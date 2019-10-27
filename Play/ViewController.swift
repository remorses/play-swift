//
//  ViewController.swift
//  Play
//
//  Created by Morse on 27/10/2019.
//  Copyright © 2019 Morse. All rights reserved.
//

import UIKit
import MongoKitten


func connect(hostname: String, port: UInt16) -> Cluster {
    let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    let hosts = [ConnectionSettings.Host(hostname: hostname, port: port)]
    let settings = ConnectionSettings(authentication: .unauthenticated, hosts: hosts)
    return try! Cluster.connect(on: group, settings: settings).wait()
}


func databases(conn: Cluster) -> [Database]{
    let databases = try! conn.listDatabases().map({ (dbs) -> [Database] in
        return dbs
    }).wait()
    return databases
}

func collections(db: Database) -> [String]{
    let collections = try! db.listCollections().map({ collections -> [String] in
        let names: [String] = collections.map({ coll in
            return coll.name
        })
        return Array(Set(names))
    }).wait()
    return collections
}

func getDb(_ conn: Cluster, name: String) -> Database {
    let db = try! conn.listDatabases().map({dbs in
        return dbs.filter({db in db.name == name})[0]
    }).wait()
    return db
}


func findOne(_ db: Database, collection: String) -> String {
    return try! db[collection].findOne().map({ doc in
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(doc)
        return String(data: data, encoding: .utf8)!
    }).wait()
}


func findMany(_ db: Database, collection: String, skip: Int = 0, limit: Int = 20) -> [String] {
    let results: EventLoopFuture<[Document]> = db[collection].find().skip(skip).limit(limit).getAllResults()
    return try! results.map { docs in
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return docs.map({doc in
            let data = try! encoder.encode(docs)
            return String(data: data, encoding: .utf8)!
        })
    }.wait()
}

func main() {
    let conn = connect(hostname: "localhost", port: 27017)
    let colls = databases(conn: conn).map({db in db.name})
    print(colls)
    let db = getDb(conn, name: "zzz")
    print(db.name)
    print(collections(db: db))
    print(findMany(db, collection: "xxx", skip: 1))
    
}



class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        main()
        
    }


}


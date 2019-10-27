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

func collections(db: Database) -> [Collection]{
    let collections = try! db.listCollections().map({ collections in
        return collections.map({ coll in
            return coll
        })
    }).wait()
    return collections
}


func main() {
    let conn = connect(hostname: "localhost", port: 27017)
    let colls = databases(conn: conn).map({db in db.name})
    print(colls)
}

main()

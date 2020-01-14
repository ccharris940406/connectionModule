//
//  clientConnection.swift
//  connectionModule
//
//  Created by Carlos César Harris Castillo on 1/14/20.
//  Copyright © 2020 Carlos César Harris Castillo. All rights reserved.
//

import Foundation
import Network

class Client {
    
    let connection: Connection

    init() {
        let nwConnection = NWConnection(host: "127.0.0.1", port: 12345, using: .tcp)
        self.connection = Connection(nwConnection: nwConnection)
    }

    func start() {
        self.connection.didStopCallback = self.didStopCallback(error:)
        self.connection.start()
    }

    func didStopCallback(error: Error?) {
        if error == nil {
            exit(EXIT_SUCCESS)
        } else {
            exit(EXIT_FAILURE)
        }
    }

    static func run() {
        let client = Client()
        client.start()
        dispatchMain()
    }
}

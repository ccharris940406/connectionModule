//
//  serverConnection.swift
//  connectionModule
//
//  Created by Carlos César Harris Castillo on 1/14/20.
//  Copyright © 2020 Carlos César Harris Castillo. All rights reserved.
//

import Foundation
import Network

class Server {

    let listener: NWListener
    private var connectionsByID: [Int: Connection] = [:]
    
    init() {
        self.listener = try! NWListener(using: .tcp, on: 12345)
        //self.timer = DispatchSource.makeTimerSource(queue: .main)
    }

    func start() throws {
        print("server will start")
        self.listener.stateUpdateHandler = self.stateDidChange(to:)
        self.listener.newConnectionHandler = self.didAccept(nwConnection:)
        self.listener.start(queue: .main)
    
        //self.timer.setEventHandler(handler: self.heartbeat)
        //self.timer.schedule(deadline: .now() + 5.0, repeating: 5.0)
        //self.timer.activate()
    }

    func stateDidChange(to newState: NWListener.State) {
        switch newState {
        case .setup:
            break
        case .waiting:
            break
        case .ready:
            break
        case .failed(let error):
            print("server did fail, error: \(error)")
            self.stop()
        case .cancelled:
            break
        default:
            break
        }
    }

    private func didAccept(nwConnection: NWConnection) {
        let connection = Connection(nwConnection: nwConnection)
        self.connectionsByID[connection.id] = connection
        connection.didStopCallback = { _ in
            self.connectionDidStop(connection)
        }
        connection.start()
        print("server did open connection \(connection.id)")
    }

    private func connectionDidStop(_ connection: Connection) {
        self.connectionsByID.removeValue(forKey: connection.id)
        print("server did close connection \(connection.id)")
    }

    private func stop() {
        self.listener.stateUpdateHandler = nil
        self.listener.newConnectionHandler = nil
        self.listener.cancel()
        for connection in self.connectionsByID.values {
            connection.didStopCallback = nil
            connection.stop()
        }
        self.connectionsByID.removeAll()
    }

    private func heartbeat() {
        let timestamp = Date()
        print("server heartbeat, timestamp: \(timestamp)")
        for connection in self.connectionsByID.values {
            let data = "heartbeat, connection: \(connection.id), timestamp: \(timestamp)\r\n"
            connection.send(data: Data(data.utf8))
        }
    }

    static func run() {
        let listener = Server()
        try! listener.start()
        dispatchMain()
    }
}

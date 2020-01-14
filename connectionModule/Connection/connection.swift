//
//  connection.swift
//  connectionModule
//
//  Created by Carlos César Harris Castillo on 1/14/20.
//  Copyright © 2020 Carlos César Harris Castillo. All rights reserved.
//

import Foundation
import Network

class Connection {
    
    let nwConnection: NWConnection
    let id: Int
    private static var nextID: Int = 0
    var didStopCallback: ((Error?) -> Void)? = nil

    init(nwConnection: NWConnection) {
        self.nwConnection = nwConnection
        self.id = Connection.nextID
        Connection.nextID += 1
    }

    func start() {
        print("connection \(self.id) will start")
        self.nwConnection.stateUpdateHandler = self.stateDidChange(to:)
        self.setupReceive()
        self.nwConnection.start(queue: .main)
    }

    func send(data: Data) {
        self.nwConnection.send(content: data, completion: .contentProcessed( { error in
            if let error = error {
                self.connectionDidFail(error: error)
                return
            }
            print("connection \(self.id) did send, data: \(data as NSData)")
        }))
    }

    func stop() {
        print("connection \(self.id) will stop")
    }

    private func stateDidChange(to state: NWConnection.State) {
        switch state {
        case .setup:
            break
        case .waiting(let error):
            self.connectionDidFail(error: error)
        case .preparing:
            break
        case .ready:
            print("connection \(self.id) ready")
        case .failed(let error):
            self.connectionDidFail(error: error)
        case .cancelled:
            break
        default:
            break
        }
    }

    private func connectionDidFail(error: Error) {
        print("connection \(self.id) did fail, error: \(error)")
        self.stop(error: error)
    }

    private func connectionDidEnd() {
        print("connection \(self.id) did end")
        self.stop(error: nil)
    }

    private func stop(error: Error?) {
        self.nwConnection.stateUpdateHandler = nil
        self.nwConnection.cancel()
        if let didStopCallback = self.didStopCallback {
            self.didStopCallback = nil
            didStopCallback(error)
        }
    }

    private func setupReceive() {
        self.nwConnection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { (data, _, isComplete, error) in
            if let data = data, !data.isEmpty {
                print("connection \(self.id) did receive, data: \(data as NSData)")
            }
            if isComplete {
                self.connectionDidEnd()
            } else if let error = error {
                self.connectionDidFail(error: error)
            } else {
                self.setupReceive()
            }
        }
    }
    
}



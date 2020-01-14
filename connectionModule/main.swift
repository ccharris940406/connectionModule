//
//  main.swift
//  connectionModule
//
//  Created by Carlos César Harris Castillo on 1/14/20.
//  Copyright © 2020 Carlos César Harris Castillo. All rights reserved.
//

import Foundation

func main() {
    switch CommandLine.arguments.dropFirst() {
    case ["client"]: Client.run()
    case ["server"]: Server.run()
    default:
        print("usage: NWTest server | client")
        exit(EXIT_FAILURE)
    }
}

main()




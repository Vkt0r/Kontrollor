//
//  KontrollorCLI.swift
//  Kontrollor
//
//  Created by Victor Sigler Lopez on 6/19/17.
//
//

let tool = KontrollorCLI()

do {
    try tool.run()
} catch {
    print("🚫  Whoops! An error occurred: \(error.localizedDescription)".lightWhite)
}

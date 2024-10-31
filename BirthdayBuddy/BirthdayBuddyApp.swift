//
//  BirthdayBuddyApp.swift
//  BirthdayBuddy
//
//  Created by Aditya Saravana on 10/30/24.
//

import SwiftUI

@main
struct BirthdayBuddyApp: App {
    @StateObject var scanner = Scanner.shared
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(scanner)
        }
    }
}

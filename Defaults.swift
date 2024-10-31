//
//  Defaults.swift
//  BirthdayBuddy
//
//  Created by Aditya Saravana on 10/30/24.
//

import Defaults

extension Defaults.Keys {
    // static let quality = Key<Double>("quality", default: 0.8)
    //            ^            ^         ^                ^
    //           Key          Type   UserDefaults name   Default value
    static let ignoredContacts = Key<[String]>("ignoredContacts", default: [])
}

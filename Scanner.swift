//
//  Scanner.swift
//  BirthdayBuddy
//
//  Created by Aditya Saravana on 10/30/24.
//

import Foundation
import SwiftyContacts
import Contacts
import Defaults
import UIKit

class Scanner: ObservableObject {
    @Published var contactsWithoutBirthdays: [CNContact] = []
    
    static let shared = Scanner()
    
    init() {
        Task {
            await scan()
        }
    }
    
    func scan() async {
        do {
            try await requestAccess()
        } catch {
            print("Error requesting access")
        }
        
        var contacts: [CNContact]? = nil
        
        do {
            contacts = try await fetchContacts()
        } catch {
            print("error fetching contacts")
        }
        
        var newContactsWithoutBirthdays: [CNContact] = []
        
        if let people = contacts {
            for contact in people {
                if contact.birthday == nil && !Defaults[.ignoredContacts].contains(contact.identifier) {
                    newContactsWithoutBirthdays.append(contact)
                }
            }
        }
        
        
        
        DispatchQueue.main.async {
            self.contactsWithoutBirthdays = newContactsWithoutBirthdays.sorted { $0.givenName < $1.givenName }
        }
    }
}

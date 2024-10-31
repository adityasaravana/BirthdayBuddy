//
//  ContentView.swift
//  BirthdayBuddy
//
//  Created by Aditya Saravana on 10/30/24.
//

import SwiftUI
import Contacts

struct ContentView: View {
    @EnvironmentObject var scanner: Scanner
    @State private var searchText = ""
    @State private var groupedContacts: [String: [CNContact]] = [:]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if scanner.contactsWithoutBirthdays.count > 0 {
                        Label("You have \(scanner.contactsWithoutBirthdays.count) contacts without birthdays", systemImage: "exclamationmark.circle").foregroundStyle(.red)
                    } else {
                        Label("All your contacts have birthdays!", systemImage: "checkmark.circle").foregroundStyle(.green)
                    }
                }
                
                ForEach(groupedContacts.keys.sorted(), id: \.self) { key in
                    Section(header: Text(key)) {
                        ForEach(groupedContacts[key]!, id: \.identifier) { contact in
                            Text(contact.givenName + " " + contact.familyName)
                        }
                    }
                }
            }
            .navigationTitle("BirthdayBuddy")
            .refreshable {
                await scanner.scan()
                groupContacts()
            }
            .searchable(text: $searchText, prompt: "Search")
            .onAppear {
                groupContacts()
            }
        }
    }

    var filteredContacts: [CNContact] {
        if searchText.isEmpty {
            return scanner.contactsWithoutBirthdays
        } else {
            return scanner.contactsWithoutBirthdays.filter { contact in
                contact.givenName.localizedCaseInsensitiveContains(searchText) ||
                contact.familyName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    private func groupContacts() {
        groupedContacts = Dictionary(
            grouping: filteredContacts,
            by: { $0.givenName.first?.uppercased() ?? "" }
        ).mapValues { $0.sorted { $0.givenName < $1.givenName } }
    }
}

#Preview {
    ContentView().environmentObject(Scanner.shared)
}

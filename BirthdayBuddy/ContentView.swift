import SwiftUI
import Contacts
import Defaults
import SwiftUIMessage

struct ContentView: View {
    @EnvironmentObject var scanner: Scanner

    @Default(.ignoredContacts) var ignoredContacts

    @State private var searchText = ""
    @State private var groupedContacts: [String: [CNContact]] = [:]

    struct MessageRecipient: Identifiable {
        let id = UUID()
        let phoneNumber: String
        let name: String
    }
    
    @State private var selectedMessageRecipient: MessageRecipient? = nil

    func refresh() async {
        await scanner.scan()
        groupContacts()
    }

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
                        ForEach(groupedContacts[key] ?? [], id: \.identifier) { contact in
                            Text(contact.givenName + " " + contact.familyName)
                                .swipeActions(edge: .trailing) {
                                    if let firstPhoneNumber = contact.phoneNumbers.first?.value.stringValue {
                                        Button {
                                            selectedMessageRecipient = MessageRecipient(phoneNumber: firstPhoneNumber, name: contact.givenName)
                                        } label: {
                                            Label("Message", systemImage: "message.fill")
                                        }
                                        .tint(.green)
                                        
                                        
                                        Button(role: .destructive) {
                                            ignoredContacts.append(contact.identifier)
                                            Task {
                                                await refresh()
                                            }
                                        } label: {
                                            Label("Ignore", systemImage: "eye.slash")
                                        }
                                    }
                                }
                                .sheet(item: $selectedMessageRecipient) { messageRecipient in
                                    if MessageComposeView.canSendText() {
                                        MessageComposeView(
                                            .init(recipients: [messageRecipient.phoneNumber], body: "Hey \(messageRecipient.name), when's your birthday? I'm trying to add everyone's birthdays to my contacts")
                                        )
                                        .ignoresSafeArea()
                                    } else {
                                        // Here you can tell the user the issue.
                                        Text("Text messages cannot be sent from your device.")
                                    }
                                }
                                
                        }
                        
                    }
                }
            }
            .navigationTitle("BirthdayBuddy")
            .refreshable {
                await refresh()
            }
            .task {
                await refresh()
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

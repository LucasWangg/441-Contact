import SwiftUI

struct Contact: Identifiable {
    var id = UUID()
    var name: String
    var position: String
    var organization: String
    var phone: String
    var email: String
    var socialMedia: String
    var description: String
}


struct ContactView: View {
    @Binding var showChat: Bool
    @State private var contacts: [Contact] = []
    @State private var selectedLetter: String? = nil
    @State private var searchText: String = ""
    @State private var scrollViewProxy: ScrollViewProxy? = nil
    @State private var commandText: String = ""

    var body: some View {
        NavigationView {
            HStack(spacing: 0) {
                // Alphabet navigator
                VStack {
                    ForEach(letters, id: \.self) { letter in
                        Button(action: {
                            selectedLetter = letter
                            searchText = ""
                        }) {
                            Text(letter)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.blue)
                                .padding(4)
                        }
                    }
                }
                .padding(.leading, 8)
                
                // Contacts List
                ScrollViewReader { proxy in
                    VStack {
                        // Command input
                        HStack {
                            TextField("Enter command", text: $commandText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button("Execute") {
                                executeCommand()
                            }
                        }
                        .padding()
                        
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                            TextField("Search by name", text: $searchText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                            
                            NavigationLink(destination: CreateContactView()) {
                                Image(systemName: "plus")
                                    .font(.system(size: 18, weight: .bold))
                                    .padding(.trailing)
                            }
                        }
                        .padding()
                        
                        List {
                            ForEach(filteredContacts) { contact in
                                NavigationLink(destination: ContactDetailView(contact: contact)) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(contact.name)
                                                .font(.headline)
                                            Text(contact.position)
                                                .font(.subheadline)
                                            Text(contact.organization)
                                                .font(.subheadline)
                                        }
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            callContact(phoneNumber: contact.phone)
                                        }) {
                                            Image(systemName: "phone.fill")
                                                .foregroundColor(.green)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                        
                                        Button(action: {
                                            showChat = true
                                        }) {
                                            Image(systemName: "message.fill")
                                                .foregroundColor(.blue)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                    .padding(.vertical, 8)
                                }
                                .id(contact.id)
                            }
                        }
                        .navigationTitle("Contacts")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    showChat = true
                                }) {
                                    Image(systemName: "message")
                                        .font(.system(size: 18, weight: .bold))
                                }
                            }
                        }
                    }
                    .onAppear {
                        scrollViewProxy = proxy
                        loadContacts()
                    }
                    .onChange(of: selectedLetter) { newValue in
                        scrollToLetter(newValue)
                    }
                }
            }
        }
    }
    
    private var letters: [String] {
        let letters = contacts.map { String($0.name.prefix(1).uppercased()) }
        return Array(Set(letters)).sorted()
    }
    
    private var filteredContacts: [Contact] {
        let sortedContacts = contacts.sorted { $0.name < $1.name }
        
        if !searchText.isEmpty {
            return sortedContacts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        return sortedContacts
    }
    
    private func loadContacts() {
        contacts = DatabaseManager.shared.fetchContacts()
    }
    
    private func executeCommand() {
        DatabaseManager.shared.executeCommand(commandText) { success in
            if success {
                loadContacts()
                commandText = ""
            } else {
                print("Failed to execute command")
            }
        }
    }
    
    private func callContact(phoneNumber: String) {
        print("Calling \(phoneNumber)")
    }
    
    private func scrollToLetter(_ letter: String?) {
        guard let letter = letter else { return }
        
        if let index = filteredContacts.firstIndex(where: { $0.name.hasPrefix(letter) }) {
            withAnimation {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    scrollViewProxy?.scrollTo(filteredContacts[index].id, anchor: .top)
                }
            }
        }
    }
}

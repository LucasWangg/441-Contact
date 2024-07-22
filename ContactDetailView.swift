import SwiftUI

struct ContactDetailView: View {
    @State var contact: Contact
    @Environment(\.presentationMode) var presentationMode
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(contact.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                HStack {
                    Button(action: {
                        callContact(phoneNumber: contact.phone)
                    }) {
                        HStack {
                            Image(systemName: "phone.fill")
                                .foregroundColor(.white)
                            Text("Call")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                    }
                    .padding(.trailing, 16)
                    
                    Button(action: {
                        messageContact(phoneNumber: contact.phone)
                    }) {
                        HStack {
                            Image(systemName: "message.fill")
                                .foregroundColor(.white)
                            Text("Message")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                }
                .padding(.bottom, 16)
                
                DetailRow(title: "Position:", value: contact.position)
                DetailRow(title: "Organization:", value: contact.organization)
                DetailRow(title: "Phone:", value: contact.phone)
                DetailRow(title: "Email:", value: contact.email)
                DetailRow(title: "Social Media:", value: contact.socialMedia)
                
                Text("Description:")
                    .fontWeight(.bold)
                Text(contact.description)
                    .padding(.bottom, 16)
                
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    Text("Delete Contact")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationTitle("Contact Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingEditSheet = true
                }) {
                    Text("Edit")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationView {
                EditContactView(contact: $contact)
            }
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete Contact"),
                message: Text("Are you sure you want to delete this contact?"),
                primaryButton: .destructive(Text("Delete")) {
                    deleteContact()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func callContact(phoneNumber: String) {
        print("Calling \(phoneNumber)")
    }
    
    private func messageContact(phoneNumber: String) {
        print("Messaging \(phoneNumber)")
    }
    
    private func deleteContact() {
        let command = "Delete contact with id \(contact.id)"
        
        DatabaseManager.shared.executeCommand(command) { success in
            if success {
                print("Contact deleted successfully")
                presentationMode.wrappedValue.dismiss()
            } else {
                print("Failed to delete contact")
            }
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.bold)
            Text(value)
        }
    }
}

struct ContactDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContactDetailView(contact: Contact(name: "John Doe", position: "Developer", organization: "Tech Co", phone: "123-456-7890", email: "john@example.com", socialMedia: "@johndoe", description: "A skilled developer"))
        }
    }
}

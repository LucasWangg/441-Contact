import SwiftUI

struct EditContactView: View {
    @Binding var contact: Contact
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name: String
    @State private var position: String
    @State private var organization: String
    @State private var phone: String
    @State private var email: String
    @State private var socialMedia: String
    @State private var description: String
    
    init(contact: Binding<Contact>) {
        self._contact = contact
        _name = State(initialValue: contact.wrappedValue.name)
        _position = State(initialValue: contact.wrappedValue.position)
        _organization = State(initialValue: contact.wrappedValue.organization)
        _phone = State(initialValue: contact.wrappedValue.phone)
        _email = State(initialValue: contact.wrappedValue.email)
        _socialMedia = State(initialValue: contact.wrappedValue.socialMedia)
        _description = State(initialValue: contact.wrappedValue.description)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Basic Information")) {
                TextField("Name", text: $name)
                TextField("Position", text: $position)
                TextField("Organization", text: $organization)
                TextField("Phone", text: $phone)
                TextField("Email", text: $email)
                TextField("Social Media", text: $socialMedia)
            }
            
            Section(header: Text("Additional Information")) {
                TextEditor(text: $description)
                    .frame(height: 100)
            }
            
            Section {
                Button(action: saveContact) {
                    Text("Save Changes")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
        }
        .navigationTitle("Edit Contact")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func saveContact() {
        let command = """
        Update contact with id \(contact.id) with the following details:
        Name: \(name)
        Position: \(position)
        Organization: \(organization)
        Phone: \(phone)
        Email: \(email)
        Social Media: \(socialMedia)
        Description: \(description)
        """
        
        DatabaseManager.shared.executeCommand(command) { success in
            if success {
                contact.name = name
                contact.position = position
                contact.organization = organization
                contact.phone = phone
                contact.email = email
                contact.socialMedia = socialMedia
                contact.description = description
                
                print("Contact updated successfully")
                presentationMode.wrappedValue.dismiss()
            } else {
                print("Failed to update contact")
            }
        }
    }
}

struct EditContactView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditContactView(contact: .constant(Contact(name: "John Doe", position: "Developer", organization: "Tech Co", phone: "123-456-7890", email: "john@example.com", socialMedia: "@johndoe", description: "A skilled developer")))
        }
    }
}

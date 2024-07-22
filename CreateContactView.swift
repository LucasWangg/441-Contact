import SwiftUI

struct CreateContactView: View {
    @State private var name = ""
    @State private var position = ""
    @State private var organization = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var socialMedia = ""
    @State private var description = ""
    @Environment(\.presentationMode) var presentationMode

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
                Button(action: createContact) {
                    Text("Create Contact")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
        }
        .navigationTitle("Create Contact")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func createContact() {
        let command = """
        Add a new contact with the following details:
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
                print("Contact created successfully")
                presentationMode.wrappedValue.dismiss()
            } else {
                print("Failed to create contact")
            }
        }
    }
}

struct CreateContactView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CreateContactView()
        }
    }
}

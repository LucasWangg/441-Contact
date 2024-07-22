import SQLite3
import Foundation

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: OpaquePointer?
    
    private init() {
        self.db = createDatabase()
        createTable()
    }
    
    private func createDatabase() -> OpaquePointer? {
        var db: OpaquePointer?
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Contacts.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database")
            return nil
        }
        
        return db
    }
    
    private func createTable() {
        let createTableString = """
        CREATE TABLE IF NOT EXISTS contacts(
        id TEXT PRIMARY KEY,
        name TEXT,
        position TEXT,
        organization TEXT,
        phone TEXT,
        email TEXT,
        socialMedia TEXT,
        description TEXT);
        """
        
        var createTableStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Contact table created.")
            } else {
                print("Contact table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
    
    func insertContact(_ contact: Contact) -> Bool {
        let insertStatementString = "INSERT INTO contacts (id, name, position, organization, phone, email, socialMedia, description) VALUES (?, ?, ?, ?, ?, ?, ?, ?);"
        var insertStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (contact.id.uuidString as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (contact.name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (contact.position as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, (contact.organization as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 5, (contact.phone as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 6, (contact.email as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 7, (contact.socialMedia as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 8, (contact.description as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
                sqlite3_finalize(insertStatement)
                return true
            } else {
                print("Could not insert row.")
                sqlite3_finalize(insertStatement)
                return false
            }
        } else {
            print("INSERT statement could not be prepared.")
            return false
        }
    }
    
    func updateContact(_ contact: Contact) -> Bool {
        let updateStatementString = "UPDATE contacts SET name = ?, position = ?, organization = ?, phone = ?, email = ?, socialMedia = ?, description = ? WHERE id = ?;"
        var updateStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(updateStatement, 1, (contact.name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 2, (contact.position as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 3, (contact.organization as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 4, (contact.phone as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 5, (contact.email as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 6, (contact.socialMedia as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 7, (contact.description as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 8, (contact.id.uuidString as NSString).utf8String, -1, nil)
            
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated row.")
                sqlite3_finalize(updateStatement)
                return true
            } else {
                print("Could not update row.")
                sqlite3_finalize(updateStatement)
                return false
            }
        } else {
            print("UPDATE statement could not be prepared.")
            return false
        }
    }
    
    func deleteContact(id: UUID) -> Bool {
        let deleteStatementString = "DELETE FROM contacts WHERE id = ?;"
        var deleteStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(deleteStatement, 1, (id.uuidString as NSString).utf8String, -1, nil)
            
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
                sqlite3_finalize(deleteStatement)
                return true
            } else {
                print("Could not delete row.")
                sqlite3_finalize(deleteStatement)
                return false
            }
        } else {
            print("DELETE statement could not be prepared.")
            return false
        }
    }
    
    func fetchContacts() -> [Contact] {
        let queryStatementString = "SELECT * FROM contacts;"
        var queryStatement: OpaquePointer?
        var contacts : [Contact] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = UUID(uuidString: String(cString: sqlite3_column_text(queryStatement, 0)))!
                let name = String(cString: sqlite3_column_text(queryStatement, 1))
                let position = String(cString: sqlite3_column_text(queryStatement, 2))
                let organization = String(cString: sqlite3_column_text(queryStatement, 3))
                let phone = String(cString: sqlite3_column_text(queryStatement, 4))
                let email = String(cString: sqlite3_column_text(queryStatement, 5))
                let socialMedia = String(cString: sqlite3_column_text(queryStatement, 6))
                let description = String(cString: sqlite3_column_text(queryStatement, 7))
                
                contacts.append(Contact(id: id, name: name, position: position, organization: organization, phone: phone, email: email, socialMedia: socialMedia, description: description))
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return contacts
    }
    
    func executeCommand(_ command: String, completion: @escaping (Bool) -> Void) {
        ChatGPTManager.shared.processCommand(command) { result in
            switch result {
            case .success(let response):
                guard let action = response["action"] as? String,
                      let contact = response["contact"] as? [String: Any] else {
                    completion(false)
                    return
                }
                
                switch action {
                case "add":
                    let newContact = Contact(
                        name: contact["name"] as? String ?? "",
                        position: contact["position"] as? String ?? "",
                        organization: contact["organization"] as? String ?? "",
                        phone: contact["phone"] as? String ?? "",
                        email: contact["email"] as? String ?? "",
                        socialMedia: contact["socialMedia"] as? String ?? "",
                        description: contact["description"] as? String ?? ""
                    )
                    completion(self.insertContact(newContact))
                    
                case "update":
                    guard let id = contact["id"] as? String,
                          let uuid = UUID(uuidString: id) else {
                        completion(false)
                        return
                    }
                    let updatedContact = Contact(
                        id: uuid,
                        name: contact["name"] as? String ?? "",
                        position: contact["position"] as? String ?? "",
                        organization: contact["organization"] as? String ?? "",
                        phone: contact["phone"] as? String ?? "",
                        email: contact["email"] as? String ?? "",
                        socialMedia: contact["socialMedia"] as? String ?? "",
                        description: contact["description"] as? String ?? ""
                    )
                    completion(self.updateContact(updatedContact))
                    
                case "delete":
                    guard let id = contact["id"] as? String,
                          let uuid = UUID(uuidString: id) else {
                        completion(false)
                        return
                    }
                    completion(self.deleteContact(id: uuid))
                    
                default:
                    completion(false)
                }
                
            case .failure(let error):
                print("Error processing command: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
}

//
//  ViewController.swift
//  ContactConverter
//
//  Created by yurim on 2020/12/02.
//

import UIKit
import Contacts

class ViewController: UIViewController {
    
    let contactStore = CNContactStore()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /* 변환 버튼 클릭 */
    @IBAction func convertButtonDidTab(_ sender: UIButton) {
        
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName)]
        let request = CNContactFetchRequest(keysToFetch: keys)

        do {
            try self.contactStore.enumerateContacts(with: request, usingBlock: convertContactName(contact:stop:))
        } catch {
            print("unable to fetch contacts")
        }
    }
    
    /* 성 이름 -> _ 성이름 */
    func convertContactName(contact: CNContact, stop: UnsafeMutablePointer<ObjCBool>) {
        
        if contact.familyName != "" {
            guard let mutableContact = contact.mutableCopy() as? CNMutableContact else { return }
            mutableContact.givenName = "\(contact.familyName)\(mutableContact.givenName)"
            mutableContact.familyName = ""
            
            let saveRequest = CNSaveRequest()
            saveRequest.update(mutableContact)
            do {
                try self.contactStore.execute(saveRequest)
            } catch {
                print("Saving contact failed, error: \(error)")
            }
        }
    }

}


//
//  ViewController.swift
//  ContactConverter
//
//  Created by yurim on 2020/12/02.
//

import UIKit
import Contacts

class ViewController: UIViewController {
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    let contactStore = CNContactStore()
    var contacts = [CNContact]()
    var contactNumber = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressBar.progress = 0
    }
    
    /* 변환 버튼 클릭 */
    @IBAction func convertButtonDidTab(_ sender: UIButton) {
        // 초기화
        self.progressBar.progress = 0
        self.contactNumber = 0
        
        // 비동기로 수행
        DispatchQueue.global().async {
            // 연락처 불러오기
            self.loadContacts()
            
            // 이름 변경
            for contact in self.contacts {
                self.convertContactName(contact)
            }
        }
    }
    
    /* 연락처 불러오기 */
    func loadContacts() {
        // 초기화
        contacts.removeAll()
        
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName)]
        let request = CNContactFetchRequest(keysToFetch: keys)
        
        do {
            try self.contactStore.enumerateContacts(with: request, usingBlock: { (contact, stop) in
                self.contacts.append(contact)
            })
        } catch {
            print("unable to fetch contacts")
        }
    }
    
    /* 성 이름 -> _ 성이름 */
    func convertContactName(_ contact: CNContact) {
        
        // 성이 있는 연락처만 작업
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
        
        // Progress Bar 업데이트
        DispatchQueue.main.async {
            let progressStatus = Float(self.contactNumber + 1) / Float(self.contacts.count)
            self.progressBar.setProgress(progressStatus, animated: true)
            self.contactNumber += 1
        }
    }

}


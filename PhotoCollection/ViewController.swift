//
//  ViewController.swift
//  PhotoCollection
//
//  Created by Apple on 24/02/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import ContactsUI

enum ContactsFilter {
    case none
    case mail
    case message
}

class ViewController: UIViewController {
   
    var phoneContacts = [PhoneContact]() // array of PhoneContact(It is model find it below)
    var filter: ContactsFilter = .none
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topCollectionView: UICollectionView!
    var image:[UIImage] = [#imageLiteral(resourceName: "icon"), #imageLiteral(resourceName: "whatsapp"), #imageLiteral(resourceName: "twitter")]
    private var allLists:[List] = []
    private let spacing: CGFloat = 10.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
     allLists = List.getAll() ?? []
        loadContacts(filter: .none)
    }

    fileprivate func loadContacts(filter: ContactsFilter) {
        phoneContacts.removeAll()
        var allContacts = [PhoneContact]()
        for contact in PhoneContacts.getContacts(filter: filter) {
            allContacts.append(PhoneContact(contact: contact))
        }
        
        var filterdArray = [PhoneContact]()
        if self.filter == .mail {
            filterdArray = allContacts.filter({ $0.email.count > 0 }) // getting all email
        } else if self.filter == .message {
            filterdArray = allContacts.filter({ $0.phoneNumber.count > 0 })
        } else {
            filterdArray = allContacts
        }
        phoneContacts.append(contentsOf: filterdArray)
        
        for contact in phoneContacts {
            print("Name -> \(contact.name)")
            print("Email -> \(contact.email)")
            print("Phone Number -> \(contact.phoneNumber)")
        }
        let arrayCode  = self.phoneNumberWithContryCode()
        for codes in arrayCode {
            print(codes)
        }
        DispatchQueue.main.async {
          self.tableView.reloadData() // update your tableView having phoneContacts array
        }
    }
       
    func phoneNumberWithContryCode() -> [String] {

        let contacts = PhoneContacts.getContacts() // here calling the getContacts methods
        var arrPhoneNumbers = [String]()
        for contact in contacts {
            for ContctNumVar: CNLabeledValue in contact.phoneNumbers {
                if let fulMobNumVar  = ContctNumVar.value as? CNPhoneNumber {
                    //let countryCode = fulMobNumVar.value(forKey: "countryCode") get country code
                       if let MccNamVar = fulMobNumVar.value(forKey: "digits") as? String {
                            arrPhoneNumbers.append(MccNamVar)
                    }
                }
            }
        }
        return arrPhoneNumbers // here array has all contact numbers.
    }
 
    @IBAction func addListButtonTapped(_ sender: UIBarButtonItem) {
        AlertUtility.showAlertWithTextField(self, title: "", message: "Enter Your List Name", placeholder: "Enter List Name") { (result) in
            if result != "" {
                _ = List.set(id:  UUID().uuidString, name: result.trimSpace(), icon: self.image[1].pngData() as NSData?, createdDate: NSDate(), images: nil)
                self.allLists = List.getAll() ?? []
                self.topCollectionView.reloadData()
            }
        }
    }
    
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allLists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        let cell = topCollectionView.dequeueReusableCell(withReuseIdentifier: "NameCollectionViewCell", for: indexPath) as! NameCollectionViewCell
        cell.nameLabel.text = allLists[indexPath.row].name
        cell.imageView.image = UIImage(data: allLists[indexPath.row].image!)
        return cell
    }
    
    
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           return CGSize(width:collectionView.frame.width / 4
            ,height:collectionView.frame.height)
       }
    
 
}


class PhoneContacts {

    class func getContacts(filter: ContactsFilter = .none) -> [CNContact] { //  ContactsFilter is Enum find it below

        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey,
            CNContactThumbnailImageDataKey] as [Any]

        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }

        var results: [CNContact] = []

        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)

            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching containers")
            }
        }
        return results
    }
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return phoneContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell") as! ContactTableViewCell
        let phone = phoneContacts[indexPath.row].phoneNumber
        cell.nameLabel.text = phoneContacts[indexPath.row].name
        cell.contactLabel.text = phone.first
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}

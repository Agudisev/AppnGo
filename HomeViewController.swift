//
//  HomeViewController.swift
//  app
//
//  Created by dhruv patel on 2/14/20.
//  Copyright © 2020 dhruv patel. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import CoreNFC

class HomeViewController: UIViewController, NFCNDEFReaderSessionDelegate {
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var logout: UIButton!
    
    
    @IBOutlet weak var startShopping: UIButton!
    
    // Ref for Retrieving data from Firebase
    var ref = DatabaseReference.init()
    
    // Constant for username
    var username = Auth.auth().currentUser?.uid
    var property = ""
    
    // For NFC Reader
    var nfcSession: NFCNDEFReaderSession?
    
    // Constant for Tap-In
    var TapToIn = "Center"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.ref = Database.database().reference()
        
    // To display user name when signed in
         self.getNameOfUser()
        
    // To make buttons looks good
        setUpElements()
        changeButton()

}
    
    
    // ADDS STYLES TO SCAN AND LOGOUT BUTTON
    func setUpElements() {
       // Creates button type borders 
       Utilities.styleFilledButton(startShopping)
       Utilities.styleFilledButton(logout)
              }
       
       
    // TAKES YOU TO VIEW CONTROLLER WHICH IS LOGOUT PROCESS
    func transitionToViewController() {
     
   let viewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.viewController) as? ViewController
     
     view.window?.rootViewController = viewController
     view.window?.makeKeyAndVisible()
    }
  
    //-------------------------------------------------------------
    // Gets username from Firestore and display on welcome screen
    //-------------------------------------------------------------
    func getNameOfUser() {
        let db = Firestore.firestore()
        
        let docRef = db.collection("users").document(username ?? "100")
        
    }

    //-------------------------------------------------------------
    // Takes you to NFC page
    //-------------------------------------------------------------
    func transitionToNFC() {
        
      let nfcviewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.nfcViewController) as? NFCViewController
        
        view.window?.rootViewController = nfcviewController
        view.window?.makeKeyAndVisible()
    }
    
//     ref.child("users").child(username ?? "User doesn't exist").queryOrderedByKey().observeSingleEvent(of: .value) { (snapshot) in
//        if snapshot.hasChildren(){
//            self.startShopping.setTitle("Continue Shopping", for: .normal)
//            print("Name exist")
//        }
//        else {
//            self.startShopping.setTitle("Start Shopping", for: .normal)
//            print("Name does't exist")
//    }
//    }
    func changeButton() {
             ref.child("users").child(username ?? "User doesn't exist").queryOrderedByKey().observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.hasChildren(){
                    self.startShopping.setTitle("Continue Shopping", for: .normal)
                }
                else {
                    self.startShopping.setTitle("Start Shopping", for: .normal)
            }
            }
    }
    
    // WHEN LOGOUT BUTTON TAPPED
    // IT WILL TAKE TO VIEW CONTROLLER
    @IBAction func logoutTapped(_ sender: Any) {
        self.transitionToViewController()
    }
    
    // NFC READER FUNCTION
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
           // print("The Session was Invalidated: \(error.localizedDescription)")
    }
    
    // NFC READER FUNCTION
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        var tapIn = ""
        for payload in messages[0].records {
           tapIn += String.init(data: payload.payload.advanced(by: 3), encoding: .utf16) ?? "Format not supported"
           }
               DispatchQueue.main.async {
                // Store "In" in the nfc tags
                self.TapToIn = tapIn
                
                // Function that will store status:IN in the cloud
                self.tapToIn()
                
                if self.TapToIn == "In" {
                    self.transitionToNFC()
                }
        }
    }
    
    // Save TapToIn to Firebase
     func tapToIn () {
         self.ref.child("users").child("Status").setValue(TapToIn)
     }
    

    // WHEN START SHOPPING BUTTON TAPPED
    // NFC READER WILL PULL UP TO WALK IN THE STORE
    // IT WILL TAKE TO NFC SCAN PAGE
    @IBAction func startTapped(_ sender: Any) {
        
        // To Start Shopping without scanning at gate
        // IF came back to HOME SCREEN
        ref.child("users").child(username ?? "User doesn't exist").queryOrderedByKey().observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChildren(){
                self.changeButton()
                self.transitionToNFC()
            }
            else{
                self.nfcSession = NFCNDEFReaderSession.init(delegate: self, queue: nil, invalidateAfterFirstRead: true)
                self.nfcSession?.begin()
            }
        
        }

        
    }
    
 
    
} // END OF MAIN


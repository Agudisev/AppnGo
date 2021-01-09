//
//  CheckoutViewController.swift
//  app
//
//  Created by dhruv patel on 6/21/20.
//  Copyright © 2020 dhruv patel. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import CoreNFC


class CheckoutViewController: UIViewController, NFCNDEFReaderSessionDelegate {
   
    

    @IBOutlet weak var home: UIButton!
    
    @IBOutlet weak var logout: UIButton!
    
    @IBOutlet weak var sumLabel: UILabel!
    
    // Ref for Retrieving data from Firebase
    var ref = DatabaseReference.init()
    // For NFC Reader
    var nfcSession: NFCNDEFReaderSession?
    
    var receiveSum : Double = 0
    
    // Constant for Tap-In
    var TapToOut = "Center"
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = Database.database().reference()
        setUpElements()
        // ADD USER'S NAME BEFORE YOUR TOTAL IS!!!!!!!!!!
        sumLabel.text = "Your Total was: $\(receiveSum)"
    }
    
  
    //---------------------------------------------
    // TAKES YOU TO VIEW CONTROLLER PAGE (LOGOUT)
    //---------------------------------------------
    func transitionToViewController() {
      let viewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.viewController) as? ViewController
        view.window?.rootViewController = viewController
        view.window?.makeKeyAndVisible()
    }
    
    //---------------------------------------------
    // TAKES YOU TO HOME PAGE CONTROLLER
    //---------------------------------------------
    func transitionToHome() {
      let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeViewController
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    
    //---------------------------------------------
    // ADDIND STYLES TO BUTTONS
    //---------------------------------------------
    func setUpElements() {
        Utilities.styleFilledButton(home)
        Utilities.styleHollowButton(logout)
      }
    
    //------------------------------------------------
    // TRANSITION TO HOME PAGE WHEN HOME BUTTON TAPPED
    //------------------------------------------------
    @IBAction func homeTapped(_ sender: Any) {
        transitionToHome()
    }
    
    
    // Save TapToIn to Firebase
     func tapToOut () {
         self.ref.child("users").child("Status").setValue(TapToOut)
     }
    
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        // print("The Session was Invalidated: \(error.localizedDescription)")
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        var tapOut = ""
        for payload in messages[0].records {
           tapOut += String.init(data: payload.payload.advanced(by: 3), encoding: .utf16) ?? "Format not supported"
           }
        DispatchQueue.main.async {
            
            // Store "Out" in the nfc tags
            self.TapToOut = tapOut
            
            // Function that will store status in the cloud
            self.tapToOut()
            
            if self.TapToOut == "Out" {
                self.transitionToViewController()
            }
            
        }
        
     
        
    }
    
    
    //----------------------------------------------------
    // Before: TRANSITION TO VIEW PAGE WHEN LOGOUT BUTTON TAPPED
    // NOW: AFTER TAPPED, PROMT NFC READER AND STORE STATUS OUT IF TAPPED
    //----------------------------------------------------
    @IBAction func logoutTapped(_ sender: Any) {
 //        // UNCOMMENT THIS TO IMPLIMENT NFC READER FOR START SHOPPING
        nfcSession = NFCNDEFReaderSession.init(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.begin()
//        //EDIT\\
        // UNCOMMENT THIS TO IMPLIMENT NFC READER TO EXIT |^
        
        
        // COMMENT THIS ONE OUT WHEN ENABLING NFC READER FOR EXIT
        // TO GET TO VIEW CONTROLLER WITHOUT TAPPING THE TAG
//        self.transitionToViewController()
        // COMMENT THIS ONE OUT WHEN ENABLING NFC READER TO EXIT |^
        
        
        
    }
    
    
    
}

//
//  NFCViewController.swift
//  app
//
//  Created by dhruv patel on 6/7/20.
//  Copyright © 2020 dhruv patel. All rights reserved.
//

import UIKit
import Firebase
import CoreNFC
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage


class NFCViewController: UIViewController, NFCNDEFReaderSessionDelegate {

    // STORE PRICE FOR LAST SCANNED TAG "label"

    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var scan: UIButton!
    
    @IBOutlet weak var back: UIButton!
    
    @IBOutlet weak var checkout: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var totalLabel: UILabel!
    
    // Store Image for Last Scanned Tag "storeImg"
    @IBOutlet weak var storeImg: UIImageView!
    
    // Ref for Retrieving data from Firebase
    var ref = DatabaseReference.init()
    
    // arrData is an array of Price on Firebase Database
    var arrData = [NFCModel]()
    var username = Auth.auth().currentUser?.uid
    var username1 = Auth.auth().currentUser?.email
    
    // Var From techcoderx
    var keyArray: [String] = []
    
    // GETTING VALUE OF SUM AND PASSING TO CHECKOUT PAGE
    var sum : Double = 0
    var sendSum : Double = 0
    var roundedSum = 0.0
    
    // Variable to separate Price from tags
    var intVal : String = ""
    
    // Variable to seprate text for IMAGE
    var name: String = " "

    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = Database.database().reference()
    // BETTER LOOK FOR TABLE VIEW
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
    // HIDE BACK BUTTON
        back.isHidden = false
        self.getAllFIRData()
        self.getSum()
        
    // Wait for few sec and then update center to DB
        // STORES STATUS TO CENTER IN FIREBASEDATABASE
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.ref.child("users").child("Status").setValue("Center")
            //change if incorrect!
            self.ref.child("users").child("Name").setValue("App&GO")
            }
        
    // UPDATE THE FIREBASE CLOUD FOR TAP-IN
    //  self.ref.child("users").child("Status").removeValue()
    }
    
    //-------------------------------------------------------------
    // TAKES TO HOMEPAGE
    //-------------------------------------------------------------
    func transitionToHome() {
      let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeViewController
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    //-------------------------------------------------------------
    // TAKES TO CheckOut Page
    //-------------------------------------------------------------
    func transitionToCheckOutPage() {
      let checkoutController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.checkoutController) as? CheckoutViewController
        view.window?.rootViewController = checkoutController
        view.window?.makeKeyAndVisible()
    }
    
     var nfcSession: NFCNDEFReaderSession?
     var word = "None"
    
    //-------------------------------------------------------------
    // ADDING ALL THE ACTION OUTLETS
    //-------------------------------------------------------------

    // SCAN BUTTON TAPPED
    @IBAction func scanTapped(_ sender: Any) {
        nfcSession = NFCNDEFReaderSession.init(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.begin()
        
    }

    // BACK BUTTON TAPPED
    @IBAction func backTapped(_ sender: Any) {
    // Take to Virtual Cart if back button is tapped!
       transitionToHome()
    }
    
    //____________________________________________________________________
    // FUNCTION WILL EXECUTE IF AND ONLY IF THERE IS ERROR WITH THE TAG READER SESSION
    //____________________________________________________________________
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
       // print("The Session was Invalidated: \(error.localizedDescription)")
        }
    
    //____________________________________________________________________
    // FUNCTION WILL EXECUTE IF AND ONLY IF TAG READER SESSION IS ON
    //____________________________________________________________________
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
    var result = ""
    for payload in messages[0].records {
    result += String.init(data: payload.payload.advanced(by: 3), encoding: .utf16) ?? "Format not supported"
    }
        DispatchQueue.main.async {
            // ASSIGN TAG VALUE TO LABEL ON APP
            self.label.text = result
            // Print Price
            self.separatePrice()
            // GET TEXT FROM TAG
             self.sepText()
            // assign image view to last scanned
            self.storeImg.image = UIImage(named: self.name)
            // SAVE DATA REALTIME
            self.saveFIRData()
            // GET DATA REALTIME
            self.getAllFIRData()
            //Let firebase get updated to get the sum value
            DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                // GET TOTAL SUM
                self.getSum()
            }
              }
             }
    
    // REALTIME DATABASE STORE DATA
    //____________________________________________________________________
    // FUNCTION TO SAVE DATA TO FIREBASE DATABASE
    // WHEN NFC TAG IS TAPPED THROUGH APP -- "Yogesh Method"
    //____________________________________________________________________
    func saveFIRData() {
        self.uploadImage(self.storeImg.image) { url in
            self.saveImage(profileImageURL: url!) { success in
                if success != nil {
                    print("SUCCESS")
                }
            }
        }
    } // END OF FUNCTION
    
    // REALTIME DATA BASE GET DATA
    //____________________________________________________________________
    // FUNCTION TO RETRIVE DATA FROM FIRBASE AND ADD TO TABLE VIEW ON APP
    // Getting Data from Firebase (Yogesh Youtube)
    //____________________________________________________________________
    func getAllFIRData() {
       // self.ref.child("users").queryOrderedByKey().observe(.value){ (snapshot) in
        self.ref.child("users").child(username ?? "Didn't find Current User").queryOrderedByKey().observe(.value){ (snapshot) in
            self.arrData.removeAll()
            if let snapShot = snapshot.children.allObjects as? [DataSnapshot]{
                    if let mainDict = snap.value as?[String: AnyObject]{
                        let Price = mainDict["Price"] as? String
                        let Name = mainDict["Name"] as? String
                        let profileImageURL = mainDict["profileImageURL"] as? String ?? ""
                        self.tableView.reloadData()
                    }}}}} // END OF FUNCTION
    
    //____________________________________________________________________
            
            func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
                         return true
                     }
    
           func getallkeys(){
            ref.child("users").child(username ?? "Didn't find Current User").observeSingleEvent(of: .value) { (snapshot) in
                    for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    let key = snap.key
                    self.keyArray.append(key)
                }}
              } // END OF FUNCTION
    
    // REALTIME DATA DELETE
            //____________________________________________________________________
            // DELETING DATA FROM APP AND THAT WILL DELETE IN REALTIME FIREBASE DATABASE
            //____________________________________________________________________
            func tableView (_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
                if editingStyle == .delete {
                    getallkeys()
                    let when = DispatchTime.now() + 1
                    DispatchQueue.main.asyncAfter(deadline: when, execute:  {
                        
                        self.ref.child("users").child(self.username ?? "Didn't find Current User").child(self.keyArray[indexPath.row]).removeValue()
                        self.arrData.remove(at: indexPath.row)
                      
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        self.getSum()
                        self.keyArray = []
                    })
                }
            } // END OF TABLEVIEW
    
    // ADD Tags
    func getSum() {
        
        ref.child("users").child(username ?? "Didn't find Current User").observeSingleEvent(of: .value) { (snapshot) in
       //    var sum: Double = 0
            self.sum = 0
            
            // Total Label shows total on virtual cart
            self.totalLabel.text = "Total: $\(String(self.roundedSum))"
            
            // Store Total Price to FireBase
            print("Final sum: \(self.sum)")
        }
    
    } // END OF FUNCTION
    
   
    // WHEN CHECKOUT BUTTON IS TAPPED
    // NFC READER WILL PULL UP, TAP TO WALK OUT!
    @IBAction func checkoutTapped(_ sender: Any) {
        self.ref.child("users").child(self.username ?? "Didn't find Current User").removeValue()
        sendSum = roundedSum
        performSegue(withIdentifier: "sum", sender: self)

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! CheckoutViewController
        vc.receiveSum = self.sendSum
    }
    
    
} //END OF MAIN

extension NFCViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
              return 100
          }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return arrData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        cell.nfcModel = arrData[indexPath.row]
        // make rounded cells
        cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 2
        cell.roundedImage()
            return cell
       }
} // END OF TABLEVIEW EXTENSTION

// EXTENSION FOR UPLOADING AND SAVING IMAGE TO DATABASE
extension NFCViewController {
       func uploadImage(_ Image: UIImage?, completion: @escaping ((_ url: URL?)  -> ()) ){
           let storageRef = Storage.storage().reference().child(name)
           guard let imgData = storeImg.image?.pngData() else { return  }
           let metaData = StorageMetadata()
           metaData.contentType = "image/png"
           storageRef.putData(imgData, metadata: metaData) {(metadata, error) in
               if error == nil {
                   storageRef.downloadURL(completion: {(url,error) in
                       completion(url)
                   } )
               }else{
                   print("error in save image")
                  completion(nil)
               }
       
           }
       }
       
       func saveImage(profileImageURL: URL, completion: @escaping ((_ url: URL?)  -> ()) ){
           let dict = ["Price": intVal, "Name": label.text as Any, "profileImageURL": profileImageURL.absoluteString] as [String : Any]
            self.ref.child("users").child(username ?? "Didn't find Current user").childByAutoId().setValue(dict)
       }
   }

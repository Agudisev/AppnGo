    //
    //  ViewController.swift
    //  nfc
    //
    //  Created by dhruv patel on 5/5/20.
    //  Copyright © 2020 dhruv patel. All rights reserved.
    //

    import UIKit
    import CoreNFC
    import Firebase
    
   
    


    class ViewController: UIViewController, NFCNDEFReaderSessionDelegate {
        
        @IBOutlet weak var label: UILabel!
      
        @IBOutlet weak var tableView: UITableView!
        
        @IBOutlet weak var myImageView: UIImageView!
    
        // FOR IMAGE VIEW ON CELL
//        let testImg = ["test"]
        // color
        let blue = UIColor.blue
        let green = UIColor.green
        
        // Ref for Retrieving data from Firebase
        var ref = DatabaseReference.init()
        
        // arrData is an array of Price on Firebase Database
        var arrData = [NFCModel]()
      
        // Var From techcoderx
        var keyArray: [String] = []
        
        // ADD NFC TAPS
        var sumArray: [String] = []
        var TotalArray : [String] = []

        // Variable to seprate text
        var name: String = " "
        
        // variable to store sum value
        var sum : Double = 0
     // Variable to separate Price from tags
     var intVal1 : Int = 0
     var intVal : String = ""
        

        
        //____________________________________________________________________
        // VIEW DID LOAD FUNCTION
        //____________________________________________________________________
        override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view.
            // Set the firebase reference
            self.ref = Database.database().reference()

                //make table view look good
            tableView.separatorStyle = .none
            tableView.showsVerticalScrollIndicator = false
            self.getallkeys()
            self.getAllFIRData()
    
            
        }
        //____________________________________________________________________
        
        var nfcSession: NFCNDEFReaderSession?
        var word = "None"
        
        //____________________________________________________________________
        // SCAN BUTTON FUNCTION IF TAPPED THEN DO THE FOLLOWING
        //____________________________________________________________________
        @IBAction func scanTapped(_ sender: Any) {
            nfcSession = NFCNDEFReaderSession.init(delegate: self, queue: nil, invalidateAfterFirstRead: true)
            nfcSession?.begin()
        }
        //____________________________________________________________________
        
        //____________________________________________________________________
        // FUNCTION WILL EXECUTE IF AND ONLY IF THERE IS ERROR WITH THE TAG READER SESSION
        //____________________________________________________________________
        func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
            // print("The Session was Invalidated: \(error.localizedDescription)")
          }
        //____________________________________________________________________
        
        
        //____________________________________________________________________
        // FUNCTION WILL EXECUTE IF AND ONLY IF TAG READER SESSION IS ON
        //____________________________________________________________________
        func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
             // ADD NFC TAPS
       //     var total: Double = 0
            var result = ""
            for payload in messages[0].records {
               result += String.init(data: payload.payload.advanced(by: 3), encoding: .utf16) ?? "Format not supported"
           }
            DispatchQueue.main.async() {
            // ASSIGN TAG VALUE TO LABEL ON APP
                self.label.text = result
                
                self.separatePrice()
            //    self.getTotalSum()
                
            // obtain text value
                self.sepText()
                
                // assign image view
                self.myImageView.image = UIImage(named: self.name)
                
            // SAVE DATA REALTIME
                self.saveFIRData()
 
            // GET DATA REALTIME
                self.getAllFIRData()
                
            // DELETE DATA REALTIME
             //   self.getallkeys()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                     self.getSum()
                }
                
               
           }
          }
        //____________________________________________________________________
  
        
        
        
        //____________________________________________________________________
        // SEPERATE TEXT FROM TAG AND USE IT TO ASSIGN PIC OF ITEM
        //____________________________________________________________________
        
        func sepText(){
            
            let stopAt = ":"
            let tagName = self.label.text
            let tagNameArr = tagName?.components(separatedBy: stopAt)
            name = tagNameArr![0]
            
        }
          
        
        
        // REALTIME DATABASE STORE DATA
        //____________________________________________________________________
        // FUNCTION TO SAVE DATA TO FIREBASE DATABASE
        // WHEN NFC TAG IS TAPPED THROUGH APP -- "Yogesh Method"
        //____________________________________________________________________
        func saveFIRData() {
            self.uploadImage(self.myImageView.image) { url in
                self.saveImage(profileImageURL: url!) { success in
                    if success != nil {
                        print("SUCCESS")

                    }
                }
            }

            
//            let dict = ["Price": label.text]
//            self.ref.child("Value").childByAutoId().setValue(dict)
        }
        //____________________________________________________________________
        
        
     
        
        // REALTIME DATABASE GET DATA
        //____________________________________________________________________
        // FUNCTION TO RETRIVE DATA FROM FIRBASE AND ADD TO TABLE VIEW ON APP
        // Getting Data from Firebase (Yogesh Youtube)
        //____________________________________________________________________
        func getAllFIRData() {
       //    var sum : Double = 0.0
            self.ref.child("Value").queryOrderedByKey().observe(.value){ (snapshot) in
                self.arrData.removeAll()
                if let snapShot = snapshot.children.allObjects as? [DataSnapshot]{
                    for snap in snapShot {
                        if let mainDict = snap.value as?[String: AnyObject]{
                            let Price = mainDict["Price"] as? String
                            let profileImageURL = mainDict["profileImageURL"] as? String ?? ""
                            self.arrData.append(NFCModel(Price: Price ?? "100", profileImageURL: profileImageURL))
                            //add tags
                            //let sum = Double(Price!) ?? 100

                            self.tableView.reloadData()
                        }}
               //      print(sum)
                  
                }}
        }
        //____________________________________________________________________

        
         // ADD Tags
//            func getSum() {
//                //observeSingleEvent
//                self.sum = 0
//                ref.child("Value").observeSingleEvent(of: .value) { (snapshot) in
//               //    var sum: Double = 0
//                    for snap in snapshot.children.allObjects as! [DataSnapshot] {
//
//
//                        let price = snap.childSnapshot(forPath: "Price").value as! String
//                        self.sum += Double(price) ?? 10
//
//                      print("-------------------------------------")
//                      print("Final sum: \(self.sum)")
//                    print("---------------------------------------")
//                }
//
//            } // END OF GET SUM
//
//        }
        
        //____________________________________________________________________
        
        func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
                     return true
                 }
//
       func getallkeys(){
        ref.child("Value").observeSingleEvent(of: .value) { (snapshot) in
                for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key
                self.keyArray.append(key)
            }
            }
          }

        // REALTIME DATA DELETE
        //____________________________________________________________________
        // DELETING DATA FROM APP AND THAT WILL DELETE IN REALTIME FIREBASE DATABASE
        //____________________________________________________________________
        func tableView (_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                getallkeys()
                let when = DispatchTime.now() + 1
                DispatchQueue.main.asyncAfter(deadline: when, execute:  {
                    // Change keyArray to arrData
                    //self.ref.child("Value").child(self.keyArray[indexPath.row]).removeValue()

                    self.arrData.remove(at: indexPath.row)

                    tableView.deleteRows(at: [indexPath], with: .fade) // .automatic
                    self.ref.child("Value").child(self.keyArray[indexPath.row]).removeValue()
                    self.keyArray = []
                })
            
               
            }
        }
    
        //____________________________________________________________________
        // FUNCTION -> SEPARATE PRICE FROM THE STRING
        //____________________________________________________________________
        func separatePrice() {
//            let tag = label.text // whatever set on nfc tags
//            let tagArr = tag?.split(separator: " ")
//
//            for item in tagArr ?? [] {
//                let part = item.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
//                intVal1 = Int(part) ?? 0
//                intVal = String(intVal1)
//            }
            let tag = label.text // whatever set on nfc tags
            
            if let range = tag?.range(of: "$") {
                let price = tag?[range.upperBound...]
                intVal = String(price ?? "100")
//                intVal1 = Int(price ?? "100") ?? 0
//                intVal = String(intVal1)
//                print(price ?? "100") // prints "123.456.7891"
//                print(intVal1)
 //               print(intVal)
        }
        }
        
        // ADD Tags
        func getTotalSum() {
            
            ref.child("Value").observeSingleEvent(of: .value) { (snapshot) in
                var sum: Double = 0
                for snap in snapshot.children.allObjects as! [DataSnapshot] {
                    let price = snap.childSnapshot(forPath: "Price").value as! String
                    sum += Double(price) ?? 100
               }
               print("Final sum is: \(sum)")
            }
      }// END OF GET SUM
        
      
        @IBAction func checkOutTapped(_ sender: Any) {
      
        }
        
        
        
        
         } // END OF MAIN FUNCTION


        
    extension ViewController: UITableViewDelegate, UITableViewDataSource {
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 100
        }
 
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return arrData.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
            let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
            
            // make rounded cells
            cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 2
            cell.roundedImage()
            
            cell.nfcModel = arrData[indexPath.row]

            
            return cell
        }
        
  }
//
    
    // YOGESH's METHOD
    
    extension ViewController {
        
        func uploadImage(_ Image: UIImage?, completion: @escaping ((_ url: URL?)  -> ()) ){
            let storageRef = Storage.storage().reference().child(name)
            guard let imgData = myImageView.image?.pngData() else { return  }
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
            let dict = ["Price": intVal , "profileImageURL": profileImageURL.absoluteString] as [String : Any]
             self.ref.child("Value").childByAutoId().setValue(dict)
        }
    
         func getSum() {
                        //observeSingleEvent
                        self.sum = 0
                        ref.child("Value").observeSingleEvent(of: .value) { (snapshot) in
                       //    var sum: Double = 0
                            for snap in snapshot.children.allObjects as! [DataSnapshot] {
        
        
                                let price = snap.childSnapshot(forPath: "Price").value as! String
                                self.sum += Double(price) ?? 10
                                let roundSum = round(100.0 * self.sum) / 100.0
                                
                              print("-------------------------------------")
                              print("Final sum: \(self.sum)")
                            print("Final Rounded Sum: \(roundSum)")
                            print("---------------------------------------")
                        }
        
                    } // END OF GET SUM
        
                }
    
    
        
    }

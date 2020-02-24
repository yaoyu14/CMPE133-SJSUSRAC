//
//  CancelTimeSlotViewController.swift
//  SJSUSRAC
//
//  Created by Daniel Lee on 10/28/19.
//  Copyright © 2019 Daniel Lee. All rights reserved.
//

import UIKit
import Firebase

class CancelTimeSlotViewController: UIViewController {

    @IBOutlet weak var firstCancelButton: UIButton!
    @IBOutlet weak var secondReservationLabel: UILabel!
    @IBOutlet weak var firstReservationLabel: UILabel!
    @IBOutlet weak var secondCancelButton: UIButton!
    
    var reservedTime = [String:String]()
    
    let db = Firestore.firestore()
    let currentUid = Auth.auth().currentUser!.uid
    let timeReference = Firestore.firestore().collection("reservation_chart")
    
    @IBAction func firstCancelButtonTapped(_ sender: Any) {
        updateTimeSlot(date: reservedTime.first!.key)
        createAlert(title: "CONFIRMED", message: "Your reservation got cancelled!")
        if reservedTime.count == 0{
            firstCancelButton.isHidden = true
            firstReservationLabel.alpha = 0
        }
        updateCurrentUserReservation()
    }
    
    @IBAction func secondCancelButtonTapped(_ sender: Any) {
        updateTimeSlot(date: Array(reservedTime.keys)[1])
        createAlert(title: "CONFIRMED", message: "Your reservation got cancelled!")
        secondCancelButton.isHidden = true
        secondReservationLabel.alpha = 0
        updateCurrentUserReservation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstReservationLabel.alpha = 0
        secondReservationLabel.alpha = 0
        firstCancelButton.isHidden = true
        secondCancelButton.isHidden = true
        updateLabels()
        
        // Do any additional setup after loading the view.
        setElements()
    }
    
    // create popup message
    private func createAlert (title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion:nil)
            self.transitionToHomePage()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // update time slot for reservation from database and reserved time dictionary
    private func updateTimeSlot(date: String) {
        var tempTimeslot = [String:Any]()
        timeReference.addSnapshotListener { (snapshot, _) in
            guard let snapshot = snapshot else { return }
            let doc = snapshot.documents
            if date == "12/05/19 rack1" {
                tempTimeslot = doc[0].data()
                if self.reservedTime[date] != nil {
                    tempTimeslot.updateValue(true, forKey: self.reservedTime[date]!)
                    self.timeReference.document("LjUpSZCIviFeSq3fPCzc").setData(tempTimeslot)
                    // update reserved time dictionary
                    self.reservedTime.removeValue(forKey: "12/05/19 rack1")
                    print(self.reservedTime)
                }
                
            } else if date == "12/06/19 rack1" {
                tempTimeslot = doc[1].data()
                if self.reservedTime[date] != nil{
                    tempTimeslot.updateValue(true, forKey: self.reservedTime[date]!)
                    self.timeReference.document("SIg6q6u9flbtkVWTiPYn").setData(tempTimeslot)
                    
                    // update reserved time dictionary
                    self.reservedTime.removeValue(forKey: "12/06/19 rack1")
                    print(self.reservedTime)
                }
            }
        }
        
    }
    
    // updating reservation labels
    private func updateLabels() {
        db.collection("users").whereField("uid", isEqualTo: currentUid).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting Document")
            } else {
                let doc = querySnapshot!.documents[0]
                let documentId = doc.documentID
                let reservationRef = self.db.collection("users").document(documentId)
                reservationRef.getDocument { (snapshot, err) in
                    if let err = err {
                        print("Error occured")
                    } else {
                        let doc = snapshot!.get("reservation") as! [String:String]
                        self.reservedTime = doc
                        if self.reservedTime.count > 0 {
                            self.firstReservationLabel.text = self.reservedTime.first!.key + " at " + self.reservedTime.first!.value
                            self.firstReservationLabel.alpha = 1
                            self.firstCancelButton.isHidden = false
                            if self.reservedTime.count > 1 {
                                self.secondReservationLabel.text = Array(self.reservedTime.keys)[1] + " at " + Array(self.reservedTime.values)[1]
                                self.secondReservationLabel.alpha = 1
                                self.secondCancelButton.isHidden = false
                            }
                        }
                        
                    }
                }
                
            }
        }
    }
    
    private func updateCurrentUserReservation() {
        let emptyDic = [String:String]()
        db.collection("users").whereField("uid", isEqualTo: currentUid).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting Document")
            } else {
                let doc = querySnapshot!.documents[0]
                let documentId = doc.documentID
                let reservationRef = self.db.collection("users").document(documentId)
                reservationRef.setData(["reservation" : emptyDic], merge: true)
                reservationRef.setData(["reservation" : self.reservedTime], merge: true)
                
            }
        }
    }
    
    private func transitionToHomePage() {
        let homeViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.HomeViewController) as? HomeViewController
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    
    private func setElements() {
        Utilities.differentStyleFilledButton(firstCancelButton)
        Utilities.differentStyleFilledButton(secondCancelButton)
    }
}

//
//  ReserveTimeSlotViewController.swift
//  SJSUSRAC
//
//  Created by Daniel Lee on 10/28/19.
//  Copyright © 2019 Daniel Lee. All rights reserved.
//

import UIKit
import Firebase

class ReserveTimeSlotViewController: UIViewController {

    @IBOutlet weak var selectDateButton: UIButton!
    @IBOutlet weak var selectTimeButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var dateTblView: UITableView!
    @IBOutlet weak var timeTblView: UITableView!
    
    var selectedButton = UIButton()
    var reservedTime = [String:String]()
    var reservationChart = [String:Any]()
    var timeAlreadyLoaded = false
    var dateSource = ["12/05/19 rack1", "12/06/19 rack1"]
    var timeSource = [String]()
    
    @IBAction func confirmButtonTapped(_ sender: Any) {
        // get uid
        if selectDateButton.titleLabel!.text! == "Select the date", selectTimeButton.titleLabel!.text! == "Select the time" {
            errorLabel.text = "Please fill all area"
            errorLabel.alpha = 1
        } else {
            reservedTime = [selectDateButton.titleLabel!.text!:selectTimeButton.titleLabel!.text!]
            updateCurrentUserReservation(reservedTime: reservedTime)
            updateReservationChart()
        }
    }
    
    @IBAction private func dateButtonTapped(_ sender: Any) {
        if dateTblView.isHidden {
            animate(view: dateTblView, toggle: true)
            timeAlreadyLoaded = false
        } else {
            animate(view: dateTblView, toggle: false)
        }
        selectedButton = selectDateButton
    }
    
    @IBAction private func timeButtonTapped(_ sender: Any) {
        
        if timeAlreadyLoaded == false {
            timeSource = [String]()
            
            // check if the user selects the date first
            if selectDateButton.titleLabel?.text == "Select the date" {
                self.timeSource = ["Select date first!"]
            } else {
                let timeReference = Firestore.firestore().collection("reservation_chart")
                timeReference.addSnapshotListener { (snapshot, _) in
                    guard let snapshot = snapshot else { return }
                    let doc = snapshot.documents
                    var dic = doc[0].data()
                    if self.selectDateButton.titleLabel?.text == "12/06/19 rack1" {
                        dic = doc[1].data()
                    }
                    self.reservationChart = dic
                    for (time, bool) in dic{
                        if let availability = bool as? Bool, availability==true {
                            self.timeSource.append(time)
                        }
                    }
                    self.timeSource.sort()
                }
            }
            timeAlreadyLoaded = true
        }
        
        timeTblView.reloadData()
        
        // show and hide drop down menu
        if timeTblView.isHidden {
            animate(view: timeTblView, toggle: true)
        } else {
            animate(view: timeTblView, toggle: false)
        }
        selectedButton = selectTimeButton
    }
    
    private func animate(view: UITableView, toggle: Bool) {
        switch view{
        case dateTblView:
            if toggle {
                UIView.animate(withDuration: 0.3) {
                    self.dateTblView.isHidden = false
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.dateTblView.isHidden = true
                }
            }
        case timeTblView:
            if toggle {
                UIView.animate(withDuration: 0.3) {
                    self.timeTblView.isHidden = false
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.timeTblView.isHidden = true
                }
            }
        default:
            print("Nothing")
        }
        
    }
    
    // update current user's reservation status
    private func updateCurrentUserReservation(reservedTime: [String:String]){
        let db = Firestore.firestore()
        let currentUid = Auth.auth().currentUser!.uid
        db.collection("users").whereField("uid", isEqualTo: currentUid).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting Document")
            } else {
                let doc = querySnapshot!.documents[0]
                let documentId = doc.documentID
                print(documentId)
                let reservationRef = db.collection("users").document(documentId)
                
                reservationRef.setData(["reservation" : reservedTime], merge: true)
                
            }
        }
    }
    
    private func updateReservationChart() {
        let timeReference = Firestore.firestore().collection("reservation_chart")
        reservationChart[reservedTime.first!.value] = false
        if self.selectDateButton.titleLabel?.text == "12/05/19 rack1" {
            timeReference.document("LjUpSZCIviFeSq3fPCzc").setData(reservationChart)
            transitionToHomePage()
        } else if self.selectDateButton.titleLabel?.text == "12/06/19 rack1" {
            timeReference.document("SIg6q6u9flbtkVWTiPYn").setData(reservationChart)
            transitionToHomePage()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.alpha = 0
        // Do any additional setup after loading the view.
        
        dateTblView.isHidden = true
        timeTblView.isHidden = true
        setElements()
    }
    
    private func transitionToHomePage() {
        let homeViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.HomeViewController) as? HomeViewController
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    
    private func setElements() {
        Utilities.styleFilledButton(confirmButton)
        Utilities.styleFilledButton(selectDateButton)
        Utilities.styleFilledButton(selectTimeButton)
    }

}

extension ReserveTimeSlotViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        switch tableView {
        case dateTblView:
            numberOfRows = dateSource.count
        case timeTblView:
            numberOfRows = timeSource.count
        default:
            print("Nothing")
        }
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        switch tableView{
        case dateTblView:
            cell = tableView.dequeueReusableCell(withIdentifier: "dateCell", for: indexPath)
            cell.textLabel?.text = dateSource[indexPath.row]
        case timeTblView:
            cell = tableView.dequeueReusableCell(withIdentifier: "timeCell", for: indexPath)
            cell.textLabel?.text = timeSource[indexPath.row]
        default:
            print("Nothing")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedButton == selectDateButton {
            selectedButton.setTitle(dateSource[indexPath.row], for: .normal)
            animate(view: dateTblView, toggle: false)
        } else if selectedButton == selectTimeButton{
            selectedButton.setTitle(timeSource[indexPath.row], for: .normal)
            animate(view: timeTblView, toggle: false)
        }
        
    }
    
}

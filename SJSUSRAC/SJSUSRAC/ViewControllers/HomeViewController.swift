//
//  HomeViewController.swift
//  SJSUSRAC
//
//  Created by Daniel Lee on 10/27/19.
//  Copyright © 2019 Daniel Lee. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {

    @IBOutlet weak var reserveTimeSlotButton: UIButton!
    @IBOutlet weak var cancelTimeSlotButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var busyHoursChart: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var checkInButton: UIButton!
    @IBOutlet weak var scanQRCodeButton: UIButton!


    private func getDay() {
        let weekday = Calendar.current.component(.weekday, from: Date())
        dayLabel.text = Calendar.current.weekdaySymbols[weekday-1]
        dayLabel.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
    }


    @IBAction func signOut(_ sender: Any) {
        transitionToFirstPage()
    }

    @IBAction func checkInButtonTapped(_ sender: Any) {
        confirmCheckIn()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        busyHoursChart.contentMode = .scaleAspectFit
        // Do any additional setup after loading the view.
        MacawChartView.playAnimation()
        //dayLabel.text = String(weekday)
        getDay()
        setElements()
    }

    // reset time slots in database every day
    private func resetTimeSlots () {
        let time = getCurrentTime()

        let timeReference = Firestore.firestore().collection("reservation_chart")
        if time == "12:00 PM"{

            timeReference.addSnapshotListener { (snapshot, _) in
                guard let snapshot = snapshot else { return }
                let doc = snapshot.documents
                let dic = doc[1].data()
                var renewedTimeSlot = dic
                for key in renewedTimeSlot.keys{
                    renewedTimeSlot.updateValue(true, forKey: key)
                }

                timeReference.document("LjUpSZCIviFeSq3fPCzc").setData(dic)
                timeReference.document("SIg6q6u9flbtkVWTiPYn").setData(renewedTimeSlot)
            }
        }
    }

    private func getCurrentTime() -> String{
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let str = formatter.string(from: Date())
        return str
    }

    private func transitionToFirstPage() {
        let firstPageViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.FirstPageController) as? ViewController
        view.window?.rootViewController = firstPageViewController
        view.window?.makeKeyAndVisible()
    }

    private func setElements(){
        Utilities.differentStyleFilledButton(reserveTimeSlotButton)
        Utilities.styleHollowButton(cancelTimeSlotButton)
        Utilities.styleFilledButton(signOutButton)
        Utilities.styleFilledButton(checkInButton)
        Utilities.styleFilledButton(scanQRCodeButton)
    }

    private func confirmCheckIn() {
        let alertController = UIAlertController(title: "Confirm check in", message: "Check in?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            let db = Firestore.firestore()
            let timeStamp = [ "timeStamp:": Timestamp(date: Date())]
            db.collection("checkin").addDocument(data: timeStamp) { err in
                if let err = err {
                    print("error writing document: \(err)")
                } else {
                    print("Document successfully written")
                }

            }

        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) {
            UIAlertAction in print("cancelled")
        }

        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }


}

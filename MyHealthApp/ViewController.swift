//
//  ViewController.swift
//  MyHealthApp
//
//  Created by Sarawanak on 9/25/18.
//  Copyright © 2018 ThoughtWorks. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Health Data"
        HealthKitInterface.shared.requestReadAuthorization(for: HealthCharacteristic.allReadableTypes) { errMsg in
            if errMsg != nil {
                print("An Error Has Occured")
            } else {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return 2
        } else {
            return 3
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "My Personal Info"
        } else if section == 1 {
            return "Health Record"
        } else {
            return "Fitness Record"
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tableCell = tableView.dequeueReusableCell(withIdentifier: "infoCell") as? InfoTableViewCell else { return UITableViewCell() }

        if indexPath.section == 0 {
            let rowData = fetchData(for: indexPath.row)

            tableCell.titleLabel.text = rowData.title
            tableCell.valueLabel.text = rowData.value
        } else if indexPath.section == 1 {
            tableCell.titleLabel.text = getTitleForSamples(row: indexPath.row)
            tableCell.titleLabel.textColor = UIColor.darkGray
            tableCell.accessoryType = .disclosureIndicator
        } else {
            tableCell.titleLabel.text = getTitleForFitness(row: indexPath.row)
            tableCell.titleLabel.textColor = UIColor.darkGray
            tableCell.accessoryType = .disclosureIndicator
        }

        return tableCell
    }

    func getTitleForSamples(row: Int) -> String {
        switch row {
        case 0:
            return "Heart Rate"
        case 1:
            return "Blood Pressure"
        case 2:
            return "Blood Glucose"
        default:
            break
        }
        return ""
    }

    func getTitleForFitness(row: Int) -> String {
        switch row {
        case 0:
            return "Cycling Distance"
        case 1:
            return "Steps Count"
        default:
            break
        }
        return ""
    }

    func fetchData(for row: Int) -> (title: String, value: String) {
        switch row {
        case 0:
            let gender = HealthKitInterface.shared.readGenderType()
            return ("Gender", gender)
        case 1:
            let dob = HealthKitInterface.shared.readDob()
            return ("Date Of Birth", dob)
        case 2:
            let bloodGroup = HealthKitInterface.shared.readBloodType()
            return ("Blood group", bloodGroup)
        default:
            break
        }
        return ("", "")
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SampleList") as? SampleListTableViewController {
            switch (indexPath.section, indexPath.row) {
            case (1, 0):
                vc.title = "Heart Rate"
                vc.type = HealthCharacteristic.heartRate.type as? Set<HKQuantityType>
            case (1, 2):
                vc.title = "Blood Glucose"
                vc.type = HealthCharacteristic.bloodGlucose.type as? Set<HKQuantityType>
            case (2, 0):
                vc.title = "Cycling"
                vc.type = HealthCharacteristic.cycling.type as? Set<HKQuantityType>
            case (2, 1):
                vc.title = "Steps"
                vc.type = HealthCharacteristic.steps.type as? Set<HKQuantityType>
            default:
                return
            }

            navigationController?.pushViewController(vc, animated: true)
        }
    }

    @IBAction func createHealthData(_ sender: Any) {
        let types: Set<HKSampleType> = [HKQuantityType.quantityType(forIdentifier: .heartRate)!,
                                        HKQuantityType.quantityType(forIdentifier: .bloodGlucose)!]
        HealthKitInterface.shared.requestWriteAuth(for: types) { (error) in
            if let e = error {
                print("Error Occurred \(e)")
            } else {
                self.writeData()
            }
        }
    }


    func writeData() {
        let count = 5
        let cal = Calendar.current

        for i in 0..<count {
            
        }
    }
}


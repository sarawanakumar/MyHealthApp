//
//  SampleListTableViewController.swift
//  MyHealthApp
//
//  Created by Sarawanak on 9/26/18.
//  Copyright © 2018 ThoughtWorks. All rights reserved.
//

import UIKit
import HealthKit

class SampleListTableViewController: UITableViewController {
    var data: [HKQuantitySample]? {
        didSet {
            DispatchQueue.main.async {
                if let d = self.data, d.count > 0 {
                    self.tableView.backgroundView?.isHidden =  true
                } else {
                    self.tableView.backgroundView?.isHidden = false
                }
            }
        }
    }

    var type: Set<HKQuantityType>?

    @IBOutlet weak var noItemsView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = noItemsView
        clearsSelectionOnViewWillAppear = true

        HealthKitInterface.shared.requestReadAuthorization(for: type!) { (error) in
            if let e = error {
                print("Error occured: \(e)")
            } else {
                self.readData()
            }
        }
    }

    func readData() {
        HealthKitInterface.shared.readSamples(of: type!.first!) { (samplesList, error) in
            if let d = samplesList {
                self.data = d
            } else {
                self.data = []
            }

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sampleCell", for: indexPath)


        let qSample = data![indexPath.row]
        cell.textLabel?.text = DateFormatter.babylonFormat.string(from: qSample.startDate)
        cell.detailTextLabel?.text = "\(qSample.quantity)"
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DateFormatter {
    static var babylonFormat: DateFormatter {
        let d = DateFormatter()
        d.dateFormat = "dd-MMM-yyyy"
        return d
    }
}

//
//  HistoryTableViewController.swift
//  healthpointsclub
//
//  Created by Joseph Smith on 10/7/17.
//  Copyright © 2017 Joseph Smith. All rights reserved.
//

import UIKit

class HistoryTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func refreshHistory(_ sender: Any) {
        let alert = UIAlertController(title: "Update", message: "Your History is being updated. Please Wait.", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
                
            }})
        action.isEnabled = false
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        
        let original = HealthDay.shared.history.reduce(0) {$0 + $1.points}
        let originalHighScore = HealthDay.shared.history.map{ $0.points }.max()!
        var newTotal = 0
        var newHighScore = 0
        var count = 0
        let hkHelper = HealthKitHelper()
        
        let group = DispatchGroup()
        
        for day in HealthDay.shared.history {
            group.enter()
            if let index = HealthDay.shared.history.index(of: day){
                hkHelper.loadHistoricDay(date: day.date) { (day) in
                    _ = day.getPoints()
                    count += 1
                    DispatchQueue.main.async {
                        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.automatic)
                    }
                    group.leave()
                }
            }
            
        }
        group.notify(queue: .main) {
            newTotal = HealthDay.shared.history.reduce(0) {$0 + $1.points}
            let points = HealthDay.shared.history.map{ $0.points }
            if let newscore = points.max() {
                newHighScore = newscore
            } else {
                newHighScore = 0
            }
            
            alert.message = "Total Points: \(original) -> \(newTotal) \nAll Time High: \(originalHighScore) -> \(newHighScore)"
            action.isEnabled = true
        }
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return HealthDay.shared.history.count
    }
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let refreshAction = UIContextualAction(style: .normal, title: "Refresh") { (contextaction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            print("update history day at \(indexPath.row)")
            let date = HealthDay.shared.history[indexPath.row].date
            let hkHelper = HealthKitHelper()
            
            hkHelper.loadHistoricDay(date: date) { (day) -> Void in
                let points = day.getPoints()
                DispatchQueue.main.async {
                    tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                }
                
            }
            completionHandler(true)
            
        }
        refreshAction.backgroundColor = UIColor.gray
        
        return UISwipeActionsConfiguration(actions: [refreshAction])
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryTableViewCell
        
        // Configure the cell...
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        
        cell.dateLabel?.text = formatter.string(from: HealthDay.shared.history[indexPath.row].date)
        cell.pointsLabel?.text = HealthDay.shared.history[indexPath.row].points.description
        
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

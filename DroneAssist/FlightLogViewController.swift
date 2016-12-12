//
//  FlightLogViewController.swift
//  DroneFlight
//
//  Created by Benjamin Durao on 10/25/16.
//  Copyright © 2016 CCSU. All rights reserved.
//

import UIKit

class FlightLogTableViewController: UITableViewController {
    
    // MARK: Properties
    
    var flights = [Flight]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the edit button item provided bu the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        
        // Load any saved meals, otherwise load sample data.
        if let savedFlights = loadFlights() {
            flights += savedFlights
        }
        else {
            // Load the sample data.
            loadSampleFlights()
        }
    }
    
    func loadSampleFlights() {
        let photo1 = UIImage(named: "drone2")!
        let flight1 = Flight(name: "Test Flight", photo: photo1, notes: "Yo testing our DroneFlight. This is my first!", time: "15:30", longitude: "100.0", latitude: "100.2", wind: "10.4", weather: "sunny")!
        
        flights += [flight1]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flights.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "FlightTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FlightTableViewCell
        
        // Configure the cell
        let flight = flights[(indexPath as NSIndexPath).row]
        
        cell.nameLabel.text = flight.name
        cell.photoImageView.image = flight.photo
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            flights.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let flightViewController = segue.destination as! FlightViewController
            
            // Get the cell that generated this sgue.
            if let selectedFlightCell = sender as? FlightTableViewCell {
                let indexPath = tableView.indexPath(for: selectedFlightCell)!
                let selectedFlight = flights[indexPath.row]
                flightViewController.flight = selectedFlight
            }
        }
    }
    
    @IBAction func unwindToFlightList(_ sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? FlightViewController, let flight = sourceViewController.flight {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing flight.
                flights[(selectedIndexPath as NSIndexPath).row] = flight
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add a new flight.
                let newIndexPath = IndexPath(row: flights.count, section: 0)
                flights.append(flight)
                tableView.insertRows(at: [newIndexPath], with: .bottom)
            }
            
            // Save the meals.
            saveFlights()
            
        }
        
    }
    
    // MARK: NSCoding
    func saveFlights() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(flights, toFile: Flight.ArchiveURL.path)
        
        if !isSuccessfulSave {
            print("Failed to save flights...")
        }
    }
    
    func loadFlights() -> [Flight]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Flight.ArchiveURL.path) as? [Flight]
    }
    
}

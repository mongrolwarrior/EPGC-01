//
//  PatientDetailsViewController.swift
//  EPGC 01
//
//  Created by Andrew Amos on 9/11/2014.
//  Copyright (c) 2014 Andrew Amos. All rights reserved.
//

import UIKit
import CoreData

class PatientDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    var managedObjectContext: NSManagedObjectContext? = nil
    var selectedPatient: String? = nil
    
    convenience init(patientName: String) {
        self.init()
        self.selectedPatient = patientName
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let v = self.view
        
        let w = UIView(frame: CGRectMake(0, 0, v.bounds.width, v.bounds.height/2.0))
        
        let label = UILabel()
        w.addSubview(label)
        if self.selectedPatient != nil {
            label.text = selectedPatient
        } else {
            label.text = "No Patient Selected!"
        }
        label.autoresizingMask = .FlexibleTopMargin | .FlexibleLeftMargin | .FlexibleBottomMargin | .FlexibleRightMargin
        label.sizeToFit()
        label.center = CGPointMake(w.bounds.midX, w.bounds.midX)
        label.frame.integerize()
        
        v.addSubview(w)
     
        let x = UITableView(frame: CGRectMake(0, v.bounds.height/2.0, v.bounds.width, v.bounds.height/2.0))
        x.delegate = self
        x.dataSource = self
        
        v.addSubview(x)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("PatientDetailCell") as? UITableViewCell
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "PatientDetailCell")
        }
        self.configureCell(cell!, atIndexPath: indexPath)
        return cell!
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject
        cell.textLabel.text = String(object.valueForKey("outcomeType")!.description)
        let score = UInt(object.valueForKey("outcomeScore")! as NSNumber)
        cell.detailTextLabel?.text = score.description
    }
    
    /*
    let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject
    cell.textLabel.text = String(object.valueForKey("firstName")!.description) + " " + String(object.valueForKey("lastName")!.description)
    cell.detailTextLabel?.text = String(object.valueForKey("caseManager")!.description)

*/
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("PatientOutcomes", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Set NSPredicate for request, based on case manager name
        if selectedPatient != nil {
            fetchRequest.predicate = NSPredicate(format: "patientName = '\(self.selectedPatient!)'")
        }
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "patientName", ascending: true)
        let sortDescriptors = [sortDescriptor]
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        var error: NSError? = nil
        if !_fetchedResultsController!.performFetch(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil
}

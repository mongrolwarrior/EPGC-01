//
//  PatientDetailsViewController.swift
//  EPGC 01
//
//  Created by Andrew Amos on 9/11/2014.
//  Copyright (c) 2014 Andrew Amos. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class PatientDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, JBBarChartViewDataSource, JBBarChartViewDelegate {
    var managedObjectContext: NSManagedObjectContext? = nil
    var selectedPatient: String? = nil
    let _barChartView = JBBarChartView()
    
    let _headerHeight:CGFloat = 80;
    let _footerHeight:CGFloat = 25;
    let _padding:CGFloat = 10;
    
    let _headerView = HeaderView()
    let _footerView = FooterView()
    
    convenience init(patientName: String) {
        self.init()
        self.selectedPatient = patientName
    }
    
    func barChartView(barChartView: JBBarChartView!, colorForBarViewAtIndex index: UInt) -> UIColor! {
        return UIColor.redColor()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.view.backgroundColor = UIColor.whiteColor()
        
        let v = self.view
        
        // Table View
        let x = UITableView()//frame: CGRectMake(0, v.bounds.height/2.0, v.bounds.width, v.bounds.height/2.0))
        x.delegate = self
        x.dataSource = self
        x.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        v.addSubview(x)
        
        // JBChartView
        _barChartView.setTranslatesAutoresizingMaskIntoConstraints(false)
        v.addSubview(_barChartView)
        
        _barChartView.dataSource = self
        _barChartView.delegate = self
        
        self.navigationItem.title = selectedPatient
        
        _barChartView.backgroundColor = uicolorFromHex(0x3c3c3c)
        _barChartView.minimumValue = 0
        
        _barChartView.reloadData()
        
        let viewsDictionary = ["view1":_barChartView, "tlg": self.topLayoutGuide, "tableView": x]
        
        let view_constraint_H:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("H:|[view1]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
        let view_constraint_H2: NSArray = NSLayoutConstraint.constraintsWithVisualFormat("H:|[tableView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
        let view_constraint_V:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("V:[tlg][view1(==tableView)][tableView]|", options: NSLayoutFormatOptions.AlignAllLeading, metrics: nil, views: viewsDictionary)
        
        v.addConstraints(view_constraint_H)
        v.addConstraints(view_constraint_H2)
        v.addConstraints(view_constraint_V)
        
        v.setNeedsLayout()
        v.layoutIfNeeded()

        
        // Header
        _headerView.titleLabel.text = "HoNOS Data"
        _headerView.subtitleLabel.text = selectedPatient
        _headerView.backgroundColor = uicolorFromHex(0x3c3c3c)
        _barChartView.headerView = _headerView
        
        // Footer
        _footerView.padding = _padding
        _footerView.backgroundColor = uicolorFromHex(0x3c3c3c)
        _footerView.leftLabel.text = "1"
        _footerView.leftLabel.textColor = UIColor.whiteColor()
        _footerView.rightLabel.text = "3"
        _footerView.rightLabel.textColor = UIColor.whiteColor()
        _barChartView.footerView = _footerView
    }
    
    func numberOfBarsInBarChartView(barChartView: JBBarChartView) -> UInt {
        return 3
    }
    // - (CGFloat)barChartView:(JBBarChartView *)barChartView heightForBarViewAtIndex:(NSUInteger)index;
    
    func barChartView(barChartView: JBBarChartView!, heightForBarViewAtIndex index: UInt) -> CGFloat {
        switch index {
        case 0:
            return 5.0
        case 1:
            return 10.0
        default:
            return 15.0
        }
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
    
    func uicolorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
}

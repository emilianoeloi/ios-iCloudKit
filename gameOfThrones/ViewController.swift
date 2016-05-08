//
//  ViewController.swift
//  gameOfThrones
//
//  Created by Emiliano on 5/7/16.
//  Copyright © 2016 Emiliano Barbosa. All rights reserved.
//

import UIKit
import CloudKit

class ViewController: UIViewController,
                      UITableViewDelegate,
                      UITableViewDataSource {
    
    
    @IBOutlet weak var waitView: UIView!
    @IBOutlet weak var tblActors: UITableView!
    var arrActors: Array<CKRecord> = []
    
    var editedActorRecord: CKRecord!
    var selectedActorIndex: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        tblActors.delegate = self
        tblActors.dataSource = self
        fetchActors()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchActors() {
        let container = CKContainer.defaultContainer()
        let privateDatabase = container.privateCloudDatabase
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: "Actors", predicate: predicate)
        
        waitView.hidden = false
        view.bringSubviewToFront(waitView)
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        privateDatabase.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
            if error != nil {
                print(error?.localizedDescription)
            }
            else {
                for result in results! {
                    self.arrActors.append(result as CKRecord)
                }
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.tblActors.reloadData()
                    self.waitView.hidden = true
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                })
            }
        }
    }
    
    // MARK: - TableView Delegates/DataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrActors.count
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("idCellActor", forIndexPath: indexPath) as UITableViewCell
        let actorRecord: CKRecord = arrActors[indexPath.row]
        let dateFormatter = NSDateFormatter()
        
        let imageAsset: CKAsset = actorRecord.valueForKey("actorPhoto") as! CKAsset
        cell.imageView?.image = UIImage(contentsOfFile: imageAsset.fileURL.path!)
        cell.imageView?.contentMode = UIViewContentMode.ScaleAspectFit

        
        dateFormatter.dateFormat = "MMMM dd, yyyy, hh:mm"
//        cell.detailTextLabel?.text = dateFormatter.stringFromDate(actorRecord.valueForKey("actorEditedDate") as! NSDate)
        cell.textLabel?.text = actorRecord.valueForKey("actorName") as? String
        cell.detailTextLabel?.text = actorRecord.valueForKey("actorCharacter") as? String
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let selectedRecordID = arrActors[indexPath.row].recordID
            
            let container = CKContainer.defaultContainer()
            let privateDatabase = container.privateCloudDatabase
            
            privateDatabase.deleteRecordWithID(selectedRecordID, completionHandler: { (recordID, error) -> Void in
                if error != nil {
                    print(error?.localizedDescription)
                }
                else {
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        self.arrActors.removeAtIndex(indexPath.row)
                        self.tblActors.reloadData()
                    })
                }
            })
        }
    }


}


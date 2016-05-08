//
//  AddViewController.swift
//  gameOfThrones
//
//  Created by Emiliano on 5/7/16.
//  Copyright © 2016 Emiliano Barbosa. All rights reserved.
//

import UIKit
import CloudKit

class AddViewController: UIViewController,
                         UIImagePickerControllerDelegate,
                         UINavigationControllerDelegate {
    
    @IBOutlet weak var actorName: UITextField!
    @IBOutlet weak var actorCharacter: UITextField!
    @IBOutlet weak var actorPhoto: UIImageView!
    
    @IBOutlet weak var selectPhotoButton: UIButton!
    @IBOutlet weak var removePhotoButton: UIButton!
    @IBOutlet weak var waitVew: UIView!
    
    var photoURL: NSURL!
    let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
    let tempImageName = "temp_image.jpg"

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func pickPhoto(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            let imagePicker  :UIImagePickerController = UIImagePickerController()
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker.allowsEditing = false
            presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func saveActorPhotoLocally() {
        let imageData: NSData = UIImageJPEGRepresentation(actorPhoto.image!, 0.8)!
        let path = documentsDirectoryPath.stringByAppendingPathComponent(tempImageName)
        photoURL = NSURL(fileURLWithPath: path)
        imageData.writeToURL(photoURL, atomically: true)
    }
    
    
    @IBAction func saveActor(sender: AnyObject) {
        if actorName.text == "" || actorCharacter.text == "" {
            return
        }
        let timestampAsString = String(format: "%f", NSDate.timeIntervalSinceReferenceDate())
        let timestampParts = timestampAsString.componentsSeparatedByString(".")
        
        let actorID :CKRecordID = CKRecordID(recordName: timestampParts[0])
        
        let actorRecord :CKRecord = CKRecord(recordType: "Actors", recordID: actorID)
        
        actorRecord.setObject(actorName.text, forKey: "actorName")
        actorRecord.setObject(actorCharacter.text, forKey: "actorCharacter")
        actorRecord.setObject(NSDate(), forKey: "actorEditedDate")
        
        if let url = photoURL {
            let photoAsset = CKAsset(fileURL: url)
            actorRecord.setObject(photoAsset, forKey: "actorPhoto")
        }
        else {
            let fileURL = NSBundle.mainBundle().URLForResource("no_image", withExtension: "png")
            let imageAsset = CKAsset(fileURL: fileURL!)
            actorRecord.setObject(imageAsset, forKey: "acthorPhoto")
        }
        
        let container = CKContainer.defaultContainer()
        let privateDatabase = container.privateCloudDatabase
        
        waitVew.hidden = false
        view.bringSubviewToFront(waitVew)
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        privateDatabase.saveRecord(actorRecord, completionHandler: { (record, error) -> Void in
            if (error != nil) {
                print(error?.localizedDescription)
            }
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.waitVew.hidden = true
                self.navigationController?.setNavigationBarHidden(false, animated: true)
            })
        })
        
    }
    
    // MARK: - Image Picker Delegate
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil);
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        actorPhoto.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        actorPhoto.contentMode = UIViewContentMode.ScaleAspectFit
        
        saveActorPhotoLocally()
        
        actorPhoto.hidden = false
        selectPhotoButton.hidden = true
        removePhotoButton.hidden = false;
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    // MARK: - NAvigation Delegate
    @IBAction func dismiss(sender: AnyObject) {
        if let url = photoURL {
            let fileManager = NSFileManager()
            if fileManager.fileExistsAtPath(url.absoluteString) {
                do {
                    try fileManager.removeItemAtURL(url)
                } catch {
                    print("fail to removeItemAtURL")
                }
                
            }
        }
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func unsetImage(sender: AnyObject) {
        actorPhoto.image = nil
        
        actorPhoto.hidden = true
        removePhotoButton.hidden = true
        selectPhotoButton.hidden = false
        
        photoURL = nil
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  ConfirmProfileViewController.swift
//  Happimess
//
//  Created by Nikita Feshchun on 21.09.15.
//  Copyright © 2015 Nikita Feshchun. All rights reserved.
//


import UIKit
import JVFloatLabeledTextField
import Parse

class ConfirmProfileViewController : UIViewController,UIPickerViewDelegate,UIPickerViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate,SetupUniversityDelegate,UITextFieldDelegate {
    
    
    
    @IBOutlet weak var department: JVFloatLabeledTextField!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var placeholder: UIImageView!
    @IBOutlet weak var university: JVFloatLabeledTextField!
    @IBOutlet weak var dateselection: JVFloatLabeledTextField!
    let imagePicker = UIImagePickerController()
    var selectedField = "";
    var selectedDate = NSDate();
    let pickerView = UIPickerView()
    let datePicker = UIDatePicker()
    @IBOutlet weak var firstname: JVFloatLabeledTextField!
    @IBOutlet weak var secondname: JVFloatLabeledTextField!
    var deparments : [String] = ["Department 1","Department 2","Department 3","Department 4"];
    var universities : [String] = ["University 1","University 2","University 3","University 4"];
    override func viewDidLoad() {
        super.viewDidLoad()
        //        department.enabled = false
        department.inputView = pickerView
        university.inputView = pickerView
        dateselection.inputView = datePicker
        datePicker.datePickerMode = UIDatePickerMode.Date
        datePicker.backgroundColor = UIColor.whiteColor()
        datePicker.addTarget(self, action: Selector("datePickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        pickerView.dataSource = self;
        pickerView.delegate = self;
        
        let blur:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let effectView:UIVisualEffectView = UIVisualEffectView (effect: blur)
        effectView.frame = placeholder.frame
        placeholder.addSubview(effectView)
        avatar.layer.borderWidth = 2
        avatar.layer.masksToBounds = false
        avatar.layer.borderColor = UIColor.whiteColor().CGColor
        avatar.layer.cornerRadius = avatar.frame.height/2
        avatar.clipsToBounds = true
        imagePicker.delegate = self
        let profile = PFUser.currentUser()
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "dd MMMM yyyy"
        if (profile?.valueForKey("birthday") != nil) {
            let strDate = dateFormatter.stringFromDate((profile?.valueForKey("birthday") as? NSDate)!)
            dateselection.text = strDate
        }
        
        firstname.delegate = self
        secondname.delegate = self
        firstname.returnKeyType = UIReturnKeyType.Done
        secondname.returnKeyType = UIReturnKeyType.Done
        firstname.text = profile?.valueForKey("firstName") as? String
        secondname.text = profile?.valueForKey("lastName") as? String
        university.text = profile?.valueForKey("university") as? String
        department.text = profile?.valueForKey("department") as? String
        let imageFile = profile?.valueForKey("avatar") as? PFFile
        if imageFile != nil {
            imageFile?.getDataInBackgroundWithBlock({ (data : NSData?, error : NSError?) -> Void in
                let imageData = UIImage(data: data!)
                self.avatar.image = imageData
                self.placeholder.image = imageData
            })
        }
        let toolbar = UIToolbar.init(frame: CGRectMake(0, 0, 320, 44))
//        toolbar.barStyle   = UIBarStyle.
        let itemDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Done, target: dateselection, action: "resignFirstResponder")
        toolbar.items = [itemDone];
        dateselection.inputAccessoryView = toolbar;
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func initdeparment(sender: AnyObject) {
        resignFirstResponder()
        selectedField = "deparment"
        dateselection.resignFirstResponder()
        department.resignFirstResponder()
        performSegueWithIdentifier("UniversitySearch", sender: sender)
    }
    
    @IBAction func inituniversity(sender: AnyObject) {
        //        selectedField = "university"
        //        pickerView.reloadAllComponents()
        dateselection.resignFirstResponder()
        department.resignFirstResponder()
        performSegueWithIdentifier("UniversitySearch", sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "UniversitySearch" {
            if (selectedField == "deparment") {
                (segue.destinationViewController as! SearchUniversity).department = self
            } else {
                (segue.destinationViewController as! SearchUniversity).universityDelegate = self
                
            }
        }
    }
    
    @IBAction func inidate(sender: AnyObject) {
        selectedField = "date"
        pickerView.reloadAllComponents()
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch selectedField {
        case "university": university.text = self.universities[row]
        default:  department.text = self.deparments[row]
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch selectedField {
        case "university": return self.universities[row]
        default: return self.deparments[row]
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        return  1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch selectedField {
        case "university": return self.universities.count
        case "date": return self.universities.count
        default: return self.deparments.count
        }
    }
    
    func datePickerChanged(datePicker:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "dd MMMM yyyy"
        
        let strDate = dateFormatter.stringFromDate(datePicker.date)
        dateselection.text = strDate
        selectedDate = datePicker.date
    }
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
        
    }
    
    @IBAction func confirm(sender: AnyObject) {
        saveProfile()
    }
    
    @IBAction internal func changeAvatar(sender: AnyObject) {
        
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .ActionSheet)
        
        // 2
        let addFeed = UIAlertAction(title: "Take photo", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            
            self.presentViewController(self.imagePicker, animated: true) { () -> Void in
                
            }
        })
        let addFile = UIAlertAction(title: "From library", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            self.presentViewController(self.imagePicker, animated: true) { () -> Void in
                
            }
        })
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
        
        
        // 4
        optionMenu.addAction(addFeed)
        optionMenu.addAction(addFile)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        avatar.image = image
        placeholder.image = image
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveProfile() {
        
        let profile = PFUser.currentUser()
        if firstname.text! == "" || secondname.text! == "" || university.text! == "" || department.text! == "" {
            let alert = UIAlertView()
            alert.message = "Please complete all required fields"
            alert.addButtonWithTitle("OK")
            alert.show()
        } else {
            profile!.setObject(firstname.text!, forKey: "firstName")
            profile!.setObject(secondname.text!, forKey: "secondName")
            profile!.setObject(selectedDate, forKey: "birthday")
            profile!.setObject(university.text!, forKey: "university")
            profile!.setObject(department.text!, forKey: "department")
            profile!.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
                if (success) {
                    self.dismissViewControllerAnimated(true) { () -> Void in
                        
                    }
                } else {
                    let alert = UIAlertView()
                    alert.message = "Error updating profile"
                    alert.addButtonWithTitle("OK")
                    alert.show()
                }
            }
        }
        
    }
    
    func setupUniversity(value: String){
        if (selectedField == "deparment") {
            department.text = value
        } else {
            university.text = value
        }
    }
    
}


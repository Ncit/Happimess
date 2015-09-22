//
//  ConfirmProfileViewController.swift
//  Happimess
//
//  Created by Nikita Feshchun on 21.09.15.
//  Copyright © 2015 Nikita Feshchun. All rights reserved.
//


import UIKit
import JVFloatLabeledTextField

class ConfirmProfileViewController : UIViewController,UIPickerViewDelegate,UIPickerViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var department: JVFloatLabeledTextField!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var placeholder: UIImageView!
    @IBOutlet weak var university: JVFloatLabeledTextField!
    @IBOutlet weak var dateselection: JVFloatLabeledTextField!
     let imagePicker = UIImagePickerController()
    var selectedField = "";
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
    }
    
    @IBAction func initdeparment(sender: AnyObject) {
        resignFirstResponder()
        selectedField = "deparment"
        pickerView.reloadAllComponents()
    }
    
    @IBAction func inituniversity(sender: AnyObject) {
//        selectedField = "university"
//        pickerView.reloadAllComponents()
        dateselection.resignFirstResponder()
         department.resignFirstResponder()
        performSegueWithIdentifier("UniversitySearch", sender: sender)
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
    }
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }

    }
    
    @IBAction func confirm(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
    @IBAction internal func changeAvatar(sender: AnyObject) {
        imagePicker.allowsEditing = false
//        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true) { () -> Void in
            
        }
    
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        avatar.image = image
        placeholder.image = image
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
}


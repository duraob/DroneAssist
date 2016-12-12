//
//  SocialMediaViewController.swift
//  DroneFlight
//
//  Created by Benjamin Durao on 10/10/16.
//  Copyright © 2016 CCSU. All rights reserved.
//

import UIKit
import Social

class FlightViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    // MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var timerLabel: UITextField!
    @IBOutlet weak var weatherTextField: UITextField!
    @IBOutlet weak var windTextField: UITextField!
    var time: String = ""
    var lat:String = ""
    var lng:String = ""
    /*
     This value is either passed bu `MealTableViewController` in `prepareForSegue(_:sender:)` or
     constructed as part of adding a new meal
     */
    var flight: Flight?
    
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Handle the text field's user input through delegation callbacks.
        nameTextField.delegate = self
        
        
        // Set up view if editing an exisitng Meal.
        if let flight = flight {
            navigationItem.title = flight.name
            nameTextField.text = flight.name
            photoImageView.image = flight.photo
            notesTextView.text = flight.notes
            latitudeLabel.text = flight.latitude
            longitudeLabel.text = flight.longitude
            timerLabel.text = flight.time
            windTextField.text = flight.wind
            weatherTextField.text = flight.weather
            
        }
        else
        {
            timerLabel.text = time
            latitudeLabel.text = lat
            longitudeLabel.text = lng
        }
        
        
        
        //Enable the Save button only if the text field has a valid Meal name.
        checkValidFlightName()
    }
    
    // MARK: Methods
    
    func checkValidFlightName() {
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkValidFlightName()
        navigationItem.title = textField.text
    }
    
    // MARK: UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        saveButton.isEnabled = false
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentCharacterCount = textView.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + text.characters.count - range.length
        return newLength <= 160
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        
        // Dismiss the picker
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddFlightMode = presentingViewController is UINavigationController
        if isPresentingInAddFlightMode {
            dismiss(animated: true, completion: nil)
        }
        else {
            dismiss(animated: true, completion: nil)
            navigationController!.popViewController(animated: true)
            
        }
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if saveButton === sender as! UIBarButtonItem {
            let name = nameTextField.text ?? ""
            let photo = photoImageView.image
            let notes = notesTextView.text ?? ""
            let time = timerLabel.text ?? ""
            let latitude = latitudeLabel.text ?? ""
            let longitude = longitudeLabel.text ?? ""
            let wind = windTextField.text ?? ""
            let weather = weatherTextField.text ?? ""
            
            // Set the meal to be passed to MealTableViewController after the unwind segue.
            flight = Flight(name: name, photo: photo, notes: notes, time: time, longitude: longitude, latitude: latitude, wind: wind, weather: weather)
            
        }
    }
    
    // MARK: Photo Actions
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        // Hide the keyboard
        nameTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: Social Media Controls
    // MARK: FACEBOOK
    @IBAction func facebookBtn(_ sender: AnyObject) {
        // Is FaceBook installed and logged in?
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
            let fbShare:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            fbShare.setInitialText(notesTextView.text)
            fbShare.add(photoImageView.image)
            self.present(fbShare, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    // MARK: TWITTER
    @IBAction func tweetBtn(_ sender: AnyObject) {
        // Is Twitter installed and logged in?
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            let twShare:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            twShare.setInitialText(notesTextView.text)
            twShare.add(photoImageView.image)
            
            self.present(twShare, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    // MARK: ACTIVITY VIEW CONTROLLER
    @IBAction func shareButtonClicked(sender: AnyObject) {
        let textToShare = "Today I flew with the help of DroneFlight!"
        let objectsToshare = [textToShare]
        
        let shareBtn = UIActivityViewController(activityItems: objectsToshare, applicationActivities: nil)
        
        shareBtn.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList, UIActivityType.assignToContact, UIActivityType.openInIBooks]
        shareBtn.popoverPresentationController?.sourceView = sender as? UIView
        self.present(shareBtn, animated: true, completion: nil)
    }
    
}




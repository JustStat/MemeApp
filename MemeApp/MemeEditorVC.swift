//
//  MemeEditorVC.swift
//  MemeApp
//
//  Created by Kirill Varlamov on 23.01.17.
//  Copyright © 2017 Kirill Varlamov. All rights reserved.
//

import UIKit

struct Constants {
    static let defaultTextSize : CGFloat = 40
    static let defaultStrokeWidth : CGFloat = -3
}

class MemeEditorVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFieldStyle(textField: topTextField, text: "Top text")
        setTextFieldStyle(textField: bottomTextField, text: "Bottom text")
    }
    
    func setTextFieldStyle(textField: UITextField, text: String) {
        textField.isHidden = true
        
        let memeTextAttributes:[String:Any] = [
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            NSStrokeWidthAttributeName: Constants.defaultStrokeWidth,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: Constants.defaultTextSize)!]
        textField.defaultTextAttributes = memeTextAttributes
        textField.attributedPlaceholder = NSAttributedString.init(string: text, attributes: memeTextAttributes)
        textField.textAlignment = .center
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    @IBAction func pickAnImage(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType(rawValue: (sender as! UIBarButtonItem).tag)!
        present(pickerController, animated: true, completion: nil)
        
    }
    
    func generateMeme() -> UIImage {
        UIGraphicsBeginImageContext(self.mainImageView.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return memedImage

    }
    
    @IBAction func shareImage(_ sender: Any) {
        let activityController = UIActivityViewController(activityItems: [generateMeme()], applicationActivities: nil)
        activityController.completionWithItemsHandler = completionHandler
        present(activityController, animated: true, completion: nil)
    }
    
    func completionHandler(activityType: UIActivityType?, shared: Bool, items: [Any]?, error: Error?) {
        if (shared) {
             let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: mainImageView.image!, memedImage: generateMeme())
            print(meme)
        }
    }
    
    //MARK: imagePickerDelegateMethods
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print(info.keys)
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            mainImageView.image = image
            topTextField.isHidden = false
            bottomTextField.isHidden = false
            shareButton.isEnabled = true
            topTextField.text = ""
            bottomTextField.text = ""
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK: TextFieldDelegateMethods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    //MARK: Work with Keyboard
    
    func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = 0 - getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default .addObserver(self, selector:  #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }

}


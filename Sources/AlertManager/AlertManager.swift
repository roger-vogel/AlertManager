
// UIAlertController Wrapper
// Created by Roger Vogel

import Foundation
import UIKit

public class AlertManager: NSObject {
    
    // MARK: - PROPERTIES
    public var thisAlert: UIAlertController?
    public var alertTextFieldParams: (placeholder: String, defaultText: String)?
    public var textAlertButtonsToDisable: [Int]?
    
    private var activeController: UIViewController?
    private var delegate: Any?
    private var indicator: UIActivityIndicatorView?
   
    // MARK: - INITIALIZATION
    public init(controller: UIViewController) {
        
        super.init()
        activeController = controller
    }
    
    // MARK: - PRIMARY FUNCTIONS
    // Basic popup (alert or action sheet) with one button
    public func popupWithCustomButton (aTitle: String? = nil, aMessage: String? = nil, buttonTitle: String, theStyle: UIAlertAction.Style, theType: UIAlertController.Style? = .actionSheet) {
        
        // Dismiss any previous alert
        if thisAlert != nil { dismiss() }
        
        // Create alert controller and add action button
        thisAlert = UIAlertController(title: aTitle, message: aMessage, preferredStyle: theType!)
        thisAlert!.addAction(UIAlertAction(title: buttonTitle, style: theStyle, handler: { action in return } ) )
        
        // Required if running on iPad and using action sheet
        if delegate != nil { thisAlert!.popoverPresentationController?.delegate = (delegate as! UIPopoverPresentationControllerDelegate) }
        
        // Delay slightly to let dismiss complete and then present
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            
            self.activeController!.present(self.thisAlert!, animated: true, completion: nil)
        })
    }
    
    // Popup with one button with callback upon completion
    public func popupWithCustomButton (aTitle: String? = "", aMessage: String? = "", buttonTitle: String, theStyle: UIAlertAction.Style, theType: UIAlertController.Style? = .actionSheet, callBack: @escaping () -> Void ) {
        
        // Dismiss any previous alert
        if thisAlert != nil { dismiss() }
        
        // Create alert controller and add action button
        thisAlert = UIAlertController(title: aTitle, message: aMessage, preferredStyle: theType!)
        thisAlert!.addAction(UIAlertAction(title: buttonTitle, style: theStyle, handler: { action in DispatchQueue.main.async(execute: { () -> Void in callBack() } ) } ) )
        
        // Required if running on iPad and using action sheet
        if delegate != nil { thisAlert!.popoverPresentationController?.delegate = (delegate as! UIPopoverPresentationControllerDelegate) }
        
        // Delay slightly to let dismiss complete and then present
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            
            self.activeController!.present(self.thisAlert!, animated: true, completion: nil)
        })
    }
    
    // Popup with multiple buttons
    public func popupWithCustomButtons (aTitle: String? = "", aMessage: String? = "", buttonTitles: [String], theStyle: [UIAlertAction.Style], theType: UIAlertController.Style? = .actionSheet, callBack: @escaping (Int) -> Void) {
        
        // Dismiss any previous alert
        if thisAlert != nil { dismiss() }
        
        // Create alert
        thisAlert = UIAlertController(title: aTitle, message: aMessage, preferredStyle: theType!)
        
        // Required if running on iPad and using action sheet
        if delegate != nil { thisAlert!.popoverPresentationController!.delegate = (delegate as! UIPopoverPresentationControllerDelegate) }
        
        // Create multiple buttons which return the button index to caller for processing
        for (index,title) in buttonTitles.enumerated() {
            
            thisAlert!.addAction(UIAlertAction(title: title, style: theStyle[index], handler: { action in DispatchQueue.main.async(execute: { () -> Void in callBack(index) } ) } ) )
        }
        
        // Delay slightly to let dismiss complete and then present
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            
            self.activeController!.present(self.thisAlert!, animated: true, completion: nil)
        })
    }
    
    // Popup an alert with a textfield and buttons
    public func popupWithTextField (
        
        aTitle: String? = "",
        aMessage: String,
        aPlaceholder: String? = "",
        aDefault: String? = "",
        buttonTitles: [String],
        disabledButtons: [Int]? = nil,
        aStyle: [UIAlertAction.Style],
        keyboard: UIKeyboardType? = .default,
        fontSize: CGFloat? = 16,
        callBack: @escaping (Int,String) -> Void ) {
        
            // Dismiss any previous alert
            if thisAlert != nil { dismiss() }
            
            // Ability to disable buttons
            textAlertButtonsToDisable = disabledButtons
            
            // Create alert
            thisAlert = UIAlertController(title: aTitle!, message: aMessage, preferredStyle: .alert)

            // Set the text field placeholder and default text, if any
            alertTextFieldParams = (aPlaceholder!,aDefault!)
            
            // Add buttons
            for (index,title) in buttonTitles.enumerated() {
                
                self.thisAlert!.addAction(UIAlertAction(title: title, style: aStyle[index], handler: { action in DispatchQueue.main.async(execute: { () -> Void in callBack(index,self.thisAlert!.textFields!.first!.text!) } ) } ) )
             
                if disabledButtons != nil {
                    
                    if disabledButtons!.contains(index) { self.thisAlert!.actions[index].isEnabled = false }
                }
            }
            
            // Add text field
            self.thisAlert!.addTextField(configurationHandler: { (theTextField) in
                
                theTextField.placeholder = self.alertTextFieldParams!.placeholder
                theTextField.font = UIFont.systemFont(ofSize: fontSize!)
                theTextField.text = self.alertTextFieldParams!.defaultText
                theTextField.autocapitalizationType = .words
                theTextField.keyboardType = keyboard!
                theTextField.delegate = self
            })
            
            // Delay slightly to let dismiss complete and then present
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                
                self.activeController!.present(self.thisAlert!, animated: true, completion: nil)
            })
    }
    
    // MARK: - "PRE-PACKAGED" ALERTS
    // Popup a simple alert with an OK button
    public func popupOK (aTitle: String? = "", aMessage: String? = "") {
        
        popupWithCustomButton(aTitle: aTitle!, aMessage: aMessage!, buttonTitle: "OK", theStyle: .default, theType: .alert)
    }
 
    // Popup a alert with an OK button and callback
    public func popupOK (aTitle: String? = "",  aMessage: String? = "", callBack: @escaping () -> Void ) {
        
        popupWithCustomButton(aTitle: aTitle!, aMessage: aMessage!, buttonTitle: "OK", theStyle: .default, theType: .alert, callBack: callBack)
    }
   
    // Popup alert with cancel button
    public func popupCancel (aTitle: String? = "",  aMessage: String? = "", callBack: @escaping () -> Void ) {
        
        popupWithCustomButton(aTitle: aTitle!, aMessage: aMessage!, buttonTitle: "Cancel", theStyle: .default, callBack: callBack)
    }
    
    // Popup alert with OK/CANCEL buttons
    public func popupOKCancel (aTitle: String? = "",  aMessage: String? = "", callBack: @escaping (Int) -> Void ) {
        
        popupWithCustomButtons(aTitle: aTitle!, aMessage: aMessage!, buttonTitles: ["OK","Cancel"], theStyle: [.default,.destructive], callBack: callBack)
    }
    
    // Popup alert with YES/NO buttons
    public func popupYesNo (aTitle: String? = "", aMessage: String, aStyle: [UIAlertAction.Style]? = [.default,.destructive], callBack: @escaping (Int) -> Void ) {
        
        popupWithCustomButtons(aTitle: aTitle!, aMessage: aMessage, buttonTitles: ["Yes","No"], theStyle: aStyle!, callBack: callBack)
    }
    
    // MARK: - POPUP WITH ACTIVITY INDICATOR
    // Popup an alert with an animated activity indicator which can be dismissed by caller upon task completion
    public func popupPendingMsg (aTitle: String? = "",  aMessage: String, fontSize: CGFloat? = 13) {
        
        // Dismiss any previous alert
        if thisAlert != nil { dismiss() }
        
        // Create message and add a couple of returns for spacing above activity indicator
        let messageFont = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize!)]
        let messageAttrString = NSMutableAttributedString(string: aMessage + "\n\n", attributes: messageFont)
        
        // Create alert with attributed string
        thisAlert = UIAlertController(title: aTitle!, message: "", preferredStyle: .alert)
        thisAlert!.setValue(messageAttrString, forKey:"attributedMessage")
       
        // Create activity indicator and present alert
        self.setupPendingIndicator()
        self.activeController!.present(self.thisAlert!, animated: true, completion: nil)
    }
    
    // Popup an alert with an animated activity indicator and multiple buttons
    public func popupPendingMsg (aTitle: String? = "", aMessage: String, buttonTitles: [String], fontSize: CGFloat? = 13, callBack: @escaping (Int) -> Void) {
        
        // Dismiss any previous alert
        if thisAlert != nil { dismiss() }
        
        // Create message and add a couple of returns for spacing above activity indicator
        let messageFont = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize!)]
        let messageAttrString = NSMutableAttributedString(string: aMessage + "\n\n", attributes: messageFont)
        
        thisAlert = UIAlertController(title: aTitle!, message: "", preferredStyle: .alert)
        thisAlert!.setValue(messageAttrString, forKey:"attributedMessage")
       
        // Setup activity indicator
        self.setupPendingIndicator()
        
        // Create buttons
        for (index,title) in buttonTitles.enumerated() {
            
            self.thisAlert!.addAction(UIAlertAction(title: title, style: .default, handler: { action in DispatchQueue.main.async(execute: { () -> Void in callBack(index) } ) } ) )
        }
     
        // Present alert
        self.activeController!.present(self.thisAlert!, animated: true, completion: nil)
    }
    
    // Popup with a cancel button
    public func popupPendingCancel (aTitle: String? = "", aMessage: String, fontSize: CGFloat? = 13, callBack: @escaping (Int) -> Void) {
        
        popupPendingMsg(aTitle: aTitle!, aMessage: aMessage, buttonTitles: ["CANCEL"], fontSize: fontSize!, callBack: callBack)
    }
    
    // MARK: - POPUP MESSAGE (ACTION SHEET) FOR A TIME INTERVAL AND THEN DISMISS
    // Without callback
    public func popupMessage (aTitle: String? = "", aMessage: String, aViewDelay: TimeInterval? = 2.0) {
        
        if thisAlert != nil { dismiss() }
        thisAlert = UIAlertController(title: aTitle!, message: aMessage, preferredStyle: .actionSheet)
        
        if delegate != nil { thisAlert!.popoverPresentationController?.delegate = (delegate as! UIPopoverPresentationControllerDelegate) }
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            
            self.activeController!.present(self.thisAlert!, animated: true, completion: { self.dismissWithDelay(wait: aViewDelay!) })
        })
    }
    
    // With callback
    public func popupMessage (aTitle: String? = "", aMessage: String, aViewDelay: TimeInterval? = 2.0, callBack: @escaping () -> Void ) {
        
        if thisAlert != nil { dismiss() }
        
        thisAlert = UIAlertController(title: aTitle!, message: aMessage, preferredStyle: .actionSheet)
        if delegate != nil { thisAlert!.popoverPresentationController?.delegate = (delegate as! UIPopoverPresentationControllerDelegate) }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            
            self.activeController!.present(self.thisAlert!, animated: true, completion: { self.dismissWithDelay(wait: aViewDelay!, callBack: callBack) })
        })
    }
    
    // MARK: - DISMISS ALERT
    // Dismiss immediately
    public func dismiss() {
        
        if self.thisAlert != nil {
            
            self.thisAlert!.dismiss(animated: true, completion: nil)
            self.thisAlert = nil
        }
    }
    
    // With delay
    public func dismissWithDelay(wait: TimeInterval? = 2.0) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + wait!, execute: { self.dismiss() })
    }
  
    // With delay and callback
    public func dismissWithDelay(wait: TimeInterval? = 2.0, callBack: @escaping () -> Void ) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + wait!, execute: { callBack(); self.dismiss() })
    }
    
    // MARK: - POPOVER DELEGATE FOR IPAD
    // Allows caller to set the delegate for popover to allow setting of view and rect
    public func addDelegate(delegate: Any) { self.delegate = delegate }
 
    // MARK: - ACTIVItY INDICATOR
    // Create the activiy indicator for popup pending functions
    private func setupPendingIndicator(spacing: CGFloat? = 10) {
     
        indicator = UIActivityIndicatorView(frame: self.thisAlert!.view.bounds)
        indicator!.color = .black
        indicator!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        indicator!.frame.origin.y = (self.thisAlert!.view.bounds.height/2 - indicator!.frame.height/2) + spacing!
        
        // Add the activity indicator as a subview of the alert controller's view
        thisAlert!.view.addSubview(indicator!)
        indicator!.isUserInteractionEnabled = false
        indicator!.startAnimating()
        indicator!.isHidden = false
    }
  
}

// MARK: - TEXTFIELD DELEGATE FOR TEXTFIELD ALERT
extension AlertManager: UITextFieldDelegate {
    
    public func textFieldDidChangeSelection(_ textField: UITextField) {
        
        guard textAlertButtonsToDisable != nil else { return }
        guard !textAlertButtonsToDisable!.isEmpty else { return }
        guard textAlertButtonsToDisable != nil else { return }
        
        for (index,value) in thisAlert!.actions.enumerated() {
            
            if textAlertButtonsToDisable!.contains(index) {
                
                value.isEnabled = textField.text!.count == 0 ? false : true
            }
        }
    }
}

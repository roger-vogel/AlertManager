
import UIKit

public class AlertManager: NSObject {
    
    // MARK: - PROPERTIES
    private var activeController: UIViewController?
    private var indicator: UIActivityIndicatorView?
   
    public var thisAlert: UIAlertController?
    public var alertTextFieldParams: (placeholder: String, defaultText: String)?
    public var textAlertButtonsToDisable: [Int]?
    
    public init(controller: UIViewController) {
        
        super.init()
        activeController = controller
    }
    
    // MARK: - POPUP OK
    public func popupOK (aTitle: String? = "", aMessage: String? = "") { popupWithCustomButton(aTitle: aTitle!, aMessage: aMessage!, buttonTitle: "OK", theStyle: .default, theType: .alert) }
 
    public func popupOK (aTitle: String? = "",  aMessage: String? = "", callBack: @escaping () -> Void ) { popupWithCustomButton(aTitle: aTitle!, aMessage: aMessage!, buttonTitle: "OK", theStyle: .default, theType: .alert, callBack: callBack) }
   
    // MARK: - POPUP CANCEL
    public func popupCancel (aTitle: String? = "",  aMessage: String? = "", callBack: @escaping () -> Void ) { popupWithCustomButton(aTitle: aTitle!, aMessage: aMessage!, buttonTitle: "Cancel", theStyle: .default, callBack: callBack)}
    
    // MARK: - POPUP QUESTIONS
    public func popupOKCancel (aTitle: String? = "",  aMessage: String? = "", callBack: @escaping (Int) -> Void ) {
        
        popupWithCustomButtons(aTitle: aTitle!, aMessage: aMessage!, buttonTitles: ["OK","Cancel"], theStyle: [.default,.destructive], callBack: callBack)
    }
    
    public func popupYesNo (aTitle: String? = "", aMessage: String, aStyle: [UIAlertAction.Style]? = [.default,.destructive], callBack: @escaping (Int) -> Void ) {
        
        popupWithCustomButtons(aTitle: aTitle!, aMessage: aMessage, buttonTitles: ["Yes","No"], theStyle: aStyle!, callBack: callBack)
    }
    
    // MARK: - POPUP WITH ACTIVITY INDICATOR
    public func popupPendingMsg (aTitle: String? = "",  aMessage: String) {
        
        if thisAlert != nil { dismiss() }
        
        let messageFont = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)]
        let messageAttrString = NSMutableAttributedString(string: aMessage + "\n\n", attributes: messageFont)
        
        thisAlert = UIAlertController(title: aTitle!, message: "", preferredStyle: .alert)
        thisAlert!.setValue(messageAttrString, forKey:"attributedMessage")
       
        self.setupPendingIndicator()
      
        self.activeController!.present(self.thisAlert!, animated: true, completion: nil)
    }
    
    public func popupPendingMsg (aTitle: String? = "", aMessage: String, buttonTitles: [String], callBack: @escaping (Int) -> Void) {
        
        if thisAlert != nil { dismiss() }
        let messageFont = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)]
        let messageAttrString = NSMutableAttributedString(string: aMessage + "\n\n", attributes: messageFont)
        
        thisAlert = UIAlertController(title: aTitle!, message: "", preferredStyle: .alert)
        thisAlert!.setValue(messageAttrString, forKey:"attributedMessage")
       
        self.setupPendingIndicator()
        
        for (index,title) in buttonTitles.enumerated() {
            
            self.thisAlert!.addAction(UIAlertAction(title: title, style: .default, handler: { action in DispatchQueue.main.async(execute: { () -> Void in callBack(index) } ) } ) )
        }
     
        self.activeController!.present(self.thisAlert!, animated: true, completion: nil)
    }
    
    public func popupPendingCancel (aTitle: String? = "", aMessage: String, callBack: @escaping () -> Void) {
        
        if thisAlert != nil { dismiss() }
        
        let messageFont = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)]
        let messageAttrString = NSMutableAttributedString(string: aMessage + "\n\n", attributes: messageFont)
        
        thisAlert = UIAlertController(title: aTitle!, message: "", preferredStyle: .alert)
        thisAlert!.setValue(messageAttrString, forKey:"attributedMessage")
       
        self.setupPendingIndicator()
        self.thisAlert!.addAction(UIAlertAction(title: "CANCEL", style: .destructive, handler: { action in DispatchQueue.main.async(execute: { () -> Void in callBack() } ) } ) )
       
        self.activeController!.present(self.thisAlert!, animated: true, completion: nil)
    }
    
    // MARK: - POPUP WITH TEXTFIELD
    public func popupWithTextField (aTitle: String? = "", aMessage: String, aPlaceholder: String, aDefault: String, buttonTitles: [String], disabledButtons: [Int]? = nil, aStyle: [UIAlertAction.Style], keyboard: UIKeyboardType? = .default, callBack: @escaping (Int,String) -> Void ) {
        
        if thisAlert != nil { dismiss() }
        
        textAlertButtonsToDisable = disabledButtons
        
        thisAlert = UIAlertController(title: aTitle!, message: aMessage, preferredStyle: .alert)
        alertTextFieldParams = (aPlaceholder,aDefault)
        
        for (index,title) in buttonTitles.enumerated() {
            
            self.thisAlert!.addAction(UIAlertAction(title: title, style: aStyle[index], handler: { action in DispatchQueue.main.async(execute: { () -> Void in callBack(index,self.thisAlert!.textFields!.first!.text!) } ) } ) )
         
            if disabledButtons != nil {
                
                if disabledButtons!.contains(index) { self.thisAlert!.actions[index].isEnabled = false }
            }
        }
        
        self.thisAlert!.addTextField(configurationHandler: { (theTextField) in
            
            theTextField.placeholder = self.alertTextFieldParams!.placeholder
            theTextField.font = UIFont.systemFont(ofSize: 16)
            theTextField.text = self.alertTextFieldParams!.defaultText
            theTextField.autocapitalizationType = .words
            theTextField.keyboardType = keyboard!
            theTextField.delegate = self
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            
            self.activeController!.present(self.thisAlert!, animated: true, completion: nil)
        })
    }
    
    // MARK: - POPUP WITH CUSTOM BUTTON(S)
    public func popupWithCustomButton (aTitle: String? = "", aMessage: String? = "", buttonTitle: String, theStyle: UIAlertAction.Style, theType: UIAlertController.Style? = .actionSheet) {
        
        if thisAlert != nil { dismiss() }
        
        var theTitle: String?
        var theMessage: String?
        
        if aTitle!.isEmpty { theTitle = nil } else { theTitle = aTitle }
        if aMessage!.isEmpty { theMessage = nil } else { theMessage = aMessage! }
        
        thisAlert = UIAlertController(title: theTitle, message: theMessage, preferredStyle: theType!)
        thisAlert!.addAction(UIAlertAction(title: buttonTitle, style: theStyle, handler: { action in return } ) )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            
            self.activeController!.present(self.thisAlert!, animated: true, completion: nil)
        })
    }
    
    public func popupWithCustomButton (aTitle: String? = "", aMessage: String? = "", buttonTitle: String, theStyle: UIAlertAction.Style, theType: UIAlertController.Style? = .actionSheet, callBack: @escaping () -> Void ) {
        
        if thisAlert != nil { dismiss() }
        
        var theTitle: String?
        var theMessage: String?
       
        if aTitle!.isEmpty { theTitle = nil } else { theTitle = aTitle }
        if aMessage!.isEmpty { theMessage = nil } else { theMessage = aMessage! }
        
        thisAlert = UIAlertController(title: theTitle, message: theMessage, preferredStyle: theType!)
        thisAlert!.addAction(UIAlertAction(title: buttonTitle, style: theStyle, handler: { action in DispatchQueue.main.async(execute: { () -> Void in callBack() } ) } ) )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            
            self.activeController!.present(self.thisAlert!, animated: true, completion: nil)
        })
    }
    
    public func popupWithCustomButtons (aTitle: String? = "", aMessage: String? = "", buttonTitles: [String], theStyle: [UIAlertAction.Style], theType: UIAlertController.Style? = .actionSheet, callBack: @escaping (Int) -> Void) {
        
        if thisAlert != nil { dismiss() }
        
        var theTitle: String?
        var theMessage: String?
        
        if aTitle!.isEmpty { theTitle = nil } else { theTitle = aTitle }
        if aMessage!.isEmpty { theMessage = nil } else { theMessage = aMessage! }
        
        thisAlert = UIAlertController(title: theTitle, message: theMessage, preferredStyle: theType!)
        
        for (index,title) in buttonTitles.enumerated() {
            
            thisAlert!.addAction(UIAlertAction(title: title, style: theStyle[index], handler: { action in DispatchQueue.main.async(execute: { () -> Void in callBack(index) } ) } ) )
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            
            self.activeController!.present(self.thisAlert!, animated: true, completion: nil)
        })
    }
    
    // MARK: - POPUP MESSAGE
    public func popupMessage (aTitle: String? = "", aMessage: String, aViewDelay: TimeInterval? = 2.0) {
        
        if thisAlert != nil { dismiss() }
        thisAlert = UIAlertController(title: aTitle!, message: aMessage, preferredStyle: .actionSheet)
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            
            self.activeController!.present(self.thisAlert!, animated: true, completion: { self.dismissWithDelay(wait: aViewDelay!) })
        })
    }
    
    public func popupMessage (aTitle: String? = "", aMessage: String, aViewDelay: TimeInterval? = 2.0, callBack: @escaping () -> Void ) {
        
        if thisAlert != nil { dismiss() }
        thisAlert = UIAlertController(title: aTitle!, message: aMessage, preferredStyle: .actionSheet)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            
            self.activeController!.present(self.thisAlert!, animated: true, completion: { self.dismissWithDelay(wait: aViewDelay!, aCallBack: callBack) })
        })
    }
    
    // MARK: - DISMISS ALERT
    public func dismiss() {
        
        if self.thisAlert != nil {
            
            self.thisAlert!.dismiss(animated: true, completion: nil)
            self.thisAlert = nil
        }
    }
    
    public func dismissWithDelay(wait: TimeInterval? = 2.0) { DispatchQueue.main.asyncAfter(deadline: .now() + wait!, execute: { self.dismiss() }) }
  
    public func dismissWithDelay(wait: TimeInterval? = 2.0, aCallBack: @escaping () -> Void ) { DispatchQueue.main.asyncAfter(deadline: .now() + wait!, execute: { aCallBack(); self.dismiss() }) }
        
    // MARK: - INTERNAL USE ONLY
    private func setupPendingIndicator() {
     
        indicator = UIActivityIndicatorView(frame: self.thisAlert!.view.bounds)
        indicator!.color = .black
        indicator!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        indicator!.frame.origin.y = (self.thisAlert!.view.bounds.height/2 - indicator!.frame.height/2) + 10
        
        // Add the activity indicator as a subview of the alert controller's view
        thisAlert!.view.addSubview(indicator!)
        indicator!.isUserInteractionEnabled = false
        indicator!.startAnimating()
        indicator!.isHidden = false
    }
  
}

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

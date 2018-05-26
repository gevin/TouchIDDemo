//
//  ViewController.swift
//  TouchIDDemo
//
//  Created by GevinChen on 2018/5/25.
//  Copyright © 2018年 GevinChen. All rights reserved.
//

import UIKit

/* ## 1 import framework */
import LocalAuthentication

class ViewController: UIViewController {

    /* ## 2 declare LAContext instance */
    // Get the local authentication context.
    let context = LAContext()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonAuthenticateClicked(_ sender: Any) {
        authenticateUser(context: self.context)
    }
    
    @IBAction func buttonAuthenticationWithBiometricsClicked(_ sender: Any) {
        authenticateUserWithBiometrics(context: self.context)
    }
    
     ## 3 write the function of authentication 
    // if user fallback, it will forward to ios build-in password input UI
    func authenticateUser(context:LAContext) {
        // Declare a NSError variable.
        var error: NSError?
        // Set the reason string that will appear on the authentication alert.
        let reasonString = "Authentication is needed to access your data."
        // Check if the device can evaluate the policy.
        if  context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthentication,
                                   localizedReason: reasonString,
                                   reply: { (success: Bool, evalPolicyError: Error?) in
                                    if success {
                                        // do something
                                        print("touch id authenticate success.")
                                    }
                                    else{
                                        guard let evalPolicyError = evalPolicyError else {
                                            print("error occured, but error is empty.")
                                            return
                                        }
                                        // If authentication failed then show a message to the console with a short description.
                                        // In case that the error is a user fallback, then show the password alert view.
                                        print(evalPolicyError.localizedDescription)
                                        switch evalPolicyError {
                                        case LAError.systemCancel:
                                            print("Authentication was cancelled by the system")
                                        case LAError.userCancel:
                                            print("Authentication was cancelled by the user")
                                        case LAError.userFallback:
                                            // user 選擇輸入密碼
                                            // 若 LAPolicy 是選 deviceOwnerAuthentication
                                            // 那這裡就會自動帶入系統的輸入密碼
                                            // 若是選 deviceOwnerAuthenticationWithBiometrics
                                            // 那你就要自己處理輸入密碼的介面，你可以彈一個 input text alert 出來
                                            print("User selected to enter custom password")
                                        default:
                                            print("Authentication failed")
                                        }
                                    }
            })
        }
        else{
            guard let error = error else {
                return
            }
            // If the security policy cannot be evaluated then show a short message depending on the error.
            switch error{
            case LAError.biometryNotEnrolled:
                print("TouchID is not enrolled")
            case LAError.biometryLockout:
                print("TouchID is lockout")
                // 被鎖住，要輸入密碼才能過
            case LAError.biometryNotAvailable:
                print("TouchID is not available")
            case LAError.passcodeNotSet:
                print("A passcode has not been set")
            default:
                // The LAError.TouchIDNotAvailable case.
                print("TouchID not available")
            }
            // Optionally the error description can be displayed on the console.
            print(error.localizedDescription)
        }
    }
    
    
    func authenticateUserWithBiometrics(context:LAContext) {
        // Declare a NSError variable.
        var error: NSError?
        // Set the reason string that will appear on the authentication alert.
        let reasonString = "Authentication is needed to access your data."
        // Check if the device can evaluate the policy.
        if  context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: reasonString,
                                   reply: { (success: Bool, evalPolicyError: Error?) in
                                    if success {
                                        // do something
                                        print("touch id authenticate success.")
                                    }
                                    else{
                                        guard let evalPolicyError = evalPolicyError else {
                                            print("error occured, but error is empty.")
                                            return
                                        }
                                        // If authentication failed then show a message to the console with a short description.
                                        // In case that the error is a user fallback, then show the password alert view.
                                        print(evalPolicyError.localizedDescription)
                                        switch evalPolicyError {
                                        case LAError.systemCancel:
                                            print("Authentication was cancelled by the system")
                                        case LAError.userCancel:
                                            print("Authentication was cancelled by the user")
                                        case LAError.userFallback:
                                            print("User selected to enter custom password")
                                            self.showInputPasswordAlert()
                                        case LAError.biometryLockout:
                                            print("try lockout")
                                            // lockout 要輸入密碼才能過，改用 deviceOwnerAuthentication 就能帶出系統的密碼介面
                                            self.authenticateUser(context: context)
                                        default:
                                            print("Authentication failed")
                                        }
                                    }
            })
        }
        else{
            guard let error = error else {
                return
            }
            // If the security policy cannot be evaluated then show a short message depending on the error.
            switch error{
            case LAError.biometryNotEnrolled:
                print("TouchID is not enrolled")
            case LAError.biometryLockout:
                print("TouchID is lockout")
                // lockout 要輸入密碼才能過，改用 deviceOwnerAuthentication 就能帶出系統的密碼介面
                self.authenticateUser(context: context)
            case LAError.biometryNotAvailable:
                print("TouchID is not available")
            case LAError.passcodeNotSet:
                print("A passcode has not been set")
            default:
                // The LAError.TouchIDNotAvailable case.
                print("TouchID not available")
            }
            // Optionally the error description can be displayed on the console.
            print(error.localizedDescription)
        }
    }
    

    
    func showInputPasswordAlert() {
        
        if #available(iOS 10 , *) {
            
            let passwordAlert: UIAlertController = UIAlertController(title: "TouchIDDemo",
                                                                     message: "Authentication failed",
                                                                     preferredStyle: UIAlertControllerStyle.alert)
            let action_ok: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: { [weak passwordAlert] (action) in
                guard let passwordAlert = passwordAlert else { return }
                passwordAlert.dismiss(animated: true, completion: nil)
                // verify password here
                // ...
            })
            
            let action_cancel: UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { [weak passwordAlert] (action) in
                guard let passwordAlert = passwordAlert else { return }
                passwordAlert.dismiss(animated: true, completion: nil)
            })
            passwordAlert.addAction(action_ok)
            passwordAlert.addAction(action_cancel)
            passwordAlert.addTextField(configurationHandler: { (textField) in
                textField.isSecureTextEntry = true
            })
            self.present(passwordAlert, animated: true, completion: nil)
        }
    }
    

}


//
//  CXSignInSignUpViewController.swift
//  NV Agencies
//
//  Created by Sarath on 07/04/16.
//  Copyright © 2016 Sarath. All rights reserved.
//

import UIKit
import Foundation


protocol CXSingInDelegate {
    func didGoogleSignIn()
}

class CXSignInSignUpViewController: CXViewController,UITextFieldDelegate {
    var emailAddressField: UITextField!
    var passwordField: UITextField!
    var signInBtn:UIButton!
    var signUpBtn:UIButton!
    var backButton:UIButton!
    
    var cScrollView:UIScrollView!
    var keyboardIsShown:Bool!
    
    //var orgID:String! = CXConstant.MallID
    var profileImageStr:String!
    var profileImagePic:UIImageView!
    var delegate:CXSingInDelegate?
    var heder: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white;
        self.keyboardIsShown = false
        self.customizeMainView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(CXSignInSignUpViewController.methodOfReceivedNotification(_:)), name:NSNotification.Name(rawValue: "ForgotNotification"), object: nil)
    }
    
    
    func customizeMainView() {
        self.cScrollView = UIScrollView.init(frame: CGRect(x: 0,y: 0, width: self.view.frame.size.width, height: (self.view.frame.size.height)))
        self.cScrollView.backgroundColor = UIColor.clear
       // self.cScrollView.contentSize = CGSizeMake(self.view.frame.size.width,600)
        self.view.addSubview(self.cScrollView)

        let signUpLbl = UILabel.createHeaderLabel(CGRect(x: 20, y: 40, width: self.cScrollView.frame.size.width-40, height: 50), text: "Sign In",font:UIFont.init(name: "Roboto-Regular", size: 40)!)
        self.cScrollView.addSubview(signUpLbl)
        
        let signUpSubLbl = UILabel.createHeaderLabel(CGRect(x: 20, y: signUpLbl.frame.origin.y+signUpLbl.frame.size.height-10, width: self.cScrollView.frame.size.width-40, height: 40), text: "Sign up with email address",font:UIFont.init(name: "Roboto-Regular", size: 14)!)
        self.cScrollView.addSubview(signUpSubLbl)
        
        self.emailAddressField = self.createField(CGRect(x: 30, y: signUpSubLbl.frame.size.height+signUpSubLbl.frame.origin.y+5, width: self.view.frame.size.width-60, height: 40), tag: 1, placeHolder: "Email address")
        self.cScrollView.addSubview(self.emailAddressField)
        
        self.passwordField = self.createField(CGRect(x: 30, y: self.emailAddressField.frame.size.height+self.emailAddressField.frame.origin.y+20, width: self.view.frame.size.width-60, height: 40), tag: 2, placeHolder: "Password")
        self.passwordField.isSecureTextEntry = true
        self.cScrollView.addSubview(self.passwordField)
        
        self.signInBtn = self.createButton(CGRect(x: 25, y: self.passwordField.frame.size.height+self.passwordField.frame.origin.y+30, width: self.view.frame.size.width-50, height: 50), title: "SIGN IN", tag: 3, bgColor: CXAppConfig.sharedInstance.getAppTheamColor())
          self.signInBtn.addTarget(self, action: #selector(CXSignInSignUpViewController.signInAction), for: .touchUpInside)
        self.cScrollView.addSubview(self.signInBtn)
        
        self.signUpBtn = self.createButton(CGRect(x: 25, y: self.signInBtn.frame.size.height+self.signInBtn.frame.origin.y+20, width: self.view.frame.size.width-50, height: 50), title: "SIGN UP", tag: 3, bgColor: UIColor.signUpColor())
        self.signUpBtn.addTarget(self, action: #selector(CXSignInSignUpViewController.signUpAction), for: .touchUpInside)
        self.cScrollView.addSubview(self.signUpBtn)
        
      
        
    }
    
    override func methodOfReceivedNotification(_ notification: NSNotification){
        
        let forgotPswdViewCnt : CXForgotPassword = CXForgotPassword()
        self.navigationController?.pushViewController(forgotPswdViewCnt, animated: true)
        
    }
    
    
    func  createPlainTextButton(_ frame:CGRect,title: String,tag:Int) -> UIButton {
        let button: UIButton = UIButton()
        button.frame = frame
        button.setTitle(title, for: UIControlState())
        button.titleLabel?.font = UIFont.init(name:"Roboto-Regular", size: 15)
        button.titleLabel?.textAlignment = NSTextAlignment.center
        button.setTitleColor(UIColor.black, for: UIControlState())
        button.backgroundColor = UIColor.clear
        return button
        
    }
  
    func showAlertView(_ message:String, status:Int) {
        DispatchQueue.main.async(execute: {
            let alert = UIAlertController(title: "Alert!!!", message: message, preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default) {
                UIAlertAction in
                if status == 1 {
                    //It should leads to Profile Screen
                    
                    
                }
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    
    func moveBackView() {
        let navControllers:NSArray = (self.navigationController?.viewControllers)! as NSArray
        let prevController = navControllers.object(at: navControllers.count-1)
        self.navigationController?.popToViewController(prevController as! UIViewController, animated: true)
    }
    
    
    
    func sendSignDetails() {
  
        CXAppDataManager.sharedInstance.singWithUserDetails(self.emailAddressField.text!, password: self.passwordField.text!) { (responseDict) in
            /*   UserId = 2003;
             address = "";
             city = "";
             country = India;
             emailId = "iamsky.mme@gmail.com";
             firstName = Suresh;
             fullName = "Suresh Kumar";
             gender = 0;
             lastName = Kumar;
             macId = "20749ce5-bddb-4ea5-82b4-8960f0598e90";
             macIdJobId = 30450;
             mobile = 9640339556;
             msg = Success;
             orgId = 11;
             organisation = "68M Holidays";
             state = "";
             status = 1;
             userBannerPath = "";
             userImagePath = "";*/
            
        let status: Int = Int(responseDict.value(forKey: "status") as! String)!
            
            if status == 1{
            UserDefaults.standard.set(responseDict.value(forKey: "state"), forKey: "STATE")
            UserDefaults.standard.set(responseDict.value(forKey: "emailId"), forKey: "USER_EMAIL")
            UserDefaults.standard.set(responseDict.value(forKey: "firstName"), forKey: "FIRST_NAME")
            UserDefaults.standard.set(responseDict.value(forKey: "lastName"), forKey: "LAST_NAME")
            UserDefaults.standard.set(responseDict.value(forKey: "gender"), forKey: "GENDER")
            UserDefaults.standard.set(responseDict.value(forKey: "UserId"), forKey: "USER_ID")
            UserDefaults.standard.set(responseDict.value(forKey: "macId"), forKey: "MAC_ID")
            UserDefaults.standard.set(responseDict.value(forKey: "mobile"), forKey: "MOBILE")
            UserDefaults.standard.set(responseDict.value(forKey: "address"), forKey: "ADDRESS")
            UserDefaults.standard.set(responseDict.value(forKey: "fullName"), forKey: "FULL_NAME")
            UserDefaults.standard.set(responseDict.value(forKey: "city"), forKey: "CITY")
            UserDefaults.standard.set(responseDict.value(forKey: "orgId"), forKey: "ORG_ID")
            UserDefaults.standard.set(responseDict.value(forKey: "macIdJobId"), forKey: "MACID_JOBID")
            UserDefaults.standard.set(responseDict.value(forKey: "organisation"), forKey: "ORGANIZATION")
            UserDefaults.standard.set(responseDict.value(forKey: "msg"), forKey: "MESSAGE")
            UserDefaults.standard.set(responseDict.value(forKey: "status"), forKey: "STATUS")
            UserDefaults.standard.set(responseDict.value(forKey: "country"), forKey: "COUNTRY")
            UserDefaults.standard.set(responseDict.value(forKey: "userBannerPath"), forKey: "BANNER_PATH")
            UserDefaults.standard.set(responseDict.value(forKey: "userImagePath"), forKey: "IMAGE_PATH")
            UserDefaults.standard.synchronize()
            
                let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let profile = storyBoard.instantiateViewController(withIdentifier: "PROFILE") as! UserProfileViewController
                profile.isFromSignIn = true
                self.navigationController?.pushViewController(profile, animated: true)
            
                
        } else {
               self.showAlertView("Please enter valid credentials", status: status)
            }
        }
        }
    
    func signInAction() {
        // print ("Sign In action")
        self.view.endEditing(true)
        if self.isValidEmail(self.emailAddressField.text!) {
            self.sendSignDetails()
        } else {
                let alert = UIAlertController(title: "Alert!!!", message: "Please enter valid email.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                //print("Please enter valid email")
        }
    }
    
    func signUpAction() {
        print ("Sign Up action")
        self.view.endEditing(true)
        let signUpView = CXSignUpViewController.init()
//signUpView.orgID = self.orgID
        self.navigationController?.pushViewController(signUpView, animated: true)
    }
    
    func isValidEmail(_ email: String) -> Bool {
        print("validate email: \(email)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if emailTest.evaluate(with: email) {
            return true
        }
        return false
    }
    
    
    func createField(_ frame:CGRect, tag:Int, placeHolder:String) -> UITextField {
        let txtField : UITextField = UITextField()
        txtField.frame = frame;
        txtField.delegate = self
        txtField.tag = tag
        txtField.placeholder = placeHolder
        txtField.font = UIFont.init(name:"Roboto-Regular", size: 15)
        txtField.autocapitalizationType = .none
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: txtField.frame.size.height - width, width:  txtField.frame.size.width, height: txtField.frame.size.height)
        border.borderWidth = width
        txtField.layer.addSublayer(border)
        txtField.layer.masksToBounds = true
        
        return txtField
    }
    
    func createButton(_ frame:CGRect,title: String,tag:Int, bgColor:UIColor) -> UIButton {
        let button: UIButton = UIButton()
        button.frame = frame
        button.setTitle(title, for: UIControlState())
        button.titleLabel?.font = UIFont.init(name:"Roboto-Regular", size: 15)
        button.layer.cornerRadius = 5.0
        button.layer.masksToBounds = true
        button.backgroundColor = bgColor
        return button
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let scrollPoint = CGPoint(x: 0, y: textField.frame.origin.y)
        self.cScrollView.setContentOffset(scrollPoint, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.cScrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    //MAR:Heder options enable
    override  func shouldShowRightMenu() -> Bool{
        
        return true
    }
    
    override func shouldShowNotificatoinBell() ->Bool{
        
        return false
    }
    
    override  func shouldShowCart() -> Bool{
        
        return false
    }
    
    override func shouldShowLeftMenu() -> Bool{
        
        return false
    }
    override func showLogoForAboutUs() -> Bool{
        return false
    }
    override func shouldShowLeftMenuWithLogo() -> Bool{
        
        return false
    }
    override func headerTitleText() -> String{
        return "Sign in and Sign up"
    }
    
    override func profileDropdown() -> Bool{
        return false
    }
    
    override func profileDropdownForSignIn() -> Bool{
        return true
    }
    

}



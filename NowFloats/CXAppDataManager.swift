//
//  CXAppDataManager.swift
//  NowFloats
//
//  Created by Mahesh Y on 8/24/16.
//  Copyright © 2016 CX. All rights reserved.
//

import UIKit
private var _sharedInstance:CXAppDataManager! = CXAppDataManager()

protocol AppDataDelegate {
    func completedTheFetchingTheData(sender: CXAppDataManager)
    
}
public class CXAppDataManager: NSObject {
    
    var dataDelegate:AppDataDelegate?
    
    class var sharedInstance : CXAppDataManager {
        return _sharedInstance
    }
    
    private override init() {
        
    }
    
    func destory () {
        _sharedInstance = nil
    }
    
    //Get The StoreCategory
    func getTheStoreCategory(){
         self.getTheSigleMall()
        CXDataService.sharedInstance.getTheAppDataFromServer(["type":"StoreCategories","mallId":CXAppConfig.sharedInstance.getAppMallID()]) { (responseDict) in
            print("print store category\(responseDict)")
            self.getTheStores()
        }
    }
    
    
    func getTheStores(){
        CXDataService.sharedInstance.getTheAppDataFromServer(["type":"Stores","mallId":CXAppConfig.sharedInstance.getAppMallID()]) { (responseDict) in
            if  CXDataProvider.sharedInstance.getTheTableDataFromDataBase("CX_Stores", predicate: NSPredicate(), ispredicate: false,orederByKey: "").totalCount == 0{
                CXDataProvider.sharedInstance.saveStoreInDB(responseDict, completion: { (isDataSaved) in
                    self.getProducts()
                })
            }else{
                self.getProducts()
            }
        }
    }
    
    func getProducts(){
        if  CXDataProvider.sharedInstance.getTheTableDataFromDataBase("CX_Products", predicate: NSPredicate(), ispredicate: false,orederByKey: "").totalCount == 0{
            CXDataService.sharedInstance.getTheAppDataFromServer(["type":"Products","mallId":CXAppConfig.sharedInstance.getAppMallID()]) { (responseDict) in
                //print("print products\(responseDict)")
                CXDataProvider.sharedInstance.saveTheProducts(responseDict, completion: { (isDataSaved) in
                    self.getTheFeaturedProduct()
                })
            }
        }else{
            self.getTheFeaturedProduct()
        }
    }
    
    //http://nowfloats.ongostore.com:8081/Services/getMasters?type=Products&mallId=11
    //http://nowfloats.ongostore.com:8081/Services/getMasters?type=Products&mallId=11&pageNumber=2&pageSize=5
    
    
    func getTheSigleMall(){
        //type=singleMall
        if  CXDataProvider.sharedInstance.getTheTableDataFromDataBase("CX_SingleMall", predicate: NSPredicate(), ispredicate: false,orederByKey: "").totalCount == 0{
            CXDataService.sharedInstance.getTheAppDataFromServer(["type":"singleMall","mallId":CXAppConfig.sharedInstance.getAppMallID()]) { (responseDict) in
                CXDataProvider.sharedInstance.saveSingleMallInDB(responseDict, completion: { (isDataSaved) in
                })
            }
        }else{
            
        }
    }
    
    
    func getTheProductCategory(){
        
        
    }
    
    func getTheServieCategory(){
        
        
    }
    
    
    func getTheFeaturedProduct(){
        print("getTheFeaturedProduct")
        
        if  CXDataProvider.sharedInstance.getTheTableDataFromDataBase("CX_FeaturedProducts", predicate: NSPredicate(), ispredicate: false,orederByKey: "").totalCount == 0{
            CXDataService.sharedInstance.getTheAppDataFromServer(["type":"Featured Products","mallId":CXAppConfig.sharedInstance.getAppMallID()]) { (responseDict) in
                CXDataProvider.sharedInstance.saveTheFeatureProducts(responseDict, completion: { (isDataSaved) in
                    if isDataSaved{
                        self.getTheFeaturedProductJobs()
                    }else{
                        self.dataDelegate?.completedTheFetchingTheData(self)
                    }
                    
                })
            }
        }else{
            self.getTheFeaturedProductJobs()
        }
    }
    
    
    func getTheFeaturedProductJobs(){
        print("getTheFeaturedProductJobs")
        
        let jobsArray : NSArray =  CXDataProvider.sharedInstance.getTheTableDataFromDataBase("CX_FeaturedProducts", predicate: NSPredicate(format:"itHasJobs == 0" ), ispredicate: true,orederByKey: "").dataArray
        if jobsArray.count != 0 {
            let featuredProducts:CX_FeaturedProducts
                =    (jobsArray.lastObject as? CX_FeaturedProducts)!
            //  NSManagedObjectContext.MR_contextForCurrentThread().save()
            
            CXDataService.sharedInstance.getTheAppDataFromServer(["PrefferedJobs":featuredProducts.campaign_Jobs!,"mallId":CXAppConfig.sharedInstance.getAppMallID()]) { (responseDict) in
                CXDataProvider.sharedInstance.saveTheFeaturedProductJobs(responseDict, parentID: featuredProducts.fID!, completion: { (isDataSaved) in
                    featuredProducts.itHasJobs = true
                    NSManagedObjectContext.MR_contextForCurrentThread().MR_saveOnlySelfAndWait()
                    self.getTheFeaturedProductJobs()
                })
            }
        }else{
            self.dataDelegate?.completedTheFetchingTheData(self)
        }
    }
    
    
    //Mark Place order
    
    func placeOder(completion:(isDataSaved:Bool) -> Void){
        
        CXDataService.sharedInstance.synchDataToServerAndServerToMoblile("", parameters: ["json":self.checkOutCartItems(),"dt":"CAMPAIGNS","category":"Services","userId":"","consumerEmail":""]) { (responseDict) in
            
        }
    }
    
    
    func checkOutCartItems()-> String{
        
        let productEn = NSEntityDescription.entityForName("CX_Cart", inManagedObjectContext: NSManagedObjectContext.MR_contextForCurrentThread())
        let fetchRequest = CX_Cart.MR_requestAllSortedBy("name", ascending: true)
        // fetchRequest.predicate = predicate
        fetchRequest.entity = productEn
        
        let order: NSMutableDictionary = NSMutableDictionary()
        var orderItemName: NSMutableString = NSMutableString()
        let orderItemQuantity: NSMutableString = NSMutableString()
        let orderSubTotal: NSMutableString = NSMutableString()
        let orderItemId: NSMutableString = NSMutableString()
        let orderItemMRP: NSMutableString = NSMutableString()
        
        //let total: Double = 0
        order.setValue("", forKey: "Name")
        //order["Name"] = ("\("kushal")")
        //should be replaced
        // order["Address"] = ("\("madhapur hyd")")
        order.setValue("", forKey: "Address")
        
        //should be replaced
        //order["Contact_Number"] = ("\("7893335553")")
        order.setValue("", forKey: "Contact_Number")
        
        //should be replaced
        
        
        for (index, element) in CX_Cart.MR_executeFetchRequest(fetchRequest).enumerate() {
            let cart : CX_Cart = element as! CX_Cart
            if index != 0 {
                orderItemName.appendString(("\("|")"))
                orderItemQuantity .appendString(("\("|")"))
                orderSubTotal .appendString(("\("|")"))
                orderItemId .appendString(("\("|")"))
                orderItemMRP .appendString(("\("|")"))
            }
            orderItemName.appendString("\(cart.name! + "`" + cart.pID!)")
            //orderItemQuantity.appendString("\(cart.quantity! + "`" + cart.pID!)")
            //orderSubTotal.appendString(cart.name! + "`" + cart.pID!)
            orderItemId.appendString("\(cart.pID! + "`" + cart.pID!)")
            //orderItemMRP.appendString(cart.name! + "`" + cart.pID!)
            //print("Item \(index): \(cart)")
        }
        
        //  order["OrderItemId"] = orderItemId
        order.setValue(orderItemId, forKey: "OrderItemId")
        
        //[order setObject:itemCode forKey:@"ItemCode"];
        //order["OrderItemQuantity"] = orderItemQuantity
        order.setValue(orderItemQuantity, forKey: "OrderItemQuantity")
        
        // order["OrderItemName"] = orderItemName
        order.setValue(orderItemName, forKey: "OrderItemName")
        
        //order["OrderItemSubTotal"] = ("\(orderSubTotal)")
        order.setValue(orderSubTotal, forKey: "OrderItemSubTotal")
        
        // order["OrderItemMRP"] = ("\(orderItemMRP)")
        order.setValue(orderItemMRP, forKey: "OrderItemMRP")
        
        
        //print("order dic \(order)")
        
        let listArray : NSMutableArray = NSMutableArray()
        
        listArray.addObject(order)
        
        let cartJsonDict :NSMutableDictionary = NSMutableDictionary()
        cartJsonDict.setObject(listArray, forKey: "list")
        
        //let jsonString = cartJsonDict.JSONString()
        var jsonData : NSData = NSData()
        do {
            jsonData = try NSJSONSerialization.dataWithJSONObject(cartJsonDict, options: NSJSONWritingOptions.PrettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
        } catch let error as NSError {
            print(error)
        }
        let jsonStringFormat = String(data: jsonData, encoding: NSUTF8StringEncoding)
        //print("order dic \(jsonStringFormat)")
        
        return jsonStringFormat!
        
    
    }
    

    //MARK : SIGN 
    //http://storeongo.com:8081/MobileAPIs/loginConsumerForOrg?
    func singWithUserDetails(email:String, password:String ,completion:(responseDict:NSDictionary) -> Void){
        
        CXDataService.sharedInstance.synchDataToServerAndServerToMoblile(CXAppConfig.sharedInstance.getBaseUrl()+CXAppConfig.sharedInstance.getSignInUrl(), parameters: ["orgId":CXAppConfig.sharedInstance.getAppMallID(),"email":email,"dt":"DEVICES","password":password]) { (responseDict) in
            completion(responseDict: responseDict)
        }
        
    }
    
    //MARK: SIGN UP
    func signUpWithUserDetails (fistName:String, lastName:String,mobileNumber:String, email:String, password:String, completion:(responseDict:NSDictionary) -> Void){
    // let signUpUrl = "http://sillymonksapp.com:8081/MobileAPIs/regAndloyaltyAPI?orgId="+orgID+"&userEmailId="+self.emailAddressField.text!+"&dt=DEVICES&firstName="+self.firstNameField.text!.urlEncoding()+"&lastName="+self.lastNameField.text!.urlEncoding()+"&password="+self.passwordField.text!.urlEncoding()
        
        
        CXDataService.sharedInstance.synchDataToServerAndServerToMoblile(CXAppConfig.sharedInstance.getBaseUrl()+CXAppConfig.sharedInstance.getSignUpInUrl(), parameters: ["orgId":CXAppConfig.sharedInstance.getAppMallID(),"userEmailId":email,"dt":"DEVICES","password":password,"firstName":"","lastName":""]) { (responseDict) in
            completion(responseDict: responseDict)

        }
    }
    
    //MARK : FORGOOT PASSWORD
    
    func  forgotPassword(email:String,completion:(responseDict:NSDictionary) -> Void){
        
        CXDataService.sharedInstance.synchDataToServerAndServerToMoblile(CXAppConfig.sharedInstance.getBaseUrl()+CXAppConfig.sharedInstance.getForgotPassordUrl(), parameters: ["orgId":CXAppConfig.sharedInstance.getAppMallID(),"email":email,"dt":"DEVICES"]) { (responseDict) in
            completion(responseDict: responseDict)

        }
    }
    
    //MARK : GET ALL ORDERS
    
    
    
    //MARK : UPDATE PROFILE
    
    func profileUpdate(email:String,address:String,firstName:String,lastName:String,mobileNumber:String,city:String,state:String,country:String,image:UIImage,completion:(responseDict:NSDictionary)-> Void){
        
        CXDataService.sharedInstance.imageUpload(UIImageJPEGRepresentation(image, 0.5)!) { (imageFileUrl) in
            
            CXDataService.sharedInstance.synchDataToServerAndServerToMoblile(CXAppConfig.sharedInstance.getBaseUrl()+CXAppConfig.sharedInstance.getupdateProfileUrl(), parameters: ["orgId":CXAppConfig.sharedInstance.getAppMallID(),"email":email,"dt":"DEVICES","address":"","firstName":"","lastName":"","mobileNo":"","city":"","state":"","country":"","userImagePath":imageFileUrl,"userBannerPath":imageFileUrl]) { (responseDict) in
                completion(responseDict: responseDict)
            }
            
        }
        //   NSString* urlString = [NSString stringWithFormat:@"%@orgId=%@&email=%@&dt=DEVICES&firstName=%@&lastName=%@&address=%@&mobileNo=%@&city=%@&state=%@&country=%@&userImagePath=%@&userBannerPath=%@",UpdateProfile_URL,mallId,dict[@"emailId"], dict[@"firstName"],dict[@"lastName"],dict[@"address"],dict[@"mobile"],dict[@"city"],dict[@"state"],dict[@"country"], dict[@"userImagePath"], dict[@"userBannerPath"]];

        
    }
    
    
    
    
}

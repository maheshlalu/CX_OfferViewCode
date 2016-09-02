//
//  CXAppDataManager.swift
//  NowFloats
//
//  Created by Mahesh Y on 8/24/16.
//  Copyright © 2016 CX. All rights reserved.
//

import UIKit
private var _sharedInstance:CXAppDataManager! = CXAppDataManager()
public class CXAppDataManager: NSObject {

    
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
            CXDataService.sharedInstance.getTheAppDataFromServer(["type":"StoreCategories","mallId":CXAppConfig.sharedInstance.getAppMallID()]) { (responseDict) in
           // print("print store category\(responseDict)")
               // CXDataProvider.sharedInstance.saveTheStoreCategory(responseDict)
                //responseDict.valueForKey("jobs")! as! NSArray
            //self.getTheStores()
        }
    }
    
    
    func getTheStores(){
        CXDataService.sharedInstance.getTheAppDataFromServer(["type":"Stores","mallId":CXAppConfig.sharedInstance.getAppMallID()]) { (responseDict) in
           // print("print getTheStores\(responseDict)")
            
        }
    }
    
    func getProducts(){
        
        
        
        CXDataService.sharedInstance.getTheAppDataFromServer(["type":"Products","mallId":CXAppConfig.sharedInstance.getAppMallID()]) { (responseDict) in
             //print("print products\(responseDict)")
            CXDataProvider.sharedInstance.saveTheProducts(responseDict)

        }
        
        
    }
    
    //http://nowfloats.ongostore.com:8081/Services/getMasters?type=Products&mallId=11
    //http://nowfloats.ongostore.com:8081/Services/getMasters?type=Products&mallId=11&pageNumber=2&pageSize=5
    
    
    
    func getTheSigleMall(){
        
        
    }
    
    
    func getTheProductCategory(){
        
        
    }
    
    func getTheServieCategory(){
        
        
    }
    
    
    func getTheFeaturedProduct(){
        CXDataService.sharedInstance.getTheAppDataFromServer(["type":"Featured Products","mallId":CXAppConfig.sharedInstance.getAppMallID()]) { (responseDict) in
            print("print products\(responseDict)")
            //CXDataProvider.sharedInstance.saveTheFeatureProducts(responseDict)
            self.getTheFeaturedProductJobs(responseDict)
        }
    }
    
    
    func getTheFeaturedProductJobs(jsonDic:NSDictionary){
        //jobId
        let jobs : NSArray =  jsonDic.valueForKey("jobs")! as! NSArray

        for prod in jobs {
            let jobsString : String = (prod.valueForKey("Campaign_Jobs") as? String)!
                CXDataService.sharedInstance.getTheAppDataFromServer(["PrefferedJobs":jobsString,"mallId":CXAppConfig.sharedInstance.getAppMallID()]) { (responseDict) in
                    print("print products\(responseDict)")
            }
            
            
        }
    }
    

    
    let operation = NSOperation()


    
}

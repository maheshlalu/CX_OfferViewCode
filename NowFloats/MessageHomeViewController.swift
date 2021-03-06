//
//  MessageHomeViewController.swift
//  NowFloats
//
//  Created by Manishi on 9/20/16.
//  Copyright © 2016 CX. All rights reserved.
//

import UIKit


class MessageHomeViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        addTheTabBarControllers()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addTheTabBarControllers(){
        
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
    
        let product = storyBoard.instantiateViewController(withIdentifier: "FORM") as! ServiceFormViewController
        product.title = "FORM"

        let photos = storyBoard.instantiateViewController(withIdentifier: "HISTORY") as! HistoryViewController
        photos.title = "HISTORY"

        
        self.tabBarController?.setViewControllers([product,photos], animated: true)

    }

}

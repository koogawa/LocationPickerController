//
//  ViewController.swift
//  LocationPickerController
//
//  Created by koogawa on 2016/04/30.
//  Copyright © 2016 koogawa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var locationLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTapSelectLocationButton(sender: AnyObject) {
        print(1)
    }

}


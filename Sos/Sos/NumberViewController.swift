//
//  NumberViewController.swift
//  Sos
//
//  Created by Иван Белоконь on 5/16/19.
//  Copyright © 2019 Иван Белоконь. All rights reserved.
//

import UIKit

class NumberViewController: UIViewController {
    @IBOutlet weak var contact1: UITextField!
    @IBOutlet weak var contact2: UITextField!
    @IBOutlet weak var contact3: UITextField!
    
    weak var previousVC: ViewController!
    
    @IBAction func saveContact(_ sender: Any) {
        let firstContact = contact1.text
        let secondContact = contact2.text
        let lastContact = contact3.text
        if (firstContact!.isEmpty || secondContact!.isEmpty || lastContact!.isEmpty) {
            var myAlert = UIAlertController(title: "Alert", message: "All fields are required to fill in", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
            myAlert.addAction(okAction)
            self.present(myAlert, animated: true, completion: nil)
            return
        }
        previousVC.allNumberText = contact1.text! + ",\n" + contact2.text! + ",\n" + contact3.text!
        navigationController?.popViewController(animated: true)
        
    }
    
    
    
    
}

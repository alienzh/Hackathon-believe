//
//  LoginViewController.swift
//  Game2035OCNew
//
//  Created by FanPengpeng on 2023/3/8.
//

import UIKit

class LoginViewController: UIViewController {
    
    private var loginSuccessCallback:(()->())?

    @IBOutlet weak var phoneTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func didClickLoginButton(_ sender: Any) {
        if let phone = phoneTF.text, phone.count > 0 {
            AppContext.currentUserId = phone
            loginSuccessCallback?()
        }
    }
    
    @objc func loginSuccess(_ callback:(()->())?) {
        loginSuccessCallback = callback
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        phoneTF.resignFirstResponder()
    }
}

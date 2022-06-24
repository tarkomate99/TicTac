//
//  LoginViewController.swift
//  TicTac
//
//  Created by mac on 2022. 06. 24..
//

import UIKit
import FirebaseAuth
class LoginViewController: UIViewController {

    
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var pwdText: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
        // Do any additional setup after loading the view.
    }
    
    func setUpElements(){
        errorLabel.alpha = 0
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func loginTapped(_ sender: Any) {
        
        let email = self.emailText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = self.pwdText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Auth.auth().signIn(withEmail: email, password: password){ (result, error) in
            if error != nil {
                self.errorLabel.text = error!.localizedDescription
                self.errorLabel.alpha = 1
            }else{
                self.showHomePage()
            }
        }
        
    }
    
    func showHomePage(){
        let homeViewController = self.storyboard?.instantiateViewController(identifier: "HomeVC") as? ViewController
        self.navigationController?.pushViewController(homeViewController!, animated: true)
    }
}

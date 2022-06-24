//
//  SignUpViewController.swift
//  TicTac
//
//  Created by mac on 2022. 06. 24..
//

import UIKit
import FirebaseAuth
import Firebase
class SignUpViewController: UIViewController {

    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var pwdText: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    
    
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
    
    func validateFileds() -> String? {
        if firstNameText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            pwdText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Töltsd ki a mezőket!"
        }
        
        let cleanedPassword = pwdText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        
        if passwordTest.evaluate(with: cleanedPassword) == false {
            return "A jelszónak minumum 8 karakteresnek kell lennie, és speciális karaktert és számot kell tartalmaznia!"
        }
        
        
        return nil
    }
    
    
    @IBAction func registerTapped(_ sender: Any) {
        
        let error = validateFileds()
        
        if error != nil {
            
            showError(error!)
            
        }else{
            
            let firstName = firstNameText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let passw = pwdText.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            Auth.auth().createUser(withEmail: email, password: passw) { (result, err) in
                
                if err != nil {
                    print(err?.localizedDescription)
                    self.showError("Error creating user")
                }
                else {
                    let db = Firestore.firestore()
                    db.collection("users").addDocument(data: ["firstname": firstName, "lastname": lastName, "uid": result!.user.uid ]){ (error) in
                        
                        if error != nil{
                            self.showError("Error saving user data")
                        }
                    }
                    
                    self.showHomePage()
                    
                }
                
            }
            
            
        }
        
        
    }
    
    func showError(_ message:String){
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func showHomePage(){
        let homeViewController = self.storyboard?.instantiateViewController(identifier: "HomeVC") as? ViewController
        self.navigationController?.pushViewController(homeViewController!, animated: true)
        
        /*
         self.view.window?.rootViewController = homeViewController
         self.view.window?.makeKeyAndVisible()
         */
       
    }
    
}

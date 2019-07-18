import Foundation
import Firebase
import GoogleSignIn

class GoogleSignIn: UIViewController, GIDSignInUIDelegate{
   
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    
    var handle: AuthStateDidChangeListenerHandle?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Lmao")
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
   
   
}

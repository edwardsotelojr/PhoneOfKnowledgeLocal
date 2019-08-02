import UIKit
import Firebase
import GoogleSignIn
var books = [Book]()
let db = Firestore.firestore()
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    var window: UIWindow?
    var activityIndicator = UIActivityIndicatorView()
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error) != nil {
            print("An error occured during Google Authentication")
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (user, error) in
            if (error) != nil {
                print("Google Authentification Fail")
                return
            }
            print("Google Authentification Success")
            if let userID = user?.uid {
                self.getUser(userID: userID)
            }
        }
    }
    
    
    private func getUser(userID: String){
        // check if user is in the DB
        let userRef = db.collection("users").document(userID)
        userRef.getDocument{ (document, error) in
                // if user exist in DB
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? nil
                print("Document data: \(dataDescription)")
                self.getData(userID: userID)
            
            }
            
            else {
                let title = "Sample Book"
                let author = "Edward Sotelo Jr"
                let coverImage = ""
                let imageUI = UIImage(named: "defaultPhoto")!
            db.collection("users").document(userID).setData([:])
                db.collection("users").document(userID).collection("books").addDocument(data: ["title" : title,
                     "author": author,
                     "coverImage" : coverImage
                    ])
                books.append(Book(documentID: UUID().uuidString, title: title, image: coverImage, author: author, imageUI: imageUI)!)
                print("Document does not exist")
                let mainStoryBoard: UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
                let protectedPage = mainStoryBoard.instantiateViewController(withIdentifier: "navController") as! UINavigationController
                let appDelegate = UIApplication.shared.delegate
                appDelegate?.window??.rootViewController = protectedPage
            }
        }
    }
    
    private func getData(userID: String) {
            print("here in getData()")
            user = db.collection("users").document(userID).collection("books")
        db.collection("users").document(userID).collection("books").getDocuments() {
            (snapshot, error) in
                if error != nil {
                    print(error!)
                    return
                }
            let docArray = snapshot!.documents
            print(docArray)
            for snap in snapshot!.documents {
                let title = snap.data()["title"] as! String
                let author = snap.data()["author"] as! String
                let coverImage = snap.data()["coverImage"]
                    as! String
                var imageUI: UIImage = UIImage(named: "defaultPhoto")!
                if (coverImage == ""){
                     books.append(Book(documentID: snap.documentID, title: title, image: coverImage, author: author, imageUI: imageUI)!)
                     print("appended book ")
                }else{
                    let storageRef = Storage.storage().reference(forURL: coverImage)
                    storageRef.downloadURL{ (url, error) in
                        if error != nil {
                            print(error!)
                            return
                        }
                        do{
                            let data = try Data(contentsOf: url!)
                            let image = UIImage(data: data)
                            imageUI = image!
                                books.append(Book(documentID: snap.documentID, title: title, image: coverImage, author: author, imageUI: imageUI)!)
                            print("appended book ")
                        }catch{
                            print(error)
                        }
                    }
                }
                if(snap == docArray.last){
                    self.addIndicator()
                    self.showIndicator()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.hideIndicator()
                        print("done")
                        let mainStoryBoard: UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
                        let protectedPage = mainStoryBoard.instantiateViewController(withIdentifier: "navController") as! UINavigationController
                        let appDelegate = UIApplication.shared.delegate
                        appDelegate?.window??.rootViewController = protectedPage
                    }
                }
            }
        }
    }
    
    func addIndicator(){
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.height)) as UIActivityIndicatorView
        //  indicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        activityIndicator.backgroundColor = UIColor.black
        activityIndicator.alpha = 0.75
    }
    
    func showIndicator(){
        //show the Indicator
        activityIndicator.startAnimating()
        window?.rootViewController?.view .addSubview(activityIndicator)
        
    }
    
    func hideIndicator(){
        //Hide the Indicator
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        return true
    }

    private func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url as URL?,
                                                 sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
}


//
//  UserInfoViewController.swift
//  MyMenu
//
//  Created by Vitalii Havryliuk on 6/7/18.
//  Copyright © 2018 Vitalii Havryliuk. All rights reserved.

import GoogleAPIClientForREST
import UIKit
import GoogleSignIn
import GTMSessionFetcher

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    //MARK: - Properties
    
    var user: GIDGoogleUser?
    private let service = GTLRSheetsService()
    let signInButton = GIDSignInButton()
    private let scopes = [kGTLRAuthScopeSheetsSpreadsheetsReadonly]
    var currentDay: Int = 0
    
    enum DayOfWeek: Int {
        case monday = 0
        case tuesday
        case wednesday
        case thursday
        case friday
    }
    
    //MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signInButton.isHidden = true
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signInSilently()
        if !GIDSignIn.sharedInstance().hasAuthInKeychain() {
            signInButton.isHidden = false
        }
        view.addSubview(signInButton)
        signInButton.frame.size.width = view.frame.size.width / 1.4
        signInButton.center = CGPoint(x: view.center.x, y: view.center.y)
        currentDay = getDayOfWeek()
    }
    
    func getDayOfWeek() -> Int {
        let todayDate = Date()
        let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let myComponents = myCalendar.component(.weekday, from: todayDate)
        return myComponents
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
            self.user = user
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            listMajors()
        }
    }
    
    func listMajors() {
        let spreadsheetId = "1O3XFddyj5jGpdAHQlacEx3knUPxSZuFqU56GdyKp3DI"
        var range: String
        switch currentDay {
        case 3: range = "tuesday"
        case 4: range = "wednesday"
        case 5: range = "thursday"
        case 6: range = "friday"
        default:range = "monday"
        }
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: spreadsheetId, range:range)
        service.executeQuery(
            query,
            delegate: self,
            didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:))
        )
    }
    
    @objc func displayResultWithTicket(ticket: GTLRServiceTicket, finishedWithObject result: GTLRSheets_ValueRange, error: NSError?) {
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        var isUserFound = false
        let rows = result.values! as! [[String]]
        var meals = [String]()
        for i in 0..<rows[0].count {
            if rows[i][0] == user?.profile.name {
                isUserFound = true
                for j in 0..<rows[i].count {
                    if rows[i][j] == "1" {
                        meals.append(rows[1][j])
                    }
                }
                break
            }
        }
        if isUserFound {
            if let navigationController = storyboard?.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController, let profileController = navigationController.topViewController as? ProfileTableViewController, let user = user {
                profileController.meals = meals
                profileController.user = user
                present(navigationController, animated: true) {
                    self.signInButton.isHidden = false
                }
            } else {
                showAlert(title: "Some problem with access(", message: "Please, try again later.")
            }
        } else {
            showAlert(title: "Can't find you in the list", message: "")
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }

}

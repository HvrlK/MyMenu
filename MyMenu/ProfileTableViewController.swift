//
//  ProfileTableViewController.swift
//  MyMenu
//
//  Created by Vitalii Havryliuk on 6/7/18.
//  Copyright © 2018 Vitalii Havryliuk. All rights reserved.
//

import UIKit
import GoogleSignIn

class ProfileTableViewController: UITableViewController {
    
    //MARK: - Properties
    
    var meals: [String]?
    var user: GIDGoogleUser?
    var isMealsEmpty = true
    
    //MARK: - Outlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    //MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = user {
            nameLabel.text = user.profile.name
            emailLabel.text = user.profile.email
            downloadImage(url: user.profile.imageURL(withDimension: 100))
        }
        if let meals = meals {
            isMealsEmpty = meals.isEmpty
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadImage(url: URL) {
        print("Download Started")
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.photoImageView.image = UIImage(data: data)
            }
        }
    }

    //MARK: - Actions
    
    @IBAction func signOutButtonTapped(_ sender: UIBarButtonItem) {
        GIDSignIn.sharedInstance().signOut()
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isMealsEmpty {
            return 1
        } else {
            return meals!.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MealCell", for: indexPath)
        if isMealsEmpty {
            cell.textLabel?.text = "List is empty..."
            cell.textLabel?.textAlignment = NSTextAlignment.center
            cell.textLabel?.alpha = 0.5
        } else {
            cell.textLabel?.text = meals![indexPath.row]
        }
        return cell
    }

}

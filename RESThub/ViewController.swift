//
//  ViewController.swift
//  RESThub
//
//  Created by Harrison on 7/25/19.
//  Copyright © 2019 Harrison. All rights reserved.
//
    
import UIKit

class ViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var feedTableView: UITableView!
    
    // MARK: Variables
    var feedGists: [Gist] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: GET a list of gists
        DataService.shared.fetchGists { (result) in
            DispatchQueue.main.async {
                switch result {
                    case .success(let gists):
                        
                        self.feedGists = gists
                        self.feedTableView.reloadData()
                        
                        for gist in gists {
                            print("\(gist)\n")
                        }
                    
                    case .failure(let error):
                        print(error)
                }
            }
        }
    }

    @IBAction func createNewGist(_ sender: UIButton) {
        // TODO: POST a new gist
        DataService.shared.createNewGist { (result) in
            DispatchQueue.main.async {
                switch result {
                    case .success(let json):
                        self.showResultAlert(title: "Yay!", message: "New post successfully created.")
                    case .failure(let error):
                        self.showResultAlert(title: "Oops", message: "Something went wrong...")
                }
            }
        }
    }
    
    // MARK: Utilities
    func showResultAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}

// MARK: UITableView Delegate & DataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feedGists.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedCellID", for: indexPath)
        
        let currentGist = self.feedGists[indexPath.row]
        cell.textLabel?.text = currentGist.description
        cell.detailTextLabel?.text = currentGist.id
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let currentGist = self.feedGists[indexPath.row]
        let starAction = UIContextualAction(style: .normal, title: "Star") { (action, view, completion) in
            
            // TODO: PUT a gist star
            DataService.shared.starUnstarGist(id: "\(currentGist.id!)", star: true) { (success) in
                
                DispatchQueue.main.async {
                    if success {
                        self.showResultAlert(title: "Success", message: "Gist successfully starred!")
                    } else {
                        self.showResultAlert(title: "Oops", message: "Something went wrong...")
                    }
                }
            }
            completion(true)
        }
        
        let unstarAction = UIContextualAction(style: .normal, title: "Unstar") { (action, view, completion) in
            
            // TODO: DELETE a gist star
            DataService.shared.starUnstarGist(id: "\(currentGist.id!)", star: false) { (success) in
                            
                DispatchQueue.main.async {
                    if success {
                        self.showResultAlert(title: "Success", message: "Gist successfully unstarred!")
                    } else {
                        self.showResultAlert(title: "Oops", message: "Something went wrong...")
                    }
                }
            }
            completion(true)
        }
        
        starAction.backgroundColor = .blue
        unstarAction.backgroundColor = .darkGray
        
        let actionConfig = UISwipeActionsConfiguration(actions: [unstarAction, starAction])
        return actionConfig
    }
    
}


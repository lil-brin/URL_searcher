//
//  ViewController.swift
//  developex_test
//
//  Created by Brin on 6/14/19.
//  Copyright © 2019 Brin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var threadsTextField: UITextField!
    @IBOutlet weak var searchingTextField: UITextField!
    @IBOutlet weak var scanDepthTextField: UITextField!
    @IBOutlet weak var searchButtonOutlet: UIButton!
    @IBOutlet weak var stopButtonOutlet: UIButton!
    @IBOutlet weak var searchTableView: UITableView!

    
    let searchService = SearchService()
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        searchButtonOutlet.isEnabled = false
        searchService.startSearch(startUrl: urlTextField.text!, threadsNumber: Int(threadsTextField.text!) ?? 1, searchingText: searchingTextField.text!, searchingDepth: Int(scanDepthTextField.text!) ?? 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func stopButtonPressed(_ sender: UIButton) {
//        searchService.urls.removeAll()
//        searchService.urlStatuses.removeAll()
//        searchTableView.reloadData()
        searchService.stopSearch()
        
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        searchService.delegate = self
    }
}


//some extensions
extension ViewController: SearchServiceDelegate {
    
    func didUpdateLinksDictionary() {
        searchTableView.reloadData()
    }
    
    func didFinishSearch() {
        searchButtonOutlet.isEnabled = true
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchService.urls.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if (cell == nil) {
            cell = UITableViewCell(style:UITableViewCell.CellStyle.value2, reuseIdentifier:"Cell")
        }
        let url = searchService.urls[indexPath.row]
        cell!.textLabel!.text = searchService.urlStatuses[url]
        cell!.detailTextLabel?.text = url
        return cell!
    }
}

extension UIViewController {
    func showAlert(message: String = "Something went wrong") {
        let title = "Oops :/"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

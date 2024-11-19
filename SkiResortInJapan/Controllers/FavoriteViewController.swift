//
//  FavoriteViewController.swift
//  SkiResortInJapan
//
//  Created by Adam Chen on 2024/11/14.
//

import UIKit

class FavoriteViewController: UIViewController {

    @IBOutlet weak var favoriteTableView: UITableView!
    
    var favoriteArray = [String]()
    var favoriteList = [SkiResort]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        favoriteTableView.delegate = self
        favoriteTableView.dataSource = self
        favoriteTableView.register(SkiResortTableViewCell.nib(), forCellReuseIdentifier: SkiResortTableViewCell.identifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        favoriteTableView.reloadData()
    }

}

extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SkiResortTableViewCell.identifier, for: indexPath) as! SkiResortTableViewCell
        cell.nameLabel.text = favoriteList[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let infoVC = storyboard?.instantiateViewController(withIdentifier: "InfoTableViewController") as! InfoTableViewController
        infoVC.skiResortInfo = favoriteList[indexPath.row]
        infoVC.isFavorite = true
        infoVC.favoriteArray = favoriteArray
        infoVC.favoriteList = favoriteList
        infoVC.delegate = self
        navigationController?.pushViewController(infoVC, animated: true)
    }
}

extension FavoriteViewController: InfoTableViewControllerDelegate {
    func infoTableViewController(_ controller: InfoTableViewController, didUpdateFavoriteArray newFavoriteArray: [String]) {
        favoriteArray = newFavoriteArray
        
        if let navController = tabBarController?.viewControllers?.first as? UINavigationController {
            if let skiResortViewController = navController.viewControllers.first as? SkiResortViewController {
                skiResortViewController.favoriteArray = favoriteArray
            }
        }
    }
    
    func infoTableViewController(_ controller: InfoTableViewController, didUpdateFavoriteList newFavoriteList: [SkiResort]) {
        favoriteList = newFavoriteList
        
        if let navController = tabBarController?.viewControllers?.first as? UINavigationController {
            if let skiResortViewController = navController.viewControllers.first as? SkiResortViewController {
                skiResortViewController.favoriteList = favoriteList
            }
        }
    }
}

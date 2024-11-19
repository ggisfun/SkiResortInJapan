//
//  SkiResortViewController.swift
//  SkiResortInJapan
//
//  Created by Adam Chen on 2024/11/14.
//

import UIKit

class SkiResortViewController: UIViewController {

    @IBOutlet weak var skiResortTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var skiResorts = [SkiResort]()
    var activityIndicator = UIActivityIndicatorView(style: .large)
    
    var favoriteArray = [String]()
    var favoriteList = [SkiResort]()
    var isFavorite: Bool = false
    
    var filteredSkiResorts = [SkiResort]() // 用於存儲搜尋結果
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        skiResortTableView.delegate = self
        skiResortTableView.dataSource = self
        skiResortTableView.register(SkiResortTableViewCell.nib(), forCellReuseIdentifier: SkiResortTableViewCell.identifier)
        
        searchBar.delegate = self
        searchBar.returnKeyType = .done
        
        //載入收藏資料
        if let favorites = SkiResort.loadFavorites() {
            favoriteArray = favorites
            print("load: \(favoriteArray)")
        }
        
        setupActivityIndicator()
        Task {
            await loadSkiResorts()
            setupFavoriteList()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func setupActivityIndicator() {
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    func loadSkiResorts() async {
        activityIndicator.startAnimating() // 開始顯示加載指示器
        
        do {
            skiResorts = try await NetworkService.shared.fetchSkiResorts()
            DispatchQueue.main.async {
                self.skiResortTableView.reloadData()
                self.activityIndicator.stopAnimating() // 加載結束，停止指示器
            }
        } catch {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating() // 在錯誤情況下停止指示器
            }
            print("發生錯誤：\(error.localizedDescription)")
        }
    }
    
    func setupFavoriteList() {
        favoriteList = favoriteArray.compactMap { favoriteName in
            skiResorts.first(where: { $0.name == favoriteName })
        }
        
        if let navController = tabBarController?.viewControllers?.last as? UINavigationController {
            if let favoriteController = navController.viewControllers.first as? FavoriteViewController {
                favoriteController.favoriteArray = favoriteArray
                favoriteController.favoriteList = favoriteList
            }
        }
    }

}

extension SkiResortViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredSkiResorts.count : skiResorts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SkiResortTableViewCell.identifier, for: indexPath) as! SkiResortTableViewCell
        let skiResort = isSearching ? filteredSkiResorts[indexPath.row] : skiResorts[indexPath.row]
        cell.nameLabel.text = skiResort.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        let infoVC = storyboard?.instantiateViewController(withIdentifier: "InfoTableViewController") as! InfoTableViewController
        
        // 根據是否在搜尋狀態選擇正確的資料來源
        let selectedSkiResort = isSearching ? filteredSkiResorts[indexPath.row] : skiResorts[indexPath.row]
        isFavorite = favoriteArray.contains(selectedSkiResort.name)
        
        infoVC.skiResortInfo = selectedSkiResort
        infoVC.isFavorite = isFavorite
        infoVC.favoriteArray = favoriteArray
        infoVC.favoriteList = favoriteList
        infoVC.delegate = self
        navigationController?.pushViewController(infoVC, animated: true)
    }
}

extension SkiResortViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredSkiResorts = skiResorts
        } else {
            isSearching = true
            filteredSkiResorts = skiResorts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        skiResortTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // 收起鍵盤
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchBar.text = ""
        skiResortTableView.reloadData()
        searchBar.resignFirstResponder() // 隱藏鍵盤
    }
    
}

extension SkiResortViewController: InfoTableViewControllerDelegate {
    func infoTableViewController(_ controller: InfoTableViewController, didUpdateFavoriteArray newFavoriteArray: [String]) {
        favoriteArray = newFavoriteArray
        
        if let navController = tabBarController?.viewControllers?.last as? UINavigationController {
            if let favoriteController = navController.viewControllers.first as? FavoriteViewController {
                favoriteController.favoriteArray = favoriteArray
            }
        }
    }
    
    func infoTableViewController(_ controller: InfoTableViewController, didUpdateFavoriteList newFavoriteList: [SkiResort]) {
        favoriteList = newFavoriteList
        if let navController = tabBarController?.viewControllers?.last as? UINavigationController {
            if let favoriteController = navController.viewControllers.first as? FavoriteViewController {
                favoriteController.favoriteList = favoriteList
            }
        }
    }
}



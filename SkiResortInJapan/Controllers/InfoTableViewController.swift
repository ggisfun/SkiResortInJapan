//
//  InfoTableViewController.swift
//  SkiResortInJapan
//
//  Created by Adam Chen on 2024/11/14.
//

import UIKit
import Kingfisher

class InfoTableViewController: UITableViewController {

    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var elevationLabel: UILabel!
    @IBOutlet weak var trailCountLabel: UILabel!
    @IBOutlet weak var maxSlopeLabel: UILabel!
    @IBOutlet weak var liftCountLabel: UILabel!
    @IBOutlet weak var longestRunLabel: UILabel!
    @IBOutlet weak var infobgView: UIView!
    @IBOutlet weak var difficultyLabelView: UIView!
    @IBOutlet weak var compositionLabelView: UIView!
    @IBOutlet weak var trailDifficultyView: UIView!
    @IBOutlet weak var trailCompositionView: UIView!
    
    weak var delegate: InfoTableViewControllerDelegate?
    
    var skiResortInfo : SkiResort!
    var favoriteArray = [String]()
    var favoriteList = [SkiResort]()
    
    var isFavorite: Bool = false
    var heartButton = UIBarButtonItem()
    var houseButton = UIBarButtonItem()
    
    var difficultyLabels: [String] = ["初級", "中級", "高級"]
    var compositionLabels: [String] = ["壓雪", "非壓雪"]
    let difficultyColors = [
        UIColor.systemGreen.withAlphaComponent(0.6),  // 淡綠色
        UIColor.systemBlue.withAlphaComponent(0.6),   // 淡藍色
        UIColor.systemRed.withAlphaComponent(0.6)     // 淡紅色
    ]
    let compositionColors = [
        UIColor.systemYellow.withAlphaComponent(0.6),
        UIColor.systemOrange.withAlphaComponent(0.6)
    ]
    
    var mapImageHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundView = UIImageView(image: UIImage(named: "snow"))
        tableView.backgroundView?.contentMode = .scaleAspectFill
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationItem.title = skiResortInfo.name
        
        infobgView.backgroundColor = UIColor(white: 1, alpha: 0.7)
        infobgView.layer.cornerRadius = 5
        descriptionTextView.backgroundColor = UIColor(white: 1, alpha: 0.7)
        descriptionTextView.layer.cornerRadius = 5
        
        mapImageView.kf.indicatorType = .activity
        mapImageView.kf.setImage(with: URL(string: skiResortInfo.mapUrl)) { result in
            switch result {
            case .success(let value):
                // 取得下載圖片的原始大小
                let originalSize = value.image.size
                print("圖片原始大小：\(originalSize.width) x \(originalSize.height)")
                
                // 計算縮放後的高度
                let widthRatio = (self.tableView.frame.width-10) / originalSize.width
                self.mapImageHeight = originalSize.height * widthRatio
                
                // 更新表格
                DispatchQueue.main.async {
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                }
                
            case .failure(let error):
                print("圖片加載失敗：\(error.localizedDescription)")
            }
        }
        
        descriptionTextView.text = skiResortInfo.description
        elevationLabel.text = "標高: \(skiResortInfo.elevation)m"
        trailCountLabel.text = "雪道數量: \(skiResortInfo.trailCount)"
        maxSlopeLabel.text = "最大坡度: \(skiResortInfo.maxSlope)°"
        liftCountLabel.text = "纜車數量: \(skiResortInfo.liftCount)"
        longestRunLabel.text = "最長滑行距離: \(skiResortInfo.longestRun)m"
        
        difficultyLabelView.backgroundColor = UIColor(white: 1, alpha: 0.7)
        compositionLabelView.backgroundColor = UIColor(white: 1, alpha: 0.7)
        difficultyLabelView.layer.cornerRadius = 5
        compositionLabelView.layer.cornerRadius = 5
        difficultyLabelView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        compositionLabelView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        trailDifficultyView.backgroundColor = UIColor(white: 1, alpha: 0.7)
        trailCompositionView.backgroundColor = UIColor(white: 1, alpha: 0.7)
        trailDifficultyView.layer.cornerRadius = 5
        trailCompositionView.layer.cornerRadius = 5
        trailDifficultyView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        trailCompositionView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        configureItems()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapMapImageView))
        mapImageView.isUserInteractionEnabled = true
        mapImageView.addGestureRecognizer(tapGesture)
        
    }
    
    override func viewDidLayoutSubviews() {
        let difficultyPercent = [
            skiResortInfo.trailDifficulty.beginner,
            skiResortInfo.trailDifficulty.intermediate,
            skiResortInfo.trailDifficulty.advanced
        ]
        
        let compositionPercent = [
            skiResortInfo.trailComposition.groomed,
            skiResortInfo.trailComposition.ungroomed
        ]
        
        drawPieChart(on: trailDifficultyView, with: difficultyPercent, labels: difficultyLabels, colors: difficultyColors)
        drawPieChart(on: trailCompositionView, with: compositionPercent, labels: compositionLabels, colors: compositionColors)
    }
    
    @objc func didTapMapImageView() {
        let zoomViewController = ImageZoomViewController()
        zoomViewController.image = mapImageView.image
        zoomViewController.modalPresentationStyle = .fullScreen
        present(zoomViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return mapImageHeight > 0 ? mapImageHeight : tableView.frame.width * 0.7
        }
        return UITableView.automaticDimension
    }
    
    func drawPieChart(on view: UIView, with data: [Double], labels: [String], colors: [UIColor]) {
        let total = data.reduce(0, +)
        var startAngle: CGFloat = -.pi / 2
        
        for (index, value) in data.enumerated() {
            let endAngle = startAngle + CGFloat(value / total) * 2 * .pi
            let path = UIBezierPath()
            path.move(to: CGPoint(x: view.bounds.midX, y: view.bounds.midY))
            path.addArc(withCenter: CGPoint(x: view.bounds.midX, y: view.bounds.midY),
                        radius: (view.bounds.width - 4) / 2,
                        startAngle: startAngle,
                        endAngle: endAngle,
                        clockwise: true)
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.fillColor = colors[index % colors.count].cgColor // 使用固定顏色
            
            view.layer.addSublayer(shapeLayer)
            
            // 計算標籤位置
            let middleAngle = (startAngle + endAngle) / 2
            //let radius = min(view.bounds.width, view.bounds.height) / 2
            let radius = view.bounds.width / 2 * 0.6 // 調整半徑以將標籤放置在內圈
            let labelX = view.bounds.midX + radius * cos(middleAngle)
            let labelY = view.bounds.midY + radius * sin(middleAngle)
            
            let label = UILabel()
            label.textColor = .black
            label.text = "\(labels[index])\n\(Int(value))%" // 格式化顯示名稱和數值
            label.font = UIFont.systemFont(ofSize: 14)
            label.textAlignment = .center
            label.numberOfLines = 0 // 設置標籤為多行
            label.sizeToFit()
            label.center = CGPoint(x: labelX, y: labelY)
            
            // 檢查標籤是否超出邊界，調整位置或縮小文字
            if label.frame.maxX > view.bounds.width || label.frame.maxY > view.bounds.height {
                label.font = UIFont.systemFont(ofSize: 12)
                label.sizeToFit()
                label.center = CGPoint(x: labelX, y: labelY)
            }
            
            view.addSubview(label)
            
            startAngle = endAngle
        }
    }
    
    private func configureItems() {
        let heartImageName = isFavorite ? "heart.fill" : "heart"
        heartButton = UIBarButtonItem(image: UIImage(systemName: heartImageName), style: .done, target: self, action: #selector(toggleFavorite))
        houseButton = UIBarButtonItem(image: UIImage(systemName: "house.fill"), style: .plain, target: self, action: #selector(openWebsite))
        heartButton.tintColor = isFavorite ? UIColor.systemPink : UIColor.black
        houseButton.tintColor = UIColor.black
        navigationItem.rightBarButtonItems = [heartButton, houseButton]
    }
    
    @objc func toggleFavorite() {
        if !isFavorite {
            if !favoriteArray.contains(skiResortInfo.name) {
                isFavorite.toggle()
                updateHeartButtonImage()
                
                favoriteArray.append(skiResortInfo.name)
                favoriteList.append(skiResortInfo)
                
                delegate?.infoTableViewController(self, didUpdateFavoriteArray: favoriteArray)
                delegate?.infoTableViewController(self, didUpdateFavoriteList: favoriteList)
                
                DispatchQueue.main.async {
                    SkiResort.saveFavorites(self.favoriteArray)
                }
                
                showAlert(title: "已加入收藏", message: nil, autoDismiss: true)
            }
        } else {
            let controller = UIAlertController(title: "從收藏中移除嗎？", message: nil, preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "確定", style: .default) { _ in
                self.isFavorite.toggle()
                self.updateHeartButtonImage()
                
                self.favoriteArray.removeAll(where: { $0 == self.skiResortInfo.name })
                self.favoriteList.removeAll(where: { $0.name == self.skiResortInfo.name })
                
                self.delegate?.infoTableViewController(self, didUpdateFavoriteArray: self.favoriteArray)
                self.delegate?.infoTableViewController(self, didUpdateFavoriteList: self.favoriteList)
                
                DispatchQueue.main.async {
                    SkiResort.saveFavorites(self.favoriteArray)
                }
                
                self.showAlert(title: "已移除收藏", message: nil, autoDismiss: true)
            }
            let cancelAction = UIAlertAction(title: "取消", style: .cancel)
            controller.addAction(confirmAction)
            controller.addAction(cancelAction)
            present(controller, animated: true)
        }
        
    }
    
    func updateHeartButtonImage() {
        let updatedImageName = isFavorite ? "heart.fill" : "heart"
        heartButton.tintColor = isFavorite ? UIColor.systemPink : UIColor.black
        heartButton.image = UIImage(systemName: updatedImageName)
    }
    
    func showAlert(title: String, message: String?, autoDismiss: Bool = false) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "好的", style: .default)
        controller.addAction(okAction)
        
        present(controller, animated: true) {
            if autoDismiss {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    controller.dismiss(animated: true)
                }
            }
        }
    }
    
    @objc private func openWebsite() {
        if let url = URL(string: skiResortInfo.websiteUrl) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

}

protocol InfoTableViewControllerDelegate: AnyObject {
    func infoTableViewController(_ controller: InfoTableViewController, didUpdateFavoriteArray newFavoriteArray: [String])
    func infoTableViewController(_ controller: InfoTableViewController, didUpdateFavoriteList newFavoriteList: [SkiResort])
}


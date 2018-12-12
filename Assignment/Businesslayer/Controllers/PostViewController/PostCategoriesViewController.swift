//
//  PostCategoriesViewController.swift
//  Assignment
//
//  Created by Dev on 12/12/18.
//  Copyright © 2018 Dev. All rights reserved.
//

import UIKit

class PostCategoriesViewController: UIViewController {
    var arrIndexSelect : [Int] = []
    var strCategoriesHandler: (([Int]) -> Void)?
    @IBOutlet weak var collCatgeories: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if arrIndexSelect.count == 0{
            self.collCatgeories.reloadData()
        }
    }
    
    
    //MARK:- button actions
    @IBAction func actionBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func actionSelect(_ sender: Any) {
        if self.arrIndexSelect.count == 0{
            NSUtility.showAlertWithTitle(title:KErrorTitle, message: KErrorPostCategory, controller: self)
            return 
        }
        if let callback = self.strCategoriesHandler {
            callback (arrIndexSelect)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
extension PostCategoriesViewController:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 40
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollCell", for: indexPath) as! CategoryCollCell
        var serialNumber = "0"
        serialNumber = (indexPath.row+1) < 10 ? "00\(indexPath.row+1)" : "0\(indexPath.row+1)"
        cell.lblNumber.text = "C \(serialNumber)"
        cell.lblNumberBack.text = "C \(serialNumber)"
        cell.showingBack = true
        if arrIndexSelect.contains(indexPath.row){
            cell.showingBack = false
        }
        self.flipCell(cell: cell, withAnimation: false)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: KScreenWidth/3-1, height: KScreenWidth/3-1)
    }
    func flipCell(cell:CategoryCollCell,withAnimation:Bool){
        let toView = cell.showingBack ? cell.viewFront : cell.viewBack
        let fromView = cell.showingBack ? cell.viewBack : cell.viewFront
        //  let newView = fromView
        let transitionOptions: UIView.AnimationOptions = cell.showingBack ? [.transitionFlipFromLeft, .showHideTransitionViews] : [.transitionFlipFromRight, .showHideTransitionViews]
        
        UIView.transition(with: fromView!, duration: withAnimation ? 1.0 : 0, options: transitionOptions, animations: {
            fromView?.alpha = 0
        })
        
        UIView.transition(with: toView!, duration: withAnimation ? 1.0 : 0, options: transitionOptions, animations: {
            toView?.alpha = 1
        })
        
        //    toView?.translatesAutoresizingMaskIntoConstraints = false
        
        cell.showingBack = !cell.showingBack
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CategoryCollCell
        if arrIndexSelect.count >= 3 && !arrIndexSelect.contains(indexPath.row){
            NSUtility.showAlertWithTitle(title: KErrorTitle, message: KErrorUpto3Categories, controller: self)
            return
        }
        
        self.flipCell(cell: cell, withAnimation: true)
        if !arrIndexSelect.contains(indexPath.row){
            
            arrIndexSelect.append(indexPath.row)
        }
        else{
            let index = arrIndexSelect.index(where: { number -> Bool in
                number == indexPath.row
                
            })
            if index != nil{
                arrIndexSelect.remove(at: index!)
            }
            
            
        }
    }
}
class CategoryCollCell : UICollectionViewCell{
    var showingBack = false
    @IBOutlet weak var viewBack: UIView!
    @IBOutlet weak var viewFront: UIView!
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var lblNumberBack: UILabel!
}

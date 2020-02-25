//
//
// UICollectionView+Extension.swift
// GroceryList
//
// Oragnizstion: zapbuild
// Created By: zapbuild on 12/06/19
// Swift Version: 5.0
//Copyright © 2019 zapbuild. All rights reserved.
//  
//
//
    

import Foundation
import UIKit
extension UICollectionView {
    /**
     Register cell nib without identifier
     */
    func registerNib<Cell: UICollectionViewCell>(cell: Cell.Type) {
        let nibName = String(describing: Cell.self)
        register(UINib(nibName: nibName, bundle: nil), forCellWithReuseIdentifier: nibName)
        
    }
    
    /**
     Dequeue registered cell
     */
    func dequeue<Cell: UICollectionViewCell>(indexPath:IndexPath) -> Cell {
        let identifier = String(describing: Cell.self)
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? Cell else {
            fatalError("Error in cell")
        }
        return cell
    }

}

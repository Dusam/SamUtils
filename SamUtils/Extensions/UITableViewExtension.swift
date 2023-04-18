//
//  UITableViewExtension.swift
//  AbnormalStatistics
//
//  Created by 杜千煜 on 2023/4/18.
//

import Foundation
import SwifterSwift

extension UITableView {
    var snapshotLongImage: UIImage? {
        let savedContentOffset = contentOffset
        let savedFrame = frame
        
        let imageHeight = contentSize.height
        var screensInTable = 0
        
        if (frame.size.height != 0) {
            screensInTable = Int(ceil(imageHeight / frame.size.height))
        }
                
        let imageSize = CGSize(width: frame.size.width, height: imageHeight)
        UIGraphicsBeginImageContextWithOptions(imageSize, false, UIScreen.main.scale)
        
        frame = CGRect(x: 0, y: 0, width: contentSize.width, height: imageHeight)
        
        let oldBounds = layer.bounds
        
        if #available(iOS 15, *) {
            //iOS 15 需要改變 tableview 的 bounds
            layer.bounds = CGRect(x: oldBounds.origin.x,
                                  y: oldBounds.origin.y,
                                  width: contentSize.width,
                                  height: contentSize.height)
            
            // 偏移量歸零
            contentOffset = CGPoint.zero
            // frame 變為 contentSize
            frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
        }
        
        for i in 0..<screensInTable {
            let contentOffset = CGPoint(x: CGFloat(0), y: CGFloat(i) * frame.size.height)
            setContentOffset(contentOffset, animated: false)
            
            if let context = UIGraphicsGetCurrentContext() {
                layer.render(in: context)
            }
        }
        
        if #available(iOS 15, *) {
            layer.bounds = oldBounds
        }
        
        frame = savedFrame
        setContentOffset(savedContentOffset, animated: false)
        
        // use SwifterSwift method
        return snapshot
    }
    
}

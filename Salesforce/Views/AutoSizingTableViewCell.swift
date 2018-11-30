//
//  AutoSizingTableViewCell.swift
//  Salesforce
//
//  Created by Bindu on 11/27/18.
//  Copyright © 2018 Sandeep. All rights reserved.
//

import UIKit

protocol AutoSizingTableViewCellDelegate {
    func resized(height: CGFloat, modifiedText: String, editedIndexPath: IndexPath?)
}

class AutoSizingTableViewCell: UITableViewCell {
    
    var delegate: AutoSizingTableViewCellDelegate?
    
    // INTITAL BAD DESIGN DECISION LEAD TO THIS WIERED STATE. :(
    var indexPath: IndexPath?
    
    @IBOutlet weak var textView: UITextView!

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        textView.delegate = self
    }
}

extension AutoSizingTableViewCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        let height = self.calculateHeight(withBaseHeight: 200)
       
        delegate?.resized(height: height, modifiedText: textView.text, editedIndexPath: indexPath)
    }
}

fileprivate extension AutoSizingTableViewCell {
    
    func calculateHeight(withBaseHeight: CGFloat) -> CGFloat {
        
        let fixedWidth = frame.size.width
        let newSize = sizeThatFits(CGSize(width: fixedWidth, height: .greatestFiniteMagnitude))
        var newFrame = frame
        
        let height: CGFloat = newSize.height > withBaseHeight ? newSize.height : withBaseHeight
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: height)
        
        return newFrame.height
    }
    
}



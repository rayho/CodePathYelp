//
//  ResultCell.swift
//  CodePathYelp
//
//  Created by Ray Ho on 9/20/14.
//  Copyright (c) 2014 Prime Rib Software. All rights reserved.
//

import UIKit

class ResultCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var ratingView: UIImageView!
    @IBOutlet weak var ratingWidth: NSLayoutConstraint!
    @IBOutlet weak var ratingHeight: NSLayoutConstraint!
    @IBOutlet weak var reviewCountView: UILabel!
    @IBOutlet weak var addressView: UILabel!
    @IBOutlet weak var categoriesView: UILabel!

    func populate(business: NSDictionary) {
        // Name
        let name: NSString = business.valueForKey("name") as NSString
        titleLabel.text = name

        // Thumbnail
        let imageUrl: NSString? = business.valueForKey("image_url") as NSString?
        if (imageUrl != nil) {
            thumbnailView.setImageWithURL(NSURL.URLWithString(imageUrl!))
        } else {
            thumbnailView.image = nil
        }

        // Rating: Use properly scaled image
        var ratingUrl: NSString!
        let screenScale: CGFloat = UIScreen.mainScreen().scale
        if (screenScale > 1) {
            ratingUrl = business.valueForKey("rating_img_url_large") as NSString
            ratingWidth.constant = 83
            ratingHeight.constant = 15
        } else {
            ratingUrl = business.valueForKey("rating_img_url") as NSString
            ratingWidth.constant = 84
            ratingHeight.constant = 17
        }
        ratingView.setImageWithURL(NSURL.URLWithString(ratingUrl))

        // Review count
        let reviewCountNumber: Int = business.valueForKey("review_count") as Int
        reviewCountView.text = NSString(format:
            NSLocalizedString("REVIEW_COUNT",  comment: ""), reviewCountNumber)

        // Address
        let location: NSDictionary = business.valueForKey("location") as NSDictionary
        let displayAddress: NSArray = location.valueForKey("display_address") as NSArray
        let displayAddressSecondToLastIndex = displayAddress.count - 2
        var formattedAddress: String = ""
        for var i = 0; i <= displayAddressSecondToLastIndex; i++ {
            let address: NSString = displayAddress[i] as NSString
            formattedAddress += address
            if (i < displayAddressSecondToLastIndex) {
                formattedAddress += ", "
            }
        }
        addressView.text = formattedAddress

        // Categories
        var formattedCategories: String = ""
        let categories: NSArray? = business.valueForKey("categories") as NSArray?
        if (categories != nil) {
            for var i = 0; i < categories!.count; i++ {
                let category: NSArray = categories![i] as NSArray
                let categoryName: NSString = category[0] as NSString
                formattedCategories += categoryName
                if (i < (categories!.count - 1)) {
                    formattedCategories += ", "
                }
            }
        }
        categoriesView.text = formattedCategories
    }
}
//
//  FiltersController.swift
//  CodePathYelp
//
//  Created by Ray Ho on 9/23/14.
//  Copyright (c) 2014 Prime Rib Software. All rights reserved.
//

import UIKit

class FiltersController: UIViewController {

    @IBOutlet weak var sortSegments: UISegmentedControl!
    @IBOutlet weak var dealSwitch: UISwitch!
    @IBOutlet weak var radiusSlider: UISlider!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        sortSegments.selectedSegmentIndex = YELP.sort
        dealSwitch.on = YELP.dealsFilter
        radiusSlider.value = Float(YELP.radius)
    }

    override func viewWillDisappear(animated: Bool) {
        YELP.sort = sortSegments.selectedSegmentIndex
        YELP.dealsFilter = dealSwitch.on
        YELP.radius = Int(radiusSlider.value)
    }
}

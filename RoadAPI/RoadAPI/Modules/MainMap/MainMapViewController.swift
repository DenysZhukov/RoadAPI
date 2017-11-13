//
//  MainMapViewController.swift
//  RoadAPI
//
//  Created by Denys on 11/14/17.
//  Copyright (c) 2017 Denys Zhukov. All rights reserved.
//

import UIKit

class MainMapViewController: UIViewController  {
    //MARK: - Properties
    var presenter:  MainMapPresenter!
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
    }
    
    //MARK: - UI
    
    private func configureInterface() {
        localizeViews()
    }
    
    private func localizeViews() {
    }
}

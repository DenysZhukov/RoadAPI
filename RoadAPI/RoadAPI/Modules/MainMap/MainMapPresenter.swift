//
//  MainMapPresenter.swift
//  RoadAPI
//
//  Created by Denys on 11/14/17.
//  Copyright (c) 2017 Denys Zhukov. All rights reserved.
//

import UIKit

class MainMapPresenter {
    
    //MARK: - Init
    required init(controller: MainMapViewController,
                  interactor: MainMapInteractor,
                  coordinator: MainMapCoordinator) {
        self.coordinator = coordinator
        self.controller = controller
        self.interactor = interactor
    }
    
    //MARK: - Private -
    fileprivate let coordinator: MainMapCoordinator
    fileprivate unowned var controller: MainMapViewController
    fileprivate var interactor: MainMapInteractor
}

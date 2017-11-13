//
//  MainMapWireframe.swift
//  RoadAPI
//
//  Created by Denys on 11/14/17.
//  Copyright (c) 2017 Denys Zhukov. All rights reserved.
//

import Foundation

typealias MainMapConfiguration = (MainMapPresenter) -> Void

class MainMapWireframe {
    class func setup(_ viewController: MainMapViewController,
                     withCoordinator coordinator: MainMapCoordinator,
                     configutation: MainMapConfiguration? = nil) {
        let interactor = MainMapInteractor()
        let presenter = MainMapPresenter(controller: viewController,
                                                          interactor: interactor,
                                                          coordinator: coordinator)
        viewController.presenter = presenter
        interactor.presenter = presenter
        configutation?(presenter)
    }
}

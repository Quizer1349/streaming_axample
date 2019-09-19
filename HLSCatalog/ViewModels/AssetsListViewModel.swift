//
//  AssetsListViewModel.swift
//  HLSCatalog
//
//  Created by Alex Sklyarenko on 9/19/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation

protocol AssetsListViewModelDelegate: class {
    func assetListManagerDidLoad()
}

class AssetsListViewModel {
    weak var delegate: AssetsListViewModelDelegate?
    
    init() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAssetListManagerDidLoad(_:)),
                                               name: .AssetListManagerDidLoad, object: nil)
        fetchAssets()
    }
    
    
    // MARK: Deinitialization
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: .AssetListManagerDidLoad,
                                                  object: nil)
    }

    // MARK: Data Source
    func numberOfAssets() -> Int {
        return AssetListManager.sharedManager.numberOfAssets()
    }
    
    func asset(at: Int) -> Asset {
        return AssetListManager.sharedManager.asset(at: at)
    }
    
    // MARK: - Private
    // TODO: Add detching state
    func fetchAssets() {
        Networking.request(endpoint: .media(itemId: 2889), params: nil) { (result: Result<MediaModel, NetError>) in
            switch result {
            case .success(let media):
                guard let stream = media.convertToStream() else {
                    return
                }
                StreamListManager.shared.streams.append(stream)
                // Restore the state of the application and any running downloads.
                AssetPersistenceManager.sharedManager.restorePersistenceManager()
            case .failure(let error):
                print(error)
            }
        }
    }
}

// MARK: - Notification handling
extension AssetsListViewModel {
    @objc
    func handleAssetListManagerDidLoad(_: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.assetListManagerDidLoad()
        }
    }
}

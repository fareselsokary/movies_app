import Foundation
import Kingfisher

// AppConfigurator.swift
enum AppConfigurator {
    static func configure() {
        configureLogger()
        configureNetwork()
        configureNetworkListener()
        configureImageCache()
    }

    private static func configureLogger() {
        #if !DEBUG
            Logger.isLoggingEnabled = false
        #endif
    }

    private static func configureNetwork() {
        let config = NetworkConfiguration.shared
        config.baseURL = Bundle.main.object(forInfoDictionaryKey: .baseURL)
        let apiKey = Bundle.main.object(forInfoDictionaryKey: .apiKey)
        config.defaultHeaders = [
            "Authorization": "Bearer \(apiKey)",
            "accept": "application/json"
        ]
    }

    private static func configureNetworkListener() {
        NetworkReachability.shared.start()
    }

    private static func configureImageCache() {
        let cache = KingfisherManager.shared.cache
        cache.diskStorage.config.sizeLimit = 500 * 1024 * 1024
        cache.memoryStorage.config.totalCostLimit = 150 * 1024 * 1024
        cache.memoryStorage.config.countLimit = 50
        cache.memoryStorage.config.expiration = .seconds(10 * 60)
        cache.diskStorage.config.expiration = .days(7)
    }
}

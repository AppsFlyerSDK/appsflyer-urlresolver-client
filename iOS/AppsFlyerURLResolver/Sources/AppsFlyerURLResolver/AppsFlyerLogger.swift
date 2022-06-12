//
//  AppsFlyerLogger.swift
//  AppsFlyerURLResolver
//
//  Created by Amit Kremer on 12/06/2022.
//

import Foundation

protocol AppsFlyerLogger {
  func logDebug(_ msg:String)
  func logError(_ msg:String)
}


class AFLogger : AppsFlyerLogger {
    private var isDebug : Bool
    
    public init(isDebug: Bool = false) {
      self.isDebug = isDebug
    }
    
    func logDebug(_ msg:String) {
        if isDebug{
            NSLog("AppsFlyer URL Resolver [Debug]: \(msg)")
        }
    }
    
    func logError(_ msg:String) {
        NSLog("AppsFlyer URL Resolver [Error]: \(msg)")
    }
}

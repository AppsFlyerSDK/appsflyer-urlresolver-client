//
//  URLResolver.swift
//  AFExample
//
//  Created by Paz Lavi  on 06/09/2021.
//

import Foundation

protocol AppsFlyerLogger {
    func logDebug(_ msg:String)
    func logError(_ msg:String)
}

struct afLogger: AppsFlyerLogger {
    private let isDebug : Bool
    
    init(isDebug: Bool = false) {
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

public final class URLResolver: NSObject {
    
    private let isDebug : Bool
    private let logger: AppsFlyerLogger
    
    private var redirects : [String] = []
    private var maxRedirections : Int = 10
    
    
    public init(isDebug: Bool = false) {
        self.isDebug = isDebug
        self.logger = afLogger(isDebug: isDebug)
    }
    
    public func resolve(url: String?, maxRedirections: Int = 10 , completionHandler :  @escaping (String?) -> Void) {
        guard let url = url else  {
            completionHandler(nil)
            return
        }
        
        guard let encoded = encodeAndValidateUrl(url: url) else {
            completionHandler(url)
            return
        }
        
        self.logger.logDebug("Resolving URL: \(url)")
        self.redirects = [encoded]
        self.maxRedirections = maxRedirections
        resolveInternal(completionHandler: completionHandler)
    }
    
    public func resolveJSRedirection(url: String?, completionHandler :  @escaping (String?) -> Void) {
        guard let url = url else  {
            completionHandler(nil)
            return
        }
        
        guard let encoded = encodeAndValidateUrl(url: url) else {
            completionHandler(nil)
            return
        }
        self.logger.logDebug("Resolving URL: \(encoded)")
        let jsResolver = JSRedirectionHandler(logger: self.logger, redirectionCompletionHandler: completionHandler)
        jsResolver.resolveJSRedirection(withUrl: encoded)
    }
    
    private func encodeAndValidateUrl(url: String) -> String?{
        // MI link contains '%%' symbols as a query param place holder. In iOS this scheme is not allowed.
        // Hance, we have to encode the query part to be in a valid Percent-encoding.
        guard let encoded = url.encodeUrl() else {
            return nil
        }
        // check we got valid URL, if not we'll return the input
        if !encoded.isValidURL() {
            return nil
        }
        return encoded
    }
    
    private func resolveInternal( completionHandler: @escaping (String?) -> Void) {
        guard let uri = self.redirects.last else {
            completionHandler(nil)
            return
        }
        
        guard let url = URL(string: uri) else {
            self.logger.logDebug("Could no create URL object for \(uri)")
            completionHandler(nil)
            return
        }
        
        let request = URLRequest(url: url)
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        
        session.dataTask(with: request) {(data, response, error) in
            if let err = error {
                self.logger.logError(err.localizedDescription)
                completionHandler(nil)
                return
            }
            
            if let response = response {
                if let url = response.url {
                    self.logger.logDebug("Found URL: \(url.absoluteString)")
                    //return the last URL to the developer
                    completionHandler(url.absoluteString)
                } else {
                    self.logger.logError("No url in response")
                    completionHandler(nil)
                }
            }
        }.resume()
    }
}

// MARK: URL Delegate
extension URLResolver: URLSessionTaskDelegate {
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        if (300...308).contains(response.statusCode ){ // has a redirection
            guard let urlString = request.url?.absoluteString else {
                completionHandler(nil)
                return
            }
            
            self.redirects.append(urlString)
            self.logger.logDebug("Redirect to \(urlString)")
            
            if self.redirects.count == self.maxRedirections {
                completionHandler(nil)
                return
            }
            // Regular iOS URL SESSION behavior - countinue resolving
            completionHandler(request)
        } else {
            completionHandler(nil)
        }
    }
}

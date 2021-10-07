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


public class URLResolver: NSObject {
  private var redirects : [String] = []
  private var maxRedirections : Int = 10
  private var isDebug : Bool = false
  
  init(isDebug: Bool = false) {
    self.isDebug = isDebug
  }
 
  public func resolve(url: String?, maxRedirections: Int = 10 , completionHandler :  @escaping (String?) -> Void) {
    guard let url = url else  {
      completionHandler(nil)
      return
    }
    // MI link contains '%%' symbols as a query param place holder. In iOS this scheme is not allowed.
    // Hance, we have to encode the query part to be in a valid Percent-encoding.
    guard let encoded = url.encodeUrl() else {
      completionHandler(url)
      return
    }
    // check we got valid URL, if not we'll return the input
    if !encoded.isValidURL() {
      completionHandler(url)
      return
    }
    
    print("RETURN AFTER INVALID URL")
    
    logDebug("Resolving URL: \(url)")
    self.redirects = [encoded]
    self.maxRedirections = maxRedirections
    resolveInternal(completionHandler: completionHandler)
  }
  
  private func resolveInternal( completionHandler: @escaping (String?) -> Void) {
    guard let uri = self.redirects.last else {
      completionHandler(nil)
      return
    }
    
    guard let url = URL(string: uri) else {
      self.logDebug("Could no create URL object for \(uri)")
      completionHandler(nil)
      return
    }
    
    let request = URLRequest(url: url)
    let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    
    session.dataTask(with: request) {(data, response, error) in
      if let err = error {
        self.logError(err.localizedDescription)
        completionHandler(nil)
        return
      }
      
      if let response = response {
        if let url = response.url {
          self.logDebug("Found URL: \(url.absoluteString)")
          //return the last URL to the developer
          completionHandler(url.absoluteString)
        } else {
          self.logError("No url in response")
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
      self.logDebug("Redirect to \(urlString)")
      
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

// MARK: Logger
extension URLResolver : AppsFlyerLogger {
  func logDebug(_ msg:String) {
    if isDebug{
      NSLog("AppsFlyer URL Resolver [Debug]: \(msg)")
    }
  }
  
  func logError(_ msg:String) {
    NSLog("AppsFlyer URL Resolver [Error]: \(msg)")
  }
}

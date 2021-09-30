//
//  URLResolver.swift
//  AFExample
//
//  Created by Paz Lavi  on 06/09/2021.
//

import Foundation

public class URLResolver: NSObject {
    private var redirects : [String] = []
    private var maxRedirections : Int = 10
    private var isDebug : Bool = false
    
    
    public func setDebug(_ isDebug : Bool) -> URLResolver{
        self.isDebug = isDebug
        return self
    }
    
    public func resolve(url: String?, maxRedirections: Int = 10 , completionHandler :  @escaping (String?) -> Void)  {
        if url == nil  {
            completionHandler(url)
            return
        }
        // MI link contains '%%' symbols as a query param place holder. In iOS this scheme is not allowed.
        // Hance, we have to encode the query part to be in a valid Percent-encoding.
        guard let encoded = url!.encodeUrl() else {
            completionHandler(url)
            return
        }
        
        // check we got valid URL, if not we'll return the input
        if !encoded.isValidURL() {
            completionHandler(url)
            return
        }
        
        logDebug("Resolving URL: \(url!)")
        self.redirects = [encoded]
        self.maxRedirections = maxRedirections
        resolveInternal(completionHandler: completionHandler)
        
        
    }
    
   private func resolveInternal( completionHandler: @escaping (String?) -> Void){
       DispatchQueue.global(qos: .background).async {
           let uri = self.redirects.last!
           let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
           
           guard let url = URL(string: uri) else {
               self.logDebug("Could no create URL object for \(uri)")
               DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                   completionHandler(nil)
               })
               return
           }
           
           let request = URLRequest(url: url)
           let task = session.dataTask(with: request) {(data, response, error) in
               
               if response?.url != nil{
                   self.logDebug("Found URL: \(response!.url!.absoluteString)")
                   //return the last URL to the developer
                   DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                       completionHandler(response?.url?.absoluteString)
                   })
               }else if error != nil{
                   self.logError(error!.localizedDescription)
                   DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                       completionHandler(nil)
                   })
               }
           }
           task.resume()
       }
   }
}

// MARK: URL Delegate
extension URLResolver: URLSessionDelegate, URLSessionTaskDelegate {
  
  public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
       
       if (300...308).contains(response.statusCode){ // has a redirection
           guard let absoluteString = request.url?.absoluteString else {
               completionHandler(nil)
               return
           }
           
           self.redirects.append(absoluteString)
           self.logDebug("Redirect to \(absoluteString)")
           
           if self.redirects.count == self.maxRedirections {
               completionHandler(nil)
               return
           }
           
           completionHandler(request) // Regular iOS URL SESSION behavior - countinue resolving
           
       }else{
           completionHandler(nil)
       }
       
   }
}

    

// MARK: Logger
extension URLResolver{
   private func logDebug(_ msg:String){
        if isDebug{
            NSLog("AppsFlyer Resolver [Debug]: \(msg)")
        }
        
    }
    private func logError(_ msg:String){
        NSLog("AppsFlyer Resolver [Error]: \(msg)")
        
    }
}

//
//  JSRedirectionHandler.swift
//  AppsFlyerURLResolver
//
//  Created by Amit Kremer on 12/06/2022.
//

import Foundation

class JSRedirectionHandler : NSObject {
    var jsRedirectionCompletionHandler : ((String?) -> Void)
    var logger : AppsFlyerLogger
    
    init(logger: AppsFlyerLogger, redirectionCompletionHandler: @escaping (String?) -> Void) {
        self.logger = logger
        self.jsRedirectionCompletionHandler = redirectionCompletionHandler
    }
    
    func resolveJSRedirection(withUrl url:String) {
        guard let url = URL(string: url) else {
            self.jsRedirectionCompletionHandler(nil)
            return
        }
        let request = URLRequest(url: url)
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: request) {(data, response, error) in
            if let err = error {
                self.logger.logError(err.localizedDescription)
                self.jsRedirectionCompletionHandler(nil)
                return
            }
            
            if let data = data {
                if let jsCode = String(data: data, encoding: .utf8) {
                    let redirectionLink = self.extractLinkFrom(JSCode: jsCode)
                    if let redirectionLink = redirectionLink {
                        self.logger.logDebug("Found URL: \(redirectionLink)")
                        self.jsRedirectionCompletionHandler(redirectionLink)
                    }else {
                        self.logger.logError("No url found")
                        self.jsRedirectionCompletionHandler(nil)
                    }
                }
            }
        }.resume()
    }
    
    /**
     gets the link that the JS code returns for iOS platform
     */
    func extractLinkFrom(JSCode stringifyJSCode: String) -> String? {
        let rawStringLinks = matches(for: "window.location.replace\\(\\\".*\"\\)", in: stringifyJSCode)
        if rawStringLinks.isEmpty {
            return nil
        }
        let lastLink = rawStringLinks[rawStringLinks.count-1]
        var redirectLink = matches(for: "http.*\"", in: lastLink).joined()
        redirectLink = String(redirectLink.dropLast())
        
        return redirectLink
    }
    
    /**
     finds occurences of sub-string inside string using regex. Returns array of sub-strings that match the regex or an empty array when something wrong happened
     */
    func matches(for regex: String, in text: String) -> [String]{
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            self.logger.logError("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}

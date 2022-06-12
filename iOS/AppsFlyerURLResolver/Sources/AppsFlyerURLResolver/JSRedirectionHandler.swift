//
//  JSRedirectionHandler.swift
//  AppsFlyerURLResolver
//
//  Created by Amit Kremer on 12/06/2022.
//

import Foundation

class JSRedirectionHandler : NSObject {
    static var sharedInstance = JSRedirectionHandler()
    var jsRedirectionCompletionHandler : ((String?) -> Void)?
    var afLogger : AFLogger?
    
    func resolveJSRedirection(withUrl url:String) {
        guard let url = URL(string: url) else {
            self.jsRedirectionCompletionHandler?(nil)
            return
        }
        let request = URLRequest(url: url)
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: request) {(data, response, error) in
            if let err = error {
                self.afLogger?.logError(err.localizedDescription)
                self.jsRedirectionCompletionHandler?(nil)
                return
            }
            
            if let data = data {
                if let jsCode = String(data: data, encoding: .utf8) {
                    let redirectionLink = self.extractLinkFrom(JSCode: jsCode)
                    if let redirectionLink = redirectionLink {
                        self.afLogger?.logDebug("Found URL: \(redirectionLink)")
                        self.jsRedirectionCompletionHandler?(redirectionLink)
                    }else {
                        self.afLogger?.logError("No url found")
                        self.jsRedirectionCompletionHandler?(nil)
                    }
                }
            }
        }.resume()
    }
    
    /**
     gets the link that the JS code returns for iOS platform
     */
    private func extractLinkFrom(JSCode stringifyJSCode: String) -> String? {
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
    private func matches(for regex: String, in text: String) -> [String]{
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}

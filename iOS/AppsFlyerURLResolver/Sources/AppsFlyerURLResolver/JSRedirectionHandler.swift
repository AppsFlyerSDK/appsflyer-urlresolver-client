//
//  JSRedirectionHandler.swift
//  AppsFlyerURLResolver
//
//  Created by Amit Kremer on 12/06/2022.
//

import Foundation

final class JSRedirectionHandler : NSObject {
    
    private enum RegExp {
        static let hubspotRegepx: String = "window.location.replace\\(\\\".*\"\\)"
        static let emersysRegexp: String = "http-equiv=\"refresh\"[\\s\\n]*content=\"0;[\\s\\n]*URL='([^']+)'\""
    }

    
    
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
        var rawStringLinks = matches(for: RegExp.hubspotRegepx, in: stringifyJSCode)
        
        if rawStringLinks.isEmpty {
            rawStringLinks = matches(for: RegExp.emersysRegexp, in: stringifyJSCode)
        }
        
        if rawStringLinks.isEmpty {
            return nil
        }
        
        guard let lastLink = rawStringLinks.last else { return nil }
        var redirectLink = detectURLInString(text: lastLink).joined()
        return redirectLink
    }
    
    func detectURLInString(text: String) -> [String] {
        let types: NSTextCheckingResult.CheckingType = [ .link]
        let detector = try? NSDataDetector(types: types.rawValue)
        guard let results = detector?.matches(in: text, range: NSRange(location: 0, length: text.count)) else { return [String]() }
        
        return results.map { String(text[Range($0.range, in: text)!]) }
    }
    
    /**
     finds occurences of sub-string inside string using regex. Returns array of sub-strings that match the regex or an empty array when something wrong happened
     */
    func matches(for regex: String, in text: String) -> [String] {
        return _matches(for: regex, in: text)
    }
    
    private func _matches(for regex: String, in text: String) -> [String] {
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

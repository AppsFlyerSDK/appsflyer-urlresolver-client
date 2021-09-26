//
//  Extentions.swift
//  AFExample
//
//  Created by Paz Lavi  on 06/09/2021.
//

import Foundation

extension String{
    func isValidURL() -> Bool{
        let    regex = "^(http|https)://(\\w+:{0,1}\\w*@)?(\\S+)(:[0-9]+)?(/|/([\\w#!:.?+=&%@\\-/]))?"
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
        
    }
    
    public func decodeUrl() -> String?
    {
        return self.removingPercentEncoding
    }
    
    public func encodeUrl() -> String?{
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
}

//
//  ModelClass.swift
//  WikiGame
//
//  Created by Saurabh Mishra on 06/01/18.
//  Copyright © 2018 Saurabh. All rights reserved.
//

import Foundation
import SwiftSoup

extension String {
    func split(splitter: String) -> Array<String> {
        return self.components(separatedBy:splitter)
    }
}
extension UITextView {
    
    func convertToRange(range:UITextRange)->NSRange{
        
        let beginning = self.beginningOfDocument
        let selectionStart = range.start
        let selectionEnd = range.end
        let location=self.offset(from: beginning, to:selectionStart)
        let length=self.offset(from: selectionStart, to:selectionEnd)
        return NSMakeRange(location, length);
    }
}
class ModelClass{
    
    //api function
    func getApi(completion:@escaping(_ response:AnyObject,_ isSuccess:Bool)->Void){
        
        var request = URLRequest(url: URL(string: "http://en.wikipedia.org/wiki/Special:Random")!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                let html = String(data: data!, encoding: String.Encoding.utf8)
                let doc: Document = try SwiftSoup.parse(html!)
                completion(try doc.text() as AnyObject,true)
            } catch {
                
                completion(NSNull(),false)
                print("error")
            }
        })
        task.resume()
    }
    func trimSpecialChar(input:String)->String{
        
        var returnValue=input
        let trimCharacter=[",",":",";","()","(",")","//","/","\\","\""]
        for value in trimCharacter{
            
             returnValue = returnValue.replacingOccurrences(of:value, with: "")
        }
        return returnValue
    }
    func calculateScore(originalText:String,newText:String)->String{
        
        //compare both
        var i = 0
        var score=10
        let originalArray=originalText.split(splitter:".")[0..<10]
        let newArray=newText.split(splitter:".")
        while i<originalArray.count {
            
            if !(originalArray[i].replacingOccurrences(of:" ", with: "")==newArray[i].replacingOccurrences(of:" ", with: "")){
                
                score=score-1
            }
            i=i+1
        }
        return "\(score)"
    }
}

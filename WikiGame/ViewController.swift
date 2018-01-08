//
//  ViewController.swift
//  WikiGame
//
//  Created by Saurabh Mishra on 06/01/18.
//  Copyright © 2018 Saurabh. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UITextViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource{
    
    @IBOutlet weak var stvWikiText: UITextView!
    var viewText=""
    var originalString=""
    var replacedChar=[String]()
    var answerByUser=[String]()
    let pickerView=UIPickerView()
    var selectedRange:UITextRange!
    var raangesArray = [UITextRange]()
    let modelClass=ModelClass()
    let blackColor = [NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20)]
    let blueColor = [NSAttributedStringKey.foregroundColor: UIColor.blue, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 25)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.stvWikiText.delegate=self
        pickerView.delegate=self
        pickerView.dataSource=self
        setData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    func setData(){
        
        modelClass.getApi { (response,isStatus) in
        
            if isStatus==true{
                
                DispatchQueue.main.async() {
                    
                    self.viewText=(response as? String)!
                    self.setupText()
                }
            }
            else{
                
                DispatchQueue.main.async() {
                    
                    let alert = UIAlertController(title:"Alert!", message:"Something went wrong!", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    /////////////////////////////////Set up text in textView///////////////////////
    func setupText(){
        
        viewText = modelClass.trimSpecialChar(input: viewText)
        let sentenseArray=viewText.split(splitter:".")[0..<10]
        let sentenseToShow=NSMutableAttributedString()
        for value in sentenseArray{
            
            sentenseToShow.append(replaceWordWithDash(text: value))
        }
        self.stvWikiText.attributedText=sentenseToShow
    }
    //replace text with dash
    func replaceWordWithDash(text:String)->NSMutableAttributedString{
        
        let returnString=NSMutableAttributedString()
        var i=0
        let textArray=text.split(splitter:" ").count
        let position=arc4random_uniform(UInt32(textArray))
        while i<textArray{
            
            if i==position{
                
                replacedChar.append((text.split(splitter:" ")[i] as String))
                returnString.append(NSMutableAttributedString(string:" "+"______", attributes: blueColor))
            }
            else{
                
                returnString.append(NSMutableAttributedString(string:" "+text.split(splitter:" ")[i], attributes: blackColor))
            }
            i=i+1
        }
        returnString.append(NSMutableAttributedString(string:" "+"."+" ", attributes: blackColor))
        return returnString
    }
    //////////////////////////////////////////////////////////////////

    //present pickerview to show available options
    func showChoiceMenu(){
    
        pickerView.backgroundColor=UIColor.brown
        pickerView.frame.size.width=self.view.frame.size.width
        pickerView.frame.size.height=200
        pickerView.center=self.view.center
        pickerView.reloadAllComponents()
        self.view.addSubview(pickerView)
    }
    //MARK:- PickerView delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
         return 1
    }
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return replacedChar.count
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        stvWikiText.textStorage.replaceCharacters(in:stvWikiText.convertToRange(range: selectedRange), with: NSMutableAttributedString(string:replacedChar[row], attributes: blueColor))
            self.pickerView.removeFromSuperview()
    }
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return replacedChar[row]
    }
    //MARK:- TEXTVIEW delegate
    func textViewDidChangeSelection(_ textView: UITextView){
        
        if (textView.selectedTextRange != nil){
            
            let selectedValue=textView.text(in: textView.selectedTextRange!)
            if(selectedValue=="______"){
                
                self.showChoiceMenu()
                selectedRange=textView.selectedTextRange!
                raangesArray.append(textView.selectedTextRange!)
                textView.selectedTextRange=nil
            }
            else if(linearSearch(array:replacedChar,object:selectedValue!).status==true){
                
                self.showChoiceMenu()
                selectedRange=textView.selectedTextRange!
                raangesArray.append(textView.selectedTextRange!)
                textView.selectedTextRange=nil
            }
        }
    }
    func linearSearch<T: Equatable>(array: [T], object: T) -> (status:Bool,index:Int) {
        
        for (index, obj) in array.enumerated() where obj == object {
            
            return (true,index)
            
        }
        return (false,0)
    }
    //MARK:- IBACTION
    @IBAction func clickSubmit(_ sender: Any) {
        
        let message=modelClass.calculateScore(originalText: self.viewText, newText:self.stvWikiText.text)
        var answer=""
        for value in replacedChar{
            
            answer=answer+value+" , "
        }
        let alert = UIAlertController(title:"Your Score! is ->\(message)/10", message:"The right options are->"+answer, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func clickReplay(_ sender: Any) {
        
        self.setData()
        replacedChar.removeAll()
        answerByUser.removeAll()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


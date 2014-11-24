//
//  ViewController.swift
//  ImageDownloader
//
//  Created by Kohei on 2014/11/18.
//  Copyright (c) 2014年 KoheiKanagu. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func showAlert(MessageText messageText:NSString, InformativeText informativeText:NSString) {
        let alert = NSAlert()
        alert.messageText = messageText
        alert.informativeText = informativeText
        alert.runModal()
    }
    
//MARK: - ダウンロード系
    func formalWithRule(rule:NSString, content:NSString) -> (NSArray?) {
        var resultArray = [NSString]()
        var error:NSError?
        
        let regex = NSRegularExpression(pattern: rule, options: NSRegularExpressionOptions.CaseInsensitive, error: &error);
        if error != nil {
            return nil
        }
        var matches = (regex?.matchesInString(content, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, content.length))) as Array<NSTextCheckingResult>
        for match:NSTextCheckingResult in matches {
            resultArray.append(content.substringWithRange(match.rangeAtIndex(1)))
        }
        return resultArray
    }
    
    func downloadData(rawURLs:NSArray!, contentString:NSString!, saveDir:NSURL) {
        var donedCount = 0.0
        
        for urlString in rawURLs{
            autoreleasepool({ () -> () in
                let url = NSURL(string: (urlString) as NSString)!
                
                let data = NSData(contentsOfURL: url)
                let fileFullURLPath = saveDir.URLByAppendingPathComponent(url.lastPathComponent)
                
                if (data?.writeToURL(fileFullURLPath, atomically: true) != nil) {
                    println("Done -> \(fileFullURLPath)")
                    donedCount++
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.refreshBarIndicator(donedCount / Double(rawURLs.count) * 100)
                    })
                }else{
                    println("nil")
                }
            })
        }
    }
    
    func refreshBarIndicator(current: NSNumber) {
        barIndicator?.doubleValue = current.doubleValue
    }
    
//MARK: - 保存先作成
    func makeDirectory() -> (NSURL?){
        let uuid:NSString = NSUUID().UUIDString
        let choosedDir = chooseDirectory()
        if(choosedDir == nil){
            return nil
        }
        let fullPath = (choosedDir as NSURL!).URLByAppendingPathComponent(uuid, isDirectory: true)
        
        NSFileManager().createDirectoryAtURL(fullPath, withIntermediateDirectories: true, attributes: nil, error: nil)
        return fullPath
    }
    
    func chooseDirectory() -> (NSURL?) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.resolvesAliases = true
        panel.prompt = "ここに保存"
        panel.title = "保存先"
        
        var filePath: NSURL
        
        if(panel.runModal() == NSFileHandlingPanelOKButton){
            return (panel.URLs[0] as NSURL)
        }
        return nil
    }
    
//MARK: - Action
    @IBOutlet var htmlTextField:NSTextField?
    @IBOutlet var indicator:NSProgressIndicator?
    @IBOutlet var barIndicator:NSProgressIndicator?
    @IBOutlet var startButton:NSButton?
    @IBOutlet var checkButton:NSButton?
    
    @IBAction func startButtonAction(sender:AnyObject) {
        let contentString = htmlTextField?.stringValue
        var rawURLs:NSArray = formalWithRule("<a href=\"(.*)\"", content: contentString!)!

        if rawURLs.count == 0{
            showAlert(MessageText: "Images Not Found", InformativeText: "")
            return
        }
        
        var saveDir:NSURL?
        if(checkButton?.state == NSOnState){
            saveDir = makeDirectory()
        }else{
            saveDir = chooseDirectory()
        }
        
        if(saveDir == nil){
            println("Cancel")
            return
        }
        
        indicator?.startAnimation(nil)
        startButton?.enabled = false
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            self.downloadData(rawURLs, contentString: contentString, saveDir: saveDir!)
            self.startButton?.enabled = true
            self.indicator?.stopAnimation(nil)

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.showAlert(MessageText: "Complate!!", InformativeText: "")
            })
        })
    }
}


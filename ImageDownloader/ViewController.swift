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
    
    func downloadData(rawURLs:NSArray!, contentString:NSString!, saveDir:NSString) {
        for urlString in rawURLs{
            let url = NSURL(string: (urlString) as NSString)!
            
            let data = NSData(contentsOfURL: url)
            let fileFullPath = saveDir.stringByAppendingPathComponent(url.lastPathComponent)
            
            if (data?.writeToFile(fileFullPath, atomically: true) != nil) {
                println("Done -> \(fileFullPath)")
            }else{
                println("nil")
            }
        }
    }
    
    func makeDirectory() -> (fullPath: NSString, uuid: NSString){
        let uuid:NSString = NSUUID().UUIDString
        let fullPath = NSHomeDirectory()+"/Downloads/"+uuid;
        NSFileManager().createDirectoryAtPath(fullPath, withIntermediateDirectories: true, attributes: nil, error: nil)
        return (fullPath, uuid)
    }
    
    func showAlert(MessageText messageText:NSString, InformativeText informativeText:NSString) {
        let alert = NSAlert()
        alert.messageText = messageText
        alert.informativeText = informativeText
        alert.runModal()
    }
    
    
    @IBOutlet var htmlTextField:NSTextField?
    @IBOutlet var indicator:NSProgressIndicator?
    @IBOutlet var startButton:NSButton?
    
    @IBAction func startButtonAction(sender:AnyObject) {
        let contentString = htmlTextField?.stringValue
        var rawURLs:NSArray = formalWithRule("<a href=\"(.*)\"", content: contentString!)!

        if rawURLs.count == 0{
            showAlert(MessageText: "Images Not Found", InformativeText: "")
            return
        }
        
        let saveDir = makeDirectory()
        showAlert(MessageText: "Save Images Directory is...", InformativeText: saveDir.fullPath)
        
        indicator?.startAnimation(nil)
        startButton?.enabled = false
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            self.downloadData(rawURLs, contentString: contentString, saveDir: saveDir.fullPath)
            self.startButton?.enabled = true
            self.indicator?.stopAnimation(nil)

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.showAlert(MessageText: "Complate!!", InformativeText: "")
            })
        })
    }
}


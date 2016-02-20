//
//  AppDelegate.swift
//  RabbitMQ
//
//  Created by José Padilla on 2/20/16.
//  Copyright © 2016 José Padilla. All rights reserved.
//
import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var paths = NSSearchPathForDirectoriesInDomains(
        NSSearchPathDirectory.DocumentDirectory,
        NSSearchPathDomainMask.UserDomainMask, true)
    
    var documentsDirectory: AnyObject
    var dataPath: String
    var logPath: String
    var environment: [String: String]
    
    var task: NSTask = NSTask()
    var pipe: NSPipe = NSPipe()
    var file: NSFileHandle
    
    var statusBar = NSStatusBar.systemStatusBar()
    var statusBarItem: NSStatusItem = NSStatusItem()
    var menu: NSMenu = NSMenu()
    
    var statusMenuItem: NSMenuItem = NSMenuItem()
    var openCLIMenuItem: NSMenuItem = NSMenuItem()
    var openLogsMenuItem: NSMenuItem = NSMenuItem()
    var docsMenuItem: NSMenuItem = NSMenuItem()
    var aboutMenuItem: NSMenuItem = NSMenuItem()
    var versionMenuItem: NSMenuItem = NSMenuItem()
    var quitMenuItem: NSMenuItem = NSMenuItem()
    var updatesMenuItem: NSMenuItem = NSMenuItem()
    
    override init() {
        self.file = self.pipe.fileHandleForReading
        self.documentsDirectory = self.paths[0]
        self.dataPath = documentsDirectory.stringByAppendingPathComponent("RabbitMQData")
        self.logPath = documentsDirectory.stringByAppendingPathComponent("RabbitMQData/Logs")
        
        self.environment = [
            "HOME": NSProcessInfo.processInfo().environment["HOME"]!,
            "RABBITMQ_MNESIA_BASE": self.dataPath,
            "RABBITMQ_LOG_BASE": self.logPath
        ]
        
        super.init()
    }
    
    func startServer() {
        self.task = NSTask()
        self.pipe = NSPipe()
        self.file = self.pipe.fileHandleForReading
        
        if let path = NSBundle.mainBundle().pathForResource("rabbitmq-server", ofType: "", inDirectory: "Vendor/rabbitmq/sbin") {
            self.task.launchPath = path
        }

        self.task.environment = self.environment
        self.task.standardOutput = self.pipe
        
        print("Run rabbitmq-server")
        
        self.task.launch()
    }
    
    func stopServer() {
        let task = NSTask()
        
        if let path = NSBundle.mainBundle().pathForResource("rabbitmqctl", ofType: "", inDirectory: "Vendor/rabbitmq/sbin") {
            task.launchPath = path
        }
        
        task.arguments = ["stop"]
        task.environment = self.environment
        
        print("Run rabbitmqctl stop")
        task.launch()

        
        let data: NSData = self.file.readDataToEndOfFile()
        self.file.closeFile()
        
        let output: String = NSString(data: data, encoding: NSUTF8StringEncoding)! as String
        print(output)
    }
    
    func openUI(sender: AnyObject) {
        if let url: NSURL = NSURL(string: "http://localhost:15672") {
            NSWorkspace.sharedWorkspace().openURL(url)
        }
    }
    
    func openDocumentationPage(send: AnyObject) {
        if let url: NSURL = NSURL(string: "https://github.com/jpadilla/rabbitmqapp") {
            NSWorkspace.sharedWorkspace().openURL(url)
        }
    }
    
    func openLogsDirectory(send: AnyObject) {
        NSWorkspace.sharedWorkspace().openFile(self.logPath)
    }
    
    func createDirectories() {
        if (!NSFileManager.defaultManager().fileExistsAtPath(self.dataPath)) {
            do {
                try NSFileManager.defaultManager()
                    .createDirectoryAtPath(self.dataPath, withIntermediateDirectories: false, attributes: nil)
            } catch {
                print("Something went wrong creating dataPath")
            }
        }
        
        if (!NSFileManager.defaultManager().fileExistsAtPath(self.logPath)) {
            do {
                try NSFileManager.defaultManager()
                    .createDirectoryAtPath(self.logPath, withIntermediateDirectories: false, attributes: nil)
            } catch {
                print("Something went wrong creating logPath")
            }
        }
        
        print("RabbitMQ data directory: \(self.dataPath)")
        print("RabbitMQ logs directory: \(self.logPath)")
    }
    
    func checkForUpdates(sender: AnyObject?) {
        print("Checking for updates")
    }
    
    func setupSystemMenuItem() {
        // Add statusBarItem
        statusBarItem = statusBar.statusItemWithLength(-1)
        statusBarItem.menu = menu
        
        let icon = NSImage(named: "logo")
        icon!.template = true
        icon!.size = NSSize(width: 18, height: 18)
        statusBarItem.image = icon
        
        // Add version to menu
        versionMenuItem.title = "RabbitMQ"
        if let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String? {
            versionMenuItem.title = "RabbitMQ v\(version)"
        }
        menu.addItem(versionMenuItem)
        
        // Add actionMenuItem to menu
        statusMenuItem.title = "Running on Port 5672"
        menu.addItem(statusMenuItem)
        
        // Add separator
        menu.addItem(NSMenuItem.separatorItem())
        
        // Add open redis-cli to menu
        openCLIMenuItem.title = "Open Management UI"
        openCLIMenuItem.action = Selector("openUI:")
        menu.addItem(openCLIMenuItem)
        
        // Add open logs to menu
        openLogsMenuItem.title = "Open logs directory"
        openLogsMenuItem.action = Selector("openLogsDirectory:")
        menu.addItem(openLogsMenuItem)
        
        // Add separator
        menu.addItem(NSMenuItem.separatorItem())
        
        // Add check for updates to menu
        updatesMenuItem.title = "Check for Updates..."
        updatesMenuItem.action = Selector("checkForUpdates:")
        menu.addItem(updatesMenuItem)
        
        // Add about to menu
        aboutMenuItem.title = "About"
        aboutMenuItem.action = Selector("orderFrontStandardAboutPanel:")
        menu.addItem(aboutMenuItem)
        
        // Add docs to menu
        docsMenuItem.title = "Documentation..."
        docsMenuItem.action = Selector("openDocumentationPage:")
        menu.addItem(docsMenuItem)
        
        // Add separator
        menu.addItem(NSMenuItem.separatorItem())
        
        // Add quitMenuItem to menu
        quitMenuItem.title = "Quit"
        quitMenuItem.action = Selector("terminate:")
        menu.addItem(quitMenuItem)
    }
    
    func appExists(appName: String) -> Bool {
        let found = [
            "/Applications/\(appName).app",
            "/Applications/Utilities/\(appName).app",
            "\(NSHomeDirectory())/Applications/\(appName).app"
            ].map {
                return NSFileManager.defaultManager().fileExistsAtPath($0)
            }.reduce(false) {
                if $0 == false && $1 == false {
                    return false;
                } else {
                    return true;
                }
        }
        
        return found
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        createDirectories()
        setupSystemMenuItem()
        startServer()
    }
    
    func applicationWillTerminate(notification: NSNotification) {
        stopServer()
    }
    
}
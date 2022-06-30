//
//  AppDelegate.swift
//  CameraUsage
//
//  Created by Tobias Timpe on 20.08.20.
//  Copyright © 2020 Tobias Timpe. All rights reserved.
//

import Cocoa
import CoreImage
import CoreMedia
import CoreMediaIO


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    let cameraUsageController = CameraUsageController()

    @IBOutlet weak var cameraOnURLField: NSTextField!
    
    @IBOutlet weak var cameraSelectorPopup: NSPopUpButton!
    
    var selectedCameraId :UInt32 = 0
    
    let statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
       

        
        statusBarItem.button?.image = NSImage(named: "MenuBarIcon")
        
        let menu = NSMenu()
        
        let setAvailableMenuItem = NSMenuItem(title: NSLocalizedString("MENU_ITEM_AVAILABLE", comment: "Set available"), action:
            #selector(self.setAvailable(_:)), keyEquivalent: "")
        let setBusyMenuItem = NSMenuItem(title: NSLocalizedString("MENU_ITEM_BUSY", comment: "Set busy"), action:
            #selector(self.setBusy(_:)), keyEquivalent: "")
        let setAwayMenuItem = NSMenuItem(title: NSLocalizedString("MENU_ITEM_AWAY", comment: "Set away"), action:
            #selector(self.setAway(_:)), keyEquivalent: "")
        
        let playPauseMenuItem = NSMenuItem(title: NSLocalizedString("PAUSE_MONITORING", comment: "Pause monitoring"), action: #selector(self.toggleMonitoringEnabled(_:)), keyEquivalent: "")
        playPauseMenuItem.state = .on
        
        let preferencesMenuItem = NSMenuItem(title: NSLocalizedString("MENU_ITEM_PREFERENCES", comment: "Preferences"), action: #selector(self.showPreferencesWindow(_:)), keyEquivalent: "")
        
        let quitMenuItem = NSMenuItem(title: NSLocalizedString("MENU_ITEM_QUIT", comment: "Quit"), action: #selector(self.quitApp), keyEquivalent: "")
        
        menu.addItem(setAvailableMenuItem)
        menu.addItem(setBusyMenuItem)
        menu.addItem(setAwayMenuItem)
        menu.addItem(playPauseMenuItem)
        menu.addItem(preferencesMenuItem)
        menu.addItem(quitMenuItem)
        self.statusBarItem.menu = menu
        
        UserDefaults.standard.synchronize()
        
        self.selectedCameraId = UInt32(UserDefaults.standard.integer(forKey: "selectedCameraId"))
        cameraUsageController.enableDALDevices()
        cameraUsageController.startUpdating()
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        cameraUsageController.stopUpdating()
    }
    
    @objc func quitApp() {
        NSApp.terminate(nil)
    }
    
    @objc func setAvailable(_ sender: NSMenu) {
        cameraUsageController.sendUpdateToServer(status: "Available")
    }
    
    @objc func setBusy(_ sender: NSMenu) {
        cameraUsageController.sendUpdateToServer(status: "In_Meeting")
    }
    
    @objc func setAway(_ sender: NSMenu) {
        cameraUsageController.sendUpdateToServer(status: "Away")
    }
    
    @objc func toggleMonitoringEnabled(_ sender: NSMenuItem) {
        if self.cameraUsageController.isMonitoring {
            self.cameraUsageController.stopUpdating()
            sender.state = .off
        } else {
            self.cameraUsageController.startUpdating()
            sender.state = .on
        }
    }

    @IBAction func showPreferencesWindow(_ sender: Any) {
        print(self.window.debugDescription)
        
        self.window.setIsVisible(true)
        NSApp.activate(ignoringOtherApps: true)

        
        self.window.makeKeyAndOrderFront(self)
        

        
        UserDefaults.standard.synchronize()
        
        
        
        let availableCameras = cameraUsageController.cameras

        self.cameraSelectorPopup.removeAllItems()

        let anyCameraMenuItem = NSMenuItem(title: NSLocalizedString("ANY_CAMERA", comment: "Any camera"), action: nil, keyEquivalent: "")
        anyCameraMenuItem.tag = 0
        self.cameraSelectorPopup.menu?.addItem(anyCameraMenuItem)
        
        
        for camera in availableCameras {
            let cameraMenuItem = NSMenuItem(title: camera.name ?? "", action: nil, keyEquivalent: "")
            cameraMenuItem.tag = Int(camera.id)
            print(camera.id)
            self.cameraSelectorPopup.menu?.addItem(cameraMenuItem)
        }
        self.cameraSelectorPopup.selectItem(withTag: Int(self.selectedCameraId))
        

        if let cameraOnURLString = UserDefaults.standard.url(forKey: "cameraOnURL")?.absoluteString {
            self.cameraOnURLField.stringValue = cameraOnURLString
        }
    }
    
    @IBAction func saveUpdateURLs(_ sender: Any) {
        self.selectedCameraId = UInt32(self.cameraSelectorPopup.selectedTag())
        
        UserDefaults.standard.set(self.selectedCameraId, forKey: "selectedCameraId")
        print("saving selected camera id \(self.selectedCameraId)")
        
        
        if let cameraOnURL = URL(string: self.cameraOnURLField.stringValue) {
            UserDefaults.standard.set(cameraOnURL, forKey: "cameraOnURL")
        }
        self.window.close()
        UserDefaults.standard.synchronize()
        
    }
}


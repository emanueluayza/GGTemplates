//
//  main.swift
//  GGToolsInstaller
//
//  Created by Emanuel Luayza on 07/05/2020.
//  Copyright © 2020 Emanuel Luayza. All rights reserved.
//

import Foundation
import AppKit

// MARK: - Constants

struct Constants {
    struct FilesDirectory {
        static let architectures = "architectures/"
        static let utils = "utils/"
    }
    
    struct ArchtFiles {
        static let mvvmTemplate = "MVVM.xctemplate"
    }
    
    struct UtilFiles {
        static let baseServiceTemplate = "Base Service.xctemplate"
    }
    
    struct Paths {
        static let destinationPath = "/Library/Xcode/Templates/File Templates/GGTools Templates"
    }

    struct Messages {
        static let creatingDirectoryMessage = "Creating GGT Template directory... "
        static let installingMessage = "Installing GGT Template (%@) into: "
        static let successMessage = "GGT Template (%@) was installed succesfully."
        static let errorMessage = "Ooops! Something went wrong"
        static let replaceMessage = "The GGT Template (%@) already exists. Do you want to replace it?"
        static let successfullReplaceMessage = "The GGT Template (%@) has been replaced for you with the new version."
        static let skipReplacementMessage = "The GGT Template (%@) replacement was skipped."
    }
}

// MARK: - Installer App

// Declare the Application context
let app = NSApplication.shared
app.setActivationPolicy(.regular)

// MARK: - Handlers

class DelegatesHandler: NSObject, NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.close()
        app.terminate(self)
        return true
    }
}

// MARK: - Alerts

struct Alert {
    var message: String
    var description: String?
    var okTitle: String
    var cancelTitle: String?
    var style: NSAlert.Style
    var okAction: (() -> Void)?
    var cancelAction: (() -> Void)?
    
    func show(on window: NSWindow) {
        let alert = NSAlert()
        alert.alertStyle = style
        alert.messageText = message
        alert.informativeText = description ?? ""
        alert.addButton(withTitle: okTitle)
        
        if let cancel = cancelTitle {
            alert.addButton(withTitle: cancel)
        }
        
        alert.beginSheetModal(for: window) { (response) in
            if response == .alertFirstButtonReturn {
                self.okAction?()
            } else {
                self.cancelAction?()
            }
            
            NSApplication.shared.stopModal()
        }
        
        alert.runModal()
    }
}

// MARK: - AppDelegate

class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: - Properties
    
    let handler = DelegatesHandler()
    
    // MARK: - IBOutlets
    
    let window = NSWindow(contentRect: NSRect(x:0, y:0, width:400, height:400),
                          styleMask: [.titled, .closable, .miniaturizable],
                          backing: .buffered,
                          defer: false)
    
    let imageView = NSImageView()
    let title = NSTextField()
    let subtitle = NSTextField()
    let mvvmButton = NSButton()
    let baseServiceButton = NSButton()
    let installButton = NSButton()
    let layout = NSLayoutGuide()

    // MARK: - NSApplicationDelegate
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupWindow()
        setupView()
        setupLayout()
    }
    
    // MARK: - Setups
    
    private func setupWindow() {
        window.title = "GGTools Templates Installer"
        window.center()
        window.makeKeyAndOrderFront(nil)  // Magic needed to display the window
        window.delegate = handler
    }
    
    private func setupView() {

        // Create logo
        let imagePath = "./GG.png"
        let completeUrl = URL(fileURLWithPath: imagePath)
        let img = NSImage(byReferencing: completeUrl)

        imageView.image = img
        
        window.contentView!.addSubview(imageView)
        
        // Create subtitle
        subtitle.stringValue = "Choose the templates you want to install:"
        subtitle.backgroundColor = .clear
        subtitle.isBezeled = false
        subtitle.isEditable = false
        subtitle.font = NSFont.systemFont(ofSize: 18)
        subtitle.alignment = .center
        
        window.contentView!.addSubview(subtitle)

        // Create buttons
        mvvmButton.title = "MVVM Template"
        mvvmButton.setButtonType(.switch)

        baseServiceButton.title = "Base Service Template"
        baseServiceButton.setButtonType(.switch)

        installButton.title = "Install"
        installButton.setButtonType(.toggle)
        installButton.target = self
        installButton.action = #selector(installAction)
        installButton.font = NSFont.systemFont(ofSize: 14)
        installButton.bezelStyle = .rounded
        
        window.contentView!.addSubview(mvvmButton)
        window.contentView!.addSubview(baseServiceButton)
        window.contentView!.addSubview(installButton)
    }
    
    private func setupLayout() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        mvvmButton.translatesAutoresizingMaskIntoConstraints = false
        baseServiceButton.translatesAutoresizingMaskIntoConstraints = false
        installButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: window.contentView!.topAnchor, constant: 40),
            imageView.centerXAnchor.constraint(equalTo: window.contentView!.centerXAnchor, constant: 0),
            imageView.widthAnchor.constraint(equalToConstant: 124),
            imageView.heightAnchor.constraint(equalToConstant: 74),
            
            subtitle.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            subtitle.leadingAnchor.constraint(equalTo: window.contentView!.leadingAnchor, constant: 0),
            subtitle.trailingAnchor.constraint(equalTo: window.contentView!.trailingAnchor, constant: 0),
            
            mvvmButton.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 20),
            mvvmButton.centerXAnchor.constraint(equalTo: window.contentView!.centerXAnchor, constant: -20),
            mvvmButton.heightAnchor.constraint(equalToConstant: 40),
            
            baseServiceButton.topAnchor.constraint(equalTo: mvvmButton.bottomAnchor, constant: 10),
            baseServiceButton.leadingAnchor.constraint(equalTo: mvvmButton.leadingAnchor, constant: 0),
            baseServiceButton.heightAnchor.constraint(equalToConstant: 40),
            
            installButton.topAnchor.constraint(equalTo: baseServiceButton.bottomAnchor, constant: 40),
            installButton.centerXAnchor.constraint(equalTo: window.contentView!.centerXAnchor, constant: 0),
            installButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    // MARK: - Actions
    
    @objc func installAction () {
        if mvvmButton.stringValue == "1" {
            installTemplate(template: Constants.ArchtFiles.mvvmTemplate, from: Constants.FilesDirectory.architectures, on: window)
        }

        if baseServiceButton.stringValue == "1" {
            installTemplate(template: Constants.UtilFiles.baseServiceTemplate, from: Constants.FilesDirectory.utils, on: window)
        }
    }
}

// MARK: - Files Management

func installTemplate(template: String, from directory: String, on window: NSWindow) {
    do {
        let fileManager = FileManager.default
        let destinationPath = bash(command: "xcode-select", arguments: ["--print-path"]).appending(Constants.Paths.destinationPath)
        var isDir : ObjCBool = false
                    
        if fileManager.fileExists(atPath: destinationPath, isDirectory:&isDir) {
            if isDir.boolValue {
                // Directory exists. Move forward...
            } else {
                // There is a file with the same name but is not a directory.
                //printToConsole(Constants.Messages.errorMessage)
                let alert = Alert(message: Constants.Messages.errorMessage, okTitle: "OK", style: .warning)
                alert.show(on: window)
            }
        } else {
            // Directory doesn't exist.
            //printToConsole(Constants.Messages.creatingDirectoryMessage)
            
            do {
                try FileManager.default.createDirectory(atPath: destinationPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                //printToConsole("\(Constants.Messages.errorMessage) : \(error)")
                let alert = Alert(message: Constants.Messages.errorMessage, description: "\(error)", okTitle: "Ok", style: .warning)
                alert.show(on: window)
            }
        }
        
        if !fileManager.fileExists(atPath: "\(destinationPath)/\(template)"){
            //printToConsole(String(format: Constants.Messages.installingMessage, template) + destinationPath)
            try fileManager.copyItem(atPath: directory + template, toPath: "\(destinationPath)/\(template)")
            let alert = Alert(message: Constants.Messages.successMessage, okTitle: "Ok", style: .informational)
            alert.show(on: window)
            //printToConsole(String(format: Constants.Messages.successMessage, template))
        } else {
            //printToConsole(String(format: Constants.Messages.replaceMessage, template))
            let alert = Alert(message: String(format: Constants.Messages.replaceMessage, template), okTitle: "Replace", cancelTitle: "Cancel", style: .informational, okAction: {
                do {
                    try replaceItemAt(URL(fileURLWithPath: "\(destinationPath)/\(template)"), withItemAt: URL(fileURLWithPath: directory + template))
                } catch {
                    let alert = Alert(message: Constants.Messages.errorMessage, description: "\(error)", okTitle: "Ok", style: .warning)
                    alert.show(on: window)
                }
            })
            
            alert.show(on: window)
        }
    }
    catch let error as NSError {
        let alert = Alert(message: Constants.Messages.errorMessage, description: "\(error.localizedFailureReason!)", okTitle: "Ok", style: .warning)
        alert.show(on: window)
        //printToConsole("\(Constants.Messages.errorMessage) : \(error.localizedFailureReason!)")
    }
}

func replaceItemAt(_ url: URL, withItemAt itemAtUrl: URL) throws {
    let fileManager = FileManager.default
    try fileManager.removeItem(at: url)
    try fileManager.copyItem(atPath: itemAtUrl.path, toPath: url.path)
}

// MARK: - Shell and Bash Management

func shell(launchPath: String, arguments: [String]) -> String {
    let task = Process()
    task.launchPath = launchPath
    task.arguments = arguments

    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: String.Encoding.utf8)!
    if output.count > 0 {
        //remove newline character.
        let lastIndex = output.index(before: output.endIndex)
        return String(output[output.startIndex ..< lastIndex])
    }
    return output
}

func bash(command: String, arguments: [String]) -> String {
    let whichPathForCommand = shell(launchPath: "/bin/bash", arguments: [ "-l", "-c", "which \(command)" ])
    return shell(launchPath: whichPathForCommand, arguments: arguments)
}

// Run app
let delegate = AppDelegate()
app.delegate = delegate
app.run()


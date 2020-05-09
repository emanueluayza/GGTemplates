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
        static let successMessageSingular = "The GGT Template was installed succesfully."
        static let successMessagePlural = "The GGT Templates were installed succesfully."
        static let errorMessage = "Ooops! Something went wrong"
        static let replaceMessage = "The GGT Template (%@) already exists. Do you want to replace it?"
        static let successfullReplaceMessage = "The GGT Template (%@) has been replaced for you with the new version."
        static let skipReplacementMessage = "The GGT Template (%@) replacement was skipped."
        static let permissionDeniedMessage = "You don't have permission to install templates. Please run the installer in administrator mode."
    }
    
    struct ErrorCode {
        static let permissionDeniedCode = 513
    }
}

// MARK: - Installer App

// Declare the Application context
let app = NSApplication.shared
app.setActivationPolicy(.regular)

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

// MARK: - Handlers

class DelegatesHandler: NSObject, NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.close()
        app.terminate(self)
        return true
    }
}

// MARK: - Helpers

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
        
        switch style {
        case .warning: alert.icon = NSImage(named: NSImage.cautionName)
        case .informational: alert.icon = NSImage(named: NSImage.infoName)
        default: break
        }

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

struct Template {
    var name: String
    var directory: String
    
    func path() -> String {
        return directory + name
    }
}

struct ErrorMessage {
    var message: String
    var description: String?
}

let fileManager = FileManager.default
let destinationPath = bash(command: "xcode-select", arguments: ["--print-path"]).appending(Constants.Paths.destinationPath)
let taskManager = DispatchGroup()
var templates: [Template] = []
var templatesCount: Int = 0
var templatesInstalled = 0

// MARK: - Extensions

extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
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
        let imagePath = "/Users/emanueluayza/Personal/Projects/MacOS/GGToolsInstaller/GGToolsInstaller/GG.png"
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
            imageView.topAnchor.constraint(equalTo: window.contentView!.topAnchor, constant: 30),
            imageView.centerXAnchor.constraint(equalTo: window.contentView!.centerXAnchor, constant: 0),
            imageView.widthAnchor.constraint(equalToConstant: 144),
            imageView.heightAnchor.constraint(equalToConstant: 94),
            
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
            templates.append(Template(name: Constants.ArchtFiles.mvvmTemplate, directory: Constants.FilesDirectory.architectures))
        }
        
        if baseServiceButton.stringValue == "1" {
            templates.append(Template(name: Constants.UtilFiles.baseServiceTemplate, directory: Constants.FilesDirectory.utils))
        }
        
        taskManager.enter()
        createDirectory { [weak self] (error) in
            guard let strongSelf = self else { return }
            
            if let error = error {
                let alert = Alert(message: error.message, description: error.description, okTitle: "OK", style: .warning, okAction: {
                    taskManager.leave()
                })
                alert.show(on: strongSelf.window)
            } else {
                taskManager.leave()
            }
        }

        templatesCount = templates.count
        installTemplates(on: window)

        taskManager.notify(queue: .main) { [weak self] in
            guard let strongSelf = self else { return }
            
            if templatesInstalled == templatesCount {
                let alert = Alert(message: templatesInstalled == 1 ? Constants.Messages.successMessageSingular : Constants.Messages.successMessagePlural, okTitle: "OK", style: .informational)
                alert.show(on: strongSelf.window)
                templatesInstalled = 0
            }
        }
    }
}

// MARK: - Files Management

func installTemplates(on window: NSWindow) {
    guard templates.count > 0 else { return }
    
    let template = templates.first!
    
    func nextTemplate() {
        templates.removeFirst()
        installTemplates(on: window)
    }
    
    taskManager.enter()
    install(template: template, on: window) { (error) in
        if let error = error {
            let alert = Alert(message: error.message, description: error.description, okTitle: "OK", style: .warning, okAction: {
                nextTemplate()
                taskManager.leave()
            })
            alert.show(on: window)
        } else {
            templatesInstalled += 1
            nextTemplate()
            taskManager.leave()
        }
    }
}

func install(template: Template, on window: NSWindow, completion:((_ error: ErrorMessage?) -> Void)?) {
    if !fileManager.fileExists(atPath: "\(destinationPath)/\(template.name)") {
        do {
            try fileManager.copyItem(atPath: template.path(), toPath: "\(destinationPath)/\(template.name)")
        } catch let error {
            completion?(ErrorMessage(message: Constants.Messages.errorMessage, description: error.localizedDescription))
            return
        }

        completion?(nil)
    } else {
        DispatchQueue.main.async {
            let alert = Alert(message: String(format: Constants.Messages.replaceMessage, template.name), okTitle: "Replace", cancelTitle: "Cancel", style: .informational, okAction: {
                DispatchQueue.main.async {
                    do {
                        try replace(template: template, at: destinationPath)
                    } catch let error {
                        let description = error.code == Constants.ErrorCode.permissionDeniedCode ? Constants.Messages.permissionDeniedMessage : "\(error)"
                        completion?(ErrorMessage(message: Constants.Messages.errorMessage, description: description))
                        return
                    }

                    completion?(nil)
                }
            })

            alert.show(on: window)
        }
    }
}

func createDirectory(completion:((_ error: ErrorMessage?) -> Void)?) {
    var isDir : ObjCBool = false
                
    if fileManager.fileExists(atPath: destinationPath, isDirectory:&isDir) {
        if !isDir.boolValue {
            completion?(ErrorMessage(message: Constants.Messages.errorMessage, description: nil))
            return
        }
    } else {
        do {
            try fileManager.createDirectory(atPath: destinationPath, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            completion?(ErrorMessage(message: Constants.Messages.errorMessage, description: error.localizedDescription))
            return
        }
    }
    
    completion?(nil)
}

func replace(template: Template, at destination: String) throws {
    let oldPath = URL(fileURLWithPath: "\(destination)/\(template.name)")
    let newPath = URL(fileURLWithPath: template.path())
        
    try fileManager.removeItem(at: oldPath)
    try fileManager.copyItem(atPath: newPath.path, toPath: oldPath.path)
}

// Run app
let delegate = AppDelegate()
app.delegate = delegate
app.run()

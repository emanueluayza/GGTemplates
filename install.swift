//
//  install.swift
//  GGTemplatesInstaller
//
//  Created by Emanuel Luayza on 07/05/2020.
//  Copyright © 2020 Emanuel Luayza. All rights reserved.
//

import Foundation
import AppKit

// MARK: - Constants

struct Constants {
    struct FilesDirectory {
        static let mvvmBsArch = "architectures/MVVM+BS/"
        static let mvvmArch = "architectures/MVVM/"
        static let utils = "utils/"
    }
    
    struct ArchtFiles {
        static let mvvmTemplate = "MVVM.xctemplate"
    }
    
    struct UtilFiles {
        static let baseServiceTemplate = "Base Service.xctemplate"
    }
    
    struct Paths {
        struct Images {
            static let logoPath = "./Resources/logo.png"
            static let iconPath = "./Resources/icon.png"
            static let successPath = "./Resources/success.png"
            static let warningPath = "./Resources/warning.png"
            static let errorPath = "./Resources/error.png"
        }
        
        static let destinationPath = "/Library/Xcode/Templates/File Templates/GGTemplates"
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

// Set App Icon
let iconUrl = URL(fileURLWithPath: Constants.Paths.Images.iconPath)
let iconImage = NSImage(byReferencing: iconUrl)
app.applicationIconImage = iconImage

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

enum AlertType {
    case success
    case warning
    case error
    
    func path() -> String {
        switch self {
        case .success: return Constants.Paths.Images.successPath
        case .warning: return Constants.Paths.Images.warningPath
        case .error: return Constants.Paths.Images.errorPath
        }
    }
}

struct Alert {
    var message: String
    var description: String?
    var okTitle: String
    var cancelTitle: String?
    var type: AlertType
    var okAction: (() -> Void)?
    var cancelAction: (() -> Void)?
    
    func show(on window: NSWindow) {
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = description ?? ""
        alert.addButton(withTitle: okTitle)

        let imageUrl = URL(fileURLWithPath: type.path())
        let image = NSImage(byReferencing: imageUrl)
        
        alert.icon = image
        
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
    
    // MARK: - IBOutlets
    
    let window = NSWindow(contentRect: NSRect(x:0, y:0, width:400, height:400),
                          styleMask: [.titled, .closable, .miniaturizable],
                          backing: .buffered,
                          defer: false)
    
    let imageView = NSImageView()
    let title = NSTextField()
    let subtitle = NSTextField()
    let baseServiceTitle = NSTextField()
    let mvvmButton = NSButton()
    let mvvmBSButton = NSButton()
    let mvpButton = NSButton()
    let mvpBSButton = NSButton()
    let installButton = NSButton()

    // MARK: - Properties
    
    let handler = DelegatesHandler()
    var isMvvmSelected = false
    var isMvpSelected = false
    var isMvvmBSSelected = false
    var isMvpBSSelected = false
    
    // MARK: - NSApplicationDelegate
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupWindow()
        setupView()
        setupLayout()
    }
    
    // MARK: - Setups
    
    private func setupWindow() {
        window.title = "GGTemplates Installer"
        window.center()
        window.makeKeyAndOrderFront(nil)  // Magic needed to display the window
        window.delegate = handler
    }
    
    private func setupView() {

        // Create logo
        let logoUrl = URL(fileURLWithPath: Constants.Paths.Images.logoPath)
        let logoImage = NSImage(byReferencing: logoUrl)
        imageView.image = logoImage
        
        window.contentView!.addSubview(imageView)
        
        // Create subtitle
        subtitle.stringValue = "Choose the templates you want to install:"
        subtitle.backgroundColor = .clear
        subtitle.isBezeled = false
        subtitle.isEditable = false
        subtitle.font = NSFont.systemFont(ofSize: 18)
        subtitle.alignment = .center
        
        window.contentView!.addSubview(subtitle)

        // Create Base Service title
        baseServiceTitle.stringValue = "Base Service"
        baseServiceTitle.backgroundColor = .clear
        baseServiceTitle.isBezeled = false
        baseServiceTitle.isEditable = false
        baseServiceTitle.font = NSFont.systemFont(ofSize: 14)
        baseServiceTitle.alignment = .center
        
        window.contentView!.addSubview(baseServiceTitle)
        
        // Create buttons
        mvvmButton.title = "MVVM Template"
        mvvmButton.setButtonType(.switch)
        mvvmButton.setButtonType(.toggle)
        mvvmButton.target = self
        mvvmButton.action = #selector(mvvmButtonAction)
        
        mvvmBSButton.title = ""
        mvvmBSButton.setButtonType(.switch)
        mvvmBSButton.isEnabled = isMvvmBSSelected
        mvvmBSButton.setButtonType(.toggle)
        mvvmBSButton.target = self
        mvvmBSButton.action = #selector(mvvmBSButtonAction)
        
        mvpButton.title = "MVP Template"
        mvpButton.setButtonType(.switch)
        mvpButton.setButtonType(.toggle)
        mvpButton.target = self
        mvpButton.action = #selector(mvpButtonAction)
        
        mvpBSButton.title = ""
        mvpBSButton.setButtonType(.switch)
        mvpBSButton.isEnabled = isMvpBSSelected
        mvpBSButton.setButtonType(.toggle)
        mvpBSButton.target = self
        mvpBSButton.action = #selector(mvpBSButtonAction)
        
        installButton.title = "Install"
        installButton.setButtonType(.toggle)
        installButton.target = self
        installButton.action = #selector(installAction)
        installButton.font = NSFont.systemFont(ofSize: 14)
        installButton.bezelStyle = .rounded
        
        window.contentView!.addSubview(mvvmButton)
        window.contentView!.addSubview(mvvmBSButton)
        window.contentView!.addSubview(mvpButton)
        window.contentView!.addSubview(mvpBSButton)
        window.contentView!.addSubview(installButton)
    }
    
    private func setupLayout() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        baseServiceTitle.translatesAutoresizingMaskIntoConstraints = false
        mvvmButton.translatesAutoresizingMaskIntoConstraints = false
        mvvmBSButton.translatesAutoresizingMaskIntoConstraints = false
        mvpButton.translatesAutoresizingMaskIntoConstraints = false
        mvpBSButton.translatesAutoresizingMaskIntoConstraints = false
        installButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: window.contentView!.topAnchor, constant: 30),
            imageView.centerXAnchor.constraint(equalTo: window.contentView!.centerXAnchor, constant: 0),
            imageView.widthAnchor.constraint(equalToConstant: 144),
            imageView.heightAnchor.constraint(equalToConstant: 94),
            
            subtitle.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            subtitle.leadingAnchor.constraint(equalTo: window.contentView!.leadingAnchor, constant: 0),
            subtitle.trailingAnchor.constraint(equalTo: window.contentView!.trailingAnchor, constant: 0),
            
            baseServiceTitle.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 20),
            baseServiceTitle.leadingAnchor.constraint(equalTo: window.contentView!.leadingAnchor, constant: 0),
            baseServiceTitle.trailingAnchor.constraint(equalTo: window.contentView!.trailingAnchor, constant: 0),
            
            mvvmButton.topAnchor.constraint(equalTo: baseServiceTitle.bottomAnchor, constant: 20),
            mvvmButton.leadingAnchor.constraint(equalTo: window.contentView!.leadingAnchor, constant: 40),
            mvvmButton.heightAnchor.constraint(equalToConstant: 40),
            
            mvvmBSButton.centerYAnchor.constraint(equalTo: mvvmButton.centerYAnchor, constant: 0),
            mvvmBSButton.heightAnchor.constraint(equalToConstant: 40),
            mvvmBSButton.centerXAnchor.constraint(equalTo: window.contentView!.centerXAnchor, constant: 0),
            
            mvpButton.topAnchor.constraint(equalTo: mvvmButton.bottomAnchor, constant: 20),
            mvpButton.leadingAnchor.constraint(equalTo: window.contentView!.leadingAnchor, constant: 40),
            mvpButton.heightAnchor.constraint(equalToConstant: 40),
            
            mvpBSButton.centerYAnchor.constraint(equalTo: mvpButton.centerYAnchor, constant: 0),
            mvpBSButton.heightAnchor.constraint(equalToConstant: 40),
            mvpBSButton.centerXAnchor.constraint(equalTo: window.contentView!.centerXAnchor, constant: 0),

            installButton.topAnchor.constraint(equalTo: mvpBSButton.bottomAnchor, constant: 30),
            installButton.centerXAnchor.constraint(equalTo: window.contentView!.centerXAnchor, constant: 0),
            installButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    // MARK: - Actions
    
    @objc func mvvmButtonAction() {
        isMvvmSelected = mvvmButton.stringValue == "1"
        mvvmBSButton.isEnabled = isMvvmSelected
    }
    
    @objc func mvpButtonAction() {
        isMvpSelected = mvpButton.stringValue == "1"
        mvpBSButton.isEnabled = isMvpSelected
    }
    
    @objc func mvvmBSButtonAction() {
        isMvvmBSSelected = mvvmBSButton.stringValue == "1"
        mvvmBSButton.isEnabled = isMvvmBSSelected
    }
    
    @objc func mvpBSButtonAction() {
        isMvpBSSelected = mvpBSButton.stringValue == "1"
        mvpBSButton.isEnabled = isMvpBSSelected
    }
    
    @objc func installAction () {
        if isMvvmSelected {
            if isMvvmBSSelected {
                templates.append(Template(name: Constants.ArchtFiles.mvvmTemplate, directory: Constants.FilesDirectory.mvvmBsArch))
                templates.append(Template(name: Constants.UtilFiles.baseServiceTemplate, directory: Constants.FilesDirectory.utils))
            } else {
                templates.append(Template(name: Constants.ArchtFiles.mvvmTemplate, directory: Constants.FilesDirectory.mvvmArch))
            }
        }
        
//        if baseServiceButton.stringValue == "1" {
//            templates.append(Template(name: Constants.UtilFiles.baseServiceTemplate, directory: Constants.FilesDirectory.utils))
//        }
        
        taskManager.enter()
        createDirectory { [weak self] (error) in
            guard let strongSelf = self else { return }
            
            if let error = error {
                let alert = Alert(message: error.message, description: error.description, okTitle: "OK", type: .error, okAction: {
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
                let alert = Alert(message: templatesInstalled == 1 ? Constants.Messages.successMessageSingular : Constants.Messages.successMessagePlural, okTitle: "OK", type: .success)
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
            let alert = Alert(message: error.message, description: error.description, okTitle: "OK", type: .error, okAction: {
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
            let alert = Alert(message: String(format: Constants.Messages.replaceMessage, template.name), okTitle: "Replace", cancelTitle: "Cancel", type: .warning, okAction: {
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

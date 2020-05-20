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
        static let mvpBsArch = "architectures/MVP+BS/"
        static let mvpArch = "architectures/MVP/"
        static let utils = "utils/"
    }
    
    struct ArchtFiles {
        static let mvvmTemplate = "MVVM.xctemplate"
        static let mvpTemplate = "MVP.xctemplate"
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

struct Template: Equatable {
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
var selectedTemplates: [Template] = []
var processingTemplates: [Template] = []
var templatesInstalled: [Template] = []

// MARK: - Extensions

extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}

extension NSButton {
    func setupButton(with title: String, type: NSButton.ButtonType, isEnabled: Bool, target: AnyObject?, action: Selector?, bezel: NSButton.BezelStyle?, font: NSFont?) {
        self.title = title
        self.setButtonType(type)
        self.isEnabled = isEnabled
        self.target = target
        self.action = action
        
        if let bezelType = bezel {
            self.bezelStyle = bezelType
        }
        
        if let fontType = font {
            self.font = fontType
        }
    }
}

extension NSTextField {
    func setup(with title: String, backgroundColor: NSColor, isBezeled: Bool, isEditable: Bool, font: NSFont, align: NSTextAlignment) {
        self.stringValue = title
        self.backgroundColor = backgroundColor
        self.isBezeled = isBezeled
        self.isEditable = isEditable
        self.font = font
        self.alignment = align
    }
}

// MARK: - AppDelegate

class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: - IBOutlets
    
    let window = NSWindow(contentRect: NSRect(x:0, y:0, width:400, height:440),
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
    let uninstallButton = NSButton()
    let buttonsStack = NSStackView()
    
    // MARK: - Properties
    
    let handler = DelegatesHandler()
    let mvvmTemplate = Template(name: Constants.ArchtFiles.mvvmTemplate, directory: Constants.FilesDirectory.mvvmArch)
    let mvvmBSTemplate = Template(name: Constants.ArchtFiles.mvvmTemplate, directory: Constants.FilesDirectory.mvvmBsArch)
    let mvpTemplate = Template(name: Constants.ArchtFiles.mvpTemplate, directory: Constants.FilesDirectory.mvpArch)
    let mvpBSTemplate = Template(name: Constants.ArchtFiles.mvpTemplate, directory: Constants.FilesDirectory.mvpBsArch)
    let bsTemplate = Template(name: Constants.UtilFiles.baseServiceTemplate, directory: Constants.FilesDirectory.utils)
    
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
                
        // Create subtitle
        subtitle.setup(with: "Choose the templates you want to install:", backgroundColor: .clear, isBezeled: false, isEditable: false, font: NSFont.systemFont(ofSize: 18), align: .center)
        
        // Create Base Service title
        baseServiceTitle.setup(with: "Include\nBase Service", backgroundColor: .clear, isBezeled: false, isEditable: false, font: NSFont.systemFont(ofSize: 14), align: .center)
        
        // Create buttons
        mvvmButton.setupButton(with: "MVVM Template", type: .switch, isEnabled: true, target: self, action: #selector(mvvmButtonAction), bezel: nil, font: nil)
        
        mvvmBSButton.setupButton(with: "", type: .switch, isEnabled: mvvmBSButton.stringValue == "1", target: self, action: #selector(mvvmBSButtonAction), bezel: nil, font: nil)
        
        mvpButton.setupButton(with: "MVP Template", type: .switch, isEnabled: true, target: self, action: #selector(mvpButtonAction), bezel: nil, font: nil)
        
        mvpBSButton.setupButton(with: "", type: .switch, isEnabled: mvpBSButton.stringValue == "1", target: self, action: #selector(mvpBSButtonAction), bezel: nil, font: nil)
        
        installButton.setupButton(with: "Install", type: .toggle, isEnabled: true, target: self, action: #selector(installAction), bezel: .rounded, font: NSFont.systemFont(ofSize: 14))
        
        uninstallButton.setupButton(with: "Uninstall", type: .toggle, isEnabled: false, target: self, action: #selector(uninstallAction), bezel: .rounded, font: NSFont.systemFont(ofSize: 14))
        
        buttonsStack.orientation = .horizontal
        buttonsStack.setViews([installButton, uninstallButton], in: .center)
        
        addViews(views: [imageView, subtitle, baseServiceTitle, mvvmButton, mvvmBSButton, mvpButton, mvpBSButton, buttonsStack])
    }
    
    private func addViews(views: [NSView]) {
        for view in views {
            window.contentView!.addSubview(view)
        }
    }
    
    private func setupLayout() {
        translatesIntoConstraints(views: [imageView, title, subtitle, baseServiceTitle, mvvmButton, mvvmBSButton,
                                          mvpButton, mvpBSButton, installButton, uninstallButton, buttonsStack])
        
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
            
            buttonsStack.topAnchor.constraint(equalTo: mvpButton.bottomAnchor, constant: 30),
            buttonsStack.centerXAnchor.constraint(equalTo: window.contentView!.centerXAnchor, constant: 0),
            buttonsStack.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func translatesIntoConstraints(views: [NSView]) {
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    // MARK: - Actions
    
    @objc func mvvmButtonAction() {
        mvvmBSButton.isEnabled = mvvmButton.stringValue == "1"
        
        if mvvmBSButton.isEnabled {
            selectedTemplates.append(mvvmTemplate)
        } else {
            _ = selectedTemplates.firstIndex(of: mvvmTemplate).map { selectedTemplates.remove(at: $0) }
        }
    }
    
    @objc func mvpButtonAction() {
        mvpBSButton.isEnabled = mvpButton.stringValue == "1"
        
        if mvpBSButton.isEnabled {
            selectedTemplates.append(mvpTemplate)
        } else {
            _ = selectedTemplates.firstIndex(of: mvpTemplate).map { selectedTemplates.remove(at: $0) }
        }
    }
    
    @objc func mvvmBSButtonAction() {
        if mvvmBSButton.stringValue == "1" {
            _ = selectedTemplates.firstIndex(of: mvvmTemplate).map { selectedTemplates.remove(at: $0) }
            selectedTemplates.append(mvvmBSTemplate)
            
            if !FileManager.default.fileExists(atPath: "\(destinationPath)/\(bsTemplate.name)") {
                selectedTemplates.append(bsTemplate)
            }
        } else {
            _ = selectedTemplates.firstIndex(of: mvvmBSTemplate).map { selectedTemplates.remove(at: $0) }
            _ = selectedTemplates.firstIndex(of: bsTemplate).map { selectedTemplates.remove(at: $0) }
            selectedTemplates.append(mvvmTemplate)
        }
    }
    
    @objc func mvpBSButtonAction() {
        if mvpBSButton.stringValue == "1" {
            _ = selectedTemplates.firstIndex(of: mvpTemplate).map { selectedTemplates.remove(at: $0) }
            selectedTemplates.append(mvpBSTemplate)
            
            if !FileManager.default.fileExists(atPath: "\(destinationPath)/\(bsTemplate.name)") {
                selectedTemplates.append(bsTemplate)
            }
        } else {
             _ = selectedTemplates.firstIndex(of: mvpBSTemplate).map { selectedTemplates.remove(at: $0) }
            _ = selectedTemplates.firstIndex(of: bsTemplate).map { selectedTemplates.remove(at: $0) }
            selectedTemplates.append(mvpTemplate)
        }
    }
    
    @objc func installAction () {
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

        processingTemplates = selectedTemplates
        installTemplates(on: window)

        taskManager.notify(queue: .main) { [weak self] in
            guard let strongSelf = self else { return }
            
            if templatesInstalled.count == selectedTemplates.count {
                let alert = Alert(message: templatesInstalled.count == 1 ? Constants.Messages.successMessageSingular : Constants.Messages.successMessagePlural, okTitle: "OK", type: .success)
                alert.show(on: strongSelf.window)
                templatesInstalled = []
            }
        }
    }
    
    @objc func uninstallAction () {
    
    }
}

// MARK: - Files Management

func installTemplates(on window: NSWindow) {
    guard processingTemplates.count > 0 else { return }
    
    let template = processingTemplates.first!
    
    func nextTemplate() {
        processingTemplates.removeFirst()
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
            templatesInstalled.append(template)
            nextTemplate()
            taskManager.leave()
        }
    }
}

func install(template: Template, on window: NSWindow, completion:((_ error: ErrorMessage?) -> Void)?) {
    if !fileManager.fileExists(atPath: "\(destinationPath)/\(template.name)") {
        do {
            try add(template: template)
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
                        try replace(template: template)
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

func add(template: Template) throws {
    try fileManager.copyItem(atPath: template.path(), toPath: "\(destinationPath)/\(template.name)")
}

func replace(template: Template) throws {
    let oldPath = URL(fileURLWithPath: "\(destinationPath)/\(template.name)")
    let newPath = URL(fileURLWithPath: template.path())
        
    try fileManager.removeItem(at: oldPath)
    try fileManager.copyItem(atPath: newPath.path, toPath: oldPath.path)
}

func remove(template: Template) throws {
    let path = URL(fileURLWithPath: "\(destinationPath)/\(template.name)")
    
    try fileManager.removeItem(at: path)
}

// Run app
let delegate = AppDelegate()
app.delegate = delegate
app.run()





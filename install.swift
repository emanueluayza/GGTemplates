import Foundation

// MARK: - Constants

struct Constants {

    struct CommandLineValues {
        static let yes = "yes"
        static let no = "no"
        static let y = "y"
        static let n = "n"
    }
    
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
        static let creatingDirectoryMessage = "📁 Creating GGT Template directory... "
        static let installingMessage = "🔧 Installing GGT Template (%@) into: "
        static let successMessage = "✅ GGT Template (%@) was installed succesfully 🎉."
        static let errorMessage = "❌ Ooops! Something went wrong 😕"
        static let replaceMessage = "❗The GGT Template (%@) already exists. Do you want to replace it? (YES or NO)"
        static let successfullReplaceMessage = "✅ The GGT Template (%@) has been replaced for you with the new version 🎉."
        static let skipReplacementMessage = "⏭ The GGT Template (%@) replacement was skipped."
        static let exitMessage = "See you later 👋"
    }

    struct Blocks {
        static let printSeparator = { print("====================================") }
    }
}

// MARK: - Prints

func printToConsole(_ message:Any){
    Constants.Blocks.printSeparator()
    print("\(message)")
    Constants.Blocks.printSeparator()
}

// MARK: - Files Management

func installTemplate(template: String, from directory: String) {
    do {
        let fileManager = FileManager.default
        let destinationPath = bash(command: "xcode-select", arguments: ["--print-path"]).appending(Constants.Paths.destinationPath)
        var isDir : ObjCBool = false
                    
        if fileManager.fileExists(atPath: destinationPath, isDirectory:&isDir) {
            if isDir.boolValue {
                // Directory exists. Move forward...
            } else {
                // There is a file with the same name but is not a directory.
                printToConsole(Constants.Messages.errorMessage)
            }
        } else {
            // Directory doesn't exist.
            printToConsole(Constants.Messages.creatingDirectoryMessage)
            
            do {
                try FileManager.default.createDirectory(atPath: destinationPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                printToConsole("\(Constants.Messages.errorMessage) : \(error)")
            }
        }
        
        if !fileManager.fileExists(atPath: "\(destinationPath)/\(template)"){
            printToConsole(String(format: Constants.Messages.installingMessage, template) + destinationPath)
            try fileManager.copyItem(atPath: directory + template, toPath: "\(destinationPath)/\(template)")
            printToConsole(String(format: Constants.Messages.successMessage, template))
        } else {
            printToConsole(String(format: Constants.Messages.replaceMessage, template))
            var input = ""
            repeat {
                guard let textFormCommandLine = readLine(strippingNewline: true) else {
                    continue
                }
                input = textFormCommandLine.lowercased()
                
            } while(input != Constants.CommandLineValues.yes && input != Constants.CommandLineValues.y && input != Constants.CommandLineValues.no && input != Constants.CommandLineValues.n)

            if input == Constants.CommandLineValues.yes || input == Constants.CommandLineValues.y {
                try replaceItemAt(URL(fileURLWithPath: "\(destinationPath)/\(template)"), withItemAt: URL(fileURLWithPath: directory + template))
                printToConsole(String(format: Constants.Messages.successfullReplaceMessage, template))
            } else {
                printToConsole(String(format: Constants.Messages.skipReplacementMessage, template))
            }
        }
    }

    catch let error as NSError {
        printToConsole("\(Constants.Messages.errorMessage) : \(error.localizedFailureReason!)")
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

// MARK: - Perform Installation

installTemplate(template: Constants.ArchtFiles.mvvmTemplate, from: Constants.FilesDirectory.architectures)
installTemplate(template: Constants.UtilFiles.baseServiceTemplate, from: Constants.FilesDirectory.utils)
printToConsole(Constants.Messages.exitMessage)

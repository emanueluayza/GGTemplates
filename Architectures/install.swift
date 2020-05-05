import Foundation

// MARK: - Constants

struct Constants {

    struct CommandLineValues {
        static let yes = "YES"
        static let no = "NO"
    }
    
    struct Files {
        static let mvvmTemplate = "GGT-MVVM.xctemplate"
    }
    
    struct Paths {
        static let destinationPath = "/Library/Xcode/Templates/File Templates/GGToolsTemplates"
    }

    struct Messages {
        static let installingMessage = "📑 GGT Template will be copied to: "
        static let successMessage = "✅  GGT Template was installed succesfully 🎉."
        static let successfullReplaceMessage = "✅  The GGT Template has been replaced for you with the new version 🎉."
        static let errorMessage = "❌  Ooops! Something went wrong 😕"
        static let exitMessage = "See you later 👋"
        static let promptReplace = "❕ That GGT Template already exists. Do you want to replace it? (YES or NO)"
        static let creatingDirectory = "🏗  Creating GGT Template directory... "
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

func installTemplate(){
    do {
        let fileManager = FileManager.default
        let destinationPath = bash(command: "xcode-select", arguments: ["--print-path"]).appending(Constants.Paths.destinationPath)
        var isDir : ObjCBool = false
                    
        if fileManager.fileExists(atPath: destinationPath, isDirectory:&isDir) {
            if isDir.boolValue {
                // file exists and is a directory
                printToConsole(Constants.Messages.installingMessage + destinationPath)
            } else {
                // file exists and is not a directory
                printToConsole(Constants.Messages.errorMessage)
            }
        } else {
            // file does not exist
            printToConsole(Constants.Messages.creatingDirectory)
            
            do {
                try FileManager.default.createDirectory(atPath: destinationPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                printToConsole("\(Constants.Messages.errorMessage) : \(error)")
            }
        }
        
        if !fileManager.fileExists(atPath: "\(destinationPath)/\(Constants.Files.mvvmTemplate)"){
            print(Constants.Files.mvvmTemplate)
            try fileManager.copyItem(atPath: Constants.Files.mvvmTemplate, toPath: "\(destinationPath)/\(Constants.Files.mvvmTemplate)")
            printToConsole(Constants.Messages.successMessage)
        } else {
            print(Constants.Messages.promptReplace)
            var input = ""
            repeat {
                guard let textFormCommandLine = readLine(strippingNewline: true) else {
                    continue
                }
                input = textFormCommandLine.uppercased()
            } while(input != Constants.CommandLineValues.yes && input != Constants.CommandLineValues.no)

            if input == Constants.CommandLineValues.yes {
                try replaceItemAt(URL(fileURLWithPath: "\(destinationPath)/\(Constants.Files.mvvmTemplate)"), withItemAt: URL(fileURLWithPath: Constants.Files.mvvmTemplate))
                printToConsole(Constants.Messages.successfullReplaceMessage)
            } else {
                print(Constants.Messages.exitMessage)
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

installTemplate()

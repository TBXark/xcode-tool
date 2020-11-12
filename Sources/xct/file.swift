//
//  file.swift
//  xct
//
//  Created by TBXark on 2020/11/12.
//

import Foundation
import XcodeProj
import PathKit

struct CleanFileTool: CommandHandler {
    
    let key: String = "clean-file"
    let help = """
    xct clean-file <project> <location>...
    // example: xct clean-file ./xctdemo.xcodeproj /Sources /Tests
    arguments:
        <project>: path to *.xcodeproj
        <location>...: path to target directory
    """
    
    func run(arguments: [String]) {
        do {
            guard arguments.count >= 2 else {
                throw xctError(reason: help)
            }
            let projectPath = Path(arguments[0]).absolute()
            let xcodeproj = try XcodeProj(path: projectPath)
            let fileNameSet = Set([
                xcodeproj.pbxproj.buildFiles.compactMap({ $0.file?.path}),
                xcodeproj.pbxproj.copyFilesBuildPhases.compactMap({ $0.dstPath })
            ].flatMap({ $0 }))
            var localFiles = [String]()
            for i in 1..<arguments.count {
                localFiles.append(contentsOf: getAllFilePath(Path(arguments[i]).absolute().string))
            }
            for file in localFiles {
                if !fileNameSet.contains((file as NSString).lastPathComponent) {
                    print(file)
                }
            }
        } catch {
            fputs("error: \(error.localizedDescription)\n\(help)", stderr)
            exit(1)
        }
    }
    
    private func getAllFilePath(_ dirPath: String) -> [String] {
        guard let array = try? FileManager.default.contentsOfDirectory(atPath: dirPath) else {
            return []
        }
        var filePaths = [String]()
        for fileName in array {
            var isDir: ObjCBool = true
            let fullPath = "\(dirPath)/\(fileName)"
            if FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDir) {
                if isDir.boolValue {
                    if fileName.hasSuffix(".xcassets") || fileName.hasSuffix(".bundle") {
                        filePaths.append(fullPath)
                    } else {
                        filePaths.append(contentsOf: getAllFilePath(fullPath))
                    }
                } else {
                    if fileName != ".DS_Store" {
                        filePaths.append(fullPath)
                    }
                }
            }
        }
        return filePaths
    }
}

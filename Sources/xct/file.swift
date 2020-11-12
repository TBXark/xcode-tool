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
    usage: xct clean-file <project> <location>
    """
    
    func run(arguments: [String]) {
        do {
            guard arguments.count >= 2 else {
                throw xtcError(reason: help)
            }
            let projectPath = Path(arguments[0]).absolute()
            let xcodeproj = try XcodeProj(path: projectPath)
            var paths = [String]()
            paths.append(contentsOf: xcodeproj.pbxproj.buildFiles.compactMap({ $0.file?.path}))
            paths.append(contentsOf: xcodeproj.pbxproj.copyFilesBuildPhases.compactMap({ $0.dstPath }))
            let fileNameSet = Set(paths)
            var localFiles = getAllFilePath(Path(arguments[1]).absolute().string)
            if arguments.count > 2 {
                for i in 2..<arguments.count {
                    localFiles.append(contentsOf: getAllFilePath(Path(arguments[i]).absolute().string))
                }
            }
            for file in localFiles {
                if !fileNameSet.contains((file as NSString).lastPathComponent) {
                    print(file)
                }
            }
        } catch {
            fputs("error: \(error.localizedDescription)n", stderr)
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
            
            if fileName == ".DS_Store" {
                continue
            }
            if FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDir) {
                if isDir.boolValue {
                    if fileName.hasSuffix(".xcassets") || fileName.hasSuffix(".bundle") {
                        filePaths.append(fullPath)
                    } else {
                        filePaths.append(contentsOf: getAllFilePath(fullPath))
                    }
                } else {
                    filePaths.append(fullPath)
                }
            }
        }
        return filePaths
    }
    


}

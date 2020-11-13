//
//  file.swift
//  xct
//
//  Created by TBXark on 2020/11/12.
//

import Foundation
import XcodeProj
import PathKit

struct FileCleaner: CommandService {

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
            guard let projectPath = arguments.first.map({ Path($0).absolute() }) else {
                throw xctError(reason: "project path not found")
            }
            guard arguments.count > 1 else {
                throw xctError(reason: "target location path not found")
            }
            let xcodeproj = try XcodeProj(path: projectPath)
            let fileNameSet = Set([
                xcodeproj.pbxproj.buildFiles.compactMap({ $0.file?.path}),
                xcodeproj.pbxproj.copyFilesBuildPhases.compactMap({ $0.dstPath })
            ].flatMap({ $0 }))
            var localFiles = [Path]()
            for i in 1..<arguments.count {
                localFiles.append(contentsOf: getAllFilePath(Path(arguments[i]).absolute()))
            }
            for file in localFiles {
                if !fileNameSet.contains(file.lastComponent) {
                    print(file)
                }
            }
        } catch {
            fputs("error: \(error.localizedDescription)\n\(help)", stderr)
            exit(1)
        }
    }

    private func getAllFilePath(_ dirPath: Path) -> [Path] {
        var paths = [Path]()
        for sub in (try? dirPath.children()) ?? [] {
            let name = sub.lastComponent
            if sub.isDirectory {
                if name.hasSuffix(".xcassets") || name.hasSuffix(".bundle") {
                    paths.append(sub)
                } else {
                    paths.append(contentsOf: getAllFilePath(sub))
                }
            } else {
                if name != ".DS_Store" {
                    paths.append(sub)
                }
            }
        }
        return paths
    }
}

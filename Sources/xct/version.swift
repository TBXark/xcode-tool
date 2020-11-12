//
//  version.swift
//  xct
//
//  Created by TBXark on 2020/11/12.
//

import Foundation
import XcodeProj
import PathKit


struct VersionTool: CommandHandler {
    
    let key = "version"
    let help = """
    usage: xct version <project> <bundle_id> <command> [version]
        get/set project version: \(VersionData.projectVersionSet.joined(separator: ", "))
        get/set market version: \(VersionData.marketVersionSet.joined(separator: ", "))
    """

    struct VersionData {
        static let projectVersionSet  = ["--projectVersion", "-p", "-pv"]
        static let marketVersionSet = ["--marketVersion", "-m", "-mv"]
        
        var project: String
        var bundleId: String
        var key: String
        var version: String?
        
        init?(arguments: [String]) {
            guard arguments.count >= 2,
                  let key =  VersionData.command2Key(arguments[2]) else {
                return nil
            }
            self.project = arguments[0]
            self.bundleId = arguments[1]
            self.key = key
            self.version = arguments.count > 3 ? arguments[3] : nil
        }
        
        init(project: String, bundleId: String, key: String, version: String?) {
            self.project = project
            self.bundleId = bundleId
            self.key = key
            self.version = version
        }
        
        static private func command2Key(_ value: String) -> String? {
            return projectVersionSet.contains(value) ? "CURRENT_PROJECT_VERSION" : (marketVersionSet.contains(value) ? "MARKETING_VERSION": nil)
        }
    }
    
    
    func run(arguments: [String]) {
        do {
            guard let command = VersionData(arguments: arguments) else {
                throw xtcError(reason: help)
            }
            let projectPath = Path(command.project).absolute()
            let xcodeproj = try XcodeProj(path: projectPath)

            if let version = command.version {
                if version.range(of: "^[\\d\\.]*[\\d]+$", options: .regularExpression, range: nil, locale: nil) != nil {
                    for conf in xcodeproj.pbxproj.buildConfigurations {
                        if conf.buildSettings["PRODUCT_BUNDLE_IDENTIFIER"].flatMap({ $0 as? String }) == command.bundleId, conf.buildSettings[command.key] != nil {
                            conf.buildSettings[command.key] = version
                        }
                    }
                    try xcodeproj.write(path: projectPath)
                    fputs(command.version, stdout)
                    exit(0)
                } else {
                    fputs("error: \(version) is an illegal version number, please enter a legal version number\n", stderr)
                    exit(1)
                }
            } else {
                for conf in xcodeproj.pbxproj.buildConfigurations {
                    if  conf.buildSettings["PRODUCT_BUNDLE_IDENTIFIER"].flatMap({ $0 as? String }) == command.bundleId,
                        let version = conf.buildSettings[command.key].flatMap({ $0 as? String }) {
                        fputs(version, stdout)
                        exit(0)
                    }
                }
            }
        } catch {
            fputs("error: \(error.localizedDescription)n", stderr)
            exit(1)
        }
    }
}


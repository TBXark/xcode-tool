//
//  utils.swift
//  xct
//
//  Created by TBXark on 2020/11/12.
//

import Foundation
import JsonMapper
import PathKit

func xctError(code: Int = 0, reason: String) -> Error {
    return NSError(domain: "com.tbxark.xtc", code: code, userInfo: [NSLocalizedFailureReasonErrorKey: reason])
}

struct JSONReader: CommandService {
    let key: String = "json"
    let help = """
    xct json <json-string> [keypath]...
    // example: xct json '{"data": { "version": 1}}' 'data.version'
    arguments:
        <json-string>: The json string to be parsed
        [keyPath]: json keypath
    """
    func run(arguments: [String]) {
        if arguments.count >= 1 {
            var json = (try? JSONElement(rawJSON: arguments[0])) ?? JSONElement.null
            if arguments.count >= 2 {
                for key in 1..<arguments.count {
                    json = json[keyPath: arguments[key]]
                }
            }
            if let v = json.rawValue {
                fputs("\(v)", stdout)
            }
        }
        exit(0)
    }
}


func findAllDirectoryPaths(_ dirPath: Path, suffix: String) -> [Path] {
    var paths = [Path]()
    do {
        let children = try dirPath.children()
        for sub in children {
            if sub.isDirectory {
                if sub.lastComponent.hasSuffix(suffix) {
                    paths.append(sub)
                } else {
                    paths.append(contentsOf: findAllDirectoryPaths(sub, suffix: suffix))
                }
            }
        }
    } catch {
        fputs(error.localizedDescription, stderr)
    }
    return paths
}


func findAllFilePaths(_ dirPath: Path, suffix: String) -> [Path] {
    var paths = [Path]()
    for sub in (try? dirPath.children()) ?? [] {
        if sub.isDirectory {
            paths.append(contentsOf: findAllFilePaths(sub, suffix: suffix))
        } else if sub.lastComponent.hasSuffix(suffix) {
            paths.append(sub)
        }
    }
    return paths
}

//
//  asset.swift
//  xct
//
//  Created by TBXark on 2020/11/12.
//

import Foundation
import JsonMapper
import PathKit

private func getAllImagesetPaths(_ dirPath: Path) -> [Path] {
    var paths = [Path]()
    for sub in (try? dirPath.children()) ?? [] {
        let name = sub.lastComponent
        if sub.isDirectory {
            if name.hasSuffix(".imageset"){
                paths.append(sub)
            } else {
                paths.append(contentsOf: getAllImagesetPaths(sub))
            }
        }
    }
    return paths
}

struct RenameAsset: CommandService {
    let key: String = "rename-asset"
    let help: String = ""
    
    
    func run(arguments: [String]) {
        do {
            guard let dir = arguments.first else {
                throw xctError(reason: help)
            }
            let paths = getAllImagesetPaths(Path(arguments[0]))
            fputs("Find \(paths.count) assets in \(dir)", stdout)
            for asset in paths {
                let jsonPath = "\(asset)/Contents.json"
                let data = try Data(contentsOf: URL(fileURLWithPath: jsonPath))
                let info = try JSONDecoder().decode(JSONElement.self, from: data)
                let assetName = asset.lastComponentWithoutExtension
                guard var json = String(data: data, encoding: .utf8) else {
                    continue
                }
                var didUpdate = false
                for image in info.images.arrayValue ?? [] {
                    guard let name = image.filename.stringValue,
                          let type = name.split(separator: ".").last else {
                        continue
                    }
                    let targetName = "\(assetName)\(image.scale.stringValue.map({ "@\($0)" }) ?? "").\(type)"
                    if targetName != name {
                        try FileManager.default.moveItem(atPath: "\(asset)/\(name)", toPath: "\(asset)/\(targetName)")
                        didUpdate = true
                        json = json.replacingOccurrences(of: "\"filename\" *: *\"\(name)\"", with: "\"filename\" : \"\(targetName)\"", options: .regularExpression, range: nil)
                    }
                }
                if didUpdate, let jsonData = json.data(using: .utf8) {
                    try jsonData.write(to: URL(fileURLWithPath: jsonPath), options: Data.WritingOptions.atomicWrite)
                }
            }
        } catch {
            fputs("error: \(error.localizedDescription)\n\(help)", stderr)
            exit(1)
        }
    }
}

//
//  asset.swift
//  xct
//
//  Created by TBXark on 2020/11/12.
//

import Foundation
import JsonMapper
import PathKit

struct RenameAsset: CommandService {
    let key: String = "rename-asset"
    let help = """
    xct rename-asset <location>
    // example: xct rename-asset ./xctdemo/Sources
    arguments:
        <location>: path to target directory
    """

    func run(arguments: [String]) {
        do {
            guard let dir = arguments.first.map({ Path($0).absolute() }) else {
                throw xctError(reason: "target location path not found")
            }
            let paths = findAllDirectoryPaths(dir, suffix: ".imageset")
            fputs("Find \(paths.count) assets in \(dir)", stdout)
            for asset in paths {
                let jsonPath = asset + "Contents.json"

                let data: Data = try jsonPath.read()
                var json: String = try jsonPath.read()
                let info = try JSONDecoder().decode(JSONElement.self, from: data)

                let assetName = asset.lastComponentWithoutExtension
                var didUpdate = false

                for image in info.images.arrayValue ?? [] {
                    guard let name = image.filename.stringValue,
                          let type = name.split(separator: ".").last else {
                        continue
                    }
                    let targetName = "\(assetName)\(image.scale.stringValue.map({ "@\($0)" }) ?? "").\(type)"
                    if targetName != name {
                        try (asset + name).move(asset + targetName)
                        didUpdate = true
                        json = json.replacingOccurrences(of: "\"filename\" *: *\"\(name)\"", with: "\"filename\" : \"\(targetName)\"", options: .regularExpression, range: nil)
                    }
                }

                if didUpdate, let jsonData = json.data(using: .utf8) {
                    try jsonPath.write(jsonData)
                }
            }
        } catch {
            fputs("error: \(error.localizedDescription)\n\(help)", stderr)
            exit(1)
        }
    }
}

struct AssetCleaner: CommandService {
    let key: String = "clean-asset"
    let help = """
    xct clean-asset <location>
    // example: xct clean-asset ./xctdemo/Sources
    arguments:
        <location>: path to target directory
    """
    func run(arguments: [String]) {
        do {
            guard let dir = arguments.first.map({ Path($0).absolute()  }) else {
                throw xctError(reason: "target location path not found")
            }
            var assets = findAllDirectoryPaths(dir, suffix: ".xcassets")
                .map({
                    (xcassets: $0, imageset: Set(findAllDirectoryPaths($0, suffix: ".imageset")))
                })
            let swiftFile = findAllFilePaths(dir, suffix: ".swift").filter({ $0.lastComponent != "R.generated.swift" })
            for file in swiftFile {
                autoreleasepool { () -> Void in
                    do {
                        let text: String = try file.read()
                        for x in 0..<assets.count {
                            var find = [Path]()
                            for asset in assets[x].imageset {
                                let name = asset.lastComponentWithoutExtension
                                if text.contains("R.image.\(name)") || text.contains("#imageLiteral(resourceName: \"\(name)\")") || text.contains("UIImage(named: \"\(name)\")") {
                                    find.append(asset)
                                    fputs("\(file) find \(name)\n", stdout)
                                }
                                // else if text.range(of: "UIImage[\\.init]*\\(named: *\"\(name)\"", options: .regularExpression, range: nil, locale: nil) != nil {
                                //     find.append(asset)
                                //     fputs("\(file) find \(name)\n", stdout)
                                // }
                            }
                            for asset in find {
                                assets[x].imageset.remove(asset)
                            }
                        }
                    } catch {
                        fputs("\(error.localizedDescription)\n", stderr)
                    }
                }
            }
            fputs("\n\n\n\nunused imageset\n", stdout)
            let output = assets.map({ item -> [String] in
                return item.imageset.map({ image -> String in
                    return "\(item.xcassets) -> \(image.lastComponentWithoutExtension)"
                })
            }).flatMap({ $0 }).joined(separator: "\n")
            fputs(output, stdout)
        } catch {
            fputs("error: \(error.localizedDescription)\n\(help)", stderr)
            exit(1)
        }
    }
}

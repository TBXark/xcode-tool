//
//  color.swift
//  xct
//
//  Created by TBXark on 2020/11/13.
//

import Foundation
import PathKit

private func hex2color(_ hexString: String) -> String? {
    var red = CGFloat(0)
    var green = CGFloat(0)
    var blue = CGFloat(0)
    var alpha = CGFloat(1)
    var hex = hexString
    if hex.hasPrefix("#") {
        _ = hex.removeFirst()
    }
    let scanner = Scanner(string: hex)
    var hexValue = CUnsignedLongLong(0)
    if scanner.scanHexInt64(&hexValue) {
        switch hex.count {
        case 3:
            red = CGFloat((hexValue & 0xF00) >> 8) / 15.0
            green = CGFloat((hexValue & 0x0F0) >> 4) / 15.0
            blue = CGFloat(hexValue & 0x00F) / 15.0
        case 4:
            red = CGFloat((hexValue & 0xF000) >> 12) / 15.0
            green = CGFloat((hexValue & 0x0F00) >> 8) / 15.0
            blue = CGFloat((hexValue & 0x00F0) >> 4) / 15.0
            alpha = CGFloat(hexValue & 0x000F) / 15.0
        case 6:
            red = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
            green = CGFloat((hexValue & 0x00FF00) >> 8) / 255.0
            blue = CGFloat(hexValue & 0x0000FF) / 255.0
        case 8:
            red = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
            green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
            blue = CGFloat((hexValue & 0x0000FF00) >> 8) / 255.0
            alpha = CGFloat(hexValue & 0x000000FF) / 255.0
        default:
            return nil
        }
    } else {
        return nil
    }
    return String(format: "UIColor(red: %.3f, green: %.3f, blue: %.3f, alpha: %.3f)", red, green, blue, alpha)
}

struct Hex2UIColor: CommandService {
    let key: String = "hex"
    let help = """
    xct hex <color>
    // example: xct hex #232323
    arguments:
        <color>: hex color string
    """
    
    func run(arguments: [String]) {
        guard let hex = arguments.first else {
            fputs("hex string not found\n\(help)", stderr)
            return
        }
        if let color = hex2color(hex) {
            fputs(color, stdout)
        } else {
            fputs("hex string is illegal\n\(help)", stderr)
        }
        
    }
}

struct ReplaceHex2UIColor: CommandService {
    let key: String = "replace-hex"
    let help = """
    xct hex <location>
    // example: xct replace-hex /xctdemo
    arguments:
        <location>: path to target directory
    """
    
    func run(arguments: [String]) {
        do {
            guard let dir = arguments.first.map({ Path($0).absolute() }) else {
                throw xctError(reason: "project path not found")
            }
            for file in findAllDirectoryPaths(dir, suffix: ".swift") {
                autoreleasepool { () -> Void in
                    do {
                        var text: String = try file.read()
                        var didChange = false
                        while let range = text.range(of: "UIColor\\(hexString: ?\"#?[a-zA-Z0-9]{6}\" ?\\)[!?]?", options: .regularExpression, range: nil, locale: nil) {
                            if let color = hex2color(String(text[range])) {
                                text.replaceSubrange(range, with: color)
                                didChange = true
                            } else {
                                fputs("error: Cannot process \(range) in \(file)\n", stderr)
                                break
                            }
                        }
                        if didChange {
                            try file.write(text, encoding: .utf8)
                        }
                    } catch {
                        fputs("\(error.localizedDescription)\n", stderr)
                    }
                }
            }
        } catch {
            fputs("error: \(error.localizedDescription)\n\(help)", stderr)
            exit(1)
        }
    }
}

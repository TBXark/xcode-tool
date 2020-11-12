//
//  main.swift
//  xct
//
//  Created by TBXark on 2020/11/12.
//
import Foundation
import XcodeProj
import PathKit

protocol CommandService {
    var key: String { get }
    var help: String { get }
    init()
    func run(arguments: [String])
}

let handlers: [CommandService] = [VersionTool(), FileCleaner(), RenameAsset(), JSONReader()]
var arguments = CommandLine.arguments
if arguments.count > 1, let handler = handlers.first(where: { $0.key == arguments[1]}) {
    arguments.removeFirst(2)
    handler.run(arguments: arguments)
} else {
    for handler in handlers {
        fputs("\(handler.help)\n\n", stderr)
    }
}

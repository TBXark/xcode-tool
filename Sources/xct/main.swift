//
//  main.swift
//  xct
//
//  Created by TBXark on 2020/11/12.
//
import Foundation
import XcodeProj
import PathKit

func xctError(code: Int = 0, reason: String) -> Error {
    return NSError(domain: "com.tbxark.xtc", code: code, userInfo: [NSLocalizedFailureReasonErrorKey: reason])
}

protocol CommandHandler {
    var key: String { get }
    var help: String { get }
    func run(arguments: [String])
}

let handlers: [CommandHandler] = [VersionTool(), CleanFileTool()]
var arguments = CommandLine.arguments
if arguments.count > 1, let handler = handlers.first(where: { $0.key == arguments[1]}) {
    arguments.removeFirst(2)
    handler.run(arguments: arguments)
} else {
    for handler in handlers {
        fputs("\(handler.help)\n\n", stderr)
    }
}

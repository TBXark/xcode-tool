//
//  utils.swift
//  xct
//
//  Created by TBXark on 2020/11/12.
//

import Foundation
import JsonMapper

func xctError(code: Int = 0, reason: String) -> Error {
    return NSError(domain: "com.tbxark.xtc", code: code, userInfo: [NSLocalizedFailureReasonErrorKey: reason])
}

struct JSONReader: CommandService {
    let key: String = "json"
    let help: String = ""
    
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

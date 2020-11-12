//
//  utils.swift
//  xct
//
//  Created by TBXark on 2020/11/12.
//

import Foundation

func xctError(code: Int = 0, reason: String) -> Error {
    return NSError(domain: "com.tbxark.xtc", code: code, userInfo: [NSLocalizedFailureReasonErrorKey: reason])
}

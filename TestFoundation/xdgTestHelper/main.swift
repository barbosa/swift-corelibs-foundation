// This source file is part of the Swift.org open source project
//
// Copyright (c) 2017 Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

#if DEPLOYMENT_RUNTIME_OBJC || os(Linux) || os(Android)
import Foundation
#else
import SwiftFoundation
#endif

enum HelperCheckStatus : Int32 {
    case ok                 = 0
    case fail               = 1
    case cookieStorageNil   = 20
    case cookieStorePathWrong
}


class XDGCheck {
    static func run() -> Never {
        let storage = HTTPCookieStorage.shared
        let properties: [HTTPCookiePropertyKey: String] = [
            .name: "TestCookie",
            .value: "Test @#$%^$&*99",
            .path: "/",
            .domain: "example.com",
            ]

        guard let simpleCookie = HTTPCookie(properties: properties) else {
            exit(HelperCheckStatus.cookieStorageNil.rawValue)
        }
        guard let rawValue = getenv("XDG_DATA_HOME"), let xdg_data_home = String(utf8String: rawValue) else {
            exit(HelperCheckStatus.fail.rawValue)
        }

        storage.setCookie(simpleCookie)
        let fm = FileManager.default

        guard let bundleName = Bundle.main.infoDictionary?["CFBundleName"] as? String else {
            exit(HelperCheckStatus.fail.rawValue)
        }
        let destPath = xdg_data_home + "/" + bundleName + "/.cookies.shared"
        var isDir: ObjCBool = false
        let exists = fm.fileExists(atPath: destPath, isDirectory: &isDir)
        if (!exists) {
            print("Expected cookie path: ", destPath)
            exit(HelperCheckStatus.cookieStorePathWrong.rawValue)
        }
        exit(HelperCheckStatus.ok.rawValue)
    }
}

if let arg = ProcessInfo.processInfo.arguments.last {
    if arg == "--xdgcheck" {
        XDGCheck.run()
    }
    if arg == "--getcwd" {
        print(FileManager.default.currentDirectoryPath)
    }
    if arg == "--echo-PWD" {
        print(ProcessInfo.processInfo.environment["PWD"] ?? "")
    }
}


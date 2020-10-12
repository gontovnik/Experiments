// Copyright © 2020 Danil Gontovnik. All rights reserved.

import Foundation

public protocol KeyValueStoring {
    func string(forKey defaultName: String) -> String?
    func set(_ value: Any?, forKey defaultName: String)
}

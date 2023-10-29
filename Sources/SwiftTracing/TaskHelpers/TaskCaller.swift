//
//  TaskCaller.swift
//
//
//  Created by Tomas Harkema on 11/08/2023.
//

import Foundation
import SwiftStacktrace

package enum TaskCaller {
  @TaskLocal static var caller: Caller?
}

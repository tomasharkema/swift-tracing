//
//  TaskCaller.swift
//
//
//  Created by Tomas Harkema on 11/08/2023.
//

import Foundation

#if DEBUG
enum TaskCaller {
    @TaskLocal static var caller: Caller?
}
#endif

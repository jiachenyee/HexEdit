//
//  HexEditApp.swift
//  HexEdit
//
//  Created by Jia Chen Yee on 28/1/22.
//

import SwiftUI

@main
struct HexEditApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: HexEditDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}

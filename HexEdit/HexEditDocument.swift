//
//  HexEditDocument.swift
//  HexEdit
//
//  Created by Jia Chen Yee on 28/1/22.
//

import SwiftUI
import UniformTypeIdentifiers

struct HexEditDocument: FileDocument {
    static var readableContentTypes: [UTType] = [.data]
    
    var data: Data = Data()

    init(data: Data = Data()) {
        self.data = data
    }
//    static var readableContentTypes: [UTType] { [.exampleText] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return .init(regularFileWithContents: data)
    }
}

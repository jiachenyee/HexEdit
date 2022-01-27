//
//  ContentView.swift
//  HexEdit
//
//  Created by Jia Chen Yee on 28/1/22.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: HexEditDocument

    var body: some View {
        TextEditor(text: $document.text)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(HexEditDocument()))
    }
}

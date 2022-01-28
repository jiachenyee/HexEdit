//
//  ContentView.swift
//  HexEdit
//
//  Created by Jia Chen Yee on 28/1/22.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @Binding var document: HexEditDocument
    @State var addMenuPresented = false
    
    @State var inputText = ""
    
    var body: some View {
        TextEditor(text: $inputText)
            .font(.system(.body, design: .monospaced))
            .onChange(of: inputText) { newValue in
                inputText = newValue.filter { $0.isHexDigit }.separate(every: 2, with: " ")
                
                document.data = newValue.filter {
                    $0.isHexDigit
                }.hexadecimal ?? Data()
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigation) {
                    Button {
                        addMenuPresented = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .popover(isPresented: $addMenuPresented) {
                        AddTextView { str in
                            document.data.append(contentsOf: str)
                        }
                    }
                }
            }
            .onAppear {
                inputText = document.data.reduce(into: "") { acc, byte in
                    var s = String(byte, radix: 16)
                    if s.count == 1 {
                        s = "0" + s
                    }
                    acc += s + " "
                }
            }
    }
    func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
    
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(document: .constant(HexEditDocument()))
//    }
//}

extension String {
    
    /// Create `Data` from hexadecimal string representation
    ///
    /// This creates a `Data` object from hex string. Note, if the string has any spaces or non-hex characters (e.g. starts with '<' and with a '>'), those are ignored and only hex characters are processed.
    ///
    /// - returns: Data represented by this hexadecimal string.
    
    var hexadecimal: Data? {
        var data = Data(capacity: count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        
        guard data.count > 0 else { return nil }
        
        return data
    }
    
}

extension String {
    func separate(every stride: Int = 4, with separator: Character = " ") -> String {
        return String(enumerated().map { $0 > 0 && $0 % stride == 0 ? [separator, $1] : [$1]}.joined())
    }
}

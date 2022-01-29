//
//  ContentView.swift
//  HexEdit
//
//  Created by Jia Chen Yee on 28/1/22.
//

import SwiftUI
import Introspect
import UniformTypeIdentifiers

class TextViewCoordinator: NSObject, ObservableObject, NSTextViewDelegate {
    
    @Published var range: NSRange? = nil
    @Published var text: String = "" {
        didSet {
            textView!.string = text
        }
    }
    
    var textView: NSTextView?
    
    func textViewDidChangeSelection(_ notification: Notification) {
        range = textView?.selectedRange()
    }
    
    func textDidChange(_ notification: Notification) {
        textChange()
    }
    func textChange() {
        textView!.string = textView!.string.filter { $0.isHexDigit }.separate(every: 2, with: " ")
        text = textView!.string
        range = textView?.selectedRange()
    }
}

struct ContentView: View {
    @Binding var document: HexEditDocument
    @State var addMenuPresented = false
    
    @StateObject var textViewCoordinator = TextViewCoordinator()
    
    @State var inputText = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                List {
                    if let value = textViewCoordinator.text.substring(with: textViewCoordinator.range ?? NSRange(location: 0, length: 0)) {
                        let string = String(value)
                        let data = string.filter {
                            $0.isHexDigit
                        }.hexadecimal ?? Data()
                        
                        Section {
                            TextEditor(text: .constant(string))
                                .introspectTextView { textView in
                                    textView.backgroundColor = .clear
                                    textView.isEditable = false
                                    textView.isSelectable = false
                                }
                                .font(.system(.body, design: .monospaced))
                        } header: {
                            Label("Selected Text", systemImage: "selection.pin.in.out")
                        }
                        
                        Section {
                            TextEditor(text: .constant(data.reduce("") { partialResult, value in
                                partialResult + "\(value) "
                            }))
                                .introspectTextView { textView in
                                    textView.backgroundColor = .clear
                                    textView.isEditable = false
                                    textView.isSelectable = false
                                }
                                .font(.system(.body, design: .monospaced))
                        } header: {
                            Label("Decimal", systemImage: "textformat.123")
                        }
                        
                        Section {
                            TextEditor(text: .constant(String(data: data, encoding: .utf8) ?? "Invalid UTF8"))
                                .introspectTextView { textView in
                                    textView.backgroundColor = .clear
                                    textView.isEditable = false
                                    textView.isSelectable = false
                                }
                                .font(.system(.body, design: .monospaced))
                        } header: {
                            Label("UTF-8", systemImage: "abc")
                        }
                        
                        Section {
                            let str = String(data.flatMap { String($0, radix: 2) }).separate(every: 4, with: " ")
                            
                            TextEditor(text: .constant(str))
                                .introspectTextView { textView in
                                    textView.backgroundColor = .clear
                                    textView.isEditable = false
                                    textView.isSelectable = false
                                }
                                .font(.system(.body, design: .monospaced))
                        } header: {
                            Label("Binary", systemImage: "01.square")
                        }
                    }
                }
                
                    
            }
            
            TextEditor(text: $inputText)
                .introspectTextView(customize: { textView in
                    textView.delegate = textViewCoordinator
                    textViewCoordinator.textView = textView
                })
                .font(.system(.body, design: .monospaced))
        }
            .onChange(of: textViewCoordinator.text) { newValue in
                document.data = textViewCoordinator.text.filter {
                    $0.isHexDigit
                }.hexadecimal ?? Data()
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigation) {
                    
                    Button(action: toggleSidebar, label: { // 1
                        Image(systemName: "sidebar.leading")
                    })
                    
                    Button {
                        addMenuPresented = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .popover(isPresented: $addMenuPresented) {
                        AddTextView { str in
                            textViewCoordinator.text.append(contentsOf: str)
                            textViewCoordinator.textChange()
                        }
                    }
                }
            }
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                    textViewCoordinator.text = document.data.reduce(into: "") { acc, byte in
                        var s = String(byte, radix: 16)
                        if s.count == 1 {
                            s = "0" + s
                        }
                        acc += s + " "
                    }
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

extension String {
    func substring(with nsrange: NSRange) -> Substring? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return self[range]
    }
}

//
//  AddTextView.swift
//  HexEdit
//
//  Created by Jia Chen Yee on 28/1/22.
//

import SwiftUI

struct AddTextView: View {
    
    @State var inputString = ""
    @Environment(\.presentationMode) var presentationMode
    
    var insertData: ((String) -> ())
    
    var body: some View {
        VStack {
            Text("Insert Text")
            
            TextField("", text: $inputString)
                .onSubmit {
                    insertData(Data(inputString.utf8).reduce(into: "") { acc, byte in
                        var s = String(byte, radix: 16)
                        if s.count == 1 {
                            s = "0" + s
                        }
                        acc += s + " "
                    })
                    presentationMode.wrappedValue.dismiss()
                }
            let data = Data(inputString.utf8).reduce(into: "") { acc, byte in
                var s = String(byte, radix: 16)
                if s.count == 1 {
                    s = "0" + s
                }
                acc += s + " "
            }
            
            ScrollView {
                Text(data)
                    .font(.system(.body, design: .monospaced))
            }
            
        }
        .padding()
        .frame(width: 200, height: 200)
    }
}

struct AddTextView_Previews: PreviewProvider {
    static var previews: some View {
        AddTextView { _ in
            
        }
    }
}

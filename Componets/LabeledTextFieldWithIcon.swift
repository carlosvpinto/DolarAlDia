//
//  LabeledTextFieldWithIcon.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/10/24.
//

import SwiftUI

struct LabeledTextFieldWithIcon: View {
    var label: String
    var iconName: String
    var placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Label para el TextField
            Text(label)
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                // Ícono a la izquierda del TextField
                Image(systemName: iconName)
                    .foregroundColor(.gray)
                    .font(.title2)
                
                // TextField con placeholder
                TextField(placeholder, text: $text)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .shadow(radius: 2)
            }
        }
        .padding(.vertical, 10)
    }
}

// Vista previa para SwiftUI
struct LabeledTextFieldWithIcon_Previews: PreviewProvider {
    @State static var sampleText1 = "Carlos"
    @State static var sampleText2 = ""

    static var previews: some View {
        VStack {
            // Preview 1: TextField con texto prellenado
            LabeledTextFieldWithIcon(
                label: "Nombre",
                iconName: "person.fill",
                placeholder: "Introduce tu nombre",
                text: $sampleText1
            )
            .padding()

            // Preview 2: TextField vacío con placeholder visible
            LabeledTextFieldWithIcon(
                label: "Apellido",
                iconName: "person.fill",
                placeholder: "Introduce tu apellido",
                text: $sampleText2
            )
            .padding()
        }
        .previewLayout(.sizeThatFits)
    }
}


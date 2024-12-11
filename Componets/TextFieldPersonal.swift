import SwiftUI

struct TextFieldPersonal: View {
    var placeholder: String
    var startIcon: String
    @Binding var text: String // Vinculación con el texto

    @FocusState private var isFocused: Bool // Usamos FocusState para manejar el enfoque
    // Agrega un closure que se ejecutará para limpiar todos los campos
        var onClearAll: () -> Void

    var body: some View {
        ZStack(alignment: .leading) {
            // Placeholder centrado
            Text(placeholder)
                .foregroundColor(.gray)
                .offset(x: 40, y: isFocused || !text.isEmpty ? -22 : 0) // Ajuste de posición (x para el centrado y y para mover hacia arriba)
                .scaleEffect(isFocused || !text.isEmpty ? 0.8 : 1) // Reducción de tamaño del placeholder
                .animation(.easeInOut(duration: 0.2), value: isFocused || !text.isEmpty) // Animación suave

            // Campo de texto
            HStack {
                Image(systemName: startIcon)
                    .foregroundColor(.gray)
                    .padding(.leading, 5) // Pequeño padding para que no esté pegado al borde

                TextField("", text: $text)
                    .focused($isFocused) // Vincular el estado del enfoque con FocusState
                    .font(.system(size: 18, weight: .bold))
                    .keyboardType(.decimalPad)
                    .padding(.leading, 5)
                    

                Spacer() // Empuja el botón de borrar hacia la derecha

                // Botón para borrar el texto
                if !text.isEmpty {
                    Button(action: {
                        // Aquí llamamos a la función que limpia todos los campos
                                             onClearAll()
                        text = "" // Limpiar el texto
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 5) // Padding derecho para separar del borde
                }
            }
            .padding(15)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isFocused ? Color.accentColor : Color.gray, lineWidth: 2)
            )
            .animation(.easeInOut(duration: 0.2), value: isFocused) // Animación del borde
        }
        .padding()
    }
}
// Función que se llamará cuando el texto cambie
    func onTextChange() {
        print("YESSS")
    }

//#Preview {
    // Como este es un preview, necesitamos pasar un binding con .constant
 //   TextFieldPersonal(placeholder: "Bolívares", startIcon: "dollarsign.circle.fill", text: .constant(""))
//}


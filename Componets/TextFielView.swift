import SwiftUI

struct TextFielView: View {
    @State private var bolivares: String = ""

    @State private var dolares: String = ""

    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Dólares")
                
                TextField("$", text: $dolares)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    UIPasteboard.general.string = dolares
                    showToast = true
                }) {
                    Image(systemName: "doc.on.doc")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                }
            }
            
            HStack {
                Text("Bolívares")
                Spacer()
                TextField("Bs.", text: $bolivares)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    UIPasteboard.general.string = bolivares
                    showToast = true
                }) {
                    Image(systemName: "doc.on.doc")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black, lineWidth: 2)
        )
        .overlay(
            Group {
                if showToast {
                    Text("El contenido ha sido copiado al portapapeles")
                        .font(.subheadline)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .transition(.opacity)
                     //   .animation(.easeInOut(duration: 1))
                        .padding()
                }
            }
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TextFielView()
    }
}


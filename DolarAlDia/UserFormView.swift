//
//  UserFormView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/10/24.
//

import SwiftUICore
import SwiftUI

struct UserFormView: View {
    @State private var alias: String = ""
    @State private var phone: String = ""
    @State private var idNumber: String = ""
    @State private var selectedBank: String = "Banesco"
    @State private var isDefaultUser: Bool = false
    @Environment(\.presentationMode) var presentationMode
    var userDataManager = UserDataManager()
    var user: UserData? // Parámetro opcional para editar un usuario existente
    var banks: [String] = ["Banco de Venezuela", "Banesco", "Mercantil", "Bancaribe"] // Puedes personalizar la lista de bancos
    var onSave: () -> Void // Callback para notificar que se ha guardado un usuario


    var body: some View {
        Form {
            Section(header: Text("Información del Usuario")) {
                TextField("Alias", text: $alias)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))

                TextField("Teléfono", text: $phone)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                    .keyboardType(.numberPad)

                TextField("Cédula/RIF", text: $idNumber)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                    .keyboardType(.numberPad)

                Picker("Banco", selection: $selectedBank) {
                    ForEach(banks, id: \.self) { bank in
                        Text(bank).tag(bank)
                    }
                }

                Toggle("Usuario Predeterminado", isOn: $isDefaultUser)
            }

            Section {
                Button(action: saveUser) {
                    HStack {
                        Image(systemName: "checkmark.circle")
                        Text("Guardar")
                    }
                }

                Button(action: cancelAction) {
                    HStack {
                        Image(systemName: "xmark.circle")
                        Text("Cancelar")
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .navigationTitle(user == nil ? "Agregar Usuario" : "Editar Usuario")
        .onAppear {
            if let user = user {
                alias = user.alias
                phone = user.phone
                idNumber = user.idNumber
                selectedBank = user.bank
                isDefaultUser = (userDataManager.loadDefaultUser()?.id == user.id)
            }
        }
    }

    // Guardar o modificar usuario
    private func saveUser() {
        let newUser = UserData(alias: alias, phone: phone, idNumber: idNumber, bank: selectedBank)

        // Guardar o modificar el usuario
        userDataManager.save(user: newUser)

        // Guardar como usuario predeterminado si el toggle está activado
        if isDefaultUser {
            userDataManager.saveDefaultUser(newUser)
        }

        // Cerrar la vista
        presentationMode.wrappedValue.dismiss()
        // Llamar el callback onSave cuando el usuario se ha guardado
              onSave()
        
    }

    // Acción de cancelar
    private func cancelAction() {
        presentationMode.wrappedValue.dismiss()
    }
}

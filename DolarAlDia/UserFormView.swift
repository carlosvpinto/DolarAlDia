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
    @State private var selectedBank: String = Constants.BANKS.first ?? "" // Valor inicial seguro
    @State private var isDefaultUser: Bool = false // Eliminar esta línea
  
    @Environment(\.presentationMode) var presentationMode
    var userDataManager = UserDataManager()
    var user: UserData?
    var onSave: () -> Void
    @State private var selectedIdType: String = "V"

    var body: some View {
        Form {
            Section(header: Text("Datos del Pago Movil")) {
                TextField("Alias", text: $alias)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))

                TextField("Teléfono", text: $phone)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                    .keyboardType(.numberPad)

                HStack {
                    Picker("Ci/Rif", selection: $selectedIdType) {
                        Text("V").tag("V")
                        Text("E").tag("E")
                        Text("J").tag("J")
                    }
                    .frame(width: 100)

                    TextField("Cédula/RIF", text: $idNumber)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                        .keyboardType(.numberPad)
                }

                Picker("Banco", selection: $selectedBank) {
                    ForEach(Constants.BANKS, id: \.self) { bank in
                        Text(bank).tag(bank)
                    }
                }

                // Toggle("Usuario Predeterminado", isOn: $isDefaultUser) // Eliminar esta línea
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
                //isDefaultUser = (userDataManager.loadDefaultUser()?.id == user.id) // Eliminar esta línea
                selectedIdType = user.idType
            }
        }
    }

    // Guardar o modificar usuario
    private func saveUser() {
        // Si estamos modificando un usuario existente
        if let existingUser = user {
            userDataManager.delete(existingUser.id)
        }

        // Crear o modificar el usuario
        let newUser = UserData(alias: alias, phone: phone, idNumber: idNumber, idType: selectedIdType, bank: selectedBank)

        // Guardar el usuario modificado o nuevo
        userDataManager.save(user: newUser)

        // Siempre guardar el nuevo usuario como predeterminado
        userDataManager.saveDefaultUser(newUser)

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

#Preview {
    UserFormView(onSave: {})
}

//
//  UserFormView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/10/24.
//

import SwiftUI

struct UserFormView: View {
    @State private var alias: String = ""
    @State private var phone: String = ""
    @State private var idNumber: String = ""
    @State private var selectedBank: String = Constants.BANKS.first ?? ""
    @State private var selectedIdType: String = "V"

    @Environment(\.presentationMode) var presentationMode
    var userDataManager = UserDataManager()
    var user: UserData?
    var onSave: () -> Void
    var onCancel: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Datos del Pago Móvil")) {
                    TextField("Alias", text: $alias)
                        .autocapitalization(.words)
                    TextField("Teléfono", text: $phone)
                        .keyboardType(.numberPad)
                    HStack {
                        Picker("Tipo", selection: $selectedIdType) {
                            Text("V").tag("V")
                            Text("E").tag("E")
                            Text("J").tag("J")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 100)
                        TextField("Cédula/RIF", text: $idNumber)
                            .keyboardType(.numberPad)
                    }
                    Picker("Banco", selection: $selectedBank) {
                        ForEach(Constants.BANKS, id: \.self) { bank in
                            Text(bank).tag(bank)
                        }
                    }
                }
            }
            .navigationTitle(user == nil ? "Agregar Datos" : "Editar Usuario")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        cancelAction()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveUser()
                    }
                }
            }
            .onAppear {
                if let user = user {
                    alias = user.alias
                    phone = user.phone
                    idNumber = user.idNumber
                    selectedBank = user.bank
                    selectedIdType = user.idType
                }
            }
        }
    }

    private func saveUser() {
        // Si se está editando, elimina el usuario anterior
        if let existingUser = user {
            userDataManager.delete(existingUser.id)
        }
        let newUser = UserData(alias: alias, phone: phone, idNumber: idNumber, idType: selectedIdType, bank: selectedBank)
        userDataManager.save(user: newUser)
        userDataManager.saveDefaultUser(newUser)
        presentationMode.wrappedValue.dismiss()
        onSave()
    }

    private func cancelAction() {
        presentationMode.wrappedValue.dismiss()
        onCancel()
    }
}

struct UserFormView_Previews: PreviewProvider {
    static var previews: some View {
        UserFormView(onSave: {}, onCancel: {})
    }
}

//
//  UserListView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/10/24.
//


import SwiftUICore
import SwiftUI

struct UserListView: View {
    @State private var users: [UserData] = []
    @State private var selectedUserId: String? // Usuario predeterminado seleccionado
    let userDataManager = UserDataManager()

    var body: some View {
        NavigationView {
            List {
                ForEach(users) { user in
                    userRow(for: user) // Descomponer en una subvista
                }
                .onDelete(perform: deleteUser)
            }
            .navigationTitle("Lista de Usuarios")
            .onAppear {
                users = userDataManager.load() // Cargar usuarios
                selectedUserId = userDataManager.loadDefaultUser()?.id // Cargar usuario predeterminado
            }
        }
    }

    // Subvista para la fila de usuario
    private func userRow(for user: UserData) -> some View {
        HStack {
            // Checkbox para seleccionar usuario predeterminado
            userCheckbox(for: user)

            // Información del usuario
            userInfo(for: user)

            Spacer()

            // Botones de acción: Modificar y Eliminar
            actionButtons(for: user)
        }
        .padding(.vertical, 10)
    }

    // Subvista para el checkbox de usuario predeterminado
    private func userCheckbox(for user: UserData) -> some View {
        Button(action: {
            selectedUserId = user.id
            userDataManager.saveDefaultUser(user) // Guarda el usuario predeterminado
        }) {
            Image(systemName: selectedUserId == user.id ? "checkmark.circle.fill" : "circle")
                .foregroundColor(selectedUserId == user.id ? .green : .gray)
                .font(.title2)
        }
    }

    // Subvista para la información del usuario
    private func userInfo(for user: UserData) -> some View {
        VStack(alignment: .leading) {
            Text(user.alias)
                .font(.headline)
                .foregroundColor(.primary)
            Text("Teléfono: \(user.phone)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("Cédula/RIF: \(user.idNumber)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("Banco: \(user.bank)")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }

    // Subvista para los botones de acción
    private func actionButtons(for user: UserData) -> some View {
        HStack {
            // Botón para modificar el usuario
            Button(action: {
                modifyUser(user)
            }) {
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())

            // Botón para eliminar el usuario
            Button(action: {
                deleteUser(user)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    // Función para modificar el usuario
    private func modifyUser(_ user: UserData) {
        // Lógica para modificar el usuario
    }

    // Función para eliminar un usuario
    private func deleteUser(_ user: UserData) {
        users.removeAll { $0.id == user.id } // Elimina el usuario de la lista local
        userDataManager.delete(user.id) // Elimina el usuario del almacenamiento
    }

    // Función para eliminar un usuario desde IndexSet
    private func deleteUser(at offsets: IndexSet) {
        offsets.forEach { index in
            let user = users[index]
            userDataManager.delete(user.id)
        }
        users.remove(atOffsets: offsets)
    }
}

// Vista previa de UserListView
struct UserListView_Previews: PreviewProvider {
    static var previews: some View {
        UserListView()
    }
}

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
    @State private var selectedUser: UserData? // Usuario seleccionado (para agregar o modificar)
    @State private var isShowingUserForm = false // Estado para mostrar la vista de UserForm
    let userDataManager = UserDataManager()

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(users) { user in
                        userRow(for: user) // Subvista para cada fila de usuario
                    }
                    .onDelete(perform: deleteUser)
                }
            }
            .navigationTitle("Pago Móvil")
            .toolbar {
                // Botón de agregar usuario en la barra de herramientas
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        selectedUser = nil // Limpiar usuario seleccionado para creación
                        isShowingUserForm = true // Mostrar el formulario de usuario
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Agregar").fontWeight(.bold)
                        }
                        .padding(5)
                        .background(Color.blue) // Fondo azul para resaltar el botón
                        .foregroundColor(.white) // Texto en blanco
                        .cornerRadius(10) // Bordes redondeados
                    }
                }
            }
            .sheet(isPresented: $isShowingUserForm) {
                // Mostrar UserFormView en modo de creación o edición
                UserFormView(user: selectedUser, onSave: {
                    users = userDataManager.load() // Actualizar la lista de usuarios
                    isShowingUserForm = false // Cerrar la vista del formulario
                })
            }
            .onAppear {
                users = userDataManager.load() // Cargar usuarios
                selectedUser = userDataManager.loadDefaultUser() // Cargar usuario predeterminado
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
            selectedUser = user // Actualizar usuario seleccionado
            userDataManager.saveDefaultUser(user) // Guarda el usuario predeterminado
        }) {
            Image(systemName: selectedUser?.id == user.id ? "checkmark.circle.fill" : "circle")
                .foregroundColor(selectedUser?.id == user.id ? .green : .gray)
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
                selectedUser = user // Establecer usuario seleccionado para editar
                isShowingUserForm = true // Mostrar el formulario de usuario
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


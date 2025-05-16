//
//  UserListView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/10/24.
//

import SwiftUI

struct UserListView: View {
    @State private var users: [UserData] = []
    @State private var selectedUser: UserData? = nil
    @State private var isShowingUserForm = false
    let userDataManager = UserDataManager()

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(users) { user in
                        HStack {
                            // Botón check para usuario activo
                            Button(action: {
                                userDataManager.saveDefaultUser(user)
                                selectedUser = user
                            }) {
                                Image(systemName: selectedUser?.id == user.id ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedUser?.id == user.id ? .green : .gray)
                                    .font(.title2)
                            }
                            .buttonStyle(PlainButtonStyle())

                            // Info usuario
                            VStack(alignment: .leading) {
                                Text(user.alias)
                                    .font(.headline)
                                Text("Teléfono: \(user.phone)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("Cédula/RIF: \(user.idType)-\(user.idNumber)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("Banco: \(user.bank)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            // Botón editar
                            Button(action: {
                                selectedUser = user
                                isShowingUserForm = true
                            }) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                            }
                            .buttonStyle(PlainButtonStyle())

                            // Botón eliminar
                            Button(action: {
                                deleteUser(user)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .font(.title2)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Datos de pago Movil")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        selectedUser = nil
                        isShowingUserForm = true
                    }) {
                        Label("Agregar", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingUserForm) {
                UserFormView(
                    user: selectedUser,
                    onSave: {
                        users = userDataManager.load()
                        selectedUser = userDataManager.loadDefaultUser()
                        isShowingUserForm = false
                    },
                    onCancel: {
                        selectedUser = userDataManager.loadDefaultUser()
                        isShowingUserForm = false
                    }
                )
            }
            .onAppear {
                users = userDataManager.load()
                selectedUser = userDataManager.loadDefaultUser()
            }
        }
    }

    private func deleteUser(_ user: UserData) {
        userDataManager.delete(user.id)
        users = userDataManager.load()
        // Si el usuario eliminado era el seleccionado, actualiza el seleccionado
        if selectedUser?.id == user.id {
            selectedUser = userDataManager.loadDefaultUser()
        }
    }
}

struct UserListView_Previews: PreviewProvider {
    static var previews: some View {
        UserListView()
    }
}

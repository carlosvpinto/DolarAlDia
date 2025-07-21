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
                            // CHECK Usuario activo
                            Button(action: {
                                userDataManager.saveDefaultUser(user)
                                selectedUser = user
                            }) {
                                Image(systemName: selectedUser?.id == user.id ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedUser?.id == user.id ? .green : .gray)
                                    .font(.title2)
                            }
                            .buttonStyle(PlainButtonStyle())

                            // IMAGEN miniatura de usuario (o icono si no tiene)
                            if let data = user.imageData, let image = UIImage(data: data) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 48, height: 48)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                            } else {
                                Image(systemName: "person.crop.square")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 48, height: 48)
                                    .foregroundColor(.gray.opacity(0.45))
                            }

                            // DATOS DEL USUARIO
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

                            // BOTÓN editar
                            Button(action: {
                                selectedUser = user
                                isShowingUserForm = true
                            }) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                            }
                            .buttonStyle(PlainButtonStyle())

                            // BOTÓN eliminar
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

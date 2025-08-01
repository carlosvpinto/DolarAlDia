//
//  UserFormView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/10/24.
//



import SwiftUI
import PhotosUI

struct UserFormView: View {
    // --- ESTADOS Y PROPIEDADES (Sin cambios) ---
    @State private var alias: String = ""
    @State private var phone: String = ""
    @State private var idNumber: String = ""
  
    @State private var selectedBank: String = "Seleccione un banco"
    @State private var selectedIdType: String = "V"

    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var uiImage: UIImage? = nil
    
    // Nuevos estados para la validación y alertas
    @State private var showAlert = false
    @State private var alertMessage = ""

    @Environment(\.presentationMode) var presentationMode
    var userDataManager = UserDataManager()
    var user: UserData?
    var onSave: () -> Void
    var onCancel: () -> Void

    var body: some View {
        NavigationView {
            // Usamos un ZStack para poder poner los botones de acción encima del ScrollView
            ZStack(alignment: .bottom) {
                // El fondo de la vista principal
                Color(.systemGray6).edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // MARK: - Sección de Imagen
                        Section {
                            VStack(spacing: 12) {
                                Text("Imagen Personalizada (Opcional)")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                PhotosPicker(
                                    selection: $selectedPhoto,
                                    matching: .images,
                                    photoLibrary: .shared()
                                ) {
                                    // La vista para la imagen seleccionada o el placeholder
                                    ZStack {
                                        if let uiImage = uiImage {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        } else {
                                            // Fondo sutil para el placeholder
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.1))
                                            Image(systemName: "photo.on.rectangle.angled")
                                                .font(.largeTitle)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))
                                    .shadow(radius: 5)
                                }
                                // MARK: - AQUÍ ESTÁ EL ÚNICO CAMBIO
                                // Reemplazamos el .onChange obsoleto por la nueva sintaxis.
                                .onChange(of: selectedPhoto) { oldValue, newValue in
                                    // Cuando `selectedPhoto` cambia, este código se ejecuta.
                                    // `newValue` es el nuevo `PhotosPickerItem` que el usuario eligió.
                                    // Le pasamos ese `newValue` a nuestra función `loadImage`.
                                    loadImage(from: newValue)
                                }
                               
                            }
                            .padding()
                        }

                        // MARK: - Sección de Datos Personales
                        VStack(spacing: 16) {
                            FormFieldView(icon: "person.text.rectangle", title: "Alias o Apodo", hasError: alias.isEmpty && showAlert, content: {
                                TextField("Ej: Mi Banesco", text: $alias)
                            })
                            
                            FormFieldView(icon: "phone.fill", title: "Teléfono", hasError: phone.isEmpty && showAlert, content: {
                                TextField("Ej: 04121234567", text: $phone)
                                    .keyboardType(.numberPad)
                            })
                            
                            FormFieldView(icon: "person.text.rectangle", title: "Identificación", hasError: idNumber.isEmpty && showAlert, content: {
                                HStack {
                                    Picker("Tipo", selection: $selectedIdType) {
                                        Text("V").tag("V")
                                        Text("E").tag("E")
                                        Text("J").tag("J")
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                    
                                    TextField("Cédula o RIF", text: $idNumber)
                                        .keyboardType(.numberPad)
                                }
                            })
                            
                            FormFieldView(icon: "building.columns.fill", title: "Banco", hasError: selectedBank == "Seleccione un banco" && showAlert, content: {
                                Picker("Seleccione un banco", selection: $selectedBank) {
                                    // Añadimos la opción "fantasma" que no es un banco válido
                                    Text("Seleccione un banco").tag("Seleccione un banco")
                                    ForEach(Constants.BANKS, id: \.self) { bank in
                                        Text(bank).tag(bank)
                                    }
                                }
                                .pickerStyle(.menu)
                            })
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                        
                        // Spacer para dejar espacio para los botones flotantes
                        Spacer(minLength: 120)
                    }
                    .padding()
                }
                
                // MARK: - Botones de Acción Flotantes
                HStack(spacing: 16) {
                    Button(action: cancelAction) {
                        Text("Cancelar")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                    }
                    
                    Button(action: saveUser) {
                        Text("Guardar")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
            }
            .navigationTitle(user == nil ? "Agregar Pago Móvil" : "Editar Datos")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
        .alert("Error de Validación", isPresented: $showAlert) {
                     Button("OK", role: .cancel) { }
                 } message: {
                     Text(alertMessage)
                 }
             
        .onAppear(perform: loadUserData)
    }

    // --- FUNCIONES AUXILIARES (Refactorizadas) ---
    
    // MARK: - Nueva función de validación
        private func validateForm() -> Bool {
            // Limpiamos espacios en blanco para evitar falsos positivos
            if alias.trimmingCharacters(in: .whitespaces).isEmpty {
                alertMessage = "El campo 'Alias' no puede estar vacío."
                showAlert = true
                return false
            }
            if phone.trimmingCharacters(in: .whitespaces).isEmpty {
                alertMessage = "El campo 'Teléfono' no puede estar vacío."
                showAlert = true
                return false
            }
            if idNumber.trimmingCharacters(in: .whitespaces).isEmpty {
                alertMessage = "El campo 'Cédula o RIF' no puede estar vacío."
                showAlert = true
                return false
            }
            if selectedBank == "Seleccione un banco" {
                alertMessage = "Debe seleccionar un banco de la lista."
                showAlert = true
                return false
            }
            
            // Si todas las validaciones pasan
            return true
        }
        
    
    private func loadUserData() {
        if let user = user {
            alias = user.alias
            phone = user.phone
            idNumber = user.idNumber
            selectedBank = user.bank
            selectedIdType = user.idType
            if let data = user.imageData, let savedImage = UIImage(data: data) {
                uiImage = savedImage
            }
        }
    }
    
    private func loadImage(from item: PhotosPickerItem?) {
        guard let item = item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                // La actualización de la UI debe hacerse en el hilo principal
                await MainActor.run {
                    uiImage = image
                }
            }
        }
    }

    private func saveUser() {
        
        // MARK: - Llamamos a la validación antes de guardar
           guard validateForm() else {
               // Si la validación falla, detenemos la ejecución aquí.
               // La alerta se mostrará automáticamente porque `showAlert` se puso en `true`.
               return
           }
        
        let newUser = UserData(
            id: user?.id ?? UUID().uuidString, // Reutiliza el ID si se edita, o crea uno nuevo
            alias: alias,
            phone: phone,
            idNumber: idNumber,
            idType: selectedIdType,
            bank: selectedBank,
            imageData: uiImage?.jpegData(compressionQuality: 0.5)
        )
        userDataManager.save(user: newUser)
        // Si no había un usuario por defecto antes, o si se está editando
        // el usuario por defecto, lo volvemos a establecer.
        if userDataManager.loadDefaultUser() == nil || userDataManager.loadDefaultUser()?.id == newUser.id {
            userDataManager.saveDefaultUser(newUser)
        }
        onSave()
        presentationMode.wrappedValue.dismiss()
    }

    private func cancelAction() {
        onCancel()
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Vista de Campo de Formulario Reutilizable
// Esta sub-vista nos ayuda a mantener un diseño consistente para cada campo.
struct FormFieldView<Content: View>: View {
    let icon: String
    let title: String
    var hasError: Bool = false // Parámetro para resaltar el error
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(hasError ? .red : .accentColor) // Color dinámico
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(hasError ? .red : .secondary) // Color dinámico
            }
            content
                .padding(12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                // Añadimos un borde rojo si hay error
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(hasError ? Color.red : Color.clear, lineWidth: 1.5)
                )
        }
        .animation(.default, value: hasError) // Animación suave al aparecer el borde
    }
}

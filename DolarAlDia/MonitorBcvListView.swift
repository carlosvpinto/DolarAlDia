//
//  MonitorBcvListView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/10/24.
//

import SwiftUI

struct MonitorBcvListView: View {
    @StateObject private var viewModel = MonitorBcvListViewModel()

    var body: some View {
        NavigationView {
            // Usamos un ZStack como base para poder superponer la vista de carga.
            ZStack {
               
                Color(.systemGray6)
                    .edgesIgnoringSafeArea(.all)

                // La vista principal que contiene la lista o el mensaje de error.
                VStack {
                    if let errorMessage = viewModel.errorMessage {
                        // Mostramos un mensaje de error más visual y centrado.
                        VStack {
                            Spacer()
                            Image(systemName: "wifi.exclamationmark")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("Error al Cargar")
                                .font(.headline)
                                .padding(.top, 5)
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            Spacer()
                        }
                    } else {
                        // La lista siempre está presente en el árbol de vistas,
                        // lo que permite que el indicador de carga se superponga sobre ella.
                        List(viewModel.monitors, id: \.title) { monitor in
                            HStack(spacing: 15) {
                                // Celda de imagen
                                if let imageUrl = monitor.image, let url = URL(string: imageUrl) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                            .shadow(radius: 4)
                                    } placeholder: {
                                        ProgressView()
                                            .frame(width: 50, height: 50)
                                    }
                                } else {
                                    Image(systemName: "photo.artframe.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .shadow(radius: 4)
                                }

                                // Contenido de texto
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(monitor.title)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text("Precio: \(monitor.price, specifier: "%.2f") USD")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Cambio: \(monitor.change, specifier: "%.2f") \(monitor.symbol)")
                                        .font(.subheadline)
                                        .foregroundColor(getColor(for: monitor.color))
                                    
                                    Text("Última actualización: \(monitor.lastUpdate)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                // Icono de estado
                                if monitor.symbol.isEmpty {
                                    Image(systemName: "arrowshape.left.arrowshape.right.fill")
                                        .foregroundColor(.gray)
                                        .font(.title2)
                                } else {
                                    Image(systemName: monitor.symbol == "▲" ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                        .foregroundColor(getColor(for: monitor.color))
                                        .font(.title2)
                                }
                            }
                            .padding(.vertical, 10)
                        }
                        .listStyle(InsetGroupedListStyle())
                    }
                }
                
                // Si está cargando, mostramos nuestra nueva vista de carga encima de todo.
                if viewModel.isLoading {
                    LoadingView()
                        .transition(.opacity.animation(.easeInOut(duration: 0.3))) // Animación suave
                }
            }
            .navigationTitle("Precio en Bancos")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Solo llama a la API la primera vez que la vista aparece
                // si no hay datos. El resto de las veces se usará el botón de refrescar.
                if viewModel.monitors.isEmpty {
                    viewModel.fetchMonitors()
                }
            }
            // Añadimos un botón en la barra de navegación para refrescar manualmente.
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.fetchMonitors()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading) // Desactiva el botón mientras ya está cargando
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    // Función auxiliar para determinar el color según el valor de monitor.color
    private func getColor(for color: String) -> Color {
        switch color {
        case "green":
            return .green
        case "red":
            return .red
        case "neutral":
            return .gray
        default:
            return .gray
        }
    }
}

// Vista previa para SwiftUI
struct MonitorBcvListView_Previews: PreviewProvider {
    static var previews: some View {
        // Para probar, puedes crear un ViewModel simulado si es necesario
        // o simplemente instanciar la vista directamente.
        MonitorBcvListView()
    }
}

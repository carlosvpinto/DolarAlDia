//
//  MonitorListView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/9/24.
//

import SwiftUI

struct MonitorListView: View {
    @StateObject private var viewModel = MonitorListViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                // Fondo sutil para la app de finanzas
                Color(.systemGray6)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    if viewModel.isLoading {
                        ProgressView("Cargando...")
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    } else if let errorMessage = viewModel.errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        List(viewModel.monitors) { monitor in
                            HStack(spacing: 15) {
                                // Imagen del monitor con diseño circular y sombra
                                AsyncImage(url: URL(string: monitor.image)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .shadow(radius: 4)
                                } placeholder: {
                                    ProgressView()
                                }

                                VStack(alignment: .leading, spacing: 5) {
                                    // Título del monitor
                                    Text(monitor.title)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    // Precio actual
                                    Text("Precio: \(monitor.price, specifier: "%.2f") USD")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    // Cambio con color dinámico
                                    Text("Cambio: \(monitor.change, specifier: "%.2f") \(monitor.symbol)")
                                        .font(.subheadline)
                                        //.foregroundColor(monitor.color == "green" ? .green : .red)
                                        .foregroundColor(getColor(for: monitor.color)) // Uso de la función para obtener el color
                                    
                                    // Última actualización
                                    Text("Última actualización: \(monitor.lastUpdate)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()

                                // Icono de estado basado en el cambio (arriba/abajo) o imagen cuando no hay cambio
                                if monitor.symbol.isEmpty {
                                    Image(systemName: "arrowshape.left.arrowshape.right.fill")
                                        .foregroundColor(.gray)
                                        .font(.title2)
                                } else {
                                    Image(systemName: monitor.symbol == "▲" ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                        .foregroundColor(getColor(for: monitor.color)) // Color dinámico también para el icono
                                        .font(.title2)
                                }
                            }
                            .padding(.vertical, 10)
                        }
                        .listStyle(InsetGroupedListStyle()) // Mejor estilo de lista
                    }
                }
                .navigationTitle("Precio En Paginas")
                .navigationBarTitleDisplayMode(.inline)
            }
            .onAppear {
                viewModel.fetchData()
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
               return .gray // Color predeterminado si no es green, red, o neutral
           }
       }
}

// Vista previa para SwiftUI
#Preview {
    MonitorListView()
}


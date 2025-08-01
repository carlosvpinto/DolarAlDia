//
//  HistoryView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 4/20/25.
//,

import SwiftUI

struct BCVHistoryView: View {
    let imgUrl: String
    let navigationTitle: String
    let page: String      // "bcv" o "criptodolar"
    let monitor: String   // "usd" o "enparalelovzla"

    @StateObject private var service = BCVHistoryService()

    var body: some View {
        NavigationView {
            VStack {
                if service.isLoading {
                    ProgressView("Cargando...")
                        .padding()
                }
                if let error = service.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                }
                if !service.history.isEmpty {
                    InteractiveHistoryChartView(history: service.history.reversed())
                   // BCVHistoryChartView(history: service.history.reversed())
                }
                List(service.history) { item in
                    HStack(spacing: 12) {
                        AsyncImage(url: URL(string: imgUrl)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 50, height: 50)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.last_update.components(separatedBy: ",").first ?? item.last_update)
                                .font(.system(size: 16, weight: .medium))
                            Text(String(format: "%.2f", item.price))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.blue)
                        }
                        Spacer()
                    }
                    .padding(10)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(UIColor.systemBackground))
            .onAppear {
                service.fetchHistory(page: page, monitor: monitor)
            }
        }
        .navigationViewStyle(.stack)
    }
}

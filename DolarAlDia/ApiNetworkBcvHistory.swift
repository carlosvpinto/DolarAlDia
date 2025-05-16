//
//  ApiNetworkBcvHistory.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 5/11/25.
//

import Foundation

class BCVHistoryService: ObservableObject {
    @Published var history: [BCVHistoryItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchHistory(
        page: String = "bcv",
        monitor: String = "usd"
    ) {
        // Calcula fecha de hoy y 30 días atrás
        let today = Date()
        guard let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: today) else { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let endDate = formatter.string(from: today)
        let startDate = formatter.string(from: thirtyDaysAgo)

        let urlString = "https://pydolarve.org/api/v2/dollar/history?page=\(page)&monitor=\(monitor)&start_date=\(startDate)&end_date=\(endDate)&format_date=default&rounded_price=true&order=desc"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer 2x9Qjpxl5F8CoKK6T395KA", forHTTPHeaderField: "Authorization")

        isLoading = true
        errorMessage = nil

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                guard let data = data else {
                    self.errorMessage = "No data"
                    return
                }
                do {
                    let decoded = try JSONDecoder().decode(BCVHistoryResponse.self, from: data)
                    self.history = decoded.history
                } catch {
                    self.errorMessage = "Decoding error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

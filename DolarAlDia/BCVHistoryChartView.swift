//
//  BCVHistoryChartView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 5/11/25.
//
import Charts
import SwiftUI

struct BCVHistoryChartView: View {
    let history: [BCVHistoryItem]

    var body: some View {
        Chart {
            ForEach(history) { item in
                LineMark(
                    x: .value("Fecha", dateFromString(item.last_update)),
                    y: .value("Precio", item.price)
                )
                .foregroundStyle(.blue)
                .symbol(Circle())
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisValueLabel(format: .dateTime.day().month())
            }
        }
        .chartYAxisLabel("Bs/USD")
        .chartXAxisLabel("Fecha")
        .frame(height: 240)
        .padding(.horizontal)
    }

    // Convierte "25/04/2025, 12:00 AM" a Date
    private func dateFromString(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy, hh:mm a"
        if let date = formatter.date(from: string) {
            return date
        }
        // fallback: solo la fecha antes de la coma
        let dateOnly = string.components(separatedBy: ",").first ?? string
        let fallbackFormatter = DateFormatter()
        fallbackFormatter.dateFormat = "dd/MM/yyyy"
        return fallbackFormatter.date(from: dateOnly) ?? Date()
    }
}




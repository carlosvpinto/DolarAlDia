//
//  InteractiveChartView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 5/14/25.
//
import Charts
import SwiftUI

struct InteractiveHistoryChartView: View {
    let history: [BCVHistoryItem]
    @State private var selectedElement: BCVHistoryItem?
    @State private var hideTooltipTask: DispatchWorkItem?

    var body: some View {
        ZStack {
            Chart {
                ForEach(history) { item in
                    LineMark(
                        x: .value("Fecha", dateFromString(item.last_update)),
                        y: .value("Precio", item.price)
                    )
                    .foregroundStyle(.blue)
                    .symbol(Circle())
                }
                if let selected = selectedElement {
                    PointMark(
                        x: .value("Fecha", dateFromString(selected.last_update)),
                        y: .value("Precio", selected.price)
                    )
                    .foregroundStyle(.red)
                }
            }
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: visibleDomainLength)
            .frame(height: 260)
            .padding(.horizontal)
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let frame: CGRect
                                    if #available(iOS 17.0, *) {
                                        frame = geometry[proxy.plotFrame!]
                                    } else {
                                        frame = geometry[proxy.plotAreaFrame]
                                    }
                                    let x = value.location.x - frame.origin.x
                                    if let date: Date = proxy.value(atX: x) {
                                        if let nearest = history.min(by: { a, b in
                                            abs(dateFromString(a.last_update).timeIntervalSince(date)) <
                                            abs(dateFromString(b.last_update).timeIntervalSince(date))
                                        }) {
                                            // Solo reinicia el temporizador si cambia el punto seleccionado
                                            if selectedElement?.last_update != nearest.last_update {
                                                selectedElement = nearest
                                                startTooltipTimer()
                                            }
                                        }
                                    }
                                }
                        )
                }
            }

            // Tooltip grande y legible
            if let selected = selectedElement {
                VStack(spacing: 8) {
                    Text("Bs \(String(format: "%.2f", selected.price))")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Text(dateOnly(selected.last_update))
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                }
                .padding()
                .background(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.blue.opacity(0.92))
                )
                .shadow(radius: 10)
                .frame(maxWidth: 260)
                .transition(.scale)
                .zIndex(1)
            }
        }
        .frame(height: 260)
    }

    // Inicia el temporizador para ocultar el tooltip después de 2 segundos
    private func startTooltipTimer() {
        hideTooltipTask?.cancel()
        let task = DispatchWorkItem {
            withAnimation {
                selectedElement = nil
            }
        }
        hideTooltipTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: task)
    }

    // Calcula el rango de fechas (en segundos) para mostrar 7 valores
    private var visibleDomainLength: TimeInterval {
        let dates = history
            .map { dateFromString($0.last_update) }
            .sorted()
        guard dates.count >= 7 else {
            return (dates.last?.timeIntervalSince(dates.first ?? Date())) ?? 0
        }
        return dates[6].timeIntervalSince(dates[0])
    }

    private func dateFromString(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd/MM/yyyy, hh:mm a"
        if let date = formatter.date(from: string) {
            return date
        }
        let dateOnly = string.components(separatedBy: ",").first ?? string
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.date(from: dateOnly) ?? Date()
    }
    private func dateOnly(_ string: String) -> String {
        string.components(separatedBy: ",").first ?? string
    }
}


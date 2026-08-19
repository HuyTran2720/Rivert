//
//  TimeCard.swift
//  Flood-Detection
//
//  Created by RyanMFDR on 18/08/26.
//
//
//  TimeCard.swift
//  Flood-Detection
//
//  Created by RyanMFDR on 18/08/26.
//
import SwiftUI
import Combine

struct TimeCard: View {
    @State private var now = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    enum Selection {
        case now, next
    }
    
    //later for Binding not yet connected
    @State private var selection: Selection = .now

    private var formatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "HH.mm"
        return f
    }

    private var nextHour: Date {
        Calendar.current.date(byAdding: .hour, value: 1, to: now) ?? now
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 0) {
                Text("Now")
                    .font(.bodyFD3)
                    .foregroundStyle(Color.extraFD)
                Text(formatter.string(from: now))
                    .font(.headingFD2)
                    .foregroundStyle(selection == .now ? Color.white : Color.extraFD)
                    .frame(width: 57, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 7)
                            .fill(selection == .now ? Color.extraFD : Color.clear)
                    )
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selection = .now
                }
            }

            Text("---")
                .font(.headingFD2)
                .foregroundStyle(Color.extraFD)

            VStack(spacing: 0) {
                Text("Next")
                    .font(.bodyFD3)
                    .foregroundStyle(Color.extraFD)
                Text(formatter.string(from: nextHour))
                    .font(.headingFD2)
                    .foregroundStyle(selection == .next ? Color.white : Color.extraFD)
                    .frame(width: 57, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 7)
                            .fill(selection == .next ? Color.extraFD : Color.clear)
                    )
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selection = .next
                }
            }
        }
        .onReceive(timer) { input in
            now = input
        }
        .frame(width: 189, height: 59)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.extraFD, lineWidth: 1)
        )
    }
}

#Preview {
    TimeCard()
}

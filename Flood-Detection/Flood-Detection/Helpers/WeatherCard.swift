//
//  WeatherCard.swift
//  Flood-Detection
//
//  Created by Gian Denggan Benjamin on 26/08/26.
//

import SwiftUI

struct WeatherCard: View {
    
    let currentTemp: Int
    let currentCondition: String
    let currentIcon: WeatherIcon
    let forecast: [WeatherModel]

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.softCyan.opacity(0.5))
                .frame(width: 350, height: 80)
                .cornerRadius(16)

            HStack(spacing: 16) {
                // Current weather
                HStack(spacing: 8) {
                    Image(systemName: currentIcon.systemImageName)
                        .font(.system(size: 30))
                        .foregroundColor(.secondaryFD)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(currentTemp)°")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.terniaryFD)
                        Text(currentCondition)
                            .font(.bodyFD2)
                            .foregroundColor(.terniaryFD)
                    }
                }

                Divider()
                    .frame(height: 50)

                // Hourly forecast
                HStack(spacing: 20) {
                    ForEach(forecast.indices, id: \.self) { i in
                        VStack(spacing: 6) {
                            Text(forecast[i].date)
                                .font(.bodyFD3)
                                .foregroundColor(.terniaryFD)
                            Image(systemName: forecast[i].weatherIcon.systemImageName)
                                .font(.system(size: 20))
                                .foregroundColor(.secondaryFD)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    WeatherCard(
        currentTemp: 19,
        currentCondition: "Sunny",
        currentIcon: .clear,
        forecast: [
            WeatherModel(weatherCondition: "Cloudy", weatherProbability: 20, weatherIcon: .cloudy, date: "12"),
            WeatherModel(weatherCondition: "Cloudy", weatherProbability: 40, weatherIcon: .cloudy, date: "15"),
            WeatherModel(weatherCondition: "Rain", weatherProbability: 70, weatherIcon: .rain, date: "18"),
            WeatherModel(weatherCondition: "Storm", weatherProbability: 90, weatherIcon: .storm, date: "21")
        ]
    )
}

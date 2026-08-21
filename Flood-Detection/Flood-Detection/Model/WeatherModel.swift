//
//  WeatherModel.swift
//  Flood-Detection
//
//  Created by Gian Denggan Benjamin on 13/08/26.
//

struct WeatherModel {
    
    //Weather condition to determine if its raining/not and the intensity of the rain
    var weatherCondition: String
    
    //The percentage of possibilty if the rain is happening
    var weatherProbability: Int
    
    // Icon of each weather
    var weatherIcon : weatherIcon
    
    // date of the weather
    var date: String
}


enum weatherIcon: String {
    case rain
    case clear
    case cloudy
    case storm
    
    var systemImageName: String {
        switch self {
        case .rain: return "cloud.rain.fill"
        case .clear: return "sun.max.fill"
        case .cloudy: return "cloud.fill"
        case .storm: return "cloud.bolt.rain.fill"
        }
    }
}


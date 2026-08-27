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
    let weatherIcon : WeatherIcon
        // date of the weather
    var date: String
}


enum WeatherIcon: String {
    case rain
    case sunny
    case cloudy
    case storm
    
    var systemImageName: String {
        switch self {
        case .rain: return "Rain"
        case .sunny: return "Sunny"
        case .cloudy: return "Cloudy"
        case .storm: return "Storm"
        }
    }

    /// Map a BMKG `weather_desc_en` string onto one of our four assets.
    ///
    /// Matched case-insensitively on keywords rather than by equality:
    /// BMKG is not consistent about capitalisation or wording between
    /// runs ("Light Rain" / "light rain" / "Isolated Shower"), and an
    /// exact-match table silently falls through to a default the first
    /// time they reword something.
    ///
    /// Order matters — thunder is checked before rain because
    /// "Severe Thunderstorm With Rain" contains both.
    static func from(description: String) -> WeatherIcon {
        let d = description.lowercased()

        if d.contains("thunder") || d.contains("storm") || d.contains("squall") {
            return .storm
        }
        if d.contains("rain") || d.contains("shower") || d.contains("drizzle") {
            return .rain
        }
        // Haze/fog/smoke have no asset of their own; cloudy is the
        // closest honest stand-in for "you cannot see the sky".
        if d.contains("cloud") || d.contains("overcast")
            || d.contains("haze") || d.contains("fog")
            || d.contains("mist") || d.contains("smoke") {
            return .cloudy
        }
        if d.contains("clear") || d.contains("sunny") || d.contains("fair") {
            return .sunny
        }
        return .cloudy
    }
}


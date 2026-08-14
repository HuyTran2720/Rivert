//
//  WeatherModel.swift
//  Flood-Detection
//
//  Created by Gian Denggan Benjamin on 13/08/26.
//

struct WeatherModel {
    
    //Weather condition to determine if its raining/not and the intensity of the rain
    let weatherCondition: String
    
    //The percentage of possibilty if the rain is happening
    let weatherProbability: Int
    
    // Icon of each weather
    let weatherIcon : weatherIcon
    
    // date of the weather
    let date: String
}


enum weatherIcon: String {
    case rain
    case clear
    case cloudy
    case storm
}



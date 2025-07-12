import Foundation

enum WeatherCondition: String, CaseIterable {
    case sunny
    case rain
    case snow
    case clear

    var imageName: String? {
        switch self {
        case .sunny: return "sunny"
        case .rain: return "rain"
        case .snow: return "snow"
        case .clear: return nil
        }
    }
}

struct WeatherService {
    static func weather(for date: Date) -> WeatherCondition {
        let day = Calendar.current.component(.day, from: date)
        switch day % 3 {
        case 0: return .sunny
        case 1: return .rain
        default: return .snow
        }
    }
}

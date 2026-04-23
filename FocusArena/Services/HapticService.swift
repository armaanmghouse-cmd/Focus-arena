import Foundation
#if canImport(UIKit)
import UIKit
#endif

final class HapticService {
    static let shared = HapticService()
    var enabled: Bool = true

    func impact(_ style: ImpactStyle = .medium) {
        guard enabled else { return }
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: style.uiKit)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }

    func notify(_ type: NotificationType) {
        guard enabled else { return }
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type.uiKit)
        #endif
    }

    enum ImpactStyle {
        case light, medium, heavy, rigid, soft
        #if canImport(UIKit)
        var uiKit: UIImpactFeedbackGenerator.FeedbackStyle {
            switch self {
            case .light: return .light
            case .medium: return .medium
            case .heavy: return .heavy
            case .rigid: return .rigid
            case .soft: return .soft
            }
        }
        #endif
    }

    enum NotificationType {
        case success, warning, error
        #if canImport(UIKit)
        var uiKit: UINotificationFeedbackGenerator.FeedbackType {
            switch self {
            case .success: return .success
            case .warning: return .warning
            case .error: return .error
            }
        }
        #endif
    }
}

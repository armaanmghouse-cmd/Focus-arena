import SwiftUI

struct SectionCard<Content: View>: View {
    let title: String?
    let subtitle: String?
    @ViewBuilder var content: () -> Content

    init(title: String? = nil, subtitle: String? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if title != nil || subtitle != nil {
                VStack(alignment: .leading, spacing: 2) {
                    if let title {
                        Text(title)
                            .font(.nmTitleSection)
                            .foregroundStyle(Theme.textPrimary)
                    }
                    if let subtitle {
                        Text(subtitle)
                            .font(.nmCaption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }
            content()
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Theme.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Theme.divider.opacity(0.4), lineWidth: 0.5)
        )
    }
}

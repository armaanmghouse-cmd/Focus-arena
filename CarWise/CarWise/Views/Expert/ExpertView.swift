import SwiftUI

struct ExpertView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    hero
                    consultantCard
                    whatYouGet
                    upcomingSection
                    pastSection
                    ctaButton
                }
                .padding(16)
                .padding(.bottom, 40)
            }
            .background(Theme.Palette.surface.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("TALK TO AN EXPERT")
                        .font(.system(size: 12, weight: .black)).tracking(2.5)
                        .foregroundColor(Theme.Palette.ink)
                }
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("THE HUMAN LAYER")
                .font(.system(size: 11, weight: .black)).tracking(2.0)
                .foregroundColor(Theme.Palette.accent)
            Text("A real advisor.\nOn the phone.")
                .font(Theme.Font.display(32))
                .foregroundColor(Theme.Palette.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text("30-minute consult with a dedicated car expert. Bring your shortlist and get unbiased guidance before you spend five figures.")
                .font(Theme.Font.body(14))
                .foregroundColor(Theme.Palette.inkSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var consultantCard: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle().fill(Theme.Palette.ink)
                Text("MR")
                    .font(.system(size: 22, weight: .black))
                    .foregroundColor(.white)
            }
            .frame(width: 64, height: 64)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("Marcus Reid").font(Theme.Font.headline(18)).foregroundColor(Theme.Palette.ink)
                    RedPill(text: "Founder")
                }
                Text("12 years buying, selling, and advising on cars — independent of any dealership.")
                    .font(Theme.Font.caption(12))
                    .foregroundColor(Theme.Palette.inkSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 14) {
                    stat(value: "420+", label: "CALLS")
                    stat(value: "4.9", label: "RATING")
                    stat(value: "$2k", label: "AVG SAVED")
                }
                .padding(.top, 4)
            }
        }
        .cardStyle(padding: 16)
    }

    private func stat(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(value).font(Theme.Font.mono(13)).foregroundColor(Theme.Palette.ink)
            Text(label).font(.system(size: 9, weight: .black)).tracking(0.8)
                .foregroundColor(Theme.Palette.inkTertiary)
        }
    }

    private var whatYouGet: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What you'll get")
                .font(Theme.Font.headline(18))
                .foregroundColor(Theme.Palette.ink)
            VStack(alignment: .leading, spacing: 10) {
                bullet("A ranked shortlist reviewed by a human — not a model.")
                bullet("Dealer negotiation script tailored to your cars.")
                bullet("Honest read on trade-in value, financing, and timing.")
                bullet("One follow-up message via email if you hit a snag.")
            }
        }
        .cardStyle(padding: 16)
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark")
                .font(.system(size: 10, weight: .black))
                .foregroundColor(.white)
                .frame(width: 16, height: 16)
                .background(Theme.Palette.accent)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            Text(text)
                .font(Theme.Font.body(14))
                .foregroundColor(Theme.Palette.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private var upcomingSection: some View {
        let upcoming = appState.bookings
            .filter { $0.status == .confirmed && $0.date > Date() }
            .sorted { $0.date < $1.date }
        if !upcoming.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Upcoming")
                    .font(Theme.Font.headline(18))
                    .foregroundColor(Theme.Palette.ink)
                VStack(spacing: 10) {
                    ForEach(upcoming) { b in
                        BookingRow(booking: b,
                                   onCancel: { appState.cancelBooking(id: b.id) })
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var pastSection: some View {
        let past = appState.bookings.filter { $0.status == .cancelled || $0.date <= Date() || $0.status == .completed }
        if !past.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Past")
                    .font(Theme.Font.headline(18))
                    .foregroundColor(Theme.Palette.ink)
                VStack(spacing: 10) {
                    ForEach(past) { b in
                        BookingRow(booking: b, onCancel: nil)
                            .opacity(0.8)
                    }
                }
            }
        }
    }

    private var ctaButton: some View {
        NavigationLink {
            BookingView()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 15, weight: .bold))
                Text("Book a call — free intro")
                    .font(.system(size: 16, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundColor(.white)
            .background(Theme.Palette.accent)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

private struct BookingRow: View {
    let booking: Booking
    var onCancel: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(statusText.uppercased())
                        .font(.system(size: 10, weight: .black)).tracking(1.2)
                        .foregroundColor(statusColor)
                    Text(dateFormatter.string(from: booking.date))
                        .font(Theme.Font.title(15))
                        .foregroundColor(Theme.Palette.ink)
                    Text(booking.topic.displayName)
                        .font(Theme.Font.caption(12))
                        .foregroundColor(Theme.Palette.inkSecondary)
                }
                Spacer()
                Text("\(booking.durationMinutes) min")
                    .font(Theme.Font.mono(12))
                    .foregroundColor(Theme.Palette.inkSecondary)
            }
            if !booking.notes.isEmpty {
                Text(booking.notes)
                    .font(Theme.Font.body(13))
                    .foregroundColor(Theme.Palette.inkSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let onCancel, booking.status == .confirmed {
                Button(role: .destructive, action: onCancel) {
                    Text("Cancel")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Theme.Palette.accent)
                }
            }
        }
        .padding(14)
        .background(Theme.Palette.paper)
        .overlay(
            RoundedRectangle(cornerRadius: 12).stroke(Theme.Palette.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var statusText: String {
        switch booking.status {
        case .confirmed: return booking.date > Date() ? "Confirmed" : "Completed"
        case .pending: return "Pending"
        case .cancelled: return "Cancelled"
        case .completed: return "Completed"
        }
    }

    private var statusColor: Color {
        switch booking.status {
        case .confirmed: return booking.date > Date() ? Theme.Palette.accent : Theme.Palette.inkSecondary
        case .pending: return Theme.Palette.warning
        case .cancelled: return Theme.Palette.inkTertiary
        case .completed: return Theme.Palette.inkSecondary
        }
    }

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "EEE, MMM d · h:mm a"
        return f
    }
}

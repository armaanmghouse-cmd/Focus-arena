import SwiftUI

struct BookingView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        BookingViewContent(appState: appState)
    }
}

private struct BookingViewContent: View {
    @StateObject private var vm: BookingViewModel
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    init(appState: AppState) {
        self.appState = appState
        _vm = StateObject(wrappedValue: BookingViewModel(appState: appState))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                topicPicker
                datePicker
                slotGrid
                detailsForm
                Button {
                    vm.book()
                } label: {
                    Text(vm.canBook ? "Confirm booking" : "Pick a slot and add your phone")
                        .font(.system(size: 16, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .foregroundColor(.white)
                        .background(vm.canBook ? Theme.Palette.accent : Theme.Palette.inkTertiary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!vm.canBook)
                Text("No charge for this MVP. Payments added in a future release.")
                    .font(Theme.Font.caption(11))
                    .foregroundColor(Theme.Palette.inkSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 4)
            }
            .padding(16)
            .padding(.bottom, 30)
        }
        .background(Theme.Palette.surface.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("BOOK A CALL")
                    .font(.system(size: 12, weight: .black)).tracking(2.5)
                    .foregroundColor(Theme.Palette.ink)
            }
        }
        .sheet(isPresented: $vm.showingConfirmation) {
            if let booking = vm.lastBooking {
                BookingConfirmationSheet(booking: booking) {
                    dismiss()
                }
                .presentationDetents([.medium])
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("30-MINUTE CONSULT").font(.system(size: 11, weight: .black)).tracking(1.8)
                .foregroundColor(Theme.Palette.accent)
            Text("Let's set it up.")
                .font(Theme.Font.display(30))
                .foregroundColor(Theme.Palette.ink)
        }
    }

    private var topicPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TOPIC").font(.system(size: 10, weight: .black)).tracking(1.2)
                .foregroundColor(Theme.Palette.inkSecondary)
            FlowLayout(spacing: 8) {
                ForEach(BookingTopic.allCases) { t in
                    Chip(title: t.displayName, isSelected: vm.topic == t) {
                        vm.topic = t
                    }
                }
            }
        }
    }

    private var datePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DATE").font(.system(size: 10, weight: .black)).tracking(1.2)
                .foregroundColor(Theme.Palette.inkSecondary)
            DatePicker("", selection: $vm.selectedDate,
                       in: Date()...Calendar.current.date(byAdding: .month, value: 2, to: Date())!,
                       displayedComponents: .date)
            .labelsHidden()
            .datePickerStyle(.graphical)
            .tint(Theme.Palette.accent)
            .cardStyle(padding: 12)
        }
    }

    private var slotGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("AVAILABLE SLOTS · \(vm.formattedDate(vm.selectedDate).uppercased())")
                .font(.system(size: 10, weight: .black)).tracking(1.2)
                .foregroundColor(Theme.Palette.inkSecondary)
            if vm.availableSlots.isEmpty {
                Text("No availability on this date — pick another day (weekends closed).")
                    .font(Theme.Font.body(13))
                    .foregroundColor(Theme.Palette.inkSecondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Theme.Palette.paper)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.Palette.border, lineWidth: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 8)], spacing: 8) {
                    ForEach(Array(vm.availableSlots.enumerated()), id: \.offset) { i, slot in
                        slotButton(index: i, slot: slot)
                    }
                }
            }
        }
    }

    private func slotButton(index: Int, slot: Date) -> some View {
        let isSelected = vm.selectedSlotIndex == index
        return Button {
            vm.selectSlot(index)
        } label: {
            Text(vm.formattedSlot(slot))
                .font(.system(size: 14, weight: .bold))
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .foregroundColor(isSelected ? .white : Theme.Palette.ink)
                .background(isSelected ? Theme.Palette.accent : Theme.Palette.paper)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Theme.Palette.accent : Theme.Palette.border, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(PressableButtonStyle())
    }

    private var detailsForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("YOUR DETAILS").font(.system(size: 10, weight: .black)).tracking(1.2)
                .foregroundColor(Theme.Palette.inkSecondary)

            VStack(alignment: .leading, spacing: 6) {
                Text("Phone")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Theme.Palette.inkSecondary)
                TextField("(555) 123-4567", text: $vm.phone)
                    .keyboardType(.phonePad)
                    .padding(12)
                    .background(Theme.Palette.paper)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10).stroke(Theme.Palette.border, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Notes (optional)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Theme.Palette.inkSecondary)
                TextField("Anything specific to discuss?", text: $vm.notes, axis: .vertical)
                    .lineLimit(3...6)
                    .padding(12)
                    .background(Theme.Palette.paper)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10).stroke(Theme.Palette.border, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}

private struct BookingConfirmationSheet: View {
    let booking: Booking
    let onClose: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 54, weight: .bold))
                .foregroundColor(Theme.Palette.accent)
                .padding(.top, 24)
            Text("Booked.")
                .font(Theme.Font.display(30))
                .foregroundColor(Theme.Palette.ink)
            VStack(alignment: .leading, spacing: 6) {
                row("When", dateFormatter.string(from: booking.date))
                row("Topic", booking.topic.displayName)
                row("Duration", "\(booking.durationMinutes) min")
                row("Callback to", booking.phone)
            }
            .cardStyle(padding: 14)
            .padding(.horizontal, 20)

            Text("You'll get a reminder 30 minutes before the call.")
                .font(Theme.Font.caption(12))
                .foregroundColor(Theme.Palette.inkSecondary)

            Button {
                dismiss()
                onClose()
            } label: {
                Text("Done")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.Palette.ink)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 20)
            Spacer(minLength: 8)
        }
        .padding(.bottom, 12)
        .background(Theme.Palette.paper)
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label.uppercased()).font(.system(size: 10, weight: .black)).tracking(1.2)
                .foregroundColor(Theme.Palette.inkSecondary)
            Spacer()
            Text(value).font(Theme.Font.body(14)).foregroundColor(Theme.Palette.ink)
        }
    }

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "EEE, MMM d · h:mm a"
        return f
    }
}

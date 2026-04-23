import SwiftUI

struct ChatView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        // AppState is injected once — ChatViewContent takes it at init time
        // so the ChatViewModel has a live reference throughout its lifetime.
        ChatViewContent(appState: appState)
    }
}

private struct ChatViewContent: View {
    @StateObject private var vm: ChatViewModel
    @ObservedObject var appState: AppState
    @FocusState private var inputFocused: Bool

    init(appState: AppState) {
        self.appState = appState
        _vm = StateObject(wrappedValue: ChatViewModel(appState: appState))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                messageList
                if vm.isResponding { typingIndicator.transition(.opacity) }
                if appState.chatMessages.count <= 1 { suggestionsRail }
                inputBar
            }
            .background(Theme.Palette.surface.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("ASK CARWISE")
                        .font(.system(size: 12, weight: .black)).tracking(2.5)
                        .foregroundColor(Theme.Palette.ink)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        vm.clear()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundColor(Theme.Palette.ink)
                    }
                }
            }
        }
        .onAppear {
            vm.seedWelcomeIfNeeded()
        }
    }

    // MARK: - List

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 14) {
                    ForEach(appState.chatMessages) { msg in
                        MessageBubble(message: msg).id(msg.id)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .onChange(of: appState.chatMessages.count) { _, _ in
                if let last = appState.chatMessages.last {
                    withAnimation(.easeOut(duration: 0.25)) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    private var typingIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(Theme.Palette.accent)
                    .frame(width: 6, height: 6)
                    .opacity(0.5)
                    .animation(
                        .easeInOut(duration: 0.6).repeatForever().delay(Double(i) * 0.15),
                        value: vm.isResponding
                    )
            }
            Text("thinking")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Theme.Palette.inkSecondary)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var suggestionsRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(vm.suggestedPrompts, id: \.self) { prompt in
                    Button {
                        Task { await vm.send(text: prompt) }
                    } label: {
                        Text(prompt)
                            .font(.system(size: 13, weight: .semibold))
                            .padding(.horizontal, 12).padding(.vertical, 8)
                            .background(Theme.Palette.paper)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20).stroke(Theme.Palette.border, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .foregroundColor(Theme.Palette.ink)
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }

    private var inputBar: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField("Ask anything about cars...", text: $vm.draftText, axis: .vertical)
                .focused($inputFocused)
                .font(Theme.Font.body(15))
                .foregroundColor(Theme.Palette.ink)
                .lineLimit(1...5)
                .padding(.horizontal, 14).padding(.vertical, 12)
                .background(Theme.Palette.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 22).stroke(Theme.Palette.border, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 22))
            Button {
                inputFocused = false
                Task { await vm.sendDraftIfPossible() }
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        vm.draftText.trimmingCharacters(in: .whitespaces).isEmpty
                            ? Theme.Palette.inkTertiary
                            : Theme.Palette.accent
                    )
                    .clipShape(Circle())
            }
            .disabled(vm.draftText.trimmingCharacters(in: .whitespaces).isEmpty || vm.isResponding)
        }
        .padding(12)
        .background(
            Theme.Palette.paper
                .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: -4)
        )
        .overlay(
            Rectangle().frame(height: 1).foregroundColor(Theme.Palette.border),
            alignment: .top
        )
    }
}

// MARK: - Bubble

private struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        if message.role == .user {
            HStack {
                Spacer(minLength: 60)
                bubble(bg: Theme.Palette.ink, fg: .white, align: .trailing)
            }
        } else {
            HStack(alignment: .top, spacing: 10) {
                ZStack {
                    Circle().fill(Theme.Palette.accent)
                    Text("CW").font(.system(size: 10, weight: .black)).foregroundColor(.white)
                }
                .frame(width: 28, height: 28)
                bubble(bg: Theme.Palette.paper, fg: Theme.Palette.ink, align: .leading)
                Spacer(minLength: 40)
            }
        }
    }

    private func bubble(bg: Color, fg: Color, align: HorizontalAlignment) -> some View {
        VStack(alignment: align, spacing: 8) {
            Text(renderMarkdown(message.content))
                .font(Theme.Font.body(15))
                .foregroundColor(fg)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(align == .trailing ? .trailing : .leading)
            if !message.referencedCarIds.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(message.referencedCarIds, id: \.self) { id in
                        if let car = MockCarDatabase.car(id: id) {
                            HStack(spacing: 8) {
                                Image(systemName: car.symbol)
                                    .font(.system(size: 11))
                                    .foregroundColor(Theme.Palette.accent)
                                Text(car.displayName)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(fg)
                            }
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(14)
        .background(bg)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(message.role == .assistant ? Theme.Palette.border : .clear, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func renderMarkdown(_ text: String) -> AttributedString {
        do {
            return try AttributedString(
                markdown: text,
                options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
            )
        } catch {
            return AttributedString(text)
        }
    }
}

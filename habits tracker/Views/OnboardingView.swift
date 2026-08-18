import SwiftData
import SwiftUI

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isComplete: Bool

    @State private var page = 0
    @State private var selectedTemplates: Set<String> = ["walk", "read"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TabView(selection: $page) {
                    welcomePage
                        .tag(0)

                    privacyPage
                        .tag(1)

                    templatePage
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))

                Button(action: advance) {
                    Text(page == 2 ? "Start building momentum" : "Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 24)
                .padding(.bottom, 12)

                if page < 2 {
                    Button("Skip") {
                        completeOnboarding(createTemplates: false)
                    }
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 20)
                }
            }
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Vibe Habits")
                        .font(.headline)
                }
            }
        }
        .interactiveDismissDisabled()
    }

    private var welcomePage: some View {
        OnboardingPage(
            icon: "checkmark.seal.fill",
            color: .blue,
            title: "Build habits that actually stick",
            message: "Choose goals that fit your life, log progress in seconds, and grow one day at a time."
        )
    }

    private var privacyPage: some View {
        OnboardingPage(
            icon: "hand.raised.fill",
            color: .indigo,
            title: "Private by design",
            message: "No account, no advertising, and no tracking. Your habits stay on your device."
        )
    }

    private var templatePage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Start with a few small wins")
                        .font(.largeTitle.bold())

                    Text("Pick any examples you want. You can edit or delete them later.")
                        .foregroundStyle(.secondary)
                }

                ForEach(HabitTemplate.featured) { template in
                    Button {
                        if selectedTemplates.contains(template.id) {
                            selectedTemplates.remove(template.id)
                        } else {
                            selectedTemplates.insert(template.id)
                        }
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: template.icon)
                                .font(.title2)
                                .foregroundStyle(.blue)
                                .frame(width: 44, height: 44)
                                .background(.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))

                            VStack(alignment: .leading, spacing: 3) {
                                Text(template.name)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text(template.frequencyType.description)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: selectedTemplates.contains(template.id) ? "checkmark.circle.fill" : "circle")
                                .font(.title2)
                                .foregroundStyle(selectedTemplates.contains(template.id) ? .blue : .secondary)
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)
                    .accessibilityValue(selectedTemplates.contains(template.id) ? "Selected" : "Not selected")
                }
            }
            .padding(24)
        }
    }

    private func advance() {
        if page < 2 {
            withAnimation { page += 1 }
        } else {
            completeOnboarding(createTemplates: true)
        }
    }

    private func completeOnboarding(createTemplates: Bool) {
        if createTemplates {
            let store = HabitStore(modelContext: modelContext)
            for template in HabitTemplate.featured where selectedTemplates.contains(template.id) {
                store.addHabit(
                    name: template.name,
                    frequencyType: template.frequencyType,
                    targetValue: template.targetValue
                )
            }
        }
        isComplete = true
    }
}

private struct OnboardingPage: View {
    let icon: String
    let color: Color
    let title: LocalizedStringKey
    let message: LocalizedStringKey

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 72))
                .foregroundStyle(color.gradient)
                .frame(width: 140, height: 140)
                .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 36))
                .accessibilityHidden(true)

            VStack(spacing: 12) {
                Text(title)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }

            Spacer()
            Spacer()
        }
        .padding(24)
    }
}

#Preview {
    OnboardingView(isComplete: .constant(false))
        .modelContainer(for: [Habit.self, HabitLog.self], inMemory: true)
}

import SwiftUI

// information screen explaining delayed auditory feedback and the choral voice effect
// presented as a sheet from the Profile menu
struct AboutDAFView: View {

    @Environment(\.dismiss) private var dismiss

    // research reference backing the explanations on this screen
    private let referenceURL = URL(string: "https://doi.org/10.1111/1460-6984.70007")!

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {

                        infoCard(
                            title: "What is DAF?",
                            body: "Delayed Auditory Feedback (DAF) plays your own voice back to you through headphones with a tiny delay — usually a fraction of a second. Hearing yourself slightly later changes how you monitor your speech and often encourages a slower, smoother pace."
                        )

                        infoCard(
                            title: "The Choral Voice Effect",
                            body: "Many people who stutter become noticeably more fluent when they speak at the same time as another voice. This is called choral speech, or the “choral voice” effect. DAF recreates a similar altered-hearing condition on your own: by feeding your voice back with a delay, the app mimics the supportive feeling of speaking alongside someone else."
                        )

                        infoCard(
                            title: "How It May Support Fluency",
                            body: "Research has reported that DAF can reduce stuttering for many speakers, sometimes with large immediate improvements in fluency and without making speech sound unnatural. Results vary from person to person, and some studies have found only a limited effect during spontaneous conversation. DAF works best as regular practice over time rather than a one-time fix."
                        )

                        infoCard(
                            title: "A Practice Tool, Not a Cure",
                            body: "StuttererApp is a self-guided practice tool. It is not a medical treatment and does not cure stuttering. Everyone responds differently, so for personalized support we encourage working with a licensed speech-language pathologist."
                        )

                        referenceCard
                    }
                    .padding(24)
                }
            }
            .navigationTitle("About DAF")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    // one titled explanation block
    private func infoCard(
        title: LocalizedStringKey,
        body: LocalizedStringKey
    ) -> some View {

        GlassCard {
            VStack(alignment: .leading, spacing: 8) {

                Text(title)
                    .font(.headline)

                Text(body)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
            }
        }
    }

    // citation for the research referenced above
    private var referenceCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {

                Text("Reference")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.secondary)

                Text(
                    "Alqhazo, M., & Alkhamaiseh, Z. (2025). Effect of delayed auditory feedback on stuttering-like disfluencies. International Journal of Language & Communication Disorders, 60(2), e70007."
                )
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

                Link("View study", destination: referenceURL)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Theme.accent)
            }
        }
    }
}

// preview for the about DAF screen
struct AboutDAFView_Previews: PreviewProvider {
    static var previews: some View {
        AboutDAFView()
            .preferredColorScheme(.dark)
    }
}

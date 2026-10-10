//
//  EditProfileView.swift
//  StuttererApp
//

import SwiftUI
import PhotosUI

// sheet for changing the profile name and photo
struct EditProfileView: View {

    @ObservedObject var store: ProfileStore
    let email: String?

    @Environment(\.dismiss) private var dismiss

    // edited copies, only written to the store when the user taps Save
    @State private var firstName: String
    @State private var lastName: String
    @State private var photoData: Data?

    // what the photo picker hands back before we load it
    @State private var pickedItem: PhotosPickerItem?

    init(store: ProfileStore, email: String?) {
        self.store = store
        self.email = email
        _firstName = State(initialValue: store.firstName)
        _lastName = State(initialValue: store.lastName)
        _photoData = State(initialValue: store.photoData)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(spacing: 12) {
                        ProfilePhoto(data: photoData, size: 96)

                        PhotosPicker(
                            photoData == nil
                                ? LocalizedStringKey("Add Photo")
                                : LocalizedStringKey("Change Photo"),
                            selection: $pickedItem,
                            matching: .images
                        )

                        if photoData != nil {
                            Button("Remove Photo", role: .destructive) {
                                photoData = nil
                                pickedItem = nil
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    // stops the whole row acting as one button
                    .buttonStyle(.borderless)
                }

                Section("Name") {
                    TextField("First name", text: $firstName)
                        .textContentType(.givenName)

                    TextField("Last name", text: $lastName)
                        .textContentType(.familyName)
                }

                Section("Email") {
                    Text(email ?? String(localized: "No email"))
                        .foregroundColor(.secondary)
                }

                if store.errorMessage != nil {
                    Section {
                        Text("Something went wrong. Please try again.")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    if store.isSaving {
                        ProgressView()
                    } else {
                        Button("Save") {
                            save()
                        }
                    }
                }
            }
            // loads the picked photo and shrinks it before showing it
            .onChange(of: pickedItem) { _, item in
                guard let item else { return }

                Task {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        photoData = ProfileStore.compressedPhoto(from: data)
                    }
                }
            }
        }
    }

    private func save() {
        Task {
            let saved = await store.save(
                firstName: firstName,
                lastName: lastName,
                photoData: photoData
            )

            if saved {
                dismiss()
            }
        }
    }
}

// round profile photo, or the default person icon when there isn't one
struct ProfilePhoto: View {

    let data: Data?
    let size: CGFloat

    var body: some View {
        if let data, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
        } else {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: size))
                .foregroundColor(Theme.accent)
        }
    }
}

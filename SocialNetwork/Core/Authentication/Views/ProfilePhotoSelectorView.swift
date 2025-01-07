import SwiftUI

struct ProfilePhotoSelectorView: View {
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var profileImage: Image?
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack {
            // Header View
            AuthHeaderView(title1: "Setup account", title2: "Add a profile photo")
            
            // Profile Image Picker Button
            Button {
                showImagePicker.toggle()
            } label: {
                if let profileImage = profileImage {
                    profileImage
                        .resizable()
                        .modifier(ProfileImageModifier())
                } else {
                    Image("addProfile")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color.themeColor)
                        .modifier(ProfileImageModifier())
                }
            }
            .sheet(isPresented: $showImagePicker, onDismiss: loadImage) {
                ImagePicker(selectedImage: $selectedImage)
            }
            
            // Continue Button (Shown if an image is selected)
            if let selectedImage = selectedImage {
                Button {
                    viewModel.uploadProfileImage(selectedImage)
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 340, height: 50)
                        .background(Color.themeColor)
                        .clipShape(Capsule())
                        .padding()
                }
                .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 0)
            }
            
            Spacer()
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
    }
    
    // Load the selected image and convert it to SwiftUI's Image
    func loadImage() {
        guard let selectedImage = selectedImage else { return }
        profileImage = Image(uiImage: selectedImage)
    }
}

private struct ProfileImageModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scaledToFill()
            .frame(width: 180, height: 180)
            .overlay(
                RoundedRectangle(cornerRadius: 90)
                    .stroke(Color.themeColor, lineWidth: 10)
            )
            .clipShape(Circle())
            .padding(.top, 44)
    }
}

struct ProfilePhotoSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePhotoSelectorView()
            .environmentObject(AuthViewModel()) // Provide mock view model for preview
    }
}

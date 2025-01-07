import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthViewModel // Use the updated Django-compatible AuthViewModel
    @State private var loginError: String? // For error handling and displaying messages
    
    var body: some View {
        VStack {
            // Header
            AuthHeaderView(title1: "Hello,", title2: "Welcome back")
            
            // Input fields
            VStack(spacing: 40) {
                CustomInputField(imageName: "envelope",
                                 placeholderText: "Email",
                                 textCase: .lowercase,
                                 keyboardType: .emailAddress,
                                 textContentType: .emailAddress,
                                 text: $email)
                
                CustomInputField(imageName: "lock",
                                 placeholderText: "Password",
                                 textCase: .lowercase,
                                 keyboardType: .default,
                                 textContentType: .password,
                                 isSecureField: true,
                                 text: $password)
            }
            .padding(.horizontal, 32)
            .padding(.top, 44)
            
            // Forgot password link
            HStack {
                Spacer()
                
                NavigationLink {
                    Text("Reset Password View") // You can replace this with your ResetPasswordView
                } label: {
                    Text("Forgot Password?")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.themeColor)
                        .padding(.top)
                        .padding(.trailing, 24)
                }
            }
            
            // Sign In Button
            Button {
                viewModel.login(withEmail: email, password: password) { success, error in
                    if let error = error {
                        loginError = error.localizedDescription
                    } else if success {
                        print("DEBUG: Login successful!")
                    }
                }
            } label: {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 340, height: 50)
                    .background(Color.themeColor)
                    .clipShape(Capsule())
                    .padding()
            }
            .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 0)

            
            // Display error message if login fails
            if let loginError = loginError {
                Text(loginError)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            // Sign Up link
            NavigationLink {
                RegistrationView()
                    .navigationBarHidden(true)
            } label: {
                HStack {
                    Text("Don't have an account?")
                        .font(.footnote)
                    
                    Text("Sign Up")
                        .font(.footnote)
                        .fontWeight(.semibold)
                }
            }
            .padding(.bottom, 32)
            .foregroundColor(Color.themeColor)
        }
        .ignoresSafeArea()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel()) // Ensure this is provided
    }
}

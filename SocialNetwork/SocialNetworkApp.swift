import SwiftUI
//import Firebase

@main
struct SocialNetworkApp: App {

    @StateObject var viewModel = AuthViewModel()
    init() {
        //FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
             }
            .environmentObject(viewModel)
        }
    }
}

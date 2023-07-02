import SwiftUI
import TestPhotosPickerUI

@main
struct TestPhotosPickerApp: App {

    var body: some Scene {
        WindowGroup {
            TabView {
                TabContentView(configuration: Constants.Tab.swiftUI) {
                    SwiftUIVersionView()
                }
                TabContentView(configuration: Constants.Tab.uiKit) {
                    UIKitVersionView()
                }
            }
        }
    }
}

import SwiftUI

struct AppErrorAlertModifier: ViewModifier {
    let error: AppError?
    let onDismiss: () -> Void

    func body(content: Content) -> some View {
        content.alert(
            error?.title ?? "Something went wrong",
            isPresented: isPresented
        ) {
            Button("OK", action: onDismiss)
        } message: {
            if let error {
                Text(error.alertMessage)
            }
        }
    }

    private var isPresented: Binding<Bool> {
        Binding {
            error != nil
        } set: { isPresented in
            if !isPresented {
                onDismiss()
            }
        }
    }
}

extension View {
    func appErrorAlert(error: AppError?, onDismiss: @escaping () -> Void) -> some View {
        modifier(AppErrorAlertModifier(error: error, onDismiss: onDismiss))
    }
}

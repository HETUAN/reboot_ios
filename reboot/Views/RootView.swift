import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: RebootStore
    @State private var showLoading = true
    @State private var path: [AppRoute] = []

    var body: some View {
        Group {
            if showLoading {
                LoadingView()
            } else {
                NavigationStack(path: $path) {
                    DashboardView(path: $path)
                        .navigationDestination(for: AppRoute.self) { route in
                            switch route {
                            case .morning:
                                MorningRitualView()
                            case .daytime:
                                DaytimeCheckView()
                            case .evening:
                                EveningReviewView()
                            case .history:
                                HistoryDataView()
                            }
                        }
                }
            }
        }
        .task {
            async let loadingDelay: Void = holdLoading()
            async let notifications: Void = syncNotifications()
            _ = await (loadingDelay, notifications)
        }
    }

    private func holdLoading() async {
        try? await Task.sleep(for: .milliseconds(1800))
        showLoading = false
    }

    private func syncNotifications() async {
        if !store.notificationsEnabled {
            NotificationService.cancelReminders()
            return
        }

        let settings = await NotificationService.notificationSettings()
        let granted = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
        let finalGranted = granted ? true : await NotificationService.requestAuthorization()

        if finalGranted {
            try? await NotificationService.scheduleReminders()
        } else {
            store.setNotificationsEnabled(false)
        }
    }
}

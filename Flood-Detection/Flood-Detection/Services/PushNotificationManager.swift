//
//  PushNotificationManager.swift
//  Flood-Detection
//
//  WHAT: Requests notification permission and keeps this device's FCM
//        token registered in Firestore's `devices` collection, where
//        each document ID is a token the backend multicasts risk-state
//        pushes to.
//
//  WHY:  The backend already decides *when* and *what* to send on every
//        state/{siteId} write (see checkRiskAndNotify). The client only
//        needs to make sure its own token is discoverable there.
//

import UIKit
import UserNotifications
import FirebaseFirestore

@MainActor
final class PushNotificationManager: NSObject {
    static let shared = PushNotificationManager()

    private let hasRequestedKey = "pushNotificationPermissionRequested"

    /// Call this once, the first time the user reaches the dashboard.
    /// Safe to call again — it no-ops after the first request.
    func requestAuthorizationOnFirstLaunch() {
        guard !UserDefaults.standard.bool(forKey: hasRequestedKey) else { return }
        UserDefaults.standard.set(true, forKey: hasRequestedKey)

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            guard granted else { return }
            Task { @MainActor in
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    /// Upserts this device's current FCM token as a `devices/{token}` doc.
    nonisolated func registerDeviceToken(_ token: String) {
        Firestore.firestore().collection("devices").document(token).setData([
            "platform": "ios",
            "updatedAt": FieldValue.serverTimestamp(),
        ], merge: true)
    }
}

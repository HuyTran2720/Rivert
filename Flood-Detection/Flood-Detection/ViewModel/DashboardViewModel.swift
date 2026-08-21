//
//  DashboardViewModel.swift
//  Flood-Detection
//
//  ViewModel that listens to the Firestore "state/legian-01" document
//  and publishes changes to the Views.
//

import Foundation
import Combine
import FirebaseFirestore

class DashboardViewModel: ObservableObject {

    @Published var sensorState: SensorState?
    @Published var isLoading = true
    @Published var errorMessage: String?

    private var listener: ListenerRegistration?

    /// Start listening to the Firestore state document in real time.
    func startListening() {
        let db = Firestore.firestore()

        listener = db.collection("state").document("legian-01")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                self.isLoading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let snapshot = snapshot, snapshot.exists else {
                    self.errorMessage = "No data found"
                    return
                }

                do {
                    self.sensorState = try snapshot.data(as: SensorState.self)
                    self.errorMessage = nil
                } catch {
                    self.errorMessage = "Failed to decode: \(error.localizedDescription)"
                }
            }
    }

    /// Stop listening when no longer needed.
    func stopListening() {
        listener?.remove()
        listener = nil
    }

    deinit {
        stopListening()
    }
}

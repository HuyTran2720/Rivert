//
//  DashboardViewModel.swift
//  Flood-Detection
//
//  Created by RyanMFDR on 20/08/26.
//

//  Feeds DashboardView (InformationCard -> TimeCard / WaterLevelCard /
//  WaterRateCard / DangerPhase, plus SafetyStatusCard).
//
//  ⚠️ ASSUMPTIONS — please align these with your actual files in
//  Model/ and Helpers/, I'm inferring names/shapes from your ERD:
//    - WaterStatusModel(currentLevel: Float, riseRate: Float, trend: WaterTrend, staleness: String)
//    - SafetyStatusModel(riskStatus: RiskStatus)
//    - WeatherModel, MapDataModel, DashboardDataModel — as in your ERD
//  If a name doesn't match, it's a quick rename, not a redesign.
//
//  Single source of truth: everything (safety, water readings, and
//  eventually weather) comes from the one Firestore state document,
//  pushed live via Combine. No separate weather API call anymore —
//  once the backend adds weather fields to that document, they'll just
//  show up here through the same listener.
//

import Foundation
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {

    // MARK: Published state consumed by DashboardView

    @Published private(set) var safetyStatus: SafetyStatus = .safe
    @Published private(set) var waterStatus: WaterStatusModel = .init(
        currentLevel: 0, riseRate: 0, trend: .normal, staleness: "fresh"
    )
    @Published private(set) var weather: WeatherModel?
    @Published private(set) var errorMessage: String?

    // Raw Firestore extras not (yet) in your ERD models but present in the doc —
    // exposed separately so TimeCard can show "time to bank" / freeboard if wanted.
    @Published private(set) var freeboardMM: Double = 0
    @Published private(set) var timeToBankMin: Double?
    @Published private(set) var latestReadingAt: Date?

    // MARK: Dependencies (protocol-typed so this VM is testable with fakes)

    private let firebaseService: FirebaseServiceProtocol
    private let siteId: String

    private var cancellables = Set<AnyCancellable>()

    // Tune these to whatever "fast" actually means for your sensors (mm/min).
    private let risingFastThreshold: Double = 5
    private let droppingFastThreshold: Double = -5

    init(
        siteId: String,
        firebaseService: FirebaseServiceProtocol = FirebaseService()
    ) {
        self.siteId = siteId
        self.firebaseService = firebaseService
    }

    // MARK: Lifecycle — call from DashboardView's .task { } or .onAppear

    func start() {
        observeSafetyAndWater()
    }

    // MARK: Real-time: Firebase

    private func observeSafetyAndWater() {
        firebaseService.observeSiteState(siteId: siteId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = "Live data error: \(error.localizedDescription)"
                }
            } receiveValue: { [weak self] dto in
                self?.apply(dto)
            }
            .store(in: &cancellables)
    }

    private func apply(_ dto: WaterSiteStateDTO) {
        safetyStatus = SafetyStatus(firestoreValue: dto.riskState)

        waterStatus = WaterStatusModel(
            currentLevel: Float(dto.levelMM),
            riseRate: Float(dto.rateMMPerMin),
            trend: trend(forRateMMPerMin: dto.rateMMPerMin),
            staleness: dto.staleness
        )

        freeboardMM = dto.freeboardMM
        timeToBankMin = dto.timeToBankMin
        latestReadingAt = dto.latestReadingAt

        // Weather fields are optional until the backend adds them to this
        // same document. Until then `weather` just stays nil and whatever
        // WeatherCard/InformationCard shows should handle that gracefully.
        if let condition = dto.weatherCondition,
           let probability = dto.weatherProbability,
           let iconRaw = dto.weatherIcon {
            weather = WeatherModel(
                weatherCondition: condition,
                weatherProbability: probability,
                weatherIcon: WeatherIconName(rawValue: iconRaw) ?? .unknown,
                date: ISO8601DateFormatter().string(from: dto.computedAt ?? Date())
            )
        }
    }

    /// Client-side derivation — Firestore doesn't send `trend`, only the raw rate.
    private func trend(forRateMMPerMin rate: Double) -> WaterTrend {
        if rate >= risingFastThreshold { return .risingFast }
        if rate <= droppingFastThreshold { return .droppingFast }
        return .normal
    }
}

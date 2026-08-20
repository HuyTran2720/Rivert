//
//  MapView.swift
//  Flood-Detection
//
//  Created by Gian Denggan Benjamin on 06/08/26.
//
//  VIEW — SwiftUI views for the map. No logic or data here.
//

import SwiftUI
import MapKit

// MARK: - MKMapView Wrapper

struct MapKitView: UIViewRepresentable {

    @ObservedObject var viewModel: MapViewModel

    func makeCoordinator() -> MapCoordinator {
        MapCoordinator()
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true

        viewModel.requestLocationPermission()
        mapView.setRegion(MapConfig.defaultRegion, animated: false)
        viewModel.addPins(to: mapView)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        if viewModel.centerOnUser {
            viewModel.centerOnUserLocation(mapView: uiView)
            DispatchQueue.main.async { viewModel.centerOnUser = false }
        }
    }
}

// MARK: - Main Map View

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            MapKitView(viewModel: viewModel)

            // Locate-me button
            Button {
                viewModel.centerOnUser = true
            } label: {
                Image(systemName: "location.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color(red: 0.35, green: 0.45, blue: 0.55))
                    .frame(width: 50, height: 50)
                    .background(
                        Circle().fill(Color(red: 0.9, green: 0.95, blue: 1.0))
                    )
                    .overlay(
                        Circle().stroke(Color.white, lineWidth: 3)
                    )
                    .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
            }
            .padding(.trailing, 16)
            .padding(.bottom, 100)
        }
    }
}

#Preview {
    MapView()
        .ignoresSafeArea()
}

//
//  ContentView.swift
//  Echoes-Abroad
//
//  Created by Samuel Aarón Flores Montemayor on 27/03/25.
//
import MapKit
import SwiftUI

struct ContentView: View {
    @State private var cameraPosition: MapCameraPosition = .region(.worldRegion)
    @State private var mapSelection: Location?
    @State private var locations: [Location] = []

    var body: some View {
        Map(position: $cameraPosition, selection: $mapSelection) {
                    ForEach(locations) { location in
                        Marker(location.message, coordinate: location.coordinate)
                            .tint(location.color)
                            .tag(location)
                    }
                }
        .mapControls {
            MapCompass()
        }
        .onAppear {
            loadMarkersFromPinManager()
        }
    }

    func loadMarkersFromPinManager() {
        let pins = PinManager.shared.loadPins()
        locations = pins.compactMap { $0.toLocation() }
    }
}

extension MKCoordinateRegion {
    static var worldRegion: MKCoordinateRegion {
        .init(
            center: CLLocationCoordinate2D(latitude: 20.0, longitude: 0.0),
            latitudinalMeters: 50000000,
            longitudinalMeters: 50000000
        )
    }
}


#Preview {
    ContentView()
}

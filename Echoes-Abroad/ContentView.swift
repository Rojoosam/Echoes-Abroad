//
//  ContentView.swift
//  Echoes-Abroad
//
//  Created by Samuel Aarón Flores Montemayor on 27/03/25.
//
import MapKit
import SwiftUI
 
struct ContentView: View {
    @State private var region: MKCoordinateRegion
    
    init() {
            self._region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        }

    var body: some View {
        Map(coordinateRegion: $region)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                print("Map loaded")
            }
        }
}

#Preview {
    ContentView()
}

import MapKit
import SwiftUI

struct ContentView: View {
    @State private var cameraPosition: MapCameraPosition = .region(.worldRegion)
    @State private var mapSelection: Location?
    @State private var locations: [Location] = []
    @State private var showSheet: Bool = false  // Estado para controlar la hoja

    var body: some View {
        ZStack (alignment: .top){
            Map(position: $cameraPosition, selection: $mapSelection) {
                ForEach(locations) { location in
                    Marker("", coordinate: location.coordinate)
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
            .onChange(of: mapSelection) { newSelection in
                if let _ = newSelection {
                    showSheet = true  // Mostrar la hoja cuando se selecciona un pin
                }
            }
            
            
            ZStack {
                // Fondo difuminado detrás del texto
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .frame(height: 60)
                    .padding(.horizontal, 20)
                    .blur(radius: 0.5)

                Text("Echoes Abroad")
                    .font(.largeTitle.bold())
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.green, Color.blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            
            
            
            
        }
        .sheet(isPresented: $showSheet) {
            if let selectedLocation = mapSelection {
                PinDetailView(location: selectedLocation)
            }
        }
    }

    func loadMarkersFromPinManager() {
        let pins = PinManager.shared.loadPins()
        locations = pins.compactMap { $0.toLocation() }
    }
}

struct PinDetailView: View {
    var location: Location

    var body: some View {
        VStack(spacing: 20) {
            Text(location.message)
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
            
            Circle()
                .fill(location.color)
                .frame(width: 50, height: 50)
                .overlay(Circle().stroke(location.color, lineWidth: 2))
            
            Text(location.continent).foregroundColor(.gray)
            
            Text("Coordenadas: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                .font(.subheadline)
                .foregroundColor(.gray)

        }
        .padding()
        .presentationDetents([.fraction(0.4), .large])
    }
}

extension MKCoordinateRegion {
    static var worldRegion: MKCoordinateRegion {
        .init(
            center: CLLocationCoordinate2D(latitude: 23.6345, longitude: -102.5528),
            latitudinalMeters: 50000000,
            longitudinalMeters: 50000000
        )
    }
}

#Preview {
    ContentView()
}

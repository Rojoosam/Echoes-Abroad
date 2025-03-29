import MapKit
import SwiftUI

struct ContentView: View {
    @State private var cameraPosition: MapCameraPosition = .region(.worldRegion)
    @State private var mapSelection: Location?
    @State private var locations: [Location] = []
    @State private var showSheet: Bool = false  // Estado para controlar la hoja
    @State private var showNewPinSheet: Bool = false
    @State private var newPinCoordinate: CLLocationCoordinate2D?


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
            .onTapGesture { location in
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        let mapView = MKMapView(frame: window.bounds)
                        let coordinate = mapView.convert(location, toCoordinateFrom: window)
                        newPinCoordinate = coordinate
                        showNewPinSheet = true
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
        .sheet(isPresented: $showNewPinSheet) {
            if let coordinate = newPinCoordinate {
                AddNewPinView(coordinate: coordinate, onSave: { newPin in
                    PinManager.shared.addPin(newPin)
                    loadMarkersFromPinManager()
                })
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

struct AddNewPinView: View {
    let coordinate: CLLocationCoordinate2D
    @State private var message: String = ""
    @State private var selectedContinent: String = "America"
    let onSave: (Pin) -> Void

    // Colores hex por continente
    let continentColors: [String: String] = [
        "Africa": "#717883",
        "Europe": "#005A8D",
        "Asia": "#F1C232",
        "America": "#00A859",
        "Oceania": "#F11C2B",
        "Antarctica": "#FFFFFF"
    ]

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Add new pin")
                .font(.title)
                .bold()
                .padding(.top, 10)

            Text("Where are you from?")

            Picker("Continent", selection: $selectedContinent) {
                ForEach(continentColors.keys.sorted(), id: \.self) { continent in
                    Text(continent).tag(continent)
                }
            }
            .pickerStyle(MenuPickerStyle())

            TextField("Message", text: $message)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button("Save") {
                let pin = Pin(
                    longitude: String(coordinate.longitude),
                    latitude: String(coordinate.latitude),
                    color: continentColors[selectedContinent] ?? "#808080",
                    message: message,
                    continent: selectedContinent
                )

                onSave(pin)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)

            Text("Coordinates: \(coordinate.latitude), \(coordinate.longitude)")
                .font(.footnote)
                .foregroundColor(.gray)

            Spacer()
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

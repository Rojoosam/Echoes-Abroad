import Foundation
import SwiftUI
import MapKit


// Pin Model
struct Pin: Codable {
    let longitude: String
    let latitude: String
    let color: String
    let message: String
    let continent: String
}

// Container
struct NearbyPinsContainer: Codable {
    let nearbyPins: [Pin]
}

// Extracts the response attribute
struct ResponseWrapper: Codable {
    let response: NearbyPinsContainer
}

// The response has nearby Pins and inside of it a list of pins
struct ResponseData: Codable {
    var nearbyPins: [Pin]
}

class PinManager {
    static let shared = PinManager()
    private let fileName = "pins.json"

    private init() {
        //copyJSONFileIfNeeded()
        copyJSONFileAlways()
    }

    /*
    // Copy the pins.json file
    private func copyJSONFileIfNeeded() {
        let fileManager = FileManager.default
        
        // Get the route
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("❌ No se pudo encontrar el directorio Documents")
            return
        }
        
        let destinationURL = documentsURL.appendingPathComponent(fileName)
        
        // If exists, pass
        if fileManager.fileExists(atPath: destinationURL.path) {
            print("✅ El archivo \(fileName) ya existe en Documents")
            return
        }
        
        // Get url of bundle
        guard let sourceURL = Bundle.main.url(forResource: "pins", withExtension: "json") else {
            print("❌ No se encontró pins.json en el bundle")
            return
        }
        
        do {
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
            print("✅ Archivo pins.json copiado a Documents")
        } catch {
            print("❌ Error al copiar pins.json: \(error)")
        }
    }
     */
    
    private func copyJSONFileAlways() {
        let fileManager = FileManager.default
        
        // Get directory's route
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("❌ No se pudo encontrar el directorio Documents")
            return
        }
        
        let destinationURL = documentsURL.appendingPathComponent(fileName)
        
        // If file exists, delete it
        if fileManager.fileExists(atPath: destinationURL.path) {
            do {
                try fileManager.removeItem(at: destinationURL)
                print("✅ Archivo existente removido de Documents")
            } catch {
                print("❌ Error al eliminar archivo existente: \(error)")
            }
        }
        
        // Gets Bundle's url
        guard let sourceURL = Bundle.main.url(forResource: "pins", withExtension: "json") else {
            print("❌ No se encontró pins.json en el bundle")
            return
        }
        
        // Copy bundle --> documents (file)
        do {
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
            print("✅ Archivo pins.json copiado a Documents")
        } catch {
            print("❌ Error al copiar pins.json: \(error)")
        }
    }


    // Read pins file
    func loadPins() -> [Pin] {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return [] }
        let fileURL = documentsURL.appendingPathComponent(fileName)
        
        guard let data = try? Data(contentsOf: fileURL) else {
            print("❌ No se pudo leer el archivo \(fileName)")
            return []
        }
        
        do {
            let wrapper = try JSONDecoder().decode(ResponseWrapper.self, from: data)
            return wrapper.response.nearbyPins
        } catch {
            print("❌ Error al decodificar pins.json: \(error)")
            return []
        }
    }


    // Saves pins
    func savePins(_ pins: [Pin]) {
        let response = ResponseData(nearbyPins: pins)
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentsURL.appendingPathComponent(fileName)
        
        do {
            let data = try JSONEncoder().encode(response)
            try data.write(to: fileURL, options: .atomic)
            print("✅ Pins guardados correctamente en \(fileURL)")
        } catch {
            print("❌ Error al guardar pins.json: \(error)")
        }
    }
    
    // Add-pin
    func addPin(_ pin: Pin) {
        var pins = loadPins()
        pins.append(pin)
        savePins(pins)
    }
    
    // Delete all pins (into simulation app, not the project)
    func clearPins() {
        savePins([])
        print("✅ Todos los pines han sido eliminados.")
    }
}

extension Pin {
    func toLocation() -> Location? {
        guard let lat = Double(latitude),
              let lon = Double(longitude) else { return nil }

        // Diccionario de colores por continente
        let continentColors: [String: String] = [
            "Africa": "#717883",  // Negro (representa a África)
            "Europe": "#005A8D",  // Azul (representa a Europa)
            "Asia": "#F1C232",    // Amarillo (representa a Asia)
            "America": "#00A859", // Verde (representa a América)
            "Oceania": "#F11C2B", // Rojo (representa a Oceanía)
            "Antarctica": "#FFFFFF" // Blanco (usado para completar el diseño)
        ]

        // Usar siempre el color basado en el continente
        let resolvedColor = continentColors[continent] ?? "#808080" // Fallback a gris si no hay color para el continente

        return Location(
            coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
            color: Color(from: resolvedColor),  // Siempre usa el color del continente
            message: message,
            continent: continent
        )
    }
}


//ES ESTO DE AQUI LO QUE CAMBIE LOL

//Hay que convertir el formato porque el MAP() nuevo necesita un formato 'Location' como este para leer los pins
//sorry por hacerte trabajar mas jajajaja pero de verdad hacer asi el mapa es muuuucho mas sencillo T-T
struct Location: Identifiable, Hashable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let color: Color
    let message: String
    let continent: String

    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Color {
    init(from value: String) {
        let namedColors: [String: String] = [
            "red": "#F43535",
            "green": "#62BD22",
            "blue": "#35F4E8",
            "yellow": "#DDF435",
            "black": "#000000",
            "white": "#FFFFFF"
        ]
        
        let hex = namedColors[value.lowercased()] ?? value
        print("Parsing color: \(value) -> \(hex)") // Depuración
        self.init(hex: hex)
    }
    
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexSanitized.hasPrefix("#") {
            hexSanitized.removeFirst()
        }
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            print("Failed to parse hex: \(hexSanitized)") // Depuración
            self = .gray // Fallback color
            return
        }
        
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        print("Parsed RGB: \(r), \(g), \(b)") // Depuración
        
        self.init(red: r, green: g, blue: b)
    }
}

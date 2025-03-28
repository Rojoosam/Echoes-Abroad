import Foundation

// Pin Model
struct Pin: Codable {
    let longitude: String
    let latitude: String
    let color: String
    let message: String
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

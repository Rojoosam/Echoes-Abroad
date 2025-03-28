import SwiftUI

struct ContentView2: View {
    @State private var pins: [Pin] = []
    
    var body: some View {
        VStack {
            Text("Lista de Pines")
                .font(.title)
                .padding()
            
            // LORENA: AQUI CENTRATE EN EXTRAER ATRIBUTOS DEL OBJETO
            List(pins, id: \.longitude) { pin in
                VStack(alignment: .leading) {
                    Text("📍 Lat: \(pin.latitude), Lon: \(pin.longitude)")
                    Text("🎨 Color: \(pin.color)")
                    Text("💬 Mensaje: \(pin.message)")
                }.padding(2)
            }
            
            Button("📌 Agregar Pin de Prueba") {
                
                // LORENA: ESTA ES LA FORMA EN COMO AÑADES PINES
                let newPin = Pin(longitude: "25.700000", latitude: "-100.300000", color: "#FF0000", message: "Nuevo punto agregado")
                PinManager.shared.addPin(newPin)
                
                // LORENA: ASI CARGAS LA LISTA DE PINES CERCANOS
                pins = PinManager.shared.loadPins()
            }
            .padding()
            
            // LORENA: ESTO NO CREO QUE SEA NECESARIO, QUE MEJOR LOS USUARIOS NO PUEDAN BORRAR (LUEGO HRABRÍA LOGIN PARA ESTO)
            Button("🗑 Eliminar Todos") {
                PinManager.shared.clearPins()
                pins = PinManager.shared.loadPins()
            }
            .foregroundColor(.red)
            .padding()
        }
        .onAppear {
            pins = PinManager.shared.loadPins()
        }
    }
}

struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView2()
        }
    }
}

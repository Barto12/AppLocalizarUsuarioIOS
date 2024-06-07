//
//  ContentView.swift
//  Localizar Usuario
//
//  Created by Nazir Enoch Rosas Salgado on 11/02/24.
//

import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332),  // Ciudad de México
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    @State private var locationText: String = "Obteniendo ubicación..."
    
    var body: some View {
        VStack {
            Map(coordinateRegion: $region, showsUserLocation: true)
                .onAppear {
                    requestLocation()
                }

            Text(locationText)
                .padding()
        }
    }
    
    private func requestLocation() {
        let locationManager = CLLocationManager()
        locationManager.delegate = Coordinator(parent: self)
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func updateLocationLabel(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                locationText = "Error obteniendo ubicación: \(error.localizedDescription)"
            } else if let placemark = placemarks?.first {
                let address = "\(placemark.locality ?? ""), \(placemark.administrativeArea ?? "")"
                locationText = address
            } else {
                locationText = "Ubicación desconocida"
            }
        }
    }
    
    // Clase coordinador para el manejo de los eventos de coordenadas
    class Coordinator: NSObject, CLLocationManagerDelegate {
        var parent: ContentView

        init(parent: ContentView) {
            self.parent = parent
        }

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.last {
                let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
                parent.region = region

                parent.updateLocationLabel(location: location)
            }
        }

        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            parent.locationText = "Error obteniendo ubicación: \(error.localizedDescription)"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

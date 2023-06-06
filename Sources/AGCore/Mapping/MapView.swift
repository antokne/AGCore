//
//  MapView.swift
//  RaceWeight
//
//  Created by Antony Gardiner on 16/12/22.
//

import SwiftUI
import MapKit

#if os(iOS)
public struct MapView: UIViewRepresentable {
	let region: MKCoordinateRegion
	let lineCoordinates: [CLLocationCoordinate2D]
	
	public func makeUIView(context: Context) -> MKMapView {
		let mapView = MKMapView()
		mapView.delegate = context.coordinator
		mapView.region = region
		
		let polyline = MKPolyline(coordinates: lineCoordinates, count: lineCoordinates.count)
		mapView.addOverlay(polyline)
		
		return mapView
	}
	
	public func updateUIView(_ view: MKMapView, context: Context) {}
	
	public func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
}
#endif

#if os(macOS)
public struct MapView: NSViewRepresentable {
		
	typealias NSViewType = MKMapView
	
	let region: MKCoordinateRegion
	let lineCoordinates: [CLLocationCoordinate2D]
	
	public func makeNSView(context: Context) -> MKMapView {
		let mapView = MKMapView()
		mapView.delegate = context.coordinator
		mapView.region = region
		
		let polyline = MKPolyline(coordinates: lineCoordinates, count: lineCoordinates.count)
		mapView.addOverlay(polyline)
		
		return mapView
	}
	
	public func updateNSView(_ view: MKMapView, context: Context) {}
	
	public func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
}
#endif


public class Coordinator: NSObject, MKMapViewDelegate {
	var parent: MapView
	
	public init(_ parent: MapView) {
		self.parent = parent
	}
	
	public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		if let routePolyline = overlay as? MKPolyline {
			let renderer = MKPolylineRenderer(polyline: routePolyline)
			renderer.strokeColor = AGColor.systemRed
			renderer.lineWidth = 2
			return renderer
		}
		return MKOverlayRenderer()
	}
}

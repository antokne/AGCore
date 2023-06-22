//
//  MapViewSnapshot.swift
//  RaceWeight
//
//  Created by Antony Gardiner on 19/12/22.
//

import Foundation
import MapKit

public class MapViewSnapshot: NSObject {
	
#if os(iOS)
	public func generateSnapshotImageView(coords: [CLLocationCoordinate2D], size: CGSize, colour: AGColor, width: CGFloat) async throws -> AGImage? {

		let polyLine = MKPolyline.init(coordinates: coords, count: coords.count)
		
		let options = MKMapSnapshotter.Options()
		options.mapRect = polyLine.boundingMapRect
		options.size = size
		options.scale = AGImage.screenScale()
		
		let snapShotter = MKMapSnapshotter(options: options)
		
		let snapshot = try await snapShotter.start(with: DispatchQueue.global(qos: .utility))
		let image = snapshot.image
		
		UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
		image.draw(at: CGPoint.zero)
		
		guard let context = UIGraphicsGetCurrentContext() else {
			return nil
		}
		
		context.setStrokeColor(colour.cgColor)
		context.setLineWidth(width)
		context.beginPath()
		
		var first = true
		
		for coord in coords {
			
			let point = snapshot.point(for: coord)
			if first {
				context.move(to: point)
				first = false
			}
			else {
				context.addLine(to: point)
			}
		}
		
		context.strokePath()
		
		let generatedImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return generatedImage
	}
#endif

}

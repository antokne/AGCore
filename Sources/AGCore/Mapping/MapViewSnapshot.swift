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
	
	/// Generate a snapshot image of the list of coords that can be displayed on screen
	/// - Parameters:
	///   - coords: a list of coordinates
	///   - size: the size of the image to generate
	///   - colour: the color to use for the path of coordinates
	///   - width: the width if the line to use for the path of coordinates
	/// - Returns: A OS specific image if successful
	public func generateSnapshotImageView(coords: [CLLocationCoordinate2D], size: CGSize, colour: AGColor, width: CGFloat) async throws -> AGImage? {

		let polyLine = MKPolyline.init(coordinates: coords, count: coords.count)
		
		let options = MKMapSnapshotter.Options()
		options.mapRect = polyLine.boundingMapRect
		options.size = size
		options.scale = AGImage.screenScale()
		
		let snapShotter = MKMapSnapshotter(options: options)
		
		// Get the map snapshot image
		let snapshot = try await snapShotter.start(with: DispatchQueue.global(qos: .utility))
		let image = snapshot.image
		
		// TODO: Split into two methods when we need a macOS version.
		UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
		image.draw(at: CGPoint.zero)
		
		guard let context = UIGraphicsGetCurrentContext() else {
			return nil
		}
		
		// Now we can add the polyline data over the top of the map image
		
		context.setStrokeColor(colour.cgColor)
		context.setLineWidth(width)
		context.beginPath()
		
		var first = true
		
		// TODO: - Improve performance by filtering coords based on distance between or number of coords.
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
		
		// And finally generate the image with the polyline
		let generatedImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return generatedImage
	}
#endif

}

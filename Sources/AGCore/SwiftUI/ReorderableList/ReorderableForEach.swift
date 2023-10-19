//
//  ReorderableForEach.swift
//  ReOrderTests
//
//  Created by Ant Gardiner on 18/10/23.
//

import UniformTypeIdentifiers
import SwiftUI

public struct ReorderableForEach<Content: View, Item: Identifiable & Equatable>: View {
	let items: [Item]
	let content: (Item) -> Content
	let moveAction: (IndexSet, Int) -> Void
	
	// A little hack that is needed in order to make view back opaque
	// if the drag and drop hasn't ever changed the position
	// Without this hack the item remains semi-transparent
//	@State private var hasChangedLocation: Bool = false
	
	public init(items: [Item],
				@ViewBuilder content: @escaping (Item) -> Content,
				moveAction: @escaping (IndexSet, Int) -> Void) {
		self.items = items
		self.content = content
		self.moveAction = moveAction
	}
	
	@State private var draggingItem: Item?
	
	public var body: some View {
		ForEach(items) { item in
			content(item)
				//.overlay(.ultraThinMaterial)
				.onDrag {
					draggingItem = item
					return NSItemProvider(object: "\(item.id)" as NSString)
				}
				.onDrop(
					of: [UTType.text],
					delegate: DragRelocateDelegate(
						item: item,
						listData: items,
						current: $draggingItem
						//hasChangedLocation: $hasChangedLocation
					) { from, to in
						withAnimation {
							moveAction(from, to)
						}
					}
				)
		}
	}
}



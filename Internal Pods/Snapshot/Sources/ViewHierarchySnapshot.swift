//
//  ViewHierarchySnapshot.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/26/19.
//

import UIKit

public struct ViewHierarchySnapshot<ViewType: UIView>: SnapshotOutputFormat {
    // MARK: SnapshotOutputFormat

    public typealias RenderingFormat = ViewType

    public static func snapshotData(with renderingFormat: ViewType) throws -> Data {
        let hierarchy = renderingFormat.textHierarchy
        let string = hierarchy.stringValue

        return string.data(using: .utf8)!
    }

    public static var outputInfo: SnapshotOutputInfo {
        SnapshotOutputInfo(
            directoryName: "Hierarchies",
            fileExtension: "hierarchy.txt"
        )
    }

    public static func validate(render view: ViewType, existingData: Data) throws {
        let textHierarchy = try ViewHierarchySnapshot.snapshotData(with: view)

        if textHierarchy != existingData {
            throw SnapshotValidationError.notMatching
        }
    }
}

extension UIView {
    var textHierarchy: TextHierarchy {
        let hierarchy = TextHierarchy()

        startingViewForTextHierarchy.appendTo(textHierarchy: hierarchy, depth: 0)

        return hierarchy
    }

    @objc var textHierarchyDescription: String {
        "[\(type(of: self)): \(frame.origin.x), \(frame.origin.y), \(frame.width), \(frame.height)]"
    }

    @objc var startingViewForTextHierarchy: UIView {
        self
    }

    private func appendTo(textHierarchy: TextHierarchy, depth: Int) {
        textHierarchy.append(.init(view: self, depth: depth))

        for subview in subviews {
            subview.appendTo(textHierarchy: textHierarchy, depth: depth + 1)
        }
    }

    final class TextHierarchy {
        private(set) var views: [View] = []

        func append(_ view: View) {
            views.append(view)
        }

        var stringValue: String {
            let rows: [String] = views.map {
                let space = Array(repeating: "   ", count: $0.depth).joined()
                let description = $0.view.textHierarchyDescription

                return space + description
            }

            return rows.joined(separator: "\n") + "\n"
        }

        struct View {
            let view: UIView
            let depth: Int
        }
    }
}

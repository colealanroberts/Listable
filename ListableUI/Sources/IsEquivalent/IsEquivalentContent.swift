//
//  IsEquivalentContent.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 11/28/21.
//

import Foundation


public protocol IsEquivalentContent {
    
    ///
    /// Used by the list to determine when the content of content has changed; in order to
    /// remeasure the content and re-layout the list.
    ///
    /// You should return `false` from this method when any values within your content that
    /// affects visual appearance or layout (and in particular, sizing) changes. When the list
    /// receives `false` back from this method, it will invalidate any cached sizing it has stored
    /// for the content, and re-measure + re-layout the content.
    ///
    /// ```swift
    /// struct MyItemContent : ItemContent, Equatable {
    ///
    ///     var identifierValue : UUID
    ///     var title : String
    ///     var detail : String
    ///     var theme : MyTheme
    ///     var onTapDetail : () -> ()
    ///
    ///     func isEquivalent(to other : MyItemContent) -> Bool {
    ///         // 🚫 Missing checks for title and detail.
    ///         // If they change, they likely affect sizing,
    ///         // which would result in incorrect item sizing.
    ///
    ///         self.theme == other.theme
    ///     }
    ///
    ///     func isEquivalent(to other : MyItemContent) -> Bool {
    ///         // 🚫 Missing check for theme.
    ///         // If the theme changed; its likely that the device's
    ///         // accessibility settings changed; dark mode was enabled,
    ///         // etc. All of these can affect the appearance or sizing
    ///         // of the item.
    ///
    ///         self.title == other.title &&
    ///         self.detail == other.detail
    ///     }
    ///
    ///     func isEquivalent(to other : MyItemContent) -> Bool {
    ///         // ✅ Checking all parameters which can affect appearance + layout.
    ///         // 💡 Not checking identifierValue or onTapDetail, since they do not affect appearance + layout.
    ///
    ///         self.theme == other.theme &&
    ///         self.title == other.title &&
    ///         self.detail == other.detail
    ///     }
    /// }
    ///
    /// struct MyItemContent : ItemContent, Equatable {
    ///     // ✅ Nothing else needed!
    ///     // `Equatable` conformance provides `isEquivalent(to:) for free!`
    /// }
    /// ```
    ///
    /// ## Note
    /// If your ``ItemContent`` conforms to ``Equatable``, there is a default
    /// implementation of this method which simply returns `self == other`.
    ///
    func isEquivalent(to other : Self) -> Bool
}


public extension IsEquivalentContent where Self:Equatable
{
    /// If your content is `Equatable`, `isEquivalent` is based on the `Equatable` implementation.
    func isEquivalent(to other : Self) -> Bool {
        self == other
    }
}


public protocol KeyPathEquivalentContent : IsEquivalentContent {
    
    static func isEquivalent(using comparison : inout KeyPathEquivalent<Self>)
}


private var allKeyPathEquivalents : [ObjectIdentifier:Any] = [:]


extension KeyPathEquivalentContent {
    
    // MARK: IsEquivalentContent
    
    public func isEquivalent(to other: Self) -> Bool {
        Self.comparator.isEquivalent(self, other)
    }
    
    private static var comparator : KeyPathEquivalent<Self> {
        let id = ObjectIdentifier(Self.self)
        
        if let existing = allKeyPathEquivalents[id] {
            return existing as! KeyPathEquivalent<Self>
        } else {
            let comparator = KeyPathEquivalent<Self> {
                Self.isEquivalent(using: &$0)
            }
            
            allKeyPathEquivalents[id] = comparator
            
            return comparator
        }
    }
}

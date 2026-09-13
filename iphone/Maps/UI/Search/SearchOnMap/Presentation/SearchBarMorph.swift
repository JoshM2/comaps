/// The look shared by the search bar on the map (`MapSearchButton`) and the text field at the top of
/// the search sheet (`SearchOnMapHeaderView`).
///
/// The two are deliberately styled the same, so that the bar keeps its identity when it becomes the
/// field you type in, and so the animation between them has only position and size to change.
enum SearchBarAppearance {
  static let borderWidth: CGFloat = 1
  static let shadowRadius: CGFloat = 2
  /// SwiftUI's `.shadow(radius:)` default opacity, which the bar on the map uses.
  static let shadowOpacity: Float = 0.33
  /// Leading inset of the magnifying glass. Matches where `UISearchTextField` places its own, so the
  /// icon does not shift when the stand-in hands over to the real field.
  static let contentInset: CGFloat = 8
  static let iconSpacing: CGFloat = 6

  static var borderColor: UIColor {
    UIColor(named: "Map Buttons/Border Color") ?? .separator
  }

  /// Matches the fill in `MapSearchButton`: opaque white, or black with a 25% white overlay.
  static var fill: UIColor {
    UIColor { traits in
      traits.userInterfaceStyle == .dark ? UIColor(white: 0.25, alpha: 1) : .white
    }
  }

  /// Matches SwiftUI's `.secondary`, which the bar on the map uses for its label.
  static var placeholderColor: UIColor { .secondaryLabel }
  static var iconColor: UIColor { .secondaryLabel }
  static var font: UIFont { .preferredFont(forTextStyle: .body) }

  /// A capsule, whatever the height.
  static func cornerRadius(forHeight height: CGFloat) -> CGFloat {
    height / 2
  }
}

/// Hand-off between the SwiftUI search bar on the map and the UIKit search sheet, which live in
/// sibling view hierarchies and cannot see each other.
///
/// The bar records where it is on screen just before it asks for search to be presented; the sheet
/// animates a stand-in from there to its own text field, and back again on dismiss.
enum SearchBarMorph {
  /// The key backing `isMorphing`.
  static let isMorphingKey = "IsSearchBarMorphing"

  /// Set by the bar when it is tapped, and consumed exactly once by the search sheet.
  ///
  /// Only the bar sets this, so the other entry points into search (the ⌘F key command, the 3D-touch
  /// action, routing) present without a morph.
  private(set) static var pendingFrame: CGRect?

  /// The last frame the bar reported, kept for the reverse morph: the bar is out of the view
  /// hierarchy while search is open, so it cannot report a live frame at dismiss time.
  private(set) static var lastFrame: CGRect?

  /// Whether a stand-in is currently on screen in place of the bar.
  ///
  /// Stored in the user defaults so that the SwiftUI overlay can observe it via `@AppStorage`.
  static var isMorphing: Bool {
    get { UserDefaults.standard.bool(forKey: isMorphingKey) }
    set { UserDefaults.standard.set(newValue, forKey: isMorphingKey) }
  }

  /// Record the bar's position and ask for a morph on the presentation that is about to happen.
  /// - Parameter frame: The bar's frame in window coordinates.
  static func setPendingFrame(_ frame: CGRect) {
    pendingFrame = frame
    lastFrame = frame
  }

  /// Take the pending frame, if there is one, clearing it so it is used only once.
  static func consumePendingFrame() -> CGRect? {
    defer { pendingFrame = nil }
    return pendingFrame
  }
}

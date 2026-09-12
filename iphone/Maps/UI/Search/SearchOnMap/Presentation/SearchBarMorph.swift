/// Hand-off between the SwiftUI map search pill (`MapSearchButton`) and the UIKit search sheet
/// (`SearchOnMapViewController`), which live in sibling view hierarchies and cannot see each other.
///
/// The pill records where it is on screen just before it asks for search to be presented; the sheet
/// consumes that frame to animate a stand-in view from the pill into the real search field, and back
/// again on dismiss.
enum SearchBarMorph {
  /// The key backing `isMorphing`.
  static let isMorphingKey = "IsSearchBarMorphing"

  /// A frame captured from the pill, together with the container size it was captured in.
  struct Source {
    let frame: CGRect
    let containerSize: CGSize
  }

  /// Set by the pill when it is tapped, and consumed exactly once by the search sheet.
  ///
  /// Only the pill sets this, so the other entry points into search (the ⌘F key command, the 3D-touch
  /// action, routing) present without a morph.
  private(set) static var pendingSource: Source?

  /// The last frame the pill reported, kept for the reverse morph: the pill is out of the view
  /// hierarchy while search is open, so it cannot report a live frame at dismiss time.
  private(set) static var lastSource: Source?

  /// Whether a stand-in view is currently on screen in place of the pill.
  ///
  /// Stored in the user defaults so that the SwiftUI overlay can observe it via `@AppStorage`.
  static var isMorphing: Bool {
    get { UserDefaults.standard.bool(forKey: isMorphingKey) }
    set { UserDefaults.standard.set(newValue, forKey: isMorphingKey) }
  }

  /// Record the pill's position and request a morph for the presentation that is about to happen.
  /// - Parameter frame: The pill's frame in window coordinates.
  /// - Parameter containerSize: The size of the container the frame was measured in.
  static func setPendingSource(frame: CGRect, containerSize: CGSize) {
    let source = Source(frame: frame, containerSize: containerSize)
    pendingSource = source
    lastSource = source
  }

  /// Take the pending source frame, if there is one, clearing it so it is used only once.
  static func consumePendingSource() -> Source? {
    defer { pendingSource = nil }
    return pendingSource
  }

  /// The frame to collapse back into, or `nil` when the stored one can no longer be trusted.
  ///
  /// A recorded frame is only meaningful while the container it was measured in still has the same
  /// shape, so a resize — a rotation, most obviously — invalidates it. Compared with a tolerance
  /// rather than exactly, because the two sides measure the container through different APIs.
  /// - Parameter containerSize: The size of the container the morph will run in.
  static func collapseTarget(in containerSize: CGSize) -> CGRect? {
    guard let lastSource else { return nil }
    let recorded = lastSource.containerSize
    let tolerance: CGFloat = 1
    guard abs(recorded.width - containerSize.width) < tolerance,
          abs(recorded.height - containerSize.height) < tolerance else { return nil }
    return lastSource.frame
  }

  /// Forget any recorded state. Used when the pill goes away for reasons unrelated to search.
  static func reset() {
    pendingSource = nil
    lastSource = nil
    isMorphing = false
  }
}

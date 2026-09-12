/// A stand-in for the map search pill, used to animate between the pill on the map and the search
/// field at the top of the search sheet.
///
/// It carries both appearances at once — the pill's bordered background and the search field's
/// background — and cross-fades between them, so a single animation block moves, resizes and
/// restyles it in one motion. Subviews are positioned with explicit frames rather than Auto Layout
/// so that everything interpolates cleanly.
final class SearchBarMorphView: UIView {

  /// The look of the real search field, read off it rather than hardcoded so that the landing state
  /// matches the current theme, and the system-drawn field on iOS 26 where the renderer opts out.
  struct FieldAppearance {
    let backgroundColor: UIColor?
    let cornerRadius: CGFloat
    let textColor: UIColor
    let tintColor: UIColor
  }

  private enum Constants {
    /// Matches `MapSearchButton`'s `RoundedRectangle(cornerRadius: 28)`.
    static let pillCornerRadius: CGFloat = 28
    /// Matches `MapSearchButton`'s `.padding(.leading)` on its label.
    static let pillContentInset: CGFloat = 16
    /// Roughly where `UISearchTextField` puts its magnifying glass.
    static let fieldContentInset: CGFloat = 8
    static let pillShadowRadius: CGFloat = 2
    /// SwiftUI's `.shadow(radius:)` default opacity.
    static let pillShadowOpacity: Float = 0.33
    static let pillBorderWidth: CGFloat = 1
    static let iconSpacing: CGFloat = 6
    /// The magnifying glass is drawn at the pill's size and scaled down for the field.
    static let fieldIconScale: CGFloat = 0.8
  }

  private let pillBackground = UIView()
  private let fieldBackground = UIView()
  private let iconView = UIImageView()
  private let label = UILabel()

  private let fieldAppearance: FieldAppearance

  /// The current leading inset of the icon and label, interpolated by the animation.
  private var contentInset: CGFloat = Constants.pillContentInset

  // MARK: - Init
  init(fieldAppearance: FieldAppearance) {
    self.fieldAppearance = fieldAppearance
    super.init(frame: .zero)
    setupView()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    isUserInteractionEnabled = false

    pillBackground.backgroundColor = UIColor { traits in
      // Matches the fill in MapSearchButton: opaque white, or black with a 25% white overlay.
      traits.userInterfaceStyle == .dark ? UIColor(white: 0.25, alpha: 1) : .white
    }
    pillBackground.layer.cornerCurve = .continuous
    pillBackground.layer.cornerRadius = Constants.pillCornerRadius
    pillBackground.layer.borderWidth = Constants.pillBorderWidth
    pillBackground.layer.shadowColor = UIColor.black.cgColor
    pillBackground.layer.shadowOffset = .zero
    pillBackground.layer.shadowRadius = Constants.pillShadowRadius
    pillBackground.layer.shadowOpacity = Constants.pillShadowOpacity

    fieldBackground.backgroundColor = fieldAppearance.backgroundColor
    fieldBackground.layer.cornerCurve = .continuous
    fieldBackground.layer.cornerRadius = Constants.pillCornerRadius
    fieldBackground.alpha = 0

    iconView.image = UIImage(systemName: "magnifyingglass")
    iconView.contentMode = .center
    iconView.tintColor = .secondaryLabel

    label.text = L("search")
    label.textColor = .secondaryLabel
    label.font = .preferredFont(forTextStyle: .body)

    addSubview(pillBackground)
    addSubview(fieldBackground)
    addSubview(iconView)
    addSubview(label)
  }

  // MARK: - Layout
  override func layoutSubviews() {
    super.layoutSubviews()
    updateBorderColor()
    pillBackground.frame = bounds
    fieldBackground.frame = bounds

    let iconSize = iconView.intrinsicContentSize
    iconView.bounds = CGRect(origin: .zero, size: iconSize)
    iconView.center = CGPoint(x: contentInset + iconSize.width / 2, y: bounds.midY)

    let labelSize = label.intrinsicContentSize
    let labelLeft = iconView.frame.maxX + Constants.iconSpacing
    label.frame = CGRect(x: labelLeft,
                         y: bounds.midY - labelSize.height / 2,
                         width: max(0, bounds.width - labelLeft),
                         height: labelSize.height)
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    updateBorderColor()
  }

  /// A layer's border takes a `CGColor`, which cannot adapt on its own, so the dynamic colour the
  /// bar uses is resolved against the traits in force.
  private func updateBorderColor() {
    let borderColor = UIColor(named: "Map Buttons/Border Color") ?? .separator
    pillBackground.layer.borderColor = borderColor.resolvedColor(with: traitCollection).cgColor
  }

  // MARK: - Appearances
  /// Show the view as the map search pill. Call outside an animation block to set the start state,
  /// or inside one to animate back to it.
  func applyPillAppearance() {
    pillBackground.alpha = 1
    fieldBackground.alpha = 0
    pillBackground.layer.cornerRadius = Constants.pillCornerRadius
    fieldBackground.layer.cornerRadius = Constants.pillCornerRadius
    iconView.transform = .identity
    iconView.tintColor = .secondaryLabel
    label.textColor = .secondaryLabel
    contentInset = Constants.pillContentInset
    setNeedsLayout()
    layoutIfNeeded()
  }

  /// Show the view as the search sheet's text field.
  func applyFieldAppearance() {
    pillBackground.alpha = 0
    fieldBackground.alpha = 1
    pillBackground.layer.cornerRadius = fieldAppearance.cornerRadius
    fieldBackground.layer.cornerRadius = fieldAppearance.cornerRadius
    iconView.transform = CGAffineTransform(scaleX: Constants.fieldIconScale, y: Constants.fieldIconScale)
    iconView.tintColor = fieldAppearance.tintColor
    label.textColor = fieldAppearance.textColor
    contentInset = Constants.fieldContentInset
    setNeedsLayout()
    layoutIfNeeded()
  }
}

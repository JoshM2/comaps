/// A stand-in for the search bar, used to animate between its place on the map and the text field at
/// the top of the search sheet.
///
/// Because both ends are styled the same — see `SearchBarAppearance` — this has a single appearance
/// and only its frame is animated. Subviews are positioned with explicit frames rather than Auto
/// Layout so that they interpolate cleanly as it resizes.
final class SearchBarMorphView: UIView {

  private let background = UIView()
  private let iconView = UIImageView()
  private let label = UILabel()

  // MARK: - Init
  init() {
    super.init(frame: .zero)
    setupView()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    isUserInteractionEnabled = false

    background.backgroundColor = SearchBarAppearance.fill
    background.layer.cornerCurve = .continuous
    background.layer.borderWidth = SearchBarAppearance.borderWidth
    background.layer.shadowColor = UIColor.black.cgColor
    background.layer.shadowOffset = .zero
    background.layer.shadowRadius = SearchBarAppearance.shadowRadius
    background.layer.shadowOpacity = SearchBarAppearance.shadowOpacity

    iconView.image = UIImage(systemName: "magnifyingglass")
    iconView.contentMode = .center
    iconView.tintColor = SearchBarAppearance.iconColor

    label.text = L("search")
    label.textColor = SearchBarAppearance.placeholderColor
    label.font = SearchBarAppearance.font

    addSubview(background)
    addSubview(iconView)
    addSubview(label)
  }

  // MARK: - Layout
  override func layoutSubviews() {
    super.layoutSubviews()
    updateBorderColor()

    background.frame = bounds
    background.layer.cornerRadius = SearchBarAppearance.cornerRadius(forHeight: bounds.height)

    let iconSize = iconView.intrinsicContentSize
    iconView.frame = CGRect(x: SearchBarAppearance.contentInset,
                            y: bounds.midY - iconSize.height / 2,
                            width: iconSize.width,
                            height: iconSize.height)

    let labelSize = label.intrinsicContentSize
    let labelLeft = iconView.frame.maxX + SearchBarAppearance.iconSpacing
    label.frame = CGRect(x: labelLeft,
                         y: bounds.midY - labelSize.height / 2,
                         width: max(0, bounds.width - labelLeft),
                         height: labelSize.height)
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    updateBorderColor()
  }

  /// A layer's border takes a `CGColor`, which cannot adapt on its own, so the dynamic colour is
  /// resolved against the traits in force.
  private func updateBorderColor() {
    background.layer.borderColor = SearchBarAppearance.borderColor.resolvedColor(with: traitCollection).cgColor
  }
}

protocol SearchOnMapHeaderViewDelegate: UISearchBarDelegate {
  func cancelButtonDidTap()
  func grabberDidTap()
}

final class SearchOnMapHeaderView: UIView {
  weak var delegate: SearchOnMapHeaderViewDelegate? {
    didSet {
      searchBar.delegate = delegate
    }
  }

  private enum Constants {
    /// Close to the height of a map control, so that the search bar barely changes size as it moves
    /// up from the map into this header.
    static let searchBarHeight: CGFloat = 44
    static let searchBarInsets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 10, right: 0)
    static let grabberHeight: CGFloat = 5
    static let grabberWidth: CGFloat = 36
    static let grabberTopMargin: CGFloat = 5
    static let cancelButtonInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 16)
  }

  private let grabberView = UIView()
  private let grabberTapHandlerView = UIView()
  private let searchBar = UISearchBar()
  private let cancelButton = UIButton()
  private let cancelContainer = UIView()
  private var separator: UIView?

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
    layoutView()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    setStyle(.background)

    setupGrabberView()
    setupGrabberTapHandlerView()
    setupSearchBar()
    setupCancelButton()
  }

  private func setupGrabberView() {
    grabberView.setStyle(.grabber)
    iPadSpecific { [weak self] in
      self?.grabberView.isHidden = true
    }
  }

  private func setupGrabberTapHandlerView() {
    grabberTapHandlerView.backgroundColor = .clear
    iPhoneSpecific {
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(grabberDidTap))
      grabberTapHandlerView.addGestureRecognizer(tapGesture)
    }
  }

  private func setupSearchBar() {
    searchBar.setStyle(.defaultSearchBar)
    searchBar.placeholder = L("search")
    searchBar.showsCancelButton = false
    searchBar.searchTextField.clearButtonMode = .always
    searchBar.returnKeyType = .search
    searchBar.searchTextField.enablesReturnKeyAutomatically = true
    searchBar.backgroundImage = UIImage()
  }

  private func setupCancelButton() {
    cancelContainer.setStyle(.background)
    cancelButton.setStyle(.searchCancelButton)
    cancelButton.setTitle(L("cancel"), for: .normal)
    cancelButton.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
  }

  private func layoutView() {
    addSubview(grabberView)
    addSubview(grabberTapHandlerView)
    addSubview(searchBar)
    addSubview(cancelContainer)
    cancelContainer.addSubview(cancelButton)
    separator = addSeparator(.bottom)

    grabberView.translatesAutoresizingMaskIntoConstraints = false
    grabberTapHandlerView.translatesAutoresizingMaskIntoConstraints = false
    grabberTapHandlerView.setContentHuggingPriority(.defaultLow, for: .vertical)
    searchBar.translatesAutoresizingMaskIntoConstraints = false
    cancelContainer.translatesAutoresizingMaskIntoConstraints = false
    cancelButton.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      grabberView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.grabberTopMargin),
      grabberView.centerXAnchor.constraint(equalTo: centerXAnchor),
      grabberView.widthAnchor.constraint(equalToConstant: Constants.grabberWidth),
      grabberView.heightAnchor.constraint(equalToConstant: Constants.grabberHeight),

      grabberTapHandlerView.topAnchor.constraint(equalTo: grabberView.bottomAnchor),
      grabberTapHandlerView.leadingAnchor.constraint(equalTo: leadingAnchor),
      grabberTapHandlerView.trailingAnchor.constraint(equalTo: trailingAnchor),
      grabberTapHandlerView.bottomAnchor.constraint(equalTo: searchBar.topAnchor),

      searchBar.topAnchor.constraint(equalTo: grabberView.bottomAnchor, constant: Constants.searchBarInsets.top),
      searchBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.searchBarInsets.left),
      searchBar.trailingAnchor.constraint(equalTo: cancelContainer.leadingAnchor),
      searchBar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.searchBarInsets.bottom),
      searchBar.heightAnchor.constraint(equalToConstant: Constants.searchBarHeight),

      cancelContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
      cancelContainer.topAnchor.constraint(equalTo: searchBar.topAnchor),
      cancelContainer.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor),

      cancelButton.topAnchor.constraint(equalTo: cancelContainer.topAnchor),
      cancelButton.leadingAnchor.constraint(equalTo: cancelContainer.leadingAnchor, constant: Constants.cancelButtonInsets.left),
      cancelButton.trailingAnchor.constraint(equalTo: cancelContainer.trailingAnchor, constant: -Constants.cancelButtonInsets.right),
      cancelButton.bottomAnchor.constraint(equalTo: cancelContainer.bottomAnchor),
    ])
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    // Applied here rather than in setup because UISearchBarRenderer runs on didMoveToWindow and on
    // every theme change, and resets the corner radius and background it cares about.
    applySearchBarAppearance()
  }

  /// Give the text field the same look as the search bar on the map, so that the bar keeps its
  /// identity once it becomes the thing you type in.
  private func applySearchBarAppearance() {
    let textField = searchBar.searchTextField
    textField.backgroundColor = SearchBarAppearance.fill
    textField.font = SearchBarAppearance.font
    textField.leftView?.tintColor = SearchBarAppearance.iconColor
    if let placeholder = textField.placeholder {
      textField.attributedPlaceholder = NSAttributedString(
        string: placeholder,
        attributes: [.foregroundColor: SearchBarAppearance.placeholderColor,
                     .font: SearchBarAppearance.font])
    }

    let layer = textField.layer
    layer.cornerCurve = .continuous
    // From the constant rather than the field's own height: subviews lay out after their parent, so
    // that height is not settled yet here. An over-large radius is clamped, so this is a capsule
    // whatever inset UISearchBar gives the field.
    layer.cornerRadius = SearchBarAppearance.cornerRadius(forHeight: Constants.searchBarHeight)
    layer.borderWidth = SearchBarAppearance.borderWidth
    layer.borderColor = SearchBarAppearance.borderColor.resolvedColor(with: traitCollection).cgColor
    // The bar casts a shadow over the map; keeping it here means the morph has nothing to fade.
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOffset = .zero
    layer.shadowRadius = SearchBarAppearance.shadowRadius
    layer.shadowOpacity = SearchBarAppearance.shadowOpacity
    // A shadow needs to escape the bounds, so the rounding is applied by the mask instead.
    layer.masksToBounds = false
  }

  @objc private func grabberDidTap() {
    delegate?.grabberDidTap()
  }

  @objc private func cancelButtonDidTap() {
    delegate?.cancelButtonDidTap()
  }

  func setSearchText(_ text: String) {
    searchBar.text = text
  }

  func setIsSearching(_ isSearching: Bool) {
    if isSearching {
      searchBar.becomeFirstResponder()
    } else if searchBar.isFirstResponder {
      searchBar.resignFirstResponder()
    }
  }

  var searchQuery: SearchQuery {
    SearchQuery(searchBar.text ?? "", locale: searchBar.textInputMode?.primaryLanguage, source: .typedText)
  }

  /// The search field's frame, in this view's coordinates. Used to place the morph stand-in.
  var searchBarFrame: CGRect {
    searchBar.frame
  }

  /// Hide just the search field and the cancel button, leaving the grabber and separator to move
  /// with the sheet as usual while the morph stand-in covers for them.
  func setSearchFieldHidden(_ hidden: Bool) {
    let alpha: CGFloat = hidden ? 0 : 1
    searchBar.alpha = alpha
    cancelContainer.alpha = alpha
  }

  func setSeparatorHidden(_ hidden: Bool) {
    separator?.isHidden = hidden
  }
}

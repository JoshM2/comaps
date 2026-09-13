import SwiftUI

/// View for a map search button (later to be replaced by an actual textfield)
struct MapSearchButton: View {
    // MARK: Properties

    /// The vertical size class of the environment
    @Environment(\.verticalSizeClass) private var verticalSizeClass


    /// The color scheme of the environment
    @Environment(\.colorScheme) private var colorScheme


    /// The default height of a map control
    var controlHeight: CGFloat


    /// The frame of the bar itself, in window coordinates, handed to the search sheet so that it can animate the bar into its own search field
    @State private var frame: CGRect = .zero


    /// The actual view
    var body: some View {
        HStack(spacing: 0) {
            if verticalSizeClass != .compact {
                Spacer(minLength: 0)
            }

            bar

            Spacer(minLength: 0)
        }
    }


    /// The bar itself
    ///
    /// Built from parts rather than as one expression: the whole thing at once is more than the type checker will work through in reasonable time.
    private var bar: some View {
        sizingGuide
            .overlay {
                button
            }
            .background {
                background
            }
            .background {
                frameReader
            }
            .contentShape(Rectangle())
            .padding(.leading, verticalSizeClass == .compact ? (controlHeight + 24) : 0)
    }


    /// Invisible circles matching the mode picker, which are what give the bar its width
    private var sizingGuide: some View {
        HStack(spacing: 0) {
            ForEach(Mode.allCases) { mode in
                Circle()
                    .fill(.clear)
                    .aspectRatio(1, contentMode: .fit)
            }
        }
        .padding(4)
        .accessibilityHidden(true)
    }


    /// The tappable label
    private var button: some View {
        Button {
            SearchBarMorph.setPendingFrame(frame)
            SearchBarMorph.isMorphing = true

            NotificationCenter.default.post(Notification(name: MapControls.presentSearchNotificationName))
        } label: {
            Label("search", systemImage: "magnifyingglass")
                .foregroundStyle(.secondary)
                // Where the search sheet's text field puts its own magnifying glass, so the icon
                // stays put when this bar becomes that field
                .padding(.leading, SearchBarAppearance.contentInset)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .compositingGroup()
                .background(.white.opacity(0.01))
        }
        .buttonStyle(.plain)
    }


    /// The rounded, bordered background
    private var background: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .stroke(Color.MapButtons.border, lineWidth: 1)
            .background {
                if colorScheme == .dark {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color.black)
                }

                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.white.opacity(colorScheme == .dark ? 0.25 : 1))
            }
            .shadow(radius: 2)
            .foregroundStyle(Color.secondary)
            .compositingGroup()
    }


    /// Reports where the bar is, so that the search sheet can start its animation from here
    private var frameReader: some View {
        GeometryReader { barGeometry in
            if #available(iOS 16.0, *) {
                Color.black
                    .hidden()
                    .onAppear {
                        frame = barGeometry.frame(in: .global)
                    }
                    .onGeometryChange(for: CGRect.self) { changedBarGeometry in
                        changedBarGeometry.frame(in: .global)
                    } action: { changedFrame in
                        frame = changedFrame
                    }
            } else {
                Color.black
                    .hidden()
                    .onAppear {
                        frame = barGeometry.frame(in: .global)
                    }
            }
        }
    }
}

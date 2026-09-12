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


    /// The frame of the bar itself, in window coordinates, handed to the search sheet so that it can
    /// animate the bar into its own search field
    @State private var frame: CGRect = .zero


    /// The actual view
    var body: some View {
        HStack(spacing: 0) {
            if verticalSizeClass != .compact {
                Spacer(minLength: 0)
            }
            
            HStack(spacing: 0) {
                ForEach(Mode.allCases) { mode in
                    Circle()
                        .fill(.clear)
                        .aspectRatio(1, contentMode: .fit)
                }
            }
            .padding(4)
            .accessibilityHidden(true)
            .overlay {
                Button {
                    SearchBarMorph.setPendingSource(frame: frame, containerSize: UIScreen.main.bounds.size)
                    SearchBarMorph.isMorphing = true

                    NotificationCenter.default.post(Notification(name: MapControls.presentSearchNotificationName))
                } label: {
                    Label("search", systemImage: "magnifyingglass")
                        .foregroundStyle(.secondary)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .compositingGroup()
                        .background(.white.opacity(0.01))
                }
                .buttonStyle(.plain)
            }
            .background {
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
            .background {
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
            .contentShape(Rectangle())
            .padding(.leading, verticalSizeClass == .compact ? (controlHeight + 24) : 0)
            
            Spacer(minLength: 0)
        }
    }
}

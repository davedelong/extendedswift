//
//  ProgressViewStyle.swift
//  ExtendedSwift
//
//  Created by Dave DeLong on 9/21/25.
//

import SwiftUI

extension ProgressViewStyle where Self == ThinCircularProgressViewStyle {
    public static var thinCircular: Self { .init() }
}

public struct ThinCircularProgressViewStyle: ProgressViewStyle {
    public func makeBody(configuration: Configuration) -> some View {
        Label(title: { configuration.label },
              icon: { CircleSpinner(fraction: configuration.fractionCompleted) })
    }
}

private struct CircleSpinner: View {
    private let minimumLineWidth = 3.0
    
    var fraction: Double?

    @State var rotation = Angle(degrees: -90)
    @State var circleDimension: CGFloat?

    private var lineWidth: CGFloat {
        guard let circleDimension else { return minimumLineWidth }
        let proportional = circleDimension * 0.1
        return max(proportional, minimumLineWidth)
    }

    private var animation: Animation {
        guard fraction == nil else { return .default }

        return Animation.linear(duration: 1.0)
                        .repeatForever(autoreverses: false)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(.secondary, lineWidth: lineWidth)
                .padding(lineWidth / 2.0)

            Circle()
                .trim(from: 0, to: fraction ?? 1.0)
                .stroke(.primary, lineWidth: lineWidth)
                .padding(lineWidth / 2.0)
                .mask {
                    AngularGradient(colors: [.black.opacity(fraction == nil ? 0.0 : 1.0), .black],
                                    center: .center)
                        .frame(width: circleDimension, height: circleDimension)
                        .rotationEffect(rotation)
                        .animation(animation, value: rotation)
                }
                .rotationEffect(.degrees(-90))
                .animation(.default, value: fraction)
        }
        .onAppear { updateRotation() }
        .onChange(of: fraction) { _ in updateRotation() }
        .onGeometryChange(for: CGSize.self, of: \.size) { circleDimension = min($0.width, $0.height) }
        .frame(width: circleDimension, height: circleDimension, alignment: .center)
    }

    private func updateRotation() {
        if fraction == nil {
            rotation += .degrees(360)
        } else {
            rotation = .degrees(0)
        }
    }

}

//
//  WorkLogEmptyView.swift
//  Chronik
//
//  Created by Vít Míchal on 08.09.2026.
//

import SwiftUI
import Generic

/// The first run of the Work log, before there is anything to show.
struct WorkLogEmptyView: View {
    let addAction: () -> Void

    var body: some View {
        VStack(spacing: 22) {
            WorkLogMark()
                .frame(width: 104, height: 104)

            Text("Your Work log starts here")
                .font(Theme.typography.emptyTitle)
                .foregroundStyle(Theme.pallete.onBackgroundColor)

            Text("Write down one thing you did today. A line is enough.")
                .font(Theme.typography.body)
                .foregroundStyle(Theme.pallete.onSurfaceColor)
                .frame(maxWidth: 250)

            Button("Add your first Entry", action: addAction)
                .buttonStyle(
                    PrimaryPillButtonStyle(
                        height: 52,
                        horizontalPadding: 28,
                        font: Theme.typography.buttonLarge
                    )
                )
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 40)
        .padding(.bottom, 90)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.pallete.backgroundColor)
    }
}

/// A page with two written lines and a pen, drawn on the 96pt grid the rest of
/// the iconography uses.
private struct WorkLogMark: View {
    var body: some View {
        ZStack {
            PageShape()
                .stroke(
                    Theme.pallete.iconColorVariant,
                    style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                )
            PenShape()
                .stroke(
                    Theme.pallete.primaryColor,
                    style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                )
        }
    }
}

private struct PageShape: Shape {
    func path(in rect: CGRect) -> Path {
        let scale = min(rect.width, rect.height) / 96
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: x * scale, y: y * scale)
        }
        let radius = 4 * scale

        var path = Path()
        path.move(to: point(22, 20))
        path.addLine(to: point(60, 20))
        path.addLine(to: point(74, 34))
        path.addLine(to: point(74, 76))
        path.addArc(tangent1End: point(74, 80), tangent2End: point(70, 80), radius: radius)
        path.addLine(to: point(22, 80))
        path.addArc(tangent1End: point(18, 80), tangent2End: point(18, 76), radius: radius)
        path.addLine(to: point(18, 24))
        path.addArc(tangent1End: point(18, 20), tangent2End: point(22, 20), radius: radius)
        path.closeSubpath()

        // The folded corner.
        path.move(to: point(60, 20))
        path.addLine(to: point(60, 34))
        path.addLine(to: point(74, 34))

        // Two written lines.
        path.move(to: point(30, 50))
        path.addLine(to: point(52, 50))
        path.move(to: point(30, 62))
        path.addLine(to: point(60, 62))

        return path
    }
}

private struct PenShape: Shape {
    func path(in rect: CGRect) -> Path {
        let scale = min(rect.width, rect.height) / 96
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: x * scale, y: y * scale)
        }

        var path = Path()
        path.move(to: point(64, 44))
        path.addLine(to: point(74, 54))
        path.addLine(to: point(58, 70))
        path.addLine(to: point(47, 71))
        path.addLine(to: point(48, 60))
        path.closeSubpath()
        return path
    }
}

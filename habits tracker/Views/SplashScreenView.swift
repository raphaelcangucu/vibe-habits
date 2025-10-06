//
//  SplashScreenView.swift
//  habits tracker
//
//  Created by Raphael Canguçu on 05/10/25.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0
    @State private var rotationAngle: Double = 0
    @Binding var isActive: Bool

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.6, blue: 1.0),
                    Color(red: 0.3, green: 0.5, blue: 0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                // Icon Animation
                ZStack {
                    // Outer circles (ripple effect)
                    ForEach(0..<3) { index in
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            .frame(width: 120, height: 120)
                            .scaleEffect(isAnimating ? CGFloat(1.5 + Double(index) * 0.5) : 1.0)
                            .opacity(isAnimating ? 0.0 : 0.6)
                            .animation(
                                Animation.easeOut(duration: 2.0)
                                    .repeatForever(autoreverses: false)
                                    .delay(Double(index) * 0.3),
                                value: isAnimating
                            )
                    }

                    // Main icon container
                    ZStack {
                        // Background circle
                        Circle()
                            .fill(Color.white)
                            .frame(width: 120, height: 120)
                            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)

                        // Checkmark grid pattern (like the streak grid)
                        VStack(spacing: 4) {
                            ForEach(0..<3) { row in
                                HStack(spacing: 4) {
                                    ForEach(0..<3) { col in
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(Color.blue.opacity(isAnimating ? 1.0 : 0.0))
                                            .frame(width: 16, height: 16)
                                            .scaleEffect(isAnimating ? 1.0 : 0.5)
                                            .animation(
                                                Animation.spring(response: 0.5, dampingFraction: 0.6)
                                                    .delay(Double(row * 3 + col) * 0.05),
                                                value: isAnimating
                                            )
                                    }
                                }
                            }
                        }
                    }
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(rotationAngle))
                }

                // App name
                VStack(spacing: 8) {
                    Text("Vibe Habits")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(opacity)

                    Text("Build momentum, one day at a time")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .opacity(opacity)
                }
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        // Initial scale and rotation animation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            scale = 1.0
            rotationAngle = 360
        }

        // Fade in text
        withAnimation(.easeIn(duration: 0.6).delay(0.3)) {
            opacity = 1.0
        }

        // Start ripple effect
        withAnimation(.default.delay(0.2)) {
            isAnimating = true
        }

        // Transition to main app
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.5)) {
                isActive = false
            }
        }
    }
}

#Preview {
    SplashScreenView(isActive: .constant(false))
}

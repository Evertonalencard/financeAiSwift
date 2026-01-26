//
//  SystemDisign.swift
//  FinanceIA
//
//  Created by Éverton Alencar de Lima on 13/12/25.
//

import SwiftUI

// MARK: - GlassEffectContainer (A View Wrapper)




extension View {
    @ViewBuilder
    func glassedEffect(in shape: some Shape, interactive: Bool = false) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(interactive ? .clear.interactive() : .clear, in: shape)
        } else {
            self.background {
                shape.glassed()
            }
        }
    }
}

extension Shape {
    func glassed() -> some View {
        self
            .fill(.ultraThinMaterial)
            .fill(
                .linearGradient(
                    colors: [
                        .primary.opacity(0.08),
                        .primary.opacity(0.05),
                        .primary.opacity(0.01),
                        .clear,
                        .clear,
                        .clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .stroke(.primary.opacity(0.2), lineWidth: 0.7)
    }
}

extension View {
    // Função auxiliar para fechar o teclado
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

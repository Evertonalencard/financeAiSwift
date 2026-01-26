//
//  BackgroundView.swift
//  FinanceIA
//
//  Created by Éverton Alencar de Lima on 27/12/25.
//
import SwiftUI

struct BackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.corDeFundo, Color.corDeFundo2],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if #available(iOS 26.0, *) {
                Circle()
                    .fill(Color.bolaVerde.opacity(0.1))
                    .glassedEffect(in: .capsule, interactive: true)
                    .frame(width: 410, height: 410)
                    .offset(x: -100, y: -300)
                
                Circle()
                    .fill(Color.bolaAzul.opacity(0.1))
                    .glassedEffect(in: .capsule, interactive: true)
                    .frame(width: 360, height: 360)
                    .offset(x: 100, y: 300)
            } else {
                Circle()
                    .fill(Color.bolaVerde.opacity(0.3))
                    .frame(width: 300, height: 300)
                    .blur(radius: 40)
                    .offset(x: -100, y: -300)
                
                Circle()
                    .fill(Color.bolaAzul.opacity(0.3))
                    .frame(width: 300, height: 300)
                    .blur(radius: 40)
                    .offset(x: 100, y: 200)
            }
        }
    }
}

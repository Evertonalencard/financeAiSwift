//
//  TabView.swift
//  projetofinal
//
//  Created by Éverton Alencar de Lima on 13/11/25.
//

import SwiftUI

struct Principal: View {
    var body: some View {
        TabView {
            TelaInicialView()
                .tabItem{Label("", systemImage: "house")}
            ContentView()
                .tabItem{Label("", systemImage: "arrow.up.arrow.down")}
            

        }
    }
}

#Preview {
    Principal()
}

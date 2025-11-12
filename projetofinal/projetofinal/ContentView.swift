//
//  ContentView.swift
//  projetofinal
//
//  Created by Turma02-9 on 11/11/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color(.green)
            Color.black.ignoresSafeArea().opacity(0.8)
                        Text("Hello, world!")
        }.ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}

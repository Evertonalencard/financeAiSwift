import SwiftUI

struct Principal: View {
    // Estado para controlar a aba selecionada
    @State private var selectedTab: Int = 0
    
    // Estado para controlar a Splash Screen
    @State private var showSplash: Bool = true
    init() {
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray // Ícones inativos cinza
    }
    
    var body: some View {
        ZStack{
            if showSplash {
                SplashScreen(isActive: $showSplash)
                    .transition(.opacity) // Suaviza a saída da splash
            } else{
                
                TabView {
                    // 🏠 Tela Inicial (Dashboard)
                    TelaInicialView()
                        .tabItem {
                            Label("", systemImage: "house")
                        }
                    
                    // 📜 ContentView (Histórico de Transações)
                    ContentView()
                        .tabItem{
                            Label("", systemImage: "arrow.up.arrow.down")
                        }
                    
                    // 🤖 IA
                    IADasFinancas()
                        .tabItem {
                            Label("", systemImage: "message.fill")
                        }
                    
                    // 📂 Categorias
                    categorias()
                        .tabItem{
                            Label("",systemImage: "list.dash")
                        }
                }
                .tint(.corUIitens)
            }
        }
    }
}

// MARK: - Componente Splash Screen
struct SplashScreen: View {
    @Binding var isActive: Bool
    @State private var scale = 0.5
    @State private var opacity = 0.3
    
    var body: some View {
        ZStack {
            Color.corDeFundo.ignoresSafeArea() // Fundo sólido da splash
            
            VStack {
                // SUBSTITUA PELO SEU LOGO REAL
                Image("iconeFinanceIa-iOS-Default-1024x1024") // Exemplo: ícone do app
                    .resizable()
                    .frame(width: 124, height: 124)
                    .foregroundStyle(.white)
                    .padding()
                    .glassedEffect(in: .rect(cornerRadius: 30), interactive: false)
                
                Text("Finance AI")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white.opacity(0.8))
            }
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                // Animação de entrada da logo
                withAnimation(.easeIn(duration: 2.3)) {
                    self.scale = 1.0
                    self.opacity = 1.0
                }
            }
        }
        .onAppear {
            // Tempo que a splash fica na tela (2.5 segundos)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    self.isActive = false
                }
            }
        }
    }
}

#Preview {
    Principal()
        .modelContainer(PreviewHelper.container)
}

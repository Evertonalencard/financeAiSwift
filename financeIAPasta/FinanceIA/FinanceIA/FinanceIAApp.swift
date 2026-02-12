//
//  projetofinalApp.swift
//  FinanceIA
//

import SwiftUI
import SwiftData

@main
struct projetofinalApp: App {
    let container: ModelContainer
    
    init() {
        do {
            // ✅ Configuração com migração automática
            let schema = Schema([
                TransactionModel.self,
                CategoryModel.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )
            
            container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            
            print("✅ ModelContainer criado com sucesso")
            
        } catch {
            // ✅ Erro mais detalhado
            print("❌ ERRO DETALHADO:")
            print("   Tipo: \(type(of: error))")
            print("   Descrição: \(error.localizedDescription)")
            print("   Error: \(error)")
            
            // Solução temporária: tenta deletar e recriar
            fatalError("""
            ⚠️ Falha ao criar o ModelContainer.
            
            SOLUÇÃO:
            1. Delete o app do simulador
            2. Clean Build (Cmd+Shift+K)
            3. Rebuild (Cmd+B)
            4. Execute novamente
            
            Erro técnico: \(error)
            """)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            Principal()
                .onAppear {
                    Task { @MainActor in
                        DataSeeder.seed(context: container.mainContext)
                        
                        // ✅ CORRIGIDO: Chama o método correto
                        RecurrenceManager.verificarRecorrencias(context: container.mainContext)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    Task { @MainActor in
                        // ✅ CORRIGIDO
                        RecurrenceManager.verificarRecorrencias(context: container.mainContext)
                    }
                }
        }
        .modelContainer(container)
    }

}

import SwiftUI
import SwiftData

extension TipoRecorrencia {
    var icone: String {
        switch self {
        case .nenhuma: return "tag.fill"
        case .diaria: return "calendar.day.timeline.left"
        case .semanal: return "calendar"
        case .mensal: return "calendar.badge.clock"
        case .anual: return "calendar.badge.exclamationmark"
        case .personalizada: return "calendar.badge.plus"
        }
    }
}


struct categorias: View {
    @Environment(\.modelContext) var modelContext
    @State private var categories: [CategoryModel] = []
    @State private var isLoading = false
    @State private var hasMoreData = true
    @State private var currentOffset = 0
    @State private var mostrarAdicionar = false
    
    private let pageSize = 10
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                
                VStack {
                    Text("Categorias")
                        .font(.title)
                        .bold()
                        .foregroundStyle(Color.corTextosBotoes)
                        .padding(.top)
                    
                    if categories.isEmpty && !isLoading {
                        emptyState
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(Array(categories.enumerated()), id: \.element.id) { index, categoria in
                                    CardCategoria(categoria: categoria)
                                        .onAppear {
                                            if categoria.id == categories.last?.id {
                                                loadMore()
                                            }
                                        }
                                }
                                
                                if isLoading {
                                    HStack {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .corUIitens))
                                        Text("Carregando...")
                                            .foregroundStyle(.corTextosBotoes)
                                            .font(.caption)
                                    }
                                    .padding()
                                }
                                
                                if !hasMoreData && !categories.isEmpty {
                                    Text("Todas as categorias carregadas")
                                        .foregroundStyle(.corTextosBotoes.opacity(0.5))
                                        .font(.caption)
                                        .padding()
                                }
                            }
                            .padding()
                        }
                    }
                    
                    Button(action: { mostrarAdicionar = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Nova Categoria")
                                .font(.system(size: 25))
                        }
                        .foregroundStyle(.black)
                        .frame(height: 66)
                        .frame(maxWidth: .infinity)
                        .background(Color.verdeClarinho)
                        .cornerRadius(20)
                    }
                    .padding(EdgeInsets(top: 30, leading: 22, bottom: 15, trailing: 22))
                }
            }
            .sheet(isPresented: $mostrarAdicionar) {
                // ✅ Quando o sheet fechar, recarrega
                reloadCategories()
            } content: {
                AdicionarCategoria()
            }
            .onAppear {
                if categories.isEmpty {
                    loadMore()
                }
            }
        }
        .tint(.corPretoBranco)
    }
    
    var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder.badge.questionmark")
                .font(.system(size: 60))
                .foregroundStyle(Color.corTextosBotoes.opacity(0.5))
            Text("Nenhuma categoria cadastrada")
                .foregroundStyle(Color.corTextosBotoes)
        }
        .frame(maxHeight: .infinity)
    }
    
    // ✅ Função para recarregar do zero
    func reloadCategories() {
        currentOffset = 0
        categories.removeAll()
        hasMoreData = true
        loadMore()
    }
    
    func loadMore() {
        guard !isLoading, hasMoreData else { return }
        
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            do {
                var descriptor = FetchDescriptor<CategoryModel>(
                    sortBy: [SortDescriptor(\.name)]
                )
                descriptor.fetchLimit = pageSize
                descriptor.fetchOffset = currentOffset
                
                let novasCategorias = try modelContext.fetch(descriptor)
                
                if novasCategorias.count < pageSize {
                    hasMoreData = false
                }
                
                categories.append(contentsOf: novasCategorias)
                currentOffset += novasCategorias.count
                isLoading = false
                
                print("📦 Carregadas \(novasCategorias.count) categorias (total: \(categories.count))")
                
            } catch {
                print("❌ Erro ao carregar categorias: \(error)")
                isLoading = false
            }
        }
    }
}



// MARK: - Card de Categoria
struct CardCategoria: View {
    let categoria: CategoryModel
    @Environment(\.modelContext) var modelContext
    @State private var mostrarConfirmacao = false
    
    var body: some View {
        if #available(iOS 26.0, *){
            HStack {
                // Ícone de recorrência (se aplicável)
                if categoria.isRecorrente {
                    VStack {
                        Image(systemName: categoria.tipoRecorrencia.icone)
                            .font(.title2)
                            .foregroundStyle(Color.corUIitens)
                        
                        Text(textoRecorrencia())
                            .font(.caption2)
                            .foregroundStyle(Color.corTextosBotoes.opacity(0.7))
                    }
                    .frame(width: 60)
                } else {
                    Image(systemName: "tag.fill")
                        .font(.title2)
                        .foregroundStyle(Color.corTextosBotoes.opacity(0.6))
                        .frame(width: 60)
                }
                
                VStack() {
                    Text(categoria.name)
                        .font(.headline)
                        .foregroundStyle(Color.corTextosBotoes)
                    
                    if categoria.isRecorrente {
                        HStack(spacing: 4) {
                            Image(systemName: "repeat")
                                .font(.caption)
                            Text(descricaoRecorrencia())
                                .font(.caption)
                        }
                        .foregroundStyle(Color.corUIitens)
                        
                        if let valor = categoria.valorPadrao {
                            Text("Valor padrão: \(valor, format: .currency(code: "BRL"))")
                                .font(.caption)
                                .foregroundStyle(Color.corTextosBotoes.opacity(0.7))
                        }
                        
                        if let proxima = categoria.proximaOcorrencia {
                            Text("Próxima: \(proxima, style: .date)")
                                .font(.caption2)
                                .foregroundStyle(Color.corTextosBotoes.opacity(0.6))
                        }
                    }
                }
                
                Spacer()
                
                // Menu de ações
                Menu {
                    NavigationLink(destination: EditarCategoria(categoria: categoria)) {
                            Label("Editar", systemImage: "pencil.line")
                        }
                    
                    Button(role: .destructive, action: { mostrarConfirmacao = true }) {
                        Label("Deletar", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundStyle(Color.corTextosBotoes)
                        .padding(10)
                }
            }
            .padding()
            
            .glassedEffect(in: .capsule, interactive: true)
            .confirmationDialog("Deletar Categoria?", isPresented: $mostrarConfirmacao) {
                Button("Deletar", role: .destructive) {
                    modelContext.delete(categoria)
                    try? modelContext.save()
                }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("Esta ação não pode ser desfeita. Todas as transações vinculadas também serão removidas.")
            }
        }else{
            HStack {
                // Ícone de recorrência (se aplicável)
                if categoria.isRecorrente {
                    VStack {
                        Image(systemName: categoria.tipoRecorrencia.icone)
                            .font(.title2)
                            .foregroundStyle(Color.corUIitens)
                        
                        Text(textoRecorrencia())
                            .font(.caption2)
                            .foregroundStyle(Color.corTextosBotoes.opacity(0.7))
                    }
                    .frame(width: 60)
                } else {
                    Image(systemName: "tag.fill")
                        .font(.title2)
                        .foregroundStyle(Color.corTextosBotoes.opacity(0.6))
                        .frame(width: 60)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(categoria.name)
                        .font(.headline)
                        .foregroundStyle(Color.corTextosBotoes)
                    
                    if categoria.isRecorrente {
                        HStack(spacing: 4) {
                            Image(systemName: "repeat")
                                .font(.caption)
                            Text(descricaoRecorrencia())
                                .font(.caption)
                        }
                        .foregroundStyle(Color.corUIitens)
                        
                        if let valor = categoria.valorPadrao {
                            Text("Valor padrão: \(valor, format: .currency(code: "BRL"))")
                                .font(.caption)
                                .foregroundStyle(Color.corTextosBotoes.opacity(0.7))
                        }
                        
                        if let proxima = categoria.proximaOcorrencia {
                            Text("Próxima: \(proxima, style: .date)")
                                .font(.caption2)
                                .foregroundStyle(Color.corTextosBotoes.opacity(0.6))
                        }
                    }
                }
                
                Spacer()
                
                // Menu de ações
                Menu {
                    NavigationLink(destination: EditarCategoria(categoria: categoria)) {
                            Label("Editar", systemImage: "pencil.line")
                        }
                    Button(role: .destructive){
                        mostrarConfirmacao = true
                
                    } label: {
                        HStack {
                            Text("Deletar")
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                        }
                    }
                    .tint(.red)
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundStyle(Color.corTextosBotoes)
                        .padding(10)
                }
                
            }
            .padding()
            .background(Color.corCaixaDeTexto)
            .cornerRadius(10)
            .confirmationDialog("Deletar Categoria?", isPresented: $mostrarConfirmacao) {
                Button("Deletar", role: .destructive) {
                    modelContext.delete(categoria)
                    try? modelContext.save()
                }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("Esta ação não pode ser desfeita. Todas as transações vinculadas também serão removidas.")
            }
    }
    }
    
    func textoRecorrencia() -> String {
        let intervalo = categoria.intervaloRecorrencia
        switch categoria.tipoRecorrencia {
        case .diaria: return "\(intervalo)d"
        case .semanal: return "\(intervalo)s"
        case .mensal: return "\(intervalo)m"
        case .anual: return "\(intervalo)a"
        case .personalizada: return "\(intervalo)d"
        case .nenhuma: return ""
        }
    }

    func descricaoRecorrencia() -> String {
        let intervalo = categoria.intervaloRecorrencia
        switch categoria.tipoRecorrencia {
        case .diaria: return intervalo == 1 ? "Diária" : "A cada \(intervalo) dias"
        case .semanal: return intervalo == 1 ? "Semanal" : "A cada \(intervalo) semanas"
        case .mensal: return intervalo == 1 ? "Mensal" : "A cada \(intervalo) meses"
        case .anual: return intervalo == 1 ? "Anual" : "A cada \(intervalo) anos"
        case .personalizada: return "A cada \(intervalo) dias"
        case .nenhuma: return ""
        }
    }

}

#Preview {
    categorias()
        .modelContainer(PreviewHelper.container)
}

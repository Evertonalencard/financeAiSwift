import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()
    @Environment(\.modelContext) var modelContext
    
    @State private var transacaoSelecionada: TransactionModel? = nil
    @State private var mostrarConfirmacaoParar = false
    @State private var mostrarConfirmacaoDelete = false
    
    var monthsArray: [String: String] = [
        "12": "Dezembro", "11": "Novembro", "10": "Outubro", "09": "Setembro",
        "08": "Agosto", "07": "Julho", "06": "Junho", "05": "Maio",
        "04": "Abril", "03": "Março", "02": "Fevereiro", "01": "Janeiro",
    ]
    
    func getMonthFromDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM"
        return formatter.string(from: date)
    }
    
    var body: some View {
        NavigationStack{
            ZStack {
                if #available(iOS 26.0, *){
                    LinearGradient(
                        colors: [Color.corDeFundo, Color.corDeFundo2],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
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
                    LinearGradient(
                        colors: [Color.corDeFundo, Color.corDeFundo2],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
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
                
                VStack {
                    Text("Histórico de Finanças")
                        .font(.system(size: 30, weight: .bold, design: .default))
                        .foregroundStyle(.corTextosBotoes)
                    
                    if #available(iOS 26.0, *) {
                        ScrollView {
                            contentList
                        }
                        // ✅ Efeito Soft para iOS 26
                        .scrollEdgeEffectStyle(.soft, for: .all)
                    } else {
                        ScrollView {
                            contentList
                        }
                    }
                }
            }
            .onAppear() {
                viewModel.setContext(modelContext)
            }
        }
        .tint(.corPretoBranco)
        .confirmationDialog("Parar Recorrência?", isPresented: $mostrarConfirmacaoParar, presenting: transacaoSelecionada) { transacao in
            Button("Parar", role: .destructive) {
                pararRecorrencia(transaction: transacao)
            }
            Button("Cancelar", role: .cancel) {}
        } message: { _ in
            Text("A categoria continuará recorrente, mas esta transação específica não será mais criada automaticamente.")
        }
        .confirmationDialog("Deletar Transação?", isPresented: $mostrarConfirmacaoDelete, presenting: transacaoSelecionada) { transacao in
            Button("Deletar", role: .destructive) {
                viewModel.removeTransaction(transaction: transacao)
            }
            Button("Cancelar", role: .cancel) {}
        } message: { _ in
            Text("Esta ação não pode ser desfeita.")
        }
    }
    
    // Conteúdo da lista extraído
    // Substitua APENAS a var contentList:
    var contentList: some View {
        LazyVStack {
            ForEach(monthsArray.sorted(by: { $0.key > $1.key }), id: \.key) { key, value in
                // ✅ FILTRAR transações do mês ANTES do ForEach
                let transacoesDoMes = viewModel.transactions.filter { getMonthFromDate($0.data) == key }
                
                if !transacoesDoMes.isEmpty {
                    HStack {
                        Text(value)
                            .safeAreaPadding(.top, 10)
                            .font(.system(size: 20))
                            .foregroundStyle(.corTextosBotoes)
                            .padding(.leading, 20)
                        Spacer()
                    }
                    
                    // ✅ Agora itera apenas as transações deste mês
                    ForEach(transacoesDoMes) { transaction in
                        VStack {
                            if #available(iOS 26.0, *) {
                                ZStack {
                                    if (transaction.valor < 0) { Color.corVermelhoApagar.opacity(0.7) } else { Color.corCaixaDeTexto.opacity(0.7) }
                                    HStack {
                                        if transaction.isRecorrente {
                                            VStack(spacing: 2) {
                                                Image(systemName: transaction.recorrenciaAtiva ? "repeat.circle.fill" : "pause.circle.fill")
                                                    .foregroundStyle(transaction.recorrenciaAtiva ? Color.corUIitens : Color.gray)
                                                
                                                if !transaction.recorrenciaAtiva {
                                                    Text("Pausada")
                                                        .font(.system(size: 8))
                                                        .foregroundStyle(Color.gray)
                                                }
                                            }
                                        }
                                        
                                        VStack(alignment: .leading) {
                                            Text(transaction.descricao)
                                                .font(.system(size: 22))
                                                .foregroundColor(Color.corTextosBotoes)
                                            Text(transaction.category?.name ?? "Sem categoria")
                                                .font(.system(size: 12))
                                                .foregroundColor(Color.corTextosBotoes)
                                        }.padding(.leading,10)
                                        Spacer()
                                        Text(transaction.valor, format: .currency(code: "BRL"))
                                            .font(.system(size: 18))
                                            .foregroundColor(Color.corTextosBotoes)
                                        
                                        Menu {
                                            NavigationLink(destination: editTransaction(transaction: transaction)){
                                                HStack {
                                                    Text("Editar")
                                                    Image(systemName: "pencil.line")
                                                }
                                            }
                                            
                                            if transaction.isRecorrente && transaction.recorrenciaAtiva {
                                                Button(action: {
                                                    transacaoSelecionada = transaction
                                                    mostrarConfirmacaoParar = true
                                                }) {
                                                    Label("Parar Recorrência", systemImage: "pause.circle")
                                                }
                                            }
                                            if transaction.isRecorrente && !transaction.recorrenciaAtiva {
                                                Button(action: {
                                                    retormarRecorrencia(transaction: transaction)
                                                }) {
                                                    Label("Retomar Recorrência", systemImage: "play.circle")
                                                }
                                            }
                                            
                                            Button(role: .destructive) {
                                                transacaoSelecionada = transaction
                                                mostrarConfirmacaoDelete = true
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
                                                .foregroundColor(.corTextosBotoes)
                                                .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 10))
                                        }
                                        .menuOrder(.fixed)
                                    }
                                    .safeAreaPadding(.horizontal, 8)
                                    .safeAreaPadding(.vertical, 15)
                                }
                                .cornerRadius(100)
                                .glassedEffect(in: .capsule, interactive: true)
                                .padding(2)
                                .safeAreaPadding(.horizontal, 20)
                            } else {
                                ZStack {
                                    if (transaction.valor < 0) { Color.corVermelhoApagar } else { Color.corCaixaDeTexto }
                                    HStack {
                                        if transaction.isRecorrente {
                                            VStack(spacing: 2) {
                                                Image(systemName: transaction.recorrenciaAtiva ? "repeat.circle.fill" : "pause.circle.fill")
                                                    .foregroundStyle(transaction.recorrenciaAtiva ? Color.corUIitens : Color.gray)
                                                
                                                if !transaction.recorrenciaAtiva {
                                                    Text("Pausada")
                                                        .font(.system(size: 8))
                                                        .foregroundStyle(Color.gray)
                                                }
                                            }
                                        }
                                        VStack(alignment: .leading) {
                                            Text(transaction.descricao)
                                                .font(.system(size: 22))
                                                .foregroundColor(Color.corTextosBotoes)
                                            Text(transaction.category?.name ?? "Sem categoria")
                                                .font(.system(size: 12))
                                                .foregroundColor(Color.corTextosBotoes)
                                        }
                                        Spacer()
                                        Text(transaction.valor, format: .currency(code: "BRL"))
                                            .font(.system(size: 18))
                                            .foregroundColor(Color.corTextosBotoes)
                                        
                                        Menu {
                                            NavigationLink(destination: editTransaction(transaction: transaction)){
                                                HStack {
                                                    Text("Editar")
                                                    Image(systemName: "pencil.line")
                                                }
                                            }
                                            
                                            if transaction.isRecorrente && transaction.recorrenciaAtiva {
                                                Button(action: {
                                                    transacaoSelecionada = transaction
                                                    mostrarConfirmacaoParar = true
                                                }) {
                                                    Label("Parar Recorrência", systemImage: "pause.circle")
                                                }
                                            }
                                            if transaction.isRecorrente && !transaction.recorrenciaAtiva {
                                                Button(action: {
                                                    retormarRecorrencia(transaction: transaction)
                                                }) {
                                                    Label("Retomar Recorrência", systemImage: "play.circle")
                                                }
                                            }
                                            
                                            Button(role: .destructive) {
                                                transacaoSelecionada = transaction
                                                mostrarConfirmacaoDelete = true
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
                                                .foregroundColor(.corTextosBotoes)
                                                .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 10))
                                        }
                                        .menuOrder(.fixed)
                                    }
                                    .safeAreaPadding(.horizontal, 8)
                                    .safeAreaPadding(.vertical, 15)
                                }
                                .cornerRadius(10)
                                .padding(2)
                                .safeAreaPadding(.horizontal, 20)
                            }
                        }
                        .onAppear {
                            // ✅ Detecta último item de TODAS as transações (não só do mês)
                            if transaction.id == viewModel.transactions.last?.id {
                                viewModel.fetchMore()
                            }
                        }
                    }
                }
            }
            
            // Indicador de carregamento
            if viewModel.isLoading {
                HStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .corUIitens))
                    Text("Carregando...")
                        .foregroundStyle(.corTextosBotoes)
                        .font(.caption)
                }
                .padding()
            }
        }
    }
    // MARK: - Funções de Recorrência
    
    func pararRecorrencia(transaction: TransactionModel) {
        // ✅ Só pode pausar recorrências individuais
        guard transaction.isRecorrenteIndividual else {
            print("⚠️ Não é possível pausar transações automáticas")
            return
        }
        
        transaction.recorrenciaAtiva = false
        
        do {
            try modelContext.save()
            viewModel.fetch()
            print("⏸️ Recorrência pausada para: \(transaction.descricao)")
        } catch {
            print("❌ Erro ao parar recorrência: \(error)")
        }
    }
    
    func retormarRecorrencia(transaction: TransactionModel) {
        guard transaction.isRecorrenteIndividual else { return }
        
        transaction.recorrenciaAtiva = true
        
        if let intervalo = transaction.intervaloRecorrencia,
           let tipoRaw = transaction.tipoRecorrenciaRaw,
           let tipo = TipoRecorrencia(rawValue: tipoRaw) {
            transaction.proximaOcorrencia = CategoryModel.calcularProximaOcorrencia(
                from: Date(),
                tipo: tipo,
                intervalo: intervalo
            )
        }
        
        do {
            try modelContext.save()
            viewModel.fetch()
            print("▶️ Recorrência retomada para: \(transaction.descricao)")
        } catch {
            print("❌ Erro ao retomar recorrência: \(error)")
        }
    }
    
}

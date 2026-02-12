import SwiftUI
import SwiftData



struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()
    @Environment(\.modelContext) var modelContext
    
    @State private var transacaoSelecionada: TransactionModel? = nil
    @State private var mostrarConfirmacaoParar = false
    @State private var mostrarConfirmacaoDelete = false
    @State private var searchText = ""
    @State private var mesesExpandidos: Set<String> = []
    
    var monthsArray: [String: String] = [
        "12": "Dezembro", "11": "Novembro", "10": "Outubro", "09": "Setembro",
        "08": "Agosto", "07": "Julho", "06": "Junho", "05": "Maio",
        "04": "Abril", "03": "Março", "02": "Fevereiro", "01": "Janeiro",
    ]
    
    
    // MARK: - Helpers de Data
    func getMonthYearKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-yyyy"
        return formatter.string(from: date)
    }
    
    // MARK: - Filtro de Transações
    var transacoesFiltradas: [TransactionModel] {
        if searchText.isEmpty {
            return viewModel.transactions
        } else {
            return viewModel.transactions.filter { transaction in
                let descricaoMatch = transaction.descricao.localizedCaseInsensitiveContains(searchText)
                let categoriaMatch = transaction.category?.name.localizedCaseInsensitiveContains(searchText) ?? false
                return descricaoMatch || categoriaMatch
            }
        }
    }
    
    var transacoesPorMesAno: [String: [TransactionModel]] {
        Dictionary(grouping: transacoesFiltradas) { transaction in
            getMonthYearKey(transaction.data)
        }
    }
    
    var mesesOrdenados: [String] {
        transacoesPorMesAno.keys.sorted(by: >)
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                // Fundo com Gradiente e Bolas
                if #available(iOS 26.0, *) {
                    LinearGradient(colors: [Color.corDeFundo, Color.corDeFundo2], startPoint: .topLeading, endPoint: .bottomTrailing)
                        .ignoresSafeArea()
                    Circle().fill(Color.bolaVerde.opacity(0.1)).glassedEffect(in: .capsule, interactive: true).frame(width: 410, height: 410).offset(x: -100, y: -300)
                    Circle().fill(Color.bolaAzul.opacity(0.1)).glassedEffect(in: .capsule, interactive: true).frame(width: 360, height: 360).offset(x: 100, y: 300)
                } else {
                    LinearGradient(colors: [Color.corDeFundo, Color.corDeFundo2], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
                    Circle().fill(Color.bolaVerde.opacity(0.3)).frame(width: 300, height: 300).blur(radius: 40).offset(x: -100, y: -300)
                    Circle().fill(Color.bolaAzul.opacity(0.3)).frame(width: 300, height: 300).blur(radius: 40).offset(x: 100, y: 200)
                }
                
                VStack(spacing: 0) {
                    // ✅ Título fixo no topo
                    Text("Histórico de Finanças")
                        .font(.system(size: 30, weight: .bold, design: .default))
                        .foregroundStyle(.corTextosBotoes)
                        .padding(.top, 10)
                        .padding(.bottom, 8)
                    
                    filtroPeriodo

                    // ✅ ScrollView com barra de pesquisa dentro
                    if #available(iOS 26.0, *) {
                        ScrollView {
                            VStack(spacing: 12) {
                                searchBar
                                contentList
                            }
                        }
                        .scrollEdgeEffectStyle(.soft, for: .all)
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                searchBar
                                contentList
                            }
                        }
                    }
                }
            }
            .onAppear() {
                viewModel.setContext(modelContext)
                expandirMesAtual()
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
        .tint(.corPretoBranco)
        .confirmationDialog("Parar Recorrência?", isPresented: $mostrarConfirmacaoParar, presenting: transacaoSelecionada) { transacao in
            Button("Parar", role: .destructive) { pararRecorrencia(transaction: transacao) }
            Button("Cancelar", role: .cancel) {}
        } message: { _ in
            Text("A categoria continuará recorrente, mas esta transação específica não será mais criada automaticamente.")
        }
        .confirmationDialog("Deletar Transação?", isPresented: $mostrarConfirmacaoDelete, presenting: transacaoSelecionada) { transacao in
            Button("Deletar", role: .destructive) { viewModel.removeTransaction(transaction: transacao) }
            Button("Cancelar", role: .cancel) {}
        } message: { _ in Text("Esta ação não pode ser desfeita.") }
    }
    
    // MARK: - Barra de Pesquisa Customizada
    var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.corTextosBotoes.opacity(0.6))
                .font(.system(size: 18))
            
            TextField("", text: $searchText, prompt: Text("Buscar transação ou categoria").foregroundStyle(.corTextosBotoes.opacity(0.5)))
                .foregroundStyle(.corTextosBotoes)
                .font(.system(size: 17))
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.corTextosBotoes.opacity(0.6))
                        .font(.system(size: 18))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.corCaixaDeTexto.opacity(0.5))
        .glassedEffect(in: .capsule, interactive: true)
        .cornerRadius(100)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Lógica de Expansão
    func expandirMesAtual() {
        let mesAtual = getMonthYearKey(Date())
        mesesExpandidos.insert(mesAtual)
    }
    
    // MARK: - Lista de Conteúdo
    var contentList: some View {
        LazyVStack(spacing: 0) {
            // ✅ Se houver busca ativa e nenhum resultado
            if !searchText.isEmpty && mesesOrdenados.isEmpty {
                ContentUnavailableView.search(text: searchText)
                    .padding(.top, 50)
            }
            
            ForEach(mesesOrdenados, id: \.self) { mesAno in
                let transacoesDoMes = transacoesPorMesAno[mesAno] ?? []
                let mes = String(mesAno.prefix(2))
                let ano = String(mesAno.suffix(4))
                let nomeDoMes = monthsArray[mes] ?? "Desconhecido"
                
                // Se estiver buscando, expande tudo automaticamente
                let estaExpandido = !searchText.isEmpty || mesesExpandidos.contains(mesAno)
                
                VStack(spacing: 0) {
                    // Cabeçalho do mês
                    Button(action: {
                        withAnimation(.easeInOut) {
                            if mesesExpandidos.contains(mesAno) {
                                mesesExpandidos.remove(mesAno)
                            } else {
                                mesesExpandidos.insert(mesAno)
                            }
                        }
                    }) {
                        if #available(iOS 26.0, *) {
                            headerMesView(nome: nomeDoMes, ano: ano, count: transacoesDoMes.count, expandido: estaExpandido)
                                .glassedEffect(in: .capsule, interactive: true)
                        } else {
                            headerMesView(nome: nomeDoMes, ano: ano, count: transacoesDoMes.count, expandido: estaExpandido)
                                .background(Color.corCaixaDeTexto.opacity(0.2))
                                .cornerRadius(10)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // Lista de transações
                    if estaExpandido {
                        ForEach(transacoesDoMes.sorted(by: { $0.data > $1.data })) { transaction in
                            transactionRow(transaction: transaction)
                                .transition(.asymmetric(insertion: .opacity.combined(with: .move(edge: .top)), removal: .opacity))
                        }
                    }
                }
            }
            
            if viewModel.isLoading {
                HStack {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .corUIitens))
                    Text("Carregando...").foregroundStyle(.corTextosBotoes).font(.caption)
                }.padding()
            }
        }
    }
    
    
    // ✅ MENU COM MÚLTIPLAS OPÇÕES
    var filtroPeriodo: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: viewModel.periodoSelecionado.icone)
                    .font(.caption)
                Text(viewModel.periodoSelecionado.rawValue)
                    .font(.caption)
            }
            .foregroundStyle(.corTextosBotoes.opacity(0.8))
            
            Spacer()
            
            Menu {
                ForEach(ContentViewModel.PeriodoHistorico.allCases, id: \.self) { periodo in
                    Button {
                        viewModel.periodoSelecionado = periodo
                        
                        // Atualiza a data limite
                        if let meses = periodo.meses {
                            let calendar = Calendar.current
                            viewModel.dataLimite = calendar.date(byAdding: .month, value: meses, to: Date())
                        } else {
                            viewModel.dataLimite = nil
                        }
                        
                        viewModel.resetAndFetch()
                    } label: {
                        HStack {
                            Label(periodo.rawValue, systemImage: periodo.icone)
                            if viewModel.periodoSelecionado == periodo {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.corUIitens)
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "slider.horizontal.3")
                    Text("Período")
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                }
                .font(.caption)
                .foregroundStyle(.corUIitens)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .glassedEffect(in: .capsule, interactive: true)
                .cornerRadius(8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    
    // MARK: - Componente do Cabeçalho do Mês
    func headerMesView(nome: String, ano: String, count: Int, expandido: Bool) -> some View {
        HStack {
            Image(systemName: expandido ? "chevron.down" : "chevron.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.corUIitens)
                .frame(width: 20)
            
            Text("\(nome) \(ano)")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.corTextosBotoes)
            
            Spacer()
            
            Text("\(count)")
                .font(.system(size: 14))
                .foregroundStyle(.corTextosBotoes.opacity(0.6))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.corCaixaDeTexto.opacity(0.3))
                .cornerRadius(8)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    // MARK: - Linha de Transação
    @ViewBuilder
    func transactionRow(transaction: TransactionModel) -> some View {
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
                                    Text("Pausada").font(.system(size: 8)).foregroundStyle(Color.gray)
                                }
                            }
                        }
                        VStack(alignment: .leading) {
                            Text(transaction.descricao).font(.system(size: 22)).foregroundColor(Color.corTextosBotoes)
                            Text(transaction.category?.name ?? "Sem categoria").font(.system(size: 12)).foregroundColor(Color.corTextosBotoes)
                        }.padding(.leading,10)
                        Spacer()
                        Text(transaction.valor, format: .currency(code: "BRL")).font(.system(size: 18)).foregroundColor(Color.corTextosBotoes)
                        menuTransacao(transaction: transaction)
                    }
                    .safeAreaPadding(.horizontal, 8).safeAreaPadding(.vertical, 15)
                }
                .cornerRadius(100).glassedEffect(in: .capsule, interactive: true).padding(2).safeAreaPadding(.horizontal, 20)
            } else {
                ZStack {
                    if (transaction.valor < 0) { Color.corVermelhoApagar } else { Color.corCaixaDeTexto }
                    HStack {
                        if transaction.isRecorrente {
                            VStack(spacing: 2) {
                                Image(systemName: transaction.recorrenciaAtiva ? "repeat.circle.fill" : "pause.circle.fill")
                                    .foregroundStyle(transaction.recorrenciaAtiva ? Color.corUIitens : Color.gray)
                                if !transaction.recorrenciaAtiva {
                                    Text("Pausada").font(.system(size: 8)).foregroundStyle(Color.gray)
                                }
                            }
                        }
                        VStack(alignment: .leading) {
                            Text(transaction.descricao).font(.system(size: 22)).foregroundColor(Color.corTextosBotoes)
                            Text(transaction.category?.name ?? "Sem categoria").font(.system(size: 12)).foregroundColor(Color.corTextosBotoes)
                        }
                        Spacer()
                        Text(transaction.valor, format: .currency(code: "BRL")).font(.system(size: 18)).foregroundColor(Color.corTextosBotoes)
                        menuTransacao(transaction: transaction)
                    }
                    .safeAreaPadding(.horizontal, 8).safeAreaPadding(.vertical, 15)
                }
                .cornerRadius(10).padding(2).safeAreaPadding(.horizontal, 20)
            }
        }
        .onAppear {
            if transaction.id == viewModel.transactions.last?.id { viewModel.fetchMore() }
        }
    }
    
    // MARK: - Menu de Transação
    func menuTransacao(transaction: TransactionModel) -> some View {
        Menu {
            NavigationLink(destination: editTransaction(transaction: transaction)){
                HStack { Text("Editar"); Image(systemName: "pencil.line") }
            }
            if transaction.isRecorrente && transaction.recorrenciaAtiva {
                Button(action: { transacaoSelecionada = transaction; mostrarConfirmacaoParar = true }) { Label("Parar Recorrência", systemImage: "pause.circle") }
            }
            if transaction.isRecorrente && !transaction.recorrenciaAtiva {
                Button(action: { retormarRecorrencia(transaction: transaction) }) { Label("Retomar Recorrência", systemImage: "play.circle") }
            }
            Button(role: .destructive) { transacaoSelecionada = transaction; mostrarConfirmacaoDelete = true } label: { HStack { Text("Deletar"); Image(systemName: "trash").foregroundStyle(.red) } }.tint(.red)
        } label: {
            Image(systemName: "ellipsis").rotationEffect(.degrees(90)).foregroundColor(.corTextosBotoes).padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 10))
        }
        .menuOrder(.fixed)
    }
    
    // MARK: - Funções de Recorrência
    func pararRecorrencia(transaction: TransactionModel) {
        guard transaction.isRecorrenteIndividual else { return }
        transaction.recorrenciaAtiva = false
        try? modelContext.save(); viewModel.fetch()
    }
    
    func retormarRecorrencia(transaction: TransactionModel) {
        guard transaction.isRecorrenteIndividual else { return }
        transaction.recorrenciaAtiva = true
        if let intervalo = transaction.intervaloRecorrencia, let tipoRaw = transaction.tipoRecorrenciaRaw, let tipo = TipoRecorrencia(rawValue: tipoRaw) {
            transaction.proximaOcorrencia = CategoryModel.calcularProximaOcorrencia(from: Date(), tipo: tipo, intervalo: intervalo)
        }
        try? modelContext.save(); viewModel.fetch()
    }
}

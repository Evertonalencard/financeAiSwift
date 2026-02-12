import SwiftUI
import SwiftData
import GoogleGenerativeAI
import FoundationModels

enum source: String {
    case user, ai
}

struct message: Identifiable {
    var id: UUID = UUID()
    var source: source
    var text: String
}

// MARK: - Enum para gerenciar modelos de IA
enum AIModel {
    case appleIntelligence
    case gemini
    
    var displayName: String {
        switch self {
        case .appleIntelligence: return "Apple Intelligence"
        case .gemini: return "Gemini 27B"
        }
    }
    
    var icon: String {
        switch self {
        case .appleIntelligence: return "apple.intelligence"
        case .gemini: return "sparkles"
        }
    }
}

struct IADasFinancas: View {
    // MARK: - Propriedades
    
    @FocusState var focusIA: Bool
    @StateObject private var viewModel = ViewModel()
    @Environment(\.modelContext) var modelContext
    
    // ✅ Estados para gerenciar Apple Intelligence
    @State private var modeloAtual: AIModel = .gemini
    @State private var mostrarAlertaAppleIntelligence = false
    
    // ✅ CORRIGIDO: Adiciona @available para iOS 26.0+
    @State private var appleIntelligenceSession: Any? // Usamos Any para evitar erro de compilação
    
    let modelGemini = GenerativeModel(name: "gemma-3-27b-it", apiKey: APIKey.default)
    
    @State var textInput: String = ""
    @State var aiResponse: message = message(source: .ai, text: "Olá! Como posso te ajudar com suas finanças hoje?")
    @State var loading: Bool = false
    @State var listSystemMessages: [message] = []
    
    // Lista de Perguntas Padrão
    let perguntasSugestivas = [
        "Qual categoria teve a maior quantidade de gastos e qual gastou mais? ",
        "Quanto gastei em Alimentação?",
        "Faça um resumo dos meus gastos",
        "Me dê uma dica de economia",
        "Quais foram minhas 5 compras mais altas recentemente?",
        "Existe alguma categoria cujo gasto esteja aumentando?",
        "Você identifica algum padrão de despesas recorrentes que poderia ser otimizado?",
        "Há algum gasto incomum ou fora do padrão recentemente?",
        "Como meus gastos de hoje se comparam à média dos últimos dias?",
        "Quais categorias têm maior variação mês a mês?",
        "Com base em todo histórico de transações, qual seria uma projeção do meu saldo e transações para o próximo mês?"
    ]
    
    // MARK: - Body
    
    var body: some View {
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
                // Cabeçalho com indicador de modelo
                HStack(spacing: 8) {
                    Text("Chat")
                        .font(.title)
                        .bold()
                        .foregroundStyle(Color.corTextosBotoes)
                    
                    // Indicador do modelo atual
                    HStack(spacing: 4) {
                        Image(systemName: modeloAtual.icon)
                            .font(.caption)
                        Text(modeloAtual.displayName)
                            .font(.caption)
                    }
                    .foregroundStyle(Color.corUIitens)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.corCaixaDeTexto.opacity(0.5))
                    .cornerRadius(8)
                }
                .safeAreaPadding(.top, 1)
                
                // MARK: - Área de Mensagens
                ScrollView {
                    LazyVStack{
                        ForEach(listSystemMessages) { msg in
                            if (msg.source == .user ) {
                                HStack {
                                    Spacer()
                                    Text(msg.text)
                                        .padding(10)
                                        .foregroundColor(.corTextosBotoes)
                                        .background(.corCaixaDeTexto)
                                        .font(.system(size: 25))
                                        .cornerRadius(10)
                                        .safeAreaPadding(.vertical, 5)
                                        .overlay(alignment: .bottomTrailing) {
                                            Image(systemName: "arrowtriangle.down.fill")
                                                .font(.title)
                                                .rotationEffect(.degrees(-45))
                                                .offset(x: 10, y: 3)
                                                .foregroundColor(.corCaixaDeTexto)
                                        }
                                }
                            } else {
                                HStack {
                                    Text(msg.text)
                                        .padding(10)
                                        .foregroundColor(.corTextosBotoes)
                                        .background(.corCaixaDeTexto)
                                        .font(.system(size: 25))
                                        .cornerRadius(10)
                                        .safeAreaPadding(.vertical, 5)
                                        .overlay(alignment: .bottomLeading) {
                                            Image(systemName: "arrowtriangle.down.fill")
                                                .font(.title)
                                                .rotationEffect(.degrees(45))
                                                .offset(x: -10, y: 3)
                                                .foregroundColor(.corCaixaDeTexto)
                                        }
                                    Spacer()
                                }
                            }
                        }
                        if (loading) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .safeAreaPadding(.top, 20)
                        }
                    }
                }
                .safeAreaPadding(.horizontal, 15)
                
                Spacer()
                
                // MARK: - Sugestões de Perguntas
                if !loading {
                    ScrollView(.horizontal, showsIndicators: false) {
                        if #available(iOS 26.0,*){
                            GlassEffectContainer(spacing: 50){
                                HStack(spacing: 30) {
                                    ForEach(perguntasSugestivas, id: \.self) { sugestao in
                                        Button {
                                            enviarMensagem(texto: sugestao)
                                        } label: {
                                            Text(sugestao)
                                                .lineLimit(2)
                                                .multilineTextAlignment(.leading)
                                                .frame(maxWidth: 500, alignment: .leading)
                                                .fixedSize(horizontal: true, vertical: true)
                                                .font(.system(size: 18))
                                                .foregroundStyle(Color.corTextosBotoes)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 10)
                                                .glassedEffect(in: Capsule(), interactive: true)
                                                .contentShape(Rectangle())
                                        }
                                    }
                                }
                                .padding(.vertical,5)
                            }
                            .padding(.horizontal,20)
                        } else {
                            HStack(spacing: 12) {
                                ForEach(perguntasSugestivas, id: \.self) { sugestao in
                                    Button {
                                        enviarMensagem(texto: sugestao)
                                    } label: {
                                        Text(sugestao)
                                            .lineLimit(2)
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: 500, alignment: .leading)
                                            .fixedSize(horizontal: true, vertical: true)
                                            .font(.system(size: 18))
                                            .foregroundStyle(Color.corTextosBotoes)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(Color.corCaixaDeTexto)
                                            .cornerRadius(10)
                                            .contentShape(Rectangle())
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 5)
                }
                
                // MARK: - Barra de Input
                HStack(alignment: .bottom) {
                    ZStack {
                        if #available(iOS 26.0,*){
                            HStack {
                                TextField("", text: $textInput, prompt: Text("Diga algo...").foregroundColor(.corTextosBotoes).font(.system(size: 25)),axis: .vertical)
                                    .lineLimit(1...3)
                                    .foregroundColor(.corTextosBotoes)
                                    .font(.system(size: 25))
                                    .focused($focusIA)
                                    .safeAreaPadding(.horizontal, 10)
                                    .padding(10)
                                    .glassedEffect(in: .capsule, interactive: true)
                            }
                        } else {
                            HStack {
                                TextField("", text: $textInput, prompt: Text("Diga algo...").foregroundColor(.corTextosBotoes).font(.system(size: 25)), axis: .vertical)
                                    .lineLimit(1...3)
                                    .foregroundColor(.corTextosBotoes)
                                    .font(.system(size: 25))
                                    .focused($focusIA)
                                    .safeAreaPadding(10)
                                    .background(Color.corCaixaDeTexto)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    
                    if #available(iOS 26.0, *){
                        Button {
                            enviarMensagem(texto: textInput)
                        } label: {
                            Image(systemName: "paperplane.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .contentShape(Rectangle())
                        }
                        .padding(12)
                        .glassedEffect(in: .circle, interactive: true)
                        .foregroundColor(.corTextosBotoes)
                    } else {
                        Button {
                            enviarMensagem(texto: textInput)
                        } label: {
                            Image(systemName: "paperplane.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .contentShape(Rectangle())
                        }
                        .padding(12)
                        .background(.corCaixaDeTexto)
                        .foregroundColor(.corTextosBotoes)
                        .cornerRadius(100)
                    }
                }
            }
            .padding(.horizontal, 20)
            .safeAreaPadding(.bottom,10)
        }
        .onAppear {
            viewModel.setContext(modelContext)
            
            // Verifica disponibilidade do Apple Intelligence
            verificarDisponibilidadeAppleIntelligence()
            
            if listSystemMessages.isEmpty {
                listSystemMessages.append(aiResponse)
            }
        }
        .onTapGesture {
            focusIA = false
            hideKeyboard()
        }
        // Alerta quando Apple Intelligence está desabilitado
        .alert("Apple Intelligence Desabilitado", isPresented: $mostrarAlertaAppleIntelligence) {
            Button("Ir para Ajustes") {
                if let url = URL(string: "App-prefs:root=APPLE_INTELLIGENCE") {
                    UIApplication.shared.open(url)
                }
            }
            Button("Usar Gemini", role: .cancel) {
                modeloAtual = .gemini
            }
        } message: {
            Text("Para usar o Apple Intelligence, ative-o em Ajustes > Apple Intelligence & Siri.")
        }
    }
    
    // MARK: - Funções
    
    // ✅ CORRIGIDO: Adiciona verificação de versão
    func verificarDisponibilidadeAppleIntelligence() {
        if #available(iOS 26.0, *) {
            let systemModel = SystemLanguageModel.default
            
            switch systemModel.availability {
            case .available:
                // ✅ Dispositivo suporta e está habilitado
                modeloAtual = .appleIntelligence
                configurarAppleIntelligence()
                print("✅ Apple Intelligence disponível e habilitado")
                
            case .unavailable(let reason):
                switch reason {
                case .appleIntelligenceNotEnabled:
                    // ⚠️ Suporta mas está desabilitado
                    print("⚠️ Apple Intelligence está desabilitado")
                    mostrarAlertaAppleIntelligence = true
                    modeloAtual = .gemini
                    
                case .deviceNotEligible:
                    // ❌ Dispositivo não suporta
                    print("❌ Dispositivo não suporta Apple Intelligence")
                    modeloAtual = .gemini
                    
                case .modelNotReady:
                    // ⏳ Modelo ainda não está pronto (download/inicialização)
                    print("⏳ Modelo Apple Intelligence não está pronto")
                    modeloAtual = .gemini
                    
                @unknown default:
                    print("❌ Razão desconhecida para indisponibilidade")
                    modeloAtual = .gemini
                }
            }
        } else {
            // iOS < 26.0 - Usa Gemini
            modeloAtual = .gemini
            print("ℹ️ iOS < 26.0 - Usando Gemini")
        }
    }
    
    // ✅ CORRIGIDO: Adiciona @available
    @available(iOS 26.0, *)
    func configurarAppleIntelligence() {
        let instructions = """
                Você é um assistente financeiro pessoal de alta precisão.
                
                ⛔️ REGRAS CRÍTICAS DE RESPOSTA (SIGA ESTRITAMENTE):
                1. NÃO use Markdown (sem **, sem #, sem negrito, sem itálico). Use apenas texto puro.
                2. NÃO use formatação de código ou blocos JSON.
                3. Use APENAS estes emojis para listas: 🟢 (bom,positivo), 🔴 (ruim,negativo), 🔹 (itens), 🔸 (alertas), ✅ (gamhos), ❌ (gastos).
                4. Ao calcular totais, some explicitamente os valores listados antes de responder.
                                    
                🧠 COMO INTERPRETAR OS DADOS:
                - Transações marcadas como "GASTO" (valor negativo) subtraem do saldo.
                - Transações marcadas como "GANHO" (valor positivo) somam ao saldo.
                - "Recorrência: ATIVA" significa que essa cobrança acontecerá novamente na data "Próxima".
                - "Recorrência: PAUSADA" significa que é uma conta fixa, mas o usuário parou temporariamente.
                - "Categoria RECORRENTE" indica um compromisso fixo (ex: Aluguel, Assinaturas).
                - evite usar os valores predefinidos das categorias, use apenas os valores vindos de transacoes 
                                    
                🧮 INSTRUÇÕES DE CÁLCULO:
                - Se perguntado "quanto gastei em X", some APENAS transações onde a Categoria ou Descrição contém X.
                - Ignore transações futuras (datas após hoje) para cálculos de histórico passado.
                - Para projeções futuras, use as datas "Próxima" das categorias e transações recorrentes ATIVAS.
                                    
                📢 TOM DE VOZ:
                Seja direto e numérico. Evite enrolação.
                Exemplo bom: "Você gastou R$ 500,00 em Alimentação."
                Exemplo ruim: "Olhando seus dados, parece que houve um gasto aproximado de..."
                """
        
        appleIntelligenceSession = LanguageModelSession(instructions: instructions)
    }
    
    func enviarMensagem(texto: String) {
        guard !texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        focusIA = false
        hideKeyboard()
        
        let userMessage = message(source: .user, text: texto)
        listSystemMessages.append(userMessage)
        
        textInput = ""
        loading = true
        
        // Decide qual modelo usar
        if modeloAtual == .appleIntelligence {
            if #available(iOS 26.0, *) {
                sendMessageAppleIntelligence(userPrompt: texto)
            } else {
                // Fallback se por algum motivo modelo estava errado
                modeloAtual = .gemini
                sendMessageGemini(userPrompt: texto)
            }
        } else {
            sendMessageGemini(userPrompt: texto)
        }
    }
    
    // ✅ CORRIGIDO: Adiciona @available e verificação adicional
    @available(iOS 26.0, *)
    func sendMessageAppleIntelligence(userPrompt: String) {
        guard let session = appleIntelligenceSession as? LanguageModelSession else { return }
        
        Task {
            // ✅ FILTRAGEM APLICADA CORRETAMENTE
            let transacoesRelevantes = filtrarTransacoesRelevantes(para: userPrompt)
            
            // ✅ Passando as transações filtradas
            let contexto = prepararContextoFinanceiro(transacoes: transacoesRelevantes)
            
            let prompt = """
                        CONTEXTO DE DADOS ATUALIZADO:
                        \(contexto)
                        
                        PERGUNTA DO USUÁRIO:
                        \(userPrompt)
                        """
            
            do {
                let response = try await session.respond(to: prompt)
                await exibirResposta(response.content)
                
            } catch let error as LanguageModelSession.GenerationError {
                // ✅ CAPTURA O ERRO DE LIMITE
                if case .exceededContextWindowSize = error {
                    print("⚠️ Limite de tokens excedido. Reiniciando sessão...")
                    
                    // 1. Reseta a sessão (limpa o histórico da conversa)
                    configurarAppleIntelligence()
                    
                    // 2. Tenta novamente com uma nova sessão
                    if let novaSessao = appleIntelligenceSession as? LanguageModelSession {
                        do {
                            // Opcional: Reduz ainda mais o contexto na segunda tentativa
                            let contextoCurto = prepararContextoFinanceiro(transacoes: transacoesRelevantes)
                            let novoPrompt = "DADOS: \n\(contextoCurto)\n\nPERGUNTA: \(userPrompt)"
                            
                            let response = try await novaSessao.respond(to: novoPrompt)
                            await exibirResposta(response.content)
                        } catch {
                            await exibirErro("Erro após reiniciar sessão: \(error.localizedDescription)")
                        }
                    }
                } else {
                    await exibirErro("Erro na IA: \(error.localizedDescription)")
                }
            } catch {
                await exibirErro("Erro desconhecido: \(error.localizedDescription)")
            }
        }
    }
    
    // Helpers para limpar o código principal
    func exibirResposta(_ texto: String) async {
        let novaMsg = message(source: .ai, text: texto)
        await MainActor.run {
            listSystemMessages.append(novaMsg)
            loading = false
        }
    }
    
    func exibirErro(_ texto: String) async {
        let erroMsg = message(source: .ai, text: texto)
        await MainActor.run {
            listSystemMessages.append(erroMsg)
            loading = false
        }
    }
    
    
    // Função Gemini (mantém original)
    func sendMessageGemini(userPrompt: String) {
        aiResponse = message(source: .ai, text: "")
        
        Task {
            do {
                let transacoesRelevantes = filtrarTransacoesRelevantes(para: userPrompt)
                let contextoFinanceiro = prepararContextoFinanceiro(transacoes: transacoesRelevantes)
                
                // ✅ NOVO: Pega as últimas 4 mensagens para dar contexto de conversa
                // (Ignora a mensagem "Olá" inicial e a mensagem atual que ainda não foi adicionada)
                let historicoRecente = listSystemMessages.suffix(4).map { msg in
                    let papel = msg.source == .user ? "USUÁRIO" : "ASSISTENTE"
                    return "\(papel): \(msg.text)"
                }.joined(separator: "\n")
                
                let systemPrompt = """
                    Você é um assistente financeiro pessoal de alta precisão.
                    
                    ⛔️ REGRAS CRÍTICAS DE RESPOSTA (SIGA ESTRITAMENTE):
                    1. NÃO use Markdown (sem **, sem #, sem negrito, sem itálico). Use apenas texto puro.
                    2. NÃO use formatação de código ou blocos JSON.
                    3. Use APENAS estes emojis para listas: 🟢 (bom,positivo), 🔴 (ruim,negativo), 🔹 (itens), 🔸 (alertas), ✅ (ganhos), ❌ (gastos).
                    4. Ao calcular totais, some explicitamente os valores listados antes de responder.
                    
                    🧠 COMO INTERPRETAR OS DADOS:
                    - Transações marcadas como "GASTO" (valor negativo) subtraem do saldo.
                    - Transações marcadas como "GANHO" (valor positivo) somam ao saldo.
                    - "Recorrência: ATIVA" significa que essa cobrança acontecerá novamente na data "Próxima".
                    - "Recorrência: PAUSADA" significa que é uma conta fixa, mas o usuário parou temporariamente.
                    - "Categoria RECORRENTE" indica um compromisso fixo (ex: Aluguel, Assinaturas).
                                    - evite usar os valores predefinidos das categorias, use apenas os valores vindos de transacoes 
                    
                    🧮 INSTRUÇÕES DE CÁLCULO:
                    - Se perguntado "quanto gastei em X", some APENAS transações onde a Categoria ou Descrição contém X.
                    - Ignore transações futuras (datas após hoje) para cálculos de histórico passado.
                    - Para projeções futuras, use as datas "Próxima" das categorias e transações recorrentes ATIVAS.
                    
                    📢 TOM DE VOZ:
                    Seja direto e numérico. Evite enrolação.
                    Exemplo bom: "Você gastou R$ 500,00 em Alimentação."
                    Exemplo ruim: "Olhando seus dados, parece que houve um gasto aproximado de..."
                    
                    🧠 DADOS PARA ANÁLISE:
                    \(contextoFinanceiro)
                                        
                    💬 HISTÓRICO DA CONVERSA (Contexto):
                    \(historicoRecente)
                    
                    ❓ NOVA PERGUNTA DO USUÁRIO:
                    \(userPrompt)
                    """
                
                let response = try await modelGemini.generateContent(systemPrompt)
                
                if let text = response.text {
                    let novaMensagemIA = message(source: .ai, text: text)
                    
                    await MainActor.run {
                        listSystemMessages.append(novaMensagemIA)
                        loading = false
                    }
                } else {
                    await MainActor.run {
                        loading = false
                    }
                }
                
            } catch {
                aiResponse = message(source: .ai, text: "Ocorreu um erro: \(error)")
                await MainActor.run {
                    listSystemMessages.append(aiResponse)
                    loading = false
                }
            }
        }
    }
    
    // Função auxiliar para preparar contexto financeiro (reutilizável)
    func prepararContextoFinanceiro(transacoes: [TransactionModel]) -> String {
        let saldoTotal = viewModel.ganhos + viewModel.gastos
        
        let formatador = NumberFormatter()
        formatador.numberStyle = .currency
        formatador.currencyCode = "BRL"
        formatador.locale = Locale(identifier: "pt_BR")
        
        let saldoString = formatador.string(from: saldoTotal as NSDecimalNumber) ?? "R$ 0,00"
        
        // Formata Categorias
        let categoriasString = viewModel.categories.map { cat in
            var linha = "- ID: \(cat.name) | Tipo: \(cat.isRecorrente ? "RECORRENTE" : "NORMAL")"
            
            if cat.isRecorrente {
                linha += " | Frequência: \(cat.tipoRecorrencia.rawValue)"
                linha += " | Intervalo: a cada \(cat.intervaloRecorrencia)"
                if let valor = cat.valorPadrao {
                    let v = formatador.string(from: valor as NSDecimalNumber) ?? "\(valor)"
                    linha += " | Valor Padrão: \(v)"
                }
                if let proxima = cat.proximaOcorrencia {
                    linha += " | Próxima Cobrança: \(proxima.formatted(date: .numeric, time: .omitted))"
                }
            }
            return linha
        }.joined(separator: "\n")
        
        // ✅ CORREÇÃO AQUI: Retornar a linha completa, não a versão resumida
        let transacoesString = transacoes.map { t in
            let valorStr = formatador.string(from: t.valor as NSDecimalNumber) ?? "\(t.valor)"
            let dataStr = t.data.formatted(date: .numeric, time: .omitted)
            let catStr = t.category?.name ?? "Sem Categoria"
            let tipoValor = t.valor < 0 ? "GASTO" : "GANHO"
            
            var linha = "- \(dataStr) | \(tipoValor) | \(valorStr) | Descrição: \(t.descricao) | Categoria: \(catStr)"
            
            if t.isRecorrente {
                let status = t.recorrenciaAtiva ? "ATIVA" : "PAUSADA"
                linha += " | Recorrência: \(status)"
                if t.recorrenciaAtiva, let proxima = t.proximaOcorrencia {
                    linha += " | Próxima: \(proxima.formatted(date: .numeric, time: .omitted))"
                }
            } else {
                linha += " | Recorrência: NÃO"
            }
            
            return linha // ✅ Agora retorna a linha completa
        }.joined(separator: "\n")
        
        return """
        ====== DADOS FINANCEIROS ESTRUTURADOS ======
        
        [RESUMO GERAL]
        Saldo Atual Calculado: \(saldoString)
        Data de Hoje: \(Date().formatted(date: .numeric, time: .omitted))
        
        [LISTA DE CATEGORIAS]
        (Use isso para identificar quais gastos são fixos/recorrentes)
        \(categoriasString)
        
        [HISTÓRICO DE TRANSAÇÕES SELECIONADAS (\(transacoes.count))]
        (Ordenado do mais recente para o mais antigo. Valores negativos são gastos, positivos são ganhos)
        \(transacoesString)
        ===========================================
        """
    }
    
    
    // Função para filtrar transações baseadas no que o usuário perguntou
    func filtrarTransacoesRelevantes(para pergunta: String) -> [TransactionModel] {
        let perguntaLower = pergunta.lowercased()
        
        // Se a pergunta for genérica, retorna as mais recentes (padrão)
        let palavrasGenericas = ["geral", "resumo", "tudo", "gastos", "ganhos", "balanço", "saldo"]
        if palavrasGenericas.contains(where: { perguntaLower.contains($0) }) {
            // Retorna as 30 últimas se for genérico
            return Array(viewModel.transactions.prefix(30))
        }
        
        // Tenta encontrar transações que combinem com palavras da pergunta
        let transacoesFiltradas = viewModel.transactions.filter { t in
            let descricaoMatch = perguntaLower.contains(t.descricao.lowercased())
            let categoriaMatch = perguntaLower.contains((t.category?.name ?? "").lowercased())
            return descricaoMatch || categoriaMatch
        }
        
        // Se encontrou algo específico, retorna. Se não, volta para o padrão (últimas 30)
        return transacoesFiltradas.isEmpty ? Array(viewModel.transactions.prefix(30)) : transacoesFiltradas
    }
    
}

// MARK: - Preview
#Preview {
    IADasFinancas()
        .modelContainer(PreviewHelper.container)
}

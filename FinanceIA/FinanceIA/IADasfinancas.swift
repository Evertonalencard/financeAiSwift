import SwiftUI
import SwiftData
import GoogleGenerativeAI

enum source: String {
    case user, ai
}

struct message: Identifiable {
    var id: UUID = UUID()
    var source: source
    var text: String
}

struct IADasFinancas: View {
    
    // MARK: - Propriedades
    
    @FocusState var focusIA: Bool
    @StateObject private var viewModel = ViewModel()
    
    let model = GenerativeModel(name: "gemma-3-27b-it", apiKey: APIKey.default)
    
    @State var textInput: String = ""
    @State var aiResponse: message = message(source: .ai, text: "Olá! Como posso te ajudar com suas finanças hoje?")
    @State var loading: Bool = false
    @State var listSystemMessages: [message] = []
    
    @Environment(\.modelContext) var modelContext
    
    // ✅ Lista de Perguntas Padrão (Sugestões)
    let perguntasSugestivas = [
        "Qual categoria teve a maior quantidade de gastos e qual gastou mais? ",
        "Quanto gastei em Alimentação?",
        "Faça um resumo dos meus gastos",
        "Me dê uma dica de economia",
        "Quais foram minhas 5 compras mais altas recentemente?",
        "Existe alguma categoria cujo gasto esteja aumentando?",
        "Você identifica algum padrão de despesas recorrentes que poderia ser otimizado?",
        "Há algum gasto incomum ou fora do padrão recentemente?",
        "Como meus gastos de hoje se comparam à média dos últimos dias?",
        "Quais categorias têm maior variação mês a mês?",
        "Com base em todo histórico de transações, qual seria uma projeção do meu saldo e transações para o próximo mês?"
    ]
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            if #available(iOS 26.0, *){
                // Novo Fundo Gradiente
                LinearGradient(
                    colors: [Color.corDeFundo, Color.corDeFundo2],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Círculos de luz
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
                // Novo Fundo Gradiente (Versão Atual)
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
                Text("Chat")
                    .font(.title)
                    .bold()
                    .foregroundStyle(Color.corTextosBotoes)
                
                // MARK: - Área de Mensagens
                ScrollView {
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
                .safeAreaPadding(.horizontal, 15)
                
                Spacer()
                
                // MARK: - Sugestões de Perguntas (NOVO) ✨
                // Aparece apenas se não estiver carregando
                if !loading {
                    ScrollView(.horizontal, showsIndicators: false) {
                        if #available(iOS 26.0,*){
                            GlassEffectContainer(spacing: 50){
                                HStack(spacing: 30) {
                                    ForEach(perguntasSugestivas, id: \.self) { sugestao in
                                        Button {
                                            // Ação ao clicar na sugestão
                                            enviarMensagem(texto: sugestao)
                                        } label: {
                                            Text(sugestao)
                                                .lineLimit(2)
                                                .multilineTextAlignment(.leading)
                                                .frame(maxWidth: 500, alignment: .leading)
                                                .fixedSize(horizontal: true, vertical: true)
                                                .font(.system(size: 18)) // Tamanho um pouco menor para caber bem
                                                .foregroundStyle(Color.corTextosBotoes)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 10)
                                                .glassedEffect(in: Capsule(), interactive: true) // Retângulo Liquid Glass
                                                .contentShape(Rectangle())
                                            
                                        }
                                    }
                                }
                                .padding(.vertical,5)// ver se ios 18 funciona
                            }
                            .padding(.horizontal,20)// Padding externo do scroll
                        }else{
                            HStack(spacing: 12) {
                                ForEach(perguntasSugestivas, id: \.self) { sugestao in
                                    Button {
                                        // Ação ao clicar na sugestão
                                        enviarMensagem(texto: sugestao)
                                    } label: {
                                        Text(sugestao)
                                            .lineLimit(2)
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: 500, alignment: .leading)
                                            .fixedSize(horizontal: true, vertical: true)
                                            .font(.system(size: 18)) // Tamanho um pouco menor para caber bem
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
                    .padding(.bottom, 5) // Espaço entre as sugestões e o input
                }
                
                // MARK: - Barra de Input
                HStack(alignment: .bottom) {
                    ZStack {
                        if #available(iOS 26.0,*){
                            
                            
                            HStack {
                                TextField("", text: $textInput, prompt: Text("Diga algo...").foregroundColor(.corTextosBotoes).font(.system(size: 25)),axis: .vertical)
                                    .lineLimit(1...3) // Cresce de 1 até 5 linhas
                                    .foregroundColor(.corTextosBotoes)
                                    .font(.system(size: 25))
                                    .focused($focusIA)
                                    .safeAreaPadding(.horizontal, 10)
                                    .padding(10)
                                    .glassedEffect(in: .capsule, interactive: true)
                            }
                        } else {
                            // Fallback visual
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
                    // Removemos frame height fixo para crescer
                    
                    if #available(iOS 26.0, *){
                        Button {
                            enviarMensagem(texto: textInput)
                        } label: {
                            Image(systemName: "paperplane.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .contentShape(Rectangle())
                        }
                        .padding(12) // Aumentei um pouco o padding do botão
                        .glassedEffect(in: .circle, interactive: true) // Mudei para Circle fica mais bonito no botão redondo
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
                        .cornerRadius(100) // Redondo
                    }
                }
            }
            .padding(.horizontal, 20)
            .safeAreaPadding(.vertical, 20)
        }
        .onAppear {
            viewModel.setContext(modelContext)
            
            if listSystemMessages.isEmpty {
                listSystemMessages.append(aiResponse)
            }
        }
        .onTapGesture {
            focusIA = false
            hideKeyboard()
        }
    }
    
    
    // MARK: - Funções (Lógica)
    
    // ✅ Função auxiliar para evitar repetição de código no botão e nas sugestões
    func enviarMensagem(texto: String) {
        guard !texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        focusIA = false
        hideKeyboard()
        
        let userMessage = message(source: .user, text: texto)
        listSystemMessages.append(userMessage)
        
        textInput = "" // Limpa o campo se foi digitado
        loading = true
        
        sendMessage(userPrompt: texto)
    }
    
    func sendMessage(userPrompt: String) {
        aiResponse = message(source: .ai, text: "")
        
        Task {
            do {
                // 1. Calcular Saldo
                let saldoTotal = viewModel.ganhos + viewModel.gastos
                
                // 2. Configurar Formatador para String (A IA precisa de texto)
                let formatador = NumberFormatter()
                formatador.numberStyle = .currency
                formatador.currencyCode = "BRL"
                
                // 3. Preparar Strings para o Prompt
                // Convertemos o Decimal para NSDecimalNumber para o formatador aceitar
                let saldoString = formatador.string(from: saldoTotal as NSDecimalNumber) ?? "R$ 0,00"
                
                // Variável definida AQUI para estar no escopo
                // Formata categorias com informações de recorrência
                let categoriasString = viewModel.categories.map { cat in
                    var info = "• \(cat.name)"
                    
                    if cat.isRecorrente {
                        info += " [RECORRENTE: \(cat.tipoRecorrencia.rawValue)"
                        
                        if cat.intervaloRecorrencia > 1 {
                            info += " - a cada \(cat.intervaloRecorrencia)"
                        }
                        
                        if let valor = cat.valorPadrao {
                            let valorStr = formatador.string(from: valor as NSDecimalNumber) ?? "\(valor)"
                            info += ", Valor padrão: \(valorStr)"
                        }
                        
                        if let proxima = cat.proximaOcorrencia {
                            info += ", Próxima: \(proxima.formatted(date: .numeric, time: .omitted))"
                        }
                        
                        info += "]"
                    }
                    
                    return info
                }.joined(separator: "\n")
                
                // Formata transações com status de recorrência
                let transacoesString = viewModel.transactions.map { t in
                    let valorStr = formatador.string(from: t.valor as NSDecimalNumber) ?? "\(t.valor)"
                    let dataStr = t.data.formatted(date: .numeric, time: .omitted)
                    let catStr = t.category?.name ?? "Sem categoria"
                    
                    var linha = "• \(t.descricao): \(valorStr) em \(dataStr) [\(catStr)]"
                    
                    // Adiciona informação de recorrência
                    if t.isRecorrente {
                        if t.recorrenciaAtiva {
                            linha += " 🔄 RECORRENTE ATIVA"
                            if let proxima = t.proximaOcorrencia {
                                linha += " (Próxima: \(proxima.formatted(date: .numeric, time: .omitted)))"
                            }
                        } else {
                            linha += " ⏸️ RECORRENTE PAUSADA"
                        }
                    }
                    
                    return linha
                }.joined(separator: "\n")
                
                // ✅ NOVO: Calcula resumo de recorrências
                let recorrentesAtivas = viewModel.transactions.filter { $0.isRecorrente && $0.recorrenciaAtiva }.count
                let recorrentesPausadas = viewModel.transactions.filter { $0.isRecorrente && !$0.recorrenciaAtiva }.count
                let categoriasRecorrentes = viewModel.categories.filter { $0.isRecorrente }.count
                
                let systemPrompt = """
                                Você é um assistente financeiro pessoal inteligente com conhecimento sobre gestão de finanças
                               ═══════════════════════════════════════
                               INSTRUÇÕES DE RESPOSTA
                               ═══════════════════════════════════════
                                • Responda APENAS com texto simples (sem markdown, sem JSON, sem formatação especial)
                                • Seja direto, objetivo e amigável
                                • Use emojis para facilitar a leitura (💰 📊 📉 📈 ⚠️ ✅)
                                • Forneça insights práticos e acionáveis
                                • Considere transações recorrentes ao fazer análises futuras
                                • Gastos são: qualquer tipo de compra.
                                • Ganhos são: renda extra, Salários, renda proveniente de ivestimento, entre muitos outros.
                                • Se o saldo for negativo avise ao usuario, e de dicas de como ele pode melhorar essa situação,baseado no historico das transações.
                               ═══════════════════════════════════════
                               💡 CONTEXTO DO SISTEMA
                               ═══════════════════════════════════════
                               O usuário utiliza um sistema com:
                               • CATEGORIAS RECORRENTES: Criam transações automaticamente (ex: Salário mensal, Aluguel)
                               • TRANSAÇÕES RECORRENTES: Podem ser pausadas individualmente sem afetar a categoria
                               • Status possíveis: 🔄 Ativa (cria automaticamente) ou ⏸️ Pausada (não cria mais)
                                ═══════════════════════════════════════
                                DADOS FINANCEIROS ATUAIS
                                ═══════════════════════════════════════
                                
                                 SALDO TOTAL: \(saldoString)

                                 CATEGORIAS (\(viewModel.categories.count) no total, \(categoriasRecorrentes) recorrentes):
                                \(categoriasString)

                                 TRANSAÇÕES (\(viewModel.transactions.count) no total):
                                \(transacoesString)

                                RESUMO DE RECORRÊNCIAS:
                                • Transações recorrentes ativas: \(recorrentesAtivas)
                                • Transações recorrentes pausadas: \(recorrentesPausadas)
                                • Categorias com recorrência: \(categoriasRecorrentes)
                               
                               ═══════════════════════════════════════
                                DICAS DE ANÁLISE
                               ═══════════════════════════════════════
                               
                               Ao responder:
                               ✓ Considere gastos/ganhos recorrentes para projeções futuras
                               ✓ Alerte se há muitas recorrências pausadas (podem indicar problemas)
                               ✓ Sugira pausar recorrências se o saldo está negativo
                               ✓ Identifique padrões de gastos que poderiam ser recorrentes
                               ✓ Se o saldo é negativo, dê dicas baseadas no histórico real
                                
                               ═══════════════════════════════════════
                                HISTÓRICO DA CONVERSA
                               ═══════════════════════════════════════
                               \(listSystemMessages.map { "\($0.source == .user ? " Usuário" : " Assistente"): \($0.text)" }.joined(separator: "\n"))
                                
                                ═══════════════════════════════════════
                                 PERGUNTA ATUAL
                                ═══════════════════════════════════════
                                \(userPrompt)
                               """
                
                let response = try await model.generateContent(systemPrompt)
                
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
}

// MARK: - Preview
#Preview {
    IADasFinancas()
        .modelContainer(PreviewHelper.container)
}




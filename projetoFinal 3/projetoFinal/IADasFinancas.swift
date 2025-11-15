import SwiftUI
import GoogleGenerativeAI

enum source:String {
    case user, ai
}

struct message: Identifiable {
    var id: UUID = UUID()
    var source: source
    var text: String
}

struct IADasFinancas: View {
    
    // MARK: - Propriedades
    
    @StateObject private var viewModel = ViewModel() // 1. Instância do ViewModel
    
    let model = GenerativeModel(name: "gemini-2.5-flash", apiKey: APIKey.default)
    
    @State var textInput: String = "" // 2. String simples para o TextField
    @State var aiResponse: message = message(source: .ai, text: "Olá! Como posso te ajudar com suas finanças hoje?")
    @State var loading: Bool = false
    @State var listSystemMessages: [message] = []
    
    
    // MARK: - Body (A View)
    
    var body: some View {
        ZStack {
            Color.corDeFundo
                .ignoresSafeArea(edges: .all)
            VStack {
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
                                            .offset(x: 10, y: 6)
                                            .foregroundColor(.corCaixaDeTexto)
                                    }
                                
                            }
                        }
                        else {
                            HStack {
                                Text(msg.text)
                                    .padding(10)
                                    .background(.corCaixaDeTexto)
                                    .foregroundColor(.corTextosBotoes)
                                    .font(.system(size: 25))
                                    .cornerRadius(10)
                                    .safeAreaPadding(.vertical, 5)
                                    .overlay(alignment: .bottomLeading) {
                                        Image(systemName: "arrowtriangle.down.fill")
                                            .font(.title)
                                            .rotationEffect(.degrees(45))
                                            .offset(x: -10, y: 6)
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
                ZStack {
                    Color.corCaixaDeTexto
                    HStack {
                        // Ligado diretamente à @State var textInput: String
                        
                            
                        
                            TextField("", text: $textInput, prompt: Text("Diga algo...").foregroundColor(.corTextosBotoes).font(.system(size: 25)),axis: .vertical)
                                .foregroundColor(.corTextosBotoes)
                                .font(.system(size: 25))
                        
                        
                        
                        Button {
                            // Lógica do botão atualizada
                            let userMessage = message(source: .user, text: textInput)
                            listSystemMessages.append(userMessage)
                            
                            let promptText = textInput // Salva o texto
                            textInput = "" // Limpa o campo
                            
                            loading = true
                            sendMessage(userPrompt: promptText) // Passa o texto para a função
                            
                            print()
                            
                        } label: {
                            Image(systemName: "paperplane.fill")
                                .resizable()
                                .frame(width: 30,height: 30)
                        }
                        .foregroundColor(.corTextosBotoes)
                        
                    }
                }
                .padding(10)
                .background(Color.corCaixaDeTexto)
                .frame(width: 300, height: 50)
                .cornerRadius(10)
                .safeAreaPadding(.bottom, 20)
                
            }
            .safeAreaPadding(.vertical, 20)
            .onAppear {
                // 4. Carregue os dados quando a view aparecer
                viewModel.fetch()
                viewModel.fetchCategory()
                
                // Adiciona a saudação inicial à lista de mensagens
                if listSystemMessages.isEmpty {
                    listSystemMessages.append(aiResponse)
                }
            }
        }
    }
    
    // MARK: - Funções (Lógica)
    
    
    func sendMessage(userPrompt: String) { // Recebe a pergunta do usuário
        aiResponse = message(source: .ai, text: "")
        
        Task {
            do {
                
                let transactions = viewModel.transactions
                let categories = viewModel.categories
                
                
                let encoder = JSONEncoder()
                
                

                
                //ANDRÉ
                var jsonCategories: [Category] = []
                for i in viewModel.categories {
                    jsonCategories.append(i)
                }
                var jsonTransasao: [Transaction] = []
                for i in viewModel.transactions {
                    jsonTransasao.append(i)
                }
                var jsonSaldo: [Double] = []
                for i in viewModel.transactions{
                    jsonSaldo.append(i.valor)
                }
                
                
                let formattedHistory = listSystemMessages.map { msg in
                    "\(msg.source.rawValue): \(msg.text)"
                }.joined(separator: "\n")
                
                
                
                let systemPrompt = """
                Você é um assistente financeiro pessoal e educado.
                Sua tarefa é responder às perguntas do usuário com base *exclusivamente* nos dados financeiros fornecidos e no histórico da conversa.
                Seja objetivo e baseie-se nos fatos (os dados). Não invente informações.

                --- DADOS FINANCEIROS ATUAIS ---
                
                "Categorias Disponíveis" ou "Categorias de Gastos" ou "Categorias de ganho":
                \(jsonCategories)
                
                Transações do Usuário:
                \(jsonTransasao)
                
                Saldo atual(some os valore deste array, para obter o saldo):
                \(jsonSaldo)
                

                --- FIM DOS DADOS ---

                --- HISTÓRICO DA CONVERSA ---
                \(formattedHistory)
                
                --- FIM DO HISTÓRICO ---

                --- PERGUNTA ATUAL DO USUÁRIO ---
                user: \(userPrompt)
                ai:
                """
                
                
                let response = try await model.generateContent(systemPrompt)
                
                guard let text = response.text else {
                    let errorResponse = message(source: .ai, text: "Desculpe, não consegui processar essa informação.")
                    listSystemMessages.append(errorResponse)
                    loading = false
                    return
                }
                
                
                aiResponse = message(source: .ai, text: text)
                listSystemMessages.append(aiResponse)
                loading = false
                print(jsonCategories)
                print(jsonTransasao)
                print(jsonSaldo)
                
            } catch {
                aiResponse = message(source: .ai, text: "Ocorreu um erro: \(error)")
                listSystemMessages.append(aiResponse)
                loading = false
            }
        }
    }
}

// MARK: - Preview

#Preview {
    IADasFinancas()
}

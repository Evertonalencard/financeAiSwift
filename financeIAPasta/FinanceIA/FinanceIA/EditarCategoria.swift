import SwiftUI
import SwiftData

struct EditarCategoria: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    let categoria: CategoryModel
    
    @State private var nomeCategoria: String
    @State private var isRecorrente: Bool
    @State private var tipoRecorrencia: TipoRecorrencia
    @State private var intervalo: Int
    @State private var valorPadrao: String
    @State private var ehNegativo: Bool = false // ✅ Controla sinal
    @State private var mostrarErro: Bool = false
    @FocusState private var campoValorFocado: Bool // ✅ Foco do campo
    
    init(categoria: CategoryModel) {
        self.categoria = categoria
        _nomeCategoria = State(initialValue: categoria.name)
        _isRecorrente = State(initialValue: categoria.isRecorrente)
        _tipoRecorrencia = State(initialValue: categoria.tipoRecorrencia)
        _intervalo = State(initialValue: categoria.intervaloRecorrencia)
        
        // Converte Decimal para String e define sinal
        if let valor = categoria.valorPadrao {
            _ehNegativo = State(initialValue: valor < 0)
            _valorPadrao = State(initialValue: String(describing: abs(valor)))
        } else {
            _valorPadrao = State(initialValue: "")
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Nome da Categoria
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nome da Categoria")
                                .foregroundStyle(Color.corTextosBotoes)
                                .font(.headline)
                            
                            if #available(iOS 26.0, *) {
                                TextField("", text: $nomeCategoria, prompt: Text("Ex: Aluguel").foregroundColor(.corTextosBotoes))
                                    .foregroundColor(.corTextosBotoes)
                                    .padding()
                                    .glassedEffect(in: .capsule, interactive: true)
                            } else {
                                TextField("", text: $nomeCategoria, prompt: Text("Ex: Aluguel").foregroundColor(.corTextosBotoes))
                                    .padding()
                                    .background(Color.corCaixaDeTexto)
                                    .cornerRadius(10)
                                    .foregroundStyle(Color.corTextosBotoes)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Toggle de Recorrência
                        VStack(alignment: .leading, spacing: 8) {
                            if #available(iOS 26.0, *) {
                                Toggle(isOn: $isRecorrente) {
                                    HStack {
                                        Image(systemName: "repeat")
                                            .foregroundStyle(Color.corTextosBotoes)
                                        Text("Categoria Recorrente")
                                            .foregroundStyle(Color.corTextosBotoes)
                                            .font(.headline)
                                    }
                                }
                                .tint(.corUIitens)
                                .padding()
                                .background(Color.corCaixaDeTexto.opacity(0.5))
                                .cornerRadius(100)
                                .glassedEffect(in: .capsule, interactive: true)
                            } else {
                                Toggle(isOn: $isRecorrente) {
                                    HStack {
                                        Image(systemName: "repeat")
                                            .foregroundStyle(Color.corTextosBotoes)
                                        Text("Categoria Recorrente")
                                            .foregroundStyle(Color.corTextosBotoes)
                                            .font(.headline)
                                    }
                                }
                                .tint(.corUIitens)
                                .padding()
                                .background(Color.corCaixaDeTexto.opacity(0.5))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Opções de Recorrência
                        if isRecorrente {
                            VStack(spacing: 15) {
                                // Tipo de Recorrência
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Frequência")
                                        .foregroundStyle(Color.corTextosBotoes)
                                        .font(.headline)
                                    
                                    Picker("Tipo", selection: $tipoRecorrencia) {
                                        ForEach(TipoRecorrencia.allCases.filter { $0 != .nenhuma }, id: \.self) { tipo in
                                            Text(tipo.rawValue).tag(tipo)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                    .glassedEffect(in: .capsule, interactive: false)
                                }
                                .padding(.horizontal)
                                
                                // Intervalo
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(textoIntervalo())
                                        .foregroundStyle(Color.corTextosBotoes)
                                        .font(.headline)
                                    
                                    if #available(iOS 26.0, *) {
                                        HStack {
                                            Button(action: { if intervalo > 1 { intervalo -= 1 } }) {
                                                Image(systemName: "minus.circle.fill")
                                                    .font(.title2)
                                                    .foregroundStyle(intervalo > 1 ? Color.corVermelhoApagar : Color.gray)
                                            }
                                            .disabled(intervalo <= 1)
                                            
                                            Spacer()
                                            Text("\(intervalo)")
                                                .font(.title)
                                                .bold()
                                                .foregroundStyle(Color.corTextosBotoes)
                                                .frame(minWidth: 50)
                                            Spacer()
                                            
                                            Button(action: { if intervalo < 99 { intervalo += 1 } }) {
                                                Image(systemName: "plus.circle.fill")
                                                    .font(.title2)
                                                    .foregroundStyle(Color.corUIitens)
                                            }
                                        }
                                        .padding()
                                        .background(Color.corCaixaDeTexto.opacity(0.5))
                                        .cornerRadius(100)
                                        .glassedEffect(in: .capsule, interactive: false)
                                    } else {
                                        HStack {
                                            Button(action: { if intervalo > 1 { intervalo -= 1 } }) {
                                                Image(systemName: "minus.circle.fill")
                                                    .font(.title2)
                                                    .foregroundStyle(intervalo > 1 ? Color.corVermelhoApagar : Color.gray)
                                            }
                                            .disabled(intervalo <= 1)
                                            
                                            Spacer()
                                            Text("\(intervalo)")
                                                .font(.title)
                                                .bold()
                                                .foregroundStyle(Color.corTextosBotoes)
                                                .frame(minWidth: 50)
                                            Spacer()
                                            
                                            Button(action: { if intervalo < 99 { intervalo += 1 } }) {
                                                Image(systemName: "plus.circle.fill")
                                                    .font(.title2)
                                                    .foregroundStyle(Color.corUIitens)
                                            }
                                        }
                                        .padding()
                                        .background(Color.corCaixaDeTexto)
                                        .cornerRadius(10)
                                    }
                                }
                                .padding(.horizontal)
                                
                                // ✅ Valor Padrão com botão ±
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Valor Padrão (opcional)")
                                            .foregroundStyle(Color.corTextosBotoes)
                                            .font(.headline)
                                        Spacer()
                                        Text(ehNegativo ? "Negativo" : "Positivo")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundStyle(ehNegativo ? Color.corVermelhoApagar : Color.corUIitens)
                                    }
                                    
                                    if #available(iOS 26.0, *) {
                                        HStack {
                                            Text(ehNegativo ? "-" : "+")
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundColor(ehNegativo ? .corVermelhoApagar : .corUIitens)
                                                .frame(width: 30)
                                            
                                            TextField("0.00", text: $valorPadrao)
                                                .keyboardType(.decimalPad)
                                                .foregroundColor(.corTextosBotoes)
                                                .focused($campoValorFocado)
                                        }
                                        .padding()
                                        .glassedEffect(in: .capsule, interactive: true)
                                    } else {
                                        HStack {
                                            Text(ehNegativo ? "-" : "+")
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundColor(ehNegativo ? .corVermelhoApagar : .corUIitens)
                                                .frame(width: 30)
                                            
                                            TextField("0.00", text: $valorPadrao)
                                                .keyboardType(.decimalPad)
                                                .foregroundStyle(.corTextosBotoes)
                                                .focused($campoValorFocado)
                                        }
                                        .padding()
                                        .background(Color.corCaixaDeTexto)
                                        .cornerRadius(10)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                        
                        // Botão Salvar
                        Button(action: salvarEdicao) {
                            Text("Salvar Alterações")
                                .font(.headline)
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(nomeCategoria.isEmpty ? Color.gray : Color.verdeClarinho)
                                .cornerRadius(10)
                        }
                        .disabled(nomeCategoria.isEmpty)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Editar Categoria")
            .navigationBarTitleDisplayMode(.inline)
            // ✅ Toolbar com botão ±
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button(action: {
                        ehNegativo.toggle()
                    }) {
                        Image(systemName: ehNegativo ? "minus.circle.fill" : "plus.circle.fill")
                            .foregroundStyle(ehNegativo ? Color.corVermelhoApagar : Color.corUIitens)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                }
            }
            .alert("Erro", isPresented: $mostrarErro) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Não foi possível salvar as alterações")
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
    
    func textoIntervalo() -> String {
        switch tipoRecorrencia {
        case .diaria: return "Repetir a cada \(intervalo) dias"
        case .semanal: return "Repetir a cada \(intervalo) semanas"
        case .mensal: return "Repetir a cada \(intervalo) meses"
        case .anual: return "Repetir a cada \(intervalo) anos"
        case .personalizada: return "Repetir a cada \(intervalo) dias"
        case .nenhuma: return ""
        }
    }
    
    func salvarEdicao() {
        guard !nomeCategoria.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        categoria.name = nomeCategoria
        categoria.isRecorrente = isRecorrente
        categoria.tipoRecorrencia = isRecorrente ? tipoRecorrencia : .nenhuma
        categoria.intervaloRecorrencia = intervalo
        
        // ✅ Atualiza valor padrão com sinal correto
        if !valorPadrao.isEmpty {
            let valorFormatado = valorPadrao.replacingOccurrences(of: ",", with: ".")
            if let valorDecimal = Decimal(string: valorFormatado) {
                categoria.valorPadrao = ehNegativo ? abs(valorDecimal) * -1 : abs(valorDecimal)
            }
        } else {
            categoria.valorPadrao = nil
        }
        
        if isRecorrente && tipoRecorrencia != .nenhuma {
            categoria.proximaOcorrencia = CategoryModel.calcularProximaOcorrencia(
                from: Date(),
                tipo: tipoRecorrencia,
                intervalo: intervalo
            )
        } else {
            categoria.proximaOcorrencia = nil
        }
        
        do {
            try modelContext.save()
            print("✅ Categoria '\(categoria.name)' atualizada")
            dismiss()
        } catch {
            print("❌ Erro ao salvar categoria: \(error)")
            mostrarErro = true
        }
    }
}

#Preview {
    let categoria = CategoryModel(name: "Aluguel")
    categoria.isRecorrente = true
    categoria.tipoRecorrencia = .mensal
    categoria.intervaloRecorrencia = 1
    categoria.valorPadrao = -1200.00
    categoria.proximaOcorrencia = CategoryModel.calcularProximaOcorrencia(
        from: Date(),
        tipo: .mensal,
        intervalo: 1
    )
    
    return EditarCategoria(categoria: categoria)
        .modelContainer(PreviewHelper.container)
}

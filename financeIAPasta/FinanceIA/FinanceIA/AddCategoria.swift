//
//  AddCategoria.swift
//  FinanceIA
//
//  Created by Éverton Alencar de Lima on 01/01/26.
//

import SwiftUI
import SwiftData

struct AdicionarCategoria: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @State private var nomeCategoria: String = ""
    @State private var isRecorrente: Bool = false
    @State private var tipoRecorrencia: TipoRecorrencia = .mensal
    @State private var intervalo: Int = 1
    @State private var valorPadrao: String = ""
    @State private var ehNegativo: Bool = false // ✅ Controla sinal
    @State private var mostrarErro: Bool = false
    @FocusState private var campoValorFocado: Bool // ✅ Foco do campo
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Nome da Categoria
                        campoNome
                        
                        // Toggle de Recorrência
                        toggleRecorrencia
                        
                        // Opções de Recorrência
                        if isRecorrente {
                            opcoesRecorrencia
                        }
                        
                        // Botão Salvar
                        botaoSalvar
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Nova Categoria")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundStyle(Color.corPretoBranco)
                }
                
                // ✅ Toolbar com botão ± (só aparece quando o campo está focado)
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
                Text("Não foi possível salvar a categoria")
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
    
    // MARK: - Componentes da View
    
    var campoNome: some View {
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
    }
    
    var toggleRecorrencia: some View {
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
    }
    
    var opcoesRecorrencia: some View {
        VStack(spacing: 15) {
            // Tipo de Recorrência
            VStack(alignment: .leading, spacing: 8) {
                Text("Frequência")
                    .foregroundStyle(Color.corTextosBotoes)
                    .font(.headline)
                
                Picker("Tipo", selection: $tipoRecorrencia) {
                    Text("Diária").tag(TipoRecorrencia.diaria)
                    Text("Semanal").tag(TipoRecorrencia.semanal)
                    Text("Mensal").tag(TipoRecorrencia.mensal)
                    Text("Anual").tag(TipoRecorrencia.anual)
                    Text("Personalizada").tag(TipoRecorrencia.personalizada)
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)
            
            // Intervalo
            intervaloSelector
            
            // Valor Padrão
            campoValorPadrao
            
            // Exemplo
            exemploVisual
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    var intervaloSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(textoIntervalo())
                .foregroundStyle(Color.corTextosBotoes)
                .font(.headline)
            
            if #available(iOS 26.0, *) {
                HStack {
                    Button(action: {
                        if intervalo > 1 { intervalo -= 1 }
                    }) {
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
                    
                    Button(action: {
                        if intervalo < 99 { intervalo += 1 }
                    }) {
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
                    Button(action: {
                        if intervalo > 1 { intervalo -= 1 }
                    }) {
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
                    
                    Button(action: {
                        if intervalo < 99 { intervalo += 1 }
                    }) {
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
    }
    
    // ✅ Campo Valor Padrão com botão ±
    var campoValorPadrao: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Valor Padrão (opcional)")
                    .foregroundStyle(Color.corTextosBotoes)
                    .font(.headline)
                Spacer()
                // ✅ Indicador visual do sinal
                Text(ehNegativo ? "Negativo" : "Positivo")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(ehNegativo ? Color.corVermelhoApagar : Color.corUIitens)
            }
            
            if #available(iOS 26.0, *) {
                HStack {
                    // ✅ Mostra o sinal visualmente
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
    
    var exemploVisual: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundStyle(Color.corUIitens)
                Text("Exemplo:")
                    .foregroundStyle(Color.corTextosBotoes)
                    .font(.subheadline)
            }
            
            Text(exemploTexto())
                .foregroundStyle(Color.corTextosBotoes.opacity(0.8))
                .font(.caption)
                .italic()
        }
        .padding()
        .background(Color.corCaixaDeTexto.opacity(0.3))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    var botaoSalvar: some View {
        Button(action: salvarCategoria) {
            Text("Salvar Categoria")
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
    
    // MARK: - Funções Auxiliares
    
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
    
    func exemploTexto() -> String {
        let unidade: String
        switch tipoRecorrencia {
        case .diaria: unidade = intervalo == 1 ? "dia" : "dias"
        case .semanal: unidade = intervalo == 1 ? "semana" : "semanas"
        case .mensal: unidade = intervalo == 1 ? "mês" : "meses"
        case .anual: unidade = intervalo == 1 ? "ano" : "anos"
        case .personalizada: unidade = intervalo == 1 ? "dia" : "dias"
        case .nenhuma: return ""
        }
        
        return "Esta categoria criará transações automaticamente a cada \(intervalo) \(unidade)"
    }
    
    func salvarCategoria() {
        guard !nomeCategoria.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        let novaCategoria = CategoryModel(name: nomeCategoria)
        novaCategoria.isRecorrente = isRecorrente
        novaCategoria.tipoRecorrencia = isRecorrente ? tipoRecorrencia : .nenhuma
        novaCategoria.intervaloRecorrencia = intervalo
        
        // ✅ Converte valor padrão com sinal correto
        if !valorPadrao.isEmpty {
            let valorFormatado = valorPadrao.replacingOccurrences(of: ",", with: ".")
            if let valorDecimal = Decimal(string: valorFormatado) {
                novaCategoria.valorPadrao = ehNegativo ? abs(valorDecimal) * -1 : abs(valorDecimal)
            }
        }
        
        if isRecorrente {
            novaCategoria.proximaOcorrencia = CategoryModel.calcularProximaOcorrencia(
                from: Date(),
                tipo: tipoRecorrencia,
                intervalo: intervalo
            )
        }
        
        modelContext.insert(novaCategoria)
        
        do {
            try modelContext.save()
            print("✅ Categoria '\(nomeCategoria)' criada")
            dismiss()
        } catch {
            print("❌ Erro ao salvar categoria: \(error)")
            mostrarErro = true
        }
    }
}

#Preview {
    AdicionarCategoria()
        .modelContainer(PreviewHelper.container)
}

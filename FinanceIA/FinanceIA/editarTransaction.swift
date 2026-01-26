import SwiftUI
import SwiftData

struct editTransaction: View {
    @Bindable var transaction: TransactionModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @State var categoriaSelecionada: CategoryModel?
    @State var titulo = ""
    @State var valor = ""
    @State private var ehNegativo = false // ✅ Controla se o valor é negativo
    @StateObject var viewModel = ViewModel()
    
    @State private var showAlert = false
    @State private var alertMessage: String = ""
    @FocusState private var campoValorFocado: Bool // ✅ Controla foco do campo
    
    var body: some View {
        ZStack{
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
                Spacer()
                
                if #available(iOS 26.0, *){
                    ZStack {
                        if (transaction.valor < 0) { Color.corVermelhoApagar.opacity(0.7) } else { Color.corCaixaDeTexto.opacity(0.7) }
                        
                        HStack {
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
                        }
                        .safeAreaPadding(.horizontal, 15)
                        .safeAreaPadding(.vertical, 15)
                    }
                    .cornerRadius(100)
                    .glassedEffect(in: .capsule, interactive: true)
                    .padding(2)
                    .safeAreaPadding(.horizontal, 20)
                    .padding(.vertical,50)
                    .frame(height: 100)
                } else {
                    ZStack {
                        if (transaction.valor < 0) { Color.corVermelhoApagar } else { Color.corCaixaDeTexto}
                        
                        HStack {
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
                        }
                        .safeAreaPadding(.horizontal, 15)
                        .safeAreaPadding(.vertical, 15)
                    }
                    .cornerRadius(10)
                    .padding(2)
                    .safeAreaPadding(.horizontal, 20)
                    .padding(.vertical,50)
                    .frame(height: 100)
                }
                
                Spacer()
                
                if #available(iOS 26.0, *) {
                    // TÍTULO
                    VStack (alignment: .leading) {
                        Text("Título").font(.title).foregroundStyle(Color.corTextosBotoes)
                        ZStack{
                            Rectangle()
                                .foregroundColor(.corCaixaDeTexto.opacity(0.1))
                                .frame(height: 50)
                                .cornerRadius(100)
                                .glassedEffect(in: .capsule, interactive: true)
                            
                            TextField("", text: $titulo)
                                .font(.system(size: 25))
                                .foregroundColor(.corTextosBotoes)
                                .padding()
                                .frame(height: 45)
                        }
                    }
                    .padding(8)
                    .padding(.horizontal,20)
                    
                    // VALOR
                    VStack (alignment: .leading) {
                        HStack {
                            Text("Valor").font(.title).foregroundStyle(Color.corTextosBotoes)
                            Spacer()
                            // ✅ Indicador visual do sinal
                            Text(ehNegativo ? "Negativo" : "Positivo")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(ehNegativo ? Color.corVermelhoApagar : Color.corUIitens)
                                
                        }
                        ZStack{
                            Rectangle()
                                .foregroundColor(.corCaixaDeTexto.opacity(0.1))
                                .frame(height: 50)
                                .cornerRadius(100)
                                .glassedEffect(in: .capsule, interactive: true)
                            
                            HStack {
                                // ✅ Mostra o sinal visualmente
                                Text(ehNegativo ? "-" : "+")
                                    .font(.system(size: 25, weight: .bold))
                                    .foregroundColor(ehNegativo ? .corVermelhoApagar : .corUIitens)
                                    .frame(width: 30)
                                
                                TextField("0.00", text: $valor)
                                    .font(.system(size: 25))
                                    .foregroundColor(.corTextosBotoes)
                                    .keyboardType(.decimalPad)
                                    .focused($campoValorFocado)
                            }
                            .padding(.horizontal)
                            .frame(height: 45)
                        }
                    }
                    .padding(8)
                    .padding(.horizontal,20)
                    
                    // CATEGORIA
                    VStack  (alignment: .leading){
                        Text("Categoria").font(.title).foregroundStyle(Color.corTextosBotoes)
                        ZStack{
                            Rectangle()
                                .foregroundColor(.corCaixaDeTexto.opacity(0.1))
                                .frame( height: 50)
                                .cornerRadius(100)
                                .glassedEffect(in: .capsule, interactive: true)
                            
                            Picker("Selecione a categoria", selection: $categoriaSelecionada){
                                Text("Selecione").tag(nil as CategoryModel?)
                                
                                ForEach(viewModel.categories) { categoria in
                                    Text(categoria.name).tag(categoria as CategoryModel?)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(height: 45)
                            .tint(.corTextosBotoes)
                        }
                    }
                    .padding(.horizontal,20)
                    .padding(8)
                } else {
                    // TÍTULO
                    VStack (alignment: .leading) {
                        Text("Título").font(.title).foregroundStyle(Color.corTextosBotoes)
                        ZStack{
                            Rectangle()
                                .foregroundColor(.corCaixaDeTexto)
                                .frame(height: 50)
                                .cornerRadius(10)
                            
                            TextField("", text: $titulo)
                                .font(.system(size: 25))
                                .foregroundColor(.corTextosBotoes)
                                .padding()
                                .frame(height: 45)
                        }
                    }
                    .padding(8)
                    .padding(.horizontal,20)
                    
                    // VALOR
                    VStack (alignment: .leading) {
                        HStack {
                            Text("Valor").font(.title).foregroundStyle(Color.corTextosBotoes)
                            Spacer()
                            Text(ehNegativo ? "Negativo" : "Positivo")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(ehNegativo ? Color.corVermelhoApagar : Color.corUIitens)
                        }
                        ZStack{
                            Rectangle()
                                .foregroundColor(.corCaixaDeTexto)
                                .frame(height: 50)
                                .cornerRadius(10)
                            
                            HStack {
                                Text(ehNegativo ? "-" : "+")
                                    .font(.system(size: 25, weight: .bold))
                                    .foregroundColor(ehNegativo ? .corVermelhoApagar : .corUIitens)
                                    .frame(width: 30)
                                
                                TextField("0.00", text: $valor)
                                    .font(.system(size: 25))
                                    .foregroundColor(.corTextosBotoes)
                                    .keyboardType(.decimalPad)
                                    .focused($campoValorFocado)
                            }
                            .padding(.horizontal)
                            .frame(height: 45)
                        }
                    }
                    .padding(8)
                    .padding(.horizontal,20)
                    
                    // CATEGORIA
                    VStack  (alignment: .leading){
                        Text("Categoria").font(.title).foregroundStyle(Color.corTextosBotoes)
                        ZStack{
                            Rectangle()
                                .foregroundColor(.corCaixaDeTexto)
                                .frame( height: 50)
                                .cornerRadius(10)
                            
                            Picker("Selecione a categoria", selection: $categoriaSelecionada){
                                Text("Selecione").tag(nil as CategoryModel?)
                                
                                ForEach(viewModel.categories) { categoria in
                                    Text(categoria.name).tag(categoria as CategoryModel?)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(height: 45)
                            .tint(.corTextosBotoes)
                        }
                    }
                    .padding(.horizontal,20)
                    .padding(8)
                }

                Button {
                    guard !titulo.isEmpty, !valor.isEmpty else {
                        alertMessage = "Preencha todos os campos"; showAlert = true; return
                    }
                    
                    let valorFormatado = valor.replacingOccurrences(of: ",", with: ".")
                    
                    guard let valorDecimal = Decimal(string: valorFormatado) else {
                        alertMessage = "Valor inválido"; showAlert = true; return
                    }
                    
                    guard let categoria = categoriaSelecionada else {
                        alertMessage = "Selecione uma categoria"; showAlert = true; return
                    }
                    
                    // ✅ Aplica o sinal baseado no estado ehNegativo
                    let valorFinal = ehNegativo ? abs(valorDecimal) * -1 : abs(valorDecimal)
                    
                    // ✅ NOVO: Verifica se a categoria mudou
                    let categoriaMudou = transaction.category?.id != categoria.id
                    
                    // Atualiza dados básicos
                    transaction.descricao = titulo
                    transaction.valor = valorFinal
                    transaction.category = categoria
                    
                    // ✅ NOVO: Herda características de recorrência da nova categoria
                    if categoriaMudou {
                        if categoria.isRecorrente {
                            // Nova categoria É recorrente → torna a transação recorrente
                            transaction.isRecorrenteIndividual = true
                            transaction.recorrenciaAtiva = true
                            transaction.tipoRecorrenciaRaw = categoria.tipoRecorrenciaRaw
                            transaction.intervaloRecorrencia = categoria.intervaloRecorrencia
                            transaction.ehTransacaoAutomatica = false
                            transaction.proximaOcorrencia = CategoryModel.calcularProximaOcorrencia(
                                from: Date(),
                                tipo: categoria.tipoRecorrencia,
                                intervalo: categoria.intervaloRecorrencia
                            )
                            print("✅ Transação '\(titulo)' agora é recorrente (herdou da categoria '\(categoria.name)')")
                        } else {
                            // Nova categoria NÃO é recorrente → remove recorrência da transação
                            transaction.isRecorrenteIndividual = false
                            transaction.recorrenciaAtiva = false
                            transaction.tipoRecorrenciaRaw = nil
                            transaction.intervaloRecorrencia = nil
                            transaction.proximaOcorrencia = nil
                            transaction.ehTransacaoAutomatica = false
                            print("✅ Transação '\(titulo)' não é mais recorrente (categoria '\(categoria.name)' não é recorrente)")
                        }
                    }
                    
                    try? modelContext.save()
                    dismiss()
                    
                } label: {
                    HStack {
                        Image(systemName: "arrowshape.up.circle")
                        Text("Atualizar")
                            .font(.system(size: 25))
                    }
                    .foregroundStyle(.black)
                    .frame(height: 66)
                    .frame(maxWidth: .infinity)
                    .background(Color.verdeClarinho)
                    .cornerRadius(20)
                }
                .padding(EdgeInsets(top: 30, leading: 22, bottom: 30, trailing: 22))

            }
        }
        .tint(.corTextosBotoes)
        // ✅ TOOLBAR COM BOTÃO ±
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button(action: {
                    ehNegativo.toggle()
                }) {
                    HStack {
                        Image(systemName: ehNegativo ? "minus.circle.fill" : "plus.circle.fill")
                    }
                    .foregroundStyle(ehNegativo ? Color.corVermelhoApagar : Color.corUIitens)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
//                    .background(Color.corCaixaDeTexto)
                    .cornerRadius(8)
                }
                
                Spacer()

            }
        }
        .onAppear(){
            viewModel.setContext(modelContext)
            titulo = transaction.descricao
            
            // ✅ Define se é negativo baseado no valor original
            ehNegativo = transaction.valor < 0
            
            let formatador = NumberFormatter()
            formatador.numberStyle = .decimal
            formatador.maximumFractionDigits = 2
            formatador.minimumFractionDigits = 2
            valor = formatador.string(from: abs(transaction.valor) as NSDecimalNumber) ?? ""
            
            categoriaSelecionada = transaction.category
        }
        .onTapGesture {
            hideKeyboard()
        }
        .alert("Aviso", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
}

#Preview {
    NavigationStack {
        editTransaction(transaction: PreviewHelper.exampleTransaction)
    }
    .modelContainer(PreviewHelper.container)
}

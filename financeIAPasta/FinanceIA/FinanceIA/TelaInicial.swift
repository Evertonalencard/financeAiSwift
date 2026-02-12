import SwiftUI
import Charts
import SwiftData

struct CustomDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        return context.maxDetentValue - 1
    }
}

struct TelaInicialView: View {
    @State private var showingSheetGasto = false
    @State private var showingSheetGanho = false
    
    @StateObject var dados = ViewModel()
    @Environment(\.modelContext) var modelContext
    
    private var areaBackground: Gradient {
        return Gradient(colors: [Color.brown, Color.brown.opacity(0.1)])
    }
    
    @State var clicouGanho: Bool = false
    @State var clicouGasto: Bool = true
    
    var body: some View {
        ZStack {
           BackgroundView()
            
            VStack {
                if #available(iOS 26.0, *) {
                    Text("Finance AI")
                        .font(.title)
                        .bold()
                        .foregroundStyle(Color.corTextosBotoes)
                    
                    seletorPeriodo
                    
                    ScrollView {
                        
                        // Conteúdo da ScrollView
                        contentView
                    }
                    // ✅ Aplicando o estilo "soft" para o efeito Liquid Glass
                    .scrollEdgeEffectStyle(.soft, for: .all)
                    .navigationTitle("Scroll View")
                    
                } else {
                    Text("Finance AI")
                        .font(.title)
                        .bold()
                        .foregroundStyle(Color.corTextosBotoes)
                    seletorPeriodo
                    
                    ScrollView {
                        contentView
                    }
                }
            }
        }
        .onAppear() {
            dados.setContext(modelContext)
        }
    }
    
    // ✅ NOVO: Seletor de Período
    var seletorPeriodo: some View {
            VStack(spacing: 8) {
                Picker("Período", selection: $dados.periodoCarregado) {
                    ForEach(ViewModel.PeriodoHistorico.allCases, id: \.self) { periodo in
                        Text(periodo.rawValue).tag(periodo)
                    }
                    
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .onChange(of: dados.periodoCarregado) { oldValue, newValue in
                    dados.fetch(periodo: newValue)
                }
                
                
            }
            .padding(.top, 8)
            .padding(.bottom, 4)
        }
    
    // Extraí o conteúdo para evitar duplicação no código acima
    var contentView: some View {
        VStack {
            if #available(iOS 26.0, *){
                // Versão iOS 26
                VStack (alignment: .leading) {
                    Text(" Saldo")
                        .foregroundStyle(Color.corTextosBotoes)
                        .font(.title2)
                    
                    Text(dados.ganhos + dados.gastos, format: .currency(code: "BRL"))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(Color.corTextosBotoes)
                        .minimumScaleFactor(0.5)
                        .glassedEffect(in: .capsule, interactive: true)
                }
                .padding(22)
                
                HStack {
                    VStack (alignment: .leading)  {
                        Text(" Ganhos")
                            .foregroundStyle(Color.corTextosBotoes)
                            .font(.title2)
                        
                        Text(dados.ganhos, format: .currency(code: "BRL"))
                            .frame( height: 50)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(Color.corTextosBotoes)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .glassedEffect(in: .capsule, interactive: true)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    VStack (alignment: .leading) {
                        Text(" Gastos")
                            .foregroundStyle(Color.corTextosBotoes)
                            .font(.title2)
                        
                        Text(dados.gastos, format: .currency(code: "BRL"))
                            .frame( height: 50)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(Color.corTextosBotoes)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .glassedEffect(in: .capsule, interactive: true)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
            } else {
                // Versão Anterior (Fallback)
                VStack {
                    VStack (alignment: .leading) {
                        Text("Saldo")
                            .foregroundStyle(Color.corTextosBotoes)
                            .font(.title2)
                        ZStack (alignment: .leading) {
                            Rectangle()
                                .frame( height: 50)
                                .foregroundColor(.corCaixaDeTexto)
                                .cornerRadius(10)
                            Text(dados.ganhos + dados.gastos, format: .currency(code: "BRL"))
                                .foregroundStyle(Color.corTextosBotoes)
                                .padding(.horizontal)
                                .minimumScaleFactor(0.5)
                        }
                    }
                    .padding(.horizontal,20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        VStack (alignment: .leading)  {
                            Text("Ganhos")
                                .foregroundStyle(Color.corTextosBotoes)
                                .font(.title2)
                            ZStack (alignment: .leading) {
                                Rectangle()
                                    .frame(width: 150, height: 50)
                                    .foregroundColor(.corCaixaDeTexto)
                                    .cornerRadius(10)
                                Text(dados.ganhos, format: .currency(code: "BRL"))
                                    .foregroundStyle(Color.corTextosBotoes)
                                    .padding(.horizontal)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.6)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                        
                        VStack (alignment: .leading) {
                            Text("Gastos")
                                .foregroundStyle(Color.corTextosBotoes)
                                .font(.title2)
                            ZStack (alignment: .leading) {
                                Rectangle()
                                    .frame(width: 150, height: 50)
                                    .foregroundColor(.corCaixaDeTexto)
                                    .cornerRadius(10)
                                Text(dados.gastos, format: .currency(code: "BRL"))
                                    .foregroundStyle(Color.corTextosBotoes)
                                    .padding(.horizontal)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.6)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal)
                }
            }
            
            // Gráfico e Botões (Compartilhado)
            VStack {
                Text("Bússola Financeira")
                    .font(.title)
                    .bold()
                    .foregroundStyle(Color.corTextosBotoes)
                
                ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            // 1. Gráfico Ganhos vs Gastos
                            graficoGanhosGastos
                                .frame(width: 350)
                            
                            // 2. Gráfico de Categorias (Gastos)
                            graficoCategorias
                                .frame(width: 350)
                            
                            // 3. Gráfico de Evolução (7 dias)
                            graficoEvolucao
                                .frame(width: 350)
                            
                            // 4. Gráfico de Recorrências
                            graficoRecorrencias
                                .frame(width: 350)
                        }
                        .padding(.horizontal, 22)
                    }
                }
                .padding(.vertical, 10)
            
            // Botões de Ação
            if #available(iOS 26.0, *) {
                GlassEffectContainer(spacing: 50) {
                    HStack {
                        Image(systemName: "plus")
                            .frame(width: 120, height: 120)
                            .font(.system(size: 90))
                            .glassedEffect(in: .buttonBorder, interactive: true)
                            .foregroundStyle(Color.corTextosBotoes)
                            .onTapGesture {
                                showingSheetGanho.toggle()
                                clicouGanho = false
                            }.sheet(isPresented: $showingSheetGanho, onDismiss: { dados.fetch() }) {
                                AdicionarGanho(ganhoOuGasto: clicouGanho)
                                    .presentationDetents([.custom(CustomDetent.self)])
                                    .presentationDetents([.fraction(0.65)])
                            }
                        
                        Image(systemName: "minus")
                            .frame(width: 120, height: 120)
                            .font(.system(size: 90))
                            .glassedEffect(in: .capsule, interactive: true)
                            .foregroundStyle(Color.corVermelhoApagar)
                            .onTapGesture {
                                showingSheetGasto.toggle()
                                clicouGasto = true
                            }.sheet(isPresented: $showingSheetGasto, onDismiss: { dados.fetch() }) {
                                AdicionarGanho(ganhoOuGasto: clicouGasto)
                                    .presentationDetents([.custom(CustomDetent.self)])
                                    .presentationDetents([.fraction(0.65)])
                            }
                    }
                }.padding(.bottom,10)
            } else {
                HStack(spacing: 40) {
                    Image(systemName: "plus.app.fill")
                        .frame(width: 120, height: 120)
                        .font(.system(size: 100))
                        .foregroundStyle(Color.corTextosBotoes)
                        .onTapGesture {
                            showingSheetGanho.toggle()
                            clicouGanho = false
                        }.sheet(isPresented: $showingSheetGanho, onDismiss: { dados.fetch() }) {
                            AdicionarGanho(ganhoOuGasto: clicouGanho)
                                .presentationDetents([.custom(CustomDetent.self)])
                                .presentationDetents([.fraction(0.65)])
                        }
                    
                    Image(systemName: "minus.circle.fill")
                        .frame(width: 120, height: 120)
                        .font(.system(size: 100))
                        .foregroundStyle(Color.verdeClarinho)
                        .onTapGesture {
                            showingSheetGasto.toggle()
                            clicouGasto = true
                        }.sheet(isPresented: $showingSheetGasto, onDismiss: { dados.fetch() }) {
                            AdicionarGanho(ganhoOuGasto: clicouGasto)
                                .presentationDetents([.custom(CustomDetent.self)])
                                .presentationDetents([.fraction(0.65)])
                        }
                }.padding(.bottom,10)
            }
        }
    }

    // MARK: - Gráficos Individuais

    // 1️⃣ Gráfico Ganhos vs Gastos (já existente, refatorado)
    var graficoGanhosGastos: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("💰 Ganhos vs Gastos")
                .font(.headline)
                .foregroundStyle(Color.corTextosBotoes)
                .padding(.horizontal)
            
            if #available(iOS 26.0, *) {
                Chart(Array(dados.gastosGanhos.enumerated()), id: \.offset) { index, dado in
                    BarMark(
                        x: .value("Tipo", index == 0 ? "Ganhos" : "Gastos"),
                        y: .value("Valor", NSDecimalNumber(decimal: abs(dado)).doubleValue)
                    )
                    .foregroundStyle(index == 1 ? Color.corVermelhoApagar : Color.corCaixaDeTexto)
                    .cornerRadius(5)
                    .annotation(position: .top) {
                        Text(abs(dado), format: .currency(code: "BRL"))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .chartXScale(domain: ["Ganhos", "Gastos"])
                .frame(height: 250)
                .padding(20)
                .glassEffect(.regular, in: .containerRelative)
                .cornerRadius(10)
                .chartXAxis {
                    AxisMarks { _ in
                        AxisGridLine().foregroundStyle(.gray.opacity(0.3))
                        AxisValueLabel().foregroundStyle(Color.charts).font(.caption.bold())
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine().foregroundStyle(.gray.opacity(0.3))
                        AxisValueLabel().foregroundStyle(Color.charts)
                    }
                }
            } else {
                Chart(Array(dados.gastosGanhos.enumerated()), id: \.offset) { index, dado in
                    BarMark(
                        x: .value("Tipo", index == 0 ? "Ganhos" : "Gastos"),
                        y: .value("Valor", NSDecimalNumber(decimal: abs(dado)).doubleValue)
                    )
                    .foregroundStyle(index == 1 ? Color.corVermelhoApagar : Color.verdeClarinho)
                    .cornerRadius(5)
                    .annotation(position: .top) {
                        Text(abs(dado), format: .currency(code: "BRL"))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .chartXScale(domain: ["Ganhos", "Gastos"])
                .frame(height: 250)
                .padding()
                .background(Color.corCaixaDeTexto.opacity(0.5))
                .cornerRadius(10)
                .chartXAxis {
                    AxisMarks { _ in
                        AxisGridLine().foregroundStyle(.gray.opacity(0.3))
                        AxisValueLabel().foregroundStyle(Color.charts).font(.caption.bold())
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine().foregroundStyle(.gray.opacity(0.3))
                        AxisValueLabel().foregroundStyle(Color.charts)
                    }
                }
            }
        }
    }

    // 2️⃣ Gráfico de Categorias (Top 5 Gastos)
    var graficoCategorias: some View {
        let dadosCategorias = dados.gastosPorCategoria()
        
        return VStack(alignment: .leading, spacing: 10) {
            Text("📂 Top 5 Categorias")
                .font(.headline)
                .foregroundStyle(Color.corTextosBotoes)
                .padding(.horizontal)
            
            if dadosCategorias.isEmpty {
                emptyChartView(message: "Sem dados de categorias")
            } else {
                if #available(iOS 26.0, *) {
                    Chart(dadosCategorias, id: \.categoria) { item in
                        SectorMark(
                            angle: .value("Valor", NSDecimalNumber(decimal: item.valor).doubleValue),
                            innerRadius: .ratio(0.5),
                            angularInset: 2
                        )
                        .foregroundStyle(by: .value("Categoria", item.categoria))
                        .cornerRadius(5)
                    }
                    .frame(height: 250)
                    .padding()
                    .glassEffect(.regular, in: .containerRelative)
                    .cornerRadius(10)
                    .chartLegend(position: .bottom, spacing: 8)
                } else {
                    Chart(dadosCategorias, id: \.categoria) { item in
                        BarMark(
                            x: .value("Valor", NSDecimalNumber(decimal: item.valor).doubleValue),
                            y: .value("Categoria", item.categoria)
                        )
                        .foregroundStyle(Color.corVermelhoApagar)
                        .annotation(position: .trailing) {
                            Text(item.valor, format: .currency(code: "BRL"))
                                .font(.caption2)
                                .foregroundColor(.corTextosBotoes)
                        }
                    }
                    .frame(height: 250)
                    .padding()
                    .background(Color.corCaixaDeTexto.opacity(0.5))
                    .cornerRadius(10)
                    .chartXAxis(.hidden)
                    .chartYAxis {
                        AxisMarks { _ in
                            AxisValueLabel().foregroundStyle(Color.corTextosBotoes).font(.caption)
                        }
                    }
                }
            }
        }
    }

    // 3️⃣ Gráfico de Evolução (7 dias)
    var graficoEvolucao: some View {
        let dadosEvolucao = dados.transacoesRecentes()
        
        return VStack(alignment: .leading, spacing: 10) {
            Text("📈 Evolução (7 dias)")
                .font(.headline)
                .foregroundStyle(Color.corTextosBotoes)
                .padding(.horizontal)
            
            if dadosEvolucao.isEmpty {
                emptyChartView(message: "Sem transações recentes")
            } else {
                if #available(iOS 26.0, *) {
                    Chart(dadosEvolucao, id: \.data) { item in
                        LineMark(
                            x: .value("Data", item.data, unit: .day),
                            y: .value("Saldo", NSDecimalNumber(decimal: item.saldo).doubleValue)
                        )
                        .foregroundStyle(item.saldo >= 0 ? Color.verdeClarinho : Color.corVermelhoApagar)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        
                        AreaMark(
                            x: .value("Data", item.data, unit: .day),
                            y: .value("Saldo", NSDecimalNumber(decimal: item.saldo).doubleValue)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    item.saldo >= 0 ? Color.verdeClarinho.opacity(0.3) : Color.corVermelhoApagar.opacity(0.3),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                    .frame(height: 250)
                    .padding(20)
                    .glassEffect(.regular, in: .containerRelative)
                    .cornerRadius(10)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { _ in
                            AxisGridLine().foregroundStyle(.gray.opacity(0.3))
                            AxisValueLabel(format: .dateTime.day().month(), centered: true)
                                .foregroundStyle(Color.charts)
                                .font(.caption2)
                        }
                    }
                    .chartYAxis {
                        AxisMarks { _ in
                            AxisGridLine().foregroundStyle(.gray.opacity(0.3))
                            AxisValueLabel().foregroundStyle(Color.charts).font(.caption2)
                        }
                    }
                } else {
                    Chart(dadosEvolucao, id: \.data) { item in
                        LineMark(
                            x: .value("Data", item.data, unit: .day),
                            y: .value("Saldo", NSDecimalNumber(decimal: item.saldo).doubleValue)
                        )
                        .foregroundStyle(item.saldo >= 0 ? Color.verdeClarinho : Color.corVermelhoApagar)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                    }
                    .frame(height: 250)
                    .padding()
                    .background(Color.corCaixaDeTexto.opacity(0.5))
                    .cornerRadius(10)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { _ in
                            AxisValueLabel(format: .dateTime.day().month())
                                .foregroundStyle(Color.charts)
                                .font(.caption2)
                        }
                    }
                    .chartYAxis {
                        AxisMarks { _ in
                            AxisValueLabel().foregroundStyle(Color.charts).font(.caption2)
                        }
                    }
                }
            }
        }
    }

    // 4️⃣ Gráfico de Recorrências
    var graficoRecorrencias: some View {
        let proximasRecorrencias = dados.proximasRecorrencias()
        let totalRecorrente = dados.totalRecorrenciasAtivas()
        
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("🔄 Recorrências")
                    .font(.headline)
                    .foregroundStyle(Color.corTextosBotoes)
                
                Spacer()
                
                Text(totalRecorrente, format: .currency(code: "BRL"))
                    .font(.caption)
                    .foregroundStyle(totalRecorrente >= 0 ? Color.verdeClarinho : Color.corVermelhoApagar)
                    .bold()
            }
            .padding(.horizontal)
            
            if proximasRecorrencias.isEmpty {
                emptyChartView(message: "Sem recorrências ativas")
            } else {
                if #available(iOS 26.0, *) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(proximasRecorrencias, id: \.descricao) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.descricao)
                                        .font(.caption)
                                        .foregroundStyle(Color.corTextosBotoes)
                                        .lineLimit(1)
                                    
                                    Text(item.data, style: .date)
                                        .font(.caption2)
                                        .foregroundStyle(Color.corTextosBotoes.opacity(0.7))
                                }
                                
                                Spacer()
                                
                                Text(item.valor, format: .currency(code: "BRL"))
                                    .font(.caption)
                                    .bold()
                                    .foregroundStyle(item.valor >= 0 ? Color.verdeClarinho : Color.corVermelhoApagar)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.corDeFundo2.opacity(0.3))
                            .cornerRadius(8)
                        }
                    }
                    .frame(height: 250)
                    .padding(20)
                    .glassEffect(.regular, in: .containerRelative)
                    .cornerRadius(10)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(proximasRecorrencias, id: \.descricao) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.descricao)
                                        .font(.caption)
                                        .foregroundStyle(Color.corTextosBotoes)
                                        .lineLimit(1)
                                    
                                    Text(item.data, style: .date)
                                        .font(.caption2)
                                        .foregroundStyle(Color.corTextosBotoes.opacity(0.7))
                                }
                                
                                Spacer()
                                
                                Text(item.valor, format: .currency(code: "BRL"))
                                    .font(.caption)
                                    .bold()
                                    .foregroundStyle(item.valor >= 0 ? Color.verdeClarinho : Color.corVermelhoApagar)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.corCaixaDeTexto.opacity(0.5))
                            .cornerRadius(8)
                        }
                    }
                    .frame(height: 250)
                    .padding()
                    .background(Color.corCaixaDeTexto.opacity(0.5))
                    .cornerRadius(10)
                }
            }
        }
    }

    // Helper para gráficos vazios
    func emptyChartView(message: String) -> some View {
        VStack {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 40))
                .foregroundStyle(Color.corTextosBotoes.opacity(0.3))
            
            Text(message)
                .font(.caption)
                .foregroundStyle(Color.corTextosBotoes.opacity(0.5))
        }
        .frame(height: 250)
        .frame(maxWidth: .infinity)
        .background(Color.corCaixaDeTexto.opacity(0.3))
        .cornerRadius(10)
        .padding()
    }

}

import SwiftUI

extension Date {
    var millisecondsSince1970:Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

struct editTransaction: View {
    @State var transaction: Transaction
    
    @State var categoriaSelecionada: Category?
    @State var titulo = ""//"\(transaction.descricao)"
    @State var valor = ""//"\(transaction.valor)"
    @StateObject var viewModel = ViewModel()
    
    @State private var showAlert = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        ZStack{
            Color.corDeFundo
                .ignoresSafeArea()
            VStack {
                
                TextField("", text: $titulo,prompt: Text("Titulo:").font(.system(size: 25)).foregroundColor(.corTextosBotoes))
                    .foregroundColor(.corTextosBotoes)
                    .font(.system(size: 25))
                    .padding()
                    .frame(width: 350,height: 45)
                    .background(Color.corCaixaDeTexto)
                    .cornerRadius(10)
                    .padding(.bottom,20)
                
                TextField("", text: $valor,prompt: Text("Valor:").font(.system(size: 25)).foregroundColor(.corTextosBotoes))
                    .foregroundColor(.corTextosBotoes)
                    .font(.system(size: 25))
                    .padding()
                    .frame(width: 350,height: 45)
                    .background(Color.corCaixaDeTexto)
                    .cornerRadius(10)
                    .padding(.bottom,20)
                    .keyboardType(.decimalPad)
                
                Picker("Selecione a categoria", selection: $categoriaSelecionada){
                    Text("Selecione").tag(nil as Category?)
                    ForEach(viewModel.categories, id: \.self) { categoria in
                        Text(categoria.name).tag(categoria as Category?)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 350,height: 45)
                .background(Color.corCaixaDeTexto)
                .cornerRadius(10)
                .tint(.corTextosBotoes)// deve ser substituido por categoria.
                
                Button("Adicionar") {
                    guard !titulo.isEmpty, !valor.isEmpty else {
                        alertMessage = "Preencha todos os campos"
                        showAlert = true
                        return
                    }
                    
                    guard let valorDouble = Double(valor.replacingOccurrences(of: ",", with: ".")) else {
                        alertMessage = "Valor inválido"
                        showAlert = true
                        return
                    }
                    
                    guard let categoria = categoriaSelecionada else {
                        alertMessage = "Selecione uma categoria"
                        showAlert = true
                        return
                    }
                    
                    viewModel.editTransaction(trasaction: Transaction(
                        _id: transaction._id,
                        _rev: transaction._rev,
                        descricao: titulo,
                        valor: valorDouble,
                        data: transaction.data,
                        category: categoria
                    ))
                    
                    titulo = ""
                    valor = ""
                    
                }
                
                .font(.system(size: 25))
                .foregroundColor(.black)
                .frame(width: 350,height: 66)
                .background(.verdeClarinho)
                .cornerRadius(20)
                .padding(.top,30)
                
                
                Spacer()
            }
        }
        
        .onAppear(){
            viewModel.fetch()
            viewModel.fetchCategory()
            titulo = "\(transaction.descricao)"
            valor = "\(transaction.valor)"
        }
        .alert("Aviso", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        
        
        
    }
}


#Preview {
    editTransaction(transaction: Transaction(
        _id: "1",
        _rev: "1",
        descricao: "Teste",
        valor: 100.0,
        data: Int(Date().timeIntervalSince1970),
        category: Category(name: "Alimentação")
    ))
    .environmentObject(ViewModel()) // ✅ Se usar EnvironmentObject
}


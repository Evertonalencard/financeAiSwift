
//
//  ContentView.swift
//  gemini-api
//
//  Created by Turma02 on 04/11/25.
//

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
    
    let model = GenerativeModel(name: "gemini-2.5-flash", apiKey: APIKey.default)
    
    @State var textInput: message = message(source: .user, text: "")
    @State var aiResponse: message = message(source: .ai, text: "Hello! How can I assist you today")
    @State var loading: Bool = false
    
    @State var listSystemMessages: [message] = []
    
    func sendMessage() {
        aiResponse = message(source: .ai, text: "")
        
        Task {
            do {
                let response = try await model.generateContent("Seja bastante objetivo em sua resposta, mas educado. Esse é o contexto anterior da conversa: \(listSystemMessages) Com base nisso, escreva uma resposta para: \(textInput.text)")
                
                guard let text = response.text else {
                    textInput = message(source: .ai, text: "Sorry, Icouldn't process that.")
                    listSystemMessages.append(textInput)
                    loading = false
                    
                    return
                }
                
                textInput = message(source: .ai, text: "")
                aiResponse = message(source: .ai, text: text)
                listSystemMessages.append(aiResponse)
                loading = false
                
            } catch {
                aiResponse = message(source: .ai, text: "An error occurred: \(error)")
                listSystemMessages.append(aiResponse)
                loading = false
            }
        }
    }
    
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
                        TextField("", text: $textInput.text, prompt: Text("Diga algo...").foregroundColor(.corTextosBotoes).font(.system(size: 25)))
                            .foregroundColor(.corTextosBotoes)
                            .font(.system(size: 25))
                        
                        Button {
                            listSystemMessages.append(message(source: .user, text: textInput.text))
                            loading = true
                            sendMessage()
                        } label: {
                            Image(systemName: "paperplane.fill")
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
        }
    }
}

#Preview {
    IADasFinancas()
}

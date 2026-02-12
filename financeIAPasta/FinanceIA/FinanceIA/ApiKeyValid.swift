//
//  ApiKeyValid.swift
//  gemini-api
//
//  Created by Turma02 on 04/11/25.
//

import Foundation

enum APIKey {

    static var `default` : String {
        let value = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String ?? ""
        return value
    }
}




//
//  LoginResponse.swift
//  HELP_DESK_APP
//
//  Created by Braulio Alejandro Navarrete Horta on 16/06/24.
//

import Foundation

struct LoginResponse: Codable {
    var usuario: Usuario
    var tickets: [Ticket]
}

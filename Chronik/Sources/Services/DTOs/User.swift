//
//  User.swift
//  Chronik
//
//  Created by Vít Míchal on 22.07.2026.
//

import Foundation

enum UserRoleDto: String, Codable {
    case guest
    case host
    case admin
}

struct UserDto: Identifiable, Codable {
    let id: UUID
    let name: String
    let email: String
    let avatarUrl: URL?
    let role: UserRoleDto
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case avatarUrl = "avatar_url"
        case role
        case createdAt = "created_at"
    }
}

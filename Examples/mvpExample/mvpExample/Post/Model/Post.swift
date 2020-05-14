//
//  Post.swift
//  mvpExample
//
//  Created by Emanuel Luayza on 14/05/2020.
//  Copyright © 2020 Emanuel Luayza. All rights reserved.
//

import Foundation

struct Post: Codable {
    
    // MARK: - Properties
    
    var id: Int
    var title: String
    var body: String
    var userId: Int
    
    // MARK: - Methods
}

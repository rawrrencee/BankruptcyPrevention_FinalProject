//
//  FirestoreReferenceManager.swift
//  bankruptcyprevention_finalproject
//
//  Created by Lawrence on 14/11/19.
//  Copyright © 2019 Lawrence Lim. All rights reserved.
//

import Firebase

struct FirestoreReferenceManager {
    static let db = Firestore.firestore()
    
    static let users = db.collection("users")
}

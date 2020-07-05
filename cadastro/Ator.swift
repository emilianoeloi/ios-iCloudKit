//
//  Ator.swift
//  cadastro
//
//  Created by emiliano.barbosa on 05/07/20.
//  Copyright © 2020 NevBar. All rights reserved.
//

import Foundation

@objc func refresh(_ completion: @escaping (Error?) -> Void) {
  // 1.
  let predicate = NSPredicate(value: true)
  // 2.
  let query = CKQuery(recordType: "Atores", predicate: predicate)
  atores(forQuery: query, completion)
}


private func atores(forQuery query: CKQuery,
    _ completion: @escaping (Error?) -> Void) {
  publicDB.perform(query,
      inZoneWith: CKRecordZone.default().zoneID) { [weak self] results, error in
    guard let self = self else { return }
    if let error = error {
      DispatchQueue.main.async {
        completion(error)
      }
      return
    }
    guard let results = results else { return }
    self.establishments = results.compactMap {
      Establishment(record: $0, database: self.publicDB)
    }
    DispatchQueue.main.async {
      completion(nil)
    }
  }
}


//
//  CodingUserInfoKey+Util.swift
//  RxFlickr
//
//  Created by victory1908 on 1/10/18.
//  Copyright © 2018 victory1908. All rights reserved.
//

import Foundation

public extension CodingUserInfoKey {
    // Helper property to retrieve the Core Data managed object context
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")
}

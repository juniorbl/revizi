//
//  UnlimitedSubjects.swift
//  Revizi
//
//  Created by Carlos on 2019-01-28.
//  Copyright © 2019 Carlos Luz. All rights reserved.
//

struct UnlimitedSubjects {
    public static let unlimitedSubjectsProductId = "net.carlosluz.revizi.unlimitedsubjects"
    private static let productIDs: Set<String> = [unlimitedSubjectsProductId]
    public static let store = StoreHelper(productIds: productIDs)
}

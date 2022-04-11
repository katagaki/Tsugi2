//
//  JSONUtilities.swift
//  Buses
//
//  Created by 堅書 on 2022/04/11.
//

import Foundation

func decode<T: Decodable>(from path: String) -> T? {
    do {
        let decoder = JSONDecoder()
        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        return try decoder.decode(T.self, from: data)
    } catch let DecodingError.dataCorrupted(context) {
        print(context)
    } catch let DecodingError.keyNotFound(key, context) {
        print("Key '\(key)' not found:", context.debugDescription)
        print("codingPath:", context.codingPath)
    } catch let DecodingError.valueNotFound(value, context) {
        print("Value '\(value)' not found:", context.debugDescription)
        print("codingPath:", context.codingPath)
    } catch let DecodingError.typeMismatch(type, context)  {
        print("Type '\(type)' mismatch:", context.debugDescription)
        print("codingPath:", context.codingPath)
    } catch {
        print("error: ", error)
    }
    return nil
}

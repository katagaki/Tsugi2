//
//  JSONUtilities.swift
//  Buses
//
//  Created by 堅書 on 2022/04/11.
//

import Foundation

func encode<T: Encodable>(_ object: T) -> String? {
    do {
        let jsonData = try JSONEncoder().encode(object)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        return jsonString
    } catch {
        log("Error while encoding an object: \(error.localizedDescription)")
    }
    return nil
}

func decode<T: Decodable>(from path: String) -> T? {
    do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        return decode(fromData: data)
    } catch {
        log("Error while decoding an object: \(error.localizedDescription)")
    }
    return nil
}

func decode<T: Decodable>(fromData data: Data) -> T? {
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch let DecodingError.dataCorrupted(context) {
        log("Error while decoding an object: \(context.debugDescription)\n" +
            "Coding Path: \(context.codingPath.description)\n" +
            "Underlying Error: \(context.underlyingError?.localizedDescription ?? "(none)")",
            level: .error)
    } catch let DecodingError.keyNotFound(key, context) {
        log("Error while decoding an object: \(context.debugDescription)\n" +
            "Key: \(key)\nCoding Path: \(context.codingPath.description)", level: .error)
    } catch let DecodingError.valueNotFound(value, context) {
        log("Error while decoding an object: \(context.debugDescription)\n" +
            "Value: \(value)\nCoding Path: \(context.codingPath.description)", level: .error)
    } catch let DecodingError.typeMismatch(type, context) {
        log("Error while decoding an object: \(context.debugDescription)\n" +
            "Type: \(type)\nCoding Path: \(context.codingPath.description)", level: .error)
    } catch {
        log("Error while decoding an object: \(error.localizedDescription)")
    }
    log(String(data: data, encoding: .utf8) ?? "No content found.")
    return nil
}

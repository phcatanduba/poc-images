//
//  Repository.swift
//  poc-images
//
//  Created by Pedro Henrique Catanduba de Andrade on 15/09/22.
//

import Foundation

class Repository {
    func getImages(breweryId: String, completion: @escaping ( ([ImageResponse]) -> () )) {
        let url = URL(string: "https://bootcamp-mobile-01.eastus.cloudapp.azure.com/breweries/photos/\(breweryId)")
        var request = URLRequest(url: url!)
        
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                if let data = data {
                    let decoder = JSONDecoder()
                    let imagesResponse = try decoder.decode([ImageResponse].self, from: data)
                    completion(imagesResponse)
                }
            } catch let error {
                print(error)
            }
        }.resume()
    }
    
    func postImage(imageData: Data, breweryId: String, completion: @escaping ((ImageResponse) -> ())) {
        let url = URL(string: "https://bootcamp-mobile-01.eastus.cloudapp.azure.com/breweries/photos/upload?brewery_id=\(breweryId)")
        var request = URLRequest(url: url!);
        request.httpMethod = "POST"

        let boundary = generateBoundaryString()

        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        request.httpBody = createBodyWithParameters(filePathKey: "file", imageDataKey: imageData, boundary: boundary)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                if let data = data {
                    let decoder = JSONDecoder()
                    let imageResponse = try decoder.decode(ImageResponse.self, from: data)
                    completion(imageResponse)
                }
            } catch let error {
                print(error)
            }

        }.resume()
    }
    
    func createBodyWithParameters(filePathKey: String?, imageDataKey: Data, boundary: String) -> Data {
        var body = Data();

        let filename = UUID().uuidString + ".jpg"

        let mimetype = "image/jpg"
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.append("\r\n")

        body.append("--\(boundary)--\r\n")

        return body
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
}

class ImageResponse: Codable {
    let id: String
    let breweryId: String
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case breweryId = "brewery_id"
        case url
    }
}

extension Data {
    mutating func append(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }
        append(data)
    }
}

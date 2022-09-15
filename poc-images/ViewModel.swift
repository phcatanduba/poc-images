//
//  ViewModel.swift
//  poc-images
//
//  Created by Pedro Henrique Catanduba de Andrade on 15/09/22.
//

import Foundation

class ViewModel {
    let repository = Repository()
    var lastImages: [ImageResponse] = []
    var savedImages: [String : [ImageResponse]] = [:]
    
    func postImage(imageData: Data, id: String, completion: @escaping (() -> ())) {
        repository.postImage(imageData: imageData, breweryId: id) { imageResponse in
            self.lastImages.append(imageResponse)
            
            if self.savedImages[id] != nil {
                self.savedImages[id]?.append(imageResponse)
            } else {
                self.savedImages[id] = [imageResponse]
            }
            
            completion()
        }
    }
    
    func getImages(breweryId: String, completion: @escaping (() -> ())) {
        repository.getImages(breweryId: breweryId) { imagesResponse in
            self.savedImages[breweryId] = imagesResponse
            completion()
        }
    }
}

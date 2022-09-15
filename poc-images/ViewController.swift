//
//  ViewController.swift
//  poc-images
//
//  Created by Pedro Henrique Catanduba de Andrade on 15/09/22.
//

import UIKit
import PhotosUI
import Kingfisher

class ViewController: UIViewController, PHPickerViewControllerDelegate {
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let viewModel = ViewModel()
    var images: [UIImage?] = []
    var pickerConfiguration = PHPickerConfiguration()
    var picker: PHPickerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerConfiguration.filter = .images
        picker = PHPickerViewController(configuration: pickerConfiguration)
        picker?.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    @IBAction func addImage(_ sender: Any) {
        present(picker ?? UIViewController(), animated: true)
    }
    
    @IBAction func post(_ sender: Any) {
        guard let data = images.last??.jpegData(compressionQuality: 0.0) else { return }
        viewModel.postImage(imageData: data, id: "teste") {
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }
    
    @IBAction func get(_ sender: Any) {
        viewModel.getImages(breweryId: "teste") {
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
       picker.dismiss(animated: true)
        for result in results {
            let provider = result.itemProvider
     
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, error in
                    if let image = image as? UIImage, !self.images.contains(image) {
                       self.images.append(image)
                    }
                }
            }
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image", for: indexPath) as? ImageCell  else { fatalError() }
        
        if let  url = URL(string: viewModel.savedImages["teste"]?[indexPath.row].url ?? "") {
            cell.photo.kf.setImage(with: url)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.savedImages["teste"]?.count ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
}

extension ViewController: UICollectionViewDelegate {
    
}

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var photo: UIImageView!
}

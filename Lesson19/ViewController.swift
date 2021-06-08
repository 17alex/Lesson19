//
//  ViewController.swift
//  Lesson19
//
//  Created by Алексей Алексеев on 08.06.2021.
//

import UIKit

class ViewController: UIViewController {

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
//        imageView.backgroundColor = .systemGray4
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        return imagePicker
    }()
    
    private lazy var imageCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
//        layout.itemSize = CGSize(width: 90, height: 90)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.reuseID)
        collection.dataSource = self
        collection.delegate = self
        collection.backgroundColor = .systemBackground
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private lazy var barButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(buttonPress))
    private var originalImage: UIImage! {
        didSet {
            print("didSet")
            createImages()
            imageCollection.reloadData()
        }
    }
    
    private let context = CIContext(options: nil)
    private var filteredImages: [CellImage] = []
//    private let filters = CIFilter.filterNames(inCategory: kCICategoryBuiltIn)
    var filters = [
        "CIPhotoEffectChrome",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectNoir",
        "CIPhotoEffectProcess",
        "CIPhotoEffectTonal",
        "CIPhotoEffectTransfer",
        "CISepiaTone"
    ]
    
    //MArK: - LiveCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        imageView.image = UIImage(named: "forest")
        originalImage = UIImage(named: "forest")
    }
    
    //MARK: - Metods
    
    private func createImages() {
        filteredImages.removeAll()
        
        filteredImages = filters.compactMap() { filterName in
            guard let currentFilter = CIFilter(name: filterName) else { return nil }
            let beginImage = CIImage(image: originalImage)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
//            currentFilter.setValue(0.5, forKey: kCIInputIntensityKey)
            guard let output = currentFilter.outputImage,
                  let cgImage = context.createCGImage(output, from: output.extent) else { return nil }
            print("CompactMap =", filterName)
            print("Thread =", Thread.current)
            return CellImage(filterName: filterName, image: UIImage(cgImage: cgImage))
            
        }
    }

    @objc private func buttonPress() {
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = barButtonItem
        view.addSubview(imageView)
        view.addSubview(imageCollection)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageCollection.topAnchor, constant: -8),
            
            imageCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            imageCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            imageCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            imageCollection.heightAnchor.constraint(equalToConstant: 200),
        ])
    }
}

//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        originalImage = image
        dismiss(animated: true) { [weak self] in self?.imageView.image = image }
    }
}

//MARK: - UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("numberOfItemsInSection =", filteredImages.count)
        return filteredImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.reuseID, for: indexPath) as? ImageCell else { fatalError() }
        cell.set(cellImage: filteredImages[indexPath.item])
        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let dim = collectionView.bounds.height
        return CGSize(width: dim, height: dim)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        imageView.image = filteredImages[indexPath.row].image
    }
}

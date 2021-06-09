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
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.reuseID)
        collection.dataSource = self
        collection.delegate = self
        collection.backgroundColor = .systemBackground
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private lazy var addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPress))
    private lazy var saveButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonPress))
    
    private let imageFilterService: ImageFilterServiceProtocol
    private let filters = Filter().names
    private var filteredImages: [CellImage] = []
    
    private var originalImage: UIImage! {
        didSet {
            print("didSet")
            imageView.image = originalImage
            title = ""
            createImages()
            imageCollection.reloadData()
        }
    }
    
    //MARK: - Init
    
    init(imageFilterService: ImageFilterServiceProtocol) {
        self.imageFilterService = imageFilterService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - LiveCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        let image = UIImage(named: "forest")
        imageView.image = image
        originalImage = image
    }
    
    //MARK: - Metods
    
    private func createImages() {
        filteredImages.removeAll()
        imageCollection.reloadData()
        
        filters.forEach { filterName in
            imageFilterService.modifi(image: originalImage, with: filterName) { outImage in
                guard let outImage = outImage else { return }
                let cellImage = CellImage(filterName: filterName, image: outImage)
                self.filteredImages.append(cellImage)
                let indexPath = IndexPath(item: self.filteredImages.count - 1, section: 0)
                self.imageCollection.insertItems(at: [indexPath])
            }
        }
    }

    @objc private func addButtonPress() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc private func saveButtonPress() {
        guard let image = imageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = saveButtonItem
        navigationItem.leftBarButtonItem = addButtonItem
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

//MARK: - UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
        let selectImage = filteredImages[indexPath.item]
        imageView.image = selectImage.image
        title = selectImage.filterName
    }
}

//MARK: - UIImagePickerController

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true)
        guard let image = info[.editedImage] as? UIImage else { return }
        originalImage = image
    }
}

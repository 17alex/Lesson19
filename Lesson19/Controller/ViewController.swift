//
//  ViewController.swift
//  Lesson19
//
//  Created by Алексей Алексеев on 08.06.2021.
//

import UIKit

class ViewController: UIViewController {

    //MARK: - Propertis
    
    private let mainImageView: UIImageView = {
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
    
    private lazy var intencivySlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.setValue(defaultValue, animated: false)
        slider.addTarget(self, action: #selector(sliderValueChange(slider:)), for: .touchUpInside)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private lazy var addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(imagePickerButtonPress))
    private lazy var saveButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveImageButtonPress))
    private lazy var settingButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(settingButtonPress))
    
    private let imageFilterService: ImageFilterServiceProtocol

    private var filters: [String] {
        return imageFilterService.filters
    }
    
    private var mainFilterName = ""
    private var filteredImages: [CellModel] = []
    private let defaultValue: Float = 0.5
    
    private var originalImage: UIImage! {
        didSet {
            print("didSet")
            mainImageView.image = originalImage
            title = "no filter"
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
        print("filters =", imageFilterService.filters)
        setupUI()
        let image = UIImage(named: "forest")
        mainImageView.image = image
        originalImage = image
    }
    
    //MARK: - Metods
    
    private func createImages() {
        filteredImages.removeAll()
        imageCollection.reloadData()
        
        filters.forEach { filterName in
            imageFilterService.modifi(image: originalImage, with: filterName, intensivity: defaultValue) { outImage in
                guard let outImage = outImage else { return }
                let cellModel = CellModel(filterName: filterName, image: outImage)
                self.filteredImages.append(cellModel)
                let indexPath = IndexPath(item: self.filteredImages.count - 1, section: 0)
                self.imageCollection.insertItems(at: [indexPath])
            }
        }
    }

    @objc private func sliderValueChange(slider: UISlider) {
        print("sliderValueChange =", slider.value)
        imageFilterService.modifi(image: originalImage, with: mainFilterName, intensivity: slider.value) { outImage in
            guard let outImage = outImage else { return }
            self.mainImageView.image = outImage
        }
    }
    
    @objc private func settingButtonPress() {
        intencivySlider.isHidden = !intencivySlider.isHidden
    }
    
    @objc private func imagePickerButtonPress() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc private func saveImageButtonPress() {
        guard let image = mainImageView.image else { return }
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
        navigationItem.rightBarButtonItems = [saveButtonItem, settingButtonItem]
        navigationItem.leftBarButtonItem = addButtonItem
        view.addSubview(mainImageView)
        view.addSubview(imageCollection)
        view.addSubview(intencivySlider)
        
        NSLayoutConstraint.activate([
            mainImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainImageView.bottomAnchor.constraint(equalTo: imageCollection.topAnchor, constant: -8),
            
            imageCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            imageCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            imageCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            imageCollection.heightAnchor.constraint(equalToConstant: 200),
            
            intencivySlider.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            intencivySlider.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            intencivySlider.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            intencivySlider.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        intencivySlider.isHidden = true
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
        let selectCell = filteredImages[indexPath.item]
        mainImageView.image = selectCell.image
        mainFilterName = selectCell.filterName
        title = selectCell.filterName
        intencivySlider.setValue(defaultValue, animated: true)
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

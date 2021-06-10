//
//  ImageFilterService.swift
//  Lesson19
//
//  Created by Алексей Алексеев on 09.06.2021.
//
//"CIPhotoEffectChrome",
//"CIPhotoEffectFade",
//"CIPhotoEffectInstant",
//"CIPhotoEffectNoir",
//"CIPhotoEffectProcess",
//"CIPhotoEffectTonal",
//"CIPhotoEffectTransfer",
//"CISepiaTone",
//"CIBlendWithRedMask",
//"CIBloom",
//"CIBokehBlur",
//"CIBoxBlur",
//"CIBumpDistortion",
//"CIBumpDistortionLinear",


import UIKit

protocol ImageFilterServiceProtocol {
    var filters: [String] { get }
    func modifi(image: UIImage, with filter: String, intensivity: Float, complete: @escaping ((UIImage?) -> Void))
}

class ImageFilterService {
    
    private let context = CIContext(options: nil)
    
    let filters = CIFilter.filterNames(inCategory: kCICategoryBuiltIn)
        .filter { filterName -> Bool in CIFilter(name: filterName)?.inputKeys.contains(kCIInputImageKey) ?? false }
        .filter { filterName -> Bool in CIFilter(name: filterName)?.inputKeys.contains(kCIInputIntensityKey) ?? false }
}

extension ImageFilterService: ImageFilterServiceProtocol {
    
    func modifi(image: UIImage, with filter: String, intensivity: Float, complete: @escaping ((UIImage?) -> Void)) {
        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self,
                  let currentFilter = CIFilter(name: filter) else { DispatchQueue.main.async { complete(nil) }; return }
            let beginImage = CIImage(image: image)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            currentFilter.setValue(intensivity, forKey: kCIInputIntensityKey)
            guard let output = currentFilter.outputImage,
                  let cgImage = strongSelf.context.createCGImage(output, from: output.extent) else { DispatchQueue.main.async { complete(nil) }; return }
            print("FilterName =", filter, ", Thread =", Thread.current)
            let returnImage = UIImage(cgImage: cgImage)
            DispatchQueue.main.async { complete(returnImage) }
        }
    }
}

//
//  ImageFilterService.swift
//  Lesson19
//
//  Created by Алексей Алексеев on 09.06.2021.
//

import UIKit

protocol ImageFilterServiceProtocol {
    func modifi(image: UIImage, with filter: String, complete: @escaping ((UIImage?) -> Void))
}

class ImageFilterService {
    
    private let context = CIContext(options: nil)
}

extension ImageFilterService: ImageFilterServiceProtocol {
    
    func modifi(image: UIImage, with filter: String, complete: @escaping ((UIImage?) -> Void)) {
        let myQueue = DispatchQueue(label: "myQueue", qos: .userInitiated, attributes: .concurrent)
        myQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            guard let currentFilter = CIFilter(name: filter) else { DispatchQueue.main.async { complete(nil) }; return }
            let beginImage = CIImage(image: image)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            //            currentFilter.setValue(0.5, forKey: kCIInputIntensityKey)
            guard let output = currentFilter.outputImage,
                  let cgImage = strongSelf.context.createCGImage(output, from: output.extent) else { DispatchQueue.main.async { complete(nil) }; return }
            print("FilterName =", filter, "Thread =", Thread.current)
            let returnImage = UIImage(cgImage: cgImage)
            DispatchQueue.main.async { complete(returnImage) }
        }
    }
}

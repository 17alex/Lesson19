//
//  FilterNames.swift
//  Lesson19
//
//  Created by Алексей Алексеев on 09.06.2021.
//

import Foundation

class Filter {
    //    private let filters = CIFilter.filterNames(inCategory: kCICategoryBuiltIn)
    private let filters = [
        "CIPhotoEffectChrome",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectNoir",
        "CIPhotoEffectProcess",
        "CIPhotoEffectTonal",
        "CIPhotoEffectTransfer",
        "CISepiaTone",
        "CIBlendWithRedMask",
        "CIBloom",
        "CIBokehBlur",
        "CIBoxBlur",
        "CIBumpDistortion",
        "CIBumpDistortionLinear",
    ]
    
    var names: [String] {
        return filters
    }
    
}

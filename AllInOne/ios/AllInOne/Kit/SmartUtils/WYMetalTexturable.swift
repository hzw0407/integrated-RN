//
//  WYMetalTexturable.swift
//  LearnMetal
//
//  Created by 3i_yang on 2021/11/20.
//

import MetalKit

protocol WYMetalTexturable { }

extension WYMetalTexturable {
    static func loadTexture(imageName: String) throws -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: WYMetalRenderer.device)
        
        let textureLoaderOptions: [MTKTextureLoader.Option: Any] = [.origin: MTKTextureLoader.Origin.bottomLeft, .SRGB: false, .generateMipmaps: NSNumber(booleanLiteral: true)]
        
        let fileExtension = URL(fileURLWithPath: imageName).pathExtension.isEmpty ? "png" : nil
        
        guard let url = Bundle.main.url(forResource: imageName, withExtension: fileExtension) else {
            print("Failed to load \(imageName)\n - loading from Assets Catalog")
            return try textureLoader.newTexture(name: imageName, scaleFactor: 1, bundle: Bundle.main, options: textureLoaderOptions)
        }
        
        let texture = try textureLoader.newTexture(URL: url, options: textureLoaderOptions)
        
        print("loaded texture: \(url.lastPathComponent)")
        return texture
    }
}

//
//  DataExtension.swift
//  SamUtils
//
//  Created by Qian-Yu Du on 2023/3/10.
//

import Foundation
import UIKit
import AVFoundation

public extension Data {
    
    /// Convert PCM 16bit data to AVAudioPCMBuffer
    ///
    ///     let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 8000, channels: 1, interleaved: false)!
    ///     let playBuffer = Data().convertPCMtoFloat32PCMBuffer(byFormat: format)
    ///
    /// iPhone only can play float32 buffer.
    func convertPCMtoFloat32PCMBuffer(byFormat: AVAudioFormat) -> AVAudioPCMBuffer {
        let audioBuffer = AVAudioPCMBuffer(pcmFormat: byFormat, frameCapacity: UInt32(self.count) / 2)!
        audioBuffer.frameLength = audioBuffer.frameCapacity
        
        for i in 0..<self.count / 2 {
            let floatChannelData = Float(Int16(self[i * 2 + 1]) << 8 | Int16( self[i * 2])) / (Float(Int16.max) + 1.0)
            audioBuffer.floatChannelData?.pointee[i] = floatChannelData
        }
        
        return audioBuffer
    }
    
    /// Split Data
    ///
    ///     let originalData: [UInt8] = [0, 0, 0, 1, 24, 25, 0, 0, 0, 1, 55, 65]
    ///     let separatorData: [UInt8] = [0, 0, 0, 1]
    ///     let splitDatas = originalData.split(Data(separatorData))
    ///     print(splitDatas) // [Data([24, 25]), Data([55, 65])]
    ///
    /// - Parameters:
    ///   - separator: Separator Data
    /// - Returns: Data Array
    func split(separator: Data) -> [Data] {
        var chunks: [Data] = []
        var position = startIndex
        
        while let r = self[position...].range(of: separator) {
            
            if r.lowerBound > position {
                chunks.append(self[position..<r.lowerBound])
            }
            position = r.upperBound
        }
        
        if position < endIndex {
            chunks.append(self[position..<endIndex])
        }
        return chunks
    }
}

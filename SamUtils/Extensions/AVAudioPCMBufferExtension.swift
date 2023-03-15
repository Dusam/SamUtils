//
//  AudioExtension.swift
//  SamUtils
//
//  Created by Qian-Yu Du on 2023/3/10.
//

import Foundation
import AVFoundation

public extension AVAudioPCMBuffer {
    
    /// Get data with PCM 16bit
    ///
    ///     let buffer: AVAudioPCMBuffer
    ///     buffer.to16bitData()
    func to16bitData() -> Data {
        let channels = UnsafeBufferPointer(start: self.int16ChannelData, count: 1)
        let data = Data(bytes: channels[0], count:Int(self.frameCapacity * self.format.streamDescription.pointee.mBytesPerFrame))
        return data
    }
}

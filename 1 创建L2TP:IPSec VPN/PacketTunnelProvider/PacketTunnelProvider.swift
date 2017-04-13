//
//  PacketTunnelProvider.swift
//  proxydump
//
//  Created by Zach on 11/04/2017.
//  Copyright © 2017 Lucifer. All rights reserved.
//

import UIKit
import NetworkExtension

class PacketTunnelProvider: NEPacketTunnelProvider {

    override func startTunnel(options: [String : NSObject]? = nil, completionHandler: @escaping (Error?) -> Void) {
        
        completionHandler(nil)
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        
    }

}

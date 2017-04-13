//
//  ViewController.swift
//  proxydump
//
//  Created by Zach on 11/04/2017.
//  Copyright © 2017 Lucifer. All rights reserved.
//

import UIKit
import NetworkExtension

class ViewController: UIViewController {

    @IBOutlet weak var vpnSwitch: UISwitch!
    
    var vpnManager: NEVPNManager!
    
    let serviceName = "let.us.try.vpn.in.ipsec" //随便自定义
    let vpnPwdIdentifier = "vpnPassword" //随便自定义
    let vpnPrivateKeyIdentifier = "sharedKey" //随便自定义
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initManager()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func switchChangeAction(_ sender: UISwitch) {
        if vpnManager.connection.status == .disconnected {
            do {
                try vpnManager.connection.startVPNTunnel()
            } catch  {
                NSLog("start error: \(error.localizedDescription)")
            }
        }
        else {
            vpnManager.connection.stopVPNTunnel()
        }
    }
    
    func initManager() {
//        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
//            guard managers != nil else {return}
//            
//            if managers!.count > 0 {
//                self.vpnManager = managers![0]
//            }
//            else {
//                self.createManager()
//            }
//        }
        createManager()
    }
    
    func createManager(){
        //设置共享密钥和密码到keychain
        createKeychainValue("密码", vpnPwdIdentifier)//密码
        createKeychainValue("共享密钥", vpnPrivateKeyIdentifier)//共享密钥
        
        let manager = NEVPNManager.shared()
        manager.loadFromPreferences { (error) in
            var conf: NEVPNProtocolIPSec? = manager.protocolConfiguration as? NEVPNProtocolIPSec
            if conf == nil {
                conf = NEVPNProtocolIPSec()
            }
            conf!.serverAddress = "10.200.11.108"//"走你地址"
            conf!.username = "zach"
            conf!.authenticationMethod = .sharedSecret
            conf!.sharedSecretReference = self.searchKeychainCopyMatching(self.vpnPrivateKeyIdentifier)
            conf!.passwordReference = self.searchKeychainCopyMatching(self.vpnPwdIdentifier)
            
            manager.protocolConfiguration = conf!;
            manager.localizedDescription = "走你vpn";
            manager.isEnabled = true
            manager.saveToPreferences { (error) in
                print("done: \(error.debugDescription)")
                if error == nil {
                    self.vpnManager = manager
                }
            }

        }
        
    }
    
    func newSearchDictionary(_ identifier : String) -> NSMutableDictionary {
        let searchDictionary = NSMutableDictionary()
        let encodedIdentifier: Data = identifier.data(using: .utf8)!
        searchDictionary.addEntries(from: [
            kSecClass as NSString: kSecClassGenericPassword as NSString,
            kSecAttrGeneric as NSString: encodedIdentifier,
            kSecAttrAccount as NSString: encodedIdentifier,
            kSecAttrService as NSString: serviceName
            ])
        return searchDictionary
    }
    
    func searchKeychainCopyMatching(_ identifier : String) -> Data{
        let searchDictionary = newSearchDictionary(identifier)
        searchDictionary.addEntries(from: [
            kSecMatchLimit as NSString: kSecMatchLimitOne as NSString,
            kSecReturnPersistentRef as NSString: true
            ])
        
        var result: CFTypeRef? = nil
        SecItemCopyMatching(searchDictionary as CFMutableDictionary, &result)
        return result as! Data
    }
    
    func createKeychainValue(_ password: String, _ identifier: String) -> Bool{
        let dictionary = newSearchDictionary(identifier)
        var status: OSStatus = SecItemDelete(dictionary as CFMutableDictionary)
        let passwordData: Data = password.data(using: .utf8)!
        dictionary.setObject(passwordData, forKey: kSecValueData as NSString)
        status = SecItemAdd(dictionary as CFDictionary, nil)
        return status == errSecSuccess
    }

}


//
//  ViewController.swift
//  FileSharingApp
//
//  Created by Rajneesh on 27/04/21.
//  Copyright © 2021 BRRV. All rights reserved.
//

import Cocoa
import MultipeerConnectivity


class ViewController: NSViewController {
    var pathToShare : String?
   
    lazy var peerID: MCPeerID = {
        let peer: MCPeerID

        if let peerData = UserDefaults.standard.data(forKey: "mePeerID") {
            guard let unarchivedPeer = NSKeyedUnarchiver.unarchiveObject(with: peerData) as? MCPeerID else {
                fatalError("mePeerID in user defaults is not a MCPeerID. WHAT?")
            }

            peer = unarchivedPeer
        } else {
            peer = MCPeerID(displayName: "PayPal")

            let peerData = NSKeyedArchiver.archivedData(withRootObject: peer)
            UserDefaults.standard.set(peerData, forKey: "mePeerID")
            UserDefaults.standard.synchronize()
        }

        return peer
    }()

    // MD2
    lazy var session: MCSession = {
        let s = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)

        s.delegate = self

        return s
    }()

    // MD4
    lazy var advertiser: MCNearbyServiceAdvertiser = {
        let a = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: ["demo": "data"], serviceType: "MultipeerDemo")

        a.delegate = self

        return a
    }()

    // MD7
    lazy var browser: MCNearbyServiceBrowser = {
        let b = MCNearbyServiceBrowser(peer: peerID, serviceType: "MultipeerDemo")

        b.delegate = self

        return b
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
    }

    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    @IBAction func SelectFileForSharing(_ sender: Any) {
           selectFile()
       }
    @IBAction func sendFileItem(_ sender: Any) {
        print(pathToShare!)
        
        if session.connectedPeers.count > 0 {
            
        }
        
    }
    
    
    func selectFile() {
        let dialog = NSOpenPanel();

        dialog.title                   = "Choose a file| Our Code World";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.allowsMultipleSelection = false;
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file

            if (result != nil) {
                if let path = result?.path {
                    pathToShare = path
                    print(path)
                }
            }
            
        } else {
            // User clicked on "Cancel"
            return
        }
    }
}

extension ViewController: MCSessionDelegate, MCBrowserViewControllerDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")

        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")

        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
//        if let image = UIImage(data: data) {
//            DispatchQueue.main.async { [unowned self] in
//                // do something with the image
//            }
//        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(true)
    }
    
    
}
extension ViewController: MCNearbyServiceAdvertiserDelegate {

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // This is insecure! We should verify that the peer is valid and etc etc
        invitationHandler(true, session)
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("Woops! Advertising failed with error \(String(describing: error))")
    }

}

extension ViewController: MCNearbyServiceBrowserDelegate {

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print(peerID.displayName)
        DispatchQueue.main.async {
            browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("Puke")
    }

}

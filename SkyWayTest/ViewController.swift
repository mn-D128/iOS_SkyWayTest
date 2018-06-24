//
//  ViewController.swift
//  SkyWayTest
//
//  Created by Masanori Nakano on 2018/06/23.
//  Copyright © 2018年 D128. All rights reserved.
//

import UIKit
import SkyWay

class ViewController: UIViewController {
    
    @IBOutlet private weak var identifierFld: UITextField!
    @IBOutlet private weak var destIdentifierFld: UITextField!
    
    private var peer: SKWPeer?
    private var stream: SKWMediaStream?
    private var connection: SKWMediaConnection?
    
    private var remoteStream: SKWMediaStream?
    private var remoteConnection: SKWMediaConnection?
    
    
    // MARK: - UIViewController
    
    // MARK: - Private
    
    private func setCallback(_ connection: SKWMediaConnection) {
        connection.on(SKWMediaConnectionEventEnum.MEDIACONNECTION_EVENT_STREAM,
                      callback: { [weak self] obj in
                        print("MEDIACONNECTION_EVENT_STREAM")
        })
        
        connection.on(SKWMediaConnectionEventEnum.MEDIACONNECTION_EVENT_REMOVE_STREAM,
                      callback: { [weak self] obj in
                        print("MEDIACONNECTION_EVENT_REMOVE_STREAM")
        })
        
        connection.on(SKWMediaConnectionEventEnum.MEDIACONNECTION_EVENT_CLOSE,
                      callback: { [weak self] obj in
                        print("MEDIACONNECTION_EVENT_CLOSE")
        })
        
        connection.on(SKWMediaConnectionEventEnum.MEDIACONNECTION_EVENT_REMOVE_STREAM,
                      callback: { [weak self] obj in
                        print("MEDIACONNECTION_EVENT_REMOVE_STREAM")
        })
    }
    
    private func createStream(_ peer: SKWPeer) -> SKWMediaStream? {
        let constraints: SKWMediaConstraints = SKWMediaConstraints()
        constraints.videoFlag = false
        
        SKWNavigator.initialize(peer)
        return SKWNavigator.getUserMedia(constraints)
    }

    // MARK: - Action
    
    @IBAction private func connectDidTap(_ sender: Any) {
        guard let text = self.identifierFld.text,
            0 < text.utf8.count else {
            return
        }
        
        let option: SKWPeerOption = SKWPeerOption()
        option.key = ""
        option.domain = ""
        option.debug = SKWDebugLevelEnum.DEBUG_LEVEL_ALL_LOGS
        
        self.peer = SKWPeer(id: text, options: option)!
        
        self.peer?.on(SKWPeerEventEnum.PEER_EVENT_CALL,
                  callback: { [weak self] obj in
                    print("PEER_EVENT_CALL")
                    
                    guard let weakSelf = self else {
                        return
                    }
                    
                    guard let connection: SKWMediaConnection = obj as? SKWMediaConnection else {
                        return
                    }
                    
                    guard let stream: SKWMediaStream = weakSelf.createStream(weakSelf.peer!) else {
                        return
                    }
                    
//                    let option: SKWAnswerOption = SKWAnswerOption()
                    
                    connection.answer(stream)
                    
                    weakSelf.remoteStream = stream
                    weakSelf.remoteConnection = connection
        })
        
        self.peer?.on(SKWPeerEventEnum.PEER_EVENT_ERROR,
                  callback: { [weak self] obj in
                    guard let error: SKWPeerError = obj as? SKWPeerError else {
                        return
                    }
                    
                    print("PEER_EVENT_ERROR \(error)")
        })
        
        self.peer?.on(SKWPeerEventEnum.PEER_EVENT_CLOSE,
                  callback: { [weak self] _ in
                    print("PEER_EVENT_CLOSE")
        })
        
        self.peer?.on(SKWPeerEventEnum.PEER_EVENT_DISCONNECTED,
                  callback: { [weak self] _ in
                    print("PEER_EVENT_DISCONNECTED")
        })
        
        let callback: SKWPeerEventCallback = { [weak self] obj in
            guard let ownId = obj as? String else {
                return
            }
            
            print("ownId = \(ownId)")
        }
        
        self.peer?.on(SKWPeerEventEnum.PEER_EVENT_OPEN,
                     callback: callback)
    }
    
    @IBAction private func callDidTap(_ sender: Any) {
        guard let text = self.destIdentifierFld.text,
            0 < text.utf8.count else {
                return
        }
        
        guard let stream: SKWMediaStream = createStream(self.peer!) else {
            return
        }
        
        self.stream = stream
        
        // SKWCallOption
        guard let connection: SKWMediaConnection = self.peer?.call(withId: text, stream: stream, options: nil) else {
            return
        }
        self.connection = connection
        setCallback(connection)
    }
    
}


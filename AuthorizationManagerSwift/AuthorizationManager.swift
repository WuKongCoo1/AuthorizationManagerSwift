//
//  AuthorizationManager.swift
//  AuthorizationManagerSwift
//
//  Created by Jacky on 2018/10/31.
//  Copyright © 2018 FinupGroup. All rights reserved.
//  摄像头、麦克风、相册、通讯录、定位

import UIKit
import AVFoundation
import Photos
import Contacts
import CoreLocation

enum LocationAuthorizationType {
    case aways //一直获取
    case WhenInUse //仅在使用期间
}

typealias WKLocationHandler = (Bool, CLLocation?) -> Void
typealias WKAuthorizationHandler = (Bool) -> Void

class AuthorizationManager: NSObject, CLLocationManagerDelegate {
    
    //定位
    lazy var locationManager: CLLocationManager = {
        let cm = CLLocationManager.init()
        cm.delegate = self
        return cm
    }()
    var locationAuthType : LocationAuthorizationType? = nil
    
    var locationClosure: WKLocationHandler?
    //通讯录
    lazy var contactStore = CNContactStore.init()
    
    //单例
    private class var sharedManager: AuthorizationManager {
        struct Static {
            static let sharedInstance : AuthorizationManager = AuthorizationManager()
        }
        return Static.sharedInstance
    }
    
    
    /// 请求摄像头权限
    ///
    /// - Parameter handler: 回调 true代表有权限 false 代表无权限
    class func checkCameraAuthorization(completionHandler handler:  WKAuthorizationHandler? = nil) -> () {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            handler?(true)
            print("function:  \(#function)" + " authorized")
        case .notDetermined://未申请过摄像头权限
            AVCaptureDevice.requestAccess(for: .video) { (result) in
                handler?(result)
                if result == true {
                    print("function:  \(#function)" + " authorized")
                }else {
                    print("function:  \(#function)" + " unauthorized")
                }
            }
        default:
            handler?(false)
            print("function:  \(#function)" + " unauthorized")
        }
        
        
    }
    
    //麦克风权限
   class func checkAudioAuthorization(completionHandler handler: @escaping (Bool) -> Void) -> () {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.audio) {
        case .authorized:
            handler(true)
            print("function:  \(#function)" + " authorized")
        case .notDetermined://未申请过麦克风权限
            AVCaptureDevice.requestAccess(for: .audio) { (result) in
                handler(result)
                if result == true {
                    print("function:  \(#function)" + " authorized")
                }else {
                    print("function:  \(#function)" + " unauthorized")
                }
            }
        default:
            handler(false)
            print("function:  \(#function)" + " unauthorized")
        }
    }
    
    //相册权限
    class func checkPhotoAutorization(completionHandler handler: @escaping (Bool) -> Void) -> () {
        
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == PHAuthorizationStatus.authorized {
                    handler(true)
                    print("function:  \(#function)" + " authorized")
                }else {
                    handler(false)
                    print("function:  \(#function)" + " unauthorized")
                }
            }
        case .authorized:
            print("function:  \(#function)" + " authorized")
            handler(true)
        default:
            handler(false)
            print("function:  \(#function)" + " unauthorized")
        }
        
    }
    
    //联系人权限
    class func checkContactsAuthorization(completionHandler handler: @escaping (Bool) -> Void) -> () {
        
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            handler(true)
            print("function:  \(#function)" + " authorized")
        case .notDetermined:
            self.sharedManager.contactStore.requestAccess(for: .contacts) { (result, error) in
                handler(result)
                if result == true {
                    print("function:  \(#function)" + " authorized")
                }else {
                    print("function:  \(#function)" + " unauthorized")
                }
            }
        default:
            print("function:  \(#function)" + " unauthorized")
            handler(false)
        }
    }
    
    //位置权限
    class func checkLocationAutorization(locationType type: LocationAuthorizationType ,completionHandler handler: @escaping WKLocationHandler) -> () {
        sharedManager.locationClosure = handler
        sharedManager.locationAuthType = type
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .notDetermined:
            if type == .aways {
                sharedManager.locationManager.requestAlwaysAuthorization()
            } else {
                sharedManager.locationManager.requestWhenInUseAuthorization()
            }
        case .authorizedWhenInUse,
             .authorizedAlways:
            self.sharedManager.estimateLocationAuthResult(status)
        
        
        default:
            print("function:  \(#function)" + " unauthorized")
            handler(false, nil)
        }
    }
}

//位置处理
extension AuthorizationManager {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            self .estimateLocationAuthResult(status)
        }else if(status != .notDetermined){
            self.locationClosure?(false, nil)
            print("function:  \(#function)" + " unauthorized")
        }
    }
    
    func estimateLocationAuthResult(_ result: CLAuthorizationStatus) -> Void {
        let targetAuthType = LocationAuthorizationType.aways == self.locationAuthType ? CLAuthorizationStatus.authorizedAlways : CLAuthorizationStatus.authorizedWhenInUse
        let authResult = targetAuthType == result
        let resultDesc = authResult ? " authorized" : " unauthorized"
        print("function:  \(#function)" + resultDesc)
        self.locationClosure?(authResult, nil)
    }
}

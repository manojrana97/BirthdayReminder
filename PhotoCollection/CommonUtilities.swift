//
//  CommonUtilities.swift
//  Tokr
//
//  Created by parvinderjit on 06/09/16.
//  Copyright © 2016 Zapbuild. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC
import Security
import CoreLocation
import MapKit

class CommonUtilities {
  
    
    class func showUnknownErrorAlert(_ controller:UIViewController,callback:(()->())? = nil){
        AlertUtility.showAlert(controller, title: nil, message: "Something went wrong, please try after sometime", cancelButton: "OK",buttons: nil){ (alertAction, index) in
            callback?()
        }
    }
    class func convertJsonToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                Logger.log(error.localizedDescription)
            }
        }
        return nil
    }
    class func showUnknownErrorAlert(_ controller:UIViewController, retry:@escaping ()->()){
        AlertUtility.showAlert(controller, title: nil, message: "Something went wrong, please retry", cancelButton: "Retry", buttons: nil) { (alertAction, index) in
            retry()
        }
        
    }
    class func showComingSoonAlert(_ controller:UIViewController){
        AlertUtility.showAlert(controller, title: nil, message: "Coming Soon", cancelButton: "OK", buttons: nil, actions: nil)
    }
    
    
    class func openSettings() {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(URL(string:UIApplication.openSettingsURLString)!)
        }
    }
    
    
    //  class func getTodaysDate () -> String{
    //    let todaysDate = NSDate()
    //    let dateFormatter = DateFormatter()
    //    dateFormatter.dateFormat = Constants.DateFormats.dateWithFullTime
    //    let dateString = dateFormatter.string(from: todaysDate as Date)
    //    return dateString as String
    //  }
    
}



class AlertUtility {
    
    static let CancelButtonIndex = -1;
    
    class func showAlert(_ onController:UIViewController!, title:String?,message:String? ) {
        showAlert(onController, title: title, message: message, cancelButton: "OK", buttons: nil, actions: nil)
    }
    
    /**
     - parameter title:        title for the alert
     - parameter message:      message for alert
     - parameter cancelButton: title for cancel button
     - parameter buttons:      array of string for title for other buttons
     - parameter actions:      action is the callback which return the action and index of the button which was pressed
     */
    
    
    class func showAlert(_ onController:UIViewController!, type:UIAlertController.Style! = .alert, title:String?,message:String? = nil ,cancelButton:String = "OK",buttons:[String]? = nil,actions:((_ alertAction:UIAlertAction,_ index:Int)->())? = nil) {
        // make sure it would be run on  main queue
        let alertController = UIAlertController(title: title, message: message, preferredStyle: type)
        
        let action = UIAlertAction(title: cancelButton, style: UIAlertAction.Style.cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
            actions?(action,CancelButtonIndex)
        }
        
        alertController.addAction(action)
        if let _buttons = buttons {
            for button in _buttons {
                let action = UIAlertAction(title: button, style: .default) { (action) in
                    let index = _buttons.index(of: action.title!)
                    actions?(action,index!)
                }
                alertController.addAction(action)
            }
        }
        DispatchQueue.main.async {
            onController.present(alertController, animated: true, completion: nil)
        }
    }
    
    class func showDeleteAlert(_ onController:UIViewController!, type:UIAlertController.Style! = .alert, title:String?,message:String? = nil ,cancelButton:String = "OK",buttons:[String]? = nil,actions:((_ alertAction:UIAlertAction,_ index:Int)->())? = nil) {
        // make sure it would be run on  main queue
        let alertController = UIAlertController(title: title, message: message, preferredStyle: type)
        
        let action = UIAlertAction(title: cancelButton, style: .default) { (action) in
            alertController.dismiss(animated: true, completion: nil)
            actions?(action,CancelButtonIndex)
        }
        alertController.addAction(action)
        if let _buttons = buttons {
            for button in _buttons {
                let action = UIAlertAction(title: button, style: .destructive) { (action) in
                    let index = _buttons.index(of: action.title!)
                    actions?(action,index!)
                }
                alertController.addAction(action)
            }
        }
        onController.present(alertController, animated: true, completion: nil)
    }
    
    
    
    
    class func showAlertWithTextField(_ onController: UIViewController!, title: String? = nil, message: String? = nil, placeholder: String? = nil, completion: @escaping ((String) -> Void) = { _ in }) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField() { newTextField in
            newTextField.placeholder = placeholder
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completion("") })
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in
            if
                let textFields = alert.textFields,
                let tf = textFields.first,
                let result = tf.text
            { completion(result) }
            else
            { completion("") }
        })
        onController.present(alert, animated: true, completion: nil)
    }
    
    class func showAlertForSubscription(_ onController:UIViewController!, message: String, isCancelButton:Bool, actions:((_ alertAction:UIAlertAction,_ index:Int)->())? = nil ) {
        let alertController = UIAlertController(title: "Subscribe", message: message, preferredStyle: .alert)
        
        if isCancelButton {
            let action = UIAlertAction(title: "Cancel", style: .default) { (action) in
                alertController.dismiss(animated: true, completion: nil)
                actions?(action,CancelButtonIndex)
            }
            alertController.addAction(action)
        }
        
        let action = UIAlertAction(title: "Upgrade", style: .default) { (action) in
            actions?(action,0)
        }
        alertController.addAction(action)
        onController.present(alertController, animated: true, completion: nil)
    }
    
    
}

class ToastUtility{
    static let toastTag = -99
    static var isToastRemoved = false
    class func showToast(message : String, controller: UIViewController) {
        let toastLabel = UILabel(frame: CGRect(x: controller.view.frame.size.width/2 - 150, y: controller.view.frame.size.height-200, width: 300, height: 35))
        toastLabel.tag = toastTag
        //toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        controller.view.addSubview(toastLabel)
        isToastRemoved = false
        controller.view.bringSubviewToFront(toastLabel)
        UIView.animate(withDuration: 3.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            if !isToastRemoved {
                toastLabel.removeFromSuperview()
            }
        })
    }
    class func removeToast(from viewController: UIViewController) {
        if let toastView = viewController.view.viewWithTag(toastTag) {
            toastView.removeFromSuperview()
            isToastRemoved = true
        }
    }
    
    
}

@IBDesignable
class SpinnerView : UIView {
    
    override var layer: CAShapeLayer {
        get {
            return super.layer as! CAShapeLayer
        }
    }
    
    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.fillColor = nil
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 3
        setPath()
    }
    
    override func didMoveToWindow() {
        animate()
    }
    
    private func setPath() {
        layer.path = UIBezierPath(ovalIn: bounds.insetBy(dx: layer.lineWidth / 2, dy: layer.lineWidth / 2)).cgPath
    }
    
    struct Pose {
        let secondsSincePriorPose: CFTimeInterval
        let start: CGFloat
        let length: CGFloat
        init(_ secondsSincePriorPose: CFTimeInterval, _ start: CGFloat, _ length: CGFloat) {
            self.secondsSincePriorPose = secondsSincePriorPose
            self.start = start
            self.length = length
        }
    }
    
    class var poses: [Pose] {
        get {
            return [
                Pose(0.0, 0.000, 0.7),
                Pose(0.6, 0.500, 0.5),
                Pose(0.6, 1.000, 0.3),
                Pose(0.6, 1.500, 0.1),
                Pose(0.2, 1.875, 0.1),
                Pose(0.2, 2.250, 0.3),
                Pose(0.2, 2.625, 0.5),
                Pose(0.2, 3.000, 0.7),
            ]
        }
    }
    
    func animate() {
        var time: CFTimeInterval = 0
        var times = [CFTimeInterval]()
        var start: CGFloat = 0
        var rotations = [CGFloat]()
        var strokeEnds = [CGFloat]()
        
        let poses = type(of: self).poses
        let totalSeconds = poses.reduce(0) { $0 + $1.secondsSincePriorPose }
        
        for pose in poses {
            time += pose.secondsSincePriorPose
            times.append(time / totalSeconds)
            start = pose.start
            rotations.append(start * 2 * .pi)
            strokeEnds.append(pose.length)
        }
        
        times.append(times.last!)
        rotations.append(rotations[0])
        strokeEnds.append(strokeEnds[0])
        
        animateKeyPath(keyPath: "strokeEnd", duration: totalSeconds, times: times, values: strokeEnds)
        animateKeyPath(keyPath: "transform.rotation", duration: totalSeconds, times: times, values: rotations)
        
        //animateStrokeHueWithDuration(duration: totalSeconds * 5)
    }
    
    func animateKeyPath(keyPath: String, duration: CFTimeInterval, times: [CFTimeInterval], values: [CGFloat]) {
        let animation = CAKeyframeAnimation(keyPath: keyPath)
        animation.keyTimes = times as [NSNumber]?
        animation.values = values
        //animation.calculationMode = .linear
        animation.duration = duration
        animation.repeatCount = Float.infinity
        layer.add(animation, forKey: animation.keyPath)
    }
    
}




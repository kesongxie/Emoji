//
//  ViewController.swift
//  Emoji
//
//  Created by Xie kesong on 3/21/17.
//  Copyright © 2017 ___KesongXie___. All rights reserved.
//

import UIKit

class CanvasViewController: UIViewController {
    @IBOutlet weak var arrowBtn: UIButton!

    @IBOutlet weak var trayView: UIView!
    @IBAction func arrowBtnTapped(_ sender: UIButton) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    
    var originalCenter: CGPoint!
    var createdFace: UIImageView?{
        didSet{
            self.createdFace?.isUserInteractionEnabled = true
        }
    }

    lazy var createdFaceList = [UIImageView]()
    
    
    @IBAction func draggingEmoji(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: nil)
        switch sender.state{
        case .changed:
            if self.createdFace == nil{
                if let faceImageView = sender.view as? UIImageView{
                    self.createdFace = UIImageView(image: faceImageView.image)
                    self.createdFace?.contentMode = .scaleAspectFit
                    self.createdFace?.frame = faceImageView.frame
                    print(faceImageView.center)
                    self.originalCenter = faceImageView.convert(faceImageView.center, to: nil)
                      self.createdFace?.center = originalCenter
                    self.view.addSubview(self.createdFace!)
                }
            }
            
            let scaleTransform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.createdFace!.center = CGPoint(x: self.originalCenter.x + translation.x, y: self.originalCenter.y + translation.y)
            self.createdFace?.transform = scaleTransform
        case .ended:
            if let newlyFace = self.createdFace{
                if newlyFace.frame.origin.y + newlyFace.frame.size.height > self.view.frame.height - self.trayView.frame.size.height{
                    UIView.animate(withDuration:0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options:[] ,
                                   animations: { () -> Void in
                                    self.createdFace?.transform = .identity
                                    self.createdFace?.center = self.originalCenter
                    }, completion: {
                        finished in
                        if finished{
                            self.createdFace?.removeFromSuperview()
                            self.createdFace = nil
                            self.originalCenter = CGPoint(x: 0, y: 0)
                        }
                    })
                }else{
                    if let face = self.createdFace{
                        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                            face.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
                        }, completion: nil)
                        
                        //pin gesture
                        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinching(_:)))
                        face.addGestureRecognizer(pinchGesture)
                        

                        //pan gesture
                        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(createdFacePanned(_:)))
                        face.addGestureRecognizer(panGesture)
                        
                        //rotation gesture
                        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(createdFaceRoatated(_:)))
                       // face.addGestureRecognizer(rotationGesture)
                        
                        
                        rotationGesture.delegate = self;

                        self.newFaceCenter = face.center
                        
                        self.createdFaceList.insert(face, at: 0)
                        self.createdFace = nil
                    }
                }
                
            }
            default:
            break
        }
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    func pinching(_ gesture: UIPinchGestureRecognizer){
        if let view = gesture.view {
            view.transform = view.transform.scaledBy(x: gesture.scale, y: gesture.scale)
            gesture.scale = 1
        }
    }
    
    var newFaceCenter: CGPoint!
    
    
    func createdFacePanned(_ gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: nil)
        switch gesture.state{
        case .began:
            self.newFaceCenter = gesture.view?.center
        case .changed:
              gesture.view!.center = CGPoint(x: self.newFaceCenter.x + translation.x, y: self.newFaceCenter.y + translation.y)
        default:
            break
        }
    }
    
    func createdFaceRoatated(_ gesture: UIRotationGestureRecognizer){
        let rotation = gesture.rotation
        let imageView = gesture.view as! UIImageView
        print(rotation)
        imageView.transform = CGAffineTransform(rotationAngle: rotation)
        gesture.rotation = 0
    }
    
    
    
    @IBAction func dragging(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: nil)
        switch sender.state{
        case .changed:
            self.bottomSpace.constant = max(min(self.bottomSpace.constant - translation.y, 0), -110)
            UIView.animate(withDuration:0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options:[] ,
                           animations: { () -> Void in
                            self.view.layoutIfNeeded()
            }, completion: nil)
            var transfrom: CGAffineTransform

            if sender.velocity(in: nil).y > 0{
                self.bottomSpace.constant = -110
                transfrom = .identity
            }else{
                self.bottomSpace.constant = 0
                transfrom = CGAffineTransform(rotationAngle: CGFloat.pi)
            }
            UIView.animate(withDuration:0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options:[] ,
                           animations: { () -> Void in
                            self.arrowBtn.transform = transfrom
                            self.view.layoutIfNeeded()
                            
            }, completion: nil)
            
            
            
        case .ended:
            print("ended")
        default:
            break
        }
        
        
    }

}

extension CanvasViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}


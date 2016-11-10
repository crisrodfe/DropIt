//
//  DropItView.swift
//  DropIt
//
//  Created by Cristina Rodriguez Fernandez on 28/7/16.
//  Copyright © 2016 CrisRodFe. All rights reserved.
//

import UIKit
import CoreMotion

//Toda la lógica estará en esta clase

class DropItView: NamedBezierPathsView, UIDynamicAnimatorDelegate
{
    // Número de bloques que cabrán en una fila
    fileprivate let dropsPerRow = 10
    
    
    // Tamaño de los bloques
    fileprivate var dropSize: CGSize
    {
            let size = bounds.size.width / CGFloat(dropsPerRow)
        
        return CGSize(width:size, height: size)
    }
    
    
    fileprivate let dropBehavior = FallingObjectBehavior()
    
    fileprivate lazy var animator: UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: self)
        animator.delegate = self
        return animator
    }()
    
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        removeCompletedRow()
    }
    
    //Buscará en la línea si todos los huecos están ocupados por un bloque, si es así eliminará la fila
    //Llamaremos a este método cuando todo el efecto rebote pare.
    fileprivate func removeCompletedRow()
    {
        var dropsToRemove = [UIView]()
        
        var hitTestRect = CGRect(origin: bounds.lowerLeft, size: dropSize)
        repeat {
            hitTestRect.origin.x = bounds.minX
            hitTestRect.origin.y -= dropSize.height
            var dropsTested = 0
            var dropsFound = [UIView]()
            while dropsTested < dropsPerRow {
                if let hitView = hitTest(hitTestRect.mid) , hitView.superview == self {
                    dropsFound.append(hitView)
                } else {
                    break
                }
                hitTestRect.origin.x += dropSize.width
                dropsTested += 1
            }
            if dropsTested == dropsPerRow {
                dropsToRemove += dropsFound
            }
        } while dropsToRemove.count == 0 && hitTestRect.origin.y > bounds.minY
        
        for drop in dropsToRemove {
            dropBehavior.removeItem(drop)
            drop.removeFromSuperview()
        }
    }
    
    //Creamos un obstáculo en medio de la View
    fileprivate struct PathName {
        static let MiddleBarrier = "Middle Barrier"
        static let Attachment = "Attachment"
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath(ovalIn: CGRect(center: bounds.mid, size: dropSize))
        dropBehavior.addBarrier(path, named: PathName.MiddleBarrier)
        bezierPath[PathName.MiddleBarrier] = path
    }
    
    //Añadirá a la View un bloque
    func addDrop()
    {
        var frame = CGRect(origin: CGPoint.zero,size: dropSize)
        frame.origin.x = CGFloat.random(dropsPerRow) * dropSize.width //Creará aleatoriamente el lugar por donde aparece el bloque
        
        let drop = UIView(frame: frame)
        drop.backgroundColor = UIColor.random
        
        addSubview(drop)
        
        dropBehavior.addItem(drop)
        
        lastDrop = drop
    }
    
    var animating: Bool = false {
        didSet {
            if animating {
                animator.addBehavior(dropBehavior)
            } else {
                animator.removeBehavior(dropBehavior)
            }
        }
    }
    
    //Creacion de el gesto que hará que al poner el dedo el cuadradito quede enganchado a él y podamos moverlo
    fileprivate var attachment: UIAttachmentBehavior? {
        
        willSet { // Si ya hay uno enganchado lo quitamos
            if attachment != nil {
                animator.removeBehavior(attachment!)
                bezierPath[PathName.Attachment] = nil
            }
        }
        
        didSet {
            if attachment != nil {
                animator.addBehavior(attachment!)
                attachment!.action = { [unowned self ] in 
                    if let attachedDrop = self.attachment!.items.first as? UIView {
                        self.bezierPath[PathName.Attachment] =
                            UIBezierPath.lineFrom(self.attachment!.anchorPoint, to: attachedDrop.center)
                    }
                }
            }
        }
    }
    
    fileprivate var lastDrop: UIView? // Cada vez que añadamos un bloque más arriba, sera considerado lastDrop y sera el q podamos coger
    
    func grabDrop(_ recognizer: UIPanGestureRecognizer) {
        let gesturePoint = recognizer.location(in: self)
        
        switch recognizer.state
        {
            case .began:
                if let dropToAttachTo = lastDrop , dropToAttachTo.superview != nil {
                    attachment = UIAttachmentBehavior (item: dropToAttachTo, attachedToAnchor: gesturePoint)
            }
            lastDrop = nil
            case .changed:
                attachment?.anchorPoint = gesturePoint
            default: attachment = nil
        }
    }
    
    //Haremos que lo bloques caigan segun la gravedad, no simplemente hacia el Home button
    var realGravity: Bool = false {
        didSet {
            updateRealGravity()
        }
    }
    
    fileprivate let motionManager = CMMotionManager()
    
    fileprivate func updateRealGravity()
    {
        if realGravity {
            if motionManager.isAccelerometerAvailable && !motionManager.isAccelerometerActive {
                motionManager.accelerometerUpdateInterval = 0.25
                motionManager.startAccelerometerUpdates(to: OperationQueue.main)
                { [unowned self] (data, error) in
                    if self.dropBehavior.dynamicAnimator != nil
                    {
                        if var dx = data?.acceleration.x , var dy = data?.acceleration.y {
                            switch UIDevice.current.orientation {
                                case .portrait: dy = -dy
                                case .portraitUpsideDown : break
                                case .landscapeRight: swap (&dx,&dy)
                                case .landscapeLeft: swap(&dx, &dy); dy = -dy
                                default: dx = 0; dy = 0;
                            }
                            
                            self.dropBehavior.gravity.gravityDirection = CGVector(dx: dx, dy: dy)
                        }
                    } else {
                        self.motionManager.stopAccelerometerUpdates()
                    }
                }
            }
        } else {
            motionManager.stopAccelerometerUpdates()
        }
    }
}

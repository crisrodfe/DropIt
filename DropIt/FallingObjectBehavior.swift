//
//  FallingObjectBehavior.swift
//  DropIt
//
//  Created by Cristina Rodriguez Fernandez on 28/7/16.
//  Copyright © 2016 CrisRodFe. All rights reserved.
//

import UIKit

//Esta clase encapsula los comportamientos que queremos que tengan nuestros bloques: gravedad, colisión, y comportamiento de cada bloque cuendo colisiona con otro

//Además tiene un método con el que se puede añadir un obstáculo a la View con el que los bloques colisionarán

class FallingObjectBehavior: UIDynamicBehavior
{
    let gravity = UIGravityBehavior()
    
    fileprivate let collider:  UICollisionBehavior = {
        let collider = UICollisionBehavior()
        collider.translatesReferenceBoundsIntoBoundary = true
        return collider
    }()
    
    fileprivate let itemBehavior: UIDynamicItemBehavior = {
       let dib = UIDynamicItemBehavior()
        dib.allowsRotation = false //No girarán
        dib.elasticity = 0.75 //Efecto rebote
        
        return dib
    }()
    
    func addBarrier(_ path: UIBezierPath, named name: String)
    {
        collider.removeBoundary(withIdentifier: name as NSCopying) //Si ya hay uno, antes lo eliminamos
        collider.addBoundary(withIdentifier: name as NSCopying, for: path)
    }
    
    override init()
    {
        super.init()
        addChildBehavior(gravity)
        addChildBehavior(collider)
        addChildBehavior(itemBehavior)
    }
    
    func addItem(_ item: UIDynamicItem)
    {
        gravity.addItem(item)
        collider.addItem(item)
        itemBehavior.addItem(item)
    }
    
    func removeItem(_ item: UIDynamicItem)
    {
        gravity.removeItem(item)
        collider.removeItem(item)
        itemBehavior.removeItem(item)
    }
}

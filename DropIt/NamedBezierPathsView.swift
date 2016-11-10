//
//  NamedBezierPathsView.swift
//  DropIt
//
//  Created by Cristina Rodriguez Fernandez on 28/7/16.
//  Copyright © 2016 CrisRodFe. All rights reserved.
//

import UIKit

//Crea un BezierPath 

class NamedBezierPathsView: UIView
{

    var bezierPath = [String: UIBezierPath]() {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        for (_, path) in bezierPath {
            path.stroke()
            path.fill()
        }
    }
}

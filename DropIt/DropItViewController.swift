//
//  DropItViewController.swift
//  DropIt
//
//  Created by Cristina Rodriguez Fernandez on 28/7/16.
//  Copyright © 2016 CrisRodFe. All rights reserved.
//

import UIKit

//Aqui controlaremos los gestos y el ciclo de vida

class DropItViewController: UIViewController
{
    //Cada vez que hacemos tap, se ejecutará el método que crea un bloque
    
    @IBOutlet weak var gameView: DropItView!
    {
        didSet {
            gameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addDrop(_:))))
            gameView.addGestureRecognizer(UIPanGestureRecognizer(target: gameView, action: #selector(DropItView.grabDrop(_:))))
            gameView.realGravity = true
        }
    }
    
    func addDrop(_ recognizer: UITapGestureRecognizer)
    {
        if recognizer.state == .ended {
            gameView.addDrop()
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        gameView.animating = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        gameView.animating = false
    }
    
    
}

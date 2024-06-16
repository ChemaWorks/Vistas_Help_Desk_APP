//
//  HomeViewController.swift
//  612_help_desk
//
//  Created by Braulio Alejandro Navarrete Horta on 28/05/24.
//

import UIKit

class AdminViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    @IBAction func logout(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "nombreUsuario")
        UserDefaults.standard.removeObject(forKey: "apellidoUsuario")
        UserDefaults.standard.removeObject(forKey: "tipoUsuario")
        UserDefaults.standard.removeObject(forKey: "correoUsuario")
        UserDefaults.standard.synchronize()
        self.performSegue(withIdentifier: "AuthView", sender: self)
    }
}

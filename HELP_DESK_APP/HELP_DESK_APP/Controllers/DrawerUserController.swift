import UIKit

class DrawerUserController: UIViewController {

    @IBOutlet weak var lblNombreUsuario: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Recuperar los datos del usuario desde UserDefaults
        if let nombre = UserDefaults.standard.string(forKey: "nombreUsuario"),
           let apellido = UserDefaults.standard.string(forKey: "apellidoUsuario") {
            lblNombreUsuario.setTitle("\(nombre) \(apellido)", for: .normal)
        } else {
            lblNombreUsuario.setTitle("Nombre de usuario", for: .normal)
        }
    }
    
    @IBAction func cerrarSesion(_ sender: Any) {
        // Limpiar los datos del usuario de UserDefaults
        UserDefaults.standard.removeObject(forKey: "nombreUsuario")
        UserDefaults.standard.removeObject(forKey: "apellidoUsuario")
        UserDefaults.standard.removeObject(forKey: "tipoUsuario")
        UserDefaults.standard.removeObject(forKey: "correoUsuario")
        UserDefaults.standard.synchronize()
        
        // Volver a la pantalla de inicio de sesión
        self.performSegue(withIdentifier: "Logout", sender: self)
    }
    
    
    @IBAction func irPerfil(_ sender: Any) {
        self.performSegue(withIdentifier: "UserData", sender: self)
    }
}

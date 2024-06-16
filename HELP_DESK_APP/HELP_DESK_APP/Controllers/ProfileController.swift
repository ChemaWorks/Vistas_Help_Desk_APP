import UIKit

class ProfileController: UIViewController {

    @IBOutlet weak var lblMatricula: UILabel!
    @IBOutlet weak var lblNombre: UILabel!
    @IBOutlet weak var lblApellido: UILabel!
    @IBOutlet weak var lblCorreo: UILabel!
    @IBOutlet weak var lblContrasena: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Recuperar los datos del usuario desde UserDefaults
        if let nombre = UserDefaults.standard.string(forKey: "nombreUsuario"),
           let apellido = UserDefaults.standard.string(forKey: "apellidoUsuario"),
           let correo = UserDefaults.standard.string(forKey: "correoUsuario"),
           let contrasena = UserDefaults.standard.string(forKey: "contrasenaUsuario"),
           let matricula = UserDefaults.standard.string(forKey: "matriculaUsuario") {
            
            lblNombre.text = nombre
            lblApellido.text = apellido
            lblCorreo.text = correo
            lblContrasena.text = contrasena
            lblMatricula.text = matricula
        } else {
            lblNombre.text = "Nombre"
            lblApellido.text = "Apellido"
            lblCorreo.text = "Correo"
            lblContrasena.text = "Contraseña"
            lblMatricula.text = "Matricula"
        }
    }
}

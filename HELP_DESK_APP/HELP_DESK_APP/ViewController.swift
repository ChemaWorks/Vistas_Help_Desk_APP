import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var txtCorreo: UITextField!
    @IBOutlet weak var txtContraseña: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btnIniciarSesion(_ sender: Any) {
        guard let username = txtCorreo.text, !username.isEmpty else {
            showAlert(message: "User not found, try again.")
            return
        }
        
        guard let password = txtContraseña.text, !password.isEmpty else {
            showAlert(message: "Password incorrect, try again.")
            return
        }
        
        validarLogin(user: username, password: password) { success, user in
            DispatchQueue.main.async {
                print("Resultado de la validación: \(success)")
                if success, let user = user {
                    // Almacenar los datos del usuario en UserDefaults
                    UserDefaults.standard.set(user.nombre, forKey: "nombreUsuario")
                    UserDefaults.standard.set(user.apellido, forKey: "apellidoUsuario")
                    UserDefaults.standard.set(user.tipo, forKey: "tipoUsuario")
                    UserDefaults.standard.set(user.correo, forKey: "correoUsuario")
                    UserDefaults.standard.set(user.matricula, forKey: "matriculaUsuario")
                    UserDefaults.standard.set(user.contraseña, forKey: "contrasenaUsuario")
                    UserDefaults.standard.synchronize()
                    
                    // Login exitoso, realizar segue basado en el tipo de usuario
                    print("Login exitoso, realizando segue")
                    if user.tipo == "Alumno" {
                        self.performSegue(withIdentifier: "StudentDashboard", sender: self)
                    } else {
                        self.performSegue(withIdentifier: "showAdminScreen", sender: self)
                    }
                } else {
                    // Login fallido, mostrar alerta
                    print("Login fallido, mostrando alerta")
                    self.showAlert(message: "Usuario o contraseña incorrectos, intenta de nuevo.")
                }
            }
        }
    }
    
    private func validarLogin(user: String, password: String, completion: @escaping (Bool, Usuario?) -> Void) {
        let loginEndpoint = "/usuario/login?correo=\(user)&contraseña=\(password)"
        let urlString = APIConfig.baseURL + loginEndpoint
        guard let url = URL(string: urlString) else {
            print("URL inválida")
            completion(false, nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error en la petición: \(error)")
                completion(false, nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Código de estado HTTP: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 401 {
                    print("Credenciales incorrectas")
                    completion(false, nil)
                    return
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("Respuesta del servidor inválida: \(response.debugDescription)")
                    completion(false, nil)
                    return
                }
            }
            
            if let data = data {
                do {
                    let user = try JSONDecoder().decode(Usuario.self, from: data)
                    completion(true, user)
                } catch let parsingError {
                    print("Error al parsear los datos: \(parsingError)")
                    completion(false, nil)
                }
            } else {
                print("No se recibió ningún dato del servidor.")
                completion(false, nil)
            }
        }
        task.resume()
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "ERROR", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true, completion: nil)
    }
}

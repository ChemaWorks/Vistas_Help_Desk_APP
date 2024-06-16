import UIKit

class RegisterTecnicoController: UIViewController {

   
    @IBOutlet weak var txtNombre: UITextField!
    
    @IBOutlet weak var txtApellido: UITextField!
    
    @IBOutlet weak var txtCorreo: UITextField!
    
    @IBOutlet weak var txtContraseña: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func registrarTecnico(_ sender: Any) {
        guard let nombre = txtNombre.text, !nombre.isEmpty,
              let apellido = txtApellido.text, !apellido.isEmpty,
              let correo = txtCorreo.text, !correo.isEmpty,
              let contraseña = txtContraseña.text, !contraseña.isEmpty else {
            showAlert(message: "Todos los campos son obligatorios.")
            return
        }

        let nuevoAlumno = Usuario(nombre: nombre, apellido: apellido, correo: correo, tipo: "Técnico", contraseña: contraseña)
        registrarUsuario(usuario: nuevoAlumno) { success in
            DispatchQueue.main.async {
                if success {
                    self.showAlert(message: "Técnico registrado exitosamente.")
                    self.limpiarCampos()
                } else {
                    self.showAlert(message: "Error al registrar el técnico. Inténtalo de nuevo.")
                }
            }
        }
    }
     

    private func registrarUsuario(usuario: Usuario, completion: @escaping (Bool) -> Void) {
        guard let nombreCodificado = usuario.nombre.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let apellidoCodificado = usuario.apellido.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let correoCodificado = usuario.correo.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let contraseñaCodificada = usuario.contraseña.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Error al codificar los parámetros")
            completion(false)
            return
        }
        
        let queryParams = "nombre=\(nombreCodificado)&apellido=\(apellidoCodificado)&correo=\(correoCodificado)&tipo=Técnico&contraseña=\(contraseñaCodificada)"
        let registerEndpoint = "/usuario/register_user?\(queryParams)"
        let urlString = APIConfig.baseURL + registerEndpoint
        print("URL de registro: \(urlString)") // Línea de depuración
        guard let url = URL(string: urlString) else {
            print("URL inválida")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error en la petición: \(error)")
                completion(false)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("No se pudo obtener la respuesta HTTP")
                completion(false)
                return
            }

            if !(200...299).contains(httpResponse.statusCode) {
                print("Respuesta del servidor inválida")
                print("Código de estado: \(httpResponse.statusCode)")
                if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                    print("Cuerpo de la respuesta: \(responseBody)")
                }
                print("Encabezados: \(httpResponse.allHeaderFields)")
                completion(false)
                return
            }

            completion(true)
        }
        task.resume()
    }

    private func limpiarCampos() {
        txtNombre.text = ""
        txtApellido.text = ""
        txtCorreo.text = ""
        txtContraseña.text = ""
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Información", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true, completion: nil)
    }
}

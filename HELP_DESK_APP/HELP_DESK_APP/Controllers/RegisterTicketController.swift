import UIKit

class RegisterTicketController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var txtEnunciado: UILabel!
    @IBOutlet weak var txtTitulo: UITextField!
    @IBOutlet weak var txtDescripcion: UITextView!
    @IBOutlet weak var pickerUbicacion: UIPickerView!
    @IBOutlet weak var pickerCategoria: UIPickerView!
    @IBOutlet weak var pickerPrioridad: UIPickerView!
    @IBOutlet weak var btnRegistrar: UIButton!

    var ticketToEdit: Ticket?

    let ubicaciones = ["Edificio A", "Edificio B", "Edificio C", "Edificio D", "Edificio E", "Edificio F", "Edificio G", "Edificio H", "Edificio I", "Edificio J", "Edificio K", "Edificio L", "Edificio M", "Edificio N", "Edificio O", "Edificio P", "Edificio Q", "Edificio R", "Edificio S", "Edificio T", "Edificio U", "Edificio V", "Edificio W", "Edificio X", "Edificio Y", "Edificio Z"]
    let categorias = ["Infraestructura", "Electrico", "Personal", "Red", "Servicio"]
    let prioridades = ["Baja", "Media", "Alta"]

    override func viewDidLoad() {
        super.viewDidLoad()

        pickerUbicacion.delegate = self
        pickerUbicacion.dataSource = self
        pickerCategoria.delegate = self
        pickerCategoria.dataSource = self
        pickerPrioridad.delegate = self
        pickerPrioridad.dataSource = self

        if let ticket = ticketToEdit {
            configureForEditing(ticket)
        }
    }

    private func configureForEditing(_ ticket: Ticket) {
        txtEnunciado.text = "Actualizar Ticket"
        btnRegistrar.setTitle("Actualizar", for: .normal)
        txtTitulo.text = ticket.titulo
        txtDescripcion.text = ticket.descripcion
        if let ubicacionIndex = ubicaciones.firstIndex(of: ticket.ubicacion) {
            pickerUbicacion.selectRow(ubicacionIndex, inComponent: 0, animated: false)
        }
        if let categoriaIndex = categorias.firstIndex(of: ticket.categoria) {
            pickerCategoria.selectRow(categoriaIndex, inComponent: 0, animated: false)
        }
        if let prioridadIndex = prioridades.firstIndex(of: ticket.prioridad) {
            pickerPrioridad.selectRow(prioridadIndex, inComponent: 0, animated: false)
        }
    }

    @IBAction func registrarTicket(_ sender: Any) {
        guard let titulo = txtTitulo.text, !titulo.isEmpty,
              let descripcion = txtDescripcion.text, !descripcion.isEmpty else {
            showAlert(message: "Todos los campos son obligatorios.")
            return
        }

        let ubicacion = ubicaciones[pickerUbicacion.selectedRow(inComponent: 0)]
        let categoria = categorias[pickerCategoria.selectedRow(inComponent: 0)]
        let prioridad = prioridades[pickerPrioridad.selectedRow(inComponent: 0)]
        let idAlumno = UserDefaults.standard.integer(forKey: "idUsuario")

        guard idAlumno != 0 else {
            showAlert(message: "No se pudo obtener el ID del alumno.")
            return
        }

        if let ticket = ticketToEdit {
            let updatedTicket = Ticket(idTicket: ticket.idTicket, titulo: titulo, descripcion: descripcion, ubicacion: ubicacion, categoria: categoria, prioridad: prioridad, estado: ticket.estado, fechaCreacion: ticket.fechaCreacion, fechaActualizacion: ticket.fechaActualizacion, idAlumno: ticket.idAlumno, idTecnico: ticket.idTecnico)
            actualizarTicket(ticket: updatedTicket) { success in
                DispatchQueue.main.async {
                    if success {
                        self.showAlert(message: "Ticket actualizado exitosamente.")
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.showAlert(message: "Error al actualizar el ticket. Inténtalo de nuevo.")
                    }
                }
            }
        } else {
            let nuevoTicket = Ticket(idTicket: 0, titulo: titulo, descripcion: descripcion, ubicacion: ubicacion, categoria: categoria, prioridad: prioridad, estado: "Nuevo", fechaCreacion: "", fechaActualizacion: "", idAlumno: idAlumno, idTecnico: 0)
            registrarTicket(ticket: nuevoTicket) { success in
                DispatchQueue.main.async {
                    if success {
                        self.showAlert(message: "Ticket registrado exitosamente.")
                        self.limpiarCampos()
                    } else {
                        self.showAlert(message: "Error al registrar el ticket. Inténtalo de nuevo.")
                    }
                }
            }
        }
    }

    private func registrarTicket(ticket: Ticket, completion: @escaping (Bool) -> Void) {
        guard let tituloCodificado = ticket.titulo.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let descripcionCodificada = ticket.descripcion.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let ubicacionCodificada = ticket.ubicacion.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let categoriaCodificada = ticket.categoria.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let prioridadCodificada = ticket.prioridad.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Error al codificar los parámetros")
            completion(false)
            return
        }

        let queryParams = "titulo=\(tituloCodificado)&descripcion=\(descripcionCodificada)&ubicacion=\(ubicacionCodificada)&categoria=\(categoriaCodificada)&prioridad=\(prioridadCodificada)&estado=Nuevo&idAlumno=\(ticket.idAlumno)"
        let registerEndpoint = "/ticket/register_ticket?\(queryParams)"
        let urlString = APIConfig.baseURL + registerEndpoint
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
                completion(false)
                return
            }

            completion(true)
        }
        task.resume()
    }

    private func actualizarTicket(ticket: Ticket, completion: @escaping (Bool) -> Void) {
        guard let tituloCodificado = ticket.titulo.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let descripcionCodificada = ticket.descripcion.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let ubicacionCodificada = ticket.ubicacion.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let categoriaCodificada = ticket.categoria.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let prioridadCodificada = ticket.prioridad.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Error al codificar los parámetros")
            completion(false)
            return
        }

        let queryParams = "idTicket=\(ticket.idTicket)&titulo=\(tituloCodificado)&descripcion=\(descripcionCodificada)&ubicacion=\(ubicacionCodificada)&categoria=\(categoriaCodificada)&prioridad=\(prioridadCodificada)&estado=\(ticket.estado)&idAlumno=\(ticket.idAlumno)"
        let updateEndpoint = "/ticket/update_ticket?\(queryParams)"
        let urlString = APIConfig.baseURL + updateEndpoint
        guard let url = URL(string: urlString) else {
            print("URL inválida")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

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
                completion(false)
                return
            }

            completion(true)
        }
        task.resume()
    }

    private func limpiarCampos() {
        txtTitulo.text = ""
        txtDescripcion.text = ""
        pickerUbicacion.selectRow(0, inComponent: 0, animated: false)
        pickerCategoria.selectRow(0, inComponent: 0, animated: false)
        pickerPrioridad.selectRow(0, inComponent: 0, animated: false)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Información", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true, completion: nil)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case pickerUbicacion:
            return ubicaciones.count
        case pickerCategoria:
            return categorias.count
        case pickerPrioridad:
            return prioridades.count
        default:
            return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case pickerUbicacion:
            return ubicaciones[row]
        case pickerCategoria:
            return categorias[row]
        case pickerPrioridad:
            return prioridades[row]
        default:
            return nil
        }
    }
}

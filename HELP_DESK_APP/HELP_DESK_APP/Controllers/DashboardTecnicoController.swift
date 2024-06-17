import UIKit

class DashboardTecnicoController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnGuardar: UIButton!
    
    var tickets: [Ticket] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        fetchTickets()
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TicketTableTecnicoViewCell.self, forCellReuseIdentifier: "TicketTableTecnicoViewCell")
    }
    
    private func fetchTickets() {
        guard let idTecnico = UserDefaults.standard.value(forKey: "idUsuario") as? Int else {
            showAlert(message: "No se pudo obtener el ID del técnico.")
            return
        }
        
        let ticketsEndpoint = "/usuario/get_tickets_by_tecnico?idTecnico=\(idTecnico)"
        let urlString = APIConfig.baseURL + ticketsEndpoint
        guard let url = URL(string: urlString) else {
            print("URL inválida")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error en la petición: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Código de estado HTTP: \(httpResponse.statusCode)")
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("Respuesta del servidor inválida: \(response.debugDescription)")
                    return
                }
            }
            
            if let data = data {
                do {
                    self.tickets = try JSONDecoder().decode([Ticket].self, from: data)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } catch let parsingError {
                    print("Error al parsear los datos: \(parsingError)")
                }
            } else {
                print("No se recibió ningún dato del servidor.")
            }
        }
        task.resume()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tickets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TicketTableTecnicoViewCell", for: indexPath) as! TicketTableTecnicoViewCell
        let ticket = tickets[indexPath.row]
        
        cell.ticketIDLabel.text = "ID Ticket: \(ticket.idTicket)"
        cell.tituloLabel.text = "Título: \(ticket.titulo)"
        cell.descripcionLabel.text = "Descripción: \(ticket.descripcion)"
        cell.ubicacionLabel.text = "Ubicación: \(ticket.ubicacion)"
        cell.categoriaLabel.text = "Categoría: \(ticket.categoria)"
        cell.prioridadLabel.text = "Prioridad: \(ticket.prioridad)"
        
        if let index = cell.estados.firstIndex(of: ticket.estado) {
            cell.estadoPicker.selectRow(index, inComponent: 0, animated: false)
        }
        
        return cell
    }
    
    // MARK: - Actions
    
    @IBAction func guardarCambios(_ sender: Any) {
        for (index, ticket) in tickets.enumerated() {
            if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? TicketTableTecnicoViewCell {
                let selectedEstado = cell.estados[cell.estadoPicker.selectedRow(inComponent: 0)]
                var updatedTicket = ticket
                updatedTicket.estado = selectedEstado
                updateTicket(updatedTicket) { success in
                    DispatchQueue.main.async {
                        if success {
                            self.showAlert(message: "Estado actualizado exitosamente.")
                        } else {
                            self.showAlert(message: "Error al actualizar el estado. Inténtalo de nuevo.")
                        }
                    }
                }
            }
        }
    }
    
    private func updateTicket(_ ticket: Ticket, completion: @escaping (Bool) -> Void) {
        guard let tituloCodificado = ticket.titulo.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let descripcionCodificada = ticket.descripcion.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let ubicacionCodificada = ticket.ubicacion.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let categoriaCodificada = ticket.categoria.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let prioridadCodificada = ticket.prioridad.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let estadoCodificado = ticket.estado.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Error al codificar los parámetros")
            completion(false)
            return
        }

        let queryParams = "idTicket=\(ticket.idTicket)&titulo=\(tituloCodificado)&descripcion=\(descripcionCodificada)&ubicacion=\(ubicacionCodificada)&categoria=\(categoriaCodificada)&prioridad=\(prioridadCodificada)&estado=\(estadoCodificado)&idAlumno=\(ticket.idAlumno)&idTecnico=\(ticket.idTecnico ?? 0)"
        let updateEndpoint = "/ticket/update_ticket/?\(queryParams)"
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

    // MARK: - Helper Methods
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Información", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true, completion: nil)
    }
}

import UIKit
class DashboardAdminController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnGuardar: UIButton!

    var tickets: [Ticket] = []
    var tecnicos: [Usuario] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        fetchTickets()
        fetchTecnicos()
    }

    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TicketTableAdminViewCell.self, forCellReuseIdentifier: "TicketTableAdminViewCell")
    }

    private func fetchTickets() {
        let ticketsEndpoint = "/ticket/get_all_tickets"
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

    private func fetchTecnicos() {
        let tecnicosEndpoint = "/usuario/get_all_users"
        let urlString = APIConfig.baseURL + tecnicosEndpoint
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
                    let usuarios = try JSONDecoder().decode([Usuario].self, from: data)
                    self.tecnicos = usuarios.filter { $0.tipo == "Técnico" }
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tickets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TicketTableAdminViewCell", for: indexPath) as! TicketTableAdminViewCell
        let ticket = tickets[indexPath.row]
        cell.configure(with: ticket, tecnicos: tecnicos)
        return cell
    }

    @IBAction func guardarCambios(_ sender: Any) {
        for (index, ticket) in tickets.enumerated() {
            if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? TicketTableAdminViewCell {
                if let selectedTecnico = cell.selectedTecnico {
                    var updatedTicket = ticket
                    updatedTicket.idTecnico = selectedTecnico.idUsuario
                    updateTicket(updatedTicket)
                }
            }
        }
    }

    private func updateTicket(_ ticket: Ticket) {
        guard let idTecnico = ticket.idTecnico else {
            print("idTecnico es nil")
            return
        }

        let updateEndpoint = "/ticket/update_ticket/?idTicket=\(ticket.idTicket)&titulo=\(ticket.titulo)&descripcion=\(ticket.descripcion)&ubicacion=\(ticket.ubicacion)&categoria=\(ticket.categoria)&prioridad=\(ticket.prioridad)&estado=\(ticket.estado)&idAlumno=\(ticket.idAlumno)&idTecnico=\(idTecnico)"
        let urlString = APIConfig.baseURL + updateEndpoint
        guard let url = URL(string: urlString) else {
            print("URL inválida")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

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

            DispatchQueue.main.async {
                self.showAlert(message: "Ticket actualizado correctamente.")
            }
        }
        task.resume()
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Información", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true, completion: nil)
    }
}

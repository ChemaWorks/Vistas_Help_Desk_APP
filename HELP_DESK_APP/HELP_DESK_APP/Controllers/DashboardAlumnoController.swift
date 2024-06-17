import UIKit

class DashboardAlumnoController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnAddTicket: UIButton!

    var tickets: [Ticket] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureFloatingButton()
        fetchTickets()
    }

    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TicketTableViewCell.self, forCellReuseIdentifier: "TicketTableViewCell")
    }

    private func configureFloatingButton() {
        btnAddTicket.layer.cornerRadius = btnAddTicket.frame.size.width / 2
        btnAddTicket.layer.shadowColor = UIColor.black.cgColor
        btnAddTicket.layer.shadowOffset = CGSize(width: 0, height: 2)
        btnAddTicket.layer.shadowRadius = 4
        btnAddTicket.layer.shadowOpacity = 0.3
        btnAddTicket.backgroundColor = UIColor.systemGreen

        btnAddTicket.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(btnAddTicket)

        NSLayoutConstraint.activate([
            btnAddTicket.widthAnchor.constraint(equalToConstant: 60),
            btnAddTicket.heightAnchor.constraint(equalToConstant: 60),
            btnAddTicket.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            btnAddTicket.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])

        btnAddTicket.addTarget(self, action: #selector(addTicket), for: .touchUpInside)
    }

    @objc private func addTicket() {
        performSegue(withIdentifier: "RegisterTicket", sender: nil)
    }

    private func fetchTickets() {
        guard let idAlumno = UserDefaults.standard.value(forKey: "idUsuario") as? Int else {
            showAlert(message: "No se pudo obtener el ID del alumno.")
            return
        }

        let ticketsEndpoint = "/usuario/get_tickets_by_alumno?idAlumno=\(idAlumno)"
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tickets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TicketTableViewCell", for: indexPath) as! TicketTableViewCell
        let ticket = tickets[indexPath.row]

        cell.ticketIDLabel.text = "ID Ticket: \(ticket.idTicket)"
        cell.tituloLabel.text = "Título: \(ticket.titulo)"
        cell.descripcionLabel.text = "Descripción: \(ticket.descripcion)"
        cell.ubicacionLabel.text = "Ubicación: \(ticket.ubicacion)"
        cell.categoriaLabel.text = "Categoría: \(ticket.categoria)"
        cell.prioridadLabel.text = "Prioridad: \(ticket.prioridad)"
        cell.estadoLabel.text = "Estado: \(ticket.estado)"

        cell.accionEditarButton.tag = indexPath.row
        cell.accionEditarButton.addTarget(self, action: #selector(editarTicket(_:)), for: .touchUpInside)

        cell.accionDeleteButton.tag = indexPath.row
        cell.accionDeleteButton.addTarget(self, action: #selector(eliminarTicket(_:)), for: .touchUpInside)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    @objc func editarTicket(_ sender: UIButton) {
        let ticket = tickets[sender.tag]
        performSegue(withIdentifier: "UpdateTicket", sender: ticket)
    }

    @objc func eliminarTicket(_ sender: UIButton) {
        let ticket = tickets[sender.tag]
        let alert = UIAlertController(title: "Eliminar Ticket", message: "¿Estás seguro de que deseas eliminar este ticket?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Eliminar", style: .destructive, handler: { _ in
            self.deleteTicket(ticket)
        }))
        present(alert, animated: true, completion: nil)
    }

    private func deleteTicket(_ ticket: Ticket) {
        let deleteEndpoint = "/ticket/delete_ticket/?idTicket=\(ticket.idTicket)"
        let urlString = APIConfig.baseURL + deleteEndpoint
        guard let url = URL(string: urlString) else {
            print("URL inválida")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error en la petición: \(error)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Respuesta del servidor inválida")
                return
            }

            DispatchQueue.main.async {
                if let index = self.tickets.firstIndex(where: { $0.idTicket == ticket.idTicket }) {
                    self.tickets.remove(at: index)
                    self.tableView.reloadData()
                }
            }
        }
        task.resume()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UpdateTicket",
           let destinationVC = segue.destination as? RegisterTicketController,
           let ticket = sender as? Ticket {
            destinationVC.ticketToEdit = ticket
        } else if segue.identifier == "RegisterTicket",
                  let destinationVC = segue.destination as? RegisterTicketController {
            destinationVC.ticketToEdit = nil
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Información", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true, completion: nil)
    }
}

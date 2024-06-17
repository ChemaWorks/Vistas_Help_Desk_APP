import UIKit

class TicketTableAdminViewCell: UITableViewCell {

    let ticketIDLabel = UILabel()
    let tituloLabel = UILabel()
    let descripcionLabel = UILabel()
    let ubicacionLabel = UILabel()
    let categoriaLabel = UILabel()
    let prioridadLabel = UILabel()
    let estadoLabel = UILabel()
    let tecnicoPicker = UIPickerView()

    var tecnicos: [Usuario] = []
    var selectedTecnico: Usuario?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        // Configura las vistas y añádelas a la celda
        let stackView = UIStackView(arrangedSubviews: [ticketIDLabel, tituloLabel, descripcionLabel, ubicacionLabel, categoriaLabel, prioridadLabel, estadoLabel, tecnicoPicker])
        stackView.axis = .vertical
        stackView.spacing = 8

        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        tecnicoPicker.delegate = self
        tecnicoPicker.dataSource = self
    }

    func configure(with ticket: Ticket, tecnicos: [Usuario]) {
        ticketIDLabel.text = "ID Ticket: \(ticket.idTicket)"
        tituloLabel.text = "Título: \(ticket.titulo)"
        descripcionLabel.text = "Descripción: \(ticket.descripcion)"
        ubicacionLabel.text = "Ubicación: \(ticket.ubicacion)"
        categoriaLabel.text = "Categoría: \(ticket.categoria)"
        prioridadLabel.text = "Prioridad: \(ticket.prioridad)"
        estadoLabel.text = "Estado: \(ticket.estado)"
        self.tecnicos = tecnicos
        if let idTecnico = ticket.idTecnico, let index = tecnicos.firstIndex(where: { $0.idUsuario == idTecnico }) {
            tecnicoPicker.selectRow(index, inComponent: 0, animated: false)
            selectedTecnico = tecnicos[index]
        }
        tecnicoPicker.reloadAllComponents()
    }
}

extension TicketTableAdminViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return tecnicos.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(tecnicos[row].nombre) \(tecnicos[row].apellido)"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedTecnico = tecnicos[row]
    }
}

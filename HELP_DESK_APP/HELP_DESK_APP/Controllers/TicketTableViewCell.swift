import UIKit

class TicketTableViewCell: UITableViewCell {

    let ticketIDLabel = UILabel()
    let tituloLabel = UILabel()
    let descripcionLabel = UILabel()
    let ubicacionLabel = UILabel()
    let categoriaLabel = UILabel()
    let prioridadLabel = UILabel()
    let estadoLabel = UILabel()
    let accionEditarButton = UIButton(type: .system)
    let accionDeleteButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        // Configura las vistas y añádelas a la celda
        accionEditarButton.setTitle("Editar", for: .normal)
        accionDeleteButton.setTitle("Eliminar", for: .normal)
        accionEditarButton.setTitleColor(.blue, for: .normal)
        accionDeleteButton.setTitleColor(.blue, for: .normal)
        
        let stackView = UIStackView(arrangedSubviews: [ticketIDLabel, tituloLabel, descripcionLabel, ubicacionLabel, categoriaLabel, prioridadLabel, estadoLabel, accionEditarButton, accionDeleteButton])
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
    }
}

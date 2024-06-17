import UIKit

class TicketCell: UITableViewCell {
    
    
    
    @IBOutlet weak var ticketIDLabel: UILabel!
    @IBOutlet weak var tituloLabel: UILabel!
    @IBOutlet weak var descripcionLabel: UILabel!
    @IBOutlet weak var ubicacionLabel: UILabel!
    @IBOutlet weak var categoriaLabel: UILabel!
    @IBOutlet weak var prioridadLabel: UILabel!
    
    
    @IBOutlet weak var estadoLabel: UILabel!
    
    
    
    @IBOutlet weak var accionEditarButton: UIButton!

    @IBOutlet weak var accionDeleteButton: UIButton!
}

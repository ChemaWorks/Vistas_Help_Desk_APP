import Foundation

struct Ticket: Codable {
    var idTicket: Int
    var titulo: String
    var descripcion: String
    var ubicacion: String
    var categoria: String
    var prioridad: String
    var estado: String
    var fechaCreacion: String?
    var fechaActualizacion: String?
    var idAlumno: Int
    var idTecnico: Int?
    
    
    enum CodingKeys: String, CodingKey {
            case idTicket = "idTicket"
            case titulo = "titulo"
            case descripcion = "descripcion"
            case ubicacion = "ubicacion"
            case categoria = "Categoria"  // Clave JSON con mayúscula
            case prioridad = "prioridad"
            case estado = "Estado"  // Clave JSON con mayúscula
            case fechaCreacion = "fechaCreacion"
            case fechaActualizacion = "fechaActualizacion"
            case idAlumno = "Id_Alumno"  // Clave JSON con mayúscula y guion bajo
            case idTecnico = "Id_Tecnico"  // Clave JSON con mayúscula y guion bajo
        }
}

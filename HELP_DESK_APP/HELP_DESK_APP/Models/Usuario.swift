import Foundation

struct Usuario: Codable {
    var idUsuario: Int?
    var nombre: String
    var apellido: String
    var correo: String
    var tipo: String
    var contraseña: String
    var matricula: Int?
    var fechaCreacion: String?
    var fechaActualizacion: String?

    init(idUsuario: Int? = nil, nombre: String, apellido: String, correo: String, tipo: String, contraseña: String, matricula: Int? = nil, fechaCreacion: String? = nil, fechaActualizacion: String? = nil) {
        self.idUsuario = idUsuario
        self.nombre = nombre
        self.apellido = apellido
        self.correo = correo
        self.tipo = tipo
        self.contraseña = contraseña
        self.matricula = matricula
        self.fechaCreacion = fechaCreacion
        self.fechaActualizacion = fechaActualizacion
    }
}

// A1. Seleccionar la base de datos SaborYa.
use saborya

// A2. Contar los documentos de cada colección.
db.restaurantes.countDocuments()
db.clientes.countDocuments()
db.productos.countDocuments()
db.pedidos.countDocuments()


// A3. Insertar el restaurante R11 en Medellín.
db.restaurantes.insertOne({
  _id: "R11",
  nombre: "Café Arriero",
  categoria: "Cafetería",
  ciudad: "Medellín",
  barrio: "Laureles",
  calificacion: 4.5,
  domicilio: true,
  ubicacion: {
    type: "Point",
    coordinates: [-75.5925, 6.2442]
  },
  etiquetas: ["café", "postres"]
})


// A4. Insertar los dos productos del restaurante R11.
db.productos.insertMany([
  {
    _id: "P25",
    restaurante_id: "R11",
    nombre: "Tinto campesino",
    categoria: "bebida",
    precio: 3500,
    stock: 100,
    disponible: true,
    volumen_ml: 200
  },
  {
    _id: "P26",
    restaurante_id: "R11",
    nombre: "Torta de zanahoria",
    categoria: "postre",
    precio: 9000,
    stock: 20,
    disponible: true
  }
])

// A5. Consultar los restaurantes ubicados en Medellín.
db.restaurantes.find(
  { ciudad: "Medellín" }
)

// Contar los productos asociados al restaurante R11.
db.productos.countDocuments(
  { restaurante_id: "R11" }
)

// B1. verificar que todos los pedidos tengan la fecha de tipo date
db.pedidos.countDocuments({
  fecha: { $not: { $type: "date" } }
})
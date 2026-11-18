// A1 - revisar bd y colecciones
use saborya
db
show collections

// A2 - conteo inicial de documentos
db.restaurantes.countDocuments()
db.clientes.countDocuments()
db.productos.countDocuments()
db.pedidos.countDocuments()

// A3 - insertar restaurante R11
db.restaurantes.insertOne({
  _id: "R11",
  nombre: "Café Arriero",
  categoria: "Cafetería",
  ciudad: "Medellín",
  barrio: "Laureles",
  calificacion: 4.5,
  domicilio: true,
  ubicacion: { type: "Point", coordinates: [-75.5925, 6.2442] },
  etiquetas: ["café", "postres"]
})

// A4 - productos del R11
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

// A5 - consulta medellin y conteo productos R11
db.restaurantes.find({ ciudad: "Medellín" })
db.productos.countDocuments({ restaurante_id: "R11" })


// B1 - validar tipos de dato en fecha y precio
db.pedidos.countDocuments({ fecha: { $not: { $type: "date" } } })
db.productos.countDocuments({ precio: { $type: "string" } })

// B2 - justificacion coleccion aparte para resenas
// Se dejan en una coleccion aparte porque un restaurante puede acumular demasiadas resenas con el tiempo y el documento podria crecer mucho hasta acercarse al limite de 16 MB. Ademas, normalmente en la app solo se muestran el promedio, el total y las ultimas resenas, asi que es mas practico consultarlas aparte sin traer todo el documento del restaurante. Del cliente solo se guarda id y nombre porque casi nunca cambian y alcanzan para mostrar quien comento.

// B3 - crear coleccion resenas con validacion
db.createCollection("resenas", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["restaurante_id", "cliente", "calificacion", "texto", "fecha"],
      properties: {
        restaurante_id: { bsonType: "string" },
        cliente: {
          bsonType: "object",
          required: ["id", "nombre"],
          properties: {
            id: { bsonType: "string" },
            nombre: { bsonType: "string" }
          }
        },
        calificacion: { bsonType: "int", minimum: 1, maximum: 5 },
        texto: { bsonType: "string", minLength: 5 },
        fecha: { bsonType: "date" },
        fotos: { bsonType: "array", maxItems: 4, items: { bsonType: "string" } }
      }
    }
  }
})

// B4 - insertar 4 resenas
db.resenas.insertMany([
  {
    restaurante_id: "R02",
    cliente: { id: "C01", nombre: "Laura Gómez" },
    calificacion: 5,
    texto: "El ramen llegó caliente y bien empacado",
    fecha: new Date("2026-10-15T20:10:00-05:00")
  },
  {
    restaurante_id: "R02",
    cliente: { id: "C08", nombre: "Julián Castro" },
    calificacion: 4,
    texto: "Buen sushi, pero tardó 50 minutos",
    fecha: new Date("2026-10-16T21:30:00-05:00")
  },
  {
    restaurante_id: "R10",
    cliente: { id: "C07", nombre: "Daniela Martínez" },
    calificacion: 5,
    texto: "La cazuela es abundante",
    fotos: ["https://cdn.saborya.co/r/301.jpg", "https://cdn.saborya.co/r/302.jpg"],
    fecha: new Date("2026-10-17T13:45:00-05:00")
  },
  {
    restaurante_id: "R04",
    cliente: { id: "C03", nombre: "Valentina Ríos" },
    calificacion: 2,
    texto: "Las papas llegaron frías",
    fecha: new Date("2026-10-18T19:05:00-05:00")
  }
])

// B5 - prueba de error con calificacion 6 (debe fallar)
db.resenas.insertOne({
  restaurante_id: "R01",
  cliente: { id: "C01", nombre: "Laura Gómez" },
  calificacion: 6,
  texto: "Excelente servicio y comida",
  fecha: new Date("2026-10-19T12:00:00-05:00")
})

// B6 - resenas de C01 y resenas que tengan fotos
db.resenas.find({ "cliente.id": "C01" })
db.resenas.find({ fotos: { $exists: true, $ne: [] } })

// B7 - calcular promedio/total de R02 y guardarlo en el restaurante
db.resenas.aggregate([
  { $match: { restaurante_id: "R02" } },
  { $group: { _id: "$restaurante_id", promedio: { $avg: "$calificacion" }, total: { $sum: 1 } } }
])

db.restaurantes.updateOne(
  { _id: "R02" },
  { $set: { resumen_resenas: { promedio: 4.5, total: 2 } } }
)

// B8 - restaurantes con resenas
db.resenas.distinct("restaurante_id")


// C1 - platos disponibles con stock < 20
db.productos.find({ categoria: "plato", disponible: true, stock: { $lt: 20 } }, { nombre: 1, stock: 1, _id: 0 }).sort({ stock: 1 })

// C2 - pedidos entre 50k y 80k en efectivo o nequi
db.pedidos.find(
  { total: { $gte: 50000, $lte: 80000 }, metodo_pago: { $in: ["efectivo", "nequi"] } },
  { total: 1, metodo_pago: 1, _id: 0 }
)

// C3 - top 3 restaurantes de Bogota
db.restaurantes.find({ ciudad: "Bogotá" }, { nombre: 1, calificacion: 1, _id: 0 }).sort({ calificacion: -1 }).limit(3)

// C4 - clientes de Bogota con mas de 100 puntos
db.clientes.find({ ciudad: "Bogotá", puntos: { $gt: 100 } })

// C5 - pedidos del 12 al 14 de oct no entregados
db.pedidos.find({
  fecha: {
    $gte: new Date("2026-10-12T00:00:00-05:00"),
    $lte: new Date("2026-10-14T23:59:59-05:00")
  },
  estado: { $ne: "entregado" }
})

// C6 - comparacion con $elemMatch vs sin $elemMatch
db.pedidos.find({
  items: { $elemMatch: { precio: { $lt: 10000 }, cantidad: { $gte: 2 } } }
})

db.pedidos.find({
  "items.precio": { $lt: 10000 },
  "items.cantidad": { $gte: 2 }
})

// C7 - pagina 2 ordenada por precio descendente
db.productos.find().sort({ precio: -1, _id: 1 }).skip(6).limit(6)

// C8 - restaurantes con horario o menu_vegano
db.restaurantes.find({
  $or: [{ horario: { $exists: true } }, { menu_vegano: { $exists: true } }]
})


// D1 - subir 1000 a platos de R07
db.productos.updateMany({ restaurante_id: "R07", categoria: "plato" }, { $inc: { precio: 1000 } })

// D2 - cambiar PD018 a en_camino solo si esta pendiente (se corre 2 veces)
db.pedidos.updateOne({ _id: "PD018", estado: "pendiente" }, { $set: { estado: "en_camino" } })
db.pedidos.updateOne({ _id: "PD018", estado: "pendiente" }, { $set: { estado: "en_camino" } })

// D3 - agregar japonesa a C03 sin duplicar (se corre 2 veces)
db.clientes.updateOne({ _id: "C03" }, { $addToSet: { preferencias: "japonesa" } })
db.clientes.updateOne({ _id: "C03" }, { $addToSet: { preferencias: "japonesa" } })

// D4 - insertar a Natalia Suarez si no existe por email
db.clientes.updateOne(
  { email: "natalia.suarez@example.com" },
  {
    $setOnInsert: {
      _id: "C09",
      nombre: "Natalia Suárez",
      ciudad: "Medellín",
      puntos: 0,
      direcciones: []
    }
  },
  { upsert: true }
)

// D5 - quitar volumen_ml de P06
db.productos.updateOne({ _id: "P06" }, { $unset: { volumen_ml: "" } })

// D6 - borrar resenas con calificacion menor a 3
db.resenas.countDocuments({ calificacion: { $lt: 3 } })
db.resenas.deleteMany({ calificacion: { $lt: 3 } })

// D7 - borrar pedidos cancelados de Medellin
db.pedidos.countDocuments({ ciudad: "Medellín", estado: "cancelado" })
db.pedidos.deleteMany({ ciudad: "Medellín", estado: "cancelado" })

// D8 - conteo final de las 5 colecciones
db.restaurantes.countDocuments()
db.clientes.countDocuments()
db.productos.countDocuments()
db.pedidos.countDocuments()
db.resenas.countDocuments()
# Integrantes: [Completar con nombres del grupo]
# Archivo: datos.exs
# Módulo con los datos de prueba: repartidores, zonas y servicios.
# Los servicios incluyen casos válidos e inválidos mezclados para probar la validación.

defmodule Datos do
  # PURA - devuelve la lista de repartidores (11 en total, 5 con bicicleta)
  def repartidores do
    [
      %{codigo: "M01", nombre: "Ana Torres", bicicleta: true},
      %{codigo: "M02", nombre: "Carlos Mendoza", bicicleta: false},
      %{codigo: "M03", nombre: "Luisa Ramírez", bicicleta: true},
      %{codigo: "M04", nombre: "Jorge Patiño", bicicleta: false},
      %{codigo: "M05", nombre: "María López", bicicleta: true},
      %{codigo: "M06", nombre: "Diego Hernández", bicicleta: false},
      %{codigo: "M07", nombre: "Valentina Ríos", bicicleta: true},
      %{codigo: "M08", nombre: "Andrés Castaño", bicicleta: false},
      %{codigo: "M09", nombre: "Camila Vargas", bicicleta: false},
      %{codigo: "M10", nombre: "Santiago Moreno", bicicleta: false},
      %{codigo: "M11", nombre: "Paula Gil", bicicleta: true}
    ]
  end

  # PURA - devuelve la lista de zonas (4 zonas con áreas distintas)
  def zonas do
    [
      %{id: "Z1", nombre: "Centro", area: 6.5},
      %{id: "Z2", nombre: "Norte", area: 12.0},
      %{id: "Z3", nombre: "Sur", area: 8.3},
      %{id: "Z4", nombre: "Occidente", area: 15.7}
    ]
  end

  # PURA - devuelve la lista de todos los servicios (válidos e inválidos mezclados)
  # Total: 125 válidos + 16 inválidos = 141 servicios
  def servicios do
    servicios_validos() ++ servicios_invalidos()
  end

  # PURA - servicios que pasarán la validación (125 servicios)
  def servicios_validos do
    [
      # ===== M01 - Ana Torres (bici: true) =====
      # Tiene servicios en TODAS las 4 zonas (para R8)
      # Día 2: 85.5 km -> bonificación
      # Trabaja 6 días -> alquiler = 60000
      %{repartidor: "M01", zona: "Z1", dia: 1, kilometros: 25, retraso: -5},
      %{repartidor: "M01", zona: "Z2", dia: 1, kilometros: 20, retraso: 0},
      %{repartidor: "M01", zona: "Z1", dia: 2, kilometros: 30, retraso: -2},
      %{repartidor: "M01", zona: "Z2", dia: 2, kilometros: 28, retraso: 5},
      %{repartidor: "M01", zona: "Z4", dia: 2, kilometros: 27.5, retraso: 0},
      %{repartidor: "M01", zona: "Z1", dia: 3, kilometros: 22, retraso: 15},
      %{repartidor: "M01", zona: "Z3", dia: 3, kilometros: 18, retraso: 31},
      %{repartidor: "M01", zona: "Z2", dia: 4, kilometros: 20, retraso: 10},
      %{repartidor: "M01", zona: "Z4", dia: 4, kilometros: 15, retraso: 0},
      %{repartidor: "M01", zona: "Z1", dia: 5, kilometros: 25, retraso: -3},
      %{repartidor: "M01", zona: "Z3", dia: 5, kilometros: 20, retraso: 0},
      %{repartidor: "M01", zona: "Z2", dia: 5, kilometros: 22, retraso: 0},
      %{repartidor: "M01", zona: "Z1", dia: 6, kilometros: 20, retraso: 5},

      # ===== M02 - Carlos Mendoza (sin bici) =====
      # Solo 2 servicios válidos -> NO entra en R6 (necesita mínimo 3)
      %{repartidor: "M02", zona: "Z1", dia: 1, kilometros: 18, retraso: 3},
      %{repartidor: "M02", zona: "Z2", dia: 4, kilometros: 22, retraso: -1},

      # ===== M03 - Luisa Ramírez (bici: true) =====
      # Trabaja 6 días -> alquiler = 60000
      %{repartidor: "M03", zona: "Z1", dia: 1, kilometros: 20, retraso: 0},
      %{repartidor: "M03", zona: "Z3", dia: 1, kilometros: 18.5, retraso: 3},
      %{repartidor: "M03", zona: "Z1", dia: 2, kilometros: 25, retraso: -1},
      %{repartidor: "M03", zona: "Z3", dia: 2, kilometros: 18, retraso: 12},
      %{repartidor: "M03", zona: "Z2", dia: 3, kilometros: 30, retraso: 0},
      %{repartidor: "M03", zona: "Z1", dia: 3, kilometros: 22, retraso: 5},
      %{repartidor: "M03", zona: "Z3", dia: 4, kilometros: 20, retraso: 25},
      %{repartidor: "M03", zona: "Z1", dia: 4, kilometros: 25, retraso: 0},
      %{repartidor: "M03", zona: "Z1", dia: 5, kilometros: 18, retraso: 30},
      %{repartidor: "M03", zona: "Z2", dia: 5, kilometros: 22, retraso: 0},
      %{repartidor: "M03", zona: "Z1", dia: 6, kilometros: 15, retraso: 0},

      # ===== M04 - Jorge Patiño (sin bici) =====
      # Día 2: 82 km -> bonificación
      %{repartidor: "M04", zona: "Z2", dia: 1, kilometros: 22, retraso: -10},
      %{repartidor: "M04", zona: "Z3", dia: 1, kilometros: 18, retraso: 6},
      %{repartidor: "M04", zona: "Z1", dia: 2, kilometros: 35, retraso: 0},
      %{repartidor: "M04", zona: "Z2", dia: 2, kilometros: 25, retraso: 3},
      %{repartidor: "M04", zona: "Z3", dia: 2, kilometros: 22, retraso: -5},
      %{repartidor: "M04", zona: "Z1", dia: 3, kilometros: 25, retraso: 10},
      %{repartidor: "M04", zona: "Z2", dia: 3, kilometros: 28, retraso: 20},
      %{repartidor: "M04", zona: "Z1", dia: 4, kilometros: 30, retraso: 0},
      %{repartidor: "M04", zona: "Z3", dia: 4, kilometros: 22, retraso: -3},
      %{repartidor: "M04", zona: "Z3", dia: 5, kilometros: 30, retraso: 0},
      %{repartidor: "M04", zona: "Z1", dia: 5, kilometros: 15, retraso: 35},
      %{repartidor: "M04", zona: "Z2", dia: 5, kilometros: 25, retraso: -2},
      %{repartidor: "M04", zona: "Z2", dia: 6, kilometros: 20, retraso: 0},
      %{repartidor: "M04", zona: "Z1", dia: 6, kilometros: 22, retraso: -1},

      # ===== M05 - María López (bici: true) =====
      # Día 2: 83 km -> bonificación
      %{repartidor: "M05", zona: "Z2", dia: 2, kilometros: 30, retraso: -8},
      %{repartidor: "M05", zona: "Z3", dia: 2, kilometros: 25, retraso: 0},
      %{repartidor: "M05", zona: "Z1", dia: 2, kilometros: 28, retraso: 4},
      %{repartidor: "M05", zona: "Z1", dia: 3, kilometros: 20, retraso: 15},
      %{repartidor: "M05", zona: "Z2", dia: 3, kilometros: 18, retraso: 0},
      %{repartidor: "M05", zona: "Z3", dia: 4, kilometros: 22, retraso: 7},
      %{repartidor: "M05", zona: "Z1", dia: 4, kilometros: 15, retraso: -2},
      %{repartidor: "M05", zona: "Z2", dia: 5, kilometros: 25, retraso: 0},
      %{repartidor: "M05", zona: "Z3", dia: 5, kilometros: 20, retraso: -1},
      %{repartidor: "M05", zona: "Z1", dia: 5, kilometros: 22, retraso: 0},
      %{repartidor: "M05", zona: "Z2", dia: 6, kilometros: 20, retraso: 10},
      %{repartidor: "M05", zona: "Z3", dia: 6, kilometros: 18, retraso: 0},

      # ===== M06 - Diego Hernández (sin bici) =====
      # Día 4: 80 km exactos -> bonificación (>= 80)
      %{repartidor: "M06", zona: "Z1", dia: 1, kilometros: 30, retraso: 0},
      %{repartidor: "M06", zona: "Z2", dia: 1, kilometros: 25, retraso: -3},
      %{repartidor: "M06", zona: "Z3", dia: 1, kilometros: 15, retraso: 0},
      %{repartidor: "M06", zona: "Z3", dia: 2, kilometros: 35, retraso: 2},
      %{repartidor: "M06", zona: "Z1", dia: 2, kilometros: 20, retraso: 0},
      %{repartidor: "M06", zona: "Z2", dia: 3, kilometros: 25, retraso: 10},
      %{repartidor: "M06", zona: "Z1", dia: 3, kilometros: 20, retraso: 25},
      %{repartidor: "M06", zona: "Z3", dia: 4, kilometros: 30, retraso: 0},
      %{repartidor: "M06", zona: "Z2", dia: 4, kilometros: 22, retraso: -5},
      %{repartidor: "M06", zona: "Z1", dia: 4, kilometros: 28, retraso: -2},
      %{repartidor: "M06", zona: "Z1", dia: 5, kilometros: 28, retraso: 0},
      %{repartidor: "M06", zona: "Z3", dia: 5, kilometros: 20, retraso: 8},
      %{repartidor: "M06", zona: "Z2", dia: 5, kilometros: 22, retraso: 0},
      %{repartidor: "M06", zona: "Z2", dia: 6, kilometros: 15, retraso: 0},
      %{repartidor: "M06", zona: "Z1", dia: 6, kilometros: 20, retraso: 5},

      # ===== M07 - Valentina Ríos (bici: true) =====
      # Trabaja 6 días -> alquiler = 60000
      # Día 6: 45 km (empate con M10 para R5)
      %{repartidor: "M07", zona: "Z3", dia: 1, kilometros: 20, retraso: 0},
      %{repartidor: "M07", zona: "Z1", dia: 1, kilometros: 18, retraso: -7},
      %{repartidor: "M07", zona: "Z2", dia: 2, kilometros: 22, retraso: 0},
      %{repartidor: "M07", zona: "Z3", dia: 2, kilometros: 20, retraso: 3},
      %{repartidor: "M07", zona: "Z1", dia: 3, kilometros: 25, retraso: 0},
      %{repartidor: "M07", zona: "Z2", dia: 3, kilometros: 18, retraso: 0},
      %{repartidor: "M07", zona: "Z2", dia: 4, kilometros: 28, retraso: -1},
      %{repartidor: "M07", zona: "Z1", dia: 4, kilometros: 22, retraso: 5},
      %{repartidor: "M07", zona: "Z3", dia: 4, kilometros: 15, retraso: 0},
      %{repartidor: "M07", zona: "Z1", dia: 5, kilometros: 20, retraso: 0},
      %{repartidor: "M07", zona: "Z2", dia: 5, kilometros: 18, retraso: 10},
      %{repartidor: "M07", zona: "Z3", dia: 5, kilometros: 20, retraso: 3},
      %{repartidor: "M07", zona: "Z3", dia: 6, kilometros: 25, retraso: 0},
      %{repartidor: "M07", zona: "Z1", dia: 6, kilometros: 20, retraso: -2},

      # ===== M08 - Andrés Castaño (sin bici) =====
      %{repartidor: "M08", zona: "Z2", dia: 1, kilometros: 15, retraso: 30},
      %{repartidor: "M08", zona: "Z1", dia: 1, kilometros: 20, retraso: 0},
      %{repartidor: "M08", zona: "Z1", dia: 2, kilometros: 25, retraso: 0},
      %{repartidor: "M08", zona: "Z3", dia: 2, kilometros: 18, retraso: 10},
      %{repartidor: "M08", zona: "Z2", dia: 2, kilometros: 20, retraso: 0},
      %{repartidor: "M08", zona: "Z2", dia: 3, kilometros: 22, retraso: 0},
      %{repartidor: "M08", zona: "Z1", dia: 3, kilometros: 18, retraso: -4},
      %{repartidor: "M08", zona: "Z1", dia: 4, kilometros: 25, retraso: 0},
      %{repartidor: "M08", zona: "Z3", dia: 4, kilometros: 20, retraso: 15},
      %{repartidor: "M08", zona: "Z2", dia: 5, kilometros: 20, retraso: 5},
      %{repartidor: "M08", zona: "Z1", dia: 5, kilometros: 15, retraso: 0},
      %{repartidor: "M08", zona: "Z3", dia: 5, kilometros: 25, retraso: 0},
      %{repartidor: "M08", zona: "Z3", dia: 6, kilometros: 22, retraso: 0},
      %{repartidor: "M08", zona: "Z1", dia: 6, kilometros: 15, retraso: 8},

      # ===== M09 - Camila Vargas (sin bici) =====
      %{repartidor: "M09", zona: "Z1", dia: 1, kilometros: 18, retraso: -2},
      %{repartidor: "M09", zona: "Z3", dia: 1, kilometros: 15, retraso: 0},
      %{repartidor: "M09", zona: "Z2", dia: 2, kilometros: 20, retraso: 0},
      %{repartidor: "M09", zona: "Z1", dia: 2, kilometros: 25, retraso: 8},
      %{repartidor: "M09", zona: "Z3", dia: 2, kilometros: 15, retraso: -3},
      %{repartidor: "M09", zona: "Z1", dia: 3, kilometros: 15, retraso: 0},
      %{repartidor: "M09", zona: "Z2", dia: 3, kilometros: 18, retraso: -6},
      %{repartidor: "M09", zona: "Z3", dia: 4, kilometros: 20, retraso: 0},
      %{repartidor: "M09", zona: "Z1", dia: 4, kilometros: 22, retraso: 12},
      %{repartidor: "M09", zona: "Z2", dia: 4, kilometros: 18, retraso: 0},
      %{repartidor: "M09", zona: "Z2", dia: 5, kilometros: 25, retraso: 0},
      %{repartidor: "M09", zona: "Z3", dia: 5, kilometros: 18, retraso: -1},
      %{repartidor: "M09", zona: "Z1", dia: 5, kilometros: 18, retraso: 0},
      %{repartidor: "M09", zona: "Z1", dia: 6, kilometros: 20, retraso: 5},
      %{repartidor: "M09", zona: "Z2", dia: 6, kilometros: 15, retraso: 0},

      # ===== M10 - Santiago Moreno (sin bici) =====
      # Día 6: 45 km (empate con M07 para R5)
      %{repartidor: "M10", zona: "Z2", dia: 1, kilometros: 20, retraso: 0},
      %{repartidor: "M10", zona: "Z1", dia: 1, kilometros: 22, retraso: -5},
      %{repartidor: "M10", zona: "Z3", dia: 1, kilometros: 15, retraso: 0},
      %{repartidor: "M10", zona: "Z3", dia: 2, kilometros: 18, retraso: 0},
      %{repartidor: "M10", zona: "Z1", dia: 2, kilometros: 20, retraso: 5},
      %{repartidor: "M10", zona: "Z2", dia: 2, kilometros: 25, retraso: 0},
      %{repartidor: "M10", zona: "Z1", dia: 3, kilometros: 25, retraso: 0},
      %{repartidor: "M10", zona: "Z2", dia: 4, kilometros: 18, retraso: 0},
      %{repartidor: "M10", zona: "Z1", dia: 4, kilometros: 22, retraso: 10},
      %{repartidor: "M10", zona: "Z3", dia: 4, kilometros: 25, retraso: 3},
      %{repartidor: "M10", zona: "Z3", dia: 5, kilometros: 20, retraso: 0},
      %{repartidor: "M10", zona: "Z2", dia: 5, kilometros: 22, retraso: -3},
      %{repartidor: "M10", zona: "Z1", dia: 5, kilometros: 20, retraso: -1},
      %{repartidor: "M10", zona: "Z1", dia: 6, kilometros: 25, retraso: 0},
      %{repartidor: "M10", zona: "Z3", dia: 6, kilometros: 20, retraso: 5}

      # ===== M11 - Paula Gil (bici: true) =====
      # NO tiene servicios válidos -> aparece en liquidación con ceros
    ]
  end

  # PURA - servicios que NO pasarán la validación (16 servicios inválidos)
  def servicios_invalidos do
    [
      # --- Motivo: :repartidor_desconocido (2 servicios) ---
      %{repartidor: "M99", zona: "Z1", dia: 1, kilometros: 15, retraso: 5},
      %{repartidor: "M88", zona: "Z2", dia: 3, kilometros: 20, retraso: 0},

      # --- Motivo: :zona_desconocida (2 servicios) ---
      %{repartidor: "M01", zona: "Z9", dia: 2, kilometros: 10, retraso: 0},
      %{repartidor: "M03", zona: "Z8", dia: 4, kilometros: 25, retraso: 5},

      # --- Motivo: :dia_invalido (4 servicios, variedad de errores) ---
      %{repartidor: "M02", zona: "Z1", dia: 0, kilometros: 15, retraso: 0},
      %{repartidor: "M04", zona: "Z2", dia: 7, kilometros: 20, retraso: 5},
      %{repartidor: "M06", zona: "Z1", dia: 2.5, kilometros: 18, retraso: 0},
      %{repartidor: "M08", zona: "Z2", dia: "3", kilometros: 22, retraso: 0},

      # --- Motivo: :kilometros_fuera_de_rango (4 servicios) ---
      %{repartidor: "M03", zona: "Z1", dia: 2, kilometros: 0, retraso: 5},
      %{repartidor: "M05", zona: "Z2", dia: 3, kilometros: -5, retraso: 0},
      %{repartidor: "M07", zona: "Z1", dia: 4, kilometros: 50, retraso: 0},
      %{repartidor: "M09", zona: "Z2", dia: 1, kilometros: "abc", retraso: 3},

      # --- Motivo: :retraso_invalido (3 servicios) ---
      %{repartidor: "M04", zona: "Z1", dia: 2, kilometros: 20, retraso: 200},
      %{repartidor: "M06", zona: "Z2", dia: 3, kilometros: 15, retraso: -40},
      %{repartidor: "M08", zona: "Z1", dia: 5, kilometros: 25, retraso: "tarde"},

      # --- Servicio con DOS errores (zona + km inválidos) ---
      # Se reporta solo el primero según el orden: :zona_desconocida
      %{repartidor: "M05", zona: "Z9", dia: 3, kilometros: -10, retraso: 5}
    ]
  end
end

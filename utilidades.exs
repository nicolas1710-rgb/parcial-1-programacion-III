# Integrantes: [Completar con nombres del grupo]
# Archivo: utilidades.exs
# Módulo con funciones de apoyo: ranking genérico, búsqueda y formato.

defmodule Utilidades do
  # PURA - ordena y limita una lista de mapas usando opciones en una keyword list.
  # Opciones permitidas:
  #   - por: átomo del campo por el que se ordena (por defecto :neto)
  #   - orden: :asc o :desc (por defecto :desc)
  #   - limite: cantidad máxima de elementos a retornar (por defecto toda la lista)
  def ranking(lista, opciones \\ []) do
    campo = Keyword.get(opciones, :por, :neto)
    orden = Keyword.get(opciones, :orden, :desc)
    limite = Keyword.get(opciones, :limite, length(lista))

    lista_ordenada = Enum.sort_by(lista, fn elemento -> Map.get(elemento, campo) end, orden)
    Enum.take(lista_ordenada, limite)
  end

  # PURA - busca el nombre de un repartidor a partir de su código
  def buscar_nombre(codigo, repartidores) do
    repartidor = Enum.find(repartidores, fn r -> r.codigo == codigo end)

    if repartidor != nil do
      repartidor.nombre
    else
      "Desconocido"
    end
  end

  # PURA - formatea un valor numérico a pesos colombianos redondeados
  def formato_pesos(numero) do
    "$#{round(numero)}"
  end

  # PURA - redondea un número a 2 decimales para mostrar en pantalla
  def redondear(numero) do
    Float.round(numero * 1.0, 2)
  end
end

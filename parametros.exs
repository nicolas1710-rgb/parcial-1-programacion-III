# Integrantes: [Completar con nombres del grupo]
# Archivo: parametros.exs
# Módulo con las constantes del negocio. Cada parámetro es un atributo de módulo
# y se expone con una función pública para que otros módulos lo consulten.

defmodule Parametros do
  @tarifa_base 2500
  @meta_diaria 500
  @dias_operacion 1..6
  @maxima_distancia 45
  @km_bonificacion 80
  @bonificacion_diaria 15_000
  @alquiler_bicicleta 10_000

  # PURA - devuelve la tarifa base por kilómetro
  def tarifa_base, do: @tarifa_base

  # PURA - devuelve la meta diaria de la empresa en km
  def meta_diaria, do: @meta_diaria

  # PURA - devuelve el rango de días de operación (1 a 6)
  def dias_operacion, do: @dias_operacion

  # PURA - devuelve la distancia máxima permitida por servicio
  def maxima_distancia, do: @maxima_distancia

  # PURA - devuelve los km diarios mínimos para ganar bonificación
  def km_bonificacion, do: @km_bonificacion

  # PURA - devuelve el monto de la bonificación diaria
  def bonificacion_diaria, do: @bonificacion_diaria

  # PURA - devuelve el costo de alquiler de bicicleta por día trabajado
  def alquiler_bicicleta, do: @alquiler_bicicleta
end

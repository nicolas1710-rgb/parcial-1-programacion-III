# Integrantes: [Completar con nombres del grupo]
# Archivo: liquidacion.exs
# Módulo para calcular valores de servicios, bonificaciones por km, alquiler de bicicleta y pago neto.

defmodule Liquidacion do
  # PURA - calcula el valor a pagar por un servicio individual según la tarifa y el retraso
  def valor_servicio(servicio) do
    valor_base = servicio.kilometros * Parametros.tarifa_base()
    retraso = servicio.retraso

    cond do
      retraso <= 0 ->
        # Llegó a tiempo o antes: bonificación del 8%
        valor_base * 1.08

      retraso <= 10 ->
        # Retraso leve (1 a 10 min): tarifa completa sin ajuste
        valor_base * 1.0

      retraso <= 30 ->
        # Retraso moderado (11 a 30 min): descuento del 10%
        valor_base * 0.90

      true ->
        # Retraso grave (más de 30 min): descuento del 25%
        valor_base * 0.75
    end
  end

  # PURA - calcula el total de bonificaciones semanales ($15.000 por cada día con 80 km o más)
  def calcular_bonificaciones(codigo_repartidor, servicios_validos) do
    # Filtramos los servicios de este repartidor
    servicios = Enum.filter(servicios_validos, fn s -> s.repartidor == codigo_repartidor end)

    # Agrupamos por día para sumar los km de cada día
    por_dia = Enum.group_by(servicios, fn s -> s.dia end)

    # Sumamos $15.000 por cada día que alcanzó la meta diaria
    Enum.reduce(por_dia, 0, fn {_dia, servicios_del_dia}, total_bonos ->
      km_del_dia = Enum.sum(Enum.map(servicios_del_dia, fn s -> s.kilometros end))

      if km_del_dia >= Parametros.km_bonificacion() do
        total_bonos + Parametros.bonificacion_diaria()
      else
        total_bonos
      end
    end)
  end

  # PURA - calcula el descuento por alquiler de bicicleta ($10.000 por cada día trabajado)
  def calcular_alquiler(repartidor, servicios_validos) do
    if repartidor.bicicleta do
      # Obtenemos los servicios del repartidor
      servicios = Enum.filter(servicios_validos, fn s -> s.repartidor == repartidor.codigo end)

      # Obtenemos los días distintos en los que trabajó
      dias_distintos = Enum.uniq(Enum.map(servicios, fn s -> s.dia end))

      # Multiplicamos la cantidad de días por la tarifa de alquiler
      length(dias_distintos) * Parametros.alquiler_bicicleta()
    else
      0
    end
  end

  # PURA - calcula la liquidación completa de todos los repartidores
  def liquidar_todos(repartidores, servicios_validos) do
    Enum.map(repartidores, fn repartidor ->
      # Servicios válidos asociados a este repartidor
      servicios = Enum.filter(servicios_validos, fn s -> s.repartidor == repartidor.codigo end)

      # Sumas totales
      total_km = Enum.sum(Enum.map(servicios, fn s -> s.kilometros end))
      total_servicios = Enum.sum(Enum.map(servicios, fn s -> valor_servicio(s) end))
      total_bonos = calcular_bonificaciones(repartidor.codigo, servicios_validos)
      descuento_alquiler = calcular_alquiler(repartidor, servicios_validos)

      # Neto final = Servicios + Bonificaciones - Alquiler
      neto = total_servicios + total_bonos - descuento_alquiler

      %{
        codigo: repartidor.codigo,
        nombre: repartidor.nombre,
        kilometros: total_km,
        valor_servicios: total_servicios,
        bonificaciones: total_bonos,
        alquiler: descuento_alquiler,
        neto: neto
      }
    end)
  end
end

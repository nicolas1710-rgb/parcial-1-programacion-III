# Integrantes: Nicolas Arbelaez, Santiago Avila, Cristian Cruz
defmodule Liquidacion do
  def valor_servicio(servicio) do
    valor_base = servicio.kilometros * Parametros.tarifa_base()
    retraso = servicio.retraso

    cond do
      retraso <= 0 ->
        valor_base * 1.08

      retraso <= 10 ->
        valor_base * 1.0

      retraso <= 30 ->
        valor_base * 0.90

      true ->
        valor_base * 0.75
    end
  end

  def calcular_bonificaciones(codigo_repartidor, servicios_validos) do
    servicios = Enum.filter(servicios_validos, fn s -> s.repartidor == codigo_repartidor end)
    por_dia = Enum.group_by(servicios, fn s -> s.dia end)

    Enum.reduce(por_dia, 0, fn {_dia, servicios_del_dia}, total_bonos ->
      km_del_dia = Enum.sum(Enum.map(servicios_del_dia, fn s -> s.kilometros end))

      if km_del_dia >= Parametros.km_bonificacion() do
        total_bonos + Parametros.bonificacion_diaria()
      else
        total_bonos
      end
    end)
  end

  def calcular_alquiler(repartidor, servicios_validos) do
    if repartidor.bicicleta do
      servicios = Enum.filter(servicios_validos, fn s -> s.repartidor == repartidor.codigo end)
      dias_distintos = Enum.uniq(Enum.map(servicios, fn s -> s.dia end))
      length(dias_distintos) * Parametros.alquiler_bicicleta()
    else
      0
    end
  end

  def liquidar_todos(repartidores, servicios_validos) do
    Enum.map(repartidores, fn repartidor ->
      servicios = Enum.filter(servicios_validos, fn s -> s.repartidor == repartidor.codigo end)

      total_km = Enum.sum(Enum.map(servicios, fn s -> s.kilometros end))
      total_servicios = Enum.sum(Enum.map(servicios, fn s -> valor_servicio(s) end))
      total_bonos = calcular_bonificaciones(repartidor.codigo, servicios_validos)
      descuento_alquiler = calcular_alquiler(repartidor, servicios_validos)

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

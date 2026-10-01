# Integrantes: Nicolas Arbelaez, Santiago Avila, Cristian Cruz
defmodule Validacion do
  def validar(servicio, codigos_repartidores, ids_zonas) do
    with {:ok, _} <- verificar_repartidor(servicio, codigos_repartidores),
         {:ok, _} <- verificar_zona(servicio, ids_zonas),
         {:ok, _} <- verificar_dia(servicio),
         {:ok, _} <- verificar_kilometros(servicio),
         {:ok, _} <- verificar_retraso(servicio) do
      {:ok, servicio}
    end
  end

  def verificar_repartidor(servicio, codigos_repartidores) do
    if servicio.repartidor in codigos_repartidores do
      {:ok, servicio}
    else
      {:error, :repartidor_desconocido}
    end
  end

  def verificar_zona(servicio, ids_zonas) do
    if servicio.zona in ids_zonas do
      {:ok, servicio}
    else
      {:error, :zona_desconocida}
    end
  end

  def verificar_dia(servicio) do
    dia = servicio.dia

    if is_integer(dia) and dia >= 1 and dia <= 6 do
      {:ok, servicio}
    else
      {:error, :dia_invalido}
    end
  end

  def verificar_kilometros(servicio) do
    km = servicio.kilometros

    if is_number(km) and km > 0 and km <= Parametros.maxima_distancia() do
      {:ok, servicio}
    else
      {:error, :kilometros_fuera_de_rango}
    end
  end

  def verificar_retraso(servicio) do
    retraso = servicio.retraso

    if is_number(retraso) and retraso >= -30 and retraso <= 180 do
      {:ok, servicio}
    else
      {:error, :retraso_invalido}
    end
  end
end

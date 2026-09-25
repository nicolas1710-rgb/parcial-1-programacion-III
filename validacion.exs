# Integrantes: [Completar con nombres del grupo]
# Archivo: validacion.exs
# Módulo de validación de servicios. Cada regla es una función pequeña
# que devuelve {:ok, servicio} o {:error, motivo}. Se encadenan con with.

defmodule Validacion do
  # PURA - valida un servicio aplicando las 5 reglas en orden con with.
  # Si alguna falla, devuelve {:error, motivo} del primer error encontrado.
  def validar(servicio, codigos_repartidores, ids_zonas) do
    with {:ok, _} <- verificar_repartidor(servicio, codigos_repartidores),
         {:ok, _} <- verificar_zona(servicio, ids_zonas),
         {:ok, _} <- verificar_dia(servicio),
         {:ok, _} <- verificar_kilometros(servicio),
         {:ok, _} <- verificar_retraso(servicio) do
      {:ok, servicio}
    end
  end

  # PURA - verifica que el repartidor exista en la lista de códigos conocidos
  def verificar_repartidor(servicio, codigos_repartidores) do
    if servicio.repartidor in codigos_repartidores do
      {:ok, servicio}
    else
      {:error, :repartidor_desconocido}
    end
  end

  # PURA - verifica que la zona exista en la lista de ids conocidos
  def verificar_zona(servicio, ids_zonas) do
    if servicio.zona in ids_zonas do
      {:ok, servicio}
    else
      {:error, :zona_desconocida}
    end
  end

  # PURA - verifica que el día sea un entero entre 1 y 6
  def verificar_dia(servicio) do
    dia = servicio.dia

    if is_integer(dia) and dia >= 1 and dia <= 6 do
      {:ok, servicio}
    else
      {:error, :dia_invalido}
    end
  end

  # PURA - verifica que los kilómetros sean un número mayor a 0 y máximo 45
  def verificar_kilometros(servicio) do
    km = servicio.kilometros

    if is_number(km) and km > 0 and km <= Parametros.maxima_distancia() do
      {:ok, servicio}
    else
      {:error, :kilometros_fuera_de_rango}
    end
  end

  # PURA - verifica que el retraso sea numérico y esté entre -30 y 180
  def verificar_retraso(servicio) do
    retraso = servicio.retraso

    if is_number(retraso) and retraso >= -30 and retraso <= 180 do
      {:ok, servicio}
    else
      {:error, :retraso_invalido}
    end
  end
end

# Integrantes: [Completar con nombres del grupo]
# Archivo: entrada.exs
# Módulo para leer y parsear la entrada del usuario por consola (IO.gets).
# Maneja la lectura de servicios adicionales y consulta de comprobantes sin usar try/rescue.

defmodule Entrada do
  # PURA - convierte un texto a número (entero o decimal) sin try/rescue
  def parsear_numero(texto) do
    texto_limpio = String.trim(texto)

    case Integer.parse(texto_limpio) do
      {entero, ""} ->
        {:ok, entero}

      _ ->
        case Float.parse(texto_limpio) do
          {decimal, ""} -> {:ok, decimal}
          _ -> {:error, :no_es_numero}
        end
    end
  end

  # PURA - convierte un texto a entero para validar el día
  def parsear_dia(texto) do
    texto_limpio = String.trim(texto)

    case Integer.parse(texto_limpio) do
      {dia, ""} -> {:ok, dia}
      _ -> {:error, :dia_no_entero}
    end
  end

  # PURA - separa la línea por punto y coma (;) y arma el mapa del servicio
  def parsear_servicio(linea) do
    texto = String.trim(linea)

    if texto == "" do
      {:ok, :omitido}
    else
      partes = String.split(texto, ";")

      if length(partes) == 5 do
        [rep, zona, dia_txt, km_txt, ret_txt] = Enum.map(partes, fn p -> String.trim(p) end)

        with {:ok, dia} <- parsear_dia(dia_txt),
             {:ok, km} <- parsear_numero(km_txt),
             {:ok, retraso} <- parsear_numero(ret_txt) do
          servicio = %{
            repartidor: rep,
            zona: zona,
            dia: dia,
            kilometros: km,
            retraso: retraso
          }
          {:ok, servicio}
        else
          _error -> {:error, :formato_invalido}
        end
      else
        {:error, :formato_invalido}
      end
    end
  end

  # IMPURA - solicita un servicio adicional por consola
  def pedir_servicio do
    IO.puts("Ingrese un servicio adicional")
    IO.puts("(repartidor;zona;dia;kilometros;retraso)")
    IO.write("o presione Enter para omitir: ")
    entrada = IO.gets("")

    texto = if entrada == nil, do: "", else: entrada
    parsear_servicio(texto)
  end

  # IMPURA - solicita el código de un repartidor para generar su comprobante
  def pedir_codigo_repartidor do
    IO.puts("\n========================================")
    IO.puts("  CONSULTA DE COMPROBANTE INDIVIDUAL")
    IO.puts("========================================")
    IO.write("Ingrese el código del repartidor (ej: M01) o Enter para salir: ")
    entrada = IO.gets("")

    if entrada == nil do
      ""
    else
      String.trim(entrada)
    end
  end
end

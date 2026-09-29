# Integrantes: [Completar con nombres del grupo]
# Archivo: entrada.exs
# Módulo para leer y parsear la entrada del usuario usando Util.exs.

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

  # IMPURA - solicita un único servicio por consola
  def pedir_un_servicio do
    prompt = "Ingrese servicio (repartidor;zona;dia;kilometros;retraso): "
    entrada = Util.ingresar(prompt, :texto)
    parsear_servicio(entrada)
  end

  # IMPURA - solicita una colección de servicios adicionales utilizando Util.ingresar con :boolean y :coleccion
  def pedir_servicios_adicionales do
    desea_ingresar = Util.ingresar("¿Desea ingresar servicios adicionales (s/n)? ", :boolean)

    if desea_ingresar do
      Util.ingresar(&pedir_un_servicio/0, :coleccion)
    else
      []
    end
  end

  # IMPURA - solicita el código de un repartidor para generar su comprobante usando Util
  def pedir_codigo_repartidor do
    Util.mostrar("\n========================================", :mensaje)
    Util.mostrar("  CONSULTA DE COMPROBANTE INDIVIDUAL", :mensaje)
    Util.mostrar("========================================", :mensaje)
    Util.ingresar("Ingrese el código del repartidor (ej: M01): ", :texto)
  end
end

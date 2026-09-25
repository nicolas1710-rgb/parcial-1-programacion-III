# Integrantes: [Completar con nombres del grupo]
# Archivo: main.exs
# Módulo principal que orquesta la carga de módulos, validación de datos,
# interacción con el usuario, cálculo de liquidaciones, reportes e investigación.

Code.require_file("parametros.exs")
Code.require_file("datos.exs")
Code.require_file("utilidades.exs")
Code.require_file("validacion.exs")
Code.require_file("liquidacion.exs")
Code.require_file("reportes.exs")
Code.require_file("entrada.exs")

defmodule Main do
  # IMPURA - función principal que orquesta todo el flujo del sistema
  def ejecutar do
    IO.puts("==================================================")
    IO.puts("    SISTEMA DE GESTIÓN Y LIQUIDACIÓN MENSAJERÍA    ")
    IO.puts("==================================================\n")

    # 1. Cargar datos iniciales
    repartidores = Datos.repartidores()
    zonas = Datos.zonas()
    servicios_iniciales = Datos.servicios()

    codigos_repartidores = Enum.map(repartidores, fn r -> r.codigo end)
    ids_zonas = Enum.map(zonas, fn z -> z.id end)

    # 2. Validar servicios aplicando las 5 reglas en orden
    # Validamos cada servicio y separamos válidos de rechazados con comprensiones for
    servicios_validados = Enum.map(servicios_iniciales, fn s ->
      {s, Validacion.validar(s, codigos_repartidores, ids_zonas)}
    end)

    servicios_validos = for {s, {:ok, _}} <- servicios_validados, do: s
    rechazados = for {s, {:error, motivo}} <- servicios_validados, do: {s, motivo}

    # 3. Interacción con el usuario: ingreso opcional de un servicio adicional
    {servicios_validos_totales, rechazados_totales} =
      case Entrada.pedir_servicio() do
        {:ok, :omitido} ->
          IO.puts(">> No se ingresó ningún servicio adicional.")
          {servicios_validos, rechazados}

        {:error, :formato_invalido} ->
          IO.puts(">> Servicio rechazado: formato inválido (verifique los 5 campos y tipos).")
          {servicios_validos, rechazados}

        {:ok, nuevo_servicio} ->
          case Validacion.validar(nuevo_servicio, codigos_repartidores, ids_zonas) do
            {:ok, valido} ->
              IO.puts(">> Servicio adicional agregado con éxito.")
              {servicios_validos ++ [valido], rechazados}

            {:error, motivo} ->
              IO.puts(">> Servicio rechazado por validación: #{motivo}")
              {servicios_validos, rechazados ++ [{nuevo_servicio, motivo}]}
          end
      end

    # 4. Calcular liquidaciones de todos los repartidores
    liquidaciones = Liquidacion.liquidar_todos(repartidores, servicios_validos_totales)

    # 5. Generar e imprimir los reportes R1 a R8
    Reportes.imprimir_r1(rechazados_totales)
    Reportes.imprimir_r2(servicios_validos_totales, zonas)
    km_por_dia = Reportes.imprimir_r3(servicios_validos_totales)
    Reportes.imprimir_r4(liquidaciones)
    Reportes.imprimir_r5(servicios_validos_totales, repartidores)
    Reportes.imprimir_r6(servicios_validos_totales, repartidores)
    Reportes.imprimir_r7(liquidaciones)
    Reportes.imprimir_r8(servicios_validos_totales, zonas, repartidores)

    # 6. Sección de Investigación del Parcial
    seccion_investigacion(km_por_dia, repartidores, servicios_validos_totales, codigos_repartidores, ids_zonas)

    # 7. Consulta interactiva de comprobante individual por código
    codigo_consultado = Entrada.pedir_codigo_repartidor()

    if codigo_consultado != "" do
      liquidacion_encontrada = Enum.find(liquidaciones, fn l -> l.codigo == codigo_consultado end)

      if liquidacion_encontrada != nil do
        Reportes.imprimir_comprobante(liquidacion_encontrada, servicios_validos_totales, repartidores)
      else
        IO.puts(">> El repartidor con código \"#{codigo_consultado}\" no fue encontrado.")
      end
    else
      IO.puts(">> Consulta de comprobante omitida.")
    end

    IO.puts("\nProceso finalizado correctamente.")
  end

  # IMPURA - ejecuta e imprime los puntos de la sección de investigación
  def seccion_investigacion(km_por_dia, repartidores, servicios_validos, codigos_repartidores, ids_zonas) do
    IO.puts("\n==================================================")
    IO.puts("         SECCIÓN DE INVESTIGACIÓN (PARCIAL)       ")
    IO.puts("==================================================")

    # a) Demostración de ranking genérico con keyword lists
    IO.puts("\n--- a) Ranking genérico con Keyword Lists ---")
    IO.puts("Se implementó la función Utilidades.ranking/2 que recibe opciones como keyword list:")
    IO.puts("  ranking(lista, por: :campo, orden: :asc/:desc, limite: n)")
    top_3 = Utilidades.ranking(repartidores, por: :codigo, orden: :asc, limite: 3)
    IO.puts("Demostración ranking alfabético de los primeros 3 repartidores:")
    Enum.each(top_3, fn r -> IO.puts("  #{r.codigo}: #{r.nombre}") end)

    # b) Combinación con empresa aliada usando Map.merge/3
    IO.puts("\n--- b) Combinación de mapas con Map.merge/3 ---")
    empresa_aliada = %{1 => 580.5, 2 => 430, 3 => 510, 5 => 625, 7 => 180}

    mapa_combinado =
      Map.merge(km_por_dia, empresa_aliada, fn _dia, km_nuestra, km_aliada ->
        km_nuestra + km_aliada
      end)

    IO.puts("Mapa combinado de kilómetros (nuestra empresa + aliada):")
    Enum.sort(mapa_combinado)
    |> Enum.each(fn {dia, km} ->
      IO.puts("  Día #{dia}: #{Utilidades.redondear(km)} km")
    end)

    IO.puts("\nExplicación técnica Map.merge/3:")
    IO.puts("1. Map.merge/2 sobrescribe los valores de las claves repetidas con los del segundo mapa, perdiendo los km de nuestra empresa.")
    IO.puts("2. Map.merge/3 resuelve esto al recibir una función anónima que decide cómo combinar los dos valores (en este caso sumándolos).")
    IO.puts("3. El día 7, al no existir en nuestra empresa (operamos días 1 al 6), se inserta directamente conservando los 180 km de la aliada.")

    # c) Mediciones de tiempo de ejecución con :timer.tc/1
    IO.puts("\n--- c) Mediciones de rendimiento con :timer.tc/1 ---")

    # Medición 1: Validación de servicios
    {tiempo_val, _} =
      :timer.tc(fn ->
        Enum.map(servicios_validos, fn s ->
          Validacion.validar(s, codigos_repartidores, ids_zonas)
        end)
      end)

    # Medición 2: Cálculo de liquidación semanal
    {tiempo_liq, _} =
      :timer.tc(fn ->
        Liquidacion.liquidar_todos(repartidores, servicios_validos)
      end)

    # Medición 3: Búsqueda en lista vs búsqueda en mapa
    mapa_repartidores = Map.new(repartidores, fn r -> {r.codigo, r} end)
    codigo_prueba = "M05"

    {tiempo_lista, _} =
      :timer.tc(fn ->
        Enum.find(repartidores, fn r -> r.codigo == codigo_prueba end)
      end)

    {tiempo_mapa, _} =
      :timer.tc(fn ->
        Map.get(mapa_repartidores, codigo_prueba)
      end)

    IO.puts("1. Validación de servicios: #{tiempo_val} microsegundos (µs).")
    IO.puts("2. Cálculo de liquidaciones completas: #{tiempo_liq} microsegundos (µs).")
    IO.puts("3. Búsqueda en lista (Enum.find): #{tiempo_lista} µs vs Búsqueda en mapa (Map.get): #{tiempo_mapa} µs.")
    IO.puts("\nExplicación de mediciones:")
    IO.puts("Los tiempos se miden en microsegundos (1 segundo = 1.000.000 µs). Permiten observar la velocidad")
    IO.puts("del runtime BEAM y comparar el acceso directo en mapa O(1) frente al recorrido secuencial en lista O(n).")
  end
end

# Ejecutar el programa al ser invocado con: elixir main.exs
Main.ejecutar()

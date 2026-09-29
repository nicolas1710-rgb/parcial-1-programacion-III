# Integrantes: [Completar con nombres del grupo]
# Archivo: main.exs
# Módulo principal que orquesta la carga de módulos, validación de datos,
# interacción con el usuario, cálculo de liquidaciones, reportes e investigación.
# Utiliza Util.exs para toda la interacción de entrada y salida por consola.

Code.require_file("parametros.exs")
Code.require_file("datos.exs")
Code.require_file("Util.exs")
Code.require_file("utilidades.exs")
Code.require_file("validacion.exs")
Code.require_file("liquidacion.exs")
Code.require_file("reportes.exs")
Code.require_file("entrada.exs")

defmodule Main do
  # IMPURA - función principal que orquesta todo el flujo del sistema
  def ejecutar do
    Util.mostrar("==================================================", :mensaje)
    Util.mostrar("    SISTEMA DE GESTIÓN Y LIQUIDACIÓN MENSAJERÍA    ", :mensaje)
    Util.mostrar("==================================================\n", :mensaje)

    # 1. Cargar datos iniciales
    repartidores = Datos.repartidores()
    zonas = Datos.zonas()
    servicios_iniciales = Datos.servicios()

    codigos_repartidores = Enum.map(repartidores, fn r -> r.codigo end)
    ids_zonas = Enum.map(zonas, fn z -> z.id end)

    # 2. Validar servicios aplicando las 5 reglas en orden
    # Separamos en dos listas: válidos y rechazados usando comprensiones for
    servicios_validados = Enum.map(servicios_iniciales, fn s ->
      {s, Validacion.validar(s, codigos_repartidores, ids_zonas)}
    end)

    servicios_validos = for {s, {:ok, _}} <- servicios_validados, do: s
    rechazados = for {s, {:error, motivo}} <- servicios_validados, do: {s, motivo}

    # 3. Interacción con el usuario: ingreso opcional de servicios adicionales con Util.ingresar (:boolean y :coleccion)
    servicios_adicionales_ingresados = Entrada.pedir_servicios_adicionales()

    {servicios_validos_totales, rechazados_totales} =
      if servicios_adicionales_ingresados == [] do
        Util.mostrar(">> No se ingresaron servicios adicionales.", :mensaje)
        {servicios_validos, rechazados}
      else
        Enum.reduce(servicios_adicionales_ingresados, {servicios_validos, rechazados}, fn
          {:ok, nuevo_servicio}, {acc_validos, acc_rechazados} ->
            case Validacion.validar(nuevo_servicio, codigos_repartidores, ids_zonas) do
              {:ok, valido} ->
                Util.mostrar(">> Servicio de #{valido.repartidor} en #{valido.zona} agregado con éxito.", :mensaje)
                {acc_validos ++ [valido], acc_rechazados}

              {:error, motivo} ->
                Util.mostrar(">> Servicio rechazado por validación: #{motivo}", :error)
                {acc_validos, acc_rechazados ++ [{nuevo_servicio, motivo}]}
            end

          {:error, :formato_invalido}, {acc_validos, acc_rechazados} ->
            Util.mostrar(">> Servicio rechazado: formato inválido (verifique los 5 campos y tipos).", :error)
            servicio_fantasma = %{repartidor: "DESC", zona: "DESC", dia: nil, kilometros: nil, retraso: nil}
            {acc_validos, acc_rechazados ++ [{servicio_fantasma, :formato_invalido}]}

          {:ok, :omitido}, acc ->
            acc
        end)
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
    desea_comprobante = Util.ingresar("\n¿Desea consultar un comprobante individual (s/n)? ", :boolean)

    if desea_comprobante do
      codigo_consultado = Entrada.pedir_codigo_repartidor()
      liquidacion_encontrada = Enum.find(liquidaciones, fn l -> l.codigo == codigo_consultado end)

      if liquidacion_encontrada != nil do
        Reportes.imprimir_comprobante(liquidacion_encontrada, servicios_validos_totales, repartidores)
      else
        Util.mostrar(">> El repartidor con código \"#{codigo_consultado}\" no fue encontrado.", :error)
      end
    else
      Util.mostrar(">> Consulta de comprobante omitida.", :mensaje)
    end

    Util.mostrar("\nProceso finalizado correctamente.", :mensaje)
  end

  # IMPURA - ejecuta e imprime los puntos de la sección de investigación
  def seccion_investigacion(km_por_dia, repartidores, servicios_validos, codigos_repartidores, ids_zonas) do
    Util.mostrar("\n==================================================", :mensaje)
    Util.mostrar("         SECCIÓN DE INVESTIGACIÓN (PARCIAL)       ", :mensaje)
    Util.mostrar("==================================================", :mensaje)

    # a) Demostración de ranking genérico con keyword lists
    Util.mostrar("\n--- a) Ranking genérico con Keyword Lists ---", :mensaje)
    Util.mostrar("Se implementó la función Utilidades.ranking/2 que recibe opciones como keyword list:", :mensaje)
    Util.mostrar("  ranking(lista, por: :campo, orden: :asc/:desc, limite: n)", :mensaje)
    top_3 = Utilidades.ranking(repartidores, por: :codigo, orden: :asc, limite: 3)
    Util.mostrar("Demostración ranking alfabético de los primeros 3 repartidores:", :mensaje)
    lineas_top_3 =
      Util.convertir_coleccion_mensaje(top_3, fn r -> "  #{r.codigo}: #{r.nombre}" end)

    Enum.each(lineas_top_3, &Util.mostrar(&1, :mensaje))

    # b) Combinación con empresa aliada usando Map.merge/3
    Util.mostrar("\n--- b) Combinación de mapas con Map.merge/3 ---", :mensaje)
    empresa_aliada = %{1 => 580.5, 2 => 430, 3 => 510, 5 => 625, 7 => 180}

    mapa_combinado =
      Map.merge(km_por_dia, empresa_aliada, fn _dia, km_nuestra, km_aliada ->
        km_nuestra + km_aliada
      end)

    Util.mostrar("Mapa combinado de kilómetros (nuestra empresa + aliada):", :mensaje)
    Util.ordenar(mapa_combinado)
    |> Enum.each(fn {dia, km} ->
      Util.mostrar("  Día #{dia}: #{Utilidades.redondear(km)} km", :mensaje)
    end)

    Util.mostrar("\nExplicación técnica Map.merge/3:", :mensaje)
    Util.mostrar("1. Map.merge/2 sobrescribe los valores de las claves repetidas con los del segundo mapa, perdiendo los km de nuestra empresa.", :mensaje)
    Util.mostrar("2. Map.merge/3 resuelve esto al recibir una función anónima que decide cómo combinar los dos valores (en este caso sumándolos).", :mensaje)
    Util.mostrar("3. El día 7, al no existir en nuestra empresa (operamos días 1 al 6), se inserta directamente conservando los 180 km de la aliada.", :mensaje)

    # c) Mediciones de tiempo de ejecución con :timer.tc/1
    Util.mostrar("\n--- c) Mediciones de rendimiento con :timer.tc/1 ---", :mensaje)

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

    Util.mostrar("1. Validación de servicios: #{tiempo_val} microsegundos (µs).", :mensaje)
    Util.mostrar("2. Cálculo de liquidaciones completas: #{tiempo_liq} microsegundos (µs).", :mensaje)
    Util.mostrar("3. Búsqueda en lista (Enum.find): #{tiempo_lista} µs vs Búsqueda en mapa (Map.get): #{tiempo_mapa} µs.", :mensaje)
    Util.mostrar("\nExplicación de mediciones:", :mensaje)
    Util.mostrar("Los tiempos se miden en microsegundos (1 segundo = 1.000.000 µs). Permiten observar la velocidad", :mensaje)
    Util.mostrar("del runtime BEAM y comparar el acceso directo en mapa O(1) frente al recorrido secuencial en lista O(n).", :mensaje)
  end
end

# Ejecutar el programa al ser invocado con: elixir main.exs
Main.ejecutar()

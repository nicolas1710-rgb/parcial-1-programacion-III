# Integrantes: [Completar con nombres del grupo]
# Archivo: reportes.exs
# Módulo con los reportes R1 a R8 y el comprobante de pago.
# Cada reporte separa la función PURA (cálculo de datos) de la IMPURA (impresión en pantalla).

defmodule Reportes do
  # ============================================================
  # R1: SERVICIOS RECHAZADOS
  # ============================================================

  # PURA - agrupa los servicios rechazados por motivo y cuenta cuántos hay de cada uno
  def contar_rechazos_por_motivo(rechazados) do
    por_motivo = Enum.group_by(rechazados, fn {_servicio, motivo} -> motivo end)

    Enum.map(por_motivo, fn {motivo, lista} ->
      {motivo, length(lista)}
    end)
  end

  # IMPURA - imprime la lista de servicios rechazados y el resumen de motivos
  def imprimir_r1(rechazados) do
    IO.puts("\n========================================")
    IO.puts("  R1: SERVICIOS RECHAZADOS")
    IO.puts("========================================")

    if rechazados == [] do
      IO.puts("  No hay servicios rechazados.")
    else
      Enum.each(rechazados, fn {servicio, motivo} ->
        IO.puts("  Repartidor: #{servicio.repartidor}, Zona: #{servicio.zona}, Día: #{inspect(servicio.dia)}, Km: #{inspect(servicio.kilometros)}, Retraso: #{inspect(servicio.retraso)} -> #{motivo}")
      end)

      IO.puts("\n  Rechazos por motivo:")
      conteo = contar_rechazos_por_motivo(rechazados)

      Enum.each(conteo, fn {motivo, cantidad} ->
        IO.puts("    #{motivo}: #{cantidad}")
      end)

      IO.puts("  Total rechazados: #{length(rechazados)}")
    end
  end

  # ============================================================
  # R2: KILÓMETROS POR ZONA Y DENSIDAD
  # ============================================================

  # PURA - calcula los kilómetros acumulados y la densidad (km / km²) para cada zona
  def calcular_km_por_zona(servicios_validos, zonas) do
    Enum.map(zonas, fn zona ->
      servicios_de_la_zona = Enum.filter(servicios_validos, fn s -> s.zona == zona.id end)
      km_totales = Enum.sum(Enum.map(servicios_de_la_zona, fn s -> s.kilometros end))
      densidad = if zona.area > 0, do: km_totales / zona.area, else: 0.0

      %{
        id: zona.id,
        nombre: zona.nombre,
        area: zona.area,
        km: km_totales,
        densidad: densidad
      }
    end)
  end

  # IMPURA - imprime las zonas ordenadas por densidad de mayor a menor
  def imprimir_r2(servicios_validos, zonas) do
    IO.puts("\n========================================")
    IO.puts("  R2: KILÓMETROS POR ZONA Y DENSIDAD")
    IO.puts("========================================")

    datos_zonas = calcular_km_por_zona(servicios_validos, zonas)
    ordenados = Utilidades.ranking(datos_zonas, por: :densidad, orden: :desc)

    Enum.each(ordenados, fn z ->
      IO.puts("  #{z.nombre} (#{z.id}): #{Utilidades.redondear(z.km)} km, Área: #{z.area} km², Densidad: #{Utilidades.redondear(z.densidad)} km/km²")
    end)
  end

  # ============================================================
  # R3: KILÓMETROS POR DÍA Y META DIARIA
  # ============================================================

  # PURA - calcula los kilómetros de cada día (1 al 6) y devuelve un mapa %{dia => km}
  def calcular_km_por_dia(servicios_validos) do
    Enum.reduce(1..6, %{}, fn dia, mapa_acumulado ->
      servicios_del_dia = Enum.filter(servicios_validos, fn s -> s.dia == dia end)
      total_km = Enum.sum(Enum.map(servicios_del_dia, fn s -> s.kilometros end))
      Map.put(mapa_acumulado, dia, total_km)
    end)
  end

  # IMPURA - imprime los km de cada día y si se alcanzó la meta de 500 km
  def imprimir_r3(servicios_validos) do
    IO.puts("\n========================================")
    IO.puts("  R3: KILÓMETROS POR DÍA Y META (#{Parametros.meta_diaria()} km)")
    IO.puts("========================================")

    km_por_dia = calcular_km_por_dia(servicios_validos)
    meta = Parametros.meta_diaria()

    dias_cumplidos = Enum.map(1..6, fn dia ->
      km = Map.get(km_por_dia, dia, 0)
      alcanzo = km >= meta
      estado = if alcanzo, do: "✓ META ALCANZADA", else: "✗ No alcanzó la meta"
      IO.puts("  Día #{dia}: #{Utilidades.redondear(km)} km - #{estado}")
      alcanzo
    end)

    todos = Enum.all?(dias_cumplidos, fn x -> x end)
    al_menos_uno = Enum.any?(dias_cumplidos, fn x -> x end)

    IO.puts("\n  ¿Meta todos los días? #{if todos, do: "SÍ", else: "NO"}")
    IO.puts("  ¿Meta al menos un día? #{if al_menos_uno, do: "SÍ", else: "NO"}")

    # Retorna el mapa para reutilizarlo en la investigación
    km_por_dia
  end

  # ============================================================
  # R4: LIQUIDACIÓN DE REPARTIDORES
  # ============================================================

  # IMPURA - imprime la liquidación de repartidores ordenada de mayor a menor neto
  def imprimir_r4(liquidaciones) do
    IO.puts("\n========================================")
    IO.puts("  R4: LIQUIDACIÓN DE REPARTIDORES")
    IO.puts("========================================")

    # Ordenamos con nuestra función de ranking
    ordenadas = Utilidades.ranking(liquidaciones, por: :neto, orden: :desc)

    Enum.with_index(ordenadas, 1)
    |> Enum.each(fn {liq, posicion} ->
      IO.puts("  #{posicion}. #{liq.nombre} (#{liq.codigo})")
      IO.puts("     Kilómetros: #{Utilidades.redondear(liq.kilometros)}")
      IO.puts("     Valor servicios: #{Utilidades.formato_pesos(liq.valor_servicios)}")
      IO.puts("     Bonificaciones: #{Utilidades.formato_pesos(liq.bonificaciones)}")
      IO.puts("     Alquiler bicicleta: #{Utilidades.formato_pesos(liq.alquiler)}")
      IO.puts("     NETO: #{Utilidades.formato_pesos(liq.neto)}\n")
    end)
  end

  # ============================================================
  # R5: MEJOR REPARTIDOR POR DÍA Y CAMPEÓN SEMANAL
  # ============================================================

  # PURA - encuentra al repartidor (o repartidores si hay empate) con más km en cada día
  def mejores_por_dia(servicios_validos, repartidores) do
    Enum.map(1..6, fn dia ->
      servicios_del_dia = Enum.filter(servicios_validos, fn s -> s.dia == dia end)

      # Calculamos los km de cada repartidor en este día
      totales = Enum.map(repartidores, fn r ->
        servicios_rep = Enum.filter(servicios_del_dia, fn s -> s.repartidor == r.codigo end)
        km = Enum.sum(Enum.map(servicios_rep, fn s -> s.kilometros end))
        %{codigo: r.codigo, nombre: r.nombre, km: km}
      end)

      # Filtramos los que sí tuvieron servicios ese día
      activos = Enum.filter(totales, fn r -> r.km > 0 end)

      if activos == [] do
        {dia, []}
      else
        max_km = Enum.max(Enum.map(activos, fn r -> r.km end))
        ganadores = Enum.filter(activos, fn r -> r.km == max_km end)
        {dia, ganadores}
      end
    end)
  end

  # PURA - determina el campeón semanal (el que fue primero en más días)
  def campeon_semanal(mejores) do
    # Obtenemos la lista de todos los ganadores de cada día
    todos_los_ganadores = Enum.flat_map(mejores, fn {_dia, ganadores} -> ganadores end)

    if todos_los_ganadores == [] do
      []
    else
      # Agrupamos por código para contar cuántas veces ganó cada repartidor
      por_repartidor = Enum.group_by(todos_los_ganadores, fn g -> g.codigo end)

      conteo = Enum.map(por_repartidor, fn {codigo, lista} ->
        nombre = hd(lista).nombre
        %{codigo: codigo, nombre: nombre, dias: length(lista)}
      end)

      max_dias = Enum.max(Enum.map(conteo, fn c -> c.dias end))
      Enum.filter(conteo, fn c -> c.dias == max_dias end)
    end
  end

  # IMPURA - imprime los ganadores de cada día y el campeón semanal
  def imprimir_r5(servicios_validos, repartidores) do
    IO.puts("\n========================================")
    IO.puts("  R5: MEJOR REPARTIDOR POR DÍA")
    IO.puts("========================================")

    mejores = mejores_por_dia(servicios_validos, repartidores)

    Enum.each(mejores, fn {dia, ganadores} ->
      if ganadores == [] do
        IO.puts("  Día #{dia}: Sin servicios")
      else
        textos = Enum.map(ganadores, fn g ->
          "#{g.nombre} (#{g.codigo}) con #{Utilidades.redondear(g.km)} km"
        end)
        mensaje = Enum.join(textos, ", ")
        empate = if length(ganadores) > 1, do: " [EMPATE]", else: ""
        IO.puts("  Día #{dia}: #{mensaje}#{empate}")
      end
    end)

    campeones = campeon_semanal(mejores)
    IO.puts("\n  Campeón semanal (primero en más días):")

    Enum.each(campeones, fn c ->
      IO.puts("    #{c.nombre} (#{c.codigo}) - #{c.dias} día(s) como primero")
    end)
  end

  # ============================================================
  # R6: MEJOR PUNTUALIDAD (PROMEDIO PONDERADO VS SIMPLE)
  # ============================================================

  # PURA - calcula promedios de retraso para repartidores con 3 o más servicios
  def calcular_puntualidad(servicios_validos, repartidores) do
    por_repartidor = Enum.group_by(servicios_validos, fn s -> s.repartidor end)
    elegibles = Enum.filter(por_repartidor, fn {_cod, lista} -> length(lista) >= 3 end)

    Enum.map(elegibles, fn {codigo, servicios} ->
      # Promedio ponderado: suma(retraso * km) / suma(km)
      suma_ponderada = Enum.sum(Enum.map(servicios, fn s -> s.retraso * s.kilometros end))
      total_km = Enum.sum(Enum.map(servicios, fn s -> s.kilometros end))
      promedio_ponderado = if total_km > 0, do: suma_ponderada / total_km, else: 0.0

      # Promedio simple: suma(retraso) / total_servicios
      suma_retrasos = Enum.sum(Enum.map(servicios, fn s -> s.retraso end))
      promedio_simple = suma_retrasos / length(servicios)

      nombre = Utilidades.buscar_nombre(codigo, repartidores)

      %{
        codigo: codigo,
        nombre: nombre,
        promedio_ponderado: promedio_ponderado,
        promedio_simple: promedio_simple,
        num_servicios: length(servicios)
      }
    end)
  end

  # IMPURA - imprime el repartidor con mejor puntualidad según el promedio ponderado
  def imprimir_r6(servicios_validos, repartidores) do
    IO.puts("\n========================================")
    IO.puts("  R6: MEJOR PUNTUALIDAD (PROMEDIO PONDERADO)")
    IO.puts("========================================")

    promedios = calcular_puntualidad(servicios_validos, repartidores)

    if promedios == [] do
      IO.puts("  No hay repartidores con 3 o más servicios válidos.")
    else
      # El mejor es el que tenga el menor promedio (más puntual o con adelanto)
      ganador = Enum.min_by(promedios, fn p -> p.promedio_ponderado end)

      IO.puts("  Ganador: #{ganador.nombre} (#{ganador.codigo})")
      IO.puts("  Servicios válidos: #{ganador.num_servicios}")
      IO.puts("  Promedio ponderado (retraso × km / km): #{Utilidades.redondear(ganador.promedio_ponderado)} min")
      IO.puts("  Promedio simple: #{Utilidades.redondear(ganador.promedio_simple)} min")
      IO.puts("  (El ponderado da más peso a servicios de más kilómetros)")
    end
  end

  # ============================================================
  # R7: TOTAL PAGADO Y COSTO POR KILÓMETRO
  # ============================================================

  # PURA - suma los pagos netos y kilómetros para calcular el costo promedio por km
  def calcular_totales(liquidaciones) do
    total_netos = Enum.sum(Enum.map(liquidaciones, fn l -> l.neto end))
    total_km = Enum.sum(Enum.map(liquidaciones, fn l -> l.kilometros end))
    costo_por_km = if total_km > 0, do: total_netos / total_km, else: 0.0

    %{total_netos: total_netos, total_km: total_km, costo_por_km: costo_por_km}
  end

  # IMPURA - imprime el total de dinero pagado y el costo por kilómetro
  def imprimir_r7(liquidaciones) do
    IO.puts("\n========================================")
    IO.puts("  R7: TOTAL PAGADO EN LA SEMANA")
    IO.puts("========================================")

    totales = calcular_totales(liquidaciones)

    IO.puts("  Total pagado (suma de netos): #{Utilidades.formato_pesos(totales.total_netos)}")
    IO.puts("  Total kilómetros: #{Utilidades.redondear(totales.total_km)}")
    IO.puts("  Costo promedio por km: #{Utilidades.formato_pesos(totales.costo_por_km)}")
  end

  # ============================================================
  # R8: REPARTIDORES CON SERVICIO EN TODAS LAS ZONAS
  # ============================================================

  # PURA - encuentra los repartidores que han prestado servicio en cada una de las zonas
  def repartidores_todas_zonas(servicios_validos, zonas, repartidores) do
    total_zonas = length(zonas)

    Enum.filter(repartidores, fn r ->
      servicios_r = Enum.filter(servicios_validos, fn s -> s.repartidor == r.codigo end)
      zonas_visitadas = Enum.uniq(Enum.map(servicios_r, fn s -> s.zona end))
      length(zonas_visitadas) == total_zonas
    end)
    |> Enum.map(fn r ->
      servicios_r = Enum.filter(servicios_validos, fn s -> s.repartidor == r.codigo end)
      zonas_visitadas = Enum.sort(Enum.uniq(Enum.map(servicios_r, fn s -> s.zona end)))
      %{codigo: r.codigo, nombre: r.nombre, zonas: zonas_visitadas}
    end)
  end

  # IMPURA - imprime los repartidores con cobertura completa de zonas
  def imprimir_r8(servicios_validos, zonas, repartidores) do
    IO.puts("\n========================================")
    IO.puts("  R8: REPARTIDORES EN TODAS LAS ZONAS")
    IO.puts("========================================")

    resultado = repartidores_todas_zonas(servicios_validos, zonas, repartidores)

    if resultado == [] do
      IO.puts("  Ningún repartidor tiene servicios en todas las zonas.")
    else
      Enum.each(resultado, fn r ->
        IO.puts("  #{r.nombre} (#{r.codigo}) - Zonas: #{Enum.join(r.zonas, ", ")}")
      end)
    end
  end

  # ============================================================
  # COMPROBANTE DE PAGO INDIVIDUAL
  # ============================================================

  # IMPURA - imprime el comprobante desglosado día por día de un repartidor
  def imprimir_comprobante(liquidacion, servicios_validos, repartidores) do
    codigo = liquidacion.codigo
    repartidor = Enum.find(repartidores, fn r -> r.codigo == codigo end)
    servicios_del_repartidor = Enum.filter(servicios_validos, fn s -> s.repartidor == codigo end)

    IO.puts("\n========================================")
    IO.puts("  COMPROBANTE DE PAGO")
    IO.puts("========================================")
    IO.puts("  Repartidor: #{liquidacion.nombre} (#{codigo})")
    IO.puts("  Bicicleta: #{if repartidor.bicicleta, do: "Sí", else: "No"}")
    IO.puts("----------------------------------------")

    por_dia = Enum.group_by(servicios_del_repartidor, fn s -> s.dia end)
    dias_trabajados = Enum.sort(Map.keys(por_dia))

    if dias_trabajados == [] do
      IO.puts("  Sin servicios válidos en la semana.")
    else
      Enum.each(dias_trabajados, fn dia ->
        servicios_dia = Map.get(por_dia, dia, [])
        km_dia = Enum.sum(Enum.map(servicios_dia, fn s -> s.kilometros end))
        valor_dia = Enum.sum(Enum.map(servicios_dia, fn s -> Liquidacion.valor_servicio(s) end))
        bono_dia = if km_dia >= Parametros.km_bonificacion(), do: Parametros.bonificacion_diaria(), else: 0

        IO.puts("  Día #{dia}: #{Utilidades.redondear(km_dia)} km, Valor: #{Utilidades.formato_pesos(valor_dia)}, Bonificación: #{Utilidades.formato_pesos(bono_dia)}")
      end)
    end

    IO.puts("----------------------------------------")
    IO.puts("  Suma valor servicios: #{Utilidades.formato_pesos(liquidacion.valor_servicios)}")
    IO.puts("  Suma bonificaciones: #{Utilidades.formato_pesos(liquidacion.bonificaciones)}")
    IO.puts("  Descuento alquiler: #{Utilidades.formato_pesos(liquidacion.alquiler)}")
    IO.puts("  NETO A PAGAR: #{Utilidades.formato_pesos(liquidacion.neto)}")
    IO.puts("========================================")
  end
end

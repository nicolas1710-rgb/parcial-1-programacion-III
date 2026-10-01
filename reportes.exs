# Integrantes: Nicolas Arbelaez, Santiago Avila, Cristian Cruz
defmodule Reportes do
  # R1: Servicios rechazados y total por motivo
  def imprimir_r1(rechazados) do
    Util.mostrar("\n=== R1: SERVICIOS RECHAZADOS ===", :mensaje)
    Enum.each(rechazados, fn {s, m} -> Util.mostrar("  #{s.repartidor} (#{s.zona}): #{m}", :mensaje) end)

    Enum.group_by(rechazados, fn {_s, m} -> m end)
    |> Enum.each(fn {m, l} -> Util.mostrar("  Motivo #{m}: #{length(l)}", :mensaje) end)
  end

  # R2: Km por zona y densidad (km/km²)
  def imprimir_r2(servicios_validos, zonas) do
    Util.mostrar("\n=== R2: DENSIDAD POR ZONA ===", :mensaje)

    Enum.map(zonas, fn z ->
      km = Enum.sum(for s <- servicios_validos, s.zona == z.id, do: s.kilometros)
      %{nombre: z.nombre, id: z.id, km: km, den: if(z.area > 0, do: km / z.area, else: 0.0)}
    end)
    |> Utilidades.ranking(por: :den, orden: :desc)
    |> Enum.each(fn z -> Util.mostrar("  #{z.nombre} (#{z.id}): #{Utilidades.redondear(z.km)} km | #{Utilidades.redondear(z.den)} km/km²", :mensaje) end)
  end

  # R3: Km por día y meta diaria
  def imprimir_r3(servicios_validos) do
    Util.mostrar("\n=== R3: KILÓMETROS POR DÍA ===", :mensaje)

    km_por_dia = Enum.reduce(1..6, %{}, fn d, acc ->
      Map.put(acc, d, Enum.sum(for s <- servicios_validos, s.dia == d, do: s.kilometros))
    end)

    dias = Enum.map(1..6, fn d ->
      km = Map.get(km_por_dia, d, 0)
      Util.mostrar("  Día #{d}: #{Utilidades.redondear(km)} km - #{if km >= Parametros.meta_diaria(), do: "CUMPLIÓ", else: "NO CUMPLIÓ"}", :mensaje)
      km >= Parametros.meta_diaria()
    end)

    Util.mostrar("  Meta todos los días: #{if Enum.all?(dias, & &1), do: "SÍ", else: "NO"}", :mensaje)
    km_por_dia
  end

  # R4: Liquidaciones ordenadas por neto
  def imprimir_r4(liquidaciones) do
    Util.mostrar("\n=== R4: LIQUIDACIÓN DE REPARTIDORES ===", :mensaje)

    Utilidades.ranking(liquidaciones, por: :neto, orden: :desc)
    |> Enum.each(fn l ->
      Util.mostrar("  #{l.nombre} (#{l.codigo}): Neto #{Utilidades.formato_pesos(l.neto)} (Km: #{Utilidades.redondear(l.kilometros)}, Serv: #{Utilidades.formato_pesos(l.valor_servicios)}, Bono: #{Utilidades.formato_pesos(l.bonificaciones)}, Alq: #{Utilidades.formato_pesos(l.alquiler)})", :mensaje)
    end)
  end

  # R5: Mejor repartidor por día y campeón semanal
  def imprimir_r5(servicios_validos, repartidores) do
    Util.mostrar("\n=== R5: MEJOR REPARTIDOR POR DÍA ===", :mensaje)

    mejores = Enum.map(1..6, fn d ->
      s_dia = Enum.filter(servicios_validos, &(&1.dia == d))
      tot = Enum.map(repartidores, fn r -> %{c: r.codigo, n: r.nombre, km: Enum.sum(for s <- s_dia, s.repartidor == r.codigo, do: s.kilometros)} end) |> Enum.filter(&(&1.km > 0))

      if tot == [], do: {d, []}, else: {d, Enum.filter(tot, &(&1.km == Enum.max(Enum.map(tot, fn x -> x.km end))))}
    end)

    Enum.each(mejores, fn {d, g} ->
      txt = Enum.map_join(g, ", ", fn r -> "#{r.n} (#{Utilidades.redondear(r.km)} km)" end)
      Util.mostrar("  Día #{d}: #{if g == [], do: "Sin servicios", else: txt}", :mensaje)
    end)

    ganadores = Enum.flat_map(mejores, fn {_d, g} -> g end)
    if ganadores != [] do
      max_d = Enum.group_by(ganadores, & &1.c) |> Enum.map(fn {c, l} -> {c, hd(l).n, length(l)} end) |> Enum.max_by(fn {_c, _n, d} -> d end) |> elem(2)
      camps = Enum.group_by(ganadores, & &1.c) |> Enum.map(fn {c, l} -> {c, hd(l).n, length(l)} end) |> Enum.filter(fn {_c, _n, d} -> d == max_d end)
      Util.mostrar("  Campeón semanal: " <> Enum.map_join(camps, ", ", fn {_c, n, d} -> "#{n} (#{d} días)" end), :mensaje)
    end
  end

  # R6: Mejor puntualidad (Promedio ponderado)
  def imprimir_r6(servicios_validos, repartidores) do
    Util.mostrar("\n=== R6: MEJOR PUNTUALIDAD (PONDERADA) ===", :mensaje)

    proms = Enum.group_by(servicios_validos, & &1.repartidor)
    |> Enum.filter(fn {_c, l} -> length(l) >= 3 end)
    |> Enum.map(fn {c, servs} ->
      tot_km = Enum.sum(Enum.map(servs, & &1.kilometros))
      pond = if tot_km > 0, do: Enum.sum(Enum.map(servs, &(&1.retraso * &1.kilometros))) / tot_km, else: 0.0
      %{c: c, n: Utilidades.buscar_nombre(c, repartidores), pond: pond}
    end)

    if proms != [] do
      g = Enum.min_by(proms, & &1.pond)
      Util.mostrar("  Ganador: #{g.n} (#{g.c}) - Promedio ponderado: #{Utilidades.redondear(g.pond)} min", :mensaje)
    end
  end

  # R7: Total pagado y costo promedio por km
  def imprimir_r7(liquidaciones) do
    Util.mostrar("\n=== R7: TOTAL PAGADO EN LA SEMANA ===", :mensaje)
    t_neto = Enum.sum(Enum.map(liquidaciones, & &1.neto))
    t_km = Enum.sum(Enum.map(liquidaciones, & &1.kilometros))
    Util.mostrar("  Total Pagado: #{Utilidades.formato_pesos(t_neto)} | Total Km: #{Utilidades.redondear(t_km)} | Costo/Km: #{Utilidades.formato_pesos(if t_km > 0, do: t_neto / t_km, else: 0.0)}", :mensaje)
  end

  # R8: Repartidores con servicio en todas las zonas
  def imprimir_r8(servicios_validos, zonas, repartidores) do
    Util.mostrar("\n=== R8: REPARTIDORES EN TODAS LAS ZONAS ===", :mensaje)
    t_zonas = length(zonas)

    for r <- repartidores, length(Enum.uniq(for s <- servicios_validos, s.repartidor == r.codigo, do: s.zona)) == t_zonas do
      Util.mostrar("  #{r.nombre} (#{r.codigo}) - Cobertura 100%", :mensaje)
    end
  end

  # Comprobante individual
  def imprimir_comprobante(liquidacion, servicios_validos) do
    Util.mostrar("\n=== COMPROBANTE DE PAGO: #{liquidacion.nombre} (#{liquidacion.codigo}) ===", :mensaje)
    servs = Enum.filter(servicios_validos, &(&1.repartidor == liquidacion.codigo))

    Enum.group_by(servs, & &1.dia)
    |> Enum.each(fn {d, s_dia} ->
      km = Enum.sum(Enum.map(s_dia, & &1.kilometros))
      val = Enum.sum(Enum.map(s_dia, &Liquidacion.valor_servicio/1))
      bono = if km >= Parametros.km_bonificacion(), do: Parametros.bonificacion_diaria(), else: 0
      Util.mostrar("  Día #{d}: #{Utilidades.redondear(km)} km | Serv: #{Utilidades.formato_pesos(val)} | Bono: #{Utilidades.formato_pesos(bono)}", :mensaje)
    end)

    Util.mostrar("  NETO A PAGAR: #{Utilidades.formato_pesos(liquidacion.neto)}\n========================================", :mensaje)
  end
end

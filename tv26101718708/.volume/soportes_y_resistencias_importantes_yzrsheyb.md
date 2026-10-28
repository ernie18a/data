# Soportes y Resistencias Importantes

- url: https://www.tradingview.com/script/yzRsHEYb/
- type: indicator
- pine_id: PUB;8cd7b8233f0247749995022bcda4d6cb
- version: 13.0

## Description

Soportes y Resistencias Importantes         
                                                                                                                                                                                                                          
  ¿Qué hace este indicador?
                                                                                                                                     
  Detecta automáticamente los niveles de soporte y resistencia más relevantes del gráfico basándose en el volumen real de mercado, no
   en fórmulas arbitrarias. La idea es simple: cuando el precio toca un nivel con un volumen muy elevado, ese nivel tiene memoria —  
  el mercado lo recuerda y suele reaccionar en él en el futuro.                                                                      
                  
  ---
  ¿Cómo funciona por dentro?
                            
  1. Busca picos de volumen — El indicador escanea el histórico visible en pantalla y localiza las barras donde el volumen fue
  notablemente superior a la media. Estos son momentos donde hubo una batalla real entre compradores y vendedores.                   
  2. Registra el precio de cierre en ese pico — El precio al que cerró esa barra de alto volumen se guarda como un nivel potencial.
  Es el precio donde el mercado "decidió" moverse con fuerza.                                                                        
  3. Agrupa niveles cercanos (clustering) — Si varios picos de volumen se produjeron cerca del mismo precio, el indicador los fusiona
   en un único nivel más preciso. Así evita mostrar cinco líneas casi idénticas.                                                     
  4. Clasifica automáticamente — Compara cada nivel con el precio actual:
    - Los niveles por debajo del precio → Soportes (azul por defecto)                                                                
    - Los niveles por encima del precio → Resistencias (amarillo por defecto)                                                        
  5. Muestra solo los más importantes — De todos los niveles detectados, filtra únicamente los top 5 soportes y top 5 resistencias   
  con mayor volumen asociado. Menos ruido, más señal.                                                                                
  6. Rango visible — Traza dos líneas extra marcando el máximo y mínimo del rango visible en pantalla, útil como referencia rápida de
   hasta dónde ha llegado el precio en el período analizado.                                                                         
                  
  ---                                                                                                                                
  ¿Qué muestra en pantalla?
                                                                                                                                     
  - Líneas horizontales extendidas a ambos lados del gráfico, en el color de soporte o resistencia según corresponda.
  - Etiquetas de precio encima de cada línea, alineadas a la derecha del gráfico, indicando el nivel exacto y cuántas veces ese      
  cluster fue confirmado (ej: 84.250 x3 = nivel tocado con alto volumen 3 veces).                                                    
  - Dos líneas de rango (máximo y mínimo visible) en colores diferenciados.                                                          
                                                                                                                                     
  ---             
  Configuración:                                                                                                                                                                                                                                                      
                                                                                                                                     
  La ventana de configuración se divide en cuatro secciones:
                                                                                                                                     
  - Volumen — controla qué tan exigente es el detector de picos (barras de contexto y multiplicador sobre la media)                  
  - Clustering — cuántos niveles mostrar como máximo y qué distancia porcentual hace que dos niveles se fusionen en uno
  - Soportes / Resistencias — color, grosor y estilo de línea para cada tipo                                                         
  - Rango visible — personalización de las líneas de máximo y mínimo del área visible                                                
                                                                                                                                     
  ---                                                                                                                                
  ¿Para quién es útil?                                                                                                               
                      
  Para cualquier trader que opere con price action y quiera tener en pantalla los niveles donde el mercado ha demostrado interés
  real, sin necesidad de dibujarlos manualmente. Funciona en cualquier activo (crypto, forex, acciones, futuros) y en cualquier      
  temporalidad.
                                                                                                                                     
  ▎ Nota: El indicador trabaja sobre las barras visibles en pantalla. Si haces zoom in o zoom out, los niveles se recalculan en  función del nuevo rango visible.

## Source Code

````pine
//@version=6
indicator("Soportes y Resistencias Importantes", overlay=true, max_bars_back=500, max_lines_count=200, max_labels_count=200)

grp_fix   = "Fijar"
grp_vol   = "Volumen"
grp_clust = "Clustering"
grp_sup   = "Soportes"
grp_res   = "Resistencias"
grp_rng   = "Rango (max/min)"
grp_vwap  = "VWAP Semanal"

i_fix = input.bool(false, "Fijar Soportes y Resistencias", group=grp_fix,
    tooltip="COMO FIJAR NIVELES:\n1. Elige la fecha de inicio en 'Fecha inicio'\n2. Activa este checkbox y guarda\n\nON  → niveles calculados desde la fecha elegida, valido para BTC, ETH o cualquier activo\nOFF → modo dinamico segun rango visible")

i_fix_date = input.time(timestamp("2025-01-01"), "Fecha inicio", group=grp_fix,
    tooltip="Fecha desde la que se calculan los S/R cuando 'Fijar' esta activado.\n\nUsar fecha en lugar de barras garantiza el mismo periodo historico para cualquier activo.\n\nEn modo dinamico (Fijar=OFF) este valor se ignora.")

i_vol_bars  = input.int(2,     "Barras +- pico volumen",   minval=1,   maxval=10,  group=grp_vol)
i_vol_mult  = input.float(1.3, "Multiplicador vol. medio", minval=0.5, maxval=5.0, step=0.1, group=grp_vol)
i_max_sup   = input.int(10,    "Max. soportes",            minval=1,   maxval=20,  group=grp_clust)
i_max_res   = input.int(10,    "Max. resistencias",        minval=1,   maxval=20,  group=grp_clust)
i_tolerance = input.float(3,   "Tolerancia cluster (%)",   minval=0.1, maxval=5.0, step=0.1, group=grp_clust)
i_sup_color = input.color(color.new(color.blue,   0), "Color soporte",    group=grp_sup)
i_sup_width = input.int(2, "Grosor", minval=1, maxval=5, group=grp_sup)
i_sup_style = input.string("Solida", "Estilo", options=["Solida","Punteada","Discontinua"], group=grp_sup)
i_res_color = input.color(color.new(color.yellow, 0), "Color resistencia", group=grp_res)
i_res_width = input.int(2, "Grosor", minval=1, maxval=5, group=grp_res)
i_res_style = input.string("Solida", "Estilo", options=["Solida","Punteada","Discontinua"], group=grp_res)
i_lbl_size  = input.string("Pequeno", "Tamano etiqueta", options=["Pequeno","Normal","Grande"])
i_rng_sup_color = input.color(color.new(color.aqua,   0), "Color minimo rango", group=grp_rng)
i_rng_res_color = input.color(color.new(color.orange, 0), "Color maximo rango", group=grp_rng)
i_rng_width     = input.int(2, "Grosor rango", minval=1, maxval=5, group=grp_rng)

i_vwap_show  = input.bool(true,  "Mostrar VWAP Semanal", group=grp_vwap)
i_vwap_color = input.color(color.new(color.purple, 0), "Color", group=grp_vwap)
i_vwap_width = input.int(2, "Grosor", minval=1, maxval=5, group=grp_vwap)
i_vwap_style = input.string("Solida", "Estilo", options=["Solida","Punteada","Discontinua"], group=grp_vwap)

f_lstyle(s) =>
    switch s
        "Punteada"    => line.style_dotted
        "Discontinua" => line.style_dashed
        => line.style_solid

f_lsize(s) =>
    switch s
        "Normal" => size.normal
        "Grande" => size.large
        => size.small

real_high  = request.security(syminfo.tickerid, timeframe.period, high,   lookahead=barmerge.lookahead_off)
real_low   = request.security(syminfo.tickerid, timeframe.period, low,    lookahead=barmerge.lookahead_off)
real_close = request.security(syminfo.tickerid, timeframe.period, close,  lookahead=barmerge.lookahead_off)
real_vol   = request.security(syminfo.tickerid, timeframe.period, volume, lookahead=barmerge.lookahead_off)

// ── VWAP Semanal ─────────────────────────────────────────────────────────────
is_new_week = ta.change(time("W")) != 0

var float _cum_pv = 0.0
var float _cum_v  = 0.0

if is_new_week
    _cum_pv := 0.0
    _cum_v  := 0.0

_typical = (real_high + real_low + real_close) / 3.0
_cum_pv  += _typical * real_vol
_cum_v   += real_vol

weekly_vwap = _cum_v > 0 ? _cum_pv / _cum_v : na

plot(weekly_vwap, "VWAP Semanal",
     color     = i_vwap_show ? i_vwap_color : color.new(color.purple, 100),
     linewidth = i_vwap_width,
     style     = i_vwap_style == "Punteada" ? plot.style_circles : plot.style_line,
     display   = display.all - display.status_line)

// ─────────────────────────────────────────────────────────────────────────────

eff_start_time = i_fix ? na : chart.left_visible_bar_time
in_range     = i_fix ? (time >= i_fix_date) : (not na(eff_start_time) and time >= eff_start_time)
in_rng_spike = i_fix ? (time[i_vol_bars] >= i_fix_date) : (not na(eff_start_time) and time[i_vol_bars] >= eff_start_time)

avg_vol  = ta.sma(real_vol, 20)
vol_peak = ta.pivothigh(real_vol, i_vol_bars, i_vol_bars)
is_spike = not na(vol_peak) and vol_peak >= nz(avg_vol[i_vol_bars]) * i_vol_mult
price_at = real_close[i_vol_bars]

var array<float> lvls        = array.new_float()
var array<float> vols        = array.new_float()
var array<int>   cnts        = array.new_int()
var array<int>   spike_times = array.new_int()
var array<line>  lines       = array.new_line()
var array<label> lbls        = array.new_label()

if is_spike and in_rng_spike and (not i_fix or barstate.ishistory)
    price      = price_at
    vol        = vol_peak
    spike_time = int(time[i_vol_bars])
    tol        = price * i_tolerance / 100.0
    idx        = -1
    if array.size(lvls) > 0
        for k = 0 to array.size(lvls) - 1
            if math.abs(array.get(lvls, k) - price) <= tol
                idx := k
                break
    if idx >= 0
        old     = array.get(lvls, idx)
        cnt     = array.get(cnts, idx)
        new_cnt = cnt + 1
        new_lvl = (old * cnt + price) / new_cnt
        array.set(lvls,        idx, new_lvl)
        array.set(cnts,        idx, new_cnt)
        array.set(vols,        idx, math.max(array.get(vols, idx), vol))
        array.set(spike_times, idx, math.max(array.get(spike_times, idx), spike_time))
        l  = array.get(lines, idx)
        lb = array.get(lbls,  idx)
        line.set_y1(l, new_lvl)
        line.set_y2(l, new_lvl)
        label.set_y(lb, new_lvl)
        label.set_text(lb, str.tostring(math.round(new_lvl, 0), "#"))
    else
        l  = line.new(bar_index - i_vol_bars, price, bar_index, price,
             color=color.gray, width=2, extend=extend.both)
        lb = label.new(bar_index, price,
             str.tostring(math.round(price, 0), "#"),
             style=label.style_label_left,
             color=color.new(color.black, 100),
             textcolor=color.gray,
             size=f_lsize(i_lbl_size))
        array.push(lvls,        price)
        array.push(vols,        vol)
        array.push(cnts,        1)
        array.push(spike_times, spike_time)
        array.push(lines,       l)
        array.push(lbls,        lb)

f_sort_vol(idx_arr, vol_arr) =>
    n = array.size(idx_arr)
    if n > 1
        for a = 0 to n - 2
            for b = 0 to n - a - 2
                ia = array.get(idx_arr, b)
                ib = array.get(idx_arr, b + 1)
                if array.get(vol_arr, ia) < array.get(vol_arr, ib)
                    array.set(idx_arr, b,     ib)
                    array.set(idx_arr, b + 1, ia)

var float run_high = na
var float run_low  = na

if not in_range
    run_high := na
    run_low  := na
else
    run_high := na(run_high) ? real_high : math.max(run_high, real_high)
    run_low  := na(run_low)  ? real_low  : math.min(run_low,  real_low)

// Visible price range (always based on current visible bars, independent of Fijar mode)
vis_left     = chart.left_visible_bar_time
vis_in_range = not na(vis_left) and time >= vis_left

var float vis_low  = na
var float vis_high = na

if not vis_in_range
    vis_low  := na
    vis_high := na
else
    vis_low  := na(vis_low)  ? real_low  : math.min(vis_low,  real_low)
    vis_high := na(vis_high) ? real_high : math.max(vis_high, real_high)

var line  rng_sup_line = na
var line  rng_res_line = na
var label rng_sup_lbl  = na
var label rng_res_lbl  = na

var table info_tbl = na

if barstate.islast
    hide_col    = color.new(color.black, 100)
    n           = array.size(lvls)
    cur         = real_close
    filter_time = int(chart.left_visible_bar_time)

    // Ocultar todo y mover a cur para no distorsionar auto-scale
    if n > 0
        for ii = 0 to n - 1
            l  = array.get(lines, ii)
            lb = array.get(lbls,  ii)
            line.set_color(l, hide_col)
            line.set_y1(l, cur)
            line.set_y2(l, cur)
            label.set_color(lb, hide_col)
            label.set_textcolor(lb, hide_col)
            label.set_y(lb, cur)

    info_txt = i_fix ? "S/R> " + str.format_time(i_fix_date, "dd/MM/yy-HH:mm", syminfo.timezone) : ""
    info_col = color.yellow

    if na(info_tbl)
        info_tbl := table.new(position.top_right, 1, 2,
             frame_color  = color.new(color.black, 100),
             frame_width  = 0,
             border_color = color.new(color.black, 100),
             border_width = 0)
    table.cell(info_tbl, 0, 0, "",
             height  = 3,
             bgcolor = color.new(color.black, 100))
    table.cell(info_tbl, 0, 1, info_txt,
             text_color = info_col,
             text_size  = size.normal,
             bgcolor    = color.new(color.black, 100))

    // Solo mostrar spikes dentro del rango temporal Y de precio visibles
    s_eli = array.new_int()
    if n > 0
        for ii = 0 to n - 1
            lvl = array.get(lvls, ii)
            if lvl < cur and array.get(spike_times, ii) >= filter_time and (na(vis_low) or lvl >= vis_low)
                array.push(s_eli, ii)
    f_sort_vol(s_eli, vols)
    show_s = math.min(i_max_sup, array.size(s_eli))
    if show_s > 0
        for ii = 0 to show_s - 1
            idx = array.get(s_eli, ii)
            l   = array.get(lines, idx)
            lb  = array.get(lbls,  idx)
            line.set_color(l, i_sup_color)
            line.set_width(l, i_sup_width)
            line.set_style(l, f_lstyle(i_sup_style))
            line.set_y1(l, array.get(lvls, idx))
            line.set_y2(l, array.get(lvls, idx))
            label.set_color(lb, i_sup_color)
            label.set_textcolor(lb, color.white)
            label.set_style(lb, label.style_label_left)
            label.set_size(lb, f_lsize(i_lbl_size))
            label.set_y(lb, array.get(lvls, idx))
            label.set_x(lb, bar_index)

    r_eli = array.new_int()
    if n > 0
        for ii = 0 to n - 1
            lvl = array.get(lvls, ii)
            if lvl > cur and array.get(spike_times, ii) >= filter_time and (na(vis_high) or lvl <= vis_high)
                array.push(r_eli, ii)
    f_sort_vol(r_eli, vols)
    show_r = math.min(i_max_res, array.size(r_eli))
    if show_r > 0
        for jj = 0 to show_r - 1
            idx = array.get(r_eli, jj)
            l   = array.get(lines, idx)
            lb  = array.get(lbls,  idx)
            line.set_color(l, i_res_color)
            line.set_width(l, i_res_width)
            line.set_style(l, f_lstyle(i_res_style))
            line.set_y1(l, array.get(lvls, idx))
            line.set_y2(l, array.get(lvls, idx))
            label.set_color(lb, i_res_color)
            label.set_textcolor(lb, color.black)
            label.set_style(lb, label.style_label_left)
            label.set_size(lb, f_lsize(i_lbl_size))
            label.set_y(lb, array.get(lvls, idx))
            label.set_x(lb, bar_index)

    // Mostrar rng lines solo si están dentro del rango de precio visible
    show_rng_sup = not na(run_low) and not na(vis_low) and run_low >= vis_low
    show_rng_res = not na(run_high) and not na(vis_high) and run_high <= vis_high

    if show_rng_sup
        if na(rng_sup_line)
            rng_sup_line := line.new(bar_index - 1, run_low, bar_index, run_low,
              extend=extend.both, color=i_rng_sup_color, width=i_rng_width)
            rng_sup_lbl := label.new(bar_index, run_low,
              str.tostring(math.round(run_low, 0), "#"),
              style=label.style_label_left,
              color=i_rng_sup_color, textcolor=color.black, size=f_lsize(i_lbl_size))
        else
            line.set_y1(rng_sup_line, run_low)
            line.set_y2(rng_sup_line, run_low)
            line.set_color(rng_sup_line, i_rng_sup_color)
            label.set_y(rng_sup_lbl, run_low)
            label.set_text(rng_sup_lbl, str.tostring(math.round(run_low, 0), "#"))
            label.set_color(rng_sup_lbl, i_rng_sup_color)
            label.set_textcolor(rng_sup_lbl, color.black)
            label.set_size(rng_sup_lbl, f_lsize(i_lbl_size))
        label.set_x(rng_sup_lbl, bar_index)
    else
        if not na(rng_sup_line)
            line.set_color(rng_sup_line, hide_col)
            line.set_y1(rng_sup_line, cur)
            line.set_y2(rng_sup_line, cur)
        if not na(rng_sup_lbl)
            label.set_color(rng_sup_lbl, hide_col)
            label.set_textcolor(rng_sup_lbl, hide_col)
            label.set_y(rng_sup_lbl, cur)

    if show_rng_res
        if na(rng_res_line)
            rng_res_line := line.new(bar_index - 1, run_high, bar_index, run_high,
              extend=extend.both, color=i_rng_res_color, width=i_rng_width)
            rng_res_lbl := label.new(bar_index, run_high,
              str.tostring(math.round(run_high, 0), "#"),
              style=label.style_label_left,
              color=i_rng_res_color, textcolor=color.black, size=f_lsize(i_lbl_size))
        else
            line.set_y1(rng_res_line, run_high)
            line.set_y2(rng_res_line, run_high)
            line.set_color(rng_res_line, i_rng_res_color)
            label.set_y(rng_res_lbl, run_high)
            label.set_text(rng_res_lbl, str.tostring(math.round(run_high, 0), "#"))
            label.set_color(rng_res_lbl, i_rng_res_color)
            label.set_textcolor(rng_res_lbl, color.black)
            label.set_size(rng_res_lbl, f_lsize(i_lbl_size))
        label.set_x(rng_res_lbl, bar_index)
    else
        if not na(rng_res_line)
            line.set_color(rng_res_line, hide_col)
            line.set_y1(rng_res_line, cur)
            line.set_y2(rng_res_line, cur)
        if not na(rng_res_lbl)
            label.set_color(rng_res_lbl, hide_col)
            label.set_textcolor(rng_res_lbl, hide_col)
            label.set_y(rng_res_lbl, cur)
````

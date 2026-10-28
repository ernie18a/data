# Buying Volume Spike Alert [Ale]

- url: https://www.tradingview.com/script/muDLyDPc-Buying-Volume-Spike-Alert-Ale/
- type: indicator
- pine_id: PUB;4e12caa382a24bafa5d2641de5e06fe8
- version: 1.0

## Description

BVS Alert — Buying Volume Spike Alert
This indicator watches for unusually large bursts of buying volume and flags them in real time.
It runs in its own pane below the chart. On every bar it splits the volume into buying volume (bars where close ≥ open) and selling volume (everything else), plotting buying volume as positive teal columns and selling volume as negative red columns. A 20-period simple moving average of total volume is drawn as the baseline reference.
The core logic compares the current analyzed volume against that moving average to get a spike ratio. If a bullish bar's volume is at least 2x the average, it's tagged "ALTO" (high); if it's at least 3x, it's tagged "EXTREMO" (extreme). Two horizontal threshold lines mark those 2x and 3x levels so you can see visually how far a bar pokes above them, with a shaded band between them.
When a spike fires, the bar gets recolored, a ⚡ or 🔥 label drops in, and the background tints. A small info table in the top-right shows current volume, the volume MA, the live spike ratio, the bar's delta (buy minus sell volume), and the current state. Finally it pushes alerts — both automatic alert() calls and alertcondition() hooks for the Create Alert dialog — so you get pinged the moment extreme or high buying volume shows up. The read is: big buying spike = potential bullish thrust / demand stepping in.

## Source Code

````pine
//@version=6
indicator("Buying Volume Spike Alert [Ale]", shorttitle="BVS Alert v6", overlay=false)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
grp1 = "Volume Settings"
vol_ma_len      = input.int(20,    "MA Volumen (periodos)",      minval=5,  maxval=100, group=grp1)
spike_mult_high = input.float(3.0, "Spike EXTREMO (x veces MA)", minval=1.5, step=0.5,  group=grp1)
spike_mult_med  = input.float(2.0, "Spike ALTO (x veces MA)",    minval=1.0, step=0.5,  group=grp1)
use_buy_only    = input.bool(true,  "Solo volumen de velas alcistas", group=grp1)

grp2 = "Visual"
col_extreme = input.color(color.new(#00e676, 0),   "Color Spike EXTREMO", group=grp2)
col_high    = input.color(color.new(#ffeb3b, 0),   "Color Spike ALTO",    group=grp2)
col_buy     = input.color(color.new(#26a69a, 70),  "Color Volumen compra",group=grp2)
col_sell    = input.color(color.new(#ef5350, 70),  "Color Volumen venta", group=grp2)

grp3 = "Alertas"
alert_extreme = input.bool(true, "Alerta Spike EXTREMO", group=grp3)
alert_high    = input.bool(true, "Alerta Spike ALTO",    group=grp3)

// ─────────────────────────────────────────────
// CÁLCULO DE VOLUMEN
// ─────────────────────────────────────────────

// Volumen de compra vs venta
is_bull      = close >= open
buy_vol      = is_bull ? volume : 0.0
sell_vol     = is_bull ? 0.0 : volume

// Volumen que analizar para el spike
vol_analyzed = use_buy_only ? buy_vol : volume

// Media móvil del volumen total como referencia base
vol_ma_base  = ta.sma(volume, vol_ma_len)
vol_ma_buy   = ta.sma(buy_vol, vol_ma_len)

// Ratio de spike (protegido contra na/0 en el periodo de calentamiento)
spike_ratio  = nz(vol_ma_base) > 0 ? vol_analyzed / vol_ma_base : 0.0

// Detección de spikes (solo en velas alcistas; warmup queda en false)
warmup           = na(vol_ma_base)
is_spike_extreme = not warmup and spike_ratio >= spike_mult_high and is_bull
is_spike_high    = not warmup and spike_ratio >= spike_mult_med  and spike_ratio < spike_mult_high and is_bull

// ─────────────────────────────────────────────
// DELTA ACUMULADO (Buying Pressure)
// ─────────────────────────────────────────────
delta        = buy_vol - sell_vol
cum_delta    = ta.cum(delta)
delta_ma     = ta.ema(delta, vol_ma_len)

// ─────────────────────────────────────────────
// PLOT — PANEL PRINCIPAL
// ─────────────────────────────────────────────

// Barras de volumen coloreadas
plot(buy_vol,  "Vol Compra", col_buy,  style=plot.style_columns)
plot(-sell_vol,"Vol Venta",  col_sell, style=plot.style_columns)

// MA volumen de referencia
plot(vol_ma_base, "MA Vol", color.new(color.white, 40), linewidth=1, style=plot.style_line)

// Umbrales visuales
hline_high    = plot(vol_ma_base * spike_mult_med,  "Umbral ALTO",    color.new(#ffeb3b, 60), linewidth=1, style=plot.style_line)
hline_extreme = plot(vol_ma_base * spike_mult_high, "Umbral EXTREMO", color.new(#00e676, 60), linewidth=1, style=plot.style_line)

// Relleno entre umbrales
fill(hline_high, hline_extreme, color.new(#ffeb3b, 92), "Zona ALTO")

// Markers de spike en las barras
barcolor(is_spike_extreme ? col_extreme : is_spike_high ? col_high : na)

// Labels en el panel
plotshape(is_spike_extreme, "EXTREMO", shape.labelup, location.bottom,
     col_extreme, size=size.small, text="🔥", textcolor=color.black)
plotshape(is_spike_high and not is_spike_extreme, "ALTO", shape.labelup, location.bottom,
     col_high, size=size.tiny, text="⚡", textcolor=color.black)

// Background en spikes
bgcolor(is_spike_extreme ? color.new(col_extreme, 88) : na, title="BG Extremo")
bgcolor(is_spike_high    ? color.new(col_high,    92) : na, title="BG Alto")

// ─────────────────────────────────────────────
// TABLA INFO ESQUINA
// ─────────────────────────────────────────────
var table info_table = table.new(position.top_right, 2, 6,
     bgcolor=color.new(color.black, 75),
     border_color=color.new(color.white, 70),
     border_width=1, frame_color=color.new(color.white,60), frame_width=1)

if barstate.islast
    table.cell(info_table, 0, 0, "BUYING VOLUME SPIKE",
         text_color=color.white, text_size=size.small, bgcolor=color.new(color.blue,70), text_halign=text.align_center)
    table.cell(info_table, 1, 0, "[Ale]",
         text_color=color.new(color.white,40), text_size=size.tiny, bgcolor=color.new(color.blue,70))

    table.cell(info_table, 0, 1, "Vol actual",    text_color=color.new(color.white,30), text_size=size.tiny)
    table.cell(info_table, 1, 1, str.tostring(volume, "#,###"),
         text_color=color.white, text_size=size.tiny)

    table.cell(info_table, 0, 2, "MA Vol(" + str.tostring(vol_ma_len) + ")", text_color=color.new(color.white,30), text_size=size.tiny)
    table.cell(info_table, 1, 2, str.tostring(vol_ma_base, "#,###"),
         text_color=color.white, text_size=size.tiny)

    table.cell(info_table, 0, 3, "Ratio spike",   text_color=color.new(color.white,30), text_size=size.tiny)
    ratio_color = spike_ratio >= spike_mult_high ? col_extreme :
                  spike_ratio >= spike_mult_med  ? col_high : color.white
    table.cell(info_table, 1, 3, str.tostring(spike_ratio, "#.##") + "x",
         text_color=ratio_color, text_size=size.tiny)

    table.cell(info_table, 0, 4, "Delta barra",   text_color=color.new(color.white,30), text_size=size.tiny)
    delta_col = delta >= 0 ? color.new(#26a69a,20) : color.new(#ef5350,20)
    table.cell(info_table, 1, 4, str.tostring(delta, "#,###"),
         text_color=delta_col, text_size=size.tiny)

    table.cell(info_table, 0, 5, "Estado",        text_color=color.new(color.white,30), text_size=size.tiny)
    estado_txt = is_spike_extreme ? "🔥 EXTREMO" : is_spike_high ? "⚡ ALTO" : "— Normal"
    estado_col = is_spike_extreme ? col_extreme  : is_spike_high ? col_high  : color.new(color.white,50)
    table.cell(info_table, 1, 5, estado_txt, text_color=estado_col, text_size=size.tiny)

// ─────────────────────────────────────────────
// ALERTAS
// ─────────────────────────────────────────────
if alert_extreme and is_spike_extreme
    alert("🔥 SPX BUYING SPIKE EXTREMO — Vol " + str.tostring(spike_ratio,"#.#") + "x la media | Precio: " + str.tostring(close,"#.##"), alert.freq_once_per_bar)

if alert_high and is_spike_high
    alert("⚡ SPX Buying Spike ALTO — Vol " + str.tostring(spike_ratio,"#.#") + "x la media | Precio: " + str.tostring(close,"#.##"), alert.freq_once_per_bar)

// Alerta combinada para usar en el botón "Create Alert"
alertcondition(is_spike_extreme, "🔥 Buying Spike EXTREMO", "Volumen de compra extremo detectado — posible impulso alcista")
alertcondition(is_spike_high,    "⚡ Buying Spike ALTO",    "Volumen de compra alto detectado")
alertcondition(is_spike_extreme or is_spike_high, "BVS — Cualquier Spike", "Spike de volumen de compra detectado")
````

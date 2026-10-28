# Selling Volume Spike Alert [Ale]

- url: https://www.tradingview.com/script/iPGVkeGg-Selling-Volume-Spike-Alert-Ale/
- type: indicator
- pine_id: PUB;1566de267dd24ac0b6baf78b58d9f2ee
- version: 1.0

## Description

VS Alert — Selling Volume Spike Alert
This is the mirror image: it watches for unusually large bursts of selling volume.
It uses the same structure but flips the subject. It defines a bearish bar as close < open and treats that bar's volume as selling volume. In its pane the selling volume points up (red columns) as the protagonist, with buying volume pointing down (teal). The same 20-period volume MA is the baseline.
The spike math is identical — selling volume divided by the average gives the spike ratio, tagged ALTO at 2x and EXTREMO at 3x, with the same threshold lines and shaded band. Spikes recolor the bar, drop a 💧 or 🔻 label at the top, and tint the background. The info table (top-right) mirrors the buying version: current volume, MA, spike ratio, delta, and state. Alerts and alertcondition() hooks fire on high/extreme selling volume, with distinct names so they don't collide with the buying indicator's alerts. The read here is the opposite: big selling spike = potential bearish pressure / distribution or de-risking.
How to read them together: an extreme spike on BVS with nothing on SVS is clean buying; the reverse is clean selling pressure; simultaneous spikes on both panes suggest a climax or absorption event — worth caution since those often precede reversals.

## Source Code

````pine
//@version=6
indicator("Selling Volume Spike Alert [Ale]", shorttitle="SVS Alert v6", overlay=false)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
grp1 = "Volume Settings"
vol_ma_len      = input.int(20,    "MA Volumen (periodos)",      minval=5,  maxval=100, group=grp1)
spike_mult_high = input.float(3.0, "Spike EXTREMO (x veces MA)", minval=1.5, step=0.5,  group=grp1)
spike_mult_med  = input.float(2.0, "Spike ALTO (x veces MA)",    minval=1.0, step=0.5,  group=grp1)
use_sell_only   = input.bool(true,  "Solo volumen de velas bajistas", group=grp1)

grp2 = "Visual"
col_extreme = input.color(color.new(#ff1744, 0),   "Color Spike EXTREMO", group=grp2)
col_high    = input.color(color.new(#ff9100, 0),   "Color Spike ALTO",    group=grp2)
col_sell    = input.color(color.new(#ef5350, 30),  "Color Volumen venta", group=grp2)
col_buy     = input.color(color.new(#26a69a, 70),  "Color Volumen compra",group=grp2)

grp3 = "Alertas"
alert_extreme = input.bool(true, "Alerta Spike EXTREMO", group=grp3)
alert_high    = input.bool(true, "Alerta Spike ALTO",    group=grp3)

// ─────────────────────────────────────────────
// CÁLCULO DE VOLUMEN
// ─────────────────────────────────────────────

// Vela bajista = close < open (espejo exacto del sell_vol del indicador de compra)
is_bear      = close < open
sell_vol     = is_bear ? volume : 0.0
buy_vol      = is_bear ? 0.0    : volume

// Volumen que analizar para el spike
vol_analyzed = use_sell_only ? sell_vol : volume

// Media móvil del volumen total como referencia base (igual que el de compra)
vol_ma_base  = ta.sma(volume, vol_ma_len)
vol_ma_sell  = ta.sma(sell_vol, vol_ma_len)

// Ratio de spike (protegido contra na/0 en el periodo de calentamiento)
spike_ratio  = nz(vol_ma_base) > 0 ? vol_analyzed / vol_ma_base : 0.0

// Detección de spikes (solo en velas bajistas; warmup queda en false)
warmup           = na(vol_ma_base)
is_spike_extreme = not warmup and spike_ratio >= spike_mult_high and is_bear
is_spike_high    = not warmup and spike_ratio >= spike_mult_med  and spike_ratio < spike_mult_high and is_bear

// ─────────────────────────────────────────────
// DELTA ACUMULADO (Selling Pressure)
// ─────────────────────────────────────────────
delta        = buy_vol - sell_vol
cum_delta    = ta.cum(delta)
delta_ma     = ta.ema(delta, vol_ma_len)

// ─────────────────────────────────────────────
// PLOT — PANEL PRINCIPAL (venta hacia ARRIBA, protagonista del panel)
// ─────────────────────────────────────────────

// Barras de volumen coloreadas: venta positiva (rojo), compra negativa (teal)
plot(sell_vol, "Vol Venta",  col_sell, style=plot.style_columns)
plot(-buy_vol, "Vol Compra", col_buy,  style=plot.style_columns)

// MA volumen de referencia
plot(vol_ma_base, "MA Vol", color.new(color.white, 40), linewidth=1, style=plot.style_line)

// Umbrales visuales (sobre el lado de venta, positivo)
hline_high    = plot(vol_ma_base * spike_mult_med,  "Umbral ALTO",    color.new(#ff9100, 60), linewidth=1, style=plot.style_line)
hline_extreme = plot(vol_ma_base * spike_mult_high, "Umbral EXTREMO", color.new(#ff1744, 60), linewidth=1, style=plot.style_line)

// Relleno entre umbrales
fill(hline_high, hline_extreme, color.new(#ff9100, 92), "Zona ALTO")

// Markers de spike en las barras
barcolor(is_spike_extreme ? col_extreme : is_spike_high ? col_high : na)

// Labels en el panel (arriba, para diferenciar del de compra)
plotshape(is_spike_extreme, "EXTREMO", shape.labeldown, location.top,
     col_extreme, size=size.small, text="🔻", textcolor=color.white)
plotshape(is_spike_high and not is_spike_extreme, "ALTO", shape.labeldown, location.top,
     col_high, size=size.tiny, text="💧", textcolor=color.black)

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
    table.cell(info_table, 0, 0, "SELLING VOLUME SPIKE",
         text_color=color.white, text_size=size.small, bgcolor=color.new(color.red,60), text_halign=text.align_center)
    table.cell(info_table, 1, 0, "[Ale]",
         text_color=color.new(color.white,40), text_size=size.tiny, bgcolor=color.new(color.red,60))

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
    estado_txt = is_spike_extreme ? "🔻 EXTREMO" : is_spike_high ? "💧 ALTO" : "— Normal"
    estado_col = is_spike_extreme ? col_extreme  : is_spike_high ? col_high  : color.new(color.white,50)
    table.cell(info_table, 1, 5, estado_txt, text_color=estado_col, text_size=size.tiny)

// ─────────────────────────────────────────────
// ALERTAS
// ─────────────────────────────────────────────
if alert_extreme and is_spike_extreme
    alert("🔻 SPX SELLING SPIKE EXTREMO — Vol " + str.tostring(spike_ratio,"#.#") + "x la media | Precio: " + str.tostring(close,"#.##"), alert.freq_once_per_bar)

if alert_high and is_spike_high
    alert("💧 SPX Selling Spike ALTO — Vol " + str.tostring(spike_ratio,"#.#") + "x la media | Precio: " + str.tostring(close,"#.##"), alert.freq_once_per_bar)

// Alerta combinada para usar en el botón "Create Alert"
alertcondition(is_spike_extreme, "🔻 Selling Spike EXTREMO", "Volumen de venta extremo detectado — posible impulso bajista")
alertcondition(is_spike_high,    "💧 Selling Spike ALTO",    "Volumen de venta alto detectado")
alertcondition(is_spike_extreme or is_spike_high, "SVS — Cualquier Spike", "Spike de volumen de venta detectado")
````

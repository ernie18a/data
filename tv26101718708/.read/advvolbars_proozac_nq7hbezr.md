# AdvVolBars [Proozac]

- url: https://www.tradingview.com/script/nQ7HbEZr-AdvVolBars-Proozac/
- type: indicator
- pine_id: PUB;558ce28313c74c8e914aa9a0392b493e
- version: 1.0

## Description

A colored volume indicator that visually identifies bars with significant volume relative to their historical average, replicating the visual style of advanced volume panels used in intraday futures setups.
How it works
Each volume bar is colored based on two factors: candle direction (bullish/bearish) and whether volume exceeds a configurable threshold relative to a long-term average (Slow MA, 929 periods by default). This produces 4 visual states:

🟢 Green — high bullish volume
🔵 Dim Cyan — low bullish volume
🟠 Orange — high bearish volume
🔴 Dark Red — low bearish volume

A yellow overlay line (Fast MA, 5 periods) helps visualize recent volume trend without comparing bars individually.
Info panel
The last bar displays a summary including: average volume per candle (Candle Avg), relative volume of the last 5 bars (Last 5 rVol %), cumulative session volume (Total Vol), current bar volume (LastBar Vol), and volume prior to regular session open (PreMkt Vol).
Configurable parameters

Fast MA Length / Slow MA Length
High volume threshold (multiplier over average)
Candle average lookback length
Fully customizable colors
Alerts for bullish/bearish volume spikes (rVol ≥ 2x)

Recommended use
Designed for intraday timeframes (1m–15m) on indices and futures, as volume confirmation alongside EMA and VWAP-based setups. Useful for spotting volume climax, trend exhaustion, or breakout confirmation.

## Source Code

````pine
//@version=6
indicator(title="AdvVolBars [WSGTA]", shorttitle="AdvVolBars", format=format.volume, precision=0)

// ─────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────
grp1 = "Volume Settings"
len_fast     = input.int(5,   "Fast MA Length",        minval=1, group=grp1)
len_slow     = input.int(929, "Slow MA Length (RVOL)", minval=10, group=grp1)
rvol_thresh  = input.float(1.5, "High Volume Threshold (xAvg)", minval=0.5, step=0.1, group=grp1, tooltip="Barras por encima de este múltiplo se colorean con intensidad alta")
candle_avg_len = input.int(400, "Candle Average Length", minval=10, group=grp1)

grp2 = "Colors"
col_bull_hi  = input.color(color.new(#00C853, 0),  "Bull — High Volume",  group=grp2)
col_bull_lo  = input.color(color.new(#00897B, 40), "Bull — Low Volume",   group=grp2)
col_bear_hi  = input.color(color.new(#FF6D00, 0),  "Bear — High Volume",  group=grp2)
col_bear_lo  = input.color(color.new(#B71C1C, 40), "Bear — Low Volume",   group=grp2)
col_ma       = input.color(color.new(#FFD600, 70), "Volume MA Line",      group=grp2)

grp3 = "Label / Info Bar"
show_label   = input.bool(true, "Show Info Label", group=grp3)
show_rvol    = input.bool(true, "Show rVol %",     group=grp3)
show_avg     = input.bool(true, "Show Candle Avg", group=grp3)
show_total   = input.bool(true, "Show Total Vol",  group=grp3)
show_pmkt    = input.bool(true, "Show PreMkt Vol", group=grp3)
show_last    = input.bool(true, "Show LastBar Vol",group=grp3)

// ─────────────────────────────────────────────
//  VOLUME CALCULATIONS
// ─────────────────────────────────────────────
vol = volume

// Dirección de la vela
is_bull = close >= open

// Media rápida (línea visual sobre las barras)
vol_ma_fast = ta.sma(vol, len_fast)

// Media lenta (base para el cálculo de RVOL)
vol_ma_slow = ta.sma(vol, len_slow)

// Relative Volume — múltiplo respecto a la media lenta
rvol = vol / vol_ma_slow

// Media de volumen por vela (últimas N barras)
candle_avg = ta.sma(vol, candle_avg_len)

// Volumen acumulado de la sesión
is_new_session = ta.change(time("D")) != 0
var float session_vol    = 0.0
var float premarket_vol  = 0.0
var float last5_vol_sum  = 0.0
var int   bar_count      = 0

// Detectar premarket (antes de las 09:30 ET = hora de apertura)
// En futuros /ES no hay premarket estricto, pero se usa como referencia la sesión nocturna
session_regular = not na(time("1D", "0930-1600"))  // true durante RTH

if is_new_session
    premarket_vol := 0.0
    session_vol   := 0.0
    bar_count     := 0

if not session_regular
    premarket_vol += vol

session_vol += vol
bar_count   += 1

// Last 5 rVol (promedio de las últimas 5 barras vs media)
last5_rvol = ta.sma(rvol, 5)

// ─────────────────────────────────────────────
//  COLOREADO DE BARRAS
// ─────────────────────────────────────────────
// Alta/baja intensidad según si supera el umbral
is_high_vol = rvol >= rvol_thresh

bar_color = is_bull
     ? (is_high_vol ? col_bull_hi : col_bull_lo)
     : (is_high_vol ? col_bear_hi : col_bear_lo)

// ─────────────────────────────────────────────
//  PLOTS
// ─────────────────────────────────────────────
plot(vol,         "Volume",     color=bar_color,   style=plot.style_columns, linewidth=1)
plot(vol_ma_fast, "Vol MA",     color=col_ma,      style=plot.style_line,    linewidth=2)
plot(vol_ma_slow, "Vol MA Slow",color=color.new(color.white, 85), style=plot.style_line, linewidth=1)

// Línea de referencia — volumen promedio
hline(0, "Zero", color=color.new(color.white, 90))

// ─────────────────────────────────────────────
//  LABEL INFO BAR (última barra)
// ─────────────────────────────────────────────
if barstate.islast and show_label
    rvol_pct   = math.round(last5_rvol * 100)
    avg_str    = show_avg   ? "Candle Avg: "   + str.tostring(math.round(candle_avg))  + "  " : ""
    rvol_str   = show_rvol  ? "Last 5 rVol: "  + str.tostring(rvol_pct) + "%  "               : ""
    total_str  = show_total ? "Total Vol: "    + str.tostring(math.round(session_vol / 1000)) + "K  " : ""
    last_str   = show_last  ? "LastBar Vol: "  + str.tostring(math.round(vol))                + "  " : ""
    pmkt_str   = show_pmkt  ? "PreMkt Vol: "   + str.tostring(math.round(premarket_vol / 1000)) + "K" : ""

    label_txt = avg_str + rvol_str + total_str + last_str + pmkt_str

    label.new(
         x           = bar_index,
         y           = vol_ma_fast,
         text        = label_txt,
         style       = label.style_label_left,
         color       = color.new(color.black, 80),
         textcolor   = color.white,
         size        = size.small
         )

// ─────────────────────────────────────────────
//  ALERTAS
// ─────────────────────────────────────────────
alertcondition(rvol >= 2.0 and is_bull,  "Bull High Volume Spike",  "Volumen alcista alto — rVol ≥ 2x")
alertcondition(rvol >= 2.0 and not is_bull, "Bear High Volume Spike","Volumen bajista alto — rVol ≥ 2x")
````

# S/R + Confirmare Intrare

- url: https://www.tradingview.com/script/JGyuWsGw-S-R-Confirmare-Intrare/
- type: indicator
- pine_id: PUB;4c3afb99d9674bd8b909f5a2e4018c80
- version: 1.0

## Description

script de test bazat pe suport si rezistenta cu confirmare la intrare

## Source Code

````pine
//@version=5
indicator("S/R + Confirmare Intrare", overlay=true, max_lines_count=500, max_labels_count=500)

// ==========================================
// 📊 SETĂRI DIN INTERFAȚĂ (INPUTS)
// ==========================================
i_lookback   = input.int(50, "Perioadă Scanare (Bare)", minval=20, group="1. Detectare S/R")
i_min_touches= input.int(3, "Atingeri Minime Nivel", minval=2, step=1, group="1. Detectare S/R")
i_pivot_L    = input.int(5, "Pivot Stânga", minval=2, group="1. Detectare S/R")
i_pivot_R    = input.int(5, "Pivot Dreapta", minval=2, group="1. Detectare S/R")
i_tolerance  = input.float(0.25, "Toleranță Atingere (%)", step=0.05, group="1. Detectare S/R")

i_draw_sltp  = input.bool(true, "Desenează SL & TP Automate", group="2. Management Trade")
i_sl_method  = input.string("ATR", "Metodă Calcul SL", options=["ATR", "Swing Recent"], group="2. Management Trade")
i_atr_len    = input.int(14, "Lungime ATR (dacă e activ)", group="2. Management Trade")
i_atr_mult   = input.float(1.5, "Multiplicator ATR pentru SL", step=0.1, group="2. Management Trade")
i_rr1        = input.float(1.0, "RR 1 (Take Profit)", group="2. Management Trade")
i_rr2        = input.float(1.5, "RR 2 (Take Profit)", group="2. Management Trade")

i_show_alert = input.bool(true, "Activează Alertă la Semnal", group="3. Alertă & Vizual")
i_max_levels = input.int(12, "Max Niveluri Vizibile", minval=5, maxval=30, group="3. Alertă & Vizual")

// ==========================================
// 🔍 DETECTARE PIVOȚI & STOCARE NIVELURI
// ==========================================
ph = ta.pivothigh(high, i_pivot_L, i_pivot_R)
pl = ta.pivotlow(low, i_pivot_L, i_pivot_R)

// Array-uri pentru stocarea nivelurilor și a barelor de origine
var array<float> lv_prices = array.new_float()
var array<int>   lv_bars   = array.new_int()
var array<string> lv_types = array.new_string()

// Adăugare pivots noi (doar pe bara confirmată)
if barstate.isconfirmed
    if not na(pl)
        array.push(lv_prices, pl)
        array.push(lv_bars, bar_index)
        array.push(lv_types, "S")
    if not na(ph)
        array.push(lv_prices, ph)
        array.push(lv_bars, bar_index)
        array.push(lv_types, "R")
    
    // Păstrăm doar ultimele X niveluri pentru performanță
    while array.size(lv_prices) > i_max_levels * 2
        array.shift(lv_prices)
        array.shift(lv_bars)
        array.shift(lv_types)

// ==========================================
// ✅ VALIDARE NIVELURI (NUMĂRARE ATINGERI)
// ==========================================
count_touches(level, tolerance_pct) =>
    hits = 0
    for i = 0 to i_lookback
        price_range_val = level * tolerance_pct / 100
        if math.abs(high[i] - level) <= price_range_val or math.abs(low[i] - level) <= price_range_val
            hits += 1
    hits

// Desenare niveluri valide
for idx = 0 to array.size(lv_prices) - 1
    price = array.get(lv_prices, idx)
    origin_bar = array.get(lv_bars, idx)
    typ = array.get(lv_types, idx)
    
    if bar_index - origin_bar <= i_lookback
        touches = count_touches(price, i_tolerance)
        if touches >= i_min_touches
            // Desenează linie albastră conform cerinței
            line.new(x1=origin_bar, y1=price, x2=bar_index, y2=price, 
                     color=color.new(color.blue, 30), width=2, extend=extend.right, xloc=xloc.bar_index)

// ==========================================
// 🕯️ DETECTARE FORMAȚII DE CANDELE
// ==========================================
body = math.abs(close - open)
// FIX: Redenumit 'range' în 'bar_range' (cuvânt rezervat în Pine Script v5)
bar_range = high - low 

is_pinbar_long  = (low < close and low < open) and (bar_range > 0) and (body / bar_range < 0.3) and (math.abs(open - low) > body * 2)
is_pinbar_short = (high > close and high > open) and (bar_range > 0) and (body / bar_range < 0.3) and (math.abs(high - close) > body * 2)
is_bull_engulf  = close[1] < open[1] and close > open and open <= close[1] and close >= open[1]
is_bear_engulf  = close[1] > open[1] and close < open and open >= close[1] and close <= open[1]
is_doji         = body / bar_range < 0.15 and bar_range > ta.atr(14) * 0.5

// ==========================================
// 🎯 GENERARE SEMNAL + SL/TP AUTOMAT
// ==========================================
var line sl_line = na
var line tp1_line = na
var line tp2_line = na
var label entry_label = na

// Curățare elemente vechi
if barstate.isconfirmed
    line.delete(sl_line)
    line.delete(tp1_line)
    line.delete(tp2_line)
    label.delete(entry_label)

long_signal  = false
short_signal = false
// FIX: Inițializare cu 0.0 în loc de na (sau folosește: float entry_price = na)
entry_price  = 0.0
sl_price     = 0.0
tp1_price    = 0.0
tp2_price    = 0.0

// Verificare apropiere de nivel valid
for idx = 0 to array.size(lv_prices) - 1
    price = array.get(lv_prices, idx)
    typ = array.get(lv_types, idx)
    dist = math.abs(close - price) / price * 100
    
    if dist <= i_tolerance * 1.2 and barstate.isconfirmed
        if typ == "S" and (is_pinbar_long or is_bull_engulf or is_doji)
            long_signal := true
            entry_price := close
        if typ == "R" and (is_pinbar_short or is_bear_engulf or is_doji)
            short_signal := true
            entry_price := close

// Calcul SL & TP
if long_signal or short_signal
    atr_val = ta.atr(i_atr_len)
    
    if i_sl_method == "ATR"
        sl_price := long_signal ? entry_price - (atr_val * i_atr_mult) : entry_price + (atr_val * i_atr_mult)
    else
        // Swing recent ca fallback
        sl_price := long_signal ? ta.lowest(low, 20) : ta.highest(high, 20)
    
    risk = math.abs(entry_price - sl_price)
    tp1_price := long_signal ? entry_price + (risk * i_rr1) : entry_price - (risk * i_rr1)
    tp2_price := long_signal ? entry_price + (risk * i_rr2) : entry_price - (risk * i_rr2)

    if i_draw_sltp
        // FIX: Adăugat xloc=xloc.bar_index pentru toate liniile
        sl_line   := line.new(bar_index, sl_price, bar_index + 20, sl_price, color=color.red, width=2, extend=extend.right, style=line.style_dashed, xloc=xloc.bar_index)
        tp1_line  := line.new(bar_index, tp1_price, bar_index + 20, tp1_price, color=color.green, width=1, extend=extend.right, xloc=xloc.bar_index)
        tp2_line  := line.new(bar_index, tp2_price, bar_index + 20, tp2_price, color=color.green, width=1, extend=extend.right, style=line.style_dotted, xloc=xloc.bar_index)
    
    entry_label := label.new(bar_index, long_signal ? low - ta.atr(14)*0.5 : high + ta.atr(14)*0.5, 
                             text=long_signal ? "🟢 LONG" : "🔴 SHORT", 
                             color=long_signal ? color.new(color.green, 70) : color.new(color.red, 70), 
                             textcolor=color.white, style=label.style_label_up)

// ==========================================
// 🔔 ALERTĂ & CONDITII
// ==========================================
alertcondition(long_signal, title="Semnal LONG Confirmat", message="S/R LONG validat cu confirmare candelă.")
alertcondition(short_signal, title="Semnal SHORT Confirmat", message="S/R SHORT validat cu confirmare candelă.")

plotshape(long_signal, title="Long Signal", location=location.belowbar, color=color.green, style=shape.triangleup, size=size.small)
plotshape(short_signal, title="Short Signal", location=location.abovebar, color=color.red, style=shape.triangledown, size=size.small)
````

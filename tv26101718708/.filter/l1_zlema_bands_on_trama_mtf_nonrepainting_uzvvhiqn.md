# L1 ZLEMA Bands on TRAMA (MTF Non-Repainting)

- url: https://www.tradingview.com/script/uzVvHiQN-L1-ZLEMA-Bands-on-TRAMA-MTF-Non-Repainting/
- type: indicator
- pine_id: PUB;5cd01a070e1a4e8daf56a88976e661d7
- version: 1.0

## Description

A MA tool that put TRAMA(slow trend reaction) data into Zero Leg EMA formula

## Source Code

````pine
//@version=5
indicator("L1 ZLEMA Bands on TRAMA (MTF Non-Repainting)", shorttitle="L1 ZLEMA on TRAMA MTF", overlay=true, max_labels_count=500)

// ── Inputs ──
tf_input       = input.timeframe("5", title="TRAMA + ZLEMA Timeframe (blank = chart tf)")
trama_length   = input.int(125, minval=1, title="TRAMA Length")
zlema_length   = input.int(21, minval=1, title="ZLEMA Length")
multiplier     = input.float(1.0, step=0.1, title="Band Multiplier")
price_source   = input.source(close, title="Price Source for Crossovers (chart tf)")
show_trama     = input.bool(true,  title="Show TRAMA Line")
show_bands     = input.bool(true,  title="Show Bands & Fill")

// ── Calculation function ──
f_calc() =>
    // TRAMA on the requested timeframe
    var float ama = na
    hh = math.max(math.sign(ta.change(ta.highest(trama_length))), 0)
    ll = math.max(math.sign(ta.change(ta.lowest(trama_length)) * -1), 0)
    tc = math.pow(ta.sma(hh or ll ? 1 : 0, trama_length), 2)
    ama := nz(ama[1] + tc * (close - ama[1]), close)

    base = ama

    // ZLEMA on base
    alpha = 2.0 / (zlema_length + 1)
    var float prev_ema = na
    ema_val = na(prev_ema) ? ta.sma(base, zlema_length) : (base - prev_ema) * alpha + prev_ema
    prev_ema := ema_val

    dev    = multiplier * ta.stdev(base, zlema_length)
    upper  = ema_val + dev
    lower  = ema_val - dev

    // Return OFFSET values here (previous confirmed bar on HTF)
    [ama[1], ema_val[1], upper[1], lower[1]]

// ── Request confirmed previous bar values from HTF (non-repainting) ──
[htf_trama, htf_zlema, htf_upper, htf_lower] = request.security(
     syminfo.tickerid, 
     tf_input == "" ? timeframe.period : tf_input, 
     f_calc(), 
     gaps     = barmerge.gaps_off, 
     lookahead = barmerge.lookahead_on
     )

// ── Plots ──
p_zlema  = plot(show_bands ? htf_zlema  : na, color=color.yellow, title="ZLEMA on TRAMA", linewidth=2)
p_upper  = plot(show_bands ? htf_upper  : na, color=color.yellow, title="Upper Band")
p_lower  = plot(show_bands ? htf_lower  : na, color=color.yellow, title="Lower Band")

fill(p_upper, p_lower, color = show_bands ? color.new(color.fuchsia, 82) : na, title="Band Fill")

plot(show_trama ? htf_trama : na, title="TRAMA Base", color=color.new(color.orange, 40), linewidth=1)

// ── Signals: chart-timeframe price crossing HTF bands ──
buySignal  = ta.crossunder(price_source, htf_lower)
sellSignal = ta.crossover(price_source, htf_upper)

if buySignal
    label.new(bar_index, low, "Buy", style=label.style_label_up, color=color.green, textcolor=color.white, size=size.small)

if sellSignal
    label.new(bar_index, high, "Sell", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)

// ── Alerts ──
alertcondition(buySignal,  title="Buy  – Price crossed under HTF Lower Band",  message="Buy: Price crossed under higher-TF ZLEMA lower band")
alertcondition(sellSignal, title="Sell – Price crossed over HTF Upper Band",   message="Sell: Price crossed over higher-TF ZLEMA upper band")
````

# TradingConToto DCA

- url: https://www.tradingview.com/script/Bd8i2LEZ/
- type: indicator
- pine_id: PUB;e22db4ba26ae42489eac5044ab3af718
- version: 1.0

## Description

TradingConToto DCA

The TradingConToto DCA indicator is a trend-following tool designed to help traders identify high-probability market conditions using a structured EMA hierarchy.

Instead of relying on subjective analysis, the indicator evaluates the relationship between four Exponential Moving Averages (20, 50, 200 and 800) to determine whether the market is in a bullish trend, bearish trend, or ranging environment.

Features

• Automatic trend detection using EMA alignment
• Dynamic EMA coloring based on market structure
• Trend clouds for improved visual clarity
• Macro trend visualization between the 200 EMA and 800 EMA
• Automatic BUY and SELL confirmation labels when a new trend begins
• Clean, minimalist interface designed for discretionary traders

Trend Logic

Bullish Trend

EMA 20 > EMA 50 > EMA 200 > EMA 800

Bearish Trend

EMA 20 < EMA 50 < EMA 200 < EMA 800

Any other configuration is considered a ranging market.

BUY Confirmation

A BUY signal appears only when the market transitions into a valid bullish EMA alignment.

SELL Confirmation

A SELL signal appears only when the market transitions into a valid bearish EMA alignment.

Signals are generated only on the first confirmation bar to avoid unnecessary repetitions.

Best Used For

• Trend Following
• Swing Trading
• Position Trading
• Index CFDs
• Stocks
• Forex
• Commodities
• Cryptocurrencies

Disclaimer

This indicator is designed to identify market structure and trend confirmation. It should be used as part of a complete trading plan with proper risk management and is not financial advice.

## Source Code

````pine
//@version=6
indicator("TradingConToto DCA", overlay=true, max_labels_count=500)

// ─── INPUTS ──────────────────────────────────────────────────
var g1 = "═══ Períodos"
p1 = input.int(20,  "EMA 1", minval=1, group=g1)
p2 = input.int(50,  "EMA 2", minval=1, group=g1)
p3 = input.int(200, "EMA 3", minval=1, group=g1)
p4 = input.int(800, "EMA 4", minval=1, group=g1)

var g2 = "═══ Visual"
show_clouds = input.bool(true, "Mostrar nubes", group=g2)
show_labels = input.bool(true, "Mostrar etiquetas EMAs", group=g2)
show_signals = input.bool(true, "Mostrar señales BUY / SELL", group=g2)

// ─── EMAs ────────────────────────────────────────────────────
e1 = ta.ema(close, p1)
e2 = ta.ema(close, p2)
e3 = ta.ema(close, p3)
e4 = ta.ema(close, p4)

// ─── ESTADO ──────────────────────────────────────────────────
alcista = e1 > e2 and e2 > e3 and e3 > e4
bajista = e1 < e2 and e2 < e3 and e3 < e4
rango   = not alcista and not bajista

// ─── COLORES ─────────────────────────────────────────────────
buy_color   = color.rgb(0, 200, 120)
sell_color  = color.rgb(230, 40, 70)
range_color = color.rgb(130, 140, 155)
macro_blue  = color.rgb(37, 99, 235)

main_color = alcista ? buy_color : bajista ? sell_color : range_color

// ─── NUBES ───────────────────────────────────────────────────
cloud_1 = color.new(main_color, 84)
cloud_2 = color.new(main_color, 89)
cloud_3 = color.new(macro_blue, 88)

// ─── PLOTS EMAs ──────────────────────────────────────────────
p_e1 = plot(e1, "EMA 20",  color=main_color, linewidth=3)
p_e2 = plot(e2, "EMA 50",  color=color.new(main_color, 10), linewidth=2)
p_e3 = plot(e3, "EMA 200", color=color.new(main_color, 20), linewidth=3)
p_e4 = plot(e4, "EMA 800", color=macro_blue, linewidth=4)

// ─── NUBES ENTRE EMAs ────────────────────────────────────────
fill(p_e1, p_e2, color=show_clouds ? cloud_1 : na, title="Nube 20-50")
fill(p_e2, p_e3, color=show_clouds ? cloud_2 : na, title="Nube 50-200")
fill(p_e3, p_e4, color=show_clouds ? cloud_3 : na, title="Nube 200-800")

// ─── LABELS DE EMAs A LA DERECHA ─────────────────────────────
var label lbl1 = na
var label lbl2 = na
var label lbl3 = na
var label lbl4 = na

if barstate.islast and show_labels
    label.delete(lbl1)
    label.delete(lbl2)
    label.delete(lbl3)
    label.delete(lbl4)

    lbl1 := label.new(bar_index + 2, e1, "EMA " + str.tostring(p1),
         style=label.style_label_left,
         color=main_color,
         textcolor=color.white,
         size=size.small)

    lbl2 := label.new(bar_index + 2, e2, "EMA " + str.tostring(p2),
         style=label.style_label_left,
         color=main_color,
         textcolor=color.white,
         size=size.small)

    lbl3 := label.new(bar_index + 2, e3, "EMA " + str.tostring(p3),
         style=label.style_label_left,
         color=main_color,
         textcolor=color.white,
         size=size.small)

    lbl4 := label.new(bar_index + 2, e4, "EMA " + str.tostring(p4),
         style=label.style_label_left,
         color=macro_blue,
         textcolor=color.white,
         size=size.small)

// ─── SEÑALES NUEVAS ──────────────────────────────────────────
alcista_nuevo = alcista and not alcista[1]
bajista_nuevo = bajista and not bajista[1]

atr = ta.atr(14)

// ─── SEÑAL BUY ESTILO LUX ────────────────────────────────────
if show_signals and alcista_nuevo
    label.new(
         bar_index,
         low - atr * 0.8,
         text="BUY CONFIRMATION",
         style=label.style_label_up,
         color=color.new(buy_color, 0),
         textcolor=color.white,
         size=size.normal
    )

// ─── SEÑAL SELL ESTILO LUX ───────────────────────────────────
if show_signals and bajista_nuevo
    label.new(
         bar_index,
         high + atr * 0.8,
         text="SELL CONFIRMATION",
         style=label.style_label_down,
         color=color.new(sell_color, 0),
         textcolor=color.white,
         size=size.normal
    )
````

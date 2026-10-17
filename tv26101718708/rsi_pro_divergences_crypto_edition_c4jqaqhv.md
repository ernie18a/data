# RSI Pro Divergences: Crypto Edition

- url: https://www.tradingview.com/script/C4jqaQhv-RSI-Pro-Divergences-Crypto-Edition/
- type: indicator
- pine_id: PUB;b48234dae03f4e35be1f4428b3b9892f
- version: 1.0

## Description

# RSI Pro Divergences — Crypto Edition

A professional-grade RSI divergence detector built from the ground up in 
Pine Script v6, specifically optimized for cryptocurrency markets 
(BTC, ETH, SOL, LTC and altcoins) across all timeframes.

This indicator automatically identifies and visualizes the 4 key types of 
RSI divergences, displays them with clear labels and connecting lines, 
and provides a real-time status dashboard — everything an active trader 
needs to spot high-probability reversal and continuation setups.

---

## 🎯 What It Detects

**▲ Regular Bullish Divergence** — Price prints a Lower Low while RSI 
prints a Higher Low. Classic reversal signal at the end of a downtrend; 
strong setup at support zones, springs, or accumulation phases.

**▼ Regular Bearish Divergence** — Price prints a Higher High while RSI 
prints a Lower High. Classic reversal signal at the end of an uptrend; 
strong setup at resistance, UTADs, or distribution phases.

**△ Hidden Bullish Divergence** — Price prints a Higher Low while RSI 
prints a Lower Low. Continuation signal during pullbacks within an 
established uptrend. Great for trend-following entries.

**▽ Hidden Bearish Divergence** — Price prints a Lower High while RSI 
prints a Higher High. Continuation signal during retraces within an 
established downtrend.

---

## 🚀 Key Features

- **Pine Script v6** — Built on TradingView's latest engine for 
  maximum speed, type safety, and future-proofing

- **All 4 divergence types** — Regular and Hidden, both Bullish and 
  Bearish, each independently toggleable

- **Connecting lines between pivots** — Visualizes the divergence 
  directly on the RSI panel (solid for Regular, dashed for Hidden)

- **Differentiated labels** — BULL / H.BULL / BEAR / H.BEAR so you 
  can instantly distinguish reversal from continuation signals

- **Triangle markers** — Aligned to the actual pivot bar (not the 
  confirmation bar) using offset compensation

- **Dual overbought/oversold zones** — Standard (70/30) plus Extreme 
  (80/20) with shaded background for instant visual context

- **Real-time dashboard** — Shows current RSI value, market zone, 
  last divergence detected, and how many bars ago it appeared

- **6 alert conditions** — One per divergence type plus OB/OS crosses, 
  fully customizable for webhooks and notifications

- **Fully configurable** — Period, source, pivot lookbacks, range 
  filters, colors, and dashboard position all adjustable via inputs

---

## ⚙️ Recommended Settings by Timeframe

| Timeframe | RSI Period | Pivot L/R | Range Min/Max | Use Case          |
|-----------|------------|-----------|---------------|-------------------|
| 5m        | 10         | 3 / 3     | 5 / 40        | Scalping entries  |
| 15m       | 12         | 4 / 4     | 5 / 50        | Intraday          |
| 1H        | 14         | 5 / 5     | 5 / 60        | Short-term swing  |
| 4H        | 14         | 5 / 5     | 5 / 60        | Macro validation  |
| 1D        | 14         | 7 / 7     | 5 / 80        | Weekly structure  |

---

## 📊 How to Use

1. **Apply to chart** — Adds a new sub-panel with the RSI and signals
2. **Set your timeframe** — Use the table above as a starting point
3. **Watch the dashboard** — Top-right corner shows live RSI status
4. **Confirm with context** — Divergences work best when combined with:
   - Support/resistance zones
   - Volume confirmation
   - Higher timeframe trend alignment
   - Order flow or market structure analysis

5. **Set alerts** — Right-click any signal → Add Alert → choose 
   the divergence type you want to be notified about

---

## ⚠️ Important Notes

**This is an indicator, not a complete trading system.** Divergences are 
high-probability signals but should never be traded in isolation. Always 
combine with proper risk management, position sizing, and confluence 
from other tools (volume, structure, higher timeframes, macro context).

**On repainting:** Pivots are confirmed N bars after they form (where N 
equals the right lookback). This means signals appear with a small delay 
but do NOT repaint once confirmed. Lower lookback values reduce delay 
but increase noise.

**Best results in crypto:** This indicator was tuned specifically for 
24/7 markets with high volatility. It also works on stocks, forex, 
and futures, but parameters may need adjustment for those markets.

---

## 🔧 Technical Details

- Language: Pine Script v6
- Type: Indicator (study), non-overlay
- Performance: Up to 500 lines and 500 labels rendered
- Repainting: Confirmed pivots only (delayed but stable)
- Resource usage: Lightweight, suitable for multi-chart layouts

---

## 📜 Credits

Built on the divergence detection logic originally popularized in the 
TradingView community, completely rewritten and modernized in Pine v6 
with crypto-specific optimizations, visual enhancements, dashboard 
integration, and alert system.

Open source — feel free to fork, modify, and improve. If you find this 
useful, a like and comment would be appreciated!

---

**Happy trading. Stay patient. Trust the system.** 🎯

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════
//   RSI Pro Divergences: Crypto Edition
//   Versión:  1.0  |  Pine Script v6
//   Tipo:     Indicador (study) — no ejecuta trades
//   Activos:  BTC, ETH, SOL, LTC y demás cripto — cualquier timeframe
//
//   Detecta automáticamente 4 tipos de divergencias RSI:
//     ▲ Regular Bullish  — reversión alcista  (precio LL / RSI HL)
//     ▼ Regular Bearish  — reversión bajista  (precio HH / RSI LH)
//     △ Hidden  Bullish  — continuación alcista (precio HL / RSI LL)
//     ▽ Hidden  Bearish  — continuación bajista (precio LH / RSI HH)
// ═══════════════════════════════════════════════════════════════════════

indicator(
     title             = "RSI Pro Divergences — Crypto Edition",
     shorttitle        = "RSI Pro Div",
     overlay           = false,
     format            = format.price,
     precision         = 2,
     max_lines_count   = 500,
     max_labels_count  = 500
 )

// ═══════════════════════════════════════════════════════════════════════
//   1. INPUTS
// ═══════════════════════════════════════════════════════════════════════

// ── RSI ──
gRSI   = "📊 Configuración RSI"
rsiLen = input.int(14, "Período RSI", minval=2, maxval=200, group=gRSI,
                   tooltip="14 estándar | 10 para entradas en 5m | 9 más rápido")
rsiSrc = input.source(close, "Fuente", group=gRSI)
obLvl  = input.int(70, "Sobrecompra (OB)", minval=51, maxval=99, group=gRSI)
osLvl  = input.int(30, "Sobreventa  (OS)", minval=1,  maxval=49, group=gRSI)
extOB  = input.int(80, "OB Extremo",       minval=70, maxval=99, group=gRSI)
extOS  = input.int(20, "OS Extremo",       minval=1,  maxval=30, group=gRSI)

// ── Divergencias ──
gDiv     = "🎯 Detección de Divergencias"
lbL      = input.int(5,  "Lookback Izquierdo", minval=1, maxval=20, group=gDiv)
lbR      = input.int(5,  "Lookback Derecho",   minval=1, maxval=20, group=gDiv,
                     tooltip="Velas para confirmar el pivote. Mayor = más fiable, más retraso")
rangeMin = input.int(5,  "Rango Mín. entre Pivotes", minval=1,  group=gDiv)
rangeMax = input.int(60, "Rango Máx. entre Pivotes", minval=10, group=gDiv)

showRB = input.bool(true, "Regular Bullish  ▲ (reversión alcista)",   group=gDiv)
showRR = input.bool(true, "Regular Bearish  ▼ (reversión bajista)",   group=gDiv)
showHB = input.bool(true, "Hidden  Bullish  △ (continuación alcista)", group=gDiv)
showHR = input.bool(true, "Hidden  Bearish  ▽ (continuación bajista)", group=gDiv)

// ── Visual ──
gVis      = "🎨 Visualización"
drawLines = input.bool(true, "Dibujar Líneas entre Pivotes", group=gVis)
drawLabs  = input.bool(true, "Mostrar Etiquetas de Señal",   group=gVis)
showDash  = input.bool(true, "Dashboard de Estado",          group=gVis)
dashPos   = input.string("top_right", "Posición Dashboard",
                         options=["top_right","top_left","bottom_right","bottom_left"],
                         group=gVis)

// ── Colores ──
gCol = "🎨 Colores"
cRB  = input.color(#26A69A,                   "Bull Regular",  group=gCol)
cRR  = input.color(#EF5350,                   "Bear Regular",  group=gCol)
cHB  = input.color(color.new(#26A69A, 50),    "Bull Oculta",   group=gCol)
cHR  = input.color(color.new(#EF5350, 50),    "Bear Oculta",   group=gCol)
cRSI = input.color(#8E24AA,                   "Línea RSI",     group=gCol)

// ═══════════════════════════════════════════════════════════════════════
//   2. CÁLCULO RSI Y NIVELES
// ═══════════════════════════════════════════════════════════════════════

osc = ta.rsi(rsiSrc, rsiLen)

plot(osc, title="RSI", linewidth=2, color=cRSI)

hMid    = hline(50,    "Media",        color=color.new(color.gray,  50), linestyle=hline.style_dotted)
hOB     = hline(obLvl, "OB",           color=color.new(color.red,   60), linestyle=hline.style_dashed)
hOS     = hline(osLvl, "OS",           color=color.new(color.green, 60), linestyle=hline.style_dashed)
hExtOB  = hline(extOB, "OB Extremo",   color=color.new(color.red,   30), linestyle=hline.style_solid)
hExtOS  = hline(extOS, "OS Extremo",   color=color.new(color.green, 30), linestyle=hline.style_solid)

fill(hOB, hExtOB, color=color.new(color.red,   90), title="Zona OB Extrema")
fill(hOS, hExtOS, color=color.new(color.green, 90), title="Zona OS Extrema")

// ═══════════════════════════════════════════════════════════════════════
//   3. DETECCIÓN DE PIVOTES
// ═══════════════════════════════════════════════════════════════════════

pivotLowVal  = ta.pivotlow (osc, lbL, lbR)
pivotHighVal = ta.pivothigh(osc, lbL, lbR)

plFound = not na(pivotLowVal)
phFound = not na(pivotHighVal)

inRange(bool cond) =>
    bars = ta.barssince(cond)
    rangeMin <= bars and bars <= rangeMax

// ═══════════════════════════════════════════════════════════════════════
//   4. CONDICIONES DE DIVERGENCIA
// ═══════════════════════════════════════════════════════════════════════

// Regular Bullish — precio Lower Low / RSI Higher Low
oscHL   = osc[lbR] > ta.valuewhen(plFound, osc[lbR], 1) and inRange(plFound[1])
priceLL = low[lbR] < ta.valuewhen(plFound, low[lbR], 1)
regBull = showRB and plFound and priceLL and oscHL

// Hidden Bullish — precio Higher Low / RSI Lower Low
oscLL   = osc[lbR] < ta.valuewhen(plFound, osc[lbR], 1) and inRange(plFound[1])
priceHL = low[lbR] > ta.valuewhen(plFound, low[lbR], 1)
hidBull = showHB and plFound and priceHL and oscLL

// Regular Bearish — precio Higher High / RSI Lower High
oscLH   = osc[lbR] < ta.valuewhen(phFound, osc[lbR], 1) and inRange(phFound[1])
priceHH = high[lbR] > ta.valuewhen(phFound, high[lbR], 1)
regBear = showRR and phFound and priceHH and oscLH

// Hidden Bearish — precio Lower High / RSI Higher High
oscHH   = osc[lbR] > ta.valuewhen(phFound, osc[lbR], 1) and inRange(phFound[1])
priceLH = high[lbR] < ta.valuewhen(phFound, high[lbR], 1)
hidBear = showHR and phFound and priceLH and oscHH

// ═══════════════════════════════════════════════════════════════════════
//   5. LÍNEAS CONECTANDO PIVOTES
// ═══════════════════════════════════════════════════════════════════════

pivotBar = bar_index - lbR

if drawLines
    if regBull
        line.new(int(ta.valuewhen(plFound, bar_index[lbR], 1)),
                 ta.valuewhen(plFound, osc[lbR], 1),
                 pivotBar, osc[lbR],
                 color=cRB, width=2, style=line.style_solid)
    if hidBull
        line.new(int(ta.valuewhen(plFound, bar_index[lbR], 1)),
                 ta.valuewhen(plFound, osc[lbR], 1),
                 pivotBar, osc[lbR],
                 color=cHB, width=1, style=line.style_dashed)
    if regBear
        line.new(int(ta.valuewhen(phFound, bar_index[lbR], 1)),
                 ta.valuewhen(phFound, osc[lbR], 1),
                 pivotBar, osc[lbR],
                 color=cRR, width=2, style=line.style_solid)
    if hidBear
        line.new(int(ta.valuewhen(phFound, bar_index[lbR], 1)),
                 ta.valuewhen(phFound, osc[lbR], 1),
                 pivotBar, osc[lbR],
                 color=cHR, width=1, style=line.style_dashed)

// ═══════════════════════════════════════════════════════════════════════
//   6. ETIQUETAS
// ═══════════════════════════════════════════════════════════════════════

if drawLabs
    if regBull
        label.new(pivotBar, osc[lbR], "BULL",   style=label.style_label_up,
                  color=cRB, textcolor=color.white, size=size.small)
    if hidBull
        label.new(pivotBar, osc[lbR], "H.BULL", style=label.style_label_up,
                  color=cHB, textcolor=color.white, size=size.tiny)
    if regBear
        label.new(pivotBar, osc[lbR], "BEAR",   style=label.style_label_down,
                  color=cRR, textcolor=color.white, size=size.small)
    if hidBear
        label.new(pivotBar, osc[lbR], "H.BEAR", style=label.style_label_down,
                  color=cHR, textcolor=color.white, size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════
//   7. TRIÁNGULOS DE SEÑAL
// ═══════════════════════════════════════════════════════════════════════

plotshape(regBull, title="▲ Bull Regular",  style=shape.triangleup,
          location=location.bottom, color=cRB, size=size.tiny, offset=-lbR)
plotshape(hidBull, title="△ Bull Oculta",   style=shape.triangleup,
          location=location.bottom, color=cHB, size=size.tiny, offset=-lbR)
plotshape(regBear, title="▼ Bear Regular",  style=shape.triangledown,
          location=location.top,    color=cRR, size=size.tiny, offset=-lbR)
plotshape(hidBear, title="▽ Bear Oculta",   style=shape.triangledown,
          location=location.top,    color=cHR, size=size.tiny, offset=-lbR)

// ═══════════════════════════════════════════════════════════════════════
//   8. DASHBOARD
// ═══════════════════════════════════════════════════════════════════════

f_dashPos(string p) =>
    p == "top_right"    ? position.top_right    :
     p == "top_left"     ? position.top_left     :
     p == "bottom_right" ? position.bottom_right :
     position.bottom_left

var table dash = table.new(f_dashPos(dashPos), 2, 6,
                          bgcolor      = color.new(color.black, 80),
                          border_width = 1,
                          border_color = color.new(color.gray, 50))

var string lastDiv = "Ninguna"
var color  lastCol = color.gray
var int    lastBar = na

if regBull
    lastDiv := "▲ BULL Regular"
    lastCol := cRB
    lastBar := bar_index
if hidBull
    lastDiv := "△ BULL Oculta"
    lastCol := cHB
    lastBar := bar_index
if regBear
    lastDiv := "▼ BEAR Regular"
    lastCol := cRR
    lastBar := bar_index
if hidBear
    lastDiv := "▽ BEAR Oculta"
    lastCol := cHR
    lastBar := bar_index

barsAgo = not na(lastBar) ? bar_index - lastBar : -1

rsiZone = osc >= extOB  ? "🔴 OB Extremo"  :
          osc >= obLvl  ? "🟠 Sobrecompra" :
          osc <= extOS  ? "🟢 OS Extremo"  :
          osc <= osLvl  ? "🟡 Sobreventa"  :
                          "⚪ Neutral"

if showDash and barstate.islast
    table.cell(dash, 0, 0, "RSI PRO DIV",
               bgcolor=color.new(#8E24AA, 20), text_color=color.white, text_size=size.normal)
    table.cell(dash, 1, 0, syminfo.ticker + " · " + timeframe.period,
               bgcolor=color.new(#8E24AA, 20), text_color=color.white, text_size=size.normal)

    table.cell(dash, 0, 1, "RSI",        text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 1, str.tostring(osc, "#.##"),
                                          text_color=color.white, text_size=size.small)

    table.cell(dash, 0, 2, "Zona",       text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 2, rsiZone,      text_color=color.white, text_size=size.small)

    table.cell(dash, 0, 3, "Última Div.",text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 3, lastDiv,      text_color=lastCol,     text_size=size.small)

    table.cell(dash, 0, 4, "Hace",       text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 4, barsAgo >= 0 ? str.tostring(barsAgo) + " velas" : "—",
                                          text_color=color.white, text_size=size.small)

    table.cell(dash, 0, 5, "Pivote L/R", text_color=color.gray,  text_size=size.tiny)
    table.cell(dash, 1, 5, str.tostring(lbL) + " / " + str.tostring(lbR),
                                          text_color=color.gray,  text_size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════
//   9. ALERTAS
// ═══════════════════════════════════════════════════════════════════════

alertcondition(regBull, title="🟢 Bull Regular",
     message="RSI Div BULL Regular en {{ticker}} {{interval}} | RSI={{plot_0}}")
alertcondition(hidBull, title="🟢 Bull Oculta",
     message="RSI Div BULL Oculta en {{ticker}} {{interval}} | RSI={{plot_0}}")
alertcondition(regBear, title="🔴 Bear Regular",
     message="RSI Div BEAR Regular en {{ticker}} {{interval}} | RSI={{plot_0}}")
alertcondition(hidBear, title="🔴 Bear Oculta",
     message="RSI Div BEAR Oculta en {{ticker}} {{interval}} | RSI={{plot_0}}")
alertcondition(ta.crossover (osc, obLvl),  title="⚠ RSI cruzó OB",
     message="RSI cruzó OB en {{ticker}}")
alertcondition(ta.crossunder(osc, osLvl),  title="⚠ RSI cruzó OS",
     message="RSI cruzó OS en {{ticker}}")
````

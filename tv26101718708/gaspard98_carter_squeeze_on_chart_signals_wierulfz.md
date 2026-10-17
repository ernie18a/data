# Gaspard98 - Carter Squeeze On Chart / Signals

- url: https://www.tradingview.com/script/wIeRUlFZ/
- type: indicator
- pine_id: PUB;d227534b84214ac7aab0467d02d64afe
- version: 1.0

## Description

# Gaspard98 — Carter Squeeze On Chart / Signals

## Overview

The **Carter Squeeze** is an on-chart implementation of John Carter's well-known *TTM Squeeze* concept, rebuilt as a clean overlay with discrete **Buy / Sell signals**. It detects periods of volatility compression — when a market coils up before an expansion move — and fires a directional signal the moment that energy is released.

Unlike a classic momentum-pane squeeze, everything here lives directly on the price chart: compression state, momentum bias, trend, and entries are all visible at a glance, with no second window to monitor.

---

## The Concept Behind the Squeeze

Carter's method is built on a single, elegant observation: **when Bollinger Bands contract inside the Keltner Channels, the market is in a low-volatility "squeeze."** Volatility is mean-reverting, so a tight squeeze tends to be followed by a sharp expansion. The trade is not the squeeze itself — it's the *release* (the "fire"), taken in the direction of momentum.

This script measures that compression at **three intensity levels** (TTM Squeeze Pro style) rather than a single on/off state, so you can distinguish a mild coil from an extreme one.

---

## How It Works

**1. Compression detection**
Bollinger Bands (default 20, 2.0) are compared against three Keltner Channels built from the average True Range, at multipliers 2.0 / 1.5 / 1.0:

- **No squeeze** — bands are outside the widest Keltner (market is expanding)
- **Low compression** — mild coil
- **Mid compression** — moderate coil
- **High compression** — the tightest state; bands sit inside the narrowest channel

**2. Momentum**
A linear-regression oscillator measures price relative to the mid-channel (the classic Carter momentum formula). Its sign defines directional bias (bullish / bearish) and its slope defines whether momentum is accelerating or fading.

**3. Signals**
The default trigger is the **squeeze fire**: the bar where compression releases. A **BUY** prints if momentum is positive at the release, a **SELL** if it is negative. An optional alternative mode triggers on a **momentum zero-cross** instead.

---

## Signal Logic & Filtering

- **Trigger — Squeeze fire** (default): entry on the release of a compression, in the direction of momentum. This is the purest expression of Carter's method.
- **Trigger — Momentum cross**: entry when momentum crosses the zero line, regardless of squeeze state.
- **Require accelerating momentum** (default on): only allows a BUY when momentum is rising and a SELL when it is falling, filtering out weak, fading releases.
- **Confirm on close** (default on): signals evaluate only on closed bars, making them **non-repainting**. Disable it for faster, intrabar-reactive signals at the cost of mid-bar flicker.

---

## Visual Features

- **Buy / Sell labels** plotted directly below / above the bars.
- **Squeeze state dots** along the bottom of the chart, color-coded by intensity:
  - green = no squeeze
  - blue = low compression
  - orange = mid compression
  - red = high compression
- **Background tint** while a squeeze is active (color reflects intensity).
- **Candle coloring** driven by momentum (bright = accelerating, faded = fading).
- **Trend line** (the basis) colored by momentum bias.
- **Status table** in the top-right corner showing squeeze level, momentum value + direction, current bias, and the last signal.
- Optional **Bollinger + Keltner band overlay** so you can visualize the compression itself.

---

## Settings

**Squeeze**
- Source, Bollinger length & multiplier
- Keltner length and the three compression multipliers (low / mid / high)

**Signals**
- Trigger mode (Squeeze fire / Momentum cross)
- Require accelerating momentum
- Confirm on close (non-repaint)

**Visual**
- Toggle bands, background, dots, candle coloring, trend line, status table
- Custom Buy / Sell colors

---

## How to Use It

1. Watch for a tightening sequence — dots moving from green toward orange and red signal building compression.
2. The **brighter the candles** and the larger the momentum value, the stronger the directional conviction.
3. A signal prints when the squeeze releases. Treat the release as a *timing* tool, not a standalone system — combine it with structure, higher-timeframe trend, and your own risk management.
4. Tighter compressions (red) before a fire tend to precede the cleanest expansions.

Works on any market and timeframe (futures, indices, FX, crypto, equities). Higher timeframes generally yield fewer but cleaner signals.

---

## Alerts

Two alert conditions are built in — **BUY** and **SELL** — ready to attach in TradingView's alert dialog. The default message embeds the ticker and close price and can be reshaped for any webhook or automation endpoint.

---

## Notes

- Default Bollinger / Keltner parameters follow Carter's classic 20-period configuration; adjust to your instrument's volatility profile.
- With *Confirm on close* enabled, signals are fixed once the bar closes and do not repaint.

---

*This indicator is a technical-analysis tool provided for educational and informational purposes only. It is not financial advice and does not guarantee any outcome. Trading involves substantial risk of loss — always test thoroughly and manage risk according to your own plan.*

## Source Code

````pine
//@version=6
// ==========================================================================
//  Gaspard98 — CARTER SQUEEZE SIGNALS
//  Methode du "Squeeze" de John Carter (TTM Squeeze Pro)
//  Bollinger Bands comprimees dans les Keltner Channels + momentum lineaire.
//  Signaux Buy/Sell au declenchement (fire) dans la direction du momentum.
// ==========================================================================
indicator("Gaspard98 - Carter Squeeze On Chart / Signals", "Gaspard98 - CARTER SQZ ON CHART / SIGNALS", overlay = true)

// ───────────────────────────── INPUTS ─────────────────────────────────────
grpC     = "Squeeze"
src      = input.source(close,  "Source",                          group = grpC)
lenBB    = input.int(20,        "Longueur Bollinger", minval = 1,  group = grpC)
multBB   = input.float(2.0,     "Multiplicateur BB",  step = 0.1,  group = grpC)
lenKC    = input.int(20,        "Longueur Keltner",   minval = 1,  group = grpC)
multLow  = input.float(2.0,     "Mult. KC — compression faible",  step = 0.1, group = grpC)
multMid  = input.float(1.5,     "Mult. KC — compression moyenne", step = 0.1, group = grpC)
multHigh = input.float(1.0,     "Mult. KC — compression forte",   step = 0.1, group = grpC)

grpS         = "Signaux"
sigMode      = input.string("Fire du squeeze", "Declencheur", options = ["Fire du squeeze", "Croisement momentum"], group = grpS)
useMomFilter = input.bool(true,  "Exiger un momentum qui accelere", group = grpS, tooltip = "Buy seulement si le momentum monte, Sell seulement s'il baisse")
confirmClose = input.bool(true,  "Confirmer sur cloture (non-repaint)", group = grpS)

grpV      = "Visuel"
showBands = input.bool(false, "Afficher Bollinger + Keltner",    group = grpV)
showBG    = input.bool(true,  "Fond colore pendant le squeeze",  group = grpV)
showDots  = input.bool(true,  "Points d'etat du squeeze (bas)",  group = grpV)
colorBars = input.bool(true,  "Colorer les bougies (momentum)",  group = grpV)
showTrend = input.bool(true,  "Ligne de tendance",               group = grpV)
showTable = input.bool(true,  "Tableau d'etat",                  group = grpV)
colBuy    = input.color(#00e676, "Couleur Buy",  group = grpV)
colSell   = input.color(#ff1744, "Couleur Sell", group = grpV)

// ──────────────────────────── CALCULS ─────────────────────────────────────
// Bollinger Bands
basis   = ta.sma(src, lenBB)
dev     = multBB * ta.stdev(src, lenBB)
upperBB = basis + dev
lowerBB = basis - dev

// Keltner Channels (moyenne du True Range) a 3 largeurs
maKC     = ta.sma(src, lenKC)
rangeMA  = ta.sma(ta.tr(true), lenKC)
upKClow  = maKC + rangeMA * multLow
loKClow  = maKC - rangeMA * multLow
upKCmid  = maKC + rangeMA * multMid
loKCmid  = maKC - rangeMA * multMid
upKChigh = maKC + rangeMA * multHigh
loKChigh = maKC - rangeMA * multHigh

// Etats du squeeze (BB a l'interieur des KC)
sqzLow  = lowerBB > loKClow  and upperBB < upKClow
sqzMid  = lowerBB > loKCmid  and upperBB < upKCmid
sqzHigh = lowerBB > loKChigh and upperBB < upKChigh

// Classification exclusive (du plus serre au plus large)
compHigh  = sqzHigh
compMid   = sqzMid and not sqzHigh
compLow   = sqzLow and not sqzMid
noSqz     = not sqzLow
sqzActive = sqzLow                       // au moins une compression en cours

// Momentum (regression lineaire prix vs canal median) — formule Carter
hl     = math.avg(ta.highest(high, lenKC), ta.lowest(low, lenKC))
mom    = ta.linreg(src - math.avg(hl, ta.sma(close, lenKC)), lenKC, 0)
momUp  = mom > nz(mom[1])
momPos = mom > 0

// ──────────────────────────── SIGNAUX ─────────────────────────────────────
fire          = sqzActive[1] and not sqzActive    // le squeeze vient de se relacher
zeroCrossUp   = ta.crossover(mom, 0)
zeroCrossDown = ta.crossunder(mom, 0)

trigUp   = sigMode == "Fire du squeeze" ? fire : zeroCrossUp
trigDown = sigMode == "Fire du squeeze" ? fire : zeroCrossDown

rawBuy   = (sigMode == "Fire du squeeze" ? (trigUp   and momPos)     : trigUp)   and (not useMomFilter or momUp)
rawSell  = (sigMode == "Fire du squeeze" ? (trigDown and not momPos) : trigDown) and (not useMomFilter or not momUp)

ready = not confirmClose or barstate.isconfirmed
buy   = rawBuy  and ready
sell  = rawSell and ready

var int bias = 0
if buy
    bias := 1
if sell
    bias := -1

// ──────────────────────────── VISUELS ─────────────────────────────────────
// Bandes (optionnel)
plot(showBands ? upperBB : na, "BB sup", color.new(color.blue,   40))
plot(showBands ? lowerBB : na, "BB inf", color.new(color.blue,   40))
plot(showBands ? upKClow : na, "KC sup", color.new(color.orange, 50))
plot(showBands ? loKClow : na, "KC inf", color.new(color.orange, 50))

// Ligne de tendance coloree selon le momentum
trendCol = momPos ? (momUp ? colBuy : color.new(colBuy, 55)) : (not momUp ? colSell : color.new(colSell, 55))
plot(showTrend ? basis : na, "Tendance", trendCol, 2)

// Couleur de momentum (4 etats type TTM)
momCol = momPos ? (momUp ? colBuy : color.new(colBuy, 50)) : (not momUp ? colSell : color.new(colSell, 50))
barcolor(colorBars ? momCol : na)

// Fond pendant le squeeze (intensite = couleur)
bgcolor(showBG and sqzActive ? color.new(compHigh ? colSell : compMid ? color.orange : color.blue, 90) : na)

// Points d'etat du squeeze en bas du graphique
plotshape(showDots and compHigh, "SQZ forte",   shape.circle, location.bottom, colSell,       size = size.tiny)
plotshape(showDots and compMid,  "SQZ moyenne", shape.circle, location.bottom, color.orange,  size = size.tiny)
plotshape(showDots and compLow,  "SQZ faible",  shape.circle, location.bottom, color.blue,    size = size.tiny)
plotshape(showDots and noSqz,    "Pas de SQZ",  shape.circle, location.bottom, colBuy,        size = size.tiny)

// Fleches Buy / Sell
plotshape(buy,  "BUY",  shape.labelup,   location.belowbar, colBuy,  text = "BUY",  textcolor = color.white, size = size.small)
plotshape(sell, "SELL", shape.labeldown, location.abovebar, colSell, text = "SELL", textcolor = color.white, size = size.small)

// ──────────────────────────── TABLEAU ─────────────────────────────────────
var table t = table.new(position.top_right, 2, 4, border_width = 1)
if showTable and barstate.islast
    sqzTxt = noSqz ? "OFF" : compHigh ? "FORTE" : compMid ? "MOYENNE" : "FAIBLE"
    sqzClr = noSqz ? colBuy : compHigh ? colSell : compMid ? color.orange : color.blue
    table.cell(t, 0, 0, "SQUEEZE",  text_color = color.white, bgcolor = color.new(color.gray, 30))
    table.cell(t, 1, 0, sqzTxt,     text_color = color.white, bgcolor = color.new(sqzClr, 30))
    table.cell(t, 0, 1, "MOMENTUM", text_color = color.white, bgcolor = color.new(color.gray, 30))
    table.cell(t, 1, 1, str.tostring(mom, "#.##") + (momUp ? " ▲" : " ▼"), text_color = color.white, bgcolor = color.new(momCol, 30))
    table.cell(t, 0, 2, "BIAIS",    text_color = color.white, bgcolor = color.new(color.gray, 30))
    table.cell(t, 1, 2, momPos ? "HAUSSIER" : "BAISSIER", text_color = color.white, bgcolor = color.new(momPos ? colBuy : colSell, 30))
    table.cell(t, 0, 3, "SIGNAL",   text_color = color.white, bgcolor = color.new(color.gray, 30))
    table.cell(t, 1, 3, bias == 1 ? "BUY" : bias == -1 ? "SELL" : "—", text_color = color.white, bgcolor = color.new(bias == 1 ? colBuy : bias == -1 ? colSell : color.gray, 30))

// ──────────────────────────── ALERTES ─────────────────────────────────────
alertcondition(buy,  "Carter Squeeze — BUY",  "BUY {{ticker}} @ {{close}}")
alertcondition(sell, "Carter Squeeze — SELL", "SELL {{ticker}} @ {{close}}")
````

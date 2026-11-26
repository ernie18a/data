# Gaspard98 - RSI Glissant

- url: https://www.tradingview.com/script/RftQfYxt/
- type: indicator
- pine_id: PUB;27d95d7e57624d259e949832b37238a5
- version: 1.0

## Description

# Gaspard98 ⊛ RSI Glissant — Sliding RSI projected on price

## Overview

**RSI Glissant** ("Sliding RSI") is an on-chart overlay that takes a multi-timeframe RSI, re-scales it dynamically over a rolling window, and projects the result directly onto the price band. Instead of reading an oscillator in a separate sub-pane, you see an adaptive RSI curve riding inside the recent high/low range of price, with overbought and overload zones drawn as price levels you can actually trade against.

The goal is simple: keep your eyes on price, but with RSI context built into the chart itself.

---

## Concept — why "sliding"

A classic RSI moves between 0 and 100 against fixed thresholds. The problem is that in trending or low-volatility regimes the raw RSI rarely reaches those extremes, so 70/30 stop being meaningful.

This indicator solves that with two layers:

1. **Adaptive normalization.** The raw MTF RSI is re-normalized to a 0–100 scale over its own rolling range (the *Sliding Range*). The highest and lowest RSI readings of the lookback window become the new 100 and 0. The oscillator therefore always "breathes" across the full scale and stays responsive to the current regime.

2. **Projection onto price.** That normalized curve is then mapped onto the price band — defined by the highest high and lowest low of the same rolling window. A value of 0 sits on the band floor, 100 on the band ceiling. The overbought (default 70) and oversold (default 30) thresholds become two horizontal **price levels**, not abstract oscillator lines.

The result is a cyan curve and two zone lines that live on the candles, scaling automatically as the market range expands or contracts.

---

## Signals

Signals are triggered by **price closing back through the projected zone lines**, which keeps them anchored to actual price action rather than to the oscillator alone:

- **BUY** — price closes back **above** the projected oversold level (exit from the lower/green zone).
- **SELL** — price closes back **below** the projected overbought level (exit from the upper/red zone).

This is a mean-reversion logic: the indicator looks for price leaving an extreme zone rather than simply touching it.

### Optional signal filters
- **Heikin Ashi confirmation** — BUY only fires on a green HA candle, SELL only on a red HA candle.
- **Strict alternation** — never two BUYs (or two SELLs) in a row; the system waits for an opposite signal before repeating.
- **All signals (no filter)** — shows every qualifying close, ignoring alternation and the HA filter, for testing or discretionary reading.

---

## Visuals
- **Cyan line** — the sliding RSI curve projected onto price.
- **Red / green guide lines** — the overbought and oversold thresholds projected onto price.
- **Gradient fill** — red intensifies above the overbought level, green intensifies below the oversold level, giving an instant read of how stretched price is inside its range.
- **BUY / SELL labels** — plotted on the bars that trigger.

---

## Settings

**RSI MTF**
- *Source* — price source for the RSI (default Close).
- *RSI Length* — RSI period (default 14).
- *RSI Timeframe* — the higher timeframe the RSI is computed on (default 5 min).
- *Anti-repaint* — see the repaint note below.

**OB / OS Zones**
- *Overbought level* (default 70) and *Oversold level* (default 30).

**Sliding Band**
- *Sliding Range (bars)* — lookback used for both the RSI re-normalization and the price band (default 150).
- *OB/OS guide lines* — show/hide the projected threshold lines.
- *Out-of-zone gradient* — show/hide the red/green fill.

**Signals**
- *Confirm with HA color*, *All signals*, *Strict BUY/SELL alternation* — as described above.

---

## How to use
1. Pick an RSI timeframe higher than your chart timeframe for cleaner context (e.g. 5 min RSI on a 1 min chart).
2. Adjust the *Sliding Range* to your style — shorter for reactive intraday work, longer for smoother swing context.
3. Treat the green/red zones as adaptive stretch zones: a BUY signal marks price leaving the lower zone, a SELL marks price leaving the upper zone.
4. Combine with your own trend filter or structure read — the signals are reversion-oriented and work best with confluence.

---

## Repaint disclosure

By default (*Anti-repaint* OFF), the indicator uses the live, in-progress value of the higher-timeframe RSI. While the current HTF bar is still forming, that value can change, so the most recent reading and signal **may repaint** until the HTF bar closes.

Turning *Anti-repaint* **ON** forces the indicator to use only the last **confirmed** higher-timeframe value (offset by one bar with `lookahead_off`). Signals are then non-repainting and confirmed, at the cost of being slightly later. Choose ON for honest backtesting and alert-driven workflows.

---

## Alerts

Two alert conditions are provided, **BUY — exit OS** and **SELL — exit OB**, plus built-in `alert()` calls that fire once per bar close. Set them to "Once per bar close" to match the indicator's confirmation logic.

---

## Disclaimer

This indicator is a technical analysis tool provided for educational and informational purposes only. It is not financial advice and does not guarantee any result. Past behavior of any signal does not predict future performance. Always do your own research and manage your own risk.

© Gaspard98

## Source Code

````pine
// © G-ONE369
//@version=6
indicator("Gaspard98 ⊛ RSI Glissant", shorttitle="Gaspard98 RSI GLISSANT", overlay=true, max_labels_count=500)

// ════════════════════════════════════════════════════════════════════
//  INPUTS
// ════════════════════════════════════════════════════════════════════
grpR   = "RSI MTF"
src    = input.source(close,  "Source",             group=grpR)
rsiLen = input.int(14,        "Longueur RSI",        minval=1, group=grpR)
tfRSI  = input.timeframe("5", "Timeframe RSI (MTF)", group=grpR)
noRep  = input.bool(false,    "Anti-repaint (valeur HTF confirmée)", group=grpR,
     tooltip="ON = utilise la dernière valeur 5 min clôturée : pas de repaint, signaux confirmés mais légèrement plus tardifs.")

grpZ   = "Zones OB / OS"
obLvl  = input.float(70.0, "Seuil OB (surachat)", minval=50, maxval=100, group=grpZ)
osLvl  = input.float(30.0, "Seuil OS (survente)", minval=0,  maxval=50,  group=grpZ)

grpB   = "Bande glissante"
projLen = input.int(150, "Range glissant (barres)", minval=10, group=grpB,
     tooltip="Plus haut/plus bas du prix sur ce nb de barres : c'est la bande où le RSI est projeté.")
showGuides = input.bool(true, "Lignes OB/OS",         group=grpB)
showGrad   = input.bool(true, "Dégradé hors-zone",    group=grpB,
     tooltip="Rouge de plus en plus intense au-dessus de l'OB, vert sous l'OS.")

grpS   = "Signaux"
useHA  = input.bool(false, "Confirmer par couleur HA", group=grpS,
     tooltip="BUY uniquement si HA verte, SELL uniquement si HA rouge.")
allSig = input.bool(false, "Tous les signaux (aucun filtre)", group=grpS,
     tooltip="Affiche CHAQUE clôture qui sort de zone, sans alternance ni filtre HA.")
alternate = input.bool(true, "Alternance stricte BUY/SELL", group=grpS,
     tooltip="Jamais deux BUY (ni deux SELL) d'affilée. Ignoré si 'Tous les signaux' est actif.")

// ════════════════════════════════════════════════════════════════════
//  OSCILLATEUR GLISSANT (RSI normalisé sur le range glissant) + ANTI-REPAINT
// ════════════════════════════════════════════════════════════════════
rsiExpr = ta.rsi(src, rsiLen)
idx     = noRep and barstate.isrealtime ? 1 : 0
rsiRaw  = request.security(syminfo.tickerid, tfRSI, rsiExpr[idx], lookahead=barmerge.lookahead_off)

// version glissante : le RSI est renormalisé 0..100 sur son propre range glissant.
// C'est CETTE courbe qui remplit la bande ET qui déclenche les signaux (plus de MTF brut).
rsiLo = ta.lowest(rsiRaw, projLen)
rsiHi = ta.highest(rsiRaw, projLen)
osc   = 100.0 * (rsiRaw - rsiLo) / math.max(rsiHi - rsiLo, 1e-6)

// ════════════════════════════════════════════════════════════════════
//  BANDE GLISSANTE + PROJECTION SUR LE PRIX
// ════════════════════════════════════════════════════════════════════
hh      = ta.highest(high, projLen)
ll      = ta.lowest(low,  projLen)
rng     = hh - ll
map(v)  => ll + (v / 100.0) * rng         // mappe une valeur osc [0..100] sur la bande prix

rsiY = map(osc)        // courbe glissante projetée (cyan)
obY  = map(obLvl)      // ligne OB projetée
osY  = map(osLvl)      // ligne OS projetée

// ════════════════════════════════════════════════════════════════════
//  HEIKIN ASHI (couleur de la bougie courante)
// ════════════════════════════════════════════════════════════════════
float haClose = (open + high + low + close) / 4
var float haOpen = na
haOpen := na(haOpen[1]) ? (open + close) / 2 : (haOpen[1] + haClose[1]) / 2
haGreen = haClose >= haOpen
haRed   = haClose <  haOpen

// ════════════════════════════════════════════════════════════════════
//  SIGNAUX : clôture de la bougie hors zone OB/OS
//  BUY  = la bougie CLÔTURE au-dessus de la zone OS (sort du vert)
//  SELL = la bougie CLÔTURE en-dessous de la zone OB (sort du rouge)
//  → ce sont les niveaux de prix obY/osY (70 %/30 % de la bande) qui sont franchis,
//    pas la courbe oscillateur.
// ════════════════════════════════════════════════════════════════════
buyCross  = ta.crossover(close,  osY)   // clôture repasse au-dessus de l'OS → BUY
sellCross = ta.crossunder(close, obY)   // clôture repasse en-dessous de l'OB → SELL

buyOK  = buyCross  and (allSig or not useHA or haGreen)
sellOK = sellCross and (allSig or not useHA or haRed)

var int lastSig = 0
useAlt = alternate and not allSig
buySignal  = buyOK  and (not useAlt or lastSig != 1)
sellSignal = sellOK and (not useAlt or lastSig != -1)
if buySignal
    lastSig := 1
if sellSignal
    lastSig := -1

// ════════════════════════════════════════════════════════════════════
//  TRACÉ — tout sur le graphique des prix
// ════════════════════════════════════════════════════════════════════
pRSI = plot(rsiY, "RSI projeté", color=color.new(#00e5ff, 0), linewidth=2)
pOB  = plot(showGuides ? obY : na, "Ligne OB", color=color.new(color.red,   55))
pOS  = plot(showGuides ? osY : na, "Ligne OS", color=color.new(color.green, 55))

// bornes invisibles pour le dégradé
pTop = plot(showGrad ? hh  : na, "Haut bande", display=display.none)
pBot = plot(showGrad ? ll  : na, "Bas bande",  display=display.none)
pOBy = plot(showGrad ? obY : na, "OB y",       display=display.none)
pOSy = plot(showGrad ? osY : na, "OS y",       display=display.none)

// dégradé : rouge transparent à l'OB → intense en haut de bande
fill(pOBy, pTop, top_value=hh, bottom_value=obY,
     top_color=color.new(color.red, 15), bottom_color=color.new(color.red, 100), title="Hors-zone haut (rouge)")
// dégradé : vert transparent à l'OS → intense en bas de bande
fill(pOSy, pBot, top_value=osY, bottom_value=ll,
     top_color=color.new(color.green, 100), bottom_color=color.new(color.green, 15), title="Hors-zone bas (vert)")

// signaux posés sur les bougies (le prix déclenche)
plotshape(buySignal,  "BUY",  shape.triangleup,   location.belowbar, color.new(color.lime, 0), text="BUY",  textcolor=color.white, size=size.small)
plotshape(sellSignal, "SELL", shape.triangledown, location.abovebar, color.new(color.red,  0), text="SELL", textcolor=color.white, size=size.small)

// ════════════════════════════════════════════════════════════════════
//  ALERTES
// ════════════════════════════════════════════════════════════════════
alertcondition(buySignal,  "BUY  — sortie OS",  "BUY G-ONE369 RSI Glissant")
alertcondition(sellSignal, "SELL — sortie OB",  "SELL G-ONE369 RSI Glissant")
if buySignal
    alert("BUY ⊛ sortie OS — "  + syminfo.ticker, alert.freq_once_per_bar_close)
if sellSignal
    alert("SELL ⊛ sortie OB — " + syminfo.ticker, alert.freq_once_per_bar_close)
````

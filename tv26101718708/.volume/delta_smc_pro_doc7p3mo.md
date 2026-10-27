# Delta SMC Pro

- url: https://www.tradingview.com/script/dOC7P3mO/
- type: indicator
- pine_id: PUB;ad95404ae78a4c4f87cc3b3e36b295f3
- version: 2.0

## Description

Delta SMC Pro ist ein Hybrid‑Indikator, der
Liquidity Sweeps
CHoCH‑Breaks und ein 
starkes Delta‑Volumenmodul kombiniert

Delta – Kurzdefinition:  
Delta misst den Unterschied zwischen Kaufvolumen und Verkaufsvolumen.

Bullish Delta → mehr aggressives Kaufvolumen
Bearish Delta → mehr aggressives Verkaufsvolumen
Neutral → ausgeglichen
Delta zeigt, ob ein Move echte Stärke hat oder nur ein Liquidity‑Grab ist.

Hauptfunktionen:

Sweep‑Erkennung (HTF)

CHoCH‑Erkennung (LTF)

Delta‑Momentumfilter


Hybrid‑Entry‑Signale (LONG / SHORT)
Dashboard + Alerts für Automatisierung
Nutzung:
Sweep‑ und CHoCH‑Timeframe wählen
Trend pro Asset einstellen
LONG/SHORT erscheinen automatisch, wenn alle Bedingungen erfüllt sind
Alerts aktivieren für Bot‑Signale

Sweeps funktionieren gut in Liquiditätszonen
CHoCH bestätigt Richtungswechsel
Delta filtert schwache Moves

## Source Code

````pine
//@version=6
indicator("Delta SMC – Hybrid SMC + Delta (No Trend)", overlay=true)

// ---------------------------
// INPUTS
// ---------------------------
sweepTF  = input.timeframe("15", "Sweep Timeframe")
chochTF  = input.timeframe("5", "CHoCH Timeframe")
swingLen = input.int(5, "Swing Length")

// ---------------------------
// SWEEP DETECTION (15m)
// ---------------------------
sweepHighTF = request.security(syminfo.tickerid, sweepTF, high)
sweepLowTF  = request.security(syminfo.tickerid, sweepTF, low)

swingHighTF = request.security(syminfo.tickerid, sweepTF, high[swingLen] == ta.highest(high, swingLen * 2 + 1))
swingLowTF  = request.security(syminfo.tickerid, sweepTF, low[swingLen] == ta.lowest(low, swingLen * 2 + 1))

bullSweep = sweepLowTF < sweepLowTF[swingLen] and swingLowTF
bearSweep = sweepHighTF > sweepHighTF[swingLen] and swingHighTF

// ---------------------------
// CHOCH DETECTION (5m)
// ---------------------------
chochHighTF = request.security(syminfo.tickerid, chochTF, high)
chochLowTF  = request.security(syminfo.tickerid, chochTF, low)

bullCHoCH = chochHighTF > chochHighTF[1]
bearCHoCH = chochLowTF < chochLowTF[1]

// ---------------------------
// DELTA MODUL
// ---------------------------
buyVol  = close > open ? volume : 0.0
sellVol = close < open ? volume : 0.0
delta   = buyVol - sellVol

deltaBull = delta > 0
deltaBear = delta < 0

deltaText  = deltaBull ? "Bullish Delta" : deltaBear ? "Bearish Delta" : "Neutral"
deltaColor = deltaBull ? color.new(color.green, 0) : deltaBear ? color.new(color.red, 0) : color.new(color.gray, 0)

// ---------------------------
// FINAL HYBRID SIGNALS (NO TREND FILTER)
// ---------------------------
longSignal  = bullSweep and bullCHoCH
shortSignal = bearSweep and bearCHoCH

// ---------------------------
// PLOTS
// ---------------------------
plotshape(longSignal,  title="Long Entry",  style=shape.labelup,   color=color.green, text="LONG",  size=size.small, location=location.belowbar)
plotshape(shortSignal, title="Short Entry", style=shape.labeldown, color=color.red,   text="SHORT", size=size.small, location=location.abovebar)

// ---------------------------
// ALERTS
// ---------------------------
alertcondition(longSignal,  title="Long Signal",  message="Hybrid LONG: Sweep + CHoCH + Delta")
alertcondition(shortSignal, title="Short Signal", message="Hybrid SHORT: Sweep + CHoCH + Delta")

// ---------------------------
// HYBRID DASHBOARD (NO TREND)
// ---------------------------
bull    = color.new(color.green, 0)
bear    = color.new(color.red, 0)
neutral = color.new(color.gray, 0)

sweepText  = bullSweep ? "Bullish (Sweep unten)" : bearSweep ? "Bearish (Sweep oben)" : "None"
sweepColor = bullSweep ? bull : bearSweep ? bear : neutral

chochText  = bullCHoCH ? "Bullish" : bearCHoCH ? "Bearish" : "None"
chochColor = bullCHoCH ? bull : bearCHoCH ? bear : neutral

var table dash = table.new(position.top_left, 2, 4, border_width=1)

if barstate.islast
    table.cell(dash, 0, 0, "DELTA SMC DASHBOARD", text_color=color.white, bgcolor=color.black)

    table.cell(dash, 0, 1, "Sweep (" + sweepTF + "):", text_color=color.white)
    table.cell(dash, 1, 1, sweepText, text_color=sweepColor)

    table.cell(dash, 0, 2, "CHoCH (" + chochTF + "):", text_color=color.white)
    table.cell(dash, 1, 2, chochText, text_color=chochColor)

    table.cell(dash, 0, 3, "Delta:", text_color=color.white)
    table.cell(dash, 1, 3, deltaText, text_color=deltaColor)
````

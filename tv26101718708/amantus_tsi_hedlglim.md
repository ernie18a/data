# AMANTUS TSI

- url: https://www.tradingview.com/script/HedlgLiM-AMANTUS-TSI/
- type: indicator
- pine_id: PUB;97727ebf3f024703b44cbd93d3e2517b
- version: 1.0

## Description

[b]AMANTUS TSI — True Strength Index with Signal Line, Zones & Cross Markers[/b]

[b]What it is[/b]
A clean, no-nonsense implementation of William Blau's True Strength Index — a double-smoothed momentum oscillator that filters out price noise while staying responsive to real shifts in strength. Paired with an SMA signal line, overbought/oversold zones and clear crossover markers, it gives you a complete momentum read-out in one pane.

[b]How it works[/b]
[list]
[*]Price change (close − previous close) is smoothed twice with EMAs (25, then 13).
[*]The absolute price change is smoothed the same way.
[*]TSI = 100 × (smoothed change / smoothed absolute change), bounded between −100 and +100.
[*]A 14-period SMA of the TSI serves as the signal line.
[/list]

Double smoothing is what makes TSI different from RSI or a plain momentum line: it reacts to sustained pressure, not single-bar spikes. In practice this often makes TSI more informative than RSI — especially in precious metals, where sharp intraday swings keep RSI pinned in extreme zones while TSI still shows whether the underlying momentum is building or fading.

[b]What you see[/b]
[list]
[*][b]TSI line[/b] (violet) and [b]Signal line[/b] (amber).
[*][b]Gap fill[/b]: green when TSI is above the signal, red when below — momentum direction at a glance.
[*][b]Zone lines[/b] at ±25 (adjustable) and a dotted zero line.
[*][b]▲ / ▼ markers[/b] on bullish and bearish crossovers.
[/list]

[b]How to read it[/b]
[list]
[*]TSI crosses above the signal → momentum turning bullish; above zero → bulls in control.
[*]TSI crosses below the signal → momentum turning bearish; below zero → bears in control.
[*]Readings beyond ±25 flag stretched conditions — crosses [i]from[/i] these zones back toward zero are the classic mean-reversion setups.
[*]Divergence between TSI peaks/troughs and price often precedes a turn.
[/list]

[b]Settings[/b]
[list]
[*]Long smoothing (25), Short smoothing (13), Signal SMA (14)
[*]Zone boundary (±25)
[*]Toggle crossover markers and gap fill
[/list]

[b]Alerts[/b]
Two built-in alert conditions: [b]TSI BULL cross[/b] and [b]TSI BEAR cross[/b].

[b]Notes[/b]
[list]
[*]Works on any symbol and timeframe. Developed and tested on XAUUSD.
[*]Signals are confirmed at bar close and do not repaint afterwards.
[*]Early values depend on the amount of loaded history (EMA warm-up).
[/list]

© amant.us 2026. Open source — use it, study it, build on it. Modification and redistribution are welcome with attribution to amant.us. Feedback welcome.

## Source Code

````pine
//@version=6
// =====================================================================
//  AMANTUS TSI v.1.0E
//  Indicator (separate pane), any symbol and timeframe.
//
//  True Strength Index (double-smoothed momentum) with an SMA signal
//  line, overbought / oversold zones and crossover markers.
//
//  DEFAULTS
//   • TSI long smoothing 25, short smoothing 13
//   • Signal line: SMA 14 of TSI
//   • Zone boundaries ±25
//   • Crossover markers ON
//
//  CALCULATION
//   • pc  = close − close[1]
//   • TSI = 100 × EMA(EMA(pc, 25), 13) / EMA(EMA(|pc|, 25), 13)
//   • Signal = SMA(TSI, 14)
//   • TSI ranges from −100 to +100; above +zone = overbought,
//     below −zone = oversold.
//
//  SIGNALS
//   • BULL cross: TSI crosses ABOVE the signal line (▲ at pane bottom).
//   • BEAR cross: TSI crosses BELOW the signal line (▼ at pane top).
//   • Gap fill between TSI and signal: green = TSI above, red = TSI below.
//   • A cross is known at bar close; it does not repaint after close.
//
//  NOTE: EMAs are calculated from the first loaded bar, so early values
//  depend on how much history is loaded.
// =====================================================================
indicator("AMANTUS TSI v.1.0E", shorttitle="AMANTUS TSI", overlay=false, precision=2)

// ---------- TSI settings ----------
lenLong = input.int(25,     "Long smoothing",  minval=1, group="TSI")
lenShrt = input.int(13,     "Short smoothing", minval=1, group="TSI")
lenSig  = input.int(14,     "Signal SMA",      minval=1, group="TSI")

// ---------- Zones ----------
zone    = input.float(25.0, "Zone boundary (±)", step=1.0, minval=0, group="Zones")

// ---------- Display ----------
showX   = input.bool(true,  "Show crossover markers", group="Display")
showGap = input.bool(true,  "Fill gap TSI / signal",  group="Display")

// ---------- Calculation ----------
pc  = ta.change(close)
num = ta.ema(ta.ema(pc,           lenLong), lenShrt)
den = ta.ema(ta.ema(math.abs(pc), lenLong), lenShrt)
tsi = den == 0 ? na : 100 * num / den
sig = ta.sma(tsi, lenSig)

// ---------- Plots ----------
pT = plot(tsi, "TSI",    color=#a58bf0, linewidth=2)
pS = plot(sig, "Signal", color=#e8a33c, linewidth=2)
fill(pT, pS, color=not showGap ? na : tsi >= sig ? color.new(#3fd39a, 88) : color.new(#c0392f, 88), title="Gap")

hline(0,     "Zero",       color=color.new(color.gray, 55), linestyle=hline.style_dotted)
hline(zone,  "Upper zone", color=color.new(#c9756a, 45),    linestyle=hline.style_dashed)
hline(-zone, "Lower zone", color=color.new(#3fd39a, 45),    linestyle=hline.style_dashed)

// ---------- Signals ----------
bull = ta.crossover(tsi, sig)
bear = ta.crossunder(tsi, sig)
plotshape(showX and bull, "BULL cross", style=shape.triangleup,   location=location.bottom, color=#3fd39a, size=size.tiny)
plotshape(showX and bear, "BEAR cross", style=shape.triangledown, location=location.top,    color=#c0392f, size=size.tiny)

alertcondition(bull, "TSI BULL cross", "AMANTUS TSI: BULL cross")
alertcondition(bear, "TSI BEAR cross", "AMANTUS TSI: BEAR cross")
````

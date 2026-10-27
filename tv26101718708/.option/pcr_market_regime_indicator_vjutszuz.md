# PCR Market Regime Indicator

- url: https://www.tradingview.com/script/VjUtSzUZ-PCR-Market-Regime-Indicator/
- type: indicator
- pine_id: PUB;b26b083ccdd1453b981ae4d0e9204222
- version: 3.0

## Description

📊 PCR Market Regime Indicator

This indicator is an enhanced version of the Percent Change of Range (PCR) concept, focused on identifying market regimes through behavior around the key zero level.

Unlike traditional momentum indicators that rely on extreme values, this tool uses the zero level as the boundary between buyers and sellers, providing a clear visual understanding of whether the market is trending or ranging.

🧠 How it works

PCR measures the relative price change compared to the total range over a defined period:

Values above 0 → bullish control
Values below 0 → bearish control
Movement around 0 → indecision / chop

The indicator also applies:

EMA smoothing to reduce noise
neutral zone around 0 to filter false signals
hold logic, requiring sustained movement above/below 0 before confirming a regime change
🎯 What the indicator shows
Background color (regime):
🟢 Green → bullish regime
🔴 Red → bearish regime
⚪ Gray → neutral / chop
PCR line:
visual representation of momentum
Horizontal levels:
+100 / +70 → strong bullish extremes
0 → key boundary
-70 / -100 → strong bearish extremes
⚙️ How to use it

This indicator is not designed as a standalone entry signal, but as a tool for understanding market context.

Basic guidelines:

Trade in the direction of the regime (green or red zones)
Avoid trading during neutral (chop) conditions
Pay attention to zero-level crossings and holding behavior
⚠️ Disclaimer

This indicator does not guarantee future results and should not be used as the sole basis for trading decisions. It is recommended to combine it with other tools such as price action, market structure, or trend indicators.

📌 Summary

PCR Regime Engine provides a clean and intuitive way to identify:

market trends
consolidation phases
momentum shifts

with a focus on the most important level — 0 (market control boundary).

## Source Code

````pine
//@version=6
indicator("PCR Market Regime Indicator", overlay=false)

//========================
// INPUTS
//========================
pcrLen      = input.int(80, "PCR Length")
holdBars    = input.int(1, "Min Hold Bars")
zone        = input.float(1.0, "Neutral Zone (+/- around 0)")
smoothLen   = input.int(3, "Smoothing")

// EMA INPUT
showEMA     = input.bool(true, "Show EMA")
emaLen      = input.int(10, "EMA Length")

// LEVELS TOGGLE
show100     = input.bool(true,  "Show 100")
show70      = input.bool(true,  "Show 70")
show0       = input.bool(true,  "Show 0")
showNeg70   = input.bool(true,  "Show -70")
showNeg100  = input.bool(true,  "Show -100")

//========================
// PCR FUNCTION
//========================
f_pcr(_length) =>
    _h = ta.highest(high, _length)
    _l = ta.lowest(low, _length)
    _c = close - close[_length]
    _r = _h - _l
    _r != 0 ? (_c / _r * 100) : 0

raw_pcr = f_pcr(pcrLen)
pcr = ta.ema(raw_pcr, smoothLen)

//========================
// EMA NA PCR
//========================
pcrEma = ta.ema(pcr, emaLen)

//========================
// ZONE DEFINICIJE
//========================
above   = pcr > zone
below   = pcr < -zone
neutral = not above and not below

//========================
// HOLD LOGIKA
//========================
aboveHold = ta.barssince(not above) >= holdBars
belowHold = ta.barssince(not below) >= holdBars

//========================
// REGIME STATE
//========================
var int regime = 0

if above and aboveHold
    regime := 1
else if below and belowHold
    regime := -1
else if neutral
    regime := 0

//========================
// BACKGROUND COLOR
//========================
bgcolor(
     regime == 1 ? color.new(color.green, 85) :
     regime == -1 ? color.new(color.red, 85) :
     color.new(color.gray, 85)
)

//========================
// PCR LINE
//========================
plot(pcr, title="PCR", color=pcr > 0 ? color.lime : color.red, linewidth=2)

//========================
// EMA LINE
//========================
plot(showEMA ? pcrEma : na, title="PCR EMA", color=color.purple, linewidth=2)

//========================
// LEVELS
//========================
hline(show100    ? 100  : na, "100",  color=color.blue)
hline(show70     ? 70   : na, "70",   color=color.green)
hline(show0      ? 0    : na, "0",    color=color.rgb(251, 251, 253))
hline(showNeg70  ? -70  : na, "-70",  color=color.red)
hline(showNeg100 ? -100 : na, "-100", color=color.maroon)
````

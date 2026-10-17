# PI Band

- url: https://www.tradingview.com/script/yuDYHN9h/
- type: indicator
- pine_id: PUB;c287dfe8d7924c40b3644c0d2fd56170
- version: 1.0

## Description

# PI Band

PI ATR Compression Breakout is a volatility expansion and breakout detection tool built around a custom PI-powered energy model.

Unlike traditional squeeze indicators that rely solely on price volatility, this script combines **ATR (volatility)**, **OBV momentum (volume flow)** and a **PI-based energy calculation** to identify compression phases before potential directional breakouts.

---

## How The Energy Engine Works

The core of the indicator is the proprietary PI ATR OBV Energy Model.

The calculation starts by measuring:

* ATR volatility
* OBV rate of change
* PI-scaled volatility area

ATR is transformed into a circular energy representation using:

PI × ATR²

This value is then combined with the square root of OBV momentum, creating an energy stream that reflects both volatility expansion and volume participation.

The resulting energy is normalized and smoothed to produce a dynamic market pressure score ranging between 0 and 100.

---

## PI Power

The normalized energy drives a variable called **PI Power**.

Higher energy levels increase PI Power.

Lower energy levels reduce PI Power.

Instead of using a fixed ATR channel, the indicator dynamically adjusts channel width according to the current market energy state.

This allows the bands to expand during strong directional moves and contract during low-energy environments.

---

## Compression Detection

The script continuously compares the active PI ATR value against its historical average.

When PI ATR falls significantly below its own average, a compression state is detected.

Compression represents:

* Reduced volatility
* Contracting market activity
* Energy accumulation
* Potential breakout preparation

Compression zones are highlighted in purple to make them easy to identify.

---

## Dynamic PI ATR Channel

The indicator builds a volatility channel around a Center EMA.

Components:

* Center EMA
* Dynamic PI ATR Upper Band
* Dynamic PI ATR Lower Band

Because channel width is driven by PI Power, the structure automatically adapts to changing market conditions.

This creates a responsive framework that behaves differently from static volatility bands.

---

## Breakout Logic

A breakout is only considered valid when price escapes a previously compressed structure.

### Long Break

A LONG BREAK is generated when:

* Previous bar was in compression
* Price closes above the upper PI ATR band
* Price remains above the center trend line

### Short Break

A SHORT BREAK is generated when:

* Previous bar was in compression
* Price closes below the lower PI ATR band
* Price remains below the center trend line

This approach attempts to focus on expansion moves that emerge directly from volatility contraction.

---

## Release Signal

The indicator also identifies compression releases.

A release occurs when:

* Compression ends
* PI ATR begins expanding again

These events are marked with purple release markers and can be used as early warnings that market conditions are changing.

---

## Visual Features

✔ Dynamic PI ATR volatility channel

✔ Compression highlighting

✔ Long and Short breakout signals

✔ Release markers

✔ Adaptive bar coloring

✔ Real-time information panel

✔ Alert conditions for breakout and release events

---

## Information Panel

The panel displays:

* Current Energy Value
* PI Power
* Active PI ATR
* Historical PI ATR Average
* Current Market State

Possible states:

* COMPRESS
* BULL
* BEAR
* NORMAL
* LONG BREAK
* SHORT BREAK

---

## Intended Use

PI ATR Compression Breakout is designed for traders who want to monitor:

* Volatility contractions
* Energy accumulation phases
* Expansion breakouts
* Trend continuation opportunities

The indicator is not intended to predict future price movement. Instead, it aims to visualize when market energy shifts from compression into expansion and to highlight potential breakout environments.

## Source Code

````pine
//@version=6
indicator("PI ATR COMPRESSION BREAKOUT", shorttitle="PI ATR SQUEEZE", overlay=true,
     max_lines_count=300, max_labels_count=100)

//━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━
atrLen     = input.int(14,  "ATR Length",         minval=1)
obvLen     = input.int(14,  "OBV ROC Length",     minval=1)
smoothLen  = input.int(9,   "Energy Smooth",      minval=1)
scaleLen   = input.int(100, "Normalize Length",  minval=20)
centerLen  = input.int(50,  "Center EMA",         minval=1)
repoMult   = input.float(2.0, "PI ATR Band Mult", minval=0.1, step=0.1)

compLen    = input.int(50,  "Compression Length", minval=5)
compRatio  = input.float(0.70, "Compression Ratio", minval=0.10, maxval=1.00, step=0.05)
minPower   = input.float(0.30, "Minimum PI Power",  minval=0.05, step=0.05)

showBars    = input.bool(true,  "Color Bars")
showSignals = input.bool(true,  "Show Break Signals")
showPanel   = input.bool(true,  "Panel")
showFillRef = input.bool(true,  "Avg Band Ref Fill")

//━━━━━━━━━━━━━━━━━━━
// PI ATR OBV ENERGY MOTOR
//━━━━━━━━━━━━━━━━━━━
atrValue = ta.atr(atrLen)
atrArea  = math.pi * math.pow(atrValue, 2)
obv      = ta.obv
obvRoc   = ta.roc(obv, obvLen)
obvRoot  = obvRoc >= 0 ? math.sqrt(math.abs(obvRoc)) : -math.sqrt(math.abs(obvRoc))
rawEnergy = atrArea * obvRoot

lowestE  = ta.lowest(rawEnergy, scaleLen)
highestE = ta.highest(rawEnergy, scaleLen)
energyNorm = highestE != lowestE ? 100 * (rawEnergy - lowestE) / (highestE - lowestE) : 50
energy     = ta.ema(energyNorm, smoothLen)

//━━━━━━━━━━━━━━━━━━━
// PI ATR / REPO ATR
//━━━━━━━━━━━━━━━━━━━
piPower = math.max(minPower, energy / 50.0)
piAtr   = atrValue * piPower
piAvg   = ta.sma(piAtr, compLen)
compression = piAtr < piAvg * compRatio
release     = compression[1] and not compression

//━━━━━━━━━━━━━━━━━━━
// CHANNEL
//━━━━━━━━━━━━━━━━━━━
center = ta.ema(close, centerLen)
upperBand = center + piAtr * repoMult
lowerBand = center - piAtr * repoMult
upperAvg  = center + piAvg * repoMult
lowerAvg  = center - piAvg * repoMult

//━━━━━━━━━━━━━━━━━━━
// BREAKOUT LOGIC
//━━━━━━━━━━━━━━━━━━━
var int state = 0   // 0=neutral, 1=long, -1=short

longSignal  = compression[1] and close > upperBand and close > center
shortSignal = compression[1] and close < lowerBand and close < center

longBreak  = longSignal  and state != 1
shortBreak = shortSignal and state != -1

if longBreak
    state := 1
if shortBreak
    state := -1
if not compression and close < upperBand and close > lowerBand and state != 0
    state := 0

//━━━━━━━━━━━━━━━━━━━
// COLOURS
//━━━━━━━━━━━━━━━━━━━
bullCol   = color.new(#00E676, 0)
bearCol   = color.new(#FF5252, 0)
compCol   = color.new(#E040FB, 0)
bullZone  = color.new(#00E676, 92)
bearZone  = color.new(#FF5252, 92)
compFill  = color.new(#E040FB, 90)
avgCol    = color.new(#FFD54F, 65)
centerCol = color.new(#FFB300, 0)

//━━━━━━━━━━━━━━━━━━━
// PLOTS
//━━━━━━━━━━━━━━━━━━━
pU  = plot(upperBand, "PI ATR Upper",  color=compression ? compCol : bullCol, linewidth=2)
pM  = plot(center,      "Center",      color=centerCol, linewidth=2)
pL  = plot(lowerBand, "PI ATR Lower",  color=compression ? compCol : bearCol, linewidth=2)
pUA = plot(upperAvg,   "Avg Upper",    color=avgCol, linewidth=1)
pLA = plot(lowerAvg,   "Avg Lower",    color=avgCol, linewidth=1)

//━━━━━━━━━━━━━━━━━━━
// FILLS (global scope)
//━━━━━━━━━━━━━━━━━━━
fill(pM, pU, color=compression ? compFill : bullZone, title="Upper Zone")
fill(pM, pL, color=compression ? compFill : bearZone, title="Lower Zone")
fill(pUA, pU, color=showFillRef ? color.new(avgCol, 85) : na, title="Avg-Active Upper Gap")
fill(pLA, pL, color=showFillRef ? color.new(avgCol, 85) : na, title="Avg-Active Lower Gap")

//━━━━━━━━━━━━━━━━━━━
// BAR COLORS
//━━━━━━━━━━━━━━━━━━━
barCol = showBars ?
     (compression ? (close >= center ? color.new(#E040FB, 45) : color.new(#9C27B0, 45)) :
      state == 1      ? color.new(#00E676, 55) :
      state == -1     ? color.new(#FF5252, 55) :
      close >= center ? color.new(#00E676, 75) :
      color.new(#FF5252, 75)) : na
barcolor(barCol)

//━━━━━━━━━━━━━━━━━━━
// SIGNALS
//━━━━━━━━━━━━━━━━━━━
if showSignals and longBreak
    label.new(bar_index, low,
         "▲ LONG BREAK\n" + str.tostring(close, "#.##"),
         color=bullCol, textcolor=color.white,
         style=label.style_triangleup, size=size.small, yloc=yloc.belowbar)
if showSignals and shortBreak
    label.new(bar_index, high,
         "▼ SHORT BREAK\n" + str.tostring(close, "#.##"),
         color=bearCol, textcolor=color.white,
         style=label.style_triangledown, size=size.small, yloc=yloc.abovebar)

plotshape(showSignals and longBreak,  title="Long Dot",  style=shape.triangleup,
          location=location.belowbar, color=bullCol, size=size.small)
plotshape(showSignals and shortBreak, title="Short Dot", style=shape.triangledown,
          location=location.abovebar, color=bearCol, size=size.small)
plotshape(showSignals and release, title="Release", style=shape.circle,
          location=location.bottom, color=compCol, size=size.tiny, text="REL")

//━━━━━━━━━━━━━━━━━━━
// PANEL
//━━━━━━━━━━━━━━━━━━━
var table pan = na
if barstate.islast and showPanel
    if na(pan)
        pan := table.new(position.top_right, 2, 6,
             bgcolor=color.new(#0A0A0A, 5), border_width=1,
             border_color=color.new(color.gray, 50))
    table.cell(pan, 0, 0, "PI ATR SQUEEZE", text_color=color.white, text_size=size.large)
    table.cell(pan, 1, 0, compression ? "COMPRESS" : (state == 1 ? "BULL" : state == -1 ? "BEAR" : "NORMAL"),
               text_color=compression ? compCol : state == 1 ? bullCol : state == -1 ? bearCol : color.gray)
    table.cell(pan, 0, 1, "Energy", text_color=color.gray)
    table.cell(pan, 1, 1, str.tostring(energy, "#.##"), text_color=energy >= 50 ? bullCol : bearCol)
    table.cell(pan, 0, 2, "PI Power", text_color=color.gray)
    table.cell(pan, 1, 2, str.tostring(piPower, "#.##"), text_color=color.orange)
    table.cell(pan, 0, 3, "PI ATR", text_color=color.gray)
    table.cell(pan, 1, 3, str.tostring(piAtr, "#.####"), text_color=color.teal)
    table.cell(pan, 0, 4, "ATR Avg", text_color=color.gray)
    table.cell(pan, 1, 4, str.tostring(piAvg, "#.####"), text_color=color.silver)
    table.cell(pan, 0, 5, "State", text_color=color.gray)
    stTxt = longBreak ? "LONG BREAK" : shortBreak ? "SHORT BREAK" : compression ? "SQUEEZE" : "WAIT"
    stCol = longBreak ? bullCol : shortBreak ? bearCol : compression ? compCol : color.gray
    table.cell(pan, 1, 5, stTxt, text_color=stCol)

//━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━
alertcondition(longBreak,  "PI ATR Long Break",
               "PI ATR Squeeze: LONG BREAK {{ticker}} @ {{close}}")
alertcondition(shortBreak, "PI ATR Short Break",
               "PI ATR Squeeze: SHORT BREAK {{ticker}} @ {{close}}")
alertcondition(release,     "PI ATR Release",
               "PI ATR Squeeze: RELEASE {{ticker}} @ {{close}}")
````

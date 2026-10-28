# SMI Ergodic Oscillator PRO

- url: https://www.tradingview.com/script/MfB6OYvQ/
- type: indicator
- pine_id: PUB;c9734d109c7649c8b9bd24aefc5480c8
- version: 7.0

## Description

SMI Ergodic Oscillator PRO

The SMI Ergodic Oscillator PRO is a momentum indicator designed to help traders identify changes in the strength and direction of price movement.

The indicator displays a histogram, making momentum behavior easy to visualize:

🟢 Green/Lime: momentum is gaining strength or positive slope.
🔴 Red: momentum is weakening or showing negative slope.
Larger bars: indicate stronger momentum.
Smaller bars: may indicate declining momentum and a possible loss of strength.

The main purpose of the indicator is not to generate trades by itself, but to help confirm market direction and identify potential changes in momentum.

How to Use
1. Trend Confirmation

During an uptrend, look for a sequence of consistent positive bars. Sustained momentum can provide additional confirmation that the current move remains strong.

During a downtrend, look for persistent negative bars.

2. Momentum Changes

A change in histogram color can highlight a potential shift in market momentum.

Red → Green
May indicate improving bullish momentum.

Green → Red
May indicate weakening bullish momentum or increasing bearish momentum.

Color changes should be evaluated together with price action, market structure, and the overall trend.

3. Loss of Momentum

When histogram bars begin to decrease in size, even while remaining on the same side, this may indicate that the current movement is losing strength.

This can be used as an alert to:

Reduce exposure
Protect an existing position
Wait for additional confirmation
Monitor for a potential reversal
Parameter Settings

The indicator provides three main parameters:

Parameter	Practical Function	Effect
Long Length	Controls the longer-term sensitivity	Higher values = smoother response
Short Length	Controls responsiveness to recent price movements	Lower values = faster response
Signal Length	Controls signal smoothing	Higher values = less noise
Suggested Settings
Balanced — 20 / 5 / 5

A good starting configuration for general market analysis and most timeframes.

Fast — 10 / 3 / 3

More responsive to recent momentum changes. Suitable for traders looking for earlier signals, but it may produce more noise.

Conservative — 30 / 7 / 7

Produces a smoother reading and reduces sensitivity to smaller market fluctuations.

Very Conservative — 50 / 10 / 10

Designed for traders who prefer to focus on larger and more sustained market movements.

Choosing the Right Settings

There is no universal "best" configuration. Parameters should be adapted to:

Asset: Crypto, Forex, stocks, indices, etc.
Timeframe: Scalping, day trading, or swing trading.
Volatility: Highly volatile markets may require more conservative settings.
Trading style: Faster settings can be useful for earlier momentum detection, while slower settings can provide stronger confirmation.
Simple Trading Approach

A practical approach is to use the indicator in combination with price structure and market context.

Potential Long Setup:
Favorable market structure + positive momentum + confirmation from the histogram.

Potential Short Setup:
Favorable bearish structure + negative momentum + confirmation from the histogram.

Avoid: entering a trade solely because the histogram changes color. A color change is better treated as a confirmation or warning signal, rather than an independent trading signal.

Important Notice

The SMI Ergodic Oscillator PRO is a technical analysis tool designed to assist with market analysis. It does not guarantee trading results and should not be considered financial advice. Always combine the indicator with proper risk management and independent market analysis.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at
// https://mozilla.org/MPL/2.0/

// © Canhoto-Medium

//@version=6
indicator(title="SMI Ergodic Oscillator PRO", shorttitle="SMIO PRO", format=format.price, precision=4, max_labels_count=500)

// === INPUTS ===

longlen  = input.int(20, minval=1, title="Long Length", group="🔔 Sound Alerts")
shortlen = input.int(5, minval=1, title="Short Length", group="🔔 Sound Alerts")
siglen   = input.int(5, minval=1, title="Signal Length", group="🔔 Sound Alerts")

// === MA TYPE ===

maType = input.string("EMA", "Signal MA Type", options=["EMA", "SMA", "WMA", "RMA"], group="🧮 Moving Averages")

// === SOURCE ===

srcOpt = input.string("close", "Source", options=["close", "hl2", "hlc3", "ohlc4", "hlcc4"])

src = switch srcOpt
    "close" => close
    "hl2"   => hl2
    "hlc3"  => hlc3
    "ohlc4" => ohlc4
    => hlcc4  // hlcc4

// === MULTI-TIMEFRAME ALERT ALIGNMENT ===

mtfMode = input.string("Triple", "Alignment Mode",display=display.none, options=["Dual", "Triple"], group="🕒 Multi-Timeframe Alerts")
tf1     = input.timeframe("60",  "Timeframe 1", group="🕒 Multi-Timeframe Alerts", display=display.none)
tf2     = input.timeframe("240", "Timeframe 2", group="🕒 Multi-Timeframe Alerts", display=display.none)
tf3     = input.timeframe("D",   "Timeframe 3", group="🕒 Multi-Timeframe Alerts", display=display.none)

// === BASE (TSI) ===

erg = ta.tsi(src, shortlen, longlen)

// === SIGNAL ===

sig = switch maType
    "EMA" => ta.ema(erg, siglen)
    "SMA" => ta.sma(erg, siglen)
    "RMA" => ta.rma(erg, siglen)
    => ta.wma(erg, siglen)  // WMA

// === OSCILLATOR ===

osc = erg - sig

// === ZONE (above / below zero) ===

aboveZero = osc >= 0
belowZero = osc < 0

// === EXPANSION / CONTRACTION (compared to previous bar) ===

rising  = osc > osc[1]
falling = osc < osc[1]

// === FIRST VALID BAR (end of TSI warmup) ===

firstValid = not na(osc) and na(osc[1])

// === 4 STATES (handling the first valid bar) ===

isGreen  = aboveZero and (rising or firstValid)
isBlue   = aboveZero and falling and not firstValid
isRed    = belowZero and (falling or firstValid)
isOrange = belowZero and rising and not firstValid

// === STATE PERSISTENCE ===

var color  lastColor = na
var string lastEmoji = na

if isGreen
    lastColor := color.lime
    lastEmoji := "🟢"
else if isBlue
    lastColor := color.aqua
    lastEmoji := "🔵"
else if isRed
    lastColor := color.red
    lastEmoji := "🔴"
else if isOrange
    lastColor := color.orange
    lastEmoji := "🟠"

colorHist = lastColor

// === HISTOGRAM ===

plot(na(colorHist) ? na : osc, title="SMI Ergodic", style=plot.style_histogram, color=colorHist, linewidth=3)

// === STATUS DOT (reflects current state) ===

var table statusTable = table.new(position.middle_right, 1, 1)

if barstate.islast and not na(lastEmoji)
    table.cell(statusTable, 0, 0, text=lastEmoji, text_size=size.normal, bgcolor=color.new(color.black, 100))

// === ALERTS (fire on state change) ===

stateChange = (isGreen and not isGreen[1]) or (isBlue and not isBlue[1]) or (isRed and not isRed[1]) or (isOrange and not isOrange[1])

alertcondition(isGreen and not isGreen[1],   title="SMIO 🟢 Bullish expansion",     message="SMIO PRO: histogram above zero and expanding (🟢).")
alertcondition(isBlue and not isBlue[1],     title="SMIO 🔵 Losing strength (bullish)", message="SMIO PRO: histogram above zero but contracting (🔵).")
alertcondition(isRed and not isRed[1],       title="SMIO 🔴 Bearish expansion",     message="SMIO PRO: histogram below zero and expanding (🔴).")
alertcondition(isOrange and not isOrange[1], title="SMIO 🟠 Losing strength (bearish)", message="SMIO PRO: histogram below zero but contracting (🟠).")
alertcondition(stateChange, title="SMIO ↕ State change", message="SMIO PRO: histogram state changed.")

// === MTF STATE FUNCTION (recomputes the same logic on another timeframe) ===

f_state() =>
    _erg = ta.tsi(src, shortlen, longlen)
    _sig = switch maType
        "EMA" => ta.ema(_erg, siglen)
        "SMA" => ta.sma(_erg, siglen)
        "RMA" => ta.rma(_erg, siglen)
        => ta.wma(_erg, siglen)
    _osc    = _erg - _sig
    _above  = _osc >= 0
    _below  = _osc < 0
    _rising = _osc > _osc[1]
    _first  = not na(_osc) and na(_osc[1])
    _green  = _above and (_rising or _first)
    _red    = _below and (not _rising or _first)
    _green ? 1 : _red ? -1 : 0

state_cur = isGreen ? 1 : isRed ? -1 : 0
state_tf1 = request.security(syminfo.tickerid, tf1, f_state())
state_tf2 = request.security(syminfo.tickerid, tf2, f_state())
state_tf3 = request.security(syminfo.tickerid, tf3, f_state())

// === ALIGNMENT LOGIC ===

alignBullDual = state_cur > 0 and state_tf1 > 0 and state_tf2 > 0
alignBearDual = state_cur < 0 and state_tf1 < 0 and state_tf2 < 0

alignBullTriple = alignBullDual and state_tf3 > 0
alignBearTriple = alignBearDual and state_tf3 < 0

mtfBullish = mtfMode == "Dual" ? alignBullDual : alignBullTriple
mtfBearish = mtfMode == "Dual" ? alignBearDual : alignBearTriple

alertcondition(mtfBullish and not mtfBullish[1], title="SMIO 🟢🟢 MTF Bullish Alignment", message="SMIO PRO: bullish alignment across selected timeframes.")
alertcondition(mtfBearish and not mtfBearish[1], title="SMIO 🔴🔴 MTF Bearish Alignment", message="SMIO PRO: bearish alignment across selected timeframes.")
````

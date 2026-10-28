#  VSA Trail

- url: https://www.tradingview.com/script/UiwP7rh0-VSA-Trail/
- type: indicator
- pine_id: PUB;aafba8611b7142fb9a2f4f5e5fcfad1e
- version: 1.0

## Description

Effort-Displacement VSA Trail

Effort-Displacement VSA Trail is a scalping-oriented VSA-style indicator built around a custom effort-result signal gate.

The script uses common technical-analysis building blocks such as ATR, SMA, volume, candle body, and trailing-stop direction, but the signal logic and the way these parts are combined are original to this script.

The core idea is simple: a directional signal should not appear only because price crossed a trailing stop, and it should not appear only because volume increased.

A Buy or Sell label is printed only when three things align on the same bar:

1. ATR trailing-stop direction confirms the active side.
2. Volume expands above its own baseline.
3. Price displacement expands above its own baseline.

The displacement layer is calculated as:

body = abs(close - open)
gap = abs(open - previous close)
displacement = body + gap

This is the main design difference of the script.

Instead of measuring only candle body size, the script also includes the opening gap from the previous close.

This creates a stricter effort-result model: volume must be accompanied by real directional displacement before a signal is allowed.

The ATR trailing stop acts as the directional regime layer.

The volume condition acts as the effort layer.

The displacement condition acts as the result layer.

Only when direction, effort, and result confirm each other does the script print a Buy or Sell signal.

This is not a generic volume spike tool and it is not a plain ATR trailing-stop indicator.

It is a combined VSA-style confirmation model designed to reduce weak signals where volume increases but price movement does not meaningfully follow.

Public / common components used:
- ATR calculation with ta.atr()
- SMA baselines with ta.sma()
- ATR-style trailing-stop direction logic

Original elements:
- Body-plus-gap displacement confirmation
- Same-bar effort-result validation
- Signal gating that requires ATR direction, volume expansion, and displacement expansion together
- Stateful Buy/Sell logic that avoids repeating the same-side signal until direction changes

This script does not include copied third-party script code.

It was built as an original combination of standard Pine Script functions and custom signal logic.

Use case:
This indicator is intended for short-term chart analysis where the trader wants to see only those directional moments where trailing-stop bias, volume expansion, and displacement expansion confirm each other.

Limitations:
The script is not a complete trading system.

It does not include position sizing, take-profit rules, slippage modeling, spread handling, or full risk management.

Signals can still fail in choppy, illiquid, or news-driven market conditions.

Disclaimer:
This script is for educational and informational purposes only.

It is not financial advice, investment advice, or a recommendation to buy or sell any asset.

Trading involves risk.

Past signals do not guarantee future results.

Always use your own analysis and risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © blntduman 2026

//@version=6
indicator(title="Effort-Displacement VSA Trail", shorttitle="VSA Trail", overlay=true)

// ==========================================
// 1. SETTINGS
// ==========================================
atrPeriod = input.int(20, title="ATR Period")
atrMultiplier = input.float(4.0, title="ATR Multiplier", minval=0.5, maxval=1000.0, step=0.1)
vol_length = input.int(20, title="Volume and Disp SMA Period", minval=1)

// ==========================================
// 2. VOL_ATR TRAILING STOP CALCULATION
// ==========================================
atr = ta.atr(atrPeriod)
nLoss = atrMultiplier * atr

float xATRTrailingStop = na
float prevStop = nz(xATRTrailingStop[1], 0.0)

// Trailing Stop Line Mathematics (modern v6 version of old 'iff' chains)
if close > prevStop and nz(close[1], 0.0) > prevStop
    xATRTrailingStop := math.max(prevStop, close - nLoss)
else if close < prevStop and nz(close[1], 0.0) < prevStop
    xATRTrailingStop := math.min(prevStop, close + nLoss)
else if close > prevStop
    xATRTrailingStop := close - nLoss
else
    xATRTrailingStop := close + nLoss

// Determine ATR Direction (Trend)
int pos = na
int prevPos = nz(pos[1], 0)

if nz(close[1], 0.0) < prevStop and close > prevStop
    pos := 1
else if nz(close[1], 0.0) > prevStop and close < prevStop
    pos := -1
else
    pos := prevPos

// ==========================================
// 3. VOLUME AND DISPLACEMENT
// ==========================================
body = math.abs(close - open)
gap = math.abs(open - nz(close[1], open))
disp = body + gap
disp_avg = ta.sma(disp, vol_length)

hasVolume = not na(volume) and volume > 0
vol_avg = ta.sma(volume, vol_length)

volume_ok = hasVolume ? volume > nz(vol_avg, volume) * 1.2 : true
disp_ok = disp > nz(disp_avg, disp) * 1.2

unusual_vol_up = volume_ok and disp_ok and close > open
unusual_vol_down = volume_ok and disp_ok and close < open

// ==========================================
// 4. SCALPING TRADE ENTRY LOGIC
// ==========================================
var bool isLong = false
var bool isShort = false

// Signal Condition: VolATR direction is correct AND your Institutional Expansion (Disp+Vol) condition is triggered on that bar!
bool LONG = not isLong and pos == 1 and unusual_vol_up
bool SHORT = not isShort and pos == -1 and unusual_vol_down

if LONG
    isLong := true
    isShort := false

if SHORT
    isLong := false
    isShort := true

// ==========================================
// 5. VISUALIZATION AND ALERTS
// ==========================================
// Signal Labels
plotshape(SHORT, title="Sell", style=shape.labeldown, location=location.abovebar, size=size.normal, text="Sell", color=color.red, textcolor=color.white)
plotshape(LONG, title="Buy", style=shape.labelup, location=location.belowbar, size=size.normal, text="Buy", color=color.green, textcolor=color.white)

// Plot the Stop Line for the Scalper
color stopColor = pos == 1 ? color.green : color.red
plot(xATRTrailingStop, title="ATR Trailing Stop", color=stopColor, linewidth=2, style=plot.style_linebr)

// Alerts
alertcondition(LONG, title="Buy Signal", message="VolATR Pro: Real Institutional Volume Buy")
alertcondition(SHORT, title="Sell Signal", message="VolATR Pro: Real Institutional Volume Sell")
````

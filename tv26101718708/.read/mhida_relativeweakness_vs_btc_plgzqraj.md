# MHIDa Relative-Weakness vs BTC

- url: https://www.tradingview.com/script/PlGzqrAj/
- type: indicator
- pine_id: PUB;fc1e644a01124f53b51dc750c659658f
- version: 1.0

## Description

WHAT IT DOES
This indicator measures how much the asset on your chart is underperforming Bitcoin (or any reference symbol you choose) over a rolling window of bars. It plots the difference between the asset return and the reference return over the same window, in percent, in a separate pane. Values below zero mean the asset is weaker than the reference.

HOW IT WORKS
- It takes the asset return over the last N bars (default 10) and subtracts the reference symbol return over the same N bars. The comparison uses the just-closed bar (close[1] versus close[1+N]), so the reading is based on completed bars.
- Relative weakness = (asset return - reference return) * 100.
- When this value drops below your chosen threshold (default 8%), the pane background is shaded: that is an excess-of-weakness zone.
- If, inside that zone, the current candle closes green (close above open), a small watch triangle prints at the bottom of the pane: the underperformance is extreme AND a first sign of stabilization has appeared. The marker draws only on standard chart types.

WHY THESE PIECES ARE TOGETHER
The shaded zone alone tells you the underperformance is extreme, but an extreme can keep getting worse. The green-candle condition adds the first hint that the fall against the reference is cooling off. Neither piece is a trade signal on its own; together they point at spots worth examining by eye.

HOW TO USE IT
Works on any symbol and timeframe. Inputs: reference symbol (default BTC), window length in bars, weakness threshold in percent, and whether to require a green candle before flagging. An optional alert fires on the flag - it is a reminder to go look at the chart, not an order.

HONEST LIMITS
This is a context tool, not a signal and not financial advice. It is not a winning system on its own. The decision, the context and the risk stay with you.

## Source Code

````pine
//@version=6
// =============================================================================
// Relative-Weakness vs BTC — a tool to help you read what you are looking at.
// It is NOT a signal, NOT financial advice, and NOT a strategy that wins on
// its own. You always decide.
// =============================================================================
//
// WHAT IT DOES (in plain words):
// It measures how much the coin you are watching is LOSING AGAINST BTC.
// It computes the coin's return over the last N bars and compares it to BTC's
// return over the same window. The difference = "relative strength".
// When the coin loses a LOT against BTC (beyond a threshold, default 8%) and
// then prints a green candle (a first hint of a bounce), the panel highlights it.
//
// The idea is market-neutral: it does not look at whether the coin is rising or
// falling in absolute terms, but at whether it is UNDER-performing BTC. An excess
// of relative weakness, followed by a first green sign, is the spot this tool
// invites you to LOOK AT.
//
// THE LOGIC (honest):
// Relative weakness over a window of bars = (coin return) - (BTC return).
// It flags a spot when (coin return - BTC return) drops below a chosen threshold
// AND the current candle is green.
//
// THIS TOOL IS NOT A WINNER ON ITS OWN. It is a SUPPORT to read the chart better:
// it tells you "here there is an excess of relative weakness that is starting to
// cool off" — the decision, the context and the risk stay YOURS.
// =============================================================================

indicator("MHIDa Relative-Weakness vs BTC", overlay=false, precision=2)

// ----------------------------- INPUT (defaults = a starting point, not "the" config) ------
grpRif   = "Reference"
refSym   = input.symbol("BINANCE:BTCUSDT", "Reference symbol (BTC)", group=grpRif,
     tooltip="The coin we measure weakness against. Default BTC: it is the yardstick of the market.")

grpLogica = "Weakness logic"
lookback = input.int(10, "Window (bars)", minval=2, maxval=200, group=grpLogica,
     tooltip="How many bars we compare coin return vs BTC return over.")
soglia   = input.float(8.0, "Weakness threshold %", minval=0.5, step=0.5, group=grpLogica,
     tooltip="How much the coin must lose AGAINST BTC for it to count as an 'excess'.")
richVerde = input.bool(true, "Require green candle (hint of bounce)", group=grpLogica,
     tooltip="Highlight only when, after the weakness, a first green candle appears.")

grpVis = "Visual"
colDeb  = input.color(color.new(color.orange, 0), "Weakness color", group=grpVis)
colSeg  = input.color(color.new(color.lime, 0),   "Flag color", group=grpVis)

// ----------------------------- BTC DATA --------------------------------------
// We take BTC's close on the same timeframe as the chart.
btcClose = request.security(refSym, timeframe.period, close)

// ----------------------------- RELATIVE STRENGTH CALC ------------------------
// Return over the last "lookback" bars, for both the coin and BTC.
// The logic compares close[1] vs close[1+lookback] (the just-closed bar).
coinPrev  = close[1]
coinBase  = close[1 + lookback]
btcPrev   = btcClose[1]
btcBase   = btcClose[1 + lookback]

coinValid = not na(coinBase) and coinBase > 0
btcValid  = not na(btcBase)  and btcBase  > 0

coinRet = coinValid ? (coinPrev / coinBase - 1.0) : na
btcRet  = btcValid  ? (btcPrev  / btcBase  - 1.0) : na

// Relative weakness (in %): negative = the coin is losing against BTC.
relWeak = (coinValid and btcValid) ? (coinRet - btcRet) * 100.0 : na

// ----------------------------- FLAG CONDITION --------------------
// Excess of weakness: the coin under-performs BTC beyond the threshold.
eccesso = not na(relWeak) and relWeak < -soglia

// Hint of a bounce: green candle (close > open) on the current bar.
verde = close > open

// The flag (excess of weakness + first green candle).
// Guarded by chart.is_standard: directional markers must not draw on
// non-standard chart types (Heikin Ashi, Renko, Kagi, P&F, Range).
segnale = eccesso and (richVerde ? verde : true) and chart.is_standard

// ----------------------------- DRAWING ---------------------------------------
// Relative strength line (below zero = weaker than BTC).
plot(relWeak, "Relative strength vs BTC (%)", color=color.new(color.gray, 0), linewidth=2)
hline(0, "Par with BTC", color=color.new(color.gray, 60), linestyle=hline.style_dashed)
hline(-soglia, "Weakness threshold", color=color.new(color.orange, 40), linestyle=hline.style_dotted)

// Colored excess zone.
bgcolor(eccesso ? color.new(colDeb, 88) : na, title="Excess weakness zone")

// Marker on the flag (excess + green hint).
plotshape(segnale, title="Excess weakness cooling off", location=location.bottom,
     style=shape.triangleup, size=size.tiny, color=colSeg,
     text="watch", textcolor=color.new(color.white, 0))

// ----------------------------- PERMANENT NOTICE -----------------------------
var table nota = table.new(position.bottom_right, 1, 1, border_width=1)
if barstate.islast
    table.cell(nota, 0, 0,
         "MHIDa — a tool to help you read, not a signal nor advice.\nNot a winner on its own. You always decide.",
         text_size=size.tiny, text_color=color.new(color.gray, 0),
         bgcolor=color.new(color.black, 80))

// ----------------------------- ALERT (optional) ---------------------------
// The alert is NOT an order: it is only a reminder to GO AND LOOK at the chart.
alertcondition(segnale, title="MHIDa Rel-Weakness vs BTC — worth a look",
     message="MHIDa: excess weakness vs BTC starting to cool off. Look at the chart and decide for yourself.")
````

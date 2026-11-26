# Opening Range Breakout

- url: https://www.tradingview.com/script/KBonL7Ea/
- type: indicator
- pine_id: PUB;b28bdb35f497415886b5ba6797f61998
- version: 1.0

## Description

This indicator tracks the high and low of a configurable opening window (default: the first 15 minutes of the US cash session) and draws those levels for the rest of the trading day.
How it works
During the opening window, the running high and low are recorded. Once the window closes, both levels are drawn until the end of the day. The first confirmed close above the range high (or below the range low) is marked as a breakout — one signal per direction per day — and matching alert conditions are included. The window highlight, markers and colors are configurable, and the session time is interpreted in a selectable timezone (exchange time by default), so daylight-saving shifts are handled automatically.
Notes and limitations
Works on intraday timeframes only. A close beyond the range is a description of what happened, not a prediction: opening-range breakouts fail regularly, and the tool intentionally does not attempt to filter "good" from "bad" breakouts. Combine it with your own analysis of context, volume and risk.

## Source Code

````pine
//@version=6
// ============================================================
//  Opening Range Breakout (ORB)
//  Tracks the high/low of a configurable opening window and
//  draws those levels for the rest of the day, with one-time
//  breakout signals and alerts per direction per day.
// ============================================================
indicator("Opening Range Breakout", overlay = true)

// ---------- Inputs ----------
orSess = input.session("0930-0945", "Opening range window")
tzOpt  = input.string("Exchange", "Timezone",
     options = ["Exchange", "America/New_York", "Europe/London", "Asia/Tokyo"])
showBg  = input.bool(true, "Highlight opening range window")
showSig = input.bool(true, "Show breakout markers")

colHi = input.color(color.new(#26a69a, 0), "OR high")
colLo = input.color(color.new(#ef5350, 0), "OR low")

tz = tzOpt == "Exchange" ? syminfo.timezone : tzOpt

// ---------- Opening range tracking ----------
inOR   = timeframe.isintraday and not na(time(timeframe.period, orSess, tz))
newDay = ta.change(time("D")) != 0

var float orHi   = na
var float orLo   = na
var bool brokeUp = false
var bool brokeDn = false

if newDay
    orHi    := na
    orLo    := na
    brokeUp := false
    brokeDn := false

if inOR
    orHi := na(orHi) ? high : math.max(orHi, high)
    orLo := na(orLo) ? low  : math.min(orLo, low)

// Levels become active once the opening window has closed
orReady = not inOR and not na(orHi)

// ---------- Breakout detection (first close through, once per day) ----------
upBreak = orReady and not brokeUp and barstate.isconfirmed and close > orHi
dnBreak = orReady and not brokeDn and barstate.isconfirmed and close < orLo
if upBreak
    brokeUp := true
if dnBreak
    brokeDn := true

// ---------- Drawing ----------
plot(orReady ? orHi : na, "OR High", color.new(colHi, 20), 2, plot.style_linebr)
plot(orReady ? orLo : na, "OR Low",  color.new(colLo, 20), 2, plot.style_linebr)
bgcolor(showBg and inOR ? color.new(#2962ff, 90) : na, title = "Opening range window")

plotshape(showSig and upBreak, "Breakout up",   shape.triangleup,   location.belowbar, colHi, size = size.tiny)
plotshape(showSig and dnBreak, "Breakout down", shape.triangledown, location.abovebar, colLo, size = size.tiny)

// ---------- Alerts ----------
alertcondition(upBreak, "OR breakout up",   "ORB: price closed above the opening range high")
alertcondition(dnBreak, "OR breakout down", "ORB: price closed below the opening range low")
````

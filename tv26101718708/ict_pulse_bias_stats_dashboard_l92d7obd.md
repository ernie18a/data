# ICT Pulse - Bias & Stats Dashboard

- url: https://www.tradingview.com/script/L92d7OBD-ICT-Pulse-Bias-Stats-Dashboard/
- type: indicator
- pine_id: PUB;9fbd4d63c30f44bcb86181f9680b1732
- version: 1.0

## Description

ICT Pulse — Bias & Session Dashboard

ICT Pulse is a dashboard-style indicator designed to summarize higher-timeframe context, session status, and liquidity conditions for discretionary ICT-style futures trading.

The script does not generate buy or sell signals. Its purpose is to organize market context into a compact dashboard so traders can quickly understand where price is trading relative to previous ranges and whether session liquidity has been taken.

How it works

ICT Pulse compares the current price to the previous daily, weekly, and monthly ranges. For each range, it calculates whether price is trading in premium or discount by measuring the current close relative to the prior high, low, and midpoint.

The dashboard then combines this higher-timeframe information with session conditions. It tracks the active Asia, London, and New York sessions, records each session’s high and low, and monitors whether those levels have later been traded through.

The confluence score is a simple context score, not a signal system. Bullish and bearish scores are built from five conditions:

* Daily range position
* Weekly range position
* Monthly range position
* Whether opposing-side liquidity has been taken
* Whether price is above or below the active session midpoint

For example, the bullish score increases when price is in premium on higher timeframes, when downside liquidity has been taken, and when price is holding above the current session midpoint. The bearish score uses the opposite conditions.

Main features

* Daily, weekly, and monthly bias summary
* Premium/discount status for previous daily, weekly, and monthly ranges
* Active session detection
* Current session range tracking
* Asia, London, and New York high/low sweep status
* Bullish and bearish confluence score
* Dashboard-only layout to reduce chart clutter

How to use it

ICT Pulse is best used as a market-context tool before looking for entries. A trader can use it to check whether higher-timeframe conditions are aligned, whether important session liquidity has already been taken, and whether the current session is supporting bullish, bearish, or neutral conditions.

Suggested workflow:

1. Check daily, weekly, and monthly bias.
2. Check whether price is in premium or discount.
3. Check whether Asia, London, or New York liquidity has been taken.
4. Compare the bullish and bearish confluence scores.
5. Use a separate execution model for entries, stops, and trade management.

This script is intended for educational and analytical use only. It does not provide financial advice, trade recommendations, or guaranteed outcomes. Futures and financial market trading involves risk.

## Source Code

````pine
//Sakamoah - My 2nd Indicator #ICTPulse
//@version=6
indicator("ICT Pulse - Bias & Stats Dashboard", overlay=true, max_labels_count=100)

// ─────────────────────────────────────
// Groups
// ─────────────────────────────────────
gMain = "Main Settings"
gDash = "Dashboard"
gSess = "Sessions"

// ─────────────────────────────────────
// Inputs
// ─────────────────────────────────────
tz = input.string("America/New_York", "Timezone", group=gMain)

showDashboard = input.bool(true, "Show Dashboard", group=gDash)
dashPos = input.string("Top Right", "Position", options=["Top Right", "Middle Right", "Bottom Right"], group=gDash)
dashTransp = input.int(0, "Background Transparency", minval=0, maxval=90, group=gDash)
textSizeInput = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal"], group=gDash)

asiaSession   = input.session("1800-0000", "Asia Session", group=gSess)
londonSession = input.session("0200-0500", "London Session", group=gSess)
nySession     = input.session("0930-1200", "New York Session", group=gSess)

// ─────────────────────────────────────
// Helpers
// ─────────────────────────────────────
pos = dashPos == "Top Right" ? position.top_right : dashPos == "Middle Right" ? position.middle_right : position.bottom_right
txtSize = textSizeInput == "Tiny" ? size.tiny : textSizeInput == "Small" ? size.small : size.normal

fmt(v) =>
    na(v) ? "—" : str.tostring(v, format.mintick)

fmtPct(v) =>
    na(v) ? "—" : str.tostring(v, "#") + "%"

yesNo(v) =>
    v ? "Yes" : "No"

ynColor(v) =>
    v ? color.green : color.red

inSession(sess) =>
    not na(time(timeframe.period, sess, tz))

rangePos(_price, _hi, _lo) =>
    rng = _hi - _lo
    na(_hi) or na(_lo) or rng == 0 ? na : ((_price - _lo) / rng) * 100

rangeStatus(_price, _hi, _lo) =>
    na(_hi) or na(_lo) ? "—" : _price > _hi ? "Above high" : _price < _lo ? "Below low" : "Inside range"

zoneText(_pos) =>
    na(_pos) ? "—" : _pos >= 50 ? "Premium" : "Discount"

biasText(_price, _mid, _hi, _lo) =>
    na(_mid) or na(_hi) or na(_lo) ? "—" : _price > _hi ? "Bullish breakout" : _price < _lo ? "Bearish breakdown" : _price >= _mid ? "Bullish / premium" : "Bearish / discount"

biasColor(_txt) =>
    str.contains(_txt, "Bullish") ? color.green : str.contains(_txt, "Bearish") ? color.red : color.black

zoneColor(_pos) =>
    na(_pos) ? color.black : _pos >= 50 ? color.green : color.red

scoreColor(_score) =>
    _score >= 4 ? color.green : _score == 3 ? color.orange : color.red

directionColor(_txt) =>
    _txt == "Bullish" ? color.green : _txt == "Bearish" ? color.red : color.orange

cell(_table, _col, _row, _txt, _txtColor, _bg) =>
    table.cell(_table, _col, _row, _txt, text_color=_txtColor, bgcolor=_bg, text_size=txtSize)

// ─────────────────────────────────────
// Previous High / Low Data
// ─────────────────────────────────────
pdh = request.security(syminfo.tickerid, "D", high[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, "D", low[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

pwh = request.security(syminfo.tickerid, "W", high[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
pwl = request.security(syminfo.tickerid, "W", low[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

pmh = request.security(syminfo.tickerid, "M", high[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
pml = request.security(syminfo.tickerid, "M", low[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

pdMid = (pdh + pdl) / 2
pwMid = (pwh + pwl) / 2
pmMid = (pmh + pml) / 2

pdPos = rangePos(close, pdh, pdl)
pwPos = rangePos(close, pwh, pwl)
pmPos = rangePos(close, pmh, pml)

dailyBias   = biasText(close, pdMid, pdh, pdl)
weeklyBias  = biasText(close, pwMid, pwh, pwl)
monthlyBias = biasText(close, pmMid, pmh, pml)

// ─────────────────────────────────────
// Session Detection
// ─────────────────────────────────────
asiaOn   = inSession(asiaSession)
londonOn = inSession(londonSession)
nyOn     = inSession(nySession)

asiaPrev   = bar_index > 0 ? asiaOn[1] : false
londonPrev = bar_index > 0 ? londonOn[1] : false
nyPrev     = bar_index > 0 ? nyOn[1] : false

asiaStart   = asiaOn and not asiaPrev
asiaEnd     = not asiaOn and asiaPrev

londonStart = londonOn and not londonPrev
londonEnd   = not londonOn and londonPrev

nyStart     = nyOn and not nyPrev
nyEnd       = not nyOn and nyPrev

sessionNow = asiaOn ? "Asia" : londonOn ? "London" : nyOn ? "New York" : "No session"

// ─────────────────────────────────────
// Track Session Highs / Lows
// ─────────────────────────────────────
var float asiaHi = na
var float asiaLo = na
var float lastAH = na
var float lastAL = na

var float londonHi = na
var float londonLo = na
var float lastLH = na
var float lastLL = na

var float nyHi = na
var float nyLo = na
var float lastNYH = na
var float lastNYL = na

if asiaStart
    asiaHi := high
    asiaLo := low

if asiaOn
    asiaHi := na(asiaHi) ? high : math.max(asiaHi, high)
    asiaLo := na(asiaLo) ? low : math.min(asiaLo, low)

if asiaEnd
    lastAH := asiaHi
    lastAL := asiaLo
    asiaHi := na
    asiaLo := na

if londonStart
    londonHi := high
    londonLo := low

if londonOn
    londonHi := na(londonHi) ? high : math.max(londonHi, high)
    londonLo := na(londonLo) ? low : math.min(londonLo, low)

if londonEnd
    lastLH := londonHi
    lastLL := londonLo
    londonHi := na
    londonLo := na

if nyStart
    nyHi := high
    nyLo := low

if nyOn
    nyHi := na(nyHi) ? high : math.max(nyHi, high)
    nyLo := na(nyLo) ? low : math.min(nyLo, low)

if nyEnd
    lastNYH := nyHi
    lastNYL := nyLo
    nyHi := na
    nyLo := na

// ─────────────────────────────────────
// Persistent Sweep Memory
// ─────────────────────────────────────
var bool asiaHighTaken = false
var bool asiaLowTaken = false
var bool londonHighTaken = false
var bool londonLowTaken = false
var bool nyHighTaken = false
var bool nyLowTaken = false

if asiaEnd
    asiaHighTaken := false
    asiaLowTaken := false

if londonEnd
    londonHighTaken := false
    londonLowTaken := false

if nyEnd
    nyHighTaken := false
    nyLowTaken := false

if not na(lastAH) and high > lastAH
    asiaHighTaken := true

if not na(lastAL) and low < lastAL
    asiaLowTaken := true

if not na(lastLH) and high > lastLH
    londonHighTaken := true

if not na(lastLL) and low < lastLL
    londonLowTaken := true

if not na(lastNYH) and high > lastNYH
    nyHighTaken := true

if not na(lastNYL) and low < lastNYL
    nyLowTaken := true

anyHighTaken = asiaHighTaken or londonHighTaken or nyHighTaken
anyLowTaken  = asiaLowTaken or londonLowTaken or nyLowTaken

// ─────────────────────────────────────
// Current Session Range
// ─────────────────────────────────────
currentSessionHi = asiaOn ? asiaHi : londonOn ? londonHi : nyOn ? nyHi : na
currentSessionLo = asiaOn ? asiaLo : londonOn ? londonLo : nyOn ? nyLo : na
currentSessionMid = na(currentSessionHi) or na(currentSessionLo) ? na : (currentSessionHi + currentSessionLo) / 2
currentSessionRange = na(currentSessionHi) or na(currentSessionLo) ? na : currentSessionHi - currentSessionLo

aboveSessionMid = not na(currentSessionMid) and close >= currentSessionMid
belowSessionMid = not na(currentSessionMid) and close < currentSessionMid

// ─────────────────────────────────────
// Confluence Score
// ─────────────────────────────────────
dailyBull = not na(pdPos) and pdPos >= 50
dailyBear = not na(pdPos) and pdPos < 50

weeklyBull = not na(pwPos) and pwPos >= 50
weeklyBear = not na(pwPos) and pwPos < 50

monthlyBull = not na(pmPos) and pmPos >= 50
monthlyBear = not na(pmPos) and pmPos < 50

bullScore = 0
bullScore += dailyBull ? 1 : 0
bullScore += weeklyBull ? 1 : 0
bullScore += monthlyBull ? 1 : 0
bullScore += anyLowTaken ? 1 : 0
bullScore += aboveSessionMid ? 1 : 0

bearScore = 0
bearScore += dailyBear ? 1 : 0
bearScore += weeklyBear ? 1 : 0
bearScore += monthlyBear ? 1 : 0
bearScore += anyHighTaken ? 1 : 0
bearScore += belowSessionMid ? 1 : 0

direction = bullScore > bearScore ? "Bullish" : bearScore > bullScore ? "Bearish" : "Neutral"

// ─────────────────────────────────────
// Dashboard
// ─────────────────────────────────────
var table dash = table.new(pos, 2, 22, frame_color=color.new(color.gray, 70), frame_width=1)

if barstate.islast
    if showDashboard
        headerBg = color.new(color.black, 0)
        sectionBg = color.new(color.black, 0)
        clearBg  = color.new(color.white, dashTransp)

        mainText = color.black
        softText = color.rgb(40, 40, 40)

        cell(dash, 0, 0, "ICT Pulse", color.white, headerBg)
        cell(dash, 1, 0, "Score", color.white, headerBg)

        cell(dash, 0, 1, "Direction", mainText, clearBg)
        cell(dash, 1, 1, direction, directionColor(direction), clearBg)

        cell(dash, 0, 2, "Bull Score", mainText, clearBg)
        cell(dash, 1, 2, str.tostring(bullScore) + "/5", scoreColor(bullScore), clearBg)

        cell(dash, 0, 3, "Bear Score", mainText, clearBg)
        cell(dash, 1, 3, str.tostring(bearScore) + "/5", scoreColor(bearScore), clearBg)

        cell(dash, 0, 4, "Session", mainText, clearBg)
        cell(dash, 1, 4, sessionNow, color.blue, clearBg)

        cell(dash, 0, 5, "Range", mainText, clearBg)
        cell(dash, 1, 5, fmt(currentSessionRange), color.orange, clearBg)

        cell(dash, 0, 6, "Bias", color.white, sectionBg)
        cell(dash, 1, 6, "HTF", color.white, sectionBg)

        cell(dash, 0, 7, "Daily", mainText, clearBg)
        cell(dash, 1, 7, dailyBias, biasColor(dailyBias), clearBg)

        cell(dash, 0, 8, "D Zone", mainText, clearBg)
        cell(dash, 1, 8, zoneText(pdPos) + " " + fmtPct(pdPos), zoneColor(pdPos), clearBg)

        cell(dash, 0, 9, "Weekly", mainText, clearBg)
        cell(dash, 1, 9, weeklyBias, biasColor(weeklyBias), clearBg)

        cell(dash, 0, 10, "W Zone", mainText, clearBg)
        cell(dash, 1, 10, zoneText(pwPos) + " " + fmtPct(pwPos), zoneColor(pwPos), clearBg)

        cell(dash, 0, 11, "Monthly", mainText, clearBg)
        cell(dash, 1, 11, monthlyBias, biasColor(monthlyBias), clearBg)

        cell(dash, 0, 12, "M Zone", mainText, clearBg)
        cell(dash, 1, 12, zoneText(pmPos) + " " + fmtPct(pmPos), zoneColor(pmPos), clearBg)

        cell(dash, 0, 13, "Sweeps", color.white, sectionBg)
        cell(dash, 1, 13, "Taken?", color.white, sectionBg)

        cell(dash, 0, 14, "Asia High", mainText, clearBg)
        cell(dash, 1, 14, yesNo(asiaHighTaken), ynColor(asiaHighTaken), clearBg)

        cell(dash, 0, 15, "Asia Low", mainText, clearBg)
        cell(dash, 1, 15, yesNo(asiaLowTaken), ynColor(asiaLowTaken), clearBg)

        cell(dash, 0, 16, "London High", mainText, clearBg)
        cell(dash, 1, 16, yesNo(londonHighTaken), ynColor(londonHighTaken), clearBg)

        cell(dash, 0, 17, "London Low", mainText, clearBg)
        cell(dash, 1, 17, yesNo(londonLowTaken), ynColor(londonLowTaken), clearBg)

        cell(dash, 0, 18, "NY High", mainText, clearBg)
        cell(dash, 1, 18, yesNo(nyHighTaken), ynColor(nyHighTaken), clearBg)

        cell(dash, 0, 19, "NY Low", mainText, clearBg)
        cell(dash, 1, 19, yesNo(nyLowTaken), ynColor(nyLowTaken), clearBg)

        cell(dash, 0, 20, "PD Range", mainText, clearBg)
        cell(dash, 1, 20, rangeStatus(close, pdh, pdl), softText, clearBg)

        cell(dash, 0, 21, "Price", mainText, clearBg)
        cell(dash, 1, 21, fmt(close), color.orange, clearBg)
    else
        table.clear(dash, 0, 0, 1, 21)
````

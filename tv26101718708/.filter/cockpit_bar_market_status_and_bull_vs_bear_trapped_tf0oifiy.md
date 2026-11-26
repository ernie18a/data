# Cockpit Bar Market Status and bull vs bear trapped 

- url: https://www.tradingview.com/script/tF0OiFIY-Cockpit-Bar-Market-Status-and-bull-vs-bear-trapped/
- type: indicator
- pine_id: PUB;70323cd31cfb4e8e801a2573fa5b1e3e
- version: 1.0

## Description

just a simple way to look at what kind of market we are in, works on all time frames, all traded products.

I wrote this code with the help of claude Fable 5 before it got pulled by the usa govt.
Feel free to use it, change it, whatever...if it helps keep you on the right side of the market then good... have fun.

Ikert.

## Source Code

````pine
//@version=6
// Cockpit Bar — Regime Light + Trap Meter in ONE top-center row (v1)
// Left:  regime badge (BULL/BEAR/FLAT + ▲▲▲ strength tiers) + run clock since the state began.
// Right: Trap Meter — 🐂 % of today's buying underwater, 🐻 % of selling underwater,
//        pain-weighted net pressure (▼ red = forced-selling fuel, ▲ green = squeeze fuel).
// One table = the boxes can never stack on each other.
// Badge strobes + live bar column glows on regime change. Trap book resets 09:30 NY, dims after hours.
indicator("Cockpit Bar — Regime + Trap", "Cockpit Bar", overlay = true)

NYT = "America/New_York"

// ─── Inputs: regime ───────────────────────────────────────────────────
fastLen   = input.int(20, "Fast EMA", minval = 2, group = "Regime")
slowLen   = input.int(50, "Slow EMA", minval = 5, group = "Regime")
adxLen    = input.int(14, "ADX length", minval = 5, group = "Regime")
adxMin    = input.float(20, "Trend strength for 1st triangle (ADX)", minval = 5, maxval = 50, step = 1, group = "Regime")
adxStep   = input.float(7, "Extra ADX per triangle", minval = 2, maxval = 20, step = 1, group = "Regime")
flashSec  = input.int(15, "Flash on state change (seconds, 0 = off)", minval = 0, maxval = 120, group = "Regime")
showWord  = input.bool(true, "Show word (BULL/BEAR/FLAT)", group = "Regime")
showClock = input.bool(true, "Show run clock", group = "Regime")
bigBadge  = input.bool(true, "Big badge", group = "Regime")

// ─── Inputs: trap meter ───────────────────────────────────────────────
showTrap = input.bool(true, "Show trap meter", group = "Trap Meter")
binTicks = input.int(4, "Price bin size (ticks)", minval = 1, group = "Trap Meter")
painCap  = input.float(60, "Pressure for full red/green (10-100)", minval = 10, maxval = 100, group = "Trap Meter")

// ─── Regime logic ─────────────────────────────────────────────────────
emaF = ta.ema(close, fastLen)
emaS = ta.ema(close, slowLen)
[diP, diM, adx] = ta.dmi(adxLen, adxLen)

trending = adx >= adxMin
state = trending and emaF > emaS ? 1 : trending and emaF < emaS ? -1 : 0
lvl = state == 0 ? 0 : adx >= adxMin + 2 * adxStep ? 3 : adx >= adxMin + adxStep ? 2 : 1
grade = state * lvl   // −3 (max bear) .. +3 (max bull)

tri = lvl == 3 ? (state == 1 ? "▲▲▲" : "▼▼▼") : lvl == 2 ? (state == 1 ? "▲▲" : "▼▼") : lvl == 1 ? (state == 1 ? "▲" : "▼") : "—"
word = state == 1 ? "BULL " : state == -1 ? "BEAR " : "FLAT "
col = color.new(color.yellow, 0)
if state == 1
    col := lvl == 3 ? color.new(color.lime, 0) : lvl == 2 ? color.new(color.green, 10) : color.new(color.green, 40)
if state == -1
    col := lvl == 3 ? color.new(color.red, 0) : lvl == 2 ? color.new(color.red, 15) : color.new(color.red, 45)

// run clock: re-anchors only when a flip sticks at a bar close
var int curConfState = 0
var int stateStartMs = na
if barstate.isconfirmed
    if na(stateStartMs) or state != curConfState
        curConfState := state
        stateStartMs := time

fmtDur(int ms) =>
    s = math.max(0, math.round(ms / 1000.0))
    h = math.floor(s / 3600)
    m = math.floor((s % 3600) / 60)
    x = s % 60
    str.tostring(h) + ":" + (m < 10 ? "0" : "") + str.tostring(m) + ":" + (x < 10 ? "0" : "") + str.tostring(x)

// flash on state change (tick-driven strobe)
var int lastState = 0
var int flipAt = 0
var bool seeded = false
if barstate.islast and not seeded
    lastState := state
    seeded := true
if barstate.islast and state != lastState
    flipAt := timenow
    lastState := state
flashing = barstate.islast and flashSec > 0 and flipAt > 0 and timenow - flipAt < flashSec * 1000
blink = flashing and math.floor(timenow / 400) % 2 == 0

// ─── Trap meter logic ─────────────────────────────────────────────────
binSize = syminfo.mintick * binTicks
inRTH = not na(time(timeframe.period, "0930-1600", NYT))
newSession = inRTH and not inRTH[1]

var buyAt  = map.new<int, float>()
var sellAt = map.new<int, float>()
var float totBuy  = 0.0
var float totSell = 0.0

if newSession
    map.clear(buyAt)
    map.clear(sellAt)
    totBuy := 0.0
    totSell := 0.0

ltf = timeframe.isintraday and timeframe.multiplier > 1 ? "1" : timeframe.period
[ltH, ltL, ltC, ltV] = request.security_lower_tf(syminfo.tickerid, ltf, [high, low, close, volume])

addVol(mB, mS, float price, float bVol, float sVol) =>
    b = math.round(price / binSize)
    map.put(mB, b, nz(map.get(mB, b)) + bVol)
    map.put(mS, b, nz(map.get(mS, b)) + sVol)

if inRTH and barstate.isconfirmed
    n = array.size(ltV)
    if n > 0
        for i = 0 to n - 1
            h = array.get(ltH, i)
            l = array.get(ltL, i)
            c = array.get(ltC, i)
            v = nz(array.get(ltV, i))
            rng = h - l
            bFrac = rng > 0 ? (c - l) / rng : 0.5
            bV = v * bFrac
            addVol(buyAt, sellAt, (h + l + c) / 3, bV, v - bV)
            totBuy := totBuy + bV
            totSell := totSell + (v - bV)
    else
        rng = high - low
        bFrac = rng > 0 ? (close - low) / rng : 0.5
        bV = nz(volume) * bFrac
        addVol(buyAt, sellAt, hlc3, bV, nz(volume) - bV)
        totBuy := totBuy + bV
        totSell := totSell + (nz(volume) - bV)

calcStats(float px) =>
    bullPain = 0.0
    bearPain = 0.0
    trapB = 0.0
    trapS = 0.0
    if map.size(buyAt) > 0
        ks = map.keys(buyAt)
        for i = 0 to array.size(ks) - 1
            b = array.get(ks, i)
            p = b * binSize
            if p > px
                bv = nz(map.get(buyAt, b))
                trapB += bv
                bullPain += bv * (p - px)
            else if p < px
                sv = nz(map.get(sellAt, b))
                trapS += sv
                bearPain += sv * (px - p)
    pctB = totBuy > 0 ? 100 * trapB / totBuy : 0.0
    pctS = totSell > 0 ? 100 * trapS / totSell : 0.0
    denom = bullPain + bearPain
    press = denom > 0 ? 100 * (bullPain - bearPain) / denom : 0.0
    [pctB, pctS, press]

[pctBull, pctBear, pressure] = calcStats(close)

// ─── The bar: one table, top-center, can never stack ──────────────────
var table t = table.new(position.top_center, 7, 1)
if barstate.islast
    bgC = blink ? color.white : col
    txC = blink ? col : state == 0 ? color.black : color.white
    table.cell(t, 0, 0, "  " + (showWord ? word : "") + tri + "  ", bgcolor = bgC, text_color = txC, text_size = bigBadge ? size.huge : size.large)
    if showClock
        table.cell(t, 1, 0, " " + (na(stateStartMs) ? "—" : fmtDur(timenow - stateStartMs)) + " ", bgcolor = bgC, text_color = txC, text_size = bigBadge ? size.large : size.normal)
    if showTrap
        netCol = pressure > 5 ? color.from_gradient(pressure, 0, painCap, color.new(color.red, 60), color.new(color.red, 0)) : pressure < -5 ? color.from_gradient(pressure, -painCap, 0, color.new(color.green, 0), color.new(color.green, 60)) : color.new(color.gray, 20)
        dim = inRTH ? 0 : 45
        arrow = pressure > 5 ? "▼ " : pressure < -5 ? "▲ " : "— "
        table.cell(t, 2, 0, "  ", bgcolor = color.new(color.black, 100))
        table.cell(t, 3, 0, " 🐂 " + str.tostring(pctBull, "#") + "% ", bgcolor = color.new(color.red, 100 - math.round(math.min(60.0, pctBull)) + (inRTH ? 0 : 30)), text_color = color.new(color.white, dim), text_size = size.normal)
        table.cell(t, 4, 0, " 🐻 " + str.tostring(pctBear, "#") + "% ", bgcolor = color.new(color.green, 100 - math.round(math.min(60.0, pctBear)) + (inRTH ? 0 : 30)), text_color = color.new(color.white, dim), text_size = size.normal)
        table.cell(t, 5, 0, " " + arrow + str.tostring(pressure, "#") + " ", bgcolor = color.new(netCol, dim), text_color = color.new(color.white, dim), text_size = size.normal)

// glow the live bar's column while the badge is flashing
bgcolor(flashing ? color.new(col, 65) : na, title = "Flip flash beacon")

// ─── Alerts (regime + trap) ────────────────────────────────────────────
flipBull = state == 1 and state[1] != 1
flipBear = state == -1 and state[1] != -1
flipFlat = state == 0 and state[1] != 0
maxBull  = grade == 3 and grade[1] != 3
maxBear  = grade == -3 and grade[1] != -3
heavyBullTrap = inRTH and pressure >= painCap and pressure[1] < painCap
heavyBearTrap = inRTH and pressure <= -painCap and pressure[1] > -painCap
alertcondition(flipBull, "Regime: turned BULL", "Cockpit: regime turned BULL")
alertcondition(flipBear, "Regime: turned BEAR", "Cockpit: regime turned BEAR")
alertcondition(flipFlat, "Regime: turned FLAT", "Cockpit: regime turned FLAT")
alertcondition(maxBull, "Regime: MAX BULL ▲▲▲", "Cockpit: max bull — 3 triangles")
alertcondition(maxBear, "Regime: MAX BEAR ▼▼▼", "Cockpit: max bear — 3 triangles")
alertcondition(heavyBullTrap, "Trap: heavy BULL trap", "Cockpit: trapped longs dominating — downside fuel")
alertcondition(heavyBearTrap, "Trap: heavy BEAR trap", "Cockpit: trapped shorts dominating — squeeze fuel")
````

# Adaptive Market Suite [Jayadev Rana]

- url: https://www.tradingview.com/script/4nAlzrsC-Adaptive-Market-Suite-Jayadev-Rana/
- type: indicator
- pine_id: PUB;3f2cde8a633449f3bb95d11533c0b2b6
- version: 1.0

## Description

Overview
Adaptive Market Suite is a four-module analysis toolkit that draws on the price chart. Each module is independent: turn any of them on or off, and each has its own settings group. It shows context, not buy or sell arrows. The four modules are an adaptive trend, volatility bands, market structure with order blocks and fair-value gaps, and an order-flow oscillator. You read the confluence and make your own decisions.

Module 1 - Adaptive Trend and Regime
A moving average whose smoothing adapts to Kaufman's efficiency ratio: the net distance price travelled divided by the total path it took to get there. In clean trends the ratio is high and the average speeds up to hug price; in chop it is low and the average slows and flattens. The line is coloured by its slope, and the info panel reports whether the market is trending or ranging from the same ratio.

Module 2 - Expected-Move Bands
Volatility bands around the adaptive basis. Instead of a fixed multiple of range, the band width scales with where the current Average True Range sits in its own recent history (its percentile), so the bands contract in quiet conditions and expand when volatility rises. A nearer pair and a wider pair mark two envelopes.

Module 3 - Liquidity and Structure
Market structure from confirmed swing pivots, labelled as Break of Structure and Change of Character. Because the pivots are symmetric (confirmed on both sides), they are fixed before they are drawn and do not repaint afterward. On a structure break the tool marks the order block behind the move (the last opposite-direction candle before the push) and it tracks fair-value gaps, which are three-bar imbalances. Each zone follows a mitigation lifecycle: it is extended while it is live and greyed once price trades through it, and only the most recent zones per type are kept so the chart stays readable.

Module 4 - Order-Flow Oscillator
A normalised buy and sell pressure read in the indicator pane. For each bar it combines where price closed within the bar's range with how large that bar's volume was relative to its recent average. Sustained closes near the highs on strong volume push the oscillator positive; the mirror pushes it negative. An absorption marker highlights bars with heavy volume but a small range, where effort is not producing movement.

Info panel
An optional compact table summarises the current trend direction, the regime read, the volatility percentile, and the current order-flow side. It is context only.

Inputs
Inputs are grouped per module: General (ATR length); Module 1 (efficiency length, fast and slow smoothing, regime threshold, colours); Module 2 (volatility lookback, base and extra width, colour); Module 3 (swing length, order-block lookback, max zones per type, toggles for structure, order blocks and fair-value gaps, colours); Module 4 (pressure smoothing, absorption threshold, colours); plus an info-panel toggle. Every module has a single enable switch.

Alerts
Bullish and bearish structure break, and the order-flow oscillator crossing above or below zero.

How to use it
Treat it as a confluence map rather than a signal. For example, price reaching an order block near the lower band, with the order-flow oscillator turning up while the adaptive trend is still rising, is a stronger context than any one of those alone. Turn off the modules you do not need: if you only trade structure, disable the other three groups for a clean map. It is intended for liquid instruments and works across timeframes; the demonstration chart is Gold on the 1-hour timeframe.

Limitations
The structure module confirms swings with bars on both sides, so its labels and order blocks appear a fixed number of bars after the pivot forms. That delay is the trade-off that keeps them from repainting. The bands, the oscillator and the info panel read the current bar and update as it forms, like any live calculation. This is an analysis tool, not a strategy: it places no orders, makes no performance claim, and there is no win rate because it does not promise trades.

Disclaimer
For education and research only. This is not financial advice, and past chart behaviour does not predict future results. Test any approach yourself and manage your own risk.

## Source Code

````pine
//@version=6
// ============================================================================
// Adaptive Market Suite [Jayadev Rana]
// ----------------------------------------------------------------------------
// A four-module market-analysis toolkit. Every module is independent: turn any
// on or off, and each module's settings live in its own input group. Nothing
// here is a buy/sell arrow or a win-rate claim - the value is the adaptive math
// and the visuals, and the trader makes the decision.
//
//  Module 1 - Adaptive Trend & Regime
//      A Kaufman-efficiency adaptive moving average (speeds up in clean trends,
//      slows down in noise), coloured by slope, plus a regime read (trending vs
//      ranging) from the efficiency ratio, reported in the info panel.
//  Module 2 - Expected-Move Bands
//      Volatility bands around the adaptive basis whose width scales with the
//      current ATR percentile, so they breathe with volatility instead of using
//      a fixed multiple.
//  Module 3 - Liquidity & Structure
//      Confirmed-swing market structure (BOS / CHoCH), auto Order Blocks, and
//      Fair-Value Gaps - each drawn as a zone with a mitigation lifecycle
//      (created, then greyed/removed once price trades through it).
//  Module 4 - Order-Flow Oscillator
//      A normalised buy/sell pressure read (bar close position weighted by
//      relative volume), with an absorption flag when heavy volume fails to move
//      price. This module plots in the indicator pane; the other three draw on
//      the price chart.
//
// SCOPE / HONESTY: pivots and structure are confirmed (non-repainting) once
// their pivot completes; the oscillator and bands update on the live bar. No
// higher-timeframe requests. Not financial advice; nothing here predicts the
// future or guarantees a result.
// ============================================================================
indicator("Adaptive Market Suite [Jayadev Rana]", overlay = false, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)

//==============================================================================
// GLOBAL
//==============================================================================
grpG   = "General"
atrLen = input.int(14, "ATR length", minval = 1, group = grpG)
atr    = ta.atr(atrLen)

//==============================================================================
// MODULE 1 - Adaptive Trend & Regime
//==============================================================================
g1        = "Module 1 - Adaptive Trend & Regime"
m1On      = input.bool(true,  "Enable Adaptive Trend & Regime", group = g1)
erLen     = input.int(20,     "Efficiency length", minval = 2, group = g1)
fastLen   = input.int(2,      "Fastest smoothing", minval = 1, group = g1)
slowLen   = input.int(30,     "Slowest smoothing", minval = 2, group = g1)
regimeTh  = input.float(0.35, "Trending regime threshold (0-1)", minval = 0.05, maxval = 0.95, step = 0.05, group = g1)
m1Up      = input.color(#26a69a, "Trend up", group = g1, inline = "m1c")
m1Dn      = input.color(#ef5350, "Trend down", group = g1, inline = "m1c")

// Kaufman adaptive MA
change    = math.abs(close - close[erLen])
volatility= math.sum(math.abs(close - close[1]), erLen)
er        = volatility != 0 ? change / volatility : 0.0
fastSC    = 2.0 / (fastLen + 1)
slowSC    = 2.0 / (slowLen + 1)
sc        = math.pow(er * (fastSC - slowSC) + slowSC, 2)
var float kama = na
kama := na(kama[1]) ? close : kama[1] + sc * (close - kama[1])
bool kamaUp = kama > kama[1]
color kamaCol = kamaUp ? m1Up : m1Dn
plot(m1On ? kama : na, "Adaptive MA", color = kamaCol, linewidth = 2, force_overlay = true)
plot(m1On ? kama : na, "Adaptive MA glow", color = color.new(kamaCol, 70), linewidth = 5, force_overlay = true)
bool ranging = er < regimeTh

//==============================================================================
// MODULE 2 - Expected-Move Bands
//==============================================================================
g2       = "Module 2 - Expected-Move Bands"
m2On     = input.bool(true, "Enable Expected-Move Bands", group = g2)
volLB    = input.int(100,  "Volatility percentile lookback", minval = 20, group = g2)
baseMult = input.float(1.5, "Base width (x ATR)", minval = 0.5, step = 0.5, group = g2)
widen    = input.float(1.5, "Extra width in high volatility (x ATR)", minval = 0.0, step = 0.5, group = g2)
m2Col    = input.color(#42a5f5, "Bands", group = g2)

float atrPct   = ta.percentrank(atr, volLB) / 100.0
float width    = (baseMult + widen * atrPct) * atr
float emaBasis = ta.ema(close, 20)
float basis    = m1On ? kama : emaBasis
float up1 = basis + width
float dn1 = basis - width
float up2 = basis + width * 1.8
float dn2 = basis - width * 1.8
pU1 = plot(m2On ? up1 : na, "Upper 1", color = color.new(m2Col, 40), force_overlay = true)
pD1 = plot(m2On ? dn1 : na, "Lower 1", color = color.new(m2Col, 40), force_overlay = true)
pU2 = plot(m2On ? up2 : na, "Upper 2", color = color.new(m2Col, 75), force_overlay = true)
pD2 = plot(m2On ? dn2 : na, "Lower 2", color = color.new(m2Col, 75), force_overlay = true)
fill(pU1, pU2, color = m2On ? color.new(m2Col, 90) : na, title = "Upper zone")
fill(pD1, pD2, color = m2On ? color.new(m2Col, 90) : na, title = "Lower zone")

//==============================================================================
// MODULE 3 - Liquidity & Structure (BOS/CHoCH + Order Blocks + FVG)
//==============================================================================
g3       = "Module 3 - Liquidity & Structure"
m3On     = input.bool(true, "Enable Liquidity & Structure", group = g3)
swLen    = input.int(15,   "Swing length", minval = 2, group = g3)
showBos  = input.bool(true, "Show BOS / CHoCH", group = g3)
showOB   = input.bool(true, "Show Order Blocks", group = g3)
showFVG  = input.bool(true, "Show Fair-Value Gaps", group = g3)
obLook   = input.int(12,   "Order Block lookback", minval = 3, group = g3)
maxZones = input.int(8,    "Max zones per type", minval = 1, maxval = 20, group = g3)
bullCol  = input.color(#26a69a, "Bullish zone", group = g3, inline = "m3c")
bearCol  = input.color(#ef5350, "Bearish zone", group = g3, inline = "m3c")

type Zone
    box  bx
    bool bull
    bool dead

var array<Zone> obs  = array.new<Zone>()
var array<Zone> fvgs = array.new<Zone>()

ph3 = ta.pivothigh(high, swLen, swLen)
pl3 = ta.pivotlow(low, swLen, swLen)
var float lastSwH = na
var float lastSwL = na
var bool  upBias  = true
if not na(ph3)
    lastSwH := ph3
if not na(pl3)
    lastSwL := pl3

// structure break on close through the most recent confirmed swing
bool bosUp = m3On and not na(lastSwH) and close > lastSwH and close[1] <= lastSwH
bool bosDn = m3On and not na(lastSwL) and close < lastSwL and close[1] >= lastSwL
if m3On and showBos and bosUp
    label.new(bar_index, lastSwH, upBias ? "BOS" : "CHoCH", style = label.style_label_down, color = color.new(bullCol, 15), textcolor = color.white, size = size.tiny, force_overlay = true)
    upBias := true
if m3On and showBos and bosDn
    label.new(bar_index, lastSwL, upBias ? "CHoCH" : "BOS", style = label.style_label_up, color = color.new(bearCol, 15), textcolor = color.white, size = size.tiny, force_overlay = true)
    upBias := false

pushZone(array<Zone> a, box b, bool bull) =>
    array.push(a, Zone.new(b, bull, false))
    while array.size(a) > maxZones
        Zone z = array.shift(a)
        box.delete(z.bx)

// Order Blocks: last opposite-colour candle before a structure break
if m3On and showOB and (bosUp or bosDn)
    bool wantBull = bosUp
    int found = -1
    for k = 1 to obLook
        bool downC = close[k] < open[k]
        if wantBull and downC
            found := k
            break
        if (not wantBull) and (not downC)
            found := k
            break
    if found >= 0
        float zt = high[found]
        float zb = low[found]
        box b = box.new(bar_index - found, zt, bar_index + 6, zb, border_color = color.new(wantBull ? bullCol : bearCol, 20), bgcolor = color.new(wantBull ? bullCol : bearCol, 82), force_overlay = true)
        pushZone(obs, b, wantBull)

// Fair-Value Gaps: 3-bar imbalance
bool fvgBull = m3On and showFVG and low > high[2]
bool fvgBear = m3On and showFVG and high < low[2]
if fvgBull
    box b = box.new(bar_index - 2, low, bar_index + 6, high[2], border_color = color.new(bullCol, 40), bgcolor = color.new(bullCol, 85), force_overlay = true)
    pushZone(fvgs, b, true)
if fvgBear
    box b = box.new(bar_index - 2, low[2], bar_index + 6, high, border_color = color.new(bearCol, 40), bgcolor = color.new(bearCol, 85), force_overlay = true)
    pushZone(fvgs, b, false)

// mitigation lifecycle: extend live zones, grey them once price trades through
mitigate(array<Zone> a) =>
    if array.size(a) > 0
        for i = 0 to array.size(a) - 1
            Zone z = array.get(a, i)
            if not z.dead
                float zt = box.get_top(z.bx)
                float zb = box.get_bottom(z.bx)
                bool through = z.bull ? close < zb : close > zt
                if through
                    z.dead := true
                    box.set_bgcolor(z.bx, color.new(color.gray, 88))
                    box.set_border_color(z.bx, color.new(color.gray, 70))
                    box.set_right(z.bx, bar_index)
                else
                    box.set_right(z.bx, bar_index + 6)
mitigate(obs)
mitigate(fvgs)

//==============================================================================
// MODULE 4 - Order-Flow Oscillator (plots in this pane)
//==============================================================================
g4       = "Module 4 - Order-Flow Oscillator"
m4On     = input.bool(true, "Enable Order-Flow Oscillator", group = g4)
flowLen  = input.int(14,   "Pressure smoothing", minval = 1, group = g4)
absTh    = input.float(1.8, "Absorption volume threshold (x average)", minval = 1.0, step = 0.1, group = g4)
m4Up     = input.color(#26a69a, "Buy pressure", group = g4, inline = "m4c")
m4Dn     = input.color(#ef5350, "Sell pressure", group = g4, inline = "m4c")

float rng4    = math.max(high - low, syminfo.mintick)
float clsPos  = (close - low) / rng4 * 2.0 - 1.0
float volSma  = ta.sma(volume, flowLen)
float relVol  = volume > 0 and volSma > 0 ? volume / volSma : 1.0
float flowRaw = clsPos * relVol
float flow    = ta.ema(flowRaw, flowLen)
bool  flowUp  = ta.crossover(flow, 0)
bool  flowDn  = ta.crossunder(flow, 0)
color fcol    = flow >= 0 ? m4Up : m4Dn
plot(m4On ? flow : na, "Order flow area", color = color.new(fcol, 55), style = plot.style_area)
plot(m4On ? flow : na, "Order flow line", color = fcol, linewidth = 1)
hline(0, "Zero", color = color.new(color.gray, 60))
bool absorption = m4On and relVol >= absTh and (high - low) <= atr * 0.7
plotshape(absorption ? flow : na, "Absorption", style = shape.circle, location = location.absolute, color = color.new(#ffb300, 0), size = size.tiny)

//==============================================================================
// INFO PANEL (context, not performance)
//==============================================================================
gP      = "Info panel"
showPanel = input.bool(true, "Show info panel", group = gP)
var table ip = table.new(position.top_right, 2, 5, frame_color = color.new(color.gray, 40), frame_width = 1, border_color = color.new(color.gray, 60), border_width = 1)
if showPanel and barstate.islast
    color bg = color.new(#131722, 0)
    table.cell(ip, 0, 0, "Adaptive Market Suite", text_color = color.white, bgcolor = bg, text_size = size.small)
    table.cell(ip, 1, 0, "", bgcolor = bg)
    table.cell(ip, 0, 1, "Trend", text_color = color.silver, bgcolor = bg, text_size = size.small)
    table.cell(ip, 1, 1, kamaUp ? "Up" : "Down", text_color = kamaUp ? m1Up : m1Dn, bgcolor = bg, text_size = size.small)
    table.cell(ip, 0, 2, "Regime", text_color = color.silver, bgcolor = bg, text_size = size.small)
    table.cell(ip, 1, 2, ranging ? "Ranging" : "Trending", text_color = color.white, bgcolor = bg, text_size = size.small)
    table.cell(ip, 0, 3, "Volatility pct", text_color = color.silver, bgcolor = bg, text_size = size.small)
    table.cell(ip, 1, 3, str.tostring(atrPct * 100, "#") + "%", text_color = color.white, bgcolor = bg, text_size = size.small)
    table.cell(ip, 0, 4, "Order flow", text_color = color.silver, bgcolor = bg, text_size = size.small)
    table.cell(ip, 1, 4, flow >= 0 ? "Buyers" : "Sellers", text_color = flow >= 0 ? m4Up : m4Dn, bgcolor = bg, text_size = size.small)

//==============================================================================
// ALERTS
//==============================================================================
alertcondition(bosUp, "Bullish structure break", "Adaptive Market Suite: bullish BOS/CHoCH")
alertcondition(bosDn, "Bearish structure break", "Adaptive Market Suite: bearish BOS/CHoCH")
alertcondition(m4On and flowUp, "Order flow flips bullish", "Adaptive Market Suite: order flow turned positive")
alertcondition(m4On and flowDn, "Order flow flips bearish", "Adaptive Market Suite: order flow turned negative")
````

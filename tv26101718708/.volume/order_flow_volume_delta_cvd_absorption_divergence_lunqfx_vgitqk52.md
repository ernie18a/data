# Order Flow Volume Delta, CVD, Absorption & Divergence [LunqFX]

- url: https://www.tradingview.com/script/Vgitqk52-Order-Flow-Volume-Delta-CVD-Absorption-Divergence-LunqFX/
- type: indicator
- pine_id: PUB;f212a963e8b94e7d8ca6f6f69997d40c
- version: 1.0

## Description

Price shows you WHERE the market went. Order flow shows you WHO pushed it there — buyers or sellers — and whether they had real volume behind the move. This Order Flow indicator reads the volume delta on every candle (the balance of buying volume vs selling volume), builds it into a cumulative volume delta (CVD) trend, and automatically marks the two order-flow events that lead price: absorption and delta divergence. Everything is drawn on your chart as clean delta candles, order-flow support/resistance levels and a live buying-pressure dashboard.

❶ THE CONCEPTS (so it's clear)

▸ VOLUME DELTA — the difference between buying volume and selling volume inside a bar. Positive delta = buyers were more aggressive, negative = sellers. It is the core of all order-flow analysis.

▸ CVD (CUMULATIVE VOLUME DELTA) — delta added up over time. A rising CVD means buyers are steadily accumulating; a falling CVD means distribution by sellers. CVD is how you see the real trend of order flow, not just price.

▸ ABSORPTION — a bar with heavy volume but almost no price movement. It means a large player (smart money / institutional) is absorbing every market order at that level. Absorption very often appears right before a reversal.

▸ DELTA DIVERGENCE — price makes a new high but CVD does not (or a new low but CVD does not). The move has no real volume behind it — a trap / exhaustion signal that warns a reversal is likely.

❷ WHAT YOU SEE ON THE CHART

▸ Delta candles — sky-blue when buyers won the bar, coral when sellers won; the brighter the candle, the more one-sided the flow. You read buying and selling pressure at a glance.

▸ Order-flow levels — every absorption (gold) and divergence (blue / coral) is projected to the right as a support/resistance level with its exact price. These are the levels where big volume actually traded, so price reacts to them again.

▸ Live dashboard — who is in control (buyers vs sellers) from the CVD, the CVD value, the current bar's buy/sell pressure split, and the latest signal.

❸ HOW TO TRADE IT — STEP BY STEP

1 — Read the BIAS. The panel shows ▲ BUYERS or ▼ SELLERS IN CONTROL from the CVD. Trade with the side that controls order flow, not against it.

2 — Watch for DELTA DIVERGENCE against the move. Price higher high while CVD makes a lower high = buyers are exhausted → look for shorts. Price lower low while CVD makes a higher low = sellers are exhausted → look for longs. This is the highest-value order-flow reversal signal.

3 — Use ABSORPTION as a reversal cue. When heavy volume fails to move price, the move is being absorbed; watch for the turn and use that gold level as your invalidation line.

4 — Trade the reaction at order-flow levels. Old absorption and divergence levels act as support and resistance — enter when the delta flips back in your favour as price returns to a level.

5 — Confirm with Bar pressure. The panel's ▲/▼ % buy shows the live buy/sell split — take the trade when it agrees with your setup and the bias.

❹ HOW IT WORKS (fully transparent)

Each bar's volume is split by where price closed in its range: buy-volume = volume × (close − low) ÷ range, sell-volume = volume × (high − close) ÷ range, and delta = buy − sell. This is a transparent, range-based volume-delta estimate — it needs no tick or bid/ask feed, so it runs on any symbol. CVD is the running sum of that delta (session-anchored on intraday charts, fully cumulative on daily and higher, handled automatically). Absorption is flagged when volume rises above its average by your chosen multiple while the candle body stays smaller than a fraction of ATR. Divergence compares each confirmed swing pivot in price with the CVD value at that pivot. Every reading comes from closed bars and confirmed pivots — no repainting, no lookahead.

Order flow is strongest on markets with true exchange volume — crypto, stocks, futures and indices — and on intraday timeframes (1m–4h), where buying and selling pressure is most meaningful. On forex, volume is broker tick-volume, so treat the delta as an approximation of order flow rather than exact.

SETTINGS — CVD reset (Session / Week / None), absorption sensitivity, divergence swing length, number of order-flow levels + glow, delta candles on/off, dashboard position.

ALERTS — bullish delta divergence, bearish delta divergence, absorption, and CVD crossing zero (buyers / sellers taking control).

This indicator is an educational market-analysis tool, not financial advice. The volume delta shown here is a transparent estimate from price and volume, not exchange-audited bid/ask order flow, and past behaviour does not guarantee future results. Always confirm with your own analysis and manage your risk.

## Source Code

````pine
//@version=6
// ============================================================================
//  Order Flow — Volume Delta, CVD, Absorption & Divergence [LunqFX]
// ----------------------------------------------------------------------------
//  ONE idea, on the chart: the balance of buying vs selling volume.
//
//  Each bar's volume is split into buy- and sell-volume from where price closed
//  in its range → VOLUME DELTA. From that:
//    • DELTA CANDLES — coloured by who won the bar (blue buyers, coral sellers).
//    • CVD — cumulative volume delta (session reset), read in the panel.
//    • ABSORPTION — heavy volume that barely moves price, drawn as a level.
//    • DELTA DIVERGENCE — price new high/low but delta does not, drawn as a level.
//  Absorption & divergence levels extend right as order-flow support/resistance.
//
//  NON-REPAINTING: delta/CVD from closed bars; levels from confirmed events.
// ============================================================================
indicator("Order Flow — Volume Delta, CVD, Absorption & Divergence [LunqFX]",
     "Order Flow [LunqFX]", overlay = true, max_labels_count = 200, max_lines_count = 60)

// ─────────────────────────────────────────────────────────────────────────
//  PALETTE  (designer pairing for a dark GREEN background: blue + coral)
// ─────────────────────────────────────────────────────────────────────────
UP      = #2EC5F6            // buyers — sky blue
UP_HI   = #86DEFB
UP_LO   = #12405A
DN      = #FF6B81            // sellers — coral rose
DN_HI   = #FFA3B1
DN_LO   = #5E1E2C
GOLD    = #F4B740
PANEL   = color.new(#0A1520, 12)
HEAD    = color.new(#132133, 0)
GRID    = #2A3A4A
TXT     = #EAF2F8
MUTE    = #8A97A6

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
gF      = "Order Flow"
cvdReset= input.string("Session","CVD reset", options=["Session","Week","None"], group=gF)
absMult = input.float(1.8,"Absorption volume ×", minval=1.2, maxval=5.0, step=0.1, group=gF)
absBody = input.float(0.35,"Absorption max body (×ATR)", minval=0.1, maxval=1.0, step=0.05, group=gF)
divLen  = input.int(8,"Divergence swing length", minval=3, maxval=30, group=gF)

gV      = "Visuals"
candOn  = input.bool(true, "Delta candles", group=gV)
levelsN = input.int(5, "Order-flow levels kept", minval=0, maxval=20, group=gV)
lineW   = input.int(2, "Level line width", minval=1, maxval=5, group=gV)
lineGlow= input.bool(true, "Level glow", group=gV)
markOn  = input.bool(true, "Event labels", group=gV)

gP      = "Dashboard"
showHUD = input.bool(true, "Show dashboard", group=gP)
hudPos  = input.string("Top Right","Position", options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group=gP)

// ─────────────────────────────────────────────────────────────────────────
//  VOLUME DELTA
// ─────────────────────────────────────────────────────────────────────────
rangeHL = math.max(high - low, syminfo.mintick)
buyVol  = volume * (close - low) / rangeHL
sellVol = volume * (high - close) / rangeHL
delta   = buyVol - sellVol
buyShare= volume > 0 ? buyVol / volume * 100.0 : 50.0

// "Session" reset only makes sense intraday; on daily+ it would reset every bar,
// so there it becomes a full cumulative CVD automatically.
sessReset = timeframe.isintraday and ta.change(time("D")) != 0
resetNow  = cvdReset == "Session" ? sessReset : cvdReset == "Week" ? ta.change(time("W")) != 0 : false
var float cvd = 0.0
cvd := resetNow ? delta : cvd + delta

atr14  = ta.atr(14)
volAvg = ta.sma(volume, 20)
dAbs   = ta.sma(math.abs(delta), 20)

// ─────────────────────────────────────────────────────────────────────────
//  ABSORPTION & DIVERGENCE
// ─────────────────────────────────────────────────────────────────────────
absorption = volume > volAvg * absMult and math.abs(close - open) < atr14 * absBody
absBuy = absorption and delta >= 0

pvh = ta.pivothigh(high, divLen, divLen)
pvl = ta.pivotlow(low, divLen, divLen)
var float lastPH  = na
var float lastPHd = na
var float lastPL  = na
var float lastPLd = na
bearDiv = false
bullDiv = false
if not na(pvh)
    cvdAt = cvd[divLen]
    if not na(lastPH) and pvh > lastPH and cvdAt < lastPHd
        bearDiv := true
    lastPH  := pvh
    lastPHd := cvdAt
if not na(pvl)
    cvdAt = cvd[divLen]
    if not na(lastPL) and pvl < lastPL and cvdAt > lastPLd
        bullDiv := true
    lastPL  := pvl
    lastPLd := cvdAt

// ─────────────────────────────────────────────────────────────────────────
//  RECORD EVENTS  (drawn as clean horizontal levels on the last bar)
// ─────────────────────────────────────────────────────────────────────────
var array<int>   evBar = array.new<int>()
var array<float> evPr  = array.new<float>()
var array<color> evCl  = array.new<color>()
pushEv(int b, float p, color c) =>
    array.push(evBar, b)
    array.push(evPr, p)
    array.push(evCl, c)
    while array.size(evBar) > 60
        array.shift(evBar)
        array.shift(evPr)
        array.shift(evCl)

if absorption
    pushEv(bar_index, math.avg(high, low), GOLD)
if bearDiv
    pushEv(bar_index - divLen, high[divLen], DN)
if bullDiv
    pushEv(bar_index - divLen, low[divLen], UP)

var array<line>  lvl   = array.new<line>()
var array<label> lvlLb = array.new<label>()
if barstate.islast
    if array.size(lvl) > 0
        for i = 0 to array.size(lvl) - 1
            line.delete(array.get(lvl, i))
        array.clear(lvl)
    if array.size(lvlLb) > 0
        for i = 0 to array.size(lvlLb) - 1
            label.delete(array.get(lvlLb, i))
        array.clear(lvlLb)
    n = array.size(evBar)
    if n > 0 and levelsN > 0
        from = math.max(0, n - levelsN)
        x2 = bar_index + 12
        for i = from to n - 1
            b0 = array.get(evBar, i)
            pr = array.get(evPr, i)
            cc = array.get(evCl, i)
            if lineGlow
                array.push(lvl, line.new(b0, pr, x2, pr, color = color.new(cc, 82), width = lineW + 5))
            array.push(lvl, line.new(b0, pr, x2, pr, color = color.new(cc, 12), width = lineW))
            array.push(lvlLb, label.new(x2, pr, "  " + str.tostring(pr, format.mintick) + "  ", style = label.style_label_left, color = color.new(#0A1520, 8), textcolor = cc, size = size.normal))

// ─────────────────────────────────────────────────────────────────────────
//  DELTA CANDLES
// ─────────────────────────────────────────────────────────────────────────
dStr    = math.min(1.0, math.abs(delta) / (dAbs * 1.2 + 1e-9))
bodyCol = delta >= 0 ? color.from_gradient(dStr, 0, 1, UP_LO, UP) : color.from_gradient(dStr, 0, 1, DN_LO, DN)
edgeCol = delta >= 0 ? UP_HI : DN_HI
plotcandle(candOn ? open : na, high, low, close, title="Delta Candles", color=bodyCol, wickcolor=edgeCol, bordercolor=edgeCol)

// ─────────────────────────────────────────────────────────────────────────
//  EVENT LABELS
// ─────────────────────────────────────────────────────────────────────────
var array<label> evLb = array.new<label>()
pushLb(label l) =>
    array.push(evLb, l)
    while array.size(evLb) > 22
        label.delete(array.shift(evLb))

if markOn and absorption
    pushLb(label.new(bar_index, absBuy ? low : high, " ABSORB ", style = absBuy ? label.style_label_up : label.style_label_down, color = GOLD, textcolor = #1A1300, size = size.normal))
if markOn and bearDiv
    pushLb(label.new(bar_index - divLen, high[divLen], " ▼ DIVERGENCE ", style = label.style_label_down, color = DN, textcolor = color.white, size = size.normal))
if markOn and bullDiv
    pushLb(label.new(bar_index - divLen, low[divLen], " ▲ DIVERGENCE ", style = label.style_label_up, color = UP, textcolor = #04222E, size = size.normal))

// ─────────────────────────────────────────────────────────────────────────
//  DASHBOARD
// ─────────────────────────────────────────────────────────────────────────
hudPosition(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.middle_right

var table hud = na
if showHUD and barstate.islast
    if not na(hud)
        table.delete(hud)
    hud := table.new(hudPosition(hudPos), 2, 5, bgcolor = PANEL, border_width = 0, frame_width = 0)
    dBias   = cvd >= 0
    biasCol = dBias ? UP_HI : DN_HI
    lblC    = MUTE

    table.cell(hud, 0, 0, "  ORDER FLOW", text_color = TXT, text_size = size.large, text_halign = text.align_left, bgcolor = HEAD)
    table.cell(hud, 1, 0, "LunqFX  ", text_color = MUTE, text_size = size.small, text_halign = text.align_right, bgcolor = HEAD)

    table.cell(hud, 0, 1, (dBias ? "  ▲ BUYERS" : "  ▼ SELLERS") + " IN CONTROL", text_color = biasCol, text_size = size.large, text_halign = text.align_left, bgcolor = PANEL)
    table.cell(hud, 1, 1, "", bgcolor = PANEL)

    table.cell(hud, 0, 2, "  CVD · " + cvdReset, text_color = lblC, text_size = size.normal, text_halign = text.align_left, bgcolor = PANEL)
    table.cell(hud, 1, 2, str.tostring(cvd, format.volume) + "  ", text_color = biasCol, text_size = size.normal, text_halign = text.align_right, bgcolor = PANEL)

    table.cell(hud, 0, 3, "  Bar pressure", text_color = lblC, text_size = size.normal, text_halign = text.align_left, bgcolor = PANEL)
    table.cell(hud, 1, 3, (delta >= 0 ? "▲ " : "▼ ") + str.tostring(math.round(buyShare)) + "% buy  ", text_color = delta >= 0 ? UP_HI : DN_HI, text_size = size.normal, text_halign = text.align_right, bgcolor = PANEL)

    sig = bearDiv ? " ▼ DIVERGENCE " : bullDiv ? " ▲ DIVERGENCE " : absorption ? " ● ABSORPTION " : cvd >= cvd[1] ? " CVD RISING " : " CVD FALLING "
    sigBg = bearDiv ? DN_LO : bullDiv ? UP_LO : absorption ? #5A4410 : color.new(GRID, 20)
    sigTx = bearDiv ? DN_HI : bullDiv ? UP_HI : absorption ? GOLD : color.new(TXT, 20)
    table.cell(hud, 0, 4, "  Signal", text_color = lblC, text_size = size.normal, text_halign = text.align_left, bgcolor = PANEL)
    table.cell(hud, 1, 4, sig, text_color = sigTx, text_size = size.normal, text_halign = text.align_center, bgcolor = sigBg)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────
alertcondition(bullDiv,     "Bullish delta divergence", "LunqFX Order Flow: bullish delta divergence")
alertcondition(bearDiv,     "Bearish delta divergence", "LunqFX Order Flow: bearish delta divergence")
alertcondition(absorption,  "Absorption",               "LunqFX Order Flow: absorption — heavy volume, little movement")
alertcondition(ta.crossover(cvd, 0),  "CVD turned positive", "LunqFX Order Flow: CVD crossed above zero")
alertcondition(ta.crossunder(cvd, 0), "CVD turned negative", "LunqFX Order Flow: CVD crossed below zero")
````

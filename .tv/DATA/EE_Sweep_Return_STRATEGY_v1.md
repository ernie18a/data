<!-- tradingview-pine-id: PUB;01395ef342074752a28f8f7d8dfb0f18 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# EE Sweep Return — STRATEGY v1

Source: https://www.tradingview.com/script/7OLnQI4B-STRATEGY-SCRIPT-Sweep-Return-v1/

## Description

STRATEGY SCRIPT

The "EE Sweep Return v1" is a liquidity capture indicator engineered to trade the failure of Opening Range Breakouts, systematically identifying when price sweeps above or below the morning range to trap breakout traders before reversing back inside.

**Architectural Breakdown**

| Phase | Timeframe (CT) | Mechanical Function |
| --- | --- | --- |
| **Calibration** | 08:30 - 09:30 | Maps the absolute High (`orH`) and Low (`orL`) of the cash session open. Visualized as a shaded box. |
| **Arming** | 09:30 - 15:00 | The indicator monitors for a breach. If price breaks the `orH`, it arms a potential short trap. If price breaks the `orL`, it arms a potential long trap. |
| **Execution** | 09:30 - 15:00 | The trigger fires. A **SHORT** prints if price sweeps the high but closes back below `orH`. A **LONG** prints if price sweeps the low but closes back above `orL`. |

**Operational Nuances**

* **Same-Bar Logic:** By default (`sameBar = true`), the indicator allows the break and the reversion to happen on a single candle (a wick rejection). If toggled off, it requires one candle to close outside the range, and a subsequent candle to close back inside.
* **Timezone Alignment:** The `America/Chicago` timezone anchors the logic perfectly to Central Time, ensuring the 08:30 - 09:30 window aligns flawlessly with the initial hour of the New York equities open.

## AI Integration: Evolving the Sweep Strategy

To elevate this first-principles liquidity concept into a perfectly optimized, high-level quantitative model, artificial intelligence must be integrated to eliminate false signals and maximize directional efficiency.

* **Granular Execution (Micro-Structure Analysis):** A standard sweep simply measures a price close. An AI-integrated model analyzes the Level 2 order book and footprint data during the sweep itself. Machine learning algorithms can detect real-time volume absorption—confirming exactly when institutional limit orders absorb retail stop-losses at the `orH` or `orL` before the candle even closes, executing the entry at the absolute geometric peak of the wick.
* **Contextual Volatility Filtering:** Neural networks can pre-calculate the probability of a sweep versus a true trend day by analyzing pre-market volume, VIX term structure, and macroeconomic data releases. If the AI determines a high-trend probability, it dynamically disables the sweep indicator to prevent fading a genuine breakout.
* **Dynamic Range Optimization:** Instead of a static 08:30 - 09:30 Opening Range, an unsupervised learning algorithm can dynamically adjust the time window block by block based on the underlying asset's real-time average true range (ATR) and relative volume (RVOL), perfectly sizing the trap parameters to the exact heartbeat of the current session.

---

## Source Code

````pine
//@version=6
strategy("EE Sweep Return — STRATEGY v1", "STRATEGY SCRIPT Sweep Return v1",
     overlay                 = true,
     process_orders_on_close = true,
     calc_on_every_tick      = false,
     pyramiding              = 0,
     initial_capital         = 50000,
     default_qty_type        = strategy.fixed,
     default_qty_value       = 1,
     commission_type         = strategy.commission.cash_per_contract,
     commission_value        = 2.00,
     slippage                = 1,
     margin_long             = 0,
     margin_short            = 0,
     max_boxes_count         = 500,
     max_labels_count        = 500)

// ==================== INPUTS ====================
tz      = input.string("America/Chicago", "Timezone",      group = "Session")
orSess  = input.session("0830-0930",      "Opening range", group = "Session")
winSess = input.session("0930-1500",      "Signal window", group = "Session")

sameBar   = input.bool(true, "Allow same-bar break and return",   group = "Logic")
strictBox = input.bool(true, "Require close back INSIDE the box", group = "Logic")
flatOnly  = input.bool(true, "Only enter when flat",              group = "Logic")

entryMode = input.string("Signal bar close", "Enter at", options = ["Signal bar close", "Next bar close"], group = "Trade")
tpPts     = input.float(50.0, "Target (points)", minval = 0.25, step = 0.25, group = "Trade")
slPts     = input.float(25.0, "Stop (points)",   minval = 0.25, step = 0.25, group = "Trade")
eodFlat   = input.bool(true,  "Flatten at end of signal window",  group = "Trade")

showBox = input.bool(true, "Show opening range box", group = "Visuals")
showLbl = input.bool(true, "Show signal labels",     group = "Visuals")
diagOn  = input.bool(true, "Show status panel",      group = "Visuals")

// ==================== STATE ====================
var float orH       = na
var float orL       = na
var bool  orOK      = false
var bool  armUp     = false
var bool  armDn     = false
var int   lastBreak = 0
var int   pend      = 0
var box   orBox     = na
var int   sigCount  = 0

// ==================== SESSION FLAGS ====================
inOR  = not na(time(timeframe.period, orSess,  tz))
inWin = not na(time(timeframe.period, winSess, tz))

orStart = inOR  and not inOR[1]
orEnd   = not inOR  and inOR[1]
winEnd  = not inWin and inWin[1]

// ==================== DAILY RESET ====================
if orStart
    orH       := na
    orL       := na
    orOK      := false
    armUp     := false
    armDn     := false
    lastBreak := 0
    pend      := 0
    orBox     := na

// ==================== BUILD OPENING RANGE ====================
if inOR
    orH := na(orH) ? high : math.max(orH, high)
    orL := na(orL) ? low  : math.min(orL, low)
    if showBox
        if na(orBox)
            orBox := box.new(bar_index, orH, bar_index, orL, border_color = color.new(color.gray, 30), bgcolor = color.new(color.gray, 90))
        else
            box.set_top(orBox, orH)
            box.set_bottom(orBox, orL)
            box.set_right(orBox, bar_index)

if orEnd
    orOK := true

if orOK and inWin and showBox and not na(orBox)
    box.set_right(orBox, bar_index)

active  = orOK and inWin and not na(orH) and not na(orL)
orWidth = not na(orH) and not na(orL) ? orH - orL : na

// ==================== ARM ON BREAK ====================
armUpPrev = armUp
armDnPrev = armDn
lbPrev    = lastBreak

if active
    brokeUp = high > orH
    brokeDn = low  < orL
    if brokeUp
        armUp := true
    if brokeDn
        armDn := true
    if brokeUp and brokeDn
        lastBreak := close >= open ? 1 : -1
    else if brokeUp
        lastBreak := 1
    else if brokeDn
        lastBreak := -1

canShort = sameBar ? armUp     : armUpPrev
canLong  = sameBar ? armDn     : armDnPrev
lb       = sameBar ? lastBreak : lbPrev

// ==================== RETURN INSIDE ====================
insideBox = active and close < orH and close > orL
retShort  = strictBox ? insideBox : close < orH
retLong   = strictBox ? insideBox : close > orL

rawShort = active and canShort and retShort
rawLong  = active and canLong  and retLong

shortSig = rawShort and (not rawLong  or lb ==  1)
longSig  = rawLong  and (not rawShort or lb == -1)

if shortSig or longSig
    armUp     := false
    armDn     := false
    lastBreak := 0
    sigCount  += 1

// ==================== ORDERS ====================
canTrade = flatOnly ? strategy.position_size == 0 : true
delayed  = entryMode == "Next bar close"
tag      = str.tostring(nz(orWidth), "#.##")

goLong() =>
    strategy.entry("SR Long", strategy.long, comment = "L w" + tag)
    strategy.exit("X L", from_entry = "SR Long", limit = close + tpPts, stop = close - slPts)

goShort() =>
    strategy.entry("SR Short", strategy.short, comment = "S w" + tag)
    strategy.exit("X S", from_entry = "SR Short", limit = close - tpPts, stop = close + slPts)

// delayed fills first, using THIS bar's close as the reference
if delayed and pend != 0
    if canTrade
        if pend == 1
            goLong()
        else
            goShort()
    pend := 0

if shortSig
    if delayed
        pend := -1
    else if canTrade
        goShort()

if longSig
    if delayed
        pend := 1
    else if canTrade
        goLong()

// ==================== END OF DAY FLAT ====================
if eodFlat and winEnd and strategy.position_size != 0
    strategy.close_all(comment = "EOD flat")

// ==================== VISUALS ====================
if showLbl and shortSig
    label.new(bar_index, high, "SHORT", style = label.style_label_down, color = color.new(color.red, 15), textcolor = color.white, size = size.small)

if showLbl and longSig
    label.new(bar_index, low, "LONG", style = label.style_label_up, color = color.new(color.teal, 15), textcolor = color.white, size = size.small)

plot(orOK ? orH : na, "OR high", color = color.new(color.gray, 20), style = plot.style_linebr, linewidth = 1)
plot(orOK ? orL : na, "OR low",  color = color.new(color.gray, 20), style = plot.style_linebr, linewidth = 1)

// ==================== STATUS PANEL ====================
var table diag = na
if diagOn and barstate.islast
    if na(diag)
        diag := table.new(position.top_right, 2, 4, border_width = 1)
    tot = strategy.closedtrades + strategy.opentrades
    table.cell(diag, 0, 0, "SR STRAT v2", text_color = color.white, bgcolor = color.new(color.purple, 10), text_size = size.small)
    table.cell(diag, 1, 0, "LIVE",        text_color = color.white, bgcolor = color.new(color.purple, 10), text_size = size.small)
    table.cell(diag, 0, 1, "Signals",     text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small)
    table.cell(diag, 1, 1, str.tostring(sigCount), text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small)
    table.cell(diag, 0, 2, "Trades",      text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small)
    table.cell(diag, 1, 2, str.tostring(tot), text_color = tot == 0 and sigCount > 0 ? color.orange : color.white, bgcolor = color.new(color.black, 20), text_size = size.small)
    table.cell(diag, 0, 3, "OR width",    text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small)
    table.cell(diag, 1, 3, str.tostring(nz(orWidth), "#.##"), text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.small)
````

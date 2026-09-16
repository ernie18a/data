<!-- tradingview-pine-id: PUB;1abcbf004d00494ea02a38bfc4e5b6b2 -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# Trding Risk-Sizing Calculator

Source: https://www.tradingview.com/script/KMCdL6PJ-Risk-Sizing-Calculator/

## Description

A simple, visual position-sizing tool for any market or timeframe.

Enter your account size and risk percentage, choose a stop-distance
method (ATR-based, manual stop price, or fixed % of entry), and the
indicator calculates your position size, stop distance, dollar risk,
notional exposure, and an optional reward-to-risk target — displayed
in a clean live table with entry and stop lines on your chart.

Also includes a 3-scenario Size Ladder (0.5% / 1% / 2% account risk
side-by-side) so you can see the sizing range at a glance, plus an
optional Market Context panel showing ATR %, RSI, ADX, volatility
class, and session state.

FEATURES
- Three stop-distance methods: ATR-based, Manual Stop Price, Fixed %
- Position size in units, notional dollars, and % of account
- Size Ladder table showing what 0.5% / 1% / 2% risk each produce
- Reward-to-risk target row (optional · pairs with an R multiple)
- Market Context panel: ATR %, RSI(14), ADX(14), volatility class,
  session flag
- Live entry + stop + target lines drawn on the chart
- Adjustable table position (top-right, middle-right, etc.)
- Clean numeric output for quick pre-trade sanity check

HOW TO USE
1. Set Direction (Long / Short) and optionally a Manual Entry Price
2. Choose your Stop Distance method — ATR, manual price, or fixed %
3. Enter Account Size and Risk per trade % (1% is a common default)
4. Optional: enable target row and set R multiple

Pairs naturally with any ATR-based visualizer or manual entry planning.
Educational only · not financial advice · does not generate buy/sell signals.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/

// ═══════════════════════════════════════════════════════════════
// Risk-Sizing Calculator · v1.1.0.
// Educational position-sizing tool. Enter your account size and
// risk percentage · get position size, stop distance, and dollar
// risk for a hypothetical trade. Uses ATR for stop distance OR
// a manual stop price OR a fixed %. Includes a 3-scenario size
// ladder (0.5% · 1% · 2%) and market-context panel.
// No buy/sell signals. Not financial advice.
// Pairs naturally with ATR Stop & Target Visualizer.
// ═══════════════════════════════════════════════════════════════
//
// v1.1.0 (2026-09-01) — Wave 1 release upgrade: Size Ladder (3
//   simultaneous risk scenarios · shows what 0.5% / 1% / 2% risk
//   produce side-by-side so trader sees the range instantly) ·
//   Market Context panel (ATR% · RSI · ADX · volatility class ·
//   session) · brand palette locked to Trding_AI family (gold
//   entry · electric blue stop · electric lime target · deep
//   navy tables).
// v1.0.0 (2026-08-31) — Initial draft. Single-scenario sizing.
//
// ═══════════════════════════════════════════════════════════════

//@version=6
indicator("Trding Risk-Sizing Calculator", shorttitle="TRDING Risk Sizer", overlay=true,
     max_lines_count=20, max_labels_count=20)

// ═══════════════════════════════════════════════════════════════
// PALETTE (Trding_AI brand · locked with ATR Visualizer + Fire)
// ═══════════════════════════════════════════════════════════════
color C_ENTRY = #D4AF37   // gold · entry reference
color C_STOP  = #3B82F6   // electric blue · stop
color C_TGT   = #5EE33E   // electric lime · target
color C_NAVY  = #0B1220   // deep navy · table bg
color C_MUTE  = #94A3B8   // slate · muted labels
color C_HEAD  = #131A2E   // panel header background

// ═══════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════

// ─── Trade Setup ───
grpT = "Trade Setup"
dir       = input.string("Long", "Direction", options=["Long", "Short"], group=grpT,
     tooltip="Direction of the hypothetical trade you want to size.")
entryMode = input.string("Current Close", "Entry Reference",
     options=["Current Close", "Manual Price"], group=grpT)
manualEntry = input.price(0.0, "Manual Entry Price", group=grpT,
     tooltip="Used only when Entry Reference = Manual Price.")

// ─── Stop Distance Method ───
grpS = "Stop Distance"
stopMethod = input.string("ATR", "Method", options=["ATR", "Manual Price", "Fixed %"], group=grpS,
     tooltip="Choose how to calculate stop distance from entry.")
atrLen     = input.int(14, "ATR Length", minval=1, group=grpS,
     tooltip="Used when Method = ATR.")
atrMult    = input.float(1.5, "Stop = ATR ×", minval=0.1, step=0.1, group=grpS,
     tooltip="Used when Method = ATR.")
manualStop = input.price(0.0, "Manual Stop Price", group=grpS,
     tooltip="Used when Method = Manual Price. Enter the exact stop price.")
fixedPct   = input.float(2.0, "Stop = fixed %", minval=0.1, step=0.1, group=grpS,
     tooltip="Used when Method = Fixed %. Stop distance as % of entry price.")

// ─── Account + Risk ───
grpA = "Account + Risk"
acctSize = input.float(10000, "Account Size ($)", minval=0, group=grpA)
riskPct  = input.float(1.0, "Risk per trade (%)", minval=0.01, step=0.1, group=grpA,
     tooltip="Percent of account you're willing to lose if the stop hits. 1% is a common default.")

// ─── Target (optional) ───
grpTgt = "Target (optional)"
showTarget = input.bool(true, "Show target row in table", group=grpTgt)
rr         = input.float(2.0, "Target = R multiple", minval=0.1, step=0.1, group=grpTgt,
     tooltip="Reward-to-risk. 2.0 means the target is twice the stop distance.")

// ─── Display ───
grpD = "Display"
showLines     = input.bool(true, "Draw entry + stop lines on chart", group=grpD)
showTable     = input.bool(true, "Show risk-sizing table", group=grpD)
showLadder    = input.bool(true, "Show size ladder (0.5% / 1% / 2% scenarios)", group=grpD,
     tooltip="Adds a compact 3-column table showing what different risk % values produce for size + notional. Helps you see the range at a glance.")
showContext   = input.bool(true, "Show market-context panel", group=grpD,
     tooltip="Adds ATR% · RSI · ADX · volatility class · session panel.")
tablePosition = input.string("top_right", "Table Position",
     options=["top_left","top_right","middle_right","bottom_right","bottom_left"], group=grpD)

// ═══════════════════════════════════════════════════════════════
// CALCULATIONS
// ═══════════════════════════════════════════════════════════════
isLong    = dir == "Long"
useManual = entryMode == "Manual Price" and manualEntry > 0
entry     = useManual ? manualEntry : close

// Stop distance depending on method
atrVal = ta.atr(atrLen)
stopDistATR    = atrVal * atrMult
stopDistFixed  = entry * fixedPct / 100.0
stopDistManual = manualStop > 0 ? math.abs(entry - manualStop) : 0.0

stopDist = stopMethod == "ATR" ? stopDistATR : stopMethod == "Manual Price" ? stopDistManual : stopDistFixed

// Stop + target prices
stop   = isLong ? entry - stopDist : entry + stopDist
target = isLong ? entry + stopDist * rr : entry - stopDist * rr

// Primary scenario sizing math
riskDollars = acctSize * riskPct / 100.0
qtyUnits    = stopDist > 0 ? math.floor(riskDollars / stopDist) : 0
notional    = qtyUnits * entry
notionalPct = acctSize > 0 ? (notional / acctSize) * 100.0 : 0.0
stopDistPct = entry > 0 ? (stopDist / entry) * 100.0 : 0.0

// ─── Size ladder · 3 fixed scenarios (0.5%, 1%, 2%) ───
_r05 = acctSize * 0.5 / 100.0
_r10 = acctSize * 1.0 / 100.0
_r20 = acctSize * 2.0 / 100.0
_q05 = stopDist > 0 ? math.floor(_r05 / stopDist) : 0
_q10 = stopDist > 0 ? math.floor(_r10 / stopDist) : 0
_q20 = stopDist > 0 ? math.floor(_r20 / stopDist) : 0
_n05 = _q05 * entry
_n10 = _q10 * entry
_n20 = _q20 * entry

// ═══════════════════════════════════════════════════════════════
// MARKET CONTEXT
// ═══════════════════════════════════════════════════════════════
rsiVal = ta.rsi(close, 14)
atrPct = close > 0 ? (atrVal / close) * 100.0 : 0.0

_upMove2   = ta.change(high)
_downMove2 = -ta.change(low)
_plusDM2   = _upMove2 > _downMove2 and _upMove2 > 0 ? _upMove2 : 0.0
_minusDM2  = _downMove2 > _upMove2 and _downMove2 > 0 ? _downMove2 : 0.0
_trADX2    = ta.rma(ta.tr(true), 14)
_plusDI2   = 100 * ta.rma(_plusDM2, 14) / (_trADX2 == 0 ? 1 : _trADX2)
_minusDI2  = 100 * ta.rma(_minusDM2, 14) / (_trADX2 == 0 ? 1 : _trADX2)
_dxSum2    = _plusDI2 + _minusDI2
_dx2       = _dxSum2 == 0 ? 0.0 : 100 * math.abs(_plusDI2 - _minusDI2) / _dxSum2
adxVal     = ta.rma(_dx2, 14)

atrAvg   = ta.sma(atrVal, 42)
volRatio = atrAvg > 0 ? atrVal / atrAvg : 1.0
volClass = volRatio < 0.7 ? "Low" : volRatio > 2.5 ? "Extreme" : volRatio > 1.5 ? "High" : "Normal"
sessionFlag = session.ismarket ? "Regular" : session.ispremarket ? "Pre-market" : session.ispostmarket ? "After-hours" : "Closed"

// ═══════════════════════════════════════════════════════════════
// FORMATTING HELPERS
// ═══════════════════════════════════════════════════════════════
f_p(p) => str.tostring(p, format.mintick)
f_d(v, d) => str.tostring(v, "#." + str.tostring(d, "0"))

rsiText = str.tostring(rsiVal, "#.#") + (rsiVal >= 70 ? " · OB" : rsiVal <= 30 ? " · OS" : " · OK")
adxText = str.tostring(adxVal, "#.#") + (adxVal >= 25 ? " · TREND" : adxVal >= 20 ? " · WEAK" : " · CHOP")
rsiColor = rsiVal >= 70 or rsiVal <= 30 ? C_STOP : C_TGT
adxColor = adxVal >= 25 ? C_TGT : adxVal >= 20 ? C_ENTRY : C_MUTE

// Convert table position input string → position constant
tblPos = tablePosition == "top_left" ? position.top_left : tablePosition == "top_right" ? position.top_right : tablePosition == "middle_right" ? position.middle_right : tablePosition == "bottom_right" ? position.bottom_right : position.bottom_left

// ═══════════════════════════════════════════════════════════════
// DRAWING (last-bar only)
// ═══════════════════════════════════════════════════════════════
var line  lE = na, var line  lS = na, var line  lT = na
var label eL = na, var label sL = na, var label tL = na
var table tbl = na
var table lad = na
var table ctx = na

if barstate.islast
    line.delete(lE), line.delete(lS), line.delete(lT)
    label.delete(eL), label.delete(sL), label.delete(tL)

    x1 = bar_index - 5
    x2 = bar_index + 10

    if showLines and stopDist > 0
        lE := line.new(x1, entry, x2, entry, xloc.bar_index, color=C_ENTRY, width=2)
        lS := line.new(x1, stop,  x2, stop,  xloc.bar_index, color=C_STOP,  width=2, style=line.style_dashed)

        eL := label.new(x2, entry, "Entry  " + f_p(entry), xloc.bar_index,
             style=label.style_label_left, color=C_ENTRY, textcolor=color.white, size=size.small)
        sL := label.new(x2, stop, "Stop  " + f_p(stop) + "   ·  1R", xloc.bar_index,
             style=label.style_label_left, color=C_STOP, textcolor=color.white, size=size.small)

        if showTarget
            lT := line.new(x1, target, x2, target, xloc.bar_index, color=C_TGT, width=2, style=line.style_dashed)
            tL := label.new(x2, target, "Target  " + f_p(target) + "   ·  " + str.tostring(rr, "#.#") + "R", xloc.bar_index,
                 style=label.style_label_left, color=C_TGT, textcolor=color.black, size=size.small)

// ═══════════════════════════════════════════════════════════════
// RISK-SIZING TABLE (primary scenario)
// ═══════════════════════════════════════════════════════════════
if showTable and barstate.islast
    rows = showTarget ? 11 : 10
    if na(tbl)
        tbl := table.new(tblPos, 2, rows, border_width=1, border_color=color.new(C_MUTE, 60))
    hdr = color.new(C_HEAD, 0)
    row = color.new(C_NAVY, 15)

    table.cell(tbl, 0, 0, "RISK PLAN", text_color=C_ENTRY, text_size=size.small, bgcolor=hdr)
    table.cell(tbl, 1, 0, isLong ? "LONG" : "SHORT", text_color=isLong ? C_TGT : C_STOP, text_size=size.small, bgcolor=hdr)

    table.cell(tbl, 0, 1, "Account $",           text_color=C_MUTE,      text_size=size.small, bgcolor=row)
    table.cell(tbl, 1, 1, f_d(acctSize, 2),      text_color=color.white, text_size=size.small, bgcolor=row)

    table.cell(tbl, 0, 2, "Risk %",              text_color=C_MUTE,      text_size=size.small, bgcolor=row)
    table.cell(tbl, 1, 2, f_d(riskPct, 2) + "%", text_color=color.white, text_size=size.small, bgcolor=row)

    table.cell(tbl, 0, 3, "Risk $",              text_color=C_MUTE,      text_size=size.small, bgcolor=row)
    table.cell(tbl, 1, 3, f_d(riskDollars, 2),   text_color=C_STOP,      text_size=size.small, bgcolor=row)

    table.cell(tbl, 0, 4, "Entry",               text_color=C_MUTE,      text_size=size.small, bgcolor=row)
    table.cell(tbl, 1, 4, f_p(entry),            text_color=C_ENTRY,     text_size=size.small, bgcolor=row)

    table.cell(tbl, 0, 5, "Stop (" + stopMethod + ")", text_color=C_MUTE, text_size=size.small, bgcolor=row)
    table.cell(tbl, 1, 5, f_p(stop),             text_color=C_STOP,      text_size=size.small, bgcolor=row)

    table.cell(tbl, 0, 6, "Stop distance",       text_color=C_MUTE,      text_size=size.small, bgcolor=row)
    table.cell(tbl, 1, 6, f_p(stopDist) + " · " + f_d(stopDistPct, 2) + "%", text_color=color.white, text_size=size.small, bgcolor=row)

    table.cell(tbl, 0, 7, "Size (units)",        text_color=C_MUTE,      text_size=size.small, bgcolor=row)
    table.cell(tbl, 1, 7, str.tostring(qtyUnits), text_color=color.white, text_size=size.small, bgcolor=row)

    table.cell(tbl, 0, 8, "Notional $",          text_color=C_MUTE,      text_size=size.small, bgcolor=row)
    table.cell(tbl, 1, 8, f_d(notional, 2),      text_color=color.white, text_size=size.small, bgcolor=row)

    table.cell(tbl, 0, 9, "Notional / Account",  text_color=C_MUTE,      text_size=size.small, bgcolor=row)
    table.cell(tbl, 1, 9, f_d(notionalPct, 1) + "%", text_color=color.white, text_size=size.small, bgcolor=row)

    if showTarget
        table.cell(tbl, 0, 10, "Target (" + str.tostring(rr, "#.#") + "R)", text_color=C_MUTE, text_size=size.small, bgcolor=row)
        table.cell(tbl, 1, 10, f_p(target),      text_color=C_TGT,       text_size=size.small, bgcolor=row)

// ═══════════════════════════════════════════════════════════════
// SIZE LADDER · 3 SCENARIOS SIDE-BY-SIDE (middle_right)
// ═══════════════════════════════════════════════════════════════
if showLadder and barstate.islast
    if na(lad)
        lad := table.new(position.middle_right, 4, 5, border_width=1, border_color=color.new(C_MUTE, 60))
    hdrL = color.new(C_HEAD, 0)
    rowL = color.new(C_NAVY, 15)

    // Header
    table.cell(lad, 0, 0, "SIZE LADDER", text_color=C_ENTRY, text_size=size.small, bgcolor=hdrL)
    table.cell(lad, 1, 0, "0.5%",        text_color=C_MUTE,  text_size=size.small, bgcolor=hdrL)
    table.cell(lad, 2, 0, "1.0%",        text_color=C_MUTE,  text_size=size.small, bgcolor=hdrL)
    table.cell(lad, 3, 0, "2.0%",        text_color=C_MUTE,  text_size=size.small, bgcolor=hdrL)

    // Risk $
    table.cell(lad, 0, 1, "Risk $",      text_color=C_MUTE,      text_size=size.small, bgcolor=rowL)
    table.cell(lad, 1, 1, f_d(_r05, 2),  text_color=color.white, text_size=size.small, bgcolor=rowL)
    table.cell(lad, 2, 1, f_d(_r10, 2),  text_color=C_STOP,      text_size=size.small, bgcolor=rowL)
    table.cell(lad, 3, 1, f_d(_r20, 2),  text_color=color.white, text_size=size.small, bgcolor=rowL)

    // Size units
    table.cell(lad, 0, 2, "Size (u)",    text_color=C_MUTE,      text_size=size.small, bgcolor=rowL)
    table.cell(lad, 1, 2, str.tostring(_q05), text_color=color.white, text_size=size.small, bgcolor=rowL)
    table.cell(lad, 2, 2, str.tostring(_q10), text_color=color.white, text_size=size.small, bgcolor=rowL)
    table.cell(lad, 3, 2, str.tostring(_q20), text_color=color.white, text_size=size.small, bgcolor=rowL)

    // Notional
    table.cell(lad, 0, 3, "Notional",    text_color=C_MUTE,       text_size=size.small, bgcolor=rowL)
    table.cell(lad, 1, 3, f_d(_n05, 0),  text_color=color.white,  text_size=size.small, bgcolor=rowL)
    table.cell(lad, 2, 3, f_d(_n10, 0),  text_color=color.white,  text_size=size.small, bgcolor=rowL)
    table.cell(lad, 3, 3, f_d(_n20, 0),  text_color=color.white,  text_size=size.small, bgcolor=rowL)

    // Notional %
    table.cell(lad, 0, 4, "Notional %",  text_color=C_MUTE,       text_size=size.small, bgcolor=rowL)
    table.cell(lad, 1, 4, f_d(acctSize > 0 ? _n05 / acctSize * 100 : 0, 1) + "%", text_color=color.white, text_size=size.small, bgcolor=rowL)
    table.cell(lad, 2, 4, f_d(acctSize > 0 ? _n10 / acctSize * 100 : 0, 1) + "%", text_color=color.white, text_size=size.small, bgcolor=rowL)
    table.cell(lad, 3, 4, f_d(acctSize > 0 ? _n20 / acctSize * 100 : 0, 1) + "%", text_color=color.white, text_size=size.small, bgcolor=rowL)

// ═══════════════════════════════════════════════════════════════
// MARKET CONTEXT PANEL (bottom_right)
// ═══════════════════════════════════════════════════════════════
if showContext and barstate.islast
    if na(ctx)
        ctx := table.new(position.bottom_right, 2, 6, border_width=1, border_color=color.new(C_MUTE, 60))
    hdrC = color.new(C_HEAD, 0)
    rowC = color.new(C_NAVY, 15)

    table.cell(ctx, 0, 0, "MARKET CONTEXT", text_color=C_ENTRY, text_size=size.small, bgcolor=hdrC)
    table.cell(ctx, 1, 0, "",               text_color=C_MUTE,  text_size=size.small, bgcolor=hdrC)

    table.cell(ctx, 0, 1, "ATR %",          text_color=C_MUTE,      text_size=size.small, bgcolor=rowC)
    table.cell(ctx, 1, 1, f_d(atrPct, 2) + "%", text_color=color.white, text_size=size.small, bgcolor=rowC)

    table.cell(ctx, 0, 2, "RSI(14)",        text_color=C_MUTE,      text_size=size.small, bgcolor=rowC)
    table.cell(ctx, 1, 2, rsiText,          text_color=rsiColor,    text_size=size.small, bgcolor=rowC)

    table.cell(ctx, 0, 3, "ADX(14)",        text_color=C_MUTE,      text_size=size.small, bgcolor=rowC)
    table.cell(ctx, 1, 3, adxText,          text_color=adxColor,    text_size=size.small, bgcolor=rowC)

    table.cell(ctx, 0, 4, "Volatility",     text_color=C_MUTE,      text_size=size.small, bgcolor=rowC)
    table.cell(ctx, 1, 4, volClass,         text_color=color.white, text_size=size.small, bgcolor=rowC)

    table.cell(ctx, 0, 5, "Session",        text_color=C_MUTE,      text_size=size.small, bgcolor=rowC)
    table.cell(ctx, 1, 5, sessionFlag,      text_color=color.white, text_size=size.small, bgcolor=rowC)
````

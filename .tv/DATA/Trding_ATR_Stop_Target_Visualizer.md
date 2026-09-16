<!-- tradingview-pine-id: PUB;c3322fd09918408cb4d86a1d0238aa62 -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# Trding ATR Stop & Target Visualizer

Source: https://www.tradingview.com/script/JFXMkdD7-ATR-Stop-Target-Visualizer/

## Description

A simple, visual risk-planning tool for any market or timeframe.

Choose a direction (Long/Short) and the indicator plots an ATR-based
stop-loss, three reward-to-risk targets (TP1, TP2, TP3), shaded
risk / reward zones, and a live trade-plan table summarizing entry,
stop, targets, R:R math, ATR value, dollar risk, and a simplified
position-size estimate.

Also includes an optional Market Context panel showing ATR %, RSI,
ADX, volatility class, and session state — so the risk plan sits
alongside the environment reading you're planning against.

FEATURES
- ATR-based stop distance with selectable smoothing (RMA/SMA/EMA/WMA)
- Three reward-to-risk targets (TP1/TP2/TP3) with independent R
  multiples · defaults 1R / 2R / 3R
- Layered shaded reward zones (densest at TP1, lightest at TP3)
- Auto or manual entry price
- Trade-plan table with all key numbers at a glance
- Simplified position-size estimate (account × risk %)
- Market Context panel: ATR %, RSI(14), ADX(14), volatility class,
  session flag
- Clean single-bar drawing to keep charts readable

HOW TO USE
1. Set Direction (Long / Short) and optionally a Manual Entry Price
2. Tune the ATR length and stop multiple to fit the instrument's
   volatility
3. Set each target as an R multiple (defaults 1R / 2R / 3R)
4. Enter account size and risk % to see a suggested position size

This is a visual risk-planning tool built to help traders think in
terms of risk first. Educational only · not financial advice · does
not generate buy/sell signals.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/

// ═══════════════════════════════════════════════════════════════
// ATR Stop & Target Visualizer · v1.1.0
// Educational risk-visualization tool. Draws an ATR-based stop-loss,
// three reward-to-risk targets (TP1/TP2/TP3), shaded risk / reward
// zones, a live market-context panel, and a simplified position-size
// estimate for a hypothetical trade.
// No buy/sell signals. Not financial advice.
// ═══════════════════════════════════════════════════════════════
//
// v1.1.0 (2026-09-01) — Tier upgrade for Wave 1 release: TP1/TP2/TP3
//   with independent R multiples (default 1/2/3) · layered shaded
//   reward zones (light → dense) matching Trding Fire's tiered TP
//   language · new Market Context panel (ATR% · RSI · ADX · volatility
//   class · session risk) · reward:risk row in trade plan · brand
//   palette locked to Trding_AI family (gold entry · electric blue
//   stop · electric lime targets · deep navy tables).
// v1.0.0 (2026-08-31) — Initial draft. Single target, single R.
//
// ═══════════════════════════════════════════════════════════════

//@version=6
indicator("Trding ATR Stop & Target Visualizer", shorttitle="TRDING ATR SL/TP", overlay=true,
     max_lines_count=50, max_labels_count=50, max_boxes_count=50)

// ═══════════════════════════════════════════════════════════════
// PALETTE (Trding_AI brand · locked with Score + Fire v2.11.0)
// ═══════════════════════════════════════════════════════════════
color C_ENTRY = #D4AF37   // gold · entry reference (neutral role)
color C_STOP  = #3B82F6   // electric blue · stop loss role
color C_TGT   = #5EE33E   // electric lime · target role
color C_NAVY  = #0B1220   // deep navy · table backgrounds
color C_MUTE  = #94A3B8   // slate · muted labels
color C_HEAD  = #131A2E   // panel header background

// ═══════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════

// ─── Trade Setup ───
grpT = "Trade Setup"
dir       = input.string("Long", "Direction", options=["Long", "Short"], group=grpT,
     tooltip="Direction of the hypothetical trade you want to visualize.")
entryMode = input.string("Current Close", "Entry Reference",
     options=["Current Close", "Manual Price"], group=grpT)
manualEntry = input.price(0.0, "Manual Entry Price", group=grpT,
     tooltip="Used only when Entry Reference = Manual Price.")

// ─── Risk Model (ATR) ───
grpR = "Risk Model (ATR)"
atrLen    = input.int(14, "ATR Length", minval=1, group=grpR)
atrSmooth = input.string("RMA", "ATR Smoothing", options=["RMA", "SMA", "EMA", "WMA"], group=grpR)
stopMult  = input.float(1.5, "Stop = ATR ×", minval=0.1, step=0.1, group=grpR,
     tooltip="Stop distance as a multiple of ATR.")

// ─── Targets (3 R multiples) ───
grpTP = "Targets · TP1 / TP2 / TP3"
tp1R = input.float(1.0, "TP1 · R multiple", minval=0.1, step=0.1, group=grpTP,
     tooltip="TP1 distance in R multiples. Default 1.0 = same distance as stop (breakeven scale).")
tp2R = input.float(2.0, "TP2 · R multiple", minval=0.1, step=0.1, group=grpTP,
     tooltip="TP2 distance in R multiples. Default 2.0 = 2× stop distance (balanced target).")
tp3R = input.float(3.0, "TP3 · R multiple", minval=0.1, step=0.1, group=grpTP,
     tooltip="TP3 distance in R multiples. Default 3.0 = 3× stop distance (runner target).")

// ─── Position Sizing (optional) ───
grpP = "Position Sizing"
showSize = input.bool(true, "Show position size", group=grpP)
acctSize = input.float(10000, "Account Size ($)", minval=0, group=grpP)
riskPct  = input.float(1.0, "Risk per trade (%)", minval=0, step=0.1, group=grpP,
     tooltip="Percent of account risked if the stop is hit. Size is a simplified units estimate.")

// ─── Display ───
grpD = "Display"
lookback         = input.int(10, "Anchor bars back", minval=0, group=grpD)
extendR          = input.int(15, "Extend bars right", minval=0, group=grpD)
showZones        = input.bool(true, "Shade risk / reward zones (layered)", group=grpD)
showTable        = input.bool(true, "Show trade-plan table", group=grpD)
showContext      = input.bool(true, "Show market-context panel", group=grpD,
     tooltip="Adds ATR% · RSI · ADX · volatility class · session risk panel below Trade Plan.")
cEntry           = input.color(C_ENTRY, "Entry",  group=grpD, inline="col")
cStop            = input.color(C_STOP,  "Stop",   group=grpD, inline="col")
cTgt             = input.color(C_TGT,   "Target", group=grpD, inline="col")

// ═══════════════════════════════════════════════════════════════
// ATR (selectable smoothing)
// ═══════════════════════════════════════════════════════════════
maFn(src, len, t) =>
    switch t
        "SMA" => ta.sma(src, len)
        "EMA" => ta.ema(src, len)
        "WMA" => ta.wma(src, len)
        =>       ta.rma(src, len)
atrVal = maFn(ta.tr(true), atrLen, atrSmooth)

// ═══════════════════════════════════════════════════════════════
// LEVELS
// ═══════════════════════════════════════════════════════════════
isLong    = dir == "Long"
useManual = entryMode == "Manual Price" and manualEntry > 0
entry     = useManual ? manualEntry : close
stopDist  = atrVal * stopMult
stop      = isLong ? entry - stopDist : entry + stopDist
tp1       = isLong ? entry + stopDist * tp1R : entry - stopDist * tp1R
tp2       = isLong ? entry + stopDist * tp2R : entry - stopDist * tp2R
tp3       = isLong ? entry + stopDist * tp3R : entry - stopDist * tp3R

// Position size (simplified units estimate)
riskDollars = acctSize * riskPct / 100.0
qty         = stopDist > 0 ? math.floor(riskDollars / stopDist) : 0
notional    = qty * entry
notionalPct = acctSize > 0 ? (notional / acctSize) * 100.0 : 0.0

// ═══════════════════════════════════════════════════════════════
// MARKET CONTEXT INDICATORS
// ═══════════════════════════════════════════════════════════════
rsiVal     = ta.rsi(close, 14)
atrPct     = close > 0 ? (atrVal / close) * 100.0 : 0.0

// ADX(14) manual calc
_upMove    = ta.change(high)
_downMove  = -ta.change(low)
_plusDM    = _upMove > _downMove and _upMove > 0 ? _upMove : 0.0
_minusDM   = _downMove > _upMove and _downMove > 0 ? _downMove : 0.0
_trADX     = ta.rma(ta.tr(true), 14)
_plusDI    = 100 * ta.rma(_plusDM, 14) / (_trADX == 0 ? 1 : _trADX)
_minusDI   = 100 * ta.rma(_minusDM, 14) / (_trADX == 0 ? 1 : _trADX)
_dxSum     = _plusDI + _minusDI
_dx        = _dxSum == 0 ? 0.0 : 100 * math.abs(_plusDI - _minusDI) / _dxSum
adxVal     = ta.rma(_dx, 14)

// Volatility class · relative to 42-bar ATR average
atrAvg     = ta.sma(atrVal, 42)
volRatio   = atrAvg > 0 ? atrVal / atrAvg : 1.0
volClass   = volRatio < 0.7 ? "Low" : volRatio > 2.5 ? "Extreme" : volRatio > 1.5 ? "High" : "Normal"

// Session flag (regular vs extended)
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

// ═══════════════════════════════════════════════════════════════
// DRAWING (last-bar only to keep charts clean)
// ═══════════════════════════════════════════════════════════════
var line  lE = na, var line  lS = na, var line  lT1 = na, var line  lT2 = na, var line  lT3 = na
var label eL = na, var label sL = na, var label t1L = na, var label t2L = na, var label t3L = na
var box   zRisk = na
var box   zTP1 = na, var box   zTP2 = na, var box   zTP3 = na
var table tbl = na
var table ctx = na

if barstate.islast
    line.delete(lE), line.delete(lS), line.delete(lT1), line.delete(lT2), line.delete(lT3)
    label.delete(eL), label.delete(sL), label.delete(t1L), label.delete(t2L), label.delete(t3L)
    box.delete(zRisk), box.delete(zTP1), box.delete(zTP2), box.delete(zTP3)

    x1 = bar_index - lookback
    x2 = bar_index + extendR

    // ─── Layered zones (TP1 densest · TP3 lightest · risk = blue) ───
    if showZones
        // Risk zone (entry → stop)
        zRisk := box.new(x1, entry, x2, stop, border_color=color.new(cStop, 70), bgcolor=color.new(cStop, 88))
        // TP1 zone (entry → tp1 · densest lime)
        zTP1 := box.new(x1, entry, x2, tp1, border_color=color.new(cTgt, 70), bgcolor=color.new(cTgt, 85))
        // TP2 zone (tp1 → tp2 · mid)
        zTP2 := box.new(x1, tp1, x2, tp2, border_color=color.new(cTgt, 80), bgcolor=color.new(cTgt, 90))
        // TP3 zone (tp2 → tp3 · lightest)
        zTP3 := box.new(x1, tp2, x2, tp3, border_color=color.new(cTgt, 85), bgcolor=color.new(cTgt, 94))

    // ─── Lines ───
    lE  := line.new(x1, entry, x2, entry, xloc.bar_index, color=cEntry, width=2)
    lS  := line.new(x1, stop,  x2, stop,  xloc.bar_index, color=cStop,  width=2, style=line.style_dashed)
    lT1 := line.new(x1, tp1,   x2, tp1,   xloc.bar_index, color=color.new(cTgt, 30), width=1, style=line.style_dashed)
    lT2 := line.new(x1, tp2,   x2, tp2,   xloc.bar_index, color=cTgt,               width=2, style=line.style_dashed)
    lT3 := line.new(x1, tp3,   x2, tp3,   xloc.bar_index, color=cTgt,               width=2)

    // ─── Labels · role-based colors + R multiples ───
    eL  := label.new(x2, entry, "Entry  " + f_p(entry), xloc.bar_index,
         style=label.style_label_left, color=cEntry, textcolor=color.white, size=size.small)
    sL  := label.new(x2, stop, "Stop  " + f_p(stop) + "   ·  1R", xloc.bar_index,
         style=label.style_label_left, color=cStop, textcolor=color.white, size=size.small)
    t1L := label.new(x2, tp1, "TP1  " + f_p(tp1) + "   ·  " + str.tostring(tp1R, "#.#") + "R", xloc.bar_index,
         style=label.style_label_left, color=cTgt, textcolor=color.black, size=size.small)
    t2L := label.new(x2, tp2, "TP2  " + f_p(tp2) + "   ·  " + str.tostring(tp2R, "#.#") + "R", xloc.bar_index,
         style=label.style_label_left, color=cTgt, textcolor=color.black, size=size.small)
    t3L := label.new(x2, tp3, "TP3  " + f_p(tp3) + "   ·  " + str.tostring(tp3R, "#.#") + "R", xloc.bar_index,
         style=label.style_label_left, color=cTgt, textcolor=color.black, size=size.small)

// ═══════════════════════════════════════════════════════════════
// TRADE-PLAN TABLE (top-right)
// ═══════════════════════════════════════════════════════════════
if showTable and barstate.islast
    rows = 11
    if na(tbl)
        tbl := table.new(position.top_right, 2, rows, border_width=1, border_color=color.new(C_MUTE, 60))
    hdr = color.new(C_HEAD, 0)
    row = color.new(C_NAVY, 15)

    table.cell(tbl, 0, 0, "TRADE PLAN", text_color=C_ENTRY, text_size=size.small, bgcolor=hdr)
    table.cell(tbl, 1, 0, isLong ? "LONG" : "SHORT", text_color=isLong ? C_TGT : C_STOP, text_size=size.small, bgcolor=hdr)

    table.cell(tbl, 0, 1, "Entry",          text_color=C_MUTE,      text_size=size.small, bgcolor=row)
    table.cell(tbl, 1, 1, f_p(entry),       text_color=C_ENTRY,     text_size=size.small, bgcolor=row)

    table.cell(tbl, 0, 2, "Stop (1R)",      text_color=C_MUTE,      text_size=size.small, bgcolor=row)
    table.cell(tbl, 1, 2, f_p(stop),        text_color=C_STOP,      text_size=size.small, bgcolor=row)

    table.cell(tbl, 0, 3, "TP1 (" + str.tostring(tp1R, "#.#") + "R)", text_color=C_MUTE, text_size=size.small, bgcolor=row)
    table.cell(tbl, 1, 3, f_p(tp1),         text_color=C_TGT,       text_size=size.small, bgcolor=row)

    table.cell(tbl, 0, 4, "TP2 (" + str.tostring(tp2R, "#.#") + "R)", text_color=C_MUTE, text_size=size.small, bgcolor=row)
    table.cell(tbl, 1, 4, f_p(tp2),         text_color=C_TGT,       text_size=size.small, bgcolor=row)

    table.cell(tbl, 0, 5, "TP3 (" + str.tostring(tp3R, "#.#") + "R)", text_color=C_MUTE, text_size=size.small, bgcolor=row)
    table.cell(tbl, 1, 5, f_p(tp3),         text_color=C_TGT,       text_size=size.small, bgcolor=row)

    table.cell(tbl, 0, 6, "ATR(" + str.tostring(atrLen) + ")", text_color=C_MUTE, text_size=size.small, bgcolor=row)
    table.cell(tbl, 1, 6, f_p(atrVal),      text_color=color.white, text_size=size.small, bgcolor=row)

    table.cell(tbl, 0, 7, "Stop distance",  text_color=C_MUTE,      text_size=size.small, bgcolor=row)
    table.cell(tbl, 1, 7, f_p(stopDist),    text_color=color.white, text_size=size.small, bgcolor=row)

    table.cell(tbl, 0, 8, "Risk $",         text_color=C_MUTE,      text_size=size.small, bgcolor=row)
    table.cell(tbl, 1, 8, f_d(riskDollars, 2), text_color=C_STOP,   text_size=size.small, bgcolor=row)

    table.cell(tbl, 0, 9, "Size (units)",   text_color=C_MUTE,      text_size=size.small, bgcolor=row)
    table.cell(tbl, 1, 9, showSize ? str.tostring(qty) : "—", text_color=color.white, text_size=size.small, bgcolor=row)

    table.cell(tbl, 0, 10, "Notional / Acct", text_color=C_MUTE,    text_size=size.small, bgcolor=row)
    table.cell(tbl, 1, 10, f_d(notionalPct, 1) + "%", text_color=color.white, text_size=size.small, bgcolor=row)

// ═══════════════════════════════════════════════════════════════
// MARKET-CONTEXT TABLE (middle-right · below Trade Plan)
// ═══════════════════════════════════════════════════════════════
if showContext and barstate.islast
    ctxRows = 6
    if na(ctx)
        ctx := table.new(position.middle_right, 2, ctxRows, border_width=1, border_color=color.new(C_MUTE, 60))
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

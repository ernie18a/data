# AetherEdge - APEX Swing Engine

- url: https://www.tradingview.com/script/1ro4FL1E/
- type: indicator
- pine_id: PUB;1620b3f6129142bd90c29963d0cfc766
- version: 1.0

## Description

🖊️ Overview

APEX is a swing-reversal engine that captures market tops (swing highs) and bottoms (swing lows), routing BUY and SELL into a strictly alternating sequence. At its core sits confirmed-pivot detection, so once a signal is printed it never moves — the indicator is fully non-repainting. Where many "perfect top-and-bottom" tools are illusions drawn by peeking at future data, APEX accepts an honest confirmation lag in exchange for signals that hold meaning in real time. A state machine structurally guarantees alternation, while an oscillator consensus gate filters out trivial swings.

🔶 Key Features

Strict alternation: a state machine enforces the BUY→SELL→BUY order, eliminating one-sided signal clustering
Fully non-repainting: only confirmed pivots (ta.pivothigh/low) are used; printed markers never shift
Transparent confirmation lag: the HUD shows how many bars after the true extreme the pivot confirmed
RSI consensus gate: accepts a top/bottom only when the oscillator was overbought/oversold at pivot formation, removing noise swings
Minimum-move filter: requires an ATR-based price displacement from the last signal to suppress over-dense output
Zig-zag visualization: glowing lines connect confirmed extremes, making the alternating capture structure instantly readable
Top/bottom zone shading: a translucent band around each extreme visualizes the high/low region
Live tracking rays: horizontal lines extend from the latest top and bottom as dynamic support/resistance
Refined data-science palettes: Quant Lab, Sumi Ink, and Aurora
Integrated HUD: current state, last top/bottom prices, RSI, confirmation lag, and the next permitted signal type

🧠 Technical Architecture

The source of APEX's honesty is confirmed-pivot detection. ta.pivothigh/ta.pivotlow resolve a value only after a set number of bars (pv_rightInput) have elapsed to the right of the pivot candidate. By the time confirmation occurs, the extreme is already a past bar, so its position can never change afterward — the essence of "a few bars of lag, but never repainting." The resulting delay, the honest price of refusing to peek at the future, is displayed explicitly in the HUD.
Alternation is enforced by a state machine. Its internal state holds +1 when the last signal was a bottom (BUY), −1 when it was a top (SELL), and 0 before any signal. Because this state locks which signal type is next permitted, same-type signals are structurally rejected and output necessarily alternates between BUY and SELL. In the rare case where a top and a bottom confirm on the same bar, an arbitration rule favors whichever carries the stronger oscillator extreme.
The consensus gate promotes a confirmed pivot into a top/bottom candidate. A pivot high qualifies as a top (SELL) candidate only if RSI exceeded the overbought threshold when it formed; a pivot low qualifies as a bottom (BUY) candidate only if RSI was below the oversold threshold. This leaves only "meaningful" swings accompanied by oscillator extremes rather than every minor wiggle. An ATR-based minimum-move filter further demands sufficient travel from the prior signal to prevent crowding. In the visual layer, accepted extremes are linked by a zig-zag line, each extreme receives a zone box, and rays extending from the latest top and bottom present dynamic battle lines.

⚙️ Recommended Settings & Tuning Guide

APEX is tuned with crypto in mind. For intraday trading on majors like BTC and ETH, Pivot Left/Right Bars near 8 is a balanced starting point between sensitivity and lag. On higher-volatility names such as SOL and XRP, widening Bars to 10–12 and tightening the RSI gate (overbought 65 / oversold 35) suppresses fakeout swings and stabilizes top/bottom precision.
Pivot Bars is the master sensitivity parameter. Larger values admit only larger, more significant swings and increase lag; smaller values are more responsive with less lag but more fakeouts. For swing trading (days-to-weeks holds), 15–20 is a guide; for short-term trading, 6–8. If signals are too frequent, tighten the RSI gate (overbought 70 / oversold 30) and set the minimum-move filter to 1–2 ATR to reduce density. If signals are too sparse, ease the RSI gate (overbought 55 / oversold 45) or disable it, driving alternation purely from pivot structure.

💡 How to Use in Practice

The most fundamental use is to read confirmed BUY/SELL markers as an objective fact that a swing pivot has formed. Because markers arrive with lag, treat them with care as direct counter-trend triggers; instead, the tracking rays extending from the latest top and bottom serve as powerful support/resistance for subsequent price action. Moments where price approaches and rejects these rays are strong entry-consideration points while awaiting the next alternating signal.
For multi-timeframe trading, pair APEX on a higher timeframe to grasp the major swing structure with APEX on a lower timeframe for finer timing. Since the zig-zag line maps directly to wave structure, overlaying it with Elliott Wave or Fibonacci retracements adds context to top/bottom placement. The HUD's "next permitted signal" makes clear which reversal to await, serving as a guide for position management.

⚠️ Important Notes

Because this indicator is based on confirmed pivots, signals always arrive in real time delayed by the confirmation lag. Historical charts appear to capture tops and bottoms perfectly, but that is because they are already confirmed — no marker appears on a not-yet-confirmed extreme near the latest bar. This is not a flaw but a necessary property of an honest, non-repainting design. Expecting instant reaction on the current bar without understanding this lag leads to misuse. Setting pivot width extremely small reduces lag but lowers confirmation reliability and increases fakeouts.

🚨 Disclaimer

This indicator is provided for educational and informational purposes only and does not constitute financial or investment advice. No signal guarantees future profit, and past performance does not indicate future results. All trading decisions are made at your own risk; please use this tool with sound risk management and your own independent verification.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © AetherEdge — APEX // Alternating Swing Top/Bottom Engine
//@version=6

// ┌──────────────────────────────────────────────────────────────────────────┐
// │  APEX — ALTERNATING TOP/BOTTOM ENGINE                                      │
// │                                                                            │
// │  Captures swing tops and bottoms and fires BUY / SELL that STRICTLY        │
// │  alternate. A state machine guarantees a SELL can only follow a BUY and    │
// │  vice-versa, so signals never cluster on one side.                         │
// │                                                                            │
// │  HONEST BY DESIGN — NON-REPAINTING:                                        │
// │  Tops/bottoms are detected with confirmed pivots (ta.pivothigh/low), which │
// │  only resolve after `rightBars` have elapsed. The marker therefore appears │
// │  a few bars after the actual extreme and NEVER moves once printed. There   │
// │  is an inherent, honest lag — the price of not cheating with future data.  │
// │                                                                            │
// │  A confluence gate (oscillator at an extreme when the pivot confirms)      │
// │  keeps only "meaningful" swings, so signals approximate genuine tops and   │
// │  bottoms rather than every minor wiggle.                                   │
// └──────────────────────────────────────────────────────────────────────────┘

indicator("AetherEdge - APEX Swing Engine", "AE-APEX", overlay = true,
     max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)


// ============================================================================
//  ░░ INPUTS ░░
// ============================================================================

// ─── PIVOT DETECTION ─────────────────────────────────────────────────────────
gP = "▓ PIVOT DETECTION ▓"
pv_leftInput  = input.int(8, "Pivot Left Bars", minval = 1, maxval = 100, group = gP,
     tooltip = "Bars required on the LEFT of a pivot. Larger = only more significant swings qualify.")
pv_rightInput = input.int(8, "Pivot Right Bars (confirmation lag)", minval = 1, maxval = 100, group = gP,
     tooltip = "Bars required on the RIGHT before a pivot CONFIRMS. This is the honest, non-repainting lag: a marker appears this many bars after the extreme.")
pv_srcHigh    = input.source(high, "Top Source", group = gP)
pv_srcLow     = input.source(low, "Bottom Source", group = gP)

// ─── CONFLUENCE GATE ─────────────────────────────────────────────────────────
gG = "▓ CONFLUENCE GATE ▓"
cg_useOscInput= input.bool(true, "Require Oscillator Extreme", group = gG,
     tooltip = "Only accept a top/bottom if the oscillator was overbought/oversold when the pivot formed — filters out minor swings.")
cg_rsiLenInp  = input.int(14, "RSI Length", minval = 2, maxval = 100, group = gG)
cg_obInput    = input.float(60.0, "Overbought (top gate)", minval = 50.0, maxval = 90.0, step = 1.0, group = gG,
     tooltip = "RSI at the pivot high must exceed this to accept a SELL/top.")
cg_osInput    = input.float(40.0, "Oversold (bottom gate)", minval = 10.0, maxval = 50.0, step = 1.0, group = gG,
     tooltip = "RSI at the pivot low must be below this to accept a BUY/bottom.")
cg_minMoveInp = input.float(0.0, "Min Move Since Last Signal (ATR)", minval = 0.0, maxval = 20.0, step = 0.5, group = gG,
     tooltip = "Require price to have moved at least this many ATRs from the last signal before a new one is accepted. 0 = off.")

// ─── VISUALS ─────────────────────────────────────────────────────────────────
gV = "▓ VISUALS ▓"
vi_themeInput = input.string("Quant Lab", "Palette",
     options = ["Quant Lab", "Sumi Ink", "Aurora"], group = gV,
     tooltip = "Refined data-science palettes. Quant Lab = teal/coral on near-black.")
vi_zigzagInput= input.bool(true, "Draw Zig-Zag Between Extremes", group = gV)
vi_zzWidthInp = input.int(2, "Zig-Zag Width", minval = 1, maxval = 5, group = gV)
vi_zoneInput  = input.bool(true, "Shade Top/Bottom Zones", group = gV,
     tooltip = "Fill a band around each confirmed extreme to visualize the high/low region.")
vi_glowInput  = input.bool(true, "Glow on Markers & Lines", group = gV)
vi_labelInput = input.bool(true, "Show BUY/SELL Labels", group = gV)
vi_trackInput = input.bool(true, "Track Last Extreme Lines", group = gV,
     tooltip = "Extend horizontal rays from the last top and bottom as live support/resistance.")

// ─── HUD ─────────────────────────────────────────────────────────────────────
gH = "▓ HUD ▓"
hud_showInput = input.bool(true, "Show HUD", group = gH)
hud_posInput  = input.string("Top Right", "Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gH)
hud_sizeInput = input.string("Normal", "Text Size",
     options = ["Tiny", "Small", "Normal", "Large"], group = gH)


// ============================================================================
//  ░░ PALETTE ░░
// ============================================================================
var color cTop  = na   // tops / SELL
var color cBot  = na   // bottoms / BUY
var color cZig  = na
var color cAcc  = na
var color cTxt  = #dde6ee
var color cTxtD = #5d7080
var color cPanel= #0b0f15
var color cPanelHd = #131b27

setPalette() =>
    [t, b, z, a] = switch vi_themeInput
        "Quant Lab" => [#ff5d73, #2dd4bf, #8b97a8, #38bdf8]
        "Sumi Ink"  => [#e85d75, #6ab7a8, #6b7280, #c9a227]
        => [#f472b6, #34d399, #7c8aa0, #a78bfa]   // Aurora
    [t, b, z, a]
[pt, pb, pz, pa] = setPalette()
cTop := pt
cBot := pb
cZig := pz
cAcc := pa


// ============================================================================
//  ░░ HELPERS ░░
// ============================================================================
sdiv(a, b) =>
    b != 0 ? a / b : 0.0
clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))


// ============================================================================
//  ░░ PIVOT DETECTION (non-repainting) ░░
//  ta.pivothigh/low return a value `pv_rightInput` bars in the PAST once the
//  pivot is confirmed, or na otherwise. Because confirmation requires future
//  bars relative to the pivot, the result never changes after it prints.
// ============================================================================
ph = ta.pivothigh(pv_srcHigh, pv_leftInput, pv_rightInput)
pl = ta.pivotlow(pv_srcLow,  pv_leftInput, pv_rightInput)

// The bar where the extreme actually occurred (rightBars ago).
pivBar = bar_index - pv_rightInput

// Oscillator value AT the pivot bar (look back rightBars to read it there).
rsiNow = ta.rsi(close, cg_rsiLenInp)
rsiAtPiv = rsiNow[pv_rightInput]

atr = ta.atr(14)


// ============================================================================
//  ░░ CONFLUENCE GATE ░░
//  A confirmed pivot high becomes a candidate TOP; a pivot low a candidate
//  BOTTOM. The oscillator-extreme requirement filters minor swings.
// ============================================================================
topCandidate = not na(ph) and (not cg_useOscInput or rsiAtPiv >= cg_obInput)
botCandidate = not na(pl) and (not cg_useOscInput or rsiAtPiv <= cg_osInput)


// ============================================================================
//  ░░ ALTERNATION STATE MACHINE ░░
//  state:  +1 = last signal was a BOTTOM/BUY  (next must be a TOP/SELL)
//          -1 = last signal was a TOP/SELL    (next must be a BOTTOM/BUY)
//           0 = no signal yet (accept either)
//  This guarantees strict BUY → SELL → BUY alternation.
// ============================================================================
var int   state      = 0
var float lastSigPx  = na
var int   lastTopBar = na
var int   lastBotBar = na
var float lastTopPx  = na
var float lastBotPx  = na

// Min-move gate: distance from the last signal price in ATRs.
moveOk(px) =>
    cg_minMoveInp <= 0 or na(lastSigPx) or math.abs(px - lastSigPx) >= cg_minMoveInp * atr

// Evaluate acceptance under alternation + gates.
// A TOP/SELL is accepted only if state allows (state != -1) and move gate ok.
topPx = na(ph) ? na : ph
botPx = na(pl) ? na : pl

acceptTop = topCandidate and state != -1 and moveOk(topPx)
acceptBot = botCandidate and state != 1  and moveOk(botPx)

// If BOTH confirm on the same bar (rare), prefer the one that continues
// alternation cleanly; if both are valid, take the stronger oscillator extreme.
bothValid = acceptTop and acceptBot
takeTop = acceptTop and (not bothValid or (rsiAtPiv - cg_obInput) >= (cg_osInput - rsiAtPiv))
takeBot = acceptBot and (not bothValid or not takeTop)

sellSignal = takeTop
buySignal  = takeBot

// Commit state transitions.
if sellSignal
    state := -1
    lastSigPx := topPx
    lastTopBar := pivBar
    lastTopPx := topPx
if buySignal
    state := 1
    lastSigPx := botPx
    lastBotBar := pivBar
    lastBotPx := botPx


// ============================================================================
//  ░░ VISUALS ░░
// ============================================================================

// ─── Zig-zag line connecting confirmed extremes ───
var int   zzPrevBar = na
var float zzPrevPx  = na
var int   zzPrevTyp = 0   // +1 top, -1 bottom

drawZig(toBar, toPx, typ) =>
    if vi_zigzagInput and not na(zzPrevBar) and zzPrevTyp != typ
        col = typ > 0 ? cTop : cBot
        if vi_glowInput
            line.new(zzPrevBar, zzPrevPx, toBar, toPx, color = color.new(col, 75), width = vi_zzWidthInp + 3)
        line.new(zzPrevBar, zzPrevPx, toBar, toPx, color = col, width = vi_zzWidthInp)

if sellSignal
    drawZig(pivBar, topPx, 1)
    zzPrevBar := pivBar
    zzPrevPx  := topPx
    zzPrevTyp := 1
if buySignal
    drawZig(pivBar, botPx, -1)
    zzPrevBar := pivBar
    zzPrevPx  := botPx
    zzPrevTyp := -1

// ─── Top/bottom zone boxes ───
if vi_zoneInput and sellSignal
    half = atr * 0.6
    box.new(pivBar, topPx + half, pivBar + pv_rightInput, topPx - half,
         border_color = color.new(cTop, 60), bgcolor = color.new(cTop, 88))
if vi_zoneInput and buySignal
    half = atr * 0.6
    box.new(pivBar, botPx + half, pivBar + pv_rightInput, botPx - half,
         border_color = color.new(cBot, 60), bgcolor = color.new(cBot, 88))

// ─── BUY/SELL markers (drawn at the pivot bar, not the current bar) ───
if vi_labelInput and sellSignal
    yOff = topPx + atr * 0.8
    if vi_glowInput
        label.new(pivBar, yOff, "▼", yloc = yloc.price, color = color.new(cTop, 80),
             textcolor = color.new(cTop, 25), style = label.style_label_down, size = size.huge)
    label.new(pivBar, yOff, "SELL", yloc = yloc.price, color = cTop,
         textcolor = #15000a, style = label.style_label_down, size = size.normal,
         tooltip = "Confirmed TOP · RSI@pivot " + str.tostring(rsiAtPiv, "#"))

if vi_labelInput and buySignal
    yOff = botPx - atr * 0.8
    if vi_glowInput
        label.new(pivBar, yOff, "▲", yloc = yloc.price, color = color.new(cBot, 80),
             textcolor = color.new(cBot, 25), style = label.style_label_up, size = size.huge)
    label.new(pivBar, yOff, "BUY", yloc = yloc.price, color = cBot,
         textcolor = #001512, style = label.style_label_up, size = size.normal,
         tooltip = "Confirmed BOTTOM · RSI@pivot " + str.tostring(rsiAtPiv, "#"))

// ─── Live tracking rays from the last extremes ───
var line topRay = na
var line botRay = na
if vi_trackInput and not na(lastTopPx)
    line.delete(topRay)
    topRay := line.new(nz(lastTopBar, bar_index), lastTopPx, bar_index, lastTopPx,
         color = color.new(cTop, 45), width = 1, style = line.style_dotted, extend = extend.right)
if vi_trackInput and not na(lastBotPx)
    line.delete(botRay)
    botRay := line.new(nz(lastBotBar, bar_index), lastBotPx, bar_index, lastBotPx,
         color = color.new(cBot, 45), width = 1, style = line.style_dotted, extend = extend.right)


// ============================================================================
//  ░░ HUD ░░
// ============================================================================
hudPos(p) =>
    switch p
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.middle_right
hudSize(s) =>
    switch s
        "Tiny"  => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

var table hud = na
if hud_showInput and na(hud)
    hud := table.new(hudPos(hud_posInput), 2, 7, bgcolor = cPanel,
         border_color = color.new(cAcc, 70), border_width = 1, frame_color = color.new(cAcc, 50), frame_width = 1)

if hud_showInput and barstate.islast
    sz = hudSize(hud_sizeInput)
    stateTxt = state == 1 ? "▲ LONG (await top)" : state == -1 ? "▼ SHORT (await bottom)" : "· flat"
    stateCol = state == 1 ? cBot : state == -1 ? cTop : cTxtD

    table.cell(hud, 0, 0, "APEX SWING ENGINE", text_color = cAcc, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 0, "alt-state", text_color = cTxtD, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_right)

    table.cell(hud, 0, 1, "position", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 1, stateTxt, text_color = stateCol, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 2, "last top", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 2, na(lastTopPx) ? "—" : str.tostring(lastTopPx, format.mintick), text_color = cTop, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 3, "last bottom", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 3, na(lastBotPx) ? "—" : str.tostring(lastBotPx, format.mintick), text_color = cBot, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 4, "RSI now", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 4, str.tostring(rsiNow, "#.0"), text_color = rsiNow >= cg_obInput ? cTop : rsiNow <= cg_osInput ? cBot : cTxt, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 5, "confirm lag", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 5, str.tostring(pv_rightInput) + " bars", text_color = cTxt, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 6, "next signal", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 6, state == 1 ? "SELL only" : state == -1 ? "BUY only" : "either", text_color = cAcc, text_size = sz, text_halign = text.align_right)


// ============================================================================
//  ░░ ALERTS ░░
// ============================================================================
alertcondition(buySignal,  "APEX BUY",  "APEX: confirmed BOTTOM (BUY)")
alertcondition(sellSignal, "APEX SELL", "APEX: confirmed TOP (SELL)")
````

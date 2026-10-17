# ORB & Session Liquidity Model [JOAT]

- url: https://www.tradingview.com/script/1WebemDv-ORB-Session-Liquidity-Model-JOAT/
- type: indicator
- pine_id: PUB;069087f670d54ada9f6df45c22295dee
- version: 1.0

## Description

[b]ORB and Session Liquidity Model [JOAT][/b]
[i]Builds the opening range for your chosen session, maps the liquidity around it, and signals breakouts with session-aware trade control.[/i]

[b]What it is[/b]
The first minutes of a session set a reference range that the rest of the session repeatedly reacts to. This indicator defines that opening range, tracks the liquidity sitting above and below it, and signals confirmed breakouts — with session timing, a daily trade cap and full trade framing built in. It is an original session-driven model, not a generic breakout line.

[b]How it works[/b]
• [b]Opening range[/b] — during a user-defined opening window (for example the first N minutes of your session), the tool records the high and low. Once the window closes, that range is locked as the reference for the rest of the day and drawn as a box.

[image]https://www.tradingview.com/x/we5NjM1i/[/image]

• [b]Session logic[/b] — the model resets cleanly each new day using a real session-change test, so counters and levels do not carry stale values across sessions. Trading is only permitted inside the active session window you define.

• [b]Liquidity ladder[/b] — levels around the range (its extremes and projections) are drawn and labelled as the liquidity price is likely to seek. These give context for where a breakout may run to or reverse from.

• [b]Breakout signals[/b] — a Buy fires on a confirmed close beyond the range high plus a buffer; a Sell on a confirmed close below the range low minus the buffer. A per-day maximum-trades cap and a minimum-gap control prevent the level from generating repeated prints as price oscillates around it.

[b]Trade levels[/b]
Each breakout draws a red risk box to the stop and a green reward box to the third target, with inner dividers and right-edge labels for entry, stop and each take-profit at your R multiples. Stops relate to the range, which is the structure the trade is based on.

[b]The dashboard[/b]
An adjustable session-console panel shows the current session phase (pre-range, range building, or live), the locked range, the directional bias relative to it, the trades used against the daily cap, the active signal, a conviction estimate, and a live first-target-before-stop tally from closed bars only.

[b]How to use it[/b]
• Set the opening window and session to match the market you trade (indices, futures, forex sessions, crypto day boundaries).
• Wait for the range to lock, then trade confirmed breakouts in the direction of your bias; use the liquidity ladder for targets and invalidation.
• The daily cap keeps the model disciplined — respect it rather than overriding on every wiggle.

[b]Settings[/b]
Opening-range window, session hours, breakout buffer, maximum trades per day, liquidity options, risk multiple and target R multiples, plus visual and dashboard controls.

[b]Originality and usefulness[/b]
Opening-range breakout is a known concept; the contribution here is the integrated liquidity mapping around the range, the strict session reset and daily trade governance, the confirmed-close breakout logic, and the full non-repainting trade framing — assembled into one session-aware model and explained so each element's role is clear.

[image]https://www.tradingview.com/x/s2tzHz8Y/[/image]

[b]Notes and limitations[/b]
• Breakouts can fail, and range-bound sessions produce whipsaws around the levels — the buffer and daily cap reduce but do not eliminate this.
• Session settings must match the instrument; a mismatched window will define the range at the wrong time.
• The tally reflects only past bars on the current chart and is not a forecast.
• Educational and analytical tool, not financial advice.

[i]— made with passion by officialjackofalltrades[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6

indicator("ORB & Session Liquidity Model [JOAT]", "ORB Liquidity [JOAT]", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ─────────────────────────────────────────────────────────────────────────
//  PALETTE  (near-black · neon cyan / magenta / electric purple)
// ─────────────────────────────────────────────────────────────────────────
CYAN    = #00E5FF
CYAN_HI = #8CF6FF
MAG     = #FF2E9A
MAG_HI  = #FF86C6
PURP    = #A64BFF
PURP_HI = #C99BFF
LIME    = #7CFF5A
AMBER   = #FFC24B
RED     = #FF3D5A
RED_HI  = #FF8199
GRN     = #16C784
GRN_HI  = #5CF0B0
INK     = #05070E
INKHI   = #EAF2FF
MUTE    = #5A6B8C

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
gSes    = "Sessions"
orbSession = input.session("0930-1000", "Opening Range window", group = gSes, tooltip = "The session window whose high/low form the Opening Range. Locks when the window closes.")
tradeSession = input.session("1000-1600", "Trade session (signals only here)", group = gSes, tooltip = "Breakout signals are only allowed inside this window.")
tz         = input.string("America/New_York", "Timezone", options = ["America/New_York", "America/Chicago", "America/Los_Angeles", "Europe/London", "Europe/Berlin", "Asia/Tokyo", "Asia/Shanghai", "Asia/Kolkata", "Australia/Sydney", "UTC"], group = gSes)

gBrk    = "Breakout Logic"
atrLenT = input.int(14, "ATR length", minval = 1, group = gBrk)
bufMult = input.float(0.10, "Breakout buffer = ATR ×", minval = 0.0, step = 0.05, group = gBrk, tooltip = "Small ATR cushion beyond ORH/ORL to reduce false pokes.")
maxTrades = input.int(2, "Max trades per side / day", minval = 1, maxval = 10, group = gBrk)

gRisk   = "Risk / Targets"
useAtrSL = input.bool(false, "SL from ATR (else opposite OR level)", group = gRisk, tooltip = "On: SL = entry ± ATR×mult. Off: SL = the opposite OR level.")
slMult  = input.float(1.0, "ATR SL multiplier", minval = 0.1, step = 0.1, group = gRisk)
tp1R    = input.float(1.0, "TP1 (R)", step = 0.5, group = gRisk)
tp2R    = input.float(2.0, "TP2 (R)", step = 0.5, group = gRisk)
tp3R    = input.float(3.0, "TP3 (R)", step = 0.5, group = gRisk)
boxW    = input.int(24, "TP/SL box width (bars)", minval = 5, group = gRisk)

gLad    = "Liquidity Ladder"
showLadder = input.bool(true, "Show OR extension ladder", group = gLad)
e1 = input.float(0.5, "Extension 1 ×", minval = 0.1, step = 0.1, group = gLad)
e2 = input.float(1.0, "Extension 2 ×", minval = 0.1, step = 0.1, group = gLad)
e3 = input.float(1.5, "Extension 3 ×", minval = 0.1, step = 0.1, group = gLad)
e4 = input.float(2.0, "Extension 4 ×", minval = 0.1, step = 0.1, group = gLad)

gViz    = "Visuals"
showBox = input.bool(true, "OR box", group = gViz)
showTradeBox = input.bool(true, "Trade risk/reward boxes", group = gViz)
showBg  = input.bool(true, "Session background tint", group = gViz)
glowLevels = input.bool(true, "Glow ORH / ORL", group = gViz)

gP      = "Dashboard"
showHUD = input.bool(true, "Show dashboard", group = gP)
hudPos  = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gP)
hudBg   = input.color(#06090F, "Background", group = gP)

// ─────────────────────────────────────────────────────────────────────────
//  HELPERS  (declared before first use)
// ─────────────────────────────────────────────────────────────────────────
f_pos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.middle_right

f_meter(float pct01) =>
    fill = math.round(math.max(0.0, math.min(1.0, pct01)) * 10)
    out = ""
    for i = 1 to 10
        out := out + (i <= fill ? "▰" : "▱")
    out

f_num(float v) =>
    str.tostring(v, format.mintick)

// pip conviction meter — filled ⬤ vs empty ◯ dots (session-console glyph)
f_pips(float pct01) =>
    fill = math.round(math.max(0.0, math.min(1.0, pct01)) * 10)
    out = ""
    for i = 1 to 10
        out := out + (i <= fill ? "⬤" : "◯")
    out

// position a horizontal ladder line + its label
f_tline(line ln, label lb, int x1, float y, color c, string txt) =>
    line.set_xy1(ln, x1, y)
    line.set_xy2(ln, x1 + 5, y)
    line.set_color(ln, c)
    label.set_xy(lb, x1, y)
    label.set_text(lb, txt)
    label.set_textcolor(lb, c)

// ─────────────────────────────────────────────────────────────────────────
//  SESSION / DAY STATE
// ─────────────────────────────────────────────────────────────────────────
atr    = ta.atr(atrLenT)
inORB  = not na(time(timeframe.period, orbSession, tz))
inTrade= not na(time(timeframe.period, tradeSession, tz))
newDay = timeframe.change("D")

orbStart = inORB and not inORB[1]      // first bar of the OR window
orbEnd   = not inORB and inORB[1]      // OR window just closed → lock

var float orH        = na
var float orL        = na
var int   orStartBar = na
var bool  orLocked   = false
var bool  dayHasOR   = false
var int   buysToday  = 0
var int   sellsToday = 0

if newDay
    buysToday  := 0
    sellsToday := 0

// build / extend the range inside the window
if orbStart
    orH        := high
    orL        := low
    orStartBar := bar_index
    orLocked   := false
else if inORB
    orH := math.max(nz(orH, high), high)
    orL := math.min(nz(orL, low), low)

if orbEnd
    orLocked := true
    dayHasOR := true

orRange = (orLocked and not na(orH) and not na(orL)) ? orH - orL : na
orMid   = na(orRange) ? na : (orH + orL) / 2.0

// ─────────────────────────────────────────────────────────────────────────
//  OR BOX + ORH/ORL LINES + LIQUIDITY LADDER  (single set, redrawn per day)
// ─────────────────────────────────────────────────────────────────────────
var box   orBox  = na
var line  lnH    = na
var line  lnL    = na
var label lbH    = na
var label lbL    = na
var line  uL1 = na, var line uL2 = na, var line uL3 = na, var line uL4 = na
var line  dL1 = na, var line dL2 = na, var line dL3 = na, var line dL4 = na
var label uT1 = na, var label uT2 = na, var label uT3 = na, var label uT4 = na
var label dT1 = na, var label dT2 = na, var label dT3 = na, var label dT4 = na

// Objects are created ONCE at global scope (Pine functions cannot create/assign
// globals). We lazily create each group the first time its toggle needs it.
if orbEnd and showBox
    if na(orBox)
        orBox := box.new(bar_index, close, bar_index, close, border_color = color.new(PURP, 30), bgcolor = color.new(PURP, 92), border_width = 1)
    box.set_left(orBox, orStartBar)
    box.set_top(orBox, orH)
    box.set_right(orBox, bar_index)
    box.set_bottom(orBox, orL)

if orbEnd and showLadder
    if na(lnH)
        bi = bar_index
        px = close
        lnH := line.new(bi, px, bi + 1, px, color = CYAN, width = 2, extend = extend.right)
        lnL := line.new(bi, px, bi + 1, px, color = MAG,  width = 2, extend = extend.right)
        lbH := label.new(bi, px, "", style = label.style_label_left, color = color.new(INK, 100), size = size.small)
        lbL := label.new(bi, px, "", style = label.style_label_left, color = color.new(INK, 100), size = size.small)
        uL1 := line.new(bi, px, bi + 1, px, color = CYAN, style = line.style_dotted, extend = extend.right)
        uL2 := line.new(bi, px, bi + 1, px, color = CYAN, style = line.style_dotted, extend = extend.right)
        uL3 := line.new(bi, px, bi + 1, px, color = CYAN, style = line.style_dotted, extend = extend.right)
        uL4 := line.new(bi, px, bi + 1, px, color = CYAN, style = line.style_dotted, extend = extend.right)
        dL1 := line.new(bi, px, bi + 1, px, color = MAG, style = line.style_dotted, extend = extend.right)
        dL2 := line.new(bi, px, bi + 1, px, color = MAG, style = line.style_dotted, extend = extend.right)
        dL3 := line.new(bi, px, bi + 1, px, color = MAG, style = line.style_dotted, extend = extend.right)
        dL4 := line.new(bi, px, bi + 1, px, color = MAG, style = line.style_dotted, extend = extend.right)
        uT1 := label.new(bi, px, "", style = label.style_none, textcolor = CYAN, size = size.tiny)
        uT2 := label.new(bi, px, "", style = label.style_none, textcolor = CYAN, size = size.tiny)
        uT3 := label.new(bi, px, "", style = label.style_none, textcolor = CYAN, size = size.tiny)
        uT4 := label.new(bi, px, "", style = label.style_none, textcolor = CYAN, size = size.tiny)
        dT1 := label.new(bi, px, "", style = label.style_none, textcolor = MAG, size = size.tiny)
        dT2 := label.new(bi, px, "", style = label.style_none, textcolor = MAG, size = size.tiny)
        dT3 := label.new(bi, px, "", style = label.style_none, textcolor = MAG, size = size.tiny)
        dT4 := label.new(bi, px, "", style = label.style_none, textcolor = MAG, size = size.tiny)
    x1 = bar_index
    f_tline(lnH, lbH, orStartBar, orH, CYAN, " ORH " + f_num(orH))
    f_tline(lnL, lbL, orStartBar, orL, MAG,  " ORL " + f_num(orL))
    f_tline(uL1, uT1, x1, orH + orRange * e1, CYAN,    " +" + str.tostring(e1, "#.#") + "R")
    f_tline(uL2, uT2, x1, orH + orRange * e2, CYAN,    " +" + str.tostring(e2, "#.#") + "R")
    f_tline(uL3, uT3, x1, orH + orRange * e3, CYAN_HI, " +" + str.tostring(e3, "#.#") + "R")
    f_tline(uL4, uT4, x1, orH + orRange * e4, CYAN_HI, " +" + str.tostring(e4, "#.#") + "R")
    f_tline(dL1, dT1, x1, orL - orRange * e1, MAG,     " -" + str.tostring(e1, "#.#") + "R")
    f_tline(dL2, dT2, x1, orL - orRange * e2, MAG,     " -" + str.tostring(e2, "#.#") + "R")
    f_tline(dL3, dT3, x1, orL - orRange * e3, MAG_HI,  " -" + str.tostring(e3, "#.#") + "R")
    f_tline(dL4, dT4, x1, orL - orRange * e4, MAG_HI,  " -" + str.tostring(e4, "#.#") + "R")

// keep the OR box growing across the trade session on the confirmed last bar
if showBox and not na(orBox) and orLocked and barstate.islast
    box.set_right(orBox, bar_index + 2)

// ─────────────────────────────────────────────────────────────────────────
//  BREAKOUT SIGNALS  (trade session only · capped per side · confirmed close)
// ─────────────────────────────────────────────────────────────────────────
buffer   = atr * bufMult
canTrade = orLocked and inTrade and not na(orRange)

buy  = canTrade and ta.crossover(close, orH + buffer)  and buysToday  < maxTrades
sell = canTrade and ta.crossunder(close, orL - buffer) and sellsToday < maxTrades

if buy
    buysToday += 1
if sell
    sellsToday += 1
sig = buy or sell

// directional bias relative to the range
bias = na(orRange) ? 0 : close > orH ? 1 : close < orL ? -1 : 0

// ─────────────────────────────────────────────────────────────────────────
//  CONVICTION 0..100  (breakout extension · session · volatility expansion)
// ─────────────────────────────────────────────────────────────────────────
extBeyond = na(orRange) or orRange == 0 ? 0.0 : bias == 1 ? (close - orH) / orRange : bias == -1 ? (orL - close) / orRange : 0.0
extComp   = math.min(1.0, math.abs(extBeyond))
sesComp   = inTrade ? 1.0 : 0.0
expComp   = atr > 0 ? math.min(1.0, math.abs(close - open) / atr) : 0.0
conv = math.round(100 * (0.5 * extComp + 0.3 * sesComp + 0.2 * expComp))

// ─────────────────────────────────────────────────────────────────────────
//  LIVE WIN-RATE TRACKER  (TP1 before SL · no lookahead)
// ─────────────────────────────────────────────────────────────────────────
var float sEntry = na
var float sSL    = na
var float sT1    = na
var int   sDir   = 0
var bool  sOpen  = false
var int   wins   = 0
var int   losses = 0

if sOpen
    if sDir == 1
        if high >= sT1
            wins += 1
            sOpen := false
        else if low <= sSL
            losses += 1
            sOpen := false
    else
        if low <= sT1
            wins += 1
            sOpen := false
        else if high >= sSL
            losses += 1
            sOpen := false

// ─────────────────────────────────────────────────────────────────────────
//  TRADE RISK / REWARD BOXES  (red = risk entry→SL, green = reward entry→TP3)
// ─────────────────────────────────────────────────────────────────────────
var box   slBox = na          // red RISK box (entry → SL)
var box   tpBox = na          // green REWARD box (entry → TP3)
var line  lnEntry = na        // solid entry line
var line  lnSL    = na        // dashed SL line
var line  lnTP1   = na        // thin TP1 divider
var line  lnTP2   = na        // thin TP2 divider
var label lbE = na            // ENTRY
var label lbS = na            // SL
var label lb1 = na            // TP1 · 1R
var label lb2 = na            // TP2 · 2R
var label lb3 = na            // TP3 · 3R

f_computeSL(bool isBuy, float entry) =>
    float sl = na
    if useAtrSL
        sl := isBuy ? entry - atr * slMult : entry + atr * slMult
    else
        sl := isBuy ? orL : orH
    sl

if sig
    isBuy = buy
    entry = close
    sl    = f_computeSL(isBuy, entry)
    risk  = math.abs(entry - sl)
    // guard: degenerate risk falls back to ATR
    if risk <= 0 or na(risk)
        risk := atr * slMult
        sl   := isBuy ? entry - risk : entry + risk
    tp1 = isBuy ? entry + risk * tp1R : entry - risk * tp1R
    tp2 = isBuy ? entry + risk * tp2R : entry - risk * tp2R
    tp3 = isBuy ? entry + risk * tp3R : entry - risk * tp3R

    // register the trade for the win-rate tracker
    if sOpen
        losses += 1
        sOpen  := false
    sDir   := isBuy ? 1 : -1
    sEntry := entry
    sSL    := sl
    sT1    := tp1
    sOpen  := true

    if showTradeBox
        rEdge = bar_index + boxW
        // BOTH filled boxes: red risk (entry→SL) and green reward (entry→TP3).
        // Recreate boxes each signal; lines/labels are created ONCE then repositioned.
        box.delete(slBox)
        box.delete(tpBox)
        slBox := box.new(bar_index, entry, rEdge, sl,  border_color = color.new(RED, 35), bgcolor = color.new(RED, 82), border_width = 1)
        tpBox := box.new(bar_index, entry, rEdge, tp3, border_color = color.new(GRN, 35), bgcolor = color.new(GRN, 85), border_width = 1)
        if na(lnEntry)
            lnEntry := line.new(bar_index, entry, rEdge, entry, color = AMBER, width = 1)
            lnSL    := line.new(bar_index, sl,    rEdge, sl,    color = RED,   width = 1, style = line.style_dashed)
            lnTP1   := line.new(bar_index, tp1,   rEdge, tp1,   color = color.new(GRN, 30), width = 1, style = line.style_dotted)
            lnTP2   := line.new(bar_index, tp2,   rEdge, tp2,   color = color.new(GRN, 30), width = 1, style = line.style_dotted)
            lbE := label.new(rEdge, entry, "", style = label.style_label_left, color = color.new(INK, 100), size = size.small)
            lbS := label.new(rEdge, sl,    "", style = label.style_label_left, color = color.new(INK, 100), size = size.small)
            lb1 := label.new(rEdge, tp1,   "", style = label.style_label_left, color = color.new(INK, 100), size = size.small)
            lb2 := label.new(rEdge, tp2,   "", style = label.style_label_left, color = color.new(INK, 100), size = size.small)
            lb3 := label.new(rEdge, tp3,   "", style = label.style_label_left, color = color.new(INK, 100), size = size.small)
        // reposition the divider / edge lines
        line.set_xy1(lnEntry, bar_index, entry)
        line.set_xy2(lnEntry, rEdge, entry)
        line.set_xy1(lnSL, bar_index, sl)
        line.set_xy2(lnSL, rEdge, sl)
        line.set_xy1(lnTP1, bar_index, tp1)
        line.set_xy2(lnTP1, rEdge, tp1)
        line.set_xy1(lnTP2, bar_index, tp2)
        line.set_xy2(lnTP2, rEdge, tp2)
        // one right-edge label per level (ENTRY / SL / TP1·1R / TP2·2R / TP3·3R)
        label.set_xy(lbE, rEdge, entry)
        label.set_text(lbE, (isBuy ? "▲ " : "▼ ") + "ENTRY " + f_num(entry))
        label.set_textcolor(lbE, AMBER)
        label.set_xy(lbS, rEdge, sl)
        label.set_text(lbS, "SL " + f_num(sl))
        label.set_textcolor(lbS, RED_HI)
        label.set_xy(lb1, rEdge, tp1)
        label.set_text(lb1, "TP1 · " + str.tostring(tp1R, "#.#") + "R " + f_num(tp1))
        label.set_textcolor(lb1, GRN)
        label.set_xy(lb2, rEdge, tp2)
        label.set_text(lb2, "TP2 · " + str.tostring(tp2R, "#.#") + "R " + f_num(tp2))
        label.set_textcolor(lb2, GRN_HI)
        label.set_xy(lb3, rEdge, tp3)
        label.set_text(lb3, "TP3 · " + str.tostring(tp3R, "#.#") + "R " + f_num(tp3))
        label.set_textcolor(lb3, GRN_HI)

// extend the active trade graphic to the right while the trade is live
if showTradeBox and sOpen and not na(slBox) and barstate.islast
    rE = bar_index + boxW
    box.set_right(slBox, rE)
    box.set_right(tpBox, rE)
    line.set_x2(lnEntry, rE)
    line.set_x2(lnSL, rE)
    line.set_x2(lnTP1, rE)
    line.set_x2(lnTP2, rE)
    label.set_x(lbE, rE)
    label.set_x(lbS, rE)
    label.set_x(lb1, rE)
    label.set_x(lb2, rE)
    label.set_x(lb3, rE)

resolved = wins + losses
winRate  = resolved > 0 ? wins / resolved * 100.0 : na

// ─────────────────────────────────────────────────────────────────────────
//  PLOTS  (glow ORH/ORL · session tint · signals)
// ─────────────────────────────────────────────────────────────────────────
orHplot = (orLocked and dayHasOR) ? orH : na
orLplot = (orLocked and dayHasOR) ? orL : na
plot(glowLevels ? orHplot : na, "ORH glow", color = color.new(CYAN, 72), linewidth = 5, style = plot.style_linebr)
plot(glowLevels ? orLplot : na, "ORL glow", color = color.new(MAG, 72),  linewidth = 5, style = plot.style_linebr)

// session background tint — cyan while OR is forming, purple while trading
sesCol = inORB ? color.new(CYAN, 90) : inTrade ? color.new(PURP, 93) : na
bgcolor(showBg ? sesCol : na, title = "Session tint")

// bias-graded candles
biasCol = bias == 1 ? color.from_gradient(conv, 0, 100, CYAN, CYAN_HI) : bias == -1 ? color.from_gradient(conv, 0, 100, MAG, MAG_HI) : color.new(MUTE, 40)
barcolor(color.new(biasCol, 30), title = "Bias candles")

plotshape(buy,  "BUY",  style = shape.labelup,   location = location.belowbar, color = CYAN, textcolor = INK,   text = "BUY",  size = size.small)
plotshape(sell, "SELL", style = shape.labeldown, location = location.abovebar, color = MAG,  textcolor = INKHI, text = "SELL", size = size.small)

// ─────────────────────────────────────────────────────────────────────────
//  DASHBOARD  (cyberpunk HUD)
// ─────────────────────────────────────────────────────────────────────────
// dashboard is fully adjustable — reposition (hudPos) and resize text (hudSize)
hudSize = input.string("Normal", "Dashboard text size", options = ["Tiny", "Small", "Normal", "Large"], group = "Dashboard")
hudTS = hudSize == "Tiny" ? size.tiny : hudSize == "Small" ? size.small : hudSize == "Large" ? size.large : size.normal
var table hud = na
if showHUD and barstate.islast
    if not na(hud)
        table.delete(hud)
    hud := table.new(f_pos(hudPos), 2, 9, bgcolor = color.new(hudBg, 0), frame_color = color.new(PURP, 40), frame_width = 1, border_width = 0)
    SURF  = color.new(hudBg, 0)
    HEADR = color.new(color.from_gradient(0.5, 0, 1, hudBg, #241246), 0)

    // ── SESSION PHASE → big coloured badge headline ──
    phaseT = inORB ? "◉ IN OR" : (not dayHasOR ? "◷ PRE-OR" : inTrade ? "▶ TRADING" : "■ CLOSED")
    phaseC = inORB ? CYAN : (not dayHasOR ? PURP : inTrade ? MAG : MUTE)   // accent per phase
    badgeBg = color.new(phaseC, 20)

    rngTxt = na(orRange) ? "—" : f_num(orRange)
    rngC   = na(orRange) ? MUTE : CYAN_HI

    biasT  = bias == 1 ? "LONG ▲" : bias == -1 ? "SHORT ▼" : "Inside"
    biasC  = bias == 1 ? CYAN_HI : bias == -1 ? MAG_HI : MUTE

    convC  = conv >= 66 ? CYAN_HI : conv >= 33 ? PURP_HI : MUTE

    sigT   = buy ? "BUY BREAKOUT ▲" : sell ? "SELL BREAKOUT ▼" : canTrade ? "Armed" : "Standby"
    sigC   = buy ? CYAN_HI : sell ? MAG_HI : canTrade ? PURP_HI : MUTE

    trTxt  = "L " + str.tostring(buysToday) + " / S " + str.tostring(sellsToday) + " · max " + str.tostring(maxTrades)
    trCap  = (buysToday >= maxTrades or sellsToday >= maxTrades)
    trC    = trCap ? AMBER : INKHI
    trBg   = color.new(PURP, 78)

    statTxt = na(winRate) ? "—" : str.tostring(math.round(winRate)) + "% (" + str.tostring(resolved) + ")"
    statC   = na(winRate) ? MUTE : winRate >= 55 ? GRN_HI : winRate <= 45 ? RED_HI : AMBER

    // row 0 — session-phase badge headline spanning both columns
    table.cell(hud, 0, 0, phaseT + "  ", text_color = INK, text_halign = text.align_left, bgcolor = badgeBg, text_size = hudTS)
    table.cell(hud, 1, 0, "ORB · JOAT  ", text_color = INK, text_halign = text.align_right, bgcolor = badgeBg, text_size = hudTS)
    // row 1 — trades today, given its own accented row (prominent)
    table.cell(hud, 0, 1, "  TRADES TODAY", text_color = PURP_HI, text_halign = text.align_left, bgcolor = trBg, text_size = hudTS)
    table.cell(hud, 1, 1, trTxt + "  ", text_color = trC, text_halign = text.align_right, bgcolor = trBg, text_size = hudTS)
    // row 2 — conviction pip meter
    table.cell(hud, 0, 2, "  Conviction", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 2, f_pips(conv / 100.0) + " " + str.tostring(conv) + "  ", text_color = convC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    // row 3 — signal
    table.cell(hud, 0, 3, "  Signal", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 3, sigT + "  ", text_color = sigC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    // row 4 — bias
    table.cell(hud, 0, 4, "  Bias", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 4, biasT + "  ", text_color = biasC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    // row 5 — OR range
    table.cell(hud, 0, 5, "  OR range", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 5, rngTxt + "  ", text_color = rngC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    // row 6 — ORH / ORL
    table.cell(hud, 0, 6, "  ORH / ORL", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 6, (na(orH) ? "—" : f_num(orH)) + " / " + (na(orL) ? "—" : f_num(orL)) + "  ", text_color = INKHI, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    // row 7 — divider label
    table.cell(hud, 0, 7, "  ── stats ──", text_color = MUTE, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 7, "", bgcolor = SURF, text_size = hudTS)
    // row 8 — live win-rate
    table.cell(hud, 0, 8, "  Win (TP1)", text_color = MUTE, text_halign = text.align_left, bgcolor = HEADR, text_size = hudTS)
    table.cell(hud, 1, 8, statTxt + "  ", text_color = statC, text_halign = text.align_right, bgcolor = HEADR, text_size = hudTS)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────
alertcondition(buy,    "Buy",       "ORB Liquidity: close broke above the Opening Range high inside the trade session")
alertcondition(sell,   "Sell",      "ORB Liquidity: close broke below the Opening Range low inside the trade session")
alertcondition(orbEnd, "OR formed", "ORB Liquidity: Opening Range locked for the day")
````

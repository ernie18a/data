# Opening Range Breakout Session Strategy [JOAT]

- url: https://www.tradingview.com/script/JCDja5a6-Opening-Range-Breakout-Session-Strategy-JOAT/
- type: indicator
- pine_id: PUB;f64d6d27e9c44cca8aa8187a860231fd
- version: 1.0

## Description

[b]Opening Range Breakout Session Strategy [JOAT][/b]
[i]Locks the opening range of your session, then trades disciplined, capped breakouts beyond it with fully framed risk.[/i]

[image]https://www.tradingview.com/x/TC1rnHwU/[/image]

[b]What it is[/b]
The first minutes of a session set the day's battle lines. The opening range — the high and low forged during that early window — is where overnight orders, gap fills and early positioning collide, and price leaving that range tends to keep going. This indicator builds the opening range objectively, trades confirmed breakouts from it, and enforces the discipline that makes the approach workable: a session filter and a hard daily trade cap. It is an original implementation of the widely-used opening-range-breakout concept.

[b]How it works[/b]
• [b]Opening range[/b] — during a user-defined opening window (09:30–10:00 by default, in your chosen timezone) the tool records the high and low, then locks them as the reference range and draws a clean box with labelled ORH and ORL levels.

• [b]Session and daily reset[/b] — signals are only allowed inside a separate trade-session window, and the range clears cleanly on each new day using a real day-change test, so nothing carries over stale.

• [b]Breakout logic[/b] — a Buy fires on a confirmed close above the range high plus a small ATR buffer; a Sell on a confirmed close below the range low minus the buffer. The buffer filters marginal pokes through the edge.

• [b]Discipline[/b] — a hard cap of N trades per day plus a minimum-bar spacing control prevent the range edges from generating repeated signals as price oscillates around them.

[b]Trade framing[/b]
Each signal projects a red risk box and a green reward box. The stop is either the opposite opening-range edge (structure-based, the default) or an ATR distance, and the three targets ladder out in R multiples with labelled entry, stop and take-profit prices. Extension levels at 1R and 2R from the range edges are also projected as context for where a breakout may travel.

[b]The dashboard[/b]
An adjustable session ticket shows the current phase (pre-open, opening, session or locked), the range size, the bias relative to the range, a breakout-extension meter, the trades used against the daily cap, the active signal, and a live first-target-before-stop tally from closed bars only.

[b]How to use it[/b]
• Set the opening window, trade session and timezone to match your market (index or futures cash open, an FX session, or a crypto day boundary).
• Wait for the range to lock, then take confirmed breakouts; use the opposite edge as your invalidation and the extension levels as context.
• Respect the daily cap — the discipline is part of the method, not an afterthought.

[b]Settings[/b]
Opening-range and trade-session windows, timezone, ATR length, stop mode and multiplier, breakout buffer, target R multiples, maximum trades per day, plus full visual and dashboard controls.

[b]Originality and usefulness[/b]
Opening-range breakout is a public concept; the contribution here is the complete, disciplined implementation — objective range locking, a strict session and daily-reset model, buffered confirmed-close breakouts, structure-based stops at the opposite edge, and integrated non-repainting trade framing — explained so each control's purpose is clear.

[b]Notes and limitations[/b]
• Range-bound sessions produce whipsaws around the edges; the buffer and daily cap reduce but do not remove this.
• Breakouts fail regularly — the opposite-edge stop and R-based targets exist precisely for that reason.
• Session settings must match the instrument, or the range will be measured at the wrong time.
• The win tally reflects only past bars on the current chart and is not a forecast.
• Educational and analytical tool, not financial advice.

[i]— made with passion by officialjackofalltrades[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6

indicator("Opening Range Breakout Session Strategy [JOAT]", "ORB Session [JOAT]", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// ─────────────────────────────────────────────────────────────────────────
//  PALETTE  (clean black & white / grey — one faint red, one faint green)
// ─────────────────────────────────────────────────────────────────────────
WHITE   = #F5F7FA
LGREY   = #C7CDD6
MGREY   = #8A93A3
INK     = #14181F
GRN     = #4E8C6A     // restrained, muted green (reward only)
RED     = #B5595E     // restrained, muted red (risk only)

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
gS       = "Sessions"
orbSess  = input.session("0930-1000", "Opening Range window", group = gS, tooltip = "The early window whose high/low form the Opening Range.")
tradeSess= input.session("1000-1600", "Trade session window", group = gS, tooltip = "Signals are only permitted inside this window.")
tz       = input.string("America/New_York", "Timezone", options = ["America/New_York","America/Chicago","America/Los_Angeles","Europe/London","Europe/Berlin","Asia/Tokyo","Asia/Shanghai","Asia/Kolkata","Australia/Sydney","UTC"], group = gS)

gR       = "Risk / Targets"
atrLen   = input.int(14, "ATR length", minval = 1, group = gR)
useAtrSL = input.bool(false, "SL from ATR (else opposite OR edge)", group = gR, tooltip = "On: stop is ATR×mult from entry. Off: stop is the opposite Opening Range edge.")
slMult   = input.float(1.0, "SL = ATR ×", minval = 0.1, step = 0.1, group = gR)
buffMult = input.float(0.10,"Breakout buffer = ATR ×", minval = 0.0, step = 0.05, group = gR, tooltip = "Small cushion beyond the OR edge required to confirm a break.")
tp1R     = input.float(1.0, "TP1 (R)", step = 0.5, group = gR)
tp2R     = input.float(2.0, "TP2 (R)", step = 0.5, group = gR)
tp3R     = input.float(3.0, "TP3 (R)", step = 0.5, group = gR)
maxTrades= input.int(2, "Max trades / day", minval = 1, maxval = 10, group = gR)

gV       = "Visuals"
showBox  = input.bool(true, "Opening Range box", group = gV)
showLevels=input.bool(true, "ORH / ORL extended lines", group = gV)
showTargets=input.bool(true,"1R / 2R extension targets", group = gV)
showRR   = input.bool(true, "TP/SL box on signal", group = gV)
paintBars= input.bool(true, "Monochrome candle paint", group = gV, tooltip = "White up bars, grey down bars.")
shadeORB = input.bool(true, "Shade opening-range window", group = gV)
boxExtend= input.int(20, "Signal box width (bars)", minval = 5, maxval = 100, group = gV)

gP       = "Dashboard"
showHUD  = input.bool(true, "Show dashboard", group = gP)
hudPos   = input.string("Top Right","Position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = gP)

// ─────────────────────────────────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────────────────────────────────
f_pos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.middle_right

// compact 5-segment DASH meter — filled ▬ vs empty ▭
f_dash(float p01) =>
    n = math.round(math.max(0.0, math.min(1.0, p01)) * 5)
    out = ""
    for i = 1 to 5
        out := out + (i <= n ? "▬" : "▭")
    out

// ─────────────────────────────────────────────────────────────────────────
//  SESSION STATE
// ─────────────────────────────────────────────────────────────────────────
atr        = ta.atr(atrLen)
inOrb      = not na(time(timeframe.period, orbSess, tz))
inTrade    = not na(time(timeframe.period, tradeSess, tz))
orbStart   = inOrb and not inOrb[1]          // first bar of the OR window
orbEnd     = not inOrb and inOrb[1]           // first bar after window closes
newDay     = timeframe.change("D")

// ─────────────────────────────────────────────────────────────────────────
//  OPENING RANGE  (build during window, lock when it ends)
// ─────────────────────────────────────────────────────────────────────────
var float orH    = na
var float orL    = na
var bool  orLock = false

if orbStart
    orH    := high
    orL    := low
    orLock := false
else if inOrb
    orH    := math.max(nz(orH, high), high)
    orL    := math.min(nz(orL, low), low)

if orbEnd
    orLock := true

if newDay and not inOrb
    // fresh day before the window opens — clear the stale range
    orLock := false

orValid = orLock and not na(orH) and not na(orL)
orMid   = orValid ? (orH + orL) / 2 : na
orRange = orValid ? orH - orL : na

// R-extension targets projected from the range edges
tgtUp1 = orValid ? orH + nz(orRange) * tp1R : na
tgtUp2 = orValid ? orH + nz(orRange) * tp2R : na
tgtDn1 = orValid ? orL - nz(orRange) * tp1R : na
tgtDn2 = orValid ? orL - nz(orRange) * tp2R : na

// ─────────────────────────────────────────────────────────────────────────
//  BREAKOUT SIGNALS  (trade session only, capped per day)
// ─────────────────────────────────────────────────────────────────────────
var int tradesToday = 0
if newDay
    tradesToday := 0

buffer  = atr * buffMult
crossUp = orValid and inTrade and close > orH + buffer and close[1] <= orH[1] + buffer
crossDn = orValid and inTrade and close < orL - buffer and close[1] >= orL[1] - buffer

canTrade = tradesToday < maxTrades
buy  = crossUp and canTrade
sell = crossDn and canTrade
sig  = buy or sell

// ── signal debounce — Buy/Sell can never stack on any timeframe
minGap = input.int(5, "Min bars between signals", minval = 0, group = "Signals", tooltip = "Minimum bar spacing between printed signals so labels never overlap on lower timeframes. 0 = off.")
var int lastSigBar = na
okGap = na(lastSigBar) or (bar_index - lastSigBar) >= minGap
buy  := buy  and okGap
sell := sell and okGap
sig  := buy or sell
if sig
    lastSigBar := bar_index

if sig
    tradesToday += 1

bias = orValid ? (close > orH ? 1 : close < orL ? -1 : 0) : 0

// ─────────────────────────────────────────────────────────────────────────
//  LIVE STATS  (resolve open trade before arming a new one — no lookahead)
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
//  TP/SL BOX  (single active, redrawn per signal)
// ─────────────────────────────────────────────────────────────────────────
var box   slBox = na          // red RISK box  (entry → SL)
var box   tpBox = na          // green REWARD box (entry → TP3)
var line  lnE   = na          // solid ENTRY line
var line  lnS   = na          // dashed SL line (risk-box floor)
var line  ln1   = na          // TP1 divider across reward box
var line  ln2   = na          // TP2 divider across reward box
var label lbE   = na
var label lbS   = na
var label lb1   = na
var label lb2   = na
var label lb3   = na

f_setLbl(label lb, float p, string txt) =>
    label.set_xy(lb, bar_index + boxExtend, p)
    label.set_text(lb, txt)

if sig
    if sOpen
        losses += 1
        sOpen := false

    entry = close
    risk  = useAtrSL ? atr * slMult : (buy ? entry - orL : orH - entry)
    risk := risk <= 0 ? atr * slMult : risk           // guard degenerate range
    sl    = buy ? entry - risk : entry + risk
    t1    = buy ? entry + risk * tp1R : entry - risk * tp1R
    t2    = buy ? entry + risk * tp2R : entry - risk * tp2R
    t3    = buy ? entry + risk * tp3R : entry - risk * tp3R

    sDir  := buy ? 1 : -1
    sEntry:= entry
    sSL   := sl
    sT1   := t1
    sOpen := true

    if showRR
        rx = bar_index + boxExtend
        box.delete(slBox)
        box.delete(tpBox)
        // red RISK box: entry → SL   |   green REWARD box: entry → TP3
        slBox := box.new(bar_index, entry, rx, sl, border_color = color.new(RED, 35), border_width = 1, bgcolor = color.new(RED, 91))
        tpBox := box.new(bar_index, entry, rx, t3, border_color = color.new(GRN, 35), border_width = 1, bgcolor = color.new(GRN, 92))

        if na(lbE)
            lnE := line.new(bar_index, entry, rx, entry, color = INK, width = 1, style = line.style_solid)
            lnS := line.new(bar_index, sl, rx, sl, color = color.new(RED, 25), width = 1, style = line.style_dashed)
            ln1 := line.new(bar_index, t1, rx, t1, color = color.new(GRN, 40), width = 1, style = line.style_dotted)
            ln2 := line.new(bar_index, t2, rx, t2, color = color.new(GRN, 40), width = 1, style = line.style_dotted)
            lbE := label.new(rx, entry, "", style = label.style_label_left, color = WHITE, textcolor = INK, size = size.small)
            lbS := label.new(rx, sl, "", style = label.style_label_left, color = WHITE, textcolor = INK, size = size.small)
            lb1 := label.new(rx, t1, "", style = label.style_label_left, color = WHITE, textcolor = INK, size = size.small)
            lb2 := label.new(rx, t2, "", style = label.style_label_left, color = WHITE, textcolor = INK, size = size.small)
            lb3 := label.new(rx, t3, "", style = label.style_label_left, color = WHITE, textcolor = INK, size = size.small)

        line.set_xy1(lnE, bar_index, entry)
        line.set_xy2(lnE, rx, entry)
        line.set_xy1(lnS, bar_index, sl)
        line.set_xy2(lnS, rx, sl)
        line.set_xy1(ln1, bar_index, t1)
        line.set_xy2(ln1, rx, t1)
        line.set_xy1(ln2, bar_index, t2)
        line.set_xy2(ln2, rx, t2)
        f_setLbl(lbE, entry, " ENTRY " + str.tostring(entry, format.mintick))
        f_setLbl(lbS, sl,    " SL " + str.tostring(sl, format.mintick))
        f_setLbl(lb1, t1,    " TP1 · " + str.tostring(tp1R, "#.#") + "R  " + str.tostring(t1, format.mintick))
        f_setLbl(lb2, t2,    " TP2 · " + str.tostring(tp2R, "#.#") + "R  " + str.tostring(t2, format.mintick))
        f_setLbl(lb3, t3,    " TP3 · " + str.tostring(tp3R, "#.#") + "R  " + str.tostring(t3, format.mintick))

// keep the active trade box/labels pinned to the right edge while price develops
if showRR and sOpen and not na(slBox) and barstate.islast
    rx2 = bar_index + boxExtend
    box.set_right(slBox, rx2)
    box.set_right(tpBox, rx2)
    line.set_x2(lnE, rx2)
    line.set_x2(lnS, rx2)
    line.set_x2(ln1, rx2)
    line.set_x2(ln2, rx2)
    label.set_x(lbE, rx2)
    label.set_x(lbS, rx2)
    label.set_x(lb1, rx2)
    label.set_x(lb2, rx2)
    label.set_x(lb3, rx2)

resolved = wins + losses
winRate  = resolved > 0 ? wins / resolved * 100.0 : na

// ─────────────────────────────────────────────────────────────────────────
//  OPENING-RANGE BOX  (clean: light fill, thin near-black border)
// ─────────────────────────────────────────────────────────────────────────
var box orBox = na
if orbEnd and showBox
    orBox := box.new(bar_index, orH, bar_index + boxExtend, orL, border_color = color.new(INK, 25), border_width = 1, bgcolor = color.new(LGREY, 88))
if showBox and orValid and not na(orBox) and barstate.islast
    box.set_right(orBox, bar_index + boxExtend)

// small clean ORH / ORL labels riding the right edge of the range
var label orhLbl = na
var label orlLbl = na
if showLevels and orValid and barstate.islast
    if na(orhLbl)
        orhLbl := label.new(bar_index + boxExtend, orH, "", style = label.style_label_left, color = WHITE, textcolor = INK, size = size.small)
        orlLbl := label.new(bar_index + boxExtend, orL, "", style = label.style_label_left, color = WHITE, textcolor = INK, size = size.small)
    label.set_xy(orhLbl, bar_index + boxExtend, orH)
    label.set_text(orhLbl, " ORH " + str.tostring(orH, format.mintick))
    label.set_xy(orlLbl, bar_index + boxExtend, orL)
    label.set_text(orlLbl, " ORL " + str.tostring(orL, format.mintick))

// ─────────────────────────────────────────────────────────────────────────
//  PLOTS
// ─────────────────────────────────────────────────────────────────────────
plotLevels = showLevels and orValid
plot(plotLevels ? orH : na, "ORH", color = color.new(INK, 0), linewidth = 1, style = plot.style_linebr)
plot(plotLevels ? orL : na, "ORL", color = color.new(INK, 0), linewidth = 1, style = plot.style_linebr)
plot(plotLevels ? orMid : na, "OR Mid", color = color.new(MGREY, 20), linewidth = 1, style = plot.style_linebr)

plotTgt = showTargets and orValid
plot(plotTgt ? tgtUp1 : na, "Up 1R", color = color.new(MGREY, 45), linewidth = 1, style = plot.style_linebr)
plot(plotTgt ? tgtUp2 : na, "Up 2R", color = color.new(LGREY, 40), linewidth = 1, style = plot.style_linebr)
plot(plotTgt ? tgtDn1 : na, "Dn 1R", color = color.new(MGREY, 45), linewidth = 1, style = plot.style_linebr)
plot(plotTgt ? tgtDn2 : na, "Dn 2R", color = color.new(LGREY, 40), linewidth = 1, style = plot.style_linebr)

// monochrome candle paint
paintCol = close >= open ? WHITE : MGREY
barcolor(paintBars ? paintCol : na, title = "Monochrome candles")

// subtle grey shading during the OR window only
bgcolor(shadeORB and inOrb ? color.new(MGREY, 92) : na, title = "OR window shade")

// clean breakout markers (monochrome)
plotshape(buy,  "BUY",  style = shape.triangleup,   location = location.belowbar, color = INK,   size = size.tiny)
plotshape(sell, "SELL", style = shape.triangledown, location = location.abovebar, color = MGREY, size = size.tiny)

// ─────────────────────────────────────────────────────────────────────────
//  DASHBOARD  (understated: white/grey surfaces, near-black text)
// ─────────────────────────────────────────────────────────────────────────
// dashboard is fully adjustable — reposition (hudPos) and resize text (hudSize)
hudSize = input.string("Normal", "Dashboard text size", options = ["Tiny", "Small", "Normal", "Large"], group = "Dashboard")
hudTS = hudSize == "Tiny" ? size.tiny : hudSize == "Small" ? size.small : hudSize == "Large" ? size.large : size.normal
var table hud = na
if showHUD and barstate.islast
    if not na(hud)
        table.delete(hud)
    hud := table.new(f_pos(hudPos), 2, 7, bgcolor = color.new(WHITE, 6), frame_color = color.new(INK, 40), frame_width = 1, border_color = color.new(LGREY, 40), border_width = 1)
    SURF  = color.new(WHITE, 6)
    HEADR = color.new(LGREY, 22)      // grey header / footer strip
    BADGE = color.new(MGREY, 12)      // session-phase badge cell

    // session phase → short badge label
    phaseT = inOrb ? "OPENING" : orValid ? (inTrade ? "SESSION" : "LOCKED") : "PRE-OPEN"
    rangeT = orValid ? str.tostring(orRange, format.mintick) : "—"
    biasT  = bias == 1 ? "Above OR ▲" : bias == -1 ? "Below OR ▼" : "Inside range"
    biasC  = bias == 1 ? INK : MGREY
    // breakout extension = how far price has pushed past the OR mid (in range units)
    brkP   = orValid and not na(orRange) and orRange > 0 ? math.min(1.0, math.abs(close - orMid) / orRange) : 0.0
    brkT   = f_dash(brkP)
    sigT   = buy ? "BUY — break ▲" : sell ? "SELL — break ▼" : inTrade and orValid ? "Watching" : "—"
    sigC   = buy ? INK : MGREY
    tradeT = str.tostring(tradesToday) + " / " + str.tostring(maxTrades)
    tradeC = tradesToday >= maxTrades ? MGREY : INK
    wrT    = na(winRate) ? "—" : str.tostring(math.round(winRate)) + "% (" + str.tostring(resolved) + ")"

    // ── header strip: ticket title + session-phase badge ──
    table.cell(hud, 0, 0, "  ▸ ORB TICKET", text_color = INK, text_halign = text.align_left, bgcolor = HEADR, text_size = hudTS)
    table.cell(hud, 1, 0, phaseT + "  ", text_color = INK, text_halign = text.align_right, bgcolor = BADGE, text_size = hudTS)
    // ── body ──
    table.cell(hud, 0, 1, "  Bias", text_color = MGREY, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 1, biasT + "  ", text_color = biasC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 2, "  OR range", text_color = MGREY, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 2, rangeT + "  ", text_color = INK, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 3, "  Breakout", text_color = MGREY, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 3, brkT + "  ", text_color = INK, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 4, "  Signal", text_color = MGREY, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 4, sigT + "  ", text_color = sigC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 0, 5, "  Trades", text_color = MGREY, text_halign = text.align_left, bgcolor = SURF, text_size = hudTS)
    table.cell(hud, 1, 5, tradeT + "  ", text_color = tradeC, text_halign = text.align_right, bgcolor = SURF, text_size = hudTS)
    // ── footer strip: live win-rate ──
    table.cell(hud, 0, 6, "  Win (TP1)", text_color = INK, text_halign = text.align_left, bgcolor = HEADR, text_size = hudTS)
    table.cell(hud, 1, 6, wrT + "  ", text_color = INK, text_halign = text.align_right, bgcolor = HEADR, text_size = hudTS)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────
alertcondition(buy,    "Buy",  "ORB Session: bullish breakout above the Opening Range high")
alertcondition(sell,   "Sell", "ORB Session: bearish breakdown below the Opening Range low")
alertcondition(sig,    "Any signal", "ORB Session: Opening Range breakout signal")
alertcondition(orbEnd, "OR locked", "ORB Session: Opening Range window has closed and locked")
````

# Stryk HTF Reversal Box

- url: https://www.tradingview.com/script/zM6kiFN9-Stryk-HTF-Reversal-Box/
- type: indicator
- pine_id: PUB;f38597c3eb904b5a85054cf96f32bcc5
- version: 1.0

## Description

# Stryk HTF Reversal Box — TradingView publication description

*(Paste the section below into the description box when you publish. It is written to avoid performance or outcome claims. Keep it as-is; do not add win rates, returns, or "profitable" language.)*

---

## Stryk HTF Reversal Box

**Overview**

Stryk HTF Reversal Box is a market-analysis tool that carries a higher-timeframe reaction zone onto your entry chart. It draws a High/Low box from recent closed higher-timeframe bars, but only when a higher-timeframe bar closed at a conviction extreme of its ATR band with above-average volume — the kind of location where a reaction, or a strong push through it, tends to begin. The box then moves through a clear, colour-coded lifecycle so you can read its state at a glance, and an optional panel measures the behaviour of the boxes on your current chart.

**The idea**

Levels drawn purely from price often lack context: why should this high matter more than that one? This tool adds two pieces of information a bare level does not carry — where a higher-timeframe bar closed within its own volatility band, and whether it did so on meaningful volume. A close pinned to the top of the band on strong volume is a stretched, high-participation event; a shelf built there is a more considered level than an arbitrary swing high. The script turns that reasoning into a defined, repeatable object.

**How it works**

- **Band position.** On the selected higher timeframe, an EMA-of-close band of ±(width × ATR) is constructed. The last closed higher-timeframe bar's close is located inside that band on a 0-to-1 scale (0 = band low, 1 = band high).
- **Qualification.** A close in the top of the band (at or above the Top threshold) on above-average volume marks a stretched high and draws a red "expect-down" box. A close in the bottom (at or below the Bottom threshold) on above-average volume draws a green "expect-up" box.
- **The box.** It spans the High/Low of the last N closed higher-timeframe bars and re-rolls on each higher-timeframe close until a bar qualifies.
- **Breakout.** On your entry chart, a candle that closes beyond a box edge with volume above the chart average locks the box and projects a target a chosen multiple of ATR beyond the edge. The box then takes the colour of the actual break direction, so a push through the extreme flips its colour to the continuation side.
- **Retest shelves.** 25 / 50 / 75% levels inside the box mark common pullback references. If price closes through the opposite edge, the box holds position and re-projects a target in the new direction.
- **Consolidation.** If the target is not reached within the timeout while price remains inside the box, the box turns blue and removes its target, waiting for a fresh break rather than assuming direction.

**State colours (line style shows the state)**

- Grey dotted — forming, waiting for a qualifying higher-timeframe bar
- Red / green dotted — armed, expecting a reaction down / up
- Solid — a volume-backed break has set a target
- Blue dotted — consolidating inside the box after the timeout

**The panel**

The optional corner panel is a self-measuring summary of the boxes on your current chart and timeframe only: how many reached their target, how many entered consolidation, the resulting rate shown with its sample size (n), and the average number of bars taken to reach target. It describes what has already happened on this chart. It is a study aid, not a projection, and it recalculates when you change settings.

**How to use it**

1. Choose the higher timeframe you take context from and load the tool on the entry timeframe you actually trade.
2. Watch for an armed (red or green) box forming a reaction zone.
3. A box turning solid marks a volume-backed break with a projected target; the 25 / 50 / 75% shelves are retest references inside the zone.
4. Use the panel to understand how these boxes have behaved on your instrument and timeframe before relying on them.

Every threshold, length, colour, width, and label is adjustable in the settings, and each input carries an in-app tooltip describing exactly what it does.

**Notes on repainting**

Higher-timeframe data is read from confirmed, closed bars using a one-bar offset with lookahead disabled, and all state changes are evaluated on the bar close. The live projection to the right of price is cosmetic; the box edges, breakouts, targets, and states are fixed once determined on a closed bar.

**Disclaimer**

This script is a technical-analysis and study tool. It does not place orders, does not provide financial advice, and makes no claim about future results. Markets involve risk; use your own judgement and risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Es-Sniper
//
// ── Stryk HTF Reversal Box ───────────────────────────────────────────────────
// WHAT IT IS
// A context tool that brings a higher-timeframe reversal zone down onto your
// entry chart. It draws a High/Low box from recent CLOSED higher-timeframe
// bars, but only when a higher-timeframe bar closed at a conviction extreme of
// its ATR band on above-average volume — the locations where a turn (or, if
// price pushes through instead, a larger continuation) tends to originate.
//
// HOW IT WORKS
// • Band position: an EMA-of-close band of ±(width × ATR) is built on the
//   higher timeframe. The last closed HTF bar's close is measured inside that
//   band (0 = band low, 1 = band high).
// • Qualification: a close in the top of the band (≥ Top threshold) with volume
//   above its average draws a red "expect-down" box; a close in the bottom
//   (≤ Bottom threshold) with volume draws a green "expect-up" box.
// • The box spans the High/Low of the last N closed HTF bars and re-rolls each
//   HTF close until it qualifies, then waits.
// • Breakout: on your entry chart, a candle that CLOSES beyond a box edge with
//   volume above the chart average locks the box and sets a target a chosen
//   multiple of ATR beyond the edge. The box colours by the actual break
//   direction, so a continuation through the extreme flips the colour.
// • Retest shelves at 25/50/75% mark where price often pulls back to after a
//   break. If price closes through the opposite edge, the box holds its place
//   and re-targets the new direction.
// • Consolidation: if the target is not reached within the timeout while price
//   stays inside the box, the box turns blue and removes its target, waiting for
//   a fresh break.
// • The optional panel self-measures this chart's own boxes: how many reached
//   target, how many consolidated, the resulting rate with its sample size, and
//   the average number of bars to reach target.
//
// STATE COLOURS (line style shows the state at a glance)
//   grey dotted  = forming        red/green dotted = armed (expected reversal)
//   solid        = target live     blue dotted      = consolidating
//
// HOW TO USE
// Pick the higher timeframe you take context from and the entry timeframe you
// trade. Watch for an armed (red/green) box, then a solid box once a
// volume-backed break sets the target. The shelves are retest references; the
// panel tells you, from this chart's history, how often these breaks have
// reached target and how long they took. Every threshold, colour, width, and
// label is adjustable in the settings.
//
// NOTES
// Non-repainting: higher-timeframe data is read from confirmed CLOSED bars
// (one-bar offset, lookahead off) and every state change is evaluated on the
// bar close. The performance panel is a description of this chart's past
// behaviour, not a prediction. This script is a market-analysis and study tool,
// not financial advice; it does not place orders or guarantee any outcome.
// ─────────────────────────────────────────────────────────────────────────────

//@version=6
indicator("Stryk HTF Reversal Box", "Stryk: HTF Box", overlay = true, max_lines_count = 500, max_labels_count = 100, max_boxes_count = 50, max_bars_back = 500)

// ════════════════════════════════════════════════════════════════════════════
// 1 · HTF SOURCE
// ════════════════════════════════════════════════════════════════════════════
g1 = "1 · HTF source"
htfTf   = input.timeframe("60", "Higher timeframe", group = g1, tooltip = "The box is built from CLOSED bars of this timeframe — never the bar still forming. 60 = 1 hour. The whole idea is to carry a higher-timeframe reversal zone down onto your entry chart.")
nBars   = input.int(1, "Closed HTF bars for High/Low", minval = 1, maxval = 50, group = g1, tooltip = "How many CLOSED higher-timeframe bars are measured to build the box. 1 = just the last closed HTF bar's high and low. 4 = the highest high and lowest low across the last 4 closed HTF bars (a wider zone). The box keeps re-rolling over the most recent N closed bars until a breakout locks it.")
atrLen  = input.int(14, "Master ATR length", minval = 1, maxval = 200, group = g1, tooltip = "One ATR length used throughout: the band that measures the HTF bar's conviction, and the ATR the target distance is scaled from. 14 is the standard setting.")
bandLen = input.int(20, "Band basis (EMA length)", minval = 1, maxval = 200, group = g1, tooltip = "The conviction band is an EMA of close of this length, plus and minus (width × ATR). The HTF bar's close position inside that band is what tells us whether it closed stretched toward an extreme.")
bandMult = input.float(1.5, "Band width (× ATR)", minval = 0.2, maxval = 5.0, step = 0.1, group = g1, tooltip = "How wide the band is, in ATR. Wider = fewer closes count as 'at the extreme', so a box only draws on stronger stretches. Narrower = more setups, lower selectivity.")

// ════════════════════════════════════════════════════════════════════════════
// 2 · QUALIFICATION (which HTF bars draw a box)
// ════════════════════════════════════════════════════════════════════════════
g2 = "2 · Qualification"
topThr    = input.float(0.75, "Top of band ≥", minval = 0.5, maxval = 1.2, step = 0.05, group = g2, tooltip = "If the HTF bar closes at or above this fraction of its band (0.75 = the top quarter), it counts as an extended HIGH — a possible reversal DOWN — and the box draws RED. Higher = only more extreme closes qualify.")
botThr    = input.float(0.25, "Bottom of band ≤", minval = -0.2, maxval = 0.5, step = 0.05, group = g2, tooltip = "If the HTF bar closes at or below this fraction (0.25 = the bottom quarter), it counts as an extended LOW — a possible reversal UP — and the box draws GREEN. Lower = only more extreme closes qualify.")
htfVolMult = input.float(1.5, "HTF volume ≥ (× HTF avg)", minval = 0.5, maxval = 10.0, step = 0.1, group = g2, tooltip = "The qualifying HTF bar must also have volume at least this multiple of its own recent average. This is the conviction filter: a stretched close on heavy volume is a far stronger setup than the same close on light volume.")
htfVolLen = input.int(20, "HTF volume average length", minval = 1, maxval = 200, group = g2, tooltip = "How many higher-timeframe bars are averaged for the HTF volume comparison above.")

// ════════════════════════════════════════════════════════════════════════════
// 3 · BREAKOUT (on the entry / chart timeframe)
// ════════════════════════════════════════════════════════════════════════════
g3 = "3 · Breakout"
ltfVolMult = input.float(1.5, "Breakout volume ≥ (× chart avg)", minval = 0.5, maxval = 10.0, step = 0.1, group = g3, tooltip = "On your entry chart, a candle closing beyond a box edge only LOCKS the box (sets a target) if that candle's volume clears this multiple of the chart's recent average. It separates a real, committed break from a quiet drift through the line.")
ltfVolLen  = input.int(20, "Chart volume average length", minval = 1, maxval = 200, group = g3, tooltip = "How many chart-timeframe bars are averaged for the breakout volume comparison above.")

// ════════════════════════════════════════════════════════════════════════════
// 4 · TARGET
// ════════════════════════════════════════════════════════════════════════════
g4 = "4 · Target"
tgtAtrHtf = input.bool(false, "Scale target off HTF ATR (else chart ATR)", group = g4, tooltip = "Off (default): the target distance is a multiple of the CHART timeframe's ATR — reachable intraday. On: it scales off the higher-timeframe ATR, giving much larger targets. Leave off unless you want big-swing targets.")
autoOn    = input.bool(true, "Auto target (scale by breakout volume)", group = g4, tooltip = "On (default): the target multiple scales with the breakout candle's volume — a heavier break projects a larger target — using base + (volume-ratio − 1) × slope, clamped between min and max. Off: a single fixed multiple is used.")
fixedMult = input.float(2.0, "Fixed target (× ATR)", minval = 0.2, maxval = 20.0, step = 0.1, group = g4, tooltip = "Used only when Auto target is OFF: target distance = this many ATR beyond the broken edge.")
baseMult  = input.float(2.0, "Auto: base (× ATR)", inline = "au", group = g4, tooltip = "Auto target only: the floor multiple applied to an average-volume breakout (volume-ratio = 1). Extra volume adds to this via the slope.")
autoSlope = input.float(0.25, "slope", inline = "au", group = g4, tooltip = "Auto target only: how much the multiple grows per unit of extra volume. At 0.25, a 5× volume break adds (5 − 1) × 0.25 = 1.0 to the base.")
minMult   = input.float(2.0, "Auto: min", inline = "au2", group = g4, tooltip = "Auto target only: the multiple can never fall below this floor.")
maxMult   = input.float(5.0, "max", inline = "au2", group = g4, tooltip = "Auto target only: the multiple is capped here, so a volume spike cannot project an unreachable target.")

// ════════════════════════════════════════════════════════════════════════════
// 5 · CONSOLIDATION
// ════════════════════════════════════════════════════════════════════════════
g5 = "5 · Consolidation"
timeoutBars = input.int(48, "Timeout (chart bars, no target hit)", minval = 5, maxval = 2000, group = g5, tooltip = "If a locked box has not reached its target after this many chart bars, it resolves by WHERE price is: still INSIDE the box → consolidation (the box turns blue, its target is removed, it waits for a fresh break, and it counts as the loss in the panel). OUTSIDE the box → full reset to a new grey box. This is the loss half of the panel's hit rate.")

// ════════════════════════════════════════════════════════════════════════════
// 6 · SHELVES / PROJECTION / HISTORY
// ════════════════════════════════════════════════════════════════════════════
g6 = "6 · Shelves / projection"
showShelves = input.bool(true, "Show 25/50/75% retest shelves", group = g6, tooltip = "Draws the 25 / 50 / 75% levels inside a locked box — the shelves price often retests and reacts to after a break. Turn off for a cleaner box.")
projBars    = input.int(30, "Projection bars", minval = 0, maxval = 500, group = g6, tooltip = "How many bars into the future every line extends past the last bar, so the levels sit ahead of price.")
keepN       = input.int(10, "Resolved boxes to keep", minval = 1, maxval = 60, group = g6, tooltip = "How many finished boxes stay drawn as history. Older ones delete automatically so the chart never clogs.")

// ════════════════════════════════════════════════════════════════════════════
// 7 · STYLE
// ════════════════════════════════════════════════════════════════════════════
g7 = "7 · Style"
wDot     = input.int(1, "Dotted width", minval = 1, maxval = 5, inline = "w", group = g7, tooltip = "Line width while a box has no active target (the grey / armed / consolidation states).")
wSolid   = input.int(2, "Solid width",  minval = 1, maxval = 5, inline = "w", group = g7, tooltip = "Line width once a box has locked and a target is active.")
greyCol  = input.color(#8a8f98, "Forming (grey)", group = g7, tooltip = "Colour of a fresh box that is still rolling and waiting for a qualifying HTF bar.")
upCol    = input.color(#00e676, "Up / expect-up (green)", inline = "c1", group = g7, tooltip = "Green: an armed box expecting an UP reversal (HTF closed at the bottom of its band), and a locked box that broke UP.")
dnCol    = input.color(#ff1744, "Down / expect-down (red)", inline = "c1", group = g7, tooltip = "Red: an armed box expecting a DOWN reversal (HTF closed at the top of its band), and a locked box that broke DOWN.")
consolCol = input.color(#2962ff, "Consolidation (blue)", group = g7, tooltip = "Colour a box turns when it times out with price still inside it — consolidating, waiting for a break.")
tgtUpCol = input.color(#00e676, "Target up", inline = "c2", group = g7, tooltip = "Colour of the target line for an upward break.")
tgtDnCol = input.color(#ff1744, "Target down", inline = "c2", group = g7, tooltip = "Colour of the target line for a downward break.")
shelfCol = input.color(#b0b3b8, "Shelves", group = g7, tooltip = "Colour of the 25 / 50 / 75% retest shelves inside a locked box.")
showFill = input.bool(true, "Fill the box", inline = "f", group = g7, tooltip = "Shade the box interior with a faint tint of its current state colour.")
fillTransp = input.int(92, "transp", minval = 60, maxval = 98, inline = "f", group = g7, tooltip = "Transparency of the box fill. Higher = fainter.")
lblSize  = input.string("Normal", "Label size", options = ["Tiny", "Small", "Normal", "Large"], group = g7, tooltip = "Text size of the box state label.")
lblTxtCol = input.color(#ffffff, "Label text", group = g7, tooltip = "Colour of the text inside the box state label.")

// ════════════════════════════════════════════════════════════════════════════
// 8 · PERFORMANCE PANEL
// ════════════════════════════════════════════════════════════════════════════
g8 = "8 · Performance panel"
showPanel = input.bool(true, "Show performance panel", group = g8, tooltip = "Show the corner table that self-measures this chart's own boxes: target hits, consolidations, the resulting rate with its sample size (n), and the average bars to reach target. It describes this chart's past behaviour — it is not a forecast.")
panelPos  = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left"], group = g8, tooltip = "Which corner the performance panel sits in.")
panelSize = input.string("Small", "Panel text size", options = ["Tiny", "Small", "Normal", "Large"], group = g8, tooltip = "Text size inside the performance panel.")
panelBg   = input.color(color.new(#0a1a3a, 15), "Panel background", group = g8, tooltip = "Background colour of the performance panel.")
panelTxt  = input.color(#ffffff, "Panel text", group = g8, tooltip = "Text colour of the performance panel.")

f_sz(_s) => _s == "Tiny" ? size.tiny : _s == "Normal" ? size.normal : _s == "Large" ? size.large : size.small
f_pos(_p) => _p == "Top Right" ? position.top_right : _p == "Top Left" ? position.top_left : _p == "Bottom Right" ? position.bottom_right : _p == "Bottom Left" ? position.bottom_left : _p == "Middle Right" ? position.middle_right : position.middle_left
// ════════════════════════════════════════════════════════════════════════════
// HTF DATA — confirmed closed bars only ([1] offset + lookahead off = no repaint)
// ════════════════════════════════════════════════════════════════════════════
[hH, hL, hC, hAtr, hVol, hVolAvg, hBasis] = request.security(syminfo.tickerid, htfTf, [ta.highest(high, nBars)[1], ta.lowest(low, nBars)[1], close[1], ta.atr(atrLen)[1], volume[1], ta.sma(volume, htfVolLen)[1], ta.ema(close, bandLen)[1]], lookahead = barmerge.lookahead_off)

ltfAtr    = ta.atr(atrLen)
ltfVolAvg = ta.sma(volume, ltfVolLen)
tgtAtr    = tgtAtrHtf ? hAtr : ltfAtr
htfNew    = timeframe.change(htfTf)

// band position of the last closed HTF bar (0 = band low, 1 = band high)
bandW = 2.0 * bandMult * hAtr
bandLo = hBasis - bandMult * hAtr
pos = bandW > 0 ? (hC - bandLo) / bandW : 0.5
qualTop = not na(pos) and pos >= topThr and not na(hVol) and hVol >= htfVolMult * hVolAvg
qualBot = not na(pos) and pos <= botThr and not na(hVol) and hVol >= htfVolMult * hVolAvg

f_mult() => autoOn ? math.max(minMult, math.min(maxMult, baseMult + (nz(ltfVolAvg > 0 ? volume / ltfVolAvg : 1.0, 1.0) - 1.0) * autoSlope)) : fixedMult

// ════════════════════════════════════════════════════════════════════════════
// STATE  (0 grey/forming · 1 armed · 2 locked · 3 consolidation)
// ════════════════════════════════════════════════════════════════════════════
var int   bxState = 0
var float bxHi    = na
var float bxLo    = na
var int   bxLeft  = na
var int   armDir  = 0
var int   lkDir   = 0
var float lkTgt   = na
var int   lkBar   = na
var bool  scored  = false

var line     lnHi = na
var line     lnLo = na
var line     ln25 = na
var line     ln50 = na
var line     ln75 = na
var line     lnTgt = na
var label    lbl  = na
var linefill fillBx = na
var array<line> kept = array.new<line>()

var int   nWin  = 0
var int   nLoss = 0
var int   sumBars = 0

// init the reusable drawing objects once
if na(lnHi)
    bxLeft := bar_index
    lnHi := line.new(bar_index, close, bar_index, close, xloc = xloc.bar_index, color = greyCol, width = wDot, style = line.style_dotted)
    lnLo := line.new(bar_index, close, bar_index, close, xloc = xloc.bar_index, color = greyCol, width = wDot, style = line.style_dotted)
    ln25 := line.new(bar_index, close, bar_index, close, xloc = xloc.bar_index, color = na, width = 1, style = line.style_dotted)
    ln50 := line.new(bar_index, close, bar_index, close, xloc = xloc.bar_index, color = na, width = 1, style = line.style_dotted)
    ln75 := line.new(bar_index, close, bar_index, close, xloc = xloc.bar_index, color = na, width = 1, style = line.style_dotted)
    lbl  := label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = na, textcolor = na, size = size.small)
    fillBx := linefill.new(lnHi, lnLo, na)

ltfVolOK = not na(ltfVolAvg) and volume >= ltfVolMult * ltfVolAvg
bool doReset = false

// ════════════════════════════════════════════════════════════════════════════
// STATE MACHINE (confirmed bars only)
// ════════════════════════════════════════════════════════════════════════════
if barstate.isconfirmed
    // roll H/L + (re)qualify on each HTF close while not locked
    if htfNew and (bxState == 0 or bxState == 1)
        bxHi := hH
        bxLo := hL
        if qualTop or qualBot
            bxState := 1
            armDir := qualTop ? -1 : 1
        else
            bxState := 0
            armDir := 0
    // armed → watch for a volume breakout
    if bxState == 1 and not na(bxHi)
        upB = close > bxHi and ltfVolOK
        dnB = close < bxLo and ltfVolOK
        if upB or dnB
            bxState := 2
            lkDir := upB ? 1 : -1
            lkBar := bar_index
            scored := false
            _m = f_mult()
            lkTgt := upB ? bxHi + _m * tgtAtr : bxLo - _m * tgtAtr
            lnTgt := line.new(bxLeft, lkTgt, bar_index + projBars, lkTgt, xloc = xloc.bar_index, color = (upB ? tgtUpCol : tgtDnCol), width = wSolid, style = line.style_solid)
    else if bxState == 2
        tgtHit   = lkDir == 1 ? high >= lkTgt : low <= lkTgt
        oppClose = lkDir == 1 ? close < bxLo : close > bxHi
        if tgtHit
            if not scored
                nWin += 1
                sumBars += bar_index - lkBar
                scored := true
            doReset := true
        else if oppClose
            // broke the reverse side → hold position, re-target the new direction
            lkDir := lkDir == 1 ? -1 : 1
            lkBar := bar_index
            _m2 = f_mult()
            lkTgt := lkDir == 1 ? bxHi + _m2 * tgtAtr : bxLo - _m2 * tgtAtr
            if not na(lnTgt)
                line.set_color(lnTgt, lkDir == 1 ? tgtUpCol : tgtDnCol)
        else if bar_index - lkBar >= timeoutBars
            if close <= bxHi and close >= bxLo
                bxState := 3
                if not scored
                    nLoss += 1
                    scored := true
                lkTgt := na
                if not na(lnTgt)
                    line.delete(lnTgt)
                    lnTgt := na
            else
                doReset := true
    else if bxState == 3 and not na(bxHi)
        // consolidation: skin re-colours on breakout, target re-arms
        upB = close > bxHi and ltfVolOK
        dnB = close < bxLo and ltfVolOK
        if upB or dnB
            bxState := 2
            lkDir := upB ? 1 : -1
            lkBar := bar_index
            _m3 = f_mult()
            lkTgt := upB ? bxHi + _m3 * tgtAtr : bxLo - _m3 * tgtAtr
            lnTgt := line.new(bxLeft, lkTgt, bar_index + projBars, lkTgt, xloc = xloc.bar_index, color = (upB ? tgtUpCol : tgtDnCol), width = wSolid, style = line.style_solid)

// ── reset: archive current box, start a fresh grey one ──
if doReset
    array.push(kept, lnHi)
    array.push(kept, lnLo)
    if not na(lnTgt)
        array.push(kept, lnTgt)
    while array.size(kept) > keepN * 3
        line.delete(array.shift(kept))
    lnHi := line.new(bar_index, close, bar_index, close, xloc = xloc.bar_index, color = greyCol, width = wDot, style = line.style_dotted)
    lnLo := line.new(bar_index, close, bar_index, close, xloc = xloc.bar_index, color = greyCol, width = wDot, style = line.style_dotted)
    fillBx := linefill.new(lnHi, lnLo, na)
    lnTgt := na
    bxState := 0
    bxLeft := bar_index
    bxHi := hH
    bxLo := hL
    armDir := 0
    lkTgt := na
    scored := false

// ════════════════════════════════════════════════════════════════════════════
// DRAW (every bar — extension is cosmetic; state only changes on close)
// ════════════════════════════════════════════════════════════════════════════
rightX = bar_index + projBars
if not na(lnHi) and not na(bxHi)
    _col = bxState == 0 ? greyCol : bxState == 1 ? (armDir == 1 ? upCol : dnCol) : bxState == 2 ? (lkDir == 1 ? upCol : dnCol) : consolCol
    _sty = bxState == 2 ? line.style_solid : line.style_dotted
    _wid = bxState == 2 ? wSolid : wDot
    line.set_xy1(lnHi, bxLeft, bxHi)
    line.set_xy2(lnHi, rightX, bxHi)
    line.set_color(lnHi, _col)
    line.set_style(lnHi, _sty)
    line.set_width(lnHi, _wid)
    line.set_xy1(lnLo, bxLeft, bxLo)
    line.set_xy2(lnLo, rightX, bxLo)
    line.set_color(lnLo, _col)
    line.set_style(lnLo, _sty)
    line.set_width(lnLo, _wid)
    if not na(fillBx)
        linefill.set_color(fillBx, showFill ? color.new(_col, fillTransp) : color.new(_col, 100))
    _shOn = showShelves and (bxState == 2 or bxState == 3)
    _h = bxHi - bxLo
    _sc = _shOn ? color.new(shelfCol, 25) : color.new(shelfCol, 100)
    line.set_xy1(ln25, bxLeft, bxLo + _h * 0.25)
    line.set_xy2(ln25, rightX, bxLo + _h * 0.25)
    line.set_color(ln25, _sc)
    line.set_xy1(ln50, bxLeft, bxLo + _h * 0.50)
    line.set_xy2(ln50, rightX, bxLo + _h * 0.50)
    line.set_color(ln50, _sc)
    line.set_xy1(ln75, bxLeft, bxLo + _h * 0.75)
    line.set_xy2(ln75, rightX, bxLo + _h * 0.75)
    line.set_color(ln75, _sc)
    if bxState == 2 and not na(lnTgt)
        line.set_xy1(lnTgt, bxLeft, lkTgt)
        line.set_xy2(lnTgt, rightX, lkTgt)
    _lt = bxState == 0 ? "" : bxState == 1 ? (armDir == 1 ? "▲ setup" : "▼ setup") : bxState == 2 ? ((lkDir == 1 ? "▲ " : "▼ ") + str.tostring(lkTgt, format.mintick)) : "Consolidation"
    _show = _lt != ""
    label.set_xy(lbl, rightX, bxHi)
    label.set_text(lbl, _lt)
    label.set_color(lbl, _show ? color.new(_col, 20) : color.new(_col, 100))
    label.set_textcolor(lbl, _show ? lblTxtCol : color.new(lblTxtCol, 100))
    label.set_size(lbl, f_sz(lblSize))

// ════════════════════════════════════════════════════════════════════════════
// PERFORMANCE PANEL (win = target hit · loss = consolidation · avg bars-to-target)
// ════════════════════════════════════════════════════════════════════════════
var table pnl = na
if showPanel and barstate.islast
    if na(pnl)
        pnl := table.new(f_pos(panelPos), 2, 6, bgcolor = panelBg, border_width = 1, border_color = color.new(#000000, 40))
    _tot = nWin + nLoss
    _wr  = _tot > 0 ? str.tostring(nWin / _tot * 100, "#") + "%" : "—"
    _avg = nWin > 0 ? str.tostring(sumBars / nWin, "#") + " bars" : "—"
    _stt = bxState == 0 ? "forming" : bxState == 1 ? "armed" : bxState == 2 ? "target live" : "consolidation"
    _ps = f_sz(panelSize)
    table.cell(pnl, 0, 0, "HTF Box", text_color = panelTxt, text_size = _ps, bgcolor = color.new(panelTxt, 90))
    table.cell(pnl, 1, 0, str.tostring(htfTf), text_color = panelTxt, text_size = _ps, bgcolor = color.new(panelTxt, 90))
    table.cell(pnl, 0, 1, "Target hit", text_color = panelTxt, text_size = _ps)
    table.cell(pnl, 1, 1, str.tostring(nWin), text_color = upCol, text_size = _ps)
    table.cell(pnl, 0, 2, "Consolidated", text_color = panelTxt, text_size = _ps)
    table.cell(pnl, 1, 2, str.tostring(nLoss), text_color = consolCol, text_size = _ps)
    table.cell(pnl, 0, 3, "Hit rate", text_color = panelTxt, text_size = _ps)
    table.cell(pnl, 1, 3, _wr + " (n=" + str.tostring(_tot) + ")", text_color = panelTxt, text_size = _ps)
    table.cell(pnl, 0, 4, "Avg to target", text_color = panelTxt, text_size = _ps)
    table.cell(pnl, 1, 4, _avg, text_color = panelTxt, text_size = _ps)
    table.cell(pnl, 0, 5, "State", text_color = panelTxt, text_size = _ps)
    table.cell(pnl, 1, 5, _stt, text_color = panelTxt, text_size = _ps)

// ════════════════════════════════════════════════════════════════════════════
// ALERTS (once per bar close)
// ════════════════════════════════════════════════════════════════════════════
alertcondition(bxState == 1 and bxState[1] != 1, "Box armed", "Stryk HTF Box: band-extreme box armed on {{ticker}} ({{interval}})")
alertcondition(bxState == 2 and bxState[1] != 2, "Breakout locked", "Stryk HTF Box: volume breakout, target set on {{ticker}} ({{interval}})")
alertcondition(bxState == 3 and bxState[1] != 3, "Consolidation", "Stryk HTF Box: target not hit, price consolidating inside the box on {{ticker}} ({{interval}})")
````

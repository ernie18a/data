# STRYK Market Bias

- url: https://www.tradingview.com/script/K9WQt2Y7-STRYK-Market-Bias/
- type: indicator
- pine_id: PUB;aca33096ed8b4b20a7662e0ee65a10fb
- version: 1.0

## Description

Multi-timeframe EMA-alignment dashboard: short-term, long-term, and overall bias boxes, plus an optional two-line color band.

# STRYK Market Bias

A multi-timeframe EMA-alignment dashboard. It reads one moving average across several timeframes at once and summarizes how those timeframes line up into two composite readings — a short-term read and a long-term read — plus a combined overall read. It can also draw a two-line band on the chart. This is a descriptive context tool for discretionary analysis. It does not generate buy or sell signals.

## What it does

For each of several timeframes, it checks whether price is above or below that timeframe's EMA. Above reads bull, below reads bear. Those individual reads are combined into a weighted score for each group and shown as simple BULL / BEAR / NEUTRAL boxes, so you can see multi-timeframe alignment at a glance instead of loading the same moving average on seven separate charts.

## How it works

**One EMA, many timeframes.** A single EMA length (default 233) is applied to each timeframe: fast frames (5m / 15m / 30m, with an optional 1m) and slow frames (1h / 2h / 4h). All higher-timeframe values are taken from the last closed bar by default, so they do not repaint.

**Each frame votes.** Price above its EMA = +1 (bull), below = −1 (bear).

**Two composites, weighted differently on purpose:**

- **Short-term** emphasizes *freshness*. A fast frame that has just flipped receives a temporary extra weight that decays back to normal over a set number of bars, so recent changes on the fast frames carry more emphasis than stale ones.
- **Long-term** emphasizes *persistence*. The longer a slow frame has held its side, the more its vote weighs (up to a cap), so a slow frame that has stayed on one side for a long time carries more of the read.

Each group's score runs from −100 to +100 and is mapped to BULL / BEAR / NEUTRAL with an adjustable threshold. The **Overall** box is a blend of the two (default 60% long-term / 40% short-term, adjustable). A **fresh flag** lights when a fast frame flips within the fresh window in the same direction as the short-term read.

**Per-frame grid (optional).** Expand it to see every timeframe's own arrow and its own bars-since-flip, so you can tell which timeframe is driving or breaking the score.

## The band (optional)

Pick any two timeframes (default 1m and 4h). The EMA of each is drawn as a line and the area between them is filled. The band and lines are colored by where price sits relative to the two lines: above both, between them, or below both. A **fade** option holds the current color until price stays in a new zone for a set number of bars, so a brief poke into the band does not immediately change the color.

## How to use it

Treat it as context, not instructions. When all the boxes agree and sit at their extremes, the timeframes are simply aligned. The more informative moments are when the short-term and long-term reads diverge, or when a fresh flip appears against the current read. Use the per-frame grid to see exactly which timeframe is responsible.

Everything is adjustable: the EMA length and source, which timeframes are used, the weighting mode per group, the fresh and persistence settings, the threshold and overall blend, and the band and its colors, transparency and fade.

## Notes

- With non-repaint on (default), higher-timeframe reads are delayed by one bar of that timeframe in exchange for values that do not change after the fact. Turn it off for live intrabar values, which repaint.
- Timeframes smaller than your chart timeframe are sampled at chart resolution.
- Alerts are provided for short-term, long-term, and overall state changes.

## Disclaimer

This script is for informational and educational purposes only. It does not produce buy or sell signals and makes no claim about future results. Do your own analysis and manage your own risk.

## Source Code

````pine
//@version=6
// =============================================================================
//  STRYK MARKET BIAS  ·  Es-Sniper
//  Dual multi-timeframe EMA-alignment dashboard.
//  Each frame votes bull/bear by price vs its own EMA. Two weighted composites:
//    SHORT-TERM  : fast frames, FRESH flips weighted up (the transition window).
//    LONG-TERM   : slow frames, PERSISTENCE weighted up (longer held = heavier).
//  Output: one score in [-100,+100] per side -> a single BULL / BEAR / NEUTRAL box.
//  Descriptive alignment read of the EMAs. Not a signal. No plots (table only).
// =============================================================================
indicator("STRYK Market Bias", overlay = true)

// ---------- palette ----------
cBull = input.color(#26a69a, "Bull", inline = "col", group = "Display")
cBear = input.color(#ef5350, "Bear", inline = "col", group = "Display")
cNeut = input.color(#787b86, "Neutral", inline = "col", group = "Display",
     tooltip = "Colors used for the BULL / BEAR / NEUTRAL states shown in the boxes, arrows and text.")
cTxt  = color.white
cHdr  = input.color(#1c2230, "Header background", group = "Display",
     tooltip = "Background color of the table's header rows.")

// ---------- engine ----------
emaLen  = input.int(233, "EMA length", minval = 1, group = "Engine",
     tooltip = "Length of the EMA calculated on every timeframe. Price above that EMA = that frame reads bull; below = bear. This one length is reused everywhere.")
srcIn   = input.source(close, "Source", group = "Engine",
     tooltip = "Price series the EMA is built from (default: close).")
confirm = input.bool(true, "Non-repaint (use last CLOSED HTF bar)", group = "Engine",
     tooltip = "On (recommended): each higher-timeframe reading uses the last CLOSED bar, so values do not change after the fact — honest but delayed by one HTF bar. Off: uses the still-forming bar (current but repaints intrabar).")

// ---------- band ----------
showBand  = input.bool(true, "Show band", group = "Band",
     tooltip = "Draw the two EMA lines and the color-filled band between them on the price chart.")
bandTf1   = input.timeframe("1",   "Band line 1 timeframe", group = "Band",
     tooltip = "Timeframe for the first band line. The EMA (length above) is calculated on this timeframe. Default 1 minute.")
bandTf2   = input.timeframe("240", "Band line 2 timeframe", group = "Band",
     tooltip = "Timeframe for the second band line. Default 240 minutes (4h). The band is the area between the two lines, whichever is higher.")
cAbove    = input.color(#26a69a, "Above", inline = "bc", group = "Band")
cInside   = input.color(#2962ff, "Inside", inline = "bc", group = "Band")
cBelow    = input.color(#ef5350, "Below",  inline = "bc", group = "Band",
     tooltip = "Band color by where price sits: ABOVE both lines, INSIDE (between the two lines), or BELOW both lines.")
cLine     = input.color(#b2b5be, "Line color (when not following band)", group = "Band",
     tooltip = "Color of the two lines when 'Lines follow band color' is turned off.")
bandTransp = input.int(82, "Fill transparency", minval = 0, maxval = 100, group = "Band",
     tooltip = "Transparency of the band fill. 0 = solid, 100 = invisible.")
lineW     = input.int(1, "Line width", minval = 1, maxval = 4, group = "Band",
     tooltip = "Thickness of the two band lines.")
bandSmooth = input.bool(true, "Smooth band lines", group = "Band",
     tooltip = "De-steps the higher-timeframe lines. A higher-TF EMA comes back as a staircase (it only updates once per HTF bar); a short EMA on the chart timeframe smooths those steps into a continuous curve. Same de-step approach as Stryk:ACE. Adds a little lag.")
smoothLen = input.int(8, "Smoothing length", minval = 1, group = "Band",
     tooltip = "Length of the de-step EMA applied to the two band lines. Higher = smoother and slightly more lag.")
lineFollow = input.bool(true, "Lines follow band color", group = "Band",
     tooltip = "When 'Show band' is on: the lines take the band's current color (green/blue/red). Otherwise the lines use the fixed 'Line color' above with no flip.")
showLines = input.bool(true, "Show lines", group = "Band",
     tooltip = "Plot the two EMA lines. With 'Show band' off, the lines still plot in the solid 'Line color' and do NOT change color.")
fadeBars  = input.int(3, "Fade (bars to confirm flip)", minval = 1, group = "Band",
     tooltip = "The band keeps its current color until price holds a new zone for this many bars. So a brief dip into the band does not instantly change the color — it must stick. 1 = instant, higher = slower to give up the current read.")

// ---------- short-term frames ----------
useF1 = input.bool(false, "Include 1m", inline = "s0", group = "Short-term frames",
     tooltip = "Add the 1-minute frame to the short-term score. It is the noisiest frame, so it is off by default.")
tf1   = input.timeframe("1",  "", inline = "s0", group = "Short-term frames")
tf5   = input.timeframe("5",  "Fast frames", inline = "s1", group = "Short-term frames")
tf15  = input.timeframe("15", "", inline = "s1", group = "Short-term frames")
tf30  = input.timeframe("30", "", inline = "s1", group = "Short-term frames",
     tooltip = "The fast timeframes that make up the SHORT-TERM score.")

// ---------- long-term frames ----------
tf60  = input.timeframe("60",  "Slow frames", inline = "l1", group = "Long-term frames")
tf120 = input.timeframe("120", "", inline = "l1", group = "Long-term frames")
tf240 = input.timeframe("240", "", inline = "l1", group = "Long-term frames",
     tooltip = "The slow timeframes that make up the LONG-TERM score.")

// ---------- scoring ----------
stWmode    = input.string("Rank", "Short-term weighting", options = ["Equal", "Rank", "Minutes"], group = "Scoring",
     tooltip = "How the fast frames are weighted relative to each other. Equal = every frame the same; Rank = larger frame counts a bit more; Minutes = weighted by timeframe length.")
ltWmode    = input.string("Rank", "Long-term weighting",  options = ["Equal", "Rank", "Minutes"], group = "Scoring",
     tooltip = "How the slow frames are weighted relative to each other. Equal / Rank / Minutes, same idea as short-term.")
stBoost    = input.float(1.0, "ST fresh-flip boost (x)", minval = 0.0, step = 0.25, group = "Scoring",
     tooltip = "Extra weight given to a fast frame that JUST flipped, on top of its base weight. Decays back to normal over the fresh window. 0 = no boost.")
stFresh    = input.int(5, "ST fresh window (bars)", minval = 1, group = "Scoring",
     tooltip = "How many bars a fast-frame flip is treated as 'fresh'. Drives the fresh boost, the * marker in the grid, and the FRESH flag.")
persistDiv = input.float(20.0, "LT persistence divisor", minval = 1.0, group = "Scoring",
     tooltip = "Controls how fast a slow frame's weight grows the longer it has held its side. Smaller = persistence matters more.")
persistCap = input.float(3.0, "LT persistence cap (x)", minval = 1.0, group = "Scoring",
     tooltip = "Maximum weight multiplier a slow frame can reach from persistence, so one long-held frame cannot completely dominate.")
bullTh     = input.float(33.0, "Bull / Bear threshold", minval = 1.0, maxval = 99.0, group = "Scoring",
     tooltip = "A score past +this shows BULL, past -this shows BEAR, anything in between shows NEUTRAL.")
netLTw     = input.float(0.6, "Overall: long-term weight", minval = 0.0, maxval = 1.0, step = 0.1, group = "Scoring",
     tooltip = "How the OVERALL box blends the two sides. 1 = all long-term, 0 = all short-term, 0.6 = 60% long / 40% short.")

// ---------- table ----------
posSel  = input.string("Top Right", "Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = "Display",
     tooltip = "Where the dashboard table sits on the chart.")
sizeSel = input.string("Normal", "Text size", options = ["Tiny", "Small", "Normal", "Large"], group = "Display",
     tooltip = "Text size of the dashboard table.")
layout  = input.string("Stacked", "Layout", options = ["Stacked", "Horizontal"], group = "Display",
     tooltip = "Stacked: the three bias boxes on top, the per-frame grid below them. Horizontal: bias boxes on the left, per-frame grid on the right.")
showFrames = input.bool(false, "Expand per-frame grid", group = "Display",
     tooltip = "Show each timeframe's own direction (arrow) and bars-since-flip below the bias boxes. A * marks a frame still inside the fresh window.")

// =============================================================================
//  per-frame bias, computed IN-CONTEXT so age = that frame's own bars
// =============================================================================
f_bias(_len, _src) =>
    e = ta.ema(_src, _len)
    d = _src >= e ? 1 : -1
    a = ta.barssince(d != d[1])
    [d, a]

// pull each frame; [1] on the result = last CLOSED state (non-repaint) when confirm is on
req(_tf) =>
    [d0, a0] = request.security(syminfo.tickerid, _tf, f_bias(emaLen, srcIn), lookahead = barmerge.lookahead_off)
    d = confirm ? d0[1] : d0
    a = confirm ? a0[1] : a0
    [nz(d, 0), nz(a, 0)]

// EMA value on a chosen TF (for the band lines)
f_emav(_len, _src) => ta.ema(_src, _len)
reqv(_tf) =>
    v0 = request.security(syminfo.tickerid, _tf, f_emav(emaLen, srcIn), lookahead = barmerge.lookahead_off)
    confirm ? v0[1] : v0

[d1,  a1]  = req(tf1)
[d5,  a5]  = req(tf5)
[d15, a15] = req(tf15)
[d30, a30] = req(tf30)
[d60, a60] = req(tf60)
[d120,a120]= req(tf120)
[d240,a240]= req(tf240)

// =============================================================================
//  weighting + confidence
// =============================================================================
f_w(_mode, _rank, _mins) =>
    _mode == "Equal" ? 1.0 : _mode == "Rank" ? _rank : _mins

// short term: fresh flip boosted, decays to 1x over the fresh window
f_st(_d, _a, _rank, _mins) =>
    w  = f_w(stWmode, _rank, _mins)
    cf = 1.0 + stBoost * (_a <= stFresh ? (1.0 - _a / math.max(stFresh, 1)) : 0.0)
    [_d * w * cf, w * cf]

// long term: persistence boosted, capped
f_lt(_d, _a, _rank, _mins) =>
    w  = f_w(ltWmode, _rank, _mins)
    cf = math.min(1.0 + _a / persistDiv, persistCap)
    [_d * w * cf, w * cf]

[ns1, ds1] = f_st(d1,  a1,  1, 1)
[ns5, ds5] = f_st(d5,  a5,  2, 5)
[ns15,ds15]= f_st(d15, a15, 3, 15)
[ns30,ds30]= f_st(d30, a30, 4, 30)

stNum = (useF1 ? ns1 : 0.0) + ns5 + ns15 + ns30
stDen = (useF1 ? ds1 : 0.0) + ds5 + ds15 + ds30
scoreST = stDen > 0 ? 100.0 * stNum / stDen : 0.0

[nl60, dl60]  = f_lt(d60,  a60,  1, 60)
[nl120,dl120] = f_lt(d120, a120, 2, 120)
[nl240,dl240] = f_lt(d240, a240, 3, 240)

ltNum = nl60 + nl120 + nl240
ltDen = dl60 + dl120 + dl240
scoreLT = ltDen > 0 ? 100.0 * ltNum / ltDen : 0.0

// raw alignment counts
stCount = (useF1 ? 4 : 3)
stBull  = (useF1 and d1 == 1 ? 1 : 0) + (d5 == 1 ? 1 : 0) + (d15 == 1 ? 1 : 0) + (d30 == 1 ? 1 : 0)
ltBull  = (d60 == 1 ? 1 : 0) + (d120 == 1 ? 1 : 0) + (d240 == 1 ? 1 : 0)

// overall = blend of the two composites (long-term leaning by default)
scoreNET = netLTw * scoreLT + (1.0 - netLTw) * scoreST
netBull  = stBull + ltBull
netCount = stCount + 3

// fresh-flip flag: a fast frame flipped within the window AND agrees with the ST tilt
stSign  = scoreST >= 0 ? 1 : -1
stFlash = (useF1 and a1 <= stFresh and d1 == stSign)
     or (a5  <= stFresh and d5  == stSign)
     or (a15 <= stFresh and d15 == stSign)
     or (a30 <= stFresh and d30 == stSign)

// =============================================================================
//  state mapping + alerts
// =============================================================================
f_state(_s) => _s >= bullTh ? 1 : _s <= -bullTh ? -1 : 0
stState = f_state(scoreST)
ltState = f_state(scoreLT)
netState = f_state(scoreNET)

f_lbl(_st) => _st == 1 ? "▲ BULL" : _st == -1 ? "▼ BEAR" : "– NEUTRAL"
f_clr(_st) => _st == 1 ? cBull : _st == -1 ? cBear : cNeut
f_num(_s)  => (_s >= 0 ? "+" : "") + str.tostring(math.round(_s))

alertcondition(ta.change(stState) != 0, "ST bias flip", "STRYK short-term bias changed")
alertcondition(ta.change(ltState) != 0, "LT bias flip", "STRYK long-term bias changed")
alertcondition(ta.change(netState) != 0, "Overall bias flip", "STRYK overall bias changed")

// =============================================================================
//  band: two EMA lines on chosen TFs, 3-color fill by price position
//    close above both -> green, between the lines -> blue, below both -> red
// =============================================================================
emaA_raw = reqv(bandTf1)
emaB_raw = reqv(bandTf2)
// ACE-style HTF de-step: the request.security line is a staircase; a short chart-side
// EMA over it smooths those steps into a continuous curve. ta.ema runs every bar.
emaA_sm = ta.ema(emaA_raw, smoothLen)
emaB_sm = ta.ema(emaB_raw, smoothLen)
emaA = bandSmooth ? emaA_sm : emaA_raw
emaB = bandSmooth ? emaB_sm : emaB_raw
bandTop = math.max(emaA, emaB)
bandBot = math.min(emaA, emaB)

// raw zone: 1 = above band (green), -1 = below band (red), 0 = inside (blue)
rawPos = close > bandTop ? 1 : close < bandBot ? -1 : 0
// fade / hysteresis: a new zone must hold for `fadeBars` bars before the color flips
var int rawRun = 1
rawRun := (na(rawPos[1]) or rawPos != rawPos[1]) ? 1 : rawRun + 1
var int dispPos = na
dispPos := na(dispPos) ? rawPos : (rawPos != dispPos and rawRun >= fadeBars ? rawPos : dispPos)

bandCol = dispPos == 1 ? cAbove : dispPos == -1 ? cBelow : cInside
// lines flip color only while the band is shown; otherwise solid Line color
lnCol   = (showBand and lineFollow) ? bandCol : cLine

// lines plot independently of the band; value always present so the fill still has edges
pA = plot(emaA, "Band line 1", color = showLines ? lnCol : na, linewidth = lineW)
pB = plot(emaB, "Band line 2", color = showLines ? lnCol : na, linewidth = lineW)
fill(pA, pB, color = showBand ? color.new(bandCol, bandTransp) : na, title = "Band fill")

// =============================================================================
//  table (built once on the last bar; 0 plots)
// =============================================================================
f_pos(_p) =>
    _p == "Top Left" ? position.top_left :
     _p == "Bottom Right" ? position.bottom_right :
     _p == "Bottom Left" ? position.bottom_left :
     _p == "Middle Right" ? position.middle_right : position.top_right

f_sz(_s) =>
    _s == "Tiny" ? size.tiny : _s == "Small" ? size.small : _s == "Large" ? size.large : size.normal

// pretty timeframe name: "5"->"5m", "60"->"1h", "240"->"4h"
f_tfname(_tf) =>
    m = str.tonumber(_tf)
    na(m) ? _tf : m >= 60 and m % 60 == 0 ? str.tostring(m / 60) + "h" : str.tostring(m) + "m"

var table t = table.new(f_pos(posSel), 7, 14, border_width = 1, border_color = cHdr)

if barstate.islast
    tsz = f_sz(sizeSel)
    // title row
    table.cell(t, 0, 0, "MARKET BIAS", text_color = cTxt, bgcolor = cHdr, text_size = tsz)
    table.cell(t, 1, 0, "", bgcolor = cHdr, text_size = tsz)
    table.cell(t, 2, 0, str.tostring(emaLen) + " EMA", text_color = cTxt, bgcolor = cHdr, text_size = tsz)
    // column headers
    table.cell(t, 0, 1, "SHORT",   text_color = cTxt, bgcolor = cHdr, text_size = tsz)
    table.cell(t, 1, 1, "LONG",    text_color = cTxt, bgcolor = cHdr, text_size = tsz)
    table.cell(t, 2, 1, "OVERALL", text_color = cTxt, bgcolor = cHdr, text_size = tsz)
    // state label (colored)
    table.cell(t, 0, 2, f_lbl(stState),  text_color = cTxt, bgcolor = f_clr(stState),  text_size = tsz)
    table.cell(t, 1, 2, f_lbl(ltState),  text_color = cTxt, bgcolor = f_clr(ltState),  text_size = tsz)
    table.cell(t, 2, 2, f_lbl(netState), text_color = cTxt, bgcolor = f_clr(netState), text_size = tsz)
    // score
    table.cell(t, 0, 3, f_num(scoreST),  text_color = f_clr(stState),  text_size = tsz)
    table.cell(t, 1, 3, f_num(scoreLT),  text_color = f_clr(ltState),  text_size = tsz)
    table.cell(t, 2, 3, f_num(scoreNET), text_color = f_clr(netState), text_size = tsz)
    // alignment count
    table.cell(t, 0, 4, str.tostring(stBull)  + "/" + str.tostring(stCount),  text_color = cNeut, text_size = tsz)
    table.cell(t, 1, 4, str.tostring(ltBull)  + "/3",                          text_color = cNeut, text_size = tsz)
    table.cell(t, 2, 4, str.tostring(netBull) + "/" + str.tostring(netCount), text_color = cNeut, text_size = tsz)
    // fresh-flip flag (short-term only)
    table.cell(t, 0, 5, stFlash ? "⚡ FRESH" : "—",
         text_color = stFlash ? cTxt : cNeut, bgcolor = stFlash ? f_clr(stState) : na, text_size = tsz)
    table.cell(t, 1, 5, "—", text_color = cNeut, text_size = tsz)
    table.cell(t, 2, 5, "—", text_color = cNeut, text_size = tsz)
    // ---- optional per-frame breakdown ----
    if showFrames
        // horizontal -> grid to the RIGHT of the bias boxes (col 3 is a gap); stacked -> BELOW
        horiz = layout == "Horizontal"
        gc = horiz ? 4 : 0
        gr = horiz ? 0 : 6
        fLbl = array.from(f_tfname(tf1), f_tfname(tf5), f_tfname(tf15), f_tfname(tf30), f_tfname(tf60), f_tfname(tf120), f_tfname(tf240))
        fDir = array.from(d1, d5, d15, d30, d60, d120, d240)
        fAge = array.from(a1, a5, a15, a30, a60, a120, a240)
        fOn  = array.from(useF1, true, true, true, true, true, true)
        table.cell(t, gc, gr,     "FRAME", text_color = cTxt, bgcolor = cHdr, text_size = tsz)
        table.cell(t, gc + 1, gr, "DIR",   text_color = cTxt, bgcolor = cHdr, text_size = tsz)
        table.cell(t, gc + 2, gr, "BARS",  text_color = cTxt, bgcolor = cHdr, text_size = tsz)
        rw = gr + 1
        for i = 0 to 6
            if array.get(fOn, i)
                fd = array.get(fDir, i)
                fa = array.get(fAge, i)
                fresh = fa <= stFresh
                table.cell(t, gc, rw,     array.get(fLbl, i), text_color = cTxt, text_size = tsz)
                table.cell(t, gc + 1, rw, fd == 1 ? "▲" : "▼", text_color = fd == 1 ? cBull : cBear, text_size = tsz)
                table.cell(t, gc + 2, rw, str.tostring(fa) + (fresh ? " *" : ""),
                     text_color = fresh ? (fd == 1 ? cBull : cBear) : cNeut, text_size = tsz)
                rw := rw + 1
````

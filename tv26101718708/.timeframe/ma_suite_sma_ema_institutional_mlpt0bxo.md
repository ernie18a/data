# MA Suite SMA + EMA [Institutional]

- url: https://www.tradingview.com/script/mlpt0bXo-MA-Suite-SMA-EMA-Institutional/
- type: indicator
- pine_id: PUB;7412840daa544019b4383040a5b7a5e0
- version: 2.0

## Description

MA Suite SMA + EMA [Institutional]

A single overlay that replaces a whole stack of separate moving-average indicators. It plots up to 6 fully configurable SMAs and 6 EMAs side by side, with everything you need to read trend structure at a glance — and nothing you have to fight with.

Core
- 6 SMA + 6 EMA slots, each with its own enable toggle, length, color, and line width.
- Sensible institutional defaults (20 / 50 / 100 / 150 / 200) with the 20, 50 and 200 emphasized by thickness.
- Disabled lines disappear from both the chart and the status line, so the data window stays clean — you only ever see the values you actually use.

Multi-timeframe
- Compute every MA from a higher timeframe (e.g. show daily MAs while viewing an intraday chart).
- Permanent 20-week and 200-week SMA anchors that hold their value on any lower timeframe, with optional smoothing to remove the weekly "staircase."

Slope projection
- Tick ext on any line to extend it forward along its current slope — a quick look at where a moving average is heading. The 200 SMA and both weekly anchors are projected by default.

Context tools
- % distance table showing how far price sits from each active MA — fast read on stretch and mean-reversion.
- Slope coloring (lines fade when falling) and an optional bias background (price above/below the 200 SMA).
- Golden / death-cross markers, a configurable ribbon fill, and an anchored VWAP with standard-deviation bands.
- Built-in alerts for MA crosses and price/MA crossovers.

One indicator, every moving-average reference an institutional trader actually looks at.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MasterOfDesaster

//@version=6
// ============================================================================
//  MA Suite
//  6 user-defined SMAs + 6 user-defined EMAs in a single overlay.
//  Per-line enable / length / color / width / slope-extend / label, MTF calc,
//  smoothed permanent weekly anchors, golden/death-cross signals, ribbon fill,
//  anchored VWAP, % distance table, alerts.
// ============================================================================
indicator("MA Suite SMA EMA Institutional", "MA Suite", overlay = true, max_lines_count = 200, max_labels_count = 200)

// ───────────────────────────── General ─────────────────────────────
gGen = "General"
src  = input.source(close, "Source", group = gGen)
res  = input.timeframe("", "Calculation timeframe (blank = chart)", group = gGen,
     tooltip = "Render ALL moving averages from a higher timeframe (e.g. 1D, 1W) on any chart. Blank = current chart timeframe.")
_tf  = res == "" ? timeframe.period : res

f_sma(len) => request.security(syminfo.tickerid, _tf, ta.sma(src, len), lookahead = barmerge.lookahead_off)
f_ema(len) => request.security(syminfo.tickerid, _tf, ta.ema(src, len), lookahead = barmerge.lookahead_off)

// ──────────────────────── Simple Moving Averages ────────────────────────
// Row layout:  ☑enable · length · color · width · ☑extend(slope) · ☑lbl(price label)
gS = "Simple Moving Averages (SMA)"
s1On = input.bool(true,  "SMA", inline = "S1", group = gS)
s1L  = input.int(20,     "len", inline = "S1", group = gS, minval = 1)
s1C  = input.color(color.yellow, "", inline = "S1", group = gS)
s1W  = input.int(2,      "w",   inline = "S1", group = gS, minval = 1, maxval = 5)
s1X  = input.bool(false, "ext", inline = "S1", group = gS)
s1Lab = input.bool(false, "lbl", inline = "S1", group = gS)

s2On = input.bool(true,  "SMA", inline = "S2", group = gS)
s2L  = input.int(50,     "len", inline = "S2", group = gS, minval = 1)
s2C  = input.color(color.red, "", inline = "S2", group = gS)
s2W  = input.int(2,      "w",   inline = "S2", group = gS, minval = 1, maxval = 5)
s2X  = input.bool(false, "ext", inline = "S2", group = gS)
s2Lab = input.bool(false, "lbl", inline = "S2", group = gS)

s3On = input.bool(true,  "SMA", inline = "S3", group = gS)
s3L  = input.int(100,    "len", inline = "S3", group = gS, minval = 1)
s3C  = input.color(#90EE90, "", inline = "S3", group = gS)   // light green
s3W  = input.int(1,      "w",   inline = "S3", group = gS, minval = 1, maxval = 5)
s3X  = input.bool(false, "ext", inline = "S3", group = gS)
s3Lab = input.bool(false, "lbl", inline = "S3", group = gS)

s4On = input.bool(true,  "SMA", inline = "S4", group = gS)
s4L  = input.int(150,    "len", inline = "S4", group = gS, minval = 1)
s4C  = input.color(#ADD8E6, "", inline = "S4", group = gS)   // light blue
s4W  = input.int(1,      "w",   inline = "S4", group = gS, minval = 1, maxval = 5)
s4X  = input.bool(false, "ext", inline = "S4", group = gS)
s4Lab = input.bool(false, "lbl", inline = "S4", group = gS)

s5On = input.bool(true,  "SMA", inline = "S5", group = gS)
s5L  = input.int(200,    "len", inline = "S5", group = gS, minval = 1)
s5C  = input.color(#0000CD, "", inline = "S5", group = gS)   // medium blue (one step lighter than dark blue)
s5W  = input.int(3,      "w",   inline = "S5", group = gS, minval = 1, maxval = 5)
s5X  = input.bool(true,  "ext", inline = "S5", group = gS)   // 200 SMA extended by default
s5Lab = input.bool(true,  "lbl", inline = "S5", group = gS)   // 200 SMA labeled by default

s6On = input.bool(false, "SMA", inline = "S6", group = gS)
s6L  = input.int(250,    "len", inline = "S6", group = gS, minval = 1)
s6C  = input.color(color.gray, "", inline = "S6", group = gS)
s6W  = input.int(1,      "w",   inline = "S6", group = gS, minval = 1, maxval = 5)
s6X  = input.bool(false, "ext", inline = "S6", group = gS)
s6Lab = input.bool(false, "lbl", inline = "S6", group = gS)

s1 = f_sma(s1L), s2 = f_sma(s2L), s3 = f_sma(s3L)
s4 = f_sma(s4L), s5 = f_sma(s5L), s6 = f_sma(s6L)

// ──────────────────── Exponential Moving Averages ────────────────────
gE = "Exponential Moving Averages (EMA)"
e1On = input.bool(true,  "EMA", inline = "E1", group = gE)
e1L  = input.int(20,     "len", inline = "E1", group = gE, minval = 1)
e1C  = input.color(#FF9800, "", inline = "E1", group = gE)   // orange
e1W  = input.int(1,      "w",   inline = "E1", group = gE, minval = 1, maxval = 5)
e1X  = input.bool(false, "ext", inline = "E1", group = gE)
e1Lab = input.bool(false, "lbl", inline = "E1", group = gE)

e2On = input.bool(true,  "EMA", inline = "E2", group = gE)
e2L  = input.int(50,     "len", inline = "E2", group = gE, minval = 1)
e2C  = input.color(#E91E63, "", inline = "E2", group = gE)   // pink/magenta
e2W  = input.int(1,      "w",   inline = "E2", group = gE, minval = 1, maxval = 5)
e2X  = input.bool(false, "ext", inline = "E2", group = gE)
e2Lab = input.bool(false, "lbl", inline = "E2", group = gE)

e3On = input.bool(true,  "EMA", inline = "E3", group = gE)
e3L  = input.int(100,    "len", inline = "E3", group = gE, minval = 1)
e3C  = input.color(#009688, "", inline = "E3", group = gE)   // teal
e3W  = input.int(1,      "w",   inline = "E3", group = gE, minval = 1, maxval = 5)
e3X  = input.bool(false, "ext", inline = "E3", group = gE)
e3Lab = input.bool(false, "lbl", inline = "E3", group = gE)

e4On = input.bool(true,  "EMA", inline = "E4", group = gE)
e4L  = input.int(150,    "len", inline = "E4", group = gE, minval = 1)
e4C  = input.color(#00BCD4, "", inline = "E4", group = gE)   // cyan
e4W  = input.int(1,      "w",   inline = "E4", group = gE, minval = 1, maxval = 5)
e4X  = input.bool(false, "ext", inline = "E4", group = gE)
e4Lab = input.bool(false, "lbl", inline = "E4", group = gE)

e5On = input.bool(true,  "EMA", inline = "E5", group = gE)
e5L  = input.int(200,    "len", inline = "E5", group = gE, minval = 1)
e5C  = input.color(#673AB7, "", inline = "E5", group = gE)   // deep purple
e5W  = input.int(1,      "w",   inline = "E5", group = gE, minval = 1, maxval = 5)
e5X  = input.bool(false, "ext", inline = "E5", group = gE)
e5Lab = input.bool(false, "lbl", inline = "E5", group = gE)

e6On = input.bool(false, "EMA", inline = "E6", group = gE)
e6L  = input.int(250,    "len", inline = "E6", group = gE, minval = 1)
e6C  = input.color(color.silver, "", inline = "E6", group = gE)
e6W  = input.int(1,      "w",   inline = "E6", group = gE, minval = 1, maxval = 5)
e6X  = input.bool(false, "ext", inline = "E6", group = gE)
e6Lab = input.bool(false, "lbl", inline = "E6", group = gE)

e1 = f_ema(e1L), e2 = f_ema(e2L), e3 = f_ema(e3L)
e4 = f_ema(e4L), e5 = f_ema(e5L), e6 = f_ema(e6L)

// ───────────────────────── Weekly Anchors (permanent) ─────────────────────────
gW       = "Weekly Anchors (multi-timeframe)"
w20On    = input.bool(true,  "20-week SMA",  inline = "W1", group = gW)
w20C     = input.color(color.orange, "", inline = "W1", group = gW)
w20X     = input.bool(true,  "ext", inline = "W1", group = gW)
w20Lab   = input.bool(true,  "lbl", inline = "W1", group = gW)
w50On    = input.bool(true,  "50-week SMA",  inline = "W3", group = gW)
w50C     = input.color(color.purple, "", inline = "W3", group = gW)
w50X     = input.bool(true,  "ext", inline = "W3", group = gW)
w50Lab   = input.bool(true,  "lbl", inline = "W3", group = gW)
w200On   = input.bool(true,  "200-week SMA", inline = "W2", group = gW)
w200C    = input.color(color.maroon, "", inline = "W2", group = gW)
w200X    = input.bool(true,  "ext", inline = "W2", group = gW)
w200Lab  = input.bool(true,  "lbl", inline = "W2", group = gW)
wSmoothOn  = input.bool(true, "Smooth weekly anchors on lower timeframes", group = gW,
     tooltip = "On lower timeframes a weekly value updates in steps (staircase). This applies a short SMA to the weekly series so the anchor draws as a smooth line.")
wSmoothLen = input.int(10, "Smoothing length", group = gW, minval = 1, maxval = 200)

sma20w_raw  = request.security(syminfo.tickerid, "1W", ta.sma(close, 20),  lookahead = barmerge.lookahead_off)
sma50w_raw  = request.security(syminfo.tickerid, "1W", ta.sma(close, 50),  lookahead = barmerge.lookahead_off)
sma200w_raw = request.security(syminfo.tickerid, "1W", ta.sma(close, 200), lookahead = barmerge.lookahead_off)
sma20w  = wSmoothOn ? ta.sma(sma20w_raw,  wSmoothLen) : sma20w_raw
sma50w  = wSmoothOn ? ta.sma(sma50w_raw,  wSmoothLen) : sma50w_raw
sma200w = wSmoothOn ? ta.sma(sma200w_raw, wSmoothLen) : sma200w_raw

// ─────────────────────────── Visuals / Trend ───────────────────────────
gV         = "Visuals"
slopeColOn = input.bool(false, "Slope-color MAs (dim when falling)", group = gV,
     tooltip = "Each MA keeps its color while rising and fades when falling — a fast per-line read of trend direction.")
biasOn     = input.bool(false, "Bias background (price vs SMA slot 5)", group = gV)

mcol(col, v) => not slopeColOn ? col : (v > v[1] ? col : color.new(col, 62))

// ─────────────────────────── Price Labels ───────────────────────────
// Per-line 'lbl' checkbox decides WHICH moving averages get a price label.
// This selector decides WHERE that label is drawn:
//   "Chart"       → a floating tag on the chart at the line's right end
//                   (at the projected end when 'ext' is on, else at the current value)
//   "Price scale" → the value tag on the right-hand price axis (native plot label)
//   "Off"         → master switch, no price labels at all
gLab     = "Price Labels"
labelMode = input.string("Price scale", "Price label position",
     options = ["Price scale", "Line end", "Off"], group = gLab,
     tooltip = "Price scale = solid colored tags lined up at the right edge, near the price axis.  Line end = translucent tag at the end of each line / projection.  Off = hide all price labels.")
lblOffset = input.int(5, "Price-scale label offset (bars right)", group = gLab, minval = 0, maxval = 50,
     tooltip = "How far right of the last bar the price-scale tags sit. Increase to push them closer to the price axis in your usual zoom.")

// Plots never carry their native price-scale value tag — price labels are drawn
// explicitly below (as colored tags) so they render reliably (native tags get
// hidden by user price-scale settings / overlap) and can be styled.
f_disp(on) => not on ? display.none : display.all - display.price_scale

// Readable text color (black/white) for a solid colored label background.
f_txt(c) => (color.r(c) * 0.299 + color.g(c) * 0.587 + color.b(c) * 0.114) > 150 ? color.black : color.white

// Short unit token for the calculation timeframe (D / W / M / H / m / s), so a
// chart-timeframe 20 SMA reads "20D SMA" on a daily, "20H SMA" on hourly, etc.
// Reflects the actual calc timeframe (`res`), which matters when MAs are pulled
// from a higher timeframe than the chart.
f_tfTok() =>
    t = res == "" ? timeframe.period : res
    str.contains(t, "S") ? "s" : str.contains(t, "D") ? "D" : str.contains(t, "W") ? "W" : str.contains(t, "M") ? "M" : (str.tonumber(t) >= 60 ? "H" : "m")
TFTOK = f_tfTok()

// ─────────────────────────────── Plots ───────────────────────────────
// display = none when disabled → keeps the status line clean (only the
// selected MAs appear in the status line, each with its live value).
ps1 = plot(s1On ? s1 : na, "SMA 1", mcol(s1C, s1), s1W, display = f_disp(s1On))
ps2 = plot(s2On ? s2 : na, "SMA 2", mcol(s2C, s2), s2W, display = f_disp(s2On))
plot(s3On ? s3 : na, "SMA 3", mcol(s3C, s3), s3W, display = f_disp(s3On))
plot(s4On ? s4 : na, "SMA 4", mcol(s4C, s4), s4W, display = f_disp(s4On))
plot(s5On ? s5 : na, "SMA 5", mcol(s5C, s5), s5W, display = f_disp(s5On))
plot(s6On ? s6 : na, "SMA 6", mcol(s6C, s6), s6W, display = f_disp(s6On))

plot(e1On ? e1 : na, "EMA 1", mcol(e1C, e1), e1W, display = f_disp(e1On))
plot(e2On ? e2 : na, "EMA 2", mcol(e2C, e2), e2W, display = f_disp(e2On))
plot(e3On ? e3 : na, "EMA 3", mcol(e3C, e3), e3W, display = f_disp(e3On))
plot(e4On ? e4 : na, "EMA 4", mcol(e4C, e4), e4W, display = f_disp(e4On))
plot(e5On ? e5 : na, "EMA 5", mcol(e5C, e5), e5W, display = f_disp(e5On))
plot(e6On ? e6 : na, "EMA 6", mcol(e6C, e6), e6W, display = f_disp(e6On))

plot(w20On  ? sma20w  : na, "20W SMA",  w20C,  3, display = f_disp(w20On))
plot(w50On  ? sma50w  : na, "50W SMA",  w50C,  3, display = f_disp(w50On))
plot(w200On ? sma200w : na, "200W SMA", w200C, 3, display = f_disp(w200On))

bgcolor(biasOn ? (close > s5 ? color.new(color.green, 92) : color.new(color.red, 92)) : na, title = "Bias background")

// ───────────────────────── Slope Projection ─────────────────────────
gP       = "Slope Projection"
projOn   = input.bool(true,  "Enable slope projection (per-line 'ext')", group = gP,
     tooltip = "Master switch. Each MA / anchor with its 'ext' box ticked is extended forward along its current slope.")
projNcur = input.int(30,  "Current-TF extension (chart bars)", group = gP, minval = 1, maxval = 500,
     tooltip = "How far the standard SMA/EMA projections reach, measured in bars of the CURRENT chart timeframe. The real-world span therefore scales with the timeframe you are viewing.")
projLBcur= input.int(3,   "Current-TF slope lookback (bars)",  group = gP, minval = 1,
     tooltip = "Slope of a current-TF MA = its change over this many chart bars. Larger = smoother slope.")
projNwk  = input.int(13,  "Anchored extension (weeks)",        group = gP, minval = 1, maxval = 260,
     tooltip = "How far the weekly anchor projections (20W / 50W / 200W) reach, measured in WEEKS — independent of the chart timeframe, so they stay anchored to the weekly trend.")
projLBwk = input.int(4,   "Anchored slope lookback (weeks)",   group = gP, minval = 1,
     tooltip = "Slope of a weekly anchor = its change over this many weeks, computed on the weekly series so it stays smooth on lower timeframes.")
projStyle = input.string("Dashed", "Projection line style", options = ["Solid", "Dotted", "Dashed"], group = gP)
projTransp= input.int(0, "Projection transparency", group = gP, minval = 0, maxval = 100,
     tooltip = "0 = fully opaque, 100 = invisible. Dims only the projected extensions; the solid MA lines keep their own opacity.")

// Current-TF slopes (change per CHART BAR). Computed on EVERY bar (global scope)
// so the history operator inside slp() has data to look back on — reading them
// only inside `barstate.islast`, as the original did, leaves the parameter
// history empty, so slp() returns na and no projection line is ever drawn.
slp(v) => (v - v[projLBcur]) / projLBcur
s1Slope = slp(s1),  s2Slope = slp(s2),  s3Slope = slp(s3)
s4Slope = slp(s4),  s5Slope = slp(s5),  s6Slope = slp(s6)
e1Slope = slp(e1),  e2Slope = slp(e2),  e3Slope = slp(e3)
e4Slope = slp(e4),  e5Slope = slp(e5),  e6Slope = slp(e6)

// Anchor slopes (change per WEEK). Computed on the weekly series itself via
// request.security so they are independent of the chart timeframe and stay
// smooth on lower timeframes (no staircase feeding the slope).
f_wkslope(len) => request.security(syminfo.tickerid, "1W", (ta.sma(close, len) - ta.sma(close, len)[projLBwk]) / projLBwk, lookahead = barmerge.lookahead_off)
w20Slope  = f_wkslope(20)
w50Slope  = f_wkslope(50)
w200Slope = f_wkslope(200)

WEEK_MS = 7 * 24 * 60 * 60 * 1000   // one week in milliseconds (for time-based anchor projection)

// Typed bundle for each plottable line.
type MAdef
    bool   on
    float  v
    float  slope
    color  col
    int    w
    bool   ext
    string name
    int    len
    bool   showLab
    bool   isAnchor

var line[]  projLines = array.new_line()
var label[] labs      = array.new_label()

if barstate.islast
    for ln in projLines
        line.delete(ln)
    array.clear(projLines)
    for lb in labs
        label.delete(lb)
    array.clear(labs)

    MAdef[] defs = array.new<MAdef>()
    array.push(defs, MAdef.new(s1On, s1, s1Slope, s1C, s1W, s1X, "SMA", s1L, s1Lab, false))
    array.push(defs, MAdef.new(s2On, s2, s2Slope, s2C, s2W, s2X, "SMA", s2L, s2Lab, false))
    array.push(defs, MAdef.new(s3On, s3, s3Slope, s3C, s3W, s3X, "SMA", s3L, s3Lab, false))
    array.push(defs, MAdef.new(s4On, s4, s4Slope, s4C, s4W, s4X, "SMA", s4L, s4Lab, false))
    array.push(defs, MAdef.new(s5On, s5, s5Slope, s5C, s5W, s5X, "SMA", s5L, s5Lab, false))
    array.push(defs, MAdef.new(s6On, s6, s6Slope, s6C, s6W, s6X, "SMA", s6L, s6Lab, false))
    array.push(defs, MAdef.new(e1On, e1, e1Slope, e1C, e1W, e1X, "EMA", e1L, e1Lab, false))
    array.push(defs, MAdef.new(e2On, e2, e2Slope, e2C, e2W, e2X, "EMA", e2L, e2Lab, false))
    array.push(defs, MAdef.new(e3On, e3, e3Slope, e3C, e3W, e3X, "EMA", e3L, e3Lab, false))
    array.push(defs, MAdef.new(e4On, e4, e4Slope, e4C, e4W, e4X, "EMA", e4L, e4Lab, false))
    array.push(defs, MAdef.new(e5On, e5, e5Slope, e5C, e5W, e5X, "EMA", e5L, e5Lab, false))
    array.push(defs, MAdef.new(e6On, e6, e6Slope, e6C, e6W, e6X, "EMA", e6L, e6Lab, false))
    array.push(defs, MAdef.new(w20On,  sma20w,  w20Slope,  w20C,  3, w20X,  "20W SMA",  0, w20Lab,  true))
    array.push(defs, MAdef.new(w50On,  sma50w,  w50Slope,  w50C,  3, w50X,  "50W SMA",  0, w50Lab,  true))
    array.push(defs, MAdef.new(w200On, sma200w, w200Slope, w200C, 3, w200X, "200W SMA", 0, w200Lab, true))

    for d in defs
        if d.on and not na(d.v)
            extend = projOn and d.ext and not na(d.slope)
            ls     = projStyle == "Solid" ? line.style_solid : projStyle == "Dotted" ? line.style_dotted : line.style_dashed
            pcol   = color.new(d.col, projTransp)                          // projection color + user opacity
            // name: anchors carry their own "20W SMA"; current-TF lines get the
            // chart-timeframe unit token, e.g. "20D SMA" / "50H SMA".
            nm     = d.isAnchor ? d.name : str.tostring(d.len) + TFTOK + " " + d.name
            lineEnd = labelMode == "Line end" and d.showLab
            // Projection line + (optionally) the line-end label. xloc must be a
            // literal (not series), so anchors / current-TF are split:
            //   Anchors    → extend by WEEKS along the TIME axis (timeframe-independent)
            //   Current TF → extend by chart BARS along the bar-index axis
            if d.isAnchor
                endY = extend ? d.v + d.slope * projNwk : d.v
                x2   = time + projNwk * WEEK_MS
                tipX = extend ? x2 : time
                if extend
                    array.push(projLines, line.new(time, d.v, x2, endY, xloc = xloc.bar_time, color = pcol, width = d.w, style = ls))
                if lineEnd
                    array.push(labs, label.new(tipX, endY, nm + "  " + str.tostring(endY, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(d.col, 82), textcolor = d.col, size = size.small))
            else
                endY = extend ? d.v + d.slope * projNcur : d.v
                x2   = bar_index + projNcur
                tipX = extend ? x2 : bar_index
                if extend
                    array.push(projLines, line.new(bar_index, d.v, x2, endY, color = pcol, width = d.w, style = ls))
                if lineEnd
                    array.push(labs, label.new(tipX, endY, nm + "  " + str.tostring(endY, format.mintick), style = label.style_label_left, color = color.new(d.col, 82), textcolor = d.col, size = size.small))
            // Price-scale label: solid colored tag lined up at the right edge near
            // the price axis, at the line's CURRENT value (independent of projection).
            if labelMode == "Price scale" and d.showLab
                array.push(labs, label.new(bar_index + lblOffset, d.v, nm + "  " + str.tostring(d.v, format.mintick), style = label.style_label_left, color = d.col, textcolor = f_txt(d.col), size = size.small))

// ───────────────────────── Ribbon Fill ─────────────────────────
gF     = "Ribbon Fill"
fillOn = input.bool(false, "Fill between SMA slot 1 & slot 2", group = gF)
fcUp   = input.color(color.new(color.green, 88), "Up", inline = "F1", group = gF)
fcDn   = input.color(color.new(color.red,   88), "Down", inline = "F1", group = gF)
fill(ps1, ps2, color = fillOn ? (s1 > s2 ? fcUp : fcDn) : na, title = "SMA Ribbon")

// ───────────────────────── Cross Signals & Alerts ─────────────────────────
gX   = "Cross Signals (SMA slot 2 × slot 5)"
xOn  = input.bool(false, "Golden / Death cross markers", group = gX,
     tooltip = "Uses SMA slot 2 (default 50) crossing SMA slot 5 (default 200).")
gold = ta.crossover(s2, s5)
dead = ta.crossunder(s2, s5)
plotshape(xOn and gold, "Golden Cross", shape.triangleup,   location.belowbar, color.new(color.green, 0), text = "GC", textcolor = color.green, size = size.tiny)
plotshape(xOn and dead, "Death Cross",  shape.triangledown, location.abovebar, color.new(color.red,   0), text = "DC", textcolor = color.red,   size = size.tiny)

alertcondition(gold,                "Golden Cross",       "MA Suite: Fast SMA crossed ABOVE Slow SMA")
alertcondition(dead,                "Death Cross",        "MA Suite: Fast SMA crossed BELOW Slow SMA")
alertcondition(ta.cross(close, s1), "Price × SMA slot 1", "MA Suite: Price crossed SMA slot 1")
alertcondition(ta.cross(close, e1), "Price × EMA slot 1", "MA Suite: Price crossed EMA slot 1")

// ───────────────────────── Anchored VWAP + Bands ─────────────────────────
gVW       = "Anchored VWAP"
avOn      = input.bool(false, "Show anchored VWAP", group = gVW)
avAnchor  = input.string("Session", "Anchor period", options = ["Session", "Week", "Month", "Quarter", "Year"], group = gVW)
avSrc     = input.source(hlc3, "VWAP source", group = gVW)
avColor   = input.color(#2962FF, "VWAP color", inline = "AV", group = gVW)
avBandsOn = input.bool(true, "Std-dev bands", inline = "AV", group = gVW)
avMult    = input.float(2.0, "Mult", inline = "AV", group = gVW, minval = 0.1, step = 0.1)

avTf    = avAnchor == "Session" ? "D" : avAnchor == "Week" ? "W" : avAnchor == "Month" ? "M" : avAnchor == "Quarter" ? "3M" : "12M"
avReset = timeframe.change(avTf)
[avwap, avUp, avLo] = ta.vwap(avSrc, avReset, avMult)

plot(avOn ? avwap : na, "AVWAP", avColor, 2, display = avOn ? display.all : display.none)
pUp = plot(avOn and avBandsOn ? avUp : na, "AVWAP +band", color.new(avColor, 35), 1, display = avOn and avBandsOn ? display.all : display.none)
pLo = plot(avOn and avBandsOn ? avLo : na, "AVWAP -band", color.new(avColor, 35), 1, display = avOn and avBandsOn ? display.all : display.none)
fill(pUp, pLo, color = avOn and avBandsOn ? color.new(avColor, 92) : na, title = "AVWAP band fill")

// ───────────────────────── % Distance Table ─────────────────────────
gT     = "Distance Table"
tblOn  = input.bool(true, "Show % distance table", group = gT)
tblPos = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gT)
_pos   = tblPos == "Top Right" ? position.top_right : tblPos == "Top Left" ? position.top_left : tblPos == "Bottom Right" ? position.bottom_right : tblPos == "Bottom Left" ? position.bottom_left : position.middle_right

var table dt = table.new(_pos, 2, 30, border_width = 1, frame_width = 1, frame_color = color.new(color.gray, 50))

addRow(r, on, pfx, len, v, col) =>
    rr = r
    if on and not na(v)
        pct = (close - v) / v * 100.0
        nm  = len > 0 ? str.tostring(len) + TFTOK + " " + pfx : pfx
        table.cell(dt, 0, rr, nm, text_color = col, text_size = size.small, text_halign = text.align_left)
        table.cell(dt, 1, rr, str.tostring(pct, "0.00") + "%", text_color = pct >= 0 ? color.green : color.red, text_size = size.small, text_halign = text.align_right)
        rr := r + 1
    rr

if tblOn and barstate.islast
    table.clear(dt, 0, 0, 1, 29)
    table.cell(dt, 0, 0, "MA",       text_color = color.white, text_size = size.small, bgcolor = color.new(color.gray, 30), text_halign = text.align_left)
    table.cell(dt, 1, 0, "Δ% price", text_color = color.white, text_size = size.small, bgcolor = color.new(color.gray, 30), text_halign = text.align_right)
    int r = 1
    r := addRow(r, s1On, "SMA", s1L, s1, s1C)
    r := addRow(r, s2On, "SMA", s2L, s2, s2C)
    r := addRow(r, s3On, "SMA", s3L, s3, s3C)
    r := addRow(r, s4On, "SMA", s4L, s4, s4C)
    r := addRow(r, s5On, "SMA", s5L, s5, s5C)
    r := addRow(r, s6On, "SMA", s6L, s6, s6C)
    r := addRow(r, e1On, "EMA", e1L, e1, e1C)
    r := addRow(r, e2On, "EMA", e2L, e2, e2C)
    r := addRow(r, e3On, "EMA", e3L, e3, e3C)
    r := addRow(r, e4On, "EMA", e4L, e4, e4C)
    r := addRow(r, e5On, "EMA", e5L, e5, e5C)
    r := addRow(r, e6On, "EMA", e6L, e6, e6C)
    r := addRow(r, w20On,  "20W SMA",  0, sma20w,  w20C)
    r := addRow(r, w50On,  "50W SMA",  0, sma50w,  w50C)
    r := addRow(r, w200On, "200W SMA", 0, sma200w, w200C)
````

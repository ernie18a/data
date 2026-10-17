# Wickless Candles

- url: https://www.tradingview.com/script/9v24mHbB/
- type: indicator
- pine_id: PUB;659c742a6bfe4a1897e85f50495583de
- version: 3.0

## Description

Wickless Candles – Multi-Timeframe Levels

Marks wickless candles (Marubozu-style candles with no wick on one or both sides) as horizontal levels across multiple timeframes. These candles form when price closes in one direction without testing the opposite side even once during the bar – a sign of clean, one-sided order flow. The high/low levels of such candles often act as future support or resistance zones.
What it does

The indicator scans multiple timeframes in parallel (1H, 4H, 1D, 1W by default, plus 15m and current chart optional) and draws a horizontal line from the candle body the moment a wickless candle closes:

Top (red): line at the high level when the candle has no upper wick.
Bottom (green): line at the low level when the candle has no lower wick.
A fully wickless candle (true Marubozu) produces both lines.

Lines extend bar by bar until price reaches the level again. By default, the line is removed on first touch (setting „Hide broken lines") – so only untested levels stay on the chart and the view remains clean.

Detection logic:
A candle qualifies as wickless on a given side when:

No upper wick: high == max(open, close)
No lower wick: low == min(open, close)

Detection runs strictly on candle close (non-repainting). Higher timeframes are read via request.security with lookahead_on and [1] indexing on the last closed HTF candle – levels are only drawn after the HTF candle has fully closed, and never change afterwards.


Settings

Timeframes:
Individually toggleable: Current chart, 15m, 1H, 4H, 1D, 1W
Timeframe label at the line end (e.g. „1D", „4H") – follows the right edge of the line, so it's always clear which TF the level came from

Display:
Line width (1–4)
Line style: solid, dashed, dotted
Hide broken lines (on: line disappears on touch / off: line stops at touch and stays visible)

Colors:
Freely customizable for upper and lower markings (default: subtle red/green with transparency)


How to use

Typical setup: a lower-timeframe chart (e.g. 15m or 1H) with higher TFs enabled (4H, 1D, 1W). At a glance you see which 1D or 1W levels price last closed against one-sidedly, and which of those levels haven't been retested yet – often high-quality reaction zones for pullbacks or breakouts.

Note:
Timeframes lower than the chart TF (e.g. 15m on a 4H chart) are only sampled coarsely by Pine Script – not every 15m wickless candle will be captured in that case. For full coverage, select TF >= chart TF.

Alert:
Built-in alert „Wickless candle (Chart)" fires when a wickless candle closes on the current chart timeframe.

## Source Code

````pine
//@version=6
// ============================================================================
//  Wickless Candles - Multi-Timeframe Levels
//  ---------------------------------------------------------------------------
//  Marks candles that closed without a wick on one or both sides and projects
//  the wickless edge forward as a level. Higher timeframes are read with a one
//  bar offset, so only closed candles are ever evaluated. A level becomes
//  testable only after price has first moved away from it.
// ============================================================================
indicator("Wickless Candles v1.1", "Wickless Candles", overlay = true,
     max_lines_count = 500, max_labels_count = 500)

// ------------------------------------------------------------------ inputs --
const string G_TF  = "Timeframes"
const string G_LVL = "Level lifecycle"
const string G_VIS = "Display"
const string G_COL = "Colors"

bool showChart = input.bool(false, "Current chart", group = G_TF)
bool show15m   = input.bool(false, "15m", group = G_TF)
bool show1H    = input.bool(true,  "1H",  group = G_TF)
bool show4H    = input.bool(true,  "4H",  group = G_TF)
bool show1D    = input.bool(true,  "1D",  group = G_TF)
bool show1W    = input.bool(true,  "1W",  group = G_TF)
bool showNote  = input.bool(true, "Show availability note", group = G_TF,
     tooltip = "A timeframe finer than the chart resolution is skipped. Pine samples it once per chart bar, so most of its candles are never seen and the level set would silently depend on which chart you happen to be viewing.")

float armDist = input.float(0.5, "Arm distance (x ATR)", minval = 0, step = 0.1, group = G_LVL,
     tooltip = "A wickless candle closes on its own extreme, so price sits exactly on the level the moment it is drawn. Until price has moved this far away, a touch is not counted. Without it every level would be consumed by the very next bar.")
bool hideBroken = input.bool(true, "Remove levels once tested", group = G_LVL,
     tooltip = "On: only untested levels remain. Off: the line stops at the test bar and stays visible as a record.")
float maxDist   = input.float(20, "Drop levels beyond (x ATR, 0 = off)", minval = 0, step = 1,
     group = G_LVL,
     tooltip = "An untested level stays valid indefinitely and can end up far from current price, where it tells you nothing but still forces the chart's auto scale to include it. 0 keeps every level.")
int maxMarkers  = input.int(60, "Maximum levels kept", minval = 5, maxval = 250, group = G_LVL,
     tooltip = "Oldest levels are dropped beyond this count. Without a cap, Pine silently discards drawings past its own object limit.")

bool   showLabel   = input.bool(true, "Timeframe tag at line end", group = G_VIS)
int    lineWidth   = input.int(1, "Line width", minval = 1, maxval = 4, group = G_VIS)
string lineStyleIn = input.string("dashed", "Line style", options = ["solid", "dashed", "dotted"], group = G_VIS)

color colorUpper = input.color(color.new(#ef5350, 40), "Upper (no upper wick)", group = G_COL)
color colorLower = input.color(color.new(#26a69a, 40), "Lower (no lower wick)", group = G_COL)

string styleLine = switch lineStyleIn
    "solid"  => line.style_solid
    "dashed" => line.style_dashed
    => line.style_dotted

prettyTF(string tf) =>
    switch tf
        "1"   => "1m"
        "3"   => "3m"
        "5"   => "5m"
        "15"  => "15m"
        "30"  => "30m"
        "60"  => "1H"
        "120" => "2H"
        "240" => "4H"
        "D"   => "1D"
        "W"   => "1W"
        "M"   => "1M"
        => tf

// -------------------------------------------------------- grid availability --
float chartMin = timeframe.in_seconds(timeframe.period) / 60.0

bool ok15m = show15m and chartMin <= 15
bool ok1H  = show1H  and chartMin <= 60
bool ok4H  = show4H  and chartMin <= 240
bool ok1D  = show1D  and chartMin <= 1440
bool ok1W  = show1W  and chartMin <= 10080

float atr14 = ta.atr(14)

// ------------------------------------------------------------------- state --
var array<line>   mkLine  = array.new<line>()
var array<label>  mkLabel = array.new<label>()
var array<float>  mkLevel = array.new<float>()
var array<bool>   mkUpper = array.new<bool>()
var array<int>    mkStart = array.new<int>()
var array<string> mkTfs   = array.new<string>()
var array<bool>   mkLive  = array.new<bool>()
var array<bool>   mkArmed = array.new<bool>()

float dedupTol = syminfo.mintick * 2

// ---------------------------------------------------------------- creation --
// A weekly candle and the daily candle that produced its extreme are wickless
// at the same price. Rather than stacking two identical lines, the tag of the
// second one is appended to the first.
createMarker(float level, bool upper, string tag) =>
    string pretty = prettyTF(tag)
    bool merged = false

    if array.size(mkLine) > 0
        for i = 0 to array.size(mkLine) - 1
            if array.get(mkLive, i) and array.get(mkUpper, i) == upper and
                 math.abs(array.get(mkLevel, i) - level) <= dedupTol
                string tfs = array.get(mkTfs, i)
                if not str.contains(tfs, pretty)
                    tfs := tfs + ", " + pretty
                    array.set(mkTfs, i, tfs)
                    label lb = array.get(mkLabel, i)
                    if not na(lb)
                        label.set_text(lb, tfs)
                merged := true
                break

    if not merged
        color col = upper ? colorUpper : colorLower
        line ln = line.new(bar_index, level, bar_index, level,
             color = col, width = lineWidth, style = styleLine)

        label lbl = na
        if showLabel
            lbl := label.new(bar_index, level, pretty, style = label.style_none,
                 textcolor = col, size = size.tiny)

        array.push(mkLine,  ln)
        array.push(mkLabel, lbl)
        array.push(mkLevel, level)
        array.push(mkUpper, upper)
        array.push(mkStart, bar_index)
        array.push(mkTfs,   pretty)
        array.push(mkLive,  true)
        array.push(mkArmed, false)

// -------------------------------------------------------------- detection ---
// The one bar offset is what makes this honest. request.security with
// lookahead_on and no offset hands back the finished values of a candle that
// has only just opened, which looks flawless on history and cannot work live.
// Offsetting by one bar returns the last candle that actually closed.
probeTF(string tf) =>
    [o, h, l, c] = request.security(syminfo.tickerid, tf,
         [open[1], high[1], low[1], close[1]], lookahead = barmerge.lookahead_on)

    bool isNew = ta.change(time(tf)) != 0
    bool valid = not na(o) and not na(h) and not na(l) and not na(c) and h >= l and h > 0

    bool noUpper = isNew and valid and h <= math.max(o, c)
    bool noLower = isNew and valid and l >= math.min(o, c)
    [noUpper, noLower, h, l]

// Requested at global scope so the calls are unconditional; results are simply
// ignored when a layer is off.
[u15, d15, h15, l15]     = probeTF("15")
[u60, d60, h60, l60]     = probeTF("60")
[u240, d240, h240, l240] = probeTF("240")
[uD, dD, hD, lD]         = probeTF("D")
[uW, dW, hW, lW]         = probeTF("W")

// ---------------------------------------------------------------- upkeep ----
// Three stages per level:
//   arming - price must first travel away from the level it was born on
//   test   - once armed, price returning to the level counts as a test
//   expiry - a level that drifts too far from price stops describing anything
float armGap = na(atr14) ? 0.0 : atr14 * armDist

if array.size(mkLine) > 0
    for i = 0 to array.size(mkLine) - 1
        if array.get(mkLive, i)
            float lvl = array.get(mkLevel, i)
            bool  up  = array.get(mkUpper, i)
            int   st  = array.get(mkStart, i)
            line  ln  = array.get(mkLine, i)
            label lb  = array.get(mkLabel, i)

            bool armed = array.get(mkArmed, i)
            if not armed and bar_index > st
                if up ? close < lvl - armGap : close > lvl + armGap
                    array.set(mkArmed, i, true)
                    armed := true

            bool tested = armed and (up ? high >= lvl : low <= lvl)
            bool tooFar = maxDist > 0 and not na(atr14) and math.abs(lvl - close) > atr14 * maxDist

            line.set_x2(ln, bar_index)
            if not na(lb)
                label.set_x(lb, bar_index)

            if tested or tooFar
                array.set(mkLive, i, false)
                if hideBroken or tooFar
                    line.delete(ln)
                    if not na(lb)
                        label.delete(lb)
                    array.set(mkLine, i, na)
                    array.set(mkLabel, i, na)

// Slots whose drawing is gone carry no information. Drop them so the cap counts
// levels you can actually see.
if array.size(mkLine) > 0
    for i = array.size(mkLine) - 1 to 0
        if na(array.get(mkLine, i))
            array.remove(mkLine, i)
            array.remove(mkLabel, i)
            array.remove(mkLevel, i)
            array.remove(mkUpper, i)
            array.remove(mkStart, i)
            array.remove(mkTfs, i)
            array.remove(mkLive, i)
            array.remove(mkArmed, i)

// ------------------------------------------------------------- execution ----
if showChart and barstate.isconfirmed
    if high <= math.max(open, close)
        createMarker(high, true, timeframe.period)
    if low >= math.min(open, close)
        createMarker(low, false, timeframe.period)

if ok15m
    if u15
        createMarker(h15, true, "15")
    if d15
        createMarker(l15, false, "15")
if ok1H
    if u60
        createMarker(h60, true, "60")
    if d60
        createMarker(l60, false, "60")
if ok4H
    if u240
        createMarker(h240, true, "240")
    if d240
        createMarker(l240, false, "240")
if ok1D
    if uD
        createMarker(hD, true, "D")
    if dD
        createMarker(lD, false, "D")
if ok1W
    if uW
        createMarker(hW, true, "W")
    if dW
        createMarker(lW, false, "W")

// ------------------------------------------------------------------- cap ----
while array.size(mkLine) > maxMarkers
    line.delete(array.shift(mkLine))
    label old = array.shift(mkLabel)
    if not na(old)
        label.delete(old)
    array.shift(mkLevel)
    array.shift(mkUpper)
    array.shift(mkStart)
    array.shift(mkTfs)
    array.shift(mkLive)
    array.shift(mkArmed)

// ------------------------------------------------------- availability note --
bool anyOff = (show15m and not ok15m) or (show1H and not ok1H) or
     (show4H and not ok4H) or (show1D and not ok1D) or (show1W and not ok1W)

if showNote and barstate.islast and anyOff
    string active = (ok15m ? "15m " : "") + (ok1H ? "1H " : "") + (ok4H ? "4H " : "") +
         (ok1D ? "1D " : "") + (ok1W ? "1W" : "")
    string note = str.length(str.trim(active)) == 0
         ? "No selected timeframe is available at this chart resolution."
         : "Timeframes active: " + str.trim(active)

    var table tNote = table.new(position.top_right, 1, 1)
    table.cell(tNote, 0, 0, note, text_size = size.tiny,
         text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 20))

// ----------------------------------------------------------------- alerts ---
bool chartWickless = barstate.isconfirmed and
     (high <= math.max(open, close) or low >= math.min(open, close))

alertcondition(chartWickless, "Wickless candle (chart)",
     "A wickless candle closed on the chart timeframe.")
````

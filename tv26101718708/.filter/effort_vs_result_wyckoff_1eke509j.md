# Effort vs Result [Wyckoff]

- url: https://www.tradingview.com/script/1Eke509j-Effort-vs-Result-Wyckoff/
- type: indicator
- pine_id: PUB;2d42c4bb93cd47e5af9790b02e25bc20
- version: 1.0

## Description

Wyckoff's "effort vs result," quantified. Effort = volume (how much trading took place). Result = how far price actually travelled. When a bar shows heavy effort but little result, supply/demand is being absorbed — a battle worth marking.

[b]HOW IT WORKS[/b]
Effort and result are turned into z-scores over a rolling window, so "high" and "low" mean high/low for this symbol on this timeframe — not a fixed number.

Absorption (high effort, low result) does not give direction — it only marks an important area where effort got absorbed. The indicator draws that area as a zone and waits. The zone develops, growing to include every following bar. The moment price closes beyond the developing range — either side, any volume — the level has given way. That break, in its own direction, is the signal.

1) Absorption seeds a zone (its high–low)
2) Each following bar expands the range
3) A close beyond the range = breakout (within N bars), otherwise the zone is discarded

[b]HOW TO READ[/b]
- Grey dashed box: a developing absorption zone (directionless).
- Green triangle below a bar: bullish breakout (closed above the zone) — box turns green.
- Red triangle above a bar: bearish breakout (closed below the zone) — box turns red.
Zones that time out or get breached without a clean close disappear, so only meaningful areas remain.

[b]INPUTS[/b]
- Z-Score Lookback — window for the rolling mean / standard deviation.
- Divergence Threshold (σ) — how extreme a bar must be to count as absorption. Higher = fewer, stronger zones.
- Result Source — Range (high−low), Body (|close−open|), or True Range (gap-aware).
- Detection Mode — Score (combined divergence, looser) or Strict (both legs extreme).
- Max Bars: Absorption → Breakout — how long a zone waits before being discarded.
- Visuals — show/hide zones, arrows, labels, colours.

[b]ALERTS[/b]
Two separate conditions: Bullish Breakout and Bearish Breakout (use "Once Per Bar Close").

[b]NOTES & LIMITS[/b]
Volume reliability depends on the symbol/feed — on spot FX it is tick volume, not real contracts; no volume = no signals. This is a statistical observation, not a forecast: a z-score flags an unusual bar, a breakout shows a level gave way — neither guarantees what price does next. No repaint, no lookahead: all calculations are on closed bars; z-scores use past bars only.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © ElisTools
// Effort vs Result [Wyckoff] — Attribution required: credit "ElisTools" in any reuse or derivative.
//@version=6
indicator("Effort vs Result [Wyckoff]", shorttitle="EvR [Wyckoff]", overlay=true, max_boxes_count=500, max_labels_count=500)

// ─────────────────────────────────────────────────────────────────────────
//  Absorption marks a battle, not a direction — so it only seeds a ZONE: a
//  price area where heavy effort got absorbed. The zone then DEVELOPS, growing
//  to include every bar that prints while we wait. The moment price CLOSES
//  beyond that developing range — either side, any volume — the level has
//  given way; that break, in its own direction, is the signal.
//
//    1. Absorption             →  seed a zone (its high–low)
//    2. Each following bar      →  range expands to include it
//    3. Close beyond the range  →  breakout (within N bars), else discard
//
//  Everything is read on closed bars only: no repaint, no lookahead.
// ─────────────────────────────────────────────────────────────────────────

// ── Signal engine ────────────────────────────────────────────────────────
gEng      = "Signal Engine"
lookback  = input.int(50, "Z-Score Lookback", minval=10, group=gEng)
threshold = input.float(2.0, "Divergence Threshold (σ)", minval=0.5, step=0.1, group=gEng, tooltip="How extreme a bar must be to count as absorption.")
resultSrc = input.string("Range", "Result Source", options=["Range", "Body", "True Range"], group=gEng, tooltip="Range = high−low. Body = |close−open|. True Range = gap-aware.")
detMode   = input.string("Score", "Detection Mode", options=["Score", "Strict"], group=gEng)

// ── Sequence ─────────────────────────────────────────────────────────────
gSeq       = "Sequence"
linkWindow = input.int(10, "Max Bars: Absorption → Breakout", minval=1, group=gSeq, tooltip="Price must close beyond the zone within this many bars of the last absorption, otherwise the zone is discarded.")

// ── Visuals ──────────────────────────────────────────────────────────────
gVis       = "Visuals"
showZones  = input.bool(true,  "Show Absorption Zones", group=gVis)
showBreaks = input.bool(true,  "Show Breakout Arrows", group=gVis)
showLabels = input.bool(false, "Show Breakout Labels", group=gVis)
zoneCol    = input.color(#787b86, "Zone", group=gVis)
upCol      = input.color(#26a69a, "Bullish Breakout", group=gVis, inline="bo")
dnCol      = input.color(#ef5350, "Bearish Breakout", group=gVis, inline="bo")

// ── Effort / result z-scores (for absorption detection) ──────────────────
effort    = volume
trueRange = ta.tr(true)
result    = resultSrc == "Range" ? (high - low) : resultSrc == "Body" ? math.abs(close - open) : trueRange

effMean = ta.sma(effort, lookback)
effSd   = ta.stdev(effort, lookback)
resMean = ta.sma(result, lookback)
resSd   = ta.stdev(result, lookback)
effortZ = effSd > 0 ? (effort - effMean) / effSd : 0.0
resultZ = resSd > 0 ? (result - resMean) / resSd : 0.0

div     = effortZ - resultZ
divMean = ta.sma(div, lookback)
divSd   = ta.stdev(div, lookback)
divZ    = divSd > 0 ? (div - divMean) / divSd : 0.0

absRaw = detMode == "Score" ? (divZ >= threshold and effortZ > 0 and resultZ < 0) : (effortZ >= threshold and resultZ <= -threshold)

// ── Zone state machine ───────────────────────────────────────────────────
var float zHigh   = na
var float zLow    = na
var int   zBar    = na          // most recent absorption — the window deadline
var bool  zActive = false
var box   zBox    = na

zoneFill = color.new(zoneCol, 90)
zoneBord = color.new(zoneCol, 25)
upFill   = color.new(upCol, 82)
dnFill   = color.new(dnCol, 82)

bool bullBreak = false
bool bearBreak = false

if barstate.isconfirmed
    if zActive
        // Break = close beyond the range built from the absorption + every bar since.
        brokeUp = close > zHigh
        brokeDn = close < zLow
        if brokeUp or brokeDn
            bullBreak := brokeUp
            bearBreak := brokeDn
            if not na(zBox)
                box.set_right(zBox, bar_index)
                box.set_bgcolor(zBox, brokeUp ? upFill : dnFill)
                box.set_border_color(zBox, brokeUp ? upCol : dnCol)
            zActive := false
            zBox    := na
        else if bar_index - zBar > linkWindow
            // No break in time → discard.
            if not na(zBox)
                box.delete(zBox)
            zBox    := na
            zActive := false
        else
            // Still developing: fold this bar's high/low into the growing range.
            zHigh := math.max(zHigh, high)
            zLow  := math.min(zLow, low)
            if absRaw
                zBar := bar_index
            if not na(zBox)
                box.set_top(zBox, zHigh)
                box.set_bottom(zBox, zLow)
                box.set_right(zBox, bar_index)

    if not zActive and absRaw
        // A fresh absorption seeds a new zone.
        zHigh   := high
        zLow    := low
        zBar    := bar_index
        zActive := true
        zBox    := showZones ? box.new(bar_index, zHigh, bar_index, zLow, border_color=zoneBord, bgcolor=zoneFill, border_style=line.style_dashed) : na

// ── Markers ──────────────────────────────────────────────────────────────
plotshape(showBreaks and bullBreak, "Bullish Breakout", shape.triangleup,   location.belowbar, upCol, size=size.small)
plotshape(showBreaks and bearBreak, "Bearish Breakout", shape.triangledown, location.abovebar, dnCol, size=size.small)

if showLabels and (bullBreak or bearBreak)
    label.new(bar_index, na, bullBreak ? "Break ▲" : "Break ▼", yloc = bullBreak ? yloc.belowbar : yloc.abovebar, style = bullBreak ? label.style_label_up : label.style_label_down, color = bullBreak ? upCol : dnCol, textcolor = color.white, size = size.tiny)

// ── Data Window read-outs ────────────────────────────────────────────────
plot(divZ, "Divergence Z", display = display.data_window)
plot(zActive ? 1 : 0, "Zone Active", display = display.data_window)

// ── Alerts — two separate, selectable conditions (pick "Once Per Bar Close") ─
alertcondition(bullBreak, title="Bullish Breakout", message="Bullish Breakout")
alertcondition(bearBreak, title="Bearish Breakout", message="Bearish Breakout")
````

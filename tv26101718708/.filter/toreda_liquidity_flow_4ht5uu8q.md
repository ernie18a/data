# Toreda Liquidity Flow

- url: https://www.tradingview.com/script/4HT5uu8q-Toreda-Liquidity-Flow/
- type: indicator
- pine_id: PUB;929f73eb4db94292af7aa55177adbd22
- version: 2.0

## Description

# Toreda Liquidity Flow

**Pivot-based liquidity mapping with sweep detection, bias gauge, and right-edge strength histogram.**

---

## What it does

Toreda Liquidity Flow detects untapped buy-side and sell-side liquidity from confirmed swing pivots, scores each level by your chosen strength metric (volume, age, or touches), and tracks when price sweeps through them. A side panel summarizes the current bias; a right-edge histogram aggregates the surviving liquidity by price band so you can see at a glance where the heaviest unswept inventory sits.

This is **liquidity-based analysis, not volume profile**. The histogram on the right plots summed pivot strength per price band — not traded volume. Use it alongside a volume profile if you want both views.

---

## How to read the chart

- **Green horizontal lines (buy-side)** — unswept lows below current price. Likely resting buy stops / support.
- **Red horizontal lines (sell-side)** — unswept highs above current price. Likely resting sell stops / resistance.
- **Number next to each line** — the level's strength score (volume at the pivot bar by default).
- **Right-edge horizontal bars (histogram)** — total strength in each price band. Longer bar = more liquidity stacked at that price. Color matches side (green below current close, red above).
- **Bias panel (top-right)** — BULLISH / BEARISH / NEUTRAL based on the imbalance between unswept buy-side and sell-side strength within your bias lookback window.
- **✕ marks** (optional) — where a level got swept; the line dims but stays visible for context.

Non-repainting: every level is confirmed `Pivot Lookback` bars *after* the swing forms.

---

## Settings

### Core
- **Pivot Lookback (Sensitivity)** — bars required each side to confirm a pivot. Higher = fewer, stronger swings.
- **Max Levels per Side** — caps the number of active levels per side; older ones get pruned.
- **Remove Swept Levels** — delete on breach (clean chart) or keep dimmed with a ✕ mark (full history).
- **Sweep Confirmation** — *Wick* (any trade-through) or *Close* (bar must close beyond the level).

### Strength
- **Strength Metric** — Volume (snapshot at the pivot bar), Age (bars since formation), or Touches (proximity hits).
- **Minimum Strength to Display** — hide weak levels.
- **Touch Distance (ATR multiple)** — how close price must get to count as a touch.

### Filters
- **Detect Only Within Session** — restrict new-level detection to a specific session window.

### Visuals
- Colors, transparency, line width, label size.
- **Extend Lines to Right Edge** — long ribbons across the chart vs. short segments at origin.
- **Show Liquidity Histogram (right edge)** — toggles the right-side strength bars.
- **Histogram Bands** — number of price bands the level range is split into (more = thinner bars).
- **Histogram Max Bar Width** — width of the strongest band in chart bars; everything else scales relative to it.

### Bias Panel
- **Bias Calc Lookback (bars)** — only levels formed within this window contribute to the bias score.
- **Bias Threshold (%)** — magnitude of net imbalance required to flip out of NEUTRAL.

### Alerts
- **New Liquidity Formed** — fires when a new pivot-derived level is confirmed.
- **Liquidity Swept** — fires when any level is breached.

---

## How the bias is calculated

```
biasPct = (sellWeight - buyWeight) / total * 100

  >  +threshold  →  BEARISH (resistance overhead dominates)
  <  -threshold  →  BULLISH (support below dominates)
  else           →  NEUTRAL
```

Each unswept level contributes `max(strength, 1)` to its side's weight. Weighting by strength means a single high-volume pivot can outweigh several low-volume ones.

---

## Best timeframes and markets

- Designed for **intraday charts** (1m / 5m / 15m / 1h) on liquid instruments — futures (ES/NQ/MNQ), index ETFs, large-cap equities, major FX pairs.
- Higher timeframes work but produce fewer levels — bump `Pivot Lookback` down to compensate.
- Volume strength metric requires a market with reported volume. For symbols without volume (most spot FX), switch to **Age** or **Touches**.

---

## Limitations

- The histogram aggregates levels' price range, not the chart's visible range — if you zoom into a tight window, most bands will sit off-screen.
- Strength is captured at pivot formation, not continuously recomputed (except for Age, which updates each bar).
- Sweep detection is a single-bar check — wick mode can flag scratches; use Close mode for stricter confirmation.
- No higher-timeframe MTF aggregation — each instance is single-TF.

---

## Version

**v1.0** — Initial public release.

## Source Code

````pine
//@version=5
indicator("Toreda Liquidity Flow", "Toreda Liq Flow", overlay=true,
     max_lines_count=500, max_labels_count=500, max_boxes_count=500)

grpCore   = "Core"
grpStr    = "Strength"
grpFilt   = "Filters"
grpGaps   = "Fair Value Gaps"
grpViz    = "Visuals"
grpPanel  = "Bias Panel"
grpAlerts = "Alerts"
grpDebug  = "Debug"

pivLen        = input.int(10, "Pivot Lookback (Sensitivity)", minval=2, group=grpCore)
maxPerSide    = input.int(20, "Max Levels per Side", minval=1, maxval=100, group=grpCore)
removeSwept   = input.bool(true, "Remove Swept Levels", group=grpCore)
sweepMode     = input.string("Wick", "Sweep Confirmation", options=["Wick", "Close"], group=grpCore)

strMetric     = input.string("Volume", "Strength Metric", options=["Volume", "Age (bars)", "Touches"], group=grpStr)
minStrength   = input.float(0.0, "Minimum Strength to Display", minval=0.0, group=grpStr)
touchTolATR   = input.float(0.10, "Touch Distance (ATR multiple)", minval=0.0, step=0.05, group=grpStr)

useSession    = input.bool(false, "Detect Only Within Session", group=grpFilt)
sessStr       = input.session("0930-1600", "Session (when filter on)", group=grpFilt)

enableFVG_C    = input.bool(true,  "Detect FVG on Current TF", group=grpGaps)
enableFVG_H    = input.bool(false, "Detect FVG on Higher TF", group=grpGaps)
htfFVG         = input.timeframe("60", "Higher TF for FVG", group=grpGaps)
enableIFVG     = input.bool(true,  "Convert Filled FVG → IFVG", group=grpGaps)
fvgMinATR      = input.float(0.0, "Min FVG Size (ATR multiple)", minval=0.0, step=0.05, group=grpGaps)
fvgMaxAge      = input.int(200, "Max FVG Age (bars before pruning)", minval=10, maxval=2000, group=grpGaps)
colBullFVG     = input.color(color.new(#26a69a, 75), "Bullish FVG", group=grpGaps)
colBearFVG     = input.color(color.new(#ef5350, 75), "Bearish FVG", group=grpGaps)
colBullIFVG    = input.color(color.new(#42a5f5, 70), "Bullish IFVG (broken bear FVG)", group=grpGaps)
colBearIFVG    = input.color(color.new(#ab47bc, 70), "Bearish IFVG (broken bull FVG)", group=grpGaps)
showFVGLabel   = input.bool(true,  "Show FVG / IFVG text labels at right edge", group=grpGaps)
fvgLabelOffset = input.int(3, "Label Offset (bars right of latest)", minval=1, maxval=30, group=grpGaps)

buyCol        = input.color(#26a69a, "Buy-Side Color (support below)", group=grpViz)
sellCol       = input.color(#ef5350, "Sell-Side Color (resistance above)", group=grpViz)
lineTransp    = input.int(60, "Active Line Transparency", minval=0, maxval=100, group=grpViz)
sweptTransp   = input.int(85, "Swept Line Transparency", minval=0, maxval=100, group=grpViz)
lineWidthInp  = input.int(1, "Line Width", minval=1, maxval=4, group=grpViz)
labelSizeInp  = input.string("tiny", "Label Size", options=["tiny", "small", "normal"], group=grpViz)
extendRight   = input.bool(false, "Extend Lines to Right Edge", group=grpViz)
showSweepMark = input.bool(true, "Mark Sweep Points (✕)", group=grpViz)
showHist      = input.bool(true, "Show Liquidity Histogram (right edge)", group=grpViz)
histBands     = input.int(60, "Histogram Bands", minval=5, maxval=100, group=grpViz)
histBarWidth  = input.int(15, "Histogram Max Bar Width (bars)", minval=5, maxval=200, group=grpViz)

showPanel        = input.bool(true, "Show Bias Panel", group=grpPanel)
panelPos         = input.string("Top Right", "Panel Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group=grpPanel)
biasLookbackBars = input.int(200, "Bias Calc Lookback (bars)", minval=20, group=grpPanel)
biasThreshold    = input.float(15.0, "Bias Threshold (%)", minval=1.0, maxval=50.0, group=grpPanel)

alertNewLiq   = input.bool(false, "Alert on New Liquidity Formed", group=grpAlerts)
alertSweep    = input.bool(false, "Alert on Liquidity Sweep", group=grpAlerts)

debugMode     = input.bool(false, "Debug Mode", group=grpDebug)

type Liq
    float price
    int   originBar
    int   originTime
    string side
    float strength
    int   touches
    bool  swept
    line  ln
    label lb

type FVG
    float top
    float bot
    int   originBar
    bool  bullish
    bool  inverted
    string src
    box   bx
    label lb

var array<Liq> levels       = array.new<Liq>()
var array<FVG> fvgs         = array.new<FVG>()
var array<box> histBoxes    = array.new<box>()
var int        newLiqCount  = 0
var int        sweepCount   = 0
var table      panel        = na
var table      dbg          = na

f_labelSize() =>
    labelSizeInp == "tiny" ? size.tiny : labelSizeInp == "small" ? size.small : size.normal

f_lineCol(side, swept) =>
    base = side == "buy" ? buyCol : sellCol
    color.new(base, swept ? sweptTransp : lineTransp)

f_textCol(side, swept) =>
    base = side == "buy" ? buyCol : sellCol
    color.new(base, swept ? 60 : 20)

f_inSession() =>
    not useSession or not na(time(timeframe.period, sessStr))

f_panelPos() =>
    switch panelPos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        => position.top_right

f_extend() =>
    extendRight ? extend.right : extend.none

atrVal    = ta.atr(14)
touchDist = atrVal * touchTolATR

ph = ta.pivothigh(high, pivLen, pivLen)
pl = ta.pivotlow(low, pivLen, pivLen)

f_addLevel(price, side, originBarIdx, originT, vol) =>
    Liq lq = Liq.new()
    lq.price      := price
    lq.originBar  := originBarIdx
    lq.originTime := originT
    lq.side       := side
    lq.strength   := strMetric == "Volume" ? vol : strMetric == "Age (bars)" ? 0.0 : 1.0
    lq.touches    := 1
    lq.swept      := false
    lq.ln := line.new(x1=originT, y1=price, x2=time, y2=price,
         xloc=xloc.bar_time, color=f_lineCol(side, false),
         width=lineWidthInp, extend=f_extend())
    lq.lb := label.new(x=originT, y=price,
         text=str.tostring(int(math.round(lq.strength))),
         xloc=xloc.bar_time, yloc=yloc.price, style=label.style_none,
         textcolor=f_textCol(side, false), size=f_labelSize())
    array.push(levels, lq)

if not na(ph) and f_inSession()
    f_addLevel(ph, "sell", bar_index - pivLen, time[pivLen], volume[pivLen])
    newLiqCount += 1
if not na(pl) and f_inSession()
    f_addLevel(pl, "buy", bar_index - pivLen, time[pivLen], volume[pivLen])
    newLiqCount += 1

sweepFiredThisBar = false

if array.size(levels) > 0
    for i = array.size(levels) - 1 to 0
        Liq lq = array.get(levels, i)
        if not lq.swept
            if strMetric == "Age (bars)"
                newAge = bar_index - lq.originBar
                lq.strength := newAge
                label.set_text(lq.lb, str.tostring(int(newAge)))
            within = math.min(math.abs(high - lq.price), math.abs(low - lq.price)) <= touchDist
            if within and strMetric == "Touches"
                lq.touches  += 1
                lq.strength := lq.touches
                label.set_text(lq.lb, str.tostring(lq.touches))
            isSwept = false
            if lq.side == "sell"
                isSwept := sweepMode == "Wick" ? high > lq.price : close > lq.price
            else
                isSwept := sweepMode == "Wick" ? low  < lq.price : close < lq.price
            if isSwept
                lq.swept   := true
                sweepCount += 1
                sweepFiredThisBar := true
                if removeSwept
                    line.delete(lq.ln)
                    label.delete(lq.lb)
                    array.remove(levels, i)
                else
                    line.set_color(lq.ln, f_lineCol(lq.side, true))
                    label.set_textcolor(lq.lb, f_textCol(lq.side, true))
                    if showSweepMark
                        label.new(x=bar_index, y=lq.price, text="✕",
                             xloc=xloc.bar_index, yloc=yloc.price,
                             style=label.style_none, size=size.tiny,
                             textcolor=f_textCol(lq.side, false))
            if not lq.swept and lq.strength < minStrength
                line.set_color(lq.ln, color.new(color.gray, 100))
                label.set_textcolor(lq.lb, color.new(color.gray, 100))

f_pruneSide(side) =>
    cnt = 0
    if array.size(levels) > 0
        for i = array.size(levels) - 1 to 0
            Liq l = array.get(levels, i)
            if l.side == side and not l.swept
                cnt += 1
                if cnt > maxPerSide
                    line.delete(l.ln)
                    label.delete(l.lb)
                    array.remove(levels, i)
    cnt

if barstate.islast
    f_pruneSide("buy")
    f_pruneSide("sell")

f_fvgColor(FVG f) =>
    f.inverted ? (f.bullish ? colBearIFVG : colBullIFVG)
               : (f.bullish ? colBullFVG  : colBearFVG)

f_fvgText(FVG f) =>
    base = f.inverted ? "IFVG" : "FVG"
    f.src == "H" ? htfFVG + " " + base : base

f_drawFVGBox(FVG f) =>
    col = f_fvgColor(f)
    box.new(left=f.originBar, top=f.top, right=bar_index, bottom=f.bot,
         border_color=color.new(col, 100), border_width=0, bgcolor=col,
         xloc=xloc.bar_index, extend=extend.right)

f_drawFVGLabel(FVG f) =>
    col = f_fvgColor(f)
    label.new(x=bar_index + fvgLabelOffset, y=(f.top + f.bot) / 2,
         text=f_fvgText(f),
         xloc=xloc.bar_index, yloc=yloc.price,
         style=label.style_none,
         textcolor=color.new(col, 0),
         size=size.small)

if enableFVG_C and bar_index >= 2 and barstate.isconfirmed
    bullGap = low > high[2]
    bearGap = high < low[2]
    if bullGap or bearGap
        topPx   = bullGap ? low      : low[2]
        botPx   = bullGap ? high[2]  : high
        gapSize = topPx - botPx
        if gapSize >= atrVal * fvgMinATR
            f = FVG.new()
            f.top       := topPx
            f.bot       := botPx
            f.originBar := bar_index - 2
            f.bullish   := bullGap
            f.inverted  := false
            f.src       := "C"
            f.bx        := f_drawFVGBox(f)
            f.lb        := showFVGLabel ? f_drawFVGLabel(f) : na
            array.push(fvgs, f)

[htfH_p, htfL_p, htfH_3, htfL_3] = request.security(syminfo.tickerid, htfFVG,
     [high[1], low[1], high[3], low[3]], lookahead=barmerge.lookahead_off)
htfBarTime    = request.security(syminfo.tickerid, htfFVG, time, lookahead=barmerge.lookahead_off)
htfBarChanged = ta.change(htfBarTime) != 0

if enableFVG_H and htfBarChanged and not na(htfH_3) and not na(htfL_3)
    bullGapH = htfL_p > htfH_3
    bearGapH = htfH_p < htfL_3
    if bullGapH or bearGapH
        topH   = bullGapH ? htfL_p : htfL_3
        botH   = bullGapH ? htfH_3 : htfH_p
        sizeH  = topH - botH
        if sizeH >= atrVal * fvgMinATR
            fH = FVG.new()
            fH.top       := topH
            fH.bot       := botH
            fH.originBar := bar_index
            fH.bullish   := bullGapH
            fH.inverted  := false
            fH.src       := "H"
            fH.bx        := f_drawFVGBox(fH)
            fH.lb        := showFVGLabel ? f_drawFVGLabel(fH) : na
            array.push(fvgs, fH)

if array.size(fvgs) > 0
    for i = array.size(fvgs) - 1 to 0
        FVG f = array.get(fvgs, i)
        if bar_index - f.originBar > fvgMaxAge
            box.delete(f.bx)
            if not na(f.lb)
                label.delete(f.lb)
            array.remove(fvgs, i)
            continue
        if not f.inverted
            broken = f.bullish ? close < f.bot : close > f.top
            if broken
                if enableIFVG
                    f.inverted := true
                    newCol = f_fvgColor(f)
                    box.set_bgcolor(f.bx, newCol)
                    box.set_border_color(f.bx, color.new(newCol, 100))
                    if not na(f.lb)
                        label.set_text(f.lb, f_fvgText(f))
                        label.set_textcolor(f.lb, color.new(newCol, 0))
                else
                    box.delete(f.bx)
                    if not na(f.lb)
                        label.delete(f.lb)
                    array.remove(fvgs, i)
                    continue
        else
            returned = f.bullish ? close >= f.bot : close <= f.top
            if returned
                box.delete(f.bx)
                if not na(f.lb)
                    label.delete(f.lb)
                array.remove(fvgs, i)
                continue

if showFVGLabel and barstate.islast and array.size(fvgs) > 0
    for i = 0 to array.size(fvgs) - 1
        FVG f = array.get(fvgs, i)
        if not na(f.lb)
            label.set_x(f.lb, bar_index + fvgLabelOffset)
            label.set_y(f.lb, (f.top + f.bot) / 2)

f_calcBias() =>
    bs = 0.0
    ss = 0.0
    if array.size(levels) > 0
        for i = 0 to array.size(levels) - 1
            Liq l = array.get(levels, i)
            if not l.swept and (bar_index - l.originBar) <= biasLookbackBars
                w = math.max(l.strength, 1.0)
                if l.side == "buy"
                    bs += w
                else
                    ss += w
    [bs, ss]

[buyScoreV, sellScoreV] = f_calcBias()
totalScore = buyScoreV + sellScoreV
biasPct    = totalScore > 0 ? (sellScoreV - buyScoreV) / totalScore * 100 : 0.0
biasLabel  = biasPct > biasThreshold ? "BEARISH" : biasPct < -biasThreshold ? "BULLISH" : "NEUTRAL"
biasBg     = biasPct > biasThreshold ? color.new(sellCol, 0) :
             biasPct < -biasThreshold ? color.new(buyCol, 0) : color.new(color.gray, 0)

buyActive  = 0
sellActive = 0
if array.size(levels) > 0
    for i = 0 to array.size(levels) - 1
        Liq l = array.get(levels, i)
        if not l.swept
            if l.side == "buy"
                buyActive += 1
            else
                sellActive += 1

if barstate.islast
    if not na(panel)
        table.delete(panel)
        panel := na
    if showPanel
        panel := table.new(f_panelPos(), 2, 5,
             frame_color=color.new(color.gray, 60), frame_width=1,
             border_color=color.new(color.gray, 70), border_width=1)
        table.cell(panel, 0, 0, "Toreda Liquidity Flow",
             text_color=color.white, text_size=size.small,
             bgcolor=color.new(color.black, 30))
        table.cell(panel, 1, 0, "v1.0",
             text_color=color.new(color.gray, 30), text_size=size.tiny,
             bgcolor=color.new(color.black, 30))
        table.cell(panel, 0, 1, "Bias",
             text_color=color.new(color.gray, 20), text_size=size.small)
        table.cell(panel, 1, 1, biasLabel,
             text_color=color.white, text_size=size.small, bgcolor=biasBg)
        table.cell(panel, 0, 2, "Sell-side levels",
             text_color=color.new(color.gray, 20), text_size=size.tiny)
        table.cell(panel, 1, 2, str.tostring(sellActive),
             text_color=color.new(sellCol, 0), text_size=size.tiny)
        table.cell(panel, 0, 3, "Buy-side levels",
             text_color=color.new(color.gray, 20), text_size=size.tiny)
        table.cell(panel, 1, 3, str.tostring(buyActive),
             text_color=color.new(buyCol, 0), text_size=size.tiny)
        table.cell(panel, 0, 4, "Sweeps (total)",
             text_color=color.new(color.gray, 20), text_size=size.tiny)
        table.cell(panel, 1, 4, str.tostring(sweepCount),
             text_color=color.white, text_size=size.tiny)

if barstate.islast
    if array.size(histBoxes) > 0
        for i = 0 to array.size(histBoxes) - 1
            box.delete(array.get(histBoxes, i))
        array.clear(histBoxes)
    if showHist and array.size(levels) > 0
        priceHi    = -1e10
        priceLo    =  1e10
        anyUnswept = false
        for i = 0 to array.size(levels) - 1
            Liq l = array.get(levels, i)
            if not l.swept
                priceHi    := math.max(priceHi, l.price)
                priceLo    := math.min(priceLo, l.price)
                anyUnswept := true
        if anyUnswept and priceHi > priceLo
            bandHeight    = (priceHi - priceLo) / histBands
            bandStrengths = array.new<float>(histBands, 0.0)
            for i = 0 to array.size(levels) - 1
                Liq l = array.get(levels, i)
                if not l.swept
                    bandIdx = int(math.floor((l.price - priceLo) / bandHeight))
                    bandIdx := math.max(0, math.min(histBands - 1, bandIdx))
                    array.set(bandStrengths, bandIdx,
                         array.get(bandStrengths, bandIdx) + math.max(l.strength, 1.0))
            maxStr = 0.0
            for b = 0 to histBands - 1
                maxStr := math.max(maxStr, array.get(bandStrengths, b))
            if maxStr > 0
                for b = 0 to histBands - 1
                    s = array.get(bandStrengths, b)
                    if s > 0
                        bandLo  = priceLo + b * bandHeight
                        bandHi  = bandLo + bandHeight
                        bandMid = (bandLo + bandHi) / 2
                        wBars   = int(math.round(s / maxStr * histBarWidth))
                        if wBars >= 1
                            col = bandMid >= close ? sellCol : buyCol
                            bx  = box.new(left=bar_index, top=bandHi,
                                 right=bar_index + wBars, bottom=bandLo,
                                 border_color=color.new(col, 0), border_width=1,
                                 bgcolor=color.new(col, 40))
                            array.push(histBoxes, bx)

if barstate.islast
    if not na(dbg)
        table.delete(dbg)
        dbg := na
    if debugMode
        dbg := table.new(position.bottom_left, 2, 6,
             frame_color=color.new(color.yellow, 70), frame_width=1)
        table.cell(dbg, 0, 0, "DEBUG", text_color=color.yellow, text_size=size.small)
        table.cell(dbg, 1, 0, "", text_color=color.yellow, text_size=size.tiny)
        table.cell(dbg, 0, 1, "Levels stored", text_color=color.gray, text_size=size.tiny)
        table.cell(dbg, 1, 1, str.tostring(array.size(levels)), text_color=color.white, text_size=size.tiny)
        table.cell(dbg, 0, 2, "New liq total", text_color=color.gray, text_size=size.tiny)
        table.cell(dbg, 1, 2, str.tostring(newLiqCount), text_color=color.white, text_size=size.tiny)
        table.cell(dbg, 0, 3, "Sweep total", text_color=color.gray, text_size=size.tiny)
        table.cell(dbg, 1, 3, str.tostring(sweepCount), text_color=color.white, text_size=size.tiny)
        table.cell(dbg, 0, 4, "ATR(14)", text_color=color.gray, text_size=size.tiny)
        table.cell(dbg, 1, 4, str.tostring(atrVal, "#.##"), text_color=color.white, text_size=size.tiny)
        table.cell(dbg, 0, 5, "Bias %", text_color=color.gray, text_size=size.tiny)
        table.cell(dbg, 1, 5, str.tostring(biasPct, "#.#") + "%", text_color=color.white, text_size=size.tiny)

newLiqEvent = (not na(ph) or not na(pl)) and f_inSession()
alertcondition(newLiqEvent,
     title="New Liquidity Formed",
     message="New liquidity level detected on {{ticker}} {{interval}}")
alertcondition(sweepFiredThisBar,
     title="Liquidity Swept",
     message="Liquidity swept on {{ticker}} {{interval}} at {{close}}")
````

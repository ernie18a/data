# Daily Bias Structure Map

- url: https://www.tradingview.com/script/fNchXh6w-Daily-Bias-Structure-Map/
- type: indicator
- pine_id: PUB;6b42ce60f3c74d84b5b1e4235688cb72
- version: 1.0

## Description

Daily Bias Structure Map

An automated market-structure tool that reads swing highs/lows the same way a discretionary ICT-style trader would — and marks up your chart with the exact levels you'd draw by hand: origin, break of structure, liquidity target, and equilibrium.

What it does

The indicator tracks pivot highs and lows in real time. When price closes back through the most recent unbroken pivot, it registers a break of structure (BOS) and flips bias — then automatically plots:

- BOS line— the swing that was just broken, confirming the shift in bias
- Origin line — the opposing swing that started the current leg
- Liquidity target— the next untapped swing beyond the BOS, i.e. the level price is being drawn toward
- Equilibrium (50%)-  the midpoint between origin and liquidity target
- Premium / Discount zones— labeled above and below equilibrium, so you can see at a glance whether price is in a favorable zone to enter with bias, or extended and better left alone
- Structure trendline— connects the origin swing to the most recent higher low (in a bullish leg) or lower high (in a bearish leg), extended forward
- Bias label — a pinned box in the top-left corner showing BULLISH / BEARISH / NEUTRAL, updating live as structure shifts

All levels and the bias label recalculate and redraw automatically on every new BOS, so the chart never gets cluttered with stale lines.

**How to use it**

1. Add it to your higher-timeframe chart (daily or 4H is standard) to establish directional bias before session trading.
2. Treat BULLISH as "look for longs only," BEARISH as "look for shorts only" — the model works best when you don't fight the labeled bias.
3. Use the premium/discount split to time entries: buy from discount in a bullish bias, sell from premium in a bearish bias, rather than chasing price mid-range.
4. Drop to a lower timeframe (5–15m) for your actual trigger (liquidity sweep + MSS + FVG/OB entry) once bias is established here.
5. Enable alerts for "Bullish BOS" / "Bearish BOS" to get notified the moment structure shifts, without watching the chart.

**Settings**

- *Pivot Lookback* — controls how significant a swing must be to register (higher = fewer, more major swing points; lower = more responsive but noisier)
- Toggle equilibrium, premium/discount labels, liquidity target, origin line, and trendline independently
- Customizable bullish/bearish colors and label text size

**Notes**

Pivots confirm with a lookback delay (standard for any swing-based tool), so the most recent 1–2 candles' structure may adjust slightly as new bars print. This is a bias/context tool, not a standalone entry signal — pair it with your own lower-timeframe confirmation and risk management. Not financial advice.

## Source Code

````pine
//@version=6
indicator("Daily Bias Structure Map", overlay=true, max_lines_count=200, max_labels_count=200)

// ============ INPUTS ============
pivotLen      = input.int(5, "Pivot Lookback (bars)", minval=2)
showEQ        = input.bool(true, "Show Equilibrium (50%)")
showPremDisc  = input.bool(true, "Show Premium / Discount Labels")
showLiquidity = input.bool(true, "Show Liquidity Target")
showTrendline = input.bool(true, "Show Structure Trendline")
showOrigin    = input.bool(true, "Show Origin Line")
bullColor     = input.color(#1a7a3c, "Bullish Color")
bearColor     = input.color(#c9432d, "Bearish Color")
labelSizeStr  = input.string("small", "Label Text Size", options=["tiny", "small", "normal", "large"])

lblSize = size.small
if labelSizeStr == "tiny"
    lblSize := size.tiny
if labelSizeStr == "normal"
    lblSize := size.normal
if labelSizeStr == "large"
    lblSize := size.large

// ============ PIVOT TRACKING (last 2 highs, last 2 lows) ============
var float ph1 = na
var int   ph1Bar = na
var float ph2 = na
var int   ph2Bar = na
var bool  ph1Broken = false

var float pl1 = na
var int   pl1Bar = na
var float pl2 = na
var int   pl2Bar = na
var bool  pl1Broken = false

ph = ta.pivothigh(pivotLen, pivotLen)
pl = ta.pivotlow(pivotLen, pivotLen)

// ============ BOS DETECTION — MUST RUN BEFORE PIVOT VALUES UPDATE ============
// (checks against the level confirmed as of the END of the previous bar only)
bullBOS = not ph1Broken and not na(ph1) and ta.crossover(close, ph1)
bearBOS = not pl1Broken and not na(pl1) and ta.crossunder(close, pl1)

// ============ NOW UPDATE PIVOT TRACKING (after the check above) ============
if not na(ph)
    ph2 := ph1
    ph2Bar := ph1Bar
    ph1 := ph
    ph1Bar := bar_index - pivotLen
    ph1Broken := false

if not na(pl)
    pl2 := pl1
    pl2Bar := pl1Bar
    pl1 := pl
    pl1Bar := bar_index - pivotLen
    pl1Broken := false

// ============ STATE ============
var string bias = "neutral"
var float  bosLevel = na
var int    bosBar = na
var float  originLevel = na
var int    originBar = na
var float  liqTarget = na
var float  structPoint = na
var int    structPointBar = na

var line  trendLine = na
var line  bosLine = na
var line  liqLine = na
var line  eqLine = na
var line  originLine = na
var label bosTag = na
var label liqTag = na
var label eqTag = na
var label originTag = na
var label premTag = na
var label discTag = na

if bullBOS
    ph1Broken := true
    bias := "bullish"
    bosLevel := ph1[1]
    bosBar := ph1Bar[1]
    originLevel := pl1[1]
    originBar := pl1Bar[1]
    liqTarget := (not na(ph2[1]) and ph2[1] > ph1[1]) ? ph2[1] : na
    structPoint := na
    structPointBar := na

if bearBOS
    pl1Broken := true
    bias := "bearish"
    bosLevel := pl1[1]
    bosBar := pl1Bar[1]
    originLevel := ph1[1]
    originBar := ph1Bar[1]
    liqTarget := (not na(pl2[1]) and pl2[1] < pl1[1]) ? pl2[1] : na
    structPoint := na
    structPointBar := na

// wipe old drawings on any flip
if bullBOS or bearBOS
    line.delete(trendLine)
    line.delete(bosLine)
    line.delete(liqLine)
    line.delete(eqLine)
    line.delete(originLine)
    label.delete(bosTag)
    label.delete(liqTag)
    label.delete(eqTag)
    label.delete(originTag)
    label.delete(premTag)
    label.delete(discTag)
    trendLine := na
    bosLine := na
    liqLine := na
    eqLine := na
    originLine := na
    bosTag := na
    liqTag := na
    eqTag := na
    originTag := na
    premTag := na
    discTag := na

// ============ DRAWING ============
if bias != "neutral" and not na(bosLevel)
    bColor = bias == "bullish" ? bullColor : bearColor
    bosText = "BOS  " + str.tostring(bosLevel, format.mintick)
    if na(bosLine)
        bosLine := line.new(bosBar, bosLevel, bar_index, bosLevel, color=bColor, width=2, style=line.style_dashed, extend=extend.right)
        bosTag := label.new(bar_index, bosLevel, bosText, style=label.style_label_left, color=bColor, textcolor=color.white, size=lblSize)
    else
        label.set_x(bosTag, bar_index)

    if showOrigin and not na(originLevel)
        originText = "ORIGIN  " + str.tostring(originLevel, format.mintick)
        if na(originLine)
            originLine := line.new(originBar, originLevel, bar_index, originLevel, color=color.new(bColor, 45), width=1, style=line.style_dotted, extend=extend.right)
            originTag := label.new(bar_index, originLevel, originText, style=label.style_label_left, color=color.new(bColor, 45), textcolor=color.white, size=lblSize)
        else
            label.set_x(originTag, bar_index)

    if showLiquidity and not na(liqTarget)
        liqText = "LIQUIDITY  " + str.tostring(liqTarget, format.mintick)
        if na(liqLine)
            liqLine := line.new(bosBar, liqTarget, bar_index, liqTarget, color=color.orange, width=2, style=line.style_dashed, extend=extend.right)
            liqTag := label.new(bar_index, liqTarget, liqText, style=label.style_label_left, color=color.orange, textcolor=color.white, size=lblSize)
        else
            label.set_x(liqTag, bar_index)

    farLevel = na(liqTarget) ? bosLevel : liqTarget
    eqLevel = not na(originLevel) ? (originLevel + farLevel) / 2 : na

    if showEQ and not na(eqLevel)
        eqText = "EQ 50%  " + str.tostring(eqLevel, format.mintick)
        if na(eqLine)
            eqLine := line.new(originBar, eqLevel, bar_index, eqLevel, color=color.blue, width=1, style=line.style_dashed, extend=extend.right)
            eqTag := label.new(bar_index, eqLevel, eqText, style=label.style_label_left, color=color.blue, textcolor=color.white, size=lblSize)
        else
            label.set_x(eqTag, bar_index)

        if showPremDisc
            premMid = bias == "bullish" ? eqLevel + (farLevel - eqLevel) / 2 : originLevel - (originLevel - eqLevel) / 2
            discMid = bias == "bullish" ? originLevel + (eqLevel - originLevel) / 2 : eqLevel - (eqLevel - farLevel) / 2
            if na(premTag)
                premTag := label.new(bar_index, premMid, "PREMIUM", style=label.style_label_left, color=color.new(color.red, 70), textcolor=color.red, size=lblSize)
                discTag := label.new(bar_index, discMid, "DISCOUNT", style=label.style_label_left, color=color.new(color.green, 70), textcolor=color.green, size=lblSize)
            else
                label.set_x(premTag, bar_index)
                label.set_x(discTag, bar_index)

    if bias == "bullish" and not na(pl) and pl > originLevel
        if na(structPoint) or (bar_index - pivotLen) > structPointBar
            structPoint := pl
            structPointBar := bar_index - pivotLen

    if bias == "bearish" and not na(ph) and ph < originLevel
        if na(structPoint) or (bar_index - pivotLen) > structPointBar
            structPoint := ph
            structPointBar := bar_index - pivotLen

    if showTrendline and not na(structPoint)
        if na(trendLine)
            trendLine := line.new(originBar, originLevel, structPointBar, structPoint, color=color.aqua, width=2, extend=extend.right)
        else
            line.set_xy1(trendLine, originBar, originLevel)
            line.set_xy2(trendLine, structPointBar, structPoint)

// ============ BIAS LABEL ============
var table biasTable = table.new(position.top_left, 1, 1)
biasTxt = bias == "bullish" ? "DAILY BIAS: BULLISH" : bias == "bearish" ? "DAILY BIAS: BEARISH" : "DAILY BIAS: NEUTRAL"
biasCol = bias == "bullish" ? bullColor : bias == "bearish" ? bearColor : color.gray
table.cell(biasTable, 0, 0, biasTxt, text_color=color.white, bgcolor=biasCol, text_size=size.normal)

// ============ ALERTS ============
alertcondition(bullBOS, title="Bullish BOS", message="Bullish break of structure — daily bias flipped bullish")
alertcondition(bearBOS, title="Bearish BOS", message="Bearish break of structure — daily bias flipped bearish")
````

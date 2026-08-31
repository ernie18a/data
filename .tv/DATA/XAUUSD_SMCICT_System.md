<!-- tradingview-pine-id: PUB;0223a523e20b40ae85606ac75f8e7f7f -->
<!-- tradingviewscripts-format: 1 -->
# XAUUSD SMC/ICT System

Source: https://www.tradingview.com/script/pK8gLBef-OSAMA-ZALLOUM-V2/

## Description

//@version=6
indicator("XAUUSD SMC/ICT System", shorttitle="XAU SMC-ICT", overlay=true, max_boxes_count=300, max_lines_count=300, max_labels_count=300)

// ============================================================================
// INPUTS
// ============================================================================

swingLen      = input.int(5, "Swing Pivot Length", minval=2, maxval=50, group="Market Structure", tooltip="Lower = faster/more sensitive. Higher = major structure only. Suggested: H4/D=7-8, H1=5-6, M15=5, M5=8-10.")
showStructure = input.bool(true, "Show BOS / CHoCH Labels", group="Market Structure")
showSwingSR   = input.bool(true, "Show Auto Support/Resistance", group="Market Structure")
maxSRLines    = input.int(6, "Max S/R Lines Kept", minval=1, maxval=20, group="Market Structure")

showOB       = input.bool(true, "Show Order Blocks", group="Order Blocks")
obSearchBars = input.int(15, "OB Search Window (bars)", minval=3, maxval=50, group="Order Blocks")
maxOBBoxes   = input.int(4, "Max Order Blocks per Side", minval=1, maxval=20, group="Order Blocks")
bullOBColor  = input.color(color.new(color.teal, 82), "Bullish OB Color", group="Order Blocks")
bearOBColor  = input.color(color.new(color.red, 82), "Bearish OB Color", group="Order Blocks")

showFVG       = input.bool(true, "Show Fair Value Gaps", group="Fair Value Gap")
maxFVGBoxes   = input.int(5, "Max FVG Boxes per Side", minval=1, maxval=30, group="Fair Value Gap")
minFVGSizeATR = input.float(0.0, "Min FVG Size (x ATR, 0 = off)", minval=0.0, maxval=5.0, step=0.1, group="Fair Value Gap", tooltip="Filters out small gaps. Raise to 0.3-0.5 during strong trends when FVGs stack up too much.")
bullFVGColor  = input.color(color.new(color.blue, 82), "Bullish FVG Color", group="Fair Value Gap")
bearFVGColor  = input.color(color.new(color.orange, 82), "Bearish FVG Color", group="Fair Value Gap")

showLiquidity  = input.bool(true, "Show Equal Highs/Lows", group="Liquidity")
eqTolerancePct = input.float(0.10, "Equal High/Low Tolerance (%)", minval=0.01, maxval=2.0, step=0.01, group="Liquidity")
maxEQLines     = input.int(6, "Max Liquidity Lines Kept", minval=1, maxval=20, group="Liquidity")
showSweeps     = input.bool(true, "Show Liquidity Sweeps", group="Liquidity")

showFib       = input.bool(true, "Show Auto Fibonacci (last swing leg)", group="Fibonacci")
showOTEZone   = input.bool(true, "Highlight OTE Zone (0.618 - 0.79)", group="Fibonacci")
fibExtendBars = input.int(20, "Fibonacci Right Extension (bars)", minval=5, maxval=100, group="Fibonacci")

// ============================================================================
// SWING / MARKET STRUCTURE (BOS / CHoCH)
// ============================================================================

ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

var float lastSwingHighVal = na
var int   lastSwingHighBar = na
var float prevSwingHighVal = na
var int   prevSwingHighBar = na

var float lastSwingLowVal = na
var int   lastSwingLowBar = na
var float prevSwingLowVal = na
var int   prevSwingLowBar = na

var bool brokeHighFlag = false
var bool brokeLowFlag  = false
var int  trendState    = 0

if not na(ph)
    prevSwingHighVal := lastSwingHighVal
    prevSwingHighBar := lastSwingHighBar
    lastSwingHighVal := ph
    lastSwingHighBar := bar_index - swingLen
    brokeHighFlag := false

if not na(pl)
    prevSwingLowVal := lastSwingLowVal
    prevSwingLowBar := lastSwingLowBar
    lastSwingLowVal := pl
    lastSwingLowBar := bar_index - swingLen
    brokeLowFlag := false

bullBreak = not na(lastSwingHighVal) and close > lastSwingHighVal and not brokeHighFlag
bearBreak = not na(lastSwingLowVal) and close < lastSwingLowVal and not brokeLowFlag

if bullBreak
    brokeHighFlag := true
    if showStructure
        label.new(bar_index, low, trendState == 1 ? "BOS" : "CHoCH", style=label.style_label_up, color=color.new(color.green, 0), textcolor=color.white, size=size.tiny)
    trendState := 1

if bearBreak
    brokeLowFlag := true
    if showStructure
        label.new(bar_index, high, trendState == -1 ? "BOS" : "CHoCH", style=label.style_label_down, color=color.new(color.red, 0), textcolor=color.white, size=size.tiny)
    trendState := -1

var array<line> srLines = array.new<line>()

if showSwingSR and not na(ph)
    srLineH = line.new(bar_index - swingLen, ph, bar_index, ph, color=color.new(color.red, 40), style=line.style_dashed, extend=extend.right)
    array.push(srLines, srLineH)
    if array.size(srLines) > maxSRLines
        line.delete(array.shift(srLines))

if showSwingSR and not na(pl)
    srLineL = line.new(bar_index - swingLen, pl, bar_index, pl, color=color.new(color.teal, 40), style=line.style_dashed, extend=extend.right)
    array.push(srLines, srLineL)
    if array.size(srLines) > maxSRLines
        line.delete(array.shift(srLines))

// ============================================================================
// ORDER BLOCKS
// ============================================================================

var array<box> bullOBBoxes = array.new<box>()
var array<box> bearOBBoxes = array.new<box>()

if showOB and bullBreak
    float obTop = na
    float obBottom = na
    int obBar = na
    for i = 1 to obSearchBars
        if close < open
            obTop := high
            obBottom := low
            obBar := bar_index - i
            break
    if not na(obBar)
        obBoxBull = box.new(left=obBar, top=obTop, right=bar_index, bottom=obBottom, border_color=color.teal, bgcolor=bullOBColor, text="OB", text_size=size.tiny, text_color=color.teal)
        array.push(bullOBBoxes, obBoxBull)
        if array.size(bullOBBoxes) > maxOBBoxes
            box.delete(array.shift(bullOBBoxes))

if showOB and bearBreak
    float obTop2 = na
    float obBottom2 = na
    int obBar2 = na
    for i = 1 to obSearchBars
        if close > open
            obTop2 := high
            obBottom2 := low
            obBar2 := bar_index - i
            break
    if not na(obBar2)
        obBoxBear = box.new(left=obBar2, top=obTop2, right=bar_index, bottom=obBottom2, border_color=color.red, bgcolor=bearOBColor, text="OB", text_size=size.tiny, text_color=color.red)
        array.push(bearOBBoxes, obBoxBear)
        if array.size(bearOBBoxes) > maxOBBoxes
            box.delete(array.shift(bearOBBoxes))

if array.size(bullOBBoxes) > 0
    for i = array.size(bullOBBoxes) - 1 to 0
        obB = array.get(bullOBBoxes, i)
        if close < box.get_bottom(obB)
            box.delete(obB)
            array.remove(bullOBBoxes, i)
        else
            box.set_right(obB, bar_index)

if array.size(bearOBBoxes) > 0
    for i = array.size(bearOBBoxes) - 1 to 0
        obB2 = array.get(bearOBBoxes, i)
        if close > box.get_top(obB2)
            box.delete(obB2)
            array.remove(bearOBBoxes, i)
        else
            box.set_right(obB2, bar_index)

// ============================================================================
// FAIR VALUE GAPS (FVG)
// ============================================================================

atrVal = ta.atr(14)

var array<box> bullFVGBoxes = array.new<box>()
var array<box> bearFVGBoxes = array.new<box>()

bullFVG = low > high[2] and (minFVGSizeATR == 0 or (low - high[2]) > atrVal * minFVGSizeATR)
bearFVG = high < low[2] and (minFVGSizeATR == 0 or (low[2] - high) > atrVal * minFVGSizeATR)

if showFVG and bullFVG
    fvgBoxBull = box.new(left=bar_index - 2, top=low, right=bar_index, bottom=high[2], border_color=color.blue, bgcolor=bullFVGColor, text="FVG", text_size=size.tiny, text_color=color.blue)
    array.push(bullFVGBoxes, fvgBoxBull)
    if array.size(bullFVGBoxes) > maxFVGBoxes
        box.delete(array.shift(bullFVGBoxes))

if showFVG and bearFVG
    fvgBoxBear = box.new(left=bar_index - 2, top=low[2], right=bar_index, bottom=high, border_color=color.orange, bgcolor=bearFVGColor, text="FVG", text_size=size.tiny, text_color=color.orange)
    array.push(bearFVGBoxes, fvgBoxBear)
    if array.size(bearFVGBoxes) > maxFVGBoxes
        box.delete(array.shift(bearFVGBoxes))

if array.size(bullFVGBoxes) > 0
    for i = array.size(bullFVGBoxes) - 1 to 0
        fvgB = array.get(bullFVGBoxes, i)
        if close < box.get_bottom(fvgB)
            box.delete(fvgB)
            array.remove(bullFVGBoxes, i)
        else
            box.set_right(fvgB, bar_index)

if array.size(bearFVGBoxes) > 0
    for i = array.size(bearFVGBoxes) - 1 to 0
        fvgB2 = array.get(bearFVGBoxes, i)
        if close > box.get_top(fvgB2)
            box.delete(fvgB2)
            array.remove(bearFVGBoxes, i)
        else
            box.set_right(fvgB2, bar_index)

// ============================================================================
// LIQUIDITY: EQUAL HIGHS / LOWS + SWEEPS
// ============================================================================

var array<line>  eqLines  = array.new<line>()
var array<label> eqLabels = array.new<label>()

if showLiquidity and not na(ph) and not na(prevSwingHighVal)
    if math.abs(ph - prevSwingHighVal) <= prevSwingHighVal * eqTolerancePct / 100
        eqLineH  = line.new(prevSwingHighBar, prevSwingHighVal, bar_index - swingLen, ph, color=color.new(color.fuchsia, 20), width=2)
        eqLabelH = label.new(bar_index - swingLen, ph, "EQH", style=label.style_label_down, color=color.new(color.fuchsia, 20), textcolor=color.fuchsia, size=size.tiny)
        array.push(eqLines, eqLineH)
        array.push(eqLabels, eqLabelH)
        if array.size(eqLines) > maxEQLines
            line.delete(array.shift(eqLines))
            label.delete(array.shift(eqLabels))

if showLiquidity and not na(pl) and not na(prevSwingLowVal)
    if math.abs(pl - prevSwingLowVal) <= prevSwingLowVal * eqTolerancePct / 100
        eqLineL  = line.new(prevSwingLowBar, prevSwingLowVal, bar_index - swingLen, pl, color=color.new(color.fuchsia, 20), width=2)
        eqLabelL = label.new(bar_index - swingLen, pl, "EQL", style=label.style_label_up, color=color.new(color.fuchsia, 20), textcolor=color.fuchsia, size=size.tiny)
        array.push(eqLines, eqLineL)
        array.push(eqLabels, eqLabelL)
        if array.size(eqLines) > maxEQLines
            line.delete(array.shift(eqLines))
            label.delete(array.shift(eqLabels))

var bool sweptLowFlag  = false
var bool sweptHighFlag = false

if not na(pl)
    sweptLowFlag := false
if not na(ph)
    sweptHighFlag := false

bullishSweep = showSweeps and not na(lastSwingLowVal) and low < lastSwingLowVal and close > lastSwingLowVal and not sweptLowFlag
bearishSweep = showSweeps and not na(lastSwingHighVal) and high > lastSwingHighVal and close < lastSwingHighVal and not sweptHighFlag

if bullishSweep
    sweptLowFlag := true
    label.new(bar_index, low, "Sweep", style=label.style_label_up, color=color.new(color.lime, 0), textcolor=color.black, size=size.tiny)

if bearishSweep
    sweptHighFlag := true
    label.new(bar_index, high, "Sweep", style=label.style_label_down, color=color.new(color.maroon, 0), textcolor=color.white, size=size.tiny)

// ============================================================================
// AUTO FIBONACCI (from most recent swing leg) + OTE ZONE
// ============================================================================

var line fibLine0   = na
var line fibLine236 = na
var line fibLine382 = na
var line fibLine5   = na
var line fibLine618 = na
var line fibLine79  = na
var line fibLine100 = na
var box  oteBox     = na

updateFib = showFib and (not na(ph) or not na(pl)) and not na(lastSwingHighVal) and not na(lastSwingLowVal)

if updateFib
    line.delete(fibLine0)
    line.delete(fibLine236)
    line.delete(fibLine382)
    line.delete(fibLine5)
    line.delete(fibLine618)
    line.delete(fibLine79)
    line.delete(fibLine100)
    box.delete(oteBox)

    bool upLeg   = lastSwingHighBar > lastSwingLowBar
    float hi     = lastSwingHighVal
    float lo     = lastSwingLowVal
    float diff   = hi - lo
    int leftBar  = upLeg ? lastSwingLowBar : lastSwingHighBar
    int rightBar = bar_index + fibExtendBars

    float lv0   = upLeg ? hi : lo
    float lv236 = upLeg ? hi - diff * 0.236 : lo + diff * 0.236
    float lv382 = upLeg ? hi - diff * 0.382 : lo + diff * 0.382
    float lv5   = upLeg ? hi - diff * 0.5   : lo + diff * 0.5
    float lv618 = upLeg ? hi - diff * 0.618 : lo + diff * 0.618
    float lv79  = upLeg ? hi - diff * 0.79  : lo + diff * 0.79
    float lv100 = upLeg ? lo : hi

    fibLine0   := line.new(leftBar, lv0,   rightBar, lv0,   color=color.new(color.gray, 30))
    fibLine236 := line.new(leftBar, lv236, rightBar, lv236, color=color.new(color.gray, 30))
    fibLine382 := line.new(leftBar, lv382, rightBar, lv382, color=color.new(color.gray, 30))
    fibLine5   := line.new(leftBar, lv5,   rightBar, lv5,   color=color.new(color.gray, 30))
    fibLine618 := line.new(leftBar, lv618, rightBar, lv618, color=color.new(color.yellow, 20))
    fibLine79  := line.new(leftBar, lv79,  rightBar, lv79,  color=color.new(color.yellow, 20))
    fibLine100 := line.new(leftBar, lv100, rightBar, lv100, color=color.new(color.gray, 30))

    if showOTEZone
        oteBox := box.new(left=leftBar, top=math.max(lv618, lv79), right=rightBar, bottom=math.min(lv618, lv79), bgcolor=color.new(color.yellow, 85), border_color=color.new(color.yellow, 50), text="OTE", text_size=size.tiny)

// ============================================================================
// BIAS INFO PANEL
// ============================================================================

var table infoTable = table.new(position.top_right, 1, 1, bgcolor=color.new(color.black, 70), border_width=1, border_color=color.gray)

if barstate.islast
    string biasText  = trendState == 1 ? "BIAS: BULLISH" : trendState == -1 ? "BIAS: BEARISH" : "BIAS: NEUTRAL"
    color  biasColor = trendState == 1 ? color.lime : trendState == -1 ? color.red : color.gray
    table.cell(infoTable, 0, 0, biasText, text_color=biasColor, text_size=size.small)

// ============================================================================
// ALERTS
// ============================================================================

alertcondition(bullBreak, title="Bullish BOS/CHoCH", message="XAUUSD: Bullish structure break")
alertcondition(bearBreak, title="Bearish BOS/CHoCH", message="XAUUSD: Bearish structure break")
alertcondition(bullishSweep, title="Bullish Liquidity Sweep", message="XAUUSD: Bullish liquidity sweep detected")
alertcondition(bearishSweep, title="Bearish Liquidity Sweep", message="XAUUSD: Bearish liquidity sweep detected")

---

## Source Code

````pine
//@version=6
indicator("XAUUSD SMC/ICT System", shorttitle="XAU SMC-ICT", overlay=true, max_boxes_count=300, max_lines_count=300, max_labels_count=300)

// ============================================================================
// INPUTS
// ============================================================================

swingLen      = input.int(5, "Swing Pivot Length", minval=2, maxval=50, group="Market Structure", tooltip="Lower = faster/more sensitive. Higher = major structure only. Suggested: H4/D=7-8, H1=5-6, M15=5, M5=8-10.")
showStructure = input.bool(true, "Show BOS / CHoCH Labels", group="Market Structure")
showSwingSR   = input.bool(true, "Show Auto Support/Resistance", group="Market Structure")
maxSRLines    = input.int(6, "Max S/R Lines Kept", minval=1, maxval=20, group="Market Structure")

showOB       = input.bool(true, "Show Order Blocks", group="Order Blocks")
obSearchBars = input.int(15, "OB Search Window (bars)", minval=3, maxval=50, group="Order Blocks")
maxOBBoxes   = input.int(4, "Max Order Blocks per Side", minval=1, maxval=20, group="Order Blocks")
bullOBColor  = input.color(color.new(color.teal, 82), "Bullish OB Color", group="Order Blocks")
bearOBColor  = input.color(color.new(color.red, 82), "Bearish OB Color", group="Order Blocks")

showFVG       = input.bool(true, "Show Fair Value Gaps", group="Fair Value Gap")
maxFVGBoxes   = input.int(5, "Max FVG Boxes per Side", minval=1, maxval=30, group="Fair Value Gap")
minFVGSizeATR = input.float(0.0, "Min FVG Size (x ATR, 0 = off)", minval=0.0, maxval=5.0, step=0.1, group="Fair Value Gap", tooltip="Filters out small gaps. Raise to 0.3-0.5 during strong trends when FVGs stack up too much.")
bullFVGColor  = input.color(color.new(color.blue, 82), "Bullish FVG Color", group="Fair Value Gap")
bearFVGColor  = input.color(color.new(color.orange, 82), "Bearish FVG Color", group="Fair Value Gap")

showLiquidity  = input.bool(true, "Show Equal Highs/Lows", group="Liquidity")
eqTolerancePct = input.float(0.10, "Equal High/Low Tolerance (%)", minval=0.01, maxval=2.0, step=0.01, group="Liquidity")
maxEQLines     = input.int(6, "Max Liquidity Lines Kept", minval=1, maxval=20, group="Liquidity")
showSweeps     = input.bool(true, "Show Liquidity Sweeps", group="Liquidity")

showFib       = input.bool(true, "Show Auto Fibonacci (last swing leg)", group="Fibonacci")
showOTEZone   = input.bool(true, "Highlight OTE Zone (0.618 - 0.79)", group="Fibonacci")
fibExtendBars = input.int(20, "Fibonacci Right Extension (bars)", minval=5, maxval=100, group="Fibonacci")

// ============================================================================
// SWING / MARKET STRUCTURE (BOS / CHoCH)
// ============================================================================

ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

var float lastSwingHighVal = na
var int   lastSwingHighBar = na
var float prevSwingHighVal = na
var int   prevSwingHighBar = na

var float lastSwingLowVal = na
var int   lastSwingLowBar = na
var float prevSwingLowVal = na
var int   prevSwingLowBar = na

var bool brokeHighFlag = false
var bool brokeLowFlag  = false
var int  trendState    = 0

if not na(ph)
    prevSwingHighVal := lastSwingHighVal
    prevSwingHighBar := lastSwingHighBar
    lastSwingHighVal := ph
    lastSwingHighBar := bar_index - swingLen
    brokeHighFlag := false

if not na(pl)
    prevSwingLowVal := lastSwingLowVal
    prevSwingLowBar := lastSwingLowBar
    lastSwingLowVal := pl
    lastSwingLowBar := bar_index - swingLen
    brokeLowFlag := false

bullBreak = not na(lastSwingHighVal) and close > lastSwingHighVal and not brokeHighFlag
bearBreak = not na(lastSwingLowVal) and close < lastSwingLowVal and not brokeLowFlag

if bullBreak
    brokeHighFlag := true
    if showStructure
        label.new(bar_index, low, trendState == 1 ? "BOS" : "CHoCH", style=label.style_label_up, color=color.new(color.green, 0), textcolor=color.white, size=size.tiny)
    trendState := 1

if bearBreak
    brokeLowFlag := true
    if showStructure
        label.new(bar_index, high, trendState == -1 ? "BOS" : "CHoCH", style=label.style_label_down, color=color.new(color.red, 0), textcolor=color.white, size=size.tiny)
    trendState := -1

var array<line> srLines = array.new<line>()

if showSwingSR and not na(ph)
    srLineH = line.new(bar_index - swingLen, ph, bar_index, ph, color=color.new(color.red, 40), style=line.style_dashed, extend=extend.right)
    array.push(srLines, srLineH)
    if array.size(srLines) > maxSRLines
        line.delete(array.shift(srLines))

if showSwingSR and not na(pl)
    srLineL = line.new(bar_index - swingLen, pl, bar_index, pl, color=color.new(color.teal, 40), style=line.style_dashed, extend=extend.right)
    array.push(srLines, srLineL)
    if array.size(srLines) > maxSRLines
        line.delete(array.shift(srLines))

// ============================================================================
// ORDER BLOCKS
// ============================================================================

var array<box> bullOBBoxes = array.new<box>()
var array<box> bearOBBoxes = array.new<box>()

if showOB and bullBreak
    float obTop = na
    float obBottom = na
    int obBar = na
    for i = 1 to obSearchBars
        if close[i] < open[i]
            obTop := high[i]
            obBottom := low[i]
            obBar := bar_index - i
            break
    if not na(obBar)
        obBoxBull = box.new(left=obBar, top=obTop, right=bar_index, bottom=obBottom, border_color=color.teal, bgcolor=bullOBColor, text="OB", text_size=size.tiny, text_color=color.teal)
        array.push(bullOBBoxes, obBoxBull)
        if array.size(bullOBBoxes) > maxOBBoxes
            box.delete(array.shift(bullOBBoxes))

if showOB and bearBreak
    float obTop2 = na
    float obBottom2 = na
    int obBar2 = na
    for i = 1 to obSearchBars
        if close[i] > open[i]
            obTop2 := high[i]
            obBottom2 := low[i]
            obBar2 := bar_index - i
            break
    if not na(obBar2)
        obBoxBear = box.new(left=obBar2, top=obTop2, right=bar_index, bottom=obBottom2, border_color=color.red, bgcolor=bearOBColor, text="OB", text_size=size.tiny, text_color=color.red)
        array.push(bearOBBoxes, obBoxBear)
        if array.size(bearOBBoxes) > maxOBBoxes
            box.delete(array.shift(bearOBBoxes))

if array.size(bullOBBoxes) > 0
    for i = array.size(bullOBBoxes) - 1 to 0
        obB = array.get(bullOBBoxes, i)
        if close < box.get_bottom(obB)
            box.delete(obB)
            array.remove(bullOBBoxes, i)
        else
            box.set_right(obB, bar_index)

if array.size(bearOBBoxes) > 0
    for i = array.size(bearOBBoxes) - 1 to 0
        obB2 = array.get(bearOBBoxes, i)
        if close > box.get_top(obB2)
            box.delete(obB2)
            array.remove(bearOBBoxes, i)
        else
            box.set_right(obB2, bar_index)

// ============================================================================
// FAIR VALUE GAPS (FVG)
// ============================================================================

atrVal = ta.atr(14)

var array<box> bullFVGBoxes = array.new<box>()
var array<box> bearFVGBoxes = array.new<box>()

bullFVG = low > high[2] and (minFVGSizeATR == 0 or (low - high[2]) > atrVal * minFVGSizeATR)
bearFVG = high < low[2] and (minFVGSizeATR == 0 or (low[2] - high) > atrVal * minFVGSizeATR)

if showFVG and bullFVG
    fvgBoxBull = box.new(left=bar_index - 2, top=low, right=bar_index, bottom=high[2], border_color=color.blue, bgcolor=bullFVGColor, text="FVG", text_size=size.tiny, text_color=color.blue)
    array.push(bullFVGBoxes, fvgBoxBull)
    if array.size(bullFVGBoxes) > maxFVGBoxes
        box.delete(array.shift(bullFVGBoxes))

if showFVG and bearFVG
    fvgBoxBear = box.new(left=bar_index - 2, top=low[2], right=bar_index, bottom=high, border_color=color.orange, bgcolor=bearFVGColor, text="FVG", text_size=size.tiny, text_color=color.orange)
    array.push(bearFVGBoxes, fvgBoxBear)
    if array.size(bearFVGBoxes) > maxFVGBoxes
        box.delete(array.shift(bearFVGBoxes))

if array.size(bullFVGBoxes) > 0
    for i = array.size(bullFVGBoxes) - 1 to 0
        fvgB = array.get(bullFVGBoxes, i)
        if close < box.get_bottom(fvgB)
            box.delete(fvgB)
            array.remove(bullFVGBoxes, i)
        else
            box.set_right(fvgB, bar_index)

if array.size(bearFVGBoxes) > 0
    for i = array.size(bearFVGBoxes) - 1 to 0
        fvgB2 = array.get(bearFVGBoxes, i)
        if close > box.get_top(fvgB2)
            box.delete(fvgB2)
            array.remove(bearFVGBoxes, i)
        else
            box.set_right(fvgB2, bar_index)

// ============================================================================
// LIQUIDITY: EQUAL HIGHS / LOWS + SWEEPS
// ============================================================================

var array<line>  eqLines  = array.new<line>()
var array<label> eqLabels = array.new<label>()

if showLiquidity and not na(ph) and not na(prevSwingHighVal)
    if math.abs(ph - prevSwingHighVal) <= prevSwingHighVal * eqTolerancePct / 100
        eqLineH  = line.new(prevSwingHighBar, prevSwingHighVal, bar_index - swingLen, ph, color=color.new(color.fuchsia, 20), width=2)
        eqLabelH = label.new(bar_index - swingLen, ph, "EQH", style=label.style_label_down, color=color.new(color.fuchsia, 20), textcolor=color.fuchsia, size=size.tiny)
        array.push(eqLines, eqLineH)
        array.push(eqLabels, eqLabelH)
        if array.size(eqLines) > maxEQLines
            line.delete(array.shift(eqLines))
            label.delete(array.shift(eqLabels))

if showLiquidity and not na(pl) and not na(prevSwingLowVal)
    if math.abs(pl - prevSwingLowVal) <= prevSwingLowVal * eqTolerancePct / 100
        eqLineL  = line.new(prevSwingLowBar, prevSwingLowVal, bar_index - swingLen, pl, color=color.new(color.fuchsia, 20), width=2)
        eqLabelL = label.new(bar_index - swingLen, pl, "EQL", style=label.style_label_up, color=color.new(color.fuchsia, 20), textcolor=color.fuchsia, size=size.tiny)
        array.push(eqLines, eqLineL)
        array.push(eqLabels, eqLabelL)
        if array.size(eqLines) > maxEQLines
            line.delete(array.shift(eqLines))
            label.delete(array.shift(eqLabels))

var bool sweptLowFlag  = false
var bool sweptHighFlag = false

if not na(pl)
    sweptLowFlag := false
if not na(ph)
    sweptHighFlag := false

bullishSweep = showSweeps and not na(lastSwingLowVal) and low < lastSwingLowVal and close > lastSwingLowVal and not sweptLowFlag
bearishSweep = showSweeps and not na(lastSwingHighVal) and high > lastSwingHighVal and close < lastSwingHighVal and not sweptHighFlag

if bullishSweep
    sweptLowFlag := true
    label.new(bar_index, low, "Sweep", style=label.style_label_up, color=color.new(color.lime, 0), textcolor=color.black, size=size.tiny)

if bearishSweep
    sweptHighFlag := true
    label.new(bar_index, high, "Sweep", style=label.style_label_down, color=color.new(color.maroon, 0), textcolor=color.white, size=size.tiny)

// ============================================================================
// AUTO FIBONACCI (from most recent swing leg) + OTE ZONE
// ============================================================================

var line fibLine0   = na
var line fibLine236 = na
var line fibLine382 = na
var line fibLine5   = na
var line fibLine618 = na
var line fibLine79  = na
var line fibLine100 = na
var box  oteBox     = na

updateFib = showFib and (not na(ph) or not na(pl)) and not na(lastSwingHighVal) and not na(lastSwingLowVal)

if updateFib
    line.delete(fibLine0)
    line.delete(fibLine236)
    line.delete(fibLine382)
    line.delete(fibLine5)
    line.delete(fibLine618)
    line.delete(fibLine79)
    line.delete(fibLine100)
    box.delete(oteBox)

    bool upLeg   = lastSwingHighBar > lastSwingLowBar
    float hi     = lastSwingHighVal
    float lo     = lastSwingLowVal
    float diff   = hi - lo
    int leftBar  = upLeg ? lastSwingLowBar : lastSwingHighBar
    int rightBar = bar_index + fibExtendBars

    float lv0   = upLeg ? hi : lo
    float lv236 = upLeg ? hi - diff * 0.236 : lo + diff * 0.236
    float lv382 = upLeg ? hi - diff * 0.382 : lo + diff * 0.382
    float lv5   = upLeg ? hi - diff * 0.5   : lo + diff * 0.5
    float lv618 = upLeg ? hi - diff * 0.618 : lo + diff * 0.618
    float lv79  = upLeg ? hi - diff * 0.79  : lo + diff * 0.79
    float lv100 = upLeg ? lo : hi

    fibLine0   := line.new(leftBar, lv0,   rightBar, lv0,   color=color.new(color.gray, 30))
    fibLine236 := line.new(leftBar, lv236, rightBar, lv236, color=color.new(color.gray, 30))
    fibLine382 := line.new(leftBar, lv382, rightBar, lv382, color=color.new(color.gray, 30))
    fibLine5   := line.new(leftBar, lv5,   rightBar, lv5,   color=color.new(color.gray, 30))
    fibLine618 := line.new(leftBar, lv618, rightBar, lv618, color=color.new(color.yellow, 20))
    fibLine79  := line.new(leftBar, lv79,  rightBar, lv79,  color=color.new(color.yellow, 20))
    fibLine100 := line.new(leftBar, lv100, rightBar, lv100, color=color.new(color.gray, 30))

    if showOTEZone
        oteBox := box.new(left=leftBar, top=math.max(lv618, lv79), right=rightBar, bottom=math.min(lv618, lv79), bgcolor=color.new(color.yellow, 85), border_color=color.new(color.yellow, 50), text="OTE", text_size=size.tiny)

// ============================================================================
// BIAS INFO PANEL
// ============================================================================

var table infoTable = table.new(position.top_right, 1, 1, bgcolor=color.new(color.black, 70), border_width=1, border_color=color.gray)

if barstate.islast
    string biasText  = trendState == 1 ? "BIAS: BULLISH" : trendState == -1 ? "BIAS: BEARISH" : "BIAS: NEUTRAL"
    color  biasColor = trendState == 1 ? color.lime : trendState == -1 ? color.red : color.gray
    table.cell(infoTable, 0, 0, biasText, text_color=biasColor, text_size=size.small)

// ============================================================================
// ALERTS
// ============================================================================

alertcondition(bullBreak, title="Bullish BOS/CHoCH", message="XAUUSD: Bullish structure break")
alertcondition(bearBreak, title="Bearish BOS/CHoCH", message="XAUUSD: Bearish structure break")
alertcondition(bullishSweep, title="Bullish Liquidity Sweep", message="XAUUSD: Bullish liquidity sweep detected")
alertcondition(bearishSweep, title="Bearish Liquidity Sweep", message="XAUUSD: Bearish liquidity sweep detected")
````

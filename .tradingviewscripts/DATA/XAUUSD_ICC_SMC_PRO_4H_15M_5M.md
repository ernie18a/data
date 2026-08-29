<!-- tradingview-pine-id: PUB;2b18a6c1b0f4442cb8a260798f8fe948 -->
<!-- tradingviewscripts-format: 1 -->
# XAUUSD ICC SMC PRO 4H 15M 5M

Source: https://www.tradingview.com/script/SyWSSQai-XAUUSD-ICC-SMC-PRO-4H-15M-5M/

## Description

XAU/USD ICC + SMC Multi-Timeframe Indicator
The XAU/USD ICC + SMC Multi-Timeframe Indicator is designed to identify high-probability continuation setups by combining Indication, Correction and Continuation (ICC) with Supply & Demand, Liquidity Sweeps, CHoCH, BOS and multi-timeframe market structure.
The indicator follows a strict top-down process using 4H → 15M → 5M analysis.
4H – Indication and Supply/Demand
The 4-hour timeframe defines the main market direction and the institutional area of interest.
When price creates a confirmed Break of Structure (BOS), the indicator searches for the last opposite candle responsible for the displacement.
For a bullish structure, this area is marked as a 4H Demand Zone.
For a bearish structure, it is marked as a 4H Supply Zone.
The zone is automatically displayed as a rectangle and extended forward until price returns to it.
The 4H stage represents the INDICATION phase of the ICC model.
15M – Liquidity Sweep and CHoCH
Once price returns inside the 4H Supply or Demand zone, the indicator begins analyzing the 15-minute structure.
For a bullish setup, price must first take Sell-Side Liquidity below a previous 15M low and then close back above that level.
For a bearish setup, price must take Buy-Side Liquidity above a previous 15M high and close back below it.
A liquidity sweep alone is not considered an entry signal.
The indicator waits for a Change of Character (CHoCH) confirming that the short-term market structure is beginning to reverse.
The relationship between liquidity sweeps, displacement, CHoCH and BOS is similar to the structure shown in the example diagrams above. 
15M – BOS Confirmation
After CHoCH, the system waits for another structural break in the same direction.
This second break is identified as the 15M BOS confirmation.
For a bullish setup:
Sell-Side Liquidity Sweep → Bullish CHoCH → Bullish BOS
For a bearish setup:
Buy-Side Liquidity Sweep → Bearish CHoCH → Bearish BOS
BOS is used primarily as a continuation confirmation, while CHoCH indicates a possible structural transition. 
15M – Correction
After the BOS confirmation, the indicator waits for the market to retrace.
This retracement becomes the CORRECTION phase of the ICC model.
For a bullish setup, bearish 15-minute candles forming after the bullish BOS are monitored.
For a bearish setup, bullish candles forming after the bearish BOS are monitored.
The entire correction area is highlighted with an orange rectangle.
The indicator continuously tracks the highest and lowest points of the correction.
Correction Trendline
During the correction, the indicator automatically searches for swing points that allow it to build a correction trendline.
For a bullish setup, the correction normally creates a descending structure.
The indicator therefore draws a descending resistance trendline across the correction highs.
For a bearish setup, it draws an ascending support trendline across the correction lows.
The trendline is important because the indicator does not consider the correction finished simply because price touches an Order Block.
End of Correction
The correction ends only when price breaks the correction trendline in the direction of the original 4H setup.
Bullish sequence:
Correction → Descending Trendline → Bullish Trendline Break
Bearish sequence:
Correction → Ascending Trendline → Bearish Trendline Break
At this stage the indicator displays:
CORRECTION ENDED
TRENDLINE BREAK
CONTINUATION
This represents the transition from Correction → Continuation.
5M – Execution Zone
After the 15M continuation is confirmed, the indicator moves to the 5-minute execution logic.
For a bullish setup, it waits for a 5M bullish BOS and identifies the last bearish candle that created the displacement.
That candle becomes the new 5M Demand Zone.
For a bearish setup, the last bullish candle before the bearish displacement becomes the 5M Supply Zone.
Order Blocks combined with structural breaks are commonly visualized in this way, as shown in the example chart above. 
The indicator then displays:
5M DEMAND – WAIT FOR RETEST
or
5M SUPPLY – WAIT FOR RETEST
Final BUY Signal
A BUY signal requires the complete sequence:
4H Bullish BOS
→ 4H Demand
→ Sell-Side Liquidity Sweep
→ 15M Bullish CHoCH
→ 15M Bullish BOS
→ 15M Correction
→ Correction Trendline Break
→ 5M Bullish BOS
→ 5M Demand
→ Demand Retest
→ Bullish Reaction
→ STRONG BUY
The indicator will not generate a BUY signal simply because price enters a Demand zone.
Final SELL Signal
The bearish process is the exact opposite:
4H Bearish BOS
→ 4H Supply
→ Buy-Side Liquidity Sweep
→ 15M Bearish CHoCH
→ 15M Bearish BOS
→ 15M Correction
→ Correction Trendline Break
→ 5M Bearish BOS
→ 5M Supply
→ Supply Retest
→ Bearish Reaction
→ STRONG SELL
Visual Color Guide
Green rectangle: 4H/5M Demand Zone
Red rectangle: 4H/5M Supply Zone
Yellow label: Liquidity Sweep
Aqua label: CHoCH
Blue label: BOS
Orange rectangle: Correction
Green/Red trendline: Correction structure
Large green label: STRONG BUY
Large red label: STRONG SELL
ICC Logic
The complete model can therefore be summarized as:
INDICATION
4H BOS + Supply/Demand
↓
CORRECTION PREPARATION
Liquidity Sweep + CHoCH + 15M BOS
↓
CORRECTION
15M retracement + correction trendline
↓
CONTINUATION
Trendline Break + 5M BOS + Demand/Supply retest
↓
EXECUTION
STRONG BUY or STRONG SELL
This structure is intentionally strict. Its purpose is to filter out ordinary Order Block touches and wait for liquidity manipulation, structural confirmation, correction and continuation before displaying the final trading signal.

Instant

---

## Source Code

````pine
//@version=6
indicator("XAUUSD ICC SMC PRO 4H 15M 5M", overlay=true, max_boxes_count=100, max_lines_count=100, max_labels_count=300)

//====================================================
// INPUTS
//====================================================

swing4H = input.int(3, "4H Structure Length", minval=2)
swing15 = input.int(3, "15M Structure Length", minval=2)
swing5 = input.int(3, "5M Structure Length", minval=2)

show4HZone = input.bool(true, "Show 4H Supply Demand")
show15Correction = input.bool(true, "Show 15M Correction")
showTrendline = input.bool(true, "Show 15M Correction Trendline")
show5Zone = input.bool(true, "Show 5M Supply Demand")
showLabels = input.bool(true, "Show Labels")
showDashboard = input.bool(true, "Show Dashboard")

//====================================================
// HTF STRUCTURE FUNCTION
// Returns CONFIRMED previous HTF candle information
//====================================================

f_structure(int len) =>
    ph = ta.pivothigh(high, len, len)
    pl = ta.pivotlow(low, len, len)

    var float lastHigh = na
    var float lastLow = na

    if not na(ph)
        lastHigh := ph

    if not na(pl)
        lastLow := pl

    bullBos = not na(lastHigh) and close > lastHigh and close[1] <= lastHigh
    bearBos = not na(lastLow) and close < lastLow and close[1] >= lastLow

    bullSweep = not na(lastLow) and low < lastLow and close > lastLow
    bearSweep = not na(lastHigh) and high > lastHigh and close < lastHigh

    bullOBHigh = ta.valuewhen(close < open, high, 0)
    bullOBLow = ta.valuewhen(close < open, low, 0)
    bullOBTime = ta.valuewhen(close < open, time, 0)

    bearOBHigh = ta.valuewhen(close > open, high, 0)
    bearOBLow = ta.valuewhen(close > open, low, 0)
    bearOBTime = ta.valuewhen(close > open, time, 0)

    [bullBos[1], bearBos[1], bullSweep[1], bearSweep[1], lastHigh[1], lastLow[1], bullOBHigh[1], bullOBLow[1], bullOBTime[1], bearOBHigh[1], bearOBLow[1], bearOBTime[1], open[1], high[1], low[1], close[1], time[1]]

//====================================================
// 4H DATA
//====================================================

[bullBos4, bearBos4, bullSweep4, bearSweep4, swingHigh4, swingLow4, bullOBHigh4, bullOBLow4, bullOBTime4, bearOBHigh4, bearOBLow4, bearOBTime4, o4, h4, l4, c4, t4] = request.security(syminfo.tickerid, "240", f_structure(swing4H), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

//====================================================
// 15M DATA
//====================================================

[bullBos15, bearBos15, bullSweep15, bearSweep15, swingHigh15, swingLow15, bullOBHigh15, bullOBLow15, bullOBTime15, bearOBHigh15, bearOBLow15, bearOBTime15, o15, h15, l15, c15, t15] = request.security(syminfo.tickerid, "15", f_structure(swing15), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

//====================================================
// NEW CONFIRMED HTF EVENTS
//====================================================

newBullBos4 = bullBos4 and not bullBos4[1]
newBearBos4 = bearBos4 and not bearBos4[1]

newBullBos15 = bullBos15 and not bullBos15[1]
newBearBos15 = bearBos15 and not bearBos15[1]

newBullSweep15 = bullSweep15 and not bullSweep15[1]
newBearSweep15 = bearSweep15 and not bearSweep15[1]

new15Bar = not na(t15) and t15 != t15[1]

//====================================================
// STATE MACHINE
//
//  0  = WAITING
//
// 10  = 4H DEMAND ACTIVE
// 11  = SELL-SIDE LIQUIDITY SWEPT
// 12  = BULLISH CHOCH
// 13  = BULLISH BOS
// 14  = BULLISH CORRECTION
// 15  = BULL TRENDLINE BROKEN
// 16  = 5M DEMAND ACTIVE
//
// -10 = 4H SUPPLY ACTIVE
// -11 = BUY-SIDE LIQUIDITY SWEPT
// -12 = BEARISH CHOCH
// -13 = BEARISH BOS
// -14 = BEARISH CORRECTION
// -15 = BEAR TRENDLINE BROKEN
// -16 = 5M SUPPLY ACTIVE
//====================================================

var int state = 0

//====================================================
// OBJECTS
//====================================================

var box zone4HBox = na
var box correction15Box = na
var box execution5Box = na

var line correctionLine = na

//====================================================
// ACTIVE 4H ZONE
//====================================================

var float zone4Top = na
var float zone4Bottom = na
var int zone4Time = na

//====================================================
// 4H BULLISH BOS -> DEMAND
//====================================================

if newBullBos4
    state := 10

    zone4Top := bullOBHigh4
    zone4Bottom := bullOBLow4
    zone4Time := bullOBTime4

    if not na(zone4HBox)
        box.delete(zone4HBox)

    if not na(correction15Box)
        box.delete(correction15Box)

    if not na(execution5Box)
        box.delete(execution5Box)

    if not na(correctionLine)
        line.delete(correctionLine)

    if show4HZone and not na(zone4Time)
        zone4HBox := box.new(zone4Time, zone4Top, time, zone4Bottom, xloc=xloc.bar_time, extend=extend.right, border_color=color.lime, border_width=3, bgcolor=color.new(color.lime, 86))

    if showLabels
        label.new(bar_index, low, "4H INDICATION\nBOS BULLISH\nDEMAND", style=label.style_label_up, color=color.green, textcolor=color.white)

//====================================================
// 4H BEARISH BOS -> SUPPLY
//====================================================

if newBearBos4
    state := -10

    zone4Top := bearOBHigh4
    zone4Bottom := bearOBLow4
    zone4Time := bearOBTime4

    if not na(zone4HBox)
        box.delete(zone4HBox)

    if not na(correction15Box)
        box.delete(correction15Box)

    if not na(execution5Box)
        box.delete(execution5Box)

    if not na(correctionLine)
        line.delete(correctionLine)

    if show4HZone and not na(zone4Time)
        zone4HBox := box.new(zone4Time, zone4Top, time, zone4Bottom, xloc=xloc.bar_time, extend=extend.right, border_color=color.red, border_width=3, bgcolor=color.new(color.red, 86))

    if showLabels
        label.new(bar_index, high, "4H INDICATION\nBOS BEARISH\nSUPPLY", style=label.style_label_down, color=color.red, textcolor=color.white)

//====================================================
// PRICE INSIDE 4H ZONE
//====================================================

inside4H = not na(zone4Top) and not na(zone4Bottom) and high >= zone4Bottom and low <= zone4Top

//====================================================
// 15M LIQUIDITY SWEEP
// Bullish setup = Sell-Side Liquidity Sweep
//====================================================

bullLiquiditySweep = state == 10 and inside4H and newBullSweep15

if bullLiquiditySweep
    state := 11

    if showLabels
        label.new(bar_index, low, "15M\nSELL-SIDE LIQUIDITY\nSWEEP", style=label.style_label_up, color=color.yellow, textcolor=color.black)

//====================================================
// 15M LIQUIDITY SWEEP
// Bearish setup = Buy-Side Liquidity Sweep
//====================================================

bearLiquiditySweep = state == -10 and inside4H and newBearSweep15

if bearLiquiditySweep
    state := -11

    if showLabels
        label.new(bar_index, high, "15M\nBUY-SIDE LIQUIDITY\nSWEEP", style=label.style_label_down, color=color.yellow, textcolor=color.black)

//====================================================
// 15M CHOCH
// First structural break AFTER sweep
//====================================================

bullChoch = state == 11 and newBullBos15
bearChoch = state == -11 and newBearBos15

if bullChoch
    state := 12

    if showLabels
        label.new(bar_index, low, "15M CHoCH\nBULLISH", style=label.style_label_up, color=color.aqua, textcolor=color.black)

if bearChoch
    state := -12

    if showLabels
        label.new(bar_index, high, "15M CHoCH\nBEARISH", style=label.style_label_down, color=color.aqua, textcolor=color.black)

//====================================================
// SECOND 15M STRUCTURAL BREAK = BOS
//====================================================

bullBosConfirmation = state == 12 and newBullBos15
bearBosConfirmation = state == -12 and newBearBos15

if bullBosConfirmation
    state := 13

    if showLabels
        label.new(bar_index, low, "15M BOS\nCONFIRMED", style=label.style_label_up, color=color.blue, textcolor=color.white)

if bearBosConfirmation
    state := -13

    if showLabels
        label.new(bar_index, high, "15M BOS\nCONFIRMED", style=label.style_label_down, color=color.blue, textcolor=color.white)

//====================================================
// CORRECTION VARIABLES
//====================================================

var float correctionTop = na
var float correctionBottom = na

var float correctionFirstHigh = na
var float correctionFirstLow = na

var int correctionStartBar = na
var int correctionStartTime = na

var bool trendlineReady = false

//====================================================
// START BULLISH CORRECTION
// First confirmed bearish 15M candle after bullish BOS
//====================================================

startBullCorrection = state == 13 and new15Bar and c15 < o15

if startBullCorrection
    state := 14

    correctionTop := h15
    correctionBottom := l15

    correctionFirstHigh := h15
    correctionFirstLow := l15

    correctionStartBar := bar_index
    correctionStartTime := t15

    trendlineReady := false

    if not na(correction15Box)
        box.delete(correction15Box)

    if show15Correction
        correction15Box := box.new(t15, h15, time, l15, xloc=xloc.bar_time, extend=extend.right, border_color=color.orange, border_width=2, bgcolor=color.new(color.orange, 86))

    if not na(correctionLine)
        line.delete(correctionLine)

    if showLabels
        label.new(bar_index, low, "15M CORRECTION\nSTART", style=label.style_label_up, color=color.orange, textcolor=color.white)

//====================================================
// START BEARISH CORRECTION
// First confirmed bullish 15M candle after bearish BOS
//====================================================

startBearCorrection = state == -13 and new15Bar and c15 > o15

if startBearCorrection
    state := -14

    correctionTop := h15
    correctionBottom := l15

    correctionFirstHigh := h15
    correctionFirstLow := l15

    correctionStartBar := bar_index
    correctionStartTime := t15

    trendlineReady := false

    if not na(correction15Box)
        box.delete(correction15Box)

    if show15Correction
        correction15Box := box.new(t15, h15, time, l15, xloc=xloc.bar_time, extend=extend.right, border_color=color.orange, border_width=2, bgcolor=color.new(color.orange, 86))

    if not na(correctionLine)
        line.delete(correctionLine)

    if showLabels
        label.new(bar_index, high, "15M CORRECTION\nSTART", style=label.style_label_down, color=color.orange, textcolor=color.white)

//====================================================
// TRACK BULLISH CORRECTION
// Build descending resistance trendline
//====================================================

if state == 14 and new15Bar
    correctionTop := math.max(correctionTop, h15)
    correctionBottom := math.min(correctionBottom, l15)

    if not na(correction15Box)
        box.set_top(correction15Box, correctionTop)
        box.set_bottom(correction15Box, correctionBottom)

    lowerHighFound = h15 < correctionFirstHigh and bar_index > correctionStartBar

    if lowerHighFound
        if na(correctionLine)
            correctionLine := line.new(correctionStartBar, correctionFirstHigh, bar_index, h15, xloc=xloc.bar_index, extend=extend.right, color=color.lime, width=3)
        else
            line.set_xy2(correctionLine, bar_index, h15)

        trendlineReady := true

//====================================================
// TRACK BEARISH CORRECTION
// Build ascending support trendline
//====================================================

if state == -14 and new15Bar
    correctionTop := math.max(correctionTop, h15)
    correctionBottom := math.min(correctionBottom, l15)

    if not na(correction15Box)
        box.set_top(correction15Box, correctionTop)
        box.set_bottom(correction15Box, correctionBottom)

    higherLowFound = l15 > correctionFirstLow and bar_index > correctionStartBar

    if higherLowFound
        if na(correctionLine)
            correctionLine := line.new(correctionStartBar, correctionFirstLow, bar_index, l15, xloc=xloc.bar_index, extend=extend.right, color=color.red, width=3)
        else
            line.set_xy2(correctionLine, bar_index, l15)

        trendlineReady := true

//====================================================
// TRENDLINE VALUE
//====================================================

float trendPrice = na

if not na(correctionLine)
    trendPrice := line.get_price(correctionLine, bar_index)

//====================================================
// END OF BULLISH CORRECTION
//====================================================

bullTrendBreak = state == 14 and trendlineReady and not na(trendPrice) and close > trendPrice and close > open

if bullTrendBreak
    state := 15

    if not na(correction15Box)
        box.set_extend(correction15Box, extend.none)
        box.set_right(correction15Box, time)

    if showLabels
        label.new(bar_index, low, "CORRECTION ENDED\nTRENDLINE BREAK\nCONTINUATION", style=label.style_label_up, color=color.green, textcolor=color.white, size=size.normal)

//====================================================
// END OF BEARISH CORRECTION
//====================================================

bearTrendBreak = state == -14 and trendlineReady and not na(trendPrice) and close < trendPrice and close < open

if bearTrendBreak
    state := -15

    if not na(correction15Box)
        box.set_extend(correction15Box, extend.none)
        box.set_right(correction15Box, time)

    if showLabels
        label.new(bar_index, high, "CORRECTION ENDED\nTRENDLINE BREAK\nCONTINUATION", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.normal)

//====================================================
// 5M MARKET STRUCTURE
//====================================================

pivotHigh5 = ta.pivothigh(high, swing5, swing5)
pivotLow5 = ta.pivotlow(low, swing5, swing5)

var float lastHigh5 = na
var float lastLow5 = na

if not na(pivotHigh5)
    lastHigh5 := pivotHigh5

if not na(pivotLow5)
    lastLow5 := pivotLow5

bullBos5 = not na(lastHigh5) and close > lastHigh5 and close[1] <= lastHigh5
bearBos5 = not na(lastLow5) and close < lastLow5 and close[1] >= lastLow5

//====================================================
// LAST OPPOSITE 5M CANDLE
//====================================================

demandTop5 = ta.valuewhen(close < open, high, 0)
demandBottom5 = ta.valuewhen(close < open, low, 0)
demandTime5 = ta.valuewhen(close < open, time, 0)

supplyTop5 = ta.valuewhen(close > open, high, 0)
supplyBottom5 = ta.valuewhen(close > open, low, 0)
supplyTime5 = ta.valuewhen(close > open, time, 0)

//====================================================
// ACTIVE 5M ZONE
//====================================================

var float zone5Top = na
var float zone5Bottom = na
var int zone5Time = na

//====================================================
// 5M DEMAND AFTER 15M CONTINUATION
//====================================================

createDemand5 = state == 15 and bullBos5

if createDemand5
    zone5Top := demandTop5
    zone5Bottom := demandBottom5
    zone5Time := demandTime5

    state := 16

    if not na(execution5Box)
        box.delete(execution5Box)

    if show5Zone and not na(zone5Time)
        execution5Box := box.new(zone5Time, zone5Top, time, zone5Bottom, xloc=xloc.bar_time, extend=extend.right, border_color=color.lime, border_width=3, bgcolor=color.new(color.lime, 76))

    if showLabels
        label.new(bar_index, low, "5M DEMAND\nWAIT FOR RETEST", style=label.style_label_up, color=color.lime, textcolor=color.black)

//====================================================
// 5M SUPPLY AFTER 15M CONTINUATION
//====================================================

createSupply5 = state == -15 and bearBos5

if createSupply5
    zone5Top := supplyTop5
    zone5Bottom := supplyBottom5
    zone5Time := supplyTime5

    state := -16

    if not na(execution5Box)
        box.delete(execution5Box)

    if show5Zone and not na(zone5Time)
        execution5Box := box.new(zone5Time, zone5Top, time, zone5Bottom, xloc=xloc.bar_time, extend=extend.right, border_color=color.red, border_width=3, bgcolor=color.new(color.red, 76))

    if showLabels
        label.new(bar_index, high, "5M SUPPLY\nWAIT FOR RETEST", style=label.style_label_down, color=color.red, textcolor=color.white)

//====================================================
// 5M RETEST / REACTION
//====================================================

touchDemand5 = state == 16 and not na(zone5Top) and not na(zone5Bottom) and low <= zone5Top and low >= zone5Bottom
touchSupply5 = state == -16 and not na(zone5Top) and not na(zone5Bottom) and high >= zone5Bottom and high <= zone5Top

strongBuy = touchDemand5 and close > zone5Top and close > open
strongSell = touchSupply5 and close < zone5Bottom and close < open

//====================================================
// INVALIDATE 5M ZONES
//====================================================

demandInvalid = state == 16 and not na(zone5Bottom) and close < zone5Bottom
supplyInvalid = state == -16 and not na(zone5Top) and close > zone5Top

if demandInvalid
    state := 10

    if showLabels
        label.new(bar_index, low, "5M DEMAND\nINVALID", style=label.style_label_down, color=color.gray, textcolor=color.white)

if supplyInvalid
    state := -10

    if showLabels
        label.new(bar_index, high, "5M SUPPLY\nINVALID", style=label.style_label_up, color=color.gray, textcolor=color.white)

//====================================================
// FINAL SIGNAL
//====================================================

if strongBuy
    if showLabels
        label.new(bar_index, low, "ICC CONTINUATION\nSTRONG BUY", style=label.style_label_up, color=color.green, textcolor=color.white, size=size.large)

if strongSell
    if showLabels
        label.new(bar_index, high, "ICC CONTINUATION\nSTRONG SELL", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.large)

//====================================================
// BUY / SELL ARROWS
//====================================================

plotshape(strongBuy, title="STRONG BUY", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small, text="BUY", textcolor=color.white)

plotshape(strongSell, title="STRONG SELL", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="SELL", textcolor=color.white)

//====================================================
// DASHBOARD TEXT
//====================================================

string biasText = "WAITING"
string liquidityText = "WAITING"
string chochText = "WAITING"
string bosText = "WAITING"
string correctionText = "WAITING"
string trendlineText = "WAITING"
string executionText = "WAITING"

if state > 0
    biasText := "BULLISH / DEMAND"

if state < 0
    biasText := "BEARISH / SUPPLY"

if state >= 11
    liquidityText := "SELL-SIDE SWEPT"

if state <= -11
    liquidityText := "BUY-SIDE SWEPT"

if state >= 12
    chochText := "BULLISH CONFIRMED"

if state <= -12
    chochText := "BEARISH CONFIRMED"

if state >= 13
    bosText := "BULLISH CONFIRMED"

if state <= -13
    bosText := "BEARISH CONFIRMED"

if state == 14 or state == -14
    correctionText := "ACTIVE"

if state >= 15 or state <= -15
    correctionText := "FINISHED"

if state == 14 or state == -14
    trendlineText := "ACTIVE"

if state >= 15 or state <= -15
    trendlineText := "BROKEN"

if state == 15
    executionText := "SEARCH 5M DEMAND"

if state == -15
    executionText := "SEARCH 5M SUPPLY"

if state == 16
    executionText := "5M DEMAND - WAIT RETEST"

if state == -16
    executionText := "5M SUPPLY - WAIT RETEST"

if strongBuy
    executionText := "STRONG BUY"

if strongSell
    executionText := "STRONG SELL"

//====================================================
// DASHBOARD
//====================================================

var table panel = table.new(position.top_right, 2, 8, border_width=1)

if barstate.islast and showDashboard
    table.cell(panel, 0, 0, "XAUUSD ICC SMC", bgcolor=color.blue, text_color=color.white)
    table.cell(panel, 1, 0, "4H > 15M > 5M", bgcolor=color.blue, text_color=color.white)

    table.cell(panel, 0, 1, "4H BIAS", text_color=color.white)
    table.cell(panel, 1, 1, biasText, text_color=color.white)

    table.cell(panel, 0, 2, "LIQUIDITY", text_color=color.white)
    table.cell(panel, 1, 2, liquidityText, text_color=color.yellow)

    table.cell(panel, 0, 3, "15M CHoCH", text_color=color.white)
    table.cell(panel, 1, 3, chochText, text_color=color.aqua)

    table.cell(panel, 0, 4, "15M BOS", text_color=color.white)
    table.cell(panel, 1, 4, bosText, text_color=color.blue)

    table.cell(panel, 0, 5, "CORRECTION", text_color=color.white)
    table.cell(panel, 1, 5, correctionText, text_color=color.orange)

    table.cell(panel, 0, 6, "TRENDLINE", text_color=color.white)
    table.cell(panel, 1, 6, trendlineText, text_color=color.lime)

    table.cell(panel, 0, 7, "5M EXECUTION", text_color=color.white)
    table.cell(panel, 1, 7, executionText, text_color=color.white)

//====================================================
// ALERTS
//====================================================

alertcondition(newBullBos4, "4H DEMAND", "XAUUSD: 4H bullish BOS and Demand zone detected")
alertcondition(newBearBos4, "4H SUPPLY", "XAUUSD: 4H bearish BOS and Supply zone detected")

alertcondition(bullLiquiditySweep, "SELL SIDE SWEEP", "XAUUSD: 15M Sell-Side Liquidity Sweep inside 4H Demand")
alertcondition(bearLiquiditySweep, "BUY SIDE SWEEP", "XAUUSD: 15M Buy-Side Liquidity Sweep inside 4H Supply")

alertcondition(bullChoch, "15M BULL CHOCH", "XAUUSD: 15M bullish CHoCH confirmed")
alertcondition(bearChoch, "15M BEAR CHOCH", "XAUUSD: 15M bearish CHoCH confirmed")

alertcondition(bullBosConfirmation, "15M BULL BOS", "XAUUSD: 15M bullish BOS confirmed")
alertcondition(bearBosConfirmation, "15M BEAR BOS", "XAUUSD: 15M bearish BOS confirmed")

alertcondition(bullTrendBreak, "BULL CORRECTION ENDED", "XAUUSD: 15M bullish correction ended and trendline broken")
alertcondition(bearTrendBreak, "BEAR CORRECTION ENDED", "XAUUSD: 15M bearish correction ended and trendline broken")

alertcondition(createDemand5, "5M DEMAND", "XAUUSD: 5M Demand zone created")
alertcondition(createSupply5, "5M SUPPLY", "XAUUSD: 5M Supply zone created")

alertcondition(strongBuy, "ICC STRONG BUY", "XAUUSD ICC SMC: STRONG BUY")
alertcondition(strongSell, "ICC STRONG SELL", "XAUUSD ICC SMC: STRONG SELL")
````

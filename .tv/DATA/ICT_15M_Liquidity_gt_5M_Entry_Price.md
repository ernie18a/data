<!-- tradingview-pine-id: PUB;aade211f10d14f36a0a100fa07e6bea6 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# ICT 15M Liquidity -&gt; 5M Entry + Price

Source: https://www.tradingview.com/script/68e7iNCJ-ICT-15M-Liquidity-5M-Entry-Price/

## Description

CT 15M Liquidity → 5M Entry Indicator

This indicator is designed to identify ICT-style trade setups by combining 15-minute liquidity confirmation with 5-minute execution timing.

The 15-minute timeframe is used to detect the higher-quality setup conditions. It looks for major liquidity such as Previous Day High/Low, Asia High/Low, London High/Low, and selected 15M/4H swing levels. Once price sweeps one of these liquidity levels, the indicator waits for a reclaim and then looks for displacement in the opposite direction.

After the 15M setup is confirmed, the script classifies the setup based on the strongest confirmation present:

iFVG — an opposing Fair Value Gap is invalidated and becomes an inverse FVG.
FVG — displacement creates a new Fair Value Gap in the direction of the trade.
DISP — liquidity sweep, reclaim, and displacement are present, but no qualifying iFVG or FVG is detected.

The 5-minute timeframe is then used for the actual execution. The indicator waits for a pullback after the 15M confirmation, identifies the relevant 5M market structure, and requires a body close through that structure to confirm the MSS.

The final signal is plotted at the actual 5-minute execution price, which is the close of the candle that confirms the entry.

The chart only displays the final signals:

BUY • iFVG — sell-side liquidity was swept, bullish displacement confirmed an iFVG, and a bullish 5M MSS triggered the entry.

BUY • FVG — sell-side liquidity was swept, bullish displacement created an FVG, and a bullish 5M MSS triggered the entry.

BUY • DISP — sell-side liquidity was swept and reclaimed, bullish displacement occurred, and a bullish 5M MSS confirmed the entry.

SELL • iFVG — buy-side liquidity was swept, bearish displacement confirmed an iFVG, and a bearish 5M MSS triggered the entry.

SELL • FVG — buy-side liquidity was swept, bearish displacement created an FVG, and a bearish 5M MSS triggered the entry.

SELL • DISP — buy-side liquidity was swept and reclaimed, bearish displacement occurred, and a bearish 5M MSS confirmed the entry.

The indicator is intended to be used on the 5-minute chart, while the 15-minute confirmation logic runs internally. It is designed to reduce random buy/sell signals by requiring liquidity to be taken first and then waiting for structural confirmation before identifying an execution.

---

## Source Code

````pine
//@version=6
indicator('ICT 15M Liquidity -> 5M Entry + Price', overlay = true, max_bars_back = 5000)

//=============================================================================
// USE ON 5-MINUTE CHART
//
// 15M:
// Liquidity sweep
// -> reclaim
// -> displacement
// -> iFVG / FVG / displacement classification
//
// 5M:
// pullback
// -> MSS
// -> execution signal
//
// FINAL LABELS ARE PLOTTED AT THE ACTUAL EXECUTION PRICE.
//=============================================================================


//=============================================================================
// SETTINGS
//=============================================================================

grpLiq = '1. Liquidity'

usePD = input.bool(true, 'Previous Day High / Low', group = grpLiq)
useAsia = input.bool(true, 'Asia High / Low', group = grpLiq)
useLondon = input.bool(true, 'London High / Low', group = grpLiq)
use15Swing = input.bool(true, '15M Swing Liquidity', group = grpLiq)
use4HSwing = input.bool(false, '4H Swing Liquidity', group = grpLiq)

pivot15Len = input.int(2, '15M Pivot Length', minval = 1, group = grpLiq)
pivot4HLen = input.int(2, '4H Pivot Length', minval = 1, group = grpLiq)

asiaSession = input.session('1800-0000', 'Asia ET', group = grpLiq)
londonSession = input.session('0200-0500', 'London ET', group = grpLiq)


//=============================================================================
// 15M SETUP
//=============================================================================

grp15 = '2. 15M Setup'

disp15Multiplier = input.float(1.05, '15M Displacement Strength', minval = 0.80, step = 0.05, group = grp15)

maxReclaim15Bars = input.int(3, '15M Bars To Reclaim', minval = 1, maxval = 10, group = grp15)

maxConfirmation15Bars = input.int(6, '15M Bars Reclaim -> Confirmation', minval = 1, maxval = 15, group = grp15)


//=============================================================================
// 5M ENTRY
//=============================================================================

grp5 = '3. 5M Entry'

pivot5Len = input.int(1, '5M MSS Pivot', minval = 1, group = grp5)

maxEntryBars = input.int(36, 'Maximum 5M Bars After Setup', minval = 6, maxval = 100, group = grp5)

maxBarsAfterPullback = input.int(15, 'Maximum Pullback -> MSS Bars', minval = 2, maxval = 40, group = grp5)

require5MDisplacement = input.bool(false, 'Require 5M Entry Displacement', group = grp5)

disp5Multiplier = input.float(1.00, '5M Displacement Strength', minval = 0.75, step = 0.05, group = grp5)


//=============================================================================
// FILTERS
//=============================================================================

grpFilters = '4. Filters'

useNYOnly = input.bool(false, 'NY Window Only', group = grpFilters)

nySession = input.session('0800-1100', 'NY ET', group = grpFilters)

cooldownBars = input.int(6, 'Signal Cooldown', minval = 0, maxval = 50, group = grpFilters)


//=============================================================================
// DISPLAY
//=============================================================================

grpDisplay = '5. Display'

showBuy = input.bool(true, 'Show BUY', group = grpDisplay)
showSell = input.bool(true, 'Show SELL', group = grpDisplay)


//=============================================================================
// FUNCTIONS
//=============================================================================

f_lastPivotHigh(_len) =>
    ph = ta.pivothigh(_len, _len)

    var float result = na

    if not na(ph)
        result := ph
        result

    result


f_lastPivotLow(_len) =>
    pl = ta.pivotlow(_len, _len)

    var float result = na

    if not na(pl)
        result := pl
        result

    result


f_session(_session) =>
    sessionTime = time(timeframe.period, _session, 'America/New_York')

    active = not na(sessionTime)

    var float runningHigh = na
    var float runningLow = na

    var float completedHigh = na
    var float completedLow = na

    sessionStarted = active and not active[1]

    sessionEnded = not active and active[1]

    if sessionStarted

        runningHigh := high
        runningLow := low
        runningLow

    else if active

        runningHigh := math.max(nz(runningHigh, high), high)

        runningLow := math.min(nz(runningLow, low), low)
        runningLow

    if sessionEnded

        completedHigh := runningHigh
        completedLow := runningLow
        completedLow

    [completedHigh, completedLow]


f_findSweptSSL(_levels, _currentLow) =>
    float result = na

    if array.size(_levels) > 0

        for i = 0 to array.size(_levels) - 1 by 1

            level = array.get(_levels, i)

            if not na(level) and _currentLow < level

                if na(result) or level > result

                    result := level
                    result

    result


f_findSweptBSL(_levels, _currentHigh) =>
    float result = na

    if array.size(_levels) > 0

        for i = 0 to array.size(_levels) - 1 by 1

            level = array.get(_levels, i)

            if not na(level) and _currentHigh > level

                if na(result) or level < result

                    result := level
                    result

    result


//=============================================================================
// TIMEFRAME
//=============================================================================

is5Minute = timeframe.isminutes and timeframe.multiplier == 5


new15 = ta.change(time('15')) != 0


//=============================================================================
// PREVIOUS DAY
//=============================================================================

pdh = request.security(syminfo.tickerid, 'D', high[1], lookahead = barmerge.lookahead_on)


pdl = request.security(syminfo.tickerid, 'D', low[1], lookahead = barmerge.lookahead_on)


//=============================================================================
// HTF SWINGS
//=============================================================================

swing15High = request.security(syminfo.tickerid, '15', f_lastPivotHigh(pivot15Len)[1], lookahead = barmerge.lookahead_on)


swing15Low = request.security(syminfo.tickerid, '15', f_lastPivotLow(pivot15Len)[1], lookahead = barmerge.lookahead_on)


swing4High = request.security(syminfo.tickerid, '240', f_lastPivotHigh(pivot4HLen)[1], lookahead = barmerge.lookahead_on)


swing4Low = request.security(syminfo.tickerid, '240', f_lastPivotLow(pivot4HLen)[1], lookahead = barmerge.lookahead_on)


//=============================================================================
// SESSION LIQUIDITY
//=============================================================================

[asiaHigh, asiaLow] = f_session(asiaSession)


[londonHigh, londonLow] = f_session(londonSession)


//=============================================================================
// LIQUIDITY ARRAYS
//=============================================================================

bsl = array.new_float()
ssl = array.new_float()


if usePD

    array.push(bsl, pdh)
    array.push(ssl, pdl)


if useAsia

    array.push(bsl, asiaHigh)
    array.push(ssl, asiaLow)


if useLondon

    array.push(bsl, londonHigh)
    array.push(ssl, londonLow)


if use15Swing

    array.push(bsl, swing15High)
    array.push(ssl, swing15Low)


if use4HSwing

    array.push(bsl, swing4High)
    array.push(ssl, swing4Low)


//=============================================================================
// CLOSED 15M CANDLE
//=============================================================================

o15 = request.security(syminfo.tickerid, '15', open[1], lookahead = barmerge.lookahead_on)


h15 = request.security(syminfo.tickerid, '15', high[1], lookahead = barmerge.lookahead_on)


l15 = request.security(syminfo.tickerid, '15', low[1], lookahead = barmerge.lookahead_on)


c15 = request.security(syminfo.tickerid, '15', close[1], lookahead = barmerge.lookahead_on)


//=============================================================================
// 15M FVG
//=============================================================================

oldHigh15 = request.security(syminfo.tickerid, '15', high[3], lookahead = barmerge.lookahead_on)


oldLow15 = request.security(syminfo.tickerid, '15', low[3], lookahead = barmerge.lookahead_on)


bullFVG15 = l15 > oldHigh15


bearFVG15 = h15 < oldLow15


//=============================================================================
// 15M DISPLACEMENT
//=============================================================================

body15 = math.abs(c15 - o15)


avgBody15 = request.security(syminfo.tickerid, '15', ta.sma(math.abs(close - open), 5)[2], lookahead = barmerge.lookahead_on)


bullDisplacement15 = c15 > o15 and not na(avgBody15) and body15 >= avgBody15 * disp15Multiplier


bearDisplacement15 = c15 < o15 and not na(avgBody15) and body15 >= avgBody15 * disp15Multiplier


//=============================================================================
// FVG MEMORY
//=============================================================================

var float lastBullFVGTop = na
var float lastBullFVGBottom = na

var float lastBearFVGTop = na
var float lastBearFVGBottom = na


//=============================================================================
// 15M STATE
//=============================================================================

var int bullState = 0
var int bearState = 0

var float bullLiquidity = na
var float bearLiquidity = na

var float bullSweepLow = na
var float bearSweepHigh = na

var int bullStateAge = 0
var int bearStateAge = 0


//=============================================================================
// 5M ARMED SETUPS
//
// 1 = iFVG
// 2 = FVG
// 3 = displacement only
//=============================================================================

var bool bullArmed = false
var bool bearArmed = false

var int bullReason = 0
var int bearReason = 0

var float bullInvalidation = na
var float bearInvalidation = na

var float bullZoneTop = na
var float bullZoneBottom = na

var float bearZoneTop = na
var float bearZoneBottom = na

var int bullArmedBar = na
var int bearArmedBar = na


//=============================================================================
// 15M ENGINE
//=============================================================================

if new15

//---------------------------------------------------------------------
// BULL SWEEP
//---------------------------------------------------------------------

    if bullState == 0 and not bullArmed

        sweptSSL = f_findSweptSSL(ssl, l15)

        if not na(sweptSSL)

            bullLiquidity := sweptSSL

            bullSweepLow := l15

            bullStateAge := 0

            if c15 > bullLiquidity

                bullState := 2
                bullState

            else 
                bullState := 1
                bullState


//---------------------------------------------------------------------
// BULL RECLAIM
//---------------------------------------------------------------------

    if bullState == 1

        bullStateAge := bullStateAge + 1

        bullSweepLow := math.min(bullSweepLow, l15)

        if c15 > bullLiquidity

            bullState := 2

            bullStateAge := 0
            bullStateAge

        else if bullStateAge > maxReclaim15Bars

            bullState := 0
            bullState


//---------------------------------------------------------------------
// BULL CONFIRMATION
//---------------------------------------------------------------------

    if bullState == 2

        bullStateAge := bullStateAge + 1


        bullIFVG = not na(lastBearFVGTop) and c15 > lastBearFVGTop and bullDisplacement15


        if bullDisplacement15

            if bullIFVG

                bullReason := 1

                bullZoneTop := lastBearFVGTop

                bullZoneBottom := lastBearFVGBottom
                bullZoneBottom


            else if bullFVG15

                bullReason := 2

                bullZoneTop := l15

                bullZoneBottom := oldHigh15
                bullZoneBottom


            else 
                bullReason := 3

                bullZoneTop := na

                bullZoneBottom := na
                bullZoneBottom


            bullInvalidation := bullSweepLow

            bullArmed := true

            bearArmed := false

            bullArmedBar := bar_index

            bullState := 0
            bullState


        else if bullStateAge > maxConfirmation15Bars

            bullState := 0
            bullState


//---------------------------------------------------------------------
// BEAR SWEEP
//---------------------------------------------------------------------

    if bearState == 0 and not bearArmed

        sweptBSL = f_findSweptBSL(bsl, h15)

        if not na(sweptBSL)

            bearLiquidity := sweptBSL

            bearSweepHigh := h15

            bearStateAge := 0

            if c15 < bearLiquidity

                bearState := 2
                bearState

            else 
                bearState := 1
                bearState


//---------------------------------------------------------------------
// BEAR RECLAIM
//---------------------------------------------------------------------

    if bearState == 1

        bearStateAge := bearStateAge + 1

        bearSweepHigh := math.max(bearSweepHigh, h15)

        if c15 < bearLiquidity

            bearState := 2

            bearStateAge := 0
            bearStateAge

        else if bearStateAge > maxReclaim15Bars

            bearState := 0
            bearState


//---------------------------------------------------------------------
// BEAR CONFIRMATION
//---------------------------------------------------------------------

    if bearState == 2

        bearStateAge := bearStateAge + 1


        bearIFVG = not na(lastBullFVGBottom) and c15 < lastBullFVGBottom and bearDisplacement15


        if bearDisplacement15

            if bearIFVG

                bearReason := 1

                bearZoneTop := lastBullFVGTop

                bearZoneBottom := lastBullFVGBottom
                bearZoneBottom


            else if bearFVG15

                bearReason := 2

                bearZoneTop := oldLow15

                bearZoneBottom := h15
                bearZoneBottom


            else 
                bearReason := 3

                bearZoneTop := na

                bearZoneBottom := na
                bearZoneBottom


            bearInvalidation := bearSweepHigh

            bearArmed := true

            bullArmed := false

            bearArmedBar := bar_index

            bearState := 0
            bearState


        else if bearStateAge > maxConfirmation15Bars

            bearState := 0
            bearState


//---------------------------------------------------------------------
// STORE NEW FVG LAST
//---------------------------------------------------------------------

    if bullFVG15

        lastBullFVGTop := l15

        lastBullFVGBottom := oldHigh15
        lastBullFVGBottom


    if bearFVG15

        lastBearFVGTop := oldLow15

        lastBearFVGBottom := h15
        lastBearFVGBottom


//=============================================================================
// 5M STRUCTURE
//=============================================================================

pivotHigh5 = ta.pivothigh(pivot5Len, pivot5Len)


pivotLow5 = ta.pivotlow(pivot5Len, pivot5Len)


var float last5High = na
var float last5Low = na


if not na(pivotHigh5)

    last5High := pivotHigh5
    last5High


if not na(pivotLow5)

    last5Low := pivotLow5
    last5Low


//=============================================================================
// 5M DISPLACEMENT
//=============================================================================

body5 = math.abs(close - open)


avgBody5 = ta.sma(math.abs(close - open), 5)[1]


bullDisplacement5 = close > open and not na(avgBody5) and body5 >= avgBody5 * disp5Multiplier


bearDisplacement5 = close < open and not na(avgBody5) and body5 >= avgBody5 * disp5Multiplier


//=============================================================================
// 5M ENTRY STATE
//=============================================================================

var bool bullPullbackSeen = false
var bool bearPullbackSeen = false

var int bullPullbackBar = na
var int bearPullbackBar = na

var float bullMSSLevel = na
var float bearMSSLevel = na


//=============================================================================
// FILTERS
//=============================================================================

insideNY = not na(time(timeframe.period, nySession, 'America/New_York'))


timeOK = not useNYOnly or insideNY


var int lastSignalBar = na


cooldownOK = na(lastSignalBar) or bar_index - lastSignalBar > cooldownBars


//=============================================================================
// FINAL SIGNAL VARIABLES
//=============================================================================

buyIFVG = false
buyFVG = false
buyDISP = false

sellIFVG = false
sellFVG = false
sellDISP = false


//=============================================================================
// EXACT EXECUTION PRICE
//
// Execution occurs on the 5M candle CLOSE that confirms MSS.
//=============================================================================

float buyExecutionPrice = na
float sellExecutionPrice = na


//=============================================================================
// BULLISH 5M EXECUTION
//=============================================================================

if bullArmed and is5Minute

    setupAge = bar_index - bullArmedBar


    invalid = low < bullInvalidation


    if invalid or setupAge > maxEntryBars

        bullArmed := false

        bullPullbackSeen := false
        bullPullbackSeen


    else 
        zoneTouch = not na(bullZoneTop) and not na(bullZoneBottom) and low <= bullZoneTop and high >= bullZoneBottom


        pullback = close < open or low < low[1] or zoneTouch


        if not bullPullbackSeen and pullback

            bullPullbackSeen := true

            bullPullbackBar := bar_index

            bullMSSLevel := last5High
            bullMSSLevel


        if bullPullbackSeen

            barsAfterPullback = bar_index - bullPullbackBar


            bullMSS = bar_index > bullPullbackBar and not na(bullMSSLevel) and close > bullMSSLevel


            entry = bullMSS and close > open and (not require5MDisplacement or bullDisplacement5)


            if barsAfterPullback > maxBarsAfterPullback

                bullArmed := false

                bullPullbackSeen := false
                bullPullbackSeen


            else if entry and timeOK and cooldownOK

                buyExecutionPrice := close


                if bullReason == 1

                    buyIFVG := true
                    buyIFVG


                else if bullReason == 2

                    buyFVG := true
                    buyFVG


                else 
                    buyDISP := true
                    buyDISP


                lastSignalBar := bar_index

                bullArmed := false

                bullPullbackSeen := false
                bullPullbackSeen


//=============================================================================
// BEARISH 5M EXECUTION
//=============================================================================

if bearArmed and is5Minute

    setupAge = bar_index - bearArmedBar


    invalid = high > bearInvalidation


    if invalid or setupAge > maxEntryBars

        bearArmed := false

        bearPullbackSeen := false
        bearPullbackSeen


    else 
        zoneTouch = not na(bearZoneTop) and not na(bearZoneBottom) and high >= bearZoneBottom and low <= bearZoneTop


        pullback = close > open or high > high[1] or zoneTouch


        if not bearPullbackSeen and pullback

            bearPullbackSeen := true

            bearPullbackBar := bar_index

            bearMSSLevel := last5Low
            bearMSSLevel


        if bearPullbackSeen

            barsAfterPullback = bar_index - bearPullbackBar


            bearMSS = bar_index > bearPullbackBar and not na(bearMSSLevel) and close < bearMSSLevel


            entry = bearMSS and close < open and (not require5MDisplacement or bearDisplacement5)


            if barsAfterPullback > maxBarsAfterPullback

                bearArmed := false

                bearPullbackSeen := false
                bearPullbackSeen


            else if entry and timeOK and cooldownOK

                sellExecutionPrice := close


                if bearReason == 1

                    sellIFVG := true
                    sellIFVG


                else if bearReason == 2

                    sellFVG := true
                    sellFVG


                else 
                    sellDISP := true
                    sellDISP


                lastSignalBar := bar_index

                bearArmed := false

                bearPullbackSeen := false
                bearPullbackSeen


//=============================================================================
// FINAL LABELS AT EXECUTION PRICE
//=============================================================================

plotshape(showBuy and buyIFVG ? buyExecutionPrice : na, title = 'BUY iFVG', text = 'BUY • iFVG', style = shape.labelup, location = location.absolute, size = size.small, color = color.lime, textcolor = color.black)


plotshape(showBuy and buyFVG ? buyExecutionPrice : na, title = 'BUY FVG', text = 'BUY • FVG', style = shape.labelup, location = location.absolute, size = size.small, color = color.lime, textcolor = color.black)


plotshape(showBuy and buyDISP ? buyExecutionPrice : na, title = 'BUY Displacement', text = 'BUY • DISP', style = shape.labelup, location = location.absolute, size = size.small, color = color.lime, textcolor = color.black)


plotshape(showSell and sellIFVG ? sellExecutionPrice : na, title = 'SELL iFVG', text = 'SELL • iFVG', style = shape.labeldown, location = location.absolute, size = size.small, color = color.red, textcolor = color.white)


plotshape(showSell and sellFVG ? sellExecutionPrice : na, title = 'SELL FVG', text = 'SELL • FVG', style = shape.labeldown, location = location.absolute, size = size.small, color = color.red, textcolor = color.white)


plotshape(showSell and sellDISP ? sellExecutionPrice : na, title = 'SELL Displacement', text = 'SELL • DISP', style = shape.labeldown, location = location.absolute, size = size.small, color = color.red, textcolor = color.white)


//=============================================================================
// ENTRY PRICE DOT
//=============================================================================

plot(buyExecutionPrice, title = 'BUY Execution Price', style = plot.style_circles, linewidth = 3)


plot(sellExecutionPrice, title = 'SELL Execution Price', style = plot.style_circles, linewidth = 3)


//=============================================================================
// ALERTS
//=============================================================================

alertcondition(buyIFVG or buyFVG or buyDISP, title = 'ICT BUY', message = '15M bullish ICT setup confirmed. 5M MSS entry confirmed at candle close.')


alertcondition(sellIFVG or sellFVG or sellDISP, title = 'ICT SELL', message = '15M bearish ICT setup confirmed. 5M MSS entry confirmed at candle close.')
````

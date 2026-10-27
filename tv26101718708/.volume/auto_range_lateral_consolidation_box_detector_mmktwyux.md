# Auto Range / Lateral Consolidation Box Detector

- url: https://www.tradingview.com/script/MmKTWyux-Auto-Range-Lateral-Consolidation-Box-Detector/
- type: indicator
- pine_id: PUB;901b981f18b047a69a8ecb2f37828863
- version: 1.0

## Description

Auto Range / Lateral Consolidation Box Detector
Overview
The Auto Range / Lateral Consolidation Box Detector is designed to automatically identify and draw price ranges where a stock is moving sideways after a prior advance.
Instead of manually drawing rectangle boxes around consolidation areas, this indicator detects them objectively using price containment, range width, prior trend movement, ADR, moving-average structure, and optional volume/RSI filters.
The purpose is to help traders identify:


lateral consolidations


tight launch shelves


continuation bases


range breakouts


failed ranges


breakout/retest zones


early momentum continuation structures


This tool is especially useful for traders who look for stocks that have already shown strength, pause in a controlled range, and then attempt to continue higher.

Core Concept
Many strong momentum moves do not happen randomly. They often follow a repeatable structure:

Prior advance → sideways range → breakout → continuation

This indicator attempts to locate that sideways range automatically.
The blue dashed boxes show detected consolidation zones. When price breaks above a completed range, the indicator can mark the breakout and preserve the prior box so the trader can review the structure historically.
The goal is not to predict breakouts blindly. The goal is to make range structure easier to detect, measure, and trade with defined risk.

What the Indicator Detects
The indicator identifies two main types of structures:
1. Standard Rectangle Range
This is a broader lateral consolidation that usually forms over a larger number of candles.
It is useful for detecting:


multi-week consolidations


continuation bases


sideways digestion after an advance


breakout/retest setups


controlled pullbacks above moving averages


A standard rectangle is best used when price has already advanced and then begins moving sideways in a defined box.

2. Tight Launch Shelf
This is a shorter, tighter range that often forms just before a momentum expansion.
It is useful for detecting:


short pauses near highs


high-tight continuation shelves


pre-breakout compression


momentum names that do not build long bases


stocks that pause briefly before expanding again


This feature was added because some of the strongest stocks do not consolidate for weeks. They may only pause for several sessions before breaking out.

How the Boxes Work
The indicator measures the range using completed prior candles only.
This is important because the breakout candle itself should not distort the range.
For example, if a stock breaks out above a tight rectangle, the breakout candle may be much larger than the range. If the script included that candle in the box calculation, it would make the range look wider than it actually was.
This script avoids that issue by asking:

“Before the current breakout candle, was there a valid sideways range?”

That allows the indicator to draw the actual consolidation area more accurately.

Visual Guide
Visual ElementMeaningBlue dashed boxDetected standard rectangle rangePurple dashed boxDetected tight launch shelfUpper box lineRange resistance / breakout levelLower box lineRange support / invalidation referenceMidlineInternal range midpointBO markerBreakout above range with volumeBO? markerPrice breakout without volume confirmationFAIL markerBreakdown below rangeScore labelShows range quality, width, ADR, prior move, and containment

How I Use It in My Strategy
This indicator fits into a continuation-style trading strategy built around strength, structure, and timing.
The process is:
1. Find a stock with prior strength
I want to see that the stock has already proven demand.
That may include:


strong prior advance


relative strength versus the market


rising moving averages


reclaim or hold above the 200 SMA


improving volume profile


strong sector or theme participation


recent earnings, catalyst, or institutional attention


The indicator is not used to find random sideways stocks. It is used to find sideways ranges after strength has already appeared.

2. Let the stock build a range
Once a stock has moved, I want to see whether it can hold gains.
A clean range tells me:


buyers are defending higher prices


sellers are not fully taking control


price is digesting instead of collapsing


moving averages may be catching up


risk can be defined around the box


This is where the auto box becomes useful.
Instead of manually drawing every range, the indicator highlights areas where price is compressing or consolidating.

3. Use the box for trade planning
The box gives me three major trade locations:
Trade LocationUse CaseRange lowSupport-defense entryRange highBreakout triggerBreakout retestPreferred continuation entry
I generally do not want to enter randomly in the middle of the box unless I have another strong reason.
The best trades usually come from:


range-low defense,


breakout through range high,


or breakout followed by a retest that holds.



4. Confirm with other tools
This indicator identifies structure, but it is not a standalone buy signal.
Before taking a trade, I still want confirmation from:


relative strength


catalyst/news/earnings context


sector/theme strength


ADR/movement potential


volume expansion


VWAP/AVWAP location


volume profile levels


option-chain liquidity if using options


broader market regime


The box tells me where the trade may be forming.
The rest of the process tells me whether it deserves capital.

How Other Traders Can Use It
This indicator can be adapted to several trading styles.
Momentum Traders
Momentum traders can use it to identify stocks that are pausing after a strong move and preparing for another push.
Best use:


breakout above range high


breakout with volume


tight launch shelf breakouts


high-relative-volume names


strong sector/theme participation



Swing Traders
Swing traders can use it to locate multi-day or multi-week continuation bases.
Best use:


buy breakout/retest


enter near range support with defined risk


use the box low as invalidation


use the box height for measured-move targets


combine with daily/weekly trend structure



Breakout Traders
Breakout traders can use the box high as an objective breakout level.
Best use:


price closes above the range high


volume expands above average


range is not too wide


stock is above key moving averages


market regime supports continuation



Mean-Reversion Traders
Mean-reversion traders can use the range boundaries in the opposite way.
Best use:


fade weak breakouts back into the range


buy range low if buyers defend


sell/avoid failed range highs


use the midpoint as a decision level



Position Traders
Position traders can use detected boxes as add zones during a larger trend.
Best use:


add after a valid base forms above rising moving averages


trail risk below higher base lows


identify where trend continuation is being accepted


avoid adding after emotional vertical moves without digestion



Input Settings Explained
Standard Rectangle Bars
Controls how many prior candles are used to detect a normal consolidation box.
Higher values detect longer bases.
Lower values detect shorter ranges.
Suggested use:
StyleSettingFast momentum8–12Swing trading12–20Longer bases20–40

Tight Launch Shelf Bars
Controls how many prior candles are used to detect short, tight shelves near highs.
This is designed for stocks that pause briefly before breaking out.
Suggested use:
StyleSettingVery fast momentum4–6Normal launch shelf6–10Slower swing shelf10–15

Prior Move Lookback Bars
Determines how far back the script looks to measure whether the stock had a prior advance before the range.
Higher values allow the script to detect bases after larger, older moves.
Suggested use:
StyleSettingShort-term momentum20–35Swing continuation35–60Longer trend bases60–100

Minimum Prior Advance %
Defines how much price must have advanced before the range qualifies.
This helps prevent the script from highlighting random sideways chop.
Suggested use:
Market TypeSettingLarge caps8%–15%Mid caps15%–25%Small caps / high ADR20%–40%
A higher setting makes the script more selective.

Minimum Close Containment %
Controls how many closes must remain inside the box.
A higher value requires cleaner sideways behavior.
Suggested use:
Range QualitySettingLoose ranges60%–70%Normal ranges70%–80%Very tight clean bases80%–90%

Max Standard Range Width x ADR
Controls how wide a normal range can be compared with the stock’s average daily range.
Lower values require tighter bases.
Higher values allow wider, looser consolidations.
Suggested use:
PreferenceSettingTight clean bases only1.5–2.25Balanced2.5–3.0Loose momentum names3.0–4.0

Max Tight Shelf Width x ADR
Controls how wide a tight launch shelf can be.
Because launch shelves should be tighter than standard ranges, this number is usually lower.
Suggested use:
PreferenceSettingVery tight shelves1.0–1.3Balanced1.4–1.8Volatile small caps1.8–2.5

ADR Length
Controls the lookback period for average daily range.
Default is 20, which approximates one trading month.
Suggested use:
PurposeSettingShort-term sensitivity10Standard20Smoother ADR30–50

Volume Average Length
Controls the average volume lookback used for breakout and volume comparison.
Suggested use:
StyleSettingFast momentum10Standard swing20Smoother volume filter30–50

Max Range Volume vs Avg
This controls how much volume is allowed during the range if the volume filter is enabled.
Lower values require quieter consolidation.
Higher values allow more active ranges.
Suggested use:
Range TypeSettingQuiet base0.8–1.0Normal base1.0–1.25Active momentum range1.25–1.75

RSI Settings
RSI filters can be used to avoid ranges that are either too weak or too extended.
Suggested use:
PurposeSettingAvoid weak rangesMinimum RSI 40Allow momentum leadersMaximum RSI 80–85Stricter resetMax RSI 70–75
For strong momentum stocks, I prefer leaving RSI control flexible because strong names can remain elevated before breaking out.

Require Price Above 200 SMA
When enabled, the script only accepts ranges where price is above the 200 SMA.
This is useful for trend-following and continuation strategies.
Turn this off if you want to scan:


bottoming structures


early reversals


200 SMA reclaim attempts


accumulation ranges below the 200 SMA



Require Prior Advance
When enabled, the script requires price to have moved up before forming the range.
This is best for continuation traders.
Turn this off if you want to study:


accumulation bases


bottoming ranges


reversal setups


sideways structures before a first move



Require Volume Control
When enabled, the range must have controlled volume relative to average volume.
This helps filter out chaotic ranges.
However, for volatile small caps or active momentum names, I often leave this off because strong stocks can consolidate with active volume.

Require RSI Control
When enabled, RSI must remain within the selected range.
This can help avoid weak or overextended setups.
However, momentum leaders can remain strong for longer than expected, so this setting is optional depending on the strategy.

Setup Score
The label displays an Auto Range Score out of 10.
The score considers:


prior move


price above 200 SMA


containment inside the range


range width versus ADR


volume behavior


OBV behavior


RSI condition


ADR level


The score is not a buy signal. It is a structure-quality score.
General interpretation:
ScoreInterpretation9–10Very clean structure7–8Good watchlist candidate5–6Needs more confirmationBelow 5Low-quality or incomplete structure

Trading Notes
A detected box is only a location tool.
It does not replace:


market regime analysis


risk management


catalyst research


relative strength checks


liquidity checks


options-chain review


trade planning


The highest-quality setups usually combine:

strong prior move + clean box + range containment + volume expansion on breakout + supportive market conditions.


Risk Management
The box can help define risk.
Common invalidation methods:


stop below range low


stop below breakout candle low


stop below retest low


stop below rising 20 EMA or 50 SMA


exit if breakout fails back into range


avoid if price breaks below the box with volume


The cleanest setups are usually those where the box gives a tight, logical invalidation level.

Important Disclaimer
This indicator is for educational and research purposes only.
It does not provide financial advice, investment advice, or guaranteed trade signals. All trading involves risk. Traders should use their own research, risk management, and judgment before entering any position.

## Source Code

````pine
//@version=6
indicator("Auto Range / Lateral Consolidation Box Detector [Rick]", overlay=true, max_boxes_count=300, max_labels_count=100, max_lines_count=300)

// =====================================================
// Auto Range / Lateral Consolidation Box Detector
// Goal: Draw the rectangle range automatically before breakout.
// Core fix: ranges are measured on PRIOR completed bars, so the breakout candle
// does not distort the consolidation box.
// =====================================================

// -------------------------
// Inputs
// -------------------------
standardBars      = input.int(15, "Standard Rectangle Bars", minval=8, maxval=60)
tightBars         = input.int(7, "Tight Launch Shelf Bars", minval=4, maxval=20)
priorMoveBars     = input.int(35, "Prior Move Lookback Bars", minval=10, maxval=150)
minPriorMovePct   = input.float(18.0, "Minimum Prior Advance %", minval=1.0, step=0.5)
containmentPct    = input.float(70.0, "Minimum Close Containment %", minval=50.0, maxval=100.0, step=5.0)
maxStandardADR    = input.float(2.75, "Max Standard Range Width x ADR", minval=0.5, maxval=8.0, step=0.25)
maxTightADR       = input.float(1.60, "Max Tight Shelf Width x ADR", minval=0.3, maxval=5.0, step=0.05)
adrLength         = input.int(20, "ADR Length", minval=5, maxval=100)
volLength         = input.int(20, "Volume Average Length", minval=5, maxval=100)
maxVolVsAvg       = input.float(1.25, "Max Range Volume vs Avg", minval=0.2, maxval=3.0, step=0.05)
rsiLength         = input.int(14, "RSI Length", minval=2, maxval=50)
rsiMin            = input.float(38.0, "Minimum RSI During Range", minval=1.0, maxval=80.0, step=1.0)
rsiMax            = input.float(85.0, "Maximum RSI During Range", minval=50.0, maxval=100.0, step=1.0)
requireAbove200   = input.bool(true, "Require Price Above 200 SMA")
requirePriorMove  = input.bool(true, "Require Prior Advance")
requireVolumeOK   = input.bool(false, "Require Volume Control")
requireRSIOK      = input.bool(false, "Require RSI Control")
showActiveBox     = input.bool(true, "Show Current Detected Range")
showLockedBoxes   = input.bool(true, "Lock Historical Boxes On Breakout")
colorCandles      = input.bool(true, "Color Candles Inside Detected Range")
showBreakouts     = input.bool(true, "Show Breakout Markers")
showScoreLabel    = input.bool(true, "Show Last Range Score Label")

// -------------------------
// Core indicators
// -------------------------
sma200 = ta.sma(close, 200)
ema10  = ta.ema(close, 10)
ema20  = ta.ema(close, 20)
ema50  = ta.ema(close, 50)
rsi    = ta.rsi(close, rsiLength)
volAvg = ta.sma(volume, volLength)

// ADR percent
dailyRangePct = ((high - low) / close) * 100.0
adrPct = ta.sma(dailyRangePct, adrLength)

// -------------------------
// Helper function: count closes inside a prior box
// The range is measured on completed bars only using [1].
// -------------------------
f_insidePct(_bars, _hi, _lo) =>
    int count = 0
    for i = 1 to _bars
        count += close[i] <= _hi and close[i] >= _lo ? 1 : 0
    (count / _bars) * 100.0

f_upperHalfPct(_bars, _hi, _lo) =>
    float mid = (_hi + _lo) / 2.0
    int count = 0
    for i = 1 to _bars
        count += close[i] >= mid ? 1 : 0
    (count / _bars) * 100.0

// -------------------------
// Build completed prior rectangles, excluding current candle
// This is the key ERAS fix.
// -------------------------
stdHigh = ta.highest(high[1], standardBars)
stdLow  = ta.lowest(low[1], standardBars)
stdMid  = (stdHigh + stdLow) / 2.0
stdWidthPct = ((stdHigh - stdLow) / stdMid) * 100.0
stdContain = f_insidePct(standardBars, stdHigh, stdLow)
stdUpper = f_upperHalfPct(standardBars, stdHigh, stdLow)
stdVol = ta.sma(volume[1], standardBars)

shelfHigh = ta.highest(high[1], tightBars)
shelfLow  = ta.lowest(low[1], tightBars)
shelfMid  = (shelfHigh + shelfLow) / 2.0
shelfWidthPct = ((shelfHigh - shelfLow) / shelfMid) * 100.0
shelfContain = f_insidePct(tightBars, shelfHigh, shelfLow)
shelfUpper = f_upperHalfPct(tightBars, shelfHigh, shelfLow)
shelfVol = ta.sma(volume[1], tightBars)

// Prior advance is measured before the range begins.
priorLowStd = ta.lowest(low[standardBars + 1], priorMoveBars)
priorLowShelf = ta.lowest(low[tightBars + 1], priorMoveBars)
priorAdvanceStd = ((stdHigh - priorLowStd) / priorLowStd) * 100.0
priorAdvanceShelf = ((shelfHigh - priorLowShelf) / priorLowShelf) * 100.0

// Filters
trendOK = requireAbove200 ? close[1] > sma200[1] and (ema10[1] >= ema20[1] or close[1] >= ema20[1]) : (ema10[1] >= ema20[1] or close[1] >= ema20[1])
priorOKStd = requirePriorMove ? priorAdvanceStd >= minPriorMovePct : true
priorOKShelf = requirePriorMove ? priorAdvanceShelf >= minPriorMovePct : true
volumeOKStd = requireVolumeOK ? stdVol <= volAvg[1] * maxVolVsAvg : true
volumeOKShelf = requireVolumeOK ? shelfVol <= volAvg[1] * maxVolVsAvg : true
rsiOK = requireRSIOK ? rsi[1] >= rsiMin and rsi[1] <= rsiMax : true

// Rectangle qualification
stdRangeOK = stdContain >= containmentPct and stdWidthPct <= adrPct[1] * maxStandardADR and trendOK and priorOKStd and volumeOKStd and rsiOK
shelfRangeOK = shelfContain >= containmentPct and shelfUpper >= 45.0 and shelfWidthPct <= adrPct[1] * maxTightADR and trendOK and priorOKShelf and volumeOKShelf and rsiOK

// Prefer the tighter launch shelf if both exist, because it matches the immediate pre-breakout rectangle.
activeIsShelf = shelfRangeOK
activeRangeOK = shelfRangeOK or stdRangeOK
activeBars = activeIsShelf ? tightBars : standardBars
activeHigh = activeIsShelf ? shelfHigh : stdHigh
activeLow = activeIsShelf ? shelfLow : stdLow
activeMid = (activeHigh + activeLow) / 2.0
activeWidth = activeIsShelf ? shelfWidthPct : stdWidthPct
activeContain = activeIsShelf ? shelfContain : stdContain
activePriorMove = activeIsShelf ? priorAdvanceShelf : priorAdvanceStd
activeType = activeIsShelf ? "Tight Launch Shelf" : stdRangeOK ? "Standard Rectangle" : "None"

// Breakout / failure using prior completed box.
breakout = activeRangeOK and close > activeHigh and volume > volAvg
breakoutNoVol = activeRangeOK and close > activeHigh
breakdown = activeRangeOK and close < activeLow

// -------------------------
// Score model
// -------------------------
obv = ta.cum(close > close[1] ? volume : close < close[1] ? -volume : 0)
obvHigh = ta.highest(obv[1], activeBars)
obvLow = ta.lowest(obv[1], activeBars)
obvNearHigh = obv[1] >= obvLow + ((obvHigh - obvLow) * 0.60)

score = 0
score += activePriorMove >= minPriorMovePct ? 2 : 0
score += close[1] > sma200[1] ? 2 : 0
score += activeContain >= containmentPct ? 1 : 0
score += activeWidth <= adrPct[1] * (activeIsShelf ? maxTightADR : maxStandardADR) ? 1 : 0
score += (activeIsShelf ? shelfVol : stdVol) <= volAvg[1] * maxVolVsAvg ? 1 : 0
score += obvNearHigh ? 1 : 0
score += rsi[1] >= rsiMin and rsi[1] <= rsiMax ? 1 : 0
score += adrPct[1] >= 4.0 ? 1 : 0

// -------------------------
// Visuals
// -------------------------
plot(sma200, "200 SMA", color=color.new(color.orange, 0), linewidth=2)
plot(ema20, "20 EMA", color=color.new(color.blue, 20), linewidth=1)
plot(ema50, "50 EMA", color=color.new(color.red, 20), linewidth=1)

// Active range lines appear like your manually drawn blue dashed rectangle.
plot(showActiveBox and activeRangeOK ? activeHigh : na, "Auto Range High", color=color.new(color.blue, 0), style=plot.style_linebr, linewidth=2)
plot(showActiveBox and activeRangeOK ? activeLow : na, "Auto Range Low", color=color.new(color.blue, 0), style=plot.style_linebr, linewidth=2)
plot(showActiveBox and activeRangeOK ? activeMid : na, "Auto Range Mid", color=color.new(color.gray, 25), style=plot.style_linebr, linewidth=1)

barcolor(colorCandles and activeRangeOK ? (activeIsShelf ? color.new(color.purple, 0) : color.new(color.teal, 0)) : na)

// Active box updates bar-by-bar before breakout.
var box liveBox = na
if showActiveBox
    if activeRangeOK
        bg = activeIsShelf ? color.new(color.purple, 88) : color.new(color.blue, 88)
        border = activeIsShelf ? color.new(color.purple, 0) : color.new(color.blue, 0)
        if na(liveBox)
            liveBox := box.new(left=bar_index - activeBars, top=activeHigh, right=bar_index - 1, bottom=activeLow, bgcolor=bg, border_color=border, border_style=line.style_dashed)
        else
            box.set_left(liveBox, bar_index - activeBars)
            box.set_right(liveBox, bar_index - 1)
            box.set_top(liveBox, activeHigh)
            box.set_bottom(liveBox, activeLow)
            box.set_bgcolor(liveBox, bg)
            box.set_border_color(liveBox, border)
            box.set_border_style(liveBox, line.style_dashed)
    else
        if not na(liveBox)
            box.delete(liveBox)
            liveBox := na

// Lock the completed rectangle when breakout happens, so you can study it historically.
if showLockedBoxes and breakoutNoVol
    lockedBg = activeIsShelf ? color.new(color.purple, 90) : color.new(color.blue, 90)
    lockedBorder = activeIsShelf ? color.new(color.purple, 0) : color.new(color.blue, 0)
    box.new(left=bar_index - activeBars, top=activeHigh, right=bar_index - 1, bottom=activeLow, bgcolor=lockedBg, border_color=lockedBorder, border_style=line.style_dashed)

plotshape(showBreakouts and breakout, title="Volume Breakout", style=shape.triangleup, location=location.belowbar, size=size.small, color=color.new(color.lime, 0), text="BO")
plotshape(showBreakouts and breakoutNoVol and not breakout, title="Price Breakout", style=shape.triangleup, location=location.belowbar, size=size.tiny, color=color.new(color.yellow, 0), text="BO?")
plotshape(showBreakouts and breakdown, title="Range Failure", style=shape.triangledown, location=location.abovebar, size=size.small, color=color.new(color.red, 0), text="FAIL")

// Score label
var label scoreLbl = na
if showScoreLabel and barstate.islast
    label.delete(scoreLbl)
    grade = score >= 9 ? "A" : score >= 7 ? "B+" : score >= 5 ? "B" : "NO"
    txt = "Auto Range Score: " + str.tostring(score) + "/10" + "\nGrade: " + grade + "\nType: " + activeType + "\nRange: " + str.tostring(activeLow, format.mintick) + " - " + str.tostring(activeHigh, format.mintick) + "\nWidth: " + str.tostring(activeWidth, "#.##") + "%" + "\nADR: " + str.tostring(adrPct[1], "#.##") + "%" + "\nPrior Move: " + str.tostring(activePriorMove, "#.##") + "%" + "\nContainment: " + str.tostring(activeContain, "#.##") + "%"
    labelColor = activeRangeOK ? color.new(color.blue, 0) : color.new(color.gray, 20)
    scoreLbl := label.new(bar_index, high, txt, style=label.style_label_down, textcolor=color.white, color=labelColor)

// Alerts
alertcondition(activeRangeOK, "Auto Range Detected", "Auto rectangle/lateral consolidation range detected on completed bars.")
alertcondition(breakout, "Range Breakout With Volume", "Price broke above auto range with volume confirmation.")
alertcondition(breakoutNoVol, "Range Breakout", "Price broke above auto range.")
alertcondition(breakdown, "Range Breakdown", "Price broke below auto range.")

// =====================================================
// Interpretation
// =====================================================
// This version is designed to match the blue dashed manual box logic:
// - It measures the rectangle using prior completed candles only.
// - It draws a dashed rectangle around the actual range before breakout.
// - It locks historical boxes on breakout so you can review them later.
// - Purple = tighter launch shelf.
// - Blue/teal = broader standard rectangle.
//
// Practical use:
// 1. Use the auto box as structure detection.
// 2. Entry still requires your trigger: breakout, retest, range-low defense, or order-flow confirmation.
// 3. Setup still requires separate catalyst/RS/options-liquidity review.
````

# 5/7 Index Plan - SPX SPY QQQ

- url: https://www.tradingview.com/script/5lYgPGce-5-7-Index-Plan-SPX-SPY-QQQ/
- type: indicator
- pine_id: PUB;707984c4ba11400da7a51221434558b9
- version: 2.0

## Description

King node definition: the blue cell on the GEX heatmap is the largest concentration of net gamma for that ticker by strike/expiration. It matters because it is where dealer hedging pressure is most concentrated. In positive GEX, king nodes tend to act as pin/magnet/compression zones. If price accepts above them, they can become support. If price rejects below them, they often cap the move. In negative GEX, they can become volatility accelerants.

1. Executive market read

The index tape is still bullish but extended. This is not a clean “buy anywhere” market. The cleanest read is that the market is sitting in a positive gamma grind regime, with SPX/SPXW pinning around the current level and upside magnets stacked above. The biggest risk tomorrow is not an immediate crash setup. The bigger risk is chasing calls after the move has already expanded into a gamma shelf.

The core map:

Product	Spot	Net GEX	Max +GEX	Max -GEX	Read
SPX	7365.12	+44.45B	+4.57B @ 7500	-786.84M @ 6000	Structural bullish, upside magnet stack
SPXW	7365.12	+111.87B	+27.26B @ 7365	-507.88M @ 6800	Front-expiry pin directly at spot
SPY	733.00	+9.58B	+1.28B @ 730	-505.24M @ 700	Bullish above 730, but 733 to 735 is decision zone
QQQ	694.51	+4.12B	+494.71M @ 700	-178.68M @ 590	Bullish until 690 fails, 700 is magnet/resistance
VIX	17.39	-21.28M	+8.35M @ 25	-25.01M @ 17	Volatility is still suppressed but fragile near 17 to 18

The most important read: SPXW is controlling the short-term index tape more than SPX proper. SPX structural flow is longer-dated and bullish, but the front-week pinning is SPXW. Current SPXW max +GEX is literally sitting at 7365, which explains the late-day compression around that area.

2. SPX / SPXW detailed read

SPX closed/marked around 7365.12, directly on the SPXW 7365 king node. That is the entire key. This is not a random level. It is the largest front-expiry gamma node in the screenshots.

SPXW front-expiry GEX:

Level	Interpretation
7365	Current king node / pin
7370	Immediate upside gamma shelf
7375	Next upside acceptance level
7380 to 7400	Bull continuation shelf
7350	Key downside support/pivot
7325	First real downside confirmation
7300	Major lower support/magnet
7280 to 7250	Downside acceleration zone if 7300 fails

SPX structural GEX:

Level	Interpretation
7300	Major positive GEX support
7325	Positive shelf and likely dip-buy zone
7350	Positive GEX shelf
7375	Strong positive GEX above spot
7400	Major positive GEX wall
7500	Max +GEX, larger structural magnet, not necessarily a one-day target

The clean SPX/SPXW flow file read is mixed but still constructive. SPX valid flow was about $133.9M, with roughly $101.7M bullish versus $28.5M bearish. SPXW valid flow was about $54.0M, with front-week 5/7 flow modestly bullish on signed premium. The issue is that SPX/SPXW flow had a large number of corrections/cancels, so I would not rank the tape higher than the actual GEX map.

The trade logic for tomorrow:

Scenario	Trigger	Confirmation	Target path
Bull continuation	SPX holds 7365 and reclaims 7375	5-min close above 7375 with SPY > 734 and QQQ > 696	7400, 7420, 7450
A-grade long	SPX accepts above 7400	Pullback holds 7380 to 7400	7420, 7450, 7500 stretch
Failed breakout short	Push into 7375 to 7400 rejects	5-min close back below 7365	7350, 7325, 7300
A-grade bear	SPX loses 7350, then 7325	VIX > 18 and QQQ < 690	7300, 7280, 7250

My preferred setup is not a blind long at 7365. The cleaner trade is either:

Long above 7375, with SPXW reclaiming the 7370/7375 shelf and SPY/QQQ confirming, or
Short below 7350, only if the 7365 king node fails and VIX starts lifting.

No-trade zone for SPX: 7350 to 7375.

Best SPX long trigger: 7375.
A+ SPX long trigger: 7400 acceptance.
Best SPX short trigger: 7350 failure.
A+ SPX short trigger: 7325 failure.

3. SPY detailed read

SPY closed around 733.00. The key SPY GEX structure is cleaner than QQQ but less explosive than SPXW.

SPY GEX:

Level	Interpretation
730	Max +GEX / major support and pin
733 to 734	Current decision zone
735	Upside trigger zone
737	First upside magnet
740	Major upside magnet
728	First downside warning
725	Lower support
723 to 720	Breakdown target zone
700	Far downside max -GEX, not immediate unless volatility expands hard

The SPY flow file was almost perfectly balanced: about $329.7M total premium, with $164.1M bullish versus $156.7M bearish. That is not a clean directional imbalance. However, the chart and GEX map are bullish as long as SPY stays above 730.

The front-expiry tape showed heavy activity in 5/7 puts around 731 to 734, but the interpretation is not automatically bearish. A lot of those puts can be hedges, short premium, or pin positioning around the post-rally area. Because SPY closed above the max +GEX level, the stronger directional read is: bullish above 730, but vulnerable to mean reversion if 733/735 fails.

SPY trade plan:

Scenario	Trigger	Confirmation	Target path
Bull continuation	Reclaim 734.50 to 735.00	SPX > 7375 and QQQ > 696	737, 740, 742
A-grade long	Hold above 735 after first pullback	9 EMA/VWAP hold on 5-min	740, 742, 745
Failed breakout short	Rejects 734.50 to 735	Loses 733 then 730	728, 725, 723
A-grade bear	Below 728	VIX > 18, QQQ < 690	725, 723, 720

No-trade zone for SPY: 730 to 734.50.

Best long: above 735.
Best short: below 730, with stronger confirmation below 728.

For SPY options, I would not use far OTM contracts. The clean contracts are the nearest liquid strikes around the trigger: 734C/735C for upside, 730P/728P for downside, ideally with spreads under 7 to 10 percent of midpoint.

4. QQQ detailed read

QQQ is the most important confirmation product tomorrow because tech/semis have been the actual risk-on engine. QQQ closed around 694.51, and the biggest structural magnet is 700.

QQQ GEX:

Level	Interpretation
700	Max +GEX / upside magnet and resistance
696	Near-term front-expiry gamma shelf
695	Current decision/pin area
692	First support
690	Major support and bull/bear pivot
688	Bear confirmation
685	Downside magnet
682 to 680	Larger downside target zone

This is where I want to be stricter. The chart is bullish. The GEX map is bullish above 690. But the flow file is not clean bullish. QQQ had about $251.6M total premium, with roughly $137.2M bearish versus $104.2M bullish by execution logic. The biggest bearish input came from 5/15 call selling and front-week puts. That does not mean QQQ is an automatic short. It means QQQ needs price confirmation before taking calls.

The proper interpretation is: QQQ has a bullish gamma path toward 700, but the options tape is hedged/overwritten enough that the long needs a trigger.

QQQ trade plan:

Scenario	Trigger	Confirmation	Target path
Bull continuation	Reclaim 696 to 697	SPY > 735 and VIX < 17.50	700, 702.50, 705
A-grade long	Clean acceptance above 700	Pullback holds 697 to 700	705, 710
Failed breakout short	Rejects 696 to 700	Loses 692	690, 688, 685
A-grade bear	Below 688	VIX > 18 and SPY < 730	685, 682, 680

No-trade zone for QQQ: 692 to 696.

Best long: above 696.50 to 697, but A+ only above 700 acceptance.
Best short: below 690, with A+ below 688.

For QQQ options, the clean upside contract is near the trigger, not far OTM. I would look at 695C/696C/700C, but only after price confirms. For downside, 690P/688P are cleaner than chasing deep OTM puts.

5. VIX confirmation filter

VIX is the fail-safe filter for the whole plan.

VIX is sitting near 17.39, and the VIX GEX map shows negative gamma around 17 to 18. That means a push above 18 can matter quickly because volatility hedging can become self-reinforcing.

Use this filter:

VIX Condition	Market Meaning
VIX below 17.50	Favors SPX/SPY/QQQ continuation
VIX 17.50 to 18.00	Neutral/caution zone
VIX above 18.00	Avoid blind calls
VIX above 18.50	Short setups become much cleaner
VIX back below 17.00	Supports grind-up / gamma compression

Tomorrow, if SPX is above 7375 but VIX is pushing above 18, I would not chase calls. That is a divergence. If SPX is above 7375 and VIX is pinned below 17.50, that is confirmation.

6. Best actual index setup for tomorrow

The best setup is SPX/SPXW long continuation, but only after confirmation.

A+ long conditions:

SPX > 7375
SPY > 735
QQQ > 696.50
VIX < 17.50
5-minute candle closes above trigger
Pullback holds VWAP or 9 EMA

Target path: SPX 7400 → 7420 → 7450.

The second-best setup is the failed gamma-pin breakdown.

A+ short conditions:

SPX loses 7350, then 7325
SPY loses 730, then 728
QQQ loses 690, then 688
VIX > 18.00
5-minute close below trigger, not just a wick

Target path: SPX 7300 → 7280 → 7250.

The worst trade is buying calls inside the no-trade zone after a gap up. If SPX opens 7385 to 7400 and stalls, that is not an A+ long. That is where I would wait for either a pullback hold or failed breakout short.

## Source Code

````pine
//@version=6
indicator("BullFlow Institutional Index Roadmap | 5/13 SPX SPY QQQ VIX", overlay=true, max_lines_count=300, max_labels_count=300, max_boxes_count=50)

//=============================================================================
// INPUTS
//=============================================================================
groupMode = "Mode"
autoDetect      = input.bool(true, "Auto-detect ticker", group=groupMode)
manualMode      = input.string("SPX", "Manual mode", options=["SPX", "SPY", "QQQ", "VIX"], group=groupMode)

groupEvent = "Event Date / Session"
useDateFilter   = input.bool(true, "Only fire setup alerts on event date", group=groupEvent)
eventYear       = input.int(2026, "Event year", group=groupEvent)
eventMonth      = input.int(5, "Event month", group=groupEvent)
eventDay        = input.int(13, "Event day", group=groupEvent)
sessionInput    = input.session("0930-1600", "Regular session", group=groupEvent)

groupVix = "VIX Risk Filter"
vixSymbol       = input.symbol("CBOE:VIX", "VIX symbol", group=groupVix)
ignoreVixNA     = input.bool(true, "Allow signals if VIX unavailable", group=groupVix)
vixRiskOn       = input.float(18.50, "Risk-on / controlled below", step=0.05, group=groupVix)
vixBearMin      = input.float(19.00, "Bear confirmation above", step=0.05, group=groupVix)
vixRiskOff      = input.float(20.00, "Risk-off above", step=0.05, group=groupVix)
vixVolExpansion = input.float(22.00, "Vol expansion above", step=0.05, group=groupVix)
vixPanic        = input.float(25.00, "Panic / max +GEX zone", step=0.05, group=groupVix)

groupFilters = "Signal Filters"
confirmOnClose      = input.bool(true, "Fire only on confirmed candle close", group=groupFilters)
useTrendFilter      = input.bool(true, "Require EMA/VWAP trend alignment", group=groupFilters)
useOpeningRange     = input.bool(true, "Require opening range context after OR completes", group=groupFilters)
orMinutes           = input.int(30, "Opening range minutes", minval=5, maxval=120, group=groupFilters)
minBarsAfterOpen    = input.int(1, "Minimum bars after open before alerts", minval=0, maxval=30, group=groupFilters)

groupVisual = "Visuals"
themeMode       = input.string("White", "Chart background target", options=["White", "Dark"], group=groupVisual)
showLevels      = input.bool(true, "Show roadmap levels", group=groupVisual)
showLabels      = input.bool(true, "Show staggered labels", group=groupVisual)
showDashboard   = input.bool(true, "Show dashboard", group=groupVisual)
showEMAVWAP     = input.bool(true, "Show 9 EMA / 21 EMA / VWAP", group=groupVisual)
showZones       = input.bool(true, "Shade no-trade / decision zone", group=groupVisual)
showRiskBg      = input.bool(true, "Shade VIX risk state", group=groupVisual)
showOR          = input.bool(true, "Show opening range", group=groupVisual)
showPrevDay     = input.bool(false, "Show previous day high/low", group=groupVisual)
showSignals     = input.bool(true, "Show signal markers", group=groupVisual)

labelOffsetBars = input.int(8, "First label offset bars", minval=1, maxval=100, group=groupVisual)
labelStepBars   = input.int(7, "Label stagger spacing", minval=1, maxval=50, group=groupVisual)
lineBackBars    = input.int(700, "Level line lookback bars", minval=50, maxval=5000, group=groupVisual)
lineFwdBars     = input.int(250, "Level line forward bars", minval=25, maxval=2000, group=groupVisual)

groupAlerts = "Alert Routing"
alertBull      = input.bool(true, "Enable bullish alerts", group=groupAlerts)
alertBear      = input.bool(true, "Enable bearish alerts", group=groupAlerts)
alertFail      = input.bool(true, "Enable failed breakout / failed reclaim alerts", group=groupAlerts)
alertVix       = input.bool(true, "Enable VIX regime alerts", group=groupAlerts)
alertOR        = input.bool(true, "Enable opening range alerts", group=groupAlerts)

//=============================================================================
// SYMBOL DETECTION
//=============================================================================
tickerUpper = str.upper(syminfo.ticker)
descUpper   = str.upper(syminfo.description)

isSPY = str.contains(tickerUpper, "SPY")
isQQQ = str.contains(tickerUpper, "QQQ")
isVIX = str.contains(tickerUpper, "VIX")
isSPX = str.contains(tickerUpper, "SPX") or str.contains(tickerUpper, "SPXW") or str.contains(tickerUpper, "US500") or str.contains(tickerUpper, "SP500") or str.contains(descUpper, "S&P 500 INDEX")

autoMode = isVIX ? "VIX" : isQQQ ? "QQQ" : isSPY ? "SPY" : isSPX ? "SPX" : manualMode
mode = autoDetect ? autoMode : manualMode
indexMode = mode != "VIX"

//=============================================================================
// EVENT DATE / BAR CONTROL
//=============================================================================
isEventDate = year(time) == eventYear and month(time) == eventMonth and dayofmonth(time) == eventDay
activeDate = not useDateFilter or isEventDate
barOk = confirmOnClose ? barstate.isconfirmed : true

inSession = not na(time(timeframe.period, sessionInput))
newSession = inSession and not inSession[1]

var int sessionStartTime = na
var int barsFromOpen = 0

if newSession
    sessionStartTime := time
    barsFromOpen := 0
else if inSession
    barsFromOpen += 1

timeFilterOk = barsFromOpen >= minBarsAfterOpen

//=============================================================================
// LEVEL MAP: 5/13 ROADMAP
//=============================================================================
// SPX: 7400 pin, 7425/7450/7475/7500 upside, 7375/7350 failure band.
// SPY: 738 gamma flip, 740/742/745 upside, 735 breakdown.
// QQQ: 706/707 decision zone, 710 reclaim, 704/702 trap-door, 700/695/690 downside.
// VIX: 18 pivot, 18.50 warning, 19 bearish confirmation, 20 risk-off, 22/25 expansion.

float pivot = switch mode
    "SPX" => 7400.0
    "SPY" => 738.0
    "QQQ" => 706.0
    => 18.0

float bullTrigger = switch mode
    "SPX" => 7400.0
    "SPY" => 738.0
    "QQQ" => 710.0
    => 18.50

float bullConfirm = switch mode
    "SPX" => 7425.0
    "SPY" => 740.0
    "QQQ" => 714.0
    => 19.0

float bullTarget1 = switch mode
    "SPX" => 7425.0
    "SPY" => 740.0
    "QQQ" => 710.0
    => 19.0

float bullTarget2 = switch mode
    "SPX" => 7450.0
    "SPY" => 742.0
    "QQQ" => 714.0
    => 20.0

float bullTarget3 = switch mode
    "SPX" => 7475.0
    "SPY" => 745.0
    "QQQ" => 718.0
    => 22.0

float bullTarget4 = switch mode
    "SPX" => 7500.0
    "SPY" => 750.0
    "QQQ" => 720.0
    => 25.0

float support1 = switch mode
    "SPX" => 7375.0
    "SPY" => 736.0
    "QQQ" => 706.0
    => 18.0

float support2 = switch mode
    "SPX" => 7350.0
    "SPY" => 735.0
    "QQQ" => 704.0
    => 17.50

float bearWarning = switch mode
    "SPX" => 7375.0
    "SPY" => 736.0
    "QQQ" => 704.0
    => 18.50

float bearTrigger = switch mode
    "SPX" => 7350.0
    "SPY" => 735.0
    "QQQ" => 702.0
    => 19.0

float bearTarget1 = switch mode
    "SPX" => 7335.0
    "SPY" => 733.0
    "QQQ" => 700.0
    => 20.0

float bearTarget2 = switch mode
    "SPX" => 7325.0
    "SPY" => 730.0
    "QQQ" => 695.0
    => 22.0

float bearTarget3 = switch mode
    "SPX" => 7300.0
    "SPY" => 725.0
    "QQQ" => 690.0
    => 25.0

float zoneLow = switch mode
    "SPX" => 7375.0
    "SPY" => 735.0
    "QQQ" => 704.0
    => 18.0

float zoneHigh = switch mode
    "SPX" => 7425.0
    "SPY" => 738.0
    "QQQ" => 710.0
    => 19.0

float failLevel = switch mode
    "SPX" => 7400.0
    "SPY" => 738.0
    "QQQ" => 706.0
    => 18.50

//=============================================================================
// CONTRACT MAP
//=============================================================================
string longContract = switch mode
    "SPX" => "SPXW 5/13 7400C or 7425C"
    "SPY" => "SPY 5/13 738C or SPY 5/18 745C"
    "QQQ" => "QQQ 5/13 707C/711C or 5/15 710C/715C"
    => "VIX 5/19 20.5C or 21.5C as hedge only"

string shortContract = switch mode
    "SPX" => "SPX 5/15 7390P / 7335P / 7325P"
    "SPY" => "SPY 5/13 734P or 730P"
    "QQQ" => "QQQ 5/15 710P or 5/13 700P after 702 breaks"
    => "No short VIX setup. Use VIX as risk filter."

string setupText = switch mode
    "SPX" => "7400 pin/reclaim | 7375-7350 failure"
    "SPY" => "738 reclaim | 735 breakdown"
    "QQQ" => "706/707 decision | 704/702 trap-door"
    => "18 pivot | 19 confirmation | 20 risk-off"

//=============================================================================
// COLORS FOR WHITE / DARK BACKGROUNDS
//=============================================================================
bool whiteTheme = themeMode == "White"

color cPivot     = whiteTheme ? color.rgb(120, 85, 0) : color.rgb(255, 210, 80)
color cBull      = whiteTheme ? color.rgb(0, 115, 65) : color.rgb(20, 210, 120)
color cBull2     = whiteTheme ? color.rgb(0, 105, 170) : color.rgb(70, 190, 255)
color cBearWarn  = whiteTheme ? color.rgb(210, 95, 0) : color.rgb(255, 165, 60)
color cBear      = whiteTheme ? color.rgb(190, 0, 0) : color.rgb(255, 65, 65)
color cBear2     = whiteTheme ? color.rgb(125, 0, 130) : color.rgb(220, 80, 255)
color cNeutral   = whiteTheme ? color.rgb(70, 70, 70) : color.rgb(220, 220, 220)
color cBlack     = color.rgb(15, 15, 15)
color cWhite     = color.white

//=============================================================================
// CORE INDICATORS
//=============================================================================
ema9 = ta.ema(close, 9)
ema21 = ta.ema(close, 21)
vwapValue = ta.vwap(hlc3)

plot(showEMAVWAP ? ema9 : na, "EMA 9", color=whiteTheme ? color.rgb(0, 145, 210) : color.rgb(50, 220, 255), linewidth=2)
plot(showEMAVWAP ? ema21 : na, "EMA 21", color=whiteTheme ? color.rgb(215, 115, 0) : color.rgb(255, 170, 50), linewidth=2)
plot(showEMAVWAP ? vwapValue : na, "VWAP", color=whiteTheme ? color.rgb(30, 30, 30) : color.rgb(240, 240, 240), linewidth=2)

//=============================================================================
// PREVIOUS DAY HIGH / LOW
//=============================================================================
prevHigh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
prevLow  = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)

plot(showPrevDay ? prevHigh : na, "Previous Day High", color=color.new(cBull2, 25), linewidth=1, style=plot.style_linebr)
plot(showPrevDay ? prevLow : na, "Previous Day Low", color=color.new(cBear2, 25), linewidth=1, style=plot.style_linebr)

//=============================================================================
// VIX DATA / STATE
//=============================================================================
vixExternal = request.security(vixSymbol, timeframe.period, close, ignore_invalid_symbol=true)
vixValue = mode == "VIX" ? close : vixExternal
vixAvailable = not na(vixValue)

vixControlled = (not vixAvailable and ignoreVixNA) or (vixAvailable and vixValue < vixRiskOn)
vixScalp = vixAvailable and vixValue >= vixRiskOn and vixValue < vixBearMin
vixBearConfirm = (not vixAvailable and ignoreVixNA) or (vixAvailable and vixValue >= vixBearMin)
vixRiskOffState = vixAvailable and vixValue >= vixRiskOff
vixExpansionState = vixAvailable and vixValue >= vixVolExpansion

string vixState = not vixAvailable ? "VIX N/A" :
     vixValue < vixRiskOn ? "CONTROLLED" :
     vixValue < vixBearMin ? "SCALP ONLY" :
     vixValue < vixRiskOff ? "BEAR CONFIRM" :
     vixValue < vixVolExpansion ? "RISK-OFF" :
     vixValue < vixPanic ? "VOL EXPANSION" :
     "PANIC"

color vixStateColor = not vixAvailable ? color.rgb(85, 85, 85) :
     vixValue < vixRiskOn ? color.rgb(0, 125, 75) :
     vixValue < vixBearMin ? color.rgb(170, 125, 0) :
     vixValue < vixRiskOff ? color.rgb(210, 95, 0) :
     vixValue < vixVolExpansion ? color.rgb(190, 0, 0) :
     vixValue < vixPanic ? color.rgb(125, 0, 130) :
     color.rgb(70, 0, 90)

//=============================================================================
// TREND FILTERS
//=============================================================================
trendLong = not useTrendFilter or (close > ema9 and ema9 >= ema21 and close >= vwapValue)
trendShort = not useTrendFilter or (close < ema9 and ema9 <= ema21 and close <= vwapValue)

momentumLong = close > open and close > ema9
momentumShort = close < open and close < ema9

//=============================================================================
// OPENING RANGE
//=============================================================================
var float orHigh = na
var float orLow = na

if newSession
    orHigh := na
    orLow := na

inOR = inSession and not na(sessionStartTime) and time < sessionStartTime + orMinutes * 60 * 1000
orComplete = inSession and not na(sessionStartTime) and time >= sessionStartTime + orMinutes * 60 * 1000

if inOR
    orHigh := na(orHigh) ? high : math.max(orHigh, high)
    orLow := na(orLow) ? low : math.min(orLow, low)

plot(showOR and indexMode ? orHigh : na, "Opening Range High", color=color.rgb(0, 95, 170), linewidth=2, style=plot.style_linebr)
plot(showOR and indexMode ? orLow : na, "Opening Range Low", color=color.rgb(155, 0, 125), linewidth=2, style=plot.style_linebr)

orLongOk = not useOpeningRange or not orComplete or close >= orLow
orShortOk = not useOpeningRange or not orComplete or close <= orHigh

//=============================================================================
// DECISION ZONE FILL
//=============================================================================
zoneHighPlot = plot(showZones and indexMode ? zoneHigh : na, "Decision Zone High", color=color.new(cNeutral, 85), linewidth=1)
zoneLowPlot  = plot(showZones and indexMode ? zoneLow : na, "Decision Zone Low", color=color.new(cNeutral, 85), linewidth=1)
fill(zoneHighPlot, zoneLowPlot, color=showZones ? color.new(color.gray, 91) : na, title="Decision Zone Fill")

riskBgColor =
     not showRiskBg or not vixAvailable ? na :
     vixValue >= vixVolExpansion ? color.new(color.rgb(150, 0, 90), 86) :
     vixValue >= vixRiskOff ? color.new(color.rgb(210, 0, 0), 89) :
     vixValue >= vixBearMin ? color.new(color.rgb(255, 130, 0), 92) :
     na

bgcolor(riskBgColor, title="VIX Risk Background")

//=============================================================================
// LEVEL LINES + STAGGERED LABELS
//=============================================================================
var line[] levelLines = array.new_line()
var label[] levelLabels = array.new_label()

f_clearObjects() =>
    while array.size(levelLines) > 0
        line.delete(array.pop(levelLines))
    while array.size(levelLabels) > 0
        label.delete(array.pop(levelLabels))

f_addLevel(float price, string name, color col, int idx, int width, string styleInput) =>
    if showLevels and not na(price)
        line l = line.new(
             x1=bar_index - lineBackBars,
             y1=price,
             x2=bar_index + lineFwdBars,
             y2=price,
             xloc=xloc.bar_index,
             extend=extend.right,
             color=col,
             width=width,
             style=styleInput)
        array.push(levelLines, l)

        if showLabels
            label lbl = label.new(
                 x=bar_index + labelOffsetBars + idx * labelStepBars,
                 y=price,
                 text=name + "  " + str.tostring(price, format.mintick),
                 xloc=xloc.bar_index,
                 yloc=yloc.price,
                 style=label.style_label_left,
                 color=col,
                 textcolor=color.white,
                 size=size.small,
                 textalign=text.align_left)
            array.push(levelLabels, lbl)

if barstate.islast
    f_clearObjects()

    if mode == "VIX"
        f_addLevel(18.00, "VIX Pivot", cPivot, 0, 3, line.style_solid)
        f_addLevel(18.50, "Warning", cBearWarn, 1, 3, line.style_solid)
        f_addLevel(19.00, "Bear Confirm", cBear, 2, 3, line.style_solid)
        f_addLevel(20.00, "Risk-Off", cBear, 3, 3, line.style_solid)
        f_addLevel(22.00, "Vol Expansion", cBear2, 4, 2, line.style_solid)
        f_addLevel(25.00, "Max +GEX / Panic", cBull2, 5, 2, line.style_solid)
    else
        f_addLevel(pivot, "Pivot / Flip", cPivot, 0, 3, line.style_solid)
        f_addLevel(bullTrigger, "Bull Trigger", cBull, 1, 3, line.style_solid)
        f_addLevel(bullConfirm, "Bull Confirm", cBull2, 2, 2, line.style_solid)
        f_addLevel(bullTarget1, "Bull T1", cBull, 3, 2, line.style_solid)
        f_addLevel(bullTarget2, "Bull T2", cBull2, 4, 2, line.style_solid)
        f_addLevel(bullTarget3, "Bull T3", cBull2, 5, 2, line.style_solid)
        f_addLevel(bullTarget4, "Bull T4", cBull2, 6, 2, line.style_solid)

        f_addLevel(support1, "Support / Must Hold", cNeutral, 7, 2, line.style_dashed)
        f_addLevel(support2, "Failure Watch", cBearWarn, 8, 2, line.style_solid)
        f_addLevel(bearWarning, "Bear Warning", cBearWarn, 9, 2, line.style_solid)
        f_addLevel(bearTrigger, "Bear Trigger", cBear, 10, 3, line.style_solid)
        f_addLevel(bearTarget1, "Bear T1", cBear, 11, 2, line.style_solid)
        f_addLevel(bearTarget2, "Bear T2", cBear2, 12, 2, line.style_solid)
        f_addLevel(bearTarget3, "Bear T3", cBear2, 13, 2, line.style_solid)

//=============================================================================
// SIGNAL ENGINE
//=============================================================================
baseSignalOk = activeDate and barOk and timeFilterOk and inSession

// Mode-specific decision logic.
spxPinReclaim = mode == "SPX" and baseSignalOk and ta.crossover(close, 7400.0) and trendLong and vixValue < vixBearMin
spxUpperBreak = mode == "SPX" and baseSignalOk and ta.crossover(close, 7425.0) and trendLong and vixValue < vixBearMin
spxBearBreak  = mode == "SPX" and baseSignalOk and close < 7350.0 and close[1] >= 7350.0 and trendShort and vixBearConfirm

spyReclaim738 = mode == "SPY" and baseSignalOk and ta.crossover(close, 738.0) and trendLong and vixValue < vixRiskOn
spyReclaim740 = mode == "SPY" and baseSignalOk and ta.crossover(close, 740.0) and trendLong and vixValue < vixRiskOn
spyBear735    = mode == "SPY" and baseSignalOk and close < 735.0 and close[1] >= 735.0 and trendShort and vixBearConfirm

qqqHoldBounce = mode == "QQQ" and baseSignalOk and low <= 707.0 and close > 707.0 and close > ema9 and vixValue < vixBearMin
qqqReclaim710 = mode == "QQQ" and baseSignalOk and ta.crossover(close, 710.0) and trendLong and vixValue < vixBearMin
qqqBearWarn   = mode == "QQQ" and baseSignalOk and close < 704.0 and close[1] >= 704.0 and vixBearConfirm
qqqTrapDoor   = mode == "QQQ" and baseSignalOk and close < 702.0 and close[1] >= 702.0 and trendShort and vixBearConfirm

longTriggerSignal = indexMode and baseSignalOk and ta.crossover(close, bullTrigger) and trendLong and vixValue < vixBearMin and orLongOk
longConfirmSignal = indexMode and baseSignalOk and ta.crossover(close, bullConfirm) and trendLong and vixValue < vixBearMin and orLongOk

bearWarningSignal = indexMode and baseSignalOk and ta.crossunder(close, bearWarning) and vixBearConfirm
bearTriggerSignal = indexMode and baseSignalOk and ta.crossunder(close, bearTrigger) and trendShort and vixBearConfirm and orShortOk

failedBreakoutSignal = indexMode and baseSignalOk and high > bullConfirm and close < failLevel and vixBearConfirm
failedReclaimSignal = indexMode and baseSignalOk and high > pivot and close < pivot and vixBearConfirm

orBullBreak = indexMode and baseSignalOk and alertOR and orComplete and not na(orHigh) and ta.crossover(close, orHigh) and close > pivot and trendLong and vixValue < vixBearMin
orBearBreak = indexMode and baseSignalOk and alertOR and orComplete and not na(orLow) and ta.crossunder(close, orLow) and close < pivot and trendShort and vixBearConfirm

vixCross185 = baseSignalOk and vixAvailable and ta.crossover(vixValue, vixRiskOn)
vixCross19  = baseSignalOk and vixAvailable and ta.crossover(vixValue, vixBearMin)
vixCross20  = baseSignalOk and vixAvailable and ta.crossover(vixValue, vixRiskOff)
vixCross22  = baseSignalOk and vixAvailable and ta.crossover(vixValue, vixVolExpansion)
vixLose18   = baseSignalOk and vixAvailable and ta.crossunder(vixValue, 18.0)

//=============================================================================
// SIGNAL MARKERS
//=============================================================================
plotshape(showSignals and spxPinReclaim, title="SPX Pin Reclaim", text="SPX 7400", style=shape.labelup, location=location.belowbar, color=cBull, textcolor=color.white, size=size.small)
plotshape(showSignals and spxUpperBreak, title="SPX Upper Break", text="SPX 7425", style=shape.triangleup, location=location.belowbar, color=cBull2, textcolor=color.white, size=size.small)
plotshape(showSignals and spxBearBreak, title="SPX Bear Break", text="SPX FAIL", style=shape.labeldown, location=location.abovebar, color=cBear, textcolor=color.white, size=size.small)

plotshape(showSignals and spyReclaim738, title="SPY 738 Reclaim", text="SPY 738", style=shape.labelup, location=location.belowbar, color=cBull, textcolor=color.white, size=size.small)
plotshape(showSignals and spyReclaim740, title="SPY 740 Reclaim", text="SPY 740", style=shape.triangleup, location=location.belowbar, color=cBull2, textcolor=color.white, size=size.small)
plotshape(showSignals and spyBear735, title="SPY 735 Breakdown", text="SPY 735", style=shape.labeldown, location=location.abovebar, color=cBear, textcolor=color.white, size=size.small)

plotshape(showSignals and qqqHoldBounce, title="QQQ 706/707 Hold", text="QQQ HOLD", style=shape.labelup, location=location.belowbar, color=cBull, textcolor=color.white, size=size.small)
plotshape(showSignals and qqqReclaim710, title="QQQ 710 Reclaim", text="QQQ 710", style=shape.triangleup, location=location.belowbar, color=cBull2, textcolor=color.white, size=size.small)
plotshape(showSignals and qqqBearWarn, title="QQQ 704 Warning", text="QQQ WARN", style=shape.triangledown, location=location.abovebar, color=cBearWarn, textcolor=color.white, size=size.small)
plotshape(showSignals and qqqTrapDoor, title="QQQ Trap Door", text="TRAP", style=shape.labeldown, location=location.abovebar, color=cBear, textcolor=color.white, size=size.small)

plotshape(showSignals and failedBreakoutSignal, title="Failed Breakout", text="FAIL", style=shape.labeldown, location=location.abovebar, color=color.rgb(115, 0, 0), textcolor=color.white, size=size.tiny)
plotshape(showSignals and orBullBreak, title="OR Bull Break", text="OR↑", style=shape.triangleup, location=location.belowbar, color=cBull2, textcolor=color.white, size=size.tiny)
plotshape(showSignals and orBearBreak, title="OR Bear Break", text="OR↓", style=shape.triangledown, location=location.abovebar, color=cBear2, textcolor=color.white, size=size.tiny)

//=============================================================================
// DASHBOARD
//=============================================================================
var table dash = table.new(position.top_right, 2, 15, border_width=1)

if barstate.islast and showDashboard
    headerBg = cBlack
    cellBg = whiteTheme ? color.rgb(250, 250, 250) : color.rgb(35, 35, 35)
    textMain = whiteTheme ? color.rgb(20, 20, 20) : color.white

    table.cell(dash, 0, 0, "Mode", bgcolor=headerBg, text_color=color.white)
    table.cell(dash, 1, 0, mode, bgcolor=headerBg, text_color=color.white)

    table.cell(dash, 0, 1, "Setup", bgcolor=cellBg, text_color=textMain)
    table.cell(dash, 1, 1, setupText, bgcolor=cellBg, text_color=textMain)

    table.cell(dash, 0, 2, "Pivot / Flip", bgcolor=color.rgb(255, 242, 190), text_color=color.black)
    table.cell(dash, 1, 2, str.tostring(pivot, format.mintick), bgcolor=color.rgb(255, 242, 190), text_color=color.black)

    table.cell(dash, 0, 3, "Bull Trigger", bgcolor=color.rgb(210, 245, 220), text_color=color.black)
    table.cell(dash, 1, 3, str.tostring(bullTrigger, format.mintick), bgcolor=color.rgb(210, 245, 220), text_color=color.black)

    table.cell(dash, 0, 4, "Bull Confirm", bgcolor=color.rgb(205, 235, 255), text_color=color.black)
    table.cell(dash, 1, 4, str.tostring(bullConfirm, format.mintick), bgcolor=color.rgb(205, 235, 255), text_color=color.black)

    table.cell(dash, 0, 5, "Bull Targets", bgcolor=color.rgb(230, 250, 235), text_color=color.black)
    table.cell(dash, 1, 5, str.tostring(bullTarget1, format.mintick) + " / " + str.tostring(bullTarget2, format.mintick) + " / " + str.tostring(bullTarget3, format.mintick) + " / " + str.tostring(bullTarget4, format.mintick), bgcolor=color.rgb(230, 250, 235), text_color=color.black)

    table.cell(dash, 0, 6, "Bear Warning", bgcolor=color.rgb(255, 232, 210), text_color=color.black)
    table.cell(dash, 1, 6, str.tostring(bearWarning, format.mintick), bgcolor=color.rgb(255, 232, 210), text_color=color.black)

    table.cell(dash, 0, 7, "Bear Trigger", bgcolor=color.rgb(255, 218, 218), text_color=color.black)
    table.cell(dash, 1, 7, str.tostring(bearTrigger, format.mintick), bgcolor=color.rgb(255, 218, 218), text_color=color.black)

    table.cell(dash, 0, 8, "Bear Targets", bgcolor=color.rgb(255, 235, 235), text_color=color.black)
    table.cell(dash, 1, 8, str.tostring(bearTarget1, format.mintick) + " / " + str.tostring(bearTarget2, format.mintick) + " / " + str.tostring(bearTarget3, format.mintick), bgcolor=color.rgb(255, 235, 235), text_color=color.black)

    table.cell(dash, 0, 9, "Long Contract", bgcolor=cellBg, text_color=textMain)
    table.cell(dash, 1, 9, longContract, bgcolor=cellBg, text_color=textMain)

    table.cell(dash, 0, 10, "Short Contract", bgcolor=cellBg, text_color=textMain)
    table.cell(dash, 1, 10, shortContract, bgcolor=cellBg, text_color=textMain)

    table.cell(dash, 0, 11, "OR High / Low", bgcolor=cellBg, text_color=textMain)
    table.cell(dash, 1, 11, (na(orHigh) ? "N/A" : str.tostring(orHigh, format.mintick)) + " / " + (na(orLow) ? "N/A" : str.tostring(orLow, format.mintick)), bgcolor=cellBg, text_color=textMain)

    table.cell(dash, 0, 12, "Trend", bgcolor=cellBg, text_color=textMain)
    table.cell(dash, 1, 12, trendLong ? "LONG ALIGNED" : trendShort ? "SHORT ALIGNED" : "MIXED", bgcolor=trendLong ? color.rgb(205, 245, 220) : trendShort ? color.rgb(255, 218, 218) : color.rgb(240, 240, 210), text_color=color.black)

    table.cell(dash, 0, 13, "VIX State", bgcolor=vixStateColor, text_color=color.white)
    table.cell(dash, 1, 13, vixState + " | " + (vixAvailable ? str.tostring(vixValue, "#.##") : "N/A"), bgcolor=vixStateColor, text_color=color.white)

    table.cell(dash, 0, 14, "Active Date", bgcolor=cellBg, text_color=textMain)
    table.cell(dash, 1, 14, activeDate ? "YES" : "NO", bgcolor=activeDate ? color.rgb(205, 245, 220) : color.rgb(255, 218, 218), text_color=color.black)

//=============================================================================
// ALERT CONDITIONS
//=============================================================================
alertcondition(spxPinReclaim, "SPX 7400 Pin Reclaim", "SPX reclaimed/held 7400. Use Any alert() function call for full message.")
alertcondition(spxUpperBreak, "SPX 7425 Upper Break", "SPX broke 7425. Use Any alert() function call for full message.")
alertcondition(spxBearBreak, "SPX 7350 Failure", "SPX broke 7350. Use Any alert() function call for full message.")

alertcondition(spyReclaim738, "SPY 738 Reclaim", "SPY reclaimed 738. Use Any alert() function call for full message.")
alertcondition(spyReclaim740, "SPY 740 Reclaim", "SPY reclaimed 740. Use Any alert() function call for full message.")
alertcondition(spyBear735, "SPY 735 Breakdown", "SPY broke 735. Use Any alert() function call for full message.")

alertcondition(qqqHoldBounce, "QQQ 706/707 Hold", "QQQ held 706/707. Use Any alert() function call for full message.")
alertcondition(qqqReclaim710, "QQQ 710 Reclaim", "QQQ reclaimed 710. Use Any alert() function call for full message.")
alertcondition(qqqTrapDoor, "QQQ 702 Trap Door", "QQQ broke 702. Use Any alert() function call for full message.")

alertcondition(failedBreakoutSignal, "Failed Breakout", "Failed breakout detected. Use Any alert() function call for full message.")
alertcondition(orBullBreak, "Opening Range Bull Break", "Opening range upside break. Use Any alert() function call for full message.")
alertcondition(orBearBreak, "Opening Range Bear Break", "Opening range downside break. Use Any alert() function call for full message.")

alertcondition(vixCross185, "VIX 18.50 Warning", "VIX crossed 18.50.")
alertcondition(vixCross19, "VIX 19 Bear Confirmation", "VIX crossed 19.")
alertcondition(vixCross20, "VIX 20 Risk-Off", "VIX crossed 20.")
alertcondition(vixCross22, "VIX 22 Vol Expansion", "VIX crossed 22.")
alertcondition(vixLose18, "VIX Lost 18", "VIX crossed below 18.")

//=============================================================================
// DYNAMIC ALERT MESSAGES
//=============================================================================
string vixText = vixAvailable ? str.tostring(vixValue, "#.##") : "N/A"

if alertBull and spxPinReclaim
    alert("SPX 7400 PIN RECLAIM | Close " + str.tostring(close, format.mintick) + " | Contract: SPXW 5/13 7400C or 7425C | Targets: 7425 / 7450 / 7475 / 7500 | Invalidation: below 7375, hard fail below 7350 | VIX " + vixText, alert.freq_once_per_bar_close)

if alertBull and spxUpperBreak
    alert("SPX 7425 UPPER BREAK | Close " + str.tostring(close, format.mintick) + " | Contract: SPXW 5/13 7425C | Targets: 7450 / 7475 / 7500 | Do not overstay if VIX >19 | VIX " + vixText, alert.freq_once_per_bar_close)

if alertBear and spxBearBreak
    alert("SPX 7350 FAILURE | Close " + str.tostring(close, format.mintick) + " | Contract focus: SPX 5/15 7390P / 7335P / 7325P | Targets: 7335 / 7325 / 7300 | Invalidation: reclaim 7375/7400 | VIX " + vixText, alert.freq_once_per_bar_close)

if alertBull and spyReclaim738
    alert("SPY 738 RECLAIM | Close " + str.tostring(close, format.mintick) + " | Contract: SPY 5/13 738C or SPY 5/18 745C | Targets: 740 / 742 / 745 | Invalidation: below 736/735 | VIX " + vixText, alert.freq_once_per_bar_close)

if alertBull and spyReclaim740
    alert("SPY 740 CONFIRMATION | Close " + str.tostring(close, format.mintick) + " | Upside path open toward 742 / 745 | Contract: SPY 5/18 745C or 5/13 740C | VIX " + vixText, alert.freq_once_per_bar_close)

if alertBear and spyBear735
    alert("SPY 735 BREAKDOWN | Close " + str.tostring(close, format.mintick) + " | Contract: SPY 5/13 734P or 730P | Targets: 733 / 730 / 725 | Invalidation: reclaim 738 | VIX " + vixText, alert.freq_once_per_bar_close)

if alertBull and qqqHoldBounce
    alert("QQQ 706/707 HOLD | Close " + str.tostring(close, format.mintick) + " | Bounce setup active. Contract: QQQ 5/13 707C/711C or 5/15 710C/715C | Targets: 710 / 714-715 / 718-720 | Invalid below 704/702 | VIX " + vixText, alert.freq_once_per_bar_close)

if alertBull and qqqReclaim710
    alert("QQQ 710 RECLAIM | Close " + str.tostring(close, format.mintick) + " | Contract: QQQ 5/13 711C or 5/15 710C/715C | Targets: 714-715 / 718 / 720 | Invalidation: back below 706 | VIX " + vixText, alert.freq_once_per_bar_close)

if alertBear and qqqBearWarn
    alert("QQQ 704 WARNING | Close " + str.tostring(close, format.mintick) + " | Trap-door risk rising. Wait for 702 confirmation or failed reclaim of 706. Short contract focus: QQQ 5/15 710P or 5/13 700P after 702 breaks | VIX " + vixText, alert.freq_once_per_bar_close)

if alertBear and qqqTrapDoor
    alert("QQQ 702 TRAP DOOR | Close " + str.tostring(close, format.mintick) + " | Contract: QQQ 5/15 710P or QQQ 5/13 700P | Targets: 700 / 695 / 690 | Invalidation: reclaim 706, hard invalid above 710 | VIX " + vixText, alert.freq_once_per_bar_close)

if alertFail and failedBreakoutSignal
    alert("FAILED BREAKOUT | " + mode + " | High exceeded confirmation but closed back below failure/pivot level | Close " + str.tostring(close, format.mintick) + " | Watch downside contract: " + shortContract + " | VIX " + vixText, alert.freq_once_per_bar_close)

if alertFail and failedReclaimSignal
    alert("FAILED RECLAIM | " + mode + " | Price traded above pivot but closed back below it | Close " + str.tostring(close, format.mintick) + " | Risk of rotation lower. VIX " + vixText, alert.freq_once_per_bar_close)

if alertOR and orBullBreak
    alert("OPENING RANGE BULL BREAK | " + mode + " | Close " + str.tostring(close, format.mintick) + " | OR High " + str.tostring(orHigh, format.mintick) + " | Contract: " + longContract + " | VIX " + vixText, alert.freq_once_per_bar_close)

if alertOR and orBearBreak
    alert("OPENING RANGE BEAR BREAK | " + mode + " | Close " + str.tostring(close, format.mintick) + " | OR Low " + str.tostring(orLow, format.mintick) + " | Contract: " + shortContract + " | VIX " + vixText, alert.freq_once_per_bar_close)

if alertVix and vixCross185
    alert("VIX WARNING | VIX crossed above 18.50 | Failed breakout risk rising. Tighten call stops. VIX " + vixText, alert.freq_once_per_bar_close)

if alertVix and vixCross19
    alert("VIX BEAR CONFIRMATION | VIX crossed above 19 | QQQ/SPY/SPX downside triggers gain priority. VIX " + vixText, alert.freq_once_per_bar_close)

if alertVix and vixCross20
    alert("VIX RISK-OFF | VIX crossed above 20 | Do not force index calls unless price is strongly accepting above trigger. VIX " + vixText, alert.freq_once_per_bar_close)

if alertVix and vixCross22
    alert("VIX VOL EXPANSION | VIX crossed above 22 | Downside continuation and hedge contracts have priority. VIX " + vixText, alert.freq_once_per_bar_close)

if alertVix and vixLose18
    alert("VIX CONTROLLED | VIX lost 18 | Equity bounce/breakout setups have higher validity if price confirms. VIX " + vixText, alert.freq_once_per_bar_close)
````

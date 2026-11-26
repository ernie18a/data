# IND001 - Tide Flow Structure Map

- url: https://www.tradingview.com/script/2eb8PNMp-IND001-Tide-Flow-Structure-Map/
- type: indicator
- pine_id: PUB;5fde69848832474a902a2dd872f76969
- version: 1.0

## Description

[b]==================================================
WARNING
==================================================[/b]

This indicator is designed to read trend structure. It is not designed to act on every drop only because price reaches a lower or red area.

The correct use is to first check whether the market still has a supportive structure. The indicator works best when price action is stable, liquid, and structured. It is less suitable for very risky, illiquid, speculative, or erratic instruments.

[quote]The script does not predict the future. It helps the user read whether current market conditions are supportive, neutral, weakening, or risk-off.[/quote]

[b]==================================================
(1) INTRODUCTION
==================================================[/b]

[b]IND001 - Tide Flow Structure Map[/b] is a public open-source trend-structure indicator.

The idea behind Tide Flow is simple: markets often move in phases. Some phases are healthy and structured, while others are weak, noisy, or damaged. This indicator was built to help users read those phases more clearly by combining trend direction, active flow, structure, volatility, trend strength, and optional asset-quality checks.

It is not meant to be a simple signal tool. It is meant to help the user understand the current market condition first.

[b]==================================================
(2) OVERVIEW
==================================================[/b]

Tide Flow is mainly a structure-reading and trend-following tool. It is designed to work best when the market shows clear continuation behavior and enough stability for the curves to reflect real structure.

The main question is:

[quote]Is the current movement still healthy and structured, or is the structure starting to weaken?[/quote]

Instead of using one simple signal, the indicator combines several layers of information:

[list]
[*]main trend direction
[*]active trend flow
[*]upper and lower price structure
[*]volatility
[*]trend strength
[*]higher-timeframe confirmation
[*]RSI extension control
[*]optional asset-quality filtering
[/list]

[b]Quick color key[/b]

[list]
[*]🟨 [b]Yellow[/b] - main trend environment
[*]🟦 [b]Blue[/b] - active trend flow
[*]🟩 [b]Green[/b] - upper structure and strength
[*]🟥 [b]Red[/b] - lower structure and risk
[/list]

[b]--------------------------------------------------
WHERE TIDE FLOW FITS BEST
--------------------------------------------------[/b]

[b]Best trading styles[/b]

[list]
[*][b]Swing trading[/b] - usually the best fit, because structure is clearer on higher timeframes.
[*][b]Intraday / day trading[/b] - can work well on liquid and cleanly trending assets.
[*][b]Position trading[/b] - suitable for following broader structure on higher timeframes.
[/list]

[b]Less suitable trading style[/b]

[list]
[*][b]Scalping[/b] - usually the weakest fit, because very low timeframes often contain more noise and false shifts.
[/list]

[b]Timeframe guidance[/b]

[list]
[*][b]Best fit:[/b] 1H, 4H, Daily
[*][b]Good fit:[/b] 15m, Weekly
[*][b]Use with caution:[/b] 5m and lower
[/list]

[b]Best asset types[/b]

[list]
[*]liquid stocks
[*]major crypto assets
[*]index-related instruments
[*]assets with stable trend structure
[*]markets with clear continuation behavior
[/list]

[b]Less suitable asset types[/b]

[list]
[*]very low-liquidity assets
[*]small speculative instruments
[*]thin or manipulated markets
[*]assets with frequent abnormal spikes or unstable gaps
[*]sideways markets with weak structure
[/list]

[b]Practical summary[/b]

[list]
[*][b]Best overall use:[/b] swing trading
[*][b]Good use:[/b] day trading on liquid trending assets
[*][b]Weakest use:[/b] scalping on very low timeframes
[/list]

[b]==================================================
(3) MOST IMPORTANT: HOW TO USE IT PROPERLY
==================================================[/b]

The correct way to use this indicator is to read the market structure first, then use the table, background colors, and alerts only as extra confirmation.

[b]Simple workflow[/b]

[list=1]
[*]🟨 [b]Start with the yellow curve.[/b]
Check whether price is above or below the main trend. If price is below the yellow curve, the broader structure is weaker and long-side ideas need more caution.

[*]🟦 [b]Then check the blue curve.[/b]
The blue curve shows the active trend flow. A rising or stable blue curve is healthier. A falling blue curve means the active flow is weakening.

[*]🟩 [b]Then check the green curve.[/b]
The green curve shows upper structure and strength. Price moving toward or above the green curve can show stronger expansion, but chasing too far above it can create poor risk-reward.

[*]🟥 [b]Then check the red curve.[/b]
The red curve shows lower structure and risk. Price moving close to or below the red curve means the structure is weakening or breaking.

[*][b]Only after that, check the table and background colors.[/b]
The table and BG colors are helpers. They should support the structure reading, not replace it.

[*][b]Use alerts only for monitoring.[/b]
An alert means a chart condition has appeared. It is not a trade instruction and does not guarantee a result.
[/list]

[b]Correct use[/b]

[list]
[*]Use it when the market is liquid, structured, and trending clearly.
[*]Use it to separate supportive structure from weak or risk-off structure.
[*]Use it to avoid acting too early when price is below the main trend.
[*]Use it with your own risk management and position sizing.
[/list]

[b]Incorrect use[/b]

[list]
[*]Do not use it as a simple green-buy / red-sell system.
[*]Do not act only because the table shows a stronger state.
[*]Do not act only because the background color changes.
[*]Do not act only because price touches the red or lower area.
[*]Do not expect the script to predict future price movement.
[/list]

[quote]The most important rule is: read the curves first. The helpers come second.[/quote]

[b]==================================================
(4) CURVES
==================================================[/b]

The indicator is built around four main curves. Each curve represents a different layer of market structure.

[b]🟨 Yellow curve - Main trend[/b]

The yellow curve represents the broader trend environment.

[list]
[*]Price above yellow: the broader trend condition is more supportive.
[*]Price below yellow: the broader trend is weaker or damaged.
[/list]

[b]🟦 Blue curve - Active trend flow[/b]

The blue curve represents the active movement inside the main trend.

[list]
[*]Price above blue: active flow is stronger.
[*]Price around blue: the market is testing the flow.
[*]Price below blue: the active flow is weakening.
[/list]

[b]🟩 Green curve - Upper structure[/b]

The green curve represents the upper part of recent smoothed price structure.

[list]
[*]Price below green: price is still building inside structure.
[*]Price at or above green: strength or expansion is increasing.
[/list]

[b]🟥 Red curve - Lower structure[/b]

The red curve represents the lower part of recent smoothed price structure.

[list]
[*]Price above red: lower structure is still holding.
[*]Price near red: structure is becoming weaker.
[*]Price below red: lower structure is breaking.
[/list]

[b]==================================================
(5) LOGICAL SEQUENCE
==================================================[/b]

The indicator should be read in order. Each curve gives a different part of the full picture.

[b]Correct reading order[/b]

[list=1]
[*]🟨 Yellow curve - defines the broader environment
[*]🟦 Blue curve - defines the active flow
[*]🟩 Green curve - shows strength and expansion
[*]🟥 Red curve - shows weakness and risk
[/list]

[b]What is normal[/b]

A healthier bullish structure usually develops in a stable way:

[list]
[*]price is above the yellow curve
[*]blue curve is flat-to-rising or rising
[*]price respects the blue curve during pullbacks
[*]price moves toward or above the green curve
[*]red curve remains clearly below price
[/list]

This suggests that the market structure is still functioning in a supportive way.

[b]What is not normal[/b]

A weaker or damaged structure usually looks different:

[list]
[*]price falls below the yellow curve
[*]blue curve starts to flatten or decline
[*]price cannot recover toward the green curve
[*]price moves too close to the red curve or breaks below it
[/list]

This suggests that the tide flow is no longer healthy and the market should be treated with caution.

[b]==================================================
(6) EXAMPLE 1: CLEAN PULLBACK IN TREND
==================================================[/b]

Price is above the yellow curve, so the broader environment is still supportive. The blue curve is rising, showing that the active flow is healthy. Price pulls back toward the blue curve, respects it, and then continues toward the green curve.

[b]Main reading[/b]

[list]
[*]above yellow = supportive environment
[*]blue rising = healthy active flow
[*]pullback to blue = controlled movement
[/list]

This is a structured use case because the idea is based on trend behavior, not on chasing price.

[b]==================================================
(7) EXAMPLE 2: BREAKOUT AFTER BUILDING
==================================================[/b]

Price remains above the yellow curve and spends time moving between the blue and green curves. This shows that the market is building structure. Later, price moves above the green curve with stronger behavior.

[b]Main reading[/b]

[list]
[*]above yellow = supportive condition
[*]movement between blue and green = structure building
[*]move above green = expansion
[/list]

This is a better-quality setup because the move happens after structure has already developed.

[b]==================================================
(8) EXAMPLE 3: RECLAIM OF THE BLUE CURVE
==================================================[/b]

Price briefly moves below the blue curve but remains above the yellow curve. Soon after, price moves back above the blue curve and continues higher.

[b]Main reading[/b]

[list]
[*]above yellow = broader trend still valid
[*]temporary move below blue = short-term weakness
[*]reclaim of blue = active flow improves again
[/list]

This is useful because the main structure did not break and the active flow was restored.

[b]==================================================
(9) EXAMPLE 4: AVOIDING A WEAK CONDITION
==================================================[/b]

Price moves below the yellow curve. This means the broader trend environment is no longer supportive. A small bounce may appear, but the structure is still weak.

[b]Main reading[/b]

[list]
[*]below yellow = weak environment
[*]small bounce = not enough confirmation
[*]structure still weak = caution
[/list]

This helps the user avoid acting too early in a damaged structure.

[b]==================================================
(10) EXAMPLE 5: SIDEWAYS MARKET
==================================================[/b]

Price moves around the blue curve with no clear direction. The blue curve is flat, and price does not clearly move toward the green curve or break structure with strength.

[b]Main reading[/b]

[list]
[*]flat blue = weak active flow
[*]sideways movement = unclear structure
[*]no clean expansion = lower-quality condition
[/list]

This is a situation where patience is usually better than forcing a trade idea.

[b]==================================================
(11) OPTIONAL HELPERS: BG COLORS, TABLE, SETUP / RISK USE
==================================================[/b]

The indicator includes helper tools to make the chart easier to read. These tools are not the full system by themselves. The main reading still comes from the four structure curves.

[b]--------------------------------------------------

1. BG COLORS - VISUAL HELP FOR IMPROVING CONDITIONS
   --------------------------------------------------[/b]

Background colors can appear when the indicator detects improving structure after a weaker phase.

They can help the user notice:

[list]
[*]improving recovery conditions
[*]strengthening active flow
[*]a transition from weaker structure to healthier structure
[/list]

They should not be used as standalone entry signals.

[b]BG colors are not:[/b]

[list]
[*]direct trade instructions
[*]standalone entry signals
[*]a replacement for reading the curves
[*]a guarantee that price will continue
[/list]

[quote]Correct use: first read the yellow, blue, green, and red curves. Then use background colors as extra visual context only.[/quote]

[b]--------------------------------------------------
2) TABLE - QUICK SUMMARY OF CURRENT CONDITION
--------------------------------------------------[/b]

The table gives a compact summary of the current market state. It helps organize the most important checks in one place.

The table can show:

[list]
[*]current state
[*]direction
[*]higher-timeframe trend
[*]trend condition
[*]ADX strength
[*]ATR condition
[*]structure zone
[*]asset quality
[*]quality data
[*]quality explanation
[/list]

The table is useful because it shows whether the current move is supported by more than one condition. It should still be treated as a summary panel, not as a replacement for chart reading.

[b]--------------------------------------------------
3) SETUP / RISK USE - EXTRA CONFIRMATION ONLY
--------------------------------------------------[/b]

The indicator is first a structure-reading tool. The table, background colors, and alerts can support the reading, but they should not replace it.

A stronger long-side condition may be present when:

[list]
[*]price is above the yellow curve
[*]the blue curve is healthy or rising
[*]price respects structure instead of breaking it
[*]price moves toward or above the green curve
[*]the table supports the stronger condition
[*]background colors show improving structure
[/list]

A weaker or risk-off condition may be present when:

[list]
[*]price falls below the yellow curve
[*]the blue curve weakens or turns down
[*]price fails to recover toward the green curve
[*]price moves close to or below the red curve
[*]the table no longer supports the stronger condition
[/list]

[b]Simple summary[/b]

[list]
[*]the curves explain the structure
[*]the background colors show visual improvement
[*]the table summarizes the internal checks
[*]alerts help with monitoring
[/list]

When these parts agree, the reading is stronger. When they disagree, the user should be more careful.

[b]==================================================
(12) HOW EVERYTHING IS CALCULATED
==================================================[/b]

This section explains the internal logic in simple terms.

[b]How the curves are calculated[/b]

[list]
[*]Yellow curve: an EMA of price using the main trend length.
[*]Blue curve: a faster EMA of price.
[*]Green curve: recent highest highs over a lookback period, then smoothed.
[*]Red curve: recent lowest lows over a lookback period, then smoothed.
[/list]

[b]How the main conditions are calculated[/b]

[list]
[*]ATR checks whether volatility is active enough.
[*]ADX checks whether trend strength is acceptable.
[*]Higher-timeframe filter checks whether broader direction supports the trend.
[*]RSI helps avoid overly extended long-side conditions.
[*]The active-flow check uses the slope of the blue curve to detect weakness.
[/list]

[b]How asset quality is calculated[/b]

The optional asset-quality guard uses:

[list]
[*]market cap
[*]20-day average dollar volume
[*]60-day average dollar volume
[*]price level
[/list]

These values are combined into a quality score and grouped into a quality rank. The purpose is to help avoid instruments with weak liquidity, weak size, or unstable trading conditions.

In practice, the indicator combines:

[list]
[*]trend structure
[*]active flow
[*]volatility
[*]trend strength
[*]higher-timeframe confirmation
[*]asset quality
[*]liquidity quality
[/list]

The purpose is not to predict the future exactly. The purpose is to judge whether current market conditions are supportive enough.

[b]==================================================
(13) 10 POINTS: WHAT IS WRONG WHEN USING TIDE FLOW
==================================================[/b]

[list=1]
[*][b]Using it like a simple signal tool[/b]
The indicator is not meant to be a simple green-buy / red-sell system.

[*][b]Acting below the yellow curve without caution[/b]
When price is below the yellow curve, the broader environment is weaker.

[*][b]Ignoring the blue curve[/b]
If the blue curve is flat or falling, the active flow is weak.

[*][b]Treating every dip as an opportunity[/b]
A drop in price alone is not a valid reason to act.

[*][b]Chasing price too far above the green curve[/b]
Late entries after large expansion can create poor risk-reward.

[*][b]Ignoring the red curve[/b]
When price gets close to or below the red curve, structure is weakening.

[*][b]Using it in sideways markets without caution[/b]
The indicator works best when the market has structure and direction.

[*][b]Skipping the reading sequence[/b]
The correct order is yellow first, blue second, green third, red last.

[*][b]Expecting prediction instead of interpretation[/b]
The indicator helps interpret condition. It does not predict future price.

[*][b]Using it without patience[/b]
Better readings usually come when structure is clear and supportive.
[/list]

[b]==================================================
(14) ALERTCONDITION
==================================================[/b]

The indicator includes alert conditions so users can monitor important chart events.

Alerts can be used for conditions such as:

[list]
[*]main gates becoming aligned
[*]price moving above the upper structure curve
[*]a long-side setup forming
[*]recovery conditions appearing
[*]asset quality warning
[*]price crossing below important structure levels
[*]price confirming below the active risk line
[/list]

[quote]Alerts are only monitoring tools. They are not trade instructions, performance claims, or guarantees of future results.[/quote]

[b]==================================================
(15) SUMMARY TO USE
==================================================[/b]

Use Tide Flow as a trend-following and structure-reading indicator, not as a simple buy or sell signal tool.

[b]Simple reading process[/b]

[list=1]
[*]🟨 Start with the yellow curve to check the broader environment.
[*]🟦 Use the blue curve to confirm active trend flow.
[*]🟩 Use the green curve to identify strength or expansion.
[*]🟥 Use the red curve to monitor weakness and risk.
[*]Use the table and background colors only as helpers.
[*]Use alerts only for monitoring chart conditions.
[*]Avoid forcing trades in weak, sideways, illiquid, or unstable markets.
[*]Use your own risk management and analysis.
[/list]

[quote]The indicator is most useful when the market is structured, liquid, and trending clearly.[/quote]

[b]==================================================
DISCLAIMER
==================================================[/b]

This script is a public open-source indicator for educational and informational use.

It is not financial advice, investment advice, or a recommendation to buy or sell any asset.

The indicator does not guarantee profitable trades, signal accuracy, or future performance. It can produce false or late signals, especially in sideways, illiquid, volatile, or news-driven markets.

Users should always apply their own analysis, position sizing, and risk management before making any trading decision.

[b]==================================================
PINE NOTE
==================================================[/b]

[pine]
// Public open-source indicator
// Alerts identify chart conditions only
// No future performance is guaranteed
[/pine]

## Source Code

````pine
//@version=6
indicator("IND001 - Tide Flow Structure Map", shorttitle="IND001 Tide Flow", overlay=true, max_labels_count=100)

//------------------------------------------------------------------------------
// IND001 - Tide Flow Structure Map
// Open-source trend-structure dashboard using EMA direction, smoothed high/low
// structure, ATR volatility, ADX trend strength, higher-timeframe context, and
// an optional asset-quality guard. Alerts identify chart conditions only.
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
grpMain = "Main"
showTable   = input.bool(true, "Show table", group=grpMain)
tablePos    = input.string("Bottom Right", "Table position", options=["Bottom Right", "Bottom Left", "Top Right", "Top Left"], group=grpMain)
showBgState = input.bool(false, "Show bullish state background", group=grpMain)

grpCore = "Core Settings"
trendLen  = input.int(150, "Trend EMA length", minval=20, group=grpCore)
fastLen   = input.int(50, "EMA50 length", minval=10, group=grpCore)
hhLen     = input.int(14, "Structure lookback", minval=2, group=grpCore)
hhEmaLen  = input.int(14, "Structure smoothing", minval=1, group=grpCore)
showTrend = input.bool(true, "Show Trend EMA", group=grpCore)
showFast  = input.bool(true, "Show EMA50", group=grpCore)
showTop   = input.bool(true, "Show Resistance Top", group=grpCore)
showBot   = input.bool(true, "Show Support Bottom", group=grpCore)

grpFilters = "Main Filters"
atrMinPct = input.float(0.25, "Min ATR %", step=0.05, minval=0.0, group=grpFilters)
adxMin    = input.float(14.0, "Min ADX", step=0.5, minval=0.0, maxval=100.0, group=grpFilters)
useHTF    = input.bool(true, "Use HTF trend filter", group=grpFilters)
htfTf     = input.timeframe("60", "HTF timeframe", group=grpFilters)

grpQuality = "Asset Quality"
useAssetProtection = input.bool(false, "Use asset quality guard", group=grpQuality)
qualityProfile     = input.string("Balanced", "Quality profile", options=["Aggressive", "Balanced", "Conservative", "Custom"], group=grpQuality)

//------------------------------------------------------------------------------
// Internal settings kept out of the input window to keep the script simple to use
//------------------------------------------------------------------------------

// Colors
colTrend = color.yellow
colFast  = color.rgb(37, 99, 235)
colTop   = color.rgb(96, 246, 3)
colBot   = color.rgb(252, 0, 0)

tideGreenColor  = color.rgb(34, 197, 94)
tideYellowColor = color.rgb(130, 244, 73)
tideRedColor    = color.rgb(239, 68, 68)
bullStateBg     = color.rgb(59, 130, 246)

// Visual zones
showTideFill       = true
showBottomFill     = true
tideGreenAlpha     = 74
tideYellowAlpha    = 80
tideRedAlpha       = 72
bgAlpha            = 92
upperGreenZonePct  = 0.55
riseBoostAlphaStep = 10

// Filters
rsiLen    = 14
rsiMax    = 76
atrLen    = 14
adxLen    = 14
htfEmaLen = 200
useEngine = true
engineDeadzonePct = 0.02

// Setup and risk handling
cooldownBars       = 4
confirmOnCloseOnly = true
exitMode           = "ATR or Bottom"
atrStopMult        = 2.0
exitConfirmBars    = 2

// Recovery background
showRecoveryBg             = true
recoveryLookbackBars       = 20
recoveryMinRedBars         = 4
recoveryRequireRecentCross = false
recoveryRecentCrossBars    = 6
recoveryYellowAlpha        = 86
recoveryBlueAlpha          = 82
recoveryGreenAlpha         = 78
showStrongPlotShape        = true
strongShapeSize            = "Small"

// Asset quality guard
qualityAsSoftWarning = true
minRequiredQuality   = "GOOD"

// Custom thresholds in millions
capT1M  = 300
capT2M  = 1000
capT3M  = 5000
capT4M  = 10000
capT5M  = 50000

dv20T1M = 2
dv20T2M = 10
dv20T3M = 20
dv20T4M = 50
dv20T5M = 100

dv60T1M = 2
dv60T2M = 8
dv60T3M = 15
dv60T4M = 40
dv60T5M = 80

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------
f_posTable(_pos) =>
    pos = position.bottom_right
    if _pos == "Bottom Left"
        pos := position.bottom_left
    else if _pos == "Top Right"
        pos := position.top_right
    else if _pos == "Top Left"
        pos := position.top_left
    pos

f_gateWord(_ok) => _ok ? "GREEN" : "RED"

f_clampAlpha(_a) =>
    math.max(0, math.min(100, _a))

f_shapeSize(_s) =>
    _s == "Tiny" ? size.tiny : _s == "Normal" ? size.normal : size.small

f_qualityRank(_txt) =>
    _txt == "VERY RISKY" ? 0 :
     _txt == "RISKY" ? 1 :
     _txt == "ACCEPTABLE" ? 2 :
     _txt == "GOOD" ? 3 :
     _txt == "VERY GOOD" ? 4 : 5

f_qualityName(_rank) =>
    _rank <= 0 ? "VERY RISKY" :
     _rank == 1 ? "RISKY" :
     _rank == 2 ? "ACCEPTABLE" :
     _rank == 3 ? "GOOD" :
     _rank == 4 ? "VERY GOOD" : "STRONG"

f_qualityColor(_rank) =>
    _rank <= 0 ? color.rgb(220, 38, 38) :
     _rank == 1 ? color.rgb(249, 115, 22) :
     _rank == 2 ? color.rgb(234, 179, 8) :
     _rank == 3 ? color.rgb(132, 204, 22) :
     _rank == 4 ? color.rgb(34, 197, 94) : color.rgb(22, 163, 74)

f_score6(_valueM, _t1, _t2, _t3, _t4, _t5) =>
    _valueM >= _t5 ? 5 :
     _valueM >= _t4 ? 4 :
     _valueM >= _t3 ? 3 :
     _valueM >= _t2 ? 2 :
     _valueM >= _t1 ? 1 : 0

//------------------------------------------------------------------------------
// Core curves
//------------------------------------------------------------------------------
emaTrend = ta.ema(close, trendLen)
emaFast  = ta.ema(close, fastLen)

hh     = ta.highest(high, hhLen)
ll     = ta.lowest(low, hhLen)
top    = ta.ema(hh, hhEmaLen)
bottom = ta.ema(ll, hhEmaLen)

//------------------------------------------------------------------------------
// Filters
//------------------------------------------------------------------------------
atrVal = ta.atr(atrLen)
atrPct = atrVal / close * 100.0
volatilityOk = atrPct >= atrMinPct

[plusDI, minusDI, adx] = ta.dmi(adxLen, adxLen)
trendQualityOk = adx >= adxMin

rsi    = ta.rsi(close, rsiLen)
rsiOkL = rsi <= rsiMax

htfBull = request.security(syminfo.tickerid, htfTf, close > ta.ema(close, htfEmaLen), barmerge.gaps_off, barmerge.lookahead_off)
trendBull = close > emaTrend and emaFast > emaTrend and emaTrend > emaTrend[1]
bullDirection = useHTF ? (trendBull and htfBull) : trendBull

fastSlopePct = emaFast[1] != 0 ? ((emaFast - emaFast[1]) / emaFast[1]) * 100.0 : 0.0
engineBear   = fastSlopePct < -engineDeadzonePct
engineOk     = not useEngine or not engineBear

gateDIR = bullDirection
gateHTF = not useHTF or htfBull
gateADX = trendQualityOk
gateATR = volatilityOk

allGreen = gateDIR and gateHTF and gateADX and gateATR
barOkForSignals = not confirmOnCloseOnly or barstate.isconfirmed

//------------------------------------------------------------------------------
// Asset quality guard
// The guard combines size, dollar volume, and price level as chart context.
//------------------------------------------------------------------------------
cap1M  = qualityProfile == "Aggressive" ? 200   : qualityProfile == "Balanced" ? 300   : qualityProfile == "Conservative" ? 500    : capT1M
cap2M  = qualityProfile == "Aggressive" ? 500   : qualityProfile == "Balanced" ? 1000  : qualityProfile == "Conservative" ? 2000   : capT2M
cap3M  = qualityProfile == "Aggressive" ? 2000  : qualityProfile == "Balanced" ? 5000  : qualityProfile == "Conservative" ? 10000  : capT3M
cap4M  = qualityProfile == "Aggressive" ? 10000 : qualityProfile == "Balanced" ? 10000 : qualityProfile == "Conservative" ? 20000  : capT4M
cap5M  = qualityProfile == "Aggressive" ? 50000 : qualityProfile == "Balanced" ? 50000 : qualityProfile == "Conservative" ? 100000 : capT5M

dv20_1M = qualityProfile == "Aggressive" ? 1  : qualityProfile == "Balanced" ? 2   : qualityProfile == "Conservative" ? 5   : dv20T1M
dv20_2M = qualityProfile == "Aggressive" ? 5  : qualityProfile == "Balanced" ? 10  : qualityProfile == "Conservative" ? 15  : dv20T2M
dv20_3M = qualityProfile == "Aggressive" ? 10 : qualityProfile == "Balanced" ? 20  : qualityProfile == "Conservative" ? 30  : dv20T3M
dv20_4M = qualityProfile == "Aggressive" ? 25 : qualityProfile == "Balanced" ? 50  : qualityProfile == "Conservative" ? 75  : dv20T4M
dv20_5M = qualityProfile == "Aggressive" ? 50 : qualityProfile == "Balanced" ? 100 : qualityProfile == "Conservative" ? 150 : dv20T5M

dv60_1M = qualityProfile == "Aggressive" ? 1  : qualityProfile == "Balanced" ? 2   : qualityProfile == "Conservative" ? 4   : dv60T1M
dv60_2M = qualityProfile == "Aggressive" ? 4  : qualityProfile == "Balanced" ? 8   : qualityProfile == "Conservative" ? 12  : dv60T2M
dv60_3M = qualityProfile == "Aggressive" ? 8  : qualityProfile == "Balanced" ? 15  : qualityProfile == "Conservative" ? 25  : dv60T3M
dv60_4M = qualityProfile == "Aggressive" ? 20 : qualityProfile == "Balanced" ? 40  : qualityProfile == "Conservative" ? 60  : dv60T4M
dv60_5M = qualityProfile == "Aggressive" ? 40 : qualityProfile == "Balanced" ? 80  : qualityProfile == "Conservative" ? 120 : dv60T5M

avgDollarVol20 = request.security(syminfo.tickerid, "D", ta.sma(close * volume, 20), barmerge.gaps_off, barmerge.lookahead_off)
avgDollarVol60 = request.security(syminfo.tickerid, "D", ta.sma(close * volume, 60), barmerge.gaps_off, barmerge.lookahead_off)

avgDollarVol20M = avgDollarVol20 / 1000000.0
avgDollarVol60M = avgDollarVol60 / 1000000.0

sharesOut = request.financial(syminfo.tickerid, "TOTAL_SHARES_OUTSTANDING", "FQ", ignore_invalid_symbol=true)
marketCap = sharesOut * close
marketCapM = marketCap / 1000000.0
hasMarketCapData = not na(sharesOut) and not na(marketCap)

capScore = hasMarketCapData ? f_score6(marketCapM, cap1M, cap2M, cap3M, cap4M, cap5M) : 2
dv20Score = f_score6(avgDollarVol20M, dv20_1M, dv20_2M, dv20_3M, dv20_4M, dv20_5M)
dv60Score = f_score6(avgDollarVol60M, dv60_1M, dv60_2M, dv60_3M, dv60_4M, dv60_5M)

priceScore =
     close >= 50 ? 5 :
     close >= 20 ? 4 :
     close >= 10 ? 3 :
     close >= 5 ? 2 :
     close >= 3 ? 1 : 0

assetQualityScore =
     (capScore * 0.35) +
     (dv20Score * 0.25) +
     (dv60Score * 0.25) +
     (priceScore * 0.15)

assetQualityRank =
     assetQualityScore >= 4.5 ? 5 :
     assetQualityScore >= 3.8 ? 4 :
     assetQualityScore >= 3.0 ? 3 :
     assetQualityScore >= 2.2 ? 2 :
     assetQualityScore >= 1.2 ? 1 : 0

assetQualityTxt = f_qualityName(assetQualityRank)
assetQualityCol = f_qualityColor(assetQualityRank)

requiredQualityRank = f_qualityRank(minRequiredQuality)
assetQualityOk = assetQualityRank >= requiredQualityRank

assetQualityWarning = useAssetProtection and not assetQualityOk
assetQualityGateOk =
     not useAssetProtection ? true :
     qualityAsSoftWarning ? true : assetQualityOk

assetQualityWhy =
     assetQualityRank == 5 ? "Strong liquidity, size, and price structure." :
     assetQualityRank == 4 ? "Very good liquidity and size profile." :
     assetQualityRank == 3 ? "Good overall fit for this model." :
     assetQualityRank == 2 ? "Usable, but the quality profile is only moderate." :
     assetQualityRank == 1 ? "Risky: liquidity or size is on the weak side." :
     "Very risky: small, illiquid, or weak quality profile."

assetQualityDetails =
     "CAP " + (hasMarketCapData ? str.tostring(marketCapM, "#") + "M" : "N/A") + " | " +
     "20D " + str.tostring(avgDollarVol20M, "#") + "M | " +
     "60D " + str.tostring(avgDollarVol60M, "#") + "M | " +
     "PX " + str.tostring(close, "#.##")

//------------------------------------------------------------------------------
// Structure text
//------------------------------------------------------------------------------
structureTxt =
     close > emaFast and close < top ? "BULLISH ZONE" :
     close > emaTrend ? "MIDDLE ZONE" :
     close > bottom ? "BELOW TREND" :
     "BELOW SUPPORT"

trendTxt =
     trendBull ? "BULLISH" :
     close > emaTrend ? "RECOVERING" :
     "BEARISH"

strengthTxt =
     allGreen ? "STRONG" :
     (gateDIR or gateHTF or gateADX or gateATR) ? "MODERATE" :
     "WEAK"

//------------------------------------------------------------------------------
// Tide flow zones
//------------------------------------------------------------------------------
bandHigh = math.max(top, emaFast)
bandLow  = math.min(top, emaFast)
bandSize = math.max(bandHigh - bandLow, syminfo.mintick)
bandPos  = (close - bandLow) / bandSize

tideRising = top > top[1] and emaFast > emaFast[1]

greenAlphaNow  = tideRising ? f_clampAlpha(tideGreenAlpha - riseBoostAlphaStep) : tideGreenAlpha
yellowAlphaNow = tideRising ? f_clampAlpha(tideYellowAlpha - riseBoostAlphaStep) : tideYellowAlpha

tideColor =
     close < emaTrend ? na :
     close >= top ? color.new(tideGreenColor, greenAlphaNow) :
     close > emaFast ?
         (bandPos >= upperGreenZonePct
             ? color.new(tideGreenColor, greenAlphaNow)
             : color.new(tideYellowColor, yellowAlphaNow)) :
     color.new(tideYellowColor, yellowAlphaNow)

lowerBandColor = close < emaTrend ? color.new(tideRedColor, tideRedAlpha) : na

//------------------------------------------------------------------------------
// Recovery logic
//------------------------------------------------------------------------------
redPhaseNow = close < emaTrend ? 1 : 0
recentRedBars = math.sum(redPhaseNow, recoveryLookbackBars)
hadRecentRedPhase = recentRedBars >= recoveryMinRedBars

barsSinceTrendCross = ta.barssince(ta.crossover(close, emaTrend))
crossedAboveTrendRecently = not na(barsSinceTrendCross) and barsSinceTrendCross <= recoveryRecentCrossBars

recoveryBaseOk = hadRecentRedPhase and close > emaTrend and (not recoveryRequireRecentCross or crossedAboveTrendRecently)

recoveryYellow = recoveryBaseOk and close > emaTrend
recoveryBlue   = recoveryBaseOk and close > emaFast
recoveryGreen  = recoveryBaseOk and close > top

strongRecoveryShape = recoveryGreen and tideRising and allGreen

recoveryStage =
     recoveryGreen ? 3 :
     recoveryBlue ? 2 :
     recoveryYellow ? 1 : 0

recoveryBgColor =
     recoveryStage == 3 ? color.new(colTop, recoveryGreenAlpha) :
     recoveryStage == 2 ? color.new(colFast, recoveryBlueAlpha) :
     recoveryStage == 1 ? color.new(colTrend, recoveryYellowAlpha) :
     na

recoveryStageTxt =
     recoveryStage == 3 ? "GREEN" :
     recoveryStage == 2 ? "BLUE" :
     recoveryStage == 1 ? "YELLOW" :
     "-"

//------------------------------------------------------------------------------
// Setups
//------------------------------------------------------------------------------
breakoutTrig = close > top[1]
pullbackTrig = low <= emaFast and close > emaFast
reclaimTrig  = ta.crossover(close, emaFast)

longGatesOk = gateDIR and gateHTF and gateADX and gateATR and rsiOkL and engineOk and assetQualityGateOk

longSignalRaw =
     longGatesOk and
     (breakoutTrig or pullbackTrig or reclaimTrig)

var int lastSignalBar = na
inCooldown = cooldownBars > 0 and not na(lastSignalBar) and (bar_index - lastSignalBar) <= cooldownBars

longSignal = barOkForSignals and longSignalRaw and not inCooldown

if longSignal
    lastSignalBar := bar_index

signalTxt =
     strongRecoveryShape ? "GREEN + SHAPE" :
     recoveryStage == 3 ? "RECOVERY GREEN" :
     recoveryStage == 2 ? "RECOVERY BLUE" :
     recoveryStage == 1 ? "RECOVERY YELLOW" :
     breakoutTrig ? "BREAKOUT" :
     pullbackTrig ? "PULLBACK" :
     reclaimTrig ? "RECLAIM" :
     "-"

bullishShift = barOkForSignals and ta.crossover(close, top) and allGreen
bullishState = allGreen and close > emaFast and close > emaTrend

//------------------------------------------------------------------------------
// Risk line
//------------------------------------------------------------------------------
var bool inLong = false
var float atrTrail = na

if longSignal
    inLong := true

atrStopRaw = close - atrVal * atrStopMult

if not inLong
    atrTrail := na
else
    atrTrail := na(atrTrail[1]) ? atrStopRaw : math.max(atrTrail[1], atrStopRaw)

exitLine =
     exitMode == "ATR Trail" ? atrTrail :
     exitMode == "Bottom" ? bottom :
     math.max(atrTrail, bottom)

var int exitBelowCount = 0
exitBelowCount := (inLong and not na(exitLine) and close < exitLine) ? nz(exitBelowCount[1]) + 1 : 0
exitNow = barOkForSignals and inLong and exitBelowCount >= exitConfirmBars

if exitNow
    inLong := false

belowTrendAlert  = barOkForSignals and ta.crossunder(close, emaTrend)
belowBottomAlert = barOkForSignals and ta.crossunder(close, bottom)

//------------------------------------------------------------------------------
// Dashboard text
//------------------------------------------------------------------------------
actionTxt =
     exitNow ? "EXIT / MANAGE RISK" :
     longSignal ? "LONG SETUP" :
     assetQualityWarning ? assetQualityTxt :
     strongRecoveryShape ? "STRONG RECOVERY" :
     recoveryStage == 3 ? "RECOVERY GREEN" :
     recoveryStage == 2 ? "RECOVERY BLUE" :
     recoveryStage == 1 ? "RECOVERY YELLOW" :
     bullishState ? "LONG BIAS" :
     close < emaTrend ? "RISK-OFF / NO LONGS" :
     "WAIT"

why =
     exitNow ? "Price confirmed below the active risk line." :
     assetQualityWarning ? assetQualityWhy :
     strongRecoveryShape ? "Above green curve, tide rising, and DIR/HTF/ADX/ATR are green." :
     recoveryStage == 3 ? "Price is above the green curve after a recent bearish phase." :
     recoveryStage == 2 ? "Price is above the blue curve after a recent bearish phase." :
     recoveryStage == 1 ? "Price is above the yellow curve after a recent bearish phase." :
     longSignal ? "Main long-side conditions aligned." :
     bullishState ? "Trend and gates aligned." :
     not bullDirection ? "Trend direction is not aligned." :
     not volatilityOk ? "ATR is below the selected threshold." :
     not trendQualityOk ? "ADX is below the selected threshold." :
     not rsiOkL ? "RSI is extended." :
     not engineOk ? "EMA50 slope filter is weak." :
     "Waiting for a cleaner trigger."

gatesL =
     "DIR " + f_gateWord(gateDIR) + " | " +
     "HTF " + f_gateWord(gateHTF) + " | " +
     "ADX " + f_gateWord(gateADX) + " | " +
     "ATR " + f_gateWord(gateATR)

//------------------------------------------------------------------------------
// Plots
//------------------------------------------------------------------------------
pTrend  = plot(showTrend ? emaTrend : na, "Trend EMA", color=colTrend, linewidth=4)
pFast   = plot(showFast ? emaFast : na, "EMA50", color=colFast, linewidth=3)
pTop    = plot(showTop ? top : na, "Resistance Top", color=colTop, linewidth=2)
pBottom = plot(showBot ? bottom : na, "Support Bottom", color=colBot, linewidth=2)

fill(pTop, pFast, showTideFill ? tideColor : na, title="Tide Flow: Top to EMA50")
fill(pFast, pBottom, showBottomFill ? lowerBandColor : na, title="Bearish Zone: EMA50 to Bottom")

bgcolor(showBgState and bullishState ? color.new(bullStateBg, bgAlpha) : na)
bgcolor(showRecoveryBg ? recoveryBgColor : na)

//------------------------------------------------------------------------------
// Table
//------------------------------------------------------------------------------
cPanel  = color.rgb(18, 18, 23)
cHead   = color.rgb(28, 28, 36)
cGrid   = color.rgb(55, 55, 70)
cLabel  = color.rgb(210, 210, 220)
cWhite  = color.white
cMuted  = color.rgb(170, 170, 180)

cBullBg = color.rgb(22, 163, 74)
cBearBg = color.rgb(220, 38, 38)
cWaitBg = color.rgb(9, 111, 14)
cFlatBg = color.rgb(90, 90, 100)

cBullSoft = color.new(color.rgb(22, 163, 74), 82)
cBearSoft = color.new(color.rgb(220, 38, 38), 82)

actionBg =
     exitNow ? cBearBg :
     longSignal ? cBullBg :
     assetQualityWarning ? assetQualityCol :
     strongRecoveryShape ? color.rgb(22, 163, 74) :
     recoveryStage == 3 ? color.rgb(22, 163, 74) :
     recoveryStage == 2 ? color.rgb(37, 99, 235) :
     recoveryStage == 1 ? color.rgb(202, 138, 4) :
     bullishState ? cWaitBg :
     cFlatBg

actionTc = cWhite

dirTxt = gateDIR ? "STRONG" : "WEAK"
htfTxt = gateHTF ? "STRONG" : "WEAK"
adxStrengthTxt = "ADX " + (gateADX ? "STRONG" : "WEAK") + " | " + strengthTxt
atrTxt = gateATR ? "STRONG" : "WEAK"

dirBg = gateDIR ? cBullSoft : cBearSoft
htfBg = gateHTF ? cBullSoft : cBearSoft
adxStrengthBg = gateADX ? cBullSoft : cBearSoft
atrBg = gateATR ? cBullSoft : cBearSoft
trendBg = trendBull ? cBullSoft : cBearSoft

dirTc = gateDIR ? color.lime : color.red
htfTc = gateHTF ? color.lime : color.red
adxStrengthTc = gateADX ? color.lime : color.red
atrTc = gateATR ? color.lime : color.red
trendTc = trendBull ? color.lime : color.red

qualityBg = color.new(assetQualityCol, 82)
qualityTc = color.white
structureBg = cPanel
qualityWhyBg = assetQualityOk ? cPanel : color.new(color.rgb(220, 38, 38), 85)

var table t = na
var string lastTablePos = ""

if showTable and (na(t) or lastTablePos != tablePos)
    if not na(t)
        table.delete(t)
    t := table.new(
         f_posTable(tablePos),
         2, 10,
         frame_width=1,
         frame_color=cGrid,
         border_width=1,
         border_color=cGrid)
    lastTablePos := tablePos

if not showTable and not na(t)
    table.delete(t)
    t := na
    lastTablePos := ""

cell(_c, _r, _txt, _bg, _tc) =>
    table.cell(t, _c, _r, _txt, bgcolor=_bg, text_color=_tc, text_size=size.normal)

if showTable and not na(t)
    cell(0, 0, "ACTION", actionBg, cWhite)
    cell(1, 0, actionTxt, actionBg, actionTc)

    cell(0, 1, "DIRECTION", cHead, cLabel)
    cell(1, 1, dirTxt, dirBg, dirTc)

    cell(0, 2, "HTF TREND", cHead, cLabel)
    cell(1, 2, htfTxt, htfBg, htfTc)

    cell(0, 3, "TREND", cHead, cLabel)
    cell(1, 3, trendTxt, trendBg, trendTc)

    cell(0, 4, "ADX / STRENGTH", cHead, cLabel)
    cell(1, 4, adxStrengthTxt, adxStrengthBg, cWhite)

    cell(0, 5, "ATR", cHead, cLabel)
    cell(1, 5, atrTxt, atrBg, atrTc)

    cell(0, 6, "STRUCTURE", cHead, cLabel)
    cell(1, 6, structureTxt, structureBg, cWhite)

    cell(0, 7, "ASSET QUALITY", cHead, cLabel)
    cell(1, 7, assetQualityTxt, qualityBg, qualityTc)

    cell(0, 8, "QUALITY DATA", cHead, cLabel)
    cell(1, 8, assetQualityDetails, cPanel, cWhite)

    cell(0, 9, "QUALITY WHY", cHead, cLabel)
    cell(1, 9, assetQualityWhy, qualityWhyBg, cMuted)

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------
alertcondition(allGreen, title="IND001 Gates All Green", message="IND001: all main long-side gates are green on {{ticker}} ({{interval}}).")
alertcondition(bullishShift, title="IND001 Bullish Shift Above Top Curve", message="IND001: price crossed above the top structure curve with main gates aligned on {{ticker}} ({{interval}}).")
alertcondition(longSignal, title="IND001 Long Setup", message="IND001: long-side setup on {{ticker}} ({{interval}}). Review chart context and risk before acting.")

alertcondition(recoveryStage == 1, title="IND001 Recovery Yellow", message="IND001: recovery stage yellow on {{ticker}} ({{interval}}).")
alertcondition(recoveryStage == 2, title="IND001 Recovery Blue", message="IND001: recovery stage blue on {{ticker}} ({{interval}}).")
alertcondition(recoveryStage == 3, title="IND001 Recovery Green", message="IND001: recovery stage green on {{ticker}} ({{interval}}).")
alertcondition(strongRecoveryShape, title="IND001 Strong Recovery Marker", message="IND001: strong recovery marker on {{ticker}} ({{interval}}).")

alertcondition(assetQualityWarning, title="IND001 Asset Quality Warning", message="IND001: asset quality is below the selected guard level on {{ticker}} ({{interval}}).")
alertcondition(useAssetProtection and not qualityAsSoftWarning and not assetQualityOk, title="IND001 Asset Quality Block", message="IND001: long-side setups are blocked because asset quality is below the selected guard level on {{ticker}} ({{interval}}).")

alertcondition(belowTrendAlert, title="IND001 Below Trend Curve", message="IND001: price crossed below the trend curve on {{ticker}} ({{interval}}).")
alertcondition(belowBottomAlert, title="IND001 Below Support Curve", message="IND001: price crossed below the support curve on {{ticker}} ({{interval}}).")
alertcondition(exitNow, title="IND001 Exit / Manage Risk", message="IND001: price confirmed below the active risk line on {{ticker}} ({{interval}}).")
````

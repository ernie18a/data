# IND002 - Multi-Timeframe RSI Percentile Map

- url: https://www.tradingview.com/script/9wnid0S6-IND002-Multi-Timeframe-RSI-Percentile-Map/
- type: indicator
- pine_id: PUB;601cd19e4f624371a4383bbe832f085e
- version: 1.0

## Description

[b]IND002 - Multi-Timeframe RSI Percentile Map[/b] shows whether RSI momentum is historically low, historically high, improving, neutral or weakening across several timeframes.

It helps traders use multi-timeframe RSI context before deciding whether a setup is worth considering.

[b]========================================================================
✨  Follow my profile to stay updated on future indicators and improvements
========================================================================[/b]

[b]==================================================
WARNING
==================================================[/b]

This indicator does not predict the future and does not provide guaranteed entries.

A low percentile can show that momentum is historically depressed, but price can still continue lower. A high percentile can show that momentum is historically stretched, but price can still continue higher.

[quote]Use this as momentum context together with trend, structure, support/resistance, volume, divergence, and risk management.[/quote]

[b]==================================================
(1) OVERVIEW AND PURPOSE
==================================================[/b]

IND002 combines RSI readings from four selected timeframes into one smoother combined RSI line. By default, it uses Monthly, Weekly, Daily, and 4H RSI, but the user can change the timeframes and weights in the settings.

The main purpose is not only to show RSI. The main purpose is to show where the current combined RSI stands compared with its own recent history.

This is done with percentile ranking.

[b]What percentile means[/b]

Percentile shows whether the current combined RSI is low, normal, or high compared with its own historical values.

[list]
[*][b]Percentile 5[/b] - combined RSI is very low compared with recent history.
[*][b]Percentile 20[/b] - combined RSI is in a lower historical area.
[*][b]Percentile 50[/b] - combined RSI is near its normal middle range.
[*][b]Percentile 80[/b] - combined RSI is in a higher historical area.
[*][b]Percentile 95[/b] - combined RSI is very stretched compared with recent history.
[/list]

A low percentile is not automatically a buy signal. It means RSI is low compared with its own history. A high percentile is not automatically a sell signal. It means RSI is stretched compared with its own history.

The useful reading comes from combining:

[list]
[*]percentile level
[*]RSI direction
[*]multi-timeframe alignment
[*]price structure
[/list]

[b]Color meaning[/b]

[list]
[*]🟩 [b]Green[/b] - combined RSI is in a lower percentile area and slope is turning up.
[*]🟨 [b]Yellow[/b] - momentum is neutral, mixed, or not clear enough.
[*]🟥 [b]Red[/b] - combined RSI is in a higher percentile area and slope is turning down.
[/list]

[quote]The main idea: do not read RSI only as 30 / 50 / 70. Read where RSI is compared with its own history and whether it is starting to turn.[/quote]

[b]==================================================
(2) HOW TO USE IT PROPERLY
==================================================[/b]

The indicator should be used differently depending on the trading style. It is not one fixed entry rule for every trader.

[b]Simple use[/b]

[list=1]
[*]Check the combined RSI color first.
[*]🟩 Green = momentum is recovering from a historically lower area.
[*]🟨 Yellow = momentum is neutral or unclear; wait for better context.
[*]🟥 Red = momentum is weakening from a historically higher area.
[*]Confirm the reading with price structure, support/resistance, trend, volume, or divergence.
[*]Use alerts only as monitoring tools, not as trade instructions.
[/list]

[b]Long-term investing use[/b]

For long-term investing, give more attention to Monthly, Weekly, and Daily context.

A more useful long-term reading usually appears when:

[list]
[*]combined RSI is in a lower percentile area
[*]the line turns 🟩 green
[*]higher timeframes stop weakening
[*]price is near important support or a long-term value area
[*]market structure starts stabilizing
[/list]

This does not confirm the exact bottom. It only means multi-timeframe momentum is becoming more constructive compared with its own history.

[b]Swing trading use[/b]

For swing trading, a low percentile alone is usually not enough. The trader usually wants evidence that momentum is recovering and that price structure confirms the idea.

A more useful swing reading usually appears when:

[list]
[*]combined RSI was low or below normal
[*]the line turns 🟩 green
[*]RSI starts moving back toward the middle area
[*]Daily and 4H RSI begin to agree
[*]price confirms with support reaction, reclaim, breakout, or trend continuation
[/list]

For swing trading, Daily and 4H can be weighted more, while Weekly remains useful for context.

[b]Advanced use[/b]

Enable the four timeframe RSI curves when you want to compare alignment, divergence, or conflict between timeframes.

[list]
[*]If price makes a lower low but combined RSI or higher-timeframe RSI improves, this can support a bullish divergence reading.
[*]If price makes a higher high but RSI weakens, this can support a bearish divergence reading.
[*]If Monthly, Weekly, Daily, and 4H RSI improve together, momentum confirmation is broader.
[*]If only 4H improves while Weekly and Monthly remain weak, the move may only be short-term.
[/list]

[b]Setup markers and alerts[/b]

[list]
[*]🟩 [b]Long-Side Setup[/b] - lower percentile area, RSI slope turning up, and optional ADX filter confirmed.
[*]🟥 [b]Risk-Off Setup[/b] - upper percentile area, RSI slope turning down, and optional ADX filter confirmed.
[/list]

Alerts describe chart conditions only. They are not trade instructions.

[quote]Best use: let IND002 show multi-timeframe momentum context, then confirm with your own price-action method before making a decision.[/quote]

[b]==================================================
(3) SETTINGS, SUMMARY AND DISCLAIMER
==================================================[/b]

[b]Important settings[/b]

[list]
[*][b]RSI period[/b] - lower is faster, higher is smoother.
[*][b]Timeframes A-D[/b] - choose the four RSI timeframes.
[*][b]Weights[/b] - higher weight gives that timeframe more influence.
[*][b]Percentile lookback days[/b] - higher is broader context, lower adapts faster.
[*][b]Lower threshold[/b] - default 20, defines lower-percentile recovery area.
[*][b]Upper threshold[/b] - default 80, defines upper-percentile risk-off area.
[*][b]ADX threshold[/b] - filters setup markers by trend strength.
[*][b]Show four timeframe RSI curves[/b] - helps compare alignment and divergence.
[/list]

This script may receive future refinements if useful improvements are added to the model, settings, or explanation.

If you want to stay updated on future script releases or improvements to this indicator, you can check my profile for new public publications and updates.

[b]Summary[/b]

IND002 combines RSI from four timeframes and ranks the result against its own historical range.

It helps users understand whether momentum is 🟩 improving, 🟨 neutral, or 🟥 weakening.

The script is most useful as multi-timeframe momentum context, not as a standalone trading system.

[b]Disclaimer[/b]

This script is a public open-source indicator for educational and informational use.

It is not financial advice, investment advice, or a recommendation to buy or sell any asset.

The script identifies momentum and percentile conditions only. It does not guarantee profitable trades, signal accuracy, or future performance.

Users should always apply their own analysis, position sizing, and risk management before making any trading decision.

## Source Code

````pine
//@version=6
indicator("IND002 - Multi-Timeframe RSI Percentile Map", shorttitle="IND002 RSI Percentile", overlay=false, format=format.price, precision=2)

//------------------------------------------------------------------------------
// IND002 - Multi-Timeframe RSI Percentile Map
//
// This indicator combines RSI readings from four timeframes, compares the result
// with its own historical percentile range, and highlights constructive or
// extended momentum conditions. Markers and alerts describe chart conditions only;
// they are not trade instructions and do not guarantee future results.
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Inputs with tooltips
//------------------------------------------------------------------------------
IND002_GroupMain = "IND002 Main Settings"
IND002_GroupSetup = "IND002 Setup Conditions"

IND002_Len = input.int(
     14,
     "RSI period",
     minval=1,
     group=IND002_GroupMain,
     tooltip="RSI calculation length used on each selected timeframe. Common values are 14 to 21. Lower values react faster; higher values are smoother.")

IND002_TfA = input.timeframe(
     "M",
     "Timeframe A",
     group=IND002_GroupMain,
     inline="A",
     tooltip="Highest timeframe used in the combined RSI calculation. Default is Monthly for broad context.")

IND002_WA = input.float(
     15,
     "Weight",
     minval=0,
     maxval=100,
     group=IND002_GroupMain,
     inline="A",
     tooltip="Weight of Timeframe A in the combined RSI. Higher values give this timeframe more influence. Range: 0 to 100.")

IND002_TfB = input.timeframe(
     "W",
     "Timeframe B",
     group=IND002_GroupMain,
     inline="B",
     tooltip="Second timeframe used in the combined RSI calculation. Default is Weekly.")

IND002_WB = input.float(
     25,
     "Weight",
     minval=0,
     maxval=100,
     group=IND002_GroupMain,
     inline="B",
     tooltip="Weight of Timeframe B in the combined RSI. Higher values give this timeframe more influence. Range: 0 to 100.")

IND002_TfC = input.timeframe(
     "D",
     "Timeframe C",
     group=IND002_GroupMain,
     inline="C",
     tooltip="Third timeframe used in the combined RSI calculation. Default is Daily.")

IND002_WC = input.float(
     35,
     "Weight",
     minval=0,
     maxval=100,
     group=IND002_GroupMain,
     inline="C",
     tooltip="Weight of Timeframe C in the combined RSI. Higher values give this timeframe more influence. Range: 0 to 100.")

IND002_TfD = input.timeframe(
     "240",
     "Timeframe D",
     group=IND002_GroupMain,
     inline="D",
     tooltip="Lowest timeframe used in the combined RSI calculation. Default is 4H / 240 minutes.")

IND002_WD = input.float(
     25,
     "Weight",
     minval=0,
     maxval=100,
     group=IND002_GroupMain,
     inline="D",
     tooltip="Weight of Timeframe D in the combined RSI. Higher values give this timeframe more influence. Range: 0 to 100.")

IND002_LookbackDays = input.int(
     365,
     "Percentile lookback days",
     minval=30,
     group=IND002_GroupMain,
     tooltip="Calendar-day estimate used to build the percentile lookback. Higher values create broader historical context; lower values adapt faster. Minimum: 30 days.")

IND002_GreenBase = input.float(
     20,
     "Lower percentile threshold <=",
     minval=0,
     maxval=100,
     group=IND002_GroupMain,
     tooltip="Lower percentile threshold. Near 20 means the combined RSI is low compared with its own recent history. Constructive conditions also require the RSI slope to turn up.")

IND002_RedBase = input.float(
     80,
     "Upper percentile threshold >=",
     minval=0,
     maxval=100,
     group=IND002_GroupMain,
     tooltip="Upper percentile threshold. Near 80 means the combined RSI is high compared with its own recent history. Risk-off conditions also require the RSI slope to turn down.")

IND002_AdxBgLevel = input.float(
     30.0,
     "ADX background threshold",
     minval=1,
     maxval=100,
     step=0.5,
     group=IND002_GroupMain,
     tooltip="ADX level used for background highlighting and optional setup filtering. Higher values require stronger trend activity. Common range: 20 to 35.")

IND002_LineWidth = input.int(
     4,
     "Main line width",
     minval=2,
     maxval=6,
     group=IND002_GroupMain,
     tooltip="Visual thickness of the combined RSI line. This does not change calculations.")

IND002_ShowTfRsi = input.bool(
     false,
     "Show four timeframe RSI curves",
     group=IND002_GroupMain,
     tooltip="When enabled, the individual RSI curves for the four selected timeframes are shown behind the combined RSI.")

IND002_ShowSetups = input.bool(
     true,
     "Show setup markers",
     group=IND002_GroupSetup,
     tooltip="Shows small markers when the indicator detects a long-side or risk-off momentum condition. These markers are chart conditions, not trade instructions.")

IND002_RequireAdxForSetup = input.bool(
     true,
     "Require ADX for setup markers",
     group=IND002_GroupSetup,
     tooltip="When enabled, setup markers require ADX to be above the selected ADX threshold. This helps avoid weaker or flat environments.")

IND002_UseBarClose = input.bool(
     true,
     "Confirm setup on bar close",
     group=IND002_GroupSetup,
     tooltip="When enabled, setup markers and alerts only trigger after the bar closes. This reduces live-bar flicker.")

//------------------------------------------------------------------------------
// Internal settings
//------------------------------------------------------------------------------
IND002_Src = close
IND002_SmoothLenCombined = 8
IND002_SmoothCombinedExtra = 3
IND002_SlopeLen = 3
IND002_ClusterWindow = 150
IND002_ClusterIters = 5
IND002_CompressionLen = 10
IND002_ClusterInfluence = 1.0
IND002_AdxLen = 14

IND002_PaintBg = true
IND002_ShowPercentile = false
IND002_ShowRegimeFeature = false
IND002_ShowAdx = false

//------------------------------------------------------------------------------
// Weight normalization
//------------------------------------------------------------------------------
IND002_SumW = IND002_WA + IND002_WB + IND002_WC + IND002_WD
IND002_SumWSafe = IND002_SumW == 0 ? 1.0 : IND002_SumW

//------------------------------------------------------------------------------
// Reference timeframe and lookback conversion
//------------------------------------------------------------------------------
IND002_TfSecA = timeframe.in_seconds(IND002_TfA)
IND002_TfSecB = timeframe.in_seconds(IND002_TfB)
IND002_TfSecC = timeframe.in_seconds(IND002_TfC)
IND002_TfSecD = timeframe.in_seconds(IND002_TfD)

IND002_RefTF =
     IND002_TfSecA <= IND002_TfSecB and IND002_TfSecA <= IND002_TfSecC and IND002_TfSecA <= IND002_TfSecD ? IND002_TfA :
     IND002_TfSecB <= IND002_TfSecC and IND002_TfSecB <= IND002_TfSecD ? IND002_TfB :
     IND002_TfSecC <= IND002_TfSecD ? IND002_TfC : IND002_TfD

IND002_RefSec = timeframe.in_seconds(IND002_RefTF)
IND002_LbRef = math.max(20, math.min(5000, int(IND002_LookbackDays * 86400 / IND002_RefSec)))

//------------------------------------------------------------------------------
// RSI formula
//------------------------------------------------------------------------------
IND002_RsiFormula(_src, _len) =>
    _change = ta.change(_src)
    _up = ta.rma(math.max(_change, 0), _len)
    _down = ta.rma(-math.min(_change, 0), _len)
    _down == 0 ? 100 : _up == 0 ? 0 : 100 - (100 / (1 + _up / _down))

//------------------------------------------------------------------------------
// Multi-timeframe RSI readings
//------------------------------------------------------------------------------
IND002_RsiA = request.security(syminfo.tickerid, IND002_TfA, IND002_RsiFormula(IND002_Src, IND002_Len), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
IND002_RsiB = request.security(syminfo.tickerid, IND002_TfB, IND002_RsiFormula(IND002_Src, IND002_Len), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
IND002_RsiC = request.security(syminfo.tickerid, IND002_TfC, IND002_RsiFormula(IND002_Src, IND002_Len), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
IND002_RsiD = request.security(syminfo.tickerid, IND002_TfD, IND002_RsiFormula(IND002_Src, IND002_Len), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

//------------------------------------------------------------------------------
// Combined RSI and percentile rank
//------------------------------------------------------------------------------
IND002_ComboRaw = (IND002_RsiA * IND002_WA + IND002_RsiB * IND002_WB + IND002_RsiC * IND002_WC + IND002_RsiD * IND002_WD) / IND002_SumWSafe
IND002_RsiCombined = ta.rma(ta.rma(IND002_ComboRaw, IND002_SmoothLenCombined), IND002_SmoothCombinedExtra)

IND002_PercentileRaw = bar_index >= IND002_LbRef ? ta.percentrank(IND002_RsiCombined, IND002_LbRef) : na
IND002_Percentile = ta.rma(IND002_PercentileRaw, 3)

//------------------------------------------------------------------------------
// Momentum and regime features
//------------------------------------------------------------------------------
IND002_PercentileSlope = bar_index >= IND002_SlopeLen ? IND002_Percentile - IND002_Percentile[IND002_SlopeLen] : na
IND002_RsiSlope = bar_index >= IND002_SlopeLen ? IND002_RsiCombined - IND002_RsiCombined[IND002_SlopeLen] : na

IND002_Dist50 = na(IND002_RsiCombined) ? na : IND002_RsiCombined - 50.0
IND002_Compression = ta.stdev(IND002_RsiCombined, IND002_CompressionLen)
IND002_PercentileVol = ta.stdev(IND002_Percentile, IND002_CompressionLen)

IND002_RegimeFeature =
     na(IND002_Percentile) or na(IND002_PercentileSlope) ? na :
     IND002_Percentile * 0.55 +
     math.abs(IND002_PercentileSlope) * 2.4 +
     nz(IND002_Compression) * 1.6 +
     math.abs(nz(IND002_Dist50)) * 0.35 +
     nz(IND002_PercentileVol) * 0.8

var IND002_FeatureBuf = array.new_float()

if not na(IND002_RegimeFeature)
    array.push(IND002_FeatureBuf, IND002_RegimeFeature)
    if array.size(IND002_FeatureBuf) > IND002_ClusterWindow
        array.shift(IND002_FeatureBuf)

//------------------------------------------------------------------------------
// Simple three-cluster regime grouping
//------------------------------------------------------------------------------
IND002_Kmeans3(_arr, _iters) =>
    int _n = array.size(_arr)
    float _c1 = na
    float _c2 = na
    float _c3 = na
    if _n > 5
        float _mn = array.get(_arr, 0)
        float _mx = array.get(_arr, 0)
        for _i = 0 to _n - 1
            _v = array.get(_arr, _i)
            _mn := math.min(_mn, _v)
            _mx := math.max(_mx, _v)
        _c1 := _mn
        _c2 := (_mn + _mx) * 0.5
        _c3 := _mx
        for _iter = 0 to _iters - 1
            float _s1 = 0.0
            float _s2 = 0.0
            float _s3 = 0.0
            int _n1 = 0
            int _n2 = 0
            int _n3 = 0
            for _i = 0 to _n - 1
                _v = array.get(_arr, _i)
                _d1 = math.abs(_v - _c1)
                _d2 = math.abs(_v - _c2)
                _d3 = math.abs(_v - _c3)
                if _d1 <= _d2 and _d1 <= _d3
                    _s1 += _v
                    _n1 += 1
                else if _d2 <= _d1 and _d2 <= _d3
                    _s2 += _v
                    _n2 += 1
                else
                    _s3 += _v
                    _n3 += 1
            _c1 := _n1 > 0 ? _s1 / _n1 : _c1
            _c2 := _n2 > 0 ? _s2 / _n2 : _c2
            _c3 := _n3 > 0 ? _s3 / _n3 : _c3
    [_c1, _c2, _c3]

[IND002_C1Raw, IND002_C2Raw, IND002_C3Raw] = IND002_Kmeans3(IND002_FeatureBuf, IND002_ClusterIters)

IND002_CLow = na(IND002_C1Raw) or na(IND002_C2Raw) or na(IND002_C3Raw) ? na : math.min(IND002_C1Raw, math.min(IND002_C2Raw, IND002_C3Raw))
IND002_CHigh = na(IND002_C1Raw) or na(IND002_C2Raw) or na(IND002_C3Raw) ? na : math.max(IND002_C1Raw, math.max(IND002_C2Raw, IND002_C3Raw))
IND002_CMid = na(IND002_C1Raw) or na(IND002_C2Raw) or na(IND002_C3Raw) ? na : IND002_C1Raw + IND002_C2Raw + IND002_C3Raw - IND002_CLow - IND002_CHigh

IND002_DLow = na(IND002_CLow) ? na : math.abs(IND002_RegimeFeature - IND002_CLow)
IND002_DMid = na(IND002_CMid) ? na : math.abs(IND002_RegimeFeature - IND002_CMid)
IND002_DHigh = na(IND002_CHigh) ? na : math.abs(IND002_RegimeFeature - IND002_CHigh)

IND002_ClusterId =
     array.size(IND002_FeatureBuf) < 20 or na(IND002_DLow) or na(IND002_DMid) or na(IND002_DHigh) ? 1 :
     IND002_DLow <= IND002_DMid and IND002_DLow <= IND002_DHigh ? 0 :
     IND002_DMid <= IND002_DLow and IND002_DMid <= IND002_DHigh ? 1 : 2

//------------------------------------------------------------------------------
// Adaptive percentile thresholds
//------------------------------------------------------------------------------
IND002_GreenAdaptive =
     IND002_ClusterId == 0 ? IND002_GreenBase - 4 * IND002_ClusterInfluence :
     IND002_ClusterId == 1 ? IND002_GreenBase :
     IND002_GreenBase + 5 * IND002_ClusterInfluence

IND002_RedAdaptive =
     IND002_ClusterId == 0 ? IND002_RedBase + 4 * IND002_ClusterInfluence :
     IND002_ClusterId == 1 ? IND002_RedBase :
     IND002_RedBase - 5 * IND002_ClusterInfluence

IND002_GreenLevel = math.max(1, math.min(40, IND002_GreenAdaptive))
IND002_RedLevel = math.max(60, math.min(99, IND002_RedAdaptive))

//------------------------------------------------------------------------------
// State logic
//------------------------------------------------------------------------------
IND002_LowerPercentile = not na(IND002_Percentile) and IND002_Percentile <= IND002_GreenLevel
IND002_UpperPercentile = not na(IND002_Percentile) and IND002_Percentile >= IND002_RedLevel

IND002_SlopeUp = not na(IND002_RsiSlope) and IND002_RsiSlope > 0
IND002_SlopeDown = not na(IND002_RsiSlope) and IND002_RsiSlope < 0

IND002_ConstructiveState = IND002_LowerPercentile and IND002_SlopeUp
IND002_RiskOffState = IND002_UpperPercentile and IND002_SlopeDown
IND002_NeutralState = not IND002_ConstructiveState and not IND002_RiskOffState

IND002_CurveColor = IND002_ConstructiveState ? color.lime : IND002_RiskOffState ? color.red : color.yellow
IND002_BgSignalColor = IND002_ConstructiveState ? color.new(color.lime, 92) : IND002_RiskOffState ? color.new(color.red, 92) : na

//------------------------------------------------------------------------------
// ADX filter
//------------------------------------------------------------------------------
IND002_Adx(_len) =>
    [_pdi, _mdi, _adx] = ta.dmi(_len, _len)
    _adx

IND002_AdxVal = request.security(syminfo.tickerid, IND002_RefTF, IND002_Adx(IND002_AdxLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
IND002_AdxStrong = IND002_AdxVal > IND002_AdxBgLevel
IND002_SetupFilterOk = not IND002_RequireAdxForSetup or IND002_AdxStrong
IND002_BarOk = not IND002_UseBarClose or barstate.isconfirmed

//------------------------------------------------------------------------------
// Setup conditions
//------------------------------------------------------------------------------
IND002_LongSetupRaw = IND002_ConstructiveState and IND002_SetupFilterOk
IND002_RiskOffSetupRaw = IND002_RiskOffState and IND002_SetupFilterOk

IND002_LongSetup = IND002_BarOk and IND002_LongSetupRaw and not IND002_LongSetupRaw[1]
IND002_RiskOffSetup = IND002_BarOk and IND002_RiskOffSetupRaw and not IND002_RiskOffSetupRaw[1]

//------------------------------------------------------------------------------
// Plots
//------------------------------------------------------------------------------
IND002_TfColor = color.new(color.silver, 45)

plot(IND002_RsiCombined, "IND002 Combined RSI", color=IND002_CurveColor, linewidth=IND002_LineWidth)
plot(IND002_ShowTfRsi ? IND002_RsiD : na, "IND002 RSI 4H", color=IND002_TfColor, linewidth=1)
plot(IND002_ShowTfRsi ? IND002_RsiC : na, "IND002 RSI Daily", color=IND002_TfColor, linewidth=2)
plot(IND002_ShowTfRsi ? IND002_RsiB : na, "IND002 RSI Weekly", color=IND002_TfColor, linewidth=3)
plot(IND002_ShowTfRsi ? IND002_RsiA : na, "IND002 RSI Monthly", color=IND002_TfColor, linewidth=4)

plot(IND002_ShowPercentile ? IND002_Percentile : na, "IND002 Percentile Rank", color=color.new(color.white, 0), linewidth=1)
plot(IND002_ShowRegimeFeature ? IND002_RegimeFeature : na, "IND002 Regime Feature", color=color.new(color.aqua, 0), linewidth=1)
plot(IND002_ShowAdx ? IND002_AdxVal : na, "IND002 ADX", color=color.new(color.orange, 0), linewidth=1)

hline(30, "IND002 RSI 30", color=color.new(color.green, 40), linestyle=hline.style_dotted, linewidth=5)
hline(50, "IND002 RSI 50", color=color.new(#ffffff, 40), linestyle=hline.style_dotted, linewidth=5)
hline(70, "IND002 RSI 70", color=color.new(color.red, 40), linestyle=hline.style_dotted, linewidth=5)

plotshape(IND002_ShowSetups and IND002_LongSetup ? IND002_RsiCombined : na,
     title="IND002 Long-Side Setup",
     style=shape.triangleup,
     location=location.absolute,
     color=color.lime,
     size=size.tiny,
     text="L")

plotshape(IND002_ShowSetups and IND002_RiskOffSetup ? IND002_RsiCombined : na,
     title="IND002 Risk-Off Setup",
     style=shape.triangledown,
     location=location.absolute,
     color=color.red,
     size=size.tiny,
     text="R")

bgcolor(IND002_PaintBg and IND002_AdxStrong and (IND002_ConstructiveState or IND002_RiskOffState) ? IND002_BgSignalColor : na)

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------
alertcondition(IND002_LongSetup, title="IND002 Long-Side Setup", message="IND002 long-side momentum condition detected on {{ticker}} ({{interval}}). This is a chart condition, not a trade instruction.")
alertcondition(IND002_RiskOffSetup, title="IND002 Risk-Off Setup", message="IND002 risk-off momentum condition detected on {{ticker}} ({{interval}}). This is a chart condition, not a trade instruction.")
alertcondition(IND002_ConstructiveState and IND002_AdxStrong, title="IND002 Constructive State", message="IND002 constructive RSI percentile state with ADX confirmation on {{ticker}} ({{interval}}).")
alertcondition(IND002_RiskOffState and IND002_AdxStrong, title="IND002 Risk-Off State", message="IND002 risk-off RSI percentile state with ADX confirmation on {{ticker}} ({{interval}}).")
````

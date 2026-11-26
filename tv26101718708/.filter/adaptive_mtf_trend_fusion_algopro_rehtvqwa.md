# Adaptive MTF Trend Fusion [AlgoPro]

- url: https://www.tradingview.com/script/rehtVqWA-Adaptive-MTF-Trend-Fusion-AlgoPro/
- type: indicator
- pine_id: PUB;4b9af31f643641a88937af6198069629
- version: 1.0

## Description

Adaptive MTF Trend Fusion [AlgoPro] is an advanced multi-timeframe trend modeling system. It is engineered to combine multi-timeframe moving average structure, multi-timeframe VWAP-based price weighting, volatility-adjusted trend bands, and adaptive visual confirmation into one clean decision framework.

Rather than relying on a single moving average, fixed trendline, or static channel, this tool creates a dynamic fusion midline by blending multiple timeframe calculations together. The result is a smoother, more context-aware trend anchor that adapts to market structure, volatility, and directional pressure across different chart environments.

🔵 [b]SYSTEM ARCHITECTURE & CORE TREND ENGINE[/b]

[b]Multi-Timeframe Fusion Engine[/b]

Adaptive Timeframe Mapping: The system can automatically select lower, middle, or higher timeframe combinations based on the chart you are viewing. This allows the indicator to build a broader trend model without requiring manual timeframe adjustments every time you switch charts.

Auto Higher / Auto Middle / Auto Lower Modes: Traders can choose whether the fusion engine should lean into higher-timeframe confirmation, balanced multi-timeframe structure, or lower-timeframe responsiveness. Manual mode is also available for full custom timeframe selection.

Confirmed Higher-Timeframe Logic: Higher-timeframe values are handled with confirmation logic to help prevent future-leak behavior and keep the model grounded in completed higher-timeframe data.

[b]Advanced Moving Average Fusion Core[/b]

Selectable Smoothing Models: The moving-average engine supports multiple smoothing types, including SMA, EMA, WMA, HMA, RMA, VWMA, DEMA, TEMA, THMA, and JMA. This allows the trader to tune the fusion line from slower institutional-style trend tracking to faster adaptive response.

Weighted Calculation Control: The moving average component can be enabled, disabled, or weighted independently. This lets traders decide how much influence the selected moving average structure should have in the final fusion midline.

Multi-Timeframe MA Blending: The script calculates the selected moving average across three chosen timeframes, then blends those values into a single adaptive trend anchor.

[b]VWAP-Based Price Alignment Engine[/b]

Rolling VWAP Support: The VWAP engine can use a rolling VWAP calculation over a user-defined length, helping the system identify price positioning relative to recent volume-weighted value.

Daily VWAP Support: A daily-reset VWAP mode is also included for traders who prefer a session/day-based value anchor.

Weighted VWAP Influence: The VWAP component can be enabled, disabled, or weighted separately from the moving-average component. This allows the final fusion line to lean more toward volume-weighted value, moving-average structure, or a balanced blend of both.

[b]Volatility-Scaled Trend Confirmation Bands[/b]

ATR-Based Volatility Framework: The fusion midline is surrounded by volatility-adjusted upper and lower confirmation thresholds. These bands expand and contract with market volatility, helping reduce false flips during noisy conditions.

Trend Confirmation Candles: A trend state does not flip immediately from a single cross. The system requires a user-defined number of confirming candles above or below the volatility structure before locking into a bullish or bearish state.

Directional State Machine: Once a bullish or bearish condition is confirmed, the indicator maintains that structural state until the opposite side earns confirmation. This helps traders avoid reacting to every minor pullback or midline test.

🔵 [b]VISUAL TREND STRUCTURE & MARKET INTERPRETATION[/b]

[b]Adaptive Fusion Band[/b]

Fusion Band Around the Midline: A separate internal band is plotted around the fusion midline to help define the core trend zone. This acts as a visual center-of-gravity area for the current market structure.

Dynamic Color Behavior: The fusion band shifts color based on price position and trend state. When price is interacting with the band, the color can remain more neutral. As price pushes away from the band, the visual structure becomes stronger in the active trend color.

Clean Trend Zone Visualization: The band is designed to make trend structure easy to read without overwhelming the chart. It gives traders a clear view of whether price is compressing near the midline or expanding away from it.

[b]Volatility Gradient Fill[/b]

Trend Expansion Visualization: When price is moving in the direction of the confirmed trend, the script creates a gradient fill between price and the active volatility buffer.

Volume-Based Brightness: The gradient fill responds to volume pressure. Stronger directional volume can make the fill appear more active, while weaker volume pressure fades the visual intensity.

Directional Market Context: This helps traders quickly identify whether a move has supportive pressure behind it or whether price is simply drifting away from the midline without strong participation.

[b]Trend Flip Signals[/b]

Confirmed Bullish Flip Signals: When the system confirms a bullish transition, a clean signal marker is printed near the lower volatility structure.

Confirmed Bearish Flip Signals: When the system confirms a bearish transition, a clean signal marker is printed near the upper volatility structure.

Glow-Based Signal Styling: The signal markers are designed with layered glow circles to make important trend shifts visible without cluttering the chart.

[b]Midline Retest Signals[/b]

Bullish Retest Logic: During a bullish trend, if price pulls below the fusion midline and then crosses back above it, the script can print a bullish retest marker.

Bearish Retest Logic: During a bearish trend, if price pushes above the fusion midline and then crosses back below it, the script can print a bearish retest marker.

Continuation Setup Assistance: These retest markers are designed to help identify possible trend continuation opportunities after a pullback into the fusion structure.

🔵 [b]SYSTEMATIC TRADING INTERPRETATION[/b]

Trend Following Bias: Use the confirmed market state as the primary directional bias. Bullish states favor long-side planning, while bearish states favor short-side planning.

Midline Pullback Continuations: During a confirmed trend, watch for price to pull back toward or through the fusion midline. A retest signal can help identify when price is attempting to reclaim trend direction.

Volatility Buffer Confirmation: Strong trend flips occur only when price closes beyond the volatility structure for the required number of confirming candles. This helps filter weak crosses and reduce premature entries.

Trend Strength Expansion: A rising trend strength value means price is moving farther away from the midline. This can indicate strong momentum, but it can also warn that price is becoming extended depending on market context.

Volume Pressure Confirmation: Use the volume pressure reading to determine whether the current move is being supported by directional participation. Strong trend state plus matching volume pressure can suggest better continuation quality.

Fusion Band Compression: When price is hovering near the fusion band, the market may be compressing, ranging, or preparing for a larger directional move. When price expands away from the band, the system helps visualize directional strength.

🔵 [b]INTERFACE CONFIGURATION & PARAMETERS[/b]

Multi-Timeframe Controls: Choose Auto Higher, Auto Middle, Auto Lower, or Manual mode depending on whether you want broader confirmation, balanced structure, lower-timeframe responsiveness, or full custom control.

Moving Average Settings: Select from multiple moving average types and adjust the moving average length to control how responsive or smooth the fusion engine becomes.

VWAP Settings: Choose between Rolling VWAP and Daily VWAP, then adjust the rolling length when using the rolling mode.

Volatility Settings: Tune the ATR length, volatility multiplier, smoothing, and confirmation candle count to adjust how strict or responsive the trend engine should be.

Fusion Band Settings: Control the internal band visibility, width, and multiplier to fit your preferred chart style.

Visual Settings: Customize bull, bear, and neutral colors, signal sizes, dashboard position, dashboard size, and chart display options.

Adaptive MTF Trend Fusion [AlgoPro] transforms a standard chart into a multi-timeframe trend modeling dashboard. By combining moving average structure, VWAP value, volatility confirmation, trend strength, and volume pressure into one unified system, it gives traders a cleaner way to read market direction, trend health, and pullback continuation opportunities.

## Source Code

````pine
//@version=6
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © AlgoPro
indicator("Adaptive MTF Trend Fusion [AlgoPro]", overlay=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
group1 = "ＭＵＬＴＩ ＴＩＭＥＦＲＡＭＥ ＳＥＴＵＰ"
group2 = "ＭＯＶＩＮＧ ＡＶＥＲＡＧＥ ＳＥＴＵＰ"
group3 = "ＶＷＡＰ ＳＥＴＵＰ"
group4 = "ＴＲＥＮＤ ＢＡＮＤ ＳＥＴＵＰ"
group5 = "ＶＯＬＡＴＩＬＩＴＹ ＳＥＴＵＰ"
group6 = "ＶＩＳＵＡＬ ＳＥＴＵＰ"

tfMode = input.string("Auto Higher", "Timeframe Mode", options=["Auto Higher", "Auto Middle", "Auto Lower", "Manual"], tooltip="Auto Higher uses chart timeframe + next 2 common higher timeframes. Example: 3m = 3m / 5m / 15m. On higher intraday charts, 4H = 4H / 6H / 12H.", group = group1)
manualTf1 = input.timeframe("5", "Timeframe 1⃣", group = group1)
manualTf2 = input.timeframe("15", "Timeframe 2⃣", group = group1)
manualTf3 = input.timeframe("60", "Timeframe 3⃣", group = group1)
useHeikinAshiCalc = input.bool(true, "Calculate On Heikin Ashi", group = group1)
useConfirmedHTF = true

enableMaFusion = input.bool(true, "Use MA In Calculation", group = group2)
maType = input.string("THMA", "Moving Average Type", options=["SMA", "EMA", "WMA", "HMA", "RMA", "VWMA", "DEMA", "TEMA", "THMA", "JMA"], group = group2)
maLen = input.int(100, "Moving Average Length", minval=1, group = group2)
maWeight = input.float(1.0, "MA Calc Weight", minval=0.0, maxval=10.0, step=0.1, tooltip = "Weight controls how much each calculation contributes to the fusion line. If both MA and VWAP weight are equal, then both components are balanced the same.", group = group2)
jmaPhase = 0
jmaPower = 0.45

enableVwapFusion = input.bool(true, "Use VWAP In Calculation", group = group3)
vwapMode = input.string("Rolling VWAP", "VWAP Mode", options=["Rolling VWAP", "Daily VWAP"], group = group3)
vwapLength = input.int(100, "Rolling VWAP Length", minval=1, group = group3)
vwapWeight = input.float(1.0, "VWAP Calc Weight", minval=0.0, maxval=10.0, step=0.1, tooltip = "Weight controls how much each calculation contributes to the fusion line. If both MA and VWAP weight are equal, then both components are balanced the same.", group = group3)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Main outer volatility buffer
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
colorConfirmBars = input.int(3, "Trend Confirmation Candles", minval=1, tooltip="Bullish flip requires this many consecutive green candles closing above the upper main volatility buffer. Bearish flip requires this many consecutive red candles closing below the lower main volatility buffer.", group = group5)

lineSmoothLen = input.int(100, "Smoothing", minval=1, group = group5)
volatilityAtrLen = input.int(100, "Volatility Length", minval=1, group = group5)
volatilityMultiplier = input.float(2.5, "Volatility Multiplier", minval=0.0, step=0.05, group = group5)
showVolatilityBuffer = true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Fusion ribbon separate buffer
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showFusionRibbon = input.bool(true, "Show Fusion Band", group = group4)
fusionRibbonAtrLen = input.int(50, "Fusion Band Length", minval=1, group = group4)
fusionRibbonAtrMultiplier = 0.25
fusionRibbonSmoothLen = 500
fusionRibbonWidthMult = input.float(1.0, "Fusion Band Multiplier", minval=0.01, maxval=5.0, step=0.01, group = group4)

fusionRibbonGradientMode = "Strong 2-Zone"
fusionRibbonEdgeTransparency = 70
fusionRibbonCenterTransparency = 70
fusionRibbonLineTransparency = 70
fusionRibbonMidLineTransparency = 70
fusionRibbonColorSensitivity = 0.5
fusionRibbonColorRangeMult = 3

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Outer gradient fill
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showGradientFill = input.bool(true, "Show Trend Gradient Fill", group = group6)
outerFillBaseTransparency = 40
outerFillLowVolumeExtraFade = 55
outerFillFadeTransparency = 99

useVolumeFillGradient = true
volumePressureLen = 50
volumeColorSensitivity = 0.75
volumeNeutralThreshold = 0.05

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Signal circles
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showGradientSignals = input.bool(true, "Show Trend Flip Signals", group = group6)
mainSignalSize = input.int(4, "Bull/Bear Signal Size", minval=1, maxval=8, group = group6)

showFusionRetestSignals = input.bool(true, "Show Midline Retest Signals", group = group6)
retestSignalSize = input.int(2, "Retest Signal Size", minval=1, maxval=6, group = group6)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Dashboard
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showDashboard = input.bool(true, "Show Dashboard", group = group6)
dashboardPosition = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = group6)
dashboardSize = input.string("Small", "Dashboard Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group = group6)
trendStrengthRangeMult = 2.0
bullStrongColor = input.color(color.rgb(0, 255, 42), "Bull Color", group = group6)
bearStrongColor = input.color(color.rgb(255, 0, 0), "Bear Color", group = group6)
neutralGrayColor = input.color(color.rgb(255, 251, 0), "Neutral Color", group = group6)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Heikin Ashi Source
// Main calculations can use Heikin Ashi.
// Volume pressure always uses normal candles.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
calcTicker = useHeikinAshiCalc ? ticker.heikinashi(syminfo.tickerid) : syminfo.tickerid
[calcOpen, calcHigh, calcLow, calcClose, calcAtr, calcRibbonAtr] = request.security(calcTicker, timeframe.period, [open, high, low, close, ta.atr(volatilityAtrLen), ta.atr(fusionRibbonAtrLen)], barmerge.gaps_off, barmerge.lookahead_off)
[realOpen, realClose] = request.security(syminfo.tickerid, timeframe.period, [open, close], barmerge.gaps_off, barmerge.lookahead_off)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// JMA Function
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
jma(series float source, simple int period, simple int phase = 0, simple float power = 0.45) =>
    simple float _PHASE      = phase < -100 ? 0.5 : phase > 100 ? 2.5 : (phase * 0.01) + 1.5
    simple float _LEN0       = period < 1.0000000002 ? 1e-10 : (period - 1.0) / 2.0
    simple float _LOG_PARAM  = math.max(math.log(math.sqrt(_LEN0)) / math.log(2.0) + 2.0, 0.0)
    simple float _SQRT_PARAM = math.sqrt(_LEN0) * _LOG_PARAM
    simple float _LEN_ADJ    = _LEN0 * 0.9
    simple float _LEN_DIV    = _LEN_ADJ / (_LEN_ADJ + 2.0)
    simple float _SQRT_DIV   = _SQRT_PARAM / (_SQRT_PARAM + 1.0)
    simple float _P_EXP      = math.max(_LOG_PARAM - 2.0, 0.5)

    var float  paramA      = na
    var float  paramB      = na
    var float  lastC0      = na
    var float  lastC8      = na
    var float  lastA8      = na
    var float  lastJma     = na
    var int    bars        = 0

    var float  cycleDelta  = 0.0
    var int    volIndex    = 0
    var int    volCount    = 0
    var array<float> volWindow  = array.new_float(10, 0.0)

    var int    distIndex   = 0
    var int    distCount   = 0
    var array<float> distWindow = array.new_float(128, 0.0)
    var array<float> sorted     = array.new_float(0)

    float current_jma = na

    if not na(source)
        bars += 1

        if bars == 1
            paramA  := source
            paramB  := source
            lastC0  := source
            lastC8  := 0.0
            lastA8  := 0.0
            lastJma := source
            current_jma := source
        else
            float diffA    = source - paramA
            float diffB    = source - paramB
            float absA     = math.abs(diffA)
            float absB     = math.abs(diffB)
            float absValue = absA > absB ? absA : absB
            float dLocal   = absValue + 1e-10

            float oldVol = array.get(volWindow, volIndex)
            cycleDelta  += dLocal - oldVol
            array.set(volWindow, volIndex, dLocal)
            volIndex += 1
            if volIndex >= 10
                volIndex := 0
            if volCount < 10
                volCount += 1
            float highD = volCount > 0 ? cycleDelta / (volCount < 10 ? volCount : 10) : dLocal

            array.set(distWindow, distIndex, highD)
            distIndex += 1
            if distIndex >= 128
                distIndex := 0
            if distCount < 128
                distCount += 1

            float dRef = highD
            if distCount >= 16
                int count = distCount
                array.clear(sorted)
                for i = 0 to count - 1
                    int idx = distIndex - 1 - i
                    if idx < 0
                        idx += 128
                    array.push(sorted, array.get(distWindow, idx))
                array.sort(sorted)

                int idxLo = 0
                int idxHi = 0
                if count >= 128
                    idxLo := 32
                    idxHi := 96
                else
                    int slice = int(math.max(5.0, math.round(count * 0.5)))
                    int drop  = (count - slice) / 2
                    idxLo := drop
                    idxHi := drop + slice - 1

                if idxLo < 0
                    idxLo := 0
                if idxHi >= count
                    idxHi := count - 1

                float sum = 0.0
                for i = idxLo to idxHi
                    sum += array.get(sorted, i)
                dRef := sum / float(idxHi - idxLo + 1)

            if dRef <= 0.0
                dRef := dLocal

            float ratio = absValue / dRef
            if ratio < 0.0
                ratio := 0.0
            float d = math.pow(ratio, _P_EXP)
            d := math.min(math.max(d, 1.0), _LOG_PARAM)

            float adapt = math.pow(_SQRT_DIV, math.sqrt(d))
            if source > paramA
                paramA := source
            else
                paramA := source - (source - paramA) * adapt
            if source < paramB
                paramB := source
            else
                paramB := source - (source - paramB) * adapt

            float prevJma = na(lastJma) ? source : lastJma
            float alpha  = math.pow(_LEN_DIV, d)
            float alpha2 = alpha * alpha
            float c0 = (1.0 - alpha) * source + alpha * lastC0
            float c8 = (source - c0) * (1.0 - _LEN_DIV) + _LEN_DIV * lastC8
            float a8 = (_PHASE * c8 + c0 - prevJma) * (alpha * -2.0 + alpha2 + 1.0) + alpha2 * lastA8
            float jmaVal = prevJma + a8

            lastC0  := c0
            lastC8  := c8
            lastA8  := a8
            lastJma := jmaVal
            current_jma := jmaVal

    current_jma

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Common Timeframe Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_nextCommonTf(_tf) =>
    sec = timeframe.in_seconds(_tf)
    sec <= 1 ? "5S" : sec <= 5 ? "15S" : sec <= 15 ? "30S" : sec <= 30 ? "1" : sec <= 60 ? "3" : sec <= 180 ? "5" : sec <= 300 ? "15" : sec <= 900 ? "30" : sec <= 1800 ? "60" : sec <= 3600 ? "120" : sec <= 7200 ? "180" : sec <= 10800 ? "240" : sec <= 14400 ? "360" : sec <= 21600 ? "720" : sec <= 43200 ? "D" : sec <= 86400 ? "W" : sec <= 604800 ? "M" : sec <= 2592000 ? "3M" : sec <= 7776000 ? "6M" : "12M"

f_prevCommonTf(_tf) =>
    sec = timeframe.in_seconds(_tf)
    sec <= 5 ? "1S" : sec <= 15 ? "5S" : sec <= 30 ? "15S" : sec <= 60 ? "30S" : sec <= 180 ? "1" : sec <= 300 ? "3" : sec <= 900 ? "5" : sec <= 1800 ? "15" : sec <= 3600 ? "30" : sec <= 7200 ? "60" : sec <= 10800 ? "120" : sec <= 14400 ? "180" : sec <= 21600 ? "240" : sec <= 43200 ? "360" : sec <= 86400 ? "720" : sec <= 604800 ? "D" : sec <= 2592000 ? "W" : sec <= 7776000 ? "M" : sec <= 15552000 ? "3M" : sec <= 31536000 ? "6M" : "12M"

f_nextCommonTf2(_tf) =>
    f_nextCommonTf(f_nextCommonTf(_tf))

f_prevCommonTf2(_tf) =>
    f_prevCommonTf(f_prevCommonTf(_tf))

autoHigherTf1 = timeframe.period
autoHigherTf2 = f_nextCommonTf(timeframe.period)
autoHigherTf3 = f_nextCommonTf2(timeframe.period)

autoMiddleTf1 = f_prevCommonTf(timeframe.period)
autoMiddleTf2 = timeframe.period
autoMiddleTf3 = f_nextCommonTf(timeframe.period)

autoLowerTf1 = timeframe.period
autoLowerTf2 = f_prevCommonTf(timeframe.period)
autoLowerTf3 = f_prevCommonTf2(timeframe.period)

tf1 = tfMode == "Manual" ? manualTf1 : tfMode == "Auto Higher" ? autoHigherTf1 : tfMode == "Auto Middle" ? autoMiddleTf1 : autoLowerTf1
tf2 = tfMode == "Manual" ? manualTf2 : tfMode == "Auto Higher" ? autoHigherTf2 : tfMode == "Auto Middle" ? autoMiddleTf2 : autoLowerTf2
tf3 = tfMode == "Manual" ? manualTf3 : tfMode == "Auto Higher" ? autoHigherTf3 : tfMode == "Auto Middle" ? autoMiddleTf3 : autoLowerTf3

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Helper Functions
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_useConfirmed(_tf) =>
    useConfirmedHTF and _tf != timeframe.period and timeframe.in_seconds(_tf) > timeframe.in_seconds(timeframe.period)

f_thma(_src, _len) =>
    halfLen = math.max(1, int(math.round(_len / 2.0)))
    thirdLen = math.max(1, int(math.round(_len / 3.0)))
    ta.wma(ta.wma(_src, thirdLen) * 3.0 - ta.wma(_src, halfLen) - ta.wma(_src, _len), _len)

f_getMa(_src, _len, _type) =>
    ema1 = ta.ema(_src, _len)
    ema2 = ta.ema(ema1, _len)
    ema3 = ta.ema(ema2, _len)
    _type == "SMA" ? ta.sma(_src, _len) :
     _type == "EMA" ? ema1 :
     _type == "WMA" ? ta.wma(_src, _len) :
     _type == "HMA" ? ta.hma(_src, _len) :
     _type == "RMA" ? ta.rma(_src, _len) :
     _type == "VWMA" ? ta.vwma(_src, _len) :
     _type == "DEMA" ? 2.0 * ema1 - ema2 :
     _type == "TEMA" ? 3.0 * ema1 - 3.0 * ema2 + ema3 :
     _type == "THMA" ? f_thma(_src, _len) :
     _type == "JMA" ? jma(_src, _len, jmaPhase, jmaPower) :
     ema1

f_maValue(_confirmed) =>
    maValue = f_getMa(close, maLen, maType)
    _confirmed ? maValue[1] : maValue

f_dailyVwap(_src) =>
    newDay = ta.change(time("D")) != 0
    var float dailyPv = na
    var float dailyVol = na
    if newDay or na(dailyPv) or na(dailyVol)
        dailyPv := _src * volume
        dailyVol := volume
    else
        dailyPv += _src * volume
        dailyVol += volume
    dailyVol != 0.0 ? dailyPv / dailyVol : na

f_vwapValue(_confirmed) =>
    rvSrc = hlc3
    sumSrcVol = math.sum(rvSrc * volume, vwapLength)
    sumVol = math.sum(volume, vwapLength)
    rollingVwap = sumVol != 0.0 ? sumSrcVol / sumVol : na
    dailyVwap = f_dailyVwap(rvSrc)
    selectedVwap = vwapMode == "Rolling VWAP" ? rollingVwap : dailyVwap
    _confirmed ? selectedVwap[1] : selectedVwap

f_mtfMa(_tf) =>
    useConfirmed = f_useConfirmed(_tf)
    request.security(calcTicker, _tf, f_maValue(useConfirmed), barmerge.gaps_off, barmerge.lookahead_off)

f_mtfVwap(_tf) =>
    useConfirmed = f_useConfirmed(_tf)
    request.security(calcTicker, _tf, f_vwapValue(useConfirmed), barmerge.gaps_off, barmerge.lookahead_off)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Fusion Components
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
tf1Ma = f_mtfMa(tf1)
tf2Ma = f_mtfMa(tf2)
tf3Ma = f_mtfMa(tf3)

tf1Vwap = f_mtfVwap(tf1)
tf2Vwap = f_mtfVwap(tf2)
tf3Vwap = f_mtfVwap(tf3)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Fusion Line
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
maW = enableMaFusion ? maWeight : 0.0
vwapW = enableVwapFusion ? vwapWeight : 0.0

totalWeight = maW + maW + maW + vwapW + vwapW + vwapW
safeTotalWeight = totalWeight == 0.0 ? 1.0 : totalWeight

fusionRaw = totalWeight == 0.0 ? calcClose : (tf1Ma * maW + tf2Ma * maW + tf3Ma * maW + tf1Vwap * vwapW + tf2Vwap * vwapW + tf3Vwap * vwapW) / safeTotalWeight
fusionLine = lineSmoothLen > 1 ? ta.ema(fusionRaw, lineSmoothLen) : fusionRaw

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Main Outer Volatility Buffer
// Uses same smoothing input as fusion line.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
atrVolatility = lineSmoothLen > 1 ? ta.ema(calcAtr, lineSmoothLen) : calcAtr
volatilityBuffer = atrVolatility * volatilityMultiplier

upperBuffer = fusionLine + volatilityBuffer
lowerBuffer = fusionLine - volatilityBuffer

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Separate Fusion Ribbon Buffer
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
fusionRibbonAtrRaw = calcRibbonAtr * fusionRibbonAtrMultiplier
fusionRibbonAtrSmoothed = fusionRibbonSmoothLen > 1 ? ta.ema(fusionRibbonAtrRaw, fusionRibbonSmoothLen) : fusionRibbonAtrRaw
fusionRibbonHalfWidth = fusionRibbonAtrSmoothed * fusionRibbonWidthMult

fusionRibbonUpper = fusionLine + fusionRibbonHalfWidth
fusionRibbonLower = fusionLine - fusionRibbonHalfWidth

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Trend State
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
haGreenCandle = calcClose > calcOpen
haRedCandle = calcClose < calcOpen

bullConfirmCandle = calcClose > upperBuffer and haGreenCandle
bearConfirmCandle = calcClose < lowerBuffer and haRedCandle

var int bullConfirmCount = 0
var int bearConfirmCount = 0

bullConfirmCount := bullConfirmCandle ? nz(bullConfirmCount[1]) + 1 : 0
bearConfirmCount := bearConfirmCandle ? nz(bearConfirmCount[1]) + 1 : 0

bullConfirmed = bullConfirmCount >= colorConfirmBars
bearConfirmed = bearConfirmCount >= colorConfirmBars

var int trendState = 0
trendState := bullConfirmed ? 1 : bearConfirmed ? -1 : nz(trendState[1], 0)

trendBull = trendState == 1
trendBear = trendState == -1
trendNeutral = trendState == 0

bullFlip = trendBull and trendState[1] != 1
bearFlip = trendBear and trendState[1] != -1
trendChanged = bullFlip or bearFlip

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Fusion Midline Retest Signals
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
crossUnderFusion = ta.crossunder(calcClose, fusionLine)
crossOverFusion = ta.crossover(calcClose, fusionLine)

var bool bullMidlinePulledBack = false
var bool bearMidlinePulledBack = false

if trendChanged
    bullMidlinePulledBack := false
    bearMidlinePulledBack := false

if trendBull and crossUnderFusion
    bullMidlinePulledBack := true

if trendBear and crossOverFusion
    bearMidlinePulledBack := true

bullMidlineRetestSignal = showFusionRetestSignals and trendBull and bullMidlinePulledBack and crossOverFusion
bearMidlineRetestSignal = showFusionRetestSignals and trendBear and bearMidlinePulledBack and crossUnderFusion

if bullMidlineRetestSignal
    bullMidlinePulledBack := false

if bearMidlineRetestSignal
    bearMidlinePulledBack := false

trendColor = trendBull ? bullStrongColor : trendBear ? bearStrongColor : neutralGrayColor
activeBufferColor = trendBull ? color.new(bullStrongColor, 35) : trendBear ? color.new(bearStrongColor, 35) : color.new(neutralGrayColor, 55)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Dynamic Fusion Ribbon Color
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
candleTouchesFusionRibbon = calcLow <= fusionRibbonUpper and calcHigh >= fusionRibbonLower
candleFullyAboveFusionRibbon = calcLow > fusionRibbonUpper
candleFullyBelowFusionRibbon = calcHigh < fusionRibbonLower

distanceFromFusionRibbon = candleTouchesFusionRibbon ? 0.0 : candleFullyAboveFusionRibbon ? calcLow - fusionRibbonUpper : candleFullyBelowFusionRibbon ? fusionRibbonLower - calcHigh : 0.0

ribbonFadeRangeBase = atrVolatility > 0.0 ? atrVolatility : volatilityBuffer
ribbonFadeRange = math.max(ribbonFadeRangeBase * fusionRibbonColorRangeMult, syminfo.mintick)

ribbonDistanceRaw = math.min(distanceFromFusionRibbon / ribbonFadeRange, 1.0)
ribbonColorStrength = math.min(math.pow(ribbonDistanceRaw, 1.0 / fusionRibbonColorSensitivity), 1.0)

dynamicFusionRibbonColor = candleTouchesFusionRibbon ? neutralGrayColor : color.from_gradient(ribbonColorStrength, 0.0, 1.0, neutralGrayColor, trendColor)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Volume-Based Fill Brightness
// Uses NORMAL candles, even when Heikin Ashi calculation is enabled.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bullVolume = realClose > realOpen ? volume : 0.0
bearVolume = realClose < realOpen ? volume : 0.0

bullVolSum = math.sum(bullVolume, volumePressureLen)
bearVolSum = math.sum(bearVolume, volumePressureLen)
totalVolSum = bullVolSum + bearVolSum

volumePressure = totalVolSum > 0.0 ? (bullVolSum - bearVolSum) / totalVolSum : 0.0

bullVolumeStrengthRaw = math.max(volumePressure - volumeNeutralThreshold, 0.0) / math.max(1.0 - volumeNeutralThreshold, 0.0001)
bearVolumeStrengthRaw = math.max(-volumePressure - volumeNeutralThreshold, 0.0) / math.max(1.0 - volumeNeutralThreshold, 0.0001)

bullVolumeStrength = math.min(math.pow(bullVolumeStrengthRaw, 1.0 / volumeColorSensitivity), 1.0)
bearVolumeStrength = math.min(math.pow(bearVolumeStrengthRaw, 1.0 / volumeColorSensitivity), 1.0)

volumeBrightnessStrength = trendBull ? bullVolumeStrength : trendBear ? bearVolumeStrength : 0.0
activeOuterFillColor = trendColor

volumeAdjustedBaseTransparencyRaw = useVolumeFillGradient ? outerFillBaseTransparency + (1.0 - volumeBrightnessStrength) * outerFillLowVolumeExtraFade : outerFillBaseTransparency
volumeAdjustedBaseTransparency = int(math.min(math.max(math.round(volumeAdjustedBaseTransparencyRaw), 0), 100))
volumeAdjustedFadeTransparency = int(math.min(math.max(outerFillFadeTransparency, 0), 100))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Active Outer Buffer
// Breaks on trend-change bars to prevent vertical connector lines.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
activeBuffer = trendBull ? lowerBuffer : trendBear ? upperBuffer : na
visibleActiveBuffer = showVolatilityBuffer and not trendChanged ? activeBuffer : na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Outer Gradient Fill
// Breaks on trend-change bars to prevent vertical fill walls.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
outerFillAllowed = not trendChanged and trendState == trendState[1]
outerFillOn = showGradientFill and outerFillAllowed and ((trendBull and calcClose > lowerBuffer) or (trendBear and calcClose < upperBuffer))

pOuterBuffer = plot(outerFillOn ? activeBuffer : na, "Outer Gradient Buffer Anchor", color=na, display=display.none)
pOuterCandle = plot(outerFillOn ? calcClose : na, "Outer Gradient Candle Anchor", color=na, display=display.none)

outerTopValue = trendBull ? calcClose : activeBuffer
outerBottomValue = trendBull ? activeBuffer : calcClose
outerTopColor = trendBull ? color.new(activeOuterFillColor, volumeAdjustedFadeTransparency) : color.new(activeOuterFillColor, volumeAdjustedBaseTransparency)
outerBottomColor = trendBull ? color.new(activeOuterFillColor, volumeAdjustedBaseTransparency) : color.new(activeOuterFillColor, volumeAdjustedFadeTransparency)

fill(pOuterBuffer, pOuterCandle, outerTopValue, outerBottomValue, outerTopColor, outerBottomColor, title="Outer Vertical Gradient With Volume Brightness")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Fusion Ribbon — Strong Dynamic Vertical Gradient
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pFusionUpper = plot(showFusionRibbon ? fusionRibbonUpper : na, "Fusion Ribbon Upper", color=color.new(dynamicFusionRibbonColor, fusionRibbonLineTransparency), linewidth=1)
pFusionMid = plot(showFusionRibbon ? fusionLine : na, "Fusion Ribbon Mid", color=color.new(dynamicFusionRibbonColor, fusionRibbonMidLineTransparency), linewidth=1)
pFusionLower = plot(showFusionRibbon ? fusionRibbonLower : na, "Fusion Ribbon Lower", color=color.new(dynamicFusionRibbonColor, fusionRibbonLineTransparency), linewidth=1)

hardUpperBottomT = int(math.min(100, fusionRibbonEdgeTransparency + 20))
hardLowerTopT = int(math.min(100, fusionRibbonEdgeTransparency + 20))

upperTopColor = color.new(dynamicFusionRibbonColor, fusionRibbonEdgeTransparency)
upperBottomColor = fusionRibbonGradientMode == "Smooth Vertical" ? color.new(dynamicFusionRibbonColor, fusionRibbonCenterTransparency) : fusionRibbonGradientMode == "Strong 2-Zone" ? color.new(dynamicFusionRibbonColor, 100) : color.new(dynamicFusionRibbonColor, hardUpperBottomT)

lowerTopColor = fusionRibbonGradientMode == "Smooth Vertical" ? color.new(dynamicFusionRibbonColor, fusionRibbonCenterTransparency) : fusionRibbonGradientMode == "Strong 2-Zone" ? color.new(dynamicFusionRibbonColor, 100) : color.new(dynamicFusionRibbonColor, hardLowerTopT)
lowerBottomColor = color.new(dynamicFusionRibbonColor, fusionRibbonEdgeTransparency)

fill(pFusionUpper, pFusionLower, fusionRibbonUpper, fusionLine, upperTopColor, upperBottomColor, title="Fusion Ribbon Upper Dynamic Gradient")
fill(pFusionUpper, pFusionLower, fusionLine, fusionRibbonLower, lowerTopColor, lowerBottomColor, title="Fusion Ribbon Lower Dynamic Gradient")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Signal Circles
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
signalY = showGradientSignals and bullFlip ? lowerBuffer : showGradientSignals and bearFlip ? upperBuffer : na
signalColor = bullFlip ? bullStrongColor : bearFlip ? bearStrongColor : neutralGrayColor

retestSignalY = bullMidlineRetestSignal ? lowerBuffer : bearMidlineRetestSignal ? upperBuffer : na
retestSignalColor = bullMidlineRetestSignal ? bullStrongColor : bearMidlineRetestSignal ? bearStrongColor : neutralGrayColor

plot(visibleActiveBuffer, "Active ATR Volatility Buffer", color=activeBufferColor, linewidth=1, style=plot.style_linebr)

plot(signalY, "Signal Outer Glow", color=color.new(signalColor, 82), linewidth=mainSignalSize + 7, style=plot.style_circles)
plot(signalY, "Signal Mid Glow", color=color.new(signalColor, 45), linewidth=mainSignalSize + 3, style=plot.style_circles)
plot(signalY, "Signal Core", color=color.new(signalColor, 0), linewidth=mainSignalSize, style=plot.style_circles)

plot(retestSignalY, "Fusion Retest Outer Glow", color=color.new(retestSignalColor, 84), linewidth=retestSignalSize + 5, style=plot.style_circles)
plot(retestSignalY, "Fusion Retest Mid Glow", color=color.new(retestSignalColor, 50), linewidth=retestSignalSize + 2, style=plot.style_circles)
plot(retestSignalY, "Fusion Retest Core", color=color.new(retestSignalColor, 0), linewidth=retestSignalSize, style=plot.style_circles)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Dashboard
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
dashPos = dashboardPosition == "Top Right" ? position.top_right : dashboardPosition == "Top Left" ? position.top_left : dashboardPosition == "Bottom Right" ? position.bottom_right : position.bottom_left
dashTextSize = dashboardSize == "Tiny" ? size.tiny : dashboardSize == "Small" ? size.small : dashboardSize == "Large" ? size.large : dashboardSize == "Huge" ? size.huge : size.normal
var table dash = table.new(dashPos, 2, 11, border_width=1)

dashBg = color.new(#363a45, 79)
dashBull = color.new(bullStrongColor, 80)
dashBear = color.new(bearStrongColor, 80)
dashNeutral = color.new(color.gray, 80)

stateText = trendBull ? "Bullish" : trendBear ? "Bearish" : "Neutral"
calculationText = enableMaFusion and enableVwapFusion ? maType + " + " + vwapMode : enableMaFusion ? maType + " Only" : enableVwapFusion ? vwapMode + " Only" : "Price Only"
confirmText = trendBull ? str.tostring(bearConfirmCount) + " / " + str.tostring(colorConfirmBars) + " Red" : trendBear ? str.tostring(bullConfirmCount) + " / " + str.tostring(colorConfirmBars) + " Green" : "Waiting"
fusionMidlineText = str.tostring(fusionLine, format.mintick)

trendDistanceFromMidline = math.abs(calcClose - fusionLine)
trendStrengthRange = math.max(volatilityBuffer * trendStrengthRangeMult, syminfo.mintick)
trendStrengthRaw = trendDistanceFromMidline / trendStrengthRange * 100.0
trendStrengthClamped = math.min(trendStrengthRaw, 100.0)
trendStrengthText = str.tostring(trendStrengthClamped, "#") + "%"
trendStrengthBg = trendStrengthClamped >= 100.0 ? color.new(trendColor, 65) : trendStrengthClamped >= 50.0 ? color.new(trendColor, 78) : color.new(color.gray, 80)

bullVolPercent = totalVolSum > 0.0 ? bullVolSum / totalVolSum * 100.0 : 50.0
bearVolPercent = totalVolSum > 0.0 ? bearVolSum / totalVolSum * 100.0 : 50.0
volumePressureText = bullVolPercent >= bearVolPercent ? "Bull " + str.tostring(bullVolPercent, "#") + "%" : "Bear " + str.tostring(bearVolPercent, "#") + "%"
volumePressureBg = bullVolPercent >= bearVolPercent ? color.new(bullStrongColor, 70) : color.new(bearStrongColor, 70)

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "Market State", text_color=color.white, bgcolor=dashBg, text_size=dashTextSize)
    table.cell(dash, 1, 0, stateText, text_color=color.white, bgcolor=trendBull ? dashBull : trendBear ? dashBear : dashNeutral, text_size=dashTextSize)

    table.cell(dash, 0, 1, "TF Mode", text_color=color.white, bgcolor=dashBg, text_size=dashTextSize)
    table.cell(dash, 1, 1, tfMode, text_color=color.white, bgcolor=dashBg, text_size=dashTextSize)

    table.cell(dash, 0, 2, "Timeframes", text_color=color.white, bgcolor=dashBg, text_size=dashTextSize)
    table.cell(dash, 1, 2, tf1 + " / " + tf2 + " / " + tf3, text_color=color.white, bgcolor=dashBg, text_size=dashTextSize)

    table.cell(dash, 0, 3, "Calculation", text_color=color.white, bgcolor=dashBg, text_size=dashTextSize)
    table.cell(dash, 1, 3, calculationText, text_color=color.white, bgcolor=dashBg, text_size=dashTextSize)

    table.cell(dash, 0, 4, "MA Length", text_color=color.white, bgcolor=dashBg, text_size=dashTextSize)
    table.cell(dash, 1, 4, str.tostring(maLen), text_color=color.white, bgcolor=dashBg, text_size=dashTextSize)

    table.cell(dash, 0, 5, "VWAP Length", text_color=color.white, bgcolor=dashBg, text_size=dashTextSize)
    table.cell(dash, 1, 5, vwapMode == "Rolling VWAP" ? str.tostring(vwapLength) : "N/A", text_color=color.white, bgcolor=dashBg, text_size=dashTextSize)

    table.cell(dash, 0, 6, "Smoothing", text_color=color.white, bgcolor=dashBg, text_size=dashTextSize)
    table.cell(dash, 1, 6, str.tostring(lineSmoothLen), text_color=color.white, bgcolor=dashBg, text_size=dashTextSize)

    table.cell(dash, 0, 7, "Midline", text_color=color.white, bgcolor=dashBg, text_size=dashTextSize)
    table.cell(dash, 1, 7, fusionMidlineText, text_color=color.white, bgcolor=dashBg, text_size=dashTextSize)

    table.cell(dash, 0, 8, "Trend Strength", text_color=color.white, bgcolor=dashBg, text_size=dashTextSize)
    table.cell(dash, 1, 8, trendStrengthText, text_color=color.white, bgcolor=trendStrengthBg, text_size=dashTextSize)

    table.cell(dash, 0, 9, "Confirmed Candles", text_color=color.white, bgcolor=dashBg, text_size=dashTextSize)
    table.cell(dash, 1, 9, confirmText, text_color=color.white, bgcolor=dashBg, text_size=dashTextSize)

    table.cell(dash, 0, 10, "Volume Pressure", text_color=color.white, bgcolor=dashBg, text_size=dashTextSize)
    table.cell(dash, 1, 10, volumePressureText, text_color=color.white, bgcolor=volumePressureBg, text_size=dashTextSize)

if not showDashboard and barstate.islast
    table.clear(dash, 0, 0, 1, 10)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alerts
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(bullFlip, "Bullish Flip", "Consecutive green candles confirmed above the upper main volatility buffer.")
alertcondition(bearFlip, "Bearish Flip", "Consecutive red candles confirmed below the lower main volatility buffer.")
alertcondition(bullMidlineRetestSignal, "Bullish Midline Retest", "Bull trend pulled below the fusion midline and crossed back above. Circle plotted on lower volatility buffer.")
alertcondition(bearMidlineRetestSignal, "Bearish Midline Retest", "Bear trend pulled above the fusion midline and crossed back below. Circle plotted on upper volatility buffer.")
````

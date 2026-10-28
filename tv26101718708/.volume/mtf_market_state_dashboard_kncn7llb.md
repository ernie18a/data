# MTF Market State Dashboard

- url: https://www.tradingview.com/script/kncn7LLB-MTF-Market-State-Dashboard/
- type: indicator
- pine_id: PUB;d82d457f5aae4b6eb7c2a2c21fc0d64b
- version: 1.0

## Description

A multi-timeframe market context dashboard designed to classify market conditions using three independent analytical layers: Trend direction, Trend strength and Participation / Volume flow
Instead of relying on a single indicator or isolated signal, this script combines multiple forms of market information into a structured decision framework intended to help traders evaluate the quality and maturity of a market condition.
The goal of the dashboard is not to predict tops or bottoms, but to help identify:
•	aligned market conditions
•	conflicting conditions
•	strengthening trends
•	weakening trends
•	and low-conviction environments

[b]Core Idea Behind The Script[/b]
Many indicators work well in certain environments and poorly in others.
For example:
•	Trend indicators may continue showing bullish conditions during weakening momentum.
•	Momentum indicators may react aggressively inside consolidations.
•	Volume indicators may show temporary spikes without broader trend confirmation.
This script was built to reduce that fragmentation by separating market behavior into three independent layers:
1. Direction
Defines where the market is currently biased.
2. Strength
Measures whether the move has enough momentum to sustain itself.
3. Participation
Evaluates whether price movement is supported by broader volume-flow behavior.
The dashboard then combines these layers into a unified market-state classification system.
What The Dashboard Tracks

[b]1. Trend Structure Layer[/b]
The script evaluates directional bias using:
EMA 200
Used as the higher-level directional filter.
Typical interpretation:
•	Price above EMA 200 → bullish macro bias
•	Price below EMA 200 → bearish macro bias
EMA 50
Tracks intermediate trend behavior and shorter-term structural changes.
Supertrend
Used as a dynamic trend confirmation layer.
Unlike a static moving average, the Supertrend adapts to volatility and helps identify directional transitions more quickly.
Each trend component is displayed as:
•	BULL
•	BEAR
along with an “age” value showing how many bars have passed since the last state change.
This allows traders to distinguish between:
•	fresh transitions
•	mature trends
•	and potentially exhausted conditions

[b]2. Trend Strength Layer[/b]
ADX (via DMI)
ADX is used to measure trend strength, not trend direction.
Typical interpretation:
•	Low ADX → weak or ranging environment
•	Rising / high ADX → stronger directional environment
This distinction matters because bullish conditions inside weak trend environments often behave differently from bullish conditions inside expanding trends.
The script uses ADX as a confirmation filter inside the Market State logic.

[b]3. Participation & Volume-Flow Layer[/b]
This layer attempts to measure whether directional movement is being supported by participation and flow behavior.
CMF (Chaikin Money Flow)
CMF estimates buying versus selling pressure by evaluating closing location relative to range and volume.
General interpretation:
•	Positive CMF → accumulation pressure
•	Negative CMF → distribution pressure
CDV (Cumulative Delta Volume Proxy)
Pine Script does not provide true bid/ask delta data.
This script therefore uses a candle-based directional volume proxy to estimate cumulative directional participation.
The CDV layer classifies conditions as:
•	Rising
•	Falling
•	Neutral
Adaptive filtering is included to reduce minor fluctuations and noise.
OBV Breakout Detection
The script also evaluates whether On-Balance Volume is breaking above or below recent ranges.
This is used to identify:
•	expanding participation
•	weakening participation
•	or neutral flow conditions
The OBV component is not intended as a standalone signal generator, but rather as an additional confirmation layer inside the broader market-state framework.

[b]Market State Classification[/b]
One of the main purposes of the script is to convert multiple independent readings into a simplified market-state output.
The dashboard derives a “Market State” by combining:
•	Trend direction
•	Trend strength
•	Participation / flow confirmation
Possible classifications include:
•	Strong Bull Context
•	Bull Context
•	Mixed / Wait
•	Bear Context
•	Strong Bear Context
The classification is not predictive and should not be interpreted as financial advice.
Instead, it is intended to provide a structured summary of current market conditions.
https://www.tradingview.com/x/WFi4GZ7E/
[b]How Market State Is Derived[/b]
The logic combines three internal scoring groups:
Trend Score
Built from:
•	EMA 200 state
•	EMA 50 state
•	Supertrend state
Participation Score
Built from:
•	CMF bias
•	CDV direction
•	OBV breakout state
Strength Filter
Built from:
•	ADX threshold validation
Example:
•	bullish trend structure
•	bullish participation
•	and strong ADX
→ may classify as “Strong Bull Context”
Whereas:
•	bullish trend structure
•	weak participation
•	and weak ADX
→ may classify as “Mixed / Wait”
This allows the dashboard to identify agreement and disagreement between independent analytical layers.
Multi-Timeframe Logic
The script supports:
•	single timeframe mode
•	dual timeframe mode
Typical usage example:
•	Lower timeframe → execution context
•	Higher timeframe → broader directional context
This allows traders to compare:
•	local conditions
•	against higher timeframe structure
without switching charts repeatedly.
[b]Age Tracking[/b]
Each directional state includes an “age” measurement representing the number of bars since the last directional transition.
This is included because newer transitions and older trends may behave differently.
Example:
•	Low age → newer condition
•	High age → more mature condition
The script does not assume older trends will reverse, but age can provide additional context about trend maturity.

[b]Practical Interpretation[/b]
Example: Higher-Conviction Bullish Environment
Possible characteristics:
•	EMA structure bullish
•	Supertrend bullish
•	ADX elevated
•	CMF positive
•	CDV rising
•	OBV breakout bullish
This may indicate alignment between:
•	trend
•	momentum
•	and participation
https://www.tradingview.com/x/kz0FuHSa/
Example: Mixed Environment
Possible characteristics:
•	bullish EMA structure
•	falling CDV
•	weak ADX
•	neutral OBV behavior
This may indicate:
•	weakening momentum
•	transition behavior
•	or lower-conviction conditions
https://www.tradingview.com/x/ne7islgG/
[b]Intended Usage[/b]
The script is designed as:
•	a context tool
•	a filtering framework
•	and a market-state dashboard
It is not intended to replace:
•	risk management
•	execution models
•	or broader trading plans
The dashboard is generally most useful when combined with:
•	breakout systems
•	pullback systems
•	trend-following models
•	or discretionary execution methods

[b]Customization Options[/b]
The script includes:
•	1TF / 2TF modes
•	configurable EMA lengths
•	Supertrend settings
•	ADX threshold controls
•	CDV sensitivity adjustment
•	OBV breakout lookback settings
•	Table themes
•	Text sizing
•	Dashboard positioning

[b]Notes[/b]
•	CDV uses a candle-based proxy because true bid/ask delta data is unavailable in Pine Script.
•	The dashboard focuses on contextual interpretation rather than direct entry signals.
•	The Market State classification is derived from internal scoring logic and should be interpreted as a contextual summary, not a prediction engine.

[b]Summary[/b]
This dashboard was designed to organize multiple forms of market information into a single structured framework.
Rather than treating trend, momentum, and participation separately, the script attempts to evaluate how they interact with each other across one or more timeframes.
The result is a compact market-context tool intended to help traders:
•	identify alignment
•	recognize conflict
•	filter weaker conditions
•	and evaluate overall market structure more efficiently.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ScriptoPro

//@version=6
indicator("MTF Market State Dashboard", overlay=true, max_labels_count=500)

// INPUTS
//──────────────────────────────────────────────────────────────────────────────
grpTF  = "Timeframes"
mode   = input.string("2 TFs", "Mode", options=["1 TF","2 TFs"], group=grpTF)
tf1    = input.timeframe("60",  "TF1", group=grpTF)
tf2    = input.timeframe("240", "TF2", group=grpTF)

grpLens = "Lengths"
emaLen1 = input.int(200, "EMA 200 Length", minval=1, group=grpLens)
emaLen2 = input.int(50,  "EMA 50 Length",  minval=1, group=grpLens)

grpST = "Supertrend"
stAtrLen = input.int(10, "ATR Length", minval=1, group=grpST)
stMult   = input.float(3.0, "Multiplier", minval=0.1, step=0.1, group=grpST)

grpADX = "ADX / CMF / CDV"
adxLen = input.int(14, "ADX Length (via DMI)", minval=1, group=grpADX)
adxTrendLevel = input.float(20.0, "ADX Trend Threshold", minval=1, step=0.5, group=grpADX)
cmfLen = input.int(20, "CMF Length", minval=1, group=grpADX)

grpCDV = "CDV"
cdvLookback = input.int(20, "CDV Neutral Threshold Lookback", minval=2, group=grpCDV)
cdvNeutralK = input.float(0.20, "Neutral Threshold (x Avg |delta|)", minval=0.0, step=0.05, group=grpCDV)

grpOBV = "OBV Breakout"
obvLookback = input.int(10, "OBV High/Low Lookback", minval=2, group=grpOBV)

grpAge = "Age"
ageCap = input.int(60, "Age display cap (bars)", minval=1, group=grpAge)

grpUI = "UI"
posOpt   = input.string("Top Right", "Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=grpUI)
txtSize  = input.string("Small", "Text Size", options=["Tiny","Small","Normal","Large"], group=grpUI)
themeOpt = input.string("Dark Pro", "Table Theme", options=["Original","Dark Pro","Light Pro"], group=grpUI)

// HELPERS
//──────────────────────────────────────────────────────────────────────────────
f_pos(_p) =>
    _p == "Top Right" ? position.top_right :
     _p == "Top Left" ? position.top_left :
     _p == "Bottom Right" ? position.bottom_right : position.bottom_left

f_size(_s) =>
    _s == "Tiny" ? size.tiny :
     _s == "Small" ? size.small :
     _s == "Normal" ? size.normal : size.large

isOriginal = themeOpt == "Original"
isLightPro = themeOpt == "Light Pro"

headerBg  = isOriginal ? color.new(color.black, 0) : isLightPro ? color.rgb(42, 50, 62) : color.rgb(20, 26, 34)
labelBg   = isOriginal ? color.new(color.black, 85) : isLightPro ? color.rgb(235, 238, 244) : color.rgb(34, 42, 52)
frameCol  = isOriginal ? color.new(color.black, 0) : isLightPro ? color.rgb(120, 130, 145) : color.rgb(75, 85, 100)

headerTxt = color.white
labelTxt  = isOriginal ? color.white : isLightPro ? color.rgb(20, 25, 35) : color.rgb(230, 235, 240)
valueTxt  = color.white

bullBg    = isOriginal ? color.new(#067841, 0) : isLightPro ? color.rgb(10, 135, 82) : color.rgb(0, 120, 75)
bearBg    = isOriginal ? color.new(#790707, 0) : isLightPro ? color.rgb(185, 52, 55) : color.rgb(150, 35, 38)
neutralBg = isOriginal ? color.new(color.gray, 0) : isLightPro ? color.rgb(120, 125, 135) : color.rgb(85, 92, 102)
infoBg    = isOriginal ? color.new(color.blue, 70) : isLightPro ? color.rgb(55, 100, 165) : color.rgb(42, 82, 145)
mixedBg   = isOriginal ? color.new(color.orange, 20) : isLightPro ? color.rgb(190, 130, 40) : color.rgb(160, 105, 25)

f_cellColorState(_state) =>
    _state == 1 ? bullBg : _state == -1 ? bearBg : neutralBg

f_age_txt(_age, _cap) =>
    _age > _cap ? ">" + str.tostring(_cap) : str.tostring(_age)

f_txt_bb(_state, _age, _cap) =>
    (_state == 1 ? "Bull" : "Bear") + "  •  " + f_age_txt(_age, _cap)

f_txt_obv(_state, _age, _cap) =>
    (_state == 1 ? "Bull" : _state == -1 ? "Bear" : "Neutral") + "  •  " + f_age_txt(_age, _cap)

f_txt_tri(_state, _age, _cap) =>
    (_state == 1 ? "Rising" : _state == -1 ? "Falling" : "Neutral") + "  •  " + f_age_txt(_age, _cap)

f_state_age_from_bool(_isBull) =>
    var int _state = na
    var int _age = 0
    int _newState = _isBull ? 1 : -1
    if na(_state)
        _state := _newState
        _age := 0
    else
        if _newState != _state
            _state := _newState
            _age := 0
        else
            _age += 1
    [_state, _age]

f_state_age_from_state(_newState) =>
    var int _state = na
    var int _age = 0
    if na(_state)
        _state := _newState
        _age := 0
    else
        if _newState != _state
            _state := _newState
            _age := 0
        else
            _age += 1
    [_state, _age]

// INDICATOR LOGIC
//──────────────────────────────────────────────────────────────────────────────
f_ema_state_age(_len) =>
    float _ema = ta.ema(close, _len)
    bool _bull = close > _ema
    f_state_age_from_bool(_bull)

f_st_state_age(_mult, _atrLen) =>
    [_stLine, _stDir] = ta.supertrend(_mult, _atrLen)
    bool _bull = close > _stLine
    f_state_age_from_bool(_bull)

f_adx_val(_len) =>
    [_p, _m, _adx] = ta.dmi(_len, _len)
    _adx

f_cmf_val(_len) =>
    float _hl  = high - low
    float _mfm = _hl == 0.0 ? 0.0 : ((close - low) - (high - close)) / _hl
    float _mfv = _mfm * volume
    float _sumMFV = 0.0
    float _sumVol = 0.0
    for i = 0 to _len - 1
        _sumMFV += _mfv[i]
        _sumVol += volume[i]
    _sumVol == 0.0 ? 0.0 : _sumMFV / _sumVol

f_cdv_val() =>
    var float _cdv = na
    float _delta = close > close[1] ? volume : close < close[1] ? -volume : 0.0
    _cdv := nz(_cdv[1]) + _delta
    _cdv

f_cdv_state_age(_lb, _k) =>
    float _cdv = f_cdv_val()
    float _chg = _cdv - nz(_cdv[1])
    float _sumAbs = 0.0
    for i = 0 to _lb - 1
        _sumAbs += math.abs(_cdv[i] - nz(_cdv[i + 1]))
    float _avgAbs = _sumAbs / _lb
    float _thr = _k * _avgAbs
    int _state = math.abs(_chg) <= _thr ? 0 : _chg > 0 ? 1 : -1
    f_state_age_from_state(_state)

f_obv() =>
    var float _obv = na
    _obv := nz(_obv[1]) + (close > close[1] ? volume : close < close[1] ? -volume : 0)
    _obv

f_obv_breakout_state_age(_lb) =>
    float _o  = f_obv()
    float _hi = ta.highest(_o, _lb)[1]
    float _lo = ta.lowest(_o, _lb)[1]
    int _state = _o > _hi ? 1 : _o < _lo ? -1 : 0
    f_state_age_from_state(_state)

// MARKET STATE DECISION LOGIC
//──────────────────────────────────────────────────────────────────────────────
f_market_state(_ema200, _ema50, _st, _adx, _cmf, _cdv, _obv, _adxLevel) =>
    int trendScore = _ema200 + _ema50 + _st
    int flowScore = (_cmf > 0 ? 1 : _cmf < 0 ? -1 : 0) + _cdv + _obv
    bool trendStrong = _adx >= _adxLevel

    int totalScore = trendScore + flowScore

    string txt = "Mixed / Wait"
    int bgState = 0

    if trendScore >= 2 and flowScore >= 1 and trendStrong
        txt := "Strong Bull Context"
        bgState := 1
    else if trendScore >= 2 and totalScore > 0
        txt := "Bull Context"
        bgState := 1
    else if trendScore <= -2 and flowScore <= -1 and trendStrong
        txt := "Strong Bear Context"
        bgState := -1
    else if trendScore <= -2 and totalScore < 0
        txt := "Bear Context"
        bgState := -1
    else
        txt := "Mixed / Wait"
        bgState := 0

    [txt, bgState, trendScore, flowScore]

// MTF CALCS
//──────────────────────────────────────────────────────────────────────────────
use2 = mode == "2 TFs"

[ema200State_1, ema200Age_1] = request.security(syminfo.tickerid, tf1, f_ema_state_age(emaLen1))
[ema50State_1,  ema50Age_1 ] = request.security(syminfo.tickerid, tf1, f_ema_state_age(emaLen2))
[stState_1,     stAge_1    ] = request.security(syminfo.tickerid, tf1, f_st_state_age(stMult, stAtrLen))
adx_1 = request.security(syminfo.tickerid, tf1, f_adx_val(adxLen))
cmf_1 = request.security(syminfo.tickerid, tf1, f_cmf_val(cmfLen))
[cdvState_1, cdvAge_1] = request.security(syminfo.tickerid, tf1, f_cdv_state_age(cdvLookback, cdvNeutralK))
[obvState_1, obvAge_1] = request.security(syminfo.tickerid, tf1, f_obv_breakout_state_age(obvLookback))

[ema200State_2, ema200Age_2] = request.security(syminfo.tickerid, tf2, f_ema_state_age(emaLen1))
[ema50State_2,  ema50Age_2 ] = request.security(syminfo.tickerid, tf2, f_ema_state_age(emaLen2))
[stState_2,     stAge_2    ] = request.security(syminfo.tickerid, tf2, f_st_state_age(stMult, stAtrLen))
adx_2 = request.security(syminfo.tickerid, tf2, f_adx_val(adxLen))
cmf_2 = request.security(syminfo.tickerid, tf2, f_cmf_val(cmfLen))
[cdvState_2, cdvAge_2] = request.security(syminfo.tickerid, tf2, f_cdv_state_age(cdvLookback, cdvNeutralK))
[obvState_2, obvAge_2] = request.security(syminfo.tickerid, tf2, f_obv_breakout_state_age(obvLookback))

[stateTxt_1, stateBg_1, trendScore_1, flowScore_1] = f_market_state(ema200State_1, ema50State_1, stState_1, adx_1, cmf_1, cdvState_1, obvState_1, adxTrendLevel)
[stateTxt_2, stateBg_2, trendScore_2, flowScore_2] = f_market_state(ema200State_2, ema50State_2, stState_2, adx_2, cmf_2, cdvState_2, obvState_2, adxTrendLevel)

// TABLE
//──────────────────────────────────────────────────────────────────────────────
int cols = use2 ? 3 : 2

var table t = na
var int prevCols = na
var string prevPos = ""
var string prevTxt = ""
var string prevTheme = ""

needRebuild = barstate.isfirst or na(t) or prevCols != cols or prevPos != posOpt or prevTxt != txtSize or prevTheme != themeOpt

if needRebuild
    if not na(t)
        table.delete(t)
    t := table.new(f_pos(posOpt), cols, 10, frame_color=frameCol, frame_width=isOriginal ? 1 : 2, border_color=frameCol, border_width=1)
    prevCols := cols
    prevPos := posOpt
    prevTxt := txtSize
    prevTheme := themeOpt

if barstate.islast
    table.cell(t, 0, 0, "Metric", text_color=headerTxt, bgcolor=headerBg, text_size=f_size(txtSize))
    table.cell(t, 1, 0, "TF1", text_color=headerTxt, bgcolor=headerBg, text_size=f_size(txtSize))
    if use2
        table.cell(t, 2, 0, "TF2", text_color=headerTxt, bgcolor=headerBg, text_size=f_size(txtSize))

    table.cell(t, 0, 1, "TFs (Chart: " + timeframe.period + ")", text_color=labelTxt, bgcolor=labelBg, text_size=f_size(txtSize))
    table.cell(t, 1, 1, tf1, text_color=labelTxt, bgcolor=labelBg, text_size=f_size(txtSize))
    if use2
        table.cell(t, 2, 1, tf2, text_color=labelTxt, bgcolor=labelBg, text_size=f_size(txtSize))

    table.cell(t, 0, 2, "Market State", text_color=labelTxt, bgcolor=labelBg, text_size=f_size(txtSize))
    table.cell(t, 1, 2, stateTxt_1, text_color=valueTxt, bgcolor=stateBg_1 == 1 ? bullBg : stateBg_1 == -1 ? bearBg : mixedBg, text_size=f_size(txtSize))
    if use2
        table.cell(t, 2, 2, stateTxt_2, text_color=valueTxt, bgcolor=stateBg_2 == 1 ? bullBg : stateBg_2 == -1 ? bearBg : mixedBg, text_size=f_size(txtSize))

    table.cell(t, 0, 3, "EMA " + str.tostring(emaLen1), text_color=labelTxt, bgcolor=labelBg, text_size=f_size(txtSize))
    table.cell(t, 1, 3, f_txt_bb(ema200State_1, ema200Age_1, ageCap), text_color=valueTxt, bgcolor=f_cellColorState(ema200State_1), text_size=f_size(txtSize))
    if use2
        table.cell(t, 2, 3, f_txt_bb(ema200State_2, ema200Age_2, ageCap), text_color=valueTxt, bgcolor=f_cellColorState(ema200State_2), text_size=f_size(txtSize))

    table.cell(t, 0, 4, "EMA " + str.tostring(emaLen2), text_color=labelTxt, bgcolor=labelBg, text_size=f_size(txtSize))
    table.cell(t, 1, 4, f_txt_bb(ema50State_1, ema50Age_1, ageCap), text_color=valueTxt, bgcolor=f_cellColorState(ema50State_1), text_size=f_size(txtSize))
    if use2
        table.cell(t, 2, 4, f_txt_bb(ema50State_2, ema50Age_2, ageCap), text_color=valueTxt, bgcolor=f_cellColorState(ema50State_2), text_size=f_size(txtSize))

    table.cell(t, 0, 5, "Supertrend", text_color=labelTxt, bgcolor=labelBg, text_size=f_size(txtSize))
    table.cell(t, 1, 5, f_txt_bb(stState_1, stAge_1, ageCap), text_color=valueTxt, bgcolor=f_cellColorState(stState_1), text_size=f_size(txtSize))
    if use2
        table.cell(t, 2, 5, f_txt_bb(stState_2, stAge_2, ageCap), text_color=valueTxt, bgcolor=f_cellColorState(stState_2), text_size=f_size(txtSize))

    table.cell(t, 0, 6, "ADX (" + str.tostring(adxLen) + ")", text_color=labelTxt, bgcolor=labelBg, text_size=f_size(txtSize))
    table.cell(t, 1, 6, str.tostring(adx_1, "#.##"), text_color=valueTxt, bgcolor=infoBg, text_size=f_size(txtSize))
    if use2
        table.cell(t, 2, 6, str.tostring(adx_2, "#.##"), text_color=valueTxt, bgcolor=infoBg, text_size=f_size(txtSize))

    table.cell(t, 0, 7, "CMF (" + str.tostring(cmfLen) + ")", text_color=labelTxt, bgcolor=labelBg, text_size=f_size(txtSize))
    table.cell(t, 1, 7, str.tostring(cmf_1, "#.###"), text_color=valueTxt, bgcolor=infoBg, text_size=f_size(txtSize))
    if use2
        table.cell(t, 2, 7, str.tostring(cmf_2, "#.###"), text_color=valueTxt, bgcolor=infoBg, text_size=f_size(txtSize))

    table.cell(t, 0, 8, "CDV (Trend)", text_color=labelTxt, bgcolor=labelBg, text_size=f_size(txtSize))
    table.cell(t, 1, 8, f_txt_tri(cdvState_1, cdvAge_1, ageCap), text_color=valueTxt, bgcolor=f_cellColorState(cdvState_1), text_size=f_size(txtSize))
    if use2
        table.cell(t, 2, 8, f_txt_tri(cdvState_2, cdvAge_2, ageCap), text_color=valueTxt, bgcolor=f_cellColorState(cdvState_2), text_size=f_size(txtSize))

    table.cell(t, 0, 9, "OBV Breakout (" + str.tostring(obvLookback) + ")", text_color=labelTxt, bgcolor=labelBg, text_size=f_size(txtSize))
    table.cell(t, 1, 9, f_txt_obv(obvState_1, obvAge_1, ageCap), text_color=valueTxt, bgcolor=f_cellColorState(obvState_1), text_size=f_size(txtSize))
    if use2
        table.cell(t, 2, 9, f_txt_obv(obvState_2, obvAge_2, ageCap), text_color=valueTxt, bgcolor=f_cellColorState(obvState_2), text_size=f_size(txtSize))
````

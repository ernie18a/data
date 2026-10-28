# Kalman Flow Trail

- url: https://www.tradingview.com/script/vRHKCr1V-Kalman-Flow-Trail/
- type: indicator
- pine_id: PUB;83ecee7550b34688b6d23fe55db5d35b
- version: 4.0

## Description

Kalman Flow Trail

Kalman Flow Trail is a clean trend-following and market structure overlay designed to help traders read market direction, structural shifts, protected levels, liquidity targets, and higher-timeframe alignment from one chart.

The script combines an adaptive Kalman-based trail with market structure logic, live strong/weak range levels, POI supply and demand zones, optional MSS/MSB guides, higher-timeframe confirmation, flip markers, and a compact Flow Dashboard.

Core Features

1. Adaptive Kalman Flow Engine

At the centre of the script is a dual Kalman smoothing engine designed to filter market noise while tracking directional flow.

Unlike a standard moving average with fixed behaviour, the trail adapts using market structure activity and volatility. When price action becomes more active, the trail can respond faster. When price is choppy or compressed, the trail becomes smoother to reduce unnecessary noise.

The engine also includes a structure-bias filter to help reduce overreaction when Kalman momentum and market structure are not aligned.

2. MSS / MSB Structure Guides

Kalman Flow Trail includes optional structure guides for traders who want to see internal market structure directly on the chart.

MSS = Market Structure Shift
MSB = Market Structure Break

These guides can be toggled on or off depending on whether the trader wants a detailed structure view or a cleaner visual layout.

3. Live Strong & Weak Range Levels

The script automatically tracks swing structure and highlights strong protected levels and weak target levels.

Strong levels represent the protected side of the current range.
Weak levels represent likely liquidity targets.

When a weak target is swept, the level can roll forward live with the current extreme until a new confirmed pivot forms. This helps keep the range logic responsive during strong continuation moves.

4. POI Supply & Demand Zones

The script can draw POI zones from important structural pivot areas.

In a bullish range, the POI highlights a potential demand area around the protected strong low.
In a bearish range, the POI highlights a potential supply area around the protected strong high.

The zones use theme-adaptive colours and dashed borders for a cleaner and more professional chart style.

5. Higher-Timeframe Confirmation

The optional HTF Kalman Basis allows traders to compare current chart flow with a selected higher timeframe.

For example, traders can view a 1H Kalman basis while analysing a 5-minute or 15-minute chart. This helps identify whether lower-timeframe price action is aligned with the broader market direction.

6. Flow Dashboard

The built-in Flow Dashboard gives a compact read of current market conditions:

Trail Direction
Kalman Momentum
HTF Alignment
Range State

This allows traders to quickly check whether the current flow, momentum, higher timeframe, and range structure are aligned.

7. Trail Flip Markers

Diamond markers appear when the Kalman Flow Trail changes direction.

These Trail Flip markers are designed to highlight possible shifts in directional flow. They are not standalone buy or sell signals, but they can help traders identify when market conditions are changing.

8. Proximity Star

The live trail star follows the active trail level.

When price moves close to the trail, the star changes into a warning state. This can help traders see when price is approaching a possible reaction area, mean-reversion zone, or potential trail breach.

Visual Themes

Kalman Flow Trail includes multiple built-in colour themes:

Lucid Neon
Ember Pulse
Arctic Signal
Violet Flux
Mono Current
Custom Theme

Users can also toggle trail glow, trail fill, trail boundaries, flip diamonds, live trail star, HTF basis, POI zones, MSS/MSB guides, and candle colouring.

How Traders Can Use It

Trend Continuation
Look for price respecting the trail and holding above protected demand areas in bullish conditions, or below protected supply areas in bearish conditions.

Trail Flip
Use diamond markers as visual alerts that directional flow may be shifting.

Strong / Weak Range Logic
Use strong levels as protected structure and weak levels as potential liquidity objectives.

HTF Alignment
Higher-quality conditions generally occur when Trail Direction and HTF Alignment point in the same direction.

POI Zones
Use POI Demand and POI Supply zones as structural areas of interest for reactions, continuation, or invalidation.

Best Use Cases

Trend-following analysis
Market structure reading
Liquidity target mapping
Higher-timeframe confirmation
Clean visual trend tracking
Crypto, Forex, Indices, Stocks, and Commodities

Notes

This indicator is designed as an analytical tool. It does not predict the future and should not be used as a standalone trading system. Traders should combine it with their own market context, confirmation process, and risk management.

Disclaimer

Trading involves risk. This script is for educational and analytical purposes only and does not constitute financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NICK789

//@version=6
indicator(
     "Kalman Flow Trail",
     "Kalman Flow Trail",
     overlay = true,
     max_labels_count = 500,
     max_lines_count = 500,
     max_boxes_count = 500,
     max_bars_back = 5000
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//╔════════════════════════════════════════════════════════════════════════════╗
//║                         KALMAN FLOW TRAIL                                  ║
//║                              NICK789                                       ║
//╚════════════════════════════════════════════════════════════════════════════╝
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// Adaptive Kalman trail with market-structure guidance, ranked adaptive range highs and lows,
// higher-timeframe confirmation, and a clean trend dashboard.
//
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//╔════════════════════════════════════════════════════════════════════════════╗
//║                              SETTINGS                                      ║
//╚════════════════════════════════════════════════════════════════════════════╝
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┃                                                                          ┃
//┃  01. USER INPUT GROUPS                                                   ┃
//┃                                                                          ┃
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
const string grpKalman = "01. Kalman Engine"
const string grpMacro  = "02. Trail Visuals"
const string grpTheme  = "03. Colour Theme"
const string grpS1Vis  = "04. MSS / MSB Guides"
const string grpRange  = "05. Adaptive Range Levels"
const string grpHTF    = "06. HTF Confirmation"
const string grpTable  = "07. Dashboard"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 01. KALMAN ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
kalmanMainLen = input.int(50, "Fast Kalman Length", minval = 2, maxval = 500, group = grpKalman, tooltip = "Lower value = faster Kalman trail response.")
kalmanSlowLen = input.int(100, "Slow Kalman Length", minval = 2, maxval = 800, group = grpKalman, tooltip = "Higher value = smoother Kalman confirmation.")

lenFast = 6
lenSlow = 40
pushFac = 0.35
structureWeight = 0.60

kalmanResponse = 0.50
kalmanNoise = 0.50
disagreeFactor = 0.35

kalmanMainQ = kalmanResponse / kalmanMainLen
kalmanMainR = kalmanNoise
kalmanSlowQ = kalmanResponse / kalmanSlowLen
kalmanSlowR = kalmanNoise

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 02. TRAIL VISUALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showFlowTrail    = input.bool(true, "Show Kalman Trail", group = grpMacro)
showKalmanBasis  = input.bool(false, "Show Kalman Basis", group = grpMacro)
showFlowBands    = input.bool(false, "Show Trail Boundaries", group = grpMacro)
showBoundaryFill = input.bool(true, "Show Trail Fill", group = grpMacro)
showFlipDiamonds = input.bool(true, "Show Flip Diamonds", group = grpMacro)
showTrailStar    = input.bool(true, "Show Live Trail Star", group = grpMacro)
showTipLine      = input.bool(true, "Show Live Trail Tip", group = grpMacro)
paintBars        = input.bool(false, "Colour Candles", group = grpMacro)

flowBoundaryMult = input.float(1.5, "Trail Boundary Multiplier", minval = 0.1, maxval = 10.0, step = 0.1, group = grpMacro)
useSlopeConfirm  = input.bool(true, "Use Kalman Slope Confirmation", group = grpMacro)
proxDist          = input.float(0.25, "Trail Proximity Warning ATR", minval = 0.05, maxval = 2.0, step = 0.05, group = grpMacro)
trailWidth        = input.int(2, "Trail Width", minval = 1, maxval = 5, group = grpMacro, inline = "w")
glowWidth         = input.int(7, "Glow Width", minval = 1, maxval = 12, group = grpMacro, inline = "w")
glowTransp        = input.int(84, "Glow Transparency", minval = 0, maxval = 100, group = grpMacro, inline = "t")
fillTransp        = input.int(90, "Fill Transparency", minval = 0, maxval = 100, group = grpMacro, inline = "t")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 03. COLOUR THEME
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
themeMode = input.string(
     "Lucid Neon",
     "Colour Theme",
     options = ["Lucid Neon", "Ember Pulse", "Arctic Signal", "Violet Flux", "Mono Current", "Custom"],
     group = grpTheme)

customBull    = input.color(#089981, "Custom Bullish", inline = "custCol", group = grpTheme)
customBear    = input.color(#f23645, "Custom Bearish", inline = "custCol", group = grpTheme)
customNeutral = input.color(color.gray, "Custom Neutral", group = grpTheme)

bullCol =
     themeMode == "Lucid Neon"    ? #00F5A0 :
     themeMode == "Ember Pulse"   ? #FFB000 :
     themeMode == "Arctic Signal" ? #00C2FF :
     themeMode == "Violet Flux"   ? #B56CFF :
     themeMode == "Mono Current"  ? #D7DEE8 :
     customBull

bearCol =
     themeMode == "Lucid Neon"    ? #FF2E63 :
     themeMode == "Ember Pulse"   ? #FF3B30 :
     themeMode == "Arctic Signal" ? #FF5C8A :
     themeMode == "Violet Flux"   ? #FF4FD8 :
     themeMode == "Mono Current"  ? #5C6773 :
     customBear

neutralCol =
     themeMode == "Lucid Neon"    ? #8A8F98 :
     themeMode == "Ember Pulse"   ? #A77A45 :
     themeMode == "Arctic Signal" ? #7DA7B8 :
     themeMode == "Violet Flux"   ? #9B8BB4 :
     themeMode == "Mono Current"  ? #8C96A3 :
     customNeutral

warningCol =
     themeMode == "Lucid Neon"    ? #FFE66D :
     themeMode == "Ember Pulse"   ? #FFD166 :
     themeMode == "Arctic Signal" ? #B8F7FF :
     themeMode == "Violet Flux"   ? #F7B2FF :
     themeMode == "Mono Current"  ? #F2F2F2 :
     color.yellow


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 04. INTERNAL STRUCTURE LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
piv1 = 5

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 04. MSS / MSB GUIDES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showS1Ln = input.bool(false, "MSS / MSB Lines", group = grpS1Vis, inline = "f0")
showS1Lb = input.bool(false, "MSS / MSB Tags", group = grpS1Vis, inline = "f0")
colS1Up  = input.color(#089981, "Bullish", group = grpS1Vis, inline = "f1")
colS1Dn  = input.color(#f23645, "Bearish", group = grpS1Vis, inline = "f1")
styS1In  = input.string("Dotted", "Style", options = ["Solid", "Dashed", "Dotted"], group = grpS1Vis, inline = "f3")
szS1In   = input.string("Small", "Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpS1Vis, inline = "f3")
widS1    = input.int(2, "Width", minval = 1, group = grpS1Vis, inline = "f3")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 05. ADAPTIVE RANGE LEVELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showRangeLevels      = input.bool(true, "Show Adaptive Range Levels", group = grpRange)
rangeLookback    = input.int(50, "Range Lookback", minval = 10, maxval = 1000, step = 10, group = grpRange)
rangeZonePct     = input.float(10.0, "Level Zone Size %", minval = 1.0, maxval = 50.0, step = 0.5, group = grpRange)
mediumThreshold  = input.float(8.0, "Medium Pressure %", minval = 0.0, maxval = 100.0, step = 1.0, group = grpRange)
strongThreshold  = input.float(18.0, "Strong Pressure %", minval = 0.0, maxval = 100.0, step = 1.0, group = grpRange)
showStrengthLine       = input.bool(true, "Strength Line", inline = "pd0", group = grpRange)
showStrengthLabel      = input.bool(true, "Strength Tag", inline = "pd0", group = grpRange)
showRangeTarget     = input.bool(true, "Live Target", inline = "pd1", group = grpRange)
showRangePoi        = input.bool(false, "Level Zone", inline = "pd1", group = grpRange)
showVolDelta     = input.bool(true, "Show Volumatic Delta", group = grpRange)
rangeStyleIn        = input.string("Solid", "Style", options = ["Solid", "Dashed", "Dotted"], inline = "pd2", group = grpRange)
rangeSizeIn         = input.string("Small", "Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], inline = "pd2", group = grpRange)
rangeWidth          = input.int(2, "Width", minval = 1, maxval = 5, inline = "pd2", group = grpRange)
poiTransp        = input.int(86, "POI Transparency", minval = 0, maxval = 100, group = grpRange)
rangeRightOffset     = input.int(8, "Right Label Offset", minval = 1, maxval = 100, group = grpRange, tooltip = "Extends the wick-anchored level and places its label this many bars to the right of the live candle.")

poiBullCol =
     themeMode == "Lucid Neon"    ? #00E5FF :
     themeMode == "Ember Pulse"   ? #FFF176 :
     themeMode == "Arctic Signal" ? #1DE9B6 :
     themeMode == "Violet Flux"   ? #D500F9 :
     themeMode == "Mono Current"  ? #ECEFF1 :
     customBull

poiBearCol =
     themeMode == "Lucid Neon"    ? #FF9100 :
     themeMode == "Ember Pulse"   ? #C62828 :
     themeMode == "Arctic Signal" ? #E91E63 :
     themeMode == "Violet Flux"   ? #3D5AFE :
     themeMode == "Mono Current"  ? #263238 :
     customBear

// 06. HTF CONFIRMATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showHtfLine = input.bool(false, "Show HTF Kalman Basis", group = grpHTF)
htfTf       = input.timeframe("60", "HTF Timeframe", group = grpHTF)

showMtfStrip = input.bool(true, "Show Compact MTF Strip", group = grpHTF)

mtf1 = input.timeframe("5",   "TF 1", group = grpHTF, inline = "mtf1")
mtf2 = input.timeframe("15",  "TF 2", group = grpHTF, inline = "mtf1")
mtf3 = input.timeframe("60",  "TF 3", group = grpHTF, inline = "mtf2")
mtf4 = input.timeframe("240", "TF 4", group = grpHTF, inline = "mtf2")
mtf5 = input.timeframe("D",   "TF 5", group = grpHTF, inline = "mtf3")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 07. DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showTable  = input.bool(true, "Show Flow Dashboard", group = grpTable)
tablePosIn = input.string("Top Right", "Table Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = grpTable)
tableTextSizeIn = input.string("Normal", "Dashboard Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpTable)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CONSTANTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
wMss = 1
wMsb = 3

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┃                                                                          ┃
//┃  03. UTILITY FUNCTIONS                                                   ┃
//┃                                                                          ┃
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
lineStyle(txt) =>
    switch txt
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        => line.style_dotted

labelSize(txt) =>
    switch txt
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.huge

structText(os, isBull) =>
    isBull ? (os == -1 ? "MSS" : "MSB") : (os == 1 ? "MSS" : "MSB")

clamp01(x) =>
    math.max(0.0, math.min(1.0, x))

fBiasText(x) =>
    x > 0 ? "Bullish" : x < 0 ? "Bearish" : "Neutral"

fTablePos(txt) =>
    switch txt
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

fTfLabel(tf) =>
    switch tf
        "1"   => "1"
        "3"   => "3"
        "5"   => "5"
        "15"  => "15"
        "30"  => "30"
        "45"  => "45"
        "60"  => "1H"
        "120" => "2H"
        "180" => "3H"
        "240" => "4H"
        "D"   => "D"
        "W"   => "W"
        "M"   => "M"
        => tf

fTrendIcon(x) =>
    x > 0 ? "▲" : x < 0 ? "▼" : "•"

fTrendCol(x) =>
    x > 0 ? bullCol : x < 0 ? bearCol : neutralCol

structCalc(pLen, swHi, swLo, swHiBar, swLoBar) =>
    ph = ta.pivothigh(high, pLen, pLen)
    pl = ta.pivotlow(low, pLen, pLen)

    hi = swHi
    lo = swLo
    hiBar = swHiBar
    loBar = swLoBar

    if not na(ph)
        hi := ph
        hiBar := bar_index - pLen

    if not na(pl)
        lo := pl
        loBar := bar_index - pLen

    bullBreak = not na(hi) and close > hi and close[1] <= hi
    bearBreak = not na(lo) and close < lo and close[1] >= lo

    [ph, pl, hi, lo, hiBar, loBar, bullBreak, bearBreak]

drawStruct(isBull, trig, sBar, sPx, txt, lnCol, lbCol, lnSty, lnWid, showLn, showLb, actLb, actPx, actBar, lbSz) =>
    newLb = actLb
    newPx = actPx
    newBar = actBar

    if trig and not na(sBar) and not na(sPx)
        if showLn
            line.new(sBar, sPx, bar_index, sPx, color = lnCol, style = lnSty, width = lnWid)

        if showLb
            sameSwing = not na(actPx) and not na(actBar) and math.abs(actPx - sPx) < syminfo.mintick and actBar == sBar

            if sameSwing and not na(actLb)
                label.delete(actLb)

            newLb := label.new(
                 int(math.avg(bar_index, sBar)),
                 sPx,
                 txt,
                 color = color(na),
                 textcolor = lbCol,
                 style = isBull ? label.style_label_down : label.style_label_up,
                 size = lbSz
             )

            newPx := sPx
            newBar := sBar

    [newLb, newPx, newBar]

f_kalman_pair(_src, _mainQ, _mainR, _slowQ, _slowR) =>
    var float kMainEst = na
    var float kMainErr = 1.0
    if na(kMainEst)
        kMainEst := _src
    mainK    = (kMainErr + _mainQ) / (kMainErr + _mainQ + _mainR)
    kMainEst := kMainEst + mainK * (_src - kMainEst)
    kMainErr := (1.0 - mainK) * (kMainErr + _mainQ)

    var float kSlowEst = na
    var float kSlowErr = 1.0
    if na(kSlowEst)
        kSlowEst := _src
    slowK    = (kSlowErr + _slowQ) / (kSlowErr + _slowQ + _slowR)
    kSlowEst := kSlowEst + slowK * (_src - kSlowEst)
    kSlowErr := (1.0 - slowK) * (kSlowErr + _slowQ)

    [kMainEst, kSlowEst]

fCoreTrail() =>
    var float _hi1 = na
    var float _lo1 = na
    var int _hiBar1 = na
    var int _loBar1 = na

    [_, __, _newHi1, _newLo1, _newHiBar1, _newLoBar1, _bullBreak1, _bearBreak1] = structCalc(piv1, _hi1, _lo1, _hiBar1, _loBar1)
    _hi1 := _newHi1
    _lo1 := _newLo1
    _hiBar1 := _newHiBar1
    _loBar1 := _newLoBar1

    _structureImpulse  = _bullBreak1 ? 1.0 : _bearBreak1 ? -1.0 : 0.0
    _structureActivity = ta.rma(math.abs(_structureImpulse), 20)
    _structureBias     = ta.rma(_structureImpulse, 20)

    [_kMain, _kSlow] = f_kalman_pair(close, kalmanMainQ, kalmanMainR, kalmanSlowQ, kalmanSlowR)

    _weightSum = math.max(structureWeight, 0.0001)
    _adapt     = math.min(1.0, (_structureActivity * structureWeight) / _weightSum)

    _aFast = 2.0 / (lenFast + 1.0)
    _aSlow = 2.0 / (lenSlow + 1.0)
    _alpha = _aSlow + (_aFast - _aSlow) * _adapt

    _mid = na(_hi1) or na(_lo1) ? na : (_hi1 + _lo1) / 2.0
    _anchW = 0.20 * _structureActivity

    _m3 = 1.0
    _a3 = clamp01(_alpha * _m3)
    _p3 = pushFac * _m3

    var float _b3 = na
    _atr = ta.atr(14)

    _kalmanAgree =
         _structureBias > 0 and _kMain > _kSlow ? 1.0 :
         _structureBias < 0 and _kMain < _kSlow ? 1.0 :
         disagreeFactor

    _b3 := na(_b3[1]) ? _kMain : _b3[1] + _a3 * (_kMain - _b3[1])
    _b3 := _b3 + _p3 * _structureBias * _kalmanAgree * _atr
    _b3 := not na(_mid) ? _b3 + _anchW * (_mid - _b3) : _b3

    _b3

fCoreState() =>
    _trail = fCoreTrail()
    na(_trail) ? 0 : close > _trail ? 1 : close < _trail ? -1 : 0

fTextSize(txt) =>
    switch txt
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        => size.large

fSign(x) =>
    x > 0 ? 1 : x < 0 ? -1 : 0

fAlignCount(base, a, b, c, d, e) =>
    _b = fSign(base)
    _c1 = _b != 0 and fSign(a) == _b ? 1 : 0
    _c2 = _b != 0 and fSign(b) == _b ? 1 : 0
    _c3 = _b != 0 and fSign(c) == _b ? 1 : 0
    _c4 = _b != 0 and fSign(d) == _b ? 1 : 0
    _c5 = _b != 0 and fSign(e) == _b ? 1 : 0
    _c1 + _c2 + _c3 + _c4 + _c5


fVolPressure(_len) =>
    _bullVol = math.sum(close > open ? volume : 0.0, _len)
    _bearVol = math.sum(close < open ? volume : 0.0, _len)
    _totalVol = _bullVol + _bearVol
    _delta = _totalVol == 0.0 ? 0.0 : (_bullVol - _bearVol) / _totalVol * 100.0
    [_bullVol, _bearVol, _delta]

fRangeRanks(_trend, _delta) =>
    _lowRank = _delta >= strongThreshold and _trend == 1 ? 3 :
         _delta >= mediumThreshold or (_delta > 0 and _trend == 1) ? 2 : 1
    _highRank = _delta <= -strongThreshold and _trend == -1 ? 3 :
         _delta <= -mediumThreshold or (_delta < 0 and _trend == -1) ? 2 : 1
    [_highRank, _lowRank]

fRankText(_rank) =>
    _rank == 3 ? "Strong" : _rank == 2 ? "Medium" : "Weak"

fRankShort(_rank) =>
    _rank == 3 ? "S" : _rank == 2 ? "M" : "W"

fRankColor(_rank, _zoneColor) =>
    _rank == 3 ? _zoneColor : _rank == 2 ? warningCol : neutralCol

fDeltaText(_delta) =>
    (_delta > 0 ? "+" : "") + str.tostring(_delta, "#.##") + "%"

fActiveLevelText(_trend, _highRank, _lowRank) =>
    _trend > 0 ? fRankText(_lowRank) + " Low" :
     _trend < 0 ? fRankText(_highRank) + " High" : "Building"

fRangePoiText(_trend) =>
    _trend > 0 ? "POI Demand" : _trend < 0 ? "POI Supply" : ""

fRangeTargetText(_trend) =>
    _trend > 0 ? "Live High Target" : _trend < 0 ? "Live Low Target" : ""

fRangePathText(_trend, _highRank, _lowRank) =>
    _trend > 0 ? fRankText(_lowRank) + " Low → High" :
     _trend < 0 ? fRankText(_highRank) + " High → Low" : "Building"

fRangePathShort(_trend, _highRank, _lowRank) =>
    _trend > 0 ? fRankShort(_lowRank) + ".Low→High" :
     _trend < 0 ? fRankShort(_highRank) + ".High→Low" : "Build"

fRangePathColor(_trend, _highRank, _lowRank) =>
    _trend > 0 ? fRankColor(_lowRank, poiBullCol) :
     _trend < 0 ? fRankColor(_highRank, poiBearCol) : neutralCol

fRangeState() =>
    _state = fCoreState()
    [_, __, _delta] = fVolPressure(rangeLookback)
    [_hRank, _lRank] = fRangeRanks(_state, _delta)
    [_state, _hRank, _lRank, _delta]
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┃                                                                          ┃
//┃  04. DERIVED SETTINGS                                                    ┃
//┃                                                                          ┃
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
styS1 = lineStyle(styS1In)
labS1 = labelSize(szS1In)

aFast = 2.0 / (lenFast + 1.0)
aSlow = 2.0 / (lenSlow + 1.0)
colSUp = #089981
colSDn = #f23645
tablePos = fTablePos(tablePosIn)
tableTxtSize = fTextSize(tableTextSizeIn)
rangeStyle = lineStyle(rangeStyleIn)
rangeLabelSize = labelSize(rangeSizeIn)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┃                                                                          ┃
//┃  05. FLOW STATE                                                          ┃
//┃                                                                          ┃
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float hi1 = na
var float lo1 = na
var int hiBar1 = na
var int loBar1 = na
var int os1 = 0

var label bullLb1 = na
var label bearLb1 = na
var float bullPx1 = na
var float bearPx1 = na
var int bullBar1 = na
var int bearBar1 = na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┃                                                                          ┃
//┃  06. ADAPTIVE RANGE LEVEL STATE                                          ┃
//┃                                                                          ┃
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var box rangePoiBox = na
var line rangeStrengthLine = na
var line rangeTargetLine = na
var label rangeStrengthLabel = na
var label rangeTargetLabel = na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┃                                                                          ┃
//┃  FLOW CALCULATIONS                                                       ┃
//┃                                                                          ┃
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[ph1, pl1, newHi1, newLo1, newHiBar1, newLoBar1, bullBreak1, bearBreak1] = structCalc(piv1, hi1, lo1, hiBar1, loBar1)

hi1 := newHi1
lo1 := newLo1
hiBar1 := newHiBar1
loBar1 := newLoBar1


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┃                                                                          ┃
//┃  08. STATE RESET LOGIC                                                   ┃
//┃                                                                          ┃
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if not na(ph1)
    bullLb1 := na
    bullPx1 := na
    bullBar1 := na

if not na(pl1)
    bearLb1 := na
    bearPx1 := na
    bearBar1 := na


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┃                                                                          ┃
//┃  09. STRUCTURE EVENT CLASSIFICATION                                      ┃
//┃                                                                          ┃
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bullTxt1 = structText(os1, true)
bearTxt1 = structText(os1, false)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┃                                                                          ┃
//┃  10. KALMAN ADAPTIVE FLOW ENGINE                                         ┃
//┃                                                                          ┃
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
structureImpulse  = bullBreak1 ? 1.0 : bearBreak1 ? -1.0 : 0.0
structureActivity = ta.rma(math.abs(structureImpulse), 20)
structureBias     = ta.rma(structureImpulse, 20)

[kMain, kSlow] = f_kalman_pair(close, kalmanMainQ, kalmanMainR, kalmanSlowQ, kalmanSlowR)
kalmanSlope = kMain - kMain[1]

weightSum = math.max(structureWeight, 0.0001)
adapt     = math.min(1.0, (structureActivity * structureWeight) / weightSum)
alpha     = aSlow + (aFast - aSlow) * adapt

mid = na(hi1) or na(lo1) ? na : (hi1 + lo1) / 2.0
anchW = 0.20 * structureActivity

m1 = 1.36
m2 = 1.18
m3 = 1.0
m4 = 0.82
m5 = 0.64

a1 = clamp01(alpha * m1)
a2 = clamp01(alpha * m2)
a3 = clamp01(alpha * m3)
a4 = clamp01(alpha * m4)
a5 = clamp01(alpha * m5)

p1 = pushFac * m1
p2 = pushFac * m2
p3 = pushFac * m3
p4 = pushFac * m4
p5 = pushFac * m5

var float b1 = na
var float b2 = na
var float b3 = na
var float b4 = na
var float b5 = na

atr = ta.atr(14)

kalmanAgree =
     structureBias > 0 and kMain > kSlow ? 1.0 :
     structureBias < 0 and kMain < kSlow ? 1.0 :
     disagreeFactor

b1 := na(b1[1]) ? kMain : b1[1] + a1 * (kMain - b1[1])
b2 := na(b2[1]) ? kMain : b2[1] + a2 * (kMain - b2[1])
b3 := na(b3[1]) ? kMain : b3[1] + a3 * (kMain - b3[1])
b4 := na(b4[1]) ? kMain : b4[1] + a4 * (kMain - b4[1])
b5 := na(b5[1]) ? kMain : b5[1] + a5 * (kMain - b5[1])

b1 := b1 + p1 * structureBias * kalmanAgree * atr
b2 := b2 + p2 * structureBias * kalmanAgree * atr
b3 := b3 + p3 * structureBias * kalmanAgree * atr
b4 := b4 + p4 * structureBias * kalmanAgree * atr
b5 := b5 + p5 * structureBias * kalmanAgree * atr

b1 := not na(mid) ? b1 + anchW * (mid - b1) : b1
b2 := not na(mid) ? b2 + anchW * (mid - b2) : b2
b3 := not na(mid) ? b3 + anchW * (mid - b3) : b3
b4 := not na(mid) ? b4 + anchW * (mid - b4) : b4
b5 := not na(mid) ? b5 + anchW * (mid - b5) : b5

avgMain = b3

flowUpper = avgMain + atr * flowBoundaryMult
flowLower = avgMain - atr * flowBoundaryMult

baselineSlopeBull = avgMain > avgMain[1]
baselineSlopeBear = avgMain < avgMain[1]

bullShiftRaw = close > flowUpper and (not useSlopeConfirm or baselineSlopeBull)
bearShiftRaw = close < flowLower and (not useSlopeConfirm or baselineSlopeBear)

var int macroTrend = 0

if macroTrend == 0
    macroTrend := close >= avgMain ? 1 : -1
else if bullShiftRaw
    macroTrend := 1
else if bearShiftRaw
    macroTrend := -1
else
    macroTrend := macroTrend[1]

macroFlowLine = macroTrend == 1 ? flowLower : flowUpper
macroTrendFlip = macroTrend != macroTrend[1] and macroTrend[1] != 0
macroBullFlip = macroTrend == 1 and macroTrend[1] == -1
macroBearFlip = macroTrend == -1 and macroTrend[1] == 1
macroTrendCol = macroTrend == 1 ? bullCol : bearCol
nearTrail = math.abs(close - macroFlowLine) < atr * proxDist

plot(showKalmanBasis ? avgMain : na, "Flow Basis", color = color.new(neutralCol, 0), linewidth = 2)
plot(showFlowBands ? flowUpper : na, "Upper Flow Boundary", color = color.new(bearCol, 70), linewidth = 1)
plot(showFlowBands ? flowLower : na, "Lower Flow Boundary", color = color.new(bullCol, 70), linewidth = 1)

pMacroFlow = plot(showFlowTrail and not macroTrendFlip ? macroFlowLine : na,
     "Adaptive Trail",
     color.new(macroTrendCol, 0),
     trailWidth,
     plot.style_linebr)

pMacroGlow = plot(showFlowTrail and not macroTrendFlip ? macroFlowLine : na,
     "Adaptive Trail Glow",
     color.new(macroTrendCol, glowTransp),
     glowWidth,
     plot.style_linebr)

pMacroPrice = plot(hl2, display = display.none, editable = false)

fillTopVal = math.max(hl2, macroFlowLine)
fillBtmVal = math.min(hl2, macroFlowLine)

fillTopCol = macroTrend == 1 ? color.new(macroTrendCol, 100) : color.new(macroTrendCol, 70)
fillBtmCol = macroTrend == 1 ? color.new(macroTrendCol, 70) : color.new(macroTrendCol, 100)

fill(
     pMacroFlow,
     pMacroPrice,
     fillTopVal,
     fillBtmVal,
     showBoundaryFill ? fillTopCol : color.new(macroTrendCol, 100),
     showBoundaryFill ? fillBtmCol : color.new(macroTrendCol, 100),
     "Trail Fill"
)

var line macroTip = na

if showTipLine and showFlowTrail and not na(macroFlowLine) and not na(macroFlowLine[1]) and macroTrend == macroTrend[1]
    line.delete(macroTip)
    macroTip := line.new(
         bar_index - 1,
         macroFlowLine[1],
         bar_index,
         macroFlowLine,
         color = macroTrendCol,
         width = trailWidth,
         style = nearTrail ? line.style_dashed : line.style_solid)

var label macroTrailStar = label.new(
     na,
     na,
     "",
     color = #00000000,
     textcolor = macroTrendCol,
     style = label.style_label_center,
     size = size.normal)

if barstate.islast and showTrailStar and not na(macroFlowLine)
    label.set_xy(macroTrailStar, bar_index, macroFlowLine)
    label.set_text(macroTrailStar, nearTrail ? "✦" : "✪")
    label.set_textcolor(macroTrailStar, nearTrail ? warningCol : macroTrendCol)
    label.set_size(macroTrailStar, size.normal)
else if barstate.islast
    label.set_xy(macroTrailStar, na, na)

plotshape(showFlipDiamonds and macroBullFlip ? macroFlowLine : na, "Bull Trail Flip", shape.diamond, location.absolute, bullCol, size = size.small)
plotshape(showFlipDiamonds and macroBearFlip ? macroFlowLine : na, "Bear Trail Flip", shape.diamond, location.absolute, bearCol, size = size.small)

barcolor(paintBars ? color.new(macroTrendCol, 10) : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┃                                                                          ┃
//┃  11. ADAPTIVE RANGE LEVELS                                               ┃
//┃      Wick-anchored highs/lows with Volumatic strength ranking            ┃
//┃                                                                          ┃
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
rangeHi = ta.highest(high, rangeLookback)
rangeLo = ta.lowest(low, rangeLookback)
rangeHiOffset = math.abs(ta.highestbars(high, rangeLookback))
rangeLoOffset = math.abs(ta.lowestbars(low, rangeLookback))
rangeHiBar = bar_index - rangeHiOffset
rangeLoBar = bar_index - rangeLoOffset
rangeSpan = rangeHi - rangeLo
rangeFrac = rangeZonePct / 100.0
rangeHighLevel = rangeHi
rangeHighZoneBottom = rangeHi - rangeSpan * rangeFrac
rangeLowZoneTop = rangeLo + rangeSpan * rangeFrac
rangeLowLevel = rangeLo
[rangeBullVol, rangeBearVol, rangeDelta] = fVolPressure(rangeLookback)
[rangeHighRank, rangeLowRank] = fRangeRanks(macroTrend, rangeDelta)

rangeLabelX = bar_index + rangeRightOffset
activeRank = macroTrend > 0 ? rangeLowRank : rangeHighRank
activeLevel = macroTrend > 0 ? rangeLowLevel : rangeHighLevel
activeSourceBar = macroTrend > 0 ? rangeLoBar : rangeHiBar
activeZoneTop = macroTrend > 0 ? rangeLowZoneTop : rangeHighLevel
activeZoneBottom = macroTrend > 0 ? rangeLowLevel : rangeHighZoneBottom
targetLevel = macroTrend > 0 ? rangeHighLevel : rangeLowLevel
targetSourceBar = macroTrend > 0 ? rangeHiBar : rangeLoBar
activeBaseColor = macroTrend > 0 ? poiBullCol : poiBearCol
activeRankColor = fRankColor(activeRank, activeBaseColor)
targetColor = macroTrend > 0 ? poiBearCol : poiBullCol
activeLevelText = fActiveLevelText(macroTrend, rangeHighRank, rangeLowRank)
activePoiText = fRangePoiText(macroTrend)
activeTargetText = fRangeTargetText(macroTrend)
activeDeltaText = showVolDelta ? "  Δ " + fDeltaText(rangeDelta) : ""

if showRangeLevels and rangeSpan > 0 and macroTrend != 0
    if showRangePoi
        if na(rangePoiBox)
            rangePoiBox := box.new(
                 activeSourceBar,
                 activeZoneTop,
                 bar_index,
                 activeZoneBottom,
                 xloc = xloc.bar_index,
                 bgcolor = color.new(activeBaseColor, poiTransp),
                 border_color = color.new(activeRankColor, 50),
                 border_style = line.style_dashed,
                 text = activePoiText,
                 text_size = size.tiny,
                 text_color = activeRankColor,
                 text_halign = text.align_center,
                 text_valign = text.align_center)
        else
            box.set_left(rangePoiBox, activeSourceBar)
            box.set_right(rangePoiBox, bar_index)
            box.set_top(rangePoiBox, activeZoneTop)
            box.set_bottom(rangePoiBox, activeZoneBottom)
            box.set_bgcolor(rangePoiBox, color.new(activeBaseColor, poiTransp))
            box.set_border_color(rangePoiBox, color.new(activeRankColor, 50))
            box.set_text(rangePoiBox, activePoiText)
            box.set_text_color(rangePoiBox, activeRankColor)
    else if not na(rangePoiBox)
        box.delete(rangePoiBox)
        rangePoiBox := na

    if showStrengthLine
        if na(rangeStrengthLine)
            rangeStrengthLine := line.new(activeSourceBar, activeLevel, rangeLabelX, activeLevel, xloc = xloc.bar_index, color = activeRankColor, style = rangeStyle, width = rangeWidth)
        else
            line.set_xy1(rangeStrengthLine, activeSourceBar, activeLevel)
            line.set_xy2(rangeStrengthLine, rangeLabelX, activeLevel)
            line.set_color(rangeStrengthLine, activeRankColor)
            line.set_style(rangeStrengthLine, rangeStyle)
            line.set_width(rangeStrengthLine, rangeWidth)
    else if not na(rangeStrengthLine)
        line.delete(rangeStrengthLine)
        rangeStrengthLine := na

    if showStrengthLabel
        if na(rangeStrengthLabel)
            rangeStrengthLabel := label.new(rangeLabelX, activeLevel, activeLevelText + activeDeltaText, xloc = xloc.bar_index, color = color(na), textcolor = activeRankColor, style = label.style_label_left, size = rangeLabelSize)
        else
            label.set_xy(rangeStrengthLabel, rangeLabelX, activeLevel)
            label.set_text(rangeStrengthLabel, activeLevelText + activeDeltaText)
            label.set_textcolor(rangeStrengthLabel, activeRankColor)
            label.set_style(rangeStrengthLabel, label.style_label_left)
            label.set_size(rangeStrengthLabel, rangeLabelSize)
    else if not na(rangeStrengthLabel)
        label.delete(rangeStrengthLabel)
        rangeStrengthLabel := na

    if showRangeTarget
        if na(rangeTargetLine)
            rangeTargetLine := line.new(targetSourceBar, targetLevel, rangeLabelX, targetLevel, xloc = xloc.bar_index, color = color.new(targetColor, 28), style = line.style_dotted, width = math.max(1, rangeWidth - 1))
        else
            line.set_xy1(rangeTargetLine, targetSourceBar, targetLevel)
            line.set_xy2(rangeTargetLine, rangeLabelX, targetLevel)
            line.set_color(rangeTargetLine, color.new(targetColor, 28))
            line.set_style(rangeTargetLine, line.style_dotted)
            line.set_width(rangeTargetLine, math.max(1, rangeWidth - 1))

        if na(rangeTargetLabel)
            rangeTargetLabel := label.new(rangeLabelX, targetLevel, activeTargetText, xloc = xloc.bar_index, color = color(na), textcolor = targetColor, style = label.style_label_left, size = rangeLabelSize)
        else
            label.set_xy(rangeTargetLabel, rangeLabelX, targetLevel)
            label.set_text(rangeTargetLabel, activeTargetText)
            label.set_textcolor(rangeTargetLabel, targetColor)
            label.set_style(rangeTargetLabel, label.style_label_left)
            label.set_size(rangeTargetLabel, rangeLabelSize)
    else
        if not na(rangeTargetLine)
            line.delete(rangeTargetLine)
            rangeTargetLine := na
        if not na(rangeTargetLabel)
            label.delete(rangeTargetLabel)
            rangeTargetLabel := na
else
    if not na(rangePoiBox)
        box.delete(rangePoiBox)
        rangePoiBox := na
    if not na(rangeStrengthLine)
        line.delete(rangeStrengthLine)
        rangeStrengthLine := na
    if not na(rangeTargetLine)
        line.delete(rangeTargetLine)
        rangeTargetLine := na
    if not na(rangeStrengthLabel)
        label.delete(rangeStrengthLabel)
        rangeStrengthLabel := na
    if not na(rangeTargetLabel)
        label.delete(rangeTargetLabel)
        rangeTargetLabel := na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┃                                                                          ┃
//┃  07. HIGHER TIMEFRAME ENGINE                                             ┃
//┃                                                                          ┃
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
htfAvg = request.security(syminfo.tickerid, htfTf, fCoreTrail(), barmerge.gaps_off, barmerge.lookahead_off)
plot(showHtfLine ? htfAvg : na, "HTF Kalman Basis", color = color.new(color.yellow, 0), linewidth = 2, style = plot.style_line)

[mtfState1, mtfHighRank1, mtfLowRank1, mtfDelta1] = request.security(syminfo.tickerid, mtf1, fRangeState(), barmerge.gaps_off, barmerge.lookahead_off)
[mtfState2, mtfHighRank2, mtfLowRank2, mtfDelta2] = request.security(syminfo.tickerid, mtf2, fRangeState(), barmerge.gaps_off, barmerge.lookahead_off)
[mtfState3, mtfHighRank3, mtfLowRank3, mtfDelta3] = request.security(syminfo.tickerid, mtf3, fRangeState(), barmerge.gaps_off, barmerge.lookahead_off)
[mtfState4, mtfHighRank4, mtfLowRank4, mtfDelta4] = request.security(syminfo.tickerid, mtf4, fRangeState(), barmerge.gaps_off, barmerge.lookahead_off)
[mtfState5, mtfHighRank5, mtfLowRank5, mtfDelta5] = request.security(syminfo.tickerid, mtf5, fRangeState(), barmerge.gaps_off, barmerge.lookahead_off)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┃                                                                          ┃
//┃  13. STRUCTURE GUIDE DRAWINGS                                            ┃
//┃                                                                          ┃
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[tmpBullLb1, tmpBullPx1, tmpBullBar1] = drawStruct(
    true, bullBreak1, hiBar1, hi1, bullTxt1, colS1Up, colS1Up, styS1, widS1, showS1Ln, showS1Lb, bullLb1, bullPx1, bullBar1, labS1)

bullLb1 := tmpBullLb1
bullPx1 := tmpBullPx1
bullBar1 := tmpBullBar1

[tmpBearLb1, tmpBearPx1, tmpBearBar1] = drawStruct(
    false, bearBreak1, loBar1, lo1, bearTxt1, colS1Dn, colS1Dn, styS1, widS1, showS1Ln, showS1Lb, bearLb1, bearPx1, bearBar1, labS1)

bearLb1 := tmpBearLb1
bearPx1 := tmpBearPx1
bearBar1 := tmpBearBar1

if bullBreak1
    os1 := 1
if bearBreak1
    os1 := -1

if bullBreak1
    hi1 := na
    hiBar1 := na
    bullPx1 := na
    bullBar1 := na
    bullLb1 := na
    if bullTxt1 == "MSS"
        lo1 := na
        loBar1 := na
        bearPx1 := na
        bearBar1 := na
        bearLb1 := na

if bearBreak1
    lo1 := na
    loBar1 := na
    bearPx1 := na
    bearBar1 := na
    bearLb1 := na
    if bearTxt1 == "MSS"
        hi1 := na
        hiBar1 := na
        bullPx1 := na
        bullBar1 := na
        bullLb1 := na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┃                                                                          ┃
//┃  15. DASHBOARD                                                           ┃
//┃                                                                          ┃
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
htfState = na(htfAvg) ? 0 : close > htfAvg ? 1 : close < htfAvg ? -1 : 0

if showTable
    var table tb = table.new(
         tablePos,
         6,
         5,
         bgcolor = color.new(color.black, 84),
         frame_color = color.new(color.white, 70),
         frame_width = 1,
         border_color = color.new(color.white, 88),
         border_width = 1)

    if barstate.isfirst
        table.merge_cells(tb, 0, 0, 5, 0)
        table.merge_cells(tb, 1, 3, 5, 3)
        table.merge_cells(tb, 1, 4, 5, 4)

    rowHeadBg = color.new(color.white, 94)
    rowBg1 = color.new(color.white, 97)
    rowBg2 = color.new(color.white, 100)
    labelCol = color.new(color.white, 0)
    softCol = color.new(color.white, 22)

    flowCol = macroTrend > 0 ? bullCol : macroTrend < 0 ? bearCol : neutralCol
    momState = fSign(kalmanSlope)
    flowSummaryCol = fSign(macroTrend) == momState ? flowCol : warningCol

    rangeText = macroTrend > 0 ? "Bull Range" : macroTrend < 0 ? "Bear Range" : "Building"
    rangeCol = macroTrend > 0 ? fRankColor(rangeLowRank, poiBullCol) :
         macroTrend < 0 ? fRankColor(rangeHighRank, poiBearCol) : neutralCol

    titleText = "KFT • " + syminfo.ticker + " • " + fTfLabel(timeframe.period) + "   " + str.tostring(close, format.mintick) + " " + syminfo.currency
    table.cell(tb, 0, 0, titleText, text_color = color.white, text_size = tableTxtSize, text_halign = text.align_left, bgcolor = rowHeadBg)

    table.cell(tb, 0, 1, "period", text_color = labelCol, text_size = tableTxtSize, text_halign = text.align_left, bgcolor = rowBg1)
    table.cell(tb, 1, 1, fTfLabel(mtf1), text_color = softCol, text_size = tableTxtSize, text_halign = text.align_center, bgcolor = rowBg1)
    table.cell(tb, 2, 1, fTfLabel(mtf2), text_color = softCol, text_size = tableTxtSize, text_halign = text.align_center, bgcolor = rowBg1)
    table.cell(tb, 3, 1, fTfLabel(mtf3), text_color = softCol, text_size = tableTxtSize, text_halign = text.align_center, bgcolor = rowBg1)
    table.cell(tb, 4, 1, fTfLabel(mtf4), text_color = softCol, text_size = tableTxtSize, text_halign = text.align_center, bgcolor = rowBg1)
    table.cell(tb, 5, 1, fTfLabel(mtf5), text_color = softCol, text_size = tableTxtSize, text_halign = text.align_center, bgcolor = rowBg1)

    table.cell(tb, 0, 2, "trend", text_color = labelCol, text_size = tableTxtSize, text_halign = text.align_left, bgcolor = rowBg2)
    table.cell(tb, 1, 2, fTrendIcon(mtfState1), text_color = fTrendCol(mtfState1), text_size = tableTxtSize, text_halign = text.align_center, bgcolor = rowBg2)
    table.cell(tb, 2, 2, fTrendIcon(mtfState2), text_color = fTrendCol(mtfState2), text_size = tableTxtSize, text_halign = text.align_center, bgcolor = rowBg2)
    table.cell(tb, 3, 2, fTrendIcon(mtfState3), text_color = fTrendCol(mtfState3), text_size = tableTxtSize, text_halign = text.align_center, bgcolor = rowBg2)
    table.cell(tb, 4, 2, fTrendIcon(mtfState4), text_color = fTrendCol(mtfState4), text_size = tableTxtSize, text_halign = text.align_center, bgcolor = rowBg2)
    table.cell(tb, 5, 2, fTrendIcon(mtfState5), text_color = fTrendCol(mtfState5), text_size = tableTxtSize, text_halign = text.align_center, bgcolor = rowBg2)

    table.cell(tb, 0, 3, "flow", text_color = labelCol, text_size = tableTxtSize, text_halign = text.align_left, bgcolor = rowBg1)
    table.cell(tb, 1, 3, "Trail: " + fBiasText(macroTrend) + "   •   Kal: " + fBiasText(kalmanSlope), text_color = flowSummaryCol, text_size = tableTxtSize, text_halign = text.align_left, bgcolor = rowBg1)

    table.cell(tb, 0, 4, "range", text_color = labelCol, text_size = tableTxtSize, text_halign = text.align_left, bgcolor = rowBg2)
    table.cell(tb, 1, 4, rangeText, text_color = rangeCol, text_size = tableTxtSize, text_halign = text.align_left, bgcolor = rowBg2)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//┃                                                                          ┃
//┃  16. ALERTS                                                              ┃
//┃                                                                          ┃
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(macroBullFlip, title = "Bull Trail Flip", message = "Kalman Flow Trail shifted bullish on {{ticker}}")
alertcondition(macroBearFlip, title = "Bear Trail Flip", message = "Kalman Flow Trail shifted bearish on {{ticker}}")
````

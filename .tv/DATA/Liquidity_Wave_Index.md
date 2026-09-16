<!-- tradingview-pine-id: PUB;a698a95c04b04df6a304bb34f58436c3 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Liquidity Wave Index

Source: https://www.tradingview.com/script/msfc9aQZ-Liquidity-Wave-Index/

## Description

Liquidity Wave Index is a momentum, pressure and divergence oscillator designed to combine three related forms of market information in one pane:

* OHLCV-based directional pressure
* An adaptive market-cycle oscillator
* Price-versus-oscillator divergence

The purpose of combining these components is to separate directional pressure from cycle timing. The Liquidity Pressure histogram shows whether candle structure and reported volume are contributing more positively or negatively, while the Cycle Engine measures normalized price displacement and momentum rotation. Divergence analysis then compares confirmed price swings with confirmed oscillator swings to identify disagreement between price structure and momentum.

The components can be used independently or combined through optional confirmation filters.

LIQUIDITY PRESSURE

Liquidity Pressure is an OHLCV-derived analytical measure.

For each candle, directional pressure begins with the candle body relative to the full candle range:

(close - open) / (high - low)

This value is multiplied by reported volume, smoothed with an EMA, and then normalized by smoothed volume.

The Scale input changes the displayed magnitude without changing the underlying directional relationship.

Positive values indicate that the recent combination of candle direction, candle range and reported volume is weighted toward positive pressure.

Negative values indicate the opposite.

This is not true bid/ask delta, order-book data or exchange trade-direction data. It is an OHLCV-based approximation derived from chart data, and volume characteristics may differ between symbols, exchanges and data providers.

ADAPTIVE CYCLE ENGINE

The Cycle Engine is based on an adaptive WaveTrend-style framework.

The selected price source, HLC3 by default, is compared with an adaptive EMA baseline. Price displacement from that baseline is normalized using an adaptively smoothed measure of absolute deviation.

The resulting normalized oscillator is then adaptively smoothed into:

Cycle Line
Signal Line

The adaptive smoothing rate changes according to recent price movement rather than remaining completely fixed.

Additional EMA smoothing is applied through the Ribbon Smooth setting.

The ribbon between the two lines visually represents the current relationship between the Cycle Line and Signal Line.

BULL AND BEAR SIGNALS

A Bull signal occurs when the Cycle Line crosses above the Signal Line.

A Bear signal occurs when the Cycle Line crosses below the Signal Line.

Signals are only accepted on confirmed bars. A crossover that appears temporarily while the current candle is still forming will therefore not become a confirmed signal unless the crossover remains present when the candle closes.

The Threshold Filter and Liquidity Pressure Confirmation settings can optionally make these signals more selective.

THRESHOLD FILTER

With the Threshold Filter enabled:

Bull signals require the Cycle Line to be below the negative threshold when the bullish cross occurs.

Bear signals require the Cycle Line to be above the positive threshold when the bearish cross occurs.

The threshold does not represent probability, expected performance or a statistically defined overbought/oversold level. It is a user-controlled signal filter.

LIQUIDITY PRESSURE CONFIRMATION

Liquidity Pressure Confirmation optionally connects the pressure module directly to the Bull and Bear Cycle signals.

Three modes are available:

Off

Liquidity Pressure does not affect Bull or Bear signals.

This is the default setting.

Same Direction

A Bull Cycle cross is only accepted when Liquidity Pressure is above zero.

A Bear Cycle cross is only accepted when Liquidity Pressure is below zero.

This mode requires pressure to agree with the direction of the Cycle signal.

Zero Cross

A Bull Cycle cross is only accepted when Liquidity Pressure crosses above zero on the same confirmed candle.

A Bear Cycle cross is only accepted when Liquidity Pressure crosses below zero on the same confirmed candle.

This is the most restrictive mode because both the Cycle cross and Liquidity Pressure zero-line cross must occur together.

Liquidity Pressure Confirmation is a directional filter. It does not represent probability, expected accuracy or guaranteed signal quality.

DIVERGENCES

The indicator detects divergence by comparing confirmed price pivots with nearby confirmed Cycle Line pivots.

Regular bullish divergence occurs when price forms a lower low while the matched oscillator structure forms a higher low.

Regular bearish divergence occurs when price forms a higher high while the matched oscillator structure forms a lower high.

Hidden divergence can optionally be enabled.

Hidden bullish divergence compares a higher price low with a lower oscillator low.

Hidden bearish divergence compares a lower price high with a higher oscillator high.

Regular and hidden divergences are calculated independently so enabling hidden divergences does not replace the regular divergence calculation.

Regular Bull, Regular Bear, Hidden Bull and Hidden Bear divergence colors can be configured independently.

PIVOT MATCHING

Price pivots and oscillator pivots do not always occur on exactly the same candle.

The Max Price/Osc Pivot Gap setting determines how far apart a confirmed price pivot and oscillator pivot may be while still being treated as a matched swing.

The divergence engine stores several recent matched pivot pairs rather than comparing only the immediately previous swing. This allows the detector to identify divergence structures that may span an intermediate pivot.

Min Bars Between Price Pivots and Max Bars Between Price Pivots control the permitted distance between the two price swings being compared.

DIVERGENCE PRESETS

Aggressive

Uses shorter pivots and allows a larger price-to-oscillator pivot gap. This generally produces more divergence detections and reacts more quickly.

Balanced

The default profile and intended general-purpose setting.

Conservative

Uses stronger pivots, requires wider swing separation and allows a smaller price-to-oscillator matching gap. This generally produces fewer but more structurally developed divergence detections.

Custom

Uses the manually configured Pivot Length, Min Bars, Max Bars and Max Price/Osc Pivot Gap values.

ZERO-LINE CONTEXT

Require Zero-Line Context is an optional divergence filter.

When enabled:

Bullish divergences require both oscillator pivot values to be at or below zero.

Bearish divergences require both oscillator pivot values to be at or above zero.

This can be used to restrict divergence detection to the corresponding side of the oscillator.

IMPORTANT PIVOT CONFIRMATION BEHAVIOUR

Divergence detection uses confirmed pivots.

A pivot cannot be known when the actual swing high or swing low first occurs. It becomes confirmed only after the required number of bars to the right of that swing have completed.

For example, with Pivot Length 4, a pivot is confirmed four bars after the historical pivot candle.

Divergence lines are drawn between the actual historical pivot locations after confirmation.

Their historical placement therefore does not mean the divergence was available on the earlier pivot candle.

Any divergence alert occurs when the divergence becomes confirmed, not when the earlier pivot originally formed.

This confirmation delay is an inherent part of pivot-based divergence detection.

TARGET / STOP STATISTICS

The tables provide simplified historical Target/Stop outcome statistics for confirmed Cycle signals and confirmed divergence events.

They are not TradingView Strategy Tester results and do not simulate actual orders.

For a confirmed Bull Cycle signal:

The confirmation-bar close is used as the reference price.

The Target is placed above that reference price according to the Target % input.

The Stop is placed below the reference price according to the Stop % input.

For a confirmed Bear signal, the directions are reversed.

Divergence outcomes use the same principle with the separate Div Target % and Div Stop % settings.

Outcome checking begins on the bar after the signal or divergence confirmation.

Price movement occurring earlier on the confirmation candle is therefore not used to determine the result.

Every confirmed event is tracked independently. A new event does not overwrite an unresolved previous event.

If both the Target and Stop are touched during the same candle, the Stop is counted first.

This is a conservative assumption because the script does not have access to the exact intrabar price sequence from standard OHLC bars.

T represents Target reached.

S represents Stop reached.

The percentage shown beside these counts represents:

Targets / (Targets + Stops) x 100

Only resolved events are included in that percentage. Events that have not yet reached either level remain unresolved and are not counted as either Target or Stop.

STATISTICS LIMITATIONS

The Target/Stop statistics are simplified historical measurements.

They do not model:

Commissions
Spread
Slippage
Liquidity
Position sizing
Order execution
Market impact
Partial fills
Funding costs
Intrabar execution sequence

They should therefore not be interpreted as strategy profitability, expected win probability or future performance.

Historical outcomes do not imply future results.

ALERTS

Alerts are available for:

Bullish Cycle Cross
Bearish Cycle Cross
Bullish Divergence
Bearish Divergence
Liquidity Pressure crossing above zero
Liquidity Pressure crossing below zero

Cycle and Liquidity Pressure alerts use confirmed bars.

When Liquidity Pressure Confirmation is enabled, Bull and Bear Cycle alerts follow the filtered Bull/Bear signal conditions.

Divergence alerts depend on confirmed pivots and therefore include the pivot confirmation delay described above.

HOW TO USE

A practical workflow is to use the Cycle Engine for timing, Liquidity Pressure for directional context and divergence for potential disagreement between price and momentum.

Example bullish workflow:

Look for improving or positive Liquidity Pressure.

Watch for bullish regular or hidden divergence.

Wait for a confirmed bullish Cycle Line cross.

Optionally enable Same Direction Liquidity Pressure Confirmation if Bull signals should only occur while pressure is positive.

Use Zero Cross mode if a Bull signal should only occur when both the Cycle cross and Liquidity Pressure transition above zero happen together.

The optional Threshold Filter can further restrict Bull crosses to deeper negative oscillator conditions.

Example bearish workflow:

Look for deteriorating or negative Liquidity Pressure.

Watch for bearish regular or hidden divergence.

Wait for a confirmed bearish Cycle Line cross.

Optionally enable Same Direction Liquidity Pressure Confirmation if Bear signals should only occur while pressure is negative.

Use Zero Cross mode if a Bear signal should only occur when both the Cycle cross and Liquidity Pressure transition below zero happen together.

The optional Threshold Filter can further restrict Bear crosses to higher positive oscillator conditions.

These components do not need to align on every setup unless the user deliberately enables the available confirmation filters.

TIMEFRAMES

The indicator can be used on different chart timeframes, but the default settings are primarily intended as a general-purpose starting point around the 15-minute to 1-hour range.

15-minute charts provide a relatively responsive balance between Cycle signals, Liquidity Pressure and swing structure.

1-hour charts generally produce slower and cleaner pivot structures.

Lower timeframes such as 1-minute to 5-minute charts usually contain considerably more market noise and may require different divergence or smoothing settings.

Higher timeframes produce fewer signals and substantially longer pivot-confirmation delays.

IMPORTANT SETTINGS

Smoothing Length

Controls smoothing of the Liquidity Pressure calculation. Higher values produce a smoother and slower histogram.

Scale

Changes the displayed magnitude of Liquidity Pressure.

Base Length

Controls the adaptive baseline used by the Cycle Engine.

Slow Length

Controls smoothing of the primary Cycle calculation.

Adaptation Lookback

Controls the lookback used to adjust adaptive EMA responsiveness.

Fast Lag / Slow Lag

Control the adaptive response characteristics of the Cycle Line and Signal Line.

Ribbon Smooth

Adds final EMA smoothing to the displayed Cycle lines.

Threshold Filter

Optionally requires Cycle crosses to occur beyond the selected positive or negative threshold.

Liquidity Pressure Confirmation

Determines whether Liquidity Pressure is ignored, must already agree with signal direction, or must cross zero on the same candle as the Cycle signal.

Pivot Length

Controls pivot confirmation strength. Larger values require more bars to confirm a swing and therefore increase confirmation delay.

Max Price/Osc Pivot Gap

Controls how far apart price and oscillator pivots may occur while still being matched.

Regular Bull / Regular Bear Color

Control the colors of regular divergence lines.

Hidden Bull / Hidden Bear Color

Control the colors of hidden divergence lines.

Target % / Stop %

Define the virtual outcome levels used by the Cycle signal statistics.

Div Target % / Div Stop %

Define the virtual outcome levels used by the divergence statistics.

LIMITATIONS

Liquidity Pressure is calculated from OHLCV data and is not true order-flow or bid/ask delta.

Volume availability and quality vary between markets and data providers.

Adaptive smoothing introduces some lag.

Pivot-based divergences require future bars for confirmation.

Divergence lines are drawn back to the historical pivot positions only after those pivots have been confirmed.

Divergence does not necessarily produce a reversal.

Current market conditions can differ substantially from historical conditions.

Target/Stop tables are simplified analytical statistics and are not execution-based backtests.

Same Direction and Zero Cross confirmation modes reduce the number of Cycle signals and can cause signals visible with confirmation Off to disappear.

The indicator should be used as an analytical tool rather than as a prediction or guarantee of future market direction.

CODE ORIGIN AND ATTRIBUTION

The adaptive cycle foundation of Liquidity Wave Index was developed from the open-source Wave Oscillator by Claye Weight, used under the Mozilla Public License 2.0.

Liquidity Wave Index substantially extends that foundation with an OHLCV-based normalized pressure module, optional Liquidity Pressure signal confirmation, confirmed-bar signal handling, rewritten pivot-based divergence detection, price/oscillator pivot matching, independent regular and hidden divergence processing, configurable divergence presets, separate divergence colors, independent Target/Stop outcome tracking and configurable statistics tables.

The complete source code of this publication is provided openly in accordance with the applicable open-source licence.

---

## Source Code

````pine
//@version=6
indicator("Liquidity Wave Index", "LWI", overlay=false, max_lines_count=500, max_labels_count=300, explicit_plot_zorder=true)

//==================================================================================================
// INPUTS
//==================================================================================================
grpFlow   = "1) Liquidity Pressure"
grpCycle  = "2) Cycle Engine"
grpDiv    = "3) Divergence"
grpSig    = "4) Signals"
grpViz    = "5) Visuals"
grpStats  = "6) Stats & Tables"
grpAlerts = "7) Alerts"

// --- Tooltips
// Liquidity Pressure
string ttShowFlow  = "Show/hide the Liquidity Pressure histogram."
string ttFlowLen   = "EMA smoothing length for raw liquidity pressure. Higher = smoother and slower."
string ttFlowScale = "Scales the normalized pressure output for easier visual inspection."

// Cycle Engine
string ttCycleSrc      = "Price source used by the adaptive cycle engine."
string ttBaseLen       = "Base adaptive smoothing length for the cycle baseline."
string ttSlowLen       = "Smoothing length for the cycle line before signal derivation."
string ttAdaptLookback = "Lookback used to normalize adaptive EMA responsiveness."
string ttFastLag       = "Adaptive lag used on the primary cycle line."
string ttSlowLag       = "Adaptive lag used on the signal line."

// Divergence Settings
string ttShowDiv       = "Enable/disable divergence detection."
string ttShowDivTable  = "Show divergence win/loss stats tables."
string ttDivTpPct      = "Virtual target percent used for divergence outcome tracking. Tracking starts on the bar after confirmation; if Target and Stop are both touched on the same bar, SL is counted first."
string ttDivSlPct      = "Virtual stop-loss percent used for divergence outcome tracking. Tracking starts on the bar after confirmation; if Target and Stop are both touched on the same bar, SL is counted first."
string ttDivPreset     = "Preset profile for divergence sensitivity. Custom uses the manual settings below."
string ttDivPivotLen   = "Pivot strength used to detect swing highs/lows for divergence."
string ttDivMinBars    = "Minimum bars between two price pivots used in a divergence."
string ttDivMaxBars    = "Maximum bars between two price pivots used in a divergence."
string ttDivMaxOscGap  = "Maximum bar distance allowed between a price pivot and its matching oscillator pivot."
string ttDivRequireZero = "Require bullish divergences below zero and bearish divergences above zero."
string ttDivHidden     = "Also detect hidden bullish/bearish divergences."
string ttShowDivOsc    = "Draw divergence lines in the oscillator pane."
string ttShowDivChart  = "Draw divergence lines on the main price chart."
string ttDivLineWidth  = "Line width for divergence drawings."

// Signals
string ttUseThreshold = "Require crosses to occur beyond +/- threshold zones."
string ttThresh       = "Absolute threshold level used by the filter."
string ttShowBands    = "Show/hide horizontal threshold guide lines."
string ttFlowConfirm  = "Optional Liquidity Pressure confirmation for Bull/Bear cycle signals. Off = no pressure filter. Same Direction = Bull requires pressure above zero and Bear requires pressure below zero. Zero Cross = pressure must cross zero in the matching direction on the same confirmed bar as the cycle cross."

// Visuals
string ttPalTealLine   = "Primary bullish line color."
string ttPalPinkLine   = "Primary bearish line color."
string ttPalTealSoft   = "Soft bullish fill color used for ribbon/filters."
string ttPalPinkSoft   = "Soft bearish fill color used for ribbon/filters."
string ttShowBG        = "Enable gradient background split around zero."
string ttBgTeal        = "Bullish side background color."
string ttBgPink        = "Bearish side background color."
string ttBgRange       = "Vertical range for background fills around zero."
string ttRibbonSmooth  = "EMA smoothing for ribbon transparency transitions."
string ttTablePreset   = "Changes table text color. Default uses white text. Black Text uses black text."

// Stats
string ttTpPct     = "Virtual target % used for cross signal win-rate stats. Tracking starts on the bar after confirmation; if Target and Stop are both touched on the same bar, SL is counted first."
string ttSlPct     = "Virtual stop-loss % used for cross signal win-rate stats. Tracking starts on the bar after confirmation; if Target and Stop are both touched on the same bar, SL is counted first."
string ttShowStats = "Show/hide bullish and bearish cross performance tables."

// Alerts
string ttAlCrossUp = "Enable runtime alert() for bullish cycle crosses."
string ttAlCrossDn = "Enable runtime alert() for bearish cycle crosses."
string ttAlDivUp   = "Enable runtime alert() for bullish divergences."
string ttAlDivDn   = "Enable runtime alert() for bearish divergences."
string ttAlFlowUp  = "Enable runtime alert() when flow crosses above zero."
string ttAlFlowDn  = "Enable runtime alert() when flow crosses below zero."

// Tables
string ttLongPos  = "Screen anchor for long stats table."
string ttShortPos = "Screen anchor for short stats table."
string ttBullPos  = "Screen anchor for bullish divergence table."
string ttBearPos  = "Screen anchor for bearish divergence table."

// --- Liquidity Pressure
showFlow      = input.bool(true,  "Show Liquidity Pressure Histogram", group=grpFlow, tooltip=ttShowFlow)
flowLen       = input.int(55,     "Smoothing Length", minval=1, group=grpFlow, tooltip=ttFlowLen)
flowScale     = input.float(120,  "Scale", step=1, group=grpFlow, tooltip=ttFlowScale)

// --- Cycle Engine
cycleSrc      = input.source(hlc3, "Source", group=grpCycle, tooltip=ttCycleSrc)
baseLen       = input.int(14,      "Base Length", minval=2, group=grpCycle, tooltip=ttBaseLen)
slowLen       = input.int(21,      "Slow Length", minval=2, group=grpCycle, tooltip=ttSlowLen)
adaptLookback = input.int(12,      "Adaptation Lookback", minval=1, group=grpCycle, tooltip=ttAdaptLookback)
fastLag       = input.int(4,       "Fast Lag", minval=1, group=grpCycle, tooltip=ttFastLag)
slowLag       = input.int(6,       "Slow Lag", minval=1, group=grpCycle, tooltip=ttSlowLag)

// --- Divergence
showDiv       = input.bool(true,   "Enable Divergence Detection", group=grpDiv, tooltip=ttShowDiv)
showDivTable  = input.bool(true,   "Show Divergence Table", group=grpDiv, tooltip=ttShowDivTable)
divTpPct      = input.float(2.0,   "Div Target %", minval=0.1, step=0.1, group=grpDiv, tooltip=ttDivTpPct)
divSlPct      = input.float(1.0,   "Div SL %", minval=0.1, step=0.1, group=grpDiv, tooltip=ttDivSlPct)

divPreset         = input.string("Balanced", "Divergence Preset", options=["Aggressive", "Balanced", "Conservative", "Custom"], group=grpDiv, tooltip=ttDivPreset)
divPivotLenInput  = input.int(4, "Pivot Length", minval=1, group=grpDiv, tooltip=ttDivPivotLen)
divMinBarsInput   = input.int(4, "Min Bars Between Price Pivots", minval=1, group=grpDiv, tooltip=ttDivMinBars)
divMaxBarsInput   = input.int(80, "Max Bars Between Price Pivots", minval=2, group=grpDiv, tooltip=ttDivMaxBars)
divMaxOscGapInput = input.int(10, "Max Price/Osc Pivot Gap", minval=0, group=grpDiv, tooltip=ttDivMaxOscGap)
divRequireZero    = input.bool(false, "Require Zero-Line Context", group=grpDiv, tooltip=ttDivRequireZero)
divUseHidden      = input.bool(false, "Enable Hidden Divergences", group=grpDiv, tooltip=ttDivHidden)
showDivOscLines   = input.bool(true, "Show Divergence Lines In Oscillator", group=grpDiv, tooltip=ttShowDivOsc)
showDivChartLines = input.bool(false, "Show Divergence Lines On Price Chart", group=grpDiv, tooltip=ttShowDivChart)
divLineWidth      = input.int(2, "Line Width", minval=1, maxval=5, group=grpDiv, tooltip=ttDivLineWidth)
regularBullColor   = input.color(color.new(#00e5ff, 0), "Regular Bull Color", group=grpDiv)
regularBearColor   = input.color(color.new(#ff00ff, 0), "Regular Bear Color", group=grpDiv)
hiddenBullColor    = input.color(color.new(color.lime, 0), "Hidden Bull Color", group=grpDiv)
hiddenBearColor    = input.color(color.new(color.orange, 0), "Hidden Bear Color", group=grpDiv)

divPivotLen = switch divPreset
    "Aggressive"   => 2
    "Balanced"     => 4
    "Conservative" => 6
    => divPivotLenInput

divMinBars = switch divPreset
    "Aggressive"   => 2
    "Balanced"     => 4
    "Conservative" => 8
    => divMinBarsInput

divMaxBars = switch divPreset
    "Aggressive"   => 50
    "Balanced"     => 80
    "Conservative" => 120
    => divMaxBarsInput

divMaxOscGap = switch divPreset
    "Aggressive"   => 14
    "Balanced"     => 10
    "Conservative" => 6
    => divMaxOscGapInput

// --- Signals
useThreshold  = input.bool(false,  "Use Threshold Filter", inline="sf", group=grpSig, tooltip=ttUseThreshold)
thresh        = input.int(10,      "", inline="sf", group=grpSig, tooltip=ttThresh)
showBands     = input.bool(false,  "Show Threshold Lines", group=grpSig, tooltip=ttShowBands)
flowConfirm   = input.string("Off", "Liquidity Pressure Confirmation", options=["Off", "Same Direction", "Zero Cross"], group=grpSig, tooltip=ttFlowConfirm)

// --- Visuals
palTealLine    = input.color(color.new(#00e5ff, 0),  "Teal", inline="pal", group=grpViz, tooltip=ttPalTealLine)
palPinkLine    = input.color(color.new(#ff00ff, 0),  "Pink", inline="pal", group=grpViz, tooltip=ttPalPinkLine)
palTealSoft    = input.color(color.new(#00e5ff, 25), "",     inline="pal", group=grpViz, tooltip=ttPalTealSoft)
palPinkSoft    = input.color(color.new(#ff00ff, 25), "",     inline="pal", group=grpViz, tooltip=ttPalPinkSoft)

showBG         = input.bool(true,   "Background Gradient", group=grpViz, tooltip=ttShowBG)
bgTeal         = input.color(color.new(#00e5ff, 88), "Teal BG", inline="bg", group=grpViz, tooltip=ttBgTeal)
bgPink         = input.color(color.new(#ff00ff, 88), "Pink BG", inline="bg", group=grpViz, tooltip=ttBgPink)
bgRange        = input.int(250, "Background Range (+/-)", minval=50, group=grpViz, tooltip=ttBgRange)
ribbonSmooth   = input.int(5, "Ribbon Smooth (EMA)", minval=1, group=grpViz, tooltip=ttRibbonSmooth)
tablePreset    = input.string("Default", "Table Color Preset", options=["Default", "Black Text"], group=grpViz, tooltip=ttTablePreset)

// --- Stats + Tables
tpPct         = input.float(1.0, "Target %", minval=0.1, step=0.1, group=grpStats, tooltip=ttTpPct) / 100.0
slPct         = input.float(1.0, "Stop Loss %",   minval=0.1, step=0.1, group=grpStats, tooltip=ttSlPct) / 100.0
showStats     = input.bool(true, "Show Win/Loss Tables", group=grpStats, tooltip=ttShowStats)

long_pos_str  = input.string("Top Left",  "Long Stats Position",  options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=grpStats, tooltip=ttLongPos)
short_pos_str = input.string("Top Right", "Short Stats Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=grpStats, tooltip=ttShortPos)
bull_pos_str  = input.string("Bottom Left", "Bull Div Position",  options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=grpStats, tooltip=ttBullPos)
bear_pos_str  = input.string("Bottom Right", "Bear Div Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=grpStats, tooltip=ttBearPos)

// --- Alerts
alCrossUp     = input.bool(true, "Bullish Cross", inline="a1", group=grpAlerts, tooltip=ttAlCrossUp)
alCrossDn     = input.bool(true, "Bearish Cross", inline="a1", group=grpAlerts, tooltip=ttAlCrossDn)
alDivUp       = input.bool(true, "Bullish Divergence", inline="a2", group=grpAlerts, tooltip=ttAlDivUp)
alDivDn       = input.bool(true, "Bearish Divergence", inline="a2", group=grpAlerts, tooltip=ttAlDivDn)
alFlowUp      = input.bool(true, "Flow Bull Cross 0", inline="a3", group=grpAlerts, tooltip=ttAlFlowUp)
alFlowDn      = input.bool(true, "Flow Bear Cross 0", inline="a3", group=grpAlerts, tooltip=ttAlFlowDn)


//==================================================================================================
// HELPERS
//==================================================================================================
f_div(n, d) =>
    d == 0.0 ? 0.0 : (n / d)

f_adapt_ema(src, len, lb) =>
    float alphaBase = 2.0 / (len + 1.0)
    float delta     = math.abs(src - src[lb])
    float denom     = ta.highest(delta, len)
    float changeNorm = math.min(1.0, f_div(delta, denom))
    float alpha     = alphaBase * changeNorm
    var float out   = na
    out := na(out[1]) ? src : alpha * src + (1.0 - alpha) * nz(out[1])
    out

f_ribbon_color(x, center, bearCol, bullCol, smoothLen) =>
    var float maxRun = 1.0
    var float run    = 0.0
    bool above = x > center
    bool below = x < center
    bool xUp   = ta.crossover(x, center)
    bool xDn   = ta.crossunder(x, center)
    float chg  = ta.change(x)

    if above
        run := xUp ? 1.0 : chg > 0 ? (run + 1.0) : chg < 0 ? math.max(1.0, run - 1.0) : run
    else if below
        run := xDn ? 1.0 : chg < 0 ? (run + 1.0) : chg > 0 ? math.max(1.0, run - 1.0) : run

    maxRun := math.max(maxRun, run)

    float tRaw = 82.0 - (run * 92.0 / maxRun)
    float tSm  = ta.ema(tRaw, smoothLen)
    float t    = math.max(0.0, math.min(100.0, tSm))

    above ? color.new(bullCol, t) : below ? color.new(bearCol, t) : na

f_is_valid_span(curIdx, prevIdx, minBars, maxBars) =>
    span = curIdx - prevIdx
    span >= minBars and span <= maxBars


f_is_bull_regular_div(curBar, curPrice, curOsc, prevBar, prevPrice, prevOsc, minBars, maxBars, requireZero) =>
    bool result = false
    if not na(prevBar) and not na(prevPrice) and not na(prevOsc)
        bool validSpan = f_is_valid_span(curBar, prevBar, minBars, maxBars)
        bool regular   = curPrice < prevPrice and curOsc > prevOsc
        bool zeroOk    = requireZero ? (prevOsc <= 0 and curOsc <= 0) : true
        result := validSpan and zeroOk and regular
    result

f_is_bull_hidden_div(curBar, curPrice, curOsc, prevBar, prevPrice, prevOsc, minBars, maxBars, requireZero) =>
    bool result = false
    if not na(prevBar) and not na(prevPrice) and not na(prevOsc)
        bool validSpan = f_is_valid_span(curBar, prevBar, minBars, maxBars)
        bool hidden    = curPrice > prevPrice and curOsc < prevOsc
        bool zeroOk    = requireZero ? (prevOsc <= 0 and curOsc <= 0) : true
        result := validSpan and zeroOk and hidden
    result

f_is_bear_regular_div(curBar, curPrice, curOsc, prevBar, prevPrice, prevOsc, minBars, maxBars, requireZero) =>
    bool result = false
    if not na(prevBar) and not na(prevPrice) and not na(prevOsc)
        bool validSpan = f_is_valid_span(curBar, prevBar, minBars, maxBars)
        bool regular   = curPrice > prevPrice and curOsc < prevOsc
        bool zeroOk    = requireZero ? (prevOsc >= 0 and curOsc >= 0) : true
        result := validSpan and zeroOk and regular
    result

f_is_bear_hidden_div(curBar, curPrice, curOsc, prevBar, prevPrice, prevOsc, minBars, maxBars, requireZero) =>
    bool result = false
    if not na(prevBar) and not na(prevPrice) and not na(prevOsc)
        bool validSpan = f_is_valid_span(curBar, prevBar, minBars, maxBars)
        bool hidden    = curPrice < prevPrice and curOsc > prevOsc
        bool zeroOk    = requireZero ? (prevOsc >= 0 and curOsc >= 0) : true
        result := validSpan and zeroOk and hidden
    result

f_nearest_low_osc_pivot(priceBar, oscBar1, oscVal1, oscBar2, oscVal2, oscBar3, oscVal3, maxGap) =>
    int bestBar = na
    float bestVal = na
    int bestGap = 1000000

    if not na(oscBar1)
        gap1 = math.abs(priceBar - oscBar1)
        if gap1 <= maxGap and gap1 < bestGap
            bestGap := gap1
            bestBar := oscBar1
            bestVal := oscVal1

    if not na(oscBar2)
        gap2 = math.abs(priceBar - oscBar2)
        if gap2 <= maxGap and gap2 < bestGap
            bestGap := gap2
            bestBar := oscBar2
            bestVal := oscVal2

    if not na(oscBar3)
        gap3 = math.abs(priceBar - oscBar3)
        if gap3 <= maxGap and gap3 < bestGap
            bestGap := gap3
            bestBar := oscBar3
            bestVal := oscVal3

    [bestBar, bestVal]

f_nearest_high_osc_pivot(priceBar, oscBar1, oscVal1, oscBar2, oscVal2, oscBar3, oscVal3, maxGap) =>
    int bestBar = na
    float bestVal = na
    int bestGap = 1000000

    if not na(oscBar1)
        gap1 = math.abs(priceBar - oscBar1)
        if gap1 <= maxGap and gap1 < bestGap
            bestGap := gap1
            bestBar := oscBar1
            bestVal := oscVal1

    if not na(oscBar2)
        gap2 = math.abs(priceBar - oscBar2)
        if gap2 <= maxGap and gap2 < bestGap
            bestGap := gap2
            bestBar := oscBar2
            bestVal := oscVal2

    if not na(oscBar3)
        gap3 = math.abs(priceBar - oscBar3)
        if gap3 <= maxGap and gap3 < bestGap
            bestGap := gap3
            bestBar := oscBar3
            bestVal := oscVal3

    [bestBar, bestVal]

f_table_text_color(preset) =>
    preset == "Black Text" ? color.black : color.white

//==================================================================================================
// 1) LIQUIDITY PRESSURE
//==================================================================================================
rng  = high - low
body = close - open
rawPressure = f_div(body, rng) * volume
flowCore = ta.ema(rawPressure, flowLen)
flow = (flowCore / ta.ema(volume, flowLen)) * flowScale

flowCol =
  flow > 0 and flow > flow[1] ? color.new(palTealLine, 55) :
  flow > 0                    ? color.new(palTealLine, 70) :
  flow < 0 and flow < flow[1] ? color.new(palPinkLine, 55) :
  flow < 0                    ? color.new(palPinkLine, 70) : na

plot(showFlow ? flow : na, "Liquidity Pressure", style=plot.style_area, color=flowCol)

//==================================================================================================
// 2) CYCLE ENGINE
//==================================================================================================
base   = f_adapt_ema(cycleSrc, baseLen, adaptLookback)
dev    = cycleSrc - base
devAbs = f_adapt_ema(math.abs(dev), baseLen, adaptLookback)
z      = f_div(dev, (0.015 * devAbs))

cycleLine0   = f_adapt_ema(z, slowLen, fastLag)
cycleSignal0 = f_adapt_ema(cycleLine0, math.max(2, math.round(slowLen * 0.35)), slowLag)

cycleLine   = ta.ema(cycleLine0, ribbonSmooth)
cycleSignal = ta.ema(cycleSignal0, ribbonSmooth)

//==================================================================================================
// 3) SIGNALS
//==================================================================================================
xUpRaw = ta.crossover(cycleLine, cycleSignal)
xDnRaw = ta.crossunder(cycleLine, cycleSignal)

flowUpRaw = ta.crossover(flow, 0)
flowDnRaw = ta.crossunder(flow, 0)

allowUp = useThreshold ? cycleLine < -thresh : true
allowDn = useThreshold ? cycleLine >  thresh : true

flowBullOk = switch flowConfirm
    "Same Direction" => flow > 0
    "Zero Cross"     => flowUpRaw
    => true

flowBearOk = switch flowConfirm
    "Same Direction" => flow < 0
    "Zero Cross"     => flowDnRaw
    => true

// Signals are only accepted on confirmed bars so realtime crosses cannot appear and vanish intrabar.
// Liquidity Pressure confirmation is optional and defaults to Off, preserving the original signal behaviour.
sigUp = barstate.isconfirmed and xUpRaw and allowUp and flowBullOk
sigDn = barstate.isconfirmed and xDnRaw and allowDn and flowBearOk

flowUp = barstate.isconfirmed and flowUpRaw
flowDn = barstate.isconfirmed and flowDnRaw

plot(showBands ? float(thresh) : na,  "Upper Filter", color=color.new(palTealSoft, 0), editable=false, display=display.all - display.status_line)
plot(showBands ? float(-thresh) : na, "Lower Filter", color=color.new(palPinkSoft, 0), editable=false, display=display.all - display.status_line)

pCyc  = plot(cycleLine,   "Cycle Anchor",  color=color.new(#ffffff, 100))
pSig  = plot(cycleSignal, "Signal Anchor", color=color.new(#ffffff, 100))
plot(cycleLine,   "Cycle (Teal)",  color=palTealLine)
plot(cycleSignal, "Signal (Pink)", color=palPinkLine)

h0 = hline(0, "Zero", color=color.new(color.white, 100))

fillCol = f_ribbon_color(cycleLine, cycleSignal, palPinkSoft, palTealSoft, ribbonSmooth)
fill(pCyc, pSig, fillCol)

plotshape(sigUp ? cycleLine : na, "Bullish Cross", style=shape.diamond, location=location.absolute, size=size.tiny, color=palTealLine, display=display.all - display.status_line)
plotshape(sigDn ? cycleLine : na, "Bearish Cross", style=shape.diamond, location=location.absolute, size=size.tiny, color=palPinkLine, display=display.all - display.status_line)

//==================================================================================================
// 4) BACKGROUND (EXPANDED RANGE)
//==================================================================================================
top = hline(bgRange,  "Top",  display=display.none)
bot = hline(-bgRange, "Bot",  display=display.none)

bgTealUse = showBG ? bgTeal : na
bgPinkUse = showBG ? bgPink : na

// Use the color-input transparency directly instead of overriding it with another color.new().
fill(top, h0, bgTealUse)
fill(h0, bot, bgPinkUse)

//==================================================================================================
// 5) DIVERGENCES
//==================================================================================================
pivLen = divPivotLen

pH = ta.pivothigh(high, pivLen, pivLen)
pL = ta.pivotlow(low,  pivLen, pivLen)

oH = ta.pivothigh(cycleLine, pivLen, pivLen)
oL = ta.pivotlow(cycleLine,  pivLen, pivLen)

// Store recent confirmed oscillator lows.
var int   oscLowBar1 = na
var int   oscLowBar2 = na
var int   oscLowBar3 = na
var float oscLowVal1 = na
var float oscLowVal2 = na
var float oscLowVal3 = na

// Store recent confirmed oscillator highs.
var int   oscHighBar1 = na
var int   oscHighBar2 = na
var int   oscHighBar3 = na
var float oscHighVal1 = na
var float oscHighVal2 = na
var float oscHighVal3 = na

// Store the three most recent matched price/oscillator LOW pairs.
// Looking back beyond only the immediately previous pair prevents valid A -> C divergences from being lost.
var int   bullPriceBar1 = na
var int   bullPriceBar2 = na
var int   bullPriceBar3 = na
var float bullPriceVal1 = na
var float bullPriceVal2 = na
var float bullPriceVal3 = na
var int   bullOscBar1   = na
var int   bullOscBar2   = na
var int   bullOscBar3   = na
var float bullOscVal1   = na
var float bullOscVal2   = na
var float bullOscVal3   = na

// Store the three most recent matched price/oscillator HIGH pairs.
var int   bearPriceBar1 = na
var int   bearPriceBar2 = na
var int   bearPriceBar3 = na
var float bearPriceVal1 = na
var float bearPriceVal2 = na
var float bearPriceVal3 = na
var int   bearOscBar1   = na
var int   bearOscBar2   = na
var int   bearOscBar3   = na
var float bearOscVal1   = na
var float bearOscVal2   = na
var float bearOscVal3   = na

// Separate divergence line pools keep regular and hidden drawings visible together.
// Each pool is capped so hidden lines cannot crowd regular lines out of TradingView's global line limit.
var array<line> regOscLines = array.new_line()
var array<line> hidOscLines = array.new_line()
var array<line> regChartLines = array.new_line()
var array<line> hidChartLines = array.new_line()

f_store_div_line(array<line> pool, line ln, int maxKeep) =>
    array.push(pool, ln)
    if array.size(pool) > maxKeep
        line.delete(array.shift(pool))

int maxDivLinesPerPool = 110

// Divergence outcome counters and independent active-trade storage.
var int bullDivW = 0
var int bullDivL = 0
var int bearDivW = 0
var int bearDivL = 0

var array<float> bullDivTPs  = array.new_float()
var array<float> bullDivSLs  = array.new_float()
var array<int>   bullDivBars = array.new_int()
var array<float> bearDivTPs  = array.new_float()
var array<float> bearDivSLs  = array.new_float()
var array<int>   bearDivBars = array.new_int()

bullDiv = false
bearDiv = false

// Update oscillator pivot memory only after the current bar is confirmed.
if barstate.isconfirmed and not na(oL)
    oscLowBar3 := oscLowBar2
    oscLowVal3 := oscLowVal2
    oscLowBar2 := oscLowBar1
    oscLowVal2 := oscLowVal1
    oscLowBar1 := bar_index[pivLen]
    oscLowVal1 := oL

if barstate.isconfirmed and not na(oH)
    oscHighBar3 := oscHighBar2
    oscHighVal3 := oscHighVal2
    oscHighBar2 := oscHighBar1
    oscHighVal2 := oscHighVal1
    oscHighBar1 := bar_index[pivLen]
    oscHighVal1 := oH

// Bullish divergence.
if showDiv and barstate.isconfirmed and not na(pL)
    int curPriceBar = bar_index[pivLen]
    float curPrice  = pL

    [matchedOscBar, matchedOscVal] = f_nearest_low_osc_pivot(curPriceBar, oscLowBar1, oscLowVal1, oscLowBar2, oscLowVal2, oscLowBar3, oscLowVal3, divMaxOscGap)

    if not na(matchedOscBar) and not na(matchedOscVal)
        int regPriceBar = na
        float regPrice  = na
        int regOscBar   = na
        float regOsc    = na

        int hidPriceBar = na
        float hidPrice  = na
        int hidOscBar   = na
        float hidOsc    = na

        // Find the nearest REGULAR bullish divergence first.
        if f_is_bull_regular_div(curPriceBar, curPrice, matchedOscVal, bullPriceBar1, bullPriceVal1, bullOscVal1, divMinBars, divMaxBars, divRequireZero)
            regPriceBar := bullPriceBar1
            regPrice    := bullPriceVal1
            regOscBar   := bullOscBar1
            regOsc      := bullOscVal1
        else if f_is_bull_regular_div(curPriceBar, curPrice, matchedOscVal, bullPriceBar2, bullPriceVal2, bullOscVal2, divMinBars, divMaxBars, divRequireZero)
            regPriceBar := bullPriceBar2
            regPrice    := bullPriceVal2
            regOscBar   := bullOscBar2
            regOsc      := bullOscVal2
        else if f_is_bull_regular_div(curPriceBar, curPrice, matchedOscVal, bullPriceBar3, bullPriceVal3, bullOscVal3, divMinBars, divMaxBars, divRequireZero)
            regPriceBar := bullPriceBar3
            regPrice    := bullPriceVal3
            regOscBar   := bullOscBar3
            regOsc      := bullOscVal3

        // Hidden divergences are evaluated independently, so enabling them cannot replace regular lines.
        if divUseHidden
            if f_is_bull_hidden_div(curPriceBar, curPrice, matchedOscVal, bullPriceBar1, bullPriceVal1, bullOscVal1, divMinBars, divMaxBars, divRequireZero)
                hidPriceBar := bullPriceBar1
                hidPrice    := bullPriceVal1
                hidOscBar   := bullOscBar1
                hidOsc      := bullOscVal1
            else if f_is_bull_hidden_div(curPriceBar, curPrice, matchedOscVal, bullPriceBar2, bullPriceVal2, bullOscVal2, divMinBars, divMaxBars, divRequireZero)
                hidPriceBar := bullPriceBar2
                hidPrice    := bullPriceVal2
                hidOscBar   := bullOscBar2
                hidOsc      := bullOscVal2
            else if f_is_bull_hidden_div(curPriceBar, curPrice, matchedOscVal, bullPriceBar3, bullPriceVal3, bullOscVal3, divMinBars, divMaxBars, divRequireZero)
                hidPriceBar := bullPriceBar3
                hidPrice    := bullPriceVal3
                hidOscBar   := bullOscBar3
                hidOsc      := bullOscVal3

        if not na(regPriceBar) and not na(regOscBar)
            if showDivOscLines
                f_store_div_line(regOscLines, line.new(regOscBar, regOsc, matchedOscBar, matchedOscVal, xloc=xloc.bar_index, color=regularBullColor, width=divLineWidth), maxDivLinesPerPool)
            if showDivChartLines
                f_store_div_line(regChartLines, line.new(regPriceBar, regPrice, curPriceBar, curPrice, xloc=xloc.bar_index, color=regularBullColor, width=divLineWidth, force_overlay=true), maxDivLinesPerPool)

            bullDiv := true
            array.push(bullDivTPs, close * (1.0 + divTpPct / 100.0))
            array.push(bullDivSLs, close * (1.0 - divSlPct / 100.0))
            array.push(bullDivBars, bar_index)

        if not na(hidPriceBar) and not na(hidOscBar)
            if showDivOscLines
                f_store_div_line(hidOscLines, line.new(hidOscBar, hidOsc, matchedOscBar, matchedOscVal, xloc=xloc.bar_index, color=hiddenBullColor, width=divLineWidth), maxDivLinesPerPool)
            if showDivChartLines
                f_store_div_line(hidChartLines, line.new(hidPriceBar, hidPrice, curPriceBar, curPrice, xloc=xloc.bar_index, color=hiddenBullColor, width=divLineWidth, force_overlay=true), maxDivLinesPerPool)

            bullDiv := true
            array.push(bullDivTPs, close * (1.0 + divTpPct / 100.0))
            array.push(bullDivSLs, close * (1.0 - divSlPct / 100.0))
            array.push(bullDivBars, bar_index)

        // Shift matched-pair memory after testing so the current pivot cannot compare with itself.
        bullPriceBar3 := bullPriceBar2
        bullPriceVal3 := bullPriceVal2
        bullOscBar3   := bullOscBar2
        bullOscVal3   := bullOscVal2
        bullPriceBar2 := bullPriceBar1
        bullPriceVal2 := bullPriceVal1
        bullOscBar2   := bullOscBar1
        bullOscVal2   := bullOscVal1
        bullPriceBar1 := curPriceBar
        bullPriceVal1 := curPrice
        bullOscBar1   := matchedOscBar
        bullOscVal1   := matchedOscVal

// Bearish divergence.
if showDiv and barstate.isconfirmed and not na(pH)
    int curPriceBar = bar_index[pivLen]
    float curPrice  = pH

    [matchedOscBar, matchedOscVal] = f_nearest_high_osc_pivot(curPriceBar, oscHighBar1, oscHighVal1, oscHighBar2, oscHighVal2, oscHighBar3, oscHighVal3, divMaxOscGap)

    if not na(matchedOscBar) and not na(matchedOscVal)
        int regPriceBar = na
        float regPrice  = na
        int regOscBar   = na
        float regOsc    = na

        int hidPriceBar = na
        float hidPrice  = na
        int hidOscBar   = na
        float hidOsc    = na

        // Find the nearest REGULAR bearish divergence first.
        if f_is_bear_regular_div(curPriceBar, curPrice, matchedOscVal, bearPriceBar1, bearPriceVal1, bearOscVal1, divMinBars, divMaxBars, divRequireZero)
            regPriceBar := bearPriceBar1
            regPrice    := bearPriceVal1
            regOscBar   := bearOscBar1
            regOsc      := bearOscVal1
        else if f_is_bear_regular_div(curPriceBar, curPrice, matchedOscVal, bearPriceBar2, bearPriceVal2, bearOscVal2, divMinBars, divMaxBars, divRequireZero)
            regPriceBar := bearPriceBar2
            regPrice    := bearPriceVal2
            regOscBar   := bearOscBar2
            regOsc      := bearOscVal2
        else if f_is_bear_regular_div(curPriceBar, curPrice, matchedOscVal, bearPriceBar3, bearPriceVal3, bearOscVal3, divMinBars, divMaxBars, divRequireZero)
            regPriceBar := bearPriceBar3
            regPrice    := bearPriceVal3
            regOscBar   := bearOscBar3
            regOsc      := bearOscVal3

        // Hidden divergences are evaluated independently, so enabling them cannot replace regular lines.
        if divUseHidden
            if f_is_bear_hidden_div(curPriceBar, curPrice, matchedOscVal, bearPriceBar1, bearPriceVal1, bearOscVal1, divMinBars, divMaxBars, divRequireZero)
                hidPriceBar := bearPriceBar1
                hidPrice    := bearPriceVal1
                hidOscBar   := bearOscBar1
                hidOsc      := bearOscVal1
            else if f_is_bear_hidden_div(curPriceBar, curPrice, matchedOscVal, bearPriceBar2, bearPriceVal2, bearOscVal2, divMinBars, divMaxBars, divRequireZero)
                hidPriceBar := bearPriceBar2
                hidPrice    := bearPriceVal2
                hidOscBar   := bearOscBar2
                hidOsc      := bearOscVal2
            else if f_is_bear_hidden_div(curPriceBar, curPrice, matchedOscVal, bearPriceBar3, bearPriceVal3, bearOscVal3, divMinBars, divMaxBars, divRequireZero)
                hidPriceBar := bearPriceBar3
                hidPrice    := bearPriceVal3
                hidOscBar   := bearOscBar3
                hidOsc      := bearOscVal3

        if not na(regPriceBar) and not na(regOscBar)
            if showDivOscLines
                f_store_div_line(regOscLines, line.new(regOscBar, regOsc, matchedOscBar, matchedOscVal, xloc=xloc.bar_index, color=regularBearColor, width=divLineWidth), maxDivLinesPerPool)
            if showDivChartLines
                f_store_div_line(regChartLines, line.new(regPriceBar, regPrice, curPriceBar, curPrice, xloc=xloc.bar_index, color=regularBearColor, width=divLineWidth, force_overlay=true), maxDivLinesPerPool)

            bearDiv := true
            array.push(bearDivTPs, close * (1.0 - divTpPct / 100.0))
            array.push(bearDivSLs, close * (1.0 + divSlPct / 100.0))
            array.push(bearDivBars, bar_index)

        if not na(hidPriceBar) and not na(hidOscBar)
            if showDivOscLines
                f_store_div_line(hidOscLines, line.new(hidOscBar, hidOsc, matchedOscBar, matchedOscVal, xloc=xloc.bar_index, color=hiddenBearColor, width=divLineWidth), maxDivLinesPerPool)
            if showDivChartLines
                f_store_div_line(hidChartLines, line.new(hidPriceBar, hidPrice, curPriceBar, curPrice, xloc=xloc.bar_index, color=hiddenBearColor, width=divLineWidth, force_overlay=true), maxDivLinesPerPool)

            bearDiv := true
            array.push(bearDivTPs, close * (1.0 - divTpPct / 100.0))
            array.push(bearDivSLs, close * (1.0 + divSlPct / 100.0))
            array.push(bearDivBars, bar_index)

        bearPriceBar3 := bearPriceBar2
        bearPriceVal3 := bearPriceVal2
        bearOscBar3   := bearOscBar2
        bearOscVal3   := bearOscVal2
        bearPriceBar2 := bearPriceBar1
        bearPriceVal2 := bearPriceVal1
        bearOscBar2   := bearOscBar1
        bearOscVal2   := bearOscVal1
        bearPriceBar1 := curPriceBar
        bearPriceVal1 := curPrice
        bearOscBar1   := matchedOscBar
        bearOscVal1   := matchedOscVal

// Divergence outcome tracking. Each divergence is tracked independently.
// Checking starts on the bar AFTER confirmation. If Target and Stop are both touched on one bar, Stop is counted first (conservative rule).
if array.size(bullDivBars) > 0
    int i = array.size(bullDivBars) - 1
    while i >= 0
        int entryBar = array.get(bullDivBars, i)
        if bar_index > entryBar
            float tp = array.get(bullDivTPs, i)
            float sl = array.get(bullDivSLs, i)
            bool slHit = low <= sl
            bool tpHit = high >= tp
            if slHit or tpHit
                if slHit
                    bullDivL += 1
                else
                    bullDivW += 1
                array.remove(bullDivTPs, i)
                array.remove(bullDivSLs, i)
                array.remove(bullDivBars, i)
        i -= 1

if array.size(bearDivBars) > 0
    int i = array.size(bearDivBars) - 1
    while i >= 0
        int entryBar = array.get(bearDivBars, i)
        if bar_index > entryBar
            float tp = array.get(bearDivTPs, i)
            float sl = array.get(bearDivSLs, i)
            bool slHit = high >= sl
            bool tpHit = low <= tp
            if slHit or tpHit
                if slHit
                    bearDivL += 1
                else
                    bearDivW += 1
                array.remove(bearDivTPs, i)
                array.remove(bearDivSLs, i)
                array.remove(bearDivBars, i)
        i -= 1


//==================================================================================================
// ALERTS
//==================================================================================================
alertcondition(sigUp,   "LWI Bullish Cross",      "LWI: Bullish Cycle Cross")
alertcondition(sigDn,   "LWI Bearish Cross",      "LWI: Bearish Cycle Cross")
alertcondition(bullDiv, "LWI Bullish Divergence", "LWI: Bullish Divergence")
alertcondition(bearDiv, "LWI Bearish Divergence", "LWI: Bearish Divergence")
alertcondition(flowUp,  "LWI Flow Bullish",       "LWI: Liquidity Pressure crossed above 0")
alertcondition(flowDn,  "LWI Flow Bearish",       "LWI: Liquidity Pressure crossed below 0")

if sigUp and alCrossUp
    alert("LWI: Bullish Cycle Cross", alert.freq_once_per_bar_close)
if sigDn and alCrossDn
    alert("LWI: Bearish Cycle Cross", alert.freq_once_per_bar_close)
if bullDiv and alDivUp
    alert("LWI: Bullish Divergence", alert.freq_once_per_bar_close)
if bearDiv and alDivDn
    alert("LWI: Bearish Divergence", alert.freq_once_per_bar_close)
if flowUp and alFlowUp
    alert("LWI: Liquidity Pressure crossed above 0", alert.freq_once_per_bar_close)
if flowDn and alFlowDn
    alert("LWI: Liquidity Pressure crossed below 0", alert.freq_once_per_bar_close)

//==================================================================================================
// STATS
//==================================================================================================
var int longW  = 0
var int longL  = 0
var int shortW = 0
var int shortL = 0

var array<float> longTPs   = array.new_float()
var array<float> longSLs   = array.new_float()
var array<int>   longBars  = array.new_int()
var array<float> shortTPs  = array.new_float()
var array<float> shortSLs  = array.new_float()
var array<int>   shortBars = array.new_int()

// Every confirmed signal gets its own virtual target/stop outcome instead of overwriting the previous one.
if sigUp
    array.push(longTPs, close * (1.0 + tpPct))
    array.push(longSLs, close * (1.0 - slPct))
    array.push(longBars, bar_index)

if sigDn
    array.push(shortTPs, close * (1.0 - tpPct))
    array.push(shortSLs, close * (1.0 + slPct))
    array.push(shortBars, bar_index)

// Start checking on the next bar. If both Target and Stop are touched on the same candle, count Stop first.
if array.size(longBars) > 0
    int i = array.size(longBars) - 1
    while i >= 0
        int entryBar = array.get(longBars, i)
        if bar_index > entryBar
            float tp = array.get(longTPs, i)
            float sl = array.get(longSLs, i)
            bool slHit = low <= sl
            bool tpHit = high >= tp
            if slHit or tpHit
                if slHit
                    longL += 1
                else
                    longW += 1
                array.remove(longTPs, i)
                array.remove(longSLs, i)
                array.remove(longBars, i)
        i -= 1

if array.size(shortBars) > 0
    int i = array.size(shortBars) - 1
    while i >= 0
        int entryBar = array.get(shortBars, i)
        if bar_index > entryBar
            float tp = array.get(shortTPs, i)
            float sl = array.get(shortSLs, i)
            bool slHit = high >= sl
            bool tpHit = low <= tp
            if slHit or tpHit
                if slHit
                    shortL += 1
                else
                    shortW += 1
                array.remove(shortTPs, i)
                array.remove(shortSLs, i)
                array.remove(shortBars, i)
        i -= 1

get_table_position(s) =>
    switch s
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        => position.top_left


//=================================================================================================
// TABLES
//=================================================================================================
var table tLong    = table.new(get_table_position(long_pos_str), 4, 1, border_width=1, frame_width=1, frame_color=color.gray)
var table tShort   = table.new(get_table_position(short_pos_str), 4, 1, border_width=1, frame_width=1, frame_color=color.gray)
var table tBullDiv = table.new(get_table_position(bull_pos_str), 4, 1, border_width=1, frame_width=1, frame_color=color.gray)
var table tBearDiv = table.new(get_table_position(bear_pos_str), 4, 1, border_width=1, frame_width=1, frame_color=color.gray)

f_cell_bg(isPos, isNeg) => isPos ? color.new(color.green, 80) : isNeg ? color.new(color.red, 80) : color.new(color.gray, 80)

tableTextColor = f_table_text_color(tablePreset)

if barstate.islast
    if showStats
        float longWR  = (longW + longL) > 0 ? (float(longW)  / float(longW  + longL))  * 100.0 : 0.0
        float shortWR = (shortW + shortL) > 0 ? (float(shortW) / float(shortW + shortL)) * 100.0 : 0.0

        table.cell(tLong, 0, 0, "Bull", bgcolor=color.new(color.gray, 80), text_color=tableTextColor, text_size=size.small)
        table.cell(tLong, 1, 0, "T: " + str.tostring(longW),  bgcolor=f_cell_bg(true,  false), text_color=tableTextColor, text_size=size.small)
        table.cell(tLong, 2, 0, "S: " + str.tostring(longL),  bgcolor=f_cell_bg(false, true),  text_color=tableTextColor, text_size=size.small)
        table.cell(tLong, 3, 0, str.tostring(longWR, "#.##") + "%",  bgcolor=color.new(color.gray, 80), text_color=tableTextColor, text_size=size.small)

        table.cell(tShort, 0, 0, "Bear", bgcolor=color.new(color.gray, 80), text_color=tableTextColor, text_size=size.small)
        table.cell(tShort, 1, 0, "T: " + str.tostring(shortW), bgcolor=f_cell_bg(true,  false), text_color=tableTextColor, text_size=size.small)
        table.cell(tShort, 2, 0, "S: " + str.tostring(shortL), bgcolor=f_cell_bg(false, true),  text_color=tableTextColor, text_size=size.small)
        table.cell(tShort, 3, 0, str.tostring(shortWR, "#.##") + "%", bgcolor=color.new(color.gray, 80), text_color=tableTextColor, text_size=size.small)
    else
        table.cell(tLong,  0, 0, "", bgcolor=color.new(color.gray, 100), text_color=tableTextColor, text_size=size.small)
        table.cell(tLong,  1, 0, "", bgcolor=color.new(color.gray, 100), text_color=tableTextColor, text_size=size.small)
        table.cell(tLong,  2, 0, "", bgcolor=color.new(color.gray, 100), text_color=tableTextColor, text_size=size.small)
        table.cell(tLong,  3, 0, "", bgcolor=color.new(color.gray, 100), text_color=tableTextColor, text_size=size.small)

        table.cell(tShort, 0, 0, "", bgcolor=color.new(color.gray, 100), text_color=tableTextColor, text_size=size.small)
        table.cell(tShort, 1, 0, "", bgcolor=color.new(color.gray, 100), text_color=tableTextColor, text_size=size.small)
        table.cell(tShort, 2, 0, "", bgcolor=color.new(color.gray, 100), text_color=tableTextColor, text_size=size.small)
        table.cell(tShort, 3, 0, "", bgcolor=color.new(color.gray, 100), text_color=tableTextColor, text_size=size.small)

    if showDivTable
        float bullWR = (bullDivW + bullDivL) > 0 ? (float(bullDivW) / float(bullDivW + bullDivL)) * 100.0 : 0.0
        float bearWR = (bearDivW + bearDivL) > 0 ? (float(bearDivW) / float(bearDivW + bearDivL)) * 100.0 : 0.0

        table.cell(tBullDiv, 0, 0, "Bull D", bgcolor=color.new(color.gray, 80), text_color=tableTextColor, text_size=size.small)
        table.cell(tBullDiv, 1, 0, "T: " + str.tostring(bullDivW), bgcolor=f_cell_bg(true, false), text_color=tableTextColor, text_size=size.small)
        table.cell(tBullDiv, 2, 0, "S: " + str.tostring(bullDivL), bgcolor=f_cell_bg(false, true), text_color=tableTextColor, text_size=size.small)
        table.cell(tBullDiv, 3, 0, str.tostring(bullWR, "#.##") + "%", bgcolor=color.new(color.gray, 80), text_color=tableTextColor, text_size=size.small)

        table.cell(tBearDiv, 0, 0, "Bear D", bgcolor=color.new(color.gray, 80), text_color=tableTextColor, text_size=size.small)
        table.cell(tBearDiv, 1, 0, "T: " + str.tostring(bearDivW), bgcolor=f_cell_bg(true, false), text_color=tableTextColor, text_size=size.small)
        table.cell(tBearDiv, 2, 0, "S: " + str.tostring(bearDivL), bgcolor=f_cell_bg(false, true), text_color=tableTextColor, text_size=size.small)
        table.cell(tBearDiv, 3, 0, str.tostring(bearWR, "#.##") + "%", bgcolor=color.new(color.gray, 80), text_color=tableTextColor, text_size=size.small)
    else
        table.cell(tBullDiv, 0, 0, "", bgcolor=color.new(color.gray, 100), text_color=tableTextColor, text_size=size.small)
        table.cell(tBullDiv, 1, 0, "", bgcolor=color.new(color.gray, 100), text_color=tableTextColor, text_size=size.small)
        table.cell(tBullDiv, 2, 0, "", bgcolor=color.new(color.gray, 100), text_color=tableTextColor, text_size=size.small)
        table.cell(tBullDiv, 3, 0, "", bgcolor=color.new(color.gray, 100), text_color=tableTextColor, text_size=size.small)

        table.cell(tBearDiv, 0, 0, "", bgcolor=color.new(color.gray, 100), text_color=tableTextColor, text_size=size.small)
        table.cell(tBearDiv, 1, 0, "", bgcolor=color.new(color.gray, 100), text_color=tableTextColor, text_size=size.small)
        table.cell(tBearDiv, 2, 0, "", bgcolor=color.new(color.gray, 100), text_color=tableTextColor, text_size=size.small)
        table.cell(tBearDiv, 3, 0, "", bgcolor=color.new(color.gray, 100), text_color=tableTextColor, text_size=size.small)
````

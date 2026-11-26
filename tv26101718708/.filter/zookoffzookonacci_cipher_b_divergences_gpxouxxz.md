# Zookoff-Zookonacci Cipher B + Divergences

- url: https://www.tradingview.com/script/gPXOuxXZ-Zookoff-Zookonacci-Cipher-B-Divergences/
- type: indicator
- pine_id: PUB;819a3700694c45eeb7abf5008ced9067
- version: 2.0

## Description

The Zook Ciphernator — Cipher B

The Zook Ciphernator is a multi-layer momentum, divergence, and reversal dashboard inspired by the classic Cipher B / VuManChu-style oscillator layout, but redesigned with cleaner visuals, improved toggle control, flexible display positioning, enhanced RSI divergence options, and a more refined dot/legend system.

This indicator is designed to help read momentum shifts, exhaustion, divergence, and possible reversal conditions in one pane. It is not intended to be used as a standalone buy/sell system. The signals are contextual tools and should be combined with price action, market structure, volume, risk management, and your own trading plan.

Core Components
WaveTrend

WaveTrend is the main momentum structure of the indicator.

It consists of:

Fast WaveTrend
Slow WaveTrend

The fast WaveTrend crossing above or below the slow WaveTrend can indicate a possible momentum shift.

In this version, the WaveTrend hills are rendered as layered blue/dark areas so the interaction between the fast and slow waves is easier to read visually.

WaveTrend is also used for standard buy/sell signals, WaveTrend divergence, and the Gold Dot logic.

Fast WT / VWAP

The VWAP layer in this indicator is not traditional price VWAP.

Here, it is calculated from the gap between the fast WaveTrend and the slow WaveTrend. In other words, it acts like a fast WaveTrend impulse layer.

When it rises, it suggests the fast WaveTrend is gaining strength relative to the slow WaveTrend. When it falls, it suggests momentum is weakening.

It can often give an earlier clue that momentum is starting to turn before the full WaveTrend structure becomes obvious.

Money Flow

The Money Flow area is a background pressure gauge.

It helps show whether the recent candle structure is leaning bullish or bearish.

Cyan Money Flow = bullish pressure
Red Money Flow = bearish pressure

This Money Flow is best used as context, not as a direct entry trigger. For example, a bullish reversal setup is usually cleaner if Money Flow is improving, flattening, or moving back toward positive territory.

Stochastic RSI

Stochastic RSI is included as a timing tool.

It is useful for identifying when momentum is stretched, bottoming, topping, or beginning to turn.

Typical use:

Low Stoch RSI beginning to curl up = possible early bullish timing clue
High Stoch RSI beginning to roll over = possible early bearish timing clue

Stochastic RSI can be displayed in the upper or lower half of the pane using the display-position controls.

RSI

RSI is included with optional smoothing, overbought/oversold guide levels, and divergence detection.

The RSI line uses dynamic colouring:

Gold = neutral RSI zone
Cyan = RSI oversold zone
Red = RSI overbought zone

The RSI smoothing line can be used as a quieter reference line to help see the broader RSI direction.

RSI can also be displayed in the upper or lower half of the pane.

RSI Divergence Engines

The indicator includes two RSI divergence modes.

1. Cipher Classic

This uses a stricter, confirmed-fractal style divergence method.

It tends to produce fewer signals, but they are cleaner and more selective.

2. Realtime Pivot

This uses a more responsive pivot-scanning divergence engine.

It can detect more RSI divergences and can pick them up earlier. Because it can work closer to the current candle, some signals may change or disappear before confirmation.

There is also an Auto mode:

When WaveTrend is visible, RSI divergences default toward the classic cipher style.
When WaveTrend is hidden, RSI divergences can use the realtime pivot style.
Schaff Trend Cycle

Schaff TC is an optional trend-cycle filter.

It is based on MACD-style momentum, then normalized into a cyclic oscillator. It can help show whether the broader momentum cycle is improving or weakening.

It is not a primary entry trigger, but it can be useful as a background confirmation tool.

Schaff TC can also be displayed in the upper or lower half of the pane.

Sommi Flag and Sommi Diamond

The indicator also includes the original Sommi-style Flag and Diamond pattern logic.

These are optional advanced signals that combine WaveTrend behaviour with higher-timeframe context.

Sommi Flag

The Sommi Flag is designed to highlight potential continuation or reversal-style conditions using:

Money Flow direction
WaveTrend position
WaveTrend cross direction
Higher-timeframe VWAP / Fast WT behaviour

A bearish Sommi Flag can appear when Money Flow is weak, WaveTrend is elevated and crossing down, and the higher-timeframe Fast WT / VWAP context is bearish.

A bullish Sommi Flag uses the opposite logic.

Sommi Diamond

The Sommi Diamond uses higher-timeframe Heikin Ashi candle direction together with WaveTrend crossing behaviour.

A bearish Sommi Diamond can appear when higher-timeframe Heikin Ashi candles are bearish and WaveTrend crosses down from a relevant level.

A bullish Sommi Diamond uses the opposite logic.

How to Use Sommi Signals

Sommi signals should be treated as optional confluence markers, not standalone trade signals.

They are most useful when they agree with the broader context shown by:

WaveTrend
Money Flow
VWAP / Fast WT
Stochastic RSI
RSI divergence
Price structure

Because this version of the Zook Ciphernator focuses mainly on WaveTrend, RSI, Stoch RSI, Money Flow, VWAP, and the dot system, the Sommi tools remain available as legacy/advanced features for users who like that style of signal filtering.

Display Position Controls

The indicator includes quick display controls for:

RSI
Stochastic RSI
Schaff TC

Each can be set to:

Auto
Upper
Lower

Auto uses the current adaptive layout rules. Upper and Lower allow manual override.

This makes it easier to avoid visual clashes between RSI, Stochastic RSI, WaveTrend, and Schaff TC.

Dot Legend

TOP ROW DOTS

Purple/pink dot = RSI bearish divergence
[i]Price has made a higher high, but RSI has made a lower high. This suggests upside momentum may be weakening.[/i]

Red dot, slightly faded = Standard WaveTrend sell signal
[i]The fast WaveTrend crosses down through the slow WaveTrend while WaveTrend is in an overbought area.[/i]

Red dot, brighter = Standard WaveTrend sell signal + confirmed WaveTrend bearish divergence
[i]The normal WaveTrend sell signal has triggered and it coincides with a confirmed WaveTrend bearish divergence. This means price has pushed higher, but WaveTrend has failed to make a stronger high.[/i]

BOTTOM ROW DOTS

Lime dot = RSI bullish divergence
[i]Price has made a lower low, but RSI has made a higher low. This suggests downside momentum may be weakening.[/i]

Cyan dot, slightly faded = Standard WaveTrend buy signal
[i]The fast WaveTrend crosses up through the slow WaveTrend while WaveTrend is in an oversold area.[/i]

Cyan dot, brighter = Standard WaveTrend buy signal + confirmed WaveTrend bullish divergence
[i]The normal WaveTrend buy signal has occurred and it coincides with a confirmed WaveTrend bullish divergence. This means price has pushed lower, but WaveTrend has failed to make a weaker low.[/i]

Gold dot, larger = Stronger bullish reversal setup
[i]This is a higher-alert bullish reversal condition. It generally combines a bullish divergence / oversold WaveTrend structure with RSI oversold confirmation.[/i]

Important: the Gold Dot is not an instruction to buy immediately. It is a warning that a potentially stronger reversal setup may be forming. Confirmation from price action, structure, and your trading plan is still required.

DOTS ON THE WAVETREND HILLS

Red dot on WaveTrend hill = Fast WaveTrend crossing down through slow WaveTrend
[i]This marks a possible bearish momentum shift.[/i]

Cyan dot on WaveTrend hill = Fast WaveTrend crossing up through slow WaveTrend
[i]This marks a possible bullish momentum shift.[/i]

These hill dots mark all WaveTrend crosses. They are useful for reading momentum shifts, but they are not the same as the stronger top/bottom row buy/sell signals.

Visibility Behaviour

The top and bottom row dots are designed to remain in place even if the WaveTrend hills are hidden.

This allows you to hide the WaveTrend visual layer while still preserving the key signal information.

Similarly, RSI divergence dots can remain visible even if the RSI line itself is hidden.

Suggested Reading Framework

A simple way to read the indicator:

Stochastic RSI = timing and stretched momentum
WaveTrend = main momentum structure
VWAP / Fast WT = early impulse clue
Money Flow = background pressure
RSI divergences = momentum disagreement with price
Gold Dot = stronger bullish reversal warning
Schaff TC = optional trend-cycle confirmation
Sommi Flag / Diamond = optional higher-timeframe confluence markers

For bullish setups, look for oversold conditions, improving VWAP / Fast WT, Stoch RSI turning up, bullish divergence, and Money Flow stabilising or improving.

For bearish setups, look for overbought conditions, weakening VWAP / Fast WT, Stoch RSI rolling over, bearish divergence, and Money Flow weakening.

Future Development

This version focuses on the core Cipher B-style workflow: WaveTrend, VWAP / Fast WT, Money Flow, Stochastic RSI, RSI divergence, Schaff TC, Sommi tools, and the refined dot system.

Future iterations may include additional modules such as:

MACD-based confirmation
DSS Bressert
Further divergence refinements
Additional display and confluence options

These may be added in future versions if they improve the indicator without making the layout too cluttered.

Disclaimer

This indicator is for educational and analytical use only. It does not provide financial advice and should not be treated as a standalone trading system.

No signal is guaranteed. Always use proper risk management and make your own trading decisions.

Some examples of customisable views:
[image]https://www.tradingview.com/x/hx2Hr1cV/[/image]
[image]https://www.tradingview.com/x/nY3fdosT/[/image]
[image]https://www.tradingview.com/x/lioRdZpk/[/image]
[image]https://www.tradingview.com/x/XuEMY0Ke/[/image]
[image]https://www.tradingview.com/x/7GQtFEPn/[/image]
Stripping down to just RSI and Stoch RSI while dots are preserved:
[image]https://www.tradingview.com/x/CrzKKLyb/[/image]
[image]https://www.tradingview.com/x/ralUdwjn/[/image]

## Source Code

````pine
//@version=6

//  [Original from VMC (VuManChu)]: Thanks to dynausmaux for the code.
//  Thanks to falconCoin for https://www.tradingview.com/script/KVfgBvDd-Market-Cipher-B-Free-version-with-Buy-and-sell/ inspired me to start this.
//  Thanks to LazyBear for WaveTrend Oscillator https://www.tradingview.com/script/2KE8wTuF-Indicator-WaveTrend-Oscillator-WT/
//  Thanks to RicardoSantos for https://www.tradingview.com/script/3oeDh0Yq-RS-Price-Divergence-Detector-V2/
//  Thanks to LucemAnb for Plain Stochastic Divergence https://www.tradingview.com/script/FCUgF8ag-Plain-Stochastic-Divergence/
//  Thanks to andreholanda73 for MFI+RSI Area https://www.tradingview.com/script/UlGZzUAr/
//  I especially thanks to TradingView for its platform that facilitates development and learning.
//
//  CIRCLES & TRIANGLES:
//  - TOP ROW DOTS: Purple/pink = RSI bearish divergence; Red dot, slightly faded = Standard sell signal; Red dot, brighter = Standard sell signal + confirmed WaveTrend bearish divergence
//  - BOTTOM ROW DOTS: Lime dot = RSI bullish divergence; Cyan dot, slightly faded = Standard buy signal; Cyan dot, brighter = Standard buy signal + confirmed WaveTrend bullish divergence; Gold dot, larger = Stronger/high-confidence bullish reversal setup - combines bullish divergence/oversold WaveTrend conditions with RSI oversold confirmation.
//  - DOTS ON WAVETREND HILLS: Red dot on WaveTrend hill = Fast WaveTrend crossing down through Slow WaveTrend - Possible sell / bearish momentum shift; Cyan dot on WaveTrend hill = Fast WaveTrend crossing up through Slow WaveTrend - Possible buy / bullish momentum shift
//  - [Legacy VMC Cipher B] PURPLE TRIANGLE: Appear when a bullish or bearish divergence is formed and WaveTrend waves crosses at overbought and oversold points.
//
//  VWAP:
//    - In this script, VWAP is basically the “fast WT vs slow WT gap.” It is not price VWAP.
//    - When the yellow VWAP area is below zero, fast WT is below slow WT. When it starts rising back toward zero, it means the fast WT is catching up with the slow WT. That often happens before the WT hill visually turns, or at least before the turn becomes obvious.
//    - VWAP curling up while still below zero = early warning that downside WT momentum is weakening.
//    - VWAP crossing above zero = fast WT has crossed above slow WT, so the WT turn is confirmed.
//    - VWAP rising but staying below zero = possible early bounce, but not confirmed yet.
//
//  MFI / MONEY FLOW INDEX:
//    - MFI / Money Flow is best treated as a background pressure gauge: it shows whether the candle structure over the lookback period is leaning bullish or bearish.
//    - It is not exactly the classic volume-based Money Flow Index. It is more like a smoothed “are candles closing bullish or bearish inside their ranges?” measure.
//    - Above zero / cyan: bullish money-flow pressure. Buyers have more control over the recent candle structure.
//    - Below zero / red: bearish money-flow pressure. Sellers have more control.
//    - Rising MF: pressure is improving, even if price or WT has not fully turned yet.
//    - Falling MF: pressure is weakening, even if price still looks okay.
//
//  SCHAFF TREND CYCLE:
//    - The Schaff TC line is the Schaff Trend Cycle — basically a faster, more cyclic version of MACD. It calculates MACD-style momentum first, then runs it through stochastic-style normalization/smoothing
//    - How to read it: STC rising = trend/momentum cycle improving; STC falling = trend/momentum cycle weakening; High STC, e.g. 75–100 = strong/up-cycle, possibly extended; Low STC, e.g. 0–25 = weak/down-cycle, possibly washed out
//    - The practical use is as a trend-cycle filter, not your main entry trigger
//    
//  IN SUMMARY:
//    - Stoch RSI = timing
//    - WT = main momentum structure
//    - VWAP = fast WT impulse
//    - MFI = background pressure
//    - Schaff TC = broader trend-cycle filter
//
//  NOTES:
//    - [From VMC]: I am not an expert trader or know how to program pine script as such, in fact it is my first indicator only to study and all the code is copied and modified from other codes that are published in TradingView.
//    - I am very grateful to the entire TV community that publishes codes so that other newbies like me can learn and present their results. This is an attempt to imitate Market Cipher B by VuManChu and the zook version is a variation of that immitation.
//    - Settings by default are for 4h timeframe, divergences are more stronger and accurate. Haven't tested in all timeframes, only 2h and 4h, divergences are stronger and more accurate.
//    - [From Zook]: I find the weekly and monthly timeframes to give more accurate buy and sell signals
//    - [From Zook]: All adjustments and updates to the VMC Cipher made with the help of Gemini and ChatGPT. Colour scheme inspired by the Monkey Cipher Pro on mmt.gg, which is stunning!
//
//  CONTRIBUTIONS [from VMC]:
//    - Tip/Idea: Add higher timeframe analysis for bearish/bullish patterns at the current timeframe.
//    + Bearish/Bullish FLAG:
//      - MFI+RSI Area are RED (Below 0).
//      - Wavetrend waves are above 0 and crosses down.
//      - VWAP Area are below 0 on higher timeframe.
//      - This pattern reversed becomes bullish.
//    - Tip/Idea: Check the last heikinashi candle from 2 higher timeframes
//    + Bearish/Bullish DIAMOND:
//      - HT Candle is red
//      - WT > 0 and crossed down

indicator(title = 'Zookoff-Zookonacci Cipher B + Divergences', shorttitle = 'The Zook Ciphernator', explicit_plot_zorder = true, max_bars_back = 500, max_lines_count = 500, max_labels_count = 500)

// PARAMETERS {

// QUICK VISIBILITY TOGGLES
// These are deliberately grouped first so the main on/off controls sit at the top of the settings panel.
quickGroup = 'Quick Visibility Toggles'
wtShow = input.bool(true, title = 'Show WaveTrend', group = quickGroup)
wtBuyShow = input.bool(true, title = 'Show Buy dots', group = quickGroup)
wtGoldShow = input.bool(true, title = 'Show Gold dots', group = quickGroup)
wtSellShow = input.bool(true, title = 'Show Sell dots', group = quickGroup)
wtDivShow = input.bool(true, title = 'Show Div. dots', group = quickGroup)
vwapShow = input.bool(true, title = 'Show Fast WT / VWAP', group = quickGroup)
rsiMFIShow = input.bool(true, title = 'Show MFI', group = quickGroup)
rsiShow = input.bool(false, title = 'Show RSI', group = quickGroup)
stochShow = input.bool(true, title = 'Show Stochastic RSI', group = quickGroup)
tcLine = input.bool(false, title = 'Show Schaff TC line', group = quickGroup)

// Quick display-position overrides.
// Auto keeps the existing adaptive layout rules; Upper/Lower manually force that oscillator into the selected half.
rsiDisplayPosition = input.string('Auto', title = 'RSI Display Position', options = ['Auto', 'Upper', 'Lower'], group = quickGroup)
stochDisplayPosition = input.string('Auto', title = 'Stochastic RSI Display Position', options = ['Auto', 'Upper', 'Lower'], group = quickGroup)
tcDisplayPosition = input.string('Auto', title = 'Schaff TC Display Position', options = ['Auto', 'Upper', 'Lower'], group = quickGroup)

// WaveTrend
wtChannelLen = input.int(9, title = 'WT Channel Length', group = 'WaveTrend Settings')
wtAverageLen = input.int(12, title = 'WT Average Length', group = 'WaveTrend Settings')
wtMASource = input.source(hlc3, title = 'WT MA Source', group = 'WaveTrend Settings')
wtMALen = input.int(3, title = 'WT MA Length', group = 'WaveTrend Settings')

// Visual-only WaveTrend shaping. These do NOT change WT crosses, divergences, dots, or alerts.
wtVisualSmooth = input.int(1, title = 'WT Visual Smoothing Only', minval = 1, maxval = 10, group = 'Visual Match Settings')
wtVisualScale = input.float(1.0, title = 'WT Visual Scale Only', minval = 0.5, maxval = 2.0, group = 'Visual Match Settings')
wtEdgeSource = input.string('WT1', title = 'WT Blue Hill Source', options = ['WT1', 'WT2', 'Average'], group = 'Visual Match Settings')
wtBodySource = input.string('WT2', title = 'WT Dark Body Source', options = ['WT1', 'WT2', 'Average'], group = 'Visual Match Settings')
wtBodyScale = input.float(1.00, title = 'WT Dark Body Scale Only', minval = 0.70, maxval = 1.20, group = 'Visual Match Settings')
wtSignalDivMatchBars = input.int(2, title = 'WT Divergence Upgrade Window', minval = 0, maxval = 2, group = 'Visual Match Settings')

// WaveTrend Overbought & Oversold lines
obLevel = input.int(53, title = 'WT Overbought Level 1', group = 'WaveTrend Settings')
obLevel2 = input.int(60, title = 'WT Overbought Level 2', group = 'WaveTrend Settings')
obLevel3 = input.int(100, title = 'WT Overbought Level 3', group = 'WaveTrend Settings')
osLevel = input.int(-53, title = 'WT Oversold Level 1', group = 'WaveTrend Settings')
osLevel2 = input.int(-60, title = 'WT Oversold Level 2', group = 'WaveTrend Settings')
osLevel3 = input.int(-75, title = 'WT Oversold Level 3', group = 'WaveTrend Settings')

// Divergence WT
wtShowDiv = input.bool(true, title = 'Show WT Regular Divergences', group = 'WaveTrend Settings')
wtShowHiddenDiv = input.bool(false, title = 'Show WT Hidden Divergences', group = 'WaveTrend Settings')
showHiddenDiv_nl = input.bool(true, title = 'Not apply OB/OS Limits on Hidden Divergences', group = 'WaveTrend Settings')
wtDivOBLevel = input.int(45, title = 'WT Bearish Divergence min', group = 'WaveTrend Settings')
wtDivOSLevel = input.int(-65, title = 'WT Bullish Divergence min', group = 'WaveTrend Settings')

// Divergence extra range
wtDivOBLevel_addshow = input.bool(true, title = 'Show 2nd WT Regular Divergences', group = 'WaveTrend Settings')
wtDivOBLevel_add = input.int(15, title = 'WT 2nd Bearish Divergence', group = 'WaveTrend Settings')
wtDivOSLevel_add = input.int(-40, title = 'WT 2nd Bullish Divergence 15 min', group = 'WaveTrend Settings')


// Realtime RSI visual endpoint helper.
// The RSI+ engine can detect a divergence before the current candle is itself a clean RSI pivot.
// These helpers anchor the drawn line/dot to the nearest recent RSI peak/trough so the line
// visually connects peak-to-peak or trough-to-trough instead of landing halfway up/down a swing.
f_rsi_rt_recent_top_offset(src, lookback) =>
    bestOffset = 0
    bestVal = src[0]
    for i = 0 to lookback
        if not na(src[i]) and (na(bestVal) or src[i] > bestVal)
            bestVal := src[i]
            bestOffset := i
    bestOffset

f_rsi_rt_recent_bot_offset(src, lookback) =>
    bestOffset = 0
    bestVal = src[0]
    for i = 0 to lookback
        if not na(src[i]) and (na(bestVal) or src[i] < bestVal)
            bestVal := src[i]
            bestOffset := i
    bestOffset

// RSI+MFI
rsiMFIperiod = input.int(60, title = 'MFI Period', group = 'MFI Settings')
rsiMFIMultiplier = input.float(150, title = 'MFI Area multiplier', group = 'MFI Settings')
rsiMFIPosY = input.float(2.5, title = 'MFI Area Y Pos', group = 'MFI Settings')
// Visual-only scale for the Money Flow layer. Keep near 1.0 for Monkey-style hugging around zero.
mfiVisualScale = input.float(1.25, title = 'MFI Visual Scale', minval = 0.1, maxval = 3.0, group = 'MFI Settings')
// Visual smoothing only. Does not change alerts, divergence detection, or signal logic.
mfiVisualSmooth = input.int(1, title = 'MFI Visual Smoothing Only', minval = 1, maxval = 10, group = 'MFI Settings')
mfiGradientPower = input.float(1.4, title = 'MFI Gradient Strength', minval = 0.0, maxval = 5.0, group = 'MFI Settings')
mfiSoftenNearZero = input.bool(true, title = 'Soften MF Near Zero', group = 'MFI Settings')
mfiSoftenLevel = input.float(8.0, title = 'MF Near Zero Soften Level', minval = 0.5, maxval = 20.0, group = 'MFI Settings')
mfiSoftenExtra = input.int(12, title = 'Extra MF Transparency Near Zero', minval = 0, maxval = 80, group = 'MFI Settings')
mfiYieldToLowStoch = input.bool(true, title = 'Reduce MF When Stoch Is Low', group = 'MFI Settings')
mfiYieldFromDateOnly = input.bool(true, title = 'Apply Low-Stoch MF Fade After Date', group = 'MFI Settings')
mfiYieldStartTime = input.time(defval = timestamp("01 Jan 2026 00:00 +0000"), title = 'Low-Stoch MF Fade Start Date', group = 'MFI Settings')
mfiYieldStochLevel = input.int(30, title = 'Stoch Priority Level', minval = 5, maxval = 60, group = 'MFI Settings')
mfiYieldExtraTransparency = input.int(48, title = 'Extra MF Transparency During Low Stoch', minval = 0, maxval = 80, group = 'MFI Settings')

// RSI
rsiSRC = input.source(close, title = 'RSI Source', group = 'RSI Settings')
rsiLen = input.int(14, title = 'RSI Length', minval = 1, group = 'RSI Settings')
rsiOversold = input.int(30, title = 'RSI Oversold Color Threshold', minval = 0, maxval = 50, group = 'RSI Settings')
rsiOverbought = input.int(70, title = 'RSI Overbought Color Threshold', minval = 50, maxval = 100, group = 'RSI Settings')
rsiLineColorMode = input.string('VWAP Dynamic', title = 'RSI Line Color Mode', options = ['VWAP Dynamic', 'VWAP Gold', 'Monkey Dynamic', 'Custom'], group = 'RSI Settings')
rsiLineCustomColor = input.color(color.new(#FFEB3B, 15), title = 'RSI Line Custom Color', group = 'RSI Settings')
rsiHoldExtremeColor = input.bool(true, title = 'Hold RSI Extreme Color Through Cross', group = 'RSI Settings')
// Visual-only: places RSI in the lower half of the pane (-100..0) so Stoch RSI can keep the normal 0..100 zone.
rsiLowerHalf = input.bool(true, title = 'Display RSI In Lower Half', group = 'RSI Settings')

// RSI smoothing line, based on TradingView-style defaults. Visual only.
rsiMaShow = input.bool(true, title = 'Show RSI Smoothing Line', group = 'RSI Settings')
rsiMaType = input.string('SMA', title = 'RSI Smoothing Type', options = ['SMA', 'EMA', 'RMA', 'WMA', 'VWMA'], group = 'RSI Settings')
rsiMaLen = input.int(14, title = 'RSI Smoothing Length', minval = 1, group = 'RSI Settings')
rsiMaColorMode = input.string('Custom', title = 'RSI Smoothing Color Mode', options = ['Custom', 'Monkey Dynamic', 'VWAP Gold'], group = 'RSI Settings')
rsiMaColor = input.color(color.new(#00BCD4, 28), title = 'RSI Smoothing Custom Color', group = 'RSI Settings')
rsiMaWidth = input.int(1, title = 'RSI Smoothing Line Width', minval = 1, maxval = 4, group = 'RSI Settings')

// RSI guide levels. These use plot() rather than hline() so they can be hidden when Show RSI is off.
rsiLevelsShow = input.bool(true, title = 'Show RSI 70/30 Levels', group = 'RSI Settings')
rsiOBGuideLevel = input.int(70, title = 'RSI Overbought Guide Level', minval = 50, maxval = 100, group = 'RSI Settings')
rsiOSGuideLevel = input.int(30, title = 'RSI Oversold Guide Level', minval = 0, maxval = 50, group = 'RSI Settings')
rsiGuideStyle = input.string('Solid', title = 'RSI Guide Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = 'RSI Settings')
rsiGuideWidth = input.int(1, title = 'RSI Guide Line Width', minval = 1, maxval = 4, group = 'RSI Settings')
rsiOBGuideColor = input.color(color.new(#FF1100, 45), title = 'RSI Overbought Guide Color', group = 'RSI Settings')
rsiOSGuideColor = input.color(color.new(#00EEFF, 45), title = 'RSI Oversold Guide Color', group = 'RSI Settings')

// Divergence RSI
rsiShowDiv = input.bool(true, title = 'Show RSI Regular Divergences', group = 'RSI Settings')
rsiShowHiddenDiv = input.bool(false, title = 'Show RSI Hidden Divergences', group = 'RSI Settings')
rsiDivDotsShow = input.bool(true, title = 'Show RSI Divergence Dots', group = 'RSI Settings')

// RSI divergence engine. Classic keeps the original cipher confirmed-fractal method.
// Realtime Pivot ports the RSI+ pivot-array divergence engine: it scans several recent price pivots and can use the current bar.
rsiDivEngine = input.string('Auto', title = 'RSI Divergence Engine', options = ['Auto', 'Cipher Classic', 'Realtime Pivot'], group = 'RSI Settings')
// Auto mode: with WT visible, use the cleaner Cipher Classic RSI divergence layer; with WT hidden, use the fuller RSI+ Realtime Pivot layer.
rsiDivEngineEffective = rsiDivEngine == 'Auto' ? (wtShow ? 'Cipher Classic' : 'Realtime Pivot') : rsiDivEngine
rsiRealtimeIncludeClassic = input.bool(true, title = 'Realtime RSI: Include Cipher Classic Divergences', group = 'RSI Settings')
rsiRealtimeShowLast = input.bool(false, title = 'Realtime RSI: Show Only Last Divergence', group = 'RSI Settings')
rsiRealtimeDotsShowLast = input.bool(false, title = 'Realtime RSI: Show Only Last Divergence Dot', group = 'RSI Settings')
rsiRealtimeDotRenderer = input.string('Aligned plot dots', title = 'Realtime RSI: Dot Renderer', options = ['Aligned plot dots', 'Clean label dots'], group = 'RSI Settings')
rsiRealtimeDontConfirm = input.bool(true, title = 'Realtime RSI: Dont Wait for Confirmation', group = 'RSI Settings')
rsiRealtimePeakEndpoint = input.bool(false, title = 'Realtime RSI: Anchor Lines To RSI Peaks', group = 'RSI Settings')
rsiRealtimeEndpointLookback = input.int(10, title = 'Realtime RSI: Peak Anchor Lookback', minval = 2, maxval = 50, group = 'RSI Settings')
rsiRealtimeSearchDiv = input.string('Regular', title = 'Realtime RSI: Divergence Type', options = ['Regular', 'Hidden', 'Regular/Hidden'], group = 'RSI Settings')
rsiRealtimePivotPeriod = input.int(5, title = 'Realtime RSI: Pivot Period', minval = 1, maxval = 50, group = 'RSI Settings')
rsiRealtimeMaxPivots = input.int(5, title = 'Realtime RSI: Max Pivots To Check', minval = 1, maxval = 20, group = 'RSI Settings')
rsiRealtimeMaxBars = input.int(150, title = 'Realtime RSI: Max Bars To Check', minval = 10, maxval = 200, group = 'RSI Settings')

rsiDivOBLevel = input.int(60, title = 'RSI Bearish Divergence min', group = 'RSI Settings')
rsiDivOSLevel = input.int(30, title = 'RSI Bullish Divergence min', group = 'RSI Settings')

// RSI Stochastic
stochUseLog = input.bool(true, title=' Use Log?', group = 'Stoch Settings')
stochAvg = input.bool(false, title='Use Average of both K & D', group = 'Stoch Settings')
stochSRC = input.source(close, title = 'Stochastic RSI Source', group = 'Stoch Settings')
stochLen = input.int(14, title = 'Stochastic RSI Length', group = 'Stoch Settings')
stochRsiLen = input.int(14, title = 'RSI Length ', group = 'Stoch Settings')
stochKSmooth = input.int(3, title = 'Stochastic RSI K Smooth', group = 'Stoch Settings')
stochDSmooth = input.int(3, title = 'Stochastic RSI D Smooth', group = 'Stoch Settings')
// Visual smoothing only. Does not affect Stoch divergence detection.
stochVisualSmooth = input.int(1, title = 'Stoch Visual Smoothing Only', minval = 1, maxval = 10, group = 'Stoch Settings')
// Visual-only: optionally places Stochastic RSI in the lower half of the pane (-100..0). Default is OFF so Stoch RSI stays in the normal 0..100 zone.
stochLowerHalf = input.bool(false, title = 'Display Stochastic RSI In Lower Half', group = 'Stoch Settings')
// Visual-only auto split. When enabled, the pane layout adapts to keep RSI and Stoch from overlapping.
// WT ON + Stoch ON        -> RSI lower / Stoch upper.
// WT ON + Stoch OFF       -> RSI upper.
// WT OFF + RSI ON         -> RSI upper / Stoch lower.
// WT OFF + RSI OFF        -> Stoch uses its manual lower-half checkbox, default OFF = upper.
autoOscSplitWhenWTHidden = input.bool(true, title = 'Auto RSI/Stoch Split When WaveTrend Hidden', group = 'Stoch Settings')
// Auto layout keeps the current rules; quick dropdowns can manually override to Upper/Lower.
rsiLowerHalfAuto = autoOscSplitWhenWTHidden ? (wtShow ? stochShow : false) : rsiLowerHalf
stochLowerHalfAuto = autoOscSplitWhenWTHidden ? (wtShow ? false : (rsiShow ? stochShow : stochLowerHalf)) : stochLowerHalf
rsiLowerHalfActive = rsiDisplayPosition == 'Lower' ? true : rsiDisplayPosition == 'Upper' ? false : rsiLowerHalfAuto
stochLowerHalfActive = stochDisplayPosition == 'Lower' ? true : stochDisplayPosition == 'Upper' ? false : stochLowerHalfAuto
showStochFill = input.bool(false, title = 'Show Stoch Fill', group = 'Stoch Settings')

// Divergence stoch
stochShowDiv = input.bool(false, title = 'Show Stoch Regular Divergences', group = 'Stoch Settings')
stochShowHiddenDiv = input.bool(false, title = 'Show Stoch Hidden Divergences', group = 'Stoch Settings')

// Schaff Trend Cycle
tcSRC = input.source(close, title = 'Schaff TC Source', group = 'Schaff Settings')
tclength = input.int(10, title="Schaff TC", group = 'Schaff Settings')
tcfastLength = input.int(23, title="Schaff TC Fast Lenght", group = 'Schaff Settings')
tcslowLength = input.int(50, title="Schaff TC Slow Length", group = 'Schaff Settings')
tcfactor = input.float(0.5, title="Schaff TC Factor", group = 'Schaff Settings')
// Visual-only: optionally places Schaff TC in the lower half of the pane (-100..0). Default is OFF so STC stays in the normal 0..100 zone.
tcLowerHalf = input.bool(false, title = 'Display Schaff TC In Lower Half', group = 'Schaff Settings')
tcLowerHalfActive = tcDisplayPosition == 'Lower' ? true : tcDisplayPosition == 'Upper' ? false : tcLowerHalf

// Sommi Flag
sommiFlagShow = input.bool(false, title = 'Show Sommi flag', group = 'Sommi Settings')
sommiShowVwap = input.bool(false, title = 'Show Sommi F. Wave', group = 'Sommi Settings')
sommiVwapTF = input.string('720', title = 'Sommi F. Wave timeframe', group = 'Sommi Settings')
sommiVwapBearLevel = input.int(0, title = 'F. Wave Bear Level (less than)', group = 'Sommi Settings')
sommiVwapBullLevel = input.int(0, title = 'F. Wave Bull Level (more than)', group = 'Sommi Settings')
soomiFlagWTBearLevel = input.int(0, title = 'WT Bear Level (more than)', group = 'Sommi Settings')
soomiFlagWTBullLevel = input.int(0, title = 'WT Bull Level (less than)', group = 'Sommi Settings')
soomiRSIMFIBearLevel = input.int(0, title = 'Money flow Bear Level (less than)', group = 'Sommi Settings')
soomiRSIMFIBullLevel = input.int(0, title = 'Money flow Bull Level (more than)', group = 'Sommi Settings')

// Sommi Diamond
sommiDiamondShow = input.bool(false, title = 'Show Sommi diamond', group = 'Sommi Settings')
sommiHTCRes = input.string('60', title = 'HTF Candle Res. 1', group = 'Sommi Settings')
sommiHTCRes2 = input.string('240', title = 'HTF Candle Res. 2', group = 'Sommi Settings')
soomiDiamondWTBearLevel = input.int(0, title = 'WT Bear Level (More than)', group = 'Sommi Settings')
soomiDiamondWTBullLevel = input.int(0, title = 'WT Bull Level (Less than)', group = 'Sommi Settings')

// macd Colors
macdWTColorsShow = input.bool(false, title = 'Show MACD Colors', group = 'MACD Settings')
macdWTColorsTF = input.string('240', title = 'MACD Colors MACD TF', group = 'MACD Settings')

darkMode = input.bool(true, title = 'Dark mode', group = 'Mode Settings')

// } PARAMETERS

// FUNCTIONS {
  
// Divergences 
f_top_fractal(src) => src[4] < src[2] and src[3] < src[2] and src[2] > src[1] and src[2] > src[0]
f_bot_fractal(src) => src[4] > src[2] and src[3] > src[2] and src[2] < src[1] and src[2] < src[0]
f_fractalize(src) => f_top_fractal(src) ? 1 : f_bot_fractal(src) ? -1 : 0

f_findDivs(src, topLimit, botLimit, useLimits) =>
    fractalTop = f_fractalize(src) > 0 and (useLimits ? src[2] >= topLimit : true)
    fractalBot = f_fractalize(src) < 0 and (useLimits ? src[2] <= botLimit : true)
    highPrev = ta.valuewhen(fractalTop, src[2], 0)[2]
    highPrice = ta.valuewhen(fractalTop, high[2], 0)[2]
    lowPrev = ta.valuewhen(fractalBot, src[2], 0)[2]
    lowPrice = ta.valuewhen(fractalBot, low[2], 0)[2]
    bearSignal = fractalTop and high[2] > highPrice and src[2] < highPrev
    bullSignal = fractalBot and low[2] < lowPrice and src[2] > lowPrev
    bearDivHidden = fractalTop and high[2] < highPrice and src[2] > highPrev
    bullDivHidden = fractalBot and low[2] > lowPrice and src[2] < lowPrev
    [fractalTop, fractalBot, lowPrev, bearSignal, bullSignal, bearDivHidden, bullDivHidden]

// Realtime RSI divergence engine support.
// This uses line.new() rather than plot(), so it does not add plot-count pressure.
// It is intentionally kept separate from WT divergence logic.
var int rsiRtMaxArraySize = 20
var array<int> rsiRtPhPositions = array.new_int(rsiRtMaxArraySize, 0)
var array<int> rsiRtPlPositions = array.new_int(rsiRtMaxArraySize, 0)
var array<float> rsiRtPhVals = array.new_float(rsiRtMaxArraySize, 0.0)
var array<float> rsiRtPlVals = array.new_float(rsiRtMaxArraySize, 0.0)
var array<line> rsiRtPosLines = array.new_line(0)
var array<line> rsiRtNegLines = array.new_line(0)
// Realtime RSI dots are drawn with labels instead of plotchar to avoid exceeding TradingView's 64-plot limit.
var array<label> rsiRtPosDotLabels = array.new_label(0)
var array<label> rsiRtNegDotLabels = array.new_label(0)

// RSI+ cleanup state: when Dont Wait For Confirmation is ON, the realtime engine can
// redraw several candidate lines from the same pivot cluster as the live swing develops.
// These counters let us remove the previous candidate group until a new RSI pivot appears,
// which removes the distracting middle/fan lines while keeping accumulated historical divergences.
var int rsiRtLastPosLines = 0
var int rsiRtLastNegLines = 0
var int rsiRtLastPosDots = 0
var int rsiRtLastNegDots = 0
var bool rsiRtRemoveLastPosDivs = false
var bool rsiRtRemoveLastNegDivs = false
var bool rsiRtRemoveLastPosDots = false
var bool rsiRtRemoveLastNegDots = false

f_delete_old_rsi_rt_pos_lines() =>
    if array.size(rsiRtPosLines) > 0
        for j = 0 to array.size(rsiRtPosLines) - 1
            line.delete(array.get(rsiRtPosLines, j))
        array.clear(rsiRtPosLines)

f_delete_old_rsi_rt_neg_lines() =>
    if array.size(rsiRtNegLines) > 0
        for j = 0 to array.size(rsiRtNegLines) - 1
            line.delete(array.get(rsiRtNegLines, j))
        array.clear(rsiRtNegLines)

// Keep accumulated realtime RSI divergence lines from growing indefinitely when Show Only Last is off.
f_trim_rsi_rt_pos_lines() =>
    if array.size(rsiRtPosLines) > 120
        line.delete(array.shift(rsiRtPosLines))

f_trim_rsi_rt_neg_lines() =>
    if array.size(rsiRtNegLines) > 120
        line.delete(array.shift(rsiRtNegLines))

f_delete_last_rsi_rt_pos_lines(n) =>
    if n > 0 and array.size(rsiRtPosLines) >= n
        asz = array.size(rsiRtPosLines)
        for j = 1 to n
            line.delete(array.get(rsiRtPosLines, asz - j))
            array.pop(rsiRtPosLines)

f_delete_last_rsi_rt_neg_lines(n) =>
    if n > 0 and array.size(rsiRtNegLines) >= n
        asz = array.size(rsiRtNegLines)
        for j = 1 to n
            line.delete(array.get(rsiRtNegLines, asz - j))
            array.pop(rsiRtNegLines)

f_delete_old_rsi_rt_pos_dots() =>
    if array.size(rsiRtPosDotLabels) > 0
        for j = 0 to array.size(rsiRtPosDotLabels) - 1
            label.delete(array.get(rsiRtPosDotLabels, j))
        array.clear(rsiRtPosDotLabels)

f_delete_old_rsi_rt_neg_dots() =>
    if array.size(rsiRtNegDotLabels) > 0
        for j = 0 to array.size(rsiRtNegDotLabels) - 1
            label.delete(array.get(rsiRtNegDotLabels, j))
        array.clear(rsiRtNegDotLabels)

f_trim_rsi_rt_pos_dots() =>
    if array.size(rsiRtPosDotLabels) > 40
        label.delete(array.shift(rsiRtPosDotLabels))

f_trim_rsi_rt_neg_dots() =>
    if array.size(rsiRtNegDotLabels) > 40
        label.delete(array.shift(rsiRtNegDotLabels))

f_delete_last_rsi_rt_pos_dots(n) =>
    if n > 0 and array.size(rsiRtPosDotLabels) >= n
        asz = array.size(rsiRtPosDotLabels)
        for j = 1 to n
            label.delete(array.get(rsiRtPosDotLabels, asz - j))
            array.pop(rsiRtPosDotLabels)

f_delete_last_rsi_rt_neg_dots(n) =>
    if n > 0 and array.size(rsiRtNegDotLabels) >= n
        asz = array.size(rsiRtNegDotLabels)
        for j = 1 to n
            label.delete(array.get(rsiRtNegDotLabels, asz - j))
            array.pop(rsiRtNegDotLabels)

// cond == 1: bullish regular. cond == 2: bullish hidden.
f_rsi_rt_positive_regular_or_negative_hidden(src, cond) =>
    divlen = 0
    prsc = close
    if rsiRealtimeDontConfirm or src > src[1] or close > close[1]
        startpoint = rsiRealtimeDontConfirm ? 0 : 1
        for x = 0 to rsiRealtimeMaxPivots - 1
            pivotPos = array.get(rsiRtPlPositions, x)
            len = bar_index - pivotPos + rsiRealtimePivotPeriod
            if pivotPos == 0 or len > rsiRealtimeMaxBars
                break
            if len > 5 and ((cond == 1 and src[startpoint] > src[len] and prsc[startpoint] < nz(array.get(rsiRtPlVals, x))) or (cond == 2 and src[startpoint] < src[len] and prsc[startpoint] > nz(array.get(rsiRtPlVals, x))))
                slope1 = (src[startpoint] - src[len]) / (len - startpoint)
                virtualLine1 = src[startpoint] - slope1
                slope2 = (prsc[startpoint] - prsc[len]) / (len - startpoint)
                virtualLine2 = prsc[startpoint] - slope2
                arrived = true
                for y = 1 + startpoint to len - 1
                    if src[y] < virtualLine1 or nz(prsc[y]) < virtualLine2
                        arrived := false
                        break
                    virtualLine1 := virtualLine1 - slope1
                    virtualLine2 := virtualLine2 - slope2
                if arrived
                    divlen := len
                    break
    divlen

// cond == 1: bearish regular. cond == 2: bearish hidden.
f_rsi_rt_negative_regular_or_positive_hidden(src, cond) =>
    divlen = 0
    prsc = close
    if rsiRealtimeDontConfirm or src < src[1] or close < close[1]
        startpoint = rsiRealtimeDontConfirm ? 0 : 1
        for x = 0 to rsiRealtimeMaxPivots - 1
            pivotPos = array.get(rsiRtPhPositions, x)
            len = bar_index - pivotPos + rsiRealtimePivotPeriod
            if pivotPos == 0 or len > rsiRealtimeMaxBars
                break
            if len > 5 and ((cond == 1 and src[startpoint] < src[len] and prsc[startpoint] > nz(array.get(rsiRtPhVals, x))) or (cond == 2 and src[startpoint] > src[len] and prsc[startpoint] < nz(array.get(rsiRtPhVals, x))))
                slope1 = (src[startpoint] - src[len]) / (len - startpoint)
                virtualLine1 = src[startpoint] - slope1
                slope2 = (prsc[startpoint] - nz(prsc[len])) / (len - startpoint)
                virtualLine2 = prsc[startpoint] - slope2
                arrived = true
                for y = 1 + startpoint to len - 1
                    if src[y] > virtualLine1 or nz(prsc[y]) > virtualLine2
                        arrived := false
                        break
                    virtualLine1 := virtualLine1 - slope1
                    virtualLine2 := virtualLine2 - slope2
                if arrived
                    divlen := len
                    break
    divlen


// RSI+MFI
f_rsimfi(_period, _multiplier, _tf) => request.security(syminfo.tickerid, _tf, ta.sma(((close - open) / (high - low)) * _multiplier, _period) - rsiMFIPosY)
   
// WaveTrend
f_wavetrend(src, chlen, avg, malen, tf) =>
    tfsrc = request.security(syminfo.tickerid, tf, src)
    esa = ta.ema(tfsrc, chlen)
    de = ta.ema(math.abs(tfsrc - esa), chlen)
    ci = (tfsrc - esa) / (0.015 * de)
    wt1 = request.security(syminfo.tickerid, tf, ta.ema(ci, avg))
    wt2 = request.security(syminfo.tickerid, tf, ta.sma(wt1, malen))
    wtVwap = wt1 - wt2
    wtOversold = wt2 <= osLevel
    wtOverbought = wt2 >= obLevel
    wtCross = ta.cross(wt1, wt2)
    wtCrossUp = wt2 - wt1 <= 0
    wtCrossDown = wt2 - wt1 >= 0
    wtCrosslast = ta.cross(wt1[2], wt2[2])
    wtCrossUplast = wt2[2] - wt1[2] <= 0
    wtCrossDownlast = wt2[2] - wt1[2] >= 0
    [wt1, wt2, wtOversold, wtOverbought, wtCross, wtCrossUp, wtCrossDown, wtCrosslast, wtCrossUplast, wtCrossDownlast, wtVwap]

// Schaff Trend Cycle
f_tc(src, length, fastLength, slowLength) =>
    ema1 = ta.ema(src, fastLength)
    ema2 = ta.ema(src, slowLength)
    macdVal = ema1 - ema2	
    alpha = ta.lowest(macdVal, length)
    beta = ta.highest(macdVal, length) - alpha
    gamma = (macdVal - alpha) / beta * 100
    gamma := beta > 0 ? gamma : nz(gamma[1])
    delta = gamma
    delta := na(delta[1]) ? delta : delta[1] + tcfactor * (gamma - delta[1])
    epsilon = ta.lowest(delta, length)
    zeta = ta.highest(delta, length) - epsilon
    eta = (delta - epsilon) / zeta * 100
    eta := zeta > 0 ? eta : nz(eta[1])
    stcReturn = eta
    stcReturn := na(stcReturn[1]) ? stcReturn : stcReturn[1] + tcfactor * (eta - stcReturn[1])
    stcReturn

// Stochastic RSI
f_stochrsi(_src, _stochlen, _rsilen, _smoothk, _smoothd, _log, _avg) =>
    src = _log ? math.log(_src) : _src
    rsi = ta.rsi(src, _rsilen)
    kk = ta.sma(ta.stoch(rsi, rsi, rsi, _stochlen), _smoothk)
    d1 = ta.sma(kk, _smoothd)
    avg_1 = math.avg(kk, d1)
    k = _avg ? avg_1 : kk
    [k, d1]

// Generic MA helper for RSI smoothing line
// Written as an if/else block for Pine v6 compatibility. Multi-line ternaries are fragile in v4.
f_ma(_src, _len, _type) =>
    if _type == 'SMA'
        ta.sma(_src, _len)
    else if _type == 'EMA'
        ta.ema(_src, _len)
    else if _type == 'RMA'
        ta.rma(_src, _len)
    else if _type == 'WMA'
        ta.wma(_src, _len)
    else if _type == 'VWMA'
        ta.vwma(_src, _len)
    else
        na

// MACD
f_macd(src, fastlen, slowlen, sigsmooth, tf) =>
    fast_ma = request.security(syminfo.tickerid, tf, ta.ema(src, fastlen))
    slow_ma = request.security(syminfo.tickerid, tf, ta.ema(src, slowlen))
    macd = fast_ma - slow_ma
    signal = request.security(syminfo.tickerid, tf, ta.sma(macd, sigsmooth))
    hist = macd - signal
    [macd, signal, hist]

// MACD Colors on WT    
f_macdWTColors(tf) =>
    hrsimfi = f_rsimfi(rsiMFIperiod, rsiMFIMultiplier, tf)
    [macd, signal, hist] = f_macd(close, 28, 42, 9, macdWTColorsTF)
    macdup = macd >= signal
    macddown = macd <= signal
    macdWT1Color = macdup ? hrsimfi > 0 ? #4db6ac : #00897b : macddown ? hrsimfi < 0 ? #e57373 : #d32f2f : na
    macdWT2Color = macdup ? hrsimfi < 0 ? #00241b : #004d40 : macddown ? hrsimfi < 0 ? #5d0000 : #b71c1c : na
    [macdWT1Color, macdWT2Color]
    
// Get higher timeframe candle
f_getTFCandle(_tf) =>
    _open  = request.security(ticker.heikinashi(syminfo.tickerid), _tf, open, barmerge.gaps_off, barmerge.lookahead_on)
    _close = request.security(ticker.heikinashi(syminfo.tickerid), _tf, close, barmerge.gaps_off, barmerge.lookahead_on)
    _high  = request.security(ticker.heikinashi(syminfo.tickerid), _tf, high, barmerge.gaps_off, barmerge.lookahead_on)
    _low   = request.security(ticker.heikinashi(syminfo.tickerid), _tf, low, barmerge.gaps_off, barmerge.lookahead_on)
    haMid = (_high + _low) / 2.0
    newBar = ta.change(_open)
    candleBodyDir = _close > _open
    [candleBodyDir, newBar]

// Sommi flag
f_findSommiFlag(tf, wt1, wt2, rsimfi, wtCross, wtCrossUp, wtCrossDown) =>    
    [hwt1, hwt2, hwtOversold, hwtOverbought, hwtCross, hwtCrossUp, hwtCrossDown, hwtCrosslast, hwtCrossUplast, hwtCrossDownlast, wtVwap] = f_wavetrend(wtMASource, wtChannelLen, wtAverageLen, wtMALen, tf)      
    bearPattern = rsimfi < soomiRSIMFIBearLevel and wt2 > soomiFlagWTBearLevel and wtCross and wtCrossDown and wtVwap < sommiVwapBearLevel
    bullPattern = rsimfi > soomiRSIMFIBullLevel and wt2 < soomiFlagWTBullLevel and wtCross and wtCrossUp and wtVwap > sommiVwapBullLevel
    [bearPattern, bullPattern, wtVwap]
    
f_findSommiDiamond(tf, tf2, wt1, wt2, wtCross, wtCrossUp, wtCrossDown) =>
    [candleBodyDir, newBar] = f_getTFCandle(tf)
    [candleBodyDir2, newBar2] = f_getTFCandle(tf2)
    bearPattern = wt2 >= soomiDiamondWTBearLevel and wtCross and wtCrossDown and not candleBodyDir and not candleBodyDir2                   
    bullPattern = wt2 <= soomiDiamondWTBullLevel and wtCross and wtCrossUp and candleBodyDir and candleBodyDir2
    [bearPattern, bullPattern]
 
// } FUNCTIONS  

// CALCULATE INDICATORS {

// RSI
rsi = ta.rsi(rsiSRC, rsiLen)
// Monkey Double RSI colours from screenshots:
// RSI line defaults now use 85% opacity -> Pine transparency 15
rsiobcolor = input.color(color.new(#FF1100, 15), 'RSI OverBought', group = 'Color Settings')
rsioscolor = input.color(color.new(#00EEFF, 15), 'RSI OverSold', group = 'Color Settings')
rsinacolor = input.color(color.new(#CA1BFF, 15), 'RSI InBetween', group = 'Color Settings')
rsiColor = rsi <= rsiOversold ? rsioscolor : rsi >= rsiOverbought ? rsiobcolor : rsinacolor
// RSI line defaults to VWAP Dynamic: gold in the middle, cyan at oversold, red at overbought.
// The hold option keeps the segment coloured through the actual OB/OS cross, so the exit leg is not cut back to gold too early.
rsiGoldColor = color.new(#FFEB3B, 15)
rsiWasOS = nz(rsi[1]) <= rsiOversold
rsiWasOB = nz(rsi[1]) >= rsiOverbought
rsiNowOS = rsi <= rsiOversold
rsiNowOB = rsi >= rsiOverbought
rsiVwapDynamicColor = (rsiNowOS or (rsiHoldExtremeColor and rsiWasOS)) ? rsioscolor : (rsiNowOB or (rsiHoldExtremeColor and rsiWasOB)) ? rsiobcolor : rsiGoldColor
rsiPlotColor = rsiLineColorMode == 'VWAP Dynamic' ? rsiVwapDynamicColor : rsiLineColorMode == 'Monkey Dynamic' ? rsiVwapDynamicColor : rsiLineColorMode == 'VWAP Gold' ? rsiGoldColor : rsiLineCustomColor
rsiMA = f_ma(rsi, rsiMaLen, rsiMaType)
// Visual remap only. RSI logic/divergence detection still uses the raw 0..100 RSI.
rsiVisual = rsiLowerHalfActive ? rsi - 100 : rsi
rsiMAVisual = rsiLowerHalfActive ? rsiMA - 100 : rsiMA
rsiOBGuideVisual = rsiLowerHalfActive ? rsiOBGuideLevel - 100 : rsiOBGuideLevel
rsiOSGuideVisual = rsiLowerHalfActive ? rsiOSGuideLevel - 100 : rsiOSGuideLevel
// RSI MA colour options. Default is a static muted purple so the RSI line can carry the cyan/red zone information.
rsiMaMonkeyColor = rsiMA <= rsiOSGuideLevel ? color.new(#00EEFF, 34) : rsiMA >= rsiOBGuideLevel ? color.new(#FF1100, 34) : color.new(#CA1BFF, 42)
rsiMaGoldColor = color.new(#FFEB3B, 42)
rsiMaPlotColor = rsiMaColorMode == 'Custom' ? rsiMaColor : rsiMaColorMode == 'Monkey Dynamic' ? rsiMaMonkeyColor : rsiMaGoldColor

// RSI guide lines: dynamic series so they only draw when RSI is visible.
// Pine cannot draw true conditional dashed hlines, so dashed/dotted are approximated with denser on/off plot segments.
rsiGuideDashOn = rsiGuideStyle == 'Solid' ? true : rsiGuideStyle == 'Dashed' ? (bar_index % 5 < 4) : (bar_index % 2 == 0)
rsiOBGuideSeries = rsiShow and rsiLevelsShow and rsiGuideDashOn ? rsiOBGuideVisual : na
rsiOSGuideSeries = rsiShow and rsiLevelsShow and rsiGuideDashOn ? rsiOSGuideVisual : na

// RSI + MFI Area (Monkey Cipher Colors)
rsiMFI = f_rsimfi(rsiMFIperiod, rsiMFIMultiplier, timeframe.period)
rsiMFIColorAbove = input.color(color.new(#00EEFF, 72), 'MFI Color > 0', group = 'Color Settings')
rsiMFIColorBelow = input.color(color.new(#FF1100, 72), 'MFI Color < 0', group = 'Color Settings')
rsiMFIColor = rsiMFI > 0 ? rsiMFIColorAbove : rsiMFIColorBelow

// Calculates WaveTrend
[wt1, wt2, wtOversold, wtOverbought, wtCross, wtCrossUp, wtCrossDown, wtCross_last, wtCrossUp_last, wtCrossDown_last, wtVwap] = f_wavetrend(wtMASource, wtChannelLen, wtAverageLen, wtMALen, timeframe.period)
 
// Stochastic RSI
[stochK, stochD] = f_stochrsi(stochSRC, stochLen, stochRsiLen, stochKSmooth, stochDSmooth, stochUseLog, stochAvg)

// Schaff Trend Cycle
tcVal = f_tc(tcSRC, tclength, tcfastLength, tcslowLength)
// Visual remap only. Schaff logic still uses the raw 0..100 STC value.
tcValDisplay = tcLowerHalfActive ? tcVal - 100 : tcVal

// Sommi flag
[sommiBearish, sommiBullish, hvwap] = f_findSommiFlag(sommiVwapTF, wt1, wt2, rsiMFI, wtCross,  wtCrossUp, wtCrossDown)

//Sommi diamond
[sommiBearishDiamond, sommiBullishDiamond] = f_findSommiDiamond(sommiHTCRes, sommiHTCRes2, wt1, wt2, wtCross, wtCrossUp, wtCrossDown)

// macd colors
[macdWT1Color, macdWT2Color] = f_macdWTColors(macdWTColorsTF)

// WT Divergences
[wtFractalTop, wtFractalBot, wtLow_prev, wtBearDiv, wtBullDiv, wtBearDivHidden, wtBullDivHidden] = f_findDivs(wt2, wtDivOBLevel, wtDivOSLevel, true)
[wtFractalTop_add, wtFractalBot_add, wtLow_prev_add, wtBearDiv_add, wtBullDiv_add, wtBearDivHidden_add, wtBullDivHidden_add] =  f_findDivs(wt2, wtDivOBLevel_add, wtDivOSLevel_add, true)
[wtFractalTop_nl, wtFractalBot_nl, wtLow_prev_nl, wtBearDiv_nl, wtBullDiv_nl, wtBearDivHidden_nl, wtBullDivHidden_nl] =  f_findDivs(wt2, 0, 0, false)

wtBearDivHidden_ = showHiddenDiv_nl ? wtBearDivHidden_nl : wtBearDivHidden
wtBullDivHidden_ = showHiddenDiv_nl ? wtBullDivHidden_nl : wtBullDivHidden

WTBearDivColorDown = input.color(color.new(#FF1100, 0), 'WT Bear Div', group = 'Color Settings')
wtBullDivColorUp = input.color(color.new(#00EEFF, 0), 'WT Bull Div', group = 'Color Settings')

wtBearDivColor = (wtShowDiv and wtBearDiv) or (wtShowHiddenDiv and wtBearDivHidden_) ? WTBearDivColorDown : na
wtBullDivColor = (wtShowDiv and wtBullDiv) or (wtShowHiddenDiv and wtBullDivHidden_) ? wtBullDivColorUp : na

wtBearDivColor_add = (wtShowDiv and (wtDivOBLevel_addshow and wtBearDiv_add)) or (wtShowHiddenDiv and (wtDivOBLevel_addshow and wtBearDivHidden_add)) ? WTBearDivColorDown: na
wtBullDivColor_add = (wtShowDiv and (wtDivOBLevel_addshow and wtBullDiv_add)) or (wtShowHiddenDiv and (wtDivOBLevel_addshow and wtBullDivHidden_add)) ? wtBullDivColorUp : na

// RSI Divergences
[rsiFractalTop, rsiFractalBot, rsiLow_prev, rsiBearDiv, rsiBullDiv, rsiBearDivHidden, rsiBullDivHidden] = f_findDivs(rsi, rsiDivOBLevel, rsiDivOSLevel, true)
[rsiFractalTop_nl, rsiFractalBot_nl, rsiLow_prev_nl, rsiBearDiv_nl, rsiBullDiv_nl, rsiBearDivHidden_nl, rsiBullDivHidden_nl] = f_findDivs(rsi, 0, 0, false)

rsiBearDivHidden_ = showHiddenDiv_nl ? rsiBearDivHidden_nl : rsiBearDivHidden
rsiBullDivHidden_ = showHiddenDiv_nl ? rsiBullDivHidden_nl : rsiBullDivHidden

// RSI divergence colours are deliberately different from WT divergence colours.
// WT uses cyan/red; RSI defaults to olive-lime/magenta so the source of the divergence is easier to distinguish.
rsiBearColor = input.color(color.new(#CA1BFF, 0), 'RSI Bear Div', group = 'Color Settings')
rsiBullColor = input.color(color.new(#B7FF5A, 0), 'RSI Bull Div', group = 'Color Settings')

rsiClassicDivActive = rsiDivEngineEffective == 'Cipher Classic' or (rsiDivEngineEffective == 'Realtime Pivot' and rsiRealtimeIncludeClassic)
// Active RSI divergence engine flags. Defined here before the panel-dot routing uses them.
// Realtime RSI divergence calculations stay active even if the RSI line itself is hidden,
// so RSI divergence dots can still be shown as panel-level markers.
rsiRealtimeActive = rsiDivEngineEffective == 'Realtime Pivot' and (rsiShowDiv or rsiShowHiddenDiv)
rsiClassicBullDivForSignals = rsiClassicDivActive and rsiBullDiv
rsiClassicBearDivForSignals = rsiClassicDivActive and rsiBearDiv
rsiBearDivColor = rsiShow and rsiClassicDivActive and ((rsiShowDiv and rsiBearDiv) or (rsiShowHiddenDiv and rsiBearDivHidden_)) ? rsiBearColor : na
rsiBullDivColor = rsiShow and rsiClassicDivActive and ((rsiShowDiv and rsiBullDiv) or (rsiShowHiddenDiv and rsiBullDivHidden_)) ? rsiBullColor : na
 
// Stoch Divergences
[stochFractalTop, stochFractalBot, stochLow_prev, stochBearDiv, stochBullDiv, stochBearDivHidden, stochBullDivHidden] = f_findDivs(stochK, 0, 0, false)

stochbearcolor = color.new(#ff1744, 0)
stochbullcolor = color.new(#00e676, 0)

stochBearDivColor = (stochShowDiv and stochBearDiv) or (stochShowHiddenDiv and stochBearDivHidden) ? stochbearcolor : na
stochBullDivColor = (stochShowDiv and stochBullDiv) or (stochShowHiddenDiv and stochBullDivHidden) ? stochbullcolor : na

// Small Circles WT Cross
signalcolorup = input.color(color.new(#00EEFF, 0), 'WT Buy Dot', group = 'Color Settings')
signalcolordown = input.color(color.new(#FF1100, 0), 'WT Sell Dot', group = 'Color Settings')

signalColor = wt2 - wt1 > 0 ? signalcolordown : signalcolorup

// Buy signal.
buySignal = wtCross and wtCrossUp and wtOversold

buySignalDiv = (wtShowDiv and wtBullDiv) or (wtShowDiv and wtBullDiv_add) or (stochShowDiv and stochBullDiv) or (rsiShow and rsiShowDiv and rsiClassicBullDivForSignals)
buySignalDiv_color = wtBullDiv ? wtBullDivColorUp : wtBullDiv_add ? color.new(#00EEFF, 60) : (rsiShow and rsiClassicBullDivForSignals) ? rsiBullColor : stochBullDiv ? stochbullcolor : na

// Sell signal
sellSignal = wtCross and wtCrossDown and wtOverbought
sellSignalDiv = (wtShowDiv and wtBearDiv) or (wtShowDiv and wtBearDiv_add) or (stochShowDiv and stochBearDiv) or (rsiShow and rsiShowDiv and rsiClassicBearDivForSignals)
sellSignalDiv_color = wtBearDiv ? WTBearDivColorDown : wtBearDiv_add ? color.new(#FF1100, 60) : (rsiShow and rsiClassicBearDivForSignals) ? rsiBearColor : stochBearDiv ? stochbearcolor : na

// Gold Buy 
lastRsi = ta.valuewhen(wtFractalBot, rsi[2], 0)[2]
// Gold-dot logic keeps the original internal RSI contribution even when the RSI visual layer is hidden.
// Show RSI only controls RSI visuals; it does not weaken the gold-dot filter/confirmation.
rsiBullDivForGoldDot = rsiShowDiv and rsiClassicBullDivForSignals
wtGoldBuy = ((wtShowDiv and wtBullDiv) or rsiBullDivForGoldDot) and wtLow_prev <= osLevel3 and wt2 > osLevel3 and wtLow_prev - wt2 <= -5 and lastRsi < 30          

// Divergence dot routing.
// WT divergence lines still use the raw WT2 anchor, but the top/bottom WT dots are signal-only.
// The bright WT top/bottom dot is independent of the WT divergence display toggles: even if WT
// divergence lines on the hills are hidden, the dot still tells us when a buy/sell signal also
// coincided with a confirmed WT divergence at that pivot.
// Hidden divergences only contribute here when the hidden-divergence setting is enabled,
// so the bright dots do not get triggered by hidden divergences the user has not chosen to use.
wtBullConfirmedDivRaw = wtBullDiv or (wtDivOBLevel_addshow and wtBullDiv_add) or (wtShowHiddenDiv and (wtBullDivHidden_ or (wtDivOBLevel_addshow and wtBullDivHidden_add)))
wtBearConfirmedDivRaw = wtBearDiv or (wtDivOBLevel_addshow and wtBearDiv_add) or (wtShowHiddenDiv and (wtBearDivHidden_ or (wtDivOBLevel_addshow and wtBearDivHidden_add)))

rsiBullDivDot = wtDivShow and rsiDivDotsShow and rsiClassicDivActive and ((rsiShowDiv and rsiBullDiv) or (rsiShowHiddenDiv and rsiBullDivHidden_))
rsiBearDivDot = wtDivShow and rsiDivDotsShow and rsiClassicDivActive and ((rsiShowDiv and rsiBearDiv) or (rsiShowHiddenDiv and rsiBearDivHidden_))
stochBullDivDot = stochShow and wtDivShow and ((stochShowDiv and stochBullDiv) or (stochShowHiddenDiv and stochBullDivHidden))
stochBearDivDot = stochShow and wtDivShow and ((stochShowDiv and stochBearDiv) or (stochShowHiddenDiv and stochBearDivHidden))

// Top/bottom confirmation dots.
// WT top/bottom dots are signal markers, not every-divergence marker.
// They remain visible even when the WaveTrend hills are hidden, so the signal layer is not lost.
// v84 architecture:
// - ordinary faded buy/sell dots print immediately when the qualified WT signal occurs;
// - if a matching WT divergence confirms within the upgrade window, a bright dot is plotted
//   back over that same original signal candle on the actual confirmation bar.
// This separates timing from confirmation without delaying the ordinary dot.
wtBuySignalDot = wtBuyShow and buySignal
wtSellSignalDot = wtSellShow and sellSignal

// Exact bright-upgrade paths for a 0/1/2-bar window.
// Using separate fixed-offset plotchar calls keeps the bright overlay aligned with the original
// signal candle while avoiding a second dot on the divergence-confirmation candle.
wtBuySignalDotBright0 = wtBuyShow and wtSignalDivMatchBars >= 0 and buySignal and wtBullConfirmedDivRaw
wtBuySignalDotBright1 = wtBuyShow and wtSignalDivMatchBars >= 1 and buySignal[1] and wtBullConfirmedDivRaw
wtBuySignalDotBright2 = wtBuyShow and wtSignalDivMatchBars >= 2 and buySignal[2] and wtBullConfirmedDivRaw
wtSellSignalDotBright0 = wtSellShow and wtSignalDivMatchBars >= 0 and sellSignal and wtBearConfirmedDivRaw
wtSellSignalDotBright1 = wtSellShow and wtSignalDivMatchBars >= 1 and sellSignal[1] and wtBearConfirmedDivRaw
wtSellSignalDotBright2 = wtSellShow and wtSignalDivMatchBars >= 2 and sellSignal[2] and wtBearConfirmedDivRaw

// RSI top/bottom divergence dots remain separate because RSI divergences are less frequent
// and are easier to read as panel-level markers. Stoch dots are not routed here by default
// to keep the panel cleaner.
// Classic RSI panel dots are shown only when the Classic engine is the active visual engine.
// When the Realtime engine is active, realtime label-dots handle the RSI divergence dots.
// This prevents double dots and mixed plot/label vertical alignment on the top row.
buySignalDivDot = rsiBullDivDot and not rsiRealtimeActive
sellSignalDivDot = rsiBearDivDot and not rsiRealtimeActive

// Top/bottom panel marker rows.
// The sell/bearish row is lifted higher so the panel dots stay clear of tall WT hills
// and do not clash with the signal dots plotted on the hills themselves.
topPanelDotY = 105
bottomPanelDotY = -107

// Realtime RSI dots are labels rather than plotchar so they do not consume extra plot slots.
// Keep them on the exact same Y rows as the plotchar panel dots; the larger text size below
// makes them visually match the WT-on/classic dots much more closely when WaveTrend is hidden.
rsiRtTopPanelDotY = topPanelDotY
rsiRtBottomPanelDotY = bottomPanelDotY

// All top/bottom panel dots use the same visual size; only colour/brightness changes.
buySignalDiv_y = bottomPanelDotY
sellSignalDiv_y = topPanelDotY
buySignalDivDotColor = rsiBullDivDot ? rsiBullColor : na
sellSignalDivDotColor = rsiBearDivDot ? rsiBearColor : na
          
// } CALCULATE INDICATORS

// UI COLOR INPUTS (Monkey Pro Layers)
// Hex alpha screenshots converted to Pine transparency:
// #2962FF95 -> color.new(#2962FF, 42)
// #040A1ADF -> color.new(#040A1A, 13)
// #FFEB3B50 -> color.new(#FFEB3B, 69)
// #FFEB3B30 -> color.new(#FFEB3B, 81)
// #00EEFF40 / #FF110040 -> color.new(..., 75)
// #00EEFFFF / #FF1100FF -> color.new(..., 0)
// #00EEFF90 / #FF110090 -> color.new(..., 44)
// Double RSI: #CA1BFFB7 / #00EEFFB7 / #FF1100B7 -> color.new(..., 28)
// WT hills now use the classic WT1/WT2 overlap render, but with Monkey-style colours.
// WT1 is the blue outer hill; WT2 is the dark inner body. This makes the point where WT2 overtakes WT1 visually obvious.
wt1FillColor = input.color(color.new(#2962FF, 42), 'WT1 Blue Hill Area', group = 'Color Settings')
wt2FillColor = input.color(color.new(#040A1A, 13), 'WT2 Dark Body Area', group = 'Color Settings')
vwapLineColor = input.color(color.new(#FFEB3B, 35), 'VWAP Line', group = 'Color Settings')
vwapFillColor = input.color(color.new(#FFEB3B, 78), 'VWAP Fill', group = 'Color Settings')
mfiOutlineColorAbove = input.color(color.new(#00EEFF, 0), 'MFI Outline > 0', group = 'Color Settings')
mfiOutlineColorBelow = input.color(color.new(#FF1100, 0), 'MFI Outline < 0', group = 'Color Settings')
stochKColorInput = input.color(color.new(#00EEFF, 0), 'Stoch K', group = 'Color Settings')
stochDColorInput = input.color(color.new(#CA1BFF, 8), 'Stoch D', group = 'Color Settings')
bigBuyDotColor = input.color(color.new(#00EEFF, 44), 'Big Buy Dot', group = 'Color Settings')
bigSellDotColor = input.color(color.new(#FF1100, 44), 'Big Sell Dot', group = 'Color Settings')

// Ordinary buy/sell signal dots stay slightly faded.
// If the signal also coincides with a confirmed WT divergence, the separate top/bottom
// confirmation dot above is plotted in full-bright cyan/red.
buySignalDotDisplayColor = bigBuyDotColor
sellSignalDotDisplayColor = bigSellDotColor
// Ordinary row dots are always faded; bright upgrades are plotted separately on top
// with fixed offsets, so no aggregate bright colour variable is needed here.
wtBuySignalDotColor = buySignalDotDisplayColor
wtSellSignalDotColor = sellSignalDotDisplayColor

// Optional legacy MACD-colour mode. Off by default to preserve the Monkey-style blue/navy WT look.
wt1AreaColorApplied = macdWTColorsShow ? color.new(macdWT1Color, 42) : wt1FillColor
wt2AreaColorApplied = macdWTColorsShow ? color.new(macdWT2Color, 13) : wt2FillColor

// Monkey-style visual toggles. These only change what is drawn; they do not change the underlying divergence/signal calculations.
showDivergenceLinesVisual = input.bool(true, title = 'Show Divergence Lines', group = 'Visual Match Settings')
divLineWidth = input.int(1, title = 'Divergence Line Width', minval = 1, maxval = 3, group = 'Visual Match Settings')

// Realtime RSI pivot divergence engine.
// Ported from the RSI+ pivot-array method: pivot arrays, max pivot scan, max bars scan,
// regular/hidden modes, show-last line deletion, and optional current-bar endpoint.
// Default endpoint mode is RSI+ exact; optional peak anchoring is visual-only and can be enabled later.
rsiRtPh = ta.pivothigh(close, rsiRealtimePivotPeriod, rsiRealtimePivotPeriod)
rsiRtPl = ta.pivotlow(close, rsiRealtimePivotPeriod, rsiRealtimePivotPeriod)

// Once a new confirmed RSI pivot appears, previous realtime candidates are now historical,
// so the next divergence is allowed to create a new group rather than replacing the last one.
if rsiRealtimeActive and not na(rsiRtPl)
    rsiRtRemoveLastPosDivs := false
    rsiRtLastPosLines := 0
    rsiRtRemoveLastPosDots := false
    rsiRtLastPosDots := 0

if rsiRealtimeActive and not na(rsiRtPh)
    rsiRtRemoveLastNegDivs := false
    rsiRtLastNegLines := 0
    rsiRtRemoveLastNegDots := false
    rsiRtLastNegDots := 0

if rsiRealtimeActive and not na(rsiRtPh)
    array.unshift(rsiRtPhPositions, bar_index)
    array.unshift(rsiRtPhVals, rsiRtPh)
    if array.size(rsiRtPhPositions) > rsiRtMaxArraySize
        array.pop(rsiRtPhPositions)
        array.pop(rsiRtPhVals)

if rsiRealtimeActive and not na(rsiRtPl)
    array.unshift(rsiRtPlPositions, bar_index)
    array.unshift(rsiRtPlVals, rsiRtPl)
    if array.size(rsiRtPlPositions) > rsiRtMaxArraySize
        array.pop(rsiRtPlPositions)
        array.pop(rsiRtPlVals)

rsiRtAllowRegular = rsiShowDiv and (rsiRealtimeSearchDiv == 'Regular' or rsiRealtimeSearchDiv == 'Regular/Hidden')
rsiRtAllowHidden = rsiShowHiddenDiv and (rsiRealtimeSearchDiv == 'Hidden' or rsiRealtimeSearchDiv == 'Regular/Hidden')

rsiRtBullRegLen = rsiRealtimeActive and rsiRtAllowRegular ? f_rsi_rt_positive_regular_or_negative_hidden(rsi, 1) : 0
rsiRtBearRegLen = rsiRealtimeActive and rsiRtAllowRegular ? f_rsi_rt_negative_regular_or_positive_hidden(rsi, 1) : 0
// Match RSI+ exactly: bullish hidden uses pivot lows, bearish hidden uses pivot highs.
rsiRtBullHidLen = rsiRealtimeActive and rsiRtAllowHidden ? f_rsi_rt_positive_regular_or_negative_hidden(rsi, 2) : 0
rsiRtBearHidLen = rsiRealtimeActive and rsiRtAllowHidden ? f_rsi_rt_negative_regular_or_positive_hidden(rsi, 2) : 0

rsiRtStartPoint = rsiRealtimeDontConfirm ? 0 : 1
// RSI+ exact mode uses the detection endpoint (usually current bar when Dont Wait For Confirmation is ON).
// Peak-anchor mode is optional and visual only.
rsiRtBullEndpointRaw = rsiRealtimePeakEndpoint ? f_rsi_rt_recent_bot_offset(rsi, rsiRealtimeEndpointLookback) : rsiRtStartPoint
rsiRtBearEndpointRaw = rsiRealtimePeakEndpoint ? f_rsi_rt_recent_top_offset(rsi, rsiRealtimeEndpointLookback) : rsiRtStartPoint

// Realtime RSI divergence detections for optional panel-level dots.
// These are separate from Classic RSI dots because the realtime engine can use the current bar as its endpoint.
rsiRtBullDivDot = rsiRealtimeActive and rsiDivDotsShow and ((rsiRtAllowRegular and rsiRtBullRegLen > 0) or (rsiRtAllowHidden and rsiRtBullHidLen > 0))
rsiRtBearDivDot = rsiRealtimeActive and rsiDivDotsShow and ((rsiRtAllowRegular and rsiRtBearRegLen > 0) or (rsiRtAllowHidden and rsiRtBearHidLen > 0))
// Plotchar dots match the normal panel dots perfectly, but cannot be deleted historically.
// Label dots can be cleaned up with realtime candidate lines, but TradingView renders them slightly differently.
rsiRtUseLabelDots = rsiRealtimeDotRenderer == 'Clean label dots' or rsiRealtimeDotsShowLast

// Realtime RSI dots may show with RSI hidden, but realtime RSI lines remain part of the RSI visual layer.
rsiRtDraw = rsiShow and rsiRealtimeActive and showDivergenceLinesVisual
rsiRtPosHasDiv = rsiRtBullRegLen > 0 or rsiRtBullHidLen > 0
rsiRtNegHasDiv = rsiRtBearRegLen > 0 or rsiRtBearHidLen > 0

// Match the RSI+ behaviour more closely by replacing the last live candidate group
// until a new pivot confirms. This removes the middle/fan lines from the same swing.
if rsiRtPosHasDiv and not rsiRealtimeShowLast and rsiRtRemoveLastPosDivs
    f_delete_last_rsi_rt_pos_lines(rsiRtLastPosLines)
    rsiRtLastPosLines := 0

if rsiRtNegHasDiv and not rsiRealtimeShowLast and rsiRtRemoveLastNegDivs
    f_delete_last_rsi_rt_neg_lines(rsiRtLastNegLines)
    rsiRtLastNegLines := 0

if rsiRtUseLabelDots and rsiRtBullDivDot and not rsiRealtimeDotsShowLast and rsiRtRemoveLastPosDots
    f_delete_last_rsi_rt_pos_dots(rsiRtLastPosDots)
    rsiRtLastPosDots := 0

if rsiRtUseLabelDots and rsiRtBearDivDot and not rsiRealtimeDotsShowLast and rsiRtRemoveLastNegDots
    f_delete_last_rsi_rt_neg_dots(rsiRtLastNegDots)
    rsiRtLastNegDots := 0

if rsiRtDraw and rsiRtPosHasDiv
    if rsiRealtimeShowLast
        f_delete_old_rsi_rt_pos_lines()
        rsiRtLastPosLines := 0
    if rsiRtBullRegLen > 0
        rsiRtBullRegEnd = math.min(rsiRtBullEndpointRaw, rsiRtBullRegLen - 1)
        rsiRtBullRegLine = line.new(x1 = bar_index - rsiRtBullRegLen, y1 = rsiLowerHalfActive ? rsi[rsiRtBullRegLen] - 100 : rsi[rsiRtBullRegLen], x2 = bar_index - rsiRtBullRegEnd, y2 = rsiLowerHalfActive ? rsi[rsiRtBullRegEnd] - 100 : rsi[rsiRtBullRegEnd], color = rsiBullColor, style = line.style_solid, width = divLineWidth)
        array.push(rsiRtPosLines, rsiRtBullRegLine)
        rsiRtLastPosLines := rsiRtLastPosLines + 1
        if not rsiRealtimeShowLast
            f_trim_rsi_rt_pos_lines()
    if rsiRtBullHidLen > 0
        rsiRtBullHidEnd = math.min(rsiRtBullEndpointRaw, rsiRtBullHidLen - 1)
        rsiRtBullHidLine = line.new(x1 = bar_index - rsiRtBullHidLen, y1 = rsiLowerHalfActive ? rsi[rsiRtBullHidLen] - 100 : rsi[rsiRtBullHidLen], x2 = bar_index - rsiRtBullHidEnd, y2 = rsiLowerHalfActive ? rsi[rsiRtBullHidEnd] - 100 : rsi[rsiRtBullHidEnd], color = color.new(rsiBullColor, 15), style = line.style_dotted, width = divLineWidth)
        array.push(rsiRtPosLines, rsiRtBullHidLine)
        rsiRtLastPosLines := rsiRtLastPosLines + 1
        if not rsiRealtimeShowLast
            f_trim_rsi_rt_pos_lines()
    rsiRtRemoveLastPosDivs := true

if rsiRtDraw and rsiRtNegHasDiv
    if rsiRealtimeShowLast
        f_delete_old_rsi_rt_neg_lines()
        rsiRtLastNegLines := 0
    if rsiRtBearRegLen > 0
        rsiRtBearRegEnd = math.min(rsiRtBearEndpointRaw, rsiRtBearRegLen - 1)
        rsiRtBearRegLine = line.new(x1 = bar_index - rsiRtBearRegLen, y1 = rsiLowerHalfActive ? rsi[rsiRtBearRegLen] - 100 : rsi[rsiRtBearRegLen], x2 = bar_index - rsiRtBearRegEnd, y2 = rsiLowerHalfActive ? rsi[rsiRtBearRegEnd] - 100 : rsi[rsiRtBearRegEnd], color = rsiBearColor, style = line.style_solid, width = divLineWidth)
        array.push(rsiRtNegLines, rsiRtBearRegLine)
        rsiRtLastNegLines := rsiRtLastNegLines + 1
        if not rsiRealtimeShowLast
            f_trim_rsi_rt_neg_lines()
    if rsiRtBearHidLen > 0
        rsiRtBearHidEnd = math.min(rsiRtBearEndpointRaw, rsiRtBearHidLen - 1)
        rsiRtBearHidLine = line.new(x1 = bar_index - rsiRtBearHidLen, y1 = rsiLowerHalfActive ? rsi[rsiRtBearHidLen] - 100 : rsi[rsiRtBearHidLen], x2 = bar_index - rsiRtBearHidEnd, y2 = rsiLowerHalfActive ? rsi[rsiRtBearHidEnd] - 100 : rsi[rsiRtBearHidEnd], color = color.new(rsiBearColor, 35), style = line.style_dotted, width = divLineWidth)
        array.push(rsiRtNegLines, rsiRtBearHidLine)
        rsiRtLastNegLines := rsiRtLastNegLines + 1
        if not rsiRealtimeShowLast
            f_trim_rsi_rt_neg_lines()
    rsiRtRemoveLastNegDivs := true

// Realtime Pivot RSI divergence dots.
 // Two renderers are available:
 // - Aligned plot dots: exact same plotchar rendering as the WT/classic panel dots, but live candidates cannot be deleted historically.
 // - Clean label dots: deletable labels that follow realtime line cleanup, but may render slightly differently in TradingView.
if rsiRtUseLabelDots and rsiRtBullDivDot
    if rsiRealtimeDotsShowLast
        f_delete_old_rsi_rt_pos_dots()
        rsiRtLastPosDots := 0
    rsiRtBullDotEnd = rsiRtBullRegLen > 0 ? math.min(rsiRtBullEndpointRaw, rsiRtBullRegLen - 1) : rsiRtBullHidLen > 0 ? math.min(rsiRtBullEndpointRaw, rsiRtBullHidLen - 1) : rsiRtStartPoint
    rsiRtBullDotLabel = label.new(x = bar_index - rsiRtBullDotEnd, y = rsiRtBottomPanelDotY, text = '•', xloc = xloc.bar_index, yloc = yloc.price, color = color.new(#000000, 100), style = label.style_none, textcolor = rsiBullColor, size = size.normal)
    array.push(rsiRtPosDotLabels, rsiRtBullDotLabel)
    rsiRtLastPosDots := rsiRtLastPosDots + 1
    rsiRtRemoveLastPosDots := true
    if not rsiRealtimeDotsShowLast
        f_trim_rsi_rt_pos_dots()

if rsiRtUseLabelDots and rsiRtBearDivDot
    if rsiRealtimeDotsShowLast
        f_delete_old_rsi_rt_neg_dots()
        rsiRtLastNegDots := 0
    rsiRtBearDotEnd = rsiRtBearRegLen > 0 ? math.min(rsiRtBearEndpointRaw, rsiRtBearRegLen - 1) : rsiRtBearHidLen > 0 ? math.min(rsiRtBearEndpointRaw, rsiRtBearHidLen - 1) : rsiRtStartPoint
    rsiRtBearDotLabel = label.new(x = bar_index - rsiRtBearDotEnd, y = rsiRtTopPanelDotY, text = '•', xloc = xloc.bar_index, yloc = yloc.price, color = color.new(#000000, 100), style = label.style_none, textcolor = rsiBearColor, size = size.normal)
    array.push(rsiRtNegDotLabels, rsiRtBearDotLabel)
    rsiRtLastNegDots := rsiRtLastNegDots + 1
    rsiRtRemoveLastNegDots := true
    if not rsiRealtimeDotsShowLast
        f_trim_rsi_rt_neg_dots()

// Visual-only smoothed series. Core calculations above remain unchanged.
wt1VisualBase = wtVisualSmooth > 1 ? ta.ema(wt1, wtVisualSmooth) : wt1
wt2VisualBase = wtVisualSmooth > 1 ? ta.ema(wt2, wtVisualSmooth) : wt2
wtAvgVisualBase = (wt1VisualBase + wt2VisualBase) / 2.0
wt1Visual = wt1VisualBase * wtVisualScale
wt2Visual = wt2VisualBase * wtVisualScale
wtAvgVisual = wtAvgVisualBase * wtVisualScale
wtBlueEdgeVisual = wtEdgeSource == 'WT2' ? wt2Visual : wtEdgeSource == 'Average' ? wtAvgVisual : wt1Visual
wtDarkBodyVisual = (wtBodySource == 'WT1' ? wt1Visual : wtBodySource == 'Average' ? wtAvgVisual : wt2Visual) * wtBodyScale
wtVwapVisual = wt1Visual - wt2Visual

rsiMFIVisualBase = mfiVisualSmooth > 1 ? ta.ema(rsiMFI, mfiVisualSmooth) : rsiMFI
rsiMFIVisual = rsiMFIVisualBase * mfiVisualScale
stochKVisual = stochVisualSmooth > 1 ? ta.ema(stochK, stochVisualSmooth) : stochK
stochDVisual = stochVisualSmooth > 1 ? ta.ema(stochD, stochVisualSmooth) : stochD
// Visual remap only. Stoch calculations/divergence detection still use the raw 0..100 Stoch RSI values.
stochKDisplay = stochLowerHalfActive ? stochKVisual - 100 : stochKVisual
stochDDisplay = stochLowerHalfActive ? stochDVisual - 100 : stochDVisual
stochKDivDisplay = stochLowerHalfActive ? stochK - 100 : stochK

// Stoch-priority visual mode:
// When Stoch is in the low/bounce zone, Money Flow fades back so the Stoch bottom remains easy to read.
// This is visual only; it does not change WT/Stoch/MF calculations, divergences, dots, or alerts.
stochLowRef = math.min(stochKVisual, stochDVisual)
// Pine v4 cannot know the final/right-edge bar index, so this uses a date gate instead.
// Set the start date near the part of the chart where you want the MF to yield to low Stoch.
mfiRecentFadeWindow = not mfiYieldFromDateOnly or time >= mfiYieldStartTime
stochPriorityFactor = (mfiYieldToLowStoch and mfiRecentFadeWindow) ? math.max(0.0, math.min(1.0, (mfiYieldStochLevel - stochLowRef) / mfiYieldStochLevel)) : 0.0

// Monkey-style MF shading: sharper raw outline, with fill opacity increasing as MF moves away from zero,
// then yielding to Stoch when Stoch is low.
mfiAbsForGradient = math.abs(rsiMFIVisual)
mfiDynTranspRaw = 90 - int(mfiAbsForGradient * mfiGradientPower)
mfiDynTranspBase = math.max(58, math.min(90, mfiDynTranspRaw))
mfiDynTransp = math.min(90, mfiDynTranspBase + int(stochPriorityFactor * mfiYieldExtraTransparency))
mfiGradientColor = rsiMFIVisual >= 0 ? color.new(#00EEFF, mfiDynTransp) : color.new(#FF1100, mfiDynTransp)


// DRAW {
bgcolor(darkMode ? color.new(#000000, 0) : na) 
zLine = plot(0, color = color.new(#ffffff, 78))

//  MFI BAR CONTROL PANEL
// Use hline() instead of plot() here to preserve visuals without consuming 2 extra plot counts.
rsiMfiBarTopLine = hline(-92, title = 'MFI Bar TOP Line', color = color.new(#000000, 100))
rsiMfiBarBottomLine = hline(-99, title = 'MFI Bar BOTTOM Line', color = color.new(#000000, 100))
fill(rsiMfiBarTopLine, rsiMfiBarBottomLine, title = 'MFI Bar Colors', color = rsiMFIShow ? rsiMFIColor : na)

// LAYER 1: classic WT overlap areas.
// This is closer to the original cipher rendering: WT1 forms the blue outer hill, WT2 lays the dark body over it.
// Because the default visual source is now raw WT1/WT2, dots/crosses line up with the visible overtake more naturally.
wt1plot = plot(wtShow ? wtBlueEdgeVisual : na, title='WT1 Blue Hill Area', color=wt1AreaColorApplied, linewidth=1, style=plot.style_area)
wt2plot = plot(wtShow ? wtDarkBodyVisual : na, title='WT2 Dark Body Area', color=wt2AreaColorApplied, linewidth=1, style=plot.style_area)

// LAYER 2: VWAP fill sits above the WT hills but below Money Flow.
vwapPlot = plot(vwapShow ? wtVwapVisual : na, title='VWAP Line', color=vwapLineColor, linewidth=1)
fill(vwapPlot, zLine, title='VWAP Fill', color=vwapFillColor)

// LAYER 3: Money Flow is deliberately drawn after WT/VWAP so it is not cancelled by the WT hills.
// One hidden anchor creates the fill; the visible outline is plotted after the fill so it stays sharp.
mfiNearZeroFactor = mfiSoftenNearZero ? math.max(0.0, math.min(1.0, (mfiSoftenLevel - math.abs(rsiMFIVisual)) / mfiSoftenLevel)) : 0.0
mfiOutlineTransp = math.min(68, int(mfiNearZeroFactor * mfiSoftenExtra) + int(stochPriorityFactor * mfiYieldExtraTransparency))
rsiMFIOutlineColor = rsiMFIVisualBase > 0 ? color.new(#00EEFF, mfiOutlineTransp) : color.new(#FF1100, mfiOutlineTransp)
rsiMFIAnchor = plot(rsiMFIShow ? rsiMFIVisual : na, title='Money Flow Fill Anchor', color=color.new(#000000, 100), linewidth=1)
fill(rsiMFIAnchor, zLine, title='MFI Area Fill', color=mfiGradientColor)
rsiMFIplot = plot(rsiMFIShow ? rsiMFIVisual : na, title='Money Flow Outline', color=rsiMFIOutlineColor, linewidth=1)

// Custom Stochastic RSI Lines
stochKplot = plot(stochShow ? stochKDisplay : na, title = 'STOCH K', color = stochKColorInput, linewidth = 1)
stochDplot = plot(stochShow ? stochDDisplay : na, title = 'STOCH D', color = stochDColorInput, linewidth = 1)
stochFillColor = showStochFill ? (stochKVisual >= stochDVisual ? color.new(#00EEFF, 98) : color.new(#CA1BFF, 98)) : color.new(#000000, 100)
fill(stochKplot, stochDplot, title='KD Fill', color=stochFillColor)

// WT Div Lines use line.new() instead of plot() so the publish version stays under
// TradingView's 64-plot limit while keeping the bright row-dot upgrades as aligned plotchar dots.
// Anchors are still the original/raw wt2[2] pivot values, equivalent to the old offset = -2 plots.
// Important: the original plot()-based Cipher/VMC rendering effectively connects the current
// divergence pivot to the immediately previous qualifying fractal pivot, not to the previous
// divergence pivot. v88 accidentally connected divergence-to-divergence, which created long,
// strange lines. This version updates the anchor on every qualifying fractal and only draws
// when the current fractal is an actual divergence.
var int wtBearDivLastX = na
var float wtBearDivLastY = na
var int wtBullDivLastX = na
var float wtBullDivLastY = na
var int wtBearDivAddLastX = na
var float wtBearDivAddLastY = na
var int wtBullDivAddLastX = na
var float wtBullDivAddLastY = na

wtBearDivDrawNow = wtShow and showDivergenceLinesVisual and not na(wtBearDivColor)
wtBullDivDrawNow = wtShow and showDivergenceLinesVisual and not na(wtBullDivColor)
wtBearDivAddDrawNow = wtShow and showDivergenceLinesVisual and not na(wtBearDivColor_add)
wtBullDivAddDrawNow = wtShow and showDivergenceLinesVisual and not na(wtBullDivColor_add)

if barstate.isconfirmed and wtFractalTop
    wtBearDivX = bar_index - 2
    wtBearDivY = wt2[2]
    if wtBearDivDrawNow and not na(wtBearDivLastX)
        line.new(wtBearDivLastX, wtBearDivLastY, wtBearDivX, wtBearDivY, xloc = xloc.bar_index, extend = extend.none, color = wtBearDivColor, width = divLineWidth)
    wtBearDivLastX := wtBearDivX
    wtBearDivLastY := wtBearDivY

if barstate.isconfirmed and wtFractalBot
    wtBullDivX = bar_index - 2
    wtBullDivY = wt2[2]
    if wtBullDivDrawNow and not na(wtBullDivLastX)
        line.new(wtBullDivLastX, wtBullDivLastY, wtBullDivX, wtBullDivY, xloc = xloc.bar_index, extend = extend.none, color = wtBullDivColor, width = divLineWidth)
    wtBullDivLastX := wtBullDivX
    wtBullDivLastY := wtBullDivY

if barstate.isconfirmed and wtFractalTop_add
    wtBearDivAddX = bar_index - 2
    wtBearDivAddY = wt2[2]
    if wtBearDivAddDrawNow and not na(wtBearDivAddLastX)
        line.new(wtBearDivAddLastX, wtBearDivAddLastY, wtBearDivAddX, wtBearDivAddY, xloc = xloc.bar_index, extend = extend.none, color = wtBearDivColor_add, width = divLineWidth)
    wtBearDivAddLastX := wtBearDivAddX
    wtBearDivAddLastY := wtBearDivAddY

if barstate.isconfirmed and wtFractalBot_add
    wtBullDivAddX = bar_index - 2
    wtBullDivAddY = wt2[2]
    if wtBullDivAddDrawNow and not na(wtBullDivAddLastX)
        line.new(wtBullDivAddLastX, wtBullDivAddLastY, wtBullDivAddX, wtBullDivAddY, xloc = xloc.bar_index, extend = extend.none, color = wtBullDivColor_add, width = divLineWidth)
    wtBullDivAddLastX := wtBullDivAddX
    wtBullDivAddLastY := wtBullDivAddY

// RSI Line + optional TradingView-style smoothing/levels
plot(rsiShow ? rsiVisual : na, title = 'RSI Line', color = rsiPlotColor, linewidth = 1)
plot(rsiShow and rsiMaShow ? rsiMAVisual : na, title = 'RSI Smoothing Line', color = rsiMaPlotColor, linewidth = rsiMaWidth)
plot(rsiOBGuideSeries, title = 'RSI Overbought Guide', color = rsiOBGuideColor, linewidth = rsiGuideWidth, style = plot.style_linebr)
plot(rsiOSGuideSeries, title = 'RSI Oversold Guide', color = rsiOSGuideColor, linewidth = rsiGuideWidth, style = plot.style_linebr)

// RSI Div Lines
plot(series = rsiShow and rsiClassicDivActive and showDivergenceLinesVisual and rsiFractalTop ? rsiVisual[2] : na, title='RSI Bearish Divergence', color = rsiBearDivColor, linewidth = 1, offset = -2)
plot(series = rsiShow and rsiClassicDivActive and showDivergenceLinesVisual and rsiFractalBot ? rsiVisual[2] : na, title='RSI Bullish Divergence', color = rsiBullDivColor, linewidth = 1, offset = -2)

// Stoch Div Lines
plot(series = showDivergenceLinesVisual and stochFractalTop ? stochKDivDisplay[2] : na, title='Stoch Bearish Divergence', color = stochBearDivColor, linewidth = 1, offset = -2)
plot(series = showDivergenceLinesVisual and stochFractalBot ? stochKDivDisplay[2] : na, title='Stoch Bullish Divergence', color = stochBullDivColor, linewidth = 1, offset = -2)

// Schaff Trend Cycle
plot(tcLine ? tcValDisplay : na, color = color.new(#a855f7, 50), linewidth = 2, title = "Schaff Trend Cycle")

// Grid Level Coordinates
// hline() does not consume plot count. These extra Monkey-style guide lines make the panel read closer to the PRO version.
majorGridColor = color.new(#ffffff, 72)
minorGridColor = color.new(#ffffff, 86)

hline(100, title = 'Top Grid 100', color = minorGridColor, linestyle = hline.style_solid, linewidth = 1)
hline(50, title = 'Mid Grid 50', color = majorGridColor, linestyle = hline.style_solid, linewidth = 1)
hline(obLevel2, title = 'Over Bought Level 2', color = majorGridColor, linestyle = hline.style_solid, linewidth = 1)
hline(obLevel3, title = 'Over Bought Level 3', color = minorGridColor, linestyle = hline.style_solid, linewidth = 1)
hline(-50, title = 'Mid Grid -50', color = majorGridColor, linestyle = hline.style_solid, linewidth = 1)
hline(osLevel2, title = 'Over Sold Level 2', color = majorGridColor, linestyle = hline.style_solid, linewidth = 1)
hline(-100, title = 'Bottom Grid -100', color = minorGridColor, linestyle = hline.style_solid, linewidth = 1)

// Sommi Flags
// v72: draw optional Sommi glyphs with labels instead of plotchar so we can use
// plotchar for the realtime RSI divergence dots without hitting TradingView's 64-plot limit.
if sommiFlagShow and sommiBearish
    label.new(x = bar_index, y = 108, text = '⚑', xloc = xloc.bar_index, yloc = yloc.price, color = color.new(#000000, 100), style = label.style_none, textcolor = color.new(#ff007f, 0), size = size.tiny)
if sommiFlagShow and sommiBullish
    label.new(x = bar_index, y = -108, text = '⚑', xloc = xloc.bar_index, yloc = yloc.price, color = color.new(#000000, 100), style = label.style_none, textcolor = color.new(#00b0ff, 0), size = size.tiny)
plot(sommiShowVwap ? ta.ema(hvwap, 3) : na, title = 'Sommi higher VWAP', color = color.new(#ffd600, 55), linewidth = 2, style = plot.style_line)

if sommiDiamondShow and sommiBearishDiamond
    label.new(x = bar_index, y = 108, text = '◆', xloc = xloc.bar_index, yloc = yloc.price, color = color.new(#000000, 100), style = label.style_none, textcolor = color.new(#ff007f, 0), size = size.tiny)
if sommiDiamondShow and sommiBullishDiamond
    label.new(x = bar_index, y = -108, text = '◆', xloc = xloc.bar_index, yloc = yloc.price, color = color.new(#000000, 100), style = label.style_none, textcolor = color.new(#00b0ff, 0), size = size.tiny)

// Signal Cross Circles
plot(wtShow and wtCross ? wt2 : na, title = 'Buy and sell circle', color = color.new(signalColor, 10), style = plot.style_circles, linewidth = 3)

// Top/bottom panel dots are uniform in size, except the gold dot which remains intentionally larger.
// Normal buy/sell dots are slightly faded and print immediately. Confirmed signal+divergence
// dots are plotted later over the original signal candle using fixed 0/1/2-bar offsets.
// v84: this preserves immediate signal timing while allowing exact later bright confirmation.
plotchar(wtBuySignalDot ? bottomPanelDotY : na, title = 'Buy circle', char='•', color = buySignalDotDisplayColor, location = location.absolute, size = size.small)
plotchar(wtSellSignalDot ? topPanelDotY : na , title = 'Sell circle', char='•', color = sellSignalDotDisplayColor, location = location.absolute, size = size.small)
plotchar(wtBuySignalDotBright0 ? bottomPanelDotY : na, title = 'Buy circle + WT divergence confirmation 0', char='•', color = color.new(#00EEFF, 0), location = location.absolute, size = size.small)
plotchar(wtBuySignalDotBright1 ? bottomPanelDotY : na, title = 'Buy circle + WT divergence confirmation 1', char='•', color = color.new(#00EEFF, 0), location = location.absolute, size = size.small, offset = -1)
plotchar(wtBuySignalDotBright2 ? bottomPanelDotY : na, title = 'Buy circle + WT divergence confirmation 2', char='•', color = color.new(#00EEFF, 0), location = location.absolute, size = size.small, offset = -2)
plotchar(wtSellSignalDotBright0 ? topPanelDotY : na , title = 'Sell circle + WT divergence confirmation 0', char='•', color = color.new(#FF1100, 0), location = location.absolute, size = size.small)
plotchar(wtSellSignalDotBright1 ? topPanelDotY : na , title = 'Sell circle + WT divergence confirmation 1', char='•', color = color.new(#FF1100, 0), location = location.absolute, size = size.small, offset = -1)
plotchar(wtSellSignalDotBright2 ? topPanelDotY : na , title = 'Sell circle + WT divergence confirmation 2', char='•', color = color.new(#FF1100, 0), location = location.absolute, size = size.small, offset = -2)

plotchar(buySignalDivDot ? buySignalDiv_y : na, title = 'RSI Classic Divergence buy circle', char='•', color = buySignalDivDotColor, location = location.absolute, size = size.small, offset = -2)
plotchar(sellSignalDivDot ? sellSignalDiv_y : na, title = 'RSI Classic Divergence sell circle', char='•', color = sellSignalDivDotColor, location = location.absolute, size = size.small, offset = -2)

// Realtime RSI divergence dots.
// Default is plotchar so these match the other top/bottom dots in size and alignment.
// If the renderer is set to Clean label dots, they are drawn above with deletable labels instead.
plotchar(rsiRealtimeActive and not rsiRtUseLabelDots and rsiRtBullDivDot ? rsiRtBottomPanelDotY : na, title = 'RSI Realtime Divergence buy circle', char='•', color = rsiBullColor, location = location.absolute, size = size.small)
plotchar(rsiRealtimeActive and not rsiRtUseLabelDots and rsiRtBearDivDot ? rsiRtTopPanelDotY : na, title = 'RSI Realtime Divergence sell circle', char='•', color = rsiBearColor, location = location.absolute, size = size.small)

plotchar(wtGoldBuy and wtGoldShow ? -106 : na, title = 'Gold buy gold circle', char='•', color = color.new(#ff9100, 10), location = location.absolute, size = size.normal, offset = -2)

// } DRAW

// ALERTS {
// Compact alerts preserve plot-count headroom for the RSI smoothing/guide-line tools.
// The individual signal variables/dots are unchanged; only the alert menu is simplified.
bullishCipherAlert = buySignal or buySignalDiv or wtGoldBuy or sommiBullish or sommiBullishDiamond or (wtCross and wtCrossUp)
bearishCipherAlert = sellSignal or sellSignalDiv or sommiBearish or sommiBearishDiamond or (wtCross and wtCrossDown)

alertcondition(bullishCipherAlert, 'Cipher bullish signal', 'Bullish Cipher signal')
alertcondition(bearishCipherAlert, 'Cipher bearish signal', 'Bearish Cipher signal')

// } ALERTS
````

# Market Rhythm Signals ( 8-13-21-34 )

- url: https://www.tradingview.com/script/SloFCOcG-Market-Rhythm-Signals-8-13-21-34/
- type: indicator
- pine_id: PUB;5b983b471f054f91aaea7e784b2ca3ca
- version: 1.0

## Description

[b]Market Rhythm Signals — Non-Repainting Market Structure[/b]

8-bar shifts. 13-bar highs. 21-bar lows. 34-bar exhaustion zones. One structural view of market rhythm.

Most traders look at individual candles.

Market Rhythm Signals was built around a different idea: price develops a rhythm across multiple structural windows, and those structures can be used together to identify where the market is, where pressure is building, and when directional structure has actually changed.

The indicator uses consecutive Fibonacci lookback periods — 8, 13, 21 and 34 bars — to observe market structure across multiple horizons.

The framework combines four core components:

• HH8 / LL8 — 8-bar structural shift levels  
• H13 — 13-bar high  
• L21 — 21-bar low  
• 34-bar upper and lower exhaustion zones

Together, these levels create a dynamic framework for reading market structure rather than relying on a single oscillator or isolated signal.

[b]CORE STRUCTURE[/b]

H13 — 13-Bar High

H13 tracks the highest price reached during the most recent 13 bars.It acts as an upper structural reference and helps show how the market's short-to-medium-term range is evolving.

L21 — 21-Bar Low

L21 tracks the lowest price reached during the most recent 21 bars. It provides the corresponding lower structural reference.

HH8 / LL8 — Bias Shift Levels

HH8 and LL8 represent the short-term structural boundaries used to identify directional changes. The levels are derived from the previous 8-bar structure, so the candle currently testing the level does not redefine its own breakout threshold. When price closes beyond one of these levels and the active filters agree, the indicator can generate a Bias Shift signal.

[b]BIAS SHIFT SIGNALS[/b]

A Bias Shift represents a confirmed change in short-term structural pressure.

Bullish Bias Shift

Price closes above the upper 8-bar structural boundary while satisfying the active confirmation filters.

Bearish Bias Shift

Price closes below the lower 8-bar structural boundary while satisfying the active confirmation filters.

Signals are evaluated on confirmed candle closes. Temporary intrabar movements are not used to create final directional signals.

[b]GOLDEN SIGNALS[/b]

Golden signals are higher-confluence structural signals. They combine the underlying structural breakout with additional confirmation such as:

• EMA trend alignment  
• volatility conditions  
• cooldown logic  
• higher-timeframe confirmation  
• exhaustion-zone context

Golden signals are not intended to be interpreted as automatic buy or sell instructions.
They represent situations where several structural conditions align simultaneously.

[b]34-BAR EXHAUSTION ZONES[/b]

The indicator calculates the recent 34-bar price range and defines an upper and lower exhaustion area.

Upper Exhaustion Zone

Shows when price is trading near the upper extreme of its recent structural range.

Lower Exhaustion Zone

Shows when price is trading near the lower extreme of its recent structural range.

These areas are context zones, not automatic reversal signals.

A breakout occurring from the middle of a structure is different from a breakout occurring after price has already reached an extreme.

That context is one of the central ideas behind Market Rhythm Signals.

[b]DECISION ZONE[/b]

HH8 and LL8 define the indicator's dynamic Decision Zone.

This area represents the short-term structural range the market must resolve before a clearer directional bias develops. The Decision Zone can adapt visually according to the relationship between price, the trend filter and an ATR-based neutral band.

It provides a quick distinction between:

Bullish structure  
Bearish structure  
Neutral / ranging structure

[b]HIGHER-TIMEFRAME CONFIRMATION[/b]

Market Rhythm Signals can use higher-timeframe trend information as an additional confirmation layer. The non-repainting implementation uses completed higher-timeframe information rather than an unfinished HTF candle. This prevents a higher-timeframe condition from changing simply because the current HTF candle is still developing.

[b]NON-REPAINTING DESIGN[/b]

This version was designed around confirmed market information. Directional signals are generated only after the chart candle closes.

The 8-bar structural thresholds are based on previously completed bars, while higher-timeframe confirmation uses completed HTF data. As a result, a confirmed signal is not intentionally removed because price later moved back across the level during the same candle.

Non-repainting does not mean predictive. It only means that the signal-generation logic is based on confirmed rather than temporary intrabar conditions.

[b]PRESETS[/b]

Market Rhythm Signals includes:

Auto  
Scalp  
Intraday  
Swing  
Position  
Custom

Auto automatically adapts the operating profile to the chart timeframe, while Custom provides manual control over the principal filters.

Three sensitivity profiles are also available:

Conservative  
Balanced  
Aggressive

These profiles modify signal selectivity while preserving the underlying structural framework.

[b]HOW TO READ MARKET RHYTHM SIGNALS[/b]

The indicator is designed primarily as a market-structure and context tool.

Rather than asking only:

“Is price going up or down?”

the framework is intended to help answer:

“Where is price within its current structure, and has that structure actually changed?”

A practical way to read the chart is:

Structure → Decision Zone → Bias Shift → Confirmation → Exhaustion Context

The individual signals are only one part of the indicator.

The main value comes from understanding how price interacts with the complete 8 / 13 / 21 / 34 structure.

[b]FULL MARKET RHYTHM STRUCTURE[/b]

8-bar shifts, 13-bar highs, 21-bar lows and 34-bar exhaustion zones working as one structural framework.

https://www.tradingview.com/x/8u1XE2yg/


BULLISH STRUCTURE EXAMPLE

Confirmed bullish structural shifts as the market transitions from consolidation into directional expansion.

https://www.tradingview.com/x/BYfYrzyD/


BEARISH STRUCTURE EXAMPLE

Confirmed bearish structural shifts during a sustained deterioration in market structure.

https://www.tradingview.com/x/kHnadMOq/

[b]ALERTS[/b]

Alerts are available for:

Bullish Bias Shift  
Bearish Bias Shift  
Golden Bull  
Golden Bear  
Upper Exhaustion Entry  
Lower Exhaustion Entry

Webhook support is also available for external workflows. Directional alerts are based on confirmed bars.

[b]ABOUT THE CONCEPT[/b]

The consecutive Fibonacci windows — 8, 13, 21 and 34 — were translated into a rules-based framework combining short-term structural changes, intermediate price boundaries and broader exhaustion context.

Although the resulting structure can sometimes visually resemble wave-based analysis, Market Rhythm Signals does not automatically detect or count Elliott Waves.

It is a systematic market-structure framework based on rolling price levels and confirmed structural events.

[b]ABOUT AND RISK DISCLOSURE[/b]

Market Rhythm Signals is provided for informational and educational purposes only and does not constitute financial or investment advice. Its signals and levels are based on historical price data, may be incorrect, and do not guarantee future market movements or trading results. Confirmation at bar close helps prevent intrabar signal changes, but it does not eliminate market risk or ensure profitability. Trading involves substantial risk, including the possible loss of all capital committed to trading, and past performance is not a reliable indicator of future results. Before acting on any signal, assess its suitability for your circumstances and use appropriate risk management, including position sizing and stop-loss orders, while recognizing that these measures cannot eliminate losses.

You remain responsible for your trading decisions and their outcomes.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © talgos

//@version=6
indicator("Market Rhythm Signals", overlay=true, max_boxes_count=50, max_labels_count=500)

// ─────────────────────────────────────────────────────────────
// NON-REPAINT DESIGN
// - All signals are evaluated ONLY on confirmed chart bars.
// - HH/LL breakout thresholds use prior-bar lookbacks.
// - HTF confirmation uses the LAST CONFIRMED HTF bar via [1] + lookahead_on.
// - No intrabar/live preview signals.
// - No freeze/timenow logic participates in signal generation.
// ─────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────
// ABOUT AND RISK DISCLOSURE
// ─────────────────────────────────────────────────────────────
grpAttn = "ABOUT AND RISK DISCLOSURE"
attMsg =
     "Market Rhythm Signals is provided for informational and educational purposes only and does not constitute financial or investment advice.\n" +
     "Its signals and levels are based on historical price data, may be incorrect, and do not guarantee future market movements or trading results. Confirmation at bar close helps prevent intrabar signal changes, but it does not eliminate market risk or ensure profitability.\n" +
     "Trading involves substantial risk, including the possible loss of all capital committed to trading, and past performance is not a reliable indicator of future results. Before acting on any signal, assess its suitability for your circumstances and use appropriate risk management, including position sizing and stop-loss orders, while recognizing that these measures cannot eliminate losses. You remain responsible for your trading decisions and their outcomes."
_attnInfo = input.bool(true, attMsg, group=grpAttn, tooltip="About and risk disclosure.")

// ─────────────────────────────────────────────────────────────
// Groups
// ─────────────────────────────────────────────────────────────
grpPresets = "PRESETS"
grpLevels  = "Levels"
grpBoxes   = "Boxes"
grpSignals = "Signals"
grpTable   = "Table"
grpDebug   = "Debug"
grpAdv     = "Advanced"
grpWh      = "Webhook (Pro)"

// ─────────────────────────────────────────────────────────────
// Presets / profiles
// ─────────────────────────────────────────────────────────────
presetIn = input.string(
     "Auto", "Preset",
     options=["Auto","Scalp","Intraday","Swing","Position","Custom"],
     group=grpPresets,
     tooltip="Auto selects a preset from the chart timeframe. Custom enables manual filter parameters."
)

profileIn = input.string(
     "Balanced", "Profile",
     options=["Conservative","Balanced","Aggressive"],
     group=grpPresets,
     tooltip="Conservative = stricter filters / longer cooldown. Aggressive = looser filters / shorter cooldown."
)

// ─────────────────────────────────────────────────────────────
// Core lengths
// ─────────────────────────────────────────────────────────────
lenFlip = input.int(8,  "Bias Shift length", minval=2, group=grpLevels)
lenHigh = input.int(13, "High length", minval=2, group=grpLevels)
lenLow  = input.int(21, "Low length", minval=2, group=grpLevels)

lenExh     = input.int(34, "Exhaustion length", minval=2, group=grpBoxes)
zonePct_in = input.float(0.20, "Exhaustion zone size", minval=0.05, maxval=0.50, step=0.01, group=grpBoxes,
     tooltip="0.20 = top/bottom 20% of the rolling range.")

// ─────────────────────────────────────────────────────────────
// Levels
// ─────────────────────────────────────────────────────────────
enableH13Line_in = input.bool(true, "H13", group=grpLevels, inline="lvlH13",
     tooltip="Highest high over the selected High length.")
h13LineColor_in = input.color(color.red, "", group=grpLevels, inline="lvlH13")

enableL21Line_in = input.bool(true, "L21", group=grpLevels, inline="lvlL21",
     tooltip="Lowest low over the selected Low length.")
l21LineColor_in = input.color(color.green, "", group=grpLevels, inline="lvlL21")

enableHH8Line_in = input.bool(true, "HH8", group=grpLevels, inline="lvlHH8",
     tooltip="Highest high of the previous Bias Shift lookback. Uses [1] so the current bar cannot move its own breakout threshold.")
hh8LineColor_in = input.color(color.blue, "", group=grpLevels, inline="lvlHH8")

enableLL8Line_in = input.bool(true, "LL8", group=grpLevels, inline="lvlLL8",
     tooltip="Lowest low of the previous Bias Shift lookback. Uses [1] so the current bar cannot move its own breakout threshold.")
ll8LineColor_in = input.color(color.purple, "", group=grpLevels, inline="lvlLL8")

// ─────────────────────────────────────────────────────────────
// Boxes
// ─────────────────────────────────────────────────────────────
enableDecisionBox_in = input.bool(true, "Enable decision box (HH8-LL8)", group=grpBoxes)
enableExhUpper_in    = input.bool(true, "Enable upper exhaustion box", group=grpBoxes)
enableExhLower_in    = input.bool(true, "Enable lower exhaustion box", group=grpBoxes)

exhUpperColor_in = input.color(color.red, "Upper box color", group=grpBoxes)
exhLowerColor_in = input.color(color.green, "Lower box color", group=grpBoxes)

decisionDynColor_in = input.bool(true, "Decision box: dynamic", group=grpBoxes,
     tooltip="Colors the Decision Box from the confirmed trend state around the EMA.")
decisionRangeAtr_in = input.float(0.25, "Decision box: range threshold (ATR)", minval=0.0, step=0.05, group=grpBoxes)
decisionBullColor_in  = input.color(color.blue, "Decision box: bullish color", group=grpBoxes)
decisionBearColor_in  = input.color(color.purple, "Decision box: bearish color", group=grpBoxes)
decisionRangeColor_in = input.color(color.gray, "Decision box: range color", group=grpBoxes)

// ─────────────────────────────────────────────────────────────
// Signals
// ─────────────────────────────────────────────────────────────
enableFlipSignals_in = input.bool(true, "Enable Bias Shift signals", group=grpSignals,
     tooltip="Confirmed-bar breakout above HH8 or below LL8, subject to filters.")
enableGoldenSignals_in = input.bool(true, "Enable Golden signals", group=grpSignals,
     tooltip="Higher-selectivity confirmed-bar breakout signal.")

oneSignalPerBar_in = input.bool(false, "One signal per bar (Bias Shift + Golden)", group=grpSignals)
oneSignalPriority_in = input.string(
     "Prefer Golden", "One signal priority",
     options=["Prefer Golden","Prefer Bias Shift"],
     group=grpSignals
)

// Bias Shift style
flipRender = input.string("Text", "Bias Shift render", options=["Text","Icon"], group=grpSignals)
flipShape  = input.string("Triangle", "Bias Shift shape",
     options=["Triangle","Arrow","Circle","Diamond","Label Up","Label Down"], group=grpSignals)
flipSize = input.string("Normal", "Bias Shift size", options=["Tiny","Small","Normal","Large","Huge"], group=grpSignals)
flipBullColor = input.color(color.new(color.lime, 0), "Bias Shift bull color", group=grpSignals)
flipBearColor = input.color(color.new(color.red, 0), "Bias Shift bear color", group=grpSignals)

flipOffsetMode = input.string("ATR", "Bias Shift offset mode", options=["ATR","Ticks"], group=grpSignals)
flipTicks   = input.int(10, "Bias Shift ticks offset", minval=0, group=grpSignals)
flipAtrLen  = input.int(14, "Bias Shift ATR length", minval=1, group=grpSignals)
flipAtrMult = input.float(1.0, "Bias Shift ATR multiplier", minval=0.0, step=0.1, group=grpSignals)
maxFlipSignals = input.int(120, "Max Bias Shift signals", minval=0, maxval=450, group=grpSignals)

// Golden style
goldRender = input.string("Text", "Golden render", options=["Text","Icon"], group=grpSignals)
goldShape  = input.string("Diamond", "Golden shape", options=["Diamond","Circle","Triangle","Label"], group=grpSignals)
goldSize   = input.string("Normal", "Golden size", options=["Tiny","Small","Normal","Large","Huge"], group=grpSignals)
goldBullColor = input.color(color.new(color.teal, 0), "Golden bull color", group=grpSignals)
goldBearColor = input.color(color.new(color.orange, 0), "Golden bear color", group=grpSignals)

goldOffsetMode = input.string("ATR", "Golden offset mode", options=["ATR","Ticks"], group=grpSignals)
goldTicks   = input.int(10, "Golden ticks offset", minval=0, group=grpSignals)
goldAtrLen  = input.int(14, "Golden ATR length", minval=1, group=grpSignals)
goldAtrMult = input.float(1.5, "Golden ATR multiplier", minval=0.0, step=0.1, group=grpSignals)

goldStrictFilters = input.bool(true, "Golden: strict filters", group=grpSignals,
     tooltip="ON: Golden uses trend + volatility + its own cooldown + outside-exhaustion + confirmed HTF. OFF: EMA direction + outside-exhaustion + confirmed HTF.")
maxGoldSignals = input.int(80, "Max Golden signals", minval=0, maxval=450, group=grpSignals)

// ─────────────────────────────────────────────────────────────
// Values table
// ─────────────────────────────────────────────────────────────
enableValuesTable_in = input.bool(true, "Enable values table", group=grpTable)
valuesTablePos_in = input.string("Bottom right", "Values table position",
     options=["Top right","Bottom right"], group=grpTable)

// ─────────────────────────────────────────────────────────────
// Advanced filters
// ─────────────────────────────────────────────────────────────
useTrendFilter_in = input.bool(true, "Use trend filter (EMA)", group=grpAdv)
emaLen_in = input.int(200, "EMA length", minval=1, group=grpAdv)

useVolFilter_in = input.bool(false, "Use volatility filter (ATR%)", group=grpAdv)
atrLen_in = input.int(14, "ATR length", minval=1, group=grpAdv)
minAtrPct_in = input.float(0.15, "Min ATR%", minval=0.0, step=0.05, group=grpAdv)

useCooldown_in = input.bool(true, "Use cooldown", group=grpAdv,
     tooltip="Bias Shift and Golden use independent cooldown counters.")
flipCooldownBars_in = input.int(3, "Bias Shift cooldown bars", minval=0, group=grpAdv)
goldCooldownBars_in = input.int(3, "Golden cooldown bars", minval=0, group=grpAdv)

flipOutsideExh_in = input.bool(false, "Bias Shift only outside exhaustion", group=grpAdv)

useHtfConfirm_in = input.bool(false, "Use HTF trend confirmation", group=grpAdv,
     tooltip="When enabled, the script uses ONLY the previous confirmed HTF bar. This is intentionally one HTF bar late to avoid repainting.")
htfTf_in = input.timeframe("15", "HTF timeframe (Custom)", group=grpAdv)
htfEmaLen_in = input.int(200, "HTF EMA length", minval=10, group=grpAdv)

autoTfMethod_in = input.string("Ratio", "Auto HTF method", options=["Ratio","Fixed"], group=grpAdv)
autoHtfMult_in = input.float(5.0, "Auto HTF multiple", minval=1.5, step=0.5, group=grpAdv)

// Debug
enableDebugDW = input.bool(false, "Enable status/debug (Data Window)", group=grpDebug)

// ─────────────────────────────────────────────────────────────
// Webhook — all webhook signals are confirmed-bar only
// ─────────────────────────────────────────────────────────────
wh_enable = input.bool(false, "Enable Webhook Alerts (alert())", group=grpWh,
     display=display.data_window + display.status_line,
     tooltip="Create one TradingView alert using: Any alert() function call. All messages are confirmed-bar only.")
wh_format = input.string("JSON", "Message Format", options=["JSON","Plain"], group=grpWh,
     display=display.data_window + display.status_line)
wh_payloadDetail = input.string("Verbose", "Payload Detail", options=["Basic","Verbose"], group=grpWh,
     display=display.data_window + display.status_line)
wh_token = input.string("", "Token", group=grpWh, display=display.data_window + display.status_line)
wh_idPrefix = input.string("talgos", "Signal ID prefix", group=grpWh,
     display=display.data_window + display.status_line)
wh_tag = input.string("", "Custom tag", group=grpWh, display=display.data_window + display.status_line)
wh_priceField = input.string("close", "Price Field", options=["close","hl2","ohlc4"], group=grpWh,
     display=display.data_window + display.status_line)

wh_includeGolden = input.bool(true, "Include Golden signals", group=grpWh,
     display=display.data_window + display.status_line)
wh_includeExhaustion = input.bool(true, "Include Exhaustion entry signals", group=grpWh,
     display=display.data_window + display.status_line)
wh_includeOHLC = input.bool(false, "Verbose: include OHLC", group=grpWh,
     display=display.data_window + display.status_line)

// ─────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────
f_size(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.huge

f_flip_style(bull) =>
    switch flipShape
        "Triangle"   => bull ? label.style_triangleup : label.style_triangledown
        "Arrow"      => bull ? label.style_label_up : label.style_label_down
        "Circle"     => label.style_circle
        "Diamond"    => label.style_diamond
        "Label Up"   => label.style_label_up
        "Label Down" => label.style_label_down
        => bull ? label.style_triangleup : label.style_triangledown

f_gold_style(bull) =>
    switch goldShape
        "Diamond"  => label.style_diamond
        "Circle"   => label.style_circle
        "Triangle" => bull ? label.style_triangleup : label.style_triangledown
        "Label"    => bull ? label.style_label_up : label.style_label_down
        => label.style_diamond

f_flip_symbol(bull) =>
    switch flipShape
        "Diamond"   => "◆"
        "Circle"    => "●"
        "Arrow"     => bull ? "↑" : "↓"
        "Triangle"  => bull ? "▲" : "▼"
        "Label Up"  => bull ? "▲" : "▼"
        "Label Down"=> bull ? "▲" : "▼"
        => bull ? "▲" : "▼"

f_gold_symbol(bull) =>
    switch goldShape
        "Circle"   => "●"
        "Triangle" => bull ? "▲" : "▼"
        "Label"    => "◆"
        => "◆"

// Standard timeframe list used by Auto Ratio.
var string[] _tfList = array.from(
     "1","3","5","15","30","45","60","120","180","240","360","480","720",
     "D","2D","3D","W","2W","M","3M","6M","12M"
)

var int[] _tfSec = array.from(
     timeframe.in_seconds("1"),
     timeframe.in_seconds("3"),
     timeframe.in_seconds("5"),
     timeframe.in_seconds("15"),
     timeframe.in_seconds("30"),
     timeframe.in_seconds("45"),
     timeframe.in_seconds("60"),
     timeframe.in_seconds("120"),
     timeframe.in_seconds("180"),
     timeframe.in_seconds("240"),
     timeframe.in_seconds("360"),
     timeframe.in_seconds("480"),
     timeframe.in_seconds("720"),
     timeframe.in_seconds("D"),
     timeframe.in_seconds("2D"),
     timeframe.in_seconds("3D"),
     timeframe.in_seconds("W"),
     timeframe.in_seconds("2W"),
     timeframe.in_seconds("M"),
     timeframe.in_seconds("3M"),
     timeframe.in_seconds("6M"),
     timeframe.in_seconds("12M")
)

f_pick_tf(int targetSec) =>
    string res = array.get(_tfList, array.size(_tfList) - 1)
    for i = 0 to array.size(_tfSec) - 1
        if targetSec <= array.get(_tfSec, i)
            res := array.get(_tfList, i)
            break
    res

// Signal-family conflict resolver.
// 0 none, 1 bull Bias, 2 bear Bias, 3 bull Golden, 4 bear Golden.
f_pick_signal(fBull, fBear, gBull, gBear, keepBull, preferGold) =>
    fb = (fBull and fBear) ? keepBull : fBull
    fr = (fBull and fBear) ? not keepBull : fBear
    gb = (gBull and gBear) ? keepBull : gBull
    gr = (gBull and gBear) ? not keepBull : gBear

    anyF = fb or fr
    anyG = gb or gr

    int sel = 0
    if preferGold
        if anyG
            sel := gb ? 3 : 4
        else if anyF
            sel := fb ? 1 : 2
    else
        if anyF
            sel := fb ? 1 : 2
        else if anyG
            sel := gb ? 3 : 4
    sel

// ─────────────────────────────────────────────────────────────
// Preset resolution
// ─────────────────────────────────────────────────────────────
tfSec = timeframe.in_seconds(timeframe.period)

autoPreset =
     tfSec <= 5 * 60       ? "Scalp" :
     tfSec <= 60 * 60      ? "Intraday" :
     tfSec <= 24 * 60 * 60 ? "Swing" :
                              "Position"

preset = presetIn == "Auto" ? autoPreset : presetIn

isAuto     = presetIn == "Auto"
isCustom   = preset == "Custom"
isScalp    = preset == "Scalp"
isIntraday = preset == "Intraday"
isSwing    = preset == "Swing"
isPosition = preset == "Position"

profCon = profileIn == "Conservative"
profAgg = profileIn == "Aggressive"

profCdAdj  = profCon ? 2 : profAgg ? -1 : 0
profAtrAdj = profCon ? 0.10 : profAgg ? -0.05 : 0.0

// Effective toggles
effFlipSignals = enableFlipSignals_in and maxFlipSignals > 0
effGoldSignals = enableGoldenSignals_in and maxGoldSignals > 0

effH13 = enableH13Line_in
effL21 = enableL21Line_in
effHH8 = enableHH8Line_in
effLL8 = enableLL8Line_in

effDecisionBox = enableDecisionBox_in
effExhUpper = enableExhUpper_in
effExhLower = enableExhLower_in
effValuesTable = enableValuesTable_in

// Effective filters
useTrendFilter = isCustom ? useTrendFilter_in : (isIntraday or isSwing or isPosition)
emaLen = isCustom ? emaLen_in : (isScalp ? 50 : 200)

useVolFilter = isCustom ? useVolFilter_in : (isScalp or isIntraday)
atrLen = atrLen_in

minAtrPctBase = isCustom ? minAtrPct_in : (isScalp ? 0.10 : isIntraday ? 0.15 : minAtrPct_in)
minAtrPct = math.max(0.0, minAtrPctBase + profAtrAdj)

useCooldown = isCustom ? useCooldown_in : true

flipCooldownBase = isCustom ? flipCooldownBars_in :
     isScalp ? 1 :
     isIntraday ? 2 :
     isSwing ? 3 : 5

goldCooldownBase = isCustom ? goldCooldownBars_in :
     isScalp ? 1 :
     isIntraday ? 2 :
     isSwing ? 3 : 5

flipCooldownBars = math.max(0, flipCooldownBase + profCdAdj)
goldCooldownBars = math.max(0, goldCooldownBase + profCdAdj)

flipOutsideExh = isCustom ? flipOutsideExh_in : false

useHtfConfirm = isCustom ? useHtfConfirm_in : true
htfEmaLen = htfEmaLen_in

// Fixed HTF mapping.
htfTf_fixed =
     isCustom ? htfTf_in :
     isScalp ? "15" :
     isIntraday ? "240" :
     isSwing ? (tfSec < timeframe.in_seconds("D") ? "D" : "W") :
     isPosition ? (
         tfSec < timeframe.in_seconds("W") ? "W" :
         tfSec < timeframe.in_seconds("M") ? "M" : "3M"
     ) :
     htfTf_in

autoTargetSec = int(math.round(tfSec * autoHtfMult_in))
autoHtfTf = f_pick_tf(autoTargetSec)
useRatioAuto = isAuto and autoTfMethod_in == "Ratio"
htfTf = useRatioAuto ? autoHtfTf : htfTf_fixed

htfSec = timeframe.in_seconds(htfTf)
htfValid = htfSec > tfSec

if useHtfConfirm and not htfValid
    runtime.error("Non-repaint HTF confirmation requires HTF > chart timeframe. Increase the HTF timeframe or Auto HTF multiple.")

// ─────────────────────────────────────────────────────────────
// Core levels
// ─────────────────────────────────────────────────────────────
hi13 = ta.highest(high, lenHigh)
lo21 = ta.lowest(low, lenLow)

// Prior-bar breakout thresholds. The current bar cannot modify its own HH/LL trigger.
hh8 = ta.highest(high, lenFlip)[1]
ll8 = ta.lowest(low, lenFlip)[1]

ema = ta.ema(close, emaLen)

// Exhaustion zones are evaluated from FINAL bar values for signals.
exhHi  = ta.highest(high, lenExh)
exhLo  = ta.lowest(low, lenExh)
exhRng = exhHi - exhLo

exhUpperBottom = exhHi - exhRng * zonePct_in
exhUpperTop    = exhHi
exhLowerTop    = exhLo + exhRng * zonePct_in
exhLowerBottom = exhLo

inUpperExh = close >= exhUpperBottom and close <= exhUpperTop
inLowerExh = close <= exhLowerTop and close >= exhLowerBottom
outsideExh = not inUpperExh and not inLowerExh

upperEntryRaw = inUpperExh and not inUpperExh[1]
lowerEntryRaw = inLowerExh and not inLowerExh[1]

// ─────────────────────────────────────────────────────────────
// Trend / volatility
// ─────────────────────────────────────────────────────────────
bullAbove = profAgg ? close >= ema : close > ema
bearBelow = profAgg ? close <= ema : close < ema

bullSlopeOk = not profCon or ema >= ema[1]
bearSlopeOk = not profCon or ema <= ema[1]

trendOKBull = not useTrendFilter or (bullAbove and bullSlopeOk)
trendOKBear = not useTrendFilter or (bearBelow and bearSlopeOk)

tr = ta.tr(true)
atr = ta.rma(tr, atrLen)
atrPct = close != 0.0 ? atr / close * 100.0 : na

volOK = not useVolFilter or (not na(atrPct) and atrPct >= minAtrPct)

// ─────────────────────────────────────────────────────────────
// Confirmed HTF filter — NON-REPAINT
// TradingView's robust pattern: expression[1] + lookahead_on.
// ─────────────────────────────────────────────────────────────
f_htf_pack(_emaLen) =>
    [close[1], ta.ema(close, _emaLen)[1]]

[htfCls, htfEma] = request.security(
     syminfo.tickerid,
     htfTf,
     f_htf_pack(htfEmaLen),
     lookahead=barmerge.lookahead_on
)

htfBullOK = not useHtfConfirm or (not na(htfCls) and not na(htfEma) and htfCls > htfEma)
htfBearOK = not useHtfConfirm or (not na(htfCls) and not na(htfEma) and htfCls < htfEma)

// ─────────────────────────────────────────────────────────────
// Independent cooldowns
// ─────────────────────────────────────────────────────────────
var int lastFlipSignalIdx = na
var int lastGoldSignalIdx = na

flipCoolOK = not useCooldown or na(lastFlipSignalIdx) or bar_index - lastFlipSignalIdx > flipCooldownBars
goldCoolOK = not useCooldown or na(lastGoldSignalIdx) or bar_index - lastGoldSignalIdx > goldCooldownBars

// ─────────────────────────────────────────────────────────────
// Signal candidates
// IMPORTANT:
//  close > HH / close < LL are evaluated only at bar close in the final signals.
//  Strict inequality removes equality-touch noise.
// ─────────────────────────────────────────────────────────────
bullBreakBase = not na(hh8) and close > hh8
bearBreakBase = not na(ll8) and close < ll8

flipExhOK = not flipOutsideExh or outsideExh

bullFlipCandidate =
     bullBreakBase and
     trendOKBull and
     volOK and
     flipCoolOK and
     flipExhOK and
     htfBullOK

bearFlipCandidate =
     bearBreakBase and
     trendOKBear and
     volOK and
     flipCoolOK and
     flipExhOK and
     htfBearOK

goldBullLoose =
     bullBreakBase and
     close > ema and
     outsideExh and
     goldCoolOK and
     htfBullOK

goldBearLoose =
     bearBreakBase and
     close < ema and
     outsideExh and
     goldCoolOK and
     htfBearOK

goldBullStrict =
     bullBreakBase and
     trendOKBull and
     volOK and
     goldCoolOK and
     outsideExh and
     htfBullOK

goldBearStrict =
     bearBreakBase and
     trendOKBear and
     volOK and
     goldCoolOK and
     outsideExh and
     htfBearOK

goldBullCandidate = goldStrictFilters ? goldBullStrict : goldBullLoose
goldBearCandidate = goldStrictFilters ? goldBearStrict : goldBearLoose

// ─────────────────────────────────────────────────────────────
// FINAL NON-REPAINT SIGNALS
// No signal exists until the chart bar is confirmed.
// ─────────────────────────────────────────────────────────────
bullF0 = effFlipSignals and barstate.isconfirmed and bullFlipCandidate
bearF0 = effFlipSignals and barstate.isconfirmed and bearFlipCandidate
goldB0 = effGoldSignals and barstate.isconfirmed and goldBullCandidate
goldS0 = effGoldSignals and barstate.isconfirmed and goldBearCandidate

preferGold = oneSignalPriority_in == "Prefer Golden"
keepBullDir = close >= open

sel = oneSignalPerBar_in ?
     f_pick_signal(bullF0, bearF0, goldB0, goldS0, keepBullDir, preferGold) : 0

sigL  = oneSignalPerBar_in ? sel == 1 : bullF0
sigS  = oneSignalPerBar_in ? sel == 2 : bearF0
sigEL = oneSignalPerBar_in ? sel == 3 : goldB0
sigES = oneSignalPerBar_in ? sel == 4 : goldS0

sigTW = barstate.isconfirmed and upperEntryRaw
sigBW = barstate.isconfirmed and lowerEntryRaw

// Cooldowns update ONLY from signals that were actually emitted.
if barstate.isconfirmed
    if sigL or sigS
        lastFlipSignalIdx := bar_index
    if sigEL or sigES
        lastGoldSignalIdx := bar_index

// ─────────────────────────────────────────────────────────────
// Plots
// ─────────────────────────────────────────────────────────────
plot(effH13 ? hi13 : na, title="H13", color=color.new(h13LineColor_in, 0), style=plot.style_stepline)
plot(effL21 ? lo21 : na, title="L21", color=color.new(l21LineColor_in, 0), style=plot.style_stepline)
plot(effHH8 ? hh8 : na, title="HH8", color=color.new(hh8LineColor_in, 0), style=plot.style_stepline)
plot(effLL8 ? ll8 : na, title="LL8", color=color.new(ll8LineColor_in, 0), style=plot.style_stepline)

// Hidden support values
plot(exhHi, title="ExhHi (lookback high)", display=display.none)
plot(exhLo, title="ExhLo (lookback low)", display=display.none)
plot(exhUpperBottom, title="ExhUpperBottom", display=display.none)
plot(exhLowerTop, title="ExhLowerTop", display=display.none)
plot(ema, title="EMA", display=display.none)
plot(atrPct, title="ATR%", display=display.none)
plot(htfCls, title="Confirmed HTF Close", display=display.none)
plot(htfEma, title="Confirmed HTF EMA", display=display.none)

// ─────────────────────────────────────────────────────────────
// Boxes — updated only on confirmed bars
// ─────────────────────────────────────────────────────────────
var box exhUpper = na
var box exhLower = na
var box decBox = na

if not effExhUpper and not na(exhUpper)
    box.delete(exhUpper)
    exhUpper := na

if not effExhLower and not na(exhLower)
    box.delete(exhLower)
    exhLower := na

if not effDecisionBox and not na(decBox)
    box.delete(decBox)
    decBox := na

if barstate.isconfirmed
    if effExhUpper
        if not na(exhUpperTop) and not na(exhUpperBottom)
            if na(exhUpper)
                exhUpper := box.new(
                     left=bar_index,
                     right=bar_index,
                     top=exhUpperTop,
                     bottom=exhUpperBottom,
                     bgcolor=color.new(exhUpperColor_in, 85),
                     border_color=color.new(exhUpperColor_in, 60)
                )
            box.set_left(exhUpper, math.max(0, bar_index - lenExh + 1))
            box.set_right(exhUpper, bar_index)
            box.set_top(exhUpper, exhUpperTop)
            box.set_bottom(exhUpper, exhUpperBottom)
        else if not na(exhUpper)
            box.delete(exhUpper)
            exhUpper := na

    if effExhLower
        if not na(exhLowerTop) and not na(exhLowerBottom)
            if na(exhLower)
                exhLower := box.new(
                     left=bar_index,
                     right=bar_index,
                     top=exhLowerTop,
                     bottom=exhLowerBottom,
                     bgcolor=color.new(exhLowerColor_in, 85),
                     border_color=color.new(exhLowerColor_in, 60)
                )
            box.set_left(exhLower, math.max(0, bar_index - lenExh + 1))
            box.set_right(exhLower, bar_index)
            box.set_top(exhLower, exhLowerTop)
            box.set_bottom(exhLower, exhLowerBottom)
        else if not na(exhLower)
            box.delete(exhLower)
            exhLower := na

    if effDecisionBox
        if not na(hh8) and not na(ll8)
            decBand = atr * decisionRangeAtr_in
            decBull = close > ema + decBand
            decBear = close < ema - decBand
            decBase = decisionDynColor_in ?
                 (decBull ? decisionBullColor_in : decBear ? decisionBearColor_in : decisionRangeColor_in) :
                 decisionBullColor_in

            decFill = color.new(decBase, 92)
            decBorder = color.new(decBase, 70)

            if na(decBox)
                decBox := box.new(
                     left=bar_index,
                     right=bar_index,
                     top=hh8,
                     bottom=ll8,
                     bgcolor=decFill,
                     border_color=decBorder
                )

            box.set_bgcolor(decBox, decFill)
            box.set_border_color(decBox, decBorder)
            box.set_left(decBox, math.max(0, bar_index - lenFlip + 1))
            box.set_right(decBox, bar_index)
            box.set_top(decBox, hh8)
            box.set_bottom(decBox, ll8)
        else if not na(decBox)
            box.delete(decBox)
            decBox := na

// ─────────────────────────────────────────────────────────────
// Signal label ring buffers
// ─────────────────────────────────────────────────────────────
TOTAL_LABEL_BUDGET = 480

wantFlip = effFlipSignals ? maxFlipSignals : 0
wantGold = effGoldSignals ? maxGoldSignals : 0
sumWant = wantFlip + wantGold

int flipCapEff = wantFlip
int goldCapEff = wantGold

if sumWant <= 0
    flipCapEff := 0
    goldCapEff := 0
else if sumWant > TOTAL_LABEL_BUDGET
    flipCapEff := int(math.floor(TOTAL_LABEL_BUDGET * (wantFlip / sumWant)))
    goldCapEff := TOTAL_LABEL_BUDGET - flipCapEff

    if wantFlip > 0 and flipCapEff == 0
        flipCapEff := 1
        goldCapEff := math.max(0, goldCapEff - 1)

    if wantGold > 0 and goldCapEff == 0
        goldCapEff := 1
        flipCapEff := math.max(0, TOTAL_LABEL_BUDGET - goldCapEff)

flipBufSize = flipCapEff > 0 ? flipCapEff : 1
goldBufSize = goldCapEff > 0 ? goldCapEff : 1

var label[] flipBuf = array.new_label(flipBufSize, na)
var label[] goldBuf = array.new_label(goldBufSize, na)
var int flipHead = 0
var int flipCount = 0
var int goldHead = 0
var int goldCount = 0

f_ring_push(label[] buf, int head, int count, int cap, label lb) =>
    int newHead = head
    int newCount = count

    if cap > 0 and not na(lb)
        idx = newHead
        old = array.get(buf, idx)

        if newCount == cap
            if not na(old)
                label.delete(old)
        else
            newCount += 1

        array.set(buf, idx, lb)
        newHead := (newHead + 1) % cap

    [newHead, newCount]

// Cached ATRs used only for label placement.
atrFlip = nz(ta.rma(tr, flipAtrLen), tr)
atrGold = nz(ta.rma(tr, goldAtrLen), tr)

flipOffPx = flipOffsetMode == "ATR" ? atrFlip * flipAtrMult : syminfo.mintick * flipTicks
goldOffPx = goldOffsetMode == "ATR" ? atrGold * goldAtrMult : syminfo.mintick * goldTicks

f_new_flip_label(doCreate, bull) =>
    label lb = na
    if doCreate
        off = flipOffPx
        y = bull ? low - off : high + off
        txt = flipRender == "Text" ? f_flip_symbol(bull) : ""
        col = bull ? flipBullColor : flipBearColor
        st = f_flip_style(bull)
        tip = bull ? "MRS NR Bullish Bias Shift — confirmed bar" : "MRS NR Bearish Bias Shift — confirmed bar"

        lb := label.new(
             bar_index,
             y,
             txt,
             xloc=xloc.bar_index,
             style=flipRender == "Text" ? label.style_none : st,
             textcolor=col,
             color=flipRender == "Text" ? color.new(col, 100) : col,
             size=f_size(flipSize),
             tooltip=tip
        )
    lb

f_new_gold_label(doCreate, bull) =>
    label lb = na
    if doCreate
        off = goldOffPx
        y = bull ? low - off : high + off
        txt = goldRender == "Text" ? f_gold_symbol(bull) : ""
        col = bull ? goldBullColor : goldBearColor
        st = f_gold_style(bull)
        tip = bull ? "MRS NR Golden Bull — confirmed bar" : "MRS NR Golden Bear — confirmed bar"

        lb := label.new(
             bar_index,
             y,
             txt,
             xloc=xloc.bar_index,
             style=goldRender == "Text" ? label.style_none : st,
             textcolor=col,
             color=goldRender == "Text" ? color.new(col, 100) : col,
             size=f_size(goldSize),
             tooltip=tip
        )
    lb

newFlipBull = f_new_flip_label(sigL and flipCapEff > 0, true)
newFlipBear = f_new_flip_label(sigS and flipCapEff > 0, false)
newGoldBull = f_new_gold_label(sigEL and goldCapEff > 0, true)
newGoldBear = f_new_gold_label(sigES and goldCapEff > 0, false)

if not na(newFlipBull)
    [_fh1, _fc1] = f_ring_push(flipBuf, flipHead, flipCount, flipCapEff, newFlipBull)
    flipHead := _fh1
    flipCount := _fc1

if not na(newFlipBear)
    [_fh2, _fc2] = f_ring_push(flipBuf, flipHead, flipCount, flipCapEff, newFlipBear)
    flipHead := _fh2
    flipCount := _fc2

if not na(newGoldBull)
    [_gh1, _gc1] = f_ring_push(goldBuf, goldHead, goldCount, goldCapEff, newGoldBull)
    goldHead := _gh1
    goldCount := _gc1

if not na(newGoldBear)
    [_gh2, _gc2] = f_ring_push(goldBuf, goldHead, goldCount, goldCapEff, newGoldBear)
    goldHead := _gh2
    goldCount := _gc2

// ─────────────────────────────────────────────────────────────
// Values table
// ─────────────────────────────────────────────────────────────
cGrid  = color.new(color.gray, 0)
cTrans = color.new(color.black, 100)
cH13   = color.new(color.red, 0)
cL21   = color.new(color.green, 0)
cHH8   = color.new(color.blue, 0)
cLL8   = color.new(color.purple, 0)

tablePos = valuesTablePos_in == "Top right" ? position.top_right : position.bottom_right

var table t = table.new(
     tablePos,
     4,
     4,
     bgcolor=cTrans,
     frame_color=color.new(cGrid, 100),
     frame_width=0,
     border_color=color.new(cGrid, 100),
     border_width=0
)

f_table_hide() =>
    table.clear(t, 0, 0, 3, 3)
    table.set_frame_width(t, 0)
    table.set_border_width(t, 0)
    table.set_frame_color(t, color.new(cGrid, 100))
    table.set_border_color(t, color.new(cGrid, 100))

f_fchg(float a, float b) =>
    (na(a) and na(b)) ? false : (na(a) != na(b)) ? true : a != b

var bool tblShown = false
var float c_hi13 = na
var float c_lo21 = na
var float c_hh8 = na
var float c_ll8 = na
var float c_exhUpperBottom = na
var float c_exhUpperTop = na
var float c_exhLowerTop = na
var float c_exhLowerBottom = na

if barstate.islast
    if effValuesTable
        if not tblShown
            tblShown := true
            table.set_frame_width(t, 1)
            table.set_border_width(t, 1)
            table.set_frame_color(t, cGrid)
            table.set_border_color(t, cGrid)

            table.cell(t, 0, 0, "H 13", text_color=cH13, bgcolor=cTrans, text_halign=text.align_center)
            table.cell(t, 1, 0, "L 21", text_color=cL21, bgcolor=cTrans, text_halign=text.align_center)
            table.cell(t, 2, 0, "HH 8", text_color=cHH8, bgcolor=cTrans, text_halign=text.align_center)
            table.cell(t, 3, 0, "LL 8", text_color=cLL8, bgcolor=cTrans, text_halign=text.align_center)

            table.cell(t, 0, 2, "Upper Low", text_color=cGrid, bgcolor=cTrans, text_halign=text.align_center)
            table.cell(t, 1, 2, "Upper High", text_color=cGrid, bgcolor=cTrans, text_halign=text.align_center)
            table.cell(t, 2, 2, "Lower High", text_color=cGrid, bgcolor=cTrans, text_halign=text.align_center)
            table.cell(t, 3, 2, "Lower Low", text_color=cGrid, bgcolor=cTrans, text_halign=text.align_center)

        if f_fchg(hi13, c_hi13)
            table.cell(t, 0, 1, str.tostring(hi13, format.mintick), text_color=cH13, bgcolor=cTrans, text_halign=text.align_center)
            c_hi13 := hi13

        if f_fchg(lo21, c_lo21)
            table.cell(t, 1, 1, str.tostring(lo21, format.mintick), text_color=cL21, bgcolor=cTrans, text_halign=text.align_center)
            c_lo21 := lo21

        if f_fchg(hh8, c_hh8)
            table.cell(t, 2, 1, str.tostring(hh8, format.mintick), text_color=cHH8, bgcolor=cTrans, text_halign=text.align_center)
            c_hh8 := hh8

        if f_fchg(ll8, c_ll8)
            table.cell(t, 3, 1, str.tostring(ll8, format.mintick), text_color=cLL8, bgcolor=cTrans, text_halign=text.align_center)
            c_ll8 := ll8

        if f_fchg(exhUpperBottom, c_exhUpperBottom)
            table.cell(t, 0, 3, str.tostring(exhUpperBottom, format.mintick), text_color=cGrid, bgcolor=cTrans, text_halign=text.align_center)
            c_exhUpperBottom := exhUpperBottom

        if f_fchg(exhUpperTop, c_exhUpperTop)
            table.cell(t, 1, 3, str.tostring(exhUpperTop, format.mintick), text_color=cGrid, bgcolor=cTrans, text_halign=text.align_center)
            c_exhUpperTop := exhUpperTop

        if f_fchg(exhLowerTop, c_exhLowerTop)
            table.cell(t, 2, 3, str.tostring(exhLowerTop, format.mintick), text_color=cGrid, bgcolor=cTrans, text_halign=text.align_center)
            c_exhLowerTop := exhLowerTop

        if f_fchg(exhLowerBottom, c_exhLowerBottom)
            table.cell(t, 3, 3, str.tostring(exhLowerBottom, format.mintick), text_color=cGrid, bgcolor=cTrans, text_halign=text.align_center)
            c_exhLowerBottom := exhLowerBottom
    else if tblShown
        f_table_hide()
        tblShown := false
        c_hi13 := na
        c_lo21 := na
        c_hh8 := na
        c_ll8 := na
        c_exhUpperBottom := na
        c_exhUpperTop := na
        c_exhLowerTop := na
        c_exhLowerBottom := na

// ─────────────────────────────────────────────────────────────
// Debug — Data Window only
// ─────────────────────────────────────────────────────────────
plot(enableDebugDW ? (barstate.isconfirmed ? 1 : 0) : na,
     title="DBG: Chart bar confirmed", display=enableDebugDW ? display.data_window : display.none)

plot(enableDebugDW ? (useTrendFilter ? 1 : 0) : na,
     title="DBG: Trend filter enabled", display=enableDebugDW ? display.data_window : display.none)

plot(enableDebugDW ? emaLen : na,
     title="DBG: EMA length", display=enableDebugDW ? display.data_window : display.none)

plot(enableDebugDW ? (useVolFilter ? 1 : 0) : na,
     title="DBG: Vol filter enabled", display=enableDebugDW ? display.data_window : display.none)

plot(enableDebugDW ? atrPct : na,
     title="DBG: ATR%", display=enableDebugDW ? display.data_window : display.none)

plot(enableDebugDW ? minAtrPct : na,
     title="DBG: Min ATR%", display=enableDebugDW ? display.data_window : display.none)

plot(enableDebugDW ? flipCooldownBars : na,
     title="DBG: Bias cooldown bars", display=enableDebugDW ? display.data_window : display.none)

plot(enableDebugDW ? goldCooldownBars : na,
     title="DBG: Golden cooldown bars", display=enableDebugDW ? display.data_window : display.none)

plot(enableDebugDW ? (htfValid ? 1 : 0) : na,
     title="DBG: HTF valid (> chart TF)", display=enableDebugDW ? display.data_window : display.none)

plot(enableDebugDW ? (htfBullOK ? 1 : 0) : na,
     title="DBG: Confirmed HTF bull OK", display=enableDebugDW ? display.data_window : display.none)

plot(enableDebugDW ? (htfBearOK ? 1 : 0) : na,
     title="DBG: Confirmed HTF bear OK", display=enableDebugDW ? display.data_window : display.none)

// ─────────────────────────────────────────────────────────────
// TradingView static alerts — ALL confirmed close only
// ─────────────────────────────────────────────────────────────
alertcondition(sigL, "talgos NR: Bullish Bias Shift", "Bullish Bias Shift — confirmed bar, non-repaint.")
alertcondition(sigS, "talgos NR: Bearish Bias Shift", "Bearish Bias Shift — confirmed bar, non-repaint.")

alertcondition(sigEL, "talgos NR: Golden Bull", "Golden Bull — confirmed bar, non-repaint.")
alertcondition(sigES, "talgos NR: Golden Bear", "Golden Bear — confirmed bar, non-repaint.")

alertcondition(sigTW, "talgos NR: Exhaustion Upper Entry", "Exhaustion Upper Entry — confirmed bar, non-repaint.")
alertcondition(sigBW, "talgos NR: Exhaustion Lower Entry", "Exhaustion Lower Entry — confirmed bar, non-repaint.")

// ─────────────────────────────────────────────────────────────
// Webhook helpers — confirmed bar only
// alert.freq_all is deliberate so several DISTINCT signal types can be sent
// on the same confirmed bar. There is no intrabar webhook path.
// ─────────────────────────────────────────────────────────────
const string TALGOS_VENDOR  = "TALGOS"
const string TALGOS_VERSION = "10.0-NR"

f_json_escape(s) =>
    s1 = str.replace_all(s, "\\", "\\\\")
    s2 = str.replace_all(s1, "\"", "\\\"")
    s3 = str.replace_all(s2, "\n", "\\n")
    s3

f_wh_bool(v) => v ? "true" : "false"
f_wh_num(float v) => na(v) ? "null" : str.tostring(v)
f_wh_str(s) => "\"" + f_json_escape(s) + "\""

f_wh_price() =>
    wh_priceField == "hl2" ? hl2 :
     wh_priceField == "ohlc4" ? ohlc4 :
     close

f_wh_id(sigName, codeName) =>
    wh_idPrefix + "|" + syminfo.tickerid + "|" + timeframe.period + "|" + str.tostring(time) + "|" + codeName + "|" + sigName

f_wh_payload(sigName, codeName) =>
    p = f_wh_price()
    trendState = na(ema) ? 0 : close > ema ? 1 : close < ema ? -1 : 0
    htfState = (na(htfCls) or na(htfEma)) ? 0 : htfCls > htfEma ? 1 : htfCls < htfEma ? -1 : 0

    string msg = "{"
    msg += "\"vendor\":" + f_wh_str(TALGOS_VENDOR) + ","
    msg += "\"version\":" + f_wh_str(TALGOS_VERSION) + ","
    msg += "\"id\":" + f_wh_str(f_wh_id(sigName, codeName)) + ","
    msg += "\"signal\":" + f_wh_str(sigName) + ","
    msg += "\"code\":" + f_wh_str(codeName) + ","
    msg += "\"symbol\":" + f_wh_str(syminfo.tickerid) + ","
    msg += "\"exchange\":" + f_wh_str(syminfo.prefix) + ","
    msg += "\"ticker\":" + f_wh_str(syminfo.ticker) + ","
    msg += "\"timeframe\":" + f_wh_str(timeframe.period) + ","
    msg += "\"barIndex\":" + str.tostring(bar_index) + ","
    msg += "\"barTime\":" + str.tostring(time) + ","
    msg += "\"barTimeClose\":" + str.tostring(time_close) + ","
    msg += "\"triggerTime\":" + str.tostring(timenow) + ","
    msg += "\"confirmed\":true,"
    msg += "\"price\":" + f_wh_num(p) + ","
    msg += "\"trendState\":" + str.tostring(trendState) + ","
    msg += "\"htfState\":" + str.tostring(htfState)

    if wh_payloadDetail == "Verbose"
        msg += ",\"ema\":" + f_wh_num(ema)
        msg += ",\"atrPct\":" + f_wh_num(atrPct)
        msg += ",\"h13\":" + f_wh_num(hi13)
        msg += ",\"l21\":" + f_wh_num(lo21)
        msg += ",\"hh8\":" + f_wh_num(hh8)
        msg += ",\"ll8\":" + f_wh_num(ll8)
        msg += ",\"exhUpperBottom\":" + f_wh_num(exhUpperBottom)
        msg += ",\"exhUpperTop\":" + f_wh_num(exhUpperTop)
        msg += ",\"exhLowerTop\":" + f_wh_num(exhLowerTop)
        msg += ",\"exhLowerBottom\":" + f_wh_num(exhLowerBottom)
        msg += ",\"volOK\":" + f_wh_bool(volOK)
        msg += ",\"flipCoolOK\":" + f_wh_bool(flipCoolOK)
        msg += ",\"goldCoolOK\":" + f_wh_bool(goldCoolOK)
        msg += ",\"trendOKBull\":" + f_wh_bool(trendOKBull)
        msg += ",\"trendOKBear\":" + f_wh_bool(trendOKBear)
        msg += ",\"outsideExh\":" + f_wh_bool(outsideExh)
        msg += ",\"htfClose\":" + f_wh_num(htfCls)
        msg += ",\"htfEma\":" + f_wh_num(htfEma)

        if wh_includeOHLC
            msg += ",\"o\":" + f_wh_num(open)
            msg += ",\"h\":" + f_wh_num(high)
            msg += ",\"l\":" + f_wh_num(low)
            msg += ",\"c\":" + f_wh_num(close)

    if str.length(wh_tag) > 0
        msg += ",\"tag\":" + f_wh_str(wh_tag)

    if str.length(wh_token) > 0
        msg += ",\"token\":" + f_wh_str(wh_token)

    msg += "}"
    msg

f_wh_plain(sigName, codeName) =>
    "TALGOS|" + sigName +
     "|code=" + codeName +
     "|sym=" + syminfo.tickerid +
     "|tf=" + timeframe.period +
     "|px=" + str.tostring(f_wh_price()) +
     "|conf=1"

f_wh_msg(sigName, codeName) =>
    wh_format == "Plain" ? f_wh_plain(sigName, codeName) : f_wh_payload(sigName, codeName)

f_wh_send(cond, sigName, codeName) =>
    if wh_enable and barstate.isconfirmed and cond
        alert(f_wh_msg(sigName, codeName), alert.freq_all)

// Webhook dispatch.
// Because every condition is confirmed-bar gated, no signal can fire intrabar.
f_wh_send(sigL, "Bullish Bias Shift", "L")
f_wh_send(sigS, "Bearish Bias Shift", "S")

f_wh_send(wh_includeGolden and sigEL, "Golden Bull", "EL")
f_wh_send(wh_includeGolden and sigES, "Golden Bear", "ES")

f_wh_send(wh_includeExhaustion and sigTW, "Exhaustion Upper Entry", "TW")
f_wh_send(wh_includeExhaustion and sigBW, "Exhaustion Lower Entry", "BW")
````

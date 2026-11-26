# Buy and Sell Candle Pressure

- url: https://www.tradingview.com/script/o1SkDByD-Buy-and-Sell-Candle-Pressure/
- type: indicator
- pine_id: PUB;37155691d99e4b16b61c38399150c5ae
- version: 1.0

## Description

Buy and Sell Candle Pressure takes the candle-pressure model used in my closed-source script "Predictive Volume MTF Pro"  workflow and brings that Buy/Sell pressure read directly onto the price chart. Instead of viewing the Buy/Sell split only inside a table, the candles themselves can now show whether the active candle structure is leaning bullish, bearish, neutral, or moving through stronger pressure tiers.

The goal is simple:

• keep the real OHLC candle shape intact
• recolor the candle body, wick, and border from the candle-pressure engine
• make candle-by-candle pressure easier to see directly on the chart
• add local and higher-timeframe bias trails for extra context

This is not meant to replace the main Predictive Volume dashboard. It is meant to be a lightweight visual companion that helps bring the Buy/Sell pressure read into your chart space.

────────────────────────────
What the Candle Colors Represent
────────────────────────────

The candle overlay uses a candle-structure pressure estimate built from OHLC and volume behavior.

The pressure model looks at more than just whether a candle closed green or red. It considers:

• where the close sits inside the full candle range
• how much directional conviction is shown by the candle body
• how upper and lower wicks may reflect rejection, absorption, or imbalance

That pressure score is then converted into a rounded Buy/Sell split and used to color the candle overlay.

Important:
This is not true order flow, bid/ask volume, or exchange-level volume delta. It is a candle-structure pressure estimate designed to give visual context from the candle itself.

────────────────────────────
Bias Modes
────────────────────────────

The script includes two candle color modes:

Standard

A simple bull / bear / neutral color mode.

This is the cleanest option if you only want to know whether the candle-pressure read is leaning toward buy pressure, sell pressure, or balance.

Standard II

A stronger tiered color mode.

This mode expands the Buy/Sell pressure split into multiple bull and bear intensity levels. Lighter colors represent earlier pressure development, while stronger colors represent more aggressive Buy/Sell pressure readings.

────────────────────────────
Pressure Bias Trail
────────────────────────────

The Pressure Bias Trail is a rolling price-bias reference line designed to pair with the pressure candles.

In plain terms:

• candles show current-bar Buy/Sell pressure
• the Pressure Bias Trail shows the local rolling price-bias reference

The trail is calculated from the selected price source, average type, and length. Its color is based on whether the current close is above or below the trail.

This gives the chart two layers of context:

• candle pressure = what the current candle is showing
• trail position = whether price is holding above or below its rolling bias reference

────────────────────────────
HTF Pressure Bias Trail
────────────────────────────

The HTF Pressure Bias Trail applies the same trail formula on an automatically selected higher timeframe.

The HTF value is stabilized using SimpleCryptoLife’s HighTimeframeSampling library so the higher-timeframe trail behaves more smoothly on the active chart timeframe.

This can help users compare:

• current candle pressure
• local rolling price bias
• higher-timeframe rolling price bias

When price is above both the local and HTF trails, the chart can show stronger alignment. When price is trapped between them, fading through one, or repeatedly rejecting one, the trails can provide useful context around pressure transitions.

────────────────────────────
Included Visual Tools
────────────────────────────

• Buy/Sell Pressure Candle Overlay
• Standard and Standard II pressure color modes
• Chart-timeframe Pressure Bias Trail
• HTF Pressure Bias Trail
• Bar-to-Bar Close Follow Line
• Last-Bar Index Follow Line
• Last-Bar Buy/Sell + Pressure Label

The pressure label shows the rounded Buy/Sell split on the first line and the normalized pressure value on the second line. It can auto-position above bullish pressure and below bearish pressure.

────────────────────────────
How I Use It
────────────────────────────

I view this script as a chart-side pressure layer.

The main Predictive Volume + MTF [Pro] script gives the broader table-based multi-timeframe volume view. This script brings one important part of that workflow — candle pressure — directly onto the candles.

Useful ways to read it:

• Standard II candles can highlight stronger Buy/Sell pressure tiers
• the local Pressure Bias Trail can show whether price is holding its short-term bias
• the HTF Pressure Bias Trail can show where higher-timeframe bias may be acting as context
• the pressure label gives a quick last-bar read without needing a full table

This is not a buy/sell signal system by itself. It is a visual context tool.

────────────────────────────
Companion Script
────────────────────────────

This script is designed to work hand in hand with:

Predictive Volume + MTF [Pro]
https://www.tradingview.com/script/hESCvPuH-Predictive-Volume-MTF-Pro/

Predictive Volume + MTF [Pro] remains the larger dashboard-style workflow for multi-timeframe predictive volume, current volume, previous volume, average volume, relative volume, and Buy/Sell pressure context.

Buy and Sell Candle Pressure is the lightweight open-source candle-overlay companion.

────────────────────────────
Attribution
────────────────────────────

Special thanks to SimpleCryptoLife for the original Predictive Volume foundation and for the HighTimeframeSampling library used to stabilize the HTF Pressure Bias Trail.

This open-source script is published as a companion visualization layer for "Predictive Volume + MTF [Pro]".

https://www.tradingview.com/x/Wphl6SHw/

https://www.tradingview.com/x/LOYVYs5m/

https://www.tradingview.com/x/97icTRgr/

https://www.tradingview.com/x/Mxy7dAHH/

## Source Code

````pine
//@version=6
indicator("Buy and Sell Candle Pressure", "Candle Pressure", overlay=true, max_lines_count=10, max_labels_count=10, calc_bars_count = 1500)

// ==============================================================================================
// 🟢 SCRIPT OVERVIEW
// ==============================================================================================
//
// Buy and Sell Candle Pressure is a lightweight chart-overlay companion for
// Predictive Volume + MTF [Pro].
//
// This script takes the candle-pressure model used in the Predictive Volume family
// and brings that Buy/Sell pressure read directly onto the price candles. Instead of
// only viewing Buy/Sell pressure inside a dashboard table, the chart itself can show
// whether the active candle structure is leaning bullish, bearish, neutral, or moving
// through stronger pressure tiers.
//
// The overlay keeps the original OHLC candle shape intact. Only the candle body,
// wick, and border colors are recolored from the pressure engine. This makes it easier
// to see candle-by-candle participation context without replacing price structure.
//
// The script also includes a Pressure Bias Trail system:
// • The chart-timeframe trail is a rolling average of the selected price source
// • The HTF trail applies the same formula on an automatically selected higher timeframe
// • The HTF trail is stabilized through SimpleCryptoLife's HTF sampler
// • Trail colors are based on whether price is above or below each trail
//
// Included visual tools:
// • Buy/Sell Pressure Candle Overlay
// • Standard and Standard II pressure color modes
// • Chart-Timeframe Pressure Bias Trail
// • HTF Pressure Bias Trail
// • Bar-to-Bar Close Follow Line
// • Last-Bar Index Follow Line
// • Last-Bar Buy/Sell + Pressure Label
//
// The pressure label shows the rounded Buy/Sell split on the first line and the
// normalized pressure value on the second line. Positive pressure can auto-position
// above the last bar, while negative pressure can auto-position below it.
//
// This is not true order flow, bid/ask volume, or exchange-level volume delta.
// It is a candle-structure pressure estimate built from OHLC and volume behavior.
//
// Companion script:
// Predictive Volume + MTF [Pro]
// https://www.tradingview.com/script/hESCvPuH-Predictive-Volume-MTF-Pro/
//
// Attribution:
// Predictive Volume concept/code lineage credited to SimpleCryptoLife.
// Higher-timeframe trail stabilization uses SimpleCryptoLife's HighTimeframeSampling library.
// This open-source candle overlay is published as a companion visualization layer
// for the Predictive Volume workflow.
//
// ==============================================================================================
// 🔴 END SCRIPT OVERVIEW
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: Library Imports
// ==============================================================================================

import MYNAMEISBRANDON/CandlePressure_Utilities/1 as CP
import SimpleCryptoLife/HighTimeframeSampling/4 as SCL_HTF

// ==============================================================================================
// 🔴 END REGION: Library Imports
// ==============================================================================================


// ==============================================================================================
// 🟢 REGION: Input Groups
// ==============================================================================================

const string G_CANDLES = "Buy/Sell Candles"
const string G_LABELS  = "Buy/Sell/Pressure Label"
const string G_PRESSURE_BIAS = "Pressure Bias Trail"
const string G_LINES   = "Follow Lines"

// ==============================================================================================
// 🔴 END REGION: Input Groups
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: Tooltip Strings
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: Buy/Sell Candles
// ──────────────────────────────────────────────
const string TT_BS_CANDLE_OVERLAY =
     "Shows or hides the Buy/Sell Pressure candle overlay.\n\n" +
     "When enabled, the script redraws the chart candles using the same OHLC shape, but recolors the body, wick, and border from the candle-pressure engine.\n\n" +
     "This does not replace price structure. It only adds a Buy/Sell pressure color layer on top of the chart candles."

const string TT_BS_CANDLE_LAST_BARS =
     "Controls how many of the most recent candles are shown with the Buy/Sell Pressure overlay.\n\n" +
     "Lower values keep the chart cleaner.\n" +
     "Higher values show more historical candle-pressure context."

const string TT_BIAS_MODE =
     "Controls how Buy/Sell pressure colors are assigned.\n\n" +
     "• Standard:\n" +
     "  Uses simple bull / bear / neutral coloring.\n\n" +
     "• Standard II:\n" +
     "  Uses stronger tiered bull and bear colors based on the rounded Buy/Sell pressure split.\n\n" +
     "Buy/Sell pressure is a candle-structure estimate built from OHLC and volume behavior. It is not true bid/ask order flow or exchange-level volume delta."

// ──────────────────────────────────────────────
// 🟦 Subregion: Pressure Bias Trail
// ──────────────────────────────────────────────
const string TT_PRESSURE_BIAS_TRAIL =
     "Shows or hides the Pressure Bias Trail.\n\n" +
     "This trail is a rolling average of the selected price source.\n\n" +
     "It is designed to pair with the Buy/Sell Pressure candles:\n" +
     "• Candles show current-bar Buy/Sell pressure\n" +
     "• The trail shows the rolling price-bias reference\n\n" +
     "The trail color is based on whether the current close is above, below, or equal to the trail."

const string TT_PRESSURE_BIAS_PLOT_LAST =
     "Controls how many of the most recent bars show the Pressure Bias Trail.\n\n" +
     "Lower values keep the chart cleaner.\n" +
     "Higher values show more historical rolling-bias context."

const string TT_PRESSURE_BIAS_LEN_MODE =
     "Controls how the Pressure Bias Trail length is chosen.\n\n" +
     "• Auto:\n" +
     "  Uses a chart-timeframe-based length.\n\n" +
     "• Manual:\n" +
     "  Uses the Manual Length input below.\n\n" +
     "Current Auto lengths:\n" +
     "• Seconds = 21\n" +
     "• 1m to 5m = 21\n" +
     "• Above 5m to 15m = 34\n" +
     "• Above 15m to 60m = 55\n" +
     "• Above 60m intraday = 89\n" +
     "• Daily = 21\n" +
     "• Weekly = 13\n" +
     "• Monthly = 8\n" +
     "• Fallback = 34"

const string TT_PRESSURE_BIAS_MANUAL_LEN =
     "Manual rolling-average length used when Length Mode = Manual.\n\n" +
     "Lower values make the trail faster and more reactive.\n" +
     "Higher values make the trail smoother and slower."

const string TT_PRESSURE_BIAS_AVG_TYPE =
     "Controls which moving average type is used to smooth the selected price source.\n\n" +
     "• EMA:\n" +
     "  Faster and more responsive to recent price movement.\n\n" +
     "• RMA:\n" +
     "  Smoother and slightly slower, similar to Wilder-style smoothing.\n\n" +
     "• SMA:\n" +
     "  Simple average of the selected source over the active length."

const string TT_PRESSURE_BIAS_SOURCE =
     "Controls which price source feeds the Pressure Bias Trail.\n\n" +
     "• Close:\n" +
     "  Uses the candle close only.\n\n" +
     "• HLC3:\n" +
     "  Uses the average of high, low, and close.\n\n" +
     "• OHLC4:\n" +
     "  Uses the average of open, high, low, and close.\n\n" +
     "The selected source is then smoothed by the active Average Type and Length."

const string TT_PRESSURE_BIAS_HTF_TRAIL =
     "Shows or hides the HTF Pressure Bias Trail.\n\n" +
     "This trail uses the same Pressure Bias Trail formula, but calculates it from an automatically selected higher timeframe.\n\n" +
     "Formula:\n" +
     "Selected Price Source → selected Average Type → selected Length → HTF Pressure Bias Trail\n\n" +
     "The HTF value is then stabilized with SimpleCryptoLife's HTF sampler so the higher-timeframe plot behaves more smoothly on the chart timeframe.\n\n" +
     "Current HTF selection is hardcoded to Auto:\n" +
     "• Seconds = 1m\n" +
     "• 1m to below 3m = 3m\n" +
     "• 3m to below 5m = 5m\n" +
     "• 5m to below 15m = 15m\n" +
     "• 15m to below 30m = 30m\n" +
     "• 30m to below 60m = 1h\n" +
     "• 1h to below 2h = 2h\n" +
     "• 2h to below 4h = 4h\n" +
     "• 4h to below 8h = 8h\n" +
     "• Higher intraday = 1D\n" +
     "• Daily = 1W\n" +
     "• Weekly = 1M\n" +
     "• Monthly and above = 12M\n\n" +
     "Color is based on whether the current close is above or below the HTF trail."
     
// ==============================================================================================
// 🔴 END REGION: Tooltip Strings
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: Inputs
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: Buy/Sell Candles
// ──────────────────────────────────────────────
// Candle display
string in_showBsCandles = input.string(defval="Show", title="Buy/Sell Candle Overlay", options=["Show", "Hide"], group=G_CANDLES, tooltip=TT_BS_CANDLE_OVERLAY)
int in_bsCandleLastBars = input.int(defval=144, minval=1, maxval=5000, title="  ↳ Last N Bars", group=G_CANDLES, tooltip=TT_BS_CANDLE_LAST_BARS, active=in_showBsCandles == "Show")

// Bias mode + Standard colors
string in_biasMode = input.string(defval="Standard II", title="Bias Mode", options=["Standard", "Standard II"], group=G_CANDLES, tooltip=TT_BIAS_MODE)
color in_standardBullColor = input.color(defval=color.rgb(134, 204, 136), title="Standard Bull Color", group=G_CANDLES, active=in_showBsCandles == "Show" and in_biasMode == "Standard")
color in_standardBearColor = input.color(defval=color.rgb(207, 62, 62), title="Standard Bear Color", group=G_CANDLES, active=in_showBsCandles == "Show" and in_biasMode == "Standard")

// Candle transparency
int in_bsCandleBodyTransp   = input.int(defval=80, minval=0, maxval=100, title="Body Transparency", group=G_CANDLES, active=in_showBsCandles == "Show")
int in_bsCandleWickTransp   = input.int(defval=0, minval=0, maxval=100, title="Wick Transparency", group=G_CANDLES, active=in_showBsCandles == "Show")
int in_bsCandleBorderTransp = input.int(defval=0, minval=0, maxval=100, title="Border Transparency", group=G_CANDLES, active=in_showBsCandles == "Show")

// ──────────────────────────────────────────────
// 🟦 Subregion: Pressure Label
// ──────────────────────────────────────────────
string in_showPressureLabel = input.string(defval="Show", title="Buy/Sell + Pressure Label", options=["Show", "Hide"], group=G_LABELS)
string in_pressureLabelPos  = input.string(defval="Auto", title="Label Position", options=["Auto", "Above", "Below"], group=G_LABELS, active=in_showPressureLabel == "Show")
string in_pressureLabelSize = input.string(defval="Normal", title="Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=G_LABELS, active=in_showPressureLabel == "Show")

// ──────────────────────────────────────────────
// 🟦 Subregion: Pressure Bias Trail
// ──────────────────────────────────────────────

// Rolling price-bias plot
string in_showPressureBiasTrail = input.string(defval="Show", title="Pressure Bias Trail", options=["Show", "Hide"], group=G_PRESSURE_BIAS, tooltip=TT_PRESSURE_BIAS_TRAIL)
int in_pressureBiasPlotLast     = input.int(defval=21, minval=1, maxval=5000, title="  ↳ Plot Last N Bars", group=G_PRESSURE_BIAS, tooltip=TT_PRESSURE_BIAS_PLOT_LAST, active=in_showPressureBiasTrail == "Show")
string in_pressureBiasLenMode   = input.string(defval="Auto", title="  ↳ Length Mode", options=["Auto", "Manual"], group=G_PRESSURE_BIAS, tooltip=TT_PRESSURE_BIAS_LEN_MODE, active=in_showPressureBiasTrail == "Show")
int in_pressureBiasManualLen    = input.int(defval=21, minval=1, maxval=500, title="  ↳ Manual Length", group=G_PRESSURE_BIAS, tooltip=TT_PRESSURE_BIAS_MANUAL_LEN, active=in_showPressureBiasTrail == "Show" and in_pressureBiasLenMode == "Manual")
string in_pressureBiasMaType    = input.string(defval="EMA", title="  ↳ Average Type", options=["EMA", "RMA", "SMA"], group=G_PRESSURE_BIAS, tooltip=TT_PRESSURE_BIAS_AVG_TYPE, active=in_showPressureBiasTrail == "Show")
string in_pressureBiasSource    = input.string(defval="HLC3", title="  ↳ Price Source", options=["Close", "HLC3", "OHLC4"], group=G_PRESSURE_BIAS, tooltip=TT_PRESSURE_BIAS_SOURCE, active=in_showPressureBiasTrail == "Show")
int in_pressureBiasLineWidth    = input.int(defval=2, minval=1, maxval=5, title="  ↳ Line Width", group=G_PRESSURE_BIAS, active=in_showPressureBiasTrail == "Show")
color in_pressureBiasBullColor  = input.color(defval=color.rgb(134, 204, 136), title="  ↳ Bull Color", group=G_PRESSURE_BIAS, active=in_showPressureBiasTrail == "Show")
color in_pressureBiasBearColor  = input.color(defval=color.rgb(207, 62, 62), title="  ↳ Bear Color", group=G_PRESSURE_BIAS, active=in_showPressureBiasTrail == "Show")
color in_pressureBiasFlatColor  = input.color(defval=color.gray, title="  ↳ Neutral Color", group=G_PRESSURE_BIAS, active=in_showPressureBiasTrail == "Show")

// HTF rolling price-bias plot
string in_showPressureBiasHtfTrail = input.string(defval="Show", title="HTF Pressure Bias Trail", options=["Show", "Hide"], group=G_PRESSURE_BIAS, tooltip=TT_PRESSURE_BIAS_HTF_TRAIL)
int in_pressureBiasHtfPlotLast     = input.int(defval=21, minval=1, maxval=5000, title="  ↳ HTF Plot Last N Bars", group=G_PRESSURE_BIAS, active=in_showPressureBiasHtfTrail == "Show")
int in_pressureBiasHtfLineWidth    = input.int(defval=2, minval=1, maxval=5, title="  ↳ HTF Line Width", group=G_PRESSURE_BIAS, active=in_showPressureBiasHtfTrail == "Show")
color in_pressureBiasHtfBullColor  = input.color(defval=#0055d4, title="  ↳ HTF Bull Color", group=G_PRESSURE_BIAS, active=in_showPressureBiasHtfTrail == "Show")
color in_pressureBiasHtfBearColor  = input.color(defval=#0055d4, title="  ↳ HTF Bear Color", group=G_PRESSURE_BIAS, active=in_showPressureBiasHtfTrail == "Show")

// ──────────────────────────────────────────────
// 🟦 Subregion: Follow Lines
// ──────────────────────────────────────────────
// Bar-to-bar close follow line
string in_showBarToBarLine = input.string(defval="Show", title="Bar-to-Bar Close Follow Line", options=["Show", "Hide"], group=G_LINES)
int in_barToBarLastBars    = input.int(defval=3, minval=1, maxval=5000, title="  ↳ Last N Bars", group=G_LINES, active=in_showBarToBarLine == "Show")
int in_barToBarLineWidth   = input.int(defval=2, minval=1, maxval=5, title="  ↳ Line Width", group=G_LINES, active=in_showBarToBarLine == "Show")

// Last-bar index follow line
string in_showIndexLine   = input.string(defval="Show", title="Last-Bar Index Follow Line", options=["Show", "Hide"], group=G_LINES)
int in_indexLineLeftBars  = input.int(defval=1, minval=0, maxval=50, title="  ↳ Left Bars", group=G_LINES, active=in_showIndexLine == "Show")
int in_indexLineRightBars = input.int(defval=2, minval=0, maxval=50, title="  ↳ Right Bars", group=G_LINES, active=in_showIndexLine == "Show")
int in_indexLineWidth     = input.int(defval=1, minval=1, maxval=5, title="  ↳ Line Width", group=G_LINES, active=in_showIndexLine == "Show")

// ==============================================================================================
// 🔴 END REGION: Inputs
// ==============================================================================================


// ==============================================================================================
// 🟢 REGION: Constants + Colors
// ==============================================================================================

const string PRESSURE_BIAS_HTF_MODE   = "Auto"
const string PRESSURE_BIAS_HTF_MANUAL = "60"

color COLOR_NEUTRAL_BG = color.rgb(38, 40, 46)

color BULL_1 = color.rgb(169, 211, 221)
color BULL_2 = color.rgb(134, 204, 136)
color BULL_3 = color.rgb(241, 231, 79)
color BULL_4 = color.rgb(248, 195, 48)
color BULL_5 = #fc7107

color BEAR_1 = color.rgb(248, 133, 133)
color BEAR_2 = color.red
color BEAR_3 = #c22929
color BEAR_4 = color.rgb(138, 16, 16)
color BEAR_5 = #720092

// ==============================================================================================
// 🔴 END REGION: Constants + Colors
// ==============================================================================================


// ==============================================================================================
// 🟢 REGION: Candle Pressure Color Helpers
// ==============================================================================================

f_stdBiasBg(float _buyPct, float _sellPct, float _refVol) =>
    na(_buyPct) or na(_sellPct) or na(_refVol) or _refVol <= 0 ? COLOR_NEUTRAL_BG :
     _sellPct > 50.0 ? in_standardBearColor :
     _buyPct > 50.0 ? in_standardBullColor :
     COLOR_NEUTRAL_BG

f_bsCellBg(float _buyPct, float _sellPct, float _curVol) =>
    int _buyPctI = CP.pctIntVol(_buyPct, _curVol)
    int _sellPctI = na(_sellPct) or na(_curVol) or _curVol <= 0 ? 0 : 100 - _buyPctI

    if na(_buyPct) or na(_sellPct) or na(_curVol) or _curVol <= 0
        COLOR_NEUTRAL_BG
    else if _sellPctI > 50
        _sellPctI < 60 ? BEAR_1 :
         _sellPctI < 70 ? BEAR_2 :
         _sellPctI < 80 ? BEAR_3 :
         _sellPctI < 90 ? BEAR_4 :
         BEAR_5
    else if _buyPctI <= 50
        COLOR_NEUTRAL_BG
    else if _buyPctI < 60
        BULL_1
    else if _buyPctI < 70
        BULL_2
    else if _buyPctI < 80
        BULL_3
    else if _buyPctI < 90
        BULL_4
    else
        BULL_5

f_pressureBiasAutoLen() =>
    timeframe.isseconds ? 21 :
     timeframe.isminutes and timeframe.multiplier <= 5 ? 21 :
     timeframe.isminutes and timeframe.multiplier <= 15 ? 34 :
     timeframe.isminutes and timeframe.multiplier <= 60 ? 55 :
     timeframe.isminutes ? 89 :
     timeframe.isdaily ? 21 :
     timeframe.isweekly ? 13 :
     timeframe.ismonthly ? 8 :
     34

f_pressureBiasMa(float _src, int _len, string _type) =>
    float _ema = ta.ema(_src, _len)
    float _rma = ta.rma(_src, _len)
    float _sma = ta.sma(_src, _len)

    _type == "EMA" ? _ema :
     _type == "RMA" ? _rma :
     _sma

f_pressureBiasNextTfStep() =>
    timeframe.isseconds ? "1" :
     timeframe.isminutes and timeframe.multiplier < 3 ? "3" :
     timeframe.isminutes and timeframe.multiplier < 5 ? "5" :
     timeframe.isminutes and timeframe.multiplier < 15 ? "15" :
     timeframe.isminutes and timeframe.multiplier < 30 ? "30" :
     timeframe.isminutes and timeframe.multiplier < 60 ? "60" :
     timeframe.isminutes and timeframe.multiplier < 120 ? "120" :
     timeframe.isminutes and timeframe.multiplier < 240 ? "240" :
     timeframe.isminutes and timeframe.multiplier < 480 ? "480" :
     timeframe.isminutes ? "D" :
     timeframe.isdaily ? "W" :
     timeframe.isweekly ? "M" :
     "12M"

f_pressureBiasTrailContext() =>
    int _len =
         in_pressureBiasLenMode == "Auto" ? f_pressureBiasAutoLen() : in_pressureBiasManualLen

    float _src =
         in_pressureBiasSource == "Close" ? close :
         in_pressureBiasSource == "HLC3" ? hlc3 :
         ohlc4

    f_pressureBiasMa(_src, _len, in_pressureBiasMaType)

// ==============================================================================================
// 🔴 END REGION: Candle Pressure Color Helpers
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: Label Helpers
// ==============================================================================================

f_labelSize(string _size) =>
    _size == "Tiny" ? size.tiny :
     _size == "Small" ? size.small :
     _size == "Normal" ? size.normal :
     _size == "Large" ? size.large :
     size.huge

f_bsTextColor(float _buyPct, float _sellPct, float _curVol) =>
    int _buyPctI  = CP.pctIntVol(_buyPct, _curVol)
    int _sellPctI = na(_sellPct) or na(_curVol) or _curVol <= 0 ? 0 : 100 - _buyPctI

    bool _blackText =
         not na(_buyPct) and not na(_sellPct) and not na(_curVol) and _curVol > 0 and
         _buyPctI > 50 and _sellPctI < 51

    _blackText ? #000000 : color.white

f_pressureText(float _pressure, float _buyPct, float _sellPct, float _vol) =>
    string _bs = CP.fmtBuySellSplit(_buyPct, _sellPct, _vol)
    string _p  = na(_pressure) ? "—" : CP.stripLeadingZero(str.tostring(_pressure, "#.##"))
    "" + _bs + "\n" + _p

f_syncPressureLabel(label _id, bool _show, int _x, string _text, string _ylocText, string _styleText, color _bg, color _txt, string _sizeText) =>
    label _lbl = _id

    _style =
         _styleText == "down" ? label.style_label_down :
         _styleText == "up"   ? label.style_label_up :
                                 label.style_none

    _yloc =
         _ylocText == "above" ? yloc.abovebar : yloc.belowbar

    _size =
         f_labelSize(_sizeText)

    if _show
        if na(_lbl)
            _lbl := label.new(
                 x=_x,
                 y=0,
                 text=_text,
                 xloc=xloc.bar_index,
                 yloc=_yloc,
                 style=_style,
                 color=_bg,
                 textcolor=_txt,
                 size=_size)
        else
            label.set_xy(_lbl, _x, 0)
            label.set_text(_lbl, _text)
            label.set_yloc(_lbl, _yloc)
            label.set_style(_lbl, _style)
            label.set_color(_lbl, _bg)
            label.set_textcolor(_lbl, _txt)
            label.set_size(_lbl, _size)
    else
        if not na(_lbl)
            label.delete(_lbl)
            _lbl := na

    _lbl

// ==============================================================================================
// 🔴 END REGION: Label Helpers
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: Candle Pressure Engine
// ==============================================================================================

bool showBsCandles =
     in_showBsCandles == "Show"

[pressure, buyPct, sellPct] =
     CP.candlePressureMetrics(open, high, low, close, volume)

color bsBaseColor =
     in_biasMode == "Standard" ? f_stdBiasBg(buyPct, sellPct, volume) :
     f_bsCellBg(buyPct, sellPct, volume)

color bsCandleBody =
     showBsCandles ? color.new(bsBaseColor, in_bsCandleBodyTransp) : na

color bsCandleWick =
     showBsCandles ? color.new(bsBaseColor, in_bsCandleWickTransp) : na

color bsCandleBorder =
     showBsCandles ? color.new(bsBaseColor, in_bsCandleBorderTransp) : na

// ==============================================================================================
// 🔴 END REGION: Candle Pressure Engine
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: Pressure Bias Trail
// ==============================================================================================
//
// 📌 Purpose:
//     Draws chart-timeframe and higher-timeframe rolling price-bias trails that
//     can be used with the candle-pressure overlay for extra chart context.
//
// 🧠 Behavior:
//     • The local trail is a rolling average of the selected price source.
//     • The HTF trail uses the same rolling average logic on a higher timeframe.
//     • The HTF trail is stabilized through SimpleCryptoLife's HTF sampler.
//     • Trail colors are based only on price above / below each trail.
//     • Candles still show current-bar Buy/Sell pressure.
//
// ==============================================================================================

// Local Trail
bool showPressureBiasTrail =
     in_showPressureBiasTrail == "Show"

float pressureBiasTrail =
     f_pressureBiasTrailContext()

color pressureBiasTrailColor =
     close > pressureBiasTrail ? in_pressureBiasBullColor :
     close < pressureBiasTrail ? in_pressureBiasBearColor :
     in_pressureBiasFlatColor

plot(
     showPressureBiasTrail ? pressureBiasTrail : na,
     title="Pressure Bias Trail",
     color=pressureBiasTrailColor,
     linewidth=in_pressureBiasLineWidth,
     style=plot.style_line,
     show_last=in_pressureBiasPlotLast)

// HTF Trail
bool showPressureBiasHtfTrail =
     in_showPressureBiasHtfTrail == "Show"

string pressureBiasHtf =
     PRESSURE_BIAS_HTF_MODE == "Auto" ? f_pressureBiasNextTfStep() : PRESSURE_BIAS_HTF_MANUAL

float pressureBiasHtfSecurity =
     request.security(
         syminfo.tickerid,
         pressureBiasHtf,
         f_pressureBiasTrailContext(),
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off)

float pressureBiasHtfTrail =
     SCL_HTF.f_HTF_Float(
         _HTF=pressureBiasHtf,
         _source=pressureBiasHtfSecurity,
         _arrayHistory=2,
         _HTF_offset=0,
         _useLiveDataOnChartTF=true)

color pressureBiasHtfTrailColor =
     close > pressureBiasHtfTrail ? in_pressureBiasHtfBullColor :
     close < pressureBiasHtfTrail ? in_pressureBiasHtfBearColor :
     in_pressureBiasFlatColor

plot(
     showPressureBiasHtfTrail ? pressureBiasHtfTrail : na,
     title="HTF Pressure Bias Trail",
     color=pressureBiasHtfTrailColor,
     linewidth=in_pressureBiasHtfLineWidth,
     style=plot.style_line,
     show_last=in_pressureBiasHtfPlotLast)

// ==============================================================================================
// 🔴 END REGION: Pressure Bias Trail
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: Buy/Sell Candle Overlay
// ==============================================================================================

plotcandle(
     open=showBsCandles ? open : na,
     high=showBsCandles ? high : na,
     low=showBsCandles ? low : na,
     close=showBsCandles ? close : na,
     title="Buy/Sell Pressure Candles",
     color=bsCandleBody,
     wickcolor=bsCandleWick,
     bordercolor=bsCandleBorder,
     show_last=in_bsCandleLastBars)

// ==============================================================================================
// 🔴 END REGION: Buy/Sell Candle Overlay
// ==============================================================================================


// ==============================================================================================
// 🟢 REGION: Follow Lines
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: Bar-to-Bar Close Follow Line
// ──────────────────────────────────────────────
//
// Lightweight series plot. This is cheaper than creating line objects on every bar.

plot(
     in_showBarToBarLine == "Show" ? close : na,
     title="Bar-to-Bar Close Follow Line",
     color=bsBaseColor,
     linewidth=in_barToBarLineWidth,
     show_last=in_barToBarLastBars)

// ──────────────────────────────────────────────
// 🟦 Subregion: Last-Bar Index Follow Line
// ──────────────────────────────────────────────
//
// One object only. Updates on the last bar using bar_index coordinates.

var line indexFollowLine = na

if barstate.islast
    bool _showIndexLine = in_showIndexLine == "Show"
    int _x1 = bar_index - in_indexLineLeftBars
    int _x2 = bar_index + in_indexLineRightBars

    if _showIndexLine
        if na(indexFollowLine)
            indexFollowLine := line.new(
                 x1=_x1,
                 y1=close,
                 x2=_x2,
                 y2=close,
                 xloc=xloc.bar_index,
                 extend=extend.none,
                 color=bsBaseColor,
                 width=in_indexLineWidth)
        else
            line.set_xy1(indexFollowLine, _x1, close)
            line.set_xy2(indexFollowLine, _x2, close)
            line.set_color(indexFollowLine, bsBaseColor)
            line.set_width(indexFollowLine, in_indexLineWidth)
    else
        if not na(indexFollowLine)
            line.delete(indexFollowLine)
            indexFollowLine := na

// ==============================================================================================
// 🔴 END REGION: Follow Lines
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: Buy/Sell Pressure Label
// ==============================================================================================

var label pressureLabel = na

bool pressureBullish =
     not na(pressure) and pressure >= 0.0

string pressureLabelYloc =
     in_pressureLabelPos == "Above" ? "above" :
     in_pressureLabelPos == "Below" ? "below" :
     pressureBullish ? "above" : "below"

string pressureLabelStyle =
     pressureLabelYloc == "above" ? "down" : "up"

string pressureLabelText =
     f_pressureText(pressure, buyPct, sellPct, volume)

color pressureLabelBg =
     bsBaseColor

color pressureLabelTxt =
     f_bsTextColor(buyPct, sellPct, volume)

bool showPressureLabel =
     in_showPressureLabel == "Show"

if barstate.islast
    pressureLabel := f_syncPressureLabel(
         pressureLabel,
         showPressureLabel,
         bar_index,
         pressureLabelText,
         pressureLabelYloc,
         pressureLabelStyle,
         pressureLabelBg,
         pressureLabelTxt,
         in_pressureLabelSize)

// ==============================================================================================
// 🔴 END REGION: Buy/Sell Pressure Label
// ==============================================================================================
````

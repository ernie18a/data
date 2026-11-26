# RSI Trend Dashboard + SMMA Channel Overlay

- url: https://www.tradingview.com/script/MuHUGJ8q-RSI-Trend-Dashboard-SMMA-Channel-Overlay/
- type: indicator
- pine_id: PUB;52d98abad4e94d2395e47731a4b7bc34
- version: 1.0

## Description

At its core, this script is an RSI trend framework designed to organize momentum into a compact dashboard that is easy to read at a glance, while also extending that same logic back onto the main chart through an optional SMMA-style channel overlay. Instead of treating RSI as just a single line crossing fixed levels, this script breaks it into a layered structure: current RSI state, higher-timeframe comparison, fast and slow RSI average relationships, and a summarized fast-vs-slow regime table view. The goal is not simply to show whether RSI is high or low but to create a cleaner way to read momentum alignment, trend agreement, and chart-side context from one unified engine.

The foundation of the script is the 5-row RSI trend strip. That strip is built to answer a practical set of questions quickly:
Is RSI in a bullish, bearish, or neutral zone?
Is chart RSI above or below its higher-timeframe RSI reference?
Is RSI above or below its fast average?
Is RSI above or below its slow average?
And is the fast average currently above or below the slow average?
That matters because momentum is often easier to interpret as a stack of relationships instead of as one isolated value. A single RSI print can be helpful, but RSI in relation to HTF RSI, fast structure, and slow structure often gives a better read on whether momentum is strengthening, weakening, or starting to rotate.

The added features here are not meant to feel bolted on. They are different ways of reading the same momentum structure. In this script, that includes:
➖ a 5-row trend strip
➖ a stabilized higher-timeframe RSI comparison
➖ fast and slow RSI average relation rows
➖ a fast-vs-slow summary row
➖ a compact dashboard table with current values, bar-to-bar deltas, and slope arrows
➖ an optional RSI-colored price candle overlay
➖ an optional Trend SMMA Channel Overlay on the main chart
➖ an optional smoothed OHLC4 price-average line used to color the channel
➖ optional bullish and bearish triangle markers derived from the overlay engine

The dashboard table is there to keep the same engine readable in a more precise format. The pane gives the fast visual impression. The table gives the actual current readings: rounded values, simple deltas, and short slope arrows so the trader can see not only where RSI and its companion series are, but whether they are currently improving, fading, or flattening. I like that combination because it keeps the script visual first, but still lets you confirm the details without needing to inspect each series manually.

The higher-timeframe layer is an important part of the script. Rather than leaving RSI fully isolated to the local chart, this indicator compares the chart RSI against the next logical higher timeframe so traders can quickly judge whether local momentum is aligned with broader context or starting to separate from it. The script uses SimpleCryptoLife’s HighTimeframeSampling library to stabilize that HTF reference series, which helps keep the higher-timeframe comparison cleaner and more reliable in live use.

The chart-side Trend SMMA Channel Overlay serves a different purpose. While the pane organizes RSI structure, the overlay projects a smoother trend context directly onto price using Wilder-style smoothed high and low boundaries, along with an optional smoothed OHLC4 price-average line. That creates a second way to read the same market: the pane shows internal momentum relationships, while the chart overlay helps show whether smoothed price-average behavior is pressing above the channel, below it, or back inside it. In other words, the pane gives the momentum-state view and the chart gives the price-structure view.

This script also uses auto timeframe length resolvers for the main chart-side overlay tools, which I think makes it more practical across different chart speeds. Instead of forcing users to constantly retune multiple lengths when moving from lower timeframes to higher ones, the script can automatically resolve separate preset lengths for the Trend SMMA channel, the OHLC4 price-average line, and the bullish/bearish triangle engine. Manual controls are still available, but the default design is meant to stay more adaptive and chart-friendly out of the box.

A practical way to think about it:

➡️ If RSI is strong, above HTF RSI, and above both fast and slow averages, momentum is generally aligned in the bullish direction.

➡️ If RSI is weak, below HTF RSI, and below both fast and slow averages, momentum is generally aligned in the bearish direction.

➡️ If the rows begin to disagree with each other, that often signals transition, cooling, or a market that is no longer moving with the same clean momentum structure.

➡️ If the Trend SMMA overlay is also pushing outside its channel in the same direction, that can help reinforce what the pane is already suggesting.

➡️ If the pane and chart overlay begin to disagree, that can be a useful sign that trend strength may be losing alignment.

This is not meant to predict reversals by itself, and I would not treat it as a stand-alone signal machine. The way I use it is more practical:
➖ to judge whether RSI momentum is aligned or mixed
➖ to compare local RSI behavior against higher-timeframe context
➖ to see whether fast and slow momentum structure are still confirming each other
➖ to keep pane-space momentum and chart-space trend context visually connected
That overall framing is very similar to the way my previous Chandelier and Heikin Ashi publishings were written: one central engine, then multiple companion layers that help interpret the same underlying structure rather than replacing it with unrelated tools.

Bar Replay is especially useful here. Watching the strip build one bar at a time makes it much easier to see when RSI shifts from neutral into directional territory, when chart RSI moves above or below its HTF reference, when the fast/slow relationship changes, and how the chart-side SMMA overlay responds as price-average behavior moves through the channel. Scripts like this are often easier to understand dynamically than from a single static screenshot.

Like most momentum tools, this works best with confluence. I would not use it in isolation. Structure, volume, support and resistance, price action, market regime, and higher-timeframe context all still matter. The value of this script is not that it replaces those tools. The value is that it gives RSI a more organized dashboard-style expression while also extending that same read onto the main chart through a cleaner trend overlay.

Credit where it’s due: this script uses SimpleCryptoLife’s HighTimeframeSampling library for the stabilized HTF reference, and portions of the Trend SMMA channel, OHLC4 price-average interaction, and bullish/bearish triangle logic were adapted from concepts used in SimpleCryptoLife’s open-source Price Action Trend work. I always want that lineage to be clear, especially when chart-side concepts have been reworked into a different script and broader dashboard framework.

https://www.tradingview.com/x/f8SUwZbU/

https://www.tradingview.com/x/Rg5FNhTh/

https://www.tradingview.com/x/bnDcMmEf/

## Source Code

````pine
// ==============================================================================
//  RSI Trend Dashboard + SMMA Channel Overlay
//  Author: © 𝕄𝕐ℕ𝔸𝕄𝔼𝕀𝕊𝔹ℝ𝔸ℕ𝔻𝕆ℕ
//  License: Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ==============================================================================
//
//  Reference / Attribution:
//  Portions of the Trend SMMA channel, the OHLC4 price-average interaction,
//  and the bullish / bearish triangle engine in this script were adapted from
//  concepts used in SimpleCryptoLife's open-source "Price Action Trend" script: https://www.tradingview.com/v/ll7Wabyv/
//
//  In this version, those ideas were integrated into this script's own
//  AUTO timeframe length-resolver framework, so the channel, OHLC4 line,
//  and triangle logic can automatically scale across chart speeds instead
//  of relying only on fixed manual lengths.
//
//  This script also uses SimpleCryptoLife's HighTimeframeSampling library
//  for the stabilized HTF RSI reference series.
//
//
//@version=6
indicator("RSI Trend Dashboard + SMMA Channel Overlay", "RSI Trend", overlay=false, calc_bars_count = 500)

// Overview:
//     RSI Trend Dashboard is a compact momentum dashboard built around RSI,
//     HTF RSI comparison, fast/slow RSI average relationships, and an optional
//     Wilder-style smoothed channel overlay on price.
//
//     The script includes:
//     • a 5-row RSI trend strip
//     • an HTF RSI comparison row
//     • fast and slow RSI average relation rows
//     • a fast-vs-slow summary row
//     • a dashboard table with values, deltas, and slope arrows
//     • an optional RSI-driven price candle overlay
//     • an optional Trend SMMA Channel Overlay colored by a smoothed OHLC4 price average
//
// Notes:
//     • Built for quick visual interpretation of RSI trend, HTF agreement,
//       fast/slow momentum structure, and price-channel context.
//     • Designed to stay compact, readable, and chart-friendly.
//

// ==============================================================================================
// 🟢 REGION: Imports
// ==============================================================================================
//
// Purpose:
//     Imports external libraries used by this script.
//
// Notes:
//     • HighTimeframeSampling is used to stabilize the HTF RSI reference series.
//
import SimpleCryptoLife/HighTimeframeSampling/4 as SCL_HTF

// ==============================================================================================
// 🔴 END REGION: Imports
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: Group Names
// ==============================================================================================

const string G_ENGINE       = "Dashboard Engine"
const string G_VISUALS      = "Dashboard Visuals"
const string G_TABLE        = "Dashboard Table"
const string G_RSI_TREND    = "Price Candle Overlay"
const string G_SMMA_CHANNEL = "Trend SMMA Channel Overlay"

// ==============================================================================================
// 🔴 END REGION: Group Names
// ==============================================================================================

/// ==============================================================================================
// 🟢 REGION: Tooltip Strings
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: Trend Strip Engine
// ──────────────────────────────────────────────
const string TT_RSI_LEN =
     "Controls the RSI lookback length used throughout the dashboard."

const string TT_AVG_TYPE =
     "Controls whether the fast and slow RSI averages use SMA or EMA.\n\n" +
     "This affects:\n" +
     "• the fast relation row\n" +
     "• the slow relation row\n" +
     "• the fast vs slow row\n" +
     "• the matching dashboard table rows"

const string TT_FAST_LEN =
     "Controls the length used by the fast RSI average."

const string TT_SLOW_LEN =
     "Controls the length used by the slow RSI average."

const string TT_RSI_NEUTRAL_UPPER =
     "Sets the upper edge of the RSI neutral zone.\n\n" +
     "When RSI is between the lower and upper neutral thresholds, the RSI row is colored white."

const string TT_RSI_NEUTRAL_LOWER =
     "Sets the lower edge of the RSI neutral zone.\n\n" +
     "When RSI is between the lower and upper neutral thresholds, the RSI row is colored white."

const string TT_STRIP_MODE =
     "Controls whether the 5-row trend strip is displayed.\n\n" +
     "• Show:\n" +
     "  Displays the RSI row, HTF RSI relation row, fast relation row, slow relation row, and fast vs slow row.\n\n" +
     "• Hide:\n" +
     "  Hides all five trend-strip rows."

const string TT_LAST_N =
     "Controls how many recent bars are shown in the 5-row trend strip."

// ──────────────────────────────────────────────
// 🟦 Subregion: Trend Strip Visuals
// ──────────────────────────────────────────────
const string TT_FAST_ROW_COLOR_MODE =
     "Controls how the HTF RSI row, fast relation row, slow relation row, and fast vs slow row are colored.\n\n" +
     "• Bull/Bear:\n" +
     "  Uses the selected bullish and bearish colors with no duration-based shading.\n\n" +
     "• Gradient:\n" +
     "  Keeps the same bullish or bearish direction, but deepens the color as the active relationship lasts longer."

const string TT_TREND_UP_COLOR =
     "Base color used when a relation row is in a bullish state."

const string TT_TREND_DOWN_COLOR =
     "Base color used when a relation row is in a bearish state."

const string TT_ROW_HEIGHT =
     "Controls the thickness of each trend-strip row.\n\n" +
     "Higher values make each row taller."

// ──────────────────────────────────────────────
// 🟦 Subregion: Dashboard Table
// ──────────────────────────────────────────────
const string TT_TABLE_MODE =
     "Controls whether the dashboard table is displayed."

const string TT_TABLE_POSITION =
     "Controls where the dashboard table is anchored in the pane."

const string TT_TABLE_TEXT_SIZE =
     "Controls the text size used in the dashboard table."

const string TT_TABLE_ROW_HEIGHT =
     "Controls the visual height of each dashboard table row."

const string TT_TABLE_VALUE_COLS_WIDTH =
     "Controls the width of the 2nd and 3rd dashboard table columns.\n\n" +
     "This affects both:\n" +
     "• the current value column\n" +
     "• the delta column"

const string TT_TABLE_FRAME_COLOR =
     "Controls the color used for the dashboard table frame and borders."

const string TT_TABLE_FRAME_TRANSP =
     "Controls the transparency used for the dashboard table frame and borders."

const string TT_AVG_SLOPE_LEN =
     "Controls the linear regression lookback used for the slope arrows shown next to the RSI, fast average, slow average, and HTF RSI values in the dashboard table.\n\n" +
     "• Lower values:\n" +
     "  respond faster to slope changes\n" +
     "  but can flip more often\n\n" +
     "• Higher values:\n" +
     "  smooth the slope more\n" +
     "  but react more slowly\n\n" +
     "Tip:\n" +
     "• 2 = fastest response\n" +
     "• 3 = slightly smoother"

const string TT_AVG_SLOPE_FLAT =
     "Controls the flat threshold used by the dashboard table slope arrows.\n\n" +
     "If the linear regression slope stays inside this threshold, the reading is treated as flat.\n\n" +
     "• Lower values:\n" +
     "  make arrows switch more quickly between up and down\n\n" +
     "• Higher values:\n" +
     "  make flat readings more common"

// ──────────────────────────────────────────────
// 🟦 Subregion: Price Candle Overlay
// ──────────────────────────────────────────────
const string TT_RSI_TREND_OVERLAY_MODE =
     "Colors price candles using the RSI color engine.\n\n" +
     "• PlotCandles:\n" +
     "  Draws a full candle overlay using separate body, wick, and border transparency controls.\n\n" +
     "• Hide:\n" +
     "  Disables the price candle overlay."

const string TT_RSI_TREND_BODY_TRANSP =
     "Controls the transparency used by the price candle body."

const string TT_RSI_TREND_WICK_TRANSP =
     "Controls the transparency used by the price candle wick."

const string TT_RSI_TREND_BORDER_TRANSP =
     "Controls the transparency used by the price candle border."

// ──────────────────────────────────────────────
// 🟦 Subregion: Trend SMMA Channel Overlay
// ──────────────────────────────────────────────
const string TT_SMMA_CHANNEL_MODE =
     "Controls whether the Trend SMMA Channel Overlay is shown on the main chart.\n\n" +
     "• Show:\n" +
     "  Displays the SMMA high/low channel, its fill, and the optional price-average line.\n\n" +
     "• Hide:\n" +
     "  Disables the full overlay."

const string TT_SMMA_CHANNEL_LEN =
     "Controls the manual smoothing length used to build the channel boundaries from the chart's high and low price series.\n\n" +
     "This input is only used when Overlay Length Mode = Manual.\n\n" +
     "In this script, the upper boundary is a Wilder-style smoothed average of highs, and the lower boundary is a Wilder-style smoothed average of lows.\n\n" +
     "Suggested manual default:\n" +
     "• 34 = balanced middle-tier baseline"

const string TT_SMMA_CHANNEL_SHOW_PA =
     "Shows or hides the smoothed OHLC4 price-average line used by the channel color logic.\n\n" +
     "OHLC4 = (open + high + low + close) / 4.\n\n" +
     "When Overlay Length Mode = Auto, the Price Average Length resolves by timeframe as follows:\n" +
     "• Seconds to 5m = 15\n" +
     "• >5m to <30m = 10\n" +
     "• 30m to <4h = 6\n" +
     "• 4h to 1D = 4\n" +
     "• >1D and higher = 3\n\n" +
     "When Overlay Length Mode = Manual, the line uses the Manual Price Average Length input below."

const string TT_SMMA_CHANNEL_PA_LEN =
     "Controls the manual smoothing length used by the OHLC4 price-average line.\n\n" +
     "This input is only used when Overlay Length Mode = Manual.\n\n" +
     "OHLC4 = (open + high + low + close) / 4.\n\n" +
     "Suggested manual default:\n" +
     "• 13 = balanced middle-tier baseline"

const string TT_SMMA_CHANNEL_PA_TYPE =
     "Controls the smoothing type used by the OHLC4 price-average line.\n\n" +
     "The line always starts from OHLC4, then applies the selected smoothing method.\n\n" +
     "• SMA:\n" +
     "  A simple average of OHLC4 over the selected length\n\n" +
     "• EMA:\n" +
     "  A faster-reacting average that gives more weight to recent bars\n\n" +
     "• RMA:\n" +
     "  Wilder-style smoothing of OHLC4\n" +
     "  This is the same smoothing family used to build the channel boundaries in this script,\n" +
     "  so it usually gives the closest visual match to the channel's behavior"

const string TT_SMMA_CHANNEL_LINE_WIDTH =
     "Controls the line width used by the channel high and low boundaries."

const string TT_SMMA_CHANNEL_FILL_TRANSP =
     "Controls the transparency used by the channel fill.\n\n" +
     "Lower values make the fill more visible.\n" +
     "Higher values make it more subtle."

const string TT_SMMA_CHANNEL_NEUTRAL_FILL_TRANSP =
     "Controls the transparency used only when the Trend SMMA channel is neutral.\n\n" +
     "Neutral means the smoothed OHLC4 price-average line is inside the channel.\n\n" +
     "Lower values make the neutral fill more visible.\n" +
     "Higher values make the neutral fill more subtle."

const string TT_SMMA_CHANNEL_OBOS_MODE =
     "Controls whether the Trend SMMA bullish / bearish triangles are shown on the main chart.\n\n" +
     "These markers are derived from a dynamic Price Action-style overbought / oversold engine built from a short Wilder-style channel and adaptive pivot levels.\n\n" +
     "• Overbought condition → bullish green triangle below price\n" +
     "• Oversold condition → bearish red triangle above price"

const string TT_SMMA_CHANNEL_OBOS_LEN =
     "Controls the manual short Wilder-style channel lookback used to build the raw overbought / oversold engine.\n\n" +
     "This input is only used when Triangle Length Mode = Manual.\n\n" +
     "This is the first stage of the triangle logic. It shapes the underlying OB/OS signal before the adaptive trigger levels are calculated.\n\n" +
     "Suggested manual default:\n" +
     "• 5 = balanced middle-tier baseline"

const string TT_SMMA_CHANNEL_OBOS_ADAPT_LEN =
     "Controls the manual adaptive smoothing length used for the dynamic overbought / oversold trigger levels.\n\n" +
     "This input is only used when Triangle Length Mode = Manual.\n\n" +
     "This is the second stage of the triangle logic. It smooths the Williams-style pivot highs and lows detected from the raw OB/OS engine into the final trigger levels.\n\n" +
     "Suggested manual default:\n" +
     "• 12 = balanced middle-tier baseline"

const string TT_SMMA_CHANNEL_PA_LAST_N =
     "Controls how many recent bars are shown for the OHLC4 price-average line on the main chart.\n\n" +
     "Lower values keep the line focused on recent structure.\n" +
     "Higher values keep more of the line visible."

const string TT_SMMA_CHANNEL_OBOS_LENGTH_MODE =
     "Controls whether the bullish / bearish triangle engine uses Auto timeframe presets or the manual input pair below.\n\n" +
     "• Auto:\n" +
     "  Uses one of five preset pairs based on the chart timeframe:\n" +
     "  - Seconds to 5m = 8 / 18\n" +
     "  - >5m to <30m = 6 / 14\n" +
     "  - 30m to <4h = 5 / 12\n" +
     "  - 4h to 1D = 4 / 10\n" +
     "  - >1D and higher = 3 / 8\n\n" +
     "• Manual:\n" +
     "  Uses the Manual OB/OS Channel Lookback and Manual OB/OS Level Adaptive Length inputs below."

const string TT_SMMA_OVERLAY_LENGTH_MODE =
     "Controls whether the Trend SMMA channel and OHLC4 price-average line use Auto timeframe presets or the manual inputs below.\n\n" +
     "• Auto:\n" +
     "  Uses one shared timeframe bucket, while resolving separate lengths for the Channel and the Price Average line.\n\n" +
     "  Channel Length by timeframe:\n" +
     "  - Seconds to 5m = 55\n" +
     "  - >5m to <30m = 34\n" +
     "  - 30m to <4h = 21\n" +
     "  - 4h to 1D = 13\n" +
     "  - >1D and higher = 8\n\n" +
     "  Price Average Length by timeframe:\n" +
     "  - Seconds to 5m = 15\n" +
     "  - >5m to <30m = 10\n" +
     "  - 30m to <4h = 6\n" +
     "  - 4h to 1D = 4\n" +
     "  - >1D and higher = 3\n\n" +
     "• Manual:\n" +
     "  Uses the manual Channel Length and manual Price Average Length inputs below."
     
// ==============================================================================================
// 🔴 END REGION: Tooltip Strings
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: Helpers
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: Moving Average Helpers
// ──────────────────────────────────────────────
// Purpose:
//     Resolves the selected fast / slow RSI average type.
//
f_avgSeries(float _src, int _len, string _type) =>
    float _ema =
         ta.ema(_src, _len)

    float _sma =
         ta.sma(_src, _len)

    _type == "EMA" ? _ema : _sma

// ──────────────────────────────────────────────
// 🟦 Subregion: Slope Arrow Helpers
// ──────────────────────────────────────────────
// Purpose:
//     Handles linear-regression slope direction used by the dashboard table.
//
f_slopeArrow(float _sl, float _eps) =>
    na(_sl) ? "" :
     _sl > _eps  ? " ↗" :
     _sl < -_eps ? " ↘" :
                   " •"

f_lrSlope(float _src, int _len) =>
    float _lr0 =
         ta.linreg(_src, math.max(_len, 2), 0)

    float _lr1 =
         ta.linreg(_src, math.max(_len, 2), 1)

    _lr0 - _lr1

// ──────────────────────────────────────────────
// 🟦 Subregion: Color Helpers
// ──────────────────────────────────────────────
// Purpose:
//     Builds the RSI band colors, duration-gradient row colors, and contrast-safe text colors.
//
method t(color _c, int _tr) =>
    color.new(_c, _tr)

f_rsiIsNeutral(float _rsi, float _neutralUpper, float _neutralLower) =>
    not na(_rsi) and  
     _rsi < _neutralUpper and 
     _rsi > _neutralLower

f_contrastText(color _bg) =>
    float _r =
         color.r(_bg)

    float _g =
         color.g(_bg)

    float _b =
         color.b(_bg)

    float _lum =
         (0.299 * _r) + (0.587 * _g) + (0.114 * _b)

    _lum > 140 ? #000000 : color.white

f_scaleColor(color _c, float _factor) =>
    color.rgb(
         int(math.round(math.min(math.max(color.r(_c) * _factor, 0), 255))),
         int(math.round(math.min(math.max(color.g(_c) * _factor, 0), 255))),
         int(math.round(math.min(math.max(color.b(_c) * _factor, 0), 255))))

f_durationGradientBaseColor(int _bars, bool _bull, bool _bear, color _bullColor, color _bearColor) =>
    float _barsClamped =
         math.min(math.max(_bars, 1), 21)

    _bull
         ? color.from_gradient(
             _barsClamped,
             1,
             21,
             f_scaleColor(_bullColor, 0.40),
             _bullColor)
         : _bear
         ? color.from_gradient(
             _barsClamped,
             1,
             21,
             f_scaleColor(_bearColor, 0.40),
             _bearColor)
         : color.gray

f_rsiTrendLevelColor(float _rsi, int _tr, float _neutralUpper, float _neutralLower) =>
    if na(_rsi)
        color.new(color.gray, 85)
    else
        bool _neutral =
             f_rsiIsNeutral(_rsi, _neutralUpper, _neutralLower)

        _neutral ? color.white.t(_tr) :
         _rsi >= 90 and _rsi <= 100 ? color.rgb(255, 102, 0).t(_tr) :
         _rsi >= 80 and _rsi < 90 ? color.rgb(255, 251, 0).t(_tr) :
         _rsi >= 70 and _rsi < 80 ? #37af00.t(_tr) :
         _rsi >= 60 and _rsi < 70 ? color.teal.t(_tr) :
         _rsi >= 50 and _rsi < 60 ? color.aqua.t(_tr) :
         _rsi < 50 and _rsi >= 40 ? color.rgb(95, 95, 95).t(_tr) :
         _rsi < 40 and _rsi >= 30 ? color.rgb(255, 101, 101).t(_tr) :
         _rsi < 30 and _rsi >= 20 ? #ec0000.t(_tr) :
         _rsi < 20 and _rsi >= 10 ? color.rgb(220, 5, 248).t(_tr) :
         _rsi < 10 and _rsi >= 0 ? #8700b1.t(_tr) :
         color.gray

f_rsiRowTextColor(float _rsi, float _neutralUpper, float _neutralLower) =>
    if na(_rsi)
        color.white
    else
        bool _neutral =
             f_rsiIsNeutral(_rsi, _neutralUpper, _neutralLower)

        _neutral ? #000000 :
         _rsi < 50 ? color.white :
         #000000

// ──────────────────────────────────────────────
// 🟦 Subregion: Text Helpers
// ──────────────────────────────────────────────
// Purpose:
//     Formats signed values for the dashboard table.
//
f_signedText(float _x) =>
    na(_x) ? "na" : (_x > 0 ? "+" : "") + str.tostring(_x, "#.##")

// ──────────────────────────────────────────────
// 🟦 Subregion: UI Mapping Helpers
// ──────────────────────────────────────────────
// Purpose:
//     Maps user-facing size and position strings into Pine enums.
//
f_getTextSize(string _size) =>
    switch _size
        "Tiny"  => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge"  => size.huge
        => size.normal

f_getTablePosition(string _pos) =>
    switch _pos
        "Top Left"      => position.top_left
        "Top Right"     => position.top_right
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Right"  => position.bottom_right
        => position.top_right

// ──────────────────────────────────────────────
// 🟦 Subregion: Higher-Timeframe Helpers
// ──────────────────────────────────────────────
// Purpose:
//     Resolves the higher timeframe used by the HTF RSI row.
//
f_getNextTf() =>
    string next_tf = ""
    float mult = timeframe.multiplier

    if timeframe.isseconds
        next_tf :=
             timeframe.period == "1S"  ? "5S"  :
             timeframe.period == "5S"  ? "10S" :
             timeframe.period == "10S" ? "15S" :
             timeframe.period == "15S" ? "30S" :
             timeframe.period == "30S" ? "45S" :
             timeframe.period == "45S" ? "1"   : "1"

    else if timeframe.isminutes
        next_tf :=
             mult <= 1   ? "3"   :
             mult <= 2   ? "4"   :
             mult <= 3   ? "5"   :
             mult <= 5   ? "10"  :
             mult <= 10  ? "15"  :
             mult <= 15  ? "30"  :
             mult <= 30  ? "60"  :
             mult <= 60  ? "120" :
             mult <= 120 ? "240" :
             mult <= 240 ? "480" : "D"

    else if timeframe.isdaily
        next_tf := "1W"
    else if timeframe.isweekly
        next_tf := "2W"
    else if timeframe.ismonthly
        next_tf := "2M"
    else
        next_tf := "1D"

    next_tf

// ==============================================================================================
// 🔴 END REGION: Helpers
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: Inputs
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: Pane Visibility
// ──────────────────────────────────────────────
// Purpose:
//     Controls whether the pane is shown and how many recent bars it plots.
//
string in_stripMode = input.string(
     defval="Show",
     title="5-Row Trend Strip",
     options=["Show", "Hide"],
     group=G_ENGINE,
     tooltip=TT_STRIP_MODE)

int in_stripLastN = input.int(
     defval=55,
     minval=1,
     maxval=5000,
     title=" ↳ Plot Last N Bars",
     group=G_ENGINE,
     tooltip=TT_LAST_N)

// ──────────────────────────────────────────────
// 🟦 Subregion: RSI Engine
// ──────────────────────────────────────────────
// Purpose:
//     Controls the RSI source engine used by the pane and table.
//
int in_rsiLen = input.int(
     defval=14,
     minval=1,
     title="RSI Length",
     group=G_ENGINE,
     tooltip=TT_RSI_LEN)

float in_rsiNeutralUpper = input.float(
     defval=51.5,
     minval=50.0,
     maxval=55.0,
     step=0.1,
     title=" ↳ Upper Neutral Threshold",
     group=G_ENGINE,
     tooltip=TT_RSI_NEUTRAL_UPPER)

float in_rsiNeutralLower = input.float(
     defval=48.5,
     minval=45.0,
     maxval=50.0,
     step=0.1,
     title=" ↳ Lower Neutral Threshold",
     group=G_ENGINE,
     tooltip=TT_RSI_NEUTRAL_LOWER)

// ──────────────────────────────────────────
// 🟦 Subregion: Fast / Slow Average Engine
// ──────────────────────────────────────────
// Purpose:
//     Controls the average type and lengths used by the fast / slow rows.
//
string in_avgType = input.string(
     defval="SMA",
     title="Fast / Slow RSI Average Type",
     options=["SMA", "EMA"],
     group=G_ENGINE,
     tooltip=TT_AVG_TYPE)

int in_fastLen = input.int(
     defval=20,
     minval=1,
     title=" ↳ Fast Average Length",
     group=G_ENGINE,
     tooltip=TT_FAST_LEN)

int in_slowLen = input.int(
     defval=50,
     minval=1,
     title=" ↳ Slow Average Length",
     group=G_ENGINE,
     tooltip=TT_SLOW_LEN)

// ──────────────────────────────────────────────
// 🟦 Subregion: Trend Strip Visuals
// ──────────────────────────────────────────────
float in_rowHeight = input.float(
     defval=0.70,
     minval=0.10,
     maxval=1.0,
     step=0.01,
     title="Row Height",
     group=G_VISUALS,
     tooltip=TT_ROW_HEIGHT)

// ──────────────────────────────────────────────
// 🟦 Subregion: Fast / Slow Average Colors
// ──────────────────────────────────────────────
string in_fastRowColorMode = input.string(
     defval="Gradient",
     title="Row Color Mode",
     options=["Bull/Bear", "Gradient"],
     group=G_VISUALS,
     tooltip=TT_FAST_ROW_COLOR_MODE)

color in_trendUpColor = input.color(
     defval=color.aqua,
     title="Trend Up Color",
     group=G_VISUALS,
     tooltip=TT_TREND_UP_COLOR)

color in_trendDownColor = input.color(
     defval=color.rgb(255, 101, 101),
     title="Trend Down Color",
     group=G_VISUALS,
     tooltip=TT_TREND_DOWN_COLOR)

/// ──────────────────────────────────────────────
// 🟦 Subregion: Table
// ──────────────────────────────────────────────
string in_tableMode = input.string(
     defval="Show",
     title="Dashboard Table",
     options=["Show", "Hide"],
     group=G_TABLE,
     tooltip=TT_TABLE_MODE)

string in_tablePosition = input.string(
     defval="Middle Right",
     title=" ↳ Position",
     options=["Top Right", "Middle Right", "Top Left", "Bottom Right", "Bottom Left"],
     group=G_TABLE,
     tooltip=TT_TABLE_POSITION)

string in_tableTextSize = input.string(
     defval="Normal",
     title=" ↳ Text Size",
     options=["Tiny", "Small", "Normal", "Large", "Huge"],
     group=G_TABLE,
     tooltip=TT_TABLE_TEXT_SIZE)

int in_tableRowHeight = input.int(
     defval=15,
     minval=8,
     maxval=40,
     title=" ↳ Row Height",
     group=G_TABLE,
     tooltip=TT_TABLE_ROW_HEIGHT)

int in_tableValueColsWidth = input.int(
     defval=3,
     minval=0,
     maxval=100,
     title=" ↳ 2nd / 3rd Column Width",
     group=G_TABLE,
     tooltip=TT_TABLE_VALUE_COLS_WIDTH)

int in_avgSlopeLen = input.int(
     defval=2,
     minval=2,
     title="Average Arrow Slope Length",
     group=G_TABLE,
     tooltip=TT_AVG_SLOPE_LEN)

float in_avgSlopeFlat = input.float(
     defval=0.02,
     minval=0.0,
     step=0.01,
     title=" ↳ Flat Threshold",
     group=G_TABLE,
     tooltip=TT_AVG_SLOPE_FLAT)

color in_tableFrameColor = input.color(
     defval=#000000,
     title="Table Frame",
     group=G_TABLE,
     tooltip=TT_TABLE_FRAME_COLOR)

int in_tableFrameTransp = input.int(
     defval=60,
     minval=0,
     maxval=100,
     title=" ↳ Transparency",
     group=G_TABLE,
     tooltip=TT_TABLE_FRAME_TRANSP)

// ──────────────────────────────────────────────
// 🟦 Subregion: RSI Trend Candle Overlay
// ──────────────────────────────────────────────
string in_rsiCandleOverlayMode = input.string(
     defval="PlotCandles",
     title="Price Candle Overlay",
     options=["PlotCandles", "Hide"],
     group=G_RSI_TREND,
     tooltip=TT_RSI_TREND_OVERLAY_MODE)

int in_rsiTrendBodyTransp = input.int(
     defval=70,
     minval=0,
     maxval=100,
     title="Body Transparency",
     group=G_RSI_TREND,
     tooltip=TT_RSI_TREND_BODY_TRANSP)

int in_rsiTrendWickTransp = input.int(
     defval=10,
     minval=0,
     maxval=100,
     title="Wick Transparency",
     group=G_RSI_TREND,
     tooltip=TT_RSI_TREND_WICK_TRANSP)

int in_rsiTrendBorderTransp = input.int(
     defval=10,
     minval=0,
     maxval=100,
     title="Border Transparency",
     group=G_RSI_TREND,
     tooltip=TT_RSI_TREND_BORDER_TRANSP)

// ──────────────────────────────────────────────
// 🟦 Subregion: Trend SMMA Channel Overlay
// ──────────────────────────────────────────────
// Purpose:
//     Controls whether the Trend SMMA channel is shown and whether the channel
//     and price-average line use Auto timeframe presets or manual lengths.
//
// Notes:
//     • Overlay Length Mode controls the shared auto/manual length behavior for:
//         - Channel Length
//         - Price Average Length
//     • Channel Line Width controls the visibility of the channel boundaries.
//     • Channel Fill Transparency controls how subtle or prominent the filled band appears.
//
string in_smmaChannelMode = input.string(
     defval="Show",
     title="Trend SMMA Channel Overlay",
     options=["Show", "Hide"],
     group=G_SMMA_CHANNEL,
     tooltip=TT_SMMA_CHANNEL_MODE)

string in_smmaOverlayLengthMode = input.string(
     defval="Auto",
     title=" ↳ Overlay Length Mode",
     options=["Auto", "Manual"],
     group=G_SMMA_CHANNEL,
     tooltip=TT_SMMA_OVERLAY_LENGTH_MODE)

int in_smmaChannelLen = input.int(
     defval=34,
     minval=1,
     title="  ↳ Manual Channel Length",
     group=G_SMMA_CHANNEL,
     tooltip=TT_SMMA_CHANNEL_LEN)

int in_smmaChannelLineWidth = input.int(
     defval=1,
     minval=1,
     maxval=5,
     title=" ↳ Channel Line Width",
     group=G_SMMA_CHANNEL,
     tooltip=TT_SMMA_CHANNEL_LINE_WIDTH)

int in_smmaChannelFillTransp = input.int(
     defval=85,
     minval=0,
     maxval=100,
     title=" ↳ Channel Fill Transparency",
     group=G_SMMA_CHANNEL,
     tooltip=TT_SMMA_CHANNEL_FILL_TRANSP)

int in_smmaChannelNeutralFillTransp = input.int(
     defval=95,
     minval=0,
     maxval=100,
     title=" ↳ Neutral Fill Transparency",
     group=G_SMMA_CHANNEL,
     tooltip=TT_SMMA_CHANNEL_NEUTRAL_FILL_TRANSP)
     
// ──────────────────────────────────────────────
// 🟦 Subregion: Price Average Line
// ──────────────────────────────────────────────
// Purpose:
//     Controls whether the Trend SMMA price-average line is shown and how that
//     OHLC4-based line is built and displayed on the chart.
//
// Notes:
//     • Overlay Length Mode above controls whether Price Average Length uses
//       Auto timeframe presets or the manual value below.
//     • Price Average Smoothing controls how that OHLC4 line is averaged.
//     • Plot Last N Bars limits how much of the line remains visible.
//
string in_smmaChannelShowPriceAverageMode = input.string(
     defval="Show",
     title="Price Average Line",
     options=["Show", "Hide"],
     group=G_SMMA_CHANNEL,
     tooltip=TT_SMMA_CHANNEL_SHOW_PA)

int in_smmaChannelPriceAverageLen = input.int(
     defval=13,
     minval=1,
     title="  ↳ Manual Price Average Length",
     group=G_SMMA_CHANNEL,
     tooltip=TT_SMMA_CHANNEL_PA_LEN)

string in_smmaChannelPriceAverageType = input.string(
     defval="RMA",
     title=" ↳ Price Average Smoothing",
     options=["SMA", "EMA", "RMA"],
     group=G_SMMA_CHANNEL,
     tooltip=TT_SMMA_CHANNEL_PA_TYPE)

int in_smmaChannelPriceAverageLastN = input.int(
     defval=55,
     minval=1,
     maxval=5000,
     title=" ↳ Plot Last N Bars",
     group=G_SMMA_CHANNEL,
     tooltip=TT_SMMA_CHANNEL_PA_LAST_N)

// ──────────────────────────────────────────────
// 🟦 Subregion: Bullish / Bearish Triangles
// ──────────────────────────────────────────────
// Purpose:
//     Controls whether the Trend SMMA bullish / bearish triangle markers are shown
//     and whether their OB/OS engine uses Auto timeframe presets or manual lengths.
//
// Notes:
//     • Auto uses five timeframe buckets:
//         - Seconds to 5m = 8 / 18
//         - >5m to <30m = 6 / 14
//         - 30m to <4h = 5 / 12
//         - 4h to <1D = 4 / 10
//         - 1D and higher = 3 / 8
//     • Manual uses the two manual inputs below.
//
string in_smmaChannelObOsMode = input.string(
     defval="Show",
     title="Bullish / Bearish Triangles",
     options=["Show", "Hide"],
     group=G_SMMA_CHANNEL,
     tooltip=TT_SMMA_CHANNEL_OBOS_MODE)

string in_smmaChannelObOsLengthMode = input.string(
     defval="Auto",
     title="  ↳ Triangle Length Mode",
     options=["Auto", "Manual"],
     group=G_SMMA_CHANNEL,
     tooltip=TT_SMMA_CHANNEL_OBOS_LENGTH_MODE)

int in_smmaChannelObOsLen = input.int(
     defval=5,
     minval=1,
     title="   ↳ Manual OB/OS Channel Lookback",
     group=G_SMMA_CHANNEL,
     tooltip=TT_SMMA_CHANNEL_OBOS_LEN)

int in_smmaChannelObOsAdaptiveLen = input.int(
     defval=12,
     minval=2,
     maxval=200,
     title="   ↳ Manual OB/OS Level Adaptive Length",
     group=G_SMMA_CHANNEL,
     tooltip=TT_SMMA_CHANNEL_OBOS_ADAPT_LEN)

// ==============================================================================================
// 🔴 END REGION: Inputs
// ==============================================================================================

/// ==============================================================================================
// 🟢 REGION: Core Series
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: RSI Core Series
// ──────────────────────────────────────────────
// Purpose:
//     Builds the main RSI series used by the pane rows and table.
//
float rsi =
     ta.rsi(close, in_rsiLen)

// ──────────────────────────────────────────────
// 🟦 Subregion: Higher-Timeframe RSI Reference
// ──────────────────────────────────────────────
// Purpose:
//     Builds the hardcoded higher-timeframe RSI reference used by the HTF relation row.
//
// Notes:
//     • This script always uses the next logical higher timeframe.
//     • HTF selection is intentionally not user-configurable to keep the dashboard simpler.
//
string activeHtf =
     f_getNextTf()

f_secHtfRsi(_tf) =>
    request.security(
         syminfo.tickerid,
         _tf,
         ta.rsi(close, in_rsiLen),
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off)

float htfRsiRaw =
     f_secHtfRsi(activeHtf)

float htfRsi =
     SCL_HTF.f_HTF_Float(
         _HTF=activeHtf,
         _source=htfRsiRaw,
         _arrayHistory=2,
         _HTF_offset=0,
         _useLiveDataOnChartTF=true)

// ──────────────────────────────────────────────
// 🟦 Subregion: Fast / Slow Average Series
// ──────────────────────────────────────────────
// Purpose:
//     Builds the selected fast and slow RSI averages.
//
float rsiFastAvg =
     f_avgSeries(rsi, in_fastLen, in_avgType)

float rsiSlowAvg =
     f_avgSeries(rsi, in_slowLen, in_avgType)

// ──────────────────────────────────────────────
// 🟦 Subregion: Bar-to-Bar Delta Series
// ──────────────────────────────────────────────
// Purpose:
//     Tracks simple bar-to-bar change for RSI, HTF RSI, and both averages.
//
float rsiDelta =
     rsi - rsi[1]

float htfRsiDelta =
     htfRsi - htfRsi[1]

float fastAvgDelta =
     rsiFastAvg - rsiFastAvg[1]

float slowAvgDelta =
     rsiSlowAvg - rsiSlowAvg[1]

// ──────────────────────────────────────────────
// 🟦 Subregion: Linear Regression Slope Series
// ──────────────────────────────────────────────
// Purpose:
//     Builds LR-slope values used for the up / down / flat arrows in the pane table.
//
float rsiSlope =
     f_lrSlope(rsi, in_avgSlopeLen)

float htfRsiSlope =
     f_lrSlope(htfRsi, in_avgSlopeLen)

float fastAvgSlope =
     f_lrSlope(rsiFastAvg, in_avgSlopeLen)

float slowAvgSlope =
     f_lrSlope(rsiSlowAvg, in_avgSlopeLen)

// ──────────────────────────────────────────────
// 🟦 Subregion: Fast / Slow Relation State
// ──────────────────────────────────────────────
// Purpose:
//     Tracks RSI vs HTF RSI, fast / slow average relations, and how long each
//     active relationship has remained in force.
//
bool htfRelationBull =
     not na(rsi) and
     not na(htfRsi) and
     rsi > htfRsi

bool htfRelationBear =
     not na(rsi) and
     not na(htfRsi) and
     rsi < htfRsi

bool htfRelationActive =
     htfRelationBull or htfRelationBear

bool htfRelationFlip =
     htfRelationActive and
     (
         (htfRelationBull and not htfRelationBull[1]) or
         (htfRelationBear and not htfRelationBear[1])
     )

var int htfRelationDurationBars = 0

htfRelationDurationBars :=
     htfRelationActive
     ? htfRelationFlip ? 1 : nz(htfRelationDurationBars[1]) + 1
     : 0

bool fastAboveSlow =
     not na(rsiFastAvg) and
     not na(rsiSlowAvg) and
     rsiFastAvg > rsiSlowAvg

bool slowAboveFast =
     not na(rsiFastAvg) and
     not na(rsiSlowAvg) and
     rsiFastAvg < rsiSlowAvg

bool crossStateActive =
     fastAboveSlow or slowAboveFast

bool crossStateFlip =
     crossStateActive and
     (
         (fastAboveSlow and not fastAboveSlow[1]) or
         (slowAboveFast and not slowAboveFast[1])
     )

var int crossDurationBars = 0

crossDurationBars :=
     crossStateActive
     ? crossStateFlip ? 1 : nz(crossDurationBars[1]) + 1
     : 0

bool fastRelationBull =
     not na(rsi) and
     not na(rsiFastAvg) and
     rsi > rsiFastAvg

bool fastRelationBear =
     not na(rsi) and
     not na(rsiFastAvg) and
     rsi < rsiFastAvg

bool fastRelationActive =
     fastRelationBull or fastRelationBear

bool fastRelationFlip =
     fastRelationActive and
     (
         (fastRelationBull and not fastRelationBull[1]) or
         (fastRelationBear and not fastRelationBear[1])
     )

var int fastRelationDurationBars = 0

fastRelationDurationBars :=
     fastRelationActive
     ? fastRelationFlip ? 1 : nz(fastRelationDurationBars[1]) + 1
     : 0

bool slowRelationBull =
     not na(rsi) and
     not na(rsiSlowAvg) and
     rsi > rsiSlowAvg

bool slowRelationBear =
     not na(rsi) and
     not na(rsiSlowAvg) and
     rsi < rsiSlowAvg

bool slowRelationActive =
     slowRelationBull or slowRelationBear

bool slowRelationFlip =
     slowRelationActive and
     (
         (slowRelationBull and not slowRelationBull[1]) or
         (slowRelationBear and not slowRelationBear[1])
     )

var int slowRelationDurationBars = 0

slowRelationDurationBars :=
     slowRelationActive
     ? slowRelationFlip ? 1 : nz(slowRelationDurationBars[1]) + 1
     : 0

// ==============================================================================================
// 🔴 END REGION: Core Series
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: Color State
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: Pane Visibility State
// ──────────────────────────────────────────────
// Purpose:
//     Controls whether the pane rows are shown and whether a bar is inside the
//     active Last N Bars window.
//
bool showStripPane =
     in_stripMode == "Show"

bool inWindow =
     bar_index >= math.max(last_bar_index - in_stripLastN + 1, 0)

// ──────────────────────────────────────────────
// 🟦 Subregion: RSI Row Color State
// ──────────────────────────────────────────────
// Purpose:
//     Builds the top RSI row color from the RSI band engine.
//
color rsiRowColor =
     f_rsiTrendLevelColor(
         rsi,
         0,
         in_rsiNeutralUpper,
         in_rsiNeutralLower)

// ──────────────────────────────────────────────
// 🟦 Subregion: HTF Row Color State
// ──────────────────────────────────────────────
// Purpose:
//     Resolves the HTF row state from chart RSI vs higher-timeframe RSI, with
//     optional duration-based gradient intensity.
//
bool rsiAboveHtf =
     not na(rsi) and
     not na(htfRsi) and
     rsi > htfRsi

bool rsiBelowHtf =
     not na(rsi) and
     not na(htfRsi) and
     rsi < htfRsi

color htfRowBaseColor =
     in_fastRowColorMode == "Gradient"
     ? f_durationGradientBaseColor(
         htfRelationDurationBars,
         rsiAboveHtf,
         rsiBelowHtf,
         in_trendUpColor,
         in_trendDownColor)
     : rsiAboveHtf
     ? in_trendUpColor
     : rsiBelowHtf
     ? in_trendDownColor
     : color.gray

color htfRowColor =
     color.new(htfRowBaseColor, 0)

// ──────────────────────────────────────────────
// 🟦 Subregion: Fast Row Color State
// ──────────────────────────────────────────────
// Purpose:
//     Resolves the fast row state from RSI vs the fast average, with optional
//     duration-based gradient intensity.
//
bool rsiAboveFast =
     not na(rsi) and
     not na(rsiFastAvg) and
     rsi > rsiFastAvg

bool rsiBelowFast =
     not na(rsi) and
     not na(rsiFastAvg) and
     rsi < rsiFastAvg

color fastRowBaseColor =
     in_fastRowColorMode == "Gradient"
     ? f_durationGradientBaseColor(
         fastRelationDurationBars,
         rsiAboveFast,
         rsiBelowFast,
         in_trendUpColor,
         in_trendDownColor)
     : rsiAboveFast
     ? in_trendUpColor
     : rsiBelowFast
     ? in_trendDownColor
     : color.gray

color fastRowColor =
     color.new(fastRowBaseColor, 0)

// ──────────────────────────────────────────────
// 🟦 Subregion: Slow Row Color State
// ──────────────────────────────────────────────
// Purpose:
//     Resolves the slow row state from RSI vs the slow average, with optional
//     duration-based gradient intensity.
//
bool rsiAboveSlow =
     not na(rsi) and
     not na(rsiSlowAvg) and
     rsi > rsiSlowAvg

bool rsiBelowSlow =
     not na(rsi) and
     not na(rsiSlowAvg) and
     rsi < rsiSlowAvg

color slowRowBaseColor =
     in_fastRowColorMode == "Gradient"
     ? f_durationGradientBaseColor(
         slowRelationDurationBars,
         rsiAboveSlow,
         rsiBelowSlow,
         in_trendUpColor,
         in_trendDownColor)
     : rsiAboveSlow
     ? in_trendUpColor
     : rsiBelowSlow
     ? in_trendDownColor
     : color.gray

color slowRowColor =
     color.new(slowRowBaseColor, 0)

// ──────────────────────────────────────────────
// 🟦 Subregion: Cross Duration Row Color State
// ──────────────────────────────────────────────
// Purpose:
//     Resolves the bottom row from the fast vs slow relationship, with optional
//     duration-based gradient intensity.
//
color crossRowBaseColor =
     in_fastRowColorMode == "Gradient"
     ? f_durationGradientBaseColor(
         crossDurationBars,
         fastAboveSlow,
         slowAboveFast,
         in_trendUpColor,
         in_trendDownColor)
     : fastAboveSlow
     ? in_trendUpColor
     : slowAboveFast
     ? in_trendDownColor
     : color.gray

color crossRowColor =
     color.new(crossRowBaseColor, 0)

// ──────────────────────────────────────────────
// 🟦 Subregion: Separator Color State
// ──────────────────────────────────────────────
// Purpose:
//     Builds the divider color used between the five pane rows.
//
color separatorColor =
     color.new(color.gray, 100)

// ==============================================================================================
// 🔴 END REGION: Color State
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: RSI Trend Candle Overlay
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: Body Color State
// ──────────────────────────────────────────────
// Purpose:
//     Builds the RSI-driven body color for the candle overlay.
//
color rsiTrendBodyColor =
     f_rsiTrendLevelColor(
         rsi,
         in_rsiTrendBodyTransp,
         in_rsiNeutralUpper,
         in_rsiNeutralLower)

// ──────────────────────────────────────────────
// 🟦 Subregion: Wick Color State
// ──────────────────────────────────────────────
// Purpose:
//     Builds the RSI-driven wick color for the candle overlay.
//
color rsiTrendWickColor =
     f_rsiTrendLevelColor(
         rsi,
         in_rsiTrendWickTransp,
         in_rsiNeutralUpper,
         in_rsiNeutralLower)

// ──────────────────────────────────────────────
// 🟦 Subregion: Border Color State
// ──────────────────────────────────────────────
// Purpose:
//     Builds the RSI-driven border color for the candle overlay.
//
color rsiTrendBorderColor =
     f_rsiTrendLevelColor(
         rsi,
         in_rsiTrendBorderTransp,
         in_rsiNeutralUpper,
         in_rsiNeutralLower)

// ==============================================================================================
// 🔴 END REGION: RSI Trend Candle Overlay
// ==============================================================================================

/// ==============================================================================================
// 🟢 REGION: Row Geometry
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: Static Row Levels
// ──────────────────────────────────────────────
// Purpose:
//     Defines the fixed top and bottom bounds for the five pane rows.
//
float rowRsiTop =
     5.00

float rowRsiBottom =
     rowRsiTop - in_rowHeight

float rowHtfTop =
     4.00

float rowHtfBottom =
     rowHtfTop - in_rowHeight

float rowFastTop =
     3.00

float rowFastBottom =
     rowFastTop - in_rowHeight

float rowSlowTop =
     2.00

float rowSlowBottom =
     rowSlowTop - in_rowHeight

float rowCrossTop =
     1.00

float rowCrossBottom =
     rowCrossTop - in_rowHeight


// ──────────────────────────────────────────────
// 🟦 Subregion: Row Plot Series
// ──────────────────────────────────────────────
// Purpose:
//     Gates each row boundary so the pane only plots when enabled and inside the
//     active Last N Bars window.
//
float rowRsiTopSeries =
     showStripPane and inWindow ? rowRsiTop : na

float rowRsiBottomSeries =
     showStripPane and inWindow ? rowRsiBottom : na

float rowHtfTopSeries =
     showStripPane and inWindow ? rowHtfTop : na

float rowHtfBottomSeries =
     showStripPane and inWindow ? rowHtfBottom : na

float rowFastTopSeries =
     showStripPane and inWindow ? rowFastTop : na

float rowFastBottomSeries =
     showStripPane and inWindow ? rowFastBottom : na

float rowSlowTopSeries =
     showStripPane and inWindow ? rowSlowTop : na

float rowSlowBottomSeries =
     showStripPane and inWindow ? rowSlowBottom : na

float rowCrossTopSeries =
     showStripPane and inWindow ? rowCrossTop : na

float rowCrossBottomSeries =
     showStripPane and inWindow ? rowCrossBottom : na


// ──────────────────────────────────────────────
// 🟦 Subregion: Separator Geometry
// ──────────────────────────────────────────────
// Purpose:
//     Defines the hardcoded divider lines between the five pane rows.
//
float sep1Series =
     showStripPane and inWindow ? 4.50 : na

float sep2Series =
     showStripPane and inWindow ? 3.50 : na

float sep3Series =
     showStripPane and inWindow ? 2.50 : na

float sep4Series =
     showStripPane and inWindow ? 1.50 : na

// ==============================================================================================
// 🔴 END REGION: Row Geometry
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: Trend SMMA Channel Overlay
// ==============================================================================================
//
// Purpose:
//     Draws a force-overlay Wilder-style smoothed high/low channel on the main
//     chart and can color that channel by a smoothed OHLC4 price-average line.
//
// Behavior:
//     • The upper channel boundary is built from ta.rma(high, length).
//     • The lower channel boundary is built from ta.rma(low, length).
//     • An optional smoothed OHLC4 price-average line can be shown on top of the channel.
//     • The channel and price-average line can use either Auto timeframe presets
//       or manual lengths.
//     • The bullish / bearish triangle engine can also use Auto timeframe presets
//       or manual lengths.
//
// Notes:
//     • This overlay is drawn in the main price pane using force_overlay=true.
//     • Overlay Length Mode controls the shared auto/manual length behavior for
//       the channel and the OHLC4 price-average line.
//     • Triangle Length Mode controls the OB/OS triangle engine separately.
//
// ==============================================================================================
//
// ──────────────────────────────────────────────
// 🟦 Subregion: Visibility State
// ──────────────────────────────────────────────
// Purpose:
//     Resolves whether the Trend SMMA Channel Overlay should render.
//
bool showSmmaChannel =
     in_smmaChannelMode == "Show"

// ──────────────────────────────────────────────
// 🟦 Subregion: Overlay Length Resolver
// ──────────────────────────────────────────────
// Purpose:
//     Resolves the active auto/manual lengths used by the Trend SMMA overlay
//     and the bullish / bearish triangle engine.
//
// Notes:
//     • This uses the same static-selector pattern already used in the RSI Pro script.
//     • Auto selects a fixed preset by chart timeframe.
//     • Manual uses the user-entered inputs directly.
//
int smmaChannelLen_auto =
     timeframe.isseconds or (timeframe.isminutes and timeframe.multiplier <= 5) ? 55 :
     timeframe.isminutes and timeframe.multiplier < 30                          ? 34 :
     timeframe.isminutes and timeframe.multiplier < 240                         ? 21 :
     (timeframe.isminutes and timeframe.multiplier >= 240) or (timeframe.isdaily and timeframe.multiplier == 1) ? 13 :
                                                                                  8

int smmaChannelPriceAverageLen_auto =
     timeframe.isseconds or (timeframe.isminutes and timeframe.multiplier <= 5) ? 15 :
     timeframe.isminutes and timeframe.multiplier < 30                          ? 10 :
     timeframe.isminutes and timeframe.multiplier < 240                         ? 6 :
     (timeframe.isminutes and timeframe.multiplier >= 240) or (timeframe.isdaily and timeframe.multiplier == 1) ? 4 :
                                                                                  3

int smmaChannelObOsLen_auto =
     timeframe.isseconds or (timeframe.isminutes and timeframe.multiplier <= 5) ? 8 :
     timeframe.isminutes and timeframe.multiplier < 30                          ? 6 :
     timeframe.isminutes and timeframe.multiplier < 240                         ? 5 :
     (timeframe.isminutes and timeframe.multiplier >= 240) or (timeframe.isdaily and timeframe.multiplier == 1) ? 4 :
                                                                                  3

int smmaChannelObOsAdaptiveLen_auto =
     timeframe.isseconds or (timeframe.isminutes and timeframe.multiplier <= 5) ? 18 :
     timeframe.isminutes and timeframe.multiplier < 30                          ? 14 :
     timeframe.isminutes and timeframe.multiplier < 240                         ? 12 :
     (timeframe.isminutes and timeframe.multiplier >= 240) or (timeframe.isdaily and timeframe.multiplier == 1) ? 10 :
                                                                                  8

int smmaChannelLen_active =
     in_smmaOverlayLengthMode == "Auto" ? smmaChannelLen_auto : in_smmaChannelLen

int smmaChannelPriceAverageLen_active =
     in_smmaOverlayLengthMode == "Auto" ? smmaChannelPriceAverageLen_auto : in_smmaChannelPriceAverageLen

int smmaChannelObOsLen_active =
     in_smmaChannelObOsLengthMode == "Auto" ? smmaChannelObOsLen_auto : in_smmaChannelObOsLen

int smmaChannelObOsAdaptiveLen_active =
     in_smmaChannelObOsLengthMode == "Auto" ? smmaChannelObOsAdaptiveLen_auto : in_smmaChannelObOsAdaptiveLen

// ──────────────────────────────────────────────
// 🟦 Subregion: Channel Core Series
// ──────────────────────────────────────────────
// Purpose:
//     Builds the Wilder-style smoothed channel boundaries from high/low and the
//     optional smoothed OHLC4 price-average line using the active overlay lengths.
//
float smmaChannelHigh =
     ta.rma(high, smmaChannelLen_active)

float smmaChannelLow =
     ta.rma(low, smmaChannelLen_active)

float smmaChannelPriceAverageSma =
     ta.sma(ohlc4, smmaChannelPriceAverageLen_active)

float smmaChannelPriceAverageEma =
     ta.ema(ohlc4, smmaChannelPriceAverageLen_active)

float smmaChannelPriceAverageRma =
     ta.rma(ohlc4, smmaChannelPriceAverageLen_active)

float smmaChannelPriceAverage =
     in_smmaChannelPriceAverageType == "SMA" ? smmaChannelPriceAverageSma :
     in_smmaChannelPriceAverageType == "EMA" ? smmaChannelPriceAverageEma :
     smmaChannelPriceAverageRma

// ──────────────────────────────────────────────
// 🟦 Subregion: Overbought / Oversold State
// ──────────────────────────────────────────────
// Purpose:
//     Builds a dynamic PA-style overbought / oversold engine for the Trend SMMA
//     Channel Overlay using a short Wilder-style channel, Williams-style pivot
//     detection, and adaptive EMA levels.
//
// Notes:
//     • This is the logic that drives the bullish and bearish triangle markers.
//     • Overbought conditions are rendered as bullish green up-triangles below price.
//     • Oversold conditions are rendered as bearish red down-triangles above price.
//     • Triangle Length Mode is resolved above before these calculations run.
//     • This version uses the active triangle lengths resolved in the overlay
//       length resolver above.
//     • To keep the port surgical, this version reuses the script's RSI Length
//       instead of adding SCL's separate PA RSI Length mode.
//
bool showSmmaChannelObOsTriangles =
     in_smmaChannelObOsMode == "Show"

float smmaObOsHigh =
     ta.rma(high, smmaChannelObOsLen_active)

float smmaObOsLow =
     ta.rma(low, smmaChannelObOsLen_active)

float smmaObOsHalfRange =
     (smmaObOsHigh - smmaObOsLow) / 2.0

float smmaObOsMid =
     smmaObOsLow + smmaObOsHalfRange

float smmaObOsRsiHighRaw =
     ta.rsi((high - smmaObOsMid) / smmaObOsHalfRange, in_rsiLen)

float smmaObOsRsiLowRaw =
     ta.rsi((low - smmaObOsMid) / smmaObOsHalfRange, in_rsiLen)

float smmaObOsRsiHigh =
     na(smmaObOsHalfRange) or smmaObOsHalfRange == 0 ? na : smmaObOsRsiHighRaw

float smmaObOsRsiLow =
     na(smmaObOsHalfRange) or smmaObOsHalfRange == 0 ? na : smmaObOsRsiLowRaw

float smmaObOsRsiMax =
     math.max(smmaObOsRsiHigh, smmaObOsRsiLow)

float smmaObOsRsiMin =
     math.min(smmaObOsRsiHigh, smmaObOsRsiLow)

bool smmaObOsBothAboveMidline =
     smmaObOsRsiMax > 50 and smmaObOsRsiMin > 50

bool smmaObOsBothBelowMidline =
     smmaObOsRsiMax < 50 and smmaObOsRsiMin < 50

float smmaObOsChosen =
     smmaObOsBothAboveMidline ? smmaObOsRsiMax :
     smmaObOsBothBelowMidline ? smmaObOsRsiMin :
     math.abs(smmaObOsRsiMax - 50) < math.abs(smmaObOsRsiMin - 50) ? smmaObOsRsiMax :
     smmaObOsRsiMin

int smmaObOsPivotOffset =
     3

bool smmaObOsIsWilliamsHigh =
     smmaObOsChosen[smmaObOsPivotOffset] >= ta.highest(smmaObOsChosen, 8)

bool smmaObOsIsWilliamsLow =
     smmaObOsChosen[smmaObOsPivotOffset] <= ta.lowest(smmaObOsChosen, 8)

float smmaObOsWilliamsHighPrice =
     smmaObOsIsWilliamsHigh ? smmaObOsChosen[smmaObOsPivotOffset] : na

float smmaObOsWilliamsLowPrice =
     smmaObOsIsWilliamsLow ? smmaObOsChosen[smmaObOsPivotOffset] : na

float smmaObOsAlpha =
     2.0 / (smmaChannelObOsAdaptiveLen_active + 1)

var float smmaObOsHighEma = na
if smmaObOsWilliamsHighPrice > in_rsiNeutralUpper and smmaObOsIsWilliamsHigh
    smmaObOsHighEma :=
         smmaObOsAlpha * smmaObOsWilliamsHighPrice +
         (1.0 - smmaObOsAlpha) * nz(smmaObOsHighEma[1], smmaObOsWilliamsHighPrice)

var float smmaObOsLowEma = na
if smmaObOsWilliamsLowPrice < in_rsiNeutralLower and smmaObOsIsWilliamsLow
    smmaObOsLowEma :=
         smmaObOsAlpha * smmaObOsWilliamsLowPrice +
         (1.0 - smmaObOsAlpha) * nz(smmaObOsLowEma[1], smmaObOsWilliamsLowPrice)

float smmaOverboughtLine =
     smmaObOsHighEma > 0 ? smmaObOsHighEma : na

float smmaOversoldLine =
     smmaObOsLowEma > 0 ? smmaObOsLowEma : na

bool smmaChannelIsOverbought =
     not na(smmaOverboughtLine) and
     smmaObOsChosen > smmaOverboughtLine

bool smmaChannelIsOversold =
     not na(smmaOversoldLine) and
     smmaObOsChosen < smmaOversoldLine

bool plotSmmaChannelOverboughtTriangles =
     showSmmaChannelObOsTriangles and
     smmaChannelIsOverbought

bool plotSmmaChannelOversoldTriangles =
     showSmmaChannelObOsTriangles and
     smmaChannelIsOversold

// ──────────────────────────────────────────────
// 🟦 Subregion: Channel Color State
// ──────────────────────────────────────────────
// Purpose:
//     Resolves channel color by comparing the smoothed OHLC4 price-average line
//     against the Wilder-style smoothed upper and lower channel boundaries.
//
// Notes:
//     • Channel coloring always follows the original PA-style logic.
//     • Trend Up Color = price average is above the upper boundary.
//     • Trend Down Color = price average is below the lower boundary.
//     • Neutral = price average is inside the channel.
//
bool showSmmaChannelPriceAverage =
     in_smmaChannelShowPriceAverageMode == "Show"

bool inSmmaChannelPriceAverageWindow =
     bar_index >= math.max(last_bar_index - in_smmaChannelPriceAverageLastN + 1, 0)
     
bool smmaChannelIsColourable =
     showSmmaChannel and
     not na(smmaChannelHigh) and
     not na(smmaChannelLow) and
     not na(smmaChannelPriceAverage)

bool smmaChannelBull =
     smmaChannelIsColourable and
     smmaChannelPriceAverage > smmaChannelHigh

bool smmaChannelBear =
     smmaChannelIsColourable and
     smmaChannelPriceAverage < smmaChannelLow

color smmaChannelCoreColor =
     not smmaChannelIsColourable ? color.gray :
     smmaChannelBull ? in_trendUpColor :
     smmaChannelBear ? in_trendDownColor :
     color.white

color smmaChannelHighColor =
     smmaChannelCoreColor

color smmaChannelLowColor =
     smmaChannelCoreColor

color smmaChannelFillColor =
     color.new(
         smmaChannelCoreColor,
         smmaChannelBull or smmaChannelBear ? in_smmaChannelFillTransp : in_smmaChannelNeutralFillTransp)
     
// ──────────────────────────────────────────────
// 🟦 Subregion: Channel Overlay Render
// ──────────────────────────────────────────────
// Purpose:
//     Draws the upper/lower channel boundaries, the filled band, and the
//     optional OHLC4 price-average line on the main chart using force_overlay=true.
//
// Notes:
//     • The channel boundaries always follow the Wilder-style smoothed high/low series.
//     • The fill sits between the upper and lower channel boundaries.
//     • The OHLC4 price-average line only renders when its dropdown is set to Show.
//     • The price-average line can be limited to its own Last N Bars window.
//
plotSmmaChannelHigh = plot(
     showSmmaChannel ? smmaChannelHigh : na,
     title="Trend SMMA High Overlay",
     color=smmaChannelHighColor,
     linewidth=in_smmaChannelLineWidth,
     force_overlay=true)

plotSmmaChannelLow = plot(
     showSmmaChannel ? smmaChannelLow : na,
     title="Trend SMMA Low Overlay",
     color=smmaChannelLowColor,
     linewidth=in_smmaChannelLineWidth,
     force_overlay=true)

fill(
     plotSmmaChannelHigh,
     plotSmmaChannelLow,
     title="Trend SMMA Channel Fill",
     color=showSmmaChannel ? smmaChannelFillColor : na)

plot(
     showSmmaChannel and showSmmaChannelPriceAverage and inSmmaChannelPriceAverageWindow ? smmaChannelPriceAverage : na,
     title="Trend SMMA Price Average",
     color=chart.fg_color,
     linewidth=2,
     force_overlay=true)

// ──────────────────────────────────────────────
// 🟦 Subregion: Bullish / Bearish Triangle Render
// ──────────────────────────────────────────────
// Purpose:
//     Draws the Trend SMMA bullish and bearish triangle markers on the main chart.
//
// Notes:
//     • Overbought conditions are shown as bullish green up-triangles below the bar.
//     • Oversold conditions are shown as bearish red down-triangles above the bar.
//     • Separate plot titles allow individual style toggles in TradingView.
//
//
plotshape(
     plotSmmaChannelOverboughtTriangles,
     title="Trend SMMA Green Bullish Triangles",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.new(color.lime, 10),
     size=size.tiny,
     force_overlay=true)

plotshape(
     plotSmmaChannelOversoldTriangles,
     title="Trend SMMA Red Bearish Triangles",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.new(color.red, 10),
     size=size.tiny,
     force_overlay=true)

// ==============================================================================================
// 🔴 END REGION: Trend SMMA Channel Overlay
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: Trend Strip Render
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: Row Boundary Anchors
// ──────────────────────────────────────────────
// Purpose:
//     Creates the hidden top and bottom plot anchors used to render the five trend-strip rows.
//
plotRowRsiTop = plot(
     rowRsiTopSeries,
     title="RSI Row Top",
     color=color.new(color.white, 100),
     linewidth=1)

plotRowRsiBottom = plot(
     rowRsiBottomSeries,
     title="RSI Row Bottom",
     color=color.new(color.white, 100),
     linewidth=1)

plotRowHtfTop = plot(
     rowHtfTopSeries,
     title="HTF Row Top",
     color=color.new(color.white, 100),
     linewidth=1)

plotRowHtfBottom = plot(
     rowHtfBottomSeries,
     title="HTF Row Bottom",
     color=color.new(color.white, 100),
     linewidth=1)

plotRowFastTop = plot(
     rowFastTopSeries,
     title="Fast Row Top",
     color=color.new(color.white, 100),
     linewidth=1)

plotRowFastBottom = plot(
     rowFastBottomSeries,
     title="Fast Row Bottom",
     color=color.new(color.white, 100),
     linewidth=1)

plotRowSlowTop = plot(
     rowSlowTopSeries,
     title="Slow Row Top",
     color=color.new(color.white, 100),
     linewidth=1)

plotRowSlowBottom = plot(
     rowSlowBottomSeries,
     title="Slow Row Bottom",
     color=color.new(color.white, 100),
     linewidth=1)

plotRowCrossTop = plot(
     rowCrossTopSeries,
     title="Cross Duration Row Top",
     color=color.new(color.white, 100),
     linewidth=1)

plotRowCrossBottom = plot(
     rowCrossBottomSeries,
     title="Cross Duration Row Bottom",
     color=color.new(color.white, 100),
     linewidth=1)

// ──────────────────────────────────────────────
// 🟦 Subregion: Row Fill Render
// ──────────────────────────────────────────────
// Purpose:
//     Fills each trend-strip row using the resolved RSI, HTF, fast, slow, and fast-vs-slow colors.
//
fill(
     plotRowRsiTop,
     plotRowRsiBottom,
     color=rsiRowColor)

fill(
     plotRowHtfTop,
     plotRowHtfBottom,
     color=htfRowColor)

fill(
     plotRowFastTop,
     plotRowFastBottom,
     color=fastRowColor)

fill(
     plotRowSlowTop,
     plotRowSlowBottom,
     color=slowRowColor)

fill(
     plotRowCrossTop,
     plotRowCrossBottom,
     color=crossRowColor)

// ──────────────────────────────────────────────
// 🟦 Subregion: Separator Render
// ──────────────────────────────────────────────
// Purpose:
//     Draws the divider lines between the five trend-strip rows.
//
plot(
     sep1Series,
     title="Separator 1",
     color=separatorColor,
     linewidth=1)

plot(
     sep2Series,
     title="Separator 2",
     color=separatorColor,
     linewidth=1)

plot(
     sep3Series,
     title="Separator 3",
     color=separatorColor,
     linewidth=1)

plot(
     sep4Series,
     title="Separator 4",
     color=separatorColor,
     linewidth=1)

// ==============================================================================================
// 🔴 END REGION: Trend Strip Render
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: Pane Table
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: Table State
// ──────────────────────────────────────────────
// Purpose:
//     Resolves table visibility, frame styling, and spacer-row height.
//
bool showPaneTable =
     in_tableMode == "Show"

color tableFrameColor =
     color.new(in_tableFrameColor, in_tableFrameTransp)

int tableGapHeight =
     math.max(2, int(math.round(in_tableRowHeight * 0.30)))


// ──────────────────────────────────────────────
// 🟦 Subregion: Table Text State
// ──────────────────────────────────────────────
// Purpose:
//     Builds the display text used by the dashboard table, including:
//     • row labels
//     • rounded current values
//     • delta text
//     • the merged fast-vs-slow summary row
//
// Notes:
//     • Average labels use a spaced format such as "SMA 20" or "EMA 50".
//     • Value fields show rounded readings plus the slope arrow.
//     • Delta fields show the rounded bar-to-bar change.
//     • The bottom merged row summarizes the active fast-vs-slow relationship.
//
string fastLabelText =
     in_avgType + " " + str.tostring(in_fastLen)

string slowLabelText =
     in_avgType + " " + str.tostring(in_slowLen)

string crossDurationText =
     str.tostring(crossDurationBars) + " bar" + (crossDurationBars == 1 ? "" : "s")

// Label text
string htfRelationLabelText =
     rsiAboveHtf ? "RSI > HTF RSI" :
     rsiBelowHtf ? "HTF RSI > RSI" :
     "RSI = HTF RSI"

string fastRelationLabelText =
     rsiAboveFast ? "RSI > " + fastLabelText :
     rsiBelowFast ? fastLabelText + " > RSI" :
     "RSI = " + fastLabelText

string slowRelationLabelText =
     rsiAboveSlow ? "RSI > " + slowLabelText :
     rsiBelowSlow ? slowLabelText + " > RSI" :
     "RSI = " + slowLabelText

// Current value text
string rsiValueText =
     na(rsi) ? "na" : str.tostring(math.round(rsi)) + f_slopeArrow(rsiSlope, in_avgSlopeFlat)

string htfValueText =
     na(htfRsi) ? "na" : str.tostring(math.round(htfRsi)) + f_slopeArrow(htfRsiSlope, in_avgSlopeFlat)

string fastValueText =
     na(rsiFastAvg) ? "na" : str.tostring(math.round(rsiFastAvg)) + f_slopeArrow(fastAvgSlope, in_avgSlopeFlat)

string slowValueText =
     na(rsiSlowAvg) ? "na" : str.tostring(math.round(rsiSlowAvg)) + f_slopeArrow(slowAvgSlope, in_avgSlopeFlat)

// Delta text
string rsiDeltaText =
     na(rsiDelta) ? "Δ na" : "Δ " + f_signedText(math.round(rsiDelta))

string htfDeltaText =
     na(htfRsiDelta) ? "Δ na" : "Δ " + f_signedText(math.round(htfRsiDelta))

string fastDeltaText =
     na(fastAvgDelta) ? "Δ na" : "Δ " + f_signedText(math.round(fastAvgDelta))

string slowDeltaText =
     na(slowAvgDelta) ? "Δ na" : "Δ " + f_signedText(math.round(slowAvgDelta))

// Merged bottom-row summary text
string relationRowText =
     fastAboveSlow
     ? fastLabelText + " > " + slowLabelText + " • " + crossDurationText
     : slowAboveFast
     ? slowLabelText + " > " + fastLabelText + " • " + crossDurationText
     : fastLabelText + " = " + slowLabelText

// ──────────────────────────────────────────────
// 🟦 Subregion: Table Color State
// ──────────────────────────────────────────────
// Purpose:
//     Resolves the text color used by each dashboard table row so the text
//     stays readable against the active row background color.
//
// Notes:
//     • The RSI row uses its dedicated RSI text-color helper.
//     • The relation rows use contrast-safe text unless a bearish row state
//       is forced to white for clarity.
//
color rsiRowTextColor =
     f_rsiRowTextColor(rsi, in_rsiNeutralUpper, in_rsiNeutralLower)

color htfRowTextColor =
     rsiBelowHtf ? color.white : f_contrastText(htfRowBaseColor)

color fastRowTextColor =
     rsiBelowFast ? color.white : f_contrastText(fastRowBaseColor)

color slowRowTextColor =
     rsiBelowSlow ? color.white : f_contrastText(slowRowBaseColor)

color crossRowTextColor =
     slowAboveFast ? color.white : f_contrastText(crossRowBaseColor)

// ──────────────────────────────────────────────
// 🟦 Subregion: Table Hover Tooltip State
// ──────────────────────────────────────────────
// Purpose:
//     Builds the hover text shown by the dashboard table cells.
//
// Notes:
//     • Label tooltips explain what each row represents.
//     • Value tooltips explain the rounded reading and slope arrow.
//     • Delta tooltips explain the bar-to-bar change.
//     • The bottom merged-row tooltip explains the active fast-vs-slow state.
//
string rsiLabelTooltip =
     "RSI row.\nUses RSI Length = " + str.tostring(in_rsiLen) + "."

string rsiValueTooltip =
     "Current RSI value, rounded to a whole number.\nArrow shows linear-regression slope direction.\nSlope Length = " + str.tostring(in_avgSlopeLen) + ".\nFlat Threshold = " + str.tostring(in_avgSlopeFlat) + "."

string rsiDeltaTooltip =
     "Bar-to-bar RSI change.\nCurrent RSI minus prior-bar RSI."

string htfLabelTooltip =
     "HTF RSI relation row.\nShows whether RSI is above or below the higher-timeframe RSI reference.\nReference TF = " + activeHtf + "."

string htfValueTooltip =
     "Current HTF RSI value, rounded to a whole number.\nArrow shows linear-regression slope direction.\nReference TF = " + activeHtf + ".\nSlope Length = " + str.tostring(in_avgSlopeLen) + ".\nFlat Threshold = " + str.tostring(in_avgSlopeFlat) + "."

string htfDeltaTooltip =
     "Bar-to-bar change in the HTF RSI reference.\nReference TF = " + activeHtf + "."

string fastLabelTooltip =
     "Fast relation row.\nShows whether RSI is above or below " + fastLabelText + "."

string fastValueTooltip =
     "Current fast RSI average value, rounded to a whole number.\nArrow shows linear-regression slope direction.\nSlope Length = " + str.tostring(in_avgSlopeLen) + ".\nFlat Threshold = " + str.tostring(in_avgSlopeFlat) + "."

string fastDeltaTooltip =
     "Bar-to-bar change in the fast RSI average.\nCurrent fast average minus prior-bar fast average."

string slowLabelTooltip =
     "Slow relation row.\nShows whether RSI is above or below " + slowLabelText + "."

string slowValueTooltip =
     "Current slow RSI average value, rounded to a whole number.\nArrow shows linear-regression slope direction.\nSlope Length = " + str.tostring(in_avgSlopeLen) + ".\nFlat Threshold = " + str.tostring(in_avgSlopeFlat) + "."

string slowDeltaTooltip =
     "Bar-to-bar change in the slow RSI average.\nCurrent slow average minus prior-bar slow average."

string relationRowTooltip =
     "Fast-vs-slow summary row.\nShows which RSI average is above the other and how long that relationship has remained active.\nThe matching trend-strip row deepens in color as the duration increases."

// ──────────────────────────────────────────────
// 🟦 Subregion: Table Object
// ──────────────────────────────────────────────
// Purpose:
//     Creates the fixed 3-column dashboard table.
//
// Layout:
//     • Column 1 = row label
//     • Column 2 = current value
//     • Column 3 = delta
//     • Bottom row is merged across all 3 columns
//
var table paneInfoTable = table.new(
     f_getTablePosition(in_tablePosition),
     3,
     9,
     border_width=1,
     frame_color=tableFrameColor,
     border_color=tableFrameColor)

// ──────────────────────────────────────────────
// 🟦 Subregion: Table Render
// ──────────────────────────────────────────────
// Purpose:
//     Clears and redraws the dashboard table on the last bar only.
//
// Notes:
//     • Spacer rows separate the main data rows for easier reading.
//     • The final row is merged into a single fast-vs-slow summary row.
//     • Table text, colors, and tooltips are all resolved above.
//
if barstate.islast
    table.clear(paneInfoTable, 0, 0, 2, 8)

    if showPaneTable
        // RSI row
        table.cell(
             paneInfoTable,
             0,
             0,
             "RSI",
             text_color=rsiRowTextColor,
             text_halign=text.align_center,
             text_valign=text.align_center,
             text_size=f_getTextSize(in_tableTextSize),
             bgcolor=rsiRowColor,
             height=in_tableRowHeight,
             tooltip=rsiLabelTooltip)

        table.cell(
             paneInfoTable,
             1,
             0,
             rsiValueText,
             text_color=rsiRowTextColor,
             text_halign=text.align_center,
             text_valign=text.align_center,
             text_size=f_getTextSize(in_tableTextSize),
             bgcolor=rsiRowColor,
             width=in_tableValueColsWidth,
             height=in_tableRowHeight,
             tooltip=rsiValueTooltip)

        table.cell(
             paneInfoTable,
             2,
             0,
             rsiDeltaText,
             text_color=rsiRowTextColor,
             text_halign=text.align_center,
             text_valign=text.align_center,
             text_size=f_getTextSize(in_tableTextSize),
             bgcolor=rsiRowColor,
             width=in_tableValueColsWidth,
             height=in_tableRowHeight,
             tooltip=rsiDeltaTooltip)

        // Spacer
        table.cell(
             paneInfoTable,
             0,
             1,
             "",
             text_color=color.new(color.white, 100),
             bgcolor=color.new(color.black, 100),
             height=tableGapHeight)

        table.cell(
             paneInfoTable,
             1,
             1,
             "",
             text_color=color.new(color.white, 100),
             bgcolor=color.new(color.black, 100),
             width=in_tableValueColsWidth,
             height=tableGapHeight)

        table.cell(
             paneInfoTable,
             2,
             1,
             "",
             text_color=color.new(color.white, 100),
             bgcolor=color.new(color.black, 100),
             width=in_tableValueColsWidth,
             height=tableGapHeight)

        // HTF row
        table.cell(
             paneInfoTable,
             0,
             2,
             htfRelationLabelText,
             text_color=htfRowTextColor,
             text_halign=text.align_center,
             text_valign=text.align_center,
             text_size=f_getTextSize(in_tableTextSize),
             bgcolor=htfRowColor,
             height=in_tableRowHeight,
             tooltip=htfLabelTooltip)

        table.cell(
             paneInfoTable,
             1,
             2,
             htfValueText,
             text_color=htfRowTextColor,
             text_halign=text.align_center,
             text_valign=text.align_center,
             text_size=f_getTextSize(in_tableTextSize),
             bgcolor=htfRowColor,
             width=in_tableValueColsWidth,
             height=in_tableRowHeight,
             tooltip=htfValueTooltip)

        table.cell(
             paneInfoTable,
             2,
             2,
             htfDeltaText,
             text_color=htfRowTextColor,
             text_halign=text.align_center,
             text_valign=text.align_center,
             text_size=f_getTextSize(in_tableTextSize),
             bgcolor=htfRowColor,
             width=in_tableValueColsWidth,
             height=in_tableRowHeight,
             tooltip=htfDeltaTooltip)

        // Spacer
        table.cell(
             paneInfoTable,
             0,
             3,
             "",
             text_color=color.new(color.white, 100),
             bgcolor=color.new(color.black, 100),
             height=tableGapHeight)

        table.cell(
             paneInfoTable,
             1,
             3,
             "",
             text_color=color.new(color.white, 100),
             bgcolor=color.new(color.black, 100),
             width=in_tableValueColsWidth,
             height=tableGapHeight)

        table.cell(
             paneInfoTable,
             2,
             3,
             "",
             text_color=color.new(color.white, 100),
             bgcolor=color.new(color.black, 100),
             width=in_tableValueColsWidth,
             height=tableGapHeight)

        // Fast row
        table.cell(
             paneInfoTable,
             0,
             4,
             fastRelationLabelText,
             text_color=fastRowTextColor,
             text_halign=text.align_center,
             text_valign=text.align_center,
             text_size=f_getTextSize(in_tableTextSize),
             bgcolor=fastRowColor,
             height=in_tableRowHeight,
             tooltip=fastLabelTooltip)

        table.cell(
             paneInfoTable,
             1,
             4,
             fastValueText,
             text_color=fastRowTextColor,
             text_halign=text.align_center,
             text_valign=text.align_center,
             text_size=f_getTextSize(in_tableTextSize),
             bgcolor=fastRowColor,
             width=in_tableValueColsWidth,
             height=in_tableRowHeight,
             tooltip=fastValueTooltip)

        table.cell(
             paneInfoTable,
             2,
             4,
             fastDeltaText,
             text_color=fastRowTextColor,
             text_halign=text.align_center,
             text_valign=text.align_center,
             text_size=f_getTextSize(in_tableTextSize),
             bgcolor=fastRowColor,
             width=in_tableValueColsWidth,
             height=in_tableRowHeight,
             tooltip=fastDeltaTooltip)

        // Spacer
        table.cell(
             paneInfoTable,
             0,
             5,
             "",
             text_color=color.new(color.white, 100),
             bgcolor=color.new(color.black, 100),
             height=tableGapHeight)

        table.cell(
             paneInfoTable,
             1,
             5,
             "",
             text_color=color.new(color.white, 100),
             bgcolor=color.new(color.black, 100),
             width=in_tableValueColsWidth,
             height=tableGapHeight)

        table.cell(
             paneInfoTable,
             2,
             5,
             "",
             text_color=color.new(color.white, 100),
             bgcolor=color.new(color.black, 100),
             width=in_tableValueColsWidth,
             height=tableGapHeight)

        // Slow row
        table.cell(
             paneInfoTable,
             0,
             6,
             slowRelationLabelText,
             text_color=slowRowTextColor,
             text_halign=text.align_center,
             text_valign=text.align_center,
             text_size=f_getTextSize(in_tableTextSize),
             bgcolor=slowRowColor,
             height=in_tableRowHeight,
             tooltip=slowLabelTooltip)

        table.cell(
             paneInfoTable,
             1,
             6,
             slowValueText,
             text_color=slowRowTextColor,
             text_halign=text.align_center,
             text_valign=text.align_center,
             text_size=f_getTextSize(in_tableTextSize),
             bgcolor=slowRowColor,
             width=in_tableValueColsWidth,
             height=in_tableRowHeight,
             tooltip=slowValueTooltip)

        table.cell(
             paneInfoTable,
             2,
             6,
             slowDeltaText,
             text_color=slowRowTextColor,
             text_halign=text.align_center,
             text_valign=text.align_center,
             text_size=f_getTextSize(in_tableTextSize),
             bgcolor=slowRowColor,
             width=in_tableValueColsWidth,
             height=in_tableRowHeight,
             tooltip=slowDeltaTooltip)

        // Spacer
        table.cell(
             paneInfoTable,
             0,
             7,
             "",
             text_color=color.new(color.white, 100),
             bgcolor=color.new(color.black, 100),
             height=tableGapHeight)

        table.cell(
             paneInfoTable,
             1,
             7,
             "",
             text_color=color.new(color.white, 100),
             bgcolor=color.new(color.black, 100),
             width=in_tableValueColsWidth,
             height=tableGapHeight)

        table.cell(
             paneInfoTable,
             2,
             7,
             "",
             text_color=color.new(color.white, 100),
             bgcolor=color.new(color.black, 100),
             width=in_tableValueColsWidth,
             height=tableGapHeight)

        // Fast-vs-slow summary row
        table.cell(
             paneInfoTable,
             0,
             8,
             relationRowText,
             text_color=crossRowTextColor,
             text_halign=text.align_center,
             text_valign=text.align_center,
             text_size=f_getTextSize(in_tableTextSize),
             bgcolor=crossRowColor,
             height=in_tableRowHeight,
             tooltip=relationRowTooltip)

        table.merge_cells(
             paneInfoTable,
             0,
             8,
             2,
             8)

// ==============================================================================================
// 🔴 END REGION: Dashboard Table
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: Price Candle Overlay Render
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: PlotCandle Render
// ──────────────────────────────────────────────
// Purpose:
//     Draws the RSI-colored price candle overlay when enabled.
//
// Notes:
//     • Body, wick, and border transparency are controlled separately.
//     • The overlay is drawn in the price pane using force_overlay=true.
//
plotcandle(
     open,
     high,
     low,
     close,
     color=in_rsiCandleOverlayMode == "PlotCandles" ? rsiTrendBodyColor : na,
     wickcolor=in_rsiCandleOverlayMode == "PlotCandles" ? rsiTrendWickColor : na,
     bordercolor=in_rsiCandleOverlayMode == "PlotCandles" ? rsiTrendBorderColor : na,
     title="Price Candle Overlay",
     force_overlay=true)

// ==============================================================================================
// 🔴 END REGION: Price Candle Overlay Render
// ==============================================================================================
````

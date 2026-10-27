# RSI MTF Dashboard + RSI/ATR-Based Volatility Zones

- url: https://www.tradingview.com/script/0kTlSUAd-RSI-MTF-Dashboard-RSI-ATR-Based-Volatility-Zones/
- type: indicator
- pine_id: PUB;e8ae1a684fe94ec690d15c2d1f612dc8
- version: 1.0

## Description

RSI MTF (multi-timeframe) Dashboard + RSI/ATR-Based Volatility Zones is a multi-timeframe RSI alignment dashboard built to connect RSI structure, timeframe agreement, and chart-side price context into one organized workflow. Instead of treating RSI as a single value on one timeframe, this script reads RSI across a full stack of timeframes and organizes that information into a compact table, a chart-side Stack Trend, an ATR-based envelope, a bottom-pinned bias strip, optional RSI-colored candles, and localized Bull/Bear pressure markers. The goal is to make it easier to see whether the broader RSI timeframe stack is supporting price, resisting price, mixed, or transitioning.

At the center of the script is the MTF RSI table. The table can display timeframe rows from 1 minute through monthly, with each row showing:

➡️ Current RSI  
➡️ Current RSI vs Previous RSI  
➡️ RSI SMA 20  
➡️ RSI SMA 50  
➡️ SMA slope arrows  
➡️ Live bar timer information  
➡️Lower-timeframe and higher-timeframe RSI averages

RSI is often more useful when read as a set of relationships instead of one isolated number. A single RSI value can show strength or weakness, but RSI in relation to its prior value, RSI SMA 20, RSI SMA 50, and higher timeframe context gives a cleaner view of whether momentum is building, fading, rotating, or staying aligned.

The chart-side MTF RSI Stack Trend is where the table becomes more than just a dashboard.

Each enabled timeframe row contributes to a full-stack RSI bias score using four relationships:

➡️ Current RSI regime  
➡️ Current RSI vs Previous RSI  
➡️ Current RSI vs RSI SMA 20  
➡️ Current RSI vs RSI SMA 50  

Those scores are combined into one MTF Stack Bias reading. When the stack leans bullish, the Stack Trend can project below price like a support-style trail. When the stack leans bearish, it can project above price like a resistance-style trail. When the stack is mixed or transitioning, the trail can fall back into a neutral state. That gives the chart one clean read of the broader RSI stack instead of forcing the user to mentally combine every row in the table.

The MTF Stack ATR Envelope  expands that idea into a broader volatility zone. The envelope is built around the Stack Trend system and can reference the chart Stack Trend, a higher-timeframe Stack Trend, or the midpoint between both. This creates a volatility-adjusted zone around the broader RSI stack context.

The practical use is to help answer questions like:

➡️ Is price stretched away from the active RSI stack trail?  
➡️ Is price trading inside the broader stack envelope?  
➡️ Is the chart trail aligned with the higher-timeframe trail?  
➡️ Is the stack acting more like support, resistance, or transition?  

The MTF Stack Bias Trend Strip gives another view of the same engine. Instead of projecting the stack onto price, the strip shows the raw MTF Stack Bias as a compact gradient along the bottom of the chart.

This makes it easier to see when the broader stack is:

➡️ strengthening bullish  
➡️ strengthening bearish  
➡️ fading back toward neutral  
➡️ chopping through mixed conditions  
➡️ transitioning from one regime to another  

The color behavior is intentionally visual. Stronger bullish readings can push toward yellow/orange, stronger bearish readings can push toward purple/extreme purple, and mixed readings stay closer to neutral.

The optional RSI Trend Candle Overlay brings the RSI color engine directly onto the main chart. Price candles still keep normal OHLC structure, but their body, wick, and border colors can reflect the current chart-timeframe RSI state. This makes it easier to see RSI strength, weakness, stretch, or neutrality without constantly checking a separate pane.

The Bull/Bear markers add a more localized pressure layer. These markers use a Price Action-style adaptive overbought/oversold engine built from a short Wilder-style high/low channel and adaptive trigger levels. They can be shown as raw pressure markers or filtered so bullish markers only appear during bullish stack regimes and bearish markers only appear during bearish stack regimes.

A practical way to read the script:

➡️ If the table rows are broadly bullish, RSI is above its moving-average references, and the Stack Trend is holding below price, the RSI timeframe stack is generally supporting the move.
➡️ If the table rows are broadly bearish, RSI is below its moving-average references, and the Stack Trend is pressing above price, the RSI timeframe stack is generally acting more like resistance.
➡️ If the table rows disagree, the trend strip fades toward neutral, or price is moving back through the envelope, the market may be transitioning or losing clean RSI alignment.
➡️ If the Bull/Bear markers agree with the active Stack Trend regime, they may help highlight localized pressure in the same direction as the broader RSI stack.
➡️ If the markers, candles, table, trail, and trend strip disagree, that disagreement can be useful information by itself because it often points to chop, cooling momentum, or a less directional environment.

The value of RSI MTF Table + ATR Envelope Trend is organization. It takes RSI behavior across multiple timeframes and turns it into a connected chart-side framework: table detail, stack bias, trail behavior, volatility zones, candle context, trend strip pressure, and localized markers. While this script is not meant to be a standalone buy/sell signal machine, it certainly has the necessary components and features to be just that once you learn its behavior over multiple timeframes. Used alongside oscillator, pressure, pivot-structure, and divergence tools, this script can also serve as a higher-level RSI alignment dashboard. The table and trend strip help answer whether the broader RSI stack is supporting, resisting, mixed, or transitioning, while companion tools can provide more detailed oscillator-side structure, pressure, pivots, and divergence context.

Attribution: this script uses SimpleCryptoLife library helpers for timeframe formatting and higher-timeframe stabilization. Some color-engine concepts, compact transparency-helper style, tiered RSI-style trend-color mapping, and PA-style overbought/oversold triangle concepts were inspired by ideas from SimpleCryptoLife’s open-source Price Action Trend work.

💥Chart examples💥

➖Bullish structure expectation➖

For this setup to continue developing, I want to see price reclaim the purple chart Stack Trend first, then begin working back toward the blue HTF Stack Trend.

The key idea is progression:

Price is still trading below both Stack Trend references, so the broader RSI stack is not fully supportive yet. A stronger bullish shift would start with price reclaiming the faster chart-side Stack Trend, then holding above it while the HTF Stack Trend begins to flatten or move underneath price.

What I’m watching:

• Price reclaiming the purple Stack Trend
• Purple Stack Trend turning back into support
• Yellow Stack Trend / envelope behavior improving underneath price
• Blue HTF Stack Trend flattening or moving below price
• Price holding above the prior local structure zone

Until that happens, rallies into the purple/blue Stack Trend area are still tests of resistance, not confirmed bullish structure.
https://www.tradingview.com/x/7ydakDV5/

➖Follow up to the above chart (Bullish structure follow-through)➖

This is the progression we wanted to see from the prior setup. Earlier, price was still below both the chart Stack Trend and the HTF Stack Trend, so the bullish structure was only an expectation — not confirmation yet. Now price has started to work back into the Stack Trend zone. The short-term RSI rows are strengthening, the bottom Stack Bias strip is shifting back into warmer pressure, and price is pushing into the same area that previously needed to be reclaimed.

The key improvement:

Price is no longer simply fading below the Stack Trend structure. It is actively testing the trail/envelope area from underneath and beginning to show the early signs of a bullish reclaim attempt.

What still matters next:

Price needs to hold above the faster chart-side Stack Trend and continue working toward the blue HTF Stack Trend. If that area flips from resistance into support, the bullish structure becomes much cleaner.

Until then, this is a bullish attempt in progress — stronger than the prior chart, but still needing confirmation above the broader HTF Stack Trend zone.
https://www.tradingview.com/x/zpoYlOdj/

➖Repeated Stack Trend failure pattern➖

Price repeatedly loses the faster yellow/chart Stack Trend, then attempts to recover back into the purple/blue Stack Trend zone.

When price cannot reclaim that upper Stack Trend structure, the purple trail begins acting like resistance and price fades back underneath it.

The key read is progression: yellow weakness first, then failed reclaim into purple/blue resistance, followed by bearish continuation if price cannot push back above the broader Stack Trend stack.
https://www.tradingview.com/x/p2hPBCRK/

➖Bullish Stack Trend support structure➖

This is the stronger version of the bullish reclaim pattern. Price first works above the faster chart Stack Trend, then the trail begins holding underneath price instead of acting as resistance. As the move expands, the broader blue HTF Stack Trend also lifts below price, giving the rally higher-timeframe support.

The key read:

Yellow/chart Stack Trend supports first, then the HTF Stack Trend confirms underneath. When price holds above both, the RSI stack structure shifts from recovery attempt into stronger bullish continuation.
https://www.tradingview.com/x/S8VWOZPE/

➖Bearish Stack Trend rejection➖

Price attempted to recover back into the chart Stack Trend, but the broader blue HTF Stack Trend stayed overhead the entire time.

That kept the move capped. Once price failed to reclaim and hold above the purple trail, the Stack Trend structure shifted back into resistance and price faded lower.

The key read:

A bounce into the chart trail is not enough by itself. If the HTF Stack Trend remains above price, the broader RSI stack can still act like overhead resistance.
https://www.tradingview.com/x/4t5lRPeC/

➖MTF Stack Bias Trend Strip➖

Yellow/orange shows stronger bullish stack pressure, purple shows stronger bearish stack pressure, and muted/gray transition areas show the stack moving through mixed conditions.

The key read:

The strip gives a quick visual summary of the broader RSI environment underneath price — making it easier to see when the market is trading with bullish pressure, bearish pressure, or shifting between regimes.
https://www.tradingview.com/x/X5p8NAWu/
https://www.tradingview.com/x/ndg98sWV/
https://www.tradingview.com/x/uU3BRUp0/

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MYNAMEISBRANDON

//@version=6
indicator("RSI MTF Dashboard + RSI/ATR-Based Volatility Zones", "RSI MTF", overlay=true, dynamic_requests=true, max_bars_back=5000, calc_bars_count=1500)

// ==============================================================================
//  RSI MTF Dashboard + RSI-Based Volatility Zones
//  Author: © 𝕄𝕐ℕ𝔸𝕄𝔼𝕀𝕊𝔹ℝ𝔸ℕ𝔻𝕆ℕ
//  License: Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ==============================================================================
//
// Overview:
//     RSI MTF (Multi-timerame) Dashboard + RSI-Based Volatility Zones is a compact multi-timeframe RSI
//     dashboard and price-chart context tool built around timeframe-native RSI,
//     RSI moving-average alignment, live bar timers, a full-stack RSI bias
//     engine, volatility-adjusted chart-side Stack Trend zones, and a
//     bottom-pinned stack-bias trend strip.
//
//     The script includes:
//     • multi-timeframe RSI rows from 1m through monthly
//     • Current RSI, Cur vs Prev RSI, RSI SMA 20, and RSI SMA 50 table columns
//     • SMA slope arrows for the RSI moving-average columns
//     • lower-timeframe and higher-timeframe RSI averages in the table header
//     • hardcoded extended-hours data handling for non-crypto symbols
//     • optional RSI-colored price candles using barcolor() or plotcandle()
//     • independent candle body, wick, and border transparency controls
//     • user-facing bull/bear table colors for comparison columns
//     • realtime last-bar table updates
//     • MTF RSI Stack Trend on the price chart
//     • Auto / Manual Stack Trend price-basis length selection
//     • optional higher-timeframe Stack Trend plot
//     • MTF RSI Stack Trend ATR Envelope using chart/HTF Stack Trend midpoint logic
//     • bottom-pinned MTF Stack Bias trend strip with multi-stop gradient coloring
//     • optional Bull/Bear markers using a PA-style adaptive OB/OS engine
//     • optional Stack-Confirmed marker filtering
//
// Notes:
//     • The previous visible Prev RSI column has been removed.
//     • Previous RSI is still calculated internally so Cur vs Prev RSI can compare
//       current RSI against the prior RSI value.
//     • The MTF RSI Stack Trend scores each enabled timeframe row using:
//          Current RSI regime
//          Cur vs Prev RSI
//          RSI vs SMA 20
//          RSI vs SMA 50
//     • The Stack Trend projects the combined RSI table bias onto price as a
//       volatility-adjusted support/resistance-style trend line.
//     • The ATR Envelope expands the Stack Trend into a broader volatility zone
//       using the chart Stack Trend, HTF Stack Trend, or their midpoint as the basis.
//     • The Stack Bias trend strip shows the smoothed MTF Stack Bias at the bottom
//       of the price chart, making it easier to see whether the broader stack is
//       bullish, bearish, mixed, or transitioning.
//     • The trend strip uses a multi-stop gradient so stronger bullish readings
//       can push toward yellow/orange, stronger bearish readings can push toward
//       purple/extreme purple, and mixed readings can remain closer to neutral.
//     • The Bull/Bear markers add localized PA-style exhaustion/pressure markers
//       around price, with an optional filter that only shows signals aligned with
//       the active MTF RSI Stack regime.
//     • Plot visibility controls use Show / Hide with Last N Bars where applicable.
//     • Table rendering updates on the realtime last bar to keep the display live.
//     • Object-based label systems are intentionally excluded.
//
// Reference / Attribution:
//
//     This script uses SimpleCryptoLife library helpers for timeframe formatting
//     and higher-timeframe stabilization:
//
//     • SimpleCryptoLife/LibraryTimeframeHelper/1
//       Used to prettify chart timeframe text in the table header.
//
//     • SimpleCryptoLife/HighTimeframeSampling/4
//       Used to stabilize the higher-timeframe Stack Trail stream for the
//       chart/HTF midpoint envelope.
//
//     Some color-engine concepts, compact transparency-helper style,
//     tiered RSI-style trend-color mapping, and PA-style overbought/oversold
//     marker concepts were inspired by ideas from SimpleCryptoLife's
//     open-source "Price Action Trend" script:
//     https://www.tradingview.com/v/ll7Wabyv/
//
// Companion Workflow:
//
//     RSI MTF Dashboard + RSI-Based Volatility Zones can be used alongside oscillator,
//     pressure, pivot-structure, and divergence tools as a higher-level RSI
//     alignment dashboard.
//
//     The relationship is simple:
//     • This script focuses on timeframe-stack alignment, table organization,
//       RSI moving-average context, chart-side stack bias, volatility zones,
//       stack-bias transition context, and localized Bull/Bear pressure markers.
//     • RSI oscillator and divergence tools focus more directly on oscillator
//       pressure, pivots, structure, and divergence events.
//
//     Used together, the table and trend strip help answer whether the broader
//     RSI timeframe stack is supporting, resisting, mixed, or transitioning,
//     while other tools provide the more detailed oscillator-side structure.
//
//     This is intended as a confluence and organization tool, not a standalone
//     buy/sell signal system.
// ==============================================================================

// ================================================================================
// 🟢 REGION: Core Imports
// ================================================================================
//
// 📌 Purpose:
//     Loads SimpleCryptoLife framework helpers used for timeframe formatting and
//     higher-timeframe trail stabilization.
//
// 🧠 Behavior:
//     • LibraryTimeframeHelper formats chart timeframe text for the table header.
//     • HighTimeframeSampling stabilizes the HTF Stack Trend stream used by the
//       ATR envelope midpoint.
//
// ================================================================================

import SimpleCryptoLife/LibraryTimeframeHelper/1 as TF
import SimpleCryptoLife/HighTimeframeSampling/4 as SCL_HTF

// ================================================================================
// 🔴 END REGION: Core Imports
// ================================================================================

// ================================================================================
// 🟢 REGION: Group Names
// ================================================================================

const string G_HDR              = "RSI — Table Header"
const string G_TBL_DISPLAY      = "RSI — Table Display"
const string G_TBL_ENGINE       = "RSI — Table Engine"
const string G_TBL_COLORS       = "RSI — Table Colors"
const string G_TFS              = "Rows — Timeframes"
const string G_RSI_COLOR        = "RSI Trend Colors"
const string G_CANDLES          = "RSI Trend Candle Overlay"
const string G_STACK_TRAIL      = "MTF RSI Stack Trend"
const string G_STACK_ATR_ENV    = "MTF RSI Stack Trend ATR Envelope"
const string G_STACK_MARKERS    = "MTF RSI Stack Bull/Bear Markers"
const string G_STACK_BIAS_BOXES = "MTF RSI Stack Bias Trend Strip"

// ================================================================================
// 🔴 END REGION: Group Names
// ================================================================================

// ==============================================================================================
// 🟢 REGION: Tooltip Strings
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: Header + Table Tooltips
// ──────────────────────────────────────────────
const string TT_TIMER_MODE =
     "Controls whether the table timer displays remaining/elapsed time or remaining/elapsed percent."

const string TT_TIMER_DIRECTION =
     "Controls whether the timer counts down toward bar close or counts up from bar open."

const string TT_FIXED_WIDTH =
     "Sets a fixed table-cell width for numeric RSI columns.\n\n" +
     "This helps reduce side-to-side shifting when values change."

const string TT_RSI_LEN =
     "RSI length used for every timeframe row and for the optional RSI-colored candle overlay."

const string TT_RSI_SMA_LEN =
     "Length used for the faster RSI moving-average table column."

const string TT_RSI_SMA_LEN_50 =
     "Length used for the slower RSI moving-average table column."

const string TT_SMA_SLOPE_LEN =
     "Lookback used only for the SMA slope arrows shown next to the RSI SMA values.\n\n" +
     "Lower values make the arrows more reactive. Higher values make them smoother."

// ──────────────────────────────────────────────
// 🟦 Subregion: RSI Color Tooltips
// ──────────────────────────────────────────────
const string TT_RSI_COLOR_NEUTRAL_UPPER =
     "Upper edge of the neutral zone used by the RSI color engine.\n\n" +
     "RSI values between the lower and upper neutral thresholds are colored white."

const string TT_RSI_COLOR_NEUTRAL_LOWER =
     "Lower edge of the neutral zone used by the RSI color engine.\n\n" +
     "RSI values between the lower and upper neutral thresholds are colored white."

const string TT_RSI_TREND_TRANSP =
     "Controls transparency for the RSI color engine when used in table cells and candle overlays."

const string TT_RSI_CANDLE_OVERLAY =
     "Colors price candles based on the chart-timeframe RSI level color.\n\n" +
     "Bar Color uses barcolor().\n" +
     "PlotCandles draws a candle overlay.\n" +
     "Off disables the candle overlay."

// ──────────────────────────────────────────────
// 🟦 Subregion: MTF RSI Stack Trend Tooltips
// ──────────────────────────────────────────────
const string TT_STACK_TRAIL_MODE =
     "Controls whether the MTF RSI Stack Trend is shown on the price chart.\n\n" +
     "The trail is built from the enabled timeframe rows in the table. Each row scores Current RSI, Cur vs Prev RSI, RSI vs SMA 20, and RSI vs SMA 50, then combines those scores into one full-stack bias."

const string TT_STACK_TRAIL_LAST_N =
     "Controls how many of the most recent bars show the MTF RSI Stack Trend."

const string TT_STACK_TRAIL_THRESHOLD =
     "Minimum stack-bias percentage required before the trail is treated as bullish or bearish.\n\n" +
     "Lower values make the trail change state more easily.\n" +
     "Higher values require stronger agreement across the enabled timeframe stack."

const string TT_STACK_TRAIL_SMOOTH =
     "Smoothing length applied to the full-stack RSI bias before the trail state is calculated.\n\n" +
     "Higher values make the trail steadier.\n" +
     "Lower values make it more responsive."

const string TT_STACK_TRAIL_BASIS_MODE =
     "Controls how the Stack Trend price-basis length is selected.\n\n" +
     "Auto adapts the EMA basis length by chart timeframe.\n" +
     "Manual uses the fixed length below.\n\n" +
     "Auto Length Map:\n" +
     "• Seconds (<1m): 13\n" +
     "• 1m–3m: 8\n" +
     "• 5m–10m: 13\n" +
     "• 15m–30m: 21\n" +
     "• 1h–2h: 34\n" +
     "• 4h–8h: 48\n" +
     "• Daily: 21\n" +
     "• Weekly: 13\n" +
     "• Monthly: 8"

const string TT_STACK_TRAIL_BASIS_MANUAL =
     "Manual EMA length used as the Stack Trend price basis when Basis Length Mode is set to Manual.\n\n" +
     "Auto Reference Table:\n" +
     "────────────────────────────\n" +
     " • <1m seconds → 13\n" +
     " • 1–3m        → 8\n" +
     " • 5–10m       → 13\n" +
     " • 15–30m      → 21\n" +
     " • 1–2h        → 34\n" +
     " • 4–8h        → 48\n" +
     " • Daily       → 21\n" +
     " • Weekly      → 13\n" +
     " • Monthly     → 8\n" +
     "────────────────────────────"

const string TT_STACK_TRAIL_MULT =
     "Base ATR distance used to place the MTF RSI Stack Trend away from price.\n\n" +
     "The Stack Trend is offset from the EMA price basis by ATR × multiplier.\n\n" +
     "Lower values keep the trend line closer to price and make it more reactive.\n" +
     "Higher values push the trend line farther from price and make it behave more like a wider support/resistance trail.\n\n" +
     "Example:\n" +
     "• 0.75 = tighter / more sensitive\n" +
     "• 1.00 = balanced default\n" +
     "• 1.50 = wider / slower to interact with price"

const string TT_STACK_TRAIL_BOOST =
     "Adaptive ATR expansion added when the MTF RSI stack bias gets stronger.\n\n" +
     "Final trail multiplier = Base ATR Multiplier + (Stack Strength × Stack Strength Boost).\n\n" +
     "Stack Strength is based on the absolute MTF Stack Bias, scaled from 0 to 1.\n\n" +
     "A value of 0 disables adaptive expansion, so the trail only uses the Base ATR Multiplier.\n" +
     "Higher values push the trend farther from price when the timeframe stack is strongly bullish or bearish.\n\n" +
     "Example with Base ATR Multiplier = 1.00 and Stack Strength Boost = 0.75:\n" +
     "• 25% stack strength → 1.1875× ATR\n" +
     "• 50% stack strength → 1.375× ATR\n" +
     "• 100% stack strength → 1.75× ATR"

const string TT_STACK_TRAIL_WIDTH =
     "Controls the line width used by the active bull/bear Stack Trend."

const string TT_STACK_TRAIL_NEUTRAL_WIDTH =
     "Controls the line width used by the neutral/mixed Stack Trend."

// ──────────────────────────────────────────────
// 🟦 Subregion: MTF RSI Stack Trend ATR Envelope Tooltips
// ──────────────────────────────────────────────
const string TT_STACK_ATR_ENV_MODE =
     "Controls whether the MTF RSI Stack Trend ATR Envelope is shown on the price chart.\n\n" +
     "The envelope is built around the Stack Trend system, not a price-average line. It uses the chart Stack Trend, a higher-timeframe Stack Trend, or the midpoint between both."

const string TT_STACK_ATR_ENV_BASIS =
     "Selects the center line used for the envelope.\n\n" +
     "• Stack Trend (Chart): uses the chart-timeframe MTF RSI Stack Trend.\n" +
     "• Stack Trend (HTF): uses the requested higher-timeframe Stack Trend.\n" +
     "• Midpoint: averages the chart Stack Trend and HTF Stack Trend."

const string TT_STACK_ATR_ENV_LAST_N =
     "Controls how many of the most recent bars show the envelope fill."

const string TT_STACK_ATR_ENV_INNER =
     "Inner ATR multiplier used for the hardcoded envelope band fill.\n\n" +
     "Lower values keep the inner band closer to the Stack Trend basis."

const string TT_STACK_ATR_ENV_OUTER =
     "Outer ATR multiplier used for the hardcoded envelope band fill.\n\n" +
     "Higher values expand the outer band farther from the Stack Trend basis."

const string TT_STACK_ATR_ENV_TRANSP =
     "Transparency applied to the envelope fill.\n\n" +
     "0 = solid fill\n" +
     "100 = invisible fill"

const string TT_STACK_ATR_ENV_HTF_PLOT =
     "Controls whether the higher-timeframe MTF Stack Trend is shown on the price chart.\n\n" +
     "This is the HTF trail used by the envelope midpoint calculation. Showing it makes it easier to compare the chart trail, HTF trail, and the envelope relationship."

const string TT_STACK_ATR_ENV_HTF_LAST_N =
     "Controls how many of the most recent bars show the higher-timeframe MTF Stack Trend."

const string TT_STACK_ATR_ENV_HTF_WIDTH =
     "Controls the line width used by the higher-timeframe MTF Stack Trend."

const string TT_STACK_ATR_ENV_HTF_COLOR =
     "Color used by the higher-timeframe MTF Stack Trend plot."

const string TT_STACK_ATR_ENV_HTF_TRANSP =
     "Controls the transparency of the higher-timeframe MTF Stack Trend."

// ──────────────────────────────────────────────
// 🟦 Subregion: MTF RSI Stack Bull/Bear Marker Tooltips
// ──────────────────────────────────────────────
const string TT_STACK_MARKER_MODE =
     "Controls whether the Bull/Bear markers are shown on the price chart.\n\n" +
     "These markers use a Price Action-style overbought/oversold engine built from a short Wilder-style high/low channel and adaptive pivot levels."

const string TT_STACK_MARKER_LENGTH_MODE =
     "Controls whether the Bull/Bear marker engine uses Auto timeframe presets or the manual inputs below.\n\n" +
     "Auto Length Map:\n" +
     "────────────────────────────\n" +
     " • Seconds–5m   → 8 / 18\n" +
     " • >5m–<30m     → 6 / 14\n" +
     " • 30m–<4h      → 5 / 12\n" +
     " • 4h–1D        → 4 / 10\n" +
     " • >1D+         → 3 / 8\n" +
     "────────────────────────────"

const string TT_STACK_MARKER_LEN =
     "Manual short Wilder-style channel lookback used to build the raw Bull/Bear marker engine.\n\n" +
     "This input is only used when MARKER Length Mode is set to Manual."

const string TT_STACK_MARKER_ADAPT =
     "Manual adaptive smoothing length used for the dynamic Bull/Bear trigger levels.\n\n" +
     "This input is only used when MARKER Length Mode is set to Manual."

const string TT_STACK_MARKER_LAST_N =
     "Controls how many of the most recent bars can show Bull/Bear markers."

const string TT_STACK_MARKER_FILTER =
     "Controls whether markers require confirmation from the MTF RSI Stack Trend.\n\n" +
     "All Signals shows the raw PA-style marker engine.\n" +
     "Stack-Confirmed only shows bullish markers during bullish stack regimes and bearish markers during bearish stack regimes."

// ──────────────────────────────────────────────
// 🟦 Subregion: MTF RSI Stack Bias Box Tooltips
// ──────────────────────────────────────────────
const string TT_STACK_BIAS_BOX_MODE =
     "Controls whether the MTF RSI Stack Bias Trend Strip is shown at the bottom of the price chart.\n\n" +
     "The strip visualizes the current MTF Stack Bias value as a bottom-pinned gradient."

const string TT_STACK_BIAS_BOX_LAST_N =
     "Controls how many of the most recent bars show the MTF RSI Stack Bias Trend Strip."

const string TT_STACK_BIAS_BOX_SIZE =
     "Controls the visual size of the bottom-pinned Stack Bias Trend Strip."

// ==============================================================================================
// 🔴 END REGION: Tooltip Strings
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: Helpers
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: String + Math Helpers
// ──────────────────────────────────────────────
s(_thing, string _format=na) =>
    str.tostring(_thing, _format)

f_safeDiv(float _num, float _den, float _fallback) =>
    na(_num) or na(_den) or math.abs(_den) < 1e-10 ? _fallback : _num / _den

f_stripLead0(string _s) =>
    int n = str.length(_s)
    bool neg0 = n >= 3 and str.substring(_s, 0, 3) == "-0."
    bool pos0 = n >= 2 and str.substring(_s, 0, 2) == "0."
    neg0 ? str.replace(_s, "-0.", "-.") :
     pos0 ? str.replace(_s, "0.",  ".")  : _s

f_fmtSigned2(float _v) =>
    if na(_v)
        "n/a"
    else
        string sAbs = str.format("{0,number,0.##}", math.abs(_v))
        sAbs := (_v != 0 and math.abs(_v) < 1) ? f_stripLead0(sAbs) : sAbs
        _v > 0 ? "+" + sAbs :
         _v < 0 ? "-" + sAbs :
                  "0"

f_formatSecondsToTime(float _secsIn) =>
    var int _secondsInAnHour = 60 * 60
    var int _secondsInADay  = 60 * 60 * 24
    float _secsLeft = _secsIn
    float _days = math.floor(_secsIn / _secondsInADay)
    if _days > 0
        _secsLeft := _secsLeft - (_days * _secondsInADay)
    float _hours = math.floor(_secsLeft / _secondsInAnHour)
    if _hours > 0
        _secsLeft := _secsLeft - (_hours * _secondsInAnHour)
    float _mins = math.floor(_secsLeft / 60)
    if _mins > 0
        _secsLeft := _secsLeft - (_mins * 60)

    string _daysStr  = _days > 0 ? s(_days) + "d " : ""
    string _hoursStr = _hours > 0 ? s(_hours) + "h " : ""
    string _minsStr  = _days > 0 and _hours > 0 ? "" : _mins > 0 ? s(_mins) + "m " : ""
    string _secsStr  = _hours > 0 and _mins > 0 ? "" : _secsLeft > 0 ? s(_secsLeft) + "s " : ""
    _secsIn < 0 ? "" : _daysStr + _hoursStr + _minsStr + _secsStr

f_slopeArrow(float _sl, float _eps) =>
    na(_sl) ? "" :
     _sl > _eps  ? " ↗" :
     _sl < -_eps ? " ↘" :
                   " •"

// ──────────────────────────────────────────────
// 🟦 Subregion: Color Helpers
// ──────────────────────────────────────────────
method t(color _c, int _tr) =>
    color.new(_c, _tr)

f_contrastText(color _bg) =>
    float r = color.r(_bg)
    float g = color.g(_bg)
    float b = color.b(_bg)
    float lum = (0.299 * r + 0.587 * g + 0.114 * b)
    lum > 140 ? #000000 : color.white

f_rsiLevelCol(float _rsi, float _neutralUpper, float _neutralLower, int _tr) =>
    if na(_rsi)
        color.new(color.gray, 85)
    else if _rsi >= _neutralLower and _rsi <= _neutralUpper
        color.white.t(_tr)
    else if _rsi > _neutralUpper
        _rsi >= 90 ? color.rgb(255, 102, 0).t(_tr) :
         _rsi >= 80 ? color.rgb(255, 251, 0).t(_tr) :
         _rsi >= 70 ? #37af00.t(_tr) :
         _rsi >= 60 ? color.teal.t(_tr) :
         color.aqua.t(_tr)
    else
        _rsi <= 10 ? #8700b1.t(_tr) :
         _rsi <= 20 ? color.rgb(220, 5, 248).t(_tr) :
         _rsi <= 30 ? #ec0000.t(_tr) :
         _rsi <= 40 ? color.rgb(255, 101, 101).t(_tr) :
         color.rgb(95, 95, 95).t(_tr)

// ==============================================================================================
// 🔴 END REGION: Helpers
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: Inputs
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: Header Inputs
// ──────────────────────────────────────────────
string in_headingMode = input.string(defval="Show", title="Header 1", options=["Show", "Hide"], group=G_HDR)
bool in_showHeading = in_headingMode == "Show"

string in_headingText = input.string(defval="TRADING VIEW ➡ MYNAMEISBRANDON", title="  ↳ Header 1 Text", group=G_HDR, active=in_showHeading)

string in_subheadingMode = input.string(defval="Hide", title="Header 2", options=["Show", "Hide"], group=G_HDR)
bool in_showSubheading = in_subheadingMode == "Show"

string in_subheadingText = input.string(defval="RSI MTF Dashboard + RSI-Based Volatility Zones", title="  ↳ Header 2 Text", group=G_HDR, active=in_showSubheading)

bool in_showSession = true

// ──────────────────────────────────────────────
// 🟦 Subregion: Table Display Inputs
// ──────────────────────────────────────────────
string in_tablePosition = input.string(defval="Bottom Right", title="Table Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=G_TBL_DISPLAY)
string in_tableTextSize = input.string(defval="Normal", title="Table Size", options=["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], group=G_TBL_DISPLAY)
int in_fixedWidthCell = input.int(defval=3, title="Numeric Column Width", minval=1, maxval=30, group=G_TBL_DISPLAY, tooltip=TT_FIXED_WIDTH)

string in_timerMode = input.string(defval="Time", title="Bar Timer Mode", options=["Time", "Percent"], group=G_TBL_DISPLAY, tooltip=TT_TIMER_MODE)
string in_timerDirection = input.string(defval="Count Down", title="  ↳ Timer Direction", options=["Count Down", "Count Up"], group=G_TBL_DISPLAY, tooltip=TT_TIMER_DIRECTION)

tableTextSize = switch in_tableTextSize
    "Auto"   => size.auto
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge

tablePosition = switch in_tablePosition
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    "Bottom Right"  => position.bottom_right

// ──────────────────────────────────────────────
// 🟦 Subregion: Table Engine Inputs
// ──────────────────────────────────────────────
int in_rsiLen = input.int(defval=14, title="RSI Length", minval=1, maxval=200, group=G_TBL_ENGINE, tooltip=TT_RSI_LEN)
int in_rsiSmaLen = input.int(defval=20, title="RSI SMA Length 1", minval=1, maxval=200, group=G_TBL_ENGINE, tooltip=TT_RSI_SMA_LEN)
int in_rsiSmaLen50 = input.int(defval=50, title="RSI SMA Length 2", minval=1, maxval=200, group=G_TBL_ENGINE, tooltip=TT_RSI_SMA_LEN_50)
int in_smaSlopeLen = input.int(defval=2, title="SMA Arrow Slope Lookback", minval=2, maxval=200, group=G_TBL_ENGINE, tooltip=TT_SMA_SLOPE_LEN)

// ──────────────────────────────────────────────
// 🟦 Subregion: Table Color Inputs
// ──────────────────────────────────────────────
color in_tableBullCellColor = input.color(defval=color.yellow, title="Bull Cell Color", group=G_TBL_COLORS)
color in_tableBullTextColor = input.color(defval=#000000, title="  ↳ Bull Text Color", group=G_TBL_COLORS)

color in_tableBearCellColor = input.color(defval=color.purple, title="Bear Cell Color", group=G_TBL_COLORS)
color in_tableBearTextColor = input.color(defval=color.white, title="  ↳ Bear Text Color", group=G_TBL_COLORS)

// ──────────────────────────────────────────────
// 🟦 Subregion: Timeframe Row Inputs
// ──────────────────────────────────────────────
bool in_use_1m  = input.bool(defval=true, title="1m", group=G_TFS, inline="tf1")
bool in_use_3m  = input.bool(defval=true, title="3m", group=G_TFS, inline="tf1")
bool in_use_5m  = input.bool(defval=true, title="5m", group=G_TFS, inline="tf1")
bool in_use_10m = input.bool(defval=true, title="10m", group=G_TFS, inline="tf1")
bool in_use_15m = input.bool(defval=true, title="15m", group=G_TFS, inline="tf1")
bool in_use_30m = input.bool(defval=true, title="30m", group=G_TFS, inline="tf1")

bool in_use_1h = input.bool(defval=true, title="1h", group=G_TFS, inline="tf2")
bool in_use_2h = input.bool(defval=true, title="2h", group=G_TFS, inline="tf2")
bool in_use_4h = input.bool(defval=true, title="4h", group=G_TFS, inline="tf2")
bool in_use_8h = input.bool(defval=true, title="8h", group=G_TFS, inline="tf2")
bool in_use_1D = input.bool(defval=true, title="1D", group=G_TFS, inline="tf2")
bool in_use_W  = input.bool(defval=true, title="W", group=G_TFS, inline="tf2")
bool in_use_M  = input.bool(defval=true, title="M", group=G_TFS, inline="tf2")

// ──────────────────────────────────────────────
// 🟦 Subregion: RSI Color Inputs
// ──────────────────────────────────────────────
float in_rsiNeutralUpper = input.float(defval=51.5, title="RSI Upper Neutral Threshold", minval=50.0, maxval=55.0, step=0.1, group=G_RSI_COLOR, tooltip=TT_RSI_COLOR_NEUTRAL_UPPER)
float in_rsiNeutralLower = input.float(defval=48.5, title="RSI Lower Neutral Threshold", minval=45.0, maxval=50.0, step=0.1, group=G_RSI_COLOR, tooltip=TT_RSI_COLOR_NEUTRAL_LOWER)
int in_rsiTrendTransp = input.int(defval=0, title="RSI Trend Color Transparency", minval=0, maxval=100, group=G_RSI_COLOR, tooltip=TT_RSI_TREND_TRANSP)

// ──────────────────────────────────────────────
// 🟦 Subregion: Candle Overlay Inputs
// ──────────────────────────────────────────────
string in_rsiCandleOverlayMode = input.string(defval="PlotCandles", title="RSI Trend Candle Overlay", options=["Bar Color", "PlotCandles", "Off"], group=G_CANDLES, tooltip=TT_RSI_CANDLE_OVERLAY)

int in_rsiCandleBodyTransp = input.int(defval=80, title="Body Transparency", minval=0, maxval=100, group=G_CANDLES)
int in_rsiCandleWickTransp = input.int(defval=25, title="Wick Transparency", minval=0, maxval=100, group=G_CANDLES)
int in_rsiCandleBorderTransp = input.int(defval=0, title="Border Transparency", minval=0, maxval=100, group=G_CANDLES)

// ──────────────────────────────────────────────
// 🟦 Subregion: MTF RSI Stack Trend Inputs
// ──────────────────────────────────────────────
string in_stackTrailMode = input.string(defval="Show", title="MTF RSI Stack Trend", options=["Show", "Hide"], group=G_STACK_TRAIL, tooltip=TT_STACK_TRAIL_MODE)
bool in_showStackTrail = in_stackTrailMode == "Show"

int in_stackTrailLastNBars = input.int(defval=144, minval=1, maxval=1500, title="  ↳ Stack Trend Last N Bars", group=G_STACK_TRAIL, tooltip=TT_STACK_TRAIL_LAST_N, active=in_showStackTrail)

string in_stackTrailBasisLenMode = input.string(defval="Auto", title="  ↳ Price Basis Length Mode", options=["Auto", "Manual"], group=G_STACK_TRAIL, tooltip=TT_STACK_TRAIL_BASIS_MODE, active=in_showStackTrail)
int in_stackTrailBasisLenManual = input.int(defval=21, minval=1, maxval=200, title="    ↳ Manual Price Basis Length", group=G_STACK_TRAIL, tooltip=TT_STACK_TRAIL_BASIS_MANUAL, active=in_showStackTrail and in_stackTrailBasisLenMode == "Manual")

float in_stackTrailThreshold = input.float(defval=25.0, minval=0.0, maxval=100.0, step=1.0, title="  ↳ Stack Bias Threshold", group=G_STACK_TRAIL, tooltip=TT_STACK_TRAIL_THRESHOLD, active=in_showStackTrail)
int in_stackTrailSmoothLen = input.int(defval=5, minval=1, maxval=100, title="  ↳ Stack Bias Smoothing", group=G_STACK_TRAIL, tooltip=TT_STACK_TRAIL_SMOOTH, active=in_showStackTrail)

const int STACK_TRAIL_ATR_LEN = 14

float in_stackTrailBaseMult = input.float(defval=1.00, minval=0.05, step=0.05, title="  ↳ Base ATR Multiplier", group=G_STACK_TRAIL, tooltip=TT_STACK_TRAIL_MULT, active=in_showStackTrail)
float in_stackTrailStrengthBoost = input.float(defval=0.75, minval=0.0, step=0.05, title="  ↳ Stack Strength Boost", group=G_STACK_TRAIL, tooltip=TT_STACK_TRAIL_BOOST, active=in_showStackTrail)

int in_stackTrailWidth = input.int(defval=3, minval=1, maxval=5, title="Active Trail Width", group=G_STACK_TRAIL, tooltip=TT_STACK_TRAIL_WIDTH, active=in_showStackTrail)
int in_stackTrailNeutralWidth = input.int(defval=1, minval=1, maxval=5, title="Neutral Trail Width", group=G_STACK_TRAIL, tooltip=TT_STACK_TRAIL_NEUTRAL_WIDTH, active=in_showStackTrail)

color in_stackTrailBullColor = input.color(defval=color.yellow, title="Bull Stack Trend Color", group=G_STACK_TRAIL, active=in_showStackTrail)
color in_stackTrailBearColor = input.color(defval=color.purple, title="Bear Stack Trend Color", group=G_STACK_TRAIL, active=in_showStackTrail)
color in_stackTrailNeutralColor = input.color(defval=color.gray, title="Neutral Stack Trend Color", group=G_STACK_TRAIL, active=in_showStackTrail)

// ──────────────────────────────────────────────
// 🟦 Subregion: MTF RSI Stack Trend ATR Envelope Inputs
// ──────────────────────────────────────────────
string in_stackAtrEnvMode = input.string(defval="Show", title="MTF Stack ATR Envelope", options=["Show", "Hide"], group=G_STACK_ATR_ENV, tooltip=TT_STACK_ATR_ENV_MODE)
bool in_showStackAtrEnv = in_stackAtrEnvMode == "Show"

string in_stackAtrEnvBasisMode = input.string(defval="Midpoint (Chart↔HTF Trail)", title="Envelope Basis", options=["Stack Trend (Chart)", "Stack Trend (HTF)", "Midpoint (Chart↔HTF Trail)"], group=G_STACK_ATR_ENV, tooltip=TT_STACK_ATR_ENV_BASIS, active=in_showStackAtrEnv)

int in_stackAtrEnvLastNBars = input.int(defval=144, minval=1, maxval=5000, title="  ↳ Envelope Last N Bars", group=G_STACK_ATR_ENV, tooltip=TT_STACK_ATR_ENV_LAST_N, active=in_showStackAtrEnv)

string in_stackAtrEnvHtfPlotMode = input.string(defval="Show", title="HTF Stack Trend Plot", options=["Show", "Hide"], group=G_STACK_ATR_ENV, tooltip=TT_STACK_ATR_ENV_HTF_PLOT)
bool in_showStackAtrEnvHtfPlot = in_stackAtrEnvHtfPlotMode == "Show"

int in_stackAtrEnvHtfLastNBars = input.int(defval=144, minval=1, maxval=5000, title="  ↳ HTF Trail Last N Bars", group=G_STACK_ATR_ENV, tooltip=TT_STACK_ATR_ENV_HTF_LAST_N, active=in_showStackAtrEnvHtfPlot)
int in_stackAtrEnvHtfPlotWidth = input.int(defval=2, minval=1, maxval=5, title=" HTF Trail Width", group=G_STACK_ATR_ENV, tooltip=TT_STACK_ATR_ENV_HTF_WIDTH, active=in_showStackAtrEnvHtfPlot)
int in_stackAtrEnvHtfPlotTransp = input.int(defval=0, minval=0, maxval=100, title="HTF Trail Transparency", group=G_STACK_ATR_ENV, tooltip=TT_STACK_ATR_ENV_HTF_TRANSP, active=in_showStackAtrEnvHtfPlot)
color in_stackAtrEnvHtfPlotBaseColor = input.color(defval=color.blue, title="HTF Trail Color", group=G_STACK_ATR_ENV, tooltip=TT_STACK_ATR_ENV_HTF_COLOR, active=in_showStackAtrEnvHtfPlot)

const int STACK_ATR_ENV_ATR_LEN = 14

float in_stackAtrEnvInnerMult = input.float(defval=1.2, minval=0.0, step=0.1, title="Inner ATR Mult", group=G_STACK_ATR_ENV, tooltip=TT_STACK_ATR_ENV_INNER, active=in_showStackAtrEnv)
float in_stackAtrEnvOuterMult = input.float(defval=1.5, minval=0.0, step=0.1, title="Outer ATR Mult", group=G_STACK_ATR_ENV, tooltip=TT_STACK_ATR_ENV_OUTER, active=in_showStackAtrEnv)

int in_stackAtrEnvFillTransp = input.int(defval=85, minval=0, maxval=100, title="Fill Transparency", group=G_STACK_ATR_ENV, tooltip=TT_STACK_ATR_ENV_TRANSP, active=in_showStackAtrEnv)

// ──────────────────────────────────────────────
// 🟦 Subregion: MTF RSI Stack Bull/Bear Marker Inputs
// ──────────────────────────────────────────────
string in_stackMarkerMode = input.string(defval="Show", title="Bull/Bear Markers", options=["Show", "Hide"], group=G_STACK_MARKERS , tooltip=TT_STACK_MARKER_MODE)
bool in_showStackMarkers = in_stackMarkerMode == "Show"

string in_stackMarkerFilterMode = input.string(defval="All Signals", title="  ↳ Signal Filter", options=["All Signals", "Stack-Confirmed"], group=G_STACK_MARKERS , tooltip=TT_STACK_MARKER_FILTER, active=in_showStackMarkers)

int in_stackMarkerLastNBars = input.int(defval=144, minval=1, maxval=5000, title="  ↳ Marker Last N Bars", group=G_STACK_MARKERS , tooltip=TT_STACK_MARKER_LAST_N, active=in_showStackMarkers)

string in_stackMarkerLengthMode = input.string(defval="Auto", title="  ↳ Marker Length Mode", options=["Auto", "Manual"], group=G_STACK_MARKERS , tooltip=TT_STACK_MARKER_LENGTH_MODE, active=in_showStackMarkers)

int in_stackMarkerLenManual = input.int(defval=5, minval=1, maxval=200, title="    ↳ Manual Marker Lookback", group=G_STACK_MARKERS , tooltip=TT_STACK_MARKER_LEN, active=in_showStackMarkers and in_stackMarkerLengthMode == "Manual")

int in_stackMarkerAdaptLenManual = input.int(defval=12, minval=2, maxval=200, title="    ↳ Manual Adaptive Length", group=G_STACK_MARKERS , tooltip=TT_STACK_MARKER_ADAPT, active=in_showStackMarkers and in_stackMarkerLengthMode == "Manual")

color in_stackMarkerBullColor = input.color(defval=color.lime, title="Bull Marker Color", group=G_STACK_MARKERS , active=in_showStackMarkers)
color in_stackMarkerBearColor = input.color(defval=color.red, title="Bear Marker Color", group=G_STACK_MARKERS , active=in_showStackMarkers)

// ──────────────────────────────────────────────
// 🟦 Subregion: MTF RSI Stack Bias Box Inputs
// ──────────────────────────────────────────────
string in_stackBiasBoxMode = input.string(defval="Show", title="MTF Stack Bias Trend Strip", options=["Show", "Hide"], group=G_STACK_BIAS_BOXES, tooltip=TT_STACK_BIAS_BOX_MODE)
bool in_showStackBiasBoxes = in_stackBiasBoxMode == "Show"

int in_stackBiasBoxLastNBars = input.int(defval=144, minval=1, maxval=5000, title="  ↳ Trend Strip Last N Bars", group=G_STACK_BIAS_BOXES, tooltip=TT_STACK_BIAS_BOX_LAST_N, active=in_showStackBiasBoxes)

string in_stackBiasBoxSize = input.string(defval="Small", title="  ↳ Trend Strip Size", options=["Tiny", "Small", "Normal"], group=G_STACK_BIAS_BOXES, tooltip=TT_STACK_BIAS_BOX_SIZE, active=in_showStackBiasBoxes)

// int in_stackBiasBoxTransp = input.int(defval=0, minval=0, maxval=100, title="Trend Strip Transparency", group=G_STACK_BIAS_BOXES, tooltip=TT_STACK_BIAS_BOX_TRANSP, active=in_showStackBiasBoxes)
color in_stackBiasBoxBullColor = input.color(defval=color.yellow, title="Bull Bias Box Color", group=G_STACK_BIAS_BOXES, active=in_showStackBiasBoxes)
color in_stackBiasBoxBearColor = input.color(defval=color.purple, title="Bear Bias Box Color", group=G_STACK_BIAS_BOXES, active=in_showStackBiasBoxes)
color in_stackBiasBoxNeutralColor = input.color(defval=color.gray, title="Neutral Bias Box Color", group=G_STACK_BIAS_BOXES, active=in_showStackBiasBoxes)
color in_stackBiasBoxBullExtremeColor = input.color(defval=#ff6f00, title="Extreme Bull Bias Box Color", group=G_STACK_BIAS_BOXES, active=in_showStackBiasBoxes)
color in_stackBiasBoxBearExtremeColor = input.color(defval=color.rgb(120, 0, 170), title="Extreme Bear Bias Box Color", group=G_STACK_BIAS_BOXES, active=in_showStackBiasBoxes)

// ==============================================================================================
// 🔴 END REGION: Inputs
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: Refresh State
// ==============================================================================================
//
// 📌 Purpose:
//     Updates table-side calculations on the last bar.
//
// 🧠 Behavior:
//     • Historical bars do not repaint the table.
//     • The realtime last bar updates every tick.
//     • Refresh cadence is intentionally hardcoded to keep the table fully live.
//
// ==============================================================================================

bool doCompute = barstate.islast

// ==============================================================================================
// 🔴 END REGION: Refresh State
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: RSI Trend Candle Overlay
// ==============================================================================================
//
// 📌 Purpose:
//     Colors price candles from the chart-timeframe RSI level color engine.
//
// 🧠 Behavior:
//     • Bar Color mode uses barcolor().
//     • PlotCandles mode draws a candle overlay.
//     • Off disables both modes.
//
// ==============================================================================================

float rsiTrend = ta.rsi(close, in_rsiLen)

color rsiTrendBaseColor =
     f_rsiLevelCol(rsiTrend, in_rsiNeutralUpper, in_rsiNeutralLower, 0)

color rsiTrendCandleBody =
     color.new(rsiTrendBaseColor, in_rsiCandleBodyTransp)

color rsiTrendCandleWick =
     color.new(rsiTrendBaseColor, in_rsiCandleWickTransp)

color rsiTrendCandleBorder =
     color.new(rsiTrendBaseColor, in_rsiCandleBorderTransp)

barcolor(
     in_rsiCandleOverlayMode == "Bar Color" ? rsiTrendCandleBody : na,
     title="RSI Trend Bar Color")

plotcandle(
     open,
     high,
     low,
     close,
     color=in_rsiCandleOverlayMode == "PlotCandles" ? rsiTrendCandleBody : na,
     wickcolor=in_rsiCandleOverlayMode == "PlotCandles" ? rsiTrendCandleWick : na,
     bordercolor=in_rsiCandleOverlayMode == "PlotCandles" ? rsiTrendCandleBorder : na,
     title="RSI Trend Candle Overlay")

// ==============================================================================================
// 🔴 END REGION: RSI Trend Candle Overlay
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: Symbol + Session State
// ==============================================================================================
//
// 📌 Purpose:
//     Selects the data stream used for timeframe rows.
//
// 🧠 Behavior:
//     • Crypto uses the normal 24h stream.
//     • Non-crypto symbols use the extended-hours stream.
//     • Trading Hours is intentionally hardcoded to keep the table simple.
//
// ==============================================================================================

bool isCrypto =
     syminfo.type == "crypto"

simple string symEXT =
     ticker.new(
          prefix=syminfo.prefix,
          ticker=syminfo.ticker,
          session=session.extended)

simple string standardisedSymbol =
     isCrypto
     ? syminfo.tickerid
     : symEXT

f_chartSessionNow() =>
    if isCrypto
        "24h"
    else if not timeframe.isintraday
        "—"
    else
        "EXT"

// ==============================================================================================
// 🔴 END REGION: Symbol + Session State
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: MTF RSI Data Engine
// ==============================================================================================
//
// 📌 Purpose:
//     Requests timeframe-native RSI data and stores each row in preallocated arrays.
//
// 🧠 Behavior:
//     • Current RSI drives the main table color.
//     • Previous RSI is kept internally for the Δ column only.
//     • RSI SMA 20 and RSI SMA 50 provide slower context columns.
//     • Timer fields are calculated on the last bar using the requested timeframe's
//       native time/time_close window.
//
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: Row Schema Constants
// ──────────────────────────────────────────────
const int IDX_RSI_CUR       = 0
const int IDX_RSI_PREV      = 1
const int IDX_RSI_SMA       = 2
const int IDX_TIME          = 3
const int IDX_TIME_CLOSE    = 4
const int IDX_TIMER_SECS    = 5
const int IDX_TIMER_PCT     = 6
const int IDX_RSI_SMA50     = 7
const int IDX_SMA20_SLOPE   = 8
const int IDX_SMA50_SLOPE   = 9
const int ALL_FIELDS        = 10

// ──────────────────────────────────────────────
// 🟦 Subregion: Security Expression
// ──────────────────────────────────────────────
f_secExprRsi(simple int _len, simple int _smaLen20, simple int _smaLen50, simple int _slopeLen) =>
    float _r = ta.rsi(close, _len)
    float _p = _r[1]
    float _s20 = ta.sma(_r, _smaLen20)
    float _s50 = ta.sma(_r, _smaLen50)

    int _lb = math.max(_slopeLen, 2)

    float _lr20_0 = ta.linreg(_s20, _lb, 0)
    float _lr20_1 = ta.linreg(_s20, _lb, 1)
    float _sl20 = _lr20_0 - _lr20_1

    float _lr50_0 = ta.linreg(_s50, _lb, 0)
    float _lr50_1 = ta.linreg(_s50, _lb, 1)
    float _sl50 = _lr50_0 - _lr50_1

    [_r, _p, _s20, _s50, _sl20, _sl50, time, time_close]

f_packInto(float[] _a, float _rCur, float _rPrev, float _rSma20, float _rSma50, float _sl20, float _sl50, int _t0, int _t1) =>
    array.set(_a, IDX_RSI_CUR, _rCur)
    array.set(_a, IDX_RSI_PREV, _rPrev)
    array.set(_a, IDX_RSI_SMA, _rSma20)
    array.set(_a, IDX_TIME, float(_t0))
    array.set(_a, IDX_TIME_CLOSE, float(_t1))
    array.set(_a, IDX_RSI_SMA50, _rSma50)
    array.set(_a, IDX_SMA20_SLOPE, _sl20)
    array.set(_a, IDX_SMA50_SLOPE, _sl50)
    _a

f_sec_into(float[] _a, simple string _tf, simple int _rsiLen, simple int _rsiSmaLen20, simple int _rsiSmaLen50) =>
    [rCur, rPrev, rSma20, rSma50, sl20, sl50, t0, t1] = request.security(symbol=standardisedSymbol, timeframe=_tf, expression=f_secExprRsi(_rsiLen, _rsiSmaLen20, _rsiSmaLen50, in_smaSlopeLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
    f_packInto(_a, rCur, rPrev, rSma20, rSma50, sl20, sl50, t0, t1)

f_timerInto(float[] _a, int _nowMs) =>
    float _t0 = array.get(_a, IDX_TIME)
    float _t1 = array.get(_a, IDX_TIME_CLOSE)

    if na(_t0) or na(_t1)
        _a
    else
        float _barMs = math.max(_t1 - _t0, 1.0)
        float _elapsedMs = math.min(_barMs, math.max((_nowMs - _t0), 0.0))
        float _toCloseMs = math.max((_t1 - _nowMs), 0.0)

        float _prog = f_safeDiv(_elapsedMs, _barMs, 0.0)
        float _progPct = _prog * 100.0

        float _secsElapsed = math.floor(_elapsedMs / 1000.0)
        float _secsToClose = math.ceil(_toCloseMs / 1000.0)

        float _timerSecs =
             in_timerDirection == "Count Down" ? _secsToClose :
             in_timerDirection == "Count Up" ? _secsElapsed :
             na

        float _timerPct =
             in_timerDirection == "Count Down" ? (100.0 - _progPct) :
             in_timerDirection == "Count Up" ? _progPct :
             na

        array.set(_a, IDX_TIMER_SECS, _timerSecs)
        array.set(_a, IDX_TIMER_PCT, _timerPct)
        _a

// ──────────────────────────────────────────────
// 🟦 Subregion: Row Arrays
// ──────────────────────────────────────────────
var float[] a_1m  = array.new_float(ALL_FIELDS, na)
var float[] a_3m  = array.new_float(ALL_FIELDS, na)
var float[] a_5m  = array.new_float(ALL_FIELDS, na)
var float[] a_10m = array.new_float(ALL_FIELDS, na)
var float[] a_15m = array.new_float(ALL_FIELDS, na)
var float[] a_30m = array.new_float(ALL_FIELDS, na)
var float[] a_1h  = array.new_float(ALL_FIELDS, na)
var float[] a_2h  = array.new_float(ALL_FIELDS, na)
var float[] a_4h  = array.new_float(ALL_FIELDS, na)
var float[] a_8h  = array.new_float(ALL_FIELDS, na)
var float[] a_1D  = array.new_float(ALL_FIELDS, na)
var float[] a_W   = array.new_float(ALL_FIELDS, na)
var float[] a_M   = array.new_float(ALL_FIELDS, na)

// ──────────────────────────────────────────────
// 🟦 Subregion: Security Pulls
// ──────────────────────────────────────────────
if in_use_1m
    a_1m := f_sec_into(a_1m, "1", in_rsiLen, in_rsiSmaLen, in_rsiSmaLen50)

if in_use_3m
    a_3m := f_sec_into(a_3m, "3", in_rsiLen, in_rsiSmaLen, in_rsiSmaLen50)

if in_use_5m
    a_5m := f_sec_into(a_5m, "5", in_rsiLen, in_rsiSmaLen, in_rsiSmaLen50)

if in_use_10m
    a_10m := f_sec_into(a_10m, "10", in_rsiLen, in_rsiSmaLen, in_rsiSmaLen50)

if in_use_15m
    a_15m := f_sec_into(a_15m, "15", in_rsiLen, in_rsiSmaLen, in_rsiSmaLen50)

if in_use_30m
    a_30m := f_sec_into(a_30m, "30", in_rsiLen, in_rsiSmaLen, in_rsiSmaLen50)

if in_use_1h
    a_1h := f_sec_into(a_1h, "60", in_rsiLen, in_rsiSmaLen, in_rsiSmaLen50)

if in_use_2h
    a_2h := f_sec_into(a_2h, "120", in_rsiLen, in_rsiSmaLen, in_rsiSmaLen50)

if in_use_4h
    a_4h := f_sec_into(a_4h, "240", in_rsiLen, in_rsiSmaLen, in_rsiSmaLen50)

if in_use_8h
    a_8h := f_sec_into(a_8h, "480", in_rsiLen, in_rsiSmaLen, in_rsiSmaLen50)

if in_use_1D
    a_1D := f_sec_into(a_1D, "D", in_rsiLen, in_rsiSmaLen, in_rsiSmaLen50)

if in_use_W
    a_W := f_sec_into(a_W, "W", in_rsiLen, in_rsiSmaLen, in_rsiSmaLen50)

if in_use_M
    a_M := f_sec_into(a_M, "M", in_rsiLen, in_rsiSmaLen, in_rsiSmaLen50)

// ──────────────────────────────────────────────
// 🟦 Subregion: Timer Fields
// ──────────────────────────────────────────────
int nowMs = timenow

if doCompute
    if in_use_1m
        a_1m := f_timerInto(a_1m, nowMs)
    if in_use_3m
        a_3m := f_timerInto(a_3m, nowMs)
    if in_use_5m
        a_5m := f_timerInto(a_5m, nowMs)
    if in_use_10m
        a_10m := f_timerInto(a_10m, nowMs)
    if in_use_15m
        a_15m := f_timerInto(a_15m, nowMs)
    if in_use_30m
        a_30m := f_timerInto(a_30m, nowMs)
    if in_use_1h
        a_1h := f_timerInto(a_1h, nowMs)
    if in_use_2h
        a_2h := f_timerInto(a_2h, nowMs)
    if in_use_4h
        a_4h := f_timerInto(a_4h, nowMs)
    if in_use_8h
        a_8h := f_timerInto(a_8h, nowMs)
    if in_use_1D
        a_1D := f_timerInto(a_1D, nowMs)
    if in_use_W
        a_W := f_timerInto(a_W, nowMs)
    if in_use_M
        a_M := f_timerInto(a_M, nowMs)

// ──────────────────────────────────────────────
// 🟦 Subregion: Row Selector
// ──────────────────────────────────────────────
f_rowByIdx(int _idx) =>
    _idx == 0  ? a_1m  :
     _idx == 1  ? a_3m  :
     _idx == 2  ? a_5m  :
     _idx == 3  ? a_10m :
     _idx == 4  ? a_15m :
     _idx == 5  ? a_30m :
     _idx == 6  ? a_1h  :
     _idx == 7  ? a_2h  :
     _idx == 8  ? a_4h  :
     _idx == 9  ? a_8h  :
     _idx == 10 ? a_1D  :
     _idx == 11 ? a_W   :
     _idx == 12 ? a_M   :
     array.new_float(ALL_FIELDS, na)

// ==============================================================================================
// 🔴 END REGION: MTF RSI Data Engine
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: MTF RSI Stack Trend - Chart
// ==============================================================================================
//
// 📌 Purpose:
//     Builds a price-chart trail from the full enabled MTF RSI table stack.
//
// 🧠 Behavior:
//     • Each enabled timeframe row receives a 4-part score:
//          1) Current RSI regime
//          2) Current RSI vs previous RSI
//          3) Current RSI vs RSI SMA 20
//          4) Current RSI vs RSI SMA 50
//     • Scores are combined across all enabled rows.
//     • The combined score is normalized into a -100 to +100 stack-bias value.
//     • Positive stack bias plots a bull trail below price.
//     • Negative stack bias plots a bear trail above price.
//     • Mixed/neutral stack bias plots a neutral trail.
//     • The trail uses EMA + ATR geometry, similar to the pressure-trail concept,
//       but the engine source is the full MTF RSI table stack.
//
// 🧩 Why this matters:
//     The table shows the row-by-row detail, while this trail gives the price
//     chart one clean read of whether the enabled RSI timeframe stack is acting
//     more like support, resistance, or mixed context.
//
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: Row Score Helper
// ──────────────────────────────────────────────
f_mtfRsiStackRowScore(bool _on, float[] _a) =>
    float _score = 0.0
    float _max = 0.0

    if _on
        float _rCur = array.get(_a, IDX_RSI_CUR)
        float _rPrev = array.get(_a, IDX_RSI_PREV)
        float _rSma20 = array.get(_a, IDX_RSI_SMA)
        float _rSma50 = array.get(_a, IDX_RSI_SMA50)

        if not na(_rCur)
            _score += _rCur >= in_rsiNeutralUpper ? 1.0 : _rCur <= in_rsiNeutralLower ? -1.0 : 0.0
            _max += 1.0

        if not na(_rCur) and not na(_rPrev)
            _score += _rCur > _rPrev ? 1.0 : _rCur < _rPrev ? -1.0 : 0.0
            _max += 1.0

        if not na(_rCur) and not na(_rSma20)
            _score += _rCur > _rSma20 ? 1.0 : _rCur < _rSma20 ? -1.0 : 0.0
            _max += 1.0

        if not na(_rCur) and not na(_rSma50)
            _score += _rCur > _rSma50 ? 1.0 : _rCur < _rSma50 ? -1.0 : 0.0
            _max += 1.0

    [_score, _max]

// ──────────────────────────────────────────────
// 🟦 Subregion: Full Stack Score
// ──────────────────────────────────────────────
float mtfStackScore = 0.0
float mtfStackMax = 0.0

[stackScore_1m, stackMax_1m] = f_mtfRsiStackRowScore(in_use_1m, a_1m)
mtfStackScore += stackScore_1m, mtfStackMax += stackMax_1m

[stackScore_3m, stackMax_3m] = f_mtfRsiStackRowScore(in_use_3m, a_3m)
mtfStackScore += stackScore_3m, mtfStackMax += stackMax_3m

[stackScore_5m, stackMax_5m] = f_mtfRsiStackRowScore(in_use_5m, a_5m)
mtfStackScore += stackScore_5m, mtfStackMax += stackMax_5m

[stackScore_10m, stackMax_10m] = f_mtfRsiStackRowScore(in_use_10m, a_10m)
mtfStackScore += stackScore_10m, mtfStackMax += stackMax_10m

[stackScore_15m, stackMax_15m] = f_mtfRsiStackRowScore(in_use_15m, a_15m)
mtfStackScore += stackScore_15m, mtfStackMax += stackMax_15m

[stackScore_30m, stackMax_30m] = f_mtfRsiStackRowScore(in_use_30m, a_30m)
mtfStackScore += stackScore_30m, mtfStackMax += stackMax_30m

[stackScore_1h, stackMax_1h] = f_mtfRsiStackRowScore(in_use_1h, a_1h)
mtfStackScore += stackScore_1h, mtfStackMax += stackMax_1h

[stackScore_2h, stackMax_2h] = f_mtfRsiStackRowScore(in_use_2h, a_2h)
mtfStackScore += stackScore_2h, mtfStackMax += stackMax_2h

[stackScore_4h, stackMax_4h] = f_mtfRsiStackRowScore(in_use_4h, a_4h)
mtfStackScore += stackScore_4h, mtfStackMax += stackMax_4h

[stackScore_8h, stackMax_8h] = f_mtfRsiStackRowScore(in_use_8h, a_8h)
mtfStackScore += stackScore_8h, mtfStackMax += stackMax_8h

[stackScore_1D, stackMax_1D] = f_mtfRsiStackRowScore(in_use_1D, a_1D)
mtfStackScore += stackScore_1D, mtfStackMax += stackMax_1D

[stackScore_W, stackMax_W] = f_mtfRsiStackRowScore(in_use_W, a_W)
mtfStackScore += stackScore_W, mtfStackMax += stackMax_W

[stackScore_M, stackMax_M] = f_mtfRsiStackRowScore(in_use_M, a_M)
mtfStackScore += stackScore_M, mtfStackMax += stackMax_M

float mtfStackBiasRaw =
     mtfStackMax > 0.0
     ? (mtfStackScore / mtfStackMax) * 100.0
     : 0.0

float mtfStackBias = ta.ema(mtfStackBiasRaw, in_stackTrailSmoothLen)

// ──────────────────────────────────────────────
// 🟦 Subregion: Stack Regime State
// ──────────────────────────────────────────────
bool mtfStackBullRegime = mtfStackBias >= in_stackTrailThreshold
bool mtfStackBearRegime = mtfStackBias <= -in_stackTrailThreshold
bool mtfStackNeutralRegime = not mtfStackBullRegime and not mtfStackBearRegime

var bool mtfStackBullState = true
mtfStackBullState := mtfStackBullRegime ? true : mtfStackBearRegime ? false : mtfStackBullState

// ──────────────────────────────────────────────
// 🟦 Subregion: Stack Trend Price-Basis Length
// ──────────────────────────────────────────────
int mtfStackTrailBasisLenAuto =
     timeframe.isseconds and timeframe.multiplier <= 45  ? 13 :
     timeframe.isminutes and timeframe.multiplier <= 3   ? 8  :
     timeframe.isminutes and timeframe.multiplier <= 10  ? 13 :
     timeframe.isminutes and timeframe.multiplier <= 30  ? 21 :
     timeframe.isminutes and timeframe.multiplier <= 120 ? 34 :
     timeframe.isminutes and timeframe.multiplier <= 480 ? 48 :
     timeframe.isdaily                                   ? 21 :
     timeframe.isweekly                                  ? 13 :
     timeframe.ismonthly                                 ? 8  :
                                                           in_stackTrailBasisLenManual

int mtfStackTrailBasisLen =
     in_stackTrailBasisLenMode == "Auto"
     ? mtfStackTrailBasisLenAuto
     : in_stackTrailBasisLenManual

// ──────────────────────────────────────────────
// 🟦 Subregion: Price-Trail Geometry
// ──────────────────────────────────────────────
float mtfStackTrailAtr = ta.atr(STACK_TRAIL_ATR_LEN)
float mtfStackTrailBasis = ta.ema(hlc3, mtfStackTrailBasisLen)
float mtfStackTrailStrength = math.min(math.abs(mtfStackBias) / 100.0, 1.0)
float mtfStackTrailMult = in_stackTrailBaseMult + (mtfStackTrailStrength * in_stackTrailStrengthBoost)
float mtfStackTrailOffset = mtfStackTrailAtr * mtfStackTrailMult
float mtfStackTrailLine = mtfStackBullState ? mtfStackTrailBasis - mtfStackTrailOffset : mtfStackTrailBasis + mtfStackTrailOffset

// ──────────────────────────────────────────────
// 🟦 Subregion: Trail Colors
// ──────────────────────────────────────────────
color mtfStackActiveColor = mtfStackBullState ? in_stackTrailBullColor : in_stackTrailBearColor
color mtfStackActivePlotColor = color.new(mtfStackActiveColor, mtfStackNeutralRegime ? 100 : 0)
color mtfStackNeutralPlotColor = color.new(in_stackTrailNeutralColor, mtfStackNeutralRegime ? 0 : 100)

// ──────────────────────────────────────────────
// 🟦 Subregion: Price Chart Trail Plots
// ──────────────────────────────────────────────
plot(
     in_showStackTrail ? mtfStackTrailLine : na,
     title="MTF RSI Stack Trend - Chart Active",
     color=mtfStackActivePlotColor,
     linewidth=in_stackTrailWidth,
     style=plot.style_line,
     show_last=in_stackTrailLastNBars,
     force_overlay=true)

plot(
     in_showStackTrail ? mtfStackTrailLine : na,
     title="MTF RSI Stack Trend - Chart Neutral",
     color=mtfStackNeutralPlotColor,
     linewidth=in_stackTrailNeutralWidth,
     style=plot.style_line,
     show_last=in_stackTrailLastNBars,
     force_overlay=true)

// ==============================================================================================
// 🔴 END REGION: MTF RSI Stack Trend - Chart
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: Header RSI Averages
// ==============================================================================================
//
// 📌 Purpose:
//     Builds the LTF/HTF RSI average summary line shown in the table header.
//
// ==============================================================================================

f_accSum(float _sum, float _v) =>
    na(_v) ? _sum : (_sum + _v)

f_accCnt(int _cnt, float _v) =>
    na(_v) ? _cnt : (_cnt + 1)

f_rsiCurEnabled(bool _on, float[] _a) =>
    _on ? array.get(_a, IDX_RSI_CUR) : na

f_hdrRsiAvgs() =>
    float r1 = f_rsiCurEnabled(in_use_1m, a_1m)
    float r3 = f_rsiCurEnabled(in_use_3m, a_3m)
    float r5 = f_rsiCurEnabled(in_use_5m, a_5m)
    float r10 = f_rsiCurEnabled(in_use_10m, a_10m)
    float r15 = f_rsiCurEnabled(in_use_15m, a_15m)
    float r30 = f_rsiCurEnabled(in_use_30m, a_30m)
    float r1h = f_rsiCurEnabled(in_use_1h, a_1h)
    float r2h = f_rsiCurEnabled(in_use_2h, a_2h)
    float r4h = f_rsiCurEnabled(in_use_4h, a_4h)
    float r8h = f_rsiCurEnabled(in_use_8h, a_8h)
    float r1D = f_rsiCurEnabled(in_use_1D, a_1D)
    float rW = f_rsiCurEnabled(in_use_W, a_W)
    float rM = f_rsiCurEnabled(in_use_M, a_M)

    float sumL = 0.0
    int cntL = 0

    sumL := f_accSum(sumL, r1), cntL := f_accCnt(cntL, r1)
    sumL := f_accSum(sumL, r3), cntL := f_accCnt(cntL, r3)
    sumL := f_accSum(sumL, r5), cntL := f_accCnt(cntL, r5)
    sumL := f_accSum(sumL, r10), cntL := f_accCnt(cntL, r10)
    sumL := f_accSum(sumL, r15), cntL := f_accCnt(cntL, r15)
    sumL := f_accSum(sumL, r30), cntL := f_accCnt(cntL, r30)
    sumL := f_accSum(sumL, r1h), cntL := f_accCnt(cntL, r1h)
    sumL := f_accSum(sumL, r2h), cntL := f_accCnt(cntL, r2h)

    if isCrypto
        sumL := f_accSum(sumL, r4h), cntL := f_accCnt(cntL, r4h)

    float avgL = cntL > 0 ? (sumL / cntL) : na

    float sumH = 0.0
    int cntH = 0

    if not isCrypto
        sumH := f_accSum(sumH, r4h), cntH := f_accCnt(cntH, r4h)

    sumH := f_accSum(sumH, r8h), cntH := f_accCnt(cntH, r8h)
    sumH := f_accSum(sumH, r1D), cntH := f_accCnt(cntH, r1D)
    sumH := f_accSum(sumH, rW), cntH := f_accCnt(cntH, rW)
    sumH := f_accSum(sumH, rM), cntH := f_accCnt(cntH, rM)

    float avgH = cntH > 0 ? (sumH / cntH) : na

    [avgL, avgH]

f_hdrRsiAvgLine() =>
    [__avgL, __avgH] = f_hdrRsiAvgs()
    string ltfRng = isCrypto ? "1m–4h" : "1m–2h"
    string htfRng = isCrypto ? "8h–M" : "4h–M"
    string avgLTxt = na(__avgL) ? "—" : s(__avgL, "#.#")
    string avgHTxt = na(__avgH) ? "—" : s(__avgH, "#.#")
    "RSI AVG " + ltfRng + ": " + avgLTxt + " | " + htfRng + ": " + avgHTxt

// ==============================================================================================
// 🔴 END REGION: Header RSI Averages
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: Table Registry
// ==============================================================================================
//
// 📌 Purpose:
//     Defines visible columns and resolves active timeframe rows.
//
// 🧠 Notes:
//     • Prev RSI is intentionally not registered as a visible table column.
//     • Previous RSI remains internal for delta calculations.
//
// ==============================================================================================

var string[] a_colNames = array.from(
     "TF",
     "Timer",
     "Current\nRSI",
     "Cur vs\nPrev RSI",
     "SMA\n" + str.tostring(in_rsiSmaLen),
     "SMA\n" + str.tostring(in_rsiSmaLen50))

var string[] a_tfPretty = array.from("1m", "3m", "5m", "10m", "15m", "30m", "1h", "2h", "4h", "8h", "1D", "W", "M")
var string[] a_tfKey = array.from("1", "3", "5", "10", "15", "30", "60", "120", "240", "480", "D", "W", "M")

var int[] a_activeIdx = array.new_int()

if barstate.islast
    array.clear(a_activeIdx)
    if in_use_1m
        array.push(a_activeIdx, 0)
    if in_use_3m
        array.push(a_activeIdx, 1)
    if in_use_5m
        array.push(a_activeIdx, 2)
    if in_use_10m
        array.push(a_activeIdx, 3)
    if in_use_15m
        array.push(a_activeIdx, 4)
    if in_use_30m
        array.push(a_activeIdx, 5)
    if in_use_1h
        array.push(a_activeIdx, 6)
    if in_use_2h
        array.push(a_activeIdx, 7)
    if in_use_4h
        array.push(a_activeIdx, 8)
    if in_use_8h
        array.push(a_activeIdx, 9)
    if in_use_1D
        array.push(a_activeIdx, 10)
    if in_use_W
        array.push(a_activeIdx, 11)
    if in_use_M
        array.push(a_activeIdx, 12)

// ==============================================================================================
// 🔴 END REGION: Table Registry
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: Table Render
// ==============================================================================================
//
// 📌 Purpose:
//     Creates, resizes, and repaints the MTF RSI table.
//
// 🧠 Behavior:
//     • Header row shows optional title lines, ticker/session, and RSI averages.
//     • Body rows show TF, Timer, Cur RSI, Cur vs Prev RSI, RSI SMA 20, and RSI SMA 50.
//     • Cur RSI uses the RSI level color engine.
//     • Cur vs Prev RSI and SMA comparison cells use the user-facing bull/bear colors.
//
// ==============================================================================================

var table rsiTable = na
var int g_tableCols = na
var int g_tableRows = na

color borderColor = color.rgb(20, 20, 20)
color headerBackgroundColor = color.rgb(247, 240, 240)
color headerTextColor = color.rgb(5, 5, 5)
color subheaderBackgroundColor = color.rgb(38, 40, 46)
color subheaderTextColor = color.rgb(247, 240, 240)
color cellBg = color.rgb(247, 240, 240)
color cellText = color.rgb(5, 5, 5)
color tfBg = color.rgb(38, 40, 46)
color tfText = color.rgb(247, 240, 240)
color bullBg = in_tableBullCellColor
color bearBg = in_tableBearCellColor
color bullText = in_tableBullTextColor
color bearText = in_tableBearTextColor


if barstate.islast
    int colN = array.size(a_colNames)
    int rowN = array.size(a_activeIdx)

    int t_cols = math.max(colN, 1)
    int t_rows = math.max(rowN + 2, 2)

    bool needResize = na(rsiTable) or (g_tableCols != t_cols) or (g_tableRows != t_rows)
    bool doPaint = doCompute or needResize

    if needResize
        if not na(rsiTable)
            table.delete(rsiTable)

        rsiTable := table.new(position=tablePosition, columns=t_cols, rows=t_rows, border_color=borderColor, border_width=1)
        g_tableCols := t_cols
        g_tableRows := t_rows

    if doPaint
        table.clear(table_id=rsiTable, start_column=0, start_row=0, end_column=t_cols - 1, end_row=t_rows - 1)

        if rowN <= 0
            table.cell(table_id=rsiTable, column=0, row=0, text="No Timeframes Selected 🤔", bgcolor=na, text_color=chart.fg_color, text_halign=text.align_center, text_size=tableTextSize)
            table.merge_cells(table_id=rsiTable, start_column=0, start_row=0, end_column=t_cols - 1, end_row=0)
        else
            string chartTF_Pretty = TF.f_prettifyTF(timeframe.period)
            string sessNow = in_showSession ? (syminfo.ticker + " (" + chartTF_Pretty + "): " + f_chartSessionNow()) : ""
            string avgLine = f_hdrRsiAvgLine()
            string headingTxt = in_showHeading ? in_headingText : ""
            string subHeadingTxt = in_showSubheading ? in_subheadingText : ""

            string headerAll = ""
            if headingTxt != ""
                headerAll := headingTxt
            if subHeadingTxt != ""
                headerAll := headerAll == "" ? subHeadingTxt : headerAll + "\n" + subHeadingTxt
            if sessNow != ""
                headerAll := headerAll == "" ? sessNow : headerAll + "\n" + sessNow

            headerAll := headerAll == "" ? avgLine : headerAll + "\n" + avgLine

            table.cell(table_id=rsiTable, column=0, row=0, text=headerAll, bgcolor=headerBackgroundColor, text_color=headerTextColor, text_halign=text.align_center, text_size=tableTextSize)
            table.merge_cells(table_id=rsiTable, start_column=0, start_row=0, end_column=t_cols - 1, end_row=0)

            for c = 0 to colN - 1
                table.cell(table_id=rsiTable, column=c, row=1, text=array.get(a_colNames, c), text_color=subheaderTextColor, bgcolor=subheaderBackgroundColor, text_halign=text.align_center, text_size=size.small)

            for i = 0 to rowN - 1
                int _row = i + 2
                int _col = 0

                int tfIdx = array.get(a_activeIdx, i)
                float[] rowA = f_rowByIdx(tfIdx)

                float rCur = array.get(rowA, IDX_RSI_CUR)
                float rPrev = array.get(rowA, IDX_RSI_PREV)
                float rSma = array.get(rowA, IDX_RSI_SMA)
                float rSma50 = array.get(rowA, IDX_RSI_SMA50)
                float timerSecs = array.get(rowA, IDX_TIMER_SECS)
                float timerPct = array.get(rowA, IDX_TIMER_PCT)
                float sl20 = array.get(rowA, IDX_SMA20_SLOPE)
                float sl50 = array.get(rowA, IDX_SMA50_SLOPE)

                string tfTxt = array.get(a_tfPretty, tfIdx)
                string tfKey = array.get(a_tfKey, tfIdx)
                bool isChartRow = tfKey == timeframe.period

                color chartRowBg =
                     color.white

                color chartRowText =
                     #000000

                color tfCellBg =
                     isChartRow
                     ? chartRowBg
                     : tfBg

                color tfCellTxt =
                     isChartRow
                     ? chartRowText
                     : tfText

                color timerCellBg =
                     isChartRow
                     ? chartRowBg
                     : tfBg

                color timerTxtColRow =
                     isChartRow
                     ? chartRowText
                     : tfText

                table.cell(table_id=rsiTable, column=_col, row=_row, text=tfTxt, text_color=tfCellTxt, bgcolor=tfCellBg, text_halign=text.align_center, text_size=size.small)
                _col += 1

                string t_time = f_formatSecondsToTime(timerSecs)
                string t_fracP = na(timerPct) ? "" : s(timerPct, "##") + "%"
                string t_disp = in_timerMode == "Time" ? t_time : t_fracP

                table.cell(table_id=rsiTable, column=_col, row=_row, text=t_disp, text_color=timerTxtColRow, bgcolor=timerCellBg, text_halign=text.align_center, text_size=size.small)
                _col += 1

 
                color curBg = f_rsiLevelCol(rCur, in_rsiNeutralUpper, in_rsiNeutralLower, in_rsiTrendTransp)
                color curTxt = curBg == color.white ? #000000 : f_contrastText(curBg)
                string rCurTxt = na(rCur) ? "—" : s(rCur, "#.#")

                table.cell(table_id=rsiTable, column=_col, row=_row, text=rCurTxt, text_color=curTxt, bgcolor=curBg, width=in_fixedWidthCell, text_halign=text.align_center, text_size=tableTextSize)
                _col += 1

                float d = (na(rCur) or na(rPrev)) ? na : (rCur - rPrev)
                string dT = f_fmtSigned2(d)
                bool dBull = not na(d) and d > 0
                bool dBear = not na(d) and d < 0

                color dBg = dBull ? bullBg : dBear ? bearBg : cellBg
                color dTxt = dBull ? bullText : dBear ? bearText : cellText

                table.cell(table_id=rsiTable, column=_col, row=_row, text=dT, text_color=dTxt, bgcolor=dBg, width=in_fixedWidthCell, text_halign=text.align_center, text_size=tableTextSize)
                _col += 1

                bool rAbove = not na(rCur) and not na(rSma) and rCur > rSma
                bool rOther = not na(rCur) and not na(rSma) and not rAbove

                color sBg = rAbove ? bullBg : rOther ? bearBg : cellBg
                color sTxt = rAbove ? bullText : rOther ? bearText : cellText

                string s20 = na(rSma) ? "—" : s(rSma, "#")
                string a20 = f_slopeArrow(sl20, 0.02)
                string sT = a20 == "" ? s20 : (s20 + a20)

                table.cell(table_id=rsiTable, column=_col, row=_row, text=sT, text_color=sTxt, bgcolor=sBg, width=in_fixedWidthCell, text_halign=text.align_center, text_size=tableTextSize)
                _col += 1

                bool rAbove50 = not na(rCur) and not na(rSma50) and rCur > rSma50
                bool rOther50 = not na(rCur) and not na(rSma50) and not rAbove50

                color sBg50 = rAbove50 ? bullBg : rOther50 ? bearBg : cellBg
                color sTxt50 = rAbove50 ? bullText : rOther50 ? bearText : cellText

                string s50 = na(rSma50) ? "—" : s(rSma50, "#")
                string a50 = f_slopeArrow(sl50, 0.02)
                string sT50 = a50 == "" ? s50 : (s50 + a50)

                table.cell(table_id=rsiTable, column=_col, row=_row, text=sT50, text_color=sTxt50, bgcolor=sBg50, width=in_fixedWidthCell, text_halign=text.align_center, text_size=tableTextSize)
                _col += 1

// ==============================================================================================
// 🔴 END REGION: Table Render
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: MTF RSI Stack Trend ATR Envelope - Chart
// ==============================================================================================
//
// 📌 Purpose:
//     Builds an ATR envelope around the MTF RSI Stack Trend using a midpoint
//     between the chart-timeframe Stack Trend and a higher-timeframe Stack Trend.
//
// 🧠 Behavior:
//     • Uses the existing MTF RSI Stack Trend as the chart-side basis.
//     • Requests and stabilizes a higher-timeframe version of the Stack Trend.
//     • Builds a robust midpoint between the chart trail and HTF trail.
//     • Uses hardcoded inner/outer ATR band fills.
//     • Envelope color follows the active MTF Stack Trend color.
//     • Optional HTF trail plot can remain visible independently from the envelope.
//
// 🧩 Why this matters:
//     The Stack Trend shows the active full-table RSI bias. This envelope gives
//     that trail a volatility-adjusted zone, making it easier to see when price
//     is stretched away from the broader MTF RSI stack context.
//
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: Higher-Timeframe Selector
// ──────────────────────────────────────────────
f_stackAtrEnvGetNextTf() =>
    string _nextTf = ""
    float _mult = timeframe.multiplier

    if timeframe.isseconds
        _nextTf :=
             timeframe.period == "1S"  ? "5S"  :
             timeframe.period == "5S"  ? "10S" :
             timeframe.period == "10S" ? "15S" :
             timeframe.period == "15S" ? "30S" :
             timeframe.period == "30S" ? "45S" :
             timeframe.period == "45S" ? "1"   :
             "1"
    else if timeframe.isminutes
        _nextTf :=
             _mult <= 1   ? "3"   :
             _mult <= 2   ? "4"   :
             _mult <= 3   ? "5"   :
             _mult <= 5   ? "10"  :
             _mult <= 10  ? "15"  :
             _mult <= 15  ? "30"  :
             _mult <= 30  ? "60"  :
             _mult <= 60  ? "120" :
             _mult <= 120 ? "240" :
             _mult <= 240 ? "480" :
             "D"
    else if timeframe.isdaily
        _nextTf := "1W"
    else if timeframe.isweekly
        _nextTf := "2W"
    else if timeframe.ismonthly
        _nextTf := "2M"
    else
        _nextTf := "1D"

    _nextTf

string stackAtrEnvHtf =
     f_stackAtrEnvGetNextTf()

// ──────────────────────────────────────────────
// 🟦 Subregion: Trail + Stabilized HTF Trail Basis
// ──────────────────────────────────────────────
float stackAtrEnvChartTrailRaw =
     mtfStackTrailLine

float stackAtrEnvHtfTrailRequest =
     request.security(
         symbol=standardisedSymbol,
         timeframe=stackAtrEnvHtf,
         expression=mtfStackTrailLine,
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off)

float stackAtrEnvHtfTrailRaw =
     SCL_HTF.f_HTF_Float(
         _HTF=stackAtrEnvHtf,
         _source=stackAtrEnvHtfTrailRequest,
         _arrayHistory=2,
         _HTF_offset=0,
         _useLiveDataOnChartTF=true)

// Hold last non-na trail values so the midpoint does not collapse during early bars or HTF gaps.
var float stackAtrEnvChartTrail = na
var float stackAtrEnvHtfTrail = na

stackAtrEnvChartTrail := nz(stackAtrEnvChartTrailRaw, nz(stackAtrEnvChartTrail[1], mtfStackTrailLine))
stackAtrEnvHtfTrail := nz(stackAtrEnvHtfTrailRaw, nz(stackAtrEnvHtfTrail[1], stackAtrEnvChartTrail))

float stackAtrEnvBasis =
     in_stackAtrEnvBasisMode == "Stack Trend (Chart)" ? stackAtrEnvChartTrail :
     in_stackAtrEnvBasisMode == "Stack Trend (HTF)"   ? stackAtrEnvHtfTrail :
                                                      (stackAtrEnvChartTrail + stackAtrEnvHtfTrail) / 2.0

// ──────────────────────────────────────────────
// 🟦 Subregion: ATR Envelope Geometry
// ──────────────────────────────────────────────
float stackAtrEnvAtr = ta.atr(STACK_ATR_ENV_ATR_LEN)

float stackAtrEnvInnerMult = math.min(in_stackAtrEnvInnerMult, in_stackAtrEnvOuterMult)
float stackAtrEnvOuterMult = math.max(in_stackAtrEnvInnerMult, in_stackAtrEnvOuterMult)

float stackAtrEnvInnerOffset = stackAtrEnvAtr * stackAtrEnvInnerMult
float stackAtrEnvOuterOffset = stackAtrEnvAtr * stackAtrEnvOuterMult

float stackAtrEnvUpperInner = stackAtrEnvBasis + stackAtrEnvInnerOffset
float stackAtrEnvUpperOuter = stackAtrEnvBasis + stackAtrEnvOuterOffset
float stackAtrEnvLowerInner = stackAtrEnvBasis - stackAtrEnvInnerOffset
float stackAtrEnvLowerOuter = stackAtrEnvBasis - stackAtrEnvOuterOffset

// ──────────────────────────────────────────────
// 🟦 Subregion: Envelope + HTF Trail Colors
// ──────────────────────────────────────────────
color stackAtrEnvBaseColor = mtfStackNeutralRegime ? in_stackTrailNeutralColor : mtfStackActiveColor
color stackAtrEnvFillColor = color.new(stackAtrEnvBaseColor, in_stackAtrEnvFillTransp)
color stackAtrEnvHtfPlotColor = color.new(in_stackAtrEnvHtfPlotBaseColor, in_stackAtrEnvHtfPlotTransp)

// ──────────────────────────────────────────────
// 🟦 Subregion: Hidden Plot Anchors
// ──────────────────────────────────────────────
p_stackAtrEnvUpperInner = plot(
     in_showStackAtrEnv ? stackAtrEnvUpperInner : na,
     title="MTF Stack ATR Envelope Upper Inner",
     display=display.none,
     show_last=in_stackAtrEnvLastNBars)

p_stackAtrEnvUpperOuter = plot(
     in_showStackAtrEnv ? stackAtrEnvUpperOuter : na,
     title="MTF Stack ATR Envelope Upper Outer",
     display=display.none,
     show_last=in_stackAtrEnvLastNBars)

p_stackAtrEnvLowerInner = plot(
     in_showStackAtrEnv ? stackAtrEnvLowerInner : na,
     title="MTF Stack ATR Envelope Lower Inner",
     display=display.none,
     show_last=in_stackAtrEnvLastNBars)

p_stackAtrEnvLowerOuter = plot(
     in_showStackAtrEnv ? stackAtrEnvLowerOuter : na,
     title="MTF Stack ATR Envelope Lower Outer",
     display=display.none,
     show_last=in_stackAtrEnvLastNBars)

// ──────────────────────────────────────────────
// 🟦 Subregion: Envelope Fills
// ──────────────────────────────────────────────
fill(
     p_stackAtrEnvUpperOuter,
     p_stackAtrEnvUpperInner,
     color=in_showStackAtrEnv ? stackAtrEnvFillColor : na,
     title="MTF Stack ATR Envelope Upper Band Fill")

fill(
     p_stackAtrEnvLowerInner,
     p_stackAtrEnvLowerOuter,
     color=in_showStackAtrEnv ? stackAtrEnvFillColor : na,
     title="MTF Stack ATR Envelope Lower Band Fill")

// ──────────────────────────────────────────────
// 🟦 Subregion: Higher-Timeframe Stack Trend Plot
// ──────────────────────────────────────────────
plot(
     in_showStackAtrEnvHtfPlot ? stackAtrEnvHtfTrail : na,
     title="HTF MTF RSI Stack Trend - Chart",
     color=stackAtrEnvHtfPlotColor,
     linewidth=in_stackAtrEnvHtfPlotWidth,
     style=plot.style_line,
     show_last=in_stackAtrEnvHtfLastNBars,
     force_overlay=true)

// ==============================================================================================
// 🔴 END REGION: MTF RSI Stack Trend ATR Envelope - Chart
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: MTF RSI Stack Bias Boxes - Chart
// ==============================================================================================
//
// 📌 Purpose:
//     Draws a bottom-pinned price-chart heat strip from the current MTF Stack Bias.
//
// 🧠 Behavior:
//     • Uses mtfStackBias from the MTF RSI Stack Trend engine.
//     • Bias values are clamped from -100 to +100.
//     • Bearish values gradient from Bear Color → Neutral Color.
//     • Bullish values gradient from Neutral Color → Bull Color.
//     • Neutral/mixed readings remain visible as part of the full gradient.
//     • Uses plotchar() so the boxes remain pinned to the bottom of the price pane.
//
// 🧩 Why this matters:
//     The trail shows where the stack projects onto price. These boxes show the
//     smoothed stack-bias strength underneath the chart, making it easier to see
//     why the trail is yellow, purple, gray, hidden, or slow to flip.
//
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: Bias Box Color State
// ──────────────────────────────────────────────
float stackBiasBoxValue = math.max(math.min(nz(mtfStackBias, 0.0), 100.0), -100.0)
float stackBiasBoxAbsNorm = math.abs(stackBiasBoxValue) / 100.0

// Lower values brighten the color sooner around transitions.
float stackBiasBoxCurvePower = 0.60
float stackBiasBoxCurve = math.pow(stackBiasBoxAbsNorm, stackBiasBoxCurvePower)
float stackBiasBoxGradientValue = stackBiasBoxValue >= 0.0 ? stackBiasBoxCurve * 100.0 : -stackBiasBoxCurve * 100.0

// Multi-stop thresholds.
// Warm starts the move from neutral into trend color.
// Hot locks in the extreme color sooner so orange/purple are clearly visible.
float stackBiasBoxBullWarmStart = 35.0
float stackBiasBoxBullHotStart = 70.0
float stackBiasBoxBearWarmStart = -35.0
float stackBiasBoxBearHotStart = -70.0

color stackBiasBoxNeutralBaseColor = in_stackBiasBoxNeutralColor

color stackBiasBoxBaseColor =
     stackBiasBoxGradientValue >= stackBiasBoxBullHotStart ? in_stackBiasBoxBullExtremeColor :
     stackBiasBoxGradientValue > stackBiasBoxBullWarmStart  ? color.from_gradient(stackBiasBoxGradientValue, stackBiasBoxBullWarmStart, stackBiasBoxBullHotStart, in_stackBiasBoxBullColor, in_stackBiasBoxBullExtremeColor) :
     stackBiasBoxGradientValue > 0.0                        ? color.from_gradient(stackBiasBoxGradientValue, 0.0, stackBiasBoxBullWarmStart, stackBiasBoxNeutralBaseColor, in_stackBiasBoxBullColor) :
     stackBiasBoxGradientValue <= stackBiasBoxBearHotStart  ? in_stackBiasBoxBearExtremeColor :
     stackBiasBoxGradientValue < stackBiasBoxBearWarmStart  ? color.from_gradient(stackBiasBoxGradientValue, stackBiasBoxBearHotStart, stackBiasBoxBearWarmStart, in_stackBiasBoxBearExtremeColor, in_stackBiasBoxBearColor) :
     stackBiasBoxGradientValue < 0.0                        ? color.from_gradient(stackBiasBoxGradientValue, stackBiasBoxBearWarmStart, 0.0, in_stackBiasBoxBearColor, stackBiasBoxNeutralBaseColor) :
                                                              stackBiasBoxNeutralBaseColor

color stackBiasBoxColor = color.new(stackBiasBoxBaseColor, 0)

bool showStackBiasBox = in_showStackBiasBoxes

// ──────────────────────────────────────────────
// 🟦 Subregion: Size Fan-Out
// ──────────────────────────────────────────────
float stackBiasBoxTiny = showStackBiasBox and in_stackBiasBoxSize == "Tiny" ? 1.0 : na
float stackBiasBoxSmall = showStackBiasBox and in_stackBiasBoxSize == "Small" ? 1.0 : na
float stackBiasBoxNormal = showStackBiasBox and in_stackBiasBoxSize == "Normal" ? 1.0 : na

// ──────────────────────────────────────────────
// 🟦 Subregion: Bottom-Pinned Trend Strip Render
// ──────────────────────────────────────────────
plotchar(
     stackBiasBoxTiny,
     title="MTF Stack Bias Trend Strip - Tiny",
     char="█",
     location=location.bottom,
     size=size.tiny,
     color=stackBiasBoxColor,
     show_last=in_stackBiasBoxLastNBars)

plotchar(
     stackBiasBoxSmall,
     title="MTF Stack Bias Trend Strip - Small",
     char="█",
     location=location.bottom,
     size=size.small,
     color=stackBiasBoxColor,
     show_last=in_stackBiasBoxLastNBars)

plotchar(
     stackBiasBoxNormal,
     title="MTF Stack Bias Trend Strip - Normal",
     char="█",
     location=location.bottom,
     size=size.normal,
     color=stackBiasBoxColor,
     show_last=in_stackBiasBoxLastNBars)

// ==============================================================================================
// 🔴 END REGION: MTF RSI Stack Bias Boxes - Chart
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: MTF RSI Stack Bull/Bear Markers - Chart
// ==============================================================================================
//
// 📌 Purpose:
//     Adds PA-style Bull/Bear markers to the price chart.
//
// 🧠 Behavior:
//     • Builds a short Wilder-style high/low channel.
//     • Normalizes high/low pressure through RSI.
//     • Chooses the active pressure side relative to the RSI midline.
//     • Uses Williams-style pivot detection to build adaptive trigger levels.
//     • Bull condition plots an upward marker below price.
//     • Bear condition plots a downward marker above price.
//     • Optional Stack-Confirmed mode filters signals through the MTF RSI Stack Trend.
//
// 🧩 Why this matters:
//     The Stack Trend and envelope show broad RSI stack context, while these
//     markers add localized exhaustion/pressure markers around price.
//
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: Marker Length Resolver
// ──────────────────────────────────────────────
int stackMarkerLenAuto =
     timeframe.isseconds or (timeframe.isminutes and timeframe.multiplier <= 5) ? 8 :
     timeframe.isminutes and timeframe.multiplier < 30                          ? 6 :
     timeframe.isminutes and timeframe.multiplier < 240                         ? 5 :
     (timeframe.isminutes and timeframe.multiplier >= 240) or (timeframe.isdaily and timeframe.multiplier == 1) ? 4 :
                                                                                  3

int stackMarkerAdaptLenAuto =
     timeframe.isseconds or (timeframe.isminutes and timeframe.multiplier <= 5) ? 18 :
     timeframe.isminutes and timeframe.multiplier < 30                          ? 14 :
     timeframe.isminutes and timeframe.multiplier < 240                         ? 12 :
     (timeframe.isminutes and timeframe.multiplier >= 240) or (timeframe.isdaily and timeframe.multiplier == 1) ? 10 :
                                                                                  8

int stackMarkerLen =
     in_stackMarkerLengthMode == "Auto"
     ? stackMarkerLenAuto
     : in_stackMarkerLenManual

int stackMarkerAdaptLen =
     in_stackMarkerLengthMode == "Auto"
     ? stackMarkerAdaptLenAuto
     : in_stackMarkerAdaptLenManual

// ──────────────────────────────────────────────
// 🟦 Subregion: Marker OB/OS Core
// ──────────────────────────────────────────────
float stackMarkerHigh = ta.rma(high, stackMarkerLen)
float stackMarkerLow = ta.rma(low, stackMarkerLen)
float stackMarkerHalfRange = (stackMarkerHigh - stackMarkerLow) / 2.0
float stackMarkerMid = stackMarkerLow + stackMarkerHalfRange

float stackMarkerRsiHighRaw = ta.rsi((high - stackMarkerMid) / stackMarkerHalfRange, in_rsiLen)
float stackMarkerRsiLowRaw = ta.rsi((low - stackMarkerMid) / stackMarkerHalfRange, in_rsiLen)

float stackMarkerRsiHigh = na(stackMarkerHalfRange) or stackMarkerHalfRange == 0.0 ? na : stackMarkerRsiHighRaw
float stackMarkerRsiLow = na(stackMarkerHalfRange) or stackMarkerHalfRange == 0.0 ? na : stackMarkerRsiLowRaw

float stackMarkerRsiMax = math.max(stackMarkerRsiHigh, stackMarkerRsiLow)
float stackMarkerRsiMin = math.min(stackMarkerRsiHigh, stackMarkerRsiLow)

bool stackMarkerBothAboveMidline = stackMarkerRsiMax > 50 and stackMarkerRsiMin > 50
bool stackMarkerBothBelowMidline = stackMarkerRsiMax < 50 and stackMarkerRsiMin < 50

float stackMarkerChosen =
     stackMarkerBothAboveMidline ? stackMarkerRsiMax :
     stackMarkerBothBelowMidline ? stackMarkerRsiMin :
     math.abs(stackMarkerRsiMax - 50) < math.abs(stackMarkerRsiMin - 50) ? stackMarkerRsiMax :
     stackMarkerRsiMin

// ──────────────────────────────────────────────
// 🟦 Subregion: Adaptive Pivot Levels
// ──────────────────────────────────────────────
int stackMarkerPivotOffset = 3

bool stackMarkerIsWilliamsHigh =
     stackMarkerChosen[stackMarkerPivotOffset] >= ta.highest(stackMarkerChosen, 8)

bool stackMarkerIsWilliamsLow =
     stackMarkerChosen[stackMarkerPivotOffset] <= ta.lowest(stackMarkerChosen, 8)

float stackMarkerWilliamsHigh =
     stackMarkerIsWilliamsHigh ? stackMarkerChosen[stackMarkerPivotOffset] : na

float stackMarkerWilliamsLow =
     stackMarkerIsWilliamsLow ? stackMarkerChosen[stackMarkerPivotOffset] : na

float stackMarkerAlpha =
     2.0 / (stackMarkerAdaptLen + 1)

var float stackMarkerHighEma = na
var float stackMarkerLowEma = na

if stackMarkerWilliamsHigh > in_rsiNeutralUpper and stackMarkerIsWilliamsHigh
    stackMarkerHighEma := stackMarkerAlpha * stackMarkerWilliamsHigh + (1.0 - stackMarkerAlpha) * nz(stackMarkerHighEma[1], stackMarkerWilliamsHigh)

if stackMarkerWilliamsLow < in_rsiNeutralLower and stackMarkerIsWilliamsLow
    stackMarkerLowEma := stackMarkerAlpha * stackMarkerWilliamsLow + (1.0 - stackMarkerAlpha) * nz(stackMarkerLowEma[1], stackMarkerWilliamsLow)

float stackMarkerBullLine =
     stackMarkerHighEma > 0 ? stackMarkerHighEma : na

float stackMarkerBearLine =
     stackMarkerLowEma > 0 ? stackMarkerLowEma : na

// ──────────────────────────────────────────────
// 🟦 Subregion: Final Marker States
// ──────────────────────────────────────────────
bool stackMarkerBullRaw =
     not na(stackMarkerBullLine) and
     stackMarkerChosen > stackMarkerBullLine

bool stackMarkerBearRaw =
     not na(stackMarkerBearLine) and
     stackMarkerChosen < stackMarkerBearLine

bool stackMarkerUseStackFilter =
     in_stackMarkerFilterMode == "Stack-Confirmed"

bool stackMarkerBull =
     stackMarkerBullRaw and
     (not stackMarkerUseStackFilter or (mtfStackBullRegime and not mtfStackNeutralRegime))

bool stackMarkerBear =
     stackMarkerBearRaw and
     (not stackMarkerUseStackFilter or (mtfStackBearRegime and not mtfStackNeutralRegime))

// ──────────────────────────────────────────────
// 🟦 Subregion: Marker Render
// ──────────────────────────────────────────────
plotshape(
     in_showStackMarkers and stackMarkerBull,
     title="MTF RSI Stack Bull Markers",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.new(in_stackMarkerBullColor, 0),
     size=size.tiny,
     show_last=in_stackMarkerLastNBars,
     force_overlay=true)

plotshape(
     in_showStackMarkers and stackMarkerBear,
     title="MTF RSI Stack Bear Markers",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.new(in_stackMarkerBearColor, 0),
     size=size.tiny,
     show_last=in_stackMarkerLastNBars,
     force_overlay=true)

// ==============================================================================================
// 🔴 END REGION: MTF RSI Stack Bull/Bear Markers - Chart
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: Close Price Follow Line - Chart
// ==============================================================================================
//
// 📌 Purpose:
//     Draws a hardcoded horizontal follow line at the current close price.
//
// 🧠 Behavior:
//     • Tracks the live close price on the price chart.
//     • Updates only on the last bar to prevent flicker.
//     • Extends slightly left and right from the active candle.
//     • Uses the current RSI trend color for visual consistency.
//     • No user-facing inputs/tooltips — intentionally hardcoded.
//
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: Follow Line Helper
// ──────────────────────────────────────────────
f_syncPriceFollowLine(line _line, bool _show, float _y, color _color, int _leftBars, int _rightBars, int _width, string _style) =>
    line _out = _line

    if _show and not na(_y)
        int _x1 = bar_index - _leftBars
        int _x2 = bar_index + _rightBars

        if na(_out)
            _out := line.new(
                 x1=_x1,
                 y1=_y,
                 x2=_x2,
                 y2=_y,
                 xloc=xloc.bar_index,
                 extend=extend.none,
                 color=_color,
                 width=_width,
                 style=_style,
                 force_overlay=true)
        else
            line.set_xy1(_out, _x1, _y)
            line.set_xy2(_out, _x2, _y)
            line.set_color(_out, _color)
            line.set_width(_out, _width)
            line.set_style(_out, _style)
    else
        if not na(_out)
            line.delete(_out)
            _out := na

    _out

// ──────────────────────────────────────────────
// 🟦 Subregion: Hardcoded Close Follow Line Settings
// ──────────────────────────────────────────────
const bool showCloseFollowLine = true
const int closeFollowLeftBars = 0
const int closeFollowRightBars = 2
const int closeFollowLineWidth = 2

string closeFollowLineStyle = line.style_solid

color closeFollowLineColor =
     rsiTrendBaseColor

// ──────────────────────────────────────────────
// 🟦 Subregion: Close Follow Line Render
// ──────────────────────────────────────────────
var line closeFollowLine = na

if barstate.islast
    closeFollowLine := f_syncPriceFollowLine(
         closeFollowLine,
         showCloseFollowLine,
         close,
         closeFollowLineColor,
         closeFollowLeftBars,
         closeFollowRightBars,
         closeFollowLineWidth,
         closeFollowLineStyle)

// ==============================================================================================
// 🔴 END REGION: Close Price Follow Line - Chart
// ==============================================================================================

plot(
     mtfStackBias,
     title="MTF Stack Bias",
     color=color.white,
     display=display.data_window)
````

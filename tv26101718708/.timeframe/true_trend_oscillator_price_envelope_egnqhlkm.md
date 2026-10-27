# True Trend Oscillator + Price Envelope

- url: https://www.tradingview.com/script/egNqhlKM-True-Trend-Oscillator-Price-Envelope/
- type: indicator
- pine_id: PUB;7ee2532c1d444976b3b3b5c4a2ea8550
- version: 2.0

## Description

True Trend Oscillator + Price Envelope is a Pine v6 rebuild and expanded interpretation of the original True Trend Oscillator concept by wbburgin.

The original idea is simple but powerful:

• Convert ATR into a stochastic volatility / trend-energy reading
• Smooth that Stoch ATR reading with a Rational Quadratic Kernel
• Use RSI as the directional pressure input
• Build separate Bull Trend and Bear Trend lines from that shared volatility engine

In this rebuild, I kept the original spirit of the oscillator but expanded it into a fuller trend-energy framework with automatic timeframe-aware settings, cleaner visual controls, price-pane candles, and a chart-side ATR envelope.

────────────────────────────
Core Idea
────────────────────────────

The oscillator is built from two main pieces:

1. Volatility / trend energy

ATR is normalized through a stochastic calculation, then smoothed with a Rational Quadratic Kernel. This creates the “energy” side of the oscillator.

2. Directional pressure

RSI supplies the directional side of the model.

The two final oscillator lines are:

Bull Trend = sqrt(RSI × Smoothed Stoch ATR)

Bear Trend = sqrt((100 - RSI) × Smoothed Stoch ATR)

That means the Bull and Bear lines are both connected to the same volatility / trend-energy source, but RSI determines which side has more directional pressure.

────────────────────────────
How to Read the Oscillator
────────────────────────────

The oscillator has two main lines:

• Bull Trend line
• Bear Trend line

The leading line shows which side currently has control.

A few practical reads:

• Bull above Bear
  Bull pressure is leading.

• Bear above Bull
  Bear pressure is leading.

• Both lines rising together
  Trend energy is expanding.

• Both lines falling together
  Trend energy is cooling, compressing, or losing force.

• Both lines collapsing near zero
  The market is moving into a low-energy / compression state.

This is one of the more important parts of the script. The oscillator is not only asking which side is leading but whether the move has enough volatility energy behind it to matter.

────────────────────────────
Active Trend Threshold
────────────────────────────

The active threshold is used to separate trend conditions from low-energy / range conditions.
A trend is only treated as active when the weaker side of the oscillator is above the active threshold.

In plain terms:

• Bull can be above Bear, but if both lines are too weak, the script treats the market as range / low energy.
• Bear can be above Bull, but if volatility energy is collapsing, the script does not force a strong trend read.
• When both sides clear the threshold, the leading side becomes more meaningful.

This helps reduce the “every crossover is a signal” problem that many simple oscillators can have.

────────────────────────────
Extreme Readings
────────────────────────────

The script includes an upper guide at 80. When the Bull Trend line pushes above 80, the script can highlight that as an extreme bull-energy condition. When the Bear Trend line pushes above 80, the script can highlight that as an extreme bear-energy condition.

By default:

• Bull extreme = orange
• Bear extreme = purple

These colors can also carry into the price candles and envelope visuals, making strong directional energy easier to spot without needing to stare only at the oscillator pane.

────────────────────────────
Auto / Manual Engine
────────────────────────────

The script includes an Auto / Manual engine profile.

Auto mode adjusts the main calculation settings based on the chart timeframe, including:

• ATR length
• Stochastic length
• RSI length
• Stoch smoothing
• Kernel lookback
• Kernel weighting
• Active range threshold

Manual mode unlocks the user-defined settings. When Auto mode is active, the manual inputs are grayed out so the settings panel stays easier to understand.

────────────────────────────
Price Candle Overlay
────────────────────────────

This rebuild includes a price-pane candle overlay using plotcandle() and force_overlay.

The candle overlay keeps the real OHLC candle shape intact, but recolors the body, wick, and border based on the active True Trend state.

The candle colors can represent:

• Bull trend
• Bear trend
• Range / low-energy
• Bull extreme
• Bear extreme

Body, wick, and border transparency are controlled separately, so the candle overlay can be made bold or subtle depending on the chart style.

────────────────────────────
True Trend Price Envelope
────────────────────────────

The script also includes a True Trend Price Envelope projected onto the main chart.

The envelope is built from:

• EMA(HLC3) basis
• ATR-based width
• True Trend strength expansion

As oscillator strength increases, the envelope can widen. This creates a chart-side visual map of how the oscillator’s trend-energy state is interacting with price.

The envelope behavior is designed around support / resistance style context:

• Bull-side pressure fills the upper half of the envelope
• Bear-side pressure fills the lower half of the envelope
• Bull pressure can plot the lower band as a support-style trail
• Bear pressure can plot the upper band as a resistance-style trail
• Neutral conditions can optionally show a soft neutral envelope or basis trail

This helps connect the oscillator pane back to price instead of leaving the oscillator isolated below the chart.

────────────────────────────
How I Use It
────────────────────────────

I use this script as a trend-energy and compression map.

A few practical ways to read it:

• When Bull is above Bear and both lines are rising, bull pressure is expanding with energy.
• When Bear is above Bull and both lines are rising, bear pressure is expanding with energy.
• When the leading side is still on top but both lines are falling, the move may be cooling or losing force.
• When both lines collapse toward zero, the market may be compressing or moving through a lower-energy phase.
• When price is holding the envelope trail in the same direction as the oscillator state, the price chart is confirming the oscillator pressure more cleanly.
• When oscillator pressure and price-envelope behavior disagree, that disagreement can be useful information by itself because it may point to chop, transition, or fading momentum.
• Extreme colors can help identify when directional energy is stretched rather than simply trending.

This is not meant to be a standalone buy/sell signal machine. It is a visual context tool designed to help organize trend direction, volatility energy, compression, and price confirmation.

────────────────────────────
Attribution
────────────────────────────

This script is a Pine v6 rebuild and expanded interpretation of the original True Trend Oscillator concept by wbburgin.

Original author / concept:

• © wbburgin
• Original TradingView script:
https://www.tradingview.com/v/R3T9epUR/

This version adds my own Pine v6 structure, Auto / Manual timeframe behavior, expanded visuals, price-pane plotcandles, extreme-state coloring, and the True Trend Price Envelope.

Special thanks to jdehorty for the KernelFunctions library used for the Rational Quadratic Kernel smoothing.

As always, this script is a visual context tool. It is not financial advice and is not meant to replace risk management, market structure, support/resistance, volume analysis, or a complete trading plan.

────────────────────────────
Chart Examples
────────────────────────────
https://www.tradingview.com/x/oGutJyWc/
https://www.tradingview.com/x/6Lmg5v9R/
https://www.tradingview.com/x/n8LC9tAF/
https://www.tradingview.com/x/SCQy4VaZ/
https://www.tradingview.com/x/g0mZe1IU/

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Original concept © wbburgin
// Pine v6 polished rebuild / expanded construct

//@version=6
indicator("True Trend Oscillator + Price Envelope", "True Trend", overlay=false, precision=2, calc_bars_count = 1000)

// KernelFunctions by jdehorty.
// Used here for the Rational Quadratic Kernel smoother that stabilizes the Stoch ATR
// trend-energy input before it feeds the Bull/Bear True Trend calculations.
import jdehorty/KernelFunctions/2 as kf

// HighTimeframeSampling by SimpleCryptoLife.
// Used here to stabilize the higher-timeframe True Trend reference line so the HTF
// Bull/Bear dominant reading can be sampled cleanly in either Live HTF Float mode
// or Confirmed HTF Close mode.
import SimpleCryptoLife/HighTimeframeSampling/4 as SCL_HTF

// ==============================================================================================
// 🟢 REGION: Script Overview
// ==============================================================================================
//
// True Trend Oscillator Pro is a Pine v6 rebuild and expanded interpretation of the original
// True Trend Oscillator concept by wbburgin.
//
// Original author / concept:
//
// • © wbburgin
// • Original TradingView script: https://www.tradingview.com/v/R3T9epUR/
//
// Kernel library attribution:
//
// • This script imports jdehorty/KernelFunctions/2 as kf
// • The imported library provides non-repainting kernel functions for Nadaraya-Watson style smoothing
// • This script uses the Rational Quadratic Kernel from that library
// • In this script, the kernel is applied to smoothed Stoch ATR, not directly to price
// • Kernel-smoothed Stoch ATR becomes the script's volatility / trend-energy input
//
// Core behavior:
//
// • ATR is converted into a stochastic volatility / trend-energy reading
// • The raw Stoch ATR reading is lightly smoothed first
// • The smoothed Stoch ATR reading is passed through the Rational Quadratic Kernel
// • RSI supplies directional pressure
// • Bull Trend = sqrt(RSI × Kernel-Smoothed Stoch ATR)
// • Bear Trend = sqrt((100 - RSI) × Kernel-Smoothed Stoch ATR)
// • A trend is considered active only when the weaker side is above the active threshold
// • When neither side clears the threshold, the script treats the market as range / low-energy
//
// Why the kernel matters:
//
// • Stoch ATR can move sharply when volatility expands or contracts
// • The Rational Quadratic Kernel helps smooth that volatility-energy input
// • This makes the Bull/Bear Trend plots less jumpy than using raw Stoch ATR alone
// • Kernel Lookback controls how much recent history is used in the estimate
// • Kernel Relative Weighting controls how nearby and farther historical bars are blended
// • Kernel Start Bar controls how early bars are handled by the kernel calculation
//
// Oscillator behavior:
//
// • Bull and Bear plots show directional pressure from the True Trend engine
// • The leading plot shows which side currently has control
// • When both plots rise together, trend energy is expanding
// • When both plots fall together, trend energy is cooling / compressing
// • When both plots collapse near zero, the market is in a low-energy compression zone
// • Plot colors are state-based:
//   - Green = Bull Trend
//   - Red = Bear Trend
//   - Gray = Range / Low Energy
//   - Orange = Bull Extreme
//   - Purple = Bear Extreme
// • Bull readings above 80 can be highlighted as extreme bull energy
// • Bear readings above 80 can be highlighted as extreme bear energy
//
// This rebuild adds:
//
// • Pine v6 structure
// • Auto / Manual engine profile
// • Timeframe-aware ATR, Stoch, RSI, threshold, smoothing, and kernel settings
// • Manual inputs that gray out automatically when Auto mode is active
// • Active RSI length and Stoch ATR length-pair labeling in the info table
// • State-colored Bull / Bear oscillator plot pair
// • SCL-stabilized HTF dominant True Trend reference line
// • Optional Bull / Bear spread histogram
// • Optional oscillator line fill
// • Extreme bull / bear coloring above the 80 guide
// • Price-pane True Trend plotcandles using force_overlay
// • Full price plotcandle transparency controls for body, wick, and border
// • Hardcoded price bar-to-bar close follow line
// • Hardcoded price bar-index close follow line
// • True Trend price envelope projected onto the chart
// • Envelope width based on ATR plus True Trend strength expansion
// • Bull-side envelope fill and lower support trail
// • Bear-side envelope fill and upper resistance trail
// • Optional neutral envelope fill and basis trail behavior
// • True Trend info table with RSI, Stoch ATR, Bull Plot, Bear Plot, and Spread metrics
// • Table delta values comparing current readings to a user-selected number of bars back
// • Last N Bars controls for cleaner chart rendering
//
// ==============================================================================================
// 🔴 END REGION: Script Overview
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: Constants
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: Groups
// ──────────────────────────────────────────────

const string G_ENGINE = "Engine"
const string G_RSI    = "RSI"
const string G_VIS    = "Visuals"
const string G_GUIDES = "Guides"
const string G_TT_ENV = "True Trend Price Envelope"
const string G_TABLE  = "Info Table"
const string G_HTF    = "HTF Reference"
const string G_ALERTS = "Alerts"

/// ──────────────────────────────────────────────
// 🟦 Subregion: Engine Tooltips
// ──────────────────────────────────────────────

const string TT_ENGINE_PROFILE =
     "Controls whether the True Trend engine uses timeframe-aware automatic settings or your manual settings.\n\n" +
     "Auto mode adjusts the main engine inputs based on the chart timeframe, including:\n" +
     "• ATR length\n" +
     "• Stochastic length\n" +
     "• RSI length\n" +
     "• Stoch ATR smoothing\n" +
     "• Kernel lookback\n" +
     "• Kernel relative weighting\n" +
     "• Active range threshold\n\n" +
     "Important:\n" +
     "• In Auto mode, the table RSI may not be RSI 14.\n" +
     "• In Auto mode, Stoch ATR may not use fixed 14 / 14 settings.\n" +
     "• The table labels show the active RSI length and Stoch ATR length pair.\n\n" +
     "Manual mode uses your fixed input values below."

const string TT_THRESHOLD =
     "The active trend threshold.\n\n" +
     "A bull or bear trend only qualifies when the weaker side of the oscillator is above this level.\n\n" +
     "Example:\n" +
     "• If Bull Trend = 60 and Bear Trend = 18 with threshold 20, the script treats this as low-energy / range because the weaker side is still below 20.\n" +
     "• If Bull Trend = 60 and Bear Trend = 25 with threshold 20, the bull trend qualifies because both sides have enough trend-energy.\n\n" +
     "Typical behavior:\n" +
     "• 17–20 = more permissive and more active on lower timeframes.\n" +
     "• 22–26 = stricter and better for filtering weaker higher-timeframe movement."

const string TT_ATR_LEN =
     "ATR length used to build the volatility side of the oscillator.\n\n" +
     "This is the first step in the Stoch ATR engine.\n\n" +
     "Example:\n" +
     "• ATR 10 reacts to shorter volatility bursts and is useful on fast intraday charts.\n" +
     "• ATR 14 is a balanced default.\n" +
     "• ATR 18–21 smooths the volatility reading for higher-timeframe charts.\n\n" +
     "In Auto mode, this value changes by chart timeframe."

const string TT_STOCH_LEN =
     "Stochastic length used to normalize ATR into a 0–100 volatility / trend-energy reading.\n\n" +
     "This does not measure price stochastic directly. It measures where current ATR sits within its recent ATR range.\n\n" +
     "Example:\n" +
     "• Stoch ATR near 0 = ATR energy is low compared to its recent range.\n" +
     "• Stoch ATR near 50 = ATR energy is mid-range.\n" +
     "• Stoch ATR near 100 = ATR energy is elevated compared to its recent range.\n\n" +
     "In Auto mode, this value changes by chart timeframe."

const string TT_STOCH_SMOOTH =
     "Smoothing applied to the raw Stoch ATR value before the kernel estimate.\n\n" +
     "This is a simple pre-smoothing step before the Rational Quadratic Kernel is applied.\n\n" +
     "Example:\n" +
     "• 2 = light smoothing for faster charts.\n" +
     "• 3 = balanced default-style smoothing.\n" +
     "• 5–6 = smoother Stoch ATR behavior for higher timeframes.\n\n" +
     "In Auto mode, this value changes by chart timeframe."

const string TT_KERNEL_LOOKBACK =
     "Lookback used by the Rational Quadratic Kernel smoother.\n\n" +
     "The kernel uses this lookback to estimate a smoother version of the Stoch ATR trend-energy input.\n\n" +
     "Example:\n" +
     "• 16–20 = shorter kernel memory, often better for fast intraday charts.\n" +
     "• 25–30 = balanced smoothing for many intraday charts.\n" +
     "• 34–40 = broader smoothing for higher-timeframe charts.\n\n" +
     "In this script, the kernel is applied to Stoch ATR, not directly to price."

const string TT_KERNEL_WEIGHT =
     "Relative weighting used by the Rational Quadratic Kernel.\n\n" +
     "This controls how the kernel blends nearby bars with farther historical bars inside the estimate.\n\n" +
     "From the KernelFunctions library behavior:\n" +
     "• Smaller values give longer-range history more influence and create a broader, more stretched estimate.\n" +
     "• Larger values make the estimate more local and more similar to a Gaussian-style kernel.\n\n" +
     "Example:\n" +
     "• 1.0 = broader, flexible smoothing.\n" +
     "• 2.0–3.0 = balanced local smoothing.\n" +
     "• 4.0–5.0 = more local weighting, often better for slower charts where the engine can tolerate a smoother HTF-style profile.\n\n" +
     "In Auto mode, this value changes by chart timeframe."

const string TT_KERNEL_START =
     "Start-at-bar setting passed into the Rational Quadratic Kernel.\n\n" +
     "The kernel library uses this to control how early bars are handled in the regression estimate.\n\n" +
     "The first bars on a chart can be unstable because the script has less history available. This setting helps the kernel avoid leaning too heavily on those early unstable bars.\n\n" +
     "Example:\n" +
     "• 2–3 = common for faster profiles.\n" +
     "• 5–6 = more conservative handling for smoother profiles.\n\n" +
     "In Auto mode, this is tied to the active Stoch ATR smoothing profile."

// ──────────────────────────────────────────────
// 🟦 Subregion: RSI Tooltips
// ──────────────────────────────────────────────

const string TT_RSI_SRC =
     "Source used for the RSI pressure calculation.\n\n" +
     "RSI supplies the directional pressure side of the True Trend engine.\n\n" +
     "Example:\n" +
     "• close = standard RSI pressure.\n" +
     "• hlc3 = slightly more balanced candle-price pressure.\n" +
     "• ohlc4 = smoother full-candle pressure."

const string TT_RSI_LEN =
     "RSI length used for the directional bull / bear pressure side of the oscillator.\n\n" +
     "Important:\n" +
     "• In Auto mode, this may not be RSI 14.\n" +
     "• The active RSI length changes by chart timeframe.\n" +
     "• The table row label shows the active RSI length, such as RSI 10, RSI 14, RSI 18, or RSI 21.\n\n" +
     "Example:\n" +
     "• RSI 10–12 = faster pressure reading for low timeframes.\n" +
     "• RSI 14 = balanced default-style reading.\n" +
     "• RSI 18–21 = smoother pressure reading for higher timeframes."

// ──────────────────────────────────────────────
// 🟦 Subregion: Shared Visual Tooltips
// ──────────────────────────────────────────────

const string TT_LAST_BARS =
     "Limits this visual to the most recent N bars.\n\n" +
     "Example:\n" +
     "• 55 = short recent context.\n" +
     "• 89–144 = balanced chart context.\n" +
     "• 233+ = wider historical view.\n\n" +
     "This keeps the chart cleaner and helps avoid drawing unnecessary history."

// ──────────────────────────────────────────────
// 🟦 Subregion: True Trend Price Envelope Tooltips
// ──────────────────────────────────────────────

const string TT_TT_ENV =
     "Controls the True Trend price envelope projected onto the price pane.\n\n" +
     "The envelope is built around an EMA(HLC3) basis, then widened by ATR and the current True Trend oscillator strength.\n\n" +
     "How to read it:\n" +
     "• Bull-side pressure fills the upper half of the envelope.\n" +
     "• Bear-side pressure fills the lower half of the envelope.\n" +
     "• During bull pressure, the active trail plots the lower band as a dynamic support-style guide.\n" +
     "• During bear pressure, the active trail plots the upper band as a dynamic resistance-style guide.\n\n" +
     "The envelope is not a trade signal by itself. It is a chart-side map of how True Trend pressure is translating onto price."

const string TT_TT_ENV_SHAPE =
     "Controls how the price envelope shape settings are selected.\n\n" +
     "• Auto = Uses timeframe-aware defaults for basis length, ATR length, ATR multiplier, and strength boost.\n" +
     "• Manual = Uses your fixed manual envelope settings.\n\n" +
     "Auto examples:\n" +
     "• Lower timeframes use a faster basis and tighter ATR profile.\n" +
     "• Higher timeframes use a slower basis and wider ATR profile.\n\n" +
     "This keeps the envelope from being too wide on fast charts or too tight on slower charts."

const string TT_TT_ENV_TRIGGER =
     "Controls what activates the envelope pressure fill.\n\n" +
     "• Trend State = Uses the qualified True Trend bull / bear state.\n" +
     "• Extreme Only = Only fills during bull / bear extreme readings above 80.\n" +
     "• Leader Side = Uses whichever oscillator line is currently leading, even if the full trend threshold has not qualified.\n" +
     "• Always On = Always colors one side based on the leading oscillator line.\n\n" +
     "Suggested use:\n" +
     "• Trend State = cleanest default.\n" +
     "• Extreme Only = strictest view.\n" +
     "• Leader Side = more active transition view.\n" +
     "• Always On = most visually active."

// ──────────────────────────────────────────────
// 🟦 Subregion: SCL HTF Reference Tooltips
// ──────────────────────────────────────────────

const string TT_HTF_REF =
     "Controls the SCL-stabilized higher-timeframe True Trend reference line.\n\n" +
     "Because this script has two oscillator lines, the HTF reference plots the dominant higher-timeframe side:\n\n" +
     "• If HTF Bull Trend is leading, the line plots HTF Bull Trend.\n" +
     "• If HTF Bear Trend is leading, the line plots HTF Bear Trend.\n\n" +
     "This keeps the HTF reference on the same 0–100 scale as the main oscillator while still showing which side is controlling the higher-timeframe trend-energy state.\n\n" +
     "Color behavior:\n" +
     "• Green = HTF Bull Trend\n" +
     "• Red = HTF Bear Trend\n" +
     "• Gray = HTF Range / Low Energy\n" +
     "• Orange = HTF Bull Extreme\n" +
     "• Purple = HTF Bear Extreme"

const string TT_HTF_SAMPLE =
     "Controls how the HTF value is sampled.\n\n" +
     "• Live HTF Float = Updates while the higher-timeframe candle is still forming.\n" +
     "• Confirmed HTF Close = Uses the prior completed higher-timeframe candle.\n\n" +
     "Example:\n" +
     "• Live HTF Float is more responsive during the active HTF candle.\n" +
     "• Confirmed HTF Close is steadier because it waits for the prior HTF candle to finish."

// ──────────────────────────────────────────────
// 🟦 Subregion: Info Table Tooltips
// ──────────────────────────────────────────────

const string TT_TABLE =
     "Controls the True Trend information table.\n\n" +
     "The table summarizes the most important live internals from the script, including RSI, Stoch ATR, Bull/Bear Trend, trend spread, threshold status, and HTF True Trend state."

const string TT_TABLE_MA =
     "SMA length used for table reference values.\n\n" +
     "Default is 20, which gives RSI and Stoch ATR a simple baseline reference."

const string TT_TABLE_DELTA =
     "Controls how far back the table compares each value.\n\n" +
     "Example:\n" +
     "• 1 = compares the current value to the previous bar.\n" +
     "• 5 = compares the current value to 5 bars ago.\n\n" +
     "The table delta is calculated as:\n" +
     "current value − value X bars ago."
     
const string TT_TABLE_HDR =
     "True Trend table summary.\n\n" +
     "The header shows the symbol and the current True Trend state.\n\n" +
     "Header color follows the active script state:\n" +
     "• Green = Bull Trend\n" +
     "• Red = Bear Trend\n" +
     "• Gray = Range / Low Energy\n" +
     "• Orange = Bull Extreme\n" +
     "• Purple = Bear Extreme"

const string TT_TABLE_RSI_ROW =
     "RSI row.\n\n" +
     "Shows the active RSI value used by the True Trend engine.\n\n" +
     "Important:\n" +
     "• In Auto mode, this may not be RSI 14.\n" +
     "• The RSI length changes by chart timeframe.\n" +
     "• The row label shows the active RSI length, such as RSI 10, RSI 14, or RSI 18.\n\n" +
     "Value column shows RSI with its SMA reference in parentheses.\n\n" +
     "Delta shows how much RSI changed compared to the selected number of bars back.\n\n" +
     "Delta color:\n" +
     "• Green = RSI increased\n" +
     "• Red = RSI decreased\n" +
     "• Gray = RSI unchanged"

const string TT_TABLE_STOCH_ROW =
     "Stoch ATR row.\n\n" +
     "Shows the smoothed Stoch ATR value used as the script's volatility / trend-energy input.\n\n" +
     "Important:\n" +
     "• In Auto mode, this may not use fixed 14 / 14 settings.\n" +
     "• The row label shows ATR length / Stochastic length.\n" +
     "• Example: Stoch ATR 10/10 means ATR length 10 and Stochastic length 10.\n\n" +
     "This value is normalized from 0 to 100:\n" +
     "• Lower values = low ATR energy / compression\n" +
     "• Higher values = elevated ATR energy / expansion\n\n" +
     "Value column shows Stoch ATR with its SMA reference in parentheses.\n\n" +
     "Delta shows how much Stoch ATR changed compared to the selected number of bars back.\n\n" +
     "Delta color follows the change."

const string TT_TABLE_BULL_ROW =
     "Bull Trend row.\n\n" +
     "Shows the current Bull Trend oscillator value:\n" +
     "sqrt(RSI × Smoothed Stoch ATR)\n\n" +
     "Higher values mean stronger bull-side pressure when the bull line is leading.\n\n" +
     "Context column shows the Bull Trend delta over the selected table delta lookback.\n\n" +
     "Value color follows delta."

const string TT_TABLE_BEAR_ROW =
     "Bear Trend row.\n\n" +
     "Shows the current Bear Trend oscillator value:\n" +
     "sqrt((100 - RSI) × Smoothed Stoch ATR)\n\n" +
     "Higher values mean stronger bear-side pressure when the bear line is leading.\n\n" +
     "Context column shows the Bear Trend delta over the selected table delta lookback.\n\n" +
     "Value color follows delta."

const string TT_TABLE_SPREAD_ROW =
     "Spread row.\n\n" +
     "Shows Bull Trend minus Bear Trend.\n\n" +
     "Interpretation:\n" +
     "• Positive spread = Bull Trend is leading\n" +
     "• Negative spread = Bear Trend is leading\n" +
     "• Near zero = Balanced / transition\n\n" +
     "Context column shows the leading side and the spread delta over the selected table delta lookback.\n\n" +
     "Value color follows delta."


// ==============================================================================================
// 🔴 END REGION: Constants
// ==============================================================================================


// ==============================================================================================
// 🟢 REGION: Inputs
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: Engine Inputs
// ──────────────────────────────────────────────

string in_engineProfile = input.string("Auto", "Engine Profile", options=["Auto", "Manual"], group=G_ENGINE, tooltip=TT_ENGINE_PROFILE)

float in_manualThreshold = input.float(20.0, "Manual Range Threshold", minval=0.0, maxval=100.0, step=0.5, group=G_ENGINE, tooltip=TT_THRESHOLD, active=in_engineProfile == "Manual")
int   in_manualAtrLen    = input.int(14, "Manual ATR Length", minval=1, group=G_ENGINE, tooltip=TT_ATR_LEN, active=in_engineProfile == "Manual")
int   in_manualStochLen  = input.int(14, "Manual Stochastic Length", minval=1, group=G_ENGINE, tooltip=TT_STOCH_LEN, active=in_engineProfile == "Manual")
int   in_manualKernelLb  = input.int(25, "Manual Kernel Lookback", minval=1, group=G_ENGINE, tooltip=TT_KERNEL_LOOKBACK, active=in_engineProfile == "Manual")
float in_manualKernelRw  = input.float(1.0, "Manual Kernel Relative Weighting", minval=0.1, step=0.1, group=G_ENGINE, tooltip=TT_KERNEL_WEIGHT, active=in_engineProfile == "Manual")
int   in_manualSmoothK   = input.int(3, "Manual Stoch ATR Smoothing", minval=1, group=G_ENGINE, tooltip=TT_STOCH_SMOOTH, active=in_engineProfile == "Manual")
int   in_manualKernelBar = input.int(3, "Manual Kernel Start Bar", minval=1, group=G_ENGINE, tooltip=TT_KERNEL_START, active=in_engineProfile == "Manual")

// ──────────────────────────────────────────────
// 🟦 Subregion: RSI Inputs
// ──────────────────────────────────────────────

in_rsiSource    = input.source(close, "RSI Source", group=G_RSI, tooltip=TT_RSI_SRC)
int in_manualRsiLen = input.int(14, "Manual RSI Length", minval=1, group=G_RSI, tooltip=TT_RSI_LEN, active=in_engineProfile == "Manual")

// ──────────────────────────────────────────────
// 🟦 Subregion: Main Visual Inputs
// ──────────────────────────────────────────────

string in_trendLineMode     = input.string("Show", "Bull/Bear Trend Lines", options=["Show", "Hide"], group=G_VIS)
int    in_trendLineLastBars = input.int(144, "  ↳ Trend Lines Last N Bars", minval=1, group=G_VIS, tooltip=TT_LAST_BARS)
int    in_trendLineWidth    = input.int(2, "Trend Line Width", minval=1, maxval=5, group=G_VIS)

string in_trendFillMode  = input.string("Show", "Bull/Bear Trend Fill", options=["Show", "Hide"], group=G_VIS)
int    in_trendFillTrans = input.int(75, "  ↳ Trend Fill Transparency", minval=0, maxval=100, group=G_VIS)

string in_spreadHistMode     = input.string("Show", "Trend Spread Histogram", options=["Show", "Hide"], group=G_VIS)
int    in_spreadHistLastBars = input.int(89, "  ↳ Spread Histogram Last N Bars", minval=1, group=G_VIS, tooltip=TT_LAST_BARS)
int    in_spreadHistTrans    = input.int(55, "  ↳ Spread Histogram Transparency", minval=0, maxval=100, group=G_VIS)

string in_priceCandleMode     = input.string("Show", "Price Plot Candles", options=["Show", "Hide"], group=G_VIS)
int    in_priceCandleLastBars = input.int(89, "  ↳ Price Candles Last N Bars", minval=1, group=G_VIS, tooltip=TT_LAST_BARS)
int    in_priceBodyTrans      = input.int(75, "  ↳ Body Transparency", minval=0, maxval=100, group=G_VIS)
int    in_priceWickTrans      = input.int(0, "  ↳ Wick Transparency", minval=0, maxval=100, group=G_VIS)
int    in_priceBorderTrans    = input.int(0, "  ↳ Border Transparency", minval=0, maxval=100, group=G_VIS)

color in_bullColor  = input.color(color.lime, "Bull Color", group=G_VIS)
color in_bearColor  = input.color(color.red, "Bear Color", group=G_VIS)
color in_rangeColor = input.color(color.gray, "Range Color", group=G_VIS)
color in_bullExtremeColor = input.color(color.orange, "Bull Extreme Color", group=G_VIS)
color in_bearExtremeColor = input.color(color.purple, "Bear Extreme Color", group=G_VIS)

// ──────────────────────────────────────────────
// 🟦 Subregion: Guide Inputs
// ──────────────────────────────────────────────

string in_guideMode     = input.string("Show", "Guide Lines", options=["Show", "Hide"], group=G_GUIDES)
int    in_guideLastBars = input.int(55, "  ↳ Guide Lines Last N Bars", minval=1, group=G_GUIDES, tooltip=TT_LAST_BARS)
int    in_guideLineTrans = input.int(0, "Guide Line Transparency", minval=0, maxval=100, group=G_GUIDES)

string in_guideFillMode = input.string("Show", "Guide Zone Fills", options=["Show", "Hide"], group=G_GUIDES)
int    in_upperFillTrans = input.int(100, "  ↳ Upper Zone Fill Transparency", minval=0, maxval=100, group=G_GUIDES)
int    in_lowerFillTrans = input.int(80, "  ↳ Lower Zone Fill Transparency", minval=0, maxval=100, group=G_GUIDES)

color in_topGuideColor       = input.color(color.blue, "Upper Guide Color", group=G_GUIDES)
color in_thresholdGuideColor = input.color(color.gray, "Active Range Threshold Color", group=G_GUIDES)
color in_baseGuideColor      = input.color(color.red, "Base Guide Color", group=G_GUIDES)

// ──────────────────────────────────────────────
// 🟦 Subregion: True Trend Price Envelope Inputs
// ──────────────────────────────────────────────

string in_ttEnvMode = input.string("Show", "True Trend Price Envelope", options=["Show", "Hide"], group=G_TT_ENV, tooltip=TT_TT_ENV)
bool showTtEnv = in_ttEnvMode == "Show"

int in_ttEnvLastBars = input.int(55, "  ↳ Envelope Last N Bars", minval=1, maxval=5000, group=G_TT_ENV, active=showTtEnv, tooltip=TT_LAST_BARS)

string in_ttEnvShapeMode = input.string("Auto", "Envelope Shape Mode", options=["Auto", "Manual"], group=G_TT_ENV, active=showTtEnv, tooltip=TT_TT_ENV_SHAPE)
bool useTtEnvAuto = in_ttEnvShapeMode == "Auto"

string in_ttEnvTriggerMode = input.string("Trend State", "Trigger Mode", options=["Trend State", "Extreme Only", "Leader Side", "Always On"], group=G_TT_ENV, active=showTtEnv, tooltip=TT_TT_ENV_TRIGGER)

int in_ttEnvBasisLenManual = input.int(21, "  ↳ Manual Basis Length", minval=1, maxval=500, group=G_TT_ENV, active=showTtEnv and not useTtEnvAuto)
int in_ttEnvAtrLenManual = input.int(14, "  ↳ Manual ATR Length", minval=1, maxval=500, group=G_TT_ENV, active=showTtEnv and not useTtEnvAuto)
float in_ttEnvAtrMultManual = input.float(1.00, "  ↳ Manual ATR Mult", minval=0.05, maxval=5.00, step=0.05, group=G_TT_ENV, active=showTtEnv and not useTtEnvAuto)
float in_ttEnvBoostManual = input.float(0.75, "  ↳ Manual Strength Boost", minval=0.00, maxval=5.00, step=0.05, group=G_TT_ENV, active=showTtEnv and not useTtEnvAuto)

int in_ttEnvFillTrans = input.int(80, "Active Fill Transparency", minval=0, maxval=100, group=G_TT_ENV, active=showTtEnv)
string in_ttEnvNeutralMode = input.string("Show Neutral Fill", "Neutral Fill", options=["Show Neutral Fill", "Hide Neutral Fill"], group=G_TT_ENV, active=showTtEnv)
int in_ttEnvNeutralTrans = input.int(85, "  ↳ Neutral Fill Transparency", minval=0, maxval=100, group=G_TT_ENV, active=showTtEnv and in_ttEnvNeutralMode == "Show Neutral Fill")

string in_ttEnvTrailMode = input.string("Show", "Active Envelope Trail Line", options=["Show", "Hide"], group=G_TT_ENV, active=showTtEnv)
int in_ttEnvTrailWidth = input.int(2, "  ↳ Trail Line Width", minval=1, maxval=5, group=G_TT_ENV, active=showTtEnv and in_ttEnvTrailMode == "Show")
int in_ttEnvTrailTrans = input.int(0, "  ↳ Trail Line Transparency", minval=0, maxval=100, group=G_TT_ENV, active=showTtEnv and in_ttEnvTrailMode == "Show")
string in_ttEnvTrailNeutral = input.string("Show Basis", "  ↳ Neutral Trail Behavior", options=["Show Basis", "Hide Neutral"], group=G_TT_ENV, active=showTtEnv and in_ttEnvTrailMode == "Show")

// ──────────────────────────────────────────────
// 🟦 Subregion: SCL HTF Reference Inputs
// ──────────────────────────────────────────────

string in_htfRefMode = input.string("Show", "SCL HTF True Trend Line", options=["Show", "Hide"], group=G_HTF, tooltip=TT_HTF_REF)
bool showHtfRef = in_htfRefMode == "Show"

int in_htfRefLastBars = input.int(144, "  ↳ HTF Line Last N Bars", minval=1, maxval=5000, group=G_HTF, active=showHtfRef, tooltip=TT_LAST_BARS)

string in_htfSampleMode = input.string("Live HTF Float", "  ↳ HTF Sampling", options=["Live HTF Float", "Confirmed HTF Close"], group=G_HTF, active=showHtfRef, tooltip=TT_HTF_SAMPLE)

int in_htfRefWidth = input.int(2, "  ↳ HTF Line Width", minval=1, maxval=5, group=G_HTF, active=showHtfRef)
int in_htfRefTrans = input.int(0, "  ↳ HTF Line Transparency", minval=0, maxval=100, group=G_HTF, active=showHtfRef)

// ──────────────────────────────────────────────
// 🟦 Subregion: Info Table Inputs
// ──────────────────────────────────────────────

string in_tableMode = input.string("Show", "True Trend Info Table", options=["Show", "Hide"], group=G_TABLE, tooltip=TT_TABLE)
bool showInfoTable = in_tableMode == "Show"

string in_tablePosition = input.string("Top Right", "  ↳ Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=G_TABLE, active=showInfoTable)
string in_tableTextSize = input.string("Small", "  ↳ Text Size", options=["Tiny", "Small", "Normal"], group=G_TABLE, active=showInfoTable)

int in_tableMaLen = input.int(20, "  ↳ SMA Length", minval=1, maxval=200, group=G_TABLE, active=showInfoTable, tooltip=TT_TABLE_MA)
int in_tableDeltaLen = input.int(1, "  ↳ Delta Compare Bars Back", minval=1, maxval=100, group=G_TABLE, active=showInfoTable, tooltip=TT_TABLE_DELTA)

int in_tableBgTrans = input.int(72, "  ↳ Row Background Transparency", minval=0, maxval=100, group=G_TABLE, active=showInfoTable)
int in_tableFrameTrans = input.int(35, "  ↳ Frame Transparency", minval=0, maxval=100, group=G_TABLE, active=showInfoTable)

// ==============================================================================================
// 🔴 END REGION: Inputs
// ==============================================================================================


// ==============================================================================================
// 🟢 REGION: Helper Functions
// ==============================================================================================

f_clamp(float _value, float _min, float _max) =>
    math.max(_min, math.min(_max, _value))

f_inLastBars(int _bars) =>
    bar_index >= last_bar_index - _bars + 1

f_stochAtr(float _atr, int _smoothK, int _lookback, float _weighting, int _lengthStoch, int _startAtBar) =>
    float _rawStoch    = ta.stoch(_atr, _atr, _atr, _lengthStoch)
    float _smoothStoch = ta.sma(_rawStoch, _smoothK)
    float _kernelValue = kf.rationalQuadratic(_smoothStoch, _lookback, _weighting, _startAtBar)
    f_clamp(_kernelValue, 0.0, 100.0)

f_nextTf() =>
    string _nextTf = ""
    float _mult = timeframe.multiplier

    if timeframe.isseconds
        _nextTf :=
             timeframe.period == "1S"  ? "5S"  :
             timeframe.period == "5S"  ? "10S" :
             timeframe.period == "10S" ? "15S" :
             timeframe.period == "15S" ? "30S" :
             timeframe.period == "30S" ? "45S" : "1"
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
             _mult <= 240 ? "480" : "D"
    else if timeframe.isdaily
        _nextTf := "1W"
    else if timeframe.isweekly
        _nextTf := "2W"
    else if timeframe.ismonthly
        _nextTf := "2M"
    else
        _nextTf := "1D"

    _nextTf

f_tablePos(string _pos) =>
    _pos == "Top Left" ? position.top_left : _pos == "Bottom Right" ? position.bottom_right :
      _pos == "Bottom Left" ? position.bottom_left : position.top_right

f_tableTextSize(string _size) =>
    _size == "Tiny" ? size.tiny : _size == "Normal" ? size.normal : size.small

f_fmt1(float _v) =>
    na(_v) ? "n/a" : str.tostring(_v, "#.0")

f_fmtDelta1(float _v) =>
    na(_v) ? "n/a" : _v > 0 ? "＋" + str.tostring(_v, "#.0") : _v < 0 ? "−" + str.tostring(math.abs(_v), "#.0") : "0.0"

f_contrast(color _bg) =>
    color.r(_bg) + color.g(_bg) + color.b(_bg) > 382 ? color.black : color.white

f_deltaColor(float _delta) =>
    _delta > 0 ? in_bullColor : _delta < 0 ? in_bearColor : in_rangeColor

f_tableRow(table _t, int _row, string _label, string _value, string _context, color _bg, color _labelTxt, color _valueTxt, color _contextTxt, string _size, string _tooltip) =>
    table.cell(_t, 0, _row, _label, text_color=_labelTxt, bgcolor=_bg, text_size=_size, text_halign=text.align_center, tooltip=_tooltip)
    table.cell(_t, 1, _row, _value, text_color=_valueTxt, bgcolor=_bg, text_size=_size, text_halign=text.align_center, tooltip=_tooltip)
    table.cell(_t, 2, _row, _context, text_color=_contextTxt, bgcolor=_bg, text_size=_size, text_halign=text.align_center, tooltip=_tooltip)

// ==============================================================================================
// 🔴 END REGION: Helper Functions
// ==============================================================================================


// ==============================================================================================
// 🟢 REGION: Auto Profile
// ==============================================================================================

bool isMicroIntraday  = timeframe.isseconds or (timeframe.isminutes and timeframe.multiplier <= 5)
bool isFastIntraday   = timeframe.isminutes and timeframe.multiplier > 5 and timeframe.multiplier <= 15
bool isMidIntraday    = timeframe.isminutes and timeframe.multiplier > 15 and timeframe.multiplier < 60
bool isHourlyIntraday = timeframe.isminutes and timeframe.multiplier >= 60 and timeframe.multiplier < 240
bool isHtfIntraday    = timeframe.isminutes and timeframe.multiplier >= 240
bool isDailyChart     = timeframe.isdaily
bool isWeeklyPlus     = timeframe.isweekly or timeframe.ismonthly

float autoThreshold =
     isMicroIntraday  ? 17.0 :
     isFastIntraday   ? 18.0 :
     isMidIntraday    ? 20.0 :
     isHourlyIntraday ? 22.0 :
     isHtfIntraday    ? 23.0 :
     isDailyChart     ? 24.0 :
     isWeeklyPlus     ? 26.0 : 20.0

int autoAtrLen =
     isMicroIntraday  ? 10 :
     isFastIntraday   ? 12 :
     isMidIntraday    ? 14 :
     isHourlyIntraday ? 16 :
     isHtfIntraday    ? 18 :
     isDailyChart     ? 20 :
     isWeeklyPlus     ? 21 : 14

int autoStochLen =
     isMicroIntraday  ? 10 :
     isFastIntraday   ? 12 :
     isMidIntraday    ? 14 :
     isHourlyIntraday ? 18 :
     isHtfIntraday    ? 21 :
     isDailyChart     ? 21 :
     isWeeklyPlus     ? 28 : 14

int autoKernelLookback =
     isMicroIntraday  ? 16 :
     isFastIntraday   ? 20 :
     isMidIntraday    ? 25 :
     isHourlyIntraday ? 30 :
     isHtfIntraday    ? 34 :
     isDailyChart     ? 34 :
     isWeeklyPlus     ? 40 : 25

float autoKernelWeight =
     isMicroIntraday  ? 1.0 :
     isFastIntraday   ? 1.5 :
     isMidIntraday    ? 2.0 :
     isHourlyIntraday ? 3.0 :
     isHtfIntraday    ? 4.0 :
     isDailyChart     ? 4.0 :
     isWeeklyPlus     ? 5.0 : 1.0

int autoSmoothK =
     isMicroIntraday  ? 2 :
     isFastIntraday   ? 3 :
     isMidIntraday    ? 3 :
     isHourlyIntraday ? 4 :
     isHtfIntraday    ? 5 :
     isDailyChart     ? 5 :
     isWeeklyPlus     ? 6 : 3

int autoRsiLen =
     isMicroIntraday  ? 10 :
     isFastIntraday   ? 12 :
     isMidIntraday    ? 14 :
     isHourlyIntraday ? 16 :
     isHtfIntraday    ? 18 :
     isDailyChart     ? 18 :
     isWeeklyPlus     ? 21 : 14

int autoKernelStartBar = autoSmoothK

bool useAutoProfile = in_engineProfile == "Auto"

float activeThreshold = useAutoProfile ? autoThreshold       : in_manualThreshold
int   activeAtrLen    = useAutoProfile ? autoAtrLen          : in_manualAtrLen
int   activeStochLen  = useAutoProfile ? autoStochLen        : in_manualStochLen
int   activeKernelLb  = useAutoProfile ? autoKernelLookback  : in_manualKernelLb
float activeKernelRw  = useAutoProfile ? autoKernelWeight    : in_manualKernelRw
int   activeSmoothK   = useAutoProfile ? autoSmoothK         : in_manualSmoothK
int   activeKernelBar = useAutoProfile ? autoKernelStartBar  : in_manualKernelBar
int   activeRsiLen    = useAutoProfile ? autoRsiLen          : in_manualRsiLen

// ==============================================================================================
// 🔴 END REGION: Auto Profile
// ==============================================================================================


// ==============================================================================================
// 🟢 REGION: True Trend Engine
// ==============================================================================================

float atrValue      = ta.atr(activeAtrLen)
float stochAtrValue = f_stochAtr(atrValue, activeSmoothK, activeKernelLb, activeKernelRw, activeStochLen, activeKernelBar)

float rsiValue        = f_clamp(ta.rsi(in_rsiSource, activeRsiLen), 0.0, 100.0)
float bullTrend       = math.sqrt(rsiValue * stochAtrValue)
float bearTrend       = math.sqrt((100.0 - rsiValue) * stochAtrValue)
float trendFloor      = math.min(bullTrend, bearTrend)
float trendSpread     = bullTrend - bearTrend

bool trendQualifies = trendFloor > activeThreshold

int trendDir =
     bullTrend > bearTrend and trendQualifies ? 1 :
     bearTrend > bullTrend and trendQualifies ? -1 : 0

bool isBullExtreme = bullTrend > 80.0
bool isBearExtreme = bearTrend > 80.0

bool isBullTrend = trendDir == 1
bool isBearTrend = trendDir == -1
bool isRange     = trendDir == 0

color coreStateColor =
     isBullExtreme ? in_bullExtremeColor :
     isBearExtreme ? in_bearExtremeColor :
     isBullTrend   ? in_bullColor :
     isBearTrend   ? in_bearColor : in_rangeColor

// ==============================================================================================
// 🔴 END REGION: True Trend Engine
// ==============================================================================================


// ==============================================================================================
// 🟢 REGION: Visuals
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: Visual State
// ──────────────────────────────────────────────

bool showTrendLinesNow   = in_trendLineMode == "Show" and f_inLastBars(in_trendLineLastBars)
bool showSpreadHistNow   = in_spreadHistMode == "Show" and f_inLastBars(in_spreadHistLastBars)
bool showGuidesNow       = in_guideMode == "Show" and f_inLastBars(in_guideLastBars)
bool showPriceCandlesNow = in_priceCandleMode == "Show" and f_inLastBars(in_priceCandleLastBars)

color trendLineStateColor = color.new(coreStateColor, 0)

color bullLineColor = trendLineStateColor
color bearLineColor = trendLineStateColor

color spreadHistColor =
     isBullExtreme ? color.new(in_bullExtremeColor, in_spreadHistTrans) :
     isBearExtreme ? color.new(in_bearExtremeColor, in_spreadHistTrans) :
     isBullTrend   ? color.new(in_bullColor, in_spreadHistTrans) :
     isBearTrend   ? color.new(in_bearColor, in_spreadHistTrans) : color.new(in_rangeColor, in_spreadHistTrans)

color priceCandleBodyColor   = color.new(coreStateColor, in_priceBodyTrans)
color priceCandleWickColor   = color.new(coreStateColor, in_priceWickTrans)
color priceCandleBorderColor = color.new(coreStateColor, in_priceBorderTrans)

// ──────────────────────────────────────────────
// 🟦 Subregion: Bull/Bear Trend Lines
// ──────────────────────────────────────────────

pBullTrend = plot(showTrendLinesNow ? bullTrend : na, title="Bull Trend", color=bullLineColor, linewidth=in_trendLineWidth)
pBearTrend = plot(showTrendLinesNow ? bearTrend : na, title="Bear Trend", color=bearLineColor, linewidth=in_trendLineWidth)

fill(pBullTrend, pBearTrend, title="Bull/Bear Trend Fill", color=in_trendFillMode == "Show" ? color.new(coreStateColor, in_trendFillTrans) : na)

// ──────────────────────────────────────────────
// 🟦 Subregion: Trend Spread Histogram
// ──────────────────────────────────────────────

plot(showSpreadHistNow ? trendSpread : na, title="Trend Spread Histogram", style=plot.style_columns, histbase=0, color=spreadHistColor)

// ──────────────────────────────────────────────
// 🟦 Subregion: Price Plot Candles
// ──────────────────────────────────────────────

plotcandle(
     showPriceCandlesNow ? open  : na,
     showPriceCandlesNow ? high  : na,
     showPriceCandlesNow ? low   : na,
     showPriceCandlesNow ? close : na,
     title="True Trend Price Candles",
     color=priceCandleBodyColor,
     wickcolor=priceCandleWickColor,
     bordercolor=priceCandleBorderColor,
     editable=false,
     force_overlay=true)

// ==============================================================================================
// 🔴 END REGION: Visuals
// ==============================================================================================


// ==============================================================================================
// 🟢 REGION: SCL HTF True Trend Reference
// ==============================================================================================
//
// Purpose:
//     Adds a stabilized higher-timeframe True Trend reference line to the oscillator pane.
//
// Behavior:
//     • Requests HTF Bull Trend and HTF Bear Trend.
//     • Stabilizes both values through SCL HighTimeframeSampling.
//     • Plots one dominant HTF line:
//         - HTF Bull leading = plots HTF Bull Trend.
//         - HTF Bear leading = plots HTF Bear Trend.
//     • Keeps the HTF reference on the same 0-100 scale as the main oscillator.
//     • Colors the line by the HTF regime state.
//     • Supports Live HTF Float and Confirmed HTF Close sampling.
//
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: HTF Timeframe Selection
// ──────────────────────────────────────────────

string htfRefTf = f_nextTf()
int htfRefOffset = in_htfSampleMode == "Confirmed HTF Close" ? 1 : 0
bool htfRefUseLive = in_htfSampleMode == "Live HTF Float"

// ──────────────────────────────────────────────
// 🟦 Subregion: HTF True Trend Request
// ──────────────────────────────────────────────

[htfBullTrendRaw, htfBearTrendRaw, htfThresholdRaw] =
     request.security(
         symbol=syminfo.tickerid,
         timeframe=htfRefTf,
         expression=[bullTrend, bearTrend, activeThreshold],
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off)

// ──────────────────────────────────────────────
// 🟦 Subregion: SCL HTF Stabilization
// ──────────────────────────────────────────────

float htfBullTrend = SCL_HTF.f_HTF_Float(_HTF=htfRefTf, _source=htfBullTrendRaw, _arrayHistory=2, _HTF_offset=htfRefOffset, _useLiveDataOnChartTF=htfRefUseLive)
float htfBearTrend = SCL_HTF.f_HTF_Float(_HTF=htfRefTf, _source=htfBearTrendRaw, _arrayHistory=2, _HTF_offset=htfRefOffset, _useLiveDataOnChartTF=htfRefUseLive)
float htfThreshold = SCL_HTF.f_HTF_Float(_HTF=htfRefTf, _source=htfThresholdRaw, _arrayHistory=2, _HTF_offset=htfRefOffset, _useLiveDataOnChartTF=htfRefUseLive)

// ──────────────────────────────────────────────
// 🟦 Subregion: HTF True Trend State
// ──────────────────────────────────────────────

float htfTrendFloor = math.min(htfBullTrend, htfBearTrend)
bool htfTrendQualifies = htfTrendFloor > htfThreshold

bool htfBullLeading = htfBullTrend >= htfBearTrend
bool htfBearLeading = htfBearTrend > htfBullTrend

bool htfBullExtreme = htfBullTrend > 80.0
bool htfBearExtreme = htfBearTrend > 80.0

bool htfBullTrendActive = htfBullLeading and htfTrendQualifies
bool htfBearTrendActive = htfBearLeading and htfTrendQualifies
bool htfRangeActive = not htfBullTrendActive and not htfBearTrendActive

float htfDominantTrend =
     htfBullLeading ? htfBullTrend : htfBearTrend

color htfRefColor =
     htfBullExtreme ? color.new(in_bullExtremeColor, in_htfRefTrans) :
     htfBearExtreme ? color.new(in_bearExtremeColor, in_htfRefTrans) :
     htfBullTrendActive ? color.new(in_bullColor, in_htfRefTrans) :
     htfBearTrendActive ? color.new(in_bearColor, in_htfRefTrans) : color.new(in_rangeColor, math.min(in_htfRefTrans + 35, 100))

// ──────────────────────────────────────────────
// 🟦 Subregion: HTF Reference Plot
// ──────────────────────────────────────────────

bool htfRefInWindow = f_inLastBars(in_htfRefLastBars)
bool showHtfRefNow = showHtfRef and htfRefInWindow

plot(
     showHtfRefNow ? htfDominantTrend : na,
     title="SCL HTF Dominant True Trend Line",
     color=htfRefColor,
     linewidth=in_htfRefWidth)

// ==============================================================================================
// 🔴 END REGION: SCL HTF True Trend Reference
// ==============================================================================================


// ==============================================================================================
// 🟢 REGION: True Trend Price Envelope
// ==============================================================================================
//
// Purpose:
//     Projects True Trend oscillator pressure onto the price pane as an ATR-based envelope.
//
// Behavior:
//     • Envelope is built around an EMA(HLC3) basis.
//     • Envelope width expands as True Trend oscillator strength increases.
//     • Bull-side pressure fills the upper half of the envelope.
//     • Bear-side pressure fills the lower half of the envelope.
//     • Active trail line plots lower band during bull pressure and upper band during bear pressure.
//     • Neutral trail can show the basis or hide.
//     • Plot anchors are invisible.
//     • Last N Bars is enforced by gating the plot series with na before fill().
//
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: Auto Envelope Settings
// ──────────────────────────────────────────────

f_ttEnvBasisLenAuto() =>
     timeframe.isseconds ? 13 :
     timeframe.isminutes and timeframe.multiplier <= 3 ? 8 :
     timeframe.isminutes and timeframe.multiplier <= 15 ? 13 :
     timeframe.isminutes and timeframe.multiplier <= 60 ? 21 :
     timeframe.isminutes and timeframe.multiplier <= 240 ? 34 :
     timeframe.isdaily ? 55 :
     timeframe.isweekly ? 89 : 144

f_ttEnvAtrLenAuto() =>
     timeframe.isseconds ? 14 :
     timeframe.isminutes and timeframe.multiplier <= 240 ? 14 :
     timeframe.isdaily ? 14 :
     timeframe.isweekly ? 14 : 55

f_ttEnvAtrMultAuto() =>
     timeframe.isseconds ? 0.80 :
     timeframe.isminutes and timeframe.multiplier <= 3 ? 0.90 :
     timeframe.isminutes and timeframe.multiplier <= 15 ? 1.00 :
     timeframe.isminutes and timeframe.multiplier <= 60 ? 1.10 :
     timeframe.isminutes and timeframe.multiplier <= 240 ? 1.20 :
     timeframe.isdaily ? 1.35 :
     timeframe.isweekly ? 1.50 : 1.75

f_ttEnvBoostAuto() =>
     timeframe.isseconds ? 0.50 :
     timeframe.isminutes and timeframe.multiplier <= 15 ? 0.75 :
     timeframe.isminutes and timeframe.multiplier <= 240 ? 0.85 :
     timeframe.isdaily ? 1.00 :
     timeframe.isweekly ? 1.10 : 1.20

// ──────────────────────────────────────────────
// 🟦 Subregion: Runtime Envelope Settings
// ──────────────────────────────────────────────

int ttEnvBasisLenRt = useTtEnvAuto ? f_ttEnvBasisLenAuto() : in_ttEnvBasisLenManual
int ttEnvAtrLenRt = useTtEnvAuto ? f_ttEnvAtrLenAuto() : in_ttEnvAtrLenManual
float ttEnvAtrMultRt = useTtEnvAuto ? f_ttEnvAtrMultAuto() : in_ttEnvAtrMultManual
float ttEnvBoostRt = useTtEnvAuto ? f_ttEnvBoostAuto() : in_ttEnvBoostManual

// ──────────────────────────────────────────────
// 🟦 Subregion: Envelope Pressure State
// ──────────────────────────────────────────────

bool ttEnvActive = showTtEnv and not na(bullTrend) and not na(bearTrend)

bool ttEnvBullLeader = bullTrend >= bearTrend
bool ttEnvBearLeader = bearTrend > bullTrend

bool ttEnvBullRaw =
     ttEnvActive and
     (
         in_ttEnvTriggerMode == "Trend State"  ? isBullTrend or isBullExtreme :
         in_ttEnvTriggerMode == "Extreme Only" ? isBullExtreme :
         in_ttEnvTriggerMode == "Leader Side"  ? ttEnvBullLeader :
         ttEnvBullLeader)

bool ttEnvBearRaw =
     ttEnvActive and
     (
         in_ttEnvTriggerMode == "Trend State"  ? isBearTrend or isBearExtreme :
         in_ttEnvTriggerMode == "Extreme Only" ? isBearExtreme :
         in_ttEnvTriggerMode == "Leader Side"  ? ttEnvBearLeader :
         ttEnvBearLeader)

bool ttEnvBullActive = ttEnvBullRaw and (not ttEnvBearRaw or bullTrend >= bearTrend)
bool ttEnvBearActive = ttEnvBearRaw and not ttEnvBullActive
bool ttEnvNeutralActive = ttEnvActive and not ttEnvBullActive and not ttEnvBearActive

// ──────────────────────────────────────────────
// 🟦 Subregion: Price Envelope Geometry
// ──────────────────────────────────────────────

float ttEnvBasis = ta.ema(hlc3, ttEnvBasisLenRt)
float ttEnvAtr = ta.atr(ttEnvAtrLenRt)
float ttEnvStrength = math.min(math.max(math.max(bullTrend, bearTrend) / 100.0, 0.0), 1.0)
float ttEnvWidth = ttEnvAtr * (ttEnvAtrMultRt + (ttEnvStrength * ttEnvBoostRt))

float ttEnvUpper = ttEnvBasis + ttEnvWidth
float ttEnvLower = ttEnvBasis - ttEnvWidth

// ──────────────────────────────────────────────
// 🟦 Subregion: Plot Gate
// ──────────────────────────────────────────────

bool ttEnvInWindow = f_inLastBars(in_ttEnvLastBars)
bool showTtEnvNow = ttEnvActive and ttEnvInWindow

float ttEnvUpperPlot = showTtEnvNow ? ttEnvUpper : na
float ttEnvBasisPlot = showTtEnvNow ? ttEnvBasis : na
float ttEnvLowerPlot = showTtEnvNow ? ttEnvLower : na

// ──────────────────────────────────────────────
// 🟦 Subregion: Envelope Colors
// ──────────────────────────────────────────────

color ttEnvInvisible = color.new(color.white, 100)
bool ttEnvShowNeutralFill = in_ttEnvNeutralMode == "Show Neutral Fill"

color ttEnvBullFillBase =
     isBullExtreme ? in_bullExtremeColor : in_bullColor

color ttEnvBearFillBase =
     isBearExtreme ? in_bearExtremeColor : in_bearColor

color ttEnvNeutralFillColor = color.new(in_rangeColor, in_ttEnvNeutralTrans)

color ttEnvUpperFillColor =
     not showTtEnvNow ? na :
     ttEnvBullActive ? color.new(ttEnvBullFillBase, in_ttEnvFillTrans) :
     ttEnvShowNeutralFill ? ttEnvNeutralFillColor : na

color ttEnvLowerFillColor =
     not showTtEnvNow ? na :
     ttEnvBearActive ? color.new(ttEnvBearFillBase, in_ttEnvFillTrans) :
     ttEnvShowNeutralFill ? ttEnvNeutralFillColor : na

// ──────────────────────────────────────────────
// 🟦 Subregion: Price Envelope Plots
// ──────────────────────────────────────────────

plotTtEnvUpper = plot(
     ttEnvUpperPlot,
     title="True Trend Price Envelope Upper",
     color=ttEnvInvisible,
     linewidth=1,
     force_overlay=true)

plotTtEnvBasis = plot(
     ttEnvBasisPlot,
     title="True Trend Price Envelope Basis",
     color=ttEnvInvisible,
     linewidth=1,
     force_overlay=true)

plotTtEnvLower = plot(
     ttEnvLowerPlot,
     title="True Trend Price Envelope Lower",
     color=ttEnvInvisible,
     linewidth=1,
     force_overlay=true)

fill(
     plotTtEnvUpper,
     plotTtEnvBasis,
     color=ttEnvUpperFillColor,
     title="True Trend Price Envelope Upper Fill")

fill(
     plotTtEnvBasis,
     plotTtEnvLower,
     color=ttEnvLowerFillColor,
     title="True Trend Price Envelope Lower Fill")

// ──────────────────────────────────────────────
// 🟦 Subregion: Active Envelope Trail Line
// ──────────────────────────────────────────────

bool showTtEnvTrailNow = showTtEnvNow and in_ttEnvTrailMode == "Show"

float ttEnvTrailLine =
     ttEnvBullActive ? ttEnvLower :
     ttEnvBearActive ? ttEnvUpper :
     in_ttEnvTrailNeutral == "Show Basis" ? ttEnvBasis : na

color ttEnvTrailColor =
     ttEnvBullActive ? color.new(ttEnvBullFillBase, in_ttEnvTrailTrans) :
     ttEnvBearActive ? color.new(ttEnvBearFillBase, in_ttEnvTrailTrans) :
     color.new(in_rangeColor, math.min(in_ttEnvTrailTrans + 35, 100))

plot(
     showTtEnvTrailNow ? ttEnvTrailLine : na,
     title="True Trend Active Envelope Trail Line",
     color=ttEnvTrailColor,
     linewidth=in_ttEnvTrailWidth,
     force_overlay=true)

// ==============================================================================================
// 🔴 END REGION: True Trend Price Envelope
// ==============================================================================================


// ==============================================================================================
// 🟢 REGION: Guides
// ==============================================================================================

pTopGuide = plot(showGuidesNow ? 80.0 : na, title="Upper Trend Guide", color=color.new(in_topGuideColor, in_guideLineTrans), linewidth=1)
pThresholdGuide = plot(showGuidesNow ? activeThreshold : na, title="Active Range Threshold", color=color.new(in_thresholdGuideColor, in_guideLineTrans), linewidth=2)
pBaseGuide = plot(showGuidesNow ? 0.0 : na, title="Base Guide", color=color.new(in_baseGuideColor, in_guideLineTrans), linewidth=1)

fill(pTopGuide, pThresholdGuide, title="Upper Trend Zone Fill", color=in_guideFillMode == "Show" ? color.new(in_topGuideColor, in_upperFillTrans) : na)
fill(pThresholdGuide, pBaseGuide, title="Range / Low Energy Zone Fill", color=in_guideFillMode == "Show" ? color.new(in_thresholdGuideColor, in_lowerFillTrans) : na)

// ==============================================================================================
// 🔴 END REGION: Guides
// ==============================================================================================


// ==============================================================================================
// 🟢 REGION: True Trend Info Table
// ==============================================================================================
//
// Purpose:
//     Displays the most important True Trend engine metrics in a compact live table.
//
// Behavior:
//     • Shows current True Trend state.
//     • Shows RSI and Stoch ATR with SMA reference and delta.
//     • Shows Bull Trend, Bear Trend, Spread, and Floor/Threshold status.
//     • Shows the SCL HTF dominant True Trend reference.
//     • Updates only on the last bar to keep table output stable.
//
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: Table Metric Calculations
// ──────────────────────────────────────────────

float tableRsiSma = ta.sma(rsiValue, in_tableMaLen)
float tableStochSma = ta.sma(stochAtrValue, in_tableMaLen)

float tableRsiDelta = rsiValue - rsiValue[in_tableDeltaLen]
float tableStochDelta = stochAtrValue - stochAtrValue[in_tableDeltaLen]
float tableBullDelta = bullTrend - bullTrend[in_tableDeltaLen]
float tableBearDelta = bearTrend - bearTrend[in_tableDeltaLen]
float tableSpreadDelta = trendSpread - trendSpread[in_tableDeltaLen]

string tableStateText =
     isBullExtreme ? "Bull Extreme" :
     isBearExtreme ? "Bear Extreme" :
     isBullTrend ? "Bull Trend" :
     isBearTrend ? "Bear Trend" : "Range / Low Energy"

// string tableHtfStateText =
//      htfBullExtreme ? "HTF Bull Extreme" :
//      htfBearExtreme ? "HTF Bear Extreme" :
//      htfBullTrendActive ? "HTF Bull Trend" :
//      htfBearTrendActive ? "HTF Bear Trend" : "HTF Range"

// string tableSpreadSide =
//      trendSpread > 0 ? "Bull" :
//      trendSpread < 0 ? "Bear" : "Balanced"

// string tableFloorStatus =
//      trendQualifies ? "Trend Active" : "Low Energy"

color tableHeaderBg = color.new(coreStateColor, 0)

color tableHeaderTxt =
     isBullTrend or isBullExtreme ? #000000 :
     f_contrast(tableHeaderBg)

color tableRowBg = color.new(color.black, in_tableBgTrans)
color tableFrameColor = color.new(coreStateColor, in_tableFrameTrans)

string tableSize = f_tableTextSize(in_tableTextSize)

// ──────────────────────────────────────────────
// 🟦 Subregion: Table Object
// ──────────────────────────────────────────────

var table ttInfoTable = table.new(f_tablePos(in_tablePosition), 3, 6, frame_color=tableFrameColor, frame_width=1, border_color=tableFrameColor, border_width=1)

// ──────────────────────────────────────────────
// 🟦 Subregion: Table Render
// ──────────────────────────────────────────────

if barstate.islast
    if showInfoTable
        table.cell(ttInfoTable, 0, 0, "TRUE TREND", text_color=tableHeaderTxt, bgcolor=tableHeaderBg, text_size=tableSize, text_halign=text.align_center, tooltip=TT_TABLE_HDR)
        table.cell(ttInfoTable, 1, 0, syminfo.ticker, text_color=tableHeaderTxt, bgcolor=tableHeaderBg, text_size=tableSize, text_halign=text.align_center, tooltip=TT_TABLE_HDR)
        table.cell(ttInfoTable, 2, 0, tableStateText, text_color=tableHeaderTxt, bgcolor=tableHeaderBg, text_size=tableSize, text_halign=text.align_center, tooltip=TT_TABLE_HDR)

        f_tableRow(ttInfoTable, 1, "RSI " + str.tostring(activeRsiLen), f_fmt1(rsiValue) + " (" + f_fmt1(tableRsiSma) + ")", "Δ " + f_fmtDelta1(tableRsiDelta), tableRowBg, color.white, color.white, f_deltaColor(tableRsiDelta), tableSize, TT_TABLE_RSI_ROW)
        f_tableRow(ttInfoTable, 2, "Stoch ATR " + str.tostring(activeAtrLen) + "/" + str.tostring(activeStochLen), f_fmt1(stochAtrValue) + " (" + f_fmt1(tableStochSma) + ")", "Δ " + f_fmtDelta1(tableStochDelta), tableRowBg, color.white, color.white, f_deltaColor(tableStochDelta), tableSize, TT_TABLE_STOCH_ROW)
        f_tableRow(ttInfoTable, 3, "Bull Plot", f_fmt1(bullTrend), "Δ " + f_fmtDelta1(tableBullDelta), tableRowBg, color.white, color.white, f_deltaColor(tableBullDelta), tableSize, TT_TABLE_BULL_ROW)
        f_tableRow(ttInfoTable, 4, "Bear Plot", f_fmt1(bearTrend), "Δ " + f_fmtDelta1(tableBearDelta), tableRowBg, color.white, color.white, f_deltaColor(tableBearDelta), tableSize, TT_TABLE_BEAR_ROW)
        f_tableRow(ttInfoTable, 5, "Spread", f_fmt1(trendSpread), "Δ " + f_fmtDelta1(tableSpreadDelta), tableRowBg, color.white, color.white, f_deltaColor(tableSpreadDelta), tableSize, TT_TABLE_SPREAD_ROW)
    else
        table.clear(ttInfoTable, 0, 0, 2, 5)

// ==============================================================================================
// 🔴 END REGION: True Trend Info Table
// ==============================================================================================


// ==============================================================================================
// 🟢 REGION: Alerts
// ==============================================================================================

bool bullTrendStart = isBullTrend and not isBullTrend[1]
bool bearTrendStart = isBearTrend and not isBearTrend[1]
bool rangeStart     = isRange and not isRange[1]

alertcondition(bullTrendStart, "Bull True Trend Start", "True Trend Oscillator Pro: Bull trend state started.")
alertcondition(bearTrendStart, "Bear True Trend Start", "True Trend Oscillator Pro: Bear trend state started.")
alertcondition(rangeStart, "Range / Low-Energy State Start", "True Trend Oscillator Pro: Range / low-energy state started.")

// ==============================================================================================
// 🔴 END REGION: Alerts
// ==============================================================================================


// // ==============================================================================================
// // 🟢 REGION: Price Pane Follow Lines
// // ==============================================================================================
// //
// // Purpose:
// //     Projects hardcoded close-follow references onto the price pane from this oscillator script.
// //
// // Behavior:
// //     • Bar-to-Bar Follow Line connects each visible close directly to the next close.
// //     • Bar-Index Follow Line is a small horizontal left/right line centered on the active candle.
// //     • Both use the active True Trend state color.
// //     • Extreme bull/bear states inherit the orange/purple extreme colors through coreStateColor.
// //     • Lines are hardcoded intentionally so they do not add extra settings clutter.
// //
// // ==============================================================================================

// // ──────────────────────────────────────────────
// // 🟦 Subregion: Price Follow Line Constants
// // ──────────────────────────────────────────────

// const int PRICE_FOLLOW_LAST_BARS       = 2
// const int PRICE_FOLLOW_LINE_WIDTH      = 1
// const int PRICE_FOLLOW_LINE_TRANSP     = 0
// const int PRICE_INDEX_LEFT_OFFSET      = 1
// const int PRICE_INDEX_RIGHT_OFFSET     = 1
// const int PRICE_INDEX_LINE_WIDTH       = 1
// const int PRICE_INDEX_LINE_TRANSP      = 0

// // ──────────────────────────────────────────────
// // 🟦 Subregion: Price Follow Line State
// // ──────────────────────────────────────────────

// color priceFollowLineColor = color.new(coreStateColor, PRICE_FOLLOW_LINE_TRANSP)
// color priceIndexLineColor  = color.new(coreStateColor, PRICE_INDEX_LINE_TRANSP)

// // ──────────────────────────────────────────────
// // 🟦 Subregion: Bar-to-Bar Close Follow Line
// // ──────────────────────────────────────────────

// plot(
//      close,
//      title="True Trend Price Bar-to-Bar Follow Line",
//      color=priceFollowLineColor,
//      linewidth=PRICE_FOLLOW_LINE_WIDTH,
//      style=plot.style_line,
//      show_last=PRICE_FOLLOW_LAST_BARS,
//      force_overlay=true)

// // ──────────────────────────────────────────────
// // 🟦 Subregion: Bar-Index Close Follow Line
// // ──────────────────────────────────────────────

// var line priceIndexFollowLine = na

// if barstate.islast
//     int priceIndexX1 = bar_index - PRICE_INDEX_LEFT_OFFSET
//     int priceIndexX2 = bar_index + PRICE_INDEX_RIGHT_OFFSET

//     if na(priceIndexFollowLine)
//         priceIndexFollowLine := line.new(x1=priceIndexX1, y1=close, x2=priceIndexX2, y2=close, xloc=xloc.bar_index, extend=extend.none, color=priceIndexLineColor, style=line.style_solid, width=PRICE_INDEX_LINE_WIDTH, force_overlay=true)
//     else
//         line.set_xy1(priceIndexFollowLine, priceIndexX1, close)
//         line.set_xy2(priceIndexFollowLine, priceIndexX2, close)
//         line.set_color(priceIndexFollowLine, priceIndexLineColor)
//         line.set_width(priceIndexFollowLine, PRICE_INDEX_LINE_WIDTH)
//         line.set_style(priceIndexFollowLine, line.style_solid)

// // ==============================================================================================
// // 🔴 END REGION: Price Pane Follow Lines
// // ==============================================================================================
````

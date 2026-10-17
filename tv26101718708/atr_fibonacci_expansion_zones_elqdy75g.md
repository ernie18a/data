# ATR & Fibonacci Expansion Zones

- url: https://www.tradingview.com/script/ELqDY75G-ATR-Fibonacci-Expansion-Zones/
- type: indicator
- pine_id: PUB;88f147a3826e404aad3c4957e592f2b2
- version: 3.0

## Description

ATR & Fibonacci Expansion Zones is a multi-mode ATR framework designed to help traders read price location, volatility expansion, session structure, and active high/low range context. The script is built around a simple but powerful idea: ATR levels can provide a volatility-adjusted map of how far price has moved from a meaningful close reference. From there, the workflow adds flexible mode selection, organized ATR labels, optional historical ATR periods, mode-aware AVWAPs, active high/low zones, and fibonacci labels that correspond to a respective level within the enabled mode.

────────────────────────────
Core Idea
────────────────────────────

ATR (actual true range) is powerful because it gives price movement a volatility-adjusted frame of reference.

This script helps traders evaluate:

• How far price has expanded from the selected close anchor
• Whether price is still near the first ATR expansion zone or already extended
• Whether price is approaching a major +1, +2, +3, or +4 ATR area
• Whether price is reacting around an active session high/low zone
• Where price is trading inside the active session fibonacci range
• Which ATR mode best frames the current move: Daily, Multiday, Swing, Position, or Long-Term

That makes the script useful for intraday context, multiday moves, swing structure, position-style tracking, and longer-term range mapping.

────────────────────────────
ATR Modes
────────────────────────────

The script renders one selected ATR engine at a time. This keeps the chart cleaner than stacking multiple ATR families together.

Included modes:

Daily
Uses the daily ATR framework. Best for day/session-level context on intraday charts.

Multiday
Uses the weekly ATR framework. Best for trades developing across multiple sessions.

Swing
Uses the monthly ATR framework. Best for larger swing-style movement.

Position
Uses a 3-month ATR framework. Best for broader position-style context.

Long-Term
Uses a 12-month ATR framework. Best for major range structure and larger macro-style moves.

All modes can render the full 23.6% through 400% ATR expansion range, with separate line and label controls for each major range block.

────────────────────────────
ATR Expansion Grid
────────────────────────────

The main ATR grid plots upper and lower ATR expansion levels from the selected close anchor.

The grid includes:

• 23.6% to 100%
• 123.6% to 200%
• 223.6% to 300%
• 323.6% to 400%

Each range has its own parent Show / Hide controls for lines and labels, plus child controls for upper and lower sides. This makes it easier to keep the chart simple when only the closer ATR levels matter, or expand the full map when price is making a larger move.

The labels can show:

• ATR ratio
• ATR level price
• selected mode tag
• percent distance from current price

That percent-from-price read helps make the grid more practical because you can quickly see how close price is to the next ATR level instead of visually estimating it or using the info line tool.

────────────────────────────
Previous / Current Close Reference
────────────────────────────

The PCL / CC line and label show the active close reference used by the selected ATR grid. Depending on the selected mode and settings, this can represent:

• Previous Close
• Current Close
• Daily close reference
• Weekly close reference
• Monthly close reference
• 3-month close reference
• 12-month close reference

The label can also show close-to-close percent change and RSI(14) from the selected ATR timeframe. This is important because the close anchor is the foundation of the ATR grid. The script keeps that reference visible so the user can see exactly where the ATR expansion map begins.

────────────────────────────
ATR Session AVWAPs
────────────────────────────

The script includes mode-aware ATR Session AVWAPs. These are not static VWAPs. They follow the currently selected ATR mode. Depending on the mode, the AVWAP set can reset from:

• the active day/session
• the active week
• the active month
• the active 3-month period
• the active 12-month period

Included AVWAP paths:

• Session VWAP
• High AVWAP
• Low AVWAP

The Session VWAP starts from the active ATR period/session start. The High AVWAP anchors from the candle that creates the active period high. The Low AVWAP anchors from the candle that creates the active period low. When a new active high or low forms, the matching AVWAP re-anchors.

In practical terms:

• ATR levels show volatility expansion from the selected close anchor
• AVWAPs show volume-weighted behavior from the active period structure
• High/Low AVWAPs help track how price behaves after major active-period extremes form

This adds a useful volume-weighted layer around the ATR map.

────────────────────────────
ATR Session High / Low Boxes
────────────────────────────

The script can also draw active high and low boxes for the selected ATR session or period.

The High Box starts from the candle that creates the active high.
The Low Box starts from the candle that creates the active low.

These boxes are wick-based, which makes them useful for highlighting rejection zones, liquidity wicks, exhaustion candles, or important high/low reference areas inside the active ATR period.

────────────────────────────
ATR Session Fibonacci Labels (levels)
────────────────────────────

ATR Session Fibonacci Labels add another layer of context beside the ATR grid.

The ATR grid answers:

“How far has price expanded from the selected close anchor?”

The session fib labels answer:

“Where is price trading inside the active high-to-low range?”

The fib labels use the same active high and low tracked by the AVWAP and high/low box engines.

Direction is inferred automatically:

• If the low formed before the high, the script treats it as a bullish session leg
• If the high formed before the low, the script treats it as a bearish session leg

The fib labels can show:

• fib ratio
• price
• percent distance from current price

This creates a clean second layer of structure: ATR levels for expansion, fib labels for internal active-range location.

────────────────────────────
Historical ATR Periods
────────────────────────────

The script includes an optional Historical ATR Periods mode. When enabled, prior ATR grid segments can remain visible for a user-defined number of completed ATR periods.

This is useful for reviewing:

• how price respected previous ATR levels
• where prior extensions acted as support or resistance
• whether price repeatedly reacted around certain volatility zones
• how current ATR behavior compares to prior periods

Historical labels are intentionally excluded to keep the chart cleaner. The historical mode focuses on line segments only.

────────────────────────────
Asset-Aware Behavior
────────────────────────────

The script includes separate behavior for stocks, crypto, and futures.

For stocks and funds:

• ATR calculations can use regular or extended-session source data
• Daily lines can start from regular open or extended open
• Daily AVWAPs, boxes, and fib labels can reset from the extended-session / premarket day start when available
• Higher-timeframe stock modes wait for the first regular-hours bar of the new period for cleaner visual alignment

For crypto:

• the chart ticker is used
• Daily mode resets once per calendar day

For futures:

• the chart ticker is used
• Daily mode uses a Globex-style 5:00 PM Central session boundary
• higher-timeframe modes reset from the selected W / M / 3M / 12M ATR period boundary

This makes the script more flexible across different asset classes instead of treating every market like a regular-hours stock chart.

────────────────────────────
How I Use It
────────────────────────────

I use this script as a volatility and structure map.

A few practical ways to read it:

• Daily mode helps frame intraday price movement around the active daily ATR grid
• Multiday mode helps show where price is trading inside the weekly ATR structure
• Swing mode is useful when the daily chart is too narrow and the monthly range matters more
• Position and Long-Term modes help zoom out and understand broader extension zones
• PCL (previous close) / CC (current close) keeps the close anchor visible
• The Auto close-anchor setting is especially useful for Daily stock mode because it automatically adapts between Current Close during New York premarket / after-hours and Previous Close during regular market hours
• This means the ATR grid can stay aligned with the session environment without forcing the user to manually decide when to use PCL or CC
• During premarket and after-hours, Current Close helps the levels respond to the active extended-hours move
• During regular hours, Previous Close keeps the main daily ATR map anchored to the completed prior session
• The price guide dash makes it easier to line up current price with the ATR label column
• High/Low Boxes help mark active wick-based extremes
• Session AVWAPs add a volume-weighted path from the active period and its extremes
• Session Fib Labels show internal retracement context inside the active high/low range
• Historical ATR Periods help review how price behaved around prior ATR grids

The Auto close-anchor behavior is one of the most practical parts of the workflow. Premarket and after-hours trading can make a static previous-close grid feel disconnected from the live move, while regular-hours trading often benefits from keeping the prior close as the main reference. Auto handles that transition in the background so the ATR levels remain tied to the most relevant close reference for the active session. In other words, you don't have to decide when to use "Use Current Close" depending on if your'e in pre-market or regular trading hours. 

The value of this script is organization. It brings ATR expansion, close-reference context, session extremes, AVWAP structure, and active-range fib location into one chart-side workflow.
ATR levels by themselves can already be useful but this script expands that idea into a fuller range map so traders can better judge whether price is early in a move, pressing into extension, reacting from an active extreme, or moving through a broader volatility structure.

────────────────────────────
Attribution
────────────────────────────

This script is a modern rebuild inspired by Saty’s ATR Levels concept and my original ATR Levels publication.

Special thanks to SimpleCryptoLife for past help and inspiration around improving the original ATR Levels workflow and for the Significant Figures library used for cleaner number formatting.

As always, this is a visual context tool. It is not meant to replace risk management, market structure, support/resistance, volume analysis, or a complete trading plan.

────────────────────────────
A Few Chart Examples
────────────────────────────

https://www.tradingview.com/x/WwDLNiRi/

https://www.tradingview.com/x/ihgD2PRj/

https://www.tradingview.com/x/u4ZIUCXr/

## Source Code

````pine
// ATR & Fibonacci Expansion Zones is an enhanced Pine v6 rebuild of my 2023 script: https://www.tradingview.com/script/usrnSDqG-ATR-Levels/
// inspired by Saty's ATR Levels: https://www.tradingview.com/v/Ty6CMBw9/
// This version renders one selected ATR engine at a time and includes labeled ATR levels,
// price guide alignment, mode-aware AVWAPs, high/low wick zones, session fib context,
// and historical ATR periods.
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MYNAMEISBRANDON

//@version=6
indicator('ATR & Fibonacci Expansion Zones', shorttitle='ATR+Fib', overlay=true, calc_bars_count=7500, max_bars_back=5000, max_lines_count=500, max_labels_count=500, max_boxes_count=50, max_polylines_count=100, dynamic_requests=true)

//
// Overview
//
// Mode behavior:
//
// • Daily
//   - ATR timeframe = D
//   - Label tag = D
//   - Available ATR expansion range = 23.6% through 400%
//
// • Multiday
//   - ATR timeframe = W
//   - Label tag = M
//   - Available ATR expansion range = 23.6% through 400%
//
// • Swing
//   - ATR timeframe = M
//   - Label tag = S
//   - Available ATR expansion range = 23.6% through 400%
//
// • Position
//   - ATR timeframe = 3M
//   - Label tag = P
//   - Available ATR expansion range = 23.6% through 400%
//
// • Long-Term
//   - ATR timeframe = 12M
//   - Label tag = LT
//   - Available ATR expansion range = 23.6% through 400%
//
// Recommended chart timeframe guide:
//
// • Daily mode
//   - Best used on intraday charts such as 1m through 1h
//   - Designed for day/session-level ATR context
//
// • Multiday mode
//   - Best used on intraday-to-short-swing charts such as 10m through 2h
//   - Designed for weekly ATR context across multiple trading days
//
// • Swing mode
//   - Best used on 30m through 1D charts
//   - Designed for monthly ATR context across larger swing moves
//
// • Position mode
//   - Best used on 4h through 1W charts
//   - Designed for 3-month ATR context across position-style moves
//
// • Long-Term mode
//   - Best used on 1D through 1M charts
//   - Designed for 12-month ATR context across major long-term ranges
//
// These are recommended viewing ranges, not hard restrictions. Lower chart timeframes provide
// more detail inside each ATR period, while higher chart timeframes provide a cleaner big-picture
// view with fewer candles inside each ATR period.
//
// Core ATR behavior:
//
// • ATR levels are rendered with persistent line arrays, not repeated plot calls
// • ATR labels are rendered with persistent label arrays
// • Only the selected ATR mode renders at one time
// • All ATR modes can render the full 23.6% through 400% expansion range
// • Default ATR Level Display = Proximity Aware:
//   - only the active price side of PCL / CC is shown
//   - 23.6% through 100% are the initial ladder
//   - crossing each outer level unlocks exactly one next expansion tier
// • Full Range preserves the existing range / side Show-Hide controls
// • ATR lines can begin from:
//   - active period start
//   - Last N Bars
//   - Last N historical ATR periods
// • Historical ATR Periods mode keeps prior ATR grid segments visible so users can review
//   how price interacted with previous ATR periods
// • Historical labels are intentionally excluded to keep the chart clean
//
// PCL / CC behavior:
//
// • PCL / CC overlay line and label are included
// • The PCL / CC label uses the same anchor as the selected ATR grid
// • PCL / CC label can show:
//   - anchor price
//   - selected timeframe close-to-close percent change
//   - source RSI(14)
//   - PCL or CC tag
// • The percent-change row is tagged by source timeframe:
//   - D Δ for Daily
//   - W Δ for Multiday
//   - M Δ for Swing
//   - 3M Δ for Position
//   - 12M Δ for Long-Term
//
// Mode-aware AVWAP behavior:
//
// • ATR Session AVWAPs follow the currently selected ATR mode
// • Daily mode can show:
//   - Session VWAP from the active ATR day/session start
//   - High AVWAP anchored from the active day/session high
//   - Low AVWAP anchored from the active day/session low
// • Multiday mode can show the same VWAP set from the active weekly ATR period
// • Swing mode can show the same VWAP set from the active monthly ATR period
// • Position mode can show the same VWAP set from the active 3-month ATR period
// • Long-Term mode can show the same VWAP set from the active 12-month ATR period
// • High and Low AVWAPs re-anchor when a new active-period high or low forms
// • Session VWAP uses the selected VWAP source, defaulting to HLC3
// • AVWAP paths use streaming point arrays and time-based polylines to avoid deep historical
//   offset issues on lower timeframes
//
// Mode-aware high / low box behavior:
//
// • ATR Session High / Low Boxes follow the same selected ATR mode as the AVWAP engine
// • High Box starts from the candle that creates the active session/period high
// • Low Box starts from the candle that creates the active session/period low
// • New highs/lows re-anchor their respective box
// • Box height is based on the anchor candle wick, with an optional long-wick limit
// • Boxes use time-based coordinates and require real horizontal width before rendering,
//   which helps avoid zero-width box artifacts on fresh anchor bars
//
// Mode-aware session fib label behavior:
//
// • ATR Session Fib Labels use the same active ATR session/period high and low anchors
//   tracked by the AVWAP and High / Low Box engines
// • The labels show internal fib retracement context inside the active session/period range
// • Fib direction is inferred from the order of the active extremes:
//   - Low formed before high = bullish session leg
//   - High formed before low = bearish session leg
// • Bullish session leg:
//   - 0 anchors at the active high
//   - 1 anchors at the active low
// • Bearish session leg:
//   - 0 anchors at the active low
//   - 1 anchors at the active high
// • This creates a second layer of context beside the ATR grid:
//   - ATR levels show expansion from the selected close anchor
//   - Session fib labels show retracement/position inside the active high-to-low range
// • Labels can show fib ratio, price, and percent distance from current price
// • Labels use bull/bear fib color families for easier directional reading
//
// Additional visuals:
//
// • Current price guide dash aligned with the ATR label column
// • Optional PCL / CC stepline plot
// • Optional period open line
// • Optional ATR Session Fib Labels for active high/low retracement context
// • Optional plotcandle overlay with separate body, wick, and border transparency controls
//
// Asset-aware behavior:
//
// • Stocks use a selectable regular/extended source ticker for ATR calculations
// • Daily stock lines can begin from Regular Open or Extended Open
// • Daily stock AVWAPs, high/low boxes, and fib labels reset from the extended-session /
//   premarket day start when available
// • Multiday / Swing / Position / Long-Term stock lines wait for the first regular-hours bar
//   of the new higher-timeframe period to better match Saty-style visual starts
// • Crypto uses the chart ticker and resets Daily AVWAPs, boxes, and fib labels once per
//   calendar day
// • Futures use the chart ticker
// • Daily futures use a Globex-style 5:00 PM Central session boundary
// • Higher-timeframe futures AVWAPs, boxes, and fib labels reset from the selected
//   W / M / 3M / 12M ATR period boundary
//
// Notes:
//
// • ATR length is canonically hardcoded at 14.
// • Current / Previous HTF Close and ATR14 are requested explicitly with dedicated remote history,
//   so ATR levels remain available and price-identical on low chart timeframes such as 1m / 3m / 5m.
// • CPU gating follows Pine-safe ownership:
//   - hidden presentation features skip object / string / color work where practical
//   - history-dependent ta.* kernels remain continuously evaluated
//   - shared session range state runs only when Boxes or Session Fib Labels require it
// • ATR grid values come from the selected higher-timeframe source.
// • Open lines, historical line starts, AVWAP anchors, and high/low box anchors are chart-candle based.
// • ATR Session Fib Labels are chart-candle based and use the active ATR session/period high and low.
// • Historical ATR Periods mode uses line objects, so the period count is intentionally capped.
// • AVWAP paths require available chart volume.
// • High / Low Boxes use box objects and are intentionally limited to one active high box and one active low box.
// • For closest AVWAP, box, and fib-label alignment, use a chart session that matches the intended asset/session view.
//

import SimpleCryptoLife/SignificantFigures/4 as SCL_SigFig

// ==============================================================================================
// 🟢 REGION: Constants
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: Limits
// ──────────────────────────────────────────────
const int SPACER_MAX = 200
const int OBJECT_LINE_MAX_BACK = 4900
const int ATR_LEN = 14
const int ATR_DATA_REQUEST_BARS = 256
const int ATR_REFERENCE_REQUEST_BARS = 256

// ──────────────────────────────────────────────
// 🟦 Subregion: Shared Display Strings
// ──────────────────────────────────────────────
const string SHOW = "Show"
const string HIDE = "Hide"

const string HIST_CURRENT = "Current Period Only"
const string HIST_PERIODS = "Last N Periods"

const string ATR_DISPLAY_PROXIMITY = "Proximity Aware"
const string ATR_DISPLAY_FULL = "Full Range"

// ──────────────────────────────────────────────
// 🟦 Subregion: ATR Mode Strings
// ──────────────────────────────────────────────
const string MODE_DAILY    = "Daily"
const string MODE_MULTI    = "Weekly"
const string MODE_SWING    = "Monthly"
const string MODE_POSITION = "3 Month"
const string MODE_LONGTERM = "12 Month"

// ──────────────────────────────────────────────
// 🟦 Subregion: Input Groups
// ──────────────────────────────────────────────
const string G_ENGINE       = "ATR Mode / Engine"
const string G_ATR_1        = "23.6% to 100% ATR Settings"
const string G_ATR_2        = "123.6% to 200% ATR Settings"
const string G_ATR_3        = "223.6% to 300% ATR Settings"
const string G_ATR_4        = "323.6% to 400% ATR Settings"
const string G_COLORS       = "ATR Level Colors"
const string G_PCL          = "Previous / Current Close"
const string G_OPEN         = "Period Open Line"
const string G_AVWAP        = "ATR Session Auto VWAP"
const string G_GUIDE        = "Price Guide Dash"
const string G_CANDLES      = "Price Candles"
const string G_HILO_BOXES   = "ATR Session High / Low Boxes"
const string G_SESSION_FIBS = "ATR Session Fib Labels"
const string G_DEBUG        = "Debug"

// ──────────────────────────────────────────────
// 🟦 Subregion: AVWAP Mode Strings
// ──────────────────────────────────────────────
const string AVWAP_SHOW_ALL      = "Show All"
const string AVWAP_SESSION_ONLY  = "Session VWAP Only"
const string AVWAP_HIGH_LOW_ONLY = "High / Low Only"
const string AVWAP_HIGH_ONLY     = "High Only"
const string AVWAP_LOW_ONLY      = "Low Only"

const string BOX_SHOW_BOTH = "Show Both"
const string BOX_HIGH_ONLY = "High Only"
const string BOX_LOW_ONLY  = "Low Only"

// ──────────────────────────────────────────────
// 🟦 Subregion: Tooltip Strings — ATR Engine
// ──────────────────────────────────────────────
const string TT_MODE_TIMEFRAME_GUIDE =
     "Recommended chart timeframe guide:\n\n" +
     "• Daily: 1m through 1h\n" +
     "• Weekly (Multiday): 10m through 2h\n" +
     "• Monthly (Swing): 30m through 1D\n" +
     "• 3 Month (Position): 4h through 1W\n" +
     "• 12 Month (Long-Term): 1D through 1M\n\n" +
     "These are recommended viewing ranges, not hard restrictions.\n\n" +
     "Lower chart timeframes provide more detail inside each ATR period. Higher chart timeframes provide a cleaner big-picture view with fewer candles inside each ATR period."

const string TT_MODE =
     "Selects the ATR engine that renders on the chart.\n\n" +
     "Daily = daily ATR grid.\n" +
     "Weekly (Multiday) = weekly ATR grid.\n" +
     "Monthly (Swing) = monthly ATR grid.\n" +
     "3 Month (Position) = 3-month ATR grid.\n" +
     "12 Month (Long-Term) = 12-month ATR grid.\n\n" +
     TT_MODE_TIMEFRAME_GUIDE + "\n\n" +
     "Only one mode renders at a time, which keeps the chart clean."

const string TT_MODE_CAP =
     "All ATR modes can use the full 23.6% through 400% expansion range.\n\n" +
     "The 323.6% to 400% range remains hidden by default and can be enabled from its own line and label controls.\n\n" +
     "Each ATR range still respects its parent Show / Hide setting and its individual upper/lower child controls."

const string TT_ANCHOR =
     "Controls whether ATR levels anchor from the previous higher-timeframe close or the active higher-timeframe close.\n\n" +
     "Auto = Daily stocks use Current Close during New York premarket / after-hours and Previous Close during regular hours.\n\n" +
     "Multiday, Swing, Position, and Long-Term use Previous Close in Auto mode.\n\n" +
     "On = force Current Close.\nOff = force Previous Close."

const string TT_ATR_SOURCE =
     "Controls the stock/fund source ticker used for ATR calculations.\n\n" +
     "Extended generally matches the classic Saty-style ATR behavior more closely for stocks that trade premarket/after-hours.\n\n" +
     "Crypto and futures use the chart ticker."

const string TT_ATR_PROXIMITY =
     "Controls how the current ATR expansion ladder is presented.\n\n" +
     "Proximity Aware — DEFAULT:\n" +
     "• Only the side of PCL / CC containing current price is shown.\n" +
     "• The active side initially shows 23.6% through 100%.\n" +
     "• Crossing 100% unlocks 123.6%.\n" +
     "• Crossing 123.6% unlocks 138.2%, and so on.\n" +
     "• The ladder keeps all already-unlocked levels back toward PCL / CC.\n" +
     "• Proximity Lines and Proximity Labels can be hidden independently.\n\n" +
     "Full Range:\n" +
     "Uses the existing ATR range and upper / lower Show-Hide controls."

const string TT_LINE_LENGTH =
     "Controls how far back the ATR lines are drawn.\n\n" +
     "Period Start = begin at the active day/week/month start.\n" +
     "Last N Bars = only draw across the most recent number of bars."

const string TT_ATR_HISTORY =
     "Controls how ATR level lines are drawn historically.\n\n" +
     "Current Period Only = ATR levels begin from the active period start, matching the cleaner object-line behavior.\n\n" +
     "Last N Periods = keeps ATR line segments from prior completed periods so you can see how price interacted with older ATR grids.\n\n" +
     "Because this uses line objects, very high values can approach TradingView's line-object limit."

// ──────────────────────────────────────────────
// 🟦 Subregion: Tooltip Strings — ATR Lines / Labels
// ──────────────────────────────────────────────
const string TT_ATR_LINES =
     "Shows or hides the ATR level lines for this range.\n\n" +
     "The script uses persistent line objects instead of many plot calls. This keeps the engine cleaner and makes it easier to manage extension ranges."

const string TT_ATR_LABELS =
     "Shows or hides the ATR labels for this range.\n\n" +
     "Labels are controlled separately from lines so you can keep levels visible while reducing label clutter."

const string TT_LABEL_PADDING =
     "Controls horizontal label padding using em-space text padding.\n\n" +
     "Higher values visually move the label column farther right without relying on a large bar-index offset."

const string TT_ATR_PCT_FROM_PRICE =
     "Shows where current price is relative to each ATR level.\n\n" +
     "The ATR level is the denominator:\n" +
     "• Positive = current price is above that level\n" +
     "• Negative = current price is below that level"

// ──────────────────────────────────────────────
// 🟦 Subregion: Tooltip Strings — PCL / CC
// ──────────────────────────────────────────────
const string TT_PCL_LABEL =
     "Shows the selected mode's close-reference label.\n\n" +
     "Rows can include:\n" +
     "• anchor price\n" +
     "• close-to-close percent change\n" +
     "• RSI(14) from the selected ATR timeframe\n" +
     "• PCL or CC tag"

// ──────────────────────────────────────────────
// 🟦 Subregion: Tooltip Strings — ATR Session AVWAP
// ──────────────────────────────────────────────
const string TT_ATR_SESSION_AVWAP =
     "Shows mode-aware AVWAP paths for the selected ATR session.\n\n" +
     "Show All = session VWAP + high AVWAP + low AVWAP.\n" +
     "Session VWAP Only = one VWAP from the selected ATR period/session start.\n" +
     "High / Low Only = only the high-anchor and low-anchor AVWAPs.\n" +
     "High Only = only the current session/period high AVWAP.\n" +
     "Low Only = only the current session/period low AVWAP.\n" +
     "Hide = hide all ATR session AVWAP paths.\n\n" +
     "Reset behavior:\n" +
     "• Daily stocks/funds reset from premarket / extended-session day start when available.\n" +
     "• Crypto resets once per calendar day.\n" +
     "• Daily futures reset once at the Globex-style 5:00 PM Central session boundary.\n" +
     "• Multiday, Swing, Position, and Long-Term reset from the selected higher-timeframe ATR period.\n\n" +
     "For smoother AVWAP paths, use chart timeframes that provide enough candles inside the selected ATR period. For example, Daily mode is usually best viewed on lower intraday charts, while Position and Long-Term modes are usually cleaner on higher intraday, daily, weekly, or monthly charts."

// ──────────────────────────────────────────────
// 🟦 Subregion: Tooltip Strings — Price Guide
// ──────────────────────────────────────────────
const string TT_PRICE_GUIDE =
     "Shows one text-based dashed guide at current price.\n\n" +
     "The guide uses the same ATR label padding so it lines up with the right-side ATR label column."

// ──────────────────────────────────────────────
// 🟦 Subregion: Tooltip Strings — 23.6% to 100% Parent Controls
// ──────────────────────────────────────────────
const string TT_ATR1_LINES_PARENT =
     "Master control for the 23.6% to 100% ATR line range.\n\n" +
     "Show = allow the upper/lower child line toggles below to control their side.\n" +
     "Hide = hide all 23.6% to 100% upper and lower lines, regardless of the child settings."

const string TT_ATR1_LABELS_PARENT =
     "Master control for the 23.6% to 100% ATR label range.\n\n" +
     "Show = allow the upper/lower child label toggles below to control their side.\n" +
     "Hide = hide all 23.6% to 100% upper and lower labels, regardless of the child settings."

// ──────────────────────────────────────────────
// 🟦 Subregion: Tooltip Strings — 123.6% to 200% Parent Controls
// ──────────────────────────────────────────────
const string TT_ATR2_LINES_PARENT =
     "Master control for the 123.6% to 200% ATR line range.\n\n" +
     "Show = allow the upper/lower child line toggles below to control their side.\n" +
     "Hide = hide all 123.6% to 200% upper and lower lines, regardless of the child settings."

const string TT_ATR2_LABELS_PARENT =
     "Master control for the 123.6% to 200% ATR label range.\n\n" +
     "Show = allow the upper/lower child label toggles below to control their side.\n" +
     "Hide = hide all 123.6% to 200% upper and lower labels, regardless of the child settings."

// ──────────────────────────────────────────────
// 🟦 Subregion: Tooltip Strings — 223.6% to 300% Parent Controls
// ──────────────────────────────────────────────
const string TT_ATR3_LINES_PARENT =
     "Master control for the 223.6% to 300% ATR line range.\n\n" +
     "Show = allow the upper/lower child line toggles below to control their side.\n" +
     "Hide = hide all 223.6% to 300% upper and lower lines, regardless of the child settings."

const string TT_ATR3_LABELS_PARENT =
     "Master control for the 223.6% to 300% ATR label range.\n\n" +
     "Show = allow the upper/lower child label toggles below to control their side.\n" +
     "Hide = hide all 223.6% to 300% upper and lower labels, regardless of the child settings."

// ──────────────────────────────────────────────
// 🟦 Subregion: Tooltip Strings — 323.6% to 400% Parent Controls
// ──────────────────────────────────────────────
const string TT_ATR4_LINES_PARENT =
     "Master control for the 323.6% to 400% ATR line range.\n\n" +
     "Show = allow the upper/lower child line toggles below to control their side.\n" +
     "Hide = hide all 323.6% to 400% upper and lower lines, regardless of the child settings."

const string TT_ATR4_LABELS_PARENT =
     "Master control for the 323.6% to 400% ATR label range.\n\n" +
     "Show = allow the upper/lower child label toggles below to control their side.\n" +
     "Hide = hide all 323.6% to 400% upper and lower labels, regardless of the child settings."

// ──────────────────────────────────────────────
// 🟦 Subregion: Tooltip Strings — ATR Engine Inputs
// ──────────────────────────────────────────────
const string TT_ATR_HISTORY_PERIODS =
     "Only used when ATR Level History is set to Last N Periods.\n\n" +
     "Each period can use up to 48 line objects, so the max is intentionally capped to protect the script from hitting TradingView's object limit."

const string TT_ATR_LINE_LAST_N =
     "Only used when ATR Level Line Length is set to Last N Bars."

const string TT_DAILY_STOCK_LINE_START =
     "Only applies to Daily mode on stocks/funds.\n\n" +
     "Regular Open = Daily ATR lines begin at the first regular-hours bar.\n" +
     "Extended Open = Daily ATR lines begin at the first extended-session / premarket bar when available."

const string TT_ATR_LABEL_PRICES =
     "Show = include the ATR level price in each label.\n" +
     "Hide = show the ATR ratio and mode tag only."

// ──────────────────────────────────────────────
// 🟦 Subregion: Tooltip Strings — PCL / CC
// ──────────────────────────────────────────────
const string TT_PCL_STEPLINE =
     "Show = adds a classic plot-based PCL / CC stepline.\n" +
     "Hide = only uses the cleaner object-based overlay line."

// ──────────────────────────────────────────────
// 🟦 Subregion: Tooltip Strings — Period Open Line
// ──────────────────────────────────────────────
const string TT_PERIOD_OPEN_LINE =
     "Shows the selected mode's active period open.\n\n" +
     "Daily = day/session open.\n" +
     "Multiday = week open.\n" +
     "Swing = month open.\n" +
     "Position = 3-month period open.\n" +
     "Long-Term = 12-month period open."

// ──────────────────────────────────────────────
// 🟦 Subregion: Tooltip Strings — Price Candles
// ──────────────────────────────────────────────
const string TT_PRICE_CANDLES =
     "Shows a simple plotcandle overlay colored by the current candle body.\n\n" +
     "Bull candle = close >= open.\n" +
     "Bear candle = close < open.\n\n" +
     "Body, wick, and border transparency can be controlled separately."

// ──────────────────────────────────────────────
// 🟦 Subregion: Tooltip Strings — ATR Session High / Low Boxes
// ──────────────────────────────────────────────
const string TT_ATR_SESSION_HILO_BOXES =
     "Draws mode-aware boxes from the active ATR session/period high and low.\n\n" +
     "High Box = starts from the candle that creates the active session/period high and extends right.\n" +
     "Low Box = starts from the candle that creates the active session/period low and extends right.\n\n" +
     "Box height is wick-based:\n" +
     "• High Box uses the anchor candle's upper wick.\n" +
     "• Low Box uses the anchor candle's lower wick.\n\n" +
     "If the anchor wick is very long, the box can be limited to only the outer portion of that wick. This keeps large wick events visible without letting the box take over the chart.\n\n" +
     "Reset behavior follows the same selected ATR session logic used by ATR Session AVWAPs."

const string TT_ATR_SESSION_BOX_LONG_WICK_TRIGGER =
     "Defines what counts as a very long wick.\n\n" +
     "The script compares the anchor candle wick to the chart timeframe ATR.\n\n" +
     "Example:\n" +
     "• 1.0 = wick is longer than 1 chart ATR\n" +
     "• 2.0 = wick is longer than 2 chart ATR"

const string TT_ATR_SESSION_BOX_LONG_WICK_LIMIT =
     "Controls how much of a very long wick is used for the box.\n\n" +
     "Example:\n" +
     "• 25% means the High Box only uses the top 25% of a very long upper wick.\n" +
     "• 25% means the Low Box only uses the bottom 25% of a very long lower wick."

// ──────────────────────────────────────────────
// 🟦 Subregion: Tooltip Strings — ATR Session Fib Labels
// ──────────────────────────────────────────────
const string TT_ATR_SESSION_FIB_LABELS =
     "Shows fib labels between the active ATR session/period high and low.\n\n" +
     "These labels add internal range context beside the ATR expansion grid.\n\n" +
     "ATR levels show how far price has expanded from the selected close anchor.\n" +
     "Session fib labels show where price is trading inside the active high-to-low session range.\n\n" +
     "Direction is inferred from the order of the active extremes:\n" +
     "• Low formed before high = bullish session leg\n" +
     "• High formed before low = bearish session leg\n\n" +
     "Bullish leg:\n" +
     "• 0 anchors at the active high\n" +
     "• 1 anchors at the active low\n\n" +
     "Bearish leg:\n" +
     "• 0 anchors at the active low\n" +
     "• 1 anchors at the active high"

const string TT_ATR_SESSION_FIB_SHOW_PRICE =
     "Show = include the price of each ATR Session Fib Label.\n" +
     "Hide = show the fib ratio and optional percent-from-price only."

const string TT_ATR_SESSION_FIB_SHOW_PCT =
     "Show = include the percent distance from current price to each ATR Session Fib Label.\n\n" +
     "This helps compare the active price location against the internal session high/low fib structure."

const string TT_ATR_SESSION_FIB_LABEL_PADDING =
     "Controls horizontal label padding using em-space text padding.\n\n" +
     "Higher values visually move the ATR Session Fib Label column farther right."

const string TT_ATR_SESSION_FIB_LABEL_SIZE =
     "Controls the text size used by the ATR Session Fib Labels."

// ==============================================================================================
// 🔴 END REGION: Constants
// ==============================================================================================


// ==============================================================================================
// 🟢 REGION: Inputs
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: ATR Mode / Engine
// ──────────────────────────────────────────────
// Mode selection
string in_atrMode = input.string(defval=MODE_DAILY, title="ATR Mode", options=[MODE_DAILY, MODE_MULTI, MODE_SWING, MODE_POSITION, MODE_LONGTERM], group=G_ENGINE, tooltip=TT_MODE)

// Anchor / source
string in_anchorMode = input.string(defval="Auto", title="Use Current Close", options=["Auto", "On", "Off"], group=G_ENGINE, tooltip=TT_ANCHOR)
string in_stockSourceSession = input.string(defval="Extended", title="Stock ATR Source Session", options=["Regular", "Extended"], group=G_ENGINE, tooltip=TT_ATR_SOURCE)

// Historical ATR periods
string in_atrHistoryMode = input.string(defval=HIST_CURRENT, title="ATR Level History", options=[HIST_CURRENT, HIST_PERIODS], group=G_ENGINE, tooltip=TT_ATR_HISTORY)
int in_atrHistoryPeriods = input.int(defval=3, title="  ↳ Historical ATR Periods", minval=1, maxval=8, group=G_ENGINE, tooltip=TT_ATR_HISTORY_PERIODS)

// ATR line length
string in_atrLineLengthMode = input.string(defval="Period Start", title="ATR Level Line Length", options=["Period Start", "Last N Bars"], group=G_ENGINE, tooltip=TT_LINE_LENGTH)
int in_atrLineLastNBars = input.int(defval=150, title="  ↳ ATR Level Last N Bars", minval=1, maxval=5000, group=G_ENGINE, tooltip=TT_ATR_LINE_LAST_N)
string in_dailyStartMode = input.string(defval="Regular Open", title="  ↳ Daily Stock Line Start", options=["Regular Open", "Extended Open"], group=G_ENGINE, tooltip=TT_DAILY_STOCK_LINE_START)

// ATR calculation
// ATR length is canonically hardcoded at 14.
int in_sigFig = input.int(defval=4, title="SigFig - Prices", minval=2, maxval=20, group=G_ENGINE)

// 🔹 Proximity-Aware ATR Grid
string in_atrDisplayMode = input.string(defval=ATR_DISPLAY_PROXIMITY, title="ATR Level Display", options=[ATR_DISPLAY_PROXIMITY, ATR_DISPLAY_FULL], group=G_ENGINE, tooltip=TT_ATR_PROXIMITY)
bool useAtrProximity = in_atrDisplayMode == ATR_DISPLAY_PROXIMITY

string in_proximityLinesMode = input.string(defval=SHOW, title="  ↳ Proximity Lines", options=[SHOW, HIDE], group=G_ENGINE, active=useAtrProximity, tooltip=TT_ATR_PROXIMITY)
string in_proximityLabelsMode = input.string(defval=SHOW, title="  ↳ Proximity Labels", options=[SHOW, HIDE], group=G_ENGINE, active=useAtrProximity, tooltip=TT_ATR_PROXIMITY)

// ATR label display
string in_showPricesMode = input.string(defval=SHOW, title="ATR Label Prices", options=[SHOW, HIDE], group=G_ENGINE, tooltip=TT_ATR_LABEL_PRICES)
string in_showAtrPctFromPriceMode = input.string(defval=SHOW, title="ATR Label % / $ From Current Price", options=[SHOW, HIDE], group=G_ENGINE, tooltip=TT_ATR_PCT_FROM_PRICE)
int in_atrLabelPadding = input.int(defval=22, title="ATR Label Padding", minval=0, maxval=SPACER_MAX, group=G_ENGINE, tooltip=TT_LABEL_PADDING)
string in_atrLabelSize = input.string(defval="Normal", title="ATR Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=G_ENGINE)

// ATR line style
int in_atrLineWidth = input.int(defval=1, title="ATR Line Width", minval=1, maxval=5, group=G_ENGINE)
string in_atrLineStyle = input.string(defval="Solid", title="ATR Line Style", options=["Solid", "Dotted", "Dashed"], group=G_ENGINE)

// ──────────────────────────────────────────────
// 🟦 Subregion: 23.6% to 100%
// ──────────────────────────────────────────────
// Lines
string in_atr1LinesMode = input.string(defval=SHOW, title="23.6% to 100% Lines", options=[SHOW, HIDE], group=G_ATR_1, tooltip=TT_ATR1_LINES_PARENT)
string in_atr1UpperLinesMode = input.string(defval=SHOW, title="  ↳ Upper Lines", options=[SHOW, HIDE], group=G_ATR_1, tooltip=TT_ATR_LINES)
string in_atr1LowerLinesMode = input.string(defval=SHOW, title="  ↳ Lower Lines", options=[SHOW, HIDE], group=G_ATR_1, tooltip=TT_ATR_LINES)

// Labels
string in_atr1LabelsMode = input.string(defval=SHOW, title="23.6% to 100% Labels", options=[SHOW, HIDE], group=G_ATR_1, tooltip=TT_ATR1_LABELS_PARENT)
string in_atr1UpperLabelsMode = input.string(defval=SHOW, title="  ↳ Upper Labels", options=[SHOW, HIDE], group=G_ATR_1, tooltip=TT_ATR_LABELS)
string in_atr1LowerLabelsMode = input.string(defval=SHOW, title="  ↳ Lower Labels", options=[SHOW, HIDE], group=G_ATR_1, tooltip=TT_ATR_LABELS)

// ──────────────────────────────────────────────
// 🟦 Subregion: 123.6% to 200%
// ──────────────────────────────────────────────
// Lines
string in_atr2LinesMode = input.string(defval=HIDE, title="123.6% to 200% Lines", options=[SHOW, HIDE], group=G_ATR_2, tooltip=TT_ATR2_LINES_PARENT)
string in_atr2UpperLinesMode = input.string(defval=SHOW, title="  ↳ Upper Lines", options=[SHOW, HIDE], group=G_ATR_2, tooltip=TT_ATR_LINES)
string in_atr2LowerLinesMode = input.string(defval=SHOW, title="  ↳ Lower Lines", options=[SHOW, HIDE], group=G_ATR_2, tooltip=TT_ATR_LINES)

// Labels
string in_atr2LabelsMode = input.string(defval=HIDE, title="123.6% to 200% Labels", options=[SHOW, HIDE], group=G_ATR_2, tooltip=TT_ATR2_LABELS_PARENT)
string in_atr2UpperLabelsMode = input.string(defval=SHOW, title="  ↳ Upper Labels", options=[SHOW, HIDE], group=G_ATR_2, tooltip=TT_ATR_LABELS)
string in_atr2LowerLabelsMode = input.string(defval=SHOW, title="  ↳ Lower Labels", options=[SHOW, HIDE], group=G_ATR_2, tooltip=TT_ATR_LABELS)

// ──────────────────────────────────────────────
// 🟦 Subregion: 223.6% to 300%
// ──────────────────────────────────────────────
// Lines
string in_atr3LinesMode = input.string(defval=HIDE, title="223.6% to 300% Lines", options=[SHOW, HIDE], group=G_ATR_3, tooltip=TT_ATR3_LINES_PARENT + "\n\n" + TT_MODE_CAP)
string in_atr3UpperLinesMode = input.string(defval=SHOW, title="  ↳ Upper Lines", options=[SHOW, HIDE], group=G_ATR_3, tooltip=TT_ATR_LINES + "\n\n" + TT_MODE_CAP)
string in_atr3LowerLinesMode = input.string(defval=SHOW, title="  ↳ Lower Lines", options=[SHOW, HIDE], group=G_ATR_3, tooltip=TT_ATR_LINES + "\n\n" + TT_MODE_CAP)

// Labels
string in_atr3LabelsMode = input.string(defval=HIDE, title="223.6% to 300% Labels", options=[SHOW, HIDE], group=G_ATR_3, tooltip=TT_ATR3_LABELS_PARENT + "\n\n" + TT_MODE_CAP)
string in_atr3UpperLabelsMode = input.string(defval=SHOW, title="  ↳ Upper Labels", options=[SHOW, HIDE], group=G_ATR_3, tooltip=TT_ATR_LABELS + "\n\n" + TT_MODE_CAP)
string in_atr3LowerLabelsMode = input.string(defval=SHOW, title="  ↳ Lower Labels", options=[SHOW, HIDE], group=G_ATR_3, tooltip=TT_ATR_LABELS + "\n\n" + TT_MODE_CAP)

// ──────────────────────────────────────────────
// 🟦 Subregion: 323.6% to 400%
// ──────────────────────────────────────────────

// Lines
string in_atr4LinesMode = input.string(defval=HIDE, title="323.6% to 400% Lines", options=[SHOW, HIDE], group=G_ATR_4, tooltip=TT_ATR4_LINES_PARENT + "\n\n" + TT_MODE_CAP)
string in_atr4UpperLinesMode = input.string(defval=SHOW, title="  ↳ Upper Lines", options=[SHOW, HIDE], group=G_ATR_4, tooltip=TT_ATR_LINES + "\n\n" + TT_MODE_CAP)
string in_atr4LowerLinesMode = input.string(defval=SHOW, title="  ↳ Lower Lines", options=[SHOW, HIDE], group=G_ATR_4, tooltip=TT_ATR_LINES + "\n\n" + TT_MODE_CAP)

// Labels
string in_atr4LabelsMode = input.string(defval=HIDE, title="323.6% to 400% Labels", options=[SHOW, HIDE], group=G_ATR_4, tooltip=TT_ATR4_LABELS_PARENT + "\n\n" + TT_MODE_CAP)
string in_atr4UpperLabelsMode = input.string(defval=SHOW, title="  ↳ Upper Labels", options=[SHOW, HIDE], group=G_ATR_4, tooltip=TT_ATR_LABELS + "\n\n" + TT_MODE_CAP)
string in_atr4LowerLabelsMode = input.string(defval=SHOW, title="  ↳ Lower Labels", options=[SHOW, HIDE], group=G_ATR_4, tooltip=TT_ATR_LABELS + "\n\n" + TT_MODE_CAP)

// ──────────────────────────────────────────────
// 🟦 Subregion: ATR Colors
// ──────────────────────────────────────────────
// Upper ATR colors
color c_ATR236 = input.color(defval=color.aqua, title="23.6% Color", group=G_COLORS)
color c_ATR382 = input.color(defval=color.teal, title="38.2% Color", group=G_COLORS)
color c_ATR500 = input.color(defval=color.rgb(223, 175, 0), title="50.0% Color", group=G_COLORS)
color c_ATR618 = input.color(defval=color.rgb(255, 149, 88), title="61.8% Color", group=G_COLORS)
color c_ATR786 = input.color(defval=color.rgb(254, 116, 37), title="78.6% Color", group=G_COLORS)
color c_ATR100 = input.color(defval=color.rgb(255, 94, 0), title="100% Color", group=G_COLORS)

// Lower ATR colors
color c_ATR_N236 = input.color(defval=#d1d1d1da, title="-23.6% Color", group=G_COLORS)
color c_ATR_N382 = input.color(defval=color.rgb(119, 119, 119), title="-38.2% Color", group=G_COLORS)
color c_ATR_N500 = input.color(defval=#ff7979, title="-50.0% Color", group=G_COLORS)
color c_ATR_N618 = input.color(defval=color.rgb(250, 71, 181), title="-61.8% Color", group=G_COLORS)
color c_ATR_N786 = input.color(defval=#e91a66, title="-78.6% Color", group=G_COLORS)
color c_ATR_N100 = input.color(defval=#9f32d2, title="-100% Color", group=G_COLORS)

// ──────────────────────────────────────────────
// 🟦 Subregion: Previous / Current Close
// ──────────────────────────────────────────────
// Overlay line / label
string in_pclLineMode = input.string(defval=SHOW, title="PCL / CC Overlay Line", options=[SHOW, HIDE], group=G_PCL)
string in_pclLabelMode = input.string(defval=SHOW, title="PCL / CC Label", options=[SHOW, HIDE], group=G_PCL, tooltip=TT_PCL_LABEL)

// Label rows
string in_pclShowPriceMode = input.string(defval=SHOW, title="  ↳ Label Price", options=[SHOW, HIDE], group=G_PCL)
string in_pclShowPctMode = input.string(defval=SHOW, title="  ↳ Label % Change", options=[SHOW, HIDE], group=G_PCL)
string in_pclShowRsiMode = input.string(defval=SHOW, title="  ↳ Label RSI(14)", options=[SHOW, HIDE], group=G_PCL)

// Line style / color
string in_pclLineStyle = input.string(defval="Dotted", title="PCL / CC Line Style", options=["Solid", "Dotted", "Dashed"], group=G_PCL)
int in_pclLineWidth = input.int(defval=1, title="PCL / CC Line Width", minval=1, maxval=5, group=G_PCL)
color c_prevClose = input.color(defval=#0051ff, title="PCL / CC Label & Line Color", group=G_PCL)

// Stepline plot
string in_pclPlotMode = input.string(defval=HIDE, title="PCL / CC Stepline Plot", options=[SHOW, HIDE], group=G_PCL, tooltip=TT_PCL_STEPLINE)
string in_pclPlotStyle = input.string(defval="Stepline", title="  ↳ Stepline Plot Style", options=["Stepline", "Circles"], group=G_PCL)

// ──────────────────────────────────────────────
// 🟦 Subregion: Period Open Line
// ──────────────────────────────────────────────
// Display
string in_openLineMode = input.string(defval=HIDE, title="Period Open Overlay Line", options=[SHOW, HIDE], group=G_OPEN, tooltip=TT_PERIOD_OPEN_LINE)

// Line style / color
string in_openLineStyle = input.string(defval="Dotted", title="Open Line Style", options=["Solid", "Dotted", "Dashed"], group=G_OPEN)
int in_openLineWidth = input.int(defval=1, title="Open Line Width", minval=1, maxval=5, group=G_OPEN)
color c_openLine = input.color(defval=#2c48ff, title="Open Line Color", group=G_OPEN)

// ──────────────────────────────────────────────
// 🟦 Subregion: ATR Session Auto VWAP
// ──────────────────────────────────────────────
// Display
string in_atrSessionAvwapMode = input.string(defval=AVWAP_SHOW_ALL, title="ATR Session AVWAP", options=[AVWAP_SHOW_ALL, AVWAP_SESSION_ONLY, AVWAP_HIGH_LOW_ONLY, AVWAP_HIGH_ONLY, AVWAP_LOW_ONLY, HIDE], group=G_AVWAP, tooltip=TT_ATR_SESSION_AVWAP)

// Session VWAP source
float in_atrSessionVwapSource = input.source(defval=hlc3, title="  ↳ Session VWAP Source", group=G_AVWAP)

// Draw limits / style
int in_atrSessionAvwapMaxBars = input.int(defval=6500, title="  ↳ Max Draw Bars", minval=25, maxval=6900, group=G_AVWAP)
int in_atrSessionAvwapWidth = input.int(defval=1, title="  ↳ Line Width", minval=1, maxval=5, group=G_AVWAP)
string in_atrSessionAvwapStyle_high_low = input.string(defval="Dashed", title="  ↳ High/Low Line Style", options=["Solid", "Dotted", "Dashed"], group=G_AVWAP)
string in_atrSessionAvwapStyle_hlc3 = input.string(defval="Dotted", title="  ↳ HLC3 Line Style", options=["Solid", "Dotted", "Dashed"], group=G_AVWAP)
int in_atrSessionAvwapTransp = input.int(defval=0, title="  ↳ Transparency", minval=0, maxval=100, group=G_AVWAP)

// Colors
color in_atrSessionVwapColor = input.color(defval=#00e5ff, title="  ↳ Session VWAP Color", group=G_AVWAP)
color in_atrSessionHighAvwapColor = input.color(defval=#ff005d, title="  ↳ High AVWAP Color", group=G_AVWAP)
color in_atrSessionLowAvwapColor = input.color(defval=#ffe81d, title="  ↳ Low AVWAP Color", group=G_AVWAP)

// ──────────────────────────────────────────────
// 🟦 Subregion: Price Guide
// ──────────────────────────────────────────────
string in_priceGuideMode = input.string(defval=SHOW, title="Price Guide Dash", options=[SHOW, HIDE], group=G_GUIDE, tooltip=TT_PRICE_GUIDE)
int in_priceGuideLen = input.int(defval=20, title="  ↳ Guide Length", minval=3, maxval=80, group=G_GUIDE)
color in_priceGuideColor = input.color(defval=color.new(color.white, 5), title="  ↳ Guide Color", group=G_GUIDE)

// ──────────────────────────────────────────────
// 🟦 Subregion: Price Candles
// ──────────────────────────────────────────────

// Display
string in_priceCandlesMode = input.string(defval=HIDE, title="Price Candles", options=[SHOW, HIDE], group=G_CANDLES, tooltip=TT_PRICE_CANDLES)

// Bull / bear colors
color in_candleBull = input.color(defval=color.new(color.yellow, 0), title="  ↳ Bull Candle", group=G_CANDLES, active=in_priceCandlesMode == SHOW)
color in_candleBear = input.color(defval=color.new(color.purple, 0), title="  ↳ Bear Candle", group=G_CANDLES, active=in_priceCandlesMode == SHOW)

// Transparency
int in_candleTransp = input.int(defval=80, title="  ↳ Body Transparency", minval=0, maxval=100, group=G_CANDLES, active=in_priceCandlesMode == SHOW)
int in_candleWickTransp = input.int(defval=0, title="  ↳ Wick Transparency", minval=0, maxval=100, group=G_CANDLES, active=in_priceCandlesMode == SHOW)
int in_candleBorderTransp = input.int(defval=0, title="  ↳ Border Transparency", minval=0, maxval=100, group=G_CANDLES, active=in_priceCandlesMode == SHOW)

// ──────────────────────────────────────────────
// 🟦 Subregion: ATR Session High / Low Boxes
// ──────────────────────────────────────────────

// Display
string in_atrSessionBoxMode = input.string(defval=HIDE, title="ATR Session High / Low Boxes", options=[BOX_SHOW_BOTH, BOX_HIGH_ONLY, BOX_LOW_ONLY, HIDE], group=G_HILO_BOXES, tooltip=TT_ATR_SESSION_HILO_BOXES)

// Wick sizing
float in_atrSessionBoxLongWickAtrMult = input.float(defval=1.5, title="  ↳ Long Wick Trigger (Chart ATR)", minval=0.1, maxval=10.0, step=0.25, group=G_HILO_BOXES, active=in_atrSessionBoxMode != HIDE, tooltip=TT_ATR_SESSION_BOX_LONG_WICK_TRIGGER)
float in_atrSessionBoxLongWickLimitPct = input.float(defval=25.0, title="  ↳ Long Wick Limit (% Wick)", minval=1.0, maxval=100.0, step=1.0, group=G_HILO_BOXES, active=in_atrSessionBoxMode != HIDE, tooltip=TT_ATR_SESSION_BOX_LONG_WICK_LIMIT)

// Transparency
int in_atrSessionBoxFillTransp = input.int(defval=90, title="  ↳ Fill Transparency", minval=0, maxval=100, group=G_HILO_BOXES, active=in_atrSessionBoxMode != HIDE)
int in_atrSessionBoxBorderTransp = input.int(defval=80, title="  ↳ Border Transparency", minval=0, maxval=100, group=G_HILO_BOXES, active=in_atrSessionBoxMode != HIDE)

// Colors
color in_atrSessionHighBoxColor = input.color(defval=#ff005d, title="  ↳ High Box Color", group=G_HILO_BOXES, active=in_atrSessionBoxMode != HIDE)
color in_atrSessionLowBoxColor = input.color(defval=#ffe81d, title="  ↳ Low Box Color", group=G_HILO_BOXES, active=in_atrSessionBoxMode != HIDE)

// ──────────────────────────────────────────────
// 🟦 Subregion: ATR Session Fib Labels
// ──────────────────────────────────────────────

// Display
string in_atrSessionFibLabelsMode = input.string(defval=SHOW, title="ATR Session Fib Labels", options=[SHOW, HIDE], group=G_SESSION_FIBS, tooltip=TT_ATR_SESSION_FIB_LABELS)

// Label rows
string in_atrSessionFibShowPriceMode = input.string(defval=SHOW, title="  ↳ Show Price", options=[SHOW, HIDE], group=G_SESSION_FIBS, tooltip=TT_ATR_SESSION_FIB_SHOW_PRICE)
string in_atrSessionFibShowPctMode = input.string(defval=SHOW, title="  ↳ Show % / $ From Current Price", options=[SHOW, HIDE], group=G_SESSION_FIBS, tooltip=TT_ATR_SESSION_FIB_SHOW_PCT)

// Label style
int in_atrSessionFibLabelPadding = input.int(defval=22, title="  ↳ Label Padding", minval=0, maxval=SPACER_MAX, group=G_SESSION_FIBS, tooltip=TT_ATR_SESSION_FIB_LABEL_PADDING)
string in_atrSessionFibLabelSize = input.string(defval="Normal", title="  ↳ Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=G_SESSION_FIBS, tooltip=TT_ATR_SESSION_FIB_LABEL_SIZE)

// ──────────────────────────────────────────────
// 🟦 Subregion: Debug
// ──────────────────────────────────────────────
string in_debugLabelMode = input.string(defval=HIDE, title="Period-Change Debug Label", options=[SHOW, HIDE], group=G_DEBUG)

// ==============================================================================================
// 🔴 END REGION: Inputs
// ==============================================================================================


// ==============================================================================================
// 🟢 REGION: Helpers
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: Spacer Engine
// ──────────────────────────────────────────────
var string[] spacers = na

if na(spacers)
    spacers := array.new_string()
    for i = 0 to SPACER_MAX
        array.push(spacers, str.repeat(" ", i))

f_spacer(int _n) =>
    int n = math.min(math.max(_n, 0), SPACER_MAX)
    array.get(spacers, n)

// ──────────────────────────────────────────────
// 🟦 Subregion: Formatters
// ──────────────────────────────────────────────

// Number / string formatters
f_trimLeadingZero(string _s) =>
    string s = _s
    if str.startswith(s, "-0.")
        s := "-" + str.substring(s, 2)
    else if str.startswith(s, "0.")
        s := str.substring(s, 1)
    s

f_sigFigsVolume(float _val, int _sigFigs) =>
    float absVal = math.abs(_val)
    float divisor = absVal >= 1e9 ? 1e9 : absVal >= 1e6 ? 1e6 : absVal >= 1e3 ? 1e3 : 1
    string suffix = absVal >= 1e9 ? "b" : absVal >= 1e6 ? "m" : absVal >= 1e3 ? "k" : ""
    float rounded = absVal / divisor
    string sign = _val < 0 ? "-" : ""
    sign + str.tostring(SCL_SigFig.sigFig(rounded, _sigFigs)) + suffix

f_priceStr(float _val, int _sigFigs) =>
    na(_val) ? "" : f_sigFigsVolume(_val, _sigFigs)

f_formatSignedPercent(float _pct) =>
    if na(_pct)
        ""
    else
        float r = math.round(_pct * 100.0) / 100.0
        if r == 0
            "0%"
        else
            string s = str.tostring(math.abs(r), "#.##")
            s := f_trimLeadingZero(s)
            (r > 0 ? "+" : "-") + s + "%"

f_formatPlainPercent(float _pct) =>
    if na(_pct)
        ""
    else
        float r = math.round(math.abs(_pct) * 100.0) / 100.0
        string s = str.tostring(r, "#.##")
        s := f_trimLeadingZero(s)
        s + "%"

f_formatLevelPercent(float _pct) =>
    if na(_pct)
        ""
    else
        float roundedPct = math.round(_pct * 100.0) / 100.0

        if roundedPct == 0.0
            "0%"
        else
            string pctText = str.tostring(math.abs(roundedPct), "#.##")
            pctText := f_trimLeadingZero(pctText)

            // Below level = minus sign.
            // Above level = no plus sign.
            (roundedPct < 0.0 ? "-" : "") + pctText + "%"

f_formatLevelDollar(float _delta) =>
    if na(_delta)
        ""
    else
        float roundedDelta = math.round(_delta * 100.0) / 100.0
        string dollarText = str.tostring(math.abs(roundedDelta), "0.00")
        dollarText := f_trimLeadingZero(dollarText)

        // Below level = -$.64.
        // Above level = $.64 with no plus sign.
        (roundedDelta < 0.0 ? "-$" : "$") + dollarText

f_formatRsi(float _val) =>
    na(_val) ? "" : str.tostring(_val, "#.0")

f_roundToMintick(float _v) =>
    na(_v) ? na : math.round(_v / syminfo.mintick) * syminfo.mintick

f_pctFromCurrentPrice(float _level) =>
    float lvl = f_roundToMintick(_level)
    float px = f_roundToMintick(close)
    na(lvl) or na(px) or lvl == 0.0 ? na : ((px - lvl) / lvl) * 100.0

f_dollarFromCurrentPrice(float _level) =>
    float lvl = f_roundToMintick(_level)
    float px = f_roundToMintick(close)

    na(lvl) or na(px) ? na : px - lvl
    
// Label text builders
f_buildPclLabel(string _priceStr, string _pctStr, string _rsiStr, string _tag, string _modeTag, string _deltaTag, string _spacer) =>
    string priceLine = _priceStr != "" ? _spacer + _priceStr + "\n" : ""
    string pctLine = _pctStr != "" ? _spacer + _deltaTag + " Δ " + _pctStr + "\n" : ""
    string rsiLine = _rsiStr != "" ? _spacer + "RSI " + _rsiStr + "\n" : ""
    priceLine + pctLine + rsiLine + _spacer + _tag + " -" + _modeTag
    
// ──────────────────────────────────────────────
// 🟦 Subregion: Style Helpers
// ──────────────────────────────────────────────
f_labelSize(string _input) =>
    switch _input
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.normal

f_lineStyle(string _input) =>
    switch _input
        "Solid"  => line.style_solid
        "Dotted" => line.style_dotted
        "Dashed" => line.style_dashed
        => line.style_solid

f_dashText(int _n) =>
    string s = str.repeat("- ", _n)
    str.length(s) > 0 ? str.substring(s, 0, str.length(s) - 1) : s

// ──────────────────────────────────────────────
// 🟦 Subregion: Object Sync Helpers
// ──────────────────────────────────────────────
color invisibleColor = color.new(color.black, 100)

f_syncLine(line _id, bool _show, int _x1, float _y, int _x2, color _color, int _width, _style) =>
    line _ln = _id
    int safeX1 = na(_x1) ? bar_index : math.min(math.max(_x1, bar_index - OBJECT_LINE_MAX_BACK), _x2)

    if _show and not na(_y)
        if na(_ln)
            _ln := line.new(x1=safeX1, y1=_y, x2=_x2, y2=_y, xloc=xloc.bar_index, extend=extend.none, color=_color, width=_width, style=_style)
        else
            line.set_xy1(_ln, safeX1, _y)
            line.set_xy2(_ln, _x2, _y)
            line.set_color(_ln, _color)
            line.set_width(_ln, _width)
            line.set_style(_ln, _style)
    else if not na(_ln)
        line.delete(_ln)
        _ln := na

    _ln

f_syncLabel(label _id, bool _show, float _y, string _text, color _textColor, _labelSize) =>
    label _lbl = _id

    if _show and not na(_y)
        if na(_lbl)
            _lbl := label.new(x=bar_index, y=_y, text=_text, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_center, color=invisibleColor, textcolor=_textColor, size=_labelSize)
        else
            label.set_xy(_lbl, bar_index, _y)
            label.set_text(_lbl, _text)
            label.set_textcolor(_lbl, _textColor)
            label.set_size(_lbl, _labelSize)
    else if not na(_lbl)
        label.delete(_lbl)
        _lbl := na

    _lbl

// ──────────────────────────────────────────────
// 🟦 Subregion: ATR Session Fib Label Array Helpers
// ──────────────────────────────────────────────
//
// Purpose:
//     Maintains the persistent label array used by ATR Session Fib Labels.
//
f_clearAtrSessionFibLabels(array<label> _store) =>
    int n = array.size(_store)

    if n > 0
        for i = n - 1 to 0 by -1
            label oldLabel = array.get(_store, i)

            if not na(oldLabel)
                label.delete(oldLabel)

    array.clear(_store)

f_syncAtrSessionFibLabelArray(array<label> _store, int _needed, float _fallbackY, string _size) =>
    while array.size(_store) < _needed
        label newLabel = label.new(x=bar_index, y=_fallbackY, text="", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=invisibleColor, textcolor=color.white, size=_size)
        array.push(_store, newLabel)

    while array.size(_store) > _needed
        label oldLabel = array.pop(_store)

        if not na(oldLabel)
            label.delete(oldLabel)

// ──────────────────────────────────────────────
// 🟦 Subregion: Time-Based Box Sync Helper
// ──────────────────────────────────────────────
//
// Purpose:
//     Syncs one persistent time-based box object using bar-time coordinates.
//
f_syncTimeBox(box _id, bool _show, int _leftTime, int _rightTime, float _top, float _bottom, color _fillColor, color _borderColor) =>
    box _bx = _id

    bool validBox =
         _show and
         not na(_leftTime) and
         not na(_rightTime) and
         _rightTime > _leftTime and
         not na(_top) and
         not na(_bottom) and
         _top > _bottom

    if validBox
        if na(_bx)
            _bx := box.new(left=_leftTime, top=_top, right=_rightTime, bottom=_bottom, xloc=xloc.bar_time, bgcolor=_fillColor, border_color=_borderColor)
        else
            box.set_left(_bx, _leftTime)
            box.set_right(_bx, _rightTime)
            box.set_top(_bx, _top)
            box.set_bottom(_bx, _bottom)
            box.set_bgcolor(_bx, _fillColor)
            box.set_border_color(_bx, _borderColor)
    else if not na(_bx)
        box.delete(_bx)
        _bx := na

    _bx

// ──────────────────────────────────────────────
// 🟦 Subregion: ATR Session Fib Label Color Helpers
// ──────────────────────────────────────────────
//
// Purpose:
//     Defines the directional fib label color families used by ATR Session Fib Labels.
//
color atrFibBull_0_236   = #ff8800
color atrFibBull_236_382 = #ff6600
color atrFibBull_382_50  = color.rgb(255, 163, 24)
color atrFibBull_50_618  = color.yellow
color atrFibBull_618_786 = color.new(color.teal, 0)
color atrFibBull_786_100 = color.new(color.aqua, 0)
color atrFibBull_1_only  = #aafd99

color atrFibBear_0_236   = color.rgb(134, 4, 255)
color atrFibBear_236_382 = color.rgb(180, 100, 255)
color atrFibBear_382_50  = color.rgb(255, 116, 197)
color atrFibBear_50_618  = #ff6666
color atrFibBear_618_786 = #a0a0a0
color atrFibBear_786_100 = #d4d4d4
color atrFibBear_1_only  = #a0e4ff

f_atrSessionFibColor(float _level, int _dir) =>
    bool isOne = math.abs(_level - 1.0) < 0.000001

    _dir == 1 ?
         (isOne ? atrFibBull_1_only :
          _level >= 0.786 ? atrFibBull_786_100 :
          _level >= 0.618 ? atrFibBull_618_786 :
          _level >= 0.500 ? atrFibBull_50_618 :
          _level >= 0.382 ? atrFibBull_382_50 :
          _level >= 0.236 ? atrFibBull_236_382 :
          atrFibBull_0_236) :
     _dir == -1 ?
         (isOne ? atrFibBear_1_only :
          _level >= 0.786 ? atrFibBear_786_100 :
          _level >= 0.618 ? atrFibBear_618_786 :
          _level >= 0.500 ? atrFibBear_50_618 :
          _level >= 0.382 ? atrFibBear_382_50 :
          _level >= 0.236 ? atrFibBear_236_382 :
          atrFibBear_0_236) :
     color.new(color.gray, 0)

// ──────────────────────────────────────────────
// 🟦 Subregion: ATR Session Fib Label Text Helpers
// ──────────────────────────────────────────────
//
// Purpose:
//     Builds compact ratio / price / percent text for ATR Session Fib Labels.
//
f_atrSessionFibRatioText(float _level) =>
    math.abs(_level - 0.0) < 0.000001 ? "0" :
     math.abs(_level - 0.5) < 0.000001 ? ".50" :
     math.abs(_level - 1.0) < 0.000001 ? "1" :
     str.replace(str.tostring(_level, "#.###"), "0.", ".")

f_atrSessionFibLabelText(float _level, float _price) =>
    string pad = f_spacer(in_atrSessionFibLabelPadding)
    string ratioText = f_atrSessionFibRatioText(_level)

    string priceText =
         in_atrSessionFibShowPriceMode == SHOW ?
         " - " + f_priceStr(_price, in_sigFig) :
         ""

    bool showChange = in_atrSessionFibShowPctMode == SHOW

    float pctFromPrice = f_pctFromCurrentPrice(_price)
    float dollarFromPrice = f_dollarFromCurrentPrice(_price)

    string pctText =
         showChange ?
         f_formatLevelPercent(pctFromPrice) :
         ""

    string dollarText =
         showChange ?
         f_formatLevelDollar(dollarFromPrice) :
         ""

    string changeText = pctText != "" ? pctText + (dollarText != "" ? " / " + dollarText : "") : ""

    string changeLine =
         changeText != "" ?
         "\n" + pad + changeText :
         ""

    // First row: fib ratio and price.
    // Second row: percent and dollar distance.
    pad + ratioText + priceText + changeLine

// ==============================================================================================
// 🔴 END REGION: Helpers
// ==============================================================================================


// ==============================================================================================
// 🟢 REGION: Mode Engine
// ==============================================================================================
//
// Purpose:
//     Converts the selected ATR mode into the active timeframe, label tag, and available
//     expansion range.
//
// Behavior:
//     • Daily uses D data and can render through 400%
//     • Multiday uses W data and can render through 400%
//     • Swing uses M data and can render through 400%
//     • Position uses 3M data and can render through 400%
//     • Long-Term uses 12M data and can render through 400%
//     • Range flags are kept for clean visibility control and future flexibility.
//
bool isDailyMode    = in_atrMode == MODE_DAILY
bool isMultiMode    = in_atrMode == MODE_MULTI
bool isSwingMode    = in_atrMode == MODE_SWING
bool isPositionMode = in_atrMode == MODE_POSITION
bool isLongTermMode = in_atrMode == MODE_LONGTERM

string atrTf =
     isDailyMode    ? "D"   :
     isMultiMode    ? "W"   :
     isSwingMode    ? "M"   :
     isPositionMode ? "3M"  : "12M"

string atrTag =
     isDailyMode    ? " D"  :
     isMultiMode    ? " W"  :
     isSwingMode    ? " M"  :
     isPositionMode ? " 3M"  : "12M"

int modeRangeCap = 4

bool allowRange1 = modeRangeCap >= 1
bool allowRange2 = modeRangeCap >= 2
bool allowRange3 = modeRangeCap >= 3
bool allowRange4 = modeRangeCap >= 4

// ==============================================================================================
// 🔴 END REGION: Mode Engine
// ==============================================================================================


// ==============================================================================================
// 🟢 REGION: Period Start Engine
// ==============================================================================================
//
// Purpose:
//     Detects the active ATR period start for stocks, crypto, and futures, then stores the
//     period open and starting bar used by ATR lines, open lines, historical segments, and AVWAPs.
//
// Behavior:
//     • Daily stocks can start from Regular Open or Extended Open
//     • Daily crypto resets once per calendar day
//     • Daily futures reset from the 5:00 PM Central Globex-style boundary
//     • Multiday / Swing / Position / Long-Term stocks wait for the first RTH bar of the new W / M / 3M / 12M period
//     • Multiday / Swing / Position / Long-Term crypto and futures use the raw higher-timeframe boundary
//     • Last N Bars mode overrides the period-start line anchor with a rolling lookback window.
//
bool isCrypto = syminfo.type == "crypto"
bool isFutures = syminfo.type == "futures"
bool isStocks = not isCrypto and not isFutures

string rthSession = "0930-1600"
string extSession = "0400-2000"
string futGlobexSessionCT = "1700-1600:1234567"

bool inRTH = isStocks and not na(time(timeframe.period, rthSession))
bool prevInRTH = isStocks and not na(time(timeframe.period, rthSession)[1])
bool isRTH_Open = isStocks and inRTH and not prevInRTH

bool inEXT = isStocks and not na(time(timeframe.period, extSession))
bool prevInEXT = isStocks and not na(time(timeframe.period, extSession)[1])
bool isEXT_Open = isStocks and inEXT and not prevInEXT

bool isNewCalendarDay = ta.change(time("D")) != 0
bool isCryptoDailyStart = isCrypto and isNewCalendarDay

int futGlobexDayKey = time("D", futGlobexSessionCT, "America/Chicago")
int futGlobexDayKeyChange = ta.change(futGlobexDayKey)
bool futGlobexDayChanged = not na(futGlobexDayKeyChange) and futGlobexDayKeyChange != 0

int futCtMins = hour(time, "America/Chicago") * 60 + minute(time, "America/Chicago")
int futCtMinsPrev = nz(futCtMins[1], futCtMins)
bool futGlobexClockOpen = isFutures and timeframe.isintraday and futCtMins >= 17 * 60 and futCtMinsPrev < 17 * 60

bool futuresDailyStart = isFutures and (futGlobexDayChanged or futGlobexClockOpen)

bool stockDailyStart =
     isStocks and (
         in_dailyStartMode == "Regular Open" ? isRTH_Open :
         isEXT_Open or isNewCalendarDay)

bool dailyStartTrig =
     isDailyMode and (
         stockDailyStart or
         isCryptoDailyStart or
         futuresDailyStart or
         barstate.isfirst)

// ──────────────────────────────────────────────
// 🟦 Subregion: Higher-Timeframe Period Start
// ──────────────────────────────────────────────
//
// Multiday / Swing / Position / Long-Term stock behavior:
// • Wait for the first regular-hours bar of the new W / M / 3M / 12M period.
// • This matches the visual Saty-style start better than starting from premarket.
//
// Non-stock behavior:
// • Crypto/futures use the raw W / M / 3M / 12M higher-timeframe boundary.
//
// Shared behavior:
// • Updates the active period open and start bar.
// • Provides the start anchor used by ATR lines, open lines, historical segments, and AVWAPs.
//
int chartPeriodKey = time(atrTf)
int chartPeriodKeyChange = ta.change(chartPeriodKey)
bool chartPeriodChanged = not na(chartPeriodKeyChange) and chartPeriodKeyChange != 0

var int stockActiveHtfPeriodKey = na

bool stockHtfStartTrig =
     not isDailyMode and
     isStocks and
     inRTH and
     (na(stockActiveHtfPeriodKey) or chartPeriodKey != stockActiveHtfPeriodKey)

bool nonStockHtfStartTrig =
     not isDailyMode and
     not isStocks and
     (chartPeriodChanged or barstate.isfirst)

bool periodStartTrig = dailyStartTrig or stockHtfStartTrig or nonStockHtfStartTrig

var float periodOpen = na
var int periodStartBar = na

if barstate.isfirst
    periodOpen := open
    periodStartBar := bar_index

if periodStartTrig
    periodOpen := open
    periodStartBar := bar_index

    if stockHtfStartTrig
        stockActiveHtfPeriodKey := chartPeriodKey

periodOpen := nz(periodOpen, periodOpen[1])

int activeStartBar = na(periodStartBar) ? bar_index : periodStartBar

int atrLevelStartBar =
     in_atrLineLengthMode == "Last N Bars" ?
         math.max(bar_index - in_atrLineLastNBars + 1, 0) :
         activeStartBar

// ==============================================================================================
// 🔴 END REGION: Period Start Engine
// ==============================================================================================


// ==============================================================================================
// 🟢 REGION: ATR Data Engine
// ==============================================================================================
//
// Purpose:
//     Builds the selected ATR mode’s source symbol, close anchor, ATR value, and supporting
//     higher-timeframe reference values used by the grid, PCL / CC label, and ATR levels.
//
// Behavior:
//     • Stocks can use Regular or Extended session source data
//     • Crypto and futures use the chart ticker
//     • Auto Current Close only applies to Daily stocks during premarket / after-hours
//     • On forces the active higher-timeframe close / ATR14
//     • Off forces the previous completed higher-timeframe close / ATR14
//     • Current / Previous HTF values are requested explicitly, then selected locally
//     • ATR14 requests carry a dedicated 256-bar HTF history budget
//     • ATR levels are calculated from the selected close anchor plus ATR multiples.
//

// Source symbol
string stockAtrSymbol =
     ticker.new(
         prefix=syminfo.prefix,
         ticker=syminfo.ticker,
         session=in_stockSourceSession == "Regular" ? session.regular : session.extended)

string atrSymbol = isStocks ? stockAtrSymbol : syminfo.tickerid

// Current Close timing window
int nyHourNow = hour(timenow, "America/New_York")
int nyMinNow = minute(timenow, "America/New_York")
int nyNowMins = nyHourNow * 60 + nyMinNow

bool nyPremarketNow = nyNowMins >= 4 * 60 and nyNowMins < 9 * 60 + 30
bool nyAfterHoursNow = nyNowMins >= 16 * 60 and nyNowMins < 20 * 60

// Effective close anchor
bool useCurrentCloseAuto = isDailyMode and isStocks and (nyPremarketNow or nyAfterHoursNow)

bool useCurrentCloseEff =
     in_anchorMode == "On" ? true :
     in_anchorMode == "Off" ? false : useCurrentCloseAuto

// ATR anchor / value
// Request explicit Current / Previous HTF values, then choose locally.
// Dedicated remote history prevents low chart timeframes from starving ATR14 warm-up.
[atrCurrentCloseHtf, atrPreviousCloseHtf, atrCurrentValueHtf, atrPreviousValueHtf] =
     request.security(
         atrSymbol,
         atrTf,
         [close, close[1], ta.atr(ATR_LEN), ta.atr(ATR_LEN)[1]],
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_on,
         calc_bars_count=ATR_DATA_REQUEST_BARS)

float atrAnchorClose =
     useCurrentCloseEff ?
     atrCurrentCloseHtf :
     atrPreviousCloseHtf

float atrValue =
     useCurrentCloseEff ?
     atrCurrentValueHtf :
     atrPreviousValueHtf

// Higher-timeframe reference values
[prevCloseHtf, curCloseHtf, prevPrevCloseHtf, prevRsi14Htf, curRsi14Htf] =
     request.security(
         atrSymbol,
         atrTf,
         [close[1], close, close[2], ta.rsi(close, 14)[1], ta.rsi(close, 14)],
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off,
         calc_bars_count=ATR_REFERENCE_REQUEST_BARS)

// ATR level helper
float baseClose_ATR = atrAnchorClose

f_atrLevel(float _mult) =>
    baseClose_ATR + atrValue * _mult

// ==============================================================================================
// 🔴 END REGION: ATR Data Engine
// ==============================================================================================


// ==============================================================================================
// 🟢 REGION: Previous / Current Close and Open Lines
// ==============================================================================================
//
// Purpose:
//     Renders the selected mode’s close-reference line/label and optional active-period open line.
//
// Behavior:
//     • PCL / CC uses the same anchor as the active ATR grid
//     • CC mode shows active higher-timeframe close data
//     • PCL mode shows previous completed higher-timeframe close data
//     • Label rows can include price, percent change, RSI(14), and PCL / CC tag
//     • Period Open Line follows the selected mode’s active day / week / month / 3-month / 12-month open.
//

// ──────────────────────────────────────────────
// 🟦 Subregion: PCL / CC Line and Label
// ──────────────────────────────────────────────

// Object state
var line pclLine = na
var label pclLabel = na

// Close-reference state
bool ccMode = useCurrentCloseEff
string pclTag = ccMode ? "CC" : "PCL"

float labelAnchor = baseClose_ATR
float labelRsi = ccMode ? curRsi14Htf : prevRsi14Htf

// Percent-change data
float labelPct =
     ccMode ?
         na(curCloseHtf) or na(prevCloseHtf) or prevCloseHtf == 0.0 ? na : ((curCloseHtf - prevCloseHtf) / prevCloseHtf) * 100.0 :
         na(prevCloseHtf) or na(prevPrevCloseHtf) or prevPrevCloseHtf == 0.0 ? na : ((prevCloseHtf - prevPrevCloseHtf) / prevPrevCloseHtf) * 100.0

// Label text
string pclSpacer = f_spacer(in_atrLabelPadding)
string pclPriceStr = in_pclShowPriceMode == SHOW ? f_priceStr(labelAnchor, in_sigFig) : ""
string pclPctStr = in_pclShowPctMode == SHOW ? f_formatSignedPercent(labelPct) : ""
string pclRsiStr = in_pclShowRsiMode == SHOW ? f_formatRsi(labelRsi) : ""
string pclDeltaTag = atrTf
string pclLabelText = f_buildPclLabel(pclPriceStr, pclPctStr, pclRsiStr, pclTag, atrTag, pclDeltaTag, pclSpacer)

// Render
if barstate.islast
    pclLine := f_syncLine(pclLine, in_pclLineMode == SHOW, activeStartBar, labelAnchor, bar_index, c_prevClose, in_pclLineWidth, f_lineStyle(in_pclLineStyle))
    pclLabel := f_syncLabel(pclLabel, in_pclLabelMode == SHOW, labelAnchor, pclLabelText, c_prevClose, f_labelSize(in_atrLabelSize))

// ──────────────────────────────────────────────
// 🟦 Subregion: Period Open Line
// ──────────────────────────────────────────────

// Object state
var line openLine = na

// Render — presentation-gated
if barstate.islast and in_openLineMode == SHOW
    openLine := f_syncLine(openLine, true, activeStartBar, periodOpen, bar_index, c_openLine, in_openLineWidth, f_lineStyle(in_openLineStyle))

// ==============================================================================================
// 🔴 END REGION: Previous / Current Close and Open Lines
// ==============================================================================================


// ==============================================================================================
// 🟢 REGION: ATR Grid Data
// ==============================================================================================
//
// Purpose:
//     Stores the reusable ATR multiplier, label text, color, line, and label arrays used by
//     the ATR grid engine.
//
// Behavior:
//     • Multiplier arrays define each positive ATR expansion range
//     • Text arrays provide the matching label ratio strings
//     • Color arrays map upper and lower ATR levels to user-selected colors
//     • Line and label stores keep persistent objects synced instead of recreating them
//

// ATR multipliers
var float[] ATR_MULTS_1 = array.from(0.236, 0.382, 0.500, 0.618, 0.786, 1.000)
var float[] ATR_MULTS_2 = array.from(1.236, 1.382, 1.500, 1.618, 1.786, 2.000)
var float[] ATR_MULTS_3 = array.from(2.236, 2.382, 2.500, 2.618, 2.786, 3.000)
var float[] ATR_MULTS_4 = array.from(3.236, 3.382, 3.500, 3.618, 3.786, 4.000)

// ATR label text
var string[] ATR_TEXT_1 = array.from("23.6%", "38.2%", "50%", "61.8%", "78.6%", "100%")
var string[] ATR_TEXT_2 = array.from("123.6%", "138.2%", "150%", "161.8%", "178.6%", "200%")
var string[] ATR_TEXT_3 = array.from("223.6%", "238.2%", "250%", "261.8%", "278.6%", "300%")
var string[] ATR_TEXT_4 = array.from("323.6%", "338.2%", "350%", "361.8%", "378.6%", "400%")

// ATR colors
var color[] ATR_COLORS_UP = array.from(c_ATR236, c_ATR382, c_ATR500, c_ATR618, c_ATR786, c_ATR100)
var color[] ATR_COLORS_DN = array.from(c_ATR_N236, c_ATR_N382, c_ATR_N500, c_ATR_N618, c_ATR_N786, c_ATR_N100)

// Persistent object stores
var line[] atrLineStore = array.new_line(48)
var label[] atrLabelStore = array.new_label(48)

// ──────────────────────────────────────────────
// 🟦 Subregion: Proximity-Aware Tier State
// ──────────────────────────────────────────────

// 🔹 Side ownership follows current price versus the active PCL / CC anchor.
// Exact anchor equality retains the prior side to avoid one-tick flicker.
var int atrProximitySide = 1

if not na(baseClose_ATR) and not na(close)
    if close > baseClose_ATR
        atrProximitySide := 1
    else if close < baseClose_ATR
        atrProximitySide := -1

// 🔹 Absolute progress from PCL / CC in ATR14 units.
float atrProximityProgress =
     not na(baseClose_ATR) and
     not na(atrValue) and
     atrValue > 0.0 ?
     math.abs(close - baseClose_ATR) / atrValue :
     na

// 🔹 Initial cap = 100%; each crossed outer tier unlocks exactly one next tier.
f_atrProximityMaxMult(float _progress) =>
    float p = nz(_progress, 0.0)

    p <= 1.000 ? 1.000 :
     p <= 1.236 ? 1.236 :
     p <= 1.382 ? 1.382 :
     p <= 1.500 ? 1.500 :
     p <= 1.618 ? 1.618 :
     p <= 1.786 ? 1.786 :
     p <= 2.000 ? 2.000 :
     p <= 2.236 ? 2.236 :
     p <= 2.382 ? 2.382 :
     p <= 2.500 ? 2.500 :
     p <= 2.618 ? 2.618 :
     p <= 2.786 ? 2.786 :
     p <= 3.000 ? 3.000 :
     p <= 3.236 ? 3.236 :
     p <= 3.382 ? 3.382 :
     p <= 3.500 ? 3.500 :
     p <= 3.618 ? 3.618 :
     p <= 3.786 ? 3.786 :
     4.000

float atrProximityMaxMult = f_atrProximityMaxMult(atrProximityProgress)

bool showProximityLines = in_proximityLinesMode == SHOW
bool showProximityLabels = in_proximityLabelsMode == SHOW

// ==============================================================================================
// 🔴 END REGION: ATR Grid Data
// ==============================================================================================


// ==============================================================================================
// 🟢 REGION: ATR Grid Engine
// ==============================================================================================
//
// Purpose:
//     Builds, updates, and renders the active ATR grid using persistent line and label objects.
//
// Behavior:
//     • Current Period Only mode updates one live line/label object per ATR level
//     • Last N Periods mode stores historical ATR line segments from prior selected ATR periods
//     • Visibility flags respect parent line/label controls, child upper/lower controls, and mode caps
//     • Labels remain current-period only to keep historical mode clean
//

// ──────────────────────────────────────────────
// 🟦 Subregion: Label Builder
// ──────────────────────────────────────────────
f_buildAtrLabelText(string _ratioText, float _level) =>
    string pad = f_spacer(in_atrLabelPadding)

    string priceText =
         in_showPricesMode == SHOW ?
         " - " + f_priceStr(_level, in_sigFig) :
         ""

    bool showChange = in_showAtrPctFromPriceMode == SHOW

    float pctFromPrice = f_pctFromCurrentPrice(_level)
    float dollarFromPrice = f_dollarFromCurrentPrice(_level)

    string pctText =
         showChange ?
         f_formatLevelPercent(pctFromPrice) :
         ""

    string dollarText =
         showChange ?
         f_formatLevelDollar(dollarFromPrice) :
         ""

    string changeText = pctText != "" ? pctText + (dollarText != "" ? " / " + dollarText : "") : ""

    string changeLine =
         changeText != "" ?
         "\n" + pad + changeText :
         ""

    pad + _ratioText + priceText + " -" + atrTag + changeLine

// ──────────────────────────────────────────────
// 🟦 Subregion: Current ATR Line and Label Sync
// ──────────────────────────────────────────────
f_syncAtrBlock(int _offset, float[] _mults, string[] _texts, color[] _colors, bool _showLines, bool _showLabels, int _side) =>
    int blockSize = array.size(_mults)

    for i = 0 to blockSize - 1
        float rawMult = array.get(_mults, i)
        float signedMult = rawMult * _side
        float level = f_atrLevel(signedMult)
        color levelColor = array.get(_colors, i)
        string ratioText = (_side < 0 ? "-" : "") + array.get(_texts, i)

        int objectIndex = _offset + i

        line ln = array.get(atrLineStore, objectIndex)
        label lbl = array.get(atrLabelStore, objectIndex)

        bool proximitySideMatch = _side == atrProximitySide
        bool proximityTierVisible = proximitySideMatch and rawMult <= atrProximityMaxMult

        bool effectiveShowLines =
             useAtrProximity ?
             showProximityLines and proximityTierVisible :
             _showLines

        bool effectiveShowLabels =
             useAtrProximity ?
             showProximityLabels and proximityTierVisible :
             _showLabels

        bool showCurrentObjectLine = effectiveShowLines and in_atrHistoryMode == HIST_CURRENT

        string atrLabelText = effectiveShowLabels ? f_buildAtrLabelText(ratioText, level) : ""

        ln := f_syncLine(ln, showCurrentObjectLine, atrLevelStartBar, level, bar_index, levelColor, in_atrLineWidth, f_lineStyle(in_atrLineStyle))
        lbl := f_syncLabel(lbl, effectiveShowLabels, level, atrLabelText, levelColor, f_labelSize(in_atrLabelSize))

        array.set(atrLineStore, objectIndex, ln)
        array.set(atrLabelStore, objectIndex, lbl)

// ──────────────────────────────────────────────
// 🟦 Subregion: Visibility Flags
// ──────────────────────────────────────────────

// 23.6% to 100%
bool showAtr1LinesParent = in_atr1LinesMode == SHOW
bool showAtr1LabelsParent = in_atr1LabelsMode == SHOW

bool showAtr1UpLines = allowRange1 and showAtr1LinesParent and in_atr1UpperLinesMode == SHOW
bool showAtr1DnLines = allowRange1 and showAtr1LinesParent and in_atr1LowerLinesMode == SHOW
bool showAtr1UpLabels = allowRange1 and showAtr1LabelsParent and in_atr1UpperLabelsMode == SHOW
bool showAtr1DnLabels = allowRange1 and showAtr1LabelsParent and in_atr1LowerLabelsMode == SHOW

// 123.6% to 200%
bool showAtr2LinesParent = in_atr2LinesMode == SHOW
bool showAtr2LabelsParent = in_atr2LabelsMode == SHOW

bool showAtr2UpLines = allowRange2 and showAtr2LinesParent and in_atr2UpperLinesMode == SHOW
bool showAtr2DnLines = allowRange2 and showAtr2LinesParent and in_atr2LowerLinesMode == SHOW
bool showAtr2UpLabels = allowRange2 and showAtr2LabelsParent and in_atr2UpperLabelsMode == SHOW
bool showAtr2DnLabels = allowRange2 and showAtr2LabelsParent and in_atr2LowerLabelsMode == SHOW

// 223.6% to 300%
bool showAtr3LinesParent = in_atr3LinesMode == SHOW
bool showAtr3LabelsParent = in_atr3LabelsMode == SHOW

bool showAtr3UpLines = allowRange3 and showAtr3LinesParent and in_atr3UpperLinesMode == SHOW
bool showAtr3DnLines = allowRange3 and showAtr3LinesParent and in_atr3LowerLinesMode == SHOW
bool showAtr3UpLabels = allowRange3 and showAtr3LabelsParent and in_atr3UpperLabelsMode == SHOW
bool showAtr3DnLabels = allowRange3 and showAtr3LabelsParent and in_atr3LowerLabelsMode == SHOW

// 323.6% to 400%
bool showAtr4LinesParent = in_atr4LinesMode == SHOW
bool showAtr4LabelsParent = in_atr4LabelsMode == SHOW

bool showAtr4UpLines = allowRange4 and showAtr4LinesParent and in_atr4UpperLinesMode == SHOW
bool showAtr4DnLines = allowRange4 and showAtr4LinesParent and in_atr4LowerLinesMode == SHOW
bool showAtr4UpLabels = allowRange4 and showAtr4LabelsParent and in_atr4UpperLabelsMode == SHOW
bool showAtr4DnLabels = allowRange4 and showAtr4LabelsParent and in_atr4LowerLabelsMode == SHOW

// ──────────────────────────────────────────────
// 🟦 Subregion: Historical ATR Line Segments
// ──────────────────────────────────────────────
//
// Purpose:
//     Stores prior ATR level segments so users can review how price interacted with previous
//     ATR periods.
//
// Behavior:
//     • Current Period Only = existing clean object-line behavior
//     • Last N Periods = keeps horizontal ATR line segments from previous selected ATR periods
//     • Labels remain current-period only to avoid historical label clutter
//     • Hidden line ranges are kept invisible so user toggles remain responsive
//     • Proximity Aware suppresses historical ATR segments and focuses on the live active-side ladder
//
// Notes:
//     • Maximum historical periods is capped from the input to protect line-object limits.
//     • Each full ATR period can use up to 48 lines:
//       - 24 upper levels
//       - 24 lower levels
//

// Historical object stores
var line[] atrHistLineStore = array.new_line()
var int[] atrHistIndexStore = array.new_int()
var line[] atrHistActiveStore = array.new_line(48)

// Historical index helpers
f_histIsLowerIndex(int _idx) =>
    int block = int(math.floor(_idx / 6.0))
    block % 2 == 1

f_histShowByIndex(int _idx) =>
     _idx < 6  ? showAtr1UpLines :
     _idx < 12 ? showAtr1DnLines :
     _idx < 18 ? showAtr2UpLines :
     _idx < 24 ? showAtr2DnLines :
     _idx < 30 ? showAtr3UpLines :
     _idx < 36 ? showAtr3DnLines :
     _idx < 42 ? showAtr4UpLines : showAtr4DnLines

f_histColorByIndex(int _idx) =>
    int localIndex = _idx % 6
    f_histIsLowerIndex(_idx) ? array.get(ATR_COLORS_DN, localIndex) : array.get(ATR_COLORS_UP, localIndex)

f_histLineColor(int _idx) =>
    f_histShowByIndex(_idx) ? f_histColorByIndex(_idx) : invisibleColor

f_histMultByIndex(int _idx) =>
    int localIndex = _idx % 6

    float rawMult =
         _idx < 12 ? array.get(ATR_MULTS_1, localIndex) :
         _idx < 24 ? array.get(ATR_MULTS_2, localIndex) :
         _idx < 36 ? array.get(ATR_MULTS_3, localIndex) :
                     array.get(ATR_MULTS_4, localIndex)

    rawMult * (f_histIsLowerIndex(_idx) ? -1.0 : 1.0)

f_histLevelByIndex(int _idx) =>
    f_atrLevel(f_histMultByIndex(_idx))

f_newHistLine(int _idx, float _level) =>
    line.new(x1=bar_index, y1=_level, x2=bar_index, y2=_level, xloc=xloc.bar_index, extend=extend.none, color=f_histLineColor(_idx), width=in_atrLineWidth, style=f_lineStyle(in_atrLineStyle))

// Historical cleanup / trimming
f_deleteAtrHistory() =>
    int n = array.size(atrHistLineStore)

    if n > 0
        for i = n - 1 to 0 by -1
            line oldLine = array.get(atrHistLineStore, i)

            if not na(oldLine)
                line.delete(oldLine)

    array.clear(atrHistLineStore)
    array.clear(atrHistIndexStore)

    for i = 0 to 47
        array.set(atrHistActiveStore, i, na)

f_trimAtrHistory() =>
    int maxHistLines = 48 * in_atrHistoryPeriods

    while array.size(atrHistLineStore) > maxHistLines
        line oldLine = array.shift(atrHistLineStore)
        array.shift(atrHistIndexStore)

        if not na(oldLine)
            line.delete(oldLine)

// Historical period creation
f_startAtrHistoryPeriod() =>
    for idx = 0 to 47
        float level = f_histLevelByIndex(idx)

        if not na(level)
            line newLine = f_newHistLine(idx, level)

            array.push(atrHistLineStore, newLine)
            array.push(atrHistIndexStore, idx)
            array.set(atrHistActiveStore, idx, newLine)
        else
            array.set(atrHistActiveStore, idx, na)

// Historical active-period updates
f_updateAtrHistoryActivePeriod() =>
    for idx = 0 to 47
        float level = f_histLevelByIndex(idx)
        line activeLine = array.get(atrHistActiveStore, idx)

        if not na(level)
            color lineColor = f_histLineColor(idx)

            if na(activeLine)
                activeLine := f_newHistLine(idx, level)

                array.push(atrHistLineStore, activeLine)
                array.push(atrHistIndexStore, idx)
                array.set(atrHistActiveStore, idx, activeLine)
            else
                line.set_xy1(activeLine, line.get_x1(activeLine), level)
                line.set_xy2(activeLine, bar_index, level)
                line.set_color(activeLine, lineColor)
                line.set_width(activeLine, in_atrLineWidth)
                line.set_style(activeLine, f_lineStyle(in_atrLineStyle))

// Historical style refresh
f_applyAtrHistoryStyle() =>
    int n = array.size(atrHistLineStore)

    if n > 0
        for i = 0 to n - 1
            line histLine = array.get(atrHistLineStore, i)
            int idx = array.get(atrHistIndexStore, i)

            if not na(histLine)
                line.set_color(histLine, f_histLineColor(idx))
                line.set_width(histLine, in_atrLineWidth)
                line.set_style(histLine, f_lineStyle(in_atrLineStyle))

// Historical mode driver
bool useAtrHistory = in_atrHistoryMode == HIST_PERIODS and not useAtrProximity

if not useAtrHistory
    if array.size(atrHistLineStore) > 0
        f_deleteAtrHistory()
else
    bool needNewHistPeriod = periodStartTrig or array.size(atrHistLineStore) == 0

    if needNewHistPeriod
        f_startAtrHistoryPeriod()
        f_trimAtrHistory()

    f_updateAtrHistoryActivePeriod()

    if barstate.islast
        f_applyAtrHistoryStyle()
        f_trimAtrHistory()

// ──────────────────────────────────────────────
// 🟦 Subregion: Grid Updates
// ──────────────────────────────────────────────

// Current-period line / label updates
if barstate.islast
    f_syncAtrBlock(0, ATR_MULTS_1, ATR_TEXT_1, ATR_COLORS_UP, showAtr1UpLines, showAtr1UpLabels, 1)
    f_syncAtrBlock(6, ATR_MULTS_1, ATR_TEXT_1, ATR_COLORS_DN, showAtr1DnLines, showAtr1DnLabels, -1)

    f_syncAtrBlock(12, ATR_MULTS_2, ATR_TEXT_2, ATR_COLORS_UP, showAtr2UpLines, showAtr2UpLabels, 1)
    f_syncAtrBlock(18, ATR_MULTS_2, ATR_TEXT_2, ATR_COLORS_DN, showAtr2DnLines, showAtr2DnLabels, -1)

    f_syncAtrBlock(24, ATR_MULTS_3, ATR_TEXT_3, ATR_COLORS_UP, showAtr3UpLines, showAtr3UpLabels, 1)
    f_syncAtrBlock(30, ATR_MULTS_3, ATR_TEXT_3, ATR_COLORS_DN, showAtr3DnLines, showAtr3DnLabels, -1)

    f_syncAtrBlock(36, ATR_MULTS_4, ATR_TEXT_4, ATR_COLORS_UP, showAtr4UpLines, showAtr4UpLabels, 1)
    f_syncAtrBlock(42, ATR_MULTS_4, ATR_TEXT_4, ATR_COLORS_DN, showAtr4DnLines, showAtr4DnLabels, -1)

// ==============================================================================================
// 🔴 END REGION: ATR Grid Engine
// ==============================================================================================


// ==============================================================================================
// 🟢 REGION: ATR Session Auto VWAP
// ==============================================================================================
//
// Purpose:
//     Builds mode-aware AVWAP paths for the selected ATR session.
//
// Behavior:
//     • Session VWAP starts from the selected ATR session/period start
//     • High AVWAP anchors to the candle that creates the active session/period high
//     • Low AVWAP anchors to the candle that creates the active session/period low
//     • New highs/lows re-anchor their respective AVWAP paths
//     • Paths are rendered with polylines using time-based chart points
//
// Selected-mode reset behavior:
//     • Daily stocks/funds reset from premarket / extended-session start when available
//     • Daily crypto resets once per calendar day
//     • Daily futures reset once at the 5:00 PM Central Globex boundary
//     • Multiday / Swing / Position / Long-Term reset from the selected higher-timeframe period start
//
// Notes:
//     • These AVWAP paths are chart-candle based.
//     • The ATR grid remains anchored to the selected higher-timeframe ATR source.
//     • Volume must be available for VWAP paths to calculate.
//
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: ATR Session AVWAP Reset
// ──────────────────────────────────────────────
bool stockAvwapDailyReset = isStocks and (isEXT_Open or isNewCalendarDay)
bool cryptoAvwapDailyReset = isCrypto and isNewCalendarDay
bool futuresAvwapDailyReset = isFutures and futuresDailyStart

bool selectedAtrSessionReset =
     isDailyMode ?
         (isStocks ? stockAvwapDailyReset : isCrypto ? cryptoAvwapDailyReset : futuresAvwapDailyReset) :
         periodStartTrig

bool atrSessionAvwapReset = barstate.isfirst or selectedAtrSessionReset

// ──────────────────────────────────────────────
// 🟦 Subregion: ATR Session AVWAP Visibility
// ──────────────────────────────────────────────
bool showAtrSessionVwap =
     in_atrSessionAvwapMode == AVWAP_SHOW_ALL or
     in_atrSessionAvwapMode == AVWAP_SESSION_ONLY

bool showAtrSessionHighAvwap =
     in_atrSessionAvwapMode == AVWAP_SHOW_ALL or
     in_atrSessionAvwapMode == AVWAP_HIGH_LOW_ONLY or
     in_atrSessionAvwapMode == AVWAP_HIGH_ONLY

bool showAtrSessionLowAvwap =
     in_atrSessionAvwapMode == AVWAP_SHOW_ALL or
     in_atrSessionAvwapMode == AVWAP_HIGH_LOW_ONLY or
     in_atrSessionAvwapMode == AVWAP_LOW_ONLY

bool showAnyAtrSessionAvwap =
     showAtrSessionVwap or
     showAtrSessionHighAvwap or
     showAtrSessionLowAvwap

// ──────────────────────────────────────────────
// 🟦 Subregion: ATR Session High / Low Anchor Tracking
// ──────────────────────────────────────────────
var float atrSessionAvwapHigh = na
var float atrSessionAvwapLow = na

var int atrSessionAvwapHighIdx = na
var int atrSessionAvwapLowIdx = na

bool resetAtrSessionHighAvwap =
     atrSessionAvwapReset or
     (not na(high) and (na(atrSessionAvwapHigh) or high > atrSessionAvwapHigh))

bool resetAtrSessionLowAvwap =
     atrSessionAvwapReset or
     (not na(low) and (na(atrSessionAvwapLow) or low < atrSessionAvwapLow))

if resetAtrSessionHighAvwap
    atrSessionAvwapHigh := high
    atrSessionAvwapHighIdx := bar_index

if resetAtrSessionLowAvwap
    atrSessionAvwapLow := low
    atrSessionAvwapLowIdx := bar_index

// ──────────────────────────────────────────────
// 🟦 Subregion: ATR Session AVWAP Helpers
// ──────────────────────────────────────────────

// Point array trimming
f_trimAvwapPointArray(array<chart.point> _pts, int _maxBars) =>
    while array.size(_pts) > _maxBars
        array.shift(_pts)

// Polyline sync
f_syncAtrSessionAvwapPolyline(polyline _id, bool _show, array<chart.point> _pts, color _color, _style, int _width) =>
    polyline _pl = _id

    if not na(_pl)
        polyline.delete(_pl)
        _pl := na

    if _show and array.size(_pts) > 1
        _pl := polyline.new(_pts, false, false, xloc.bar_time, _color, na, _style, _width)

    _pl

// ──────────────────────────────────────────────
// 🟦 Subregion: ATR Session VWAP Point Stream
// ──────────────────────────────────────────────
float atrSessionAvwapVol = nz(volume, 0.0)

var float atrSessionVwapPV = 0.0
var float atrSessionVwapVolSum = 0.0
var array<chart.point> atrSessionVwapPts = array.new<chart.point>()

if atrSessionAvwapReset
    atrSessionVwapPV := 0.0
    atrSessionVwapVolSum := 0.0
    array.clear(atrSessionVwapPts)

if showAtrSessionVwap
    atrSessionVwapPV += in_atrSessionVwapSource * atrSessionAvwapVol
    atrSessionVwapVolSum += atrSessionAvwapVol

    float atrSessionVwapVal = atrSessionVwapVolSum > 0.0 ? atrSessionVwapPV / atrSessionVwapVolSum : na

    if not na(atrSessionVwapVal)
        array.push(atrSessionVwapPts, chart.point.from_time(time, atrSessionVwapVal))
        f_trimAvwapPointArray(atrSessionVwapPts, in_atrSessionAvwapMaxBars)
else
    array.clear(atrSessionVwapPts)

// ──────────────────────────────────────────────
// 🟦 Subregion: ATR Session High / Low AVWAP Point Streams
// ──────────────────────────────────────────────
var float atrSessionHighAvwapPV = 0.0
var float atrSessionHighAvwapVolSum = 0.0
var float atrSessionLowAvwapPV = 0.0
var float atrSessionLowAvwapVolSum = 0.0

var array<chart.point> atrSessionHighAvwapPts = array.new<chart.point>()
var array<chart.point> atrSessionLowAvwapPts = array.new<chart.point>()

if resetAtrSessionHighAvwap
    atrSessionHighAvwapPV := 0.0
    atrSessionHighAvwapVolSum := 0.0
    array.clear(atrSessionHighAvwapPts)

if resetAtrSessionLowAvwap
    atrSessionLowAvwapPV := 0.0
    atrSessionLowAvwapVolSum := 0.0
    array.clear(atrSessionLowAvwapPts)

if showAtrSessionHighAvwap
    atrSessionHighAvwapPV += high * atrSessionAvwapVol
    atrSessionHighAvwapVolSum += atrSessionAvwapVol

    float atrSessionHighAvwapVal = atrSessionHighAvwapVolSum > 0.0 ? atrSessionHighAvwapPV / atrSessionHighAvwapVolSum : na

    if not na(atrSessionHighAvwapVal)
        array.push(atrSessionHighAvwapPts, chart.point.from_time(time, atrSessionHighAvwapVal))
        f_trimAvwapPointArray(atrSessionHighAvwapPts, in_atrSessionAvwapMaxBars)
else
    array.clear(atrSessionHighAvwapPts)

if showAtrSessionLowAvwap
    atrSessionLowAvwapPV += low * atrSessionAvwapVol
    atrSessionLowAvwapVolSum += atrSessionAvwapVol

    float atrSessionLowAvwapVal = atrSessionLowAvwapVolSum > 0.0 ? atrSessionLowAvwapPV / atrSessionLowAvwapVolSum : na

    if not na(atrSessionLowAvwapVal)
        array.push(atrSessionLowAvwapPts, chart.point.from_time(time, atrSessionLowAvwapVal))
        f_trimAvwapPointArray(atrSessionLowAvwapPts, in_atrSessionAvwapMaxBars)
else
    array.clear(atrSessionLowAvwapPts)

// ──────────────────────────────────────────────
// 🟦 Subregion: ATR Session AVWAP Render
// ──────────────────────────────────────────────
var polyline atrSessionVwapPoly = na
var polyline atrSessionHighAvwapPoly = na
var polyline atrSessionLowAvwapPoly = na

if barstate.islast and showAnyAtrSessionAvwap
    color atrSessionVwapColor = color.new(in_atrSessionVwapColor, in_atrSessionAvwapTransp)
    color atrSessionHighAvwapColor = color.new(in_atrSessionHighAvwapColor, in_atrSessionAvwapTransp)
    color atrSessionLowAvwapColor = color.new(in_atrSessionLowAvwapColor, in_atrSessionAvwapTransp)

    atrSessionAvwapStyle = f_lineStyle(in_atrSessionAvwapStyle_high_low)
    atrSessionAvwapStyle_hlc3 = f_lineStyle(in_atrSessionAvwapStyle_hlc3)

    atrSessionVwapPoly := f_syncAtrSessionAvwapPolyline(atrSessionVwapPoly, showAtrSessionVwap, atrSessionVwapPts, atrSessionVwapColor, atrSessionAvwapStyle_hlc3, in_atrSessionAvwapWidth)
    atrSessionHighAvwapPoly := f_syncAtrSessionAvwapPolyline(atrSessionHighAvwapPoly, showAtrSessionHighAvwap, atrSessionHighAvwapPts, atrSessionHighAvwapColor, atrSessionAvwapStyle, in_atrSessionAvwapWidth)
    atrSessionLowAvwapPoly := f_syncAtrSessionAvwapPolyline(atrSessionLowAvwapPoly, showAtrSessionLowAvwap, atrSessionLowAvwapPts, atrSessionLowAvwapColor, atrSessionAvwapStyle, in_atrSessionAvwapWidth)

// ==============================================================================================
// 🔴 END REGION: ATR Session Auto VWAP
// ==============================================================================================


// ==============================================================================================
// 🟢 REGION: ATR Session High / Low Boxes
// ==============================================================================================
//
// Purpose:
//     Draws two optional boxes from the active ATR session/period high and low.
//
// Behavior:
//     • High Box starts from the candle that creates the active session/period high
//     • Low Box starts from the candle that creates the active session/period low
//     • New highs/lows re-anchor their respective box
//     • Boxes extend right using time-based coordinates
//     • Box height is based on the anchor candle wick, with an optional long-wick limit.
//
// Notes:
//     • Only two persistent box objects are maintained.
//     • Reset behavior follows the same selected ATR session reset used by ATR Session AVWAP.
//     • Time-based boxes avoid deep bar-index issues on lower timeframes.
//
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: Box Visibility
// ──────────────────────────────────────────────
bool showAtrSessionHighBox =
     in_atrSessionBoxMode == BOX_SHOW_BOTH or
     in_atrSessionBoxMode == BOX_HIGH_ONLY

bool showAtrSessionLowBox =
     in_atrSessionBoxMode == BOX_SHOW_BOTH or
     in_atrSessionBoxMode == BOX_LOW_ONLY

bool needAtrSessionRangeState =
     showAtrSessionHighBox or
     showAtrSessionLowBox or
     in_atrSessionFibLabelsMode == SHOW

// ──────────────────────────────────────────────
// 🟦 Subregion: High / Low Box Anchor Tracking
// ──────────────────────────────────────────────
var float atrSessionBoxHigh = na
var float atrSessionBoxLow = na

var int atrSessionBoxHighTime = na
var int atrSessionBoxLowTime = na

var float atrSessionHighBoxWickHeight = na
var float atrSessionLowBoxWickHeight = na

float atrSessionBoxChartAtr = ta.atr(ATR_LEN)

f_boxWickHeight(float _wick, float _chartAtr) =>
    float safeWick = math.max(nz(_wick, 0.0), syminfo.mintick)
    bool isLongWick = not na(_chartAtr) and _chartAtr > 0.0 and safeWick > _chartAtr * in_atrSessionBoxLongWickAtrMult
    float wickHeight = isLongWick ? safeWick * (in_atrSessionBoxLongWickLimitPct / 100.0) : safeWick
    math.max(wickHeight, syminfo.mintick)

bool resetAtrSessionHighBox =
     needAtrSessionRangeState and (
         atrSessionAvwapReset or
         (not na(high) and (na(atrSessionBoxHigh) or high > atrSessionBoxHigh)))

bool resetAtrSessionLowBox =
     needAtrSessionRangeState and (
         atrSessionAvwapReset or
         (not na(low) and (na(atrSessionBoxLow) or low < atrSessionBoxLow)))

if resetAtrSessionHighBox
    atrSessionBoxHigh := high
    atrSessionBoxHighTime := time

    if showAtrSessionHighBox
        float upperWickNow = high - math.max(open, close)
        atrSessionHighBoxWickHeight := f_boxWickHeight(upperWickNow, atrSessionBoxChartAtr)

if resetAtrSessionLowBox
    atrSessionBoxLow := low
    atrSessionBoxLowTime := time

    if showAtrSessionLowBox
        float lowerWickNow = math.min(open, close) - low
        atrSessionLowBoxWickHeight := f_boxWickHeight(lowerWickNow, atrSessionBoxChartAtr)

// ──────────────────────────────────────────────
// 🟦 Subregion: Box Geometry
// ──────────────────────────────────────────────
float atrSessionHighBoxHeight = showAtrSessionHighBox ? nz(atrSessionHighBoxWickHeight, syminfo.mintick) : na
float atrSessionLowBoxHeight = showAtrSessionLowBox ? nz(atrSessionLowBoxWickHeight, syminfo.mintick) : na

float atrSessionHighBoxTop = showAtrSessionHighBox ? atrSessionBoxHigh : na
float atrSessionHighBoxBottom = showAtrSessionHighBox ? atrSessionBoxHigh - atrSessionHighBoxHeight : na

float atrSessionLowBoxTop = showAtrSessionLowBox ? atrSessionBoxLow + atrSessionLowBoxHeight : na
float atrSessionLowBoxBottom = showAtrSessionLowBox ? atrSessionBoxLow : na

// ──────────────────────────────────────────────
// 🟦 Subregion: Box Color State
// ──────────────────────────────────────────────
color atrSessionHighBoxFillColor = showAtrSessionHighBox ? color.new(in_atrSessionHighBoxColor, in_atrSessionBoxFillTransp) : na
color atrSessionHighBoxBorderColor = showAtrSessionHighBox ? color.new(in_atrSessionHighBoxColor, in_atrSessionBoxBorderTransp) : na

color atrSessionLowBoxFillColor = showAtrSessionLowBox ? color.new(in_atrSessionLowBoxColor, in_atrSessionBoxFillTransp) : na
color atrSessionLowBoxBorderColor = showAtrSessionLowBox ? color.new(in_atrSessionLowBoxColor, in_atrSessionBoxBorderTransp) : na

// ──────────────────────────────────────────────
// 🟦 Subregion: Box Object State
// ──────────────────────────────────────────────
var box atrSessionHighBox = na
var box atrSessionLowBox = na

// ──────────────────────────────────────────────
// 🟦 Subregion: Box Render
// ──────────────────────────────────────────────
if barstate.islast and showAtrSessionHighBox
    atrSessionHighBox := f_syncTimeBox(
         atrSessionHighBox,
         true,
         atrSessionBoxHighTime,
         time,
         atrSessionHighBoxTop,
         atrSessionHighBoxBottom,
         atrSessionHighBoxFillColor,
         atrSessionHighBoxBorderColor)

if barstate.islast and showAtrSessionLowBox
    atrSessionLowBox := f_syncTimeBox(
         atrSessionLowBox,
         true,
         atrSessionBoxLowTime,
         time,
         atrSessionLowBoxTop,
         atrSessionLowBoxBottom,
         atrSessionLowBoxFillColor,
         atrSessionLowBoxBorderColor)

// ==============================================================================================
// 🔴 END REGION: ATR Session High / Low Boxes
// ==============================================================================================

// ==============================================================================================
// 🟢 REGION: ATR Session High / Low Fib Labels
// ==============================================================================================
//
// Purpose:
//     Adds fib context labels between the active ATR session/period high and low.
//
// Behavior:
//     • Uses the same active high / low tracking already used by ATR Session High / Low Boxes
//     • Draws labels only, no fib lines
//     • Fib direction is inferred from the order of the active session/period extremes:
//       - Low formed before high = bullish leg
//       - High formed before low = bearish leg
//     • Bullish leg:
//       - 0 anchors at the active high
//       - 1 anchors at the active low
//     • Bearish leg:
//       - 0 anchors at the active low
//       - 1 anchors at the active high
//     • Label colors use directional bull/bear fib color families
//     • Labels update only on the last bar
//
// Notes:
//     • ATR Session Fib Labels are chart-candle based.
//     • The fib range follows the currently selected ATR session/period.
//     • These labels add internal high/low range context beside the ATR expansion grid.
//
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: Fib Label State
// ──────────────────────────────────────────────
var label[] atrSessionFibLabelStore = array.new_label()
var float[] atrSessionFibLevels = array.from(0.0, 0.236, 0.382, 0.500, 0.618, 0.786, 1.0)

// ──────────────────────────────────────────────
// 🟦 Subregion: Fib Direction + Geometry
// ──────────────────────────────────────────────
bool showAtrSessionFibLabels = in_atrSessionFibLabelsMode == SHOW

bool atrSessionFibRangeOk =
     showAtrSessionFibLabels and
     not na(atrSessionBoxHigh) and
     not na(atrSessionBoxLow) and
     atrSessionBoxHigh > atrSessionBoxLow

float atrSessionFibRange = atrSessionFibRangeOk ? atrSessionBoxHigh - atrSessionBoxLow : na
float atrSessionFibMid = atrSessionFibRangeOk ? (atrSessionBoxHigh + atrSessionBoxLow) / 2.0 : na

int atrSessionFibDir =
     not atrSessionFibRangeOk ? 0 :
     atrSessionBoxHighTime > atrSessionBoxLowTime ? 1 :
     atrSessionBoxLowTime > atrSessionBoxHighTime ? -1 :
     close >= atrSessionFibMid ? 1 : -1

f_atrSessionFibPrice(float _level, int _dir, float _hi, float _lo, float _range) =>
     _dir == 1  ? _hi - _range * _level :
     _dir == -1 ? _lo + _range * _level : na

// ──────────────────────────────────────────────
// 🟦 Subregion: Render
// ──────────────────────────────────────────────
if barstate.islast
    if not atrSessionFibRangeOk
        f_clearAtrSessionFibLabels(atrSessionFibLabelStore)
    else
        int fibCount = array.size(atrSessionFibLevels)
        string fibLabelSize = f_labelSize(in_atrSessionFibLabelSize)

        f_syncAtrSessionFibLabelArray(atrSessionFibLabelStore, fibCount, close, fibLabelSize)

        for i = 0 to fibCount - 1
            float fibLevel = array.get(atrSessionFibLevels, i)
            float fibPrice = f_atrSessionFibPrice(fibLevel, atrSessionFibDir, atrSessionBoxHigh, atrSessionBoxLow, atrSessionFibRange)

            label fibLabel = array.get(atrSessionFibLabelStore, i)

            label.set_xy(fibLabel, bar_index, fibPrice)
            label.set_text(fibLabel, f_atrSessionFibLabelText(fibLevel, fibPrice))
            label.set_textcolor(fibLabel, f_atrSessionFibColor(fibLevel, atrSessionFibDir))
            label.set_style(fibLabel, label.style_label_left)
            label.set_yloc(fibLabel, yloc.price)
            label.set_size(fibLabel, fibLabelSize)
            label.set_color(fibLabel, invisibleColor)

// ==============================================================================================
// 🔴 END REGION: ATR Session High / Low Fib Labels
// ==============================================================================================


// ==============================================================================================
// 🟢 REGION: Price Guide Dash
// ==============================================================================================
//
// Purpose:
//     Renders one text-based dashed guide at the current price, aligned with the ATR label column.
//

// Object state
var label priceGuideLabel = na

// Render — presentation-gated
if barstate.islast and in_priceGuideMode == SHOW
    string guideText = f_spacer(in_atrLabelPadding) + f_dashText(in_priceGuideLen)
    priceGuideLabel := f_syncLabel(priceGuideLabel, true, close, guideText, in_priceGuideColor, f_labelSize(in_atrLabelSize))

// ==============================================================================================
// 🔴 END REGION: Price Guide Dash
// ==============================================================================================


// ==============================================================================================
// 🟢 REGION: PCL / CC Stepline Plot
// ==============================================================================================
//
// Purpose:
//     Optional plot-based close-reference line for users who want a classic TradingView
//     stepline / circle plot in addition to the object-based PCL / CC overlay line.
//

// Display / style
bool showPclPlot = in_pclPlotMode == SHOW

plot_style_pcl = switch in_pclPlotStyle
    "Stepline" => plot.style_stepline
    "Circles"  => plot.style_circles
    => plot.style_stepline

// Plot
plot(
     showPclPlot ? labelAnchor : na,
     title     = "Previous / Current Close",
     color     = c_prevClose,
     linewidth = in_pclLineWidth,
     style     = plot_style_pcl,
     display   = display.all)

// ==============================================================================================
// 🔴 END REGION: PCL / CC Stepline Plot
// ==============================================================================================


// ==============================================================================================
// 🟢 REGION: Price Candles
// ==============================================================================================
//
// Purpose:
//     Optional plotcandle overlay colored by the current candle body direction.
//
// Behavior:
//     • Bull candle = close >= open
//     • Bear candle = close < open
//     • Body, wick, and border transparency are controlled independently.
//

// Candle state
bool showPriceCandles = in_priceCandlesMode == SHOW
bool candleBull = showPriceCandles and close >= open

// Candle colors — presentation-gated when HIDE
color candleBaseColor = showPriceCandles ? (candleBull ? in_candleBull : in_candleBear) : na
color candleBody = showPriceCandles ? color.new(candleBaseColor, in_candleTransp) : na
color candleWick = showPriceCandles ? color.new(candleBaseColor, in_candleWickTransp) : na
color candleBorder = showPriceCandles ? color.new(candleBaseColor, in_candleBorderTransp) : na

// Plot
plotcandle(
     open        = showPriceCandles ? open : na,
     high        = showPriceCandles ? high : na,
     low         = showPriceCandles ? low : na,
     close       = showPriceCandles ? close : na,
     title       = "ATR Levels Price Candles",
     color       = candleBody,
     wickcolor   = candleWick,
     bordercolor = candleBorder,
     display     = display.all)

// ==============================================================================================
// 🔴 END REGION: Price Candles
// ==============================================================================================


// ==============================================================================================
// 🟢 REGION: Period-Change Debug Label
// ==============================================================================================
//
// Purpose:
//     Adds an optional debug label when the selected ATR period changes.
//
// Behavior:
//     • Shows selected mode, source timeframe, active close anchor, ATR value, and bar range
//     • Useful for confirming stock / crypto / futures period transitions
//     • Hidden by default for normal chart use.
//

// Display
bool showDebugLabel = in_debugLabelMode == SHOW

// Render — calculation and string construction are gated with the feature
if showDebugLabel and periodStartTrig and not barstate.isfirst
    float activeRangePct =
         na(atrValue) or atrValue == 0.0 ? na :
         math.abs(high - low) / atrValue * 100.0

    string debugLabelText =
         "Mode: " + in_atrMode + "\n" +
         "TF: " + atrTf + "\n" +
         "Anchor: " + pclTag + "\n" +
         "ATR: " + f_priceStr(atrValue, in_sigFig) + "\n" +
         "Bar Range/ATR: " + f_formatPlainPercent(activeRangePct)

    label.new(x=bar_index, y=high, text=debugLabelText, xloc=xloc.bar_index, yloc=yloc.price, color=invisibleColor, style=label.style_label_down, textcolor=color.lime, size=size.small)

// ==============================================================================================
// 🔴 END REGION: Period-Change Debug Label
// ==============================================================================================
````

# Candle Levels

- url: https://www.tradingview.com/script/GrDNiUfm-Candle-Levels/
- type: indicator
- pine_id: PUB;fee613ecdccd44cead68cf3153163d4f
- version: 4.0

## Description

Candle Levels is a rebuild of my original Candle Levels Pro framework, designed to map important completed-candle and session reference levels directly on the price chart. This script focuses on current day/session levels, previous close, lower-timeframe completed candle levels, daily candle levels, weekly candle levels, and monthly candle levels. It also includes source-aware line starts and compact right-side labels so users can quickly see the level price, current distance from price, and level tag.

────────────────────────────
Core Idea
────────────────────────────

Markets often react around prior candle highs, lows, closes, session opens, and active-session extremes.

Candle Levels turns those reference points into organized horizontal levels:

• Current High of Day / Low of Day
• Regular-session open
• Premarket open
• Current close reference
• Previous close
• Previous completed LTF candle highs/lows/closes
• Previous completed daily candle highs/lows/closes
• Previous completed weekly candle highs/lows/closes
• Previous completed monthly candle highs/lows/closes

Instead of plotting every possible historical line, the script focuses on the active references that matter most to you now.

────────────────────────────
Asset-Aware Source Logic
────────────────────────────

The script separates stock/fund/ADR behavior from crypto behavior. It is not currently set up for futures. Futures have different session structures, settlement behavior, overnight handling, contract-specific calendars, and reference-level needs. A separate futures-focused version will be handled as its own script so the logic can be built specifically around futures sessions instead of forcing futures into the stock/crypto model.

For US-session stocks, funds, and ADRs:

• Close references use regular-session close data
• High/low references use extended/full-session high-low data when available
• HOD / LOD track the current full-session high and low
• PCL uses the prior regular-session daily close
• OPEN uses the regular-session open
• PMO uses the first premarket open

For crypto:

• Levels use the native 24-hour chart stream
• Daily levels follow the native 24-hour daily cycle
• US-session-only references such as PMO and CC are hidden automatically

This source split is intentional. Many traders want regular-session closes but still want premarket and after-hours highs/lows visible when those extremes matter.

────────────────────────────
Current Session Levels
────────────────────────────

The current-session block tracks:

• HOD
• LOD
• OPEN
• PMO
• CCL
• PCL

HOD and LOD update as the active day makes new extremes. Their lines can begin at the candle that created the current high or low, making the source of the level visually clear.

PCL has its own dedicated input group, label padding, and bull/bear color controls so it can be styled separately from the daily high/low rows.

────────────────────────────
Lower-Timeframe Candle Levels
────────────────────────────

The LTF section includes hardcoded completed-candle references for:

• 10m[1]
• 15m[1]
• 30m[1]
• 1h[1]
• 2h[1]
• 4h[1]
• 8h[1]

Each row can show the previous completed candle’s:

• High
• Low
• Close

The “[1]” tag means previous completed candle for that timeframe. For example, 1h[1] means the prior completed one-hour candle, not a rolling last-60-minutes window.

────────────────────────────
Daily Candle Levels
────────────────────────────

The Daily section includes:

• D[1] High / Low
• D[2] High / Low / Close
• D[3] High / Low / Close

D[1] is the most recent completed daily candle. D[2] is the single daily candle two completed sessions back. D[3] is the single daily candle three completed sessions back.

These are candle offsets, not rolling multiday ranges.

For US-session equities, Daily Hi/Lo levels can include premarket or after-hours extremes when full-session history is available. This means a D[n]Hi or D[n]Lo may not always match the visible regular-session-only TradingView daily candle.

Daily Close levels use the regular-session close source for US-session equities.

────────────────────────────
Weekly And Monthly Candle Levels
────────────────────────────

The Weekly section includes:

• W[1] High / Low / Close
• W[2] High / Low / Close

W[1] means the prior completed 1-week candle. W[2] means the single 1-week candle two completed weeks back. W[2] is not a 2-week candle.

The Monthly section includes:

• M[1] High / Low / Close
• M[2] High / Low / Close
• M[3] High / Low / Close

M[1] means the prior completed 1-month candle. M[3] means the single 1-month candle three completed months back. These are not rolling multi-month ranges.

Weekly and Monthly rows have independent high/low label controls, close label controls, and per-row label padding inputs.

────────────────────────────
Line Start Modes
────────────────────────────

Daily, Weekly, and Monthly levels include source-aware line-start controls.

Active Period:
Starts the level from the current active period. This keeps the chart cleaner and avoids long historical spans.

Source Window:
Starts the level from the beginning of the completed source candle window used for that offset.

Source Candle:
Starts high/low lines from the chart candle that created the completed source high or low when that source timing is available. Close lines start from the completed source close candle when available.

If the exact source candle is not available, the script falls back to Source Window when available, then Active Period.

────────────────────────────
Right-Side Labels
────────────────────────────

All labels are right-side text labels only.

Each label can show:

• price row
• dollar difference from current price
• percent difference from current price
• level tag row

Labels use EM-space padding instead of x-offset tricks, which helps keep the labels visually staggered while still pinned to the current bar.

Different level groups have their own padding controls, and the newer Daily / Weekly / Monthly sections include more granular row padding so overlapping labels can be separated cleanly.

────────────────────────────
Important Levels Library
────────────────────────────

This version now uses my shared ImportantLevelsLinesLabels_Utilities library: https://www.tradingview.com/script/VR6gS3SH-ImportantLevelsLinesLabels-Utilities/

That library handles the reusable output infrastructure:

• right-side label text
• price / dollar / percent formatting
• line style resolution
• label size resolution
• bar-time horizontal level lines
• transparent text labels
• object slot arrays
• history-array pruning
• source-aware line-start routing

The script itself still owns the source engine, session behavior, candle tracking, request.security() logic, and final visibility conditions.

This keeps Candle Levels Pro cleaner internally while making the level-output system more consistent with future scripts.

────────────────────────────
How I Use It
────────────────────────────

I use Candle Levels as a price-map tool.

A few practical reads:

• HOD / LOD show where the active session has expanded.
• OPEN and PMO help frame current price against the regular and premarket starts.
• PCL shows where price is relative to the prior regular-session close.
• LTF levels help identify nearby short-term reference points.
• Daily, Weekly, and Monthly levels help organize higher-timeframe context.
• Source Candle mode helps show where a completed candle high, low, or close actually came from.
• Right-side labels make it easier to compare distance from current price without manually measuring every level.

This is not intended to be a standalone buy/sell signal tool. It is a visual reference framework for organizing important price levels, session context, and completed candle structure.

────────────────────────────
Chart Examples
────────────────────────────

https://www.tradingview.com/x/t2qNaXfE/
https://www.tradingview.com/x/Ap0w3Bqz/
https://www.tradingview.com/x/pysro86w/
https://www.tradingview.com/x/QtGTSd5x/

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Candle Levels Pro 2026 rewrite by © MYNAMEISBRANDON

//@version=6
indicator("Candle Levels", "Candle Lvl", overlay=true, max_bars_back=5000, max_lines_count=170, max_labels_count=170, dynamic_requests=true)

import MYNAMEISBRANDON/ImportantLevelsLinesLabels_Utilities/1 as LVL

// NOTE:
// This rewrite intentionally avoids calc_bars_count. Weekly and monthly candle references need enough available history to calculate accurately on lower chart timeframes.
// All horizontal level objects use xloc.bar_time so long active-period spans do not request deep historical bar-index offsets.


// ==============================================================================================
// 🟢 REGION: Script Overview
// ==============================================================================================
//
// 2026 rebuild / public update of the legacy Candle Levels Pro script:
// https://www.tradingview.com/script/9U3JhyON-CANDLE-LEVELS-PRO/
//
// Core features:
//
// Public label/color update:
// • Right-side tags use the P-prefix convention (P10m / P1D / P1W / P1M, etc.) with split
//   timeframe + Hi/Lo/CL rows and no square brackets
// • Plot lines and right-side labels share the same family color engine
// • PCL defaults to light blue; all other families default to #ffb000 positive / #f51673 negative
// • PCL, CCL, HOD/LOD, OPEN, PMO, LTF, Daily, Weekly, and Monthly each have independent
//   Default / Custom color modes
// • Dynamic label padding supports Grouped (default) and Individual modes with user-adjustable
//   first padding and spacing; semantic order is fixed regardless of which levels are enabled
//
// • Asset-aware architecture for stocks/funds/ADRs, crypto, futures, indices, forex, CFDs,
//   commodities, spot, swaps, and bonds
// • US equities use RTH close references with EXT/full-session high-low tracking
// • Crypto, futures, and native cash/exchange assets use their native TradingView session streams
// • CME Group futures can expose a dedicated US-RTH OPEN through TradingView's "us_regular" session
// • Native cash/index-style assets use the first bar of the native exchange day as their OPEN
// • Current HOD / LOD track the active native/full-session day, anchor to the candle that created
//   the latest extreme, and are exported only where a true Daily reference is valid
// • OPEN tracks the applicable regular/native session open for the active asset class
// • PMO is a US-equity-only premarket-open reference
// • CCL is a US-equity-only outside-RTH reference sourced from the confirmed regular-session
//   Daily close and remains hidden during RTH
// • PCL uses the prior RTH Daily close for US equities and the prior native Daily close for
//   native-session assets
// • US-equity P1D / P2D / P3D high-low history is reconstructed from full-session EXT data
//   rather than falling back to potentially RTH-only Daily highs and lows
// • Native-session Daily high-low history is tracked independently for crypto, futures, and
//   other supported native-market assets
// • Previous candle high / low / close levels are available across 10m, 15m, 30m, 1h, 2h,
//   4h, 8h, Daily, Weekly, and Monthly families
// • Target-timeframe eligibility prevents lower-timeframe levels from being exported when the
//   host chart timeframe cannot legitimately reconstruct them
// • LTF levels can begin from the active target period or the exact chart candle that produced
//   the completed source high, low, or close
// • Daily / Weekly / Monthly levels can begin from the active period, completed source window,
//   or exact source candle where source timing is available
// • Horizontal levels use bar-time objects rather than long historical plot trails
// • Line plots and right-side labels are independently controlled throughout the level families
// • Right-side labels use a configurable stack of level price, $ difference, % difference,
//   and level tag; Price, $ Difference, and % Difference rows can be hidden globally while the
//   level tag remains
// • HOD / LOD, OPEN, PMO, CCL, PCL, LTF, Daily, Weekly, and Monthly levels retain their
//   applicable independent styling, label, and line controls
// • Plot lines and right-side labels share the same price-side color within each level family
// • PCL has its own Default / Custom color mode and defaults both directions to light blue
// • CCL, HOD/LOD, OPEN, PMO, LTF, Daily, Weekly, and Monthly each have independent
//   Default / Custom color modes; their default palette is #ffb000 positive / #f51673 negative
// • Right-side label padding uses a fixed semantic order independent of input-enable order:
//   PCL → CCL → PMO → OPEN → HOD/LOD → P10m → P15m → P30m → P1h → P2h → P4h → P8h
//   → P1D → P2D → P3D → P1W → P2W → P1M → P2M → P3M
// • Grouped padding remains the default and Individual padding remains optional
// • Grouped mode gives similar labels one shared horizontal pad (for example HOD / LOD or a
//   timeframe's Hi / Lo / CL); Individual mode gives every visible label its own pad
// • One compact array-driven padding engine owns both modes rather than maintaining separate ladders
// • First Label Padding and Padding Between Labels are user inputs; spacing defaults to 4
// • Only visible / valid labels or groups consume spacing, so the ladder remains compact in both modes
// • Candle-family right labels split the period and level type across two identically padded tag rows
//   (for example P1D then Lo); square brackets are removed from all right-side display tags
// • Previous candle offsets use P-prefix canon throughout: P1D / P2D / P3D, P1W / P2W,
//   and P1M / P2M / P3M
// • Stateful daily / weekly / monthly history remains continuously evaluated while visual
//   object synchronization is confined to the last chart bar
//
// ==============================================================================================
// 🔴 END REGION: Script Overview
// ==============================================================================================


// ==============================================================================================
// 🟢 REGION: Constants
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: Shared Strings
// ──────────────────────────────────────────────

const string SHOW = "Show"
const string HIDE = "Hide"
const string COLOR_MODE_DEFAULT = "Default"
const string COLOR_MODE_CUSTOM = "Custom"
const string LABEL_PADDING_GROUPED = "Grouped"
const string LABEL_PADDING_INDIVIDUAL = "Individual"
const string CLOSE_START_ACTIVE = "Active Period"
const string CLOSE_START_SOURCE = "Source Close Candle"
const string START_SOURCE_WINDOW = "Source Window"
const string HL_START_SOURCE = "Source Candle"

const string STYLE_SOLID  = "Solid"
const string STYLE_DOTTED = "Dotted"
const string STYLE_DASHED = "Dashed"

const int SLOT_HI = 0
const int SLOT_LO = 1
const int SLOT_CL = 2

// ──────────────────────────────────────────────
// 🟦 Subregion: Hardcoded Timeframes
// ──────────────────────────────────────────────

const string TF_10M = "10"
const string TF_15M = "15"
const string TF_30M = "30"
const string TF_1H  = "60"
const string TF_2H  = "120"
const string TF_4H  = "240"
const string TF_8H  = "480"
const string TF_1D  = "D"
const string TF_1W  = "W"
const string TF_1M  = "M"

// ──────────────────────────────────────────────
// 🟦 Subregion: Color Constants
// ──────────────────────────────────────────────

const color COLOR_POSITIVE_DEFAULT = #ffb000
const color COLOR_NEGATIVE_DEFAULT = #f51673
const color COLOR_PCL_DEFAULT = #4da3ff

// ──────────────────────────────────────────────
// 🟦 Subregion: Input Groups
// ──────────────────────────────────────────────

const string G_CUR    = "High / Low of Day - HOD/LOD"
const string G_CC     = "Current Close - CCL"
const string G_PCL    = "Previous Close - PCL"
const string G_OPEN   = "Session / RTH Open - OPEN"
const string G_PMO    = "Premarket Open - PMO"
const string G_LTF    = "Lower Timeframe Candle Levels"
const string G_DAILY  = "Daily Candle Levels"
const string G_WEEKLY = "Weekly Candle Levels"
const string G_MONTHLY = "Monthly Candle Levels"
const string G_LABELS = "Level Labels"
const string G_DEBUG  = "Debug"

// ──────────────────────────────────────────────
// 🟦 Subregion: Current / Session Reference Tooltips
// ──────────────────────────────────────────────

const string TT_CURRENT =
     "Shows current-session/day reference levels.\n\n" +
     "HOD and LOD update as the active native/full-session day makes new extremes and anchor to the candle that created the latest high or low. They are exported only on chart timeframes where a Daily reference remains valid. OPEN follows the applicable equity RTH, CME US-RTH, or native exchange-day session model. PCL is handled separately in Previous Close - PCL."


const string TT_CC =
     "Shows the Current Close / CCL reference for US-session stocks/funds/ADRs.\n\n" +
     "CCL is intentionally outside-RTH only. It uses the confirmed regular-session Daily close after RTH completes, remains available through after-hours and the following premarket, and hides again when regular trading resumes.\n\n" +
     "Non-equity assets hide CCL automatically."


const string TT_PCL =
     "Controls the separate Previous Close / PCL reference.\n\n" +
     "PCL uses the prior regular-session Daily close for US-session stocks/funds/ADRs. Crypto, futures, indices, forex, CFDs, commodities, spot, swaps, and bonds use their native prior Daily close."


const string TT_PCL_LINE_START =
     "Controls where the PCL line begins.\n\n" +
     "Active Period starts PCL from the current active daily period. This is cleaner and avoids long historical spans.\n\n" +
     "Source Close Candle starts PCL back at the actual daily close candle that created the previous close level."

const string TT_OPEN =
     "Shows the active session / regular-session OPEN reference.\n\n" +
     "US stocks/funds/ADRs use the 09:30 ET regular-session open. CME Group futures use TradingView's named US regular-session subsession (us_regular), so NQ/ES-style contracts switch from ETH to their RTH OPEN at the exchange-defined RTH boundary.\n\n" +
     "Indices, forex, CFDs, commodities, spot, swaps, and bonds use the first chart bar of the native TradingView exchange day as OPEN on intraday charts.\n\n" +
     "Crypto and futures without a supported CME US-RTH subsession hide OPEN automatically."

const string TT_PREV_OPEN_PREMARKET =
     "Controls whether the prior regular-session OPEN is shown before the current RTH session begins.\n\n" +
     "US equities: shows yesterday's regular-session open as POPEN during today's premarket.\n\n" +
     "CME Group futures: after the new ETH trade date begins but before the US-RTH subsession opens, shows the prior RTH open as POPEN.\n\n" +
     "The label switches to the current OPEN when the new regular session begins."

const string TT_PMO =
     "Shows the premarket open / PMO reference for US-session stocks/funds/ADRs.\n\n" +
     "The line starts at the first premarket candle. Non-equity assets hide PMO automatically."


// ──────────────────────────────────────────────
// 🟦 Subregion: Shared Candle Level Tooltips
// ──────────────────────────────────────────────

const string TT_PREV_CANDLE =
     "Shows completed candle reference levels from the selected family.\n\n" +
     "High / Low draws the completed candle high and low. Close draws the completed candle close."

// ──────────────────────────────────────────────
// 🟦 Subregion: LTF Candle Level Tooltips
// ──────────────────────────────────────────────

const string TT_LTF_LINE_START =
     "Line Plot Start controls how Lower Timeframe candle levels are drawn.\n\n" +

     "Active Period:\n" +
     "Starts each level from the current active LTF candle/period. This keeps the level visually tied to the current active window.\n\n" +

     "Source Candle:\n" +
     "Starts Hi/Lo levels from the chart candle that created the previous completed LTF high or low. Close levels start from the chart candle that produced the previous completed LTF close.\n\n" +

     "What the LTF rows mean:\n" +
     "Each row uses the previous completed candle for that timeframe. For example, 1h[1] means the prior completed 1-hour candle, not a rolling last-60-minutes window. The same idea applies to 10m[1], 15m[1], 30m[1], 2h[1], 4h[1], and 8h[1].\n\n" +

     "Best visual match:\n" +
     "To audit a level precisely, switch to the matching chart timeframe. For example, if 1h[1] is enabled, the 1h chart will show the exact previous 1-hour candle used for the level.\n\n" +

     "On smaller chart timeframes:\n" +
     "The level value still comes from the previous completed higher-timeframe candle. In Source Candle mode, Hi/Lo lines may begin on the specific lower-timeframe candle that created that high or low inside the completed higher-timeframe candle. Close lines begin on the lower-timeframe candle that produced the completed higher-timeframe close.\n\n" +

     "Hi/Lo[1]:\n" +
     "Draws the high and low of the previous completed candle for that timeframe.\n\n" +

     "Close[1]:\n" +
     "Draws the close of the previous completed candle for that timeframe."

const string TT_LTF_CLOSE_LABEL =
     "Controls only the right-side Close label for this LTF row.\n\n" +
     "Example: 10m[1] Close means the close of the previous completed 10-minute candle, not a rolling last-10-minutes value. The same idea applies to 15m[1], 30m[1], 1h[1], 2h[1], 4h[1], and 8h[1].\n\n" +
     "This label can be shown or hidden independently from the Hi/Lo label and independently from the Close line plot."

// ──────────────────────────────────────────────
// 🟦 Subregion: Daily Candle Level Tooltips
// ──────────────────────────────────────────────

const string TT_DAILY_HL_LABEL =
     "Controls only the right-side Hi/Lo labels for this Daily row.\n\n" +
     "For US-session stocks/funds/ADRs, Daily Hi/Lo levels use the full-session / extended-hours high-low history when available. This means a D[n]Hi or D[n]Lo level can include premarket or after-hours extremes and may not always match the visible TradingView Daily candle, which is often regular-session only.\n\n" +
     "Native-session assets use their native Daily high-low.\n\n" +
     "This label can be shown or hidden independently from the Hi/Lo line plots and independently from the Close label."


const string TT_DAILY_CLOSE_LABEL =
     "Controls only the right-side Close label for this Daily row.\n\n" +
     "For US-session stocks/funds/ADRs, Daily close levels use the regular-session Daily close source. This can differ from the full-session high-low source used by the matching Daily Hi/Lo levels.\n\n" +
     "Native-session assets use their native Daily close.\n\n" +
     "This label can be shown or hidden independently from the Close line plot and independently from the Hi/Lo label."


const string TT_DAILY_LINE_START =
     "Line Plot Start controls where Daily candle level lines begin.\n\n" +

     "Active Period:\n" +
     "Starts P1D through P3D Daily levels from the current active daily period. This keeps the chart cleaner and avoids long historical spans.\n\n" +

     "Source Window:\n" +
     "Starts P1D through P3D Daily levels from the beginning of the completed daily session/window used for that offset. This shows the full completed Daily candle window on intraday charts.\n\n" +

     "Source Candle:\n" +
     "Starts Daily Hi/Lo lines from the chart candle that created the completed daily high or low when that session-history source candle is available. Daily close lines start from the source close candle. If a source candle is not available, the line falls back to Source Window when available, then Active Period.\n\n" +

     "What the Daily rows mean:\n" +
     "Each row uses a completed daily candle offset. For example, P3D means the single daily candle three completed sessions back, not a rolling 3-day range. The same idea applies to P1D and P2D.\n\n" +

     "US equity source behavior:\n" +
     "For US-session stocks/funds/ADRs, Daily Hi/Lo levels use full-session / extended-hours high-low history when available, while Daily Close levels use the regular-session close source. Because of that, a D[n]Lo or D[n]Hi can include premarket or after-hours extremes and may not always match the visible regular-session daily candle.\n\n" +

     "Best visual match:\n" +
     "To audit regular-session close levels, switch to the daily chart. To audit extended-session Hi/Lo source candles, use an intraday chart with extended-hours data visible.\n\n" +

     "On intraday chart timeframes:\n" +
     "The level value still comes from the completed daily candle offset. Source Window starts at the beginning of that completed daily window. Source Candle starts Hi/Lo from the specific intraday candle that created that daily high or low inside the completed full-session history, and starts Close from the completed daily close source.\n\n" +

     "Hi/Lo:\n" +
     "Draws the high and low of that completed daily candle offset.\n\n" +

     "Close:\n" +
     "Draws the close of that completed daily candle offset."

// ──────────────────────────────────────────────
// 🟦 Subregion: Weekly Candle Level Tooltips
// ──────────────────────────────────────────────

const string TT_WEEKLY_HL_LABEL =
     "Controls only the right-side Hi/Lo labels for this Weekly row.\n\n" +
     "For US-session stocks/funds/ADRs, Weekly Hi/Lo levels use the full-session / extended-hours high-low source when available. This means W[n]Hi or W[n]Lo can include premarket or after-hours extremes and may not always match a regular-session-only weekly candle.\n\n" +
     "Native-session assets use their native Weekly high-low.\n\n" +
     "P1W means the prior completed 1-week candle. P2W means the single 1-week candle two completed weeks back, not a 2-week candle.\n\n" +
     "This label can be shown or hidden independently from the Hi/Lo line plots and independently from the Close label."

const string TT_WEEKLY_CLOSE_LABEL =
     "Controls only the right-side Close label for this Weekly row.\n\n" +
     "For US-session stocks/funds/ADRs, Weekly close levels use the regular-session weekly close source. This can differ from the full-session high-low source used by the matching Weekly Hi/Lo levels.\n\n" +
     "Native-session assets use their native Weekly close.\n\n" +
     "P1W means the prior completed 1-week candle. P2W means the single 1-week candle two completed weeks back, not a 2-week candle.\n\n" +
     "This label can be shown or hidden independently from the Close line plot and independently from the Hi/Lo label."

const string TT_WEEKLY_LINE_START =
     "Line Plot Start controls where Weekly candle level lines begin.\n\n" +

     "Active Period:\n" +
     "Starts P1W and P2W Weekly levels from the current active weekly period. This keeps the chart cleaner and avoids long historical spans.\n\n" +

     "Source Window:\n" +
     "Starts P1W and P2W Weekly levels from the beginning of the completed weekly candle window used for that offset. This shows the full completed Weekly candle window on intraday charts.\n\n" +

     "Source Candle:\n" +
     "Starts Weekly Hi/Lo lines from the chart candle that created the completed weekly high or low when that source candle is available. Weekly close lines start from the chart candle that produced the completed weekly close. If a source candle is not available, the line falls back to Source Window when available, then Active Period.\n\n" +

     "What the Weekly rows mean:\n" +
     "Each row uses a completed 1-week candle offset. For example, P1W means the prior completed 1-week candle. P2W means the single 1-week candle two completed weeks back. P2W is not a 2-week candle and these are not rolling multi-week ranges.\n\n" +

     "US equity source behavior:\n" +
     "For US-session stocks/funds/ADRs, Weekly Hi/Lo levels use the full-session / extended-hours high-low source when available, while Weekly Close levels use the regular-session close source. Because of that, W[n]Hi or W[n]Lo may include premarket or after-hours extremes.\n\n" +

     "Best visual match:\n" +
     "To audit regular-session weekly close levels, switch to the weekly chart. To audit extended-session Hi/Lo source candles, use an intraday chart with extended-hours data visible.\n\n" +

     "On intraday or daily chart timeframes:\n" +
     "The level value still comes from the completed weekly candle offset. Source Window starts at the beginning of that completed weekly window. Source Candle starts Hi/Lo from the specific chart candle that created that weekly high or low inside the completed weekly candle, and starts Close from the completed weekly close source.\n\n" +

     "Hi/Lo:\n" +
     "Draws the high and low of that completed weekly candle offset.\n\n" +

     "Close:\n" +
     "Draws the close of that completed weekly candle offset."

// ──────────────────────────────────────────────
// 🟦 Subregion: Monthly Candle Level Tooltips
// ──────────────────────────────────────────────

const string TT_MONTHLY_HL_LABEL =
     "Controls only the right-side Hi/Lo labels for this Monthly row.\n\n" +
     "For US-session stocks/funds/ADRs, Monthly Hi/Lo levels use the full-session / extended-hours high-low source when available. This means M[n]Hi or M[n]Lo can include premarket or after-hours extremes and may not always match a regular-session-only monthly candle.\n\n" +
     "Native-session assets use their native Monthly high-low.\n\n" +
     "P1M means the prior completed 1-month candle. P3M means the single 1-month candle three completed months back, not a 3-month candle.\n\n" +
     "This label can be shown or hidden independently from the Hi/Lo line plots and independently from the Close label."

const string TT_MONTHLY_CLOSE_LABEL =
     "Controls only the right-side Close label for this Monthly row.\n\n" +
     "For US-session stocks/funds/ADRs, Monthly close levels use the regular-session monthly close source. This can differ from the full-session high-low source used by the matching Monthly Hi/Lo levels.\n\n" +
     "Native-session assets use their native Monthly close.\n\n" +
     "P1M means the prior completed 1-month candle. P3M means the single 1-month candle three completed months back, not a 3-month candle.\n\n" +
     "This label can be shown or hidden independently from the Close line plot and independently from the Hi/Lo label."

const string TT_MONTHLY_LINE_START =
     "Line Plot Start controls where Monthly candle level lines begin.\n\n" +

     "Active Period:\n" +
     "Starts P1M through P3M Monthly levels from the current active monthly period. This keeps the chart cleaner and avoids long historical spans.\n\n" +

     "Source Window:\n" +
     "Starts P1M through P3M Monthly levels from the beginning of the completed monthly candle window used for that offset. This shows the full completed Monthly candle window on lower chart timeframes.\n\n" +

     "Source Candle:\n" +
     "Starts Monthly Hi/Lo lines from the chart candle that created the completed monthly high or low when that source candle is available. Monthly close lines start from the chart candle that produced the completed monthly close. If a source candle is not available, the line falls back to Source Window when available, then Active Period.\n\n" +

     "What the Monthly rows mean:\n" +
     "Each row uses a completed 1-month candle offset. For example, P1M means the prior completed 1-month candle. P3M means the single 1-month candle three completed months back. P3M is not a 3-month candle and these are not rolling multi-month ranges.\n\n" +

     "US equity source behavior:\n" +
     "For US-session stocks/funds/ADRs, Monthly Hi/Lo levels use the full-session / extended-hours high-low source when available, while Monthly Close levels use the regular-session close source. Because of that, M[n]Hi or M[n]Lo may include premarket or after-hours extremes.\n\n" +

     "Best visual match:\n" +
     "To audit regular-session monthly close levels, switch to the monthly chart. To audit extended-session Hi/Lo source candles, use a lower timeframe chart with extended-hours data visible.\n\n" +

     "On lower chart timeframes:\n" +
     "The level value still comes from the completed monthly candle offset. Source Window starts at the beginning of that completed monthly window. Source Candle starts Hi/Lo from the specific chart candle that created that monthly high or low inside the completed monthly candle, and starts Close from the completed monthly close source.\n\n" +

     "Hi/Lo:\n" +
     "Draws the high and low of that completed monthly candle offset.\n\n" +

     "Close:\n" +
     "Draws the close of that completed monthly candle offset."

// ──────────────────────────────────────────────
// 🟦 Subregion: Right Label Tooltips
// ──────────────────────────────────────────────

const string TT_LEVEL_COLORS =
     "Controls the plot-line and matching right-label colors for this level family.\n\n" +
     "Default uses the canonical family palette. Custom enables independent Positive / Negative colors.\n\n" +
     "Positive means current price is above the level. Negative means current price is below the level."

const string TT_LABEL_ROWS =
     "Controls optional rows inside every right-side level label.\n\n" +
     "Price Row is a global toggle for the level-price row across HOD/LOD, OPEN/PMO/CCL/PCL, LTF, Daily, Weekly, and Monthly labels. $ Difference and % Difference are also global row controls.\n\n" +
     "The level tag area remains visible even when optional numeric rows are hidden. Candle-family labels use two tag rows, such as P1D then Hi or P10m then Lo."


// ──────────────────────────────────────────────
// 🟦 Subregion: Global Settings
// ──────────────────────────────────────────────

// Asset reference sources are hardcoded by level type.
// US equities: RTH close references such as PCL/CCL and Daily close offsets; EXT/full-session high-low references.
// Crypto, futures, indices, forex, CFDs, commodities, spot, swaps, and bonds use their native session streams.

// ──────────────────────────────────────────────
// 🟦 Subregion: Current High/Low of Day Candle Level Inputs
// ──────────────────────────────────────────────

// Display
string in_curLineMode = input.string(defval=SHOW, title="Line Plots", options=[SHOW, HIDE], group=G_CUR, tooltip=TT_CURRENT)
bool showCurHLLine = in_curLineMode == SHOW
string in_curLabelMode = input.string(defval=SHOW, title="Right-side Labels", options=[SHOW, HIDE], group=G_CUR)
bool showCurHLLabel = in_curLabelMode == SHOW

// Line style
string in_curLineStyle = input.string(defval=STYLE_SOLID, title="Line Style", options=[STYLE_SOLID, STYLE_DOTTED, STYLE_DASHED], group=G_CUR)
int in_curWidth = input.int(defval=1, title="Line Width", minval=1, maxval=5, group=G_CUR)

// Colors
string in_curColorMode = input.string(defval=COLOR_MODE_DEFAULT, title="Level Colors", options=[COLOR_MODE_DEFAULT, COLOR_MODE_CUSTOM], group=G_CUR, tooltip=TT_LEVEL_COLORS)
color in_curPositiveCustom = input.color(defval=COLOR_POSITIVE_DEFAULT, title="Positive Level Color", group=G_CUR, active=in_curColorMode == COLOR_MODE_CUSTOM)
color in_curNegativeCustom = input.color(defval=COLOR_NEGATIVE_DEFAULT, title="Negative Level Color", group=G_CUR, active=in_curColorMode == COLOR_MODE_CUSTOM)

color curPositiveColor = in_curColorMode == COLOR_MODE_CUSTOM ? in_curPositiveCustom : COLOR_POSITIVE_DEFAULT
color curNegativeColor = in_curColorMode == COLOR_MODE_CUSTOM ? in_curNegativeCustom : COLOR_NEGATIVE_DEFAULT

// ──────────────────────────────────────────────
// 🟦 Subregion: Current Close / CCL Inputs
// ──────────────────────────────────────────────

// Display
string in_ccLineMode = input.string(defval=SHOW, title="Line Plot", options=[SHOW, HIDE], group=G_CC, tooltip=TT_CC)
string in_ccLabelMode = input.string(defval=SHOW, title="Right-side Label", options=[SHOW, HIDE], group=G_CC)
bool showCcLabel = in_ccLabelMode == SHOW

// Line style
string in_ccLineStyle = input.string(defval=STYLE_DOTTED, title="Line Style", options=[STYLE_SOLID, STYLE_DOTTED, STYLE_DASHED], group=G_CC)
int in_ccWidth = input.int(defval=1, title="Line Width", minval=1, maxval=5, group=G_CC)

// Colors
string in_ccColorMode = input.string(defval=COLOR_MODE_DEFAULT, title="Level Colors", options=[COLOR_MODE_DEFAULT, COLOR_MODE_CUSTOM], group=G_CC, tooltip=TT_LEVEL_COLORS)
color in_ccPositiveCustom = input.color(defval=COLOR_POSITIVE_DEFAULT, title="Positive Level Color", group=G_CC, active=in_ccColorMode == COLOR_MODE_CUSTOM)
color in_ccNegativeCustom = input.color(defval=COLOR_NEGATIVE_DEFAULT, title="Negative Level Color", group=G_CC, active=in_ccColorMode == COLOR_MODE_CUSTOM)

color ccPositiveColor = in_ccColorMode == COLOR_MODE_CUSTOM ? in_ccPositiveCustom : COLOR_POSITIVE_DEFAULT
color ccNegativeColor = in_ccColorMode == COLOR_MODE_CUSTOM ? in_ccNegativeCustom : COLOR_NEGATIVE_DEFAULT

// ──────────────────────────────────────────────
// 🟦 Subregion: Previous Close / PCL Inputs
// ──────────────────────────────────────────────

// Display
string in_pclStartMode = input.string(defval=CLOSE_START_ACTIVE, title="Line Plot Start", options=[CLOSE_START_ACTIVE, CLOSE_START_SOURCE], group=G_PCL, tooltip=TT_PCL_LINE_START)
string in_pclLineMode = input.string(defval=SHOW, title="Line Plot", options=[SHOW, HIDE], group=G_PCL, tooltip=TT_PCL)
string in_pclLabelMode = input.string(defval=SHOW, title="Right-side Label", options=[SHOW, HIDE], group=G_PCL)
bool showPclLine = in_pclLineMode == SHOW
bool showPclLabel = in_pclLabelMode == SHOW

// Line style
string in_pclLineStyle = input.string(defval=STYLE_DOTTED, title="Line Style", options=[STYLE_SOLID, STYLE_DOTTED, STYLE_DASHED], group=G_PCL)
int in_pclWidth = input.int(defval=1, title="Line Width", minval=1, maxval=5, group=G_PCL)

// Colors
string in_pclColorMode = input.string(defval=COLOR_MODE_DEFAULT, title="Level Colors", options=[COLOR_MODE_DEFAULT, COLOR_MODE_CUSTOM], group=G_PCL, tooltip=TT_LEVEL_COLORS)
color in_pclPositiveCustom = input.color(defval=COLOR_PCL_DEFAULT, title="Positive Level Color", group=G_PCL, active=in_pclColorMode == COLOR_MODE_CUSTOM)
color in_pclNegativeCustom = input.color(defval=COLOR_PCL_DEFAULT, title="Negative Level Color", group=G_PCL, active=in_pclColorMode == COLOR_MODE_CUSTOM)

color pclPositiveColor = in_pclColorMode == COLOR_MODE_CUSTOM ? in_pclPositiveCustom : COLOR_PCL_DEFAULT
color pclNegativeColor = in_pclColorMode == COLOR_MODE_CUSTOM ? in_pclNegativeCustom : COLOR_PCL_DEFAULT

// ──────────────────────────────────────────────
// 🟦 Subregion: Session / RTH Open / OPEN Inputs
// ──────────────────────────────────────────────

// Display
string in_openLineMode = input.string(defval=SHOW, title="Line Plot", options=[SHOW, HIDE], group=G_OPEN, tooltip=TT_OPEN)
string in_openLabelMode = input.string(defval=SHOW, title="Right-side Label", options=[SHOW, HIDE], group=G_OPEN)

string in_prevOpenLineMode = input.string(
     defval=HIDE,
     title="OPEN[1] Line Plot",
     options=[SHOW, HIDE],
     group=G_OPEN,
     tooltip=TT_PREV_OPEN_PREMARKET)

string in_prevOpenLabelMode = input.string(
     defval=HIDE,
     title="OPEN[1] Right-side Label",
     options=[SHOW, HIDE],
     group=G_OPEN)

bool showPrevOpenLine = in_prevOpenLineMode == SHOW
bool showPrevOpenLabel = in_prevOpenLabelMode == SHOW

bool showOpenLine = in_openLineMode == SHOW
bool showOpenLabel = in_openLabelMode == SHOW

// Line style
string in_openLineStyle = input.string(defval=STYLE_DOTTED, title="Line Style", options=[STYLE_SOLID, STYLE_DOTTED, STYLE_DASHED], group=G_OPEN)
int in_openWidth = input.int(defval=1, title="Line Width", minval=1, maxval=5, group=G_OPEN)

// Colors
string in_openColorMode = input.string(defval=COLOR_MODE_DEFAULT, title="Level Colors", options=[COLOR_MODE_DEFAULT, COLOR_MODE_CUSTOM], group=G_OPEN, tooltip=TT_LEVEL_COLORS)
color in_openPositiveCustom = input.color(defval=COLOR_POSITIVE_DEFAULT, title="Positive Level Color", group=G_OPEN, active=in_openColorMode == COLOR_MODE_CUSTOM)
color in_openNegativeCustom = input.color(defval=COLOR_NEGATIVE_DEFAULT, title="Negative Level Color", group=G_OPEN, active=in_openColorMode == COLOR_MODE_CUSTOM)

color openPositiveColor = in_openColorMode == COLOR_MODE_CUSTOM ? in_openPositiveCustom : COLOR_POSITIVE_DEFAULT
color openNegativeColor = in_openColorMode == COLOR_MODE_CUSTOM ? in_openNegativeCustom : COLOR_NEGATIVE_DEFAULT

// ──────────────────────────────────────────────
// 🟦 Subregion: Premarket Open / PMO Inputs
// ──────────────────────────────────────────────

// Display
string in_pmoLineMode = input.string(defval=SHOW, title="Line Plot", options=[SHOW, HIDE], group=G_PMO, tooltip=TT_PMO)
string in_pmoLabelMode = input.string(defval=SHOW, title="Right-side Label", options=[SHOW, HIDE], group=G_PMO)
bool showPmoLine = in_pmoLineMode == SHOW
bool showPmoLabel = in_pmoLabelMode == SHOW

// Line style
string in_pmoLineStyle = input.string(defval=STYLE_DOTTED, title="Line Style", options=[STYLE_SOLID, STYLE_DOTTED, STYLE_DASHED], group=G_PMO)
int in_pmoWidth = input.int(defval=1, title="Line Width", minval=1, maxval=5, group=G_PMO)

// Colors
string in_pmoColorMode = input.string(defval=COLOR_MODE_DEFAULT, title="Level Colors", options=[COLOR_MODE_DEFAULT, COLOR_MODE_CUSTOM], group=G_PMO, tooltip=TT_LEVEL_COLORS)
color in_pmoPositiveCustom = input.color(defval=COLOR_POSITIVE_DEFAULT, title="Positive Level Color", group=G_PMO, active=in_pmoColorMode == COLOR_MODE_CUSTOM)
color in_pmoNegativeCustom = input.color(defval=COLOR_NEGATIVE_DEFAULT, title="Negative Level Color", group=G_PMO, active=in_pmoColorMode == COLOR_MODE_CUSTOM)

color pmoPositiveColor = in_pmoColorMode == COLOR_MODE_CUSTOM ? in_pmoPositiveCustom : COLOR_POSITIVE_DEFAULT
color pmoNegativeColor = in_pmoColorMode == COLOR_MODE_CUSTOM ? in_pmoNegativeCustom : COLOR_NEGATIVE_DEFAULT

// ──────────────────────────────────────────────
// 🟦 Subregion: LTF Candle Level Inputs
// ──────────────────────────────────────────────

// Level visibility
bool in_showPrev10mHL = input.bool(defval=false, title="10m[1] Hi/Lo", group=G_LTF, inline="10m")
bool in_showPrev10mHLLabel = input.bool(defval=false, title="Label", group=G_LTF, inline="10m")
bool in_showPrev10mCL = input.bool(defval=false, title="Close[1]", group=G_LTF, inline="10m")
bool in_showPrev10mCLLabel = input.bool(defval=false, title="Label", group=G_LTF, inline="10m", tooltip=TT_LTF_CLOSE_LABEL)

bool in_showPrev15mHL = input.bool(defval=false, title="15m[1] Hi/Lo", group=G_LTF, inline="15m")
bool in_showPrev15mHLLabel = input.bool(defval=false, title="Label", group=G_LTF, inline="15m")
bool in_showPrev15mCL = input.bool(defval=false, title="Close[1]", group=G_LTF, inline="15m")
bool in_showPrev15mCLLabel = input.bool(defval=false, title="Label", group=G_LTF, inline="15m", tooltip=TT_LTF_CLOSE_LABEL)

bool in_showPrev30mHL = input.bool(defval=false, title="30m[1] Hi/Lo", group=G_LTF, inline="30m")
bool in_showPrev30mHLLabel = input.bool(defval=false, title="Label", group=G_LTF, inline="30m")
bool in_showPrev30mCL = input.bool(defval=false, title="Close[1]", group=G_LTF, inline="30m")
bool in_showPrev30mCLLabel = input.bool(defval=false, title="Label", group=G_LTF, inline="30m", tooltip=TT_LTF_CLOSE_LABEL)

bool in_showPrev1hHL = input.bool(defval=false, title="1h[1] Hi/Lo", group=G_LTF, inline="1h")
bool in_showPrev1hHLLabel = input.bool(defval=false, title="Label", group=G_LTF, inline="1h")
bool in_showPrev1hCL = input.bool(defval=false, title="Close[1]", group=G_LTF, inline="1h")
bool in_showPrev1hCLLabel = input.bool(defval=false, title="Label", group=G_LTF, inline="1h", tooltip=TT_LTF_CLOSE_LABEL)

bool in_showPrev2hHL = input.bool(defval=false, title="2h[1] Hi/Lo", group=G_LTF, inline="2h")
bool in_showPrev2hHLLabel = input.bool(defval=false, title="Label", group=G_LTF, inline="2h")
bool in_showPrev2hCL = input.bool(defval=false, title="Close[1]", group=G_LTF, inline="2h")
bool in_showPrev2hCLLabel = input.bool(defval=false, title="Label", group=G_LTF, inline="2h", tooltip=TT_LTF_CLOSE_LABEL)

bool in_showPrev4hHL = input.bool(defval=false, title="4h[1] Hi/Lo", group=G_LTF, inline="4h")
bool in_showPrev4hHLLabel = input.bool(defval=false, title="Label", group=G_LTF, inline="4h")
bool in_showPrev4hCL = input.bool(defval=false, title="Close[1]", group=G_LTF, inline="4h")
bool in_showPrev4hCLLabel = input.bool(defval=false, title="Label", group=G_LTF, inline="4h", tooltip=TT_LTF_CLOSE_LABEL)

bool in_showPrev8hHL = input.bool(defval=false, title="8h[1] Hi/Lo", group=G_LTF, inline="8h")
bool in_showPrev8hHLLabel = input.bool(defval=false, title="Label", group=G_LTF, inline="8h")
bool in_showPrev8hCL = input.bool(defval=false, title="Close[1]", group=G_LTF, inline="8h")
bool in_showPrev8hCLLabel = input.bool(defval=false, title="Label", group=G_LTF, inline="8h", tooltip=TT_LTF_CLOSE_LABEL)

// Line start
string in_ltfStartMode = input.string(defval=CLOSE_START_ACTIVE, title="Line Plot Start", options=[CLOSE_START_ACTIVE, HL_START_SOURCE], group=G_LTF, tooltip=TT_LTF_LINE_START)

// Line style
string in_ltfLineStyle = input.string(defval=STYLE_DOTTED, title="Line Style", options=[STYLE_SOLID, STYLE_DOTTED, STYLE_DASHED], group=G_LTF)
int in_ltfWidth = input.int(defval=1, title="Line Width", minval=1, maxval=5, group=G_LTF, tooltip=TT_PREV_CANDLE)

// Colors
string in_ltfColorMode = input.string(defval=COLOR_MODE_DEFAULT, title="Level Colors", options=[COLOR_MODE_DEFAULT, COLOR_MODE_CUSTOM], group=G_LTF, tooltip=TT_LEVEL_COLORS)
color in_ltfPositiveCustom = input.color(defval=COLOR_POSITIVE_DEFAULT, title="Positive Level Color", group=G_LTF, active=in_ltfColorMode == COLOR_MODE_CUSTOM)
color in_ltfNegativeCustom = input.color(defval=COLOR_NEGATIVE_DEFAULT, title="Negative Level Color", group=G_LTF, active=in_ltfColorMode == COLOR_MODE_CUSTOM)

color ltfPositiveColor = in_ltfColorMode == COLOR_MODE_CUSTOM ? in_ltfPositiveCustom : COLOR_POSITIVE_DEFAULT
color ltfNegativeColor = in_ltfColorMode == COLOR_MODE_CUSTOM ? in_ltfNegativeCustom : COLOR_NEGATIVE_DEFAULT

// ──────────────────────────────────────────────
// 🟦 Subregion: Daily Candle Level Inputs
// ──────────────────────────────────────────────

// Level visibility
bool in_showPrev1dHL = input.bool(defval=false, title="P1D Hi/Lo", group=G_DAILY, inline="1d")
bool in_showPrev1dHLLabel = input.bool(defval=true, title="Label", group=G_DAILY, inline="1d", tooltip=TT_DAILY_HL_LABEL)

bool in_showPrev2dHL = input.bool(defval=false, title="P2D Hi/Lo", group=G_DAILY, inline="2d")
bool in_showPrev2dHLLabel = input.bool(defval=false, title="Label", group=G_DAILY, inline="2d")
bool in_showPrev2dCL = input.bool(defval=false, title="P2D Close", group=G_DAILY, inline="2d")
bool in_showPrev2dCLLabel = input.bool(defval=false, title="Label", group=G_DAILY, inline="2d")

bool in_showPrev3dHL = input.bool(defval=false, title="P3D Hi/Lo", group=G_DAILY, inline="3d")
bool in_showPrev3dHLLabel = input.bool(defval=false, title="Label", group=G_DAILY, inline="3d")
bool in_showPrev3dCL = input.bool(defval=false, title="P3D Close", group=G_DAILY, inline="3d")
bool in_showPrev3dCLLabel = input.bool(defval=false, title="Label", group=G_DAILY, inline="3d")

// Line Start
string in_dailyStartMode = input.string(defval=CLOSE_START_ACTIVE, title="Line Plot Start", options=[CLOSE_START_ACTIVE, START_SOURCE_WINDOW, HL_START_SOURCE], group=G_DAILY, tooltip=TT_DAILY_LINE_START)

// Line style
string in_dailyLineStyle = input.string(defval=STYLE_DOTTED, title="Line Style", options=[STYLE_SOLID, STYLE_DOTTED, STYLE_DASHED], group=G_DAILY)
int in_dailyWidth = input.int(defval=1, title="Line Width", minval=1, maxval=5, group=G_DAILY)

// Colors
string in_dailyColorMode = input.string(defval=COLOR_MODE_DEFAULT, title="Level Colors", options=[COLOR_MODE_DEFAULT, COLOR_MODE_CUSTOM], group=G_DAILY, tooltip=TT_LEVEL_COLORS)
color in_dailyPositiveCustom = input.color(defval=COLOR_POSITIVE_DEFAULT, title="Positive Level Color", group=G_DAILY, active=in_dailyColorMode == COLOR_MODE_CUSTOM)
color in_dailyNegativeCustom = input.color(defval=COLOR_NEGATIVE_DEFAULT, title="Negative Level Color", group=G_DAILY, active=in_dailyColorMode == COLOR_MODE_CUSTOM)

color dailyPositiveColor = in_dailyColorMode == COLOR_MODE_CUSTOM ? in_dailyPositiveCustom : COLOR_POSITIVE_DEFAULT
color dailyNegativeColor = in_dailyColorMode == COLOR_MODE_CUSTOM ? in_dailyNegativeCustom : COLOR_NEGATIVE_DEFAULT

// ──────────────────────────────────────────────
// 🟦 Subregion: Weekly Candle Level Inputs
// ──────────────────────────────────────────────

// Level visibility
bool in_showPrev1wHL = input.bool(defval=false, title="P1W Hi/Lo", group=G_WEEKLY, inline="1w")
bool in_showPrev1wHLLabel = input.bool(defval=true, title="Label", group=G_WEEKLY, inline="1w", tooltip=TT_WEEKLY_HL_LABEL)
bool in_showPrev1wCL = input.bool(defval=false, title="Close[1]", group=G_WEEKLY, inline="1w")
bool in_showPrev1wCLLabel = input.bool(defval=false, title="Label", group=G_WEEKLY, inline="1w", tooltip=TT_WEEKLY_CLOSE_LABEL)

bool in_showPrev2wHL = input.bool(defval=false, title="P2W Hi/Lo", group=G_WEEKLY, inline="2w")
bool in_showPrev2wHLLabel = input.bool(defval=false, title="Label", group=G_WEEKLY, inline="2w")
bool in_showPrev2wCL = input.bool(defval=false, title="P2W Close", group=G_WEEKLY, inline="2w")
bool in_showPrev2wCLLabel = input.bool(defval=false, title="Label", group=G_WEEKLY, inline="2w")

// Line Start
string in_weeklyStartMode = input.string(defval=CLOSE_START_ACTIVE, title="Line Plot Start", options=[CLOSE_START_ACTIVE, START_SOURCE_WINDOW, HL_START_SOURCE], group=G_WEEKLY, tooltip=TT_WEEKLY_LINE_START)

// Line style
string in_weeklyLineStyle = input.string(defval=STYLE_DOTTED, title="Line Style", options=[STYLE_SOLID, STYLE_DOTTED, STYLE_DASHED], group=G_WEEKLY)
int in_weeklyWidth = input.int(defval=1, title="Line Width", minval=1, maxval=5, group=G_WEEKLY)

// Colors
string in_weeklyColorMode = input.string(defval=COLOR_MODE_DEFAULT, title="Level Colors", options=[COLOR_MODE_DEFAULT, COLOR_MODE_CUSTOM], group=G_WEEKLY, tooltip=TT_LEVEL_COLORS)
color in_weeklyPositiveCustom = input.color(defval=COLOR_POSITIVE_DEFAULT, title="Positive Level Color", group=G_WEEKLY, active=in_weeklyColorMode == COLOR_MODE_CUSTOM)
color in_weeklyNegativeCustom = input.color(defval=COLOR_NEGATIVE_DEFAULT, title="Negative Level Color", group=G_WEEKLY, active=in_weeklyColorMode == COLOR_MODE_CUSTOM)

color weeklyPositiveColor = in_weeklyColorMode == COLOR_MODE_CUSTOM ? in_weeklyPositiveCustom : COLOR_POSITIVE_DEFAULT
color weeklyNegativeColor = in_weeklyColorMode == COLOR_MODE_CUSTOM ? in_weeklyNegativeCustom : COLOR_NEGATIVE_DEFAULT

// ──────────────────────────────────────────────
// 🟦 Subregion: Monthly Candle Level Inputs
// ──────────────────────────────────────────────

// Level visibility
bool in_showPrev1mHL = input.bool(defval=false, title="P1M Hi/Lo", group=G_MONTHLY, inline="1m")
bool in_showPrev1mHLLabel = input.bool(defval=true, title="Label", group=G_MONTHLY, inline="1m", tooltip=TT_MONTHLY_HL_LABEL)
bool in_showPrev1mCL = input.bool(defval=false, title="Close[1]", group=G_MONTHLY, inline="1m")
bool in_showPrev1mCLLabel = input.bool(defval=false, title="Label", group=G_MONTHLY, inline="1m", tooltip=TT_MONTHLY_CLOSE_LABEL)

bool in_showPrev2mHL = input.bool(defval=false, title="P2M Hi/Lo", group=G_MONTHLY, inline="2m")
bool in_showPrev2mHLLabel = input.bool(defval=false, title="Label", group=G_MONTHLY, inline="2m")
bool in_showPrev2mCL = input.bool(defval=false, title="P2M Close", group=G_MONTHLY, inline="2m")
bool in_showPrev2mCLLabel = input.bool(defval=false, title="Label", group=G_MONTHLY, inline="2m")

bool in_showPrev3mHL = input.bool(defval=false, title="P3M Hi/Lo", group=G_MONTHLY, inline="3m")
bool in_showPrev3mHLLabel = input.bool(defval=false, title="Label", group=G_MONTHLY, inline="3m")
bool in_showPrev3mCL = input.bool(defval=false, title="P3M Close", group=G_MONTHLY, inline="3m")
bool in_showPrev3mCLLabel = input.bool(defval=false, title="Label", group=G_MONTHLY, inline="3m")

// Line Start
string in_monthlyStartMode = input.string(defval=CLOSE_START_ACTIVE, title="Line Plot Start", options=[CLOSE_START_ACTIVE, START_SOURCE_WINDOW, HL_START_SOURCE], group=G_MONTHLY, tooltip=TT_MONTHLY_LINE_START)

// Line style
string in_monthlyLineStyle = input.string(defval=STYLE_DOTTED, title="Line Style", options=[STYLE_SOLID, STYLE_DOTTED, STYLE_DASHED], group=G_MONTHLY)
int in_monthlyWidth = input.int(defval=1, title="Line Width", minval=1, maxval=5, group=G_MONTHLY)

// Colors
string in_monthlyColorMode = input.string(defval=COLOR_MODE_DEFAULT, title="Level Colors", options=[COLOR_MODE_DEFAULT, COLOR_MODE_CUSTOM], group=G_MONTHLY, tooltip=TT_LEVEL_COLORS)
color in_monthlyPositiveCustom = input.color(defval=COLOR_POSITIVE_DEFAULT, title="Positive Level Color", group=G_MONTHLY, active=in_monthlyColorMode == COLOR_MODE_CUSTOM)
color in_monthlyNegativeCustom = input.color(defval=COLOR_NEGATIVE_DEFAULT, title="Negative Level Color", group=G_MONTHLY, active=in_monthlyColorMode == COLOR_MODE_CUSTOM)

color monthlyPositiveColor = in_monthlyColorMode == COLOR_MODE_CUSTOM ? in_monthlyPositiveCustom : COLOR_POSITIVE_DEFAULT
color monthlyNegativeColor = in_monthlyColorMode == COLOR_MODE_CUSTOM ? in_monthlyNegativeCustom : COLOR_NEGATIVE_DEFAULT

// ──────────────────────────────────────────────
// 🟦 Subregion: Right Label Inputs
// ──────────────────────────────────────────────

// Label style
bool showLabels = true
int in_sigFig = input.int(defval=5, title="Significant Figures", minval=2, maxval=20, group=G_LABELS)
string in_labelSize = input.string(defval="Normal", title="Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=G_LABELS)

// Dynamic label padding
string in_labelPaddingMode = input.string(defval=LABEL_PADDING_GROUPED, title="Label Padding Mode", options=[LABEL_PADDING_GROUPED, LABEL_PADDING_INDIVIDUAL], group=G_LABELS)
int in_labelBasePad = input.int(defval=3, title="First Label Padding", minval=0, maxval=200, group=G_LABELS)
int in_labelPadStep = input.int(defval=5, title="Padding Between Labels", minval=1, maxval=40, group=G_LABELS)

bool useGroupedLabelPadding = in_labelPaddingMode == LABEL_PADDING_GROUPED

// Label rows
string in_labelShowPriceMode = input.string(defval=SHOW, title="Price Row", options=[SHOW, HIDE], group=G_LABELS, tooltip=TT_LABEL_ROWS)
bool in_labelShowPrice = in_labelShowPriceMode == SHOW

string in_labelShowDiffMode = input.string(defval=SHOW, title="$ Difference Row", options=[SHOW, HIDE], group=G_LABELS, tooltip=TT_LABEL_ROWS)
bool in_labelShowDiff = in_labelShowDiffMode == SHOW

string in_labelShowPctMode = input.string(defval=SHOW, title="% Difference Row", options=[SHOW, HIDE], group=G_LABELS, tooltip=TT_LABEL_ROWS)
bool in_labelShowPct = in_labelShowPctMode == SHOW

// ──────────────────────────────────────────────
// 🟦 Subregion: Debug Inputs
// ──────────────────────────────────────────────

// Debug display
string in_debugMode = input.string(defval=HIDE, title="Asset / Session Debug Label", options=[SHOW, HIDE], group=G_DEBUG)
bool showDebugLabel = in_debugMode == SHOW

// ==============================================================================================
// 🔴 END REGION: Inputs
// ==============================================================================================


// ==============================================================================================
// 🟢 REGION: Helper Functions
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: Period Helpers
// ──────────────────────────────────────────────

f_periodStartTime(bool _isNewPeriod) =>
    var int _start = na

    if _isNewPeriod or na(_start)
        _start := time

    _start

f_targetTimeframeAvailable(simple string _tf) =>
    int _chartSeconds = timeframe.in_seconds()
    int _targetSeconds = timeframe.in_seconds(_tf)

    not na(_chartSeconds) and not na(_targetSeconds) and _chartSeconds <= _targetSeconds

// ──────────────────────────────────────────────
// 🟦 Subregion: Script-Specific History Resolvers
// ──────────────────────────────────────────────

f_dailyHistFloat(bool _isEquityLike, bool _isNativeSessionAsset, array<float> _equityArr, array<float> _nativeArr, int _idx) =>
    _isEquityLike ? LVL.histFloat(_equityArr, _idx) : _isNativeSessionAsset ? LVL.histFloat(_nativeArr, _idx) : na

f_dailyHistInt(bool _isEquityLike, bool _isNativeSessionAsset, array<int> _equityArr, array<int> _nativeArr, int _idx) =>
    _isEquityLike ? LVL.histInt(_equityArr, _idx) : _isNativeSessionAsset ? LVL.histInt(_nativeArr, _idx) : na

f_dailyResolvedLevel(bool _isEquityLike, bool _isNativeSessionAsset, float _manual, float _request) =>
    _isEquityLike ? _manual : _isNativeSessionAsset and not na(_manual) ? _manual : _request

f_buildLabelPads(array<bool> _visible, array<int> _groups, array<int> _order, bool _grouped, int _basePad, int _step) =>
    int _count = array.size(_visible)
    int _orderCount = array.size(_order)
    array<int> _pads = array.new_int(_count, _basePad)
    int _cursor = _basePad

    if _orderCount > 0
        if _grouped
            int _firstIdx = array.get(_order, 0)
            int _activeGroup = array.get(_groups, _firstIdx)
            bool _groupVisible = false

            for _rank = 0 to _orderCount - 1
                int _idx = array.get(_order, _rank)
                int _group = array.get(_groups, _idx)

                if _rank > 0 and _group != _activeGroup
                    if _groupVisible
                        _cursor += _step

                    _activeGroup := _group
                    _groupVisible := false

                array.set(_pads, _idx, _cursor)
                _groupVisible := _groupVisible or array.get(_visible, _idx)
        else
            for _rank = 0 to _orderCount - 1
                int _idx = array.get(_order, _rank)

                array.set(_pads, _idx, _cursor)

                if array.get(_visible, _idx)
                    _cursor += _step

    _pads

f_splitLevelLabelText(string _topTag, string _bottomTag, float _level, float _price, int _pad, bool _showPrice, bool _showDiff, bool _showPct, int _sigFig) =>
    string _top =
         LVL.levelLabelText(
             _topTag,
             _level,
             _price,
             _pad,
             _showPrice,
             _showDiff,
             _showPct,
             _sigFig)

    string _bottom =
         LVL.levelLabelText(
             _bottomTag,
             _level,
             _price,
             _pad,
             false,
             false,
             false,
             _sigFig)

    _top + "\n" + _bottom

// ==============================================================================================
// 🔴 END REGION: Helper Functions
// ==============================================================================================


// ==============================================================================================
// 🟢 REGION: Candle Level Engine
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: Asset / Session State
// ──────────────────────────────────────────────

bool isCrypto = syminfo.type == "crypto"
bool isFutures = syminfo.type == "futures"
bool isIndex = syminfo.type == "index"
bool isForex = syminfo.type == "forex"
bool isCfd = syminfo.type == "cfd"
bool isCommodity = syminfo.type == "commodity"
bool isSpot = syminfo.type == "spot"
bool isSwap = syminfo.type == "swap"
bool isBond = syminfo.type == "bond"
bool isStock = syminfo.type == "stock"
bool isFund = syminfo.type == "fund"
bool isDepositaryReceipt = syminfo.type == "dr"
bool isEquityLike = isStock or isFund or isDepositaryReceipt
bool isCashNativeAsset = isIndex or isForex or isCfd or isCommodity or isSpot or isSwap or isBond
bool isNativeSessionAsset = isCrypto or isFutures or isCashNativeAsset
bool isSupported = isEquityLike or isNativeSessionAsset

// 🔹 Exchange-Day + US Equity Session Ownership
bool newExchangeDay = ta.change(time(TF_1D)) != 0
bool newCalendarDate = barstate.isfirst or year(time) != year(time[1]) or month(time) != month(time[1]) or dayofmonth(time) != dayofmonth(time[1])
bool isUsEquitySession = isEquityLike and syminfo.timezone == "America/New_York"
bool useUsIntradaySessionModel = isUsEquitySession and timeframe.isintraday

// TradingView exposes the reduced US RTH subsession as "us_regular" for supported CME Group futures.
// Restrict the model to CME/CBOT/COMEX/NYMEX prefixes so an unsupported named-session fallback cannot
// masquerade as a valid RTH stream on unrelated futures markets.
bool isCmeGroupFutures =
     isFutures and
     (str.contains(syminfo.prefix, "CME") or
      str.contains(syminfo.prefix, "CBOT") or
      str.contains(syminfo.prefix, "COMEX") or
      str.contains(syminfo.prefix, "NYMEX"))

bool useCmeFuturesRthModel = isCmeGroupFutures and timeframe.isintraday
bool useNativeCashOpenModel = isCashNativeAsset and timeframe.isintraday

string assetTypeStr =
     isCrypto ? "crypto" :
     isFutures ? "futures" :
     isIndex ? "index" :
     isForex ? "forex" :
     isCfd ? "cfd" :
     isCommodity ? "commodity" :
     isSpot ? "spot" :
     isSwap ? "swap" :
     isBond ? "bond" :
     isStock ? "stock" :
     isFund ? "fund" :
     isDepositaryReceipt ? "depositary receipt" : syminfo.type

string sessionTypeStr =
     isCrypto ? "24x7" :
     useCmeFuturesRthModel ? "native futures + CME US RTH OPEN" :
     isFutures ? "native futures session" :
     isCashNativeAsset ? "native cash / exchange session" :
     isUsEquitySession ? "US RTH closes / EXT highs-lows" :
     "native exchange day"

// 🔹 US Equity Intraday Windows
string stockRTHSession = "0930-1600"
string stockPostSession = "1600-2000"
string stockPreSession = "0400-0929"

bool inRTH = useUsIntradaySessionModel ? not na(time(timeframe.period, stockRTHSession)) : false
bool prevInRTH = useUsIntradaySessionModel ? not na(time(timeframe.period, stockRTHSession)[1]) : false
bool inPremarket = useUsIntradaySessionModel ? not na(time(timeframe.period, stockPreSession)) : false
bool prevInPremarket = useUsIntradaySessionModel ? not na(time(timeframe.period, stockPreSession)[1]) : false
bool inPostmarket = useUsIntradaySessionModel ? not na(time(timeframe.period, stockPostSession)) : false
bool inAnyStockSession = isEquityLike ? (useUsIntradaySessionModel ? (inPremarket or inRTH or inPostmarket) : true) : false

// 🔹 Session Transition Triggers
bool stocksOpenTrig = useUsIntradaySessionModel and inRTH and (not prevInRTH or newCalendarDate)
bool premarketOpenTrig = useUsIntradaySessionModel and inPremarket and (not prevInPremarket or newCalendarDate)

// Full-session equity history resets once per exchange calendar day on intraday US charts.
// On Daily+ US charts and non-US equities, the native exchange-day boundary owns the reset.
bool stockFullSessionDateTrig = useUsIntradaySessionModel and inAnyStockSession and newCalendarDate
bool stockFullSessionStartTrig = isEquityLike and (useUsIntradaySessionModel ? stockFullSessionDateTrig : newExchangeDay)

// ──────────────────────────────────────────────
// 🟦 Subregion: Asset-Aware Symbols
// ──────────────────────────────────────────────

string regularSymbol = ticker.new(prefix=syminfo.prefix, ticker=syminfo.ticker, session=session.regular)
string extendedSymbol = ticker.new(prefix=syminfo.prefix, ticker=syminfo.ticker, session=session.extended)
string futuresUsRthSymbol = ticker.new(prefix=syminfo.prefix, ticker=syminfo.ticker, session="us_regular")

// RTH/EXT split:
// • Close references use regular-session data for stocks/funds/ADRs.
// • High/low references use extended-session data for stocks/funds/ADRs.
// • Crypto/futures/indices/forex/CFDs/commodities/spot/swaps/bonds use their native stream for both.
string closeSymbol = isEquityLike ? regularSymbol : syminfo.tickerid
string highLowSymbol = isEquityLike ? extendedSymbol : syminfo.tickerid

[assetHigh, assetLow, assetClose] =
     request.security(
         symbol=highLowSymbol,
         timeframe=timeframe.period,
         expression=[high, low, close],
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_on)

float closeAssetCloseRaw =
     request.security(
         symbol=closeSymbol,
         timeframe=timeframe.period,
         expression=close,
         gaps=barmerge.gaps_on,
         lookahead=barmerge.lookahead_off)

// Confirmed regular-session Daily close used only by the outside-RTH CCL reference.
// The Daily RTH bar is the canonical close source because its official close can differ from
// the final visible intraday candle. lookahead_off keeps the value confirmed/non-future-looking.
[rthDailyCloseConfirmed, rthDailyCloseTime] =
     request.security(
         symbol=closeSymbol,
         timeframe=TF_1D,
         expression=[close, time_close],
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off,
         calc_bars_count=3)

float candleCloseSource = isEquityLike ? closeAssetCloseRaw : close
bool candleCloseSourceValid = isEquityLike ? not na(closeAssetCloseRaw) : not na(close)

// 🔹 CME Futures US-RTH Stream
// gaps_on makes bars outside the named RTH subsession resolve to na, which gives us an explicit
// ETH ↔ RTH transition on intraday CME Group futures charts without hardcoding NQ/ES clock times.
[futuresRthOpenRaw, futuresRthBarTime] =
     request.security(
         symbol=futuresUsRthSymbol,
         timeframe=timeframe.period,
         expression=[open, time],
         gaps=barmerge.gaps_on,
         lookahead=barmerge.lookahead_off)

bool inFuturesRth = useCmeFuturesRthModel and not na(futuresRthOpenRaw)
bool prevInFuturesRth = useCmeFuturesRthModel ? inFuturesRth[1] : false
bool futuresRthOpenTrig = useCmeFuturesRthModel and inFuturesRth and (not prevInFuturesRth or newExchangeDay)

// ──────────────────────────────────────────────
// 🟦 Subregion: Manual Extended-Session Prior High / Low
// ──────────────────────────────────────────────

// P1D / P2D / P3D high-low levels are accumulated manually from completed sessions when possible.
// Important: for stocks/funds, do not fall back to daily high/low for these offsets because that can
// resolve to the RTH daily high/low on some symbols. If the manual full-session value is not ready yet,
// the matching high-low object stays hidden instead of showing the wrong RTH-only level.
// US-session equity history resets once at the first available bar of each new exchange day, so premarket / RTH / afterhours stay in one completed session bucket.
float stockExtHighSource = na(assetHigh) ? high : na(high) ? assetHigh : math.max(assetHigh, high)
float stockExtLowSource = na(assetLow) ? low : na(low) ? assetLow : math.min(assetLow, low)
float ltfHighSource = isEquityLike ? stockExtHighSource : assetHigh
float ltfLowSource = isEquityLike ? stockExtLowSource : assetLow
float ltfCloseSource = na(assetClose) ? close : assetClose

var float stockFullSessionHighExt = na
var float stockFullSessionLowExt = na
var int stockFullSessionHighTimeExt = na
var int stockFullSessionLowTimeExt = na
var int stockFullSessionStartTimeExt = na
var array<float> stockFullSessionHighHistoryExt = array.new_float()
var array<float> stockFullSessionLowHistoryExt = array.new_float()
var array<int> stockFullSessionHighTimeHistoryExt = array.new_int()
var array<int> stockFullSessionLowTimeHistoryExt = array.new_int()
var array<int> stockFullSessionStartTimeHistoryExt = array.new_int()

if isEquityLike and inAnyStockSession
    bool resetStockFullSession = stockFullSessionStartTrig or na(stockFullSessionHighExt) or na(stockFullSessionLowExt)

    if resetStockFullSession
        if not na(stockFullSessionHighExt) and not na(stockFullSessionLowExt)

            array.unshift(stockFullSessionHighHistoryExt, stockFullSessionHighExt)
            array.unshift(stockFullSessionLowHistoryExt, stockFullSessionLowExt)
            array.unshift(stockFullSessionHighTimeHistoryExt, stockFullSessionHighTimeExt)
            array.unshift(stockFullSessionLowTimeHistoryExt, stockFullSessionLowTimeExt)
            array.unshift(stockFullSessionStartTimeHistoryExt, stockFullSessionStartTimeExt)

            LVL.pruneHiLoHistory(
                 stockFullSessionHighHistoryExt,
                 stockFullSessionLowHistoryExt,
                 stockFullSessionHighTimeHistoryExt,
                 stockFullSessionLowTimeHistoryExt,
                 stockFullSessionStartTimeHistoryExt,
                 25)

        stockFullSessionHighExt := stockExtHighSource
        stockFullSessionLowExt := stockExtLowSource
        stockFullSessionHighTimeExt := not na(stockExtHighSource) ? time : na
        stockFullSessionLowTimeExt := not na(stockExtLowSource) ? time : na
        stockFullSessionStartTimeExt := time
    else
        if not na(stockExtHighSource) and (na(stockFullSessionHighExt) or stockExtHighSource > stockFullSessionHighExt)
            stockFullSessionHighExt := stockExtHighSource
            stockFullSessionHighTimeExt := time
        if not na(stockExtLowSource) and (na(stockFullSessionLowExt) or stockExtLowSource < stockFullSessionLowExt)
            stockFullSessionLowExt := stockExtLowSource
            stockFullSessionLowTimeExt := time

f_prevHLC(simple string _tf, simple int _offset) =>
    [_h, _l] =
         request.security(
             symbol=highLowSymbol,
             timeframe=_tf,
             expression=[high[_offset], low[_offset]],
             gaps=barmerge.gaps_off,
             lookahead=barmerge.lookahead_on,
             calc_bars_count=10)

    [_c, _ct] =
         request.security(
             symbol=closeSymbol,
             timeframe=_tf,
             expression=[close[_offset], time_close[_offset]],
             gaps=barmerge.gaps_off,
             lookahead=barmerge.lookahead_on,
             calc_bars_count=10)

    [_h, _l, _c, _ct]

f_trackPrevLtf(bool _isNewPeriod, float _hSrc, float _lSrc, float _cSrc) =>
    var float _curH = na
    var float _curL = na
    var float _curC = na
    var int _curHT = na
    var int _curLT = na
    var int _curCT = na
    var float _prevH = na
    var float _prevL = na
    var float _prevC = na
    var int _prevHT = na
    var int _prevLT = na
    var int _prevCT = na

    // For LTF close source mode, anchor to the chart candle that produced the close, not the next boundary.
    // Example: on a 3m chart inside a 15m candle, the completed 15m close is produced by the final 3m bar,
    // so the close line should start on that final 3m candle rather than one bar later at the 15m boundary.
    int _barCloseSourceTime = time
    bool _reset = _isNewPeriod or na(_curH) or na(_curL)

    if _reset
        if not na(_curH) and not na(_curL)
            _prevH := _curH
            _prevL := _curL
            _prevC := _curC
            _prevHT := _curHT
            _prevLT := _curLT
            _prevCT := _curCT

        _curH := _hSrc
        _curL := _lSrc
        _curC := _cSrc
        _curHT := not na(_hSrc) ? time : na
        _curLT := not na(_lSrc) ? time : na
        _curCT := not na(_cSrc) ? _barCloseSourceTime : na
    else
        if not na(_hSrc) and (na(_curH) or _hSrc > _curH)
            _curH := _hSrc
            _curHT := time
        if not na(_lSrc) and (na(_curL) or _lSrc < _curL)
            _curL := _lSrc
            _curLT := time
        if not na(_cSrc)
            _curC := _cSrc
            _curCT := _barCloseSourceTime

    [_prevH, _prevL, _prevC, _prevHT, _prevLT, _prevCT]

// ──────────────────────────────────────────────
// 🟦 Subregion: Current Daily Candle Levels
// ──────────────────────────────────────────────

bool newd1 = isEquityLike ? stockFullSessionStartTrig : newExchangeDay
int startTimed1 = f_periodStartTime(newd1)

// 🔹 Current-Day High / Low State
var float trackedCurDayHigh = na
var float trackedCurDayLow = na
var int curHodStartTime = na
var int curLodStartTime = na

// 🔹 Native-Session Daily History
var int nativeCurDayStartTime = na
var array<float> nativeDayHighHistory = array.new_float()
var array<float> nativeDayLowHistory = array.new_float()
var array<int> nativeDayHighTimeHistory = array.new_int()
var array<int> nativeDayLowTimeHistory = array.new_int()
var array<int> nativeDayStartTimeHistory = array.new_int()

if isNativeSessionAsset
    bool resetNativeDay = newd1 or barstate.isfirst or na(trackedCurDayHigh) or na(trackedCurDayLow)

    if resetNativeDay
        if newd1 and not na(trackedCurDayHigh) and not na(trackedCurDayLow)
            array.unshift(nativeDayHighHistory, trackedCurDayHigh)
            array.unshift(nativeDayLowHistory, trackedCurDayLow)
            array.unshift(nativeDayHighTimeHistory, curHodStartTime)
            array.unshift(nativeDayLowTimeHistory, curLodStartTime)
            array.unshift(nativeDayStartTimeHistory, nativeCurDayStartTime)

            LVL.pruneHiLoHistory(
                 nativeDayHighHistory,
                 nativeDayLowHistory,
                 nativeDayHighTimeHistory,
                 nativeDayLowTimeHistory,
                 nativeDayStartTimeHistory,
                 25)

        trackedCurDayHigh := assetHigh
        trackedCurDayLow := assetLow
        curHodStartTime := not na(assetHigh) ? time : na
        curLodStartTime := not na(assetLow) ? time : na
        nativeCurDayStartTime := time
    else
        if not na(assetHigh) and (na(trackedCurDayHigh) or assetHigh > trackedCurDayHigh)
            trackedCurDayHigh := assetHigh
            curHodStartTime := time
        if not na(assetLow) and (na(trackedCurDayLow) or assetLow < trackedCurDayLow)
            trackedCurDayLow := assetLow
            curLodStartTime := time
else if isEquityLike and inAnyStockSession
    if newd1 or na(trackedCurDayHigh) or na(trackedCurDayLow)
        trackedCurDayHigh := assetHigh
        trackedCurDayLow := assetLow
        curHodStartTime := not na(assetHigh) ? time : na
        curLodStartTime := not na(assetLow) ? time : na
    else
        if not na(assetHigh) and (na(trackedCurDayHigh) or assetHigh > trackedCurDayHigh)
            trackedCurDayHigh := assetHigh
            curHodStartTime := time
        if not na(assetLow) and (na(trackedCurDayLow) or assetLow < trackedCurDayLow)
            trackedCurDayLow := assetLow
            curLodStartTime := time

float curHodLevel = trackedCurDayHigh
float curLodLevel = trackedCurDayLow

// ──────────────────────────────────────────────
// 🟦 Subregion: OPEN / PMO / CCL Session Anchors
// ──────────────────────────────────────────────

// 🔹 US Equity Regular-Session Open
var float regularOpen = na
var int regularOpenStartTime = na

if stocksOpenTrig
    regularOpen := open
    regularOpenStartTime := time
else
    regularOpen := nz(regularOpen, regularOpen[1])
    regularOpenStartTime := nz(regularOpenStartTime, regularOpenStartTime[1])

// 🔹 CME Futures Current / Prior US-RTH Open
// The futures trading day normally begins in ETH before the next US-RTH session. At the native
// exchange-day rollover, promote the completed RTH open to OPEN[1] and clear the current OPEN.
// The first bar from TradingView's "us_regular" stream then owns the new [OPEN].
var float futuresRegularOpen = na
var int futuresRegularOpenStartTime = na
var float futuresPrevRegularOpen = na
var int futuresPrevRegularOpenStartTime = na
var int futuresExchangeDayStartTime = na

if useCmeFuturesRthModel and (newExchangeDay or na(futuresExchangeDayStartTime))
    futuresPrevRegularOpen := futuresRegularOpen
    futuresPrevRegularOpenStartTime := futuresRegularOpenStartTime
    futuresRegularOpen := na
    futuresRegularOpenStartTime := na
    futuresExchangeDayStartTime := time

if futuresRthOpenTrig
    futuresRegularOpen := futuresRthOpenRaw
    futuresRegularOpenStartTime := futuresRthBarTime

// 🔹 Native Cash-Market Session Open
// Indices and OTC/cash-market symbols do not share the US-equity or CME RTH model. Their OPEN is
// the first chart bar of TradingView's native exchange day. This keeps SPX/DJI/NDQ and broker-fed
// WTI/forex/CFD/commodity symbols session-aware without imposing equity clock times on them.
var float nativeCashOpen = na
var int nativeCashOpenStartTime = na

if useNativeCashOpenModel and (newExchangeDay or na(nativeCashOpen))
    nativeCashOpen := open
    nativeCashOpenStartTime := time
else if useNativeCashOpenModel
    nativeCashOpen := nz(nativeCashOpen, nativeCashOpen[1])
    nativeCashOpenStartTime := nz(nativeCashOpenStartTime, nativeCashOpenStartTime[1])

// 🔹 US Equity Premarket Open
var float premarketOpen = na
var int premarketOpenStartTime = na

if useUsIntradaySessionModel and newCalendarDate
    premarketOpen := na
    premarketOpenStartTime := na

if premarketOpenTrig
    premarketOpen := open
    premarketOpenStartTime := time
else if not (useUsIntradaySessionModel and newCalendarDate)
    premarketOpen := nz(premarketOpen, premarketOpen[1])
    premarketOpenStartTime := nz(premarketOpenStartTime, premarketOpenStartTime[1])

// 🔹 Current / Completed Equity RTH Close
// CCL is an outside-RTH equity reference only. It stays hidden throughout regular trading hours,
// then activates after the RTH daily bar is confirmed and remains available through after-hours
// and the following premarket. Futures do not use the equity CCL construct.
bool ccOutsideRthNow = useUsIntradaySessionModel and not inRTH
float rthCloseAnchor = ccOutsideRthNow ? rthDailyCloseConfirmed : na
int rthCloseAnchorTime = ccOutsideRthNow ? rthDailyCloseTime : na

bool ccBaseNow = ccOutsideRthNow and not na(rthCloseAnchor) and not na(rthCloseAnchorTime)

bool showCcLineNow = ccBaseNow and in_ccLineMode == SHOW

bool showCcLabelNow = ccBaseNow and showCcLabel

// 🔹 Equity OPEN Visibility
bool showPrevEquityOpenBaseNow =
     useUsIntradaySessionModel and
     inPremarket and
     not na(regularOpen) and
     not na(premarketOpenStartTime)

bool showCurrentEquityOpenBaseNow =
     useUsIntradaySessionModel and
     not inPremarket and
     not na(regularOpen) and
     not na(regularOpenStartTime)

// 🔹 CME Futures OPEN Visibility
bool showPrevFuturesOpenBaseNow =
     useCmeFuturesRthModel and
     not inFuturesRth and
     na(futuresRegularOpen) and
     not na(futuresPrevRegularOpen) and
     not na(futuresExchangeDayStartTime)

bool showCurrentFuturesOpenBaseNow =
     useCmeFuturesRthModel and
     not na(futuresRegularOpen) and
     not na(futuresRegularOpenStartTime)

bool showCurrentNativeCashOpenBaseNow =
     useNativeCashOpenModel and
     not na(nativeCashOpen) and
     not na(nativeCashOpenStartTime)

bool showPrevOpenBaseNow = showPrevEquityOpenBaseNow or showPrevFuturesOpenBaseNow
bool showCurrentOpenBaseNow = showCurrentEquityOpenBaseNow or showCurrentFuturesOpenBaseNow or showCurrentNativeCashOpenBaseNow

float openDisplayLevel =
     showPrevEquityOpenBaseNow ? regularOpen :
     showPrevFuturesOpenBaseNow ? futuresPrevRegularOpen :
     showCurrentEquityOpenBaseNow ? regularOpen :
     showCurrentFuturesOpenBaseNow ? futuresRegularOpen :
     showCurrentNativeCashOpenBaseNow ? nativeCashOpen :
     na

int openDisplayStartTime =
     showPrevEquityOpenBaseNow ? premarketOpenStartTime :
     showPrevFuturesOpenBaseNow ? futuresExchangeDayStartTime :
     showCurrentEquityOpenBaseNow ? regularOpenStartTime :
     showCurrentFuturesOpenBaseNow ? futuresRegularOpenStartTime :
     showCurrentNativeCashOpenBaseNow ? nativeCashOpenStartTime :
     na

string openDisplayTag =
     showPrevOpenBaseNow ?
     "POPEN" :
     "OPEN"

bool showOpenLineNow =
     showPrevOpenBaseNow ?
     showPrevOpenLine :
     showCurrentOpenBaseNow and showOpenLine

bool showOpenLabelNow =
     showPrevOpenBaseNow ?
     showPrevOpenLabel :
     showCurrentOpenBaseNow and showOpenLabel

// 🔹 PMO Visibility
bool showPmoLineNow = useUsIntradaySessionModel and showPmoLine and not na(premarketOpen) and not na(premarketOpenStartTime)
bool showPmoLabelNow = useUsIntradaySessionModel and showPmoLabel and not na(premarketOpen)

// ──────────────────────────────────────────────
// 🟦 Subregion: Target Timeframe Eligibility
// ──────────────────────────────────────────────

// 🔹 Export only when the requested candle timeframe is at or above the host chart timeframe.
// Tracking remains continuous; this gate prevents fabricated lower-TF levels on higher-TF charts.
bool canDisplay10m = isSupported and f_targetTimeframeAvailable(TF_10M)
bool canDisplay15m = isSupported and f_targetTimeframeAvailable(TF_15M)
bool canDisplay30m = isSupported and f_targetTimeframeAvailable(TF_30M)
bool canDisplay1h = isSupported and f_targetTimeframeAvailable(TF_1H)
bool canDisplay2h = isSupported and f_targetTimeframeAvailable(TF_2H)
bool canDisplay4h = isSupported and f_targetTimeframeAvailable(TF_4H)
bool canDisplay8h = isSupported and f_targetTimeframeAvailable(TF_8H)
bool canDisplay1d = isSupported and f_targetTimeframeAvailable(TF_1D)
bool canDisplay1w = isSupported and f_targetTimeframeAvailable(TF_1W)
bool canDisplay1m = isSupported and f_targetTimeframeAvailable(TF_1M)

// ──────────────────────────────────────────────
// 🟦 Subregion: LTF Previous Candle Levels
// ──────────────────────────────────────────────

bool new10m = ta.change(time(TF_10M)) != 0
int startTime10m = f_periodStartTime(new10m)
[prev10mHigh, prev10mLow, prev10mClose, prev10mHighSourceTime, prev10mLowSourceTime, prev10mCloseTime] = f_trackPrevLtf(new10m, ltfHighSource, ltfLowSource, ltfCloseSource)

bool new15m = ta.change(time(TF_15M)) != 0
int startTime15m = f_periodStartTime(new15m)
[prev15mHigh, prev15mLow, prev15mClose, prev15mHighSourceTime, prev15mLowSourceTime, prev15mCloseTime] = f_trackPrevLtf(new15m, ltfHighSource, ltfLowSource, ltfCloseSource)

bool new30m = ta.change(time(TF_30M)) != 0
int startTime30m = f_periodStartTime(new30m)
[prev30mHigh, prev30mLow, prev30mClose, prev30mHighSourceTime, prev30mLowSourceTime, prev30mCloseTime] = f_trackPrevLtf(new30m, ltfHighSource, ltfLowSource, ltfCloseSource)

bool new1h = ta.change(time(TF_1H)) != 0
int startTime1h = f_periodStartTime(new1h)
[prev1hHigh, prev1hLow, prev1hClose, prev1hHighSourceTime, prev1hLowSourceTime, prev1hCloseTime] = f_trackPrevLtf(new1h, ltfHighSource, ltfLowSource, ltfCloseSource)

bool new2h = ta.change(time(TF_2H)) != 0
int startTime2h = f_periodStartTime(new2h)
[prev2hHigh, prev2hLow, prev2hClose, prev2hHighSourceTime, prev2hLowSourceTime, prev2hCloseTime] = f_trackPrevLtf(new2h, ltfHighSource, ltfLowSource, ltfCloseSource)

bool new4h = ta.change(time(TF_4H)) != 0
int startTime4h = f_periodStartTime(new4h)
[prev4hHigh, prev4hLow, prev4hClose, prev4hHighSourceTime, prev4hLowSourceTime, prev4hCloseTime] = f_trackPrevLtf(new4h, ltfHighSource, ltfLowSource, ltfCloseSource)

bool new8h = ta.change(time(TF_8H)) != 0
int startTime8h = f_periodStartTime(new8h)
[prev8hHigh, prev8hLow, prev8hClose, prev8hHighSourceTime, prev8hLowSourceTime, prev8hCloseTime] = f_trackPrevLtf(new8h, ltfHighSource, ltfLowSource, ltfCloseSource)

// ──────────────────────────────────────────────
// 🟦 Subregion: Weekly / Monthly Active Periods
// ──────────────────────────────────────────────

bool new1w = ta.change(time(TF_1W)) != 0
int startTime1w = f_periodStartTime(new1w)

bool new1m = ta.change(time(TF_1M)) != 0
int startTime1m = f_periodStartTime(new1m)

// ──────────────────────────────────────────────
// 🟦 Subregion: Manual Weekly / Monthly Source-Candle History
// ──────────────────────────────────────────────

bool htfTrackNow = isSupported and (isNativeSessionAsset or inAnyStockSession)
float htfHighSource = ltfHighSource
float htfLowSource = ltfLowSource
float htfCloseSource = candleCloseSource
bool htfCloseValid = candleCloseSourceValid

var float weekCurHigh = na
var float weekCurLow = na
var float weekCurClose = na
var int weekCurHighTime = na
var int weekCurLowTime = na
var int weekCurCloseTime = na
var int weekCurWindowTime = na
var array<float> weekHighHistory = array.new_float()
var array<float> weekLowHistory = array.new_float()
var array<float> weekCloseHistory = array.new_float()
var array<int> weekHighTimeHistory = array.new_int()
var array<int> weekLowTimeHistory = array.new_int()
var array<int> weekCloseTimeHistory = array.new_int()
var array<int> weekWindowTimeHistory = array.new_int()

if htfTrackNow
    bool resetWeek = new1w or na(weekCurHigh) or na(weekCurLow)

    if resetWeek
        if not na(weekCurHigh) and not na(weekCurLow)
            array.unshift(weekHighHistory, weekCurHigh)
            array.unshift(weekLowHistory, weekCurLow)
            array.unshift(weekCloseHistory, weekCurClose)
            array.unshift(weekHighTimeHistory, weekCurHighTime)
            array.unshift(weekLowTimeHistory, weekCurLowTime)
            array.unshift(weekCloseTimeHistory, weekCurCloseTime)
            array.unshift(weekWindowTimeHistory, weekCurWindowTime)

            LVL.pruneHlcHistory(
                 weekHighHistory,
                 weekLowHistory,
                 weekCloseHistory,
                 weekHighTimeHistory,
                 weekLowTimeHistory,
                 weekCloseTimeHistory,
                 weekWindowTimeHistory,
                 5)

        weekCurHigh := htfHighSource
        weekCurLow := htfLowSource
        weekCurClose := htfCloseValid ? htfCloseSource : na
        weekCurHighTime := not na(htfHighSource) ? time : na
        weekCurLowTime := not na(htfLowSource) ? time : na
        weekCurCloseTime := htfCloseValid and not na(htfCloseSource) ? time : na
        weekCurWindowTime := time
    else
        if not na(htfHighSource) and (na(weekCurHigh) or htfHighSource > weekCurHigh)
            weekCurHigh := htfHighSource
            weekCurHighTime := time
        if not na(htfLowSource) and (na(weekCurLow) or htfLowSource < weekCurLow)
            weekCurLow := htfLowSource
            weekCurLowTime := time
        if htfCloseValid and not na(htfCloseSource)
            weekCurClose := htfCloseSource
            weekCurCloseTime := time

var float monthCurHigh = na
var float monthCurLow = na
var float monthCurClose = na
var int monthCurHighTime = na
var int monthCurLowTime = na
var int monthCurCloseTime = na
var int monthCurWindowTime = na
var array<float> monthHighHistory = array.new_float()
var array<float> monthLowHistory = array.new_float()
var array<float> monthCloseHistory = array.new_float()
var array<int> monthHighTimeHistory = array.new_int()
var array<int> monthLowTimeHistory = array.new_int()
var array<int> monthCloseTimeHistory = array.new_int()
var array<int> monthWindowTimeHistory = array.new_int()

if htfTrackNow
    bool resetMonth = new1m or na(monthCurHigh) or na(monthCurLow)

    if resetMonth
        if not na(monthCurHigh) and not na(monthCurLow)
            array.unshift(monthHighHistory, monthCurHigh)
            array.unshift(monthLowHistory, monthCurLow)
            array.unshift(monthCloseHistory, monthCurClose)
            array.unshift(monthHighTimeHistory, monthCurHighTime)
            array.unshift(monthLowTimeHistory, monthCurLowTime)
            array.unshift(monthCloseTimeHistory, monthCurCloseTime)
            array.unshift(monthWindowTimeHistory, monthCurWindowTime)

            LVL.pruneHlcHistory(
                 monthHighHistory,
                 monthLowHistory,
                 monthCloseHistory,
                 monthHighTimeHistory,
                 monthLowTimeHistory,
                 monthCloseTimeHistory,
                 monthWindowTimeHistory,
                 6)

        monthCurHigh := htfHighSource
        monthCurLow := htfLowSource
        monthCurClose := htfCloseValid ? htfCloseSource : na
        monthCurHighTime := not na(htfHighSource) ? time : na
        monthCurLowTime := not na(htfLowSource) ? time : na
        monthCurCloseTime := htfCloseValid and not na(htfCloseSource) ? time : na
        monthCurWindowTime := time
    else
        if not na(htfHighSource) and (na(monthCurHigh) or htfHighSource > monthCurHigh)
            monthCurHigh := htfHighSource
            monthCurHighTime := time
        if not na(htfLowSource) and (na(monthCurLow) or htfLowSource < monthCurLow)
            monthCurLow := htfLowSource
            monthCurLowTime := time
        if htfCloseValid and not na(htfCloseSource)
            monthCurClose := htfCloseSource
            monthCurCloseTime := time

// ──────────────────────────────────────────────
// 🟦 Subregion: Daily Previous Candle Levels
// ──────────────────────────────────────────────

[prev1dHighRequest, prev1dLowRequest, prev1dClose, prev1dCloseTime] = f_prevHLC(TF_1D, 1)
float prev1dHighManual = f_dailyHistFloat(isEquityLike, isNativeSessionAsset, stockFullSessionHighHistoryExt, nativeDayHighHistory, 0)
float prev1dLowManual = f_dailyHistFloat(isEquityLike, isNativeSessionAsset, stockFullSessionLowHistoryExt, nativeDayLowHistory, 0)
float prev1dHigh = f_dailyResolvedLevel(isEquityLike, isNativeSessionAsset, prev1dHighManual, prev1dHighRequest)
float prev1dLow = f_dailyResolvedLevel(isEquityLike, isNativeSessionAsset, prev1dLowManual, prev1dLowRequest)
int prev1dHighSourceTime = f_dailyHistInt(isEquityLike, isNativeSessionAsset, stockFullSessionHighTimeHistoryExt, nativeDayHighTimeHistory, 0)
int prev1dLowSourceTime = f_dailyHistInt(isEquityLike, isNativeSessionAsset, stockFullSessionLowTimeHistoryExt, nativeDayLowTimeHistory, 0)
int prev1dWindowTime = f_dailyHistInt(isEquityLike, isNativeSessionAsset, stockFullSessionStartTimeHistoryExt, nativeDayStartTimeHistory, 0)

[prev2dHighRequest, prev2dLowRequest, prev2dClose, prev2dCloseTime] = f_prevHLC(TF_1D, 2)
float prev2dHighManual = f_dailyHistFloat(isEquityLike, isNativeSessionAsset, stockFullSessionHighHistoryExt, nativeDayHighHistory, 1)
float prev2dLowManual = f_dailyHistFloat(isEquityLike, isNativeSessionAsset, stockFullSessionLowHistoryExt, nativeDayLowHistory, 1)
float prev2dHigh = f_dailyResolvedLevel(isEquityLike, isNativeSessionAsset, prev2dHighManual, prev2dHighRequest)
float prev2dLow = f_dailyResolvedLevel(isEquityLike, isNativeSessionAsset, prev2dLowManual, prev2dLowRequest)
int prev2dHighSourceTime = f_dailyHistInt(isEquityLike, isNativeSessionAsset, stockFullSessionHighTimeHistoryExt, nativeDayHighTimeHistory, 1)
int prev2dLowSourceTime = f_dailyHistInt(isEquityLike, isNativeSessionAsset, stockFullSessionLowTimeHistoryExt, nativeDayLowTimeHistory, 1)
int prev2dWindowTime = f_dailyHistInt(isEquityLike, isNativeSessionAsset, stockFullSessionStartTimeHistoryExt, nativeDayStartTimeHistory, 1)

[prev3dHighRequest, prev3dLowRequest, prev3dClose, prev3dCloseTime] = f_prevHLC(TF_1D, 3)
float prev3dHighManual = f_dailyHistFloat(isEquityLike, isNativeSessionAsset, stockFullSessionHighHistoryExt, nativeDayHighHistory, 2)
float prev3dLowManual = f_dailyHistFloat(isEquityLike, isNativeSessionAsset, stockFullSessionLowHistoryExt, nativeDayLowHistory, 2)
float prev3dHigh = f_dailyResolvedLevel(isEquityLike, isNativeSessionAsset, prev3dHighManual, prev3dHighRequest)
float prev3dLow = f_dailyResolvedLevel(isEquityLike, isNativeSessionAsset, prev3dLowManual, prev3dLowRequest)
int prev3dHighSourceTime = f_dailyHistInt(isEquityLike, isNativeSessionAsset, stockFullSessionHighTimeHistoryExt, nativeDayHighTimeHistory, 2)
int prev3dLowSourceTime = f_dailyHistInt(isEquityLike, isNativeSessionAsset, stockFullSessionLowTimeHistoryExt, nativeDayLowTimeHistory, 2)
int prev3dWindowTime = f_dailyHistInt(isEquityLike, isNativeSessionAsset, stockFullSessionStartTimeHistoryExt, nativeDayStartTimeHistory, 2)

// ──────────────────────────────────────────────
// 🟦 Subregion: Weekly Previous Candle Levels
// ──────────────────────────────────────────────

[prev1wHighRequest, prev1wLowRequest, prev1wCloseRequest, prev1wCloseTimeRequest] = f_prevHLC(TF_1W, 1)
[prev2wHighRequest, prev2wLowRequest, prev2wCloseRequest, prev2wCloseTimeRequest] = f_prevHLC(TF_1W, 2)

[prev1wWindowTimeRequest, prev2wWindowTimeRequest] =
     request.security(
         symbol=highLowSymbol,
         timeframe=TF_1W,
         expression=[time[1], time[2]],
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_on,
         calc_bars_count=5)

float prev1wHighManual = LVL.histFloat(weekHighHistory, 0)
float prev1wLowManual = LVL.histFloat(weekLowHistory, 0)
float prev1wCloseManual = LVL.histFloat(weekCloseHistory, 0)
float prev1wHigh = LVL.requestOrManual(prev1wHighRequest, prev1wHighManual)
float prev1wLow = LVL.requestOrManual(prev1wLowRequest, prev1wLowManual)
float prev1wClose = LVL.requestOrManual(prev1wCloseRequest, prev1wCloseManual)
int prev1wHighSourceTime = LVL.manualSourceTime(prev1wHighManual, weekHighTimeHistory, 0)
int prev1wLowSourceTime = LVL.manualSourceTime(prev1wLowManual, weekLowTimeHistory, 0)
int prev1wCloseSourceTime = LVL.manualSourceTime(prev1wCloseManual, weekCloseTimeHistory, 0)
int prev1wWindowTime = nz(LVL.histInt(weekWindowTimeHistory, 0), prev1wWindowTimeRequest)

float prev2wHighManual = LVL.histFloat(weekHighHistory, 1)
float prev2wLowManual = LVL.histFloat(weekLowHistory, 1)
float prev2wCloseManual = LVL.histFloat(weekCloseHistory, 1)
float prev2wHigh = LVL.requestOrManual(prev2wHighRequest, prev2wHighManual)
float prev2wLow = LVL.requestOrManual(prev2wLowRequest, prev2wLowManual)
float prev2wClose = LVL.requestOrManual(prev2wCloseRequest, prev2wCloseManual)
int prev2wHighSourceTime = LVL.manualSourceTime(prev2wHighManual, weekHighTimeHistory, 1)
int prev2wLowSourceTime = LVL.manualSourceTime(prev2wLowManual, weekLowTimeHistory, 1)
int prev2wCloseSourceTime = LVL.manualSourceTime(prev2wCloseManual, weekCloseTimeHistory, 1)
int prev2wWindowTime = nz(LVL.histInt(weekWindowTimeHistory, 1), prev2wWindowTimeRequest)

// ──────────────────────────────────────────────
// 🟦 Subregion: Monthly Previous Candle Levels
// ──────────────────────────────────────────────

[prev1mHighRequest, prev1mLowRequest, prev1mCloseRequest, prev1mCloseTimeRequest] = f_prevHLC(TF_1M, 1)
[prev2mHighRequest, prev2mLowRequest, prev2mCloseRequest, prev2mCloseTimeRequest] = f_prevHLC(TF_1M, 2)
[prev3mHighRequest, prev3mLowRequest, prev3mCloseRequest, prev3mCloseTimeRequest] = f_prevHLC(TF_1M, 3)

[prev1mWindowTimeRequest, prev2mWindowTimeRequest, prev3mWindowTimeRequest] =
     request.security(
         symbol=highLowSymbol,
         timeframe=TF_1M,
         expression=[time[1], time[2], time[3]],
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_on,
         calc_bars_count=6)

float prev1mHighManual = LVL.histFloat(monthHighHistory, 0)
float prev1mLowManual = LVL.histFloat(monthLowHistory, 0)
float prev1mCloseManual = LVL.histFloat(monthCloseHistory, 0)
float prev1mHigh = LVL.requestOrManual(prev1mHighRequest, prev1mHighManual)
float prev1mLow = LVL.requestOrManual(prev1mLowRequest, prev1mLowManual)
float prev1mClose = LVL.requestOrManual(prev1mCloseRequest, prev1mCloseManual)
int prev1mHighSourceTime = LVL.manualSourceTime(prev1mHighManual, monthHighTimeHistory, 0)
int prev1mLowSourceTime = LVL.manualSourceTime(prev1mLowManual, monthLowTimeHistory, 0)
int prev1mCloseSourceTime = LVL.manualSourceTime(prev1mCloseManual, monthCloseTimeHistory, 0)
int prev1mWindowTime = nz(LVL.histInt(monthWindowTimeHistory, 0), prev1mWindowTimeRequest)

float prev2mHighManual = LVL.histFloat(monthHighHistory, 1)
float prev2mLowManual = LVL.histFloat(monthLowHistory, 1)
float prev2mCloseManual = LVL.histFloat(monthCloseHistory, 1)
float prev2mHigh = LVL.requestOrManual(prev2mHighRequest, prev2mHighManual)
float prev2mLow = LVL.requestOrManual(prev2mLowRequest, prev2mLowManual)
float prev2mClose = LVL.requestOrManual(prev2mCloseRequest, prev2mCloseManual)
int prev2mHighSourceTime = LVL.manualSourceTime(prev2mHighManual, monthHighTimeHistory, 1)
int prev2mLowSourceTime = LVL.manualSourceTime(prev2mLowManual, monthLowTimeHistory, 1)
int prev2mCloseSourceTime = LVL.manualSourceTime(prev2mCloseManual, monthCloseTimeHistory, 1)
int prev2mWindowTime = nz(LVL.histInt(monthWindowTimeHistory, 1), prev2mWindowTimeRequest)

float prev3mHighManual = LVL.histFloat(monthHighHistory, 2)
float prev3mLowManual = LVL.histFloat(monthLowHistory, 2)
float prev3mCloseManual = LVL.histFloat(monthCloseHistory, 2)
float prev3mHigh = LVL.requestOrManual(prev3mHighRequest, prev3mHighManual)
float prev3mLow = LVL.requestOrManual(prev3mLowRequest, prev3mLowManual)
float prev3mClose = LVL.requestOrManual(prev3mCloseRequest, prev3mCloseManual)
int prev3mHighSourceTime = LVL.manualSourceTime(prev3mHighManual, monthHighTimeHistory, 2)
int prev3mLowSourceTime = LVL.manualSourceTime(prev3mLowManual, monthLowTimeHistory, 2)
int prev3mCloseSourceTime = LVL.manualSourceTime(prev3mCloseManual, monthCloseTimeHistory, 2)
int prev3mWindowTime = nz(LVL.histInt(monthWindowTimeHistory, 2), prev3mWindowTimeRequest)

// ==============================================================================================
// 🔴 END REGION: Candle Level Engine
// ==============================================================================================


// ==============================================================================================
// 🟢 REGION: Level Objects And Labels
// ==============================================================================================

// ──────────────────────────────────────────────
// 🟦 Subregion: Object State
// ──────────────────────────────────────────────

// Current/session line state
var line line_curHod = na
var line line_curLod = na
var line line_curOpen = na
var line line_cc = na
var line line_pmo = na

// Previous-candle line state
var array<line> line_10m = array.new_line(3, na)
var array<line> line_15m = array.new_line(3, na)
var array<line> line_30m = array.new_line(3, na)
var array<line> line_1h = array.new_line(3, na)
var array<line> line_2h = array.new_line(3, na)
var array<line> line_4h = array.new_line(3, na)
var array<line> line_8h = array.new_line(3, na)
var array<line> line_1d = array.new_line(3, na)
var array<line> line_2d = array.new_line(3, na)
var array<line> line_3d = array.new_line(3, na)
var array<line> line_1w = array.new_line(3, na)
var array<line> line_2w = array.new_line(3, na)
var array<line> line_1m = array.new_line(3, na)
var array<line> line_2m = array.new_line(3, na)
var array<line> line_3m = array.new_line(3, na)

// Current/session label state
var label lbl_curHod = na
var label lbl_curLod = na
var label lbl_curOpen = na
var label lbl_cc = na
var label lbl_pmo = na
var label lbl_debug = na

// Previous-candle label state
var array<label> lbl_10m = array.new_label(3, na)
var array<label> lbl_15m = array.new_label(3, na)
var array<label> lbl_30m = array.new_label(3, na)
var array<label> lbl_1h = array.new_label(3, na)
var array<label> lbl_2h = array.new_label(3, na)
var array<label> lbl_4h = array.new_label(3, na)
var array<label> lbl_8h = array.new_label(3, na)
var array<label> lbl_1d = array.new_label(3, na)
var array<label> lbl_2d = array.new_label(3, na)
var array<label> lbl_3d = array.new_label(3, na)
var array<label> lbl_1w = array.new_label(3, na)
var array<label> lbl_2w = array.new_label(3, na)
var array<label> lbl_1m = array.new_label(3, na)
var array<label> lbl_2m = array.new_label(3, na)
var array<label> lbl_3m = array.new_label(3, na)

// ──────────────────────────────────────────────
// 🟦 Subregion: Active Level Sync
// ──────────────────────────────────────────────

if barstate.islast
    int baseT2 = time
    int curT2 = baseT2
    int ltfT2 = baseT2
    int dailyT2 = baseT2

    bool showCurHLBaseNow = canDisplay1d and (isNativeSessionAsset or inAnyStockSession)
    bool showCurHLLineNow = showCurHLBaseNow and showCurHLLine
    bool showCurHLLabelNow = showCurHLBaseNow and showCurHLLabel

    // 🔹 Dynamic Label Visibility
    bool visHod = showLabels and showCurHLLabelNow and not na(curHodLevel)
    bool visLod = showLabels and showCurHLLabelNow and not na(curLodLevel)
    bool visOpen = showLabels and showOpenLabelNow and not na(openDisplayLevel)
    bool visPmo = showLabels and showPmoLabelNow and not na(premarketOpen)
    bool visCc = showLabels and showCcLabelNow and not na(rthCloseAnchor)
    bool vis10mHi = showLabels and canDisplay10m and in_showPrev10mHLLabel and not na(prev10mHigh)
    bool vis10mLo = showLabels and canDisplay10m and in_showPrev10mHLLabel and not na(prev10mLow)
    bool vis10mCl = showLabels and canDisplay10m and in_showPrev10mCLLabel and not na(prev10mClose)
    bool vis15mHi = showLabels and canDisplay15m and in_showPrev15mHLLabel and not na(prev15mHigh)
    bool vis15mLo = showLabels and canDisplay15m and in_showPrev15mHLLabel and not na(prev15mLow)
    bool vis15mCl = showLabels and canDisplay15m and in_showPrev15mCLLabel and not na(prev15mClose)
    bool vis30mHi = showLabels and canDisplay30m and in_showPrev30mHLLabel and not na(prev30mHigh)
    bool vis30mLo = showLabels and canDisplay30m and in_showPrev30mHLLabel and not na(prev30mLow)
    bool vis30mCl = showLabels and canDisplay30m and in_showPrev30mCLLabel and not na(prev30mClose)
    bool vis1hHi = showLabels and canDisplay1h and in_showPrev1hHLLabel and not na(prev1hHigh)
    bool vis1hLo = showLabels and canDisplay1h and in_showPrev1hHLLabel and not na(prev1hLow)
    bool vis1hCl = showLabels and canDisplay1h and in_showPrev1hCLLabel and not na(prev1hClose)
    bool vis2hHi = showLabels and canDisplay2h and in_showPrev2hHLLabel and not na(prev2hHigh)
    bool vis2hLo = showLabels and canDisplay2h and in_showPrev2hHLLabel and not na(prev2hLow)
    bool vis2hCl = showLabels and canDisplay2h and in_showPrev2hCLLabel and not na(prev2hClose)
    bool vis4hHi = showLabels and canDisplay4h and in_showPrev4hHLLabel and not na(prev4hHigh)
    bool vis4hLo = showLabels and canDisplay4h and in_showPrev4hHLLabel and not na(prev4hLow)
    bool vis4hCl = showLabels and canDisplay4h and in_showPrev4hCLLabel and not na(prev4hClose)
    bool vis8hHi = showLabels and canDisplay8h and in_showPrev8hHLLabel and not na(prev8hHigh)
    bool vis8hLo = showLabels and canDisplay8h and in_showPrev8hHLLabel and not na(prev8hLow)
    bool vis8hCl = showLabels and canDisplay8h and in_showPrev8hCLLabel and not na(prev8hClose)
    bool visPcl = showLabels and canDisplay1d and showPclLabel and not na(prev1dClose)
    bool visD1Hi = showLabels and canDisplay1d and in_showPrev1dHLLabel and not na(prev1dHigh)
    bool visD1Lo = showLabels and canDisplay1d and in_showPrev1dHLLabel and not na(prev1dLow)
    bool visD2Hi = showLabels and canDisplay1d and in_showPrev2dHLLabel and not na(prev2dHigh)
    bool visD2Lo = showLabels and canDisplay1d and in_showPrev2dHLLabel and not na(prev2dLow)
    bool visD2Cl = showLabels and canDisplay1d and in_showPrev2dCLLabel and not na(prev2dClose)
    bool visD3Hi = showLabels and canDisplay1d and in_showPrev3dHLLabel and not na(prev3dHigh)
    bool visD3Lo = showLabels and canDisplay1d and in_showPrev3dHLLabel and not na(prev3dLow)
    bool visD3Cl = showLabels and canDisplay1d and in_showPrev3dCLLabel and not na(prev3dClose)
    bool visW1Hi = showLabels and canDisplay1w and in_showPrev1wHLLabel and not na(prev1wHigh)
    bool visW1Lo = showLabels and canDisplay1w and in_showPrev1wHLLabel and not na(prev1wLow)
    bool visW1Cl = showLabels and canDisplay1w and in_showPrev1wCLLabel and not na(prev1wClose)
    bool visW2Hi = showLabels and canDisplay1w and in_showPrev2wHLLabel and not na(prev2wHigh)
    bool visW2Lo = showLabels and canDisplay1w and in_showPrev2wHLLabel and not na(prev2wLow)
    bool visW2Cl = showLabels and canDisplay1w and in_showPrev2wCLLabel and not na(prev2wClose)
    bool visM1Hi = showLabels and canDisplay1m and in_showPrev1mHLLabel and not na(prev1mHigh)
    bool visM1Lo = showLabels and canDisplay1m and in_showPrev1mHLLabel and not na(prev1mLow)
    bool visM1Cl = showLabels and canDisplay1m and in_showPrev1mCLLabel and not na(prev1mClose)
    bool visM2Hi = showLabels and canDisplay1m and in_showPrev2mHLLabel and not na(prev2mHigh)
    bool visM2Lo = showLabels and canDisplay1m and in_showPrev2mHLLabel and not na(prev2mLow)
    bool visM2Cl = showLabels and canDisplay1m and in_showPrev2mCLLabel and not na(prev2mClose)
    bool visM3Hi = showLabels and canDisplay1m and in_showPrev3mHLLabel and not na(prev3mHigh)
    bool visM3Lo = showLabels and canDisplay1m and in_showPrev3mHLLabel and not na(prev3mLow)
    bool visM3Cl = showLabels and canDisplay1m and in_showPrev3mCLLabel and not na(prev3mClose)

    // 🔹 Canonical Dynamic Padding Ladder
    // Grouped (default): similar labels share one horizontal pad.
    // Individual: every visible label advances separately.
    // Semantic slot identity stays fixed while labelPadOrder owns horizontal rank.
    // This keeps chronology independent of enable order without cross-wiring family padding.
    // Hidden / unavailable labels consume no spacing in either mode.
    // Stable semantic slots. These indices never move because every label call reads its own slot.
    array<bool> labelPadVisible = array.from(
         visPcl, visCc, visPmo, visOpen, visHod, visLod,
         visD1Hi, visD1Lo, visW1Hi, visW1Lo, visW1Cl, visM1Hi,
         visM1Lo, visM1Cl, vis10mHi, vis10mLo, vis10mCl, vis15mHi,
         vis15mLo, vis15mCl, vis30mHi, vis30mLo, vis30mCl, vis1hHi,
         vis1hLo, vis1hCl, vis2hHi, vis2hLo, vis2hCl, vis4hHi,
         vis4hLo, vis4hCl, vis8hHi, vis8hLo, vis8hCl, visD2Hi,
         visD2Lo, visD2Cl, visD3Hi, visD3Lo, visD3Cl, visW2Hi,
         visW2Lo, visW2Cl, visM2Hi, visM2Lo, visM2Cl, visM3Hi,
         visM3Lo, visM3Cl)

    array<int> labelPadGroups = array.from(
         0, 1, 2, 3, 4, 4, 5, 5, 6, 6, 6, 7,
         7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11,
         11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15,
         15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19,
         19, 19)

    // Canonical horizontal rank is separate from semantic slot identity:
    // anchors → intraday shortest-to-longest → Daily → Weekly → Monthly.
    array<int> labelPadOrder = array.from(
         0, 1, 2, 3, 4, 5,
         14, 15, 16, 17, 18, 19, 20, 21, 22,
         23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34,
         6, 7, 35, 36, 37, 38, 39, 40,
         8, 9, 10, 41, 42, 43,
         11, 12, 13, 44, 45, 46, 47, 48, 49)

    array<int> labelPads =
         f_buildLabelPads(
             labelPadVisible,
             labelPadGroups,
             labelPadOrder,
             useGroupedLabelPadding,
             in_labelBasePad,
             in_labelPadStep)

    line_curHod := LVL.syncBarTimeLevelLine(line_curHod, showCurHLLineNow, curHodStartTime, curT2, curHodLevel, LVL.levelColor(curHodLevel, close, curPositiveColor, curNegativeColor), in_curWidth, in_curLineStyle)
    lbl_curHod := LVL.syncTextLabel(lbl_curHod, showLabels and showCurHLLabelNow, curHodLevel, LVL.levelLabelText("HOD", curHodLevel, close, array.get(labelPads, 4), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(curHodLevel, close, curPositiveColor, curNegativeColor), in_labelSize)

    line_curLod := LVL.syncBarTimeLevelLine(line_curLod, showCurHLLineNow, curLodStartTime, curT2, curLodLevel, LVL.levelColor(curLodLevel, close, curPositiveColor, curNegativeColor), in_curWidth, in_curLineStyle)
    lbl_curLod := LVL.syncTextLabel(lbl_curLod, showLabels and showCurHLLabelNow, curLodLevel, LVL.levelLabelText("LOD", curLodLevel, close, array.get(labelPads, 5), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(curLodLevel, close, curPositiveColor, curNegativeColor), in_labelSize)

    color openColor = LVL.levelColor(openDisplayLevel, close, openPositiveColor, openNegativeColor)

    line_curOpen := LVL.syncBarTimeLevelLine(
     line_curOpen,
     showOpenLineNow,
     openDisplayStartTime,
     curT2,
     openDisplayLevel,
     openColor,
     in_openWidth,
     in_openLineStyle)

    lbl_curOpen := LVL.syncTextLabel(
     lbl_curOpen,
     showLabels and showOpenLabelNow,
     openDisplayLevel,
     LVL.levelLabelText(
          openDisplayTag,
          openDisplayLevel,
          close,
          array.get(labelPads, 3),
          in_labelShowPrice,
          in_labelShowDiff,
          in_labelShowPct,
          in_sigFig),
          LVL.levelColor(openDisplayLevel, close, openPositiveColor, openNegativeColor),
          in_labelSize)

    color pmoColor = LVL.levelColor(premarketOpen, close, pmoPositiveColor, pmoNegativeColor)
    line_pmo := LVL.syncBarTimeLevelLine(line_pmo, showPmoLineNow, premarketOpenStartTime, curT2, premarketOpen, pmoColor, in_pmoWidth, in_pmoLineStyle)
    lbl_pmo := LVL.syncTextLabel(lbl_pmo, showLabels and showPmoLabelNow, premarketOpen, LVL.levelLabelText("PMO", premarketOpen, close, array.get(labelPads, 2), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(premarketOpen, close, pmoPositiveColor, pmoNegativeColor), in_labelSize)

    color ccColor = LVL.levelColor(rthCloseAnchor, close, ccPositiveColor, ccNegativeColor)
    line_cc := LVL.syncBarTimeLevelLine(line_cc, showCcLineNow, rthCloseAnchorTime, curT2, rthCloseAnchor, ccColor, in_ccWidth, in_ccLineStyle)
    lbl_cc := LVL.syncTextLabel(lbl_cc, showLabels and showCcLabelNow, rthCloseAnchor, LVL.levelLabelText("CCL", rthCloseAnchor, close, array.get(labelPads, 1), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(rthCloseAnchor, close, ccPositiveColor, ccNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_10m, SLOT_HI, canDisplay10m and in_showPrev10mHL, LVL.sourceLineStartTime(in_ltfStartMode, prev10mHighSourceTime, startTime10m), ltfT2, prev10mHigh, LVL.levelColor(prev10mHigh, close, ltfPositiveColor, ltfNegativeColor), in_ltfWidth, in_ltfLineStyle)
    LVL.syncLabelSlot(lbl_10m, SLOT_HI, showLabels and canDisplay10m and in_showPrev10mHLLabel, prev10mHigh, f_splitLevelLabelText("P10m", "Hi", prev10mHigh, close, array.get(labelPads, 14), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev10mHigh, close, ltfPositiveColor, ltfNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_10m, SLOT_LO, canDisplay10m and in_showPrev10mHL, LVL.sourceLineStartTime(in_ltfStartMode, prev10mLowSourceTime, startTime10m), ltfT2, prev10mLow, LVL.levelColor(prev10mLow, close, ltfPositiveColor, ltfNegativeColor), in_ltfWidth, in_ltfLineStyle)
    LVL.syncLabelSlot(lbl_10m, SLOT_LO, showLabels and canDisplay10m and in_showPrev10mHLLabel, prev10mLow, f_splitLevelLabelText("P10m", "Lo", prev10mLow, close, array.get(labelPads, 15), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev10mLow, close, ltfPositiveColor, ltfNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_10m, SLOT_CL, canDisplay10m and in_showPrev10mCL, LVL.sourceLineStartTime(in_ltfStartMode, prev10mCloseTime, startTime10m), ltfT2, prev10mClose, LVL.levelColor(prev10mClose, close, ltfPositiveColor, ltfNegativeColor), in_ltfWidth, in_ltfLineStyle)
    LVL.syncLabelSlot(lbl_10m, SLOT_CL, showLabels and canDisplay10m and in_showPrev10mCLLabel, prev10mClose, f_splitLevelLabelText("P10m", "CL", prev10mClose, close, array.get(labelPads, 16), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev10mClose, close, ltfPositiveColor, ltfNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_15m, SLOT_HI, canDisplay15m and in_showPrev15mHL, LVL.sourceLineStartTime(in_ltfStartMode, prev15mHighSourceTime, startTime15m), ltfT2, prev15mHigh, LVL.levelColor(prev15mHigh, close, ltfPositiveColor, ltfNegativeColor), in_ltfWidth, in_ltfLineStyle)
    LVL.syncLabelSlot(lbl_15m, SLOT_HI, showLabels and canDisplay15m and in_showPrev15mHLLabel, prev15mHigh, f_splitLevelLabelText("P15m", "Hi", prev15mHigh, close, array.get(labelPads, 17), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev15mHigh, close, ltfPositiveColor, ltfNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_15m, SLOT_LO, canDisplay15m and in_showPrev15mHL, LVL.sourceLineStartTime(in_ltfStartMode, prev15mLowSourceTime, startTime15m), ltfT2, prev15mLow, LVL.levelColor(prev15mLow, close, ltfPositiveColor, ltfNegativeColor), in_ltfWidth, in_ltfLineStyle)
    LVL.syncLabelSlot(lbl_15m, SLOT_LO, showLabels and canDisplay15m and in_showPrev15mHLLabel, prev15mLow, f_splitLevelLabelText("P15m", "Lo", prev15mLow, close, array.get(labelPads, 18), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev15mLow, close, ltfPositiveColor, ltfNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_15m, SLOT_CL, canDisplay15m and in_showPrev15mCL, LVL.sourceLineStartTime(in_ltfStartMode, prev15mCloseTime, startTime15m), ltfT2, prev15mClose, LVL.levelColor(prev15mClose, close, ltfPositiveColor, ltfNegativeColor), in_ltfWidth, in_ltfLineStyle)
    LVL.syncLabelSlot(lbl_15m, SLOT_CL, showLabels and canDisplay15m and in_showPrev15mCLLabel, prev15mClose, f_splitLevelLabelText("P15m", "CL", prev15mClose, close, array.get(labelPads, 19), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev15mClose, close, ltfPositiveColor, ltfNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_30m, SLOT_HI, canDisplay30m and in_showPrev30mHL, LVL.sourceLineStartTime(in_ltfStartMode, prev30mHighSourceTime, startTime30m), ltfT2, prev30mHigh, LVL.levelColor(prev30mHigh, close, ltfPositiveColor, ltfNegativeColor), in_ltfWidth, in_ltfLineStyle)
    LVL.syncLabelSlot(lbl_30m, SLOT_HI, showLabels and canDisplay30m and in_showPrev30mHLLabel, prev30mHigh, f_splitLevelLabelText("P30m", "Hi", prev30mHigh, close, array.get(labelPads, 20), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev30mHigh, close, ltfPositiveColor, ltfNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_30m, SLOT_LO, canDisplay30m and in_showPrev30mHL, LVL.sourceLineStartTime(in_ltfStartMode, prev30mLowSourceTime, startTime30m), ltfT2, prev30mLow, LVL.levelColor(prev30mLow, close, ltfPositiveColor, ltfNegativeColor), in_ltfWidth, in_ltfLineStyle)
    LVL.syncLabelSlot(lbl_30m, SLOT_LO, showLabels and canDisplay30m and in_showPrev30mHLLabel, prev30mLow, f_splitLevelLabelText("P30m", "Lo", prev30mLow, close, array.get(labelPads, 21), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev30mLow, close, ltfPositiveColor, ltfNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_30m, SLOT_CL, canDisplay30m and in_showPrev30mCL, LVL.sourceLineStartTime(in_ltfStartMode, prev30mCloseTime, startTime30m), ltfT2, prev30mClose, LVL.levelColor(prev30mClose, close, ltfPositiveColor, ltfNegativeColor), in_ltfWidth, in_ltfLineStyle)
    LVL.syncLabelSlot(lbl_30m, SLOT_CL, showLabels and canDisplay30m and in_showPrev30mCLLabel, prev30mClose, f_splitLevelLabelText("P30m", "CL", prev30mClose, close, array.get(labelPads, 22), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev30mClose, close, ltfPositiveColor, ltfNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_1h, SLOT_HI, canDisplay1h and in_showPrev1hHL, LVL.sourceLineStartTime(in_ltfStartMode, prev1hHighSourceTime, startTime1h), ltfT2, prev1hHigh, LVL.levelColor(prev1hHigh, close, ltfPositiveColor, ltfNegativeColor), in_ltfWidth, in_ltfLineStyle)
    LVL.syncLabelSlot(lbl_1h, SLOT_HI, showLabels and canDisplay1h and in_showPrev1hHLLabel, prev1hHigh, f_splitLevelLabelText("P1h", "Hi", prev1hHigh, close, array.get(labelPads, 23), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev1hHigh, close, ltfPositiveColor, ltfNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_1h, SLOT_LO, canDisplay1h and in_showPrev1hHL, LVL.sourceLineStartTime(in_ltfStartMode, prev1hLowSourceTime, startTime1h), ltfT2, prev1hLow, LVL.levelColor(prev1hLow, close, ltfPositiveColor, ltfNegativeColor), in_ltfWidth, in_ltfLineStyle)
    LVL.syncLabelSlot(lbl_1h, SLOT_LO, showLabels and canDisplay1h and in_showPrev1hHLLabel, prev1hLow, f_splitLevelLabelText("P1h", "Lo", prev1hLow, close, array.get(labelPads, 24), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev1hLow, close, ltfPositiveColor, ltfNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_1h, SLOT_CL, canDisplay1h and in_showPrev1hCL, LVL.sourceLineStartTime(in_ltfStartMode, prev1hCloseTime, startTime1h), ltfT2, prev1hClose, LVL.levelColor(prev1hClose, close, ltfPositiveColor, ltfNegativeColor), in_ltfWidth, in_ltfLineStyle)
    LVL.syncLabelSlot(lbl_1h, SLOT_CL, showLabels and canDisplay1h and in_showPrev1hCLLabel, prev1hClose, f_splitLevelLabelText("P1h", "CL", prev1hClose, close, array.get(labelPads, 25), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev1hClose, close, ltfPositiveColor, ltfNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_2h, SLOT_HI, canDisplay2h and in_showPrev2hHL, LVL.sourceLineStartTime(in_ltfStartMode, prev2hHighSourceTime, startTime2h), ltfT2, prev2hHigh, LVL.levelColor(prev2hHigh, close, ltfPositiveColor, ltfNegativeColor), in_ltfWidth, in_ltfLineStyle)
    LVL.syncLabelSlot(lbl_2h, SLOT_HI, showLabels and canDisplay2h and in_showPrev2hHLLabel, prev2hHigh, f_splitLevelLabelText("P2h", "Hi", prev2hHigh, close, array.get(labelPads, 26), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev2hHigh, close, ltfPositiveColor, ltfNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_2h, SLOT_LO, canDisplay2h and in_showPrev2hHL, LVL.sourceLineStartTime(in_ltfStartMode, prev2hLowSourceTime, startTime2h), ltfT2, prev2hLow, LVL.levelColor(prev2hLow, close, ltfPositiveColor, ltfNegativeColor), in_ltfWidth, in_ltfLineStyle)
    LVL.syncLabelSlot(lbl_2h, SLOT_LO, showLabels and canDisplay2h and in_showPrev2hHLLabel, prev2hLow, f_splitLevelLabelText("P2h", "Lo", prev2hLow, close, array.get(labelPads, 27), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev2hLow, close, ltfPositiveColor, ltfNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_2h, SLOT_CL, canDisplay2h and in_showPrev2hCL, LVL.sourceLineStartTime(in_ltfStartMode, prev2hCloseTime, startTime2h), ltfT2, prev2hClose, LVL.levelColor(prev2hClose, close, ltfPositiveColor, ltfNegativeColor), in_ltfWidth, in_ltfLineStyle)
    LVL.syncLabelSlot(lbl_2h, SLOT_CL, showLabels and canDisplay2h and in_showPrev2hCLLabel, prev2hClose, f_splitLevelLabelText("P2h", "CL", prev2hClose, close, array.get(labelPads, 28), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev2hClose, close, ltfPositiveColor, ltfNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_4h, SLOT_HI, canDisplay4h and in_showPrev4hHL, LVL.sourceLineStartTime(in_ltfStartMode, prev4hHighSourceTime, startTime4h), ltfT2, prev4hHigh, LVL.levelColor(prev4hHigh, close, ltfPositiveColor, ltfNegativeColor), in_ltfWidth, in_ltfLineStyle)
    LVL.syncLabelSlot(lbl_4h, SLOT_HI, showLabels and canDisplay4h and in_showPrev4hHLLabel, prev4hHigh, f_splitLevelLabelText("P4h", "Hi", prev4hHigh, close, array.get(labelPads, 29), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev4hHigh, close, ltfPositiveColor, ltfNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_4h, SLOT_LO, canDisplay4h and in_showPrev4hHL, LVL.sourceLineStartTime(in_ltfStartMode, prev4hLowSourceTime, startTime4h), ltfT2, prev4hLow, LVL.levelColor(prev4hLow, close, ltfPositiveColor, ltfNegativeColor), in_ltfWidth, in_ltfLineStyle)
    LVL.syncLabelSlot(lbl_4h, SLOT_LO, showLabels and canDisplay4h and in_showPrev4hHLLabel, prev4hLow, f_splitLevelLabelText("P4h", "Lo", prev4hLow, close, array.get(labelPads, 30), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev4hLow, close, ltfPositiveColor, ltfNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_4h, SLOT_CL, canDisplay4h and in_showPrev4hCL, LVL.sourceLineStartTime(in_ltfStartMode, prev4hCloseTime, startTime4h), ltfT2, prev4hClose, LVL.levelColor(prev4hClose, close, ltfPositiveColor, ltfNegativeColor), in_ltfWidth, in_ltfLineStyle)
    LVL.syncLabelSlot(lbl_4h, SLOT_CL, showLabels and canDisplay4h and in_showPrev4hCLLabel, prev4hClose, f_splitLevelLabelText("P4h", "CL", prev4hClose, close, array.get(labelPads, 31), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev4hClose, close, ltfPositiveColor, ltfNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_8h, SLOT_HI, canDisplay8h and in_showPrev8hHL, LVL.sourceLineStartTime(in_ltfStartMode, prev8hHighSourceTime, startTime8h), ltfT2, prev8hHigh, LVL.levelColor(prev8hHigh, close, ltfPositiveColor, ltfNegativeColor), in_ltfWidth, in_ltfLineStyle)
    LVL.syncLabelSlot(lbl_8h, SLOT_HI, showLabels and canDisplay8h and in_showPrev8hHLLabel, prev8hHigh, f_splitLevelLabelText("P8h", "Hi", prev8hHigh, close, array.get(labelPads, 32), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev8hHigh, close, ltfPositiveColor, ltfNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_8h, SLOT_LO, canDisplay8h and in_showPrev8hHL, LVL.sourceLineStartTime(in_ltfStartMode, prev8hLowSourceTime, startTime8h), ltfT2, prev8hLow, LVL.levelColor(prev8hLow, close, ltfPositiveColor, ltfNegativeColor), in_ltfWidth, in_ltfLineStyle)
    LVL.syncLabelSlot(lbl_8h, SLOT_LO, showLabels and canDisplay8h and in_showPrev8hHLLabel, prev8hLow, f_splitLevelLabelText("P8h", "Lo", prev8hLow, close, array.get(labelPads, 33), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev8hLow, close, ltfPositiveColor, ltfNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_8h, SLOT_CL, canDisplay8h and in_showPrev8hCL, LVL.sourceLineStartTime(in_ltfStartMode, prev8hCloseTime, startTime8h), ltfT2, prev8hClose, LVL.levelColor(prev8hClose, close, ltfPositiveColor, ltfNegativeColor), in_ltfWidth, in_ltfLineStyle)
    LVL.syncLabelSlot(lbl_8h, SLOT_CL, showLabels and canDisplay8h and in_showPrev8hCLLabel, prev8hClose, f_splitLevelLabelText("P8h", "CL", prev8hClose, close, array.get(labelPads, 34), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev8hClose, close, ltfPositiveColor, ltfNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_1d, SLOT_HI, canDisplay1d and in_showPrev1dHL, LVL.windowSourceLineStartTime(in_dailyStartMode, prev1dWindowTime, prev1dHighSourceTime, startTimed1), dailyT2, prev1dHigh, LVL.levelColor(prev1dHigh, close, dailyPositiveColor, dailyNegativeColor), in_dailyWidth, in_dailyLineStyle)
    LVL.syncLabelSlot(lbl_1d, SLOT_HI, showLabels and canDisplay1d and in_showPrev1dHLLabel, prev1dHigh, f_splitLevelLabelText("P1D", "Hi", prev1dHigh, close, array.get(labelPads, 6), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev1dHigh, close, dailyPositiveColor, dailyNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_1d, SLOT_LO, canDisplay1d and in_showPrev1dHL, LVL.windowSourceLineStartTime(in_dailyStartMode, prev1dWindowTime, prev1dLowSourceTime, startTimed1), dailyT2, prev1dLow, LVL.levelColor(prev1dLow, close, dailyPositiveColor, dailyNegativeColor), in_dailyWidth, in_dailyLineStyle)
    LVL.syncLabelSlot(lbl_1d, SLOT_LO, showLabels and canDisplay1d and in_showPrev1dHLLabel, prev1dLow, f_splitLevelLabelText("P1D", "Lo", prev1dLow, close, array.get(labelPads, 7), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev1dLow, close, dailyPositiveColor, dailyNegativeColor), in_labelSize) 
    
    bool showPclBaseNow = canDisplay1d and not na(prev1dClose)
    bool showPclLineNow = showPclBaseNow and showPclLine
    bool showPclLabelNow = showPclBaseNow and showPclLabel
    color pclColor = LVL.levelColor(prev1dClose, close, pclPositiveColor, pclNegativeColor)

    LVL.syncLineSlot(line_1d, SLOT_CL, showPclLineNow, LVL.sourceLineStartTime(in_pclStartMode, prev1dCloseTime, startTimed1), dailyT2, prev1dClose, pclColor, in_pclWidth, in_pclLineStyle)
    LVL.syncLabelSlot(lbl_1d, SLOT_CL, showLabels and showPclLabelNow, prev1dClose, LVL.levelLabelText("PCL", prev1dClose, close, array.get(labelPads, 0), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev1dClose, close, pclPositiveColor, pclNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_2d, SLOT_HI, canDisplay1d and in_showPrev2dHL, LVL.windowSourceLineStartTime(in_dailyStartMode, prev2dWindowTime, prev2dHighSourceTime, startTimed1), dailyT2, prev2dHigh, LVL.levelColor(prev2dHigh, close, dailyPositiveColor, dailyNegativeColor), in_dailyWidth, in_dailyLineStyle)
    LVL.syncLabelSlot(lbl_2d, SLOT_HI, showLabels and canDisplay1d and in_showPrev2dHLLabel, prev2dHigh, f_splitLevelLabelText("P2D", "Hi", prev2dHigh, close, array.get(labelPads, 35), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev2dHigh, close, dailyPositiveColor, dailyNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_2d, SLOT_LO, canDisplay1d and in_showPrev2dHL, LVL.windowSourceLineStartTime(in_dailyStartMode, prev2dWindowTime, prev2dLowSourceTime, startTimed1), dailyT2, prev2dLow, LVL.levelColor(prev2dLow, close, dailyPositiveColor, dailyNegativeColor), in_dailyWidth, in_dailyLineStyle)
    LVL.syncLabelSlot(lbl_2d, SLOT_LO, showLabels and canDisplay1d and in_showPrev2dHLLabel, prev2dLow, f_splitLevelLabelText("P2D", "Lo", prev2dLow, close, array.get(labelPads, 36), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev2dLow, close, dailyPositiveColor, dailyNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_2d, SLOT_CL, canDisplay1d and in_showPrev2dCL, LVL.windowSourceLineStartTime(in_dailyStartMode, prev2dWindowTime, prev2dCloseTime, startTimed1), dailyT2, prev2dClose, LVL.levelColor(prev2dClose, close, dailyPositiveColor, dailyNegativeColor), in_dailyWidth, in_dailyLineStyle)
    LVL.syncLabelSlot(lbl_2d, SLOT_CL, showLabels and canDisplay1d and in_showPrev2dCLLabel, prev2dClose, f_splitLevelLabelText("P2D", "CL", prev2dClose, close, array.get(labelPads, 37), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev2dClose, close, dailyPositiveColor, dailyNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_3d, SLOT_HI, canDisplay1d and in_showPrev3dHL, LVL.windowSourceLineStartTime(in_dailyStartMode, prev3dWindowTime, prev3dHighSourceTime, startTimed1), dailyT2, prev3dHigh, LVL.levelColor(prev3dHigh, close, dailyPositiveColor, dailyNegativeColor), in_dailyWidth, in_dailyLineStyle)
    LVL.syncLabelSlot(lbl_3d, SLOT_HI, showLabels and canDisplay1d and in_showPrev3dHLLabel, prev3dHigh, f_splitLevelLabelText("P3D", "Hi", prev3dHigh, close, array.get(labelPads, 38), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev3dHigh, close, dailyPositiveColor, dailyNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_3d, SLOT_LO, canDisplay1d and in_showPrev3dHL, LVL.windowSourceLineStartTime(in_dailyStartMode, prev3dWindowTime, prev3dLowSourceTime, startTimed1), dailyT2, prev3dLow, LVL.levelColor(prev3dLow, close, dailyPositiveColor, dailyNegativeColor), in_dailyWidth, in_dailyLineStyle)
    LVL.syncLabelSlot(lbl_3d, SLOT_LO, showLabels and canDisplay1d and in_showPrev3dHLLabel, prev3dLow, f_splitLevelLabelText("P3D", "Lo", prev3dLow, close, array.get(labelPads, 39), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev3dLow, close, dailyPositiveColor, dailyNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_3d, SLOT_CL, canDisplay1d and in_showPrev3dCL, LVL.windowSourceLineStartTime(in_dailyStartMode, prev3dWindowTime, prev3dCloseTime, startTimed1), dailyT2, prev3dClose, LVL.levelColor(prev3dClose, close, dailyPositiveColor, dailyNegativeColor), in_dailyWidth, in_dailyLineStyle)
    LVL.syncLabelSlot(lbl_3d, SLOT_CL, showLabels and canDisplay1d and in_showPrev3dCLLabel, prev3dClose, f_splitLevelLabelText("P3D", "CL", prev3dClose, close, array.get(labelPads, 40), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev3dClose, close, dailyPositiveColor, dailyNegativeColor), in_labelSize)

    int weeklyT2 = baseT2
    int monthlyT2 = baseT2

    LVL.syncLineSlot(line_1w, SLOT_HI, canDisplay1w and in_showPrev1wHL, LVL.windowSourceLineStartTime(in_weeklyStartMode, prev1wWindowTime, prev1wHighSourceTime, startTime1w), weeklyT2, prev1wHigh, LVL.levelColor(prev1wHigh, close, weeklyPositiveColor, weeklyNegativeColor), in_weeklyWidth, in_weeklyLineStyle)
    LVL.syncLabelSlot(lbl_1w, SLOT_HI, showLabels and canDisplay1w and in_showPrev1wHLLabel, prev1wHigh, f_splitLevelLabelText("P1W", "Hi", prev1wHigh, close, array.get(labelPads, 8), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev1wHigh, close, weeklyPositiveColor, weeklyNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_1w, SLOT_LO, canDisplay1w and in_showPrev1wHL, LVL.windowSourceLineStartTime(in_weeklyStartMode, prev1wWindowTime, prev1wLowSourceTime, startTime1w), weeklyT2, prev1wLow, LVL.levelColor(prev1wLow, close, weeklyPositiveColor, weeklyNegativeColor), in_weeklyWidth, in_weeklyLineStyle)
    LVL.syncLabelSlot(lbl_1w, SLOT_LO, showLabels and canDisplay1w and in_showPrev1wHLLabel, prev1wLow, f_splitLevelLabelText("P1W", "Lo", prev1wLow, close, array.get(labelPads, 9), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev1wLow, close, weeklyPositiveColor, weeklyNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_1w, SLOT_CL, canDisplay1w and in_showPrev1wCL, LVL.windowSourceLineStartTime(in_weeklyStartMode, prev1wWindowTime, prev1wCloseSourceTime, startTime1w), weeklyT2, prev1wClose, LVL.levelColor(prev1wClose, close, weeklyPositiveColor, weeklyNegativeColor), in_weeklyWidth, in_weeklyLineStyle)
    LVL.syncLabelSlot(lbl_1w, SLOT_CL, showLabels and canDisplay1w and in_showPrev1wCLLabel, prev1wClose, f_splitLevelLabelText("P1W", "CL", prev1wClose, close, array.get(labelPads, 10), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev1wClose, close, weeklyPositiveColor, weeklyNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_2w, SLOT_HI, canDisplay1w and in_showPrev2wHL, LVL.windowSourceLineStartTime(in_weeklyStartMode, prev2wWindowTime, prev2wHighSourceTime, startTime1w), weeklyT2, prev2wHigh, LVL.levelColor(prev2wHigh, close, weeklyPositiveColor, weeklyNegativeColor), in_weeklyWidth, in_weeklyLineStyle)
    LVL.syncLabelSlot(lbl_2w, SLOT_HI, showLabels and canDisplay1w and in_showPrev2wHLLabel, prev2wHigh, f_splitLevelLabelText("P2W", "Hi", prev2wHigh, close, array.get(labelPads, 41), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev2wHigh, close, weeklyPositiveColor, weeklyNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_2w, SLOT_LO, canDisplay1w and in_showPrev2wHL, LVL.windowSourceLineStartTime(in_weeklyStartMode, prev2wWindowTime, prev2wLowSourceTime, startTime1w), weeklyT2, prev2wLow, LVL.levelColor(prev2wLow, close, weeklyPositiveColor, weeklyNegativeColor), in_weeklyWidth, in_weeklyLineStyle)
    LVL.syncLabelSlot(lbl_2w, SLOT_LO, showLabels and canDisplay1w and in_showPrev2wHLLabel, prev2wLow, f_splitLevelLabelText("P2W", "Lo", prev2wLow, close, array.get(labelPads, 42), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev2wLow, close, weeklyPositiveColor, weeklyNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_2w, SLOT_CL, canDisplay1w and in_showPrev2wCL, LVL.windowSourceLineStartTime(in_weeklyStartMode, prev2wWindowTime, prev2wCloseSourceTime, startTime1w), weeklyT2, prev2wClose, LVL.levelColor(prev2wClose, close, weeklyPositiveColor, weeklyNegativeColor), in_weeklyWidth, in_weeklyLineStyle)
    LVL.syncLabelSlot(lbl_2w, SLOT_CL, showLabels and canDisplay1w and in_showPrev2wCLLabel, prev2wClose, f_splitLevelLabelText("P2W", "CL", prev2wClose, close, array.get(labelPads, 43), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev2wClose, close, weeklyPositiveColor, weeklyNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_1m, SLOT_HI, canDisplay1m and in_showPrev1mHL, LVL.windowSourceLineStartTime(in_monthlyStartMode, prev1mWindowTime, prev1mHighSourceTime, startTime1m), monthlyT2, prev1mHigh, LVL.levelColor(prev1mHigh, close, monthlyPositiveColor, monthlyNegativeColor), in_monthlyWidth, in_monthlyLineStyle)
    LVL.syncLabelSlot(lbl_1m, SLOT_HI, showLabels and canDisplay1m and in_showPrev1mHLLabel, prev1mHigh, f_splitLevelLabelText("P1M", "Hi", prev1mHigh, close, array.get(labelPads, 11), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev1mHigh, close, monthlyPositiveColor, monthlyNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_1m, SLOT_LO, canDisplay1m and in_showPrev1mHL, LVL.windowSourceLineStartTime(in_monthlyStartMode, prev1mWindowTime, prev1mLowSourceTime, startTime1m), monthlyT2, prev1mLow, LVL.levelColor(prev1mLow, close, monthlyPositiveColor, monthlyNegativeColor), in_monthlyWidth, in_monthlyLineStyle)
    LVL.syncLabelSlot(lbl_1m, SLOT_LO, showLabels and canDisplay1m and in_showPrev1mHLLabel, prev1mLow, f_splitLevelLabelText("P1M", "Lo", prev1mLow, close, array.get(labelPads, 12), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev1mLow, close, monthlyPositiveColor, monthlyNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_1m, SLOT_CL, canDisplay1m and in_showPrev1mCL, LVL.windowSourceLineStartTime(in_monthlyStartMode, prev1mWindowTime, prev1mCloseSourceTime, startTime1m), monthlyT2, prev1mClose, LVL.levelColor(prev1mClose, close, monthlyPositiveColor, monthlyNegativeColor), in_monthlyWidth, in_monthlyLineStyle)
    LVL.syncLabelSlot(lbl_1m, SLOT_CL, showLabels and canDisplay1m and in_showPrev1mCLLabel, prev1mClose, f_splitLevelLabelText("P1M", "CL", prev1mClose, close, array.get(labelPads, 13), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev1mClose, close, monthlyPositiveColor, monthlyNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_2m, SLOT_HI, canDisplay1m and in_showPrev2mHL, LVL.windowSourceLineStartTime(in_monthlyStartMode, prev2mWindowTime, prev2mHighSourceTime, startTime1m), monthlyT2, prev2mHigh, LVL.levelColor(prev2mHigh, close, monthlyPositiveColor, monthlyNegativeColor), in_monthlyWidth, in_monthlyLineStyle)
    LVL.syncLabelSlot(lbl_2m, SLOT_HI, showLabels and canDisplay1m and in_showPrev2mHLLabel, prev2mHigh, f_splitLevelLabelText("P2M", "Hi", prev2mHigh, close, array.get(labelPads, 44), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev2mHigh, close, monthlyPositiveColor, monthlyNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_2m, SLOT_LO, canDisplay1m and in_showPrev2mHL, LVL.windowSourceLineStartTime(in_monthlyStartMode, prev2mWindowTime, prev2mLowSourceTime, startTime1m), monthlyT2, prev2mLow, LVL.levelColor(prev2mLow, close, monthlyPositiveColor, monthlyNegativeColor), in_monthlyWidth, in_monthlyLineStyle)
    LVL.syncLabelSlot(lbl_2m, SLOT_LO, showLabels and canDisplay1m and in_showPrev2mHLLabel, prev2mLow, f_splitLevelLabelText("P2M", "Lo", prev2mLow, close, array.get(labelPads, 45), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev2mLow, close, monthlyPositiveColor, monthlyNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_2m, SLOT_CL, canDisplay1m and in_showPrev2mCL, LVL.windowSourceLineStartTime(in_monthlyStartMode, prev2mWindowTime, prev2mCloseSourceTime, startTime1m), monthlyT2, prev2mClose, LVL.levelColor(prev2mClose, close, monthlyPositiveColor, monthlyNegativeColor), in_monthlyWidth, in_monthlyLineStyle)
    LVL.syncLabelSlot(lbl_2m, SLOT_CL, showLabels and canDisplay1m and in_showPrev2mCLLabel, prev2mClose, f_splitLevelLabelText("P2M", "CL", prev2mClose, close, array.get(labelPads, 46), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev2mClose, close, monthlyPositiveColor, monthlyNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_3m, SLOT_HI, canDisplay1m and in_showPrev3mHL, LVL.windowSourceLineStartTime(in_monthlyStartMode, prev3mWindowTime, prev3mHighSourceTime, startTime1m), monthlyT2, prev3mHigh, LVL.levelColor(prev3mHigh, close, monthlyPositiveColor, monthlyNegativeColor), in_monthlyWidth, in_monthlyLineStyle)
    LVL.syncLabelSlot(lbl_3m, SLOT_HI, showLabels and canDisplay1m and in_showPrev3mHLLabel, prev3mHigh, f_splitLevelLabelText("P3M", "Hi", prev3mHigh, close, array.get(labelPads, 47), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev3mHigh, close, monthlyPositiveColor, monthlyNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_3m, SLOT_LO, canDisplay1m and in_showPrev3mHL, LVL.windowSourceLineStartTime(in_monthlyStartMode, prev3mWindowTime, prev3mLowSourceTime, startTime1m), monthlyT2, prev3mLow, LVL.levelColor(prev3mLow, close, monthlyPositiveColor, monthlyNegativeColor), in_monthlyWidth, in_monthlyLineStyle)
    LVL.syncLabelSlot(lbl_3m, SLOT_LO, showLabels and canDisplay1m and in_showPrev3mHLLabel, prev3mLow, f_splitLevelLabelText("P3M", "Lo", prev3mLow, close, array.get(labelPads, 48), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev3mLow, close, monthlyPositiveColor, monthlyNegativeColor), in_labelSize)

    LVL.syncLineSlot(line_3m, SLOT_CL, canDisplay1m and in_showPrev3mCL, LVL.windowSourceLineStartTime(in_monthlyStartMode, prev3mWindowTime, prev3mCloseSourceTime, startTime1m), monthlyT2, prev3mClose, LVL.levelColor(prev3mClose, close, monthlyPositiveColor, monthlyNegativeColor), in_monthlyWidth, in_monthlyLineStyle)
    LVL.syncLabelSlot(lbl_3m, SLOT_CL, showLabels and canDisplay1m and in_showPrev3mCLLabel, prev3mClose, f_splitLevelLabelText("P3M", "CL", prev3mClose, close, array.get(labelPads, 49), in_labelShowPrice, in_labelShowDiff, in_labelShowPct, in_sigFig), LVL.levelColor(prev3mClose, close, monthlyPositiveColor, monthlyNegativeColor), in_labelSize)

    string debugText = "type=" + assetTypeStr + "\n" + "session=" + sessionTypeStr
    lbl_debug := LVL.syncTextLabel(lbl_debug, showDebugLabel, high, debugText, color.white, "Small")

// ==============================================================================================
// 🔴 END REGION: Level Objects And Labels
// ==============================================================================================
````

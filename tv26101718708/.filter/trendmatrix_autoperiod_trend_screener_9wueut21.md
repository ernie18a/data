# TrendMatrix Auto-Period Trend Screener

- url: https://www.tradingview.com/script/9WueUt21-TrendMatrix-Auto-Period-Trend-Screener/
- type: indicator
- pine_id: PUB;40c0644aa0d94d078b8925ccfc8414bc
- version: 6.0

## Description

TrendMatrix Auto-Period Trend Screener - Trend Smart. 

Most traditional screeners force you to view the market through a rigid, fixed lens—asking questions like, "What are the best performers over the last 90 days?" The problem is that stocks do not all move on the same 90-day cycle. Forcing a fixed lookback period onto every ticker guarantees you will miss the true underlying trend for many of them.

The "TrendMatrix Auto-Period Trend Screener" solves this by dynamically adapting to the unique rhythm of every single stock. Instead of you telling the indicator what timeframe to look at, the indicator tells you which timeframe mathematically fits the stock best.

1. Per-Ticker Auto-Period Selection

You no longer have to guess the correct lookback window. For every ticker in your custom universe, the engine runs a regression analysis across multiple candidate periods (ranging from 1 month to 4 years). It calculates the Pearson R correlation of the log(close) against time.

The engine automatically locks onto the period with the strongest log-linear trend. This means the screener might evaluate Nvidia based on a 189-day cycle, while simultaneously measuring a gold miner on a 63-day cycle—because those are the windows where their respective trends are mathematically the cleanest.

2. TAR & Sharpe: The Ultimate Filtering Pair

Once the engine finds a stock's optimal trend period, it computes two vital metrics to help you rank them:

TAR (Trend Annualised Return): This is the Compound Annual Growth Rate (CAGR) computed strictly over the stock's auto-selected best window. It standardizes growth rates so you can directly compare a stock on a 3-month cycle against one on a 1-year cycle.

The Sharpe Ratio: Growth means nothing if the path to get there is violently volatile. The Sharpe ratio measures risk-adjusted return over that same best-fit period. By default, the screener ranks your list by Sharpe, surfacing the best combination of trend strength and trend quality (smoothness) directly to the top.

3. The Dual Stop System

Managing risk requires context. This screener replaces arbitrary stop-losses with a dynamic, dual-column system directly in your dashboard:

Stop (Trend) — Peak-Anchored: This stop adapts to each name's actual cycle. It anchors to the highest close within the stock's unique best-fit window. Short, aggressive cycles get tight stops; long, established cycles get deeper stops.

Stop (Event) — Entry-Anchored: This answers the question: "If I had entered this stock at the start of my recent target window, where would my stop be now?" It is anchored purely to the price at the start of your defined post-event window.

By tracking both, you always know exactly how much structural buffer remains in the macro trend, and how much risk remains on a recent tactical entry.

---

Additional Core Features

Four Thematic Universe Slots: The screener allows you to actively switch between 4 different ticker lists (e.g., AI Infrastructure, Gold Miners, Bioscience, Energy). You can use the curated defaults, build your own custom lists, or merge both together. Because custom tickers are stored in your script settings, updating the indicator never wipes your hard work.

Adaptive Regression Channel: The chart overlay features a regression channel that defaults to a long-term view, but automatically snaps to a short-term view if the price structurally breaks below the long-term lower bound.

Contextual Zig-Zag: A built-in, percentage-based zig-zag helps you instantly gauge the normal "swing scale" of a stock, ensuring you don't get shaken out by a routine 10% pullback on a highly volatile ticker.

Actionable Alerts: Built-in alerts fire immediately when any ticker breaches—or recovers—either its Trend Stop or its Event Stop.

How to Use It

1. Select your Universe: Choose one of the 4 slots and define your tickers.
2. Calibrate your Filters: Set your minimum R values to remove choppy, trendless noise.
3. Read the Dashboard: Look for names at the top with a high Sharpe ratio (smooth trend), a strong TAR (high growth), and a green Action column (price is safely above its adaptive stop).

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TrendMatrix_Labs
//
// CREDITS — auto-period Pearson's R selection
// The core method — scanning candidate lookback periods and selecting the one
// whose log-linear regression has the strongest |Pearson's R| — is derived from:
//   "Linear Regression - Auto Adjust To Ideal Pearson's R (Min & Max)" by @x11joe
// Carrying x11joe's own attribution chain:
//   @midtownsk8rguy — original regression channel source parts
//   @RicardoSantos  — info-panel drawing approach
// This script ports that method to Pine v6, vectorises the period scan, and builds
// a multi-ticker screener, TAR/Sharpe ranking, themed universe slots, and a regime
// overlay on top. Published open-source under MPL-2.0 per the reuse terms.

//@version=6
indicator('TrendMatrix Auto-Period Trend Screener', shorttitle="TrendSmart", overlay = true, max_bars_back = 2000, max_lines_count = 500, max_labels_count = 500)

// ══════════════════════════════════════════════════════════════════
// 01 │ COLOUR SYSTEM   (shared by the screener and the regime overlay)
// ══════════════════════════════════════════════════════════════════
color C_SIG    = #6366F1                       // indigo signature (Stripe/Linear/Discord band)
color C_UP     = #34D399                       // emerald-400 (Up — general signal cells)
color C_DN     = #FB7185                       // rose-400 (Down — general signal cells)
color C_UP_BOLD = #4ADE80                      // green-400 (Up — action columns, top of hierarchy)
color C_DN_BOLD = #F87171                      // red-400 (Down — action columns, top of hierarchy)
color C_TXT    = #E6EDF3                       // warm white text
color C_DIM    = color.rgb(136, 145, 158)                       // cool gray (dim text)
color C_ACT    = #22D3EE                       // cyan-400 (numeric accents — brighter)
color C_BG     = color.new(#0D1117, 0)         // deep cool dark base
color C_HD     = color.new(#161B22, 0)         // raised header surface
color C_RA     = color.new(#0D1117, 0)         // row alt A (matches bg)
color C_RB     = color.new(#161B22, 0)         // row alt B (subtle stripe)
string MONO = font.family_monospace

// ══════════════════════════════════════════════════════════════════
// 02 │ UNIVERSE & BENCHMARK (4 SLOTS)
// ══════════════════════════════════════════════════════════════════
string GRP_U  = "Universe"
string i_slot = input.string("Slot 1", "Active Slot",
     options = ["Slot 1", "Slot 2", "Slot 3", "Slot 4"], group = GRP_U,
     tooltip = "Select which thematic universe to screen.\n\n" +
               "Each of the four slots has a curated default ticker list, a custom text area for your own tickers, and a Mode selector that controls how they combine:\n\n" +
               "  • Default — use the slot's hardcoded thematic list as-is\n" +
               "  • Custom — replace the default entirely with your own tickers\n" +
               "  • Merge — append your custom tickers to the default, duplicates removed\n\n" +
               "The active slot's label appears in the screener header.\n\n" +
               "Key benefit: custom tickers are stored per-slot in your script settings, so re-installing or updating the indicator never wipes your lists.")

// ── Hardcoded thematic defaults ───────────────────────────────
// Curated starting points per theme. Review periodically — tickers
// can be acquired (HES, MRO, PXD recently), delisted, or renamed.
// Users can override per slot via Custom or Merge mode.
string DEF_U1 = "NVDA, AVGO, AMD, MU, AMAT, KLAC, LRCX, TXN, ADI, MRVL, ON, MCHP, INTC, QCOM, ASML, TSM, SMCI, ANET, DELL, VRT, ARM"
string DEF_U2 = "NEM, GOLD, AEM, FNV, WPM, KGC, AU, GFI, AGI, PAAS, EGO, IAG, BTG, NGD, EQX, OR, RGLD, SAND, HMY, BVN"
string DEF_U3 = "LLY, NVO, JNJ, ABBV, MRK, PFE, BMY, GILD, AMGN, REGN, BIIB, VRTX, MRNA, ALNY, INCY, AZN, NVS, SNY, GSK, NBIX"
string DEF_U4 = "XOM, CVX, COP, EOG, OXY, MPC, PSX, VLO, SLB, BKR, HAL, FANG, DVN, APA, OVV, KMI, ET, EPD, BP, SHEL, TTE, ENB"

// ── Slot 1 — AI Infrastructure ────────────────────────────────
string GRP_U1     = "Universe — Slot 1 (AI Infrastructure)"
string i_u1_label = input.string("AI Infrastructure", "Label", group = GRP_U1, inline = 'u1',
     tooltip = "Display name for this slot. Shown in the screener header when this slot is active.")
string i_u1_mode  = input.string("Default", "Mode", inline = 'u1',
     options = ["Default", "Custom", "Merge"], group = GRP_U1,
     tooltip = "Default = use the hardcoded thematic list as-is.\nCustom = use only your custom tickers below.\nMerge = combine both (custom appended to default, duplicates removed).")
string i_u1_cstm  = input.text_area("", "Custom Tickers", group = GRP_U1,
     tooltip = "Your own ticker list for this slot. Used when Mode is Custom, or merged with the default in Merge mode. Comma-separated. Max 39 total tickers per slot.")
string i_u1_bench = input.symbol("SMH", "Benchmark", group = GRP_U1)

// ── Slot 2 — Gold Miners ──────────────────────────────────────
string GRP_U2     = "Universe — Slot 2 (Gold Miners)"
string i_u2_label = input.string("Gold Miners", "Label", group = GRP_U2, inline = 'u2')
string i_u2_mode  = input.string("Default", "Mode", inline = 'u2',
     options = ["Default", "Custom", "Merge"], group = GRP_U2)
string i_u2_cstm  = input.text_area("", "Custom Tickers", group = GRP_U2)
string i_u2_bench = input.symbol("GDX", "Benchmark", group = GRP_U2)

// ── Slot 3 — Bioscience ───────────────────────────────────────
string GRP_U3     = "Universe — Slot 3 (Bioscience)"
string i_u3_label = input.string("Bioscience", "Label", group = GRP_U3, inline = 'u3')
string i_u3_mode  = input.string("Default", "Mode", inline = 'u3',
     options = ["Default", "Custom", "Merge"], group = GRP_U3)
string i_u3_cstm  = input.text_area("", "Custom Tickers", group = GRP_U3)
string i_u3_bench = input.symbol("IBB", "Benchmark", group = GRP_U3)

// ── Slot 4 — Energy ───────────────────────────────────────────
string GRP_U4     = "Universe — Slot 4 (Energy)"
string i_u4_label = input.string("Energy", "Label", group = GRP_U4, inline = 'u4')
string i_u4_mode  = input.string("Default", "Mode", inline = 'u4',
     options = ["Default", "Custom", "Merge"], group = GRP_U4)
string i_u4_cstm  = input.text_area("", "Custom Tickers", group = GRP_U4)
string i_u4_bench = input.symbol("XLE", "Benchmark", group = GRP_U4)

// ── Resolve per-slot ticker list by Mode ──────────────────────
string i_u1_tkr = switch i_u1_mode
    "Default" => DEF_U1
    "Custom"  => i_u1_cstm
    "Merge"   => DEF_U1 + ", " + i_u1_cstm
    => DEF_U1

string i_u2_tkr = switch i_u2_mode
    "Default" => DEF_U2
    "Custom"  => i_u2_cstm
    "Merge"   => DEF_U2 + ", " + i_u2_cstm
    => DEF_U2

string i_u3_tkr = switch i_u3_mode
    "Default" => DEF_U3
    "Custom"  => i_u3_cstm
    "Merge"   => DEF_U3 + ", " + i_u3_cstm
    => DEF_U3

string i_u4_tkr = switch i_u4_mode
    "Default" => DEF_U4
    "Custom"  => i_u4_cstm
    "Merge"   => DEF_U4 + ", " + i_u4_cstm
    => DEF_U4

// ── Resolve active slot ───────────────────────────────────────
string i_tickers = switch i_slot
    "Slot 1" => i_u1_tkr
    "Slot 2" => i_u2_tkr
    "Slot 3" => i_u3_tkr
    "Slot 4" => i_u4_tkr
    => i_u1_tkr

string i_benchmark = switch i_slot
    "Slot 1" => i_u1_bench
    "Slot 2" => i_u2_bench
    "Slot 3" => i_u3_bench
    "Slot 4" => i_u4_bench
    => i_u1_bench

string i_slot_label = switch i_slot
    "Slot 1" => i_u1_label
    "Slot 2" => i_u2_label
    "Slot 3" => i_u3_label
    "Slot 4" => i_u4_label
    => i_u1_label

// ══════════════════════════════════════════════════════════════════
// 03 │ ENGINE
// ══════════════════════════════════════════════════════════════════
string GRP_E     = "Engine"
bool i_lt        = input.bool(false, "Long-Term Mode (TAR)",
     group   = GRP_E,
     tooltip = "Short-term mode: auto-selects best period from {21, 42, 63, 126, 189, 252} daily bars (≈1M to 1Y).\n" +
               "Long-term mode:  auto-selects from {252, 378, 504, 630, 756, 1008} daily bars (≈1Y to 4Y).\n\n" +
               "For each candidate period, the engine computes Pearson R of log(close) vs time over that window. " +
               "The period with the highest |R| (strongest log-linear trend) is selected as the 'best period' per ticker. " +
               "CAGR is then computed over that window — this is the Trend Annualised Return (TAR).\n\n" +
               "Independent from the regression channel's LT toggle below.")
int i_persist_n = input.int(21, "Persistence horizon (bars)", group = "Engine", minval = 5, maxval = 126,
     tooltip = "The follow-through test. For each bar in this ticker's history where it was in a strong-trend state (Post-R ≥ 0.7 AND above its trend stop), the engine checks whether it was STILL above that stop this many bars later.\n\n" +
               "The result (shown in the Symbol tooltip) is the % of past strong-trend moments that held. It is the audit of Pearson's R: R tells you the trend is clean NOW; persistence tells you whether 'clean now' has historically meant 'still trending later' for this name.\n\n" +
               "It is the name's own historical tendency — NOT a forecast, and NOT the table's hit rate. A high figure means this name has followed through before; it can still break tomorrow. A low sample count reads 'thin' — too few past strong-trend moments to trust.\n\n" +
               "21 ≈ 1 month · 42 ≈ 2 months. Shorter horizons have more samples.")
int i_event_bars = input.int(42, "Post-Event / Recent Window (bars)",
     group   = GRP_E, minval = 3, maxval = 252,
     tooltip = "Number of trading bars used for the recent-window analysis.\n\n" +
               "Three values are computed over this window:\n" +
               "  • Post-event Pearson R (default sort key)\n" +
               "  • Post-event % change (used for Relative Strength)\n" +
               "  • Average daily volume in millions (used for liquidity filter)\n\n" +
               "Anchor this to a catalyst, or just use it as a recent-window length. " +
               "Common values: 21 (1M), 42 (2M), 63 (1Q), 126 (6M).")

// ══════════════════════════════════════════════════════════════════
// 04 │ FILTERS
// ══════════════════════════════════════════════════════════════════
string GRP_F   = "Filters"
float i_min_r   = input.float(0.4, "Min Post-Event R", group = GRP_F, minval = 0.0, maxval = 1.0, step = 0.05, inline = 'f1')
float i_min_pct = input.float(0.0, "Min Post-Event % Chg", group = GRP_F, minval = 0.0, step = 1.0, inline = 'f1',
     tooltip = "Left — Min Post-Event R:\n" +
               "Hide tickers whose absolute post-event Pearson R is below this threshold. Set to 0 to disable.\n\n" +
               "Default 0.40 removes sub-Weak noise without emptying typical universes. Suggested values:\n" +
               "  • 0.40 — remove pure noise (default)\n" +
               "  • 0.50 — moderate or stronger trend quality\n" +
               "  • 0.70 — strong trends only\n" +
               "  • 0.85 — very strong trends only\n\n" +
               "──────────\n\n" +
               "Right — Min Post-Event % Chg:\n" +
               "Hide tickers whose absolute post-event % change is below this threshold (in percent). Set to 0 to disable.\n\n" +
               "Useful for filtering out tickers that haven't moved meaningfully over the recent window.")
bool i_show_all = input.bool(false, "Show all names (mark filtered instead of hiding)", group = GRP_F,
     tooltip = "Off = only names passing all three filters appear (default).\n\n" +
               "On = EVERY name appears, in rank order. Names that failed a filter are DIMMED and tagged in the Symbol tooltip with the reason (low R / low %chg / low ADV). Nothing is hidden — you see the whole universe and why each marginal name is marginal.\n\n" +
               "Use this when a name you're watching has vanished from the table and you want to know whether it's filtered, dead, or just weak — rather than silently absent.")
float i_min_adv = input.float(0.0, "Min ADV (M shares)", group = GRP_F, minval = 0.0, step = 0.1,
     tooltip = "Hide tickers whose average daily volume (over the post-event window) is below this threshold, in millions of shares. Set to 0 to disable.\n\n" +
               "Protects against screening into illiquid names you can't actually trade in size.")

// ══════════════════════════════════════════════════════════════════
// 04a │ ACTION COLUMNS
// ══════════════════════════════════════════════════════════════════
string GRP_A       = "Action Columns"
float i_rev_stop   = input.float(20.0, "Trend Stop %", group = GRP_A, minval = 1.0, maxval = 50.0, step = 1.0, inline = 'a1')
float i_event_stop = input.float(10.0, "Event Stop %", group = GRP_A, minval = 1.0, maxval = 50.0, step = 1.0, inline = 'a1',
     tooltip = "Left — Trend Stop %:\n" +
               "Defines the trend-reversal stop level shown in the Stop (Trend) column.\n\n" +
               "Stop level = highest close within each ticker's auto-selected best period × (1 − this %).\n\n" +
               "Cell shows signed % distance from current price to stop:\n" +
               "  Positive (green) = price above stop\n" +
               "  Negative (red)   = price below stop\n\n" +
               "Anchoring to the trend's high-water mark over its own best-fit window means the stop adapts to each name's actual cycle — short cycles get tight, recent peaks; long cycles get fixed, deeper stops. 20% is a common threshold for trend-reversal exits.\n\n" +
               "──────────\n\n" +
               "Right — Event Stop %:\n" +
               "Defines the position stop level shown in the Stop (Event) column.\n\n" +
               "Stop level = price at the start of the post-event window × (1 − this %).\n\n" +
               "Mental model: 'If I had entered at the start of the post-event window, where would my stop be now?'\n\n" +
               "Set Post-Event Bars in the Engine group to match your actual entry date. Default 10% is tighter than the trend-reversal default 20% since entry-anchored stops sit closer to a specific reference point.")

// ══════════════════════════════════════════════════════════════════
// 04b │ ALERTS
// ══════════════════════════════════════════════════════════════════
string GRP_AL = "Alerts"
bool i_alert_trend_exit  = input.bool(true,  "Alert on Trend Breach",   group = GRP_AL, inline = 'al1')
bool i_alert_trend_entry = input.bool(false, "Alert on Trend Recovery", group = GRP_AL, inline = 'al1',
     tooltip = "Left — Alert on Trend Breach:\n" +
               "Fires when any ticker transitions from above to below the trend stop level (Stop (Trend) column flips negative) — price falls below the peak-anchored reversal stop.\n" +
               "Message: 'Trend Breach: <SYMBOL> · -X.X% past stop'\n\n" +
               "──────────\n\n" +
               "Right — Alert on Trend Recovery:\n" +
               "Fires when any ticker transitions from below to above the trend stop level (Stop (Trend) column flips positive) — price recovers above the peak-anchored stop.\n" +
               "Message: 'Trend Recovery: <SYMBOL> · +X.X% above stop'")
bool i_alert_event_exit  = input.bool(true,  "Alert on Event Breach",   group = GRP_AL, inline = 'al2')
bool i_alert_event_entry = input.bool(false, "Alert on Event Recovery", group = GRP_AL, inline = 'al2',
     tooltip = "Left — Alert on Event Breach:\n" +
               "Fires when any ticker transitions from above to below the event stop level (Stop (Event) column flips negative) — price falls below the entry-anchored position stop.\n" +
               "Message: 'Event Breach: <SYMBOL> · -X.X% past stop'\n\n" +
               "──────────\n\n" +
               "Right — Alert on Event Recovery:\n" +
               "Fires when any ticker transitions from below to above the event stop level (Stop (Event) column flips positive) — price recovers above the entry-anchored stop.\n" +
               "Message: 'Event Recovery: <SYMBOL> · +X.X% above stop'")

// ══════════════════════════════════════════════════════════════════
// 05 │ SCREENER DISPLAY
// ══════════════════════════════════════════════════════════════════
string GRP_D = "Screener Display"
string i_sort_key = input.string("Sharpe", "Sort By",
    options = ["Post-Event R", "Full Period R", "Sharpe", "Post-Event % Change", "Relative Strength"],
     group   = GRP_D, inline = 'd1')

string i_srt = input.string("Descending", "Sort Order",
     options = ["Descending", "Ascending"], group = GRP_D, inline = 'd1',
     tooltip = "Left — Sort By:\n" +
               "Column used to rank tickers. Each option answers a different question:\n\n" +
               "  • Post-Event R — 'What's trending most cleanly right now?' Best for finding active, well-structured recent trends.\n" +
               "  • Full Period R — 'What's been trending consistently over the full best-fit period?' Best for finding established, durable trends.\n" +
               "  • TAR (CAGR) — 'What's growing fastest in annualised terms?' Best for comparing growth rates across different best-fit periods.\n" +
               "  • Sharpe (default) — 'What's compounding most cleanly — smooth trends rather than steep ones?' The single most informative metric. Captures both magnitude and quality in one number.\n" +
               "  • Post-Event % Change — 'What's up the most recently?' Best for momentum / catalyst follow-through.\n" +
               "  • Relative Strength — 'What's outperforming the benchmark?' Best for finding sector leaders.\n\n" +
               "Default Sharpe surfaces the best combination of trend strength and trend quality at the top.\n\n" +
               "──────────\n\n" +
               "Right — Sort Order:\n" +
               "Descending puts the most extreme value at the top — strongest trends, highest TAR, biggest gainers. Best for active scanning when you're looking for what to trade.\n\n" +
               "Ascending inverts the order, which sounds backwards but has three real uses:\n" +
               "  • Finding the weakest names (mean-reversion candidates, short ideas, names to remove from a watchlist).\n" +
               "  • Verifying your portfolio's worst positions are still defensible.\n" +
               "  • Reading the full distribution from the bottom up when you're calibrating filters.")

string i_pos = input.string("Top Right", "Table Position", inline = 'd2',
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GRP_D)

string i_tz  = input.string("Europe/London", "Timezone", inline = 'd2',
     options = ["America/New_York", "Europe/London", "Europe/Istanbul", "Africa/Cairo", "Asia/Dubai", "Asia/Karachi", "Asia/Kolkata", "Asia/Dhaka", "Asia/Tashkent", "Asia/Tokyo", "UTC"], group = GRP_D,
     tooltip = "Timezone for the screener header timestamp. IST (Asia/Kolkata), TRT (Europe/Istanbul), Gulf (Asia/Dubai), PKT (Asia/Karachi), Dhaka, and Tashkent sit alongside the original four.")

bool i_compact = input.bool(false, "Compact Mode", group = GRP_D,
     tooltip = "Collapse the four secondary columns (Best Per., Period %, RS vs benchmark, ADV) for smaller screens.\n\n" +
               "Visible in compact: #, Symbol, TAR, Sharpe, Full R | Post R, Chg, Price, Stop (Trend), Stop (Event) — the columns needed for actual decisions.\n\n" +
               "Hidden columns collapse to slivers rather than disappear (Pine table column-count is fixed at creation), so the table narrows substantially but a thin gap remains where each hidden column was.")

// ══════════════════════════════════════════════════════════════════
// 06 │ PEARSON'S R CHANNEL (active chart)
// ══════════════════════════════════════════════════════════════════
string GRP_RC  = "Pearson's R Channel"
sourceInput    = input.source(close, 'Source', group = GRP_RC, inline = 'rc1')
max_bars_back(sourceInput, 2000)

string rcMode  = input.string("Adaptive", "Channel Mode", group = GRP_RC, inline = 'rc1',
     options = ["Long-Term", "Short-Term", "Adaptive"],
     tooltip = "Left — Source:\n" +
               "Price source for the regression channel computation on the active chart symbol. Close is standard.\n\n" +
               "──────────\n\n" +
               "Right — Channel Mode:\n" +
               "Long-Term: auto-selects best fit from {300...1200} bars (50-bar increments).\n" +
               "Short-Term: auto-selects best fit from {20...200} bars (10-bar increments).\n" +
               "Adaptive (default): starts in Long-Term, switches to Short-Term when current close falls below the LT channel's lower bound by the threshold set below. Switches back automatically when price recovers above the threshold.\n\n" +
               "Adaptive addresses the failure mode where a long-term regression keeps projecting a clean trend after price has actually broken the regime. LT/ST are manual overrides for users who want to lock the view.\n\n" +
               "Independent from the Engine LT toggle, which governs the screener TAR computation.")

float rcDropPct = input.float(0.0, "Adaptive: % Below LT Lower", group = GRP_RC, inline = 'rc2',
     minval = 0.0, maxval = 50.0, step = 0.5)

float devMult  = input.float(2.0, 'Deviation X', group = GRP_RC, inline = 'rc2', step = 0.1,
     tooltip = "Left — Adaptive: % Below LT Lower:\n" +
               "Only active in Adaptive mode. Switches channel from LT to ST when current close falls more than this percentage below the LT lower bound.\n\n" +
               "0.0     = any close below LT lower triggers the switch.\n" +
               "2.0–5.0 = requires a more decisive break (reduces whipsaw).\n\n" +
               "The channel itself already defines 'normal' via the Deviation Multiplier — this input is a buffer on top of the channel's own boundary.\n\n" +
               "──────────\n\n" +
               "Right — Deviation X:\n" +
               "Width of the channel in standard deviations of log-price residuals. 2.0 captures approximately 95% of historical price action under normality.")

color rcCol    = input.color(#06B6D4,   '',               group = GRP_RC, inline = 'rc3')
string rcStyle = input.string('Dotted',  '',               group = GRP_RC, inline = 'rc3',
     options = ['Solid', 'Dotted', 'Dashed'])
string rcExt   = input.string('Extend None','',          group = GRP_RC, inline = 'rc3',
     options = ['Extend Right', 'Extend Both', 'Extend None', 'Extend Left'])
int chWidth    = input.int(1,  'Line Width', group = GRP_RC, inline = 'rc3', minval = 1, maxval = 5,
     tooltip = "Leftmost — Color: line colour for the upper/lower channel boundaries.\n\n" +
               "──────────\n\n" +
               "Centre-Left — Style: line style (Solid, Dotted, Dashed).\n\n" +
               "──────────\n\n" +
               "Centre-Right — Extend: whether the channel lines project right, left, both, or stop at the regression window's edge.\n\n" +
               "──────────\n\n" +
               "Right — Line Width: width of the upper/lower channel boundary lines (1–5). The midline has its own Width input in the Midline group below.")

int fillTrans  = input.int(100, 'Fill Trans', group = GRP_RC, inline = 'rct', minval = 0, maxval = 100)
int chanTrans  = input.int(0,  'Line Trans', group = GRP_RC, inline = 'rct', minval = 0, maxval = 100,
     tooltip = "Left — Fill Trans: transparency of the channel fill (0 = opaque, 100 = invisible). Default 90 keeps the fill subtle.\n\n" +
               "──────────\n\n" +
               "Right — Line Trans: transparency of the upper/lower boundary lines (0 = opaque, 100 = invisible).")

string GRP_ML  = "Midline"
color midCol   = input.color(#E6EDF3,'',    group = GRP_ML, inline = GRP_ML)
int   midTrans = input.int(0, 'Trans',      group = GRP_ML, inline = GRP_ML, minval = 0, maxval = 100)
int   midWidth = input.int(1, 'Width',      group = GRP_ML, inline = GRP_ML)
string midSt   = input.string('Solid','',   group = GRP_ML, inline = GRP_ML,
     options = ['Dotted', 'Solid', 'Dashed'],
     tooltip = "Leftmost — Color: midline colour.\n\n" +
               "──────────\n\n" +
               "Centre-Left — Trans: transparency of the midline.\n\n" +
               "──────────\n\n" +
               "Centre-Right — Width: line thickness (1–5).\n\n" +
               "──────────\n\n" +
               "Right — Style: line style (Solid, Dotted, Dashed).")

// ══════════════════════════════════════════════════════════════════
// 07a │ CHART TREND STOP LINE
// ══════════════════════════════════════════════════════════════════
string GRP_TSL       = "Chart Trend Stop Line"
bool   showTrendStop = input.bool(true, 'Show Trend Stop', group = GRP_TSL, inline = 'tsl1',
     tooltip = "Plot a horizontal line on the chart at the active chart symbol's Trend Stop level. Reconciles the chart visually with the screener's Stop (Trend) column — current price above the line = positive % buffer; below = negative.\n\n" +
               "Stop level = highest close in the chart symbol's auto-selected best period × (1 − Trend Stop %).\n\n" +
               "Note: this is anchored to the TAR engine's best period (chosen from 6 candidates), which is independent of the regression channel's best period (chosen from 19 candidates). They can differ — the label shows which period the stop is anchored to.\n\n" +
               "Daily / weekly timeframes only.")
color  trendStopCol   = input.color(#6366F1, '', group = GRP_TSL, inline = 'tsl1')
string trendStopStyle = input.string('Dashed', '', group = GRP_TSL, inline = 'tsl1',
     options = ['Solid', 'Dashed', 'Dotted'])

// ══════════════════════════════════════════════════════════════════
// 07b │ CHART ZIG ZAG
// ══════════════════════════════════════════════════════════════════
string GRP_ZZ   = "Chart Zig Zag"
bool   showZZ   = input.bool(true, 'Show Zig Zag', group = GRP_ZZ, inline = 'zz1')
bool   zzLabels = input.bool(true, 'Show % Labels', group = GRP_ZZ, inline = 'zz1')
color  zzUpCol  = input.color(#34d399a4, 'Up', group = GRP_ZZ, inline = 'zz1')
color  zzDnCol  = input.color(#fb7186a6, 'Dn', group = GRP_ZZ, inline = 'zz1',
     tooltip = "Leftmost — Show Zig Zag:\n" +
               "Plot a percentage-based zig zag on the chart, connecting significant pivots and labelling each leg with its % change.\n\n" +
               "Useful for contextualising the magnitude of recent swings — high-volatility names show large legs, low-volatility names smaller legs. Helps you read the current pullback against the name's normal swing scale (e.g. a −18% pullback is routine for a name whose typical legs are ±30%).\n\n" +
               "Daily / weekly timeframes only.\n\n" +
               "──────────\n\n" +
               "Centre-Left — Show % Labels:\n" +
               "Label each daily/weekly zig zag leg with its percentage change.\n\n" +
               "──────────\n\n" +
               "Centre-Right / Right — Up / Dn colours:\n" +
               "Line and label background colours for the up legs (Up) and down legs (Dn).")

int    zzLblTrans = input.int(35, 'Label Bg Trans', group = GRP_ZZ, minval = 0, maxval = 100, inline = 'zz2')
float  zzPct    = input.float(10.0, 'Min % Move', group = GRP_ZZ, minval = 1.0, step = 0.5, inline = 'zz2',
     tooltip = "Left — Label Bg Trans:\n" +
               "Transparency of the % label background (0 = opaque pill, 100 = invisible). Useful if labels feel too dominant on busy charts.\n\n" +
               "──────────\n\n" +
               "Right — Min % Move:\n" +
               "Minimum percentage move required to register a new zig zag leg. Higher values filter out smaller swings — calibrate to the name's typical volatility:\n\n" +
               "  • 3–5%   — Low-volatility large caps (UNH, JNJ, COST, KO). Standard swings are small; 10% would skip most of the action.\n" +
               "  • 8–12%  — Default range. Works for most liquid equities (AAPL, MSFT, AVGO).\n" +
               "  • 15–20% — High-volatility momentum names (TSLA, NVDA in trend, small caps). Filters down to structurally meaningful swings.\n" +
               "  • 25%+   — Long-term context view: only the biggest cycles. Useful as a 'major regime' overlay rather than tactical context.\n\n" +
               "Diagnostic: if you see more than 20 legs on a 1-year daily chart, the threshold is too low. Fewer than 5 and it's too high.")

int    zzLB     = input.int(5, 'Left Bars',  group = GRP_ZZ, inline = 'zzbars', minval = 1, maxval = 50)
int    zzRB     = input.int(5, 'Right Bars', group = GRP_ZZ, inline = 'zzbars', minval = 1, maxval = 50,
     tooltip = "Pivot detection lookback (applies to both Left Bars and Right Bars). A high/low qualifies as a pivot if it is the highest/lowest within this many bars on each side. Higher values = more confirmation, more lag.")

// ── Intraday Zig Zag Settings (Secondary Engine) ──────────────
string GRP_IZZ     = "Chart Zig Zag (Intraday)"
bool   showIZZ     = input.bool(true, 'Show Intraday ZZ', group = GRP_IZZ, inline = 'izz1')
bool   izzLabels   = input.bool(true, 'Show % Labels', group = GRP_IZZ, inline = 'izz1')
float  izzAtrMult  = input.float(2.5, 'ATR Multiplier', group = GRP_IZZ, minval = 0.5, step = 0.5, inline = 'izz1',
     tooltip = "Leftmost — Show Intraday ZZ:\n" +
               "Plot the ATR-based zig zag on intraday timeframes. Independent of the daily/weekly zig zag — the two never draw on the same chart.\n\n" +
               "──────────\n\n" +
               "Centre — Show % Labels:\n" +
               "Label each intraday leg with its percentage change.\n\n" +
               "──────────\n\n" +
               "Right — ATR Multiplier:\n" +
               "Uses a dynamic ATR multiplier instead of a fixed percentage for intraday resolutions. Adapts automatically to the timeframe.")
color  izzUpCol    = input.color(color.new(#34D399, 40), 'Up', group = GRP_IZZ, inline = 'izz2')
color  izzDnCol    = input.color(color.new(#FB7185, 40), 'Dn', group = GRP_IZZ, inline = 'izz2')
int    izzLblTrans = input.int(40, 'Label Bg Trans', group = GRP_IZZ, minval = 0, maxval = 100, inline = 'izz2')
int    izzLB       = input.int(3, 'Left Bars',  group = GRP_IZZ, inline = 'izzbars', minval = 1, maxval = 50)
int    izzRB       = input.int(3, 'Right Bars', group = GRP_IZZ, inline = 'izzbars', minval = 1, maxval = 50)

// ══════════════════════════════════════════════════════════════════
// 07c │ EVENT START MARKER
// ══════════════════════════════════════════════════════════════════
string GRP_EM     = "Event Start Marker"
bool   showEvt    = input.bool(true, 'Event Start.', group = GRP_EM, inline = 'em1')
color  evtBgCol   = input.color(color.new(#6366F1, 80), 'Bar Highlight', group = GRP_EM, inline = 'em1')
bool   showEvtLbl = input.bool(true, 'Label.', group = GRP_EM, inline = 'em1')
color  evtLblCol  = input.color(color.new(#6366F1, 20), 'Label color', group = GRP_EM, inline = 'em1',
     tooltip = "Leftmost — Event Start.\n" +
               "Highlight the bar at the start of the post-event / recent window on the chart. Anchors the recent-window analysis visually so you can see exactly which bars are included in Chg, Post-Event R, and the Event Stop entry calculation.\n\n" +
               "The marker sits at bar_index − Post-Event Bars and moves with each new bar so it always reflects the current rolling window.\n\n" +
               "Daily / weekly timeframes only.\n\n" +
               "──────────\n\n" +
               "Centre-Left — Bar Highlight:\n" +
               "Background colour painted on the event start bar.\n\n" +
               "──────────\n\n" +
               "Centre-Right — Label.\n" +
               "Toggle the 'Event Start (Nd)' label that sits below the highlighted bar.\n\n" +
               "──────────\n\n" +
               "Right — Label color:\n" +
               "Colour of the Event Start label background.")

// ══════════════════════════════════════════════════════════════════
// 07d │ REGIME OVERLAY ENGINE — INPUTS
//       Institutional momentum / volatility-regime bands, modular
//       execution signals, auto-Fibonacci, and the Top-Center HUD.
// ══════════════════════════════════════════════════════════════════

// 1. Institutional Momentum & Regime Core Engines
lookback    = input.int(20, title = 'Trend Anchor Lookback', group = 'Regime Overlay: Chart/HUD — Core Engines', tooltip = 'These settings affect the chart overlay and the Regime half of the HUD only — they do not change the screener table.\n\nDetermines the baseline sample size for structural price ranges.\n\nUsage Ranges:\n• 10-20: Fast reaction (Day Trading/Scalping)\n• 50-100: Macro liquidity pools (Swing Trading)')
z_len       = input.int(50, title = 'Extension Z-Score Period', group = 'Regime Overlay: Chart/HUD — Core Engines', tooltip = 'Calculates statistical deviations from the mean to identify overextended price.\n\nUsage Ranges:\n• 20: Hyper-sensitive (lots of signals)\n• 50: Standard institutional balance\n• 100: Slow, focused on macro extremes')

// 2. MTF Regime Engine
regime_tf   = input.timeframe('D', title = 'Macro Regime Timeframe', group = 'Regime Overlay: Chart/HUD — MTF Engine', tooltip = 'Anchors the lower timeframe to a higher timeframe’s macro weather pattern.\n\nUsage Ranges:\n• "D" (Daily): Standard context for intraday charts (1m-1H).\n• "W" (Weekly): Standard context for swing charts (4H-1D).')
vol_len     = input.int(200, title = 'Volatility Regime Period', group = 'Regime Overlay: Chart/HUD — MTF Engine', tooltip = 'The sample size for the macro volatility baseline.\n\nUsage Ranges:\n• 100: Faster baseline (better for highly volatile crypto)\n• 200-252: Traditional 1-year equity baseline')

// 3. Multipliers & Asymmetry
base_mu     = input.float(2.0, title = 'Base Upper Multiplier', group = 'Regime Overlay: Chart/HUD — Multipliers & Asymmetry', tooltip = 'The foundational width of the volatility bands.\n\nUsage Ranges:\n• 1.5: Tight bands, frequent touches\n• 2.0: Standard (captures ~95% of normal price action)\n• 3.0: Extreme boundary (rare touches)')
base_ml     = input.float(2.0, title = 'Base Lower Multiplier', group = 'Regime Overlay: Chart/HUD — Multipliers & Asymmetry')
scale_up    = input.float(0.4, title = 'Upper Logistic Compression', group = 'Regime Overlay: Chart/HUD — Multipliers & Asymmetry', tooltip = 'Limits how wide the bands expand during extreme momentum, forcing price to break out.\n\nUsage Ranges:\n• 0.1-0.2: Minimal compression (bands curve with price)\n• 0.4: Standard curve\n• 0.8: Heavy compression (forces early invalidation)')
scale_down  = input.float(0.4, title = 'Lower Logistic Compression', group = 'Regime Overlay: Chart/HUD — Multipliers & Asymmetry')

// 4. Execution & Smoothing
exec_mode   = input.string('Fast Centerline Break', title = 'Signal Trigger Method', options = ['Conservative (Original)', 'Fast Centerline Break', 'Band Reversal (Anticipatory)'], group = 'Regime Overlay: Chart/HUD — Execution & Smoothing', tooltip = 'Defines your execution philosophy.\n• Conservative: Waits for trend slope confirmation (safer, slower).\n• Fast Break: Reacts to momentum shifts instantly.\n• Anticipatory: Plays mean-reversion at mathematical extremes.')
smooth      = input.bool(false, title = 'Smooth Price Source', group = 'Regime Overlay: Chart/HUD — Execution & Smoothing', tooltip = 'Filters out raw price noise (wicks) so the engine reacts to the "true" trend rather than momentary stop-hunts.\n\nOutcomes:\n• Checked: Cleaner signals and fewer fakeouts, but introduces entry lag.\n• Unchecked: Highly responsive, but vulnerable to intraday chop.')
len_smooth  = input.int(10,   title = 'Smooth Period', group = 'Regime Overlay: Chart/HUD — Execution & Smoothing', tooltip = 'The mathematical period used to smooth the price line.\n\nUsage Ranges:\n• 1-5: Minimal lag, tracks very close to real candles (Scalping).\n• 10-20: Standard institutional noise filtering (Day Trading).\n• 50+: Heavy macro smoothing. Trades major structural swings only (Swing Trading).')
strict_exec = input.bool(true,  title = 'Require Bar Close', group = 'Regime Overlay: Chart/HUD — Execution & Smoothing', tooltip = 'Institutions wait for the close to confirm intent. Intra-bar wicks trap retail.\n\nUsage:\n• Checked: Safe, confirmed signals (1 bar lag).\n• Unchecked: Instant reactions (Warning: high risk of intra-bar fakeouts).')

// 5. Auto Fibonacci Settings
show_fib    = input.bool(false, title = 'Enable Auto Fibonacci Levels', group = 'Regime Overlay: Chart/HUD — Auto Fibonacci')
fib_len = input.int(100, title = 'Fibonacci Lookback Length', minval = 5, group = 'Regime Overlay: Chart/HUD — Auto Fibonacci',
     tooltip="Determines the number of historical chart bars used to find the highest high and lowest low.\n\n" +
             "• Short-Term (Scalping/Day Trading): 5-20 bars.\n" +
             "  Best for 1m to 15m charts. Tracks micro-pivots; changes frequently.\n\n" +
             "• Medium-Term (Swing Trading): 50-100 bars (Default: 100).\n" +
             "  Best for 1h, 4h, or Daily charts. Filters out daily noise for broader trends.\n\n" +
             "• Long-Term (Position Trading): 150-300+ bars.\n" +
             "  Best for Daily, Weekly, or Monthly charts. Identifies macro market cycles.")

// 6. HUD Dashboard
hud_title   = input.string('Symbol X-Ray', title='HUD Title', group = 'Regime Overlay: Chart/HUD — HUD Dashboard',
     tooltip = "Header shown at the top of the HUD. Rename to taste (e.g. 'TRENDMATRIX', 'SYMBOL VITALS', 'ACTIVE READ').")
i_hud_gap   = input.int(0, title='HUD Top Gap (rows)', minval=0, maxval=6, group = 'Regime Overlay: Chart/HUD — HUD Dashboard',
     tooltip = "Blank rows above the HUD title to clear TradingView's chart legend / indicator titles. Increase if the table is obscured at the top-left.")
table_pos   = input.string('Top Center', title='HUD Dashboard Position', options=['Top Left', 'Top Center', 'Top Right', 'Bottom Left', 'Bottom Center', 'Bottom Right'], group = 'Regime Overlay: Chart/HUD — HUD Dashboard',
     tooltip = "Position of the regime HUD dashboard. Defaults to Top Center; the screener occupies Top Right. Opening Tradingview watchlist will make the (non-compact) screener overlap a Top Center HUD, so moving it to Top Left keeps it clear.")

// ══════════════════════════════════════════════════════════════════
// 08 │ COMPUTED CONSTANTS
// ══════════════════════════════════════════════════════════════════
var RC_EXT_V = switch rcExt
    'Extend Right' => extend.right
    'Extend Both'  => extend.both
    'Extend None'  => extend.none
    => extend.left

// ══════════════════════════════════════════════════════════════════
// 09 │ HELPER FUNCTIONS
// ══════════════════════════════════════════════════════════════════

f_sym(string t) =>
    string[] parts = str.split(t, ":")
    array.size(parts) > 1 ? str.trim(array.get(parts, array.size(parts) - 1)) : str.trim(t)

f_pos(string s) =>
    switch s
        "Top Left"     => position.top_left
        "Top Center"   => position.top_center
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        "Middle Left"  => position.middle_left
        =>               position.top_right

// Held% cell colour — bright when durable and well-sampled, dim when thin/weak.
// NOT a sort key (kept off i_sort_key on purpose): a base rate, not a signal.
f_persist_cellcol(float hit, int cnt) =>
    na(hit) or cnt < 8 ? C_DIM : hit >= 80 ? C_UP_BOLD : hit >= 60 ? C_UP : hit >= 45 ? C_ACT : C_DN

// Persistence readout — the follow-through audit of Pearson's R, as plain words.
f_persist_str(float hit, int cnt) =>
    na(hit) or cnt < 8 ? "thin — too few past strong-trend moments to trust" :
         str.tostring(math.round(hit)) + "% held (" + str.tostring(cnt) + " past)"

// Distribution band — where a value sits in the visible cohort's spread, as a
// quintile word. Position-in-spread, not rank-order — kills the buy-list read.
f_dist_band(float v, array<float> vals) =>
    int n = 0, int below = 0
    for j = 0 to array.size(vals) - 1
        float x = array.get(vals, j)
        if not na(x)
            n += 1
            if x <= v
                below += 1
    float pctile = n > 0 ? 100.0 * below / n : na
    na(pctile) ? "—" : pctile >= 80 ? "top fifth" : pctile >= 60 ? "upper" :
         pctile >= 40 ? "middle" : pctile >= 20 ? "lower" : "bottom fifth"

f_conf_scr(float r) =>

    float a = math.abs(r)
    a < 0.30 ? "Very Weak" : a < 0.50 ? "Weak" : a < 0.70 ? "Moderate" :
     a < 0.85 ? "Strong"  : a < 0.93 ? "Very Strong" : "Ultra Strong"

f_conf_c(float r) =>
    float a    = math.abs(r)
    color base = r >= 0.0 ? C_UP : C_DN
    int   trans = a < 0.30 ? 60 : a < 0.50 ? 45 : a < 0.70 ? 30 : a < 0.85 ? 15 : 0
    color.new(base, trans)

f_per_label(int n) =>
    if na(n)
        "—"
    else if n <= 30
        str.tostring(n) + "d"
    else if n <= 200
        str.tostring(math.round(float(n) / 21.0)) + "M"
    else
        str.tostring(math.round(float(n) / 252.0, 1)) + "Y"

f_conf_chart(float r) =>
    float a = math.abs(r)
    switch
        a < 0.2  => 'Extremely Weak'
        a < 0.3  => 'Very Weak'
        a < 0.4  => 'Weak'
        a < 0.5  => 'Mostly Weak'
        a < 0.6  => 'Somewhat Weak'
        a < 0.7  => 'Moderately Weak'
        a < 0.8  => 'Moderate'
        a < 0.9  => 'Moderately Strong'
        a < 0.92 => 'Mostly Strong'
        a < 0.94 => 'Strong'
        a < 0.96 => 'Very Strong'
        a < 0.98 => 'Exceptionally Strong'
        => 'Ultra Strong'

// ══════════════════════════════════════════════════════════════════
// 10 │ TAR ENGINE
// Returns [cagr, full_r, best_n, close, post_r, post_pct, adv_m, period_pct, best_peak, sharpe].
// full_r is signed Pearson R (standard convention: + = uptrend).
// period_pct is realised % change over the auto-selected best period
// (the un-annualised companion to CAGR / TAR).
// best_peak is the highest close within the auto-selected best period
// (used as the anchor for the reversal stop in the Action column).
// sharpe is annualised return / annualised vol of daily log returns
// over the best-fit period (Rf = 0; Bessel-corrected sample variance).
// ══════════════════════════════════════════════════════════════════
f_tar(bool lt, int n_recent) =>
    float cagr        = na
    float best_r      = 0.0
    int   best_n      = na
    float post_r      = na
    float post_pct    = na
    float adv_m       = na
    float period_pct  = na
    float best_peak   = na
    float sharpe      = na
    float persist_hit = na
    int   persist_cnt = 0
    if barstate.islast
        float mult = syminfo.type == "crypto" ? 365.0 : 252.0

        // ── Auto-period selection by max |R| ──────────────────────
        int a1 = lt ? 252  : 21
        int a2 = lt ? 378  : 42
        int a3 = lt ? 504  : 63
        int a4 = lt ? 630  : 126
        int a5 = lt ? 756  : 189
        int a6 = lt ? 1008 : 252
        array<int> ps = array.from(a1, a2, a3, a4, a5, a6)

        for pi = 0 to 5
            int n = array.get(ps, pi)
            if bar_index >= n
                float hist = close[n - 1]
                if not na(hist) and hist > 0.0
                    float fn = float(n)
                    float sX = 0., sXX = 0., sYX = 0., sY = 0., sYY = 0.
                    float local_peak = na
                    for j = 0 to n - 1
                        float p  = close[j]
                        if na(local_peak) or p > local_peak
                            local_peak := p
                        float ly = math.log(p)
                        float x  = fn - float(j)
                        sX  += x
                        sXX += x * x
                        sYX += x * ly
                        sY  += ly
                        sYY += ly * ly
                    float avgX = sX / fn
                    float avgY = sY / fn
                    float ssXY = sYX - fn * avgX * avgY
                    float ssXX = sXX - fn * avgX * avgX
                    float ssYY = sYY - fn * avgY * avgY
                    float dnom = ssXX * ssYY
                    float r    = dnom > 0.0 ? ssXY / math.sqrt(dnom) : 0.0
                    if math.abs(r) > math.abs(best_r)
                        best_r     := r
                        best_n     := n
                        cagr       := (math.pow(close / hist, mult / fn) - 1.0) * 100.0
                        period_pct := (close / hist - 1.0) * 100.0
                        best_peak  := local_peak

        // ── Sharpe ratio over best-fit period ─────────────────────
        // Annualised excess return / annualised vol of log returns.
        // Rf assumed 0 for short windows; cagr already annualised.
        // Variance uses Bessel's correction (n−1) — unbiased sample
        // estimator, the textbook Sharpe form.
        if not na(best_n) and not na(cagr) and best_n >= 3 and bar_index >= best_n
            float sum_r = 0., sum_r2 = 0.
            int   cnt   = best_n - 1
            for j = 0 to cnt - 1
                float c1 = close[j]
                float c2 = close[j + 1]
                if not na(c1) and not na(c2) and c1 > 0.0 and c2 > 0.0
                    float dr = math.log(c1) - math.log(c2)
                    sum_r  += dr
                    sum_r2 += dr * dr
            float fcnt  = float(cnt)
            float meanR = sum_r / fcnt
            float varR  = (sum_r2 - fcnt * meanR * meanR) / (fcnt - 1.0)
            if varR > 0.0
                float annVol = math.sqrt(varR) * math.sqrt(mult)
                if annVol > 0.0
                    sharpe := (cagr / 100.0) / annVol

        // ── Post-event / recent window: R, % change, ADV ──────────
        if bar_index >= n_recent
            float fn2  = float(n_recent)
            float base = close[n_recent - 1]

            if not na(base) and base > 0.0
                post_pct := (close / base - 1.0) * 100.0

            float sX2 = 0., sXX2 = 0., sYX2 = 0., sY2 = 0., sYY2 = 0.
            float sumV = 0.
            for j = 0 to n_recent - 1
                float ly2 = math.log(close[j])
                float x2  = fn2 - float(j)
                sX2  += x2
                sXX2 += x2 * x2
                sYX2 += x2 * ly2
                sY2  += ly2
                sYY2 += ly2 * ly2
                sumV += nz(volume[j])
            float avgX2 = sX2 / fn2
            float avgY2 = sY2 / fn2
            float ssXY2 = sYX2 - fn2 * avgX2 * avgY2
            float ssXX2 = sXX2 - fn2 * avgX2 * avgX2
            float ssYY2 = sYY2 - fn2 * avgY2 * avgY2
            float dnom2 = ssXX2 * ssYY2
            post_r := dnom2 > 0.0 ? ssXY2 / math.sqrt(dnom2) : 0.0
            adv_m  := (sumV / fn2) / 1000000.0

        // ── Persistence: does a strong-trend state hold N bars later? ──
        // For each historical bar where this name was strong (post-R ≥ 0.7 AND
        // above its trend stop), check whether it was still above that stop
        // i_persist_n bars later. Reuses close history already loaded — no new
        // security call. This is the forward-audit of Pearson's R: R is the
        // setup, this is the follow-through. Not a forecast; the name's own record.
        int   pn      = i_persist_n
        int   scan_lo = i_event_bars + pn
        int   scan_hi = math.min(bar_index, 756)   // cap history scanned for compute budget
        if bar_index >= scan_lo
            int hits = 0, int obs = 0
            for b = scan_lo to scan_hi
                // trend stop as-of bar b: peak of the best window ending at b,
                // approximated by the recent best_n window peak available then.
                float pk = na
                if not na(best_n) and b >= best_n - 1
                    float lp = na
                    for jj = 0 to best_n - 1
                        float cc = close[b - jj]
                        if not na(cc) and (na(lp) or cc > lp)
                            lp := cc
                    pk := lp
                if not na(pk)
                    float stop_b = pk * (1.0 - i_rev_stop / 100.0)
                    float px_b   = close[b]
                    // post-R at bar b over the event window
                    float base_b = close[b + i_event_bars - 1]
                    bool  strong = false
                    if not na(px_b) and not na(stop_b) and px_b > stop_b and not na(base_b) and base_b > 0.0
                        // quick strength proxy: price rose over the event window AND above stop
                        float chg_b = (px_b / base_b - 1.0)
                        strong := chg_b > 0.0
                    if strong
                        obs += 1
                        float px_fwd = close[b - pn]
                        if not na(px_fwd) and px_fwd > stop_b
                            hits += 1
            persist_cnt := obs
            persist_hit := obs > 0 ? 100.0 * hits / obs : na

        [cagr, best_r, best_n, close, post_r, post_pct, adv_m, period_pct, best_peak, sharpe, persist_hit, persist_cnt]

// ══════════════════════════════════════════════════════════════════
// 11 │ LOG-LINEAR REGRESSION (calcDev — active chart channel)
//
// NOTE on R sign convention:
//   calcDev's pearsonR is structurally non-negative. The formulation
//   sumDyx = Σ(dxt · dyt) reduces to slope² · n · var(i), which is
//   always ≥ 0 regardless of trend direction. Direction is read from
//   the slope sign separately (see display logic in section 16).
//   This is why array.max(_pr) — not max-by-absolute — is the
//   correct selector for the best-fit period.
// ══════════════════════════════════════════════════════════════════
calcDev(float source, int length) =>
    float logSource = math.log(source)
    var int period_1 = length - 1
    if barstate.islast
        float sumX = 0., sumXX = 0., sumYX = 0., sumY = 0.
        for int i = 1 to length
            float lSrc = logSource[i - 1]
            sumX  += i
            sumXX += i * i
            sumYX += i * lSrc
            sumY  += lSrc
        float slope     = nz((length * sumYX - sumX * sumY) / (length * sumXX - sumX * sumX))
        float average   = sumY / length
        float intercept = average - slope * sumX / length + slope
        float sumDev = 0., sumDxx = 0., sumDyy = 0., sumDyx = 0.
        float regres = intercept + slope * period_1 * 0.5
        float sumSlp = intercept
        for int i = 0 to period_1
            float lSrc = logSource[i]
            float dxt  = lSrc - average
            float dyt  = sumSlp - regres
            lSrc      := lSrc - sumSlp
            sumSlp    := sumSlp + slope
            sumDxx    += dxt * dxt
            sumDyy    += dyt * dyt
            sumDyx    += dxt * dyt
            sumDev    += lSrc * lSrc
        float unStdDev = math.sqrt(sumDev / period_1)
        float divisor  = sumDxx * sumDyy
        float pearsonR = nz(sumDyx / math.sqrt(divisor))
        [unStdDev, pearsonR, slope, intercept]
    else
        [na, na, na, na]

// ══════════════════════════════════════════════════════════════════
// 12 │ AUTO-PERIOD REGRESSION CHANNEL (19 candidates)
// ══════════════════════════════════════════════════════════════════
var array<int> RCPeriods_LT = array.from(na, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750, 800, 850, 900, 950, 1000, 1050, 1100, 1150, 1200)
var array<int> RCPeriods_ST = array.from(na,  20,  30,  40,  50,  60,  70,  80,  90, 100, 110, 120, 130, 140, 150,  160,  170,  180,  190,  200)

// LT candidates
[sd_lt01,pr_lt01,sl_lt01,ic_lt01] = calcDev(sourceInput, RCPeriods_LT.get(1))
[sd_lt02,pr_lt02,sl_lt02,ic_lt02] = calcDev(sourceInput, RCPeriods_LT.get(2))
[sd_lt03,pr_lt03,sl_lt03,ic_lt03] = calcDev(sourceInput, RCPeriods_LT.get(3))
[sd_lt04,pr_lt04,sl_lt04,ic_lt04] = calcDev(sourceInput, RCPeriods_LT.get(4))
[sd_lt05,pr_lt05,sl_lt05,ic_lt05] = calcDev(sourceInput, RCPeriods_LT.get(5))
[sd_lt06,pr_lt06,sl_lt06,ic_lt06] = calcDev(sourceInput, RCPeriods_LT.get(6))
[sd_lt07,pr_lt07,sl_lt07,ic_lt07] = calcDev(sourceInput, RCPeriods_LT.get(7))
[sd_lt08,pr_lt08,sl_lt08,ic_lt08] = calcDev(sourceInput, RCPeriods_LT.get(8))
[sd_lt09,pr_lt09,sl_lt09,ic_lt09] = calcDev(sourceInput, RCPeriods_LT.get(9))
[sd_lt10,pr_lt10,sl_lt10,ic_lt10] = calcDev(sourceInput, RCPeriods_LT.get(10))
[sd_lt11,pr_lt11,sl_lt11,ic_lt11] = calcDev(sourceInput, RCPeriods_LT.get(11))
[sd_lt12,pr_lt12,sl_lt12,ic_lt12] = calcDev(sourceInput, RCPeriods_LT.get(12))
[sd_lt13,pr_lt13,sl_lt13,ic_lt13] = calcDev(sourceInput, RCPeriods_LT.get(13))
[sd_lt14,pr_lt14,sl_lt14,ic_lt14] = calcDev(sourceInput, RCPeriods_LT.get(14))
[sd_lt15,pr_lt15,sl_lt15,ic_lt15] = calcDev(sourceInput, RCPeriods_LT.get(15))
[sd_lt16,pr_lt16,sl_lt16,ic_lt16] = calcDev(sourceInput, RCPeriods_LT.get(16))
[sd_lt17,pr_lt17,sl_lt17,ic_lt17] = calcDev(sourceInput, RCPeriods_LT.get(17))
[sd_lt18,pr_lt18,sl_lt18,ic_lt18] = calcDev(sourceInput, RCPeriods_LT.get(18))
[sd_lt19,pr_lt19,sl_lt19,ic_lt19] = calcDev(sourceInput, RCPeriods_LT.get(19))

// ST candidates
[sd_st01,pr_st01,sl_st01,ic_st01] = calcDev(sourceInput, RCPeriods_ST.get(1))
[sd_st02,pr_st02,sl_st02,ic_st02] = calcDev(sourceInput, RCPeriods_ST.get(2))
[sd_st03,pr_st03,sl_st03,ic_st03] = calcDev(sourceInput, RCPeriods_ST.get(3))
[sd_st04,pr_st04,sl_st04,ic_st04] = calcDev(sourceInput, RCPeriods_ST.get(4))
[sd_st05,pr_st05,sl_st05,ic_st05] = calcDev(sourceInput, RCPeriods_ST.get(5))
[sd_st06,pr_st06,sl_st06,ic_st06] = calcDev(sourceInput, RCPeriods_ST.get(6))
[sd_st07,pr_st07,sl_st07,ic_st07] = calcDev(sourceInput, RCPeriods_ST.get(7))
[sd_st08,pr_st08,sl_st08,ic_st08] = calcDev(sourceInput, RCPeriods_ST.get(8))
[sd_st09,pr_st09,sl_st09,ic_st09] = calcDev(sourceInput, RCPeriods_ST.get(9))
[sd_st10,pr_st10,sl_st10,ic_st10] = calcDev(sourceInput, RCPeriods_ST.get(10))
[sd_st11,pr_st11,sl_st11,ic_st11] = calcDev(sourceInput, RCPeriods_ST.get(11))
[sd_st12,pr_st12,sl_st12,ic_st12] = calcDev(sourceInput, RCPeriods_ST.get(12))
[sd_st13,pr_st13,sl_st13,ic_st13] = calcDev(sourceInput, RCPeriods_ST.get(13))
[sd_st14,pr_st14,sl_st14,ic_st14] = calcDev(sourceInput, RCPeriods_ST.get(14))
[sd_st15,pr_st15,sl_st15,ic_st15] = calcDev(sourceInput, RCPeriods_ST.get(15))
[sd_st16,pr_st16,sl_st16,ic_st16] = calcDev(sourceInput, RCPeriods_ST.get(16))
[sd_st17,pr_st17,sl_st17,ic_st17] = calcDev(sourceInput, RCPeriods_ST.get(17))
[sd_st18,pr_st18,sl_st18,ic_st18] = calcDev(sourceInput, RCPeriods_ST.get(18))
[sd_st19,pr_st19,sl_st19,ic_st19] = calcDev(sourceInput, RCPeriods_ST.get(19))

// ══════════════════════════════════════════════════════════════════
// 13 │ SYMBOL PARSING
// ══════════════════════════════════════════════════════════════════
var array<string> SL = array.new<string>()
if barstate.isfirst
    for t in str.split(i_tickers, ",")
        string s = str.trim(t)
        if s != "" and array.size(SL) < 39 and not array.includes(SL, s)
            array.push(SL, s)
int N = array.size(SL)

// ══════════════════════════════════════════════════════════════════
// 14 │ BENCHMARK DATA FETCH
// ══════════════════════════════════════════════════════════════════
// Only post-event % change is consumed (Relative Strength, Section 15).
// Pine requires a name per tuple position, so the rest are explicit discards.
[_bCagr, _bFullR, _bBest, _bPx, _bPostR, bPostPct, _bAdv, _bPeriodPct, _bPeak, _bSharpe, _bPersist, _bPersistN] = request.security(
     i_benchmark, "D", f_tar(i_lt, i_event_bars),
     lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)

// ══════════════════════════════════════════════════════════════════
// 15 │ PER-TICKER DATA FETCH
// ══════════════════════════════════════════════════════════════════
var array<float> A_CAGR    = array.new<float>(40, na)
var array<float> A_R       = array.new<float>(40, na)
var array<float> A_RR      = array.new<float>(40, na)
var array<float> A_PCT     = array.new<float>(40, na)
var array<int>   A_PER     = array.new<int>  (40, na)
var array<float> A_PX      = array.new<float>(40, na)
var array<float> A_ADV     = array.new<float>(40, na)
var array<float> A_RS      = array.new<float>(40, na)
var array<float> A_PERPCT  = array.new<float>(40, na)
var array<float> A_PEAK    = array.new<float>(40, na)
var array<float> A_SHARPE  = array.new<float>(40, na)
var array<float> A_PERSIST  = array.new<float>(40, na)
var array<int>   A_PERSCNT  = array.new<int>  (40, na)
var array<bool>  A_HOLD_T  = array.new<bool> (40, false)
var array<bool>  A_HOLD_E  = array.new<bool> (40, false)
var bool screener_initialized = false

for i = 0 to N - 1
    if N == 0
        break
    [ci, ri, ni, pxi, rri, pcti, advi, perpcti, peaki, shri, persi, perscnti] = request.security(
         array.get(SL, i), "D", f_tar(i_lt, i_event_bars),
         lookahead             = barmerge.lookahead_off,
         ignore_invalid_symbol = true)
    if barstate.islast
        array.set(A_CAGR,   i, ci)
        array.set(A_R,      i, ri)
        array.set(A_RR,     i, rri)
        array.set(A_PCT,    i, pcti)
        array.set(A_PER,    i, ni)
        array.set(A_PX,     i, pxi)
        array.set(A_ADV,    i, advi)
        array.set(A_PERPCT, i, perpcti)
        array.set(A_PEAK,   i, peaki)
        array.set(A_SHARPE, i, shri)
        array.set(A_PERSIST, i, persi)
        array.set(A_PERSCNT, i, perscnti)
        array.set(A_RS,     i, not na(pcti) and not na(bPostPct) ? pcti - bPostPct : na)

        // ── Action state computation + alert transitions ─────────
        float a_stop_t = na(peaki) ? na : peaki * (1.0 - i_rev_stop / 100.0)
        bool  ht       = not na(a_stop_t) and not na(pxi) and pxi > a_stop_t
        float a_entry  = not na(pxi) and not na(pcti) ? pxi / (1.0 + pcti / 100.0) : na
        float a_stop_e = na(a_entry) ? na : a_entry * (1.0 - i_event_stop / 100.0)
        bool  he       = not na(a_stop_e) and not na(pxi) and pxi > a_stop_e

        if screener_initialized
            bool   prev_t  = array.get(A_HOLD_T, i)
            bool   prev_e  = array.get(A_HOLD_E, i)
            string sym_lbl = f_sym(array.get(SL, i))

            if i_alert_trend_exit and prev_t and not ht and not na(a_stop_t) and not na(pxi)
                float buf = (pxi - a_stop_t) / pxi * 100.0
                alert("Trend Breach: " + sym_lbl + " · " + str.tostring(buf, "#.#") + "% past stop", alert.freq_once_per_bar)
            if i_alert_trend_entry and not prev_t and ht
                float buf = (pxi - a_stop_t) / pxi * 100.0
                alert("Trend Recovery: " + sym_lbl + " · +" + str.tostring(buf, "#.#") + "% above stop", alert.freq_once_per_bar)
            if i_alert_event_exit and prev_e and not he and not na(a_stop_e) and not na(pxi)
                float buf = (pxi - a_stop_e) / pxi * 100.0
                alert("Event Breach: " + sym_lbl + " · " + str.tostring(buf, "#.#") + "% past stop", alert.freq_once_per_bar)
            if i_alert_event_entry and not prev_e and he
                float buf = (pxi - a_stop_e) / pxi * 100.0
                alert("Event Recovery: " + sym_lbl + " · +" + str.tostring(buf, "#.#") + "% above stop", alert.freq_once_per_bar)

        array.set(A_HOLD_T, i, ht)
        array.set(A_HOLD_E, i, he)

// ══════════════════════════════════════════════════════════════════
// 16 │ MAIN RENDERING (barstate.islast)
// ══════════════════════════════════════════════════════════════════
var line     rc_upper        = na
var line     rc_base         = na
var line     rc_lower        = na
var linefill rc_fill_up      = na
var linefill rc_fill_dn      = na
var table    SCRNR           = na
var line     trend_stop_line = na
var label    trend_stop_lbl  = na

// ── Carriers: active-symbol trend metrics computed in Section 16
//    (channel block) and read by the regime HUD in Section 19. ──────
var int    g_tDetP      = na
var bool   g_tUseSt     = false
var float  g_tPearsonR  = na
var float  g_tTAR       = na
var float  g_tPeriodChg = na
var float  g_tEventChg  = na
var bool   g_tValidTf   = false

if barstate.islast

    // ── LT candidates ─────────────────────────────────────────────
    array<float> _pr_lt = array.from(pr_lt01,pr_lt02,pr_lt03,pr_lt04,pr_lt05,pr_lt06,pr_lt07,pr_lt08,pr_lt09,pr_lt10,pr_lt11,pr_lt12,pr_lt13,pr_lt14,pr_lt15,pr_lt16,pr_lt17,pr_lt18,pr_lt19)
    array<float> _sl_lt = array.from(sl_lt01,sl_lt02,sl_lt03,sl_lt04,sl_lt05,sl_lt06,sl_lt07,sl_lt08,sl_lt09,sl_lt10,sl_lt11,sl_lt12,sl_lt13,sl_lt14,sl_lt15,sl_lt16,sl_lt17,sl_lt18,sl_lt19)
    array<float> _ic_lt = array.from(ic_lt01,ic_lt02,ic_lt03,ic_lt04,ic_lt05,ic_lt06,ic_lt07,ic_lt08,ic_lt09,ic_lt10,ic_lt11,ic_lt12,ic_lt13,ic_lt14,ic_lt15,ic_lt16,ic_lt17,ic_lt18,ic_lt19)
    array<float> _sd_lt = array.from(sd_lt01,sd_lt02,sd_lt03,sd_lt04,sd_lt05,sd_lt06,sd_lt07,sd_lt08,sd_lt09,sd_lt10,sd_lt11,sd_lt12,sd_lt13,sd_lt14,sd_lt15,sd_lt16,sd_lt17,sd_lt18,sd_lt19)

    float pr_lt_max = array.max(_pr_lt)
    int   best_lt   = array.indexof(_pr_lt, pr_lt_max)
    int   detP_lt   = RCPeriods_LT.get(best_lt + 1)
    float detSl_lt  = array.get(_sl_lt, best_lt)
    float detIc_lt  = array.get(_ic_lt, best_lt)
    float detSd_lt  = array.get(_sd_lt, best_lt)

    // ── ST candidates ─────────────────────────────────────────────
    array<float> _pr_st = array.from(pr_st01,pr_st02,pr_st03,pr_st04,pr_st05,pr_st06,pr_st07,pr_st08,pr_st09,pr_st10,pr_st11,pr_st12,pr_st13,pr_st14,pr_st15,pr_st16,pr_st17,pr_st18,pr_st19)
    array<float> _sl_st = array.from(sl_st01,sl_st02,sl_st03,sl_st04,sl_st05,sl_st06,sl_st07,sl_st08,sl_st09,sl_st10,sl_st11,sl_st12,sl_st13,sl_st14,sl_st15,sl_st16,sl_st17,sl_st18,sl_st19)
    array<float> _ic_st = array.from(ic_st01,ic_st02,ic_st03,ic_st04,ic_st05,ic_st06,ic_st07,ic_st08,ic_st09,ic_st10,ic_st11,ic_st12,ic_st13,ic_st14,ic_st15,ic_st16,ic_st17,ic_st18,ic_st19)
    array<float> _sd_st = array.from(sd_st01,sd_st02,sd_st03,sd_st04,sd_st05,sd_st06,sd_st07,sd_st08,sd_st09,sd_st10,sd_st11,sd_st12,sd_st13,sd_st14,sd_st15,sd_st16,sd_st17,sd_st18,sd_st19)

    float pr_st_max = array.max(_pr_st)
    int   best_st   = array.indexof(_pr_st, pr_st_max)
    int   detP_st   = RCPeriods_ST.get(best_st + 1)
    float detSl_st  = array.get(_sl_st, best_st)
    float detIc_st  = array.get(_ic_st, best_st)
    float detSd_st  = array.get(_sd_st, best_st)

    // ── Adaptive check: has price broken below LT lower? ──────────
    float lt_lower_now       = math.exp(detIc_lt - devMult * detSd_lt)
    float lt_lower_threshold = lt_lower_now * (1.0 - rcDropPct / 100.0)
    bool  lt_broken          = na(lt_lower_now) ? true : (close < lt_lower_threshold)

    // ── Mode selection ────────────────────────────────────────────
    bool use_st = (rcMode == "Short-Term") or (rcMode == "Adaptive" and lt_broken)

    int   detP      = use_st ? detP_st   : detP_lt
    float detSl     = use_st ? detSl_st  : detSl_lt
    float detIc     = use_st ? detIc_st  : detIc_lt
    float detSd     = use_st ? detSd_st  : detSd_lt
    float highestPR = use_st ? pr_st_max : pr_lt_max

    // ── Draw regression channel ───────────────────────────────────
    int   startAt = bar_index - detP + 1
    float startPx = math.exp(detIc + detSl * (detP - 1))
    float endPx   = math.exp(detIc)

    chSt_v  = rcStyle == 'Solid' ? line.style_solid : rcStyle == 'Dashed' ? line.style_dashed : line.style_dotted
    midSt_v = midSt  == 'Solid' ? line.style_solid : midSt  == 'Dashed' ? line.style_dashed : line.style_dotted

    if na(rc_base)
        rc_base := line.new(startAt, startPx, bar_index, endPx,
             width = midWidth, extend = RC_EXT_V,
             color = color.new(midCol, midTrans), style = midSt_v)
    else
        line.set_xy1(rc_base, startAt, startPx)
        line.set_xy2(rc_base, bar_index, endPx)

    float upS = startPx * math.exp(devMult * detSd)
    float upE = endPx   * math.exp(devMult * detSd)
    if na(rc_upper)
        rc_upper := line.new(startAt, upS, bar_index, upE,
             width = chWidth, extend = RC_EXT_V,
             color = color.new(rcCol, chanTrans), style = chSt_v)
    else
        line.set_xy1(rc_upper, startAt, upS)
        line.set_xy2(rc_upper, bar_index, upE)
        line.set_color(rc_upper, rcCol)

    float dnS = startPx / math.exp(devMult * detSd)
    float dnE = endPx   / math.exp(devMult * detSd)
    if na(rc_lower)
        rc_lower := line.new(startAt, dnS, bar_index, dnE,
             width = chWidth, extend = RC_EXT_V,
             color = color.new(rcCol, chanTrans), style = chSt_v)
    else
        line.set_xy1(rc_lower, startAt, dnS)
        line.set_xy2(rc_lower, bar_index, dnE)
        line.set_color(rc_lower, rcCol)

    if na(rc_fill_up)
        rc_fill_up := linefill.new(rc_upper, rc_base,  color = color.new(rcCol, fillTrans))
    if na(rc_fill_dn)
        rc_fill_dn := linefill.new(rc_base,  rc_lower, color = color.new(rcCol, fillTrans))

    // ── Timeframe gate. valid_tf gates the trend-stop line below and
    //    the trend metrics captured for the regime HUD. ─────────────
    bool  valid_tf     = timeframe.isdaily or timeframe.isweekly

    // ── Capture active-symbol trend metrics for the regime HUD ─────
    float mult_ct      = syminfo.type == "crypto" ? 365.0 : 252.0
    float cagr_ct      = na
    float chan_chg_ct  = na
    float event_chg_ct = na
    if not na(detP) and bar_index >= detP and valid_tf
        float histPx = close[detP - 1]
        if not na(histPx) and histPx > 0.0
            cagr_ct     := (math.pow(close / histPx, mult_ct / float(detP)) - 1.0) * 100.0
            chan_chg_ct := (close / histPx - 1.0) * 100.0
    if bar_index >= i_event_bars and valid_tf
        float eventPx = close[i_event_bars - 1]
        if not na(eventPx) and eventPx > 0.0
            event_chg_ct := (close / eventPx - 1.0) * 100.0

    g_tDetP      := detP
    g_tUseSt     := use_st
    g_tPearsonR  := detSl > 0.0 ? -highestPR : highestPR
    g_tTAR       := cagr_ct
    g_tPeriodChg := chan_chg_ct
    g_tEventChg  := event_chg_ct
    g_tValidTf   := valid_tf

    // ── Trend Stop line for active chart symbol ───────────────────
    [chartCagrU, chartFullRU, chartBestN, chartCloseU, chartPostRU, chartPostPctU, chartAdvU, chartPeriodPctU, chartPeak, chartSharpeU, _chartPersist, _chartPersistN] = f_tar(i_lt, i_event_bars)
    float chartTrendStop = na(chartPeak) ? na : chartPeak * (1.0 - i_rev_stop / 100.0)
    string tslStyleV     = trendStopStyle == 'Solid' ? line.style_solid : trendStopStyle == 'Dashed' ? line.style_dashed : line.style_dotted

    if showTrendStop and valid_tf and not na(chartTrendStop)
        if na(trend_stop_line)
            trend_stop_line := line.new(bar_index - 1, chartTrendStop, bar_index, chartTrendStop,
                 color = trendStopCol, width = 1, style = tslStyleV, extend = extend.both)
        else
            line.set_xy1(trend_stop_line, bar_index - 1, chartTrendStop)
            line.set_xy2(trend_stop_line, bar_index, chartTrendStop)
            line.set_color(trend_stop_line, trendStopCol)
            line.set_style(trend_stop_line, tslStyleV)

        string tsLblText = "Trend Stop $" + str.tostring(chartTrendStop, "#.##") + " (" + f_per_label(chartBestN) + " peak)"
        if na(trend_stop_lbl)
            trend_stop_lbl := label.new(bar_index + 1, chartTrendStop,
                 text = tsLblText, color = trendStopCol, textcolor = C_RB,
                 style = label.style_label_left, size = size.small)
        else
            label.set_xy(trend_stop_lbl, bar_index + 1, chartTrendStop)
            label.set_text(trend_stop_lbl, tsLblText)
            label.set_color(trend_stop_lbl, trendStopCol)
    else
        if not na(trend_stop_line)
            line.delete(trend_stop_line)
            trend_stop_line := na
        if not na(trend_stop_lbl)
            label.delete(trend_stop_lbl)
            trend_stop_lbl := na

    // ── Filtering pass ────────────────────────────────────────────
    var array<int>    visible = array.new<int>()
    var array<bool>   fail_flag = array.new<bool>(40, false)
    var array<string> fail_why  = array.new<string>(40, "")
    array.clear(visible)
    for i = 0 to N - 1
        float r_v   = array.get(A_RR,  i)
        float p_v   = array.get(A_PCT, i)
        float a_v   = array.get(A_ADV, i)
        bool  passR = na(r_v) ? false : math.abs(r_v) >= i_min_r
        bool  passP = na(p_v) ? false : math.abs(p_v) >= i_min_pct
        bool  passA = na(a_v) ? false : a_v           >= i_min_adv
        bool  passed = passR and passP and passA
        // record WHY a name failed, for the show-all view
        string why = ""
        why += passR ? "" : (why == "" ? "" : ", ") + "low R"
        why += passP ? "" : (why == "" ? "" : ", ") + "low %chg"
        why += passA ? "" : (why == "" ? "" : ", ") + "low ADV"
        array.set(fail_flag, i, not passed)
        array.set(fail_why,  i, why)
        if passed or i_show_all
            array.push(visible, i)
    int Nv = array.size(visible)

    // ── Sort key extraction ───────────────────────────────────────
    array<float> sv = array.new<float>(Nv)
    for k = 0 to Nv - 1
        if Nv == 0
            break
        int oi = array.get(visible, k)
        float val = switch i_sort_key
            "Post-Event R"        => nz(array.get(A_RR,     oi), 0.0)
            "Full Period R"       => nz(array.get(A_R,      oi), 0.0)
            "TAR (CAGR)"          => nz(array.get(A_CAGR,   oi), 0.0)
            "Sharpe"              => nz(array.get(A_SHARPE, oi), 0.0)
            "Post-Event % Change" => nz(array.get(A_PCT,    oi), 0.0)
            "Relative Strength"   => nz(array.get(A_RS,     oi), 0.0)
            => 0.0
        array.set(sv, k, val)
    array<int> si = array.sort_indices(sv,
         i_srt == "Descending" ? order.descending : order.ascending)

    string ev_lbl = str.tostring(i_event_bars) + "d"
    string bSym   = f_sym(i_benchmark)

    // ── Render screener table ─────────────────────────────────────
    SCRNR := table.new(f_pos(i_pos), 13, Nv + 2,
         border_width = 1, border_color = color.rgb(48, 54, 61, 40), bgcolor = C_BG)

    string SEP = "  ·  "
    string hdr = Nv == 0 ? "Auto-Period Trend Screener" + SEP + i_slot_label + "\n" +
     ((timeframe.isdaily or timeframe.isweekly) ? "No tickers passed filters — loosen Min Post-Event R / %Chg / ADV in the Filters group." : "Screener metrics use daily data — switch to a Daily or Weekly chart to populate it. The regime overlay and HUD stay active here.") :
     "Auto-Period Trend Screener" + SEP + i_slot_label + SEP + "Sorted by " + i_sort_key + " (" + i_srt + ")" +
     "\n" + (i_lt ? "LT" : "ST") + SEP + "Benchmark: " + bSym + SEP + str.format_time(timenow, "dd MMM HH:mm", i_tz) +
     (Nv < N ? SEP + str.tostring(N - Nv) + " filtered" : "")
    table.cell(SCRNR, 0, 0, hdr, bgcolor = C_BG, text_color = C_SIG, text_size = size.normal)
    table.merge_cells(SCRNR, 0, 0, 12, 0)

    table.cell(SCRNR, 0, 1, "#",                  bgcolor=C_HD, text_color=C_DIM, text_size=size.small, width=0.6)
    table.cell(SCRNR, 1, 1, "Symbol",             bgcolor=C_HD, text_color=C_SIG, text_size=size.small, width=2.1, text_halign=text.align_left)
    table.cell(SCRNR, 2, 1, "Held% · n",          bgcolor=C_HD, text_color=C_ACT, text_size=size.small, width=2.4,
         tooltip = "PERSISTENCE — the follow-through audit of Pearson's R. (Replaces TAR.)\n\n" +
                   "Of past bars where this name was in a strong-trend state (rose over the event window AND above its trend stop), the % that were STILL above that stop " + str.tostring(i_persist_n) + " bars later — followed by the sample count (n).\n\n" +
                   "R says the trend is clean NOW. This says whether 'clean now' has historically meant 'still trending later' FOR THIS NAME. It is the name's own record — not a forecast, not a buy signal. A high figure can still break tomorrow, and a high figure on a name late in its move is the momentum trap.\n\n" +
                   "Read it AGAINST the rank: a top-Sharpe name with LOW Held% is strong-but-fragile; a mid-rank name with HIGH Held% on a big n has quietly reliable follow-through. The disagreement is the signal.\n\n" +
                   "n < 8 reads 'thin' and greys out — too few past strong-trend moments to trust.\n" +
                   "Colour: bright green ≥80% · green ≥60% · cyan ≥45% · red below (dim = thin).")
    table.cell(SCRNR, 3, 1, "Sharpe",             bgcolor=C_HD, text_color=C_ACT, text_size=size.small, width=1.8,
         tooltip = "Risk-adjusted return over the auto-selected best-fit period.\n\n" +
                   "Sharpe = annualised return ÷ annualised volatility of daily log returns, with risk-free rate assumed 0 for short windows.\n\n" +
                   "Reading: TAR tells you how strongly a name has trended; Sharpe tells you how cleanly. A high TAR with a low Sharpe means the return came with violent path. A high TAR with a high Sharpe means the trend has been compounding smoothly.\n\n" +
                   "Rough guide: > 1.0 is strong (green) · 0 to 1.0 is acceptable (cyan) · < 0 is poor (red)")
    table.cell(SCRNR, 4, 1, i_compact ? "" : "B Per.",          bgcolor=C_HD, text_color=C_DIM, text_size=size.small, width = i_compact ? 0.1 : 1.8,
         tooltip = i_compact ? "" : "Auto-selected best-fit period for this ticker — the lookback over which the log-linear trend has the highest |Pearson R|.")
    table.cell(SCRNR, 5, 1, i_compact ? "" : "Period %",           bgcolor=C_HD, text_color=C_ACT, text_size=size.small, width = i_compact ? 0.1 : 2.5,
         tooltip = i_compact ? "" : "The actual cumulative return over this stock's best-fit period. The realised partner to TAR — TAR converts the same return into a per-year rate; Period % is the raw total.\n\n" +
                   "Reading them together: TAR tells you how steep the trend is, Period % tells you how much it has compounded.\n\n" +
                   "Green = positive  |  Red = negative")
    table.cell(SCRNR, 6, 1, "Full R | Post R",    bgcolor=C_HD, text_color=C_SIG, text_size=size.small, width=6.0,
         tooltip = "▲ = post-event uptrend  |  ▼ = post-event downtrend\n" +
                   "Full R = signed Pearson R over the best period.\n" +
                   "Post R = Pearson R over the last " + ev_lbl + " (recent window, default sort key).\n" +
                   "Cell colour driven by post-event R magnitude and direction.")
    table.cell(SCRNR, 7, 1, "Chg " + ev_lbl,      bgcolor=C_HD, text_color=C_ACT, text_size=size.small, width=2.0,
         tooltip = "Raw % price change over the recent window.\nGreen = up  |  Red = down")
    table.cell(SCRNR, 8, 1, i_compact ? "" : "RS vs " + bSym,      bgcolor=C_HD, text_color=C_SIG, text_size=size.small, width = i_compact ? 0.1 : 2.2,
         tooltip = i_compact ? "" : "Relative Strength: ticker post-event % change MINUS benchmark post-event % change.\nPositive = outperforming the benchmark over the recent window.")
    table.cell(SCRNR, 9, 1, i_compact ? "" : "ADV (M)",            bgcolor=C_HD, text_color=C_DIM, text_size=size.small, width = i_compact ? 0.1 : 2.0,
         tooltip = i_compact ? "" : "Average daily volume (millions of shares) over the recent window. Use the Min ADV filter to exclude illiquid names.")
    table.cell(SCRNR, 10, 1, "Price",              bgcolor=C_HD, text_color=C_SIG, text_size=size.small, width=1.8,
         tooltip = "Last available daily close price.")
    table.cell(SCRNR, 11, 1, "Stop (T)",      bgcolor=C_HD, text_color=C_SIG, text_size=size.small, width=2.5,
         tooltip = "Stop Trend. Distance from current price to the trend-reversal stop level, anchored to this ticker's best-period peak.\n\n" +
                   "Stop level = highest close within the auto-selected best period × (1 − Trend Stop %).\n" +
                   "Threshold is configurable in the Action Columns input group (default 20%).\n\n" +
                   "Cell shows signed % distance:\n" +
                   "  Positive (green) = buffer remaining above the stop\n" +
                   "  Negative (red)   = price has breached the stop level\n\n" +
                   "Use the Trend Stop line on the chart (Section 07a) to visualise the level for the active chart symbol.")
    table.cell(SCRNR, 12, 1, "Stop (E)",      bgcolor=C_HD, text_color=C_SIG, text_size=size.small, width=2.5,
         tooltip = "Stop Event. Distance from current price to the position stop level, anchored to your post-event entry price.\n\n" +
                   "Stop level = price at the start of the post-event window × (1 − Event Stop %).\n" +
                   "Mental model: 'If I had entered at the start of the window, where would my stop be now?'\n" +
                   "Set Post-Event Bars in the Engine group to match your actual entry date.\n\n" +
                   "Threshold is configurable in the Action Columns input group (default 10%).\n\n" +
                   "Cell shows signed % distance:\n" +
                   "  Positive (green) = buffer remaining above the stop\n" +
                   "  Negative (red)   = price has breached the stop level")

    // ── Body rows ─────────────────────────────────────────────────
    for rank = 0 to Nv - 1
        if Nv == 0
            break
        int    idx  = array.get(si, rank)
        int    oi   = array.get(visible, idx)
        string sym  = array.get(SL,       oi)
        float  cg   = array.get(A_CAGR,   oi)
        float  rv   = array.get(A_R,      oi)
        float  rrv  = array.get(A_RR,     oi)
        float  pct  = array.get(A_PCT,    oi)
        float  rs_v = array.get(A_RS,     oi)
        float  advv = array.get(A_ADV,    oi)
        int    per  = array.get(A_PER,    oi)
        float  px   = array.get(A_PX,     oi)
        float  perp = array.get(A_PERPCT, oi)
        float  peak = array.get(A_PEAK,   oi)
        float  sh   = array.get(A_SHARPE, oi)
        float  pers = array.get(A_PERSIST, oi)
        int    persc = array.get(A_PERSCNT, oi)
        float  sortv = array.get(sv, idx)
        bool   is_failed = array.get(fail_flag, oi)
        string fail_txt  = array.get(fail_why, oi)
        int    row  = rank + 2
        color  rb   = rank % 2 == 0 ? C_RA : C_RB

        // Held% · n — persistence on the table face (replaces TAR).
        string cg_s = (na(pers) or persc < 8) ? "thin" : str.tostring(math.round(pers)) + "% · " + str.tostring(persc)
        color  cg_c = f_persist_cellcol(pers, persc)

        string sh_s = not na(sh) ? str.tostring(sh, "#.##") : "—"
        color  sh_c = na(sh) ? C_DIM : (sh > 1.0 ? C_UP : (sh < 0.0 ? C_DN : C_ACT))

        string perp_s = not na(perp) ? (perp >= 0.0 ? "+" : "") + str.tostring(perp, "#.##") + "%" : "—"
        color  perp_c = not na(perp) ? (perp >= 0.0 ? C_UP : C_DN) : C_DIM

        string dir      = not na(rrv) ? (rrv >= 0.0 ? "▲ " : "▼ ") : ""
        string full_r_s = not na(rv)  ? f_conf_scr(rv)  + "  R " + str.tostring(math.abs(rv),  "#.###") : "—"
        string post_r_s = not na(rrv) ? ev_lbl + " " + str.tostring(math.abs(rrv), "#.###") : "—"
        string cf_s     = not na(rrv) ? dir + full_r_s + " | " + post_r_s : "—"
        color  cf_c     = not na(rrv) ? f_conf_c(rrv) : C_DIM

        string pct_s = not na(pct) ? (pct >= 0.0 ? "+" : "") + str.tostring(pct, "#.##") + "%" : "—"
        color  pct_c = not na(pct) ? (pct >= 0.0 ? C_UP : C_DN) : C_DIM

        string rs_s = not na(rs_v) ? (rs_v >= 0.0 ? "+" : "") + str.tostring(rs_v, "#.##") + "%" : "—"
        color  rs_c = not na(rs_v) ? (rs_v >= 0.0 ? C_UP : C_DN) : C_DIM

        string adv_s = not na(advv) ? str.tostring(advv, "#.#") : "—"
        string px_s  = not na(px)   ? str.tostring(px, "#.##")  : "—"

        // Action (Trend) — peak-anchored reversal stop
        float  stop_t     = na(peak) ? na : peak * (1.0 - i_rev_stop / 100.0)
        bool   hold_t     = not na(stop_t) and not na(px) and px > stop_t
        float  buf_t      = na(stop_t) or na(px) ? na : (px - stop_t) / px * 100.0
        string action_t_s = na(buf_t) ? "—" : (buf_t >= 0.0 ? "+" : "") + str.tostring(buf_t, "#.#") + "%"
        color  action_t_c = na(buf_t) ? C_DIM : (hold_t ? C_UP_BOLD : C_DN_BOLD)

        // Action (Event) — entry-anchored position stop
        float  entry_e    = not na(px) and not na(pct) ? px / (1.0 + pct / 100.0) : na
        float  stop_e     = na(entry_e) ? na : entry_e * (1.0 - i_event_stop / 100.0)
        bool   hold_e     = not na(stop_e) and not na(px) and px > stop_e
        float  buf_e      = na(stop_e) or na(px) ? na : (px - stop_e) / px * 100.0
        string action_e_s = na(buf_e) ? "—" : (buf_e >= 0.0 ? "+" : "") + str.tostring(buf_e, "#.#") + "%"
        color  action_e_c = na(buf_e) ? C_DIM : (hold_e ? C_UP_BOLD : C_DN_BOLD)

        table.cell(SCRNR, 0,  row, str.tostring(rank + 1), bgcolor=rb, text_color=C_DIM,      text_size=size.small, text_font_family=MONO,
             tooltip = "Position in the visible group: " + f_dist_band(sortv, sv) + " of " + str.tostring(Nv) + " names, by " + i_sort_key + ".\n\n" +
                 "The row number is order, not a recommendation. What matters is WHERE in the spread a name sits — 'top fifth' vs 'middle' — not that it is ranked 3rd. A tight spread means the ranking is near-meaningless; a wide one means the leaders are genuinely separated.")
        table.cell(SCRNR, 1,  row, f_sym(sym) + (is_failed ? " ⋯" : ""),  bgcolor=rb, text_color=is_failed ? C_DIM : C_TXT,  text_size=size.small, text_halign=text.align_left,
             tooltip = (is_failed ? "⋯ FILTERED (" + fail_txt + ") — shown because 'Show all names' is on. This name did not pass the filters; it's here so it isn't silently missing.\n\n" : "") + f_sym(sym) + " — PERSISTENCE (follow-through of Pearson's R)\n" +
                 f_persist_str(pers, persc) + "\n\n" +
                 "Of past bars where this name was in a strong-trend state (rose over the event window AND above its trend stop), this is how often it was STILL above that stop " + str.tostring(i_persist_n) + " bars later.\n\n" +
                 "R says the trend is clean NOW; this says whether 'clean now' has historically meant 'still trending later' FOR THIS NAME. It is the name's own record — not a forecast, not the table's hit rate. A high figure can still break tomorrow. 'thin' = too few past strong-trend moments to trust.")
        table.cell(SCRNR, 2,  row, cg_s,                   bgcolor=rb, text_color=cg_c,       text_size=size.small, text_font_family=MONO)
        table.cell(SCRNR, 3,  row, sh_s,                   bgcolor=rb, text_color=sh_c,       text_size=size.small, text_font_family=MONO)
        table.cell(SCRNR, 4,  row, i_compact ? "" : f_per_label(per),       bgcolor=rb, text_color=C_DIM,      text_size=size.small, text_font_family=MONO, width = i_compact ? 0.1 : 0)
        table.cell(SCRNR, 5,  row, i_compact ? "" : perp_s,                 bgcolor=rb, text_color=perp_c,     text_size=size.small, text_font_family=MONO, width = i_compact ? 0.1 : 0)
        table.cell(SCRNR, 6,  row, cf_s,                   bgcolor=rb, text_color=cf_c,       text_size=size.small, text_font_family=MONO)
        table.cell(SCRNR, 7,  row, pct_s,                  bgcolor=rb, text_color=pct_c,      text_size=size.small, text_font_family=MONO)
        table.cell(SCRNR, 8,  row, i_compact ? "" : rs_s,                   bgcolor=rb, text_color=rs_c,       text_size=size.small, text_font_family=MONO, width = i_compact ? 0.1 : 0)
        table.cell(SCRNR, 9,  row, i_compact ? "" : adv_s,                  bgcolor=rb, text_color=C_DIM,      text_size=size.small, text_font_family=MONO, width = i_compact ? 0.1 : 0)
        table.cell(SCRNR, 10, row, px_s,                   bgcolor=rb, text_color=C_TXT,      text_size=size.small, text_font_family=MONO)
        table.cell(SCRNR, 11, row, action_t_s,             bgcolor=rb, text_color=action_t_c, text_size=size.small, text_font_family=MONO)
        table.cell(SCRNR, 12, row, action_e_s,             bgcolor=rb, text_color=action_e_c, text_size=size.small, text_font_family=MONO)

    // ── Arm alerts after first complete pass ──────────────────────
    screener_initialized := true

// ══════════════════════════════════════════════════════════════════
// 17 │ CHART ZIG ZAG (runs every bar)
// ══════════════════════════════════════════════════════════════════
// --- MACRO ENGINE ---
var float zz_last_price = na
var int   zz_last_bar   = na
var int   zz_last_dir   = 0
var line  zz_recent_leg = na
var label zz_recent_lbl = na
var float zz_leg_anchor = na

float ph_zz = ta.pivothigh(high, zzLB, zzRB)
float pl_zz = ta.pivotlow (low,  zzLB, zzRB)

if showZZ and (timeframe.isdaily or timeframe.isweekly)
    // ── High pivot ────────────────────────────────────────────────
    if not na(ph_zz)
        float pv = ph_zz
        int   pb = bar_index - zzRB
        if na(zz_last_price)
            zz_last_price := pv
            zz_last_bar   := pb
            zz_last_dir   := 1
        else if zz_last_dir == 1
            if pv > zz_last_price
                if not na(zz_recent_leg)
                    line.set_xy2(zz_recent_leg, pb, pv)
                if not na(zz_recent_lbl) and not na(zz_leg_anchor)
                    label.set_xy(zz_recent_lbl, pb, pv)
                    float new_pct = (pv - zz_leg_anchor) / zz_leg_anchor * 100.0
                    label.set_text(zz_recent_lbl, "+" + str.tostring(new_pct, "#.#") + "%")
                zz_last_price := pv
                zz_last_bar   := pb
        else
            float pct_move = (pv - zz_last_price) / zz_last_price * 100.0
            if pct_move >= zzPct
                zz_leg_anchor := zz_last_price
                zz_recent_leg := line.new(zz_last_bar, zz_last_price, pb, pv, color = zzUpCol, width = 2)
                if zzLabels
                    zz_recent_lbl := label.new(pb, pv, text = "+" + str.tostring(pct_move, "#.#") + "%", style = label.style_label_down, color = color.new(zzUpCol, zzLblTrans), textcolor = C_RB, size = size.small)
                else
                    zz_recent_lbl := na
                zz_last_price := pv
                zz_last_bar   := pb
                zz_last_dir   := 1

    // ── Low pivot ─────────────────────────────────────────────────
    if not na(pl_zz)
        float pv = pl_zz
        int   pb = bar_index - zzRB
        if na(zz_last_price)
            zz_last_price := pv
            zz_last_bar   := pb
            zz_last_dir   := -1
        else if zz_last_dir == -1
            if pv < zz_last_price
                if not na(zz_recent_leg)
                    line.set_xy2(zz_recent_leg, pb, pv)
                if not na(zz_recent_lbl) and not na(zz_leg_anchor)
                    label.set_xy(zz_recent_lbl, pb, pv)
                    float new_pct = (pv - zz_leg_anchor) / zz_leg_anchor * 100.0
                    label.set_text(zz_recent_lbl, str.tostring(new_pct, "#.#") + "%")
                zz_last_price := pv
                zz_last_bar   := pb
        else
            float pct_move = (pv - zz_last_price) / zz_last_price * 100.0
            if pct_move <= -zzPct
                zz_leg_anchor := zz_last_price
                zz_recent_leg := line.new(zz_last_bar, zz_last_price, pb, pv, color = zzDnCol, width = 2)
                if zzLabels
                    zz_recent_lbl := label.new(pb, pv, text = str.tostring(pct_move, "#.#") + "%", style = label.style_label_up, color = color.new(zzDnCol, zzLblTrans), textcolor = C_RB, size = size.small)
                else
                    zz_recent_lbl := na
                zz_last_price := pv
                zz_last_bar   := pb
                zz_last_dir   := -1

// ══════════════════════════════════════════════════════════════════
// 17b │ INTRADAY ZIG ZAG ENGINE (Secondary)
// ══════════════════════════════════════════════════════════════════
var float izz_last_price = na
var int   izz_last_bar   = na
var int   izz_last_dir   = 0
var line  izz_recent_leg = na
var label izz_recent_lbl = na
var float izz_leg_anchor = na

float ph_izz = ta.pivothigh(high, izzLB, izzRB)
float pl_izz = ta.pivotlow (low,  izzLB, izzRB)
float izz_atr = ta.atr(14)
float izz_threshold = izz_atr * izzAtrMult

if showIZZ and timeframe.isintraday
    // ── High pivot ────────────────────────────────────────────────
    if not na(ph_izz)
        float pv = ph_izz
        int   pb = bar_index - izzRB
        if na(izz_last_price)
            izz_last_price := pv
            izz_last_bar   := pb
            izz_last_dir   := 1
        else if izz_last_dir == 1
            if pv > izz_last_price
                if not na(izz_recent_leg)
                    line.set_xy2(izz_recent_leg, pb, pv)
                if not na(izz_recent_lbl) and not na(izz_leg_anchor)
                    label.set_xy(izz_recent_lbl, pb, pv)
                    float new_pct = (pv - izz_leg_anchor) / izz_leg_anchor * 100.0
                    label.set_text(izz_recent_lbl, "+" + str.tostring(new_pct, "#.#") + "%")
                izz_last_price := pv
                izz_last_bar   := pb
        else
            if (pv - izz_last_price) >= izz_threshold
                izz_leg_anchor := izz_last_price
                float pct_move = (pv - izz_last_price) / izz_last_price * 100.0
                izz_recent_leg := line.new(izz_last_bar, izz_last_price, pb, pv, color = izzUpCol, width = 1, style = line.style_dashed)
                if izzLabels                          // ← was zzLabels
                    izz_recent_lbl := label.new(pb, pv, text = "+" + str.tostring(pct_move, "#.#") + "%", style = label.style_label_down, color = color.new(izzUpCol, izzLblTrans), textcolor = C_RB, size = size.small)
                else
                    izz_recent_lbl := na
                izz_last_price := pv
                izz_last_bar   := pb
                izz_last_dir   := 1

    // ── Low pivot ─────────────────────────────────────────────────
    if not na(pl_izz)
        float pv = pl_izz
        int   pb = bar_index - izzRB
        if na(izz_last_price)
            izz_last_price := pv
            izz_last_bar   := pb
            izz_last_dir   := -1
        else if izz_last_dir == -1
            if pv < izz_last_price
                if not na(izz_recent_leg)
                    line.set_xy2(izz_recent_leg, pb, pv)
                if not na(izz_recent_lbl) and not na(izz_leg_anchor)
                    label.set_xy(izz_recent_lbl, pb, pv)
                    float new_pct = (pv - izz_leg_anchor) / izz_leg_anchor * 100.0
                    label.set_text(izz_recent_lbl, str.tostring(new_pct, "#.#") + "%")
                izz_last_price := pv
                izz_last_bar   := pb
        else
            if (izz_last_price - pv) >= izz_threshold
                izz_leg_anchor := izz_last_price
                float pct_move = (pv - izz_last_price) / izz_last_price * 100.0
                izz_recent_leg := line.new(izz_last_bar, izz_last_price, pb, pv, color = izzDnCol, width = 1, style = line.style_dashed)
                if izzLabels                          // ← was zzLabels
                    izz_recent_lbl := label.new(pb, pv, text = str.tostring(pct_move, "#.#") + "%", style = label.style_label_up, color = color.new(izzDnCol, izzLblTrans), textcolor = C_RB, size = size.small)
                else
                    izz_recent_lbl := na
                izz_last_price := pv
                izz_last_bar   := pb
                izz_last_dir   := -1

// ══════════════════════════════════════════════════════════════════
// 18 │ EVENT START MARKER (runs every bar)
// ══════════════════════════════════════════════════════════════════
var label evt_lbl = na

bool evtTfOk = timeframe.isdaily or timeframe.isweekly
bgcolor(showEvt and evtTfOk and bar_index == last_bar_index - i_event_bars ? evtBgCol : na, title = "Event Start Highlight")

if barstate.islast
    if showEvt and showEvtLbl and evtTfOk and bar_index >= i_event_bars
        int    evtBar = bar_index - i_event_bars
        float  evtY   = low[i_event_bars]
        string evtTxt = "Event Start (" + str.tostring(i_event_bars) + "d)"
        if na(evt_lbl)
            evt_lbl := label.new(evtBar, evtY, text = evtTxt,
                 color = evtLblCol, textcolor = C_RB,
                 style = label.style_label_down, size = size.small)
        else
            label.set_xy(evt_lbl, evtBar, evtY)
            label.set_text(evt_lbl, evtTxt)
            label.set_color(evt_lbl, evtLblCol)
    else
        if not na(evt_lbl)
            label.delete(evt_lbl)
            evt_lbl := na

// ══════════════════════════════════════════════════════════════════
// 19 │ REGIME OVERLAY ENGINE — LAYERS, SIGNALS & HUD
//      Institutional momentum / volatility-regime engine. Inputs are
//      declared in Section 07d. Borrows the shared colour system (01).
// ══════════════════════════════════════════════════════════════════

// ── LAYER 1: LOCAL TREND ANCHOR ───────────────────────────────────
src = smooth ? ta.ema(close, len_smooth) : close

upper_anchor = ta.highest(src, lookback)
lower_anchor = ta.lowest(src, lookback)
trend_mid    = ta.linreg(src, lookback, 0)

bull_slope = trend_mid > nz(trend_mid[1], trend_mid)
bear_slope = trend_mid < nz(trend_mid[1], trend_mid)

// ── LAYER 2: MTF VOLATILITY REGIME ENGINE ─────────────────────────
get_htf_vol() =>
    htf_raw_vol   = ta.stdev(close, vol_len)
    htf_vol       = ta.ema(htf_raw_vol, 20)
    htf_vol_rank  = ta.percentrank(htf_vol, 252)
    htf_sma_vol   = ta.sma(htf_vol, 50)
    htf_expanding = htf_vol > htf_sma_vol ? 1.0 : 0.0
    [htf_vol_rank, htf_expanding]

[htf_vol_rank, htf_expanding_raw] = request.security(syminfo.tickerid, regime_tf, get_htf_vol(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

vol_rank      = nz(htf_vol_rank, 50.0)
vol_expanding = nz(htf_expanding_raw, 0.0) == 1.0

// ── LAYER 3: LOCAL EXTENSION ENGINE & LIQUIDITY ───────────────────
mean_z = ta.ema(src, z_len)
std_z  = ta.stdev(src, z_len)
z      = std_z > 0 ? (src - mean_z) / std_z : 0

vol_sma = ta.sma(volume, 50)
rvol    = volume / (vol_sma == 0 or na(vol_sma) ? math.max(volume, 1) : vol_sma)

// ── LAYER 4: DYNAMIC MULTIPLIERS & COMPRESSION ────────────────────
compression_up   = 1 / (1 + math.exp(-z))
compression_down = 1 / (1 + math.exp(z))

dynamic_mu = base_mu * (1 - (compression_up * scale_up))
dynamic_ml = base_ml * (1 - (compression_down * scale_down))

local_vol = ta.atr(lookback)

vol_adjustment = 1 + ((vol_rank / 100.0) * 0.5)

width_upper = dynamic_mu * local_vol * vol_adjustment
width_lower = dynamic_ml * local_vol * vol_adjustment

// ── LAYER 5: SMARTER ANCHORS ──────────────────────────────────────
raw_upper  = (0.7 * upper_anchor) + (0.3 * trend_mid) - width_upper
raw_lower  = (0.7 * lower_anchor) + (0.3 * trend_mid) + width_lower

upper      = math.max(raw_upper, raw_lower)
lower      = math.min(raw_upper, raw_lower)
centerline = ta.ema((upper + lower) / 2, 10)

// ── LAYER 6: INSTITUTIONAL CONFIDENCE SCORE ───────────────────────
extension_score = math.min(math.abs(z) / 3.0, 1.0)
vol_denom       = math.max(local_vol * 5, 0.000001)
trend_score     = math.min(math.abs(trend_mid - nz(trend_mid[20], trend_mid)) / vol_denom, 1.0)

vol_multiplier  = math.min(math.max(rvol, 0.5), 1.2)
confidence      = math.min(((extension_score + trend_score) / 2.0) * vol_multiplier, 1.0)

// ── LAYER 7: MODULAR EXECUTION LOGIC & STATE MACHINE ──────────────
buy_raw  = ta.crossover(src, centerline)
sell_raw = ta.crossunder(src, centerline)

valid_bar = strict_exec ? barstate.isconfirmed : true

buy_cond  = false
sell_cond = false

if exec_mode == 'Conservative (Original)'
    buy_cond  := nz(ta.barssince(buy_raw), 999) <= 2 and src > centerline and bull_slope and valid_bar
    sell_cond := nz(ta.barssince(sell_raw), 999) <= 2 and src < centerline and bear_slope and valid_bar
else if exec_mode == 'Fast Centerline Break'
    buy_cond  := buy_raw and valid_bar
    sell_cond := sell_raw and valid_bar
else if exec_mode == 'Band Reversal (Anticipatory)'
    buy_cond  := ta.crossover(src, lower) and valid_bar
    sell_cond := ta.crossunder(src, upper) and valid_bar

var bool is_bullish = false
is_bullish := buy_cond ? true : sell_cond ? false : is_bullish

buy  = buy_cond and not is_bullish[1]
sell = sell_cond and is_bullish[1]

// ── LAYER 8: AUTO FIBONACCI CALCULATIONS ──────────────────────────
maxr = ta.highest(high, fib_len)
minr = ta.lowest(low, fib_len)
ranr = maxr - minr

fib_100 = show_fib ? maxr : na
fib_764 = show_fib ? maxr - 0.236 * ranr : na
fib_618 = show_fib ? maxr - 0.382 * ranr : na
fib_500 = show_fib ? maxr - 0.500 * ranr : na
fib_382 = show_fib ? minr + 0.382 * ranr : na
fib_236 = show_fib ? minr + 0.236 * ranr : na
fib_000 = show_fib ? minr : na

// ── PLOTTING & VISUALS ────────────────────────────────────────────
bgcolor(is_bullish ? color.new(C_UP_BOLD, 89) : color.new(C_DN_BOLD, 95), title="Regime Background")

plot(smooth ? src : na, color = C_SIG, title = 'Smoothed Price Line', linewidth = 2)
p_u = plot(upper, color = color.new(C_DN, 60), title = 'Upper Band', linewidth = 1)
p_l = plot(lower, color = color.new(C_UP, 60), title = 'Lower Band', linewidth = 1)
p_m = plot(centerline, color = color.new(C_DIM, 40), title = 'Adaptive Centerline', linewidth = 1, style = plot.style_linebr)

upper_fill = src > upper ? color.new(C_UP, 60) : src > centerline ? color.new(C_UP, 85) : na
lower_fill = src < lower ? color.new(C_DN, 60) : src < centerline ? color.new(C_DN, 85) : na

fill(p_u, p_m, color = upper_fill, title = 'Upper Zone Fill')
fill(p_m, p_l, color = lower_fill, title = 'Lower Zone Fill')

// Optimized plotshapes reacting instantly to the chosen trigger mode
plotshape(buy, title = 'Buy Signal', style = shape.triangleup, location = location.belowbar, color = C_UP_BOLD, size = size.tiny)
plotshape(sell, title = 'Sell Signal', style = shape.triangledown, location = location.abovebar, color = C_DN_BOLD, size = size.tiny)

// Plot Fibonacci Lines
plot(fib_100, title = 'Fib 1.000', color = color.new(C_DIM, 60), linewidth = 1, style = plot.style_line)
plot(fib_764, title = 'Fib 0.764', color = color.new(C_DIM, 60), linewidth = 1, style = plot.style_line)
plot(fib_618, title = 'Fib 0.618', color = color.new(C_DIM, 60), linewidth = 1, style = plot.style_line)
plot(fib_500, title = 'Fib 0.500', color = color.new(C_DIM, 60), linewidth = 1, style = plot.style_line)
plot(fib_382, title = 'Fib 0.382', color = color.new(C_DIM, 60), linewidth = 1, style = plot.style_line)
plot(fib_236, title = 'Fib 0.236', color = color.new(C_DIM, 60), linewidth = 1, style = plot.style_line)
plot(fib_000, title = 'Fib 0.000', color = color.new(C_DIM, 60), linewidth = 1, style = plot.style_line)

// Persistent Fib Labels Management
var label lbl_100 = na
var label lbl_764 = na
var label lbl_618 = na
var label lbl_500 = na
var label lbl_382 = na
var label lbl_236 = na
var label lbl_000 = na

if barstate.islast
    if show_fib
        if na(lbl_100)
            lbl_100 := label.new(bar_index + 3, maxr, '1.000', xloc = xloc.bar_index, style = label.style_label_left, color = C_BG, textcolor = C_DIM, size = size.small)
            lbl_764 := label.new(bar_index + 3, maxr - 0.236 * ranr, '0.764', xloc = xloc.bar_index, style = label.style_label_left, color = C_BG, textcolor = C_DIM, size = size.small)
            lbl_618 := label.new(bar_index + 3, maxr - 0.382 * ranr, '0.618', xloc = xloc.bar_index, style = label.style_label_left, color = C_BG, textcolor = C_DIM, size = size.small)
            lbl_500 := label.new(bar_index + 3, maxr - 0.50 * ranr, '0.500', xloc = xloc.bar_index, style = label.style_label_left, color = C_BG, textcolor = C_DIM, size = size.small)
            lbl_382 := label.new(bar_index + 3, minr + 0.382 * ranr, '0.382', xloc = xloc.bar_index, style = label.style_label_left, color = C_BG, textcolor = C_DIM, size = size.small)
            lbl_236 := label.new(bar_index + 3, minr + 0.236 * ranr, '0.236', xloc = xloc.bar_index, style = label.style_label_left, color = C_BG, textcolor = C_DIM, size = size.small)
            lbl_000 := label.new(bar_index + 3, minr, '0.000', xloc = xloc.bar_index, style = label.style_label_left, color = C_BG, textcolor = C_DIM, size = size.small)
        else
            label.set_xy(lbl_100, bar_index + 3, maxr)
            label.set_xy(lbl_764, bar_index + 3, maxr - 0.236 * ranr)
            label.set_xy(lbl_618, bar_index + 3, maxr - 0.382 * ranr)
            label.set_xy(lbl_500, bar_index + 3, maxr - 0.50 * ranr)
            label.set_xy(lbl_382, bar_index + 3, minr + 0.382 * ranr)
            label.set_xy(lbl_236, bar_index + 3, minr + 0.236 * ranr)
            label.set_xy(lbl_000, bar_index + 3, minr)
    else
        label.delete(lbl_100), lbl_100 := na
        label.delete(lbl_764), lbl_764 := na
        label.delete(lbl_618), lbl_618 := na
        label.delete(lbl_500), lbl_500 := na
        label.delete(lbl_382), lbl_382 := na
        label.delete(lbl_236), lbl_236 := na
        label.delete(lbl_000), lbl_000 := na

// ── ON-CHART HUD DASHBOARD (TABLE UI) ─────────────────────────────
risk_pct = is_bullish ? (math.abs(src - lower) / src) * 100 : (math.abs(src - upper) / src) * 100

// Determine Risk/Runway color:
// High Conf + High Risk = Cyan (Momentum Runway)
// Low Conf + High Risk = Red (Danger/Overextended)
risk_color = (confidence > 0.6 and risk_pct > 5.0) ? C_ACT : (confidence < 0.4 and risk_pct > 4.0) ? C_DN_BOLD : C_TXT

pos_mapped = switch table_pos
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    "Bottom Right"  => position.bottom_right
    =>                position.top_left

// rows = max gap (6) + 13 content rows. Unused rows collapse to zero height.
var table hud = table.new(position = pos_mapped, columns = 2, rows = 19, bgcolor = na, border_width = 0)

if barstate.islast
    text_sz = size.small
    f_mono  = font.family_monospace
    base    = i_hud_gap

    // ── Period / event lengths surfaced for an instant read ────────
    per_sfx = na(g_tDetP) ? "" : " Detected period: " + str.tostring(g_tDetP) + " bars."
    evt_sfx = " Window: " + str.tostring(i_event_bars) + " bars."

    // ─────────────────────────────────────────────────────────────
    //  Active-symbol TREND tooltips (regression-channel read)
    // ─────────────────────────────────────────────────────────────
    float t_absR = na(g_tPearsonR) ? na : math.abs(g_tPearsonR)

    tt_period_val = (g_tUseSt ? "Short-Term channel active: the long-term trend has broken its lower band, so the auto-period has re-fit to the current, shorter structure. Treat long-horizon signals with caution." : "Long-Term channel active: the dominant trend is intact. The detected period reflects the primary structure.") + per_sfx

    tt_strength_val = (na(t_absR) ? "No channel fit available on this symbol/timeframe." : t_absR >= 0.8 ? "Strong linear fit: the channel explains most of the price action; the trend read is reliable." : t_absR >= 0.6 ? "Moderate fit: the broad direction is captured but with noise; confirm with other signals." : "Weak fit: price is not tracking the channel; favour range / mean-reversion logic.") + (na(g_tPearsonR) ? "" : "\nPearson's R: " + str.tostring(g_tPearsonR, "#.###") + "." + per_sfx)

    tt_tar_val = (not g_tValidTf or na(g_tTAR)) ? "Trend Annualised Return is computed on daily / weekly timeframes only." : (g_tTAR >= 30.0 ? "Steep uptrend: a very high annualised channel return. Strong momentum, but watch for overextension." : g_tTAR >= 0.0 ? "Positive trend: the channel slopes up at a sustainable annualised pace." : "Downtrend: the channel annualises a negative return. Trend-following longs are fighting the slope.") + per_sfx

    tt_pchg_val = (not g_tValidTf or na(g_tPeriodChg)) ? "Daily / weekly timeframes only." : (g_tPeriodChg >= 0.0 ? "Price is up across the detected channel period — consistent with the channel's direction." : "Price is down across the detected channel period — momentum within the channel is negative.") + per_sfx

    tt_echg_val = (not g_tValidTf or na(g_tEventChg)) ? "Daily / weekly timeframes only." : (g_tEventChg >= 0.0 ? "Up since the event-start marker — the catalyst has held." : "Down since the event-start marker — the move has faded since the catalyst.") + evt_sfx

    // ─────────────────────────────────────────────────────────────
    //  REGIME tooltips (momentum / volatility read)
    // ─────────────────────────────────────────────────────────────
    tt_conf_val = confidence > 0.75 ? "High Conviction (>75%): Strong institutional backing." : confidence > 0.45 ? "Moderate Conviction (45-75%): Proceed with standard sizing." : "Low Conviction (<45%): Choppy/weak momentum. Avoid or scale down."

    tt_risk_val = confidence > 0.70 ? (risk_pct > 5.0 ? "Momentum Runway (>5%): Institutional momentum breakout. The band is trailing far behind, allowing for aggressive trend-following." : "Stable Trend: Asset is maintaining controlled, steady momentum.") : (risk_pct > 4.0 ? "High Risk (>4.0%): Price is extended without institutional backing. High probability of mean-reversion." : "Standard Zone: Neutral risk/reward environment.")

    tt_rvol_val = rvol > 1.5 ? "High (>1.5x): Abnormal volume detected. Strong participation." : rvol < 0.6 ? "Low (<0.6x): Retail chop. Vulnerable to fakeouts." : "Average: Normal market conditions."

    tt_vrnk_val = vol_rank > 80 ? "Extreme (>80%): Highly energetic market. Watch for explosive moves or sharp mean reversion." : vol_rank < 20 ? "Low (<20%): Deep compression. A major directional breakout is building." : "Mid-range: Standard volatility environment."

    tt_vreg_val = vol_expanding ? "Expanding: Increasing volatility. Favorable for momentum and trend continuation." : "Compressed: Decreasing volatility. Favorable for mean reversion and ranging strategies."

    // ── Spacer rows to clear the TradingView chart legend ──────────
    if base > 0
        for r = 0 to base - 1
            table.cell(hud, 0, r, " ", text_size = text_sz, bgcolor = na)
            table.cell(hud, 1, r, " ", text_size = text_sz, bgcolor = na)

    // Row base+0: MASTER TITLE BAR
    table.cell(hud, 0, base + 0, hud_title, text_color = C_SIG, text_size = size.normal, bgcolor = C_RA, text_halign = text.align_left, text_font_family = f_mono, tooltip = "Active chart symbol — combined trend (regression channel) + regime (momentum / volatility) read.")
    table.cell(hud, 1, base + 0, syminfo.ticker, text_color = C_SIG, text_size = size.normal, bgcolor = C_RA, text_halign = text.align_right, text_font_family = f_mono, tooltip = "Active chart symbol — combined trend (regression channel) + regime (momentum / volatility) read.")

    // Row base+1: TREND section header (right cell = chart timeframe)
    table.cell(hud, 0, base + 1, "Trend", text_color = C_ACT, text_size = text_sz, bgcolor = C_HD, text_halign = text.align_left, text_font_family = f_mono, tooltip = "Regression-channel read on the active chart timeframe.")
    table.cell(hud, 1, base + 1, timeframe.period, text_color = C_DIM, text_size = text_sz, bgcolor = C_HD, text_halign = text.align_right, text_font_family = f_mono, tooltip = "Chart timeframe the trend read is measured on.")

    // Row base+2: Auto-Period
    table.cell(hud, 0, base + 2, "Auto-Period", text_color = C_DIM, text_size = text_sz, bgcolor = C_RA, text_halign = text.align_left, text_font_family = f_mono, tooltip = "Auto-selected best regression-channel lookback. ST = short-term (long-term broken); LT = long-term (intact)." + per_sfx)
    period_str = na(g_tDetP) ? "—" : str.tostring(g_tDetP) + " bars · " + (g_tUseSt ? "ST" : "LT")
    table.cell(hud, 1, base + 2, period_str, text_color = C_ACT, text_size = text_sz, bgcolor = C_RA, text_halign = text.align_right, text_font_family = f_mono, tooltip = tt_period_val)

    // Row base+3: Trend Strength
    table.cell(hud, 0, base + 3, "Trend Strength", text_color = C_DIM, text_size = text_sz, bgcolor = C_HD, text_halign = text.align_left, text_font_family = f_mono, tooltip = "Pearson's R fit quality of the active regression channel.")
    strength_color = na(t_absR) ? C_DIM : t_absR >= 0.8 ? C_UP_BOLD : t_absR >= 0.6 ? C_ACT : C_DN_BOLD
    strength_text  = na(t_absR) ? "—" : f_conf_chart(g_tPearsonR)
    table.cell(hud, 1, base + 3, strength_text, text_color = strength_color, text_size = text_sz, bgcolor = C_RB, text_halign = text.align_right, text_font_family = f_mono, tooltip = tt_strength_val)

    // Row base+4: Trend Annualised Return
    table.cell(hud, 0, base + 4, "Trend Ann. Return", text_color = C_DIM, text_size = text_sz, bgcolor = C_RA, text_halign = text.align_left, text_font_family = f_mono, tooltip = "Annualised return implied by the channel slope over its detected period. Daily / weekly only." + per_sfx)
    tar_color = (not g_tValidTf or na(g_tTAR)) ? C_DIM : g_tTAR >= 0.0 ? C_UP_BOLD : C_DN_BOLD
    tar_text  = (not g_tValidTf or na(g_tTAR)) ? "N/A" : (g_tTAR >= 0.0 ? "+" : "") + str.tostring(g_tTAR, "#.#") + "%"
    table.cell(hud, 1, base + 4, tar_text, text_color = tar_color, text_size = text_sz, bgcolor = C_RA, text_halign = text.align_right, text_font_family = f_mono, tooltip = tt_tar_val)

    // Row base+5: Period Change
    table.cell(hud, 0, base + 5, "Period Change", text_color = C_DIM, text_size = text_sz, bgcolor = C_HD, text_halign = text.align_left, text_font_family = f_mono, tooltip = "Price change across the detected channel period." + per_sfx)
    pchg_color = (not g_tValidTf or na(g_tPeriodChg)) ? C_DIM : g_tPeriodChg >= 0.0 ? C_UP : C_DN
    pchg_text  = (not g_tValidTf or na(g_tPeriodChg)) ? "N/A" : (g_tPeriodChg >= 0.0 ? "+" : "") + str.tostring(g_tPeriodChg, "#.#") + "%"
    table.cell(hud, 1, base + 5, pchg_text, text_color = pchg_color, text_size = text_sz, bgcolor = C_RB, text_halign = text.align_right, text_font_family = f_mono, tooltip = tt_pchg_val)

    // Row base+6: Event Change
    table.cell(hud, 0, base + 6, "Event Chg (" + str.tostring(i_event_bars) + " bars)", text_color = C_DIM, text_size = text_sz, bgcolor = C_RA, text_halign = text.align_left, text_font_family = f_mono, tooltip = "Price change since the event-start marker." + evt_sfx)
    echg_color = (not g_tValidTf or na(g_tEventChg)) ? C_DIM : g_tEventChg >= 0.0 ? C_UP : C_DN
    echg_text  = (not g_tValidTf or na(g_tEventChg)) ? "N/A" : (g_tEventChg >= 0.0 ? "+" : "") + str.tostring(g_tEventChg, "#.#") + "%"
    table.cell(hud, 1, base + 6, echg_text, text_color = echg_color, text_size = text_sz, bgcolor = C_RA, text_halign = text.align_right, text_font_family = f_mono, tooltip = tt_echg_val)

    // Row base+7: REGIME section header (right cell = regime resolution TF)
    table.cell(hud, 0, base + 7, "Regime", text_color = C_ACT, text_size = text_sz, bgcolor = C_HD, text_halign = text.align_left, text_font_family = f_mono, tooltip = "Momentum / volatility read for the active symbol.")
    table.cell(hud, 1, base + 7, regime_tf, text_color = C_DIM, text_size = text_sz, bgcolor = C_HD, text_halign = text.align_right, text_font_family = f_mono, tooltip = "Higher timeframe the regime engine resolves against.")

    // Row base+8: Signal Confidence
    table.cell(hud, 0, base + 8, "Signal Confidence", text_color = C_DIM, text_size = text_sz, bgcolor = C_RA, text_halign = text.align_left, text_font_family = f_mono, tooltip = "Blended metric: Z-Score, Trend Slope, and RVOL.")
    conf_color = confidence > 0.75 ? C_UP_BOLD : confidence > 0.45 ? C_ACT : C_DN_BOLD
    table.cell(hud, 1, base + 8, str.tostring(confidence * 100, "#.0") + "%", text_color = conf_color, text_size = text_sz, bgcolor = C_RA, text_halign = text.align_right, text_font_family = f_mono, tooltip = tt_conf_val)

    // Row base+9: Risk to Invalidation
    table.cell(hud, 0, base + 9, "Risk to Invalidation", text_color = C_DIM, text_size = text_sz, bgcolor = C_HD, text_halign = text.align_left, text_font_family = f_mono, tooltip = "Distance to structural invalidation (the opposite volatility band).")
    table.cell(hud, 1, base + 9, str.tostring(risk_pct, "#.00") + "%", text_color = risk_color, text_size = text_sz, bgcolor = C_RB, text_halign = text.align_right, text_font_family = f_mono, tooltip = tt_risk_val)

    // Row base+10: RVOL
    table.cell(hud, 0, base + 10, "Relative Volume (RVOL)", text_color = C_DIM, text_size = text_sz, bgcolor = C_RA, text_halign = text.align_left, text_font_family = f_mono, tooltip = "Current volume vs 50-period average.")
    rvol_color = rvol > 1.5 ? C_UP_BOLD : rvol < 0.6 ? C_DN_BOLD : C_ACT
    table.cell(hud, 1, base + 10, str.tostring(rvol, "#.00") + "x", text_color = rvol_color, text_size = text_sz, bgcolor = C_RA, text_halign = text.align_right, text_font_family = f_mono, tooltip = tt_rvol_val)

    // Row base+11: Volatility Percentile
    table.cell(hud, 0, base + 11, "Vol Percentile (" + regime_tf + ")", text_color = C_DIM, text_size = text_sz, bgcolor = C_HD, text_halign = text.align_left, text_font_family = f_mono, tooltip = "Where current volatility ranks in the yearly distribution.")
    table.cell(hud, 1, base + 11, str.tostring(vol_rank, "#.0") + "%", text_color = C_ACT, text_size = text_sz, bgcolor = C_RB, text_halign = text.align_right, text_font_family = f_mono, tooltip = tt_vrnk_val)

    // Row base+12: Volatility Regime
    table.cell(hud, 0, base + 12, "Vol Regime (" + regime_tf + ")", text_color = C_DIM, text_size = text_sz, bgcolor = C_RA, text_halign = text.align_left, text_font_family = f_mono, tooltip = "Expanding = Momentum; Compressed = Mean Reversion.")
    reg_text  = vol_expanding ? "EXPANDING" : "COMPRESSED"
    reg_color = vol_expanding ? C_ACT : C_DIM
    table.cell(hud, 1, base + 12, reg_text, text_color = reg_color, text_size = text_sz, bgcolor = C_RA, text_halign = text.align_right, text_font_family = f_mono, tooltip = tt_vreg_val)
````

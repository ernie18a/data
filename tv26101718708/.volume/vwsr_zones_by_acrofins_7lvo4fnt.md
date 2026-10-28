# VWSR Zones By Acrofins

- url: https://www.tradingview.com/script/7LvO4fNt-VWSR-Zones-By-Acrofins/
- type: indicator
- pine_id: PUB;d6b486b69d224347833b9ee293a3c2ca
- version: 1.0

## Description

VWSR Zones — Acrofins Edition
A volume-weighted support/resistance engine with break/retest signals, a configurable risk-management overlay, and a session-aware money manager. Built to make discretionary price-action trading more structured and less reactive.


What this indicator does
Most "support and resistance" tools draw lines at every minor swing high or low and leave you to decide which ones matter. This indicator does the prioritization for you.

Every time price makes a pivot (a swing high or swing low), the indicator scores that pivot based on how much volume traded into it and how strongly price reacted after it formed. High-volume pivots with sharp reactions get high scores; thin-volume pivots with weak reactions get low scores. Nearby pivots get clustered into zones, and each re-touch of a zone strengthens it further. Zones decay in importance as they age, and the weakest ones get pruned so the chart stays clean.

The result is a small set of ranked, weighted S/R zones — typically 4–8 active at any time — instead of dozens of unprioritized lines. Zones are fully price-anchored and extend to the right of the chart so they move naturally with every scroll and pan.

On top of the zone engine sits a complete trade-management layer: break detection, retest detection, automatic SL/TP/break-even levels, a higher-timeframe trend filter, an intraday-only mode, a daily loss cap, and a real-time dashboard.


Key features at a glance
Zone engine

Volume-weighted pivot scoring (0–100 scale)
Adaptive zone clustering with ATR-padded merge
Touch counter (each retest reinforces the zone)
Age decay so old zones lose relevance gracefully
Auto-pruning when the active count exceeds your cap
Conviction scale displayed on each zone label (●●○○○ through ●●●●●)
Color intensity reflects conviction — bold solid fill for strong zones, soft transparent fill for weak zones

Signals

Break ▲ / Break ▼ detection with optional close-past-zone confirmation
Retest ▲ / Retest ▼ queue tracking up to 6 broken zones in parallel (most indicators only track the most recent)
Counter-trend tagging ⚠ when a signal fires against the higher-timeframe trend
Optional volume floor and volume cap filters (gap-day protection)
Optional momentum filter (×ATR candle range)

Risk management

Four built-in presets (Conservative, Balanced, Aggressive, Scalping) plus full Custom
ATR-based SL with optional zone-aware override
Three take-profit targets with R-multiple targeting
Break-even trail after TP1
Optional intraday-only mode that blocks late entries and force-closes positions

Money manager

Currency-symbol and number-notation configurable (works globally — Western K/M/B or Indian K/L/Cr)
Per-trade risk in your account currency
Daily loss cap that blocks new entries once hit
Lot-aware sizing for futures/options (configurable lot size)
Session and lifetime P&L tracking

Higher-timeframe context

Configurable HTF (default 1H) with fast/slow EMA classification
Trend direction (Bullish / Bearish / Neutral) shown in dashboard
Counter-trend signals flagged with ⚠ symbol
Optional hard-block of counter-trend entries

Operational

Instrument-type auto-detect (Index vs Single Stock) with adaptive filter defaults
Session filter with configurable timezone
Optional weekly expiry-day filter for derivatives traders (useful for NSE, CBOE)
Persistent statistics across input changes (W/L, Win Rate, Avg R, BE saves)
Theme-adaptive colors (light & dark) with WCAG AA contrast
JSON webhook format for alerts (for automation pipelines)


How it works under the hood
1. Pivot scoring
When a swing high (resistance pivot) or swing low (support pivot) confirms, three score components are computed:

Base score (10 points) — every pivot starts with a baseline
Volume score (0–40 points) — ratio of pivot-bar volume to recent average volume
Reaction score (0–30 points) — how far price moved away from the pivot in the next N bars, measured in ATR

Total raw score is capped at 100. Conviction is shown on each zone label as a dot scale:

Scale
Tier
Score range
●●○○○
Weak
< 30
●●●○○
Medium
30–60
●●●●○
Strong
60–85
●●●●●
Elite
85+


Zone fill color intensity matches the conviction tier — Elite zones are bold and opaque; Weak zones are soft and transparent. This lets you read zone importance at a glance without needing to check labels.
2. Zone clustering
If a new pivot is within Zone Merge Distance × ATR of an existing zone of the same type, it merges into that zone instead of creating a new one. The merge expands the zone bounds (with ATR padding maintained), increments the touch counter, and adds a fraction of the new pivot's score plus a touch bonus.

If no nearby zone exists, a new zone is created with ATR-padded bounds (±0.15 × ATR).
3. Decay and cleanup
Every confirmed bar, all zone scores decay slightly (rate controlled by Age Decay Rate). Zones are removed when they get too old, too weak, or have been broken without retest for too long. If the active zone count exceeds Max Active Zones, the weakest one is pruned.
4. Break detection
A bullish break fires when price closes above a resistance zone's top (optionally requiring close to exceed by X × ATR). A bearish break fires on the symmetric condition. Optional filters require minimum volume, maximum volume (gap protection), and minimum candle range.

When multiple zones break on the same bar, the higher-scored zone wins — so you get the most meaningful signal, not a random one.
5. Retest detection
After a break, the indicator watches for price to return and test the broken zone (which has flipped role — broken resistance becomes support and vice versa). A valid retest requires:

Price touched the zone within the configured retest window
Price bounced off the zone by at least Min Retest Reaction × ATR
Bounce close is on the right side of the zone

A queue tracks up to 6 broken zones in parallel — so retests of zones broken several signals ago aren't lost.
6. Trade lifecycle
When risk management is enabled and a signal fires (and no position is currently active), an entry is taken at the close of the signal bar. SL is placed using your configured preset (ATR-based or zone-aware). Three TPs are spaced at R-multiples of the SL distance.

The trade is tracked bar-by-bar:

Each TP fires once (first-touch latching)
After TP1, SL trails to break-even (configurable)
Trade closes when SL is hit, TP3 is hit, or (in intraday mode) the force-close time is reached
A 1/3 + 1/3 + 1/3 partition model computes realized R-multiple at close


Abbreviations explained
Abbrev
Meaning
S/R
Support / Resistance
VWSR
Volume-Weighted Support / Resistance
ATR
Average True Range — a volatility measure
EMA
Exponential Moving Average
HTF
Higher Timeframe (e.g., when chart is 5m, HTF might be 1H)
SL
Stop Loss — the price at which you accept the trade is wrong
TP
Take Profit (TP1, TP2, TP3 = three profit targets)
BE
Break-Even — SL moved to entry price after TP1
R
Risk unit — distance from entry to original SL
R:R
Risk-to-Reward ratio
W/L
Wins / Losses
CT
Counter-Trend (signal direction conflicts with HTF trend)
F&O
Futures & Options
CE / PE
Call / Put (Indian markets terminology)
OHLC
Open, High, Low, Close



Settings groups walkthrough
⚙️ Main Settings — Pivot Lookback, Max Active Zones, Zone Merge Distance, Min Score to Display.

🎯 Instrument Preset — Auto-detect (recommended) identifies Index vs Single Stock from the ticker. Indices use looser volume filters; single stocks get tighter defaults with gap-day protection.

📈 HTF Trend Filter — Two-EMA trend classifier on a higher timeframe. Counter-trend signals get tagged ⚠. Can flag or hard-block counter-trend entries.

🕒 Session & Expiry — Configurable session window (timezone-aware). Optional weekly expiry-day filter for derivatives traders.

🌙 Intraday-Only Mode — Entry cutoff time and force-close time. Useful for strict day-traders who want an automatic guardrail.

📦 Zone Detection — ATR length, volume lookback, reaction window, age decay, max zone age.

🔍 Filters — Volume floor, volume cap (gap protection), momentum filter, mitigation filter, close-past-zone filter.

🎯 Signals — Toggle Break/Retest signals, configure retest window, set minimum retest reaction.

🛡️ Risk Management — Choose preset or Custom. Presets:

Conservative: SL 2.5×ATR, TP 1R/2R/4R
Balanced (default): SL 1.5×ATR, TP 1R/2R/3R
Aggressive: SL 1.0×ATR, TP 1.5R/2.5R/4R
Scalping: SL 0.8×ATR, TP 0.8R/1.5R/2R

💰 Money Manager — Account capital, per-trade risk %, daily loss cap %, currency symbol, number notation, lot-aware sizing.

🎨 Visual — Theme, zone visibility, label visibility, watermark, font sizes.

📊 Dashboard — Toggle, position, stats display, reset counter.

🔔 Alerts — Toggle per-event alerts. JSON webhook format available for automation.


Visual elements on the chart
Zones — Price-anchored colored boxes extending to the right edge of the chart. Resistance zones in the bear color, support zones in the bull color. Fill opacity reflects conviction tier — ●●●●● Elite zones are bold and solid; ●●○○○ Weak zones are faint and transparent. Zones move naturally with the chart in all directions.

Zone labels — Dot-scale conviction badge, numeric score, touch count, and broken flag. Examples:

●●●○○ 45 — medium zone, score 45
●●●●● 91 ×3 — elite zone with 3 touches
●●●●○ 67 ✕ — strong zone that has been broken

Break ▲ / Break ▼ markers — Labels at the signal candle. Bullish breaks appear below the bar pointing up; bearish breaks above the bar pointing down. Counter-trend breaks tinted amber with ⚠.

Retest ▲ / Retest ▼ markers — Same style as breaks but for retest signals.

Force-close markers — ⏰ FORCE CLOSE on the bar where the intraday cutoff fired.

SL/TP/Entry lines — Five lines from the entry bar: Entry (dotted blue), SL (solid red, dims to translucent when BE active), TP1/TP2/TP3 (dashed green, turns solid cyan with ✓ on hit). Labels show price, % distance from entry, and optional money risk.

Dashboard — Live state table including zone trend, HTF trend, signal, score, active zone count, session status, live trade levels, risk metrics, daily P&L, and lifetime stats.


Recommended usage
Day-trading (5m–15m chart): Lookback 5–10, HTF 60 or 240, Intraday-only ON, Balanced or Scalping preset.

Swing trading (1H–4H chart): Lookback 10–15, HTF D, Intraday-only OFF, Conservative or Balanced preset.

Position trading (D chart): Lookback 15–25, HTF W, Intraday-only OFF, Conservative preset.

Indices (NIFTY, BankNIFTY, SPX, NDX etc.): Use Auto-detect or Index preset. Volume filters auto-relax. HTF filter is especially useful — indices respect macro trends more consistently than individual stocks.

Single stocks: Use Auto-detect or Single Stock preset. Gap-day protection on. Volume cap prevents false breaks on news spikes.


Alerts
All alerts are bar-close based (no intra-bar firing). Available events:

🟢 Break ▲ / 🔴 Break ▼
🟢 Retest ▲ / 🔴 Retest ▼
🛑 SL Hit / 🛡️ Break-Even Stop-Out
🎯 TP1 Hit / TP2 Hit / TP3 Hit
🛡️ Break-Even Activated
⏰ Intraday Force-Close
🚫 Daily Loss Cap Hit
⚠ Counter-Trend Signal

Toggle JSON webhook format for automation pipelines. Each break/retest alert includes ticker, price, score, SL, TP1/TP2/TP3, R:R, and counter-trend flag.


Notes on data assumptions
No repaint — signals confirm on bar close. HTF trend uses lookahead_off so the HTF reference never includes future data.
No backtest engine — the W/L stats are based on the indicator's own simulated entries. Useful for sanity-checking parameters, not for performance verification. Run a proper strategy backtest before sizing real money.
Money tracking is theoretical — P&L is computed as R-multiple × per-trade money risk. It does not model slippage, commissions, taxes, or option premium decay.


Disclaimer
This is a technical analysis tool, not financial advice. The signals and risk levels generated are based on historical price action and the indicator's own logic; they do not predict future results. Past performance of any signal pattern does not guarantee future performance. Trading involves substantial risk of loss. Use this tool to structure your own decisions, not to replace them. Always size positions according to your risk tolerance and verify levels independently before acting.



VWSR Zones — Acrofins Edition · v2.0.0 · Acrofins (Kiva Financial Services Pvt. Ltd.)

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════════
// VOLUME-WEIGHTED S/R ZONES — Acrofins Edition
// ══════════════════════════════════════════════════════════════════════
// A scoring-based support/resistance engine. Pivots are weighted by
// volume and the size of the price reaction that followed them, then
// clustered into zones. Zones decay with age, merge with nearby
// re-tests, and produce break and retest signals with a built-in
// risk-management overlay (SL/TP/break-even) and a trade dashboard.
//
// FEATURES
//   • Volume-weighted pivot scoring with age decay
//   • Adaptive zone clustering with ATR-padded merge
//   • Multi-candidate break detection (highest-scored zone wins)
//   • Retest queue — tracks multiple pending retests, not just the latest
//   • Higher-timeframe trend filter with optional counter-trend block
//   • Configurable risk management — ATR-based or zone-aware SL,
//     three TPs, break-even trail after TP1
//   • Currency-aware money manager — per-trade risk, daily loss cap,
//     P&L tracking in your preferred currency and notation
//   • Optional intraday-only mode — auto-blocks late entries and
//     force-closes positions before session end
//   • Session and expiry-day filters (fully configurable timezone)
//   • Instrument auto-detect (index vs single-stock) with adaptive
//     volume-filter defaults
//   • Persistent statistics (win rate, average R, BE saves) that
//     survive intra-session input edits
//   • Theme-adaptive colors with WCAG AA contrast on both light and
//     dark backgrounds
//
// COMPATIBILITY
//   Works on any market and timeframe with OHLC data. Volume-based
//   features auto-degrade gracefully on instruments without volume
//   data (forex spot, some CFDs).
// ══════════════════════════════════════════════════════════════════════
indicator(
     title             = "VWSR Zones — Acrofins Edition",
     shorttitle        = "VWSR Acro",
     overlay           = true,
     max_lines_count   = 500,
     max_labels_count  = 500,
     max_boxes_count   = 500,
     max_bars_back     = 5000)

// ══════════════════════════════════════════════════════════════════════
// CONSTANTS
// ══════════════════════════════════════════════════════════════════════
GRP_MAIN     = "⚙️ Main Settings"
GRP_INSTR    = "🎯 Instrument Preset"
GRP_HTF      = "📈 HTF Trend Filter"
GRP_SESSION  = "🕒 Session & Expiry"
GRP_INTRADAY = "🌙 Intraday-Only Mode"
GRP_ZONE     = "📦 Zone Detection"
GRP_FILTER   = "🔍 Filters (optional)"
GRP_SIGNAL   = "🎯 Signals"
GRP_RISK     = "🛡️ Risk Management"
GRP_MONEY    = "💰 Money Manager"
GRP_VISUAL   = "🎨 Visual"
GRP_DASH     = "📊 Dashboard"
GRP_ALERT    = "🔔 Alerts"
GRP_COLORS   = "🎨 Colors"

INDICATOR_VERSION = "Acrofins v2.0.0"

// Score tier thresholds
SCORE_WEAK_MAX   = 30.0
SCORE_MED_MAX    = 60.0
SCORE_STRONG_MAX = 85.0

LINE_FORWARD_BARS = 20
LABEL_OFFSET_BARS = 1
LINE_UPDATE_BARS  = 5

ZONE_HALF_ATR     = 0.15
ZONE_BORDER_WIDTH = 1

MERGE_BASE_WEIGHT  = 0.3
MERGE_TOUCH_FACTOR = 4.0

MIN_VIABLE_SCORE = 5.0
ENTRY_BAR_HOLD   = 1
WARMUP_BUFFER    = 5

// Retest queue capacity — number of broken zones tracked for pending retest
RETEST_QUEUE_CAP = 6

// ══════════════════════════════════════════════════════════════════════
// INPUTS — MAIN
// ══════════════════════════════════════════════════════════════════════
lookbackInput = input.int(21, "Pivot Lookback", minval = 2, maxval = 30, group = GRP_MAIN, tooltip = "Bars on each side of a pivot point.\n• 3-5: scalping/intraday\n• 5-10: swing\n• 10+: position trading")
maxZonesInput = input.int(8,  "Max Active Zones", minval = 2, maxval = 20, group = GRP_MAIN)
mergeAtrInput = input.float(0.5, "Zone Merge Distance (×ATR)", minval = 0.1, maxval = 3.0, step = 0.1, group = GRP_MAIN)
minScoreInput = input.float(15.0, "Min Score to Display", minval = 0.0, maxval = 100.0, step = 5.0, group = GRP_MAIN)

// ══════════════════════════════════════════════════════════════════════
// INPUTS — INSTRUMENT PRESET
// ══════════════════════════════════════════════════════════════════════
// Auto-swaps default filter behavior based on instrument type. Index
// volume on most data feeds is derived (constituent or futures volume)
// and behaves differently from cash-equity volume — looser defaults
// avoid false rejections. Single-stock keeps the original tighter
// filters with gap-day protection enabled.
instrumentPresetInput = input.string("Auto-detect", "Instrument Type",
     options = ["Auto-detect", "Index / Futures", "Single Stock", "Manual"], group = GRP_INSTR,
     tooltip = "Auto-detect: looks at the ticker — common index tickers (SPX, NDX, DJI, RUT, FTSE, DAX, NIKKEI, HSI, NIFTY, SENSEX, BANKNIFTY, etc.) treated as Index.\nIndex preset: looser volume filters, no volume cap.\nSingle Stock preset: tighter filters, gap-day protection on.\nManual: use the filter inputs below as-is.")

// ══════════════════════════════════════════════════════════════════════
// INPUTS — HTF TREND FILTER
// ══════════════════════════════════════════════════════════════════════
// A higher-timeframe trend reference. Signals that fire against the HTF
// trend get tagged "Counter-trend" — useful as a discretionary filter
// or to hard-block entries against the larger trend.
useHtfTrendInput     = input.bool(true,    "Enable HTF Trend Filter",          group = GRP_HTF, tooltip = "When enabled, the indicator computes trend on a higher timeframe and tags signals against that trend as 'Counter-trend'.")
htfPeriodInput       = input.timeframe("60", "Higher Timeframe",               group = GRP_HTF, tooltip = "Trend reference TF.\n• On 1m/5m chart → use 60 (1H)\n• On 15m chart → use 240 (4H)\n• On 1H chart → use D\n• On D chart → use W")
htfFastEmaInput      = input.int(20,   "HTF Fast EMA", minval = 5, maxval = 100, group = GRP_HTF)
htfSlowEmaInput      = input.int(50,   "HTF Slow EMA", minval = 10, maxval = 200, group = GRP_HTF)
htfBlockEntriesInput = input.bool(false, "Block Counter-Trend Entries",        group = GRP_HTF, tooltip = "OFF (default): counter-trend signals still trigger entries but are visually flagged.\nON: counter-trend signals are blocked entirely.")
htfFlagCeBiasInput   = input.bool(true,  "Flag Counter-Trend Bull Signals",    group = GRP_HTF, tooltip = "Tags bullish BRK ▲ / RT ▲ markers with a ⚠ symbol when HTF trend is bearish. Bearish counter-trend signals are always flagged.")

// ══════════════════════════════════════════════════════════════════════
// INPUTS — SESSION & EXPIRY
// ══════════════════════════════════════════════════════════════════════
// Timezone for all time-of-day inputs in this group. Defaults to the
// chart's exchange timezone (`syminfo.timezone`) so the input HHMM
// values match exchange clock times without manual conversion. Override
// if you want absolute UTC or your local time.
timezoneInput         = input.string("Exchange", "Timezone", options = ["Exchange", "UTC", "America/New_York", "Europe/London", "Europe/Berlin", "Asia/Tokyo", "Asia/Hong_Kong", "Asia/Singapore", "Asia/Kolkata", "Australia/Sydney"], group = GRP_SESSION, tooltip = "Timezone used for session window, expiry cutoff, and intraday-only cutoffs. 'Exchange' = the chart symbol's listing exchange timezone (e.g. America/New_York for NYSE/NASDAQ).")
useSessionFilterInput = input.bool(true, "Restrict to Trading Session",        group = GRP_SESSION, tooltip = "Suppress signals outside the configured session window. Useful for filtering pre-market, after-hours, or overnight noise on continuously-traded instruments.")
sessionStartInput     = input.session("0930-1600", "Session Window (HHMM-HHMM, selected TZ)", group = GRP_SESSION, tooltip = "Default 09:30–16:00 = typical equity cash session. Examples:\n• NYSE/NASDAQ: 0930-1600 (ET)\n• LSE: 0800-1630 (London)\n• NSE/BSE: 0915-1530 (IST)\n• TSE: 0900-1500 (Tokyo)")
skipFirstNMinInput    = input.int(0, "Skip First N Minutes After Open",        minval = 0, maxval = 60, group = GRP_SESSION, tooltip = "Additional buffer after session start. 0 = no extra skip. Useful for skipping open-auction volatility.")

// Optional weekly-expiry filter — suppresses signals on a chosen
// weekday after a cutoff time. Useful for derivatives traders on
// markets with weekly options expiry (any major index futures market).
useExpiryFilterInput  = input.bool(false, "Suppress Signals on Expiry Afternoon", group = GRP_SESSION, tooltip = "Useful for derivatives traders: on the configured weekly expiry day, suppress new signals after the cutoff time. Avoids settlement-driven price action.\nDefault OFF since most markets don't need this; enable if you trade weekly index options.")
expiryDayInput        = input.string("Thursday", "Weekly Expiry Day",            options = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"], group = GRP_SESSION, tooltip = "Common weekly-options expiry days: Thursday (NSE), Friday (CME/CBOE), Wednesday (some EU). Check your exchange.")
expiryCutoffInput     = input.int(1430, "Expiry Cutoff Time (HHMM, selected TZ)", minval = 0, maxval = 2359, group = GRP_SESSION, tooltip = "Signals suppressed after this time on expiry day. Default 14:30.")

// ══════════════════════════════════════════════════════════════════════
// INPUTS — INTRADAY-ONLY MODE
// ══════════════════════════════════════════════════════════════════════
// Two cutoffs: blocks new entries after the first time and force-closes
// any open position at the second time. Useful for day-traders who
// don't want overnight exposure — particularly bought options where
// time decay hits hard once the next session opens.
useIntradayOnlyInput   = input.bool(false, "Intraday-Only Mode",                  group = GRP_INTRADAY, tooltip = "Behavior when enabled:\n1. Blocks NEW entries after the Entry Cutoff time\n2. At Force-Close time, marks any open position as FORCED CLOSE and fires an alert\n3. Closes the position in the indicator's internal tracking so stats remain honest\n\nDefault OFF; enable for strict intraday strategies.")
entryCutoffTimeInput   = input.int(1515, "  Block New Entries After (HHMM, selected TZ)", minval = 0, maxval = 2359, group = GRP_INTRADAY, tooltip = "After this time, BRK/RT signals are still drawn on the chart but ignored by risk management (no SL/TP lines, no stat tracking).")
forceCloseTimeInput    = input.int(1545, "  Force-Close Open Positions At (HHMM, selected TZ)", minval = 0, maxval = 2359, group = GRP_INTRADAY, tooltip = "Open positions are marked closed at the candle whose time matches or exceeds this. Give yourself a buffer before actual session close to allow execution time.")

// ══════════════════════════════════════════════════════════════════════
// INPUTS — ZONE DETECTION
// ══════════════════════════════════════════════════════════════════════
atrLenInput       = input.int(14, "ATR Length",          minval = 5,  maxval = 50,  group = GRP_ZONE)
volLookbackInput  = input.int(20, "Volume Avg Lookback", minval = 5,  maxval = 100, group = GRP_ZONE)
reactionBarsInput = input.int(5,  "Reaction Window (bars)", minval = 2, maxval = 20, group = GRP_ZONE)
ageDecayInput     = input.float(0.5, "Age Decay Rate", minval = 0.0, maxval = 1.0, step = 0.05, group = GRP_ZONE)
maxAgeValueInput  = input.int(30,  "Max Zone Age (Value)", minval = 1, maxval = 10000, group = GRP_ZONE)
maxAgeUnitInput   = input.string("Days", "Max Zone Age (Unit)", options = ["Bars", "Hours", "Days"], group = GRP_ZONE)

// ══════════════════════════════════════════════════════════════════════
// INPUTS — FILTERS
// ══════════════════════════════════════════════════════════════════════
useVolFilterInput  = input.bool(false, "Volume Filter for Breaks",   group = GRP_FILTER)
volMultInput       = input.float(1.3, "  Volume Multiplier", minval = 1.0, maxval = 5.0, step = 0.1, group = GRP_FILTER)
useVolCapInput     = input.bool(true,  "  Volume Cap (gap protection)",  group = GRP_FILTER)
volCapInput        = input.float(5.0,  "    Volume Cap Multiplier", minval = 2.0, maxval = 20.0, step = 0.5, group = GRP_FILTER)
useMomFilterInput  = input.bool(false, "Momentum Filter for Breaks", group = GRP_FILTER)
momMultInput       = input.float(1.0, "  Momentum Multiplier (×ATR)", minval = 0.3, maxval = 3.0, step = 0.1, group = GRP_FILTER)
useMitigationInput = input.bool(false, "Mitigation Filter for Retests", group = GRP_FILTER)
// [F7] NEW: require close past zone by % of ATR — filters wick-breaks.
useCloseConfInput  = input.bool(true,  "Require Close Past Zone (×ATR)", group = GRP_FILTER, tooltip = "[NEW v2] Filters wick breaks. Requires close to exceed zone edge by at least this × ATR.\n0 = original behavior (any close past zone).\n0.1 = mild filter (default).\n0.25 = strict.")
closeConfAtrInput  = input.float(0.10, "  Close-Past-Zone Distance (×ATR)", minval = 0.0, maxval = 1.0, step = 0.05, group = GRP_FILTER)

// ══════════════════════════════════════════════════════════════════════
// INPUTS — SIGNALS
// ══════════════════════════════════════════════════════════════════════
showBreaksInput    = input.bool(true,  "Show Break Signals",   group = GRP_SIGNAL)
showRetestsInput   = input.bool(true,  "Show Retest Signals",  group = GRP_SIGNAL)
retestMinBarsInput = input.int(2,  "Min Bars Before Retest",   minval = 1, maxval = 50,  group = GRP_SIGNAL)
retestMaxBarsInput = input.int(30, "Max Bars for Retest",      minval = 5, maxval = 200, group = GRP_SIGNAL)
reactionMinInput   = input.float(0.5, "Min Retest Reaction (×ATR)", minval = 0.1, maxval = 3.0, step = 0.1, group = GRP_SIGNAL)

// ══════════════════════════════════════════════════════════════════════
// INPUTS — RISK MANAGEMENT
// ══════════════════════════════════════════════════════════════════════
useRiskInput        = input.bool(true, "Enable Risk Management", group = GRP_RISK)
riskPresetInput     = input.string("Balanced", "Risk Preset", options = ["Conservative", "Balanced", "Aggressive", "Scalping", "Custom"], group = GRP_RISK)
slMultInput         = input.float(1.5, "  SL ×ATR (Custom)",   minval = 0.5, maxval = 5.0,  step = 0.1, group = GRP_RISK)
tp1MultInput        = input.float(1.0, "  TP1 ×Risk (Custom)", minval = 0.5, maxval = 5.0,  step = 0.1, group = GRP_RISK)
tp2MultInput        = input.float(2.0, "  TP2 ×Risk (Custom)", minval = 1.0, maxval = 10.0, step = 0.1, group = GRP_RISK)
tp3MultInput        = input.float(3.0, "  TP3 ×Risk (Custom)", minval = 1.5, maxval = 15.0, step = 0.1, group = GRP_RISK)
useZoneSLInput      = input.bool(true, "Zone-Aware SL", group = GRP_RISK)
// [F8] NEW: zone-SL behavior is now switchable. Defensive default is
// "wider" — more breathing room, matches the user's documented leak
// of "weak SLs".
zoneSLBehaviorInput = input.string("Wider (more room)", "  Zone-SL Behavior",
     options = ["Wider (more room)", "Tighter (closer to entry)"],
     group = GRP_RISK, tooltip = "[NEW v2]\nWider: SL = whichever of (ATR-SL, zone-SL) is FURTHER from entry. Defensive default — gives trades room.\nTighter: SL = whichever is CLOSER to entry (original v1.4.3 behavior). Smaller R risk but stops out more.")
useBreakEvenInput   = input.bool(true, "Break-Even After TP1", group = GRP_RISK)
showSlTpInput       = input.bool(true, "Show SL/TP Lines",  group = GRP_RISK)
showSlTpLabelsInput = input.bool(true, "Show SL/TP Labels", group = GRP_RISK)
showPctOnLabelsInput= input.bool(true, "Show % Distance on Labels", group = GRP_RISK)
entryLineStyleInput = input.string("Dotted", "Entry Line Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_RISK)
slLineStyleInput    = input.string("Solid",  "SL Line Style",    options = ["Solid", "Dashed", "Dotted"], group = GRP_RISK)
tpLineStyleInput    = input.string("Dashed", "TP Line Style",    options = ["Solid", "Dashed", "Dotted"], group = GRP_RISK)

// ══════════════════════════════════════════════════════════════════════
// INPUTS — MONEY MANAGER
// ══════════════════════════════════════════════════════════════════════
// Currency-aware risk tracking. Set your account capital and per-trade
// risk %; the indicator computes money-at-risk per signal, tracks
// session and daily realized P&L, and blocks new entries when a daily
// loss cap is hit. Currency symbol and number notation are
// configurable so the dashboard reads naturally in any locale.
useRupeeRiskInput      = input.bool(true,    "Enable Money Manager", group = GRP_MONEY)
currencySymbolInput    = input.string("$",   "  Currency Symbol", options = ["$", "€", "£", "¥", "₹", "₽", "₩", "A$", "C$", "Fr", "kr"], group = GRP_MONEY, tooltip = "Symbol shown on all money-amount labels and dashboard cells.")
notationStyleInput     = input.string("Western (K / M / B)", "  Number Notation", options = ["Western (K / M / B)", "Indian (K / L / Cr)", "Plain (no abbreviation)"], group = GRP_MONEY, tooltip = "Western: 1,000 → 1K, 1,000,000 → 1M, 1,000,000,000 → 1B (US/UK convention).\nIndian: 1,000 → 1K, 100,000 → 1L (lakh), 10,000,000 → 1Cr (crore).\nPlain: full digits, no abbreviation.")
capitalInput           = input.float(10000,  "  Active Trading Capital", minval = 100, group = GRP_MONEY, tooltip = "Account capital deployed on this strategy. Used as the base for per-trade risk and daily loss cap calculations.")
perTradeRiskInput      = input.float(1.0,    "  Per-Trade Risk (% of capital)", minval = 0.1, maxval = 10.0, step = 0.1, group = GRP_MONEY)
dailyLossCapInput      = input.float(2.0,    "  Daily Loss Cap (% of capital)", minval = 0.5, maxval = 20.0, step = 0.5, group = GRP_MONEY, tooltip = "Once realized loss for the day reaches this %, new entries are BLOCKED until next session.")
showRupeeOnLabelsInput = input.bool(true,    "  Show Risk Amount on SL Label", group = GRP_MONEY)
useLotSizeInput        = input.bool(false,   "  Lot-Aware Sizing", group = GRP_MONEY, tooltip = "For futures and options trading: computes risk per lot/contract using the lot size below. Off for cash equity.")
lotSizeInput           = input.int(100,      "    Lot Size / Contract Multiplier", minval = 1, maxval = 100000, group = GRP_MONEY, tooltip = "Examples:\n• ES (E-mini S&P 500): 50\n• NQ (E-mini Nasdaq): 20\n• CL (Crude): 1000\n• Equity options (US): 100\n• NIFTY: 75 (verify current with exchange)\n• BANKNIFTY: 15 (verify current with exchange)\nVerify with your broker / exchange — contract specs change.")

// ══════════════════════════════════════════════════════════════════════
// INPUTS — VISUAL
// ══════════════════════════════════════════════════════════════════════
themeInput          = input.string("Auto", "Theme", options = ["Auto", "Dark", "Light"], group = GRP_VISUAL)
showZonesInput      = input.bool(true, "Show Zones",             group = GRP_VISUAL)
showZoneLabelsInput = input.bool(true, "Show Zone Score Labels", group = GRP_VISUAL)
showWatermarkInput  = input.bool(true, "Show Watermark",         group = GRP_VISUAL)
zoneForwardBarsInput = input.int(5, "Zone Forward Bars", minval = 0, maxval = 100, group = GRP_VISUAL)
labelFontSizeInput  = input.string("Small", "SL/TP Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = GRP_VISUAL)
signalFontSizeInput = input.string("Small", "Signal Marker Size (BRK/RT)", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = GRP_VISUAL)

// ══════════════════════════════════════════════════════════════════════
// INPUTS — DASHBOARD
// ══════════════════════════════════════════════════════════════════════
showDashInput   = input.bool(true, "Show Dashboard", group = GRP_DASH)
dashPosStr      = input.string("Top Right", "Position", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Middle Right"], group = GRP_DASH)
showStatsInput  = input.bool(true, "Show Trade Stats (W/L)", group = GRP_DASH)
// [F10] NEW: edge-triggered reset button. Stats persist via varip and
// only reset when this integer changes value (not on every input edit).
resetStatsInput = input.int(0, "Reset Stats (change value to reset)", minval = 0, maxval = 999, group = GRP_DASH)

// ══════════════════════════════════════════════════════════════════════
// INPUTS — COLORS
// ══════════════════════════════════════════════════════════════════════
bullColorInput = input.color(#00E676, "Support (Demand)",    inline = "c1", group = GRP_COLORS)
bearColorInput = input.color(#FF5252, "Resistance (Supply)", inline = "c1", group = GRP_COLORS)
counterTrendColorInput = input.color(#FFB300, "Counter-Trend Tag", group = GRP_COLORS, tooltip = "Color used for ⚠ counter-trend signal tags.")

// ══════════════════════════════════════════════════════════════════════
// INPUTS — ALERTS
// ══════════════════════════════════════════════════════════════════════
webhookInput       = input.bool(false, "Webhook JSON Format", group = GRP_ALERT)
alertOnBreakInput  = input.bool(true,  "Alert on Breaks",  group = GRP_ALERT)
alertOnRetestInput = input.bool(true,  "Alert on Retests", group = GRP_ALERT)
alertOnSlHitInput  = input.bool(false, "Alert on SL Hit",  group = GRP_ALERT)
alertOnTpHitInput  = input.bool(false, "Alert on TP Hits", group = GRP_ALERT)
alertOnForceCloseInput   = input.bool(true, "Alert on Force-Close",          group = GRP_ALERT)
alertOnDailyCapInput     = input.bool(true, "Alert on Daily Loss Cap Hit",   group = GRP_ALERT)
alertOnCounterTrendInput = input.bool(false, "Alert on Counter-Trend Signal", group = GRP_ALERT)

// ══════════════════════════════════════════════════════════════════════
// THEME & COLOR PALETTE
// ══════════════════════════════════════════════════════════════════════
isDark = switch themeInput
    "Dark"  => true
    "Light" => false
    =>         color.r(chart.bg_color) < 128

TEXT_COLOR   = isDark ? #E0E0E0 : #1A1A1A
TEXT_MUTED   = isDark ? color.new(#9E9E9E, 0) : color.new(#757575, 0)
BULL_TEXT    = isDark ? #00E676 : #00695C
BEAR_TEXT    = isDark ? #FF5252 : #D32F2F
NEUTRAL_TEXT = isDark ? #FFEB3B : #BF360C

BULL_LABEL_TEXT = #004D25
BEAR_LABEL_TEXT = #1A1A1A
ZONE_BULL_LABEL_TEXT = isDark ? #FFFFFF : #004D25
ZONE_BEAR_LABEL_TEXT = isDark ? #FFFFFF : #1A1A1A

TABLE_BG     = isDark ? color.new(#131722, 5) : color.new(#FFFFFF, 5)
TABLE_BORDER = isDark ? color.new(#2A2E39, 0) : color.new(#D0D0D0, 0)
HEADER_BG    = color.new(#1565C0, 0)
HEADER_TEXT  = #FFFFFF
WM_COLOR     = isDark ? color.new(#FFFFFF, 80) : color.new(#000000, 80)

SL_COLOR     = isDark ? color.new(#EF5350, 0)  : color.new(#C62828, 0)
TP1_COLOR    = isDark ? color.new(#4CAF50, 25) : color.new(#2E7D32, 25)
TP2_COLOR    = isDark ? color.new(#4CAF50, 35) : color.new(#2E7D32, 35)
TP3_COLOR    = isDark ? color.new(#4CAF50, 0)  : color.new(#2E7D32, 0)
ENTRY_COLOR  = isDark ? color.new(#42A5F5, 0)  : color.new(#1565C0, 0)
TP_LABEL_COLOR = isDark ? color.new(#4CAF50, 0) : color.new(#2E7D32, 0)
TP_HIT_COLOR   = isDark ? color.new(#26C6DA, 0) : color.new(#00838F, 0)
BE_COLOR       = isDark ? color.new(#FFA726, 0) : color.new(#704214, 0)
LABEL_TEXT     = isDark ? #1A1A1A : #FFFFFF

dashPos = switch dashPosStr
    "Top Left"     => position.top_left
    "Top Right"    => position.top_right
    "Bottom Left"  => position.bottom_left
    "Bottom Right" => position.bottom_right
    "Middle Right" => position.middle_right
    =>                position.top_right

lineStyleFromString(string s) =>
    switch s
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        =>          line.style_solid

entryLineStyle = lineStyleFromString(entryLineStyleInput)
slLineStyle    = lineStyleFromString(slLineStyleInput)
tpLineStyle    = lineStyleFromString(tpLineStyleInput)

// ══════════════════════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════════════════════
safeDiv(float num, float den, float fallback = 0.0) =>
    den != 0 and not na(num) and not na(den) ? num / den : fallback

sizeFromString(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.small

formatPctFromEntry(float level, float entry) =>
    string res = ""
    if showPctOnLabelsInput and not na(level) and not na(entry) and entry != 0
        float pct = (level - entry) / entry * 100.0
        string sign = pct >= 0 ? "+" : ""
        res := " (" + sign + str.tostring(pct, "#.##") + "%)"
    res

scoreToTransp(float score) =>
    score >= SCORE_STRONG_MAX ? 40 : score >= SCORE_MED_MAX ? 58 : score >= SCORE_WEAK_MAX ? 73 : 88
    

scoreToTier(float score) =>
    score >= SCORE_STRONG_MAX ? "●●●●●" : score >= SCORE_MED_MAX ? "●●●●○" : score >= SCORE_WEAK_MAX ? "●●●○○" : "●●○○○"
    

// Format money amounts using the user-configured currency symbol and
// notation style. Examples:
//   Western:  12500 → "$12.5K", 1_250_000 → "$1.25M", 1.25e9 → "$1.25B"
//   Indian:   12500 → "₹12.5K", 125000 → "₹1.25L", 12500000 → "₹1.25Cr"
//   Plain:    12500 → "$12,500" (with thousands separator)
formatRupee(float amount) =>
    string res = ""
    if not na(amount)
        float abs_a = math.abs(amount)
        string sign = amount < 0 ? "-" : ""
        string sym  = currencySymbolInput
        if notationStyleInput == "Indian (K / L / Cr)"
            if abs_a >= 10000000.0
                res := sign + sym + str.tostring(abs_a / 10000000.0, "#.##") + "Cr"
            else if abs_a >= 100000.0
                res := sign + sym + str.tostring(abs_a / 100000.0, "#.##") + "L"
            else if abs_a >= 1000.0
                res := sign + sym + str.tostring(abs_a / 1000.0, "#.#") + "K"
            else
                res := sign + sym + str.tostring(abs_a, "#")
        else if notationStyleInput == "Western (K / M / B)"
            if abs_a >= 1000000000.0
                res := sign + sym + str.tostring(abs_a / 1000000000.0, "#.##") + "B"
            else if abs_a >= 1000000.0
                res := sign + sym + str.tostring(abs_a / 1000000.0, "#.##") + "M"
            else if abs_a >= 1000.0
                res := sign + sym + str.tostring(abs_a / 1000.0, "#.#") + "K"
            else
                res := sign + sym + str.tostring(abs_a, "#")
        else  // Plain
            res := sign + sym + str.tostring(abs_a, "#,###")
    res

// ══════════════════════════════════════════════════════════════════════
// TIMEZONE RESOLUTION
// ══════════════════════════════════════════════════════════════════════
// Single resolved string used by every time-of-day filter below.
// "Exchange" = the chart symbol's listing exchange timezone, which is
// usually what traders mean when they say "9:30 AM" or "3:30 PM".
string tzResolved = timezoneInput == "Exchange" ? syminfo.timezone : timezoneInput

// ══════════════════════════════════════════════════════════════════════
// INSTRUMENT PRESET RESOLUTION
// ══════════════════════════════════════════════════════════════════════
// Auto-detect inspects the ticker for common index substrings across
// major global exchanges. Implemented as a helper function with one
// boolean per line — avoids Pine v6's occasional bracket-confusion on
// long multi-line `or` chains.
isIndexTicker(string tkr) =>
    bool found = false
    if str.contains(tkr, "NIFTY")
        found := true
    if str.contains(tkr, "SENSEX")
        found := true
    if str.contains(tkr, "SPX")
        found := true
    if str.contains(tkr, "SPY")
        found := true
    if str.contains(tkr, "NDX")
        found := true
    if str.contains(tkr, "QQQ")
        found := true
    if str.contains(tkr, "DJI")
        found := true
    if str.contains(tkr, "DIA")
        found := true
    if str.contains(tkr, "RUT")
        found := true
    if str.contains(tkr, "IWM")
        found := true
    if str.contains(tkr, "FTSE")
        found := true
    if str.contains(tkr, "DAX")
        found := true
    if str.contains(tkr, "CAC")
        found := true
    if str.contains(tkr, "STOXX")
        found := true
    if str.contains(tkr, "NIKKEI")
        found := true
    if str.contains(tkr, "N225")
        found := true
    if str.contains(tkr, "HSI")
        found := true
    if str.contains(tkr, "KOSPI")
        found := true
    if str.contains(tkr, "TSX")
        found := true
    if str.contains(tkr, "ASX")
        found := true
    if str.contains(tkr, "BANKNIFTY")
        found := true
    if str.contains(tkr, "FINNIFTY")
        found := true
    found

string _tkr       = str.upper(syminfo.ticker)
bool _tickerMatch = isIndexTicker(_tkr)
bool _typeMatch   = syminfo.type == "index" or syminfo.type == "futures"
bool _autoIsIndex = _tickerMatch or _typeMatch

string resolvedPreset = switch instrumentPresetInput
    "Auto-detect"      => _autoIsIndex ? "Index" : "Stock"
    "Index / Futures"  => "Index"
    "Single Stock"     => "Stock"
    "Manual"           => "Manual"
    =>                    "Manual"

// Effective filter values after preset override:
//   Index: looser — disable volume cap (index vol is derived), widen vol multiplier floor
//   Stock: stays at user-input values (which default to the original v1.4.3 safe defaults)
//   Manual: pass through user inputs
bool effVolCap = resolvedPreset == "Index" ? false : useVolCapInput
float effVolMult = resolvedPreset == "Index" ? math.min(volMultInput, 1.1) : volMultInput

// ══════════════════════════════════════════════════════════════════════
// HTF TREND FILTER [G1]
// ══════════════════════════════════════════════════════════════════════
// Compute fast & slow EMA on a higher timeframe, then classify:
//   htfTrendDir = +1 (bullish), -1 (bearish), 0 (neutral)
// Uses request.security with lookahead_off + barmerge.gaps_off — the
// standard safe pattern; never returns future data.
float htfClose = request.security(syminfo.tickerid, htfPeriodInput, close, lookahead = barmerge.lookahead_off)
float htfFast  = request.security(syminfo.tickerid, htfPeriodInput, ta.ema(close, htfFastEmaInput), lookahead = barmerge.lookahead_off)
float htfSlow  = request.security(syminfo.tickerid, htfPeriodInput, ta.ema(close, htfSlowEmaInput), lookahead = barmerge.lookahead_off)

// Compute HTF trend direction via explicit if-else chain. Avoids the
// nested-ternary type-inference issues that Pine v6 sometimes hits
// when a ternary's branches mix simple/series-int return types.
int htfTrendDir = 0
if useHtfTrendInput and not na(htfFast) and not na(htfSlow)
    if htfClose > htfSlow and htfFast > htfSlow
        htfTrendDir := 1
    else if htfClose < htfSlow and htfFast < htfSlow
        htfTrendDir := -1

string htfTrendStr = htfTrendDir == 1 ? "Bullish" : htfTrendDir == -1 ? "Bearish" : "Neutral"
color  htfTrendCol = htfTrendDir == 1 ? BULL_TEXT : htfTrendDir == -1 ? BEAR_TEXT : NEUTRAL_TEXT

// ══════════════════════════════════════════════════════════════════════
// SESSION & EXPIRY FILTERS [G5, G6]
// ══════════════════════════════════════════════════════════════════════
// inSession: true when bar's time falls inside configured session window.
// Pine's time(timeframe, session, timezone) returns a number when in
// session, na otherwise. Computed via an if-block instead of inline
// ternary to keep types unambiguous for the v6 compiler.
bool inSession = true
if useSessionFilterInput
    int _t = time(timeframe.period, sessionStartInput, tzResolved)
    inSession := not na(_t)

// Parse "HHMM-HHMM" session string → start HHMM. str.substring returns
// string; str.tonumber returns float; cast to int. Each step on its own
// line so the type at each stage is unambiguous.
string _startStr   = str.substring(sessionStartInput, 0, 4)
float  _startFlt   = str.tonumber(_startStr)
float  _startSafe  = na(_startFlt) ? 920.0 : _startFlt
int    _sessStartHHMM = int(_startSafe)

int _curHHMM   = hour(time, tzResolved) * 100 + minute(time, tzResolved)
int _curHr     = _curHHMM / 100
int _curMin    = _curHHMM % 100
int _startHr   = _sessStartHHMM / 100
int _startMin  = _sessStartHHMM % 100
int _minutesIntoSession = (_curHr - _startHr) * 60 + (_curMin - _startMin)

bool postOpenBuffer = true
if useSessionFilterInput and skipFirstNMinInput > 0
    postOpenBuffer := _minutesIntoSession >= skipFirstNMinInput

bool sessionPass = inSession and postOpenBuffer

// Expiry-day filter.
int _expiryDow = switch expiryDayInput
    "Monday"    => dayofweek.monday
    "Tuesday"   => dayofweek.tuesday
    "Wednesday" => dayofweek.wednesday
    "Thursday"  => dayofweek.thursday
    "Friday"    => dayofweek.friday
    =>             dayofweek.thursday
bool isExpiryDay = dayofweek(time, tzResolved) == _expiryDow
bool expiryBlock = useExpiryFilterInput and isExpiryDay and _curHHMM >= expiryCutoffInput
bool expiryPass  = not expiryBlock

// ══════════════════════════════════════════════════════════════════════
// INTRADAY-ONLY MODE [G2]
// ══════════════════════════════════════════════════════════════════════
bool intradayEntryBlocked = useIntradayOnlyInput and _curHHMM >= entryCutoffTimeInput
bool intradayForceClose   = useIntradayOnlyInput and _curHHMM >= forceCloseTimeInput

// Combined entry-gate: signals can be drawn but entries are gated.
bool entriesAllowed = sessionPass and expiryPass and not intradayEntryBlocked

// ══════════════════════════════════════════════════════════════════════
// BASE SERIES
// ══════════════════════════════════════════════════════════════════════
float atrVal     = nz(ta.atr(atrLenInput), 0.0)
float volAvgPrev = nz(ta.sma(volume[1], volLookbackInput), 0.0)
// [F3] hasVolume now a SERIES, not a scalar — evaluated per-bar so that
// historical bars with zero volume are correctly identified inside score
// functions that index with [offset].
bool  hasVolume  = nz(volume, 0.0) > 0

int  WARMUP_BARS = math.max(lookbackInput + reactionBarsInput, math.max(atrLenInput, volLookbackInput)) + lookbackInput + WARMUP_BUFFER
bool isWarmedUp  = bar_index >= WARMUP_BARS

float _tfSeconds = timeframe.in_seconds()
int  maxAgeBars = switch maxAgeUnitInput
    "Bars"  => maxAgeValueInput
    "Hours" => _tfSeconds > 0 ? int(math.max(1.0, maxAgeValueInput * 3600.0  / _tfSeconds)) : 500
    "Days"  => _tfSeconds > 0 ? int(math.max(1.0, maxAgeValueInput * 86400.0 / _tfSeconds)) : 500
    =>         500

// ══════════════════════════════════════════════════════════════════════
// PIVOT DETECTION
// ══════════════════════════════════════════════════════════════════════
float ph = ta.pivothigh(high, lookbackInput, lookbackInput)
float pl = ta.pivotlow (low,  lookbackInput, lookbackInput)
bool newPH = not na(ph)
bool newPL = not na(pl)
int pivotBarOffset = lookbackInput

// ══════════════════════════════════════════════════════════════════════
// SCORE FUNCTIONS
// ══════════════════════════════════════════════════════════════════════
// [F3] calcVolScore now reads hasVolume[offset] not scalar hasVolume.
// [F3] calcVolScore now reads hasVolume[offset] not scalar hasVolume.
calcVolScore(int offset) =>
    float result   = 20.0
    float pivotVol = nz(volume[offset], 0.0)
    float avgV     = nz(volAvgPrev[offset], 0.0)
    bool  hv       = hasVolume[offset]
    if hv and avgV > 0
        float ratio = safeDiv(pivotVol, avgV, 1.0)
        result := math.min(40.0, math.max(0.0, ratio * 20.0))
    result

calcReactionScore(int offset, float pivotPrice, bool isResistance) =>
    float maxMove = 0.0
    int   loopEnd = math.min(reactionBarsInput, offset)
    for i = 1 to loopEnd
        float ext = isResistance ? nz(low[offset - i], pivotPrice) : nz(high[offset - i], pivotPrice)
        float move = isResistance ? (pivotPrice - ext) : (ext - pivotPrice)
        if move > maxMove
            maxMove := move
    float atrAtPivot = nz(atrVal[offset], atrVal)
    float moveAtr = safeDiv(maxMove, atrAtPivot, 0.0)
    math.min(30.0, math.max(0.0, moveAtr * 10.0))

// ══════════════════════════════════════════════════════════════════════
// ZONE STORAGE
// ══════════════════════════════════════════════════════════════════════
var array<float> zoneTops      = array.new<float>()
var array<float> zoneBots      = array.new<float>()
var array<float> zoneScores    = array.new<float>()
var array<int>   zoneCreated   = array.new<int>()
var array<int>   zoneTypes     = array.new<int>()
var array<int>   zoneTouches   = array.new<int>()
var array<bool>  zoneBroken    = array.new<bool>()
var array<int>   zoneBrokenBar = array.new<int>()
var array<box>   zoneBoxes     = array.new<box>()
var array<label> zoneLabels    = array.new<label>()

// ══════════════════════════════════════════════════════════════════════
// ADD PIVOT  [F1, F2]
// ══════════════════════════════════════════════════════════════════════
// [F1] Merge expansion now uses ATR-padded bounds, matching how the
//      zone was first created. No more silent shrinkage on re-touches.
// [F2] Merge picks the CLOSEST zone (min distance), not the first match.
addPivot(float price, int zType, int barOffset) =>
    float vScore     = calcVolScore(barOffset)
    float rScore     = calcReactionScore(barOffset, price, zType == 1)
    float baseScore  = vScore + rScore + 10.0
    float mergeDist  = atrVal * mergeAtrInput
    int   pivotBar   = bar_index - barOffset
    float halfAtr    = atrVal * ZONE_HALF_ATR

    // [F2] Find closest matching zone — full scan, min distance.
    int   mergeIdx = -1
    float bestDist = mergeDist + 1.0  // start above the threshold
    int   sz = array.size(zoneTops)
    if sz > 0
        for i = 0 to sz - 1
            if array.get(zoneTypes, i) == zType and not array.get(zoneBroken, i)
                float midZone = (array.get(zoneTops, i) + array.get(zoneBots, i)) / 2.0
                float d = math.abs(midZone - price)
                if d <= mergeDist and d < bestDist
                    bestDist := d
                    mergeIdx := i

    if mergeIdx >= 0
        float curTop = array.get(zoneTops, mergeIdx)
        float curBot = array.get(zoneBots, mergeIdx)
        // [F1] Padded expansion — new edge is at most price + halfAtr
        // (resistance) or at least price - halfAtr (support).
        float newTop = math.max(curTop, price + halfAtr)
        float newBot = math.min(curBot, price - halfAtr)
        array.set(zoneTops, mergeIdx, newTop)
        array.set(zoneBots, mergeIdx, newBot)
        int   curTouch  = array.get(zoneTouches, mergeIdx)
        int   newTouch  = curTouch + 1
        float touchBon  = math.min(20.0, math.sqrt(newTouch) * MERGE_TOUCH_FACTOR)
        float curScore  = array.get(zoneScores, mergeIdx)
        array.set(zoneScores,  mergeIdx, math.min(100.0, curScore + baseScore * MERGE_BASE_WEIGHT + touchBon * 0.5))
        array.set(zoneTouches, mergeIdx, newTouch)
    else
        box   nullBox = na
        label nullLbl = na
        array.push(zoneTops,      price + halfAtr)
        array.push(zoneBots,      price - halfAtr)
        array.push(zoneScores,    math.min(100.0, baseScore))
        array.push(zoneCreated,   pivotBar)
        array.push(zoneTypes,     zType)
        array.push(zoneTouches,   1)
        array.push(zoneBroken,    false)
        array.push(zoneBrokenBar, 0)
        array.push(zoneBoxes,     nullBox)
        array.push(zoneLabels,    nullLbl)
    0

if barstate.isconfirmed and isWarmedUp
    if newPH
        addPivot(ph, 1, pivotBarOffset)
    if newPL
        addPivot(pl, -1, pivotBarOffset)

// ══════════════════════════════════════════════════════════════════════
// AGE DECAY & CLEANUP
// ══════════════════════════════════════════════════════════════════════
if barstate.isconfirmed and array.size(zoneTops) > 0
    float decayPerBar = ageDecayInput * 0.1
    for i = array.size(zoneTops) - 1 to 0
        if i < array.size(zoneTops)
            if decayPerBar > 0
                float newScr = math.max(0.0, array.get(zoneScores, i) - decayPerBar)
                array.set(zoneScores, i, newScr)
            int   age = bar_index - array.get(zoneCreated, i)
            float scr = array.get(zoneScores, i)
            bool broken = array.get(zoneBroken, i)
            int   barsSinceBreak = broken ? bar_index - array.get(zoneBrokenBar, i) : 0
            bool tooOld      = age > maxAgeBars
            bool tooWeak     = scr < MIN_VIABLE_SCORE
            bool brokenStale = broken and barsSinceBreak > retestMaxBarsInput * 2
            if tooOld or tooWeak or brokenStale
                box   b = array.get(zoneBoxes,  i)
                label l = array.get(zoneLabels, i)
                if not na(b)
                    box.delete(b)
                if not na(l)
                    label.delete(l)
                array.remove(zoneTops,      i)
                array.remove(zoneBots,      i)
                array.remove(zoneScores,    i)
                array.remove(zoneCreated,   i)
                array.remove(zoneTypes,     i)
                array.remove(zoneTouches,   i)
                array.remove(zoneBroken,    i)
                array.remove(zoneBrokenBar, i)
                array.remove(zoneBoxes,     i)
                array.remove(zoneLabels,    i)

if barstate.isconfirmed
    int trimSafetyMax = maxZonesInput * 3
    int trimSafety = 0
    while array.size(zoneTops) > maxZonesInput and trimSafety < trimSafetyMax
        float minScr = 999.0
        int   minIdx = 0
        for i = 0 to array.size(zoneScores) - 1
            float s = array.get(zoneScores, i)
            if s < minScr
                minScr := s
                minIdx := i
        box   bm = array.get(zoneBoxes,  minIdx)
        label lm = array.get(zoneLabels, minIdx)
        if not na(bm)
            box.delete(bm)
        if not na(lm)
            label.delete(lm)
        array.remove(zoneTops,      minIdx)
        array.remove(zoneBots,      minIdx)
        array.remove(zoneScores,    minIdx)
        array.remove(zoneCreated,   minIdx)
        array.remove(zoneTypes,     minIdx)
        array.remove(zoneTouches,   minIdx)
        array.remove(zoneBroken,    minIdx)
        array.remove(zoneBrokenBar, minIdx)
        array.remove(zoneBoxes,     minIdx)
        array.remove(zoneLabels,    minIdx)
        trimSafety += 1

// ══════════════════════════════════════════════════════════════════════
// RETEST QUEUE [F4]
// ══════════════════════════════════════════════════════════════════════
// [F4] Replaces upstream's single `lastBreakDir / lastBreakZoneTop` vars
// with an array of pending retests. Capacity = RETEST_QUEUE_CAP. Each
// slot holds: zone bounds, direction, break bar, score, retested-flag.
var array<float> rqZoneTops    = array.new<float>()
var array<float> rqZoneBots    = array.new<float>()
var array<int>   rqDirs        = array.new<int>()
var array<int>   rqBreakBars   = array.new<int>()
var array<float> rqScores      = array.new<float>()
var array<bool>  rqRetested    = array.new<bool>()

// ══════════════════════════════════════════════════════════════════════
// BREAK & RETEST DETECTION  [F6, F7]
// ══════════════════════════════════════════════════════════════════════
bool sigBreakBull  = false
bool sigBreakBear  = false
bool sigRetestBull = false
bool sigRetestBear = false

// Used by entry block and alerts for the most recent break/retest.
float lastBreakZoneTop = na
float lastBreakZoneBot = na
float lastBreakScore   = 0.0
int   lastBreakDir     = 0

bool volFloorPass = useVolFilterInput  ? (hasVolume and volume >= volAvgPrev * effVolMult) : true
bool volCapPass   = (useVolFilterInput and effVolCap) ? (volAvgPrev > 0 and volume <= volAvgPrev * volCapInput) : true
bool volPass      = volFloorPass and volCapPass
bool momPass = useMomFilterInput ? ((high - low) >= atrVal * momMultInput) : true

// [F7] Close-confirmation distance — close must exceed zone edge by
// X × ATR to count as a real break. closeConfDist = 0 reproduces
// original behavior.
float closeConfDist = useCloseConfInput ? atrVal * closeConfAtrInput : 0.0

// [F6] When multiple zones break the same bar, collect ALL candidates
// then pick by score, not by iteration order. Tracks best bull and
// best bear separately; final winner = higher-scored of the two.
float bestBullBreakScore = -1.0
float bestBearBreakScore = -1.0
int   bestBullIdx = -1
int   bestBearIdx = -1

if barstate.isconfirmed and isWarmedUp and array.size(zoneTops) > 0
    for i = 0 to array.size(zoneTops) - 1
        if not array.get(zoneBroken, i)
            float zTop  = array.get(zoneTops, i)
            float zBot  = array.get(zoneBots, i)
            int   zType = array.get(zoneTypes, i)
            float zScore = array.get(zoneScores, i)
            // Bullish break: close above resistance zone top by at least closeConfDist
            if zType == 1 and close > zTop + closeConfDist and close[1] <= zTop and volPass and momPass
                if zScore > bestBullBreakScore
                    bestBullBreakScore := zScore
                    bestBullIdx := i
            // Bearish break: close below support zone bottom by at least closeConfDist
            else if zType == -1 and close < zBot - closeConfDist and close[1] >= zBot and volPass and momPass
                if zScore > bestBearBreakScore
                    bestBearBreakScore := zScore
                    bestBearIdx := i

// Apply the chosen break(s). [F6] If both fire, the higher-scored one wins.
if bestBullIdx >= 0 and (bestBearIdx < 0 or bestBullBreakScore >= bestBearBreakScore)
    array.set(zoneBroken, bestBullIdx, true)
    array.set(zoneBrokenBar, bestBullIdx, bar_index)
    lastBreakZoneTop := array.get(zoneTops, bestBullIdx)
    lastBreakZoneBot := array.get(zoneBots, bestBullIdx)
    lastBreakScore   := bestBullBreakScore
    lastBreakDir     := 1
    sigBreakBull     := true
    // Push to retest queue
    if array.size(rqDirs) >= RETEST_QUEUE_CAP
        array.shift(rqZoneTops)
        array.shift(rqZoneBots)
        array.shift(rqDirs)
        array.shift(rqBreakBars)
        array.shift(rqScores)
        array.shift(rqRetested)
    array.push(rqZoneTops, lastBreakZoneTop)
    array.push(rqZoneBots, lastBreakZoneBot)
    array.push(rqDirs, 1)
    array.push(rqBreakBars, bar_index)
    array.push(rqScores, lastBreakScore)
    array.push(rqRetested, false)
else if bestBearIdx >= 0
    array.set(zoneBroken, bestBearIdx, true)
    array.set(zoneBrokenBar, bestBearIdx, bar_index)
    lastBreakZoneTop := array.get(zoneTops, bestBearIdx)
    lastBreakZoneBot := array.get(zoneBots, bestBearIdx)
    lastBreakScore   := bestBearBreakScore
    lastBreakDir     := -1
    sigBreakBear     := true
    if array.size(rqDirs) >= RETEST_QUEUE_CAP
        array.shift(rqZoneTops)
        array.shift(rqZoneBots)
        array.shift(rqDirs)
        array.shift(rqBreakBars)
        array.shift(rqScores)
        array.shift(rqRetested)
    array.push(rqZoneTops, lastBreakZoneTop)
    array.push(rqZoneBots, lastBreakZoneBot)
    array.push(rqDirs, -1)
    array.push(rqBreakBars, bar_index)
    array.push(rqScores, lastBreakScore)
    array.push(rqRetested, false)

// [F4] Retest detection — scan the queue, fire on each valid retest.
// Also evicts stale entries past retestMaxBarsInput.
if barstate.isconfirmed and isWarmedUp and array.size(rqDirs) > 0
    for i = array.size(rqDirs) - 1 to 0
        if i < array.size(rqDirs)
            int   qDir = array.get(rqDirs, i)
            int   qBar = array.get(rqBreakBars, i)
            int   barsSince = bar_index - qBar
            float qTop = array.get(rqZoneTops, i)
            float qBot = array.get(rqZoneBots, i)
            float qScr = array.get(rqScores, i)
            bool  qRet = array.get(rqRetested, i)
            // Evict stale
            if barsSince > retestMaxBarsInput
                array.remove(rqZoneTops, i)
                array.remove(rqZoneBots, i)
                array.remove(rqDirs, i)
                array.remove(rqBreakBars, i)
                array.remove(rqScores, i)
                array.remove(rqRetested, i)
            else
                bool inWindow = barsSince >= retestMinBarsInput and barsSince <= retestMaxBarsInput
                bool mitigationOk = useMitigationInput ? not qRet : true
                if inWindow and mitigationOk
                    if qDir == 1
                        bool touched = low <= qTop
                        bool bounced = close > qTop and (close - low) >= atrVal * reactionMinInput
                        if touched and bounced and not sigRetestBull
                            array.set(rqRetested, i, true)
                            sigRetestBull := true
                            lastBreakZoneTop := qTop
                            lastBreakZoneBot := qBot
                            lastBreakScore   := qScr
                            lastBreakDir     := 1
                    else
                        bool touched = high >= qBot
                        bool bounced = close < qBot and (high - close) >= atrVal * reactionMinInput
                        if touched and bounced and not sigRetestBear
                            array.set(rqRetested, i, true)
                            sigRetestBear := true
                            lastBreakZoneTop := qTop
                            lastBreakZoneBot := qBot
                            lastBreakScore   := qScr
                            lastBreakDir     := -1

bool finalBullSignal = (showBreaksInput and sigBreakBull) or (showRetestsInput and sigRetestBull)
bool finalBearSignal = (showBreaksInput and sigBreakBear) or (showRetestsInput and sigRetestBear)
float signalScore = (sigRetestBull or sigRetestBear or sigBreakBull or sigBreakBear) ? lastBreakScore : 0.0

// Counter-trend tagging [G1]: a bull signal when HTF trend is bearish
// (or bear signal when HTF is bullish) is counter-trend.
bool isCounterTrendBull = useHtfTrendInput and (sigBreakBull or sigRetestBull) and htfTrendDir == -1
bool isCounterTrendBear = useHtfTrendInput and (sigBreakBear or sigRetestBear) and htfTrendDir == 1
bool isCounterTrend     = isCounterTrendBull or isCounterTrendBear

// ══════════════════════════════════════════════════════════════════════
// RISK MANAGEMENT
// ══════════════════════════════════════════════════════════════════════
[effSLMult, effTP1, effTP2, effTP3] = switch riskPresetInput
    "Conservative" => [2.5, 1.0, 2.0, 4.0]
    "Aggressive"   => [1.0, 1.5, 2.5, 4.0]
    "Scalping"     => [0.8, 0.8, 1.5, 2.0]
    "Custom"       => [slMultInput, tp1MultInput, tp2MultInput, tp3MultInput]
    =>                [1.5, 1.0, 2.0, 3.0]

var float activeEntry    = na
var float activeSL       = na
var float activeTP1      = na
var float activeTP2      = na
var float activeTP3      = na
var int   activeDir      = 0
var float activeRR       = 0.0
var int   activeEntryBar = 0
var bool  activeIsCounterTrend = false  // tagged at entry, used in alerts/dash

var bool tp1Reached = false
var bool tp2Reached = false
var bool tp3Reached = false
var bool beActive   = false

var float activeTP1Mult = 0.0
var float activeTP2Mult = 0.0
var float activeTP3Mult = 0.0

// [F9, F10] Stats persisted via `varip` — survive intra-session input
// changes. Reset is gated by an edge-triggered comparison on
// resetStatsInput (the input itself is a counter; reset fires when its
// value changes from one bar to the next).
varip int   statsWins    = 0
varip int   statsLosses  = 0
varip int   statsBeSaves = 0
varip float statsRSum    = 0.0
varip int   statsForceClosed = 0  // [G2] count of intraday force-closes
// ₹ tracking — varip so daily P&L persists across bars within session
varip float statsRupeePnL = 0.0     // session-cumulative realized ₹
varip int   statsRupeeDay = 0       // day-of-month marker for daily-reset detection
varip float dailyRupeePnL = 0.0     // today's realized ₹ (resets each new trading day)
varip int   lastResetCounter = 0    // edge-trigger memory for reset button

// Edge-triggered reset
if resetStatsInput != lastResetCounter
    statsWins := 0
    statsLosses := 0
    statsBeSaves := 0
    statsRSum := 0.0
    statsForceClosed := 0
    statsRupeePnL := 0.0
    dailyRupeePnL := 0.0
    lastResetCounter := resetStatsInput

// New trading day → reset dailyRupeePnL
int curDayOfYear = month(time, tzResolved) * 100 + dayofmonth(time, tzResolved)
if curDayOfYear != statsRupeeDay
    dailyRupeePnL := 0.0
    statsRupeeDay := curDayOfYear

// ₹ risk per trade (computed before entry) — used both for entry sizing
// labels and for translating R-multiples into ₹ on close.
float rupeePerTradeRisk = useRupeeRiskInput ? capitalInput * perTradeRiskInput / 100.0 : 0.0
float dailyRupeeLossCap = useRupeeRiskInput ? capitalInput * dailyLossCapInput / 100.0 : 0.0

// [G3] Daily-cap block: when today's realized P&L is at or below
// -dailyRupeeLossCap, block new entries until next day.
bool dailyCapHit = useRupeeRiskInput and dailyRupeePnL <= -dailyRupeeLossCap

// Detect daily-cap-just-hit transition (for alert)
varip bool dailyCapAlertedToday = false
if curDayOfYear != statsRupeeDay or not dailyCapHit
    dailyCapAlertedToday := false
bool dailyCapJustHit = dailyCapHit and not dailyCapAlertedToday

// Final gate for entries — combines all filters.
bool canEnterNew = entriesAllowed and not dailyCapHit and not (useHtfTrendInput and htfBlockEntriesInput and isCounterTrend)

if useRiskInput and isWarmedUp and barstate.isconfirmed and activeDir == 0 and canEnterNew
    bool takeBull = finalBullSignal and not (finalBearSignal and lastBreakDir == -1)
    bool takeBear = finalBearSignal and not (finalBullSignal and lastBreakDir == 1)
    takeBear := takeBear and not takeBull
    if takeBull
        activeEntry := close
        activeDir   := 1
        activeEntryBar := bar_index
        tp1Reached := false
        tp2Reached := false
        tp3Reached := false
        beActive   := false
        activeIsCounterTrend := isCounterTrendBull
        activeTP1Mult := effTP1
        activeTP2Mult := effTP2
        activeTP3Mult := effTP3
        float slDist = atrVal * effSLMult
        if useZoneSLInput and not na(lastBreakZoneBot)
            float zoneSL = lastBreakZoneBot - atrVal * 0.2
            float atrSL  = close - slDist
            // [F8] Wider = math.min (further from entry, more room).
            // Tighter = math.max (closer to entry, original behavior).
            activeSL := zoneSLBehaviorInput == "Wider (more room)" ? math.min(atrSL, zoneSL) : math.max(atrSL, zoneSL)
            slDist := math.abs(activeEntry - activeSL)
        else
            activeSL := activeEntry - slDist
        activeTP1 := activeEntry + slDist * effTP1
        activeTP2 := activeEntry + slDist * effTP2
        activeTP3 := activeEntry + slDist * effTP3
        activeRR  := effTP1
    else if takeBear
        activeEntry := close
        activeDir   := -1
        activeEntryBar := bar_index
        tp1Reached := false
        tp2Reached := false
        tp3Reached := false
        beActive   := false
        activeIsCounterTrend := isCounterTrendBear
        activeTP1Mult := effTP1
        activeTP2Mult := effTP2
        activeTP3Mult := effTP3
        float slDist = atrVal * effSLMult
        if useZoneSLInput and not na(lastBreakZoneTop)
            float zoneSL = lastBreakZoneTop + atrVal * 0.2
            float atrSL  = close + slDist
            // [F8] For short, "wider" = further from entry = higher value = math.max.
            activeSL := zoneSLBehaviorInput == "Wider (more room)" ? math.max(atrSL, zoneSL) : math.min(atrSL, zoneSL)
            slDist := math.abs(activeSL - activeEntry)
        else
            activeSL := activeEntry + slDist
        activeTP1 := activeEntry - slDist * effTP1
        activeTP2 := activeEntry - slDist * effTP2
        activeTP3 := activeEntry - slDist * effTP3
        activeRR  := effTP1

float effectiveSL = activeSL

bool canHit = barstate.isconfirmed and activeDir != 0 and (bar_index - activeEntryBar) >= ENTRY_BAR_HOLD
bool slHit  = canHit and (activeDir == 1 ? low  <= effectiveSL : high >= effectiveSL)
bool tp1Hit = canHit and (activeDir == 1 ? high >= activeTP1   : low  <= activeTP1)
bool tp2Hit = canHit and (activeDir == 1 ? high >= activeTP2   : low  <= activeTP2)
bool tp3Hit = canHit and (activeDir == 1 ? high >= activeTP3   : low  <= activeTP3)

bool tp1FirstTouch = tp1Hit and not tp1Reached and not slHit and activeDir != 0
bool tp2FirstTouch = tp2Hit and not tp2Reached and not slHit and activeDir != 0
bool tp3FirstTouch = tp3Hit and not tp3Reached and not slHit and activeDir != 0

if tp1FirstTouch
    tp1Reached := true
if tp2FirstTouch
    tp2Reached := true
if tp3FirstTouch
    tp3Reached := true

bool beActiveAtBarStart = beActive

bool beJustActivated = false
if useBreakEvenInput and tp1FirstTouch and not beActive
    activeSL := activeEntry
    beActive := true
    beJustActivated := true

// [G2] Intraday force-close
bool forceClosedThisBar = activeDir != 0 and intradayForceClose and barstate.isconfirmed

float exitEntry = activeEntry
float exitSL    = effectiveSL
float exitTP1   = activeTP1
float exitTP2   = activeTP2
float exitTP3   = activeTP3
bool  exitBeActive = beActiveAtBarStart
float exitClose = close  // for force-close P&L calc
int   exitDir   = activeDir

if (slHit or tp3Hit or forceClosedThisBar) and activeDir != 0
    bool reachedTp1   = tp1Reached
    bool outcomeWin   = reachedTp1 and not forceClosedThisBar  // force-close treated as scratch/loss
    bool isBeSave     = reachedTp1 and slHit and beActiveAtBarStart and not forceClosedThisBar

    float tradeR = 0.0
    if forceClosedThisBar
        // [G2] Force-close: compute realized R from current price vs entry/SL distance.
        // Partition logic: 1/3 at any reached TP, remainder at close price.
        float slDistance = math.abs(activeEntry - effectiveSL)
        float closeMove  = exitDir == 1 ? (close - activeEntry) : (activeEntry - close)
        float closeR = safeDiv(closeMove, slDistance, 0.0)
        // Realized R = sum of TPs hit (1/3 each at their multiplier) + remainder at closeR
        float realizedHit = 0.0
        int   partsRemaining = 3
        if tp1Reached
            realizedHit += (1.0 / 3.0) * activeTP1Mult
            partsRemaining -= 1
        if tp2Reached
            realizedHit += (1.0 / 3.0) * activeTP2Mult
            partsRemaining -= 1
        if tp3Reached
            realizedHit += (1.0 / 3.0) * activeTP3Mult
            partsRemaining -= 1
        // Remainder closes at current price
        float remainderR = (partsRemaining / 3.0) * closeR
        tradeR := realizedHit + remainderR
        statsForceClosed += 1
        if tradeR > 0
            statsWins += 1
        else
            statsLosses += 1
    else if outcomeWin
        float r1 = (1.0 / 3.0) * activeTP1Mult
        float r2 = tp2Reached ? (1.0 / 3.0) * activeTP2Mult : 0.0
        float r3 = tp3Reached ? (1.0 / 3.0) * activeTP3Mult : 0.0
        tradeR := r1 + r2 + r3
        statsWins += 1
        if isBeSave
            statsBeSaves += 1
    else
        tradeR := -1.0
        statsLosses += 1
    statsRSum += tradeR

    // ₹ P&L update [G3]
    if useRupeeRiskInput
        float tradeRupee = tradeR * rupeePerTradeRisk
        statsRupeePnL += tradeRupee
        dailyRupeePnL += tradeRupee

    activeDir      := 0
    activeSL       := na
    activeTP1      := na
    activeTP2      := na
    activeTP3      := na
    activeEntry    := na
    activeRR       := 0.0
    activeEntryBar := 0
    activeIsCounterTrend := false
    tp1Reached     := false
    tp2Reached     := false
    tp3Reached     := false
    beActive       := false
    activeTP1Mult  := 0.0
    activeTP2Mult  := 0.0
    activeTP3Mult  := 0.0

// Daily-cap-just-hit detection (after potential P&L update)
if dailyCapHit and not dailyCapAlertedToday
    dailyCapAlertedToday := true

// ══════════════════════════════════════════════════════════════════════
// DRAW / UPDATE ZONE BOXES
// ══════════════════════════════════════════════════════════════════════
if (barstate.islast or barstate.isrealtime) and showZonesInput and array.size(zoneTops) > 0
    for i = 0 to array.size(zoneTops) - 1
        float scr = array.get(zoneScores, i)
        if scr >= minScoreInput
            float zTop = array.get(zoneTops, i)
            float zBot = array.get(zoneBots, i)
            int   zType = array.get(zoneTypes, i)
            int   zCreated = array.get(zoneCreated, i)
            bool  zBrk = array.get(zoneBroken, i)
            int   zTouches = array.get(zoneTouches, i)
            color baseColor = zType == 1 ? bearColorInput : bullColorInput
            int   transp = scoreToTransp(scr)
            color fillCol = color.new(baseColor, transp)
            int   borderTransp = math.max(0, transp - 30)
            color borderCol = color.new(baseColor, borderTransp)
            if zBrk
                fillCol   := color.new(baseColor, math.min(95, transp + 8))
                int bTr = math.min(85, math.max(0, transp - 10))
                borderCol := color.new(baseColor, bTr)
            box existingBox = array.get(zoneBoxes, i)
            if na(existingBox)
                box newBox = box.new(zCreated, zTop, bar_index + 1, zBot, border_color = borderCol, bgcolor = fillCol, border_width = ZONE_BORDER_WIDTH, extend = extend.right)
                array.set(zoneBoxes, i, newBox)
            else
                box.set_top(existingBox, zTop)
                box.set_bottom(existingBox, zBot)
                box.set_border_color(existingBox, borderCol)
                box.set_bgcolor(existingBox, fillCol)
                box.set_border_width(existingBox, ZONE_BORDER_WIDTH)
                box.set_extend(existingBox, extend.right)
            if showZoneLabelsInput
                string tier = scoreToTier(scr)
                string touchStr = zTouches > 1 ? " ×" + str.tostring(zTouches) : ""
                string brkStr   = zBrk ? " ✕" : ""
                string lblTxt = tier + " " + str.tostring(scr, "#") + brkStr + touchStr
                float lblY = zType == 1 ? zTop : zBot
                string lblStyle = zType == 1 ? label.style_label_lower_left : label.style_label_upper_left
                color lblTextCol = zType == 1 ? ZONE_BEAR_LABEL_TEXT : ZONE_BULL_LABEL_TEXT
                color lblBgCol   = color.new(baseColor, 50)
                label existingLbl = array.get(zoneLabels, i)
                if na(existingLbl)
                    label newLbl = label.new(bar_index, lblY, lblTxt, color = lblBgCol, textcolor = lblTextCol, style = lblStyle, size = size.small)
                    array.set(zoneLabels, i, newLbl)
                else
                    label.set_xy(existingLbl, bar_index, lblY)
                    label.set_text(existingLbl, lblTxt)
                    label.set_textcolor(existingLbl, lblTextCol)
                    label.set_color(existingLbl, lblBgCol)
                    label.set_style(existingLbl, lblStyle)
            else
                label existingLbl = array.get(zoneLabels, i)
                if not na(existingLbl)
                    label.delete(existingLbl)
                    label nullL1 = na
                    array.set(zoneLabels, i, nullL1)
        else
            box   b = array.get(zoneBoxes,  i)
            label l = array.get(zoneLabels, i)
            if not na(b)
                box.delete(b)
                box nullB2 = na
                array.set(zoneBoxes, i, nullB2)
            if not na(l)
                label.delete(l)
                label nullL2 = na
                array.set(zoneLabels, i, nullL2)

// ══════════════════════════════════════════════════════════════════════
// SIGNAL MARKERS  (with counter-trend tag [G1])
// ══════════════════════════════════════════════════════════════════════
bool isEntryBar = activeDir != 0 and activeEntryBar == bar_index
bool canShowSig = activeDir == 0 or isEntryBar
bool canShowBullSig = canShowSig and (not isEntryBar or activeDir == 1)
bool canShowBearSig = canShowSig and (not isEntryBar or activeDir == -1)

signalMarkerSize = sizeFromString(signalFontSizeInput)

// Counter-trend tag prefix
string ctTag = "⚠ "

if showBreaksInput and sigBreakBull and canShowBullSig
    string bullTxt = (isCounterTrendBull and htfFlagCeBiasInput ? ctTag : "") + "Break ▲"
    color  bullCol = isCounterTrendBull and htfFlagCeBiasInput ? counterTrendColorInput : bullColorInput
    label.new(bar_index, low, bullTxt, color = bullCol, textcolor = BULL_LABEL_TEXT, style = label.style_label_up, size = signalMarkerSize, yloc = yloc.belowbar)
if showBreaksInput and sigBreakBear and canShowBearSig
    string bearTxt = (isCounterTrendBear ? ctTag : "") + "Break ▼"
    color  bearCol = isCounterTrendBear ? counterTrendColorInput : bearColorInput
    label.new(bar_index, high, bearTxt, color = bearCol, textcolor = BEAR_LABEL_TEXT, style = label.style_label_down, size = signalMarkerSize, yloc = yloc.abovebar)
if showRetestsInput and sigRetestBull and canShowBullSig
    string bullTxt = (isCounterTrendBull and htfFlagCeBiasInput ? ctTag : "") + "Retest ▲"
    color  bullCol = isCounterTrendBull and htfFlagCeBiasInput ? counterTrendColorInput : bullColorInput
    label.new(bar_index, low, bullTxt, color = bullCol, textcolor = BULL_LABEL_TEXT, style = label.style_label_up, size = signalMarkerSize, yloc = yloc.belowbar)
if showRetestsInput and sigRetestBear and canShowBearSig
    string bearTxt = (isCounterTrendBear ? ctTag : "") + "Retest ▼"
    color  bearCol = isCounterTrendBear ? counterTrendColorInput : bearColorInput
    label.new(bar_index, high, bearTxt, color = bearCol, textcolor = BEAR_LABEL_TEXT, style = label.style_label_down, size = signalMarkerSize, yloc = yloc.abovebar)

// [G2] Force-close marker
if forceClosedThisBar
    label.new(bar_index, close, "⏰ FORCE CLOSE", color = NEUTRAL_TEXT, textcolor = LABEL_TEXT, style = exitDir == 1 ? label.style_label_down : label.style_label_up, size = signalMarkerSize, yloc = exitDir == 1 ? yloc.abovebar : yloc.belowbar)

// ══════════════════════════════════════════════════════════════════════
// SL/TP LINES & LABELS
// ══════════════════════════════════════════════════════════════════════
var line  slLine    = na
var line  tp1Line   = na
var line  tp2Line   = na
var line  tp3Line   = na
var line  entryLine = na
var label slLbl     = na
var label tp1Lbl    = na
var label tp2Lbl    = na
var label tp3Lbl    = na
var label entryLbl  = na
var bool  riskLinesActive = false

labelSize = sizeFromString(labelFontSizeInput)

if useRiskInput and showSlTpInput and isEntryBar
    if not na(slLine)
        line.delete(slLine)
    if not na(tp1Line)
        line.delete(tp1Line)
    if not na(tp2Line)
        line.delete(tp2Line)
    if not na(tp3Line)
        line.delete(tp3Line)
    if not na(entryLine)
        line.delete(entryLine)
    if not na(slLbl)
        label.delete(slLbl)
    if not na(tp1Lbl)
        label.delete(tp1Lbl)
    if not na(tp2Lbl)
        label.delete(tp2Lbl)
    if not na(tp3Lbl)
        label.delete(tp3Lbl)
    if not na(entryLbl)
        label.delete(entryLbl)
    int x2 = bar_index + LINE_FORWARD_BARS
    entryLine := line.new(bar_index, activeEntry, x2, activeEntry, color = ENTRY_COLOR, style = entryLineStyle, width = 1)
    slLine    := line.new(bar_index, activeSL,    x2, activeSL,    color = SL_COLOR,    style = slLineStyle,    width = 1)
    tp1Line   := line.new(bar_index, activeTP1,   x2, activeTP1,   color = TP1_COLOR,   style = tpLineStyle,    width = 1)
    tp2Line   := line.new(bar_index, activeTP2,   x2, activeTP2,   color = TP2_COLOR,   style = tpLineStyle,    width = 1)
    tp3Line   := line.new(bar_index, activeTP3,   x2, activeTP3,   color = TP3_COLOR,   style = tpLineStyle,    width = 1)
    if showSlTpLabelsInput
        int lblX = x2 + LABEL_OFFSET_BARS
        string entryS = str.tostring(activeEntry, format.mintick)
        // [G4] SL label optionally includes ₹ risk
        string slRupeeSuffix = (useRupeeRiskInput and showRupeeOnLabelsInput) ? " | " + formatRupee(rupeePerTradeRisk) : ""
        string slS    = str.tostring(activeSL,    format.mintick) + formatPctFromEntry(activeSL,  activeEntry) + slRupeeSuffix
        string tp1S   = str.tostring(activeTP1,   format.mintick) + formatPctFromEntry(activeTP1, activeEntry)
        string tp2S   = str.tostring(activeTP2,   format.mintick) + formatPctFromEntry(activeTP2, activeEntry)
        string tp3S   = str.tostring(activeTP3,   format.mintick) + formatPctFromEntry(activeTP3, activeEntry)
        // Counter-trend tag on entry label
        string entryPrefix = activeIsCounterTrend ? "⚠ ENTRY (CT) " : "ENTRY "
        color  entryColEff = activeIsCounterTrend ? counterTrendColorInput : ENTRY_COLOR
        entryLbl := label.new(lblX, activeEntry, entryPrefix + entryS, color = entryColEff, textcolor = LABEL_TEXT, style = label.style_label_left, size = labelSize)
        slLbl    := label.new(lblX, activeSL,    "SL "    + slS,    color = SL_COLOR,    textcolor = LABEL_TEXT, style = label.style_label_left, size = labelSize)
        tp1Lbl   := label.new(lblX, activeTP1,   "TP1 "   + tp1S,   color = TP_LABEL_COLOR, textcolor = LABEL_TEXT, style = label.style_label_left, size = labelSize)
        tp2Lbl   := label.new(lblX, activeTP2,   "TP2 "   + tp2S,   color = TP_LABEL_COLOR, textcolor = LABEL_TEXT, style = label.style_label_left, size = labelSize)
        tp3Lbl   := label.new(lblX, activeTP3,   "TP3 "   + tp3S,   color = TP_LABEL_COLOR, textcolor = LABEL_TEXT, style = label.style_label_left, size = labelSize)
    riskLinesActive := true

if useRiskInput and showSlTpInput and not na(tp1Line) and tp1Reached
    line.set_color(tp1Line, TP_HIT_COLOR)
    line.set_style(tp1Line, line.style_solid)
    if showSlTpLabelsInput and not na(tp1Lbl)
        label.set_text(tp1Lbl, "TP1 ✓ " + str.tostring(activeTP1, format.mintick) + formatPctFromEntry(activeTP1, activeEntry))
        label.set_color(tp1Lbl, TP_HIT_COLOR)
if useRiskInput and showSlTpInput and not na(tp2Line) and tp2Reached
    line.set_color(tp2Line, TP_HIT_COLOR)
    line.set_style(tp2Line, line.style_solid)
    if showSlTpLabelsInput and not na(tp2Lbl)
        label.set_text(tp2Lbl, "TP2 ✓ " + str.tostring(activeTP2, format.mintick) + formatPctFromEntry(activeTP2, activeEntry))
        label.set_color(tp2Lbl, TP_HIT_COLOR)
if useRiskInput and showSlTpInput and not na(tp3Line) and tp3Reached
    line.set_color(tp3Line, TP_HIT_COLOR)
    line.set_style(tp3Line, line.style_solid)
    if showSlTpLabelsInput and not na(tp3Lbl)
        label.set_text(tp3Lbl, "TP3 ✓ " + str.tostring(activeTP3, format.mintick) + formatPctFromEntry(activeTP3, activeEntry))
        label.set_color(tp3Lbl, TP_HIT_COLOR)

if useRiskInput and showSlTpInput and beActive and activeDir != 0
    if not na(slLine)
        line.set_color(slLine, color.new(SL_COLOR, 70))
    if showSlTpLabelsInput
        if not na(slLbl)
            label.set_color(slLbl, color.new(SL_COLOR, 70))
        if not na(entryLbl)
            string entryS = str.tostring(activeEntry, format.mintick)
            label.set_text(entryLbl, "ENTRY " + entryS + "  → SL (BE)")
            label.set_color(entryLbl, BE_COLOR)

if activeDir != 0
    riskLinesActive := true
if activeDir == 0 and riskLinesActive
    if not na(slLine)
        line.delete(slLine)
    if not na(tp1Line)
        line.delete(tp1Line)
    if not na(tp2Line)
        line.delete(tp2Line)
    if not na(tp3Line)
        line.delete(tp3Line)
    if not na(entryLine)
        line.delete(entryLine)
    if not na(slLbl)
        label.delete(slLbl)
    if not na(tp1Lbl)
        label.delete(tp1Lbl)
    if not na(tp2Lbl)
        label.delete(tp2Lbl)
    if not na(tp3Lbl)
        label.delete(tp3Lbl)
    if not na(entryLbl)
        label.delete(entryLbl)
    riskLinesActive := false

if activeDir != 0 and useRiskInput and showSlTpInput and not na(slLine)
    int newX2 = bar_index + LINE_UPDATE_BARS
    int newLblX = newX2 + LABEL_OFFSET_BARS
    line.set_x2(slLine,    newX2)
    line.set_x2(tp1Line,   newX2)
    line.set_x2(tp2Line,   newX2)
    line.set_x2(tp3Line,   newX2)
    line.set_x2(entryLine, newX2)
    if showSlTpLabelsInput and not na(slLbl)
        label.set_x(slLbl,    newLblX)
        label.set_x(tp1Lbl,   newLblX)
        label.set_x(tp2Lbl,   newLblX)
        label.set_x(tp3Lbl,   newLblX)
        label.set_x(entryLbl, newLblX)

// ══════════════════════════════════════════════════════════════════════
// DASHBOARD
// ══════════════════════════════════════════════════════════════════════
var float bullWeight = 0.0
var float bearWeight = 0.0
var float strongestScore = 0.0
var int   activeZoneCount = 0
var string trendStr = "Neutral"
var color  trendCol = na
var string sigStr   = "Wait"
var color  sigCol   = na
var string strStr   = "—"
var color  strCol   = na
var float  riskPct  = 0.0
var color  rrCol    = na
var color  riskCol  = na
var string dashSL   = "—"
var string dashTP1  = "—"
var string dashTP2  = "—"
var string dashTP3  = "—"
var string dashRR   = "—"
var string dashRsk  = "—"
var string zonesStr = "0 active"
var color  dashSlCol  = na
var color  dashTp1Col = na
var color  dashTp2Col = na
var color  dashTp3Col = na
var float  winRate   = 0.0
var float  avgR      = 0.0
var string dashTrades  = "0"
var string dashWL      = "0/0"
var string dashWinRate = "—"
var string dashBeSaves = "0"
var string dashAvgR    = "—"
var color  winRateCol  = na
var color  avgRCol     = na

if showDashInput and barstate.islast
    bullWeight     := 0.0
    bearWeight     := 0.0
    strongestScore := 0.0
    activeZoneCount := 0
    if array.size(zoneTops) > 0
        for i = 0 to array.size(zoneTops) - 1
            if not array.get(zoneBroken, i) and array.get(zoneScores, i) >= minScoreInput
                float zMid  = (array.get(zoneTops, i) + array.get(zoneBots, i)) / 2.0
                float s     = array.get(zoneScores, i)
                int   zType = array.get(zoneTypes, i)
                activeZoneCount += 1
                float dist = math.abs(zMid - close)
                // [F5] safeDiv used here
                float distRatio = safeDiv(dist, atrVal * 10.0, 1.0)
                float proximityFactor = math.max(0.1, 1.0 - math.min(1.0, distRatio))
                float weight = s * proximityFactor
                if zType == -1 and zMid < close
                    bullWeight += weight
                else if zType == 1 and zMid > close
                    bearWeight += weight
                if s > strongestScore
                    strongestScore := s
    trendStr := bullWeight > bearWeight * 1.2 ? "Bullish" : bearWeight > bullWeight * 1.2 ? "Bearish" : "Neutral"
    trendCol := bullWeight > bearWeight * 1.2 ? BULL_TEXT : bearWeight > bullWeight * 1.2 ? BEAR_TEXT : NEUTRAL_TEXT
    sigStr := sigBreakBull ? "BREAK ▲" : sigBreakBear ? "BREAK ▼" : sigRetestBull ? "RETEST ▲" : sigRetestBear ? "RETEST ▼" : activeDir == 1 ? "Long Active" : activeDir == -1 ? "Short Active" : "Wait"
    sigCol := (sigBreakBull or sigRetestBull or activeDir == 1) ? BULL_TEXT : (sigBreakBear or sigRetestBear or activeDir == -1) ? BEAR_TEXT : TEXT_MUTED
    strStr := signalScore > 0 ? str.tostring(signalScore, "#") + "/100" : str.tostring(strongestScore, "#") + "/100"
    strCol := signalScore >= SCORE_STRONG_MAX ? BULL_TEXT : signalScore >= SCORE_MED_MAX ? NEUTRAL_TEXT : TEXT_COLOR
    riskPct := activeDir != 0 and not na(activeEntry) and activeEntry != 0 and not na(activeSL) ? math.abs(activeEntry - activeSL) / activeEntry * 100.0 : 0.0
    rrCol   := activeRR >= 1.5 ? BULL_TEXT : activeRR >= 1.0 ? NEUTRAL_TEXT : BEAR_TEXT
    riskCol := riskPct > 3.0 ? BEAR_TEXT : riskPct > 1.0 ? NEUTRAL_TEXT : BULL_TEXT
    dashSL  := activeDir != 0 and not na(activeSL)  ? (beActive ? "BE @ " : "") + str.tostring(activeSL,  format.mintick) : "—"
    dashTP1 := activeDir != 0 and not na(activeTP1) ? (tp1Reached ? "✓ " : "") + str.tostring(activeTP1, format.mintick) : "—"
    dashTP2 := activeDir != 0 and not na(activeTP2) ? (tp2Reached ? "✓ " : "") + str.tostring(activeTP2, format.mintick) : "—"
    dashTP3 := activeDir != 0 and not na(activeTP3) ? (tp3Reached ? "✓ " : "") + str.tostring(activeTP3, format.mintick) : "—"
    dashRR  := activeDir != 0 ? str.tostring(activeRR, "#.#") + "R" : "—"
    dashRsk := activeDir != 0 ? str.tostring(riskPct, "#.##") + "%" : "—"
    zonesStr := str.tostring(activeZoneCount) + " active"
    dashSlCol  := beActive ? BE_COLOR : SL_COLOR
    dashTp1Col := tp1Reached ? TP_HIT_COLOR : TP_LABEL_COLOR
    dashTp2Col := tp2Reached ? TP_HIT_COLOR : TP_LABEL_COLOR
    dashTp3Col := tp3Reached ? TP_HIT_COLOR : TP_LABEL_COLOR
    int statsTotal = statsWins + statsLosses
    winRate    := statsTotal > 0 ? statsWins / float(statsTotal) * 100.0 : 0.0
    avgR       := statsTotal > 0 ? statsRSum / float(statsTotal) : 0.0
    dashTrades  := str.tostring(statsTotal)
    dashWL      := str.tostring(statsWins) + "/" + str.tostring(statsLosses)
    dashWinRate := statsTotal > 0 ? str.tostring(winRate, "#.#") + "%" : "—"
    dashBeSaves := statsWins > 0 ? str.tostring(statsBeSaves) + " (" + str.tostring(statsBeSaves / float(statsWins) * 100.0, "#") + "%)" : str.tostring(statsBeSaves)
    dashAvgR    := statsTotal > 0 ? str.tostring(avgR, "+0.00;-0.00") + "R" : "—"
    winRateCol := statsTotal == 0 ? TEXT_MUTED : winRate >= 55.0 ? BULL_TEXT : winRate >= 45.0 ? NEUTRAL_TEXT : BEAR_TEXT
    avgRCol    := statsTotal == 0 ? TEXT_MUTED : avgR > 0 ? BULL_TEXT : avgR < 0 ? BEAR_TEXT : TEXT_MUTED

// Pre-compute dashboard cell values used in the table render block.
// We do this regardless of showDashInput so the var bindings don't drift.
string dashHtfStr  = useHtfTrendInput ? htfTrendStr + " (" + htfPeriodInput + ")" : "Off"
color  dashHtfCol  = htfTrendCol
string dashSessionStr = sessionPass ? "✓ In session" : "✗ Out of session"
color  dashSessionCol = sessionPass ? BULL_TEXT : BEAR_TEXT
string dashIntradayStr = useIntradayOnlyInput ? (intradayEntryBlocked ? "🔒 Entries blocked" : "✓ Active") : "Off"
color  dashIntradayCol = useIntradayOnlyInput ? (intradayEntryBlocked ? NEUTRAL_TEXT : BULL_TEXT) : TEXT_MUTED
string dashDailyRupeeStr = useRupeeRiskInput ? formatRupee(dailyRupeePnL) : "Off"
color  dashDailyRupeeCol = useRupeeRiskInput ? (dailyRupeePnL > 0 ? BULL_TEXT : dailyRupeePnL < 0 ? BEAR_TEXT : TEXT_MUTED) : TEXT_MUTED
string dashRupeeCapStr   = useRupeeRiskInput ? (formatRupee(-dailyRupeeLossCap) + (dailyCapHit ? " 🚫" : "")) : "Off"
color  dashRupeeCapCol   = dailyCapHit ? BEAR_TEXT : TEXT_MUTED
string dashRupeeRiskStr  = useRupeeRiskInput ? formatRupee(rupeePerTradeRisk) : "Off"
// Multi-line ternary expanded into an if-block to keep Pine v6's type
// inference happy (it occasionally misparses ternaries spanning lines).
string dashLotRiskStr = "—"
if useRupeeRiskInput and useLotSizeInput and activeDir != 0 and not na(activeSL) and not na(activeEntry)
    float _lotRisk = math.abs(activeEntry - activeSL) * lotSizeInput
    dashLotRiskStr := formatRupee(_lotRisk) + "/lot"
string dashSessionPnlStr = useRupeeRiskInput ? formatRupee(statsRupeePnL) : "Off"
color  dashSessionPnlCol = useRupeeRiskInput ? (statsRupeePnL > 0 ? BULL_TEXT : statsRupeePnL < 0 ? BEAR_TEXT : TEXT_MUTED) : TEXT_MUTED
string dashCounterTrendStr = activeIsCounterTrend ? "⚠ COUNTER-TREND" : "—"
color  dashCounterTrendCol = activeIsCounterTrend ? counterTrendColorInput : TEXT_MUTED

if showDashInput and barstate.islast
    // Row count includes new rows: HTF, Session, Intraday, ₹ Risk, Daily ₹, Cap, Session ₹, Lot ₹, CT flag
    int statsRowBase = 13  // header + 12 base rows
    int newRowsCount = 9   // 9 new dashboard rows
    int statsRowsCount = showStatsInput ? 5 : 0
    int dashRows = statsRowBase + newRowsCount + statsRowsCount + 1  // +1 for version row
    var table dashTable = table.new(dashPos, 2, dashRows, TABLE_BG, TABLE_BORDER, 1, TABLE_BORDER, 1)
    table.cell(dashTable, 0, 0, "VWSR — Acrofins", text_color = HEADER_TEXT, bgcolor = HEADER_BG, text_size = size.small, text_halign = text.align_center)
    table.merge_cells(dashTable, 0, 0, 1, 0)

    int r = 1
    table.cell(dashTable, 0, r, "Trend",    text_color = TEXT_MUTED, text_size = size.small)
    table.cell(dashTable, 1, r, trendStr,   text_color = trendCol,   text_size = size.small)
    r += 1
    table.cell(dashTable, 0, r, "HTF Trend", text_color = TEXT_MUTED, text_size = size.small)
    table.cell(dashTable, 1, r, dashHtfStr, text_color = dashHtfCol, text_size = size.small)
    r += 1
    table.cell(dashTable, 0, r, "Signal",   text_color = TEXT_MUTED, text_size = size.small)
    table.cell(dashTable, 1, r, sigStr,     text_color = sigCol,     text_size = size.small)
    r += 1
    table.cell(dashTable, 0, r, "Score",    text_color = TEXT_MUTED, text_size = size.small)
    table.cell(dashTable, 1, r, strStr,     text_color = strCol,     text_size = size.small)
    r += 1
    table.cell(dashTable, 0, r, "Zones",    text_color = TEXT_MUTED, text_size = size.small)
    table.cell(dashTable, 1, r, zonesStr,   text_color = TEXT_COLOR, text_size = size.small)
    r += 1
    table.cell(dashTable, 0, r, "TF",       text_color = TEXT_MUTED, text_size = size.small)
    table.cell(dashTable, 1, r, timeframe.period, text_color = TEXT_COLOR, text_size = size.small)
    r += 1
    table.cell(dashTable, 0, r, "Session",  text_color = TEXT_MUTED, text_size = size.small)
    table.cell(dashTable, 1, r, dashSessionStr, text_color = dashSessionCol, text_size = size.small)
    r += 1
    table.cell(dashTable, 0, r, "Intraday", text_color = TEXT_MUTED, text_size = size.small)
    table.cell(dashTable, 1, r, dashIntradayStr, text_color = dashIntradayCol, text_size = size.small)
    r += 1
    table.cell(dashTable, 0, r, "SL",       text_color = TEXT_MUTED, text_size = size.small)
    table.cell(dashTable, 1, r, dashSL,     text_color = dashSlCol,  text_size = size.small)
    r += 1
    table.cell(dashTable, 0, r, "TP1",      text_color = TEXT_MUTED, text_size = size.small)
    table.cell(dashTable, 1, r, dashTP1,    text_color = dashTp1Col, text_size = size.small)
    r += 1
    table.cell(dashTable, 0, r, "TP2",      text_color = TEXT_MUTED, text_size = size.small)
    table.cell(dashTable, 1, r, dashTP2,    text_color = dashTp2Col, text_size = size.small)
    r += 1
    table.cell(dashTable, 0, r, "TP3",      text_color = TEXT_MUTED, text_size = size.small)
    table.cell(dashTable, 1, r, dashTP3,    text_color = dashTp3Col, text_size = size.small)
    r += 1
    table.cell(dashTable, 0, r, "R:R (TP1)", text_color = TEXT_MUTED, text_size = size.small)
    table.cell(dashTable, 1, r, dashRR,     text_color = rrCol,      text_size = size.small)
    r += 1
    table.cell(dashTable, 0, r, "Risk %",   text_color = TEXT_MUTED, text_size = size.small)
    table.cell(dashTable, 1, r, dashRsk,    text_color = riskCol,    text_size = size.small)
    r += 1
    table.cell(dashTable, 0, r, "Risk/trade", text_color = TEXT_MUTED, text_size = size.small)
    table.cell(dashTable, 1, r, dashRupeeRiskStr, text_color = TEXT_COLOR, text_size = size.small)
    r += 1
    table.cell(dashTable, 0, r, "Risk/lot",   text_color = TEXT_MUTED, text_size = size.small)
    table.cell(dashTable, 1, r, dashLotRiskStr, text_color = TEXT_COLOR, text_size = size.small)
    r += 1
    table.cell(dashTable, 0, r, "Today P&L", text_color = TEXT_MUTED, text_size = size.small)
    table.cell(dashTable, 1, r, dashDailyRupeeStr, text_color = dashDailyRupeeCol, text_size = size.small)
    r += 1
    table.cell(dashTable, 0, r, "Daily Cap", text_color = TEXT_MUTED, text_size = size.small)
    table.cell(dashTable, 1, r, dashRupeeCapStr, text_color = dashRupeeCapCol, text_size = size.small)
    r += 1
    table.cell(dashTable, 0, r, "CT Flag",  text_color = TEXT_MUTED, text_size = size.small)
    table.cell(dashTable, 1, r, dashCounterTrendStr, text_color = dashCounterTrendCol, text_size = size.small)
    r += 1
    if showStatsInput
        table.cell(dashTable, 0, r, "Trades",   text_color = TEXT_MUTED, text_size = size.small)
        table.cell(dashTable, 1, r, dashTrades, text_color = TEXT_COLOR, text_size = size.small)
        r += 1
        table.cell(dashTable, 0, r, "W/L",      text_color = TEXT_MUTED, text_size = size.small)
        table.cell(dashTable, 1, r, dashWL,     text_color = TEXT_COLOR, text_size = size.small)
        r += 1
        table.cell(dashTable, 0, r, "Win Rate", text_color = TEXT_MUTED, text_size = size.small)
        table.cell(dashTable, 1, r, dashWinRate,text_color = winRateCol,text_size = size.small)
        r += 1
        table.cell(dashTable, 0, r, "Avg R",    text_color = TEXT_MUTED, text_size = size.small)
        table.cell(dashTable, 1, r, dashAvgR,   text_color = avgRCol,    text_size = size.small)
        r += 1
        table.cell(dashTable, 0, r, "Session P&L", text_color = TEXT_MUTED, text_size = size.small)
        table.cell(dashTable, 1, r, dashSessionPnlStr, text_color = dashSessionPnlCol, text_size = size.small)
        r += 1
    table.cell(dashTable, 0, r, "Version",          text_color = TEXT_MUTED, text_size = size.tiny)
    table.cell(dashTable, 1, r, INDICATOR_VERSION,  text_color = TEXT_MUTED, text_size = size.tiny)

// ══════════════════════════════════════════════════════════════════════
// WATERMARK
// ══════════════════════════════════════════════════════════════════════
if barstate.islast and showWatermarkInput
    var table wmTable = table.new(position = position.bottom_right, columns = 1, rows = 1, bgcolor = color.new(color.black, 100), border_color = color.new(color.black, 100), border_width = 0, frame_color = color.new(color.black, 100), frame_width = 0)
    table.cell(wmTable, 0, 0, "Acrofins", text_color = WM_COLOR, text_size = size.normal, text_halign = text.align_right, bgcolor = color.new(color.black, 100))

// ══════════════════════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════════════════════
fmtActive(float v) =>
    na(v) ? "n/a" : str.tostring(v, format.mintick)

string aPrice = str.tostring(close, format.mintick)
string aSL    = fmtActive(activeSL)
string aTP1   = fmtActive(activeTP1)
string aTP2   = fmtActive(activeTP2)
string aTP3   = fmtActive(activeTP3)
string aRR    = str.tostring(activeRR, "#.#")
string aScore = str.tostring(signalScore, "#")
string ctTagAlert = isCounterTrend ? " [⚠ COUNTER-TREND]" : ""

string eEntry = fmtActive(exitEntry)
string eSL    = fmtActive(exitSL)
string eTP1   = fmtActive(exitTP1)
string eTP2   = fmtActive(exitTP2)
string eTP3   = fmtActive(exitTP3)

string jsonBreakBull  = '{"action":"break_bull","ticker":"'  + syminfo.tickerid + '","price":' + aPrice + ',"score":' + aScore + ',"sl":' + aSL + ',"tp1":' + aTP1 + ',"tp2":' + aTP2 + ',"tp3":' + aTP3 + ',"rr":' + aRR + ',"counter_trend":' + (isCounterTrendBull ? "true" : "false") + '}'
string jsonBreakBear  = '{"action":"break_bear","ticker":"'  + syminfo.tickerid + '","price":' + aPrice + ',"score":' + aScore + ',"sl":' + aSL + ',"tp1":' + aTP1 + ',"tp2":' + aTP2 + ',"tp3":' + aTP3 + ',"rr":' + aRR + ',"counter_trend":' + (isCounterTrendBear ? "true" : "false") + '}'
string jsonRetestBull = '{"action":"retest_bull","ticker":"' + syminfo.tickerid + '","price":' + aPrice + ',"score":' + aScore + ',"sl":' + aSL + ',"tp1":' + aTP1 + ',"tp2":' + aTP2 + ',"tp3":' + aTP3 + ',"rr":' + aRR + ',"counter_trend":' + (isCounterTrendBull ? "true" : "false") + '}'
string jsonRetestBear = '{"action":"retest_bear","ticker":"' + syminfo.tickerid + '","price":' + aPrice + ',"score":' + aScore + ',"sl":' + aSL + ',"tp1":' + aTP1 + ',"tp2":' + aTP2 + ',"tp3":' + aTP3 + ',"rr":' + aRR + ',"counter_trend":' + (isCounterTrendBear ? "true" : "false") + '}'

string textBreakBull  = "🟢 BREAK UP" + ctTagAlert + " | "    + syminfo.tickerid + " | TF: " + timeframe.period + " | Price: " + aPrice + " | Score: " + aScore + " | SL: " + aSL + " | TP1: " + aTP1 + " | TP2: " + aTP2 + " | TP3: " + aTP3 + " | R:R: " + aRR
string textBreakBear  = "🔴 BREAK DOWN" + ctTagAlert + " | "  + syminfo.tickerid + " | TF: " + timeframe.period + " | Price: " + aPrice + " | Score: " + aScore + " | SL: " + aSL + " | TP1: " + aTP1 + " | TP2: " + aTP2 + " | TP3: " + aTP3 + " | R:R: " + aRR
string textRetestBull = "🟢 RETEST LONG" + ctTagAlert + " | " + syminfo.tickerid + " | TF: " + timeframe.period + " | Price: " + aPrice + " | Score: " + aScore + " | SL: " + aSL + " | TP1: " + aTP1 + " | TP2: " + aTP2 + " | TP3: " + aTP3 + " | R:R: " + aRR
string textRetestBear = "🔴 RETEST SHORT" + ctTagAlert + " | "+ syminfo.tickerid + " | TF: " + timeframe.period + " | Price: " + aPrice + " | Score: " + aScore + " | SL: " + aSL + " | TP1: " + aTP1 + " | TP2: " + aTP2 + " | TP3: " + aTP3 + " | R:R: " + aRR

string textTp1Hit = "🎯 TP1 HIT | " + syminfo.tickerid + " | TP1: " + eTP1
string textTp2Hit = "🎯 TP2 HIT | " + syminfo.tickerid + " | TP2: " + eTP2
string textTp3Hit = "🏆 TP3 HIT | " + syminfo.tickerid + " | TP3: " + eTP3
string textBeAct  = "🛡️ BREAK-EVEN | " + syminfo.tickerid + " | SL moved to " + eEntry
string textForceClose = "⏰ INTRADAY FORCE-CLOSE | " + syminfo.tickerid + " | Closed at: " + str.tostring(exitClose, format.mintick) + " | Entry was: " + eEntry
string textDailyCap   = "🚫 DAILY LOSS CAP HIT | " + syminfo.tickerid + " | Today P&L: " + formatRupee(dailyRupeePnL) + " | New entries blocked until next session"

if sigBreakBull and alertOnBreakInput and canShowBullSig
    alert(webhookInput ? jsonBreakBull : textBreakBull, alert.freq_once_per_bar_close)
if sigBreakBear and alertOnBreakInput and canShowBearSig
    alert(webhookInput ? jsonBreakBear : textBreakBear, alert.freq_once_per_bar_close)
if sigRetestBull and alertOnRetestInput and canShowBullSig
    alert(webhookInput ? jsonRetestBull : textRetestBull, alert.freq_once_per_bar_close)
if sigRetestBear and alertOnRetestInput and canShowBearSig
    alert(webhookInput ? jsonRetestBear : textRetestBear, alert.freq_once_per_bar_close)

if slHit and alertOnSlHitInput
    string slMsg = (exitBeActive ? "🛡️ BE STOP-OUT | " : "🛑 SL HIT | ") + syminfo.tickerid + " | Entry: " + eEntry + " | SL: " + eSL
    alert(slMsg, alert.freq_once_per_bar_close)

if tp1FirstTouch and alertOnTpHitInput
    alert(textTp1Hit, alert.freq_once_per_bar_close)
if beJustActivated and alertOnTpHitInput
    alert(textBeAct, alert.freq_once_per_bar_close)
if tp2FirstTouch and alertOnTpHitInput
    alert(textTp2Hit, alert.freq_once_per_bar_close)
if tp3FirstTouch and alertOnTpHitInput
    alert(textTp3Hit, alert.freq_once_per_bar_close)

if forceClosedThisBar and alertOnForceCloseInput
    alert(textForceClose, alert.freq_once_per_bar_close)
if dailyCapJustHit and alertOnDailyCapInput
    alert(textDailyCap, alert.freq_once_per_bar_close)
if (isCounterTrendBull or isCounterTrendBear) and alertOnCounterTrendInput
    alert("⚠ COUNTER-TREND SIGNAL | " + syminfo.tickerid + " | TF: " + timeframe.period + " | HTF (" + htfPeriodInput + ") is " + htfTrendStr + " — signal direction conflicts with larger trend", alert.freq_once_per_bar_close)
````

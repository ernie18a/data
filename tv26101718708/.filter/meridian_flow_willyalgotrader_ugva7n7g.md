# Meridian Flow [WillyAlgoTrader]

- url: https://www.tradingview.com/script/uGVA7N7G-Meridian-Flow-WillyAlgoTrader/
- type: indicator
- pine_id: PUB;ff5e836462424ea3bd52c3fc01501563
- version: 1.0

## Description

[b]🧭 Meridian Flow[/b] is an overlay Smart-Money toolkit that reads market structure the way an institutional trader does — detecting confirmed swing points, classifying every break as a [b]BOS[/b] (trend continuation) or a [b]CHoCH[/b] (trend reversal), drawing the [b]order block[/b] each break leaves behind, and then turning that signal into a complete trade plan with ATR-based stop-loss, three take-profits, automatic break-even, and a live performance dashboard — all on one chart, with zero manual drawing.

The core idea: most "SMC" tools just paint boxes and labels and leave you to figure out the rest. Meridian Flow closes the loop. It does not stop at "here is a break" — it answers [b]where to enter, where the stop goes, where the targets are, when to move to break-even, and how the setup has performed[/b]. Structure detection, order-block tracking, a higher-timeframe bias filter, a full risk engine, a structure-anchored trend line, and a sectioned dashboard are wired into a single pipeline so each part feeds the next.

It works on [b]any market and any timeframe[/b] — forex, crypto, stocks, indices, futures — because every component is built from price action and ATR, not from instrument-specific assumptions.


[b]🧩 WHY THESE COMPONENTS WORK TOGETHER[/b]

A raw BOS/CHoCH labeler tells you structure broke, but not whether to trust the break, where the institutional zone is, or how to manage risk once you're in. An order-block tool draws zones but has no concept of trade management. A risk calculator needs an entry it can't generate on its own. Used separately, you're constantly stitching three or four tools together by hand.

Meridian Flow fuses them into one chain:

[b]Confirmed swing detection → HH/HL/LH/LL classification → BOS / CHoCH break engine → HTF bias filter → Order-block creation + mitigation tracking → ATR risk model (SL / TP1-3 / break-even) → Structure-anchored ATR trend line → Live stats & form dashboard → Alerts[/b]

The swing engine finds confirmed pivots. Classification tells you whether each new swing extends or contradicts the prior one. The break engine reads the running structure state to decide BOS vs CHoCH — the [b]same[/b] state then sets the direction of the trailing trend line, so the line and the labels never disagree. Each qualifying break spawns the order block that produced the move and tracks it until price mitigates it. The HTF filter vetoes breaks that fight the higher timeframe. The risk engine takes the surviving signal and immediately builds entry, stop, and three targets sized in ATR and R-multiples. The dashboard records the outcome and feeds it back to you as a win rate and a recent-form strip.

Without structure classification you can't separate continuations from reversals. Without the running-state logic, BOS and CHoCH blur together. Without order blocks you lose the institutional zone. Without the HTF filter you take every counter-trend poke. Without the risk model a signal is just an arrow. The combination is what turns "structure broke" into a managed, reviewable trade.


[b]🔍 WHAT MAKES IT ORIGINAL[/b]

1️⃣ [b]Confirmed swing engine with automatic HH / HL / LH / LL labeling.[/b]

Swings are found with symmetric pivots — equal left/right lookback (default [b]Swing Length 13[/b]) — so a pivot is only confirmed once enough bars have closed on both sides. Each new high is labeled:

 — isHH = (no previous high) OR (pivotHigh >= previousHigh)
 — otherwise it is an LH

Each new low is labeled:

 — isLL = (no previous low) OR (pivotLow <= previousLow)
 — otherwise it is an HL

This gives you an objective, repeatable map of structure instead of subjective lines.

2️⃣ [b]BOS vs CHoCH disambiguation via a running structure-state machine.[/b]

The indicator keeps an internal trend state (structTrend = +1 bull, −1 bear, 0 neutral). When a swing high breaks, it reads that state:

 — bull break while structTrend >= 0 → [b]BOS ▲[/b] (continuation)
 — bull break while structTrend < 0 → [b]CHoCH ▲[/b] (reversal up)

The mirror logic applies to bear breaks. This is why the same break can be a BOS in one context and a CHoCH in another — the label reflects the trend you were already in, not just the candle that broke.

3️⃣ [b]Conflict suppression + warmup guard.[/b]

If a bull break and a bear break would register on the very same bar, the bar is flagged a conflict and [b]both[/b] are suppressed — no contradictory signals. On top of that, no signal fires until the chart has warmed up:

 — WARMUP_BARS = max(Swing Length × 2, 50)

Early-history noise, where pivots aren't yet reliable, is filtered out before a single arrow prints.

4️⃣ [b]Order blocks tied to the break, with displacement detection and an arm→mitigate lifecycle.[/b]

When a break creates an OB, the engine scans back up to [b]OB Lookback (default 30)[/b] bars for the last opposite candle (for a bullish OB: the last down candle, close < open) and prefers one that was followed by a [b]displacement[/b] move out of its range. If no displacement is found, it falls back to the nearest opposite candle.

Every box then runs a lifecycle:

 — [b]Armed[/b]: price first closes beyond the zone (confirming the OB worked)
 — [b]Mitigated[/b]: price later returns into the zone (by wick or close, your choice), committed on bar close

Mitigated blocks fade to grey and freeze, or can be removed entirely. The box cap ([b]Max Order Blocks, default 8[/b]) always drops mitigated zones first, so live zones stay on the chart longest.

5️⃣ [b]Non-repainting higher-timeframe bias filter.[/b]

An EMA (default [b]50[/b]) is computed on a higher timeframe (default [b]60-minute[/b]) and read with a one-bar offset on confirmed values:

 — Bullish bias when close >= HTF EMA
 — Bearish bias when close <= HTF EMA

When the filter is on, longs are only allowed in a bullish HTF regime and shorts only in a bearish one. Because the HTF value is taken from the already-closed higher-timeframe bar, it does not repaint.

6️⃣ [b]Preset-driven ATR risk model — entry, stop, and three targets in one shot.[/b]

Stop distance is volatility-scaled, and targets are placed as multiples of that risk (R):

 — slDistance = ATR(SL length, default 13) × SL multiplier
 — SL = entry ∓ slDistance
 — TP1/TP2/TP3 = entry ± slDistance × (TP1/TP2/TP3 multiplier)

One click selects a full profile (SL ×ATR / TP1 / TP2 / TP3 in R):

 — [b]Conservative[/b]: 2.5 / 1R / 2R / 4R
 — [b]Balanced[/b]: 1.5 / 1R / 2R / 3R
 — [b]Aggressive[/b]: 1.0 / 1.5R / 2.5R / 4R
 — [b]Scalping[/b]: 0.8 / 0.8R / 1.5R / 2R
 — [b]Custom[/b]: set every multiplier by hand

Only [b]one position at a time[/b] is tracked — no pyramiding, no overlapping clutter.

7️⃣ [b]Break-even-after-TP1 with WIN-on-TP1 accounting.[/b]

When TP1 is first touched and break-even is enabled, the stop is moved to the entry price. From the next bar, any wick back to entry closes the trade at break-even — locking out the give-back loss. Crucially, [b]a trade counts as a WIN the moment TP1 is touched[/b], even if it later comes back to the break-even stop. This keeps the win-rate honest about partial profit-taking.

8️⃣ [b]Structure-anchored ATR trend line (SuperTrend-style, but it flips on CHoCH).[/b]

A smoothed ATR band trails price, but its direction is not decided by its own crossover logic — it is slaved to the structure state:

 — band = hl2 ∓ (ATR Trend Multiplier, default 5) × EMA(ATR(length 10), smoothing 5)
 — Bull regime: line trails as max(previous line, lower band)
 — Bear regime: line trails as min(previous line, upper band)
 — The line flips only when structure flips (a CHoCH), marked with a circle

So your trailing line and your BOS/CHoCH labels always tell the same story.

9️⃣ [b]Session stats engine — win rate gauge + recent-form strip.[/b]

The dashboard tallies closed trades, wins, losses, and win rate, rendered with a Unicode block gauge (▰▱). A separate [b]Form[/b] strip shows the last 10 outcomes (▰ = win, ▱ = loss, newest on the right), so you can see whether the current settings are in or out of sync with the market at a glance.


[b]🧠 HOW IT WORKS — bar by bar[/b]

[b]Step 1 — Detect swings:[/b] symmetric pivots confirm a swing high or low and label it HH/HL/LH/LL.

[b]Step 2 — Watch for a break:[/b] price closing (or wicking, your choice) beyond the last swing flags a raw break; same-bar conflicts are suppressed.

[b]Step 3 — Classify the break:[/b] the running structure state turns the raw break into a BOS or a CHoCH and flips the trend state.

[b]Step 4 — Filter by bias:[/b] if the HTF filter is on, the break must agree with the higher-timeframe EMA regime to qualify.

[b]Step 5 — Spawn the order block:[/b] the engine finds the originating candle (preferring displacement) and draws the OB zone.

[b]Step 6 — Open the trade:[/b] while flat, a qualifying break sets entry, ATR stop, and TP1/TP2/TP3 from the active preset.

[b]Step 7 — Manage it:[/b] each bar checks for TP touches and stop hits; TP1 triggers break-even; SL or TP3 closes the trade and books the result.

[b]Step 8 — Track zones:[/b] every open OB arms and then mitigates as price interacts with it.

[b]Step 9 — Report:[/b] the dashboard updates trend, signal, levels, R:R, win rate, and recent form; alerts fire on close.


[b]📖 HOW TO USE (beginner-friendly)[/b]

🎯 [b]Quick start — get running in 5 steps:[/b]
 1. Add Meridian Flow to any chart, any timeframe. Defaults already work.
 2. Look at the dashboard (top-right). The colored header tells you the current trend: green = bullish, red = bearish, blue = neutral.
 3. Wait for a [b]Long ▲[/b] or [b]Short ▼[/b] marker to print under/over a candle. That is a new trade signal.
 4. Read the colored lines that appear: the dotted line is your entry, the solid red line is your stop-loss, the three dashed lines are TP1, TP2, TP3.
 5. Use those exact levels in your broker. The dashboard shows the same numbers in text so you can copy them.

That is the whole loop: signal prints → take the levels → manage to the targets. Everything else below just helps you read and fine-tune it.

👁️ [b]Reading the chart (what every element means):[/b]
 — 🟢 [b]Long ▲ / 🔴 Short ▼[/b] markers = a trade just opened in that direction.
 — [b]BOS ▲/▼[/b] = trend is continuing in the same direction.
 — [b]CHoCH ▲/▼[/b] = trend may be reversing — the first sign of a turn.
 — [b]HH / HL[/b] = higher high / higher low (healthy uptrend). [b]LL / LH[/b] = lower low / lower high (healthy downtrend).
 — [b]Colored boxes[/b] = order blocks (institutional zones). Bright = still active; faded grey = already mitigated (price came back to it).
 — [b]Dotted line[/b] = entry · [b]solid red[/b] = stop-loss · [b]dashed lines[/b] = TP1/TP2/TP3. A target turns solid teal with a ✓ once price reaches it.
 — [b]Trailing ATR line[/b] = quick visual trend; it flips (with a small circle) when structure reverses.

📊 [b]Dashboard fields:[/b]
 — [b]Trend[/b]: current structure direction (Bullish / Bearish / Neutral).
 — [b]Signal[/b]: LONG, SHORT, or Wait (a new trade only opens when you're flat).
 — [b]Last event[/b]: the most recent BOS or CHoCH.
 — [b]Timeframe[/b]: the chart timeframe.
 — [b]SL / TP1 / TP2 / TP3[/b]: live levels of the open trade (✓ marks targets already hit; "BE @" means the stop moved to break-even).
 — [b]R:R (TP1)[/b]: reward-to-risk to the first target.
 — [b]SL Dist %[/b]: how far the stop sits from entry as a percentage.
 — [b]Trades / W-L / Win rate[/b]: this-session performance with a gauge.
 — [b]Form[/b]: last 10 results, ▰ win · ▱ loss, newest on the right.

🔧 [b]Tuning guide (fix common issues):[/b]
 — [b]Too many small/noisy signals:[/b] raise Swing Length (try 20-30) and set Break Confirmation to "Close".
 — [b]Signals feel late:[/b] lower Swing Length (5-10) and/or switch Break Confirmation to "Wick".
 — [b]Too many counter-trend trades:[/b] turn on the HTF Trend Filter.
 — [b]Stops too tight / too wide:[/b] change the Risk Preset, or use Custom and adjust SL ×ATR.
 — [b]Chart too busy:[/b] turn off OB labels and the mean line, reduce Max Order Blocks, or enable "Remove OB After Mitigation".

💡 [b]Trading ideas:[/b]
 — [b]Reversal hunting:[/b] set Signal Mode to "CHoCH only" to trade structure turns; pair with an order-block retest for confirmation.
 — [b]Trend riding:[/b] set Signal Mode to "BOS only" with the HTF filter on to stack with the higher-timeframe direction.
 — [b]Zone entries:[/b] wait for a fresh OB, then enter on the mitigation tap back into the zone rather than chasing the break.
 — [b]Scalping:[/b] use the Scalping preset on low timeframes for tight stops and quick 1:1 to 1:2 targets.
 — [b]Risk-free runners:[/b] keep Break-Even After TP1 on so winners can't turn into losers.


[b]⚙️ KEY SETTINGS REFERENCE[/b]

🏗️ [b]Structure:[/b]
 — [b]Swing Length[/b] (default 13): pivot lookback. Lower = more, smaller swings; higher = cleaner.
 — [b]Break Confirmation[/b] (default Close): Close = fewer fakeouts; Wick = earlier, riskier.
 — [b]Signal Mode[/b] (default BOS + CHoCH): which events fire trades — CHoCH only / BOS only / both.
 — [b]Show HH/HL/LH/LL[/b] (default on) · [b]Show BOS / CHoCH[/b] (default on).

📦 [b]Order Blocks:[/b]
 — [b]Show Order Blocks[/b] (default on) · [b]Create OB On[/b] (default BOS + CHoCH).
 — [b]Mitigation Trigger[/b] (default Wick): Wick = earlier; Close = stricter.
 — [b]Remove OB After Mitigation[/b] (default off) · [b]OB Lookback[/b] (default 30) · [b]Max Order Blocks[/b] (default 8).
 — [b]OB Box Transparency[/b] (default 85) · [b]Show 50% Mean Line[/b] (default off) · [b]Show OB Labels[/b] (default off).

🔍 [b]Filters:[/b]
 — [b]HTF Trend Filter[/b] (default off) · [b]HTF Timeframe[/b] (default 60) · [b]HTF EMA Length[/b] (default 50).

🛡️ [b]Risk Management:[/b]
 — [b]Risk Preset[/b] (default Balanced): Conservative / Balanced / Aggressive / Scalping / Custom.
 — [b]ATR Length (SL)[/b] (default 13) · [b]SL ×ATR / TP1 / TP2 / TP3[/b] multipliers (Custom mode).
 — [b]Show SL/TP Lines[/b] (default on) · [b]Show SL/TP Labels[/b] (default on) · [b]Show % Distance[/b] (default on).
 — [b]Break-Even After TP1[/b] (default on) · [b]Entry / SL / TP Line Style[/b].

🎨 [b]Visual:[/b]
 — [b]Theme[/b] (default Auto) · [b]Show Buy/Sell Signals[/b] (default on) · [b]Label Font Size[/b] (default Small).
 — [b]Show ATR Trend Line[/b] (default on) · [b]ATR Trend Length[/b] (default 10) · [b]Multiplier[/b] (default 5.0) · [b]Smoothing[/b] (default 5).
 — [b]Show Watermark[/b] (default on).

📊 [b]Dashboard:[/b]
 — [b]Show Dashboard[/b] (default on) · [b]Position[/b] (default Top Right) · toggles for [b]Market / Trade / Stats[/b] sections.

🔔 [b]Alerts:[/b]
 — [b]Webhook JSON Format[/b] (default off) · [b]Alert on SL Hit[/b] (default on) · [b]Alert on TP / Break-Even[/b] (default off) · [b]Alert on OB Mitigation[/b] (default off).


[b]🔔 ALERTS[/b]

 — 🟢 [b]LONG[/b] / 🔴 [b]SHORT[/b] — entry with ticker, timeframe, price, SL, TP1/TP2/TP3 and R:R.
 — 🛑 [b]SL HIT[/b] / 🛡️ [b]BE STOP-OUT[/b] — stop or break-even stop-out, with entry and stop price.
 — 🛡️ [b]BREAK-EVEN[/b] — stop moved to entry after TP1.
 — 🎯 [b]TP1 / TP2 / TP3 HIT[/b] — each target as it is touched.
 — 📦 [b]OB MITIGATION[/b] — price returns into a bull or bear order block.
All alerts support plain text and JSON webhook output, and fire on bar close (once per bar close).


[b]⚠️ IMPORTANT NOTES[/b]

 — 🚫 [b]No repainting.[/b] Swings use symmetric (equal left/right) pivots, so a pivot is confirmed only after the lookback bars close — the actual swing sits in the past by the Swing Length; the indicator draws forward from that confirmed bar. Breaks, hits, and OB mitigation all commit on bar close (barstate.isconfirmed), the HTF bias reads the already-closed higher-timeframe bar, and alerts fire once per bar close. This is delayed confirmation, not repainting of future values.
 — 📐 Confirmation delay is inherent: signals appear after the bar that triggers them closes. This is the cost of avoiding fakeouts.
 — ⚖️ Stats are session-based: win rate and the form strip reset when the script reloads or any input changes. They reflect the visible history with current settings, not a guaranteed forward result.
 — 📊 "SL Dist %" is the stop distance as a percentage of entry — it is not a position-sizing or account-risk figure. Size your positions with your own risk rules.
 — 🛠️ This is a market-structure analysis and trade-planning tool, not an automated trading bot. It detects structure, draws zones, builds stop/target levels, and tracks outcomes — trade decisions remain yours.
 — 🌐 Works on all markets and all timeframes. Past performance does not guarantee future results.
 — 🆓 Meridian Flow is free to use. Feedback and suggestions are welcome in the comments.

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════
// MERIDIAN FLOW [WillyAlgoTrader]
// ══════════════════════════════════════════════════════════
// Author:  Willy | WillyAlgoTrader
// Version: 1.4.0
// ══════════════════════════════════════════════════════════

indicator(
     title              = "Meridian Flow [WillyAlgoTrader]",
     shorttitle         = "Meridian Flow [WAT]",
     overlay            = true,
     max_lines_count    = 500,
     max_labels_count   = 500,
     max_boxes_count    = 500,
     max_bars_back      = 5000)

// ══════════════════════════════════════════════════════════
// 1. CONSTANTS
// ══════════════════════════════════════════════════════════
GRP_STRUCT = "🏗️ Structure"
GRP_OB     = "📦 Order Blocks"
GRP_FILTER = "🔍 Filters"
GRP_RISK   = "🛡️ Risk Management"
GRP_VISUAL = "🎨 Visual"
GRP_DASH   = "📊 Dashboard"
GRP_ALERT  = "🔔 Alerts"
GRP_COLORS = "🎨 Colors"

INDICATOR_VERSION = "v1.4.0"

LINE_FORWARD_BARS = 20
LINE_UPDATE_BARS  = 5
LABEL_OFFSET_BARS = 1
OB_EXTEND_BARS    = 2
OB_BORDER_BOOST   = 35
BE_DIM_TRANSP     = 70
FORM_LEN          = 10   // recent-form strip length

// ══════════════════════════════════════════════════════════
// 2. INPUTS
// ══════════════════════════════════════════════════════════

// ── Structure ───────────────────────────────────────────────
swingLenInput = input.int(13, "Swing Length", minval = 2, maxval = 50, group = GRP_STRUCT,
     tooltip = "Pivot lookback for swing detection.\n" +
               "• Lower = more, smaller swings (noisier structure)\n" +
               "• Higher = only major swings (cleaner, slower)\n" +
               "• Recommended: 5-10 intraday, 15-30 swing")

breakSrcInput = input.string("Close", "Break Confirmation",
     options = ["Close", "Wick"], group = GRP_STRUCT,
     tooltip = "How a structure break is confirmed.\n" +
               "• Close: bar must CLOSE beyond the level (fewer fakeouts)\n" +
               "• Wick: any wick beyond the level counts (earlier, riskier)")

signalModeInput = input.string("BOS + CHoCH", "Signal Mode",
     options = ["BOS + CHoCH", "CHoCH only", "BOS only"], group = GRP_STRUCT,
     tooltip = "Which structure events fire entry signals.\n" +
               "• CHoCH only: reversals (counter-trend turns)\n" +
               "• BOS only: trend continuations\n" +
               "• BOS + CHoCH: both")

showStructLabelsInput = input.bool(true, "Show HH/HL/LH/LL", group = GRP_STRUCT,
     tooltip = "Label every confirmed swing point with its type")
showBosChochInput = input.bool(true, "Show BOS / CHoCH", group = GRP_STRUCT,
     tooltip = "Draw the broken level and tag it BOS or CHoCH (shown for every\nbreak, even while a position is already open)")

// ── Order Blocks ────────────────────────────────────────────
showOBInput = input.bool(true, "Show Order Blocks", group = GRP_OB,
     tooltip = "Draw the order block created by each structure break.\n" +
               "• Bull break → bullish OB (last down candle before the up move)\n" +
               "• Bear break → bearish OB (last up candle before the down move)")
obFromInput = input.string("BOS + CHoCH", "Create OB On",
     options = ["BOS + CHoCH", "CHoCH only", "BOS only"], group = GRP_OB,
     tooltip = "Which structure events spawn an order block.")
obMitSrcInput = input.string("Wick", "Mitigation Trigger",
     options = ["Wick", "Close"], group = GRP_OB,
     tooltip = "How an OB is marked mitigated when price returns to it.\n" +
               "• Wick: any wick touches the zone's near edge (earlier)\n" +
               "• Close: a bar must close into the zone (stricter)\n" +
               "Commits on bar close only.")
removeMitigatedInput = input.bool(false, "Remove OB After Mitigation", group = GRP_OB,
     tooltip = "ON  : delete the box once mitigated (clean chart)\n" +
               "OFF : keep it, faded to grey and frozen (default)")
obLookbackInput = input.int(30, "OB Lookback (bars)", minval = 3, maxval = 100, group = GRP_OB,
     tooltip = "How far back to scan from the break for the OB candle.")
maxOBInput = input.int(8, "Max Order Blocks", minval = 1, maxval = 30, group = GRP_OB,
     tooltip = "Cap on stored OB boxes. Mitigated blocks are dropped first.")
obTranspInput = input.int(85, "OB Box Transparency", minval = 0, maxval = 95, group = GRP_OB,
     tooltip = "Fill transparency of OB boxes. Higher = more see-through.")
obShowMeanInput = input.bool(false, "Show 50% Mean Line", group = GRP_OB,
     tooltip = "Dotted line at the OB midpoint (consequent encroachment).")
obShowLabelsInput = input.bool(false, "Show OB Labels", group = GRP_OB,
     tooltip = "Tag each box 'Bull OB' / 'Bear OB'.")

// ── Filters ─────────────────────────────────────────────────
useHtfInput = input.bool(false, "HTF Trend Filter", group = GRP_FILTER,
     tooltip = "Only allow longs when higher timeframe is bullish, and\n" +
               "shorts when it is bearish. Reduces counter-trend noise.")
htfTfInput = input.timeframe("60", "HTF Timeframe", group = GRP_FILTER,
     tooltip = "Higher timeframe used for the bias filter (e.g. 60 = 1H)")
htfEmaLenInput = input.int(50, "HTF EMA Length", minval = 5, maxval = 200, group = GRP_FILTER,
     tooltip = "EMA on the HTF. Price above = bullish bias, below = bearish")

// ── Risk Management ─────────────────────────────────────────
riskPresetInput = input.string("Balanced", "Risk Preset",
     options = ["Conservative", "Balanced", "Aggressive", "Scalping", "Custom"],
     group = GRP_RISK,
     tooltip = "Quick risk presets (SL ×ATR / TP1 / TP2 / TP3 in R):\n" +
               "• Conservative: 2.5 / 1R / 2R / 4R\n" +
               "• Balanced: 1.5 / 1R / 2R / 3R\n" +
               "• Aggressive: 1.0 / 1.5R / 2.5R / 4R\n" +
               "• Scalping: 0.8 / 0.8R / 1.5R / 2R\n" +
               "• Custom: use manual inputs below")

atrLenRiskInput = input.int(13, "ATR Length (SL)", minval = 5, maxval = 50, group = GRP_RISK,
     tooltip = "ATR period for stop-loss distance.\n14 = standard on most timeframes")
slMultInput = input.float(1.5, "SL ×ATR (Custom)", minval = 0.5, maxval = 5.0, step = 0.1, group = GRP_RISK,
     tooltip = "Custom stop distance = ATR × this. Used only when preset = Custom")
tp1MultInput = input.float(1.0, "TP1 ×Risk (Custom)", minval = 0.5, maxval = 5.0, step = 0.1, group = GRP_RISK,
     tooltip = "TP1 as multiple of risk. 1.0 = 1:1 R:R")
tp2MultInput = input.float(2.0, "TP2 ×Risk (Custom)", minval = 1.0, maxval = 10.0, step = 0.1, group = GRP_RISK,
     tooltip = "TP2 as multiple of risk. 2.0 = 1:2 R:R")
tp3MultInput = input.float(3.0, "TP3 ×Risk (Custom)", minval = 1.5, maxval = 15.0, step = 0.1, group = GRP_RISK,
     tooltip = "TP3 as multiple of risk. 3.0 = 1:3 R:R")

showSlTpInput = input.bool(true, "Show SL/TP Lines", group = GRP_RISK,
     tooltip = "Draw stop and take-profit lines after each entry.\n" +
               "Lines persist showing the last trade's outcome until the next entry.")
showSlTpLabelsInput = input.bool(true, "Show SL/TP Labels", group = GRP_RISK,
     tooltip = "Show price labels on the SL/TP lines")
showPctOnLabelsInput = input.bool(true, "Show % Distance on Labels", group = GRP_RISK,
     tooltip = "Append % distance from entry to SL/TP labels.\n" +
               "Example: 'SL 1.2300 (-0.36%)'.")

useBreakEvenInput = input.bool(true, "Break-Even After TP1", group = GRP_RISK,
     tooltip = "When TP1 is hit, move stop-loss to entry price.\n" +
               "From the next bar onward, any wick touching entry closes the\n" +
               "trade at break-even. (TP1 still counts as a WIN.)")

entryLineStyleInput = input.string("Dotted", "Entry Line Style",
     options = ["Solid", "Dashed", "Dotted"], group = GRP_RISK,
     tooltip = "Entry is a REFERENCE, not an action level — keep it subtle.")
slLineStyleInput = input.string("Solid", "SL Line Style",
     options = ["Solid", "Dashed", "Dotted"], group = GRP_RISK,
     tooltip = "SL is the most critical risk level — keep it visually prominent.")
tpLineStyleInput = input.string("Dashed", "TP Line Style",
     options = ["Solid", "Dashed", "Dotted"], group = GRP_RISK,
     tooltip = "Style for TP1/TP2/TP3.\nOn hit, a TP line turns solid teal regardless.")

// ── Visual ──────────────────────────────────────────────────
themeInput = input.string("Auto", "Theme", options = ["Auto", "Dark", "Light"], group = GRP_VISUAL,
     tooltip = "Chart color theme.\n• Auto: detect from chart background\n• Dark / Light: force manually")
showSignalsInput = input.bool(true, "Show Buy/Sell Signals", group = GRP_VISUAL,
     tooltip = "Print Long ▲ / Short ▼ markers when a trade opens")

labelFontSizeInput = input.string("Small", "SL/TP Label Font Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = GRP_VISUAL,
     tooltip = "Font size for SL/TP/Entry labels. Use Tiny for compact look.")

showAtrTrendInput = input.bool(true, "Show ATR Trend Line", group = GRP_VISUAL,
     tooltip = "Smooth ATR trailing trend line (SuperTrend-style).")
atrTrendLenInput = input.int(10, "ATR Trend Length", minval = 1, maxval = 100, group = GRP_VISUAL,
     tooltip = "ATR period for the trend line. Higher = slower, smoother")
atrTrendMultInput = input.float(5.0, "ATR Trend Multiplier", minval = 0.5, maxval = 10.0, step = 0.1, group = GRP_VISUAL,
     tooltip = "Distance of the line from price = ATR × this. Higher = wider, fewer flips")
atrSmoothInput = input.int(5, "ATR Line Smoothing", minval = 1, maxval = 50, group = GRP_VISUAL,
     tooltip = "EMA smoothing applied to the ATR. Higher = smoother. 1 = none")

showWatermarkInput = input.bool(true, "Show Watermark", group = GRP_VISUAL,
     tooltip = "Display 'WillyAlgoTrader' watermark on chart")

// ── Dashboard ───────────────────────────────────────────────
showDashInput = input.bool(true, "Show Dashboard", group = GRP_DASH,
     tooltip = "Master toggle for the dashboard table")
dashPosStr = input.string("Top Right", "Dashboard Position",
     options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Middle Right"],
     group = GRP_DASH)
showMarketSecInput = input.bool(true, "  ├ Market section", group = GRP_DASH,
     tooltip = "Trend, Signal, Last event, Timeframe")
showTradeSecInput = input.bool(true, "  ├ Trade section", group = GRP_DASH,
     tooltip = "SL, TP1-3, R:R, SL distance. Collapses to one row when flat.")
showStatsSecInput = input.bool(true, "  └ Stats section", group = GRP_DASH,
     tooltip = "Trades, W/L, Win Rate (+gauge), recent Form")

// ── Alerts ──────────────────────────────────────────────────
webhookInput = input.bool(false, "Webhook JSON Format", group = GRP_ALERT,
     tooltip = "Send alerts as JSON for webhook / autotrading integrations")
showSlHitAlertInput = input.bool(true, "Alert on SL Hit", group = GRP_ALERT,
     tooltip = "Fire an alert when price hits the active stop-loss")
alertTpHitInput = input.bool(false, "Alert on TP / Break-Even", group = GRP_ALERT,
     tooltip = "Fire alerts when TP1/TP2/TP3 are touched and on break-even.")
alertOBMitInput = input.bool(false, "Alert on OB Mitigation", group = GRP_ALERT,
     tooltip = "Fire an alert when price returns into an order block (mitigation).")

// ── Colors ──────────────────────────────────────────────────
bullColorInput = input.color(#00E676, "Bull", inline = "c1", group = GRP_COLORS)
bearColorInput = input.color(#FF5252, "Bear", inline = "c1", group = GRP_COLORS)
obBullColorInput = input.color(#26A69A, "OB Bull", inline = "ob", group = GRP_COLORS)
obBearColorInput = input.color(#EF5350, "OB Bear", inline = "ob", group = GRP_COLORS)

// ══════════════════════════════════════════════════════════
// 3. THEME DETECTION & COLORS
// ══════════════════════════════════════════════════════════
isDark = switch themeInput
    "Dark"  => true
    "Light" => false
    =>         color.r(chart.bg_color) < 128   // Auto

BULL_COLOR = bullColorInput
BEAR_COLOR = bearColorInput

BULL_TEXT    = isDark ? #00E676 : #00A152
BEAR_TEXT    = isDark ? #FF5252 : #D32F2F
NEUTRAL_TEXT = isDark ? #FFEB3B : #F57F17

BULL_LABEL_TEXT = #004D25
BEAR_LABEL_TEXT = #FFFFFF

TEXT_COLOR    = isDark ? #E0E0E0                : #1A1A1A
TEXT_MUTED    = isDark ? color.new(#9E9E9E, 0)  : color.new(#757575, 0)
TABLE_BG      = isDark ? color.new(#131722, 5)  : color.new(#FFFFFF, 5)
TABLE_ROW_ALT = isDark ? color.new(#1C2030, 0)  : color.new(#F0F4F8, 0)
TABLE_BORDER  = isDark ? color.new(#2A2E39, 0)  : color.new(#D0D0D0, 0)
HEADER_TEXT   = #FFFFFF
WM_COLOR      = isDark ? color.new(#FFFFFF, 80) : color.new(#000000, 80)

// Trend-tinted header backgrounds
HEADER_BG_BULL = color.new(#0F6E56, 0)
HEADER_BG_BEAR = color.new(#A32D2D, 0)
HEADER_BG_FLAT = color.new(#2962FF, 0)

// Risk-Management palette (premium, muted, theme-aware)
SL_COLOR       = isDark ? color.new(#E57373, 0)  : color.new(#B71C1C, 0)
TP1_COLOR      = isDark ? color.new(#66BB6A, 30) : color.new(#388E3C, 30)
TP2_COLOR      = isDark ? color.new(#66BB6A, 40) : color.new(#388E3C, 40)
TP3_COLOR      = isDark ? color.new(#66BB6A, 0)  : color.new(#388E3C, 0)
ENTRY_COLOR    = isDark ? color.new(#5C8AAE, 0)  : color.new(#34495E, 0)
TP_LABEL_COLOR = isDark ? color.new(#66BB6A, 0)  : color.new(#388E3C, 0)
TP_HIT_COLOR   = isDark ? color.new(#4DB6AC, 0)  : color.new(#00695C, 0)
BE_COLOR       = isDark ? color.new(#FFA726, 0)  : color.new(#E65100, 0)
LABEL_TEXT     = isDark ? #1A1A1A                : #FFFFFF
FORM_COLOR     = isDark ? #5C8AAE                : #34495E

// Order Block colors
OB_BULL_BG     = color.new(obBullColorInput, obTranspInput)
OB_BULL_BORDER = color.new(obBullColorInput, math.max(0, obTranspInput - OB_BORDER_BOOST))
OB_BEAR_BG     = color.new(obBearColorInput, obTranspInput)
OB_BEAR_BORDER = color.new(obBearColorInput, math.max(0, obTranspInput - OB_BORDER_BOOST))
OB_MIT_BG      = isDark ? color.new(#9E9E9E, 90) : color.new(#9E9E9E, 88)
OB_MIT_BORDER  = isDark ? color.new(#9E9E9E, 55) : color.new(#9E9E9E, 50)

// ══════════════════════════════════════════════════════════
// 4. TYPES, STATE & HELPERS
// ══════════════════════════════════════════════════════════
type OB
    box   bx
    line  meanLn
    label lbl
    float top
    float bot
    int   dir
    bool  mitigated
    int   createdBar
    bool  armed

var array<OB> obList = array.new<OB>()

spawnOB(int dir, int obI) =>
    float obTop  = high[obI]
    float obBot  = low[obI]
    int   obLeft = bar_index - obI
    color bg     = dir == 1 ? OB_BULL_BG     : OB_BEAR_BG
    color bd     = dir == 1 ? OB_BULL_BORDER : OB_BEAR_BORDER
    color txt    = dir == 1 ? BULL_TEXT      : BEAR_TEXT

    box obx = box.new(obLeft, obTop, bar_index + OB_EXTEND_BARS, obBot,
         bgcolor = bg, border_color = bd, border_width = 1)

    line obml = na
    if obShowMeanInput
        float mid = (obTop + obBot) / 2.0
        obml := line.new(obLeft, mid, bar_index + OB_EXTEND_BARS, mid,
             color = bd, style = line.style_dotted, width = 1)

    label oblb = na
    if obShowLabelsInput
        oblb := label.new(obLeft, dir == 1 ? obTop : obBot, dir == 1 ? "Bull OB" : "Bear OB",
             color = color.new(color.black, 100), textcolor = txt,
             style = dir == 1 ? label.style_label_down : label.style_label_up,
             size = size.tiny, yloc = yloc.price)

    bool armed = dir == 1 ? close > obTop : close < obBot

    array.push(obList, OB.new(bx = obx, meanLn = obml, lbl = oblb, top = obTop, bot = obBot,
         dir = dir, mitigated = false, createdBar = bar_index, armed = armed))

    if array.size(obList) > maxOBInput
        int dropIdx = 0
        for j = 0 to array.size(obList) - 1
            OB cand = array.get(obList, j)
            if cand.mitigated
                dropIdx := j
                break
        OB old = array.get(obList, dropIdx)
        box.delete(old.bx)
        if not na(old.meanLn)
            line.delete(old.meanLn)
        if not na(old.lbl)
            label.delete(old.lbl)
        array.remove(obList, dropIdx)

findOBbar(bool wantBearish, int lookback) =>
    int found    = na
    int fallback = na
    for i = 1 to lookback
        bool isOpp = wantBearish ? (close[i] < open[i]) : (close[i] > open[i])
        if isOpp
            if na(fallback)
                fallback := i
            bool disp = wantBearish ? (close[i - 1] > high[i]) : (close[i - 1] < low[i])
            if disp
                found := i
                break
    na(found) ? fallback : found

// Unicode block gauge: filled ▰ proportional to value/maxVal across `width` cells
buildGauge(float value, float maxVal, int width) =>
    string result = ""
    int filled = maxVal <= 0 ? 0 : math.round(math.min(width, math.max(0.0, value / maxVal * width)))
    for i = 0 to width - 1
        result += i < filled ? "▰" : "▱"
    result

dashPos = switch dashPosStr
    "Top Left"     => position.top_left
    "Top Right"    => position.top_right
    "Bottom Left"  => position.bottom_left
    "Bottom Right" => position.bottom_right
    "Middle Right" => position.middle_right
    =>                position.top_right

fmtPrice(float v) =>
    na(v) ? "—" : str.tostring(v, format.mintick)

formatPctFromEntry(float level, float entry) =>
    string res = ""
    if showPctOnLabelsInput and not na(level) and not na(entry) and entry != 0
        float pct = (level - entry) / entry * 100.0
        string sign = pct >= 0 ? "+" : ""
        res := " (" + sign + str.tostring(pct, "#.##") + "%)"
    res

lineStyleFromString(string s) =>
    s == "Dashed" ? line.style_dashed :
     s == "Dotted" ? line.style_dotted :
     line.style_solid

sizeFromString(string s) =>
    s == "Tiny"   ? size.tiny :
     s == "Small"  ? size.small :
     s == "Normal" ? size.normal :
     s == "Large"  ? size.large :
     s == "Huge"   ? size.huge :
     size.small

entryLineStyle = lineStyleFromString(entryLineStyleInput)
slLineStyle    = lineStyleFromString(slLineStyleInput)
tpLineStyle    = lineStyleFromString(tpLineStyleInput)
labelSize      = sizeFromString(labelFontSizeInput)

// ══════════════════════════════════════════════════════════
// 5. WARMUP
// ══════════════════════════════════════════════════════════
int  WARMUP_BARS = math.max(swingLenInput * 2, 50)
bool isWarmedUp  = bar_index >= WARMUP_BARS

// ══════════════════════════════════════════════════════════
// 6. HTF BIAS (non-repainting: [1] + lookahead_on)
// ══════════════════════════════════════════════════════════
float htfEma = request.security(syminfo.tickerid, htfTfInput,
     ta.ema(close, htfEmaLenInput)[1], barmerge.gaps_off, barmerge.lookahead_on)
float safeHtfEma = nz(htfEma, close)
bool  htfBull = close >= safeHtfEma
bool  htfBear = close <= safeHtfEma
bool  htfBullOk = not useHtfInput or htfBull
bool  htfBearOk = not useHtfInput or htfBear

// ══════════════════════════════════════════════════════════
// 7. MARKET STRUCTURE ENGINE
// ══════════════════════════════════════════════════════════
float ph = ta.pivothigh(swingLenInput, swingLenInput)
float pl = ta.pivotlow(swingLenInput, swingLenInput)

var float lastSwingHigh    = na
var int   lastSwingHighBar = na
var float prevSwingHigh    = na
var bool  swingHighBroken  = true

var float lastSwingLow     = na
var int   lastSwingLowBar   = na
var float prevSwingLow     = na
var bool  swingLowBroken   = true

var int   structTrend      = 0

var array<line>  structLines  = array.new<line>()
var array<label> structLabels = array.new<label>()

if not na(ph)
    prevSwingHigh    := lastSwingHigh
    lastSwingHigh    := ph
    lastSwingHighBar := bar_index - swingLenInput
    swingHighBroken  := false
    if showStructLabelsInput
        bool isHH = na(prevSwingHigh) or ph >= prevSwingHigh
        label lb = label.new(lastSwingHighBar, ph, isHH ? "HH" : "LH",
             color = color.new(color.black, 100), textcolor = isHH ? BULL_TEXT : NEUTRAL_TEXT,
             style = label.style_label_down, size = size.tiny, yloc = yloc.abovebar)
        array.push(structLabels, lb)

if not na(pl)
    prevSwingLow    := lastSwingLow
    lastSwingLow    := pl
    lastSwingLowBar := bar_index - swingLenInput
    swingLowBroken  := false
    if showStructLabelsInput
        bool isLL = na(prevSwingLow) or pl <= prevSwingLow
        label lb = label.new(lastSwingLowBar, pl, isLL ? "LL" : "HL",
             color = color.new(color.black, 100), textcolor = isLL ? BEAR_TEXT : BULL_TEXT,
             style = label.style_label_up, size = size.tiny, yloc = yloc.belowbar)
        array.push(structLabels, lb)

float breakHighSrc = breakSrcInput == "Wick" ? high : close
float breakLowSrc  = breakSrcInput == "Wick" ? low  : close

bool rawBullBreak = not na(lastSwingHigh) and not swingHighBroken and breakHighSrc > lastSwingHigh
bool rawBearBreak = not na(lastSwingLow)  and not swingLowBroken  and breakLowSrc  < lastSwingLow

bool breakConflict = rawBullBreak and rawBearBreak
bool bullBreak = rawBullBreak and not breakConflict and barstate.isconfirmed and isWarmedUp
bool bearBreak = rawBearBreak and not breakConflict and barstate.isconfirmed and isWarmedUp

bool isBullBOS   = false
bool isBullCHoCH = false
bool isBearBOS   = false
bool isBearCHoCH = false

int   brokenHighBar = na
int   brokenLowBar  = na
float brokenHighLvl = na
float brokenLowLvl  = na

if bullBreak
    isBullBOS       := structTrend >= 0
    isBullCHoCH     := structTrend < 0
    brokenHighBar   := lastSwingHighBar
    brokenHighLvl   := lastSwingHigh
    structTrend     := 1
    swingHighBroken := true

if bearBreak
    isBearBOS       := structTrend <= 0
    isBearCHoCH     := structTrend > 0
    brokenLowBar    := lastSwingLowBar
    brokenLowLvl    := lastSwingLow
    structTrend     := -1
    swingLowBroken  := true

if showBosChochInput and (isBullBOS or isBullCHoCH) and not na(brokenHighBar)
    line ln = line.new(brokenHighBar, brokenHighLvl, bar_index, brokenHighLvl,
         color = color.new(BULL_COLOR, 25), width = 2, style = line.style_dotted)
    array.push(structLines, ln)
    label lb = label.new(bar_index, brokenHighLvl, isBullCHoCH ? "CHoCH ▲" : "BOS ▲",
         color = BULL_COLOR, textcolor = BULL_LABEL_TEXT,
         style = label.style_label_down, size = size.small)
    array.push(structLabels, lb)

if showBosChochInput and (isBearBOS or isBearCHoCH) and not na(brokenLowBar)
    line ln = line.new(brokenLowBar, brokenLowLvl, bar_index, brokenLowLvl,
         color = color.new(BEAR_COLOR, 25), width = 2, style = line.style_dotted)
    array.push(structLines, ln)
    label lb = label.new(bar_index, brokenLowLvl, isBearCHoCH ? "CHoCH ▼" : "BOS ▼",
         color = BEAR_COLOR, textcolor = BEAR_LABEL_TEXT,
         style = label.style_label_up, size = size.small)
    array.push(structLabels, lb)

if array.size(structLines) > 120
    line.delete(array.shift(structLines))
if array.size(structLabels) > 240
    label.delete(array.shift(structLabels))

// ══════════════════════════════════════════════════════════
// 8. ORDER BLOCKS — tied to BOS/CHoCH, mitigation-tracked
// ══════════════════════════════════════════════════════════
bool obMitWick   = obMitSrcInput == "Wick"
bool bullOBevent = obFromInput == "CHoCH only" ? isBullCHoCH : obFromInput == "BOS only" ? isBullBOS : (isBullBOS or isBullCHoCH)
bool bearOBevent = obFromInput == "CHoCH only" ? isBearCHoCH : obFromInput == "BOS only" ? isBearBOS : (isBearBOS or isBearCHoCH)

if showOBInput and bullOBevent
    int obI = findOBbar(true, obLookbackInput)
    if not na(obI)
        spawnOB(1, obI)

if showOBInput and bearOBevent
    int obI = findOBbar(false, obLookbackInput)
    if not na(obI)
        spawnOB(-1, obI)

// Maintenance: arm → mitigate → extend (boxes only exist when OBs are on)
if array.size(obList) > 0
    for idx = array.size(obList) - 1 to 0
        OB ob = array.get(obList, idx)
        if not ob.mitigated
            if not ob.armed
                ob.armed := ob.dir == 1 ? close > ob.top : close < ob.bot
            bool mit = ob.armed and barstate.isconfirmed and bar_index > ob.createdBar and
                 (ob.dir == 1 ? (obMitWick ? low <= ob.top : close <= ob.top)
                              : (obMitWick ? high >= ob.bot : close >= ob.bot))
            if mit
                ob.mitigated := true
                box.set_bgcolor(ob.bx, OB_MIT_BG)
                box.set_border_color(ob.bx, OB_MIT_BORDER)
                box.set_right(ob.bx, bar_index)
                if not na(ob.meanLn)
                    line.set_x2(ob.meanLn, bar_index)
                    line.set_color(ob.meanLn, OB_MIT_BORDER)
                if not na(ob.lbl)
                    label.set_textcolor(ob.lbl, OB_MIT_BORDER)
                if alertOBMitInput
                    alert((ob.dir == 1 ? "📦 Bull OB mitigated | " : "📦 Bear OB mitigated | ") +
                         syminfo.tickerid + " | TF: " + timeframe.period, alert.freq_once_per_bar_close)
                if removeMitigatedInput
                    box.delete(ob.bx)
                    if not na(ob.meanLn)
                        line.delete(ob.meanLn)
                    if not na(ob.lbl)
                        label.delete(ob.lbl)
                    array.remove(obList, idx)
            else
                box.set_right(ob.bx, bar_index + OB_EXTEND_BARS)
                if not na(ob.meanLn)
                    line.set_x2(ob.meanLn, bar_index + OB_EXTEND_BARS)

// ══════════════════════════════════════════════════════════
// 9. ENTRY SIGNALS
// ══════════════════════════════════════════════════════════
bool bullEvent = signalModeInput == "CHoCH only" ? isBullCHoCH : signalModeInput == "BOS only" ? isBullBOS : (isBullBOS or isBullCHoCH)
bool bearEvent = signalModeInput == "CHoCH only" ? isBearCHoCH : signalModeInput == "BOS only" ? isBearBOS : (isBearBOS or isBearCHoCH)

bool confirmedBuy  = bullEvent and htfBullOk
bool confirmedSell = bearEvent and htfBearOk

var string lastEventStr = "—"
if isBullBOS
    lastEventStr := "BOS ▲"
if isBullCHoCH
    lastEventStr := "CHoCH ▲"
if isBearBOS
    lastEventStr := "BOS ▼"
if isBearCHoCH
    lastEventStr := "CHoCH ▼"

// ══════════════════════════════════════════════════════════
// 10. RISK MANAGEMENT — single position, SL/TP/BE, win-rate
// ══════════════════════════════════════════════════════════
[effSLMult, effTP1, effTP2, effTP3] = switch riskPresetInput
    "Conservative" => [2.5, 1.0, 2.0, 4.0]
    "Aggressive"   => [1.0, 1.5, 2.5, 4.0]
    "Scalping"     => [0.8, 0.8, 1.5, 2.0]
    "Custom"       => [slMultInput, tp1MultInput, tp2MultInput, tp3MultInput]
    =>                [1.5, 1.0, 2.0, 3.0]   // Balanced

float riskAtr    = nz(ta.atr(atrLenRiskInput), 0.0)
float slDistance = riskAtr * effSLMult

var float activeEntry = na
var float activeSL    = na
var float activeTP1   = na
var float activeTP2   = na
var float activeTP3   = na
var int   activeDir   = 0
var int   entryBar    = na

var bool tp1Reached = false
var bool tp2Reached = false
var bool tp3Reached = false
var bool beActive   = false

// Session win-rate counters + recent-form strip (reset on reload / input change)
var int    statWins   = 0
var int    statLosses = 0
var string formStr    = ""

bool canOpen   = activeDir == 0
bool openLong  = confirmedBuy  and slDistance > 0 and canOpen
bool openShort = confirmedSell and slDistance > 0 and canOpen

if openLong
    activeEntry := close
    activeSL    := close - slDistance
    activeTP1   := close + slDistance * effTP1
    activeTP2   := close + slDistance * effTP2
    activeTP3   := close + slDistance * effTP3
    activeDir   := 1
    entryBar    := bar_index
    tp1Reached  := false
    tp2Reached  := false
    tp3Reached  := false
    beActive    := false

if openShort
    activeEntry := close
    activeSL    := close + slDistance
    activeTP1   := close - slDistance * effTP1
    activeTP2   := close - slDistance * effTP2
    activeTP3   := close - slDistance * effTP3
    activeDir   := -1
    entryBar    := bar_index
    tp1Reached  := false
    tp2Reached  := false
    tp3Reached  := false
    beActive    := false

bool  beActiveAtBarStart = beActive
float effectiveSL        = activeSL

bool canCheckHit = activeDir != 0 and not na(entryBar) and bar_index > entryBar and barstate.isconfirmed

bool slHit  = canCheckHit and (activeDir == 1 ? low  <= effectiveSL : high >= effectiveSL)
bool tp1Hit = canCheckHit and (activeDir == 1 ? high >= activeTP1   : low  <= activeTP1)
bool tp2Hit = canCheckHit and (activeDir == 1 ? high >= activeTP2   : low  <= activeTP2)
bool tp3Hit = canCheckHit and (activeDir == 1 ? high >= activeTP3   : low  <= activeTP3)

bool tp1FirstTouch = tp1Hit and not tp1Reached and not slHit
bool tp2FirstTouch = tp2Hit and not tp2Reached and not slHit
bool tp3FirstTouch = tp3Hit and not tp3Reached and not slHit

if tp1FirstTouch
    tp1Reached := true
if tp2FirstTouch
    tp2Reached := true
if tp3FirstTouch
    tp3Reached := true

bool beJustActivated = false
if useBreakEvenInput and tp1FirstTouch and not beActive
    activeSL        := activeEntry
    beActive        := true
    beJustActivated := true

var float hitSL    = na
var float hitEntry = na
if slHit
    hitSL    := effectiveSL
    hitEntry := activeEntry

float exitEntry = activeEntry
float exitSL    = effectiveSL
float exitTP1   = activeTP1
float exitTP2   = activeTP2
float exitTP3   = activeTP3
bool  exitBeActive = beActiveAtBarStart
bool  displayTp1Reached = tp1Reached
bool  displayTp2Reached = tp2Reached
bool  displayTp3Reached = tp3Reached

// Closure: SL, BE-stop (= SL once moved to entry) or TP3
if (slHit or tp3Hit) and activeDir != 0
    bool tradeWin = tp1Reached
    if tradeWin
        statWins  += 1
    else
        statLosses += 1
    // Recent-form strip: ▰ = win (TP1 touched), ▱ = loss
    formStr := formStr + (tradeWin ? "▰" : "▱")
    if str.length(formStr) > FORM_LEN
        formStr := str.substring(formStr, str.length(formStr) - FORM_LEN)
    activeDir   := 0
    activeSL    := na
    activeTP1   := na
    activeTP2   := na
    activeTP3   := na
    activeEntry := na
    entryBar    := na
    tp1Reached  := false
    tp2Reached  := false
    tp3Reached  := false
    beActive    := false

// ══════════════════════════════════════════════════════════
// 11. ATR TREND LINE (direction tied to structure / CHoCH)
// ══════════════════════════════════════════════════════════
float atrTLraw = nz(ta.atr(atrTrendLenInput), 0.0)
float atrTL    = ta.ema(atrTLraw, atrSmoothInput)
float atrSrc   = hl2

float longBand  = atrSrc - atrTrendMultInput * atrTL
float shortBand = atrSrc + atrTrendMultInput * atrTL

bool atrFlip = structTrend != structTrend[1]

var float atrTrendLine = na
if structTrend == 1
    atrTrendLine := atrFlip or na(atrTrendLine[1]) ? longBand : math.max(atrTrendLine[1], longBand)
else if structTrend == -1
    atrTrendLine := atrFlip or na(atrTrendLine[1]) ? shortBand : math.min(atrTrendLine[1], shortBand)
else
    atrTrendLine := na

// ══════════════════════════════════════════════════════════
// 12. PLOTS (entry markers + ATR trend line)
// ══════════════════════════════════════════════════════════
plotshape(showSignalsInput and openLong ? low : na, "Buy",
     style = shape.labelup, location = location.belowbar,
     color = BULL_COLOR, textcolor = BULL_LABEL_TEXT, text = "Long ▲", size = size.small)

plotshape(showSignalsInput and openShort ? high : na, "Sell",
     style = shape.labeldown, location = location.abovebar,
     color = BEAR_COLOR, textcolor = BEAR_LABEL_TEXT, text = "Short ▼", size = size.small)

plot(showAtrTrendInput and structTrend == 1  and not atrFlip ? atrTrendLine : na, "ATR Trend ▲",
     color = BULL_COLOR, linewidth = 2, style = plot.style_linebr)
plot(showAtrTrendInput and structTrend == -1 and not atrFlip ? atrTrendLine : na, "ATR Trend ▼",
     color = BEAR_COLOR, linewidth = 2, style = plot.style_linebr)

plotshape(showAtrTrendInput and atrFlip and structTrend == 1  ? atrTrendLine : na, "CHoCH Flip Up",
     style = shape.circle, location = location.absolute, color = BULL_COLOR, size = size.tiny)
plotshape(showAtrTrendInput and atrFlip and structTrend == -1 ? atrTrendLine : na, "CHoCH Flip Down",
     style = shape.circle, location = location.absolute, color = BEAR_COLOR, size = size.tiny)

// ══════════════════════════════════════════════════════════
// 13. SL/TP LINES & LABELS (persist until next entry)
// ══════════════════════════════════════════════════════════
var line slLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na
var line entryLine = na

var label slLabel = na
var label tp1Label = na
var label tp2Label = na
var label tp3Label = na
var label entryLabel = na

if (openLong or openShort) and showSlTpInput
    line.delete(slLine),  line.delete(tp1Line)
    line.delete(tp2Line), line.delete(tp3Line)
    line.delete(entryLine)
    label.delete(slLabel),  label.delete(tp1Label)
    label.delete(tp2Label), label.delete(tp3Label)
    label.delete(entryLabel)

    int x1 = bar_index
    int x2 = bar_index + LINE_FORWARD_BARS

    entryLine := line.new(x1, activeEntry, x2, activeEntry, color = ENTRY_COLOR, style = entryLineStyle, width = 1)
    slLine    := line.new(x1, activeSL,    x2, activeSL,    color = SL_COLOR,    style = slLineStyle,    width = 2)
    tp1Line   := line.new(x1, activeTP1,   x2, activeTP1,   color = TP1_COLOR,   style = tpLineStyle,    width = 1)
    tp2Line   := line.new(x1, activeTP2,   x2, activeTP2,   color = TP2_COLOR,   style = tpLineStyle,    width = 1)
    tp3Line   := line.new(x1, activeTP3,   x2, activeTP3,   color = TP3_COLOR,   style = tpLineStyle,    width = 1)

    if showSlTpLabelsInput
        int lblX = x2 + LABEL_OFFSET_BARS
        string entryS = str.tostring(activeEntry, format.mintick)
        string slS    = fmtPrice(activeSL)  + formatPctFromEntry(activeSL,  activeEntry)
        string tp1S   = fmtPrice(activeTP1) + formatPctFromEntry(activeTP1, activeEntry)
        string tp2S   = fmtPrice(activeTP2) + formatPctFromEntry(activeTP2, activeEntry)
        string tp3S   = fmtPrice(activeTP3) + formatPctFromEntry(activeTP3, activeEntry)

        entryLabel := label.new(lblX, activeEntry, "ENTRY " + entryS,
             color = ENTRY_COLOR, textcolor = LABEL_TEXT, style = label.style_label_left, size = labelSize)
        slLabel    := label.new(lblX, activeSL,  "SL "  + slS,
             color = SL_COLOR, textcolor = LABEL_TEXT, style = label.style_label_left, size = labelSize)
        tp1Label   := label.new(lblX, activeTP1, "TP1 " + tp1S,
             color = TP_LABEL_COLOR, textcolor = LABEL_TEXT, style = label.style_label_left, size = labelSize)
        tp2Label   := label.new(lblX, activeTP2, "TP2 " + tp2S,
             color = TP_LABEL_COLOR, textcolor = LABEL_TEXT, style = label.style_label_left, size = labelSize)
        tp3Label   := label.new(lblX, activeTP3, "TP3 " + tp3S,
             color = TP_LABEL_COLOR, textcolor = LABEL_TEXT, style = label.style_label_left, size = labelSize)

if showSlTpInput and not na(tp1Line) and displayTp1Reached
    line.set_color(tp1Line, TP_HIT_COLOR)
    line.set_style(tp1Line, line.style_solid)
    if showSlTpLabelsInput and not na(tp1Label)
        label.set_text(tp1Label, "TP1 ✓ " + fmtPrice(exitTP1) + formatPctFromEntry(exitTP1, exitEntry))
        label.set_color(tp1Label, TP_HIT_COLOR)
if showSlTpInput and not na(tp2Line) and displayTp2Reached
    line.set_color(tp2Line, TP_HIT_COLOR)
    line.set_style(tp2Line, line.style_solid)
    if showSlTpLabelsInput and not na(tp2Label)
        label.set_text(tp2Label, "TP2 ✓ " + fmtPrice(exitTP2) + formatPctFromEntry(exitTP2, exitEntry))
        label.set_color(tp2Label, TP_HIT_COLOR)
if showSlTpInput and not na(tp3Line) and displayTp3Reached
    line.set_color(tp3Line, TP_HIT_COLOR)
    line.set_style(tp3Line, line.style_solid)
    if showSlTpLabelsInput and not na(tp3Label)
        label.set_text(tp3Label, "TP3 ✓ " + fmtPrice(exitTP3) + formatPctFromEntry(exitTP3, exitEntry))
        label.set_color(tp3Label, TP_HIT_COLOR)

if showSlTpInput and beActive and activeDir != 0
    if not na(slLine)
        line.set_color(slLine, color.new(SL_COLOR, BE_DIM_TRANSP))
    if showSlTpLabelsInput
        if not na(slLabel)
            label.set_color(slLabel, color.new(SL_COLOR, BE_DIM_TRANSP))
        if not na(entryLabel)
            string entryS = str.tostring(activeEntry, format.mintick)
            label.set_text(entryLabel, "ENTRY " + entryS + "  → SL (BE)")
            label.set_color(entryLabel, BE_COLOR)

if activeDir != 0 and showSlTpInput and not na(slLine)
    int newX2   = bar_index + LINE_UPDATE_BARS
    int newLblX = newX2 + LABEL_OFFSET_BARS
    line.set_x2(slLine,    newX2)
    line.set_x2(tp1Line,   newX2)
    line.set_x2(tp2Line,   newX2)
    line.set_x2(tp3Line,   newX2)
    line.set_x2(entryLine, newX2)
    if showSlTpLabelsInput and not na(slLabel)
        label.set_x(slLabel,    newLblX)
        label.set_x(tp1Label,   newLblX)
        label.set_x(tp2Label,   newLblX)
        label.set_x(tp3Label,   newLblX)
        label.set_x(entryLabel, newLblX)

// ══════════════════════════════════════════════════════════
// 14. DASHBOARD (sectioned, dynamic height, gauges, tooltips)
// ══════════════════════════════════════════════════════════
var table dashTable = na

if showDashInput and barstate.islast
    // ── Values ──
    string trendWord = structTrend == 1 ? "Bullish" : structTrend == -1 ? "Bearish" : "Neutral"
    color  trendCol  = structTrend == 1 ? BULL_TEXT : structTrend == -1 ? BEAR_TEXT : NEUTRAL_TEXT
    color  headerBg  = structTrend == 1 ? HEADER_BG_BULL : structTrend == -1 ? HEADER_BG_BEAR : HEADER_BG_FLAT

    string signalStr = activeDir == 1 ? "LONG" : activeDir == -1 ? "SHORT" : "Wait"
    color  signalCol = activeDir == 1 ? BULL_TEXT : activeDir == -1 ? BEAR_TEXT : TEXT_MUTED

    float currentRR = activeDir != 0 ? effTP1 : 0.0
    float slDistPct = activeDir != 0 and not na(activeEntry) and activeEntry != 0 ? math.abs(activeEntry - activeSL) / activeEntry * 100 : 0.0

    string dashSL  = activeDir != 0 and not na(activeSL)  ? (beActive ? "BE @ " : "") + str.tostring(activeSL, format.mintick) : "—"
    string dashTP1 = activeDir != 0 and not na(activeTP1) ? (tp1Reached ? "✓ " : "") + str.tostring(activeTP1, format.mintick) : "—"
    string dashTP2 = activeDir != 0 and not na(activeTP2) ? (tp2Reached ? "✓ " : "") + str.tostring(activeTP2, format.mintick) : "—"
    string dashTP3 = activeDir != 0 and not na(activeTP3) ? (tp3Reached ? "✓ " : "") + str.tostring(activeTP3, format.mintick) : "—"
    color  dashSlCol  = beActive   ? BE_COLOR     : SL_COLOR
    color  dashTp1Col = tp1Reached ? TP_HIT_COLOR : TP_LABEL_COLOR
    color  dashTp2Col = tp2Reached ? TP_HIT_COLOR : TP_LABEL_COLOR
    color  dashTp3Col = tp3Reached ? TP_HIT_COLOR : TP_LABEL_COLOR

    string dashRR   = str.tostring(currentRR, "#.#") + "R"
    string dashDist = str.tostring(slDistPct, "#.##") + "%"
    color  rrColor   = currentRR >= 1.5 ? BULL_TEXT : currentRR >= 1.0 ? NEUTRAL_TEXT : BEAR_TEXT
    color  distColor = slDistPct > 3.0 ? BEAR_TEXT : slDistPct > 1.0 ? NEUTRAL_TEXT : BULL_TEXT

    int    closedTrades = statWins + statLosses
    float  winRate      = closedTrades > 0 ? statWins / float(closedTrades) * 100.0 : 0.0
    string dashWL       = str.tostring(statWins) + " / " + str.tostring(statLosses)
    string dashWR       = closedTrades > 0 ? str.tostring(winRate, "#.#") + "%  " + buildGauge(winRate, 100, 8) : "—"
    color  wrCol        = closedTrades == 0 ? TEXT_MUTED : winRate >= 55.0 ? BULL_TEXT : winRate >= 45.0 ? NEUTRAL_TEXT : BEAR_TEXT
    string dashForm     = formStr == "" ? "—" : formStr

    // ── Row count (dynamic) ──
    int marketRows = showMarketSecInput ? 5 : 0
    int tradeRows  = showTradeSecInput  ? (activeDir != 0 ? 7 : 2) : 0
    int statsRows  = showStatsSecInput  ? 5 : 0
    int totalRows  = 2 + marketRows + tradeRows + statsRows

    // ── Rebuild table to fit current state (one table at a time) ──
    if not na(dashTable)
        table.delete(dashTable)
    dashTable := table.new(dashPos, 2, totalRows, bgcolor = TABLE_BG, border_color = TABLE_BORDER, border_width = 1, frame_color = TABLE_BORDER, frame_width = 1)

    int   r  = 0
    bool  zeb = false
    color rb = TABLE_BG

    // Header (trend-tinted)
    table.cell(dashTable, 0, r, "◆ Meridian · " + trendWord, text_color = HEADER_TEXT, bgcolor = headerBg, text_size = size.small, text_halign = text.align_center)
    table.merge_cells(dashTable, 0, r, 1, r)
    r += 1

    // ── Market ──
    if showMarketSecInput
        table.cell(dashTable, 0, r, "— Market —", text_color = TEXT_MUTED, bgcolor = TABLE_ROW_ALT, text_size = size.tiny, text_halign = text.align_center)
        table.merge_cells(dashTable, 0, r, 1, r)
        r += 1
        rb := zeb ? TABLE_ROW_ALT : TABLE_BG
        table.cell(dashTable, 0, r, "Trend", text_color = TEXT_MUTED, text_size = size.small, bgcolor = rb, tooltip = "Structure trend from the latest confirmed BOS / CHoCH.")
        table.cell(dashTable, 1, r, trendWord, text_color = trendCol, text_size = size.small, bgcolor = rb)
        r += 1
        zeb := not zeb
        rb := zeb ? TABLE_ROW_ALT : TABLE_BG
        table.cell(dashTable, 0, r, "Signal", text_color = TEXT_MUTED, text_size = size.small, bgcolor = rb, tooltip = "Current position. A new trade opens only while flat.")
        table.cell(dashTable, 1, r, signalStr, text_color = signalCol, text_size = size.small, bgcolor = rb)
        r += 1
        zeb := not zeb
        rb := zeb ? TABLE_ROW_ALT : TABLE_BG
        table.cell(dashTable, 0, r, "Last event", text_color = TEXT_MUTED, text_size = size.small, bgcolor = rb, tooltip = "Most recent structure event.")
        table.cell(dashTable, 1, r, lastEventStr, text_color = TEXT_COLOR, text_size = size.small, bgcolor = rb)
        r += 1
        zeb := not zeb
        rb := zeb ? TABLE_ROW_ALT : TABLE_BG
        table.cell(dashTable, 0, r, "Timeframe", text_color = TEXT_MUTED, text_size = size.small, bgcolor = rb)
        table.cell(dashTable, 1, r, timeframe.period, text_color = TEXT_COLOR, text_size = size.small, bgcolor = rb)
        r += 1
        zeb := not zeb

    // ── Trade (collapses to one row when flat) ──
    if showTradeSecInput
        table.cell(dashTable, 0, r, "— Trade —", text_color = TEXT_MUTED, bgcolor = TABLE_ROW_ALT, text_size = size.tiny, text_halign = text.align_center)
        table.merge_cells(dashTable, 0, r, 1, r)
        r += 1
        if activeDir != 0
            rb := zeb ? TABLE_ROW_ALT : TABLE_BG
            table.cell(dashTable, 0, r, "SL", text_color = TEXT_MUTED, text_size = size.small, bgcolor = rb, tooltip = "Active stop. 'BE @' = moved to entry after TP1.")
            table.cell(dashTable, 1, r, dashSL, text_color = dashSlCol, text_size = size.small, bgcolor = rb)
            r += 1
            zeb := not zeb
            rb := zeb ? TABLE_ROW_ALT : TABLE_BG
            table.cell(dashTable, 0, r, "TP1", text_color = TEXT_MUTED, text_size = size.small, bgcolor = rb, tooltip = "✓ = touched (counts as a win).")
            table.cell(dashTable, 1, r, dashTP1, text_color = dashTp1Col, text_size = size.small, bgcolor = rb)
            r += 1
            zeb := not zeb
            rb := zeb ? TABLE_ROW_ALT : TABLE_BG
            table.cell(dashTable, 0, r, "TP2", text_color = TEXT_MUTED, text_size = size.small, bgcolor = rb)
            table.cell(dashTable, 1, r, dashTP2, text_color = dashTp2Col, text_size = size.small, bgcolor = rb)
            r += 1
            zeb := not zeb
            rb := zeb ? TABLE_ROW_ALT : TABLE_BG
            table.cell(dashTable, 0, r, "TP3", text_color = TEXT_MUTED, text_size = size.small, bgcolor = rb, tooltip = "Final target. Touching it closes the trade.")
            table.cell(dashTable, 1, r, dashTP3, text_color = dashTp3Col, text_size = size.small, bgcolor = rb)
            r += 1
            zeb := not zeb
            rb := zeb ? TABLE_ROW_ALT : TABLE_BG
            table.cell(dashTable, 0, r, "R:R (TP1)", text_color = TEXT_MUTED, text_size = size.small, bgcolor = rb, tooltip = "Reward-to-risk at TP1.")
            table.cell(dashTable, 1, r, dashRR, text_color = rrColor, text_size = size.small, bgcolor = rb)
            r += 1
            zeb := not zeb
            rb := zeb ? TABLE_ROW_ALT : TABLE_BG
            table.cell(dashTable, 0, r, "SL Dist %", text_color = TEXT_MUTED, text_size = size.small, bgcolor = rb, tooltip = "Stop distance as % of entry (not position risk).")
            table.cell(dashTable, 1, r, dashDist, text_color = distColor, text_size = size.small, bgcolor = rb)
            r += 1
            zeb := not zeb
        else
            rb := zeb ? TABLE_ROW_ALT : TABLE_BG
            table.cell(dashTable, 0, r, "Flat · waiting for setup", text_color = TEXT_MUTED, text_size = size.small, text_halign = text.align_center, bgcolor = rb)
            table.merge_cells(dashTable, 0, r, 1, r)
            r += 1
            zeb := not zeb

    // ── Stats ──
    if showStatsSecInput
        table.cell(dashTable, 0, r, "— Stats —", text_color = TEXT_MUTED, bgcolor = TABLE_ROW_ALT, text_size = size.tiny, text_halign = text.align_center)
        table.merge_cells(dashTable, 0, r, 1, r)
        r += 1
        rb := zeb ? TABLE_ROW_ALT : TABLE_BG
        table.cell(dashTable, 0, r, "Trades", text_color = TEXT_MUTED, text_size = size.small, bgcolor = rb, tooltip = "Closed trades this session (wins + losses).")
        table.cell(dashTable, 1, r, str.tostring(closedTrades), text_color = TEXT_COLOR, text_size = size.small, bgcolor = rb)
        r += 1
        zeb := not zeb
        rb := zeb ? TABLE_ROW_ALT : TABLE_BG
        table.cell(dashTable, 0, r, "W / L", text_color = TEXT_MUTED, text_size = size.small, bgcolor = rb)
        table.cell(dashTable, 1, r, dashWL, text_color = TEXT_COLOR, text_size = size.small, bgcolor = rb)
        r += 1
        zeb := not zeb
        rb := zeb ? TABLE_ROW_ALT : TABLE_BG
        table.cell(dashTable, 0, r, "Win rate", text_color = TEXT_MUTED, text_size = size.small, bgcolor = rb, tooltip = "Wins / closed. A trade is a WIN once TP1 is touched.")
        table.cell(dashTable, 1, r, dashWR, text_color = wrCol, text_size = size.small, bgcolor = rb)
        r += 1
        zeb := not zeb
        rb := zeb ? TABLE_ROW_ALT : TABLE_BG
        table.cell(dashTable, 0, r, "Form", text_color = TEXT_MUTED, text_size = size.small, bgcolor = rb, tooltip = "Last " + str.tostring(FORM_LEN) + " closed trades.  ▰ = win · ▱ = loss (newest on the right).")
        table.cell(dashTable, 1, r, dashForm, text_color = FORM_COLOR, text_size = size.small, bgcolor = rb)
        r += 1
        zeb := not zeb

    // Footer
    table.cell(dashTable, 0, r, "Meridian Flow · " + INDICATOR_VERSION, text_color = TEXT_MUTED, text_size = size.tiny, text_halign = text.align_center)
    table.merge_cells(dashTable, 0, r, 1, r)

// ══════════════════════════════════════════════════════════
// 15. WATERMARK
// ══════════════════════════════════════════════════════════
if barstate.islast and showWatermarkInput
    var table wmTable = table.new(position.bottom_center, 1, 1, bgcolor = color.new(color.black, 100), border_color = color.new(color.black, 100), border_width = 0, frame_color = color.new(color.black, 100), frame_width = 0)
    table.cell(wmTable, 0, 0, "WillyAlgoTrader", text_color = WM_COLOR, text_size = size.normal, text_halign = text.align_center, bgcolor = color.new(color.black, 100))

// ══════════════════════════════════════════════════════════
// 16. ALERTS (strings built only when an alert fires)
// ══════════════════════════════════════════════════════════
if openLong or openShort
    string aPrice = str.tostring(close, format.mintick)
    string aSL    = str.tostring(nz(activeSL),  format.mintick)
    string aTP1   = str.tostring(nz(activeTP1), format.mintick)
    string aTP2   = str.tostring(nz(activeTP2), format.mintick)
    string aTP3   = str.tostring(nz(activeTP3), format.mintick)
    string aRR    = str.tostring(effTP1, "#.#")

    if openLong
        string jsonBuy = '{"action":"buy","ticker":"' + syminfo.tickerid + '","price":' + aPrice + ',"sl":' + aSL + ',"tp1":' + aTP1 + ',"tp2":' + aTP2 + ',"tp3":' + aTP3 + ',"rr":' + aRR + '}'
        string textBuy = "🟢 LONG | " + syminfo.tickerid + " | TF: " + timeframe.period + " | Price: " + aPrice + " | SL: " + aSL + " | TP1: " + aTP1 + " | TP2: " + aTP2 + " | TP3: " + aTP3 + " | R:R: " + aRR
        alert(webhookInput ? jsonBuy : textBuy, alert.freq_once_per_bar_close)

    if openShort
        string jsonSell = '{"action":"sell","ticker":"' + syminfo.tickerid + '","price":' + aPrice + ',"sl":' + aSL + ',"tp1":' + aTP1 + ',"tp2":' + aTP2 + ',"tp3":' + aTP3 + ',"rr":' + aRR + '}'
        string textSell = "🔴 SHORT | " + syminfo.tickerid + " | TF: " + timeframe.period + " | Price: " + aPrice + " | SL: " + aSL + " | TP1: " + aTP1 + " | TP2: " + aTP2 + " | TP3: " + aTP3 + " | R:R: " + aRR
        alert(webhookInput ? jsonSell : textSell, alert.freq_once_per_bar_close)

if slHit and showSlHitAlertInput
    string textSlHit = (exitBeActive ? "🛡️ BE STOP-OUT | " : "🛑 SL HIT | ") + syminfo.tickerid +
         " | Entry: " + str.tostring(nz(hitEntry), format.mintick) + " | SL: " + str.tostring(nz(hitSL), format.mintick)
    alert(textSlHit, alert.freq_once_per_bar_close)

if beJustActivated and alertTpHitInput
    alert("🛡️ BREAK-EVEN | " + syminfo.tickerid + " | SL moved to " + str.tostring(nz(exitEntry), format.mintick), alert.freq_once_per_bar_close)
if tp1FirstTouch and alertTpHitInput
    alert("🎯 TP1 HIT | " + syminfo.tickerid + " | Price: " + str.tostring(nz(exitTP1), format.mintick), alert.freq_once_per_bar_close)
if tp2FirstTouch and alertTpHitInput
    alert("🎯🎯 TP2 HIT | " + syminfo.tickerid + " | Price: " + str.tostring(nz(exitTP2), format.mintick), alert.freq_once_per_bar_close)
if tp3FirstTouch and alertTpHitInput
    alert("🏆 TP3 HIT | " + syminfo.tickerid + " | Price: " + str.tostring(nz(exitTP3), format.mintick), alert.freq_once_per_bar_close)
````

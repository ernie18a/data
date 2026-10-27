# Mirage Liquidity Sweep Pro [WillyAlgoTrader]

- url: https://www.tradingview.com/script/qBUHu6aW-Mirage-Liquidity-Sweep-Pro-WillyAlgoTrader/
- type: indicator
- pine_id: PUB;238f0e26eb3d4efd8211be89ce462f28
- version: 1.0

## Description

[b]💧 Mirage Liquidity Sweep Pro[/b] is a free overlay toolkit that detects liquidity sweeps (stop-hunts), scores each one on a transparent 0-100 quality scale, optionally waits for a market-structure shift (CHoCH) to confirm, and then auto-builds a complete trade plan — wick-based stop, three take-profits, break-even logic, and a projected liquidity target — all on the bar the signal fires.

The core insight: price doesn't reverse at random support and resistance — it reverses where resting orders (liquidity) get consumed. A swing high above the market holds Buy-Side Liquidity (BSL); a swing low below it holds Sell-Side Liquidity (SSL). When price spikes through one of those levels and then closes back inside, that is a sweep: the move grabbed liquidity and rejected. Mirage finds those exact events, measures how clean the rejection was, and turns the strong ones into structured setups. It works on any market and any timeframe.


[b]🧩 WHY THESE COMPONENTS WORK TOGETHER[/b]

A raw sweep detector fires on every wick that pokes a level — most of which go nowhere. A pure structure tool (CHoCH/BOS) tells you the trend flipped but not whether liquidity was actually taken first. A risk calculator gives you a stop and targets but has no idea where the trade should go. Used separately, each one leaves a gap the others could fill.

Mirage fuses them into a single pipeline:

[b]Swing memory → Liquidity sweep detection → 5-factor quality score → CHoCH structure confirmation → Wick-anchored risk engine (SL / TP1-3 / break-even) → Liquidity target projection → Outcome tracking & stats[/b]

The swing engine remembers recent highs and lows and tags them as resting liquidity. The sweep detector only triggers when a level is pierced and reclaimed on the close — a stop-hunt, not a clean break. The quality score then rates that sweep so weak pokes are filtered out before they ever become signals. CHoCH confirmation (optional) makes price prove the reversal by breaking minor structure before you commit. The risk engine anchors the stop to the actual sweep wick — the precise point invalidating the idea — and projects the next opposite pool of liquidity as the logical objective. Finally, every closed setup is tracked so you can see the strategy's behavior in real time.

Without the score, you drown in low-quality sweeps. Without CHoCH, you front-run reversals that never come. Without wick-anchored risk, your stop sits in an arbitrary place. Without the liquidity target, you have no idea where the move is actually drawn. The combination is what turns "a wick touched a level" into a complete, rule-based trade.


[b]🔍 WHAT MAKES IT ORIGINAL[/b]

1️⃣ [b]5-factor sweep quality score (0-100) — the heart of the system.[/b]

Every detected sweep is scored before it can qualify. The score blends five independent, normalized factors:

 — 📐 [b]Wick depth (weight 0.30):[/b] wickComp = min( max(wick, 0) / ATR , 1.0 ). For a bullish sweep, wick = min(open, close) − low; for bearish, wick = high − max(open, close). Bigger rejection wick relative to ATR = stronger grab.
 — 🔄 [b]Reclaim (weight 0.25):[/b] rclComp = min( max(reclaim, 0) / ATR , 1.0 ). Bullish reclaim = close − level; bearish = level − close. Measures how decisively price closed back on the right side of the swept level.
 — 🕯️ [b]Close position (weight 0.20):[/b] closePos = (close − low) / (high − low). For bulls the raw value is used; for bears it is inverted (1 − closePos). Rewards candles that close near the rejection extreme.
 — 📊 [b]Volume (weight 0.15):[/b] volComp = clamp( (volRatio − 1) / (volMult − 1) , 0, 1 ), where volRatio = volume / SMA(volume, 21) and volMult defaults to 1.5×. On volume-less feeds this factor neutralizes to 0.5 automatically.
 — 🧭 [b]HTF bias (weight 0.10):[/b] htfComp = 1.0 if the sweep aligns with the higher-timeframe EMA trend, else 0 (or 0.5 if the filter is off).

Final score = (wickComp×0.30 + rclComp×0.25 + cpComp×0.20 + volComp×0.15 + htfComp×0.10) × 100.

A sweep only qualifies when its score ≥ Min Sweep Score (default 50). This single number is your master quality dial.

2️⃣ [b]Sweep vs. break distinction — closes decide everything.[/b]

A stored level is treated three ways. For a swing low: if price closes below it, the level is simply consumed (a real breakdown — no signal). If price wicks below but closes back above, that is a bullish sweep. The mirror logic applies to swing highs. This close-based rule is what separates a genuine liquidity grab from a trend break, and it is why the detector ignores most noise wicks.

3️⃣ [b]Two-stage signal — sweep then CHoCH confirmation.[/b]

With confirmation on (default), a qualifying sweep becomes a pending setup rather than an instant entry. The signal only fires when price then breaks the most recent minor pivot (Change of Character) within the Confirmation Window (default 13 bars). Minor structure is tracked with its own pivot length (default 8). Turn confirmation off and the signal fires on the sweep bar itself — responsive, but earlier. Pending setups expire automatically if no CHoCH arrives in time.

4️⃣ [b]Wick-anchored risk engine with a minimum-distance guard.[/b]

Entry = close of the signal bar. The stop is placed beyond the actual sweep wick:
 — Long: SL = sweepLow − ATR×buffer
 — Short: SL = sweepHigh + ATR×buffer
If the resulting stop sits closer than ATR×0.5 to entry, it is widened to exactly ATR×0.5 to avoid an unrealistically tight stop. Risk distance dist = |entry − SL|, and targets are pure R-multiples: TP1/TP2/TP3 = entry ± dist × multiplier.

5️⃣ [b]Risk presets — one click from scalp to swing.[/b]

Five presets set buffer / TP1 / TP2 / TP3 instantly (SL buffer in ×ATR, TPs in R):
 — Conservative: 0.50 / 1R / 2R / 4R
 — Balanced (default): 0.25 / 1R / 2R / 3R
 — Aggressive: 0.15 / 1.5R / 2.5R / 4R
 — Scalping: 0.10 / 0.8R / 1.5R / 2R
 — Custom: your own values

6️⃣ [b]Break-even automation after TP1.[/b]

When TP1 is touched, the stop moves to entry. From the next bar a wick back to entry closes the trade at break-even — protecting the position once it has paid out its first target. The SL line dims and the entry label annotates "→ SL (BE)" so the state is always visible.

7️⃣ [b]Resting liquidity map — BSL / SSL + EQH / EQL.[/b]

Every un-swept swing high is drawn as Buy-Side Liquidity and every un-swept swing low as Sell-Side Liquidity (most recent N per side, default 6). A level disappears the instant it is swept, so the map always shows live, untapped pools. Consecutive near-equal swings (within Equal H/L Tolerance × ATR, default 0.15) are connected as Equal Highs / Equal Lows — the strongest liquidity magnets and the most common sweep targets.

8️⃣ [b]Liquidity target projection — the draw-on-liquidity objective.[/b]

On each entry, Mirage projects a line to the nearest opposite un-swept liquidity pool: a long aims at the closest BSL above entry, a short at the closest SSL below. This is the logical place the move is "drawn" toward, independent of the fixed R-multiple TPs.

9️⃣ [b]Higher-timeframe bias as a soft, non-repainting filter.[/b]

The HTF trend (close vs. EMA, default 4H / EMA-50) is requested with confirmed prior-bar values and contributes only 10% of the score — it nudges quality rather than hard-blocking signals, so counter-trend sweeps can still fire if they are clean enough.

🔟 [b]Honest, transparent outcome tracking.[/b]

The dashboard records every closed setup: wins, losses, win rate (with a visual gauge), and a recent-form strip of the last 10 results. A setup is counted as a WIN the moment TP1 is touched, and a trade closes on a stop-out or when TP3 is reached. This definition is stated openly so you always know exactly what the numbers mean — see Important Notes for the full caveats.


[b]🧠 HOW IT WORKS — CALCULATION FLOW[/b]

[b]Step 1 — Map the swings:[/b] Confirmed pivot highs/lows (length 21) are stored in bounded memory and tagged as un-swept BSL/SSL.

[b]Step 2 — Detect a sweep:[/b] On each new bar, un-swept levels within Max Sweep Distance (default 80 bars) are checked. A wick-through-then-close-back-inside event is flagged as a sweep; a close beyond the level just marks it consumed.

[b]Step 3 — Score it:[/b] The 5-factor formula rates the sweep 0-100. Only sweeps at or above Min Sweep Score, after warm-up, on a confirmed bar, qualify.

[b]Step 4 — Resolve the signal:[/b] If CHoCH confirmation is on, the sweep becomes a pending setup and waits for a minor-structure break within the window; otherwise it fires immediately.

[b]Step 5 — Build the trade:[/b] Entry, wick-based SL (with the ATR×0.5 minimum guard), and TP1/TP2/TP3 as R-multiples are calculated. Only one position runs at a time.

[b]Step 6 — Manage it:[/b] Bar by bar, hits are checked on confirmed bars. TP1 triggers break-even; a stop-out or TP3 closes and records the result.

[b]Step 7 — Visualize & report:[/b] Lines, labels, the liquidity map, the target projection, and the dashboard all update live.


[b]📖 HOW TO USE (beginner-friendly)[/b]

🎯 [b]Quick start — 5 steps:[/b]
 1. Add the indicator to any chart and any timeframe (15m–4H is a good starting range).
 2. Leave every setting on default. The Balanced preset and a Min Score of 50 are a sensible baseline.
 3. Wait for a green [b]Long ▲[/b] or red [b]Short ▼[/b] marker. That is your entry signal — and it only appears once a sweep has passed the quality score (and, by default, a CHoCH confirmation).
 4. Read the entry, stop, and three targets straight off the chart lines and labels. The numbers are already calculated for you.
 5. Manage the trade using TP1/TP2/TP3 and the automatic break-even — see the dashboard for live status.

👁️ [b]Reading the chart — what each thing means:[/b]
 — 🟢 [b]Long ▲ / 🔴 Short ▼[/b] = a confirmed signal (a trade opened here).
 — ✖️ [b]Small × mark[/b] = a raw sweep (liquidity was grabbed) — shown even when no trade opens.
 — [b]Dashed level line[/b] = the swing high/low that was swept, drawn from where it formed.
 — [b]Thick vertical tick[/b] = the penetration depth — how far the wick pierced beyond the level.
 — [b]ENTRY line[/b] = where the trade opened. [b]SL line (red)[/b] = stop. [b]TP1/TP2/TP3 lines[/b] = targets; a target turns solid teal with a ✓ once touched.
 — [b]Gold dashed line "◎ Liquidity Target"[/b] = the nearest opposite liquidity pool the move is drawn toward.
 — [b]Dotted BSL / SSL lines[/b] = un-swept resting liquidity above (BSL) and below (SSL) — likely future sweep targets.
 — [b]EQH / EQL connectors[/b] = near-equal highs/lows = the strongest liquidity magnets.
 — [b]% on labels[/b] = distance from entry to each level, e.g. "SL 1.2300 (−0.36%)".

📊 [b]Dashboard fields:[/b]
 — [b]Trend:[/b] direction of the most recent qualifying signal.
 — [b]HTF Bias:[/b] higher-timeframe EMA bias (the soft 10% score factor).
 — [b]Signal:[/b] LONG / SHORT when in a trade, "Wait" when flat (a new trade opens only while flat).
 — [b]Last sweep:[/b] most recent qualifying sweep and its 0-100 score.
 — [b]SL / TP1 / TP2 / TP3:[/b] live levels; ✓ marks a target already touched; "BE @" marks a stop moved to break-even.
 — [b]R:R (TP1):[/b] reward-to-risk at the first target.
 — [b]SL Dist %:[/b] stop distance as a percent of entry.
 — [b]Trades / W-L / Win rate / Form:[/b] session results, with a gauge and a ▰/▱ strip of the last 10 outcomes (newest on the right).

🔧 [b]Tuning guide (common fixes):[/b]
 — [b]Too few signals?[/b] Lower Min Sweep Score (e.g. 40-45), shorten Swing Length, or turn off CHoCH confirmation for earlier entries.
 — [b]Too many weak signals?[/b] Raise Min Sweep Score (60+), keep CHoCH on, and enable the Volume filter.
 — [b]Stops feel too tight/wide?[/b] Switch presets (Conservative widens, Scalping tightens) or set the SL buffer manually in Custom.
 — [b]Choppy market?[/b] Increase Swing Length and lean on the HTF bias filter so only trend-aligned sweeps score highly.

💡 [b]Trading ideas:[/b]
 — [b]EQH/EQL hunt:[/b] watch a marked Equal High/Low — when it is swept and reclaimed with a high score, the rejection is often clean.
 — [b]Draw-on-liquidity:[/b] use the gold target line as a partial-exit zone; price frequently reaches the next opposite pool.
 — [b]Confirmation toggle:[/b] use CHoCH-on for selective swing entries, CHoCH-off on lower timeframes for faster scalps.
 — [b]Bias stacking:[/b] take only signals whose direction matches the HTF Bias field for higher-conviction entries.


[b]⚙️ KEY SETTINGS[/b]

⚙️ [b]Main:[/b]
 — [b]Swing Length[/b] (default 21): pivot lookback for the liquidity pools to sweep. Higher = bigger, cleaner pools.
 — [b]Max Sweep Distance[/b] (default 80 bars): a swing can only be swept within this many bars of forming.
 — [b]Min Sweep Score[/b] (default 50): master quality gate, 0-100.

🧩 [b]Confirmation:[/b]
 — [b]Require CHoCH Confirmation[/b] (default on): wait for a structure break after the sweep.
 — [b]Structure Pivot Length[/b] (default 8): minor pivots used to detect the CHoCH.
 — [b]Confirmation Window[/b] (default 13 bars): how long a pending setup waits before expiring.

🔍 [b]Filters:[/b]
 — [b]Use Volume Filter[/b] (default on) / [b]Volume MA Length[/b] (21) / [b]Volume Spike ×MA[/b] (1.5).
 — [b]Use HTF Bias[/b] (default on) / [b]HTF Timeframe[/b] (240) / [b]HTF EMA Length[/b] (50).

🛡️ [b]Risk Management:[/b]
 — [b]Risk Preset[/b] (default Balanced): Conservative / Balanced / Aggressive / Scalping / Custom.
 — [b]ATR Length[/b] (14) / [b]SL Buffer ×ATR[/b] (0.25, Custom) / [b]TP1/TP2/TP3 ×Risk[/b] (1.0 / 2.0 / 3.0, Custom).
 — [b]Break-Even After TP1[/b] (default on), plus SL/TP line and label visibility, % distance, and line styles.

💧 [b]Liquidity:[/b]
 — [b]Show Resting Liquidity (BSL/SSL)[/b] (on) / [b]Max Levels / Side[/b] (6) / [b]Line Extend[/b] (10 bars).
 — [b]Show Equal Highs/Lows[/b] (on) / [b]Equal H/L Tolerance ×ATR[/b] (0.15) / [b]Show Liquidity Target[/b] (on).

🎨 [b]Visual & Dashboard:[/b]
 — [b]Theme[/b] (Auto / Dark / Light), raw sweep marks, swept-level line, penetration, signals, score labels, watermark, label font size.
 — [b]Dashboard[/b] position, font size, and Market / Trade / Stats section toggles.


[b]🔔 ALERTS[/b]

 — 🟢 [b]LONG entry[/b] — ticker, timeframe, score, price, SL, TP1, TP2, TP3, R:R.
 — 🔴 [b]SHORT entry[/b] — same payload.
 — 🛑 [b]SL Hit[/b] (and 🛡️ Break-Even stop-out) — entry and stop levels.
 — 🛡️ [b]Break-Even activated[/b] — when the stop moves to entry.
 — 🎯 [b]TP1 / TP2 / TP3 touched[/b] — price at each target.

All alerts support plain-text and JSON webhook formats and fire on bar close (alert.freq_once_per_bar_close).


[b]⚠️ IMPORTANT NOTES[/b]

 — 🚫 [b]No repainting.[/b] Signals require confirmed bars (barstate.isconfirmed); swing pivots use equal left/right lookback, so the actual pivot is in the past by Swing Length bars and is drawn only once confirmed — this is delayed confirmation, not repainting of future values. The HTF bias is requested with confirmed prior-bar values, and all alerts fire on bar close.
 — 📊 [b]How wins are counted:[/b] a setup is marked a WIN as soon as TP1 is touched (1R by default). A trade that reaches TP1 and then reverses to break-even still counts as a win. This is a deliberately transparent definition, not an inflated one — read it that way when interpreting the win rate.
 — 📐 [b]Stats are session-based and simulated.[/b] The dashboard reflects the indicator's own single-position logic on the loaded history and resets when the chart reloads. It is not a broker-accurate backtest and includes no fees, slippage, or funding.
 — ⚖️ [b]One position at a time.[/b] A new signal can only open while flat — sweeps that occur mid-trade are shown but not traded.
 — 🛠️ [b]This is an analysis tool, not an automated trading bot.[/b] It detects sweeps, scores them, confirms with structure, and builds a structured trade plan — trade decisions remain yours.
 — 🌐 [b]Universal.[/b] Works on all markets and all timeframes. Volume-dependent scoring auto-neutralizes on feeds without volume.

Free to use — add it to your chart and explore. Feedback and feature requests are welcome.

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════
// MIRAGE LIQUIDITY SWEEP PRO [WillyAlgoTrader]
// ══════════════════════════════════════════════════════════
// Author:  Willy | WillyAlgoTrader
// Version: 1.3.1

indicator(
     title            = "Mirage Liquidity Sweep Pro [WillyAlgoTrader]",
     shorttitle       = "Mirage LSP",
     overlay          = true,
     max_lines_count  = 500,
     max_labels_count = 500,
     max_boxes_count  = 500,
     max_bars_back    = 5000)

// ══════════════════════════════════════════════════════════
// 1. CONSTANTS
// ══════════════════════════════════════════════════════════
GRP_MAIN    = "⚙️ Main Settings"
GRP_CONFIRM = "🧩 Confirmation"
GRP_FILTER  = "🔍 Filters"
GRP_RISK    = "🛡️ Risk Management"
GRP_LIQ     = "💧 Liquidity"
GRP_VISUAL  = "🎨 Visual"
GRP_DASH    = "📊 Dashboard"
GRP_ALERT   = "🔔 Alerts"
GRP_COLORS  = "🎨 Colors"

INDICATOR_VERSION = "v1.3.1"
MAX_STORED        = 25    // bounded swing memory
MAX_SIG_LABELS    = 50    // bounded score labels
LINE_FORWARD_BARS = 20
LINE_UPDATE_BARS  = 5
LABEL_OFFSET_BARS = 1
BE_DIM_TRANSP     = 70
FORM_LEN          = 10    // recent-form strip length
MAX_EQ_MARKS      = 16    // bounded EQH/EQL drawings

// ══════════════════════════════════════════════════════════
// 2. INPUTS
// ══════════════════════════════════════════════════════════

// ── Main ────────────────────────────────────────────────────
swingLenInput     = input.int(21, "Swing Length", minval = 3, maxval = 100, group = GRP_MAIN,
     tooltip = "Pivot lookback for major swings to sweep.\n• Higher = bigger/cleaner liquidity pools\n• Lower = more frequent, smaller sweeps\n• Recommended: 10-25")
lookbackBarsInput = input.int(80, "Max Sweep Distance (bars)", minval = 5, maxval = 500, group = GRP_MAIN,
     tooltip = "A swing can only be swept within this many bars of forming.")
minScoreInput     = input.int(50, "Min Sweep Score", minval = 0, maxval = 100, group = GRP_MAIN,
     tooltip = "Minimum 0-100 quality score for a sweep to qualify.\n• Higher = fewer, stronger sweeps\n• ~45-60 balanced, 65+ strict")

// ── Confirmation ────────────────────────────────────────────
requireConfirmInput = input.bool(true, "Require CHoCH Confirmation", group = GRP_CONFIRM,
     tooltip = "OFF: signal fires on the sweep bar (responsive).\nON: sweep becomes a setup; signal fires only after price breaks recent market structure (CHoCH).")
minorLenInput       = input.int(8, "Structure Pivot Length", minval = 2, maxval = 30, group = GRP_CONFIRM,
     tooltip = "Pivot length for the minor structure used to confirm CHoCH after a sweep.")
confirmWindowInput  = input.int(13, "Confirmation Window (bars)", minval = 1, maxval = 100, group = GRP_CONFIRM,
     tooltip = "Max bars to wait for a CHoCH after a sweep before the setup expires.")

// ── Filters ─────────────────────────────────────────────────
useVolumeInput  = input.bool(true, "Use Volume Filter", group = GRP_FILTER,
     tooltip = "Reward sweeps on above-average volume. Auto-bypassed on volume-less feeds.")
volLenInput     = input.int(21, "Volume MA Length", minval = 2, maxval = 200, group = GRP_FILTER,
     tooltip = "Length of the volume moving average baseline.")
volMultInput    = input.float(1.5, "Volume Spike (×MA)", minval = 1.1, maxval = 5.0, step = 0.1, group = GRP_FILTER,
     tooltip = "Volume multiple of its MA that counts as a full-strength spike.")
useHtfInput     = input.bool(true, "Use HTF Bias (score)", group = GRP_FILTER,
     tooltip = "Reward sweeps aligned with the higher-timeframe EMA trend (soft, +10% of score).")
htfTfInput      = input.timeframe("240", "HTF Timeframe", group = GRP_FILTER,
     tooltip = "Higher timeframe for trend bias. Empty = current TF.")
htfEmaLenInput  = input.int(50, "HTF EMA Length", minval = 5, maxval = 400, group = GRP_FILTER,
     tooltip = "EMA length on the HTF (close above = bullish bias).")

// ── Risk Management ─────────────────────────────────────────
riskPresetInput = input.string("Balanced", "Risk Preset",
     options = ["Conservative", "Balanced", "Aggressive", "Scalping", "Custom"], group = GRP_RISK,
     tooltip = "Quick presets (SL buffer ×ATR beyond wick / TP1 / TP2 / TP3 in R):\n• Conservative: 0.5 / 1R / 2R / 4R\n• Balanced: 0.25 / 1R / 2R / 3R\n• Aggressive: 0.15 / 1.5R / 2.5R / 4R\n• Scalping: 0.1 / 0.8R / 1.5R / 2R\n• Custom: manual inputs below")
atrLenRiskInput = input.int(14, "ATR Length", minval = 5, maxval = 50, group = GRP_RISK,
     tooltip = "ATR period for the stop buffer and minimum-distance guard.")
slBufferInput   = input.float(0.25, "SL Buffer ×ATR (Custom)", minval = 0.0, maxval = 3.0, step = 0.05, group = GRP_RISK,
     tooltip = "Extra room beyond the sweep wick for the stop. Used when preset = Custom.")
tp1MultInput    = input.float(1.0, "TP1 ×Risk (Custom)", minval = 0.5, maxval = 5.0,  step = 0.1, group = GRP_RISK,
     tooltip = "TP1 as multiple of risk. 1.0 = 1:1 R:R.")
tp2MultInput    = input.float(2.0, "TP2 ×Risk (Custom)", minval = 1.0, maxval = 10.0, step = 0.1, group = GRP_RISK)
tp3MultInput    = input.float(3.0, "TP3 ×Risk (Custom)", minval = 1.5, maxval = 15.0, step = 0.1, group = GRP_RISK)

useBreakEvenInput = input.bool(true, "Break-Even After TP1", group = GRP_RISK,
     tooltip = "When TP1 is touched, move SL to entry. From the next bar, a wick to entry closes at break-even. (TP1 still counts as a WIN.)")

showSlTpInput        = input.bool(true, "Show SL/TP Lines",  group = GRP_RISK)
showSlTpLabelsInput  = input.bool(true, "Show SL/TP Labels", group = GRP_RISK)
showPctOnLabelsInput = input.bool(true, "Show % Distance on Labels", group = GRP_RISK,
     tooltip = "Append % distance from entry to SL/TP labels, e.g. 'SL 1.2300 (-0.36%)'.")
entryLineStyleInput  = input.string("Dotted", "Entry Line Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_RISK,
     tooltip = "Entry is a reference, not an action level — keep it subtle.")
slLineStyleInput     = input.string("Solid", "SL Line Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_RISK)
tpLineStyleInput     = input.string("Dashed", "TP Line Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_RISK,
     tooltip = "Style for TP1/TP2/TP3. On hit, a TP line turns solid teal.")

// ── Liquidity ───────────────────────────────────────────────
showLiquidityInput = input.bool(true, "Show Resting Liquidity (BSL/SSL)", group = GRP_LIQ,
     tooltip = "Mark un-swept swing highs as Buy-Side Liquidity (BSL) and un-swept swing lows as Sell-Side Liquidity (SSL). A level disappears once it is swept.")
maxLiqInput        = input.int(6, "Max Liquidity Levels / Side", minval = 1, maxval = 25, group = GRP_LIQ,
     tooltip = "Show only the N most recent un-swept levels per side (keeps the chart clean).")
liqExtendInput     = input.int(10, "Liquidity Line Extend (bars)", minval = 0, maxval = 100, group = GRP_LIQ,
     tooltip = "How far past the current bar to project resting-liquidity lines.")
showLiqLabelsInput = input.bool(true, "Show BSL/SSL Labels", group = GRP_LIQ,
     tooltip = "Tag each resting-liquidity line BSL / SSL.")
showEqualsInput    = input.bool(true, "Show Equal Highs/Lows (EQH/EQL)", group = GRP_LIQ,
     tooltip = "Connect consecutive near-equal swing highs/lows — prime liquidity magnets and the most common sweep targets.")
eqTolInput         = input.float(0.15, "Equal H/L Tolerance (×ATR)", minval = 0.02, maxval = 1.0, step = 0.01, group = GRP_LIQ,
     tooltip = "Two swings count as 'equal' if within this fraction of ATR.\nLower = stricter (only very tight equals).")
showTargetInput    = input.bool(true, "Show Liquidity Target (on entry)", group = GRP_LIQ,
     tooltip = "On each entry, project a line to the nearest opposite un-swept liquidity — the logical draw-on-liquidity objective.")

// ── Visual ──────────────────────────────────────────────────
themeInput           = input.string("Auto", "Theme", options = ["Auto", "Dark", "Light"], group = GRP_VISUAL,
     tooltip = "Chart color theme.\n• Auto: detect from chart background\n• Dark / Light: force a palette")
showSweepsInput      = input.bool(true,  "Show Raw Sweep Marks",  group = GRP_VISUAL,
     tooltip = "Small × at the wick where liquidity was grabbed (shown even while in a trade).")
showSweepLineInput   = input.bool(true,  "Show Swept Extremum Line", group = GRP_VISUAL,
     tooltip = "Horizontal line at the swing high/low that was swept, drawn from where that swing formed to the sweep bar.")
sweepLineExtendInput = input.int(8, "Swept Line Extend (bars)", minval = 0, maxval = 100, group = GRP_VISUAL,
     tooltip = "How many bars to extend the swept-level line past the sweep bar (swept liquidity often acts as future S/R).")
showSweepPenInput    = input.bool(true,  "Show Sweep Penetration", group = GRP_VISUAL,
     tooltip = "Highlight the wick segment that pierced beyond the level — the depth of the liquidity grab.")
maxSweepVisInput     = input.int(15, "Max Sweep Drawings", minval = 1, maxval = 60, group = GRP_VISUAL,
     tooltip = "Cap on stored swept-level / penetration drawings. Oldest are removed first.")
showSignalsInput     = input.bool(true,  "Show Buy/Sell Signals", group = GRP_VISUAL,
     tooltip = "Print Long ▲ / Short ▼ markers when a trade opens.")
showScoreLabelsInput = input.bool(false, "Show Score Labels", group = GRP_VISUAL,
     tooltip = "Floating 0-100 score next to each qualifying sweep.")
showLevelInput       = input.bool(true,  "Show Swept Level Line", group = GRP_VISUAL,
     tooltip = "Line marking the liquidity level taken by the active trade.")
labelFontSizeInput   = input.string("Small", "SL/TP Label Font Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = GRP_VISUAL,
     tooltip = "Font size for SL/TP/Entry labels.")
showWatermarkInput   = input.bool(true,  "Show Watermark", group = GRP_VISUAL,
     tooltip = "Display 'WillyAlgoTrader' watermark on chart.")

// ── Dashboard ───────────────────────────────────────────────
showDashInput      = input.bool(true, "Show Dashboard", group = GRP_DASH)
dashPosStr         = input.string("Top Right", "Dashboard Position",
     options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Middle Right"], group = GRP_DASH)
dashFontSizeInput  = input.string("Small", "Dashboard Font Size",
     options = ["Small", "Normal", "Large", "Huge"], group = GRP_DASH,
     tooltip = "Font size for the dashboard table. Section dividers and the\nversion footer render one step smaller to preserve hierarchy.")
showMarketSecInput = input.bool(true, "  ├ Market section", group = GRP_DASH,
     tooltip = "Trend, HTF bias, Signal, Last sweep, Timeframe.")
showTradeSecInput  = input.bool(true, "  ├ Trade section", group = GRP_DASH,
     tooltip = "SL, TP1-3, R:R, SL distance. Collapses to one row when flat.")
showStatsSecInput  = input.bool(true, "  └ Stats section", group = GRP_DASH,
     tooltip = "Trades, W/L, Win Rate (+gauge), recent Form.")

// ── Alerts ──────────────────────────────────────────────────
webhookInput        = input.bool(false, "Webhook JSON Format", group = GRP_ALERT,
     tooltip = "Send entry alerts as JSON for webhook / autotrading.")
showSlHitAlertInput = input.bool(true,  "Alert on SL Hit", group = GRP_ALERT,
     tooltip = "Fire an alert when price hits the active stop-loss.")
alertTpHitInput     = input.bool(false, "Alert on TP / Break-Even", group = GRP_ALERT,
     tooltip = "Fire alerts when TP1/TP2/TP3 are touched and on break-even.")

// ── Colors ──────────────────────────────────────────────────
bullColorInput = input.color(#00E676, "Bull", inline = "c", group = GRP_COLORS)
bearColorInput = input.color(#FF5252, "Bear", inline = "c", group = GRP_COLORS)

// ══════════════════════════════════════════════════════════
// 3. THEME DETECTION & COLORS
// ══════════════════════════════════════════════════════════
isDark = switch themeInput
    "Dark"  => true
    "Light" => false
    =>         color.r(chart.bg_color) < 128

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

HEADER_BG_BULL = color.new(#0F6E56, 0)
HEADER_BG_BEAR = color.new(#A32D2D, 0)
HEADER_BG_FLAT = color.new(#2962FF, 0)

// Premium, muted, theme-aware risk palette
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
LEVEL_COLOR    = isDark ? color.new(#B0BEC5, 30) : color.new(#546E7A, 30)

// Liquidity family — cohesive steel hue; gold accent for the objective
LIQ_COLOR      = isDark ? color.new(#90A4AE, 40) : color.new(#607D8B, 40)
LIQ_TEXT       = isDark ? #B0BEC5                : #455A64
EQ_COLOR       = isDark ? color.new(#B0BEC5, 0)  : color.new(#455A64, 0)
EQ_TEXT        = isDark ? #ECEFF1                : #263238
TARGET_COLOR   = isDark ? color.new(#FFCA28, 15) : color.new(#F9A825, 15)
TARGET_TEXT    = isDark ? #FFD54F                : #F57F17

// ══════════════════════════════════════════════════════════
// 4. FUNCTIONS & HELPERS
// ══════════════════════════════════════════════════════════
// Sweep quality score 0-100. dir: 1 = bullish (low swept), -1 = bearish (high swept).
f_score(int dir, float lvl, float atrv, float volComp, float htfComp) =>
    float rng = high - low
    float sc  = 0.0
    if rng > 0 and atrv > 0 and not na(lvl)
        float wick     = dir == 1 ? math.min(open, close) - low : high - math.max(open, close)
        float reclaim  = dir == 1 ? close - lvl : lvl - close
        float closePos = (close - low) / rng
        float cpComp   = dir == 1 ? closePos : 1.0 - closePos
        float wickComp = math.min(math.max(wick, 0.0) / atrv, 1.0)
        float rclComp  = math.min(math.max(reclaim, 0.0) / atrv, 1.0)
        sc := (wickComp * 0.30 + rclComp * 0.25 + cpComp * 0.20 + volComp * 0.15 + htfComp * 0.10) * 100.0
    sc

buildGauge(float value, float maxVal, int width) =>
    string result = ""
    int filled = maxVal <= 0 ? 0 : math.round(math.min(width, math.max(0.0, value / maxVal * width)))
    for i = 0 to width - 1
        result += i < filled ? "▰" : "▱"
    result

fmtPrice(float v) =>
    na(v) ? "—" : str.tostring(v, format.mintick)

formatPctFromEntry(float level, float entry) =>
    string res = ""
    if showPctOnLabelsInput and not na(level) and not na(entry) and entry != 0
        float pct  = (level - entry) / entry * 100.0
        string sign = pct >= 0 ? "+" : ""
        res := " (" + sign + str.tostring(pct, "#.##") + "%)"
    res

lineStyleFromString(string s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

sizeFromString(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : s == "Large" ? size.large : s == "Huge" ? size.huge : size.small

// One step smaller — used for section dividers and the version footer
sizeDownFromString(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.tiny : s == "Normal" ? size.small : s == "Large" ? size.normal : s == "Huge" ? size.large : size.tiny

dashPos = switch dashPosStr
    "Top Left"     => position.top_left
    "Top Right"    => position.top_right
    "Bottom Left"  => position.bottom_left
    "Bottom Right" => position.bottom_right
    "Middle Right" => position.middle_right
    =>                position.top_right

entryLineStyle = lineStyleFromString(entryLineStyleInput)
slLineStyle    = lineStyleFromString(slLineStyleInput)
tpLineStyle    = lineStyleFromString(tpLineStyleInput)
labelSize      = sizeFromString(labelFontSizeInput)
dashFontSize    = sizeFromString(dashFontSizeInput)
dashFontSizeSub = sizeDownFromString(dashFontSizeInput)

// ══════════════════════════════════════════════════════════
// 5. WARMUP & BASE CALCULATIONS
// ══════════════════════════════════════════════════════════
int  WARMUP_BARS = math.max(swingLenInput * 2, 50)
bool isWarmedUp  = bar_index >= WARMUP_BARS

float riskAtr = nz(ta.atr(atrLenRiskInput), 0.0)

bool  hasVolume = nz(volume, 0) > 0
float volSmaRaw = ta.sma(volume, volLenInput)           // called every bar (consistency)
float volSma    = hasVolume ? volSmaRaw : na
float volRatio  = hasVolume and not na(volSma) and volSma > 0 ? volume / volSma : na
float volComp   = useVolumeInput ? (not na(volRatio) ? math.min(math.max((volRatio - 1.0) / math.max(volMultInput - 1.0, 0.1), 0.0), 1.0) : 0.5) : 0.5

// HTF bias — request.security UNCONDITIONAL, non-repaint via [1] + lookahead_on
[htfClose, htfEma] = request.security(syminfo.tickerid, htfTfInput, [close[1], ta.ema(close, htfEmaLenInput)[1]], barmerge.gaps_off, barmerge.lookahead_on)
bool  htfValid = not na(htfClose) and not na(htfEma)
bool  htfBull  = htfValid and htfClose > htfEma
bool  htfBear  = htfValid and htfClose < htfEma
float htfCompBull = not useHtfInput ? 0.5 : (htfBull ? 1.0 : 0.0)
float htfCompBear = not useHtfInput ? 0.5 : (htfBear ? 1.0 : 0.0)

// ══════════════════════════════════════════════════════════
// 6. SWING MEMORY (bounded) & MINOR STRUCTURE
// ══════════════════════════════════════════════════════════
var array<float> hiLvl  = array.new<float>()
var array<int>   hiBar  = array.new<int>()
var array<bool>  hiUsed = array.new<bool>()
var array<float> loLvl  = array.new<float>()
var array<int>   loBar  = array.new<int>()
var array<bool>  loUsed = array.new<bool>()

var array<line>  eqLines  = array.new<line>()
var array<label> eqLabels = array.new<label>()

float ph = ta.pivothigh(swingLenInput, swingLenInput)
float pl = ta.pivotlow(swingLenInput, swingLenInput)

if not na(ph)
    array.push(hiLvl, ph)
    array.push(hiBar, bar_index - swingLenInput)
    array.push(hiUsed, false)
    if showEqualsInput and riskAtr > 0 and array.size(hiLvl) >= 2
        float prevH  = array.get(hiLvl, array.size(hiLvl) - 2)
        int   prevHB = array.get(hiBar, array.size(hiLvl) - 2)
        if math.abs(ph - prevH) <= riskAtr * eqTolInput
            float eqLvl = math.max(ph, prevH)
            line eqLn = line.new(prevHB, eqLvl, bar_index - swingLenInput, eqLvl, color = EQ_COLOR, style = line.style_solid, width = 1)
            array.push(eqLines, eqLn)
            label eqLb = na
            if showLiqLabelsInput
                eqLb := label.new(bar_index - swingLenInput, eqLvl, "EQH", color = color.new(color.black, 100), textcolor = EQ_TEXT, style = label.style_label_left, size = size.tiny)
            array.push(eqLabels, eqLb)
            if array.size(eqLines) > MAX_EQ_MARKS
                line oldEqL = array.shift(eqLines)
                label oldEqB = array.shift(eqLabels)
                if not na(oldEqL)
                    line.delete(oldEqL)
                if not na(oldEqB)
                    label.delete(oldEqB)
    if array.size(hiLvl) > MAX_STORED
        array.shift(hiLvl)
        array.shift(hiBar)
        array.shift(hiUsed)

if not na(pl)
    array.push(loLvl, pl)
    array.push(loBar, bar_index - swingLenInput)
    array.push(loUsed, false)
    if showEqualsInput and riskAtr > 0 and array.size(loLvl) >= 2
        float prevL  = array.get(loLvl, array.size(loLvl) - 2)
        int   prevLB = array.get(loBar, array.size(loLvl) - 2)
        if math.abs(pl - prevL) <= riskAtr * eqTolInput
            float eqLvl = math.min(pl, prevL)
            line eqLn = line.new(prevLB, eqLvl, bar_index - swingLenInput, eqLvl, color = EQ_COLOR, style = line.style_solid, width = 1)
            array.push(eqLines, eqLn)
            label eqLb = na
            if showLiqLabelsInput
                eqLb := label.new(bar_index - swingLenInput, eqLvl, "EQL", color = color.new(color.black, 100), textcolor = EQ_TEXT, style = label.style_label_up, size = size.tiny)
            array.push(eqLabels, eqLb)
            if array.size(eqLines) > MAX_EQ_MARKS
                line oldEqL = array.shift(eqLines)
                label oldEqB = array.shift(eqLabels)
                if not na(oldEqL)
                    line.delete(oldEqL)
                if not na(oldEqB)
                    label.delete(oldEqB)
    if array.size(loLvl) > MAX_STORED
        array.shift(loLvl)
        array.shift(loBar)
        array.shift(loUsed)

float mph = ta.pivothigh(minorLenInput, minorLenInput)
float mpl = ta.pivotlow(minorLenInput, minorLenInput)
var float lastMinorHigh = na
var float lastMinorLow  = na
if not na(mph)
    lastMinorHigh := mph
if not na(mpl)
    lastMinorLow := mpl

// ══════════════════════════════════════════════════════════
// 7. SWEEP DETECTION (O(N) per bar)
// ══════════════════════════════════════════════════════════
bool  bullSweep = false
float bullLvl   = na
int   bullLvlBar = na
bool  bearSweep = false
float bearLvl   = na
int   bearLvlBar = na

int nlo = array.size(loLvl)
if nlo > 0
    for j = 0 to nlo - 1
        int idx = nlo - 1 - j
        if not array.get(loUsed, idx)
            float lvl = array.get(loLvl, idx)
            if bar_index - array.get(loBar, idx) <= lookbackBarsInput
                if close < lvl
                    array.set(loUsed, idx, true)
                else if low < lvl and close > lvl
                    array.set(loUsed, idx, true)
                    if not bullSweep
                        bullSweep := true
                        bullLvl   := lvl
                        bullLvlBar := array.get(loBar, idx)

int nhi = array.size(hiLvl)
if nhi > 0
    for j = 0 to nhi - 1
        int idx = nhi - 1 - j
        if not array.get(hiUsed, idx)
            float lvl = array.get(hiLvl, idx)
            if bar_index - array.get(hiBar, idx) <= lookbackBarsInput
                if close > lvl
                    array.set(hiUsed, idx, true)
                else if high > lvl and close < lvl
                    array.set(hiUsed, idx, true)
                    if not bearSweep
                        bearSweep := true
                        bearLvl   := lvl
                        bearLvlBar := array.get(hiBar, idx)

float bullScore = bullSweep ? f_score(1, bullLvl, riskAtr, volComp, htfCompBull) : 0.0
float bearScore = bearSweep ? f_score(-1, bearLvl, riskAtr, volComp, htfCompBear) : 0.0

bool bullQ = bullSweep and bullScore >= minScoreInput and isWarmedUp and barstate.isconfirmed
bool bearQ = bearSweep and bearScore >= minScoreInput and isWarmedUp and barstate.isconfirmed

// ══════════════════════════════════════════════════════════
// 8. SIGNAL RESOLUTION (immediate vs CHoCH-confirmed)
// ══════════════════════════════════════════════════════════
var int   pendingDir      = 0
var int   pendingStartBar = 0
var float pendingLvl      = na
var float pendingWick     = na
var float pendingScore    = na

bool  fireBull      = false
bool  fireBear      = false
float sigScore      = na
float anchorExtreme = na   // sweep wick: low for bull, high for bear
float sigLvl        = na

if requireConfirmInput
    if pendingDir != 0 and (bar_index - pendingStartBar) > confirmWindowInput
        pendingDir := 0
    if bullQ
        pendingDir      := 1
        pendingStartBar := bar_index
        pendingLvl      := bullLvl
        pendingWick     := low
        pendingScore    := bullScore
    if bearQ
        pendingDir      := -1
        pendingStartBar := bar_index
        pendingLvl      := bearLvl
        pendingWick     := high
        pendingScore    := bearScore
    if pendingDir == 1 and not na(lastMinorHigh) and close > lastMinorHigh and barstate.isconfirmed
        fireBull      := true
        sigScore      := pendingScore
        anchorExtreme := pendingWick
        sigLvl        := pendingLvl
        pendingDir    := 0
    if pendingDir == -1 and not na(lastMinorLow) and close < lastMinorLow and barstate.isconfirmed
        fireBear      := true
        sigScore      := pendingScore
        anchorExtreme := pendingWick
        sigLvl        := pendingLvl
        pendingDir    := 0
else
    if bullQ
        fireBull      := true
        sigScore      := bullScore
        anchorExtreme := low
        sigLvl        := bullLvl
    if bearQ
        fireBear      := true
        sigScore      := bearScore
        anchorExtreme := high
        sigLvl        := bearLvl

// ══════════════════════════════════════════════════════════
// 9. RISK MANAGEMENT — single position, wick-based SL, BE, win-rate
// ══════════════════════════════════════════════════════════
[effBuf, effTP1, effTP2, effTP3] = switch riskPresetInput
    "Conservative" => [0.50, 1.0, 2.0, 4.0]
    "Aggressive"   => [0.15, 1.5, 2.5, 4.0]
    "Scalping"     => [0.10, 0.8, 1.5, 2.0]
    "Custom"       => [slBufferInput, tp1MultInput, tp2MultInput, tp3MultInput]
    =>                [0.25, 1.0, 2.0, 3.0]   // Balanced

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

var int    statWins   = 0
var int    statLosses = 0
var string formStr    = ""

var int    sweepTrend = 0           // last signal direction (engine read)

bool sigConflict = fireBull and fireBear      // bar swept both sides → no clear direction
bool canOpen   = activeDir == 0
bool openLong  = fireBull and not sigConflict and riskAtr > 0 and canOpen
bool openShort = fireBear and not sigConflict and riskAtr > 0 and canOpen

if openLong
    activeEntry := close
    float rawSL = anchorExtreme - riskAtr * effBuf
    float dist  = math.abs(activeEntry - rawSL)
    if dist < riskAtr * 0.5
        rawSL := activeEntry - riskAtr * 0.5
        dist  := riskAtr * 0.5
    activeSL    := rawSL
    activeTP1   := activeEntry + dist * effTP1
    activeTP2   := activeEntry + dist * effTP2
    activeTP3   := activeEntry + dist * effTP3
    activeDir   := 1
    entryBar    := bar_index
    tp1Reached  := false
    tp2Reached  := false
    tp3Reached  := false
    beActive    := false
    sweepTrend  := 1

if openShort
    activeEntry := close
    float rawSL = anchorExtreme + riskAtr * effBuf
    float dist  = math.abs(rawSL - activeEntry)
    if dist < riskAtr * 0.5
        rawSL := activeEntry + riskAtr * 0.5
        dist  := riskAtr * 0.5
    activeSL    := rawSL
    activeTP1   := activeEntry - dist * effTP1
    activeTP2   := activeEntry - dist * effTP2
    activeTP3   := activeEntry - dist * effTP3
    activeDir   := -1
    entryBar    := bar_index
    tp1Reached  := false
    tp2Reached  := false
    tp3Reached  := false
    beActive    := false
    sweepTrend  := -1

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

// Snapshot BEFORE reset
var float hitSL    = na
var float hitEntry = na
if slHit
    hitSL    := effectiveSL
    hitEntry := activeEntry

float exitEntry         = activeEntry
float exitTP1           = activeTP1
float exitTP2           = activeTP2
float exitTP3           = activeTP3
bool  exitBeActive      = beActiveAtBarStart
bool  displayTp1Reached = tp1Reached
bool  displayTp2Reached = tp2Reached
bool  displayTp3Reached = tp3Reached

// Closure on SL / BE-stop / TP3
if (slHit or tp3Hit) and activeDir != 0
    bool tradeWin = tp1Reached
    if tradeWin
        statWins += 1
    else
        statLosses += 1
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

// Last sweep memory (dashboard)
var string lastSigType  = "—"
var float  lastSigScore = na
if fireBull
    lastSigType  := "Bullish"
    lastSigScore := sigScore
if fireBear
    lastSigType  := "Bearish"
    lastSigScore := sigScore

// ══════════════════════════════════════════════════════════
// 10. PLOTS (sweep marks + entry markers)
// ══════════════════════════════════════════════════════════
plotshape(showSweepsInput and bullQ ? low  : na, "Bull Sweep", shape.xcross, location.belowbar, color.new(BULL_COLOR, 35), size = size.tiny)
plotshape(showSweepsInput and bearQ ? high : na, "Bear Sweep", shape.xcross, location.abovebar, color.new(BEAR_COLOR, 35), size = size.tiny)

plotshape(showSignalsInput and openLong  ? low  : na, "Long",  shape.labelup,   location.belowbar, BULL_COLOR, textcolor = BULL_LABEL_TEXT, text = "Long ▲",  size = size.small)
plotshape(showSignalsInput and openShort ? high : na, "Short", shape.labeldown, location.abovebar, BEAR_COLOR, textcolor = BEAR_LABEL_TEXT, text = "Short ▼", size = size.small)

var array<label> sigLabels = array.new<label>()
if showScoreLabelsInput and (fireBull or fireBear)
    string lblTxt  = str.tostring(sigScore, "#")
    color  lblTcol = fireBull ? BULL_TEXT : BEAR_TEXT
    float  lblY    = fireBull ? low - riskAtr * 0.6 : high + riskAtr * 0.6
    label  lb = label.new(bar_index, lblY, lblTxt, color = color.new(color.black, 100), textcolor = lblTcol, style = label.style_none, size = size.small, tooltip = "Sweep quality: " + lblTxt + "/100")
    array.push(sigLabels, lb)
    if array.size(sigLabels) > MAX_SIG_LABELS
        label oldLb = array.shift(sigLabels)
        label.delete(oldLb)

// ══════════════════════════════════════════════════════════
// 11. SWEPT LEVEL LINE
// ══════════════════════════════════════════════════════════
var line levelLine = na
if (openLong or openShort) and showLevelInput
    line.delete(levelLine)
    if not na(sigLvl)
        levelLine := line.new(bar_index - 1, sigLvl, bar_index + LINE_UPDATE_BARS, sigLvl, color = LEVEL_COLOR, style = line.style_dotted, width = 1)
if activeDir != 0 and showLevelInput and not na(levelLine)
    line.set_x2(levelLine, bar_index + LINE_UPDATE_BARS)
if activeDir == 0 and showLevelInput and not na(levelLine)
    line.delete(levelLine)
    levelLine := na

// ══════════════════════════════════════════════════════════
// 11b. SWEEP LIQUIDITY VISUALS (per-sweep, bounded)
//   • level line  : horizontal at the swept extremum, swing origin → sweep
//   • penetration : vertical tick of the wick that pierced beyond the level
// ══════════════════════════════════════════════════════════
var array<line> swpLvlLines = array.new<line>()
var array<line> swpPenLines = array.new<line>()

bool drawBullVis = bullQ and (showSweepLineInput or showSweepPenInput)
bool drawBearVis = bearQ and (showSweepLineInput or showSweepPenInput)

if drawBullVis
    int   originBar = na(bullLvlBar) ? bar_index : bullLvlBar
    line  lvlLn = na
    line  penLn = na
    if showSweepLineInput
        lvlLn := line.new(originBar, bullLvl, bar_index + sweepLineExtendInput, bullLvl, color = color.new(BULL_COLOR, 45), style = line.style_dashed, width = 1)
    if showSweepPenInput
        penLn := line.new(bar_index, bullLvl, bar_index, low, color = BULL_COLOR, style = line.style_solid, width = 3)
    array.push(swpLvlLines, lvlLn)
    array.push(swpPenLines, penLn)

if drawBearVis
    int   originBar = na(bearLvlBar) ? bar_index : bearLvlBar
    line  lvlLn = na
    line  penLn = na
    if showSweepLineInput
        lvlLn := line.new(originBar, bearLvl, bar_index + sweepLineExtendInput, bearLvl, color = color.new(BEAR_COLOR, 45), style = line.style_dashed, width = 1)
    if showSweepPenInput
        penLn := line.new(bar_index, bearLvl, bar_index, high, color = BEAR_COLOR, style = line.style_solid, width = 3)
    array.push(swpLvlLines, lvlLn)
    array.push(swpPenLines, penLn)

if array.size(swpLvlLines) > maxSweepVisInput
    line oldLvl = array.shift(swpLvlLines)
    line oldPen = array.shift(swpPenLines)
    if not na(oldLvl)
        line.delete(oldLvl)
    if not na(oldPen)
        line.delete(oldPen)

// ══════════════════════════════════════════════════════════
// 11c. RESTING LIQUIDITY (BSL / SSL) + TARGET PROJECTION
// ══════════════════════════════════════════════════════════
var array<line>  liqLines  = array.new<line>()
var array<label> liqLabels = array.new<label>()

if showLiquidityInput and barstate.islast
    if array.size(liqLines) > 0
        for ci = 0 to array.size(liqLines) - 1
            line.delete(array.get(liqLines, ci))
    if array.size(liqLabels) > 0
        for ci = 0 to array.size(liqLabels) - 1
            label.delete(array.get(liqLabels, ci))
    array.clear(liqLines)
    array.clear(liqLabels)

    int rx = bar_index + liqExtendInput

    int drawnH = 0
    int nh = array.size(hiLvl)
    if nh > 0
        for k = 0 to nh - 1
            int idx = nh - 1 - k
            if drawnH < maxLiqInput and not array.get(hiUsed, idx)
                float lvl = array.get(hiLvl, idx)
                int   ob  = array.get(hiBar, idx)
                line ln = line.new(ob, lvl, rx, lvl, color = LIQ_COLOR, style = line.style_dotted, width = 1)
                array.push(liqLines, ln)
                if showLiqLabelsInput
                    label lb = label.new(rx, lvl, "BSL", color = color.new(color.black, 100), textcolor = LIQ_TEXT, style = label.style_label_left, size = size.tiny)
                    array.push(liqLabels, lb)
                drawnH += 1

    int drawnL = 0
    int nl = array.size(loLvl)
    if nl > 0
        for k = 0 to nl - 1
            int idx = nl - 1 - k
            if drawnL < maxLiqInput and not array.get(loUsed, idx)
                float lvl = array.get(loLvl, idx)
                int   ob  = array.get(loBar, idx)
                line ln = line.new(ob, lvl, rx, lvl, color = LIQ_COLOR, style = line.style_dotted, width = 1)
                array.push(liqLines, ln)
                if showLiqLabelsInput
                    label lb = label.new(rx, lvl, "SSL", color = color.new(color.black, 100), textcolor = LIQ_TEXT, style = label.style_label_left, size = size.tiny)
                    array.push(liqLabels, lb)
                drawnL += 1

// Target = nearest opposite un-swept liquidity, projected on entry
var line  targetLine  = na
var label targetLabel = na

if showTargetInput and (openLong or openShort)
    line.delete(targetLine)
    label.delete(targetLabel)
    targetLine  := na
    targetLabel := na
    float tgt = na
    if openLong
        float best = na
        int n = array.size(hiLvl)
        if n > 0
            for i = 0 to n - 1
                if not array.get(hiUsed, i)
                    float lvl = array.get(hiLvl, i)
                    if lvl > activeEntry and (na(best) or lvl < best)
                        best := lvl
        tgt := best
    if openShort
        float best = na
        int n = array.size(loLvl)
        if n > 0
            for i = 0 to n - 1
                if not array.get(loUsed, i)
                    float lvl = array.get(loLvl, i)
                    if lvl < activeEntry and (na(best) or lvl > best)
                        best := lvl
        tgt := best
    if not na(tgt)
        targetLine  := line.new(bar_index, tgt, bar_index + LINE_FORWARD_BARS, tgt, color = TARGET_COLOR, style = line.style_dashed, width = 1)
        targetLabel := label.new(bar_index + LINE_FORWARD_BARS, tgt, "◎ Liquidity Target", color = color.new(color.black, 100), textcolor = TARGET_TEXT, style = label.style_label_left, size = size.small)

if showTargetInput and activeDir != 0 and not na(targetLine)
    line.set_x2(targetLine, bar_index + LINE_UPDATE_BARS)
    if not na(targetLabel)
        label.set_x(targetLabel, bar_index + LINE_UPDATE_BARS)
if activeDir == 0 and not na(targetLine)
    line.delete(targetLine)
    label.delete(targetLabel)
    targetLine  := na
    targetLabel := na

// ══════════════════════════════════════════════════════════
// 12. SL/TP LINES & LABELS (persist until next entry)
// ══════════════════════════════════════════════════════════
var line slLine    = na
var line tp1Line   = na
var line tp2Line   = na
var line tp3Line   = na
var line entryLine = na

var label slLabel    = na
var label tp1Label   = na
var label tp2Label   = na
var label tp3Label   = na
var label entryLabel = na

if (openLong or openShort) and showSlTpInput
    line.delete(slLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)
    line.delete(entryLine)
    label.delete(slLabel)
    label.delete(tp1Label)
    label.delete(tp2Label)
    label.delete(tp3Label)
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

        entryLabel := label.new(lblX, activeEntry, "ENTRY " + entryS, color = ENTRY_COLOR, textcolor = LABEL_TEXT, style = label.style_label_left, size = labelSize)
        slLabel    := label.new(lblX, activeSL,  "SL "  + slS,  color = SL_COLOR,       textcolor = LABEL_TEXT, style = label.style_label_left, size = labelSize)
        tp1Label   := label.new(lblX, activeTP1, "TP1 " + tp1S, color = TP_LABEL_COLOR, textcolor = LABEL_TEXT, style = label.style_label_left, size = labelSize)
        tp2Label   := label.new(lblX, activeTP2, "TP2 " + tp2S, color = TP_LABEL_COLOR, textcolor = LABEL_TEXT, style = label.style_label_left, size = labelSize)
        tp3Label   := label.new(lblX, activeTP3, "TP3 " + tp3S, color = TP_LABEL_COLOR, textcolor = LABEL_TEXT, style = label.style_label_left, size = labelSize)

// TP-hit recolor (solid teal + ✓)
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

// Break-even: dim SL line/label, annotate entry
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

// Extend active lines to current bar
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
// 13. DASHBOARD (sectioned, dynamic height, gauge, tooltips)
// ══════════════════════════════════════════════════════════
var table dashTable = na

if showDashInput and barstate.islast
    string trendWord = sweepTrend == 1 ? "Bullish" : sweepTrend == -1 ? "Bearish" : "Neutral"
    color  trendCol  = sweepTrend == 1 ? BULL_TEXT : sweepTrend == -1 ? BEAR_TEXT : NEUTRAL_TEXT
    color  headerBg  = sweepTrend == 1 ? HEADER_BG_BULL : sweepTrend == -1 ? HEADER_BG_BEAR : HEADER_BG_FLAT

    string biasStr   = not useHtfInput ? "Off" : (htfBull ? "Bullish" : htfBear ? "Bearish" : "—")
    color  biasCol   = not useHtfInput ? TEXT_MUTED : (htfBull ? BULL_TEXT : htfBear ? BEAR_TEXT : TEXT_MUTED)

    string signalStr = activeDir == 1 ? "LONG" : activeDir == -1 ? "SHORT" : "Wait"
    color  signalCol = activeDir == 1 ? BULL_TEXT : activeDir == -1 ? BEAR_TEXT : TEXT_MUTED

    string lastSweepStr = lastSigType == "—" ? "—" : lastSigType + " " + (na(lastSigScore) ? "" : str.tostring(lastSigScore, "#"))
    color  lastSweepCol = lastSigType == "Bullish" ? BULL_TEXT : lastSigType == "Bearish" ? BEAR_TEXT : TEXT_MUTED

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

    int marketRows = showMarketSecInput ? 6 : 0
    int tradeRows  = showTradeSecInput  ? (activeDir != 0 ? 7 : 2) : 0
    int statsRows  = showStatsSecInput  ? 5 : 0
    int totalRows  = 2 + marketRows + tradeRows + statsRows

    if not na(dashTable)
        table.delete(dashTable)
    dashTable := table.new(dashPos, 2, totalRows, bgcolor = TABLE_BG, border_color = TABLE_BORDER, border_width = 1, frame_color = TABLE_BORDER, frame_width = 1)

    int  r   = 0
    bool zeb = false
    color rb = TABLE_BG

    table.cell(dashTable, 0, r, "◆ Mirage · " + trendWord, text_color = HEADER_TEXT, bgcolor = headerBg, text_size = dashFontSize, text_halign = text.align_center)
    table.merge_cells(dashTable, 0, r, 1, r)
    r += 1

    if showMarketSecInput
        table.cell(dashTable, 0, r, "— Market —", text_color = TEXT_MUTED, bgcolor = TABLE_ROW_ALT, text_size = dashFontSizeSub, text_halign = text.align_center)
        table.merge_cells(dashTable, 0, r, 1, r)
        r += 1
        rb := zeb ? TABLE_ROW_ALT : TABLE_BG
        table.cell(dashTable, 0, r, "Trend", text_color = TEXT_MUTED, text_size = dashFontSize, bgcolor = rb, tooltip = "Direction of the most recent qualifying sweep signal.")
        table.cell(dashTable, 1, r, trendWord, text_color = trendCol, text_size = dashFontSize, bgcolor = rb)
        r += 1
        zeb := not zeb
        rb := zeb ? TABLE_ROW_ALT : TABLE_BG
        table.cell(dashTable, 0, r, "HTF Bias", text_color = TEXT_MUTED, text_size = dashFontSize, bgcolor = rb, tooltip = "Higher-timeframe EMA bias (soft score component).")
        table.cell(dashTable, 1, r, biasStr, text_color = biasCol, text_size = dashFontSize, bgcolor = rb)
        r += 1
        zeb := not zeb
        rb := zeb ? TABLE_ROW_ALT : TABLE_BG
        table.cell(dashTable, 0, r, "Signal", text_color = TEXT_MUTED, text_size = dashFontSize, bgcolor = rb, tooltip = "Current position. A new trade opens only while flat.")
        table.cell(dashTable, 1, r, signalStr, text_color = signalCol, text_size = dashFontSize, bgcolor = rb)
        r += 1
        zeb := not zeb
        rb := zeb ? TABLE_ROW_ALT : TABLE_BG
        table.cell(dashTable, 0, r, "Last sweep", text_color = TEXT_MUTED, text_size = dashFontSize, bgcolor = rb, tooltip = "Most recent qualifying sweep + its 0-100 score.")
        table.cell(dashTable, 1, r, lastSweepStr, text_color = lastSweepCol, text_size = dashFontSize, bgcolor = rb)
        r += 1
        zeb := not zeb
        rb := zeb ? TABLE_ROW_ALT : TABLE_BG
        table.cell(dashTable, 0, r, "Timeframe", text_color = TEXT_MUTED, text_size = dashFontSize, bgcolor = rb)
        table.cell(dashTable, 1, r, timeframe.period, text_color = TEXT_COLOR, text_size = dashFontSize, bgcolor = rb)
        r += 1
        zeb := not zeb

    if showTradeSecInput
        table.cell(dashTable, 0, r, "— Trade —", text_color = TEXT_MUTED, bgcolor = TABLE_ROW_ALT, text_size = dashFontSizeSub, text_halign = text.align_center)
        table.merge_cells(dashTable, 0, r, 1, r)
        r += 1
        if activeDir != 0
            rb := zeb ? TABLE_ROW_ALT : TABLE_BG
            table.cell(dashTable, 0, r, "SL", text_color = TEXT_MUTED, text_size = dashFontSize, bgcolor = rb, tooltip = "Active stop. 'BE @' = moved to entry after TP1.")
            table.cell(dashTable, 1, r, dashSL, text_color = dashSlCol, text_size = dashFontSize, bgcolor = rb)
            r += 1
            zeb := not zeb
            rb := zeb ? TABLE_ROW_ALT : TABLE_BG
            table.cell(dashTable, 0, r, "TP1", text_color = TEXT_MUTED, text_size = dashFontSize, bgcolor = rb, tooltip = "✓ = touched (counts as a win).")
            table.cell(dashTable, 1, r, dashTP1, text_color = dashTp1Col, text_size = dashFontSize, bgcolor = rb)
            r += 1
            zeb := not zeb
            rb := zeb ? TABLE_ROW_ALT : TABLE_BG
            table.cell(dashTable, 0, r, "TP2", text_color = TEXT_MUTED, text_size = dashFontSize, bgcolor = rb)
            table.cell(dashTable, 1, r, dashTP2, text_color = dashTp2Col, text_size = dashFontSize, bgcolor = rb)
            r += 1
            zeb := not zeb
            rb := zeb ? TABLE_ROW_ALT : TABLE_BG
            table.cell(dashTable, 0, r, "TP3", text_color = TEXT_MUTED, text_size = dashFontSize, bgcolor = rb, tooltip = "Final target. Touching it closes the trade.")
            table.cell(dashTable, 1, r, dashTP3, text_color = dashTp3Col, text_size = dashFontSize, bgcolor = rb)
            r += 1
            zeb := not zeb
            rb := zeb ? TABLE_ROW_ALT : TABLE_BG
            table.cell(dashTable, 0, r, "R:R (TP1)", text_color = TEXT_MUTED, text_size = dashFontSize, bgcolor = rb, tooltip = "Reward-to-risk at TP1.")
            table.cell(dashTable, 1, r, dashRR, text_color = rrColor, text_size = dashFontSize, bgcolor = rb)
            r += 1
            zeb := not zeb
            rb := zeb ? TABLE_ROW_ALT : TABLE_BG
            table.cell(dashTable, 0, r, "SL Dist %", text_color = TEXT_MUTED, text_size = dashFontSize, bgcolor = rb, tooltip = "Stop distance as % of entry (not position risk).")
            table.cell(dashTable, 1, r, dashDist, text_color = distColor, text_size = dashFontSize, bgcolor = rb)
            r += 1
            zeb := not zeb
        else
            rb := zeb ? TABLE_ROW_ALT : TABLE_BG
            table.cell(dashTable, 0, r, "Flat · waiting for sweep", text_color = TEXT_MUTED, text_size = dashFontSize, text_halign = text.align_center, bgcolor = rb)
            table.merge_cells(dashTable, 0, r, 1, r)
            r += 1
            zeb := not zeb

    if showStatsSecInput
        table.cell(dashTable, 0, r, "— Stats —", text_color = TEXT_MUTED, bgcolor = TABLE_ROW_ALT, text_size = dashFontSizeSub, text_halign = text.align_center)
        table.merge_cells(dashTable, 0, r, 1, r)
        r += 1
        rb := zeb ? TABLE_ROW_ALT : TABLE_BG
        table.cell(dashTable, 0, r, "Trades", text_color = TEXT_MUTED, text_size = dashFontSize, bgcolor = rb, tooltip = "Closed trades this session (wins + losses).")
        table.cell(dashTable, 1, r, str.tostring(closedTrades), text_color = TEXT_COLOR, text_size = dashFontSize, bgcolor = rb)
        r += 1
        zeb := not zeb
        rb := zeb ? TABLE_ROW_ALT : TABLE_BG
        table.cell(dashTable, 0, r, "W / L", text_color = TEXT_MUTED, text_size = dashFontSize, bgcolor = rb)
        table.cell(dashTable, 1, r, dashWL, text_color = TEXT_COLOR, text_size = dashFontSize, bgcolor = rb)
        r += 1
        zeb := not zeb
        rb := zeb ? TABLE_ROW_ALT : TABLE_BG
        table.cell(dashTable, 0, r, "Win rate", text_color = TEXT_MUTED, text_size = dashFontSize, bgcolor = rb, tooltip = "Wins / closed. A trade is a WIN once TP1 is touched.")
        table.cell(dashTable, 1, r, dashWR, text_color = wrCol, text_size = dashFontSize, bgcolor = rb)
        r += 1
        zeb := not zeb
        rb := zeb ? TABLE_ROW_ALT : TABLE_BG
        table.cell(dashTable, 0, r, "Form", text_color = TEXT_MUTED, text_size = dashFontSize, bgcolor = rb, tooltip = "Last " + str.tostring(FORM_LEN) + " closed trades.  ▰ = win · ▱ = loss (newest right).")
        table.cell(dashTable, 1, r, dashForm, text_color = FORM_COLOR, text_size = dashFontSize, bgcolor = rb)
        r += 1
        zeb := not zeb

    table.cell(dashTable, 0, r, "Mirage LSP · " + INDICATOR_VERSION, text_color = TEXT_MUTED, text_size = dashFontSizeSub, text_halign = text.align_center)
    table.merge_cells(dashTable, 0, r, 1, r)

// ══════════════════════════════════════════════════════════
// 14. WATERMARK
// ══════════════════════════════════════════════════════════
if barstate.islast and showWatermarkInput
    var table wmTable = table.new(position.bottom_center, 1, 1, bgcolor = color.new(color.black, 100), border_color = color.new(color.black, 100), border_width = 0, frame_color = color.new(color.black, 100), frame_width = 0)
    table.cell(wmTable, 0, 0, "WillyAlgoTrader", text_color = WM_COLOR, text_size = size.normal, text_halign = text.align_center, bgcolor = color.new(color.black, 100))

// ══════════════════════════════════════════════════════════
// 15. ALERTS
// ══════════════════════════════════════════════════════════
if openLong or openShort
    string aPrice = str.tostring(close, format.mintick)
    string aScore = str.tostring(nz(sigScore), "#")
    string aSL    = str.tostring(nz(activeSL),  format.mintick)
    string aTP1   = str.tostring(nz(activeTP1), format.mintick)
    string aTP2   = str.tostring(nz(activeTP2), format.mintick)
    string aTP3   = str.tostring(nz(activeTP3), format.mintick)
    string aRR    = str.tostring(effTP1, "#.#")

    if openLong
        string jsonBuy = '{"action":"buy","ticker":"' + syminfo.tickerid + '","price":' + aPrice + ',"score":' + aScore + ',"sl":' + aSL + ',"tp1":' + aTP1 + ',"tp2":' + aTP2 + ',"tp3":' + aTP3 + ',"rr":' + aRR + '}'
        string textBuy = "🟢 LONG (Sweep) | " + syminfo.tickerid + " | TF: " + timeframe.period + " | Score: " + aScore + " | Price: " + aPrice + " | SL: " + aSL + " | TP1: " + aTP1 + " | TP2: " + aTP2 + " | TP3: " + aTP3 + " | R:R: " + aRR
        alert(webhookInput ? jsonBuy : textBuy, alert.freq_once_per_bar_close)

    if openShort
        string jsonSell = '{"action":"sell","ticker":"' + syminfo.tickerid + '","price":' + aPrice + ',"score":' + aScore + ',"sl":' + aSL + ',"tp1":' + aTP1 + ',"tp2":' + aTP2 + ',"tp3":' + aTP3 + ',"rr":' + aRR + '}'
        string textSell = "🔴 SHORT (Sweep) | " + syminfo.tickerid + " | TF: " + timeframe.period + " | Score: " + aScore + " | Price: " + aPrice + " | SL: " + aSL + " | TP1: " + aTP1 + " | TP2: " + aTP2 + " | TP3: " + aTP3 + " | R:R: " + aRR
        alert(webhookInput ? jsonSell : textSell, alert.freq_once_per_bar_close)

if slHit and showSlHitAlertInput
    string textSlHit = (exitBeActive ? "🛡️ BE STOP-OUT | " : "🛑 SL HIT | ") + syminfo.tickerid + " | Entry: " + str.tostring(nz(hitEntry), format.mintick) + " | SL: " + str.tostring(nz(hitSL), format.mintick)
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

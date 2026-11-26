# Motion Reversal System [BullByte]

- url: https://www.tradingview.com/script/ZpH5K46a-Motion-Reversal-System-BullByte/
- type: indicator
- pine_id: PUB;0f882825f8ef40609902a4b8fe12ebef
- version: 1.0

## Description

[b]Motion Reversal System (MRS) - Trend-Failure Bar Detector with Adaptive Pressure Meter, Multi-Mode Signal Engine, and Complete Trade-Level Framework[/b]

---

[b]Why This Indicator Exists[/b]

Most reversal indicators fall into one of two failure modes. Either they fire constantly in ranging markets because they have no directional filter, or they only confirm reversals long after price has already turned because they rely on lagging momentum oscillators. Motion Reversal System (MRS) was built to solve both problems in a single coherent engine.

MRS is one engine with one purpose: identify the precise bar at which a confirmed trend structurally fails - the moment commitment fades, the bar itself rejects further advance, and the move's energy reverses. From that bar, MRS automatically frames the trade with entry, two targets, and a stop loss, then manages the full trade lifecycle to closure.

---

[b]What Makes This Not a Mashup[/b]

A mashup combines independent indicators that each output their own signal, then layers them visually. MRS is the opposite. Every component of MRS feeds into a single decision: "Is the current bar a trend-failure bar?" Remove any one component and the engine stops working correctly.

- The [b]Directional Gate[/b] decides IF a trend is present (no trend = no exhaustion to detect)
- The [b]Four Failure Conditions[/b] decide IF the current bar is structurally failing that trend
- The [b]Signal Mode[/b] decides HOW STRICT the failure must be
- The [b]Pressure Meter[/b] provides a live visual reading of building reversal pressure
- The [b]Trade Level Engine[/b] decides WHERE to enter, stop, and target
- The [b]HTF Filter[/b] decides WHETHER higher-timeframe context confirms the call

These are not independent indicators. They are stages of one detection pipeline. Each stage exists because the next stage cannot function without it.

---

[b]The Engine - How It Actually Works[/b]

[b]Stage 1 - Directional Gate (Kaufman Efficiency Ratio, Self-Adapting)[/b]

The script computes Kaufman's Efficiency Ratio (ER) over a rolling window. ER measures net price displacement divided by the total path price traveled. Values near 1.0 indicate pure trending motion; values near 0.0 indicate pure noise.

A fixed ER threshold would work well on one instrument and fail on another, so MRS adapts the gate dynamically. The threshold becomes the rolling mean of the ER series plus half a standard deviation, with a user-defined floor. This means the gate raises itself during volatile sessions and lowers during quiet sessions automatically. No re-tuning per instrument.

Only bars that occur inside a confirmed directional move (gate passed + minimum ATR displacement satisfied) are evaluated for failure. This single design choice eliminates the largest source of false signals: exhaustion calls in choppy ranges where there is no trend to exhaust.

[b]Stage 2 - Four Failure Conditions (Evaluated at Bar Close)[/b]

For every bar inside a confirmed trend, MRS evaluates four orthogonal failure conditions:

[b]C1 - Velocity Reversal:[/b] The bar closed against the direction of the confirmed trend. This is the most basic failure signal. A bull trend bar that closes red, or a bear trend bar that closes green.

[b]C2 - Wick Rejection:[/b] The trend-side wick (upper wick in a bull trend, lower wick in a bear trend) is at least N times the size of the bar's body. This measures intra-bar rejection - buyers or sellers pushed price further in the trend direction and were defeated within the same bar.

[b]C3 - Commitment Anomaly:[/b] The bar's commitment value (measured via volume-weighted body strength when volume is reliable, or wick-rejection ratio when it is not) is at least N standard deviations below the recent trend's commitment baseline. The current bar is statistically anomalous compared to what the trend has been producing.

[b]C4 - Range Expansion:[/b] The bar's true range is at least N times ATR. Filters out small doji bars where wick rejection and velocity reversal become meaningless from microstructure noise.

These four conditions are orthogonal - they measure different physical properties of the bar. C1 measures direction. C2 measures intra-bar struggle. C3 measures volume/commitment. C4 measures magnitude. When multiple conditions align on the same bar, the signal reflects a greater degree of structural confluence - though no combination of conditions guarantees a reversal.

[b]Stage 3 - Signal Mode (Strictness Selector - THE ACTUAL SIGNAL GATE)[/b]

This is the decisive gate that determines whether a signal fires. The user chooses how many of the four conditions must align:

[b]Conservative[/b] - All 4 conditions required. Rarest signals, highest structural confluence. Best for swing traders, low-noise sessions, or those who prefer fewer signals with stronger multi-condition alignment.

[b]Balanced (default)[/b] - Any 3 of 4 conditions required. Middle ground for most users and most timeframes. Allows one condition to be absent if the other three are strong.

[b]Aggressive[/b] - Velocity Reversal (C1) is mandatory plus at least one other condition (minimum 2 of 4 total). Most signals, fewer conditions required per signal. Best for scalpers, active intraday traders, or those who prefer earlier detection at the cost of more false positives.

When the chosen condition count is satisfied at bar close, a signal fires. The Pressure Meter (Stage 5) is a separate visual reading and does not gate signals.

[b]Stage 4 - Commitment Measurement (Volume-Aware with Auto Fallback)[/b]

Commitment measures how decisively the market voted on each bar. MRS supports three measurement modes:

[b]Auto (recommended)[/b] - Uses volume-weighted commitment on instruments with real volume data (crypto, futures, stocks with traded volume). Automatically falls back to wick-rejection ratio on indices and synthetic feeds where reported volume is meaningless. The dashboard surfaces whichever method is actually active.

[b]Volume[/b] - Forces volume-weighted measurement. Useful when you want to lock the method explicitly. Silently falls back to wick if data is missing, with a dashboard warning.

[b]Wick[/b] - Forces wick-rejection ratio regardless of volume availability. Best for spot Gold (XAUUSD), forex, or any instrument where you don't trust the broker's volume feed.

[b]Stage 5 - Adaptive Pressure Meter (Live Visual Reading)[/b]

The pressure meter is the dashboard's live reading of building reversal pressure. It is always populated whenever a trend is confirmed, regardless of whether the four-condition gate has been met. This gives the trader a continuous sense of how strong the reversal pressure has been building.

The meter is normalized against an adaptive baseline calculated from its own rolling history (mean + multiplier x stdev). The dashboard percentage shows where the current meter sits relative to that baseline.

Important: the baseline is a visual reference only. It does not gate signals. The signal authority is the Signal Mode condition count described in Stage 3. The meter and baseline simply help the trader monitor when conditions are increasingly aligned before they actually trigger.

[b]Stage 6 - Higher Timeframe Confirmation (Optional Filter)[/b]

When enabled, the engine cross-checks every signal against the directional state of a higher timeframe. A reversal signal on the chart timeframe is marked "Strong" when the higher timeframe direction agrees with the chart trend being reversed against. For example: chart is in a confirmed bull move, HTF is also bullish, and a bear reversal signal fires - this is HTF-Strong, because the HTF confirms the bull trend that is being exhausted.

If the HTF direction disagrees with the chart trend (e.g., chart is in a bull move but HTF is already bearish), the signal is marked "Weak" - visually dimmed but not suppressed. The trader still sees the call but is warned that the HTF backdrop does not align with the underlying chart trend being detected.

The HTF uses request.security with lookahead = barmerge.lookahead_off, eliminating future-data leak across timeframes. The HTF series itself naturally evolves as each HTF candle forms (this is standard Pine behavior), so the script treats HTF as a confirmation filter rather than a guarantee of HTF-bar finalization. The signal trigger itself remains chart-bar-close only.

[b]Stage 7 - Trade Level Engine (Complete Lifecycle)[/b]

When a signal fires, the engine automatically computes and draws:

- [b]Entry:[/b] signal-bar close
- [b]Stop Loss:[/b] fixed ATR distance from entry (not score-scaled - strong signals deserve tighter stops, not wider ones)
- [b]Target 1:[/b] intermediate reference level, ATR distance scaled by signal strength (visual only, does not close trade)
- [b]Target 2:[/b] decisive level, ATR distance scaled by signal strength (closes the trade on hit)

While the trade is active, four colored horizontal lines extend from the signal bar to the current bar, with monospace pill labels showing the price and R:R for each level. Two zone fills (green Entry to TP2 reward zone, red Entry to SL risk zone) make the risk/reward geometry visible at a glance.

The trade closes when either TP2 or SL is touched at bar close (intra-bar wicks that retreat before close do NOT close the trade). Same-bar TP2/SL tie is resolved as SL hit (conservative backtest assumption).

After closure, the trade-level lines freeze in place as historical record. Labels and fills vanish to keep the chart clean. The cooldown counter starts. By default, all four lines (Entry, SL, TP1, TP2) persist as historical traces for richest backtest visibility. The "Keep TP1/TP2 Historical Lines" input can be turned off to delete TP1/TP2 lines on closure and roughly double the number of historical trades the chart can hold before Pine's 500-line cap is reached.

---

[b]Signal Timing - No Repaint[/b]

All signal generation and trade closure is gated to confirmed (closed) bars via barstate.isconfirmed.

- A reversal signal triangle and label appear only at the close of the signal bar
- Entry, SL, TP1, TP2 levels are computed from the signal bar's close
- Trade closure (TP2 / SL hit) is evaluated only after the candle finalizes - intra-bar wicks that retreat before close do not trigger closure

The trade-off is up to one bar of timing on closure for cases where price spikes through a level intra-bar and retraces. The gain is realistic backtest visuals and zero repaint at every stage of the trade lifecycle. This is an intentional architectural choice for honest behavior over flashy intra-bar firing.

---

[b]How to Read the Chart[/b]

[b]Signal Markers[/b]

[b]Bull Reversal[/b] (detected inside a confirmed bear move, reversal up signaled): small cyan triangle below the bar.
[b]Bear Reversal[/b] (detected inside a confirmed bull move, reversal down signaled): small red triangle above the bar.

Important: a bearish reversal signal fires inside a confirmed bull move. The signal detects exhaustion of the prevailing trend - not confirmation of a new one. The dashboard will show BULL MOVE while a short is active. This is correct behavior - you are trading the exhaustion of that bull move.

A monospace pill label sits beside each triangle showing the failure score (e.g., "Reversal Up | 2.45"). Higher numbers indicate stronger structural confluence across the four conditions.

When HTF Confirmation is enabled and HTF disagrees with the signal, the triangle and label appear in a dimmed color with "(HTF)" appended to the label text. The signal is still visible but is visually de-emphasized.

[b]Trade Level Lines[/b]

Once a signal fires, four horizontal lines appear extending from the signal bar:

- [b]Entry (yellow, solid):[/b] the price at which the signal was generated (signal-bar close)
- [b]Target 1 (cyan, dashed):[/b] intermediate reference level, visual only
- [b]Target 2 (green, solid):[/b] decisive level - trade closes when this is hit at bar close
- [b]Stop Loss (red, solid):[/b] risk level - trade closes when this is hit at bar close

Pill labels at the right end of each line show the exact price and R:R distance.

[b]Zone Fills[/b]

- [b]Green soft fill between Entry and TP2:[/b] the reward zone
- [b]Red soft fill between Entry and SL:[/b] the risk zone

At a glance, the green:red ratio visualizes the trade's risk-to-reward geometry.

[b]Directional Background[/b]

- Subtle blue tint: a bull trend is confirmed
- Subtle red/orange tint: a bear trend is confirmed
- No tint: no confirmed direction (chop)

[b]Bar Coloring (Exhaustion Gradient)[/b]

When the exhaustion meter rises above the trigger threshold (default 50% of baseline), bars are tinted on a gradient:
- Cool color (cyan/red): exhaustion is building but moderate
- Bright color (red on bull trend, cyan on bear trend): exhaustion has reached or exceeded the baseline - conditions for a signal are increasingly met, though no signal fires until the condition count gate is satisfied at bar close

[b]Historical Trade Traces[/b]

After a trade closes, by default all four trade-level lines (Entry, SL, TP1, TP2) remain on the chart as a permanent historical record. This builds a visual log of every prior MRS detection directly on the chart. The "Keep TP1/TP2 Historical Lines" input can be turned off if you want to conserve Pine's line-object cap.

---

[b]How to Read the Dashboard (Full Mode)[/b]

The dashboard is the live diagnostic panel. Every row tells you something specific about the current state of the engine. From top to bottom:

[b]Row 0 - Title:[/b] "MOTION REVERSAL SYSTEM (MRS)" - confirms the indicator name.

[b]Row 1 - Context:[/b] ticker symbol, chart timeframe, and active Signal Mode.

[b]Row 2 - Directional State:[/b] BULL MOVE / BEAR MOVE / NEUTRAL - large text, colored. Tells you whether a confirmed trend is currently in effect. When a trade is active against the current trend (e.g., short open during a bull move), this row appends "SHORTING EXHAUSTION" or "LONGING EXHAUSTION" so the dashboard reads as a coherent statement rather than an apparent contradiction.

[b]Row 3 - Exhaustion bar:[/b] a 10-segment text-based pressure bar with percentage. Shows how close the live meter is to the adaptive baseline. Color escalates from gray to teal to purple to bright red/cyan as pressure builds.

[b]Row 4 - Pressure:[/b] numerical value of the live exhaustion meter.

[b]Row 5 - Baseline:[/b] the adaptive baseline value (mean + k x stdev) the meter is compared against. Visual reference only - does not gate signals.

[b]Row 6 - Conditions:[/b] which of the four failure conditions are currently satisfied. "[+] VEL [+] WICK [ ] ANOM [+] RANGE" means C1, C2, C4 are firing; C3 is not.

[b]Row 7 - Count:[/b] how many of 4 conditions are firing, with current Signal Mode in parentheses. This is the actual signal authority - when the count satisfies the Signal Mode rule, a signal fires.

[b]Row 8 - Eff Ratio:[/b] the current Kaufman Efficiency Ratio value, with the adaptive gate level next to it. Shows whether the directional gate is passing.

[b]Row 9 - ATR:[/b] current ATR value at the configured length. Reference for understanding trade-level distances.

[b]Row 10 - HTF Dir:[/b] current higher-timeframe directional state, OR "INVALID HTF (set higher than chart)" warning if user has misconfigured the HTF input.

[b]Row 11 - Commit:[/b] which commitment measurement method is currently active (Auto -> Volume, Auto -> Wick fallback, etc.), with warning indicator if forced mode silently fell back.

[b]Row 12 - Active Trade Status:[/b] "NO ACTIVE TRADE" or "LONG ACTIVE E [entry price]" / "SHORT ACTIVE E [entry price]" - color-coded.

[b]Row 13 - Status:[/b] "Ready for signal" / "Cooldown: N bars" / "Trade active" - tells you whether the engine can fire a new signal right now.

[b]Row 14 - Session:[/b] count of signals fired in the current session (resets daily).

[b]Rows 15 to 19 - Engine Parameters reference:[/b] live readouts of the directional window, lookback periods, threshold parameters, ER gate values, and current commitment status. Useful for verifying your settings are applied as expected.

[b]Row 20 - Version and Author footer.[/b]

[b]Mobile / Minimal Dashboard Mode[/b]

For phone and tablet users, switching "Dashboard Mode" to "Minimal (Mobile)" collapses the dashboard to a single-column 5-row compact layout with larger fonts: Title, State, Exhaustion, Conditions, and Trade Status. Diagnostics are hidden for screen-space efficiency.

---

[b]Default Settings Explained[/b]

- [b]Directional Window:[/b] 12 bars - measures Efficiency Ratio over a 12-bar lookback
- [b]Directional Threshold (Base):[/b] 0.40 - minimum ER for trend confirmation, adapted upward dynamically
- [b]Min Move Size:[/b] 1.5 ATR - net displacement must be at least 1.5 ATR for a trend to qualify
- [b]Trend Statistics Lookback:[/b] 20 bars - sample size for computing commitment baseline statistics
- [b]Wick Rejection Ratio:[/b] 1.5 - trend-side wick must be at least 1.5x the body to count as rejection
- [b]Commitment Anomaly Sigma:[/b] 1.0 - current commitment must be at least 1.0 standard deviation below trend mean
- [b]Min Range Expansion:[/b] 1.2 ATR - current bar range must be at least 1.2x ATR
- [b]Signal Mode:[/b] Balanced - any 3 of 4 conditions required
- [b]Baseline Lookback:[/b] 100 bars - rolling history for pressure meter statistics
- [b]Baseline Multiplier:[/b] 2.0 - baseline = mean + 2.0 x stdev
- [b]ATR Length:[/b] 14 - standard ATR period
- [b]Commitment Mode:[/b] Auto - volume on real-volume instruments, wick on indices
- [b]Post-Closure Cooldown:[/b] 10 bars - wait 10 bars after trade closure before new signal
- [b]Stop Loss Distance:[/b] 1.5 ATR - base SL distance from entry
- [b]Target 1 Distance:[/b] 1.5 ATR - T1 at 1:1 with SL
- [b]Target 2 Distance:[/b] 3.0 ATR - T2 at 1:2 with SL
- [b]Score-Weight Nudge:[/b] 0.3 - stronger signals widen targets by up to 30%
- [b]Min Label Spacing:[/b] 0.35 ATR - minimum vertical gap between pill labels for readability

---

[b]Recommended Usage by Trader Profile[/b]

[b]Scalper (1m to 5m):[/b] Aggressive mode, Cooldown 5 to 8 bars, HTF Confirmation on 15m. Signal frequency will be higher in Aggressive mode; use the dashboard pressure meter to monitor building exhaustion between signals.

[b]Intraday Trader (5m to 30m):[/b] Balanced mode (default), Cooldown 10 bars, HTF Confirmation on 1h to 4h. The default settings were designed with this profile in mind as a starting reference point.

[b]Swing Trader (1h to 4h):[/b] Conservative mode, Cooldown 15 to 20 bars, HTF Confirmation on Daily. Few signals, maximum condition confluence required.

[b]Position Trader (Daily and above):[/b] Conservative mode, HTF Confirmation on Weekly. Signals are rare; when they fire, all four structural failure conditions have aligned on a higher timeframe bar.

---

[b]Recommended Markets[/b]

- [b]Crypto (Spot and Perpetuals):[/b] well-suited - high volume data availability, clean microstructure, MRS auto-selects volume-weighted commitment
- [b]Index Futures (NQ, ES, NIFTY futures):[/b] well-suited - real traded volume available, strong directional character
- [b]FX Majors:[/b] usable with Wick commitment mode forced (broker volume is unreliable)
- [b]Spot Gold (XAUUSD):[/b] use Wick mode explicitly - most brokers report tick count as volume which is meaningless
- [b]Cash Indices (NIFTY, SPX index):[/b] MRS auto-detects index type and routes to Wick mode; verify Commit row on dashboard

---

[b]A Real-World Example Walkthrough[/b]

This walkthrough is a constructed illustration of how the engine behaves. It does not represent a historical trade or a performance result.

[b]Scenario: [/b]BTCUSDT 15m chart, Balanced mode, Auto commitment.

[b]Bars 1 to 20:[/b] Price climbs in a steady bull move. Dashboard shows BULL MOVE, Efficiency Ratio 0.55, Pressure Meter 0.20 (low). No signals fire because exhaustion is not building.

[b]Bar 21:[/b] A large green candle prints - Range Expansion (C4) fires but the bar closes strong (no Velocity Reversal C1), and commitment is normal (no C3). Only 1 of 4 conditions. No signal.

[b]Bars 22 to 24:[/b] Three smaller green bars with shrinking bodies. The Pressure Meter ticks up to 0.55 (moderate). Bar coloring activates softly. Dashboard "Conditions" row shows [ ] [+] [ ] [ ] - only Wick Rejection is firing intermittently. No signal yet.

[b]Bar 25:[/b] A red bar prints with a long upper wick and large range. All four conditions fire:
- C1 Velocity Reversal: bar closed red (against bull trend)
- C2 Wick Rejection: upper wick is 1.8x the body
- C3 Commitment Anomaly: bar's commitment is 1.4 standard deviations below the trend baseline
- C4 Range Expansion: bar range is 1.6x ATR

Dashboard shows "Conditions: [+] VEL [+] WICK [+] ANOM [+] RANGE | Count: 4/4". Pressure Meter reads 1.15.

A red bear reversal triangle prints above the bar with the label "Reversal Down | 3.42". Trade-level lines automatically draw:
[b]- Entry (yellow):[/b] 64,210.50 (signal-bar close)
[b]- SL (red):[/b] 64,422.00 (1.5 ATR above entry, since this is a short)
[b]- T1 (cyan dashed):[/b] 63,999.00 (1.5 ATR x score-scale below entry)
[b]- T2 (green):[/b] 63,576.00 (3.0 ATR x score-scale below entry)

Green reward fill appears Entry to T2, red risk fill Entry to SL. Dashboard "Active Trade" row turns red: "SHORT ACTIVE E 64,210.50". Dashboard "Directional State" row reads: "BULL MOVE | SHORTING EXHAUSTION".

Over the next several bars, price drops. The trade-level lines extend bar-by-bar. Dashboard "[b]Status[/b]" reads "Trade active". No new signals fire because one trade is already open.

[b]Bar 32:[/b] In this example, price reaches T2 at 63,576.00 on this bar's close. The trade closes at the target level. Labels and zone fills vanish. The trade-level lines freeze at bar 32 as historical record. Dashboard "Status" switches to "Cooldown: 10 bars".

[b]Bars 33 to 42:[/b] Cooldown period. No new signals possible.

[b]Bar 43: [/b]Cooldown complete. Dashboard "Status" reads "Ready for signal". The engine will evaluate the next qualifying bar for failure conditions.

---

[b]Chart Examples[/b]

These screenshots show the indicator in use at specific moments in time. They are provided for visual reference only and do not represent performance results or forward-looking outcomes.

1. MRS detected a trend-failure bar inside a confirmed bull move on BTCUSDT 5m. Range expansion (C4) fired as exhaustion pressure reached the adaptive baseline (1.28 vs 1.03). Balanced mode gated the short at bar close - entry 62,553.3, SL 62,681.9, T2 62,273.6 (T2 distance: 2.17R). 

[image]https://www.tradingview.com/x/XL45Jr6v/[/image]

2. MRS detected a trend-failure bar at the low of a confirmed bear move on NQ1! 5m. As the engine tracked displacement against path length (ER), exhaustion pressure crossed the adaptive baseline - failure score 0.48. Balanced mode gated the long at bar close - entry 30,553.75, SL 30,489.00, T2 30,706.50 (T2 distance: 2.36R).

[image]https://www.tradingview.com/x/sMplqBBF/[/image]

---

[b]Parameter Adjustment Guide[/b]

[b]If you get too few signals:[/b]
- Switch Signal Mode to Aggressive
- Lower Wick Rejection Ratio (1.0 to 1.2)
- Lower Commitment Anomaly Sigma (0.7 to 0.9)
- Lower Min Range Expansion (1.0 to 1.1)
- Reduce Cooldown to 5

[b]If you get too many false signals:[/b]
- Switch Signal Mode to Conservative
- Raise Wick Rejection Ratio (2.0 to 2.5)
- Raise Commitment Anomaly Sigma (1.3 to 2.0)
- Raise Min Range Expansion (1.5 to 2.0)
- Enable HTF Confirmation
- Raise Cooldown to 15 to 20

[b]If the T2 zone is reached but price reverses sharply before bar close triggers closure:[/b]
- Reduce T2 Distance to 2.0 to 2.5 ATR
- Reduce Score-Weight Nudge to 0.1 (less target widening on strong signals)

[b]If SL is hit too often:[/b]
- Increase Stop Loss Distance to 2.0 ATR
- Increase T1 and T2 proportionally to maintain R:R geometry

---

[b]What This Indicator Does Not Do[/b]

- It does not execute trades. It is an indicator (overlay), not a strategy. Order placement and trade management decisions remain with the user.
- It does not predict the future. It identifies bars where a confirmed trend has structurally failed based on objective criteria.
- It does not eliminate losses. False signals will occur, especially in news-driven price spikes. Always size positions according to your own risk management rules.
- It does not work on every instrument equally well. Choppy low-liquidity assets produce noisier signals. Test on your specific market before relying on it.
- It does not replace discretionary judgment. Use MRS as one input in your decision process, not the only input.

---

[b]Alerts Available[/b]

[list]
[*][b]MRS Bull Reversal (Strong)[/b] - bullish reversal signal; HTF confirms the preceding bear trend
[*][b]MRS Bull Reversal (HTF Weak)[/b] - bullish reversal signal; HTF does not confirm the preceding bear trend
[*][b]MRS Bear Reversal (Strong)[/b] - bearish reversal signal; HTF confirms the preceding bull trend
[*][b]MRS Bear Reversal (HTF Weak)[/b] - bearish reversal signal; HTF does not confirm the preceding bull trend
[*][b]MRS Target 2 Hit[/b] - trade closure at T2 level
[*][b]MRS Stop Loss Hit[/b] - trade closure at SL level
[/list]

---

[b]Disclaimer[/b]

This script is provided for educational and analytical purposes only. It is not financial advice, an investment recommendation, or a solicitation to trade. Past performance of any indicator or strategy does not guarantee future results. Trading involves substantial risk of loss. The author and TradingView are not liable for any losses or damages arising from use of this script. Always validate signals against your own analysis, conduct your own due diligence, and apply prudent risk management. Use at your own risk.

---

[b]Open source under Mozilla Public License 2.0. Code is fully readable in the Pine Editor for those who want to study the math. Thank you.[/b]

[b]- BullByte[/b]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BullByte

//@version=6
// =============================================================================
// Motion Reversal System [BullByte]
// =============================================================================
// Author      : BullByte
// Version     : 1.0
// License     : Mozilla Public License 2.0
// =============================================================================
//
// CONCEPT
// -----------------------------------------------------------------------------
// Motion Reversal System treats price as a moving physical body and detects
// the precise bar at which a confirmed trend structurally fails - the moment
// commitment evaporates, the bar's own action rejects further advance, and
// the move's energy reverses. The script identifies these failure bars in
// real time at bar close, generates entry and risk levels around them, and
// manages each trade as a single self-contained setup with TP2/SL closure.
//
// IMPORTANT: A bearish reversal signal fires INSIDE a confirmed bull move,
// and a bullish reversal signal fires INSIDE a confirmed bear move. The
// signal detects exhaustion of the prevailing trend - not confirmation of
// a new one. The dashboard will show BULL MOVE while a short is active:
// this is correct. You are shorting the exhaustion of that bull move.
//
// SIGNAL TIMING (IMPORTANT)
// -----------------------------------------------------------------------------
// All signal generation and trade closure logic is gated to confirmed
// (closed) bars. Specifically:
//
//   - Reversal signals (triangles + pill labels) fire on bar close only.
//   - Entry, SL, TP1, TP2 levels are computed from the signal bar's close.
//   - Trade closure (TP2 hit / SL hit) is evaluated only after the candle
//     finalises. Intra-bar wicks that touch TP2 or SL but retreat before
//     close do NOT trigger closure - the bar must complete first.
//
// This is by design: intra-bar evaluation would repaint as price oscillates
// within the forming bar, producing misleading historical visuals and unreliable
// live behavior. The single trade-off is up to one bar of timing on closure
// in cases where price spikes through a level intra-bar; the gain is realistic
// backtest visuals and zero repaint at any stage of the trade lifecycle.
//
// HTF FILTER NOTE
// -----------------------------------------------------------------------------
// The optional Higher-Timeframe confirmation uses request.security with
// lookahead = barmerge.lookahead_off, which eliminates future-data leak
// across timeframes. However, the HTF series itself naturally evolves as
// each HTF candle forms - this is standard Pine behavior, not a flaw. The
// signal trigger remains chart-bar-close only, so the worst-case effect is
// that an HTF-Weak label can become HTF-Strong (or vice versa) after the
// current HTF candle finalises. Treat HTF as a confirmation filter, not as
// a guarantee of HTF-bar finalisation.
//
// DETECTION ENGINE
// -----------------------------------------------------------------------------
// 1. DIRECTIONAL GATE
//    Computes Kaufman Efficiency Ratio over a rolling window. Self-adapts
//    via the ER series' own mean+sigma. Only bars inside a confirmed
//    directional move are evaluated for failure - eliminating false signals
//    in choppy ranges.
//
// 2. FOUR FAILURE CONDITIONS (evaluated on the closing print of each bar)
//    C1 - Velocity Reversal : the bar closed against the trend direction
//    C2 - Wick Rejection    : the trend-side wick dominates the body
//    C3 - Commitment Anomaly: bar commitment is statistically anomalous
//                              versus the trend's own historical commitment
//    C4 - Range Expansion   : the bar is large enough to be meaningful
//
// 3. SIGNAL MODE (controls strictness)
//    Conservative : all 4 conditions required
//    Balanced     : any 3 of 4 required
//    Aggressive   : any 2 of 4 required (C1 mandatory)
//
// 4. COMMITMENT MEASUREMENT
//    Auto   : volume-weighted on instruments with real volume, automatic
//             wick-rejection fallback on indices and volume-less feeds
//    Volume : forced volume-weighted (falls back to wick if no volume)
//    Wick   : forced wick-rejection ratio
//
// 5. ADAPTIVE PRESSURE METER
//    A live "exhaust meter" reflects building reversal pressure regardless
//    of whether the full gate is met. The adaptive threshold is computed
//    from the rolling meter history (mean + k*sigma). The meter is the
//    dashboard's live reading; the gated failure score is the actual signal.
//
// 6. TRADE LEVELS
//    Entry: signal-bar close.
//    SL   : base ATR distance (not score-scaled - strong signals deserve
//           tighter stops, not wider ones).
//    TP1  : ATR distance, score-scaled, intermediate (no closure logic).
//    TP2  : ATR distance, score-scaled, decisive (closes the trade).
//    Closure: TP2 hit or SL hit. Same-bar tie -> SL priority (conservative).
//    After closure, lines freeze as historical traces; labels and fills vanish.
//
// 7. HIGHER-TIMEFRAME CONFIRMATION (optional)
//    Cross-checks signal against HTF directional state. Disagreement marks
//    the signal as Weak (dimmed); it is shown but visually de-emphasised.
//
//
// LIMITATIONS 
// -----------------------------------------------------------------------------
// - News-driven price spikes can defeat any microstructure logic.
// - Strong trends with no real exhaustion produce few signals (by design).
// - On instruments with synthetic/aggregated volume (indices), Auto mode
//   correctly routes to Wick; verify dashboard Commit row on first load.
// - This is an indicator, not a strategy. No automation; trade management
//   discretion is the user's responsibility.
//
// DISCLAIMER
// -----------------------------------------------------------------------------
// This script is provided for educational and analytical purposes only.
// It is not financial advice. Past performance does not guarantee future
// results. Trading involves risk of loss. The author and TradingView are
// not liable for any losses or damages. Use at your own risk and always
// validate signals against your own analysis and risk management rules.
// =============================================================================

indicator('Motion Reversal System [BullByte]', overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)


// =============================================================================
// SECTION 1 - INPUTS
// User-controlled parameters for engine, levels, visuals, and dashboard.
// =============================================================================

// --- Directional Engine ---
var string GRP1 = 'Directional Engine'
int i_dirWindow = input.int(12, 'Directional Window', minval = 8, maxval = 20, group = GRP1, tooltip = 'Number of bars used to measure net displacement vs total path length (Efficiency Ratio). Larger values require longer trends to confirm direction.')
float i_dirThreshB = input.float(0.40, 'Directional Threshold (Base)', minval = 0.20, maxval = 0.70, step = 0.05, group = GRP1, tooltip = 'Minimum Efficiency Ratio required to confirm a directional move. This base value is adapted upward dynamically: the adaptive gate = rolling ER mean + 0.5 × ER stdev (fixed coefficient). The Baseline Multiplier in the Adaptive Pressure section does not affect the ER gate - it governs the pressure meter baseline only.')
float i_minMoveATR = input.float(1.5, 'Min Move Size (ATR)', minval = 1.0, maxval = 3.0, step = 0.25, group = GRP1, tooltip = 'The net displacement of the directional window must be at least this many ATRs to qualify as a real move. Filters out micro-oscillations.')

// --- Trend Failure Detection ---
var string GRP2 = 'Trend Failure Detection'
int i_trendStatLB = input.int(20, 'Trend Statistics Lookback', minval = 10, maxval = 50, group = GRP2, tooltip = 'Bars used to compute the trend\'s commitment baseline (mean and standard deviation). The current bar is compared against this envelope to detect anomalous failure.')
float i_wickRejRatio = input.float(1.5, 'Wick Rejection Ratio', minval = 1.0, maxval = 3.0, step = 0.1, group = GRP2, tooltip = 'The trend-side wick must be at least this many times the body size to count as wick rejection. Measures intra-bar rejection of further trend advance.')
float i_commitAnomSig = input.float(1.0, 'Commitment Anomaly Sigma', minval = 0.5, maxval = 2.5, step = 0.1, group = GRP2, tooltip = 'Current bar commitment must be at least this many standard deviations below the trend mean to count as anomalous (statistically unusual).')
float i_rangeExpMin = input.float(1.2, 'Min Range Expansion (ATR)', minval = 1.0, maxval = 2.5, step = 0.1, group = GRP2, tooltip = 'The current bar\'s true range must be at least this many ATRs. Filters out small doji bars where wick rejection becomes meaningless.')

// --- Score Composition Mode ---
var string GRP2B = 'Signal Mode'
string i_scoreMode = input.string('Balanced', 'Signal Mode', options = ['Conservative', 'Balanced', 'Aggressive'], group = GRP2B, tooltip = 'Conservative: all 4 conditions required (rarest, strongest).\nBalanced: any 3 of 4 required (recommended).\nAggressive: Velocity Reversal (C1) is mandatory PLUS at least one other condition - minimum 2 of 4 total. Most signals, lower conviction.')

// --- Adaptive Threshold ---
var string GRP3 = 'Adaptive Pressure Baseline'
int i_threshLB = input.int(100, 'Baseline Lookback', minval = 50, maxval = 200, group = GRP3, tooltip = 'Rolling window for computing the live pressure meter\'s mean and standard deviation. Drives the dashboard percentage reading and visual baseline reference.')
float i_threshMult = input.float(2.0, 'Baseline Multiplier', minval = 1.5, maxval = 3.0, step = 0.1, group = GRP3, tooltip = 'Baseline = mean + (multiplier x stdev) of pressure meter history. Visual reference only; the actual signal gate is the condition count (see Signal Mode).')

// --- ATR Settings ---
var string GRP4 = 'Volatility Reference'
int i_atrLen = input.int(14, 'ATR Length', minval = 10, maxval = 20, group = GRP4, tooltip = 'Period for the Average True Range calculation, used as the universal volatility denominator throughout the engine.')

// --- Commitment Mode ---
var string GRP5 = 'Volume / Commitment Mode'
string i_commitMode = input.string('Auto', 'Commitment Measurement', options = ['Auto', 'Volume', 'Wick'], group = GRP5, tooltip = 'Auto (recommended): uses volume on instruments with real volume; automatically uses wick-rejection on indices and feeds with no usable volume.\nVolume: forces volume-weighted measurement (silently uses wick if data is missing).\nWick: forces wick-rejection regardless of volume availability.')

// --- HTF Confirmation ---
var string GRP6 = 'Higher Timeframe Filter'
bool i_htfOn = input.bool(false, 'Enable HTF Confirmation', group = GRP6, tooltip = 'When enabled, signals are cross-checked against the higher timeframe directional state. The HTF Efficiency Ratio is evaluated against its own adaptive gate (computed natively on the HTF), ensuring a self-consistent directional verdict. Disagreement marks the signal as Weak (dimmed appearance). Signals are not suppressed, only visually de-emphasised.')
string i_htfTF = input.timeframe('15', 'HTF Timeframe', group = GRP6, tooltip = 'The higher timeframe polled for directional confirmation. Must be higher than the chart timeframe.')

// --- Signal Control ---
var string GRP7 = 'Signal Control'
int i_cooldown = input.int(10, 'Post-Closure Cooldown (bars)', minval = 0, maxval = 20, group = GRP7, tooltip = 'Bars to wait after a trade closes (TP2 or SL) before a new signal can fire. Only one active trade at a time. Prevents back-to-back signals on the same exhaustion event.')

// --- Trade Level Management ---
var string GRP_TM = 'Trade Level Management'
float i_slATR = input.float(1.5, 'Stop Loss Distance (ATR)', minval = 0.5, maxval = 5.0, step = 0.1, group = GRP_TM, tooltip = 'Stop loss distance from entry in ATR units. By default SL = TP1 distance (1:1 at TP1) and TP2 = 2 × SL (1:2 at TP2).')
float i_tp1ATR = input.float(1.5, 'Target 1 Distance (ATR)', minval = 0.5, maxval = 8.0, step = 0.1, group = GRP_TM, tooltip = 'Intermediate target distance. Defaults to equal SL distance (R:R 1:1 at TP1). TP1 is visual-only and does not close the trade.')
float i_tp2ATR = input.float(3.0, 'Target 2 Distance (ATR)', minval = 1.0, maxval = 10.0, step = 0.1, group = GRP_TM, tooltip = 'Decisive target distance. Defaults to 2 × SL distance (R:R 1:2 at TP2). When price reaches TP2 the trade closes and the chart record freezes.\n\nSAME-BAR RESOLUTION: When TP2 and SL are both touched within the same bar (rare but possible on volatile bars), the trade is conservatively closed as a Stop Loss. This is intentional backtest realism - without tick data the actual hit order cannot be known, so the worst-case is assumed.')
float i_scoreNudge = input.float(0.3, 'Score-Weight Nudge', minval = 0.0, maxval = 0.6, step = 0.05, group = GRP_TM, tooltip = 'How much the failure score widens the TP distances. Stronger signals get proportionally wider targets. Set to 0 to use pure ATR distances. Note: SL is never scaled.')
float i_labelMinGap = input.float(0.35, 'Min Label Spacing (ATR)', minval = 0.1, maxval = 1.0, step = 0.05, group = GRP_TM, tooltip = 'Minimum vertical spacing between pill labels in ATR units. Prevents label overlap when levels are close in price. Lines remain at exact prices; only label Y-position is nudged.')
bool i_showRR = input.bool(true, 'Show R:R on Labels', group = GRP_TM)
bool i_showZoneFill = input.bool(true, 'Show Risk/Reward Zone Fills', group = GRP_TM, tooltip = 'Renders soft green fill between Entry and TP2 (reward zone), and red fill between Entry and SL (risk zone).')
bool i_keepTpHistory = input.bool(true, 'Keep TP1/TP2 Historical Lines', group = GRP_TM, tooltip = 'When ON (default): all 4 trade-level lines (Entry, SL, TP1, TP2) persist after trade closure for full historical backtest visibility. This provides the richest visual trade record.\n\nWhen OFF: on trade closure, TP1 and TP2 lines are deleted while Entry and SL remain as permanent historical traces. This roughly doubles the number of historical trades the chart can hold before Pine drops the oldest drawings (Pine cap: 500 line objects per script). Switch to OFF if you trade frequently on the same chart and want to preserve more historical setups.')

// --- Visuals ---
var string GRP8 = 'Visual Settings'
bool i_showBG = input.bool(true, 'Show Directional Background', group = GRP8, tooltip = 'Tints chart background blue (bull move) or red (bear move) when a confirmed directional state is active.')
bool i_showBarClr = input.bool(true, 'Show Exhaustion Bar Color', group = GRP8, tooltip = 'Colors candles by exhaustion pressure once meter crosses the trigger threshold. Gradient from cool (building) to bright (exceeded baseline).')
float i_barClrTrig = input.float(0.50, 'Bar Color Trigger (% baseline)', minval = 0.30, maxval = 0.90, step = 0.05, group = GRP8, tooltip = 'Exhaustion meter must reach this fraction of the adaptive baseline before bar coloring activates.')

// --- Dashboard ---
var string GRP9 = 'Dashboard'
bool i_showDash = input.bool(true, 'Show Dashboard', group = GRP9)
string i_dashMode = input.string('Full', 'Dashboard Mode', options = ['Full', 'Minimal (Mobile)'], group = GRP9, tooltip = 'Full: complete dashboard with all engine diagnostics (best for desktop).\n\nMinimal (Mobile): compact 5-row single-column layout with larger fonts for phone/tablet readability. Shows only State, Exhaustion bar, Conditions, Trade Status - diagnostics hidden.\n\nNote: when changing this setting, TradingView will recompile the script automatically. If the dashboard renders incorrectly after switching, simply remove and re-add the indicator to fully rebuild the table layout.')
string i_dashPos = input.string('Top Right', 'Dashboard Position', options = ['Top Right', 'Top Left', 'Bottom Right', 'Bottom Left'], group = GRP9)


// =============================================================================
// SECTION 2 - COLOR PALETTE
// All visual colors centralised for consistency.
// =============================================================================

color C_BULL_STRONG = #00E5FF
color C_BULL_WEAK = #4DD0E1
color C_BEAR_STRONG = #FF1744
color C_BEAR_WEAK = #FF8A80
color C_BG_BULL = color.new(#0D47A1, 92)
color C_BG_BEAR = color.new(#BF360C, 92)
color C_DASH_BG = color.new(#0A0A14, 0)
color C_DASH_HDR = color.new(#0D47A1, 0)
color C_DASH_HDR2 = color.new(#1A237E, 0)
color C_DARK = color.new(#111118, 0)
color C_DARK2 = color.new(#1A1A28, 0)
color C_WHITE = color.new(#FFFFFF, 0)
color C_GRAY = color.new(#9E9E9E, 0)
color C_GRAY_DIM = color.new(#616161, 0)
color C_WARN = color.new(#FF9800, 0)
color C_RED_DIM = color.new(#B71C1C, 0)
color C_GREEN_DIM = color.new(#1B5E20, 0)
color C_HOT = color.new(#FF9100, 0)
color C_PURPLE = color.new(#CE93D8, 0)
color C_TEAL = color.new(#4DB6AC, 0)
color C_INFO_BLUE = color.new(#90CAF9, 0)

// Trade-level palette
color C_LVL_ENTRY = #FFD600
color C_LVL_TP1 = #4DD0E1
color C_LVL_TP2 = #00E676
color C_LVL_SL = #FF1744
color C_FILL_REWARD = color.new(#00E676, 92)
color C_FILL_RISK = color.new(#FF1744, 92)
color C_PILL_BG = color.new(#0A0A14, 10)


// =============================================================================
// SECTION 3 - PERSISTENT STATE
// All state variables that persist across bars (var declarations).
// =============================================================================

// History arrays for adaptive baselines
var array<float> meterHistory = array.new_float(0)
var array<float> erHistory = array.new_float(0)

// Signal tracking
var int sessionSigs = 0
var bool volFallback = false
var bool volForcedFb = false

// Trade state machine: 0 = NO TRADE, 1 = ACTIVE TRADE
var int tradeState = 0
var int tradeDir = 0
var int tradeBar = na
var float tradeEntry = na
var float tradeTP1 = na
var float tradeTP2 = na
var float tradeSL = na

// Active-trade visual objects (recreated every bar while active)
var line aLineEntry = na
var line aLineTP1 = na
var line aLineTP2 = na
var line aLineSL = na
var label aLabEntry = na
var label aLabTP1 = na
var label aLabTP2 = na
var label aLabSL = na
var linefill aFillReward = na
var linefill aFillRisk = na

// Cooldown counter - runs from trade-closure bar
var int closureCooldownBar = -999


// =============================================================================
// SECTION 4 - BASE METRICS
// Universal price-derived metrics used across the engine.
// =============================================================================

float minTick = syminfo.mintick
float atrVal = ta.atr(i_atrLen)
float midpoint = (high + low) / 2.0
float volAvg = ta.sma(volume, 20)


// =============================================================================
// SECTION 5 - COMMITMENT FUNCTION
// Returns a signed commitment value [-1, +1] for any bar at historical offset i.
// Positive = buying commitment, negative = selling commitment.
// Volume mode: signed delta volume normalized by average volume.
// Wick mode  : wick-rejection ratio signed by close vs open direction.
// =============================================================================

f_commitment(int i) =>
    float c = close[i]
    float o = open[i]
    float h = high[i]
    float l = low[i]
    float r = math.max(h - l, minTick)
    float v = volume[i]
    float va = math.max(volAvg[i], 1.0)

    // Decide measurement method
    bool useVol = false
    if i_commitMode == 'Volume'
        useVol := not na(v) and v > 0
        useVol
    else if i_commitMode == 'Wick'
        useVol := false
        useVol
    else // Auto mode: indices and volume-less feeds always route to wick
        useVol := syminfo.type != 'index' and not na(v) and v > 0
        useVol

    float result = 0.0
    if useVol
        float bodySign = c >= o ? 1.0 : -1.0
        float bodyRatio = math.abs(c - o) / r
        float volRatio = math.min(v / va, 3.0) / 3.0
        result := bodySign * bodyRatio * volRatio
        result
    else
        float wickRej = 2.0 * math.abs(c - midpoint[i]) / r
        float bodySign = c >= o ? 1.0 : -1.0
        result := bodySign * wickRej
        result
    result


// =============================================================================
// SECTION 6 - COMMITMENT MODE STATUS
// Determines whether Auto mode has fallen back to wick measurement, and
// whether forced Volume mode is silently using wick due to missing data.
// Surfaces both states to the dashboard.
// =============================================================================

bool isIndex = syminfo.type == 'index'

if i_commitMode == 'Auto'
    volFallback := isIndex or na(volume) or volume <= 0
    volForcedFb := false
    volForcedFb
else if i_commitMode == 'Volume'
    volFallback := false
    volForcedFb := na(volume) or volume <= 0
    volForcedFb
else
    volFallback := false
    volForcedFb := false
    volForcedFb


// =============================================================================
// SECTION 7 - DIRECTIONAL ENGINE
// Efficiency Ratio measures net displacement vs total path length.
// The ER gate self-adapts via the rolling ER history's mean + 0.5*stdev,
// making the directionality check regime-aware.
// Mathematical basis: ER = net_move / path_length; values near 1 = pure trend,
// values near 0 = pure noise.
// =============================================================================

float netDisp = close - close[i_dirWindow]
float pathLen = 0.0
for i = 0 to i_dirWindow - 1 by 1
    pathLen := pathLen + math.abs(close[i] - close[i + 1])
    pathLen

float effRatio = pathLen > minTick ? netDisp / pathLen : 0.0

array.push(erHistory, math.abs(effRatio))
if array.size(erHistory) > i_threshLB
    array.shift(erHistory)

float erMean = array.avg(erHistory)
float erStdev = array.stdev(erHistory)
float erAdaptive = erMean + 0.5 * erStdev
float erGate = math.max(i_dirThreshB, erAdaptive)

int moveDir = effRatio > erGate ? 1 : effRatio < -erGate ? -1 : 0
float moveMag = math.abs(netDisp) / math.max(atrVal, minTick)
bool moveGate = moveMag >= i_minMoveATR
int confirmedDir = moveDir != 0 and moveGate ? moveDir : 0


// =============================================================================
// SECTION 8 - TREND FAILURE BAR ENGINE
// Core signal detection. Evaluates four orthogonal failure conditions on the
// current bar's closing print. The number of satisfied conditions, combined
// with Signal Mode, determines whether the failure is valid.
//
// Conditions:
//   C1 - Velocity Reversal : bar closed against trend direction
//   C2 - Wick Rejection    : trend-side wick >= ratio * body
//   C3 - Commitment Anomaly: bar commitment >= N sigma below trend mean
//   C4 - Range Expansion   : bar range >= min * ATR
// =============================================================================

// Pre-compute current-bar commitment once at global scope (avoids Pine warning
// about calling f_commitment inside conditional blocks).
float curCommitGlobal = f_commitment(0)

float failureScore = 0.0
float exhaustMeter = 0.0
bool c1_velRev = false
bool c2_wickRej = false
bool c3_commAnom = false
bool c4_rangeExp = false

if confirmedDir != 0
    float sigma = float(confirmedDir)

    // Build statistical envelope from prior trend-direction bars
    float commitSum = 0.0
    float commitSqSum = 0.0
    int statBars = 0

    for i = 1 to i_trendStatLB by 1
        float cmt = sigma * f_commitment(i)
        if cmt > 0
            commitSum := commitSum + cmt
            commitSqSum := commitSqSum + cmt * cmt
            statBars := statBars + 1
            statBars

    float commitMean = statBars > 0 ? commitSum / statBars : 0.0
    float commitVar = statBars > 1 ? (commitSqSum - statBars * commitMean * commitMean) / (statBars - 1) : 0.0
    float commitStd = math.sqrt(math.max(commitVar, 0.0))

    // Current-bar geometry
    float curBody = math.abs(close - open)
    float curRange = math.max(high - low, minTick)
    float bodySafe = math.max(curBody, minTick)

    // C1 - Velocity reversal: bar moved against trend on its own close
    float velocity = close - close[1]
    c1_velRev := sigma > 0 and velocity < 0 or sigma < 0 and velocity > 0

    // C2 - Wick rejection: trend-side wick dominates the body
    float trendWick = sigma > 0 ? high - math.max(open, close) : math.min(open, close) - low
    c2_wickRej := trendWick / bodySafe >= i_wickRejRatio

    // C3 - Commitment anomaly: current commitment is statistically below trend mean
    float curCommit = sigma * curCommitGlobal
    float commitDeviation = commitStd > 0 ? (commitMean - curCommit) / commitStd : 0.0
    c3_commAnom := commitDeviation >= i_commitAnomSig

    // C4 - Range expansion: bar is large enough to be meaningful
    c4_rangeExp := curRange >= i_rangeExpMin * atrVal

    // Count satisfied conditions
    int condCount = (c1_velRev ? 1 : 0) + (c2_wickRej ? 1 : 0) + (c3_commAnom ? 1 : 0) + (c4_rangeExp ? 1 : 0)

    // Apply Signal Mode validity rule
    bool failureValid = false
    if i_scoreMode == 'Conservative'
        failureValid := condCount == 4
        failureValid
    else if i_scoreMode == 'Balanced'
        failureValid := condCount >= 3
        failureValid
    else
        failureValid := c1_velRev and condCount >= 2
        failureValid

    // Compute individual strength components (always, for live dashboard)
    float velStrength = math.abs(velocity) / math.max(atrVal, minTick)
    float wickStrength = math.min(trendWick / bodySafe, 5.0) / 5.0
    float anomStrength = math.min(math.max(commitDeviation, 0.0), 3.0) / 3.0
    float rangeStrength = math.min(curRange / atrVal, 3.0) / 3.0

    // Live pressure meter - always populated, breathes with the trend
    float velComp = c1_velRev ? velStrength : velStrength * 0.5
    exhaustMeter := velComp * (1.0 + wickStrength) * (1.0 + anomStrength) * (1.0 + rangeStrength)

    // Failure score - only populated when validity gate passes (becomes the signal)
    if failureValid
        failureScore := velStrength * (1.0 + wickStrength) * (1.0 + anomStrength) * (1.0 + rangeStrength)
        failureScore


// =============================================================================
// SECTION 9 - ADAPTIVE BASELINE
// Rolling baseline of the live pressure meter, used as visual reference and
// dashboard percentage denominator. Does not gate signals (the condition
// count gate in Section 8 is the actual signal authority).
// =============================================================================

array.push(meterHistory, exhaustMeter)
if array.size(meterHistory) > i_threshLB
    array.shift(meterHistory)

float histMean = array.avg(meterHistory)
float histStdev = array.stdev(meterHistory)
float threshold = histMean + i_threshMult * histStdev
float meterPctVal = threshold > 0 ? exhaustMeter / threshold : 0.0


// =============================================================================
// SECTION 10 - HIGHER-TIMEFRAME DIRECTIONAL STATE
// Optional HTF check. Uses lookahead_off to ensure no repaint.
// Both the HTF ER and the HTF-native erGate are requested from the same
// timeframe so the directional comparison is self-consistent. Using the
// chart-bar erGate against an HTF ER is a cross-distribution mismatch -
// the HTF ER has its own mean/stdev regime that must gate itself.
// =============================================================================

float htfEffRatio = i_htfOn ? request.security(syminfo.tickerid, i_htfTF, effRatio, lookahead = barmerge.lookahead_off) : 0.0
float htfErGate   = i_htfOn ? request.security(syminfo.tickerid, i_htfTF, erGate,   lookahead = barmerge.lookahead_off) : 0.0

int htfDir = 0
if i_htfOn
    htfDir := htfEffRatio > htfErGate ? 1 : htfEffRatio < -htfErGate ? -1 : 0
    htfDir


// HTF validity check: HTF must be strictly higher than chart timeframe.
// timeframe.in_seconds returns the period in seconds for any timeframe string.
int chartSec = timeframe.in_seconds(timeframe.period)
int htfSec   = timeframe.in_seconds(i_htfTF)
bool htfMisconfigured = i_htfOn and htfSec <= chartSec


// =============================================================================
// SECTION 11 - SIGNAL DETECTION
// Fires reversal signals when failure score is valid, cooldown has elapsed,
// no trade is currently active, and the bar is confirmed closed.
// =============================================================================

bool sufficientBars = bar_index >= i_dirWindow + i_trendStatLB + i_threshLB
bool cooldownOk = tradeState == 0 and bar_index - closureCooldownBar >= i_cooldown
bool scoreValid = failureScore > 0
bool barConfirmed = barstate.isconfirmed

bool rawBullRev = false
bool rawBearRev = false
bool htfWeak = false

if sufficientBars and cooldownOk and confirmedDir != 0 and scoreValid and barConfirmed
    if confirmedDir == 1
        rawBearRev := true
        sessionSigs := sessionSigs + 1
        if i_htfOn
            htfWeak := htfDir != 1
    else if confirmedDir == -1
        rawBullRev := true
        sessionSigs := sessionSigs + 1
        if i_htfOn
            htfWeak := htfDir != -1

// Reset session counter on each new trading day (confirmed bar only)
if dayofweek != dayofweek[1] and barstate.isconfirmed
    sessionSigs := 0
    sessionSigs


// =============================================================================
// SECTION 12 - TRADE INITIATION
// On a new signal, computes Entry, SL, TP1, TP2 and activates trade state.
// SL distance uses base ATR only (no score scaling - stronger signals
// deserve tighter stops, not wider ones). TPs receive score-scaled distance.
// =============================================================================

bool mrsNewSignal = rawBullRev or rawBearRev

if mrsNewSignal and tradeState == 0
    tradeState := 1
    tradeDir := rawBullRev ? 1 : -1
    tradeBar := bar_index
    tradeEntry := close

    // Score-based multiplier applied only to targets, not stop
    float scoreMult = 1.0 + math.min(failureScore / math.max(threshold, 0.0001), 1.5) * i_scoreNudge
    float slDist = i_slATR * atrVal
    float tp1Dist = i_tp1ATR * atrVal * scoreMult
    float tp2Dist = i_tp2ATR * atrVal * scoreMult

    if tradeDir == 1
        tradeSL := tradeEntry - slDist
        tradeTP1 := tradeEntry + tp1Dist
        tradeTP2 := tradeEntry + tp2Dist
        tradeTP2
    else
        tradeSL := tradeEntry + slDist
        tradeTP1 := tradeEntry - tp1Dist
        tradeTP2 := tradeEntry - tp2Dist
        tradeTP2


// =============================================================================
// SECTION 13 - ACTIVE TRADE LEVEL DRAWING
// While a trade is active, rebuilds the four price-level lines and pill
// labels every bar so they extend with time. Anti-overlap logic nudges
// label Y-positions only - lines stay at their true prices.
// =============================================================================

if tradeState == 1
    // Clear previous bar's drawings before recreating
    if not na(aLineEntry)
        line.delete(aLineEntry)
    if not na(aLineTP1)
        line.delete(aLineTP1)
    if not na(aLineTP2)
        line.delete(aLineTP2)
    if not na(aLineSL)
        line.delete(aLineSL)
    if not na(aLabEntry)
        label.delete(aLabEntry)
    if not na(aLabTP1)
        label.delete(aLabTP1)
    if not na(aLabTP2)
        label.delete(aLabTP2)
    if not na(aLabSL)
        label.delete(aLabSL)
    if not na(aFillReward)
        linefill.delete(aFillReward)
    if not na(aFillRisk)
        linefill.delete(aFillRisk)

    int labelX = bar_index + 10

    // Draw the four price-level lines from signal bar to current bar
    aLineEntry := line.new(tradeBar, tradeEntry, labelX, tradeEntry, color = C_LVL_ENTRY, width = 2, style = line.style_solid)
    aLineTP1 := line.new(tradeBar, tradeTP1, labelX, tradeTP1, color = C_LVL_TP1, width = 1, style = line.style_dashed)
    aLineTP2 := line.new(tradeBar, tradeTP2, labelX, tradeTP2, color = C_LVL_TP2, width = 2, style = line.style_solid)
    aLineSL := line.new(tradeBar, tradeSL, labelX, tradeSL, color = C_LVL_SL, width = 2, style = line.style_solid)

    // Compute R:R ratios for labels
    float rrTP1 = math.abs(tradeTP1 - tradeEntry) / math.max(math.abs(tradeEntry - tradeSL), minTick)
    float rrTP2 = math.abs(tradeTP2 - tradeEntry) / math.max(math.abs(tradeEntry - tradeSL), minTick)

    // Format label text strings
    string entryTxt = '  E  ' + str.tostring(tradeEntry, format.mintick) + '  '
    string tp1Txt = i_showRR ? '  T1  ' + str.tostring(tradeTP1, format.mintick) + '   +' + str.tostring(rrTP1, '#.##') + 'R  ' : '  T1  ' + str.tostring(tradeTP1, format.mintick) + '  '
    string tp2Txt = i_showRR ? '  T2  ' + str.tostring(tradeTP2, format.mintick) + '   +' + str.tostring(rrTP2, '#.##') + 'R  ' : '  T2  ' + str.tostring(tradeTP2, format.mintick) + '  '
    string slTxt = i_showRR ? '  SL  ' + str.tostring(tradeSL, format.mintick) + '   -1.00R  ' : '  SL  ' + str.tostring(tradeSL, format.mintick) + '  '

    // Anti-overlap: nudge label Y-positions where levels are close in price
    float minGap = i_labelMinGap * atrVal
    float yEntry = tradeEntry
    float yTP1 = tradeTP1
    float yTP2 = tradeTP2
    float ySL = tradeSL

    if tradeDir == 1
        // Bull order top to bottom: TP2, TP1, Entry, SL
        if yTP1 - yEntry < minGap
            yTP1 := yEntry + minGap
            yTP1
        if yTP2 - yTP1 < minGap
            yTP2 := yTP1 + minGap
            yTP2
        if yEntry - ySL < minGap
            ySL := yEntry - minGap
            ySL
    else // Bear order top to bottom: SL, Entry, TP1, TP2
        if yEntry - yTP1 < minGap
            yTP1 := yEntry - minGap
            yTP1
        if yTP1 - yTP2 < minGap
            yTP2 := yTP1 - minGap
            yTP2
        if ySL - yEntry < minGap
            ySL := yEntry + minGap
            ySL

    // Render pill labels at nudged Y-positions
    aLabEntry := label.new(labelX, yEntry, entryTxt, style = label.style_label_left, color = C_PILL_BG, textcolor = C_LVL_ENTRY, size = size.normal, text_font_family = font.family_monospace)
    aLabTP1 := label.new(labelX, yTP1, tp1Txt, style = label.style_label_left, color = C_PILL_BG, textcolor = C_LVL_TP1, size = size.normal, text_font_family = font.family_monospace)
    aLabTP2 := label.new(labelX, yTP2, tp2Txt, style = label.style_label_left, color = C_PILL_BG, textcolor = C_LVL_TP2, size = size.normal, text_font_family = font.family_monospace)
    aLabSL := label.new(labelX, ySL, slTxt, style = label.style_label_left, color = C_PILL_BG, textcolor = C_LVL_SL, size = size.normal, text_font_family = font.family_monospace)

    // Risk and reward zone fills
    if i_showZoneFill
        aFillReward := linefill.new(aLineEntry, aLineTP2, C_FILL_REWARD)
        aFillRisk := linefill.new(aLineEntry, aLineSL, C_FILL_RISK)
        aFillRisk


// =============================================================================
// SECTION 14 - TRADE CLOSURE DETECTION
// Trade closes when TP2 or SL is hit. On closure: lines freeze in place
// as a historical record, labels and fills are removed.
// Same-bar tie: SL takes priority (conservative backtest assumption).
// =============================================================================

bool mrsTp2Hit = false
bool mrsSlHit = false

// Evaluate closure only on confirmed (closed) bars to prevent intra-bar
// repaint. A price wick that touches TP2 or SL mid-bar but retreats before
// close will NOT close the trade - the bar must finalise first.
if tradeState == 1 and bar_index > tradeBar and barstate.isconfirmed
    if tradeDir == 1
        if high >= tradeTP2
            mrsTp2Hit := true
            mrsTp2Hit
        if low <= tradeSL
            mrsSlHit := true
            mrsSlHit
    else
        if low <= tradeTP2
            mrsTp2Hit := true
            mrsTp2Hit
        if high >= tradeSL
            mrsSlHit := true
            mrsSlHit

    // Conservative: if both touched same bar, treat as SL hit
    if mrsTp2Hit and mrsSlHit
        mrsTp2Hit := false
        mrsTp2Hit

if mrsTp2Hit or mrsSlHit
    closureCooldownBar := bar_index

    // Remove active visual elements (labels, fills)
    if not na(aLabEntry)
        label.delete(aLabEntry)
        aLabEntry := na
        aLabEntry
    if not na(aLabTP1)
        label.delete(aLabTP1)
        aLabTP1 := na
        aLabTP1
    if not na(aLabTP2)
        label.delete(aLabTP2)
        aLabTP2 := na
        aLabTP2
    if not na(aLabSL)
        label.delete(aLabSL)
        aLabSL := na
        aLabSL
    if not na(aFillReward)
        linefill.delete(aFillReward)
        aFillReward := na
        aFillReward
    if not na(aFillRisk)
        linefill.delete(aFillRisk)
        aFillRisk := na
        aFillRisk

    // Freeze trade level lines as permanent historical traces on closure.
    // Entry and SL always persist. TP1 and TP2 persist by default
    // (i_keepTpHistory = true) for full historical visibility. User can
    // turn off i_keepTpHistory to delete TP1/TP2 on closure and conserve
    // Pine's 500 line-object ceiling.
    if not na(aLineEntry)
        line.set_x2(aLineEntry, bar_index)
    if not na(aLineSL)
        line.set_x2(aLineSL, bar_index)

    if i_keepTpHistory
        if not na(aLineTP1)
            line.set_x2(aLineTP1, bar_index)
        if not na(aLineTP2)
            line.set_x2(aLineTP2, bar_index)
    else
        if not na(aLineTP1)
            line.delete(aLineTP1)
        if not na(aLineTP2)
            line.delete(aLineTP2)

    // Release references so persisted lines remain as static drawings
    aLineEntry := na
    aLineTP1 := na
    aLineTP2 := na
    aLineSL := na

    // Reset trade state
    tradeState := 0
    tradeDir := 0
    tradeDir


// =============================================================================
// SECTION 15 - BACKGROUND COLOR
// Subtle tint indicating the confirmed directional state.
// =============================================================================

color bgColor = na
if i_showBG and confirmedDir != 0
    bgColor := confirmedDir == 1 ? C_BG_BULL : C_BG_BEAR
    bgColor

bgcolor(bgColor, title = 'Directional Background')


// =============================================================================
// SECTION 16 - BAR COLOR
// Candles colored by exhaustion intensity once meter crosses trigger.
// =============================================================================

color barClr = na
if i_showBarClr and confirmedDir != 0 and meterPctVal >= i_barClrTrig
    float pct = math.min((meterPctVal - i_barClrTrig) / math.max(1.0 - i_barClrTrig, 0.01), 1.0)
    if confirmedDir == 1
        barClr := color.from_gradient(pct, 0.0, 1.0, color.new(C_BULL_WEAK, 60), color.new(C_BEAR_STRONG, 0))
        barClr
    else
        barClr := color.from_gradient(pct, 0.0, 1.0, color.new(C_BEAR_WEAK, 60), color.new(C_BULL_STRONG, 0))
        barClr

barcolor(barClr, title = 'Exhaustion Gradient')


// =============================================================================
// SECTION 17 - SIGNAL MARKERS
// Small triangles plus monospace pill labels on signal bars.
// Weak (HTF-unconfirmed) signals get muted styling.
// =============================================================================

plotshape(rawBullRev and not htfWeak, title = 'Bull Reversal Strong', location = location.belowbar, style = shape.triangleup, color = C_BULL_STRONG, size = size.tiny)
plotshape(rawBullRev and htfWeak, title = 'Bull Reversal Weak', location = location.belowbar, style = shape.triangleup, color = color.new(C_BULL_WEAK, 50), size = size.tiny)
plotshape(rawBearRev and not htfWeak, title = 'Bear Reversal Strong', location = location.abovebar, style = shape.triangledown, color = C_BEAR_STRONG, size = size.tiny)
plotshape(rawBearRev and htfWeak, title = 'Bear Reversal Weak', location = location.abovebar, style = shape.triangledown, color = color.new(C_BEAR_WEAK, 50), size = size.tiny)

// Pill labels with direction arrow, label text, and score
if rawBullRev
    color sigCol = htfWeak ? color.new(C_BULL_WEAK, 30) : C_BULL_STRONG
    string sigTxt = htfWeak ? ' Reversal Up | ' + str.tostring(failureScore, '#.##') + ' (HTF) ' : ' Reversal Up | ' + str.tostring(failureScore, '#.##') + ' '
    label.new(bar_index, low - atrVal * 0.8, sigTxt, style = label.style_label_up, color = color.new(#0A0A14, 20), textcolor = sigCol, size = size.small, text_font_family = font.family_monospace)

if rawBearRev
    color sigCol = htfWeak ? color.new(C_BEAR_WEAK, 30) : C_BEAR_STRONG
    string sigTxt = htfWeak ? ' Reversal Down | ' + str.tostring(failureScore, '#.##') + ' (HTF) ' : ' Reversal Down | ' + str.tostring(failureScore, '#.##') + ' '
    label.new(bar_index, high + atrVal * 0.8, sigTxt, style = label.style_label_down, color = color.new(#0A0A14, 20), textcolor = sigCol, size = size.small, text_font_family = font.family_monospace)


// =============================================================================
// SECTION 18 - DATA WINDOW PLOTS
// Diagnostic values exposed in Data Window only (no visible chart plots).
// =============================================================================

plot(failureScore, title = 'Failure Score (gated)', color = color.new(#00E5FF, 0), display = display.data_window)
plot(exhaustMeter, title = 'Pressure Meter (live)', color = color.new(#FF9100, 0), display = display.data_window)
plot(threshold, title = 'Adaptive Baseline', color = color.new(#E0E0E0, 0), display = display.data_window)
plot(c1_velRev and confirmedDir != 0 ? 1 : 0, title = 'C1 Velocity Reversal', color = color.new(#00E5FF, 40), display = display.data_window)
plot(c2_wickRej and confirmedDir != 0 ? 1 : 0, title = 'C2 Wick Rejection', color = color.new(#FF1744, 40), display = display.data_window)
plot(c3_commAnom and confirmedDir != 0 ? 1 : 0, title = 'C3 Commit Anomaly', color = color.new(#4DB6AC, 40), display = display.data_window)
plot(c4_rangeExp and confirmedDir != 0 ? 1 : 0, title = 'C4 Range Expansion', color = color.new(#CE93D8, 40), display = display.data_window)


// =============================================================================
// SECTION 19 - DASHBOARD
// Two render modes:
//   Full           - 22-row 3-column desktop dashboard with all diagnostics
//   Minimal (Mobile) - 5-row single-column compact dashboard for phones/tablets
// =============================================================================

// Resolve dashboard position as a Pine position constant (not a string)
// Inlined at call sites because Pine position.* values are typed constants,
// not freely-typed strings.
f_dashPos() =>
    i_dashPos == 'Top Right'    ? position.top_right    :
     i_dashPos == 'Top Left'     ? position.top_left     :
     i_dashPos == 'Bottom Right' ? position.bottom_right :
                                   position.bottom_left

// Determine column count and row count based on mode
bool isMobile = i_dashMode == 'Minimal (Mobile)'
int  dashCols = isMobile ? 1 : 3
int  dashRows = isMobile ? 5 : 22

// Create table once at global scope using the position constant
var table dash = table.new(position = f_dashPos(), columns = dashCols, rows = dashRows, bgcolor = C_DASH_BG, border_color = color.new(#1E3A5F, 0), border_width = 1, frame_color = color.new(#0D47A1, 0), frame_width = 2)

if i_showDash and barstate.islast
    // Update position dynamically so user input changes take effect immediately
    table.set_position(dash, f_dashPos())

    // ─── MOBILE MINIMAL MODE ─────────────────────────────────────────────
    if isMobile
        // Row 0 - Title
        table.cell(dash, 0, 0, 'MRS  |  ' + syminfo.ticker + '  ' + timeframe.period, text_color = C_WHITE, text_size = size.normal, bgcolor = C_DASH_HDR)

        // Row 1 - Directional state (with trade context when active)
        string mState = confirmedDir == 1 ? 'BULL MOVE' : confirmedDir == -1 ? 'BEAR MOVE' : 'NEUTRAL'
        string mStateContext = tradeState == 1 and tradeDir == -1 and confirmedDir == 1 ? ' | SHORTING EXHAUST' : tradeState == 1 and tradeDir == 1 and confirmedDir == -1 ? ' | LONGING EXHAUST' : ''
        color mStateBg = confirmedDir == 1 ? color.new(#0D47A1, 30) : confirmedDir == -1 ? color.new(#B71C1C, 30) : color.new(#212121, 30)
        color mStateTxt = confirmedDir == 1 ? C_BULL_STRONG : confirmedDir == -1 ? C_BEAR_STRONG : C_GRAY
        table.cell(dash, 0, 1, mState + mStateContext, text_color = mStateTxt, text_size = size.large, bgcolor = mStateBg)

        // Row 2 - Exhaustion meter visual bar
        int mPctClamped = int(math.min(meterPctVal * 100, 100))
        int mFilledN = int(math.min(meterPctVal * 10, 10))
        string mBar10 = ''
        for i = 0 to 9 by 1
            mBar10 := mBar10 + (i < mFilledN ? '|' : '.')
            mBar10
        color mGradClr = meterPctVal >= 1.0 ? confirmedDir == 1 ? C_BEAR_STRONG : C_BULL_STRONG : meterPctVal >= 0.66 ? C_PURPLE : meterPctVal >= 0.33 ? C_TEAL : C_GRAY_DIM
        color mBarBg = meterPctVal >= 1.0 ? confirmedDir == 1 ? color.new(C_RED_DIM, 30) : color.new(C_GREEN_DIM, 30) : C_DARK2
        table.cell(dash, 0, 2, 'Exhaustion  ' + mBar10 + '  ' + str.tostring(mPctClamped) + '%', text_color = mGradClr, text_size = size.normal, bgcolor = mBarBg)

        // Row 3 - Conditions count with mode
        int mCondCount = (c1_velRev ? 1 : 0) + (c2_wickRej ? 1 : 0) + (c3_commAnom ? 1 : 0) + (c4_rangeExp ? 1 : 0)
        color mCondClr = mCondCount == 4 ? C_HOT : mCondCount == 3 ? C_PURPLE : mCondCount == 2 ? C_GRAY : C_GRAY_DIM
        table.cell(dash, 0, 3, 'Conditions: ' + str.tostring(mCondCount) + ' / 4   (' + i_scoreMode + ')', text_color = mCondClr, text_size = size.normal, bgcolor = C_DARK)

        // Row 4 - Trade status
        int mCdRemain = math.max(i_cooldown - (bar_index - closureCooldownBar), 0)
        string mTradeTxt = tradeState == 1 and tradeDir == 1 ? 'LONG ACTIVE  E ' + str.tostring(tradeEntry, format.mintick) : tradeState == 1 and tradeDir == -1 ? 'SHORT ACTIVE  E ' + str.tostring(tradeEntry, format.mintick) : mCdRemain > 0 ? 'Cooldown: ' + str.tostring(mCdRemain) + ' bars' : 'Ready for signal'
        color mTradeClr = tradeState == 1 and tradeDir == 1 ? C_LVL_TP2 : tradeState == 1 and tradeDir == -1 ? C_LVL_SL : mCdRemain > 0 ? C_GRAY : color.new(#00E676, 0)
        color mTradeBg = tradeState == 1 and tradeDir == 1 ? color.new(#00E676, 75) : tradeState == 1 and tradeDir == -1 ? color.new(#FF1744, 75) : C_DARK2
        table.cell(dash, 0, 4, mTradeTxt, text_color = mTradeClr, text_size = size.normal, bgcolor = mTradeBg)

    // ─── FULL DESKTOP MODE ───────────────────────────────────────────────
    else
        // Row 0 - Title
        table.merge_cells(dash, 0, 0, 2, 0)
        table.cell(dash, 0, 0, 'MOTION REVERSAL SYSTEM (MRS)', text_color = C_WHITE, text_size = size.small, bgcolor = C_DASH_HDR)

        // Row 1 - Subheader: instrument, timeframe, signal mode
        table.merge_cells(dash, 0, 1, 2, 1)
        table.cell(dash, 0, 1, syminfo.ticker + '  |  ' + timeframe.period + '  |  ' + i_scoreMode, text_color = C_INFO_BLUE, text_size = size.tiny, bgcolor = C_DASH_HDR2)

        // Row 2 - Directional state (with trade context when active)
        string stateText = confirmedDir == 1 ? 'BULL MOVE' : confirmedDir == -1 ? 'BEAR MOVE' : 'NEUTRAL'
        string stateContext = tradeState == 1 and tradeDir == -1 and confirmedDir == 1 ? '  SHORTING EXHAUSTION' : tradeState == 1 and tradeDir == 1 and confirmedDir == -1 ? '  LONGING EXHAUSTION' : ''
        color stateBG = confirmedDir == 1 ? color.new(#0D47A1, 40) : confirmedDir == -1 ? color.new(#B71C1C, 40) : color.new(#212121, 40)
        color stateTxt = confirmedDir == 1 ? C_BULL_STRONG : confirmedDir == -1 ? C_BEAR_STRONG : C_GRAY
        table.merge_cells(dash, 0, 2, 2, 2)
        table.cell(dash, 0, 2, stateText + stateContext, text_color = stateTxt, text_size = size.small, bgcolor = stateBG)

        // Row 3 - Live exhaustion visual bar
        int pctClamped = int(math.min(meterPctVal * 100, 100))
        int filledN = int(math.min(meterPctVal * 10, 10))
        string bar10 = ''
        for i = 0 to 9 by 1
            bar10 := bar10 + (i < filledN ? '|' : '.')
            bar10
        color gradClr = meterPctVal >= 1.0 ? confirmedDir == 1 ? C_BEAR_STRONG : C_BULL_STRONG : meterPctVal >= 0.66 ? C_PURPLE : meterPctVal >= 0.33 ? C_TEAL : C_GRAY_DIM
        table.cell(dash, 0, 3, 'Exhaustion', text_color = C_GRAY, text_size = size.tiny, bgcolor = C_DARK2)
        table.merge_cells(dash, 1, 3, 2, 3)
        table.cell(dash, 1, 3, bar10 + '  ' + str.tostring(pctClamped) + '%', text_color = gradClr, text_size = size.tiny, bgcolor = meterPctVal >= 1.0 ? confirmedDir == 1 ? color.new(C_RED_DIM, 20) : color.new(C_GREEN_DIM, 20) : C_DARK2)

        // Row 4 - Pressure meter value
        table.cell(dash, 0, 4, 'Pressure', text_color = C_GRAY, text_size = size.tiny, bgcolor = C_DARK)
        table.merge_cells(dash, 1, 4, 2, 4)
        table.cell(dash, 1, 4, str.tostring(exhaustMeter, '#.##'), text_color = gradClr, text_size = size.tiny, bgcolor = C_DARK)

        // Row 5 - Adaptive baseline
        table.cell(dash, 0, 5, 'Baseline', text_color = C_GRAY, text_size = size.tiny, bgcolor = C_DARK2)
        table.merge_cells(dash, 1, 5, 2, 5)
        table.cell(dash, 1, 5, str.tostring(threshold, '#.##'), text_color = C_WHITE, text_size = size.tiny, bgcolor = C_DARK2)

        // Row 6 - Condition checklist
        string condStr = (c1_velRev ? '[+]' : '[ ]') + ' VEL  ' + (c2_wickRej ? '[+]' : '[ ]') + ' WICK  ' + (c3_commAnom ? '[+]' : '[ ]') + ' ANOM  ' + (c4_rangeExp ? '[+]' : '[ ]') + ' RANGE'
        int condCountDisp = (c1_velRev ? 1 : 0) + (c2_wickRej ? 1 : 0) + (c3_commAnom ? 1 : 0) + (c4_rangeExp ? 1 : 0)
        color condClr = condCountDisp == 4 ? C_HOT : condCountDisp == 3 ? C_PURPLE : condCountDisp == 2 ? C_GRAY : C_GRAY_DIM
        table.cell(dash, 0, 6, 'Conditions', text_color = C_GRAY, text_size = size.tiny, bgcolor = C_DARK)
        table.merge_cells(dash, 1, 6, 2, 6)
        table.cell(dash, 1, 6, condStr, text_color = condClr, text_size = size.tiny, bgcolor = C_DARK)

        // Row 7 - Condition count with mode
        table.cell(dash, 0, 7, 'Count', text_color = C_GRAY, text_size = size.tiny, bgcolor = C_DARK2)
        table.merge_cells(dash, 1, 7, 2, 7)
        table.cell(dash, 1, 7, str.tostring(condCountDisp) + ' / 4   (' + i_scoreMode + ')', text_color = condClr, text_size = size.tiny, bgcolor = C_DARK2)

        // Row 8 - Efficiency Ratio with adaptive gate
        color erClr = math.abs(effRatio) >= erGate ? stateTxt : C_GRAY_DIM
        table.cell(dash, 0, 8, 'Eff Ratio', text_color = C_GRAY, text_size = size.tiny, bgcolor = C_DARK)
        table.cell(dash, 1, 8, str.tostring(effRatio, '#.###'), text_color = erClr, text_size = size.tiny, bgcolor = C_DARK)
        table.cell(dash, 2, 8, 'Gate ' + str.tostring(erGate, '#.###'), text_color = C_GRAY_DIM, text_size = size.tiny, bgcolor = C_DARK)

        // Row 9 - ATR
        table.cell(dash, 0, 9, 'ATR(' + str.tostring(i_atrLen) + ')', text_color = C_GRAY, text_size = size.tiny, bgcolor = C_DARK2)
        table.merge_cells(dash, 1, 9, 2, 9)
        table.cell(dash, 1, 9, str.tostring(atrVal, format.mintick), text_color = C_WHITE, text_size = size.tiny, bgcolor = C_DARK2)

        // Row 10 - HTF direction status (with misconfiguration warning)
        string htfText = not i_htfOn ? 'OFF' : htfMisconfigured ? 'INVALID HTF (set higher than chart)' : htfDir == 1 ? 'BULL (' + i_htfTF + ')' : htfDir == -1 ? 'BEAR (' + i_htfTF + ')' : 'NEUTRAL (' + i_htfTF + ')'
        color htfClr  = not i_htfOn ? C_GRAY_DIM : htfMisconfigured ? C_WARN : htfDir == 1  ? C_BULL_STRONG :htfDir == -1 ? C_BEAR_STRONG : C_GRAY
        color htfBg   = htfMisconfigured ? color.new(#FF9800, 80) : C_DARK
        table.cell(dash, 0, 10, 'HTF Dir', text_color = C_GRAY, text_size = size.tiny, bgcolor = C_DARK)
        table.merge_cells(dash, 1, 10, 2, 10)
        table.cell(dash, 1, 10, htfText, text_color = htfClr, text_size = size.tiny, bgcolor = htfBg)

        // Row 11 - Commitment mode with warnings
        string commitDisp = i_commitMode == 'Auto' ? volFallback ? 'Auto -> Wick' : 'Auto -> Volume' : i_commitMode == 'Volume' ? volForcedFb ? 'Volume -> Wick (no data)' : 'Volume' : 'Wick'
        bool commitWarn = volFallback or volForcedFb
        color commitClr = commitWarn ? C_WARN : C_TEAL
        table.cell(dash, 0, 11, 'Commit', text_color = C_GRAY, text_size = size.tiny, bgcolor = C_DARK2)
        table.merge_cells(dash, 1, 11, 2, 11)
        table.cell(dash, 1, 11, commitDisp, text_color = commitClr, text_size = size.tiny, bgcolor = commitWarn ? color.new(#FF9800, 85) : C_DARK2)

        // Row 12 - Active trade status
        string tradeStateTxt = tradeState == 0 ? 'NO ACTIVE TRADE' : tradeDir == 1 ? 'LONG ACTIVE   E ' + str.tostring(tradeEntry, format.mintick) : 'SHORT ACTIVE   E ' + str.tostring(tradeEntry, format.mintick)
        color tradeStateClr = tradeState == 0 ? C_GRAY_DIM : tradeDir == 1 ? C_LVL_TP2 : C_LVL_SL
        color tradeStateBg = tradeState == 0 ? C_DASH_HDR2 : tradeDir == 1 ? color.new(#00E676, 75) : color.new(#FF1744, 75)
        table.merge_cells(dash, 0, 12, 2, 12)
        table.cell(dash, 0, 12, tradeStateTxt, text_color = tradeStateClr, text_size = size.tiny, bgcolor = tradeStateBg)

        // Row 13 - Signal availability status
        int cdRemain = math.max(i_cooldown - (bar_index - closureCooldownBar), 0)
        string sigStatusTxt = tradeState == 1 ? 'Trade active' : cdRemain > 0 ? 'Cooldown: ' + str.tostring(cdRemain) + ' bars' : 'Ready for signal'
        color sigStatusClr = tradeState == 1 ? C_WARN : cdRemain > 0 ? C_GRAY : color.new(#00E676, 0)
        table.cell(dash, 0, 13, 'Status', text_color = C_GRAY, text_size = size.tiny, bgcolor = C_DARK)
        table.merge_cells(dash, 1, 13, 2, 13)
        table.cell(dash, 1, 13, sigStatusTxt, text_color = sigStatusClr, text_size = size.tiny, bgcolor = C_DARK)

        // Row 14 - Session signal count
        color sesClr = sessionSigs >= 8 ? C_WARN : sessionSigs >= 4 ? C_PURPLE : C_WHITE
        table.cell(dash, 0, 14, 'Session', text_color = C_GRAY, text_size = size.tiny, bgcolor = C_DARK2)
        table.merge_cells(dash, 1, 14, 2, 14)
        table.cell(dash, 1, 14, str.tostring(sessionSigs) + ' signals', text_color = sesClr, text_size = size.tiny, bgcolor = C_DARK2)

        // Row 15 - Engine params separator
        table.merge_cells(dash, 0, 15, 2, 15)
        table.cell(dash, 0, 15, 'ENGINE PARAMETERS', text_color = C_GRAY_DIM, text_size = size.tiny, bgcolor = C_DASH_HDR2)

        // Row 16 - Engine windows
        table.cell(dash, 0, 16, 'Engine', text_color = C_GRAY, text_size = size.tiny, bgcolor = C_DARK)
        table.merge_cells(dash, 1, 16, 2, 16)
        table.cell(dash, 1, 16, 'Dir ' + str.tostring(i_dirWindow) + '  Stat ' + str.tostring(i_trendStatLB) + '  Wick ' + str.tostring(i_wickRejRatio, '#.#') + '  Sigma ' + str.tostring(i_commitAnomSig, '#.#'), text_color = C_GRAY_DIM, text_size = size.tiny, bgcolor = C_DARK)

        // Row 17 - Baseline params
        table.cell(dash, 0, 17, 'Thresh', text_color = C_GRAY, text_size = size.tiny, bgcolor = C_DARK2)
        table.merge_cells(dash, 1, 17, 2, 17)
        table.cell(dash, 1, 17, 'LB ' + str.tostring(i_threshLB) + '  k=' + str.tostring(i_threshMult, '#.#') + '  CD=' + str.tostring(i_cooldown), text_color = C_GRAY_DIM, text_size = size.tiny, bgcolor = C_DARK2)

        // Row 18 - ER Gate display
        table.cell(dash, 0, 18, 'ER Gate', text_color = C_GRAY, text_size = size.tiny, bgcolor = C_DARK)
        table.merge_cells(dash, 1, 18, 2, 18)
        table.cell(dash, 1, 18, 'Base ' + str.tostring(i_dirThreshB, '#.##') + ' -> Adaptive ' + str.tostring(erGate, '#.###'), text_color = C_GRAY_DIM, text_size = size.tiny, bgcolor = C_DARK)

        // Row 19 - Commitment status footer
        table.merge_cells(dash, 0, 19, 2, 19)
        string commitNote = volFallback ? 'Auto routed to Wick (index or no volume)' : volForcedFb ? 'Volume forced but no data, using Wick' : i_commitMode == 'Auto' ? 'Volume commitment active' : 'Commitment locked: ' + i_commitMode
        color commitBG = commitWarn ? color.new(#FF9800, 75) : color.new(#1B5E20, 60)
        color commitTxC = commitWarn ? C_DARK : color.new(#A5D6A7, 0)
        table.cell(dash, 0, 19, commitNote, text_color = commitTxC, text_size = size.tiny, bgcolor = commitBG)

        // Row 20 - Version footer
        table.merge_cells(dash, 0, 20, 2, 20)
        table.cell(dash, 0, 20, 'v1.0  |  BullByte', text_color = C_GRAY_DIM, text_size = size.tiny, bgcolor = C_DASH_HDR2)


// =============================================================================
// SECTION 20 - ALERTS
// =============================================================================

alertcondition(rawBullRev and not htfWeak, title = 'MRS Bull Reversal (Strong)', message = 'MRS Bull Reversal - Strong | {{ticker}} {{interval}}')
alertcondition(rawBullRev and htfWeak, title = 'MRS Bull Reversal (HTF Weak)', message = 'MRS Bull Reversal - HTF Unconfirmed | {{ticker}} {{interval}}')
alertcondition(rawBearRev and not htfWeak, title = 'MRS Bear Reversal (Strong)', message = 'MRS Bear Reversal - Strong | {{ticker}} {{interval}}')
alertcondition(rawBearRev and htfWeak, title = 'MRS Bear Reversal (HTF Weak)', message = 'MRS Bear Reversal - HTF Unconfirmed | {{ticker}} {{interval}}')
alertcondition(mrsTp2Hit, title = 'MRS Target 2 Hit', message = 'MRS Target 2 Hit | {{ticker}} {{interval}}')
alertcondition(mrsSlHit, title = 'MRS Stop Loss Hit', message = 'MRS Stop Loss Hit | {{ticker}} {{interval}}')
````

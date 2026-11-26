# [ A L P H A X ] Vertex

- url: https://www.tradingview.com/script/ZzHuZc1H-A-L-P-H-A-X-Vertex/
- type: indicator
- pine_id: PUB;3d94672e79c8422eb155f88af1ea534c
- version: 1.0

## Description

[b]AlphaX Vertex — Volatility Squeeze Release, HTF Regime, Smart Confluence & Session-Ready Signals[/b]

AlphaX Vertex is a Pine Script v6 overlay indicator built around a classic volatility squeeze: Bollinger Bands fully inside Keltner Channels signal a coil in volatility; the first bar of expansion is the release. Vertex layers higher-timeframe regime, directional energy (+DI/−DI and ADX), RSI momentum with an optional hook, optional MACD histogram alignment, and optional volume — then separates [b]hard gates[/b] from a compact [b]soft confluence score[/b] so filters actually change outcomes. Factory defaults are tuned for responsive intraday work (including spot/CFD XAUUSD on 1-minute); every setting remains fully customizable. Visuals follow the AlphaX palette — yellow-green for bullish continuity, red for bearish, amber squeeze highlights, and a dark compact dashboard — consistent with AlphaX Titan / OMEGA styling.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]📸 Visual Overview[/b]
[image]https://www.tradingview.com/x/8Dpk9SKZ/[/image]
[i]AlphaX Vertex on chart — optional squeeze bar tint, triangle markers at confirmed releases with optional V↑ / V↓ score labels (soft score out of 3), optional Bollinger and Keltner plots, and a multi-row VERTEX dashboard showing coil state, HTF regime, bridge check, ADX, DI, RSI, and session gate.[/i]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔬 [b]Squeeze Engine — Coil and Release[/b]

The core geometry is the TTM-style relationship between Bollinger Bands and Keltner Channels:

[list]
[*][b]Coil (squeeze ON):[/b] The entire Bollinger envelope sits inside the Keltner envelope — volatility has contracted and energy is stored.
[*][b]Release:[/b] The first bar where that condition ends — Bollinger expands outside Keltner again — is the volatility release event ([b]release_ok[/b]).
[*][b]Minimum coil length:[/b] Vertex counts how many consecutive bars stayed in the coil; releases shorter than [b]Min Squeeze Bars[/b] are ignored to reduce one-bar noise (especially important on fast timeframes and symbols with spiky micro-ranges).
[/list]

Inputs include Bollinger length and standard-deviation multiplier, Keltner length and ATR multiplier, and minimum coil bars. Optional [b]Highlight Squeeze Bars[/b] tints bars during the coil; optional [b]Plot BB & Keltner[/b] draws both channels for full transparency.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 [b]Direction on Release — Keltner Basis Bias[/b]

On the release bar, directional bias for long vs short is anchored to the Keltner basis (EMA midline):

[list]
[*][b]Long-side release[/b] — price closes at or above the Keltner basis when the coil fires.
[*][b]Short-side release[/b] — price closes at or below the Keltner basis when the coil fires.
[/list]

This is the same directional cue used in textbook squeeze-plus-basis workflows: expansion plus which side of the midline price reclaims on the signal bar.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🌐 [b]Higher-Timeframe Regime — Hard Gate (No Lookahead)[/b]

When [b]Use HTF Regime Filter[/b] is enabled, Vertex pulls the selected HTF without lookahead ([b]barmerge.lookahead_off[/b]) and applies a strict regime test before any long or short can qualify:

[list]
[*][b]Bullish HTF[/b] — HTF close is above the HTF EMA and the EMA is sloped upward over your slope lookback.
[*][b]Bearish HTF[/b] — HTF close is below the HTF EMA and the EMA is sloped downward over the same lookback.
[*][b]Neutral[/b] — If neither bull nor bear condition is satisfied, Vertex [b]blocks both[/b] directions for that bar (no cherry-picking HTF as a partial score — it is a real veto).
[/list]

The dashboard shows regime ([b]BULL / BEAR / NEUTRAL / OFF[/b]), the active HTF string, an [b]HTF filter[/b] row ([b]Allows LONG[/b], [b]Allows SHORT[/b], or [b]Blocks both[/b]), and a [b]Bridge[/b] row: [b]Chart < HTF[/b] when your chart timeframe is strictly lower than the selected HTF (the intended use case), or [b]Chart >= HTF[/b] as a warning that you are not stepping up to a higher timeframe.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💪 [b]ADX and +DI / −DI — Hard Gates[/b]

When enabled, these are mandatory — not soft “minus one point” filters:

[list]
[*][b]ADX minimum[/b] — Optional floor on ADX to avoid signaling releases in dead, non-trending chop.
[*][b]+DI / −DI bias[/b] — Longs require +DI > −DI when the gate is on; shorts require −DI > +DI.
[/list]

The live dashboard shows ADX value (and whether the gate is off) plus the current DI+ / DI− readout.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]RSI, MACD Histogram, Volume — Soft Confluence (Score / 3)[/b]

After all squeeze, session, HTF, ADX, and DI conditions pass for the candidate direction, Vertex scores a separate [b]soft[/b] module:

[list]
[*][b]RSI[/b] — Configurable length and bull/bear levels; optional [b]RSI Hook[/b] demands a crossover or short ramp in the trade direction so momentum is not stale.
[*][b]MACD histogram[/b] — Optional confirm: histogram must agree with direction (or be building in that direction when enabled).
[*][b]Volume[/b] — Optional confirm versus a volume moving average and multiplier; when volume confirm is [b]off[/b], the volume slot still contributes to the soft score as a pass-through so [b]Min Confluence[/b] remains intuitive (see tooltips in script).
[/list]

[b]Min Confluence[/b] is the minimum soft score (1–3) required in addition to all hard gates. Raising it tightens entries; lowering it relaxes the model.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🕐 [b]Session Gate (UTC)[/b]

Optional London, London/NY overlap, and NY afternoon windows in [b]UTC[/b] (same convention style as AlphaX Titan Signal). When disabled, structure is evaluated around the clock; when enabled, signals outside selected windows are blocked.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 [b]Markers, Labels, and Execution Timing[/b]

[list]
[*][b]Triangles[/b] — Small green up-triangles below the bar for qualifying longs; small red down-triangles above for qualifying shorts.
[*][b]Score labels[/b] — Optional [b]V↑ n/3[/b] / [b]V↓ n/3[/b] labels offset by ATR show the soft score on the signal bar.
[*][b]Shift markers right[/b] — Optional 0–3 bar horizontal offset for plotshapes (and aligned labels) e.g. to visualize “next bar” execution while alerts still reference the true signal bar.
[*][b]Cooldown[/b] — Minimum bars between signals to reduce duplicate fires in the same impulse.
[*][b]Bar-close logic[/b] — Conditions use completed bar data (OHLC, pivot-style squeeze state, etc.). The signal bar is the first bar where the full rule set is satisfied; intrabar entries at the open of that bar are not implied by the math.
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 [b]Live Dashboard (Compact Table)[/b]

[list]
[*][b]VERTEX[/b] — Brand header row.
[*][b]Squeeze[/b] — [b]COIL[/b] vs [b]OPEN[/b] (expansion) state.
[*][b]HTF[/b] — [b]BULL / BEAR / NEUTRAL / OFF[/b] plus the configured HTF timeframe label.
[*][b]HTF filter[/b] — Which direction the HTF gate currently allows, or whether both are blocked.
[*][b]Bridge[/b] — Whether chart TF is strictly below the HTF or not.
[*][b]ADX[/b] — Live ADX with pass/fail coloring.
[*][b]DI+/DI−[/b] — Directional bias numerically.
[*][b]RSI[/b] — Live RSI reading.
[*][b]Session[/b] — [b]OK[/b] or [b]BLOCK[/b] when the session gate is used.
[/list]

Dashboard corner is selectable (Top Right, Top Left, Bottom Right, Bottom Left). Default is Bottom Left to reduce overlap with markers near the right-edge price scale.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ [b]Key Features[/b]

[list]
[*]🔬 [b]TTM-style squeeze[/b] — Bollinger inside Keltner for coil; first expansion bar = release; minimum coil length filter
[*][b]Keltner basis bias[/b] — Long/short qualification tied to close vs EMA midline on the release bar
[*]🌐 [b]HTF regime gate[/b] — [b]request.security[/b] with no lookahead; bull/bear/neutral with neutral blocking both sides
[*]💪 [b]ADX & +DI/−DI hard gates[/b] — Optional but structurally enforced when toggled on
[*]📊 [b]RSI + optional hook[/b] — Momentum filter with configurable levels
[*]📉 [b]Optional MACD histogram[/b] — Soft-score confirmation
[*]📦 [b]Optional volume[/b] — Soft-score vs volume MA
[*]🎯 [b]Soft score /3[/b] — Separate from hard gates; [b]Min Confluence[/b] control
[*]🕐 [b]UTC session filter[/b] — Optional London / overlap / NY afternoon
[*]⏱ [b]Signal cooldown[/b] — Limits back-to-back markers
[*]📋 [b]9-row dashboard[/b] — Real-time regime, bridge, ADX, DI, RSI, session
[*]🔔 [b]3 alert conditions[/b] — Vertex Long, Vertex Short, raw volatility release (unfiltered)
[*]✅ [b]Non-repainting historical signals[/b] — Confirmed bar-close style logic (standard indicator execution)
[*]🎨 [b]AlphaX theme[/b] — #A7D129 bull, #E43636 bear, dark table chrome
[*]📌 [b]Pine v6[/b] — Built for TradingView Pine Script v6
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙ [b]Settings Reference[/b]

[b]Squeeze Engine[/b]
[list]
[*]BB Length — Bollinger period (default 18 in factory XAUUSD M1 preset; full range 5–100)
[*]BB StdDev Mult — band width multiplier
[*]Keltner Length — basis/ATR channel period
[*]Keltner ATR Mult — channel width vs ATR
[*]Min Squeeze Bars — minimum consecutive coil bars before a release counts (default 6 in XAUUSD M1 factory preset)
[/list]

[b]HTF Regime[/b]
[list]
[*]Use HTF Regime Filter — master switch for HTF veto
[*]HTF Timeframe — e.g. 15, 60, 240, D (factory default 15 for 1m chart bridging)
[*]HTF EMA Length — regime EMA on that timeframe (factory default 21)
[*]HTF EMA Slope Lookback — bars back on HTF for slope direction (factory default 4)
[/list]

[b]Direction[/b]
[list]
[*]DMI / ADX Length — DI and ADX calculation period
[*]Require ADX ≥ Minimum — hard gate toggle
[*]ADX Minimum — threshold when gate is on
[*]Require +DI / −DI Bias — hard gate toggle
[*]RSI Length — momentum oscillator period
[*]Bullish / Bearish RSI Level — directional thresholds
[*]Require RSI Hook — momentum freshness filter
[*]MACD Histogram Confirm — include MACD in soft score when on (12,26,9 MACD)
[/list]

[b]Volume[/b]
[list]
[*]Volume Confirm — add volume-vs-MA requirement to soft score when on
[*]Volume MA Length — lookback for average volume
[*]Volume vs MA Mult — spike multiplier
[/list]

[b]Session[/b]
[list]
[*]Enable Session Gate (UTC) — master switch
[*]London 08:00–13:00 UTC — sub-window
[*]London/NY Overlap 13:00–17:00 UTC — sub-window
[*]NY Afternoon 17:00–21:00 UTC — sub-window
[/list]

[b]Signals[/b]
[list]
[*]Min Confluence (score / 3) — soft-score threshold after all hard gates
[*]Cooldown Bars — spacing between allowed signals
[*]Show Long / Short Markers — plotshape toggles
[*]Show Confluence Score on Marker — V↑ / V↓ labels with n/3
[/list]

[b]Display[/b]
[list]
[*]Highlight Squeeze Bars — barcolor tint during coil
[*]Plot BB & Keltner — show both channel sets
[*]Compact Dashboard — table on/off
[*]Dashboard Corner — table anchor
[*]Shift ▲▼ markers right (bars) — plotshape/label offset 0–3
[*]Label Offset (× ATR) — vertical label distance from bar extreme
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 [b]How to Trade with AlphaX Vertex — Step by Step[/b]

[b]Step 1 — Confirm squeeze state[/b]
[list]
[*]Watch the dashboard [b]Squeeze[/b] row: [b]COIL[/b] means volatility is compressed; you are hunting the [b]OPEN[/b] transition to expansion.
[*]Optional: enable BB/Keltner plots to visually verify the envelope relationship.
[/list]

[b]Step 2 — Align with higher timeframe[/b]
[list]
[*]If HTF filter is on, require [b]BULL[/b] regime for long-only bias and [b]BEAR[/b] for short-only bias. [b]NEUTRAL[/b] blocks both — stand aside until the HTF clears.
[*]Prefer [b]Bridge: Chart < HTF[/b] so the regime is truly higher than your execution chart.
[/list]

[b]Step 3 — Respect directional energy[/b]
[list]
[*]With ADX gate on, avoid releases when ADX is below your floor — the move may lack trend strength.
[*]With DI gate on, ensure +DI leads for longs and −DI leads for shorts.
[/list]

[b]Step 4 — Wait for the scored release[/b]
[list]
[*]After release and Keltner bias, soft score must meet [b]Min Confluence[/b]: RSI hook/levels, optional MACD, optional or pass-through volume slot.
[*]Triangles and optional [b]V↑/V↓ n/3[/b] labels mark the bar where the stacked logic first succeeds together.
[/list]

[b]Step 5 — Session and repetition control[/b]
[list]
[*]Apply session filter if you only trade specific liquidity windows.
[*]Use cooldown to avoid over-trading the same expansion cluster on very fast timeframes.
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔔 [b]Alert Conditions[/b]

[list]
[*][b]Vertex Long[/b] — full long stack: squeeze release, long bias, all active hard gates, soft score ≥ Min Confluence, cooldown respected, single direction resolution if both sides conflict
[*][b]Vertex Short[/b] — full short stack (mirror of long)
[*][b]Vertex Raw Release[/b] — volatility coil ended (expansion began) without the full Vertex filter stack — diagnostic for “something fired” even when regime/momentum vetoes
[/list]

Alert messages are fixed strings suitable for manual routing; add {{ticker}} and {{interval}} in TradingView’s alert message editor if your workflow requires them.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👥 [b]Who This Is For[/b]

[list]
[*]🥇 [b]Volatility breakout and squeeze traders[/b] — systematic coil → expansion framing
[*]📉 [b]Forex, metals, indices, and liquid CFDs[/b] — any symbol where compress-expand behavior matters
[*]⏱ [b]Scalpers through swing traders[/b] — parameters and HTF bridge scale with your timeframe choices
[*]🧠 [b]Traders who want explicit hard vs soft logic[/b] — regime and trend-energy gates separate from RSI/MACD/volume confluence score
[*]🔔 [b]Alert-driven workflows[/b] — filtered long/short plus raw-release diagnostic
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 [b]Notes[/b]

[list]
[*]Vertex is an [b]indicator[/b], not a strategy — it does not place orders; it visualizes conditions and exposes alertconditions.
[*]The squeeze release uses the relationship between [b]completed[/b] bar ranges (high/low/close) inside the channel math; treat the marker bar as confirmed at bar close in line with standard Pine indicator behavior.
[*]Raising [b]Min Squeeze Bars[/b] reduces false coils on noisy feeds; lowering it increases sensitivity.
[*]Turning [b]MACD Histogram Confirm[/b] off and lowering [b]Min Confluence[/b] increases signal frequency; tightening HTF, ADX, DI, and session does the opposite.
[*]Neutral HTF regime ([b]Blocks both[/b]) is intentional — it prevents trading “squeeze only” when higher-timeframe bias is undefined.
[*]The statistical target and Fibonacci extension sections in other AlphaX products are not part of Vertex; Vertex focuses on coil, release, regime, energy, and scored momentum only.
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Disclaimer[/b]

This indicator is a technical analysis and visualization tool intended for educational and informational purposes only. It does not constitute financial advice or a recommendation to buy or sell any financial instrument. All signals are derived from price and volume data via mathematical rules; profitability is not guaranteed. Past behavior of volatility coils does not guarantee future outcomes. Always conduct your own analysis, use proper risk management, and consult a licensed financial advisor before trading. The author accepts no responsibility for losses arising from use of this tool.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[i]Built for traders who want squeeze releases vetted by higher-timeframe bias, trend energy, and a transparent momentum score — AlphaX Vertex: coil, release, confluence.[/i]

## Source Code

````pine
// © AlphaX — Vertex: HTF regime × volatility squeeze release × directional energy
//@version=6
// Factory defaults below are tuned for spot/CFD XAUUSD on a 1-minute chart (intraday). Override freely for other symbols or TFs.
// Markers/alerts use bar-close math (indicator default: once per bar unless chart uses realtime calc). Signal is known when the bar *closes*; not at that bar’s open.
indicator('[ A L P H A X ] Vertex', shorttitle = '[ A L P H A X ] Vertex', overlay = true, max_labels_count = 500, max_lines_count = 500)

// ── Theme (aligned with Titan / OMEGA) ─────────────────────────────────────
_clr_primary = #A7D129
_clr_negative = #E43636
_clr_warning = #f59e0b
_clr_header = #d1d5db
_clr_header_bg = #0f0f0f
_clr_border = #1a1a1a
_clr_frame = #242424

// ╔═══════════════════════════════════════════════════════════╗
// ║                    SQUEEZE ENGINE                          ║
// ╚═══════════════════════════════════════════════════════════╝
bb_len = input.int(18, 'BB Length', minval = 5, maxval = 100, group = 'Squeeze Engine', tooltip = 'Default tuned for XAUUSD M1: slightly shorter than 20 for faster reaction; raise on noisy symbols.')
bb_mult = input.float(2.0, 'BB StdDev Mult', minval = 0.5, maxval = 4.0, step = 0.05, group = 'Squeeze Engine')
kc_len = input.int(18, 'Keltner Length', minval = 5, maxval = 100, group = 'Squeeze Engine')
kc_mult = input.float(1.5, 'Keltner ATR Mult', minval = 0.5, maxval = 4.0, step = 0.05, group = 'Squeeze Engine', tooltip = 'Keltner channel width. Narrower = more squeeze time; wider = fewer fires.')
min_squeeze_bars = input.int(6, 'Min Squeeze Bars', minval = 1, maxval = 30, group = 'Squeeze Engine', tooltip = 'XAUUSD M1: 6+ bars of coil filters micro-squeezes; tick volume spikes on gold M1 cause many fake 1–3 bar coils if this is too low.')

// ╔═══════════════════════════════════════════════════════════╗
// ║                 HTF REGIME FILTER                          ║
// ╚═══════════════════════════════════════════════════════════╝
use_htf = input.bool(true, 'Use HTF Regime Filter', group = 'HTF Regime')
htf_timeframe = input.timeframe('15', 'HTF Timeframe', group = 'HTF Regime', tooltip = 'XAUUSD on 1m: 15m is a standard step-up for intraday bias. Use 30 or 60 for slower bias; 5 only if you want very reactive (noisier) regime.')
htf_ema_len = input.int(21, 'HTF EMA Length', minval = 5, maxval = 200, group = 'HTF Regime', tooltip = '21 on 15m pairs well with M1 scalps; 34–50 if you use a higher HTF.')
htf_slope_bars = input.int(4, 'HTF EMA Slope Lookback', minval = 2, maxval = 30, group = 'HTF Regime', tooltip = 'Shorter lookback on 15m = slightly faster slope confirmation vs 5; increase if entries feel early.')

// ╔═══════════════════════════════════════════════════════════╗
// ║              DIRECTION & MOMENTUM                          ║
// ╚═══════════════════════════════════════════════════════════╝
dmi_len = input.int(10, 'DMI / ADX Length', minval = 5, maxval = 50, group = 'Direction', tooltip = 'XAUUSD M1: 10 reacts faster than 14; use 14 if signals feel too twitchy.')
use_adx_gate = input.bool(true, 'Require ADX ≥ Minimum', group = 'Direction')
adx_min = input.float(20.5, 'ADX Minimum', minval = 5.0, maxval = 45.0, step = 0.5, group = 'Direction', tooltip = 'M1 gold churns with low ADX; default ~20.5 trims dead-range releases. Lower toward 18 if too quiet.')
use_di_bias = input.bool(true, 'Require +DI / −DI Bias', group = 'Direction')
rsi_len = input.int(9, 'RSI Length', minval = 2, maxval = 50, group = 'Direction', tooltip = 'Fast RSI for M1; use 11–14 if you want smoother momentum.')
rsi_bull = input.float(47.0, 'Bullish RSI Level', minval = 30.0, maxval = 70.0, step = 1.0, group = 'Direction', tooltip = 'Long release: RSI must be above this (momentum not dead long).')
rsi_bear = input.float(53.0, 'Bearish RSI Level', minval = 30.0, maxval = 70.0, step = 1.0, group = 'Direction')
use_rsi_hook = input.bool(true, 'Require RSI Hook', group = 'Direction', tooltip = 'Long: RSI crosses above level or rises 2+ bars. Bear: mirror.')
use_macd_confirm = input.bool(true, 'MACD Histogram Confirm', group = 'Direction', tooltip = 'On by default for XAUUSD M1: histogram side must agree with direction (soft score). Turn off if signals are too rare.')

// ╔═══════════════════════════════════════════════════════════╗
// ║                 VOLUME (OPTIONAL)                          ║
// ╚═══════════════════════════════════════════════════════════╝
use_vol_confirm = input.bool(false, 'Volume Confirm (+1 confluence)', group = 'Volume', tooltip = 'Spot XAUUSD often uses tick volume; enable only if your feed’s volume/spikes are meaningful.')
vol_ma_len = input.int(14, 'Volume MA Length', minval = 5, maxval = 100, group = 'Volume', tooltip = 'Shorter MA if you enable volume on M1.')
vol_mult = input.float(1.2, 'Volume vs MA Mult', minval = 1.0, maxval = 3.0, step = 0.05, group = 'Volume')

// ╔═══════════════════════════════════════════════════════════╗
// ║                 SESSION & RISK                             ║
// ╚═══════════════════════════════════════════════════════════╝
use_session_gate = input.bool(false, 'Enable Session Gate (UTC)', group = 'Session', tooltip = 'Gold trades through Asia; leave off unless you only want London/NY (boxes below).')
sess_london = input.bool(true, 'London 08:00–13:00', group = 'Session')
sess_overlap = input.bool(true, 'London/NY Overlap 13:00–17:00', group = 'Session')
sess_ny_pm = input.bool(true, 'NY Afternoon 17:00–21:00', group = 'Session')

// ╔═══════════════════════════════════════════════════════════╗
// ║                 SIGNAL ENGINE                              ║
// ╚═══════════════════════════════════════════════════════════╝
min_confluence = input.int(3, 'Min Confluence (score / 3)', minval = 1, maxval = 3, group = 'Signals', tooltip = 'XAUUSD M1 default 3/3: need RSI + MACD + free “vol” slot (with volume confirm OFF that slot still counts). Squeeze/HTF/ADX/DI are separate hard gates. Set to 2 if too few trades.')
cooldown_bars = input.int(15, 'Cooldown Bars', minval = 0, maxval = 50, group = 'Signals', tooltip = 'On M1, 15 bars ≈ 15 minutes between signals; reduces duplicate fires in the same gold impulse.')
show_long = input.bool(true, 'Show Long Markers', group = 'Signals')
show_short = input.bool(true, 'Show Short Markers', group = 'Signals')
show_score_labels = input.bool(true, 'Show Confluence Score on Marker', group = 'Signals')

// ╔═══════════════════════════════════════════════════════════╗
// ║                 DISPLAY                                    ║
// ╚═══════════════════════════════════════════════════════════╝
show_squeeze_bg = input.bool(true, 'Highlight Squeeze Bars', group = 'Display')
show_bb_kc = input.bool(false, 'Plot BB & Keltner', group = 'Display')
show_dash = input.bool(true, 'Compact Dashboard', group = 'Display')
dash_pos = input.string('Bottom Left', 'Dashboard Corner', options = ['Top Right', 'Top Left', 'Bottom Right', 'Bottom Left'], group = 'Display', tooltip = 'Default Bottom Left keeps the top-right price area clear so triangles / labels are less likely to sit under the table.')
marker_offset_bars = input.int(0, 'Shift ▲▼ markers right (bars)', minval = 0, maxval = 3, group = 'Display', tooltip = '0 = draw on the signal bar (conditions confirmed at that bar’s CLOSE). 1 = draw on the next bar (visual for “enter at next bar open”). Alerts still use the real signal bar unless you create an alert on the delayed plot series.')
label_atr_off = input.float(0.55, 'Label Offset (× ATR)', minval = 0.1, maxval = 4.0, step = 0.05, group = 'Display', tooltip = 'Gold M1 ATR is often large in $ terms; slightly smaller multiplier keeps labels closer to price.')

atr_sig = ta.atr(14)

// ── Bollinger ───────────────────────────────────────────────────────────────
bb_basis = ta.sma(close, bb_len)
bb_dev = bb_mult * ta.stdev(close, bb_len)
bb_upper = bb_basis + bb_dev
bb_lower = bb_basis - bb_dev

// ── Keltner ─────────────────────────────────────────────────────────────────
kc_basis = ta.ema(close, kc_len)
kc_atr = ta.atr(kc_len)
kc_upper = kc_basis + kc_mult * kc_atr
kc_lower = kc_basis - kc_mult * kc_atr

// TTM-style: squeeze ON when Bollinger is fully inside Keltner
squeeze_on = bb_lower > kc_lower and bb_upper < kc_upper
var int coil_bars = 0
if squeeze_on
    coil_bars := squeeze_on[1] ? coil_bars[1] + 1 : 1
else
    coil_bars := 0

// First bar of expansion after a valid coil
release_ok = squeeze_on[1] and not squeeze_on and coil_bars[1] >= min_squeeze_bars

// ── DMI / ADX ───────────────────────────────────────────────────────────────
[di_plus, di_minus, adx_val] = ta.dmi(dmi_len, dmi_len)
di_bull = di_plus > di_minus
di_bear = di_minus > di_plus
adx_ok = not use_adx_gate or adx_val >= adx_min

// ── RSI momentum ────────────────────────────────────────────────────────────
rsi_v = ta.rsi(close, rsi_len)
rsi_hook_up = ta.crossover(rsi_v, rsi_bull) or (rsi_v > rsi_bull and rsi_v > rsi_v[1] and rsi_v[1] > rsi_v[2])
rsi_hook_dn = ta.crossunder(rsi_v, rsi_bear) or (rsi_v < rsi_bear and rsi_v < rsi_v[1] and rsi_v[1] < rsi_v[2])
rsi_long_ok = rsi_v > rsi_bull and (not use_rsi_hook or rsi_hook_up)
rsi_short_ok = rsi_v < rsi_bear and (not use_rsi_hook or rsi_hook_dn)

// ── MACD optional ───────────────────────────────────────────────────────────
[_ml, _sl, hist] = ta.macd(close, 12, 26, 9)
macd_long_ok = hist > 0.0 or hist > hist[1]
macd_short_ok = hist < 0.0 or hist < hist[1]

// ── HTF regime (no lookahead) ───────────────────────────────────────────────
htf_close = request.security(syminfo.tickerid, htf_timeframe, close, barmerge.gaps_off, barmerge.lookahead_off)
htf_ema = request.security(syminfo.tickerid, htf_timeframe, ta.ema(close, htf_ema_len), barmerge.gaps_off, barmerge.lookahead_off)
htf_ema_past = request.security(syminfo.tickerid, htf_timeframe, ta.ema(close, htf_ema_len)[htf_slope_bars], barmerge.gaps_off, barmerge.lookahead_off)
htf_slope_up = htf_ema > htf_ema_past
htf_slope_dn = htf_ema < htf_ema_past
bull_htf = htf_close > htf_ema and htf_slope_up
bear_htf = htf_close < htf_ema and htf_slope_dn
// True when chart TF is strictly lower than HTF (so request.security is a real higher TF). Same TF still works but is redundant.
chart_sec = timeframe.in_seconds(timeframe.period)
htf_sec = timeframe.in_seconds(htf_timeframe)
htf_is_strict_higher = chart_sec < htf_sec

// ── Price vs Keltner midline (classic squeeze direction) ────────────────────
bias_long = close >= kc_basis
bias_short = close <= kc_basis

// ── Volume ─────────────────────────────────────────────────────────────────-
vol_ma = ta.sma(volume, vol_ma_len)

// ── Session UTC (same style as Titan Signal) ─────────────────────────────────
h_utc = hour(time, 'UTC')
is_lon = h_utc >= 8 and h_utc < 13
is_ov = h_utc >= 13 and h_utc < 17
is_nya = h_utc >= 17 and h_utc < 21
session_ok = not use_session_gate or (sess_london and is_lon) or (sess_overlap and is_ov) or (sess_ny_pm and is_nya)

// ── Mandatory gates (when toggles ON). Previously HTF/ADX/DI only removed 1 point each from score,
//    so min_confluence 4 still fired almost every time — looked “broken”.
htf_long_ok = not use_htf or bull_htf
htf_short_ok = not use_htf or bear_htf
adx_hard_ok = not use_adx_gate or adx_val >= adx_min
di_long_ok = not use_di_bias or di_bull
di_short_ok = not use_di_bias or di_bear

f_macd_long = not use_macd_confirm or macd_long_ok
f_macd_short = not use_macd_confirm or macd_short_ok
f_vol = not use_vol_confirm or na(volume) or na(vol_ma) or vol_ma == 0.0 or volume >= vol_ma * vol_mult

// Soft score (3): RSI + MACD + vol only — release/bias already enforced in base_*.
int scL = 0
scL += rsi_long_ok ? 1 : 0
scL += f_macd_long ? 1 : 0
scL += f_vol ? 1 : 0

int scS = 0
scS += rsi_short_ok ? 1 : 0
scS += f_macd_short ? 1 : 0
scS += f_vol ? 1 : 0

var int last_bar_signal = na
cool_ok = na(last_bar_signal) or bar_index - last_bar_signal >= cooldown_bars

base_long = release_ok and bias_long and session_ok and htf_long_ok and adx_hard_ok and di_long_ok
base_short = release_ok and bias_short and session_ok and htf_short_ok and adx_hard_ok and di_short_ok
long_raw = base_long and scL >= min_confluence and cool_ok
short_raw = base_short and scS >= min_confluence and cool_ok
both = long_raw and short_raw
long_sig = long_raw and not both
short_sig = short_raw and not both

if long_sig or short_sig
    last_bar_signal := bar_index

// ── Plots ───────────────────────────────────────────────────────────────────
plot(show_bb_kc ? bb_basis : na, 'BB Basis', color = color.new(_clr_header, 65), linewidth = 1)
plot(show_bb_kc ? bb_upper : na, 'BB Upper', color = color.new(_clr_primary, 70), linewidth = 1)
plot(show_bb_kc ? bb_lower : na, 'BB Lower', color = color.new(_clr_primary, 70), linewidth = 1)
plot(show_bb_kc ? kc_upper : na, 'KC Upper', color = color.new(_clr_warning, 55), linewidth = 1)
plot(show_bb_kc ? kc_basis : na, 'KC Basis', color = color.new(_clr_warning, 75), linewidth = 1)
plot(show_bb_kc ? kc_lower : na, 'KC Lower', color = color.new(_clr_warning, 55), linewidth = 1)

squeeze_col = squeeze_on ? color.new(_clr_warning, 88) : na
barcolor(show_squeeze_bg ? squeeze_col : na)

plotshape(show_long and long_sig, title = 'Vertex Long', style = shape.triangleup, location = location.belowbar, offset = marker_offset_bars, size = size.small, color = _clr_primary, textcolor = _clr_header_bg)
plotshape(show_short and short_sig, title = 'Vertex Short', style = shape.triangledown, location = location.abovebar, offset = marker_offset_bars, size = size.small, color = _clr_negative, textcolor = _clr_header_bg)

int mo = marker_offset_bars
long_lbl_here = mo == 0 ? long_sig : long_sig[mo]
short_lbl_here = mo == 0 ? short_sig : short_sig[mo]
scL_lbl = mo == 0 ? scL : scL[mo]
scS_lbl = mo == 0 ? scS : scS[mo]

if show_long and long_lbl_here and show_score_labels
    label.new(bar_index, low - atr_sig * label_atr_off, 'V↑ ' + str.tostring(scL_lbl) + '/3', color = color.new(_clr_primary, 12), textcolor = _clr_header_bg, style = label.style_label_up, size = size.tiny)
if show_short and short_lbl_here and show_score_labels
    label.new(bar_index, high + atr_sig * label_atr_off, 'V↓ ' + str.tostring(scS_lbl) + '/3', color = color.new(_clr_negative, 12), textcolor = _clr_header_bg, style = label.style_label_down, size = size.tiny)

// ── Dashboard ───────────────────────────────────────────────────────────────
pos_enum = dash_pos == 'Top Left' ? position.top_left : dash_pos == 'Bottom Right' ? position.bottom_right : dash_pos == 'Bottom Left' ? position.bottom_left : position.top_right

var table dash = na
if show_dash and na(dash)
    dash := table.new(pos_enum, 2, 9, bgcolor = color.new(_clr_header_bg, 5), border_width = 1, border_color = _clr_border, frame_color = _clr_frame, frame_width = 1)
if not show_dash and not na(dash)
    table.delete(dash)
    dash := na
if show_dash and not na(dash)
    table.set_position(dash, pos_enum)
    table.cell(dash, 0, 0, 'VERTEX', text_color = _clr_primary, text_size = size.tiny, bgcolor = _clr_header_bg)
    table.cell(dash, 1, 0, '', bgcolor = _clr_header_bg)
    table.cell(dash, 0, 1, 'Squeeze', text_color = _clr_header, text_size = size.tiny, bgcolor = color.new(_clr_frame, 40))
    table.cell(dash, 1, 1, squeeze_on ? 'COIL' : 'OPEN', text_color = squeeze_on ? _clr_warning : _clr_primary, text_size = size.tiny, bgcolor = color.new(_clr_frame, 40))
    table.cell(dash, 0, 2, 'HTF', text_color = _clr_header, text_size = size.tiny, bgcolor = color.new(_clr_frame, 55))
    htf_tf_lbl = str.tostring(htf_timeframe)
    htf_txt = not use_htf ? 'OFF' : bull_htf ? 'BULL' : bear_htf ? 'BEAR' : 'NEUTRAL'
    htf_col = not use_htf ? _clr_header : bull_htf ? _clr_primary : bear_htf ? _clr_negative : _clr_warning
    table.cell(dash, 1, 2, htf_txt + ' @ ' + htf_tf_lbl, text_color = htf_col, text_size = size.tiny, bgcolor = color.new(_clr_frame, 55))
    table.cell(dash, 0, 3, 'HTF filter', text_color = _clr_header, text_size = size.tiny, bgcolor = color.new(_clr_frame, 40))
    htf_gate_txt = not use_htf ? '—' : bull_htf ? 'Allows LONG' : bear_htf ? 'Allows SHORT' : 'Blocks both'
    htf_gate_col = not use_htf ? _clr_header : bull_htf or bear_htf ? _clr_primary : _clr_negative
    table.cell(dash, 1, 3, htf_gate_txt, text_color = htf_gate_col, text_size = size.tiny, bgcolor = color.new(_clr_frame, 40))
    table.cell(dash, 0, 4, 'Bridge', text_color = _clr_header, text_size = size.tiny, bgcolor = color.new(_clr_frame, 55))
    bridge_txt = not use_htf ? '—' : htf_is_strict_higher ? 'Chart < HTF' : 'Chart >= HTF'
    bridge_col = not use_htf ? _clr_header : htf_is_strict_higher ? _clr_primary : _clr_warning
    table.cell(dash, 1, 4, bridge_txt, text_color = bridge_col, text_size = size.tiny, bgcolor = color.new(_clr_frame, 55))
    table.cell(dash, 0, 5, 'ADX', text_color = _clr_header, text_size = size.tiny, bgcolor = color.new(_clr_frame, 40))
    table.cell(dash, 1, 5, str.tostring(adx_val, '#.#') + (use_adx_gate ? '' : ' (off)'), text_color = adx_ok ? _clr_primary : _clr_negative, text_size = size.tiny, bgcolor = color.new(_clr_frame, 40))
    table.cell(dash, 0, 6, 'DI+/DI−', text_color = _clr_header, text_size = size.tiny, bgcolor = color.new(_clr_frame, 55))
    table.cell(dash, 1, 6, str.tostring(di_plus, '#') + '/' + str.tostring(di_minus, '#') + (use_di_bias ? '' : ' off'), text_color = di_bull ? _clr_primary : di_bear ? _clr_negative : _clr_warning, text_size = size.tiny, bgcolor = color.new(_clr_frame, 55))
    table.cell(dash, 0, 7, 'RSI', text_color = _clr_header, text_size = size.tiny, bgcolor = color.new(_clr_frame, 40))
    table.cell(dash, 1, 7, str.tostring(rsi_v, '#.#'), text_color = _clr_header, text_size = size.tiny, bgcolor = color.new(_clr_frame, 40))
    table.cell(dash, 0, 8, 'Session', text_color = _clr_header, text_size = size.tiny, bgcolor = color.new(_clr_frame, 55))
    table.cell(dash, 1, 8, session_ok ? 'OK' : 'BLOCK', text_color = session_ok ? _clr_primary : _clr_negative, text_size = size.tiny, bgcolor = color.new(_clr_frame, 55))

// ── Alerts ────────────────────────────────────────────────────────────────────
alertcondition(long_sig, title = 'Vertex Long', message = '[AlphaX Vertex] Long — squeeze release + confluence')
alertcondition(short_sig, title = 'Vertex Short', message = '[AlphaX Vertex] Short — squeeze release + confluence')
alertcondition(release_ok, title = 'Vertex Raw Release', message = '[AlphaX Vertex] Volatility coil released (unfiltered)')
````

# [ A L P H A X ] RESONANCE - Triple-RSI Stack

- url: https://www.tradingview.com/script/6jT5SDkF-A-L-P-H-A-X-RESONANCE-Triple-RSI-Stack/
- type: indicator
- pine_id: PUB;ff247b34043046c6aaf9f894e51b4df0
- version: 1.0

## Description

[b]AlphaX RESONANCE — RSI Harmonic Engine: Triple-RSI Stack, Adaptive Exhaustion Zones, RSI Coil Release, Pivot Divergence Reversals & Five-Phase Market Classification[/b]

AlphaX RESONANCE is a professional-grade momentum and mean-reversion system built on a fundamentally different RSI architecture from any conventional oscillator overlay. Where standard RSI indicators use a single period and static overbought/oversold levels, RESONANCE runs three RSI instances simultaneously — a fast Pulse RSI, a medium Core RSI, and a slow Anchor RSI — each measuring a different temporal dimension of momentum, and combines them into a unified harmonic stack that classifies the current market phase, scores directional conviction, detects RSI bandwidth compression (the RSI equivalent of a volatility coil), and fires precision entry signals across four distinct setup types. The adaptive exhaustion zones replace fixed 70/30 thresholds with percentile-ranked dynamic levels calibrated to the current instrument's own RSI distribution — so the system's definition of "overbought" evolves with actual market behavior rather than staying fixed at an arbitrary number. The result is a system that reads momentum the way it actually behaves — in layers, in phases, and in cycles — rather than as a single oscillating line. Designed for traders across crypto, forex, gold, and indices on any timeframe.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎵 [b]The Harmonic Philosophy — Three RSI Periods, One Unified Picture[/b]

The core problem with a single-period RSI is temporal ambiguity. A 14-period RSI reading of 65 could mean the market is in a healthy trend with room to run, or a short-term overbought stretch about to snap back — the same number carries completely different meanings depending on whether the underlying trend is strong or weak. A fast RSI alone is noisy and prone to false signals. A slow RSI alone is too lagged to be actionable for entries.

RESONANCE solves this by running all three simultaneously and treating their relationship as the signal — not any single RSI value in isolation.

[b]The three RSI layers:[/b]
[list]
[*][b]Pulse RSI (default: 7 periods)[/b] — the fastest layer. Reacts immediately to price movements. Used for timing — detecting the exact bar of a snapback exit from an exhaustion zone, the crossing of the harmonic midline, and the moment a coil releases. The Pulse RSI is the trigger layer
[*][b]Core RSI (default: 14 periods)[/b] — the standard intermediate layer. Used for divergence detection, slope measurement, and bandwidth compression. The Core RSI is the evidence layer — it confirms that the Pulse RSI signal has structural backing from a wider momentum view
[*][b]Anchor RSI (default: 28 periods)[/b] — the slowest, most stable layer. Used for market phase classification. When the Anchor RSI is above 58 and rising, the market is in MARKUP. Below 42 and falling, MARKDOWN. The Anchor RSI is the context layer — it tells you the macro momentum environment within which all other signals must be interpreted
[/list]

[b]The harmonic stack:[/b]
RESONANCE defines a true harmonic alignment when all three RSI layers are stacked on the same side of the midline with aligned slopes — Pulse above 50, Core above 48, Anchor above 46 (with tolerance buffers to avoid false collapses on minor retracements). When all three are stacked and sloping in the same direction, the market has broad-based momentum conviction across fast, medium, and slow timeframes simultaneously. This triple-stack condition is the backbone of the HARMONIC BREAK setup and is the highest-weight component in the Resonance Score.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]Five-Phase Market Classification — The Harmonic Dashboard[/b]

Using the Anchor RSI as the primary reference and the Core RSI slope as a secondary differentiator, RESONANCE classifies the market into one of five phases on every bar. The current phase is displayed prominently on the dashboard as the HARMONIC row and determines which setup types are most appropriate to trade.

[b]MARKUP:[/b]
Anchor RSI at or above 58 with a positive slope — the slow momentum layer confirms a sustained upward bias. The macro momentum environment is bullish. This is the primary background condition for HARMONIC BREAK long setups and SNAPBACK long entries that occur as the Pulse RSI dips to the adaptive oversold zone and recovers.

[b]MARKDOWN:[/b]
Anchor RSI at or below 42 with a negative slope — macro momentum is bearish. Primary background for HARMONIC BREAK shorts and SNAPBACK short entries.

[b]DISTRIB (Distribution):[/b]
Anchor RSI is above 52 (mildly bullish macro) but Core RSI is below the Anchor and its slope is negative — the intermediate momentum layer is diverging downward against the still-elevated Anchor. This is the distribution phase: the long-term bias has not yet shifted, but the medium-term momentum is beginning to roll over. A warning sign for bulls and an early-watch condition for bear setups.

[b]ACCUM (Accumulation):[/b]
Anchor RSI is below 48 but Core RSI is above the Anchor and its slope is positive — intermediate momentum is recovering against a still-depressed Anchor. This is the accumulation phase: the macro bias has not yet turned bullish but buying pressure is building. An early-watch condition for bull setups.

[b]COIL:[/b]
The RSI bandwidth (highest Core RSI minus lowest Core RSI over the coil lookback) has compressed below the average bandwidth by the configured multiplier. The market is in a momentum squeeze — all three RSI layers are converging toward neutral and the directional energy is compressing. This phase precedes the COIL RELEASE setup and is displayed with a purple tint to distinguish it from the directional phases.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📐 [b]Adaptive Exhaustion Zones — Dynamic Overbought/Oversold[/b]

The standard RSI uses fixed overbought (70) and oversold (30) levels. These thresholds are problematic because every instrument has a different RSI distribution — a strongly trending equity might spend months above 70 and rarely touch 30, while a mean-reverting commodity might hit 70 and snap back immediately. Fixed levels produce the wrong trigger points for most instruments most of the time.

RESONANCE replaces fixed thresholds with [b]adaptive exhaustion zones[/b] computed from the Core RSI's own historical percentile distribution:

[b]Dynamic Overbought (dynOb):[/b]
The 82nd percentile of Core RSI readings over the adaptive zone lookback period (default: 100 bars). This means the overbought threshold is set at the level that Core RSI has exceeded only 18% of the time historically. When the Pulse RSI crosses above this level and then crosses back below it, the system detects a genuine exhaustion exit — not just a touch of an arbitrary 70 threshold, but an exit from a genuinely extreme reading for this specific instrument at this specific time.

[b]Dynamic Oversold (dynOs):[/b]
The 18th percentile of Core RSI readings — the level that Core RSI has been below only 18% of the time. The oversold exit is a Pulse RSI crossover back above this level.

[b]Self-calibrating behavior:[/b] During strongly trending markets, the adaptive thresholds shift upward (dynOb moves above 70, dynOs moves above 30) reflecting the fact that RSI stays elevated in trends. During ranging markets, the thresholds move toward 70/30 or tighter. The system always uses the statistically appropriate threshold for the current regime, automatically.

[b]Dashboard display:[/b] The current dynamic oversold/overbought pair is displayed live on the dashboard as the ZONES row — e.g., "22 / 78" — updating continuously as new bars accumulate.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ [b]RSI Coil Engine — Momentum Compression Detection[/b]

The RSI Coil Engine translates the volatility compression concept — so central to CATALYST, VECTOR, and PRISM — into the RSI domain. Instead of measuring price volatility compression, it measures [b]RSI bandwidth compression</b>: how much the Core RSI is oscillating relative to its recent average oscillation.

[b]Coil detection:[/b]
On every bar, the system computes:
`RSI Bandwidth = Highest Core RSI over coilLen − Lowest Core RSI over coilLen`

This is then compared to the average bandwidth over the same period. When current bandwidth falls below `average × coilMult` (default: 0.72), the Core RSI is oscillating in a significantly tighter range than usual — all three RSI layers are converging. The inCoil boolean activates, the phase displays as COIL, and the dashboard COIL BW row shows "COMPRESSED."

[b]Coil release detection:[/b]
A coil release is the transition from compressed (inCoil was true on the prior bar) to decompressed (inCoil is false on the current bar), accompanied by a Pulse RSI move of at least the configured minimum (default: 2.5 RSI points) in a single bar. This rapid Pulse RSI expansion is the momentum equivalent of a volatility breakout — the RSI bandwidth spring is releasing directional energy.

[b]What the RSI coil captures:[/b] When all three RSI layers converge toward neutral with declining bandwidth, institutional participants are in a standoff — neither buyers nor sellers are winning the momentum battle. The coil release is the moment that standoff resolves, and the direction of the Pulse RSI's first large move after the release is the signal of who won. The COIL RELEASE setup capitalizes on this first-mover momentum advantage.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🏷 [b]Four Setup Types — The Resonance Playbook[/b]

RESONANCE fires signals through four distinct setup types, each exploiting a different momentum pattern detected by the triple-RSI harmonic system. All four can be enabled simultaneously and the highest-priority qualifying setup is selected for each signal bar.

[b]Setup priority order (when multiple qualify simultaneously):[/b]
COIL RELEASE → DIVERGENCE REVERSAL → HARMONIC BREAK → SNAPBACK

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Setup A — SNAPBACK (Adaptive OB/OS Exit)[/b]

The mean-reversion setup. Fires when the Pulse RSI exits the adaptive exhaustion zone with Core RSI confirmation.

[b]Long conditions:[/b]
[list]
[*]Pulse RSI crosses above the dynamic oversold level (dynOs) — exiting the adaptive oversold zone
[*]Core RSI is rising on the current bar (rsiCore > rsiCore[1]) — intermediate momentum is recovering
[*]Anchor RSI is within 8 points of the midline on the bullish side (anchor > midLine − 8) — the macro context is not severely bearish
[*]A bullish rejection candle is present (close above open, close above prior close)
[/list]

[b]Why SNAPBACK is the timing-precision setup:[/b] The combination of the adaptive oversold exit (not fixed 30) and Core RSI confirmation means the signal only fires when the oversold reading is genuine by historical standards AND the intermediate momentum has already begun recovering. The Anchor RSI tolerance prevents SNAPBACK longs from firing in deeply bearish macro environments where mean-reversion is likely to fail.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Setup B — HARMONIC BREAK (50-Line Cascade)[/b]

The momentum-continuation setup. Fires when the Pulse RSI crosses the harmonic midline (default: 50) with all three RSI layers stacked in the same direction.

[b]Long conditions:[/b]
[list]
[*]Pulse RSI crosses above the harmonic midline from below
[*]stackBull is true — all three RSIs are above their respective midline thresholds (Pulse > 50, Core > 48, Anchor > 46)
[*]slopeBull is true — all three RSI slopes over 3 bars are positive (Pulse slope > 0, Core slope > 0, Anchor slope ≥ 0)
[/list]

[b]Why the triple-stack midline cross is significant:[/b] A single RSI crossing 50 is noise. When the Pulse RSI crosses 50 simultaneously with Core RSI already above 48 and Anchor RSI above 46 — all three slopes positive — it means the fast, intermediate, and slow momentum layers are all accelerating upward at the same moment. This is genuine broad-based momentum conviction, not a temporary oscillation. The cascade quality reflects institutional commitment across multiple momentum timeframes.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Setup C — DIVERGENCE REVERSAL (Pivot-Based)[/b]

The reversal setup using Core RSI pivot divergence. Fires when price makes a new extreme but Core RSI does not confirm it, within the adaptive exhaustion zone context.

[b]Long divergence conditions:[/b]
[list]
[*]A confirmed price pivot low is below the prior confirmed pivot low — price is making a lower low
[*]The Core RSI at the same pivot low bar is above the Core RSI at the prior pivot low — momentum is making a higher low despite price's lower low
[*]Core RSI at the divergence low is within 8 points of the dynamic oversold level — the divergence is occurring in a genuinely oversold context, not at neutral RSI
[*]A bullish rejection candle confirms on or after the divergence bar
[*]Pulse RSI is rising on the current bar
[*]Current close is above the divergence low — price has recovered off the pivot
[/list]

[b]Divergence recency window:[/b]
Divergence is tracked with a live validity window — the divergence remains active for a configurable number of bars (default: divLen × 2). If no confirming rejection candle appears within this window, the divergence expires. This prevents acting on stale divergence signals that occurred many bars ago.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Setup D — COIL RELEASE (RSI Bandwidth Explosion)[/b]

The momentum breakout setup fired by RSI bandwidth decompression. The highest-priority setup in the selection hierarchy.

[b]Long conditions:[/b]
[list]
[*]coilRelease is true — the Core RSI was compressed on the prior bar and the bandwidth expanded this bar with a minimum Pulse RSI move
[*]Pulse RSI is above the dynamic oversold level — the release is occurring on the bullish side of the exhaustion zone
[*]slopeBull is true — all three RSI slopes are positive, confirming the release is directionally bullish
[*]A bullish candle is present (close above open)
[/list]

[b]Why COIL RELEASE is the highest-priority setup:[/b] RSI bandwidth compression is the most reliable pre-breakout indicator within the RSI framework. When all three RSI layers have converged to the same neutral zone and then the bandwidth suddenly expands with a directional Pulse RSI move, the momentum suppression has lifted and the underlying institutional order flow has revealed its direction. This is the RSI equivalent of CATALYST's squeeze release — and like the squeeze release, the first bar of the release carries the highest momentum intensity of the entire move.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🧠 [b]The Resonance Score — 10-Point Conviction Rating[/b]

Every bar, regardless of whether a signal fires, RESONANCE computes a directional conviction score from 0 to 10. This score is displayed live on the dashboard, shown on signal labels when Show Setup Tag is enabled, and used as the minimum gate for all signals — setups below the minimum score threshold (default: 5) are blocked regardless of their setup type conditions.

[b]Score components:[/b]

[b]RSI Stack Alignment (up to 2 points):[/b]
Full triple-stack (stackBull or stackBear — all three RSIs stacked) scores 2 points. Partial alignment (Pulse and Core both above midline but Anchor lagging) scores 1 point. No alignment scores 0. This is the highest-weight component — genuine triple-stack alignment is rare and carries the most institutional significance.

[b]RSI Slope Agreement (up to 2 points):[/b]
All three RSI slopes positive (slopeBull) or all negative (slopeBear) scores 2 points. Pulse and Core slopes aligned (but Anchor flat or lagging) scores 1 point. No slope agreement scores 0. Momentum acceleration across multiple timeframes — not just direction but rate of change — is the key measure of this component.

[b]RSI Hierarchy Alignment (1 point):[/b]
For bull: Pulse RSI above Core RSI and Core RSI approximately above Anchor RSI (within 3 points). For bear: Pulse below Core and Core below Anchor within tolerance. This checks that the RSI layers are in the correct relative order — the faster layer leading the slower, which is the natural configuration during genuine trending momentum.

[b]HTF Bias (up to 2 points):[/b]
Higher timeframe EMA aligned with the signal direction scores 2 points. When HTF is disabled in settings, 1 neutral point is always awarded. When HTF is enabled and opposes the signal, 0 points.

[b]Volume Expansion (1 point):[/b]
Current bar volume meets or exceeds the configured volume threshold.

[b]Non-Chop Market (1 point):[/b]
Choppiness Index is below the configured threshold. Also enforced as a hard gate.

[b]EMA Filter (1 point, optional):[/b]
Price is on the correct side of the configurable EMA. Off by default.

[b]Grade thresholds:[/b]
[list]
[*][b]A (8–10)[/b] — elite resonance. Triple-stack, slope agreement, HTF aligned, volume confirmed. The highest-conviction signal the system produces
[*][b]B (6–7)[/b] — strong resonance. Most components confirmed
[*][b]C (minimum to 5)[/b] — acceptable resonance. Passes the gate with partial confirmation
[/list]

[b]Signal accent colors:[/b] Grade A signals render in the brightest yellow-green (bull) or red (bear). Grade B in slightly dimmer versions. Grade C in transparent-tinted versions. The signal triangle's color communicates quality at a glance without reading the dashboard.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎨 [b]Candle Tinting and Phase Background[/b]

RESONANCE includes two optional chart coloring systems that provide continuous visual context even between signals.

[b]Candle Tinting (showBarTint):[/b]
When enabled (default: on), candles are tinted yellow-green at 78% transparency during stackBull conditions and red at 78% transparency during stackBear conditions. During neutral periods (no full stack), candles retain their default color. This creates a continuous visual momentum ribbon directly on the price chart — you can see at a glance how long a triple-stack condition has been sustained, when it begins, and when it collapses.

[b]Phase Background (showPhaseBg):[/b]
When enabled (default: off), a very subtle full-bar background color reflects the current harmonic phase — purple for COIL, faint yellow-green for MARKUP/ACCUM, faint red for MARKDOWN/DISTRIB. Off by default to preserve chart cleanliness, but valuable when studying phase transitions.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]Live Dashboard[/b]

The 14-row real-time dashboard displays the complete state of the harmonic RSI engine.

[b]PHASE[/b]
[list]
[*][b]HARMONIC[/b] — current market phase: MARKUP, MARKDOWN, ACCUM, DISTRIB, COIL, or NEUTRAL. Color-coded — purple for COIL, yellow-green for bullish phases, red for bearish phases
[*][b]SETUP[/b] — the current or most recent setup with grade: e.g., "COIL REL [A]", "SNAPBACK [B]", "DIV REV [C]", or "ARM LONG [—]" when approaching a trigger. ARM LONG / ARM SHORT appear when a setup condition is developing but the full signal has not yet fired
[/list]

[b]RSI STACK[/b]
[list]
[*][b]PULSE[/b] — the live 7-period RSI value, color-coded yellow-green above the midline and red below
[*][b]CORE[/b] — the live 14-period RSI value with the same color coding
[*][b]ANCHOR[/b] — the live 28-period RSI value — the macro momentum reference
[*][b]ZONES[/b] — the current dynamic oversold / overbought pair (e.g., "22 / 78"), displayed in orange. These are the adaptive exhaustion thresholds that the SNAPBACK setup watches
[/list]

[b]QUALITY[/b]
[list]
[*][b]RESONANCE[/b] — the live directional conviction score out of 10. Yellow-green when at or above the minimum threshold, neutral otherwise
[*][b]HTF BIAS[/b] — ▲ BULL, ▼ BEAR, or — FLAT from the higher timeframe EMA structure
[*][b]CHOP[/b] — live Choppiness Index value. Orange when above the stand-aside threshold (the hard gate condition)
[*][b]COIL BW[/b] — the current RSI bandwidth state: "COMPRESSED · xx.x" (purple) when in coil, "OPEN · xx.x" otherwise. When an active trade plan exists, the current TP1 level is appended to this row for quick reference
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 [b]Chart Visual System[/b]

[list]
[*][b]▲ Triangle (below bar)[/b] — bull entry signal. Size and color reflect the Resonance Grade — brightest yellow-green for Grade A, dimmer for B, transparent-tinted for C. COIL RELEASE and DIVERGENCE signals render in purple and orange accents respectively to distinguish them visually from SNAPBACK and HARMONIC signals
[*][b]▼ Triangle (above bar)[/b] — bear entry signal with matching grade-based coloring
[*][b]Setup Tag Label (optional)[/b] — when Show Setup Tag is enabled, a small label appears below (bull) or above (bear) the signal showing the setup abbreviation and grade (e.g., "COIL REL A"). Off by default for chart cleanliness
[*][b]Candle Tinting[/b] — yellow-green at 78% transparency during stackBull, red during stackBear. Continuous momentum ribbon effect on the price chart
[*][b]Phase Background (optional, off by default)[/b] — subtle full-bar tint for COIL (purple), MARKUP/ACCUM (faint yellow-green), MARKDOWN/DISTRIB (faint red)
[*][b]Entry Line (dashed)[/b] — the entry close level, extending guideExtend bars forward when Show SL + TP1 + TP2 is enabled
[*][b]SL Line (red dashed)[/b] — ATR-based stop loss level, extending forward
[*][b]TP1 Line (lime dotted)[/b] — first take profit at 1.8× ATR from entry
[*][b]TP2 Line (bright yellow-green dashed, width 2)[/b] — second take profit at 3.2× ATR from entry
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 [b]How to Trade with AlphaX RESONANCE — Step by Step[/b]

[b]Step 1 — Read the Phase and Stack[/b]
[list]
[*]Check the HARMONIC row on the dashboard. MARKUP or MARKDOWN with a confirmed triple-stack (candles tinted yellow-green or red) is the ideal background condition for HARMONIC BREAK and SNAPBACK entries
[*]Check COIL BW — COMPRESSED means RSI bandwidth is in squeeze mode. Prepare for a COIL RELEASE signal on the upcoming bars
[*]Check ZONES — how far is current price/RSI from the adaptive exhaustion levels? When the CORE RSI is approaching or inside the dynamic zone, a SNAPBACK is potentially developing
[*]Check RESONANCE score. If it is already at or above the minimum before a signal fires, the conditions are favorable. Watch for the triggering setup condition to develop
[/list]

[b]Step 2 — Identify the Setup Developing[/b]
[list]
[*]SETUP shows ARM LONG or ARM SHORT when a setup condition is partially met but the full signal has not fired. This is your preparation window — note the entry price, calculate SL and TP positions
[*]COIL BW showing COMPRESSED → watch for the next bar's release. If SETUP shows ARM LONG during a coil, a COIL RELEASE long may fire on the next expansion bar
[*]HARMONIC row switching from ACCUM to MARKUP → the Anchor RSI has crossed 58 and is rising. HARMONIC BREAK long conditions may soon be met as the Pulse RSI approaches the midline from below
[/list]

[b]Step 3 — Enter on the Triangle Signal[/b]
[list]
[*]A triangle signal with Grade A coloring (brightest yellow-green or red) is the highest-conviction entry. Enter on the close of the signal bar or the next bar's open
[*]Check which setup fired on the dashboard SETUP row. COIL REL [A] is the premium setup. DIV REV [B] is a high-quality reversal. HARMONIC [A] is a premium continuation. SNAPBACK [C] at minimum score warrants reduced size
[*]Enable Show SL + TP1 + TP2 to see the ATR-based guide levels projected forward from the signal bar
[/list]

[b]Step 4 — Manage with RSI Context[/b]
[list]
[*]During a long trade, monitor the PULSE RSI value. When it approaches the dynamic overbought zone (dynOb), partial profit at TP1 becomes prudent — momentum may be approaching exhaustion
[*]If the phase transitions from MARKUP to DISTRIB during an open long trade (Anchor RSI still high but Core RSI rolling over), tighten the stop
[*]If the candle tint disappears (triple-stack collapses), the momentum conviction has weakened — move stop to breakeven or take profit
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Identifying Low-Quality Conditions — When Not to Trade[/b]

[b]Stand aside when:[/b]
[list]
[*][b]CHOP is orange on the dashboard[/b] — the hard gate is active. Extreme chop blocks all signals. RSI oscillates rapidly in choppy conditions and the triple-stack alignments are transient rather than structural
[*][b]Phase shows NEUTRAL[/b] — none of the five phase conditions have been met. The Anchor RSI is in the middle zone (48–52) without a clear slope. Momentum conviction is absent at the macro level
[*][b]RESONANCE score is exactly at minimum (5/10)[/b] — marginal confluence. In neutral or transitional market conditions, minimum-score signals fail at a significantly higher rate. Require 6+ before committing full size
[*][b]COIL BW is COMPRESSED but no directional RSI slope is present[/b] — a coil without slope agreement means RSI has converged but without directional bias. The COIL RELEASE signal requires slopeBull or slopeBear to fire, but if the slopes are flat during the coil, the release direction is unpredictable — wait for a slope to develop before sizing up
[*][b]HTF Bias opposes the stack direction[/b] — a bull triple-stack against a bearish HTF is a counter-trend momentum entry. These work but carry higher reversal risk. Reduce position size or require a Grade A score
[*][b]SETUP shows ARM LONG but Anchor RSI is in severely bearish territory (below 35)[/b] — approaching a SNAPBACK long trigger against a deeply bearish Anchor is a mean-reversion trade against significant macro momentum. The Anchor RSI tolerance condition blocks the signal below midLine − 8, but values near that boundary are still high-risk
[/list]

[b]The ideal RESONANCE setup:[/b]
[list]
[*]Phase MARKUP (bull) or MARKDOWN (bear) sustained for 5+ bars
[*]Full triple-stack with positive slopes on all three RSIs
[*]COIL BW just releasing from COMPRESSED state (COIL RELEASE setup) OR Pulse RSI crossing the midline with stack and slope confirmed (HARMONIC BREAK)
[*]HTF aligned with stack direction
[*]Volume above average on the signal bar
[*]RESONANCE score at 8–10 (Grade A)
[*]Chop Index well below threshold
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ [b]Key Features[/b]
[list]
[*]🎵 Triple-RSI harmonic stack — Pulse (7), Core (14), and Anchor (28) RSIs operating simultaneously, each measuring a different temporal dimension of momentum
[*]📐 Adaptive exhaustion zones — dynamic overbought and oversold thresholds computed from the Core RSI's own percentile distribution over the configurable lookback, replacing fixed 70/30 levels with statistically calibrated thresholds
[*]⚡ RSI Coil Engine — bandwidth compression detection triggering when Core RSI oscillation falls below average × multiplier, with directional coil release detection on bandwidth expansion
[*]📊 Five-phase market classification — MARKUP, MARKDOWN, ACCUM, DISTRIB, COIL — derived from the Anchor RSI level and slope, providing macro momentum context for every signal
[*]🏷 Four setup types — SNAPBACK (adaptive OB/OS exit), HARMONIC BREAK (triple-stack midline cascade), DIVERGENCE REVERSAL (pivot-based Core RSI divergence), COIL RELEASE (RSI bandwidth explosion)
[*]🧠 10-point Resonance Score — RSI Stack (2pts), Slope Agreement (2pts), Hierarchy Alignment (1pt), HTF Bias (2pts), Volume (1pt), Non-Chop (1pt), EMA Filter (1pt, optional)
[*]🎨 Grade-coded signal colors — Grade A in full brightness, B in standard, C in transparent-tinted. COIL signals in purple, DIV signals in orange accent — visual quality differentiation on every triangle
[*]🌈 Candle tinting — bars colored yellow-green during stackBull and red during stackBear, creating a continuous momentum ribbon on the price chart
[*]🔮 ARM LONG / ARM SHORT awareness — dashboard SETUP row shows developing (partially-triggered) conditions before the full signal fires, providing advance preparation
[*]📡 Pivot-based RSI divergence — structural pivot comparisons with live validity window, more robust than slope-based divergence detection
[*]📊 14-row live dashboard — Phase, Setup with grade, all three RSI values, adaptive zones, Resonance Score, HTF Bias, Chop, and Coil bandwidth updated on every bar
[*]🔔 2 alert conditions — RESONANCE Bullish Setup and RESONANCE Bearish Setup
[*]⚙ Fully configurable — all three RSI periods, zone lookback and percentiles, harmonic midline, coil compression multiplier, coil release minimum, all four setup enables, divergence pivot length, cooldown, Resonance minimum, HTF timeframe and EMAs, volume filter, chop gate, optional EMA filter, SL/TP ATR multiples, guide extension, phase background, candle tinting, setup tags, dashboard size and position, and all colors are independently adjustable
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙ [b]Settings Reference[/b]

[b]RSI Harmonic Stack[/b]
[list]
[*]Pulse RSI Length — the fastest RSI layer for snapback timing and coil release triggering (default: 7)
[*]Core RSI Length — the intermediate layer for divergence detection and bandwidth measurement (default: 14)
[*]Anchor RSI Length — the slowest layer for phase classification and macro context (default: 28)
[*]Adaptive Zone Lookback — bars used to compute the Core RSI percentile distribution for the dynamic exhaustion zones (default: 100)
[*]Exhaustion Percentile High — percentile level defining the dynamic overbought threshold (default: 82)
[*]Exhaustion Percentile Low — percentile level defining the dynamic oversold threshold (default: 18)
[*]Harmonic Midline — the RSI equilibrium level used as the HARMONIC BREAK trigger and phase divider (default: 50)
[/list]

[b]RSI Coil Engine[/b]
[list]
[*]Coil Lookback — bars used to compute RSI bandwidth and its average (default: 20)
[*]Coil Compression Mult — bandwidth must fall below average × this multiplier to activate the compressed state (default: 0.72)
[*]Coil Release Min RSI Move — minimum single-bar Pulse RSI movement required to register a release (default: 2.5 RSI points)
[/list]

[b]Live Setups[/b]
[list]
[*]Snapback (adaptive OB/OS exit) — toggle the adaptive exhaustion zone exit setup
[*]Harmonic Break (50-line cascade) — toggle the triple-stack midline crossover setup
[*]Divergence Reversal — toggle the pivot-based Core RSI divergence setup
[*]Coil Release — toggle the RSI bandwidth decompression setup
[*]Divergence Pivot Length — bars each side for RSI and price pivot confirmation (default: 5)
[*]Signal Cooldown (bars) — minimum bars between consecutive signals (default: 6)
[/list]

[b]Resonance Gate[/b]
[list]
[*]Min Resonance Score (of 10) — minimum score to fire any signal (default: 5)
[*]Hard HTF Alignment — when on, counter-HTF signals are fully blocked
[*]HTF Trend Bias / HTF Timeframe / HTF Fast / HTF Slow EMA — higher timeframe parameters (defaults: on / 60-minute / 21 / 55)
[*]Volume Confirm / Volume vs Avg / Volume Avg — volume expansion layer parameters (defaults: on / 1.1× / 20 bars)
[*]Block Extreme Chop / Choppiness Length / Chop Block Above — chop gate parameters (defaults: on / 14 / 62.0)
[*]EMA Price Filter / EMA Length — optional price EMA directional filter (default: off / 21)
[/list]

[b]Entry / Exit Guides[/b]
[list]
[*]Show SL + TP1 + TP2 — toggle the guide line system (default: off)
[*]ATR Length — ATR calculation lookback (default: 14)
[*]SL (xATR) — stop loss distance from entry in ATR multiples (default: 1.2)
[*]TP1 (xATR) — first take profit distance (default: 1.8)
[*]TP2 (xATR) — second take profit distance (default: 3.2)
[*]Guide Extend (bars) — how many bars forward guide lines project (default: 30)
[/list]

[b]Display[/b]
[list]
[*]Show Entry Markers — toggle signal triangle shapes
[*]Subtle Phase Background — toggle the harmonic phase background tinting (default: off)
[*]Phase Background Opacity — background transparency when enabled (default: 96)
[*]Tint Candles by Bias — toggle yellow-green/red candle tinting during triple-stack conditions (default: on)
[*]Show Setup Tag (A/B/C) — toggle setup name and grade label on signal bars (default: off)
[*]Show Dashboard — toggle the full dashboard
[*]Dashboard Text Size — Standard / Small
[*]Dashboard Position — Top Left / Top Right / Bottom Left / Bottom Right
[/list]

[b]Colors[/b]
[list]
[*]Bull / Resonance Up — yellow-green for bullish signals, tinting, and stack indicators
[*]Bull Signal — bright yellow-green for Grade A bull signal triangles
[*]Bear / Resonance Down — red for bearish signals and stack indicators
[*]Bear Signal — bright red for Grade A bear signals
[*]Coil / Harmonic Accent — purple for COIL phase, RSI coil markers, and COIL RELEASE signals
[*]Snapback Accent — orange for SNAPBACK signals, divergence accents, and ZONES dashboard row
[*]Stop Line / TP1 Line / TP2 Line — individual guide line colors
[*]Neutral — gray for neutral states and inactive dashboard rows
[*]Dash Text / Dash BG / Dash Header / Dash Section / Dash Frame — full dashboard color control
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔔 [b]Alert Conditions (2 total)[/b]

[list]
[*]RESONANCE Bullish Setup — all long conditions confirmed. Pulse RSI trigger, Resonance Score above minimum, chop gate clear, HTF alignment met
[*]RESONANCE Bearish Setup — all short conditions confirmed
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 [b]Recommended Settings by Instrument & Timeframe[/b]

The default configuration is optimized for [b]XAUUSD, major forex pairs, and crypto on M5–H1[/b]:
[list]
[*]Triple RSI at 7/14/28 — the 2× doubling ratio creates clean harmonic separation between the three layers. Each layer is exactly twice as slow as the prior one, producing independent but harmonically related readings
[*]Adaptive zone lookback at 100 bars — approximately 8 hours on M5, sufficient to calibrate the percentile distribution to current intraday volatility conditions
[*]Coil multiplier at 0.72 — requires RSI bandwidth to fall below 72% of its average to declare compression. Tight enough to catch genuine coils without excessive false compressions
[*]Resonance minimum at 5 — balanced between frequency and quality. Raise to 6–7 for higher conviction filtering
[/list]

For other instruments or timeframes, adjust:
[list]
[*][b]M1–M3 scalping[/b] — reduce RSI periods to 5/9/18, reduce Adaptive Zone Lookback to 60, reduce Cooldown to 3, reduce Guide Extend to 15, reduce Coil Release Min to 1.5
[*][b]H4–Daily swing trading[/b] — increase RSI periods to 9/21/42, increase Zone Lookback to 200, increase TP2 to 5.0× ATR, raise Min Resonance to 6
[*][b]Crypto (BTC, ETH)[/b] — increase Adaptive Zone Percentile High to 85 and Low to 15 for the wider RSI distribution of crypto. Increase Coil Release Min to 3.0 for the larger single-bar RSI moves
[*][b]Indices (NAS100, US30)[/b] — use EMA Price Filter with a 50-period EMA, increase Min Resonance to 6, restrict via session filter to cash market hours
[*][b]More signals[/b] — lower Min Resonance to 4, reduce Cooldown to 3, enable all four setups, widen adaptive zone percentiles (75/25)
[*][b]Ultra-selective only[/b] — raise Min Resonance to 7–8, enable Hard HTF Alignment, enable EMA Price Filter, require Grade A minimum (increase minResonance to 8), disable SNAPBACK
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👥 [b]Who This Is For[/b]
[list]
[*]📊 [b]Momentum and RSI traders who want more than a single oscillator[/b] — RESONANCE is the definitive multi-period RSI implementation in the AlphaX suite. Three periods, five phases, four setups, and a 10-point scoring system replace the single-line RSI with a complete momentum intelligence framework
[*]🎵 [b]Traders who understand that momentum has layers[/b] — the 7/14/28 harmonic stack separates fast momentum (entry timing), intermediate momentum (structural backing), and slow momentum (macro context) into three distinct readings that must align before the highest-quality signals fire
[*]📐 [b]Traders who struggle with fixed RSI overbought/oversold levels[/b] — the adaptive exhaustion zones calibrate to the actual RSI distribution of the current instrument at the current time, producing thresholds that are statistically meaningful rather than arbitrary
[*]⚡ [b]Volatility coil traders who want the RSI-domain equivalent[/b] — the RSI Coil Engine applies the compression-and-release concept from CATALYST to the momentum domain, detecting RSI bandwidth squeezes that precede explosive directional moves
[*]🔀 [b]Mean-reversion and trend-following traders simultaneously[/b] — SNAPBACK entries are mean-reversion (adaptive OB/OS exits). HARMONIC BREAK entries are trend continuation (triple-stack midline). Both are available within the same system, automatically selected based on which fires first
[*]🥇 [b]Gold and forex intraday traders[/b] — the 7/14/28 RSI stack with adaptive zones is particularly effective on XAUUSD and major forex pairs where the RSI distribution shifts significantly between trending and ranging sessions
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 [b]Notes[/b]
[list]
[*]All signals are confirmed on bar close — the indicator is non-repainting by design. All RSI computations, stack alignments, divergence detections, and confluence scoring finalize on confirmed bars
[*]The adaptive exhaustion zones require the full Adaptive Zone Lookback period to calibrate. On charts with fewer bars than the lookback setting, the dynamic thresholds may not reflect accurate percentile distributions. Allow at least the full lookback period (default: 100 bars) to accumulate before treating the SNAPBACK setup as fully calibrated
[*]The RSI Coil Engine's bandwidth average also requires the Coil Lookback period to stabilize. On fresh chart loads, the COMPRESSED state may trigger briefly before the average has fully computed — this resolves naturally within the coil lookback period
[*]The divergence validity window (divLen × 2 bars after detection) means divergence signals can fire up to 10 bars (default divLen 5 × 2) after the actual pivot low or high. The confirming candle requirement prevents stale divergences from generating signals without fresh price confirmation
[*]The candle tinting applies the stackBull/stackBear condition which uses a ±2 to ±4 tolerance buffer around the midline for Core and Anchor RSIs. This prevents the tinting from flickering on and off as Core or Anchor RSIs oscillate near the midline. The tint represents sustained broad stack alignment, not momentary
[*]Guide lines (SL, TP1, TP2) are only drawn on the last bar and are redrawn whenever a new signal fires. They reflect the most recent active trade plan
[*]The indicator does not track open positions or P&L and does not connect to any broker or account
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Disclaimer[/b]

This indicator is a technical analysis and visualization tool intended for educational and informational purposes only. It does not constitute financial advice or a recommendation to buy or sell any financial instrument. All signals are generated from historical and real-time price data using mathematical calculations — their accuracy or profitability is not guaranteed. Past performance of any signal type does not guarantee future results. Always conduct your own analysis, use proper risk management, and consult a licensed financial advisor before making any trading decisions. The author accepts no responsibility for any losses incurred from the use of this indicator.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[i]Built for traders who understand that momentum is not a single number — it is a harmonic relationship between fast energy, intermediate conviction, and slow institutional commitment.[/i]

## Source Code

````pine
// © AlphaX — RESONANCE v1.0
// RSI Harmonic Resonance Engine — triple-RSI stack, adaptive exhaustion zones,
// coil-release momentum, pivot divergence reversals. Not a generic RSI overlay.

//@version=6
indicator("[ A L P H A X ] RESONANCE - Triple-RSI Stack", shorttitle="AlphaX RESONANCE",
  overlay=true, max_labels_count=50, max_lines_count=500, max_bars_back=500)

// ═══════════════════════════════════════════════════════════════════════════════
//  RSI STACK
// ═══════════════════════════════════════════════════════════════════════════════
grpRsi = "RSI Harmonic Stack"
rsiPulseLen   = input.int(7, "Pulse RSI Length", minval=3, maxval=21, group=grpRsi,
  tooltip="Fast RSI — snapback timing and coil release trigger.")
rsiCoreLen    = input.int(14, "Core RSI Length", minval=5, maxval=50, group=grpRsi)
rsiAnchorLen  = input.int(28, "Anchor RSI Length", minval=10, maxval=100, group=grpRsi)
zoneLen       = input.int(100, "Adaptive Zone Lookback", minval=30, maxval=300, group=grpRsi)
zonePctHi     = input.float(82.0, "Exhaustion Percentile (High)", minval=70, maxval=95, step=1, group=grpRsi)
zonePctLo     = input.float(18.0, "Exhaustion Percentile (Low)", minval=5, maxval=30, step=1, group=grpRsi)
midLine       = input.float(50.0, "Harmonic Midline", minval=45, maxval=55, step=0.5, group=grpRsi)

grpCoil = "RSI Coil Engine"
coilLen       = input.int(20, "Coil Lookback", minval=8, maxval=60, group=grpCoil)
coilMult      = input.float(0.72, "Coil Compression Mult", minval=0.4, maxval=0.95, step=0.02, group=grpCoil,
  tooltip="RSI bandwidth must fall below average × this to count as compressed.")
releaseMin    = input.float(2.5, "Coil Release Min RSI Move", minval=0.5, maxval=8, step=0.25, group=grpCoil)

grpSetups = "Live Setups"
enSnapback    = input.bool(true, "Snapback (adaptive OB/OS exit)", group=grpSetups,
  tooltip="Pulse RSI exits adaptive exhaustion zone with anchor confirmation.")
enHarmonic    = input.bool(true, "Harmonic Break (50-line cascade)", group=grpSetups,
  tooltip="Pulse crosses midline with core + anchor stacked on same side.")
enDivergence  = input.bool(true, "Divergence Reversal", group=grpSetups)
enCoilRelease = input.bool(true, "Coil Release", group=grpSetups)
divLen        = input.int(5, "Divergence Pivot Length", minval=2, maxval=15, group=grpSetups)
cooldown      = input.int(6, "Signal Cooldown (bars)", minval=1, maxval=40, group=grpSetups)

grpConf = "Resonance Gate"
minResonance  = input.int(5, "Min Resonance Score (of 10)", minval=3, maxval=10, group=grpConf)
requireHtf    = input.bool(false, "Hard HTF Alignment", group=grpConf)
useHtf        = input.bool(true, "HTF Trend Bias", group=grpConf)
htfTf         = input.timeframe("60", "HTF Timeframe", group=grpConf)
htfFast       = input.int(21, "HTF Fast EMA", minval=5, maxval=100, group=grpConf)
htfSlow       = input.int(55, "HTF Slow EMA", minval=10, maxval=200, group=grpConf)
useVol        = input.bool(true, "Volume Confirm", group=grpConf)
volMult       = input.float(1.1, "Volume vs Avg", minval=0.8, maxval=3.0, step=0.05, group=grpConf)
volLen        = input.int(20, "Volume Avg", minval=5, maxval=100, group=grpConf)
useChop       = input.bool(true, "Block Extreme Chop", group=grpConf)
chopLen       = input.int(14, "Choppiness Length", minval=5, maxval=50, group=grpConf)
chopMax       = input.float(62.0, "Chop Block Above", minval=50, maxval=80, step=0.5, group=grpConf)
useEmaFilt    = input.bool(false, "EMA Price Filter", group=grpConf)
emaLen        = input.int(21, "EMA Length", minval=5, maxval=100, group=grpConf)

grpExit = "Entry / Exit Guides"
showGuides    = input.bool(false, "Show SL + TP1 + TP2", group=grpExit)
atrLen        = input.int(14, "ATR Length", minval=2, maxval=100, group=grpExit)
slAtr         = input.float(1.2, "SL (xATR)", minval=0.3, maxval=5.0, step=0.1, group=grpExit)
tp1Atr        = input.float(1.8, "TP1 (xATR)", minval=0.5, maxval=8.0, step=0.1, group=grpExit)
tp2Atr        = input.float(3.2, "TP2 (xATR)", minval=1.0, maxval=12.0, step=0.1, group=grpExit)
guideExtend   = input.int(30, "Guide Extend (bars)", minval=10, maxval=80, group=grpExit)

grpVis = "Display"
showSignals   = input.bool(true, "Show Entry Markers", group=grpVis)
showPhaseBg   = input.bool(false, "Subtle Phase Background", group=grpVis)
bgOpacity     = input.int(96, "Phase Background Opacity", minval=85, maxval=100, group=grpVis)
showBarTint   = input.bool(true, "Tint Candles by Bias", group=grpVis)
showSetupTags = input.bool(false, "Show Setup Tag (A/B/C)", group=grpVis)
showDash      = input.bool(true, "Show Dashboard", group=grpVis)
dashSize      = input.string("Standard", "Dashboard Text Size",
  options=["Standard", "Small"], group=grpVis)
dashPos       = input.string("Top Right", "Dashboard Position",
  options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=grpVis)

grpColors = "Colors (AlphaX Palette)"
colBull       = input.color(#c8e624, "Bull / Resonance Up", group=grpColors)
colBullBr     = input.color(#d4f03a, "Bull Signal", group=grpColors)
colBear       = input.color(#ff1744, "Bear / Resonance Down", group=grpColors)
colBearBr     = input.color(#ff5252, "Bear Signal", group=grpColors)
colLattice    = input.color(#8b6fd0, "Coil / Harmonic Accent", group=grpColors)
colPending    = input.color(#ff9800, "Snapback Accent", group=grpColors)
colSlLine     = input.color(#ff1744, "Stop Line", group=grpColors)
colTp1Line    = input.color(#9ccc65, "TP1 Line", group=grpColors)
colTp2Line    = input.color(#c8e624, "TP2 Line", group=grpColors)
colNeutral    = input.color(#555555, "Neutral", group=grpColors)
colTextLt     = input.color(#cccccc, "Dash Text", group=grpColors)
colDashBg     = input.color(#1a1a1a, "Dash BG", group=grpColors)
colDashHeader = input.color(#111111, "Dash Header", group=grpColors)
colDashSec    = input.color(#222222, "Dash Section", group=grpColors)
colDashFrame  = input.color(#c8e624, "Dash Frame", group=grpColors)

// ═══════════════════════════════════════════════════════════════════════════════
//  TYPES & STATE
// ═══════════════════════════════════════════════════════════════════════════════
type TradePlan
    bool   valid
    bool   bull
    string setup
    float  entry
    float  stop
    float  tp1
    float  tp2

var TradePlan EMPTY_PLAN = TradePlan.new(false, false, "", na, na, na, na)
var TradePlan activePlan = EMPTY_PLAN
var line[] guideLns = array.new_line()
var int lastSigBar = na
var int guideBar = na
var int lastDrawnGuideBar = na

var string dPhase = "—"
var string dSetup = "—"
var string dBias = "NEUTRAL"
var int dScore = 0
var string dGrade = "—"
var float dTp1 = na
var float dTp2 = na

// ═══════════════════════════════════════════════════════════════════════════════
//  CORE CALCULATIONS
// ═══════════════════════════════════════════════════════════════════════════════
atrVal = ta.atr(atrLen)
volAvg = ta.sma(volume, math.max(1, volLen))
volOk  = not useVol or volume >= volAvg * volMult

float ciSum = math.sum(ta.atr(1), chopLen)
float ciHl  = ta.highest(high, chopLen) - ta.lowest(low, chopLen)
float chopIdx = ciHl > 0 ? 100.0 * math.log10(ciSum / ciHl) / math.log10(chopLen) : 50.0
bool chopOk = not useChop or chopIdx < chopMax

htfClose = request.security(syminfo.tickerid, htfTf, close, barmerge.gaps_off, barmerge.lookahead_off)
htfFastE = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfFast), barmerge.gaps_off, barmerge.lookahead_off)
htfSlowE = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfSlow), barmerge.gaps_off, barmerge.lookahead_off)
htfBull  = htfFastE > htfSlowE and htfClose > htfFastE
htfBear  = htfFastE < htfSlowE and htfClose < htfFastE

emaLine = ta.ema(close, emaLen)
emaBullOk = not useEmaFilt or close > emaLine
emaBearOk = not useEmaFilt or close < emaLine

rsiPulse  = ta.rsi(close, rsiPulseLen)
rsiCore   = ta.rsi(close, rsiCoreLen)
rsiAnchor = ta.rsi(close, rsiAnchorLen)

dynOb = ta.percentile_nearest_rank(rsiCore, zoneLen, zonePctHi)
dynOs = ta.percentile_nearest_rank(rsiCore, zoneLen, zonePctLo)

rsiBw = ta.highest(rsiCore, coilLen) - ta.lowest(rsiCore, coilLen)
rsiBwAvg = ta.sma(rsiBw, coilLen)
bool inCoil = rsiBw < rsiBwAvg * coilMult
bool coilRelease = inCoil[1] and not inCoil and math.abs(rsiPulse - rsiPulse[1]) >= releaseMin

slopePulse  = rsiPulse - rsiPulse[3]
slopeCore   = rsiCore - rsiCore[3]
slopeAnchor = rsiAnchor - rsiAnchor[3]

bool stackBull = rsiPulse > midLine and rsiCore > midLine - 2 and rsiAnchor > midLine - 4
bool stackBear = rsiPulse < midLine and rsiCore < midLine + 2 and rsiAnchor < midLine + 4
bool slopeBull = slopePulse > 0 and slopeCore > 0 and slopeAnchor >= 0
bool slopeBear = slopePulse < 0 and slopeCore < 0 and slopeAnchor <= 0

// Harmonic phase from anchor RSI + coil state
string phase = "NEUTRAL"
if inCoil
    phase := "COIL"
else if rsiAnchor >= 58 and slopeAnchor > 0
    phase := "MARKUP"
else if rsiAnchor <= 42 and slopeAnchor < 0
    phase := "MARKDOWN"
else if rsiAnchor > 52 and rsiCore < rsiAnchor and slopeCore < 0
    phase := "DISTRIB"
else if rsiAnchor < 48 and rsiCore > rsiAnchor and slopeCore > 0
    phase := "ACCUM"
else
    phase := rsiAnchor >= 50 ? "MARKUP" : "MARKDOWN"

getDashPos(p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        => position.bottom_right

f_grade(int score) =>
    score >= 8 ? "A" : score >= 6 ? "B" : score >= minResonance ? "C" : "—"

f_signalColor(bool bull, int score) =>
    if bull
        score >= 8 ? colBull : score >= 6 ? colBullBr : color.new(colBullBr, 35)
    else
        score >= 8 ? colBear : score >= 6 ? colBearBr : color.new(colBearBr, 35)

f_setupAccent(string su, bool bull, int score) =>
    if str.contains(su, "COIL")
        colLattice
    else if str.contains(su, "DIV")
        colPending
    else
        f_signalColor(bull, score)

f_stackPts(bool bull) =>
    if bull
        stackBull ? 2 : (rsiPulse > midLine and rsiCore > midLine ? 1 : 0)
    else
        stackBear ? 2 : (rsiPulse < midLine and rsiCore < midLine ? 1 : 0)

f_slopePts(bool bull) =>
    if bull
        slopeBull ? 2 : slopePulse > 0 and slopeCore > 0 ? 1 : 0
    else
        slopeBear ? 2 : slopePulse < 0 and slopeCore < 0 ? 1 : 0

f_alignPts(bool bull) =>
    if bull
        rsiPulse > rsiCore and rsiCore >= rsiAnchor - 3 ? 1 : 0
    else
        rsiPulse < rsiCore and rsiCore <= rsiAnchor + 3 ? 1 : 0

f_htfPts(bool bull) =>
    if not useHtf
        1
    else if bull
        htfBull ? 2 : 0
    else
        htfBear ? 2 : 0

f_resonance(bool bull) =>
    int score = 0
    score += f_stackPts(bull)
    score += f_slopePts(bull)
    score += f_alignPts(bull)
    score += f_htfPts(bull)
    score += volOk ? 1 : 0
    score += chopOk ? 1 : 0
    score += bull ? (emaBullOk ? 1 : 0) : (emaBearOk ? 1 : 0)
    math.min(score, 10)

// Pivot divergence on core RSI
float plPx = ta.pivotlow(low, divLen, divLen)
float plRsi = ta.pivotlow(rsiCore, divLen, divLen)
float phPx = ta.pivothigh(high, divLen, divLen)
float phRsi = ta.pivothigh(rsiCore, divLen, divLen)

var int bullDivBar = na
var int bearDivBar = na
bool bullDivRaw = false
bool bearDivRaw = false
if not na(plPx) and not na(plRsi)
    float prevPl = ta.valuewhen(not na(plPx), low[divLen], 1)
    float prevRl = ta.valuewhen(not na(plRsi), rsiCore[divLen], 1)
    bullDivRaw := not na(prevPl) and low[divLen] < prevPl and rsiCore[divLen] > prevRl and rsiCore[divLen] <= dynOs + 8
    if bullDivRaw
        bullDivBar := bar_index - divLen
if not na(phPx) and not na(phRsi)
    float prevPh = ta.valuewhen(not na(phPx), high[divLen], 1)
    float prevRh = ta.valuewhen(not na(phRsi), rsiCore[divLen], 1)
    bearDivRaw := not na(prevPh) and high[divLen] > prevPh and rsiCore[divLen] < prevRh and rsiCore[divLen] >= dynOb - 8
    if bearDivRaw
        bearDivBar := bar_index - divLen
bool bullDivLive = not na(bullDivBar) and bar_index - bullDivBar <= divLen * 2
bool bearDivLive = not na(bearDivBar) and bar_index - bearDivBar <= divLen * 2

bool rejBull = close > open and close > close[1]
bool rejBear = close < open and close < close[1]

// ═══════════════════════════════════════════════════════════════════════════════
//  SETUPS
// ═══════════════════════════════════════════════════════════════════════════════
bool cooled = na(lastSigBar) or bar_index - lastSigBar >= cooldown
bool htfOKLong  = not requireHtf or htfBull
bool htfOKShort = not requireHtf or htfBear

bool snapLong = enSnapback and ta.crossover(rsiPulse, dynOs) and rsiCore > rsiCore[1] and
     rsiAnchor > midLine - 8 and rejBull
bool snapShort = enSnapback and ta.crossunder(rsiPulse, dynOb) and rsiCore < rsiCore[1] and
     rsiAnchor < midLine + 8 and rejBear

bool harmLong = enHarmonic and ta.crossover(rsiPulse, midLine) and stackBull and slopeBull
bool harmShort = enHarmonic and ta.crossunder(rsiPulse, midLine) and stackBear and slopeBear

bool divLong = enDivergence and bullDivLive and rejBull and rsiPulse > rsiPulse[1] and close > low[divLen]
bool divShort = enDivergence and bearDivLive and rejBear and rsiPulse < rsiPulse[1] and close < high[divLen]

bool coilLong = enCoilRelease and coilRelease and rsiPulse > dynOs and slopeBull and close > open
bool coilShort = enCoilRelease and coilRelease and rsiPulse < dynOb and slopeBear and close < open

int scoreLong = f_resonance(true)
int scoreShort = f_resonance(false)

bool snapLongOk = snapLong and scoreLong >= minResonance
bool snapShortOk = snapShort and scoreShort >= minResonance
bool harmLongOk = harmLong and scoreLong >= minResonance
bool harmShortOk = harmShort and scoreShort >= minResonance
bool divLongOk = divLong and scoreLong >= minResonance
bool divShortOk = divShort and scoreShort >= minResonance
bool coilLongOk = coilLong and scoreLong >= minResonance
bool coilShortOk = coilShort and scoreShort >= minResonance

bool bullSignal = showSignals and barstate.isconfirmed and cooled and chopOk and htfOKLong and emaBullOk and
     (snapLongOk or harmLongOk or divLongOk or coilLongOk)
bool bearSignal = showSignals and barstate.isconfirmed and cooled and chopOk and htfOKShort and emaBearOk and
     (snapShortOk or harmShortOk or divShortOk or coilShortOk)

TradePlan plan = EMPTY_PLAN

f_pickSetup(bool bull) =>
    string su = "—"
    if bull
        su := coilLongOk ? "COIL REL" : divLongOk ? "DIV REV" : harmLongOk ? "HARMONIC" : snapLongOk ? "SNAPBACK" : "—"
    else
        su := coilShortOk ? "COIL REL" : divShortOk ? "DIV REV" : harmShortOk ? "HARMONIC" : snapShortOk ? "SNAPBACK" : "—"
    su

string pickedLongSetup = f_pickSetup(true)
string pickedShortSetup = f_pickSetup(false)

f_clearGuides() =>
    int n = array.size(guideLns)
    if n > 0
        for i = 0 to n - 1
            ln = array.get(guideLns, i)
            if not na(ln)
                line.delete(ln)
        array.clear(guideLns)

f_drawGuide(TradePlan p, int x0) =>
    f_clearGuides()
    if p.valid and showGuides
        int x1 = x0 + guideExtend
        col = p.bull ? colBull : colBear
        array.push(guideLns, line.new(x0, p.entry, x1, p.entry, color=colBullBr, style=line.style_dashed, width=1))
        array.push(guideLns, line.new(x0, p.stop, x1, p.stop, color=colSlLine, style=line.style_dashed, width=1))
        array.push(guideLns, line.new(x0, p.tp1, x1, p.tp1, color=colTp1Line, style=line.style_dotted, width=1))
        array.push(guideLns, line.new(x0, p.tp2, x1, p.tp2, color=colTp2Line, style=line.style_dashed, width=2))

if bullSignal
    string su = pickedLongSetup
    float sl = close - slAtr * atrVal
    float tp1 = close + tp1Atr * atrVal
    float tp2 = close + tp2Atr * atrVal
    plan := TradePlan.new(true, true, su, close, sl, tp1, tp2)
    lastSigBar := bar_index
    dPhase := phase
    dSetup := su
    dBias := "BULL"
    dScore := scoreLong
    dGrade := f_grade(scoreLong)
    dTp1 := tp1
    dTp2 := tp2
    activePlan := plan
    guideBar := bar_index

if bearSignal
    string sus = pickedShortSetup
    float sls = close + slAtr * atrVal
    float tp1s = close - tp1Atr * atrVal
    float tp2s = close - tp2Atr * atrVal
    plan := TradePlan.new(true, false, sus, close, sls, tp1s, tp2s)
    lastSigBar := bar_index
    dPhase := phase
    dSetup := sus
    dBias := "BEAR"
    dScore := scoreShort
    dGrade := f_grade(scoreShort)
    dTp1 := tp1s
    dTp2 := tp2s
    activePlan := plan
    guideBar := bar_index

if not bullSignal and not bearSignal
    dPhase := phase
    dBias := stackBull ? "BULL" : stackBear ? "BEAR" : "NEUTRAL"
    dSetup := inCoil ? "COIL" : snapLong ? "ARM LONG" : snapShort ? "ARM SHORT" : harmLong ? "ARM LONG" : harmShort ? "ARM SHORT" : "—"
    dScore := dBias == "BULL" ? scoreLong : dBias == "BEAR" ? scoreShort : math.max(scoreLong, scoreShort)
    dGrade := f_grade(dScore)

if barstate.islast and showGuides and activePlan.valid and not na(guideBar) and guideBar != lastDrawnGuideBar
    f_drawGuide(activePlan, guideBar)
    lastDrawnGuideBar := guideBar

// ═══════════════════════════════════════════════════════════════════════════════
//  VISUALS
// ═══════════════════════════════════════════════════════════════════════════════
color phaseBg = phase == "COIL" ? color.new(colLattice, 94) :
     phase == "MARKUP" ? color.new(colBull, bgOpacity) :
     phase == "MARKDOWN" ? color.new(colBear, bgOpacity) :
     phase == "ACCUM" ? color.new(colBull, math.min(100, bgOpacity + 1)) :
     phase == "DISTRIB" ? color.new(colBear, math.min(100, bgOpacity + 1)) : na
bgcolor(showPhaseBg ? phaseBg : na, title="Phase Background")

color biasBarCol = stackBull ? color.new(colBull, 78) : stackBear ? color.new(colBear, 78) : na
barcolor(showBarTint ? biasBarCol : na)

plotshape(bullSignal, title="Long Entry", style=shape.triangleup, location=location.belowbar,
  color=f_setupAccent(pickedLongSetup, true, scoreLong), size=size.small)
plotshape(bearSignal, title="Short Entry", style=shape.triangledown, location=location.abovebar,
  color=f_setupAccent(pickedShortSetup, false, scoreShort), size=size.small)

if showSetupTags and bullSignal
    label.new(bar_index, low, pickedLongSetup + " " + f_grade(scoreLong),
      style=label.style_label_up, textcolor=#000000,
      color=f_setupAccent(pickedLongSetup, true, scoreLong), size=size.tiny)
if showSetupTags and bearSignal
    label.new(bar_index, high, pickedShortSetup + " " + f_grade(scoreShort),
      style=label.style_label_down, textcolor=#ffffff,
      color=f_setupAccent(pickedShortSetup, false, scoreShort), size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════
f_dashTitle() => dashSize == "Small" ? size.tiny : size.small
f_dashBody()  => dashSize == "Small" ? size.tiny : size.small
f_dashSub()   => dashSize == "Small" ? size.tiny : size.tiny

var table dash = table.new(getDashPos(dashPos), 2, 14,
  border_width=1, border_color=color.new(colDashFrame, 60),
  frame_width=1, frame_color=color.new(colDashFrame, 40))

if showDash and barstate.islast
    szH = f_dashTitle()
    szV = f_dashBody()
    szS = f_dashSub()
    dbg = color.new(colDashBg, 0)
    secBg = color.new(colDashSec, 0)

    table.cell(dash, 0, 0, "AlphaX RESONANCE", text_color=colBull, text_size=szH,
      bgcolor=color.new(colDashHeader, 0), text_halign=text.align_center)
    table.cell(dash, 1, 0, syminfo.ticker + " · " + timeframe.period,
      text_color=color.new(colBull, 30), text_size=szS,
      bgcolor=color.new(colDashHeader, 0), text_halign=text.align_center)

    table.cell(dash, 0, 1, "─── PHASE ───", text_color=color.new(colNeutral, 20),
      text_size=szS, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 1, "", bgcolor=secBg)

    table.cell(dash, 0, 2, "HARMONIC", text_color=colTextLt, text_size=szV, bgcolor=dbg)
    table.cell(dash, 1, 2, dPhase, text_color=phase == "COIL" ? colLattice : dBias == "BULL" ? colBull : dBias == "BEAR" ? colBear : colNeutral, text_size=szV, bgcolor=dbg)

    table.cell(dash, 0, 3, "SETUP", text_color=colTextLt, text_size=szV, bgcolor=dbg)
    table.cell(dash, 1, 3, dSetup + " [" + dGrade + "]", text_color=dBias == "BULL" ? f_signalColor(true, dScore) : dBias == "BEAR" ? f_signalColor(false, dScore) : colNeutral, text_size=szV, bgcolor=dbg)

    table.cell(dash, 0, 4, "─── RSI STACK ───", text_color=color.new(colNeutral, 20),
      text_size=szS, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 4, "", bgcolor=secBg)

    table.cell(dash, 0, 5, "PULSE", text_color=colTextLt, text_size=szV, bgcolor=dbg)
    table.cell(dash, 1, 5, str.tostring(rsiPulse, "#.#"), text_color=rsiPulse >= midLine ? colBull : colBear, text_size=szV, bgcolor=dbg)

    table.cell(dash, 0, 6, "CORE", text_color=colTextLt, text_size=szV, bgcolor=dbg)
    table.cell(dash, 1, 6, str.tostring(rsiCore, "#.#"), text_color=rsiCore >= midLine ? colBull : colBear, text_size=szV, bgcolor=dbg)

    table.cell(dash, 0, 7, "ANCHOR", text_color=colTextLt, text_size=szV, bgcolor=dbg)
    table.cell(dash, 1, 7, str.tostring(rsiAnchor, "#.#"), text_color=rsiAnchor >= midLine ? colBull : colBear, text_size=szV, bgcolor=dbg)

    table.cell(dash, 0, 8, "ZONES", text_color=colTextLt, text_size=szV, bgcolor=dbg)
    table.cell(dash, 1, 8, str.tostring(dynOs, "#") + " / " + str.tostring(dynOb, "#"),
      text_color=colPending, text_size=szV, bgcolor=dbg)

    table.cell(dash, 0, 9, "─── QUALITY ───", text_color=color.new(colNeutral, 20),
      text_size=szS, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 9, "", bgcolor=secBg)

    table.cell(dash, 0, 10, "RESONANCE", text_color=colTextLt, text_size=szV, bgcolor=dbg)
    table.cell(dash, 1, 10, str.tostring(dScore) + " / 10",
      text_color=dScore >= minResonance ? colBull : colNeutral, text_size=szV, bgcolor=dbg)

    table.cell(dash, 0, 11, "HTF BIAS", text_color=colTextLt, text_size=szV, bgcolor=dbg)
    table.cell(dash, 1, 11, htfBull ? "▲ BULL" : htfBear ? "▼ BEAR" : "— FLAT",
      text_color=htfBull ? colBull : htfBear ? colBear : colNeutral, text_size=szV, bgcolor=dbg)

    table.cell(dash, 0, 12, "CHOP", text_color=colTextLt, text_size=szV, bgcolor=dbg)
    table.cell(dash, 1, 12, str.tostring(chopIdx, "#.#"),
      text_color=chopOk ? colTextLt : colPending, text_size=szV, bgcolor=dbg)

    table.cell(dash, 0, 13, "COIL BW", text_color=colTextLt, text_size=szV, bgcolor=dbg)
    coilTxt = (inCoil ? "COMPRESSED" : "OPEN") + " · " + str.tostring(rsiBw, "#.#")
    if activePlan.valid and not na(dTp1)
        coilTxt += " | TP1 " + str.tostring(dTp1, format.mintick)
    table.cell(dash, 1, 13, coilTxt,
      text_color=inCoil ? colLattice : colTextLt, text_size=szV, bgcolor=dbg)

// ═══════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
alertcondition(bullSignal, title="RESONANCE Bullish Setup",
  message="[AlphaX RESONANCE] Bullish setup on {{ticker}} {{interval}}.")
alertcondition(bearSignal, title="RESONANCE Bearish Setup",
  message="[AlphaX RESONANCE] Bearish setup on {{ticker}} {{interval}}.")
````

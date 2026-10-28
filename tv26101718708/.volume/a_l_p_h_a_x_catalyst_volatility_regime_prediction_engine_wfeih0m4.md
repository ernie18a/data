# [ A L P H A X ] CATALYST - Volatility & Regime Prediction Engine

- url: https://www.tradingview.com/script/wfEih0m4-A-L-P-H-A-X-CATALYST-Volatility-Regime-Prediction-Engine/
- type: indicator
- pine_id: PUB;d6a9ebe6d6ed4d92937945d303b7e4e1
- version: 1.0

## Description

[b]AlphaX CATALYST — Volatility Ignition & Regime Prediction Engine: Compression Cycle Detection, Bias Vector Scoring, 6-Stage Regime State Machine & Ignition Probability Gate[/b]

AlphaX CATALYST is a professional-grade volatility prediction system built on a fundamentally different philosophy from every other indicator in the AlphaX suite. Where VOID, SURGE, FORTRESS, and ANCHOR all detect setups after price has established a structural context, CATALYST reads the market [i]before[/i] the move happens. It does not wait for a breakout to confirm entry — it measures the energy compressing inside the market during quiet periods and predicts the ignition point before the explosion occurs. The core insight is simple but profound: markets breathe in cycles. They compress, coil, and then release energy in directional bursts. CATALYST quantifies every stage of that cycle — from the first signs of volatility contraction through full coil, ignition, trending expansion, and exhaustion — and fires signals only when the compression is deep enough, the directional bias during the coil is strong enough, and the higher timeframe structure confirms the direction. The result is a system that positions you [i]at the moment of ignition[/i] — not a bar after the breakout has already occurred. Designed for volatility-aware traders across crypto, forex, gold, and indices on any timeframe.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🌬 [b]The Philosophy — Markets Breathe[/b]

Every major directional move in every liquid market is preceded by a period of compression. Price range contracts. Volume dries up. Volatility percentile falls toward historic lows. The Bollinger Bands compress inside the Keltner Channels. Narrow range bars form consecutively. This compression is not random — it is the mechanism by which institutional positions are accumulated quietly, without moving price, before the delivery move begins.

Most traders see this compression phase as boring or unreadable and look elsewhere for setups. CATALYST is built on the opposite premise: [b]the compression phase is the most important and readable phase of the entire price cycle[/b]. The depth of the compression tells you how much energy is coiling. The directional bias during the compression tells you where that energy is most likely to be released. The higher timeframe alignment tells you whether that release is likely to be with or against the macro institutional flow.

By the time the breakout candle is obvious to everyone, CATALYST has already been tracking the setup for multiple bars — measuring compression depth, monitoring accumulation bias, and computing the ignition probability score in real time. When ignition fires, it fires with advance conviction — not reactive confirmation.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙ [b]The 6-Stage Regime State Machine[/b]

CATALYST is built around a deterministic 6-stage regime cycle that every market passes through on every timeframe. Understanding the regime is the foundation of using CATALYST correctly — the dashboard, background colors, and regime flip labels all communicate exactly which stage the market is in at every bar.

[b]Stage 0 — QUIET[/b]
The market is dormant. No significant compression is building (score below 35). Volatility is neither low nor building toward a setup. This is the baseline state — the market is between cycles. Gray background tint. No actionable context.

[b]Stage 1 — BUILDING[/b]
Compression is beginning to develop (score between 35 and 75). One or more compression signals are present — the squeeze may be turning on, narrow range bars may be forming, volume may be beginning to dry. The coil is winding up. Orange background tint intensifies slightly. The bias vector label appears on the current coil box to indicate which direction accumulation is occurring.

[b]Stage 2 — COILED[/b]
Maximum compression state (score 75+, full BB/KC squeeze active). The spring is fully wound. Energy is at maximum concentration. This is the highest pre-ignition alert state. Deeper orange background tint. The coil box is rendered with higher opacity. The COILED flip label appears on the chart. Dashboard shows COMPRESS at 75%+ and SQUEEZE ON. [b]This is the state you watch most closely — ignition can occur at any bar from here.[/b]

[b]Stage 3 — IGNITION[/b]
A single-bar flash state. The regime transitions through IGNITION on the bar where all ignition conditions are simultaneously met — compression deep enough, bias directional enough, expansion candle large enough, ATR expanding. The cyan background tint and IGNITION flip label mark this bar. The IGNITE signal label fires on this bar. This is the entry bar. Immediately transitions to TRENDING on the next bar.

[b]Stage 4 — TRENDING[/b]
The expansion phase. Price is in directional delivery. The regime holds TRENDING until one of the exhaustion conditions fires: RSI reaching extreme levels with climax volume, a significant wick rejection candle in the trend direction, a squeeze reforming during the trend (stall), or a reversal candle closing through the 21 EMA. Yellow-green tint during bull expansion, red tint during bear expansion.

[b]Stage 5 — EXHAUSTION[/b]
The expansion energy is spent. One of the exhaustion conditions has triggered. Purple diamond markers appear above or below price. This is the early warning that the trend leg is ending — not necessarily the trend itself, but the current momentum leg. After EXHAUSTION, the regime resets: if compression begins building again, it cycles back to BUILDING; if not, it returns to QUIET and the cycle begins again.

[b]Why the state machine matters:[/b] Every signal in CATALYST is regime-gated. Ignition signals can only fire from the COILED state. Exhaustion warnings can only fire from the TRENDING state. This ensures signals are always contextually appropriate — you cannot get an ignition signal without prior compression, and you cannot get an exhaustion warning without a prior trend.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📉 [b]The Compression Score Engine — Measuring the Coil[/b]

The compression score is a 0–100 composite reading that quantifies exactly how tightly the market is coiling at any given bar. It is the primary input to the regime state machine and is displayed live on the dashboard.

[b]Six compression components and their weights:[/b]

[b]Squeeze State (up to 30 points):[/b]
The BB/KC squeeze is the most powerful single compression signal. When Bollinger Bands are fully inside Keltner Channels, the market is at maximum volatility contraction — 30 points. If the squeeze fired on the previous bar (just released), 15 points are still awarded, capturing the residual compression energy at the moment of release.

[b]Narrow Range Pattern — NR (up to 20 points):[/b]
The current bar's high-low range is measured against the lowest range over the lookback period (default: 7 bars). When the current bar has the narrowest range in the lookback window, 20 points are awarded. This is the NR7 pattern generalized to a configurable lookback — the classic volatility contraction signal.

[b]NR Streak (up to 15 points):[/b]
Consecutive narrow range bars amplify the coil energy. When the NR count over the minimum coil duration reaches the threshold, 15 additional points are awarded. Multiple consecutive NR bars indicate the market has been compressing for a sustained period — a deeper, more energetic coil.

[b]Volume Dry-Up (up to 15 points):[/b]
Current volume below the configurable fraction of its moving average (default: 65% of the 20-bar SMA) confirms institutional accumulation is occurring quietly — institutions are building positions without creating visible volume signals. 15 points awarded when volume is dry.

[b]Volume Dry Streak (up to 10 points):[/b]
Multiple consecutive bars of volume dry-up, identical logic to the NR streak. Sustained low volume over multiple bars is a stronger coil signal than a single dry bar.

[b]ATR Percentile Rank (up to 10 points):[/b]
The current ATR is ranked against its own history over the configurable lookback (default: 100 bars). When ATR is in the bottom 25th percentile of its historical range — meaning volatility is at a historic low for this instrument on this timeframe — 10 points are awarded. Below the 40th percentile scores 5 points. This ensures the compression is genuine historically, not just temporarily quiet in an already volatile market.

[b]Reading the score:[/b]
[list]
[*][b]0–35[/b] — QUIET, no meaningful compression building
[*][b]35–55[/b] — BUILDING, compression developing but not yet actionable
[*][b]55–74[/b] — COILING, significant compression present
[*][b]75–100[/b] — FULLY COILED, maximum compression, squeeze active. Ignition-ready state
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🧭 [b]The Bias Vector — Who Is Accumulating During the Coil?[/b]

Compression tells you the market is coiling. The Bias Vector tells you [i]which direction[/i] institutions are accumulating during that coil. A range of -100 (fully bearish) to +100 (fully bullish), the bias vector is a composite of five independent directional pressure readings — each measuring accumulation from a different angle.

[b]Volume Delta (up to ±25 points):[/b]
The estimated directional volume pressure — bull volume EMA minus bear volume EMA — forms the primary bias input. When delta is positive and rising (buyers accelerating), 25 points are added. When delta is positive but not accelerating, 10 points. The inverse applies for bear delta. This is the most direct measure of whether buyers or sellers are winning the quiet accumulation battle during compression.

[b]Close-Position Bias (up to ±20 points):[/b]
Where closes fall within each bar's high-low range, averaged over the lookback period (default: 10 bars). When the average close position is in the upper 55%+ of the range — candles are consistently closing near their highs — buyers are controlling the candle closes. ±20 points based on whether the close bias is bullish (above 0.55) or bearish (below 0.45). This is a subtle but powerful measure of who is controlling the close during the coil.

[b]Micro Structure (up to ±20 points):[/b]
Higher highs or higher lows over the structure lookback (default: 20 bars) vote bullish. Lower lows or lower highs vote bearish. ±20 points. Micro structure during compression tells you whether the coil is forming as a higher low (bullish coil) or a lower high (bearish coil) — the internal structure of the compression box reveals directional intent.

[b]HTF Bias (up to ±20 points):[/b]
The higher timeframe EMA alignment (default: 60-minute, 50-period EMA). When HTF close is above the HTF EMA — the macro trend is bullish — +20 points. When below, -20 points. When Require HTF Alignment is disabled, this component is neutral. The HTF bias ensures the coil's directional reading is contextualized against the macro institutional flow.

[b]Price vs BB Basis (up to ±15 points):[/b]
Whether the current close is above or below the BB basis (Bollinger Band midline). Price above the basis during compression means the coil is forming above fair value — a mild bullish signal. Price below the basis is mildly bearish. ±15 points. This adds a relative positioning dimension to the bias.

[b]Reading the bias vector:[/b]
[list]
[*][b]+35 to +100[/b] — bull bias. Buyers are accumulating during the coil. Long ignition is favored
[*][b]-35 to -100[/b] — bear bias. Sellers are distributing during the coil. Short ignition is favored
[*][b]-34 to +34[/b] — neutral bias. No clear directional accumulation. Ignition may fire in either direction — lower conviction
[/list]

[b]Bias Arrow:[/b]
During BUILDING and COILED regime stages, a live bias arrow label appears below (bull bias) or above (bear bias) the coil box on the current bar, showing the directional score in real time. As new bars form, the arrow updates continuously — you can watch the bias building or shifting during the coil.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔥 [b]The Ignition Score — 0 to 100 Probability Gate[/b]

Every bar in the COILED regime, CATALYST computes two separate ignition scores — one for long ignition, one for short. These scores gate whether a signal fires. Only when the score meets the configured minimum threshold (default: 62) does a signal become eligible.

[b]Long ignition score components:[/b]
[list]
[*][b]Compression depth (up to 20 points)[/b] — fully coiled scores 20, isCoiling scores 10, moderate compression scores 10
[*][b]Squeeze state (up to 20 points)[/b] — squeeze release scores 20 (maximum — the spring just released), squeeze still active scores 10
[*][b]Bias vector alignment (up to 25 points)[/b] — bias above +50 scores 25, above +35 scores 15, below 0 deducts 15
[*][b]HTF alignment (up to 15 points)[/b] — HTF bullish scores 15, disabled scores 15 (neutral)
[*][b]Expansion candle quality (up to 15 points)[/b] — strong bull body above ATR threshold scores 15, any bullish close scores 8
[*][b]ATR expansion (up to 5 points)[/b] — ATR expanding above its short-term average confirms the coil is releasing
[*][b]Volume delta confirmation (up to 10 points)[/b] — accelerating buy delta scores 10, positive delta scores 5
[/list]

The short ignition score mirrors this structure with all conditions inverted.

[b]What the score thresholds mean in practice:[/b]
[list]
[*][b]90–100[/b] — near-perfect setup. All components aligned. Extremely rare
[*][b]75–89[/b] — elite setup. Multiple high-weight components confirmed simultaneously
[*][b]62–74 (default threshold)[/b] — high-quality setup. Sufficient confirmation to fire
[*][b]50–61[/b] — moderate quality. Available if you lower the threshold, but carries more false signals
[*][b]Below 50[/b] — low-quality ignition conditions. System will not fire at any reasonable threshold setting
[/list]

The live long and short scores are displayed in real time on the dashboard as [b]IGNITE L[/b] and [b]IGNITE S[/b] — color-coded yellow-green or red when they meet the threshold, neutral otherwise. You can watch the ignition score building toward threshold in real time during the coil phase.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ [b]The Ignition Signal — IGNITE Entry[/b]

The [b]IGNITE[/b] label is CATALYST's primary entry signal. It fires when all of the following conditions are simultaneously confirmed on a bar close:

[b]Hard requirements (all must be true):[/b]
[list]
[*]Regime is in COILED state (compression score 75+, squeeze active)
[*]The expansion candle body meets or exceeds the configured minimum (default: 1.15× ATR) — the breakout candle is large and directional
[*]The bias vector is aligned with the signal direction (+35 or higher for long, -35 or lower for short)
[*]ATR is actively expanding above its short-term average — the volatility expansion has begun
[*]Squeeze has released on this bar or was releasing on the previous bar (when Require Squeeze Release is enabled)
[*]Ignition score meets the minimum threshold (default: 62)
[*]Session filter is satisfied (when enabled)
[*]Signal cooldown has elapsed since the last signal
[/list]

[b]Signal label:[/b] A large [b]IGNITE[/b] label appears below the bar (long) or above (short) on the exact ignition bar. Yellow-green for long, red for short.

[b]Why this is fundamentally different from a standard breakout signal:[/b] A standard breakout indicator fires when price closes above a resistance level or a band. It reacts to what has already happened. CATALYST fires on the ignition bar only after verifying that the preceding compression was deep enough (COILED regime), that the directional bias during the coil was confirmed (bias vector), that the breakout candle itself is sufficiently large (body ATR check), and that the volatility is genuinely expanding (ATR expansion). Every component addresses a specific failure mode of basic breakout trading — false breakouts, weak breakouts, counter-HTF breakouts, and low-compression breakouts are all filtered before the signal fires.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔮 [b]The Compression Coil Box[/b]

When the compression score crosses 55 and the BUILDING regime begins, CATALYST draws a live [b]Coil Box[/b] — an orange-tinted rectangle spanning the high-low range of the entire compression period from the first coiling bar to the current bar.

[b]What the coil box represents:[/b] The coil box is the visual representation of the spring being wound. Every bar that the coil remains active, the box extends to the right and expands to incorporate the new bar's range. The box's height represents the total price range of the compression period — the tighter this range, the more compressed the energy.

[b]Box opacity:[/b] The box becomes more opaque when the compression reaches the fully COILED state (score 75+, squeeze active). This visual intensity progression gives you an immediate sense of compression depth — a faint box means early-stage building, a deep orange box means maximum coil.

[b]Box on ignition:[/b] When ignition fires, the box remains on the chart at the coil range, giving you a clear visual reference for the compression zone that preceded the move. The coil box range is also used for structural stop loss placement — the SL Beyond Coil Box Edge setting places the stop loss beyond the coil box boundary rather than a fixed ATR distance from entry.

[b]Box cleanup:[/b] When the regime returns to QUIET (compression fully dissipated without ignition), the box is deleted. When ignition occurs, the box is retained as a reference.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Exhaustion Radar — Early Warning System[/b]

The Exhaustion Radar monitors the TRENDING regime for signs that the expansion energy is being spent. When exhaustion conditions are met, purple diamond markers appear above (bull trend exhaustion) or below (bear trend exhaustion) the bar — a warning that the current momentum leg is likely approaching its end.

[b]Exhaustion conditions (any one is sufficient):[/b]
[list]
[*][b]RSI climax with volume spike[/b] — RSI above the overbought threshold (default: 72) in a bull trend with volume exceeding the configured climax multiple (default: 2.2×). This combination of extreme RSI and high volume is the classic climax top pattern — buyers are exhausting their buying capacity simultaneously
[*][b]RSI climax with volume spike (bear)[/b] — RSI below the oversold threshold (default: 28) with climax volume in a bear trend. Sellers exhausting
[*][b]Wick rejection in trend direction[/b] — a bar with a rejection wick exceeding the configured minimum percentage (default: 55%) in the direction of the trend. A bull trend bar with a massive upper wick indicates aggressive selling into the highs — supply overwhelming demand at the extreme
[*][b]Trend stall squeeze[/b] — when a squeeze (BB inside KC) forms during the trending phase while volume is also drying up. This indicates the expansion move has stalled into a new compression without resolution — energy is being absorbed rather than continuing
[*][b]Reversal candle through 21 EMA[/b] — a strong opposing candle that closes through the 21-period EMA in the trend direction. In a bull trend, a strong bearish close through the 21 EMA indicates the trend's immediate momentum structure has been broken
[/list]

[b]How to use exhaustion signals:[/b] Exhaustion diamonds are [i]not[/i] reversal signals. They indicate that the current momentum leg is likely complete — not that the trend has ended. Use them to take partial or full profit on trend trades, tighten trailing stops, or wait for the next CATALYST compression cycle to develop before re-entering.

━━━━━━━━━━━━━━━━━════════════════════════

🎯 [b]Coil-Anchored Risk Guidance System[/b]

On every IGNITE signal, CATALYST draws forward-projecting risk guidance levels for the duration of the trade.

[b]Stop Loss (SL):[/b]
When SL Beyond Coil Box Edge is enabled (default: on), the stop is placed beyond the coil box boundary — below the coil box low (long) or above the coil box high (short) — plus a small ATR buffer. The coil box represents the full compression range: if price returns into and through the opposite side of the coil box after ignition, the breakout has failed and the setup is invalidated. This gives the stop structural meaning beyond just an ATR distance. When the coil SL is less conservative than the fixed ATR SL, the system uses whichever is further from entry to ensure adequate protection.

[b]TP1 — First Target:[/b]
2.0× ATR from the entry close (configurable). The initial partial profit target. At TP1, consider scaling out 50% of the position.

[b]TP2 — Extended Target:[/b]
4.0× ATR from entry (configurable). The full expansion target for the remaining position — allowing the trailing stop or regime-based exit (exhaustion signal) to manage the remainder.

[b]Level visualization:[/b] All three levels are drawn as horizontal dashed or dotted lines extending 12 bars forward from the signal bar, with price labels at the right edge showing exact levels. SL in red, TP1 in dim yellow-green, TP2 in bright yellow-green.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]Live Dashboard[/b]

The 14-row real-time dashboard displays every internal state of the CATALYST engine on every bar.

[list]
[*][b]REGIME[/b] — current stage: QUIET / BUILDING / COILED / IGNITION / TRENDING / EXHAUSTION. Color-coded by regime type
[*][b]COMPRESS[/b] — live compression score 0–100%. Orange when above 50%, deeper orange when above 75%
[*][b]SQUEEZE[/b] — ON (BB inside KC, maximum coil), RELEASE (squeeze just fired — highest-quality ignition condition), or OFF
[*][b]ATR RANK[/b] — current ATR percentile versus its 100-bar history. Orange when below 30th percentile (historically low volatility — coil energy building)
[*][b]VOL DRY[/b] — YES when current volume is below the dry-up threshold, NO otherwise. Orange when YES
[*][b]BIAS VECTOR[/b] — the composite directional accumulation score with + or - sign. Yellow-green above +35, red below -35, neutral otherwise
[*][b]HTF BIAS[/b] — higher timeframe EMA direction: BULL, BEAR, or FLAT
[*][b]VOL DELTA[/b] — BUYERS when bull volume dominates, SELLERS when bear volume dominates
[*][b]IGNITE L[/b] — live long ignition probability score 0–100. Highlights yellow-green when at or above the minimum threshold
[*][b]IGNITE S[/b] — live short ignition probability score 0–100. Highlights red when at or above threshold
[*][b]COIL BARS[/b] — number of bars the current coil has been active. Orange when at or above the minimum coil duration
[*][b]COIL RANGE[/b] — the high-low range of the current coil box in price terms
[*][b]SESSION[/b] — ACTIVE or FILTERED based on the session filter state
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 [b]Chart Visual System[/b]

[list]
[*][b]Compression Coil Box (orange)[/b] — live orange-tinted box spanning the full high-low range of the current compression period. Brightens on full coil. The core visual centerpiece of CATALYST
[*][b]Regime Background Tints[/b] — subtle full-bar background colors for each regime: gray (QUIET), light orange (BUILDING), deeper orange (COILED), cyan (IGNITION), yellow-green or red (TRENDING), purple (EXHAUSTION)
[*][b]IGNITE Label (below bar, yellow-green)[/b] — bull ignition signal. All conditions confirmed
[*][b]IGNITE Label (above bar, red)[/b] — bear ignition signal
[*][b]◆ Exhaustion Diamond (above bar, purple)[/b] — bull trend exhaustion warning
[*][b]◆ Exhaustion Diamond (below bar, purple)[/b] — bear trend exhaustion warning
[*][b]Bias Vector Arrow Label[/b] — appears near the coil box on the current bar during BUILDING and COILED phases, showing ▲ BIAS +xx or ▼ BIAS -xx in real time
[*][b]Regime Flip Labels[/b] — small text labels marking every regime transition: BUILDING, COILED, IGNITION, TRENDING, EXHAUSTION. Color-coded by regime
[*][b]SL Dashed Line (red)[/b] — stop loss guide extending 12 bars from ignition bar
[*][b]TP1 Dotted Line (dim yellow-green)[/b] — first take-profit guide
[*][b]TP2 Dotted Line (bright yellow-green)[/b] — extended take-profit guide
[*][b]SL / TP1 / TP2 Price Labels[/b] — exact price levels labeled at the right end of each guide line
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 [b]How to Trade with AlphaX CATALYST — Step by Step[/b]

[b]Step 1 — Monitor the Regime[/b]
[list]
[*]Check the dashboard REGIME row. If it shows QUIET, nothing actionable is developing. If it shows BUILDING, a compression cycle is beginning — start paying attention
[*]Watch COMPRESS build toward 75+. When SQUEEZE shows ON simultaneously, the market is in maximum coil state. This is your highest-alert pre-signal phase
[*]Note the Coil Box forming and narrowing on the chart. The tighter the box, the more energy compressed inside
[/list]

[b]Step 2 — Assess the Bias During the Coil[/b]
[list]
[*]Watch the Bias Arrow label near the coil box. Is it showing ▲ BIAS or ▼ BIAS? A strong positive bias (+50 or above) during a tight coil is the strongest possible pre-ignition setup
[*]Check HTF BIAS on the dashboard — does it confirm the bias arrow direction? HTF alignment is worth 15 ignition score points and significantly increases the probability of a clean directional ignition
[*]Watch VOL DELTA — are BUYERS or SELLERS winning the accumulation battle during the quiet phase?
[*]If the Bias Vector is below ±35, the coil does not have strong directional conviction. Lower your size expectations or wait for bias to build
[/list]

[b]Step 3 — Watch the Ignition Scores Approach Threshold[/b]
[list]
[*]As the coil deepens, watch IGNITE L and IGNITE S scores on the dashboard climbing toward the minimum threshold. When a score crosses the threshold and highlights, the system is primed — ignition can fire on the next qualifying expansion bar
[*]The squeeze release (SQUEEZE shows RELEASE) is the most important single event in the ignition sequence. When the squeeze releases on a strong expansion candle in the bias direction, ignition fires immediately if the score is sufficient
[/list]

[b]Step 4 — Enter on the IGNITE Label[/b]
[list]
[*]The IGNITE label marks the exact ignition bar. Enter on the close of the signal bar or the open of the following bar
[*]The SL is placed beyond the coil box edge — below the coil low (long) or above the coil high (short). This is your structural invalidation: if price re-enters and closes through the opposite side of the coil box, the breakout has failed
[*]TP1 at 2.0× ATR — scale out 50% here. Move the remainder to breakeven
[*]Let TP2 or the first exhaustion diamond manage the remaining position
[/list]

[b]Step 5 — Exit on Exhaustion or Regime Shift[/b]
[list]
[*]A purple diamond marks the exhaustion condition. Take profit on the remaining position or tighten the stop aggressively
[*]The dashboard shows EXHAUSTION regime — the trend energy has been identified as spent
[*]If no exhaustion fires and price continues, the system will track the regime as TRENDING — let the move run until exhaustion appears
[*]After EXHAUSTION, the regime resets. Watch for a new compression cycle to build in the updated directional context
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Identifying Low-Quality Conditions — When Not to Trade[/b]

[b]Stand aside when:[/b]
[list]
[*][b]Regime is QUIET and COMPRESS is below 35[/b] — no cycle is developing. CATALYST has nothing actionable and no signal can fire. Do not force entries
[*][b]Regime reaches COILED but Bias Vector is below ±35[/b] — the coil is real but the directional accumulation is inconclusive. Ignition in this environment carries reduced directional probability. Reduce size significantly or wait for bias to develop clarity
[*][b]HTF BIAS opposes the bias vector direction[/b] — a bearish HTF while the bias vector is bullish means the coil is building against the macro institutional flow. Counter-HTF ignitions have a significantly lower success rate. Wait for HTF alignment
[*][b]IGNITE L and IGNITE S scores are both below threshold[/b] — the market is compressing but neither a long nor short setup has sufficient confirmation quality. No signal will fire. Wait for the scores to build
[*][b]Multiple regime cycles in rapid succession without trending[/b] — BUILDING → COILED → QUIET → BUILDING cycles that never reach IGNITION indicate a market in deep chop or accumulation. Do not try to anticipate the breakout direction — wait for the cycle to complete cleanly
[*][b]Session shows FILTERED[/b] — the session filter has blocked the current time window. No signals will fire
[*][b]COIL BARS is below the minimum coil duration[/b] — the compression has been too brief to build meaningful energy. A coil of 2 bars has far less stored energy than a coil of 8+ bars. Prioritize setups with longer coil durations
[/list]

[b]The ideal CATALYST setup:[/b]
[list]
[*]COMPRESS at 80+, SQUEEZE ON for multiple bars
[*]Bias Vector at +50 or above (long) or -50 or below (short)
[*]HTF BIAS aligned with the bias direction
[*]VOL DELTA confirming the bias direction (BUYERS for long, SELLERS for short)
[*]IGNITE L or S score approaching 75+
[*]COIL BARS at 5 or more — sustained compression
[*]Squeeze RELEASE on the ignition bar — the spring snapping
[*]Strong body expansion candle in the bias direction
[/list]

When all these conditions align, CATALYST produces its highest-conviction ignition signals — setups where the compression depth, directional accumulation, HTF alignment, volume pressure, and expansion quality are all confirming simultaneously.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ [b]Key Features[/b]
[list]
[*]🌬 6-stage regime state machine — QUIET → BUILDING → COILED → IGNITION → TRENDING → EXHAUSTION. Every bar is classified and every signal is regime-gated
[*]📉 Multi-component compression score — BB/KC squeeze, NR patterns, NR streaks, volume dry-up, volume dry streaks, and ATR percentile rank combined into a single 0–100 score
[*]📦 Live compression coil box — orange-tinted box tracking the full range of the compression period in real time, brightening at maximum coil depth
[*]🧭 5-component bias vector — Volume Delta, Close-Position Bias, Micro Structure, HTF EMA alignment, and BB Basis positioning combined into a -100 to +100 directional accumulation score
[*]⚡ Live bias arrow label — directional score displayed near the coil box on the current bar, updating in real time during BUILDING and COILED phases
[*]🔥 Dual ignition probability scores — separate 0–100 long and short scores computed every bar with a configurable minimum threshold gate
[*]💥 IGNITE signal — fires only from COILED state on the exact bar where compression, bias, expansion candle, and ATR all confirm simultaneously
[*]⚠ Exhaustion radar — RSI climax volume, rejection wick, trend stall squeeze, and reversal candle conditions produce early exhaustion warnings during the TRENDING phase
[*]📡 HTF EMA bias filter — pulls higher timeframe directional structure into both the bias vector and the ignition scoring system
[*]🎯 Coil-anchored SL placement — stop loss placed beyond the compression box structural boundary rather than a fixed ATR distance
[*]🎨 Regime background tints — full-bar background colors for every regime stage, providing constant visual awareness of where the market is in the cycle
[*]🏷 Regime flip labels — small text labels at every regime transition point on the chart history
[*]📊 14-row live dashboard — Regime, Compress, Squeeze, ATR Rank, Vol Dry, Bias Vector, HTF Bias, Vol Delta, Ignition Scores, Coil Bars, Coil Range, Session updated every bar
[*]🔔 5 alert conditions — Ignite Long, Ignite Short, Fully Coiled, Squeeze Release, Exhaustion Warning
[*]⚙ Fully configurable — all ATR/BB/KC parameters, NR lookback, volume dry-up threshold, ATR percentile length, HTF timeframe and EMA, delta and structure lookbacks, ignition threshold, body size filter, exhaustion RSI/volume/wick parameters, SL/TP multiples, session windows, and all colors are independently adjustable
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙ [b]Settings Reference[/b]

[b]Volatility Engine[/b]
[list]
[*]ATR Length — ATR calculation lookback used across the engine (default: 14)
[*]BB Length / BB Mult — Bollinger Band parameters for squeeze detection (defaults: 20 / 2.0)
[*]KC Length / KC Mult — Keltner Channel parameters (defaults: 20 / 1.5)
[*]NR Pattern Lookback — bars for narrow range comparison. NR fires when current range is the narrowest in this window (default: 7)
[*]Volume Dry-Up Length — lookback for volume moving average (default: 20)
[*]Max Vol vs Avg (coil) — maximum volume as a fraction of average for the dry-up condition (default: 0.65)
[*]ATR Percentile Lookback — history window for ATR percentile rank (default: 100)
[*]Min Coil Duration (bars) — minimum consecutive bars needed for streak bonuses (default: 3)
[/list]

[b]Bias Vector[/b]
[list]
[*]HTF Bias Timeframe — higher timeframe for EMA bias pull (default: 60-minute)
[*]HTF EMA Length — EMA period on the higher timeframe (default: 50)
[*]Require HTF Alignment — when on, HTF opposing direction deducts points from ignition scores
[*]Volume Delta Length — EMA smoothing for volume delta estimation (default: 14)
[*]Close-Position Bias Len — lookback for average close position within bar range (default: 10)
[*]Structure Lookback — bars for micro higher high / lower low detection (default: 20)
[/list]

[b]Ignition Signals[/b]
[list]
[*]Min Ignition Score (0–100) — threshold below which no signal fires (default: 62). 58–68 is practical range
[*]Min Ignition Body (xATR) — expansion candle body must exceed this multiple of ATR (default: 1.15)
[*]Require Squeeze Release — when on, ignition must occur on or after BB/KC squeeze releases
[*]Show Ignition BUY/SELL Labels — toggle IGNITE signal labels
[*]Show Exhaustion Warnings — toggle exhaustion diamond markers
[*]Signal Cooldown (bars) — minimum bars between consecutive signals (default: 6)
[/list]

[b]Exhaustion Radar[/b]
[list]
[*]RSI Overbought / Oversold — RSI thresholds for climax exhaustion detection (defaults: 72 / 28)
[*]Climax Volume (x avg) — volume multiple above average required for RSI climax condition (default: 2.2)
[*]Min Rejection Wick % — minimum wick as fraction of bar range for wick rejection exhaustion (default: 0.55)
[/list]

[b]Risk Guidance[/b]
[list]
[*]Show SL / TP Guides on Signal — toggle level lines and labels
[*]SL Distance (xATR) — ATR-based SL floor distance (default: 1.2)
[*]TP1 Distance (xATR) — first take-profit target distance (default: 2.0)
[*]TP2 Distance (xATR) — extended take-profit target distance (default: 4.0)
[*]SL Beyond Coil Box Edge — places SL at the structural coil boundary rather than fixed ATR only (default: on)
[/list]

[b]Session Filter[/b]
[list]
[*]Enable Session Filter — toggle the session restriction
[*]London (08:00–13:00 UTC) — toggle London session inclusion
[*]London/NY Overlap (13:00–17:00 UTC) — toggle the highest-volume overlap session
[*]NY Afternoon (17:00–21:00 UTC) — toggle NY afternoon session
[/list]

[b]Display[/b]
[list]
[*]Show Compression Coil Box — toggle the live orange coil box
[*]Regime Background Tint — toggle the full-bar regime background colors
[*]Show Bias Vector Arrow — toggle the live bias label near the coil box
[*]Dashboard Position — Top Right / Top Left / Top Center / Bottom Right / Bottom Left / Bottom Center
[*]Dashboard Size — Normal / Bigger
[/list]

[b]Theme[/b]
[list]
[*]Bull Primary / Bright / Dim — yellow-green family for all bullish elements
[*]Bear Primary / Bright / Dim — red family for all bearish elements
[*]Coil / Squeeze — orange for all compression and coil elements
[*]Ignition — cyan for the ignition regime flash
[*]Exhaustion — purple for exhaustion regime and warning diamonds
[*]Neutral — gray for QUIET regime and neutral states
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔔 [b]Alert Conditions (5 total)[/b]

[b]Signal Alerts[/b]
[list]
[*]CATALYST Ignite Long — all long ignition conditions confirmed. IGNITE label fired below bar
[*]CATALYST Ignite Short — all short ignition conditions confirmed. IGNITE label fired above bar
[/list]

[b]State Alerts[/b]
[list]
[*]CATALYST Fully Coiled — regime has entered COILED state (compression 75+, squeeze active). Ignition may be imminent — prepare
[*]CATALYST Squeeze Release — BB has expanded outside KC on this bar. Maximum-quality ignition condition active
[*]CATALYST Exhaustion — exhaustion conditions detected in the TRENDING regime. Trend energy fading
[/list]

All alert messages are formatted as const strings for clean webhook and notification platform integration.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 [b]Recommended Settings by Instrument & Timeframe[/b]

The default configuration is optimized for [b]XAUUSD, major forex pairs, and crypto on M5–H1[/b]:
[list]
[*]Min Ignition Score at 62 — strong quality gate while allowing frequent enough signals on intraday timeframes
[*]HTF at 60-minute — meaningful macro context for M5–M15 trading. The squeeze and ignition on M5 confirmed by H1 EMA alignment is the core multi-timeframe framework
[*]ATR Percentile Lookback at 100 — calibrated for intraday volatility cycles on liquid instruments
[*]NR Lookback at 7 — captures classic NR7 patterns while remaining sensitive enough for fast-moving instruments
[/list]

For other instruments or timeframes, adjust:
[list]
[*][b]M1–M3 scalping[/b] — reduce ATR Percentile Lookback to 50, reduce NR Lookback to 5, reduce Min Ignition Score to 58, shorten Cooldown to 3 bars
[*][b]H1–H4 swing trading[/b] — set HTF to Daily or Weekly, increase ATR Percentile Lookback to 200–250, increase Min Ignition Score to 68–72, increase TP2 to 6.0–8.0× ATR for wider swing targets
[*][b]Crypto (BTC, ETH)[/b] — increase KC Mult to 2.0–2.5 and BB Mult to 2.5 to account for wider natural volatility, increase Climax Volume threshold to 2.8–3.5 for crypto's naturally higher volume spikes
[*][b]Higher signal frequency[/b] — lower Min Ignition Score to 55–58, reduce NR Lookback to 5, reduce Min Coil Duration to 2
[*][b]Ultra-selective signals only[/b] — raise Min Ignition Score to 72–78, require Squeeze Release on, HTF Alignment on, increase Min Coil Duration to 5
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👥 [b]Who This Is For[/b]
[list]
[*]💥 [b]Volatility breakout and expansion traders[/b] — CATALYST is purpose-built for traders who want to enter at the moment of volatility ignition, not after the move has already extended significantly
[*]⚡ [b]Squeeze traders and NR pattern traders[/b] — the compression engine formalizes and quantifies every squeeze and narrow range pattern into a single score, eliminating subjective judgment about whether a coil is "tight enough"
[*]🔮 [b]Anticipatory traders who want to read the market before it moves[/b] — the bias vector and ignition score system provides pre-signal intelligence during the coil that no reactive indicator can match
[*]📊 [b]Multi-timeframe traders[/b] — the HTF bias integration means every CATALYST signal is contextualized against the higher timeframe institutional flow
[*]🧠 [b]Systematic traders[/b] — every component of the compression score, bias vector, and ignition score is quantified and configurable. There is no subjectivity in what constitutes a "good enough" coil
[*]🎯 [b]Risk-conscious traders[/b] — the coil-anchored stop loss is structurally meaningful — placed at the exact level that invalidates the breakout thesis
[*]📈 [b]Traders across all asset classes[/b] — the ATR normalization and percentile-ranked volatility detection means CATALYST works consistently on gold, forex, crypto, and indices without manual recalibration between instruments
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 [b]Notes[/b]
[list]
[*]All signals are confirmed on bar close — the indicator is non-repainting by design. Regime state, compression score, bias vector, and ignition scores all finalize on confirmed bars
[*]The regime state machine is sequential — IGNITION can only be reached from COILED. This means no signal can fire without prior confirmed compression regardless of how strong the expansion candle is
[*]The ATR percentile rank requires the configured lookback history to be available. On charts with fewer bars than the ATR Percentile Lookback setting, the rank may underperform until sufficient history accumulates. This warm-up effect resolves naturally
[*]The bias arrow label is drawn only on the last bar and refreshes on every tick during live trading. It does not appear on historical bars — only the current bar during BUILDING and COILED regimes
[*]The SL / TP guide lines are redrawn on every new ignition signal. Previous signal levels are deleted when a new signal fires
[*]Maximum 500 labels, 500 lines, and 100 boxes are rendered. The coil box, regime flip labels, and SL/TP levels all count toward these limits. On very active charts with long history, the oldest labels may be removed by TradingView's rendering limits
[*]The session filter uses UTC hours rather than exchange-specific sessions, making it instrument-agnostic across all markets globally
[*]The indicator does not track open positions or P&L — the regime state tracks the expansion direction (bull or bear) from ignition through exhaustion, but does not connect to any broker or account
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Disclaimer[/b]

This indicator is a technical analysis and visualization tool intended for educational and informational purposes only. It does not constitute financial advice or a recommendation to buy or sell any financial instrument. All signals are generated from historical and real-time price data using mathematical calculations — their accuracy or profitability is not guaranteed. Past performance of any signal type does not guarantee future results. Always conduct your own analysis, use proper risk management, and consult a licensed financial advisor before making any trading decisions. The author accepts no responsibility for any losses incurred from the use of this indicator.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[i]Built for traders who understand that the most powerful moment to enter a market is not when everyone can see the move — it is the bar before, when the coil finally snaps.[/i]

## Source Code

````pine
// © AlphaX
//@version=6
// ════════════════════════════════════════════════════════════════════════════════════════════════
//  [ A L P H A X ]  C A T A L Y S T  —  Volatility Ignition & Regime Prediction Engine
// ────────────────────────────────────────────────────────────────────────────────────────────────
//  Philosophy: Markets breathe — compress, then explode. CATALYST reads the coil BEFORE the snap.
//  - Regime cycle      : QUIET → BUILDING → COILED → IGNITION → TRENDING → EXHAUSTION
//  - Compression box   : visualizes the spring being wound (squeeze + range contraction + vol dry-up)
//  - Bias vector       : who is accumulating during the coil (delta, close position, HTF structure)
//  - Ignition score    : 0–100 probability gate — only fires when coil + bias + HTF align
//  - Exhaustion radar  : early warning when expansion energy is spent (reversal / fade context)
// ════════════════════════════════════════════════════════════════════════════════════════════════
indicator("[ A L P H A X ] CATALYST - Volatility & Regime Prediction Engine", shorttitle="[ A L P H A X ] CATALYST",
  overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=100, max_bars_back=500)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  INPUTS — VOLATILITY ENGINE
// ════════════════════════════════════════════════════════════════════════════════════════════════
atrLen        = input.int(14,  "ATR Length",              minval=2, maxval=100, group="Volatility Engine")
bbLen         = input.int(20,  "BB Length",               minval=5, maxval=100, group="Volatility Engine")
bbMult        = input.float(2.0, "BB Mult",                minval=1.0, maxval=4.0, step=0.1, group="Volatility Engine")
kcLen         = input.int(20,  "KC Length",               minval=5, maxval=100, group="Volatility Engine")
kcMult        = input.float(1.5, "KC Mult",                minval=1.0, maxval=4.0, step=0.1, group="Volatility Engine")
nrLookback    = input.int(7,   "NR Pattern Lookback",     minval=4, maxval=14, group="Volatility Engine",
  tooltip="Detects Narrow Range bars (coiling). NR7 = narrowest range in N bars.")
volDryLen     = input.int(20,  "Volume Dry-Up Length",    minval=5, maxval=100, group="Volatility Engine")
volDryPct     = input.float(0.65, "Max Vol vs Avg (coil)", minval=0.3, maxval=1.0, step=0.05, group="Volatility Engine",
  tooltip="Volume must be below this fraction of its moving average to count as 'dry'.")
atrPctLen     = input.int(100, "ATR Percentile Lookback", minval=20, maxval=500, group="Volatility Engine")
coilMinBars   = input.int(3,   "Min Coil Duration (bars)", minval=2, maxval=30, group="Volatility Engine")

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  INPUTS — BIAS VECTOR (accumulation during compression)
// ════════════════════════════════════════════════════════════════════════════════════════════════
htfRes        = input.timeframe("60", "HTF Bias Timeframe", group="Bias Vector")
htfEmaLen     = input.int(50,  "HTF EMA Length",          minval=5, maxval=400, group="Bias Vector")
useHtfBias    = input.bool(true, "Require HTF Alignment",  group="Bias Vector")
deltaLen      = input.int(14,  "Volume Delta Length",     minval=3, maxval=50, group="Bias Vector")
closeBiasLen  = input.int(10,  "Close-Position Bias Len", minval=3, maxval=50, group="Bias Vector",
  tooltip="Where closes sit within the bar range over N bars — proxy for buyer/seller control.")
structLen     = input.int(20,  "Structure Lookback",      minval=5, maxval=100, group="Bias Vector",
  tooltip="Higher highs/lows vs lower highs/lows for micro-structure bias.")

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  INPUTS — IGNITION & SIGNALS
// ════════════════════════════════════════════════════════════════════════════════════════════════
minIgniteScore = input.float(62.0, "Min Ignition Score (0–100)", minval=40, maxval=95, step=1, group="Ignition Signals",
  tooltip="Higher = fewer but higher-quality breakout entries. 58–68 is a practical range.")
igniteBodyAtr  = input.float(1.15, "Min Ignition Body (xATR)", minval=0.5, maxval=3.0, step=0.05, group="Ignition Signals",
  tooltip="Expansion candle body must exceed this × ATR to confirm ignition.")
requireSqzRelease = input.bool(true, "Require Squeeze Release", group="Ignition Signals",
  tooltip="Ignition must occur on or immediately after BB/KC squeeze releases.")
showIgnition   = input.bool(true, "Show Ignition BUY/SELL Labels", group="Ignition Signals")
showExhaust    = input.bool(true, "Show Exhaustion Warnings", group="Ignition Signals")
cooldownBars   = input.int(6, "Signal Cooldown (bars)", minval=1, maxval=50, group="Ignition Signals")

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  INPUTS — EXHAUSTION RADAR
// ════════════════════════════════════════════════════════════════════════════════════════════════
exhaustRsiHi  = input.float(72.0, "RSI Overbought", minval=60, maxval=90, group="Exhaustion Radar")
exhaustRsiLo  = input.float(28.0, "RSI Oversold",   minval=10, maxval=40, group="Exhaustion Radar")
exhaustVolSpike = input.float(2.2, "Climax Volume (x avg)", minval=1.2, maxval=5.0, step=0.1, group="Exhaustion Radar")
wickRejectPct = input.float(0.55, "Min Rejection Wick %", minval=0.3, maxval=0.9, step=0.05, group="Exhaustion Radar")

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  INPUTS — RISK GUIDANCE
// ════════════════════════════════════════════════════════════════════════════════════════════════
showLevels    = input.bool(true, "Show SL / TP Guides on Signal", group="Risk Guidance")
slAtrMult     = input.float(1.2, "SL Distance (xATR)", minval=0.3, maxval=5.0, step=0.1, group="Risk Guidance")
tp1AtrMult    = input.float(2.0, "TP1 Distance (xATR)", minval=0.5, maxval=10, step=0.1, group="Risk Guidance")
tp2AtrMult    = input.float(4.0, "TP2 Distance (xATR)", minval=1.0, maxval=20, step=0.1, group="Risk Guidance")
slBeyondCoil  = input.bool(true, "SL Beyond Coil Box Edge", group="Risk Guidance",
  tooltip="Places stop beyond the compression box instead of fixed ATR only.")

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  INPUTS — SESSION
// ════════════════════════════════════════════════════════════════════════════════════════════════
useSession    = input.bool(false, "Enable Session Filter", group="Session Filter")
trLondon      = input.bool(true,  "London (08:00–13:00 UTC)", group="Session Filter")
trOverlap     = input.bool(true,  "London/NY Overlap (13:00–17:00 UTC)", group="Session Filter")
trNyPm        = input.bool(true,  "NY Afternoon (17:00–21:00 UTC)", group="Session Filter")

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  INPUTS — DISPLAY
// ════════════════════════════════════════════════════════════════════════════════════════════════
showCoilBox   = input.bool(true, "Show Compression Coil Box", group="Display")
showRegimeBg  = input.bool(true, "Regime Background Tint", group="Display")
showBiasArrow = input.bool(true, "Show Bias Vector Arrow", group="Display")
dashPos       = input.string("Top Right", "Dashboard Position",
  options=["Top Right","Top Left","Top Center","Bottom Right","Bottom Left","Bottom Center"], group="Display")
dashSize      = input.string("Normal", "Dashboard Size", options=["Normal","Bigger"], group="Display")

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  THEME
// ════════════════════════════════════════════════════════════════════════════════════════════════
color BULL_PRIMARY = input.color(#c8e624, "Bull Primary",  group="Theme")
color BULL_BRIGHT  = input.color(#d4f03a, "Bull Bright",   group="Theme")
color BULL_DIM     = input.color(#9ab81c, "Bull Dim",      group="Theme")
color BEAR_PRIMARY = input.color(#ff1744, "Bear Primary",  group="Theme")
color BEAR_BRIGHT  = input.color(#ff5252, "Bear Bright",   group="Theme")
color BEAR_DIM     = input.color(#d50032, "Bear Dim",      group="Theme")
color COIL_CLR     = input.color(#ff9800, "Coil / Squeeze", group="Theme")
color IGNITE_CLR   = input.color(#00e5ff, "Ignition",      group="Theme")
color EXHAUST_CLR  = input.color(#8b6fd0, "Exhaustion",    group="Theme")
color NEUTRAL_CLR  = input.color(#555555, "Neutral",       group="Theme")

color HEADER_CLR   = #d1d5db
color HEADER_BG    = #0f0f0f
color BORDER_CLR   = #1a1a1a
color FRAME_CLR    = #242424

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  CORE CALCULATIONS
// ════════════════════════════════════════════════════════════════════════════════════════════════
atr    = ta.atr(atrLen)
rsi    = ta.rsi(close, 14)
volMa  = ta.sma(volume, volDryLen)

// ── Squeeze (BB inside KC) ─────────────────────────────────────────────────────────────────────
bbBasis = ta.sma(close, bbLen)
bbDev   = bbMult * ta.stdev(close, bbLen)
bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev
kcBasis = ta.ema(close, kcLen)
kcRange = ta.atr(kcLen)
kcUpper = kcBasis + kcMult * kcRange
kcLower = kcBasis - kcMult * kcRange
sqzOn   = bbUpper < kcUpper and bbLower > kcLower
sqzRelease = sqzOn[1] and not sqzOn

// ── Range contraction (NR pattern) ─────────────────────────────────────────────────────────────
barRange = high - low
isNR     = barRange <= ta.lowest(barRange, nrLookback)
nrCount  = int(math.sum(isNR ? 1.0 : 0.0, coilMinBars))

// ── Volatility percentile ──────────────────────────────────────────────────────────────────────
atrPctRank = ta.percentrank(atr, atrPctLen)
volDry     = volume < volMa * volDryPct
volDryStreak = int(math.sum(volDry ? 1.0 : 0.0, coilMinBars))

// ── Compression score (0–100 internal) ───────────────────────────────────────────────────────
float compressScore = 0.0
compressScore += sqzOn ? 30.0 : sqzOn[1] ? 15.0 : 0.0
compressScore += isNR ? 20.0 : 0.0
compressScore += nrCount >= coilMinBars - 1 ? 15.0 : 0.0
compressScore += volDry ? 15.0 : 0.0
compressScore += volDryStreak >= coilMinBars - 1 ? 10.0 : 0.0
compressScore += atrPctRank < 25 ? 10.0 : atrPctRank < 40 ? 5.0 : 0.0
compressScore := math.min(100.0, compressScore)

bool isCoiling   = compressScore >= 55
bool isFullyCoiled = compressScore >= 75 and sqzOn

// ── HTF bias ─────────────────────────────────────────────────────────────────────────────────
htfEma  = request.security(syminfo.tickerid, htfRes, ta.ema(close, htfEmaLen), lookahead=barmerge.lookahead_off)
htfClose = request.security(syminfo.tickerid, htfRes, close, lookahead=barmerge.lookahead_off)
htfBull = htfClose > htfEma
htfBear = htfClose < htfEma

// ── Volume delta (candle-range weighted) ─────────────────────────────────────────────────────
rng = math.max(high - low, syminfo.mintick)
bullVolEst = rng != 0 ? volume * (close - low) / rng : volume * 0.5
bearVolEst = volume - bullVolEst
volDelta   = ta.ema(bullVolEst, deltaLen) - ta.ema(bearVolEst, deltaLen)
deltaBull  = volDelta > 0 and volDelta > volDelta[1]
deltaBear  = volDelta < 0 and volDelta < volDelta[1]

// ── Close-position bias (where closes accumulate in range) ───────────────────────────────────
closePos = rng != 0 ? (close - low) / rng : 0.5
closeBias = ta.ema(closePos, closeBiasLen)
biasBullAccum = closeBias > 0.55
biasBearAccum = closeBias < 0.45

// ── Micro structure ──────────────────────────────────────────────────────────────────────────
hh = high > ta.highest(high[1], structLen)
hl = low  > ta.lowest(low[1], structLen)
ll = low  < ta.lowest(low[1], structLen)
lh = high < ta.highest(high[1], structLen)
structBull = hh or hl
structBear = ll or lh

// ── Bias vector composite (-100 bear … +100 bull) ────────────────────────────────────────────
float biasVector = 0.0
biasVector += deltaBull ? 25.0 : deltaBear ? -25.0 : volDelta > 0 ? 10.0 : volDelta < 0 ? -10.0 : 0.0
biasVector += biasBullAccum ? 20.0 : biasBearAccum ? -20.0 : 0.0
biasVector += structBull ? 20.0 : structBear ? -20.0 : 0.0
biasVector += (not useHtfBias or htfBull) ? 20.0 : (not useHtfBias or htfBear) ? -20.0 : 0.0
biasVector += close > bbBasis ? 15.0 : close < bbBasis ? -15.0 : 0.0
biasVector := math.max(-100.0, math.min(100.0, biasVector))

bool biasLong  = biasVector >= 35
bool biasShort = biasVector <= -35

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  REGIME STATE MACHINE
//  0=QUIET  1=BUILDING  2=COILED  3=IGNITION  4=TRENDING  5=EXHAUSTION
// ════════════════════════════════════════════════════════════════════════════════════════════════
var int   regime      = 0
var int   coilStart   = na
var float coilHigh    = na
var float coilLow     = na
var int   coilBarCount = 0
var int   trendDir    = 0   // 1 bull expansion, -1 bear expansion
var box   coilBox     = na

// Expansion detection
bodySize   = math.abs(close - open)
strongBull = close > open and bodySize >= igniteBodyAtr * atr
strongBear = close < open and bodySize >= igniteBodyAtr * atr
atrExpand  = atr > atr[1] and atr > ta.sma(atr, 5)

// Coil box tracking
if isCoiling and not isCoiling[1]
    if not na(coilBox)
        box.delete(coilBox)
        coilBox := na
    coilStart := bar_index
    coilHigh  := high
    coilLow   := low
    coilBarCount := 1
else if isCoiling
    coilHigh  := math.max(nz(coilHigh, high), high)
    coilLow   := math.min(nz(coilLow, low), low)
    coilBarCount += 1
else if not isCoiling and isCoiling[1]
    coilBarCount := 0

// Regime transitions
int prevRegime = regime
bool igniteLongEvt  = false
bool igniteShortEvt = false
if regime == 0  // QUIET
    if compressScore >= 35
        regime := 1
else if regime == 1  // BUILDING
    if isFullyCoiled
        regime := 2
    else if compressScore < 20
        regime := 0
else if regime == 2  // COILED
    bool igniteLong  = (strongBull or (sqzRelease and close > open)) and biasLong  and (not requireSqzRelease or sqzRelease or sqzOn[1])
    bool igniteShort = (strongBear or (sqzRelease and close < open)) and biasShort and (not requireSqzRelease or sqzRelease or sqzOn[1])
    if igniteLong and atrExpand
        regime := 3
        trendDir := 1
        igniteLongEvt := true
    else if igniteShort and atrExpand
        regime := 3
        trendDir := -1
        igniteShortEvt := true
    else if not isCoiling and compressScore < 30
        regime := 0
        trendDir := 0
else if regime == 3  // IGNITION (single bar flash)
    regime := 4
else if regime == 4  // TRENDING
    bool stallSqz = sqzOn and volDry
    bool rsiExhaustBull = trendDir == 1 and rsi >= exhaustRsiHi and volume > volMa * exhaustVolSpike
    bool rsiExhaustBear = trendDir == -1 and rsi <= exhaustRsiLo and volume > volMa * exhaustVolSpike
    float upperWick = high - math.max(open, close)
    float lowerWick = math.min(open, close) - low
    bool wickRejectBull = trendDir == 1 and upperWick / rng > wickRejectPct
    bool wickRejectBear = trendDir == -1 and lowerWick / rng > wickRejectPct
    if (rsiExhaustBull and wickRejectBull) or (rsiExhaustBear and wickRejectBear) or stallSqz
        regime := 5
    else if trendDir == 1 and strongBear and close < ta.ema(close, 21)
        regime := 5
    else if trendDir == -1 and strongBull and close > ta.ema(close, 21)
        regime := 5
else if regime == 5  // EXHAUSTION
    if compressScore >= 35
        regime := 1
    else
        regime := 0
        trendDir := 0

regimeChange = regime != prevRegime

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  IGNITION SCORE (0–100)
// ════════════════════════════════════════════════════════════════════════════════════════════════
calcIgniteLong() =>
    float s = 0.0
    s += isFullyCoiled or isCoiling ? 20.0 : compressScore >= 40 ? 10.0 : 0.0
    s += sqzRelease ? 20.0 : sqzOn[1] ? 10.0 : 0.0
    s += biasVector >= 50 ? 25.0 : biasVector >= 35 ? 15.0 : 0.0
    s += (not useHtfBias or htfBull) ? 15.0 : 0.0
    s += strongBull ? 15.0 : close > open ? 8.0 : 0.0
    s += atrExpand ? 5.0 : 0.0
    s += deltaBull ? 10.0 : volDelta > 0 ? 5.0 : 0.0
    s -= biasVector < 0 ? 15.0 : 0.0
    math.max(0.0, math.min(100.0, s))

calcIgniteShort() =>
    float s = 0.0
    s += isFullyCoiled or isCoiling ? 20.0 : compressScore >= 40 ? 10.0 : 0.0
    s += sqzRelease ? 20.0 : sqzOn[1] ? 10.0 : 0.0
    s += biasVector <= -50 ? 25.0 : biasVector <= -35 ? 15.0 : 0.0
    s += (not useHtfBias or htfBear) ? 15.0 : 0.0
    s += strongBear ? 15.0 : close < open ? 8.0 : 0.0
    s += atrExpand ? 5.0 : 0.0
    s += deltaBear ? 10.0 : volDelta < 0 ? 5.0 : 0.0
    s -= biasVector > 0 ? 15.0 : 0.0
    math.max(0.0, math.min(100.0, s))

igniteLongScore  = calcIgniteLong()
igniteShortScore = calcIgniteShort()

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  SESSION FILTER
// ════════════════════════════════════════════════════════════════════════════════════════════════
hUtc = hour(time, "UTC")
sLondon  = hUtc >= 8  and hUtc < 13
sOverlap = hUtc >= 13 and hUtc < 17
sNyPm    = hUtc >= 17 and hUtc < 21
sessionOk = not useSession or (sLondon and trLondon) or (sOverlap and trOverlap) or (sNyPm and trNyPm)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  SIGNALS
// ════════════════════════════════════════════════════════════════════════════════════════════════
var int lastSigBar = na
bool cooled = na(lastSigBar) or bar_index - lastSigBar >= cooldownBars

bool rawIgniteLong  = barstate.isconfirmed and igniteLongEvt and igniteLongScore >= minIgniteScore and sessionOk and cooled
bool rawIgniteShort = barstate.isconfirmed and igniteShortEvt and igniteShortScore >= minIgniteScore and sessionOk and cooled

bool mIgniteLong  = showIgnition and rawIgniteLong
bool mIgniteShort = showIgnition and rawIgniteShort

if mIgniteLong or mIgniteShort
    lastSigBar := bar_index

// Exhaustion warnings
bool mExhaustBull = showExhaust and regime == 5 and trendDir == 1 and barstate.isconfirmed
bool mExhaustBear = showExhaust and regime == 5 and trendDir == -1 and barstate.isconfirmed

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  RISK LEVELS ON SIGNAL
// ════════════════════════════════════════════════════════════════════════════════════════════════
float sigSl = na
float sigTp1 = na
float sigTp2 = na
if mIgniteLong
    float coilEdge = slBeyondCoil and not na(coilLow) ? coilLow - atr * 0.15 : close - slAtrMult * atr
    sigSl  := math.min(coilEdge, close - slAtrMult * atr)
    sigTp1 := close + tp1AtrMult * atr
    sigTp2 := close + tp2AtrMult * atr
if mIgniteShort
    float coilEdgeS = slBeyondCoil and not na(coilHigh) ? coilHigh + atr * 0.15 : close + slAtrMult * atr
    sigSl  := math.max(coilEdgeS, close + slAtrMult * atr)
    sigTp1 := close - tp1AtrMult * atr
    sigTp2 := close - tp2AtrMult * atr

var line  lnSl  = na
var line  lnTp1 = na
var line  lnTp2 = na
var label lbSl  = na
var label lbTp1 = na
var label lbTp2 = na

f_tag(string p, float px) => p + " " + str.tostring(px, format.mintick)

if (mIgniteLong or mIgniteShort) and showLevels
    if not na(lnSl)
        line.delete(lnSl)
    if not na(lnTp1)
        line.delete(lnTp1)
    if not na(lnTp2)
        line.delete(lnTp2)
    if not na(lbSl)
        label.delete(lbSl)
    if not na(lbTp1)
        label.delete(lbTp1)
    if not na(lbTp2)
        label.delete(lbTp2)
    lnSl  := line.new(bar_index, sigSl,  bar_index + 12, sigSl,  color=color.new(BEAR_PRIMARY, 20), style=line.style_dashed, width=1)
    lnTp1 := line.new(bar_index, sigTp1, bar_index + 12, sigTp1, color=color.new(BULL_DIM, 30), style=line.style_dotted, width=1)
    lnTp2 := line.new(bar_index, sigTp2, bar_index + 12, sigTp2, color=color.new(BULL_PRIMARY, 10), style=line.style_dotted, width=1)
    lbSl  := label.new(bar_index + 12, sigSl,  f_tag("SL", sigSl),  style=label.style_label_left, size=size.tiny, textcolor=BEAR_PRIMARY, color=color.new(color.white, 94))
    lbTp1 := label.new(bar_index + 12, sigTp1, f_tag("TP1", sigTp1), style=label.style_label_left, size=size.tiny, textcolor=BULL_DIM, color=color.new(color.white, 94))
    lbTp2 := label.new(bar_index + 12, sigTp2, f_tag("TP2", sigTp2), style=label.style_label_left, size=size.tiny, textcolor=BULL_PRIMARY, color=color.new(color.white, 94))

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  COIL BOX VISUAL
// ════════════════════════════════════════════════════════════════════════════════════════════════
if showCoilBox and isCoiling and not na(coilStart)
    if na(coilBox)
        color boxCol = isFullyCoiled ? color.new(COIL_CLR, 82) : color.new(COIL_CLR, 90)
        coilBox := box.new(coilStart, coilHigh, bar_index, coilLow, border_color=color.new(COIL_CLR, 60), bgcolor=boxCol, border_width=1)
    else
        box.set_right(coilBox, bar_index)
        box.set_top(coilBox, coilHigh)
        box.set_bottom(coilBox, coilLow)
        color boxCol2 = isFullyCoiled ? color.new(COIL_CLR, 82) : color.new(COIL_CLR, 90)
        box.set_bgcolor(coilBox, boxCol2)
else if showCoilBox and not isCoiling and not na(coilBox)
    box.set_right(coilBox, bar_index)
    if regime == 0
        box.delete(coilBox)
        coilBox := na

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  REGIME BACKGROUND
// ════════════════════════════════════════════════════════════════════════════════════════════════
color regimeBg = showRegimeBg ?
  regime == 0 ? color.new(NEUTRAL_CLR, 96) :
  regime == 1 ? color.new(COIL_CLR, 95) :
  regime == 2 ? color.new(COIL_CLR, 90) :
  regime == 3 ? color.new(IGNITE_CLR, 88) :
  regime == 4 ? (trendDir == 1 ? color.new(BULL_PRIMARY, 94) : color.new(BEAR_PRIMARY, 94)) :
  regime == 5 ? color.new(EXHAUST_CLR, 90) : na : na

bgcolor(regimeBg, title="Regime Background")

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  PLOTS & MARKERS
// ════════════════════════════════════════════════════════════════════════════════════════════════
plotshape(mIgniteLong, title="IGNITE LONG", style=shape.labelup, location=location.belowbar,
  color=color.new(BULL_PRIMARY, 5), textcolor=#1a1a1a, text="IGNITE", size=size.small)
plotshape(mIgniteShort, title="IGNITE SHORT", style=shape.labeldown, location=location.abovebar,
  color=color.new(BEAR_PRIMARY, 5), textcolor=#ffffff, text="IGNITE", size=size.small)

plotshape(mExhaustBull, title="Exhaust Bull", style=shape.diamond, location=location.abovebar,
  color=color.new(EXHAUST_CLR, 10), size=size.tiny)
plotshape(mExhaustBear, title="Exhaust Bear", style=shape.diamond, location=location.belowbar,
  color=color.new(EXHAUST_CLR, 10), size=size.tiny)

// Bias vector arrow on last bar during coil
if showBiasArrow and barstate.islast and (regime == 1 or regime == 2) and math.abs(biasVector) >= 20
    string arrowTxt = biasVector >= 35 ? "▲ BIAS " + str.tostring(math.round(biasVector)) : biasVector <= -35 ? "▼ BIAS " + str.tostring(math.round(biasVector)) : "◆ " + str.tostring(math.round(biasVector))
    color arrowCol = biasVector > 15 ? BULL_PRIMARY : biasVector < -15 ? BEAR_PRIMARY : NEUTRAL_CLR
    float arrowY = biasVector >= 0 ? nz(coilLow, low) - atr * 0.6 : nz(coilHigh, high) + atr * 0.6
    label.new(bar_index, arrowY, arrowTxt, color=color.new(HEADER_BG, 20), textcolor=arrowCol,
      style=biasVector >= 0 ? label.style_label_up : label.style_label_down, size=size.small)

// Regime flip labels
if regimeChange and barstate.isconfirmed
    string rTxt = regime == 1 ? "BUILDING" : regime == 2 ? "COILED" : regime == 3 ? "IGNITION" : regime == 4 ? "TRENDING" : regime == 5 ? "EXHAUSTION" : "QUIET"
    color rCol = regime == 2 ? COIL_CLR : regime == 3 ? IGNITE_CLR : regime == 4 ? (trendDir == 1 ? BULL_PRIMARY : BEAR_PRIMARY) : regime == 5 ? EXHAUST_CLR : NEUTRAL_CLR
    if regime >= 1 and regime <= 5
        label.new(bar_index, high + atr * 0.3, rTxt, color=color.new(rCol, 75), textcolor=rCol, style=label.style_label_down, size=size.tiny)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  DASHBOARD
// ════════════════════════════════════════════════════════════════════════════════════════════════
f_dashPos(string p) =>
    p == "Top Right" ? position.top_right : p == "Top Left" ? position.top_left : p == "Top Center" ? position.top_center :
     p == "Bottom Right" ? position.bottom_right : p == "Bottom Left" ? position.bottom_left : position.bottom_center

szTxt = dashSize == "Bigger" ? size.normal : size.small
hdrC  = color.new(HEADER_CLR, 0)
hdrBg = color.new(HEADER_BG, 15)
cellBg = color.new(color.black, 75)

regimeName = regime == 0 ? "QUIET" : regime == 1 ? "BUILDING" : regime == 2 ? "COILED" : regime == 3 ? "IGNITION" : regime == 4 ? "TRENDING" : "EXHAUSTION"
regimeCol  = regime == 2 ? COIL_CLR : regime == 3 ? IGNITE_CLR : regime == 4 ? (trendDir == 1 ? BULL_PRIMARY : BEAR_PRIMARY) : regime == 5 ? EXHAUST_CLR : NEUTRAL_CLR

var table dash = table.new(f_dashPos(dashPos), 2, 14, bgcolor=color.new(color.black, 85), border_width=1, border_color=color.new(BORDER_CLR, 0), frame_width=1, frame_color=color.new(FRAME_CLR, 0))

f_row(int r, string k, string v, color vc) =>
    table.cell(dash, 0, r, k, text_color=hdrC, text_size=szTxt, bgcolor=hdrBg, text_halign=text.align_left)
    table.cell(dash, 1, r, v, text_color=vc, text_size=szTxt, bgcolor=cellBg, text_halign=text.align_right)

if barstate.islast
    table.cell(dash, 0, 0, "AlphaX CATALYST", text_color=hdrC, text_size=szTxt, bgcolor=hdrBg, text_halign=text.align_left)
    table.cell(dash, 1, 0, syminfo.ticker, text_color=color.new(BULL_PRIMARY, 0), text_size=szTxt, bgcolor=hdrBg, text_halign=text.align_right)
    f_row(1, "REGIME", regimeName, color.new(regimeCol, 0))
    f_row(2, "COMPRESS", str.tostring(math.round(compressScore)) + "%", compressScore >= 75 ? color.new(COIL_CLR, 0) : compressScore >= 50 ? color.new(COIL_CLR, 30) : hdrC)
    f_row(3, "SQUEEZE", sqzOn ? "ON" : sqzRelease ? "RELEASE" : "OFF", sqzOn ? color.new(COIL_CLR, 0) : sqzRelease ? color.new(IGNITE_CLR, 0) : hdrC)
    f_row(4, "ATR RANK", str.tostring(math.round(atrPctRank)) + "th", atrPctRank < 30 ? color.new(COIL_CLR, 0) : hdrC)
    f_row(5, "VOL DRY", volDry ? "YES" : "NO", volDry ? color.new(COIL_CLR, 0) : hdrC)
    f_row(6, "BIAS VECTOR", (biasVector >= 0 ? "+" : "") + str.tostring(math.round(biasVector)), biasVector >= 35 ? color.new(BULL_PRIMARY, 0) : biasVector <= -35 ? color.new(BEAR_PRIMARY, 0) : hdrC)
    f_row(7, "HTF BIAS", htfBull ? "BULL" : htfBear ? "BEAR" : "FLAT", htfBull ? color.new(BULL_PRIMARY, 0) : htfBear ? color.new(BEAR_PRIMARY, 0) : hdrC)
    f_row(8, "VOL DELTA", volDelta > 0 ? "BUYERS" : "SELLERS", volDelta > 0 ? color.new(BULL_PRIMARY, 0) : color.new(BEAR_PRIMARY, 0))
    f_row(9, "IGNITE L", str.tostring(math.round(igniteLongScore)), igniteLongScore >= minIgniteScore ? color.new(BULL_PRIMARY, 0) : hdrC)
    f_row(10, "IGNITE S", str.tostring(math.round(igniteShortScore)), igniteShortScore >= minIgniteScore ? color.new(BEAR_PRIMARY, 0) : hdrC)
    f_row(11, "COIL BARS", str.tostring(coilBarCount), coilBarCount >= coilMinBars ? color.new(COIL_CLR, 0) : hdrC)
    string coilRng = not na(coilHigh) and not na(coilLow) ? str.tostring(coilHigh - coilLow, format.mintick) : "—"
    f_row(12, "COIL RANGE", coilRng, hdrC)
    f_row(13, "SESSION", sessionOk ? "ACTIVE" : "FILTERED", sessionOk ? color.new(BULL_DIM, 0) : color.new(BEAR_DIM, 0))

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ════════════════════════════════════════════════════════════════════════════════════════════════
alertcondition(mIgniteLong,  title="CATALYST Ignite Long",  message="AlphaX CATALYST: IGNITE LONG on {{ticker}} {{interval}} — volatility expansion bullish")
alertcondition(mIgniteShort, title="CATALYST Ignite Short", message="AlphaX CATALYST: IGNITE SHORT on {{ticker}} {{interval}} — volatility expansion bearish")
alertcondition(regime == 2 and regime[1] != 2, title="CATALYST Fully Coiled", message="AlphaX CATALYST: Market COILED on {{ticker}} — watch for ignition")
alertcondition(sqzRelease, title="CATALYST Squeeze Release", message="AlphaX CATALYST: Squeeze released on {{ticker}} — expansion imminent")
alertcondition(mExhaustBull or mExhaustBear, title="CATALYST Exhaustion", message="AlphaX CATALYST: EXHAUSTION warning on {{ticker}} — trend energy fading")
````

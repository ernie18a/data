# [ A L P H A X ] VECTOR - Regime-Adaptive Flow Engine

- url: https://www.tradingview.com/script/yXa6jJv8-A-L-P-H-A-X-VECTOR-Regime-Adaptive-Flow-Engine/
- type: indicator
- pine_id: PUB;30e5ede3da5341cd8f85908353ccf49a
- version: 1.0

## Description

[b]AlphaX VECTOR — Regime-Adaptive Flow Engine: Kaufman ER Regime Classification, KAMA Vector Line, Multi-Component Flow Score & Scalping-Optimized Entry Playbooks[/b]

AlphaX VECTOR is a professional-grade scalping system built around a fundamentally different architectural premise from every other indicator in the AlphaX suite: the market regime is identified first, and the entry playbook is selected automatically to match that regime. Most scalping systems apply the same entry logic regardless of whether the market is trending, ranging, or chopping — and then wonder why the same setup works brilliantly in one context and fails consistently in another. VECTOR solves this at the architectural level by running a three-metric regime classification engine (Efficiency Ratio, Choppiness Index, and ADX) that determines the current market character on every bar and locks in one of four states: Trend Bull, Trend Bear, Balance/Range, or Chop. Each state activates a different set of entry playbooks — micro-pullbacks to the Vector Line in trends, micro-impulse breaks in balance or trend, mean-reversion fades at band extremes in balance — and all entries are filtered through a 6-component Flow Vector score that measures the directional conviction of the current market from five independent dimensions. The result is a system where every signal is not just directionally filtered, but regime-appropriate — built for M1 through M15 scalping on gold, forex, indices, and crypto.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🧭 [b]The Core Philosophy — Regime First, Setup Second[/b]

The single biggest failure mode in scalping is applying trend-following entries in choppy markets and mean-reversion entries in trending markets. The market character changes continuously — a trending gold session can collapse into a tight range within minutes, and a balance period can explode into a directional impulse with no warning. Any fixed system that ignores this regime cycle will have extended periods of consistent losses whenever the market shifts character.

VECTOR's architecture inverts the standard approach. Instead of picking a setup type and then trying to filter bad signals, VECTOR determines the market's current character first — with three independent quantitative measurements — and then selects the correct playbook for that character. In Trend Bull, only pullback and impulse break setups fire. In Balance, only impulse breaks and band fades fire. In Chop, nothing fires. The dashboard explicitly tells you the active playbook at all times: SCALP PULLBACK ▲, SCALP PULLBACK ▼, SCALP FADE / BREAK, or NO TRADES.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]The Regime Engine — Three Independent Classifiers[/b]

The regime is determined on every bar by three completely independent measurements. The combination of all three produces a robust, multi-dimensional picture of market character that no single indicator alone could provide.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Kaufman Efficiency Ratio (ER)[/b]

The Efficiency Ratio measures how directionally efficient price movement has been over the lookback period (default: 10 bars). It divides the net directional change in price by the total path traveled — the sum of all individual bar-to-bar movements. A ratio close to 1.0 means every bar moved in the same direction — maximum efficiency, maximum trend. A ratio close to 0.0 means the total path traveled far exceeds the net movement — price oscillated back and forth with no net progress — maximum chop, minimum efficiency.

[b]ER thresholds:[/b]
[list]
[*][b]ER ≥ 0.35 (trend minimum)[/b] — price is moving with high directional efficiency. The market is trending and momentum setups are appropriate
[*][b]ER ≤ 0.22 (chop maximum)[/b] — price is oscillating with low efficiency. Combined with low ADX, this triggers the CHOP regime and blocks all signals
[*][b]Between thresholds[/b] — transitional state. Not clear trend, not clear chop
[/list]

The ER is displayed live on the dashboard with color coding — yellow-green when in trend territory, orange when in chop territory, neutral otherwise. This single number tells you the fundamental quality of price direction at any given moment.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Choppiness Index[/b]

The Choppiness Index (CI) provides an independent measure of market randomness using a logarithmic ratio formula. It calculates the sum of all individual ATR readings over the lookback period (default: 14 bars) divided by the total high-low range of that period. High CI values indicate the range of the period was consumed by oscillating ATRs — choppy movement. Low CI values indicate the period's range was established by directional movement.

[b]CI interpretation:[/b]
[list]
[*][b]CI above 61.8[/b] — the market is in a Golden Ratio chop zone. Institutional consensus is absent. All signals are suppressed when this threshold is exceeded (configurable, default: 61.0)
[*][b]CI below 38.2[/b] — maximum trending efficiency. In practice, CI values this low indicate an impulsive directional move in progress
[*][b]CI between 38.2 and 61.8[/b] — transitional territory, neither pure trend nor pure chop
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]ADX (Average Directional Index)[/b]

The ADX provides the most widely recognized trend strength measure, confirming whether a directional bias measured by ER and CI is backed by genuine momentum. ADX above the configured minimum (default: 20) is required for Trend Bull or Trend Bear regime classification. Below the minimum, even if ER is high and CI is low, the system classifies as Balance rather than Trend — the directional efficiency exists but the momentum confirmation is absent.

[b]Combined regime logic:[/b]
[list]
[*][b]CHOP (0)[/b] — CI above threshold OR (ER below chop max AND ADX below trend min). The market is in an untradeable oscillating state. Dashboard shows ⛔ CHOP — STAND ASIDE. All signals blocked
[*][b]TREND BULL (1)[/b] — not chop, ADX above trend min, ER above trend min, Flow Vector positive, price above Vector Line. Playbook: SCALP PULLBACK ▲
[*][b]TREND BEAR (2)[/b] — same conditions with Flow Vector negative and price below Vector Line. Playbook: SCALP PULLBACK ▼
[*][b]BALANCE (3)[/b] — not chop, but ADX or ER conditions for trend not met. Market is directional enough for scalping but not in a clear trend. Playbook: SCALP FADE / BREAK
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 [b]The KAMA Vector Line — Adaptive Trend Reference[/b]

The Vector Line is a [b]Kaufman Adaptive Moving Average (KAMA)[/b] — the same ER-weighted adaptive EMA that forms the basis of the regime classification. It is the central price reference for all pullback entries and a key component of the Flow Vector score.

[b]Why KAMA over a standard EMA:[/b] A standard EMA responds with the same speed regardless of market conditions. In a trending market, the EMA lags price and creates false pullback signals. In a choppy market, it whipsaws. KAMA self-adjusts — it moves quickly in trending conditions (tracking price closely) and moves slowly in choppy conditions (staying stable). This means the Vector Line acts as an accurate, self-calibrating trend reference that naturally tightens around price during strong trends and widens away from price during chop.

[b]Vector Line color coding:[/b] The line is plotted in gradient color based on the current Flow Vector score — bright yellow-green when the Flow Vector is strongly positive (above the Strong Vector threshold), bright red when strongly negative, fading to semi-transparent in neutral territory. At a glance, the Vector Line's color tells you the directional conviction of the current market.

[b]Vector Line price:[/b] The exact current Vector Line price is displayed on the dashboard as VECTOR LINE in real time — the precise price level where pullback entries are being monitored.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ [b]The Flow Vector — 6-Component Directional Score[/b]

The Flow Vector is a composite directional score ranging from -100 (maximum bearish conviction) to +100 (maximum bullish conviction). It is computed on every bar from six independent measurements, each capturing a different dimension of directional bias.

[b]Component 1 — EMA Stack (up to ±22 points):[/b]
A triple EMA (8/21/50) full stack alignment — EMA 8 above EMA 21 above EMA 50, with price above EMA 8 — scores +22 points for bull, -22 for bear stack. Partial alignment (price simply above or below EMA 21) scores ±8. This is the momentum structure layer.

[b]Component 2 — Vector Line Slope (up to ±18 points):[/b]
Whether the KAMA Vector Line is currently rising or falling. A rising Vector Line in a bull trend confirms the adaptive average is itself accelerating — ±18 points. This ensures the entry direction is aligned with the KAMA's own momentum, not fighting it.

[b]Component 3 — OBV Slope (up to ±15 points):[/b]
The slope of On-Balance Volume over the configured lookback period (default: 10 bars). A rising OBV slope means net buying pressure is accumulating (each up-close bar adds volume, each down-close subtracts). A falling slope confirms net selling. ±15 points. This is the volume accumulation/distribution layer — independent of price movement.

[b]Component 4 — Volume Delta (up to ±12 points):[/b]
The estimated directional volume pressure — bull volume EMA minus bear volume EMA using the candle range position method. ±12 points. This captures intrabar volume directional bias as opposed to OBV's inter-bar accumulation bias.

[b]Component 5 — HTF EMA Bias (up to ±18 points):[/b]
The higher timeframe EMA structure — fast EMA above slow EMA with close above fast EMA (bull) or the inverse (bear). ±18 points. This ensures the Flow Vector reflects the macro institutional direction, not just the current timeframe's local momentum.

[b]Component 6 — Price vs Vector Line (up to ±15 points):[/b]
Whether the current close is above or below the KAMA Vector Line. ±15 points. Price above the Vector Line in a bull regime confirms the pullback has not reached the Vector Line yet (trend intact). Price below confirms the line has been reached or breached (potential reversal zone).

[b]Flow Vector thresholds:[/b]
[list]
[*][b]+40 to +100[/b] — strong bull flow. Setup A (Trend Micro-Pullback) long entries require this minimum
[*][b]+65 to +100[/b] — extreme bull flow. Used as a fade signal when combined with upper balance band touch
[*][b]-40 to -100[/b] — strong bear flow. Setup A short entries require this minimum
[*][b]-65 to -100[/b] — extreme bear flow. Fade signal condition for lower band touches
[*][b]-39 to +39[/b] — neutral flow. Directional conviction insufficient for Trend regime entries
[/list]

[b]Flow Acceleration:[/b]
In addition to the absolute score, VECTOR checks whether the Flow Vector is currently accelerating — increasing for two consecutive bars (bull) or decreasing for two consecutive bars (bear). Acceleration is a hard requirement for Setup A (Trend Micro-Pullback) entries, ensuring the entry occurs when flow is building rather than stalling or reversing.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🕯 [b]Scalping Candle Quality — The Pin Bar Filter[/b]

VECTOR applies a specific, tight candle quality standard for all entry types — the scalping pin bar. All four conditions must be simultaneously true:

[b]Bull pin bar requirements:[/b]
[list]
[*]Bullish close (close above open)
[*]Lower wick covers at least 42% of the total bar range — the rejection of the low is dominant
[*]Upper wick is at most 32% of the total range — no significant selling into the close
[*]Body size at least 0.10× ATR — not a doji or near-doji
[*]Close in the upper 28% of the bar range (upper quartile) — the bar closed strongly bullish
[/list]

[b]Bear pin bar requirements:[/b] The mirror conditions — upper wick dominant (42%+ of range), lower wick minimal (32% max), small minimum body, close in the lower quartile.

[b]Why this specific candle quality standard for scalping:[/b] Scalping entries are executed in the wick of the signal candle — buying at the low of a bull pin bar, selling at the high of a bear pin bar. A candle that lacks a dominant rejection wick provides no clear structural fill level. The upper quartile close requirement for bulls ensures the rejection was decisive — not a bar that dipped into support and then closed mediocre. These parameters are significantly stricter than the standard 50% wick filter used in MERIDIAN and PIVOT, reflecting the precision required for scalping entries.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🏷 [b]Four Setup Types — Regime-Gated Playbooks[/b]

VECTOR implements four distinct setup types, each activated only in the appropriate regime state. The active playbook is displayed on the dashboard as a PLAYBOOK row, telling you exactly which setups are available right now.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Setup A — Trend Micro-Pullback (Regime: Trend Bull or Trend Bear only)[/b]

The primary VECTOR scalp entry. Fires in Trend Bull regime for longs, Trend Bear for shorts.

[b]Full condition stack for long:[/b]
[list]
[*]Regime is Trend Bull (regime == 1)
[*]Flow Vector is strongly bullish (≥ +40)
[*]Flow Vector is accelerating (rising for two consecutive bars)
[*]Price has touched the EMA 8 or Vector Line from above — the micro-pullback has reached the trend reference level. Touch tolerance is ±0.22× ATR (configurable)
[*]A qualifying bull pin bar has formed at the touch
[*]The recent 5-bar low has dipped into the EMA 8 / Vector Line zone (confirming the touch was genuine, not just proximity)
[*]Price is not extended above the Vector Line by more than the maximum extension setting (default: 1.0× ATR) — the anti-chase filter
[*]RSI(7) is between 40 and 70 — not already overbought, not in a capitulation zone
[/list]

[b]Why this is the core scalp setup:[/b] In a confirmed Trend Bull regime with accelerating flow, the EMA 8 and Vector Line are the natural pullback magnets. Institutional buyers who are long in the trend use these levels to add on dips. The pin bar at the level confirms they stepped in. The anti-extension filter prevents chasing a move that has already run 1× ATR above the Vector Line — exactly the stretch that precedes a deeper pullback.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Setup B — Micro Impulse Break (Regime: Trend or Balance)[/b]

A momentum continuation scalp that fires when price breaks out of a micro swing range with a qualifying body and volume delta confirmation.

[b]Key conditions for long:[/b]
[list]
[*]Regime is Trend Bull or Balance (the setup fires across both regimes as momentum can develop in either)
[*]Price closes above the highest high of the last 4 bars (configurable lookback) on the previous bar — a genuine micro swing break
[*]The break bar's body meets the minimum body threshold (default: 0.85× the impulse body minimum × ATR)
[*]Volume delta is positive — buying pressure drove the break
[*]A qualifying bull pin bar is present on the break bar
[*]HTF bias aligns — long only when the higher timeframe confirms bullish
[*]Price is not over-extended above the Vector Line (anti-chase filter)
[/list]

[b]What this setup captures:[/b] The breakout from a micro consolidation range with volume confirmation — the intrabar equivalent of a structure break. On a 1-minute chart, a 4-bar micro range that breaks with a strong body and bull delta is a clean scalp entry with a tight stop at the bottom of the range. In Balance regime, this setup provides the best entries because the market character does not support pullback trades but does support momentum breaks on sufficient flow.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Setup C — Range Fade / Band Extreme (Regime: Balance only)[/b]

The mean-reversion scalp. Fires only in Balance regime when price reaches the outer balance band with an exhausted or reversing Flow Vector.

[b]Short fade conditions:[/b]
[list]
[*]Regime is Balance (regime == 3)
[*]Price has touched the upper balance band (within 0.08× ATR of the upper band)
[*]The Flow Vector is either in extreme bull territory (≥ +65, meaning the move to the band is overextended) OR the flow is beginning to fade (Flow Vector is falling and was recently above +53)
[*]A qualifying bear pin bar confirms the rejection at the band
[*]RSI(7) is above 58 — confirming the RSI is elevated at the band touch, consistent with a reversal setup
[/list]

[b]Why band fades only fire in Balance:[/b] In a Trend Bull regime, price touching the upper balance band is a continuation event — the trend is simply pushing to the next level. Fading that in a trend produces the most reliable losses in scalping. Setup C is therefore hard-gated to Balance regime only, where the market has proven it is oscillating rather than trending, and the balance band genuinely represents a mean-reversion boundary.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Setup D — Vector Shift / Flow Zero-Cross (Off by default)[/b]

A legacy setup type that fires when the Flow Vector crosses from negative to positive (long) or positive to negative (short) with a strong body candle and positive volume delta. Off by default on fast timeframes because flow zero-crosses on M1–M5 produce excessive noise. Available for traders who want to experiment with flow momentum entries on H1+ timeframes where the zero-cross carries more structural weight.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🧠 [b]The 7-Point Scalp-Weighted Confluence Score[/b]

VECTOR uses a setup-weighted scoring system specifically calibrated for scalping frequency and quality:

[b]Score structure:[/b]
[list]
[*][b]Setup Type (up to 2 points)[/b] — primary setups (Trend Micro-Pullback, Micro Impulse) score 2 points. Secondary setups (Range Fade, Vector Shift) score 1 point. This weighting reflects that Setup A and B have more prerequisite conditions and are inherently higher quality
[*][b]Flow Acceleration (1 point)[/b] — Flow Vector is actively building in the signal direction over the last two bars. Ensures the entry coincides with momentum building, not stalling
[*][b]HTF Bias (1 point)[/b] — higher timeframe EMA confirms the signal direction
[*][b]Volume Expansion (1 point)[/b] — current bar volume exceeds the volume average by the configured minimum (default: 1.05×)
[*][b]Non-Chop Market (1 point)[/b] — the market is not in Chop regime. This point is also enforced as a hard gate — signals cannot fire in Chop regardless of the score
[*][b]RSI(7) Filter (1 point)[/b] — the 7-period RSI is in the acceptable zone for the signal direction (40–70 for longs, 30–60 for shorts)
[/list]

[b]Maximum score: 7. Default minimum: 4.[/b] The scalp-weighted system means that a Setup A or B entry with flow acceleration, HTF alignment, and volume can reach 5 points from the setup type, flow, HTF, and volume components alone — a clean high-quality signal. Setup C entries require more supporting factors to reach the threshold because their 1-point setup score means more of the other layers must confirm.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🛡 [b]Anti-Chase & Quality Filters[/b]

VECTOR includes several anti-chase and quality gates specifically designed for scalping precision that do not appear in the other AlphaX indicators.

[b]Extension Filter:[/b] No long signal fires if price is already above the Vector Line by more than the configured maximum extension (default: 1.0× ATR). No short signal fires if price is already below by that much. This single filter eliminates the most common scalping failure — entering a pullback after it has already run too far from the reference level, leaving insufficient room for the signal to develop before hitting the stop.

[b]Dip/Rip Confirmation:[/b] For Setup A entries, the 5-bar lowest low (bull) or highest high (bear) must have reached within a tight ATR tolerance of the reference lines. This confirms that the touch was genuine — price actually dipped into the zone — rather than just being close to it without contacting it.

[b]RSI(7) Micro Filter:[/b] A 7-period RSI gate blocks entries when RSI is already overbought (above 70 for longs) or in a knife-catch zone (below 40 for shorts). On scalping timeframes, entering a long when 7-bar RSI is already at 75 means you are entering after the move is exhausted. This filter alone dramatically reduces the worst class of setup A false signals — those that occur when price is touching the EMA 8 on the way back down through it rather than bouncing off it.

[b]Flow Acceleration Requirement:[/b] Setup A requires the Flow Vector to be accelerating (not just positive) for two consecutive bars. A stale, high but flat Flow Vector indicates the move is decelerating — the opposite of the momentum condition that produces clean scalp continuations.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 [b]Scalp Entry Reference — Wick-Based Positioning[/b]

Unlike the other AlphaX indicators where the entry is taken on the close or next open, VECTOR's entry reference is the rejection wick of the signal candle — specifically the bar's low (for bull signals) or high (for bear signals). This is the optimal scalp fill zone.

[b]Why the wick, not the close:[/b] A scalp pin bar with a 42%+ lower wick has a significant low-to-close range. Entering at the close gives up nearly half that range unnecessarily. The institutional scalp entry is at the wick extreme — the exact level where buyers stepped in and stopped the selling. A limit order at the bar's low (bull) captures the optimal risk/reward because the stop goes below that low, and the full bar range is available as immediate profit space.

[b]Entry reference visualization:[/b] A cross marker is plotted at the signal bar's low (bull) or high (bear) — the wick entry reference — distinct from the signal triangle. This gives you the precise price at which to place a limit order if you prefer limit entry over market-on-open execution.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]Live Dashboard[/b]

The 17-row real-time dashboard displays the complete internal state across five sections.

[b]REGIME[/b]
[list]
[*][b]Market Regime[/b] — current regime state with icon: ⛔ CHOP — STAND ASIDE, ▲ TREND BULL, ▼ TREND BEAR, or ◆ BALANCE / RANGE. This is the primary trading context indicator
[*][b]Playbook[/b] — the active setup playbook matching the current regime: NO TRADES, SCALP PULLBACK ▲, SCALP PULLBACK ▼, or SCALP FADE / BREAK. Tells you exactly which setup types can fire
[*][b]Flow Vector[/b] — the live composite Flow Vector score with + or - sign. Yellow-green when strongly positive, red when strongly negative, neutral otherwise
[/list]

[b]METRICS[/b]
[list]
[*][b]Efficiency[/b] — current Kaufman Efficiency Ratio value. Yellow-green when in trend territory (≥ threshold), orange when in chop territory (≤ chop max)
[*][b]Chop Index[/b] — current Choppiness Index value. Orange when above the stand-aside threshold
[*][b]ADX[/b] — current ADX value. Yellow-green when above the trend minimum
[*][b]Vol Delta[/b] — ▲ BUYERS or ▼ SELLERS based on the current volume delta direction
[/list]

[b]FILTERS[/b]
[list]
[*][b]HTF Bias[/b] — ▲ BULL, ▼ BEAR, or — FLAT
[*][b]Session[/b] — ✓ ACTIVE or ✗ OFF
[/list]

[b]CONFLUENCE[/b]
[list]
[*][b]Bull Score[/b] — live 0–7 score. Background highlights yellow-green when threshold is met and regime is not Chop
[*][b]Bear Score[/b] — live 0–7 score. Background highlights red when threshold is met and regime is not Chop
[*][b]Vector Line[/b] — the exact current KAMA Vector Line price, color-coded by Flow Vector strength
[/list]

[b]Live confluence label:[/b] During non-chop regimes, a small B x/7 · S x/7 label appears near the Vector Line on the current bar, updating in real time.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 [b]Chart Visual System[/b]

[list]
[*][b]KAMA Vector Line[/b] — the adaptive trend reference line, color-coded by Flow Vector strength. Bright yellow-green when bull flow is strong, bright red when bear flow is strong, fading to semi-transparent in neutral/weak territory
[*][b]Balance Bands (upper, lower, midline)[/b] — the Bollinger-style bands used as reference for Balance regime and Setup C fade entries. Purple-tinted at low opacity
[*][b]▲ Label with setup tag (below bar, yellow-green)[/b] — bull scalp signal. Tag shows A, B, C, or D identifying which setup type fired. Tooltip shows the full setup description
[*][b]▼ Label with setup tag (above bar, red)[/b] — bear scalp signal
[*][b]Entry Reference Cross (× marker)[/b] — plotted at the signal bar's low (bull) or high (bear) — the optimal scalp limit entry price
[*][b]SL Guide (red dotted circles)[/b] — stop loss reference below the EMA 8 and Vector Line minimum (bull) or above (bear), plus ATR buffer
[*][b]TP Guide (yellow-green dotted circles)[/b] — dynamically computed reward target at R multiple
[*][b]Regime Change Labels (optional)[/b] — small labels at regime transition bars showing TREND ▲, TREND ▼, or BALANCE. Off by default — regime visible on dashboard
[*][b]Live confluence label[/b] — B x/7 · S x/7 near the Vector Line on the current bar
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 [b]How to Trade with AlphaX VECTOR — Step by Step[/b]

[b]Step 1 — Read the Regime First[/b]
[list]
[*]Check the Market Regime row on the dashboard. ⛔ CHOP — do nothing, close the chart if needed. ◆ BALANCE — Setup B and C available. ▲ TREND BULL or ▼ TREND BEAR — Setup A is active
[*]Check the Playbook row — it tells you exactly which setup type is currently firing-eligible
[*]Note the Flow Vector value. Above +40 in Trend Bull is the optimal Setup A environment. Below +40 but still positive suggests the trend may be weakening
[/list]

[b]Step 2 — Prepare the Level[/b]
[list]
[*]In Trend Bull, identify where the Vector Line is currently sitting (Vector Line on dashboard). This is your Setup A anchor level — watch for price to pull back toward it
[*]Note the EMA 8 on the chart. For Setup A, price must touch either EMA 8 or the Vector Line — whichever is closest to price is the active support
[*]In Balance, note where the upper and lower balance bands sit. These are the Setup C fade boundaries
[/list]

[b]Step 3 — Enter on the Signal Label[/b]
[list]
[*]A ▲ label below the bar with setup tag [A] is the core scalp signal — Trend Micro-Pullback long. All conditions including regime, flow acceleration, line touch, pin bar, RSI, and extension filter are confirmed
[*]The entry reference × marker shows the wick low — the optimal limit order price
[*]The SL guide is at the minimum of EMA 8, Vector Line, and the bar low, minus ATR buffer. This is a tight structural stop designed for scalping
[*]The TP guide is at the R-multiple target. Default 2.0R for a tight scalp stop produces a larger absolute target than most other AlphaX indicators due to the compressed ATR-based stops
[/list]

[b]Step 4 — Manage the Scalp[/b]
[list]
[*]Scalp trades in VECTOR are short-duration by design — move the stop to breakeven after any meaningful move in your favor
[*]Watch the Flow Vector on the live label — if it drops below +40 during a long trade, the bull flow is weakening. Consider taking profit early
[*]If the regime changes to Chop during an open trade, take profit immediately — the market character has changed and the setup's underlying logic no longer applies
[*]Setup A targets in strong Trend Bull regimes can be extended toward the band extremes. In strong trends, the first R-target is often just the beginning of a larger move
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Identifying Low-Quality Conditions — When Not to Trade[/b]

[b]Stand aside when:[/b]
[list]
[*][b]Market Regime shows ⛔ CHOP[/b] — this is the clearest possible signal to step back. No signals will fire, and any manual entries during chop carry statistically negative expectation on scalping timeframes
[*][b]Chop Index above 61 on the dashboard[/b] — even if regime hasn't fully shifted to CHOP, a CI above 61 is a warning that market character is deteriorating. Reduce size or stop trading
[*][b]Flow Vector is between -39 and +39[/b] — the directional conviction is insufficient for Setup A. In this zone, the market is neither clearly bullish nor bearish at the flow level. Wait for the vector to commit above ±40
[*][b]Flow Vector is high but flat (no acceleration)[/b] — a Flow Vector at +55 that has been flat for 5 bars means the momentum is stale. Setup A requires active acceleration, not just a high score. The signal will be blocked, but the absence of acceleration is itself a warning
[*][b]HTF Bias opposes the signal direction[/b] — scalping against the higher timeframe institutional flow is the highest-risk scalp. If HTF shows BEAR and you are attempting Setup A longs, every entry is fundamentally counter-trend
[*][b]RSI(7) is above 70 at a bull pin bar[/b] — the 7-bar RSI filter will block the signal, but if you see a bull pin at the Vector Line with RSI at 72, it is a warning that the touch is occurring after an overbought condition rather than at a healthy pullback
[*][b]Regime changes rapidly between states[/b] — if the regime is cycling between Trend Bull and Balance or Balance and Chop multiple times per session, the market is in an indecisive transition phase. These transitions produce the most noise and the lowest signal quality across all setup types
[/list]

[b]The ideal VECTOR scalp setup:[/b]
[list]
[*]Trend Bull or Trend Bear regime sustained for 5+ bars
[*]Flow Vector at ±55 or above, actively accelerating
[*]HTF aligned with regime direction
[*]Price pulling back cleanly to the Vector Line / EMA 8 zone with a tight, contained range
[*]Bull or bear pin bar with lower/upper wick of 50%+ of range, closing in the upper/lower quartile
[*]RSI(7) between 45–60 for longs or 40–55 for shorts — the healthy pullback RSI zone
[*]Volume above average, volume delta confirming direction
[*]Score at 5/7 or higher
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ [b]Key Features[/b]
[list]
[*]🧭 Three-metric regime classification engine — Kaufman Efficiency Ratio, Choppiness Index, and ADX combined to classify every bar as Trend Bull, Trend Bear, Balance, or Chop
[*]📊 Active playbook display — dashboard tells you exactly which setup type is eligible right now: SCALP PULLBACK ▲/▼, SCALP FADE / BREAK, or NO TRADES
[*]📈 KAMA Vector Line — adaptive moving average that tightens in trends and stabilizes in chop, providing the most accurate scalp reference line available
[*]⚡ 6-component Flow Vector — EMA Stack, KAMA Slope, OBV Slope, Volume Delta, HTF Bias, and Price vs Vector Line combined into a -100 to +100 directional conviction score
[*]🔴 Flow Acceleration detection — Setup A requires the Flow Vector to be actively building for two consecutive bars, blocking stale or decelerating flow entries
[*]🏷 Four regime-gated setup types — Setup A (Trend Micro-Pullback), Setup B (Micro Impulse Break), Setup C (Balance Band Fade), Setup D (Vector Shift, off by default)
[*]🕯 Strict scalping pin bar standard — lower/upper wick ≥ 42% of range, opposing wick ≤ 32%, minimum body, close in upper/lower quartile — the highest candle quality standard in the AlphaX suite
[*]🛡 Anti-chase extension filter — blocks signals when price has already moved too far from the Vector Line, eliminating chasing entries
[*]📍 Wick-based entry reference — × marker at the signal bar's wick extreme for optimal limit order placement
[*]🔢 RSI(7) micro filter — 7-period RSI gates block overbought longs and oversold shorts at the exact scalp entry bar
[*]📊 Live Efficiency, Choppiness, and ADX metrics on dashboard — the three regime classification inputs displayed with live values and color-coded thresholds
[*]🎨 Flow Vector–colored Vector Line — line color reflects directional conviction in real time from strong bull to neutral to strong bear
[*]📊 17-row live dashboard — Regime, Playbook, Flow Vector, Efficiency, Chop Index, ADX, Vol Delta, HTF Bias, Session, Confluence, and Vector Line price updated every bar
[*]🔔 5 alert conditions — long entry, short entry, chop warning, trend bull regime change, trend bear regime change
[*]⚙ Fully configurable — ER lookback and thresholds, CI length and maximum, ADX length and minimum, KAMA parameters, OBV and delta lengths, flow vector thresholds, all four setup enables, pullback tolerance, anti-chase extension, impulse body minimum, confluence minimum, HTF timeframe and EMAs, volume filter, session, SL/TP parameters, and all colors are independently adjustable
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙ [b]Settings Reference[/b]

[b]Regime Engine[/b]
[list]
[*]ATR Length — ATR lookback for all ATR-relative calculations (default: 14)
[*]Efficiency Ratio Length — Kaufman ER lookback period (default: 10)
[*]ER Min for Trend Regime — minimum ER to qualify as trend (default: 0.35)
[*]ER Max for Chop Regime — maximum ER that contributes to chop classification (default: 0.22)
[*]Choppiness Index Length — CI calculation lookback (default: 14)
[*]Chop Index — Stand Aside Above — CI threshold above which all signals are suppressed (default: 61.0)
[*]ADX Length — ADX calculation lookback (default: 14)
[*]ADX Min for Trend — minimum ADX for Trend Bull or Trend Bear classification (default: 20.0)
[*]Balance Band Length / Mult — parameters for the balance band Bollinger calculation (defaults: 20 / 2.0)
[/list]

[b]Flow Vector[/b]
[list]
[*]Vector Line (KAMA) Length — KAMA lookback period (default: 21)
[*]KAMA Fast / KAMA Slow — KAMA smoothing constants (defaults: 2 / 30)
[*]OBV Slope Length — lookback bars for OBV slope calculation (default: 10)
[*]Volume Delta Length — EMA smoothing for volume delta estimation (default: 14)
[*]Strong Vector Threshold — minimum absolute Flow Vector for strong directional condition (default: 40)
[*]Extreme Vector (range fade) — Flow Vector level triggering the extreme condition for Setup C fades (default: 65)
[/list]

[b]Entries & Confluence (Scalping)[/b]
[list]
[*]Setup A · Trend Micro-Pullback — toggle the primary trend scalp setup
[*]Setup B · Micro Impulse Break — toggle the momentum continuation scalp
[*]Setup C · Range Fade (band extreme) — toggle the balance band mean-reversion scalp
[*]Setup D · Vector Shift (legacy) — toggle the flow zero-cross setup (default: off)
[*]Pullback Touch Tolerance (xATR) — ATR tolerance for EMA 8 / Vector Line touch detection (default: 0.22)
[*]Impulse Min Body (xATR) — minimum body size for Setup B impulse and Setup D shift candles (default: 0.55)
[*]Max Extension from Vector (xATR) — maximum allowed distance from Vector Line before anti-chase blocks the signal (default: 1.0)
[*]Micro Swing Lookback — bars for the Setup B micro swing high/low reference (default: 4)
[*]Min Confluence Layers (of 7) — minimum score to fire a signal (default: 4)
[*]Show Entry Signals — toggle signal labels
[*]Show Confluence Label — toggle the live B/S score label near the Vector Line
[*]Signal Cooldown (bars) — minimum bars between consecutive signals (default: 3)
[/list]

[b]Filters[/b]
[list]
[*]HTF Trend Filter — toggle higher timeframe EMA alignment requirement
[*]HTF Timeframe — higher timeframe for EMA data (default: 60-minute)
[*]HTF Fast / Slow EMA — EMA periods on the HTF (defaults: 21 / 55)
[*]Volume Confirm — toggle volume expansion requirement
[*]Min Volume vs Avg — minimum volume ratio (default: 1.05)
[*]Volume Avg Length — SMA length for volume baseline (default: 20)
[*]Session Filter — toggle active hours restriction (default: off)
[*]Active Session — configurable session window
[/list]

[b]Exit Guidance[/b]
[list]
[*]Show SL / TP Guides — toggle stop and target circle plots
[*]SL Distance (xATR) — ATR buffer added beyond the EMA 8 / Vector Line stop anchor (default: 0.85)
[*]TP Reward (R) — take profit as a multiple of the actual risk (default: 2.0)
[/list]

[b]Display[/b]
[list]
[*]Show Vector Line (KAMA) — toggle the adaptive trend reference line
[*]Show Balance Bands — toggle the BB-style balance band plots
[*]Show Regime Change Labels — toggle small regime transition labels on regime-change bars (default: off)
[*]Show Dashboard — toggle the full dashboard
[*]Dashboard Position — Top Left / Top Right / Bottom Left / Bottom Right
[/list]

[b]Colors[/b]
[list]
[*]Bull / Bull Bright — yellow-green family for bullish signals and indicators
[*]Bear / Bear Bright — red family for bearish signals
[*]Chop / Caution — orange for chop regime and caution states
[*]Balance / Vector — purple for balance bands, Vector Line neutral state, and equilibrium elements
[*]SL Guide / TP Guide — stop and target circle colors
[*]Dash Text / Dash BG / Dash Header / Dash Section / Dash Frame — full dashboard color control
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔔 [b]Alert Conditions (5 total)[/b]

[b]Entry Alerts[/b]
[list]
[*]Vector Long — scalp long signal fired. Wick rejection entry confirmed with all regime and confluence conditions met
[*]Vector Short — scalp short signal fired
[/list]

[b]Regime Alerts[/b]
[list]
[*]Vector Chop Warning — market has entered Chop regime. Stand aside until regime clears
[*]Vector Trend Bull — market has transitioned to Trend Bull regime. Watch Vector Line for Setup A pullback opportunities
[*]Vector Trend Bear — market has transitioned to Trend Bear regime. Watch Vector Line for Setup A short pullback opportunities
[/list]

All alert messages are formatted as const strings for clean webhook and notification platform integration.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 [b]Recommended Settings by Instrument & Timeframe[/b]

The default configuration is optimized for [b]XAUUSD, major forex pairs, and crypto on M1–M5[/b]:
[list]
[*]Cooldown at 3 bars — fast timeframes produce setups in rapid succession. A 3-bar cooldown prevents back-to-back signals on consecutive bars while allowing reasonable signal frequency
[*]SL at 0.85× ATR — tight scalp stop anchored to the EMA 8 / Vector Line zone. The strict pin bar requirement ensures the signal bar's wick provides meaningful structural support, so the stop does not need to be large
[*]TP at 2.0R — on M1–M5 with a 0.85× ATR stop, 2.0R produces a tight, achievable target during normal trending conditions
[*]HTF at 60-minute — the standard intraday reference for M1–M5 scalping
[*]Volume at 1.05× average — a very low multiplier appropriate for scalping timeframes where volume spikes are smaller and entry bars do not always show dramatic volume expansion
[/list]

For other instruments or timeframes, adjust:
[list]
[*][b]M15–H1 intraday[/b] — increase ER Length to 14, increase Chop Length to 20, increase CI stand-aside to 62, increase ADX minimum to 22, increase Cooldown to 6, increase TP to 2.5–3.0R
[*][b]Crypto (BTC, ETH)[/b] — increase ATR Length to 20 for smoother ATR on high-volatility instruments, increase ER threshold to 0.40 for trend classification on more volatile assets
[*][b]Indices (NAS100, US30)[/b] — use session filter restricted to market hours, increase ADX minimum to 22, consider enabling Setup D for the sharper zero-cross moves typical of index momentum
[*][b]Fewer, higher-quality signals[/b] — raise Min Confluence to 5–6, increase ER trend minimum to 0.40, reduce CI stand-aside to 58, increase pullback touch tolerance slightly to 0.25 for tighter reference line proximity
[*][b]Higher signal frequency[/b] — lower Min Confluence to 3, enable Setup D, reduce cooldown to 2, disable HTF filter on fast timeframes where the 60-minute EMA can lag too much
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👥 [b]Who This Is For[/b]
[list]
[*]⚡ [b]Pure scalpers on M1–M5[/b] — VECTOR is the only indicator in the AlphaX suite specifically designed for sub-5-minute scalping. Every parameter — the pin bar standard, the wick entry reference, the tight ATR stop, the acceleration requirement, the anti-chase filter — is calibrated for fast-timeframe execution
[*]🧭 [b]Regime-aware traders[/b] — traders who understand that different market conditions require different strategies will immediately recognize the value of having the regime identified and the playbook selected automatically
[*]🎯 [b]Precision entry traders[/b] — the wick-entry reference and the strict pin bar requirements make VECTOR ideal for traders who want precise fill zones rather than market-on-close entries
[*]📊 [b]Traders who study market microstructure[/b] — the Efficiency Ratio, Choppiness Index, and KAMA components expose the internal mechanics of market character in ways that standard trend indicators do not
[*]🔴 [b]Traders who are burned by chasing[/b] — the anti-extension filter and RSI(7) gate are built specifically to stop the two most common scalping failures: entering too late after the move has already extended, and entering when momentum is actually exhausted
[*]⚠ [b]Traders who overtrade in choppy conditions[/b] — the Chop regime is the most powerful feature for discipline. When the dashboard shows ⛔ CHOP — STAND ASIDE, the system enforces what many traders cannot enforce themselves
[*]🏦 [b]Gold and forex scalpers[/b] — the default settings are calibrated for XAUUSD and major forex pairs, which exhibit the clearest regime cycling of any liquid instruments due to their session-driven institutional flows
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 [b]Notes[/b]
[list]
[*]All signals are confirmed on bar close — the indicator is non-repainting by design. All regime classification, Flow Vector, setup conditions, and confluence scoring finalize on confirmed bars only
[*]The KAMA Vector Line has a warm-up period equal to the KAMA Length setting. On charts with insufficient bar history, the Vector Line may not display correctly until enough bars accumulate
[*]The Efficiency Ratio and Choppiness Index require their full lookback periods to produce accurate readings. On charts with fewer bars than the longest lookback, readings may be imprecise during the initial warm-up period
[*]The anti-chase extension filter uses the distance from close to the Vector Line. In fast-moving scalp conditions, this filter can sometimes block entries that a discretionary trader would take. Increase the extension maximum if this becomes a frequent issue on your instrument
[*]The signal cooldown of 3 bars is deliberately short for scalping timeframes. On M1 charts, 3 bars = 3 minutes — sufficient to prevent back-to-back duplicate signals while allowing rapid sequential setups in trending conditions
[*]Setup D (Vector Shift) is off by default and is not recommended for M1–M5 scalping. Flow Vector zero-crosses on fast timeframes occur too frequently and with insufficient signal-to-noise ratio to be useful without additional filtering. Consider enabling it only on H1+ timeframes
[*]The balance bands in VECTOR are Bollinger-style ATR-smoothed bands used purely as visual references and Setup C trigger levels. They are not the same as the ANCHOR adaptive bands and do not produce trailing stop functionality
[*]The indicator does not track open positions or P&L and does not connect to any broker or account
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Disclaimer[/b]

This indicator is a technical analysis and visualization tool intended for educational and informational purposes only. It does not constitute financial advice or a recommendation to buy or sell any financial instrument. All signals are generated from historical and real-time price data using mathematical calculations — their accuracy or profitability is not guaranteed. Past performance of any signal type does not guarantee future results. Always conduct your own analysis, use proper risk management, and consult a licensed financial advisor before making any trading decisions. The author accepts no responsibility for any losses incurred from the use of this indicator.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[i]Built for scalpers who know that trading the wrong setup in the wrong regime is not a signal problem — it is a system architecture problem.[/i]

## Source Code

````pine
// © AlphaX — VECTOR v1.1
// Regime-Adaptive Flow Engine — scalping-optimized entries (micro pullback + impulse + range fade).
// AlphaX branded — styled after ANCHOR.

//@version=6
indicator("[ A L P H A X ] VECTOR - Regime-Adaptive Flow Engine", shorttitle="AlphaX VECTOR",
  overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=30, max_bars_back=500)

// ═══════════════════════════════════════════════════════════════════════════════
//  REGIME ENGINE
// ═══════════════════════════════════════════════════════════════════════════════
grpReg = "Regime Engine"
atrLen      = input.int(14, "ATR Length", minval=2, maxval=100, group=grpReg)
erLen       = input.int(10, "Efficiency Ratio Length", minval=5, maxval=50, group=grpReg,
  tooltip="Kaufman ER — high = directional trend, low = noisy chop.")
erTrendMin  = input.float(0.35, "ER Min for Trend Regime", minval=0.15, maxval=0.8, step=0.05, group=grpReg)
erChopMax   = input.float(0.22, "ER Max for Chop Regime", minval=0.05, maxval=0.35, step=0.01, group=grpReg)
chopLen     = input.int(14, "Choppiness Index Length", minval=5, maxval=50, group=grpReg)
chopMax     = input.float(61.0, "Chop Index — Stand Aside Above", minval=50, maxval=75, step=0.5, group=grpReg)
adxLen      = input.int(14, "ADX Length", minval=5, maxval=50, group=grpReg)
adxTrendMin = input.float(20.0, "ADX Min for Trend", minval=12, maxval=40, step=0.5, group=grpReg)
bbLen       = input.int(20, "Balance Band Length", minval=10, maxval=100, group=grpReg)
bbMult      = input.float(2.0, "Balance Band Mult", minval=1.0, maxval=3.0, step=0.1, group=grpReg)

// ═══════════════════════════════════════════════════════════════════════════════
//  FLOW VECTOR
// ═══════════════════════════════════════════════════════════════════════════════
grpFlow = "Flow Vector"
kamaLen     = input.int(21, "Vector Line (KAMA) Length", minval=5, maxval=100, group=grpFlow)
kamaFast    = input.int(2,  "KAMA Fast", minval=2, maxval=10, group=grpFlow)
kamaSlow    = input.int(30, "KAMA Slow", minval=10, maxval=50, group=grpFlow)
obvLen      = input.int(10, "OBV Slope Length", minval=3, maxval=30, group=grpFlow)
deltaLen    = input.int(14, "Volume Delta Length", minval=3, maxval=50, group=grpFlow)
vectorStrong = input.float(40.0, "Strong Vector Threshold", minval=20, maxval=70, step=5, group=grpFlow,
  tooltip="Absolute flow vector above this = strong directional bias.")
vectorExtreme = input.float(65.0, "Extreme Vector (range fade)", minval=45, maxval=90, step=5, group=grpFlow)

// ═══════════════════════════════════════════════════════════════════════════════
//  ENTRIES & CONFLUENCE
// ═══════════════════════════════════════════════════════════════════════════════
grpEntry = "Entries & Confluence (Scalping)"
enableTrendResume = input.bool(true, "Setup A · Trend Micro-Pullback", group=grpEntry,
  tooltip="Trend regime — dip to EMA8 / Vector line, rejection close, flow accelerating. Core scalp entry.")
enableScalpImpulse = input.bool(true, "Setup B · Micro Impulse Break", group=grpEntry,
  tooltip="Break 4-bar micro swing with body + volume delta — momentum continuation scalp.")
enableRangeFade   = input.bool(true, "Setup C · Range Fade (band extreme)", group=grpEntry,
  tooltip="Balance regime only — fade outer band when flow vector is exhausted.")
enableVectorShift = input.bool(false, "Setup D · Vector Shift (legacy)", group=grpEntry,
  tooltip="Flow zero-cross — noisy on fast TFs. Off by default; use Micro Impulse instead.")
pullbackAtr   = input.float(0.22, "Pullback Touch Tolerance (xATR)", minval=0.08, maxval=0.8, step=0.02, group=grpEntry)
shiftBodyAtr  = input.float(0.55, "Impulse Min Body (xATR)", minval=0.25, maxval=1.5, step=0.05, group=grpEntry)
extensionMaxAtr = input.float(1.0, "Max Extension from Vector (xATR)", minval=0.4, maxval=2.5, step=0.1, group=grpEntry,
  tooltip="Blocks chasing — no long if price is already stretched above vector line by this much.")
impulseLookback = input.int(4, "Micro Swing Lookback", minval=2, maxval=8, group=grpEntry)
minConf       = input.int(4, "Min Confluence Layers (of 7)", minval=3, maxval=7, group=grpEntry)
showSignals   = input.bool(true, "Show Entry Signals", group=grpEntry)
showConfLbl   = input.bool(true, "Show Confluence Label", group=grpEntry)
cooldown      = input.int(3, "Signal Cooldown (bars)", minval=1, maxval=50, group=grpEntry)

// ═══════════════════════════════════════════════════════════════════════════════
//  FILTERS
// ═══════════════════════════════════════════════════════════════════════════════
grpFilt = "Filters"
useHtf      = input.bool(true, "HTF Trend Filter", group=grpFilt)
htfTf       = input.timeframe("60", "HTF Timeframe", group=grpFilt)
htfFast     = input.int(21, "HTF Fast EMA", minval=5, maxval=100, group=grpFilt)
htfSlow     = input.int(55, "HTF Slow EMA", minval=10, maxval=200, group=grpFilt)
useVol      = input.bool(true, "Volume Confirm", group=grpFilt)
volMult     = input.float(1.05, "Min Volume vs Avg", minval=0.8, maxval=3.0, step=0.05, group=grpFilt)
volLen      = input.int(20, "Volume Avg Length", minval=5, maxval=100, group=grpFilt)
useSession  = input.bool(false, "Session Filter", group=grpFilt)
sessStart   = input.session("0700-2000", "Active Session", group=grpFilt)

// ═══════════════════════════════════════════════════════════════════════════════
//  EXIT GUIDANCE
// ═══════════════════════════════════════════════════════════════════════════════
grpExit = "Exit Guidance"
showExits   = input.bool(true, "Show SL / TP Guides", group=grpExit)
slAtrMult   = input.float(0.85, "SL Distance (xATR)", minval=0.3, maxval=5.0, step=0.1, group=grpExit)
tpRR        = input.float(2.0, "TP Reward (R)", minval=0.5, maxval=20, step=0.5, group=grpExit)

// ═══════════════════════════════════════════════════════════════════════════════
//  DISPLAY
// ═══════════════════════════════════════════════════════════════════════════════
grpVis = "Display"
showVectorLn  = input.bool(true, "Show Vector Line (KAMA)", group=grpVis)
showBalanceBB = input.bool(true, "Show Balance Bands", group=grpVis)
showRegimeLbl = input.bool(false, "Show Regime Change Labels", group=grpVis,
  tooltip="Off by default — regime is shown on dashboard.")
showDash      = input.bool(true, "Show Dashboard", group=grpVis)
dashPos       = input.string("Top Right", "Dashboard Position",
  options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=grpVis)

// ═══════════════════════════════════════════════════════════════════════════════
//  COLORS (ANCHOR palette)
// ═══════════════════════════════════════════════════════════════════════════════
grpColors = "Colors"
colBull       = input.color(#c8e624, "Bull",               group=grpColors)
colBullBr     = input.color(#d4f03a, "Bull Bright",        group=grpColors)
colBear       = input.color(#ff1744, "Bear",               group=grpColors)
colBearBr     = input.color(#ff5252, "Bear Bright",        group=grpColors)
colSqueeze    = input.color(#ff9800, "Chop / Caution",     group=grpColors)
colNeutral    = input.color(#555555, "Neutral",            group=grpColors)
colEqLine     = input.color(#8b6fd0, "Balance / Vector",   group=grpColors)
colSlLine     = input.color(#ff1744, "SL Guide",           group=grpColors)
colTpLine     = input.color(#c8e624, "TP Guide",           group=grpColors)
colTextLt     = input.color(#cccccc, "Dash Text",          group=grpColors)
colDashBg     = input.color(#1a1a1a, "Dash BG",            group=grpColors)
colDashHeader = input.color(#111111, "Dash Header BG",     group=grpColors)
colDashSec    = input.color(#222222, "Dash Section BG",    group=grpColors)
colDashFrame  = input.color(#c8e624, "Dash Frame",         group=grpColors)

// ═══════════════════════════════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════════════════════════════
getDashPos(p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        => position.bottom_right

f_adx(len) =>
    float up   = ta.change(high)
    float down = -ta.change(low)
    float plusDM  = up > down and up > 0 ? up : 0.0
    float minusDM = down > up and down > 0 ? down : 0.0
    float trVal   = ta.tr(true)
    float trRma   = ta.rma(trVal, len)
    float plusRma  = trRma != 0 ? 100 * ta.rma(plusDM, len) / trRma : 0.0
    float minusRma = trRma != 0 ? 100 * ta.rma(minusDM, len) / trRma : 0.0
    float sumDM = plusRma + minusRma
    float dx = sumDM != 0 ? 100 * math.abs(plusRma - minusRma) / sumDM : 0.0
    ta.rma(dx, len)

f_kama(src, length, fast, slow) =>
    float change = math.abs(src - src[length])
    float vol = 0.0
    for i = 0 to length - 1
        vol += math.abs(src[i] - src[i + 1])
    float er = vol != 0 ? change / vol : 0.0
    float sc = math.pow(er * (2.0 / (fast + 1) - 2.0 / (slow + 1)) + 2.0 / (slow + 1), 2)
    var float k = src
    k := nz(k[1], src) + sc * (src - nz(k[1], src))
    k

// ═══════════════════════════════════════════════════════════════════════════════
//  CORE METRICS
// ═══════════════════════════════════════════════════════════════════════════════
atrVal = ta.atr(atrLen)
volMa  = ta.sma(volume, volLen)
rng    = math.max(high - low, syminfo.mintick)

// Efficiency ratio (regime)
float erChange = math.abs(close - close[erLen])
float erVol    = math.sum(math.abs(close - close[1]), erLen)
float effRatio = erVol != 0 ? erChange / erVol : 0.0

// Choppiness index
float ciSum = math.sum(ta.atr(1), chopLen)
float ciHl  = ta.highest(high, chopLen) - ta.lowest(low, chopLen)
float chopIdx = ciHl > 0 ? 100.0 * math.log10(ciSum / ciHl) / math.log10(chopLen) : 50.0

adxVal = f_adx(adxLen)

// Balance bands
bbBasis = ta.sma(close, bbLen)
bbDev   = bbMult * ta.stdev(close, bbLen)
bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev

// Vector line
vectorLine = f_kama(close, kamaLen, kamaFast, kamaSlow)
vecSlopeUp   = vectorLine > vectorLine[1]
vecSlopeDown = vectorLine < vectorLine[1]

// EMA stack
ema8  = ta.ema(close, 8)
ema21 = ta.ema(close, 21)
ema50 = ta.ema(close, 50)
stackBull = ema8 > ema21 and ema21 > ema50
stackBear = ema8 < ema21 and ema21 < ema50

// OBV slope
obvVal = ta.obv
obvSlope = (obvVal - obvVal[obvLen]) / obvLen

// Volume delta
bullVol = rng != 0 ? volume * (close - low) / rng : volume * 0.5
bearVol = volume - bullVol
volDelta = ta.ema(bullVol, deltaLen) - ta.ema(bearVol, deltaLen)

// HTF
htfClose = request.security(syminfo.tickerid, htfTf, close, barmerge.gaps_off, barmerge.lookahead_off)
htfFastE = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfFast), barmerge.gaps_off, barmerge.lookahead_off)
htfSlowE = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfSlow), barmerge.gaps_off, barmerge.lookahead_off)
htfBull  = htfFastE > htfSlowE and htfClose > htfFastE
htfBear  = htfFastE < htfSlowE and htfClose < htfFastE
htfOKLong  = not useHtf or htfBull
htfOKShort = not useHtf or htfBear
volOK = not useVol or volume >= volMa * volMult
inSession = not useSession or not na(time(timeframe.period, sessStart))

// ── Flow vector (-100 … +100) ─────────────────────────────────────────────────
float flowVec = 0.0
flowVec += stackBull ? 22.0 : stackBear ? -22.0 : close > ema21 ? 8.0 : close < ema21 ? -8.0 : 0.0
flowVec += vecSlopeUp ? 18.0 : vecSlopeDown ? -18.0 : 0.0
flowVec += obvSlope > 0 ? 15.0 : obvSlope < 0 ? -15.0 : 0.0
flowVec += volDelta > 0 ? 12.0 : volDelta < 0 ? -12.0 : 0.0
flowVec += htfBull ? 18.0 : htfBear ? -18.0 : 0.0
flowVec += close > vectorLine ? 15.0 : close < vectorLine ? -15.0 : 0.0
flowVec := math.max(-100.0, math.min(100.0, flowVec))

bool vecBull = flowVec >= vectorStrong
bool vecBear = flowVec <= -vectorStrong
bool vecExtBull = flowVec >= vectorExtreme
bool vecExtBear = flowVec <= -vectorExtreme

// ── Regime state machine: 0=CHOP 1=TREND BULL 2=TREND BEAR 3=BALANCE ─────────
var int regime = 3
int prevRegime = regime

bool isChop = chopIdx >= chopMax or (effRatio <= erChopMax and adxVal < adxTrendMin)
bool isTrendBull = not isChop and adxVal >= adxTrendMin and effRatio >= erTrendMin and flowVec > 20 and close > vectorLine
bool isTrendBear = not isChop and adxVal >= adxTrendMin and effRatio >= erTrendMin and flowVec < -20 and close < vectorLine

if isChop
    regime := 0
else if isTrendBull
    regime := 1
else if isTrendBear
    regime := 2
else
    regime := 3

bool regimeChange = regime != prevRegime

// ── Scalping candle quality (pin-bar rejection) ───────────────────────────────
bodySz    = math.abs(close - open)
upperWick = high - close
lowerWick = close - low
closeInUpperQ = close >= high - rng * 0.28
closeInLowerQ = close <= low + rng * 0.28

scalpBullBar = close > open and lowerWick >= rng * 0.42 and upperWick <= rng * 0.32 and
     bodySz >= atrVal * 0.10 and closeInUpperQ
scalpBearBar = close < open and upperWick >= rng * 0.42 and lowerWick <= rng * 0.32 and
     bodySz >= atrVal * 0.10 and closeInLowerQ

// Legacy triggers (vector shift only)
bullTrig = scalpBullBar
bearTrig = scalpBearBar
strongBull = scalpBullBar and bodySz >= shiftBodyAtr * atrVal
strongBear = scalpBearBar and bodySz >= shiftBodyAtr * atrVal

// Flow momentum — scalps need acceleration, not stale drift
flowAccelBull = flowVec > flowVec[1] and flowVec[1] >= flowVec[2]
flowAccelBear = flowVec < flowVec[1] and flowVec[1] <= flowVec[2]

// RSI micro filter (fast, avoids overbought chase / oversold knife)
rsi7 = ta.rsi(close, 7)
rsiOkLong  = rsi7 > 40 and rsi7 < 70
rsiOkShort = rsi7 < 60 and rsi7 > 30

float touchTol = atrVal * pullbackAtr
bool touchEmaLong  = low <= ema8 + touchTol and close > ema8
bool touchEmaShort = high >= ema8 - touchTol and close < ema8
bool touchVecLong  = low <= vectorLine + touchTol and close > vectorLine
bool touchVecShort = high >= vectorLine - touchTol and close < vectorLine

// Anti-chase: recent dip / rally into the line
dipIntoLong  = ta.lowest(low, 5) <= math.min(ema8, vectorLine) + atrVal * 0.18
ripIntoShort = ta.highest(high, 5) >= math.max(ema8, vectorLine) - atrVal * 0.18
notExtendedLong  = close - vectorLine <= atrVal * extensionMaxAtr
notExtendedShort = vectorLine - close <= atrVal * extensionMaxAtr

// Micro structure break (impulse scalp)
microHi = ta.highest(high[1], impulseLookback)
microLo = ta.lowest(low[1], impulseLookback)
impulseLong  = close > microHi and close[1] <= microHi and bodySz >= shiftBodyAtr * atrVal * 0.85
impulseShort = close < microLo and close[1] >= microLo and bodySz >= shiftBodyAtr * atrVal * 0.85

// Vector shift (legacy — gated off by default)
bool vecCrossUp = ta.crossover(flowVec, 0)
bool vecCrossDn = ta.crossunder(flowVec, 0)

// Range fade: band touch + vector exhaustion
bool atUpperBand = high >= bbUpper - atrVal * 0.08
bool atLowerBand = low <= bbLower + atrVal * 0.08
bool vecFadeBear = flowVec < flowVec[1] and flowVec[1] > vectorExtreme - 12
bool vecFadeBull = flowVec > flowVec[1] and flowVec[1] < -vectorExtreme + 12

// ═══════════════════════════════════════════════════════════════════════════════
//  SETUPS — scalping playbooks (regime-gated)
// ═══════════════════════════════════════════════════════════════════════════════
setupTrendLong = enableTrendResume and regime == 1 and vecBull and flowAccelBull and
     (touchEmaLong or touchVecLong) and scalpBullBar and dipIntoLong and notExtendedLong and rsiOkLong

setupTrendShort = enableTrendResume and regime == 2 and vecBear and flowAccelBear and
     (touchEmaShort or touchVecShort) and scalpBearBar and ripIntoShort and notExtendedShort and rsiOkShort

setupImpulseLong = enableScalpImpulse and (regime == 1 or regime == 3) and impulseLong and
     flowVec > vectorStrong * 0.65 and volDelta > 0 and scalpBullBar and htfOKLong and notExtendedLong

setupImpulseShort = enableScalpImpulse and (regime == 2 or regime == 3) and impulseShort and
     flowVec < -vectorStrong * 0.65 and volDelta < 0 and scalpBearBar and htfOKShort and notExtendedShort

setupFadeShort = enableRangeFade and regime == 3 and atUpperBand and (vecExtBull or vecFadeBear) and
     scalpBearBar and rsi7 > 58

setupFadeLong = enableRangeFade and regime == 3 and atLowerBand and (vecExtBear or vecFadeBull) and
     scalpBullBar and rsi7 < 42

setupShiftLong  = enableVectorShift and not isChop and vecCrossUp and strongBull and volDelta > 0 and htfOKLong
setupShiftShort = enableVectorShift and not isChop and vecCrossDn and strongBear and volDelta < 0 and htfOKShort

// Confluence — setup-weighted for scalping (max 7)
int bullScore = (setupTrendLong or setupImpulseLong ? 2 : setupFadeLong or setupShiftLong ? 1 : 0) +
     (flowAccelBull ? 1 : 0) + (htfOKLong ? 1 : 0) + (volOK ? 1 : 0) +
     (not isChop ? 1 : 0) + (rsiOkLong ? 1 : 0)
int bearScore = (setupTrendShort or setupImpulseShort ? 2 : setupFadeShort or setupShiftShort ? 1 : 0) +
     (flowAccelBear ? 1 : 0) + (htfOKShort ? 1 : 0) + (volOK ? 1 : 0) +
     (not isChop ? 1 : 0) + (rsiOkShort ? 1 : 0)

var int lastSigBar = na
bool cooled = na(lastSigBar) or bar_index - lastSigBar >= cooldown

bool setupLong  = setupTrendLong or setupImpulseLong or setupFadeLong or setupShiftLong
bool setupShort = setupTrendShort or setupImpulseShort or setupFadeShort or setupShiftShort

bool bullSignal = showSignals and barstate.isconfirmed and setupLong and bullScore >= minConf and
     inSession and cooled and volOK and not isChop
bool bearSignal = showSignals and barstate.isconfirmed and setupShort and bearScore >= minConf and
     inSession and cooled and volOK and not isChop

if bullSignal or bearSignal
    lastSigBar := bar_index

// Entry reference = rejection wick (scalp fill zone)
float entryPx = na
float slGuide = na
float tpGuide = na
if bullSignal
    entryPx := low
    slGuide := math.min(low, math.min(ema8, vectorLine)) - slAtrMult * atrVal
    float risk = entryPx - slGuide
    tpGuide := risk > 0 ? entryPx + risk * tpRR : entryPx + atrVal * tpRR
if bearSignal
    entryPx := high
    slGuide := math.max(high, math.max(ema8, vectorLine)) + slAtrMult * atrVal
    float riskS = slGuide - entryPx
    tpGuide := riskS > 0 ? entryPx - riskS * tpRR : entryPx - atrVal * tpRR

// ═══════════════════════════════════════════════════════════════════════════════
//  VISUALS
// ═══════════════════════════════════════════════════════════════════════════════
color vecCol = flowVec >= vectorStrong ? colBull : flowVec <= -vectorStrong ? colBear :
     flowVec > 0 ? color.new(colBull, 40) : flowVec < 0 ? color.new(colBear, 40) : colNeutral

plot(showVectorLn ? vectorLine : na, "Vector Line", color=color.new(vecCol, 15), linewidth=2)
plot(showBalanceBB ? bbUpper : na, "Balance Upper", color=color.new(colEqLine, 70), linewidth=1, style=plot.style_linebr)
plot(showBalanceBB ? bbLower : na, "Balance Lower", color=color.new(colEqLine, 70), linewidth=1, style=plot.style_linebr)
plot(showBalanceBB ? bbBasis : na, "Balance Mid", color=color.new(colEqLine, 85), linewidth=1, style=plot.style_linebr)

plot(showExits and not na(slGuide) ? slGuide : na, "SL Guide", color=color.new(colSlLine, 25), linewidth=1, style=plot.style_circles)
plot(showExits and not na(tpGuide) ? tpGuide : na, "TP Guide", color=color.new(colTpLine, 25), linewidth=1, style=plot.style_circles)
plot(showExits and not na(entryPx) ? entryPx : na, "Entry Ref", color=color.new(colBull, 50), linewidth=2, style=plot.style_cross)

// Pin triangles to rejection wick — actual scalp entry zone
if bullSignal
    string bTag = setupTrendLong ? "A" : setupImpulseLong ? "B" : setupFadeLong ? "C" : "D"
    label.new(bar_index, low, "▲", style=label.style_label_up, color=color.new(colBull, 10),
      textcolor=colBull, size=size.small, tooltip="SCALP LONG [" + bTag + "] @ wick")
if bearSignal
    string sTag = setupTrendShort ? "A" : setupImpulseShort ? "B" : setupFadeShort ? "C" : "D"
    label.new(bar_index, high, "▼", style=label.style_label_down, color=color.new(colBear, 10),
      textcolor=colBear, size=size.small, tooltip="SCALP SHORT [" + sTag + "] @ wick")

if showRegimeLbl and regimeChange and barstate.isconfirmed and regime != 0
    string rTxt = regime == 1 ? "TREND ▲" : regime == 2 ? "TREND ▼" : "BALANCE"
    color rCol = regime == 1 ? colBull : regime == 2 ? colBear : colEqLine
    label.new(bar_index, high + atrVal * 0.3, rTxt, color=color.new(rCol, 80), textcolor=rCol, style=label.style_label_down, size=size.tiny)

if showConfLbl and barstate.islast and not isChop
    string confTxt = "B " + str.tostring(bullScore) + "/7  ·  S " + str.tostring(bearScore) + "/7"
    color confCol = bullScore >= minConf ? colBull : bearScore >= minConf ? colBear : colNeutral
    label.new(bar_index, vectorLine, confTxt, color=color.new(colDashBg, 10),
      textcolor=confCol, style=label.style_label_left, size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════
var table dash = na
if showDash
    dash := table.new(getDashPos(dashPos), 2, 17,
      bgcolor=color.new(colDashBg, 0), border_width=1, border_color=color.new(colNeutral, 60),
      frame_width=2, frame_color=color.new(colDashFrame, 50))

string regimeTxt = regime == 0 ? "⛔ CHOP — STAND ASIDE" : regime == 1 ? "▲ TREND BULL" : regime == 2 ? "▼ TREND BEAR" : "◆ BALANCE / RANGE"
color  regimeCol = regime == 0 ? colSqueeze : regime == 1 ? colBull : regime == 2 ? colBear : colEqLine

string playbookTxt = regime == 0 ? "NO TRADES" : regime == 1 ? "SCALP PULLBACK ▲" : regime == 2 ? "SCALP PULLBACK ▼" : "SCALP FADE / BREAK"
string vecTxt = (flowVec >= 0 ? "+" : "") + str.tostring(math.round(flowVec))

if showDash and barstate.islast
    color dbg   = color.new(colDashBg, 0)
    color secBg = color.new(colDashSec, 0)

    table.cell(dash, 0, 0, "AlphaX VECTOR", text_color=colBull, text_size=size.normal,
      bgcolor=color.new(colDashHeader, 0), text_halign=text.align_center)
    table.cell(dash, 1, 0, "v1.1", text_color=color.new(colBull, 30), text_size=size.tiny,
      bgcolor=color.new(colDashHeader, 0), text_halign=text.align_center)

    table.cell(dash, 0, 1, "─── REGIME ───", text_color=color.new(colNeutral, 20),
      text_size=size.tiny, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 1, "", bgcolor=secBg)

    table.cell(dash, 0, 2, "MARKET REGIME", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 2, regimeTxt, text_color=regimeCol, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 3, "PLAYBOOK", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 3, playbookTxt, text_color=regimeCol, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 4, "FLOW VECTOR", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 4, vecTxt, text_color=flowVec >= vectorStrong ? colBull : flowVec <= -vectorStrong ? colBear : colTextLt,
      text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 5, "─── METRICS ───", text_color=color.new(colNeutral, 20),
      text_size=size.tiny, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 5, "", bgcolor=secBg)

    table.cell(dash, 0, 6, "EFFICIENCY", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 6, str.tostring(effRatio, "#.##"), text_color=effRatio >= erTrendMin ? colBull : effRatio <= erChopMax ? colSqueeze : colTextLt,
      text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 7, "CHOP INDEX", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 7, str.tostring(chopIdx, "#.#"), text_color=chopIdx >= chopMax ? colSqueeze : colTextLt,
      text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 8, "ADX", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 8, str.tostring(adxVal, "#.#"), text_color=adxVal >= adxTrendMin ? colBull : colTextLt,
      text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 9, "VOL DELTA", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 9, volDelta > 0 ? "▲ BUYERS" : "▼ SELLERS",
      text_color=volDelta > 0 ? colBull : colBear, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 10, "─── FILTERS ───", text_color=color.new(colNeutral, 20),
      text_size=size.tiny, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 10, "", bgcolor=secBg)

    table.cell(dash, 0, 11, "HTF BIAS", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 11, htfBull ? "▲ BULL" : htfBear ? "▼ BEAR" : "— FLAT",
      text_color=htfBull ? colBull : htfBear ? colBear : colNeutral, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 12, "SESSION", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 12, inSession ? "✓ ACTIVE" : "✗ OFF",
      text_color=inSession ? colBull : colBear, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 13, "─── CONFLUENCE ───", text_color=color.new(colNeutral, 20),
      text_size=size.tiny, bgcolor=secBg, text_halign=text.align_center)
    table.cell(dash, 1, 13, "", bgcolor=secBg)

    table.cell(dash, 0, 14, "BULL SCORE", text_color=colTextLt, text_size=size.small,
      bgcolor=bullScore >= minConf and not isChop ? color.new(colBull, 88) : dbg)
    table.cell(dash, 1, 14, str.tostring(bullScore) + "/7" + (bullScore >= minConf and not isChop ? " ✓" : ""),
      text_color=bullScore >= minConf and not isChop ? colBull : colNeutral, text_size=size.small,
      bgcolor=bullScore >= minConf and not isChop ? color.new(colBull, 88) : dbg)

    table.cell(dash, 0, 15, "BEAR SCORE", text_color=colTextLt, text_size=size.small,
      bgcolor=bearScore >= minConf and not isChop ? color.new(colBear, 88) : dbg)
    table.cell(dash, 1, 15, str.tostring(bearScore) + "/7" + (bearScore >= minConf and not isChop ? " ✓" : ""),
      text_color=bearScore >= minConf and not isChop ? colBear : colNeutral, text_size=size.small,
      bgcolor=bearScore >= minConf and not isChop ? color.new(colBear, 88) : dbg)

    table.cell(dash, 0, 16, "VECTOR LINE", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 16, str.tostring(vectorLine, format.mintick), text_color=vecCol, text_size=size.small, bgcolor=dbg)

// ═══════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
alertcondition(bullSignal, title="Vector Long",
  message="[AlphaX VECTOR] SCALP LONG on {{ticker}} {{interval}} — wick rejection entry.")
alertcondition(bearSignal, title="Vector Short",
  message="[AlphaX VECTOR] SCALP SHORT on {{ticker}} {{interval}} — wick rejection entry.")
alertcondition(regime == 0 and prevRegime != 0, title="Vector Chop Warning",
  message="[AlphaX VECTOR] CHOP regime — stand aside on {{ticker}}.")
alertcondition(regimeChange and regime == 1, title="Vector Trend Bull",
  message="[AlphaX VECTOR] Trend BULL regime — watch vector line pullbacks.")
alertcondition(regimeChange and regime == 2, title="Vector Trend Bear",
  message="[AlphaX VECTOR] Trend BEAR regime — watch vector line pullbacks.")
````

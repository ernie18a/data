# MTF Kinetic Oscillator | Rainbow Matrix

- url: https://www.tradingview.com/script/XH3duGHt-MTF-Kinetic-Oscillator-Rainbow-Matrix/
- type: indicator
- pine_id: PUB;075559a4758b47a992063da20b82dffe
- version: 2.0

## Description

GENERAL OVERVIEW
The MTF Kinetic Oscillator is a multi-timeframe order-flow probability oscillator that fuses 5 timeframes into a single composite score, blended with three independent order-flow sensors (CVD, Volume Climax, Squeeze) and plotted against a self-adaptive Fibonacci channel that recalibrates to current volatility conditions. Instead of treating an oscillator as a fixed 0-100 envelope where the same threshold means the same thing across all market regimes, the indicator continuously classifies the current score against an adaptive channel — and colors the chart accordingly.

The main goal of this indicator is to give traders a clean, automatic read on where the order-flow consensus sits across 5 timeframes simultaneously, and how stretched that consensus is relative to its own recent statistical range — without having to manually monitor multiple oscillators on multiple timeframes. Every value the oscillator displays is the result of a weighted aggregation of 5 timeframe scores, modulated by order-flow sensors, and contextualized against an adaptive channel.

It plots a single score line that travels through five color zones (yellow, orange, red, purple for upper extremes; green, teal, blue, aqua for lower extremes), each corresponding to a probabilistic regime. Combined with the Info Panel HUD, Vacuum Trail convergence lines, and Black Swan dynamic glow, the indicator gives a complete read on order-flow direction, statistical position, and proximity to exhaustion zones — all from a single oscillator pane.

This indicator was developed for traders who already understand oscillator-based indicators (RSI, MFI, Stochastic, CCI) and want a multi-timeframe aggregation that calibrates its thresholds to current volatility instead of using fixed 0-100 boundaries.

[image]https://www.tradingview.com/x/z2oY0B4i/[/image]

WHAT IS THE THEORY BEHIND THIS INDICATOR?
Most oscillators on TradingView — RSI, MFI, CCI, Stochastic, and their derivatives — share two common architectural choices: they operate on a single timeframe, and they classify against fixed thresholds (typically 70/30 or 80/20). This treats every market regime as statistically equivalent.

The problem: market regimes are not equivalent. A score of 75 during a tight-range, low-volatility period is structurally different from a score of 75 during a volatile expansion phase. Fixed thresholds applied to a non-stationary distribution produce systematic mismatches — overbought readings that resolve into further upside, oversold readings that continue lower, signals that appear at the wrong moments precisely when volatility shifts regimes. This mismatch becomes most visible during transitions between volatility regimes: trend climaxes, capitulation lows, squeeze breakouts.

This indicator addresses both issues at once. First, the per-timeframe score is built from a Log-Normal Z-Score regression of price (which respects the asymmetric distribution of returns) blended with RSI through a sigmoid normalization. Second, the 5 per-timeframe scores are aggregated through Fibonacci weights (0.15 / 0.20 / 0.25 / 0.25 / 0.15) into a single global score — giving the most weight to the middle macro horizons rather than the shortest or longest timeframes. Third, the global score is plotted not against fixed 0-100 thresholds, but against a self-adaptive channel whose boundaries are re-computed every bar from the highest and lowest scores in the lookback window, smoothed by EMA, and proportioned by Fibonacci ratios (1.50/1.85, 1.85/1.85, 2.75/1.85, 3.85/1.85).

The three order-flow sensors — CVD Z-Score, Volume Climax, and Squeeze — operate as modulators of the base score: the CVD bonus amplifies the score when directional order pressure dominates (clamped at ±12 points), Volume Climax drag dampens the score when abnormal volume is detected (statistical exhaustion signal), and the Squeeze damper compresses score amplitude to 25% during compressed-volatility regimes (suppressing false signals during low-conviction lateral phases).

Why traders use it: each color zone on the chart represents a different probabilistic regime, calibrated to current volatility. When the score sits between the median and the inner band (yellow/green), the order-flow consensus is in normal operating range — equilibrium. When the score crosses into the second band (orange/teal), the move has crossed into directional territory. The third band (red/blue) marks the threshold beyond which most of the impulse has already happened — exhaustion. The fourth band (purple/aqua) marks the tail of the distribution — a Black Swan event in Taleb's sense — where score positions rarely persist under normal volatility conditions.

The three order-flow sensors and the adaptive Fibonacci channel are not independent layers stacked in the same pane. They map three different aspects of the same question: where the multi-timeframe order-flow consensus currently sits (the score), how that consensus is being modulated by live order-flow pressure (the sensors), and how stretched that modulated value is relative to its own recent statistical range (the channel). The integration of all three components into a single oscillator is the reason they exist in one script rather than as three separate indicators: the cross-component blending is what surfaces multi-sensor confluence that separate-script approaches cannot produce.

MTF KINETIC OSCILLATOR FEATURES

The indicator includes 6 main features:
Multi-Timeframe Score Engine
CVD Order-Flow Sensor
Volume Climax and Squeeze Sensors
Adaptive Fibonacci Channel
Vacuum Trail and Black Swan Dynamic Glow
Info Panel HUD and Alerts

Multilingual interface and full customization across all visual layers.

MULTI-TIMEFRAME SCORE ENGINE
🔹 What It Does
The core of the indicator. For each of the 5 configured radar timeframes, the engine performs three operations:
◇ Calculates a Log-Normal Z-Score regression of price (hlc3 transformed via natural logarithm, fitted with linear regression, residuals normalized by their own standard deviation).
◇ Computes a per-timeframe RSI at a Fibonacci-aligned length (8, 13, 21, 34, 55 — one per timeframe).
◇ Blends the Z-Score (via sigmoid normalization) and the RSI into a single per-timeframe score, bounded 0-100.

The 5 per-timeframe scores are then aggregated through Fibonacci weights (0.15 / 0.20 / 0.25 / 0.25 / 0.15) into a single global score representing the multi-horizon order-flow consensus.

🔹 Method
The regression runs in log space, addressing the asymmetric nature of price distribution that linear estimators (such as the Simple Moving Average) fail to account for. The directional reference (high vs low) is selected per bar based on candle direction — green candles use the high (upward pressure reference), red candles use the low (downward pressure reference). This produces a Z-Score that reflects the directional intent of each bar rather than the midpoint average.

The sigmoid normalization compresses Z-Scores into a bounded 0-100 range without losing the asymmetric information of extreme values. The RSI component anchors the score to a familiar momentum reference, blending two independent signal families into one bounded value per timeframe.

🔹 Hierarchical Weighting
The five timeframes are weighted by structural significance using Fibonacci proportions:
◇ TF1 (Trigger, default 5): weight 15% — fastest reactivity, lowest weight.
◇ TF2 (Intraday, default 13): weight 20% — session-scale resolution.
◇ TF3 (Macro 1, default 55): weight 25% — backbone of the score.
◇ TF4 (Macro 2, default 233): weight 25% — institutional reference horizon.
◇ TF5 (Base, default 987): weight 15% — macro trend anchor.

The middle horizons (TF3 and TF4) carry the highest weight because they typically represent the most structurally significant reference for institutional decision-making — short enough to react to current conditions, long enough to filter intraday noise.

CVD ORDER-FLOW SENSOR
🔹 What It Does
The CVD (Cumulative Volume Delta) sensor estimates the difference between buyer and seller volume per bar — measuring market-order aggression. The signed delta is normalized to a Z-Score against a 50-period rolling reference, and the resulting bonus is clamped at ±12 points before being added to the global score.

🔹 Method
For each bar, total volume is split between buyer share (proportional to `close - low / range`) and seller share (proportional to `high - close / range`). The signed delta is the difference. A 50-period mean and standard deviation define the reference; the current delta is expressed as a Z-Score against that reference, then multiplied by 4 and clamped to ±12 to control its contribution to the final score.

🔹 Why It Matters
The Z-Score component answers "where is the multi-timeframe consensus", and the RSI component answers "what is the momentum". The CVD sensor answers a separate question: "who is currently aggressive in the order book". When the multi-timeframe consensus is bullish and CVD aggression confirms it, the bonus amplifies the score. When the consensus is bullish but CVD shows seller aggression, the bonus subtracts from the score — surfacing a divergence between consensus and order-flow.

VOLUME CLIMAX AND SQUEEZE SENSORS
🔹 Volume Climax
A standalone sensor that detects abnormal volume conditions (volume Z-Score above 3.0). When triggered, a climax drag is applied to the score, signaling potential exhaustion. The HUD reports this state explicitly in the Status row.

🔹 Squeeze
A volatility-compression detector based on the percentage-rank of the current range against a 20-period lookback. When the range compresses to its 15th percentile or lower, the squeeze flag activates and the score amplitude is dampened to 25% of its normal range — preventing false directional signals during compressed-volatility regimes.

🔹 Why They Matter
These sensors operate on a different axis from the price-direction sensors. Volume Climax surfaces statistical exhaustion before it becomes visible in price; Squeeze suppresses noise during periods when the oscillator would otherwise produce false reads. Together they make the oscillator behave correctly during regime transitions, where standard oscillators are typically least reliable.

ADAPTIVE FIBONACCI CHANNEL
🔹 What It Does
The global score is plotted against a self-adaptive channel rather than against fixed 0-100 thresholds. The channel boundaries are re-computed every bar from the highest and lowest scores in a 50-bar lookback window, smoothed by 10-period EMA, and then proportioned through Fibonacci ratios into four zones:
◇ Z-Breathing (inner, yellow/green) — ratio 1.50 / 1.85 (≈ 0.811)
◇ Z-Alert (upper limit, orange/teal) — ratio 1.85 / 1.85 = 1.000 (the visible anchor)
◇ Z-Exhaustion (outer, red/blue) — ratio 2.75 / 1.85 (≈ 1.486)
◇ Black Swan (extreme edge, purple/aqua) — ratio 3.85 / 1.85 (≈ 2.081)

🔹 Why It Adapts
Fixed thresholds (70/30 or 80/20) treat every volatility regime as equivalent. The adaptive channel calibrates the rainbow visual to the actual statistical envelope of the current regime — overbought during a low-volatility consolidation does not mean the same as overbought during a volatility expansion, and the channel reflects that.

🔹 Visual Rendering
The space between adjacent channel boundaries is filled with a semi-transparent color matching the zone palette (toggleable via "Show Thermal Zone Fills"). This makes the current zone immediately visible without having to read the score number — the visual position alone tells you the regime.

VACUUM TRAIL AND BLACK SWAN DYNAMIC GLOW
🔹 Vacuum Trail
Ghost convergence lines projecting from exhaustion extremes back toward the channel median. The lines anchor at a level 15% inside the inner Breathing zone (not at the channel boundary itself), which produces visual convergence inward rather than along the edge — useful for anticipating the typical mean-reversion path after extreme touches.

🔹 Black Swan Dynamic Glow
The outermost ±3.85σ-equivalent boundaries are rendered as a main line plus a wide outer glow whose intensity scales with the score's distance from the boundary. The glow becomes bright when the score is near the Black Swan zone and fades when far — drawing visual attention only when the statistical tail is approached.

🔹 Why They Matter
Both elements give the oscillator a sense of direction beyond the score's current position: the Vacuum Trail visualizes the expected return path during exhaustion; the Black Swan Glow makes statistical tail events visible at a glance, before the score itself crosses the boundary.

INFO PANEL HUD AND ALERTS
🔹 What the HUD Shows
A compact corner panel reports six live values:
◇ SCORE — the current global score (0-100) with color matching the active channel zone
◇ PROB. — the absolute probability (distance from neutral 50 expressed as percentage)
◇ DIRECTION — BUY / SELL / NEUTRAL based on score position relative to the median
◇ CHANNEL — current channel regime classification (Uptrend / Downtrend / Sideways / Compression / Expansion)
◇ RHYTHM — score velocity classification (Fast / Slow)
◇ STATUS — Black Swan / Squeeze / Climax / Neutral, prioritized by severity

🔹 Customization
The HUD can be positioned in any of the four chart corners and rendered in any of five font sizes. The display language is controlled by the System Language input.

🔹 Alerts
Three alert types are available:
◇ Exhaustion Alert — fires when the score crosses above 85% (buying exhaustion) or below 15% (selling exhaustion).
◇ Squeeze Alert — fires when the squeeze flag activates (volatility compression detected).
◇ Black Swan Alert — fires when the score enters the ±3.85σ-equivalent extreme zone; uses an edge-trigger arm/disarm mechanism (fires once on entry, locks while inside, re-arms only on exit).

All alerts are gated by `barstate.isconfirmed` and use `alert.freq_once_per_bar` to prevent duplicate firings on the same candle. Five `alertcondition` blocks are also exposed for users who prefer the TradingView alert UI.

MULTILINGUAL INTERFACE
The indicator supports five languages for the HUD display and alert messages: English (default), Português, Español, Русский, and 中文 (Chinese). Code, comments, group names and input labels remain in English regardless of the selected language.

For reference, the English text of all multilingual UI strings used in the HUD and alerts:
◇ BUY / SELL / NEUTRAL — direction states
◇ SQUEEZE — Low Volatility. Await the Explosion.
◇ CLIMAX — Abnormal Volume Detected. Possible Exhaustion.
◇ UPTREND / DOWNTREND / SIDEWAYS / COMPRESSION / EXPANSION — channel states
◇ FAST / SLOW — rhythm states
◇ SCORE: / DIRECTION: / CHANNEL: / RHYTHM:
◇ BLACK SWAN — EXTREME HIGH / BLACK SWAN — EXTREME LOW
◇ Buying Exhaustion Alert: "[HFT] Buying Exhaustion: Score above 85%. High reversal probability."
◇ Selling Exhaustion Alert: "[HFT] Selling Exhaustion: Score below 15%. High reversal probability."
◇ Squeeze Alert: "[HFT] Squeeze Active: Volatility maximally compressed. Explosion imminent."
◇ Black Swan Alert: "[BLACK SWAN] Score reached the dynamic channel's extreme zone. Maximum statistical tension. Reversal probable."

HOW TO USE
This indicator is not a signal generator. It is a state classifier: it tells you where the multi-timeframe order-flow consensus currently sits, how stretched that consensus is relative to its own recent statistical range, and which order-flow regime (climax, squeeze, normal) is currently active.

🔹 Reading the Oscillator
◇ The score line color matches the active channel zone — visual position alone identifies the regime.
◇ The HUD reports the score numerically and classifies the channel/rhythm/status in plain language.
◇ Vacuum Trail lines indicate the expected mean-reversion path during exhaustion conditions.
◇ Black Swan glow intensity scales with proximity to the statistical extreme.

🔹 Tactical Reading
◇ Score between dyn_mid and inner band: equilibrium zone. Order-flow consensus is in normal range.
◇ Score crossing into the Alert band: directional move asserting itself across multiple timeframes.
◇ Score at the Exhaustion band: most of the impulse has already happened — continuation in trend direction becomes structurally less favorable.
◇ Score touching the Black Swan band: statistical tail event. Mean-reversion context is elevated, but regime change is also possible — the boundary itself is adaptive, so a sustained breach indicates the volatility envelope expanding.
◇ Squeeze state active: oscillator is operating in low-conviction mode. Wait for squeeze release before trusting directional reads.
◇ Climax state active: abnormal volume has been detected. Exhaustion context is present regardless of score position.

🔹 Multi-Timeframe Reading
◇ The default radar configuration (5/13/55/233/987) follows Fibonacci minute periods and is calibrated for intraday and swing trading.
◇ For scalping, configure shorter timeframes (e.g., 1/3/8/21/55).
◇ For position trading, configure longer timeframes (e.g., 60/240/D/W/M).
◇ The middle-weighted timeframes (TF3 and TF4) carry the most influence — choose them carefully.

INPUTS EXPLAINED
🔹 System Language
Display language for the HUD and alert messages. Options: English (default), Português, Español, Русский, 中文 (Chinese).

🔹 MTF Synchronization (TF1 to TF5)
Configure each of the five timeframes to aggregate. Defaults: 5, 13, 55, 233, 987 (Fibonacci minutes). Weights are fixed at 15/20/25/25/15 percent respectively.

🔹 Show Thermal Zone Fills
Toggle for the semi-transparent rainbow fills between adjacent channel boundaries.

🔹 Show Vacuum Trail (Ghost Lines)
Toggle for the convergence ghost lines from exhaustion extremes back toward the channel median.

🔹 Show Dynamic Median Line
Toggle for the channel midline (dyn_mid) — the adaptive zero-reference of the oscillator.

🔹 Show Black Swan Lines (Dynamic Glow)
Toggle for the outermost ±3.85σ-equivalent boundaries with proximity glow.

🔹 Show Info Panel
Toggle for the corner HUD reporting score, direction, channel, rhythm, and status.

🔹 Panel Position
Position of the HUD on the chart. Four corners available: Bottom Right (default), Bottom Left, Top Right, Top Left.

🔹 Font Size
HUD font size. Options: Tiny (default), Small, Normal, Large, Huge.

🔹 Exhaustion Alert
Toggle for the alert that fires when the score crosses ±85/15 thresholds.

🔹 Squeeze Alert
Toggle for the alert that fires when the squeeze flag activates.

🔹 Black Swan Alert
Toggle for the alert that fires when the score enters the adaptive extreme zone.

IMPORTANT NOTES
The MTF Kinetic Oscillator works on any timeframe. The default MTF configuration (5/13/55/233/987 in minutes) is calibrated for intraday and swing trading on liquid instruments. The Fibonacci-aligned RSI lengths (8/13/21/34/55) and per-timeframe data lengths (288/96/72/60/40) are tuned to provide roughly equivalent statistical resolution across all five horizons.

The indicator works best on instruments with reliable volume data: crypto perpetual contracts, large-cap equities, futures, major forex pairs. On low-volume instruments, the CVD component becomes less reliable, though the score engine and channel continue to function correctly using the Z-Score and RSI components alone.

Alerts fire once per confirmed bar. The Black Swan alert uses an edge-trigger arm/disarm mechanism that prevents repeated firings while the score remains inside the extreme zone. Historical bars never repaint after they close. The live bar updates intra-bar as expected for a real-time indicator.

The Value Area calibration factor (vp_k = 2.51) used internally by the score engine for the Volume Profile distance component is tuned to approximate the conventional 70% Value Area definition. The Fibonacci sigma multipliers (1.50, 1.85, 2.75, 3.85) used by the adaptive channel are intentionally non-standard — they are Fibonacci-inspired proportions, not arbitrary choices, and they map to four behavioral regimes derived from observation rather than to integer statistical thresholds.

Pine Script v6. Open-source under Mozilla Public License 2.0.

UNIQUENESS
The MTF Kinetic Oscillator is unique in four ways. First, it operates across 5 timeframes simultaneously, aggregating per-timeframe scores via Fibonacci-proportioned weights (0.15 / 0.20 / 0.25 / 0.25 / 0.15) rather than operating on a single timeframe like RSI, MFI, CCI, or Stochastic. Second, the per-timeframe score is built from a Log-Normal Z-Score regression of price (which respects the asymmetric distribution of returns) blended with RSI through sigmoid normalization — producing a bounded composite that combines two independent signal families per horizon. Third, the global score is plotted not against fixed 0-100 thresholds but against a self-adaptive Fibonacci channel whose boundaries are recomputed every bar from the highest and lowest scores in the lookback window — calibrating the rainbow visual to current volatility regime rather than to static numerical levels. Fourth, three independent order-flow sensors (CVD Z-Score, Volume Climax detection, and Squeeze volatility compression) modulate the score continuously, with the Squeeze damper compressing score amplitude to 25% during low-conviction lateral phases — suppressing false directional signals at exactly the moments standard oscillators are typically least reliable. The combination of Fibonacci-weighted multi-timeframe aggregation, log-space Z-Score plus RSI per timeframe, adaptive Fibonacci channel, and three order-flow modulators produces an oscillator that behaves differently from single-timeframe and fixed-threshold oscillators, particularly during volatility regime transitions where standard oscillators are least reliable.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © rainbowmatrix
//
// ════════════════════════════════════════════════════════════════════════════════
// MTF KINETIC OSCILLATOR — MULTI-TIMEFRAME ORDER-FLOW PROBABILITY ENGINE
//
// A pure order-flow oscillator that fuses 5 timeframes into a single weighted
// probability score, calibrated against a self-adaptive Fibonacci channel that
// scales with current volatility conditions.
//
// METHOD:
//   1. For each of 5 user-configured timeframes (default 5/15/60/240/D),
//      the script extracts via request.security():
//        - Log-Normal Z-Score regression of price (asymmetric distribution).
//        - VWAP and Z-VWAP (volume-weighted reference).
//        - Volume Profile distances (VAH/POC/VAL).
//        - RSI and Parabolic SAR direction.
//        - A per-timeframe normalized score (0-100) combining Z-Score sigmoid
//          and RSI.
//   2. The 5 per-timeframe scores are aggregated via Fibonacci weights
//      (0.15 / 0.20 / 0.25 / 0.25 / 0.15) into a single global score.
//   3. The global score is adjusted by two order-flow sensors:
//        - CVD (Cumulative Volume Delta) Z-Score, clamped at ±12 points.
//        - Volume Climax drag, dampening the score when abnormal volume is
//          detected (statistical exhaustion signal).
//      A squeeze damper compresses the score amplitude to 25% during periods
//      of compressed volatility, suppressing false signals.
//   4. The adjusted score is plotted against an adaptive Fibonacci channel:
//        - Inner band (Z-Breathing)  — 1.50/1.85 ratio
//        - Upper Limit (Z-Alert)     — 1.85/1.85 = 1.000 (anchor)
//        - Outer band (Z-Exhaustion) — 2.75/1.85 ratio
//        - Extreme edge (Black Swan) — 3.85/1.85 ratio (line + glow only)
//      Channel boundaries are re-computed every bar from the highest/lowest
//      score over the lookback window, smoothed by EMA.
//   5. A Vacuum Trail (ghost convergence lines) projects from exhaustion
//      extremes back toward the channel median, with a 15% safety buffer
//      inside the cloud.
//
// ORIGINALITY:
//   Most oscillators on TradingView operate on a single timeframe (RSI, MFI,
//   CCI, Stoch). This script aggregates 5 timeframes via Fibonacci weights and
//   blends three independent signal families (Z-Score regression in log space,
//   CVD order-flow, and Volume Climax) into one probability score. The
//   adaptive Fibonacci channel calibrates the visual rainbow to current
//   volatility regime, rather than to fixed 0-100 thresholds.
//
// HOW TO USE:
//   - Score values toward 100 indicate compounded selling exhaustion;
//     values toward 0 indicate compounded buying exhaustion.
//   - The rainbow channel zones (yellow / orange / red / purple) correspond
//     to progressively rarer statistical conditions.
//   - The Black Swan zone (purple/aqua extreme glow) marks score positions
//     at the ±3.85σ-equivalent edge of the channel — statistical tail events.
//   - The HUD reports the live score, absolute probability, directional bias,
//     channel state, and rhythm classification.
//
// MULTILINGUAL UI:
//   The HUD and alert messages support 5 languages: EN/PT/ES/RU/ZH.
//   Code, comments, group names and input labels remain in English.
// ════════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("MTF Kinetic Oscillator | Rainbow Matrix", overlay=false, max_bars_back=500, max_lines_count=20)

// ========================================================================================================
// COLORS — RAINBOW PALETTE
// ========================================================================================================
c_up_4 = color.purple
c_up_3 = color.red
c_up_2 = color.orange
c_up_1 = color.yellow
c_dn_1 = color.green
c_dn_2 = color.teal
c_dn_3 = color.blue
c_dn_4 = color.aqua
c_neutral = color.gray
c_black  = color.black

// ========================================================================================================
// SYSTEM LANGUAGE
// ========================================================================================================
g_lang = "GLOBAL SETTINGS"
lang = input.string("English", "System Language",
     options=["English", "Português", "Español", "Русский", "中文 (Chinese)"],
     group=g_lang,
     tooltip="Display language for the HUD panel and alert messages. 5 languages supported: English, Português, Español, Русский, 中文. Code, inputs, and group names remain in English regardless.")
string _l = lang == "Português" ? "PT" : lang == "Español" ? "ES" : lang == "Русский" ? "RU" : lang == "中文 (Chinese)" ? "ZH" : "EN"

// ── Multi-language Strings ───────────────────────────────────────────────────
var string s_buy      = _l=="PT"?"COMPRA 💰"   :_l=="ES"?"COMPRA 💰"   :_l=="RU"?"ПОКУПКА 💰"  :_l=="ZH"?"买入 💰"   :"BUY 💰"
var string s_sell     = _l=="PT"?"VENDA 💸"    :_l=="ES"?"VENTA 💸"    :_l=="RU"?"ПРОДАЖА 💸"  :_l=="ZH"?"卖出 💸"   :"SELL 💸"
var string s_neutral  = _l=="PT"?"NEUTRO ⚖️"   :_l=="ES"?"NEUTRAL ⚖️"  :_l=="RU"?"НЕЙТРАЛЬ ⚖️" :_l=="ZH"?"中性 ⚖️"   :"NEUTRAL ⚖️"
var string s_squeeze  = _l=="PT"?"🧲 SQUEEZE — Baixa Volatilidade. Aguarde a Explosão." :_l=="ES"?"🧲 SQUEEZE — Baja Volatilidad. Espere la Explosión." :_l=="RU"?"🧲 СЖАТИЕ — Низкая Волатильность. Ждите Взрыва." :_l=="ZH"?"🧲 挤压 — 低波动率。等待爆发。" :"🧲 SQUEEZE — Low Volatility. Await the Explosion."
var string s_climax   = _l=="PT"?"💥 CLÍMAX — Volume Anormal Detectado. Exaustão Possível." :_l=="ES"?"💥 CLÍMAX — Volumen Anormal Detectado. Posible Agotamiento." :_l=="RU"?"💥 КЛИМАКС — Аномальный Объём. Возможное Истощение." :_l=="ZH"?"💥 高潮 — 异常成交量。可能枯竭。" :"💥 CLIMAX — Abnormal Volume Detected. Possible Exhaustion."
var string s_ch_up    = _l=="PT"?"↗️ CANAL ALTA"    :_l=="ES"?"↗️ CANAL ALCISTA"   :_l=="RU"?"↗️ ВОСХОДЯЩИЙ"     :_l=="ZH"?"↗️ 上升通道"  :"↗️ UPTREND"
var string s_ch_dn    = _l=="PT"?"↘️ CANAL BAIXA"   :_l=="ES"?"↘️ CANAL BAJISTA"   :_l=="RU"?"↘️ НИСХОДЯЩИЙ"     :_l=="ZH"?"↘️ 下降通道"  :"↘️ DOWNTREND"
var string s_ch_lat   = _l=="PT"?"⚖️ LATERAL"       :_l=="ES"?"⚖️ LATERAL"         :_l=="RU"?"⚖️ ФЛЭТ"           :_l=="ZH"?"⚖️ 横盘"      :"⚖️ SIDEWAYS"
var string s_ch_cont  = _l=="PT"?"🔻 CONTRAÇÃO"     :_l=="ES"?"🔻 COMPRESIÓN"      :_l=="RU"?"🔻 СЖАТИЕ"         :_l=="ZH"?"🔻 收缩"      :"🔻 COMPRESSION"
var string s_ch_exp   = _l=="PT"?"📢 EXPANSÃO"      :_l=="ES"?"📢 EXPANSIÓN"       :_l=="RU"?"📢 РАСШИРЕНИЕ"     :_l=="ZH"?"📢 扩张"      :"📢 EXPANSION"
var string s_fast     = _l=="PT"?"⚡ RÁPIDO"        :_l=="ES"?"⚡ RÁPIDO"          :_l=="RU"?"⚡ БЫСТРО"         :_l=="ZH"?"⚡ 快速"      :"⚡ FAST"
var string s_slow     = _l=="PT"?"🐢 ARRASTADO"     :_l=="ES"?"🐢 LENTO"           :_l=="RU"?"🐢 МЕДЛЕННО"       :_l=="ZH"?"🐢 缓慢"      :"🐢 SLOW"
var string s_lbl_scr  = _l=="PT"?"SCORE:"           :_l=="ES"?"SCORE:"             :_l=="RU"?"СЧЁТ:"             :_l=="ZH"?"评分:"        :"SCORE:"
var string s_lbl_dir  = _l=="PT"?"DIREÇÃO:"         :_l=="ES"?"DIRECCIÓN:"         :_l=="RU"?"НАПРАВЛЕНИЕ:"      :_l=="ZH"?"方向:"        :"DIRECTION:"
var string s_lbl_ch   = _l=="PT"?"CANAL:"           :_l=="ES"?"CANAL:"             :_l=="RU"?"КАНАЛ:"            :_l=="ZH"?"通道:"        :"CHANNEL:"
var string s_lbl_rtm  = _l=="PT"?"RITMO:"           :_l=="ES"?"RITMO:"             :_l=="RU"?"РИТМ:"             :_l=="ZH"?"节奏:"        :"RHYTHM:"
var string s_al_exh_h = _l=="PT"?"⚠️ [KINETIC] Exaustão Compradora: Score acima de 85%. Alta probabilidade de reversão." :_l=="ES"?"⚠️ [KINETIC] Agotamiento Comprador: Score sobre 85%. Alta probabilidad de reversión." :_l=="RU"?"⚠️ [KINETIC] Истощение Покупателей: Score выше 85%. Высокая вероятность разворота." :_l=="ZH"?"⚠️ [KINETIC] 买方衰竭：评分高于85%。高反转概率。" :"⚠️ [KINETIC] Buying Exhaustion: Score above 85%. High reversal probability."
var string s_al_exh_l = _l=="PT"?"⚠️ [KINETIC] Exaustão Vendedora: Score abaixo de 15%. Alta probabilidade de reversão." :_l=="ES"?"⚠️ [KINETIC] Agotamiento Vendedor: Score bajo 15%. Alta probabilidad de reversión." :_l=="RU"?"⚠️ [KINETIC] Истощение Продавцов: Score ниже 15%. Высокая вероятность разворота." :_l=="ZH"?"⚠️ [KINETIC] 卖方衰竭：评分低于15%。高反转概率。" :"⚠️ [KINETIC] Selling Exhaustion: Score below 15%. High reversal probability."
var string s_al_sqz   = _l=="PT"?"🧲 [KINETIC] Squeeze Ativo: Volatilidade comprimida ao máximo. Explosão iminente." :_l=="ES"?"🧲 [KINETIC] Squeeze Activo: Volatilidad comprimida al máximo. Explosión inminente." :_l=="RU"?"🧲 [KINETIC] Сжатие Активно: Волатильность максимально сжата. Взрыв неизбежен." :_l=="ZH"?"🧲 [KINETIC] 挤压激活：波动率最大压缩。爆发即将到来。" :"🧲 [KINETIC] Squeeze Active: Volatility maximally compressed. Explosion imminent."
var string s_bs_high  = _l=="PT"?"🦢 CISNE NEGRO — TOPO EXTREMO"  :_l=="ES"?"🦢 CISNE NEGRO — TECHO EXTREMO"  :_l=="RU"?"🦢 ЧЁРНЫЙ ЛЕБЕДЬ — ВЕРХ"           :_l=="ZH"?"🦢 黑天鹅 — 极端顶部"   :"🦢 BLACK SWAN — EXTREME HIGH"
var string s_bs_low   = _l=="PT"?"🦢 CISNE NEGRO — FUNDO EXTREMO" :_l=="ES"?"🦢 CISNE NEGRO — FONDO EXTREMO"  :_l=="RU"?"🦢 ЧЁРНЫЙ ЛЕБЕДЬ — НИЗ"            :_l=="ZH"?"🦢 黑天鹅 — 极端底部"   :"🦢 BLACK SWAN — EXTREME LOW"
var string s_al_bs    = _l=="PT"?"🦢 [CISNE NEGRO] Score atingiu zona extrema do canal dinâmico. Tensão estatística máxima. Reversão provável." :_l=="ES"?"🦢 [CISNE NEGRO] Score alcanzó zona extrema del canal dinámico. Tensión estadística máxima. Reversión probable." :_l=="RU"?"🦢 [ЧЁРН. ЛЕБЕДЬ] Score достиг экстремальной зоны динамического канала. Максимальное напряжение. Вероятен разворот." :_l=="ZH"?"🦢 [黑天鹅] 评分达到动态通道极端区域。统计张力最大。可能发生反转。" :"🦢 [BLACK SWAN] Score reached the dynamic channel's extreme zone. Maximum statistical tension. Reversal probable."

// ========================================================================================================
// INPUTS
// ========================================================================================================
g_mtf = "MTF SYNCHRONIZATION"
m_tf1 = input.string("5",   "TF 1 — Trigger",      group=g_mtf, tooltip="Fastest timeframe. Highest reactivity, lowest weight (15%).")
m_tf2 = input.string("15",  "TF 2 — Intraday",     group=g_mtf, tooltip="Second timeframe. Weight 20%.")
m_tf3 = input.string("60",  "TF 3 — Macro 1",      group=g_mtf, tooltip="Third timeframe. Highest weight (25%). Backbone of the score.")
m_tf4 = input.string("240", "TF 4 — Macro 2",      group=g_mtf, tooltip="Fourth timeframe. Weight 25%. Institutional reference.")
m_tf5 = input.string("D",   "TF 5 — Base",         group=g_mtf, tooltip="Slowest timeframe. Weight 15%. Macro trend anchor.")

g_osc = "OSCILLATOR DISPLAY"
show_fills   = input.bool(true,  "Show Thermal Zone Fills",        group=g_osc, tooltip="Toggle the colored thermal fills between rainbow zone boundaries. 6 fills render the channel as a heat map (yellow/orange/red on each side of the median). Disable for a cleaner look with only boundary lines visible.")
show_vacuo   = input.bool(true,  "Show Vacuum Trail (Ghost Lines)", group=g_osc, tooltip="Convergence lines projecting from exhaustion extremes toward the dynamic channel median. Shows the market's expected return path.")
show_midline = input.bool(true,  "Show Dynamic Median Line",       group=g_osc, tooltip="Toggle the dashed dynamic median line — the midpoint between the upper and lower channel bounds. Useful as a visual neutrality reference.")
show_swan    = input.bool(true,  "Show Black Swan Lines (Dynamic Glow)", group=g_osc, tooltip="Purple/Aqua extreme zone lines beyond the rainbow. Glow intensity scales with proximity — bright when score is near, fades when far.")
show_panel   = input.bool(true,  "Show Info Panel",                group=g_osc, tooltip="Toggle the corner information panel showing live score, absolute probability, directional bias, channel state, rhythm, and status alerts.")
panel_pos    = input.string("Bottom Right", "Panel Position",
     options=["Bottom Right","Bottom Left","Top Right","Top Left"], group=g_osc,
     tooltip="Position of the information panel on the chart. 4 corners available.")
i_text_size  = input.string("Tiny", "Font Size",
     options=["Tiny","Small","Normal","Large","Huge"], group=g_osc,
     tooltip="Font size for the information panel. 5 sizes from Tiny (compact) to Huge.")
font_size    = i_text_size == "Tiny" ? size.tiny : i_text_size == "Small" ? size.small : i_text_size == "Normal" ? size.normal : i_text_size == "Large" ? size.large : size.huge

g_al = "ALERTS"
al_exhaustion = input.bool(true, "Exhaustion Alert (Score > 85% or < 15%)", group=g_al, tooltip="Fires when the kinetic score crosses above 85% (buying exhaustion) or below 15% (selling exhaustion). These are statistically rare zones where reversal probability is highest. Alert only fires on confirmed bar close.")
al_squeeze    = input.bool(true, "Squeeze Alert (Volatility Compression)",  group=g_al, tooltip="Fires when volatility compresses to the lowest 15% of the 100-bar window — a 'squeeze' regime where directional momentum is temporarily exhausted. Often precedes explosive expansion in either direction.")
al_black_swan = input.bool(true, "Black Swan Alert (Extreme Channel Zone)", group=g_al, tooltip="Fires when the score enters the extreme statistical zone at the 3.85σ-equivalent edge of the dynamic channel. Edge-triggered: fires on first entry, re-arms when score exits the zone.")

// ========================================================================================================
// VOLUME PROFILE CONSTANT
// ========================================================================================================
float vp_k = 2.51

// ========================================================================================================
// HELPER FUNCTIONS
// ========================================================================================================
f_avg5(v1, v2, v3, v4, v5) =>
    sum = (na(v1)?0.:v1) + (na(v2)?0.:v2) + (na(v3)?0.:v3) + (na(v4)?0.:v4) + (na(v5)?0.:v5)
    cnt = (na(v1)?0:1)  + (na(v2)?0:1)  + (na(v3)?0:1)  + (na(v4)?0:1)  + (na(v5)?0:1)
    cnt > 0 ? sum / cnt : na

// Weighted average with Fibonacci weights (15/20/25/25/15)
f_avg5_weighted(v1, v2, v3, v4, v5) =>
    w1=0.15, w2=0.20, w3=0.25, w4=0.25, w5=0.15
    wt = (na(v1)?0.:w1)+(na(v2)?0.:w2)+(na(v3)?0.:w3)+(na(v4)?0.:w4)+(na(v5)?0.:w5)
    wt > 0 ? (nz(v1)*w1 + nz(v2)*w2 + nz(v3)*w3 + nz(v4)*w4 + nz(v5)*w5) / wt : na

// ========================================================================================================
// MTF EXTRACTION ENGINE — f_calc_mtf_data()
// ========================================================================================================
// For each timeframe, calculates:
// Log-Normal Z-Score, VWAP, Z-VWAP, VAH/POC/VAL (Volume Profile), RSI, SAR, Score
f_calc_mtf_data(simple int len, simple int rsi_len) =>
    // ── Log-Normal Z-Score with Directional Reference ──
    // Green candle = upward pressure → uses HIGH
    // Red candle = downward pressure → uses LOW
    _src  = hlc3 > 0 ? math.log(hlc3) : na
    _base = ta.linreg(_src, len, 0)
    _dev  = math.max(nz(ta.stdev(_src - _base, len)), 0.000001)
    float _ref_price = close >= open ? high : low
    _zraw = _ref_price > 0 ? (math.log(_ref_price) - _base) / _dev : 0.0

    // ── VWAP and Z-VWAP ──
    _vwap    = ta.vwma(hlc3, len)
    _vwap_l  = _vwap > 0 ? math.log(_vwap) : na
    _vzraw   = (_vwap_l - _base) / _dev

    // ── Volume Profile (POC / VAH / VAL) ──
    _max_vol = ta.highest(volume, len)
    _poc       = ta.valuewhen(volume == _max_vol, hlc3, 0)
    _dev_sq    = volume * math.pow(hlc3 - _poc, 2)
    _var       = math.sum(_dev_sq, len) / math.max(math.sum(volume, len), 1)
    _vah       = _poc + (math.sqrt(_var) * vp_k)
    _val       = math.max(_poc - (math.sqrt(_var) * vp_k), 0.0000000001)
    _vah_d     = _vah > 0 ? ((close - _vah) / _vah) * 100 : na
    _val_d     = _val > 0 ? ((close - _val) / _val) * 100 : na

    // ── RSI and SAR ──
    _rsi = ta.rsi(close, rsi_len)
    _sar = close > ta.sar(0.02, 0.02, 0.2) ? 1 : -1

    // ── Per-Timeframe Score: Sigmoid(Z) + RSI, normalized 0-100 ──
    _z_safe = math.max(math.min(_zraw, 10.0), -10.0)
    _scr_z    = 100.0 / (1.0 + math.exp(-_z_safe))
    _scr_base = (_scr_z + _rsi) / 2.0
    _scr      = math.max(math.min(_scr_base, 100.0), 0.0)

    [_zraw, _vwap, _vzraw, _vah_d, _val_d, _rsi, _sar, _scr]

// ========================================================================================================
// MTF EXTRACTION — 5 TIMEFRAMES
// ========================================================================================================
[z_tf1,  v_tf1,  vz_tf1,  vah_tf1,  val_tf1,  rsi_tf1,  sar_tf1,  scr_tf1]  = request.security(syminfo.tickerid, m_tf1, f_calc_mtf_data(288,  8), lookahead=barmerge.lookahead_off)
[z_tf2,  v_tf2,  vz_tf2,  vah_tf2,  val_tf2,  rsi_tf2,  sar_tf2,  scr_tf2]  = request.security(syminfo.tickerid, m_tf2, f_calc_mtf_data(96,  13), lookahead=barmerge.lookahead_off)
[z_tf3,  v_tf3,  vz_tf3,  vah_tf3,  val_tf3,  rsi_tf3,  sar_tf3,  scr_tf3]  = request.security(syminfo.tickerid, m_tf3, f_calc_mtf_data(72,  21), lookahead=barmerge.lookahead_off)
[z_tf4,  v_tf4,  vz_tf4,  vah_tf4,  val_tf4,  rsi_tf4,  sar_tf4,  scr_tf4]  = request.security(syminfo.tickerid, m_tf4, f_calc_mtf_data(60,  34), lookahead=barmerge.lookahead_off)
[z_tf5,  v_tf5,  vz_tf5,  vah_tf5,  val_tf5,  rsi_tf5,  sar_tf5,  scr_tf5]  = request.security(syminfo.tickerid, m_tf5, f_calc_mtf_data(40,  55), lookahead=barmerge.lookahead_off)

// ── Global Aggregation (Fibonacci weights) ──────────────────────────────────
rsi_glb     = f_avg5_weighted(rsi_tf1, rsi_tf2, rsi_tf3, rsi_tf4, rsi_tf5)
scr_glb_raw = f_avg5_weighted(scr_tf1, scr_tf2, scr_tf3, scr_tf4, scr_tf5)

sar_sum = nz(sar_tf1) + nz(sar_tf2) + nz(sar_tf3) + nz(sar_tf4) + nz(sar_tf5)
sar_glb = sar_sum > 0 ? 1 : sar_sum < 0 ? -1 : 0

// ========================================================================================================
// SENSOR CVD — CUMULATIVE VOLUME DELTA (Order Flow)
// ========================================================================================================
// CVD: difference between buyer and seller volume, normalized to Z-Score
// Measures market-order aggression — who is really in control
bull_power   = close - low
bear_power   = high  - close
total_power  = math.max(high - low, 0.0001)
vol_buyer = volume * (bull_power / total_power)
vol_seller  = volume * (bear_power / total_power)
delta_volume  = vol_buyer - vol_seller

len_medium = int(math.max(15, math.round(50.0)))
cvd_mean = ta.sma(delta_volume, len_medium)
cvd_dev   = math.max(ta.stdev(delta_volume, len_medium), 0.000001)
cvd_z     = (delta_volume - cvd_mean) / cvd_dev

// CVD Bonus: amplifies the score when strong directional order pressure exists
// Clamped at ±12 points to prevent excessive distortion
cvd_bonus = math.max(math.min(cvd_z * 4.0, 12.0), -12.0)

// ========================================================================================================
// KINETIC SENSORS — SQUEEZE AND VOLUME CLIMAX
// ========================================================================================================
// Squeeze: price volatility percentage normalized from 0 to 100
// ≤15 = compressed market (explosion imminent) | ≥85 = maximum expansion
vlat_len  = 20
vlat_high = ta.highest(high, vlat_len)
vlat_low  = ta.lowest(low,  vlat_len)
vlat_raw  = close > 0 ? (vlat_high - vlat_low) / close : 0.0
vlat_min  = ta.lowest(vlat_raw, 100)
vlat_max  = ta.highest(vlat_raw, 100)
vlat_norm = vlat_max > vlat_min ? ((vlat_raw - vlat_min) / (vlat_max - vlat_min)) * 100.0 : 50.0
vlat_squeeze = vlat_norm <= 15

// Volume Climax: Volume Z-Score ≥ 3.0 = volume 3 stdev above mean
len_macro = 200
vol_mean  = ta.sma(volume, len_macro)
vol_stdev = math.max(ta.stdev(volume, len_macro), 0.000001)
vol_z     = (volume - vol_mean) / vol_stdev

// Climax drag: pulls the score back to center after extreme volume
climax_drag = (vol_z >= 3.0) ? (scr_glb_raw - 50.0) * 0.15 : 0.0

// ========================================================================================================
// KINETIC SCORE PIPELINE
// ========================================================================================================
// The kinetic score is computed from pure order-flow inputs:
//   raw weighted MTF score + CVD bonus + Volume Climax drag.
// A squeeze damper compresses score amplitude in compressed-volatility regimes,
// and a 3-period WMA smooths single-bar spikes out of the final output.

float scr_mutant = nz(scr_glb_raw) + nz(cvd_bonus) + nz(climax_drag)

// Squeeze damper: in compressed markets the score oscillates at only 25% of normal
// Prevents false signals during periods of lateral noise without direction
squeeze_factor = vlat_squeeze ? 0.25 : 1.0
float scr_final = 50.0 + ((scr_mutant - 50.0) * squeeze_factor)
scr_final := math.max(math.min(scr_final, 100.0), 0.0)

// WMA smoothing (3 periods) — removes single-bar spikes
float scr_glb = ta.wma(scr_final, 3)


// ========================================================================================================
// ADAPTIVE DYNAMIC CHANNEL — RAINBOW FIBONACCI
// ========================================================================================================
// Structure mirrors the Rainbow Cloud from Cloud Institutional Bands (token):
//   short_deviation  = 1.50σ → Z-Breathing  (yellow)
//   medium_deviation = 1.85σ → Z-Alert     (orange)  ← Upper Limit (visible anchor)
//   long_deviation   = 2.75σ → Z-Exhaustion (red)
//   super_deviation  = 3.85σ -> Black Swan (purple)
//
// Normalized for the oscillator, with osc_up2 = dyn_up (Upper Limit) as anchor:
//   osc_up1 = (1.50/1.85) ≈ 0.811   Z-Breathing inner
//   osc_up2 = (1.85/1.85) = 1.000   Upper Limit (= dyn_up)
//   osc_up3 = (2.75/1.85) ≈ 1.486   Z-Exhaustion outer
//   osc_up4 = (3.85/1.85) ≈ 2.081   Black Swan (extreme edge, line + glow only)
//
// Band widths are intentionally unequal (Fibonacci-like):
//   Yellow  ┃ 0.811 wide  (WIDE — Breathing dominant)
//   Orange  ┃ 0.189 wide  (NARROW — Alert frontier)
//   Red     ┃ 0.486 wide  (medium — Exhaustion)
//   Purple  ┃ line + dynamic glow only (no fill)
lookback_dyn = 50
smooth_dyn   = 10
dyn_up  = ta.ema(ta.highest(scr_final, lookback_dyn), smooth_dyn)
dyn_dn  = ta.ema(ta.lowest(scr_final,  lookback_dyn), smooth_dyn)
dyn_mid = (dyn_up + dyn_dn) / 2.0

dist_up = dyn_up - dyn_mid
dist_dn = dyn_mid - dyn_dn

// Cloud Bands Fibonacci ratios normalized by medium-deviation (1.85)
fib_breath    = 1.50 / 1.85   // ≈ 0.811
fib_exhaust   = 2.75 / 1.85   // ≈ 1.486
fib_blackswan = 3.85 / 1.85   // ≈ 2.081

osc_up1 = dyn_mid + (dist_up * fib_breath)      // Z-Breathing High inner (yellow↔orange)
osc_up2 = dyn_up                                 // Upper Limit (orange↔red)
osc_up3 = dyn_mid + (dist_up * fib_exhaust)     // Z-Exhaustion High outer (red↔purple)
osc_up4 = dyn_mid + (dist_up * fib_blackswan)   // Black Swan High (extreme edge)

osc_dn1 = dyn_mid - (dist_dn * fib_breath)      // Z-Breathing Low inner
osc_dn2 = dyn_dn                                 // Lower Limit
osc_dn3 = dyn_mid - (dist_dn * fib_exhaust)     // Z-Exhaustion Low outer
osc_dn4 = dyn_mid - (dist_dn * fib_blackswan)   // Black Swan Low

// ── Safety Margin for the Vacuum Trail (15% buffer inside the cloud) ──
// Convergence lines anchor at levels INSIDE the channel (not at osc_up2/dn2,
// which coincide with dyn_up/dn). This ensures the trail has real direction
// and visually converges inward — anticipating the "shakeout trap".
buffer_mult       = 0.15
buffer_up_visual  = dist_up * buffer_mult
buffer_dn_visual  = dist_dn * buffer_mult
safe_top_level    = osc_up1 - buffer_up_visual   // inside the Breathing High zone
safe_bottom_level = osc_dn1 + buffer_dn_visual   // inside the Breathing Low zone

// ── Dynamic score color (changes with zone) ────────────────────────────────
scr_color = scr_glb >= osc_up4 ? c_up_4 : scr_glb >= osc_up3 ? c_up_3 : scr_glb >= osc_up2 ? c_up_2 : scr_glb >= osc_up1 ? c_up_1 : scr_glb >= dyn_mid ? c_up_1 : scr_glb >= osc_dn1 ? c_dn_1 : scr_glb >= osc_dn2 ? c_dn_2 : scr_glb >= osc_dn3 ? c_dn_3 : c_dn_4

// ========================================================================================================
// CHANNEL AND RHYTHM DETECTION
// ========================================================================================================
// Channel: comparison of dynamic top and bottom against 3 bars ago
top_falling  = dyn_up < dyn_up[3]
bottom_falling  = dyn_dn < dyn_dn[3]
top_rising = dyn_up > dyn_up[3]
bottom_rising = dyn_dn > dyn_dn[3]

string channel_txt  = s_ch_lat
color  channel_color  = c_up_1

if      top_falling  and bottom_falling
    channel_txt := s_ch_dn,   channel_color := c_up_3
else if top_rising and bottom_rising
    channel_txt := s_ch_up,   channel_color := c_dn_2
else if top_falling  and bottom_rising
    channel_txt := s_ch_cont, channel_color := c_up_2
else if top_rising and bottom_falling
    channel_txt := s_ch_exp,  channel_color := c_up_4

// Rhythm: count of bounces between channel top and bottom
var int   hunt_mode    = 0
var int   bounce_cnt  = 0
var float last_bounce_px  = na

broke_dn = ta.crossover(scr_glb,  dyn_dn)
broke_up = ta.crossunder(scr_glb, dyn_up)
pulled_dn   = ta.crossunder(scr_glb, dyn_dn)
pulled_up   = ta.crossover(scr_glb,  dyn_up)

if broke_dn and hunt_mode != 1
    hunt_mode := 1, bounce_cnt := 0, last_bounce_px := close
if broke_up and hunt_mode != -1
    hunt_mode := -1, bounce_cnt := 0, last_bounce_px := close
if hunt_mode == 1
    if scr_glb >= dyn_up
        hunt_mode := 0
    else if pulled_dn
        bounce_cnt += 1, last_bounce_px := close
else if hunt_mode == -1
    if scr_glb <= dyn_dn
        hunt_mode := 0
    else if pulled_up
        bounce_cnt += 1, last_bounce_px := close

string rhythm_txt = bounce_cnt == 0 ? s_fast : s_slow + " (" + str.tostring(bounce_cnt) + "x)"
color  rhythm_color = bounce_cnt == 0 ? c_dn_2 : c_up_2

// ========================================================================================================
// VACUUM TRAIL — GEOMETRIC CONVERGENCE LINES
// ========================================================================================================
// When the score breaks the top/bottom, plots a line converging from the
// breakpoint back toward the dynamic channel. Shows the expected return path.
var line[] lines_top = array.new_line()
var line[] lines_bottom = array.new_line()

var bool allow_top = true
var bool allow_bottom = true

var int   bar_anc_t = na, var float val_anc_t = na
var int   bar_anc_b = na, var float val_anc_b = na

c_top = show_vacuo ? color.new(c_up_3, 50) : na
c_bottom = show_vacuo ? color.new(c_dn_3, 50) : na

trigger_top = scr_glb >= osc_up2
trigger_bottom = scr_glb <= osc_dn2

if trigger_top and allow_top
    if array.size(lines_top) > 0
        for i = 0 to array.size(lines_top) - 1
            line.set_style(array.get(lines_top, i), line.style_dotted)
            line.set_extend(array.get(lines_top, i), extend.right)
    bar_anc_t := bar_index, val_anc_t := osc_up2
    l = line.new(bar_anc_t, val_anc_t, bar_index + 1, safe_top_level, color=c_top, width=2)
    array.push(lines_top, l)
    if array.size(lines_top) > 3
        line.delete(array.shift(lines_top))
    allow_top := false, allow_bottom := true

if trigger_bottom and allow_bottom
    if array.size(lines_bottom) > 0
        for i = 0 to array.size(lines_bottom) - 1
            line.set_style(array.get(lines_bottom, i), line.style_dotted)
            line.set_extend(array.get(lines_bottom, i), extend.right)
    bar_anc_b := bar_index, val_anc_b := osc_dn2
    l = line.new(bar_anc_b, val_anc_b, bar_index + 1, safe_bottom_level, color=c_bottom, width=2)
    array.push(lines_bottom, l)
    if array.size(lines_bottom) > 3
        line.delete(array.shift(lines_bottom))
    allow_bottom := false, allow_top := true

// Updates the active line in real time to point at the safe level inside the cloud
if array.size(lines_top) > 0
    line.set_xy2(array.get(lines_top, array.size(lines_top) - 1), bar_index + 1, safe_top_level)
if array.size(lines_bottom) > 0
    line.set_xy2(array.get(lines_bottom, array.size(lines_bottom) - 1), bar_index + 1, safe_bottom_level)

// ========================================================================================================
// BLACK SWAN — DYNAMIC GLOW (proportional to score distance)
// ========================================================================================================
// Cloud Bands pattern: the Black Swan line glows brighter when the score is
// near, becomes nearly invisible when far. Creates a "visual attraction" effect.
// Reference range: dist_up (= dynamic channel width)
f_glow_osc(float level) =>
    int(95 - (math.max(0.0, math.min(1.0, 1.0 - (math.abs(scr_glb - level) / math.max(dist_up, 0.000001)))) * 75))

transp_up4 = f_glow_osc(osc_up4)
transp_dn4 = f_glow_osc(osc_dn4)

// ========================================================================================================
// OSCILLATOR RENDERING
// ========================================================================================================
// ── Black Swan High (Purple) — Main line + Outer glow, NO fill ──
plot(show_swan ? osc_up4 : na, "Black Swan High Glow", color=color.new(c_up_4, transp_up4), linewidth=5, display = display.pane)
plot(show_swan ? osc_up4 : na, "Black Swan High",      color=color.new(c_up_4, math.max(20, transp_up4 - 20)), linewidth=1)

// ── Cloud plots (osc_up3/osc_up1/osc_dn1/osc_dn3 hidden as fill boundaries) ──
p_up3 = plot(osc_up3, display=display.none, title="Osc Up3 Boundary")
p_up2 = plot(osc_up2, "Upper Limit",  color=color.new(c_up_3, 50), linewidth=1, linestyle=plot.linestyle_dashed)
p_up1 = plot(osc_up1, display=display.none, title="Osc Up1 Boundary")
p_mid = plot(show_midline ? dyn_mid : na, "Dynamic Median", color=color.new(c_neutral, 50), linewidth=1, linestyle=plot.linestyle_dashed)
p_dn1 = plot(osc_dn1, display=display.none, title="Osc Dn1 Boundary")
p_dn2 = plot(osc_dn2, "Lower Limit",  color=color.new(c_dn_3, 50), linewidth=1, linestyle=plot.linestyle_dashed)
p_dn3 = plot(osc_dn3, display=display.none, title="Osc Dn3 Boundary")

// ── Black Swan Low (Aqua) — Main line + Outer glow, NO fill ──
plot(show_swan ? osc_dn4 : na, "Black Swan Low Glow", color=color.new(c_dn_4, transp_dn4), linewidth=5, display = display.pane)
plot(show_swan ? osc_dn4 : na, "Black Swan Low",      color=color.new(c_dn_4, math.max(20, transp_dn4 - 20)), linewidth=1)

// ── 6 rainbow thermal fills (Cloud Bands Fibonacci proportions) ──
fill(p_up3, p_up2, color=show_fills ? color.new(c_up_3, 88) : na, title="Z-Exhaustion High")
fill(p_up2, p_up1, color=show_fills ? color.new(c_up_2, 90) : na, title="Z-Alert High")
fill(p_up1, p_mid, color=show_fills ? color.new(c_up_1, 93) : na, title="Z-Breathing High")
fill(p_mid, p_dn1, color=show_fills ? color.new(c_dn_1, 93) : na, title="Z-Breathing Low")
fill(p_dn1, p_dn2, color=show_fills ? color.new(c_dn_2, 90) : na, title="Z-Alert Low")
fill(p_dn2, p_dn3, color=show_fills ? color.new(c_dn_3, 88) : na, title="Z-Exhaustion Low")

// ── Global score — main line ──
plot(scr_glb, "Kinetic Score", color=scr_color, linewidth=3, style=plot.style_line)
prob_abs = scr_glb >= 50 ? scr_glb : 100.0 - scr_glb

// ========================================================================================================
// INFORMATION PANEL
// ========================================================================================================
if show_panel and barstate.islast
    tbl_p = panel_pos == "Bottom Right" ? position.bottom_right :  panel_pos == "Bottom Left"  ? position.bottom_left  :   panel_pos == "Top Right"    ? position.top_right    : position.top_left
    var table tbl = table.new(tbl_p, 2, 7,
         border_width=1, border_color=color.new(c_neutral, 70),
         frame_width=2,  frame_color=color.new(c_black, 20))

    // Header
    table.cell(tbl, 0, 0, "📈 Kinetic Oscillator", text_color=color.new(c_dn_4, 0),   text_size=font_size, bgcolor=color.new(c_black, 10), text_halign=text.align_center)
    table.cell(tbl, 1, 0, "5-TF Probability Engine", text_color=color.new(c_neutral, 30), text_size=font_size, bgcolor=color.new(c_black, 10), text_halign=text.align_center)

    // Score
    scr_str = str.tostring(math.round(scr_glb, 1)) + "%"
    table.cell(tbl, 0, 1, s_lbl_scr, text_color=color.new(c_neutral, 20), text_size=font_size, bgcolor=color.new(c_black, 65), text_halign=text.align_left)
    table.cell(tbl, 1, 1, scr_str,   text_color=color.new(scr_color, 0),   text_size=font_size, bgcolor=color.new(c_black, 65), text_halign=text.align_right)

    // Absolute Probability
    prob_str = str.tostring(math.round(prob_abs, 1)) + "%"
    prob_color = prob_abs >= 80 ? c_up_3 : prob_abs >= 65 ? c_up_2 : c_dn_2
    table.cell(tbl, 0, 2, "PROB.",   text_color=color.new(c_neutral, 20), text_size=font_size, bgcolor=color.new(c_black, 70), text_halign=text.align_left)
    table.cell(tbl, 1, 2, prob_str,  text_color=color.new(prob_color, 0),    text_size=font_size, bgcolor=color.new(c_black, 70), text_halign=text.align_right)

    // Direction
    dir_txt = scr_glb >= 50 ? s_sell : (scr_glb <= 50 ? s_buy : s_neutral)
    dir_color = scr_glb >= 50 ? c_up_3 : c_dn_2
    table.cell(tbl, 0, 3, s_lbl_dir, text_color=color.new(c_neutral, 20), text_size=font_size, bgcolor=color.new(c_black, 65), text_halign=text.align_left)
    table.cell(tbl, 1, 3, dir_txt,   text_color=color.new(dir_color, 0),     text_size=font_size, bgcolor=color.new(c_black, 65), text_halign=text.align_right)

    // Channel
    table.cell(tbl, 0, 4, s_lbl_ch,  text_color=color.new(c_neutral, 20), text_size=font_size, bgcolor=color.new(c_black, 70), text_halign=text.align_left)
    table.cell(tbl, 1, 4, channel_txt, text_color=color.new(channel_color, 0),   text_size=font_size, bgcolor=color.new(c_black, 70), text_halign=text.align_right)

    // Rhythm
    table.cell(tbl, 0, 5, s_lbl_rtm, text_color=color.new(c_neutral, 20), text_size=font_size, bgcolor=color.new(c_black, 65), text_halign=text.align_left)
    table.cell(tbl, 1, 5, rhythm_txt, text_color=color.new(rhythm_color, 0),   text_size=font_size, bgcolor=color.new(c_black, 65), text_halign=text.align_right)

    // Black Swan / Squeeze / Climax status — descending priority
    state_txt = scr_glb >= osc_up4 ? s_bs_high : scr_glb <= osc_dn4 ? s_bs_low : vlat_squeeze ? s_squeeze : (vol_z >= 3.0 ? s_climax : "—")
    state_color = scr_glb >= osc_up4 ? c_up_4  : scr_glb <= osc_dn4 ? c_dn_4 : vlat_squeeze ? c_up_2  : (vol_z >= 3.0 ? c_up_3 : c_neutral)
    table.cell(tbl, 0, 6, "STATUS:", text_color=color.new(c_neutral, 20), text_size=font_size, bgcolor=color.new(c_black, 55), text_halign=text.align_left)
    table.cell(tbl, 1, 6, state_txt, text_color=color.new(state_color, 0),   text_size=font_size, bgcolor=color.new(c_black, 55), text_halign=text.align_right)

// ========================================================================================================
// ALERTS
// ========================================================================================================
exhaustion_high  = barstate.isconfirmed and scr_glb >  85 and scr_glb[1] <= 85
exhaustion_low = barstate.isconfirmed and scr_glb <  15 and scr_glb[1] >= 15
squeeze_active  = barstate.isconfirmed and vlat_squeeze  and not vlat_squeeze[1]

// Black Swan: edge-trigger with state variable (arm/disarm)
// Fires when entering zone, locks while inside, re-arms on exit
var bool bs_armed_up = true
var bool bs_armed_dn = true

bool in_swan_up = scr_glb >= osc_up4
bool in_swan_dn = scr_glb <= osc_dn4

// Re-arm when exiting the zone
if not in_swan_up
    bs_armed_up := true
if not in_swan_dn
    bs_armed_dn := true

// Trigger (fires only if armed)
bs_top_trigger  = barstate.isconfirmed and in_swan_up and bs_armed_up
bs_bottom_trigger = barstate.isconfirmed and in_swan_dn and bs_armed_dn

// Disarm after firing
if bs_top_trigger
    bs_armed_up := false
if bs_bottom_trigger
    bs_armed_dn := false

// Single event — Black Swan triggered (any extreme)
bs_event = bs_top_trigger or bs_bottom_trigger

if al_exhaustion and exhaustion_high
    alert(s_al_exh_h, alert.freq_once_per_bar)
if al_exhaustion and exhaustion_low
    alert(s_al_exh_l, alert.freq_once_per_bar)
if al_squeeze and squeeze_active
    alert(s_al_sqz, alert.freq_once_per_bar)
if al_black_swan and bs_event
    alert(s_al_bs, alert.freq_once_per_bar)

alertcondition(exhaustion_high,  "Buying Exhaustion (Score > 85%)",   "Kinetic Oscillator: Score crossed above 85% — buying exhaustion zone.")
alertcondition(exhaustion_low, "Selling Exhaustion (Score < 15%)",  "Kinetic Oscillator: Score crossed below 15% — selling exhaustion zone.")
alertcondition(squeeze_active,  "Squeeze Active (Volatility Compressed)", "Kinetic Oscillator: Volatility compressed to squeeze territory — explosion imminent.")
alertcondition(bs_event,       "Black Swan (Extreme Zone)",             "Kinetic Oscillator: Score entered Black Swan extreme zone — maximum statistical tension.")
alertcondition(false, "HOW TO SETUP ALERTS (READ)", "Select 'Any alert() function call' in the condition menu.")
````

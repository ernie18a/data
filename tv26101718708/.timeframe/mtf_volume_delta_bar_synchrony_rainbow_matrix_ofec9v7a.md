# MTF Volume Delta Bar Synchrony | Rainbow Matrix

- url: https://www.tradingview.com/script/OFEC9v7A-MTF-Volume-Delta-Bar-Synchrony-Rainbow-Matrix/
- type: indicator
- pine_id: PUB;cedbe0dbdc7e4a87b73a5cd46b0d88ca
- version: 2.0

## Description

GENERAL OVERVIEW
MTF Volume Delta Bar Synchrony is a multi-timeframe volume percentile fusion oscillator that condenses five independent volume readings — one per Fibonacci-spaced timeframe — into a single weighted Master Line, surrounded by per-TF "ghost lines" that fade visually as they diverge from the consensus. When the five timeframes align, the rainbow becomes a solid band; when they spread apart, the disagreement becomes a visible density property of the indicator itself. A compact 7×9 MTF Legend Table surfaces every dimension simultaneously: per-TF volume percentile values, trend direction, divergence flags, Pulse magnitude ratio, and named State classification — with an antenna marker flagging the row whose timeframe matches your chart's native resolution.

Optional Delta Twin Bars project per-candle directional overlays directly onto the price chart via force_overlay=true, combining the oscillator pane and an order-flow approximation in a single indicator. A hybrid Black Swan zone detects volume climax (surge) and squeeze (drought) extremes — either as static 80/20 thresholds (classic) or as a dynamic Fibonacci-scaled channel that adapts to recent volatility. A classic price↔volume divergence engine detects Wyckoff-style "no demand" rallies and selling-climax bottoms on every timeframe and on the Master line.
Designed as a sibling to the MTF RSI Synchrony indicator. Apply both side-by-side for the complete momentum + volume picture: RSI shows where price sits in its momentum range; Volume Synchrony shows whether the move has institutional backing. Same visual signature, same canonical color zones, same Legend Table layout — instant cross-indicator readability.

[image]https://www.tradingview.com/x/jUETBqm9/[/image]

WHAT IS THE THEORY BEHIND THIS INDICATOR

Most volume indicators on TradingView operate on a single timeframe — volume bars, OBV, CVD approximations — and report raw, unbounded volume values that vary wildly across timescales. A 5-minute volume bar of 50,000 contracts is meaningless without context: is that "high" for 5-minute bars on this asset, or "low"? Compared to what window? A trader watching a 5-minute chart cannot intuitively cross-reference whether that surge corresponds to anything notable on the 4-hour view.
This indicator solves the cross-timescale comparison problem by bounding every volume reading to a 0-100 percentile rank: the same scale, regardless of timeframe, regardless of asset. The percentile answers a single question: "where does this bar's volume sit in the distribution of recent volume on this timeframe?" — a number anyone can read at a glance.
Five percentile readings are then fused via canonical Fibonacci weights (0.15 / 0.20 / 0.25 / 0.25 / 0.15 — peak weight on the macro TF3/TF4 where institutional consolidation tends to occur) into a single weighted Master Line. The Master adapts to a self-calibrating Fibonacci channel built from its own highest/lowest values over a configurable lookback, smoothed by EMA. Channel boundaries use the brand's canonical ratios: Z-Breathing (1.50σ), Z-Alert (1.85σ anchor), Z-Exhaustion (2.75σ), Black Swan (3.85σ) — same proportions as the RSI sibling for cross-indicator consistency.
The result is a volume picture that updates in real time, accounts for five timescales simultaneously, encodes "synchrony" itself as a visible rainbow density property, and triggers as an alertable signal when extremes converge.

FEATURES

🔹 Multi-Timeframe Volume Percentile Fusion Engine
🔹 Adaptive Fibonacci Channel (Z-Breathing → Z-Alert → Z-Exhaustion → Black Swan)
🔹 Hybrid Black Swan Zones (static 80/20 or dynamic Fibonacci-scaled)
🔹 Classic Price↔Volume Divergence Detection (per-TF + Master)
🔹 MTF Legend Table (7 columns × 9 rows, multilingual)
🔹 Volume Profile Reading (Pulse magnitude + State classification — 7-tier vocabulary)
🔹 Delta Twin Bars (per-candle chart overlay with 4 display modes + live intra-bar updates)
🔹 Multilingual Interface (EN / PT / ES / RU / ZH)
🔹 Multi-Timeframe Volume Percentile Fusion Engine

What It Does
Aggregates five independent volume percentile readings — one per Fibonacci-spaced timeframe — into a single weighted Master Line. Each per-TF reading is plotted as a "ghost" line that fades by distance to the Master, so the rainbow becomes a visual representation of multi-timeframe consensus.
Method
Default timeframes are 5 / 15 / 60 / 240 / D (Trigger / Intraday / Macro 1 / Macro 2 / Base). On each timeframe, ta.percentrank(volume, length) produces a 0-100 percentile rank with lookahead=barmerge.lookahead_off for anti-repaint integrity. The five percentiles are fused via canonical Fibonacci weights (0.15 / 0.20 / 0.25 / 0.25 / 0.15 — peak weight on TF3 and TF4 where institutional volume tends to consolidate). The Master itself is then clamped to [0,100] for pane containment.
Per-TF length defaults are tuned to each timeframe's natural look-back window:
◇ TF1 (5m): 30 bars = 2.5 hours
◇ TF2 (15m): 50 bars = 12.5 hours
◇ TF3 (60m): 80 bars = 3.3 days
◇ TF4 (240m): 100 bars = 16 days
◇ TF5 (D): 150 bars = ~5 months
Set any per-TF override to 0 to inherit the global default (50). One-size-fits-all 50 bars across timeframes either lags on TF1 (16 hours of stale 5-minute history) or feels too reactive on TF5; the per-TF defaults match each horizon's natural cadence.
Why It Matters
Volume distribution is regime-dependent and timeframe-dependent. A single timeframe view can miss whether a 5-minute volume surge is the leading edge of a broader institutional move (visible on TF3/TF4) or a one-off scalper spike. The fusion engine surfaces alignment and disagreement instantly.

🔹 Adaptive Fibonacci Channel

What It Does
Renders six color-coded bands around the Master Line that adapt to its own recent volatility, using the brand's canonical Fibonacci ratios.
Method
Highest/lowest of the Master over lookback_dyn bars (default 50) are smoothed by EMA (default 10) to form dyn_up and dyn_dn. Channel bands are placed at canonical Fibonacci proportions:
◇ Z-Breathing: 1.50/1.85 ≈ 0.811 of half-channel
◇ Z-Alert: anchor at 1.85σ (the channel boundary itself)
◇ Z-Exhaustion: 2.75/1.85 ≈ 1.486
◇ Black Swan: 3.85/1.85 ≈ 2.081
All six band values are mathematically clamped to [0,100] before rendering, so the rainbow stays inside the visible pane in volatile regimes (no auto-scale stretching). The algorithm itself is preserved bit-exact; only the rendered values are bounded.
Why It Matters
Static thresholds (e.g., 80/20) cannot adapt to regime changes. During a low-volatility consolidation, "70" might be a meaningful surge; during a news-driven trend, "70" might be the new baseline. The Fibonacci channel calibrates the warning levels to the asset's current regime, so the alerts stay informative regardless of market state.

🔹 Hybrid Black Swan Zones

What It Does
Flags volume climax (surge) and squeeze (drought) extremes either at static 80/20 thresholds (top 20% / bottom 20% historically) or at the dynamic Fibonacci 3.85σ band, depending on the operator's preference. Each zone is rendered as a glow line that brightens proportionally as the Master approaches.
Method
By default, Dynamic Black Swan Mode is ON for this indicator (matching the volume distribution's wider range vs canonical RSI). The Black Swan high/low values become osc_up4 / osc_dn4 — the Fibonacci 3.85σ proportion of the Master's channel. Toggle the mode OFF to revert to static 80/20 (top/bottom 20% volume thresholds — classic).
The proximity glow uses the canonical f_calc_glow pattern: transparency = 95 - (1 - dist/range) × 75, where range is the half-channel width. At zero distance, transparency = 20 (solid); at full range distance, transparency = 95 (invisible).
Why It Matters
Black Swan events on volume mark institutional climax moments — news breakouts, capitulation, distribution. The dynamic mode lets the indicator self-calibrate per asset and per regime, so a "climax" on a calm Forex pair and a "climax" on a meme stock both trigger at the appropriate statistical extremes rather than at an arbitrary 80% line.

🔹 Classic Price↔Volume Divergence Detection

What It Does
Detects regular bear divergences (price makes higher high while volume percentile pivot makes lower high — Wyckoff "no demand" rally) and regular bull divergences (price makes lower low while volume percentile pivot makes higher low — selling climax / capitulation). Runs on every individual timeframe AND on the Master line directly.
Method
For each TF, f_classic_divergence_vol(length, lookback) runs inside request.security: it detects pivot highs/lows on the per-TF volume percentile via ta.pivothigh / ta.pivotlow, captures pivot values using ta.valuewhen, and compares the current pivot vs the previous pivot. Default pivot lookback is 5 bars (matches the community standard).
Master divergence runs on the chart-TF directly (no request.security), so it always reflects the current chart resolution's pivot structure. When detected, it renders a connecting line + label between the two pivots on the indicator pane (red for bear, green for bull) and triggers the alert_divergence_native alert if enabled.
Per-TF divergence surfaces in the Legend Table's "Div" column: 🔻 for bear, 🔺 for bull, — for none. Multiple timeframes showing the same divergence direction = stronger conviction signal.
Why It Matters
Divergences between price and volume have been a cornerstone of Wyckoff/Volume Spread Analysis for decades. Most TradingView divergence indicators run on a single timeframe — by detecting per-TF AND Master simultaneously, this indicator surfaces both fast warnings (TF1 divergence) and high-conviction confirmations (Master + multiple TFs aligning).

🔹 MTF Legend Table

What It Does
Compact 7×9 table positioned in a configurable chart corner. Surfaces every dimension of the analysis at a single glance: per-TF resolutions, volume percentile values, trend direction, divergence status, Pulse magnitude, named State classification, plus a Master row and a status row.
Method
The table is rendered via table.new(force_overlay=false) on the indicator pane (kept off the price chart for mobile readability). Per-TF cells use:
◇ Col 0: ● TF label (matches ghost line color) + 📡 antenna marker if this TF == chart's native resolution
◇ Col 1: TF resolution string ("5", "15", "60", "240", "D"...)
◇ Col 2: Volume percentile value (color-coded by zone via the thermal matrix)
◇ Col 3: Trend arrow ▲ rising / ▼ falling / ▬ flat (±0.5 percentile point deadzone to avoid flicker)
◇ Col 4: Div indicator 🔺 bull / 🔻 bear / — none
◇ Col 5: Pulse magnitude ratio (color-coded by intensity tier)
◇ Col 6: State name (multilingual EXTREME / HIGH / ELEVATED / NORMAL / LOW / COMPRESSED / SQUEEZE)
The Master row (row 7) merges cols 0-1 into "🌈 Master (~XhYm)" — the "~XhYm" suffix is the geometric weighted mean of the 5 TF resolutions (same weights as the Master volume fusion), giving you the "effective timeframe" the Master is reading. The status row (row 8) merges cols 0-6 and shows the MTF Divergence summary: Aligned / Strong Top / Strong Bottom / Moderate Top / Moderate Bottom — with background color matching the severity.
All header strings, status messages, and state names support 5 languages via the System Language input (English / Português / Español / Русский / 中文).
Why It Matters
The Legend Table compresses what would otherwise require 5 separate chart panels into a single ~150-pixel-wide compact widget. The antenna marker is especially useful on mobile: it tells you instantly which row is "your" timeframe, so you can scan up/down to see whether faster/slower TFs confirm or contradict.

🔹 Volume Profile Reading — Pulse Magnitude + State Classification

What It Does
Two complementary readings that answer different questions about volume — both surfaced as dedicated columns in the Legend Table.
Method — Pulse Column
Pulse is the ratio volume / SMA(volume, length) per TF. 1.0× = volume at the baseline; below = drought; above = elevated. Color-coded by intensity tier:
◇ < 0.5× → aqua (drought extreme)
◇ 0.5-0.8× → teal (below baseline)
◇ 0.8-1.3× → gray (typical)
◇ 1.3-2.0× → yellow (elevated)
◇ 2.0-3.5× → orange (high activity)
◇ 3.5-6.0× → red (surge)
◇ ≥ 6.0× → purple (climax extreme)
Pulse values cap display at "9.9x+" to avoid overflow in narrow cells.
Method — State Column
State classifies the percentile rank into 7 named tiers using a multilingual dictionary:
◇ ≥ 85 → EXTREME (purple zone — top 15% historically)
◇ 71-85 → HIGH (red — top 30%)
◇ 62-71 → ELEVATED (orange)
◇ 38-62 → NORMAL (yellow / green — middle 24%)
◇ 29-38 → LOW (teal)
◇ 15-29 → COMPRESSED (blue)
◇ ≤ 15 → SQUEEZE (aqua — bottom 15%)
Why It Matters
Pulse and State answer different questions about the same volume reading:
◇ Value (percentile column 2): "Where in the historical distribution?" — a ranking answer.
◇ Pulse (column 5): "How intense vs recent baseline?" — a magnitude answer.
◇ State (column 6): "What's the human-readable label?" — a vocabulary answer.
These three columns together tell a complete story. A bar can be at Percentile 60 (NORMAL state) with Pulse = 3.5x (red surge) — meaning: "this bar's volume isn't historically rare, but it's a massive jump versus what's been happening recently." That's a different signal than Percentile 95 / Pulse = 1.0x (EXTREME state but typical magnitude) — meaning: "this is a rare historical bar, but the magnitude is normal relative to recent activity." The columns disambiguate.

🔹 Delta Twin Bars (Chart Overlay)

What It Does
Renders per-candle directional bars on the price chart (via force_overlay=true) whose dimensions encode the selected volume score and whose color encodes buy/sell pressure approximation. Bridges the gap between this script's oscillator pane and the price action itself.
Method
For each candle, the bar size = candle_range × (score / 100) × user_multiplier. The score source is configurable (Master or any TF1-TF5; default TF1 Trigger for the most responsive read).
Four display modes:
◇ Fixed High: bar always projects above the candle high (regardless of direction)
◇ Fixed Low: bar always projects below the candle low
◇ Dynamic: buy candles get bar above high, sell candles get bar below low (intuitive directional reading)
◇ Dynamic Inverted (default): buy candles get bar BELOW low, sell candles get bar ABOVE high — an order book metaphor where buy pressure builds support and sell pressure presses resistance
Bar color follows the user-configured buy/sell colors (green / red by default — matching the OHLC tick rule: close > open = buy bias, close < open = sell bias). An optional toggle ("Use Master Line Color") overrides this with the Master zone color via the thermal matrix — giving rainbow-colored bars that match the pane oscillator.
Bar width is pixel-controlled (1-8, default 8) via line.new with the user-selected linewidth — visually independent of chart zoom, distinguishable from candle wicks at any chart density.
Two update modes:
◇ Live (default): the current bar's twin bar updates on every tick — score, direction, and color reflect real-time data. When the bar closes, the live line is "frozen" into the confirmed pool. One additional persistent line is used (zero pool overhead).
◇ Confirmed-only: twin bar appears only when the candle closes (useful for backtesting comparisons where intra-bar flicker is unwanted).
The last 500 bars are rendered (Pine v6 line pool limit) with rolling FIFO management — older candles fall out of the pool and lose their twin bar, but the most recent 500 stay live.

🚨 Honest tick-rule disclosure
The buy/sell direction encoding uses the OHLC tick rule — close > open = buy bias, close < open = sell bias. This is NOT order-flow tick-data delta. Pine Script v6 has no tick-by-tick data access in indicator scripts on the free tier. The OHLC approximation is what virtually every "delta" indicator on TradingView free uses; this script discloses it transparently rather than claiming real order flow.
For most use cases (visual confirmation, trend bias, magnitude readings) the OHLC approximation captures the essential information. Traders who need true bid/ask delta should look at paid Order Flow tools or Sierra Chart / Bookmap.
Why It Matters

The Delta Twin Bars combine two analytical layers in a single indicator: the oscillator pane (Master fusion + ghost lines + Legend Table) and the chart overlay (per-candle directional reference). Most TradingView indicators force users to choose between oscillator-only or overlay-only paradigms; this script delivers both via force_overlay=true on selectively-rendered lines, preserving full pane functionality while adding a quick visual reference directly on the price candles.

🔹 Multilingual Interface

What It Does
Translates all HUD labels, status messages, alert text, state classifications, and Legend Table headers to 5 languages: English (default), Português, Español, Русский, 中文 (Chinese). 33 multilingual keys are maintained across all 5 languages.
Method
A single language dropdown input (in the GLOBAL SETTINGS group) selects the active language. The script uses Pine v6's _l == "PT" ? ... : _l == "ES" ? ... ternary chain pattern for each translated string, evaluated once at startup. Configuration tooltips, variable names, and code comments remain in English by convention — this script is designed to be readable to developers globally.
Why It Matters
Trading is a global activity. The Rainbow Matrix product family is designed for traders worldwide; multilingual UI removes a friction point for non-English-native users without adding development overhead.

HOW TO USE

Reading the Rainbow (Pane Oscillator)
◇ Master between 30 and 70 with all 5 ghost lines solid: typical volume profile, no anomaly to flag.
◇ Master entering Z-Alert (orange / teal bands): notable volume deviation — watch for follow-through confirmation across timeframes.
◇ Master in Z-Exhaustion (red high / blue low): elevated probability of climax or drought completing.
◇ Master touches Black Swan High (purple glow): volume climax event — statistically rare top-of-distribution moment, often coincides with news catalysts, breakouts, or capitulation.
◇ Master touches Black Swan Low (aqua glow): volume drought / squeeze — extreme compression, often precedes breakouts when paired with price consolidation.
Reading the Legend Table
The antenna marker (📡) flags your chart's native timeframe. Start your read there, then scan up/down the table to see whether faster/slower TFs confirm or contradict the current volume bias. Look at the relationship between Value (where in distribution), Pulse (how intense vs baseline), and State (named tier) for each row — divergences between these three readings within a single TF are early warnings.
The status row at the bottom summarizes MTF divergence: Aligned (TFs in agreement, default), Strong Top (TF1 ≥ 70 vs TF5 ≤ 30 — fast surge with slow drought), Strong Bottom (TF1 ≤ 30 vs TF5 ≥ 70 — fast quiet with slow surge), or Moderate variants of either.

Reading the Delta Twin Bars (Chart Overlay)
Tall bars = high volume score for that candle's TF source. With Dynamic Inverted mode (default), bars projecting BELOW buy candles signal "support building"; bars projecting ABOVE sell candles signal "resistance pressing" — an order book metaphor. Switch to Dynamic mode for a more intuitive directional read (buy bars project up, sell bars hang down). Use Fixed High/Low for cleaner price action when delta-only context is needed.
Reading Divergences
Master divergence (red line + 🔻 label on the pane) = price made a higher high while Master volume percentile made a lower high — Wyckoff "no demand" rally, often precedes reversal. Master bull divergence (green + 🔺) = price made a lower low while Master volume made a higher low — selling climax, often precedes bottom.
Per-TF divergences in the Legend Table's Div column give early granular warning: a TF1 divergence might fire 5-10 candles before the Master confirms. Multiple TFs aligning on the same divergence direction = high-conviction signal.

Tactical Combinations
◇ Master Black Swan High + Strong Top divergence + Bear Master divergence simultaneously = strongest reversal signal from highs.
◇ Master Black Swan Low + Strong Bottom divergence + Bull Master divergence = strongest reversal signal from lows.
◇ Master SQUEEZE state + multiple TFs SQUEEZE state + Pulse < 0.5x = pre-breakout compression — often precedes expansion events.
◇ Pulse spikes (red / purple tier) preceding percentile shifts = often mark turning points before the percentile catches up.
◇ Pair with MTF RSI Synchrony: Aligned RSI + Aligned Volume = high-conviction setup. Bear RSI div + Bear Volume div on Master simultaneously = strongest reversal signal.

INPUTS EXPLAINED

GLOBAL SETTINGS
◇ System Language (EN / PT / ES / RU / ZH) — affects HUD and alerts only; code stays in English.
◇ Table / Labels Font Size — Tiny / Small (default) / Normal / Large.
MULTI-TIMEFRAME
◇ AI Auto-Sync TFs — when ON, auto-adjusts the 5 TFs based on chart resolution.
◇ TF1-TF5 — manual TF override (defaults: 5/15/60/240/D).
◇ Default Volume Percentile Length — global default (default 50).
◇ TF1-TF5 Length Overrides — per-TF overrides; defaults 30/50/80/100/150; set to 0 to inherit global.

ENGINE
◇ Dynamic Black Swan Mode — ON by default (Fibonacci 3.85σ adaptive). OFF = static 80/20.
◇ Dynamic Channel Lookback (default 50) and Smoothing (default 10).
◇ Divergence Pivot Lookback — default 5 (community standard).

VISUALIZATION
◇ TF1-TF5 Color + Show toggles — TF1 and TF5 visible by default; TF2/3/4 hidden (opt-in).
◇ Ghost Fade Sensitivity — default 3.5 (lines invisible at ~20 percentile points from Master).
◇ Show Master Line / Show Rainbow Fills / Show Black Swan / Show Dynamic Channel — all default ON.
◇ Show MTF Legend Table — default ON.
◇ Show Divergence Column / Pulse Column — both default ON.
◇ Show Master Divergence Chart Line — default ON.
◇ Legend Table Position — Top/Bottom × Left/Right (default Bottom Right).
◇ Show Divergence Event Markers — default OFF (reduces clutter; toggle ON to display triangles).
◇ Show Static Reference Lines — default OFF (cleaner pane on install; toggle ON for 20 / 50 / 80 guides).

ALERTS
◇ Alert on Black Swan crossings (high / low) — default ON.
◇ Alert on Strong MTF Divergence — default ON.
◇ Alert on Z-Exhaustion zone entries — default OFF (opt-in).
◇ Alert on Master Classic Divergence — default ON.

DELTA TWIN BARS
◇ Show Delta Twin Bars — default ON.
◇ Score Source — Master / TF1 (default) / TF2 / TF3 / TF4 / TF5.
◇ Display Mode — Fixed High / Fixed Low / Dynamic / Dynamic Inverted (default).
◇ Buy / Sell Colors + Transparency + Size Multiplier — fully customizable.
◇ Use Master Line Color (override) — default OFF; toggle ON for rainbow-colored bars.
◇ Bar Width (pixels) — 1-8, default 8 (bold, high-visibility).
◇ Lookback (bars) — default 500 (Pine v6 pool maximum).
◇ Live Bar (intra-bar update) — default ON; toggle OFF for confirmed-only rendering.

IMPORTANT NOTES

🔸 Pine Script v6 — uses request.security with lookahead=barmerge.lookahead_off for anti-repaint integrity. The 5 per-TF volume fetches + 5 per-TF Pulse fetches + 5 per-TF divergence fetches + 6 other security calls = 21 total request.security calls; within TradingView's free-tier limits but noteworthy if combining with other heavy multi-TF indicators on the same chart.
🔸 Repaint behavior — historical bars use confirmed close data; the current real-time bar updates as ticks arrive (especially with Live Delta Bars enabled). The pivot-based divergence detection requires div_lookback confirmed bars before triggering — so divergence labels appear on the pivot bar in retrospect, not as live signals. This is standard pivot divergence behavior across all TradingView divergence indicators.
🔸 Tick rule approximation — Delta Twin Bars use the OHLC tick rule (close > open = buy bias) as a direction encoder. This is NOT real order-flow tick data. Pine Script v6 has no tick data access in indicator scripts. Same approximation is used by virtually every "delta" indicator on the TradingView free tier; this script discloses it transparently. For real bid/ask delta, use paid order flow tools.
🔸 Pine v6 line pool limit — Delta Twin Bars are bounded to 500 lines (Pine v6 hard limit). Older candles fall out of the rolling FIFO and lose their twin bar — this is a Pine engine constraint, not a bug. The current bar's live line uses ONE persistent slot reused across bars (no additional pool consumption).
🔸 Fibonacci ratios are canonical — the channel proportions (1.50 / 1.85 / 2.75 / 3.85) match the Rainbow Matrix brand standard across all sibling indicators. They are derived from the brand's design system and are not user-configurable — preserving cross-indicator visual consistency.
🔸 Master effective TF — the "~XhYm" label in the Master row is the geometric weighted mean of the 5 TF resolutions (same weights as the Master fusion: 0.15/0.20/0.25/0.25/0.15). With defaults 5/15/60/240/D, the effective TF is approximately 71 minutes (~1h11m). This tells you the "average horizon" the Master is reading.
🔸 License: MPL 2.0 (Mozilla Public License 2.0) — open source. Free to fork, modify, and republish under the same license terms.

UNIQUENESS

Three pillars differentiate this from the dozens of volume indicators already on TradingView:
1. Multi-timeframe percentile fusion with synchrony as a visual property. Most volume tools operate on a single timeframe with raw unbounded readings. This indicator bounds every reading to a 0-100 percentile scale, fuses five timeframes via Fibonacci-proportioned weights, and expresses synchrony itself as a "rainbow density" — solid when aligned, spread-out when diverging. The disagreement between fast and slow timeframes becomes immediately readable.
2. Three complementary volume readings in one Legend Table. Value (percentile rank), Pulse (magnitude ratio), and State (named tier) answer three different questions about the same volume reading. Most indicators give you one number; this one disambiguates "rare historical event" from "extreme recent magnitude" from "elevated relative position." The combination catches signals that single-metric views miss.
3. Combined oscillator + chart overlay in a single script. Delta Twin Bars project the per-candle volume score and tick-rule direction directly onto the price chart via force_overlay=true, while the full pane oscillator (Master fusion, ghost lines, Legend Table, divergence engine, dynamic channel) continues to operate independently. Most TradingView indicators force you to choose between oscillator-only or overlay-only paradigms; this script gives you both, with honest disclosure about the OHLC tick rule approximation.

Rainbow Matrix AI | Multi-timeframe institutional analysis tools for traders.
🌐 rainbowmatrix.ai
✉️ Contact: contact@rainbowmatrix.ai

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © rainbowmatrix
//

// ════════════════════════════════════════════════════════════════════════════════
// MTF VOLUME DELTA BAR SYNCHRONY
//
// A multi-timeframe Volume Percentile fusion oscillator that aggregates five
// independent volume percentile readings — one per Fibonacci-spaced timeframe —
// into a single weighted Master Line, with each per-timeframe percentile plotted
// as a ghost line that fades by distance to the Master. When the five timeframes
// align, the rainbow is solid; when they diverge, the ghost lines spread visibly
// across the pane. A compact 7×9 MTF Legend Table surfaces all five timeframes'
// volume percentile values, trend direction, divergence flags, Pulse magnitude
// (volume vs SMA baseline), and named State classification (SQUEEZE / COMPRESSED
// / LOW / NORMAL / ELEVATED / HIGH / EXTREME) simultaneously, with an antenna
// marker flagging the row whose timeframe matches the chart's native resolution.
// A hybrid Black Swan zone (static 80/20 or dynamic Fibonacci-scaled channel)
// flags volume climax (surge) and squeeze (drought) extremes as they form.
// A classic price↔volume divergence engine detects regular bear (rally weakening)
// and bull (selling climax) divergences on each timeframe and on the Master line.
// Optional Delta Twin Bars render per-candle directional overlays on the price
// chart (via force_overlay) — pixel-controlled width, four display modes (Fixed
// High / Fixed Low / Dynamic / Dynamic Inverted), six score sources (Master or
// any individual TF), and live intra-bar updating. Direction encoding uses the
// OHLC tick rule (close > open = buy bias) — see Important Notes below for the
// honest tick-data approximation disclosure.
//
// COMPANION INDICATOR:
//   Designed as a sibling to MTF RSI Synchrony. Apply both side-by-side for the
//   complete momentum + volume picture: RSI shows where price sits in its
//   momentum range; Volume Synchrony shows whether the move has institutional
//   backing. Same visual signature, same canonical color zones, same Legend
//   Table layout — instant cross-indicator readability.
//
// METHOD:
//   1. For each of 5 user-configured timeframes (default 5/15/60/240/D), the
//      script extracts via request.security() an independent volume percentile
//      reading — ta.percentrank(volume, length) — with lookahead=barmerge.lookahead_off
//      for anti-repaint integrity. The percentile answers "where is this bar's
//      volume in the distribution of recent volume?" on a bounded 0-100 scale.
//      Per-TF length defaults (v1.6+) are tuned to each timeframe's natural
//      look-back: TF1=30 (2.5h on 5m), TF2=50 (12h on 15m), TF3=80 (3 days on
//      1h), TF4=100 (16 days on 4h), TF5=150 (~5 months on Daily). Override
//      any TF to a custom value via the per-TF inputs; set to 0 to inherit the
//      global default (50).
//   2. The five per-timeframe percentile values are aggregated via canonical
//      Fibonacci weights (0.15 / 0.20 / 0.25 / 0.25 / 0.15 — peak weight on
//      macro TF3/TF4 where institutional volume consolidates) into the weighted
//      Master Line.
//   3. Each per-timeframe percentile is plotted as a ghost line with transparency
//      inversely proportional to its absolute distance from the Master, using
//      the canonical fade-by-distance pattern. Default sensitivity 3.5 makes
//      lines effectively invisible at ~20 percentile points away from the Master
//      — synchrony itself becomes a visible density property of the rainbow.
//   4. The Master is plotted against an adaptive Fibonacci channel built from
//      its own highest/lowest over a configurable lookback, smoothed by EMA.
//      Channel boundaries: Z-Breathing (1.50σ), Z-Alert (1.85σ anchor),
//      Z-Exhaustion (2.75σ), Black Swan (3.85σ).
//   5. Black Swan zones operate in hybrid mode: static 80/20 by default
//      (top 20% / bottom 20% volume extremes — classic percentile thresholds),
//      or dynamic adapt-to-volatility via the Fibonacci 3.85σ proportion of
//      the Master channel when toggled.
//   6. A classic price↔volume divergence engine runs on each of the 5
//      timeframes (via request.security) and on the Master line directly
//      (chart-TF price). Detects:
//        • Bear divergence (top): price makes higher high while volume
//          percentile pivot makes lower high — rally on weakening conviction
//          (Wyckoff "no demand" pattern).
//        • Bull divergence (bottom): price makes lower low while volume
//          percentile pivot makes higher low — selling climax / capitulation
//          (Wyckoff exhaustion pattern).
//      Master divergence renders a chart line + label on the indicator pane;
//      per-TF divergence surfaces in the Legend Table's "Div" column.
//   7. The MTF Legend Table displays per-timeframe data: a color-coded
//      percentile value using the canonical Rainbow Palette zone classification,
//      a trend arrow (▲ rising, ▼ falling, ▬ flat — ±0.5 percentile point
//      deadzone to avoid flicker), a Div column (bull / bear / —), a
//      Pulse column showing volume magnitude ratio (current volume / SMA volume,
//      color-coded by intensity tier — drought to climax), plus a Master row
//      showing the weighted fusion of all five dimensions with an effective-TF
//      label (geometric weighted mean of the 5 TF resolutions). A status row at
//      the bottom tracks MTF alignment between TF1 and TF5: Strong (≥ 70 vs ≤ 30,
//      or mirrored) and Moderate (≥ 65 vs ≤ 40) divergences with directional
//      Top / Bottom labeling. An antenna marker flags the row whose
//      timeframe equals the chart's native resolution. The Pulse column
//      complements Value: Value answers "where in the distribution?", Pulse
//      answers "how intense vs baseline?" — together they distinguish
//      "high relative" from "extreme magnitude" events.
//   8. Delta Twin Bars: optional per-candle overlay rendered on the price chart
//      (via force_overlay=true) showing a sized colored bar whose dimensions
//      encode the selected score (Master or TF1-TF5) and whose color encodes
//      buy/sell pressure via OHLC tick rule (close > open = buy, close < open
//      = sell). Size formula: candle_range × (score / 100) × user_multiplier.
//      Four display modes available: Fixed High, Fixed Low, Dynamic (default
//      — buy bars above, sell bars below), or Dynamic Inverted. Width is
//      controlled in pixels (1-8) via line.new with the user-selected linewidth
//      — visually independent of chart zoom, distinguishable from candle wicks.
//      Default color: Master zone (rainbow palette via thermal matrix). Two
//      update modes:
//        • Live (default, show_delta_live=TRUE): the current bar's twin bar
//          updates on every tick — score/direction/color reflect real-time data;
//          when the bar closes, the live line is "frozen" into the confirmed
//          pool. One additional persistent line is used (no extra pool consumption).
//        • Confirmed-only (show_delta_live=FALSE): twin bar appears only when
//          the candle closes (classic v1.4 behavior). Useful for backtesting
//          comparisons where intra-bar flicker is unwanted.
//      Last 500 bars (Pine v6 line pool limit) with rolling FIFO management.
//      IMPORTANT: this is NOT order flow tick-data delta. Pine v6 has no tick
//      data access in indicator scripts. The OHLC tick rule is an approximation
//      used by virtually all "delta" indicators on TradingView free tier.
//
// ORIGINALITY:
//   Most volume indicators on TradingView operate on a single timeframe
//   (volume bars, OBV, CVD approximations) and apply unbounded raw volume
//   readings without expressing how that single value compares across
//   timescales. MTF Volume Delta Bar Synchrony bounds the metric to a 0-100 percentile
//   scale (matching the RSI sibling for cross-indicator comparison), fuses
//   five timeframes via Fibonacci-proportioned weights, expresses synchrony
//   as a visible "rainbow density" property (solid when aligned, spread-out
//   when diverging), surfaces fast-vs-slow volume divergences as discrete
//   events ranked by intensity, and detects classic price↔volume regular
//   divergences both per-TF and on the Master line. The Fibonacci channel
//   applied to the Master adapts the Black Swan threshold to current volume
//   volatility — replacing fixed 80/20 thresholds with a self-calibrating
//   extreme zone.
//   The Delta Twin Bars feature combines two analytical layers in one indicator:
//   the volume percentile fusion (pane oscillator) and the directional approximation
//   (chart overlay). Most TradingView indicators force users to choose between
//   oscillator-only or overlay-only paradigms; this script delivers both via
//   force_overlay=true on selectively-rendered boxes, preserving the full pane
//   functionality (Legend Table, divergence engine, dynamic channel) while
//   adding a quick visual reference directly on the price candles.
//
// HOW TO USE:
//   - Master between 30 and 70 with all 5 lines solid: typical volume profile,
//     no anomaly to flag.
//   - Master entering Z-Alert (orange/teal): notable volume deviation — watch
//     for follow-through confirmation across timeframes.
//   - Master in Z-Exhaustion (red high / blue low): elevated probability of
//     climax (top) or drought (bottom) completing.
//   - Master touches Black Swan High (purple glow): volume climax event —
//     statistically rare top-of-distribution moment, often coincides with
//     news catalysts, breakouts, or capitulation.
//   - Master touches Black Swan Low (aqua glow): volume drought / squeeze —
//     extreme compression, often precedes breakouts when paired with price
//     consolidation.
//   - Classic divergence line on Master (red bear / green bull): price↔volume
//     regular divergence detected. Bear = rally losing volume support; bull =
//     selling exhausting on heavier-than-prior-low volume (climax).
//   - Legend Table 'Div' column: per-TF divergence breakdown. Multiple TFs
//     showing the same divergence direction = stronger conviction signal.
//   - Legend Table 'Pulse' column: per-TF volume magnitude ratio. Reading
//     guide: gray (0.8-1.3x) = typical; yellow (1.3-2.0x) = elevated; orange
//     (2.0-3.5x) = high activity; red (3.5-6.0x) = surge; purple (≥ 6.0x) =
//     climax extreme; teal (0.5-0.8x) = below baseline; aqua (< 0.5x) =
//     drought extreme. Multiple TFs simultaneously red/purple = high-conviction
//     climax event. Pulse spikes preceding percentile shifts often mark
//     turning points.
//   - MTF Divergence status row lit Strong (TF1 ≥ 70 vs TF5 ≤ 30 or mirrored):
//     fast and slow timeframes telling opposite volume stories. Top variant =
//     LTF volume surge with HTF in drought (potential intra-bar reversal).
//     Bottom variant = HTF surge with LTF quiet (accumulation phase).
//   - Ghost lines visibly spread far from Master: synchrony breakdown — wait
//     for re-convergence before high-conviction entries.
//   - Legend Table reading: the antenna marker shows your chart's
//     native timeframe — start your read there, then scan up/down the table
//     to see whether faster/slower timeframes confirm or contradict the
//     current volume bias.
//   - Delta Twin Bars (price chart overlay): the sized colored bars next to
//     each candle show the selected score's magnitude with directional encoding.
//     Reading:
//       • Tall bar = high volume score for that candle's TF source
//       • Bar color (default) = Master zone color via the thermal matrix
//         (purple climax → red surge → orange high → yellow elevated →
//          green/yellow normal → teal low → blue compressed → aqua drought)
//       • Optional buy/sell color mode (toggle "Use Master Line Color" OFF):
//         green = candle closed above open (buy bias via tick rule),
//         red = candle closed below open (sell bias via tick rule)
//     Width is set in pixels (1-8, default 3) via "Bar Width (pixels)" input
//     — the bars stay at the chosen width independent of chart zoom, making
//     them visually distinct from candle wicks. Use Dynamic mode (default) for
//     intuitive directional reading: bars project up from candle highs on buy
//     candles, hang down from candle lows on sell candles. Use Fixed High/Low
//     for cleaner price action when delta-only context is needed. Use Dynamic
//     Inverted for an order book metaphor (support/resistance pressure
//     visualization).
//   - Delta Bars live mode (v1.6+ default): the current bar's twin bar updates
//     on every tick — see real-time changes in score and direction as the bar
//     forms. Useful for fast-moving markets where you want to spot delta shifts
//     before close. Toggle "Live Bar (intra-bar update)" OFF for classic
//     close-only rendering (useful for backtesting comparisons where intra-bar
//     flicker may distract).
//   - Best practice: pair with MTF RSI Synchrony. Aligned RSI + aligned
//     Volume = high-conviction setups. Bear RSI div + Bear Volume div on
//     Master simultaneously = strongest reversal signal.
//
// MULTILINGUAL UI:
//   HUD labels and alert messages are translated to 5 languages (English,
//   Português, Español, Русский, 中文) via the System Language input.
//   Configuration tooltips, variable names and code comments remain in
//   English by convention.
//
// ════════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("MTF Volume Delta Bar Synchrony | Rainbow Matrix",
     overlay         = false,
     max_bars_back   = 1440,
     max_lines_count = 500,
     max_labels_count = 500,
     max_boxes_count = 500)

// ========================================================================================================
// COLOR PALETTE (Rainbow Matrix canonical — do NOT change)
// ========================================================================================================
c_up_4 = color.purple     // Black Swan High (extreme overbought)
c_up_3 = color.red        // Z-Exhaustion High
c_up_2 = color.orange     // Z-Alert High
c_up_1 = color.yellow     // Z-Breathing High
c_dn_1 = color.green      // Z-Breathing Low
c_dn_2 = color.teal       // Z-Alert Low
c_dn_3 = color.blue       // Z-Exhaustion Low
c_dn_4 = color.aqua       // Black Swan Low (extreme oversold)
c_neutral = color.gray
c_black   = color.black

// ========================================================================================================
// GLOBAL SETTINGS
// ========================================================================================================
g_global = "GLOBAL SETTINGS"
language = input.string("English", "System Language",
     options = ["English", "Português", "Español", "Русский", "中文 (Chinese)"],
     group   = g_global,
     tooltip = "Language for HUD labels and alert messages. Affects only the on-chart UI text; code, comments, and configuration tooltips remain in English.")

string _l = language == "Português" ? "PT" : language == "Español" ? "ES" : language == "Русский" ? "RU" : language == "中文 (Chinese)" ? "ZH" : "EN"

font_size_table  = input.string("Small", "Table Font Size",  options = ["Tiny", "Small", "Normal", "Large"], group = g_global, tooltip = "Font size for the per-timeframe and Master data rows of the MTF Legend Table (RSI values and trend arrows).")
font_size_labels = input.string("Small", "Labels Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = g_global, tooltip = "Font size for the header and status rows of the MTF Legend Table.")

f_size(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

sz_tbl = f_size(font_size_table)
sz_lbl = f_size(font_size_labels)

// ========================================================================================================
// MULTI-TIMEFRAME
// ========================================================================================================
g_tf = "MULTI-TIMEFRAME"
auto_tf    = input.bool(false, "AI Auto-Sync TFs", group = g_tf, tooltip = "When ON, the engine auto-adjusts the five timeframes based on your current chart resolution to keep the Fibonacci spacing meaningful. When OFF, your manual values below are used.")
m_tf1      = input.string("5",   "TF 1 — Trigger (Minutes, D, W)",    group = g_tf, tooltip = "Fastest timeframe (innermost ghost line). Default 5m. Weight 0.15 in the Master Volume fusion.")
m_tf2      = input.string("15",  "TF 2 — Intraday (Minutes, D, W)",   group = g_tf, tooltip = "Intraday timeframe. Default 15m. Weight 0.20.")
m_tf3      = input.string("60",  "TF 3 — Macro 1 (Minutes, D, W)",    group = g_tf, tooltip = "First macro reference. Default 60m (1h). Weight 0.25 (peak).")
m_tf4      = input.string("240", "TF 4 — Macro 2 (Minutes, D, W)",    group = g_tf, tooltip = "Second macro reference. Default 240m (4h). Weight 0.25 (peak).")
m_tf5      = input.string("D",   "TF 5 — Base/Daily (Minutes, D, W)", group = g_tf, tooltip = "Slowest anchor (outermost context). Default Daily. Weight 0.15.")
vol_length_default = input.int(50, "Default Volume Percentile Length", minval = 10, group = g_tf, tooltip = "Default lookback window for volume percentile rank applied to all 5 timeframes UNLESS a per-TF override below is set to a non-zero value. Default 50 = stable baseline. Lower (20-30) = more responsive, more noise. Higher (100-200) = smoother, slower to react.")
vol_len_tf1 = input.int(30, "TF1 Volume Percentile Length Override (0 = use default)", minval = 0, group = g_tf, tooltip = "Per-TF Volume Percentile period override. 0 = inherit from Default Volume Percentile Length above. Set to a positive integer to use a different RSI period for this timeframe only. Example: use 30 here for fast read on the Trigger TF while keeping 50 on slower TFs.")
vol_len_tf2 = input.int(50, "TF2 Volume Percentile Length Override (0 = use default)", minval = 0, group = g_tf, tooltip = "Per-TF Volume Percentile period override. 0 = inherit from Default Volume Percentile Length above. Set to a positive integer to use a different RSI period for this timeframe only.")
vol_len_tf3 = input.int(80, "TF3 Volume Percentile Length Override (0 = use default)", minval = 0, group = g_tf, tooltip = "Per-TF Volume Percentile period override. 0 = inherit from Default Volume Percentile Length above. Set to a positive integer to use a different RSI period for this timeframe only.")
vol_len_tf4 = input.int(100, "TF4 Volume Percentile Length Override (0 = use default)", minval = 0, group = g_tf, tooltip = "Per-TF Volume Percentile period override. 0 = inherit from Default Volume Percentile Length above. Set to a positive integer to use a different RSI period for this timeframe only.")
vol_len_tf5 = input.int(150, "TF5 Volume Percentile Length Override (0 = use default)", minval = 0, group = g_tf, tooltip = "Per-TF Volume Percentile period override. 0 = inherit from Default Volume Percentile Length above. Set to a positive integer to use a different RSI period for this timeframe only. Example: use 100 here on the Base TF for a smoother slow read.")

string tf_1 = ""
string tf_2 = ""
string tf_3 = ""
string tf_4 = ""
string tf_5 = ""

if auto_tf
    if timeframe.isseconds or (timeframe.isintraday and timeframe.multiplier <= 5)
        tf_1 := "5",   tf_2 := "15",  tf_3 := "60",  tf_4 := "240", tf_5 := "D"
    else if timeframe.isintraday and timeframe.multiplier <= 15
        tf_1 := "15",  tf_2 := "60",  tf_3 := "240", tf_4 := "D",   tf_5 := "W"
    else if timeframe.isintraday and timeframe.multiplier <= 60
        tf_1 := "60",  tf_2 := "240", tf_3 := "D",   tf_4 := "W",   tf_5 := "M"
    else
        tf_1 := "240", tf_2 := "D",   tf_3 := "W",   tf_4 := "M",   tf_5 := "M"
else
    tf_1 := m_tf1, tf_2 := m_tf2, tf_3 := m_tf3, tf_4 := m_tf4, tf_5 := m_tf5

// ========================================================================================================
// ENGINE
// ========================================================================================================
g_engine = "ENGINE"
dynamic_extremes = input.bool(false, "Dynamic Black Swan Mode",
     group = g_engine,
     tooltip = "OFF (default): Black Swan zones at fixed 80/20 (top 20% / bottom 20% volume extremes). ON: Black Swan zones adapt dynamically to the Master Line's volatility using the canonical Fibonacci 3.85σ proportion.")
lookback_dyn = input.int(50, "Dynamic Channel Lookback",  minval = 10, group = g_engine, tooltip = "Lookback window for highest/lowest of the Master Line. Larger = smoother channel envelope.")
smooth_dyn   = input.int(10, "Dynamic Channel Smoothing", minval = 1,  group = g_engine, tooltip = "EMA smoothing applied to the dynamic channel envelope. Larger = slower response.")
div_lookback = input.int(5,  "Divergence Pivot Lookback", minval = 3, maxval = 20, group = g_engine, tooltip = "Pivot lookback (bars before/after) for classic price↔Volume Percentile divergence detection. Lower = more sensitive (smaller pivots), higher = more confirmed (larger pivots). Default 5 matches most community divergence indicators.")

// ========================================================================================================
// VISUALIZATION
// ========================================================================================================
g_visual = "VISUALIZATION"
color_tf1 = input.color(c_up_1, "TF 1 Color (Trigger)",  group = g_visual, inline = "tf12", tooltip = "Color of the TF1 (fastest) Volume percentile ghost line.")
color_tf2 = input.color(c_up_2, "TF 2 Color (Intraday)", group = g_visual, inline = "tf12", tooltip = "Color of the TF2 Volume percentile ghost line.")
color_tf3 = input.color(c_up_3, "TF 3 Color (Macro 1)",  group = g_visual, inline = "tf34", tooltip = "Color of the TF3 Volume percentile ghost line.")
color_tf4 = input.color(c_dn_3, "TF 4 Color (Macro 2)",  group = g_visual, inline = "tf34", tooltip = "Color of the TF4 Volume percentile ghost line.")
color_tf5 = input.color(c_dn_2, "TF 5 Color (Base)",     group = g_visual, tooltip = "Color of the TF5 Volume percentile ghost line.")

show_tf1 = input.bool(true, "Show TF1 Ghost Line (Trigger)",  group = g_visual, tooltip = "Hide/show the TF1 Volume percentile ghost line. The TF still contributes to the Master fusion regardless of this toggle — this is purely visual.")
show_tf2 = input.bool(false, "Show TF2 Ghost Line (Intraday)", group = g_visual, tooltip = "Hide/show the TF2 Volume percentile ghost line. TF data still feeds the Master.")
show_tf3 = input.bool(false, "Show TF3 Ghost Line (Macro 1)",  group = g_visual, tooltip = "Hide/show the TF3 Volume percentile ghost line. TF data still feeds the Master.")
show_tf4 = input.bool(false, "Show TF4 Ghost Line (Macro 2)",  group = g_visual, tooltip = "Hide/show the TF4 Volume percentile ghost line. TF data still feeds the Master.")
show_tf5 = input.bool(false, "Show TF5 Ghost Line (Base)",     group = g_visual, tooltip = "Hide/show the TF5 Volume percentile ghost line. TF data still feeds the Master.")
ghost_sensitivity = input.float(3.5, "Ghost Fade Sensitivity", minval = 0.5, maxval = 10.0, step = 0.5, group = g_visual, tooltip = "Higher = ghost lines fade more aggressively as they diverge from the Master. Lower = lines stay solid longer. Default 3.5 (dist=20 percentile points → invisible).")

show_master_line    = input.bool(true, "Show Master Line (Rainbow)",             group = g_visual, tooltip = "Plot the weighted Master Volume Percentile line, colored by zone using the canonical Rainbow Palette.")
show_master_level   = input.bool(true, "Show Master Level Line",                 group = g_visual, tooltip = "Draw a horizontal line at the Master's current value, extended right. Updates on the last bar. Colored by the Master's zone color.")
master_hist_width   = input.int(8, "Histogram Width (Master)", minval = 1, group = g_visual, tooltip = "Column thickness of the Master histogram. The five per-TF ghost histograms use this minus 1 (floor 1).")
master_transp       = input.int(30, "Master Bar Transparency", minval = 0, maxval = 100, group = g_visual, tooltip = "Transparency of the Master histogram bars (0 = opaque, 100 = invisible). Does not affect the Master Level Line.")
show_blackswan      = input.bool(true, "Show Black Swan Lines + Glow",           group = g_visual, tooltip = "Plot the Black Swan High/Low lines with proximity-based glow. No fill underneath (line + glow only).")
show_dyn_channel    = input.bool(false, "Show Dynamic Channel Envelope",          group = g_visual, tooltip = "Plot the dashed dynamic channel (Up / Mid / Down) that adapts to the Master's recent volatility.")
show_legend_table = input.bool(true, "Show MTF Legend Table",         group = g_visual, tooltip = "Show the MTF Legend Table on the indicator pane. Displays all 5 timeframes with RSI value, trend arrow and zone color, plus the weighted Master row and a divergence summary row. An antenna marker (📡) flags the row whose timeframe matches the chart's native resolution.")
show_div_column   = input.bool(false, "Show Divergence Column",        group = g_visual, tooltip = "Show the 'Div' column in the MTF Legend Table. Displays per-timeframe classic divergence detection: 🔺 = bull (price made lower low + RSI made higher low), 🔻 = bear (price made higher high + RSI made lower high), — = no active divergence. When OFF, divergence cells render empty (column space preserved).")
show_pulse_column = input.bool(true, "Show Pulse Column",             group = g_visual, tooltip = "Show the 'Pulse' column in the MTF Volume Legend Table. Displays per-timeframe volume magnitude ratio (current volume / SMA volume). 1.0x = baseline, below = drought, above = elevated. Color-coded: gray (typical), yellow (elevated), orange (high), red (surge), purple (climax extreme). Complements the Value column (percentile rank): Value shows WHERE in the distribution, Pulse shows HOW INTENSE vs baseline. When OFF, pulse cells render empty.")
show_div_chart_line = input.bool(false, "Show Master Divergence Chart Line", group = g_visual, tooltip = "Draw a connecting line between the two pivots that form each Master divergence event, plus a label at the second pivot (🔺 bull / 🔻 bear). Master divergence integrates the weighted view across all 5 timeframes — see the 'Div' column for per-TF breakdown.")
legend_pos        = input.string("Bottom Right", "Legend Table Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = g_visual, tooltip = "Position of the MTF Legend Table on the indicator pane. Four corners available.")
show_div_markers  = input.bool(false, "Show Divergence Event Markers", group = g_visual, tooltip = "Plot directional triangle markers when a Strong or Moderate MTF Divergence is detected. ▼ at the top (Top divergences = potential reversal from highs); ▲ at the bottom (Bottom divergences = potential reversal from lows). Strong = saturated colors (red / green); Moderate = transitional colors (orange / teal). Markers persist while the divergence condition holds. Independent of the Strong Divergence alert toggle in the ALERTS group.")
div_markers_pos   = input.string("Indicator Pane", "Divergence Markers Position", options = ["Indicator Pane", "Chart Overlay"], group = g_visual, tooltip = "Where to render the divergence markers. \"Indicator Pane\" = top/bottom edges of the oscillator pane (next to the Master line); \"Chart Overlay\" = above/below the price bars on the main chart.")

// ========================================================================================================
// ALERTS
// ========================================================================================================
g_alerts = "ALERTS"
alert_blackswan_high = input.bool(true,  "Alert on Master crossing Black Swan High", group = g_alerts, tooltip = "Fires once per bar when the Master Volume Percentile crosses ABOVE the Black Swan High (80 or dynamic).")
alert_blackswan_low  = input.bool(true,  "Alert on Master crossing Black Swan Low",  group = g_alerts, tooltip = "Fires once per bar when the Master Volume Percentile crosses BELOW the Black Swan Low (20 or dynamic).")
alert_divergence     = input.bool(false,  "Alert on STRONG MTF Divergence",           group = g_alerts, tooltip = "Fires when TF1 and TF5 reach opposite Volume Percentile extremes (≥70 vs ≤30).")
alert_master_extreme = input.bool(false, "Alert on Master entering Z-Exhaustion zone", group = g_alerts, tooltip = "Fires when the Master Volume Percentile enters the Z-Exhaustion zone (red high / blue low).")
alert_divergence_native = input.bool(false, "Alert on Master Classic Divergence",      group = g_alerts, tooltip = "Fires when classic divergence is detected on the Master line (price↔Volume Percentile on the chart timeframe). Master integrates the weighted MTF view, so this alert captures the most synthesized divergence signal. For per-TF breakdown, see the 'Div' column in the Legend Table.")

// ========================================================================================================
// DELTA TWIN BARS — overlay feature
//   Renders a per-candle "twin bar" on the price chart whose size encodes a selected volume score
//   (Master or any of TF1-TF5) and whose direction encodes buy/sell pressure via OHLC tick rule.
//   Rendered via box.new(force_overlay=true) — appears on the price chart despite this script
//   being a pane oscillator (overlay=false).
//
//   IMPORTANT: This is NOT order flow tick-data delta. It is an approximation via OHLC tick rule
//   (close > open = buy bias, close < open = sell bias). Pine v6 has no tick data access in
//   indicator scripts. Same approximation used by most "delta" indicators on TradingView free tier.
// ========================================================================================================
g_delta = "DELTA TWIN BARS"

show_delta_bars = input.bool(true, "Show Delta Twin Bars", group = g_delta, tooltip = "Render per-candle twin bars on the price chart using force_overlay. Bar size encodes the selected volume score (Master or TF1-TF5); bar direction encodes buy/sell bias via OHLC tick rule (close > open = buy, close < open = sell). NOT order flow tick-data delta — approximation via candle direction. Last N candles are rendered (see lookback), older candles fall out of the rolling box pool.")

delta_source = input.string("TF1 (Trigger)", "Score Source", options = ["Master", "TF1 (Trigger)", "TF2 (Intraday)", "TF3 (Macro 1)", "TF4 (Macro 2)", "TF5 (Base)"], group = g_delta, tooltip = "Which volume percentile reading to use for the twin bar size. Master (default) uses the Fibonacci-weighted fusion across all 5 TFs. Individual TF selections use that timeframe's raw percentile.")

delta_mode = input.string("Dynamic Inverted", "Display Mode", options = ["Fixed High", "Fixed Low", "Dynamic", "Dynamic Inverted"], group = g_delta, tooltip = "Where to render the twin bars relative to each candle:\n• Fixed High: always above the candle high (regardless of buy/sell direction)\n• Fixed Low: always below the candle low\n• Dynamic (default): buy bar above high, sell bar below low (semantic — green pushes up, red pulls down)\n• Dynamic Inverted: buy bar below low, sell bar above high (order book metaphor — support building / resistance pressing)")

delta_buy_color = input.color(c_dn_1, "Buy Bar Color", group = g_delta, inline = "delta_colors", tooltip = "Color used when the candle closes ABOVE its open (tick rule buy bias).")

delta_sell_color = input.color(c_up_3, "Sell Bar Color", group = g_delta, inline = "delta_colors", tooltip = "Color used when the candle closes BELOW its open (tick rule sell bias).")

delta_use_master_color = input.bool(false, "Use Master Line Color (override)", group = g_delta, tooltip = "When ON, twin bars use the Master Line's zone color (rainbow palette via thermal matrix) instead of the buy/sell colors above. The buy/sell color inputs are ignored when this is enabled.")

delta_transparency = input.int(50, "Transparency", minval = 0, maxval = 100, group = g_delta, tooltip = "Twin bar transparency. 0 = fully opaque, 100 = invisible. Default 50 = balanced visibility without obscuring price action.")

delta_size_mult = input.float(1.0, "Size Multiplier", minval = 0.5, maxval = 3.0, step = 0.1, group = g_delta, tooltip = "Multiplier applied to twin bar size after the score scaling. 1.0 (default) = score × candle range. 0.5 = half-size (subtle). 3.0 = 3× size (loud). Adjust per asset volatility profile.")

delta_bar_width = input.int(8, "Bar Width (pixels)", minval = 1, maxval = 8, group = g_delta, tooltip = "Visual thickness of the twin bars in pixels (NOT bar units). Independent of chart zoom — bars stay at the chosen width regardless of how zoomed in/out the chart is. Default 8 = bold and prominent (operator preference for high-visibility setups). Range 1 (hair-thin) to 8 (very bold). Adjust per personal preference and chart density.")

delta_lookback = input.int(500, "Lookback (bars)", minval = 50, maxval = 500, group = g_delta, tooltip = "Number of recent bars to render twin bars on. Limited to 500 (Pine v6 box.new pool size). Older candles fall out of the rolling FIFO and lose their twin bar — this is a Pine engine limitation, not a bug.")

show_delta_live = input.bool(true, "Live Bar (intra-bar update)", group = g_delta, tooltip = "When ON, the twin bar for the current (forming) candle updates LIVE on every tick — score, direction, and color reflect real-time data. When OFF, twin bars only appear after a candle closes (classic v1.4 behavior). Live mode uses ONE persistent line that gets promoted to the confirmed pool when the bar closes. No additional pool consumption.")

// ========================================================================================================
// HELPER FUNCTIONS
// ========================================================================================================

// Canonical weighted MTF average (Fibonacci-proportioned weights, peak on macro TF3/TF4)
// Weights: 0.15 / 0.20 / 0.25 / 0.25 / 0.15 — peak weight on macro (TF3 / TF4)
f_avg5_weighted(v1, v2, v3, v4, v5) =>
    w1 = 0.15
    w2 = 0.20
    w3 = 0.25
    w4 = 0.25
    w5 = 0.15
    w_total = (na(v1) ? 0.0 : w1) + (na(v2) ? 0.0 : w2) + (na(v3) ? 0.0 : w3) + (na(v4) ? 0.0 : w4) + (na(v5) ? 0.0 : w5)
    w_total > 0 ? (nz(v1) * w1 + nz(v2) * w2 + nz(v3) * w3 + nz(v4) * w4 + nz(v5) * w5) / w_total : na

// Generic fade-by-distance glow (transparency increases with distance from reference)
// Returns transparency: 20 = solid (current at reference) → 95 = invisible (current ≥ range_unit away)
f_calc_glow(float current_value, float reference_value, float range_unit) =>
    int(95 - (math.max(0.0, math.min(1.0, 1.0 - (math.abs(current_value - reference_value) / math.max(range_unit, 0.000001)))) * 75))

// Volume-percentile thermal matrix — maps a 0-100 percentile value to a Rainbow Palette color
// Thresholds use the brand's canonical percentile row classification (62 / 71 / 85 and 38 / 29 / 15, midpoint 50)
f_termal_matrix_vol(float val) =>
    color c = c_neutral
    if not na(val)
        if val >= 85
            c := c_up_4
        else if val >= 71
            c := c_up_3
        else if val >= 62
            c := c_up_2
        else if val >= 50
            c := c_up_1
        else if val > 38
            c := c_dn_1
        else if val > 29
            c := c_dn_2
        else if val > 15
            c := c_dn_3
        else
            c := c_dn_4
    c

// Buy/sell emoji from candle direction (1 = buy, -1 = sell, 0/na = doji)
f_buysell_emoji(int cdir) =>
    nz(cdir, 0) > 0 ? "💰 " : nz(cdir, 0) < 0 ? "💸 " : ""

// Volume-level emoji (cumulative): >=71 attention, >=85 attention + explosion
f_level_emoji(float val) =>
    na(val) ? "" : val >= 85 ? "⚠️💥 " : val >= 71 ? "⚠️ " : ""

f_position(s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

// Classic price-volume divergence detection (regular only — bear top + bull bottom).
// Returns [bearDiv, bullDiv] booleans. Used inside request.security per-TF
// and directly on the Master series. Uses ta.valuewhen to capture pivot values
// at pivot bars (lookback shift) and compare current vs previous pivots.
f_classic_divergence_vol(simple int length, simple int lookback) =>
    float vol_local = ta.percentrank(volume, length)
    bool phFound = not na(ta.pivothigh(vol_local, lookback, lookback))
    bool plFound = not na(ta.pivotlow(vol_local, lookback, lookback))

    float vol_ph_curr   = ta.valuewhen(phFound, vol_local[lookback], 0)
    float vol_ph_prev   = ta.valuewhen(phFound, vol_local[lookback], 1)
    float price_ph_curr = ta.valuewhen(phFound, high[lookback], 0)
    float price_ph_prev = ta.valuewhen(phFound, high[lookback], 1)

    float vol_pl_curr   = ta.valuewhen(plFound, vol_local[lookback], 0)
    float vol_pl_prev   = ta.valuewhen(plFound, vol_local[lookback], 1)
    float price_pl_curr = ta.valuewhen(plFound, low[lookback], 0)
    float price_pl_prev = ta.valuewhen(plFound, low[lookback], 1)

    bool bearDiv = phFound and not na(vol_ph_prev) and not na(price_ph_prev) and price_ph_curr > price_ph_prev and vol_ph_curr < vol_ph_prev
    bool bullDiv = plFound and not na(vol_pl_prev) and not na(price_pl_prev) and price_pl_curr < price_pl_prev and vol_pl_curr > vol_pl_prev
    [bearDiv, bullDiv]

// Manual TF-string-to-minutes lookup (Pine v6 safe — avoids series/simple type ambiguity of timeframe.in_seconds).
// Returns 0 for unknown TF strings — caller must guard.
f_tf_str_to_minutes(string tf) =>
    int mins = switch tf
        "1"   => 1
        "2"   => 2
        "3"   => 3
        "5"   => 5
        "10"  => 10
        "15"  => 15
        "30"  => 30
        "45"  => 45
        "60"  => 60
        "120" => 120
        "180" => 180
        "240" => 240
        "D"   => 1440
        "1D"  => 1440
        "W"   => 10080
        "1W"  => 10080
        "M"   => 43200
        "1M"  => 43200
        => 0
    mins

// Geometric weighted mean of the 5 TF resolutions, in minutes.
// Same weights as Master fusion (0.15/0.20/0.25/0.25/0.15). Returns na if any TF unknown.
f_master_effective_tf(string t1, string t2, string t3, string t4, string t5) =>
    int m1 = f_tf_str_to_minutes(t1)
    int m2 = f_tf_str_to_minutes(t2)
    int m3 = f_tf_str_to_minutes(t3)
    int m4 = f_tf_str_to_minutes(t4)
    int m5 = f_tf_str_to_minutes(t5)
    float result = na
    if m1 > 0 and m2 > 0 and m3 > 0 and m4 > 0 and m5 > 0
        float log_sum = 0.15 * math.log(m1) + 0.20 * math.log(m2) + 0.25 * math.log(m3) + 0.25 * math.log(m4) + 0.15 * math.log(m5)
        result := math.exp(log_sum)
    result

// Formats minutes (float) → human label. Returns "?" for na input.
//   5  → "5m"   |  60 → "1h"  |  71.5 → "1h11m"  |  1440 → "1d"
f_format_minutes_to_label(float mins) =>
    string result = "?"
    if not na(mins)
        if mins < 1
            result := "<1m"
        else if mins < 60
            result := str.tostring(int(mins)) + "m"
        else if mins < 1440
            int hours = int(mins / 60)
            int rem = int(mins) % 60
            result := rem > 0 ? str.tostring(hours) + "h" + str.tostring(rem) + "m" : str.tostring(hours) + "h"
        else
            float days = mins / 1440.0
            result := str.tostring(math.round(days, 1)) + "d"
    result

// Pulse-to-color helper: maps a volume pulse ratio (volume / SMA volume) to a Rainbow Palette color.
// Mirrors the canonical 7-tier brand thermal logic applied to pulse magnitude.
//   < 0.5  → c_dn_4 (drought extreme)     2.0-3.5 → c_up_2 (high activity)
//   0.5-0.8 → c_dn_2 (below baseline)     3.5-6.0 → c_up_3 (surge)
//   0.8-1.3 → c_neutral (typical)          ≥ 6.0   → c_up_4 (climax extreme)
//   1.3-2.0 → c_up_1 (elevated)
f_pulse_color(float p) =>
    color c = c_neutral
    if not na(p)
        if p < 0.5
            c := c_dn_4
        else if p < 0.8
            c := c_dn_2
        else if p < 1.3
            c := c_neutral
        else if p < 2.0
            c := c_up_1
        else if p < 3.5
            c := c_up_2
        else if p < 6.0
            c := c_up_3
        else
            c := c_up_4
    c

// Pulse label formatter — caps display at "9.9x+" to avoid overflow in narrow cells.
// Returns "—" for na input (warmup state).
f_pulse_label(float p) =>
    string result = "—"
    if not na(p)
        result := p >= 9.95 ? "9.9x+" : str.tostring(p, "#.0") + "x"
    result

// ========================================================================================================
// LOCALIZED STRINGS (Multilingual pattern — EN/PT/ES/RU/ZH coverage)
// ========================================================================================================

// --- HUD: title (merged full-width header) ---
var string s_hud_title        = _l=="PT"?"📊 Sincronia MTF Volume"                :_l=="ES"?"📊 Sincronía MTF Volumen"               :_l=="RU"?"📊 MTF Объём Синхрония"            :_l=="ZH"?"📊 MTF 成交量同步"                    :"📊 MTF Volume Synchrony"

// --- HUD: status row ---
var string s_aligned          = _l=="PT"?"✅ Alinhado"                            :_l=="ES"?"✅ Alineado"                            :_l=="RU"?"✅ Согласовано"                  :_l=="ZH"?"✅ 一致"                              :"✅ Aligned"
var string s_div_strong_top   = _l=="PT"?"🔀 DIVERGÊNCIA FORTE (Topo)"            :_l=="ES"?"🔀 DIVERGENCIA FUERTE (Cima)"           :_l=="RU"?"🔀 СИЛЬНАЯ ДИВЕРГЕНЦИЯ (Верх)"  :_l=="ZH"?"🔀 强背离（顶部）"                       :"🔀 STRONG DIVERGENCE (Top)"
var string s_div_strong_bot   = _l=="PT"?"🔀 DIVERGÊNCIA FORTE (Fundo)"           :_l=="ES"?"🔀 DIVERGENCIA FUERTE (Bajo)"           :_l=="RU"?"🔀 СИЛЬНАЯ ДИВЕРГЕНЦИЯ (Низ)"   :_l=="ZH"?"🔀 强背离（底部）"                       :"🔀 STRONG DIVERGENCE (Bottom)"
var string s_div_mod_top      = _l=="PT"?"⚡ Divergência Moderada (Topo)"         :_l=="ES"?"⚡ Divergencia Moderada (Cima)"          :_l=="RU"?"⚡ Умеренная дивергенция (Верх)" :_l=="ZH"?"⚡ 中度背离（顶部）"                      :"⚡ Moderate Divergence (Top)"
var string s_div_mod_bot      = _l=="PT"?"⚡ Divergência Moderada (Fundo)"        :_l=="ES"?"⚡ Divergencia Moderada (Bajo)"          :_l=="RU"?"⚡ Умеренная дивергенция (Низ)"  :_l=="ZH"?"⚡ 中度背离（底部）"                      :"⚡ Moderate Divergence (Bottom)"


// --- Alert prefixes (Black Swan crossings) ---
var string s_al_bs_high_pre   = _l=="PT"?"🌈 MTF Volume — Master cruzou ACIMA do Black Swan Alto ("   :_l=="ES"?"🌈 MTF Volume — Master cruzó ARRIBA del Black Swan Alto ("    :_l=="RU"?"🌈 MTF Volume — Master пересёк ВВЕРХ Black Swan High ("     :_l=="ZH"?"🌈 MTF Volume — Master 向上突破 Black Swan 高位 ("              :"🌈 MTF Volume — Master crossed ABOVE Black Swan High ("
var string s_al_bs_low_pre    = _l=="PT"?"🌈 MTF Volume — Master cruzou ABAIXO do Black Swan Baixo (" :_l=="ES"?"🌈 MTF Volume — Master cruzó ABAJO del Black Swan Bajo ("    :_l=="RU"?"🌈 MTF Volume — Master пересёк ВНИЗ Black Swan Low ("       :_l=="ZH"?"🌈 MTF Volume — Master 向下突破 Black Swan 低位 ("              :"🌈 MTF Volume — Master crossed BELOW Black Swan Low ("
var string s_al_bs_mid        = _l=="PT"?"). Master Volume: "                                          :_l=="ES"?"). Master Volume: "                                            :_l=="RU"?"). Master Volume: "                                            :_l=="ZH"?"）。Master Volume："                                            :"). Master Volume: "

// --- Alert prefixes (Strong MTF Divergence) ---
var string s_al_div_pre       = _l=="PT"?"🔀 MTF Volume — Divergência MTF FORTE ("                    :_l=="ES"?"🔀 MTF Volume — Divergencia MTF FUERTE ("                      :_l=="RU"?"🔀 MTF Volume — СИЛЬНАЯ MTF дивергенция ("                    :_l=="ZH"?"🔀 MTF Volume — 强 MTF 背离("                                  :"🔀 MTF Volume — STRONG MTF Divergence ("
var string s_al_div_top       = _l=="PT"?"Topo"                                                     :_l=="ES"?"Cima"                                                       :_l=="RU"?"Верх"                                                       :_l=="ZH"?"顶部"                                                       :"Top"
var string s_al_div_bottom    = _l=="PT"?"Fundo"                                                    :_l=="ES"?"Bajo"                                                       :_l=="RU"?"Низ"                                                        :_l=="ZH"?"底部"                                                       :"Bottom"
var string s_al_div_tf1       = _l=="PT"?"). TF1: "                                                 :_l=="ES"?"). TF1: "                                                   :_l=="RU"?"). TF1: "                                                   :_l=="ZH"?"）。TF1："                                                    :"). TF1: "
var string s_al_div_tf5       = _l=="PT"?" | TF5: "                                                 :_l=="ES"?" | TF5: "                                                   :_l=="RU"?" | TF5: "                                                   :_l=="ZH"?" | TF5："                                                     :" | TF5: "

// --- Alert prefixes (Z-Exhaustion zone entries) ---
var string s_al_red_pre       = _l=="PT"?"💥 MTF Volume — Master entrou na zona Z-Exaustão ALTA ("    :_l=="ES"?"💥 MTF Volume — Master entró en la zona Z-Agotamiento ALTA ("  :_l=="RU"?"💥 MTF Volume — Master вошёл в зону Z-Истощение ВЕРХ ("       :_l=="ZH"?"💥 MTF Volume — Master 进入 Z-极限 高位区 ("                       :"💥 MTF Volume — Master entered Z-Exhaustion HIGH zone ("
var string s_al_blue_pre      = _l=="PT"?"🧊 MTF Volume — Master entrou na zona Z-Exaustão BAIXA ("   :_l=="ES"?"🧊 MTF Volume — Master entró en la zona Z-Agotamiento BAJA ("   :_l=="RU"?"🧊 MTF Volume — Master вошёл в зону Z-Истощение НИЗ ("         :_l=="ZH"?"🧊 MTF Volume — Master 进入 Z-极限 低位区 ("                       :"🧊 MTF Volume — Master entered Z-Exhaustion LOW zone ("
var string s_al_zone_close    = _l=="PT"?")"                                                        :_l=="ES"?")"                                                          :_l=="RU"?")"                                                          :_l=="ZH"?"）"                                                          :")"

// --- Alert prefixes (Master Classic Divergence — price ↔ volume) ---
var string s_al_div_master_bear_pre = _l=="PT"?"🔻 MTF Volume — Divergência CLÁSSICA Bear no Master (preço↑ + Volume↓). Master Volume: " :_l=="ES"?"🔻 MTF Volume — Divergencia CLÁSICA Bear en Master (precio↑ + Volumen↓). Master Volume: " :_l=="RU"?"🔻 MTF Volume — КЛАССИЧЕСКАЯ медвежья дивергенция Master (цена↑ + Объём↓). Master Volume: " :_l=="ZH"?"🔻 MTF Volume — Master 经典看跌背离（价格↑ + 成交量↓）。Master Volume："                          :"🔻 MTF Volume — CLASSIC Bear Divergence on Master (price↑ + Volume↓). Master Volume: "
var string s_al_div_master_bull_pre = _l=="PT"?"🔺 MTF Volume — Divergência CLÁSSICA Bull no Master (preço↓ + Volume↑). Master Volume: " :_l=="ES"?"🔺 MTF Volume — Divergencia CLÁSICA Bull en Master (precio↓ + Volumen↑). Master Volume: " :_l=="RU"?"🔺 MTF Volume — КЛАССИЧЕСКАЯ бычья дивергенция Master (цена↓ + Объём↑). Master Volume: "  :_l=="ZH"?"🔺 MTF Volume — Master 经典看涨背离（价格↓ + 成交量↑）。Master Volume："                          :"🔺 MTF Volume — CLASSIC Bull Divergence on Master (price↓ + Volume↑). Master Volume: "
var string s_div_chart_label_master = _l=="PT"?" Master"                                            :_l=="ES"?" Master"                                            :_l=="RU"?" Master"                                            :_l=="ZH"?" Master"                                            :" Master"

// --- Legend Table column headers (added v1.3) ---
var string s_hdr_timeframe = _l=="PT"?"Tempo Gráfico"              :_l=="ES"?"Marco Temporal"             :_l=="RU"?"Тайм-фрейм"                :_l=="ZH"?"时间框架"                          :"Timeframe"
var string s_hdr_value     = _l=="PT"?"Valor"                      :_l=="ES"?"Valor"                      :_l=="RU"?"Значение"                  :_l=="ZH"?"数值"                              :"Value"
var string s_hdr_trend     = _l=="PT"?"Tendência"                  :_l=="ES"?"Tendencia"                  :_l=="RU"?"Тренд"                     :_l=="ZH"?"趋势"                              :"Trend"
var string s_hdr_div       = _l=="PT"?"Div"                        :_l=="ES"?"Div"                        :_l=="RU"?"Див"                       :_l=="ZH"?"背离"                              :"Div"
var string s_hdr_pulse     = _l=="PT"?"Pulso"                      :_l=="ES"?"Pulso"                      :_l=="RU"?"Импульс"                   :_l=="ZH"?"脉冲"                              :"Pulse"
var string s_hdr_state     = _l=="PT"?"Estado"                     :_l=="ES"?"Estado"                     :_l=="RU"?"Состояние"                 :_l=="ZH"?"状态"                              :"State"

// --- Volume state names (added v1.3 — used by f_state_name + State column in Legend Table) ---
var string s_state_extreme    = _l=="PT"?"EXTREMO"                 :_l=="ES"?"EXTREMO"                    :_l=="RU"?"ЭКСТРИМ"                  :_l=="ZH"?"极端"                              :"EXTREME"
var string s_state_high       = _l=="PT"?"ALTO"                    :_l=="ES"?"ALTO"                       :_l=="RU"?"ВЫСОКИЙ"                  :_l=="ZH"?"高"                                :"HIGH"
var string s_state_elevated   = _l=="PT"?"ELEVADO"                 :_l=="ES"?"ELEVADO"                    :_l=="RU"?"ПОВЫШЕН."                 :_l=="ZH"?"升高"                              :"ELEVATED"
var string s_state_normal     = _l=="PT"?"NORMAL"                  :_l=="ES"?"NORMAL"                     :_l=="RU"?"НОРМА"                    :_l=="ZH"?"正常"                              :"NORMAL"
var string s_state_low        = _l=="PT"?"BAIXO"                   :_l=="ES"?"BAJO"                       :_l=="RU"?"НИЗКИЙ"                   :_l=="ZH"?"低"                                :"LOW"
var string s_state_compressed = _l=="PT"?"COMPRIMIDO"              :_l=="ES"?"COMPRIMIDO"                 :_l=="RU"?"СЖАТ"                     :_l=="ZH"?"压缩"                              :"COMPRESSED"
var string s_state_squeeze    = _l=="PT"?"APERTO"                  :_l=="ES"?"COMPRESIÓN"                 :_l=="RU"?"СДАВЛИВАНИЕ"              :_l=="ZH"?"挤压"                              :"SQUEEZE"

// ========================================================================================================
// State name resolver — maps a 0-100 volume percentile value to a state name string.
// Mirrors the thresholds from f_termal_matrix_vol (the 7-tier color matrix) but returns
// a multilingual name from the localized dictionary. Used by the State column in the
// MTF Legend Table.
//   >= 85   -> EXTREME      29-38  -> LOW
//   71-85   -> HIGH         15-29  -> COMPRESSED
//   62-71   -> ELEVATED     <= 15  -> SQUEEZE
//   38-62   -> NORMAL       na     -> "—"
f_state_name(float val) =>
    string result = "—"
    if not na(val)
        if val >= 85
            result := s_state_extreme
        else if val >= 71
            result := s_state_high
        else if val >= 62
            result := s_state_elevated
        else if val > 38
            result := s_state_normal
        else if val > 29
            result := s_state_low
        else if val > 15
            result := s_state_compressed
        else
            result := s_state_squeeze
    result

// ========================================================================================================
// MTF VOLUME FETCH (5 independent timeframes — lookahead_off, anti-repaint)
//   Per-TF length resolution: if vol_len_tfN is 0, inherit from vol_length_default;
//   otherwise use the override. Computed once per bar.
// ========================================================================================================
int len_tf1 = vol_len_tf1 > 0 ? vol_len_tf1 : vol_length_default
int len_tf2 = vol_len_tf2 > 0 ? vol_len_tf2 : vol_length_default
int len_tf3 = vol_len_tf3 > 0 ? vol_len_tf3 : vol_length_default
int len_tf4 = vol_len_tf4 > 0 ? vol_len_tf4 : vol_length_default
int len_tf5 = vol_len_tf5 > 0 ? vol_len_tf5 : vol_length_default

[vol_tf1, cdir_tf1] = request.security(syminfo.tickerid, tf_1, [ta.percentrank(volume, len_tf1), close > open ? 1 : close < open ? -1 : 0], lookahead = barmerge.lookahead_off)
[vol_tf2, cdir_tf2] = request.security(syminfo.tickerid, tf_2, [ta.percentrank(volume, len_tf2), close > open ? 1 : close < open ? -1 : 0], lookahead = barmerge.lookahead_off)
[vol_tf3, cdir_tf3] = request.security(syminfo.tickerid, tf_3, [ta.percentrank(volume, len_tf3), close > open ? 1 : close < open ? -1 : 0], lookahead = barmerge.lookahead_off)
[vol_tf4, cdir_tf4] = request.security(syminfo.tickerid, tf_4, [ta.percentrank(volume, len_tf4), close > open ? 1 : close < open ? -1 : 0], lookahead = barmerge.lookahead_off)
[vol_tf5, cdir_tf5] = request.security(syminfo.tickerid, tf_5, [ta.percentrank(volume, len_tf5), close > open ? 1 : close < open ? -1 : 0], lookahead = barmerge.lookahead_off)
int cdir_master = close > open ? 1 : close < open ? -1 : 0

// ========================================================================================================
// MTF VOLUME PULSE FETCH (volume magnitude ratio per timeframe)
//   Pulse = volume / SMA(volume, length). Complements percentile rank (Value column):
//   Value asks "where in the distribution?"; Pulse asks "how intense vs baseline?".
//   1.0x = typical, < 1.0x = below baseline, > 1.0x = elevated.
// ========================================================================================================
float vol_pulse_tf1 = request.security(syminfo.tickerid, tf_1, volume / ta.sma(volume, len_tf1), lookahead = barmerge.lookahead_off)
float vol_pulse_tf2 = request.security(syminfo.tickerid, tf_2, volume / ta.sma(volume, len_tf2), lookahead = barmerge.lookahead_off)
float vol_pulse_tf3 = request.security(syminfo.tickerid, tf_3, volume / ta.sma(volume, len_tf3), lookahead = barmerge.lookahead_off)
float vol_pulse_tf4 = request.security(syminfo.tickerid, tf_4, volume / ta.sma(volume, len_tf4), lookahead = barmerge.lookahead_off)
float vol_pulse_tf5 = request.security(syminfo.tickerid, tf_5, volume / ta.sma(volume, len_tf5), lookahead = barmerge.lookahead_off)

// Master Pulse — Fibonacci-weighted fusion (same weights as Master Volume Percentile: 0.15/0.20/0.25/0.25/0.15)
float vol_pulse_master = nz(f_avg5_weighted(vol_pulse_tf1, vol_pulse_tf2, vol_pulse_tf3, vol_pulse_tf4, vol_pulse_tf5), 1.0)

// ========================================================================================================
// CLASSIC DIVERGENCE DETECTION (per-TF — price vs Volume Percentile on the SAME timeframe)
//   Different from existing MTF Divergence (TF1-vs-TF5 Volume Percentile alignment).
//   Each TF runs its own pivot detection via request.security; returned booleans
//   indicate bear (top) or bull (bottom) regular divergence currently active on that TF.
// ========================================================================================================
[bear_div_tf1, bull_div_tf1] = request.security(syminfo.tickerid, tf_1, f_classic_divergence_vol(len_tf1, div_lookback), lookahead = barmerge.lookahead_off)
[bear_div_tf2, bull_div_tf2] = request.security(syminfo.tickerid, tf_2, f_classic_divergence_vol(len_tf2, div_lookback), lookahead = barmerge.lookahead_off)
[bear_div_tf3, bull_div_tf3] = request.security(syminfo.tickerid, tf_3, f_classic_divergence_vol(len_tf3, div_lookback), lookahead = barmerge.lookahead_off)
[bear_div_tf4, bull_div_tf4] = request.security(syminfo.tickerid, tf_4, f_classic_divergence_vol(len_tf4, div_lookback), lookahead = barmerge.lookahead_off)
[bear_div_tf5, bull_div_tf5] = request.security(syminfo.tickerid, tf_5, f_classic_divergence_vol(len_tf5, div_lookback), lookahead = barmerge.lookahead_off)

// ========================================================================================================
// MASTER LINE (weighted Volume Percentile fusion — clamped to 0–100)
// ========================================================================================================
float vol_master = math.max(math.min(nz(f_avg5_weighted(vol_tf1, vol_tf2, vol_tf3, vol_tf4, vol_tf5), 50.0), 100.0), 0.0)

// ========================================================================================================
// DELTA HELPER FUNCTIONS (declared AFTER vol_master + vol_tfN exist in scope — Pine v6 top-down parsing)
// ========================================================================================================

// Delta twin bar — resolve selected source to its current percentile value.
// Returns Master, TF1, TF2, TF3, TF4, or TF5 score based on user selection.
f_delta_source_value(string src) =>
    float v = vol_master
    if src == "TF1 (Trigger)"
        v := vol_tf1
    else if src == "TF2 (Intraday)"
        v := vol_tf2
    else if src == "TF3 (Macro 1)"
        v := vol_tf3
    else if src == "TF4 (Macro 2)"
        v := vol_tf4
    else if src == "TF5 (Base)"
        v := vol_tf5
    v

// Delta twin bar — determine candle direction via OHLC tick rule.
// Returns +1 (buy bias), -1 (sell bias), or 0 (neutral / doji).
//   close > open → buy
//   close < open → sell
//   close == open → neutral (no twin bar rendered)
f_delta_direction() =>
    int dir = 0
    if close > open
        dir := 1
    else if close < open
        dir := -1
    dir

// Delta twin bar — compute current bar's twin bar parameters (top, bottom, color).
// Returns tuple [bar_top, bar_bottom, final_color]. Used by both live and confirmed render paths.
// Returns na values when score/direction unusable (warmup or neutral candle).
f_delta_bar_params() =>
    float score = f_delta_source_value(delta_source)
    int direction = f_delta_direction()
    float bar_top = na
    float bar_bottom = na
    color final_color = na
    if not na(score) and direction != 0
        float candle_range = high - low
        float bar_size = candle_range * (score / 100.0) * delta_size_mult
        if delta_mode == "Fixed High"
            bar_top := high + bar_size
            bar_bottom := high
        else if delta_mode == "Fixed Low"
            bar_top := low
            bar_bottom := low - bar_size
        else if delta_mode == "Dynamic"
            if direction == 1
                bar_top := high + bar_size
                bar_bottom := high
            else
                bar_top := low
                bar_bottom := low - bar_size
        else  // "Dynamic Inverted"
            if direction == 1
                bar_top := low
                bar_bottom := low - bar_size
            else
                bar_top := high + bar_size
                bar_bottom := high
        color base_color = direction == 1 ? delta_buy_color : delta_sell_color
        if delta_use_master_color
            base_color := f_termal_matrix_vol(vol_master)
        final_color := color.new(base_color, delta_transparency)
    [bar_top, bar_bottom, final_color]


// Master classic divergence detection (no request.security — uses chart-TF price + Master Volume series directly).
//   Detected on the current chart resolution. Used as fallback when chart TF doesn't match any of the 5 user-selected TFs.
bool ph_master_found = not na(ta.pivothigh(vol_master, div_lookback, div_lookback))
bool pl_master_found = not na(ta.pivotlow(vol_master,  div_lookback, div_lookback))

float vol_master_ph_curr   = ta.valuewhen(ph_master_found, vol_master[div_lookback], 0)
float vol_master_ph_prev   = ta.valuewhen(ph_master_found, vol_master[div_lookback], 1)
float price_master_ph_curr = ta.valuewhen(ph_master_found, high[div_lookback], 0)
float price_master_ph_prev = ta.valuewhen(ph_master_found, high[div_lookback], 1)

float vol_master_pl_curr   = ta.valuewhen(pl_master_found, vol_master[div_lookback], 0)
float vol_master_pl_prev   = ta.valuewhen(pl_master_found, vol_master[div_lookback], 1)
float price_master_pl_curr = ta.valuewhen(pl_master_found, low[div_lookback], 0)
float price_master_pl_prev = ta.valuewhen(pl_master_found, low[div_lookback], 1)

bool bear_div_master = ph_master_found and not na(vol_master_ph_prev) and not na(price_master_ph_prev) and price_master_ph_curr > price_master_ph_prev and vol_master_ph_curr < vol_master_ph_prev
bool bull_div_master = pl_master_found and not na(vol_master_pl_prev) and not na(price_master_pl_prev) and price_master_pl_curr < price_master_pl_prev and vol_master_pl_curr > vol_master_pl_prev

// Bar indices of Master pivots (needed for line.new chart visual — current + previous pivot bars).
int master_bar_ph_curr = ta.valuewhen(ph_master_found, bar_index[div_lookback], 0)
int master_bar_ph_prev = ta.valuewhen(ph_master_found, bar_index[div_lookback], 1)
int master_bar_pl_curr = ta.valuewhen(pl_master_found, bar_index[div_lookback], 0)
int master_bar_pl_prev = ta.valuewhen(pl_master_found, bar_index[div_lookback], 1)

// Master effective TF (geometric weighted mean of the 5 TFs) — shown in the Master row label.
float master_eff_mins  = f_master_effective_tf(tf_1, tf_2, tf_3, tf_4, tf_5)
string master_eff_label = f_format_minutes_to_label(master_eff_mins)

// ========================================================================================================
// CHART VISUAL — Master Volume Divergence (line + label)
//   Drawn on the indicator pane only. Master is the integrated MTF view, so its divergence captures the
//   "average" cross-TF signal. For per-TF breakdown, the Legend Table 'Div' column shows each TF separately.
//   Anti-spam: a divergence triggers ONE line + label on the bar it's confirmed.
//   History: bounded by indicator() max_lines_count / max_labels_count (500 each — ample for ~50 events).
// ========================================================================================================
if show_div_chart_line and bear_div_master and not na(master_bar_ph_prev)
    line.new(x1 = master_bar_ph_prev, y1 = vol_master_ph_prev, x2 = master_bar_ph_curr, y2 = vol_master_ph_curr, color = color.new(c_up_3, 30), width = 2, style = line.style_solid)
    label.new(x = master_bar_ph_curr, y = vol_master_ph_curr, text = "🔻 Bear Div" + s_div_chart_label_master, color = color.new(c_up_3, 20), textcolor = color.white, style = label.style_label_down, size = size.small)

if show_div_chart_line and bull_div_master and not na(master_bar_pl_prev)
    line.new(x1 = master_bar_pl_prev, y1 = vol_master_pl_prev, x2 = master_bar_pl_curr, y2 = vol_master_pl_curr, color = color.new(c_dn_1, 30), width = 2, style = line.style_solid)
    label.new(x = master_bar_pl_curr, y = vol_master_pl_curr, text = "🔺 Bull Div" + s_div_chart_label_master, color = color.new(c_dn_1, 20), textcolor = color.white, style = label.style_label_up, size = size.small)

// ========================================================================================================
// DYNAMIC CHANNEL (Master Volume volatility envelope)
// ========================================================================================================
float dyn_up  = ta.ema(ta.highest(vol_master, lookback_dyn), smooth_dyn)
float dyn_dn  = ta.ema(ta.lowest(vol_master,  lookback_dyn), smooth_dyn)
float dyn_mid = (dyn_up + dyn_dn) / 2.0
float dist_up = math.max(dyn_up - dyn_mid, 1e-10)
float dist_dn = math.max(dyn_mid - dyn_dn, 1e-10)

// ========================================================================================================
// RAINBOW FIBONACCI ZONES (canonical ratios 1.50/1.85/2.75/3.85 — NEVER change; all lines clamped to [0,100] for pane containment)
// ========================================================================================================
fib_breath    = 1.50 / 1.85   // ≈ 0.811
fib_exhaust   = 2.75 / 1.85   // ≈ 1.486
fib_blackswan = 3.85 / 1.85   // ≈ 2.081

float osc_up1 = math.min(100.0, math.max(0.0, dyn_mid + (dist_up * fib_breath)))     // Z-Breathing High (clamped to [0,100])
float osc_up2 = math.min(100.0, math.max(0.0, dyn_up))                                // Z-Alert High (anchor at 1.85σ, clamped to [0,100])
float osc_up3 = math.min(100.0, math.max(0.0, dyn_mid + (dist_up * fib_exhaust)))    // Z-Exhaustion High (clamped to [0,100])
float osc_up4 = math.min(100.0, math.max(0.0, dyn_mid + (dist_up * fib_blackswan)))  // Black Swan High dynamic (clamped to [0,100])

float osc_dn1 = math.min(100.0, math.max(0.0, dyn_mid - (dist_dn * fib_breath)))
float osc_dn2 = math.min(100.0, math.max(0.0, dyn_dn))
float osc_dn3 = math.min(100.0, math.max(0.0, dyn_mid - (dist_dn * fib_exhaust)))
float osc_dn4 = math.min(100.0, math.max(0.0, dyn_mid - (dist_dn * fib_blackswan)))

// ========================================================================================================
// BLACK SWAN — HYBRID MODE (static 80/20 by default, dynamic Fibonacci when toggled)
// ========================================================================================================
float black_swan_high = math.min(100.0, math.max(0.0, dynamic_extremes ? osc_up4 : 100.0))
float black_swan_low  = math.min(100.0, math.max(0.0, dynamic_extremes ? osc_dn4 : 0.0))

// ========================================================================================================
// DIVERGENCE DETECTION (TF1 vs TF5)
// ========================================================================================================
bool div_strong_top      = barstate.isconfirmed and vol_tf1 >= 70 and vol_tf5 <= 30
bool div_strong_bottom   = barstate.isconfirmed and vol_tf1 <= 30 and vol_tf5 >= 70
bool div_strong          = div_strong_top or div_strong_bottom
bool div_moderate_top    = barstate.isconfirmed and not div_strong and vol_tf1 >= 65 and vol_tf5 <= 40
bool div_moderate_bottom = barstate.isconfirmed and not div_strong and vol_tf1 <= 35 and vol_tf5 >= 60
bool div_moderate        = div_moderate_top or div_moderate_bottom

// ========================================================================================================
// VISUAL — BLACK SWAN HIGH (line + glow, fade by distance to Master, NO fill)
// ========================================================================================================
float glow_range_high = math.max(dist_up, 5.0)
float glow_range_low  = math.max(dist_dn, 5.0)
int   transp_bs_high  = f_calc_glow(vol_master, black_swan_high, glow_range_high)
int   transp_bs_low   = f_calc_glow(vol_master, black_swan_low,  glow_range_low)

plot(show_blackswan ? black_swan_high : na, "Black Swan High Glow", color = color.new(c_up_4, transp_bs_high), linewidth = 5, display = display.pane)
plot(show_blackswan ? black_swan_high : na, "Black Swan High Main", color = color.new(c_up_4, math.max(20, transp_bs_high - 20)), linewidth = 1)

// ========================================================================================================
// VISUAL — DYNAMIC CHANNEL (dashed envelope, adapts to Master volatility)
// ========================================================================================================
plot(dyn_up,  "Dyn Channel Up",  color = color.new(c_up_2,    55), linewidth = 1, linestyle = plot.linestyle_dashed, display = show_dyn_channel ? display.pane + display.price_scale : display.none)
plot(dyn_mid, "Dyn Channel Mid", color = color.new(c_neutral, 55), linewidth = 1, linestyle = plot.linestyle_dashed, display = show_dyn_channel ? display.pane + display.price_scale : display.none)
plot(dyn_dn,  "Dyn Channel Dn",  color = color.new(c_dn_2,    55), linewidth = 1, linestyle = plot.linestyle_dashed, display = show_dyn_channel ? display.pane + display.price_scale : display.none)

// ========================================================================================================
// VISUAL — GHOST LINES (5 individual Volume percentiles, transparency = f(distance to Master))
// Formula:  transp = clamp(20 + dist × ghost_sensitivity, 20, 90)
//   - At dist=0 (perfect alignment): transp=20 (solid).
//   - At dist=(70/ghost_sensitivity) RSI points: transp=90 (invisible).
//   - Default ghost_sensitivity=3.5 ⇒ invisible at ~20 RSI points apart.
// ========================================================================================================
float dist_tf1 = math.abs(vol_tf1 - vol_master)
float dist_tf2 = math.abs(vol_tf2 - vol_master)
float dist_tf3 = math.abs(vol_tf3 - vol_master)
float dist_tf4 = math.abs(vol_tf4 - vol_master)
float dist_tf5 = math.abs(vol_tf5 - vol_master)

int transp_tf1 = int(math.min(90.0, math.max(20.0, 20.0 + dist_tf1 * ghost_sensitivity)))
int transp_tf2 = int(math.min(90.0, math.max(20.0, 20.0 + dist_tf2 * ghost_sensitivity)))
int transp_tf3 = int(math.min(90.0, math.max(20.0, 20.0 + dist_tf3 * ghost_sensitivity)))
int transp_tf4 = int(math.min(90.0, math.max(20.0, 20.0 + dist_tf4 * ghost_sensitivity)))
int transp_tf5 = int(math.min(90.0, math.max(20.0, 20.0 + dist_tf5 * ghost_sensitivity)))

int tf_hist_width = math.max(1, master_hist_width - 1)
plot(show_tf1 ? vol_tf1 : na, "RSI TF 1 (Trigger)",  color = color.new(color_tf1, transp_tf1), linewidth = tf_hist_width, style = plot.style_histogram)
plot(show_tf2 ? vol_tf2 : na, "RSI TF 2 (Intraday)", color = color.new(color_tf2, transp_tf2), linewidth = tf_hist_width, style = plot.style_histogram)
plot(show_tf3 ? vol_tf3 : na, "RSI TF 3 (Macro 1)",  color = color.new(color_tf3, transp_tf3), linewidth = tf_hist_width, style = plot.style_histogram)
plot(show_tf4 ? vol_tf4 : na, "RSI TF 4 (Macro 2)",  color = color.new(color_tf4, transp_tf4), linewidth = tf_hist_width, style = plot.style_histogram)
plot(show_tf5 ? vol_tf5 : na, "RSI TF 5 (Base)",     color = color.new(color_tf5, transp_tf5), linewidth = tf_hist_width, style = plot.style_histogram)

// ========================================================================================================
// VISUAL — BLACK SWAN LOW (line + glow, before Master so Master always sits on top)
// ========================================================================================================
plot(show_blackswan ? black_swan_low : na, "Black Swan Low Glow", color = color.new(c_dn_4, transp_bs_low), linewidth = 5, display = display.pane)
plot(show_blackswan ? black_swan_low : na, "Black Swan Low Main", color = color.new(c_dn_4, math.max(20, transp_bs_low - 20)), linewidth = 1)

// ========================================================================================================
// VISUAL — MASTER LINE (rainbow color by zone, plotted LAST so it always sits on top)
// ========================================================================================================
color c_master = f_termal_matrix_vol(vol_master)
plot(show_master_line ? vol_master : na, "Volume Master", color = color.new(c_master, master_transp), linewidth = master_hist_width, style = plot.style_histogram)

// ========================================================================================================
// VISUAL — MASTER LEVEL LINE (horizontal ray at current Master value)
// ========================================================================================================
var line ln_master_level = na
if barstate.islast
    if not na(ln_master_level)
        line.delete(ln_master_level)
    if show_master_level
        ln_master_level := line.new(bar_index, vol_master, bar_index + 10, vol_master, color = color.new(c_master, 0), width = 1, style = line.style_dotted, extend = extend.right)

// ========================================================================================================
// DIVERGENCE EVENT MARKERS (Strong + Moderate, dual-position via div_markers_pos input)
// 4 events × 2 positions = 8 plotshapes declared; only the 4 matching the chosen position are active.
// Pine v6 requires location and force_overlay as const literals — dual declaration is the canonical pattern.
//
// Color hierarchy mirrors the Legend Table status row palette:
//   - Strong   top    → c_up_3 (red, saturated)     | Strong   bottom → c_dn_1 (green, saturated)
//   - Moderate top    → c_up_2 (orange, transitional)| Moderate bottom → c_dn_2 (teal, transitional)
//
// Triangle direction signals expected reversal: ▼ = Top (reversal from highs); ▲ = Bottom (reversal from lows).
// Markers persist while the divergence condition holds (mutually exclusive: Strong and Moderate never
// co-fire on the same bar — Moderate has "and not div_strong" guard from v1.0 detection logic).
// ========================================================================================================
bool mk_pane    = div_markers_pos == "Indicator Pane"
bool mk_overlay = div_markers_pos == "Chart Overlay"

// --- Indicator pane variant (location.top / location.bottom) ---
plotshape(show_div_markers and mk_pane and div_strong_top,      title = "Strong Top Divergence (pane)",      location = location.top,    style = shape.triangledown, color = color.new(c_up_3, 20), size = size.small)
plotshape(show_div_markers and mk_pane and div_strong_bottom,   title = "Strong Bottom Divergence (pane)",   location = location.bottom, style = shape.triangleup,   color = color.new(c_dn_1, 20), size = size.small)
plotshape(show_div_markers and mk_pane and div_moderate_top,    title = "Moderate Top Divergence (pane)",    location = location.top,    style = shape.triangledown, color = color.new(c_up_2, 30), size = size.small)
plotshape(show_div_markers and mk_pane and div_moderate_bottom, title = "Moderate Bottom Divergence (pane)", location = location.bottom, style = shape.triangleup,   color = color.new(c_dn_2, 30), size = size.small)

// --- Chart overlay variant (location.abovebar / location.belowbar, force_overlay=true) ---
plotshape(show_div_markers and mk_overlay and div_strong_top,      title = "Strong Top Divergence (chart)",      location = location.abovebar, style = shape.triangledown, color = color.new(c_up_3, 20), size = size.small, force_overlay = true)
plotshape(show_div_markers and mk_overlay and div_strong_bottom,   title = "Strong Bottom Divergence (chart)",   location = location.belowbar, style = shape.triangleup,   color = color.new(c_dn_1, 20), size = size.small, force_overlay = true)
plotshape(show_div_markers and mk_overlay and div_moderate_top,    title = "Moderate Top Divergence (chart)",    location = location.abovebar, style = shape.triangledown, color = color.new(c_up_2, 30), size = size.small, force_overlay = true)
plotshape(show_div_markers and mk_overlay and div_moderate_bottom, title = "Moderate Bottom Divergence (chart)", location = location.belowbar, style = shape.triangleup,   color = color.new(c_dn_2, 30), size = size.small, force_overlay = true)

// ========================================================================================================
// MTF VOLUME LEGEND TABLE (mini-table inside the indicator pane — force_overlay=false for mobile readability)
// Layout (7 cols × 9 rows):
//   Row 0: merged full-width title (multilingual s_hud_title)
//   Row 1: column headers — [Timeframe (merged 0-1)] | Value | Trend | Div | Pulse | State
//   Row 2-6: per-TF rows — [● TFn + antenna if chart-native] | TF resolution | Volume Percentile value | trend arrow ▲/▼/▬ | Div bull/bear/— | Pulse Nx | State (EXTREME/HIGH/...)
//   Row 7: Master row (cols 0-1 merged: "Master") | Master Volume Percentile | Master trend arrow | Master Div | Master Pulse | Master State
//   Row 8: merged status row (divergence summary, reused from MTF Divergence detection)
//
// Color scheme:
//   - Row 1 (headers): dim text on dim background (subtle hierarchy)
//   - Col 0 (● TFn label): color_tfN (user-configured, matches ghost line)
//   - Col 1 (TF resolution): c_neutral
//   - Col 2 (percentile value): zone color via f_termal_matrix_vol(vol_tfN)
//   - Col 3 (trend arrow): same zone color (visual coupling)
//   - Col 4 (divergence): c_up_3 (red) for bear, c_dn_1 (green) for bull, c_neutral for none
//   - Col 5 (pulse value): magnitude color via f_pulse_color(vol_pulse_tfN)
//   - Col 6 (state name): zone color via f_termal_matrix_vol(vol_tfN) — coupled with Value
//   - Master row: entire row in Master zone color
//   - Antenna marker: suffix of col 0 only on the row whose TF == timeframe.period
// ========================================================================================================
var table legend = table.new(f_position(legend_pos), 7, 9, border_width = 1, border_color = color.new(c_neutral, 80), frame_width = 2, frame_color = color.new(c_black, 20), force_overlay = false)

if barstate.islast and show_legend_table
    // --- Zone colors (used for RSI value + trend cell text) ---
    color c_tf1_dot    = f_termal_matrix_vol(vol_tf1)
    color c_tf2_dot    = f_termal_matrix_vol(vol_tf2)
    color c_tf3_dot    = f_termal_matrix_vol(vol_tf3)
    color c_tf4_dot    = f_termal_matrix_vol(vol_tf4)
    color c_tf5_dot    = f_termal_matrix_vol(vol_tf5)
    color c_master_dot = f_termal_matrix_vol(vol_master)

    // --- Antenna marker (if this TF == chart's native resolution) ---
    string current_tf = timeframe.period
    string ant1 = tf_1 == current_tf ? " 📡" : ""
    string ant2 = tf_2 == current_tf ? " 📡" : ""
    string ant3 = tf_3 == current_tf ? " 📡" : ""
    string ant4 = tf_4 == current_tf ? " 📡" : ""
    string ant5 = tf_5 == current_tf ? " 📡" : ""

    // --- Trend arrows (±0.5 deadzone vs previous bar — flicker-resistant) ---
    string trend_tf1    = vol_tf1    > nz(vol_tf1[1],    vol_tf1)    + 0.5 ? "▲" : vol_tf1    < nz(vol_tf1[1],    vol_tf1)    - 0.5 ? "▼" : "▬"
    string trend_tf2    = vol_tf2    > nz(vol_tf2[1],    vol_tf2)    + 0.5 ? "▲" : vol_tf2    < nz(vol_tf2[1],    vol_tf2)    - 0.5 ? "▼" : "▬"
    string trend_tf3    = vol_tf3    > nz(vol_tf3[1],    vol_tf3)    + 0.5 ? "▲" : vol_tf3    < nz(vol_tf3[1],    vol_tf3)    - 0.5 ? "▼" : "▬"
    string trend_tf4    = vol_tf4    > nz(vol_tf4[1],    vol_tf4)    + 0.5 ? "▲" : vol_tf4    < nz(vol_tf4[1],    vol_tf4)    - 0.5 ? "▼" : "▬"
    string trend_tf5    = vol_tf5    > nz(vol_tf5[1],    vol_tf5)    + 0.5 ? "▲" : vol_tf5    < nz(vol_tf5[1],    vol_tf5)    - 0.5 ? "▼" : "▬"
    string trend_master = vol_master > nz(vol_master[1], vol_master) + 0.5 ? "▲" : vol_master < nz(vol_master[1], vol_master) - 0.5 ? "▼" : "▬"

    // --- Divergence summary (reused from v1.5 logic) ---
    string status_txt = s_aligned
    color  status_bg  = color.new(c_neutral, 80)
    color  status_fg  = color.white
    if div_strong_top
        status_txt := s_div_strong_top
        status_bg  := color.new(c_up_3, 50)
    else if div_strong_bottom
        status_txt := s_div_strong_bot
        status_bg  := color.new(c_dn_1, 50)
    else if div_moderate_top
        status_txt := s_div_mod_top
        status_bg  := color.new(c_up_2, 60)
    else if div_moderate_bottom
        status_txt := s_div_mod_bot
        status_bg  := color.new(c_dn_2, 60)

    // === Row 0 — Header (merged 4 cols) ===
    table.merge_cells(legend, 0, 0, 6, 0)

    // Row 1: Column headers (added v1.3)
    table.cell(legend, 0, 1, s_hdr_timeframe, text_color = color.new(c_neutral, 30), text_size = sz_tbl, bgcolor = color.new(c_black, 75), text_halign = text.align_center)
    table.merge_cells(legend, 0, 1, 1, 1)
    table.cell(legend, 2, 1, s_hdr_value,     text_color = color.new(c_neutral, 30), text_size = sz_tbl, bgcolor = color.new(c_black, 75), text_halign = text.align_center)
    table.cell(legend, 3, 1, s_hdr_trend,     text_color = color.new(c_neutral, 30), text_size = sz_tbl, bgcolor = color.new(c_black, 75), text_halign = text.align_center)
    table.cell(legend, 4, 1, s_hdr_div,       text_color = color.new(c_neutral, 30), text_size = sz_tbl, bgcolor = color.new(c_black, 75), text_halign = text.align_center)
    table.cell(legend, 5, 1, s_hdr_pulse,     text_color = color.new(c_neutral, 30), text_size = sz_tbl, bgcolor = color.new(c_black, 75), text_halign = text.align_center)
    table.cell(legend, 6, 1, s_hdr_state,     text_color = color.new(c_neutral, 30), text_size = sz_tbl, bgcolor = color.new(c_black, 75), text_halign = text.align_center)
    table.cell(legend, 0, 0, s_hud_title,
         text_color = color.new(c_dn_4, 0), text_size = sz_lbl,
         bgcolor = color.new(c_black, 10), text_halign = text.align_center)

    // === Row 1 — TF1 ===
    table.cell(legend, 0, 2, "● TF1" + ant1,         text_color = color_tf1,                text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_left)
    table.cell(legend, 1, 2, tf_1,                    text_color = color.new(c_neutral, 20), text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)
    table.cell(legend, 2, 2, f_level_emoji(vol_tf1) + f_buysell_emoji(cdir_tf1) + str.tostring(vol_tf1, "#.0"), text_color = c_tf1_dot,           text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_right)
    table.cell(legend, 3, 2, trend_tf1,               text_color = c_tf1_dot,                text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)
    table.cell(legend, 4, 2, show_div_column ? (bear_div_tf1 ? "🔻" : bull_div_tf1 ? "🔺" : "—") : "",  text_color = bear_div_tf1 ? c_up_3 : bull_div_tf1 ? c_dn_1 : c_neutral,  text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)
    table.cell(legend, 5, 2, show_pulse_column ? f_pulse_label(vol_pulse_tf1) : "", text_color = f_pulse_color(vol_pulse_tf1), text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_right)
    table.cell(legend, 6, 2, f_state_name(vol_tf1), text_color = f_termal_matrix_vol(vol_tf1), text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)

    // === Row 2 — TF2 ===
    table.cell(legend, 0, 3, "● TF2" + ant2,         text_color = color_tf2,                text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_left)
    table.cell(legend, 1, 3, tf_2,                    text_color = color.new(c_neutral, 20), text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_center)
    table.cell(legend, 2, 3, f_level_emoji(vol_tf2) + f_buysell_emoji(cdir_tf2) + str.tostring(vol_tf2, "#.0"), text_color = c_tf2_dot,           text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_right)
    table.cell(legend, 3, 3, trend_tf2,               text_color = c_tf2_dot,                text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_center)
    table.cell(legend, 4, 3, show_div_column ? (bear_div_tf2 ? "🔻" : bull_div_tf2 ? "🔺" : "—") : "",  text_color = bear_div_tf2 ? c_up_3 : bull_div_tf2 ? c_dn_1 : c_neutral,  text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_center)
    table.cell(legend, 5, 3, show_pulse_column ? f_pulse_label(vol_pulse_tf2) : "", text_color = f_pulse_color(vol_pulse_tf2), text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_right)
    table.cell(legend, 6, 3, f_state_name(vol_tf2), text_color = f_termal_matrix_vol(vol_tf2), text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_center)

    // === Row 3 — TF3 ===
    table.cell(legend, 0, 4, "● TF3" + ant3,         text_color = color_tf3,                text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_left)
    table.cell(legend, 1, 4, tf_3,                    text_color = color.new(c_neutral, 20), text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)
    table.cell(legend, 2, 4, f_level_emoji(vol_tf3) + f_buysell_emoji(cdir_tf3) + str.tostring(vol_tf3, "#.0"), text_color = c_tf3_dot,           text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_right)
    table.cell(legend, 3, 4, trend_tf3,               text_color = c_tf3_dot,                text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)
    table.cell(legend, 4, 4, show_div_column ? (bear_div_tf3 ? "🔻" : bull_div_tf3 ? "🔺" : "—") : "",  text_color = bear_div_tf3 ? c_up_3 : bull_div_tf3 ? c_dn_1 : c_neutral,  text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)
    table.cell(legend, 5, 4, show_pulse_column ? f_pulse_label(vol_pulse_tf3) : "", text_color = f_pulse_color(vol_pulse_tf3), text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_right)
    table.cell(legend, 6, 4, f_state_name(vol_tf3), text_color = f_termal_matrix_vol(vol_tf3), text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)

    // === Row 4 — TF4 ===
    table.cell(legend, 0, 5, "● TF4" + ant4,         text_color = color_tf4,                text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_left)
    table.cell(legend, 1, 5, tf_4,                    text_color = color.new(c_neutral, 20), text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_center)
    table.cell(legend, 2, 5, f_level_emoji(vol_tf4) + f_buysell_emoji(cdir_tf4) + str.tostring(vol_tf4, "#.0"), text_color = c_tf4_dot,           text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_right)
    table.cell(legend, 3, 5, trend_tf4,               text_color = c_tf4_dot,                text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_center)
    table.cell(legend, 4, 5, show_div_column ? (bear_div_tf4 ? "🔻" : bull_div_tf4 ? "🔺" : "—") : "",  text_color = bear_div_tf4 ? c_up_3 : bull_div_tf4 ? c_dn_1 : c_neutral,  text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_center)
    table.cell(legend, 5, 5, show_pulse_column ? f_pulse_label(vol_pulse_tf4) : "", text_color = f_pulse_color(vol_pulse_tf4), text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_right)
    table.cell(legend, 6, 5, f_state_name(vol_tf4), text_color = f_termal_matrix_vol(vol_tf4), text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_center)

    // === Row 5 — TF5 ===
    table.cell(legend, 0, 6, "● TF5" + ant5,         text_color = color_tf5,                text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_left)
    table.cell(legend, 1, 6, tf_5,                    text_color = color.new(c_neutral, 20), text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)
    table.cell(legend, 2, 6, f_level_emoji(vol_tf5) + f_buysell_emoji(cdir_tf5) + str.tostring(vol_tf5, "#.0"), text_color = c_tf5_dot,           text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_right)
    table.cell(legend, 3, 6, trend_tf5,               text_color = c_tf5_dot,                text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)
    table.cell(legend, 4, 6, show_div_column ? (bear_div_tf5 ? "🔻" : bull_div_tf5 ? "🔺" : "—") : "",  text_color = bear_div_tf5 ? c_up_3 : bull_div_tf5 ? c_dn_1 : c_neutral,  text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)
    table.cell(legend, 5, 6, show_pulse_column ? f_pulse_label(vol_pulse_tf5) : "", text_color = f_pulse_color(vol_pulse_tf5), text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_right)
    table.cell(legend, 6, 6, f_state_name(vol_tf5), text_color = f_termal_matrix_vol(vol_tf5), text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)

    // === Row 6 — Master (cols 0-1 merged) ===
    table.merge_cells(legend, 0, 7, 1, 7)
    table.cell(legend, 0, 7, "🌈 Master (~" + master_eff_label + ")", text_color = c_master_dot, text_size = sz_tbl, bgcolor = color.new(c_black, 60), text_halign = text.align_left)
    table.cell(legend, 2, 7, f_level_emoji(vol_master) + f_buysell_emoji(cdir_master) + str.tostring(vol_master, "#.0"), text_color = c_master_dot, text_size = sz_tbl, bgcolor = color.new(c_black, 60), text_halign = text.align_right)
    table.cell(legend, 3, 7, trend_master,            text_color = c_master_dot, text_size = sz_tbl, bgcolor = color.new(c_black, 60), text_halign = text.align_center)
    table.cell(legend, 4, 7, show_div_column ? (bear_div_master ? "🔻" : bull_div_master ? "🔺" : "—") : "",  text_color = bear_div_master ? c_up_3 : bull_div_master ? c_dn_1 : c_master_dot,  text_size = sz_tbl, bgcolor = color.new(c_black, 60), text_halign = text.align_center)
    table.cell(legend, 5, 7, show_pulse_column ? f_pulse_label(vol_pulse_master) : "", text_color = f_pulse_color(vol_pulse_master), text_size = sz_tbl, bgcolor = color.new(c_black, 60), text_halign = text.align_right)
    table.cell(legend, 6, 7, f_state_name(vol_master), text_color = f_termal_matrix_vol(vol_master), text_size = sz_tbl, bgcolor = color.new(c_black, 60), text_halign = text.align_center)

    // === Row 7 — Divergence summary (merged 4 cols) ===
    table.merge_cells(legend, 0, 8, 6, 8)
    table.cell(legend, 0, 8, status_txt,
         text_color = status_fg, text_size = sz_lbl,
         bgcolor = status_bg, text_halign = text.align_center)

// ========================================================================================================
// DELTA TWIN BARS RENDER
//   Per-candle line.new rendering with force_overlay=true.
//
//   TWO-MODE OPERATION (v1.6):
//   • show_delta_live = TRUE (default): Uses ONE persistent live line (var line delta_line_live)
//     that updates on EVERY tick to reflect real-time score/direction/color. When the bar closes,
//     the live line is "frozen" into the confirmed FIFO pool. Next bar gets a fresh live line.
//   • show_delta_live = FALSE: Classic isconfirmed-only behavior — twin bar only appears
//     after candle close. The live line variable stays na.
//
//   Confirmed lines (delta_lines pool):
//     Rolling FIFO managing up to delta_lookback (max 500) closed-bar twin bars.
//
//   Width: pixel-controlled via delta_bar_width input (1-8). Independent of chart zoom.
// ========================================================================================================

// Rolling pool of CONFIRMED delta twin bar lines — FIFO managed across bars.
var array<line> delta_lines = array.new<line>()

// Persistent line for the CURRENT (forming) bar — updated intra-bar when show_delta_live is ON.
// On bar close, this line is promoted to the confirmed pool and reset to na.
var line delta_line_live = na

if show_delta_bars
    // === LIVE PATH — updates intra-bar when show_delta_live is ON ===
    if show_delta_live and barstate.isrealtime
        [live_top, live_bottom, live_color] = f_delta_bar_params()
        if not na(live_color)
            if na(delta_line_live)
                // First tick of new bar — create fresh live line
                delta_line_live := line.new(x1 = bar_index, y1 = live_top, x2 = bar_index, y2 = live_bottom, color = live_color, width = delta_bar_width, force_overlay = true)
            else
                // Subsequent tick — update existing live line in place
                line.set_xy1(delta_line_live, bar_index, live_top)
                line.set_xy2(delta_line_live, bar_index, live_bottom)
                line.set_color(delta_line_live, live_color)
                line.set_width(delta_line_live, delta_bar_width)

    // === CONFIRMED PATH — bar closed, "freeze" into pool ===
    if barstate.isconfirmed
        if not na(delta_line_live)
            // Live line for the just-closed bar is promoted to confirmed pool
            array.push(delta_lines, delta_line_live)
            delta_line_live := na
        else
            // Live mode was OFF or no live line for this bar — render confirmed line directly
            [bar_top, bar_bottom, final_color] = f_delta_bar_params()
            if not na(final_color)
                line new_line = line.new(x1 = bar_index, y1 = bar_top, x2 = bar_index, y2 = bar_bottom, color = final_color, width = delta_bar_width, force_overlay = true)
                array.push(delta_lines, new_line)

        // FIFO rolling cleanup — keep only last delta_lookback lines
        while array.size(delta_lines) > delta_lookback
            line old_line = array.shift(delta_lines)
            line.delete(old_line)

// ========================================================================================================
// ALERTS (all gated by barstate.isconfirmed — anti-flicker, see hard rule #7)
// ========================================================================================================
bool cross_up_bs    = ta.crossover(vol_master, black_swan_high) and barstate.isconfirmed
bool cross_dn_bs    = ta.crossunder(vol_master, black_swan_low) and barstate.isconfirmed
bool entered_red    = ta.crossover(vol_master, osc_up3)  and barstate.isconfirmed
bool entered_blue   = ta.crossunder(vol_master, osc_dn3) and barstate.isconfirmed
bool new_div_strong = div_strong and not div_strong[1]

if cross_up_bs and alert_blackswan_high
    alert(s_al_bs_high_pre + str.tostring(black_swan_high, "#.0") + s_al_bs_mid + str.tostring(vol_master, "#.0"), alert.freq_once_per_bar)

if cross_dn_bs and alert_blackswan_low
    alert(s_al_bs_low_pre + str.tostring(black_swan_low, "#.0") + s_al_bs_mid + str.tostring(vol_master, "#.0"), alert.freq_once_per_bar)

if new_div_strong and alert_divergence
    string dir_txt = div_strong_top ? s_al_div_top : s_al_div_bottom
    alert(s_al_div_pre + dir_txt + s_al_div_tf1 + str.tostring(vol_tf1, "#.0") + s_al_div_tf5 + str.tostring(vol_tf5, "#.0"), alert.freq_once_per_bar)

if entered_red and alert_master_extreme
    alert(s_al_red_pre + str.tostring(vol_master, "#.0") + s_al_zone_close, alert.freq_once_per_bar)

if entered_blue and alert_master_extreme
    alert(s_al_blue_pre + str.tostring(vol_master, "#.0") + s_al_zone_close, alert.freq_once_per_bar)

if bear_div_master and alert_divergence_native
    alert(s_al_div_master_bear_pre + str.tostring(vol_master, "#.0"), alert.freq_once_per_bar)

if bull_div_master and alert_divergence_native
    alert(s_al_div_master_bull_pre + str.tostring(vol_master, "#.0"), alert.freq_once_per_bar)

// Billboard alertcondition (UX hint — instructs users on alert setup workflow)
alertcondition(false, title = "HOW TO SETUP ALERTS (READ)", message = "Please select 'Any alert() function call' in the condition menu. You can filter which alerts you receive inside the Indicator Settings (Gear Icon).")
````

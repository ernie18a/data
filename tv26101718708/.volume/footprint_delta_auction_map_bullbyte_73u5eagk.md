# Footprint Delta Auction Map [BullByte]

- url: https://www.tradingview.com/script/73u5eagK-Footprint-Delta-Auction-Map-BullByte/
- type: indicator
- pine_id: PUB;c671117ac6324e01ad0beffcf4d1760d
- version: 1.0

## Description

[b]Footprint Delta Auction Map [BullByte][/b] is an [b]Auction-Market-Theory analytical framework[/b] that measures directional pressure through a [b]3-Tier Delta Engine[/b] (TradingView native volume footprint, lower-timeframe intrabar reconstruction, and single-bar OHLCV proxy), qualifies it against candle conviction and multi-source level confluence (POC, VAH, VAL, session H/L, prior day H/L, weekly H/L, round numbers), classifies the current session as a Trend, Balance or Neutral Day using an Initial Balance regime detector, and only then marks a directional scenario on the chart with a fully sized reference-level map (Entry, Reaction, Extension, Invalidation).

It is designed for discretionary traders who want a single, transparent framework that brings order flow, price structure, key reference levels and session regime into one auditable qualification process.

---

[b]1. WHAT THIS SCRIPT IS[/b]

On each confirmed bar with the required data available, the framework evaluates four complementary questions before a directional scenario can qualify:

[b]Q1 - Is there directional pressure right now?[/b]
Measured through a 3-tier delta engine (see Section 4). Normalized to a bounded -100 to +100 Unified Auction Pressure reading.

[b]Q2 - Is the candle itself convincing?[/b]
Measured through body-to-range ratio and range-to-ATR ratio. A high pressure reading on a doji inside a compressed range does not qualify.

[b]Q3 - Is this happening at a location the market has already respected?[/b]
Measured through a weighted Confluence Ladder that scores proximity to POC, VAH, VAL, session high/low, prior day high/low, weekly high/low, and configurable round numbers.

[b]Q4 - What is today's session character?[/b]
Measured through an Initial Balance (IB) day-type classifier (Trend / Balance / Neutral Day) that adjusts the qualification threshold and Extension sizing.

Only when all four align, a higher-timeframe EMA trend agrees, and the current session's IB is fully formed does the script mark a directional scenario and draw a full reference-level map on the chart.

---

[b]2. WHAT PROBLEM IT SOLVES[/b]

The framework is designed to bring several normally separate forms of market context into one qualification process.

This script is built on the design premise that directional pressure, candle structure, location and session context each answer a different question about the same market event. Rather than treating any one measurement as a standalone trigger, the framework requires these conditions to agree before it marks a directional scenario. The intent is to provide more context around each signal and make the qualification process auditable, not to claim any specific rate of success.

Concretely, it helps with:

- [b]Deliberate selectivity.[/b] A three-criterion gate (Pressure, Candle, Confluence) plus a composite score threshold plus HTF alignment plus IB regime plus cooldown means signals are intentionally infrequent and situational.
- [b]Instrument-adaptive sizing.[/b] For sizing purposes, the script automatically derives an instrument-specific volatility band from the symbol's own historical ATR-as-percent-of-price distribution, reducing the need to manually retune the basic Sizing Unit for each market.
- [b]Full transparency.[/b] A dashboard and a debug panel show which data tier is active, what the composite score is, which qualification criteria passed, what the session regime is, and where the current scenario stands.
- [b]Session-aware context.[/b] An Initial Balance day-type verdict (Trend / Balance / Neutral) recalibrates how demanding the signal threshold is and how far Extension targets project.

---

[b]3. HOW THE FRAMEWORK WORKS[/b]

Each layer answers a specific question from auction market theory, and the layers are structured in dependency order:

[b]Delta / Auction Pressure[/b] - describes what the directional pressure reading says about the current auction. Sourced from TradingView's native volume footprint when available (Tier 3), from lower-timeframe intrabar reconstruction when not (Tier 2), or from a single-bar OHLCV pressure proxy as a universal fallback (Tier 1). Each tier is normalized independently to a common bounded -100 to +100 scale.

[b]Candle Conviction[/b] - did the bar actually travel and close with intent. Prevents a strong pressure reading on a wick-heavy doji from qualifying.

[b]Level Confluence[/b] - is this happening at a price the market has already marked as significant. Uses a triangular decay proximity kernel across POC, VAH/VAL, session H/L, prior day H/L, weekly H/L and round numbers, with pre-defined relative weights. When native footprint data is active, the true volume-profile references receive the highest weights; when footprint data is unavailable, their proxy weights are reduced so the ladder does not treat session-derived references as genuine volume-profile levels.

[b]IB Regime Classifier[/b] - what kind of day is this. Compares today's Initial Balance range against a rolling historical median of prior sessions (today's IB is never included in its own median). Wider than median → Trend Day (raise threshold, widen Extension). Narrower than median → Balance Day (lower threshold, compress Extension). Otherwise Neutral.

[b]HTF EMA Filter[/b] - does the larger timeframe agree with the direction. Uses confirmed previous higher-timeframe EMA slope only (non-repainting pattern with [b]barmerge.lookahead_on[/b] on a [b][1][/b] offset).

Each contributes information the others cannot. Removing any one of them changes what the signal [i]means[/i], not just how many signals fire. That dependency structure is what distinguishes this framework from an aggregation of unrelated indicators.

This is not a mashup of separate published indicators or unrelated indicator modules combined for convenience; it is a single framework in which each measurement was selected and integrated for a specific role in the qualification process.

---

[b]4. THE THREE DATA TIERS[/b]

The three-tier architecture allows the script to use native footprint data when available and progressively simpler pressure estimates when it is not. The active tier is always shown on the dashboard so the user knows exactly what data is currently feeding the score.

[b]Tier 3 - Native TradingView Footprint[/b] (requires Premium or Ultimate plan and footprint-supported symbol)
Uses [b]request.footprint()[/b]. TradingView categorizes lower-timeframe volume via intrabar price action to produce buy volume, sell volume and delta. This is the only tier in this script that uses native footprint data. Not raw exchange bid/ask tick data.

[b]Tier 2 - Intrabar Reconstruction[/b] (default, no special plan required)
Uses [b]request.security_lower_tf()[/b] to decompose each bar into its lower-timeframe sub-bars, then applies the close-in-range volume heuristic to each sub-bar before summing. A lower-timeframe refinement of the single-bar OHLCV pressure estimate that can better distinguish intrabar two-sided movement than a single-OHLC read alone. This is an auction pressure estimate, not native footprint data.

[b]Tier 1 - OHLCV Proxy[/b] (universal fallback)
[pine]buyPressure = (close − low) / range × volume
sellPressure = (high − close) / range × volume[/pine]
A single-bar pressure proxy. Used when native footprint data is not active and lower-timeframe reconstruction is unavailable, disabled, or returns no usable intrabar data. Coarsest estimate.

All three tiers are normalized onto a common bounded -100 to +100 scale before entering the composite score. Same scale does not mean identical statistical distribution: Tier 3 footprint delta and Tier 1 OHLCV pressure have different underlying measurement characteristics. The normalization ensures the score is internally self-consistent per tier.

---

[b]5. COMPOSITE SCORE AND QUALIFICATION[/b]

When the required calculation data is available, the framework produces a Composite Score between 0 and 100:

[b]Composite Score = Fingerprint Score × 0.60 + Ladder Score × 0.40[/b]

[b]Fingerprint Score (60% weight)[/b] combines three sub-components on the current bar:

- [b]Auction Pressure conviction[/b] - up to 40 points, based on absolute normalized pressure
- [b]Candle body and range structure[/b] - up to 35 points (20 points body ratio, 15 points range-to-ATR ratio)
- [b]Volume/pressure balance magnitude[/b] - up to 25 points, using the active tier's available pressure representation

[b]Ladder Score (40% weight)[/b] provides location context. Each active reference level is scored using a triangular proximity kernel: score = 1 − (distance / tolerance) when distance is within tolerance; otherwise the score is zero. Levels are then weighted using predefined relative weights. When native footprint data is active, the genuine volume-profile references receive the highest weights; when footprint data is unavailable, those reference weights are reduced because the script uses session-derived proxies rather than true volume-profile levels.

The 60/40 weighting reflects the design choice to give greater influence to pressure, candle structure and volume/pressure balance than to location. Location confirms; pressure and structure trigger.

[b]Signal qualification requires all of the following simultaneously:[/b]

- Composite Score at or above the effective threshold (default 58, adjusted ±5 by IB day-type)
- Auction Pressure absolute value at or above Criterion 1 minimum (default 35)
- Candle body ratio at or above Criterion 2 minimum (default 0.50)
- Number of level-confluence hits at or above Criterion 3 minimum (default 2)
- HTF EMA slope aligned with signal direction (if HTF filter is enabled)
- Current session's Initial Balance is fully formed and historical IB sample exists
- Current bar's direction (close vs open) aligns with pressure direction
- No active scenario, and cooldown not in effect

---

[b]6. IB REGIME AND HTF CONTEXT[/b]

[b]Initial Balance regime detector.[/b] The first N bars of each session define today's IB range. That range is compared to the rolling median of prior sessions' IB ranges (today is never included in its own median). If today's IB is 1.25x or wider than the historical median, the classifier labels the session Trend Day, raises the qualification threshold by 5 points, and sets the IB Extension scalar to 1.15x. If today's IB is 0.75x or narrower, it labels Balance Day, lowers the qualification threshold by 5 points, and sets the IB Extension scalar to 0.85x. Otherwise, the session is classified as Neutral Day. The final Extension multiplier is also affected by the volatility scalar and the minimum effective-multiplier floor described in Section 7. This is a heuristic regime signal, not a factual market classification.

The IB layer adjusts [i]only[/i] the qualification threshold and the Extension multiplier. It does not change the 60/40 composite weights. Signals are also suppressed until the current session's IB has formed and at least three completed historical IB samples exist.

[b]HTF EMA trend filter.[/b] The higher-timeframe EMA slope is evaluated on the confirmed previous HTF bar ([b][1][/b] offset with [b]barmerge.lookahead_on[/b]), which is the documented non-repainting pattern for confirmed HTF references. The HTF resolution is validated to be strictly higher than the chart timeframe before the request is made; if not, the script halts with an explicit error rather than silently misbehaving.

---

[b]7. ENTRY / REACTION / EXTENSION / INVALIDATION[/b]

When a scenario qualifies, four reference levels are placed on the chart, all sized as multiples of a shared Sizing Unit (not raw ATR).

[b]The Sizing Unit[/b] is a percentile-bounded percentage of price. Its min–max band is, by default, auto-derived from this instrument's own historical ATR-as-percent-of-price distribution (10th and 90th percentiles). This means the sizing base scales naturally with the instrument's own volatility character.

Then:
- [b]Entry[/b] = signal bar close
- [b]Reaction[/b] = Entry ± k1 × Sizing Unit (default k1 = 1.5)
- [b]Extension[/b] = Entry ± effective k2 × Sizing Unit, where effective k2 is the larger of (k1 + 0.5) and (k2 base × IB scalar × volatility regime scalar) when Dynamic Extension Sizing is enabled. When dynamic sizing is disabled, the effective multiplier is the larger of (k1 + 0.5) and k2 base (default k2 base = 2.5)
- [b]Invalidation[/b] = Entry ± k3 × Sizing Unit (default k3 = 1.5)

[b]Extension scaling[/b] combines two factors:

- [b]IB scalar:[/b] 1.15x on Trend Day, 0.85x on Balance Day, 1.00x on Neutral Day
- [b]Volatility regime scalar:[/b] current ATR divided by baseline ATR, clamped between 0.8x and 1.6x so a single volatility spike cannot produce a runaway Extension

[b]Same-bar resolution disclosure:[/b] When a single bar touches both Extension and Invalidation, OHLC data alone cannot establish which was reached first. The script uses a deterministic proximity convention (the level closer to the prior bar's close is assumed to have been reached first). This is a documented convention, not an observation of intrabar order.

---

[b]8. DASHBOARD AND CHART INTERPRETATION[/b]

[b]Directional badge on the signal bar[/b]

- [b]Bullish-direction badge for LONG[/b] scenarios and [b]Bearish-direction badge for SHORT [/b]scenarios; the default colors are green and red and are user-configurable.
- [b]Header line: [/b]▲ LONG or ▼ SHORT
- [b]Second line: [/b]"FP Delta N" when Tier 3 is active, "Pressure N" when Tier 1 or Tier 2 is active. N is the absolute normalized Auction Pressure reading (0–100), not a percentage of volume.
- [b]Third line:[/b] "near [level name]" - the highest-weighted level in proximity
- Fourth line: Session character (Trend Day / Balance Day / Neutral Day)

[b]Four horizontal reference lines[/b]

- [b]Entry[/b] (neutral color, adaptive to chart theme)
- [b]Reaction[/b] (orange)
- [b]Extension[/b] (purple)
- [b]Invalidation[/b] (red)

[b]Right-edge price tags[/b] - each of the four levels has a floating tag on the right edge of the chart showing its exact price. Tags are automatically separated vertically to reduce overlap among the four reference-level labels.

[b]Reference level plots[/b]
- [b]Prior Day High / Low[/b] (orange) - shown in the recent-bars segment
- [b]Weekly High / Low[/b] (blue) - shown in the recent-bars segment
- [b]IB High / Low[/b] (yellow, dashed)
- [b]Session Reference[/b] (purple, dotted) - represents the footprint POC when Tier 3 is active and a session-derived reference when using Tier 1/2

[b]Scenario lifecycle[/b]

- [b]Pending[/b] - scenario is live; right-edge tags follow the current bar
- [b]Reaction Zone Reached[/b] - an alert fires on the first qualifying post-signal touch of the Reaction level; Reaction does not end the scenario.
- [b]Resolved-Extension[/b] - Extension reached first; scenario ends, right-edge tags removed, historical lines frozen
- [b]Resolved-Invalidation[/b] - Invalidation reached first; same treatment

[b]Main Dashboard (default: Top Right)[/b]

- [b]Data Engine[/b] - Footprint (Tick), Intrabar (LTF Recon.), or Proxy (Single-Bar)
- [b]Session Character[/b] - Trend Day, Balance Day, or Neutral Day
- [b]Composite Score[/b] - current bar's score out of 100
- [b]Score Requirement[/b] - effective threshold after IB adjustment
- [b]Qualification Criteria[/b] - pass/fail status for Pressure, Candle, and Confluence
- [b]Active Scenario[/b] - "None" if flat, or "Long/Short - Active (awaiting resolution)" if in progress
- [b]Cooldown[/b] - visible only when active
- [b]Reference Sizing (Inv : Ext)[/b] - the ratio currently applied

[b]Debug Dashboard (default: Bottom Right, can be turned off)[/b]

- [b]Fingerprint Score (60% wt.)[/b]
- [b]Ladder Score (40% wt.)[/b] - score plus number of levels in proximity
- [b]Nearest Level[/b] - the highest-weighted level currently in proximity
- [b]Footprint Delta / Auction Pressure[/b] - the normalized -100 to +100 reading, labeled by active tier
- [b]Extension Sizing Factor[/b] - the current volatility scalar and IB scalar
- [b]Active Data Tier[/b] - full name of the tier plus (for Tier 2) number of intrabars in the current reconstruction

---

[b]9. ILLUSTRATIVE SIGNAL WALKTHROUGH[/b]

[i]The following description is illustrative and is included only to demonstrate how the scoring workflow is interpreted. It is not a historical performance result and does not represent past or future outcomes.[/i]

Consider a 15-minute chart of a liquid instrument during a session that has been classified as a Trend Day.

[b]Setup context:[/b]

- [b]Session Character: [/b]Trend Day (today's IB is wider than the historical median)
- [b]Effective Score Requirement:[/b] raised by the IB adjustment
- [b]HTF (1H) EMA slope:[/b] rising
- [b]Data Engine:[/b] Intrabar (LTF Recon.) - user is on a plan without native footprint access

[b]Bar N (signal bar):[/b]

- Bar closes with a strong upward body (body/range ratio comfortably above the 0.50 minimum)
- Intrabar reconstruction shows aggregated buy-side pressure over sell-side, producing a Unified Auction Pressure reading well above the Pressure minimum
- Price is trading close to the Prior Day High and near a Round Number, both within Level Tolerance
- Ladder Score registers multiple levels in proximity
- The Composite Score exceeds the effective Trend-Day threshold; Pressure, Candle and Confluence criteria all pass; HTF direction agrees; session is ready
- Signal qualifies. A bullish-direction LONG badge appears with text similar to:
  - ▲ LONG
  - Pressure (value)
  - near Prior Day High
  - Trend Day

[b]Level map plotted from the Entry close:[/b]

- [b]Entry [/b]= close of bar N
- [b]Reaction [/b]= Entry + k1 × Sizing Unit (orange)
- [b]Extension [/b]= Entry + effective k2 × Sizing Unit, scaled by Trend-Day and volatility factors (purple)
- [b]Invalidation [/b]= Entry − k3 × Sizing Unit (red)
- [b]Dashboard "Active Scenario" changes to:[/b] Long - Active (awaiting resolution)

[b]Subsequent bars:[/b] As price advances into the Reaction Zone, an alert fires ("Reaction Zone reached"). The scenario stays active - Reaction is a first-touch alert, not a resolution. If price then reaches the Extension level, the scenario resolves as Resolved-Extension: right-edge tags are removed, the four reference lines freeze at the resolution bar, the "Active Scenario" cell returns to "None", and a cooldown period begins during which no new signals can fire. If instead price reached the Invalidation level first, the scenario would resolve as Resolved-Invalidation with the same freeze and cooldown behavior. In the rare case where a single bar touches both Extension and Invalidation, the proximity-based tie-breaking convention (Section 7) determines the resolved outcome.

[b]Note on FVGs and Order Blocks:[/b] This script does not natively detect Fair Value Gaps or Order Blocks. Traders who use dedicated FVG/OB analysis can treat those structures as external chart context and compare them with the reference-level map produced by this script. For example, a trader may observe a signal near a Prior Day Low or VAL while independently identifying a bullish Order Block or FVG at the same area. The FVG/OB structure is not generated or validated by this script.

[b]Real Chart Example with explanation[/b]

[b]Example 1:[/b] A short scenario was marked on Gold when Tier‑2 intrabar-reconstructed Auction Pressure hit 98 on a bearish, high-conviction candle sitting inside confluence tolerance of the Prior Day Low pushing the Composite Score above the 58 threshold under a Neutral Day regime. Footprint (Tier 3) was OFF for this example, so the pressure reading came from OHLCV-based intrabar reconstruction, not native footprint delta. Entry locked at that bar's close (4,363.94); price stalled near PDL for ~30 minutes, then broke down through the Reaction level (4,357.72) and into the Extension zone (4,355.12), with the current bar's intrabar low (4,352.76) already trading beyond Extension, though the scenario still shows "Active" since resolution only confirms on bar close.

[image]https://www.tradingview.com/x/itC1sIdh/[/image]

[b]Example 2:[/b] A long scenario was marked on QQQ when native Footprint (Tier 3) delta hit +66 on a bullish candle confluent with POC, under a Balance Day regime that lowered the qualification threshold by 5 (58 → 53) because today's Initial Balance was narrower than the historical median. Entry locked at 729.35; price consolidated near Entry for roughly an hour, then broke out through Reaction (730.25) toward Extension (730.55), with the Balance Day IB scalar (0.85x) compressing the Extension distance compared to a Trend Day setup. Unlike the earlier Gold example, this signal used genuine tick-based footprint data rather than OHLCV reconstruction.


[image]https://www.tradingview.com/x/l2CqhYWQ/[/image]

---

[b]10. SETTINGS[/b]

[b]Recommended usage:[/b]

Designed primarily for intraday analysis on 5m, 15m, 30m and 1H charts, with the exact usefulness depending on the instrument's session structure and liquidity. Works on liquid crypto pairs, index futures and CFDs, liquid FX pairs, and large-cap equities during regular session hours.

[b]Timeframe defaults:[/b]

-[b] On 5m–15m charts[/b]: default HTF = 60 (1H), Intrabar Reconstruction = 1m
- [b]On 30m–1H charts[/b]: consider raising HTF to 240 (4H)
- [b]On 1m charts:[/b] leaving Intrabar Reconstruction at the default "1" causes the lower-timeframe request to fall back to Tier 1 because the requested resolution is not lower than the chart timeframe.
- [b]Do not set Intrabar Reconstruction to a seconds-based resolution on 5m or higher charts [/b]- this can exceed TradingView's intrabar request cap

Not recommended for very illiquid instruments, daily or higher timeframes (IB is intraday by design), or symbols with no volume data.

[b]Settings you may want to change frequently:[/b]

- [b]Composite Score Requirement[/b] (default 58) - raise for more selective signals, lower for more frequent
- [b]HTF Resolution[/b] (default 60) - align with your own top-down analysis
- [b]Cooldown Period[/b] (default 20 bars) - longer for swing style, shorter for scalping

[b]Settings you may want to tune per market:[/b]

- [b]Round Number Step[/b] - choose a positive price interval appropriate to the instrument
- [b]IB Window[/b] (bars from session open) - on a 15-minute chart, the default 6-bar IB window represents 90 minutes; adjust to match the session structure you want to analyze

[b]These settings are intended as general-purpose defaults and usually do not need frequent adjustment:[/b]

- All ATR-related inputs (Length, Outlier Filter, Floor)
- Pressure Normalization Lookback
- Sizing Regime Lookback
- Auto Sizing Band Lookback
- [b]Level Tolerance %[/b] - controls how close price must be to a reference level for that level to contribute to confluence; the default is 1.2%; users may adjust it to suit the instrument and timeframe

[b]Advanced toggles:[/b]

- [b]Enable Footprint Engine (Tier 3)[/b] - leave OFF unless you have Premium/Ultimate and your symbol supports footprint data
- [b]Enable Intrabar Reconstruction (Tier 2)[/b] - leave ON by default; with the default 1-minute resolution it falls back to Tier 1 on a 1-minute chart because the requested timeframe is not lower than the chart timeframe
- [b]Use Dynamic Extension Sizing[/b] - leave ON for auto-scaled Extension by IB and volatility regime
- [b]Auto-Derive Sizing Band[/b] - leave ON to get instrument-appropriate SL/TP sizing automatically
- [b]Require Next-Bar Confirmation[/b] - turn ON for fewer, more selective signals at the cost of one bar of lag

---

[b]11. ALERTS[/b]

Five alert conditions are available in the TradingView alert dialog:

- [b]FDAM - Long Scenario Marked[/b]
- [b]FDAM - Short Scenario Marked[/b]
- [b]FDAM - Reaction Zone Reached[/b]
- [b]FDAM - Extension Zone Reached[/b]
- [b]FDAM - Invalidation Level Reached[/b]

The script also uses [b]alert()[/b] calls for dynamic messages. Those programmatic alerts are issued once per confirmed bar close. The [b]alertcondition()[/b] entries are selectable in the TradingView alert dialog; the script raises those conditions only on confirmed bars, while the selected alert frequency is configured in TradingView.

The dynamic [b]alert()[/b] messages for Long and Short scenarios include the direction, active-tier pressure reading, nearest qualifying level, and session character (for example: "▲ LONG - Pressure 64 near Prior Day High (Trend Day)").

---

[b]12. LIMITATIONS[/b]

- This is a discretionary analytical indicator rather than a built-in strategy backtest. It does not calculate audited P&L, win rate or historical strategy performance.
- The 3-tier delta engine is not equally precise across tiers. Tier 3 uses native TradingView footprint data. Tier 2 uses lower-timeframe OHLCV reconstruction. Tier 1 uses a single-bar OHLCV proxy. Each is normalized to the same -100 to +100 scale, but same scale does not mean same statistical distribution. The dashboard always shows which tier is active.
- The IB day-type classifier is a heuristic, not a factual market classification. "Session" is defined by whatever session context the chart symbol reports via [b]session.isfirstbar[/b] - this varies across equities, futures, crypto and FX. The classifier labels a session based on IB-to-historical-median ratio thresholds; it does not identify participant intent.
- The confluence ladder weights are pre-defined analytical weights, not statistically derived reliability scores. They reflect the relative significance of level types in auction market theory as designed by the author.
- Same-bar Extension/Invalidation resolution uses a deterministic proximity convention based on distance from the prior bar's close. OHLC data alone cannot establish actual intrabar sequence. This is disclosed on-chart via the resolution status and in this description.
- Signals are intentionally suppressed until the current IB is formed and at least three completed historical IB samples are available.
- Footprint mode (Tier 3) may behave inconsistently during Bar Replay because of TradingView's footprint data caching. The script displays an on-chart notice when Footprint mode is enabled and recommends disabling it for replay testing.

---

[b]13. DISCLAIMER[/b]

This script is a technical analysis tool built for educational and informational purposes only. It does not constitute financial advice, investment advice, trading advice, or a recommendation to buy or sell any security or instrument. Nothing produced by this script - signals, scores, zones, or labels - should be interpreted as a guarantee of future price behavior. Markets are probabilistic, not deterministic; past patterns in auction structure, delta, or volatility regime do not guarantee repeat outcomes. Trading leveraged instruments (crypto, futures, indices) carries substantial risk of loss. You are solely responsible for your own trading decisions, position sizing, and risk management. The author assumes no liability for losses incurred through the use of this script.

Users on plans that do not support volume-footprint data should leave the Footprint Engine toggle OFF. With Footprint mode disabled, the script uses Tier 2 when a usable lower-timeframe reconstruction is available and Tier 1 otherwise.

Published as open-source under the Mozilla Public License 2.0.

[b]- BullByte[/b]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BullByte

// ═══════════════════════════════════════════════════════════════════════════
// DISCLAIMER
// ═══════════════════════════════════════════════════════════════════════════
// This script is a technical analysis tool built for educational and
// informational purposes only. It does not constitute financial advice,
// investment advice, trading advice, or a recommendation to buy or sell any
// security or instrument. Nothing produced by this script - signals, scores,
// zones, or labels - should be interpreted as a guarantee of future price
// behavior. Markets are probabilistic, not deterministic; past patterns in
// auction structure, delta, or volatility regime do not guarantee repeat
// outcomes. Trading leveraged instruments (crypto, futures, indices) carries
// substantial risk of loss. You are solely responsible for your own trading
// decisions, position sizing, and risk management. The author assumes no
// liability for losses incurred through the use of this script.
//
// FOOTPRINT DATA NOTICE: The optional Tier 3 footprint engine in this script
// uses TradingView's request.footprint() function. Footprint mode requires a
// TradingView Premium or Ultimate plan and available volume-footprint data
// for the symbol. Users on plans that do not support footprint data should
// leave this toggle OFF (the default). TradingView's footprint categorizes
// lower-timeframe volume using intrabar price action to produce buy/sell
// volume and delta readings - it is not raw exchange bid/ask tick data.
// When Footprint mode is enabled but footprint data is unavailable for the
// current bar, the script falls back to Tier 2 (intrabar reconstruction)
// or Tier 1 (OHLCV proxy). Footprint mode may use cached footprint data;
// results during Bar Replay can differ. Disable Footprint mode when
// replay-testing.

// ═══════════════════════════════════════════════════════════════════════════
// CONCEPT - What this script is actually measuring, and why
// ═══════════════════════════════════════════════════════════════════════════
// This is built on auction market theory: price moves to find where two-way
// trade can occur, and the *quality* of that trade at a given price (the
// directional pressure observed or estimated, how convincingly it is
// expressed in the candle structure, and whether it is happening at a level
// the market has already shown it respects) is more informative than price
// alone. Three independent measurements feed a single composite score:
//
// 1. AUCTION PRESSURE / DELTA CONVICTION - who is winning the auction,
//    resolved through a 3-tier priority chain. Each tier is a progressively
//    coarser estimate of directional order flow. Only Tier 3 uses
//    TradingView's native volume-footprint data and its calculated footprint
//    delta; Tier 2 and Tier 1 are reconstructed pressure estimates derived
//    from OHLCV data:
//
//      Tier 3 (request.footprint, Premium/Ultimate + footprint data
//        availability required): TradingView footprint buy volume minus
//        sell volume, using the platform's native volume-footprint data.
//        TradingView's footprint categorizes lower-timeframe volume via
//        intrabar price action. This is the only tier in this script that
//        uses TradingView's native volume-footprint data.
//
//      Tier 2 (request.security_lower_tf intrabar reconstruction, no
//        special plan required): the current bar is decomposed into its
//        lower-timeframe sub-bars, and the close-in-range heuristic used
//        in Tier 1 is applied to each sub-bar before summing - a
//        lower-timeframe refinement of the single-bar OHLCV pressure
//        estimate that can better distinguish intrabar two-sided movement
//        (a bar that rallies hard then reverses to close flat will register
//        more two-sided pressure than a single-OHLC read of near-zero net
//        would suggest). Uses historical OHLCV data only; produces
//        consistent readings across reloads and Bar Replay for most
//        symbols when intrabars are available. This is an auction pressure
//        estimate, not native footprint data.
//
//      Tier 1 (OHLCV proxy, universal fallback):
//        buyPressure  = (close - low)  / range * volume
//        sellPressure = (high - close) / range * volume
//        A single-bar pressure proxy. Used only when Tier 3 is off AND
//        Tier 2's requested resolution isn't strictly lower than the
//        chart's (e.g. "1" on a 1-minute chart). Coarsest estimate.
//
//    All three tiers are normalized onto a common bounded -100..100 scale
//    before entering the composite score, so the scoring framework can use
//    the active data source consistently. Note that same scale does not mean
//    identical statistical distribution: Tier 3 footprint delta and Tier 1
//    OHLCV pressure have different underlying measurement characteristics.
//    The normalization ensures the score is internally self-consistent per
//    tier; cross-tier score comparisons across different chart sessions or
//    instruments should be interpreted with this distinction in mind.
//
// 2. CANDLE CONVICTION - body-to-range ratio and range-to-ATR ratio.
//    A directional delta reading means little if the bar itself is a small
//    doji inside a compressed range. This filters for bars that actually
//    traveled and closed with intent.
//
// 3. LEVEL CONFLUENCE - is this happening at a price the market has already
//    marked as significant (POC, VAH/VAL, session H/L, prior day H/L,
//    weekly H/L, round numbers)? Each level gets a proximity score using a
//    triangular decay kernel: score = 1 - (distance / tolerance) for
//    distance <= tolerance, else 0. Levels are assigned predefined relative
//    weights reflecting their analytical significance in auction market
//    theory (volume-profile references weighted highest, round numbers
//    lowest: POC > VAH/VAL > prior day/week > session > round number).
//    When Tier 3 footprint data is unavailable the POC/VAH/VAL weights are
//    halved because the fallback levels are session proxies, not genuine
//    volume-profile derivations. The weighted sum is then normalized against
//    the maximum possible weighted score to produce a 0-100 confluence reading.
//
// A fourth, independent layer - the Initial Balance (IB) day-type
// classifier - compares today's IB range (first N bars) against the
// historical median IB range for this session (computed from prior
// sessions only, never including today's own value). The classifier labels
// the current session as Trend Day, Balance Day, or Neutral Day according
// to the configured IB-to-historical-median ratio thresholds. A wide IB
// relative to median triggers the Trend Day label (score threshold raised,
// extension target widened); a narrow IB triggers Balance Day (threshold
// lowered, extension compressed). This is a heuristic regime signal, not
// a factual market classification. "Session" is defined by the chart
// symbol's session context via session.isfirstbar, which differs across
// asset classes (equities, futures, crypto, FX). 
// This layer adjusts the signal qualification threshold and the dynamic
// extension multiplier; the 60/40 composite weights are not changed by
// the IB verdict. It is not an independent vote in the composite score.
//
// Composite score = fpScore * 0.60 + ladderScore * 0.40. The Fingerprint
// Score (fpScore) combines three sub-components: auction-pressure conviction
// (40 pts), candle body and range structure (35 pts), and volume-balance
// magnitude (25 pts). It is weighted at 60% because these measurements
// directly reflect who is winning the auction at bar level. The Ladder
// Score (ladderScore) at 40% provides location context - where the pressure
// is occurring relative to key reference levels. Location confirms; pressure
// and structure trigger.
//
// ZONE SIZING - Entry/Reaction/Extension/Invalidation are all multiples of
// one shared Sizing Unit, not raw ATR directly. True Range is first capped
// at a multiple of its own rolling median before smoothing (so a single
// liquidation-wick bar has a reduced influence on subsequent volatility
// sizing rather than entering the smoothing process at full magnitude);
// the Sizing Unit itself is then bounded to a min%-max% of price
// band derived from this instrument's own historical volatility distribution.
// That min% floor prevents a genuinely quiet volatility regime from
// producing an unusably tight Invalidation level - the floor applies
// proportionally to Reaction and Extension as well, since all three share
// the same underlying Sizing Unit. Extension sizing is additionally scaled
// on top of that shared unit by both the IB day-type verdict (ibScalar)
// and the ATR-vs-baseline volatility regime (volScalar). No upper ceiling
// is imposed on Extension to allow genuine trend-day extension room.

//@version=6
indicator(
     title            = "Footprint Delta Auction Map [BullByte]",
     shorttitle       = "FDAM [BullByte]",
     overlay          = true,
     behind_chart     = false,
     max_labels_count = 100,
     max_lines_count  = 80,
     max_boxes_count  = 0,
     calc_bars_count  = 2500
 )

// ─────────────────────────────────────────────────────────────────────────
// INPUT GROUPS
// ─────────────────────────────────────────────────────────────────────────
string GRP_ENG  = "Engine"
string GRP_IB   = "Opening Range / IB Verdict"
string GRP_LAD  = "Confluence Ladder"
string GRP_SIG  = "Qualification Criteria"
string GRP_EXT  = "Reference Level Sizing"
string GRP_HTF  = "Higher Timeframe Filter"
string GRP_VIS  = "Visuals & Theme"
string GRP_DASH = "Dashboard"
string GRP_DBG  = "Debug / Score Audit"

// ─────────────────────────────────────────────────────────────────────────
// INPUTS - Engine
// ─────────────────────────────────────────────────────────────────────────
bool i_useFP = input.bool(
     false, "Enable Footprint Engine - Tier 3 (Requires Premium/Ultimate)",
     group   = GRP_ENG,
     tooltip = "OFF by default. Requires a TradingView Premium or Ultimate plan and " +
               "available volume-footprint data for the symbol. TradingView's footprint " +
               "categorizes lower-timeframe volume using intrabar price action to produce " +
               "buy/sell volume and delta readings. Footprint mode may use cached footprint " +
               "data; results during Bar Replay can differ - disable when replay-testing. " +
               "If footprint data is unavailable, the script falls back to Tier 2 " +
               "(intrabar reconstruction) automatically.")

int i_fpTicks = input.int(50, "Footprint Ticks per Row", minval = 1, group = GRP_ENG, active = i_useFP)
int i_fpVA    = input.int(70, "Footprint Value Area %",  minval = 1, maxval = 100, group = GRP_ENG, active = i_useFP)

bool i_useLTF = input.bool(
     true, "Enable Intrabar Reconstruction - Tier 2 (recommended default)",
     group   = GRP_ENG,
     tooltip = "Decomposes each bar into lower-timeframe sub-bars for a path-aware auction " +
               "pressure estimate. Uses only historical OHLCV data - no special plan required. " +
               "Produces consistent readings across chart reloads and Bar Replay for most " +
               "symbols and sessions. Automatically falls back to Tier 1 (single-bar OHLCV " +
               "proxy) if the requested resolution is not strictly lower than your chart " +
               "timeframe (e.g. leave at default '1' on a 1-minute chart - it will safely " +
               "no-op and fall back). Do not set this to a seconds resolution on 5m/15m " +
               "charts - this can exceed TradingView's intrabar request cap.")
string i_ltfRes = input.timeframe("1", "Intrabar Reconstruction Resolution", group = GRP_ENG, active = i_useLTF)

int i_atrLen         = input.int(14, "ATR Length", minval = 1, group = GRP_ENG)
int   i_atrRobustLen   = input.int(30, "ATR Outlier Filter Lookback", minval = 10, group = GRP_ENG,
     tooltip = "Rolling median TR window used to detect and cap outlier bars (wicks/liquidation spikes) before smoothing into ATR.")
float i_atrOutlierMult = input.float(2.5, "ATR Outlier Cap (x Median TR)", minval = 1.2, maxval = 5.0, step = 0.1, group = GRP_ENG,
     tooltip = "Any bar's True Range above this multiple of rolling median TR is capped before entering ATR smoothing.")
float i_minAtrPct = input.float(0.05, "Minimum ATR Floor (% of price)", minval = 0.01, maxval = 1.0, step = 0.01, group = GRP_ENG,
     tooltip = "Hard floor on the volatility measure itself. Prevents Reaction/Extension/Invalidation/signal-badge spacing from collapsing into an overlapping cluster during abnormally quiet regimes.")
int i_normLen = input.int(30, "Pressure Normalization Lookback", minval = 10, group = GRP_ENG,
     tooltip = "Rolling lookback used to normalize the Unified Auction Pressure reading onto " +
               "a bounded -100 to +100 scale. Each tier (Footprint, LTF Reconstruction, OHLCV " +
               "Proxy) is normalized independently against its own recent maximum before " +
               "entering the composite score.")

// ─────────────────────────────────────────────────────────────────────────
// INPUTS - Initial Balance / Day-Type Verdict
// ─────────────────────────────────────────────────────────────────────────
int i_ibBars = input.int(6,  "IB Window (bars from session open)", minval = 2, maxval = 50, group = GRP_IB)
int i_ibLook = input.int(20, "IB Historical Sample (sessions)",    minval = 5, group = GRP_IB)

// ─────────────────────────────────────────────────────────────────────────
// INPUTS - Confluence Ladder
// ─────────────────────────────────────────────────────────────────────────
float i_tolPct  = input.float(1.2, "Level Tolerance %", minval = 0.3, maxval = 4.0, step = 0.1, group = GRP_LAD)
bool  i_usePDHL = input.bool(true, "Include Prior Day High / Low", group = GRP_LAD)
bool  i_useWkHL = input.bool(true, "Include Weekly High / Low",    group = GRP_LAD)
bool  i_useRnd  = input.bool(true, "Include Round Numbers",        group = GRP_LAD)
float i_rndStep = input.float(500, "Round Number Step", minval = 1, step = 100, group = GRP_LAD, active = i_useRnd,
     tooltip = "Price interval for round-number confluence levels. Set to a value meaningful for the instrument being analyzed - for example 500 or 1000 for BTC/USD, 50 or 100 for indices, 0.01 or 0.10 for FX pairs. Must be greater than zero.")

// ─────────────────────────────────────────────────────────────────────────
// INPUTS - Qualification Criteria
// ─────────────────────────────────────────────────────────────────────────
float i_thresh = input.float(
     58.0, "Composite Score Requirement (0-100)",
     minval = 40, maxval = 95, step = 1, group = GRP_SIG)
float i_minDelta = input.float(
     35.0, "Criterion 1 - Min Auction Pressure",
     minval = 10, maxval = 90, step = 5, group = GRP_SIG,
     tooltip = "Minimum absolute Unified Auction Pressure reading required on the signal bar. " +
               "The reading is normalized to a 0-100 scale against its own recent maximum, " +
               "so this threshold is relative, not an absolute volume quantity. Tier 3 uses " +
               "native footprint delta; Tier 2 and Tier 1 use OHLCV-derived pressure estimates.")
float i_minBody = input.float(
     0.50, "Criterion 2 - Min Candle Conviction",
     minval = 0.20, maxval = 0.90, step = 0.05, group = GRP_SIG)
int i_minLadder = input.int(
     2, "Criterion 3 - Min Level Confluence",
     minval = 1, maxval = 6, group = GRP_SIG)
int i_cdBars   = input.int(20, "Cooldown Period (bars)", minval = 5, group = GRP_SIG)
int i_rightPad = input.int(6,  "Right-Edge Tag Padding (bars)", minval = 2, maxval = 30, group = GRP_SIG)
bool i_confirmNext = input.bool(
     false, "Require Next-Bar Confirmation", group = GRP_SIG,
     tooltip = "Waits exactly 1 additional bar for price to continue in the signal direction " +
               "before firing. Reduces false signals at the cost of 1-bar entry lag.")

// ─────────────────────────────────────────────────────────────────────────
// INPUTS - Reference Level (Extension) Sizing
// ─────────────────────────────────────────────────────────────────────────
bool  i_useDynExt = input.bool(true, "Use Dynamic Extension Sizing", group = GRP_EXT)
int   i_volLen    = input.int(50, "Volatility Regime Lookback", minval = 10, group = GRP_EXT, active = i_useDynExt)
// k1/k2/k3 multiply the Sizing Unit (a percentile-bounded % of price),
// not raw ATR directly. The label "Unit Multiplier" reflects this accurately.
float i_k1 = input.float(1.5, "Reaction Zone - Unit Multiplier",        minval = 0.1, step = 0.1, group = GRP_EXT,
     tooltip = "Multiplies the dynamic Sizing Unit (not raw ATR) to set the Reaction Zone distance from entry. " +
               "The Sizing Unit itself is derived from this instrument's own historical volatility distribution, " +
               "bounded between a min% and max% of price. Higher values place the Reaction Zone further from entry.")
float i_k2 = input.float(2.5, "Extension Zone - Unit Multiplier (base)", minval = 0.1, step = 0.1, group = GRP_EXT,
     tooltip = "Base multiplier for the Extension Zone. When Dynamic Extension Sizing is ON, this is additionally " +
               "scaled by the IB day-type verdict and ATR-vs-baseline volatility regime, so the effective " +
               "multiplier shown in the dashboard may differ from this base value.")
float i_k3 = input.float(1.5, "Invalidation - Unit Multiplier",          minval = 0.1, step = 0.1, group = GRP_EXT,
     tooltip = "Multiplies the dynamic Sizing Unit to set the Invalidation level distance from entry. " +
               "The shared min%-of-price floor on the Sizing Unit ensures this level never collapses " +
               "to an unusably tight distance even in abnormally quiet volatility regimes.")
int   i_sizeLookback = input.int(100, "Sizing Regime Lookback (bars)", minval = 30, maxval = 300, group = GRP_EXT,
     tooltip = "Window used to rank current volatility against its own recent history for SL/TP sizing.")

bool i_autoSizeBand = input.bool(true, "Auto-Derive Sizing Band (per-instrument)", group = GRP_EXT,
     tooltip = "When ON, the sizing band (min/max % of price used for SL/TP) is derived from " +
               "this instrument's own historical ATR-as-%-of-price distribution (10th to 90th " +
               "percentile), instead of a fixed universal band. This makes sizing naturally " +
               "asset-appropriate - a naturally quiet instrument and a naturally more volatile " +
               "one each get a band reflecting their own real behavior, without manual " +
               "reconfiguration per symbol. Turn OFF to use the manual Min/Max % inputs below.")
int i_sizeBandLookback = input.int(500, "Auto Sizing Band Lookback (bars)", minval = 100, maxval = 2000, group = GRP_EXT, active = i_autoSizeBand,
     tooltip = "Historical window used to measure this instrument's natural ATR-as-%-of-price " +
               "range. Longer = more stable, slower to adapt to a genuine long-term regime change.")

float i_sizeMinPct = input.float(0.15, "Manual Sizing Unit - Minimum (% of price)", minval = 0.02, maxval = 2.0, step = 0.01, group = GRP_EXT, active = not i_autoSizeBand,
     tooltip = "Used only when Auto-Derive Sizing Band is OFF. SL/TP sizing unit at the quietest end of the recent volatility range.")
float i_sizeMaxPct = input.float(0.55, "Manual Sizing Unit - Maximum (% of price)", minval = 0.05, maxval = 5.0, step = 0.01, group = GRP_EXT, active = not i_autoSizeBand,
     tooltip = "Used only when Auto-Derive Sizing Band is OFF. SL/TP sizing unit at the most " +
               "volatile end of the recent volatility range. The Max/Min ratio bounds the " +
               "Sizing Unit itself; however the Extension Zone is additionally scaled by the " +
               "dynamic IB day-type and ATR-vs-baseline multipliers, so effective Extension " +
               "distance can exceed the basic band. Reaction and Invalidation are not " +
               "additionally scaled and remain within the unit band.")

// Validate manual sizing band so Max is always >= Min. If reversed, the
// interpolation runs in the wrong direction and produces inverted sizing.
if not i_autoSizeBand and i_sizeMaxPct < i_sizeMinPct
    runtime.error("Manual Sizing Unit Maximum (" + str.tostring(i_sizeMaxPct) + "%) must be greater than or equal to Minimum (" + str.tostring(i_sizeMinPct) + "%). Please correct the Reference Level Sizing inputs.")

// ─────────────────────────────────────────────────────────────────────────
// INPUTS - Higher Timeframe Filter
// ─────────────────────────────────────────────────────────────────────────
bool   i_useHTF = input.bool(true, "Require HTF Trend Alignment", group = GRP_HTF)
string i_htfRes = input.timeframe("60", "HTF Resolution", group = GRP_HTF, active = i_useHTF)
int    i_htfLen = input.int(21, "HTF EMA Length", minval = 5, group = GRP_HTF, active = i_useHTF)

// ─────────────────────────────────────────────────────────────────────────
// INPUTS - Visuals & Theme
// ─────────────────────────────────────────────────────────────────────────
bool  i_adaptiveEntry = input.bool(true, "Adaptive Entry Color (dark/light auto)", group = GRP_VIS)
color i_bullC  = input.color(color.new(#00c896, 0), "Bullish Direction Color", group = GRP_VIS)
color i_bearC  = input.color(color.new(#ff4d6d, 0), "Bearish Direction Color", group = GRP_VIS)
color i_reactC = input.color(color.new(#f5a623, 0), "Reaction Zone Color",     group = GRP_VIS)
color i_extC   = input.color(color.new(#9c6ade, 0), "Extension Zone Color",    group = GRP_VIS)
color i_invalC = input.color(color.new(#e63950, 0), "Invalidation Color",      group = GRP_VIS)
color i_entC   = input.color(color.new(#808080, 0), "Entry Color (fallback)",  group = GRP_VIS)
color i_htfC   = input.color(color.new(#f5a623, 40), "HTF Level Color",        group = GRP_VIS)
int   i_lineWidth   = input.int(2, "Reference Line Width", minval = 1, maxval = 4, group = GRP_VIS)
float i_badgeOffset = input.float(0.6, "Signal Badge Distance (Sizing Unit x)", minval = 0.2, maxval = 2.0, step = 0.1, group = GRP_VIS,
     tooltip = "Controls how far above/below the signal bar the direction badge appears, " +
               "expressed as a multiple of the dynamic Sizing Unit (not raw ATR). The Sizing " +
               "Unit adapts to the instrument's own volatility distribution, so badge spacing " +
               "scales naturally with market conditions.")
float i_tagMinGap   = input.float(0.18, "Tag Minimum Spacing (Sizing Unit x)", minval = 0.05, maxval = 0.5, step = 0.01, group = GRP_VIS,
     tooltip = "Minimum vertical gap between Entry, Reaction, Extension and Invalidation price " +
               "tags, expressed as a multiple of the dynamic Sizing Unit. Prevents overlapping " +
               "labels on quiet instruments or tight range conditions.")

// ─────────────────────────────────────────────────────────────────────────
// INPUTS - Dashboard
// ─────────────────────────────────────────────────────────────────────────
string i_dashPos = input.string(
     "Top Right", "Main Dashboard Position",
     options = ["Top Right", "Top Left", "Top Center", "Bottom Right", "Bottom Left", "Bottom Center", "Middle Right", "Middle Left"],
     group = GRP_DASH)
string i_dashSize = input.string("Small", "Main Dashboard Text Size", options = ["Tiny", "Small", "Normal"], group = GRP_DASH)
string i_dbgPos = input.string(
     "Bottom Right", "Debug Dashboard Position",
     options = ["Top Right", "Top Left", "Top Center", "Bottom Right", "Bottom Left", "Bottom Center", "Middle Right", "Middle Left"],
     group = GRP_DASH)
string i_dbgSize = input.string("Tiny", "Debug Dashboard Text Size", options = ["Tiny", "Small", "Normal"], group = GRP_DASH)

// ─────────────────────────────────────────────────────────────────────────
// INPUTS - Debug
// ─────────────────────────────────────────────────────────────────────────
bool i_dbg = input.bool(true, "Show Live Score Breakdown", group = GRP_DBG)

// ─────────────────────────────────────────────────────────────────────────
// THEME DERIVATION
// ─────────────────────────────────────────────────────────────────────────
color themeBgSubtle   = color.new(chart.bg_color, 30)
color themeFg         = chart.fg_color
color entryColorFinal = i_adaptiveEntry ? themeFg : i_entC
color badgeBg         = color.new(#131722, 0)

// ═══════════════════════════════════════════════════════════════════════════
// TYPE - SignalTrade
// ═══════════════════════════════════════════════════════════════════════════
type SignalTrade
    int    signalBar
    string dir
    float  entry
    float  t1
    float  t2
    float  sl
    string status
    label  sigReason
    float  dispEntryY
    float  dispInvalY
    float  dispReactY
    float  dispExtY
    label  tagEntry
    label  tagInvalid
    label  tagReact
    label  tagExt
    line   histEntry
    line   histT1
    line   histT2
    line   histSL

// ═══════════════════════════════════════════════════════════════════════════
// FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════

f_extractFP() =>
    footprint fp = request.footprint(i_fpTicks, i_fpVA)
    bool  ok = not na(fp)
    float bv = ok ? fp.buy_volume()  : na
    float sv = ok ? fp.sell_volume() : na
    float dl = ok ? fp.delta()       : na
    float pc = ok ? (fp.poc().up_price() + fp.poc().down_price()) / 2.0 : na
    float vh = ok ? fp.vah().up_price()   : na
    float vl = ok ? fp.val().down_price() : na
    [ok, bv, sv, dl, pc, vh, vl]

// Decomposes the current bar into lower-timeframe sub-bars and applies the
// close-in-range volume heuristic to each before summing - a path-aware
// refinement of the single-bar proxy. Uses lower-timeframe OHLCV data and
// is designed to produce consistent historical and replay behavior when the
// required intrabars are available for the symbol and plan. Returns ok=false
// and falls back to Tier 1 when the intrabar array is empty (data limit
// reached or resolution not strictly lower than the chart timeframe).
f_intrabarDelta() =>
    [c, h, l, v] = request.security_lower_tf(
         syminfo.tickerid, i_ltfRes, [close, high, low, volume],
         ignore_invalid_timeframe = true)
    int   n    = c.size()
    bool  ok   = n > 0
    float buyV  = 0.0
    float sellV = 0.0
    if ok
        for i = 0 to n - 1
            float hi  = h.get(i)
            float lo  = l.get(i)
            float cl  = c.get(i)
            float vol = v.get(i)
            float rng = math.max(hi - lo, syminfo.mintick)
            buyV  += (cl - lo) / rng * vol
            sellV += (hi - cl) / rng * vol
    [ok, buyV, sellV, n]

f_proximity(float src, float lvl, float tol) =>
    float dist = math.abs(lvl - src)
    dist <= tol ? 1.0 - dist / tol : 0.0

f_contrastText(color c) =>
    float lum = (color.r(c) * 299 + color.g(c) * 587 + color.b(c) * 114) / 1000
    lum > 150 ? color.black : color.white

f_deconflict4(float p0, float p1, float p2, float p3, float minGap) =>
    float a0 = p0
    float a1 = math.min(p1, a0 - minGap)
    float a2 = math.min(p2, a1 - minGap)
    float a3 = math.min(p3, a2 - minGap)
    [a0, a1, a2, a3]

f_killTags(SignalTrade t) =>
    label.delete(t.tagEntry)
    label.delete(t.tagInvalid)
    label.delete(t.tagReact)
    label.delete(t.tagExt)

f_freezeHist(SignalTrade t, int x) =>
    line.set_x2(t.histEntry, x)
    line.set_x2(t.histT1,    x)
    line.set_x2(t.histT2,    x)
    line.set_x2(t.histSL,    x)

f_slideTag(label lbl, int rightX, float price, string txt) =>
    if not na(lbl)
        label.set_xy(lbl, rightX, price)
        label.set_text(lbl, txt)

f_tablePos(string p) =>
    switch p
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        => position.top_right

f_tableSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        => size.small

// ═══════════════════════════════════════════════════════════════════════════
// FOOTPRINT ENGINE - Tier 3 (native TradingView footprint, Premium/Ultimate)
// ═══════════════════════════════════════════════════════════════════════════
bool  fpAvail   = false
float fpBuyVol  = na
float fpSellVol = na
float fpDelta   = na
float fpPOC     = na
float fpVAH     = na
float fpVAL     = na

if i_useFP
    [_ok, _bv, _sv, _dl, _pc, _vh, _vl] = f_extractFP()
    fpAvail   := _ok
    fpBuyVol  := _bv
    fpSellVol := _sv
    fpDelta   := _dl
    fpPOC     := _pc
    fpVAH     := _vh
    fpVAL     := _vl

bool fpOK = i_useFP and fpAvail

// ═══════════════════════════════════════════════════════════════════════════
// INTRABAR RECONSTRUCTION ENGINE - Tier 2 (LTF OHLCV, no special plan)
// ═══════════════════════════════════════════════════════════════════════════
var bool  ltfOk      = false
var float ltfBuyVol  = na
var float ltfSellVol = na
var int   ltfN       = 0

if i_useLTF
    [_ok2, _bv2, _sv2, _n2] = f_intrabarDelta()
    ltfOk      := _ok2
    ltfBuyVol  := _bv2
    ltfSellVol := _sv2
    ltfN       := _n2

bool tier2OK = (not fpOK) and i_useLTF and ltfOk
int  actTier = fpOK ? 3 : (tier2OK ? 2 : 1)

// ═══════════════════════════════════════════════════════════════════════════
// REFERENCE LEVELS - Prior Day, Weekly, HTF Trend Filter
// ═══════════════════════════════════════════════════════════════════════════
// Prior Day and Weekly reference levels use the confirmed non-repainting
// pattern: request the previous period's values ([1] offset) with
// lookahead_on so that the confirmed prior-period high/low is available
// from the first bar of the new period onward, matching historical and
// live behavior consistently.
var float pdH = na
var float pdL = na
if i_usePDHL
    [dH, dL] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead = barmerge.lookahead_on)
    pdH := dH
    pdL := dL

var float wkH = na
var float wkL = na
if i_useWkHL
    [wH, wL] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead = barmerge.lookahead_on)
    wkH := wH
    wkL := wL

// Non-repainting HTF helper: computed at global scope so Pine accepts
// the function declaration. The EMA is evaluated in the HTF context by
// request.security; the [1] vs [2] offset ensures we compare only
// *fully closed* HTF bars, and lookahead_on maps the last confirmed
// HTF value onto every chart bar within that HTF period.
f_htfEmaRising() =>
    float e = ta.ema(close, i_htfLen)
    e[1] > e[2]

f_htfEmaFalling() =>
    float e = ta.ema(close, i_htfLen)
    e[1] < e[2]

// HTF validation runs first, before the request, so the script never
// performs a conceptually invalid HTF request before halting.
bool htfResValid = not i_useHTF or timeframe.in_seconds(i_htfRes) > timeframe.in_seconds(timeframe.period)
if i_useHTF and not htfResValid
    runtime.error("HTF Resolution (" + i_htfRes + ") must be strictly higher than the chart timeframe (" + timeframe.period + "). Please select a higher HTF timeframe in the Higher Timeframe Filter settings.")

var bool htfUp   = false
var bool htfDown = false
if i_useHTF
    [_htfUp, _htfDown] = request.security(
         syminfo.tickerid, i_htfRes,
         [f_htfEmaRising(), f_htfEmaFalling()],
         lookahead = barmerge.lookahead_on)
    htfUp   := _htfUp
    htfDown := _htfDown

bool htfLongOK  = not i_useHTF or htfUp
bool htfShortOK = not i_useHTF or htfDown

// ═══════════════════════════════════════════════════════════════════════════
// AUCTION PRESSURE - Tier 1 proxy, Tier 2 intrabar reconstruction, Tier 3
// footprint - unified onto a common bounded -100..100 scale
// ═══════════════════════════════════════════════════════════════════════════
float barRng   = math.max(high - low, syminfo.mintick)
float buyPres  = (close - low)  / barRng * volume
float sellPres = (high - close) / barRng * volume
float t1Delta  = buyPres - sellPres
float t2Delta  = ltfBuyVol - ltfSellVol

float absFPD = fpOK    ? math.abs(nz(fpDelta)) : 0.0
float absT2D = tier2OK ? math.abs(t2Delta)     : 0.0
float absT1D = math.abs(t1Delta)

float maxFPD = ta.highest(absFPD, i_normLen)
float maxT2D = ta.highest(absT2D, i_normLen)
float maxT1D = ta.highest(absT1D, i_normLen)

float fpDNorm = fpOK and maxFPD > 0 ?
     math.max(-100.0, math.min(100.0, nz(fpDelta) / maxFPD * 100.0)) : na
float t2DNorm = tier2OK and maxT2D > 0 ?
     math.max(-100.0, math.min(100.0, t2Delta / maxT2D * 100.0)) : na
float t1DNorm = maxT1D > 0 ?
     math.max(-100.0, math.min(100.0, t1Delta / maxT1D * 100.0)) : 0.0

float uDelta = fpOK ? nz(fpDNorm) : tier2OK ? nz(t2DNorm) : t1DNorm

// ═══════════════════════════════════════════════════════════════════════════
// FINGERPRINT SCORE - auction pressure conviction + candle conviction +
// volume balance
// ═══════════════════════════════════════════════════════════════════════════
float tr         = ta.tr(true)
float trMedian   = ta.percentile_nearest_rank(tr, i_atrRobustLen, 50)
float trCapped   = trMedian > 0 ? math.min(tr, trMedian * i_atrOutlierMult) : tr
float atrFloor   = close * (i_minAtrPct / 100.0)
float atrRobust  = math.max(ta.rma(trCapped, i_atrLen), atrFloor)
float bodyRatio  = math.abs(close - open) / barRng
float rangeRatio = atrRobust > 0 ? barRng / atrRobust : 1.0

float compA = math.abs(uDelta) / 100.0 * 40.0

float compB = math.min(1.0, bodyRatio / 0.65) * 20.0 + math.min(1.0, rangeRatio / 2.0) * 15.0

float compC = 0.0
if fpOK
    float totFP = nz(fpBuyVol) + nz(fpSellVol)
    compC := totFP > 0 ? math.abs(nz(fpBuyVol) - nz(fpSellVol)) / totFP * 25.0 : 12.5
else if tier2OK
    float totLTF = nz(ltfBuyVol) + nz(ltfSellVol)
    compC := totLTF > 0 ? math.abs(nz(ltfBuyVol) - nz(ltfSellVol)) / totLTF * 25.0 : 12.5
else
    float bPos = (close - low) / barRng
    compC := math.abs(bPos - 0.5) * 2.0 * 25.0

float fpScore = math.min(100.0, compA + compB + compC)
bool  fpBull  = uDelta > 0.0 and close > open
bool  fpBear  = uDelta < 0.0 and close < open

// ═══════════════════════════════════════════════════════════════════════════
// SESSION / VALUE-AREA REFERENCE LEVELS
// ═══════════════════════════════════════════════════════════════════════════
int   bSess = math.max(1, nz(ta.barssince(session.isfirstbar), 0) + 1)
float sHigh = ta.highest(high, bSess)
float sLow  = ta.lowest(low,   bSess)

// When Tier 3 footprint is active these are genuine volume-profile levels.
// When falling back to Tier 1/2 these are session-derived reference proxies
// only - not volume-profile calculations. Naming reflects the active tier.
float pocLvl  = fpOK ? fpPOC : (sHigh + sLow) * 0.5
float vahLvl  = fpOK ? fpVAH : sHigh * 0.999
float valLvl  = fpOK ? fpVAL : sLow  * 1.001
string pocLbl = fpOK ? "POC"           : "Session Mid"
string vahLbl = fpOK ? "VAH"           : "Upper Session Ref"
string valLbl = fpOK ? "VAL"           : "Lower Session Ref"
float rndLvl = math.round(close / i_rndStep) * i_rndStep

// ═══════════════════════════════════════════════════════════════════════════
// CONFLUENCE LADDER - weighted, normalized proximity across all active levels
// ═══════════════════════════════════════════════════════════════════════════
f_ladderCalc(float src) =>
    float tol   = src * (i_tolPct / 100.0)
    float maxP  = 0.0
    float rawS  = 0.0
    int   hits  = 0
    string topL = "none"
    float topW  = 0.0

    // Weights for POC/VAH/VAL are reduced when footprint is unavailable because
    // the fallback levels are session proxies, not true volume-profile levels.
    float pocW = fpOK ? 5.0 : 2.5
    float p0   = f_proximity(src, pocLvl, tol)
    maxP += pocW
    if p0 > 0.0
        rawS += pocW * p0
        hits += 1
        if pocW > topW
            topW := pocW
            topL := pocLbl

    float vahW = fpOK ? 4.0 : 2.0
    float p1   = f_proximity(src, vahLvl, tol)
    maxP += vahW
    if p1 > 0.0
        rawS += vahW * p1
        hits += 1
        if vahW > topW
            topW := vahW
            topL := vahLbl

    float valW = fpOK ? 4.0 : 2.0
    float p2   = f_proximity(src, valLvl, tol)
    maxP += valW
    if p2 > 0.0
        rawS += valW * p2
        hits += 1
        if valW > topW
            topW := valW
            topL := valLbl

    float w3 = 2.0
    float p3 = f_proximity(src, sHigh, tol)
    maxP += w3
    if p3 > 0.0
        rawS += w3 * p3
        hits += 1
        if w3 > topW
            topW := w3
            topL := "Session High"

    float w4 = 2.0
    float p4 = f_proximity(src, sLow, tol)
    maxP += w4
    if p4 > 0.0
        rawS += w4 * p4
        hits += 1
        if w4 > topW
            topW := w4
            topL := "Session Low"

    if i_usePDHL and not na(pdH)
        float w5 = 3.0
        float p5 = f_proximity(src, pdH, tol)
        maxP += w5
        if p5 > 0.0
            rawS += w5 * p5
            hits += 1
            if w5 > topW
                topW := w5
                topL := "Prior Day High"

    if i_usePDHL and not na(pdL)
        float w6 = 3.0
        float p6 = f_proximity(src, pdL, tol)
        maxP += w6
        if p6 > 0.0
            rawS += w6 * p6
            hits += 1
            if w6 > topW
                topW := w6
                topL := "Prior Day Low"

    if i_useWkHL and not na(wkH)
        float w7 = 3.0
        float p7 = f_proximity(src, wkH, tol)
        maxP += w7
        if p7 > 0.0
            rawS += w7 * p7
            hits += 1
            if w7 > topW
                topW := w7
                topL := "Weekly High"

    if i_useWkHL and not na(wkL)
        float w8 = 3.0
        float p8 = f_proximity(src, wkL, tol)
        maxP += w8
        if p8 > 0.0
            rawS += w8 * p8
            hits += 1
            if w8 > topW
                topW := w8
                topL := "Weekly Low"

    if i_useRnd
        float w9 = 1.0
        float p9 = f_proximity(src, rndLvl, tol)
        maxP += w9
        if p9 > 0.0
            rawS += w9 * p9
            hits += 1
            if w9 > topW
                topW := w9
                topL := "Round Number"

    float norm = maxP > 0.0 ? math.min(100.0, rawS / maxP * 100.0) : 0.0
    [norm, hits, topL]

[ladderScore, ladderHits, ladderTop] = f_ladderCalc(close)

// ═══════════════════════════════════════════════════════════════════════════
// INITIAL BALANCE / DAY-TYPE CLASSIFIER
// ═══════════════════════════════════════════════════════════════════════════
var float ibH       = na
var float ibL       = na
var int   ibCnt     = 0
var bool  ibFormed  = false
var string ibVerdict = "Neutral Day"
var float ibAdj      = 0.0
var array<float> ibW = array.new<float>()

if session.isfirstbar
    ibH       := high
    ibL       := low
    ibCnt     := 1
    ibFormed  := false
    // Reset verdict and adjustment at session open so the opening window
    // of the new session never inherits the prior session's classification.
    // Signals cannot qualify until ibFormed becomes true (see signalReady).
    ibVerdict := "Neutral Day"
    ibAdj     := 0.0

if not session.isfirstbar and not ibFormed
    ibH   := math.max(ibH, high)
    ibL   := math.min(ibL, low)
    ibCnt += 1
    if ibCnt >= i_ibBars
        ibFormed := true
        if ibW.size() >= 3
            float med = array.median(ibW)
            float rat = med > 0.0 ? (ibH - ibL) / med : 1.0
            if rat >= 1.25
                ibVerdict := "Trend Day"
                ibAdj     := 5.0
            else if rat <= 0.75
                ibVerdict := "Balance Day"
                ibAdj     := -5.0
            else
                ibVerdict := "Neutral Day"
                ibAdj     := 0.0
        ibW.push(ibH - ibL)
        if ibW.size() > i_ibLook
            ibW.shift()

// signalReady: both conditions must be true before a signal can qualify.
// ibFormed ensures the current session's IB window has completed.
// ibW.size() >= 3 ensures a meaningful historical IB sample exists for
// the median comparison. Signals are suppressed until both are satisfied.
bool signalReady = ibFormed and ibW.size() >= 4

// ═══════════════════════════════════════════════════════════════════════════
// DYNAMIC EXTENSION SIZING
// ═══════════════════════════════════════════════════════════════════════════
float atrBaseline = ta.sma(atrRobust, i_volLen)
float volRegime   = atrBaseline > 0.0 ? atrRobust / atrBaseline : 1.0
float volScalar   = math.max(0.8, math.min(1.6, volRegime))
float ibScalar    = ibVerdict == "Trend Day" ? 1.15 : ibVerdict == "Balance Day" ? 0.85 : 1.0

// Extension multiplier scales with both IB day-type verdict (ibScalar) and
// ATR-vs-baseline volatility regime (volScalar). volScalar is clamped to
// 0.8-1.6x so a single volatility spike cannot produce a runaway extension.
float effK2 = i_useDynExt ?
     math.max(i_k1 + 0.5, i_k2 * ibScalar * volScalar) :
     math.max(i_k1 + 0.5, i_k2)

// Percentile-bounded sizing unit: k1/k2/k3 multiply this instead of raw
// atrRobust. atrPercentile ranks current volatility against its own recent
// (short-term) range (0..1); the sizing unit interpolates between a min%
// and max% of price using that rank as weight. This caps the maximum
// possible SL/TP distance ratio at maxPct / minPct, regardless of how
// extreme raw ATR becomes.
//
// The min%/max% band itself is, by default, derived from this instrument's
// own long-run ATR-as-%-of-price distribution (10th/90th percentile) rather
// than a fixed universal constant - so a naturally quiet instrument and a
// naturally volatile one each get a band that reflects their own real
// behavior instead of being forced into one shared range.
float atrPctOfPrice = close > 0 ? atrRobust / close * 100.0 : na
float autoMinPct    = ta.percentile_nearest_rank(atrPctOfPrice, i_sizeBandLookback, 10)
float autoMaxPct    = ta.percentile_nearest_rank(atrPctOfPrice, i_sizeBandLookback, 90)

// Both percentiles must be available before the auto band is applied.
// If either is still na (insufficient warm-up history), fall back to
// the manual constants. This also avoids a na propagation in the
// math.max() call if autoMinPct were na while autoMaxPct is not.
bool   autoBandReady = i_autoSizeBand and not na(autoMinPct) and not na(autoMaxPct)
float effSizeMinPct  = autoBandReady ? autoMinPct : i_sizeMinPct
float effSizeMaxPct  = autoBandReady ? math.max(autoMaxPct, autoMinPct + 0.05) : i_sizeMaxPct

float sizeAtrHi     = ta.highest(atrRobust, i_sizeLookback)
float sizeAtrLo     = ta.lowest(atrRobust, i_sizeLookback)
float atrPercentile = sizeAtrHi > sizeAtrLo ? (atrRobust - sizeAtrLo) / (sizeAtrHi - sizeAtrLo) : 0.5
float sizingUnit    = close * (effSizeMinPct + atrPercentile * (effSizeMaxPct - effSizeMinPct)) / 100.0

// ═══════════════════════════════════════════════════════════════════════════
// COMPOSITE SCORE & QUALIFICATION CRITERIA
// ═══════════════════════════════════════════════════════════════════════════
float composite = math.min(100.0, fpScore * 0.60 + ladderScore * 0.40)
float effThresh = i_thresh + ibAdj

bool critDelta      = math.abs(uDelta) >= i_minDelta
bool critBody       = bodyRatio >= i_minBody
bool critConfluence = ladderHits >= i_minLadder
bool allCriteria    = critDelta and critBody and critConfluence

bool rawLong  = allCriteria and composite >= effThresh and fpBull and htfLongOK and signalReady and not na(sizingUnit)
bool rawShort = allCriteria and composite >= effThresh and fpBear and htfShortOK and signalReady and not na(sizingUnit)

// ═══════════════════════════════════════════════════════════════════════════
// TRADE STATE MACHINE
// ═══════════════════════════════════════════════════════════════════════════
var array<SignalTrade> trades = array.new<SignalTrade>()
var int  cdCount   = 0
var bool inTrade   = false
int      TRADE_CAP = 15

var bool   alertLong      = false
var bool   alertShort     = false
var bool   alertInvalid   = false
var bool   alertExtension = false
var bool   alertReaction  = false
var string lastReason     = ""

var bool pendingL   = false
var bool pendingS   = false
var int  pendingBar = 0

var label lblIBH  = na
var label lblIBL  = na
var float prevIBH = na
var float prevIBL = na

var label lblPDH = na
var label lblPDL = na
var label lblWkH = na
var label lblWkL = na
var float prevPDH = na
var float prevPDL = na
var float prevWkH = na
var float prevWkL = na

alertLong      := false
alertShort     := false
alertInvalid   := false
alertExtension := false
alertReaction  := false

if barstate.isconfirmed

    if cdCount > 0
        cdCount -= 1

    if trades.size() > 0
        SignalTrade t = trades.get(trades.size() - 1)

        if t.status == "Pending"
            bool reactionNow = t.dir == "Long" ?
                 (high >= t.t1 and high[1] < t.t1) :
                 (low  <= t.t1 and low[1]  > t.t1)
            if reactionNow
                alertReaction := true

            bool extHit = t.dir == "Long" ? high >= t.t2 : low  <= t.t2
            bool invHit = t.dir == "Long" ? low  <= t.sl : high >= t.sl

            if extHit and invHit
                // OHLC data cannot establish intrabar sequence: when both
                // Extension and Invalidation are touched on the same bar,
                // the outcome is determined by a proximity-based convention
                // using the prior bar's close as a reference point. The
                // level closer to the prior close is assumed to have been
                // reached first. This is a deterministic tie-breaking
                // convention, not an observation of actual intrabar order.
                // See the publication description for full disclosure.
                float distExt = math.abs(close[1] - t.t2)
                float distInv = math.abs(close[1] - t.sl)
                if distInv < distExt
                    extHit := false
                else
                    invHit := false

            if extHit
                t.status := "Resolved-Extension"
                f_killTags(t)
                f_freezeHist(t, bar_index)
                inTrade := false
                cdCount := i_cdBars
                alertExtension := true
            else if invHit
                t.status := "Resolved-Invalidation"
                f_killTags(t)
                f_freezeHist(t, bar_index)
                inTrade := false
                cdCount := i_cdBars
                alertInvalid := true

    if trades.size() > 0
        SignalTrade t = trades.get(trades.size() - 1)
        if t.status == "Pending"
            int rightX = bar_index + i_rightPad
            line.set_x2(t.histEntry, bar_index)
            line.set_x2(t.histT1,    bar_index)
            line.set_x2(t.histT2,    bar_index)
            line.set_x2(t.histSL,    bar_index)

            f_slideTag(t.tagEntry,   rightX, t.dispEntryY, "Entry "        + str.tostring(math.round(t.entry, 2)))
            f_slideTag(t.tagInvalid, rightX, t.dispInvalY, "Invalidation " + str.tostring(math.round(t.sl,    2)))
            f_slideTag(t.tagReact,   rightX, t.dispReactY, "Reaction "     + str.tostring(math.round(t.t1,    2)))
            f_slideTag(t.tagExt,     rightX, t.dispExtY,   "Extension "    + str.tostring(math.round(t.t2,    2)))

    bool canFire  = not inTrade and cdCount == 0
    bool rawFireL = canFire and rawLong
    bool rawFireS = canFire and rawShort

    bool fireL = false
    bool fireS = false

    if i_confirmNext
        // Confirmation enforces exactly one bar of lag: the signal must fire
        // on bar_index == pendingBar + 1 only. canFire is also re-checked so
        // a confirmed pending signal cannot stack on top of a trade that
        // opened on the same bar the confirmation would otherwise trigger.
        if pendingL and bar_index == pendingBar + 1 and close > close[1] and canFire
            fireL := true
        if pendingS and bar_index == pendingBar + 1 and close < close[1] and canFire
            fireS := true

        if pendingL or pendingS
            pendingL := false
            pendingS := false

        // justFired prevents a fresh rawFire on the same bar that just
        // confirmed a pending signal from immediately re-arming a new
        // pending state. The new raw signal can arm on the next bar instead.
        bool justFired = fireL or fireS
        if rawFireL and not pendingL and not pendingS and not justFired
            pendingL   := true
            pendingBar := bar_index
        if rawFireS and not pendingL and not pendingS and not justFired
            pendingS   := true
            pendingBar := bar_index
    else
        fireL := rawFireL
        fireS := rawFireS

    if fireL or fireS
        bool   isL = fireL
        string dir = isL ? "Long" : "Short"
        float  en  = close

        float t1p = isL ? en + i_k1  * sizingUnit : en - i_k1  * sizingUnit
        float t2p = isL ? en + effK2 * sizingUnit : en - effK2 * sizingUnit
        float slp = isL ? en - i_k3  * sizingUnit : en + i_k3  * sizingUnit

        color dc     = isL ? i_bullC : i_bearC
        int   rightX = bar_index + i_rightPad

        float  badgeOff = sizingUnit * i_badgeOffset
        string badgeHdr = isL ? "▲ LONG" : "▼ SHORT"
        string pressureLbl = actTier == 3 ? "FP Delta " : "Pressure "
        string lineDelta = pressureLbl + str.tostring(math.round(math.abs(uDelta)))
        string lineLevel = ladderTop != "none" ? "near " + ladderTop : ""
        string lineDay   = ibVerdict
        string badgeTxt  = badgeHdr + "\n" + lineDelta + (lineLevel != "" ? "\n" + lineLevel : "") + "\n" + lineDay
        lastReason := badgeHdr + " - " + lineDelta + (lineLevel != "" ? " " + lineLevel : "") + " (" + lineDay + ")"

        label sigReason = label.new(
             bar_index, isL ? low - badgeOff : high + badgeOff, badgeTxt,
             style           = isL ? label.style_label_up : label.style_label_down,
             color           = dc,
             textcolor       = f_contrastText(dc),
             size            = size.small,
             text_formatting = text.format_bold)

        float minGap = sizingUnit * i_tagMinGap
        float dispEntryY = na
        float dispInvalY = na
        float dispReactY = na
        float dispExtY   = na

        if isL
            [dExt, dReact, dEntry, dInval] = f_deconflict4(t2p, t1p, en, slp, minGap)
            dispExtY   := dExt
            dispReactY := dReact
            dispEntryY := dEntry
            dispInvalY := dInval
        else
            [dInval, dEntry, dReact, dExt] = f_deconflict4(slp, en, t1p, t2p, minGap)
            dispInvalY := dInval
            dispEntryY := dEntry
            dispReactY := dReact
            dispExtY   := dExt

        label tagEntry = label.new(
             rightX, dispEntryY, "Entry " + str.tostring(math.round(en, 2)),
             style = label.style_label_left, color = badgeBg,
             textcolor = entryColorFinal, size = size.small, text_formatting = text.format_bold)
        label tagInvalid = label.new(
             rightX, dispInvalY, "Invalidation " + str.tostring(math.round(slp, 2)),
             style = label.style_label_left, color = badgeBg,
             textcolor = i_invalC, size = size.small, text_formatting = text.format_bold)
        label tagReact = label.new(
             rightX, dispReactY, "Reaction " + str.tostring(math.round(t1p, 2)),
             style = label.style_label_left, color = badgeBg,
             textcolor = i_reactC, size = size.small, text_formatting = text.format_bold)
        label tagExt = label.new(
             rightX, dispExtY, "Extension " + str.tostring(math.round(t2p, 2)),
             style = label.style_label_left, color = badgeBg,
             textcolor = i_extC, size = size.small, text_formatting = text.format_bold)

        line he = line.new(bar_index, en,  bar_index + 1, en,  color = entryColorFinal, style = line.style_solid, width = i_lineWidth)
        line h1 = line.new(bar_index, t1p, bar_index + 1, t1p, color = i_reactC,        style = line.style_solid, width = i_lineWidth)
        line h2 = line.new(bar_index, t2p, bar_index + 1, t2p, color = i_extC,          style = line.style_solid, width = i_lineWidth)
        line hs = line.new(bar_index, slp, bar_index + 1, slp, color = i_invalC,        style = line.style_solid, width = i_lineWidth)

        SignalTrade nt = SignalTrade.new(
             signalBar  = bar_index,
             dir        = dir,
             entry      = en,
             t1         = t1p,
             t2         = t2p,
             sl         = slp,
             status     = "Pending",
             sigReason  = sigReason,
             dispEntryY = dispEntryY,
             dispInvalY = dispInvalY,
             dispReactY = dispReactY,
             dispExtY   = dispExtY,
             tagEntry   = tagEntry,
             tagInvalid = tagInvalid,
             tagReact   = tagReact,
             tagExt     = tagExt,
             histEntry  = he,
             histT1     = h1,
             histT2     = h2,
             histSL     = hs)

        if trades.size() >= TRADE_CAP
            SignalTrade old = trades.shift()
            label.delete(old.sigReason)
            label.delete(old.tagEntry)
            label.delete(old.tagInvalid)
            label.delete(old.tagReact)
            label.delete(old.tagExt)
            line.delete(old.histEntry)
            line.delete(old.histT1)
            line.delete(old.histT2)
            line.delete(old.histSL)

        trades.push(nt)
        inTrade := true
        cdCount := 0

        if isL
            alertLong := true
        else
            alertShort := true

// ═══════════════════════════════════════════════════════════════════════════
// REFERENCE LEVEL PLOTS
// ═══════════════════════════════════════════════════════════════════════════
int  HTF_SEG_BARS = 30
bool inRightSeg   = bar_index >= last_bar_index - HTF_SEG_BARS

plot(inRightSeg and i_usePDHL ? pdH : na, "Prior Day High", color = color.new(i_htfC, 20), linewidth = 1, style = plot.style_stepline, display = display.pane)
plot(inRightSeg and i_usePDHL ? pdL : na, "Prior Day Low",  color = color.new(i_htfC, 20), linewidth = 1, style = plot.style_stepline, display = display.pane)
plot(inRightSeg and i_useWkHL ? wkH : na, "Weekly High",    color = color.new(#4a90e2, 20), linewidth = 1, style = plot.style_stepline, display = display.pane)
plot(inRightSeg and i_useWkHL ? wkL : na, "Weekly Low",     color = color.new(#4a90e2, 20), linewidth = 1, style = plot.style_stepline, display = display.pane)

plot(ibFormed ? ibH : na, "IB High", color = color.new(color.yellow, 55), linewidth = 1, style = plot.style_stepline, linestyle = plot.linestyle_dashed, display = display.pane)
plot(ibFormed ? ibL : na, "IB Low",  color = color.new(color.yellow, 55), linewidth = 1, style = plot.style_stepline, linestyle = plot.linestyle_dashed, display = display.pane)

plot(pocLvl, "Session Reference (POC when Footprint active)", color = color.new(color.purple, 45), linewidth = 1, style = plot.style_stepline, linestyle = plot.linestyle_dotted, display = display.pane)



var table fpWarn = table.new(position.bottom_left, 1, 1, bgcolor = color.new(color.black, 0))

if barstate.islast
    int tagX = last_bar_index + 2
    if i_usePDHL and (na(prevPDH) or pdH != prevPDH)
        label.delete(lblPDH)
        lblPDH := label.new(tagX, pdH, "PDH", style = label.style_label_left, color = themeBgSubtle, textcolor = i_htfC, size = size.tiny)
        prevPDH := pdH
    if i_usePDHL and (na(prevPDL) or pdL != prevPDL)
        label.delete(lblPDL)
        lblPDL := label.new(tagX, pdL, "PDL", style = label.style_label_left, color = themeBgSubtle, textcolor = i_htfC, size = size.tiny)
        prevPDL := pdL
    if i_useWkHL and (na(prevWkH) or wkH != prevWkH)
        label.delete(lblWkH)
        lblWkH := label.new(tagX, wkH, "WkH", style = label.style_label_left, color = themeBgSubtle, textcolor = color.new(#4a90e2, 0), size = size.tiny)
        prevWkH := wkH
    if i_useWkHL and (na(prevWkL) or wkL != prevWkL)
        label.delete(lblWkL)
        lblWkL := label.new(tagX, wkL, "WkL", style = label.style_label_left, color = themeBgSubtle, textcolor = color.new(#4a90e2, 0), size = size.tiny)
        prevWkL := wkL
    if ibFormed and (na(prevIBH) or ibH != prevIBH)
        label.delete(lblIBH)
        lblIBH := label.new(tagX, ibH, "IBH", style = label.style_label_left, color = themeBgSubtle, textcolor = color.new(color.yellow, 0), size = size.tiny)
        prevIBH := ibH
    if ibFormed and (na(prevIBL) or ibL != prevIBL)
        label.delete(lblIBL)
        lblIBL := label.new(tagX, ibL, "IBL", style = label.style_label_left, color = themeBgSubtle, textcolor = color.new(color.yellow, 0), size = size.tiny)
        prevIBL := ibL

    if i_useFP
        table.cell(fpWarn, 0, 0, "Footprint ON - replay results may differ. Disable for replay testing.", text_color = color.new(color.orange, 0), text_size = size.tiny)
    else
        table.cell(fpWarn, 0, 0, "", text_color = color.new(color.black, 100), text_size = size.tiny)

// ═══════════════════════════════════════════════════════════════════════════
// MAIN DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════
var table dash = table.new(
     f_tablePos(i_dashPos), 2, 9,
     bgcolor      = themeBgSubtle,
     border_color = color.new(color.gray, 40),
     border_width = 1,
     frame_color  = color.new(color.gray, 30),
     frame_width  = 1)

if barstate.islast
    color  tierCol = actTier == 3 ? color.new(i_extC, 55) : actTier == 2 ? color.new(i_bullC, 55) : color.new(i_reactC, 55)
    string tierTx  = actTier == 3 ? "Footprint (Tick)" : actTier == 2 ? "Intrabar (LTF Recon.)" : "Proxy (Single-Bar)"
    color ibCol = ibVerdict == "Trend Day" ? color.new(i_bullC, 55) :
         ibVerdict == "Balance Day" ? color.new(i_extC, 55) : color.new(color.gray, 55)
    color scCol = color.from_gradient(composite, 0, 100, color.new(color.gray, 55), color.new(i_extC, 15))

    string scenTxt = "None"
    color  scenCol = color.new(color.gray, 60)
    if inTrade and trades.size() > 0
        SignalTrade lt = trades.get(trades.size() - 1)
        if lt.status == "Pending"
            scenTxt := lt.dir == "Long" ? "Long - Active (awaiting resolution)" : "Short - Active (awaiting resolution)"
            scenCol := lt.dir == "Long" ? color.new(i_bullC, 60) : color.new(i_bearC, 60)

    table.clear(dash, 0, 0, 1, 8)

    table.cell(dash, 0, 0, "Footprint Delta Auction Map", text_color = themeFg, bgcolor = color.new(color.gray, 70), text_size = f_tableSize(i_dashSize), text_formatting = text.format_bold)
    table.cell(dash, 1, 0, "BullByte", text_color = themeFg, bgcolor = color.new(color.gray, 70), text_size = f_tableSize(i_dashSize), text_formatting = text.format_bold)

    table.cell(dash, 0, 1, "Data Engine", text_color = themeFg, text_size = f_tableSize(i_dashSize))
    table.cell(dash, 1, 1, tierTx, text_color = themeFg, bgcolor = tierCol, text_size = f_tableSize(i_dashSize))

    table.cell(dash, 0, 2, "Session Character", text_color = themeFg, text_size = f_tableSize(i_dashSize))
    table.cell(dash, 1, 2, ibVerdict, text_color = themeFg, bgcolor = ibCol, text_size = f_tableSize(i_dashSize))

    table.cell(dash, 0, 3, "Composite Score", text_color = themeFg, text_size = f_tableSize(i_dashSize))
    table.cell(dash, 1, 3, str.tostring(math.round(composite)) + " / 100", text_color = themeFg, bgcolor = scCol, text_size = f_tableSize(i_dashSize))

    table.cell(dash, 0, 4, "Score Requirement", text_color = themeFg, text_size = f_tableSize(i_dashSize))
    string adjTx = ibAdj != 0.0 ? " (adj " + str.tostring(ibAdj) + ")" : ""
    table.cell(dash, 1, 4, str.tostring(math.round(effThresh)) + adjTx, text_color = themeFg, text_size = f_tableSize(i_dashSize))

    table.cell(dash, 0, 5, "Qualification Criteria", text_color = themeFg, text_size = f_tableSize(i_dashSize))
    table.cell(dash, 1, 5,
         "Pressure " + (critDelta ? "OK" : "--") + "  Candle " + (critBody ? "OK" : "--") + "  Confluence " + (critConfluence ? "OK" : "--"),
         text_color = allCriteria ? color.new(color.teal, 20) : themeFg, text_size = f_tableSize(i_dashSize))

    table.cell(dash, 0, 6, "Active Scenario", text_color = themeFg, text_size = f_tableSize(i_dashSize))
    table.cell(dash, 1, 6, scenTxt, text_color = themeFg, bgcolor = scenCol, text_size = f_tableSize(i_dashSize))

    if cdCount > 0
        table.cell(dash, 0, 7, "Cooldown", text_color = themeFg, text_size = f_tableSize(i_dashSize))
        table.cell(dash, 1, 7, str.tostring(cdCount) + " bars remaining", text_color = color.new(color.orange, 20), text_size = f_tableSize(i_dashSize))

    table.cell(dash, 0, 8, "Reference Sizing (Inv : Ext)", text_color = themeFg, text_size = f_tableSize(i_dashSize))
    table.cell(dash, 1, 8, str.tostring(i_k3) + " : " + str.tostring(math.round(effK2, 2)) + " x Unit", text_color = themeFg, text_size = f_tableSize(i_dashSize))

// ═══════════════════════════════════════════════════════════════════════════
// DEBUG DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════
var table dbg = table.new(
     f_tablePos(i_dbgPos), 2, 7,
     bgcolor      = themeBgSubtle,
     border_color = color.new(color.gray, 40),
     border_width = 1)

if i_dbg and barstate.islast
    color fpC = color.from_gradient(fpScore,     0, 100, color.gray, color.new(color.blue, 20))
    color ldC = color.from_gradient(ladderScore, 0, 100, color.gray, color.new(color.blue, 20))
    color udC = uDelta >= 0.0 ? color.new(color.teal, 20) : color.new(color.maroon, 20)
    string tierDetail = actTier == 3 ? "Footprint (Tick)" : actTier == 2 ? "Intrabar (LTF Recon.)" : "Proxy (Single-Bar)"
    string tierSub    = actTier == 2 ? " - " + str.tostring(ltfN) + " sub-bars" : ""

    table.cell(dbg, 0, 0, "Score Breakdown", text_color = themeFg, bgcolor = color.new(color.gray, 70), text_size = f_tableSize(i_dbgSize), text_formatting = text.format_bold)
    table.cell(dbg, 1, 0, "Current Bar",     text_color = themeFg, bgcolor = color.new(color.gray, 70), text_size = f_tableSize(i_dbgSize), text_formatting = text.format_bold)

    table.cell(dbg, 0, 1, "Fingerprint Score (60% wt.)", text_color = themeFg, text_size = f_tableSize(i_dbgSize))
    table.cell(dbg, 1, 1, str.tostring(math.round(fpScore)), text_color = themeFg, bgcolor = fpC, text_size = f_tableSize(i_dbgSize))

    table.cell(dbg, 0, 2, "Ladder Score (40% wt.)", text_color = themeFg, text_size = f_tableSize(i_dbgSize))
    table.cell(dbg, 1, 2, str.tostring(math.round(ladderScore)) + " (" + str.tostring(ladderHits) + " levels)", text_color = themeFg, bgcolor = ldC, text_size = f_tableSize(i_dbgSize))

    table.cell(dbg, 0, 3, "Nearest Level", text_color = themeFg, text_size = f_tableSize(i_dbgSize))
    table.cell(dbg, 1, 3, ladderTop, text_color = themeFg, text_size = f_tableSize(i_dbgSize))

    string deltaLbl = actTier == 3 ? "Footprint Delta" :
         actTier == 2 ? "Auction Pressure (LTF Est.)" : "Auction Pressure (OHLCV Proxy)"
    table.cell(dbg, 0, 4, deltaLbl, text_color = themeFg, text_size = f_tableSize(i_dbgSize))
    table.cell(dbg, 1, 4, str.tostring(math.round(uDelta, 1)), text_color = themeFg, bgcolor = udC, text_size = f_tableSize(i_dbgSize))

    table.cell(dbg, 0, 5, "Extension Sizing Factor", text_color = themeFg, text_size = f_tableSize(i_dbgSize))
    table.cell(dbg, 1, 5, "Vol " + str.tostring(math.round(volScalar, 2)) + "x  /  IB " + str.tostring(ibScalar) + "x", text_color = themeFg, text_size = f_tableSize(i_dbgSize))

    table.cell(dbg, 0, 6, "Active Data Tier", text_color = themeFg, text_size = f_tableSize(i_dbgSize))
    table.cell(dbg, 1, 6, tierDetail + tierSub, text_color = themeFg, text_size = f_tableSize(i_dbgSize))

// ═══════════════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════════════
alertcondition(alertLong,      "FDAM - Long Scenario Marked",       "Footprint Delta Auction Map: long scenario marked.")
alertcondition(alertShort,     "FDAM - Short Scenario Marked",      "Footprint Delta Auction Map: short scenario marked.")
alertcondition(alertReaction,  "FDAM - Reaction Zone Reached",      "Footprint Delta Auction Map: Reaction Zone reached.")
alertcondition(alertExtension, "FDAM - Extension Zone Reached",     "Footprint Delta Auction Map: Extension Zone reached.")
alertcondition(alertInvalid,   "FDAM - Invalidation Level Reached", "Footprint Delta Auction Map: Invalidation reached.")

if alertLong
    alert("Footprint Delta Auction Map - Long scenario marked. " + lastReason, alert.freq_once_per_bar_close)
if alertShort
    alert("Footprint Delta Auction Map - Short scenario marked. " + lastReason, alert.freq_once_per_bar_close)
if alertReaction
    alert("Footprint Delta Auction Map - Reaction Zone reached.", alert.freq_once_per_bar_close)
if alertExtension
    alert("Footprint Delta Auction Map - Extension Zone reached. Scenario resolved.", alert.freq_once_per_bar_close)
if alertInvalid
    alert("Footprint Delta Auction Map - Invalidation level reached. Scenario resolved.", alert.freq_once_per_bar_close)
````

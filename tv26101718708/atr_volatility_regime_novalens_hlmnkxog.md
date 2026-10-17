# ATR Volatility Regime [NovaLens]

- url: https://www.tradingview.com/script/HLMnKXog-ATR-Volatility-Regime-NovaLens/
- type: indicator
- pine_id: PUB;3adbb60fb2054ccbb3489d3ed00e3366
- version: 1.0

## Description

Volatility regime tool built to separate two things ATR alone cannot tell you apart: where volatility currently sits in its own rolling history, and which direction the regime is rotating. Adds a velocity-gated release event on top, so the indicator flags fast coiled-spring releases on the confirmed bar - and refuses to fire on the slow leaks that only look like one.

Most volatility tools collapse one axis. A raw ATR plot tells you the bar range and nothing about whether that range is rare. A percentile-rank histogram tells you the rank but not whether vol is loading or unloading. ATR Volatility Regime separates the two by design:

[list]
[*][b]Tier[/b] tracks [i]where[/i] volatility sits in its own rolling history (Compression / Quiet / Normal / Elevated).
[*][b]Phase[/b] tracks [i]where[/i] volatility is rotating (Rising / Topping / Falling / Bottoming).
[/list]

A Compression reading is not a breakout signal. It is the market saying "vol is loaded." Whether it actually releases depends on the next move. When a sustained compression actually breaks above mid-rank within a 5-bar velocity window, the indicator prints a Release diamond and pulses the pane background. Slow leaks that drift through Quiet for more than 5 bars are canceled, not reported. That single gate is what separates a real coiled-spring release from a sideways drift.


════════════════════════════════════════════


◉ [b]HOW IT WORKS[/b]

[b]The vol input.[/b] Wilder ATR over the chosen length, expressed as a percentage of close so the read is comparable across price levels and instruments. Mathematically guarded to stay clean across historical data gaps and unusual price series.

[b]The percentile rank.[/b] The current ATR% is ranked against its own rolling lookback window (100 / 200 / 300 bars by Horizon). This is an [i]asset-calibrated percentile[/i] - "P75 on BTC" means "vol higher than 75% of the last 200 BTC readings," not a market-wide cutoff. The same indicator works across SPY, BTC, EURUSD, and XAU without retuning. The raw rank drives the state engine; an EMA-smoothed copy drives the visual line so the plot reads calm without numbing event detection. Warm-up is honest: until the lookback fills, the panel shows "Warming up" and refuses to assign a tier. NA never collapses to a fake Normal.

[b]The tier model.[/b] Four tiers cut on rawRank (P25, P50, P75) with asymmetric hysteresis: 1 confirmed bar to step up (so a vol breakout is not missed), 3 confirmed bars to step down (so a tier change only confirms when vol has actually died). The ribbon fill and oscillator line both color by tier. Extreme is a signal class, not a tier; it would flicker on and off at the P90 boundary if we colored the ribbon by it.

[b]The phase model.[/b] Four phases (Rising / Topping / Falling / Bottoming) read off the rawRank slope. Slow rotations need 2 bars of confirmation to flip; violent moves with |delta rank| > 15 bypass the confirm and flip immediately. Peak and trough detection is plateau-aware: a strict ([i]greater-than[/i] on both sides) check missed the patterns where ATR percentile pins at 100 for multiple bars, so the algorithm uses [i]greater-or-equal[/i] on the left side and [i]greater-than[/i] on the right.

[b]The events.[/b] Three signature events, each with its own gating:

[list]
[*][b]Compression Release[/b]: velocity-gated. The Compression tier must run at least 10 bars to load the spring; on exit, rawRank must reach the mid (>= 50) within a 5-bar window. Slow leaks that drift through Quiet for more than 5 bars are canceled. Re-entering Compression also cancels the pending episode.
[*][b]Extreme Touch[/b]: rawRank peaks at >= 90. Re-arm runs through a three-valve cascade (rank drop to <= 75, a higher pivot with a +2 rank headroom so a 98 peak after a 97 cannot re-fire, or 2x lookback time decay) so the same Extreme arc cannot duplicate-fire, but a genuinely higher pivot in the same arc still counts.
[*][b]Cooling[/b]: armed when an Extreme fires; fires on the first confirmed bar after where rawRank falls below 75 within a 10-bar window. Disarms on fire or when the window expires. The armed-latch architecture means fast drops out of an Extreme are tracked after the Extreme event arms Cooling, instead of relying on a single fragile cross check that would miss the drop if the threshold was already crossed on the Extreme bar itself.
[/list]

[b]The Playbook Lens.[/b] Pure interpretation layer. Engine, percentile, tier, phase, and objective events are identical across lenses. The Lens recolors three visual surfaces only: the panel Playbook row text and tone, the Playbook Heatmap Strip at y = -5, and an optional Tint Price Candles by Playbook Fit overlay. Switching the Lens dropdown answers a different question against the same volatility truth: "does this regime align with the workflow I am running?" - context, never a directive.


════════════════════════════════════════════


◈ [b]HOW TO READ IT[/b]

The pane shows the smoothed percentile rank line wrapped in a tier-colored ribbon with a Volatility Glow halo that breathes wider in the loaded zones (Compression and Extreme) and tightens in Normal. Threshold lines mark P25, P50, P75, and P90.

[list]
[*]Deep blue (Compression): rawRank in [0, 25). Loaded spring.
[*]Light blue (Quiet): rawRank in [25, 50). Below median, not stretched.
[*]Gray (Normal): rawRank in [50, 75). Typical bar ranges.
[*]Orange (Elevated): rawRank in [75, 100]. High vol relative to recent history.
[*]Red (Extreme): event color, not a tier. Drives Extreme Touch markers.
[*]Teal (Release): event color, not a tier. Drives Compression Release markers.
[/list]

[b]Markers, in order of conviction:[/b]

[list]
[*][b]Compression Release[/b] (diamond on the line, Release color, with a matching pane background pulse): a >= 10 bar compression run resolved into Normal+ within 5 bars. Non-directional by design - a volatility state change, not a price direction call.
[*][b]Extreme Touch[/b] (small circle anchored to the actual peak bar, Extreme color): rawRank just peaked at or above the 90th percentile of its rolling history. Reads as topping pressure of vol, not a directional reversal call.
[*][b]Cooling[/b] (panel-only event, no chart marker): the first confirmed bar after an Extreme where rawRank fell back below 75 within a 10-bar window. Surfaces in the Last Event row and the Cooling alert.
[/list]

The info panel synthesizes six rows: [b]Volatility[/b] (tier + P-Score), [b]Flow[/b] (phase), [b]Age[/b] (bars in tier + the per-tier duration percentile so a 200-bar Quiet stretch is compared against historical Quiet stretches, not Elevated), [b]Last Event / Context[/b] (state-based decay, no fixed timer), [b]ATR Range[/b] (current bar range as % of price, with absolute price-unit ATR in the row tooltip), and [b]Playbook[/b] (the Lens context read).

The Last Event row uses [b]state-based decay[/b], not an arbitrary 10-bar timer. A Compression Release stays visible while phase is Rising or tier is Normal+. An Extreme Touch stays visible while tier is Elevated. A Cooling read stays visible while tier is Normal or Elevated. When the event's regime context expires, the row returns to [b]Context[/b] and summarizes the current regime instead of resizing or disappearing.


════════════════════════════════════════════


✦ [b]HOW WE USE IT: THE COILED-SPRING ARC[/b]

This is the arc the indicator is built to catch - not the only path. Many compressions resolve sideways without a confirmed release, and the velocity gate is what filters those out.

A common pattern on a liquid index or crypto chart, Swing profile (default), Neutral lens: the line drops into Compression and parks there for 15-30 bars. The ribbon turns deep blue, the Glow widens, and the panel Age row may read something like "Mature · 22 bars" or "Extended · 22 bars" - meaning the current run has already lasted longer than most recent Compression stretches on this market. The spring is loaded.

The full arc reads in four panel updates:

[list]
[*][b]Release.[/b] rawRank reaches 50+ within the 5-bar velocity window after exiting Compression. A Release diamond prints on the line, the pane background pulses teal for one bar, and the Last Event row reads "Compression Release".
[*][b]Run.[/b] Within a few bars the tier transitions through Normal into Elevated, the phase row flips Rising, and the smoothed line climbs toward the upper distribution.
[*][b]Touch.[/b] If the move keeps loading, rawRank peaks at 92-98 and an Extreme Touch circle prints on the peak bar - the smoothed line is now in the upper edge of its own rolling distribution. The Last Event row updates to "Extreme Touch".
[*][b]Unwind.[/b] Within 10 bars rawRank falls below 75. Cooling fires and the Last Event row updates again.
[/list]

The Playbook Lens reframes the same arc without changing a number. Flip to Breakout: the Heatmap Strip lights teal during the release window (favorable) and dims toward red as the move stretches into Extreme (less favorable). Flip to Mean Reversion: the strip stays red through the release (vol is the wrong direction for fading) and only lights teal when Cooling confirms and tier drifts back through Normal toward Quiet. Flip to Risk Control: Compression marks calmer bar-range context, Elevated and Extreme mark the wider-bar context. Same volatility truth, different playbook fit. The engine is identical across lenses; only the interpretation layer changes.


════════════════════════════════════════════


✦ [b]OTHER APPLICATIONS[/b]

[list]
[*][b]Breakout context[/b]: Compression Release diamonds after a loaded quiet regime, optionally combined with the Heatmap Strip reading favorable under the Breakout lens
[*][b]Trend context[/b]: Rising Elevated or Rising Normal volatility as movement context for an external trend plan
[*][b]Mean-reversion context[/b]: quieter or cooling regimes that may be more suitable for contained-range workflows
[*][b]Volatility risk overlay[/b]: Elevated and Extreme states as wider-bar context when reviewing size, stops, or trade frequency
[*][b]Vol regime classifier[/b]: use the Volatility row + Flow row in the panel as a top-down filter for any external trade plan, independent of the Lens
[*][b]Alert-driven workflow[/b]: subscribe to Compression Release + Extreme Touch + Cooling and check the chart only when the volatility regime actually changes, not every bar
[/list]


════════════════════════════════════════════


⚙ [b]GETTING STARTED[/b]

ATR Volatility Regime ships with three pre-tuned Horizon profiles plus a Custom override. Pick a horizon and start reading the regime:

[list]
[*][b]Intraday[/b]: ATR 14, lookback 100, smoothing 3. Faster events, lighter hysteresis (1 up / 2 down). Use on 1m through 1H charts.
[*][b]Swing (default)[/b]: ATR 14, lookback 200, smoothing 5. Balanced. Start here on 1H through 1D charts.
[*][b]Long-Term Hold[/b]: ATR 20, lookback 300, smoothing 5. Slower, rarer events, heavier hysteresis (2 up / 3 down). Use on 1D and above.
[*][b]Custom[/b]: full manual control of ATR Period, Lookback Window, and Smoothing.
[/list]

[b]Core settings:[/b]

[list]
[*][b]Horizon[/b]: selects the tuning bundle above. Start with Swing.
[*][b]ATR Period (Custom)[/b]: Wilder ATR period for the volatility input, in BARS. 14 is the standard. Shorter = more reactive; longer = smoother. Applies only when Horizon = Custom.
[*][b]Lookback Window (Custom)[/b]: rolling lookback the ATR% is percentile-ranked against. Larger = smoother distribution, fewer extreme reads, slower compression releases. Smaller = sharper, more events.
[*][b]Smoothing (EMA) (Custom)[/b]: EMA bars applied to the percentile-rank for the visual DISPLAY layer (plot, ribbon, panel readouts). The RAW rank still drives tier, phase, and events - smoothing only calms the visual. Set to 1 to disable smoothing.
[/list]

[b]Playbook Lens:[/b]

[list]
[*][b]Neutral (default)[/b]: factual regime read, heatmap stays gray. Use this to learn the engine.
[*][b]Breakout[/b]: range-expansion context. Loaded Compression and Compression Release read favorable; already-stretched Elevated or Extreme states shift toward caution.
[*][b]Trend[/b]: directional-movement context. Rising Elevated and Rising Normal regimes read favorable; topping or cooling volatility shifts toward caution.
[*][b]Mean Reversion[/b]: contained-range context. Quiet, Cooling, and Normal/Falling regimes read favorable; Release, Elevated, and Extreme regimes shift toward caution.
[*][b]Risk Control[/b]: stretched-volatility context. Compression reads calm; Elevated and Extreme states warn that bar ranges are wide.
[/list]

The Lens NEVER changes the engine - same tier, same phase, same Compression Release, same Extreme Touch, same alerts. Only the panel Playbook row text, the Heatmap Strip color, and the optional candle tint move.

[b]Display:[/b]

[list]
[*][b]Show Compression Releases[/b] (hero): diamond on the line + pane background pulse on release. On by default.
[*][b]Show Extreme Touches[/b]: circle on the peak bar at rawRank >= 90. On by default.
[*][b]Show Price Chart Markers[/b]: mirrors Compression Release diamonds and Extreme bar tints onto the price chart. OFF by default to keep the price chart clean.
[*][b]Show Raw Rank Line[/b]: faint unsmoothed percentile rank line behind the smoothed display line. OFF by default. Toggle on to debug fast vol changes.
[*][b]Show Volatility Glow[/b]: halo that widens at the loaded extremes (Compression and Extreme) and tightens in Normal. On by default.
[*][b]Show Info Panel[/b]: 6-row state panel. On by default.
[*][b]Panel Position[/b]: Top Right (default), Top Left, Bottom Right, Bottom Left, Middle Right.
[*][b]Theme[/b]: Auto (detect chart background), Dark, or Light.
[*][b]Show Playbook Heatmap Strip[/b]: thick band at y = -5 that recolors with the Lens. On by default.
[*][b]Tint Price Candles by Playbook Fit[/b]: paints price-chart candles with the Release / Extreme palette per the active Lens. OFF by default; disabled automatically when Lens = Neutral.
[/list]

[b]Appearance / Palette (6 color pickers):[/b]

[list]
[*]Compression, Quiet, Normal, Elevated, Extreme, Release - each on its own line with a state-explainer tooltip. The Display Rank line, Raw Rank, Tier Ribbon fill, Volatility Glow, Heatmap Strip, panel tier text, candle tints, and event markers all reference these inputs so users can adapt the palette (color-blind, light-mode, brand themes) without forking the script.
[/list]


════════════════════════════════════════════


△ [b]LIMITATIONS[/b]

[list]
[*][b]Warm-up[/b]: the lookback window must fill before any tier is assigned. On Swing (200) that is 200 bars; on Long-Term Hold (300) that is 300. Until then, the panel shows "Warming up" and the state engine refuses to fake a Normal read.
[*][b]Visual smoothing lag[/b]: the visible line is intentionally calmer than the raw engine. ATR is a backward-looking Wilder-smoothed measure, and the display line is lightly EMA-smoothed on top, so fast volatility expansions can look slightly delayed in the visible plot. The rawRank engine is the sharper layer underneath and is what actually drives the tier, phase, events, and alerts. The smoothed line is the readable copy; do not read a slight visual delay as the event engine being slow.
[*][b]Percentile is relative, not absolute[/b]: a "Compression" read on a chronically quiet asset can still be wider than an "Elevated" read on a chronically loud asset. The indicator compares each asset against ITS OWN history, not across markets.
[*][b]Regime shifts shrink the window[/b]: a structural vol regime change (e.g. a quiet 2-year period followed by a sustained higher-vol regime) takes about one lookback window to fully recalibrate. The first few weeks after a regime shift can read noisier than the steady-state.
[*][b]Compression Release is non-directional[/b]: the diamond and the pane pulse tell you the spring released, not which way price went. Combine with directional context (trend, structure, or a separate momentum tool) for direction.
[*][b]Extreme Touch is a state read, not a reversal call[/b]: rawRank pinning above 90 means vol is rare for this market; it does not mean price is about to reverse. Cooling tells you the unwind has begun, not where the next leg goes.
[*][b]Playbook Lens is interpretation, not validation[/b]: the Heatmap Strip recolors regime context based on the active Lens. It is not a backtested edge - it is a quick visual answer to "does my workflow want this regime?"
[/list]


════════════════════════════════════════════

🔔 [b]ALERTS[/b]

Four alert conditions are built in so you can monitor without checking every bar manually:

[list]
[*][b]Compression Release[/b]: a sustained compression (>= 10 bars) confirmed above mid-rank within 5 bars. The hero event.
[*][b]Extreme Touch[/b]: rawRank peaked above P90. Fires on the bar after the actual peak (peak detection requires the next bar to confirm the turn-down).
[*][b]Cooling[/b]: the first confirmed bar after an Extreme where rawRank falls below 75 within 10 bars.
[*][b]Compression Entry[/b]: rawRank dropped below P25 (sustained tier transition into Compression).
[/list]

All four alerts fire on bar close (gated on barstate.isconfirmed). Each alert message is a pure JSON payload with ticker, price, timeframe, and timestamp fields for webhook routing.

Four alerts by design - concentrated on the signature events. Tier and phase transitions stay visible in the info panel for users who want them on the chart, but they do not fire alerts. Keeping the alert stream lean is what makes "subscribe and let the regime come to you" a useful workflow instead of a notification flood.


════════════════════════════════════════════


⌁ [b]NOTES[/b]

[list]
[*]Based on the classical ATR percentile-rank construction, with asymmetric hysteresis and a velocity-gated compression-release definition layered on top.
[*]Repaint: intrabar-only. Closed-bar alerts are confirmed; current-bar visuals may update until the bar closes. All alert conditions are gated on barstate.isconfirmed. Peak-confirmed events (Extreme Touch) print on the bar AFTER the actual peak, on a one-bar offset, so the marker aligns with the true peak bar.
[*]References: J. Welles Wilder Jr., [i]New Concepts in Technical Trading Systems[/i] (1978), Trend Research; percentile-rank concept widely used across volatility studies.
[*]Open-source under MPL 2.0. Free to use, fork, study.
[/list]

[b]NovaLens[/b]

## Source Code

````pine
// This Pine Script™ source code is subject to the terms of the Mozilla Public License 2.0
// © NovaLens

//@version=6
// ──────────────────────────────────────────────────────────────────────────────
// ATR Volatility Regime [NovaLens]
//
// Volatility-regime lens with playbook-aware interpretation.
//
// READS THE MARKET IN TWO ORTHOGONAL DIMENSIONS:
//   Tier  - where volatility SITS (Compression / Quiet / Normal / Elevated)
//   Phase - where volatility is ROTATING (Rising / Topping / Falling / Bottoming)
//
// SIGNATURE EVENTS:
//   Compression Release - sustained compression (>=10 bars) followed by a
//                         confirmed break above the mid (rawRank >= 50)
//                         within 5 bars of leaving compression. Slow leaks
//                         that drift through Quiet for >5 bars are CANCELED,
//                         not reported as releases. Hero visual: pane
//                         background pulse + a non-directional diamond on
//                         the line, both in the Release color.
//   Extreme Touch       - rawRank peaks at >= 90 with a three-valve re-arm
//                         cascade (rank drop, higher peak, time decay).
//   Cooling             - panel-only event (no chart marker by design).
//                         Armed when an Extreme fires; fires on the first
//                         bar after where rawRank < 75 within a 10-bar
//                         window. Surfaces in Last Event row + alert.
//
// PLAYBOOK LENS (interpretation layer only - never changes the core engine,
// tier, phase, or objective events):
//   Neutral / Breakout / Trend / Mean Reversion / Risk Control
// The Lens drives THREE visual layers:
//   • Panel Playbook row text + tone color
//   • Playbook Heatmap Strip (thick band at y=-5)
//   • Optional 'Tint Price Candles by Playbook Fit' barcolor
//
// LAST EVENT row uses STATE-BASED DECAY (not a fixed timer): the row stays
// visible while the event's regime context is alive (e.g. Compression Release
// remains visible while phase is Rising or tier is Normal+).
//
// REPAINT POLICY: intrabar-only. All alerts and event latches gated on
// barstate.isconfirmed. Warmup periods show "Warming up" - never fake
// a Normal state.
// ──────────────────────────────────────────────────────────────────────────────
indicator("ATR Volatility Regime [NovaLens]", shorttitle="ATR-VR [NovaLens]", overlay=false, precision=1, max_bars_back=700)

// ─── Brand constants ────────────────────────────────────────────────────────
string BRAND_NAME    = "NovaLens"
string BRAND_ENTITY  = "NovaLens Quantitative Research"
string PRODUCT_CODE  = "AP-01"
string PRODUCT_TIER  = "Free"

// ══════════════════════════════════════════════════════════════════════════════
//  INPUTS
// ══════════════════════════════════════════════════════════════════════════════
string PROF_INTRADAY = "Intraday"
string PROF_SWING    = "Swing"
string PROF_LONGTERM = "Long-Term Hold"
string PROF_CUSTOM   = "Custom"

string horizonTip = "Pre-tunes ATR length + lookback for the time horizon.\n\n• Intraday - ATR 14 / lookback 100. Faster, more events.\n• Swing (default) - ATR 14 / lookback 200. Balanced.\n• Long-Term Hold - ATR 20 / lookback 300. Slower, rarer events.\n• Custom - drive ATR/lookback/smoothing from inputs below.\n\nValues in BARS - chart timeframe sets wall-clock duration."

horizon = input.string(PROF_SWING, "Horizon", options=[PROF_INTRADAY, PROF_SWING, PROF_LONGTERM, PROF_CUSTOM], group="Parameters", tooltip=horizonTip)

// ─── Playbook Lens ──────────────────────────────────────────────────────────
// Two-layer architecture:
//   Horizon       = how the indicator MEASURES volatility.
//   Playbook Lens = how the trader INTERPRETS the same volatility state.
// Engine, percentile, tier, phase, and objective events are unchanged.
// The Lens changes the interpretation layer: panel text, heatmap strip,
// and optional candle tint. Default = Neutral (factual regime read).
string LENS_NEUTRAL  = "Neutral"
string LENS_BREAKOUT = "Breakout"
string LENS_TREND    = "Trend"
string LENS_MEANREV  = "Mean Reversion"
string LENS_RISK     = "Risk Control"

string lensTip = "Translates the volatility regime into a playbook-specific context read. Engine, percentile, tier, phase, and events are IDENTICAL across lenses - only the interpretation layer changes (panel text, heatmap strip, optional candle tint).\n\n• Neutral (default) - factual regime read, heatmap stays gray.\n• Breakout - whether vol is in a range-expansion regime.\n• Trend - whether vol is in a directional-movement regime.\n• Mean Reversion - whether vol is in a contained-range regime.\n• Risk Control - whether vol is stretched relative to recent history.\n\nContext language only - never a buy/sell directive."

playbookLens = input.string(LENS_NEUTRAL, "Playbook Lens", options=[LENS_NEUTRAL, LENS_BREAKOUT, LENS_TREND, LENS_MEANREV, LENS_RISK], group="Parameters", tooltip=lensTip)

// ─── Custom ─────────────────────────────────────────────────────────────────
customAtrLen   = input.int(14,  "ATR Period",       minval=1,  maxval=50,  group="Custom",
     tooltip="Wilder ATR period for the volatility input.\n\n14 is the standard. Shorter = more reactive vol read; longer = smoother vol read.\n\nApplies only when Horizon = Custom.")
customLookback = input.int(200, "Lookback Window",  minval=50, maxval=500, group="Custom",
     tooltip="Bars used to percentile-rank current ATR%. Larger = smoother distribution, fewer extreme reads, slower compression releases. Smaller = sharper, more events.\n\nApplies only when Horizon = Custom.")
customSmoothing= input.int(5,   "Smoothing (EMA)",  minval=1,  maxval=20,  group="Custom",
     tooltip="EMA bars applied to the percentile-rank line for the DISPLAY layer (plot + ribbon + panel readouts).\n\nThe RAW rank still drives tier, phase, and events - so smoothing keeps the visual calm without numbing event detection.\n\nSet to 1 to disable smoothing (display = raw).\n\nApplies only when Horizon = Custom.")

// ─── Display ────────────────────────────────────────────────────────────────
// Order reflects product hierarchy: hero event first, then secondary.
showCompBreak  = input.bool(true,  "Show Compression Releases", group="Display",
     tooltip="HERO event. Diamond on the line (Release color) + matching pane background pulse when a compression releases.\n\nFires when vol exits >=10 bar compression and reaches Normal+ (rawRank >= 50) within 5 bars. Slow leaks (>5 bars in Quiet after exit) are CANCELED.\n\nDiamond is non-directional - a release is a volatility state change, not a directional signal. Cooling events appear in the panel + alert, no chart marker by design.")
showExtreme    = input.bool(true,  "Show Extreme Touches",     group="Display",
     tooltip="Secondary event. Small transparent circle (Extreme color) on the peak bar (offset=-1) when rawRank peaks at >= 90. Re-arms on drop to <=75, or higher-rank peak, or time-decay.\n\nObservational: 'volatility just peaked at the upper edge of its distribution' - reads as topping PRESSURE of vol, not directional.")
showPriceMarkers = input.bool(false, "Show Price Chart Markers", group="Display",
     tooltip="Mirror the pane's events onto the price chart.\n\n• Compression Release -> diamond (Release color) below candle.\n• Extreme Touch -> bar tint (Extreme color) on the actual peak bar (offset=-1).\n\nOFF by default to keep the price chart clean. Toggle on for screenshot-grade context overlay.")
showRawLine    = input.bool(false, "Show Raw Rank Line",       group="Display",
     tooltip="Faint unsmoothed percentile rank line behind the smoothed display line.\n\nrawRank is what drives the state engine (tier, phase, events, alerts). The smoothed line is just the visual.\n\nOFF by default for a calmer look. Toggle ON to debug fast volatility changes - the raw line can move into a new tier before the smoothed line catches up.")
showGlow       = input.bool(true,  "Show Volatility Glow",     group="Display",
     tooltip="Subtle halo around the oscillator line that breathes with the regime. The halo widens at the extremes (Compression and Extreme) where vol is loaded with energy, and tightens in Normal/Quiet zones. Pure visual depth - does not change the engine, tier, or events.\n\nWhen the smoothed line reaches the Extreme zone, the halo balloons widest. The Compression tier is also wide - the loaded-spring metaphor. Normal is tight.")
showInfoPanel  = input.bool(true,  "Show Info Panel",  group="Display",
     tooltip="6-row state panel: Volatility (tier + P-Score), Flow, Age, Last Event/Context, ATR Range, Playbook.\n\nHover any row label for details. Table stays a fixed 6 rows so it never resizes on event fire/decay.")
panelPosition  = input.string("Top Right", "Panel Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group="Display",
     tooltip="Where the info panel anchors on the pane. Pick whatever doesn't overlap with the markers / heatmap strip in your typical chart layout.")
themeMode      = input.string("Auto", "Theme", options=["Auto", "Dark", "Light"], group="Display",
     tooltip="Auto = detect chart background luminance and pick light/dark colors automatically. Dark / Light = force the palette regardless of chart theme.\n\nApplies to info-panel backgrounds and label colors. Oscillator line, ribbon, and event markers are unaffected.")
showPlaybookHeatmap = input.bool(true, "Show Playbook Heatmap Strip", group="Playbook Lens",
     tooltip="Compatibility band at y = -5. Tells you whether the current volatility regime aligns with the selected Playbook context.\n\n• Teal (Release color) - vol aligns with the selected Playbook context. Examples: Compression Release under Breakout, vol Rising into Elevated under Trend, quiet ranges holding under Mean Reversion, Compression under Risk Control.\n• Gray - vol is neutral or ambiguous for the selected Playbook. The strip is not telling you anything.\n• Red (Extreme color) - vol is stretched or misaligned for the selected Playbook context. Examples: Extreme Touch under Breakout (already exhausted), Elevated under Mean Reversion (ranges too wide to fade), Elevated under Risk Control (wide bars, sizing risk).\n\nThe strip does not change the engine, tiers, or events - only the interpretation for the selected Playbook. Neutral lens forces gray so the strip cannot suggest a directional bias.")
showPlaybookTints = input.bool(false, "Tint Price Candles by Playbook Fit", group="Playbook Lens",
     tooltip="Optional price-chart overlay using the same Playbook fit colors as the Heatmap.\n\n• Teal tint - vol aligns with the selected Playbook context.\n• Red tint - vol is stretched or misaligned for the selected Playbook context.\n• No tint - vol is neutral or ambiguous.\n\nSame meaning as the Heatmap Strip - see that tooltip for per-Playbook examples.\n\nObjective Extreme Touch overrides the Playbook tint on its bar.\n\nOFF by default to keep candles clean. Disabled automatically when Lens = Neutral.")

// ─── Colors ─────────────────────────────────────────────────────────────────
// Six color inputs drive the entire palette: Display Rank line, Raw Rank,
// Tier Ribbon fill, Volatility Glow, Heatmap Strip, panel tier text, candle
// tints, and event markers all reference these so users can adapt the palette
// (color-blind, light-mode, brand themes) without forking the script.
colCompression = input.color(#2E5BBA, "Compression", group="Appearance / Palette",
     tooltip="Tier 0 - vol in [P0, P25). Volatility is unusually quiet relative to its own recent history; ATR is at or near the bottom of the lookback distribution. Often precedes range expansion - this is the 'coiled spring' / loaded-energy state.")
colQuiet       = input.color(#6BAFD9, "Quiet",       group="Appearance / Palette",
     tooltip="Tier 1 - vol in [P25, P50). Below the median of the lookback window. Calm conditions but not loaded. Range action; not yet stretched.")
colNormal      = input.color(#A0A0A0, "Normal",      group="Appearance / Palette",
     tooltip="Tier 2 - vol in [P50, P75). Above mid - typical average volatility for this market on this timeframe. Bar ranges are roughly what you'd expect.")
colElevated    = input.color(#E07A1F, "Elevated",    group="Appearance / Palette",
     tooltip="Tier 3 - vol >= P75. High volatility relative to recent history. Wider bars, more risk pressure. Often a directional-movement regime; often less forgiving for mean-reversion playbooks.")
colExtreme     = input.color(#FF504B, "Extreme",     group="Appearance / Palette",
     tooltip="Event color (not a tier). Drives the Extreme Touch circle on the line, the Extreme bar tint on the price chart, and the caution end of the Playbook Heatmap. Fires when rawRank peaks at >= P90 - volatility has just touched the upper edge of its rolling distribution.")
colRelease     = input.color(#00E6B4, "Release",     group="Appearance / Palette",
     tooltip="Event color (not a tier). Drives the Compression Release diamond + pane background pulse, and the favorable end of the Playbook Heatmap. Fires when vol exits a >=10 bar compression and reaches Normal+ within 5 bars - the 'coiled spring released' moment.")

// ══════════════════════════════════════════════════════════════════════════════
//  COLOR PALETTE - constants used for non-customizable UI chrome
// ══════════════════════════════════════════════════════════════════════════════
const color C_GRAY = #787B86  // UI chrome (panel labels, threshold lines, neutral fallback)

// ─── Theme resolver - Auto detects chart background luminance ───────────────
float bgR = color.r(chart.bg_color)
float bgG = color.g(chart.bg_color)
float bgB = color.b(chart.bg_color)
float bgLum = (bgR + bgG + bgB) / 3.0
bool autoIsLight = bgLum > 128.0
bool useLightTheme = themeMode == "Light" or (themeMode == "Auto" and autoIsLight)

// ─── Panel anchor resolver ──────────────────────────────────────────────────
panelAnchor = panelPosition == "Top Left"      ? position.top_left :
              panelPosition == "Bottom Right"  ? position.bottom_right :
              panelPosition == "Bottom Left"   ? position.bottom_left :
              panelPosition == "Middle Right"  ? position.middle_right :
                                                 position.top_right

// ══════════════════════════════════════════════════════════════════════════════
//  ENGINE - ATR%, raw percentile rank, smoothed display rank
// ══════════════════════════════════════════════════════════════════════════════
int atrLenEff    = horizon == PROF_INTRADAY ? 14 : horizon == PROF_SWING ? 14 : horizon == PROF_LONGTERM ? 20 : customAtrLen
int smoothingEff = horizon == PROF_INTRADAY ? 3  : horizon == PROF_SWING ? 5  : horizon == PROF_LONGTERM ? 5  : customSmoothing
int lookbackEff  = horizon == PROF_INTRADAY ? 100 : horizon == PROF_SWING ? 200 : horizon == PROF_LONGTERM ? 300 : customLookback

float atrValue = ta.atr(atrLenEff)

// Divisor guard: close <= 0 or NA → atrPct = na, all downstream skips.
float atrPct = (na(close) or close <= 0) ? na : atrValue / close * 100.0

// ══════════════════════════════════════════════════════════════════════════════
//  PERCENTILE RANK + SMOOTHING
// ══════════════════════════════════════════════════════════════════════════════
// HONEST WARMUP: rawRank is na until the lookback window has enough history.
// We do NOT collapse na -> 50 (which would silently fake a Normal state).
// All downstream gates check `warm` before assigning tier / phase / events.
float rawRank     = ta.percentrank(atrPct, lookbackEff)
float emaRank     = ta.ema(rawRank, smoothingEff)
float displayRank = (smoothingEff > 1 and not na(rawRank)) ? emaRank : rawRank

bool warm = not na(rawRank) and bar_index >= lookbackEff

// ══════════════════════════════════════════════════════════════════════════════
//  TIER MODEL - 4 tiers with asymmetric hysteresis (1 up / 3 down)
// ══════════════════════════════════════════════════════════════════════════════
// Cuts on rawRank (sharp math underneath). Tier transitions use asymmetric
// hysteresis: 1 confirmed bar to step UP (don't miss vol breakouts), 3
// confirmed bars to step DOWN (only confirm when vol has actually died).
//
// "Extreme" is a SIGNAL class (§ Extreme Touch), NOT a tier - it's too rare
// to color the ribbon and would flicker on/off at the boundary.
int rawTier = na(rawRank) ? -1 : rawRank < 25.0 ? 0 : rawRank < 50.0 ? 1 : rawRank < 75.0 ? 2 : 3

var int tier = -1
var int candidateTier = -1
var int candidateBars = 0

if barstate.isconfirmed and warm
    if tier < 0
        tier := rawTier
        candidateTier := rawTier
        candidateBars := 0
    else if rawTier == tier
        candidateTier := tier
        candidateBars := 0
    else if rawTier != candidateTier
        candidateTier := rawTier
        candidateBars := 1
    else
        candidateBars += 1

    int hystUp   = horizon == PROF_INTRADAY ? 1 : horizon == PROF_LONGTERM ? 2 : 1
    int hystDown = horizon == PROF_INTRADAY ? 2 : horizon == PROF_LONGTERM ? 3 : 3
    int needed   = candidateTier > tier ? hystUp : hystDown
    if candidateBars >= needed
        tier := candidateTier
        candidateBars := 0

string tierStr = not warm ? "Warming up" : tier == 3 ? "Elevated" : tier == 2 ? "Normal" : tier == 1 ? "Quiet" : tier == 0 ? "Compression" : "-"

// VISUAL TIER drives line / ribbon colors only, computed straight from
// displayRank with no hysteresis so the color always matches the line's
// visible y-axis zone. State / panel / heatmap / alerts use `tier` (rawRank
// + hysteresis).
int displayTier = na(displayRank) ? -1 : displayRank < 25.0 ? 0 : displayRank < 50.0 ? 1 : displayRank < 75.0 ? 2 : 3

// Track bars-in-tier for Compression Release gate + Lens row + Duration pctile
var int barsInTier = 0
if barstate.isconfirmed and warm
    if tier != nz(tier[1], tier)
        barsInTier := 1
    else
        barsInTier += 1

// Per-tier duration history (50-cap rolling) for the Duration row's
// "Xth pctile" callout. Per-tier (not pooled) so a 200-bar Quiet stretch is
// compared against historical Quiet stretches, not Elevated.
var array<int> tier0Hist = array.new<int>(0)
var array<int> tier1Hist = array.new<int>(0)
var array<int> tier2Hist = array.new<int>(0)
var array<int> tier3Hist = array.new<int>(0)
int TIER_HIST_CAP = 50
int DUR_PCTILE_FLOOR = 10

if barstate.isconfirmed and warm and tier != nz(tier[1], tier)
    int oldTier = nz(tier[1], -1)
    int doneDur = nz(barsInTier[1], 0)
    if oldTier == 0 and doneDur > 0
        array.push(tier0Hist, doneDur)
        if array.size(tier0Hist) > TIER_HIST_CAP
            array.shift(tier0Hist)
    else if oldTier == 1 and doneDur > 0
        array.push(tier1Hist, doneDur)
        if array.size(tier1Hist) > TIER_HIST_CAP
            array.shift(tier1Hist)
    else if oldTier == 2 and doneDur > 0
        array.push(tier2Hist, doneDur)
        if array.size(tier2Hist) > TIER_HIST_CAP
            array.shift(tier2Hist)
    else if oldTier == 3 and doneDur > 0
        array.push(tier3Hist, doneDur)
        if array.size(tier3Hist) > TIER_HIST_CAP
            array.shift(tier3Hist)

int tierDurPctile = na
int tierHistN     = tier == 0 ? array.size(tier0Hist) : tier == 1 ? array.size(tier1Hist) : tier == 2 ? array.size(tier2Hist) : tier == 3 ? array.size(tier3Hist) : 0
if tierHistN >= DUR_PCTILE_FLOOR and tier >= 0
    int below = 0
    if tier == 0
        for i = 0 to tierHistN - 1
            if array.get(tier0Hist, i) <= barsInTier
                below += 1
    else if tier == 1
        for i = 0 to tierHistN - 1
            if array.get(tier1Hist, i) <= barsInTier
                below += 1
    else if tier == 2
        for i = 0 to tierHistN - 1
            if array.get(tier2Hist, i) <= barsInTier
                below += 1
    else
        for i = 0 to tierHistN - 1
            if array.get(tier3Hist, i) <= barsInTier
                below += 1
    tierDurPctile := int(math.round(100.0 * below / tierHistN))

// ══════════════════════════════════════════════════════════════════════════════
//  PHASE MODEL - Rising / Topping / Falling / Bottoming
//  ASYMMETRIC CONFIRMATION: 2-bar confirm for slope changes, 1-bar bypass on
//  violent moves (|Δrank| > 15). Sharp math for sharp moves; smooth math for
//  slow moves. Solves the lag-vs-noise paradox.
// ══════════════════════════════════════════════════════════════════════════════
const int   PHASE_RISING    = 0
const int   PHASE_TOPPING   = 1
const int   PHASE_FALLING   = 2
const int   PHASE_BOTTOMING = 3
const int   PHASE_CONFIRM   = 2
const float PHASE_VIOLENT   = 15.0

float slope     = warm ? rawRank - nz(rawRank[1]) : 0.0
float absSlope  = math.abs(slope)

// Plateau-aware peak/trough: `>=` on the left allows a continuing plateau,
// `>` on the right requires an actual drop. ATR percentile can pin at 100
// for multiple bars (95 -> 100 -> 100 -> 92); on the flat plateau itself no
// peak fires, the peak resolves on the first drop bar.
bool peakBar   = warm and not na(rawRank[2]) and rawRank[1] >= rawRank[2] and rawRank[1] > rawRank and rawRank[1] >= 50.0
bool troughBar = warm and not na(rawRank[2]) and rawRank[1] <= rawRank[2] and rawRank[1] < rawRank and rawRank[1] <= 50.0
bool violent   = absSlope > PHASE_VIOLENT

var int phase            = -1
var int phaseCandidate   = -1
var int phaseConfirmBars = 0

if barstate.isconfirmed and warm and bar_index >= 2
    if peakBar
        phase            := PHASE_TOPPING
        phaseCandidate   := PHASE_FALLING
        phaseConfirmBars := 0
    else if troughBar
        phase            := PHASE_BOTTOMING
        phaseCandidate   := PHASE_RISING
        phaseConfirmBars := 0
    else
        int desired = slope > 0 ? PHASE_RISING : slope < 0 ? PHASE_FALLING : phase
        if violent and desired != phase and desired >= 0
            phase            := desired
            phaseCandidate   := -1
            phaseConfirmBars := 0
        else if desired != phase and desired >= 0
            if desired == phaseCandidate
                phaseConfirmBars += 1
                if phaseConfirmBars >= PHASE_CONFIRM
                    phase            := desired
                    phaseConfirmBars := 0
            else
                phaseCandidate   := desired
                phaseConfirmBars := 1
        else
            phaseCandidate   := -1
            phaseConfirmBars := 0

string phaseStr = phase == PHASE_RISING ? "Rising" : phase == PHASE_TOPPING ? "Topping" : phase == PHASE_FALLING ? "Falling" : phase == PHASE_BOTTOMING ? "Bottoming" : "-"

var int phaseStartBar = 0
if barstate.isconfirmed and bar_index > 0 and phase != nz(phase[1], phase) and phase >= 0
    phaseStartBar := bar_index
int phaseDuration = phase < 0 ? 0 : (bar_index - phaseStartBar + 1)

// ══════════════════════════════════════════════════════════════════════════════
//  CYCLE BOOKKEEPING - trough -> trough on rawRank for 'X of Y typical' display
// ══════════════════════════════════════════════════════════════════════════════
var int        lastCycleStart = na
var float      cycleAvgLen    = na
var array<int> cycleHistory   = array.new<int>(0)

int minCycleLen = math.max(8, int(math.floor(lookbackEff / 20.0)))

if troughBar and barstate.isconfirmed
    if na(lastCycleStart)
        lastCycleStart := bar_index
    else
        int thisLen = bar_index - lastCycleStart
        if thisLen >= minCycleLen
            array.push(cycleHistory, thisLen)
            if array.size(cycleHistory) > 5
                array.shift(cycleHistory)
            cycleAvgLen := array.avg(cycleHistory)
            lastCycleStart := bar_index

bool  halfReady   = array.size(cycleHistory) >= 3
float halfTypical = halfReady ? cycleAvgLen / 2.0 : na

// ══════════════════════════════════════════════════════════════════════════════
//  EXTREME TOUCH - peak at rawRank >= 90 with three-valve re-arm cascade
// ══════════════════════════════════════════════════════════════════════════════
// Re-arm cascade:
//   1. RANK         primary trigger; rawRank dropped below 75. Re-arm.
//   2. HIGHER PIVOT a new peakBar at rawRank materially above the last fire
//                   is itself a fire-worthy event (2pt headroom).
//   3. TIME DECAY   force re-arm after 2x lookbackEff bars without a fire.
var bool  extremeArmed         = true
var float lastExtremeFireRank  = na
var int   lastExtremeBar       = na
var int   barsSinceExtremeFire = 0

// peakBar fires on the bar AFTER the actual peak, so the >= 90 check reads
// rawRank[1] (the peak's actual value), not the current bar's lower value.
float peakValue = rawRank[1]

bool extremeReArmRank   = warm and rawRank <= 75.0
// Higher-pivot re-arm uses a 2-point headroom. Larger gaps would be unreachable
// at the P98+ tail (rawRank caps at 100).
bool extremeReArmHigher = warm and peakBar and not na(lastExtremeFireRank) and peakValue > lastExtremeFireRank + 2.0
bool extremeReArmTime   = not extremeArmed and barsSinceExtremeFire >= lookbackEff * 2

// Same-bar vs next-episode re-arm split: fire-worthy re-arms (higher pivot,
// time decay) can fire on the same bar; rank-drop re-arm only counts for
// the next episode so it can't duplicate-fire from the same arc.
bool canFireExtreme = extremeArmed or extremeReArmHigher or extremeReArmTime
bool extremeFire = barstate.isconfirmed and warm and peakBar and peakValue >= 90.0 and canFireExtreme

if extremeFire
    extremeArmed         := false
    lastExtremeFireRank  := peakValue
    lastExtremeBar       := bar_index - 1  // the actual peak bar, not the confirmation bar
    barsSinceExtremeFire := 0
else if barstate.isconfirmed
    if extremeReArmRank or extremeReArmTime
        extremeArmed := true
    barsSinceExtremeFire += 1

// ══════════════════════════════════════════════════════════════════════════════
//  COMPRESSION RELEASE - velocity-gated (no slow-leak false positives)
// ══════════════════════════════════════════════════════════════════════════════
// Episode logic:
//   1. Enter Compression (tier 0): barsInTier counts the compression run.
//   2. Exit Compression with run length >= 10 bars: arm a 5-bar velocity window.
//   3. Within window, rawRank crosses >= 50: FIRE Compression Release.
//   4. Window expires without crossing >= 50: CANCEL the episode (slow leak).
//   5. Re-entering Compression also cancels the pending episode.
//
// This rejects the "drift through Quiet for 20 bars then nudge into Normal"
// false positive that pure tier-jump or pure crossover logic would fire.
const int COMP_VELOCITY_WINDOW = 5
const int COMP_DURATION_FLOOR  = 10

var int  compExitBar       = na
var bool compEpisodeArmed  = false

bool justExitedComp  = barstate.isconfirmed and warm and tier != 0 and nz(tier[1], -1) == 0

if justExitedComp and nz(barsInTier[1], 0) >= COMP_DURATION_FLOOR
    compEpisodeArmed := true
    compExitBar      := bar_index
else if justExitedComp
    compEpisodeArmed := false  // exit but didn't load enough

bool compReleaseFire = false
if compEpisodeArmed and barstate.isconfirmed and warm
    int barsSinceExit = bar_index - compExitBar
    if rawRank >= 50.0
        compReleaseFire  := true
        compEpisodeArmed := false
    else if barsSinceExit >= COMP_VELOCITY_WINDOW
        compEpisodeArmed := false  // slow leak - cancel
    else if tier == 0
        compEpisodeArmed := false  // re-entered Compression - cancel

var int lastReleaseBar = na
if compReleaseFire
    lastReleaseBar := bar_index

// ══════════════════════════════════════════════════════════════════════════════
//  COOLING - rawRank crosses below 75 within 10 bars of an Extreme Touch
// ══════════════════════════════════════════════════════════════════════════════
// Armed-latch pattern: arm Cooling when an Extreme fires; fire Cooling on
// the first confirmed bar after where rawRank < 75 (and not the same bar as
// Extreme). Disarm on fire or when the 10-bar window expires.
var bool coolingArmed = false
if extremeFire
    coolingArmed := true

bool coolingFire = barstate.isconfirmed and warm and coolingArmed and rawRank < 75.0 and not extremeFire and not na(lastExtremeBar) and (bar_index - lastExtremeBar) <= 10
if coolingFire
    coolingArmed := false
else if barstate.isconfirmed and not na(lastExtremeBar) and (bar_index - lastExtremeBar) > 10
    coolingArmed := false  // window expired - disarm

var int lastCoolingBar = na
if coolingFire
    lastCoolingBar := bar_index

// ══════════════════════════════════════════════════════════════════════════════
//  LAST EVENT row - STATE-BASED DECAY (no fixed timer)
// ══════════════════════════════════════════════════════════════════════════════
// Each event type has a regime-context lifetime:
//   Compression Release: alive while phase == Rising OR tier >= Normal
//   Extreme Touch:       alive while tier == Elevated
//   Cooling:             alive while tier >= Normal (still in elevated arc)
//
// When the latest event's lifetime expires, the row hides until a new event
// fires. No 10-bar arbitrary timer.
const int EVT_NONE         = 0
const int EVT_COMP_RELEASE = 1
const int EVT_EXTREME      = 2
const int EVT_COOLING      = 3

var int lastEventType = EVT_NONE
var int lastEventBar  = na

if compReleaseFire
    lastEventType := EVT_COMP_RELEASE
    lastEventBar  := bar_index
if extremeFire
    lastEventType := EVT_EXTREME
    lastEventBar  := bar_index - 1  // align with Touch circle + bar tint (peak bar, not confirmation bar)
if coolingFire
    lastEventType := EVT_COOLING
    lastEventBar  := bar_index

bool eventStillAlive = false
if lastEventType == EVT_COMP_RELEASE
    eventStillAlive := phase == PHASE_RISING or tier >= 2
else if lastEventType == EVT_EXTREME
    eventStillAlive := tier == 3
else if lastEventType == EVT_COOLING
    eventStillAlive := tier >= 2

// ══════════════════════════════════════════════════════════════════════════════
//  PLAYBOOK LENS - dispatched at module scope so lensTone drives the heatmap
//  strip + optional candle tints, not just the panel row.
// ══════════════════════════════════════════════════════════════════════════════
// Read state directly: tier/phase/barsInTier are only mutated on
// `barstate.isconfirmed`, so they hold the last-confirmed value during a
// live tick.
int  readTier      = tier
int  readPhase     = phase
int  readBarsTier  = barsInTier
bool recentRelease = not na(lastReleaseBar) and (bar_index - lastReleaseBar) <= 3
bool recentCooling = not na(lastCoolingBar) and (bar_index - lastCoolingBar) <= 3
bool recentExtreme = not na(lastExtremeBar) and (bar_index - lastExtremeBar) <= 3

string lensVal  = "-"
int    lensTone = 0  // -2 risk, -1 caution, 0 neutral, 1 favorable, 2 strong-favorable

if not warm
    lensVal := "Warming up"
    lensTone := 0

else if playbookLens == LENS_NEUTRAL
    lensVal := recentRelease ? "Compression releasing" : recentExtreme ? "Vol at extreme" : readTier == 3 and readPhase == PHASE_TOPPING ? "Vol cresting" : readTier == 3 and readPhase == PHASE_RISING ? "Vol still expanding" : recentCooling ? "Vol cooling after extreme" : readTier == 0 and readBarsTier >= 10 ? "Loaded compression" : readTier == 0 ? "Quiet compression" : readTier == 1 and readPhase == PHASE_FALLING ? "Cooling toward compression" : readTier == 2 and readPhase == PHASE_RISING ? "Drifting up" : readTier == 2 and readPhase == PHASE_FALLING ? "Drifting down" : "Mid range"
    lensTone := recentRelease ? 2 : recentExtreme ? -2 : readTier == 3 and readPhase == PHASE_TOPPING ? -1 : readTier == 3 ? -1 : recentCooling ? 1 : readTier == 0 and readBarsTier >= 10 ? 1 : 0

else if playbookLens == LENS_BREAKOUT
    lensVal := recentRelease ? "Breakout context active" : readTier == 0 and readBarsTier >= 10 ? "Breakout context loading" : readTier == 0 ? "Breakout context: waiting" : recentExtreme ? "Breakout context extended" : readTier == 3 and readPhase == PHASE_TOPPING ? "Breakout context fading" : readTier == 3 ? "Breakout context already extended" : readTier == 2 and readPhase == PHASE_RISING ? "Breakout context improving" : readTier == 2 ? "Breakout context neutral" : readTier == 1 and readPhase == PHASE_RISING ? "Breakout context building" : readTier == 1 ? "Breakout context muted" : "Breakout context neutral"
    lensTone := recentRelease ? 2 : readTier == 0 and readBarsTier >= 10 ? 1 : recentExtreme ? -2 : readTier == 3 and readPhase == PHASE_TOPPING ? -1 : readTier == 3 ? -1 : readTier == 2 and readPhase == PHASE_RISING ? 2 : readTier == 1 and readPhase == PHASE_RISING ? 1 : 0

else if playbookLens == LENS_TREND
    lensVal := readTier == 3 and readPhase == PHASE_RISING ? "Trend context active" : readTier == 3 and readPhase == PHASE_TOPPING ? "Trend context cresting" : readTier == 3 and readPhase == PHASE_FALLING ? "Trend context cooling" : recentCooling ? "Trend context fading" : recentRelease ? "Trend context emerging" : readTier == 2 and readPhase == PHASE_RISING ? "Trend context building" : readTier == 2 ? "Trend context neutral" : readTier == 1 ? "Trend context quiet" : readTier == 0 ? "Trend context dormant" : "Trend context neutral"
    lensTone := readTier == 3 and readPhase == PHASE_RISING ? 2 : readTier == 3 and readPhase == PHASE_TOPPING ? -1 : readTier == 3 and readPhase == PHASE_FALLING ? -1 : recentCooling ? -1 : recentRelease ? 1 : readTier == 2 and readPhase == PHASE_RISING ? 1 : readTier == 0 ? -1 : 0

else if playbookLens == LENS_MEANREV
    lensVal := recentExtreme ? "Mean-rev context unstable" : readTier == 3 ? "Mean-rev context: ranges wide" : recentRelease ? "Mean-rev context: ranges expanding" : recentCooling ? "Mean-rev context improving" : readTier == 2 and readPhase == PHASE_FALLING ? "Mean-rev context recovering" : readTier == 2 ? "Mean-rev context neutral" : readTier == 1 ? "Mean-rev context favorable" : readTier == 0 ? "Mean-rev context: tight ranges" : "Mean-rev context neutral"
    lensTone := recentExtreme ? -2 : readTier == 3 ? -1 : recentRelease ? -1 : recentCooling ? 2 : readTier == 2 and readPhase == PHASE_FALLING ? 1 : readTier == 1 ? 2 : 0

else if playbookLens == LENS_RISK
    lensVal := recentExtreme ? "Risk pressure elevated" : readTier == 3 and readPhase == PHASE_FALLING ? "Risk pressure normalizing" : readTier == 3 ? "Risk pressure high" : recentCooling ? "Risk pressure normalizing" : readTier == 2 and readPhase == PHASE_RISING ? "Risk pressure rising" : readTier == 2 ? "Risk pressure typical" : readTier == 1 ? "Risk pressure muted" : readTier == 0 ? "Risk pressure low" : "Risk pressure typical"
    lensTone := recentExtreme ? -2 : readTier == 3 and readPhase == PHASE_FALLING ? 1 : readTier == 3 ? -1 : recentCooling ? 1 : readTier == 2 and readPhase == PHASE_RISING ? -1 : readTier == 0 ? 2 : 0

// ══════════════════════════════════════════════════════════════════════════════
//  VISUALS - ribbon + 4 fixed hlines + signal markers + release pulse
// ══════════════════════════════════════════════════════════════════════════════
// Line / ribbon colors use displayTier so the color always matches the
// smoothed line's y-axis zone. Phase information is already carried by the
// panel's Flow row + Heatmap Strip; the ribbon stays static so it does not
// double-encode direction.
int ribbonTransp = 75

// Volatility glow halo - subtle breathing effect around the oscillator line.
// Width modulates with the regime: widest in Compression and Extreme zones
// (loaded energy), tightest in Normal. Pure visual depth.
// Glow color derives from the same Appearance / Palette color as the
// display line - the halo always tracks the visible line's tier color.
color glowLineCol = displayTier == 3 ? colElevated : displayTier == 2 ? colNormal : displayTier == 1 ? colQuiet : displayTier == 0 ? colCompression : C_GRAY
// Width driven by displayRank (smoothed) so the halo balloons in lockstep
// with the visible line.
float glowWidth = na(displayRank) ? 1.0 : displayRank >= 90.0 ? 6.0 : displayTier == 3 ? 4.0 : displayTier == 0 ? 5.0 : displayTier == 1 ? 2.0 : 1.0
float glowUpper = na(displayRank) ? na : math.min(displayRank + glowWidth, 100.0)
float glowLower = na(displayRank) ? na : math.max(displayRank - glowWidth, 0.0)
// editable=false so these internal anchors don't appear in the Style tab.
p_glowTop = plot(showGlow ? glowUpper : na, "Glow Upper", color=color.new(glowLineCol, 95), linewidth=1, display=display.none, editable=false)
p_glowBot = plot(showGlow ? glowLower : na, "Glow Lower", color=color.new(glowLineCol, 95), linewidth=1, display=display.none, editable=false)
fill(p_glowTop, p_glowBot, color=showGlow ? color.new(glowLineCol, 88) : na, title="Volatility Glow")

// Display Rank line. Color sourced from the Inputs -> Colors palette.
p_display = plot(displayRank, "Display Rank (smoothed)", color = displayTier == 3 ? colElevated : displayTier == 2 ? colNormal : displayTier == 1 ? colQuiet : displayTier == 0 ? colCompression : C_GRAY, linewidth=2)

// Hidden raw anchor for the Tier Ribbon fill - rendered invisibly so the
// fill always works regardless of showRawLine.
p_rawFill   = plot(rawRank, "Raw Rank Anchor", color=color.new(C_GRAY, 100), display=display.none, editable=false)
// Optional visible raw line. Same palette as the Display line, with 50
// transparency for a softer secondary visual layer.
p_rawVisible = plot(showRawLine ? rawRank : na, "Raw Rank", color = displayTier == 3 ? color.new(colElevated, 50) : displayTier == 2 ? color.new(colNormal, 50) : displayTier == 1 ? color.new(colQuiet, 50) : displayTier == 0 ? color.new(colCompression, 50) : color.new(C_GRAY, 80), linewidth=1)

// Tier Ribbon fill - keeps color.new() for transparency (the soft fade
// between display and raw lines). Trades the Style picker for the fade.
fill(p_display, p_rawFill, color = displayTier == 3 ? color.new(colElevated, ribbonTransp) : displayTier == 2 ? color.new(colNormal, ribbonTransp) : displayTier == 1 ? color.new(colQuiet, ribbonTransp) : displayTier == 0 ? color.new(colCompression, ribbonTransp) : color.new(C_GRAY, 90), title="Tier Ribbon")

// Threshold lines at the tier cuts. The 90-line is slightly less transparent
// since it's the Extreme threshold.
hline(25, "Compression cut (25)", color=color.new(C_GRAY, 60), linestyle=hline.style_dotted)
hline(50, "Mid (50)",              color=color.new(C_GRAY, 60), linestyle=hline.style_dotted)
hline(75, "Elevated cut (75)",     color=color.new(C_GRAY, 60), linestyle=hline.style_dotted)
hline(90, "Extreme threshold (90)",color=color.new(C_GRAY, 40), linestyle=hline.style_dotted)

// EXTREME TOUCH marker plots at peakValue (rawRank[1], the actual extreme),
// not at the smoothed line, so the circle always lands in the P90+ zone
// where the event truly occurred.
plotshape(showExtreme and extremeFire ? peakValue : na, title="Extreme Touch (Pane)", style=shape.circle, location=location.absolute, color=color.new(colExtreme, 30), size=size.tiny, offset=-1)

// COMPRESSION RELEASE - non-directional diamond ON the line. Plotted at
// displayRank (not displayRank-markerGap below the line) - the diamond is
// non-directional so it doesn't need to float above/below to avoid implying
// direction. Sitting on the line keeps the visual tight.
plotshape(showCompBreak and compReleaseFire ? displayRank : na, title="Compression Release (Pane)", style=shape.diamond, location=location.absolute, color=colRelease, size=size.small)

// (Cooling has no chart marker by design - the line visibly drops back from
// the extreme zone, plotting another shape on top would be redundant. Logic
// still fires for the panel "Last Event | Cooling Xb ago" + alert.)

// COMPRESSION RELEASE PULSE - signature pane background flash (Release
// color) on the fire bar. Marketing visual: makes the 'coiled spring just
// released' moment unmistakable on screenshots.
bgcolor(showCompBreak and compReleaseFire ? color.new(colRelease, 88) : na, title="Compression Release Pulse")

// ══════════════════════════════════════════════════════════════════════════════
//  PLAYBOOK HEATMAP STRIP - solid context ribbon at y = -5.
//  Core volatility line stays identical across lenses; this strip recolors
//  with the chosen Lens so the trader can see, at a glance, whether the
//  current volatility regime aligns with the selected Playbook context.
//
//  NEUTRAL LENS = strip stays gray. lensTone is forced to 0 when no playbook
//  is selected so the strip cannot suggest a directional bias.
// ══════════════════════════════════════════════════════════════════════════════
// Effective tone: Neutral lens forces gray strip + gray candle tint. lensTone
// stays as the engine value for the panel Lens row text color logic.
int effectiveLensTone = playbookLens == LENS_NEUTRAL ? 0 : lensTone

color heatmapCol = color.new(C_GRAY, 75)
if not warm
    heatmapCol := color.new(C_GRAY, 90)
else if effectiveLensTone == 2
    heatmapCol := color.new(colRelease, 20)
else if effectiveLensTone == 1
    heatmapCol := color.new(colRelease, 55)
else if effectiveLensTone == -1
    heatmapCol := color.new(colExtreme, 55)
else if effectiveLensTone == -2
    heatmapCol := color.new(colExtreme, 20)

// plot.style_line + linewidth 6 (not style_circles) so the strip stays a
// continuous band when zoomed in - circles pull apart and look dotted.
plot(showPlaybookHeatmap ? -5.0 : na, "Playbook Heatmap", style=plot.style_line, linewidth=6, color=heatmapCol)

// ══════════════════════════════════════════════════════════════════════════════
//  DATA-WINDOW EXPORTS
// ══════════════════════════════════════════════════════════════════════════════
// editable=false hides these from the Style tab. The " (engine)" suffix
// distinguishes them from the visible plots above in the Data Window.
plot(atrPct,            "ATR%",                  color=color.new(C_GRAY, 0), display=display.data_window, editable=false)
plot(rawRank,           "Raw Rank (engine)",     color=color.new(C_GRAY, 0), display=display.data_window, editable=false)
plot(displayRank,       "Display Rank (engine)", color=color.new(C_GRAY, 0), display=display.data_window, editable=false)
plot(tier,              "Tier",                  color=color.new(C_GRAY, 0), display=display.data_window, editable=false)
plot(effectiveLensTone, "Lens Tone",             color=color.new(C_GRAY, 0), display=display.data_window, editable=false)

// ══════════════════════════════════════════════════════════════════════════════
//  PRICE-CHART OVERLAY MARKERS (off by default)
// ══════════════════════════════════════════════════════════════════════════════
plotshape(showPriceMarkers and showCompBreak and compReleaseFire, title="Compression Release (Chart)", style=shape.diamond, location=location.belowbar, color=colRelease, size=size.small, force_overlay=true, display=display.all - display.status_line, editable=false)

// PLAYBOOK CANDLE TINTS - optional, off by default. Tints follow effectiveLensTone
// (Neutral = no tint). When the Extreme Touch is also active, the Extreme tint
// ALWAYS wins - objective event > subjective playbook context.
bool playbookActive = warm and playbookLens != LENS_NEUTRAL
// Fallback MUST be na (not 100% transparent gray). barcolor() with a
// fully-transparent color paints an invisible layer over the candle,
// erasing body and borders. na = "leave the candle alone."
color candleTintCol = na
if effectiveLensTone == 2
    candleTintCol := color.new(colRelease, 30)
else if effectiveLensTone == 1
    candleTintCol := color.new(colRelease, 65)
else if effectiveLensTone == -1
    candleTintCol := color.new(colExtreme, 65)
else if effectiveLensTone == -2
    candleTintCol := color.new(colExtreme, 30)

// Two barcolor calls - the second wins when both fire:
//   1. Playbook tint colors the CURRENT bar (no offset).
//   2. Extreme tint colors the PEAK bar with offset=-1, overriding Playbook
//      on that specific bar so the objective event always wins visually.
// Override gate triggers when EITHER price-chart layer is on, so the
// objective>subjective rule holds whether the user has Price Markers or
// Playbook Tints enabled.
bool extremeForBar = showExtreme and extremeFire and (showPriceMarkers or showPlaybookTints)

barcolor((showPlaybookTints and playbookActive) ? candleTintCol : na, title="Playbook Candle Tint")
barcolor(extremeForBar ? colExtreme : na, offset=-1, title="Extreme Bar Tint")

// ══════════════════════════════════════════════════════════════════════════════
//  INFO PANEL - fixed 6 rows, var table (no per-tick allocation)
// ══════════════════════════════════════════════════════════════════════════════
// Row 0: Volatility   |  <Tier> · P<rawRank>             (P-Score, no % sign)
// Row 1: Flow         |  <Phase> · <early/mid/late/extended>
// Row 2: Age          |  <Fresh/Normal/Mature/Extended> · <bars>
// Row 3: Event/Context |  EITHER <event name + bars-ago>
//                       OR    <Context> + <current state synthesis>
//                       (label switches; row stays present so table doesn't jump)
// Row 4: ATR Range    |  <atrPct>% / bar
// Row 5: Playbook     |  <Tone> · <lensVal>
//
// Table allocated once at module scope (var) to avoid per-tick churn. Cells
// and theme colors are applied inside barstate.islast via table.set_*() so
// they track a mid-session TradingView theme switch. Row 3 never hides -
// it re-purposes between "Last Event" (when an event is alive) and "Context"
// (when none) so the table never resizes.
color tblBgCol     = useLightTheme ? color.new(#FAFAFC, 10) : color.new(color.black, 15)
color tblFrameCol  = useLightTheme ? color.new(#AAAFBE, 30) : color.new(C_GRAY, 30)
color tblBorderCol = useLightTheme ? color.new(#C8CDD7, 40) : color.new(C_GRAY, 50)
var table infoPanel = table.new(panelAnchor, 2, 6, border_width=1, frame_width=2)

if barstate.islast and showInfoPanel
    table.set_bgcolor(infoPanel, tblBgCol)
    table.set_border_color(infoPanel, tblBorderCol)
    table.set_frame_color(infoPanel, tblFrameCol)

    // ─── Row values ─────────────────────────────────────────────────────────
    // Volatility: tier name + raw percentile in P-Score notation (P0..P100).
    string volatilityVal = not warm ? tierStr : tierStr + " · P" + str.tostring(rawRank, "#0")

    // Flow: phase + early/mid/late/extended bucket. Bucket cutoffs use
    // halfTypical (typical phase length on this market). Falls back to bare
    // bar count when cycle history hasn't accumulated.
    string flowBucket = ""
    if na(halfTypical) or halfTypical <= 0
        flowBucket := ""
    else if phaseDuration <= halfTypical / 3.0
        flowBucket := "early"
    else if phaseDuration <= 2.0 * halfTypical / 3.0
        flowBucket := "mid"
    else if phaseDuration <= halfTypical
        flowBucket := "late"
    else
        flowBucket := "extended"

    string flowVal = "-"
    if not warm
        flowVal := "warming up"
    else if phase < 0
        flowVal := "-"
    else if phase == PHASE_TOPPING or phase == PHASE_BOTTOMING
        flowVal := phaseStr
    else if flowBucket == ""
        flowVal := phaseStr + " · " + str.tostring(phaseDuration) + "b"
    else
        flowVal := phaseStr + " · " + flowBucket

    // Age: Fresh / Normal / Mature / Extended bucket from tierDurPctile (the
    // percentile of the current tier's duration vs prior runs of the same
    // tier). Bare bar count when below the historical floor.
    string ageBucket = ""
    if na(tierDurPctile)
        ageBucket := ""
    else if tierDurPctile < 25
        ageBucket := "Fresh"
    else if tierDurPctile < 50
        ageBucket := "Normal"
    else if tierDurPctile < 75
        ageBucket := "Mature"
    else
        ageBucket := "Extended"

    string ageVal = "-"
    if not warm
        ageVal := "-"
    else if ageBucket == ""
        ageVal := str.tostring(barsInTier) + " bars"
    else
        ageVal := ageBucket + " · " + str.tostring(barsInTier) + " bars"

    // Range: panel shows just the percentage (% / bar). Absolute ATR value
    // moves to the tooltip - keeps the panel cell tight.
    string rangeVal = na(atrValue) or na(atrPct) ? "-" : str.tostring(atrPct, "#0.00") + "% / bar"

    // Row 3: re-purposed Event/Context row. Always present (no row hiding -
    // dynamic row count would resize the table). When an event is alive,
    // shows the event + bars-ago. When no event is alive, shows the current
    // regime context (loaded compression / quiet / mid range / etc) so the
    // row always carries information.
    bool   eventVisible = warm and lastEventType != EVT_NONE and eventStillAlive and not na(lastEventBar)
    string row3Label    = eventVisible ? "Last Event" : "Context"
    string row3Val      = "-"
    if not warm
        row3Val := "warming up"
    else if eventVisible
        int barsAgo = bar_index - lastEventBar
        string evtName = lastEventType == EVT_COMP_RELEASE ? "Compression Release" : lastEventType == EVT_EXTREME ? "Extreme Touch" : "Cooling"
        row3Val := evtName + " " + str.tostring(barsAgo) + "b ago"
    else
        // Context fallback - lift a short state synthesis from the regime
        if readTier == 0 and readBarsTier >= 10
            row3Val := "Loaded compression"
        else if readTier == 0
            row3Val := "Quiet compression"
        else if readTier == 1
            row3Val := "Quiet"
        else if readTier == 2 and readPhase == PHASE_RISING
            row3Val := "Drifting up"
        else if readTier == 2 and readPhase == PHASE_FALLING
            row3Val := "Drifting down"
        else if readTier == 2
            row3Val := "Mid range"
        else if readTier == 3
            row3Val := "Elevated"
        else
            row3Val := "Mid range"

    // ─── Theme palette ──────────────────────────────────────────────────────
    color titleCol  = useLightTheme ? #0F1423 : color.white
    color labelCol  = useLightTheme ? #5A5F73 : C_GRAY
    color valueCol  = useLightTheme ? #191E2D : color.white

    // Panel tier text + phase text colors derive from the Appearance / Palette
    // inputs so the panel colors track whatever palette the user picks.
    color tierWordColor = not warm ? labelCol : tier == 3 ? colElevated : tier == 2 ? colNormal : tier == 1 ? colQuiet : tier == 0 ? colCompression : labelCol

    color phaseToppingCol = useLightTheme ? #B89400 : #FFC850  // gold (no tier equivalent in palette)
    color phaseWordColor  = phase == PHASE_TOPPING ? phaseToppingCol : phase == PHASE_BOTTOMING ? colCompression : phase == PHASE_RISING ? colElevated : phase == PHASE_FALLING ? colQuiet : labelCol

    // Last Event row color - sourced from the Colors-group inputs.
    color lastEventCol = valueCol
    if not eventVisible
        lastEventCol := labelCol
    else if lastEventType == EVT_COMP_RELEASE
        lastEventCol := colRelease
    else if lastEventType == EVT_EXTREME
        lastEventCol := colExtreme
    else if lastEventType == EVT_COOLING
        lastEventCol := colQuiet

    // Playbook Lens row color mirrors the Heatmap Strip: tone > 0 = Release
    // color, tone < 0 = Extreme color, neutral = gray. Sign-based mapping
    // keeps the row text and the strip in lockstep.
    color lensWordCol = labelCol
    if effectiveLensTone > 0
        lensWordCol := colRelease
    else if effectiveLensTone < 0
        lensWordCol := colExtreme

    // Playbook tone prefix - mirrors the Heatmap Strip in words. Neutral Lens
    // uses "Context" so the row reads as factual state, not a compatibility
    // score.
    string toneLabel = ""
    if playbookLens == LENS_NEUTRAL
        toneLabel := "Context"
    else if effectiveLensTone == 2
        toneLabel := "Strong Fit"
    else if effectiveLensTone == 1
        toneLabel := "Favorable"
    else if effectiveLensTone == -1
        toneLabel := "Caution"
    else if effectiveLensTone == -2
        toneLabel := "Stretched"
    else
        toneLabel := "Neutral"
    string playbookVal = warm ? toneLabel + " · " + lensVal : lensVal

    string tipTitle      = "Volatility tier + raw P-Score (P0..P100). 'P83' = vol at the 83rd percentile of the lookback.\n\n• Compression - rank in [0, 25)\n• Quiet - rank in [25, 50)\n• Normal - rank in [50, 75)\n• Elevated - rank >= 75\n\nExtreme Touch fires when a confirmed peak resolves at >= P90.\n\nP-Score uses the sharp raw rank; the pane line is smoothed - so panel and line can briefly disagree when a quick spike crosses a tier before the smoothed line catches up.\n\nAsymmetric hysteresis: 1 confirmed bar UP, 3 DOWN."
    string tipFlow       = "Vol Flow: Rising -> Topping -> Falling -> Bottoming.\n\nASYMMETRIC CONFIRMATION: 2-bar confirm for slope changes; instant snap on violent moves (|Δrank| > 15).\n\n'early / mid / late / extended' compares phase duration against typical phase length on this market (rolling 5-cycle window). Needs >=3 completed cycles - until then, bare bar count."
    string tipAge        = "Bars in the current tier, classified vs historical runs of the SAME tier on this market.\n\n• Fresh - below 25th pctile of prior runs\n• Normal - 25th to 50th\n• Mature - 50th to 75th\n• Extended - above 75th\n\nPer-tier comparison (rolling 50-instance window per tier). Until 10 historical instances exist, you see just the bar count."
    string tipRow3       = "Either 'Last Event' (active regime event with state decay) OR 'Context' (current state when no event is alive).\n\nEvent visibility:\n• Compression Release - while Flow is Rising or tier is Normal+\n• Extreme Touch - while tier is Elevated\n• Cooling - while tier is Normal+\n\nNo fixed timer. Row re-purposes when no event is load-bearing."
    string tipRange      = "ATR as % of price - recent realized one-bar move size. Useful for understanding whether recent bar ranges are compressed, typical, or stretched.\n\nAbsolute price-unit ATR: " + (na(atrValue) ? "-" : str.tostring(atrValue, format.mintick)) + "\n\nLAG WARNING: ATR is a backward-looking Wilder-smoothed (RMA) average. In a fresh expansion, ATR lags - ATR may understate fresh expansion on the first breakout bar, and tier context can help interpret whether ATR is lagging."
    string tipPlaybook   = "How compatible is the current volatility state with the selected Playbook?\n\nText combines a TONE PREFIX (matching the Heatmap color) with the playbook synthesis:\n• Strong Fit / Favorable - Release color\n• Neutral - gray\n• Caution / Stretched - Extreme color\n• Context - shown when Lens = Neutral (factual state, not a compatibility score)\n\nSame regime, different playbook fit. Compatibility language only - never a buy/sell directive."

    // Row 0: Volatility
    table.cell(infoPanel, 0, 0, "Volatility",   tooltip=tipTitle, text_color=titleCol,      text_size=size.normal, text_halign=text.align_left)
    table.cell(infoPanel, 1, 0, volatilityVal,  tooltip=tipTitle, text_color=tierWordColor, text_size=size.large,  text_halign=text.align_right)

    // Row 1: Flow
    table.cell(infoPanel, 0, 1, "Flow",      tooltip=tipFlow, text_color=labelCol,       text_size=size.normal, text_halign=text.align_left)
    table.cell(infoPanel, 1, 1, flowVal,     tooltip=tipFlow, text_color=phaseWordColor, text_size=size.normal, text_halign=text.align_right)

    // Row 2: Age
    table.cell(infoPanel, 0, 2, "Age",   tooltip=tipAge, text_color=labelCol, text_size=size.normal, text_halign=text.align_left)
    table.cell(infoPanel, 1, 2, ageVal,  tooltip=tipAge, text_color=valueCol, text_size=size.normal, text_halign=text.align_right)

    // Row 3: Event/Context (label switches dynamically; row always present)
    table.cell(infoPanel, 0, 3, row3Label,  tooltip=tipRow3, text_color=labelCol,                            text_size=size.normal, text_halign=text.align_left)
    table.cell(infoPanel, 1, 3, row3Val,    tooltip=tipRow3, text_color=eventVisible ? lastEventCol : valueCol, text_size=size.normal, text_halign=text.align_right)

    // Row 4: ATR Range
    table.cell(infoPanel, 0, 4, "ATR Range",  tooltip=tipRange, text_color=labelCol, text_size=size.normal, text_halign=text.align_left)
    table.cell(infoPanel, 1, 4, rangeVal,     tooltip=tipRange, text_color=valueCol, text_size=size.normal, text_halign=text.align_right)

    // Row 5: Playbook (tone prefix + lens synthesis - mirrors heatmap color)
    table.cell(infoPanel, 0, 5, "Playbook",   tooltip=tipPlaybook, text_color=labelCol,    text_size=size.normal, text_halign=text.align_left)
    table.cell(infoPanel, 1, 5, playbookVal,  tooltip=tipPlaybook, text_color=lensWordCol, text_size=size.normal, text_halign=text.align_right)

// ══════════════════════════════════════════════════════════════════════════════
//  ALERTS - 4 total, all bar-close gated
// ══════════════════════════════════════════════════════════════════════════════
// Each alert message is a pure JSON payload (no leading prose) so webhook
// consumers (3Commas, Make.com, n8n, custom) can parse the body directly.
// Human-readable text lives inside the object as the "message" key.
// All event booleans are gated on `barstate.isconfirmed` upstream, so alerts
// cannot fire intra-bar.
alertcondition(compReleaseFire,                                                               "Compression Release",   '{"event":"compression_release","message":"Compression Release confirmed: volatility moved above mid-rank within 5 bars after a loaded compression (>=10 bars).","ticker":"{{ticker}}","price":{{close}},"tf":"{{interval}}","time":"{{time}}"}')
alertcondition(extremeFire,                                                                   "Extreme Touch",         '{"event":"extreme_touch","message":"Extreme Touch confirmed - volatility rank peaked above P90 on the previous bar (peak detection requires the next bar to confirm the turn-down).","ticker":"{{ticker}}","price":{{close}},"tf":"{{interval}}","time":"{{time}}"}')
alertcondition(coolingFire,                                                                   "Cooling",               '{"event":"cooling","message":"Cooling - volatility settling after extreme.","ticker":"{{ticker}}","price":{{close}},"tf":"{{interval}}","time":"{{time}}"}')
alertcondition(barstate.isconfirmed and warm and tier == 0 and nz(tier[1], -1) != 0,          "Compression Entry",     '{"event":"compression_entry","message":"Compression Entry - rank dropped below 25th percentile (sustained).","ticker":"{{ticker}}","price":{{close}},"tf":"{{interval}}","time":"{{time}}"}')
````

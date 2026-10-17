# CQ_(A)_Larry Williams Vix Fix V4 - Tops & Bottoms + Histogram

- url: https://www.tradingview.com/script/bBCjDnFN-CQ-A-Larry-Williams-Vix-Fix-V4-Tops-Bottoms-Histogram/
- type: indicator
- pine_id: PUB;78c95b2f887e41a08d912539a97c2ec2
- version: 2.0

## Description

================================================================================
  CQ_(G)_LARRY WILLIAMS VIX FIX V4 - TOPS & BOTTOMS + HISTOGRAM
  Pine Script v6  |  TradingView Overlay Indicator
  Author: CQuevedo345
  Based on open-source work by theehoganator
================================================================================


════════════════════════════════════════════════════════════════════════════════
  PART I — WILLIAMS VIX FIX: THEORY & CONCEPTUAL FRAMEWORK
════════════════════════════════════════════════════════════════════════════════


────────────────────────────────────────────────────────────────────────────────
  1. ORIGIN AND MOTIVATION
────────────────────────────────────────────────────────────────────────────────

The Williams VIX Fix (WVF) is a synthetic volatility indicator invented by
Larry Williams and published in a 2007 article in Technical Analysis of Stocks
and Commodities magazine. Its central goal was to replicate the informational
content of the CBOE Volatility Index (VIX) using nothing but price data,
making it applicable to any instrument and any timeframe — equities, futures,
forex, crypto, indices — without requiring access to options markets.

The VIX measures the implied volatility of S&P 500 index options, essentially
reflecting the market's collective expectation of near-term price movement.
When fear spikes — during crashes, sharp corrections, or unexpected shocks —
the VIX surges. When markets are calm and complacent, the VIX stays low. This
behavioral pattern makes VIX extremes valuable as contrarian timing signals:
peak fear often coincides with market lows, and peak complacency often precedes
market tops.

Williams's insight was that the same relationship could be approximated using
only the distance between the current price bar and recent price extremes. If a
bar's low has fallen far below recent highs, it reflects the same kind of
compression that produces VIX spikes — panic, forced selling, exhaustion. No
options data required.


────────────────────────────────────────────────────────────────────────────────
  2. THE CORE FORMULAS
────────────────────────────────────────────────────────────────────────────────

STANDARD WVF (Bottoms / Fear Detection):

  WVF = ( Highest Close over N bars − Current Low )
        ─────────────────────────────────────────── × 100
              Highest Close over N bars

A large WVF value means the current low has fallen far below the highest recent
close. This mimics a VIX spike: the market has dropped sharply relative to
where it recently was, suggesting fear, capitulation, or oversold conditions.
High values are associated with potential market bottoms.

INVERSE WVF (Tops / Greed Detection):

  Inverse WVF = ( Current High − Lowest Close over N bars )
                ─────────────────────────────────────────── × 100
                      Lowest Close over N bars

A large Inverse WVF value means the current high has extended far above the
lowest recent close. This is the mirror image: the market has run up sharply
relative to where it recently was, suggesting euphoria, extension, or overbought
conditions. High values are associated with potential market tops.

Both formulas are always positive. The Inverse WVF is used internally as a
negative series in the histogram engine so both can be rendered symmetrically
around a shared baseline.


────────────────────────────────────────────────────────────────────────────────
  3. SIGNAL THRESHOLDS: WHEN IS A VALUE "ELEVATED"?
────────────────────────────────────────────────────────────────────────────────

A raw WVF number alone is not a signal. It must be evaluated against its own
recent statistical behavior. This indicator uses two independent thresholds,
and a value qualifies as elevated when it exceeds EITHER one:

BOLLINGER BAND UPPER BAND
  The WVF series is itself treated as a data series. A Bollinger Band is
  computed on the WVF values (not on price): SMA(WVF, bbl) + mult × StdDev.
  When the current WVF value exceeds its own upper band, volatility is elevated
  relative to its recent average behavior.

PERCENTILE RANGE HIGH
  The highest WVF value over a long lookback (lb bars) is found, and a
  percentile fraction (ph) is applied: RangeHigh = Highest(WVF, lb) × ph.
  This ensures that signals only fire when the WVF reaches a historically
  significant level relative to its own recent range. At ph = 0.85, the WVF
  must reach 85% of its recent peak to qualify.

When EITHER threshold is breached, the WVF is "True" (active/elevated).


────────────────────────────────────────────────────────────────────────────────
  4. THE PRIMARY SIGNAL: "WAS TRUE, NOW FALSE"
────────────────────────────────────────────────────────────────────────────────

Williams's original methodology did not recommend entering on the spike itself.
Extreme readings can persist for multiple bars, and entering during a spike
means buying into ongoing panic (for bottoms) or ongoing euphoria (for tops).
The cleanest signal comes when the elevation RESOLVES — when the WVF drops back
below BOTH thresholds on the bar immediately following an elevated reading.

This "Was True, Now False" condition represents the moment fear (or greed) has
peaked and is beginning to dissipate. Price has typically found at least a
short-term equilibrium, and the statistical anomaly is over. This is the bar
where the opportunity is most cleanly defined.

The indicator renders this as the ◓ (top resolution) and ◒ (bottom resolution)
half-circle glyphs, accompanied by a ➙ arrow — the primary actionable signals.


────────────────────────────────────────────────────────────────────────────────
  5. FILTERED AND AGGRESSIVE ENTRIES
────────────────────────────────────────────────────────────────────────────────

Two additional layers of qualification improve signal timing and reduce noise:

FILTERED ENTRY (conservative, higher quality):
  All of the following must be true simultaneously:
  — WVF was elevated on the prior bar (Was True condition met).
  — Price shows directional confirmation: for bottoms, close must be below the
    long-term OR medium-term lookback close, confirming a downtrend context. For
    tops, close must be above those levels, confirming an uptrend context.
  — A price range confirmation: for bottoms, the low must be higher than the
    prior low AND the close above the prior high (upRange). For tops, the high
    must be lower than the prior high AND the close below the prior low
    (downRange).
  — A momentum confirmation: for bottoms, close must be greater than the close
    N bars ago (str parameter). For tops, close must be less.

AGGRESSIVE ENTRY (permissive, earlier entry):
  The WVF resolution requirement is relaxed — the entry fires while the WVF is
  still elevated, rather than waiting for it to drop. The directional and
  momentum conditions are still required, but the aggressive variant captures
  potential entries before the spike has fully resolved. Higher risk, earlier
  timing.


────────────────────────────────────────────────────────────────────────────────
  6. PRACTICAL INTERPRETATION AND CONTEXT
────────────────────────────────────────────────────────────────────────────────

The Williams VIX Fix is fundamentally a MEAN-REVERSION volatility signal. Its
core assumption is that markets periodically overshoot driven by emotional
extremes — fear at bottoms, greed at tops — and that those extremes are
statistically identifiable and tend to resolve back toward equilibrium.

WHEN IT WORKS WELL:
  — Ranging, cyclical, or oscillating markets.
  — Higher timeframes (daily, weekly) where volatility spikes are meaningful.
  — Instruments with clear boom-and-bust cycles (commodities, small caps, crypto
    in trending cycles).
  — As a filter layered on top of a directional thesis.

WHEN IT IS LESS RELIABLE:
  — Strong, persistent trending markets (a bottom signal in a bear market may
    just be a pause before continuation).
  — Very low timeframes (1m, 5m) where noise drowns out meaningful signals.
  — Instruments with structural volatility regimes that change over time.

The WVF does not predict direction — it identifies statistical extremes. The
trader's job is to determine whether that extreme is a reversal opportunity or
a continuation pause. Combining with trend filters (e.g. moving averages,
market structure) significantly improves reliability.


════════════════════════════════════════════════════════════════════════════════
  PART II — INDICATOR MANUAL
════════════════════════════════════════════════════════════════════════════════


────────────────────────────────────────────────────────────────────────────────
  7. OVERVIEW
────────────────────────────────────────────────────────────────────────────────

This indicator merges two separate tools into a single Pine Script v6 overlay:

COMPONENT A — TOPS & BOTTOMS LABELS (V4)
  Detects potential market tops using the Inverse WVF and market bottoms using
  the standard WVF. Signals are rendered as label markers directly on the price
  chart — triangles, arrows, and text callouts above or below qualifying bars.
  Each signal type has independent display toggles and alert line plots.

COMPONENT B — DUAL-MODE HISTOGRAM
  Renders a proportional histogram of both WVF series (lows and highs) as
  colored boxes anchored to the price chart. The histogram is configurable in
  size, position, orientation, and color, and supports a split mode where the
  two series are displayed on opposite sides of the visible price range.

Both components share a common set of core parameters and all outputs
(labels, boxes, lines, alert plots, alert conditions) are active simultaneously.


────────────────────────────────────────────────────────────────────────────────
  8. ADDING THE INDICATOR
────────────────────────────────────────────────────────────────────────────────

  1. Open TradingView and navigate to any chart.
  2. Open the Pine Script Editor (bottom panel → Pine Editor tab).
  3. Paste the full script and click Save, then Add to Chart.
  4. The indicator renders directly on the price pane as an overlay.
  5. Access all settings via the gear icon next to the indicator name on the
     chart, or via the indicator title in the top-left of the pane.


────────────────────────────────────────────────────────────────────────────────
  9. INPUT GROUPS AND PARAMETERS
────────────────────────────────────────────────────────────────────────────────

The settings panel is organized into seven groups:


  ┌─────────────────────────────────────────────────────────────────────────┐
  │  GROUP 1: SHARED — Tops and Bottoms Variables                           │
  └─────────────────────────────────────────────────────────────────────────┘

  These parameters affect all calculations in both Component A (labels) and
  Component B (histogram). Changing any of these alters every signal and every
  histogram bar simultaneously.

  LookBack Period Standard Deviation        Default: 22
    The N-bar window used in both WVF formulas. Controls the period over which
    the Highest Close (for bottoms WVF) and Lowest Close (for tops WVF) are
    computed. Smaller values make the indicator more reactive to recent price
    action; larger values smooth out shorter-term fluctuations.

  Bollinger Band Length                     Default: 20
    The SMA and standard deviation period applied to the WVF series itself
    (not to price). The upper band derived from this setting is one of the two
    elevation thresholds.

  Bollinger Band Standard Deviation         Default: 2.0  (range: 1–5)
    The multiplier applied to the standard deviation in the Bollinger Band
    calculation. Higher values (e.g. 3.0) raise the threshold, reducing the
    frequency of signals but increasing their statistical significance. Lower
    values (e.g. 1.5) lower the threshold, producing more frequent but noisier
    signals.

  Look Back Period Percentile               Default: 50
    The lookback window used to find the highest WVF value for the percentile
    threshold calculation. A 50-bar window means the indicator looks back 50
    bars to find the peak WVF, then applies the Highest Percentile fraction.

  Highest Percentile                        Default: 0.85
    The fraction of the recent WVF range peak that must be reached to qualify
    as elevated. At 0.85, the WVF must hit 85% of its 50-bar high to trigger.
    At 0.90, 90% is required (more selective). At 0.99, only near-peak values
    qualify (very selective, very rare).

  Lowest Percentile                         Default: 1.01
    The inverse multiplier used for the histogram's highs (inverse WVF) series.
    Applied to the lowest WVF value in the lookback window. Used internally for
    the histogram's upper threshold boundary for the tops series. Values above
    1.00 raise the bar; 1.01 requires the highs WVF to reach 101% of its
    recent trough (near-exact match to the extreme).

  Long-Term LookBack (Filtered)             Default: 40  (range: 25–99)
    Used in filtered entry criteria. For bottoms, the close must be BELOW the
    close 40 bars ago OR below the medium-term lookback to confirm that price
    is in a downtrend context. For tops, close must be ABOVE it. Acts as a
    trend context filter.

  Medium-Term LookBack (Filtered)           Default: 14  (range: 10–20)
    The shorter of the two lookback comparisons for filtered entries. The OR
    condition between this and the Long-Term LookBack means only one needs to
    be satisfied — providing some flexibility in trend context detection.

  Entry Price Action Strength               Default: 3  (range: 1–9)
    The momentum lookback. For bottoms, the close must exceed the close N bars
    ago. For tops, the close must be below the close N bars ago. Larger values
    require more sustained momentum to qualify.

  Markers Label Size                        Default: Large
    Size of the primary signal markers (◥ ↘ ◓ ➙ ◢ ↗ ◒). Options: Tiny,
    Small, Normal, Large, Huge. Controls only the compact glyph labels.

  Notes Label Size                          Default: Normal
    Size of the extended text callouts (Filtered Short/Long, Aggressive
    Short/Long with the vertical │ pointer lines). Kept separate from Markers
    to allow the text to scale independently.


  ┌─────────────────────────────────────────────────────────────────────────┐
  │  GROUP 2: TOPS — Text Plots Above                                       │
  └─────────────────────────────────────────────────────────────────────────┘

  Controls which of the four top-signal label types are rendered above bars.

  Show Plot: Inverse WVF IS True            Default: true
    Displays ◥ and ↘ labels above bars where the Inverse WVF is currently
    elevated (above either threshold). This is the "active spike" state —
    the market is in a statistically elevated top-side reading right now.
    Two labels appear per qualifying bar (one triangle glyph, one arrow).

  Show Plot: Inverse WVF WAS True, Now False  Default: true
    Displays ◓ and ➙ labels on the bar immediately after the Inverse WVF
    drops back below both thresholds. This is the primary short signal — the
    top-side spike has resolved.

  Both of these toggles are in the TOPS — Text Plots Above group. The
  Filtered and Aggressive toggles are in the TOPS — Filtered Criteria group
  (see below).


  ┌─────────────────────────────────────────────────────────────────────────┐
  │  GROUP 3: TOPS — Filtered Criteria                                      │
  └─────────────────────────────────────────────────────────────────────────┘

  Show Plot: Filtered Short Entry           Default: true
    Renders the "Filtered Short │││" text callout above bars meeting the full
    filtered criteria (WVF resolved + downRange + strength + trend context).

  Show Plot: Aggressive Filtered Short Entry  Default: true
    Renders the "Aggressive Short │││" text callout when aggressive criteria
    are met (WVF still elevated + strength + trend context, without waiting
    for full resolution).

  Long-Term LookBack — Close ABOVE this OR Medium-Term  Default: 40
    Tops-specific version of the shared long-term lookback. Close must be
    above close[40] or close[14] to confirm an uptrend context for the
    filtered short signal.

  Medium-Term LookBack — Close ABOVE this OR Long-Term  Default: 14
    Tops-specific medium-term lookback, paired with the long-term above.

  Strength — Close < X Bars Back           Default: 3
    Tops-specific momentum check. Close must be less than close[3] (default),
    confirming downward momentum is present on the signal bar.


  ┌─────────────────────────────────────────────────────────────────────────┐
  │  GROUP 4: TOPS — Alerts                                                 │
  └─────────────────────────────────────────────────────────────────────────┘

  Four boolean toggles that control whether numeric alert line plots are
  rendered for tops. When enabled, a plot outputs 1 on qualifying bars and 0
  otherwise. These plots are used to create TradingView Alerts (see Section 12).

  Alert: Inverse WVF = True                Default: false
    Plot goes to 1 when the Inverse WVF is currently elevated.

  Alert: Inverse WVF Was True, Now False   Default: false
    Plot goes to 1 on the resolution bar (the primary short signal bar).

  Alert: Inverse WVF Filtered             Default: false
    Plot goes to 1 when the full filtered short criteria are satisfied.

  Alert: Inverse WVF Aggressive Filter    Default: false
    Plot goes to 1 when the aggressive filtered criteria are satisfied.


  ┌─────────────────────────────────────────────────────────────────────────┐
  │  GROUP 5: BOTTOMS — Text Plots Below / Filtered Criteria / Alerts       │
  └─────────────────────────────────────────────────────────────────────────┘

  Mirror image of Groups 2–4 for the standard WVF (bottoms detection).
  All logic is identical but applied to the lows series. Labels appear below
  bars. Summary of the parameters:

  Show Plot: WVF IS True                   Default: true
    ◢ and ↗ labels below bars where WVF is currently elevated.

  Show Plot: WVF WAS True, Now False       Default: true
    ◒ and ➙ labels on the resolution bar. Primary long signal.

  Show Plot: Filtered Long Entry           Default: true
    "Filtered Long │││" text callout when full criteria are met.

  Show Plot: Aggressive Filtered Long      Default: true
    "Aggressive Long │││" text callout for aggressive criteria.

  Long-Term LookBack — Close BELOW this OR Medium-Term  Default: 40
    For filtered longs, close must be below close[40] or close[14].

  Medium-Term LookBack — Close BELOW this OR Long-Term  Default: 14
    Paired with the long-term lookback above.

  Strength — Close > X Bars Back          Default: 3
    Close must exceed close[3] (upward momentum) to qualify.

  Four alert toggles matching the tops group, for long-side signals.


  ┌─────────────────────────────────────────────────────────────────────────┐
  │  GROUP 6: HISTOGRAM — Display Options                                   │
  └─────────────────────────────────────────────────────────────────────────┘

  Flip Histogram Upside Down               Default: true
    When true, the histogram grows downward from the baseline (lows bars hang
    below, highs bars hang above in the combined/flipped orientation). When
    false, the orientation is inverted. Useful for visual preference or when
    using Split mode.

  Number of Bars to Show                   Default: 50  (range: 5–100)
    How many of the most recent bars display histogram boxes. Older bars beyond
    this count have no boxes drawn. Reducing this value improves performance
    and reduces visual clutter on zoomed-out views.

  Histogram Height (price units)           Default: 300  (range: 200–600, step 25)
    The total vertical span of the histogram, expressed in the chart's own
    price units. The tallest bar within the visible window always fills this
    full height; all other bars are scaled proportionally. Adjust this to match
    the price scale of the instrument being analyzed — a stock at $500 needs a
    much larger value than a forex pair at 1.08.

  Split Histogram: Above highest/Below lowest Price  Default: false
    When false (combined mode): Both the lows (green) and highs (red) series
    share a single baseline, placed below the lowest low of the visible window
    at 120% of the barHeight offset. Lows grow upward, highs grow downward from
    this shared baseline.

    When true (split mode): The two series separate to opposite edges of the
    visible price range. The lows series anchors 20% of barHeight below the
    lowest low and grows outward from there. The highs series anchors 20% above
    the highest high and grows outward. This gives an unobstructed view of both
    series without overlap and relates them spatially to price action.
    The Flip toggle swaps which series sits above vs. below.

  Plot High/Low Range Lines                Default: true
    When enabled, a thin horizontal line is drawn at the percentile threshold
    level for each bar. Orange lines for the lows series (Highest Percentile),
    red lines for the highs series (Lowest Percentile). These lines show where
    the threshold sits relative to each bar's actual WVF value.

  Plot Standard Deviation Band             Default: false
    When enabled, a thicker line is drawn at the Bollinger Band upper/lower
    band level for each bar. Aqua for lows, maroon for highs. Shows the moving
    Bollinger threshold relative to the histogram bars.

  Green Bars Needed to Trigger Alert       Default: 1  (minimum: 1)
    Controls the alertcondition() green bar logic. At 1 (default), a green bar
    alert fires on the first bar the WVF reaches extreme territory. At 2, two
    consecutive extreme bars are required before the alert fires. Useful for
    filtering brief, noise-level spikes.


  ┌─────────────────────────────────────────────────────────────────────────┐
  │  GROUP 7: HISTOGRAM — Colors                                            │
  └─────────────────────────────────────────────────────────────────────────┘

  Eight color pickers controlling the visual appearance of the histogram boxes,
  plus two line color pickers for the range and SD band lines.

  WVF Lows — Extreme       Default: semi-transparent green
    Color of lows bars when the WVF is currently elevated (above threshold).

  WVF Lows — Normal        Default: semi-transparent dark gray
    Color of lows bars during non-elevated periods.

  WVF Highs — Extreme      Default: opaque red
    Color of highs bars when the Inverse WVF is currently elevated.

  WVF Highs — Normal       Default: semi-transparent gray
    Color of highs bars during non-elevated periods.

  WVF Lows — Reverted      Default: semi-transparent gold
    Color used for the lows bar on the single bar immediately after the WVF
    drops from elevated to normal (the "Was True, Now False" moment). Visually
    highlights the resolution event.

  WVF Highs — Reverted     Default: semi-transparent gold
    Same as above, for the highs (Inverse WVF) reversion bar.

  Show Reversion (Yellow) Histogram Bars  Default: true
    Toggle to enable/disable the reversion color. When disabled, reverted bars
    display in their normal (non-elevated) color.

  Range Line — Lows        Default: semi-transparent orange
    Color of the percentile threshold line drawn alongside each lows bar.

  Range Line — Highs       Default: semi-transparent red
    Color of the percentile threshold line for the highs series.

  SD Band — Lows           Default: semi-transparent aqua
    Color of the Bollinger Band level line for the lows series.

  SD Band — Highs          Default: semi-transparent maroon
    Color of the Bollinger Band level line for the highs series.


────────────────────────────────────────────────────────────────────────────────
  10. SIGNAL REFERENCE TABLE
────────────────────────────────────────────────────────────────────────────────

  Signal         Location    Color            Meaning
  ─────────────────────────────────────────────────────────────────────────
  ◥  Triangle    Above bar   Red text         Inverse WVF IS True. Tops-side
                                               volatility currently elevated.

  ↘  Arrow       Above bar   White on red     Inverse WVF IS True. Directional
                                               bias indicator (downward).

  ◓  Half-circle Above bar   Gold on green    Inverse WVF WAS True, Now False.
                                               Primary short signal. Spike
                                               resolved, sell-side opportunity.

  ➙  Arrow       Above bar   White on green   Accompanies ◓. Resolution
                                               confirmed.

  Aggressive     Above bar   Orange text      Aggressive Short. Inverse WVF
  Short │││                                   still elevated; early short entry
                                               with momentum/trend confirmation.

  Filtered       Above bar   White text       Filtered Short. Full criteria met:
  Short │││                                   resolution + range + momentum +
                                               trend context.

  ◢  Triangle    Below bar   Green text       WVF IS True. Bottoms-side
                                               volatility currently elevated.

  ↗  Arrow       Below bar   White on green   WVF IS True. Directional bias
                                               indicator (upward).

  ◒  Half-circle Below bar   Gold on red      WVF WAS True, Now False. Primary
                                               long signal. Spike resolved,
                                               buy-side opportunity.

  ➙  Arrow       Below bar   White on red     Accompanies ◒. Resolution
                                               confirmed.

  │││            Below bar   Orange text      Aggressive Long. Early long entry
  Aggressive                                  while WVF still elevated.
  Long

  │││            Below bar   White text       Filtered Long. Full criteria met
  Filtered                                    for conservative long entry.
  Long


────────────────────────────────────────────────────────────────────────────────
  11. HISTOGRAM VISUAL GUIDE
────────────────────────────────────────────────────────────────────────────────

  COMBINED MODE (bSplit = false, bFlip = true — defaults):
    A single horizontal baseline is anchored below the lowest low of the
    visible window. Green (lows) bars grow downward from this baseline, and
    red (highs) bars grow upward from the same baseline. The tallest bar in
    either series fills the full barHeight; all others are proportionally
    scaled.

  SPLIT MODE (bSplit = true):
    The lows (green) series separates below price action, anchored 20% of
    barHeight below the lowest low. The highs (red) series separates above
    price action, anchored 20% of barHeight above the highest high. Each
    series grows away from the price center — lows downward, highs upward
    (or swapped if bFlip is true). This mode is ideal when you want the
    histogram to frame the price action symmetrically.

  BAR STATES:
    Gray (low opacity): WVF value is within normal statistical range.
    Green (extreme): WVF has exceeded the elevation threshold — lows spike.
    Red (extreme): Inverse WVF has exceeded its threshold — highs spike.
    Gold/Yellow: The bar immediately after an elevated reading drops back to
    normal — the reversion bar, visually identical to the primary signal.

  RANGE LINES:
    Thin horizontal lines at the percentile threshold level (orange = lows,
    red = highs). When a histogram bar exceeds its range line, it will be
    colored in the extreme color.

  SD BAND LINES:
    Thicker lines at the Bollinger Band level (aqua = lows, maroon = highs).
    When a bar exceeds this line, it also qualifies as elevated.


────────────────────────────────────────────────────────────────────────────────
  12. SETTING UP ALERTS
────────────────────────────────────────────────────────────────────────────────

  This indicator supports two types of alerts:

  TYPE A — LABEL ALERT PLOTS (Tops & Bottoms, 8 plots):
    These output 1 on qualifying bars and 0 otherwise. To use them:
    1. Enable one or more Alert toggles in the TOPS — Alerts or BOTTOMS —
       Alerts groups (e.g. "Alert: Inverse WVF Was True, Now False").
    2. Open TradingView's Alerts panel (the clock icon or Alt+A).
    3. Click Create Alert and select this indicator.
    4. Choose the relevant plot (e.g. "Alert: Top Now False").
    5. Set condition to "Crossing" or "Greater Than 0".
    6. Configure notification method (email, push, webhook) and click Create.

    Note: These plots are invisible on the chart by default. They output at
    the price scale and are not intended as visual elements.

  TYPE B — HISTOGRAM ALERTCONDITION (Green Bar Logic, 2 conditions):
    These fire based on the histogram's bColorBars state (extreme readings).
    They appear in the Alerts panel automatically without any toggle needed.
    1. Open Alerts panel → Create Alert → select this indicator.
    2. Choose "Williams Green Bar (LOWS)" or "Williams Green Bar (HIGHS)".
    3. The alert fires when N consecutive extreme bars appear (where N is
       set by "Green Bars Needed to Trigger Alert" in the Histogram group).

  INVISIBLE HISTOGRAM ALERT PLOTS (8 additional plots):
    Eight invisible plots (Hist Alert 1–4 Lows and 1–4 Highs) are also
    available in the Alerts panel for more granular histogram-based alert
    conditions. These correspond to the four filtered/aggressive stages for
    each direction.


────────────────────────────────────────────────────────────────────────────────
  13. RECOMMENDED SETTINGS BY USE CASE
────────────────────────────────────────────────────────────────────────────────

  SWING TRADING (Daily / Weekly Charts)
    Core parameters:         pd=22, bbl=20, mult=2.0, lb=50, ph=0.85
    Label signals:           Enable WAS True, Now False only; disable IS True.
    Histogram:               Split mode on; 30–50 bars; height adjusted to chart.
    Entry filter:            Enable Filtered signals; disable Aggressive.
    Alert:                   Alert: WVF Was True, Now False (both directions).
    Note: On daily charts, one confirmed resolution bar per week or month is
    a rich signal. Be patient and wait for the full resolution.

  INTRADAY (15m / 1H Charts)
    Core parameters:         pd=14, bbl=14, mult=2.0, lb=30, ph=0.90
    Label signals:           Enable both IS True and WAS True, Now False.
    Histogram:               Combined mode; 20–30 bars; reduce height.
    Entry filter:            Enable Aggressive for faster reaction.
    Alert:                   Green Bar alert at threshold 1 for instant reaction.
    Note: Signal frequency increases sharply. Apply a trend filter separately
    (e.g. compare to a 200 EMA on the same chart) to avoid counter-trend trades.

  MEAN REVERSION / RANGE TRADING
    Core parameters:         pd=22, bbl=20, mult=1.5, lb=50, ph=0.80
    Label signals:           All four signal types enabled.
    Histogram:               Split mode for clear visual separation.
    Entry filter:            Enable both Filtered and Aggressive.
    Note: Lower mult and ph makes signals more frequent. Suitable for range-
    bound instruments where any WVF spike is likely to revert.

  TREND FOLLOWING (using WVF as a pullback entry tool)
    Core parameters:         pd=22, bbl=20, mult=2.5, lb=50, ph=0.90
    Label signals:           Only WAS True, Now False; only Filtered entries.
    Direction bias:          Only trade Bottoms signals in an established
                             uptrend; only Tops signals in a downtrend.
    Histogram:               Use as a visual confirmation tool.
    Note: In a strong uptrend, WVF Bottoms signals (fear spikes on pullbacks)
    are often the best entries. Ignore all Tops signals in an uptrend.


────────────────────────────────────────────────────────────────────────────────
  14. TECHNICAL ARCHITECTURE NOTES
────────────────────────────────────────────────────────────────────────────────

  DUAL CALCULATION TRACKS:
    The indicator maintains two separate calculation tracks for the WVF:
    — inv_wvf / wvf: the label-driving track, used for all 12 label signals
      and 8 alert line plots. These use ph as the sole percentile parameter.
    — wvf_lows / wvf_highs: the histogram-driving track, identical in formula
      to the above but using both ph and pl for separate high/low thresholds.
      wvf_highs is a negative series (inverted sign convention) enabling
      symmetric rendering around a shared baseline.
    This separation ensures the label signals remain independent of the
    histogram's additional pl parameter.

  ARRAY-BASED DRAW ENGINE:
    The histogram does not draw on every bar. Instead, 13 rolling arrays collect
    values on every bar and are trimmed to nBars entries. On barstate.islast
    (the final bar), a single loop draws all boxes and lines at once. This
    approach ensures: (a) no ghost history bars, (b) a flat, stable baseline,
    and (c) normalization against only the visible window's max value.

  PINE SCRIPT LIMITS:
    max_boxes_count = 500: at nBars=50 with 2 boxes per bar, 100 boxes are
    used at any time. Well within the limit.
    max_lines_count = 500: with hp=true and sd=false, 2 lines per bar = 100
    lines. With sd=true, 4 lines per bar = 200 lines. Still within limits.
    Labels are not bounded by a max_labels_count declaration, but TradingView
    limits labels to 500 per indicator. With many signals enabled, this limit
    may be reached on charts with long histories.

  NON-REPAINTING:
    All historical WVF calculations use ta.highest() and ta.lowest() on closed
    bar data. These do not repaint. The "IS True" label condition is based on
    the current bar's WVF value, which is provisional until bar close — treat
    IS True labels on the real-time bar as unconfirmed until the bar closes.


────────────────────────────────────────────────────────────────────────────────
  15. KNOWN LIMITATIONS
────────────────────────────────────────────────────────────────────────────────

  — No built-in stop loss or target: the indicator identifies volatility
    extremes and potential reversal zones. It does not compute or display price
    targets, stop levels, or position sizing. These must be determined by the
    trader independently.

  — Histogram height is instrument-dependent: barHeight is expressed in price
    units. A value of 300 works well for a $300 stock but is far too small for
    Bitcoin at $60,000 or far too large for a forex pair. Adjust barHeight to
    roughly 5–15% of the instrument's current price level as a starting point.

  — Label accumulation on long-history charts: if all label types are enabled
    and the chart spans many years on a high-frequency timeframe, TradingView's
    500-label limit may be reached and older labels will be silently dropped.
    Disable unused label types to conserve the label budget.

  — Split mode positioning: in split mode, the baseline is computed from the
    highest high and lowest low within the visible nBars window. Panning or
    zooming the chart does not automatically recompute until a new real-time
    tick arrives. The histogram will update on the next price movement.

  — Histogram on instruments with very low prices (below $5): barHeight has a
    minimum of 200, which may cause the histogram to extend far beyond the
    visible chart area for very low-priced instruments. In this case, reduce
    barHeight by editing the input constraints directly in the script.


================================================================================
  © CQuevedo345 — Pine Script v6 — TradingView
  Based on original work by theehoganator and Larry Williams
================================================================================

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CQuevedo345

// Based on open-source work by theehoganator:
// https://www.tradingview.com/script/wYbPyvTV-Williams-Vix-Fix-Bottoms-and-Tops/
// Modified and extended in this version (see publication description for details).
//@version=6

indicator(title = 'CQ_(A)_Larry Williams Vix Fix V4 - Tops & Bottoms + Histogram', overlay = true, max_boxes_count = 500, max_lines_count = 500)


// ─────────────────────────────────────────────────────────────────────────────
//  COLOR PALETTE
// ─────────────────────────────────────────────────────────────────────────────
Black    = color.rgb(0,   0,   0)
Charcoal = color.rgb(54,  58,  69)
Gray     = color.rgb(120, 123, 134)
Silver   = color.rgb(192, 192, 192)
White    = color.rgb(255, 255, 255)
Brown    = color.rgb(165, 42,  42)
Red      = color.rgb(255, 0,   0)
Pink     = color.rgb(255, 105, 180)
Gold     = color.rgb(212, 175, 55)
Orange   = color.rgb(255, 106, 0)
Yellow   = color.rgb(255, 255, 0)
Green    = color.rgb(0,   175, 0)
Teal     = color.rgb(0,   128, 128)
Lime     = color.rgb(0,   255, 11)
Navy     = color.rgb(49,  27,  178)
Blue     = color.rgb(0,   148, 255)
Aqua     = color.rgb(0,   188, 212)
Purple   = color.rgb(128, 0,   128)
Fucshia  = color.rgb(224, 64,  251)
Clear    = color.rgb(0,   0,   0, 100)


// ─────────────────────────────────────────────────────────────────────────────
//  SHARED INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grpS = 'SHARED — Tops and Bottoms Variables'

pd       = input(22,        title = 'LookBack Period Standard Deviation',                  group = grpS)
bbl      = input(20,        title = 'Bollinger Band Length',                               group = grpS)
mult     = input.float(2.0, minval = 1, maxval = 5, title = 'Bollinger Band Standard Deviation', group = grpS)
lb       = input(50,        title = 'Look Back Period Percentile',                         group = grpS)
ph       = input(0.85,      title = 'Highest Percentile - 0.90=90%, 0.95=95%, 0.99=99%',  group = grpS)
pl       = input(1.01,      title = 'Lowest Percentile  - 1.10=90%, 1.05=95%, 1.01=99%',  group = grpS)
ltLB     = input.int(40,   minval = 25, maxval = 99, title = 'Long-Term LookBack  (Filtered)',  group = grpS)
mtLB     = input.int(14,   minval = 10, maxval = 20, title = 'Medium-Term LookBack (Filtered)', group = grpS)
str      = input.int(3,    minval = 1,  maxval = 9,  title = 'Entry Price Action Strength',     group = grpS)
lblSize  = input.string('Large',  title = 'Markers Label Size',
     options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = grpS)
lblSize2 = input.string('Normal', title = 'Notes Label Size',
     options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = grpS)

resolvedSize =
     lblSize == 'Tiny'   ? size.tiny   :
     lblSize == 'Small'  ? size.small  :
     lblSize == 'Normal' ? size.normal :
     lblSize == 'Large'  ? size.large  :
     size.huge

resolvedSize2 =
     lblSize2 == 'Tiny'   ? size.tiny   :
     lblSize2 == 'Small'  ? size.small  :
     lblSize2 == 'Normal' ? size.normal :
     lblSize2 == 'Large'  ? size.large  :
     size.huge


// ─────────────────────────────────────────────────────────────────────────────
//  TOPS — INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grpT  = 'TOPS — Text Plots Above'
grpTF = 'TOPS — Filtered Criteria'
grpTA = 'TOPS — Alerts'

sbcT     = input(true,  title = 'Show Plot: Inverse WVF WAS True and IS Now False',   group = grpT)
sbccT    = input(true,  title = 'Show Plot: Inverse WVF IS True',                     group = grpT)
sbcFiltT = input(true,  title = 'Show Plot: Filtered Short Entry',                    group = grpTF)
sbcAggrT = input(true,  title = 'Show Plot: Aggressive Filtered Short Entry',         group = grpTF)
ltLBT    = input.int(40, minval = 25, maxval = 99, title = 'Long-Term LookBack  — Close ABOVE this OR Medium-Term',  group = grpTF)
mtLBT    = input.int(14, minval = 10, maxval = 20, title = 'Medium-Term LookBack — Close ABOVE this OR Long-Term',   group = grpTF)
strT     = input.int(3,  minval = 1,  maxval = 9,  title = 'Strength — Close < X Bars Back',                         group = grpTF)

sa1T = input(false, title = 'Alert: Inverse WVF = True',              group = grpTA)
sa2T = input(false, title = 'Alert: Inverse WVF Was True, Now False', group = grpTA)
sa3T = input(false, title = 'Alert: Inverse WVF Filtered',            group = grpTA)
sa4T = input(false, title = 'Alert: Inverse WVF Aggressive Filter',   group = grpTA)


// ─────────────────────────────────────────────────────────────────────────────
//  BOTTOMS — INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grpB  = 'BOTTOMS — Text Plots Below'
grpBF = 'BOTTOMS — Filtered Criteria'
grpBA = 'BOTTOMS — Alerts'

sbcB     = input(true,  title = 'Show Plot: WVF WAS True and IS Now False',   group = grpB)
sbccB    = input(true,  title = 'Show Plot: WVF IS True',                     group = grpB)
sbcFiltB = input(true,  title = 'Show Plot: Filtered Long Entry',              group = grpBF)
sbcAggrB = input(true,  title = 'Show Plot: Aggressive Filtered Long Entry',   group = grpBF)
ltLBB    = input.int(40, minval = 25, maxval = 99, title = 'Long-Term LookBack  — Close BELOW this OR Medium-Term', group = grpBF)
mtLBB    = input.int(14, minval = 10, maxval = 20, title = 'Medium-Term LookBack — Close BELOW this OR Long-Term',  group = grpBF)
strB     = input.int(3,  minval = 1,  maxval = 9,  title = 'Strength — Close > X Bars Back',                        group = grpBF)

sa1B = input(false, title = 'Alert: WVF = True',              group = grpBA)
sa2B = input(false, title = 'Alert: WVF Was True, Now False', group = grpBA)
sa3B = input(false, title = 'Alert: WVF Filtered',            group = grpBA)
sa4B = input(false, title = 'Alert: WVF Aggressive Filter',   group = grpBA)


// ─────────────────────────────────────────────────────────────────────────────
//  HISTOGRAM — DISPLAY OPTIONS
// ─────────────────────────────────────────────────────────────────────────────
grpDisp = 'HISTOGRAM — Display Options'

bFlip            = input(true,  title = 'Flip Histogram Upside Down',                         group = grpDisp)
nBars            = input.int(50,  title = 'Number of Bars to Show', minval = 5, maxval = 100, group = grpDisp)
barHeight        = input.float(300, title = 'Histogram Height (price units)',
     minval = 200, maxval = 600, step = 25,                                                   group = grpDisp)
bSplit           = input(false, title = 'Split Histogram: Above highest/Below lowest Price',   group = grpDisp)
hp               = input(true,  title = 'Plot High/Low Range Lines',                          group = grpDisp)
sd               = input(false, title = 'Plot Standard Deviation Band',                       group = grpDisp)
GreenBarLookBack = input.int(1, minval = 1, title = 'Green Bars Needed to Trigger Alert',     group = grpDisp)

vAnchor = 0


// ─────────────────────────────────────────────────────────────────────────────
//  HISTOGRAM — COLORS
// ─────────────────────────────────────────────────────────────────────────────
grpCol = 'HISTOGRAM — Colors'

col_wvf_lows_extreme  = input.color(color.rgb(0,   148, 133, 34), title = 'WVF Lows — Extreme',    inline = 'WVF_Lows',   group = grpCol)
col_wvf_lows_normal   = input.color(color.rgb(58, 60, 65, 34), title = 'WVF Lows — Normal',     inline = 'WVF_Lows',   group = grpCol)
col_wvf_highs_extreme = input.color(color.rgb(255, 60, 0),       title = 'WVF Highs — Extreme',   inline = 'WVF_Highs',  group = grpCol)
col_wvf_highs_normal  = input.color(color.rgb(103, 106, 116, 34), title = 'WVF Highs — Normal',    inline = 'WVF_Highs',  group = grpCol)
col_wvf_lows_revert   = input.color(color.rgb(255, 215, 0,   34), title = 'WVF Lows — Reverted',   inline = 'WVF_Revert', group = grpCol)
col_wvf_highs_revert  = input.color(color.rgb(255, 215, 0,   34), title = 'WVF Highs — Reverted',  inline = 'WVF_Revert', group = grpCol)
bShowRevert           = input(true, title = 'Show Reversion (Yellow) Histogram Bars',
     inline = 'WVF_Revert', group = grpCol)

col_rangeLine_lows  = input.color(color.new(color.orange, 35), title = 'Range Line — Lows',  group = grpCol)
col_rangeLine_highs = input.color(color.new(color.red,    35), title = 'Range Line — Highs', group = grpCol)
col_sdBand_lows     = input.color(color.new(color.aqua,   35), title = 'SD Band — Lows',     group = grpCol)
col_sdBand_highs    = input.color(color.new(color.maroon, 35), title = 'SD Band — Highs',    group = grpCol)


// ─────────────────────────────────────────────────────────────────────────────
//  TOPS — CALCULATIONS
// ─────────────────────────────────────────────────────────────────────────────
inv_wvf    = (high - ta.lowest(close, pd)) / ta.lowest(close, pd) * 100
sDevT      = mult * ta.stdev(inv_wvf, bbl)
midLineT   = ta.sma(inv_wvf, bbl)
upperBandT = midLineT + sDevT
rangeHighT = ta.highest(inv_wvf, lb) * ph

downRange      = high < high[1] and close < low[1]
downRange_Aggr = close < close[1] and close < open[1]

filteredT      = (inv_wvf[1] >= upperBandT[1] or inv_wvf[1] >= rangeHighT[1]) and inv_wvf < upperBandT and inv_wvf < rangeHighT
filteredT_Aggr = (inv_wvf[1] >= upperBandT[1] or inv_wvf[1] >= rangeHighT[1]) and not(inv_wvf < upperBandT and inv_wvf < rangeHighT)

alert1T = inv_wvf >= upperBandT or inv_wvf >= rangeHighT ? 1 : 0
alert2T = (inv_wvf[1] >= upperBandT[1] or inv_wvf[1] >= rangeHighT[1]) and inv_wvf < upperBandT and inv_wvf < rangeHighT ? 1 : 0
alert3T = downRange      and close < close[strT] and (close > close[ltLBT] or close > close[mtLBT]) and filteredT      ? 1 : 0
alert4T = downRange_Aggr and close < close[strT] and (close > close[ltLBT] or close > close[mtLBT]) and filteredT_Aggr ? 1 : 0


// ─────────────────────────────────────────────────────────────────────────────
//  BOTTOMS — CALCULATIONS
// ─────────────────────────────────────────────────────────────────────────────
wvf        = (ta.highest(close, pd) - low) / ta.highest(close, pd) * 100
sDevB      = mult * ta.stdev(wvf, bbl)
midLineB   = ta.sma(wvf, bbl)
upperBandB = midLineB + sDevB
rangeHighB = ta.highest(wvf, lb) * ph

upRange      = low > low[1] and close > high[1]
upRange_Aggr = close > close[1] and close > open[1]

filteredB      = (wvf[1] >= upperBandB[1] or wvf[1] >= rangeHighB[1]) and wvf < upperBandB and wvf < rangeHighB
filteredB_Aggr = (wvf[1] >= upperBandB[1] or wvf[1] >= rangeHighB[1]) and not(wvf < upperBandB and wvf < rangeHighB)

alert1B = wvf >= upperBandB or wvf >= rangeHighB ? 1 : 0
alert2B = (wvf[1] >= upperBandB[1] or wvf[1] >= rangeHighB[1]) and wvf < upperBandB and wvf < rangeHighB ? 1 : 0
alert3B = upRange      and close > close[strB] and (close < close[ltLBB] or close < close[mtLBB]) and filteredB      ? 1 : 0
alert4B = upRange_Aggr and close > close[strB] and (close < close[ltLBB] or close < close[mtLBB]) and filteredB_Aggr ? 1 : 0


// ─────────────────────────────────────────────────────────────────────────────
//  HISTOGRAM — CALCULATIONS
// ─────────────────────────────────────────────────────────────────────────────
wvf_lows       = (ta.highest(close, pd) - low)  / ta.highest(close, pd) * 100
sDev_lows      = mult * ta.stdev(wvf_lows, bbl)
midLine_lows   = ta.sma(wvf_lows, bbl)
upperBand_lows = midLine_lows + sDev_lows
rangeHigh_lows = ta.highest(wvf_lows, lb) * ph
rangeLow_lows  = ta.lowest(wvf_lows,  lb) * pl

wvf_highs       = (ta.lowest(close, pd) - high) / ta.lowest(close, pd) * 100
sDev_highs      = mult * ta.stdev(wvf_highs, bbl)
midLine_highs   = ta.sma(wvf_highs, bbl)
lowerBand_highs = midLine_highs - sDev_highs
rangeHigh_highs = ta.highest(wvf_highs, lb) * pl
rangeLow_highs  = ta.lowest(wvf_highs,  lb) * ph

upRange_lows      = low > low[1] and close > high[1]
upRange_Aggr_lows = close > close[1] and close > open[1]
dnRange_highs      = high < high[1] and close < low[1]
dnRange_Aggr_highs = close < close[1] and close < open[1]

bFiltered_lows       = (wvf_lows[1] >= upperBand_lows[1] or wvf_lows[1] >= rangeHigh_lows[1]) and wvf_lows < upperBand_lows and wvf_lows < rangeHigh_lows
bFiltered_Aggr_lows  = (wvf_lows[1] >= upperBand_lows[1] or wvf_lows[1] >= rangeHigh_lows[1]) and not(wvf_lows < upperBand_lows and wvf_lows < rangeHigh_lows)
bFiltered_highs      = (wvf_highs[1] <= lowerBand_highs[1] or wvf_highs[1] <= rangeLow_highs[1]) and wvf_highs > lowerBand_highs and wvf_highs > rangeLow_highs
bFiltered_Aggr_highs = (wvf_highs[1] <= lowerBand_highs[1] or wvf_highs[1] <= rangeLow_highs[1]) and not(wvf_highs > lowerBand_highs and wvf_highs > rangeLow_highs)

alert1_lows  = wvf_lows  >= upperBand_lows  or wvf_lows  >= rangeHigh_lows  ? 1 : 0
alert2_lows  = bFiltered_lows  ? 1 : 0
alert3_lows  = upRange_lows      and close > close[str] and (close < close[ltLB] or close < close[mtLB]) and bFiltered_lows      ? 1 : 0
alert4_lows  = upRange_Aggr_lows and close > close[str] and (close < close[ltLB] or close < close[mtLB]) and bFiltered_Aggr_lows ? 1 : 0

alert1_highs = wvf_highs <= lowerBand_highs or wvf_highs <= rangeLow_highs ? 1 : 0
alert2_highs = bFiltered_highs  ? 1 : 0
alert3_highs = dnRange_highs      and close < close[str] and (close > close[ltLB] or close > close[mtLB]) and bFiltered_highs      ? 1 : 0
alert4_highs = dnRange_Aggr_highs and close < close[str] and (close > close[ltLB] or close > close[mtLB]) and bFiltered_Aggr_highs ? 1 : 0

bColorBars_lows  = wvf_lows  >= upperBand_lows  or wvf_lows  >= rangeHigh_lows
bColorBars_highs = wvf_highs <= lowerBand_highs or wvf_highs <= rangeLow_highs

bReverted_lows  = not bColorBars_lows  and bColorBars_lows[1]
bReverted_highs = not bColorBars_highs and bColorBars_highs[1]

col_AboveLines = Lime
bSbcc = false
bSbc  = false
bSbcFilt = false
bSbcAggr = false
bSgb  = false

Criteria_Aggressive_lows  = bSbcAggr and bool(alert4_lows)
Criteria_Filtered_lows    = bSbcFilt  and bool(alert3_lows)
Criteria_Entry_lows       = bSbc      and bFiltered_lows
Criteria_AboveLines_lows  = bSbcc     and (wvf_lows >= upperBand_lows or wvf_lows >= rangeHigh_lows)
Criteria_AllBars_lows     = bSgb      and bool(close)

Criteria_Aggressive_highs = bSbcAggr and bool(alert4_highs)
Criteria_Filtered_highs   = bSbcFilt  and bool(alert3_highs)
Criteria_Entry_highs      = bSbc      and bFiltered_highs
Criteria_AboveLines_highs = bSbcc     and (wvf_highs <= lowerBand_highs or wvf_highs <= rangeLow_highs)
Criteria_AllBars_highs    = bSgb      and bool(close)

TestBool_lows  = false
TestBool_highs = false

for i = 1 to GreenBarLookBack by 1
    if bColorBars_lows and not bColorBars_lows[i]
        TestBool_lows := true
    else
        TestBool_lows := false
    if TestBool_lows and GreenBarLookBack > 1
        for j = 1 to i - 1 by 1
            if not bColorBars_lows[j]
                TestBool_lows := false
                break

for i = 1 to GreenBarLookBack by 1
    if bColorBars_highs and not bColorBars_highs[i]
        TestBool_highs := true
    else
        TestBool_highs := false
    if TestBool_highs and GreenBarLookBack > 1
        for j = 1 to i - 1 by 1
            if not bColorBars_highs[j]
                TestBool_highs := false
                break


// ─────────────────────────────────────────────────────────────────────────────
//  TOPS — LABELS
// ─────────────────────────────────────────────────────────────────────────────
if sbccT and bool(alert1T)
    label.new(bar_index, high,
         text = '◥', style = label.style_label_down,
         color = color.rgb(255, 0, 0, 100), textcolor = color.rgb(255, 0, 0), size = resolvedSize)

if sbccT and bool(alert1T)
    label.new(bar_index, high,
         text = '↘', style = label.style_label_down,
         color = color.rgb(255, 0, 0, 100), textcolor = color.rgb(255, 255, 255), size = resolvedSize)

if sbcT and bool(alert2T)
    label.new(bar_index, high,
         text = '◓', style = label.style_label_down,
         color = color.rgb(0, 192, 16, 100), textcolor = color.rgb(199, 179, 0), size = resolvedSize)

if sbcT and bool(alert2T)
    label.new(bar_index, high,
         text = '➙', style = label.style_label_down,
         color = color.rgb(0, 192, 16, 100), textcolor = color.rgb(255, 255, 255), size = resolvedSize)

if sbcAggrT and bool(alert4T)
    label.new(bar_index, high,
         text = 'Aggressive\nShort\n│\n│\n│\n│', style = label.style_label_down,
         color = color.new(color.orange, 100), textcolor = color.new(color.orange, 0), size = resolvedSize2)

if sbcFiltT and bool(alert3T)
    label.new(bar_index, high,
         text = 'Filtered\nShort\n│\n│\n│\n│', style = label.style_label_down,
         color = color.new(color.white, 100), textcolor = color.new(color.white, 0), size = resolvedSize2)


// ─────────────────────────────────────────────────────────────────────────────
//  BOTTOMS — LABELS
// ─────────────────────────────────────────────────────────────────────────────
if sbccB and bool(alert1B)
    label.new(bar_index, low,
         text = '◢', style = label.style_label_up,
         color = color.rgb(0, 192, 16, 100), textcolor = color.rgb(0, 158, 14), size = resolvedSize)

if sbccB and bool(alert1B)
    label.new(bar_index, low,
         text = '↗', style = label.style_label_up,
         color = color.rgb(0, 192, 16, 100), textcolor = color.rgb(255, 255, 255), size = resolvedSize)

if sbcB and bool(alert2B)
    label.new(bar_index, low,
         text = '◒', style = label.style_label_up,
         color = color.rgb(255, 0, 0, 100), textcolor = color.rgb(199, 179, 0), size = resolvedSize)

if sbcB and bool(alert2B)
    label.new(bar_index, low,
         text = '➙', style = label.style_label_up,
         color = color.rgb(255, 0, 0, 100), textcolor = color.rgb(255, 255, 255), size = resolvedSize)

if sbcAggrB and bool(alert4B)
    label.new(bar_index, low,
         text = '│\n│\n│\n│\nAggressive\nLong', style = label.style_label_up,
         color = color.new(color.orange, 100), textcolor = color.new(color.orange, 0), size = resolvedSize2)

if sbcFiltB and bool(alert3B)
    label.new(bar_index, low,
         text = '│\n│\n│\n│\nFiltered\nLong', style = label.style_label_up,
         color = color.new(color.white, 100), textcolor = color.new(color.white, 0), size = resolvedSize2)


// ─────────────────────────────────────────────────────────────────────────────
//  HISTOGRAM — ARRAY COLLECTION
// ─────────────────────────────────────────────────────────────────────────────
var float[] a_wvf_lows        = array.new_float()
var float[] a_wvf_highs       = array.new_float()
var float[] a_rangeHigh_lows  = array.new_float()
var float[] a_rangeLow_highs  = array.new_float()
var float[] a_upperBand_lows  = array.new_float()
var float[] a_lowerBand_highs = array.new_float()
var bool[]  a_colorBars_lows  = array.new_bool()
var bool[]  a_colorBars_highs = array.new_bool()
var bool[]  a_reverted_lows   = array.new_bool()
var bool[]  a_reverted_highs  = array.new_bool()
var int[]   a_bar_index       = array.new_int()
var float[] a_low             = array.new_float()
var float[] a_high            = array.new_float()

array.push(a_wvf_lows,        wvf_lows)
array.push(a_wvf_highs,       wvf_highs)
array.push(a_rangeHigh_lows,  rangeHigh_lows)
array.push(a_rangeLow_highs,  rangeLow_highs)
array.push(a_upperBand_lows,  upperBand_lows)
array.push(a_lowerBand_highs, lowerBand_highs)
array.push(a_colorBars_lows,  bColorBars_lows)
array.push(a_colorBars_highs, bColorBars_highs)
array.push(a_reverted_lows,   bReverted_lows)
array.push(a_reverted_highs,  bReverted_highs)
array.push(a_bar_index,       bar_index)
array.push(a_low,             low)
array.push(a_high,            high)

if array.size(a_wvf_lows) > nBars
    array.shift(a_wvf_lows)
    array.shift(a_wvf_highs)
    array.shift(a_rangeHigh_lows)
    array.shift(a_rangeLow_highs)
    array.shift(a_upperBand_lows)
    array.shift(a_lowerBand_highs)
    array.shift(a_colorBars_lows)
    array.shift(a_colorBars_highs)
    array.shift(a_reverted_lows)
    array.shift(a_reverted_highs)
    array.shift(a_bar_index)
    array.shift(a_low)
    array.shift(a_high)


// ─────────────────────────────────────────────────────────────────────────────
//  HISTOGRAM — DRAW
// ─────────────────────────────────────────────────────────────────────────────
if barstate.islast
    n           = array.size(a_wvf_lows)
    lowestLow   = array.min(a_low)
    highestHigh = array.max(a_high)
    pad         = barHeight * 0.20

    maxL = array.max(a_wvf_lows)
    maxH = math.abs(array.min(a_wvf_highs))
    wMax = math.max(maxL, maxH, 0.001)

    // ── Track baselines for the WVFix label (computed outside loop) ──────────
    // In combined mode both series share one baseline; in split mode they differ.
    // We derive the same values the loop uses, without needing a loop variable.
    float labelBaseLows  = bSplit
         ? (bFlip ? highestHigh + pad : lowestLow  - pad)
         : (vAnchor > 0 ? vAnchor     : lowestLow  - barHeight * 1.20)
    float labelBaseHighs = bSplit
         ? (bFlip ? lowestLow  - pad  : highestHigh + pad)
         : labelBaseLows   // combined: same baseline as lows

    // X position: 7 bars to the right of the last collected bar
    int lastBi   = array.get(a_bar_index, n - 1)
    int labelX   = lastBi + 7

    for i = 0 to n - 1
        vL  = array.get(a_wvf_lows,        i)
        vH  = array.get(a_wvf_highs,       i)
        rHL = array.get(a_rangeHigh_lows,  i)
        rLH = array.get(a_rangeLow_highs,  i)
        ubL = array.get(a_upperBand_lows,  i)
        lbH = array.get(a_lowerBand_highs, i)
        cbL = array.get(a_colorBars_lows,  i)
        cbH = array.get(a_colorBars_highs, i)
        rvL = array.get(a_reverted_lows,   i)
        rvH = array.get(a_reverted_highs,  i)
        bi  = array.get(a_bar_index,       i)

        sL   = (math.abs(vL)  / wMax) * barHeight
        sH   = (math.abs(vH)  / wMax) * barHeight
        sRHL = (math.abs(rHL) / wMax) * barHeight
        sRLH = (math.abs(rLH) / wMax) * barHeight
        sUBL = (math.abs(ubL) / wMax) * barHeight
        sLBH = (math.abs(lbH) / wMax) * barHeight

        float baseLows  = na
        float baseHighs = na

        if bSplit
            baseLows  := bFlip ? highestHigh + pad : lowestLow  - pad
            baseHighs := bFlip ? lowestLow  - pad  : highestHigh + pad
        else
            baseLows  := vAnchor > 0 ? vAnchor : lowestLow - barHeight * 1.20
            baseHighs := baseLows

        // ── LOWS box ──────────────────────────────────────────────────────────
        colL = cbL                 ? col_wvf_lows_extreme :
               bShowRevert and rvL ? col_wvf_lows_revert  :
               col_wvf_lows_normal

        float topL    = na
        float bottomL = na
        if bSplit
            topL    := bFlip ? baseLows + sL : baseLows
            bottomL := bFlip ? baseLows      : baseLows - sL
        else
            topL    := bFlip ? baseLows      : baseLows + sL
            bottomL := bFlip ? baseLows - sL : baseLows

        box.new(bi, topL, bi + 0, bottomL,
             bgcolor = colL, border_color = color.new(colL, 80), border_width = 4)

        // ── HIGHS box ─────────────────────────────────────────────────────────
        colH = cbH                 ? col_wvf_highs_extreme :
               bShowRevert and rvH ? col_wvf_highs_revert  :
               col_wvf_highs_normal

        float topH    = na
        float bottomH = na
        if bSplit
            topH    := bFlip ? baseHighs      : baseHighs
            bottomH := bFlip ? baseHighs - sH : baseHighs + sH
        else
            topH    := bFlip ? baseLows + sH : baseLows
            bottomH := bFlip ? baseLows      : baseLows - sH

        box.new(bi, topH, bi + 0, bottomH,
             bgcolor = color.new(colH, 60), border_color = color.new(colH, 80), border_width = 4)

        // ── Range lines ───────────────────────────────────────────────────────
        if hp
            float yRHL = na
            float yRLH = na
            if bSplit
                yRHL := bFlip ? baseLows  + sRHL : baseLows  - sRHL
                yRLH := bFlip ? baseHighs - sRLH : baseHighs + sRLH
            else
                yRHL := bFlip ? baseLows - sRHL : baseLows + sRHL
                yRLH := bFlip ? baseLows + sRLH : baseLows - sRLH
            line.new(bi, yRHL, bi + 1, yRHL, color = col_rangeLine_lows,  width = 2, extend = extend.none)
            line.new(bi, yRLH, bi + 1, yRLH, color = col_rangeLine_highs, width = 2, extend = extend.none)

        // ── SD bands ──────────────────────────────────────────────────────────
        if sd
            float yUBL = na
            float yLBH = na
            if bSplit
                yUBL := bFlip ? baseLows  + sUBL : baseLows  - sUBL
                yLBH := bFlip ? baseHighs - sLBH : baseHighs + sLBH
            else
                yUBL := bFlip ? baseLows - sUBL : baseLows + sUBL
                yLBH := bFlip ? baseLows + sLBH : baseLows - sLBH
            line.new(bi, yUBL, bi + 1, yUBL, color = col_sdBand_lows,  width = 3, extend = extend.none)
            line.new(bi, yLBH, bi + 1, yLBH, color = col_sdBand_highs, width = 3, extend = extend.none)

    // ── WVFix label — always at the bottom baseline ───────────────────────────
    // label_up anchors the tip of the label to the Y coordinate, so the label
    // body sits above (or below) the baseline without overlapping the bars.
    Title1 = label.new(labelX, labelBaseLows,
         text      = 'WVFix',
         style     = label.style_label_up,
         color     = color.new(color.white, 100),
         textcolor = color.white,
         size      = size.normal)
    label.delete(Title1[1])     

    // ── Second label at the top baseline — only in split mode ─────────────────
    if bSplit
        Title2 = label.new(labelX, labelBaseHighs,
             text      = 'WVFix',
             style     = label.style_label_down,
             color     = color.new(color.white, 100),
             textcolor = color.white,
             size      = size.normal)
        label.delete(Title2[1])

// ─────────────────────────────────────────────────────────────────────────────
//  ALERT LINE PLOTS
// ─────────────────────────────────────────────────────────────────────────────
plot(sa1T and bool(alert1T) ? alert1T : 0, title = 'Alert: Top = True',             color = color.new(color.red,     0))
plot(sa2T and bool(alert2T) ? alert2T : 0, title = 'Alert: Top Now False',          color = color.new(color.aqua,    0))
plot(sa3T and bool(alert3T) ? alert3T : 0, title = 'Alert: Filtered Short',         color = color.new(color.fuchsia, 0))
plot(sa4T and bool(alert4T) ? alert4T : 0, title = 'Alert: Aggressive Short',       color = color.new(color.orange,  0))
plot(sa1B and bool(alert1B) ? alert1B : 0, title = 'Alert: Bottom = True',          color = color.new(color.lime,    0))
plot(sa2B and bool(alert2B) ? alert2B : 0, title = 'Alert: Bottom Now False',       color = color.new(color.aqua,    0))
plot(sa3B and bool(alert3B) ? alert3B : 0, title = 'Alert: Filtered Long',          color = color.new(color.fuchsia, 0))
plot(sa4B and bool(alert4B) ? alert4B : 0, title = 'Alert: Aggressive Long',        color = color.new(color.orange,  0))

plot(alert1_lows,  title = 'Hist Alert 1 Lows (WVF Extreme)',  color = Clear, display = display.none)
plot(alert2_lows,  title = 'Hist Alert 2 Lows (Filtered)',     color = Clear, display = display.none)
plot(alert3_lows,  title = 'Hist Alert 3 Lows (Full Filter)',  color = Clear, display = display.none)
plot(alert4_lows,  title = 'Hist Alert 4 Lows (Aggressive)',   color = Clear, display = display.none)
plot(alert1_highs, title = 'Hist Alert 1 Highs (WVF Extreme)', color = Clear, display = display.none)
plot(alert2_highs, title = 'Hist Alert 2 Highs (Filtered)',    color = Clear, display = display.none)
plot(alert3_highs, title = 'Hist Alert 3 Highs (Full Filter)', color = Clear, display = display.none)
plot(alert4_highs, title = 'Hist Alert 4 Highs (Aggressive)',  color = Clear, display = display.none)

alertcondition(TestBool_lows,  title = 'Williams Green Bar (LOWS)',  message = '{{ticker}} Williams Green Bar Signal (LOWS) {{interval}}')
alertcondition(TestBool_highs, title = 'Williams Green Bar (HIGHS)', message = '{{ticker}} Williams Green Bar Signal (HIGHS) {{interval}}')
````

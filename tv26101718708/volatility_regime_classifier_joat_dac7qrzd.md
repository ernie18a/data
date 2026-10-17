# Volatility Regime Classifier [JOAT]

- url: https://www.tradingview.com/script/dAC7QrzD-Volatility-Regime-Classifier-JOAT/
- type: indicator
- pine_id: PUB;35f238df17034db4875e34b5bb61bdbe
- version: 1.0

## Description

[b]Volatility Regime Classifier [JOAT][/b]

[b]Introduction[/b]

The Volatility Regime Classifier is an overlay indicator that continuously classifies the current market environment into one of four distinct volatility regimes — [b]TRENDING[/b], [b]RANGING[/b], [b]VOLATILE[/b], or [b]MIXED[/b] — and adapts its visual output accordingly. Rather than simply measuring how much volatility is present, this indicator identifies [i]what type[/i] of volatility environment is active, a distinction that is directly relevant to strategy selection.

The classification is built on three independent measures — ATR Z-score, ATR percentile, and EMA directional ratio — each capturing a different dimension of market behavior. Their combination produces a regime map that is both statistically grounded and practically actionable.

---
[image]https://www.tradingview.com/x/9IfDpwp0/[/image]

[b]Core Concepts[/b]

[b]1. ATR Z-Score — Detecting Statistically Extreme Volatility[/b]

The Z-score measures how far the current ATR deviates from its own historical mean, in units of standard deviation:

[pine]
atrZ = (atr14 - ta.sma(atr14, lookback)) / ta.stdev(atr14, lookback)
[/pine]

A Z-score above the [b]Volatile Z Threshold[/b] (default 2.0) means current volatility is more than two standard deviations above the recent average — a statistically uncommon spike. This is the trigger for the VOLATILE regime, indicating conditions where position sizing, stop distances, and strategy assumptions built around normal ranges may no longer apply.

The Z-score is a mean-reverting measure. An extreme reading does not tell you which direction price will move. It tells you the current volatility environment is atypical relative to recent history.

[b]2. ATR Percentile — Identifying Volatility Compression[/b]

The percentile ranks current ATR linearly within its own recent range:

[pine]
atrPercentile = (atr14 - ta.lowest(atr14, lookback)) / (ta.highest(atr14, lookback) - ta.lowest(atr14, lookback)) * 100
[/pine]

A percentile below the [b]Ranging Percentile[/b] threshold (default 35%) means ATR is near its lowest levels of the lookback window — a compression signal. This is the trigger for the RANGING regime, which historically precedes expansion but does not predict its direction or timing. It is a descriptor of the current state, not a forecast.

Using percentile rather than a fixed ATR threshold makes the measure adaptive: it adjusts to the instrument's own volatility character and the current lookback window.

[b]3. EMA Directional Ratio — Testing Movement Quality[/b]

Directional quality is measured by the separation between a fast and slow EMA, expressed in ATR units:

[pine]
directional = math.abs(ema_fast - ema_slow) / atr14 > dirStrength
[/pine]

When the EMA separation exceeds the [b]Directional Strength[/b] threshold (default 1.5 ATR units), the market is showing sustained, coherent movement in one direction relative to its current volatility level. This is the trigger for the TRENDING regime.

Expressing EMA separation in ATR units normalizes for volatility: a large EMA gap during a high-volatility period may be less directionally significant than the same gap during a low-volatility period.

[b]4. Regime Classification Logic[/b]

The three measures are evaluated in priority order:

[list]
[*][b]VOLATILE[/b] — if ATR Z-score exceeds the volatile threshold. Extreme volatility takes precedence over all other conditions.
[*][b]RANGING[/b] — else if ATR percentile is below the ranging threshold. Volatility compression is checked next.
[*][b]TRENDING[/b] — else if the EMA directional ratio is satisfied. Directional movement is confirmed if not in a spike or compression.
[*][b]MIXED[/b] — else. The market does not clearly fit any of the above categories: volatility is average, not directional, and not compressed.
[/list]

Regime transitions are confirmed on [pine]barstate.isconfirmed[/pine] bars only, preventing labels and state changes from appearing on unfinished candles.

[b]5. Adaptive Bands[/b]

Each regime applies a different ATR multiplier to a central EMA band:

[list]
[*][b]VOLATILE:[/b] multiplier 3.0 — wide bands reflecting extreme range
[*][b]TRENDING:[/b] multiplier 2.0 — moderate bands supporting trend context
[*][b]MIXED:[/b] multiplier 1.5 — standard bands for undifferentiated conditions
[*][b]RANGING:[/b] multiplier 1.0 — tight bands appropriate for compressed, mean-reverting conditions
[/list]

[pine]
upper = ema_center + baseMult * atr14
lower = ema_center - baseMult * atr14
[/pine]

The band envelope therefore scales automatically to the current regime, providing contextually appropriate support and resistance structure without manual adjustment.

[b]6. Smooth Color Transitions[/b]

Regime colors are smoothed by applying a 10-period EMA to each RGB channel independently. This prevents abrupt color jumps at regime boundaries and provides a visual blending effect as the market transitions between states. The smoothing period is fixed at 10 bars and is not user-configurable, as it is a presentational feature rather than an analytical one.

[b]7. Regime Transition Labels[/b]

A label is plotted at each confirmed regime change, marking the bar where the classification shifted. This creates a visual audit trail of regime history on the chart, allowing traders to review how conditions evolved across the session or swing.

[b]8. Information Table[/b]

A compact table in the top-right corner displays the current state of all key measurements:

[list]
[*]Current regime classification
[*]ATR value (absolute)
[*]ATR Z-score
[*]ATR percentile
[*]EMA trend direction (bullish/bearish based on fast vs slow EMA)
[*]Band width (upper minus lower)
[*]Directional threshold met (yes/no)
[*]Active band multiplier
[/list]

---

[b]Features[/b]

[list]
[*]Four-state regime classification: TRENDING, RANGING, VOLATILE, MIXED
[*]ATR Z-score for statistical volatility spike detection
[*]ATR percentile for volatility compression identification
[*]EMA directional ratio normalized to ATR units
[*]Priority-ordered regime logic with clear precedence rules
[*]Adaptive ATR-based bands that scale multiplier per regime
[*]Smooth RGB-channel EMA color blending at regime transitions
[*]Regime transition labels at every confirmed state change
[*]Per-bar color coding reflecting the active regime
[*]Background tint per regime (high transparency, non-intrusive)
[*]Real-time information table with all underlying metrics
[/list]

---

[b]Input Parameters[/b]

[list]
[*][b]ATR Length (default 14):[/b] Period for all ATR calculations. Shorter values make the Z-score and percentile more reactive; longer values smooth them out.
[*][b]Regime Lookback (default 100):[/b] The historical window used for Z-score (mean and standard deviation) and percentile (highest/lowest) calculations. Shorter lookbacks make the regime more sensitive to recent conditions; longer lookbacks require more extreme readings to trigger transitions.
[*][b]Volatile Z Threshold (default 2.0):[/b] ATR Z-score level required to trigger the VOLATILE regime. 2.0 corresponds to a two-standard-deviation event relative to the lookback window.
[*][b]Ranging Percentile (default 35%):[/b] ATR percentile below which the RANGING regime is triggered. Lower values require a tighter compression before classifying as ranging.
[*][b]Directional Strength (default 1.5):[/b] EMA separation threshold in ATR units required for the TRENDING regime. Higher values require a stronger, more sustained directional move.
[*][b]Fast EMA (default 20):[/b] Period for the fast EMA used in directional ratio and the band center.
[*][b]Slow EMA (default 50):[/b] Period for the slow EMA used in directional ratio.
[*][b]Band EMA (default 50):[/b] Period for the central EMA from which adaptive bands project. Can be set independently from the directional EMAs.
[/list]

---
[image]https://www.tradingview.com/x/DEVXhzOx/[/image]

[b]How to Use[/b]

[b]Regime-to-strategy mapping:[/b] The four regimes map to four broad strategy postures:

[list]
[*][b]TRENDING:[/b] Conditions are directional. Trend-following approaches — momentum entries, trailing stops, breakout continuation — have historically performed better in this state.
[*][b]RANGING:[/b] Volatility is compressed. Mean-reversion approaches — fading extremes, range-bound entries — are more aligned with this environment. Be aware that compression often precedes expansion.
[*][b]VOLATILE:[/b] Volatility is statistically extreme. Reduce position size. Wider-than-usual stops are required to avoid being shaken out by noise. Many strategies based on normal ATR assumptions will malfunction in this state.
[*][b]MIXED:[/b] No strong signal. Conditions do not clearly favor trending, ranging, or risk-off postures. Waiting for a clearer regime or reducing exposure are reasonable responses.
[/list]

[b]Reading the bands:[/b] The adaptive bands are not support/resistance in a traditional sense. They represent a contextually appropriate price envelope for the current regime. In ranging conditions, expect price to interact with the tight bands; in volatile conditions, the wider bands reflect the expanded true range.

[b]Using the table:[/b] The information table provides the underlying metric values at a glance. If a regime seems unexpected, check the raw Z-score, percentile, and directional values directly — this helps distinguish borderline cases from clear ones.

[b]Transition labels:[/b] Regime transition labels mark where conditions shifted on historical bars. Reviewing these labels on historical data can help calibrate whether the default thresholds suit a particular instrument and timeframe.

---

[b]Limitations[/b]

[list]
[*]All three underlying measures are based on ATR and EMA — both of which are lagging indicators. Regime classification reflects recently confirmed conditions, not instantaneous market state.
[*]The lookback window is critical to the behavior of both the Z-score and percentile. A short lookback makes the indicator reactive but prone to frequent transitions; a long lookback produces more stable regimes but may lag real condition changes.
[*]The four-state classification is a simplification of a continuous, multidimensional market reality. Real market conditions exist on a spectrum; the regime labels are useful approximations, not rigid categories.
[*]On instruments with low liquidity, thin volume, or irregular trading sessions (certain futures contracts, crypto on illiquid exchanges, small-cap equities), ATR behavior may be distorted by gaps or thin-market artifacts, producing unreliable Z-score and percentile readings.
[*]Regime classification performs best when applied within a single session or consistent trading context. Applying it across major session boundaries (e.g., Asia open to New York close on forex) without adjustment may produce spurious transitions driven by liquidity changes rather than structural market behavior.
[*]This indicator does not predict regime changes. It classifies the current regime after it has formed. The RANGING regime, for example, does not predict that expansion will occur — it describes that compression is currently present.
[*]No indicator, including this one, predicts future price direction or magnitude. Regime classification informs [i]which type of strategy is currently better aligned with conditions</i> — it does not guarantee that any strategy will be profitable.
[/list]

---

[b]Originality Statement[/b]

Many volatility indicators answer the question "how volatile is the market?" — ATR, Bollinger Band width, historical volatility, and similar tools all provide variants of this measurement. This indicator answers a different question: "what [i]type[/i] of volatility environment is the market currently in?"

The distinction matters because different volatility types require different responses. A spike in volatility during a strong trend calls for different handling than a spike caused by a news event in a ranging market. Compression before a directional breakout is a different environment than compression within an established range. The MIXED regime acknowledges that not all market conditions are clearly classifiable — a honesty that most binary volatility tools omit.

Three independent measures are combined by design, not convenience:

[b]The Z-score[/b] is statistical — it grounds the VOLATILE trigger in the instrument's own distributional history rather than an arbitrary fixed threshold.

[b]The percentile[/b] is rank-based and linear — it identifies compression relative to the full range of recent ATR values without being sensitive to individual outliers.

[b]The EMA directional ratio[/b] tests movement quality in ATR-normalized units — a common EMA crossover system would classify direction identically regardless of whether price is moving coherently or chopping. Normalizing to ATR removes that ambiguity.

The adaptive band multiplier is a direct mechanical expression of the regime classification — not a cosmetic addition. It means the envelope drawn on the chart is always scaled to the current environment, rather than applying a single fixed multiplier that is simultaneously too tight for volatile conditions and too wide for ranging ones.

---

[b]Disclaimer[/b]

[i]This indicator is provided for informational and educational purposes only. It does not constitute financial advice, investment advice, or a recommendation to buy or sell any asset. Regime classification describes current market conditions based on historical data — it does not predict future conditions, price direction, or strategy outcomes. All trading involves risk. You are solely responsible for your own trading decisions.[/i]

-Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Volatility Regime Classifier [JOAT]", shorttitle="VRC [JOAT]", overlay=true)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grpATR  = "ATR & Regime"
atrLen          = input.int(14, "ATR Length", minval=1, maxval=50, group=grpATR)
regimeLookback  = input.int(100, "Regime Lookback", minval=20, maxval=500, group=grpATR)
zVolThresh      = input.float(2.0, "Volatile Z-Score Threshold", minval=1.0, maxval=5.0, step=0.1, group=grpATR)
rangePercentile = input.float(35.0, "Ranging Percentile Threshold", minval=5.0, maxval=60.0, step=1.0, group=grpATR)
dirStrength     = input.float(1.5, "Directional Strength (EMA Ratio)", minval=0.5, maxval=5.0, step=0.1, group=grpATR)

grpEMA  = "EMA Settings"
emaFast = input.int(20, "Fast EMA", minval=5, maxval=100, group=grpEMA)
emaSlow = input.int(50, "Slow EMA", minval=10, maxval=300, group=grpEMA)
emaBand = input.int(50, "Band EMA (center)", minval=10, maxval=200, group=grpEMA)

grpBand = "Adaptive Bands"
showBands = input.bool(true, "Show Adaptive Bands", group=grpBand)
showFill  = input.bool(true, "Band Fill", group=grpBand)
showBG    = input.bool(true, "Regime Background", group=grpBand)

grpTbl  = "Table"
showTbl = input.bool(true, "Show Regime Table", group=grpTbl)
tblPos  = input.string("top_right", "Table Position",
  options=["bottom_left","bottom_right","top_left","top_right"], group=grpTbl)

// ─────────────────────────────────────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────────────────────────────────────
bullColor  = color.rgb(92, 240, 215)
bearColor  = color.rgb(179, 42, 195)
volatileC  = color.rgb(255, 80, 80)
rangeC     = color.rgb(130, 140, 160)
mixedC     = color.rgb(200, 160, 50)
bgDark     = color.rgb(10, 14, 22)
textLight  = color.rgb(220, 225, 235)
textDim    = color.rgb(100, 110, 130)

// ─────────────────────────────────────────────────────────────────────────────
// ATR CALCULATIONS
// ─────────────────────────────────────────────────────────────────────────────
atr14     = ta.atr(atrLen)
atrSMA    = ta.sma(atr14, regimeLookback)
atrStdev  = ta.stdev(atr14, regimeLookback)
safeAtrSD = math.max(atrStdev, syminfo.mintick)
atrZ      = (atr14 - atrSMA) / safeAtrSD

// ATR Percentile (0–100) via min/max linear normalization
atrHigh      = ta.highest(atr14, regimeLookback)
atrLow       = ta.lowest(atr14, regimeLookback)
atrRange     = math.max(atrHigh - atrLow, syminfo.mintick)
atrPercentile = (atr14 - atrLow) / atrRange * 100.0

// ─────────────────────────────────────────────────────────────────────────────
// EMA TREND DIRECTION
// ─────────────────────────────────────────────────────────────────────────────
ema_fast    = ta.ema(close, emaFast)
ema_slow    = ta.ema(close, emaSlow)
ema_center  = ta.ema(close, emaBand)

atr14ForDir = math.max(ta.atr(14), syminfo.mintick)
directional = math.abs(ema_fast - ema_slow) / atr14ForDir > dirStrength
emaAbove    = ema_fast > ema_slow
emaTrend    = emaAbove ? "BULL" : "BEAR"

// ─────────────────────────────────────────────────────────────────────────────
// REGIME CLASSIFICATION
// ─────────────────────────────────────────────────────────────────────────────
regime = atrZ > zVolThresh ? "VOLATILE" :
  atrPercentile < rangePercentile ? "RANGING" :
  directional ? "TRENDING" : "MIXED"

// ─────────────────────────────────────────────────────────────────────────────
// ADAPTIVE BAND WIDTH BY REGIME
// ─────────────────────────────────────────────────────────────────────────────
baseMult   = regime == "VOLATILE" ? 3.0 :
  regime == "RANGING" ? 1.0 :
  regime == "TRENDING" ? 2.0 : 1.5

upperAdapt = ema_center + baseMult * atr14
lowerAdapt = ema_center - baseMult * atr14

// ─────────────────────────────────────────────────────────────────────────────
// REGIME COLOR MAPPING
// ─────────────────────────────────────────────────────────────────────────────
regimeColor = regime == "TRENDING" ? (emaAbove ? bullColor : bearColor) :
  regime == "VOLATILE" ? volatileC :
  regime == "RANGING"  ? rangeC : mixedC

// ─────────────────────────────────────────────────────────────────────────────
// BACKGROUND TINT
// ─────────────────────────────────────────────────────────────────────────────
bgTint = regime == "TRENDING" ? color.new(emaAbove ? bullColor : bearColor, 95) :
  regime == "VOLATILE" ? color.new(volatileC, 95) :
  regime == "RANGING"  ? color.new(rangeC, 96) :
  color.new(mixedC, 97)

bgcolor(showBG ? bgTint : na)

// ─────────────────────────────────────────────────────────────────────────────
// SMOOTH COLOR TRANSITION FOR PLOTS
// ─────────────────────────────────────────────────────────────────────────────
targetR  = float(color.r(regimeColor))
targetG  = float(color.g(regimeColor))
targetB  = float(color.b(regimeColor))
smoothR  = ta.ema(targetR, 10)
smoothG  = ta.ema(targetG, 10)
smoothB  = ta.ema(targetB, 10)
smoothC  = color.rgb(int(smoothR), int(smoothG), int(smoothB))

// ─────────────────────────────────────────────────────────────────────────────
// BAR COLORING BY REGIME
// ─────────────────────────────────────────────────────────────────────────────
barcolor(color.new(regimeColor, 60))

// ─────────────────────────────────────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────────────────────────────────────
pCenter = plot(ema_center, "EMA Center", color=color.new(smoothC, 30), linewidth=2)
pFast   = plot(ema_fast,   "EMA Fast",   color=color.new(smoothC, 55), linewidth=1)
pSlow   = plot(ema_slow,   "EMA Slow",   color=color.new(smoothC, 55), linewidth=1)

pUpper  = plot(showBands ? upperAdapt : na, "Upper Adaptive",
  color=color.new(regimeColor, 45), linewidth=1)
pLower  = plot(showBands ? lowerAdapt : na, "Lower Adaptive",
  color=color.new(regimeColor, 45), linewidth=1)

fill(pUpper, pCenter, upperAdapt, ema_center,
     showFill ? color.new(regimeColor, 88) : na, showFill ? color.new(regimeColor, 96) : na)
fill(pCenter, pLower, ema_center, lowerAdapt,
     showFill ? color.new(regimeColor, 96) : na, showFill ? color.new(regimeColor, 88) : na)

fill(pFast, pSlow, ema_fast, ema_slow,
  emaAbove ? color.new(bullColor, 90) : color.new(bearColor, 90),
  emaAbove ? color.new(bullColor, 95) : color.new(bearColor, 95))

// ─────────────────────────────────────────────────────────────────────────────
// REGIME TRANSITION MARKERS
// ─────────────────────────────────────────────────────────────────────────────
var string prevRegime = ""
regimeChanged = regime != prevRegime and barstate.isconfirmed
if regimeChanged
    prevRegime := regime
    labelText = regime
    labelStyle = regime == "VOLATILE" ? label.style_label_down :
      regime == "RANGING" ? label.style_label_center :
      label.style_label_up
    label.new(bar_index, regime == "VOLATILE" ? high + atr14 : low - atr14,
      text=labelText,
      style=labelStyle,
      color=color.new(regimeColor, 20),
      textcolor=regime == "RANGING" ? bgDark : color.white,
      size=size.tiny)

// ─────────────────────────────────────────────────────────────────────────────
// ANALYSIS TABLE
// ─────────────────────────────────────────────────────────────────────────────
var table tbl = na
if showTbl
    tblPosition = tblPos == "bottom_left"  ? position.bottom_left  :
      tblPos == "bottom_right" ? position.bottom_right :
      tblPos == "top_left"     ? position.top_left     : position.top_right

    if na(tbl)
        tbl := table.new(tblPosition, 2, 9,
          bgcolor=color.new(bgDark, 15),
          border_color=color.new(textDim, 70),
          border_width=1,
          frame_color=color.new(textDim, 50),
          frame_width=1)

    table.cell(tbl, 0, 0, "VRC [JOAT]", text_color=textLight,
      bgcolor=color.new(bgDark, 5), text_size=size.small,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(tbl, 1, 0, syminfo.ticker, text_color=bullColor,
      bgcolor=color.new(bgDark, 5), text_size=size.small,
      text_font_family=font.family_monospace, text_halign=text.align_right)

    table.cell(tbl, 0, 1, "Regime", text_color=textDim, text_size=size.small,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(tbl, 1, 1, regime, text_color=regimeColor, text_size=size.small,
      text_font_family=font.family_monospace, text_halign=text.align_right)

    table.cell(tbl, 0, 2, "ATR Value", text_color=textDim, text_size=size.small,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(tbl, 1, 2, str.tostring(atr14, "#.####"), text_color=textLight,
      text_size=size.small, text_font_family=font.family_monospace, text_halign=text.align_right)

    table.cell(tbl, 0, 3, "ATR Z-Score", text_color=textDim, text_size=size.small,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    atrZCol = atrZ > zVolThresh ? volatileC : atrZ > 1.0 ? mixedC : atrZ < 0 ? rangeC : textLight
    table.cell(tbl, 1, 3, str.tostring(atrZ, "#.##"), text_color=atrZCol,
      text_size=size.small, text_font_family=font.family_monospace, text_halign=text.align_right)

    table.cell(tbl, 0, 4, "ATR Percentile", text_color=textDim, text_size=size.small,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    pctileCol = atrPercentile > 75 ? volatileC : atrPercentile < 35 ? rangeC : textLight
    table.cell(tbl, 1, 4, str.tostring(atrPercentile, "#.#") + "%", text_color=pctileCol,
      text_size=size.small, text_font_family=font.family_monospace, text_halign=text.align_right)

    table.cell(tbl, 0, 5, "EMA Trend", text_color=textDim, text_size=size.small,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(tbl, 1, 5, emaTrend, text_color=emaAbove ? bullColor : bearColor,
      text_size=size.small, text_font_family=font.family_monospace, text_halign=text.align_right)

    bandWidth = upperAdapt - lowerAdapt
    table.cell(tbl, 0, 6, "Band Width", text_color=textDim, text_size=size.small,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(tbl, 1, 6, str.tostring(bandWidth, "#.####"), text_color=textLight,
      text_size=size.small, text_font_family=font.family_monospace, text_halign=text.align_right)

    table.cell(tbl, 0, 7, "Directional", text_color=textDim, text_size=size.small,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    dirStr = directional ? "YES" : "NO"
    dirCol = directional ? bullColor : rangeC
    table.cell(tbl, 1, 7, dirStr, text_color=dirCol,
      text_size=size.small, text_font_family=font.family_monospace, text_halign=text.align_right)

    table.cell(tbl, 0, 8, "Band Mult", text_color=textDim, text_size=size.small,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(tbl, 1, 8, str.tostring(baseMult, "#.#") + "x", text_color=regimeColor,
      text_size=size.small, text_font_family=font.family_monospace, text_halign=text.align_right)

// ─────────────────────────────────────────────────────────────────────────────
// ALERT CONDITIONS
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(regime == "VOLATILE" and regime != regime[1], title="VRC [JOAT] Volatile",  message="VRC [JOAT]: VOLATILE regime on {{ticker}} — ATR Z-Score spiked above threshold.")
alertcondition(regime == "TRENDING" and regime != regime[1], title="VRC [JOAT] Trending",  message="VRC [JOAT]: TRENDING regime on {{ticker}} — directional expansion confirmed.")
alertcondition(regime == "RANGING"  and regime != regime[1], title="VRC [JOAT] Ranging",   message="VRC [JOAT]: RANGING regime on {{ticker}} — low ATR percentile contraction.")
````

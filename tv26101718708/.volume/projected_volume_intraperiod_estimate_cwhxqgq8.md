# Projected Volume (Intraperiod Estimate)

- url: https://www.tradingview.com/script/CWhXqGq8-Projected-Volume-Intraperiod-Estimate/
- type: indicator
- pine_id: PUB;fb2c8e094a374ad4ab4293f58fc46bf1
- version: 1.0

## Description

[b]Projected Volume (Intraperiod Estimate)[/b]
════════════════════════════════════════

[b]OVERVIEW[/b]

Projected Volume replaces the standard volume study with a live, forward-looking
estimate of where the current bar's volume is likely to finish. Volume is only
known with certainty once a bar closes, which makes it hard to judge in real time
whether the bar in progress is trading heavy or light. This indicator solves that
by drawing the volume already traded as a solid column and projecting the
remaining, not-yet-traded volume as a hollow cap on top — so the anticipated
final volume of the developing bar is visible at a glance. The projection is
rebuilt on every update of the live bar and adapts to your chart timeframe and to
the data your subscription can access.


[b]WHAT IT PLOTS[/b]

• Directional volume columns on every bar — green when close ≥ open, red when
  close < open (the standard volume read you already use).
• On the current, unfinished bar only:
   – a solid column for the volume traded so far;
   – a hollow outline extending from the top of the solid column up to the
     projected final volume;
   – an optional label with the projected total and the percent of the period
     elapsed.

As the bar fills in, the solid portion grows and the hollow cap shrinks toward
zero. At the close, projected equals actual.


[b]HOW THE PROJECTION WORKS[/b]

The indicator uses two methods and selects between them automatically based on
whether sub-bar (intrabar) data is available.

1) Intraperiod volume profile — primary method

For each of the last N completed bars, the script requests lower-timeframe
volume and measures how volume accumulates through the period: what fraction of
the period's total volume is typically complete by the end of each time-slice —
the classic "how much of the day's volume is usually done by the first hour, the
second hour…" shape. That cumulative curve is averaged across the lookback window
to form a typical accumulation profile.

For the developing bar the script determines how far through the period it has
progressed, reads the typical cumulative fraction f at that point, and estimates:

     [i] projected total = volume so far ÷ f[/i]

Because the profile captures the real intraperiod shape — the U-shaped session
volume common in equities, or the flatter distribution of 24/7 crypto — the
estimate reflects typical behavior rather than assuming volume arrives at a
constant rate.

2) Average-of-increment — base-resolution fallback

When the chart is already at the lowest interval your data plan provides (for
example a 1-minute chart on a plan without seconds data), there is no sub-bar to
sample and the profile method does not apply. In that case the script projects:

      [i]projected total = volume so far + (1 − elapsed) × average volume of last N bars[/i]

This equals a typical bar early in the period, tracks the realized volume as the
bar fills, always sits at or above the volume already traded, and converges to
the actual figure at the close. It requires no lower-timeframe data and cannot
error. Elapsed time is measured from the clock, so no sub-bar feed is needed.

[b]Automatic method selection[/b]

The script detects whether a usable lower timeframe exists that your plan can
serve. If so, it uses the profile method — and floors sub-sampling at one minute,
so 5m / 15m / 1h charts still build a genuine profile from 1-minute intrabars. If
not, it uses the average-of-increment fallback. The active method is shown in the
on-chart label, where a "· avg" suffix denotes fallback mode.


[b]SETTINGS[/b]

• [b]Intraperiod slices (12 / 24 / 48)[/b] — number of time-slices used to model the
  accumulation curve within each period. 24 is roughly hourly on a daily chart.
• [b]Lookback periods[/b] — number of completed bars averaged for the profile and the
  fallback average (default 30).
• [b]Auto sub-period timeframe[/b] — when on, the script chooses the intrabar sampling
  resolution automatically. Turn off to set it manually.
• [b]Manual sub-period timeframe[/b] — used when Auto is off; must be lower than the
  chart timeframe.
• [b]Allow seconds sub-sampling[/b] — off by default. Enable only if your plan provides
  seconds data; when off, the script never requests sub-minute data and therefore
  cannot error on a 1-minute chart.
• [b]Min % elapsed before projecting[/b] — suppresses unstable projections in the
  opening moments of a new bar.
• Up / Down volume colors and a toggle for the projection label.


[b]READING THE LABEL[/b]

The label reads, for example, "Proj 1.2M (35% elapsed)" — the projected final
volume and how far the current period has progressed. A "· avg" suffix indicates
the average-of-increment fallback is active because intrabar data is unavailable
at that resolution.


[b]BEHAVIOR, NOTES & LIMITATIONS[/b]

• Real-time by design. The projection exists only on the current, unfinished bar
  and recalculates as that bar develops. Historical bars display actual traded
  volume only — the indicator does not restate closed bars, but the live estimate
  moves tick to tick as new volume arrives. This is expected behavior for a
  forward projection, not hidden repainting.
• It is an estimate, not a guarantee. Accuracy is lowest in the first fraction of
  a new bar and improves as the bar fills; the "Min % elapsed" input guards the
  earliest, noisiest moments.
• The profile method depends on intrabar data availability, which varies by
  symbol and subscription. Where it is unavailable, the indicator degrades
  gracefully to the average-based method.
• Works across asset classes and timeframes. Because elapsed progress is measured
  from intrabar count where available (and otherwise from the clock), it adapts to
  both continuous (crypto) and session-based (equities/futures) markets.
• Volume reflects the data feed of the chart's symbol; index or aggregated tickers
  may report volume differently from a single exchange.


[b]CONCEPT[/b]

The tool pairs a standard directional volume histogram with an
intraperiod-accumulation model and presents the realized-versus-projected split
visually as a filled column plus a hollow cap. The aim is a single, glanceable
read on whether the bar in progress is on pace to finish heavy or light relative
to recent norms.

## Source Code

````pine
//@version=6
// =============================================================================
//  Projected Volume (Intraperiod Estimate)
// -----------------------------------------------------------------------------
//  What it does
//  ------------
//  Standard volume columns (green = close >= open, red = close < open), PLUS a
//  live projection of the FINAL volume for the current, unfinished bar.
//
//  The solid column is the REAL volume traded so far in the current period.
//  A hollow outline extends from the top of the solid column up to the
//  PROJECTED total for the full period. As the period fills in, the solid part
//  grows and the hollow (projected) cap shrinks toward zero.
//
//  How the projection is built
//  ---------------------------
//  For each of the last `Lookback` COMPLETED periods, the script pulls
//  lower-timeframe (intrabar) volume and measures how volume accumulates
//  through the period -- i.e. what fraction of the period's total volume has
//  typically been done by the end of slice 1, slice 2, ... slice N
//  (the "first hour, second hour, ..." distribution you described).
//  It averages that cumulative curve over the lookback window.
//
//  For the current bar it measures how far through the period we are, reads the
//  typical cumulative fraction at that point (call it f), and projects:
//        projected_total = volume_so_far / f
//
//  Base-resolution fallback
//  ------------------------
//  If the chart is already at the lowest interval your data plan allows (e.g. a
//  1-minute chart with no seconds data), there is no sub-bar to sample. The
//  script detects this automatically and instead projects:
//        projected_total = volume_so_far + (1 - elapsed) * avg(volume, Lookback)
//  This needs no lower-timeframe data and never errors. Elapsed time comes from
//  the wall clock. Seconds sub-sampling is OFF by default; enable it in Settings
//  only if your plan actually provides seconds data.
//
//  Works on any chart timeframe (day, hour, minute, etc.). The intraperiod
//  "slices" and the sub-period timeframe are configurable in Settings.
// =============================================================================

indicator("Projected Volume (Intraperiod Estimate)", shorttitle = "Vol Proj", overlay = false, format = format.volume, max_boxes_count = 20, max_labels_count = 20)

// ----------------------------------------------------------------------------- Inputs
grpP = "Projection"
slices       = input.int(24, "Intraperiod slices", options = [12, 24, 48], group = grpP, tooltip = "How many equal time-slices to model within each period. 24 ~ hourly on a daily chart. More slices = finer curve.")
lookback     = input.int(30, "Lookback periods", minval = 5, maxval = 100, group = grpP, tooltip = "How many completed periods to average when building the typical volume curve.")
autoLtf      = input.bool(true, "Auto sub-period timeframe", group = grpP, tooltip = "When ON, the script picks a sensible lower timeframe for the intrabar sampling. Turn OFF to set it yourself below.")
manualLtf    = input.timeframe("60", "Manual sub-period timeframe", group = grpP, tooltip = "Used only when Auto is OFF. Must be lower than the chart timeframe.")
subMinute    = input.bool(false, "Allow seconds sub-sampling", group = grpP, tooltip = "OFF by default. Enable only if your data plan provides seconds resolution. When OFF, the script never requests sub-minute data, so it cannot error on a 1-minute chart -- at your plan's lowest interval it uses the average-of-increment fallback instead.")
minElapsePct = input.float(1.0, "Min % elapsed before projecting", minval = 0.1, maxval = 50.0, step = 0.5, group = grpP, tooltip = "Suppresses wild projections in the first moments of a new period.")

grpS = "Style"
upColor     = input.color(#26a69a, "Up volume",   group = grpS)
downColor   = input.color(#ef5350, "Down volume", group = grpS)
showLabel   = input.bool(true, "Show projection label (total + % elapsed)", group = grpS)

// ----------------------------------------------------------------------------- Helpers
// Abbreviate a volume number for the label: 1.23K / 4.5M / 6.7B
f_fmt(float v) =>
    av = math.abs(v)
    av >= 1e9 ? str.tostring(v / 1e9, "#.##") + "B" :
      av >= 1e6 ? str.tostring(v / 1e6, "#.##") + "M" :
      av >= 1e3 ? str.tostring(v / 1e3, "#.##") + "K" :
      str.tostring(v, "#.#")

// Interpolate the averaged cumulative curve `cpArr` (n checkpoints, value at
// elapsed fraction (b+1)/n) at an arbitrary elapsed fraction `ef` in [0,1].
f_interp(array<float> cpArr, int n, float ef) =>
    x  = math.min(math.max(ef, 0.0), 1.0) * n
    m0 = int(math.floor(x))
    w  = x - m0
    lowV  = m0 <= 0 ? 0.0 : array.get(cpArr, m0 - 1)
    highV = (m0 + 1) <= n ? array.get(cpArr, m0) : array.get(cpArr, n - 1)
    val = lowV + w * (highV - lowV)
    math.min(1.0, math.max(0.0001, val))

// ----------------------------------------------------------------------------- Timeframe selection
int   S         = slices
float periodSec = timeframe.in_seconds()          // seconds in one chart bar (simple int)
float target    = periodSec / S                    // desired seconds per slice

// Largest standard resolution <= target (gives at least S intrabars per period).
// Written as an inline ternary so the result stays a "simple string" that
// request.security_lower_tf() will accept.
string autoLtfStr = target >= 604800 ? "1W" :
      target >= 86400 ? "1D" :
      target >= 14400 ? "240" :
      target >= 10800 ? "180" :
      target >= 7200  ? "120" :
      target >= 3600  ? "60"  :
      target >= 2700  ? "45"  :
      target >= 1800  ? "30"  :
      target >= 900   ? "15"  :
      target >= 300   ? "5"   :
      target >= 180   ? "3"   :
      target >= 60    ? "1"   :
      target >= 30    ? "30S" :
      target >= 15    ? "15S" :
      target >= 10    ? "10S" :
      target >= 5     ? "5S"  : "1S"

// Never sample below 1 minute unless the user explicitly opts in. Most plans
// have no seconds data, and requesting an unavailable seconds resolution is what
// breaks 1-minute charts. Flooring the auto pick at "1" lets 5m/15m/1h charts
// still build a real profile from 1-minute intrabars.
bool   rawIsSeconds = timeframe.in_seconds(autoLtfStr) < 60
string flooredLtf   = (not subMinute and rawIsSeconds) ? "1" : autoLtfStr
string wantLtf      = autoLtf ? flooredLtf : manualLtf
string useLtf       = wantLtf

// The intraperiod-profile method only works when a usable LOWER timeframe exists
// that the plan can serve. If not (chart is at the plan's floor, e.g. 1m without
// seconds data), profileEnabled stays false and we use the average fallback.
bool ltfIsLower     = timeframe.in_seconds(useLtf) < periodSec
bool ltfAllowed     = subMinute or timeframe.in_seconds(useLtf) >= 60
bool profileEnabled = ltfIsLower and ltfAllowed

// ----------------------------------------------------------------------------- Intrabar request (only when a usable lower timeframe exists)
// Start with an empty array (never na, so array.size() is always safe). The
// request runs only when profileEnabled, so no seconds request is ever issued
// at the plan's base resolution. ignore_invalid_timeframe = true is a second
// safety net. Chronological order (index 0 = earliest intrabar).
array<float> ltfVol = array.new_float(0)
if profileEnabled
    ltfVol := request.security_lower_tf(syminfo.tickerid, useLtf, volume, ignore_invalid_timeframe = true)

// ----------------------------------------------------------------------------- Per-bar cumulative profile (cp)
int nBarNow = array.size(ltfVol)
array<float> cp = array.new_float(S, na)
bool cpValid = false

if nBarNow > 0
    float total = array.sum(ltfVol)
    if total > 0
        array<float> bucket = array.new_float(S, 0.0)
        for i = 0 to nBarNow - 1
            int b = math.min(S - 1, int(math.floor((i + 0.5) / nBarNow * S)))
            array.set(bucket, b, array.get(bucket, b) + array.get(ltfVol, i))
        float run = 0.0
        for b = 0 to S - 1
            run += array.get(bucket, b)
            array.set(cp, b, run / total)   // cumulative fraction by end of slice b
        cpValid := true

// ----------------------------------------------------------------------------- Rolling window of completed-bar profiles (flat ring buffer)
var array<float> ring = array.new_float(0)   // row-major, each row = S values
var int ringCount = 0
var int ringHead  = 0

if cpValid and barstate.isconfirmed
    if ringCount < lookback
        for b = 0 to S - 1
            array.push(ring, array.get(cp, b))
        ringCount += 1
    else
        int base = ringHead * S
        for b = 0 to S - 1
            array.set(ring, base + b, array.get(cp, b))
        ringHead := (ringHead + 1) % lookback

bool hasProfile = ringCount >= math.min(5, lookback)

// ----------------------------------------------------------------------------- How far through the current period are we?
float periodMs   = periodSec * 1000.0
float wallFrac   = (timenow - time) / periodMs                 // wall-clock fraction
float typicalN   = ta.sma(nBarNow[1], lookback)                // typical intrabar count of a completed period
float barsFrac   = (not na(typicalN) and typicalN > 0 and nBarNow > 0) ? nBarNow / typicalN : na
float elapsedRaw = not na(barsFrac) ? barsFrac : wallFrac      // prefer intrabar-count (session-agnostic)
float elapsedFrac = math.min(1.0, math.max(0.0, elapsedRaw))
float minElapsed  = minElapsePct / 100.0

// ----------------------------------------------------------------------------- Direction / realized volume
bool  up       = close >= open
color dirColor = up ? upColor : downColor
float realized = volume
float avgVol   = ta.sma(volume[1], lookback)   // avg volume of last N completed bars (base-resolution fallback)

// ----------------------------------------------------------------------------- Solid realized-volume columns (all bars)
plot(realized, "Volume", style = plot.style_columns, color = color.new(dirColor, 0))

// ----------------------------------------------------------------------------- Projection: hollow cap + label on the last bar
bool projShow = barstate.islast and elapsedFrac >= minElapsed and elapsedFrac < 0.999 and realized > 0

// These stay na except on the in-progress last bar, so nothing draws elsewhere.
float projBot = na          // bottom of the hollow cap = realized volume so far
float projTop = na          // top of the hollow cap    = projected full-period volume
string projTxt = ""

if projShow
    float projected = na
    if hasProfile
        // Intraperiod-profile method: divide realized volume by the typical
        // cumulative fraction of the period's volume done by this point.
        array<float> avgCP = array.new_float(S, na)
        for b = 0 to S - 1
            float s = 0.0
            for r = 0 to ringCount - 1
                s += array.get(ring, r * S + b)
            array.set(avgCP, b, s / ringCount)
        float profileFrac = math.max(f_interp(avgCP, S, elapsedFrac), 0.02)
        projected := realized / profileFrac
    else
        // Base-resolution fallback (no lower timeframe available): realized so
        // far, plus an average bar's worth scaled by the time remaining.
        projected := na(avgVol) ? na : realized + (1.0 - elapsedFrac) * avgVol
    if not na(projected)
        projBot := realized
        projTop := math.max(projected, realized)
        projTxt := "Proj " + f_fmt(projTop) + "  (" + str.tostring(elapsedFrac * 100, "#") + "% elapsed" + (hasProfile ? "" : " · avg") + ")"

// Hollow outline drawn as a transparent-body candle. Native plots are centered
// on the bar, so this lines up exactly with the solid volume column (no x-offset).
plotcandle(projBot, projTop, projBot, projTop, title = "Projected volume", color = na, wickcolor = na, bordercolor = dirColor)

// Projection label, anchored by bar_index so it sits directly over the current bar.
var label projLabel = na
if projShow and showLabel and not na(projTop)
    if na(projLabel)
        projLabel := label.new(bar_index, projTop, projTxt, style = label.style_label_down, color = color.new(dirColor, 65), textcolor = color.white, size = size.small)
    else
        label.set_xy(projLabel, bar_index, projTop)
        label.set_text(projLabel, projTxt)
        label.set_color(projLabel, color.new(dirColor, 65))
else
    if not na(projLabel)
        label.delete(projLabel)
        projLabel := na
````

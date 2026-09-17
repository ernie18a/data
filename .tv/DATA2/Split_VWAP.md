<!-- tradingview-pine-id: PUB;21dd86810b8845c3b50bebee20bd1480 -->
<!-- tradingview-pine-version: 5.0 -->
<!-- tradingviewscripts-format: 1 -->
# Split VWAP

Source: https://www.tradingview.com/script/v2BhTtjK-Split-VWAP/

## Description

What it does

Split VWAP cuts every bar horizontally at the session VWAP and draws it as two candles at the same position: one spanning the low up to VWAP, one spanning VWAP up to the high. Each partial takes the bar's open and close clamped into its own range, and a share of the bar's volume proportional to its height. Where VWAP sits at or beyond a bar's extreme, one partial collapses to zero height and the other takes the whole bar and all of its volume; the collapsed one is hidden by default.

A single candle gives you four prices and one volume total, but says nothing about how that activity was distributed relative to the session's average price. Splitting the bar at VWAP and attributing volume to each side makes that distribution visible.

How the colouring works

Each partial is coloured from two changes, both measured against the previous bar's partial on the same side of VWAP: the change in attributed volume, and the change in clamped close.

In the default mode, "Volume hue OKLCh", each change gets a channel of its own. The volume change moves the hue along a continuum — red (
#ea6c5c, hue 29) when it fell, green (
#05b28d, hue 171) when it held, blue (
#7b8efa, hue 274) when it rose. The price change moves the lightness: lighter when the close rose, darker when it fell.

All three anchors sit at an OKLCh lightness of 0.680 and hold as much chroma as their hue can carry at that lightness, capped at 0.16 so the ends do not shout over the middle. Green is the quiet one because green simply cannot hold as much. OKLCh is used rather than HSL because HSL treats lightness as a function of the hue you happen to be on, so a fixed magnitude renders brighter on some hues than others; in OKLCh, lightness, chroma and hue move independently.

Bodies are hollow when the partial's clamped close is above its clamped open, and solid otherwise. A dot marks the VWAP level itself, coloured by the same scheme applied to the whole bar.

Three further modes are included — Quadrant intensity, Bilinear blend and Polar OKLCh. These read the two changes as four corner colours instead of two channels, one per sign combination, and use magnitude to drive chroma and opacity. Every corner and anchor colour is an input.

Scaling

Every series is normalised against the dispersion of its own bar-to-bar changes: 2.5x the mean absolute change over a lookback, which is roughly two standard deviations for a well-behaved distribution but far less sensitive to the occasional volume spike.

Measuring each series against itself matters more than it sounds. A partial carries only a fraction of the bar's volume, so normalising its volume change against the whole bar's average volume compresses that axis and leaves the colour field stuck near the middle. In the other direction, half the ATR is smaller than a typical close-to-close move, so the price axis clips on a large share of bars. It also gives the VWAP-pinned partial a usable scale: when a bar closes above VWAP the lower partial's close is pinned to the cut, so its only movement is VWAP drift — small in absolute terms, but perfectly legible against its own dispersion.

The consequence worth holding on to while reading the chart: the colour says how unusual a change is for that partial, not how large it is in absolute terms.

Setup

The script paints over the chart's native candles, but Pine cannot hide the chart symbol itself. For the cleanest result, right-click the chart, open Settings -> Symbol, and uncheck Body, Borders and Wick.

Settings worth knowing

Gradient mode — the four schemes described above.
Price lightness span — how far a full-strength price change moves the lightness off the anchor, in OKLCh lightness. Default 0.16. A wider span reads more decisively but costs colour at both ends, because sRGB is widest in the middle and narrows toward black and toward white. Rather than let the channels clip, the requested chroma is fitted to whatever the lightness and hue can actually carry, so bright bars are pastel and dark bars are saturated.
Response ramp — how quickly the colour responds as a change grows. 1.0 is proportional; the default 0.6 reaches most of the response earlier, so only genuinely quiet bars stay washed out.
Price change scale / Volume change scale — the lookbacks for the two normalisers.
Transparency at no change — how far quiet bars recede. Lower it if the quiet end reads too faint.

Limitations

Volume attribution is proportional to segment height, not measured from intrabar data. It is a shape-preserving approximation, not a true intrabar volume profile.
The VWAP is session-anchored, so the split level resets at each session boundary and the first bars of a session sit close to it.
On a strongly trending session, price can run far enough from the session VWAP that one partial collapses on most bars and the display degrades toward ordinary candles. That is expected behaviour rather than a fault.
The script requires a symbol that reports volume, and raises a runtime error on symbols that report none.

Originality

This is original work. The bar splitting, the volume attribution, the per-partial normalisation, and the OKLCh colour handling — including the OKLab conversions and the chroma fitting, neither of which Pine provides — are implemented from scratch. No third-party code is reused.

---

## Source Code

````pine
//@version=6
// Generated by build.py from src/indicator.pine. Do not edit.
// Edit the sources under src/ and re-run: python3 build.py
indicator("Split VWAP", "Split VWAP", overlay = true, behind_chart = false, explicit_plot_zorder = true)

import alodis/OKLCh/1 as oklch

// >>> begin core.pine (from indicator.pine:6)
// ===========================================================================
// core.pine -- pure logic shared by the indicator and the test harness.
//
// A fragment, not a standalone script: build.py splices it into
// src/indicator.pine and src/test.pine so both run identical code.
// ===========================================================================

// Quadrant identifiers for the sign combinations of the price and volume
// change against the previous same-side partial.
const int Q_UP_VOL_UP = 0
const int Q_DOWN_VOL_UP = 1
const int Q_UP_VOL_DOWN = 2
const int Q_DOWN_VOL_DOWN = 3

// Gradient modes. See gradientColor at the bottom of this file.
const int MODE_QUADRANT = 0
const int MODE_BILINEAR = 1
const int MODE_POLAR = 2
const int MODE_VOLUME_HUE = 3

// A vertical slice of a bar: bounds [l, h], the bar's open and close clamped
// into those bounds, and the slice's share of the bar's volume.
type Partial
    float l
    float h
    float o
    float c
    float v

// One of the two candles a bar is drawn as. `upper` says which side of the
// split level it takes its color from; the geometry alone cannot say, because
// the two overlap.
type Segment
    float o
    float h
    float l
    float c
    bool upper

type Palette
    color upVolUp
    color downVolUp
    color upVolDown
    color downVolDown
    color neutral
    int minTransp
    int maxTransp
    int mode
    float armWidth
    float responseRamp
    // Volume-hue mode only: the three anchors the volume change sweeps the hue
    // between, and how far below them a price-down bar renders.
    color volFalling = na
    color volFlat = na
    color volRising = na
    float lightSpan = 0.0

clampToRange(float v_, float l_, float h_) =>
    math.max(l_, math.min(h_, v_))

// Share of the bar's volume that belongs below `level`, proportional to the
// height of the lower slice. A zero-height bar has no meaningful split, so it
// divides evenly.
lowerVolumeFraction(float l_, float h_, float level) =>
    float span = h_ - l_
    float fraction = span > 0 ? (clampToRange(level, l_, h_) - l_) / span : 0.5
    fraction

// Cuts a bar horizontally at `level`, returning the below-level and
// above-level partials. A level outside the bar's range is clamped into it,
// which collapses one partial to zero height and gives the other everything.
// Missing volume is treated as zero so the geometry still stands when a
// symbol does not report any, and a missing level hands the whole bar to the
// lower partial rather than leaving the result to na arithmetic.
splitAtLevel(float o_, float h_, float l_, float c_, float v_, float level) =>
    // A missing level is not a split at all, so the lower partial takes the
    // whole bar and the upper collapses at the high. That matches
    // splitForDisplay, which draws such a bar whole and colors it from the
    // below-level side, and it leaves the color reading the bar's own change
    // rather than whatever na arithmetic would have produced.
    float at = na(level) ? h_ : level
    float cut = clampToRange(at, l_, h_)
    float vol = nz(v_)
    float lowerVolume = vol * lowerVolumeFraction(l_, h_, at)
    Partial lower = Partial.new(l_, cut, clampToRange(o_, l_, cut), clampToRange(c_, l_, cut), lowerVolume)
    Partial upper = Partial.new(cut, h_, clampToRange(o_, cut, h_), clampToRange(c_, cut, h_), vol - lowerVolume)
    [lower, upper]

// The two candles a bar is drawn as, in draw order, cut at `level`.
//
// `splitAtLevel` is the right partition for attributing price and volume, but
// the wrong one to draw: when the level sits outside the body, one partial
// collapses to a zero-height dash and the wick on that side is lost with it.
// Drawing the pieces so they overlap instead solves both. The piece carrying
// the close is drawn last, over the other, and only its own side of the level
// is left uncovered:
//
//   - level inside the body: the body is cut at the level and each half keeps
//     the wick on its own side. The two pieces meet without overlapping.
//   - level outside the body: the far piece is stretched to the near edge of
//     the body -- a flat dash with the whole wick under it -- and the body
//     piece is clipped at the level and drawn on top. What survives is the
//     wick up to the level in one color and everything above it in the other,
//     with the dash hidden under the body's border.
//   - level past the bar entirely: the clip is a no-op, the body piece covers
//     the whole range, and the other never shows.
//
// A bar with no level to cut it at is drawn whole, as the last piece.
splitForDisplay(float o_, float h_, float l_, float c_, float level) =>
    Segment first = na
    Segment last = na
    if na(level)
        first := Segment.new(na, na, na, na, false)
        last := Segment.new(o_, h_, l_, c_, false)
    else if c_ >= o_
        if level <= o_
            first := Segment.new(o_, o_, l_, o_, false)
            last := Segment.new(o_, h_, math.max(l_, level), c_, true)
        else if level >= c_
            first := Segment.new(c_, h_, c_, c_, true)
            last := Segment.new(o_, math.min(h_, level), l_, c_, false)
        else
            first := Segment.new(o_, level, l_, level, false)
            last := Segment.new(level, h_, level, c_, true)
    else
        if level <= c_
            first := Segment.new(c_, c_, l_, c_, false)
            last := Segment.new(o_, h_, math.max(l_, level), c_, true)
        else if level >= o_
            first := Segment.new(o_, h_, o_, o_, true)
            last := Segment.new(o_, math.min(h_, level), l_, c_, false)
        else
            first := Segment.new(o_, h_, level, level, true)
            last := Segment.new(level, level, l_, c_, false)
    [first, last]

// An unchanged or missing delta counts as "down", matching the way an
// unchanged open and close renders as a solid body.
classifyQuadrant(float dP, float dV) =>
    bool priceUp = dP > 0
    bool volUp = dV > 0
    int quadrant = priceUp ? (volUp ? Q_UP_VOL_UP : Q_UP_VOL_DOWN) : (volUp ? Q_DOWN_VOL_UP : Q_DOWN_VOL_DOWN)
    quadrant

// Change in an accumulating series against the same fraction of the previous
// bar, where `pace` is the share of the forming bar that has run.
//
// Volume on an unconfirmed bar is a partial sum: it starts near zero and
// climbs, so a plain difference reads as a collapse for most of the bar's life
// and only becomes true at the close. Against a matching fraction of the
// previous bar, a bar accumulating at last bar's rate reads as no change
// instead. The result is the full-bar projection multiplied by `pace`, so it
// carries the right sign from early on but is damped by exactly the confidence
// there is in it, and the bar starts neutral and firms up rather than starting
// at the extreme and walking back.
//
// A pace of 1 leaves a plain difference, na propagation included, so every
// confirmed bar is untouched. Price needs none of this: a close is a real
// current price at every instant, not a partial sum.
pacedDelta(float current, float previous, float pace) =>
    current - clampToRange(nz(pace, 1.0), 0.0, 1.0) * previous

// Scale that maps a series of bar-to-bar changes onto [-1, 1]: 2.5x the mean
// absolute change, which is close to two standard deviations for a well
// behaved distribution but is far less sensitive to the occasional volume
// spike than ta.stdev would be.
//
// Each series must be measured against its own dispersion. A partial's close
// is clamped into its own slice of the bar and its volume is a fraction of the
// bar's, so scales borrowed from the whole bar leave both weights short of the
// ends of the range and waste most of the palette.
deltaScale(float delta, int length) =>
    2.5 * ta.sma(math.abs(nz(delta)), length)

// Normalizes the raw deltas onto [-1, 1] so color intensity is comparable
// across symbols. A missing or non-positive scale yields a neutral weight
// rather than an unbounded one.
blendWeights(float dP, float dV, float pScale, float vScale) =>
    float priceScale = nz(pScale)
    float volScale = nz(vScale)
    float priceWeight = priceScale > 0 ? math.max(-1.0, math.min(1.0, dP / priceScale)) : 0.0
    float volWeight = volScale > 0 ? math.max(-1.0, math.min(1.0, dV / volScale)) : 0.0
    [nz(priceWeight), nz(volWeight)]

isHollow(float o_, float c_) =>
    c_ > o_

// Fades a body against the color it is drawn from. Transparency composes on
// the remaining opacity, so a body `transp` transparent over a color the
// gradient already faded stays the fainter of the two. `color.new` alone would
// set it absolutely and throw the gradient's own ramp away, leaving a quiet
// bar's fill more opaque than its own border.
fadeBody(color c, float transp) =>
    float base = color.t(c)
    color.new(c, base + (100.0 - base) * transp / 100.0)

cornerColor(Palette p, int q) =>
    switch q
        Q_UP_VOL_UP => p.upVolUp
        Q_DOWN_VOL_UP => p.downVolUp
        Q_UP_VOL_DOWN => p.upVolDown
        => p.downVolDown

// The corners bounding one 90-degree sector of the weight plane. Sector 0
// starts at the up/volume-up corner and they run anticlockwise from there,
// which is the order the corners sit in around the plane.
sectorCorners(Palette p, int sector) =>
    color from_ = switch sector
        0 => p.upVolUp
        1 => p.downVolUp
        2 => p.downVolDown
        => p.upVolDown
    color to_ = switch sector
        0 => p.downVolUp
        1 => p.downVolDown
        2 => p.upVolDown
        => p.upVolUp
    [from_, to_]

// Eases the sweep across a sector so more of it stays near the anchor hue and
// the transition between anchors is quicker. Widens the recognizable wedge of
// each quadrant without introducing a discontinuity. 1.0 is a plain linear
// sweep; lower values widen further.
armEase(float t, float width) =>
    float eased = t
    if width < 1.0
        float exponent = 1.0 / width
        float a = math.pow(t, exponent)
        float b = math.pow(1.0 - t, exponent)
        eased := a + b > 0.0 ? a / (a + b) : t
    eased

// Hue from the direction of the change, chroma and lightness from its size.
// The corner directions land on their palette color exactly: the sector
// parameter is zero there and the magnitude is one.
polarColor(Palette p, float priceWeight, float volWeight, float magnitude) =>
    float angle = oklch.wrapHue(oklch.atan2Degrees(volWeight, priceWeight) - 45.0)
    int sector = int(math.min(3.0, math.floor(angle / 90.0)))
    float t = armEase((angle - sector * 90.0) / 90.0, p.armWidth)
    [fromColor, toColor] = sectorCorners(p, sector)
    [fromL, fromC, fromH] = oklch.colorToOklch(fromColor)
    [toL, toC, toH] = oklch.colorToOklch(toColor)
    [neutralL, neutralC, neutralH] = oklch.colorToOklch(p.neutral)
    float hue = oklch.wrapHue(fromH + t * oklch.shortestHueArc(fromH, toH))
    float chroma = (fromC + t * (toC - fromC)) * math.pow(magnitude, p.responseRamp)
    float lightness = neutralL + magnitude * (fromL + t * (toL - fromL) - neutralL)
    oklch.oklchToColor(lightness, chroma, hue)

// Hue from the volume change, one of two lightness bands from the price
// change.
//
// The volume weight sweeps the hue along one continuum: the falling anchor at
// -1, the flat anchor at 0, the rising anchor at +1. Each arm is interpolated
// on its own, so the two need not cover the same distance around the wheel.
// The price change then picks a band: up renders at the anchors' own lightness,
// down a `lightSpan` below it. The split is deliberately binary. Direction is
// the thing being read here, and grading it by size only made small moves
// ambiguous while costing the anchors their exact color.
//
// Dropping below the anchors' lightness costs chroma, because sRGB is widest
// in the middle and narrows toward both ends. The chroma the anchors ask for is
// therefore fitted to what is available in the band the price lands in; the
// light band is the anchors' own, so it always holds what they ask for.
volumeHueColor(Palette p, float priceWeight, float volWeight) =>
    color endAnchor = volWeight >= 0.0 ? p.volRising : p.volFalling
    float t = math.min(1.0, math.abs(volWeight))
    [flatL, flatC, flatH] = oklch.colorToOklch(p.volFlat)
    [endL, endC, endH] = oklch.colorToOklch(endAnchor)
    float hue = oklch.wrapHue(flatH + t * oklch.shortestHueArc(flatH, endH))
    float chroma = flatC + t * (endC - flatC)
    float anchorL = flatL + t * (endL - flatL)
    // The price change picks one of two bands rather than sliding between
    // them. The anchors are the light band, so an up bar reproduces the input
    // color exactly and a down bar is the same hue a span darker. An
    // unchanged change counts as down, the convention the whole script uses --
    // see classifyQuadrant and isHollow. A missing one lands there too, since
    // gradientColor has already turned it into a zero weight.
    float lightness = clampToRange(priceWeight > 0.0 ? anchorL : anchorL - p.lightSpan, 0.0, 1.0)
    oklch.oklchToColor(lightness, oklch.fitChroma(lightness, chroma, hue), hue)

// Quadrant mode keeps the four hues exact and lets magnitude drive saturation
// and opacity, so a quiet bar washes out toward neutral. Magnitude is
// Euclidean and scaled so only the true corners of the weight square reach
// full strength; a move on one axis alone stays off the vertex.
//
// Bilinear mode blends the four corners continuously along the shortest hue
// arc. It is kept for continuity, but the hue field it produces has two
// singular columns: one where the two rows share a hue and the whole column
// flattens, another where they are antipodal and the shortest arc flips.
// Neither sits at the center unless the corner hues are chosen to put it
// there.
//
// Polar mode reads the weights as an angle and a radius rather than as two
// independent axes, which is what they are. Angle picks the hue by
// interpolating around the four corners in OKLCh, radius drives chroma and
// lightness. The center is achromatic by construction, so there is no
// singular column and no collision between "no change" and a real corner.
//
// Volume-hue mode drops the four corners entirely and gives each axis its own
// visual channel: hue for the volume change, one of two lightness bands for the
// price change. Nothing is left for magnitude to fade toward, so "no change" is
// the flat anchor darkened rather than gray, and both axes stay readable at
// once instead of collapsing into a single direction-and-distance reading.
//
// The quadrant and polar ramps raise magnitude to `responseRamp` before it
// drives color, so an exponent below one reaches most of the corner's
// colorfulness earlier and only the genuinely quiet bars stay washed out. It
// deliberately does not touch the rim: at a shared lightness two of the four
// default hues already sit on the sRGB boundary, so pushing chroma past the
// corner value would clip them while the other two kept going. Volume-hue mode
// does not read it at all: its lightness split is binary, so there is nothing
// for an exponent to reshape. Transparency follows the raw magnitude in every
// mode, so a palette can use it as an independent lever -- or flatten it by
// setting both ends the same, which is what the split candles need, since a
// faded candle cannot hide the one it is drawn over.
gradientColor(Palette p, float pW, float vW) =>
    float priceWeight = nz(pW)
    float volWeight = nz(vW)
    float magnitude = math.min(1.0, math.sqrt(priceWeight * priceWeight + volWeight * volWeight) / math.sqrt(2.0))
    float ramp = p.maxTransp - magnitude * (p.maxTransp - p.minTransp)
    int transparency = int(math.round(math.max(0, math.min(100, ramp))))
    color result = na
    if p.mode == MODE_BILINEAR
        color volUpRow = oklch.mixHueGradient(priceWeight, -1.0, 1.0, p.downVolUp, p.upVolUp)
        color volDownRow = oklch.mixHueGradient(priceWeight, -1.0, 1.0, p.downVolDown, p.upVolDown)
        result := color.new(oklch.mixHueGradient(volWeight, -1.0, 1.0, volDownRow, volUpRow), p.minTransp)
    else if p.mode == MODE_POLAR
        result := color.new(polarColor(p, priceWeight, volWeight, magnitude), transparency)
    else if p.mode == MODE_VOLUME_HUE
        result := color.new(volumeHueColor(p, priceWeight, volWeight), transparency)
    else
        color corner = cornerColor(p, classifyQuadrant(priceWeight, volWeight))
        result := color.new(oklch.mixHueGradient(math.pow(magnitude, p.responseRamp), 0.0, 1.0, p.neutral, corner), transparency)
    result
// <<< end core.pine

const string GRAD_QUADRANT = "Quadrant intensity"
const string GRAD_BILINEAR = "Bilinear blend"
const string GRAD_POLAR = "Polar OKLCh"
const string GRAD_VOLUME_HUE = "Volume hue OKLCh"

const string LEVEL_SESSION = "Session VWAP"
const string LEVEL_ANCHORED = "Anchored VWAP"
const string LEVEL_ROLLING = "Rolling VWAP"

const string PERIOD_WEEK = "Week"
const string PERIOD_MONTH = "Month"
const string PERIOD_QUARTER = "Quarter"
const string PERIOD_YEAR = "Year"

// Volume hue mode splits lightness in two and has no use for a response ramp.
// Polar and quadrant mode still raise magnitude to this before it drives
// chroma, so it stays a constant at the value they shipped with rather than an
// input that would do nothing in the default mode.
const float RESPONSE_RAMP = 0.6

// ===========================================================================
// Inputs
//
// Everything here is `display.none`: the settings dialog is where these are
// read, and echoing them next to the script title only crowds the status line.
// input.bool and input.color already default to that, so only the
// value-bearing inputs have to say so.
// ===========================================================================

string levelMode = input.string(LEVEL_SESSION, "Split level", options = [LEVEL_SESSION, LEVEL_ANCHORED, LEVEL_ROLLING], tooltip = "Where the cut goes. Session VWAP restarts on each day change, which is the level traders watch, but on daily and higher charts that change fires every bar, so the level collapses onto the bar's own source price and says nothing. Anchored VWAP restarts on a period you choose instead, which keeps the anchored meaning as long as the period is longer than the chart's timeframe; it has no value until the first anchor is reached, so the start of a chart can be blank for up to one period. Rolling VWAP is a volume-weighted average of the last N bars. It never restarts, so it has no reset discontinuity, but it is a moving average rather than a level anyone is watching.", group = "VWAP", display = display.none)
string anchorPeriod = input.string(PERIOD_MONTH, "Anchor period", options = [PERIOD_WEEK, PERIOD_MONTH, PERIOD_QUARTER, PERIOD_YEAR], tooltip = "Anchored VWAP only: where the accumulation restarts. It has to be longer than the chart's timeframe, and the chart is blank until the first one is reached.", group = "VWAP", display = display.none)
int rollingLength = input.int(20, "Rolling window (bars)", minval = 2, tooltip = "Rolling VWAP only: how many bars the volume-weighted average covers.", group = "VWAP", display = display.none)
float vwapSource = input.source(hl2, "VWAP source", group = "VWAP", display = display.none)
bool showDot = input.bool(true, "Mark the VWAP level with a dot", group = "VWAP")
int dotSize = input.int(2, "Dot size", minval = 1, maxval = 4, group = "VWAP", display = display.none)

string gradientMode = input.string(GRAD_VOLUME_HUE, "Gradient mode", options = [GRAD_VOLUME_HUE, GRAD_QUADRANT, GRAD_BILINEAR, GRAD_POLAR], tooltip = "Volume hue OKLCh gives each change its own channel: hue runs on a continuum from red through green to blue as the volume change goes from falling to rising, and a price rise renders in the anchor color itself while a fall renders a step darker. Polar OKLCh instead reads the two as an angle and a distance: the angle picks the hue, the distance drives chroma, and no change is gray. Quadrant intensity keeps the four corner hues exact and fades toward neutral. Bilinear blend interpolates between the corners along each axis.", group = "Gradient", display = display.none)
float armWidth = input.float(0.8, "Polar arm width", minval = 0.3, maxval = 1.0, step = 0.05, tooltip = "How much of each quadrant stays close to its corner color in polar mode. 1.0 sweeps the hue evenly; lower values widen the recognizable wedge and make the transitions between quadrants quicker.", group = "Gradient", display = display.none)
int priceScaleLength = input.int(20, "Price change scale (bars)", minval = 2, tooltip = "Lookback for the average absolute change in each partial's close. Each partial is measured against its own dispersion, so the pinned side and the free side both use the full color range.", group = "Gradient", display = display.none)
int volumeScaleLength = input.int(20, "Volume change scale (bars)", minval = 2, tooltip = "Lookback for the average absolute change in each partial's attributed volume.", group = "Gradient", display = display.none)
int minTransparency = input.int(0, "Split candle transparency", minval = 0, maxval = 100, tooltip = "Flat transparency for the two split candles. The piece carrying the close is drawn over the other and has to be opaque to hide it, so anything above 0 lets the covered piece show through as a darker band on the far wick. Magnitude still reads through chroma and lightness.", group = "Gradient", display = display.none)
int maxTransparency = input.int(75, "Dot transparency at no change", minval = 0, maxval = 100, tooltip = "The VWAP dot alone still fades with the size of the change, from this value at no change to the split candle transparency at a full one. Bilinear blend is the exception and has always been: it does not ramp transparency, so its dot sits at the candle value throughout.", group = "Gradient", display = display.none)

// Four hues a quarter turn apart in OKLCh, in the order the quadrants sit
// around the weight plane, at a shared lightness of 0.71 and a shared chroma
// of 0.164. Even spacing is what polar mode assumes and keeps every quadrant
// boundary equally visible; the shared lightness stops one quadrant looking
// stronger than another at equal magnitude.
//
// The set is rotated to the angle where all four hues can hold the most
// chroma. sRGB is lumpy, and the obvious rotations sit in a trough: at the
// green-teal end the weakest corner tops out near 0.129, so this one is worth
// about 40% more color without giving up any of the properties above.
//
// A useful side effect is that both price-up corners land on cool hues and
// both price-down corners on warm ones, so the price direction reads before
// any individual color has been learned. The cost is that red no longer marks
// price-down/volume-up. That is unavoidable rather than a choice: the two
// price-up corners are adjacent in the plane, so no evenly spaced wheel can
// put both on the same side of a red/green split.
color colorUpVolUp = input.color(#05acfd, "Price up, volume up", group = "Colors")
color colorDownVolUp = input.color(#da77d0, "Price down, volume up", group = "Colors")
color colorUpVolDown = input.color(#3fbd69, "Price up, volume down", group = "Colors")
color colorDownVolDown = input.color(#e98506, "Price down, volume down", group = "Colors")
color colorNeutral = input.color(#808080, "No change", group = "Colors")
int bodyTransparency = input.int(80, "Up-body fill transparency", minval = 0, maxval = 100, tooltip = "How much of an up body is filled. 100 is a fully hollow body, 0 fills it like a down body. The default leaves a faint wash so an up body reads as hollow while still hinting at its color.", group = "Colors", display = display.none)

// The volume-hue anchors, which are the colors an up bar renders in exactly.
// Falling is red on the orange side of the wheel (hue 29), rising is blue just
// shy of indigo (hue 274), and the flat anchor sits halfway between them at
// 151.5, so a rise and a fall of the same size travel the same distance round
// the wheel: 122.3 degrees one way, 122.4 the other. All three sit at a shared
// lightness of 0.68, so a down bar drops the same distance whatever the volume
// did, and all three hold a chroma near 0.16, which this green can carry at
// this lightness with room to spare.
color colorVolFalling = input.color(#ea6c5c, "Falling volume", group = "Volume hue ramp")
color colorVolFlat = input.color(#36b364, "Unchanged volume", group = "Volume hue ramp")
color colorVolRising = input.color(#7b8efa, "Rising volume", group = "Volume hue ramp")
float lightnessSpan = input.float(0.16, "Price down darkening", minval = 0.02, maxval = 0.35, step = 0.01, tooltip = "How far below the anchor color a down bar renders, in OKLCh lightness. The anchors are the light band, so an up bar is the input color exactly and a down bar is the same hue this much darker. A wider step separates the two more but costs the dark band chroma, because sRGB narrows toward black.", group = "Volume hue ramp", display = display.none)

int gradientModeId = gradientMode == GRAD_BILINEAR ? MODE_BILINEAR : gradientMode == GRAD_POLAR ? MODE_POLAR : gradientMode == GRAD_VOLUME_HUE ? MODE_VOLUME_HUE : MODE_QUADRANT

// The dot fades with the size of the change; the candles cannot. The split
// candles overlap, and the piece drawn on top only hides the piece beneath it
// if it is opaque -- a faded one composites instead, doubling the far wick and
// blending the two sides' hues there. So the candles get a palette whose
// transparency does not ramp, and magnitude reaches them through chroma and
// lightness alone. Both are still driven by the same gradient.
var Palette dotPalette = Palette.new(colorUpVolUp, colorDownVolUp, colorUpVolDown, colorDownVolDown, colorNeutral, minTransparency, maxTransparency, gradientModeId, armWidth, RESPONSE_RAMP, colorVolFalling, colorVolFlat, colorVolRising, lightnessSpan)
var Palette candlePalette = Palette.new(colorUpVolUp, colorDownVolUp, colorUpVolDown, colorDownVolDown, colorNeutral, minTransparency, minTransparency, gradientModeId, armWidth, RESPONSE_RAMP, colorVolFalling, colorVolFlat, colorVolRising, lightnessSpan)

// ===========================================================================
// Split
// ===========================================================================

// Every candidate is evaluated on every bar, and so is every period boundary.
// The selectors are inputs, so a branch on them would take the same arm on
// every bar and no accumulator could actually go stale; the reason is simply
// that Pine wants ta.* calls at the top level rather than inside a conditional,
// and two unused accumulators cost nothing.
bool newWeek = timeframe.change("1W")
bool newMonth = timeframe.change("1M")
bool newQuarter = timeframe.change("3M")
bool newYear = timeframe.change("12M")
bool anchorReset = anchorPeriod == PERIOD_MONTH ? newMonth : anchorPeriod == PERIOD_QUARTER ? newQuarter : anchorPeriod == PERIOD_YEAR ? newYear : newWeek

// The anchor has to be longer than the chart's own timeframe. If it is not,
// timeframe.change fires on every bar, the accumulation restarts every bar and
// the level collapses onto the source -- silently reproducing the very problem
// this option exists to fix. Three resets in a row can only mean that.
bool anchorDegenerate = anchorReset and anchorReset[1] and anchorReset[2]
if barstate.islast and levelMode == LEVEL_ANCHORED and anchorDegenerate
    runtime.error("Split VWAP: the anchor period has to be longer than the chart's timeframe, or the level restarts every bar and lands on the source price. Pick a longer Anchor period, or set Split level to Rolling VWAP.")

float sessionLevel = ta.vwap(vwapSource)
float anchoredLevel = ta.vwap(vwapSource, anchorReset)
float rollingLevel = ta.vwma(vwapSource, rollingLength)
float splitLevel = levelMode == LEVEL_ROLLING ? rollingLevel : levelMode == LEVEL_ANCHORED ? anchoredLevel : sessionLevel

// Missing volume (an index, a cash contract) is treated as zero: hue sits
// on the unchanged-volume anchor, and a VWAP that cannot be weighted is
// not a split.
[lowerPartial, upperPartial] = splitAtLevel(open, high, low, close, nz(volume), splitLevel)

// Copied out of the objects so the previous bar's values stay reachable with
// the history-referencing operator. Only the clamped close and the attributed
// volume feed the color; the partials' bounds are not what gets drawn.
float lowerClose = lowerPartial.c
float lowerVolume = lowerPartial.v
float upperClose = upperPartial.c
float upperVolume = upperPartial.v

// What is drawn is not the same partition as what is colored: the two display
// segments overlap so the wick on the far side of VWAP survives even when VWAP
// sits outside the body. See splitForDisplay in core.pine.
[firstSegment, lastSegment] = splitForDisplay(open, high, low, close, splitLevel)

// ===========================================================================
// Colors
// ===========================================================================

// Every series is normalized against the dispersion of its own changes. The
// bar's ATR and average volume are the wrong yardsticks for a partial: a
// partial carries a fraction of the bar's volume, so a bar-wide volume scale
// compressed that axis to a fraction of its range, while ATR/2 is smaller than
// a typical close-to-close move and clipped the price axis instead.
float lowerCloseDelta = lowerClose - lowerClose[1]
float upperCloseDelta = upperClose - upperClose[1]
float barCloseDelta = close - close[1]

// The share of the forming bar's clock that has run. Only the volume deltas
// use it, because only they accumulate; see pacedDelta in core.pine. A
// confirmed bar is already whole, and a bar that does not end on a wall clock
// -- tick charts, and the synthetic types where a bar closes on price instead
// -- has no fraction to read, so both stay at 1 and take a plain difference.
float barSpan = time_close - time
bool paceReadable = not barstate.isconfirmed and chart.is_standard and not timeframe.isticks and nz(barSpan) > 0
float barPace = paceReadable ? clampToRange((timenow - time) / barSpan, 0.0, 1.0) : 1.0

float lowerVolumeDelta = pacedDelta(lowerVolume, lowerVolume[1], barPace)
float upperVolumeDelta = pacedDelta(upperVolume, upperVolume[1], barPace)
float barVolume = nz(volume)
float barVolumeDelta = pacedDelta(barVolume, barVolume[1], barPace)

// Each of these carries its own ta.sma state, and all six are evaluated on
// every bar. Until the lookback fills they are na, which blendWeights reads as
// a zero weight, so the warmup bars render neutral rather than wrong.
float lowerPriceScale = deltaScale(lowerCloseDelta, priceScaleLength)
float upperPriceScale = deltaScale(upperCloseDelta, priceScaleLength)
float barPriceScale = deltaScale(barCloseDelta, priceScaleLength)
float lowerVolumeScale = deltaScale(lowerVolumeDelta, volumeScaleLength)
float upperVolumeScale = deltaScale(upperVolumeDelta, volumeScaleLength)
float barVolumeScale = deltaScale(barVolumeDelta, volumeScaleLength)

[lowerPriceWeight, lowerVolumeWeight] = blendWeights(lowerCloseDelta, lowerVolumeDelta, lowerPriceScale, lowerVolumeScale)
[upperPriceWeight, upperVolumeWeight] = blendWeights(upperCloseDelta, upperVolumeDelta, upperPriceScale, upperVolumeScale)
[barPriceWeight, barVolumeWeight] = blendWeights(barCloseDelta, barVolumeDelta, barPriceScale, barVolumeScale)

color lowerColor = gradientColor(candlePalette, lowerPriceWeight, lowerVolumeWeight)
color upperColor = gradientColor(candlePalette, upperPriceWeight, upperVolumeWeight)
color dotColor = gradientColor(dotPalette, barPriceWeight, barVolumeWeight)

// Each drawn segment takes the color of the side of VWAP it occupies, not of
// the side its own geometry happens to reach into.
color firstColor = firstSegment.upper ? upperColor : lowerColor
color lastColor = lastSegment.upper ? upperColor : lowerColor
color firstBody = isHollow(firstSegment.o, firstSegment.c) ? fadeBody(firstColor, bodyTransparency) : firstColor
color lastBody = isHollow(lastSegment.o, lastSegment.c) ? fadeBody(lastColor, bodyTransparency) : lastColor

// ===========================================================================
// Plots
// ===========================================================================

// Pine cannot hide the chart symbol itself. `barcolor` can only clear the
// native body; wicks and borders stay. The split candles sit in front
// (`behind_chart = false`), and the cover candle paints the rest with the
// chart background so hollow bodies do not show the native candle through them.
//
// The three candle plots are `display.pane`, which draws in the pane and
// nowhere else: no price-scale label, no status line entry, no Data Window
// column. Four candles' worth of OHLC would bury the one number worth reading.
// The VWAP plot alone keeps `display.all`, so the status line and the price
// scale carry the VWAP level.
//
// `barcolor` is the exception, and cannot be helped: its `display` takes only
// display.none or display.all, and display.none would stop it clearing the
// native body rather than merely quieten it. So it keeps its status line swatch.
barcolor(lastColor, title = "Hide chart body", editable = false)
plotcandle(open, high, low, close, title = "Hide chart bars", color = chart.bg_color, wickcolor = chart.bg_color, bordercolor = chart.bg_color, display = display.pane, editable = false)
plotcandle(firstSegment.o, firstSegment.h, firstSegment.l, firstSegment.c, title = "Split candle, opposite side", color = firstBody, wickcolor = firstColor, bordercolor = firstColor, display = display.pane)
plotcandle(lastSegment.o, lastSegment.h, lastSegment.l, lastSegment.c, title = "Split candle, closing side", color = lastBody, wickcolor = lastColor, bordercolor = lastColor, display = display.pane)
plot(showDot ? splitLevel : na, "VWAP", color = dotColor, style = plot.style_circles, linewidth = dotSize, display = display.all)
````

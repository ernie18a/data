# Daily VWAP Deviation Map

- url: https://www.tradingview.com/script/fH3DXeBr-Daily-VWAP-Deviation-Map/
- type: indicator
- pine_id: PUB;49c5f11d86ef4b4598c68f335374c0af
- version: 1.0

## Description

Daily VWAP Deviation Map plots the current exchange day's VWAP and volume-weighted standard-deviation bands around it.

The purpose of this script is to show how far price is trading from the day's volume-weighted mean. Distance is displayed in price units, percent, and sigma distance. This is a context and visualization tool. It does not provide trade-action instructions and it is not a trading system.

What it shows

- Daily VWAP based on the selected source, default hlc3.
- Inner, outer, and optional tail deviation bands.
- Sigma distance from the current day's VWAP.
- A neutral state model that describes price location relative to VWAP.
- A compact dashboard with state, sigma distance, percent distance, VWAP, and volume mode.
- Optional non-arrow event markers for factual band-crossing events.

How it works

At the start of each exchange day, the calculation resets and begins accumulating volume-weighted sums from the current chart bars.

The script maintains:

- cumulative volume
- cumulative price times volume
- cumulative price squared times volume
- session bar count

From these values, it calculates:

VWAP = cumulative price times volume / cumulative volume

variance = cumulative price squared times volume / cumulative volume - VWAP squared

sigma = square root of variance, guarded against rounding noise

The script then calculates:

- raw distance from VWAP
- percent distance from VWAP
- sigma distance from VWAP

All calculations use current chart bars only. The script does not use request.security(), lookahead, or future data. Historical values are not recalculated with future information.

Daily anchoring

The daily reset follows the chart symbol's exchange day and timezone. This reset is used only to anchor the VWAP calculation to the current day. It is not a session highlighter and it does not shade Tokyo, London, New York, or other trading sessions.

Deviation states

The dashboard uses neutral descriptive states:

- Warming up
- Near VWAP
- Inner range
- One-sigma edge
- Two-sigma extension
- Outer tail

These states describe current price location. They do not imply future reversal or continuation.

Bands and multipliers

The inner, outer, and tail band multipliers are user-configurable. The active outer tier is kept above the active inner tier, and the active tail tier is kept above the outer tier. Event markers and alerts follow the active inner and outer band tiers so they remain aligned with the displayed bands when users customize the multipliers.

Volume handling

When usable volume is available, the calculation is volume-weighted. If volume is missing or not positive and fallback is enabled, the script uses an equal-weight fallback so the display can remain continuous. The dashboard discloses this clearly.

The dashboard volume mode can show:

- Volume-weighted
- Equal-weight fallback
- No usable volume

On some symbols, especially certain FX or CFD feeds, volume may represent tick volume or may not be available. This affects how VWAP and deviation bands should be interpreted.

Events and alerts

Event markers are small, neutral, non-arrow plotshape markers. They describe factual events only, such as:

- crossed above the upper inner band
- crossed below the lower inner band
- crossed above the upper outer band
- crossed below the lower outer band
- returned inside from an upper or lower extension
- crossed VWAP

Alerts use the same neutral event logic. The default setting evaluates events on confirmed bars only to reduce intrabar repainting.

Customization

Users can adjust the dashboard position, layout density, text size, plot colors, table colors, marker colors, and transparency settings.

The default dashboard position is Top right padded. It keeps the panel in the upper-right area while using subtle internal spacing to reduce clutter near the chart's right-side price-scale labels. Users can switch to standard Top right or any other available table anchor.

The default layout is Compact for a clean chart. Standard and Detailed layouts are available for users who want more information.

Intended use

This indicator is designed for intraday charts. On daily or higher timeframes, the script avoids showing misleading daily VWAP deviation bands and displays an intraday-use notice instead.

Limitations

This script is not financial advice and not a trading system.

Distance from VWAP does not guarantee reversal or continuation.

Default settings are starting points, not optimized settings.

Early-session VWAP and sigma readings can be sensitive because fewer bars have been accumulated.

Volume quality differs across markets and symbols.

Japanese notes

当日VWAPと出来高加重標準偏差バンドを使って、価格が当日の平均価格からどれだけ乖離しているかを表示します。状況把握用の可視化ツールであり、売買判断や将来の値動きを示すものではありません。出来高が使えない銘柄では等加重フォールバック、または No usable volume を表示します。イントラデイ向けです。

## Source Code

````pine
//@version=6
indicator("Daily VWAP Deviation Map", shorttitle="VWAP Dev Map", overlay=true)

// ============================================================================
// INPUTS
// ============================================================================

// --- (1) Calculation ---
string GRP_CALC = "Calculation"
srcInput       = input.source(hlc3, title="Source", group=GRP_CALC,
     tooltip="Price source fed into the volume-weighted mean. Default hlc3.")
minBars        = input.int(10, title="Minimum bars before classification", minval=1, maxval=500, group=GRP_CALC,
     tooltip="Session bar count required before a sigma state is reported. Earlier bars stay 'Warming up'.")
useVolFallback = input.bool(true, title="Use equal-weight fallback when volume is missing", group=GRP_CALC,
     tooltip="When real volume is na or not positive, weight each bar by 1.0 so the calculation stays continuous. The dashboard flags this as 'Equal-weight fallback' so the reading is not misleading.")

// --- (2) Bands ---
string GRP_BANDS = "Bands"
show1sigma = input.bool(true,  title="Show +/-1 sigma", group=GRP_BANDS)
m1         = input.float(1.0,  title="  1 sigma multiplier", minval=0.1, step=0.1, group=GRP_BANDS)
show2sigma = input.bool(true,  title="Show +/-2 sigma", group=GRP_BANDS)
m2         = input.float(2.0,  title="  2 sigma multiplier", minval=0.1, step=0.1, group=GRP_BANDS)
show3sigma = input.bool(false, title="Show +/-3 sigma (low emphasis)", group=GRP_BANDS)
m3         = input.float(3.0,  title="  3 sigma multiplier", minval=0.1, step=0.1, group=GRP_BANDS)
showFills  = input.bool(true,  title="Show band fills", group=GRP_BANDS)

// --- (3) Events and alerts ---
string GRP_EVT = "Events and alerts"
showEvents     = input.bool(true, title="Show event markers", group=GRP_EVT)
confirmOnClose = input.bool(true, title="Alert only on bar close", group=GRP_EVT,
     tooltip="When enabled, event markers and alert conditions are evaluated only on confirmed (closed) bars to avoid intrabar repainting.")

// --- (4) Display ---
string GRP_DISP = "Display"
showTable      = input.bool(true, title="Show dashboard table", group=GRP_DISP)
dashLayout     = input.string("Compact", title="Dashboard layout", group=GRP_DISP,
     options=["Compact", "Standard", "Detailed"],
     tooltip="Compact keeps the chart clean for screenshots; Standard shows the full field set; Detailed adds the active band multipliers.")
tablePosInput  = input.string("Top right padded", title="Table position", group=GRP_DISP,
     options=["Top right padded", "Top right", "Top center", "Top left", "Middle right", "Middle center", "Middle left", "Bottom right", "Bottom center", "Bottom left"],
     tooltip="Top right padded keeps the dashboard in the upper-right area while using subtle internal spacing to reduce overlap with the chart's right-side High/Low price labels. Standard Top right and all other anchors remain available.")
useTopRightPaddingInput = input.bool(true, title="Use padded top-right spacing", group=GRP_DISP,
     tooltip="When the table position is Top right padded, transparent spacing is used inside the table to keep the dashboard near the upper-right area while reducing overlap with the chart's right-side High/Low price labels.")
topSpacerHeight  = input.int(2, title="Top spacer height", minval=0, maxval=6, group=GRP_DISP,
     tooltip="Adds a transparent row above the dashboard content when using Top right padded.")
rightSpacerWidth = input.int(2, title="Right spacer width", minval=0, maxval=8, group=GRP_DISP,
     tooltip="Adds a transparent column to the right of the dashboard content when using Top right padded.")
tableSizeInput = input.string("Small", title="Table text size", group=GRP_DISP,
     options=["Tiny", "Small", "Normal", "Large"])
showCandleTint = input.bool(false, title="Tint candles by deviation zone", group=GRP_DISP,
     tooltip="Optional subtle candle coloring that reflects the current sigma zone. Off by default.")

// --- (5) Visual customization ---
// All defaults match the previous restrained palette; everything here is a
// display preference only and does not change any calculation.
string GRP_THEME = "Visual customization"
// Plot colors (every input has a unique title so there are no duplicate-title clashes)
color vwapColorInput    = input.color(color.new(#ff6d00, 0), title="VWAP",           group=GRP_THEME, inline="plotA")
color innerColorInput   = input.color(color.new(#26a69a, 0), title="Inner",          group=GRP_THEME, inline="plotA")
color outerColorInput   = input.color(color.new(#2962ff, 0), title="Outer",          group=GRP_THEME, inline="plotB")
color tailColorInput    = input.color(color.new(#9e9e9e, 0), title="Tail",           group=GRP_THEME, inline="plotB")
color extTintColorInput = input.color(color.new(#7e57c2, 0), title="Extension tint", group=GRP_THEME, inline="tint")
int   tintTransp        = input.int(65, title="Tint transp", minval=0, maxval=100,   group=GRP_THEME, inline="tint")
// Band line transparency
int innerLineTransp = input.int(15, title="Inner line transp", minval=0, maxval=100, group=GRP_THEME, inline="ltrans")
int outerLineTransp = input.int(20, title="Outer line transp", minval=0, maxval=100, group=GRP_THEME, inline="ltrans")
int tailLineTransp  = input.int(45, title="Tail line transp",  minval=0, maxval=100, group=GRP_THEME)
// Fill transparency
int innerFillTransp = input.int(92, title="Inner fill transp", minval=0, maxval=100, group=GRP_THEME, inline="ftrans")
int outerFillTransp = input.int(93, title="Outer fill transp", minval=0, maxval=100, group=GRP_THEME, inline="ftrans")
// Dashboard colors
color hdrBgInput       = input.color(color.new(#2a2e39, 10), title="Dash header bg", group=GRP_THEME, inline="dbg")
color cellBgInput      = input.color(color.new(#2a2e39, 35), title="Dash cell bg",   group=GRP_THEME, inline="dbg")
color textColorInput   = input.color(color.new(color.white, 0), title="Dash text",   group=GRP_THEME, inline="dtxt")
color accentColorInput = input.color(color.new(#ffb74d, 0), title="Dash accent",     group=GRP_THEME, inline="dtxt")
color frameColorInput  = input.color(color.new(color.gray, 40), title="Dash frame",  group=GRP_THEME, inline="dframe")
color borderColorInput = input.color(color.new(color.gray, 60), title="Dash border", group=GRP_THEME, inline="dframe")
// Event markers
color markerTextColorInput = input.color(color.new(color.white, 0), title="Marker text", group=GRP_THEME, inline="mk")
int   markerTransp         = input.int(20, title="Marker transp", minval=0, maxval=100,   group=GRP_THEME, inline="mk")

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

// Map the table-position input to a Pine position constant. "Top right padded"
// shares the top_right anchor and adds internal spacing (handled in the table
// section). All nine standard anchors remain available; fallback is top_right.
f_tablePos(string p) =>
    switch p
        "Top right padded" => position.top_right
        "Top right"        => position.top_right
        "Top center"       => position.top_center
        "Top left"         => position.top_left
        "Middle right"     => position.middle_right
        "Middle center"    => position.middle_center
        "Middle left"      => position.middle_left
        "Bottom right"     => position.bottom_right
        "Bottom center"    => position.bottom_center
        "Bottom left"      => position.bottom_left
        => position.top_right

// Map the text-size input to a Pine size constant.
f_textSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

// Neutral, descriptive state from the absolute sigma distance.
f_stateText(bool stable, float absSigma) =>
    string st = "Warming up"
    if stable and not na(absSigma)
        if absSigma < 0.5
            st := "Near VWAP"
        else if absSigma < 1.0
            st := "Inner range"
        else if absSigma < 2.0
            st := "One-sigma edge"
        else if absSigma < 3.0
            st := "Two-sigma extension"
        else
            st := "Outer tail"
    st

// Format a signed sigma distance, e.g. "+1.42 sigma".
f_fmtSigma(float v) =>
    na(v) ? "n/a" : (v >= 0 ? "+" : "") + str.tostring(v, "0.00") + " sigma"

// Format a signed price distance at the symbol's tick precision.
f_fmtPrice(float v) =>
    na(v) ? "n/a" : (v >= 0 ? "+" : "") + str.tostring(v, format.mintick)

// Format a signed percent distance.
f_fmtPct(float v) =>
    na(v) ? "n/a" : (v >= 0 ? "+" : "") + str.tostring(v, "0.00") + " %"

// Format an absolute price-scale value (VWAP, sigma).
f_fmtVal(float v) =>
    na(v) ? "n/a" : str.tostring(v, format.mintick)

// ============================================================================
// TIMEFRAME GATING
// Intraday is the intended use. On daily/weekly/monthly (or any non-intraday)
// timeframe a per-bar daily VWAP would be misleading, so bands are forced to
// na and the dashboard shows a brief notice instead.
// ============================================================================
bool isIntraday = not timeframe.isdwm

// ============================================================================
// VOLUME SELECTION
// Use real volume when present and strictly positive. Otherwise, if the
// fallback is enabled, weight the bar by 1.0 so the cumulative sums remain
// continuous. usedFallbackToday records whether any bar in the current
// session used the fallback, so the dashboard can disclose it.
// ============================================================================
bool  volMissing = na(volume) or volume <= 0
float barWeight  = volMissing ? (useVolFallback ? 1.0 : na) : volume

// ============================================================================
// DAILY-ANCHORED CUMULATIVE SUMS (computed manually for transparency)
// At the start of each exchange day we RESET the running totals FIRST, then
// accumulate the current bar, so the new day's first bar is always included.
// The sums are seeded at 0.0 (not na) so the very first partial session on a
// freshly loaded chart populates immediately.
// ============================================================================
var float cumVol = 0.0
var float cumPV  = 0.0
var float cumPV2 = 0.0
var int   barsIn = 0
var bool  usedFallbackToday = false

bool newDay = timeframe.change("D")

if newDay
    cumVol  := 0.0
    cumPV   := 0.0
    cumPV2  := 0.0
    barsIn  := 0
    usedFallbackToday := false

// Accumulate the current bar (only when intraday and the inputs are usable).
if isIntraday and not na(srcInput) and not na(barWeight)
    cumVol := cumVol + barWeight
    cumPV  := cumPV  + srcInput * barWeight
    cumPV2 := cumPV2 + srcInput * srcInput * barWeight
    barsIn := barsIn + 1
    if volMissing
        usedFallbackToday := true

// ============================================================================
// CORE CALCULATIONS (all divisions guarded)
// ============================================================================
bool  volOk = isIntraday and cumVol > 0.0
float vwap  = volOk ? cumPV / cumVol : na

// Volume-weighted population variance, floored at 0 against rounding noise.
float variance = volOk ? math.max(cumPV2 / cumVol - vwap * vwap, 0.0) : na
float sigma    = na(variance) ? na : math.sqrt(variance)

// sigma must be safely positive before we divide by it.
bool  sigmaSafe = not na(sigma) and sigma > 1e-10

float rawDistance     = na(vwap) ? na : srcInput - vwap
float percentDistance = (na(vwap) or vwap == 0) ? na : 100.0 * rawDistance / vwap
float sigmaDistance   = sigmaSafe ? rawDistance / sigma : na
float absSigma        = na(sigmaDistance) ? na : math.abs(sigmaDistance)

// Stable enough to classify: intraday, warmed up, and a usable sigma distance.
bool stable = isIntraday and barsIn >= minBars and not na(sigmaDistance)

// ============================================================================
// STATE AND SIDE (neutral, descriptive language only)
// ============================================================================
string stateText = f_stateText(stable, absSigma)

string sideText = "At VWAP"
if stable and not na(rawDistance)
    sideText := rawDistance > 0 ? "Above VWAP" : rawDistance < 0 ? "Below VWAP" : "At VWAP"

// Volume mode disclosure: fallback overrides everything; otherwise a positive
// cumulative volume means real volume drove the weighting; if neither holds the
// symbol has no usable volume and the fallback is disabled.
string volModeText = usedFallbackToday ? "Equal-weight fallback" : (cumVol > 0.0 ? "Volume-weighted" : "No usable volume")

// ============================================================================
// ACTIVE BAND MULTIPLIERS
// The outer tier is forced strictly above the inner tier (and the tail above
// the outer) so the bands and the events keyed to them stay correctly ordered
// even if a user sets unusual multipliers. Band plots and event detection both
// read these values, so the markers always line up with the displayed tiers.
// ============================================================================
float activeInnerMult = m1
float activeOuterMult = math.max(m2, activeInnerMult + 0.1)
float activeTailMult  = math.max(m3, activeOuterMult + 0.1)

// ============================================================================
// BAND VALUES
// Bands are drawn only once warmed up (bandsOk = stable, i.e. intraday, a safe
// sigma, and barsIn >= minBars), so the chart never implies stable deviation
// bands before the warm-up threshold. The VWAP line itself stays visible as
// soon as it can be computed (see the VWAP plot below).
// ============================================================================
bool  bandsOk = stable
float up1 = (bandsOk and show1sigma) ? vwap + activeInnerMult * sigma : na
float dn1 = (bandsOk and show1sigma) ? vwap - activeInnerMult * sigma : na
float up2 = (bandsOk and show2sigma) ? vwap + activeOuterMult * sigma : na
float dn2 = (bandsOk and show2sigma) ? vwap - activeOuterMult * sigma : na
float up3 = (bandsOk and show3sigma) ? vwap + activeTailMult  * sigma : na
float dn3 = (bandsOk and show3sigma) ? vwap - activeTailMult  * sigma : na

// ============================================================================
// PLOTS (restrained palette; fill() needs plot ids, so we keep handles)
// ============================================================================
// Plot colors come from the Visual customization inputs (defaults match the
// previous restrained palette). Line/fill transparency is user-configurable.
color cVwap = vwapColorInput
color c1    = innerColorInput
color c2    = outerColorInput
color c3    = tailColorInput

pVwap = plot(volOk ? vwap : na, title="VWAP", color=cVwap, linewidth=2)
pUp1  = plot(up1, title="Upper inner band", color=color.new(c1, innerLineTransp), linewidth=1)
pDn1  = plot(dn1, title="Lower inner band", color=color.new(c1, innerLineTransp), linewidth=1)
pUp2  = plot(up2, title="Upper outer band", color=color.new(c2, outerLineTransp), linewidth=1)
pDn2  = plot(dn2, title="Lower outer band", color=color.new(c2, outerLineTransp), linewidth=1)
pUp3  = plot(up3, title="Upper tail band", color=color.new(c3, tailLineTransp), linewidth=1)
pDn3  = plot(dn3, title="Lower tail band", color=color.new(c3, tailLineTransp), linewidth=1)

// Subtle fills between adjacent bands (high transparency keeps the chart calm).
fill(pVwap, pUp1, color=showFills and show1sigma ? color.new(c1, innerFillTransp) : na, title="VWAP to upper inner band")
fill(pVwap, pDn1, color=showFills and show1sigma ? color.new(c1, innerFillTransp) : na, title="VWAP to lower inner band")
fill(pUp1,  pUp2, color=showFills and show1sigma and show2sigma ? color.new(c2, outerFillTransp) : na, title="Upper inner to outer band")
fill(pDn1,  pDn2, color=showFills and show1sigma and show2sigma ? color.new(c2, outerFillTransp) : na, title="Lower inner to outer band")

// ============================================================================
// CANDLE TINT BY DEVIATION ZONE (optional, off by default, low emphasis)
// ============================================================================
color tintColor = na
if showCandleTint and stable and not na(absSigma)
    tintColor := absSigma < 0.5 ? color.new(c3, tintTransp) :
                 absSigma < 1.0 ? color.new(c1, tintTransp) :
                 absSigma < 2.0 ? color.new(c2, tintTransp) :
                 color.new(extTintColorInput, tintTransp)
barcolor(tintColor, title="Deviation zone tint")

// ============================================================================
// EVENT DETECTION
// Events are factual crossings of the active band tiers, detected by comparing
// the previous bar's sigma distance with the current one against the active
// inner/outer multipliers, so markers and alerts always match the displayed
// bands. They are not reversal or continuation predictions. When "Alert only on
// bar close" is enabled they are gated by barstate.isconfirmed so confirmed
// markers never repaint intrabar.
// ============================================================================
float sdNow  = sigmaDistance
float sdPrev = sigmaDistance[1]
bool  haveBoth = not na(sdNow) and not na(sdPrev)

// Crossings of the active inner/outer band tiers.
bool xUp1  = haveBoth and sdPrev <  activeInnerMult and sdNow >=  activeInnerMult
bool xDn1  = haveBoth and sdPrev > -activeInnerMult and sdNow <= -activeInnerMult
bool xUp2  = haveBoth and sdPrev <  activeOuterMult and sdNow >=  activeOuterMult
bool xDn2  = haveBoth and sdPrev > -activeOuterMult and sdNow <= -activeOuterMult
bool xVwap = haveBoth and ((sdPrev <= 0.0 and sdNow > 0.0) or (sdPrev >= 0.0 and sdNow < 0.0))

// Track whether price reached the +/-2 sigma extension during this excursion,
// so a later "returned inside" event can be flagged. Reading the previous-bar
// value (wasAbove2[1]) keeps the return event from self-triggering on the same
// bar, and the latch is cleared on return and on each new day.
var bool wasAbove2 = false
var bool wasBelow2 = false

if newDay
    wasAbove2 := false
    wasBelow2 := false

// Arm the latch only once warmed up, so a pre-classification excursion never
// produces an orphan "returned inside" event after warm-up completes.
if stable and not na(sdNow)
    if sdNow >= activeOuterMult
        wasAbove2 := true
    if sdNow <= -activeOuterMult
        wasBelow2 := true

bool backInsideUpper = haveBoth and wasAbove2[1] and sdPrev >= activeInnerMult and sdNow < activeInnerMult
bool backInsideLower = haveBoth and wasBelow2[1] and sdPrev <= -activeInnerMult and sdNow > -activeInnerMult

if not na(sdNow) and sdNow < activeInnerMult
    wasAbove2 := false
if not na(sdNow) and sdNow > -activeInnerMult
    wasBelow2 := false

// Gate: respect "Alert only on bar close", and only when warmed up / intraday.
bool eventGate = confirmOnClose ? barstate.isconfirmed : true
bool canEvent  = stable and eventGate

// Gated event flags shared by markers and alerts.
bool evUp1  = canEvent and xUp1
bool evDn1  = canEvent and xDn1
bool evUp2  = canEvent and xUp2
bool evDn2  = canEvent and xDn2
bool evBackU = canEvent and backInsideUpper
bool evBackL = canEvent and backInsideLower
bool evVwap = canEvent and xVwap

// ============================================================================
// EVENT MARKERS (restrained non-arrow circles via plotshape; plots do not
// accumulate chart objects over extended histories). They stay visible regardless
// of which bands are shown, respect "Show event markers", and inherit the
// confirmed-bar gating already baked into each event flag.
// ============================================================================
plotshape(showEvents and evUp1,   title="Crossed above upper inner band",       style=shape.circle, location=location.abovebar, color=color.new(c1, markerTransp), text="U1",      textcolor=markerTextColorInput, size=size.tiny)
plotshape(showEvents and evDn1,   title="Crossed below lower inner band",       style=shape.circle, location=location.belowbar, color=color.new(c1, markerTransp), text="L1",      textcolor=markerTextColorInput, size=size.tiny)
plotshape(showEvents and evUp2,   title="Crossed above upper outer band",       style=shape.circle, location=location.abovebar, color=color.new(c2, markerTransp), text="U2",      textcolor=markerTextColorInput, size=size.tiny)
plotshape(showEvents and evDn2,   title="Crossed below lower outer band",       style=shape.circle, location=location.belowbar, color=color.new(c2, markerTransp), text="L2",      textcolor=markerTextColorInput, size=size.tiny)
plotshape(showEvents and evBackU, title="Returned inside from upper extension", style=shape.circle, location=location.abovebar, color=color.new(c3, markerTransp), text="Back U1", textcolor=markerTextColorInput, size=size.tiny)
plotshape(showEvents and evBackL, title="Returned inside from lower extension", style=shape.circle, location=location.belowbar, color=color.new(c3, markerTransp), text="Back L1", textcolor=markerTextColorInput, size=size.tiny)

// ============================================================================
// ALERTS (neutral names, factual messages; gating is built into each flag)
// ============================================================================
alertcondition(evUp1,   title="Crossed above upper inner band", message="Price crossed above the upper inner deviation band of the daily VWAP.")
alertcondition(evDn1,   title="Crossed below lower inner band", message="Price crossed below the lower inner deviation band of the daily VWAP.")
alertcondition(evUp2,   title="Crossed above upper outer band", message="Price crossed above the upper outer deviation band of the daily VWAP.")
alertcondition(evDn2,   title="Crossed below lower outer band", message="Price crossed below the lower outer deviation band of the daily VWAP.")
alertcondition(evBackU, title="Returned inside from upper extension", message="Price returned inside the upper inner deviation band after reaching the upper outer deviation band.")
alertcondition(evBackL, title="Returned inside from lower extension", message="Price returned inside the lower inner deviation band after reaching the lower outer deviation band.")
alertcondition(evVwap,  title="Crossed VWAP", message="Price crossed the daily VWAP.")

// ============================================================================
// DASHBOARD TABLE (compact, neutral, descriptive only). Drawn on the last bar.
// One 3 x 13 table backs all three layouts. The optional "Top right padded"
// mode adds a transparent top spacer row and a transparent right spacer column
// so the panel stays in the upper-right area while sitting clear of the chart's
// right-side High/Low price labels. Every cell is cleared each render and only
// the rows for the selected layout are populated, so bounds are always valid.
// On non-intraday timeframes it collapses to a brief intraday-use notice.
// All colors come from the Visual customization inputs.
// ============================================================================
var table dash = table.new(f_tablePos(tablePosInput), 3, 13,
     border_width=1, border_color=borderColorInput,
     frame_width=2, frame_color=frameColorInput)

txtSz = f_textSize(tableSizeInput)

// Optional upper-right internal spacing. Pine tables use fixed anchors, so the
// panel stays anchored top-right and the spacing is created inside the table:
// a transparent top spacer row (row 0) and a transparent right spacer column
// (column 2). Both are fully transparent and hold no text.
bool  isTopRightPadded = tablePosInput == "Top right padded" and useTopRightPaddingInput
int   rowBase   = isTopRightPadded ? 1 : 0
color spacerCol = color.new(color.black, 100)

// Cell helpers. Content rows are addressed by offset; rowBase shifts them down
// when the top spacer row is active. The value and title helpers also fill the
// transparent right spacer column when padding is on.
f_cellL(int off, string txt) =>
    table.cell(dash, 0, rowBase + off, txt, text_color=textColorInput, bgcolor=hdrBgInput, text_size=txtSz, text_halign=text.align_left)
f_cellR(int off, string txt) =>
    table.cell(dash, 1, rowBase + off, txt, text_color=textColorInput, bgcolor=cellBgInput, text_size=txtSz, text_halign=text.align_right)
    if isTopRightPadded
        table.cell(dash, 2, rowBase + off, "", bgcolor=spacerCol, width=rightSpacerWidth)
f_titleRow(int off, string txt) =>
    table.cell(dash, 0, rowBase + off, txt, text_color=textColorInput, bgcolor=hdrBgInput, text_size=txtSz, text_halign=text.align_left)
    table.cell(dash, 1, rowBase + off, "", bgcolor=hdrBgInput)
    if isTopRightPadded
        table.cell(dash, 2, rowBase + off, "", bgcolor=spacerCol, width=rightSpacerWidth)
// Transparent top spacer row that nudges content down from the very top edge.
f_topSpacer() =>
    table.cell(dash, 0, 0, "", bgcolor=spacerCol, height=topSpacerHeight)
    table.cell(dash, 1, 0, "", bgcolor=spacerCol, height=topSpacerHeight)
    table.cell(dash, 2, 0, "", bgcolor=spacerCol, height=topSpacerHeight, width=rightSpacerWidth)

if showTable and barstate.islast
    table.clear(dash, 0, 0, 2, 12)
    if isTopRightPadded
        f_topSpacer()
    if not isIntraday
        // Non-intraday notice. Bands are intentionally not plotted.
        f_titleRow(0, "Daily VWAP Deviation Map")
        f_cellL(1, "Notice")
        table.cell(dash, 1, rowBase + 1, "Designed for intraday charts", text_color=accentColorInput, bgcolor=cellBgInput, text_size=txtSz, text_halign=text.align_right)
        if isTopRightPadded
            table.cell(dash, 2, rowBase + 1, "", bgcolor=spacerCol, width=rightSpacerWidth)
    else if dashLayout == "Compact"
        // 6 rows: header + the essentials, for clean default screenshots.
        f_titleRow(0, "VWAP Deviation")
        f_cellL(1, "State")
        f_cellR(1, stateText)
        f_cellL(2, "Sigma distance")
        f_cellR(2, f_fmtSigma(sigmaDistance))
        f_cellL(3, "Distance (%)")
        f_cellR(3, f_fmtPct(percentDistance))
        f_cellL(4, "VWAP")
        f_cellR(4, f_fmtVal(vwap))
        f_cellL(5, "Volume mode")
        f_cellR(5, volModeText)
    else
        // Standard: the full field set (offsets 0-8). Shared by Detailed.
        f_cellL(0, "State")
        f_cellR(0, stateText)
        f_cellL(1, "Side")
        f_cellR(1, sideText)
        f_cellL(2, "Sigma distance")
        f_cellR(2, f_fmtSigma(sigmaDistance))
        f_cellL(3, "Distance (price)")
        f_cellR(3, f_fmtPrice(rawDistance))
        f_cellL(4, "Distance (%)")
        f_cellR(4, f_fmtPct(percentDistance))
        f_cellL(5, "VWAP")
        f_cellR(5, f_fmtVal(vwap))
        f_cellL(6, "Sigma")
        f_cellR(6, f_fmtVal(sigma))
        f_cellL(7, "Session bars")
        f_cellR(7, str.tostring(barsIn))
        f_cellL(8, "Volume mode")
        f_cellR(8, volModeText)
        if dashLayout == "Detailed"
            // Two extra neutral rows: the active band-tier multipliers.
            f_cellL(9, "Inner multiplier")
            f_cellR(9, str.tostring(activeInnerMult, "0.0#"))
            f_cellL(10, "Outer multiplier")
            f_cellR(10, str.tostring(activeOuterMult, "0.0#"))
````

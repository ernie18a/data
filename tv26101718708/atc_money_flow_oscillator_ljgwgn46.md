# ATC Money Flow Oscillator

- url: https://www.tradingview.com/script/LJgWgn46-ATC-Money-Flow-Oscillator/
- type: indicator
- pine_id: PUB;d91cdd5d728b43689bad7a05011e5452
- version: 1.0

## Description

What It Is

The ATC Money Flow Oscillator is a volume-weighted buying and selling pressure tool that tells you not just whether money is flowing in or out of an instrument, but how extreme that pressure is relative to recent market history. It is a normalized oscillator — which means its readings are statistically meaningful regardless of the asset, timeframe, or market conditions you apply it to.

Where most retail money flow tools give you a raw reading against a fixed threshold (and those thresholds are always wrong for someone, somewhere, at some point in time), the ATC MFO gives you a Z-score — a measurement of how far current pressure deviates from the rolling statistical baseline for that specific instrument and session. The result is an oscillator that speaks the same language whether you are trading ES futures on a 5-minute chart or GC on a 1-hour chart.

________________________________________

Who It Is Built For

The ATC Money Flow Oscillator is built for traders who want a pressure confirmation tool that does not lie to them at the edges. If you have ever used Chaikin Money Flow, On Balance Volume, or a standard CMF and felt frustrated that the indicator screams "extreme" when conditions are perfectly normal, or gives a flat reading during a genuine momentum surge, this indicator was engineered specifically to solve that problem.


It works well as a standalone directional filter and as a confirmation layer for price action, trend, or breakout strategies. It is particularly useful for traders who want to know whether volume is supporting the move or quietly fading it before they commit to an entry.

________________________________________

Core Concept

The foundation of the ATC MFO is a Chaikin-style money flow calculation. For each bar, it asks a simple question: where did price close within the bar's high-to-low range, and how much volume was behind that close? A bar that closes at the high of its range with heavy volume is strong buying pressure. A bar that closes at the low of its range with heavy volume is strong selling pressure. A bar that closes in the middle, or closes at the high with minimal volume, is ambiguous.

That per-bar measurement is called the Money Flow Multiplier — it produces a signed value between -1 and +1 for every bar, which is then multiplied by volume to create a Money Flow Volume reading. Those per-bar readings are summed over a rolling lookback window (default 10 bars) to build a directional picture of recent pressure, then divided by total volume in the same window to normalize for volume magnitude. The result is the raw Money Flow Ratio — a clean directional reading of where participation-weighted price activity is clustering.

That raw ratio is what most retail tools stop at. The ATC MFO treats it as the starting point.

________________________________________

ATC MFO Upgrades

1. Z-Score Normalization

The raw Money Flow Ratio is run through a rolling Z-score calculation over a configurable normalization window (default 40 bars). This computes the rolling mean and standard deviation of the raw ratio across recent history and expresses the current reading as a number of standard deviations from that average. The result is the Money Flow Z-Score — the main oscillator line you see on the chart.

This single upgrade changes the character of the tool entirely. Instead of asking "is the reading above 0.25?" it asks "is the reading more than one standard deviation above average for this instrument in this session?" That is a meaningfully different and more honest question. The empirical pressure bands (at ±1 sigma and ±2 sigma) replace the guesswork of fixed thresholds with statistically derived extremes.

2. HMA Signal Line

Most money flow tools use an SMA or EMA signal line. The ATC MFO uses a Hull Moving Average (HMA) for signal smoothing. HMA dramatically reduces the lag that makes conventional smoothed signal lines late by design. The signal line updates faster, tracks direction more accurately through transitions, and avoids the "stale signal" problem where the smoothed line is still pointing one way while price has already reversed. The default HMA length is 6 bars, derived from the same optimization sweep as the lookback and normalization window settings.

3. Hysteresis-Stabilized State Engine

The indicator classifies the current pressure environment into five states: Neutral, Elevated Buying, Extreme Buy Pressure, Elevated Selling, and Extreme Sell Pressure. These states are displayed in the HUD and drive the color logic across the chart. Rather than flickering between states every time the Z-score crosses a threshold by a fraction, the state engine applies a configurable hysteresis band. Once you enter a state, you stay in it until pressure falls meaningfully below the threshold — not just one tick below it. This prevents the visual noise that makes most state-classifying indicators unreliable to read in real time.

4. Session Participation Tracker

The indicator maintains a live volume participation ratio: the current bar's volume expressed as a multiple of the session average volume for that day. A reading of 1.0x means volume is exactly in line with the session average. A reading above 1.20x means the current bar is printing above-average participation, which gives additional weight to whatever the pressure reading shows. A reading below 0.80x flags a low-participation bar — useful context when a pressure signal appears but volume is not backing it. This data lives in the HUD and updates every bar within the active session.

________________________________________

Chart Visuals

Oscillator Line

The main oscillator is the Money Flow Z-Score plotted as a continuous line against the zero axis. The line is colored green when pressure is bullish and red when bearish, with the intensity of the color constant across both states. A soft glow layer behind the line (toggleable) reinforces the directional reading without adding clutter.

Zero Line

The zero line is the neutral dividing line between net buying and net selling pressure. Crossings of the zero line are meaningful — they mark the shift from net bullish participation to net bearish, or vice versa — and have dedicated alert conditions.

HMA Signal Line

The blue signal line is the HMA-smoothed version of the Z-score. It acts as a direction filter and a trend reference for the oscillator. When the oscillator is above the signal line and both are rising, pressure alignment is confirmed. When the oscillator crosses below the signal line, it is an early sign of deterioration even if the oscillator itself has not crossed zero yet.

Sigma Bands

Four reference lines mark the ±1 sigma and ±2 sigma levels. The inner bands (dashed) mark elevated pressure territory — statistically significant, but not extreme. The outer bands (solid) mark extreme pressure readings — statistically uncommon and historically associated with either climactic moves or exhaustion.

Zone Fills

Optional background shading between the sigma bands makes the pressure regimes immediately readable at a glance. A subtle green zone fills the space between the +1 and +2 sigma lines. A subtle red zone fills the space between the -1 and -2 sigma lines. A neutral grey zone fills the space between the inner bands. These fills have no impact on calculations — they are purely visual navigation aids.

Pressure Fill

An optional fill between the oscillator line and the zero line provides instant directional context. Green fill above zero, red fill below zero. This is particularly useful when the oscillator is making small movements near the zero line where directional color alone is harder to read quickly.

________________________________________

HUD Breakdown

The HUD renders as a corner table (default position: top right, toggleable to any corner). It provides a live read of the five most important data points from the indicator without requiring you to hover over the chart or consult the data window.

State — The current pressure classification based on the hysteresis-stabilized state engine. Reports one of: Neutral, Elevated Buying, Extreme Buy Pressure, Elevated Selling, or Extreme Sell Pressure. The cell background color is green for bullish states, red for bearish, and muted blue for neutral.

Z-Score — The current Money Flow Z-Score expressed in sigma units to two decimal places. This is the raw number behind the oscillator line. Positive values indicate above-average buying pressure; negative values indicate above-average selling pressure. The cell background reflects the current pressure regime.

Signal — The current direction of the HMA signal line: Rising, Falling, or Flat. This one-word read tells you at a glance whether the smoothed pressure trend is accelerating, decelerating, or transitioning.

Participation — The current bar's volume expressed as a multiple of the session average. Displayed to two decimal places with an "x" suffix (e.g., 1.43x). Green when above 1.20x, red when below 0.80x, neutral otherwise.

Windows — Displays the active lookback and normalization window settings in the format "10 / 40z" so you can immediately see what calculation parameters are in play without opening the settings panel.

________________________________________

Logic Layers

The indicator operates across three stacked logic layers that work together:

Layer 1 — Pressure Generation. Per-bar money flow multiplier × volume, summed over the lookback window and normalized by total volume. This produces the raw directional reading before statistics are applied.

Layer 2 — Statistical Normalization. The raw ratio is run through the rolling Z-score against the normalization window. This converts the raw reading into a statistically scaled value that is instrument-agnostic and session-aware.

Layer 3 — State Classification. The Z-score is classified into one of five pressure states using the hysteresis-stabilized threshold logic. This state drives the HUD display, color outputs, and alert logic.

The session participation tracker runs as a parallel calculation that does not influence the oscillator itself — it is purely a context layer that adds interpretive weight to whatever the main oscillator is showing.

________________________________________

Alerts

The ATC MFO includes four alert conditions. All fire on state transitions or zero-line crosses, not on every bar within a given state. This means you will never get spammed with alerts while an existing condition persists — alerts only fire at the moment something changes.

MFO: Extreme Buying Pressure — Fires when the pressure state transitions into Extreme Buy territory (Z-score crosses above the outer sigma band). This marks a statistically significant acceleration of buying participation.

MFO: Extreme Selling Pressure — Fires when the pressure state transitions into Extreme Sell territory (Z-score crosses below the outer sigma band). This marks a statistically significant acceleration of selling participation.

MFO: Zero-Line Cross Up — Fires when the Z-score crosses above zero — the moment when net buying pressure emerges after a net bearish reading.

MFO: Zero-Line Cross Down — Fires when the Z-score crosses below zero — the moment when net selling pressure emerges after a net bullish reading.

________________________________________

How to Trade With It

The ATC Money Flow Oscillator is not a signal generator. It does not tell you when to buy or sell. It tells you what participation-weighted pressure is doing so you can make better decisions about the trades your other analysis is already identifying. Use it as a confirmation and context layer.

Step 1 — Establish your directional bias. Use your preferred method — price structure, trend analysis, key levels, or market context — to identify the direction you are considering trading. The MFO confirms or contradicts that bias.

Step 2 — Check the Z-score and state. Before entering a trade, look at the HUD State and Z-Score readings. For a long entry, you want to see the state reading Neutral, Elevated Buying, or Extreme Buy Pressure, and the Z-score above zero. For a short entry, the inverse applies. If you are looking for a long and the MFO shows Elevated Selling, consider waiting for pressure to realign.

Step 3 — Check the signal line direction. The HMA signal line direction (shown in the HUD as Rising, Falling, or Flat) tells you whether pressure is accelerating or decelerating. The strongest confirmation is when the oscillator is above zero, the state is bullish, and the signal is rising. The weakest setup is when the oscillator and signal are diverging.

Step 4 — Check participation. Look at the Participation reading in the HUD. A pressure signal with 1.3x or higher participation means volume is actively supporting the move. A pressure signal with 0.7x participation means the move is happening on thin volume — be cautious about the sustainability of that signal.

Step 5 — Use the sigma bands for context. Readings near the outer sigma bands (+2 or -2) indicate extreme conditions. This can mean two things depending on context: either you are seeing climactic momentum that is likely to continue briefly before exhausting, or you are seeing exhaustion that is setting up a reversal. Use price structure to distinguish. In trending conditions, extreme readings in the direction of the trend are continuation signals. In range-bound conditions, extreme readings against key levels are often fading opportunities.

Step 6 — Use the zero-line cross alerts as context shifts. The zero-line cross alerts are useful as early-warning notifications that the character of participation is changing, even before price structure confirms it. A zero-line cross up while price is still above a key support level is a useful heads-up that buyers are reasserting. A zero-line cross down while price is approaching resistance is worth noting.

Step 7 — Do not fight extreme readings. When the MFO is printing Extreme Buy or Extreme Sell Pressure and the signal line is confirming, the path of least resistance is in that direction. The most common mistake traders make with normalized oscillators is fading strong readings too early. A +2 sigma reading does not mean the pressure is about to reverse — it means pressure is statistically extreme, and statistically extreme trends tend to resolve either through continued momentum or a period of neutralization before the next move.
________________________________________
Settings Reference

Core Calculation

•	Money Flow Lookback (default 10) — Bars used for the rolling money flow sum. Shorter values make the oscillator more responsive to recent bars; longer values smooth out intrabar noise. The default of 10 was derived from a full optimization sweep on QQQ at 1-minute resolution.

•	Z-Score Normalization Window (default 40) — The rolling window used to compute the mean and standard deviation for Z-score scaling. This determines how "recent" the statistical baseline is. 40 bars is the optimized default; increasing this anchors the baseline to a longer history.

•	Signal Line HMA Length (default 6) — The HMA smoothing length for the signal line. Shorter values produce a more reactive signal line; longer values produce a smoother one. HMA is used instead of SMA or EMA to minimize lag.

Pressure Bands (Sigma)

•	Inner Band (default 1.0 sigma) — The threshold for Elevated Buying and Elevated Selling states. Readings beyond this line are statistically significant relative to the rolling window.

•	Outer Band (default 2.0 sigma) — The threshold for Extreme Buy and Extreme Sell states. Readings beyond this line are statistically uncommon.

•	State Hysteresis (default 0.10 sigma) — The neutral buffer applied to state transitions. Prevents the HUD state label from flickering when the Z-score is hovering near a threshold.

Session

•	Session (default 0930-1600) — The session window used for the participation tracker and session-aware logic.

•	Session Timezone (default America/New_York) — The timezone applied to the session definition.

Instruments and Timeframes

The ATC Money Flow Oscillator is validated and recommended for use on the following instruments and timeframes.

Instruments: ES, NQ, CL, GC, SPY, QQQ, major equities, major FX pairs.
Timeframes: 1-minute, 5-minute, 15-minute, 1-hour, 4-hour, Daily.
The indicator functions correctly on any instrument and timeframe that carries volume data. It is not suitable for instruments without volume reporting, such as some spot FX feeds.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ATConcepts

// ==========================================================================
//@version=6
indicator("ATC Money Flow Oscillator", shorttitle="ATC MFO", overlay=false, max_labels_count=50)

// ==========================================================================
// Section B — User Inputs
// ==========================================================================

// --- Core calculation inputs ---
grpCalc       = "Core Calculation"
mfLen         = input.int(32, "Money Flow Lookback", minval=5, maxval=200,
                 tooltip="Optimized QQQ 5-minute trend-capture default. Higher value smooths short-term pressure noise and better tracks sustained intraday money-flow direction.", group=grpCalc)
zLen          = input.int(120, "Z-Score Normalization Window", minval=20, maxval=500,
                 tooltip="Optimized QQQ 5-minute trend-capture default. Uses a broader statistical baseline to reduce false pressure flips.", group=grpCalc)
smoothLen     = input.int(10, "Signal Line HMA Length", minval=2, maxval=50,
                 tooltip="Optimized QQQ 5-minute trend-capture default. Smooths the signal line enough to follow intraday trends without becoming overly delayed.", group=grpCalc)

// --- Threshold inputs ---
grpThresh     = "Pressure Bands (Sigma)"
sigma1        = input.float(0.65, "Inner Band (sigma)", minval=0.25, maxval=3.0, step=0.1,
                 tooltip="Optimized QQQ 5-minute trend-capture default. Lower than 1.0 so the HUD recognizes sustained trend pressure earlier.", group=grpThresh)
sigma2        = input.float(1.70, "Outer Band (sigma)", minval=0.5, maxval=4.0, step=0.1,
                 tooltip="Optimized QQQ 5-minute trend-capture default. Marks stronger pressure extremes without waiting for rare 2-sigma events.", group=grpThresh)
hystPct       = input.float(0.10, "State Hysteresis (sigma)", minval=0.0, maxval=0.5, step=0.05,
                 tooltip="Keeps HUD state stable near pressure thresholds.", group=grpThresh)

// --- Session inputs ---
grpSess       = "Session"
sessDef       = input.session("0930-1600", "Session",
                 tooltip="Session window used for session-aware statistics and participation tracking.", group=grpSess)
sessTZ        = input.string("America/New_York", "Session Timezone",
                 options=["America/New_York","America/Chicago","America/Los_Angeles","Europe/London","Asia/Tokyo","Asia/Singapore","UTC"],
                 tooltip="Timezone for the session window. Defaults to US Eastern.", group=grpSess)

// --- Visual inputs ---
grpVis        = "Visuals"
colBull       = input.color(#2AF5A0, "Bullish Pressure", group=grpVis)
colBear       = input.color(#FF5C6C, "Bearish Pressure", group=grpVis)
colNeutral    = input.color(#B4BCC9, "Neutral", group=grpVis)
colSignal     = input.color(#49A6FF, "Signal Line / Accent", group=grpVis)
colBand       = input.color(#3C92FF, "Band Color", group=grpVis)
showFill      = input.bool(true, "Fill Between Oscillator and Zero",
                 tooltip="Fills the area between the oscillator and zero to make pressure direction more readable.", group=grpVis)
showZoneFill  = input.bool(true, "Show Sigma Zone Fills",
                 tooltip="Adds subtle bull, neutral, and bear background zones between the sigma bands.", group=grpVis)
showGlow      = input.bool(true, "Show Premium Glow",
                 tooltip="Adds soft glow layers behind the oscillator and signal line for a more premium look.", group=grpVis)
oscWidth      = input.int(3, "Oscillator Width", minval=1, maxval=5, group=grpVis)
signalWidth   = input.int(2, "Signal Width", minval=1, maxval=4, group=grpVis)
glowBoost     = input.int(2, "Glow Width Boost", minval=1, maxval=4,
                 tooltip="Extra width added to the glow layer behind the plotted lines.", group=grpVis)

// --- HUD ---
grpHUD        = "HUD"
showHUD       = input.bool(true, "Show HUD", group=grpHUD)
hudPos        = input.string("Top Right", "HUD Position",
                 options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=grpHUD)
hudTheme      = input.string("Dark", "HUD Theme",
                 options=["Dark","Light"], group=grpHUD)

// ==========================================================================
// Section C — Core Calculations
// ==========================================================================

// --- Session state ---
inSession     = not na(time(timeframe.period, sessDef, sessTZ))
newSession    = inSession and not inSession[1]

// --- Guard inputs ---
vol           = nz(volume, 0.0)
hi            = high
lo            = low
cl            = close
barRange      = hi - lo

// --- Money Flow Multiplier (Chaikin-style, but guarded) ---
// MFM ranges from -1 (close at low) to +1 (close at high)
mfm           = barRange != 0 ? ((cl - lo) - (hi - cl)) / barRange : 0.0

// --- Money Flow Volume (signed volume weighted by location in range) ---
mfv           = mfm * vol

// --- Rolling Money Flow Sum (raw, pre-normalization) ---
mfSum         = math.sum(mfv, mfLen)
volSum        = math.sum(vol, mfLen)

// --- Raw Money Flow Ratio (pre-Z-score) ---
mfRaw         = volSum != 0 ? mfSum / volSum : 0.0

// ==========================================================================
// Section D — Enhancement Layer
// ==========================================================================

// --- Z-score normalization against rolling window ---
mfMean        = ta.sma(mfRaw, zLen)
mfStdev       = ta.stdev(mfRaw, zLen)
mfZ           = mfStdev != 0 ? (mfRaw - mfMean) / mfStdev : 0.0

// --- HMA-smoothed signal line ---
mfSignal      = ta.hma(mfZ, smoothLen)

// --- State classification with hysteresis ---
// Persistent state to prevent flicker at threshold boundaries
var int pressureState = 0  // -2, -1, 0, +1, +2

absZ          = math.abs(mfZ)
prevState     = pressureState

// Hysteresis bands: entering a state requires full threshold;
// exiting requires dropping below threshold minus hysteresis.
enterOuter    = absZ >= sigma2
exitOuter     = absZ < sigma2 - hystPct
enterInner    = absZ >= sigma1
exitInner     = absZ < sigma1 - hystPct

if not na(mfZ)
    if mfZ > 0
        if prevState == 2
            if exitOuter
                pressureState := enterInner ? 1 : 0
        else if prevState == 1
            if enterOuter
                pressureState := 2
            else if exitInner
                pressureState := 0
        else
            if enterOuter
                pressureState := 2
            else if enterInner
                pressureState := 1
            else
                pressureState := 0
    else if mfZ < 0
        if prevState == -2
            if exitOuter
                pressureState := enterInner ? -1 : 0
        else if prevState == -1
            if enterOuter
                pressureState := -2
            else if exitInner
                pressureState := 0
        else
            if enterOuter
                pressureState := -2
            else if enterInner
                pressureState := -1
            else
                pressureState := 0
    else
        pressureState := 0

// --- Session participation tracker (volume vs. session average) ---
var float sessVolSum  = na
var int   sessBarCnt  = 0

if newSession
    sessVolSum := vol
    sessBarCnt := 1
else if inSession
    sessVolSum := nz(sessVolSum, 0.0) + vol
    sessBarCnt := sessBarCnt + 1

sessVolAvg    = sessBarCnt > 0 ? nz(sessVolSum, 0.0) / sessBarCnt : na
participation = not na(sessVolAvg) and sessVolAvg != 0 ? vol / sessVolAvg : na

// ==========================================================================
// Section E — Plotting & Visual Rendering
// ==========================================================================

// --- State-aware colors ---
oscColor      = pressureState >= 2  ? color.new(colBull, 0) :
                 pressureState == 1  ? color.new(colBull, 0) :
                 pressureState <= -2 ? color.new(colBear, 0) :
                 pressureState == -1 ? color.new(colBear, 0) :
                                       color.new(colNeutral, 8)

signalColor   = not na(mfSignal) and not na(mfSignal[1]) and mfSignal > mfSignal[1] ? color.new(colSignal, 0) :
                 not na(mfSignal) and not na(mfSignal[1]) and mfSignal < mfSignal[1] ? color.new(colSignal, 8) :
                                                                                         color.new(colSignal, 3)

oscGlowColor  = showGlow ? color.new(oscColor, 58) : na
sigGlowColor  = showGlow ? color.new(signalColor, 66) : na
zeroColor     = color.new(colNeutral, 40)

// --- Sigma reference lines ---
hUpper1       = hline( sigma1, "+1 sigma", color=color.new(colBand, 42), linestyle=hline.style_dashed)
hLower1       = hline(-sigma1, "-1 sigma", color=color.new(colBand, 42), linestyle=hline.style_dashed)
hUpper2       = hline( sigma2, "+2 sigma", color=color.new(colBand, 14), linestyle=hline.style_solid)
hLower2       = hline(-sigma2, "-2 sigma", color=color.new(colBand, 14), linestyle=hline.style_solid)

// --- Zone fills ---
fill(hLower1, hUpper1, color=showZoneFill ? color.new(colNeutral, 88) : na, title="Neutral Sigma Zone")
fill(hUpper1, hUpper2, color=showZoneFill ? color.new(colBull, 86) : na, title="Bullish Sigma Zone")
fill(hLower2, hLower1, color=showZoneFill ? color.new(colBear, 86) : na, title="Bearish Sigma Zone")

// --- Premium line stack ---
pOscGlow      = plot(mfZ,      "Oscillator Glow", color=oscGlowColor, linewidth=oscWidth + glowBoost)
pOsc          = plot(mfZ,      "Money Flow Z-Score", color=oscColor, linewidth=oscWidth)
pZero         = plot(0,        "Zero Line", color=zeroColor, linewidth=1)
pSignalGlow   = plot(mfSignal, "Signal Glow", color=sigGlowColor, linewidth=signalWidth + glowBoost)
pSignal       = plot(mfSignal, "Signal (HMA)", color=signalColor, linewidth=signalWidth)

// --- Directional pressure fill ---
fillColor     = showFill ? color.new(oscColor, 68) : na
fill(pOsc, pZero, color=fillColor, title="Pressure Fill")

// ==========================================================================
// Section F — HUD
// ==========================================================================

// --- State label text ---
stateText     = pressureState ==  2 ? "Extreme Buy Pressure" :
                 pressureState ==  1 ? "Elevated Buying" :
                 pressureState == -1 ? "Elevated Selling" :
                 pressureState == -2 ? "Extreme Sell Pressure" :
                                       "Neutral"

stateColor    = pressureState >=  1 ? color.white :
                 pressureState <= -1 ? color.white :
                                       color.new(colNeutral, 0)
stateBg       = pressureState >=  1 ? color.new(colBull, 28) :
                 pressureState <= -1 ? color.new(colBear, 28) :
                                       color.new(colSignal, 62)

// --- Signal direction ---
sigDir        = not na(mfSignal) and not na(mfSignal[1]) and mfSignal > mfSignal[1] ? "Rising" :
                 not na(mfSignal) and not na(mfSignal[1]) and mfSignal < mfSignal[1] ? "Falling" : "Flat"

// --- Participation text ---
partText      = not na(participation) ? str.tostring(participation, "#.00") + "x" : "n/a"
partColor     = not na(participation) and participation >= 1.20 ? color.new(colBull, 0) :
                 not na(participation) and participation <= 0.80 ? color.new(colBear, 0) :
                                                                  color.new(colNeutral, 0)

// --- HUD renderer ---
var table hud = na

if showHUD and barstate.islast
    if not na(hud)
        table.delete(hud)

    hudPosition = hudPos == "Top Right"    ? position.top_right    :
                  hudPos == "Top Left"     ? position.top_left     :
                  hudPos == "Bottom Right" ? position.bottom_right :
                                             position.bottom_left

    bgColor      = hudTheme == "Dark" ? #0F1420 : #F7F9FC
    txColor      = hudTheme == "Dark" ? color.white : #1D2433
    subColor     = hudTheme == "Dark" ? #AAB4C3 : #667085
    stateAccent  = pressureState >= 1 ? colBull : pressureState <= -1 ? colBear : colSignal
    headBg       = hudTheme == "Dark" ? color.new(stateAccent, 74) : color.new(stateAccent, 86)
    borderColor  = hudTheme == "Dark" ? color.new(stateAccent, 22) : color.new(stateAccent, 48)
    zBg          = not na(mfZ) and mfZ >= sigma1 ? color.new(colBull, 86) :
                   not na(mfZ) and mfZ <= -sigma1 ? color.new(colBear, 86) :
                   color.new(colSignal, 92)
    sigBg        = sigDir == "Rising" ? color.new(colBull, 88) :
                   sigDir == "Falling" ? color.new(colBear, 88) :
                   color.new(colSignal, 92)
    partBg       = not na(participation) and participation >= 1.20 ? color.new(colBull, 88) :
                   not na(participation) and participation <= 0.80 ? color.new(colBear, 88) :
                                                                      color.new(colSignal, 92)

    hud := table.new(hudPosition, 2, 7, bgcolor=bgColor, border_width=1, border_color=borderColor)

    table.cell(hud, 0, 0, "MFO", text_color=txColor, bgcolor=headBg, text_size=size.small)
    table.cell(hud, 1, 0, "Money Flow", text_color=txColor, bgcolor=headBg, text_size=size.small)

    table.cell(hud, 0, 1, "State", text_color=subColor, bgcolor=bgColor, text_size=size.small)
    table.cell(hud, 1, 1, stateText, text_color=stateColor, bgcolor=stateBg, text_size=size.small)

    table.cell(hud, 0, 2, "Z-Score", text_color=subColor, bgcolor=bgColor, text_size=size.small)
    table.cell(hud, 1, 2, str.tostring(mfZ, "#.00") + " sigma", text_color=txColor, bgcolor=zBg, text_size=size.small)

    table.cell(hud, 0, 3, "Signal", text_color=subColor, bgcolor=bgColor, text_size=size.small)
    table.cell(hud, 1, 3, sigDir, text_color=txColor, bgcolor=sigBg, text_size=size.small)

    table.cell(hud, 0, 4, "Participation", text_color=subColor, bgcolor=bgColor, text_size=size.small)
    table.cell(hud, 1, 4, partText, text_color=partColor, bgcolor=partBg, text_size=size.small)

    table.cell(hud, 0, 5, "Windows", text_color=subColor, bgcolor=bgColor, text_size=size.small)
    table.cell(hud, 1, 5, str.tostring(mfLen) + " / " + str.tostring(zLen) + "z", text_color=txColor, bgcolor=color.new(stateAccent, 90), text_size=size.small)

    table.cell(hud, 0, 6, "Engine", text_color=color.new(subColor, 18), bgcolor=bgColor, text_size=size.tiny)
    table.cell(hud, 1, 6, "Session-Aware Z-Score", text_color=color.new(subColor, 18), bgcolor=bgColor, text_size=size.tiny)

// ==========================================================================
// Section G — Alerts
// ==========================================================================

// State-change alerts fire only on transitions, not every bar in state.
stateChanged     = pressureState != prevState
enteredExtBuy    = stateChanged and pressureState ==  2
enteredExtSell   = stateChanged and pressureState == -2
zeroCrossUp      = ta.crossover(mfZ, 0)
zeroCrossDown    = ta.crossunder(mfZ, 0)

alertcondition(enteredExtBuy,  "MFO: Extreme Buying Pressure",  "ATC MFO entered extreme buying pressure (outer sigma band)")
alertcondition(enteredExtSell, "MFO: Extreme Selling Pressure", "ATC MFO entered extreme selling pressure (outer sigma band)")
alertcondition(zeroCrossUp,    "MFO: Zero-Line Cross Up",       "ATC MFO crossed above zero — net buying pressure emerging")
alertcondition(zeroCrossDown,  "MFO: Zero-Line Cross Down",     "ATC MFO crossed below zero — net selling pressure emerging")
````

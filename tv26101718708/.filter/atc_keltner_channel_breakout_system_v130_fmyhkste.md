# ATC Keltner Channel Breakout System v1.3.0

- url: https://www.tradingview.com/script/fMYHkSTE-ATC-Keltner-Channel-Breakout-System-v1-3-0/
- type: indicator
- pine_id: PUB;1aeab8d50158478a9ab234e1bbfc22d7
- version: 1.0

## Description

[b]What It Is[/b]

The ATC Keltner Channel Breakout System (ATC KCBS) is a breakout detection indicator built on one of the most reliable structural tools in technical analysis — the Keltner Channel — and rebuilt from the ground up to meet a higher quality standard.

Most retail Keltner indicators do one thing: draw a channel and let you guess when a breakout means something. The ATC KCBS does something different. It filters every breakout signal through a volume confirmation gate built on Z-score normalization, so the only breakouts that get flagged are the ones backed by real, statistically significant participation — not routine price noise pushing outside the bands on low volume.

The result is a cleaner, higher-quality signal set that respects your time and your capital.

________________________________________

[b]Who It's Built For[/b]

The ATC KCBS is designed for active traders focused on momentum breakouts — particularly on U.S. equities, index ETFs (QQQ, SPY), and futures (ES, NQ, CL, GC) during regular trading hours. It performs best on the 1-minute through 15-minute timeframe for intraday traders, and scales cleanly up to the 1-hour, 4-hour, and daily timeframes for swing traders. Default settings are optimized for QQQ on the 1-minute chart during RTH (Regular Trading Hours).

________________________________________

[b]The Core Concept: [/b]What Is a Keltner Channel?

A Keltner Channel consists of three lines plotted directly on your price chart:

•	A basis line — a smoothed moving average of price, acting as the channel's center of gravity
•	An upper band — the basis plus a multiple of the Average True Range (ATR)
•	A lower band — the basis minus that same ATR multiple

When price is inside the channel, the market is respecting the channel's structure and typically moving in a mean-reverting or consolidating mode. When price closes outside either band, it signals that a breakout condition may be developing. The distance of the bands from the basis is dynamic — they widen during volatile markets and compress during quiet ones.

The Keltner Channel is a better volatility envelope than Bollinger Bands for many breakout applications because ATR measures directional price movement rather than raw price deviation, which makes the channel walls more responsive to real market conditions.

________________________________________

[b]The Upgrade: What Makes This Different[/b]

Retail Keltner indicators treat all breakouts the same. A close above the upper band is a signal — end of story. The problem is that the majority of Keltner band breaks are low-conviction moves driven by thin conditions, choppy price action, or noise — not real directional momentum.

The ATC KCBS adds two meaningful upgrades over the generic version:

[b]1. HMA-Smoothed Basis[/b]

The channel's center line uses a Hull Moving Average (HMA) instead of the standard simple moving average (SMA) or exponential moving average (EMA) found in most retail Keltner tools. HMA smoothing reduces lag without sacrificing responsiveness, so the basis line tracks price structure more accurately — and the channel bands it drives are positioned more precisely as a result.

[b]2. Z-Score Normalized Volume Gate[/b]

This is the core enhancement. Before any breakout gets confirmed, volume on that bar is measured against a rolling statistical baseline — specifically, a Z-score calculated against the trailing volume mean and standard deviation. A breakout only gets flagged if volume is sufficiently elevated above that baseline in statistical terms.

This matters because a price close above the upper band with average or below-average volume is a very different event than the same close accompanied by a volume spike that is statistically exceptional relative to recent conditions. The volume gate filters the noise and focuses your attention on breakouts that have real conviction behind them.

You can toggle the volume gate on or off and adjust the Z-score threshold directly in the indicator settings.

________________________________________

[b]What You See on the Chart[/b]

The ATC KCBS overlays directly on your price chart and renders the following:

[b]The Channel[/b]

Three lines form the Keltner structure: the HMA basis in gold, and the upper and lower bands flanking it. The interior of the channel fills with a subtle color that reflects the current market state, making it easy to see at a glance whether conditions are bullish, bearish, compressing, or expanding.

[b]Regime Color Coding[/b]

The channel fill, band colors, and background tint all update dynamically to communicate the current market regime:

•	Green tones indicate an active bullish breakout bias
•	Red tones indicate an active bearish breakout bias
•	Blue tones indicate a channel expansion regime (rising volatility)
•	Grey tones indicate a channel compression regime (contracting volatility, potential coiling before a move)
•	Gold (default) indicates a neutral, ready state

This color system means you can scan your chart and immediately understand the context without reading anything. Green channel = bullish momentum active. Grey channel = market coiling.

[b]Breakout Markers[/b]

When a confirmed breakout fires — meaning price has closed beyond the band AND volume has passed the Z-score threshold — the indicator places labeled markers directly on the chart at that bar. Bullish breakouts receive a green triangle and an "LONG" label. Bearish breakouts receive a red triangle and an "SHORT" label.

These markers only appear when both conditions are met. If the volume gate doesn't pass, no marker appears, even if price is outside the band.

[b]Breakout Tags[/b]

In addition to the edge markers, the indicator plots branded "LONG CONFIRM" and "SHORT CONFIRM" labels near the breakout bar for additional visual clarity. You can control how many recent tags stay visible on the chart at one time via the settings.

[b]Bar and Background Tinting[/b]

During an active breakout bias, candle bars are tinted with the direction color (green for bullish, red for bearish) to help you maintain context as the bias holds. A subtle background tint reinforces the same state. Both are individually toggleable if you prefer a cleaner look.

________________________________________

[b]The HUD (Heads-Up Display)[/b]

The ATC KCBS contains a HUD panel that surfaces live data without cluttering your chart. The ATC KCBS HUD displays:

•	Live State — the current overall status of the indicator, displayed prominently in the header row. Possible values: BULLISH, BEARISH, COMPRESSION, EXPANSION, or READY.

•	Bias — whether a breakout bias is currently active, and how many bars remain in the bias hold window.

•	Regime — the current channel regime (Compression, Expansion, or Neutral).

•	Location — where price is relative to the channel right now: Inside Channel, Outside Upper, or Outside Lower.

•	Price vs Basis — whether price is currently above or below the HMA basis, expressed in ticks for precision.

•	Vol Gate — the real-time status of the volume gate. Shows PASS with the current Z-score when the threshold is met, or WAIT with the current Z-score when it is not. This is one of the most useful readouts in the HUD — it tells you exactly how close volume is to confirming the next breakout signal.

•	Width — current channel width expressed in ticks.

•	Width Z — the Z-score of current channel width relative to its own rolling history. Negative values indicate the channel is narrower than usual (compression). Positive values indicate it is wider than usual (expansion).

The HUD is available in dark and light themes and can be positioned in any corner of the chart.

________________________________________

[b]The Regime Engine[/b]

Beneath the visual layer, the ATC KCBS tracks a volatility regime state based on where the channel width Z-score sits relative to empirically-derived thresholds. This is not a binary switch — the regime uses a hysteresis band to prevent false flickering at the threshold boundaries.

•	Compression is flagged when channel width drops significantly below its historical 
average, indicating the market is coiling. Compression is often a precursor to a sharp directional move. When you see COMPRESSION on the HUD and in the grey channel, the market is telling you it is building energy.

•	Expansion is flagged when channel width rises significantly above its historical average, indicating volatility is increasing. Expansion during an active breakout is a confirmation of momentum. Expansion during a neutral bias can signal that conditions are becoming active.

•	Neutral is the default state between compression and expansion.

These regime states are displayed in the HUD, reflected in the channel color, and feed directly into the overall live state displayed in the header row.

________________________________________

[b]The Breakout Bias Hold[/b]

When a confirmed breakout fires, the indicator does not simply mark the bar and reset. It sets an active directional bias that persists for a configurable number of bars (default: 5). During the bias hold window, the HUD shows the direction and the bars remaining in the hold. The channel and background colors reflect the active bias throughout.

The bias clears early if price returns inside the channel before the hold window expires. This gives you a simple, clean way to track whether post-breakout price action is confirming the move or reversing it.

________________________________________

[b]Alerts[/b]

The ATC KCBS includes two configurable alert conditions:

•	Alert on Bullish Breakout — fires when a confirmed bullish breakout occurs (price closes above the upper band with volume gate passed)

•	Alert on Bearish Breakout — fires when a confirmed bearish breakout occurs (price closes below the lower band with volume gate passed)

Both can be toggled independently. To use them, set up your alert in TradingView and select the appropriate condition. The alert message includes the ticker and timeframe for easy identification in multi-alert setups.

________________________________________

[b]How to Trade With It[/b]

The ATC KCBS is a breakout signal tool. Its primary job is to tell you when a channel break has real participation behind it, and to maintain context about the market's current volatility regime. Here is a practical framework for using it:

[b]Step 1 — Read the Regime First[/b]

Before anything else, check the regime. If the HUD says COMPRESSION and the channel is grey, the market is coiling. This is a waiting state — not a trading state. Watch for a breakout to develop as the regime transitions.

If the HUD says EXPANSION and the channel is blue, volatility is already elevated. Breakouts in expansion regimes tend to be more energetic but can also be more erratic. Confirmation from your other confluence tools matters more here.

[b]Step 2 — Watch the Volume Gate[/b]

The Vol Gate row in the HUD is your pre-signal radar. When the market starts approaching the upper or lower band, watch the Vol Gate reading. If volume is already elevated (Z-score approaching or above the threshold), a breakout with confirmation is more likely. If volume is flat, a band touch is more likely to be noise.

[b]Step 3 — Wait for the Confirmation Marker[/b]

Do not trade the touch of the band. Trade the confirmed close. A confirmed breakout is defined as: price closes beyond the band AND the volume Z-score exceeds the threshold. The "LONG CONFIRM" or "SHORT CONFIRM" label on the chart is your signal.

[b]Step 4 — Assess Post-Breakout Price Action Within the Bias Hold[/b]

Once a confirmed breakout fires, monitor the bias hold countdown in the HUD. If price holds above the band (bullish) or below the band (bearish) during the hold window, the breakout is showing follow-through. If price returns inside the channel before the hold expires, treat it as a failed breakout and step aside.

[b]Step 5 — Use the Channel as a Reference After Entry[/b]

After entering on a confirmed breakout, the HMA basis becomes your key reference level. The basis is a smoothed representation of where the market's center of gravity is. Price above the basis on a bullish breakout is good. Price that retreats to the basis quickly after the breakout is a warning.

________________________________________

[b]Settings Reference[/b]

The indicator's settings are organized into clearly labeled groups:

Channel Configuration — Controls the HMA basis length, ATR length, and ATR multiplier. The defaults are optimized for QQQ on the 1-minute chart. Increase the basis length for smoother, slower channel response on higher timeframes.

Volume Gate — Toggle the volume confirmation requirement on or off. Adjust the Z-score lookback window and threshold. The default threshold (3.6) is calibrated for the optimized QQQ 1-minute profile. On other instruments or timeframes, a threshold between 1.0 and 2.0 is typically a reasonable starting point.

Session — Set the trading session and timezone. Defaults to the U.S. Regular Trading Hours session (9:30 AM — 4:00 PM Eastern). Extended hours users should adjust accordingly.

Visuals — Control all color settings, fill opacity, glow opacity, background tint, and bar tinting. Every visual element is independently adjustable. ATC's default palette (green, red, gold, grey, blue) is applied by default.

Signal Styling — Set the breakout tag text color and the maximum number of recent breakout tags kept on the chart.

Alerts — Toggle bullish and bearish alert conditions independently.

________________________________________

[b]Intended Instruments and Timeframes[/b]

Validated for: ES, NQ, CL, GC (futures), SPY, QQQ (ETFs), major FX pairs, large-cap equities
Recommended timeframes: 1-minute, 5-minute, 15-minute, 1-hour, 4-hour, Daily
Default profile optimized for: QQQ, 1-minute, Regular Trading Hours

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ATConcepts

// ========================================================================== 
// ATC Keltner Channel Breakout System — v1.3.0 Profile Selector
// Combined Defaults: QQQ 1m + QQQ 5m, RTH-focused, Extended Hours OFF
// Part of the ATC Free-Tier Library
//
// Author:   Ascend Trading Concepts
// License:  Redistribution requires attribution.
//
// Core Function:     Keltner Channel breakout detection
// ATC Enhancement:   HMA-smoothed basis + Z-score normalized volume gate
// Visual Advantage:  Premium gold-accent styling, elite HUD hierarchy,
//                    breakout markers/tags, polished alert messaging
//
// v1.3.0 Change Type: Profile selector merge
// - Combines v1.2.1 QQQ 1-minute optimized defaults
// - Combines v1.2.5 QQQ 5-minute optimized defaults
// - Adds profile selector: QQQ 1-Minute Profile / QQQ 5-Minute Profile / Custom Inputs
// - Preserves core breakout logic, regime logic, visuals, alerts, and HUD structure
//
// Intended Instruments: ES, NQ, CL, GC, SPY, QQQ, major FX pairs, large-cap equities
// Intended Timeframes:  1m, 5m, 15m, 1h, 4h, Daily
// ==========================================================================
//@version=6
indicator("ATC Keltner Channel Breakout System v1.3.0",
     shorttitle = "ATC KCBS",
     overlay = true,
     max_labels_count = 100,
     max_lines_count = 50,
     max_boxes_count = 50)

// ==========================================================================
// Section B — User Inputs
// ==========================================================================

// ----- Profile Selector -----
grpProfile = "Default Profile"

profileMode = input.string("QQQ 5-Minute Profile", "Default Profile",
     options = ["QQQ 1-Minute Profile", "QQQ 5-Minute Profile", "Custom Inputs"],
     tooltip = "Select QQQ 1-Minute Profile for the v1.2.1 optimized defaults, QQQ 5-Minute Profile for the v1.2.5 optimized defaults, or Custom Inputs to manually control the settings below.",
     group = grpProfile)

// ----- HUD Group -----
grpHUD   = "HUD"
showHUD  = input.bool(true, "Show HUD",
     tooltip = "Displays the heads-up display in the selected chart corner.",
     group = grpHUD)
hudPos   = input.string("Top Right", "HUD Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"],
     tooltip = "Position of the HUD panel on the chart.",
     group = grpHUD)
hudTheme = input.string("Dark", "HUD Theme",
     options = ["Dark", "Light"],
     tooltip = "Select Dark for dark chart themes, Light for light chart themes.",
     group = grpHUD)

// ----- Channel Configuration -----
grpChan  = "Channel Configuration"

customBasisLen = input.int(43, "Custom Basis Length",
     minval = 5, maxval = 200,
     tooltip = "Used only when Default Profile is set to Custom Inputs.",
     group = grpChan)
customAtrLen   = input.int(11, "Custom ATR Length",
     minval = 2, maxval = 100,
     tooltip = "Used only when Default Profile is set to Custom Inputs.",
     group = grpChan)
customAtrMult  = input.float(1.0, "Custom ATR Multiplier",
     minval = 0.5, maxval = 5.0, step = 0.1,
     tooltip = "Used only when Default Profile is set to Custom Inputs.",
     group = grpChan)

// ----- Volume Gate -----
grpVol   = "Volume Gate"

useVolGate  = input.bool(true, "Require Volume Confirmation",
     tooltip = "When enabled, a breakout is only flagged if volume Z-score exceeds the threshold.",
     group = grpVol)
customVolLookback = input.int(140, "Custom Volume Z-Score Lookback",
     minval = 10, maxval = 200,
     tooltip = "Used only when Default Profile is set to Custom Inputs.",
     group = grpVol)
customVolZThresh  = input.float(3.6, "Custom Volume Z-Score Threshold",
     minval = 0.0, maxval = 5.0, step = 0.1,
     tooltip = "Used only when Default Profile is set to Custom Inputs.",
     group = grpVol)

// ----- Effective Profile Values -----
basisLen = profileMode == "QQQ 1-Minute Profile" ? 43 :
     profileMode == "QQQ 5-Minute Profile" ? 34 : customBasisLen

atrLen = profileMode == "QQQ 1-Minute Profile" ? 11 :
     profileMode == "QQQ 5-Minute Profile" ? 10 : customAtrLen

atrMult = profileMode == "QQQ 1-Minute Profile" ? 1.0 :
     profileMode == "QQQ 5-Minute Profile" ? 1.0 : customAtrMult

volLookback = profileMode == "QQQ 1-Minute Profile" ? 140 :
     profileMode == "QQQ 5-Minute Profile" ? 30 : customVolLookback

volZThresh = profileMode == "QQQ 1-Minute Profile" ? 3.6 :
     profileMode == "QQQ 5-Minute Profile" ? 1.6 : customVolZThresh

// ----- Session -----
grpSess  = "Session"
sessDef  = input.session("0930-1600", "Session",
     tooltip = "Regular trading session used for session-aware calculations.",
     group = grpSess)
sessTZ   = input.string("America/New_York", "Session Timezone",
     options = ["America/New_York", "America/Chicago", "America/Los_Angeles",
                "Europe/London", "Asia/Tokyo", "Australia/Sydney"],
     tooltip = "Timezone for the session definition.",
     group = grpSess)

// ----- Visuals -----
grpVis   = "Visuals"
colBull  = input.color(#22C983, "Bullish Color",
     tooltip = "Primary bullish color used during active bullish states.",
     group = grpVis)
colBear  = input.color(#FF5F73, "Bearish Color",
     tooltip = "Primary bearish color used during active bearish states.",
     group = grpVis)
colBasis = input.color(#D4AF37, "Basis Color",
     tooltip = "Primary basis color.",
     group = grpVis)
colCompress = input.color(#8A93A5, "Compression Color",
     tooltip = "Color shown when the channel is compressing, indicating lower volatility.",
     group = grpVis)
colExpand   = input.color(#4D8DFF, "Expansion Color",
     tooltip = "Color shown when the channel is expanding, indicating rising volatility.",
     group = grpVis)
colAccent   = input.color(#D4AF37, "Accent Color",
     tooltip = "Primary HUD accent and highlight color.",
     group = grpVis)
showMarkers = input.bool(true, "Show Breakout Markers",
     tooltip = "Plot breakout markers at confirmed breakout bars.",
     group = grpVis)
showSignalTags = input.bool(true, "Show Breakout Tags",
     tooltip = "Adds confirmation tags on confirmed breakout bars.",
     group = grpVis)
showBarTint = input.bool(true, "Show State Bar Tint",
     tooltip = "Applies subtle candle tinting during active bullish or bearish bias.",
     group = grpVis)
showBackdrop = input.bool(true, "Show State Background Tint",
     tooltip = "Adds a subtle chart background tint during active states for faster visual recognition.",
     group = grpVis)
showOuterGlow = input.bool(true, "Show Outer Glow Fill",
     tooltip = "Adds a softer secondary fill between bands for extra depth.",
     group = grpVis)
fillOpacity = input.int(84, "Inner Fill Transparency",
     minval = 50, maxval = 100,
     tooltip = "Higher values = more transparent. Controls the basis-to-band fill.",
     group = grpVis)
glowOpacity = input.int(92, "Outer Glow Transparency",
     minval = 70, maxval = 100,
     tooltip = "Higher values = more transparent. Controls the band-to-band glow.",
     group = grpVis)
backdropOpacity = input.int(95, "Background Tint Transparency",
     minval = 85, maxval = 100,
     tooltip = "Higher values = more transparent. Controls the subtle background state tint.",
     group = grpVis)
barTintOpacity = input.int(72, "Bar Tint Transparency",
     minval = 0, maxval = 100,
     tooltip = "Higher values = more transparent. Controls ongoing bias candle tinting.",
     group = grpVis)

// ----- Signal Styling -----
grpSig = "Signal Styling"
tagTextColor = input.color(color.white, "Breakout Tag Text Color",
     tooltip = "Text color for the confirmation tags.",
     group = grpSig)
keepRecentTags = input.int(12, "Keep Recent Breakout Tags",
     minval = 0, maxval = 50,
     tooltip = "Maximum number of breakout labels kept on the chart at one time.",
     group = grpSig)

// ----- Alerts -----
grpAlert = "Alerts"
alertOnBull = input.bool(true, "Alert on Bullish Breakout",
     tooltip = "Enable alert condition for confirmed bullish breakouts.",
     group = grpAlert)
alertOnBear = input.bool(true, "Alert on Bearish Breakout",
     tooltip = "Enable alert condition for confirmed bearish breakouts.",
     group = grpAlert)

// ==========================================================================
// Section C — Core Calculations
// ==========================================================================

inSession  = not na(time(timeframe.period, sessDef, sessTZ))
newSession = inSession and not inSession[1]

basis = ta.hma(close, basisLen)
atrVal = ta.atr(atrLen)

upperBand = not na(basis) and not na(atrVal) ? basis + (atrMult * atrVal) : na
lowerBand = not na(basis) and not na(atrVal) ? basis - (atrMult * atrVal) : na

channelWidth = not na(upperBand) and not na(lowerBand) ? upperBand - lowerBand : na

widthLookback = 100
widthMean = ta.sma(channelWidth, widthLookback)
widthStd  = ta.stdev(channelWidth, widthLookback)

widthZ = not na(widthMean) and not na(widthStd) and widthStd != 0 ?
     (channelWidth - widthMean) / widthStd : na

volMean = ta.sma(volume, volLookback)
volStd  = ta.stdev(volume, volLookback)

volZ = not na(volMean) and not na(volStd) and volStd != 0 ?
     (volume - volMean) / volStd : 0.0

volumeConfirmed = useVolGate ? volZ >= volZThresh : true

rawBullBreak = not na(upperBand) and close > upperBand and close[1] <= upperBand[1]
rawBearBreak = not na(lowerBand) and close < lowerBand and close[1] >= lowerBand[1]

bullBreakout = rawBullBreak and volumeConfirmed
bearBreakout = rawBearBreak and volumeConfirmed

// ==========================================================================
// Section D — Enhancement Layer: Regime State + Hysteresis
// ==========================================================================

compEnter = -0.5
compExit  = -0.3
expEnter  =  0.5
expExit   =  0.3

var string regimeState = "Neutral"

if not na(widthZ)
    if regimeState == "Compression"
        if widthZ > compExit
            regimeState := "Neutral"
    else if regimeState == "Expansion"
        if widthZ < expExit
            regimeState := "Neutral"
    else
        if widthZ < compEnter
            regimeState := "Compression"
        else if widthZ > expEnter
            regimeState := "Expansion"

var string breakBias    = "None"
var int    biasBarsLeft = 0
biasHoldBars = 5

if bullBreakout
    breakBias    := "Bullish"
    biasBarsLeft := biasHoldBars
else if bearBreakout
    breakBias    := "Bearish"
    biasBarsLeft := biasHoldBars
else if biasBarsLeft > 0
    biasBarsLeft := biasBarsLeft - 1
else if biasBarsLeft == 0 and breakBias != "None"
    insideChannel = not na(upperBand) and not na(lowerBand) and close < upperBand and close > lowerBand
    if insideChannel
        breakBias := "None"

stateColor = regimeState == "Compression" ? colCompress :
     regimeState == "Expansion" ? colExpand : colBasis

activeColor = breakBias == "Bullish" ? colBull :
     breakBias == "Bearish" ? colBear : stateColor

basisColor = breakBias == "Bullish" ? colBull :
     breakBias == "Bearish" ? colBear : colBasis

innerFillColor = color.new(activeColor, fillOpacity)
color outerFillColor = showOuterGlow ? color.new(activeColor, glowOpacity) : na

color backdropColor = na
if showBackdrop
    backdropColor := breakBias == "Bullish" ? color.new(colBull, backdropOpacity) :
         breakBias == "Bearish" ? color.new(colBear, backdropOpacity) :
         regimeState == "Expansion" ? color.new(colExpand, backdropOpacity) :
         regimeState == "Compression" ? color.new(colCompress, 97) : na

color barTintColor = na
if showBarTint
    barTintColor := bullBreakout ? color.new(colBull, 0) :
         bearBreakout ? color.new(colBear, 0) :
         breakBias == "Bullish" ? color.new(colBull, barTintOpacity) :
         breakBias == "Bearish" ? color.new(colBear, barTintOpacity) : na

bullTagY = not na(lowerBand) ? lowerBand - (atrVal * 0.20) : na
bearTagY = not na(upperBand) ? upperBand + (atrVal * 0.20) : na
biasHoldDisplay = breakBias == "None" ? "—" : str.tostring(biasBarsLeft) + " bars"

// ==========================================================================
// Section E — Plotting & Visual Rendering
// ==========================================================================

bgcolor(backdropColor)
barcolor(barTintColor)

pBasis = plot(basis, "Basis (HMA)",
     color = color.new(basisColor, 0),
     linewidth = 2)

pUpper = plot(upperBand, "Upper Band",
     color = color.new(activeColor, 8),
     linewidth = 2)

pLower = plot(lowerBand, "Lower Band",
     color = color.new(activeColor, 8),
     linewidth = 2)

fill(pBasis, pUpper, color = innerFillColor)
fill(pBasis, pLower, color = innerFillColor)
fill(pUpper, pLower, color = outerFillColor)

plotshape(showMarkers and bullBreakout ? lowerBand : na,
     title = "Bullish Breakout Edge Marker",
     style = shape.triangleup,
     location = location.absolute,
     color = color.new(colBull, 0),
     size = size.tiny)

plotshape(showMarkers and bearBreakout ? upperBand : na,
     title = "Bearish Breakout Edge Marker",
     style = shape.triangledown,
     location = location.absolute,
     color = color.new(colBear, 0),
     size = size.tiny)

plotshape(showMarkers and bullBreakout ? bullTagY : na,
     title = "Bullish Breakout Confirmation",
     style = shape.labelup,
     location = location.absolute,
     color = color.new(colBull, 0),
     textcolor = tagTextColor,
     size = size.tiny,
     text = "LONG")

plotshape(showMarkers and bearBreakout ? bearTagY : na,
     title = "Bearish Breakout Confirmation",
     style = shape.labeldown,
     location = location.absolute,
     color = color.new(colBear, 0),
     textcolor = tagTextColor,
     size = size.tiny,
     text = "SHORT")

var array<label> breakoutTags = array.new<label>()
if showSignalTags
    if bullBreakout and not na(bullTagY)
        bullLabel = label.new(bar_index, bullTagY,
             text = "LONG\nCONFIRM",
             style = label.style_label_up,
             color = color.new(colBull, 0),
             textcolor = tagTextColor,
             size = size.tiny)
        array.push(breakoutTags, bullLabel)
    if bearBreakout and not na(bearTagY)
        bearLabel = label.new(bar_index, bearTagY,
             text = "SHORT\nCONFIRM",
             style = label.style_label_down,
             color = color.new(colBear, 0),
             textcolor = tagTextColor,
             size = size.tiny)
        array.push(breakoutTags, bearLabel)

while array.size(breakoutTags) > keepRecentTags
    oldLabel = array.shift(breakoutTags)
    label.delete(oldLabel)

if not showSignalTags and array.size(breakoutTags) > 0
    for i = 0 to array.size(breakoutTags) - 1
        label.delete(array.get(breakoutTags, i))
    array.clear(breakoutTags)

// ==========================================================================
// Section F — HUD
// ==========================================================================

formatTickDistance(float priceDelta) =>
    ticks = syminfo.mintick != 0 ? priceDelta / syminfo.mintick : 0.0
    sign  = ticks >= 0 ? "+" : ""
    sign + str.tostring(math.round(ticks)) + "t"

var table hud = na

if showHUD and barstate.islast
    if not na(hud)
        table.delete(hud)

    hudPosition = hudPos == "Top Right"    ? position.top_right    :
         hudPos == "Top Left"     ? position.top_left     :
         hudPos == "Bottom Right" ? position.bottom_right :
         position.bottom_left

    panelBg    = hudTheme == "Dark" ? color.rgb(12, 15, 22) : color.rgb(250, 250, 252)
    titleBg    = hudTheme == "Dark" ? color.rgb(18, 22, 31) : color.rgb(244, 245, 248)
    dividerBg  = hudTheme == "Dark" ? color.rgb(24, 28, 39) : color.rgb(236, 238, 242)
    txColor    = hudTheme == "Dark" ? color.white : color.rgb(34, 34, 34)
    subColor   = hudTheme == "Dark" ? color.rgb(184, 184, 184) : color.rgb(85, 85, 85)
    borderCol  = hudTheme == "Dark" ? color.rgb(44, 52, 66) : color.rgb(208, 213, 221)

    liveState = breakBias == "Bullish" ? "BULLISH" :
         breakBias == "Bearish" ? "BEARISH" :
         regimeState == "Compression" ? "COMPRESSION" :
         regimeState == "Expansion" ? "EXPANSION" : "READY"

    liveStateColor = breakBias == "Bullish" ? colBull :
         breakBias == "Bearish" ? colBear :
         regimeState == "Compression" ? colCompress :
         regimeState == "Expansion" ? colExpand : colAccent

    priceState = "—"
    priceStateColor = txColor
    if not na(basis)
        basisDelta = close - basis
        priceState := basisDelta > 0 ? "Above | " + formatTickDistance(basisDelta) :
             basisDelta < 0 ? "Below | " + formatTickDistance(basisDelta) : "At Basis"
        priceStateColor := basisDelta >= 0 ? colBull : colBear

    channelState = "—"
    channelStateColor = txColor
    if not na(upperBand) and close > upperBand
        channelState := "Outside Upper"
        channelStateColor := colBull
    else if not na(lowerBand) and close < lowerBand
        channelState := "Outside Lower"
        channelStateColor := colBear
    else if not na(upperBand) and not na(lowerBand)
        channelState := "Inside Channel"
        channelStateColor := subColor

    volZDisplay = not na(volZ) ? str.tostring(volZ, "#.00") : "—"
    volGateDisplay = not useVolGate ? "OFF" : volumeConfirmed ? "PASS | " + volZDisplay : "WAIT | " + volZDisplay
    volGateColor = not useVolGate ? subColor : volumeConfirmed ? colAccent : subColor

    widthDisplay = not na(channelWidth) ? formatTickDistance(channelWidth) : "—"
    widthZDisplay = not na(widthZ) ? str.tostring(widthZ, "#.00") : "—"

    biasDisplay = breakBias == "None" ? "Standby" : breakBias + " | " + biasHoldDisplay
    biasDisplayColor = breakBias == "Bullish" ? colBull : breakBias == "Bearish" ? colBear : subColor

    regimeDisplayColor = regimeState == "Compression" ? colCompress : regimeState == "Expansion" ? colExpand : txColor

    hud := table.new(hudPosition, 2, 10,
         bgcolor = panelBg,
         border_width = 1,
         border_color = borderCol,
         frame_width = 1,
         frame_color = colAccent)

    table.cell(hud, 0, 0, "KELTNER",
         text_color = colAccent,
         text_size = size.small,
         bgcolor = titleBg)
    table.cell(hud, 1, 0, liveState,
         text_color = liveStateColor,
         text_size = size.small,
         bgcolor = color.new(liveStateColor, 88))

    table.cell(hud, 0, 1, "Signal Desk",
         text_color = color.new(colAccent, 0),
         text_size = size.tiny,
         bgcolor = dividerBg)
    table.cell(hud, 1, 1, "Bias Focus",
         text_color = color.new(colAccent, 0),
         text_size = size.tiny,
         bgcolor = dividerBg)

    table.cell(hud, 0, 2, "Bias",
         text_color = subColor,
         text_size = size.small,
         bgcolor = panelBg)
    table.cell(hud, 1, 2, biasDisplay,
         text_color = biasDisplayColor,
         text_size = size.small,
         bgcolor = panelBg)

    table.cell(hud, 0, 3, "Regime",
         text_color = subColor,
         text_size = size.small,
         bgcolor = panelBg)
    table.cell(hud, 1, 3, regimeState,
         text_color = regimeDisplayColor,
         text_size = size.small,
         bgcolor = panelBg)

    table.cell(hud, 0, 4, "Location",
         text_color = subColor,
         text_size = size.small,
         bgcolor = panelBg)
    table.cell(hud, 1, 4, channelState,
         text_color = channelStateColor,
         text_size = size.small,
         bgcolor = panelBg)

    table.cell(hud, 0, 5, "Structure",
         text_color = color.new(colAccent, 0),
         text_size = size.tiny,
         bgcolor = dividerBg)
    table.cell(hud, 1, 5, "Participation",
         text_color = color.new(colAccent, 0),
         text_size = size.tiny,
         bgcolor = dividerBg)

    table.cell(hud, 0, 6, "Price vs Basis",
         text_color = subColor,
         text_size = size.small,
         bgcolor = panelBg)
    table.cell(hud, 1, 6, priceState,
         text_color = priceStateColor,
         text_size = size.small,
         bgcolor = panelBg)

    table.cell(hud, 0, 7, "Vol Gate",
         text_color = subColor,
         text_size = size.small,
         bgcolor = panelBg)
    table.cell(hud, 1, 7, volGateDisplay,
         text_color = volGateColor,
         text_size = size.small,
         bgcolor = panelBg)

    table.cell(hud, 0, 8, "Width",
         text_color = subColor,
         text_size = size.small,
         bgcolor = panelBg)
    table.cell(hud, 1, 8, widthDisplay,
         text_color = txColor,
         text_size = size.small,
         bgcolor = panelBg)

    table.cell(hud, 0, 9, "Width Z",
         text_color = subColor,
         text_size = size.small,
         bgcolor = panelBg)
    table.cell(hud, 1, 9, widthZDisplay,
         text_color = txColor,
         text_size = size.small,
         bgcolor = panelBg)

// ==========================================================================
// Section G — Alerts
// ==========================================================================

alertcondition(alertOnBull and bullBreakout,
     title = "Keltner Breakout — Bullish Breakout Confirmed",
     message = "Keltner Channel Breakout System | Confirmed bullish breakout on {{ticker}} {{interval}}. Price closed above the upper Keltner band with volume confirmation active.")

alertcondition(alertOnBear and bearBreakout,
     title = "Keltner Breakout — Bearish Breakout Confirmed",
     message = "Keltner Channel Breakout System | Confirmed bearish breakout on {{ticker}} {{interval}}. Price closed below the lower Keltner band with volume confirmation active.")
````

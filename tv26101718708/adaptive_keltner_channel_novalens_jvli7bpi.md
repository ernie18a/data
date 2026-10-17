# Adaptive Keltner Channel [NovaLens]

- url: https://www.tradingview.com/script/JvLi7BPI-Adaptive-Keltner-Channel-NovaLens/
- type: indicator
- pine_id: PUB;75d7fe8a15b749aba4853cb5e1b125c4
- version: 1.0

## Description

Adaptive Keltner Channel detects when price is doing something exceptional versus simply moving within its expected range. It wraps price in ATR-based bands around an EMA center, optionally adjusts band width to the current volatility regime, and includes built-in squeeze detection and context-aware center reclaim signals.


════════════════════════════════════════════


◉ [b]HOW IT WORKS[/b]

The indicator builds on the Keltner Channel concept introduced by Chester Keltner (1960) and refined into the modern ATR-based variant by Linda Bradford Raschke:

[list]
[*][b]Center line[/b]: EMA of close
[*][b]Upper band[/b]: Center + multiplier x ATR
[*][b]Lower band[/b]: Center - multiplier x ATR
[/list]

In static mode, the multiplier is fixed:

Upper = EMA(Close, Length) + Multiplier x ATR
Lower = EMA(Close, Length) - Multiplier x ATR

In adaptive mode, the multiplier scales with the current ATR percentile rank. When ATR is low relative to recent history, the channel widens to filter routine noise. When ATR is already elevated, the channel tightens so a band break still represents a genuine expansion rather than getting absorbed inside an overly wide envelope.

This is the opposite of how Bollinger Bands behave. Bollinger Bands widen mechanically as volatility rises because they use standard deviation. The adaptive Keltner deliberately tightens its multiplier in high-vol regimes to preserve the usefulness of a breakout signal across different conditions.

The script also includes squeeze detection: when Bollinger Bands contract inside the Keltner Channel, it flags that volatility has compressed. Compressed conditions can precede larger-than-normal moves, though the squeeze does not indicate which direction or guarantee that the expansion will follow through.


════════════════════════════════════════════


◈ [b]HOW TO READ IT[/b]

[b]Band interactions:[/b]
[list]
[*]Price above upper band: upside expansion beyond the recent channel range
[*]Price below lower band: downside expansion beyond the recent channel range
[/list]

[b]Center reclaims and losses:[/b]
[list]
[*]Price reclaims center after a lower-band touch: downside extension did not hold
[*]Price loses center after an upper-band touch: upside extension did not hold
[/list]

These are not simple center crosses. The indicator tracks which band was touched most recently and only fires a reclaim or loss signal when that context is present. A center cross after sideways consolidation is a different event from a center cross following a failed band extension. This logic filters out a significant amount of the noise that makes naive center-cross signals unreliable.

[b]Squeeze and trend:[/b]
[list]
[*]Orange fill and center color: squeeze is active, volatility compressed
[*]Squeeze intensity builds visually as the compression persists
[*]Green center line: short-term trend pressure is up
[*]Red center line: short-term trend pressure is down
[*]Teal X-cross marker below bar: squeeze just released
[/list]

The outer bands are intentionally neutral gray. Direction comes from price behavior, center slope, and the interaction signals.


════════════════════════════════════════════


✦ [b]HOW WE USE IT: VOLATILITY CONTEXT[/b]

We use this channel as a volatility context layer rather than a standalone signal source. The question it answers: is the current price behavior routine or exceptional for this market's recent history?

When the channel is in squeeze state and the info panel reads "Compressed" with the bar count climbing, that is a low-conviction environment for new directional entries but a high-attention environment for preparation. On BTC 4H with Balanced settings, in our observation squeeze conditions often persist for 8-15 bars while the fill gradually deepens to orange. During that window, we are watching, not acting.

When the squeeze releases and price pushes through a band with the center slope already confirming, that combination (squeeze release, band break, center slope alignment) carries more weight than a random band break during an already-volatile session. No single element alone is the trigger.

On the reversion side, when price flushes to the lower band and then reclaims the center, the state-aware logic recognizes that the last band touched was the lower band. It treats that center cross as a meaningful reclaim rather than noise. This matters because price often consolidates between a band touch and the center for several bars. A naive center-cross indicator would miss the connection. This one remembers.

The practical workflow: use the channel to characterize whether price is inside its expected range, expanding beyond it, or compressed. Layer your directional signals on top of that context.


════════════════════════════════════════════


✦ [b]OTHER APPLICATIONS[/b]

[list]
[*][b]Breakout context[/b]: band breaks after compression, confirmed by center slope and price acceptance on subsequent bars
[*][b]Mean reversion[/b]: in sideways conditions, band touches can frame moves back toward the center, especially when the center line is flat rather than sloped
[*][b]Trend pullbacks[/b]: the center line as a dynamic support/resistance during directional moves
[*][b]Risk management[/b]: use the center or opposite band as a trailing reference that adapts to current volatility
[*][b]Alert-driven workflow[/b]: set alerts on squeeze start, squeeze release, breakout up/down, or center reclaim/loss and check the chart only when conditions change
[/list]


════════════════════════════════════════════


⚙ [b]GETTING STARTED[/b]

Adaptive Keltner Channel ships with reactivity presets:

[list]
[*][b]Reactive[/b]: EMA 10 / Mult 1.5 / ATR 10. Tighter bands that respond quickly. Useful when you want the channel to track recent behavior more closely.
[*][b]Balanced[/b]: EMA 20 / Mult 2.0 / ATR 14. The default. A reasonable starting point for most assets. Start here unless you have a specific reason not to.
[*][b]Smooth[/b]: EMA 50 / Mult 2.5 / ATR 20. Wider and calmer. Useful on higher timeframes or when you want the channel to only flag larger-scale events.
[*][b]Custom[/b]: Full manual control for specific setups.
[/list]

[b]Core settings:[/b]
[list]
[*][b]Reactivity[/b]: selects the behavior profile. Start with Balanced.
[*][b]Adaptive Band Width[/b]: on = regime-aware scaling, off = classic static Keltner. The difference is most visible when the market transitions between calm and volatile periods.
[*][b]Adaptive Lookback[/b]: how far back ATR is ranked. 100 bars covers roughly 5 months on daily, 4 days on 1H. Increase for assets with long volatility cycles. Decrease for assets that shift regimes quickly.
[/list]

[b]Adaptive tuning:[/b]
[list]
[*][b]Adaptive Max Multiplier (calm)[/b]: scales your base multiplier up in quiet conditions. Default 1.25 means the effective multiplier becomes 25% wider than the base (e.g., base 2.0 becomes 2.5). Increase if you are seeing too many false band touches during low-vol periods.
[*][b]Adaptive Min Multiplier (vol)[/b]: scales your base multiplier down in volatile conditions. Default 0.75 means the effective multiplier becomes 25% narrower than the base (e.g., base 2.0 becomes 1.5). Decrease if breakouts are still not clearing the bands during high-vol sessions.
[/list]

[b]Squeeze settings:[/b]
[list]
[*][b]Show Squeeze Detection[/b]: enables Bollinger-inside-Keltner squeeze logic
[*][b]BB Length / BB Multiplier[/b]: default 20/2.0 matches standard Bollinger. Generally no reason to change unless comparing against a non-standard Bollinger on the same chart.
[/list]

[b]Display:[/b]
[list]
[*][b]Show Info Panel[/b]: 4-row panel showing current state, volatility, trend direction, and price location as a channel percentage. Hover any label for a plain-English explanation.
[*][b]Show Squeeze Background[/b]: subtle background tint during active squeezes. Off by default.
[*][b]Light Theme Mode[/b]: adapts panel colors for light backgrounds.
[/list]


════════════════════════════════════════════ 

△ [b]LIMITATIONS[/b]

[list]
[*][b]Lagging structure[/b]: the center is an EMA and the bands use historical ATR. Sharp reversals can outrun the channel. This is inherent to any channel overlay.
[*][b]Squeeze is not directional[/b]: a squeeze tells you volatility has contracted, not which way the next move goes. The release can fail, reverse, or stall.
[*][b]False band breaks[/b]: in noisy conditions, price can poke through a band and return inside on the next bar. Adaptive scaling is designed to help with this, but does not eliminate it.
[*][b]Mean-reversion risk in trends[/b]: using center reclaims as reversion entries during a strong trend can stay wrong longer than expected. The center keeps moving with the trend.
[*][b]History requirement[/b]: adaptive scaling needs enough bars to fill the Adaptive Lookback window (default 100 bars) before it adjusts properly. Squeeze detection also needs sufficient Bollinger and Keltner history. Early bars on any chart will have less reliable readings.
[/list]


════════════════════════════════════════════


🔔 [b]ALERTS[/b]

Six alert conditions are built in so you can monitor without watching the chart:

[list]
[*][b]Breakout Up / Breakout Down[/b]: price closes beyond the upper or lower band
[*][b]Squeeze Started[/b]: Bollinger Bands have contracted inside the Keltner Channel
[*][b]Squeeze Released[/b]: squeeze just ended, volatility expanding
[*][b]Center Reclaim[/b]: price crossed above the center after previously touching the lower band
[*][b]Center Loss[/b]: price crossed below the center after previously touching the upper band
[/list]

All alerts fire on bar close by default for confirmed signals.


════════════════════════════════════════════


⌁ [b]NOTES[/b]

[list]
[*]Original concept by Chester Keltner (1960), modern ATR-based variant by Linda Bradford Raschke
[*]Uses ATR-based bands with optional volatility-regime adaptation via percentile ranking
[*]Includes Bollinger-inside-Keltner squeeze detection with visual intensity buildup
[*]Center reclaim/loss signals use state-aware logic that tracks which band was last touched
[*]Values update in real time on the current bar and are confirmed at bar close
[*]Open-source: inspect the logic directly in the Pine editor
[/list]

## Source Code

````pine
// This Pine Script™ source code is subject to the terms of the Mozilla Public License 2.0
// © NovaLens

//@version=6

// ──────────────────────────────────────────────────────────────────────────────
// Indicator:  Adaptive Keltner Channel [NovaLens]
// Version:    3.0.0
// Release:    2026-04
// Author:     NovaLens Quantitative Research
// ──────────────────────────────────────────────────────────────────────────────
// Adaptive volatility channel with regime-aware band width and built-in
// squeeze detection. EMA center (Raschke variant) with ATR-based bands that
// can auto-scale to current volatility regime. Squeeze logic detects when
// Bollinger Bands compress inside the Keltner Channel — a signal that
// volatility is coiled and a directional move is likely.
//
// Core formulas:
//   center = EMA(close, length)
//   bands  = center ± (baseMult × adaptiveScale) × ATR
//   adaptiveScale = maxMult - (maxMult - minMult) × atrPercentRank/100
//
// Squeeze: BB upper < KC upper AND BB lower > KC lower
// Squeeze intensity (0 → 1) builds visually as the squeeze persists.
//
// Use Cases:
// - Spot regime compression (squeeze) and the volatility expansion that follows
// - Filter breakout trades with band crosses
// - Mean reversion entries on center reclaim after band touches
// - Trail stops on bands for dynamic risk management
// ──────────────────────────────────────────────────────────────────────────────

indicator("Adaptive Keltner Channel [NovaLens]", shorttitle="Adaptive KC [NovaLens]", overlay=true, precision=2, max_labels_count=50)

// ─── Brand Info ─────────────────────────────────────────────────────────────
string BRAND_NAME    = "NovaLens"
string BRAND_ENTITY  = "NovaLens Quantitative Research"
string productCode   = "KC-01"
string productTier   = "Free"

// ─── Colors ─────────────────────────────────────────────────────────────────
color C_TEAL   = color.rgb(0, 212, 170)
color C_ORANGE = color.rgb(255, 152, 0)
color C_GRAY   = color.rgb(120, 123, 134)
color C_GREEN  = color.rgb(38, 166, 154)
color C_RED    = color.rgb(239, 83, 80)
color C_WHITE  = color.rgb(255, 255, 255)

// ─── Reactivity ─────────────────────────────────────────────────────────────
string PROF_REACT  = "Reactive"
string PROF_BAL    = "Balanced"
string PROF_SMOOTH = "Smooth"
string PROF_MAN    = "Custom"

string reactivityTip = "Sets how reactive the bands are. Each preset bundles EMA length / ATR multiplier / ATR period.\n\n• Reactive (10 / 1.5 / 10)\n   Bands hug recent price closely.\n\n• Balanced (20 / 2.0 / 14)\n   Recommended default.\n\n• Smooth (50 / 2.5 / 20)\n   Bands ride above the noise.\n\n• Custom\n   Set your own values below.\n\nValues are in BARS, not minutes — '20' means 20 chart bars (≈ 20 hours on 1H, ≈ 4 weeks on daily). Pick based on how you want the bands to behave on your current chart."

profile = input.string(PROF_BAL, "Reactivity", options=[PROF_REACT, PROF_BAL, PROF_SMOOTH, PROF_MAN], group="Reactivity", tooltip=reactivityTip)

// ─── Custom Parameters ─────────────────────────────────────────────────────
manLength     = input.int(20, "KC Length", minval=2, group="Custom Parameters", tooltip="Only active in Custom reactivity. Center EMA period (in bars).")
manMultiplier = input.float(2.0, "ATR Multiplier (base)", minval=0.1, step=0.1, group="Custom Parameters", tooltip="Only active in Custom reactivity. Base band width multiplier — when Adaptive Band Width is on, this is scaled by the adaptive range (default 0.75×–1.25×) based on current ATR regime.")
manAtrPeriod  = input.int(14, "ATR Period", minval=1, group="Custom Parameters", tooltip="Only active in Custom reactivity. Average True Range lookback (in bars).")

// ─── Adaptive Engine ────────────────────────────────────────────────────────
useAdaptive      = input.bool(false, "Adaptive Band Width", group="Adaptive", tooltip="When on: bands auto-widen in calm regimes to filter noise, tighten in volatile regimes so real breakouts still pierce. Scaling is based on the current ATR percentile rank.\n\nOff = classic static Keltner Channel.")
adaptiveMaxMult  = input.float(1.25, "Adaptive Max Multiplier (calm)", minval=1.0, maxval=2.0, step=0.05, group="Adaptive", tooltip="Multiplier applied to the base when ATR is at its lowest (calm regime). Default 1.25 widens bands by 25% in quiet markets.")
adaptiveMinMult  = input.float(0.75, "Adaptive Min Multiplier (vol)", minval=0.25, maxval=1.0, step=0.05, group="Adaptive", tooltip="Multiplier applied to the base when ATR is at its highest (volatile regime). Default 0.75 tightens bands by 25% so breakouts still mean something.")
adaptiveLookback = input.int(100, "Adaptive Lookback", minval=20, group="Adaptive", tooltip="Bars used to rank current ATR. 100 ≈ 5 months on daily, ≈ 4 days on 1H, ≈ 100 minutes on 1min. Adaptive scaling only kicks in after this window fills (earlier bars use static base multiplier).")

// ─── Squeeze ────────────────────────────────────────────────────────────────
showSqueeze = input.bool(true, "Show Squeeze Detection", group="Squeeze", tooltip="A squeeze fires when price stops moving much — Bollinger Bands (stddev) contract inside the Keltner Channels (ATR). The market is coiling.\n\nWhat happens after: volatility usually expands, often with a strong directional move. The squeeze does NOT predict direction — only that a move is coming.\n\nHow to use: wait for the release (✕ marker below the bar), then trade in the direction price first breaks. Some wait for a close past one of the bands to confirm.\n\nThe fill and center color deepen as the squeeze persists, so you can see how built-up the compression is.")
bbLength    = input.int(20, "BB Length", minval=2, group="Squeeze", tooltip="Bollinger Band period for squeeze comparison.")
bbMult      = input.float(2.0, "BB Multiplier", minval=0.1, step=0.1, group="Squeeze", tooltip="Bollinger Band standard deviation multiplier.")

// ─── Display ────────────────────────────────────────────────────────────────
showInfoPanel = input.bool(true, "Show Info Panel", group="Display", tooltip="Plain-English state panel: volatility, trend, and price location. Hover any row label in the panel to see what that metric means.")
lightTheme    = input.bool(false, "Light Theme Mode", group="Display", tooltip="Adapt panel colors for light chart backgrounds.")
showSqzBg     = input.bool(false, "Show Squeeze Background", group="Display", tooltip="Subtle background tint during squeeze bars. Off by default for cleaner charts.")

// ─── Resolve Reactivity ────────────────────────────────────────────────────
kcLength = switch profile
    PROF_REACT  => 10
    PROF_BAL    => 20
    PROF_SMOOTH => 50
    => manLength

baseMult = switch profile
    PROF_REACT  => 1.5
    PROF_BAL    => 2.0
    PROF_SMOOTH => 2.5
    => manMultiplier

atrPer = switch profile
    PROF_REACT  => 10
    PROF_BAL    => 14
    PROF_SMOOTH => 20
    => manAtrPeriod

// ─── Calculation ────────────────────────────────────────────────────────────
kcCenter = ta.ema(close, kcLength)
atrValue = ta.atr(atrPer)

atrPctRank    = ta.percentrank(atrValue, adaptiveLookback)
adaptiveScale = useAdaptive and not na(atrPctRank) ? adaptiveMaxMult - (adaptiveMaxMult - adaptiveMinMult) * (atrPctRank / 100.0) : 1.0
effectiveMult = baseMult * adaptiveScale

kcUpper = kcCenter + effectiveMult * atrValue
kcLower = kcCenter - effectiveMult * atrValue

bandWidth = not na(kcCenter) and kcCenter != 0 ? ((kcUpper - kcLower) / kcCenter) * 100 : na
bwRank    = ta.percentrank(bandWidth, 100)

chanRange = kcUpper - kcLower
pricePos  = not na(chanRange) and chanRange != 0 ? ((close - kcLower) / chanRange) * 100 : na

centerSlope = not na(kcCenter[3]) ? kcCenter - kcCenter[3] : na
centerUp    = not na(centerSlope) and centerSlope > 0
centerDown  = not na(centerSlope) and centerSlope < 0

priceAbove = not na(kcUpper) and close > kcUpper
priceBelow = not na(kcLower) and close < kcLower

// Band-hit memory: persists the most recent band touched so center reclaim/loss
// alerts catch reclaims that come after consolidation, not just the bar
// immediately after a band touch.
var int lastBandHit = 0
if priceAbove
    lastBandHit := 1
else if priceBelow
    lastBandHit := -1

bool validReclaim = ta.crossover(close, kcCenter) and lastBandHit == -1
bool validLoss    = ta.crossunder(close, kcCenter) and lastBandHit == 1
if validReclaim or validLoss
    lastBandHit := 0

// ─── Squeeze Detection ──────────────────────────────────────────────────────
bbBasis = ta.sma(close, bbLength)
bbDev   = ta.stdev(close, bbLength) * bbMult
bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev

sqzOn  = showSqueeze and not na(kcUpper) and not na(bbUpper) and (bbUpper < kcUpper) and (bbLower > kcLower)
sqzOff = showSqueeze and not sqzOn and not na(kcUpper)

var int sqzBars = 0
sqzBars := sqzOn ? sqzBars + 1 : 0

sqzFire = sqzOff and sqzOn[1]

// Intensity 0 → 1 builds over ~20 bars; drives fill + center color depth.
sqzIntensity = sqzOn ? math.min(1.0, sqzBars / 20.0) : 0.0

// ─── Visual State ───────────────────────────────────────────────────────────
sqzFillT  = math.round(95 - 15 * sqzIntensity)
fillColor = sqzOn ? color.new(C_ORANGE, sqzFillT) : color.new(C_TEAL, 95)

sqzCenterT  = math.round(80 - 60 * sqzIntensity)
centerColor = sqzOn ? color.new(C_ORANGE, sqzCenterT) : centerUp ? C_GREEN : centerDown ? C_RED : C_TEAL

// ─── Plots ──────────────────────────────────────────────────────────────────
p_center = plot(kcCenter, "KC Center", color=centerColor, linewidth=2)
p_upper  = plot(kcUpper, "KC Upper", color=color.new(C_GRAY, 40), linewidth=1)
p_lower  = plot(kcLower, "KC Lower", color=color.new(C_GRAY, 40), linewidth=1)

fill(p_upper, p_lower, color=fillColor, title="KC Zone")

bgcolor(showSqzBg and sqzOn ? color.new(C_ORANGE, 96) : na, title="Squeeze Background")

plotshape(sqzFire, title="Squeeze Released", style=shape.xcross, location=location.belowbar, color=C_TEAL, size=size.tiny)
plotshape(priceAbove and not priceAbove[1], title="Breakout Up", style=shape.triangleup, location=location.belowbar, color=color.new(C_GREEN, 30), size=size.tiny)
plotshape(priceBelow and not priceBelow[1], title="Breakout Down", style=shape.triangledown, location=location.abovebar, color=color.new(C_RED, 30), size=size.tiny)

// ─── Info Panel ─────────────────────────────────────────────────────────────
if barstate.islast and showInfoPanel
    string stateBadge = priceAbove ? "▲ BREAKOUT" : priceBelow ? "▼ BREAKOUT" : sqzOn ? "◆ SQUEEZE" : "· INSIDE"
    color stateColor  = priceAbove ? C_GREEN : priceBelow ? C_RED : sqzOn ? C_ORANGE : C_TEAL

    string volStr = "—"
    color volColor = C_GRAY
    if sqzOn
        volStr := "Compressed · " + str.tostring(sqzBars) + " bars"
        volColor := C_ORANGE
    else if sqzFire
        volStr := "Release fired"
        volColor := C_TEAL
    else if not na(bwRank)
        if bwRank < 20
            volStr := "Coiling (narrow)"
            volColor := C_WHITE
        else if bwRank > 80
            volStr := "Expanded"
            volColor := C_WHITE
        else
            volStr := "Normal"
            volColor := C_WHITE

    string trendStr = centerUp ? "↑ Up" : centerDown ? "↓ Down" : "→ Sideways"
    color trendColor = centerUp ? C_GREEN : centerDown ? C_RED : C_GRAY

    string priceStr = "—"
    color priceColor = C_GRAY
    if not na(pricePos)
        string pct = str.tostring(pricePos, "#.#") + "%"
        if pricePos > 100
            priceStr := "Above upper band (" + pct + ")"
            priceColor := C_GREEN
        else if pricePos < 0
            priceStr := "Below lower band (" + pct + ")"
            priceColor := C_RED
        else
            priceStr := "Inside channel (" + pct + ")"
            priceColor := C_WHITE

    color panelBg     = lightTheme ? color.new(color.white, 5) : color.new(color.black, 15)
    color panelBorder = lightTheme ? color.new(color.gray, 50) : color.new(C_GRAY, 70)
    color panelFrame  = lightTheme ? color.new(color.gray, 30) : color.new(C_GRAY, 50)
    color titleColor  = lightTheme ? color.black : C_WHITE
    color labelColor  = lightTheme ? color.new(color.gray, 0) : C_GRAY

    string tipTitle = "State: ▲/▼ BREAKOUT = price outside the channel. ◆ SQUEEZE = volatility compressed (BB inside KC). · INSIDE = price inside bands, no squeeze."
    string tipVol   = "Volatility state. Compressed = BB has contracted inside KC (squeeze active). Release fired = squeeze just ended. Coiling / Normal / Expanded = channel width percentile vs last 100 bars (narrow → mid → wide)."
    string tipTrend = "Short-term trend direction from the center line (EMA) slope over the last 3 bars. ↑ Up = center rising, ↓ Down = falling, → Sideways = flat."
    string tipPrice = "Where price sits relative to the channel. 0% = at lower band, 50% = at center, 100% = at upper band. Above 100% or below 0% means price has broken out of the channel."

    var table infoPanel = table.new(position.top_right, 2, 4, bgcolor=panelBg, border_width=1, border_color=panelBorder, frame_width=2, frame_color=panelFrame)

    table.cell(infoPanel, 0, 0, "Keltner Channel", text_color=titleColor, text_size=size.large, text_halign=text.align_left, tooltip=tipTitle)
    table.cell(infoPanel, 1, 0, stateBadge, text_color=stateColor, text_size=size.large, text_halign=text.align_right, tooltip=tipTitle)

    table.cell(infoPanel, 0, 1, "Volatility", text_color=labelColor, text_size=size.normal, text_halign=text.align_left, tooltip=tipVol)
    table.cell(infoPanel, 1, 1, volStr, text_color=volColor, text_size=size.normal, text_halign=text.align_right, tooltip=tipVol)

    table.cell(infoPanel, 0, 2, "Trend", text_color=labelColor, text_size=size.normal, text_halign=text.align_left, tooltip=tipTrend)
    table.cell(infoPanel, 1, 2, trendStr, text_color=trendColor, text_size=size.normal, text_halign=text.align_right, tooltip=tipTrend)

    table.cell(infoPanel, 0, 3, "Price", text_color=labelColor, text_size=size.normal, text_halign=text.align_left, tooltip=tipPrice)
    table.cell(infoPanel, 1, 3, priceStr, text_color=priceColor, text_size=size.normal, text_halign=text.align_right, tooltip=tipPrice)

// ─── Alerts ─────────────────────────────────────────────────────────────────
alertcondition(ta.crossover(close, kcUpper), "KC Breakout Up", "Price broke above upper Keltner band")
alertcondition(ta.crossunder(close, kcLower), "KC Breakout Down", "Price broke below lower Keltner band")
alertcondition(sqzFire, "Squeeze Released", "Volatility squeeze released — directional move likely")
alertcondition(sqzOn and not sqzOn[1], "Squeeze Started", "Volatility squeeze detected — Bollinger Bands compressed inside Keltner Channel")
alertcondition(validReclaim, "KC Reclaim Center", "Price reclaimed center after lower-band touch")
alertcondition(validLoss, "KC Lost Center", "Price lost center after upper-band touch")
````

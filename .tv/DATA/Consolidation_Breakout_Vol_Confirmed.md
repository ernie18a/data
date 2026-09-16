<!-- tradingview-pine-id: PUB;cbf67bbae2fa4a70b15b7f220c9e4b52 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Consolidation Breakout (Vol Confirmed)

Source: https://www.tradingview.com/script/pSnzilzG-Consolidation-Breakout-with-Volume-Confirmation-Daily/

## Description

What this does
This indicator detects consolidation zones on price charts and flags breakouts confirmed by volume — in both directions (bullish breakouts and bearish breakdowns).

Methodology

[*]Scans a flexible lookback window (10–30 bars, adjustable) for the tightest qualifying price range, so it captures both short flags and multi-week bases without needing separate settings for each.
[*]A zone is drawn once a window's high-low range falls under a configurable tightness threshold (default 8%).
[*]Zones where average volume during consolidation is below its own 50-bar baseline are marked in green ("volume dry-up") as a soft indicator of higher conviction — this is informational, not a hard filter.
[*]A breakout fires on a close beyond the zone boundary, confirmed by volume at least 1.5x (configurable) the zone's average — symmetric logic for both long breakouts and short breakdowns.
[*]A cooldown period after each breakout reduces false re-triggering during choppy conditions.
[*]Each breakout label also tags candle quality (strong/weak close within the bar's range) and whether the move gapped through the zone or ground through it intraday — additional price-action context alongside the volume read.

Timeframe
Designed and tested on the Daily timeframe. All settings (lookback, cooldown, volume baseline) are counted in bars, so they do not scale automatically across timeframes — a 5-bar cooldown means 5 trading days on Daily, but a very different real-world duration on 4H, Weekly, or other timeframes. If you use this on a different timeframe, re-tune the inputs rather than relying on the defaults.

Alerts
Built-in alert conditions for both bullish breakouts and bearish breakdowns — set once per chart to get notified without watching live.

Disclaimer
This is a screening/context tool, not a standalone buy/sell signal. All thresholds are adjustable in settings — test and tune them for the instruments you trade. Always confirm with your own analysis and risk management. Not financial advice.

---

## Source Code

````pine
//@version=6
indicator("Consolidation Breakout (Vol Confirmed)", overlay=true, max_boxes_count=200, max_labels_count=200)

// ================= INPUTS =================
minLB       = input.int(10, "Min Lookback (days)", minval=3, group="Consolidation Zone")
maxLB       = input.int(30, "Max Lookback (days)", minval=5, group="Consolidation Zone")
maxRangePct = input.float(8.0, "Max Range % (tightness)", minval=0.5, step=0.5, group="Consolidation Zone")

dryUpLookback = input.int(50, "Volume Dry-Up Baseline (days)", minval=10, group="Volume")
dryUpRatio    = input.float(0.8, "Dry-Up Ratio (zone avg vol < baseline x this)", minval=0.1, maxval=1.0, step=0.05, group="Volume")
volMult       = input.float(1.5, "Breakout Volume Multiple (x zone avg vol)", minval=1.0, step=0.1, group="Volume")

showZones     = input.bool(true, "Show Zone Boxes", group="Display")
showLabels    = input.bool(true, "Show Breakout Labels", group="Display")
showBg        = input.bool(true, "Highlight Bars Inside Active Zone", group="Display")

cooldownBars  = input.int(5, "Cooldown After Breakout (days, blocks new zone forming)", minval=0, group="Behavior")

strongCloseThresh = input.float(0.7, "Strong Close Threshold (0.5-1.0)", minval=0.5, maxval=1.0, step=0.05, group="Price Action")

// ================= STATE =================
var float zTop      = na
var float zBot      = na
var float zAvgVol   = na
var int   zStartBar = na
var int   zEndBar   = na
var bool  zDryUp    = false
var bool  zActive   = false
var box   liveBox   = na
var int   lastBOBar = na

baseline = ta.sma(volume, dryUpLookback)

// ================= BREAKOUT CHECK (against the currently established zone) =================
longBO  = false
shortBO = false

if zActive
    if close > zTop and volume >= zAvgVol * volMult
        longBO := true
    else if close < zBot and volume >= zAvgVol * volMult
        shortBO := true

// ================= FINALIZE ON BREAKOUT =================
if (longBO or shortBO) and zActive
    if showZones and not na(liveBox)
        box.set_right(liveBox, bar_index)
    if showLabels
        volX = zAvgVol != 0 ? volume / zAvgVol : na
        barRange = high - low
        closeLoc = barRange != 0 ? (close - low) / barRange : 0.5
        isStrongClose = longBO ? closeLoc >= strongCloseThresh : closeLoc <= (1 - strongCloseThresh)
        isGap = longBO ? open > zTop : open < zBot
        closeTxt = isStrongClose ? "Strong close" : "Weak close"
        gapTxt = isGap ? "Gap" : "Grind"
        txt = (longBO ? "Breakout ↑" : "Breakdown ↓") + (na(volX) ? "" : "\nVol " + str.tostring(math.round(volX * 10) / 10) + "x") + "\n" + closeTxt + ", " + gapTxt
        label.new(bar_index, longBO ? low : high, txt,
             style = longBO ? label.style_label_up : label.style_label_down,
             color = color.new(longBO ? color.green : color.red, 0),
             textcolor = color.white, size = size.small)
    zActive   := false
    liveBox   := na
    zTop      := na
    zBot      := na
    zAvgVol   := na
    zStartBar := na
    zEndBar   := na
    zDryUp    := false
    lastBOBar := bar_index
else if na(lastBOBar) or (bar_index - lastBOBar) >= cooldownBars
    // ================= SCAN FOR A QUALIFYING TIGHT WINDOW (flexible lookback, prefer the largest) =================
    foundTight  = false
    float bestHH      = na
    float bestLL      = na
    float bestAvgVol  = na
    bestL       = 0

    for L = maxLB to minLB
        hh  = ta.highest(high, L)
        ll  = ta.lowest(low, L)
        mid = (hh + ll) / 2
        rangePct = mid != 0 ? (hh - ll) / mid * 100 : 100.0
        if rangePct <= maxRangePct
            foundTight := true
            bestHH     := hh
            bestLL     := ll
            bestAvgVol := ta.sma(volume, L)
            bestL      := L
            break

    if foundTight
        if not zActive
            zStartBar := bar_index - bestL + 1
            zActive   := true
            if showZones
                liveBox := box.new(zStartBar, bestHH, bar_index, bestLL,
                     border_color = color.gray, bgcolor = color.new(color.gray, 90))
        zTop    := bestHH
        zBot    := bestLL
        zAvgVol := bestAvgVol
        zEndBar := bar_index
        zDryUp  := bestAvgVol < baseline * dryUpRatio
        if showZones and not na(liveBox)
            box.set_top(liveBox, zTop)
            box.set_bottom(liveBox, zBot)
            box.set_right(liveBox, bar_index)
            box.set_border_color(liveBox, zDryUp ? color.green : color.gray)
            box.set_bgcolor(liveBox, zDryUp ? color.new(color.green, 85) : color.new(color.gray, 90))
    else if zActive and (bar_index - zEndBar > maxLB)
        // zone gone stale (no breakout, just faded away) — freeze box as-is, reset state
        zActive   := false
        liveBox   := na
        zTop      := na
        zBot      := na
        zAvgVol   := na
        zStartBar := na
        zEndBar   := na
        zDryUp    := false

// ================= VISUAL: background tint while inside an active zone =================
bgcolor(showBg and zActive ? color.new(color.blue, 95) : na)

// ================= ALERTS (set once, works across your whole watchlist) =================
alertcondition(longBO, title="Bullish Volume Breakout", message="{{ticker}}: bullish breakout with volume from consolidation zone")
alertcondition(shortBO, title="Bearish Volume Breakdown", message="{{ticker}}: bearish breakdown with volume from consolidation zone")
````

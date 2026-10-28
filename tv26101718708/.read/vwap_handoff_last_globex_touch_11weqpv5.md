# VWAP - Handoff (Last Globex Touch)

- url: https://www.tradingview.com/script/11wEqPV5-VWAP-Handoff-Last-Globex-Touch/
- type: indicator
- pine_id: PUB;14ce2119f5734fb99fe211d81c19adc8
- version: 2.0

## Description

Auto anchors to the last candle that touched the Globex VWAP in a trending market that is useful when is extended not looking to come back to Globex any time soon.

Labelled and has points from VWAP to Std Dev +-Band and points outside of the dev bands as well.

## Source Code

````pine
//@version=6
indicator(title="VWAP - Handoff (Last Globex Touch)", shorttitle="VWAP Handoff", overlay=true, max_labels_count=20)

// ===== VWAP Settings =====
hideonDWM = input(false, title="Hide VWAP on 1D or Above", group="VWAP Settings")
src       = input.source(ohlc4, title="Source", group="VWAP Settings")
offset    = input.int(0, title="Offset", group="VWAP Settings", minval=0)

// ===== Color & Label Inputs =====
COLOR_GROUP    = "Color Settings"
vwapColor      = input.color(#9c27b0, "VWAP Color",  group=COLOR_GROUP)
bandColor      = input.color(#9c27b0, "Bands Color", group=COLOR_GROUP)
labelSizeInput = input.string("large", "Label Size", options=["tiny", "small", "normal", "large", "huge"], group=COLOR_GROUP)
showVwapPriceInput = input.bool(true, "Show Price on VWAP Label", group=COLOR_GROUP)
showBandPriceInput = input.bool(true, "Show Price on Band Labels", group=COLOR_GROUP)
showBandInfoInput  = input.bool(true, "Show Band Width / Extension Info on VWAP Label", group=COLOR_GROUP, tooltip="Turn off to show just the label name (and price, if enabled) with no band-width or extension text.")

// ===== Map string input to size constant =====
getLabelSize(s) =>
    switch s
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        "huge"   => size.huge
        => size.small

labelSize = getLabelSize(labelSizeInput)

// ===== Bands Settings =====
BANDS_GROUP   = "Bands Settings"
calcModeInput = input.string("Standard Deviation", "Bands Calculation Mode", options=["Standard Deviation", "Percentage"], group=BANDS_GROUP)
showBand_1    = input.bool(true,  title="Show Band 1",   group=BANDS_GROUP)
bandMult_1    = input.float(1.0,  title="Multiplier #1", group=BANDS_GROUP, step=0.5, minval=0)
// FIX: "Percentage" mode was previously hardcoded to 1% (curVwap * 0.01) with
// no user control at all. Added a proper Percentage Width (%) input.
pctWidthInput = input.float(1.0, "Percentage Width (%)", group=BANDS_GROUP, step=0.1, minval=0.0, tooltip="Only used when Bands Calculation Mode = Percentage")

// FIX: track whether this symbol/feed ever reports volume, so we can show a
// clear message instead of silently never drawing anything.
var bool hasVolume = false
if not hasVolume and nz(volume) > 0
    hasVolume := true

// ===== Globex VWAP (Daily Reset) =====
// Recalculated inline so we can compare each bar's high/low against it
// without requiring a separate indicator.
isNewDay = timeframe.change("D")

// FIX (accuracy — the important one): gCumPV/gCumVol used to be plain `var`
// accumulators updated with `+=` on every script execution, which includes
// every intrabar tick of the still-forming realtime bar. That meant the live
// bar's own price*volume got added AGAIN on every single price update before
// that bar closed — overweighting the running Globex VWAP, and in turn
// destabilizing the "touch" detection below (globexVwap would drift intrabar,
// so whether a bar counted as touching it could change tick to tick). Fixed
// by splitting the total into a "committed" base (folded in exactly once,
// when a bar actually closes) plus that bar's own live contribution, added
// fresh each tick for display only and never written back into the base
// until close.
var float baseCumPV  = 0.0
var float baseCumVol = 0.0

if isNewDay
    baseCumPV  := 0.0
    baseCumVol := 0.0

// Guard against na price/volume (data gaps) so a single bad tick can't
// poison the running total.
liveSrc = nz(ohlc4)
liveVol = nz(volume)

float gCumPV  = baseCumPV  + liveSrc * liveVol
float gCumVol = baseCumVol + liveVol

if barstate.isconfirmed
    baseCumPV  += liveSrc * liveVol
    baseCumVol += liveVol

float globexVwap = gCumVol > 0 ? gCumPV / gCumVol : na

// ===== Last Touch Detection (Today Only) =====
// A "touch" is any bar where the candle's high/low range brackets or
// crosses the Globex VWAP — i.e. low <= globexVwap <= high.
// We reset the search at the start of each new day.
var int lastTouchIndex = na

if isNewDay
    lastTouchIndex := na   // clear on new day — today-only

if not na(globexVwap) and low <= globexVwap and globexVwap <= high
    lastTouchIndex := bar_index

// ===== Polyline & Label Storage =====
var polyline vLine = na
var polyline uLine = na
var polyline lLine = na
var label lblV     = na
var label lblU     = na
var label lblL     = na

// ===== Rendering (Executed once per CLOSED bar, not on every realtime tick) =====
// FIX (replay): previously gated on barstate.islast, which reflects the true
// last bar of the WHOLE loaded dataset — not wherever the chart's Bar Replay
// cursor currently sits. Replay bars beyond the cursor are already loaded in
// the background, so islast stayed false for the entire replay and nothing
// would draw until replay caught all the way up to real time. Dropping it in
// favor of barstate.isconfirmed means every closed bar redraws, which tracks
// correctly during replay, historical scrolling, and live trading alike.
if barstate.isconfirmed and not (hideonDWM and timeframe.isdwm)
    polyline.delete(vLine), polyline.delete(uLine), polyline.delete(lLine)
    label.delete(lblV), label.delete(lblU), label.delete(lblL)

    if not hasVolume
        // No volume on this symbol/feed -> VWAP can never be computed.
        // Say so explicitly instead of leaving the chart blank with no explanation.
        lblV := label.new(bar_index, close, "Handoff VWAP: no volume data on this symbol/feed", xloc=xloc.bar_index, style=label.style_label_down, color=color.new(color.red, 70), textcolor=color.white, size=labelSize)

    else if not na(lastTouchIndex)
        vPoints = array.new<chart.point>()
        uPoints = array.new<chart.point>()
        lPoints = array.new<chart.point>()

        float sumPV  = 0.0
        float sumV   = 0.0
        float sumPPV = 0.0

        float finalVwap  = na
        float finalUpper = na
        float finalLower = na

        lookback = bar_index - lastTouchIndex

        if lookback >= 0
            for i = lookback to 0
                // Guard against na price/volume (data gaps): without nz(), a
                // single na bar poisons every subsequent += for the rest of
                // this run, silently freezing the VWAP.
                p = nz(src[i])
                v = nz(volume[i])
                sumPV  += p * v
                sumV   += v
                sumPPV += math.pow(p, 2) * v

                if sumV > 0
                    curVwap = sumPV / sumV

                    float stdev = 0.0
                    if calcModeInput == "Standard Deviation"
                        float variance = (sumPPV / sumV) - math.pow(curVwap, 2)
                        stdev := math.sqrt(math.max(0.0, variance))
                    else
                        stdev := curVwap * (pctWidthInput / 100)

                    curUpper = curVwap + stdev * bandMult_1
                    curLower = curVwap - stdev * bandMult_1

                    // FIX: no "+ offset" here anymore — historical points always
                    // sit at their true bar index now. offset only projects the
                    // endpoint forward (below), instead of shifting the whole line.
                    xIdx = bar_index - i
                    array.push(vPoints, chart.point.from_index(xIdx, curVwap))

                    if showBand_1
                        array.push(uPoints, chart.point.from_index(xIdx, curUpper))
                        array.push(lPoints, chart.point.from_index(xIdx, curLower))

                    if i == 0
                        finalVwap  := curVwap
                        finalUpper := curUpper
                        finalLower := curLower

            // Project the endpoint forward by `offset` bars (flat), rather than
            // shifting every historical point — keeps the drawn line true to
            // history and only extends the tip toward the current price.
            if offset > 0 and not na(finalVwap)
                array.push(vPoints, chart.point.from_index(bar_index + offset, finalVwap))
                if showBand_1
                    array.push(uPoints, chart.point.from_index(bar_index + offset, finalUpper))
                    array.push(lPoints, chart.point.from_index(bar_index + offset, finalLower))

            if array.size(vPoints) > 1
                vLine := polyline.new(vPoints, false, false, line_color=vwapColor, line_width=2)
                if showBand_1
                    uLine := polyline.new(uPoints, false, false, line_color=bandColor, line_width=1)
                    lLine := polyline.new(lPoints, false, false, line_color=bandColor, line_width=1)

                lastV  = array.get(vPoints, array.size(vPoints) - 1)
                labelX = lastV.index + 1

                // ── Directional triangle ──────────────────────────────────────
                string dirTriangle = not na(finalVwap) ? (close >= finalVwap ? "▲" : "▼") : ""

                // Each label's own price segment, toggled independently for the
                // VWAP label vs. the two band labels (which share one switch).
                string vwapPriceStr = showVwapPriceInput ? ": " + str.tostring(finalVwap, format.mintick) : ""

                string bwStr  = ""
                string extStr = ""

                if showBandInfoInput
                    if showBand_1 and not na(finalUpper)
                        float bw = finalUpper - finalVwap

                        float extDist = na
                        if close > finalUpper
                            extDist := close - finalUpper
                        else if close < finalLower
                            extDist := finalLower - close

                        bwStr  := " (" + dirTriangle + ": " + str.tostring(bw, format.mintick) + " pts"
                        extStr := not na(extDist)
                             ? " | Ext: " + str.tostring(extDist, format.mintick) + " pts)"
                             : ")"
                    else
                        float extDist = na
                        if not na(finalUpper)
                            if close > finalUpper
                                extDist := close - finalUpper
                            else if close < finalLower
                                extDist := finalLower - close
                        extStr := not na(extDist)
                             ? " (Ext: " + str.tostring(extDist, format.mintick) + " pts)"
                             : ""

                string finalLabel = "Handoff VWAP" + vwapPriceStr + bwStr + extStr

                lblV := label.new(labelX, lastV.price, finalLabel, xloc=xloc.bar_index, color=color.new(color.black, 100), textcolor=vwapColor, style=label.style_label_left, size=labelSize)

                if showBand_1 and array.size(uPoints) > 0
                    lastU = array.get(uPoints, array.size(uPoints) - 1)
                    lastL = array.get(lPoints, array.size(lPoints) - 1)
                    string ubPriceStr = showBandPriceInput ? ": " + str.tostring(finalUpper, format.mintick) : ""
                    string lbPriceStr = showBandPriceInput ? ": " + str.tostring(finalLower, format.mintick) : ""
                    lblU := label.new(lastU.index + 1, lastU.price, "Handoff UB" + ubPriceStr, xloc=xloc.bar_index, color=color.new(color.black, 100), textcolor=bandColor, style=label.style_label_left, size=labelSize)
                    lblL := label.new(lastL.index + 1, lastL.price, "Handoff LB" + lbPriceStr, xloc=xloc.bar_index, color=color.new(color.black, 100), textcolor=bandColor, style=label.style_label_left, size=labelSize)

            // Single-bar anchor — draw a label so the anchor is still visible
            // even when there's only one point (no line to draw yet).
            else if array.size(vPoints) == 1 and not na(finalVwap)
                string dirTriangle = close >= finalVwap ? "▲" : "▼"
                string vwapPriceStr = showVwapPriceInput ? ": " + str.tostring(finalVwap, format.mintick) : ""
                lblV := label.new(bar_index + 1 + offset, finalVwap, "Handoff VWAP" + vwapPriceStr + " " + dirTriangle, xloc=xloc.bar_index, color=color.new(color.black, 100), textcolor=vwapColor, style=label.style_label_left, size=labelSize)
````

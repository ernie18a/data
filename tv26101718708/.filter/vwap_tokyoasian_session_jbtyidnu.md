# VWAP - Tokyo\Asian Session

- url: https://www.tradingview.com/script/jBtyidnU-VWAP-Tokyo-Asian-Session/
- type: indicator
- pine_id: PUB;8221e053181147dc9a9a4da23c19973e
- version: 3.0

## Description

VWAP auto anchored to the start of Tokyo\Asian session

Labelled that changes color to match the line color

The first calculation next to the VWAP name is the points distance from the VWAP to the Standard Dev Band. If you want to know the distance from one Std Dev +1 to -1 then double this
number.

The Ext is the real time points value of the current price outside of the Std Dev +1 or -1 band

## Source Code

````pine
//@version=6
indicator(title="Volume Weighted Average Price - Tokyo Session", shorttitle="VWAP Tokyo", overlay=true, max_labels_count=20)

// ===== VWAP Settings =====
src            = input.source(ohlc4, title="Source")
offset         = input.int(0, title="Offset", minval=0)
labelSizeInput = input.string("large", "Label Size", options=["tiny", "small", "normal", "large", "huge"])
showVwapPriceInput = input.bool(true, "Show Price on VWAP Label")
showBandPriceInput = input.bool(true, "Show Price on Band Labels")
showBandInfoInput  = input.bool(true, "Show Band Width / Extension Info on VWAP Label", tooltip="Turn off to show just the label name (and price, if enabled) with no band-width or extension text.")

// ===== Color Inputs =====
vwapColor = input.color(#ff9800, "VWAP Color")
bandColor = input.color(#ffa726, "Band Color")

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

// ===== TOKYO SESSION LOGIC =====
isTokyoTime    = not na(time(timeframe.period, "0900-1900:1234567", "Asia/Tokyo"))
isBeforeLondon = not na(time(timeframe.period, "0000-0800:1234567", "Europe/London"))

isSessionActive = isTokyoTime and isBeforeLondon
isTokyoOpen     = isSessionActive and not isSessionActive[1]

// Track whether this symbol/feed ever reports volume, so we can show a
// clear message instead of silently never plotting anything.
var bool hasVolume = false
if not hasVolume and nz(volume) > 0
    hasVolume := true

// ===== Accumulator Variables =====
// FIX (accuracy — the important one): sumSrcVol/sumVol/sumSqSrcVol were
// `var` accumulators updated with `+=` on every script execution, which
// includes every intrabar tick of the still-forming realtime bar. That
// meant the live bar's own price*volume got added AGAIN on every single
// price update before that bar closed — the busier the tick flow, the more
// that one bar's contribution silently overweighted the running VWAP.
// Fixed by splitting the total into a "committed" base (folded in exactly
// once, when a bar actually closes) plus the live bar's own contribution,
// added fresh each tick for display only and never written back into the
// base until close.
var float baseSumSrcVol   = 0.0
var float baseSumVol      = 0.0
var float baseSumSqSrcVol = 0.0

if isTokyoOpen or not isSessionActive
    baseSumSrcVol   := 0.0
    baseSumVol      := 0.0
    baseSumSqSrcVol := 0.0

// Guard against na price/volume (data gaps, or no-volume feeds) so a single
// bad tick can't poison the running totals.
liveSrc = nz(src)
liveVol = nz(volume)

float sumSrcVol   = isSessionActive ? baseSumSrcVol   + liveSrc * liveVol              : na
float sumVol      = isSessionActive ? baseSumVol      + liveVol                        : na
float sumSqSrcVol = isSessionActive ? baseSumSqSrcVol + math.pow(liveSrc, 2) * liveVol : na

// Fold this bar's contribution into the committed base exactly once, right
// when it closes.
if isSessionActive and barstate.isconfirmed
    baseSumSrcVol   += liveSrc * liveVol
    baseSumVol      += liveVol
    baseSumSqSrcVol += math.pow(liveSrc, 2) * liveVol

// ===== VWAP & Band Calculations =====
float vwapValue       = na
float upperBandValue1 = na
float lowerBandValue1 = na
float stdevValue      = na
float extensionDist   = na

if isSessionActive and sumVol > 0
    vwapValue      := sumSrcVol / sumVol
    variance        = (sumSqSrcVol / sumVol) - math.pow(vwapValue, 2)
    stdevValue     := math.sqrt(math.max(0.0, variance))
    upperBandValue1 := vwapValue + stdevValue
    lowerBandValue1 := vwapValue - stdevValue

    // Extension: only when price is OUTSIDE the bands
    if close > upperBandValue1
        extensionDist := close - upperBandValue1
    else if close < lowerBandValue1
        extensionDist := lowerBandValue1 - close

// ===== Plots =====
plot(vwapValue,       "Tokyo VWAP", vwapColor, 2, style=plot.style_linebr, offset=offset)
plot(upperBandValue1, "Upper Band", bandColor,  2, style=plot.style_linebr, offset=offset)
plot(lowerBandValue1, "Lower Band", bandColor,  2, style=plot.style_linebr, offset=offset)

// ===== End-of-line Labels =====
var label lblVWAP = na
var label lblUp1  = na
var label lblDn1  = na

// FIX (replay): previously gated on barstate.islast, which reflects the true
// last bar of the WHOLE loaded dataset — not wherever the chart's Bar Replay
// cursor currently sits. Replay bars beyond the cursor are already loaded in
// the background, so islast stayed false for the entire replay and these
// labels never appeared until replay caught all the way up to real time.
// barstate.isconfirmed instead redraws once per closed bar, which tracks
// correctly during replay, historical scrolling, and live trading, and
// (since the previous labels are always deleted first) still only ever
// shows one instance at a time.
if barstate.isconfirmed
    label.delete(lblVWAP)
    label.delete(lblUp1)
    label.delete(lblDn1)

    xPos = bar_index + 1 + offset

    if not hasVolume
        // No volume on this symbol/feed -> VWAP can never be computed.
        // Say so explicitly instead of leaving the chart blank with no explanation.
        lblVWAP := label.new(xPos, close, "Tokyo VWAP: no volume data on this symbol/feed", xloc.bar_index, yloc.price, color.new(color.black, 100), label.style_label_left, color.red, labelSize)
    else if not na(vwapValue)
        // ── Directional triangle: ▲ above VWAP, ▼ below ──────────────────────
        string dirTriangle = close >= vwapValue ? "▲" : "▼"

        // Each label's own price, toggled independently for the VWAP label vs.
        // the two band labels (which share one switch between them).
        string vwapPriceStr = showVwapPriceInput ? ": " + str.tostring(vwapValue, format.mintick) : ""
        string ubPriceStr   = showBandPriceInput ? ": " + str.tostring(upperBandValue1, format.mintick) : ""
        string lbPriceStr   = showBandPriceInput ? ": " + str.tostring(lowerBandValue1, format.mintick) : ""

        string bwStr  = showBandInfoInput and not na(stdevValue)
             ? " (" + dirTriangle + ": " + str.tostring(stdevValue, format.mintick) + " pts"
             : ""

        string extStr = showBandInfoInput and not na(extensionDist)
             ? " | Ext: " + str.tostring(extensionDist, format.mintick) + " pts)"
             : (showBandInfoInput and not na(stdevValue) ? ")" : "")

        string finalLabel = "Tokyo VWAP" + vwapPriceStr + bwStr + extStr

        lblVWAP := label.new(xPos, vwapValue,       finalLabel, xloc.bar_index, yloc.price, color.new(color.black, 100), label.style_label_left, vwapColor, labelSize)
        lblUp1  := label.new(xPos, upperBandValue1, "Tokyo UB" + ubPriceStr, xloc.bar_index, yloc.price, color.new(color.black, 100), label.style_label_left, bandColor, labelSize)
        lblDn1  := label.new(xPos, lowerBandValue1, "Tokyo LB" + lbPriceStr, xloc.bar_index, yloc.price, color.new(color.black, 100), label.style_label_left, bandColor, labelSize)
````

# Angled Square Time-Price Zones Ver 1

- url: https://www.tradingview.com/script/y3R8ut6N-Angled-Square-Time-Price-Zones-Ver-1/
- type: indicator
- pine_id: PUB;67b268ac3d0344958ee041acc0ea6d45
- version: 1.0

## Description

[b][b]Angled Square Time-Price Zones — Ver 1[/b]
By Timepricedecoder[/b]

Overview

This indicator applies W.D. Gann's Time = Price principle using Pythagorean geometry, projecting an angled grid of time-price "squares" directly on the chart. Gann believed price and time are two expressions of the same underlying cycle — when they fall out of balance, and then come back into sync, the market tends to reach a meaningful turning point or acceleration.

This script finds an anchor swing using a Pythagorean Balance search — rather than simply taking the highest high / lowest low in a window, it searches local pivot candidates for the swing whose price range and bar count best fit your chosen Pythagorean triple (e.g. 3-4-5, 5-12-13, 8-15-17). From that swing, it builds a repeating cascade of angled diamonds (or upright rectangles) forward and backward in time, each split into a red Seller Zone (upper half) and green Buyer Zone (lower half).

Each diamond's diagonal edge is the true time = price sync line for that cycle. When price closes beyond it, price is moving faster than the cycle accounts for — effectively borrowing the pace of a larger, steeper cycle. When price closes back inside, time is catching up.

[b]Core Concepts[/b]

[b]Sync vs. Break[/b]
The diagonal edge of each diamond represents time and price moving in step. A close beyond it means price has run ahead (or behind) of time for that cycle.

[b]Confluence References[/b]
Prior Day Close, Prior Day High, and Prior Day Low act as reference levels. When a sync-break happens at one of these levels, it carries more weight than a break in open space.

[b]Harmonic Cascade[/b]
The cascade repeats both in time (columns — Past/NOW/Future) and price (rows, up to your configured range), forming a self-organizing grid of time-price nodes rather than arbitrary fixed levels.

[b]Signal Types[/b]

[list]
[*]Sync-Break (triangle) — price has closed beyond the diagonal edge of its row. Large triangle = coincides with PD Close/High/Low (high confidence). Small triangle = no PD-level confluence (lower confidence).
[*]Time Catch-Up (arrow) — price has closed back inside a diagonal it previously broke; the reversion/cooling-off counterpart to Sync-Break.
[*]Wick-Touch/Rejection (x) — the candle's high/low touched or pierced the diagonal intrabar, but the close rejected back inside — catches a "kiss and reverse" that a close-only signal would miss.
[/list]

Optional filters (off by default) let you require time-cycle node proximity, price-edge proximity, or PD-level confluence before any signal fires, if you want to tighten from the default permissive behavior.

[b]Recommended Settings[/b]

[list]
[*]Scalping — Gann Number 22, Triple 4-3-5, Swing Scale Half
[*]Short Term — Gann Number 44, Triple 4-3-5, Swing Scale Full
[*]Medium Term — Gann Number 88, Triple 3-4-5, Swing Scale Full
[*]Long Term — Gann Number 176, Triple 3-4-5, Swing Scale Full
[/list]

[b]Instrument Type[/b]

Instrument type (Options vs. Indices/Stocks/Futures) is auto-detected from the ticker — no manual setting needed. Only the Options vs. non-Options split changes the underlying math (square height uses the option's own premium-decay rate); Indices, Stocks, and Futures currently share identical geometry.

[b]Square Style[/b]

Angled (Diamond) — the classic Gann-square cascade, rotated 45 degrees.
Normal (Rectangle) — the same grid drawn upright. Confluence logic automatically adjusts to match whichever style is selected.

[b]Auto-Fit[/b]

Enable Auto-Fit to have the cascade automatically size itself to your visible chart, instead of manually tuning past/future/up/down cycle counts. Enable Freeze if you want the size to hold steady during live market hours rather than resizing as you scroll or zoom.

[b]How To Use[/b]

[list]
[*]Let the script auto-detect the swing anchor from your chosen Gann Number and session.
[*]Watch the diagonal edges of each diamond — a close beyond one is a Sync-Break.
[*]Larger markers and PD-level proximity indicate stronger confluence.
[*]Use Time Catch-Up signals to spot when a stretched move is reverting back to sync.
[*]Treat Wick-Rejection marks as early-warning "tested and failed" levels.
[/list]

[b]On Repainting / Lookahead[/b]

This script uses request.security() with lookahead enabled to pull the prior day's Close, High, and Low. This is safe and non-repainting: it is always paired with a [1] or greater offset referencing an already-closed daily bar, never the current forming bar. The swing search and all signal logic are computed from closed price data only.

[b]Disclaimer[/b]

This script is published for educational purposes only. It does not constitute financial advice. Past signal accuracy does not guarantee future results. Always use proper risk management. Trade at your own risk.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Timepricedecoder — Angled Square Time-Price Zones — Ver 1
// Built on the Pythagorean Time Price Geometry Ver 5.1 swing/PD-level engine.
// Ver 1 features: auto instrument detection (Options vs non-Options via
// ticker pattern + syminfo.type), swing selection via Pythagorean Balance
// search over pivot candidates, diamond/rectangle zone fills rendered with
// line + linefill objects (not polyline) to avoid Pine's tight polyline cap,
// auto-fit cascade sizing to the visible chart (with freeze/lock option), and
// a three-layer signal set — Sync-Break, Time Catch-Up (reversion), and
// Wick-Touch/Rejection — built on PD Close/High/Low and time/price confluence.
//@version=6
indicator("Angled Square Time-Price Zones", overlay=true,
     max_lines_count=500, max_labels_count=500, max_bars_back=5000)

// ══════════════════════════════════════════════════════════════════════════════
// ① INSTRUMENT — auto-detected (Options vs Indices/Stocks/Futures)
// ══════════════════════════════════════════════════════════════════════════════
// Detection logic: NSE/MCX option tickers end in "CE"/"PE" with a strike
// (digit) immediately before the suffix, e.g. "...25000CE" / "...3000PE".
// Requiring a digit right before the suffix avoids false positives from
// stock/index tickers that merely happen to contain the letters CE or PE.
_tLen        = str.length(syminfo.ticker)
_last2       = _tLen >= 2 ? str.substring(syminfo.ticker, _tLen - 2, _tLen) : ""
_charBefore  = _tLen >= 3 ? str.substring(syminfo.ticker, _tLen - 3, _tLen - 2) : ""
_digitBefore = _charBefore == "0" or _charBefore == "1" or _charBefore == "2" or _charBefore == "3" or
     _charBefore == "4" or _charBefore == "5" or _charBefore == "6" or _charBefore == "7" or
     _charBefore == "8" or _charBefore == "9"
isOptionTicker = (_last2 == "CE" or _last2 == "PE") and _digitBefore

instrType = isOptionTicker ? "Options" : syminfo.type == "futures" ? "Futures" : syminfo.type == "index" ? "Indices" : "Stocks"
// Note: only the Options / non-Options split changes downstream math (square
// height, CoG offset). Indices/Stocks/Futures are labelled separately for
// on-chart clarity but currently share identical behavior.

// ══════════════════════════════════════════════════════════════════════════════
// ② STRUCTURE
// ══════════════════════════════════════════════════════════════════════════════
gannNumber  = input.int(88, "Gann Number (Base Period)",
     options=[11,22,44,88,96,176], group="② Structure",
     tooltip="The base cycle length (in bars) the swing-search window is sized around. 88 is tuned for Nifty/Sensex on 4-min charts; smaller numbers react faster but on noisier swings, larger numbers are steadier but slower to update.")
swingScale  = input.string("Full", "Swing Range Scale",
     options=["Full","Half"], group="② Structure")
sessionStr  = input.session("0915-1530", "Exchange Session",
     tooltip="Pick your exchange's regular trading session (NSE equities/index/options: 0915-1530. MCX commodities: 0900-2330). Session length in minutes is derived from this automatically.", group="② Structure")
sessionMinsOverride = input.float(0.0, "Manual Session Minutes Override (0 = auto)",
     minval=0, maxval=1800, step=15,
     tooltip="Leave at 0 to auto-derive from the Exchange Session picker above. Set a nonzero value only if auto-parsing doesn't match your exchange.", group="② Structure")

parseSessionMins() =>
    parts = str.split(sessionStr, "-")
    float result = na
    if array.size(parts) >= 2
        s0 = array.get(parts, 0)
        s1 = array.get(parts, 1)
        sh = str.tonumber(str.substring(s0, 0, 2))
        sm = str.tonumber(str.substring(s0, 2, 4))
        eh = str.tonumber(str.substring(s1, 0, 2))
        em = str.tonumber(str.substring(s1, 2, 4))
        if not na(sh) and not na(sm) and not na(eh) and not na(em)
            result := (eh * 60 + em) - (sh * 60 + sm)
    result

autoSessionMins = parseSessionMins()
sessionMins = sessionMinsOverride > 0 ? sessionMinsOverride : (na(autoSessionMins) or autoSessionMins <= 0 ? 375.0 : autoSessionMins)

// ══════════════════════════════════════════════════════════════════════════════
// ③ PYTHAGOREAN TRIPLE
// ══════════════════════════════════════════════════════════════════════════════
tripleMode = input.string("3-4-5   (53.1°)", "Pythagorean Triple (Manual)",
     options=["24-7-25 (16.3°)","12-5-13 (22.6°)","15-8-17 (28.1°)",
              "4-3-5   (36.9°)","1-1-Sq2 (45.0°)","3-4-5   (53.1°)",
              "8-15-17 (61.9°)","5-12-13 (67.4°)","7-24-25 (73.7°)"],
     group="③ Pythagorean Triple",
     tooltip="Fixed Pythagorean angle used to size every square (height:width ratio) and to balance the swing search. No auto-detection — pick the angle that matches your instrument's typical swing steepness.")

manualPtA = switch tripleMode
    "3-4-5   (53.1°)" => 3.0
    "4-3-5   (36.9°)" => 4.0
    "5-12-13 (67.4°)" => 5.0
    "12-5-13 (22.6°)" => 12.0
    "8-15-17 (61.9°)" => 8.0
    "15-8-17 (28.1°)" => 15.0
    "7-24-25 (73.7°)" => 7.0
    "24-7-25 (16.3°)" => 24.0
    => 1.0

manualPtB = switch tripleMode
    "3-4-5   (53.1°)" => 4.0
    "4-3-5   (36.9°)" => 3.0
    "5-12-13 (67.4°)" => 12.0
    "12-5-13 (22.6°)" => 5.0
    "8-15-17 (61.9°)" => 15.0
    "15-8-17 (28.1°)" => 8.0
    "7-24-25 (73.7°)" => 24.0
    "24-7-25 (16.3°)" => 7.0
    => 1.0

// ══════════════════════════════════════════════════════════════════════════════
// ④ CASCADE (past / present / future — all directions)
// ══════════════════════════════════════════════════════════════════════════════
squareStyle     = input.string("Angled (Diamond)", "Square Style",
     options=["Angled (Diamond)","Normal (Rectangle)"], group="④ Cascade",
     tooltip="Angled draws each Gann block rotated 45° (diamond). Normal draws it upright (rectangle). Both use the same red Seller Zone / green Buyer Zone split at the centre. Zone-cross confluence automatically matches whichever style is selected.")
pastCycles      = input.int(1, "Past Cycles (Time)",   minval=0, maxval=5, group="④ Cascade",
     tooltip="How many square-widths to project backward in time from the current swing, for visual context of how this cycle length aligned with past price action.")
futureCycles    = input.int(2, "Future Cycles (Time)", minval=0, maxval=5, group="④ Cascade",
     tooltip="How many square-widths to project forward in time — these are the projected time/price targets ahead of the current bar.")
priceCyclesUp   = input.int(1, "Price Cycles (Up)",    minval=0, maxval=4, group="④ Cascade",
     tooltip="How many extra rows of squares to stack above the current row. 0 shows a single horizontal row only.")
priceCyclesDown = input.int(1, "Price Cycles (Down)",  minval=0, maxval=4, group="④ Cascade",
     tooltip="How many extra rows of squares to stack below the current row. 0 shows a single horizontal row only.")
autoFit = input.bool(true, "Auto-Fit Cascade to Visible Chart", group="④ Cascade",
     tooltip="When on, past/future columns and up/down rows are computed automatically to cover whatever is currently visible on your chart, instead of using the fixed counts above. The manual inputs above are used as a fallback only when this is off.")
lockFit = input.bool(false, "Freeze Auto-Fit (recompute only when toggled)", group="④ Cascade",
     tooltip="When on, the auto-fit size is calculated once and then held fixed — it will not resize while the market is live or while you scroll/zoom. Toggle this off and back on (or flip it) whenever you want it to recompute for a new zoom level.")

// ══════════════════════════════════════════════════════════════════════════════
// ⑤ DISPLAY
// ══════════════════════════════════════════════════════════════════════════════
showDiamonds      = input.bool(true,  "Squares", group="⑤ Display")
showZoneFill      = input.bool(true,  "Fill Buyer/Seller Zones", group="⑤ Display")
showZoneMarkers   = input.bool(true,  "Zone-Cross Triangles (Short Covering / Profit Booking)", group="⑤ Display")
showDiamondLabels = input.bool(true,  "Cycle Labels (NOW / P# / F#)", group="⑤ Display")
showHLLabels      = input.bool(true,  "Swing H/L Anchor Labels", group="⑤ Display")
showCoG           = input.bool(true,  "CoG Levels", group="⑤ Display")
showBoundary      = input.bool(false, "Outer Boundary", group="⑤ Display")
labelSize         = input.string("small", "Label Size", options=["tiny","small","normal"], group="⑤ Display")

// ══════════════════════════════════════════════════════════════════════════════
// ⑥ COLOURS — warm Gann palette
// ══════════════════════════════════════════════════════════════════════════════
colDiamondPast   = input.color(color.new(#8D6E63, 55), "Past Square Outline",   group="⑥ Colours")
colDiamondNow    = input.color(#FF6F00,                 "Current Square Outline", group="⑥ Colours")
colDiamondFuture = input.color(color.new(#FFA000, 40), "Future Square Outline", group="⑥ Colours")
colGapDiamond    = input.color(color.new(#BCAAA4, 55), "Gap-Fill Square Outline", group="⑥ Colours")
colSellerZone    = input.color(color.new(color.red, 78),   "Seller Zone Fill (Upper Half)", group="⑥ Colours")
colBuyerZone     = input.color(color.new(color.green, 78), "Buyer Zone Fill (Lower Half)",  group="⑥ Colours")
colShortCover    = input.color(color.new(color.green, 0),  "Short-Covering Marker (Cross Up)",   group="⑥ Colours")
colProfitBook    = input.color(color.new(color.red, 0),    "Profit-Booking Marker (Cross Down)", group="⑥ Colours")
colCoGMid        = input.color(#BF360C, "CoG Mid",      group="⑥ Colours")
colCoGHL         = input.color(#FF8F00, "CoG High/Low", group="⑥ Colours")
colSwingLine     = input.color(#D84315, "Swing H-L Line", group="⑥ Colours")
colBoundary      = input.color(#6D4C41, "Outer Boundary", group="⑥ Colours")

// ══════════════════════════════════════════════════════════════════════════════
// ⑦ ZONE-CROSS CONFLUENCE — makes the markers actually check the square
// geometry instead of firing on a plain PDClose cross.
// ══════════════════════════════════════════════════════════════════════════════
reqTimeConfluence  = input.bool(false, "Require Time-Cycle Node Confluence",
     tooltip="OFF by default. When ON, only fires when price is near a column's time-center. A strong trending move usually breaks the diagonal away from that center, so requiring this suppresses most trend signals — leave off unless you specifically want reversal-only signals.", group="⑦ Zone-Cross Confluence")
reqPriceConfluence = input.bool(false, "Require Price-Edge Confluence",
     tooltip="Only fire when price is right at the row edge rather than having already gapped past it.", group="⑦ Zone-Cross Confluence")
reqPDConfluence    = input.bool(false, "Require PD Close/High/Low Confluence",
     tooltip="When ON, only fires when the sync-break level coincides with PD Close, PD High, or PD Low. When OFF (default), PD-confluence instead just marks a signal as high-confidence (larger marker) vs low-confidence (smaller marker) without filtering anything out.", group="⑦ Zone-Cross Confluence")
timeNodeSqrtFactor  = 1.0     // hardcoded — tolerance = factor × sqrt(blockWv), Gann sqrt-of-cycle scaling
priceEdgeSqrtFactor = 1.0     // hardcoded — tolerance = factor × sqrt(blockHv), Gann sqrt-of-range scaling

lblSz = labelSize == "tiny" ? size.tiny : labelSize == "normal" ? size.normal : size.small

// ══════════════════════════════════════════════════════════════════════════════
// PERSISTENT STATE
// ══════════════════════════════════════════════════════════════════════════════
var float swingHigh    = na
var float swingLow     = na
var int   swHBar       = na
var int   swLBar       = na
var float anchorPDC    = na

var line[]     drawnLines     = array.new<line>()
var label[]    drawnLabels    = array.new<label>()
var linefill[] drawnLinefills = array.new<linefill>()

var int  lockedPast    = na
var int  lockedFuture  = na
var int  lockedUp      = na
var int  lockedDown    = na
var bool lockCaptured  = false

var int  activeRow    = na
var int  pendingRow   = na
var int  pendingCount = 0

// Candidate pivot buffers reused every recalculation of the swing search
// (Pythagorean Balance now searches over these instead of every raw bar).
var float[] candHPrice = array.new<float>()
var int[]   candHBar2  = array.new<int>()
var float[] candLPrice = array.new<float>()
var int[]   candLBar2  = array.new<int>()

// ══════════════════════════════════════════════════════════════════════════════
// DERIVED CONSTANTS
// ══════════════════════════════════════════════════════════════════════════════
fullSwingBars  = gannNumber
tfMins         = timeframe.in_seconds() / 60.0
sessionBars    = int(math.round(sessionMins / tfMins))
anchorDaysBack = math.max(1, int(math.ceil(float(fullSwingBars) / float(sessionBars))))

FC        = bar_index + 499

// ══════════════════════════════════════════════════════════════════════════════
// PD LEVELS
// ══════════════════════════════════════════════════════════════════════════════
pdC1     = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)
pdC2     = request.security(syminfo.tickerid, "D", close[2], lookahead=barmerge.lookahead_on)
pdC3     = request.security(syminfo.tickerid, "D", close[3], lookahead=barmerge.lookahead_on)
pdC4     = request.security(syminfo.tickerid, "D", close[4], lookahead=barmerge.lookahead_on)
pdC5     = request.security(syminfo.tickerid, "D", close[5], lookahead=barmerge.lookahead_on)
pdClose  = anchorDaysBack <= 1 ? pdC1 : anchorDaysBack == 2 ? pdC2 : anchorDaysBack == 3 ? pdC3 : anchorDaysBack == 4 ? pdC4 : pdC5

// PD High / PD Low — same anchor logic as PD Close, used as confluence
// reference levels for the sync-break signals below.
pdH1 = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pdH2 = request.security(syminfo.tickerid, "D", high[2], lookahead=barmerge.lookahead_on)
pdH3 = request.security(syminfo.tickerid, "D", high[3], lookahead=barmerge.lookahead_on)
pdH4 = request.security(syminfo.tickerid, "D", high[4], lookahead=barmerge.lookahead_on)
pdH5 = request.security(syminfo.tickerid, "D", high[5], lookahead=barmerge.lookahead_on)
pdHigh = anchorDaysBack <= 1 ? pdH1 : anchorDaysBack == 2 ? pdH2 : anchorDaysBack == 3 ? pdH3 : anchorDaysBack == 4 ? pdH4 : pdH5

pdL1 = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)
pdL2 = request.security(syminfo.tickerid, "D", low[2], lookahead=barmerge.lookahead_on)
pdL3 = request.security(syminfo.tickerid, "D", low[3], lookahead=barmerge.lookahead_on)
pdL4 = request.security(syminfo.tickerid, "D", low[4], lookahead=barmerge.lookahead_on)
pdL5 = request.security(syminfo.tickerid, "D", low[5], lookahead=barmerge.lookahead_on)
pdLow = anchorDaysBack <= 1 ? pdL1 : anchorDaysBack == 2 ? pdL2 : anchorDaysBack == 3 ? pdL3 : anchorDaysBack == 4 ? pdL4 : pdL5

// ══════════════════════════════════════════════════════════════════════════════
// PDClose BAR LOCATION
// ══════════════════════════════════════════════════════════════════════════════
pdCloseTime = request.security(syminfo.tickerid, "D", time[1], lookahead=barmerge.lookahead_on)

var int pdCloseBarOffset = na
for i = 0 to 500
    if time[i] <= pdCloseTime and (i == 0 or time[i-1] > pdCloseTime)
        pdCloseBarOffset := i
        break

// ══════════════════════════════════════════════════════════════════════════════
// SWING SELECTION — Pythagorean Balance only, optimized over pivot candidates
// ══════════════════════════════════════════════════════════════════════════════
pdCloseChanged = na(anchorPDC) or pdClose != anchorPDC
needSwing      = na(swingHigh) or na(swingLow)

// ptA/ptB used to balance the swing search itself (manual triple only).
searchPtA = manualPtA
searchPtB = manualPtB

if (pdCloseChanged or needSwing) and not na(pdClose) and not na(pdCloseBarOffset)
    searchStart   = pdCloseBarOffset
    tfAwareWindow = math.max(fullSwingBars, int(math.round(sessionMins / tfMins)))
    searchEnd     = pdCloseBarOffset + tfAwareWindow

    float foundH    = na
    float foundL    = na
    int   foundHBar = na
    int   foundLBar = na

    for i = searchStart to searchEnd
        if na(high[i])
            break
        if na(foundH) or high[i] > foundH
            foundH    := high[i]
            foundHBar := bar_index - i

    for i = searchStart to searchEnd
        if na(low[i])
            break
        if na(foundL) or low[i] < foundL
            foundL    := low[i]
            foundLBar := bar_index - i

    if not na(foundH) and not na(foundL) and foundH > foundL

        // Reduce the pairwise search space to local pivot highs/lows within
        // the window (plus the absolute window H/L as a guaranteed fallback
        // candidate). This turns the O(window²) scan into O(pivots²), which
        // is what makes Pythagorean Balance safe as the sole, always-on
        // swing method.
        array.clear(candHPrice)
        array.clear(candHBar2)
        array.clear(candLPrice)
        array.clear(candLBar2)

        pivLen = 2
        if searchEnd - searchStart > pivLen * 2
            for i = searchStart + pivLen to searchEnd - pivLen
                if na(high[i - pivLen]) or na(high[i + pivLen])
                    break
                isPH = true
                isPL = true
                for k = -pivLen to pivLen
                    if k != 0
                        if high[i] < high[i + k]
                            isPH := false
                        if low[i] > low[i + k]
                            isPL := false
                if isPH
                    array.push(candHPrice, high[i])
                    array.push(candHBar2,  bar_index - i)
                if isPL
                    array.push(candLPrice, low[i])
                    array.push(candLBar2,  bar_index - i)

        array.push(candHPrice, foundH)
        array.push(candHBar2,  foundHBar)
        array.push(candLPrice, foundL)
        array.push(candLBar2,  foundLBar)

        float bestH       = foundH
        float bestL       = foundL
        int   bestHBar    = foundHBar
        int   bestLBar    = foundLBar
        float bestBalance = 999999.0
        minRange = (foundH - foundL) * 0.5
        minBars  = gannNumber / 2

        for hi = 0 to array.size(candHPrice) - 1
            hP = array.get(candHPrice, hi)
            hB = array.get(candHBar2,  hi)
            for li = 0 to array.size(candLPrice) - 1
                lP = array.get(candLPrice, li)
                lB = array.get(candLBar2,  li)
                if hP > lP and math.abs(hB - lB) >= minBars and (hP - lP) >= minRange
                    r     = hP - lP
                    bars  = math.abs(hB - lB)
                    sH    = r / searchPtA
                    sW    = swingScale == "Half" ? math.max(1, bars / 2) : bars
                    ratio = math.abs((sH / math.max(1, sW)) - (searchPtB / searchPtA))
                    if ratio < bestBalance
                        bestBalance := ratio
                        bestH       := hP
                        bestL       := lP
                        bestHBar    := hB
                        bestLBar    := lB

        swingHigh := bestH
        swingLow  := bestL
        swHBar    := bestHBar
        swLBar    := bestLBar

    anchorPDC := pdClose

validSwing = not na(swingHigh) and not na(swingLow) and not na(swHBar) and not na(swLBar) and swingHigh > swingLow

// ══════════════════════════════════════════════════════════════════════════════
// PYTHAGOREAN TRIPLE — manual, applied directly to the resolved swing
// ══════════════════════════════════════════════════════════════════════════════
finalPtA = manualPtA
finalPtB = manualPtB

// ══════════════════════════════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════════════════════════════
safeLine(x0, y0, x1, y1, col, w) =>
    ix0 = math.max(math.min(int(x0), FC), 0)
    ix1 = math.max(math.min(int(x1), FC), 0)
    newLine = line.new(ix0, y0, ix1, y1, color=col, width=w, style=line.style_solid)
    array.push(drawnLines, newLine)
    newLine

safeLabel(x, y, txt, sty, bgCol, txtCol) =>
    ix = math.max(math.min(int(x), FC), 0)
    array.push(drawnLabels, label.new(ix, y, txt, style=sty, color=bgCol, textcolor=txtCol, size=lblSz))

safeLineFill(l1, l2, fillCol) =>
    array.push(drawnLinefills, linefill.new(l1, l2, fillCol))

// ══════════════════════════════════════════════════════════════════════════════
// DRAW ONE SQUARE — split into a red Seller Zone (upper half) and a green
// Buyer Zone (lower half), meeting at the centre (CoG) line. Rendered with
// line + linefill objects (not polyline) to stay well under Pine's tight
// polyline cap while using the much larger line/linefill budget instead.
// "Angled" draws the square rotated 45° (diamond, vertices at the bounding-
// box midpoints); "Normal" draws it upright. Returns the top point for
// labeling.
// ══════════════════════════════════════════════════════════════════════════════
drawSquare(x0, x1, y0, y1, outlineCol, fillOn) =>
    cx0 = math.max(math.min(int(x0), FC), 0)
    cx1 = math.max(math.min(int(x1), FC), 0)
    cx = int(math.round((cx0 + cx1) / 2.0))
    cy = (y0 + y1) / 2.0
    sellFill = fillOn ? colSellerZone : na
    buyFill  = fillOn ? colBuyerZone  : na
    float lblX = na
    float lblY = na

    if squareStyle == "Angled (Diamond)"
        // Four outline edges of the diamond (left-top, top-right,
        // left-bottom, bottom-right).
        lLeftTop  = safeLine(cx0, cy, cx, y1, outlineCol, 2)
        lTopRight = safeLine(cx, y1, cx1, cy, outlineCol, 2)
        lLeftBot  = safeLine(cx0, cy, cx, y0, outlineCol, 2)
        lBotRight = safeLine(cx, y0, cx1, cy, outlineCol, 2)
        if fillOn
            // Two hidden centerline segments used only as the linefill
            // boundary at the diamond's horizontal midline.
            lCenterL = safeLine(cx0, cy, cx, cy, color.new(outlineCol, 100), 1)
            lCenterR = safeLine(cx, cy, cx1, cy, color.new(outlineCol, 100), 1)
            safeLineFill(lLeftTop,  lCenterL, sellFill)
            safeLineFill(lTopRight, lCenterR, sellFill)
            safeLineFill(lLeftBot,  lCenterL, buyFill)
            safeLineFill(lBotRight, lCenterR, buyFill)
        lblX := cx
        lblY := y1
    else
        // Rectangle: top edge, center divider, bottom edge — filled as two
        // stacked bands (seller above center, buyer below).
        lTop    = safeLine(cx0, y1, cx1, y1, outlineCol, 2)
        lCenter = safeLine(cx0, cy, cx1, cy, outlineCol, 2)
        lBot    = safeLine(cx0, y0, cx1, y0, outlineCol, 2)
        if fillOn
            safeLineFill(lTop,    lCenter, sellFill)
            safeLineFill(lCenter, lBot,    buyFill)
        lblX := cx1
        lblY := y1

    [lblX, lblY]

// ══════════════════════════════════════════════════════════════════════════════
// PER-BAR SQUARE GEOMETRY — computed every bar (not just on the last bar) so
// the zone-cross markers can be evaluated across the whole history.
// ══════════════════════════════════════════════════════════════════════════════
var int   swingEndBarV = na
var int   squareWv     = na
var float squareHv     = na
var float cogMidV      = na
var float blockWv      = na
var float blockHv      = na

if validSwing and not na(pdClose)
    fullRv    = math.abs(swingHigh - swingLow)
    fullBarsv = math.max(1, math.abs(swHBar - swLBar))
    swingEndBarV := math.max(swHBar, swLBar)
    squareWv     := swingScale == "Half" ? math.max(1, int(fullBarsv / 2)) : fullBarsv

    PTRv      = pdClose / sessionMins
    squareHv  := instrType == "Options" ? PTRv * tfMins * float(squareWv) * (finalPtB / finalPtA) : fullRv / finalPtA
    cogMidV   := pdClose
    blockWv   := math.max(1, int(finalPtB * float(squareWv)))
    blockHv   := finalPtA * squareHv

colX0(b) =>
    ci = int(math.floor(float(b - swingEndBarV) / blockWv))
    swingEndBarV + ci * int(blockWv)
colX1(b) => colX0(b) + int(blockWv)
colXc(b) => int(math.round((colX0(b) + colX1(b)) / 2.0))

// Confluence edge functions now branch on Square Style: tapered diagonal
// edges for Angled (Diamond) — matching the visual taper, full height only
// at the column's midpoint — vs flat edges for Normal (Rectangle), matching
// the upright box that's actually drawn in that mode.
diagUpper(b, rowIdx) =>
    yLo = cogMidV + float(rowIdx) * blockHv
    yHi = yLo + blockHv
    float result = na
    if squareStyle == "Angled (Diamond)"
        x0c = colX0(b)
        x1c = colX1(b)
        xc  = colXc(b)
        cy  = (yLo + yHi) / 2.0
        result := b <= xc ? cy + (yHi - cy) * (b - x0c) / math.max(1, xc - x0c) : yHi - (yHi - cy) * (b - xc) / math.max(1, x1c - xc)
    else
        result := yHi
    result

diagLower(b, rowIdx) =>
    yLo = cogMidV + float(rowIdx) * blockHv
    yHi = yLo + blockHv
    float result = na
    if squareStyle == "Angled (Diamond)"
        x0c = colX0(b)
        x1c = colX1(b)
        xc  = colXc(b)
        cy  = (yLo + yHi) / 2.0
        result := b <= xc ? cy - (cy - yLo) * (b - x0c) / math.max(1, xc - x0c) : yLo + (cy - yLo) * (b - xc) / math.max(1, x1c - xc)
    else
        result := yLo
    result

// ══════════════════════════════════════════════════════════════════════════════
// ZONE-CROSS MARKERS — up-triangle when price crosses back above the CURRENT
// ROW's centre line (Short Covering / buyers stepping in), down-triangle on
// the reverse (Profit Booking / sellers stepping in). Checks the square
// geometry itself: which row the price is in, whether it's near that row's
// centre, near a time-cycle node (column boundary), and near a price edge
// (row top/bottom) — all optional via the confluence toggles above.
// ══════════════════════════════════════════════════════════════════════════════
// Active row uses hysteresis (below): it only switches to a new row once price
// has closed in that row for 2 consecutive bars. This prevents a single-bar
// dip/spike from silently reassigning which row's diagonal is being tested —
// the exact bug that let a quick round-trip near a row boundary fall between
// two different rows' edges instead of being tracked as one continuous move.
curRawRow = na(blockHv) or blockHv <= 0 ? na : int(math.floor((close - cogMidV) / blockHv))
if not na(curRawRow)
    if na(activeRow)
        activeRow := curRawRow
    if curRawRow != activeRow
        if curRawRow == pendingRow
            pendingCount := pendingCount + 1
        else
            pendingRow   := curRawRow
            pendingCount := 1
        if pendingCount >= 2
            activeRow    := curRawRow
            pendingCount := 0
    else
        pendingRow   := na
        pendingCount := 0

rowIdxPrev = activeRow
edgeUpPrev = na(rowIdxPrev) ? na : diagUpper(bar_index - 1, rowIdxPrev)
edgeUpCurr = na(rowIdxPrev) ? na : diagUpper(bar_index, rowIdxPrev)
edgeDnPrev = na(rowIdxPrev) ? na : diagLower(bar_index - 1, rowIdxPrev)
edgeDnCurr = na(rowIdxPrev) ? na : diagLower(bar_index, rowIdxPrev)

bFromEndV  = bar_index - swingEndBarV
cyclePosV  = na(blockWv) or blockWv <= 0 ? na : bFromEndV % int(blockWv)
timeNodeWin = na(blockWv) or blockWv <= 0 ? na : math.max(1, math.round(timeNodeSqrtFactor * math.sqrt(blockWv)))
distFromColCenter = na(cyclePosV) ? na : math.abs(cyclePosV - blockWv / 2.0)
onTimeNode  = na(distFromColCenter) ? false : distFromColCenter <= timeNodeWin

// Price-edge confluence now checks the SAME edge the cross is breaking —
// i.e. the breakout didn't gap far past the edge, it's a clean test of it.
priceEdgeTol  = na(blockHv) or blockHv <= 0 ? na : priceEdgeSqrtFactor * math.sqrt(blockHv)
nearPriceEdge = (na(edgeUpCurr) or na(edgeDnCurr)) ? false : math.abs(high - edgeUpCurr) < priceEdgeTol or math.abs(low - edgeDnCurr) < priceEdgeTol

// ══════════════════════════════════════════════════════════════════════════════
// SYNC-BREAK STATE — persistent classification of whether price is currently
// running AHEAD of time (closed beyond the upper diagonal, borrowing the pace
// of a larger/steeper time cycle), BEHIND (below the lower diagonal, same
// idea downside), or IN SYNC (inside the diamond, time and price matched).
// Sync-Break signals fire on the transition into ahead/behind; Time-Catch-Up
// (reversion) signals fire on the transition back out of it.
// ══════════════════════════════════════════════════════════════════════════════
var int syncState = 0
prevSyncState = syncState
newSyncState  = not na(edgeUpCurr) and close > edgeUpCurr ? 1 : not na(edgeDnCurr) and close < edgeDnCurr ? -1 : 0

// The actual buy/sell signal: price breaking out of the row (square) it was
// in on the previous bar, tested against the true edge (tapered or flat,
// per Square Style) at each bar's own x-position — not a flat line —
// since a diamond's edge only reaches full row height at the column's
// midpoint, while a rectangle's edge is flat throughout.
baseCrossUp   = prevSyncState <= 0 and newSyncState == 1
baseCrossDown = prevSyncState >= 0 and newSyncState == -1

// Time-Catch-Up: price had broken sync (ahead/behind) and has now closed
// back inside — time is catching up to price, the move is cooling off.
baseReversionDown = prevSyncState == 1  and newSyncState <= 0
baseReversionUp   = prevSyncState == -1 and newSyncState >= 0

// PD Close / PD High / PD Low confluence — marks a signal as high-confidence
// (the sync-break level coincides with a meaningful prior-day reference)
// rather than gating it away, unless reqPDConfluence is explicitly enabled.
nearPDC = not na(cogMidV) and math.abs(close - cogMidV) < priceEdgeTol
nearPDH = not na(pdHigh)  and math.abs(close - pdHigh)  < priceEdgeTol
nearPDL = not na(pdLow)   and math.abs(close - pdLow)   < priceEdgeTol
hasPDConfluence = nearPDC or nearPDH or nearPDL

passFilters(sig) => sig and (not reqTimeConfluence or onTimeNode) and (not reqPriceConfluence or nearPriceEdge) and (not reqPDConfluence or hasPDConfluence)

crossUp        = showZoneMarkers and passFilters(baseCrossUp)
crossDown      = showZoneMarkers and passFilters(baseCrossDown)
reversionUp    = showZoneMarkers and passFilters(baseReversionUp)
reversionDown  = showZoneMarkers and passFilters(baseReversionDown)

crossUpHi   = crossUp and hasPDConfluence
crossUpLo   = crossUp and not hasPDConfluence
crossDownHi = crossDown and hasPDConfluence
crossDownLo = crossDown and not hasPDConfluence

syncState := newSyncState

// Wick-Touch/Rejection: price's HIGH or LOW touched (or pierced) the
// diagonal edge of its OWN row intrabar, but the CANDLE CLOSED back inside
// that row — a "kiss and reject" of the level. This is a single-bar event,
// so unlike Sync-Break/Time Catch-Up it is tested against the current bar's
// own row directly, not the sticky multi-bar activeRow — a wick can poke
// into a neighboring row without that row ever becoming the active one.
thisRow    = na(blockHv) or blockHv <= 0 ? na : int(math.floor((close - cogMidV) / blockHv))
edgeUpThis = na(thisRow) ? na : diagUpper(bar_index, thisRow)
edgeDnThis = na(thisRow) ? na : diagLower(bar_index, thisRow)

wickTouchReject_Up   = not na(edgeUpThis) and high >= edgeUpThis and close < edgeUpThis
wickTouchReject_Down = not na(edgeDnThis) and low  <= edgeDnThis and close > edgeDnThis

wickRejectUp   = showZoneMarkers and passFilters(wickTouchReject_Up)
wickRejectDown = showZoneMarkers and passFilters(wickTouchReject_Down)

plotshape(crossUpHi,   title="Sync-Break Up (High Confidence)",   style=shape.triangleup,   location=location.belowbar, color=colShortCover, size=size.normal)
plotshape(crossUpLo,   title="Sync-Break Up (Low Confidence)",    style=shape.triangleup,   location=location.belowbar, color=colShortCover, size=size.tiny)
plotshape(crossDownHi, title="Sync-Break Down (High Confidence)", style=shape.triangledown, location=location.abovebar, color=colProfitBook, size=size.normal)
plotshape(crossDownLo, title="Sync-Break Down (Low Confidence)",  style=shape.triangledown, location=location.abovebar, color=colProfitBook, size=size.tiny)
plotshape(reversionUp,   title="Time Catch-Up (from Behind)", style=shape.arrowup,   location=location.belowbar, color=color.new(colShortCover, 40), size=size.tiny)
plotshape(reversionDown, title="Time Catch-Up (from Ahead)",  style=shape.arrowdown, location=location.abovebar, color=color.new(colProfitBook, 40), size=size.tiny)
plotshape(wickRejectDown, title="Wick Rejection at Upper Edge", style=shape.xcross, location=location.abovebar, color=color.new(colProfitBook, 20), size=size.tiny)
plotshape(wickRejectUp,   title="Wick Rejection at Lower Edge", style=shape.xcross, location=location.belowbar, color=color.new(colShortCover, 20), size=size.tiny)

alertcondition(crossUp,       title="Sync-Break Up",   message="{{ticker}}: price closed ahead of time — sync-break up")
alertcondition(crossDown,     title="Sync-Break Down", message="{{ticker}}: price closed behind time — sync-break down")
alertcondition(reversionUp,   title="Time Catch-Up (Up)",   message="{{ticker}}: time catching up from behind — cooling off up")
alertcondition(reversionDown, title="Time Catch-Up (Down)", message="{{ticker}}: time catching up from ahead — cooling off down")
alertcondition(wickRejectUp,   title="Wick Rejection (Lower Edge)", message="{{ticker}}: wick touched the lower diagonal and rejected")
alertcondition(wickRejectDown, title="Wick Rejection (Upper Edge)", message="{{ticker}}: wick touched the upper diagonal and rejected")

// ══════════════════════════════════════════════════════════════════════════════
// DRAWING — only redrawn on the last bar
// ══════════════════════════════════════════════════════════════════════════════
if validSwing and not na(cogMidV) and barstate.islast

    while array.size(drawnLines) > 0
        line.delete(array.pop(drawnLines))
    while array.size(drawnLabels) > 0
        label.delete(array.pop(drawnLabels))
    while array.size(drawnLinefills) > 0
        linefill.delete(array.pop(drawnLinefills))

    fullR   = math.abs(swingHigh - swingLow)
    fullBars = math.max(1, math.abs(swHBar - swLBar))
    cogHigh = instrType == "Options" ? swingHigh + squareHv * 2.0 : swingHigh + squareHv
    cogLow  = instrType == "Options" ? swingLow  - squareHv * 2.0 : swingLow  - squareHv

    barDurMs = tfMins * 60000
    leftVisBarIndex  = bar_index - int(math.round((time - chart.left_visible_bar_time) / barDurMs))
    rightVisBarIndex = bar_index + int(math.round((chart.right_visible_bar_time - time) / barDurMs))

    visBarsBack = math.min(500, math.max(1, bar_index - leftVisBarIndex))
    float visHigh = na
    float visLow  = na
    for vi = 0 to visBarsBack - 1
        if na(visHigh) or high[vi] > visHigh
            visHigh := high[vi]
        if na(visLow) or low[vi] < visLow
            visLow := low[vi]

    // NOTE: caps below (7 cols / 3 rows worst case) are sized for the line-
    // budget of this rendering method (~6 lines per filled diamond). If you
    // raise them, watch for a "max_lines_count" compile/runtime error and
    // dial back if so.
    rawPast   = autoFit ? math.max(0, math.min(4, int(math.ceil(float(swingEndBarV - leftVisBarIndex) / blockWv)))) : pastCycles
    rawFuture = autoFit ? math.max(0, math.min(4, int(math.ceil(float(rightVisBarIndex - swingEndBarV) / blockWv)))) : futureCycles
    rawUp     = autoFit and not na(visHigh) ? math.max(0, math.min(2, int(math.ceil((visHigh - cogMidV) / blockHv)))) : priceCyclesUp
    rawDown   = autoFit and not na(visLow)  ? math.max(0, math.min(2, int(math.ceil((cogMidV - visLow) / blockHv)))) : priceCyclesDown

    if lockFit and not lockCaptured
        lockedPast   := rawPast
        lockedFuture := rawFuture
        lockedUp     := rawUp
        lockedDown   := rawDown
        lockCaptured := true
    if not lockFit
        lockCaptured := false

    effPastCycles   = lockFit ? lockedPast   : rawPast
    effFutureCycles = lockFit ? lockedFuture : rawFuture
    effUp           = lockFit ? lockedUp     : rawUp
    effDown         = lockFit ? lockedDown   : rawDown

    xLeft  = math.max(swingEndBarV - effPastCycles * blockWv, 0)
    xRight = math.min(swingEndBarV + effFutureCycles * blockWv, FC)

    if showHLLabels
        safeLabel(swHBar, swingHigh, "▼ H  " + str.tostring(swingHigh, format.mintick) +
             "  |  R:" + str.tostring(fullR, format.mintick) + "  Bars:" + str.tostring(fullBars),
             label.style_label_down, color.new(#3E2723, 0), color.white)
        safeLabel(swLBar, swingLow, "▲ L  " + str.tostring(swingLow, format.mintick),
             label.style_label_up, color.new(#3E2723, 0), color.white)
        safeLine(swHBar, swingHigh, swLBar, swingLow, colSwingLine, 2)

    if showDiamonds
        for col = -effPastCycles to effFutureCycles
            x0 = swingEndBarV + col * int(blockWv)
            x1 = x0 + int(blockWv)
            if x1 < bar_index - 500 or x1 > FC
                continue
            if x0 < 0
                continue

            isMainCol = col == 0
            colTag = col < 0 ? "P" + str.tostring(-col) : col == 0 ? "NOW" : "F" + str.tostring(col)
            dCol   = col < 0 ? colDiamondPast : col == 0 ? colDiamondNow : colDiamondFuture

            for row = -effDown to effUp
                y0 = cogMidV + row * blockHv
                y1 = y0 + blockHv

                [lblX, lblY] = drawSquare(x0, x1, y0, y1, dCol, showZoneFill)

                if showDiamondLabels
                    rowTag = row > 0 ? "+" + str.tostring(row) : row < 0 ? str.tostring(row) : "0"
                    barsToConj = int(math.round(lblX)) - bar_index
                    conjTxt = col > 0 and row == 0 ?
                         colTag + " | " + str.tostring(barsToConj) + "b\nF:" + str.tostring(math.round(blockHv, 2)) + " H:" + str.tostring(math.round(blockHv / 2.0, 2))
                         : row != 0 ? colTag + " " + rowTag
                         : colTag
                    conjStyle = col > 0 and col % 2 == 0 ? label.style_label_up : label.style_label_down
                    conjY     = col > 0 and col % 2 == 0 ? y0 : lblY
                    safeLabel(lblX, conjY, conjTxt, conjStyle,
                         color.new(dCol, 30), color.white)

        // Gap-fill diamonds — centered on the cell corners (where four main
        // diamonds meet at a single tip), same block size, completing the
        // tessellation so no white space is left uncovered.
        if squareStyle == "Angled (Diamond)"
            halfBH = blockHv / 2.0
            for col = -effPastCycles to effFutureCycles
                gx0 = swingEndBarV + col * int(blockWv) + int(blockWv) / 2
                gx1 = gx0 + int(blockWv)
                if gx1 < bar_index - 500 or gx1 > FC
                    continue
                for row = -effDown to effUp
                    gy0 = cogMidV + row * blockHv - halfBH
                    gy1 = gy0 + blockHv
                    drawSquare(gx0, gx1, gy0, gy1, colGapDiamond, showZoneFill)

    if showCoG
        safeLine(xLeft, cogMidV, xRight, cogMidV, colCoGMid, 2)
        safeLabel(xRight, cogMidV, "◆ CoG Mid " + str.tostring(math.round(cogMidV, 2)),
             label.style_label_left, color.new(#3E2723, 0), colCoGMid)
        safeLine(xLeft, cogHigh, xRight, cogHigh, colCoGHL, 1)
        safeLine(xLeft, cogLow,  xRight, cogLow,  colCoGHL, 1)

    if showBoundary
        safeLine(xLeft, cogLow - blockHv * 0.25, xLeft, cogHigh + blockHv * 0.25, colBoundary, 2)
        safeLine(xRight, cogLow - blockHv * 0.25, xRight, cogHigh + blockHv * 0.25, colBoundary, 2)
````

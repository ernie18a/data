# HTF Support/Resistance Multi-Tap

- url: https://www.tradingview.com/script/JUbBkx7g-HTF-Support-Resistance-Multi-Tap/
- type: indicator
- pine_id: PUB;9a5f154ef9e44b078fc74870252855fe
- version: 20.0

## Description

The HTF Multi-Tap S/R Zones is an advanced structural indicator designed for lower timeframe traders who need higher timeframe confluence without cluttering their charts.

Instead of drawing infinite lines everywhere, this indicator tracks historical pivot points from a Higher Timeframe (HTF) of your choice and dynamically builds highly-validated "Zones of Interest" directly onto your current chart. It is specifically engineered to find areas where price has repeatedly struggled to break through.

Core Features:

Dynamic Wick Absorption (Zones): When price wicks into the same general area, the script doesn't just plot a single static line. It dynamically expands the top and bottom borders of a "Zone" to encompass the full range of the historical wicks, giving you a literal block of rejection to trade against.
Zone Merging: If two adjacent zones expand enough to touch each other, the indicator will seamlessly merge them into one massive, highly significant structural block.
Volume & Tap Tracking: Every time price taps a zone, the script records the touch and pulls the exact volume that occurred on that HTF candle. The zone's label clearly displays the total accumulated volume and the number of taps it took to build it.
Automated Volume Grading: The indicator continuously scans the active zones on your chart and automatically tags the zone with the absolute highest historical volume with a (⭐ Max Vol) label, instantly showing you the strongest defensive wall on the board.
Clean & Focused: By default, it only displays the 3 closest Support zones and the 3 closest Resistance zones to the current price, keeping your chart clean and focused strictly on the levels that matter right now.
How to Use (Confluence):
This is not a standalone entry signal; it is a confluence tool.
If you are trading on a 1-minute or 5-minute chart, set the indicator's HTF to 15m or 1H. Use these projected zones as high-probability areas to look for your lower timeframe entry models (like break of structure, fair value gaps, or engulfing candles). The (⭐ Max Vol) zones are prime locations for strong reversals or major breakout continuations.

Settings:

Higher Timeframe: Choose which timeframe to pull structural pivots from.
Proximity Threshold %: Adjust how close price needs to come to an existing zone to be considered a "Tap" and expand the box. Increase this slightly for highly volatile assets to absorb larger wicks.
Minimum Taps: Determine how many times a level must be tested before it is considered valid and plotted on your screen.

## Source Code

````pine
//@version=6
// Author: barrettfvg
// HTF Hybrid S/R Entry Model
// Hybrid support/resistance model using HTF pivots, liquidity shelf grouping,
// volume/touch scoring, session levels, and 1m BOS-style entry confirmation.
//
// CHANGE vs. the live version (additive only, nothing else touched):
//   Added "Show Shelf Zones" toggle (Display & Colors group) so the shelf
//   zone lines/labels can be hidden while running this alongside other
//   indicators on the same chart — the underlying computation (which zones
//   are active, which get tapped, entry logic) is completely unaffected;
//   only whether they're drawn changes. Old zone lines are cleared on every
//   redraw regardless of the toggle, so turning it off makes them actually
//   disappear rather than leaving stale lines on the chart.
indicator("barrettfvg HTF Hybrid S/R Entry Model", overlay=true, max_lines_count=500, max_labels_count=500)

// ============================================================
//                         INPUTS
// ============================================================

// ---------- 1. SUPPORT & RESISTANCE ----------
grpSr = "1 · Support & Resistance"
htf = input.timeframe("60", "Primary Timeframe", group=grpSr, tooltip="Main timeframe for major support/resistance")
useSecondaryTf = input.bool(true, "Use Secondary Timeframe", group=grpSr)
secondaryTf = input.timeframe("30", "Secondary Timeframe", group=grpSr, tooltip="Secondary timeframe for nearby intraday support/resistance")
levelsPerTfSide = input.int(2, "Visible Areas Per Side", minval=2, maxval=5, group=grpSr, tooltip="Shows at least this many closest support areas and this many closest resistance areas.")
leftLen = input.int(5, "Pivot Left Length", group=grpSr, tooltip="Number of bars to the left to confirm a major swing")
rightLen = input.int(5, "Pivot Right Length", group=grpSr, tooltip="Number of bars to the right to confirm a major swing")
mergeThresholdTicks = input.int(20, "Merge Threshold (ticks)", minval=0, group=grpSr, tooltip="Levels from different timeframes this close display as one merged zone.")

// ---------- 2. ENTRY TRIGGER ----------
grpEntry = "2 · Entry Trigger"
bosPivotLen = input.int(3, "1m BOS Pivot Length", group=grpEntry, tooltip="Pivot length for 1m Break of Structure")
tapThresholdTicks = input.int(8, "Tap Threshold (ticks)", minval=0, group=grpEntry, tooltip="Distance around HTF levels that counts as a tap.")
maxBarsSinceTap = input.int(15, "Max Bars Since Tap for Entry", group=grpEntry, tooltip="How many 1m bars can pass after a tap before the BOS is invalid")
breakoutBufferTicks = input.int(1, "Breakout Buffer (ticks)", minval=0, group=grpEntry, tooltip="Requires close to clear the BOS pivot by this many ticks instead of an exact zero-distance tag. Kept small so real breaks aren't filtered out.")
entryCooldownBars = input.int(15, "Entry Signal Cooldown Bars", minval=0, group=grpEntry, tooltip="Minimum bars between same-direction entry signals.")
filterByBias = input.bool(false, "Filter Entries by HTF Bias", group=grpEntry, tooltip="Only take Longs in Bullish trend, Shorts in Bearish trend. Off by default.")

// ---------- 3. CONFIRMATION: ORDERFLOW ----------
grpDelta = "3 · Confirmation — Orderflow (Delta)"
requireDelta = input.bool(true, "Require Orderflow (Delta) Confirmation", group=grpDelta, tooltip="MASTER SWITCH for this section. Uses synthetic delta derived from OHLCV (not true bid/ask tick data, which Pine cannot access) to estimate buying vs selling pressure.")
deltaBarMinRatio = input.float(0.25, "BOS Candle Min Delta Ratio", minval=0.0, maxval=1.0, step=0.05, group=grpDelta, tooltip="Breakout candle's delta (buy volume minus sell volume) must be at least this fraction of its total volume, in the trade direction. 0.25 means roughly 62/38 split or better.")
deltaRequireVolume = input.bool(true, "Require Above-Average Volume on BOS", group=grpDelta, tooltip="Breakout candle's volume must exceed the recent average, so the delta reading is backed by real participation rather than a thin bar.")
deltaVolLen = input.int(20, "    ↳ Volume Average Length", minval=2, maxval=200, group=grpDelta, tooltip="Lookback for the average volume comparison on the breakout candle.")
deltaVolMult = input.float(1.2, "    ↳ Volume Multiple", minval=0.5, step=0.1, group=grpDelta, tooltip="Breakout candle volume must exceed this multiple of the average.")
requireCumDelta = input.bool(true, "Require Cumulative Delta Agreement", group=grpDelta, tooltip="Sums synthetic delta from the zone tap through the breakout bar and requires the net to favor the trade direction, filtering breaks that fire while net pressure is still against you.")
cumDeltaMaxBars = input.int(20, "    ↳ Cumulative Delta Max Bars", minval=2, maxval=100, group=grpDelta, tooltip="Cap on how many bars back from the current bar the cumulative delta sum will reach when the tap is older than this.")

// ---------- 4. CONFIRMATION: DISPLACEMENT ----------
grpDisp = "4 · Confirmation — Displacement"
requireDisplacement = input.bool(true, "Require Displacement on BOS Candle", group=grpDisp, tooltip="MASTER SWITCH for this section. Requires the breakout candle to show real conviction (range and body large relative to ATR) instead of drifting through the level on low energy.")
dispRangeAtr = input.float(1.0, "    ↳ Min Range (ATR)", minval=0.1, step=0.1, group=grpDisp, tooltip="Breakout candle's high-low range must be at least this multiple of ATR(14).")
dispBodyRatio = input.float(0.5, "    ↳ Min Body Ratio", minval=0.0, maxval=1.0, step=0.05, group=grpDisp, tooltip="Breakout candle's body must be at least this fraction of its total range, so the close finishes strong rather than leaving a large rejection wick. Set to 0 to check range only.")
dispRequireDirectionalClose = input.bool(true, "    ↳ Requires Directional Close", group=grpDisp, tooltip="Breakout candle must close in the direction of the trade (green for longs, red for shorts).")

// ---------- 5. RISK & TRADE MANAGEMENT ----------
grpRisk = "5 · Risk & Trade Management"
rrRatio = input.float(1.0, "Risk/Reward Ratio Target", group=grpRisk, tooltip="Multiplier for the Take Profit line")
slMethod = input.string("Structure lookback extreme", "SL Method", options=["Structure lookback extreme", "Last 1m pivot"], group=grpRisk, tooltip="Structure lookback extreme uses the broader low/high before entry.")
slLookbackBars = input.int(30, "Structure SL Lookback Bars", minval=1, group=grpRisk, tooltip="How many completed 1m candles to scan for the broader structure stop.")
slBufferTicks = input.int(0, "SL Buffer (ticks)", minval=0, group=grpRisk, tooltip="Optional extra room beyond the selected SL level.")

// ---------- 6. TRADING HOURS ----------
grpAlerts = "6 · Trading Hours"
alertSession1 = input.session("1800-0000", "Trading Time Window 1 (EST)", group=grpAlerts, tooltip="Trades will only fire during these hours.")
alertSession2 = input.session("0700-1600", "Trading Time Window 2 (EST)", group=grpAlerts, tooltip="Trades will only fire during these hours.")

// ---------- 7. KEY LEVELS ----------
grpKeyLevels = "7 · Key Levels"
showPdh = input.bool(true, "Show PDH", group=grpKeyLevels)
showPdl = input.bool(true, "Show PDL", group=grpKeyLevels)
showTrueDayOpen = input.bool(true, "Show True Day Open", group=grpKeyLevels)
showAsiaLevels = input.bool(true, "Show Asia High/Low", group=grpKeyLevels)
asiaSession = input.session("2000-0000", "    ↳ Asia Session (EST)", group=grpKeyLevels)
showLondonLevels = input.bool(true, "Show London High/Low", group=grpKeyLevels)
londonSession = input.session("0200-0500", "    ↳ London Session (EST)", group=grpKeyLevels)
includePw = input.bool(true, "Include Prev Week High/Low", group=grpKeyLevels, tooltip="Adds PWH/PWL as a displayed key level and, when Key Level Sweep Entries is on, as sweepable entry-arming liquidity — same treatment as PDH/PDL.")
showPwh = input.bool(true, "    ↳ Show PWH/PWL", group=grpKeyLevels)
useKeySweepEntries = input.bool(true, "Use Key Level Sweeps as Entry Triggers", group=grpKeyLevels, tooltip="Adds PDH/PDL/PWH/PWL and COMPLETED session extremes (Asia/London) as a second way to arm the entry trigger: a genuine sweep (wick beyond the level, close back inside, bar-close only) rather than a proximity tap. Feeds the exact same BOS/displacement/delta confirmation stack as shelf-zone taps — nothing about entry confirmation changes, only how the pending entry gets armed. Turn OFF to reproduce the prior behavior exactly (shelf-zone taps only).")

// ---------- 8. VWAPS ----------
grpVwap = "8 · VWAPs"
showVwaps = input.bool(true, "Show Contextual VWAPs", group=grpVwap)

// ---------- 9. MARKET STRUCTURE TAGS ----------
grpStructure = "9 · Market Structure Tags"
showStructureTags = input.bool(true, "Show 1m HH/HL/LH/LL Tags", group=grpStructure, tooltip="Visual-only chart-timeframe structure labels. Best used on the 1m chart.")
structurePivotLen = input.int(10, "Structure Pivot Strength", minval=2, maxval=50, group=grpStructure)
structureMaxLabels = input.int(25, "Max Structure Labels", minval=5, maxval=100, group=grpStructure)

// ---------- 10. DISPLAY & COLORS ----------
grpStyle = "10 · Display & Colors"
showTradeTracker = input.bool(true, "Show Visual SL/TP Tracker", group=grpStyle, tooltip="Draws dynamic SL and TP lines when an entry triggers")
showOnlyLastEntryPerSide = input.bool(true, "Show Only Last Entry Per Side", group=grpStyle, tooltip="When enabled, only the most recent LONG and most recent SHORT marker remain visible.")
showShelfZones = input.bool(true, "Show Shelf Zones", group=grpStyle, tooltip="Draws the scored shelf-zone lines and labels. Turn off to run this alongside other indicators without visual overlap — the underlying zones, taps, and entry logic are completely unaffected either way, only the drawing changes.")
showBias = input.bool(true, "Show HTF Bias on Labels", group=grpStyle)
longEntryColor = input.color(color.green, "Long Entry Color", group=grpStyle)
shortEntryColor = input.color(color.red, "Short Entry Color", group=grpStyle)
entryLabelTextColor = input.color(color.white, "Entry Label Text Color", group=grpStyle)
resColor = input.color(#f23645, "Resistance Line Color", group=grpStyle)
supColor = input.color(#089981, "Support Line Color", group=grpStyle)
levelLabelTextColor = input.color(color.black, "S/R Label Text Color", group=grpStyle)
structureBullColor = input.color(color.new(color.green, 0), "Bull Structure Color", group=grpStyle)
structureBearColor = input.color(color.new(color.red, 0), "Bear Structure Color", group=grpStyle)
tdoColor = input.color(color.blue, "TDO VWAP Color (18:00 EST)", group=grpStyle)
nyColor = input.color(#9c27b0, "NY VWAP Color (09:30-16:00 EST)", group=grpStyle)
pdhColor = input.color(color.black, "PDH Color", group=grpStyle)
pdlColor = input.color(color.black, "PDL Color", group=grpStyle)
trueDayOpenColor = input.color(color.black, "TDO Color", group=grpStyle)
asiaColor = input.color(color.new(#f23645, 0), "Asia Level Color", group=grpStyle)
londonColor = input.color(color.new(#2962ff, 0), "London Level Color", group=grpStyle)
keyLevelTextColor = input.color(color.black, "Key Level Text Color", group=grpStyle)

// ---------- 11. ADVANCED ----------
grpAdv = "11 · Advanced (rarely needs changing)"
biasEmaLen = input.int(60, "Bias EMA Length", group=grpAdv, tooltip="Length of the HTF EMA used to determine trend direction")
prioritizeMajorLevels = input.bool(true, "Prioritize Major Levels", group=grpAdv, tooltip="Ranks nearby levels by strength instead of distance only.")
majorCandidatePool = input.int(4, "Major Candidate Pool Per Side", minval=2, maxval=12, group=grpAdv, tooltip="How many nearby levels per side are scored before the final visible levels are selected.")
majorScoreThreshold = input.float(3.25, "Major Level Score Threshold", minval=0.0, step=0.25, group=grpAdv, tooltip="Minimum score used to tag a visible level as major.")
majorDistanceAtr = input.float(2.5, "Major Distance Weight ATR", minval=0.25, step=0.25, group=grpAdv, tooltip="Distance range used when scoring level proximity.")
shelfToleranceAtr = input.float(0.35, "Shelf Zone ATR Tolerance", minval=0.01, step=0.05, group=grpAdv, tooltip="How close repeated pivots need to be before they merge into a liquidity shelf zone.")
shelfMinTouches = input.int(2, "Shelf Minimum Touches", minval=1, maxval=10, group=grpAdv, tooltip="Minimum grouped pivot touches before a shelf zone becomes visible.")
shelfMinTouchSpacing = input.int(5, "Shelf Touch Spacing Bars", minval=1, maxval=100, group=grpAdv, tooltip="Minimum chart bars between touches that can count toward the same shelf.")
maxStoredPivotLevels = input.int(60, "Max Stored Pivot Levels", minval=50, maxval=300, group=grpAdv)
shelfMaxStored = input.int(60, "Max Stored Shelf Zones", minval=25, maxval=300, group=grpAdv)
fastLoadMode = input.bool(true, "Fast Load Mode", group=grpAdv, tooltip="Limits heavier historical entry and level-selection calculations to the most recent bars so the script loads faster.")
calcLookbackBars = input.int(5000, "    ↳ Fast Load Lookback Bars", minval=500, maxval=50000, group=grpAdv, tooltip="When Fast Load Mode is enabled, entry signals and visible S/R selection are calculated only this many bars back.")
showDeltaDebug = input.bool(false, "Show Delta Debug Table", group=grpAdv, tooltip="Displays live synthetic delta readings so you can sanity-check thresholds against the chart.")

runHeavyEngine = not fastLoadMode or bar_index >= last_bar_index - calcLookbackBars or barstate.islast or barstate.isrealtime

// --- HTF Custom Functions ---
getSwingHigh(left, right) =>
    ta.pivothigh(high, left, right)

getSwingLow(left, right) =>
    ta.pivotlow(low, left, right)

// --- HTF Data ---
[htfHigh, htfLow, htfVol, htfTime, htfClose, htfEma, htfAtr] = request.security(syminfo.tickerid, htf, [getSwingHigh(leftLen, rightLen), getSwingLow(leftLen, rightLen), volume[rightLen], time[rightLen], close, ta.ema(close, biasEmaLen), ta.atr(14)[rightLen]])
[secondaryHighRaw, secondaryLowRaw, secondaryVolRaw, secondaryTimeRaw, secondaryAtrRaw] = request.security(syminfo.tickerid, secondaryTf, [getSwingHigh(leftLen, rightLen), getSwingLow(leftLen, rightLen), volume[rightLen], time[rightLen], ta.atr(14)[rightLen]])
secondaryHigh = useSecondaryTf ? secondaryHighRaw : na
secondaryLow = useSecondaryTf ? secondaryLowRaw : na
secondaryVol = useSecondaryTf ? secondaryVolRaw : na
secondaryTime = useSecondaryTf ? secondaryTimeRaw : na
secondaryAtr = useSecondaryTf ? secondaryAtrRaw : na

// --- UDT Definition ---
type PivotLevel
    float price
    int startTime
    bool isRes
    float pivotVolume
    bool isFlipped
    bool hasPrimary
    bool hasSecondary

type ShelfZone
    float top
    float bot
    bool isRes
    int touches
    int startTime
    int lastTouchBar
    float pivotVolume
    bool isFlipped
    bool hasPrimary
    bool hasSecondary
    float score
    bool isMajor

var array<PivotLevel> levels = array.new<PivotLevel>()
var array<ShelfZone> shelfZones = array.new<ShelfZone>()
var activeLines = array.new_line()
var activeLabels = array.new_label()

f_shelf_mid(ShelfZone z) =>
    (z.top + z.bot) / 2.0

f_add_or_merge_shelf(array<ShelfZone> arr, bool isRes, float pivotPrice, int pivotTime, float pivotVolume, float mergeDistance, bool hasPrimary, bool hasSecondary, int maxStored) =>
    if not na(pivotPrice) and not na(pivotTime) and not na(mergeDistance) and mergeDistance > 0
        int mergeIndex = na
        float bestDistance = na
        if arr.size() > 0
            for i = 0 to arr.size() - 1
                ShelfZone existing = arr.get(i)
                float existingMid = f_shelf_mid(existing)
                float distance = math.abs(pivotPrice - existingMid)
                bool priceNearShelf = existing.isRes == isRes and distance <= mergeDistance
                bool touchSpacingOk = bar_index - existing.lastTouchBar >= shelfMinTouchSpacing
                if priceNearShelf and touchSpacingOk and (na(bestDistance) or distance < bestDistance)
                    bestDistance := distance
                    mergeIndex := i

        float halfWidth = mergeDistance * 0.5
        if na(mergeIndex)
            arr.push(ShelfZone.new(pivotPrice + halfWidth, pivotPrice - halfWidth, isRes, 1, pivotTime, bar_index, pivotVolume, false, hasPrimary, hasSecondary, 0.0, false))
        else
            ShelfZone merged = arr.get(mergeIndex)
            merged.top := math.max(merged.top, pivotPrice + halfWidth)
            merged.bot := math.min(merged.bot, pivotPrice - halfWidth)
            merged.touches += 1
            merged.startTime := math.min(merged.startTime, pivotTime)
            merged.lastTouchBar := bar_index
            merged.pivotVolume := math.max(merged.pivotVolume, pivotVolume)
            merged.isFlipped := merged.isFlipped or (merged.isRes != isRes)
            merged.hasPrimary := merged.hasPrimary or hasPrimary
            merged.hasSecondary := merged.hasSecondary or hasSecondary
            arr.set(mergeIndex, merged)

        while arr.size() > maxStored
            arr.shift()
    0

// --- Core Logic ---
if not na(htfHigh) and na(htfHigh[1])
    levels.push(PivotLevel.new(htfHigh, htfTime, true, nz(htfVol), false, true, false))
    float primaryHighRawShelfDistance = not na(htfAtr) and htfAtr > 0 ? htfAtr * shelfToleranceAtr : math.max(mergeThresholdTicks * syminfo.mintick, syminfo.mintick)
    float primaryHighShelfDistance = math.min(primaryHighRawShelfDistance, math.max(mergeThresholdTicks * syminfo.mintick, syminfo.mintick))
    f_add_or_merge_shelf(shelfZones, true, htfHigh, htfTime, nz(htfVol), primaryHighShelfDistance, true, false, shelfMaxStored)
if not na(htfLow) and na(htfLow[1])
    levels.push(PivotLevel.new(htfLow, htfTime, false, nz(htfVol), false, true, false))
    float primaryLowRawShelfDistance = not na(htfAtr) and htfAtr > 0 ? htfAtr * shelfToleranceAtr : math.max(mergeThresholdTicks * syminfo.mintick, syminfo.mintick)
    float primaryLowShelfDistance = math.min(primaryLowRawShelfDistance, math.max(mergeThresholdTicks * syminfo.mintick, syminfo.mintick))
    f_add_or_merge_shelf(shelfZones, false, htfLow, htfTime, nz(htfVol), primaryLowShelfDistance, true, false, shelfMaxStored)

if useSecondaryTf and not na(secondaryHigh) and na(secondaryHigh[1])
    levels.push(PivotLevel.new(secondaryHigh, secondaryTime, true, nz(secondaryVol), false, false, true))
    float secondaryHighRawShelfDistance = not na(secondaryAtr) and secondaryAtr > 0 ? secondaryAtr * shelfToleranceAtr : math.max(mergeThresholdTicks * syminfo.mintick, syminfo.mintick)
    float secondaryHighShelfDistance = math.min(secondaryHighRawShelfDistance, math.max(mergeThresholdTicks * syminfo.mintick, syminfo.mintick))
    f_add_or_merge_shelf(shelfZones, true, secondaryHigh, secondaryTime, nz(secondaryVol), secondaryHighShelfDistance, false, true, shelfMaxStored)
if useSecondaryTf and not na(secondaryLow) and na(secondaryLow[1])
    levels.push(PivotLevel.new(secondaryLow, secondaryTime, false, nz(secondaryVol), false, false, true))
    float secondaryLowRawShelfDistance = not na(secondaryAtr) and secondaryAtr > 0 ? secondaryAtr * shelfToleranceAtr : math.max(mergeThresholdTicks * syminfo.mintick, syminfo.mintick)
    float secondaryLowShelfDistance = math.min(secondaryLowRawShelfDistance, math.max(mergeThresholdTicks * syminfo.mintick, syminfo.mintick))
    f_add_or_merge_shelf(shelfZones, false, secondaryLow, secondaryTime, nz(secondaryVol), secondaryLowShelfDistance, false, true, shelfMaxStored)

while levels.size() > maxStoredPivotLevels
    levels.shift()

// Mitigation Logic
if barstate.isconfirmed and levels.size() > 0
    for i = levels.size() - 1 to 0
        PivotLevel lvl = levels.get(i)
        if lvl.isRes and close > lvl.price
            lvl.isRes := false
            lvl.isFlipped := true
        else if not lvl.isRes and close < lvl.price
            lvl.isRes := true
            lvl.isFlipped := true
        levels.set(i, lvl)

if barstate.isconfirmed and shelfZones.size() > 0
    for i = shelfZones.size() - 1 to 0
        ShelfZone zone = shelfZones.get(i)
        float zoneMid = f_shelf_mid(zone)
        if zone.isRes and close > zoneMid
            zone.isRes := false
            zone.isFlipped := true
        else if not zone.isRes and close < zoneMid
            zone.isRes := true
            zone.isFlipped := true
        shelfZones.set(i, zone)

f_tf_label(_tf) =>
    string tfLabel = _tf
    tfLabel := _tf == "30" ? "30m" : _tf == "60" ? "1H" : _tf == "120" ? "2H" : _tf == "240" ? "4H" : _tf == "D" ? "1D" : tfLabel
    tfLabel

f_shelf_tf_label(ShelfZone _zone) =>
    string primaryLabel = f_tf_label(htf)
    string secondaryLabel = f_tf_label(secondaryTf)
    string tfText = ""
    if _zone.hasSecondary
        tfText := secondaryLabel
    if _zone.hasPrimary
        tfText := tfText == "" ? primaryLabel : tfText + "+" + primaryLabel
    tfText

f_update_level(array<line> lineArr, array<label> labelArr, int slot, bool visible, float levelPrice, string levelText, color lineColor, color textColor, int lineWidth, int x1Time, int lineEndTime, int labelTime, string extendMode) =>
    line updatedLine = lineArr.get(slot)
    label updatedLabel = labelArr.get(slot)
    if not visible or na(levelPrice) or na(x1Time)
        if not na(updatedLine)
            line.delete(updatedLine)
        if not na(updatedLabel)
            label.delete(updatedLabel)
        updatedLine := na
        updatedLabel := na
    else
        if na(updatedLine)
            updatedLine := line.new(x1Time, levelPrice, lineEndTime, levelPrice, xloc=xloc.bar_time, extend=extend.none, color=lineColor, style=line.style_dotted, width=lineWidth)
        line.set_x1(updatedLine, x1Time)
        line.set_x2(updatedLine, lineEndTime)
        line.set_y1(updatedLine, levelPrice)
        line.set_y2(updatedLine, levelPrice)
        line.set_color(updatedLine, lineColor)
        line.set_width(updatedLine, lineWidth)
        line.set_style(updatedLine, line.style_dotted)
        if extendMode == "Left"
            line.set_extend(updatedLine, extend.left)
        else if extendMode == "Both"
            line.set_extend(updatedLine, extend.both)
        else
            line.set_extend(updatedLine, extend.none)
        if na(updatedLabel)
            updatedLabel := label.new(labelTime, levelPrice, levelText, xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=textColor, style=label.style_label_left, size=size.small)
        label.set_x(updatedLabel, labelTime)
        label.set_y(updatedLabel, levelPrice)
        label.set_text(updatedLabel, levelText)
        label.set_textcolor(updatedLabel, textColor)
    lineArr.set(slot, updatedLine)
    labelArr.set(slot, updatedLabel)
    0

f_add_structure_label(string labelText, int labelBar, float labelPrice, bool isHigh, color labelColor, array<label> labelArr) =>
    label structureLabel = label.new(labelBar, labelPrice, labelText, xloc=xloc.bar_index, color=labelColor, textcolor=color.white, style=isHigh ? label.style_label_down : label.style_label_up, size=size.tiny)
    labelArr.push(structureLabel)
    while labelArr.size() > structureMaxLabels
        label oldLabel = labelArr.shift()
        if not na(oldLabel)
            label.delete(oldLabel)
    0

f_level_allowed(PivotLevel lvl) =>
    lvl.hasPrimary or (useSecondaryTf and lvl.hasSecondary)

f_level_near_selected(array<PivotLevel> selected, PivotLevel candidate, bool getRes, float threshold) =>
    bool isNear = false
    if selected.size() > 0
        for i = 0 to selected.size() - 1
            PivotLevel existing = selected.get(i)
            if existing.isRes == getRes and math.abs(existing.price - candidate.price) <= threshold
                isNear := true
    isNear

f_build_visible_pivot_levels(array<PivotLevel> arr, int maxPerSide, float threshold, float distinctThreshold) =>
    array<PivotLevel> selected = array.new<PivotLevel>()
    for side = 0 to 1
        bool getRes = side == 0
        for pick = 0 to maxPerSide - 1
            float bestDist = na
            int bestIndex = na
            if arr.size() > 0
                for i = 0 to arr.size() - 1
                    PivotLevel candidate = arr.get(i)
                    bool isValid = getRes ? candidate.price >= close : candidate.price <= close
                    bool distinctFromSelected = not f_level_near_selected(selected, candidate, getRes, distinctThreshold)
                    if f_level_allowed(candidate) and isValid and distinctFromSelected
                        float dist = math.abs(candidate.price - close)
                        if na(bestDist) or dist < bestDist
                            bestDist := dist
                            bestIndex := i
            if not na(bestIndex)
                PivotLevel merged = arr.get(bestIndex)
                merged.isFlipped := merged.isFlipped or merged.isRes != getRes
                merged.isRes := getRes
                if arr.size() > 0
                    for j = 0 to arr.size() - 1
                        PivotLevel other = arr.get(j)
                        bool otherValid = getRes ? other.price >= close : other.price <= close
                        if j != bestIndex and f_level_allowed(other) and otherValid and math.abs(other.price - merged.price) <= threshold
                            bool usePrimaryAnchor = other.hasPrimary and not merged.hasPrimary
                            merged.price := usePrimaryAnchor ? other.price : merged.price
                            merged.startTime := math.min(merged.startTime, other.startTime)
                            merged.pivotVolume := math.max(merged.pivotVolume, other.pivotVolume)
                            merged.isFlipped := merged.isFlipped or other.isFlipped or other.isRes != getRes
                            merged.hasPrimary := merged.hasPrimary or other.hasPrimary
                            merged.hasSecondary := merged.hasSecondary or other.hasSecondary
                selected.push(merged)
    selected

f_shelf_from_pivot(PivotLevel lvl, array<ShelfZone> shelfArr, float threshold) =>
    ShelfZone bestZone = ShelfZone.new(lvl.price, lvl.price, lvl.isRes, 1, lvl.startTime, bar_index, lvl.pivotVolume, lvl.isFlipped, lvl.hasPrimary, lvl.hasSecondary, 0.0, false)
    float bestDist = na
    if shelfArr.size() > 0
        for i = 0 to shelfArr.size() - 1
            ShelfZone zone = shelfArr.get(i)
            float zoneMid = f_shelf_mid(zone)
            bool sideOk = lvl.isRes ? zoneMid >= close : zoneMid <= close
            bool touchOk = zone.touches >= shelfMinTouches
            float dist = math.abs(zoneMid - lvl.price)
            if touchOk and sideOk and dist <= threshold and (na(bestDist) or dist < bestDist)
                bestZone := zone
                bestZone.isFlipped := bestZone.isFlipped or bestZone.isRes != lvl.isRes or lvl.isFlipped
                bestZone.isRes := lvl.isRes
                bestZone.hasPrimary := bestZone.hasPrimary or lvl.hasPrimary
                bestZone.hasSecondary := bestZone.hasSecondary or lvl.hasSecondary
                bestZone.pivotVolume := math.max(bestZone.pivotVolume, lvl.pivotVolume)
                bestDist := dist
    bestZone

f_zone_major_score(ShelfZone zone, float maxVolume) =>
    float touchScore = math.min(zone.touches, 4) * 0.75
    float tfScore = zone.hasPrimary and zone.hasSecondary ? 2.0 : zone.hasPrimary ? 1.25 : 0.75
    float volumeScore = maxVolume > 0 ? math.min(zone.pivotVolume / maxVolume, 1.0) * 2.0 : 0.0
    float flipScore = zone.isFlipped ? 0.75 : 0.0
    touchScore + tfScore + volumeScore + flipScore

f_zone_rank_score(ShelfZone zone, float distanceSpan) =>
    float zoneMid = f_shelf_mid(zone)
    float distance = math.abs(zoneMid - close)
    float proximityScore = distanceSpan > 0 ? math.max(0.0, 2.0 * (1.0 - math.min(distance / distanceSpan, 1.0))) : 0.0
    zone.score + proximityScore

f_score_zone(ShelfZone zone, float maxVolume) =>
    float zoneScore = f_zone_major_score(zone, maxVolume)
    bool zoneIsMajor = zoneScore >= majorScoreThreshold
    ShelfZone.new(zone.top, zone.bot, zone.isRes, zone.touches, zone.startTime, zone.lastTouchBar, zone.pivotVolume, zone.isFlipped, zone.hasPrimary, zone.hasSecondary, zoneScore, zoneIsMajor)

f_zone_near_selected(array<ShelfZone> selected, ShelfZone candidate, bool getRes, float threshold) =>
    bool isNear = false
    float candidateMid = f_shelf_mid(candidate)
    if selected.size() > 0
        for i = 0 to selected.size() - 1
            ShelfZone existing = selected.get(i)
            if existing.isRes == getRes and math.abs(f_shelf_mid(existing) - candidateMid) <= threshold
                isNear := true
    isNear

f_select_visible_shelf_zones(array<ShelfZone> arr, int maxPerSide, bool useScoring, float distinctThreshold, float distanceSpan) =>
    array<ShelfZone> selected = array.new<ShelfZone>()
    for side = 0 to 1
        bool getRes = side == 0
        for pick = 0 to maxPerSide - 1
            float bestRank = na
            int bestIndex = na
            if arr.size() > 0
                for i = 0 to arr.size() - 1
                    ShelfZone candidate = arr.get(i)
                    float candidateMid = f_shelf_mid(candidate)
                    bool isValid = getRes ? candidate.isRes and candidateMid >= close : not candidate.isRes and candidateMid <= close
                    bool distinctFromSelected = not f_zone_near_selected(selected, candidate, getRes, distinctThreshold)
                    if isValid and distinctFromSelected
                        float distance = math.abs(candidateMid - close)
                        float rank = useScoring ? f_zone_rank_score(candidate, distanceSpan) : -distance
                        if na(bestRank) or rank > bestRank
                            bestRank := rank
                            bestIndex := i
            if not na(bestIndex)
                selected.push(arr.get(bestIndex))
    selected

int visibleAreasPerSide = math.max(levelsPerTfSide, 2)
float mergeThreshold = mergeThresholdTicks * syminfo.mintick
float displayDistinctThreshold = syminfo.mintick
int candidateAreasPerSide = prioritizeMajorLevels ? math.max(visibleAreasPerSide, majorCandidatePool) : visibleAreasPerSide
array<PivotLevel> activePivotLevels = array.new<PivotLevel>()
array<ShelfZone> candidateShelfZones = array.new<ShelfZone>()
float candidateMaxVol = 0.0
float atr14 = ta.atr(14)
float majorDistanceSpan = math.max(atr14 * majorDistanceAtr, syminfo.mintick)
array<ShelfZone> activeShelfZones = array.new<ShelfZone>()

if runHeavyEngine
    activePivotLevels := f_build_visible_pivot_levels(levels, candidateAreasPerSide, mergeThreshold, displayDistinctThreshold)

    if activePivotLevels.size() > 0
        for lvl in activePivotLevels
            candidateShelfZones.push(f_shelf_from_pivot(lvl, shelfZones, math.max(mergeThreshold, syminfo.mintick)))

    if candidateShelfZones.size() > 0
        for i = 0 to candidateShelfZones.size() - 1
            candidateMaxVol := math.max(candidateMaxVol, candidateShelfZones.get(i).pivotVolume)

    if candidateShelfZones.size() > 0
        for i = 0 to candidateShelfZones.size() - 1
            ShelfZone scoredZone = f_score_zone(candidateShelfZones.get(i), candidateMaxVol)
            candidateShelfZones.set(i, scoredZone)

    activeShelfZones := f_select_visible_shelf_zones(candidateShelfZones, visibleAreasPerSide, prioritizeMajorLevels, displayDistinctThreshold, majorDistanceSpan)

// --- HTF Trend Bias ---
string currentBias = htfClose > htfEma ? "Bullish" : htfClose < htfEma ? "Bearish" : "Neutral"
string biasIcon = currentBias == "Bullish" ? "🟢" : currentBias == "Bearish" ? "🔴" : "⚪"
bool isBullish = htfClose > htfEma
bool isBearish = htfClose < htfEma

// ============================================================
// KEY LEVEL VALUES — moved ahead of Tap Tracking so PDH/PDL/PWH/PWL and
// completed session extremes are available to the key-level SWEEP entry
// path below. Drawing/labeling of these values still happens in the
// "Key Levels" section further down the script — only the VALUE computation
// moved. Every formula here is byte-identical to where it lived before;
// this is pure relocation, not a logic change.
// ============================================================
[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
[pwh, pwl] = request.security(syminfo.tickerid, "W", [high[1], low[1]], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

var float asiaHigh = na
var float asiaLow = na
var int asiaStartTime = na
int asiaTime = time(timeframe.period, asiaSession, "America/New_York")
bool inAsiaSession = not na(asiaTime)
bool asiaStarted = inAsiaSession and na(asiaTime[1])

if asiaStarted
    asiaHigh := high
    asiaLow := low
    asiaStartTime := time
else if inAsiaSession
    asiaHigh := na(asiaHigh) ? high : math.max(asiaHigh, high)
    asiaLow := na(asiaLow) ? low : math.min(asiaLow, low)

var float londonHigh = na
var float londonLow = na
var int londonStartTime = na
int londonTime = time(timeframe.period, londonSession, "America/New_York")
bool inLondonSession = not na(londonTime)
bool londonStarted = inLondonSession and na(londonTime[1])

if londonStarted
    londonHigh := high
    londonLow := low
    londonStartTime := time
else if inLondonSession
    londonHigh := na(londonHigh) ? high : math.max(londonHigh, high)
    londonLow := na(londonLow) ? low : math.min(londonLow, low)

// --- Key Level Sweep State ---
// One arm per formation: a key level can only arm the entry trigger once per
// day/week/session. Re-arms automatically when the level re-forms (new day,
// new week, new session). Without this, a level that stayed swept for
// several bars could re-trigger repeatedly off a single event.
var bool pdhSwept = false
var bool pdlSwept = false
var bool pwhSwept = false
var bool pwlSwept = false
var bool asiaHiSwept = false
var bool asiaLoSwept = false
var bool lonHiSwept = false
var bool lonLoSwept = false

if pdh != pdh[1]
    pdhSwept := false
if pdl != pdl[1]
    pdlSwept := false
if pwh != pwh[1]
    pwhSwept := false
if pwl != pwl[1]
    pwlSwept := false
if asiaStarted
    asiaHiSwept := false
    asiaLoSwept := false
if londonStarted
    lonHiSwept := false
    lonLoSwept := false

// --- Tap Tracking ---
bool inSession1 = not na(time(timeframe.period, alertSession1, "America/New_York"))
bool inSession2 = not na(time(timeframe.period, alertSession2, "America/New_York"))
bool inSession = inSession1 or inSession2

bool tapTriggeredRes = false
bool tapTriggeredSup = false
float alertThreshold = tapThresholdTicks * syminfo.mintick
string tappedResTf = ""
string tappedSupTf = ""
float tappedResPrice = na
float tappedSupPrice = na
float bestResTapDist = na
float bestSupTapDist = na

if runHeavyEngine and inSession and activeShelfZones.size() > 0
    for i = 0 to activeShelfZones.size() - 1
        ShelfZone zone = activeShelfZones.get(i)
        float zoneMid = f_shelf_mid(zone)
        bool zoneTapped = high >= zoneMid - alertThreshold and low <= zoneMid + alertThreshold
        bool zoneTappedPrev = high[1] >= zoneMid - alertThreshold and low[1] <= zoneMid + alertThreshold
        if zoneTapped and not zoneTappedPrev
            float tapDist = math.abs(close - zoneMid)
            if zone.isRes
                if na(bestResTapDist) or tapDist < bestResTapDist
                    tapTriggeredRes := true
                    bestResTapDist := tapDist
                    tappedResTf := f_shelf_tf_label(zone)
                    tappedResPrice := zoneMid
            else
                if na(bestSupTapDist) or tapDist < bestSupTapDist
                    tapTriggeredSup := true
                    bestSupTapDist := tapDist
                    tappedSupTf := f_shelf_tf_label(zone)
                    tappedSupPrice := zoneMid

// --- Key Level Sweep Detection ---
// Separate from the shelf-zone tap logic above: this is a genuine SWEEP
// (wick beyond the level, close back inside, bar-close only) rather than a
// proximity tap, since these are significant enough levels to warrant the
// stricter confirmation. Asia and London only qualify once their session has
// COMPLETED — a break during the session is the session extending, not a
// rejection of it. Evaluated on confirmed bars only (non-repainting). If more
// than one key level sweeps on the same bar, all are marked swept (their
// liquidity was taken together) but only the last-checked one's origin/price
// feeds the entry — a rare same-bar edge case, not a design concern.
bool keySweepTriggeredRes = false
bool keySweepTriggeredSup = false
string keyResOrigin = ""
string keySupOrigin = ""
float keyResPrice = na
float keySupPrice = na

if useKeySweepEntries and runHeavyEngine and inSession and barstate.isconfirmed
    if not pdhSwept and not na(pdh) and high > pdh and close < pdh
        keySweepTriggeredRes := true
        keyResOrigin := "PDH"
        keyResPrice := pdh
        pdhSwept := true
    if includePw and not pwhSwept and not na(pwh) and high > pwh and close < pwh
        keySweepTriggeredRes := true
        keyResOrigin := "PWH"
        keyResPrice := pwh
        pwhSwept := true
    if not asiaHiSwept and not inAsiaSession and not na(asiaHigh) and high > asiaHigh and close < asiaHigh
        keySweepTriggeredRes := true
        keyResOrigin := "Asia High"
        keyResPrice := asiaHigh
        asiaHiSwept := true
    if not lonHiSwept and not inLondonSession and not na(londonHigh) and high > londonHigh and close < londonHigh
        keySweepTriggeredRes := true
        keyResOrigin := "London High"
        keyResPrice := londonHigh
        lonHiSwept := true

    if not pdlSwept and not na(pdl) and low < pdl and close > pdl
        keySweepTriggeredSup := true
        keySupOrigin := "PDL"
        keySupPrice := pdl
        pdlSwept := true
    if includePw and not pwlSwept and not na(pwl) and low < pwl and close > pwl
        keySweepTriggeredSup := true
        keySupOrigin := "PWL"
        keySupPrice := pwl
        pwlSwept := true
    if not asiaLoSwept and not inAsiaSession and not na(asiaLow) and low < asiaLow and close > asiaLow
        keySweepTriggeredSup := true
        keySupOrigin := "Asia Low"
        keySupPrice := asiaLow
        asiaLoSwept := true
    if not lonLoSwept and not inLondonSession and not na(londonLow) and low < londonLow and close > londonLow
        keySweepTriggeredSup := true
        keySupOrigin := "London Low"
        keySupPrice := londonLow
        lonLoSwept := true

// --- 1m BOS Entry Model Logic ---
var int lastSupTapBar = na
var int lastResTapBar = na
var string lastSupZoneTf = ""
var string lastResZoneTf = ""
var float lastSupZonePrice = na
var float lastResZonePrice = na

if tapTriggeredSup
    lastSupTapBar := bar_index
    lastSupZoneTf := tappedSupTf
    lastSupZonePrice := tappedSupPrice
if tapTriggeredRes
    lastResTapBar := bar_index
    lastResZoneTf := tappedResTf
    lastResZonePrice := tappedResPrice

// Key-level sweeps are a SECOND way to arm the same pending-entry state. If
// both a shelf tap and a key sweep fire on the same bar, the key sweep
// (checked second) takes precedence — arguably the more significant event.
if keySweepTriggeredSup
    lastSupTapBar := bar_index
    lastSupZoneTf := keySupOrigin
    lastSupZonePrice := keySupPrice
if keySweepTriggeredRes
    lastResTapBar := bar_index
    lastResZoneTf := keyResOrigin
    lastResZonePrice := keyResPrice

if not na(lastSupTapBar)
    if bar_index - lastSupTapBar > maxBarsSinceTap
        lastSupTapBar := na
        lastSupZoneTf := ""
        lastSupZonePrice := na

if not na(lastResTapBar)
    if bar_index - lastResTapBar > maxBarsSinceTap
        lastResTapBar := na
        lastResZoneTf := ""
        lastResZonePrice := na

// --- 1m Market Structure Tags ---
var array<label> structureLabels = array.new<label>()
var float lastStructureHigh = na
var float lastStructureLow = na

float structurePivotHigh = ta.pivothigh(high, structurePivotLen, structurePivotLen)
float structurePivotLow = ta.pivotlow(low, structurePivotLen, structurePivotLen)

if showStructureTags and not na(structurePivotHigh)
    int structureHighBar = bar_index - structurePivotLen
    bool isHigherHigh = not na(lastStructureHigh) and structurePivotHigh > lastStructureHigh
    bool isLowerHigh = not na(lastStructureHigh) and structurePivotHigh < lastStructureHigh
    if runHeavyEngine and (isHigherHigh or isLowerHigh)
        string structureText = isHigherHigh ? "HH" : "LH"
        color structureColor = isHigherHigh ? structureBullColor : structureBearColor
        f_add_structure_label(structureText, structureHighBar, structurePivotHigh, true, structureColor, structureLabels)
    lastStructureHigh := structurePivotHigh

if showStructureTags and not na(structurePivotLow)
    int structureLowBar = bar_index - structurePivotLen
    bool isHigherLow = not na(lastStructureLow) and structurePivotLow > lastStructureLow
    bool isLowerLow = not na(lastStructureLow) and structurePivotLow < lastStructureLow
    if runHeavyEngine and (isHigherLow or isLowerLow)
        string structureText = isHigherLow ? "HL" : "LL"
        color structureColor = isHigherLow ? structureBullColor : structureBearColor
        f_add_structure_label(structureText, structureLowBar, structurePivotLow, false, structureColor, structureLabels)
    lastStructureLow := structurePivotLow

ph1m = ta.pivothigh(high, bosPivotLen, bosPivotLen)
pl1m = ta.pivotlow(low, bosPivotLen, bosPivotLen)

var float lastPH1m = na
var float lastPL1m = na

if not na(ph1m)
    lastPH1m := ph1m
if not na(pl1m)
    lastPL1m := pl1m

bool longTapActive = not na(lastSupTapBar) and bar_index - lastSupTapBar <= maxBarsSinceTap
bool shortTapActive = not na(lastResTapBar) and bar_index - lastResTapBar <= maxBarsSinceTap

// BOS Triggers (buffer requires a clean clear of the pivot, not a bare tag)
float breakoutBuffer = breakoutBufferTicks * syminfo.mintick
bool crossUp = ta.crossover(close, lastPH1m + breakoutBuffer)
bool crossDn = ta.crossunder(close, lastPL1m - breakoutBuffer)
bool bullBOS = not na(lastPH1m) and crossUp
bool bearBOS = not na(lastPL1m) and crossDn

// --- Synthetic Orderflow (Delta) Confirmation ---
// Pine cannot access true bid/ask tick data, so delta here is ESTIMATED from
// OHLCV: the close's position within the bar's range is used to split volume
// into implied buying vs selling pressure. A bar closing at its high implies
// buyers absorbed the bar; closing at its low implies sellers did. This is an
// inference, not real orderflow, and should be treated as such.
float barRange = high - low
float closePosition = barRange > 0 ? (close - low) / barRange : 0.5
float buyVolume = volume * closePosition
float sellVolume = volume * (1.0 - closePosition)
float barDelta = buyVolume - sellVolume
float barDeltaRatio = volume > 0 ? barDelta / volume : 0.0

float avgVolume = ta.sma(volume, deltaVolLen)
bool deltaVolumeOk = not deltaRequireVolume or (not na(avgVolume) and avgVolume > 0 and volume >= avgVolume * deltaVolMult)

bool longBarDeltaOk = barDeltaRatio >= deltaBarMinRatio
bool shortBarDeltaOk = barDeltaRatio <= -deltaBarMinRatio

// Cumulative delta measured from the zone tap forward, capped at
// cumDeltaMaxBars so an old tap doesn't drag in unrelated history.
int longCumLookback = na(lastSupTapBar) ? na : math.min(math.max(bar_index - lastSupTapBar, 1), cumDeltaMaxBars)
int shortCumLookback = na(lastResTapBar) ? na : math.min(math.max(bar_index - lastResTapBar, 1), cumDeltaMaxBars)

float longCumDelta = na(longCumLookback) ? na : math.sum(barDelta, longCumLookback)
float shortCumDelta = na(shortCumLookback) ? na : math.sum(barDelta, shortCumLookback)

bool longCumDeltaOk = not requireCumDelta or (not na(longCumDelta) and longCumDelta > 0)
bool shortCumDeltaOk = not requireCumDelta or (not na(shortCumDelta) and shortCumDelta < 0)

bool longDeltaOk = not requireDelta or (longBarDeltaOk and deltaVolumeOk and longCumDeltaOk)
bool shortDeltaOk = not requireDelta or (shortBarDeltaOk and deltaVolumeOk and shortCumDeltaOk)

// --- Displacement confirmation on the BOS candle ---
// Measures conviction of the breakout bar itself: total range vs ATR, body
// as a fraction of range (so the close finishes strong instead of leaving a
// big rejection wick), and optionally a directional close. Independent of
// any prior price geometry, so it applies equally to reversal and
// continuation breaks.
float dispRange = high - low
float dispBody = math.abs(close - open)
float dispBodyPct = dispRange > 0 ? dispBody / dispRange : 0.0
bool dispRangeOk = not na(atr14) and atr14 > 0 and dispRange >= atr14 * dispRangeAtr
bool dispBodyOk = dispBodyPct >= dispBodyRatio
bool dispBullCloseOk = not dispRequireDirectionalClose or close > open
bool dispBearCloseOk = not dispRequireDirectionalClose or close < open
bool longDisplacementOk = not requireDisplacement or (dispRangeOk and dispBodyOk and dispBullCloseOk)
bool shortDisplacementOk = not requireDisplacement or (dispRangeOk and dispBodyOk and dispBearCloseOk)

// Entry Conditions (with Trend Filter)
bool longSignal = bullBOS and longTapActive and longDisplacementOk and longDeltaOk and inSession
bool shortSignal = bearBOS and shortTapActive and shortDisplacementOk and shortDeltaOk and inSession

if filterByBias
    longSignal := longSignal and isBullish
    shortSignal := shortSignal and isBearish

var int lastLongEntrySignalBar = na
var int lastShortEntrySignalBar = na
bool rawLongEntrySignal = longSignal and barstate.isconfirmed
bool rawShortEntrySignal = shortSignal and barstate.isconfirmed
bool longCooldownOk = na(lastLongEntrySignalBar) or bar_index - lastLongEntrySignalBar >= entryCooldownBars
bool shortCooldownOk = na(lastShortEntrySignalBar) or bar_index - lastShortEntrySignalBar >= entryCooldownBars
bool longEntrySignal = rawLongEntrySignal and longCooldownOk
bool shortEntrySignal = rawShortEntrySignal and shortCooldownOk
bool anyEntrySignal = longEntrySignal or shortEntrySignal

if longEntrySignal
    lastLongEntrySignalBar := bar_index
if shortEntrySignal
    lastShortEntrySignalBar := bar_index

string entryZoneTf = longEntrySignal ? lastSupZoneTf : shortEntrySignal ? lastResZoneTf : ""
float entryZonePrice = longEntrySignal ? lastSupZonePrice : shortEntrySignal ? lastResZonePrice : na

// --- Visual SL/TP Trade Tracker ---
var float tradeEntry = na
var float tradeSL = na
var float tradeTP = na
var int tradeDir = 0
var int tradeEntryBar = na
var line lineSL = na
var line lineTP = na
var label lblSL = na
var label lblTP = na

float slBuffer = slBufferTicks * syminfo.mintick
float longStructureSL = ta.lowest(low[1], slLookbackBars)
float shortStructureSL = ta.highest(high[1], slLookbackBars)

if longEntrySignal
    tradeEntry := close
    float longPivotSL = nz(lastPL1m, low)
    float longSetupSL = slMethod == "Structure lookback extreme" ? nz(longStructureSL, longPivotSL) : longPivotSL
    tradeSL := (longSetupSL < tradeEntry ? longSetupSL : math.min(low, tradeEntry - syminfo.mintick)) - slBuffer
    tradeTP := tradeEntry + ((tradeEntry - tradeSL) * rrRatio)
    tradeDir := 1
    tradeEntryBar := bar_index
    
    if showTradeTracker
        line.delete(lineSL), line.delete(lineTP)
        label.delete(lblSL), label.delete(lblTP)

        lineSL := line.new(bar_index, tradeSL, bar_index + 5, tradeSL, color=color.orange, style=line.style_solid, width=2)
        lineTP := line.new(bar_index, tradeTP, bar_index + 5, tradeTP, color=color.blue, style=line.style_solid, width=2)
        
        string rrStr = str.tostring(rrRatio)
        lblSL := label.new(bar_index + 5, tradeSL, text="SL " + str.tostring(tradeSL, format.mintick), color=color.new(color.orange, 0), textcolor=color.white, style=label.style_label_left, size=size.small)
        lblTP := label.new(bar_index + 5, tradeTP, text="TP " + str.tostring(tradeTP, format.mintick) + " (" + rrStr + "R)", color=color.new(color.blue, 0), textcolor=color.white, style=label.style_label_left, size=size.small)
    lastSupTapBar := na 
    lastSupZoneTf := ""
    lastSupZonePrice := na

if shortEntrySignal
    tradeEntry := close
    float shortPivotSL = nz(lastPH1m, high)
    float shortSetupSL = slMethod == "Structure lookback extreme" ? nz(shortStructureSL, shortPivotSL) : shortPivotSL
    tradeSL := (shortSetupSL > tradeEntry ? shortSetupSL : math.max(high, tradeEntry + syminfo.mintick)) + slBuffer
    tradeTP := tradeEntry - ((tradeSL - tradeEntry) * rrRatio)
    tradeDir := -1
    tradeEntryBar := bar_index
    
    if showTradeTracker
        line.delete(lineSL), line.delete(lineTP)
        label.delete(lblSL), label.delete(lblTP)

        lineSL := line.new(bar_index, tradeSL, bar_index + 5, tradeSL, color=color.orange, style=line.style_solid, width=2)
        lineTP := line.new(bar_index, tradeTP, bar_index + 5, tradeTP, color=color.blue, style=line.style_solid, width=2)
        
        string rrStr = str.tostring(rrRatio)
        lblSL := label.new(bar_index + 5, tradeSL, text="SL " + str.tostring(tradeSL, format.mintick), color=color.new(color.orange, 0), textcolor=color.white, style=label.style_label_left, size=size.small)
        lblTP := label.new(bar_index + 5, tradeTP, text="TP " + str.tostring(tradeTP, format.mintick) + " (" + rrStr + "R)", color=color.new(color.blue, 0), textcolor=color.white, style=label.style_label_left, size=size.small)
    lastResTapBar := na 
    lastResZoneTf := ""
    lastResZonePrice := na

// Check for trade completion (cleanup logic)
if not na(tradeEntry)
    if showTradeTracker
        // Extend lines
        line.set_x2(lineSL, bar_index + 5)
        line.set_x2(lineTP, bar_index + 5)
        
        // Extend labels
        label.set_x(lblSL, bar_index + 5)
        label.set_x(lblTP, bar_index + 5)
    
    // Completion Logic (Price hit SL or TP)
    bool tradeClosed = false
    if bar_index > tradeEntryBar
        if tradeDir == 1
            if low <= tradeSL or high >= tradeTP
                tradeClosed := true
        else if tradeDir == -1
            if high >= tradeSL or low <= tradeTP
                tradeClosed := true
            
    if tradeClosed
        if showTradeTracker
            // Delete all visual tracking lines and labels
            line.delete(lineSL), line.delete(lineTP)
            label.delete(lblSL), label.delete(lblTP)
        tradeEntry := na
        tradeDir := 0
        tradeEntryBar := na

// Plot Entry Signals
if not showOnlyLastEntryPerSide and longEntrySignal
    label.new(bar_index, low, text="LONG", xloc=xloc.bar_index, yloc=yloc.belowbar, color=longEntryColor, textcolor=entryLabelTextColor, style=label.style_label_up, size=size.small)
if not showOnlyLastEntryPerSide and shortEntrySignal
    label.new(bar_index, high, text="SHORT", xloc=xloc.bar_index, yloc=yloc.abovebar, color=shortEntryColor, textcolor=entryLabelTextColor, style=label.style_label_down, size=size.small)

var label lastLongEntryLabel = na
var label lastShortEntryLabel = na

if showOnlyLastEntryPerSide and longEntrySignal
    label.delete(lastLongEntryLabel)
    lastLongEntryLabel := label.new(bar_index, low, text="LONG", xloc=xloc.bar_index, yloc=yloc.belowbar, color=longEntryColor, textcolor=entryLabelTextColor, style=label.style_label_up, size=size.small)

if showOnlyLastEntryPerSide and shortEntrySignal
    label.delete(lastShortEntryLabel)
    lastShortEntryLabel := label.new(bar_index, high, text="SHORT", xloc=xloc.bar_index, yloc=yloc.abovebar, color=shortEntryColor, textcolor=entryLabelTextColor, style=label.style_label_down, size=size.small)

if anyEntrySignal
    string alertBias = longEntrySignal ? "Bullish" : "Bearish"
    string alertSide = longEntrySignal ? "LONG" : "SHORT"
    string alertZoneSide = longEntrySignal ? "Support" : "Resistance"
    string alertTf = entryZoneTf == "" ? "Unknown TF" : entryZoneTf
    string alertZonePrice = na(entryZonePrice) ? "Unknown" : str.tostring(entryZonePrice, format.mintick)
    alert(alertSide + " " + alertBias + " Entry | Zone: " + alertTf + " " + alertZoneSide + " @ " + alertZonePrice + " | Entry: " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

alertcondition(anyEntrySignal, title="Entry Signal", message="Entry signal triggered on {{ticker}} at {{close}}. Check chart for LONG/SHORT direction.")

// --- VWAP Logic ---
get_anchored_vwap(cond) =>
    var float sumSrcVol = 0.0
    var float sumVol = 0.0
    if cond
        sumSrcVol := hlc3 * volume
        sumVol := volume
    else
        sumSrcVol += hlc3 * volume
        sumVol += volume
    sumVol > 0 ? sumSrcVol / sumVol : na

// TDO Session: Anchors exactly at 18:00 EST
isTdoStart = hour(time, "America/New_York") >= 18 and hour(time[1], "America/New_York") < 18

// NY Session: 09:30 EST to 16:00 EST
isNyStart = hour(time, "America/New_York") == 9 and minute(time, "America/New_York") == 30
isNySession = not na(time(timeframe.period, "0930-1600", "America/New_York"))

tdoVwap = get_anchored_vwap(isTdoStart or barstate.isfirst)
nyVwap = get_anchored_vwap(isNyStart or barstate.isfirst)

plot(showVwaps ? tdoVwap : na, title="TDO VWAP", color=tdoColor, linewidth=2)
plot(showVwaps and isNySession ? nyVwap : na, title="NY VWAP", color=nyColor, linewidth=2)

// --- Key Levels ---
// PDH/PDL/PWH/PWL and Asia/London extremes are computed earlier (see the
// "Key Level Values" block above Tap Tracking) so they're available to the
// key-level sweep entry logic. Only display/drawing happens here now.
var float trueDayOpen = na
if isTdoStart or na(trueDayOpen)
    trueDayOpen := open

int chartBarMs = na(time[1]) ? timeframe.in_seconds(timeframe.period) * 1000 : time - time[1]
int srLevelEndTime = time + chartBarMs * 20
int srLevelLabelTime = time + chartBarMs * 28
int keyLevelLineEndTime = time + chartBarMs * 5
int keyLevelLabelTime = time + chartBarMs * 6

var array<line> keyLevelLines = array.new_line(9)
var array<label> keyLevelLabels = array.new_label(9)

f_update_level(keyLevelLines, keyLevelLabels, 0, showPdh, pdh, "PDH", pdhColor, keyLevelTextColor, 2, time, keyLevelLineEndTime, keyLevelLabelTime, "Left")
f_update_level(keyLevelLines, keyLevelLabels, 1, showPdl, pdl, "PDL", pdlColor, keyLevelTextColor, 2, time, keyLevelLineEndTime, keyLevelLabelTime, "Left")
f_update_level(keyLevelLines, keyLevelLabels, 2, showTrueDayOpen, trueDayOpen, "TDO", trueDayOpenColor, keyLevelTextColor, 2, time, keyLevelLineEndTime, keyLevelLabelTime, "Left")
f_update_level(keyLevelLines, keyLevelLabels, 3, showAsiaLevels and not na(asiaStartTime), asiaHigh, "Asia High", asiaColor, keyLevelTextColor, 2, asiaStartTime, keyLevelLineEndTime, keyLevelLabelTime, "None")
f_update_level(keyLevelLines, keyLevelLabels, 4, showAsiaLevels and not na(asiaStartTime), asiaLow, "Asia Low", asiaColor, keyLevelTextColor, 2, asiaStartTime, keyLevelLineEndTime, keyLevelLabelTime, "None")
f_update_level(keyLevelLines, keyLevelLabels, 5, showLondonLevels and not na(londonStartTime), londonHigh, "London High", londonColor, keyLevelTextColor, 2, londonStartTime, keyLevelLineEndTime, keyLevelLabelTime, "None")
f_update_level(keyLevelLines, keyLevelLabels, 6, showLondonLevels and not na(londonStartTime), londonLow, "London Low", londonColor, keyLevelTextColor, 2, londonStartTime, keyLevelLineEndTime, keyLevelLabelTime, "None")
f_update_level(keyLevelLines, keyLevelLabels, 7, includePw and showPwh, pwh, "PWH", pdhColor, keyLevelTextColor, 2, time, keyLevelLineEndTime, keyLevelLabelTime, "Left")
f_update_level(keyLevelLines, keyLevelLabels, 8, includePw and showPwh, pwl, "PWL", pdlColor, keyLevelTextColor, 2, time, keyLevelLineEndTime, keyLevelLabelTime, "Left")

// --- Drawing ---
if barstate.islast
    while array.size(activeLines) > 0
        line.delete(array.pop(activeLines))
    while array.size(activeLabels) > 0
        label.delete(array.pop(activeLabels))

    if showShelfZones
        float maxVol = 0.0
        if activeShelfZones.size() > 0
            for i = 0 to activeShelfZones.size() - 1
                maxVol := math.max(maxVol, activeShelfZones.get(i).pivotVolume)

        if activeShelfZones.size() > 0
            for i = 0 to activeShelfZones.size() - 1
                ShelfZone zone = activeShelfZones.get(i)
                int endTime = srLevelEndTime
                float zoneMid = f_shelf_mid(zone)
                bool isHighestVol = (zone.pivotVolume == maxVol) and (maxVol > 0)
                color zoneCol = zone.isRes ? resColor : supColor
                line shelfLine = line.new(zone.startTime, zoneMid, endTime, zoneMid, xloc=xloc.bar_time, color=zoneCol, width=2, style=line.style_solid)
                activeLines.push(shelfLine)

                string tfStr = f_shelf_tf_label(zone)
                string volStr = str.tostring(zone.pivotVolume, format.volume)
                string flipStr = zone.isFlipped ? " [Flipped]" : ""
                string majorStr = zone.isMajor ? " [Major]" : ""
                string lblText = str.tostring(zoneMid, format.mintick) + flipStr + majorStr + "\nTF: " + tfStr + "\nVol: " + volStr + "\nTouches: " + str.tostring(zone.touches)

                if showBias
                    lblText := lblText + "\nTrend: " + biasIcon + " " + currentBias

                if isHighestVol
                    lblText := lblText + "\n★ Max Vol"

                label lbl = label.new(srLevelLabelTime, zoneMid, text=lblText, xloc=xloc.bar_time,
                                color=color.new(color.white, 100), textcolor=levelLabelTextColor,
                                style=label.style_label_left, size=size.small)
                activeLabels.push(lbl)

// --- Delta Debug Table ---
// Live synthetic delta readings for threshold sanity-checking. Shows the
// current bar's implied buy/sell split, how it compares to the configured
// thresholds, and whether each side's delta gate currently passes.
var table deltaTable = table.new(position.top_right, 2, 8, border_width=1)

if showDeltaDebug and barstate.islast
    table.cell(deltaTable, 0, 0, "Synthetic Delta", bgcolor=color.new(#D4AF37, 0), text_color=color.black, text_size=size.small)
    table.cell(deltaTable, 1, 0, "", bgcolor=color.new(#D4AF37, 0), text_size=size.small)

    table.cell(deltaTable, 0, 1, "Bar Delta", text_color=color.white, text_size=size.small)
    table.cell(deltaTable, 1, 1, str.tostring(barDelta, format.volume), text_color=barDelta >= 0 ? color.lime : color.red, text_size=size.small)

    table.cell(deltaTable, 0, 2, "Delta Ratio", text_color=color.white, text_size=size.small)
    table.cell(deltaTable, 1, 2, str.tostring(barDeltaRatio, "#.##"), text_color=barDeltaRatio >= 0 ? color.lime : color.red, text_size=size.small)

    table.cell(deltaTable, 0, 3, "Threshold", text_color=color.white, text_size=size.small)
    table.cell(deltaTable, 1, 3, "±" + str.tostring(deltaBarMinRatio, "#.##"), text_color=color.silver, text_size=size.small)

    table.cell(deltaTable, 0, 4, "Volume / Avg", text_color=color.white, text_size=size.small)
    table.cell(deltaTable, 1, 4, str.tostring(volume, format.volume) + " / " + (na(avgVolume) ? "n/a" : str.tostring(avgVolume, format.volume)), text_color=deltaVolumeOk ? color.lime : color.red, text_size=size.small)

    table.cell(deltaTable, 0, 5, "Cum Delta (L)", text_color=color.white, text_size=size.small)
    table.cell(deltaTable, 1, 5, na(longCumDelta) ? "no tap" : str.tostring(longCumDelta, format.volume), text_color=na(longCumDelta) ? color.silver : (longCumDelta > 0 ? color.lime : color.red), text_size=size.small)

    table.cell(deltaTable, 0, 6, "Cum Delta (S)", text_color=color.white, text_size=size.small)
    table.cell(deltaTable, 1, 6, na(shortCumDelta) ? "no tap" : str.tostring(shortCumDelta, format.volume), text_color=na(shortCumDelta) ? color.silver : (shortCumDelta < 0 ? color.lime : color.red), text_size=size.small)

    table.cell(deltaTable, 0, 7, "Gate L / S", text_color=color.white, text_size=size.small)
    table.cell(deltaTable, 1, 7, (longDeltaOk ? "PASS" : "FAIL") + " / " + (shortDeltaOk ? "PASS" : "FAIL"), text_color=color.silver, text_size=size.small)
````

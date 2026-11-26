# Zero G Order Blocks

- url: https://www.tradingview.com/script/hxxIuObu-Zero-G-Order-Blocks/
- type: indicator
- pine_id: PUB;a9f1e3febe6848f3827aa12630be2a9d
- version: 1.0

## Description

# Zero G Order Blocks

Zero G Order Blocks is a chart-analysis indicator from Zero G Trading designed to identify, display, and track bullish and bearish order-block zones using price and volume-derived pivot conditions.

The indicator is intended for discretionary chart analysis. It does not generate automated trades, execute orders, or present historical strategy-performance results.

## HOW IT WORKS

Zero G Order Blocks evaluates volume pivot conditions and the surrounding price structure to identify qualifying bullish and bearish zones.

When a qualifying pivot is confirmed, the indicator uses the source candle's price range to construct the corresponding zone.

For bullish blocks, the zone extends from the source candle's low to the midpoint of its range.

For bearish blocks, the zone extends from the midpoint of the source candle's range to its high.

Once detected, zones extend forward on the chart so traders can monitor how price interacts with them over time.

A zone continues to be tracked until it is mitigated according to the selected mitigation method, exceeds the optional maximum-age setting, or is removed because of the configured storage limit.

Users can choose between wick-based and close-based mitigation. Touching the outside edge of a zone alone does not necessarily invalidate it.

## DETECTION SETTINGS

The pivot length controls how selective the detection process is.

The default setting uses a 5-bar pivot structure, while faster 3-bar and 2-bar options are available along with a custom setting.

Changing the pivot length changes which price structures qualify as blocks. Lower values generally create more frequent detections, while higher values require a more established pivot structure.

## ZONE STATES

Zones can be classified visually as fresh or tested.

A fresh zone has not been revisited by subsequent price action.

A zone becomes tested when a later candle's range first overlaps the zone.

A tested zone should not be interpreted as confirmed support or resistance. The classification only describes whether price has returned to that area.

Optional fading and labels can be used to distinguish fresh and previously tested zones.

## CHART DISPLAY

Users can configure:

• Number of visible bullish and bearish zones  
• Bullish and bearish zone colors  
• Zone transparency  
• Midpoint-line visibility and appearance  
• Fresh/tested labels  
• Fading of previously tested zones  
• Maximum zone age  
• Mitigation behavior

By default, the indicator displays the three most recent surviving zones in each direction with midpoint lines enabled.

Green represents bullish zones and red represents bearish zones using the default settings. These colors can be changed by the user.

## REAL-TIME AND CANDLE-CLOSE UPDATES

The indicator can evaluate developing conditions during the current candle or wait until the candle closes before confirming zone-related events.

When "Wait for candle close" is enabled, zone events are processed only after the relevant candle closes.

This setting does not eliminate the confirmation period required by the underlying pivot calculation.

## IMPORTANT: DETECTION TIMING

Pivot-based detection requires future candles before a historical pivot can be confirmed.

For example, with the default 5-bar pivot setting, five subsequent bars are required before the source pivot can be identified.

If "Start boxes at source candle" is enabled, the indicator draws the resulting zone back to the original source candle after confirmation.

This does not mean that the zone was known in real time on that original candle. The zone only becomes available after the required confirmation bars have occurred.

When using live updates, developing zones or markers may also change before the detection candle closes.

## ALERTS

Optional TradingView alert conditions are available for:

• Bullish block detection  
• Bearish block detection  
• First bullish-zone retest  
• First bearish-zone retest  
• Bullish-zone mitigation  
• Bearish-zone mitigation

Alert conditions are disabled by default and can be enabled through the indicator settings.

## LIMITATIONS

Order blocks displayed by this indicator are algorithmically identified chart zones based on price and volume-derived conditions.

They do not represent verified institutional orders, exchange order-book positioning, or guaranteed support and resistance.

Because pivot confirmation requires subsequent candles, historical zones may visually begin before the point at which they became detectable in real time.

Different pivot lengths and mitigation settings can materially change the zones displayed.

## Source Code

````pine
//@version=6
// Zero G Order Blocks
// Creative license owned by ZERO G TRADING

indicator("Zero G Order Blocks", shorttitle = "ZG OB", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_bars_back = 500)

// --------------------------- Detector settings ---------------------------
string G_DETECT = "1. Order block detection"
string detectionSpeed = input.string("Original - 5 bars", "Detection speed", options = ["Original - 5 bars", "Faster - 3 bars", "Fast - 2 bars", "Custom"], group = G_DETECT, tooltip = "Uses the supplied LuxAlgo volume-pivot formula. Match its Volume Pivot Length for comparison. Faster settings change the detected zones, not only the delay.")
int customVolumeSpan = input.int(5, "Custom volume pivot length", minval = 1, maxval = 100, group = G_DETECT)
int volumeSpan = detectionSpeed == "Original - 5 bars" ? 5 : detectionSpeed == "Faster - 3 bars" ? 3 : detectionSpeed == "Fast - 2 bars" ? 2 : customVolumeSpan
string invalidation = input.string("Wick", "Mitigation method", options = ["Wick", "Close"], group = G_DETECT, tooltip = "Preserves the supplied rolling mitigation rule. Bullish blocks are removed strictly below their bottom; bearish blocks strictly above their top. Touching the boundary alone does not remove a block.")
bool waitForClose = input.bool(false, "Wait for candle close", group = G_DETECT, tooltip = "OFF: normal live-indicator updates; provisional zones can change before the candle closes. ON: reproduce the closed-bar update timing of your uploaded Entry Lab. The detection formulas are identical in both modes.")

// --------------------------- Manual chart display ------------------------
string G_VIEW = "2. Chart appearance"
int visiblePerSide = input.int(3, "Visible zones per direction", minval = 1, maxval = 20, group = G_VIEW)
bool sourceAnchor = input.bool(true, "Start boxes at source candle", group = G_VIEW, tooltip = "Visual only. A volume pivot needs Volume Pivot Length bars to its right. The box is drawn back to the source when detected, not known on the source candle. Live previews are provisional until the detection candle closes.")
bool showMidpoint = input.bool(true, "Show zone midpoint", group = G_VIEW)
bool showZoneText = input.bool(false, "Show fresh / tested text", group = G_VIEW)
bool fadeTested = input.bool(false, "Fade tested zones", group = G_VIEW, tooltip = "Appearance only. The first subsequent candle whose range overlaps the block marks it tested, but does not remove it unless mitigation also occurs.")
bool showFormation = input.bool(false, "Mark detection bars", group = G_VIEW, tooltip = "Markers are placed on the detection candle, not backdated to the source. In live mode, current-bar markers may change before the candle closes.")
color bullColor = input.color(#169400, "Bullish color", group = G_VIEW)
color bearColor = input.color(#ff1100, "Bearish color", group = G_VIEW)
color midpointColor = input.color(color.new(#9598a1, 37), "Midpoint color", group = G_VIEW)
int fillTransparency = input.int(80, "Zone fill transparency", minval = 0, maxval = 100, group = G_VIEW)
int borderTransparency = input.int(0, "Zone border transparency", minval = 0, maxval = 100, group = G_VIEW)
string midpointStyle = input.string("Solid", "Midpoint style", options = ["Solid", "Dashed", "Dotted"], group = G_VIEW)
int midpointWidth = input.int(1, "Midpoint width", minval = 1, maxval = 4, group = G_VIEW)

string G_LIFE = "3. Advanced zone storage"
int maxAge = input.int(0, "Optional expiry bars (0 = off)", minval = 0, maxval = 2000, group = G_LIFE, tooltip = "Keep at 0 for no age-based expiry. Enabling expiry changes which zones survive. Age is measured from detection, not from the source candle.")
int trackedLimit = input.int(400, "Storage cap", minval = 20, maxval = 400, group = G_LIFE, tooltip = "Same combined bullish/bearish cap as the supplied Entry Lab. Oldest zones are discarded only if this cap is exceeded. Display limits do not change mitigation tracking.")

string G_ALERT = "4. Chart notifications"
bool enableNotifications = input.bool(false, "Enable notification conditions", group = G_ALERT, tooltip = "Optional ordinary TradingView notifications only. There are no order instructions or broker payloads. Create any desired alert manually in TradingView.")
bool notificationsAtClose = input.bool(true, "Notifications only at candle close", group = G_ALERT, tooltip = "Recommended for confirmed notifications. Turning this off permits provisional live events when Wait for candle close is also off.")

// --------------------------- Zone storage --------------------------------
type ZGZone
    float top
    float bottom
    int direction
    int originTime
    int bornBar
    bool touched
    box area
    line midpoint

f_delete(ZGZone zone) =>
    box.delete(zone.area)
    line.delete(zone.midpoint)

f_create(int direction, float top, float bottom, int originTime) =>
    color shade = direction == 1 ? bullColor : bearColor
    int leftTime = sourceAnchor ? originTime : time
    // A 1 ms fallback permits drawing on chart types without a known close time.
    int rightTime = na(time_close) ? time + 1 : time_close
    box area = box.new(left = leftTime, top = top, right = rightTime, bottom = bottom, xloc = xloc.bar_time, extend = extend.right, border_color = color.new(shade, borderTransparency), bgcolor = color.new(shade, fillTransparency))
    float middle = (top + bottom) / 2.0
    string chosenStyle = midpointStyle == "Dashed" ? line.style_dashed : midpointStyle == "Dotted" ? line.style_dotted : line.style_solid
    line mid = line.new(x1 = leftTime, y1 = middle, x2 = rightTime, y2 = middle, xloc = xloc.bar_time, extend = extend.right, color = showMidpoint ? midpointColor : na, style = chosenStyle, width = midpointWidth)
    ZGZone.new(top, bottom, direction, originTime, bar_index, false, area, mid)

var array<ZGZone> zones = array.new<ZGZone>()

// --------------------------- Preserved detector math ---------------------
// These formulas are retained from the uploaded LuxAlgo-based Entry Lab.
// No displacement, breakout, candle-color, ATR, EMA or trend filters are added.
// All rolling functions evaluate on every bar, including in closed-bar mode.
float priorHigh = ta.highest(high, volumeSpan)
float priorLow = ta.lowest(low, volumeSpan)
float closeLow = ta.lowest(close, volumeSpan)
float closeHigh = ta.highest(close, volumeSpan)
float targetBull = invalidation == "Close" ? closeLow : priorLow
float targetBear = invalidation == "Close" ? closeHigh : priorHigh
var int swingState = 0
swingState := high[volumeSpan] > priorHigh ? 0 : low[volumeSpan] < priorLow ? 1 : swingState[1]
float volumePeak = ta.pivothigh(volume, volumeSpan, volumeSpan)
// Pine v6 requires an explicit bool; preserve the v5 nonzero-pivot condition.
bool pivotFound = not na(volumePeak) and volumePeak != 0
bool bullBreak = pivotFound and swingState == 1
bool bearBreak = pivotFound and swingState == 0

bool bullFormed = false
bool bearFormed = false
bool bullRetested = false
bool bearRetested = false
bool bullInvalidated = false
bool bearInvalidated = false
bool updateZones = not waitForClose or barstate.isconfirmed

// Ordinary var storage intentionally uses Pine's realtime rollback behavior.
// There is no varip state that would preserve an unconfirmed intrabar preview.
if updateZones
    // Retain the supplied strict rolling-mitigation checks and reverse traversal.
    int idx = array.size(zones) - 1
    while idx >= 0
        ZGZone zone = array.get(zones, idx)
        float invalidPrice = zone.direction == 1 ? targetBull : targetBear
        bool broken = zone.direction == 1 ? invalidPrice < zone.bottom : invalidPrice > zone.top
        bool expired = maxAge > 0 and bar_index - zone.bornBar > maxAge
        if broken or expired
            if broken
                bullInvalidated := bullInvalidated or zone.direction == 1
                bearInvalidated := bearInvalidated or zone.direction == -1
            f_delete(zone)
            array.remove(zones, idx)
        else
            bool firstTouch = not zone.touched and bar_index > zone.bornBar and low <= zone.top and high >= zone.bottom
            if firstTouch
                zone.touched := true
                bullRetested := bullRetested or zone.direction == 1
                bearRetested := bearRetested or zone.direction == -1
        idx -= 1

    // Bullish block = source candle low to its high/low midpoint.
    // Record formation even when that newly detected block is already mitigated.
    if bullBreak
        bullFormed := true
        float top = (high[volumeSpan] + low[volumeSpan]) / 2.0
        float bottom = low[volumeSpan]
        if targetBull < bottom
            bullInvalidated := true
        else
            ZGZone zone = f_create(1, top, bottom, time[volumeSpan])
            array.push(zones, zone)

    // Bearish block = source candle high/low midpoint to its high.
    if bearBreak
        bearFormed := true
        float top = high[volumeSpan]
        float bottom = (high[volumeSpan] + low[volumeSpan]) / 2.0
        if targetBear > top
            bearInvalidated := true
        else
            ZGZone zone = f_create(-1, top, bottom, time[volumeSpan])
            array.push(zones, zone)

    while array.size(zones) > trackedLimit
        ZGZone oldest = array.shift(zones)
        f_delete(oldest)

// --------------------------- Show latest zones ---------------------------
// Tracking continues for hidden zones until mitigation, expiry or the cap.
if barstate.islast
    int bullsShown = 0
    int bearsShown = 0
    int idx = array.size(zones) - 1
    while idx >= 0
        ZGZone zone = array.get(zones, idx)
        bool visible = zone.direction == 1 ? bullsShown < visiblePerSide : bearsShown < visiblePerSide
        if zone.direction == 1
            bullsShown += 1
        else
            bearsShown += 1
        color shade = zone.direction == 1 ? bullColor : bearColor
        int fillAlpha = fadeTested and zone.touched ? math.min(100, fillTransparency + 8) : fillTransparency
        int borderAlpha = fadeTested and zone.touched ? math.min(100, borderTransparency + 25) : borderTransparency
        box.set_bgcolor(zone.area, visible ? color.new(shade, fillAlpha) : na)
        box.set_border_color(zone.area, visible ? color.new(shade, borderAlpha) : na)
        box.set_text(zone.area, visible and showZoneText ? (zone.direction == 1 ? "ZG BULL" : "ZG BEAR") + (zone.touched ? " | TESTED" : " | FRESH") : "")
        box.set_text_color(zone.area, shade)
        box.set_text_size(zone.area, size.tiny)
        line.set_color(zone.midpoint, visible and showMidpoint ? midpointColor : na)
        idx -= 1

// Markers refer to the detection bar, never an earlier source bar.
plotshape(showFormation and bullFormed, title = "Bullish block detected", style = shape.square, location = location.belowbar, color = bullColor, size = size.tiny)
plotshape(showFormation and bearFormed, title = "Bearish block detected", style = shape.square, location = location.abovebar, color = bearColor, size = size.tiny)
plot(volumeSpan, "Volume pivot right bars", display = display.data_window)
plot(array.size(zones), "Tracked zones", display = display.data_window)

// --------------------------- Optional notifications ----------------------
// Plain messages for manual chart monitoring. No strategy or order routing.
bool notify = enableNotifications and (not notificationsAtClose or barstate.isconfirmed)
alertcondition(notify and bullFormed, title = "ZG - Bullish block detected", message = "Zero G Order Blocks: bullish block detected on {{ticker}} ({{interval}}).")
alertcondition(notify and bearFormed, title = "ZG - Bearish block detected", message = "Zero G Order Blocks: bearish block detected on {{ticker}} ({{interval}}).")
alertcondition(notify and bullInvalidated, title = "ZG - Bullish block mitigated", message = "Zero G Order Blocks: bullish block mitigated on {{ticker}} ({{interval}}).")
alertcondition(notify and bearInvalidated, title = "ZG - Bearish block mitigated", message = "Zero G Order Blocks: bearish block mitigated on {{ticker}} ({{interval}}).")
alertcondition(notify and bullRetested, title = "ZG - Bullish block first retest", message = "Zero G Order Blocks: first subsequent-bar overlap of a surviving bullish block on {{ticker}} ({{interval}}).")
alertcondition(notify and bearRetested, title = "ZG - Bearish block first retest", message = "Zero G Order Blocks: first subsequent-bar overlap of a surviving bearish block on {{ticker}} ({{interval}}).")
````

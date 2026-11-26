# ABW Multi-Timeframe FVG

- url: https://www.tradingview.com/script/USskbXy9-ABW-Multi-Timeframe-FVG/
- type: indicator
- pine_id: PUB;f21c15e762eb4b739aead44e85bddcda
- version: 1.0

## Description

[b]ABW Multi-Timeframe FVG[/b]

[b]Overview[/b]

ABW Multi-Timeframe FVG displays confirmed fair value gaps from your chart timeframe and one higher timeframe in a single overlay. Its focus is clear formation windows: every box stays within the source candles that created the gap. In the default recent mode, separate retention limits keep higher-timeframe formations visible as new chart-timeframe gaps appear.

Bullish gaps use blue fill; bearish gaps use red fill. Boxes have no outlines. Small, regular labels at the top-right identify the source timeframe, and fill transparency is adjustable.

The script is open-source, so you can inspect how the gap rules, confirmation, timeframe selection, and retention are implemented.

[image]https://www.tradingview.com/x/QBHM7n1u/[/image]
Daily-chart example: 1D labels mark daily formations; M labels mark monthly formations.

[b]How a Gap Is Defined[/b]

The indicator examines three consecutive candles on each source timeframe.

[list]
[*]Bullish FVG: candle 3's low is strictly above candle 1's high. The box spans the price interval between those two wick prices.
[*]Bearish FVG: candle 3's high is strictly below candle 1's low. The box spans the price interval between those two wick prices.
[/list]

Equal wick prices do not qualify. Candle 2 has no color or body-size requirement. There are no additional displacement, volume, trend, or minimum-gap filters.

[b]Confirmation and Fixed Boxes[/b]

Chart-timeframe gaps appear only after candle 3 closes. Higher-timeframe gaps use confirmed source candles and become available on the first chart update of the next higher-timeframe period. A session break can delay that update.

Each box begins at source candle 1's opening time and ends exactly at source candle 3's closing time, including when the source is displayed on a lower-timeframe chart. Higher-timeframe boxes are drawn back over that earlier formation window after confirmation; they were not available while the source candle was still developing.

Boxes never extend forward or shrink after creation. A later price touch or fill does not remove them. The script records formation and does not track mitigation status; older boxes are removed only when the selected retention limit requires it.

[b]Automatic Higher-Timeframe Mapping[/b]

[b]Chart timeframe -> Higher timeframe[/b]
[list]
[*]1 minute -> 15 minutes
[*]3 minutes -> 30 minutes
[*]5 minutes -> 1 hour
[*]15 minutes -> 4 hours
[*]1 hour -> 1 day
[*]4 hours -> 1 week
[*]1 day -> 1 month
[/list]

One higher-timeframe layer is displayed at a time. A manual override can replace this mapping with any supported time-based timeframe strictly higher than the chart timeframe. Equal or lower selections are rejected. For chart intervals outside the automatic map, a status message asks you to choose a manual higher timeframe or disable that layer.

[b]Settings Guide[/b]

[image]https://www.tradingview.com/x/Q6EoLAvN/[/image]
Controls 1-9: visibility, appearance, and recent limits. Default quotas: chart 5 bullish + 5 bearish; higher timeframe 3 + 3.

[b]Visibility[/b]
[list]
[*][b]1. Show chart timeframe FVGs[/b]: enables local formations or hides them when focusing on higher-timeframe context. Default: on.
[*][b]2. Show higher timeframe FVGs[/b]: enables the mapped or manually selected higher-timeframe layer. Default: on.
[/list]

[b]Appearance[/b]
[list]
[*][b]3. Show source timeframe labels[/b]: identifies the source of each gap or hides text to reduce clutter. Default: on. 5M and 15M denote minutes; 1H and 4H hours; 1D daily; W weekly; M monthly.
[*][b]4. Fill transparency[/b]: 0 is opaque and 100 is fully transparent. Default: 85. Labels are controlled separately from fill transparency.
[/list]

[b]FVG Retention[/b]
[list]
[*][b]5. Show recent FVGs only[/b]: keeps the view focused on recent formations. Default: on. Limits apply separately to all four groups below.
[*][b]6. Chart: bullish FVG limit[/b]: default 5.
[*][b]7. Chart: bearish FVG limit[/b]: default 5.
[*][b]8. Higher timeframe: bullish FVG limit[/b]: default 3.
[*][b]9. Higher timeframe: bearish FVG limit[/b]: default 3.
[/list]

The default allows up to 16 boxes, subject to available gaps. Each group accepts 0-125; setting a group to 0 hides that group. Chart groups cannot remove higher-timeframe boxes, and higher-timeframe groups cannot remove chart boxes. Recency is ranked by source candle 3's closing time, not delivery order, so an older delayed gap cannot replace newer gaps within its group.

[image]https://www.tradingview.com/x/waAc3i9W/[/image]
Controls 10-12: the combined historical cap and manual override. The manual source interval must be strictly higher than the chart.

[list]
[*][b]10. Historical mode: total FVG limit[/b]: active only when recent-only mode is off. It replaces the four recent quotas with one combined limit across both layers and directions. Range: 1-500; default: 500. The oldest source formation is removed first.
[/list]

[b]Higher Timeframe[/b]
[list]
[*][b]11. Use a manual higher timeframe[/b]: default off, so the automatic map is used.
[*][b]12. Manual higher timeframe[/b]: default 1 hour. It takes effect when manual override and the higher-timeframe layer are enabled; choose a value strictly higher than your chart.
[/list]

[b]Interpretation and Limitations[/b]

Use standard time-based charts. Heikin Ashi, Renko, Range, other synthetic charts, and tick charts are unsupported. The display depends on available chart history, confirmed source data, enabled layers, and retention limits.

Blue and red describe the gap's formation direction. A displayed formation does not predict a price reaction or establish a trade signal. The indicator provides no entry/exit signals, alerts, or performance guarantees.

## Source Code

````pine
//@version=6
indicator("ABW Multi-Timeframe FVG", overlay = true, max_boxes_count = 500, dynamic_requests = true)

// Bullish: candle 3 low > candle 1 high. Bearish: candle 3 high < candle 1 low.
// Equal wick prices do not form a gap. Candle 2 has no body or color requirement.
// Left-edge assumption: source candle 1 open. Right edge: source candle 3 close.
// Box geometry stays fixed; later price movement does not extend, shrink, or mitigate it.
// A confirmed HTF gap becomes available at the first update of the next HTF period.
// It is then drawn over its earlier source interval; the gap was not known before confirmation.
// Only standard time-based charts are supported. Synthetic and tick charts raise an error.
// Defaults: 5 bullish + 5 bearish chart boxes, and 3 bullish + 3 bearish HTF boxes, separately.
// Recency uses source candle 3 close time, not the arrival time of delayed HTF data.

const string GROUP_LAYERS = "Visibility"
const string GROUP_STYLE = "Appearance"
const string GROUP_RETENTION = "FVG Retention"
const string GROUP_HTF = "Higher Timeframe"

bool showChart = input.bool(true, "Show chart timeframe FVGs", group = GROUP_LAYERS)
bool showHigher = input.bool(true, "Show higher timeframe FVGs", group = GROUP_LAYERS)
bool showLabels = input.bool(true, "Show source timeframe labels", group = GROUP_STYLE)
int fillTransparency = input.int(85, "Fill transparency (0 opaque, 100 transparent)", minval = 0, maxval = 100, group = GROUP_STYLE)
bool recentOnly = input.bool(true, "Show recent FVGs only", group = GROUP_RETENTION,
     tooltip = "Limits apply separately to each timeframe layer and direction. Chart gaps do not remove higher timeframe boxes. Recency is determined by source candle 3 close time.")
int currentBullCount = input.int(5, "Chart: bullish FVG limit", minval = 0, maxval = 125, group = GROUP_RETENTION, active = recentOnly,
     tooltip = "Set to 0 to hide chart timeframe bullish FVGs. Each limit supports up to 125 boxes, keeping the four limits within 500 boxes in total.")
int currentBearCount = input.int(5, "Chart: bearish FVG limit", minval = 0, maxval = 125, group = GROUP_RETENTION, active = recentOnly,
     tooltip = "Set to 0 to hide chart timeframe bearish FVGs. Each limit supports up to 125 boxes, keeping the four limits within 500 boxes in total.")
int higherBullCount = input.int(3, "Higher timeframe: bullish FVG limit", minval = 0, maxval = 125, group = GROUP_RETENTION, active = recentOnly,
     tooltip = "Set to 0 to hide higher timeframe bullish FVGs. Each limit supports up to 125 boxes, keeping the four limits within 500 boxes in total.")
int higherBearCount = input.int(3, "Higher timeframe: bearish FVG limit", minval = 0, maxval = 125, group = GROUP_RETENTION, active = recentOnly,
     tooltip = "Set to 0 to hide higher timeframe bearish FVGs. Each limit supports up to 125 boxes, keeping the four limits within 500 boxes in total.")
int retainedLimit = input.int(500, "Historical mode: total FVG limit", minval = 1, maxval = 500, group = GROUP_RETENTION, active = not recentOnly,
     tooltip = "Applies when recent-only mode is off. The oldest box by source candle 3 close time is removed first. Later mitigation does not remove boxes.")
bool useManualHigher = input.bool(false, "Use a manual higher timeframe", group = GROUP_HTF)
string manualHigher = input.timeframe("60", "Manual higher timeframe", group = GROUP_HTF,
     tooltip = "Must be strictly higher than the chart timeframe. Tick timeframes are not supported.")

// Pine expresses hourly timeframes in minutes: 60 = 1 hour, 240 = 4 hours.
f_autoHigher() =>
    string result = ""
    if timeframe.isminutes
        result := switch timeframe.multiplier
            1 => "15"
            3 => "30"
            5 => "60"
            15 => "240"
            60 => "1D"
            240 => "1W"
            => ""
    else if timeframe.isdaily and timeframe.multiplier == 1
        result := "1M"
    result

f_timeframeLabel(string sourceTf) =>
    switch sourceTf
        "1" => "One Minute"
        "3" => "Three Minutes"
        "5" => "5M"
        "15" => "15M"
        "30" => "Thirty Minutes"
        "60" => "1H"
        "240" => "4H"
        "1D" => "1D"
        "1W" => "W"
        "1M" => "M"
        => sourceTf

string higherTf = useManualHigher ? manualHigher : f_autoHigher()

if barstate.isfirst
    if not chart.is_standard or timeframe.isticks
        runtime.error("Use a standard time-based chart. Heikin Ashi, Renko, Range, other synthetic charts, and tick charts are not supported.")
    if showHigher and useManualHigher
        if manualHigher == "" or str.endswith(manualHigher, "T")
            runtime.error("The manual higher timeframe must be time-based and strictly higher than the chart timeframe.")
        if timeframe.in_seconds(manualHigher) <= timeframe.in_seconds(timeframe.period)
            runtime.error("Select a manual timeframe strictly higher than the chart timeframe.")

// Arrays are sorted by ascending source close time; index 0 contains the oldest box.
// Recent mode uses a separate array for each layer and direction to prevent cross-layer eviction.
var array<box> currentBulls = array.new<box>()
var array<box> currentBears = array.new<box>()
var array<box> higherBulls = array.new<box>()
var array<box> higherBears = array.new<box>()
var array<box> historyBoxes = array.new<box>()

f_addBox(int leftTime, int rightTime, float topPrice, float bottomPrice, bool bullish, string sourceTf, bool higherLayer) =>
    array<box> activeBoxes = historyBoxes
    int activeLimit = retainedLimit
    if recentOnly
        if higherLayer
            activeBoxes := bullish ? higherBulls : higherBears
            activeLimit := bullish ? higherBullCount : higherBearCount
        else
            activeBoxes := bullish ? currentBulls : currentBears
            activeLimit := bullish ? currentBullCount : currentBearCount
    box createdBox = na
    if activeLimit > 0
        bool keepCandidate = true
        if array.size(activeBoxes) >= activeLimit
            // An older delayed HTF gap cannot displace newer boxes in its own retention group.
            keepCandidate := rightTime >= box.get_right(array.get(activeBoxes, 0))
        if keepCandidate
            // Delete before creating to keep the total within the 500-box object limit.
            if array.size(activeBoxes) >= activeLimit
                box.delete(array.shift(activeBoxes))
            color zoneColor = bullish ? color.blue : color.red
            string zoneText = showLabels ? f_timeframeLabel(sourceTf) : ""
            createdBox := box.new(left = leftTime, top = topPrice, right = rightTime, bottom = bottomPrice,
                 xloc = xloc.bar_time, extend = extend.none, border_color = na,
                 border_width = 0, bgcolor = color.new(zoneColor, fillTransparency),
                 text = zoneText, text_color = chart.fg_color, text_size = size.tiny,
                 text_halign = text.align_right, text_valign = text.align_top,
                 text_formatting = text.format_none)
            int insertAt = array.size(activeBoxes)
            if array.size(activeBoxes) > 0
                for i = 0 to array.size(activeBoxes) - 1
                    if rightTime < box.get_right(array.get(activeBoxes, i))
                        insertAt := i
                        break
            array.insert(activeBoxes, insertAt, createdBox)
    createdBox

// Normal var persistence allows the timestamp and drawing to be recreated after realtime rollback.
// Using varip here could preserve the timestamp while losing the first tick's drawing to rollback.
var int lastHigherClose = na

if showHigher and higherTf != ""
    // Every source series is offset by at least one HTF bar to avoid future data leakage.
    // Candle 3 = [1], candle 1 = [3]. Only confirmed source candles are requested.
    [higherLow3, higherHigh3, higherHigh1, higherLow1, higherLeft, higherRight] = request.security(
         syminfo.tickerid, higherTf, [low[1], high[1], high[3], low[3], time[3], time_close[1]],
         gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
    bool newHigherCandle = not na(higherRight) and (na(lastHigherClose) or higherRight != lastHigherClose)
    if newHigherCandle
        lastHigherClose := higherRight
        if not na(higherLeft) and not na(higherHigh1) and not na(higherLow1)
            if higherLow3 > higherHigh1
                f_addBox(higherLeft, higherRight, higherLow3, higherHigh1, true, higherTf, true)
            else if higherHigh3 < higherLow1
                f_addBox(higherLeft, higherRight, higherLow1, higherHigh3, false, higherTf, true)

// Chart FVGs are created on candle 3's closing update, never before confirmation.
if showChart and barstate.isconfirmed and bar_index >= 2
    if low > high[2]
        f_addBox(time[2], time_close, low, high[2], true, timeframe.period, false)
    else if high < low[2]
        f_addBox(time[2], time_close, low[2], high, false, timeframe.period, false)

// Unmapped chart intervals do not silently select an arbitrary higher timeframe.
var table status = table.new(position.top_right, 1, 1)
if barstate.islast
    if showHigher and higherTf == ""
        table.cell(status, 0, 0, "No automatic higher timeframe is defined for this chart interval.\nChoose a manual higher timeframe in Inputs, or disable the higher timeframe layer.",
             text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 10), text_size = size.small)
    else
        table.clear(status, 0, 0)
````

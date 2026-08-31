<!-- tradingview-pine-id: PUB;dbfcad79958d4071a76509fb5e9bee93 -->
<!-- tradingviewscripts-format: 1 -->
# Dacia Clean MTF Supply + Demand V3.0

Source: https://www.tradingview.com/script/mYIBg52Q-Dacia-MTF-Supply-Demand-Zones/

## Description

Dacia MTF Supply + Demand Zones
Dacia MTF Supply + Demand Zones
Dacia MTF Supply + Demand Zones
Dacia MTF Supply + Demand Zones

---

## Source Code

````pine
//@version=6
indicator("Dacia Clean MTF Supply + Demand V3.0", shorttitle="Dacia MTF S/D V3", overlay=true, max_boxes_count=200, max_lines_count=200)

//=============================================================================
// INPUTS
//=============================================================================
string tfGroup = "1. Timeframes"
bool showTF1 = input.bool(true, "Enable TF1", inline="tf1", group=tfGroup)
string tf1 = input.timeframe("15", "", inline="tf1", group=tfGroup)
bool showTF2 = input.bool(true, "Enable TF2", inline="tf2", group=tfGroup)
string tf2 = input.timeframe("60", "", inline="tf2", group=tfGroup)
bool showTF3 = input.bool(true, "Enable TF3", inline="tf3", group=tfGroup)
string tf3 = input.timeframe("240", "", inline="tf3", group=tfGroup)

string detectGroup = "2. Detection"
int pivotLength = input.int(6, "Pivot Strength", minval=2, maxval=30, group=detectGroup)
int originSearch = input.int(8, "Origin Candle Search", minval=2, maxval=20, group=detectGroup)
string rangeMode = input.string("Body + Wick", "Zone Range", options=["Body", "Body + Wick", "Full Candle"], group=detectGroup)
float maxZoneATR = input.float(1.0, "Maximum Zone Height × ATR", minval=0.20, maxval=4.0, step=0.05, group=detectGroup)
bool requireImpulse = input.bool(true, "Require Impulse Away", group=detectGroup)
float impulseATR = input.float(0.60, "Minimum Impulse × ATR", minval=0.10, maxval=3.0, step=0.05, group=detectGroup)

string historyGroup = "3. History + Extension"
int maxZones = input.int(2, "Historical Zones Per Side / TF", minval=1, maxval=6, group=historyGroup)
int extendBars = input.int(80, "Extend Right (Chart Bars)", minval=10, maxval=300, group=historyGroup)
string brokenStyle = input.string("Hide", "Broken Zones", options=["Hide", "Freeze Gray", "Freeze Colored"], group=historyGroup)

string displayGroup = "4. Display"
bool showLabels = input.bool(true, "Show Labels Inside Zones", group=displayGroup)
string labelPosition = input.string("Right", "Label Position", options=["Center", "Right"], group=displayGroup)
string fontSizeInput = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal", "Large"], group=displayGroup)
int fillTransparency = input.int(88, "Zone Transparency", minval=0, maxval=100, group=displayGroup)
int borderWidth = input.int(2, "Border Width", minval=1, maxval=5, group=displayGroup)
bool showMidpoint = input.bool(true, "Show 50% Midpoint", group=displayGroup)

string colorGroup = "5. Colors"
color tf1Demand = input.color(#00c853, "TF1 Demand", inline="c1", group=colorGroup)
color tf1Supply = input.color(#ff1744, "TF1 Supply", inline="c1", group=colorGroup)
color tf2Demand = input.color(#00b0ff, "TF2 Demand", inline="c2", group=colorGroup)
color tf2Supply = input.color(#ff9100, "TF2 Supply", inline="c2", group=colorGroup)
color tf3Demand = input.color(#7c4dff, "TF3 Demand", inline="c3", group=colorGroup)
color tf3Supply = input.color(#e040fb, "TF3 Supply", inline="c3", group=colorGroup)

string alertGroup = "6. Alerts"
bool enableAlerts = input.bool(true, "Enable Alerts", group=alertGroup)
bool alertNewZones = input.bool(true, "Alert On New Zone", group=alertGroup)
bool alertRetests = input.bool(true, "Alert On Retest", group=alertGroup)
bool alertBreaks = input.bool(true, "Alert On Break", group=alertGroup)
bool ultraSensitive = input.bool(true, "Ultra-Sensitive Wick Alerts", group=alertGroup)
bool confirmBreakOnClose = input.bool(false, "Confirm Break On Candle Close", group=alertGroup)
float touchToleranceATR = input.float(0.00, "Touch Tolerance × Chart ATR", minval=0.0, maxval=0.5, step=0.01, group=alertGroup)
float breakBufferATR = input.float(0.00, "Break Buffer × Chart ATR", minval=0.0, maxval=0.5, step=0.01, group=alertGroup)

//=============================================================================
// TYPES + HELPERS
//=============================================================================
type Zone
    float top
    float bottom
    int origin
    int slot
    bool demand
    bool broken
    bool wasInside
    color baseColor
    box bx
    line mid

f_text_size(string s) =>
    switch s
        "Tiny" => size.tiny
        "Normal" => size.normal
        "Large" => size.large
        => size.small

f_tf_label(string tf) =>
    float sec = timeframe.in_seconds(tf)
    sec < 3600 ? str.tostring(int(sec / 60)) + "M" :
     sec < 86400 ? str.tostring(int(sec / 3600)) + "H" :
     str.tostring(int(sec / 86400)) + "D"

f_slot_tf(int slot) => slot == 1 ? tf1 : slot == 2 ? tf2 : tf3
f_enabled(int slot) => slot == 1 ? showTF1 : slot == 2 ? showTF2 : showTF3
f_color(int slot, bool demand) =>
    slot == 1 ? (demand ? tf1Demand : tf1Supply) :
     slot == 2 ? (demand ? tf2Demand : tf2Supply) :
     (demand ? tf3Demand : tf3Supply)

f_zone_text(Zone z) => f_tf_label(f_slot_tf(z.slot)) + (z.demand ? " Demand" : " Supply")

f_engine() =>
    float atr = ta.atr(14)
    float pl = ta.pivotlow(low, pivotLength, pivotLength)
    float ph = ta.pivothigh(high, pivotLength, pivotLength)

    var float dTop = na
    var float dBottom = na
    var int dTime = na
    var int dSeq = 0

    var float sTop = na
    var float sBottom = na
    var int sTime = na
    var int sSeq = 0

    if not na(pl)
        float impulse = ta.highest(high, pivotLength) - pl
        if not requireImpulse or impulse >= atr[pivotLength] * impulseATR
            int origin = pivotLength
            for i = pivotLength to pivotLength + originSearch
                if close[i] < open[i]
                    origin := i
                    break

            float bodyTop = math.max(open[origin], close[origin])
            float bodyBottom = math.min(open[origin], close[origin])
            float rawTop = rangeMode == "Body" ? bodyTop : rangeMode == "Body + Wick" ? bodyTop : high[origin]
            float rawBottom = rangeMode == "Body" ? bodyBottom : low[origin]
            float mid = math.avg(rawTop, rawBottom)
            float half = math.min((rawTop - rawBottom) / 2.0, atr[origin] * maxZoneATR / 2.0)

            dTop := mid + half
            dBottom := mid - half
            dTime := time[origin]
            dSeq += 1

    if not na(ph)
        float impulse = ph - ta.lowest(low, pivotLength)
        if not requireImpulse or impulse >= atr[pivotLength] * impulseATR
            int origin = pivotLength
            for i = pivotLength to pivotLength + originSearch
                if close[i] > open[i]
                    origin := i
                    break

            float bodyTop = math.max(open[origin], close[origin])
            float bodyBottom = math.min(open[origin], close[origin])
            float rawTop = rangeMode == "Body" ? bodyTop : high[origin]
            float rawBottom = rangeMode == "Body" ? bodyBottom : rangeMode == "Body + Wick" ? bodyBottom : low[origin]
            float mid = math.avg(rawTop, rawBottom)
            float half = math.min((rawTop - rawBottom) / 2.0, atr[origin] * maxZoneATR / 2.0)

            sTop := mid + half
            sBottom := mid - half
            sTime := time[origin]
            sSeq += 1

    [dTop, dBottom, dTime, dSeq, sTop, sBottom, sTime, sSeq]

[dTop1, dBottom1, dTime1, dSeq1, sTop1, sBottom1, sTime1, sSeq1] = request.security(syminfo.tickerid, tf1, f_engine(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[dTop2, dBottom2, dTime2, dSeq2, sTop2, sBottom2, sTime2, sSeq2] = request.security(syminfo.tickerid, tf2, f_engine(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[dTop3, dBottom3, dTime3, dSeq3, sTop3, sBottom3, sTime3, sSeq3] = request.security(syminfo.tickerid, tf3, f_engine(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

var array<Zone> zones = array.new<Zone>()
var int seenD1 = 0
var int seenS1 = 0
var int seenD2 = 0
var int seenS2 = 0
var int seenD3 = 0
var int seenS3 = 0

f_delete(Zone z) =>
    if not na(z.bx)
        box.delete(z.bx)
    if not na(z.mid)
        line.delete(z.mid)
    true

f_count(int slot, bool demand) =>
    int n = 0
    if zones.size() > 0
        for i = 0 to zones.size() - 1
            Zone z = zones.get(i)
            if z.slot == slot and z.demand == demand
                n += 1
    n

f_trim(int slot, bool demand) =>
    while f_count(slot, demand) > maxZones
        int idx = -1
        for i = 0 to zones.size() - 1
            Zone z = zones.get(i)
            if idx == -1 and z.slot == slot and z.demand == demand
                idx := i
        if idx >= 0
            Zone old = zones.remove(idx)
            f_delete(old)
        else
            break
    true

f_add(float top, float bottom, int origin, int slot, bool demand) =>
    if f_enabled(slot) and not na(top) and not na(bottom) and not na(origin) and top > bottom
        bool dup = false
        if zones.size() > 0
            for i = 0 to zones.size() - 1
                Zone z = zones.get(i)
                if z.slot == slot and z.demand == demand and z.origin == origin
                    dup := true
        if not dup
            zones.push(Zone.new(top, bottom, origin, slot, demand, false, false, f_color(slot, demand), na, na))
            f_trim(slot, demand)
    true

bool newDemand = false
bool newSupply = false

if showTF1 and dSeq1 > seenD1
    f_add(dTop1, dBottom1, dTime1, 1, true)
    seenD1 := dSeq1
    newDemand := true
if showTF1 and sSeq1 > seenS1
    f_add(sTop1, sBottom1, sTime1, 1, false)
    seenS1 := sSeq1
    newSupply := true

if showTF2 and dSeq2 > seenD2
    f_add(dTop2, dBottom2, dTime2, 2, true)
    seenD2 := dSeq2
    newDemand := true
if showTF2 and sSeq2 > seenS2
    f_add(sTop2, sBottom2, sTime2, 2, false)
    seenS2 := sSeq2
    newSupply := true

if showTF3 and dSeq3 > seenD3
    f_add(dTop3, dBottom3, dTime3, 3, true)
    seenD3 := dSeq3
    newDemand := true
if showTF3 and sSeq3 > seenS3
    f_add(sTop3, sBottom3, sTime3, 3, false)
    seenS3 := sSeq3
    newSupply := true

//=============================================================================
// DRAW + EVENTS
//=============================================================================
int chartBarMs = int(math.max(timeframe.in_seconds(timeframe.period), 1) * 1000)
int rightTime = time + chartBarMs * extendBars
float chartATR = ta.atr(14)
float tolerance = chartATR * touchToleranceATR
float breakBuffer = chartATR * breakBufferATR

bool demandRetest = false
bool supplyRetest = false
bool demandBreak = false
bool supplyBreak = false

if zones.size() > 0
    for i = zones.size() - 1 to 0
        Zone z = zones.get(i)

        if not z.broken
            if na(z.bx)
                z.bx := box.new(z.origin, z.top, rightTime, z.bottom, xloc=xloc.bar_time, extend=extend.none,
                     bgcolor=color.new(z.baseColor, fillTransparency), border_color=z.baseColor, border_width=borderWidth,
                     text=showLabels ? f_zone_text(z) : "", text_color=z.baseColor, text_size=f_text_size(fontSizeInput),
                     text_halign=labelPosition == "Right" ? text.align_right : text.align_center, text_valign=text.align_center)
            else
                box.set_right(z.bx, rightTime)
                box.set_top(z.bx, z.top)
                box.set_bottom(z.bx, z.bottom)
                box.set_bgcolor(z.bx, color.new(z.baseColor, fillTransparency))
                box.set_border_color(z.bx, z.baseColor)
                box.set_border_width(z.bx, borderWidth)
                box.set_text(z.bx, showLabels ? f_zone_text(z) : "")
                box.set_text_color(z.bx, z.baseColor)
                box.set_text_size(z.bx, f_text_size(fontSizeInput))
                box.set_text_halign(z.bx, labelPosition == "Right" ? text.align_right : text.align_center)

            if showMidpoint
                float mid = math.avg(z.top, z.bottom)
                if na(z.mid)
                    z.mid := line.new(z.origin, mid, rightTime, mid, xloc=xloc.bar_time, extend=extend.none, color=z.baseColor, style=line.style_dashed, width=1)
                else
                    line.set_xy1(z.mid, z.origin, mid)
                    line.set_xy2(z.mid, rightTime, mid)
                    line.set_color(z.mid, z.baseColor)
            else if not na(z.mid)
                line.delete(z.mid)
                z.mid := na

            bool inside = high >= z.bottom - tolerance and low <= z.top + tolerance
            bool freshEntry = inside and not z.wasInside

            bool wickBreak = z.demand
                 ? low < z.bottom - breakBuffer and low[1] >= z.bottom - breakBuffer
                 : high > z.top + breakBuffer and high[1] <= z.top + breakBuffer

            bool closeBreak = z.demand
                 ? close < z.bottom - breakBuffer and close[1] >= z.bottom - breakBuffer
                 : close > z.top + breakBuffer and close[1] <= z.top + breakBuffer

            bool brokenNow = confirmBreakOnClose ? closeBreak and barstate.isconfirmed : wickBreak

            if ultraSensitive and freshEntry
                if z.demand
                    demandRetest := true
                else
                    supplyRetest := true

            z.wasInside := inside

            if brokenNow
                if z.demand
                    demandBreak := true
                else
                    supplyBreak := true

                z.broken := true

                if brokenStyle == "Hide"
                    f_delete(z)
                    zones.remove(i)
                else
                    box.set_right(z.bx, time)
                    if not na(z.mid)
                        line.set_x2(z.mid, time)

                    if brokenStyle == "Freeze Gray"
                        box.set_bgcolor(z.bx, color.new(color.gray, 92))
                        box.set_border_color(z.bx, color.gray)
                        box.set_text_color(z.bx, color.gray)
                        if not na(z.mid)
                            line.set_color(z.mid, color.gray)

//=============================================================================
// ALERTS
//=============================================================================
bool anyNew = newDemand or newSupply
bool anyRetest = demandRetest or supplyRetest
bool anyBreak = demandBreak or supplyBreak

alertcondition(enableAlerts and alertNewZones and newDemand, "New MTF Demand Zone", "{{ticker}} {{interval}}: New MTF demand zone.")
alertcondition(enableAlerts and alertNewZones and newSupply, "New MTF Supply Zone", "{{ticker}} {{interval}}: New MTF supply zone.")
alertcondition(enableAlerts and alertRetests and demandRetest, "MTF Demand Retest", "{{ticker}} {{interval}}: Wick entered an active demand zone.")
alertcondition(enableAlerts and alertRetests and supplyRetest, "MTF Supply Retest", "{{ticker}} {{interval}}: Wick entered an active supply zone.")
alertcondition(enableAlerts and alertBreaks and demandBreak, "MTF Demand Break", "{{ticker}} {{interval}}: Price crossed below an active demand zone.")
alertcondition(enableAlerts and alertBreaks and supplyBreak, "MTF Supply Break", "{{ticker}} {{interval}}: Price crossed above an active supply zone.")
alertcondition(enableAlerts and ((alertNewZones and anyNew) or (alertRetests and anyRetest) or (alertBreaks and anyBreak)),
     "ALL MTF Supply / Demand Events", "{{ticker}} {{interval}}: New, retested, or broken MTF supply/demand zone.")

if enableAlerts and ((alertNewZones and anyNew) or (alertRetests and anyRetest) or (alertBreaks and anyBreak))
    string msg = syminfo.ticker + " | " + timeframe.period + " | "
    if alertNewZones and newDemand
        msg += "New demand; "
    if alertNewZones and newSupply
        msg += "New supply; "
    if alertRetests and demandRetest
        msg += "Demand retest; "
    if alertRetests and supplyRetest
        msg += "Supply retest; "
    if alertBreaks and demandBreak
        msg += "Demand break; "
    if alertBreaks and supplyBreak
        msg += "Supply break; "
    alert(msg, ultraSensitive and not confirmBreakOnClose ? alert.freq_once_per_bar : alert.freq_once_per_bar_close)
````

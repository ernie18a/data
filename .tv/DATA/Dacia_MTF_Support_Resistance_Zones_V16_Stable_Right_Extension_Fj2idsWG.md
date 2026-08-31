<!-- tradingview-pine-id: PUB;d8f1490c7e2c4b399aaf8a89c2a5180a -->
<!-- tradingviewscripts-format: 1 -->
# Dacia MTF Support + Resistance Zones V1.6 Stable Right Extension

Source: https://www.tradingview.com/script/Fj2idsWG-Dacia-MTF-Support-Resistance-Zones-V1-2-Fixed/

## Description

Dacia MTF Support + Resistance Zones V1.2 Fixed
Dacia MTF Support + Resistance Zones V1.2 Fixed
Dacia MTF Support + Resistance Zones V1.2 Fixed
Dacia MTF Support + Resistance Zones V1.2 Fixed

---

## Source Code

````pine
//@version=6
indicator(
     "Dacia MTF Support + Resistance Zones V1.6 Stable Right Extension",
     shorttitle="Dacia MTF S/R V1.6",
     overlay=true,
     max_boxes_count=200,
     max_lines_count=200,
     max_labels_count=200)

//=============================================================================
// 1. TIMEFRAMES
//=============================================================================
string tfGroup = "1. Timeframes"

string tf1 = input.timeframe("15", "Timeframe 1", group=tfGroup)
string tf2 = input.timeframe("60", "Timeframe 2", group=tfGroup)
string tf3 = input.timeframe("240", "Timeframe 3", group=tfGroup)

bool showTF1 = input.bool(true, "Show Timeframe 1", group=tfGroup)
bool showTF2 = input.bool(true, "Show Timeframe 2", group=tfGroup)
bool showTF3 = input.bool(true, "Show Timeframe 3", group=tfGroup)

//=============================================================================
// 2. DETECTION
//=============================================================================
string detectGroup = "2. Detection"

int pivotLength = input.int(
     15,
     "Pivot Length",
     minval=3,
     maxval=50,
     group=detectGroup)

float zoneATR = input.float(
     0.35,
     "Zone Thickness × ATR",
     minval=0.05,
     maxval=3.00,
     step=0.05,
     group=detectGroup)

string invalidationMode = input.string(
     "Close",
     "Invalidation",
     options=["Close", "Wick"],
     group=detectGroup)

bool avoidFalseBreaks = input.bool(
     true,
     "Require Volume For Break",
     group=detectGroup)

float breakVolumeMultiplier = input.float(
     1.00,
     "Break Volume Multiplier",
     minval=0.10,
     maxval=5.00,
     step=0.10,
     group=detectGroup)

int volumeLength = input.int(
     20,
     "Volume Average Length",
     minval=1,
     group=detectGroup)

//=============================================================================
// 3. ZONE MANAGEMENT
//=============================================================================
string zoneGroup = "3. Zone Management"

int maxZonesPerTF = input.int(
     2,
     "Maximum Zones Per Timeframe",
     minval=1,
     maxval=5,
     group=zoneGroup)

string extensionMode = input.string(
     "Stable Chart Bars",
     "Zone Extension",
     options=["Stable Chart Bars", "Fixed TF Bars"],
     tooltip="Stable Chart Bars gives every timeframe the same finite right projection and avoids extend.right redraw glitches.",
     group=zoneGroup)

int stableExtensionBars = input.int(
     100,
     "Stable Extend Right (Chart Bars)",
     minval=10,
     maxval=500,
     tooltip="Used by 15M, 1H, and 4H zones equally. On a 5-minute chart, 100 bars projects about 8 hours 20 minutes.",
     group=zoneGroup)

int tf1ExtensionBars = input.int(
     16,
     "TF1 Length (TF Bars)",
     minval=1,
     maxval=200,
     group=zoneGroup)

int tf2ExtensionBars = input.int(
     12,
     "TF2 Length (TF Bars)",
     minval=1,
     maxval=200,
     group=zoneGroup)

int tf3ExtensionBars = input.int(
     8,
     "TF3 Length (TF Bars)",
     minval=1,
     maxval=200,
     group=zoneGroup)

bool showInvalidated = input.bool(
     false,
     "Keep Broken Zones",
     group=zoneGroup)

bool fadeRetested = input.bool(
     true,
     "Fade After First Retest",
     group=zoneGroup)

int retestedTransparency = input.int(
     92,
     "Retested Transparency",
     minval=70,
     maxval=100,
     group=zoneGroup)

bool showRetestCount = input.bool(
     true,
     "Show Retest Count",
     group=zoneGroup)

//=============================================================================
// 4. DISPLAY
//=============================================================================
string displayGroup = "4. Display"

bool showLabelsInside = input.bool(
     true,
     "Show Labels Inside Zones",
     group=displayGroup)

string labelHorizontal = input.string(
     "Right",
     "Label Horizontal Position",
     options=["Left", "Center", "Right"],
     group=displayGroup)

string labelVertical = input.string(
     "Center",
     "Label Vertical Position",
     options=["Top", "Center", "Bottom"],
     group=displayGroup)

string textSizeInput = input.string(
     "Small",
     "Label Size",
     options=["Tiny", "Small", "Normal"],
     group=displayGroup)

int freshTransparency = input.int(
     82,
     "Fresh Zone Transparency",
     minval=0,
     maxval=100,
     group=displayGroup)

int borderWidth = input.int(
     1,
     "Border Width",
     minval=1,
     maxval=4,
     group=displayGroup)

float minimumZoneHeightATR = input.float(
     0.08,
     "Minimum Zone Height × ATR",
     minval=0.01,
     maxval=0.50,
     step=0.01,
     tooltip="Prevents higher-timeframe zones from collapsing into a single line.",
     group=displayGroup)

bool waitForConfirmedHTFZone = input.bool(
     true,
     "Wait For Confirmed HTF Zone",
     tooltip="Prevents temporary 4H zones from appearing and disappearing while the higher-timeframe candle is still forming.",
     group=displayGroup)

//=============================================================================
// 5. COLORS
//=============================================================================
string colorGroup = "5. Colors"

color tf1SupportColor = input.color(#00c853, "TF1 Support", group=colorGroup)
color tf1ResistanceColor = input.color(#ff1744, "TF1 Resistance", group=colorGroup)

color tf2SupportColor = input.color(#00b0ff, "TF2 Support", group=colorGroup)
color tf2ResistanceColor = input.color(#ff9100, "TF2 Resistance", group=colorGroup)

color tf3SupportColor = input.color(#7c4dff, "TF3 Support", group=colorGroup)
color tf3ResistanceColor = input.color(#e040fb, "TF3 Resistance", group=colorGroup)

color brokenColor = input.color(color.gray, "Broken Zone", group=colorGroup)

//=============================================================================
// 6. ALERTS
//=============================================================================
string alertGroup = "6. Alerts"

bool enableAlerts = input.bool(true, "Enable Alerts", group=alertGroup)
bool alertNewZone = input.bool(true, "Alert On New Zone", group=alertGroup)
bool alertRetest = input.bool(true, "Alert On Retest", group=alertGroup)
bool alertBreak = input.bool(true, "Alert On Break", group=alertGroup)

bool ultraSensitiveAlerts = input.bool(
     true,
     "Ultra-Sensitive Wick Alerts",
     tooltip="Alerts immediately when any wick touches a zone border or crosses through it. Does not wait for the candle to close.",
     group=alertGroup)

bool alertEveryNewTouch = input.bool(
     true,
     "Alert Every New Zone Entry",
     tooltip="Alerts once when price enters a zone, then resets after price leaves it.",
     group=alertGroup)

//=============================================================================
// HELPERS
//=============================================================================
f_text_size(string value) =>
    switch value
        "Tiny" => size.tiny
        "Normal" => size.normal
        => size.small

f_halign(string value) =>
    switch value
        "Left" => text.align_left
        "Right" => text.align_right
        => text.align_center

f_valign(string value) =>
    switch value
        "Top" => text.align_top
        "Bottom" => text.align_bottom
        => text.align_center

f_tf_label(string tf) =>
    float seconds = timeframe.in_seconds(tf)

    if seconds < 3600
        str.tostring(int(seconds / 60)) + "m"
    else if seconds < 86400
        str.tostring(int(seconds / 3600)) + "H"
    else
        str.tostring(int(seconds / 86400)) + "D"

f_expiry_time(int startTime, string tf, int bars) =>
    startTime + int(timeframe.in_seconds(tf) * 1000) * bars

//=============================================================================
// HTF ENGINE
//=============================================================================
f_engine() =>
    float atr = ta.atr(14)
    float avgVolume = ta.sma(volume, volumeLength)

    float ph = ta.pivothigh(high, pivotLength, pivotLength)
    float pl = ta.pivotlow(low, pivotLength, pivotLength)

    var float resistance = na
    var float support = na
    var int resistanceTime = na
    var int supportTime = na
    var bool resistanceBroken = false
    var bool supportBroken = false

    bool newResistance = false
    bool newSupport = false
    bool resistanceRetest = false
    bool supportRetest = false
    bool resistanceBreak = false
    bool supportBreak = false

    if not na(ph)
        resistance := ph
        resistanceTime := time[pivotLength]
        resistanceBroken := false
        newResistance := true

    if not na(pl)
        support := pl
        supportTime := time[pivotLength]
        supportBroken := false
        newSupport := true

    float breakHigh = invalidationMode == "Wick" ? high : close
    float breakLow = invalidationMode == "Wick" ? low : close

    bool volumeOK = not avoidFalseBreaks or volume >= avgVolume * breakVolumeMultiplier

    if not na(resistance) and not resistanceBroken
        resistanceRetest :=
             high >= resistance - atr * zoneATR and
             close <= resistance

        if breakHigh > resistance + atr * zoneATR and volumeOK
            resistanceBroken := true
            resistanceBreak := true

    if not na(support) and not supportBroken
        supportRetest :=
             low <= support + atr * zoneATR and
             close >= support

        if breakLow < support - atr * zoneATR and volumeOK
            supportBroken := true
            supportBreak := true

    bool htfConfirmed = barstate.isconfirmed
    [resistance, resistanceTime, resistanceBroken, support, supportTime, supportBroken, newResistance, newSupport, resistanceRetest, supportRetest, resistanceBreak, supportBreak, atr, htfConfirmed]

//=============================================================================
// MTF DATA
//=============================================================================
[r1, rt1, rb1, s1, st1, sb1, nr1, ns1, rr1, sr1, br1, bs1, atr1, confirmed1] = request.security(syminfo.tickerid, tf1, f_engine(), lookahead=barmerge.lookahead_off)

[r2, rt2, rb2, s2, st2, sb2, nr2, ns2, rr2, sr2, br2, bs2, atr2, confirmed2] = request.security(syminfo.tickerid, tf2, f_engine(), lookahead=barmerge.lookahead_off)

[r3, rt3, rb3, s3, st3, sb3, nr3, ns3, rr3, sr3, br3, bs3, atr3, confirmed3] = request.security(syminfo.tickerid, tf3, f_engine(), lookahead=barmerge.lookahead_off)

//=============================================================================
// ZONE ARRAYS
//=============================================================================
var array<box> zoneBoxes = array.new_box()
var array<string> zoneKeys = array.new_string()
var array<int> zoneRetests = array.new_int()
var array<bool> zoneInside = array.new_bool()
var array<color> zoneColors = array.new_color()
var array<string> zoneLabels = array.new_string()
var array<int> zoneExpiry = array.new_int()
var array<bool> zoneBroken = array.new_bool()

f_find_key(string key) =>
    int result = -1

    if array.size(zoneKeys) > 0
        for i = 0 to array.size(zoneKeys) - 1
            if array.get(zoneKeys, i) == key
                result := i

    result

f_delete_index(int index) =>
    box oldBox = array.remove(zoneBoxes, index)
    box.delete(oldBox)

    array.remove(zoneKeys, index)
    array.remove(zoneRetests, index)
    array.remove(zoneInside, index)
    array.remove(zoneColors, index)
    array.remove(zoneLabels, index)
    array.remove(zoneExpiry, index)
    array.remove(zoneBroken, index)

f_trim_tf(string tfName) =>
    int count = 0

    if array.size(zoneKeys) > 0
        for i = 0 to array.size(zoneKeys) - 1
            if str.startswith(array.get(zoneKeys, i), tfName + "|")
                count += 1

    while count > maxZonesPerTF * 2
        int removeIndex = -1

        for i = array.size(zoneKeys) - 1 to 0
            if removeIndex == -1 and str.startswith(array.get(zoneKeys, i), tfName + "|")
                removeIndex := i

        if removeIndex >= 0
            f_delete_index(removeIndex)
            count -= 1
        else
            count := maxZonesPerTF * 2

f_add_or_update(
     string key,
     string labelText,
     bool enabled,
     int startTime,
     float price,
     float atrValue,
     bool broken,
     color zoneColor,
     string sourceTF,
     int extensionBars,
     bool resistanceZone,
     bool sourceConfirmed) =>

    int index = f_find_key(key)
    bool valid =
         enabled and
         not na(startTime) and
         not na(price) and
         not na(atrValue) and
         atrValue > 0 and
         (not waitForConfirmedHTFZone or sourceConfirmed)
    bool updated = false

    if valid
        float requestedHalfHeight = atrValue * zoneATR
        float minimumHalfHeight = atrValue * minimumZoneHeightATR * 0.5
        float halfHeight = math.max(requestedHalfHeight, minimumHalfHeight)

        float top = price + halfHeight
        float bottom = price - halfHeight

        int expiry = f_expiry_time(startTime, sourceTF, extensionBars)
        int chartBarMs = int(math.max(timeframe.in_seconds(timeframe.period), 1) * 1000)
        int stableRightTime = time + chartBarMs * stableExtensionBars
        int rightTime = extensionMode == "Stable Chart Bars"
             ? stableRightTime
             : math.min(stableRightTime, expiry)

        if index == -1
            color displayColor = broken ? brokenColor : zoneColor

            box bx = box.new(
                 left=startTime,
                 top=top,
                 right=rightTime,
                 bottom=bottom,
                 xloc=xloc.bar_time,
                 extend=extend.none,
                 bgcolor=color.new(displayColor, freshTransparency),
                 border_color=displayColor,
                 border_width=borderWidth,
                 text=showLabelsInside ? labelText : "",
                 text_color=displayColor,
                 text_size=f_text_size(textSizeInput),
                 text_halign=text.align_right,
                 text_valign=f_valign(labelVertical))

            array.unshift(zoneBoxes, bx)
            array.unshift(zoneKeys, key)
            array.unshift(zoneRetests, 0)
            array.unshift(zoneInside, false)
            array.unshift(zoneColors, zoneColor)
            array.unshift(zoneLabels, labelText)
            array.unshift(zoneExpiry, expiry)
            array.unshift(zoneBroken, broken)
            updated := true
        else
            box bx = array.get(zoneBoxes, index)
            int touches = array.get(zoneRetests, index)
            bool storedBroken = broken or array.get(zoneBroken, index)

            array.set(zoneBroken, index, storedBroken)

            color baseColor = array.get(zoneColors, index)
            color displayColor = storedBroken ? brokenColor : baseColor

            int transparency =
                 touches > 0 and fadeRetested
                 ? retestedTransparency
                 : freshTransparency

            string displayText = array.get(zoneLabels, index)

            if showRetestCount and touches > 0
                displayText += " • " + str.tostring(touches) + "x"

            box.set_left(bx, startTime)
            box.set_top(bx, top)
            box.set_bottom(bx, bottom)
            box.set_bgcolor(bx, color.new(displayColor, transparency))
            box.set_border_color(bx, displayColor)
            box.set_border_width(bx, borderWidth)
            box.set_text(bx, showLabelsInside ? displayText : "")
            box.set_text_color(bx, displayColor)
            box.set_text_size(bx, f_text_size(textSizeInput))
            box.set_text_halign(bx, text.align_right)
            box.set_text_valign(bx, f_valign(labelVertical))

            box.set_extend(bx, extend.none)

            if storedBroken
                // Freeze a broken zone exactly where the break occurred.
                box.set_right(bx, time)
            else
                int chartBarMs = int(math.max(timeframe.in_seconds(timeframe.period), 1) * 1000)
                int stableRightTime = time + chartBarMs * stableExtensionBars
                int fixedRightTime = math.min(stableRightTime, array.get(zoneExpiry, index))
                box.set_right(
                     bx,
                     extensionMode == "Stable Chart Bars"
                          ? stableRightTime
                          : fixedRightTime)

            if storedBroken and not showInvalidated
                f_delete_index(index)

            updated := true

    updated

f_count_retest(
     string key,
     bool event) =>

    int index = f_find_key(key)

    if index >= 0
        bool wasInside = array.get(zoneInside, index)
        bool insideNow = event
        bool newRetest = insideNow and not wasInside

        array.set(zoneInside, index, insideNow)

        if newRetest
            int touches = array.get(zoneRetests, index) + 1
            array.set(zoneRetests, index, touches)

//=============================================================================
// DRAW ZONES
//=============================================================================
string tf1Label = f_tf_label(tf1)
string tf2Label = f_tf_label(tf2)
string tf3Label = f_tf_label(tf3)

f_add_or_update(tf1 + "|R", tf1Label + " Resistance", showTF1, rt1, r1, atr1, rb1, tf1ResistanceColor, tf1, tf1ExtensionBars, true, confirmed1)
f_add_or_update(tf1 + "|S", tf1Label + " Support", showTF1, st1, s1, atr1, sb1, tf1SupportColor, tf1, tf1ExtensionBars, false, confirmed1)

f_add_or_update(tf2 + "|R", tf2Label + " Resistance", showTF2, rt2, r2, atr2, rb2, tf2ResistanceColor, tf2, tf2ExtensionBars, true, confirmed2)
f_add_or_update(tf2 + "|S", tf2Label + " Support", showTF2, st2, s2, atr2, sb2, tf2SupportColor, tf2, tf2ExtensionBars, false, confirmed2)

f_add_or_update(tf3 + "|R", tf3Label + " Resistance", showTF3, rt3, r3, atr3, rb3, tf3ResistanceColor, tf3, tf3ExtensionBars, true, confirmed3)
f_add_or_update(tf3 + "|S", tf3Label + " Support", showTF3, st3, s3, atr3, sb3, tf3SupportColor, tf3, tf3ExtensionBars, false, confirmed3)

//=============================================================================
// ULTRA-SENSITIVE CHART-TIMEFRAME TOUCH / BREAK ENGINE
// Uses the visible zone borders directly, so it does not wait for the HTF bar.
//=============================================================================
f_zone_events(float price, float atrValue, bool resistanceZone) =>
    float requestedHalfHeight = atrValue * zoneATR
    float minimumHalfHeight = atrValue * minimumZoneHeightATR * 0.5
    float halfHeight = math.max(requestedHalfHeight, minimumHalfHeight)

    float top = price + halfHeight
    float bottom = price - halfHeight

    bool valid = not na(price) and not na(atrValue)
    bool insideNow = valid and high >= bottom and low <= top

    // A retest is a fresh entry into the active zone.
    bool freshTouch = insideNow and not insideNow[1]

    // A break is an immediate wick crossing beyond the far zone border.
    bool wickBreak = valid and (
         resistanceZone
              ? high > top and high[1] <= top
              : low < bottom and low[1] >= bottom)

    [freshTouch, wickBreak]

[tf1ResistanceTouchFast, tf1ResistanceBreakFast] = f_zone_events(r1, atr1, true)
[tf1SupportTouchFast, tf1SupportBreakFast] = f_zone_events(s1, atr1, false)

[tf2ResistanceTouchFast, tf2ResistanceBreakFast] = f_zone_events(r2, atr2, true)
[tf2SupportTouchFast, tf2SupportBreakFast] = f_zone_events(s2, atr2, false)

[tf3ResistanceTouchFast, tf3ResistanceBreakFast] = f_zone_events(r3, atr3, true)
[tf3SupportTouchFast, tf3SupportBreakFast] = f_zone_events(s3, atr3, false)

bool tf1ResistanceRetestEvent = ultraSensitiveAlerts ? tf1ResistanceTouchFast : rr1
bool tf1SupportRetestEvent = ultraSensitiveAlerts ? tf1SupportTouchFast : sr1
bool tf2ResistanceRetestEvent = ultraSensitiveAlerts ? tf2ResistanceTouchFast : rr2
bool tf2SupportRetestEvent = ultraSensitiveAlerts ? tf2SupportTouchFast : sr2
bool tf3ResistanceRetestEvent = ultraSensitiveAlerts ? tf3ResistanceTouchFast : rr3
bool tf3SupportRetestEvent = ultraSensitiveAlerts ? tf3SupportTouchFast : sr3

bool tf1ResistanceBreakEvent = ultraSensitiveAlerts ? tf1ResistanceBreakFast : br1
bool tf1SupportBreakEvent = ultraSensitiveAlerts ? tf1SupportBreakFast : bs1
bool tf2ResistanceBreakEvent = ultraSensitiveAlerts ? tf2ResistanceBreakFast : br2
bool tf2SupportBreakEvent = ultraSensitiveAlerts ? tf2SupportBreakFast : bs2
bool tf3ResistanceBreakEvent = ultraSensitiveAlerts ? tf3ResistanceBreakFast : br3
bool tf3SupportBreakEvent = ultraSensitiveAlerts ? tf3SupportBreakFast : bs3

f_count_retest(tf1 + "|R", tf1ResistanceRetestEvent)
f_count_retest(tf1 + "|S", tf1SupportRetestEvent)
f_count_retest(tf2 + "|R", tf2ResistanceRetestEvent)
f_count_retest(tf2 + "|S", tf2SupportRetestEvent)
f_count_retest(tf3 + "|R", tf3ResistanceRetestEvent)
f_count_retest(tf3 + "|S", tf3SupportRetestEvent)

f_trim_tf(tf1)
f_trim_tf(tf2)
f_trim_tf(tf3)

//=============================================================================
// ALERTS
//=============================================================================
bool anyNewZone =
     nr1 or ns1 or
     nr2 or ns2 or
     nr3 or ns3

bool anyRetest =
     tf1ResistanceRetestEvent or tf1SupportRetestEvent or
     tf2ResistanceRetestEvent or tf2SupportRetestEvent or
     tf3ResistanceRetestEvent or tf3SupportRetestEvent

bool anyBreak =
     tf1ResistanceBreakEvent or tf1SupportBreakEvent or
     tf2ResistanceBreakEvent or tf2SupportBreakEvent or
     tf3ResistanceBreakEvent or tf3SupportBreakEvent

alertcondition(
     enableAlerts and alertNewZone and anyNewZone,
     "New MTF Support / Resistance Zone",
     "{{ticker}} {{interval}}: New multi-timeframe support or resistance zone.")

alertcondition(
     enableAlerts and alertRetest and anyRetest,
     "MTF Support / Resistance Retest",
     "{{ticker}} {{interval}}: Price retested an active support or resistance zone.")

alertcondition(
     enableAlerts and alertBreak and anyBreak,
     "MTF Support / Resistance Break",
     "{{ticker}} {{interval}}: An active support or resistance zone was broken.")

alertcondition(enableAlerts and alertRetest and tf1SupportRetestEvent, "TF1 Support Ultra Touch", "{{ticker}} {{interval}}: Wick entered the TF1 support zone.")
alertcondition(enableAlerts and alertRetest and tf1ResistanceRetestEvent, "TF1 Resistance Ultra Touch", "{{ticker}} {{interval}}: Wick entered the TF1 resistance zone.")
alertcondition(enableAlerts and alertRetest and tf2SupportRetestEvent, "TF2 Support Ultra Touch", "{{ticker}} {{interval}}: Wick entered the TF2 support zone.")
alertcondition(enableAlerts and alertRetest and tf2ResistanceRetestEvent, "TF2 Resistance Ultra Touch", "{{ticker}} {{interval}}: Wick entered the TF2 resistance zone.")
alertcondition(enableAlerts and alertRetest and tf3SupportRetestEvent, "TF3 Support Ultra Touch", "{{ticker}} {{interval}}: Wick entered the TF3 support zone.")
alertcondition(enableAlerts and alertRetest and tf3ResistanceRetestEvent, "TF3 Resistance Ultra Touch", "{{ticker}} {{interval}}: Wick entered the TF3 resistance zone.")

alertcondition(enableAlerts and alertBreak and tf1SupportBreakEvent, "TF1 Support Ultra Break", "{{ticker}} {{interval}}: Wick crossed below the TF1 support border.")
alertcondition(enableAlerts and alertBreak and tf1ResistanceBreakEvent, "TF1 Resistance Ultra Break", "{{ticker}} {{interval}}: Wick crossed above the TF1 resistance border.")
alertcondition(enableAlerts and alertBreak and tf2SupportBreakEvent, "TF2 Support Ultra Break", "{{ticker}} {{interval}}: Wick crossed below the TF2 support border.")
alertcondition(enableAlerts and alertBreak and tf2ResistanceBreakEvent, "TF2 Resistance Ultra Break", "{{ticker}} {{interval}}: Wick crossed above the TF2 resistance border.")
alertcondition(enableAlerts and alertBreak and tf3SupportBreakEvent, "TF3 Support Ultra Break", "{{ticker}} {{interval}}: Wick crossed below the TF3 support border.")
alertcondition(enableAlerts and alertBreak and tf3ResistanceBreakEvent, "TF3 Resistance Ultra Break", "{{ticker}} {{interval}}: Wick crossed above the TF3 resistance border.")

alertcondition(
     enableAlerts and
     ((alertNewZone and anyNewZone) or
      (alertRetest and anyRetest) or
      (alertBreak and anyBreak)),
     "ALL MTF Support / Resistance Events",
     "{{ticker}} {{interval}}: New, retested, or broken support/resistance zone.")

if enableAlerts and
   ((alertNewZone and anyNewZone) or
    (alertRetest and anyRetest) or
    (alertBreak and anyBreak))

    string message = syminfo.ticker + " | " + timeframe.period + " | "

    if alertNewZone and anyNewZone
        message += "New S/R zone; "

    if alertRetest and anyRetest
        message += "S/R retest; "

    if alertBreak and anyBreak
        message += "S/R break; "

    alert(message, ultraSensitiveAlerts ? alert.freq_once_per_bar : alert.freq_once_per_bar_close)
````

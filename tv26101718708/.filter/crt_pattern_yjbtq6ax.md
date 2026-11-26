# CRT Pattern

- url: https://www.tradingview.com/script/YjBTq6ax-crt-pattern/
- type: indicator
- pine_id: PUB;de18bb173a074b5ba1b84477fc385a99
- version: 2.0

## Description

CRT Pattern automatically detects and manages CRT (Candle Range Theory) setups on a user-selected higher timeframe, displaying all key structural elements while providing a comprehensive set of alerts for discretionary trading, automation, and Study-on-Study integrations.

The indicator automatically identifies:
 • Range Candle
 • Inside Candles
 • Sweep Candle
 • CRT confirmation
 • Discount Zone
 • All major structural levels (CRH, CRL, CRM, SH/SL, and Discount Border)

Once a pattern is confirmed, the indicator continues to track it until its target is reached or its structure becomes invalid.

[b]How the Indicator Works[/b]

The detection process begins by searching for a Range Candle.
A candle qualifies as a Range Candle only if both of the following conditions are met:
 • Its body represents at least the specified percentage of the candle's total range.
 • Its size exceeds the user-defined ATR threshold.

After a valid Range Candle is found, the indicator monitors one of three possible outcomes:
 • One or more Inside Candles are formed.
 • A Sweep Candle confirms the CRT pattern.
 • The potential setup is invalidated before confirmation.

Once the Sweep Candle closes, the CRT is considered confirmed, and all structural levels and zones are automatically plotted on the chart. From that point forward, the indicator does not recalculate the pattern. Instead, it simply manages the already established structure until the pattern is completed or invalidated.

[b]Pattern Components[/b]

Once a CRT is confirmed, the indicator displays every key element of its structure.

[b]Range Candle[/b]
The first candle of the pattern that defines the entire trading range. It is highlighted with a colored box:
 • Green for a bullish Range Candle.
 • Red for a bearish Range Candle.

The CRH, CRL, and CRM levels are all derived from this candle.

[b]Inside Candle[/b]
Candles whose entire range remains inside the Range Candle. These candles are displayed as gray boxes. There is no limit to the number of Inside Candles that may appear before the Sweep Candle.

[b]Sweep Candle[/b]
The candle that confirms the CRT pattern.

For a Long CRT, the Sweep Candle:
 • trades below the Range Candle's low;
 • closes back above CRL.

For a Short CRT, it:
 • trades above the Range Candle's high;
 • closes back below CRH.

A CRT is considered confirmed only after the Sweep Candle has closed.

Like the Range Candle, the Sweep Candle is highlighted according to its direction:
 • Green if it closes bullish.
 • Red if it closes bearish.

[b]CRH (Candle Range High)[/b]
The upper boundary of the Range Candle.
Displayed as a red dotted horizontal line.

[b]CRL (Candle Range Low)[/b]
The lower boundary of the Range Candle.
Displayed as a green dotted horizontal line.

[b]CRM (Candle Range Mid)[/b]
The midpoint of the Range Candle.
It is calculated as the midpoint between the candle's High and Low.
Displayed as a gray dotted horizontal line.

[b]SH / SL[/b]
The extreme price of the Sweep Candle.
 • SH (Sweep High) is used for Short CRTs.
 • SL (Sweep Low) is used for Long CRTs.
Displayed as the corresponding dotted horizontal line.

[b]Discount Border[/b]
The boundary of the Discount Zone.

Its position depends on the selected Discount Border setting and can be based on one of the following reference levels:
 • CRM
 • CRH/CRL
 • SH/SL
 • Sweep Open
 • Sweep Close

It is displayed as a yellow dotted horizontal line.

[b]Discount Zone[/b]
The area between the Sweep level and the selected Discount Border.
This zone represents the preferred area for evaluating potential entries after a CRT has been confirmed.
 • Green for Long CRTs.
 • Red for Short CRTs.

[b]Pattern Lifecycle[/b]

Once a CRT has been confirmed, the indicator continues tracking it until one of the following conditions occurs.

[b]1. Target Reached[/b]
 • A Long CRT is considered complete when price reaches CRH.
 • A Short CRT is considered complete when price reaches CRL.
Once the target has been reached, the pattern is no longer updated.

[b]2. Sweep Failure[/b]
 • A Long CRT becomes invalid if a candle on the selected higher timeframe closes below SL.
 • A Short CRT becomes invalid if a candle on the selected higher timeframe closes above SH.
Important: Sweep failure is confirmed only by the close of the selected higher timeframe candle. Intrabar breaks or wick penetrations do not invalidate the pattern.

[b]3. Completed Pattern Display[/b]
The behavior of completed patterns is controlled by the Show Only Active Patterns setting.
 • Enabled — completed or invalidated patterns are automatically removed from the chart.
 • Disabled — the pattern stops updating but remains on the chart as historical reference.

[b]Key Features[/b]

 • Designed to operate on a chart timeframe lower than the selected HTF.
 • The selected Range Candle timeframe must always be higher than the current chart timeframe.
 • All structural calculations are based exclusively on candles from the selected higher timeframe.
 • Multiple active CRT patterns can be tracked simultaneously.
 • Once confirmed, every structural level remains fixed for the lifetime of the pattern.
 • The indicator does not repaint confirmed patterns. After confirmation, only the graphical extensions (lines and zones) continue extending to the latest bar while the underlying structure remains unchanged.

[b]Alerts[/b]

The indicator provides a complete set of alerts for discretionary trading, automation, and custom workflows. 

All alerts can be used with:
 • Standard TradingView Alerts
 • Webhooks
 • Automated trading systems
 • Study-on-Study integrations
 • Custom indicators and strategies

[b]Pattern Alerts[/b]

[b]New CRT Pattern[/b]
Triggers whenever any new CRT (Long or Short) is confirmed.

[b]New CRT Long Pattern[/b]
Triggers only when a Long CRT is confirmed.

[b]New CRT Short Pattern[/b]
Triggers only when a Short CRT is confirmed.

[b]Discount Zone Alerts[/b]

[b]Discount Long[/b]
Active while the closing price remains inside the Long Discount Zone. Condition:
[pine]SL ≤ Close ≤ Discount Border[/pine]
This is a state-based alert rather than a one-time event. As long as the closing price remains inside the Long Discount Zone, the alert condition evaluates to true.

[b]Discount Short[/b]
Active while the closing price remains inside the Short Discount Zone. Condition:
[pine]Discount Border ≤ Close ≤ SH[/pine]
Like the Long version, this is a state-based alert rather than a single trigger.

[b]Structural Level Cross Alerts[/b]

The following alerts detect when the closing price crosses one of the CRT structural levels.
Each alert is evaluated using bar closes only.

[b]CRL Up Cross[/b]
Triggers when the closing price crosses CRL from below.

[b]CRL Down Cross[/b]
Triggers when the closing price crosses CRL from above.

[b]CRH Up Cross[/b]
Triggers when the closing price crosses CRH from below.

[b]CRH Down Cross[/b]
Triggers when the closing price crosses CRH from above.

[b]CRM Up Cross[/b]
Triggers when the closing price crosses CRM from below.

[b]CRM Down Cross[/b]
Triggers when the closing price crosses CRM from above.

[b]SH/SL Up Cross[/b]
Triggers when the closing price crosses the Sweep level from below.
 • SL is used for Long CRTs.
 • SH is used for Short CRTs.

[b]SH/SL Down Cross[/b]
Triggers when the closing price crosses the Sweep level from above.
 • SL is used for Long CRTs.
 • SH is used for Short CRTs.

[b]Discount Border Up Cross[/b]
Triggers when the closing price crosses the selected Discount Border from below.

The actual level depends on the Discount Border setting:
 • CRM
 • CRH / CRL
 • SH / SL
 • Sweep Open
 • Sweep Close

[b]Discount Border Down Cross[/b]
Triggers when the closing price crosses the selected Discount Border from above.
The reference level depends on the current Discount Border configuration.

[b]Important Notes About Cross Alerts[/b]

All crossing alerts are calculated using the closing price only. If price temporarily breaks a level with its wick but closes on the same side of that level, no crossing alert will be generated. This behavior intentionally filters out intrabar noise and provides consistent, non-ambiguous signals for discretionary trading and automated systems.

[b]Study-on-Study Compatibility[/b]

Every alert condition exposed by the indicator can also be used through TradingView's Study-on-Study functionality. This allows CRT Pattern to serve as a structural filter for other indicators and strategies.

Typical use cases include:
 • allowing entries only while price is inside a Discount Zone;
 • confirming entries after crossing CRH, CRL, CRM, SH/SL, or the selected Discount Border;
 • filtering signals based on the presence of an active Long or Short CRT;
 • combining CRT structure with proprietary entry or exit logic.

Since all structural levels become fixed once a pattern is confirmed, Study-on-Study integrations receive stable, non-repainting signals throughout the lifetime of the pattern.

[b]Settings[/b]

[b]Range Settings[/b]

[b]Timeframe[/b]
Specifies the higher timeframe (HTF) used for CRT detection. The selected timeframe must be higher than the current chart timeframe. All pattern detection and structural calculations are performed using candles from this timeframe.

[b]Body Min. %[/b]
Defines the minimum percentage of the candle's body relative to its total range for a candle to qualify as a Range Candle. Higher values restrict detection to stronger, more impulsive candles, while lower values allow a broader range of setups.

[b]Candle Min. Size[/b]
Defines the minimum size of a Range Candle expressed in ATR multiples. This filter helps eliminate insignificant or low-volatility ranges. Increasing the value results in fewer but generally stronger setups.

[b]Max. Pullback %[/b]
Defines the maximum allowed pullback before the Sweep Candle forms. If price retraces beyond the specified percentage of the Range Candle before the pattern is confirmed, the potential CRT is considered invalid and discarded.

[b]Discount Border[/b]
Selects which structural level is used as the boundary of the Discount Zone.

Available options:
 • Range Middle (CRM) – the midpoint of the Range Candle.
 • Range High / Low (CRH / CRL) – the opposite boundary of the Range Candle.
 • Sweep High / Low (SH / SL) – the extreme of the Sweep Candle.
 • Sweep Open (SO) – the opening price of the Sweep Candle.
 • Sweep Close (SC) – the closing price of the Sweep Candle.

Changing this setting automatically updates both the displayed Discount Zone and the corresponding Discount Border alerts.

[b]Visual Settings[/b]

[b]Show Only Active Patterns[/b]
Controls how completed patterns are displayed.
 • Enabled – completed or invalidated CRTs are automatically removed from the chart.
 • Disabled – completed patterns remain visible as historical reference but are no longer updated.

[b]Color Settings[/b]
Every graphical element can be customized independently, including:
 • Bullish Range Candle
 • Bearish Range Candle
 • Inside Candles
 • CRH
 • CRL
 • CRM
 • SH
 • SL
 • Discount Border
 • Long Discount Zone
 • Short Discount Zone

This makes it easy to integrate the indicator with any TradingView chart theme.

[b]Design Philosophy[/b]

CRT Pattern is designed to provide an objective and consistent visualization of CRT market structure without requiring manual drawing or interpretation. Every stage of the pattern—from detection to completion—is handled automatically. Once confirmed, all structural levels remain fixed, ensuring that the indicator provides stable, non-repainting references throughout the lifetime of the pattern.

The indicator can be used as:
 • a standalone market structure analysis tool;
 • a discretionary trading aid;
 • a signal source for automated systems;
 • or a structural component within more advanced Study-on-Study workflows.

[b]Final Notes[/b]

 • Supports multiple active CRT patterns simultaneously.
 • Works on any market and any chart timeframe, provided the selected HTF is higher than the chart timeframe.
 • Uses only confirmed higher timeframe data for pattern confirmation.
 • Confirmed CRT patterns never repaint.
 • All structural alerts are based exclusively on bar closing prices, ensuring deterministic and reliable behavior for both manual trading and automation.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Pechka_Rider

//@version=6
indicator("CRT Pattern", "CRTP", true,
          max_boxes_count = 500,
          max_lines_count = 500,
          max_labels_count = 500)

// Inputs {
const string G_RS = "Range Settings"
htf = input.timeframe("60", "Timeframe", group = G_RS)
bodyMinPerc = input.float(70, "Body Min. %", 0, 100, group = G_RS)
candleMinSize = input.float(1.5, "Candle Min. Size", 0, step = 0.1, group = G_RS)
maxPullback = input.float(50, "Max. Pullback %", 0, 100, group = G_RS)
discountBorderType = input.string("Range Middle (CRM)", "Discount Border", ["Range Middle (CRM)", "Range High/Low (CRH/CRL)", "Sweep High/Low (SH/SL)", "Sweep Open (SO)", "Sweep Close (SC)"], group = G_RS)

const string G_V = "Visual"
showOnlyActive = input.bool(false, "Show Only Active Patterns", group = G_V)
txtSize = input.int(8, "Text Size", 1, group = G_V, display = display.none)
rngColRed = input.color(color.new(color.red, 85), "Red Candle Fill", group = G_V)
rngColGreen = input.color(color.new(color.green, 85), "Green Candle Fill", group = G_V)
rngColInside = input.color(color.new(color.gray, 85), "Inside Candle Fill", group = G_V)
crhCol = input.color(color.red, "Range High (CRH) Color", group = G_V)
crlCol = input.color(color.green, "Range Low (CRL) Color", group = G_V)
crmCol = input.color(color.gray, "Range Middle (CRM) Color", group = G_V)
shCol = input.color(color.red, "Sweep High (SH) Color", group = G_V)
slCol = input.color(color.green, "Sweep Low (SL) Color", group = G_V)
discountBorderCol = input.color(color.yellow, "Discount Border Color", group = G_V)
discountZoneLongCol = input.color(color.new(#059764, 90), "Long Discount Zone Fill", group = G_V)
discountZoneShortCol = input.color(color.new(#b5310a, 90), "Short Discount Zone Fill", group = G_V)
// }

// TF Check {
if timeframe.in_seconds(htf) <= timeframe.in_seconds(timeframe.period)
    runtime.error("Timeframe must be greater than chart timeframe.")
// }

// Types {
type candle
    chart.point o
    chart.point h
    chart.point l
    chart.point c
    box rangeBox

type pattern
    bool isLong
    bool formed
    candle rangeCandle
    candle sweepCandle
    candle[] insideCandles
    float discountBorder
    string discountName
    int discountX1
    line[] lines
    label[] labels
    box discountZone
// }

// Vars {
var pattern[] patterns = array.new<pattern>()
var candle currentCandle = candle.new(chart.point.new(time, bar_index, open),
                                      chart.point.new(time, bar_index, high),
                                      chart.point.new(time, bar_index, low),
                                      chart.point.new(time, bar_index, close))
// }

// Methods & Functions {
method deepCopy(chart.point this) =>
    chart.point.new(this.time, this.index, this.price)

method deepCopy(candle this) =>
    candle.new(this.o.deepCopy(), this.h.deepCopy(), this.l.deepCopy(), this.c.deepCopy())

method updatePoint(chart.point this, int t, int i, float p) =>
    this.time := t
    this.index := i
    this.price := p

method isGreen(candle this) =>
    this.c.price >= this.o.price

method rng(candle this) =>
    this.h.price - this.l.price

method body(candle this) =>
    math.abs(this.c.price - this.o.price)

method midPrice(candle this) =>
    (this.h.price + this.l.price) / 2

method drawRangeBox(candle this, color fillColor) =>
    this.rangeBox := box.new(this.o.time, this.h.price, this.c.time, this.l.price, na, xloc = xloc.bar_time, bgcolor = fillColor)

method extendDwg(pattern this) =>
    for ln in this.lines
        ln.set_x2(time)
    for lab in this.labels
        lab.set_x(time)
    this.discountZone.set_right(time)

method calcDiscountParams(pattern this) =>
    switch discountBorderType
        "Range Middle (CRM)" =>
            this.discountBorder := this.rangeCandle.midPrice()
            this.discountName := "CRM: "
            this.discountX1 := this.rangeCandle.o.time
        "Sweep High/Low (SH/SL)" => 
            this.discountBorder := this.isLong ? this.sweepCandle.h.price : this.sweepCandle.l.price
            this.discountName := this.isLong ? "SH: " : "SL: "
            this.discountX1 := this.isLong ? this.sweepCandle.h.time : this.sweepCandle.l.time
        "Sweep Open (SO)" =>
            this.discountBorder := this.sweepCandle.o.price
            this.discountName := "SO: "
            this.discountX1 := this.sweepCandle.o.time
        "Sweep Close (SC)" =>
            this.discountBorder := this.sweepCandle.c.price
            this.discountName := "SC: "
            this.discountX1 := this.sweepCandle.c.time
        "Range High/Low (CRH/CRL)" =>
            this.discountBorder := this.isLong ? this.rangeCandle.l.price : this.rangeCandle.h.price
            this.discountName := this.isLong ? "CRL: " : "CRH: "
            this.discountX1 := this.isLong ? this.rangeCandle.l.time : this.rangeCandle.h.time

method drawPattern(pattern this) =>
    this.rangeCandle.drawRangeBox(this.rangeCandle.isGreen() ? rngColGreen : rngColRed)
    this.sweepCandle.drawRangeBox(this.sweepCandle.isGreen() ? rngColGreen : rngColRed)
    if this.insideCandles.size() > 0
        for c in this.insideCandles
            c.drawRangeBox(rngColInside)
    if this.discountName != "CRH: "
        this.lines.push(line.new(this.rangeCandle.h, this.rangeCandle.h, xloc.bar_time, extend.none, crhCol, line.style_dotted))
        this.labels.push(label.new(this.rangeCandle.h, "CRH: " + str.tostring(this.rangeCandle.h.price, format.mintick), xloc.bar_time, yloc.price, color.new(color.white, 100), label.style_label_left, crhCol, txtSize))
    if this.discountName != "CRL: "
        this.lines.push(line.new(this.rangeCandle.l, this.rangeCandle.l, xloc.bar_time, extend.none, crlCol, line.style_dotted))
        this.labels.push(label.new(this.rangeCandle.l, "CRL: " + str.tostring(this.rangeCandle.l.price, format.mintick), xloc.bar_time, yloc.price, color.new(color.white, 100), label.style_label_left, crlCol, txtSize))
    if this.discountName != "CRM: "
        this.lines.push(line.new(this.rangeCandle.o.time, this.rangeCandle.midPrice(), time, this.rangeCandle.midPrice(), xloc.bar_time, extend.none, crmCol, line.style_dotted))
        this.labels.push(label.new(time, this.rangeCandle.midPrice(), "CRM: " + str.tostring(this.rangeCandle.midPrice(), format.mintick), xloc.bar_time, yloc.price, color.new(color.white, 100), label.style_label_left, crmCol, txtSize))
    if this.isLong
        this.lines.push(line.new(this.sweepCandle.l, this.sweepCandle.l, xloc.bar_time, extend.none, slCol, line.style_dotted))
        this.labels.push(label.new(this.sweepCandle.l, "SL: " + str.tostring(this.sweepCandle.l.price, format.mintick), xloc.bar_time, yloc.price, color.new(color.white, 100), label.style_label_left, slCol, txtSize))
    else
        this.lines.push(line.new(this.sweepCandle.h, this.sweepCandle.h, xloc.bar_time, extend.none, shCol, line.style_dotted))
        this.labels.push(label.new(this.sweepCandle.h, "SH: " + str.tostring(this.sweepCandle.h.price, format.mintick), xloc.bar_time, yloc.price, color.new(color.white, 100), label.style_label_left, shCol, txtSize))
    this.lines.push(line.new(this.discountX1, this.discountBorder, time, this.discountBorder, xloc.bar_time, extend.none, discountBorderCol, line.style_dotted))
    this.labels.push(label.new(time, this.discountBorder, this.discountName + str.tostring(this.discountBorder, format.mintick), xloc.bar_time, yloc.price, color.new(color.white, 100), label.style_label_left, discountBorderCol, txtSize))
    this.discountZone := box.new(time, (this.isLong ? this.sweepCandle.l.price : this.sweepCandle.h.price), time, this.discountBorder, na, xloc = xloc.bar_time, bgcolor = (this.isLong ? discountZoneLongCol : discountZoneShortCol))
    this.extendDwg()

method removePatternDwg(pattern this) =>
    this.rangeCandle.rangeBox.delete()
    this.sweepCandle.rangeBox.delete()
    if this.insideCandles.size() > 0
        for c in this.insideCandles
            c.rangeBox.delete()
    for ln in this.lines
        ln.delete()
    for lb in this.labels
        lb.delete()
    this.discountZone.delete()

upCross(float val) =>
    close[1] <= val and close > val

dnCross(float val) =>
    close[1] >= val and close < val
// }

// Calculations {
float atr = request.security(syminfo.tickerid, htf, ta.atr(14)[1], lookahead = barmerge.lookahead_on)
bool newHtfCandle = timeframe.change(htf)

bool newLongPattern = false
bool newShortPattern = false
bool discountShort = false
bool discountLong = false
bool crlUpCross = false
bool crlDnCross = false
bool crhUpCross = false
bool crhDnCross = false
bool crmUpCross = false
bool crmDnCross = false
bool sweepUpCross = false
bool sweepDnCross = false
bool discBorderUpCross = false
bool discBorderDnCross = false

// Found New Range Candle
if newHtfCandle and (currentCandle.body() / currentCandle.rng() * 100) >= bodyMinPerc and currentCandle.rng() >= atr * candleMinSize
    patterns.push(pattern.new(not currentCandle.isGreen(), false, currentCandle.deepCopy(), na, array.new<candle>(), na, na, na, array.new<line>(), array.new<label>(), na))

// Update Patterns
if patterns.size() > 0
    int i = 0
    while i < patterns.size()
        pattern p = patterns.get(i)
        if not p.formed and newHtfCandle
            // Range is Broken
            if (p.isLong ? currentCandle.c.price < p.rangeCandle.l.price : currentCandle.c.price > p.rangeCandle.h.price)
                patterns.remove(i)
                continue
            // Found Inner Candle
            else if currentCandle.h.price < p.rangeCandle.h.price and currentCandle.l.price > p.rangeCandle.l.price
                p.insideCandles.push(currentCandle.deepCopy())
            // Found Sweep Candle, Pattern is Formed
            else if (p.isLong ? (currentCandle.c.price > p.rangeCandle.l.price and currentCandle.l.price < p.rangeCandle.l.price) : 
                                (currentCandle.c.price < p.rangeCandle.h.price and currentCandle.h.price > p.rangeCandle.h.price))
                p.sweepCandle := currentCandle.deepCopy()
                p.formed := true
                p.calcDiscountParams()
                p.drawPattern()
                newLongPattern := newLongPattern or p.isLong
                newShortPattern := newShortPattern or not p.isLong
        // Pattern Failed by Pullback
        if not p.formed and (p.isLong ? (high > p.rangeCandle.l.price + p.rangeCandle.rng() * maxPullback / 100) : 
                                        (low < p.rangeCandle.h.price - p.rangeCandle.rng() * maxPullback / 100))
            patterns.remove(i)
            continue
        if p.formed
            // Check Cross Alerts
            crlUpCross := crlUpCross or upCross(p.rangeCandle.l.price)
            crlDnCross := crlDnCross or dnCross(p.rangeCandle.l.price)
            crhUpCross := crhUpCross or upCross(p.rangeCandle.h.price)
            crhDnCross := crhDnCross or dnCross(p.rangeCandle.h.price)
            crmUpCross := crmUpCross or upCross(p.rangeCandle.midPrice())
            crmDnCross := crmDnCross or dnCross(p.rangeCandle.midPrice())
            sweepUpCross := sweepUpCross or upCross(p.isLong ? p.sweepCandle.l.price : p.sweepCandle.h.price)
            sweepDnCross := sweepDnCross or dnCross(p.isLong ? p.sweepCandle.l.price : p.sweepCandle.h.price)
            discBorderUpCross := discBorderUpCross or upCross(p.discountBorder)
            discBorderDnCross := discBorderDnCross or dnCross(p.discountBorder)
            // Sweep is Broken or Target Reached
            if p.isLong ? (high >= p.rangeCandle.h.price or (newHtfCandle and currentCandle.c.price < p.sweepCandle.l.price)) :
                          (low <= p.rangeCandle.l.price or (newHtfCandle and currentCandle.c.price > p.sweepCandle.h.price))
                patterns.remove(i)
                // Remove DWG
                if showOnlyActive
                    p.removePatternDwg()
                continue
            // Check Discount Zone Alerts and Update DWG
            else
                discountShort := discountShort or (not p.isLong and close >= p.discountBorder and close <= p.sweepCandle.h.price)
                discountLong := discountLong or (p.isLong and close <= p.discountBorder and close >= p.sweepCandle.l.price)
                p.extendDwg()
        i += 1

// Update Current HTF Candle
if newHtfCandle
    currentCandle.o.updatePoint(time, bar_index, open)
    currentCandle.h.updatePoint(time, bar_index, high)
    currentCandle.l.updatePoint(time, bar_index, low)
    currentCandle.c.updatePoint(time, bar_index, close)
else
    currentCandle.c.updatePoint(time, bar_index, close)
    if high >= currentCandle.h.price
        currentCandle.h.updatePoint(time, bar_index, high)
    if low <= currentCandle.l.price
        currentCandle.l.updatePoint(time, bar_index, low)
// }

// Alerts {
alertcondition(newLongPattern or newShortPattern, "New CRT Pattern", "New CRT Pattern")
alertcondition(newLongPattern, "New CRT Long Pattern", "New CRT Long Pattern")
alertcondition(newShortPattern, "New CRT Short Pattern", "New CRT Short Pattern")
alertcondition(discountLong, "Discount Long", "Price in Long Discount Zone")
alertcondition(discountShort, "Discount Short", "Price in Short Discount Zone")
alertcondition(crlUpCross, "CRL Up Cross", "CRL Up Cross")
alertcondition(crlDnCross, "CRL Down Cross", "CRL Down Cross")
alertcondition(crhUpCross, "CRH Up Cross", "CRH Up Cross")
alertcondition(crhDnCross, "CRH Down Cross", "CRH Down Cross")
alertcondition(crmUpCross, "CRM Up Cross", "CRM Up Cross")
alertcondition(crmDnCross, "CRM Down Cross", "CRM Down Cross")
alertcondition(sweepUpCross, "SH/SL Up Cross", "SH/SL Up Cross")
alertcondition(sweepDnCross, "SH/SL Down Cross", "SH/SL Down Cross")
alertcondition(discBorderUpCross, "Discount Border Up Cross", "Discount Border Up Cross")
alertcondition(discBorderDnCross, "Discount Border Down Cross", "Discount Border Down Cross")
// }
````

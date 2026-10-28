# LH GAME PLAN NQ October 9  2026

- url: https://www.tradingview.com/script/gBshriPG-LH-GAME-PLAN-NQ-October-9-2026/
- type: indicator
- pine_id: PUB;84cbca86dd9947cf9360c157e130c355
- version: 1.0

## Description

**LH — NQ Game Plan | October 9, 2026**

Map Friday’s liquidity with black horizontal lines, tiny price labels, live session references and a compact bottom-center dashboard.

This indicator brings the Liquidity Hunter October 9 game plan onto your chart so you can prepare your levels, observe the sweep and wait for confirmation.

**GAME-PLAN REFERENCES**

Includes Thursday’s high, low, .25, .50 and .75; Wednesday’s high, low and settlement; Monday’s high, low and midpoint; and October 2 high/low plus October 1 low.

Thursday’s midpoint is the main decision reference. The dashboard shows whether price is above the midpoint, between the midpoint and .25, or below .25. This describes price location—not an automatic trade signal.

Thursday’s high and low are editable. Confirm these inputs against your final NQZ2026 session bar before trading. A manual input lets you add an older level that your chart confirms remains unpurged.

**OPTIONAL HIGHER-TIMEFRAME LEVELS**

• Previous week High / Low / Mid  
• Previous month High / Low / Mid  
• Previous quarter High / Low / .25 / .50 / .75  
• Rolling 20-, 40- and 60-daily-bar High / Low / Mid  

These arrays use the chart symbol and are captured at the beginning of the October 9 plan session.

**LIVE SESSION REFERENCES**

• Asia High / Low / Mid — default 6:00 PM–2:30 AM  
• London High / Low / Mid — default 2:30–7:00 AM  
• 8 AM candle High / Low / Mid — 8:00–9:00 AM  
• Initial Balance High / Low / Mid — 9:30–10:00 AM  
• 6 PM, midnight, weekly and 9:30 AM cash opens  
• VWAP anchored at Thursday, October 8, 6:00 PM  

All session times use America/New_York, including daylight-saving adjustments. Asia and London windows are adjustable. Session ranges develop live and retain their completed levels after the session ends.

**ALERTS AND DISCORD WEBHOOKS**

Supports the first wick breach above and below each enabled horizontal reference during the plan session, plus optional closing-cross alerts.

Alerts evaluate at candle close. Session-range alerts arm after their sessions finish. VWAP supports closing crosses only.

Messages use Discord-compatible JSON:

{"content":"LH NQ OCT 9 | event | level and price"}

Create a TradingView alert using “Any alert() function call.” Enter your Discord webhook URL for webhook delivery. Multiple level events can generate multiple messages on the same candle.

A wick breach marks a level crossing. It does not confirm a reversal or entry.

**RECOMMENDED SETUP**

Use standard 1–15 minute candles with extended hours enabled. Load enough chart history to include Thursday, October 8 at 6:00 PM Eastern for the anchored VWAP and session opens.

Fixed references are intended for December 2026 NQ. Live calculations use your chart’s symbol.

The default date filter displays the plan from October 8 at 6:00 PM through October 9 at 5:00 PM Eastern. Disable it to retain the reference display outside that window.

This indicator maps levels and sends alerts. IFVG/BPR entries, C2 confirmation, CISD, SMT and parent-cycle analysis remain manual.

For educational use. Futures trading involves substantial risk.

**NO SWEEP. NO TRADE.**  
**Time • Price • Execution.**

## Source Code

````pine
//@version=6
indicator("LH — NQ October 9, 2026", "LH NQ Oct 9", overlay = true, max_lines_count = 150, max_labels_count = 150)

string TZ = "America/New_York"
int START = timestamp(TZ, 2026, 10, 8, 18, 0)
int END = timestamp(TZ, 2026, 10, 9, 17, 0)
bool dateOnly = input.bool(true, "Display only October 9 session")
bool priceLabels = input.bool(true, "Show names and prices")
int offset = input.int(15, "Label offset", minval = 1, maxval = 100)
int thickness = input.int(1, "Black line width", minval = 1, maxval = 4)
bool tableOn = input.bool(true, "Bottom-center table")

string GF = "Fixed game-plan references — NQZ26"
float wh = input.float(31466.00, "Thursday high — confirm final bar", step = 0.25, group = GF)
float wl = input.float(30792.00, "Thursday low — confirm final bar", step = 0.25, group = GF)
float th = input.float(31521.00, "Wednesday high", step = 0.25, group = GF)
float tl = input.float(31143.00, "Wednesday low — already breached", step = 0.25, group = GF)
float ts = input.float(31402.25, "Wednesday settlement", step = 0.25, group = GF)
bool manualOn = input.bool(false, "Show manual unpurged level", group = GF)
float manualPrice = input.float(0.00, "Manual price", step = 0.25, group = GF)

string GH = "Additional arrays"
bool weekOn = input.bool(true, "Previous week H/L/Mid", group = GH)
bool monthOn = input.bool(false, "Previous month H/L/Mid", group = GH)
bool quarterOn = input.bool(false, "Previous quarter H/L/.25/.50/.75", group = GH)
bool ipdaOn = input.bool(false, "20/40/60 daily bars H/L/Mid", group = GH)

string GS = "Live sessions — Eastern"
bool opensOn = input.bool(true, "6 PM / midnight / weekly / cash opens", group = GS)
bool asiaOn = input.bool(true, "Asia H/L/Mid", group = GS)
string asiaSession = input.session("1800-0230", "Asia session", group = GS)
bool londonOn = input.bool(true, "London H/L/Mid", group = GS)
string londonSession = input.session("0230-0700", "London session", group = GS)
bool eightOn = input.bool(true, "8 AM H/L/Mid", group = GS)
bool ibOn = input.bool(true, "9:30–10:00 IB H/L/Mid", group = GS)
bool vwapOn = input.bool(true, "Thursday 6 PM anchored VWAP", group = GS)

string GA = "Alerts — Discord JSON"
bool alertsOn = input.bool(true, "Enable alerts on displayed lines", group = GA)
bool wickOn = input.bool(true, "First wick breach each direction", group = GA)
bool closeOn = input.bool(false, "Closing crosses", group = GA)

f_mid(float h, float l) =>
    math.round_to_mintick((h + l) / 2)

f_fib(float h, float l, float r) =>
    math.round_to_mintick(l + (h - l) * r)

f_range(bool inside, bool reset) =>
    var float h = na
    var float l = na
    if reset
        h := na
        l := na
    if inside
        h := na(h) ? high : math.max(h, high)
        l := na(l) ? low : math.min(l, low)
    [h, l]

f_hold(float value, bool reset) =>
    var float saved = na
    if reset
        saved := value
    saved

f_add(array<string> n, array<float> p, array<bool> a, string name, float price, bool enabled, bool armed) =>
    array.push(n, name)
    array.push(p, enabled ? price : na)
    array.push(a, enabled and armed and not na(price))

f_trip(array<string> n, array<float> p, array<bool> a, string name, float h, float l, bool enabled, bool armed) =>
    f_add(n, p, a, name + " High", h, enabled, armed)
    f_add(n, p, a, name + " Mid", f_mid(h, l), enabled, armed)
    f_add(n, p, a, name + " Low", l, enabled, armed)

f_send(string event, string name, float price) =>
    alert("{\"content\":\"LH NQ OCT 9 | " + event + " | " + name + " " + str.tostring(price, format.mintick) + " | Close " + str.tostring(close, format.mintick) + "\"}", alert.freq_all)

bool tfOK = timeframe.isintraday and timeframe.in_seconds() <= 900
bool active = time >= START and time < END
bool reset = active and (bar_index == 0 or time[1] < START)
bool visible = not dateOnly or active

// Completed previous-period values; snapshot at the plan's first bar.
[pwh0, pwl0, wo0] = request.security(syminfo.tickerid, "W", [high[1], low[1], open], lookahead = barmerge.lookahead_on)
[pmh0, pml0] = request.security(syminfo.tickerid, "M", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[pqh0, pql0] = request.security(syminfo.tickerid, "3M", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[h200, l200, h400, l400, h600, l600] = request.security(syminfo.tickerid, "D", [ta.highest(high, 20)[1], ta.lowest(low, 20)[1], ta.highest(high, 40)[1], ta.lowest(low, 40)[1], ta.highest(high, 60)[1], ta.lowest(low, 60)[1]], lookahead = barmerge.lookahead_on)

float pwh = f_hold(pwh0, reset)
float pwl = f_hold(pwl0, reset)
float wo = f_hold(wo0, reset)
float pmh = f_hold(pmh0, reset)
float pml = f_hold(pml0, reset)
float pqh = f_hold(pqh0, reset)
float pql = f_hold(pql0, reset)
float h20 = f_hold(h200, reset)
float l20 = f_hold(l200, reset)
float h40 = f_hold(h400, reset)
float l40 = f_hold(l400, reset)
float h60 = f_hold(h600, reset)
float l60 = f_hold(l600, reset)

bool inAsia = tfOK and active and not na(time(timeframe.period, asiaSession, TZ))
bool inLondon = tfOK and active and not na(time(timeframe.period, londonSession, TZ))
bool inEight = tfOK and active and not na(time(timeframe.period, "0800-0900", TZ))
bool inIB = tfOK and active and not na(time(timeframe.period, "0930-1000", TZ))

[ah, al] = f_range(inAsia, reset)
[lh, ll] = f_range(inLondon, reset)
[eh, el] = f_range(inEight, reset)
[ih, il] = f_range(inIB, reset)

var float sixOpen = na
var float midnightOpen = na
var float cashOpen = na
var float pv = na
var float vol = na

if reset
    sixOpen := na
    midnightOpen := na
    cashOpen := na
    pv := na
    vol := na

if tfOK and active
    if time == START
        sixOpen := open
        pv := hlc3 * nz(volume)
        vol := nz(volume)
    else if not na(pv)
        pv += hlc3 * nz(volume)
        vol += nz(volume)

    if hour(time, TZ) == 0 and minute(time, TZ) == 0
        midnightOpen := open

    if hour(time, TZ) == 9 and minute(time, TZ) == 30
        cashOpen := open

float avwap = not na(vol) and vol > 0 ? pv / vol : na
plot(visible and active and vwapOn ? avwap : na, "6 PM anchored VWAP", color.black, 2, plot.style_linebr)

// Stable slots preserve alert identities.
array<string> names = array.new_string()
array<float> prices = array.new_float()
array<bool> armed = array.new_bool()

f_trip(names, prices, armed, "Thursday", wh, wl, true, true)
f_add(names, prices, armed, "Thursday .75", f_fib(wh, wl, 0.75), true, true)
f_add(names, prices, armed, "Thursday .25", f_fib(wh, wl, 0.25), true, true)
f_add(names, prices, armed, "Wednesday High", th, true, true)
f_add(names, prices, armed, "Wednesday Low — Previously Breached", tl, true, true)
f_add(names, prices, armed, "Wednesday Settlement", ts, true, true)
f_add(names, prices, armed, "Monday High", 31371.00, true, true)
f_add(names, prices, armed, "October 2 High / Previous Week High", 31282.50, true, true)
f_add(names, prices, armed, "Monday Mid", 31164.25, true, true)
f_add(names, prices, armed, "Monday Low — Previously Breached", 30957.50, true, true)
f_add(names, prices, armed, "October 2 Low", 30760.25, true, true)
f_add(names, prices, armed, "October 1 Low", 30529.25, true, true)
f_add(names, prices, armed, "Manual Unpurged Level", manualPrice, manualOn and manualPrice > 0, true)

f_trip(names, prices, armed, "Previous Week", pwh, pwl, weekOn, true)
f_trip(names, prices, armed, "Previous Month", pmh, pml, monthOn, true)
f_trip(names, prices, armed, "Previous Quarter", pqh, pql, quarterOn, true)
f_add(names, prices, armed, "Previous Quarter .25", f_fib(pqh, pql, 0.25), quarterOn, true)
f_add(names, prices, armed, "Previous Quarter .75", f_fib(pqh, pql, 0.75), quarterOn, true)

f_trip(names, prices, armed, "20-Day", h20, l20, ipdaOn, true)
f_trip(names, prices, armed, "40-Day", h40, l40, ipdaOn, true)
f_trip(names, prices, armed, "60-Day", h60, l60, ipdaOn, true)

f_add(names, prices, armed, "6 PM Open", sixOpen, opensOn, true)
f_add(names, prices, armed, "Midnight Open", midnightOpen, opensOn, true)
f_add(names, prices, armed, "Weekly Open", wo, opensOn, true)
f_add(names, prices, armed, "9:30 Cash Open", cashOpen, opensOn, true)

f_trip(names, prices, armed, "Asia", ah, al, asiaOn, not inAsia)
f_trip(names, prices, armed, "London", lh, ll, londonOn, not inLondon)
f_trip(names, prices, armed, "8 AM", eh, el, eightOn, not inEight)
f_trip(names, prices, armed, "IB", ih, il, ibOn, not inIB)
f_add(names, prices, armed, "6 PM VWAP — Current", avwap, vwapOn, true)

var array<bool> upSeen = array.new_bool(100, false)
var array<bool> downSeen = array.new_bool(100, false)
var array<bool> wasArmed = array.new_bool(100, false)
var array<float> priorPrice = array.new_float(100, na)

if reset
    array.fill(upSeen, false)
    array.fill(downSeen, false)
    array.fill(wasArmed, false)
    array.fill(priorPrice, na)

if barstate.isconfirmed
    for i = 0 to array.size(names) - 1
        float p = array.get(prices, i)
        float pp = array.get(priorPrice, i)
        bool a = array.get(armed, i)
        string n = array.get(names, i)
        bool isVWAP = i == array.size(names) - 1

        if active and tfOK and a and array.get(wasArmed, i) and not na(pp)
            if not isVWAP and high > p and high[1] <= pp and not array.get(upSeen, i)
                array.set(upSeen, i, true)
                if alertsOn and wickOn
                    f_send("Wick breach ABOVE", n, p)

            if not isVWAP and low < p and low[1] >= pp and not array.get(downSeen, i)
                array.set(downSeen, i, true)
                if alertsOn and wickOn
                    f_send("Wick breach BELOW", n, p)

            if alertsOn and closeOn
                if close > p and close[1] <= pp
                    f_send("Closed ABOVE", n, p)
                if close < p and close[1] >= pp
                    f_send("Closed BELOW", n, p)

        array.set(priorPrice, i, p)
        array.set(wasArmed, i, a)

var array<line> lines = array.new<line>()
var array<label> labels = array.new<label>()

if barstate.islast
    for ln in lines
        line.delete(ln)
    for lb in labels
        label.delete(lb)

    array.clear(lines)
    array.clear(labels)

    if visible and tfOK
        int ms = int(timeframe.in_seconds() * 1000)
        int right = time + ms * offset

        for i = 0 to array.size(names) - 1
            float p = array.get(prices, i)
            if not na(p)
                array.push(lines, line.new(START, p, right, p, xloc = xloc.bar_time, color = color.black, width = thickness))
                if priceLabels
                    array.push(labels, label.new(right, p, array.get(names, i) + "  " + str.tostring(p, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.white, 100), textcolor = color.black, size = size.tiny))

var table dash = table.new(position.bottom_center, 2, 6, bgcolor = color.white, frame_color = color.black, frame_width = 1)

if barstate.islast
    table.clear(dash, 0, 0, 1, 5)

    if tableOn and visible
        string read = close >= f_mid(wh, wl) ? "Above Thursday midpoint" : close >= f_fib(wh, wl, 0.25) ? "Below mid / above .25" : "Below Thursday .25"

        table.cell(dash, 0, 0, "LIQUIDITY HUNTER", text_color = color.black, text_size = size.tiny)
        table.cell(dash, 1, 0, "NQ • OCT 9, 2026", text_color = color.black, text_size = size.tiny)
        table.cell(dash, 0, 1, "Location", text_color = color.black, text_size = size.tiny)
        table.cell(dash, 1, 1, read, text_color = color.black, text_size = size.tiny)
        table.cell(dash, 0, 2, "Thursday H / L", text_color = color.black, text_size = size.tiny)
        table.cell(dash, 1, 2, str.tostring(wh, format.mintick) + " / " + str.tostring(wl, format.mintick), text_color = color.black, text_size = size.tiny)
        table.cell(dash, 0, 3, "News • ET", text_color = color.black, text_size = size.tiny)
        table.cell(dash, 1, 3, "10:00 Michigan Sentiment + Inflation Expectations", text_color = color.black, text_size = size.tiny)
        table.cell(dash, 0, 4, "Chart / VWAP", text_color = color.black, text_size = size.tiny)
        table.cell(dash, 1, 4, not tfOK ? "Use standard 1–15M" : na(avwap) ? "Needs 6 PM bar + volume" : "6 PM VWAP " + str.tostring(avwap, format.mintick), text_color = color.black, text_size = size.tiny)
        table.cell(dash, 0, 5, "Time • Price • Execution", text_color = color.black, text_size = size.tiny)
        table.cell(dash, 1, 5, "NO SWEEP. NO TRADE.", text_color = color.black, text_size = size.tiny)
````

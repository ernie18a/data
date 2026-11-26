# [DAOL] Event Value Shift

- url: https://www.tradingview.com/script/zEvl2oj6-DAOL-Event-Value-Shift/
- type: indicator
- pine_id: PUB;da6df431e4eb4cb48b869936c7ac72fb
- version: 1.0

## Description

⏺️ What is it?

[DAOL] Event Value Shift compares price location with the movement of an Anchored Volume Weighted Average Price (VWAP).

It combines three elements:

• Anchored VWAP — a volume-weighted average calculated from a defined starting point
• Price Distance — how far the close is above or below VWAP, expressed in ATR units
• Value Shift — how much VWAP has moved over a selected number of bars, expressed in ATR units

The purpose is to distinguish price moving away from its reference from price moving in the same direction as that reference.

VWAP is an average derived from chart price and volume. It is not the actual cost basis of all market participants.

⏺️ Indicator นี้คืออะไร?

[DAOL] Event Value Shift เปรียบเทียบว่า ราคาห่างจากค่าเฉลี่ยมากแค่ไหน และค่าเฉลี่ยขยับไปทางเดียวกับราคาหรือไม่

ผสมหลักการ 3 ส่วน:

• Anchored VWAP — ราคาเฉลี่ยถ่วงน้ำหนักด้วย Volume ตั้งแต่จุดเริ่มที่กำหนด
• Price Distance — ราคาปิดอยู่เหนือหรือใต้ VWAP กี่ ATR
• Value Shift — VWAP ขยับขึ้นหรือลงกี่ ATR ในจำนวนแท่งที่เลือก

ช่วยแยกภาพ “ราคาวิ่งห่างจากค่าเฉลี่ย” กับ “ราคาและค่าเฉลี่ยขยับไปทางเดียวกัน”

VWAP เป็นค่าเฉลี่ยจากราคาและ Volume ไม่ใช่ต้นทุนจริงของผู้ถือครองทั้งหมด

⏺️ Why use Event Value Shift?

• Adds context to price distance from VWAP
• Separates the direction of VWAP movement from the direction of price location
• Uses ATR to express both measurements on a common scale
• Displays the underlying measurements rather than combining everything into one score
• Supports analysis from a selected event or a recurring exchange-day boundary

A large distance from VWAP does not automatically imply overbought, oversold, or an upcoming reversal.

⏺️ ทำไมต้องใช้?

• เพิ่มบริบทให้การอ่านระยะราคาห่างจาก VWAP
• แยกทิศทางการขยับของ VWAP ออกจากตำแหน่งราคา
• ใช้ ATR เป็นหน่วยร่วมสำหรับอ่านทั้งสองค่า
• แสดงตัวเลขแยกกัน เพื่อให้เข้าใจเหตุผลของสถานะ
• เลือกเริ่มติดตามจากเหตุการณ์ หรือเริ่มใหม่ตามขอบวันของตลาดได้

ราคาห่างจาก VWAP มากไม่ได้ยืนยันว่าซื้อมากเกินไป ขายมากเกินไป หรือกำลังจะกลับตัว

⏺️ How is it calculated?

Anchored VWAP = Sum of (HLC3 × Volume) ÷ Sum of Volume since the anchor

HLC3 = (High + Low + Close) ÷ 3

Price Distance = (Close − Current VWAP) ÷ Previous Bar ATR

Value Shift = (Current VWAP − VWAP N bars ago) ÷ Previous Bar ATR

Both VWAP observations must belong to the same anchor period. The indicator waits for sufficient VWAP history and a valid positive ATR before classifying a state.

Using the previous bar’s ATR prevents the evaluated bar from enlarging its own volatility denominator.

⏺️ คำนวณอย่างไร?

Anchored VWAP = ผลรวม (HLC3 × Volume) ÷ Volume รวมตั้งแต่จุดเริ่ม

HLC3 = (High + Low + Close) ÷ 3

Price Distance = (ราคาปิด − VWAP ปัจจุบัน) ÷ ATR ของแท่งก่อน

Value Shift = (VWAP ปัจจุบัน − VWAP เมื่อ N แท่งก่อน) ÷ ATR ของแท่งก่อน

VWAP ทั้งสองค่าต้องอยู่ภายในรอบ Anchor เดียวกัน ระบบจะรอประวัติ VWAP และ ATR ให้พร้อมก่อนจำแนกสถานะ

ใช้ ATR ของแท่งก่อน เพื่อไม่ให้แท่งที่กำลังประเมินขยายตัวหารของตัวเอง

⏺️ Anchor modes

Exchange day:
• Resets at TradingView’s exchange-day boundary
• Requires an intraday chart
• Starts at the first observed day boundary after the beginning of loaded history
• Does not separately identify custom morning, afternoon, or night sessions

Selected time:
• Starts at the first bar opening at or after the selected time
• Requires a loaded bar before the selected time
• If the selected event falls inside a bar, calculation starts at the next bar opening
• Includes the full volume of the actual anchor bar

The dashboard displays the actual anchor time in the exchange timezone.

⏺️ เลือกจุดเริ่มอย่างไร?

Exchange day:
• เริ่มใหม่ที่ขอบวันตาม TradingView
• ใช้กับกราฟ Intraday
• เริ่มจากขอบวันแรกที่ตรวจพบหลังจุดเริ่มประวัติที่โหลด
• ไม่ได้แยก Session เช้า บ่าย หรือกลางคืนโดยเฉพาะ

Selected time:
• เริ่มจากแท่งแรกที่เปิดตรงหรือหลังเวลาที่เลือก
• ต้องโหลดให้มีแท่งก่อนเวลาที่เลือกด้วย
• หากเหตุการณ์อยู่กลางแท่ง จะเริ่มที่เวลาเปิดแท่งถัดไป
• นับ Volume เต็มแท่งที่ใช้เป็น Anchor

Dashboard แสดงเวลาเริ่มจริงตามเขตเวลาของตลาด

⏺️ How to read the colors

🟢 Green — price is sufficiently above VWAP, and VWAP has moved upward beyond the selected threshold

🔴 Red — price is sufficiently below VWAP, and VWAP has moved downward beyond the selected threshold

🟡 Gold — price is far from VWAP, while VWAP displacement remains below the meaningful-shift threshold

🔵 Blue — price location and VWAP displacement oppose each other: above VWAP while VWAP falls, or below VWAP while VWAP rises

Gray — near or unclear conditions, or confirmation/data is not ready

The VWAP line color represents the confirmed state. The dashboard separately displays the latest classification, which may differ while confirmation is pending.

⏺️ อ่านสีอย่างไร?

🟢 เขียว — ราคาอยู่เหนือ VWAP ถึงเกณฑ์ และ VWAP ขยับขึ้นผ่านเกณฑ์

🔴 แดง — ราคาอยู่ใต้ VWAP ถึงเกณฑ์ และ VWAP ขยับลงผ่านเกณฑ์

🟡 ทอง — ราคาห่าง VWAP มาก แต่ VWAP ขยับน้อยกว่าเกณฑ์

🔵 ฟ้า — ตำแหน่งราคากับการขยับ VWAP สวนทาง เช่น ราคาเหนือ VWAP แต่ VWAP ลดลง

สีเทา — ใกล้ค่าเฉลี่ยหรือยังไม่ชัด หรือข้อมูล/การยืนยันยังไม่พร้อม

สีเส้น VWAP แสดงสถานะที่ยืนยันแล้ว ส่วน Dashboard แสดงสถานะล่าสุดแยกไว้ จึงอาจต่างกันระหว่างรอยืนยัน

⏺️ Example

Price Distance: +1.8 ATR
Value Shift: +0.05 ATR over 5 bars

With default thresholds, this qualifies as “Far / VWAP moving little”: price is well above its reference, but the reference has moved only slightly.

If Value Shift increases to +0.20 ATR while price remains sufficiently above VWAP, the latest classification becomes “Above / VWAP rising.”

Neither observation guarantees continuation or reversal.

⏺️ ตัวอย่าง

Price Distance: +1.8 ATR
Value Shift: +0.05 ATR ใน 5 แท่ง

ตามค่าเริ่มต้น จะเข้าเกณฑ์ “ราคาห่าง แต่ VWAP ขยับน้อย” เพราะราคาอยู่เหนือค่าเฉลี่ยมาก แต่ค่าเฉลี่ยเปลี่ยนเพียงเล็กน้อย

หาก Value Shift เพิ่มเป็น +0.20 ATR และราคายังเหนือ VWAP ถึงเกณฑ์ สถานะล่าสุดจะเปลี่ยนเป็น “เหนือ VWAP / VWAP ขยับขึ้น”

ทั้งสองกรณีไม่ได้รับประกันว่าราคาจะไปต่อหรือกลับตัว

⏺️ Default settings

• Anchor mode — Exchange day
• VWAP displacement lookback — 5 bars
• ATR length — 14
• Minimum price distance — 0.25 ATR
• Far distance — 1.50 ATR
• Meaningful VWAP displacement — 0.10 ATR
• Confirmation — 2 consecutive closed bars

The optional distance envelope is VWAP ± 1.50 prior-bar ATR by default. It is an ATR-distance reference, not a statistical confidence band.

⏺️ ค่าเริ่มต้น

• Anchor mode — Exchange day
• VWAP displacement lookback — 5 แท่ง
• ATR length — 14
• ระยะราคาขั้นต่ำ — 0.25 ATR
• เกณฑ์ราคาห่างมาก — 1.50 ATR
• เกณฑ์ VWAP ขยับชัด — 0.10 ATR
• ยืนยันสถานะ — 2 แท่งปิดต่อเนื่อง

กรอบระยะที่เปิดแสดงได้คือ VWAP ± 1.50 ATR ของแท่งก่อนตามค่าเริ่มต้น เป็นกรอบอ้างอิงระยะ ไม่ใช่ช่วงความเชื่อมั่นทางสถิติ

⏺️ How to use and alerts

Use a standard time-based candlestick or bar chart with suitable volume data.

Read Price Distance and Value Shift together. For event analysis, define the anchor before evaluating the outcome rather than selecting a favorable starting point afterward.

Available alerts:

• Above / VWAP rising
• Below / VWAP falling
• Far / little VWAP shift
• Price / VWAP opposed
• Any confirmed state change

The first confirmed state after each anchor initializes silently. Subsequent alerts occur when the confirmed state changes.

Create an alert using “Once Per Bar Close.” Recreate alerts after changing inputs or code.

⏺️ วิธีใช้และการแจ้งเตือน

ใช้กราฟแท่งเทียนหรือแท่งราคาตามเวลาที่มีข้อมูล Volume เหมาะสม แล้วอ่าน Price Distance ร่วมกับ Value Shift

หากติดตามเหตุการณ์ ควรกำหนดจุดเริ่มก่อนประเมินผล ไม่เลือกย้อนหลังเฉพาะจุดที่ให้ภาพสวย

เลือก Alert ได้สำหรับสถานะเขียว แดง ทอง ฟ้า หรือการเปลี่ยนสถานะทุกประเภท

สถานะแรกที่ยืนยันหลังแต่ละ Anchor ใช้เริ่มต้นระบบโดยไม่แจ้งเตือน จากนั้นจะแจ้งเมื่อสถานะยืนยันเปลี่ยน

ตั้ง “Once Per Bar Close” และสร้าง Alert ใหม่หลังเปลี่ยน Input หรือโค้ด

⏺️ Development and attribution

This implementation was written for DAOL without copying Community script source code.

It combines Anchored VWAP, ATR-based normalization, signed VWAP displacement, and closed-bar state confirmation for a specific purpose: comparing price location with the movement of its anchored reference.

Anchored VWAP and ATR are established concepts. No claim is made that these concepts or their general combination are new.

References:

TradingView — Anchored VWAP drawing tool

TradingView — Average True Range, developed by J. Welles Wilder

⏺️ การพัฒนาและอ้างอิง

โค้ดเขียนขึ้นสำหรับ DAOL โดยไม่คัดลอกสคริปต์ Community ผสม Anchored VWAP การปรับระยะด้วย ATR การวัดการขยับ VWAP และการยืนยันด้วยแท่งปิด

ส่วนต่อยอดคือการแยกตำแหน่งราคาออกจากการเปลี่ยนค่าเฉลี่ย พร้อมแสดงเหตุผลของแต่ละสถานะ ไม่อ้างว่า Anchored VWAP, ATR หรือการผสมสองแนวคิดเป็นสิ่งใหม่ทั้งหมด

แหล่งอ้างอิงระบุไว้ด้านบน โดย ATR อ้างอิงผลงานของ J. Welles Wilder

⏺️ Limitations and disclaimer

• VWAP is not the actual cost basis of all holders, intrinsic value, or institutional positioning.
• VWAP tends to become less responsive as cumulative volume grows. Small displacement may reflect anchor age rather than weak participation.
• Price and VWAP measurements are related because current price contributes to VWAP. They are not independent confirmations.
• Missing or negative volume invalidates the anchor calculation until the next reset. Genuine zero-volume bars do not change VWAP.
• Results depend on the anchor, chart timeframe, session settings, contract rollover, and data feed.
• Closed-bar confirmation introduces delay and does not prevent data revisions.
• Numerical checks have been completed outside Pine. TradingView compilation and market-feed validation remain pending.
• For educational and informational purposes only. It is not a standalone trading system and does not guarantee returns.

⏺️ ข้อจำกัดและคำชี้แจง

• VWAP ไม่ใช่ต้นทุนจริงของผู้ถือครองทั้งหมด มูลค่าที่แท้จริง หรือสถานะของสถาบัน
• เมื่อสะสม Volume มากขึ้น VWAP มักตอบสนองช้าลง การขยับน้อยอาจเกิดจากอายุ Anchor ไม่ใช่กิจกรรมอ่อนลง
• ราคาและ VWAP มีความเกี่ยวข้องกัน เพราะราคาปัจจุบันมีส่วนในการคำนวณ VWAP จึงไม่ใช่หลักฐานยืนยันที่เป็นอิสระจากกัน
• หาก Volume หายหรือเป็นลบ จะถือว่าการคำนวณ Anchor ไม่สมบูรณ์จนถึงรอบเริ่มใหม่ ส่วนแท่ง Volume ศูนย์จริงไม่เปลี่ยน VWAP
• จุดเริ่ม Timeframe Session การเปลี่ยนสัญญา และฟีดข้อมูลมีผลต่อผลลัพธ์
• การรอแท่งปิดทำให้มีความล่าช้า และไม่ได้ป้องกันการแก้ไขข้อมูลย้อนหลัง
• ตรวจสูตรเชิงตัวเลขแล้ว แต่ยังต้อง Compile และตรวจฟีดตลาดจริงใน TradingView
• ใช้เพื่อการศึกษาและประกอบการวิเคราะห์ ไม่ใช่ระบบซื้อขายโดยลำพังหรือการรับประกันผลตอบแทน

## Source Code

````pine
//@version=6
indicator("[DAOL] Event Value Shift", shorttitle="DAOL Value Shift", overlay=true, max_bars_back=600)

// Written for DAOL. No Community script source copied.
// Foundations: Anchored VWAP and J. Welles Wilder's ATR.
// https://www.tradingview.com/support/solutions/43000669764-anchored-vwap-drawing-tool/
// https://www.tradingview.com/support/solutions/43000501823-average-true-range-atr/
// Combines signed price distance and signed VWAP displacement; neither is
// order flow, actual holder cost, fair value, or a forecast. No novelty claim
// for VWAP, ATR, or their general combination.

string anchorMode = input.string("Exchange day", "Anchor mode", options=["Exchange day", "Selected time"], group="Anchor")
int selectedTime = input.time(timestamp("01 Oct 2026 00:00 +0700"), "Selected anchor time", group="Anchor")
int shiftBars = input.int(5, "VWAP displacement lookback", minval=1, maxval=250, group="Calculation")
int atrLength = input.int(14, "ATR length", minval=2, maxval=250, group="Calculation")
float minDistance = input.float(0.25, "Minimum signed price distance (ATR)", minval=0.01, maxval=5.0, step=0.05, group="Classification")
float farDistance = input.float(1.50, "Far from VWAP (ATR)", minval=0.1, maxval=10.0, step=0.1, group="Classification")
float minShift = input.float(0.10, "Meaningful VWAP displacement (ATR)", minval=0.01, maxval=3.0, step=0.01, group="Classification")
int confirmBars = input.int(2, "Consecutive closed bars to confirm", minval=1, maxval=10, group="Classification")
bool showEnvelope = input.bool(true, "Show distance envelope", group="Display")
bool shadeBackground = input.bool(false, "Shade confirmed state", group="Display")
bool showMarkers = input.bool(true, "Show state changes", group="Display")
bool showDashboard = input.bool(true, "Show dashboard", group="Display")

if not chart.is_standard
    runtime.error("Use standard time-based candles/bars, not synthetic charts.")
if anchorMode == "Exchange day" and not timeframe.isintraday
    runtime.error("Exchange-day mode requires an intraday chart. Use Selected time for daily or higher timeframes.")
if farDistance <= minDistance
    runtime.error("Far distance must exceed minimum price distance.")

bool newDay = timeframe.change("1D")
// Require an observed crossing for selected-time anchoring: do not silently
// start at dataset beginning when the requested anchor is outside history.
bool crossedAnchor = not na(time[1]) and time >= selectedTime and time[1] < selectedTime
float atr = ta.atr(atrLength)
var bool anchored = false
var bool invalidVolume = false
var float weightedSum = 0.0
var float totalVolume = 0.0
var int age = 0
var int actualAnchor = na
var array<float> vwapHistory = array.new_float(0)
var float closedVWAP = na
var float closedATR = na
var float closedDistance = na
var float closedShift = na
var bool ready = false
var int rawState = 0
var int candidate = 0
var int streak = 0
var int confirmedState = 0
var bool initialized = false
bool changed = false
bool reset = false

// State: 1 price above / VWAP up, -1 price below / VWAP down,
// 2 far / VWAP displacement small, 3 price and VWAP displacement opposed,
// 0 near/unclear. Opposed state takes precedence over aligned states.
f_name(int s) =>
    s == 1 ? "Above / VWAP rising" : s == -1 ? "Below / VWAP falling" : s == 2 ? "Far / VWAP moving little" : s == 3 ? "Price / VWAP opposed" : "Near / unclear"
f_color(int s) =>
    s == 1 ? color.lime : s == -1 ? color.red : s == 2 ? color.rgb(230, 175, 40) : s == 3 ? color.aqua : color.gray

if barstate.isconfirmed
    // In day mode skip the first partial loaded day; start at an observed day
    // boundary. TradingView's exchange-day boundary is not a user session.
    reset := anchorMode == "Exchange day" ? newDay and bar_index > 0 : crossedAnchor
    if reset
        anchored := true
        invalidVolume := false
        weightedSum := 0.0
        totalVolume := 0.0
        age := 0
        actualAnchor := time
        array.clear(vwapHistory)
        initialized := false
        streak := 0
        confirmedState := 0
        closedVWAP := na
    closedATR := atr[1]
    ready := false
    closedDistance := na
    closedShift := na
    rawState := 0
    if anchored
        age += 1
        if na(volume) or volume < 0.0
            invalidVolume := true
        else if not invalidVolume
            weightedSum += hlc3 * volume
            totalVolume += volume
        // Any missing volume invalidates the complete anchor accumulation
        // until next reset, rather than silently computing a partial VWAP.
        closedVWAP := not invalidVolume and totalVolume > 0.0 ? weightedSum / totalVolume : na
        array.push(vwapHistory, closedVWAP)
        if array.size(vwapHistory) > shiftBars + 1
            array.shift(vwapHistory)
        float oldVWAP = array.size(vwapHistory) == shiftBars + 1 ? array.get(vwapHistory, 0) : na
        ready := not na(closedVWAP) and not na(oldVWAP) and not na(closedATR) and closedATR > 0.0
        if ready
            closedDistance := (close - closedVWAP) / closedATR
            closedShift := (closedVWAP - oldVWAP) / closedATR
            bool above = closedDistance >= minDistance
            bool below = closedDistance <= -minDistance
            bool rising = closedShift >= minShift
            bool falling = closedShift <= -minShift
            bool farQuiet = math.abs(closedDistance) >= farDistance and math.abs(closedShift) < minShift
            if (above and falling) or (below and rising)
                rawState := 3
            else if above and rising
                rawState := 1
            else if below and falling
                rawState := -1
            else if farQuiet
                rawState := 2
            if streak == 0 or rawState != candidate
                candidate := rawState
                streak := 1
            else
                streak := math.min(streak + 1, confirmBars)
            if streak >= confirmBars
                changed := initialized and candidate != confirmedState
                confirmedState := candidate
                initialized := true
        else
            streak := 0
            initialized := false

// Break the plotted line on reset to avoid connecting different anchors.
color stateColor = ready and initialized ? f_color(confirmedState) : color.gray
plot(reset ? na : closedVWAP, "Anchored VWAP (closed bars)", color=stateColor, linewidth=2, style=plot.style_linebr)
pUpper = plot(showEnvelope and not reset ? closedVWAP + farDistance * closedATR : na, "Far-distance upper envelope", color=color.new(color.gray, 70), style=plot.style_linebr)
pLower = plot(showEnvelope and not reset ? closedVWAP - farDistance * closedATR : na, "Far-distance lower envelope", color=color.new(color.gray, 70), style=plot.style_linebr)
fill(pUpper, pLower, color=color.new(color.gray, 96), title="Distance envelope (not statistical bands)")
bgcolor(shadeBackground and ready and initialized ? color.new(stateColor, 93) : na)
plot(closedDistance, "Signed price distance (prior ATR)", display=display.data_window)
plot(closedShift, "Signed VWAP displacement (prior ATR)", display=display.data_window)
plot(age, "Bars since anchor (includes anchor bar)", display=display.data_window)
plotshape(showMarkers and changed and confirmedState == 1, title="Aligned up", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.tiny)
plotshape(showMarkers and changed and confirmedState == -1, title="Aligned down", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.tiny)
plotshape(showMarkers and changed and confirmedState == 2, title="Far quiet", style=shape.diamond, location=location.abovebar, color=color.rgb(230, 175, 40), size=size.tiny)
plotshape(showMarkers and changed and confirmedState == 3, title="Opposed", style=shape.circle, location=location.abovebar, color=color.aqua, size=size.tiny)

var table dashboard = table.new(position.top_right, 2, 6, border_width=1)
if barstate.islast and showDashboard
    color panel = color.rgb(35, 35, 35)
    string dataStatus = not anchored ? "Waiting for observed anchor" : invalidVolume ? "Missing volume: anchor invalid" : totalVolume <= 0 ? "No positive cumulative volume" : not ready ? "Building VWAP / ATR history" : "Closed-bar context"
    table.cell(dashboard, 0, 0, "DAOL Event Value Shift", text_color=color.white, bgcolor=color.rgb(19, 62, 103))
    table.cell(dashboard, 1, 0, dataStatus, text_color=color.white, bgcolor=color.rgb(19, 62, 103))
    table.cell(dashboard, 0, 1, "Actual anchor", text_color=color.white, bgcolor=panel)
    table.cell(dashboard, 1, 1, na(actualAnchor) ? "N/A" : str.format_time(actualAnchor, "yyyy-MM-dd HH:mm", syminfo.timezone), text_color=color.white, bgcolor=panel)
    table.cell(dashboard, 0, 2, "Price distance", text_color=color.white, bgcolor=panel)
    table.cell(dashboard, 1, 2, na(closedDistance) ? "N/A" : str.tostring(closedDistance, "#.00") + " ATR", text_color=color.white, bgcolor=panel)
    table.cell(dashboard, 0, 3, "VWAP shift / " + str.tostring(shiftBars) + " bars", text_color=color.white, bgcolor=panel)
    table.cell(dashboard, 1, 3, na(closedShift) ? "N/A" : str.tostring(closedShift, "#.00") + " ATR", text_color=color.white, bgcolor=panel)
    table.cell(dashboard, 0, 4, "Latest classification", text_color=color.white, bgcolor=panel)
    table.cell(dashboard, 1, 4, ready ? f_name(rawState) : "Waiting", text_color=f_color(rawState), bgcolor=panel)
    table.cell(dashboard, 0, 5, "Confirmed state", text_color=color.white, bgcolor=panel)
    table.cell(dashboard, 1, 5, ready and initialized ? f_name(confirmedState) : "Waiting", text_color=stateColor, bgcolor=panel)

alertcondition(changed and confirmedState == 1, "DAOL: Above / VWAP rising", "DAOL Event Value Shift: price above VWAP and VWAP displacement upward. {{ticker}} | {{interval}}")
alertcondition(changed and confirmedState == -1, "DAOL: Below / VWAP falling", "DAOL Event Value Shift: price below VWAP and VWAP displacement downward. {{ticker}} | {{interval}}")
alertcondition(changed and confirmedState == 2, "DAOL: Far / little VWAP shift", "DAOL Event Value Shift: price far from VWAP with small VWAP displacement. Not a reversal prediction. {{ticker}} | {{interval}}")
alertcondition(changed and confirmedState == 3, "DAOL: Price / VWAP opposed", "DAOL Event Value Shift: price side and VWAP displacement oppose. {{ticker}} | {{interval}}")
alertcondition(changed, "DAOL: Any confirmed state change", "DAOL Event Value Shift: confirmed context changed. {{ticker}} | {{interval}}")

// USAGE: Exchange day requires intraday standard chart and starts at the first
// observed 1D boundary after dataset start. This is NOT custom Day/Night Session.
// Selected time starts on first bar opening at/after selection; needs a loaded
// bar before selection to observe crossing. An event within a bar is rounded
// to next bar opening. Anchor-bar volume is included in full.
// VWAP uses HLC3*reported volume; zero-volume bars do not affect its value.
// Need shiftBars+1 valid VWAP values within the SAME anchor plus prior ATR.
// Current close and VWAP contribute jointly: metrics are not independent.
// VWAP increasingly inert with anchor age; small shift need not mean weakness.
// Envelope uses ATR distance, not confidence/probability or true holder costs.
// Only closed bars update calculations. First confirmed state per anchor is
// silent. Alerts only later transitions; select Once Per Bar Close.
// Choosing anchors after seeing outcomes creates selection bias. Fix rules
// before evaluating. Feed revisions/rollovers/session changes affect results.
// No future bars, pivots or MTF requests. External numerical checks only;
// TradingView compilation and market-feed validation pending.
````

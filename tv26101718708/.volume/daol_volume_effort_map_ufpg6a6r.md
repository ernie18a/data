# [DAOL] Volume Effort Map

- url: https://www.tradingview.com/script/ufPG6A6r-DAOL-Volume-Effort-Map/
- type: indicator
- pine_id: PUB;fffc2ce8f47947a1a36b74ac96d6aee4
- version: 1.0

## Description

⏺️ What is it?

[DAOL] Volume Effort Map compares trading activity with the price movement achieved during each completed bar.

It combines three measurements:

🔹 Same-Time Relative Volume — current bar volume compared with the average volume of bars opening at the same clock time on prior observed dates
🔹 Net Price Progress — close-to-close price change divided by the previous bar’s ATR
🔹 Close Location — where the close sits within the current bar’s high–low range

The purpose is to distinguish high activity accompanied by directional progress from high activity accompanied by little net closing-price movement.

For example, volume may reach 2.1 times its historical same-time average while the close changes by only 0.15 ATR. That indicates high activity with low net progress—not proof of accumulation or absorption.

⏺️ How is it calculated?

Relative Volume = Current Bar Volume ÷ Mean Historical Same-Time Bar Volume

Net Progress = (Current Close − Previous Close) ÷ Previous Bar ATR

Close Location = (Close − Low) ÷ (High − Low)

A close at the low has a location of 0%; a close at the high has a location of 100%. A zero-range bar is assigned 50%.

The volume baseline excludes the current date. Missing historical observations are skipped, while genuine zero-volume observations are included. Classification requires enough matching historical bars and a positive volume baseline.

Using the previous bar’s ATR prevents the evaluated bar from enlarging its own volatility denominator.

⏺️ How to read the colors

🟢 Green — high relative volume, sufficient upward net progress, and a close near the bar’s high

🔴 Red — high relative volume, sufficient downward net progress, and a close near the bar’s low

🟡 Gold — high relative volume, but small absolute close-to-close progress

🔵 Blue — high relative volume, without meeting the directional or low-progress criteria

Gray — normal or low relative volume; also used while valid measurements are unavailable

Low net progress can coexist with a large intrabar range. Inspect the separate Full Bar Range measurement before interpreting a gold bar.

⏺️ Default settings

🔹 Historical comparison — 20 prior observed exchange-calendar dates
🔹 Minimum matching observations — 5
🔹 High relative volume — at least 1.5x
🔹 ATR length — 14
🔹 Low net progress — no more than 0.20 prior ATR in absolute terms
🔹 Directional progress — at least 0.50 prior ATR
🔹 Closing edge zone — upper or lower 25% of the bar

These are starting parameters, not optimized settings or validated performance claims.

⏺️ How to use

Use a standard time-based chart from 1 to 60 minutes. A 5- or 15-minute chart is a practical starting point for evaluation.

The histogram displays same-time relative volume. Its color describes the latest completed bar’s activity and price result.

⏺️ The dashboard displays:

🔹 Relative volume
🔹 Signed net price progress
🔹 Full bar range in prior ATR units
🔹 Close location
🔹 Matching historical sample count
🔹 Current classification or data-status message

Optional price-bar coloring is available.

For TFEX evaluation, S50 and GO contract-month charts are proposed starting points, provided the feed has sufficiently continuous volume data. This is an application proposal, not validated instrument-specific performance.

⏺️ Alerts

Available conditions:

🔹 High activity / upward progress
🔹 High activity / downward progress
🔹 High activity / low net progress
🔹 High activity / mixed result
🔹 Any activity-state change

Each classification describes one completed bar. This version does not require two-bar persistence.

The first valid classification initializes silently. Subsequent alerts occur when the classification changes, rather than on every bar that meets the same condition.

Create an alert in TradingView and select “Once Per Bar Close.” Recreate alerts after changing the code or inputs.

Development and attribution

This implementation was written for DAOL without copying Community script code.

⏺️ The foundation combines:

🔹 Same-time relative-volume comparison, as described in TradingView’s Relative Volume at Time documentation
🔹 Average True Range, developed by J. Welles Wilder
🔹 Close location within a bar, a standard price-position calculation

The extension is the classification workflow connecting time-adjusted activity, volatility-adjusted net progress, and closing position, with separate measurements explaining each result.

No claim is made that relative volume, ATR, close-location analysis, or the general idea of comparing effort with result is new.

This implementation compares individual bar volume at exact clock-time matches. It does not reproduce TradingView’s complete Relative Volume at Time implementation or calculate cumulative session volume.

⏺️ References:

TradingView — Relative Volume at Time

TradingView — Average True Range

Limitations and disclaimer

🔹 Volume is the reported feed volume. It is not bid/ask delta or direct evidence of buyer/seller intent.
🔹 High activity with low net progress does not establish absorption, institutional accumulation, or a future reversal.
🔹 Clock-time matching uses the exchange timezone and calendar date, not the exchange’s official trading-date definition. Overnight sessions crossing midnight are split across dates.
🔹 Session settings, irregular bar openings, shortened sessions, daylight-saving changes, contract rollover, and missing data can affect comparisons.
🔹 Price gaps are included in close-to-close progress.
🔹 At least the selected minimum number of historical time matches must be available. Until then, the indicator displays a waiting state.
🔹 Numerical checks have been completed outside Pine. TradingView compilation, runtime performance, and market-feed validation remain pending.
🔹 For educational and informational purposes only. It is not a standalone trading system and does not guarantee returns.

คำอธิบายภาษาไทย

⏺️ Indicator นี้คืออะไร?

[DAOL] Volume Effort Map เปรียบเทียบว่า กิจกรรมซื้อขายที่เพิ่มขึ้น ทำให้ราคาปิดเดินหน้าได้มากแค่ไหน

ผสมหลักการ 3 ส่วน:

🔹 Same-Time Relative Volume — Volume ของแท่งปัจจุบันเทียบกับค่าเฉลี่ยแท่งที่เปิดเวลาเดียวกันในวันก่อน ๆ
🔹 Net Price Progress — ระยะเปลี่ยนราคาปิดเทียบกับราคาปิดก่อนหน้า หารด้วย ATR ของแท่งก่อน
🔹 Close Location — ตำแหน่งราคาปิดภายในช่วง High–Low ของแท่ง

ตัวอย่าง: Volume สูงถึง 2.1 เท่าของค่าเฉลี่ยเวลาเดียวกัน แต่ราคาปิดเปลี่ยนเพียง 0.15 ATR หมายถึงกิจกรรมสูงแต่ความคืบหน้าสุทธิต่ำ ไม่ได้ยืนยันว่ามีการสะสมหรือ Absorption

⏺️ อ่านสีอย่างไร?

🟢 เขียว — Volume สูง ราคาเดินหน้าขึ้นถึงเกณฑ์ และปิดใกล้ High

🔴 แดง — Volume สูง ราคาเดินหน้าลงถึงเกณฑ์ และปิดใกล้ Low

🟡 ทอง — Volume สูง แต่ราคาปิดเปลี่ยนจากแท่งก่อนน้อย

🔵 ฟ้า — Volume สูง แต่ยังไม่เข้าเกณฑ์ทิศทางหรือความคืบหน้าต่ำ

สีเทา — กิจกรรมปกติหรือต่ำ หรือข้อมูลยังไม่พร้อม

สีทองไม่ได้แปลว่าราคาไม่แกว่งระหว่างแท่ง เพราะแท่งอาจมี High–Low กว้าง แต่กลับมาปิดใกล้ราคาปิดเดิม จึงควรอ่าน Full Bar Range ประกอบ

⏺️ วิธีคำนวณ

Relative Volume = Volume ปัจจุบัน ÷ ค่าเฉลี่ย Volume เวลาเดียวกันย้อนหลัง

Net Progress = (ราคาปิดปัจจุบัน − ราคาปิดก่อนหน้า) ÷ ATR ของแท่งก่อน

Close Location = (ราคาปิด − Low) ÷ (High − Low)

Close Location 0% หมายถึงปิดที่ Low และ 100% หมายถึงปิดที่ High หากแท่งไม่มีช่วงราคา จะกำหนดเป็น 50%

ค่าเฉลี่ย Volume ไม่รวมวันปัจจุบัน ข้อมูลที่หายจะไม่นำมาคำนวณ แต่แท่งที่มี Volume เป็นศูนย์จริงจะนำมารวมด้วย

⏺️ ค่าเริ่มต้น

🔹 เปรียบเทียบย้อนหลัง 20 วันที่มีแท่งปรากฏในกราฟ
🔹 ต้องมีตัวอย่างเวลาเดียวกันอย่างน้อย 5 ค่า
🔹 Volume สูงเมื่อถึง 1.5 เท่า
🔹 ATR 14 แท่ง
🔹 ความคืบหน้าต่ำเมื่อเปลี่ยนไม่เกิน 0.20 ATR
🔹 ความคืบหน้าเชิงทิศทางอย่างน้อย 0.50 ATR
🔹 โซนปิดใกล้ขอบเท่ากับ 25% ของช่วงแท่ง

เป็นค่าตั้งต้นสำหรับทดลอง ไม่ใช่ค่าที่ผ่านการปรับให้เหมาะที่สุดหรือรับรองผลการซื้อขาย

⏺️ วิธีใช้งาน

ใช้กราฟแท่งเทียนตามเวลา 1–60 นาที โดยเริ่มทดลองที่ 5 หรือ 15 นาทีได้ และโหลดประวัติให้มีตัวอย่างเวลาเดียวกันเพียงพอ

Histogram แสดง Relative Volume ส่วนสีอธิบายผลด้านราคาของแท่งปิดล่าสุด

Dashboard แสดง Volume เทียบค่าเฉลี่ย ระยะเปลี่ยนราคาปิด ช่วง High–Low ในหน่วย ATR ตำแหน่งปิด จำนวนตัวอย่าง และสถานะ สามารถเปิดให้เปลี่ยนสีแท่งราคาตามสถานะได้ด้วย

สำหรับ TFEX สามารถเริ่มประเมินกับ S50 หรือ GO แบบสัญญารายเดือนที่มีข้อมูล Volume ต่อเนื่อง โดยยังต้องทดสอบผลกับฟีดจริง

⏺️ การแจ้งเตือน

เลือกแจ้งเตือนสถานะขึ้น ลง ความคืบหน้าต่ำ ผลไม่ชัด หรือการเปลี่ยนสถานะทุกประเภทได้

เวอร์ชันนี้ประเมินทีละหนึ่งแท่งปิด ไม่ได้รอยืนยันต่อเนื่องสองแท่ง สถานะแรกใช้เริ่มต้นระบบโดยไม่แจ้งเตือน หลังจากนั้นจะแจ้งเมื่อสถานะเปลี่ยน

ตั้ง Alert เป็น “Once Per Bar Close” และสร้างใหม่หลังเปลี่ยน Input หรือโค้ด

ที่มาและส่วนที่ต่อยอด

โค้ดเขียนขึ้นสำหรับ DAOL โดยไม่คัดลอกสคริปต์ Community ใช้แนวคิด Relative Volume at Time ร่วมกับ ATR ของ J. Welles Wilder และตำแหน่งราคาปิดภายในแท่ง

ส่วนต่อยอดคือการเชื่อมกิจกรรมที่เทียบตามเวลาเข้ากับความคืบหน้าที่ปรับด้วยความผันผวน แล้วอธิบายผลด้วยสถานะและตัวเลขแยกกัน ไม่อ้างว่าแนวคิดพื้นฐานทั้งหมดเป็นสิ่งใหม่

แหล่งอ้างอิงอยู่ในส่วนภาษาอังกฤษด้านบน

⏺️ ข้อจำกัดและคำชี้แจง

🔹 Volume ไม่ใช่ข้อมูลฝั่งซื้อ/ขายจริง และไม่ยืนยันพฤติกรรมรายใหญ่
🔹 Volume สูงแต่ราคาปิดคืบหน้าน้อยไม่ได้รับประกันการกลับตัว
🔹 แบ่งวันตามวันที่ปฏิทินในเขตเวลาตลาด ไม่ใช่ Trade Date ของ TFEX ช่วงข้ามเที่ยงคืนจึงถูกแบ่งเป็นคนละวัน
🔹 Session เวลาเปิดแท่ง การเปลี่ยนสัญญา และข้อมูลที่ขาดหายมีผลต่อค่าเปรียบเทียบ
🔹 Gap ถูกนับรวมในระยะเปลี่ยนราคาปิด
🔹 ตรวจสูตรเชิงตัวเลขแล้ว แต่ยังต้อง Compile และตรวจการทำงานกับข้อมูลตลาดจริงใน TradingView
🔹 ใช้เพื่อการศึกษาและประกอบการวิเคราะห์ ไม่ใช่ระบบซื้อขายโดยลำพังหรือการรับประกันผลตอบแทน

## Source Code

````pine
//@version=6
indicator("[DAOL] Volume Effort Map", shorttitle="DAOL Effort", overlay=false, precision=2)

// Written for DAOL; no Community script code copied.
// Foundation: same-time relative volume and Wilder ATR; no novelty claim for
// these concepts or general effort-versus-result analysis.
// https://www.tradingview.com/support/solutions/43000705489-relative-volume-at-time/
// https://www.tradingview.com/support/solutions/43000501823-average-true-range-atr/
// This implementation compares BAR volume, not cumulative session volume.
// Volume is reported feed volume, not bid/ask delta or smart-money detection.

int priorDays = input.int(20, "Prior observed exchange dates", minval=5, maxval=40, group="Same-time volume")
int minSamples = input.int(5, "Minimum matching historical bars", minval=2, maxval=40, group="Same-time volume")
float highVolume = input.float(1.5, "High relative volume (x)", minval=1.0, maxval=10.0, step=0.1, group="Classification")
int atrLength = input.int(14, "ATR length", minval=2, maxval=100, group="Classification")
float lowProgress = input.float(0.20, "Low net close progress (prior ATR)", minval=0.01, maxval=2.0, step=0.05, group="Classification")
float strongProgress = input.float(0.50, "Directional progress (prior ATR)", minval=0.05, maxval=5.0, step=0.05, group="Classification")
float edgeZone = input.float(25.0, "Close near edge (% of bar range)", minval=1.0, maxval=49.0, step=1.0, group="Classification")
bool colorBars = input.bool(false, "Color price bars", group="Display")
bool showDashboard = input.bool(true, "Show dashboard", group="Display")

if not timeframe.isminutes or timeframe.multiplier > 60
    runtime.error("Use a standard time-based intraday chart from 1 to 60 minutes.")
if not chart.is_standard
    runtime.error("Use standard candles/bars. Synthetic chart prices and volumes are unsuitable.")
if minSamples > priorDays
    runtime.error("Minimum matching historical bars must be <= Prior observed exchange dates.")
if lowProgress >= strongProgress
    runtime.error("Low progress threshold must be smaller than directional progress threshold.")

// Calendar date and bar-opening clock minute in the exchange timezone.
// No holidays/weekends invented: ring advances only on dates present in chart.
// Overnight trading crossing midnight is split by calendar date, NOT trade date.
int dateKey = year(time, syminfo.timezone) * 10000 + month(time, syminfo.timezone) * 100 + dayofmonth(time, syminfo.timezone)
int slot = hour(time, syminfo.timezone) * 60 + minute(time, syminfo.timezone)
int slotsPerDay = 1440
int capacity = priorDays + 1
var array<float> history = array.new_float(capacity * slotsPerDay, na)
var int activeDate = na
var int activeRow = -1
var int availableDays = 0
float currentATR = ta.atr(atrLength)

var float closedRV = na
var float closedBaseline = na
var float closedProgress = na
var float closedCLV = na
var float closedRangeATR = na
var int closedSamples = 0
var int state = 0
var int previousState = 0
var bool initialized = false
var string status = "Collecting same-time history"
bool changed = false

// 0 normal activity; 1 high activity / upward progress; -1 downward;
// 2 high activity / low net progress; 3 high activity / mixed result.
f_name(int s) =>
    s == 1 ? "High activity / upward progress" : s == -1 ? "High activity / downward progress" : s == 2 ? "High activity / low net progress" : s == 3 ? "High activity / mixed result" : "Normal or low activity"
f_color(int s) =>
    s == 1 ? color.lime : s == -1 ? color.red : s == 2 ? color.rgb(230, 175, 40) : s == 3 ? color.aqua : color.gray

if barstate.isconfirmed
    if na(activeDate) or dateKey != activeDate
        activeRow := (activeRow + 1) % capacity
        activeDate := dateKey
        availableDays := math.min(availableDays + 1, capacity)
        for m = 0 to slotsPerDay - 1
            array.set(history, activeRow * slotsPerDay + m, na)

    // Compute BEFORE storing current volume; current date is always excluded.
    float total = 0.0
    int count = 0
    for age = 1 to priorDays
        if age < availableDays
            int row = (activeRow - age + capacity) % capacity
            float observation = array.get(history, row * slotsPerDay + slot)
            if not na(observation) and observation >= 0.0
                total += observation
                count += 1
    float average = count > 0 ? total / count : na
    bool ready = count >= minSamples and not na(average) and average > 0.0 and not na(volume) and volume >= 0.0 and not na(currentATR[1]) and currentATR[1] > 0.0 and not na(close[1])
    closedSamples := count
    closedBaseline := average
    closedRV := ready ? volume / average : na
    closedProgress := ready ? (close - close[1]) / currentATR[1] : na
    float barRange = high - low
    closedCLV := ready ? (barRange > 0.0 ? (close - low) / barRange : 0.5) : na
    closedRangeATR := ready ? barRange / currentATR[1] : na
    state := 0
    if ready
        if closedRV >= highVolume
            if math.abs(closedProgress) <= lowProgress
                state := 2
            else if closedProgress >= strongProgress and closedCLV >= 1.0 - edgeZone / 100.0
                state := 1
            else if closedProgress <= -strongProgress and closedCLV <= edgeZone / 100.0
                state := -1
            else
                state := 3
        changed := initialized and state != previousState
        previousState := state
        initialized := true
        status := f_name(state)
    else
        initialized := false
        status := na(volume) ? "Missing current volume" : count < minSamples ? "Collecting same-time history" : na(average) or average <= 0.0 ? "No positive historical volume baseline" : "Waiting for valid ATR/price"
    // Missing observations remain NA; real zero-volume bars remain zero.
    array.set(history, activeRow * slotsPerDay + slot, not na(volume) and volume >= 0.0 ? volume : na)

plot(closedRV, "Same-time relative volume (x)", color=f_color(state), style=plot.style_columns, linewidth=2)
hline(1.0, "Historical volume baseline", color=color.gray, linestyle=hline.style_dotted)
hline(highVolume, "High activity threshold", color=color.orange, linestyle=hline.style_dashed)
plot(closedProgress, "Signed net progress (prior ATR)", display=display.data_window)
plot(closedRangeATR, "Full bar range (prior ATR)", display=display.data_window)
plot(closedCLV * 100.0, "Close location: low=0 high=100", display=display.data_window)
plot(closedBaseline, "Mean matching historical bar volume", display=display.data_window)
plot(closedSamples, "Matching historical bars", display=display.data_window)
barcolor(colorBars and not na(closedRV) ? f_color(state) : na)

var table dashboard = table.new(position.top_right, 2, 7, border_width=1)
if barstate.islast and showDashboard
    color panel = color.rgb(35, 35, 35)
    table.cell(dashboard, 0, 0, "DAOL Volume Effort Map", text_color=color.white, bgcolor=color.rgb(19, 62, 103))
    table.cell(dashboard, 1, 0, "Latest closed bar", text_color=color.white, bgcolor=color.rgb(19, 62, 103))
    table.cell(dashboard, 0, 1, "Volume / same-time mean", text_color=color.white, bgcolor=panel)
    table.cell(dashboard, 1, 1, na(closedRV) ? "N/A" : str.tostring(closedRV, "#.00") + "x", text_color=f_color(state), bgcolor=panel)
    table.cell(dashboard, 0, 2, "Net close progress", text_color=color.white, bgcolor=panel)
    table.cell(dashboard, 1, 2, na(closedProgress) ? "N/A" : str.tostring(closedProgress, "#.00") + " ATR", text_color=color.white, bgcolor=panel)
    table.cell(dashboard, 0, 3, "Full bar range", text_color=color.white, bgcolor=panel)
    table.cell(dashboard, 1, 3, na(closedRangeATR) ? "N/A" : str.tostring(closedRangeATR, "#.00") + " ATR", text_color=color.white, bgcolor=panel)
    table.cell(dashboard, 0, 4, "Close location", text_color=color.white, bgcolor=panel)
    table.cell(dashboard, 1, 4, na(closedCLV) ? "N/A" : str.tostring(closedCLV * 100.0, "#.0") + "%", text_color=color.white, bgcolor=panel)
    table.cell(dashboard, 0, 5, "Historical samples", text_color=color.white, bgcolor=panel)
    table.cell(dashboard, 1, 5, str.tostring(closedSamples) + " / " + str.tostring(priorDays), text_color=color.white, bgcolor=panel)
    table.cell(dashboard, 0, 6, "Context", text_color=color.white, bgcolor=panel)
    table.cell(dashboard, 1, 6, status, text_color=f_color(state), bgcolor=panel)

alertcondition(changed and state == 1, "DAOL: High activity / upward progress", "DAOL Volume Effort Map: high same-time volume, upward close progress and close near bar high. {{ticker}} | {{interval}}")
alertcondition(changed and state == -1, "DAOL: High activity / downward progress", "DAOL Volume Effort Map: high same-time volume, downward close progress and close near bar low. {{ticker}} | {{interval}}")
alertcondition(changed and state == 2, "DAOL: High activity / low net progress", "DAOL Volume Effort Map: high same-time volume but low net close progress. Not proof of absorption. {{ticker}} | {{interval}}")
alertcondition(changed and state == 3, "DAOL: High activity / mixed result", "DAOL Volume Effort Map: high same-time volume without a clear directional or low-progress classification. {{ticker}} | {{interval}}")
alertcondition(changed, "DAOL: Any activity-state change", "DAOL Volume Effort Map: closed-bar activity state changed. {{ticker}} | {{interval}}")

// USAGE / PUBLICATION NOTES
// Use 1-60 minute standard charts; start with 5 or 15 minutes. Load enough
// history for >=5 matching bar-opening clock times on prior observed dates.
// Same-time baseline is arithmetic mean of prior exact clock-minute matches
// in exchange timezone, excluding current date. Not cumulative volume, not
// TradingView's identical RVOL-at-Time implementation. Missing times skipped.
// Session settings, partial bars, holidays, DST, overnight calendar boundaries
// and illiquid feeds influence comparability. No historical calendar slots
// are manufactured. Repeated local-time bars on a DST fallback date overwrite
// that date's clock slot; use markets without ambiguous local times if needed.
// Low net progress may coexist with large intrabar movement: inspect full
// bar range separately. Gaps count in close-to-close progress. Prior-bar ATR
// is used to avoid inflating denominator with the same bar being evaluated.
// Closed-bar measurements held during live bar. First valid state initializes
// silently; alerts on later transitions only, once per bar close. No 2-bar
// persistence by default: each classification describes one completed bar.
// No guaranteed predictive value, absorption, buy/sell volume or profit claims.
// Tested numerically outside Pine; TradingView compilation/feed testing pending.
````

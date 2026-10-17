# [DAOL] Range Escape Quality

- url: https://www.tradingview.com/script/xWP6P10r-DAOL-Range-Escape-Quality/
- type: indicator
- pine_id: PUB;3318ff47ff4646948c122b15d2652ca9
- version: 1.0

## Description

⏺️ What is it?

[DAOL] Range Escape Quality evaluates price movement after a confirmed breakout from a prior high–low range.

It combines directional efficiency and retracement to distinguish efficient follow-through from movement that stays outside the range but makes little progress.

🔹 Frozen Range — the prior range captured at the breakout
🔹 Directional Efficiency — forward progress relative to cumulative close-to-close movement
🔹 Giveback — how much of the best post-breakout progress has been lost
🔹 Quality Score — efficiency adjusted for giveback, ranging from 0 to 100

The score describes observed price movement. It is not a win probability or an automatic trading recommendation.

⏺️ Indicator นี้คืออะไร?

[DAOL] Range Escape Quality ประเมิน คุณภาพการเดินหน้าของราคาหลังปิดหลุดกรอบ โดยดูทั้งประสิทธิภาพการเคลื่อนที่และระยะที่คืนกลับ

ช่วยแยกระหว่าง “หลุดแล้วเดินหน้าต่อ” กับ “ยังอยู่นอกกรอบ แต่แกว่งมากและคืบหน้าน้อย”

🔹 Frozen Range — กรอบราคาเดิมที่ตรึงไว้เมื่อเกิด Breakout
🔹 Directional Efficiency — ระยะเดินหน้าสุทธิเทียบกับระยะเคลื่อนไหวสะสมของราคาปิด
🔹 Giveback — สัดส่วนระยะที่คืนกลับจากจุดที่เดินหน้าได้ไกลที่สุด
🔹 Quality Score — คะแนนประสิทธิภาพหลังหักการคืนระยะ อยู่ระหว่าง 0–100

คะแนนใช้บรรยายการเคลื่อนไหวที่เกิดขึ้น ไม่ใช่เปอร์เซ็นต์โอกาสชนะหรือคำแนะนำซื้อขายโดยอัตโนมัติ

⏺️ Why use it?

🔹 Evaluates follow-through after a breakout
🔹 Distinguishes directional progress from repeated back-and-forth movement
🔹 Keeps the original range fixed during each event
🔹 Measures how much progress remains after retracement
🔹 Provides a consistent observation window for comparing events

⏺️ ทำไมต้องใช้?

🔹 อ่านคุณภาพการเคลื่อนที่หลัง Breakout
🔹 แยกการเดินหน้าตามทิศทางออกจากการแกว่งไปมา
🔹 ตรึงกรอบเดิมตลอดเหตุการณ์ เพื่อให้ระดับอ้างอิงคงที่
🔹 ดูว่าราคายังรักษาระยะที่เดินหน้าไว้ได้มากแค่ไหน
🔹 ใช้ช่วงติดตามที่กำหนดชัดเจนเพื่อเปรียบเทียบแต่ละเหตุการณ์

⏺️ How does it work?

Build a range from the highs and lows of the preceding 20 bars, excluding the current bar.

Start an event when the current bar closes outside that range and the preceding close is within the same range.

Freeze the range boundaries and use the breakout close as the measurement origin.

Observe the next 5 closed bars by default.

Finish early if a close reaches or crosses back over the frozen breakout boundary.

Otherwise, classify the event when the observation window ends.

Only one event is tracked at a time. A new event cannot begin on the same bar that the previous event ends.

⏺️ ทำงานอย่างไร?

สร้างกรอบจากราคาสูงสุด–ต่ำสุดของ 20 แท่งก่อนหน้า โดยไม่รวมแท่งปัจจุบัน

เริ่มเหตุการณ์เมื่อราคาปิดหลุดกรอบ และราคาปิดแท่งก่อนหน้ายังอยู่ในกรอบเดียวกัน

ตรึงขอบกรอบ และใช้ราคาปิดแท่ง Breakout เป็นจุดเริ่มวัด

ติดตาม 5 แท่งปิดถัดไปตามค่าเริ่มต้น

จบก่อนกำหนดหากราคาปิดกลับถึงหรือข้ามขอบ Breakout เดิม

หากยังอยู่นอกกรอบ ให้ประเมินผลเมื่อครบช่วงติดตาม

ระบบติดตามครั้งละหนึ่งเหตุการณ์ และไม่เริ่มเหตุการณ์ใหม่ในแท่งเดียวกับที่เหตุการณ์เดิมจบ

ไม่นับแท่ง Breakout เป็นหนึ่งใน 5 แท่งติดตาม

⏺️ How is the score calculated?

Directional Efficiency compares positive net progress in the breakout direction with the sum of absolute close-to-close changes after the breakout close.

Giveback measures the fraction of peak forward progress that has been surrendered.

Quality Score = Directional Efficiency × (1 − Giveback / 100)

Example:

🔹 Cumulative close movement = 10 points
🔹 Net forward progress = 2 points
🔹 Directional Efficiency = 20%
🔹 Peak forward progress = 4 points
🔹 Giveback = 50%
🔹 Quality Score = 10

If price makes no positive forward progress, giveback is defined as 100%. If it returns across the breakout boundary, the final score is set to zero.

⏺️ คำนวณคะแนนอย่างไร?

Directional Efficiency เปรียบเทียบระยะเดินหน้าสุทธิในทิศทาง Breakout กับผลรวมระยะเปลี่ยนแปลงของราคาปิดหลังแท่ง Breakout โดยไม่นับระยะถอยเป็นความคืบหน้าบวก

Giveback วัดว่าราคาคืนระยะจากจุดที่เดินหน้าได้ไกลที่สุดไปแล้วกี่ส่วน

Quality Score = Directional Efficiency × (1 − Giveback / 100)

ตัวอย่าง:

🔹 ราคาปิดเคลื่อนที่สะสม 10 จุด
🔹 เดินหน้าสุทธิ 2 จุด
🔹 Directional Efficiency = 20%
🔹 เคยเดินหน้าได้ไกลที่สุด 4 จุด
🔹 Giveback = 50%
🔹 Quality Score = 10

หากไม่เคยเดินหน้าเป็นบวก กำหนด Giveback เป็น 100% หากราคาปิดกลับถึงหรือข้ามขอบ Breakout เดิม คะแนนสุดท้ายจะเป็นศูนย์

ระยะคืนกลับวัดจาก ราคาปิดแท่ง Breakout และจุดสุดขั้วของราคาปิดหลังจากนั้น ไม่ได้วัดจากไส้เทียน

⏺️ How to read the colors

🔹 Blue — an event is being tracked
🔹 Green — completed upward event meeting the quality thresholds
🔹 Red — completed downward event meeting the quality thresholds
🔹 Gold — completed event remaining outside the range with weak follow-through
🔹 Gray — returned across the breakout boundary, or no completed result

Default quality requirements:

🔹 Positive net progress in the breakout direction
🔹 Directional Efficiency ≥ 60%
🔹 Giveback ≤ 30%

Color classification uses these individual conditions, rather than a single Quality Score threshold.

⏺️ อ่านสีอย่างไร?

🔹 น้ำเงิน — กำลังติดตามเหตุการณ์
🔹 เขียว — Breakout ขึ้นที่ประเมินเสร็จและผ่านเกณฑ์คุณภาพ
🔹 แดง — Breakout ลงที่ประเมินเสร็จและผ่านเกณฑ์คุณภาพ
🔹 ทอง — ครบช่วงติดตามแล้วยังอยู่นอกกรอบ แต่การเดินหน้าไม่ผ่านเกณฑ์
🔹 เทา — ราคากลับถึงหรือข้ามขอบ Breakout เดิม หรือยังไม่มีผลประเมิน

เกณฑ์คุณภาพตามค่าเริ่มต้น:

🔹 เดินหน้าสุทธิในทิศทาง Breakout เป็นบวก
🔹 Directional Efficiency ≥ 60%
🔹 Giveback ≤ 30%

สีพิจารณาจากเงื่อนไขเหล่านี้แยกกัน ไม่ได้ใช้เกณฑ์คะแนนรวมเพียงตัวเดียว

สีแดงหมายถึงการเดินหน้าลงที่ผ่านเกณฑ์ ไม่ได้หมายถึงสัญญาณผิดพลาด

⏺️ How to use it

🔹 Watch the blue start marker to identify a new tracked event
🔹 Follow the frozen boundaries and breakout-close reference
🔹 Read the completed marker together with the dashboard
🔹 Compare efficiency and giveback across events using consistent settings
🔹 Combine the result with broader trend and price-structure analysis

The latest completed result remains visible until another event begins. It is a retained historical result, not a new signal on every subsequent bar.

⏺️ วิธีใช้งาน

🔹 ดูเครื่องหมาย Start สีน้ำเงินเพื่อระบุจุดเริ่มเหตุการณ์
🔹 ติดตามขอบกรอบที่ตรึงไว้และระดับราคาปิดแท่ง Breakout
🔹 อ่านเครื่องหมายผลประเมินร่วมกับ Dashboard
🔹 เปรียบเทียบประสิทธิภาพและระยะคืนกลับโดยใช้ค่าตั้งเดียวกัน
🔹 ใช้ประกอบการอ่านแนวโน้มและโครงสร้างราคา

ผลล่าสุดจะคงอยู่จนเริ่มเหตุการณ์ใหม่ จึงเป็น ผลของเหตุการณ์ที่ผ่านมา ไม่ใช่สัญญาณใหม่ทุกแท่ง

⏺️ Dashboard and default settings

Dashboard:

🔹 Event status and direction
🔹 Closed bars observed after the breakout
🔹 Net progress and cumulative close movement
🔹 Directional Efficiency
🔹 Giveback
🔹 Quality Score

Defaults:

🔹 Prior Range — 20 bars
🔹 Observation Window — 5 bars after the breakout
🔹 Minimum Efficiency — 60%
🔹 Maximum Giveback — 30%

Use a standard OHLC or candlestick chart.

⏺️ Dashboard และค่าเริ่มต้น

Dashboard แสดง:

🔹 สถานะและทิศทางเหตุการณ์
🔹 จำนวนแท่งปิดที่ติดตามหลัง Breakout
🔹 ระยะเดินหน้าสุทธิและระยะเคลื่อนไหวสะสม
🔹 Directional Efficiency
🔹 Giveback
🔹 Quality Score

ค่าเริ่มต้น:

🔹 Prior Range — 20 แท่ง
🔹 Observation Window — 5 แท่งหลัง Breakout
🔹 Minimum Efficiency — 60%
🔹 Maximum Giveback — 30%

ใช้กับกราฟ OHLC หรือแท่งเทียนมาตรฐาน

⏺️ Alerts

🔹 Quality up escape
🔹 Quality down escape
🔹 Weak escape
🔹 Returned across boundary
🔹 Any completed event

Alerts occur on the closed bar that completes an event. This version does not apply an additional two-bar confirmation.

Select “Once Per Bar Close” and recreate alerts after changing inputs or code.

⏺️ การแจ้งเตือน

🔹 Quality up escape — เหตุการณ์ขาขึ้นผ่านเกณฑ์คุณภาพ
🔹 Quality down escape — เหตุการณ์ขาลงผ่านเกณฑ์คุณภาพ
🔹 Weak escape — ยังอยู่นอกกรอบ แต่ไม่ผ่านเกณฑ์
🔹 Returned across boundary — กลับถึงหรือข้ามขอบ Breakout เดิม
🔹 Any completed event — แจ้งทุกประเภทเมื่อจบเหตุการณ์

แจ้งเตือนเมื่อแท่งที่จบเหตุการณ์ปิด เวอร์ชันนี้ไม่มีการรอยืนยันเพิ่มอีกสองแท่ง

ตั้ง “Once Per Bar Close” และสร้าง Alert ใหม่หลังเปลี่ยน Input หรือโค้ด

⏺️ Development and references

This Pine Script v6 implementation combines a Donchian-style prior-price range, directional efficiency inspired by Perry Kaufman’s Efficiency Ratio, and event-based retracement measurement.

The extension measures movement within a frozen post-breakout event and adjusts efficiency for lost progress.

No Community script code was copied for this implementation. The underlying channel, efficiency and retracement concepts are established methods; no claim is made that those concepts are new.

References:

🔹 TradingView — Donchian Channels
https://www.tradingview.com/support/solutions/43000502253-donchian-channels-dc/

🔹 TradingView — Kaufman’s Adaptive Moving Average, including Efficiency Ratio
https://www.tradingview.com/support/solutions/43000773012-kaufman-s-adaptive-moving-average-kama/

⏺️ การพัฒนาและอ้างอิง

เขียนด้วย Pine Script v6 โดยผสมกรอบราคาแบบ Donchian หลักการประสิทธิภาพการเคลื่อนที่ที่ต่อยอดจาก Efficiency Ratio ของ Perry Kaufman และการวัดระยะคืนกลับเฉพาะเหตุการณ์

ส่วนที่ต่อยอดคือการตรึงกรอบเมื่อเกิด Breakout วัดการเคลื่อนที่ในช่วงติดตาม และหักคะแนนตามระยะเดินหน้าที่สูญเสียไป

ไม่คัดลอกโค้ดจากสคริปต์ Community สำหรับการพัฒนาครั้งนี้ แนวคิดกรอบราคา ประสิทธิภาพ และการคืนระยะเป็นหลักการที่มีอยู่แล้ว ไม่ได้อ้างว่าเป็นสิ่งประดิษฐ์ใหม่ทั้งหมด

⏺️ Limitations and disclaimer

🔹 Measurements use closing prices and exclude intrabar excursions.
🔹 The breakout jump itself is excluded from the measured path.
🔹 Results depend on the selected range, observation window and thresholds.
🔹 Strong classification describes the completed window and does not predict subsequent continuation.
🔹 Session gaps, continuous-futures rolls and data revisions can affect results.
🔹 Numerical checks have been completed; TradingView compilation and market-data validation remain pending.
🔹 For educational and informational purposes only. No investment advice or return guarantee is provided.

⏺️ ข้อจำกัดและคำชี้แจง

🔹 วัดจากราคาปิด จึงไม่สะท้อนการแกว่งทั้งหมดภายในแท่ง
🔹 ไม่รวมระยะกระโดดของแท่ง Breakout ในเส้นทางที่ใช้ประเมิน
🔹 ผลขึ้นกับจำนวนแท่งของกรอบ ช่วงติดตาม และเกณฑ์ที่เลือก
🔹 การผ่านเกณฑ์บรรยายช่วงที่ประเมินเสร็จ ไม่ได้ทำนายว่าจะเดินหน้าต่อ
🔹 Gap ระหว่าง Session การเปลี่ยนสัญญาในกราฟ Continuous และการแก้ไขข้อมูลอาจกระทบผล
🔹 ตรวจสูตรเชิงตัวเลขแล้ว แต่ยังไม่ได้ compile ใน TradingView หรือทดสอบข้อมูลตลาดจริง
🔹 ใช้เพื่อการศึกษาและประกอบการวิเคราะห์ ไม่ใช่คำแนะนำการลงทุนหรือการรับประกันผลตอบแทน

## Source Code

````pine
//@version=6
// [DAOL] Range Escape Quality v1.0
// Original implementation for this request; no Community script code copied.
// Foundations: Donchian-style prior-price channels and Perry Kaufman's ER.
// https://www.tradingview.com/support/solutions/43000502253-donchian-channels-dc/
// https://www.tradingview.com/support/solutions/43000773012-kaufman-s-adaptive-moving-average-kama/
// This event score is not Kaufman's original ER, a win probability or a trade signal.
// Standard OHLC charts only. All state mutations and alerts use confirmed bars.
// Breakout bar is the origin; observationBars means SUBSEQUENT closed bars.
// Only one event at a time. No new event on the bar an existing event ends.
// The latest completed result persists until a new breakout begins.
// Numerical validation only; TradingView compilation/market validation pending.
indicator("[DAOL] Range Escape Quality", shorttitle="DAOL Escape", overlay=true, max_bars_back=1000)

int rangeBars = input.int(20, "Prior range bars", minval=2, maxval=500, group="Event")
int observationBars = input.int(5, "Closed bars after breakout", minval=1, maxval=100, group="Event")
float minEfficiency = input.float(60.0, "Minimum directional efficiency (%)", minval=0, maxval=100, step=5, group="Quality")
float maxGiveback = input.float(30.0, "Maximum giveback (%)", minval=0, maxval=100, step=5, group="Quality")
bool showLive = input.bool(true, "Show prior rolling range", group="Display")
bool showFrozen = input.bool(true, "Show frozen event range", group="Display")
bool showMarkers = input.bool(true, "Show event markers", group="Display")
bool showDashboard = input.bool(true, "Show dashboard", group="Display")

if barstate.isfirst and not chart.is_standard
    runtime.error("Use a standard OHLC/candlestick chart.")

float upper = ta.highest(high[1], rangeBars)
float lower = ta.lowest(low[1], rangeBars)
bool enough = bar_index >= rangeBars and not na(upper) and not na(lower) and upper > lower

var bool active = false
var int direction = 0
var int elapsed = 0
var float frozenUpper = na
var float frozenLower = na
var float origin = na
var float previousClose = na
var float path = 0.0
var float peakProgress = 0.0
var float progress = na
var float efficiency = na
var float giveback = na
var float score = na
// Result: 0 none, 1 quality up, -1 quality down, 2 weak, 3 returned.
var int result = 0
var string status = "Waiting for breakout"

bool startedUp = false
bool startedDown = false
bool completed = false
bool qualityUp = false
bool qualityDown = false
bool weakResult = false
bool returnedResult = false

if barstate.isconfirmed
    if active
        elapsed += 1
        path += math.abs(close - previousClose)
        previousClose := close
        progress := direction * (close - origin)
        peakProgress := math.max(peakProgress, progress)
        // Directional ER clips adverse net progress to zero.
        efficiency := path > 0 ? 100.0 * math.max(progress, 0.0) / path : 0.0
        efficiency := math.min(100.0, efficiency)
        // Peak is measured from the breakout CLOSE, not the old range boundary.
        // No positive progress means 100% giveback by explicit convention.
        giveback := peakProgress > 0 ? 100.0 * (peakProgress - math.max(progress, 0.0)) / peakProgress : 100.0
        giveback := math.max(0.0, math.min(100.0, giveback))
        score := efficiency * (1.0 - giveback / 100.0)
        bool returned = direction == 1 ? close <= frozenUpper : close >= frozenLower
        if returned or elapsed >= observationBars
            active := false
            completed := true
            if returned
                result := 3
                score := 0.0
                status := "Returned across breakout boundary"
                returnedResult := true
            else if progress > 0 and efficiency >= minEfficiency and giveback <= maxGiveback
                result := direction
                status := direction == 1 ? "Quality up escape" : "Quality down escape"
                qualityUp := direction == 1
                qualityDown := direction == -1
            else
                result := 2
                status := "Outside / weak follow-through"
                weakResult := true
        else
            status := "Tracking closed bars"
    else if enough
        // Previous close must be within the CURRENT prior range.
        // This avoids treating every bar already beyond a rolling edge as a new escape.
        bool wasInside = close[1] <= upper and close[1] >= lower
        int newDirection = wasInside and close > upper ? 1 : wasInside and close < lower ? -1 : 0
        if newDirection != 0
            active := true
            direction := newDirection
            elapsed := 0
            frozenUpper := upper
            frozenLower := lower
            origin := close
            previousClose := close
            path := 0.0
            peakProgress := 0.0
            progress := 0.0
            efficiency := na
            giveback := na
            score := na
            result := 0
            status := "Tracking closed bars"
            startedUp := direction == 1
            startedDown := direction == -1

color eventColor = active ? color.blue : result == 1 ? color.lime : result == -1 ? color.red : result == 2 ? color.rgb(212, 175, 55) : color.gray
plot(showLive and enough ? upper : na, "Prior range high", color=color.new(color.gray, 65), style=plot.style_stepline)
plot(showLive and enough ? lower : na, "Prior range low", color=color.new(color.gray, 65), style=plot.style_stepline)
// Hide reset bar to avoid a sloping connection between different frozen ranges.
bool resetBar = startedUp or startedDown
plot(showFrozen and not resetBar ? frozenUpper : na, "Frozen range high", color=eventColor, linewidth=2, style=plot.style_linebr)
plot(showFrozen and not resetBar ? frozenLower : na, "Frozen range low", color=eventColor, linewidth=2, style=plot.style_linebr)
plot(showFrozen and not resetBar ? origin : na, "Breakout close origin", color=color.new(eventColor, 40), style=plot.style_linebr)
plot(score, "Quality score (0-100)", display=display.data_window)
plot(efficiency, "Directional efficiency (%)", display=display.data_window)
plot(giveback, "Giveback (%)", display=display.data_window)
plotshape(showMarkers and startedUp, title="Up breakout starts", style=shape.triangleup, location=location.belowbar, color=color.blue, size=size.tiny, text="Start")
plotshape(showMarkers and startedDown, title="Down breakout starts", style=shape.triangledown, location=location.abovebar, color=color.blue, size=size.tiny, text="Start")
plotshape(showMarkers and qualityUp, title="Quality up completed", style=shape.circle, location=location.belowbar, color=color.lime, size=size.small, text="Q")
plotshape(showMarkers and qualityDown, title="Quality down completed", style=shape.circle, location=location.abovebar, color=color.red, size=size.small, text="Q")
plotshape(showMarkers and weakResult, title="Weak escape completed", style=shape.diamond, location=location.abovebar, color=color.rgb(212, 175, 55), size=size.tiny, text="Weak")
plotshape(showMarkers and returnedResult, title="Returned across edge", style=shape.xcross, location=location.abovebar, color=color.gray, size=size.tiny, text="Back")

f_number(float value) =>
    na(value) ? "--" : str.tostring(value, "#.0")

var table dashboard = table.new(position.top_right, 2, 9, border_width=1)
if barstate.islast and showDashboard
    table.cell(dashboard, 0, 0, "DAOL Escape Quality", text_color=color.white, bgcolor=color.rgb(19, 62, 103))
    table.cell(dashboard, 1, 0, active ? "LIVE EVENT" : result == 0 ? "WAITING" : "LAST RESULT", text_color=color.white, bgcolor=eventColor)
    table.cell(dashboard, 0, 1, "Status")
    table.cell(dashboard, 1, 1, status)
    table.cell(dashboard, 0, 2, "Direction")
    table.cell(dashboard, 1, 2, direction == 1 ? "Up" : direction == -1 ? "Down" : "--")
    table.cell(dashboard, 0, 3, "Bars after breakout")
    table.cell(dashboard, 1, 3, str.tostring(elapsed) + " / " + str.tostring(observationBars))
    table.cell(dashboard, 0, 4, "Net progress (price)")
    table.cell(dashboard, 1, 4, na(progress) ? "--" : str.tostring(progress, format.mintick))
    table.cell(dashboard, 0, 5, "Close path (price)")
    table.cell(dashboard, 1, 5, str.tostring(path, format.mintick))
    table.cell(dashboard, 0, 6, "Efficiency (%)")
    table.cell(dashboard, 1, 6, f_number(efficiency))
    table.cell(dashboard, 0, 7, "Giveback (%)")
    table.cell(dashboard, 1, 7, f_number(giveback))
    table.cell(dashboard, 0, 8, "Quality (0-100)")
    table.cell(dashboard, 1, 8, f_number(score), bgcolor=color.new(eventColor, 75))

alertcondition(qualityUp, "DAOL: Quality up escape", "[DAOL] Range Escape Quality: upward event completed with quality thresholds met. {{ticker}} {{interval}}")
alertcondition(qualityDown, "DAOL: Quality down escape", "[DAOL] Range Escape Quality: downward event completed with quality thresholds met. {{ticker}} {{interval}}")
alertcondition(weakResult, "DAOL: Weak escape", "[DAOL] Range Escape Quality: event completed outside the range with weak follow-through. {{ticker}} {{interval}}")
alertcondition(returnedResult, "DAOL: Returned across boundary", "[DAOL] Range Escape Quality: close returned across the frozen breakout boundary. {{ticker}} {{interval}}")
alertcondition(completed, "DAOL: Any completed event", "[DAOL] Range Escape Quality: an event completed. {{ticker}} {{interval}}")

// Reading/limitations:
// Default quality: positive progress, efficiency >=60%, giveback <=30%.
// Score = directional efficiency * retained fraction of peak progress.
// Returning to/touching the breakout edge ends immediately with score zero;
// a gap through the entire range also counts as a return across that edge.
// Price path uses closes only, excludes intrabar excursions and breakout jump.
// Blue = tracking; green/red = completed quality; gold = completed weak;
// gray = returned/no result. A retained result is not a fresh signal each bar.
// Fixed horizon means output delay; no additional two-bar confirmation.
// Continuous-futures rolls, session gaps and revised data can affect results.
// Set alerts Once Per Bar Close; recreate after changing code or inputs.
// Educational context only; no profitability or originality-of-basics claim.
````

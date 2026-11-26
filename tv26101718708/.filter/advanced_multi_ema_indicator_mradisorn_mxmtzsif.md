# Advanced Multi EMA Indicator Mr.Adisorn

- url: https://www.tradingview.com/script/MxmTzSIF/
- type: indicator
- pine_id: PUB;9aee64e9df524b6b8f6cee7c8e67634d
- version: 1.0

## Description

นี่คือคำอธิบายการทำงานของเครื่องมือ Advanced Multi EMA Indicator (เวอร์ชัน Pine Script v5) เพื่อให้คุณนำไปใช้ประกอบคอนเทนต์หรือคู่มือการใช้งานครับ

🛠 เจาะลึกเครื่องมือ: Advanced Multi EMA Indicator
เครื่องมือนี้คือตัวช่วยวิเคราะห์แนวโน้ม (Trend) และจุดกลับตัวของราคาที่ทรงพลัง โดยการรวมค่าเฉลี่ยเคลื่อนที่ถึง 4 ระยะเข้าด้วยกัน พร้อมระบบทัศนสัญญาณ (Visual Signals) ที่ดูง่ายและชัดเจน

1. ระบบ Moving Average 4 ระยะ (Customizable Periods)
คุณสามารถปรับแต่งระยะเวลา (Period) ของเส้นค่าเฉลี่ยได้อิสระถึง 4 เส้น เพื่อวิเคราะห์แนวโน้มตั้งแต่ระยะสั้นไปจนถึงระยะยาว:

MA 1 (Default 9): สำหรับดูโมเมนตัมระยะสั้น

MA 2 (Default 26): สำหรับยืนยันแนวโน้มระยะกลาง

MA 3 (Default 100): สำหรับดูภาพรวมแนวโน้มหลัก

MA 4 (Default 200): เส้นแนวรับ-แนวต้านทางจิตวิทยาที่สำคัญที่สุด

2. ความยืดหยุ่นสูง (Flexible MA Types)
ไม่ได้จำกัดแค่ EMA เท่านั้น แต่คุณสามารถเลือกประเภทของ Moving Average ได้ตามความถนัดของกลยุทธ์:

EMA (Exponential): ตอบสนองต่อราคาปัจจุบันได้รวดเร็ว เหมาะกับสาย Scalping

SMA (Simple): ให้ค่าเฉลี่ยที่สมูทและนิ่งกว่า เหมาะกับการดูเทรนด์ภาพใหญ่

VWMA (Volume Weighted): คำนวณโดยให้น้ำหนักกับปริมาณการซื้อขาย (Volume) เพื่อความแม่นยำในจุดที่มีนัยสำคัญ

3. ระบบ Visual Dashboard บนหน้ากราฟ
EMA Area Background: มีการระบายสีระหว่างช่องว่างของเส้น MA (Ribbon) ช่วยให้มองเห็นสภาวะเทรนด์ที่แข็งแกร่งหรือการบีบตัวของราคา (Squeeze) ได้ทันที

Crossover Arrows: ระบบจะวาด "ลูกศร" บนกราฟโดยอัตโนมัติเมื่อมีการตัดกันของเส้น MA (Golden Cross / Death Cross) ทำให้คุณไม่พลาดทุกจุดเปลี่ยนของเทรนด์

Custom Colors & Display: ปรับสี ความหนาเส้น และความโปร่งใสของพื้นที่สีได้ตามใจชอบ เพื่อให้เข้ากับ Template กราฟของคุณ

4. ระบบการแจ้งเตือนอัจฉริยะ (Smart Alerts)
รองรับการตั้งค่า Alertcondition เมื่อเส้น MA ตัดกันในแต่ละคู่:

แจ้งเตือนเมื่อระยะสั้นตัดระยะกลาง (สัญญาณเข้าทำกำไรไว)

แจ้งเตือนเมื่อระยะกลางตัดระยะยาว (สัญญาณเปลี่ยนเทรนด์ใหญ่)

✅ สรุปจุดเด่น
เครื่องมือนี้ถูกออกแบบมาเพื่อ "ลดการใช้สายตา" ในการจ้องกราฟ โดยใช้ AI และ Logic ในการคำนวณหาจุดตัดที่สำคัญแทนคุณ เหมาะสำหรับทั้งมือใหม่ที่ต้องการระบบช่วยดูเทรนด์ และมือโปรที่ต้องการความรวดเร็วในการวิเคราะห์หลายคู่เงินพร้อมกันครับ!

## Source Code

````pine
//@version=5
indicator("Advanced Multi EMA Indicator", overlay=true, max_boxes_count=500, max_lines_count=500)

// ============================================
// ตั้งค่าพารามิเตอร์หลัก
// ============================================

// คำตั้งค่า EMA Periods
ema1_period = input.int(9, title="EMA Period 1", minval=1, maxval=500, group="EMA Settings")
ema2_period = input.int(26, title="EMA Period 2", minval=1, maxval=500, group="EMA Settings")
ema3_period = input.int(100, title="EMA Period 3", minval=1, maxval=500, group="EMA Settings")
ema4_period = input.int(200, title="EMA Period 4", minval=1, maxval=500, group="EMA Settings")

// เลือกประเภท Moving Average
ma_type = input.string("EMA", title="Moving Average Type", 
     options=["SMA", "EMA", "VWMA"], group="EMA Settings")

// ============================================
// ตั้งค่าสี
// ============================================
color1 = input.color(color.blue, title="EMA 1 Color", group="Colors")
color2 = input.color(color.orange, title="EMA 2 Color", group="Colors")
color3 = input.color(color.green, title="EMA 3 Color", group="Colors")
color4 = input.color(color.red, title="EMA 4 Color", group="Colors")

// ============================================
// ตั้งค่าการแสดงผล
// ============================================
show_lines = input.bool(true, title="Show EMA Lines", group="Display")
show_area = input.bool(true, title="Show EMA Area", group="Display")
show_crossovers = input.bool(true, title="Show Crossover Arrows", group="Display")
area_transparency = input.int(80, title="Area Transparency", minval=0, maxval=100, group="Display")
line_width = input.int(2, title="Line Width", minval=1, maxval=5, group="Display")

// ============================================
// ฟังก์ชันคำนวณ Moving Average
// ============================================
f_ma(source, period, type) =>
    if type == "SMA"
        ta.sma(source, period)
    else if type == "EMA"
        ta.ema(source, period)
    else if type == "VWMA"
        ta.vwma(source, period)
    else
        ta.ema(source, period)

// ============================================
// คำนวณ MA ทั้ง 4 ตำแหน่ง
// ============================================
ma1 = f_ma(close, ema1_period, ma_type)
ma2 = f_ma(close, ema2_period, ma_type)
ma3 = f_ma(close, ema3_period, ma_type)
ma4 = f_ma(close, ema4_period, ma_type)

// ============================================
// แสดงเส้น MA
// ============================================
p1 = plot(show_lines ? ma1 : na, color=color1, linewidth=line_width, title="MA 1")
p2 = plot(show_lines ? ma2 : na, color=color2, linewidth=line_width, title="MA 2")
p3 = plot(show_lines ? ma3 : na, color=color3, linewidth=line_width, title="MA 3")
p4 = plot(show_lines ? ma4 : na, color=color4, linewidth=line_width, title="MA 4")

// ============================================
// สร้าง Area ระหว่าง MA
// ============================================
fill(p1, p2, color=show_area ? color.new(color1, area_transparency) : na, title="Area MA1-MA2")
fill(p2, p3, color=show_area ? color.new(color2, area_transparency) : na, title="Area MA2-MA3")
fill(p3, p4, color=show_area ? color.new(color3, area_transparency) : na, title="Area MA3-MA4")

// ============================================
// ตรวจจับ Crossover
// ============================================

// ครอสโอเวอร์ MA1 และ MA2
ma1_cross_ma2_up = ta.crossover(ma1, ma2)
ma1_cross_ma2_down = ta.crossunder(ma1, ma2)

// ครอสโอเวอร์ MA2 และ MA3
ma2_cross_ma3_up = ta.crossover(ma2, ma3)
ma2_cross_ma3_down = ta.crossunder(ma2, ma3)

// ครอสโอเวอร์ MA3 และ MA4
ma3_cross_ma4_up = ta.crossover(ma3, ma4)
ma3_cross_ma4_down = ta.crossunder(ma3, ma4)

// ============================================
// วาดลูกศร Crossover
// ============================================

// MA1 x MA2
plotshape(show_crossovers and ma1_cross_ma2_up, style=shape.arrowup, location=location.belowbar, 
         color=color.new(color.green, 0), title="MA1 ↑ MA2", offset=-1)
plotshape(show_crossovers and ma1_cross_ma2_down, style=shape.arrowdown, location=location.abovebar, 
         color=color.new(color.red, 0), title="MA1 ↓ MA2", offset=-1)

// MA2 x MA3
plotshape(show_crossovers and ma2_cross_ma3_up, style=shape.arrowup, location=location.belowbar, 
         color=color.new(color.lime, 0), title="MA2 ↑ MA3", offset=-2)
plotshape(show_crossovers and ma2_cross_ma3_down, style=shape.arrowdown, location=location.abovebar, 
         color=color.new(color.maroon, 0), title="MA2 ↓ MA3", offset=-2)

// MA3 x MA4
plotshape(show_crossovers and ma3_cross_ma4_up, style=shape.arrowup, location=location.belowbar, 
         color=color.new(color.aqua, 0), title="MA3 ↑ MA4", offset=-3)
plotshape(show_crossovers and ma3_cross_ma4_down, style=shape.arrowdown, location=location.abovebar, 
         color=color.new(color.fuchsia, 0), title="MA3 ↓ MA4", offset=-3)

// ============================================
// สัญญาณเตือน (Alerts)
// ============================================
alertcondition(ma1_cross_ma2_up, title="MA1 Cross Above MA2", message="MA1 crossed ABOVE MA2")
alertcondition(ma1_cross_ma2_down, title="MA1 Cross Below MA2", message="MA1 crossed BELOW MA2")
alertcondition(ma2_cross_ma3_up, title="MA2 Cross Above MA3", message="MA2 crossed ABOVE MA3")
alertcondition(ma2_cross_ma3_down, title="MA2 Cross Below MA3", message="MA2 crossed BELOW MA3")
alertcondition(ma3_cross_ma4_up, title="MA3 Cross Above MA4", message="MA3 crossed ABOVE MA4")
alertcondition(ma3_cross_ma4_down, title="MA3 Cross Below MA4", message="MA3 crossed BELOW MA4")
````

# Trading Value

- url: https://www.tradingview.com/script/ujZVV3x5-Trading-Value/
- type: indicator
- pine_id: PUB;1b7a22a0d77146a1a6d58aad28c77cd6
- version: 1.0

## Description

[ Trading Value ]

[1] Overview
อินดิเคเตอร์ตัวนี้ออกแบบมาเพื่อติดตาม "มูลค่าการซื้อขาย"
Value = Volume × ราคาเฉลี่ย OHLC4 ในแต่ละแท่งเทียน
ช่วยให้เห็นขนาดของเม็ดเงินที่ไหลเข้าหรือออกอย่างแท้จริง
พร้อมเส้นค่าเฉลี่ย (MA) เพื่อใช้วิเคราะห์โมเมนตัมของกระแสเงิน

.

[2] องค์ประกอบและการทำงาน
1. แท่งมูลค่าการซื้อขาย (Value Columns)
1a) หากมูลค่าในแท่งนั้นสูงกว่าเส้น Initial MA แท่งจะแสดงเป็นสีเทาเข้ม
บ่งบอกถึงเม็ดเงินที่เข้ามาหนาแน่นกว่าค่าเฉลี่ยระยะสั้น
1b) หากมูลค่าน้อยกว่าเส้น Initial MA แท่งจะแสดงเป็นสีเทาอ่อน
บ่งบอกถึงเม็ดเงินที่เข้ามาลดลงจากค่าเฉลี่ยระยะสั้น

2. เส้นค่าเฉลี่ย (Moving Averages)
สามารถปรับเลือกประเภทได้ระหว่าง SMA และ EMA
2a) Initial MA (สีเขียว, ค่าเริ่มต้น 10): ใช้ประเมินเกณฑ์มาตรฐานระยะสั้น
2b) Fast MA (สีส้ม, ค่าเริ่มต้น 20): ใช้ดูแนวโน้มโมเมนตัมระยะกลาง
2c) Slow MA (สีฟ้า, ค่าเริ่มต้น 50): ใช้ดูแนวโน้มระยะยาว

-----------------------------------------------

[ Trading Value ]

[1] Overview
This indicator is designed to track the "Trading Value"
(Value = Volume × OHLC4 average price) for each candlestick.
It reveals the actual magnitude of money flowing in or out,
alongside Moving Averages (MA) to analyze money flow momentum.

[2] Components and Functions

1. Value Columns
1a) If the value in the bar is higher than the Initial MA, the column will display in dark gray,
indicating a higher concentration of money inflow compared to the short-term average.
1b) If the value is lower than the Initial MA, the column will display in light gray,
indicating a decrease in money inflow compared to the short-term average.

2. Moving Averages
The MA type can be selected between SMA and EMA.
2a) Initial MA (Green, default 10): Used to evaluate the short-term baseline.
2b) Fast MA (Orange, default 20): Used to observe mid-term momentum trends.
2c) Slow MA (Cyan, default 50): Used to observe long-term trends.

## Source Code

````pine
//@version=6
indicator("Trading Value", overlay=false, format=format.volume)

// --- 1. คำนวณ Value ---
value = volume * ohlc4

// --- 2. การตั้งค่า MA (Input) ---
ma_type        = input.string("SMA", "MA Type", options=["SMA", "EMA"], group="Value MA")
initial_length = input.int(10, "Initial MA Length", minval=1, group="Value MA")
fast_length    = input.int(20, "Fast MA Length", minval=1, group="Value MA")
slow_length    = input.int(50, "Slow MA Length", minval=1, group="Value MA")

// --- 3. ฟังก์ชันคำนวณเส้นค่าเฉลี่ย ---
get_ma(src, len, type) =>
    type == "EMA" ? ta.ema(src, len) : ta.sma(src, len)

initial_ma = get_ma(value, initial_length, ma_type)
fast_ma    = get_ma(value, fast_length, ma_type)
slow_ma    = get_ma(value, slow_length, ma_type)

// --- 4. การจัดการสี ---
initial_color = color.new(#46af49, 0)
fast_color    = color.new(#ff9900, 0)
slow_color    = color.new(color.aqua, 0)
value_color   = value > initial_ma ? color.rgb(104, 108, 109) : color.rgb(212, 215, 224)

// --- 5. การพล็อตข้อมูลลงกราฟ ---
plot_initial = plot(initial_ma, "Initial MA", color=initial_color, style=plot.style_line)
plot_fast    = plot(fast_ma, "Fast MA", color=fast_color, style=plot.style_line)
plot_slow    = plot(slow_ma, "Slow MA", color=slow_color, style=plot.style_line, linewidth=2, display=display.none)
plot_value   = plot(value, "Value", style=plot.style_columns, color=value_color)
````

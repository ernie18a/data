# F24 Block Trade Momentum & Entry Scouter

- url: https://www.tradingview.com/script/p5qbGNAK/
- type: indicator
- pine_id: PUB;26cc7cd738524bb4896d0c62e119c3f9
- version: 1.0

## Description

คอนเซปต์ของ **Volume Profile (POC), Trend (EMA), Momentum (Stoch RSI) และ Volatility (ATR)** มาประกอบกันเพื่อหาจุดเข้าและจุดออกที่ชัดเจนครับ
รายละเอียดการอ่านค่าและใช้งานแต่ละส่วน มีดังนี้ครับ:
### 1. เส้นประแนวนอนสีส้ม: Dynamic POC (Point of Control)
เส้นนี้คือหัวใจหลักในการแบ่งโซน "กระทิง" และ "หมี" ของระบบนี้
 * **การคำนวณ:** ระบบจะจำลองหาแท่งเทียนที่มี Volume หนาแน่นที่สุดในรอบ 200 แท่งล่าสุด แล้วดึงราคาเฉลี่ย (HL2) ของแท่งนั้นมาตีเป็นเส้นแนวนอน
 * **การอ่านค่า:** ทำหน้าที่เป็นแนวรับ/แนวต้านที่มีนัยสำคัญระดับ "เจ้ามือ" หรือรายใหญ่
   * **ถ้าราคายืน "เหนือ" เส้นสีส้ม:** แปลว่ารายใหญ่ที่สะสมของไว้กำลังอยู่ในฝั่งกำไร และมีโอกาสดันราคาขึ้นต่อได้ (มองฝั่ง Buy)
   * **ถ้าราคาอยู่ "ใต้" เส้นสีส้ม:** แปลว่าโมเมนตัมหลักอ่อนแอและถูกควบคุมโดยฝั่งขาย (มองฝั่ง Sell/Short)
### 2. ป้าย BUY สีเขียว (จุดเข้าซื้อแบบ Buy on Dip)
สัญญาณซื้อจะแสดงเป็นรูปสามเหลี่ยมสีเขียวใต้แท่งเทียน โดยจะเกิดขึ้นก็ต่อเมื่อเงื่อนไขทั้งหมดนี้สอดคล้องกัน (Confluence):
 1. **Trend:** หุ้นต้องอยู่ในเทรนด์ขาขึ้น (อ้างอิงจากเส้น EMA 9 ตัด EMA 21 ขึ้นไป)
 2. **Zone:** ราคาปัจจุบันต้องยืน **เหนือ** เส้นประสีส้ม (Dynamic POC)
 3. **Momentum:** อินดิเคเตอร์ Stoch RSI ลงมาพักตัวในโซนล่าง (Oversold) และกำลังม้วนตัวตัดเส้น 20 ขึ้นไป
 * **วิธีการเข้า:** เมื่อเกิดป้าย BUY สามารถพิจารณาเข้าซื้อ (Long) ที่ราคาเปิดของแท่งถัดไป หรือตั้งรอรับที่แนวรับใกล้เคียง
### 3. ป้าย SELL สีแดง (จุดเข้า Short หรือ ขายทำกำไรแบบ Short on Bounce)
สัญญาณขายจะแสดงเป็นรูปสามเหลี่ยมสีแดงเหนือแท่งเทียน ใช้สำหรับเล่นฝั่ง Short หรือใช้หนีเมื่อจบรอบ:
 1. **Trend:** หุ้นอยู่ในเทรนด์ขาลง
 2. **Zone:** ราคาปัจจุบันอยู่ **ใต้** เส้นประสีส้ม (Dynamic POC)
 3. **Momentum:** อินดิเคเตอร์ Stoch RSI เด้งขึ้นไปในโซนบน (Overbought) และกำลังม้วนตัวตัดเส้น 80 ลงมา
 * **วิธีการเข้า:** เมื่อเกิดป้าย SELL เป็นสัญญาณให้พิจารณาเปิดสถานะ Short หรือขายทำกำไรหุ้นที่ถืออยู่
### 4. จุดไข่ปลา Stop Loss (คำนวณความผันผวนจาก ATR)
ระบบนี้มีการตั้งจุดตัดขาดทุน (Stop Loss) แบบอัตโนมัติ (Trailing / Volatility Stop) ซึ่งอิงจากค่า ATR (Average True Range) ทำให้จุด Stop Loss ยืดหยุ่นตามความผันผวนของตลาดในขณะนั้น
 * **ฝั่ง BUY (จุดไข่ปลาสีแดง):** เมื่อมีป้าย BUY เกิดขึ้น จะมีจุดไข่ปลาสีแดงโผล่ขึ้นมาด้านล่าง คำนวณจากสูตร: **Low ของแท่งก่อนหน้า - (1.5 * ค่า ATR)** นี่คือจุดที่คุณต้องตั้ง Stop Loss ทันทีเมื่อเข้าออเดอร์
 * **ฝั่ง SELL/Short (จุดไข่ปลาสีเขียว):** เมื่อมีป้าย SELL เกิดขึ้น จะมีจุดไข่ปลาสีเขียวโผล่ขึ้นมาด้านบน คำนวณจากสูตร: **High ของแท่งก่อนหน้า + (1.5 * ค่า ATR)** ใช้เป็นจุด Stop Loss สำหรับไม้ Short
**💡 ข้อสังเกตเพิ่มเติม (ตารางมุมขวาบน)**
บนหน้าจอมีการทำ Dashboard สรุปสถานะของหุ้นตัวนั้นๆ ไว้ให้อ่านง่ายๆ ด้วย:
 * **Price vs POC:** บอกสถานะปัจจุบันว่าราคาอยู่ใต้ (BELOW) หรือเหนือ (ABOVE) เส้นสะสมของรายใหญ่
 * **Trend (EMA 9/21):** สรุปเทรนด์ปัจจุบัน (เช่น UPTREND)
 * **Volatility (ATR):** บอกความผันผวนปัจจุบัน (เช่น 0.77 บาท) เพื่อให้ทราบว่าหุ้นสวิงแรงแค่ไหน
ถือว่าเป็นระบบที่นำมาใช้จับจังหวะสวิงเทรด (Swing Trade) ในกรอบย่อซื้อ-เด้งขาย (Buy on Dip / Short on Bounce) ได้อย่างมีประสิทธิภาพและมีตรรกะรองรับครบถ้วนครับ

ดาวน์โหลด Outlook for iOS

## Source Code

````pine
// @version=6
indicator("Block Trade Momentum & Entry Scouter", overlay=true, max_labels_count=500)

// ==========================================
// 1. INPUT SETTINGS (ตั้งค่าพารามิเตอร์)
// ==========================================
// -- Trend Settings --
emaFastLen = input.int(9, "EMA Fast (Trend)", group="Trend Options")
emaSlowLen = input.int(21, "EMA Slow (Trend)", group="Trend Options")

// -- Volume Profile Settings --
vpLen = input.int(200, "Volume Profile Lookback", tooltip="จำนวนแท่งเทียนสำหรับหา POC", group="Volume Profile Options")

// -- StochRSI Settings (Entry Trigger) --
rsiLen   = input.int(14, "RSI Length", group="StochRSI Options")
stochLen = input.int(14, "Stoch Length", group="StochRSI Options")
smoothK  = input.int(3, "Stoch %K Smoothing", group="StochRSI Options")
smoothD  = input.int(3, "Stoch %D Smoothing", group="StochRSI Options")
obLevel  = input.int(80, "Overbought Level", group="StochRSI Options")
osLevel  = input.int(20, "Oversold Level", group="StochRSI Options")

// -- Volatility & Stop Loss Settings --
atrLen   = input.int(14, "ATR Length", group="Risk Management")
atrMult  = input.float(1.5, "ATR Multiplier (for SL)", step=0.1, group="Risk Management")

// ==========================================
// 2. CALCULATIONS (ตรรกะการคำนวณ)
// ==========================================
// -- Trend (EMA) --
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

// -- Volatility (ATR) --
atrValue = ta.atr(atrLen)

// -- Stochastic RSI (Entry Timing) --
rsi = ta.rsi(close, rsiLen)
stoch = ta.stoch(rsi, rsi, rsi, stochLen)
k = ta.sma(stoch, smoothK)
d = ta.sma(k, smoothD)

// -- Dynamic POC (จำลองโซน Volume หนาแน่นที่สุด) --
// หาราคาที่มีปริมาณการซื้อขายสูงสุดในรอบ vpLen (Lookback Period)
highestVol = ta.highest(volume, vpLen)
pocPrice   = ta.valuewhen(volume == highestVol, hl2, 0)

// ==========================================
// 3. TRADING LOGIC (เงื่อนไขจุดเข้า)
// ==========================================
// ตรวจสอบเทรนด์
uptrend   = emaFast > emaSlow
downtrend = emaFast < emaSlow

// BUY Condition: เทรนด์ขึ้น + ราคา > POC + StochRSI(K) ตัด 20 ขึ้นไป
buyCond = uptrend and (close > pocPrice) and ta.crossover(k, osLevel)

// SELL Condition: เทรนด์ลง + ราคา < POC + StochRSI(K) ตัด 80 ลงมา
sellCond = downtrend and (close < pocPrice) and ta.crossunder(k, obLevel)

// คำนวณ Stop Loss ณ จุดที่เกิดสัญญาณ (ดึงค่าจาก Low/High แท่งก่อนหน้า)
var float longSL = na
var float shortSL = na

if buyCond
    longSL := low[1] - (atrValue * atrMult)
if sellCond
    shortSL := high[1] + (atrValue * atrMult)

// ==========================================
// 4. PLOTTING (การแสดงผลบนกราฟ)
// ==========================================
// -- เส้นเทรนด์ และ POC --
plot(emaFast, title="EMA Fast", color=color.new(color.aqua, 0), linewidth=2)
plot(emaSlow, title="EMA Slow", color=color.new(color.blue, 0), linewidth=2)
plot(pocPrice, title="Dynamic POC", color=color.new(color.orange, 30), linewidth=2, style=plot.style_cross)

// -- สัญลักษณ์ Entry --
plotshape(buyCond, title="BUY Signal", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.normal, text="BUY", textcolor=color.green)
plotshape(sellCond, title="SELL Signal", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.normal, text="SELL", textcolor=color.red)

// -- จุด Stop Loss (แสดงเฉพาะตอนเกิดสัญญาณ) --
plot(buyCond ? longSL : na, title="Long Stop Loss", style=plot.style_circles, linewidth=4, color=color.red)
plot(sellCond ? shortSL : na, title="Short Stop Loss", style=plot.style_circles, linewidth=4, color=color.green)

// ==========================================
// 5. DASHBOARD (ตารางสรุปข้อมูลสิ้นวัน)
// ==========================================
var table tb = table.new(position.top_right, 2, 4, bgcolor=color.new(color.black, 80), border_width=1, border_color=color.gray)
if barstate.islast
    // Header
    table.cell(tb, 0, 0, "Metric", text_color=color.white, text_halign=text.align_left)
    table.cell(tb, 1, 0, "Status", text_color=color.white, text_halign=text.align_center)
    
    // POC Status
    bool abovePOC = close > pocPrice
    table.cell(tb, 0, 1, "Price vs POC", text_color=color.white, text_halign=text.align_left)
    table.cell(tb, 1, 1, abovePOC ? "ABOVE" : "BELOW", text_color=abovePOC ? color.green : color.red, text_halign=text.align_center)
    
    // Trend Status
    table.cell(tb, 0, 2, "Trend (EMA 9/21)", text_color=color.white, text_halign=text.align_left)
    table.cell(tb, 1, 2, uptrend ? "UPTREND" : downtrend ? "DOWNTREND" : "FLAT", text_color=uptrend ? color.green : downtrend ? color.red : color.yellow, text_halign=text.align_center)
    
    // ATR Status
    table.cell(tb, 0, 3, "Volatility (ATR)", text_color=color.white, text_halign=text.align_left)
    table.cell(tb, 1, 3, str.tostring(atrValue, "#.##"), text_color=color.orange, text_halign=text.align_center)

// ==========================================
// 6. ALERTS (การตั้งเตือน)
// ==========================================
alertcondition(buyCond, title="Block Trade BUY Signal", message="🟢 BUY Signal Triggered! Trend Up + Price > POC + StochRSI Oversold Bounce")
alertcondition(sellCond, title="Block Trade SELL Signal", message="🔴 SELL Signal Triggered! Trend Down + Price < POC + StochRSI Overbought Drop")// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © P_P4533

//@version=6
````

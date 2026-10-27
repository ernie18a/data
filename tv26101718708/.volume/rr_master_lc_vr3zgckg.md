# RR Master - LC

- url: https://www.tradingview.com/script/vR3zgCKG/
- type: strategy
- pine_id: PUB;268fb2ddb28e4653b85cd2a887fd178a
- version: 1.0

## Description

1. เงื่อนไขการคัดกรอง (ตัวกรองความเสี่ยง)
ก่อนที่ระบบจะมองหาจุดเข้า ราคาต้องผ่านด่านเหล่านี้ก่อน:

แนวโน้มขาขึ้น (Buy): ราคาต้องอยู่ เหนือเส้น EMA 200 และ เหนือเส้น VWAP

แนวโน้มขาลง (Sell): ราคาต้องอยู่ ใต้เส้น EMA 200 และ ใต้เส้น VWAP

ความแรงของเทรนด์: ค่า ADX ต้องมากกว่า 30 และต้องมีทิศทางชันขึ้น (Confirm ว่าไม่ใช่ช่วงไซด์เวย์ที่อันตราย)

Clear Zone: ราคาต้องไม่นัวเนียอยู่กับเส้น EMA 200 (ต้องลอยตัวออกมาเห็นชัดๆ)

2. สัญญาณเข้าเทรด (Entry Trigger)
เมื่อเทรดครบเงื่อนไขด้านบนแล้ว ระบบจะรอจังหวะจาก RSI:

เข้าซื้อ (Buy): RSI 7 (เส้นเร็ว) ตัดขึ้น เหนือ RSI 14 (เส้นช้า)

เข้าขาย (Sell): RSI 7 (เส้นเร็ว) ตัดลง ใต้ RSI 14 (เส้นช้า)

ระบบพักตัว (Cooldown): หลังจากจบออเดอร์ล่าสุด ระบบจะ หยุดพัก 8 แท่งเทียน เพื่อป้องกันการรีบเข้าซ้ำในจุดเดิม

3. การตั้งเป้าหมาย (TP/SL)
จุดตัดขาดทุน (SL): ใช้ราคา Low (สำหรับ Buy) หรือ High (สำหรับ Sell) ของแท่งที่เข้า บวก/ลบ ระยะเผื่อ (Buffer) 200 จุด

จุดทำกำไร (TP): ตั้งเป้าที่ 1.7 เท่า (RR 1.7) ของระยะขาดทุนเสมอ เพื่อให้กำไรโตกว่าขาดทุนในระยะยาว

4. ระบบการแสดงผลและแจ้งเตือน (Visual & Alerts)
ป้ายสัญญาณ: จะมีป้ายสีเขียว (Buy) หรือแดง (Sell) ลอยอยู่เหนือ/ใต้แท่งเทียนในระยะที่มองง่าย

ป้าย Jumbo: เมื่อปิดออเดอร์ จะมีป้ายขนาดใหญ่สรุปยอด กำไร/ขาดทุนเป็น USD โชว์บนกราฟทันที

การแจ้งเตือนมือถือ: ระบบจะส่งข้อความ ภาษาไทย เข้าแอป TradingView ทันทีที่มีการ:

เปิดออเดอร์ใหม่ (บอกราคาและจุด SL/TP)

ปิดออเดอร์เพราะชนกำไร (TP Hit)

ปิดออเดอร์เพราะชนจุดถอย (SL Hit)

คำแนะนำเพิ่มเติม: แผนนี้เน้นวินัยและความได้เปรียบของตัวเลข (RR) เมื่อระบบแจ้งเตือนมาแล้ว คุณสามารถเปิดดูหน้าจอเพื่อความมั่นใจอีกครั้ง หรือปล่อยให้ระบบรัน Backtest เก็บสถิติไปเรื่อยๆ ได้เลยครับ ขอให้พอร์ตสีเขียวสดใสครับ! 📈💰

## Source Code

````pine
//@version=5
strategy("RR Master - ระบบแจ้งเตือนภาษาไทย", overlay=true, initial_capital=10000, currency=currency.USD, default_qty_type=strategy.fixed, default_qty_value=1)

// --- [ การตั้งค่า ] ---
startTime    = input.time(timestamp("2026-01-01 00:00 +0700"), "วันที่เริ่มทดสอบ")
tradeQty     = input.float(1.0, "จำนวนสัญญา (Qty)")
rrRatio      = input.float(1.7, "อัตรากำไรต่อขาดทุน (RR)")
slBuffer     = input.float(2.0, "ระยะเผื่อ SL (2.0 = 200 จุดทอง)")
minBarGap    = input.int(8, "ระยะพักแท่งเทียน (Cooldown)")

window() => time >= startTime

// --- [ ตัวชี้วัด ] ---
ema200  = ta.ema(close, 200)
vwapVal = ta.vwap(hlc3)
[plusDI, minusDI, adxVal] = ta.dmi(14, 14)
rsiFast = ta.rsi(close, 7), rsiSlow = ta.rsi(close, 14)
atr     = ta.atr(14)
isAdxStrong = adxVal > 30 and adxVal > ta.sma(adxVal, 7)

// --- [ เงื่อนไขสัญญาณ ] ---
var int lastTradeBar = 0
canTrade = (bar_index - lastTradeBar) >= minBarGap
buy  = window() and canTrade and low > ema200 and close > vwapVal and isAdxStrong and ta.crossover(rsiFast, rsiSlow)
sell = window() and canTrade and high < ema200 and close < vwapVal and isAdxStrong and ta.crossunder(rsiFast, rsiSlow)

// --- [ การเข้าออเดอร์และระบบแจ้งเตือน ] ---
if (buy and strategy.position_size == 0)
    float sl = low - slBuffer
    float tp = close + (math.abs(close - sl) * rrRatio)
    strategy.entry("Long", strategy.long, qty=tradeQty)
    strategy.exit("Exit", "Long", stop=sl, limit=tp)
    lastTradeBar := bar_index
    // แจ้งเตือนภาษาไทย
    alert("🟢 สัญญาณซื้อ (BUY) XAUUSD @ " + str.tostring(close) + " | ตัดขาดทุน (SL): " + str.tostring(sl) + " | เป้ากำไร (TP): " + str.tostring(tp), alert.freq_once_per_bar_close)
    label.new(bar_index, low - (atr * 3), "🟢 ซื้อ (BUY)", color=color.green, textcolor=color.white, style=label.style_label_up)

if (sell and strategy.position_size == 0)
    float sl = high + slBuffer
    float tp = close - (math.abs(sl - close) * rrRatio)
    strategy.entry("Short", strategy.short, qty=tradeQty)
    strategy.exit("Exit", "Short", stop=sl, limit=tp)
    lastTradeBar := bar_index
    // แจ้งเตือนภาษาไทย
    alert("🔴 สัญญาณขาย (SELL) XAUUSD @ " + str.tostring(close) + " | ตัดขาดทุน (SL): " + str.tostring(sl) + " | เป้ากำไร (TP): " + str.tostring(tp), alert.freq_once_per_bar_close)
    label.new(bar_index, high + (atr * 3), "🔴 ขาย (SELL)", color=color.red, textcolor=color.white, style=label.style_label_down)

plot(ema200, color=color.new(color.yellow, 50), title="เส้น EMA 200")
plot(vwapVal, color=color.new(color.gray, 50), title="เส้น VWAP")
````

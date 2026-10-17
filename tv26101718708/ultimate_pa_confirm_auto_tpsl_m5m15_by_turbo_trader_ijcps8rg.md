# Ultimate PA Confirm + Auto TP/SL (M5/M15) by TURBO TRADER

- url: https://www.tradingview.com/script/IJcps8rg-Ultimate-PA-Confirm-Auto-TP-SL-M5-M15-by-TURBO-TRADER/
- type: indicator
- pine_id: PUB;60f5aa6c4af140d58fb93a0ea000c6b1
- version: 2.0

## Description

[b]Key Features[/b]
M5 / M15 Price Action Detection: Automatically scans and detects high-probability Bullish/Bearish Engulfing and Pin Bar patterns on lower timeframes.

1-Bar Confirmation Logic (No Repaint): Signals are strictly calculated and printed on the open of the next candle after the confirmation bar closes. This guarantees 100% fixed, non-repainting signals.

Dynamic Auto TP1 / TP2 Levels: Profit targets are entirely volatility-based, calculated dynamically using the actual measured range (High to Low) of the trigger Price Action candle.

SL Buffer (+300 Pips/Points): Automatically places the Stop Loss 300 pips/points below the low (for Buys) or above the high (for Sells) of the PA candle. This structural buffer protects your trades from market noise and stop hunts.

[b]Visuals on the Chart[/b]
Once applied, the indicator projects 3 dynamic, color-coded levels on your chart:

🔴 Red Line = Stop Loss (SL with buffer)

🟢 Green Line = Take Profit 1 (TP1)

🔵 Blue Line = Take Profit 2 (TP2)

All levels are recalculated and locked instantly whenever a fresh "BUY CONFIRM" or "SELL CONFIRM" printed signal occurs.

[b] Fully Customizable Settings[/b]
Simply double-click the indicator on your chart to open the Settings menu. From there, you can fine-tune:

Candle Proportions: Adjust body-to-wick ratios to make the Price Action scanner more strict or aggressive.

Risk-to-Reward Multipliers: Modify TP1 and TP2 targets.

SL Buffer Size: Scale the 300-pip default buffer up or down depending on current market volatility or the asset's spread.

Built to handle high-velocity markets—fast execution, zero lag!

## Source Code

````pine
//@version=6
indicator("Ultimate PA Confirm + Auto TP/SL (Labeled) by Gemini", overlay=true)

// ==========================================
// --- 1. ตั้งค่า INPUT (ปรับเปลี่ยนในหน้าจอได้) ---
// ==========================================
gp_pa    = "ตั้งค่ารูปแบบ Price Action"
pinBodyRatio = input.float(0.3, title="สัดส่วนเนื้อเทียน (ไม่เกิน)", minval=0.1, maxval=0.5, step=0.05, group=gp_pa)
pinWickRatio = input.float(0.6, title="สัดส่วนไส้เทียนยาว (อย่างน้อย)", minval=0.5, maxval=0.9, step=0.05, group=gp_pa)

gp_trade = "ตั้งค่าระยะกำไรและขาดทุน (TP / SL)"
tp1Multiplier = input.float(1.5, title="ตัวคูณเป้าหมาย TP 1", minval=0.5, step=0.1, group=gp_trade)
tp2Multiplier = input.float(3.0, title="ตัวคูณเป้าหมาย TP 2", minval=1.0, step=0.1, group=gp_trade)
slBufferInput = input.int(300, title="ระยะเผื่อ SL จากปลายไส้ (Pips/Points)", group=gp_trade)

// ==========================================
// --- 2. คำนวณองค์ประกอบแท่งเทียนย้อนหลัง ---
// ==========================================
candleRange1 = high[1] - low[1]
bodySize1    = math.abs(close[1] - open[1])
upperWick1   = high[1] - math.max(open[1], close[1])
lowerWick1   = math.min(open[1], close[1]) - low[1]

// ==========================================
// --- 3. เช็คเงื่อนไข Price Action (แท่ง index [1]) ---
// ==========================================
bullishEngulfing = (close[2] < open[2]) and (close[1] > open[1]) and (close[1] >= open[2]) and (open[1] <= close[2])
bearishEngulfing = (close[2] > open[2]) and (close[1] < open[1]) and (close[1] <= open[2]) and (open[1] >= close[2])
bullishPin       = (bodySize1 <= candleRange1 * pinBodyRatio) and (lowerWick1 >= candleRange1 * pinWickRatio)
bearishPin       = (bodySize1 <= candleRange1 * pinBodyRatio) and (upperWick1 >= candleRange1 * pinWickRatio)

paBuyPattern  = bullishEngulfing or bullishPin
paSellPattern = bearishEngulfing or bearishPin

// ==========================================
// --- 4. เงื่อนไข CONFIRMATION (แท่งปัจจุบัน index [0]) ---
// ==========================================
buyConfirmed  = paBuyPattern[1] and (close > open) and (close > close[1])
sellConfirmed = paSellPattern[1] and (close < open) and (close < close[1])

// แปลงหน่วยพิปตามทศนิยมของสินทรัพย์
slBuffer = slBufferInput * syminfo.mintick

// ล็อกความยาวแท่ง PA และราคาจุดเข้า
paLength   = ta.valuewhen(buyConfirmed or sellConfirmed, high[2] - low[2], 0)
entryPrice = ta.valuewhen(buyConfirmed or sellConfirmed, close, 0)

// ==========================================
// --- 5. คำนวณเป้าหมายระดับราคา TP และ SL ---
// ==========================================
var float targetSL  = na
var float targetTP1 = na
var float targetTP2 = na

if buyConfirmed
    targetSL  := low[2] - slBuffer
    targetTP1 := entryPrice + (paLength * tp1Multiplier)
    targetTP2 := entryPrice + (paLength * tp2Multiplier)

if sellConfirmed
    targetSL  := high[2] + slBuffer
    targetTP1 := entryPrice - (paLength * tp1Multiplier)
    targetTP2 := entryPrice - (paLength * tp2Multiplier)

// ==========================================
// --- 6. แสดงสัญลักษณ์และเส้นแนวรับ-แนวต้านพร้อมชื่อกำกับ ---
// ==========================================
plotshape(series=buyConfirmed, title="Buy Confirmed", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.normal, text="BUY CONFIRM")
plotshape(series=sellConfirmed, title="Sell Confirmed", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.normal, text="SELL CONFIRM")

// วาดเส้นและแสดงชื่อระบุที่ขอบขวาของกราฟอัตโนมัติ
plot(targetSL, title="Stop Loss Line", color=color.red, style=plot.style_linebr, linewidth=2, display=display.all)
plot(targetTP1, title="TP 1 Line", color=color.green, style=plot.style_linebr, linewidth=1, display=display.all)
plot(targetTP2, title="TP 2 Line", color=color.blue, style=plot.style_linebr, linewidth=1, display=display.all)

// เพิ่มข้อความ Label วิ่งตามเส้นราคาล่าสุด (อัปเดตแบบ Dynamic)
var label lblSL  = label.new(bar_index, na, text="Stop Loss", color=color.red, textcolor=color.white, style=label.style_label_left, size=size.small)
var label lblTP1 = label.new(bar_index, na, text="TP 1", color=color.green, textcolor=color.white, style=label.style_label_left, size=size.small)
var label lblTP2 = label.new(bar_index, na, text="TP 2", color=color.blue, textcolor=color.white, style=label.style_label_left, size=size.small)

if not na(targetSL)
    label.set_xy(lblSL, bar_index + 2, targetSL)
if not na(targetTP1)
    label.set_xy(lblTP1, bar_index + 2, targetTP1)
if not na(targetTP2)
    label.set_xy(lblTP2, bar_index + 2, targetTP2)

// ==========================================
// --- 7. ระบบส่งสัญญาณแจ้งเตือน (Alerts) ---
// ==========================================
if buyConfirmed
    alert(" [BUY CONFIRM] " + syminfo.ticker + " สัญญาณซื้อยืนยันแล้ว! SL และ TP ถูกกำหนดบนกราฟ", alert.freq_once_per_bar_close)
if sellConfirmed
    alert(" [SELL CONFIRM] " + syminfo.ticker + " สัญญาณขายยืนยันแล้ว! SL และ TP ถูกกำหนดบนกราฟ", alert.freq_once_per_bar_close)
````

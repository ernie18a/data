# BUY and SELL Signal

- url: https://www.tradingview.com/script/hxiJOmQx/
- type: indicator
- pine_id: PUB;f583b9f5012f4d84a4fac02e3e2129b6
- version: 1.0

## Description

Overview
This indicator is designed specifically for lower timeframes like the 5-minute (M5) chart. It monitors the closing price of the very first candle of every new hour and generates a BUY or SELL signal on the immediate next candle based on the last digit (ones place) of that hourly opening candle's closing price.

It is an interesting tool for traders who study price numbers, psychological round numbers, or digit-based statistical tendencies in the market.

## Source Code

````pine
//@version=5
indicator("BUY and SELL Signal", overlay=true)

// 1. ตรวจสอบว่าเป็นแท่งแรกของชั่วโมงใหม่หรือไม่ (บนไทม์เฟรม M5)
is_new_hour = ta.change(time("60")) != 0

// ตัวแปรสำหรับเก็บสัญญาณ
var int signal = 0 // 1 = BUY, -1 = SELL, 0 = ไม่มีสัญญาณ

// 2. เงื่อนไขการเช็กเลขหลักหน่วยเมื่อขึ้นชั่วโมงใหม่
if is_new_hour
    // ปรับราคาปิดให้เป็นจำนวนเต็มเพื่อหาหลักหน่วย (ตัดทศนิยมออกถ้ามี)
    int close_int = math.floor(close)
    int last_digit = close_int % 10
    
    // เช็กเลขหลักหน่วยตามเงื่อนไข
    if last_digit == 0 or last_digit == 1 or last_digit == 2 or last_digit == 3 or last_digit == 5 or last_digit == 6
        signal := 1  // สัญญาณ BUY สำหรับแท่งถัดไป
    else if last_digit == 4 or last_digit == 7 or last_digit == 8 or last_digit == 9
        signal := -1 // สัญญาณ SELL สำหรับแท่งถัดไป
else
    // ถ้าไม่ใช่แท่งแรกที่ต่อจากต้นชั่วโมง ให้เคลียร์สัญญาณเป็น 0
    signal := 0

// 3. แสดงผลติตตั้งสัญญาณ (Plot Shapes) ในแท่งถัดไป
// ใช้ สัญญาณจากแท่งก่อนหน้า [1] มาแสดงผลในแท่งปัจจุบัน เพื่อให้ตรงกับเงื่อนไข "ขึ้นในแท่งถัดไป"
plotshape(signal[1] == 1, title="BUY Signal", style=shape.labelup, location=location.belowbar, color=color.green, text="BUY", textcolor=color.white, size=size.small)
plotshape(signal[1] == -1, title="SELL Signal", style=shape.labeldown, location=location.abovebar, color=color.red, text="SELL", textcolor=color.white, size=size.small)
````

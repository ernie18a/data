# Snowite Scanner

- url: https://www.tradingview.com/script/0FatJd98-Snowite-Scanner/
- type: indicator
- pine_id: PUB;b598e9bfe0674162a910202bb78ca4a8
- version: 3.0

## Description

Snowite Scanner — README
ภาพรวม
Snowite Scanner เป็น indicator สำหรับ TradingView (Pine Script v6) ใช้หา จุด Setup ที่ราคากำลังสะสมตัวเงียบๆ ก่อนจะเคลื่อนไหว โดยกรองหุ้นที่มีคุณสมบัติครบ 5 ข้อพร้อมกัน ได้แก่ ราคาถูก squeeze, volume หดตัว, อยู่เหนือ trend ขาขึ้น และ momentum ยังไม่ร้อนแรงเกินไป

เงื่อนไข Setup (ต้องผ่านครบทุกข้อ)
ข้อ 1 — Price Compression (ราคาถูกบีบอัด)
ดูว่าในช่วง 5 แท่งล่าสุด ราคาเคลื่อนไหวในกรอบแคบแค่ไหน โดยวัดจาก:
compressionPct = (Highest High 5 - Lowest Low 5) / Lowest Low 5 × 100
ค่านี้ต้อง น้อยกว่า 15% → แสดงว่าราคากำลัง sideway หรือ squeeze ตัวอยู่ ยังไม่วิ่ง

ข้อ 2 — Volume Contraction (volume หดตัว)
เปรียบ volume เฉลี่ย 5 แท่งล่าสุด กับ volume เฉลี่ย 15 แท่ง:
vol5 < vol100 × 0.8
ต้อง ต่ำกว่า 80% ของค่าเฉลี่ย → แสดงว่าตลาดเงียบ คนยังไม่แห่งซื้อ ซึ่งเป็นสัญญาณที่ดีก่อน breakout จริง

ข้อ 3 — Above EMA Trend (อยู่เหนือ trend)
ราคาปิดต้อง อยู่เหนือ EMA 100 → ยืนยันว่าหุ้นอยู่ในโซน trend ขาขึ้นในระยะกลาง ไม่ใช่ดักซื้อของตก

ข้อ 4 — Rising EMA (trend กำลังขึ้น)
EMA 100 ตอนนี้ต้อง สูงกว่า EMA 100 เมื่อ 5 แท่งที่แล้ว → trend ไม่ใช่แค่ผ่านแต่กำลังชันขึ้น momentum ระยะกลางเป็นบวก

ข้อ 5 — RSI Zone (momentum ดีพอ ไม่ร้อนแรงเกิน)
RSI(14) ต้องอยู่ใน ช่วง 50–70:

มากกว่า 50 → momentum เป็นบวก ไม่อ่อนแอ
น้อยกว่า 70 → ยังไม่ overbought มีที่ให้วิ่งต่อ


เมื่อผ่านครบ — จะเกิดอะไร
เมื่อทุกเงื่อนไขผ่านพร้อมกัน indicator จะ:

วาด dot สีเขียว ใต้แท่งเทียน (plotshape)
ลาก Support Line จากจุดต่ำสุดของ zone ไปเรื่อยๆ ตราบที่ยังอยู่ใน setup
เมื่อ setup จบ → lock เป็น Support Line (สีเขียวเต็ม) เพื่อใช้เป็นแนวรับ
ถ้าราคาปิดทะลุต่ำกว่า Support → เส้นเปลี่ยนเป็นสีแดง และหยุดติดตาม

ข้อควรระวัง

****
Indicator นี้ ไม่ใช่ signal ซื้อทันที แต่เป็นการบอกว่าหุ้นอยู่ในสภาวะเหมาะสม ควรรอ confirmation เพิ่มเติม เช่น volume spike หรือ breakout จริง
ควรใช้คู่กับ timeframe ที่เหมาะสม (แนะนำ daily หรือ weekly)
ปรับ CompressionLimit และ Volume Filter Length ตาม volatility ของตลาดที่ใช้

Conclusion
Snowite Scanner does not generate immediate buy signals. It identifies stocks in an optimal accumulation state — price squeezed into a narrow range, volume quietly contracting, sitting above a rising trend, with momentum that is healthy but not overextended. Think of it as a watchlist filter: when all five conditions align and a dot appears, the stock is worth monitoring for a follow-through confirmation such as a volume spike or a clean breakout above the compression zone. Use the locked Support Line as your invalidation level — if price closes below it, the setup is no longer valid.
Best used on Daily or Weekly timeframes. Adjust CompressionLimit and Volume Filter Length to match the volatility characteristics of your target market.

## Source Code

````pine
//@version=6
indicator('Snowite Scanner', overlay = true, max_lines_count = 500)

//====================
// INPUT
//====================
hhvShortLen  = input.int(5)
hhvLongLen   = input.int(15)

compressionLimit = input.float(15.0)

volShortLen     = input.int(5)
volFilterLen    = input.int(15, title = 'Volume Filter Length')
volContractionT = input.float(0.8, title = 'Volume Contraction Threshold', minval = 0.1, maxval = 1.0, step = 0.1)

emaTrendLen = input.int(100, title = 'EMA Trend')
rsiLen      = input.int(14,  title = 'RSI Length')
rsiLow      = input.int(50,  title = 'RSI Min', minval = 1,  maxval = 100)
rsiHigh     = input.int(70,  title = 'RSI Max', minval = 1,  maxval = 100)

emaTrendColorUp   = input.color(color.green, title = 'EMA Trend Up')
emaTrendColorDown = input.color(color.red,   title = 'EMA Trend Down')

supportColorActive = input.color(color.green, title = 'Support Active Color')
supportColorBroken = input.color(color.red,   title = 'Support Broken Color')
supportWidth       = input.int(1,             title = 'Support Line Width', minval = 1, maxval = 4)
supportStyle       = input.string('dashed',   title = 'Support Line Style', options = ['solid', 'dashed', 'dotted'])

//====================
// CALCULATION
//====================

llv5   = ta.lowest(low,   hhvShortLen)
llvLng = ta.lowest(low,   hhvLongLen)
hhv5   = ta.highest(high, hhvShortLen)
hhvLng = ta.highest(high, hhvLongLen)

vol5   = ta.sma(volume, volShortLen)
vol100 = ta.sma(volume, volFilterLen)

emaTrend = ta.ema(close, emaTrendLen)
rsi      = ta.rsi(close, rsiLen)

range5         = math.max(hhv5 - llv5, syminfo.mintick)
compressionPct = range5 / math.max(llv5, syminfo.mintick) * 100

//====================
// CONDITIONS
//====================

volReady = bar_index >= volFilterLen

cond2 = compressionPct < compressionLimit
cond3 = volReady and vol5 < vol100 * volContractionT
cond4 = close > emaTrend
cond5 = emaTrend > emaTrend[5]
cond6 = rsi > rsiLow and rsi < rsiHigh

//====================
// SETUP
//====================
setup = cond2 and cond3 and cond4 and cond5 and cond6

//====================
// SUPPORT LINE
//====================
lineStyle = supportStyle == 'solid' ? line.style_solid : supportStyle == 'dotted' ? line.style_dotted : line.style_dashed

var bool  inZone       = false
var float zoneSupport  = na
var int   zoneStartBar = na
var line  activeLine   = na
var label activeLabel  = na
var line  supportLine  = na
var label supportLabel = na

if setup
    if not inZone
        // zone เริ่มใหม่
        inZone       := true
        zoneSupport  := low
        zoneStartBar := bar_index

        if not na(activeLine)
            line.delete(activeLine)
        if not na(activeLabel)
            label.delete(activeLabel)

        activeLine := line.new(
             x1    = zoneStartBar,
             y1    = zoneSupport,
             x2    = bar_index + 1,
             y2    = zoneSupport,
             color = color.new(supportColorActive, 60),
             width = supportWidth,
             style = lineStyle)
        activeLabel := label.new(
             x         = bar_index + 1,
             y         = zoneSupport,
             text      = str.tostring(zoneSupport, format.mintick),
             style     = label.style_label_left,
             color     = color.new(color.black, 100),
             textcolor = color.new(supportColorActive, 60),
             size      = size.small)
    else
        // อัพเดท support ต่ำสุด — x1 คง zoneStartBar เสมอ
        if low < zoneSupport
            zoneSupport := low
        line.set_x2(activeLine, bar_index + 1)
        line.set_y1(activeLine, zoneSupport)
        line.set_y2(activeLine, zoneSupport)
        label.set_y(activeLabel, zoneSupport)
        label.set_text(activeLabel, str.tostring(zoneSupport, format.mintick))
        label.set_x(activeLabel, bar_index + 1)

else
    if inZone
        // zone จบ → lock เป็น supportLine (สี solid)
        inZone := false
        if not na(supportLine)
            line.delete(supportLine)
        if not na(supportLabel)
            label.delete(supportLabel)
        supportLine  := activeLine
        supportLabel := activeLabel
        // เปลี่ยนสีเป็น solid เมื่อ lock
        line.set_color(supportLine, supportColorActive)
        label.set_textcolor(supportLabel, supportColorActive)
        activeLine   := na
        activeLabel  := na
        zoneSupport  := na
        zoneStartBar := na

// ขยาย supportLine และเช็ค break
if not na(supportLine)
    lineLevel = line.get_y1(supportLine)
    if close < lineLevel
        line.set_color(supportLine, supportColorBroken)
        line.set_x2(supportLine, bar_index)
        label.set_x(supportLabel, bar_index)
        label.set_textcolor(supportLabel, supportColorBroken)
        supportLine  := na
        supportLabel := na
    else
        line.set_x2(supportLine, bar_index + 1)
        label.set_x(supportLabel, bar_index + 1)

//====================
// VISUAL
//====================
plot(hhv5,   color = color.new(color.red,    100))
plot(llv5,   color = color.new(color.green,  100))
plot(hhvLng, color = color.new(color.orange, 100))
plot(llvLng, color = color.new(color.aqua,   100))

emaColor = emaTrend > emaTrend[2] ? emaTrendColorUp : emaTrendColorDown
plot(emaTrend, color = emaColor, linewidth = 2)

plotshape(setup, style = shape.circle, location = location.belowbar, size = size.tiny, color = color.yellow)

//====================
// ALERT
//====================
alertcondition(setup, title = 'Snowite Setup', message = 'Snowite Setup: {{ticker}} @ {{close}}')

//====================
// DATA WINDOW
//====================
plot(compressionPct, display = display.data_window)
plot(vol5 / vol100,  display = display.data_window)
plot(rsi,            display = display.data_window)
````

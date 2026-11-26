# FVG + HTF Equilibrium (True Mitigation V14.2)

- url: https://www.tradingview.com/script/pUXG8MHv-FVG-HTF-Equilibrium-True-Mitigation-V14-2/
- type: indicator
- pine_id: PUB;a30dba84b0e048dab995fae69eed0f37
- version: 1.0

## Description

FVG + HTF Equilibrium (True Mitigation V14.2)
อินดิเคเตอร์บอก แนวแท่งคู่(ราคาปิดแท่ง และราคาเปิดของแท่งถัดไป ราคาใกล้เคียงกัน) และ FVG

2 กลไกหลักขับเคลื่อนระบบ
1. Fair Value Gaps (FVG) – โซนความไม่สมดุลของราคา
Bullish FVG (กล่องสี Teal): โซนแรงซื้อรุนแรง ราคาเกิดช่องว่าง (Imbalance) มักลงมาทดสอบแล้วเด้งขึ้นต่อ
Bearish FVG (กล่องสีชมพู/ม่วง): โซนแรงขายรุนแรง มักรีบาวด์ขึ้นมาทดสอบแล้วร่วงต่อ
Dynamic Resizing: กล่องจะหดตัวลงตามจริงเมื่อราคาเข้าถม (Filled) และจะลบออกทันทีหากราคาปิดทะลุโซน

2. HTF Equilibrium – แนวรับ-แนวต้านแท่งคู่
Concept: ระบบดึงข้อมูลข้ามไทม์เฟรม (5m, 15m, 30m, 1h, 4h, 1D) ตรวจจับแท่งเทียนคู่ขัดแย้งในอดีต (เช่น เขียวเต็มแล้วแดงทุบสวนทันที) ณ ระดับราคาที่มีคำสั่งซื้อขายหนาแน่น
True Mitigation 100%:
 - ฝั่งไทม์เฟรมใหญ่ (HTF) จะสกรีนตัวเองก่อน หากแนวราคาเคยโดนเคลียร์ไปแล้ว จะไม่สร้างเส้นเด็ดขาด
 - เส้นประที่ปรากฏบนจอ หากราคาปัจจุบันใน m1 วิ่งมาชนหรือสะบัดไส้โดน เส้นจะถูกลบทำลายทิ้งทันทีเรียลไทม์ (บนชาร์ตจะเหลือเฉพาะแนวสดใหม่ที่ยังไม่เคยโดนทดสอบเท่านั้น)


FVG + HTF Equilibrium (True Mitigation V14.2)

This indicator identifies paired-candle levels (where a candle’s close and the next candle’s open are at nearly the same price) and FVGs.

Two Core Mechanisms Driving the System

1. Fair Value Gaps (FVG) – Price Imbalance Zones
- Bullish FVG (Teal Box):** A zone of strong buying pressure where a price gap (imbalance) forms. Price often retraces to test the zone before continuing upward.
- Bearish FVG (Pink/Purple Box):** A zone of strong selling pressure. Price often rebounds into the zone for a retest before continuing downward.
- **Dynamic Resizing:** The box automatically shrinks as price fills the gap and is removed immediately if a candle closes beyond the zone.

2. HTF Equilibrium – Paired-Candle Support & Resistance
Concept:The system pulls data from higher timeframes (5m, 15m, 30m, 1h, 4h, 1D) and detects historical opposing candle pairs (e.g., a strong bullish candle immediately followed by a strong bearish candle) at price levels with concentrated buy/sell orders.

True Mitigation 100%:
- Higher timeframes (HTF) perform self-screening first. If a price level has already been mitigated, the system will not create that level under any circumstances.
- Any dashed line displayed on the chart will be removed instantly in real time if current M1 price touches it or even wicks into it. As a result, only fresh, untested levels remain visible on the chart.

## Source Code

````pine
//@version=6
indicator("FVG + HTF Equilibrium (True Mitigation V14.2)", overlay = true, max_bars_back = 1000)

//-------------------------------------
// 1. Settings - FVG
//-------------------------------------
group_fvg      = "FVG Settings"
showFVG        = input.bool(true, "Show FVG Boxes", group=group_fvg)
maxFVG         = input.int(20, "Max FVG Boxes", group=group_fvg)
bullFVGCol     = input.color(color.new(color.teal, 80), "Bullish FVG Color", group=group_fvg)
bearFVGCol     = input.color(color.new(#ff00ea, 80), "Bearish FVG Color", group=group_fvg)
fvgTextColor   = input.color(color.new(color.white, 40), "FVG Text Color", group=group_fvg)

//-------------------------------------
// 2. Settings - HTF Equilibrium
//-------------------------------------
group_htf      = "HTF Equilibrium (เส้นประแท่งคู่)"
thresholdTicks = input.int(10, "Threshold (Ticks/Points)", minval = 0, group=group_htf)
maxLinesPerTF  = input.int(5, "Max Lines per Timeframe", group=group_htf)

// [NEW] เพิ่ม Input สำหรับ 5m
show5   = input.bool(true, "Show 5m", group="5m"),   col5   = input.color(color.olive, "Color 5m", group="5m")
show15  = input.bool(true, "Show 15m", group="15m"),  col15  = input.color(color.gray, "Color 15m", group="15m")
show30  = input.bool(true, "Show 30m", group="30m"),  col30  = input.color(color.blue, "Color 30m", group="30m")
show60  = input.bool(true, "Show 1h", group="1h"),    col60  = input.color(color.orange, "Color 1h", group="1h")
show240 = input.bool(true, "Show 4h", group="4h"),    col240 = input.color(color.red, "Color 4h", group="4h")
show1D  = input.bool(true, "Show 1D", group="1D"),    col1D  = input.color(color.yellow, "Color 1D", group="1D")

//-------------------------------------
// 3. Data Structures
//-------------------------------------
type FVGBox
    box   bx
    float top
    float btm
    bool  isBull

type HTFLine
    string tf
    line   ln
    label  lb
    float  price
    int    spawn_time

var array<FVGBox> fvgArray = array.new<FVGBox>()
var array<HTFLine> htfLines = array.new<HTFLine>()

//-------------------------------------
// 4. FVG Logic (แยกส่วนคำนวณอิสระ)
//-------------------------------------
if showFVG and bar_index > 2 and barstate.isconfirmed
    if low > high[2]
        box b = box.new(bar_index[2], low, bar_index, high[2], bgcolor=bullFVGCol, border_color=color.new(color.white, 100), text="FVG", text_size=size.tiny, text_color=fvgTextColor, text_halign=text.align_right, text_valign=text.align_center)
        array.push(fvgArray, FVGBox.new(b, low, high[2], true))
    else if high < low[2]
        box b = box.new(bar_index[2], low[2], bar_index, high, bgcolor=bearFVGCol, border_color=color.new(color.white, 100), text="FVG", text_size=size.tiny, text_color=fvgTextColor, text_halign=text.align_right, text_valign=text.align_center)
        array.push(fvgArray, FVGBox.new(b, low[2], high, false))
    if array.size(fvgArray) > maxFVG
        box.delete(array.shift(fvgArray).bx)

if array.size(fvgArray) > 0
    for i = array.size(fvgArray) - 1 to 0
        f = array.get(fvgArray, i)
        if f.isBull
            if low < f.top
                f.top := math.max(low, f.btm), box.set_top(f.bx, f.top)
            if f.top <= f.btm or close < f.btm
                box.delete(f.bx), array.remove(fvgArray, i)
            else
                box.set_right(f.bx, bar_index + 1)
        else
            if high > f.btm
                f.btm := math.min(high, f.top), box.set_bottom(f.bx, f.btm)
            if f.btm >= f.top or close > f.top
                box.delete(f.bx), array.remove(fvgArray, i)
            else
                box.set_right(f.bx, bar_index + 1)

//-------------------------------------
// 5. HTF Equilibrium Logic [V14.2 คุมสิทธิ์การเกิดเส้นจากฝั่ง HTF 100%]
//-------------------------------------
int currTFMin = timeframe.isintraday ? timeframe.multiplier : (timeframe.isdaily ? 1440 : 9999)

f_proc_htf(_tfStr, _show, _col, _min) =>
    if _show and currTFMin < _min
        // ตรรกะเด็ดขาด: ให้ฝั่งไทม์เฟรมใหญ่ตรวจสอบราคาสดๆ ของแท่งปัจจุบัน (แท่งที่ 3) ของตัวเองเลยว่าทะลุผ่านราคาเปิด o0 หรือยัง
        // โดยส่งกลับมาในตัวแปร is_mitigated_at_htf
        [o0, c0, o1, c1, t0, is_mitigated_at_htf] = request.security(syminfo.tickerid, _tfStr, 
             [open[1], close[1], open[2], close[2], time[1], (high >= open[1] and low <= open[1])], 
             lookahead=barmerge.lookahead_off)
        
        bool isOpposite = (c1 > o1 and c0 < o0) or (c1 < o1 and c0 > o0)
        float diff = math.abs(c1 - o0)
        bool isNear = diff <= (thresholdTicks * syminfo.mintick)
        
        // ถ้าฝั่ง HTF ตรวจเจอว่าแท่งที่ 3 (แท่งปัจจุบัน) วิ่งตัดผ่านราคาเปิด o0 ไปแล้ว สั่ง "ห้ามสร้างเส้น" ทันที
        if isOpposite and isNear and not is_mitigated_at_htf
            float linePrice = o0
            
            bool already_on_chart = false
            if array.size(htfLines) > 0
                for i = 0 to array.size(htfLines) - 1
                    exist_item = array.get(htfLines, i)
                    if exist_item.tf == _tfStr and exist_item.price == linePrice and exist_item.spawn_time == t0
                        already_on_chart := true
                        break
            
            if not already_on_chart
                line nl = line.new(bar_index, linePrice, bar_index + 1, linePrice, color=_col, style=line.style_dashed, width=1)
                // [ปรับปรุง] เพิ่มการแปลงค่าข้อความ Label ของไทม์เฟรม 5m ให้แสดงผลสวยงาม
                string lblText = _tfStr == "5" ? "5m" : _tfStr == "60" ? "1h" : _tfStr == "240" ? "4h" : _tfStr
                label nlb = label.new(bar_index, linePrice, lblText, color=color.new(color.white, 100), textcolor=_col, style=label.style_label_left, size=size.normal) 
                
                array.push(htfLines, HTFLine.new(_tfStr, nl, nlb, linePrice, t0))
                
                // จำกัดจำนวนคิวเส้นประ
                int count = 0
                if array.size(htfLines) > 0
                    for i = array.size(htfLines) - 1 to 0
                        check_item = array.get(htfLines, i)
                        if check_item.tf == _tfStr
                            count += 1
                            if count > maxLinesPerTF
                                line.delete(check_item.ln)
                                label.delete(check_item.lb)
                                array.remove(htfLines, i)

// เรียกใช้งานฟังก์ชันตามลำดับจากเล็กไปใหญ่ (เพิ่ม 5m ไว้บนสุด)
f_proc_htf("5",   show5,   col5,   5)
f_proc_htf("15",  show15,  col15,  15)
f_proc_htf("30",  show30,  col30,  30)
f_proc_htf("60",  show60,  col60,  60)
f_proc_htf("240", show240, col240, 240)
f_proc_htf("D",   show1D,  col1D,  1440)

//-------------------------------------
// 6. Real-time Global Update & Mitigation (สำหรับแท่งที่ 4, 5, 6 เป็นต้นไป)
//-------------------------------------
if array.size(htfLines) > 0
    for i = array.size(htfLines) - 1 to 0
        l = array.get(htfLines, i)
        
        // เช็กราคา m1 สดหน้างานเพื่อลบเส้นทิ้งเมื่อโดนชนในแท่งถัดๆ ไป (หรือเผื่อกรณีราคากระโดดข้ามฝั่ง)
        bool crossed_above = open[1] <= l.price and close >= l.price
        bool crossed_below = open[1] >= l.price and close <= l.price
        bool touch_mitigated = high >= l.price and low <= l.price
        
        if touch_mitigated or crossed_above or crossed_below
            line.delete(l.ln)
            label.delete(l.lb)
            array.remove(htfLines, i)
        else
            line.set_x2(l.ln, bar_index + 1)
            label.set_x(l.lb, bar_index + 1)
````

# RSI Bands + FVG Dynamic Box + ADX [Clean & Fixed]

- url: https://www.tradingview.com/script/q9BEU2mi/
- type: indicator
- pine_id: PUB;061c99dd731d4e598dcc6ff4f220bc32
- version: 1.0

## Description

1. Understanding the 3 Core Signals of the Indicator
RSI Bands (Upper, Lower, and Gray Midline)
Red Line (UB): Acts as a strong price resistance line, equivalent to RSI 70 (Overbought).
Green Line (LB): Acts as a strong price support line, equivalent to RSI 30 (Oversold).
Gray Line (Mid): Represents the trend filter, equivalent to RSI 50 (Bullish bias when price is above, Bearish bias when below).
FVG Dynamic Boxes (Aqua / Orange Boxes)
Aqua Box (Bullish FVG): A liquidity gap created when smart money aggressively pumps the price. It serves as a strong support zone when price retraces. The box automatically disappears when completely broken downwards.
Orange Box (Bearish FVG): A liquidity gap created when smart money aggressively dumps the price. It serves as a strong resistance zone during relief rallies. The box automatically disappears when completely broken upwards.
Purple Candle (ADX Reversal from Squeeze)
Indicates a trend pivot point where trend strength (ADX) hooks up from the squeeze zone (below 20), signaling the start of a strong directional move.
2. Practical Trading Strategies (Entry, Stop Loss, Take Profit)
🟢 Long (Buy) Strategy: Dip Buying with Trend Continuation
This setup enters at the exact pullback zone where market makers shake out retail traders before expanding the price upwards.
Setup Checklist: Wait for an Aqua Box (Bullish FVG) to form, and let the price pull back into this box area.
Entry Trigger: Enter a Long position when the price finds support inside the Aqua Box AND a Purple Candle (ADX Reversal) prints, or when the price convincingly breaks above the Gray Midline.
Stop Loss: Place your stop loss right below the Bottom of the Aqua Box (Invalidation point where institutional support fails).
Take Profit: Scale out or exit the position when the price reaches or pierces the Red Upper Band (Resistance).
🔴 Short (Sell) Strategy: Rejection at Supply Zone
This setup capitalizes on trapped buyers during a relief rally into institutional supply zones before the next leg down.
Setup Checklist: Wait for an Orange Box (Bearish FVG) to form, and let the price rally up into this orange box area.
Entry Trigger: Enter a Short position when the price gets rejected inside the Orange Box AND a Purple Candle (ADX Reversal) prints, or when the price breaks down below the Gray Midline.
Stop Loss: Place your stop loss right above the Top of the Orange Box.
Take Profit: Exit the position when the price slides down to the Green Lower Band (Support).
💡 Golden Trading Tips for This System
Box Lifespan: Thanks to the dynamic code logic, boxes stop expanding when the price mitigates (fills) the gap. Therefore, longer boxes indicate much stronger, unmitigated institutional orders than short-lived ones.
The Rule of the Purple Candle: A purple candle does not blindly mean "buy." It simply means "volatility is exploding in one direction." Always use the Gray Midline as a directional filter: if a purple candle appears while the price is above the midline, look for longs. If it appears below the midline, look for shorts.

## Source Code

````pine
//@version=5
indicator("RSI Bands + FVG Dynamic Box + ADX [Clean & Fixed]", shorttitle="RSIB_FVG_Box_Fixed", overlay=true, max_boxes_count=100)

// ==========================================
// 1. RSI Bands (LazyBear 오리지널 100% 복원형)
// ==========================================
obLevel = input.int(70, title="RSI Overbought")
osLevel = input.int(30, title="RSI Oversold")
length = input.int(14, title="RSI Length")

src = close
ep = 2 * length - 1

auc = ta.ema(math.max(src - src[1], 0), ep)
adc = ta.ema(math.max(src[1] - src, 0), ep)

x1 = (length - 1) * (adc * obLevel / (100 - obLevel) - auc)
ub = x1 >= 0 ? src + x1 : src + x1 * (100 - obLevel) / obLevel

x2 = (length - 1) * (adc * osLevel / (100 - osLevel) - auc)
lb = x2 >= 0 ? src + x2 : src + x2 * (100 - osLevel) / osLevel

plot(ub, title="Resistance", color=color.red, linewidth=2)
plot(lb, title="Support", color=color.green, linewidth=2)
plot(math.avg(ub, lb), title="RSI Midline", color=color.gray, linewidth=1)

// ==========================================
// 2. FVG 감지 및 동적 박스 그리기 (캔들 색상 변경 없음)
// ==========================================
fvg_threshold = input.float(0.0, title="FVG 최소 크기 필터")

// FVG 수학적 정의 (1번 캔들과 3번 캔들 사이의 공백)
bullish_fvg = (low > high[2]) and (low - high[2] > fvg_threshold)
bearish_fvg = (high < low[2]) and (low[2] - high > fvg_threshold)

// 동적 박스 저장용 배열 정의
var box[] bull_boxes = array.new_box()
var box[] bear_boxes = array.new_box()

// [수정] 들여쓰기 오류 해결: if문 내부 실행문 스페이스 4칸 정렬 보강
if bullish_fvg
    b = box.new(left=bar_index - 2, top=low, right=bar_index, bottom=high[2], bgcolor=color.new(color.aqua, 85), border_color=color.new(color.aqua, 60))
    array.push(bull_boxes, b)

if bearish_fvg
    b = box.new(left=bar_index - 2, top=low[2], right=bar_index, bottom=high, bgcolor=color.new(color.orange, 85), border_color=color.new(color.orange, 60))
    array.push(bear_boxes, b)

// 과거 생성된 박스들을 현재 캔들까지 실시간으로 확장하고, 가격이 갭을 채우면 멈추는 실시간 연산
if array.size(bull_boxes) > 0
    for i = array.size(bull_boxes) - 1 to 0
        b = array.get(bull_boxes, i)
        if low < box.get_bottom(b)
            array.remove(bull_boxes, i)
        else
            box.set_right(b, bar_index)

if array.size(bear_boxes) > 0
    for i = array.size(bear_boxes) - 1 to 0
        b = array.get(bear_boxes, i)
        if high > box.get_top(b)
            array.remove(bear_boxes, i)
        else
            box.set_right(b, bar_index)

// ==========================================
// 3. ADX 반등 감지 로직
// ==========================================
adxLength = input.int(14, title="ADX 기간")
adxThresh = input.int(20, title="ADX 반등 기준 바닥권")

[diPlus, diMinus, adx] = ta.dmi(adxLength, adxLength)
adx_turned_up = (adx[1] < adxThresh) and (adx > adx[1]) and (adx[1] <= adx[2])

// ==========================================
// 4. 캔들 색상 출력 (ADX 반등 캔들만 보라색으로 변경)
// ==========================================
candle_color = adx_turned_up ? color.purple : na

barcolor(candle_color)
````

# buivansongrsismooth

- url: https://www.tradingview.com/script/gnuwKfwQ-buivansongrsismooth/
- type: indicator
- pine_id: PUB;0800ce1116744fb89e9a44e630c13b7a
- version: 1.0

## Description

ấ f ád f áádf ád ád   s    d  f s d f d f d  f d f d f dfd

## Source Code

````pine
//@version=5
indicator("Smooth RSI - Cross Up Signals", shorttitle="RSI_Cross_Up", overlay=false)

// ======================================================
// 1. INPUTS (Cài đặt tham số)
// ======================================================
rsiLength    = input.int(14, "RSI Length")
smoothLength = input.int(5, "RSI Smooth Length (Độ mượt)")
emaLength    = input.int(9, "EMA Length")
wmaLength    = input.int(45, "WMA Length")
src          = input.source(close, "Source")

// ======================================================
// 2. CALCULATIONS (Tính toán cốt lõi)
// ======================================================
rsiRaw = ta.rsi(src, rsiLength)
rsiSmooth = ta.ema(rsiRaw, smoothLength)

ema = ta.ema(rsiSmooth, emaLength)
wma = ta.wma(rsiSmooth, wmaLength)

// ======================================================
// 3. LOGIC CẮT LÊN CẢ 2 ĐƯỜNG (CROSS UP)
// ======================================================
// Điều kiện 1: Hiện tại RSI phải lớn hơn cả EMA và WMA
isAboveBoth = (rsiSmooth > ema) and (rsiSmooth > wma)

// Điều kiện 2: Nến trước đó (RSI[1]) phải nằm dưới ít nhất 1 trong 2 đường
wasBelowEither = (rsiSmooth[1] <= ema[1]) or (rsiSmooth[1] <= wma[1])

// Kết hợp: Phải thỏa mãn cả 2 điều kiện thì mới tính là một cú CẮT LÊN hợp lệ
crossUpSignal = isAboveBoth and wasBelowEither

// ======================================================
// 4. PLOTS (Hiển thị đồ thị ở Panel dưới)
// ======================================================
plot(rsiSmooth, "Smooth RSI", color=color.white, linewidth=2)
plot(ema, "EMA9", color=color.yellow, linewidth=1)
plot(wma, "WMA45", color=color.blue, linewidth=2)

hline(70, "70", color=color.red, linestyle=hline.style_dashed)
hline(50, "50", color=color.gray, linestyle=hline.style_dotted)
hline(30, "30", color=color.green, linestyle=hline.style_dashed)

// ======================================================
// 5. ĐÁNH DẤU TÍN HIỆU
// ======================================================
// Ghim mũi tên tam giác hướng lên (shape.triangleup) màu xanh lá bám vào đường RSI
plotshape(crossUpSignal ? rsiSmooth : na, 
          title="RSI Cross Up", 
          style=shape.triangleup, 
          location=location.absolute, 
          color=color.green, 
          size=size.tiny)
````

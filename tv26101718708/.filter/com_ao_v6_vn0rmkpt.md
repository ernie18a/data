# COM AO V6

- url: https://www.tradingview.com/script/vN0rmkPt/
- type: indicator
- pine_id: PUB;9a231c7bdf154937ada420b3b0bb10ed
- version: 1.0

## Description

Long manh vào Long, short manh vào short de kiem tiền

## Source Code

````pine
//@version=5
indicator("KHÁNH - BỘ LỌC THỊ TRƯỜNG TIẾNG VIỆT", overlay=true)

emaLen = input.int(50, "EMA xu hướng")
swingLen = input.int(5, "Độ nhạy đỉnh đáy")
volLen = input.int(20, "Volume trung bình")

ema = ta.ema(close, emaLen)
rsi = ta.rsi(close, 14)
[macd, signal, hist] = ta.macd(close, 12, 26, 9)
volMA = ta.sma(volume, volLen)

swingHigh = ta.pivothigh(high, swingLen, swingLen)
swingLow = ta.pivotlow(low, swingLen, swingLen)

var float lastHigh = na
var float prevHigh = na
var float lastLow = na
var float prevLow = na

if not na(swingHigh)
    prevHigh := lastHigh
    lastHigh := swingHigh

if not na(swingLow)
    prevLow := lastLow
    lastLow := swingLow

HH = not na(lastHigh) and not na(prevHigh) and lastHigh > prevHigh
HL = not na(lastLow) and not na(prevLow) and lastLow > prevLow
LH = not na(lastHigh) and not na(prevHigh) and lastHigh < prevHigh
LL = not na(lastLow) and not na(prevLow) and lastLow < prevLow

giaTrenEMA = close > ema
giaDuoiEMA = close < ema

emaTang = ema >= ema[1]
emaGiam = ema <= ema[1]

histTang = hist > hist[1]
histGiam = hist < hist[1]

volumeDat = volume > volMA
volumeManh = volume > volMA * 1.5

quetDay = not na(prevLow) and low < prevLow and close > prevLow
quetDinh = not na(prevHigh) and high > prevHigh and close < prevHigh

haiDinhBangNhau = not na(lastHigh) and not na(prevHigh) and math.abs(lastHigh - prevHigh) / close * 100 < 0.3
haiDayBangNhau = not na(lastLow) and not na(prevLow) and math.abs(lastLow - prevLow) / close * 100 < 0.3

choGiaTangManh = (quetDay or rsi > 40) and histTang and volume >= volMA * 0.8 and not haiDinhBangNhau
choGiaGiamManh = (quetDinh or rsi < 60) and histGiam and volume >= volMA * 0.8 and not haiDayBangNhau

vungCanhLong = choGiaTangManh and rsi > 45 and histTang and (giaTrenEMA or quetDay) and not haiDinhBangNhau
vungCanhShort = choGiaGiamManh and rsi < 55 and histGiam and (giaDuoiEMA or quetDinh) and not haiDayBangNhau

uuTienLong = vungCanhLong and giaTrenEMA and emaTang and volumeDat and (HH or HL or close > ta.highest(high, 10)[1])
uuTienShort = vungCanhShort and giaDuoiEMA and emaGiam and volumeDat and (LL or LH or close < ta.lowest(low, 10)[1])

longManh = uuTienLong and volumeManh and rsi > 55 and hist > 0
shortManh = uuTienShort and volumeManh and rsi < 45 and hist < 0

chuaDuSetup = not choGiaTangManh and not choGiaGiamManh and not vungCanhLong and not vungCanhShort and not uuTienLong and not uuTienShort

plot(ema, color=color.yellow, linewidth=2, title="EMA xu hướng")

bgcolor(choGiaTangManh ? color.new(color.aqua, 92) : na)
bgcolor(choGiaGiamManh ? color.new(color.orange, 92) : na)
bgcolor(uuTienLong ? color.new(color.green, 88) : na)
bgcolor(uuTienShort ? color.new(color.red, 88) : na)
bgcolor(chuaDuSetup ? color.new(color.gray, 94) : na)

plotshape(choGiaTangManh and not vungCanhLong, style=shape.labelup, location=location.belowbar, color=color.aqua, text="CHỜ\nGIÁ TĂNG", textcolor=color.black, size=size.tiny)
plotshape(choGiaGiamManh and not vungCanhShort, style=shape.labeldown, location=location.abovebar, color=color.orange, text="CHỜ\nGIÁ GIẢM", textcolor=color.white, size=size.tiny)

plotshape(vungCanhLong and not uuTienLong, style=shape.labelup, location=location.belowbar, color=color.rgb(0,120,255), text="VÙNG\nCANH LONG", textcolor=color.white, size=size.small)
plotshape(vungCanhShort and not uuTienShort, style=shape.labeldown, location=location.abovebar, color=color.rgb(255,100,0), text="VÙNG\nCANH SHORT", textcolor=color.white, size=size.small)

plotshape(longManh, style=shape.labelup, location=location.belowbar, color=color.rgb(0,0,255), text="LONG\nMẠNH", textcolor=color.white, size=size.normal)
plotshape(shortManh, style=shape.labeldown, location=location.abovebar, color=color.rgb(255,0,0), text="SHORT\nMẠNH", textcolor=color.white, size=size.normal)

var table tb = table.new(position.top_center, 1, 1)

if barstate.islast
    txt = longManh ? "LONG MẠNH\nCó lực tăng rõ" :
          shortManh ? "SHORT MẠNH\nCó lực giảm rõ" :
          uuTienLong ? "ƯU TIÊN LONG\nChỉ canh Long" :
          uuTienShort ? "ƯU TIÊN SHORT\nChỉ canh Short" :
          vungCanhLong ? "VÙNG CANH LONG\nĐợi nến xác nhận" :
          vungCanhShort ? "VÙNG CANH SHORT\nĐợi nến xác nhận" :
          choGiaTangManh ? "CHỜ GIÁ TĂNG\nCó dấu hiệu sớm" :
          choGiaGiamManh ? "CHỜ GIÁ GIẢM\nCó dấu hiệu sớm" :
          "CHƯA ĐỦ SETUP\nKhông có nghĩa là giá không tăng/giảm"

    bg = longManh or uuTienLong ? color.new(color.green, 15) :
         shortManh or uuTienShort ? color.new(color.red, 15) :
         vungCanhLong or choGiaTangManh ? color.new(color.aqua, 10) :
         vungCanhShort or choGiaGiamManh ? color.new(color.orange, 10) :
         color.new(color.gray, 20)

    table.cell(tb, 0, 0, txt, text_color=color.white, bgcolor=bg, text_size=size.large)

alertcondition(choGiaTangManh, title="CHỜ GIÁ TĂNG", message="Có dấu hiệu chuẩn bị tăng")
alertcondition(choGiaGiamManh, title="CHỜ GIÁ GIẢM", message="Có dấu hiệu chuẩn bị giảm")
alertcondition(vungCanhLong, title="VÙNG CANH LONG", message="Đang có vùng canh Long")
alertcondition(vungCanhShort, title="VÙNG CANH SHORT", message="Đang có vùng canh Short")
alertcondition(uuTienLong, title="ƯU TIÊN LONG", message="Ưu tiên canh Long")
alertcondition(uuTienShort, title="ƯU TIÊN SHORT", message="Ưu tiên canh Short")
alertcondition(longManh, title="LONG MẠNH", message="Có lực Long mạnh")
alertcondition(shortManh, title="SHORT MẠNH", message="Có lực Short mạnh")
````

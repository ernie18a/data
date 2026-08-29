<!-- tradingview-pine-id: PUB;517a8ed12ee8449ea6217529271da139 -->
<!-- tradingviewscripts-format: 1 -->
# Stochastic RSI  Clean signals for gold 

Source: https://www.tradingview.com/script/5B6vJTQE/

## Description

upgrade  alert signal  for remind 
just test  with gold candle chart M3 M5  .

---

## Source Code

````pine
//@version=6
indicator(title="Stochastic RSI  Clean signals for gold ",
     shorttitle="StochRSI clean",
     overlay=false)

// ===================== 工具函数：必须放在首次调用之前 =====================

// 自定义无 str.zfill 的填充函数
padLeft(strNum, totalLen) =>
    s = str.tostring(strNum)
    deficit = totalLen - str.length(s)
    if deficit <= 0
        s
    else
        zeros = str.repeat("0", deficit)
        zeros + s

ts_text() =>
    yearStr  = str.tostring(year)
    monStr   = padLeft(month, 2)
    dayStr   = padLeft(dayofmonth, 2)
    hourStr  = padLeft(hour, 2)
    minStr   = padLeft(minute, 2)
    yearStr + "-" + monStr + "-" + dayStr + " " + hourStr + ":" + minStr

logWarning(signalType, reason, context) =>
    label.new(
        bar_index, high,
        text=signalType + " | " + reason + " | " + context,
        style=label.style_label_down,
        color=color.new(color.black, 0),
        textcolor=color.white,
        size=size.tiny
    )

// ==== Inputs ====
smoothK      = input.int(3,  "K", minval=1)
smoothD      = input.int(3,  "D", minval=1)
lengthRSI    = input.int(10, "RSI Length", minval=1)
lengthStoch  = input.int(28, "Stochastic Length", minval=1)
src          = input.source(close, "RSI Source")
compress     = input.float(0.30, "K-D Compress (0~1)", minval=0.0, maxval=1.0, step=0.05)
diffSmooth   = input.int(3, "K-D Extra Smooth (EMA)", minval=1)

GRP = "Smoothing (from rsi-line)"
TT_BB = "Only applies when 'SMA + Bollinger Bands' is selected."
maTypeInput   = input.string("SMA", "Type", options = ["None", "SMA", "SMA + Bollinger Bands", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group = GRP)
maLengthInput = input.int(14, "Length", group = GRP, minval=1, inline="ma")
bbMultInput   = input.float(2.0, "BB StdDev", minval = 0.001, maxval = 50, step = 0.5, tooltip = TT_BB, group = GRP, inline="ma")

// ==== K/D ====
rsi1 = ta.rsi(src, lengthRSI)
k0   = ta.stoch(rsi1, rsi1, rsi1, lengthStoch)
k    = ta.sma(k0, smoothK)
d    = ta.sma(k,  smoothD)

// ==== RSI + smoothing MA ====
change = ta.change(src)
up     = ta.rma(math.max(change, 0), lengthRSI)
down   = ta.rma(-math.min(change, 0), lengthRSI)
rsi    = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))

ma(source, length, MAtype) =>
    switch MAtype
        "SMA"                   => ta.sma(source, length)
        "SMA + Bollinger Bands" => ta.sma(source, length)
        "EMA"                   => ta.ema(source, length)
        "SMMA (RMA)"            => ta.rma(source, length)
        "WMA"                   => ta.wma(source, length)
        "VWMA"                  => ta.vwma(source, length)
        => na

enableMA = maTypeInput != "None"
isBB     = maTypeInput == "SMA + Bollinger Bands"
smoothingMA = enableMA ? ma(rsi, maLengthInput, maTypeInput) : na

mid = na(smoothingMA) ? rsi : (rsi + smoothingMA) / 2.0

// ==== Plots ====
plot(rsi, "RSI", color=#7E57C2)
plot(smoothingMA, "RSI MA", color=color.yellow)

bbBasis = ta.sma(mid, maLengthInput)
bbDev   = bbMultInput * ta.stdev(mid, maLengthInput)
bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev
pBasis = plot(isBB ? bbBasis : na, title="BB Basis (mid)", color=color.new(color.yellow, 0))
pUpper = plot(isBB ? bbUpper : na, title="BB Upper (mid)", color=color.new(color.aqua, 0))
pLower = plot(isBB ? bbLower : na, title="BB Lower (mid)", color=color.new(color.aqua, 0))
fill(pUpper, pLower, title="BB Fill (mid)", color=color.new(color.aqua, 85))

h0 = hline(80, "Upper Band", color=#787B86)
hline(50, "Middle Band", color=color.new(#787B86, 50))
h1 = hline(20, "Lower Band", color=#787B86)
fill(h0, h1, title="Background", color=color.rgb(33, 150, 243, 90))
hline(70, "Level 70", color=color.new(color.yellow, 0), linestyle=hline.style_dotted)
hline(50, "Level 50", color=color.new(color.yellow, 0), linestyle=hline.style_dotted)
hline(30, "Level 30", color=color.new(color.yellow, 0), linestyle=hline.style_dotted)

// ==== KD candle ====
diffRaw = (k - d) * compress
diffSm  = ta.ema(diffRaw, diffSmooth)

o  = mid - diffSm
c  = mid + diffSm
hi = math.max(o, c)
lo = math.min(o, c)

col = diffSm >= 0 ? color.red : color.white
plotcandle(o, hi, lo, c, title="K-D Candle", color=col, wickcolor=col, bordercolor=col)

// ==== Long Wick Detection (upper/lower) + 垂直线标记（不同颜色） ====
// 仅关注：mid >= 65 且上影线长；mid <= 30 且下影线长
// 且要求：连续2根K线的对应影线都较长
bodyLen      = math.abs(close - open)
upperWickLen = high - math.max(open, close)
lowerWickLen = math.min(open, close) - low

wickToBodyThreshold = input.float(0.6, "Wick/Body Threshold", minval=0.0, step=0.05)

// 当实体为 0（十字星）时：用影线占全振幅比例，避免除 0
rng = high - low
upperRatio = bodyLen > 0 ? (upperWickLen / bodyLen) : (rng > 0 ? upperWickLen / rng : 0.0)
lowerRatio = bodyLen > 0 ? (lowerWickLen / bodyLen) : (rng > 0 ? lowerWickLen / rng : 0.0)

upperLongWick = upperRatio > wickToBodyThreshold
lowerLongWick = lowerRatio > wickToBodyThreshold

// 单根条件（当前bar）
upperCase_1 = (mid >= 65) and upperLongWick
lowerCase_1 = (mid <= 35) and lowerLongWick

// 连续2根都满足（当前bar + 前一根bar）
upperCase = upperCase_1 and upperCase_1[1]
lowerCase = lowerCase_1 and lowerCase_1[1]

var line upperWickLine = na
var line lowerWickLine = na

cUpper = color.new(color.fuchsia, 0) // 上影线长（>=65，连续2根）
cLower = color.new(color.aqua, 0)    // 下影线长（<=30，连续2根）



// ==== Signal logic ====
isRed   = diffSm >= 0
isWhite = diffSm < 0

var int whiteStreak = 0
var int redStreak   = 0

whiteStreak := isWhite ? nz(whiteStreak[1]) + 1 : 0
redStreak   := isRed   ? nz(redStreak[1])   + 1 : 0

buySignal  = (mid < 35) and isRed   and (nz(whiteStreak[1]) >= 2)
sellSignal = (mid > 65) and isWhite and (nz(redStreak[1])   >= 2)

 
// ==== Vertical line signals (full panel height) ====
var line buyLine  = na
var line sellLine = na

if buySignal
    buyLine := line.new(x1=bar_index, y1=0, x2=bar_index, y2=100, xloc=xloc.bar_index, extend=extend.none, color=color.lime, style=line.style_solid, width=2)

if sellSignal
    sellLine := line.new(x1=bar_index, y1=0, x2=bar_index, y2=100, xloc=xloc.bar_index, extend=extend.none, color=color.red, style=line.style_solid, width=2)


// （可选）报警： 
alertcondition(buySignal, title="buy signal", message="buy signal")
alertcondition(sellSignal, title="sell signal", message="sell signal")
````

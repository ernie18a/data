# Distributing Zone-0943048080

- url: https://www.tradingview.com/script/M5hx5nR9-Distributing-Zone-0943048080/
- type: indicator
- pine_id: PUB;32babf2938384de3818fde783113b632
- version: 1.0

## Description

Confirmation Conditions

Horizontal support zone held multiple times

Zone spans 30 or more candles
Price range within the zone is 0%–40% (measured by the highest and lowest closing prices in the box)


Higher Lows inside the box

Each time support is tested, the low is progressively higher while still within the box
Characteristic price action signal: buyers are gradually absorbing selling pressure


Strong rejection wick at the bottom of the box

A candle with a long lower wick at the support zone = buying pressure absorbing at that level
Candle body closes near the midpoint or higher = buyers in control


Volume drying up inside the box = sellers exhausted

Volume gradually decreases throughout the time price remains in the box
Selling pressure depletes → no more sellers willing to sell at that price
Note: volume is high on the first test (absorption), then progressively declines on subsequent tests


OBV rising while price moves sideways

OBV (On Balance Volume) rising steadily despite flat price = money flowing in quietly
This is the strongest accumulation signal: smart money buying without pushing price up


Bullish Divergence on RSI / MACD

Price forms an equal or lower low, but RSI/MACD forms a higher low
Indicates selling momentum is weakening even though price has not yet risen


RSI trending upward within the accumulation zone

RSI gradually recovering from a low range (30–50) toward a mid range (50–60)


MACD rising and crossing up

MACD histogram narrowing then turning positive
MACD line crossing above the Signal line


Bollinger Band squeeze

Price compressed tightly in the box → both BB bands narrowing
The longer the squeeze, the more powerful the eventual breakout


Short-term EMA acting as dynamic support

Short EMA (8–21) sitting close to the bottom of the box, acting as dynamic support
Helps prevent price from breaking deeper below the accumulation zone


Spring / Shakeout (Wyckoff — optional but powerful)

Price briefly breaks below the box's low then closes back inside the box
Bear trap: sellers get trapped, buyers absorb everything
If a Spring appears with high volume → breakout probability is very high

## Source Code

````pine
// @version=6
indicator("Distributing Zone", overlay=true,
     max_boxes_count=20, max_labels_count=50, max_lines_count=50)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
g1 = "📦 Box"
boxLen   = input.int  (50,   "Lookback (số nến)",              group=g1, minval=30, maxval=500)
maxRange = input.float(40.0, "Range tối đa (%)",                group=g1, minval=1,  maxval=100, step=0.5)

g2 = "〰️ BB Squeeze"
bbLen    = input.int  (20,   "BB Length",                       group=g2, minval=5)
bbMult   = input.float(2.0,  "BB Mult",                         group=g2, step=0.1)
sqzPct   = input.float(15.0, "Squeeze tối đa (% giá)",          group=g2, step=0.5)

g3 = "📉 EMA"
emaLen   = input.int  (8,    "EMA Length",                      group=g3, minval=3)
useEma   = input.bool (true, "EMA bám đỉnh box",                group=g3)
emaDist  = input.float(5.0,  "Khoảng cách EMA–đỉnh box (%)",    group=g3, step=0.5)

g4 = "🔽 Momentum"
useOBV      = input.bool(true,  "OBV giảm",                                 group=g4)
useRSI      = input.bool(true,  "RSI giảm",                                 group=g4)
rsiLen      = input.int (14,    "RSI Length",                               group=g4, minval=2)
useMACD     = input.bool(false, "MACD cắt xuống",                           group=g4)
useLH       = input.bool(true,  "Lower Highs trong box",                    group=g4)
useVolDec   = input.bool(true,  "Volume giảm dần",                          group=g4)
useUpthrust = input.bool(false, "Upthrust (wick phá đỉnh rồi đảo chiều)",   group=g4)

// ─── TÍNH TOÁN ────────────────────────────────────────────────────────────────
halfLen = boxLen / 2

// Box (close-based range, high/low cho visual)
boxH_cls    = ta.highest(close[1], boxLen)
boxL_cls    = ta.lowest (close[1], boxLen)
boxH_vis    = ta.highest(high[1],  boxLen)
boxL_vis    = ta.lowest (low[1],   boxLen)
boxRangePct = (boxH_cls - boxL_cls) / boxL_cls * 100

// BB squeeze
[bbMid, bbUp, bbDn] = ta.bb(close, bbLen, bbMult)
bbWidth    = (bbUp - bbDn) / close * 100
minBbWidth = ta.lowest(bbWidth, boxLen + 1)

// EMA dynamic resistance (sát đỉnh box)
ema        = ta.ema(close, emaLen)
emaDistPct = math.abs(ema[1] - boxH_cls) / boxH_cls * 100

// Volume: nửa gần so với toàn kỳ (declining = lực mua cạn dần)
volSmaFull   = ta.sma(volume[1], boxLen)
volSmaRecent = ta.sma(volume[1], halfLen)

// OBV slope — âm = tiền rút âm thầm (smart money đang phân phối)
obv      = ta.cum(close > close[1] ? volume : close < close[1] ? -volume : 0.0)
obvSlope = obv - obv[halfLen]

// RSI slope — âm = momentum suy yếu
rsi      = ta.rsi(close, rsiLen)
rsiSlope = rsi - rsi[halfLen]

// MACD — cắt xuống = bearish
[macdLine, signalLine, histLine] = ta.macd(close, 12, 26, 9)
macdFalling = macdLine < signalLine and macdLine < macdLine[halfLen]

// Lower Highs: nửa sau không tạo đỉnh mới cao hơn nửa đầu
recentHalfHigh = ta.highest(high[1], halfLen)
fullPeriodHigh = ta.highest(high[1], boxLen)
lowerHighs     = recentHalfHigh < fullPeriodHigh

// Upthrust: wick phá lên trên kháng cự close-based rồi đóng cửa lại bên trong
hasUpthrust = ta.highest(high[1], boxLen) > boxH_cls

// ─── 9 ĐIỀU KIỆN ──────────────────────────────────────────────────────────────
cBox       = boxRangePct >= 0 and boxRangePct <= maxRange
cSqueeze   = minBbWidth < sqzPct
cEma       = not useEma       or (emaDistPct   < emaDist)
cVolDec    = not useVolDec    or (volSmaRecent < volSmaFull)
cOBV       = not useOBV       or (obvSlope     < 0)
cRSI       = not useRSI       or (rsiSlope     < 0)
cMACD      = not useMACD      or macdFalling
cLH        = not useLH        or lowerHighs
cUpthrust  = not useUpthrust  or hasUpthrust

distrib    = cBox and cSqueeze and cEma and cVolDec and cOBV and cRSI and cMACD and cLH and cUpthrust
newDistrib = distrib and not distrib[1]

// ─── VẼ CHART ─────────────────────────────────────────────────────────────────
if newDistrib
    box.new(bar_index - boxLen, boxH_vis, bar_index - 1, boxL_vis,
         border_color=color.new(color.red, 10), border_width=2,
         bgcolor=color.new(color.red, 85))
    infoText =
         "🔴 Vùng Phân Phối" +
         "\n📦 Range: "   + str.tostring(math.round(boxRangePct, 1)) + "%" +
         "\n〰️ BB Sqz: " + str.tostring(math.round(minBbWidth,  1)) + "%" +
         "\n📉 LH: "      + (lowerHighs  ? "✅" : "❌") +
         "\n🔽 OBV: "    + (obvSlope < 0 ? "✅" : "❌") +
         "\n📈 RSI: "    + (rsiSlope < 0 ? "✅" : "❌")
    label.new(bar_index, boxH_vis,
         text=infoText, style=label.style_label_down,
         color=color.new(color.red, 5), textcolor=color.white, size=size.normal)

plot(ema,  "EMA Dynamic Resistance", color.new(color.red,  20), 2)
plot(bbUp, "BB Upper",               color.new(color.blue, 70), 1)
plot(bbDn, "BB Lower",               color.new(color.blue, 70), 1)

// ─── ALERT ────────────────────────────────────────────────────────────────────
alertcondition(newDistrib,
     title="🔴 Distributing Zone Detected",
     message="Vùng phân phối xác nhận trên {{ticker}} [{{interval}}] — Price: {{close}}")
````

# 21EMA + 1/2/3/4/5 ATR Dots (Bands)

- url: https://www.tradingview.com/script/gwGMlRHx/
- type: indicator
- pine_id: PUB;f116734eba1840f18f57a5a3fee174dd
- version: 1.0

## Description

過熱感を図る指標です．利確の参考にご活用ください．

## Source Code

````pine
//@version=6
indicator("21EMA + 1/2/3/4/5 ATR Dots (Bands)", shorttitle="21EMA+ATRx Bands", overlay=true, max_bars_back=300)

//====================== Inputs ======================
groupCalc = "計算"
tf     = input.timeframe("D", "EMA/ATRの参照足", group=groupCalc)
emaLen = input.int(21, "EMA Length", minval=1, group=groupCalc)
atrLen = input.int(14, "ATR Length", minval=1, group=groupCalc)
src    = input.source(close, "判定に使う価格", group=groupCalc)

groupDisp = "表示"
showLines = input.bool(true, "閾値ラインを表示", group=groupDisp)
showDots  = input.bool(true, "ドットを表示", group=groupDisp)
dotChar   = input.string("・", "ドット文字", group=groupDisp)

//====================== Calculations ======================
s = syminfo.tickerid

emaTF = request.security(s, tf, ta.ema(close, emaLen), barmerge.gaps_off, barmerge.lookahead_off)
atrTF = request.security(s, tf, ta.atr(atrLen),      barmerge.gaps_off, barmerge.lookahead_off)

// 21EMA + n*ATR
lvl1 = emaTF + atrTF * 1.0
lvl2 = emaTF + atrTF * 2.0
lvl3 = emaTF + atrTF * 3.0
lvl4 = emaTF + atrTF * 4.0
lvl5 = emaTF + atrTF * 5.0

//====================== Plot lines ======================
plot(showLines ? lvl1 : na, "21EMA + 1ATR", color=color.new(color.lime,   0), linewidth=1)
plot(showLines ? lvl2 : na, "21EMA + 2ATR", color=color.new(color.green,  0), linewidth=1)
plot(showLines ? lvl3 : na, "21EMA + 3ATR", color=color.new(color.yellow, 0), linewidth=1)
plot(showLines ? lvl4 : na, "21EMA + 4ATR", color=color.new(color.orange, 0), linewidth=1)
plot(showLines ? lvl5 : na, "21EMA + 5ATR", color=color.new(color.red,    0), linewidth=1)

//====================== Continuous band dots ======================
// 1本につきドットは1つ（到達帯で色分け）
bool c1 = false
bool c2 = false
bool c3 = false
bool c4 = false
bool c5 = false

if showDots
    c5 := src >= lvl5
    c4 := src >= lvl4 and src < lvl5
    c3 := src >= lvl3 and src < lvl4
    c2 := src >= lvl2 and src < lvl3
    c1 := src >= lvl1 and src < lvl2

//====================== Plot dots (above bar) ======================
plotchar(c5, title="≥ 21EMA+5ATR", char=dotChar, location=location.abovebar, size=size.small, color=color.rgb(215, 35, 35))
plotchar(c4, title="4–5 ATR band", char=dotChar, location=location.abovebar, size=size.small, color=color.rgb(241,160,107))
plotchar(c3, title="3–4 ATR band", char=dotChar, location=location.abovebar, size=size.small, color=color.rgb(243,196,122))
plotchar(c2, title="2–3 ATR band", char=dotChar, location=location.abovebar, size=size.small, color=color.rgb(120,200,120))
plotchar(c1, title="1–2 ATR band", char=dotChar, location=location.abovebar, size=size.small, color=color.rgb(120,255,120))
````

# Sniper Entry_Tranmanhmkt

- url: https://www.tradingview.com/script/SkmN0lOb/
- type: indicator
- pine_id: PUB;c89dea6b496f4701ad38065c5839fd7f
- version: 1.0

## Description

🎯 Sniper Entry_Tranmanhmkt
Chỉ báo hỗ trợ xác định điểm vào lệnh BUY/SELL theo xu hướng với tín hiệu rõ ràng, tối ưu cho vàng XAUUSD khung M5 & M15.

✔️ Lọc nhiễu thị trường
✔️ Hạn chế vào lệnh ngược xu hướng
✔️ Tín hiệu trực quan, dễ sử dụng
✔️ Phù hợp scalping và intraday

Sniper Entry giúp trader tập trung vào những “điểm bắn đẹp” thay vì vào lệnh cảm tính.
Kết hợp quản lý vốn và kỷ luật sẽ giúp tối ưu hiệu quả giao dịch. 🚀📈

⚠️ Chỉ báo hỗ trợ xác suất cao, không đảm bảo thắng 100%.
#SniperEntry #Tranmanhmkt #XAUUSD #TradingView #Forex #GoldTrading

## Source Code

````pine
//@version=5
indicator("XAUUSD Sniper Entry", overlay=true, max_labels_count=500)

//==================== INPUT ====================
rsiLength=input.int(7,title="RSI Length")
emaLength=input.int(50,title="EMA Trend")
pivotLength=input.int(3,title="Pivot Length")
atrLength=input.int(14,title="ATR Length")

buyColor=input.color(color.lime,title="BUY Color")
sellColor=input.color(color.red,title="SELL Color")

//==================== TREND ====================
ema=ta.ema(close,emaLength)

bullTrend=close>ema
bearTrend=close<ema

//==================== RSI ====================
rsi=ta.rsi(close,rsiLength)

//==================== ATR ====================
atr=ta.atr(atrLength)

//==================== PIVOT ====================
pivotHigh=ta.pivothigh(high,pivotLength,pivotLength)
pivotLow=ta.pivotlow(low,pivotLength,pivotLength)

//==================== LIQUIDITY SWEEP ====================
sweepLow=low<ta.lowest(low,5)[1] and close>open
sweepHigh=high>ta.highest(high,5)[1] and close<open

//==================== SNIPER ENTRY ====================
buySignal=sweepLow and bullTrend and rsi<30 and close>(low+atr*0.2)

sellSignal=sweepHigh and bearTrend and rsi>70 and close<(high-atr*0.2)

//==================== BUY ====================
plotshape(buySignal,title="BUY",text="BUY",style=shape.labelup,location=location.belowbar,color=buyColor,textcolor=color.white,size=size.small)

//==================== SELL ====================
plotshape(sellSignal,title="SELL",text="SELL",style=shape.labeldown,location=location.abovebar,color=sellColor,textcolor=color.white,size=size.small)

//==================== PIVOT ====================
plotshape(not na(pivotHigh),title="Pivot High",style=shape.circle,location=location.abovebar,color=color.red,size=size.tiny,offset=-pivotLength)

plotshape(not na(pivotLow),title="Pivot Low",style=shape.circle,location=location.belowbar,color=color.lime,size=size.tiny,offset=-pivotLength)

//==================== BAR COLOR ====================
barcolor(bullTrend?color.new(color.green,0):bearTrend?color.new(color.red,0):color.gray)

//==================== ALERT ====================
alertcondition(buySignal,title="BUY ALERT",message="SNIPER BUY")

alertcondition(sellSignal,title="SELL ALERT",message="SNIPER SELL")
````

# WMA RSI [Long]

- url: https://www.tradingview.com/script/lSFmnBMY-WMA-RSI-Long/
- type: indicator
- pine_id: PUB;9585fffcbf654350b09086433e2b1193
- version: 1.0

## Description

Kết hợp các đường vào đường RSI để xác định xu hướng rsi. WMA45 EMA9 RSI14

## Source Code

````pine
//@version=6
indicator(title='WMA RSI [Long]', shorttitle='WMA RSI', overlay=false)
src = input(close, title='Source')


rsi_length = input(14, title='RSI')
ema_length = input(9, title='EMA')
wma_length = input(45, title='WMA')
rsi = ta.rsi(src, rsi_length)
ema = ta.wma(rsi, ema_length)
wma = ta.wma(rsi, wma_length)


up = input(90, title='QTT')
dn = input(80, title='Qua ban')
u = hline(up)
d = hline(dn)
fill(u, d, color=color.new(color.green, 1))

up1 = input(60, title='Muc 60')
dn1 = input(40, title='Muc 40')
u1 = hline(up1)
d1 = hline(dn1)
fill(u1, d1, color=color.new(color.white, 65))

up2 = input(20, title='Qua mua')
dn2 = input(10, title='QTG')
u2 = hline(up2)
d2 = hline(dn2)
fill(u2, d2, color=color.new(color.orange, 50))

up3 = input(80)
dn3 = input(70, title='Muc 70')
u3 = hline(up3)
d3 = hline(dn3)
fill(u3, d3, color=color.new(color.blue, 70))

up4 = input(30, title='Muc 30')
dn4 = input(20)
u4 = hline(up4)
d4 = hline(dn4)
fill(u4, d4, color=color.new(color.blue, 70))

plot(rsi, color=color.new(color.purple, 0), linewidth=2, title='RSI')
plot(ema, color=color.new(color.black, 20), linewidth=1, title='EMA')
plot(wma, color=color.new(color.red, 20), linewidth=1, title='WMA')
````

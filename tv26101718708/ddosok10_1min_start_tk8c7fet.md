# ddosok10 1min start

- url: https://www.tradingview.com/script/tK8c7FET/
- type: strategy
- pine_id: PUB;f92f2af403b44d978b6c66b1de39f0ff
- version: 1.0

## Description

(1볼추 매매법) 1분봉 볼밴 +3% 매매 체크 (유튜버 리또속10)
+거미줄 200틱마다 걸어놓기(익절+3 지정)

상단 볼밴 찍고 중앙선 터치 후
캔들 종가가 중앙선 아래에 있을때
숏 진입 후 하단 볼밴 터치할때쯤 익절(+3% 지정)
(허리에 들어가 무릎에 팔기)

하단 볼밴 찍고 중앙선 터치 후 
캔들 종가가 중앙선 위에 있을때
롱 진입 후 상단 볼밴 터치할때쯤 익절(+3% 지정)
(허리에 들어가 가슴에 팔기)

* 포지션 동시 2개들어가서 하나 익절 하나 들고가기도 가능

## Source Code

````pine
//@version=5

strategy("BB돌파", overlay=true)
length = input.int(20, minval=1)
src = input(close, title="Source")
mult = input.float(2.0, minval=0.001, maxval=50, title="StdDev")
basis = ta.sma(src, length)
dev = mult * ta.stdev(src, length)
upper = basis + dev
lower = basis - dev
offset = input.int(0, "Offset", minval = -500, maxval = 500)
plot(basis, "Basis", color=#FF6D00, offset = offset)
p1 = plot(upper, "Upper", color=#2962FF, offset = offset)
p2 = plot(lower, "Lower", color=#2962FF, offset = offset)
fill(p1, p2, title = "Background", color=color.rgb(33, 150, 243, 95))


long = ta.crossover(close,basis)
short = ta.crossunder(close,basis)

strategy.entry("long", strategy.long, when =long)
strategy.entry("short", strategy.short, when =short)
````

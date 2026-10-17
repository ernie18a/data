# cii strategy

- url: https://www.tradingview.com/script/8sEaYCci/
- type: strategy
- pine_id: PUB;m8vOGl9dYY8i6ecB7cZNYrndotdwbVQW
- version: 1.0

## Description

파인스크립트 공부한다고 만들어봤는데 혼자하니깐 피드백이 안되서 올려봅니다.
원리는 짧은 기간의 cci(14)가 긴 기간의 cci(56)을 뚫으면 매수, 뚫리면 매도하게 해놨습니다.
단기 분봉에는 거의 안 맞고 3시간봉 12시간봉에 맞춰서 쓰시면 됩니다. 횡보장때 승률이 많이 낮습니다..

## Source Code

````pine
//@version=3
strategy(title="my work",calc_on_order_fills=true,currency=currency.USD, default_qty_type=strategy.percent_of_equity,commission_type=strategy.commission.percent)


source = close
shortlength=input(14)
longlength=input(56)
aa=input(2)
Ss=input(75)

//Cci part
ci1=cci(source,shortlength)   //4시간봉의 기본 cci
ci2=cci(source,longlength)   //4시간봉에서 12시봉의 cci 무빙측정

//오린간 선생님의 WT + ichimoku
len = input(10)
lenTurn = input(9)
lenStd = input(26)

wtm_e(so, l) =>
    esa = ema(so, l)
    d = ema(abs(so - esa), l)
    ci = (so - esa) / (0.015 * d)
    ema(ci, l*2+1)

alh(len) => avg(lowest(len), highest(len))
alh_src(src, len) => avg(lowest(src, len), highest(src, len))

wt = wtm_e(close,len)
turn = alh_src(wt, lenTurn)
std = alh_src(wt, lenStd)

cnt = 0
if wt > turn
    cnt:=cnt+1
if wt > std
    cnt:=cnt+1


//100,-100선
h0 = hline(100)
h1 = hline(-100)

//plot(ci,color=green)
// plot(k,color=green)
// plot(d,color=red)
plot(ci1,color=green)
plot(ci2,color=red)

plot(0,color=black)
plot(100,color=black)
plot(-100,color=black)

fill(h0,h1,color=purple,transp=95)

bgcolor(cnt==0 ? red : cnt==1 ? blue : cnt == 2 ? green : na, transp = Ss)

//기간조정

Fromday = input(defval=1, title="from day", minval=1, maxval=31)
FromMonth = input(defval=1, title="from month", minval=1, maxval=12)
FromYr = input(defval=2019, title="from yr", minval=1970)

Today = input(defval=13, title="to day", minval=1, maxval=31)
ToMonth = input(defval=12, title="to month", minval=1, maxval=12)
ToYr = input(defval=2019, title="to yr", minval=1970)

startDate = timestamp(FromYr, FromMonth, Fromday, 00, 00)
finishDate = timestamp(ToYr, ToMonth, Today, 00, 00)
Time_cond = time >=startDate and time <= finishDate


/////롱

if  crossover(ci1,ci2) and change(ci2)>0 and Time_cond
    strategy.entry("go", strategy.long, comment="go")
    
strategy.close("go", (ci2<0 and ci1 <-50 and change(ci1)<0) or (crossunder(ci1,-100) and strategy.openprofit<0) and change(cnt)<0)



/////숏

if  (crossunder(ci1,ci2) and change(ci2)<0 and falling(ci1,aa)) and Time_cond
    strategy.entry("die", strategy.short, comment="die")
    
strategy.close("die", (ci2>0 and ci1 > 100 and change(ci1)>0) or (crossover(ci2,100) and strategy.openprofit<0) and change(cnt)>0)
````

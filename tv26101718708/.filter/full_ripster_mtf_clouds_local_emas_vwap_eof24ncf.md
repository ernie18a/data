# Full Ripster MTF Clouds + Local EMAs + VWAP

- url: https://www.tradingview.com/script/EOf24NCf-Full-Ripster-MTF-Clouds-Local-EMAs-VWAP/
- type: indicator
- pine_id: PUB;86d56bdd81b94d7e85eed444918cfffa
- version: 1.0

## Description

8 EMA 
20 EMA 
50 EMA 
200 EMA 
+ all the daily EMAS

## Source Code

````pine
//@version=5
indicator("Full Ripster MTF Clouds + Local EMAs + VWAP", overlay=true)

// === Inputs ===
showClouds   = input.bool(true, "Show Daily Clouds")
showLocalEMA = input.bool(true, "Show Local EMAs")

// === DAILY EMAs (MTF Clouds) ===
d8   = request.security(syminfo.tickerid, "D", ta.ema(close, 8))
d9   = request.security(syminfo.tickerid, "D", ta.ema(close, 9))

d20  = request.security(syminfo.tickerid, "D", ta.ema(close, 20))
d21  = request.security(syminfo.tickerid, "D", ta.ema(close, 21))

d50  = request.security(syminfo.tickerid, "D", ta.ema(close, 50))
d51  = request.security(syminfo.tickerid, "D", ta.ema(close, 51))

d200 = request.security(syminfo.tickerid, "D", ta.ema(close, 200))
d201 = request.security(syminfo.tickerid, "D", ta.ema(close, 201))

// === LOCAL TIMEFRAME EMAs ===
l8   = ta.ema(close, 8)
l20  = ta.ema(close, 20)
l50  = ta.ema(close, 50)
l200 = ta.ema(close, 200)

// === VWAP ===
vwapVal = ta.vwap(hlc3)

// === DAILY CLOUD PLOTS ===
pD8   = plot(d8,   color=color.blue,   linewidth=1, title="Daily 8")
pD9   = plot(d9,   color=color.blue,   linewidth=1, title="Daily 9")

pD20  = plot(d20,  color=color.red,    linewidth=1, title="Daily 20")
pD21  = plot(d21,  color=color.red,    linewidth=1, title="Daily 21")

pD50  = plot(d50,  color=color.green,  linewidth=1, title="Daily 50")
pD51  = plot(d51,  color=color.green,  linewidth=1, title="Daily 51")

pD200 = plot(d200, color=color.purple, linewidth=1, title="Daily 200")
pD201 = plot(d201, color=color.purple, linewidth=1, title="Daily 201")

// === CLOUD FILLS ===
fill(pD8,   pD9,   color=showClouds ? color.new(color.blue,   85) : na)
fill(pD20,  pD21,  color=showClouds ? color.new(color.red,    85) : na)
fill(pD50,  pD51,  color=showClouds ? color.new(color.green,  85) : na)
fill(pD200, pD201, color=showClouds ? color.new(color.purple, 85) : na)

// === LOCAL EMA PLOTS ===
plot(showLocalEMA ? l8   : na, color=color.new(color.blue,   0), linewidth=2, title="Local 8 EMA")
plot(showLocalEMA ? l20  : na, color=color.new(color.red,    0), linewidth=2, title="Local 20 EMA")
plot(showLocalEMA ? l50  : na, color=color.new(color.green,  0), linewidth=2, title="Local 50 EMA")
plot(showLocalEMA ? l200 : na, color=color.new(color.purple, 0), linewidth=2, title="Local 200 EMA")

// === VWAP ===
plot(vwapVal, color=color.yellow, linewidth=1, title="VWAP")
````

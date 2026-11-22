# CNY Basket Index

- url: https://www.tradingview.com/script/5hRcH4SK-CNY-Basket-Index/
- type: indicator
- pine_id: PUB;b5f7340ed3ca4018801f98293013de67
- version: 1.0

## Description

A custom China Yuan (CNH) strength index modelled on the CFETS RMB basket methodology. Weights yuan against a basket of major currencies including USD, EUR, GBP, JPY and AUD using a geometric weighted average. Displays as candlesticks. Rising index indicates yuan strengthening against the basket.

## Source Code

````pine
//@version=5
indicator("CNY Basket Index", overlay=false)

usdcnh_o = request.security("USDCNH", timeframe.period, open)
usdcnh_h = request.security("USDCNH", timeframe.period, high)
usdcnh_l = request.security("USDCNH", timeframe.period, low)
usdcnh_c = request.security("USDCNH", timeframe.period, close)

eurcnh_o = request.security("EURCNH", timeframe.period, open)
eurcnh_h = request.security("EURCNH", timeframe.period, high)
eurcnh_l = request.security("EURCNH", timeframe.period, low)
eurcnh_c = request.security("EURCNH", timeframe.period, close)

gbpcnh_o = request.security("GBPCNH", timeframe.period, open)
gbpcnh_h = request.security("GBPCNH", timeframe.period, high)
gbpcnh_l = request.security("GBPCNH", timeframe.period, low)
gbpcnh_c = request.security("GBPCNH", timeframe.period, close)

jpycnh_o = request.security("JPYCNH", timeframe.period, open)
jpycnh_h = request.security("JPYCNH", timeframe.period, high)
jpycnh_l = request.security("JPYCNH", timeframe.period, low)
jpycnh_c = request.security("JPYCNH", timeframe.period, close)

audcnh_o = request.security("AUDCNH", timeframe.period, open)
audcnh_h = request.security("AUDCNH", timeframe.period, high)
audcnh_l = request.security("AUDCNH", timeframe.period, low)
audcnh_c = request.security("AUDCNH", timeframe.period, close)

o = (math.pow(1/usdcnh_o, 0.1983) * math.pow(1/eurcnh_o, 0.1815) * math.pow(1/gbpcnh_o, 0.0386) * math.pow(jpycnh_o/100, 0.1153) * math.pow(1/audcnh_o, 0.0440)) * 100
h = (math.pow(1/usdcnh_h, 0.1983) * math.pow(1/eurcnh_h, 0.1815) * math.pow(1/gbpcnh_h, 0.0386) * math.pow(jpycnh_h/100, 0.1153) * math.pow(1/audcnh_h, 0.0440)) * 100
l = (math.pow(1/usdcnh_l, 0.1983) * math.pow(1/eurcnh_l, 0.1815) * math.pow(1/gbpcnh_l, 0.0386) * math.pow(jpycnh_l/100, 0.1153) * math.pow(1/audcnh_l, 0.0440)) * 100
c = (math.pow(1/usdcnh_c, 0.1983) * math.pow(1/eurcnh_c, 0.1815) * math.pow(1/gbpcnh_c, 0.0386) * math.pow(jpycnh_c/100, 0.1153) * math.pow(1/audcnh_c, 0.0440)) * 100

plotcandle(o, h, l, c, title="CNY Index", color=c >= o ? color.green : color.red, wickcolor=c >= o ? color.green : color.red)
````

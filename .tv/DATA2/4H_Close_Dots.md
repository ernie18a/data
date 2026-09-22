<!-- tradingview-pine-id: PUB;4ad598ebd1a649d4a447fe03f96a660b -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# 4H Close Dots

Source: https://www.tradingview.com/script/bnk2D7Cm/

## Description

ENG
This indicator marks the closing price of each completed 4-hour candle with a simple dot on lower timeframes. It helps traders quickly identify previous 4H closes while keeping the chart clean and uncluttered.

TR
Bu indikatör, tamamlanan her 4 saatlik mumun kapanış fiyatını alt zaman dilimlerinde basit bir nokta ile işaretler. Grafiği kalabalıklaştırmadan önceki 4H kapanış seviyelerini hızlıca görmenizi sağlar.

---

## Source Code

````pine
//@version=6
indicator("4H Close Dots", overlay=true)

// Sadece 4H'dan düşük timeframe'lerde göster
showDots = timeframe.in_seconds() < 14400

// 4H mumunun kapanış fiyatı
close4H = request.security(
    syminfo.tickerid,
    "240",
    close,
    lookahead=barmerge.lookahead_off
)

// Yeni 4H mum başladığında önceki 4H kapanmıştır
new4H = ta.change(time("240")) != 0

// 4H ve üzerinde hiçbir şey gösterme
plot(
    showDots and new4H ? close4H[1] : na,
    title="4H Close",
    style=plot.style_circles,
    linewidth=4,
    color=color.orange
)
````

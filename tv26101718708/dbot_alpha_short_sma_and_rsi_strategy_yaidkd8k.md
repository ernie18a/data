# D-BoT Alpha 'Short' SMA and RSI Strategy

- url: https://www.tradingview.com/script/YAidkd8K/
- type: strategy
- pine_id: PUB;abd671f5680043e1ba85c22f893ed96e
- version: 1.0

## Description

Dostlar selamlar,
İşte son derece basit ama etkili ve hızlı, HTF de çok iyi sonuçlar veren bir strateji daha, hepinize bol kazançlar dilerim ...

https://www.tradingview.com/x/erewM7P3/

[b]Nedir, Nasıl Çalışır:[/b][i][/i]

Strateji, iki ana girdiye dayanır: SMA ve RSI. SMA hesaplama aralığı 200 olarak, RSI ise 14 olarak ayarlanmıştır. Bu değerler, kullanıcı tercihlerine veya geriye dönük test sonuçlarına göre ayarlanabilir.

Strateji, iki koşul karşılandığında bir short sinyali oluşturur: RSI değeri, belirlenen bir giriş seviyesini (burada 51 olarak belirlenmiş) aşar ve kapanış fiyatı SMA değerinin altındadır.

Strateji, kısa pozisyonu üç durumda kapatır: Kapanış fiyatı, takip eden durdurma seviyesinden (pozisyon açıldığından beri en düşük kapanış olarak belirlenmiştir) büyükse, RSI değeri belirlenen bir durdurma seviyesini (bu durumda 54) aşarsa veya RSI değeri belirli bir kar al seviyesinin (bu durumda 32) altına düşerse.

[b]Güçlü Yönleri:[/b][i][/i]

İki farklı gösterge (SMA ve RSI) kullanımı, yalnızca birini kullanmaktan daha sağlam bir sinyal sağlayabilir.
Strateji, karları korumaya ve fiyat dalgalanmalarında kayıpları sınırlamaya yardımcı olabilecek bir iz süren durdurma seviyesi içerir.
Script oldukça anlaşılır ve değiştirmesi nispeten kolaydır.

[b]Zayıf Yönleri:[/b][i][/i]

Strateji, hacim, oynaklık veya daha geniş piyasa eğilimleri gibi diğer potansiyel önemli faktörleri göz önünde bulundurmaz.
RSI seviyeleri ve SMA süresi için belirli parametreler sabittir ve tüm piyasa koşulları veya zaman aralıkları için optimal olmayabilir.
Strateji oldukça basittir. Trade maliyetini (kayma veya komisyonlar gibi) hesaba katmaz, bu da trade performansını önemli ölçüde etkileyebilir.
[b][/b][i][/i]
Bu Stratejiyle Nasıl İşlem Yapılır:

Strateji, short işlemler için tasarlanmıştır. RSI, 51'in üzerine çıktığında ve kapanış fiyatı 200 periyotluk SMA'nın altında olduğunda işleme girer. RSI, 54'ün üzerine çıktığında veya 32'nin altına düştüğünde veya fiyat, pozisyon açıldığından beri en düşük kapanış fiyatının üzerine çıktığında işlemi kapatır.

Lütfen Dikkat, bu strateji veya herhangi bir strateji izole bir şekilde kullanılmamalıdır. Tüm bu çalışmalar eğitsel amaçlıdır. Yatırım tavsiyesi içermez.


https://www.tradingview.com/x/erewM7P3/

This script defines a trading strategy based on Simple Moving Average (SMA) and the Relative Strength Index (RSI) indicators. Here's an overview of how it works, along with its strengths and weaknesses, and how to trade using this strategy:

[b]How it works:[/b][b][/b]

The strategy involves two key inputs: SMA and RSI. The SMA length is set to 200, and the RSI length is set to 14. These values can be adjusted based on user preferences or back-testing results.

The strategy generates a short signal when two conditions are met: The RSI value crosses over a defined entry level (set at 51 here), and the closing price is below the SMA value.

When a short signal is generated, the strategy opens a short position.

The strategy closes the short position under three conditions: If the close price is greater than the trailing stop (which is set as the lowest close since the position opened), if the RSI value exceeds a defined stop level (54 in this case), or if the RSI value drops below a certain take-profit level (32 in this case).

Strengths:

The use of two different indicators (SMA and RSI) can provide a more robust signal than using just one.
The strategy includes a trailing stop, which can help to protect profits and limit losses as the price fluctuates.
The script is straightforward and relatively easy to understand and modify.

Weaknesses:[b][/b]

The strategy doesn't consider other potentially important factors, such as volume, volatility, or broader market trends.
The specific parameters for the RSI levels and SMA length are hard-coded, and may not be optimal for all market conditions or timeframes.
The strategy is very simplistic. It doesn't take into account the cost of trading (like slippage or commissions), which can significantly impact trading performance.
How to trade with this strategy:

The strategy is designed for short trades. It enters a trade when the RSI crosses above 51 and the closing price is below the 200-period SMA. It will exit the trade when the RSI goes above 54 or falls below 32, or when the price rises above the lowest closing price since the position was opened.

Please note, this strategy or any strategy should not be used in isolation. It's important to consider other aspects of trading such as risk management, capital allocation, and combining different strategies to diversify. Back-testing the strategy on historical data and demo trading before going live is also a recommended practice.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © abdllhatn

//@version=5
strategy("Alpha Short SMA and RSI Strategy", overlay=true, initial_capital=10000, default_qty_value=100)

// Inputs
sma_length = input(200, title="SMA Length")
rsi_length = input(14, title="RSI Length")
rsi_entry = input(51, title="RSI Entry Level")
rsi_stop = input(54, title="RSI Stop Level")
rsi_take_profit = input(32, title="RSI Take Profit Level")

// Indicators
sma_value = ta.sma(close, sma_length)
rsi_value = ta.rsi(close, rsi_length)

var float trailingStop = na
var float lastLow = na

// Conditions
shortCondition = ta.crossover(rsi_value, rsi_entry) and close < sma_value
if (shortCondition)
    strategy.entry("Sell", strategy.short)
    trailingStop := na
    lastLow := na

if (strategy.position_size < 0)
    if (na(lastLow) or close < lastLow)
        lastLow := close
        trailingStop := close

if not na(trailingStop) and close > trailingStop
    strategy.close("Sell")

if (rsi_value >= rsi_stop)
    strategy.close("Sell")

if (rsi_value <= rsi_take_profit)
    strategy.close("Sell")

// Plot
plot(sma_value, color=color.red, linewidth=2)
````

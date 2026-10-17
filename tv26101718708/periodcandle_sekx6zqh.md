# Period_Candle

- url: https://www.tradingview.com/script/sEkx6zqh/
- type: indicator
- pine_id: PUB;6fbb52a8bee345398264710f6edc6145
- version: 1.0

## Description

Period_Candle

This indicator creates candlesticks using the open price 
of N bars ago and the current close price.
No wicks. No intrabar high/low.

Designed for Ichimoku Kinko Hyo analysis (3-day candle).
Default period: 3 (matches Lagging Span period).

How to use:
- Set period to match your Lagging Span setting
- Default is 3 for the traditional 3-day candle

---

【日本語】
N本前の寄り付きから当日終値でローソク足を作るインジケーターです。
ヒゲなし・ザラバ高安なしのシンプルな構成。

一目均衡表の3日足として使用することを想定しています。
デフォルト期間3（遅行線の期間に合わせて使用）。

使い方：
・遅行線の期間に合わせて期間を設定
・3日足の場合はデフォルトの3のまま使用

## Source Code

````pine


// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © kapi_mama
//@version=6
indicator(title = 'Period_Candle', overlay=true)
Length = input.int(3, minval = 2, title = "期間")
Len = Length - 1

m_open  = open[Len]
m_close = close
m_high  = math.max(m_open, m_close)
m_low   = math.min(m_open, m_close)

plotcandle(m_open, m_high, m_low, m_close, 
     title='', 
     color=m_open < m_close ? color.white : color.blue, 
     wickcolor=color.new(color.white, 100))
````

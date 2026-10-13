<!-- tradingview-pine-id: PUB;04f8211b69e044049e8ac604d42804bf -->
<!-- tradingviewscripts-format: 1 -->
# MidPoint Cross (3M High/Low)

Source: https://www.tradingview.com/script/B5puqx0a/

## Description

直近(3か月)の最高値と最安値の中間地点を算出

---

## Source Code

````pine
//@version=6
indicator("MidPoint Cross (3M High/Low)", overlay = false)

// 3か月＝約63営業日
length = input.int(63, "Lookback Period (3M)", minval = 20)

// 直近高値・安値
highest_price = ta.highest(high, length)
lowest_price  = ta.lowest(low, length)

// 中間地点
mid_point = (highest_price + lowest_price) / 2

// クロス判定（下→上）
cross_up = ta.crossover(close, mid_point)

// スクリーナー用出力
plot(cross_up ? 1 : 0, "MidPoint Cross Up", color = cross_up ? color.green : color.red)
alertcondition(cross_up, "MidPoint Cross Up", "Price crossed above midpoint")
````

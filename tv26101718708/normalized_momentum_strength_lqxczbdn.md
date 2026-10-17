# Normalized Momentum Strength

- url: https://www.tradingview.com/script/lQXCZbdN/
- type: indicator
- pine_id: PUB;800fa0d267544fe790232070cd45716c
- version: 1.0

## Description

[b]Normalized Momentum Strength[/b]

Normalized Momentum Strength is an indicator that normalizes price changes using ATR (Average True Range) to measure how large the current price movement is relative to the market's typical price movement.

By using ATR as the reference instead of comparing raw price changes, the indicator accounts for differences in volatility between securities and across different periods.

[b]Calculation[/b]

Normalized Momentum Strength is calculated using the following formula:

Normalized Momentum Strength = (close - close[length]) / ATR(length)

For example, a value of 2 means that the price has increased by approximately twice the ATR compared with the price `length` periods ago.

A larger positive value indicates a larger upward price movement, while a more negative value indicates a larger downward price movement.

[b]Using It for Trend Identification[/b]

By comparing Normalized Momentum Strength with a threshold, the market can be classified into three categories and the indicator can be used as a basis for trend identification:

Normalized Momentum Strength > threshold → Uptrend
Normalized Momentum Strength < −threshold → Downtrend
Otherwise → Range

However, this indicator measures **how far the price has moved in one direction during the specified period**.

It does not take into account the shape or path of the price movement during that period.

Therefore, Normalized Momentum Strength should not be considered an indicator that measures the **shape of a trend**. Instead, it should be used as an indicator that measures the **magnitude of directional price movement over a specified period**.

[b]Parameters[/b]

The number of bars (`length`) and the threshold (`threshold`) can be changed in the settings panel.

The appropriate values may vary depending on the market and timeframe, so test the parameters using actual market data before using the indicator.

The default settings are intended for use with **weekly charts of Japanese stocks**:

Number of bars: 13
threshold: 2

[b]Trend Classification Ratio[/b]

The data window displays the percentages of:

Uptrend
Downtrend
Range

Use these figures as a reference when adjusting the parameters.



[b]Normalized Momentum Strength[/b]

Normalized Momentum Strength は、価格の変化をATR（Average True Range）で正規化し、現在の価格変化が通常の値動きに対してどの程度大きいかを測定する指標です。

株価の変化をそのまま比較するのではなく、ATRを基準にすることで、銘柄や時期によるボラティリティの違いを吸収しています。

[b]計算式[/b]

Normalized Momentum Strength は、次の式で計算します。

Normalized Momentum Strength = (close - close[length]) / ATR(length)

例えば、値が「2」であれば、length期間前と比較して、価格がATRの約2倍上昇したことを意味します。

値が大きいほど上昇方向への価格変化が大きく、値が小さいほど下降方向への価格変化が大きいことを表します。

[b]トレンド判定への利用[/b]

Normalized Momentum Strength と閾値を比較することで、相場を3つに分類し、トレンド判定ロジックの基準として利用することができます。

Normalized Momentum Strength > 閾値 → 上昇トレンド
Normalized Momentum Strength < −閾値 → 下降トレンド
それ以外 → レンジ

ただし、この指標が測定しているのは、指定した期間に価格がどれだけ一方向に移動したかです。

そのため、途中の値動きがどのような形だったかまでは考慮していません。

したがって、Normalized Momentum Strength は「トレンドの形」を測定する指標ではなく、「一定期間における方向性のある価格変化の大きさ」を測定する指標として利用してください。

[b]パラメータ[/b]

バーの本数（length）と閾値（threshold）は、パネルから変更できます。

市場や時間軸によって適した値は異なるため、実際のデータで検証したうえで使用してください。

デフォルト値は、日本株の週足で使用することを想定しています。

バーの本数：13
閾値：2

[b]トレンド判定の割合[/b]

データウィンドウには、

上昇トレンド
下降トレンド
レンジ

の割合（最初のバーから選択したバーまでの発生率）を表示しています。

パラメータを調整するときの参考情報としてご利用ください。

## Source Code

````pine
//@version=6
indicator("Normalized Momentum Strength")

// parameter
length = input.int(13, "length")
threshold = input.float(2.0, "threshold")
drawTrend = input.bool(true, "Display the trend in the main chart")
uptrendColor = input.color(color.new(color.red, 80),"uptrend color")
downtrendColor = input.color(color.new(color.blue, 80),"downtrend color")

// calculation
momentumValue = close - close[length]
atrValue = ta.sma(ta.tr, length)
nmsValue = momentumValue / atrValue

// judgement
isUptrend = (nmsValue >= threshold)
isDowntrend = (nmsValue <= -threshold)
isRange = not(isUptrend or isDowntrend)

// statistics
countUptrend = isUptrend ? 1 : 0
sumUptrend = ta.cum(countUptrend)
rateOfUptrend = sumUptrend / (bar_index + 1) * 100
countDowntrend = isDowntrend ? 1 : 0
sumDowntrend = ta.cum(countDowntrend)
rateOfDowntrend = sumDowntrend / (bar_index + 1) * 100
countRange = isRange ? 1 : 0
sumRange = ta.cum(countRange)
rateOfRange = sumRange / (bar_index + 1) * 100

// visualization
plot(momentumValue, "momentum", display = display.data_window)
plot(atrValue, "atr", display = display.data_window)
p0 = plot(nmsValue, "Normalized Momentum Strength", color.black, precision = 2)
p1 = plot(threshold, "threshold", color.black, display = display.pane)
p2 = plot(-threshold, "threshold", color.black, display = display.pane)
fill(p0, p1, isUptrend ? uptrendColor : na)
fill(p2, p0, isDowntrend ? downtrendColor : na)
bgcolor(drawTrend and isUptrend ? uptrendColor : na, force_overlay = true)
bgcolor(drawTrend and isDowntrend  ? downtrendColor : na, force_overlay = true)
plot(rateOfUptrend, "rate of uptrend(%)", precision = 2, display = display.data_window)
plot(rateOfDowntrend, "rate of downtrend(%)", precision = 2, display = display.data_window)
plot(rateOfRange, "rate of range(%)", precision = 2, display = display.data_window)
````

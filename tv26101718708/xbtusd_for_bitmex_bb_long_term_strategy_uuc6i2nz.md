# XBTUSD for BitMEX [ BB Long term strategy ]

- url: https://www.tradingview.com/script/uUc6I2NZ/
- type: strategy
- pine_id: PUB;XXoikHivIJzHN1v7FtSvhIEvkk7r2WBt
- version: 1.0

## Description

[b]XBTUSD for BitMEX [ BB Long term strategy ][/b]



[url=http://coin.oldpandaspace.com/%E3%80%90tradingview%E3%80%91%E3%80%8E%E3%81%8A%E3%81%99%E3%81%99%E3%82%81%E3%82%B9%E3%83%88%E3%83%A9%E3%83%86%E3%82%B8%E3%83%BCss%EF%BC%91%E3%80%8F%EF%BC%88bitmex%E3%83%93%E3%83%83%E3%83%88%E3%82%B3/]『おすすめストラテジーSS１』（BitMEXビットコイン用Pineスクリプト）自動売買のアイデアに！[/url]

## Source Code

````pine
//－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
//
//　『おすすめストラテジーSS１』
//　『BitMEX　XBTUSD　３０分足向け中長期用ストラテジー』
// 　本番用ストラテジーファイル
//
//
//
//－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
//【説明】
//　『おすすめストラテジーSS１』のPineスクリプトです。
//－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
 
//@version=3
strategy(title = "『おすすめストラテジーSS１』", shorttitle="Strategy1", initial_capital=1200000, pyramiding=0, default_qty_type=strategy.percent_of_equity, default_qty_value=100, commission_type=strategy.commission.percent, commission_value=0.05, overlay=true)
 
 
//－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
//
//ストラテジーロジック
//
//－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
 
 
source = close
 
length = input(51, minval = 1, title = "移動平均")
mult = input(3.01, minval = 0.001,step=0.01, maxval = 10, title = "マルチ")
 
Rikaku = input(14.2, minval = 0.1, step=0.1,maxval = 100, title = "利確（％）")
Songiri = input(99, minval = 0.1, maxval = 100, title = "損切（％）")
 
base = sma(source, length)
range = mult * stdev(source, length)
 
upper = base + range
lower = base - range
 
short_cond = crossover(source, lower)
long_cond = crossunder(source, upper)
 
 
cl = 0.0
cl := na(cl[1]) ? sma(source, length) : (cl[1] * (length - 1) + source) / length
 
plot(cl, color=black)
 
up_plot = plot(upper, color=blue)
low_plot = plot(lower, color=red)
 
fill(up_plot, low_plot,color=#009900)
 
//－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
//
//オーダー処理
//
//－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
 
 
if (long_cond)
 
	strategy.entry("Long_Entry", strategy.long, oca_name="BollingerBands", oca_type=strategy.oca.none, comment="Long")
 
	//BitFlyerのようなJPY建ての場合は以下のコードを使います。他の通貨ペアにする場合も１ティックが異なるため桁数の変更が必要です。
	//strategy.exit("LE Exit", "BBandLE", profit = close*(Rikaku/100)*100, loss = close*(Songiri/100)*100, comment="Close")
	strategy.exit("Long_Exit", "Long_Entry", profit = close*(Rikaku/100)*10, loss = close*(Songiri/100)*10, comment="LongClose")
 
if (short_cond)
 
	strategy.entry("Short_Entry", strategy.short, oca_name="BollingerBands", oca_type=strategy.oca.none, comment="Short")
 
    //BitFlyerのようなJPY建ての場合は以下のコードを使います。他の通貨ペアにする場合も１ティックが異なるため桁数の変更が必要です。
    //strategy.exit("SE Exit", "BBandSE", profit = close*(Rikaku/100)*100, loss = close*(Songiri/100)*100, comment="Close")
    strategy.exit("Short_Exit", "Short_Entry", profit = close*(Rikaku/100)*10, loss = close*(Songiri/100)*10, comment="ShortClose")
````

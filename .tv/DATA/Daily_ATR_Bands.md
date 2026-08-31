<!-- tradingview-pine-id: PUB;337417e2381c4c839ff1e8a24d416b2d -->
<!-- tradingviewscripts-format: 1 -->
# Daily ATR Bands

Source: https://www.tradingview.com/script/cCH7ieax/

## Description

**Daily ATR Bands**

This indicator visualizes market volatility using the Daily Average True Range (ATR).

Regardless of the chart timeframe, the ATR calculation always uses **daily timeframe data**. This allows traders to view Daily ATR levels while using lower timeframes such as 1-minute, 1-hour, or 4-hour charts.

**Settings**

* ATR Length: 14
* Base: Daily EMA 20
* ±1 ATR
* ±2 ATR
* ±3 ATR
* Daily ATR levels displayed on all chart timeframes
* Suitable for cryptocurrencies and other markets

To keep the chart clean and minimal, the base EMA is hidden and only the ATR bands are displayed using thin gray lines.

**Daily ATR Bands**

日足のATR（Average True Range）を使用して、価格のボラティリティを視覚化するインジケーターです。

チャートの時間足を変更しても、ATRの計算は常に**日足データ**を使用します。そのため、1分足・1時間足・4時間足などの下位時間足でも、日足基準のATRバンドを確認できます。

**設定**

* ATR期間：14
* 基準：日足EMA 20
* ±1 ATR
* ±2 ATR
* ±3 ATR
* すべての時間足で日足ATRを表示
* 仮想通貨を含む各種銘柄に対応

チャートをシンプルに保つため、基準となるEMAは表示せず、ATRバンドのみを細いグレーのラインで表示します。

---

## Source Code

````pine
//@version=6
indicator("Daily ATR Bands", overlay=true)

// ─────────────────────────────
// Settings
// ─────────────────────────────
atrLength = input.int(14, "ATR Length", minval=1)
maLength  = input.int(20, "Base EMA Length", minval=1)

// ─────────────────────────────
// Daily calculations
// ─────────────────────────────
dailyBase = request.security(
     syminfo.tickerid,
     "D",
     ta.ema(close, maLength),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off
)

dailyATR = request.security(
     syminfo.tickerid,
     "D",
     ta.atr(atrLength),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off
)

// ─────────────────────────────
// ATR Bands
// ─────────────────────────────
upper1 = dailyBase + dailyATR
lower1 = dailyBase - dailyATR

upper2 = dailyBase + dailyATR * 2.0
lower2 = dailyBase - dailyATR * 2.0

upper3 = dailyBase + dailyATR * 3.0
lower3 = dailyBase - dailyATR * 3.0

// ─────────────────────────────
// Plot
// ─────────────────────────────
bandColor = color.gray

plot(upper1, "Upper 1 ATR", color=bandColor, linewidth=1)
plot(lower1, "Lower 1 ATR", color=bandColor, linewidth=1)

plot(upper2, "Upper 2 ATR", color=bandColor, linewidth=1)
plot(lower2, "Lower 2 ATR", color=bandColor, linewidth=1)

plot(upper3, "Upper 3 ATR", color=bandColor, linewidth=1)
plot(lower3, "Lower 3 ATR", color=bandColor, linewidth=1)
````

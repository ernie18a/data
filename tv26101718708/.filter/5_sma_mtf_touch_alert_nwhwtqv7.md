# 5 SMA MTF Touch Alert

- url: https://www.tradingview.com/script/NWhwtQV7/
- type: indicator
- pine_id: PUB;fa6d4135f342439c98dc99f8684fd1f0
- version: 1.0

## Description

5本のSMAを表示し、各SMAごとに期間・線の太さ・アラートON/OFFを設定できます。
固定時間足モードを使うことで、現在のチャート足とは別の時間足のSMAも表示できます。
タッチ判定はローソク足の高値・安値を基準にしています。

This indicator displays five Simple Moving Averages (SMA) on the chart.

Default SMA lengths:
- 25
- 75
- 100
- 200
- 400

Each SMA can be individually customized:
- Show or hide each SMA
- Change the SMA length
- Change the line width
- Enable or disable touch alerts

The indicator also supports a fixed timeframe mode.
When fixed timeframe mode is enabled, the SMA values are calculated from the selected timeframe, such as 30 minutes, even when viewing a different chart timeframe.

Touch alerts are triggered when the current candle’s high and low range touches each SMA line.

This script is designed as a visual support tool for trend analysis and moving average monitoring.
It does not provide buy or sell signals and should not be used as financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Sumo_fine

//@version=6
indicator("5本SMA 可変/固定時間足＆個別タッチアラート", overlay=true)

// ===== 時間足設定 =====
useFixedTf = input.bool(true, title="固定時間足を使う")
fixedTf    = input.timeframe("30", title="固定時間足")

// ===== SMA 1 =====
showSma1  = input.bool(true,  title="SMA1を表示")
lenSma1   = input.int(25,     title="SMA1 期間", minval=1)
widthSma1 = input.int(2,      title="SMA1 線の太さ", minval=1, maxval=5)
alertSma1 = input.bool(true,  title="SMA1 タッチアラート")

// ===== SMA 2 =====
showSma2  = input.bool(true,  title="SMA2を表示")
lenSma2   = input.int(75,     title="SMA2 期間", minval=1)
widthSma2 = input.int(2,      title="SMA2 線の太さ", minval=1, maxval=5)
alertSma2 = input.bool(false, title="SMA2 タッチアラート")

// ===== SMA 3 =====
showSma3  = input.bool(true,  title="SMA3を表示")
lenSma3   = input.int(100,    title="SMA3 期間", minval=1)
widthSma3 = input.int(2,      title="SMA3 線の太さ", minval=1, maxval=5)
alertSma3 = input.bool(false, title="SMA3 タッチアラート")

// ===== SMA 4 =====
showSma4  = input.bool(true,  title="SMA4を表示")
lenSma4   = input.int(200,    title="SMA4 期間", minval=1)
widthSma4 = input.int(3,      title="SMA4 線の太さ", minval=1, maxval=5)
alertSma4 = input.bool(false, title="SMA4 タッチアラート")

// ===== SMA 5 =====
showSma5  = input.bool(true,  title="SMA5を表示")
lenSma5   = input.int(400,    title="SMA5 期間", minval=1)
widthSma5 = input.int(4,      title="SMA5 線の太さ", minval=1, maxval=5)
alertSma5 = input.bool(false, title="SMA5 タッチアラート")

// ===== SMA計算関数 =====
getSma(length) =>
    useFixedTf ? request.security(syminfo.tickerid, fixedTf, ta.sma(close, length)) : ta.sma(close, length)

// ===== SMA計算 =====
sma1 = getSma(lenSma1)
sma2 = getSma(lenSma2)
sma3 = getSma(lenSma3)
sma4 = getSma(lenSma4)
sma5 = getSma(lenSma5)

// ===== 表示 =====
plot(showSma1 ? sma1 : na, title="SMA1", color=color.blue,   linewidth=widthSma1)
plot(showSma2 ? sma2 : na, title="SMA2", color=color.orange, linewidth=widthSma2)
plot(showSma3 ? sma3 : na, title="SMA3", color=color.green,  linewidth=widthSma3)
plot(showSma4 ? sma4 : na, title="SMA4", color=color.red,    linewidth=widthSma4)
plot(showSma5 ? sma5 : na, title="SMA5", color=color.purple, linewidth=widthSma5)

// ===== タッチ判定：ヒゲ含む =====
touchSma1 = showSma1 and alertSma1 and low <= sma1 and high >= sma1
touchSma2 = showSma2 and alertSma2 and low <= sma2 and high >= sma2
touchSma3 = showSma3 and alertSma3 and low <= sma3 and high >= sma3
touchSma4 = showSma4 and alertSma4 and low <= sma4 and high >= sma4
touchSma5 = showSma5 and alertSma5 and low <= sma5 and high >= sma5

// ===== リアルタイム通知 =====
tfText = useFixedTf ? fixedTf : timeframe.period

if barstate.isrealtime
    if touchSma1
        alert("価格がSMA1にタッチしました / 時間足: " + tfText + " / SMA期間: " + str.tostring(lenSma1), alert.freq_once_per_bar)
    if touchSma2
        alert("価格がSMA2にタッチしました / 時間足: " + tfText + " / SMA期間: " + str.tostring(lenSma2), alert.freq_once_per_bar)
    if touchSma3
        alert("価格がSMA3にタッチしました / 時間足: " + tfText + " / SMA期間: " + str.tostring(lenSma3), alert.freq_once_per_bar)
    if touchSma4
        alert("価格がSMA4にタッチしました / 時間足: " + tfText + " / SMA期間: " + str.tostring(lenSma4), alert.freq_once_per_bar)
    if touchSma5
        alert("価格がSMA5にタッチしました / 時間足: " + tfText + " / SMA期間: " + str.tostring(lenSma5), alert.freq_once_per_bar)

// ===== 色付きSMA一覧テーブル =====
showTable = input.bool(true, title="色付きSMA一覧を表示")

var table smaTable = table.new(position.top_right, 2, 5)

if barstate.islast and showTable
    table.cell(smaTable, 0, 0, "SMA25",  text_color=color.blue)
    table.cell(smaTable, 1, 0, str.tostring(sma1, format.mintick), text_color=color.blue)

    table.cell(smaTable, 0, 1, "SMA75",  text_color=color.orange)
    table.cell(smaTable, 1, 1, str.tostring(sma2, format.mintick), text_color=color.orange)

    table.cell(smaTable, 0, 2, "SMA100", text_color=color.green)
    table.cell(smaTable, 1, 2, str.tostring(sma3, format.mintick), text_color=color.green)

    table.cell(smaTable, 0, 3, "SMA200", text_color=color.red)
    table.cell(smaTable, 1, 3, str.tostring(sma4, format.mintick), text_color=color.red)

    table.cell(smaTable, 0, 4, "SMA400", text_color=color.purple)
    table.cell(smaTable, 1, 4, str.tostring(sma5, format.mintick), text_color=color.purple)
````

# Volume Spike

- url: https://www.tradingview.com/script/eV5T01Kf/
- type: indicator
- pine_id: PUB;49767d2d29904277921582a2d222281a
- version: 1.0

## Description

出来高のスパイクを検知する

## Source Code

````pine
//@version=5
indicator("Volume & ATR Spike 2-Level Alert with RSI/ADX Filters (Strict Separation + RSI Label)", overlay=true)

// === ユーザー設定（スパイク本体）===
volMultiplierNS = input.float(1.7, title="NS Volume Multiplier")
atrMultiplierNS = input.float(1.11, title="NS ATR Multiplier")
volMultiplierSS = input.float(2.0, title="SS Volume Multiplier")
atrMultiplierSS = input.float(1.4, title="SS ATR Multiplier")
atrLength       = input.int(21,  title="ATRの期間")

// ★追加：最低出来高フィルター（150以下カット）
minVol = input.int(150, title="Volume Threshold (Minimum Volume for Spike)", minval=0)

// === RSIフィルター（ON/OFF）===
useRSIFilter = input.bool(false, title="Use RSI Filter")
rsiLen       = input.int(14, title="RSIの期間", minval=1)
rsiUpper     = input.float(55, title="RSI Upper Threshold", step=0.1)
rsiLower     = input.float(45, title="RSI Lower Threshold", step=0.1)

// === ADXフィルター（ON/OFF）===
useADXAbove  = input.bool(false, title="Use ADX Above Filter")
useADXBelow  = input.bool(false, title="Use ADX Below Filter")
adxLen       = input.int(14, title="ADX Period", minval=1)
adxTh        = input.float(25, title="ADX Threshold", step=0.1)

// === 計算（スパイク本体は元ロジック維持）===
vol    = volume
atr    = ta.atr(atrLength)
volSMA = ta.sma(volume, 20)
atrSMA = ta.sma(atr, 20)

// RSI（ラベル＆フィルター用）
rsiVal = ta.rsi(close, rsiLen)
rsiStr = str.tostring(rsiVal, "#.##")

// ADX（ta.adxが環境で死ぬことがあるのでdmiから取得）
[_, __, adxVal] = ta.dmi(adxLen, adxLen)

// === フィルター判定 ===
// 出来高：150以下カット（150を落とすなら ">" が正しい）
volPass = vol > minVol

// RSI：ONなら「45-55帯の外のみ許可」
rsiPass = (not useRSIFilter) or (rsiVal > rsiUpper or rsiVal < rsiLower)

// ADX：ONになってるものだけ効く
adxPassAbove = (not useADXAbove) or (adxVal >= adxTh)
adxPassBelow = (not useADXBelow) or (adxVal <= adxTh)
adxPass      = adxPassAbove and adxPassBelow

// === スパイク判定（元ロジック + フィルターを前段に追加）===
isSS = volPass and rsiPass and adxPass and (vol > volSMA * volMultiplierSS) and (atr > atrSMA * atrMultiplierSS)
isNS = volPass and rsiPass and adxPass and not isSS and (vol > volSMA * volMultiplierNS) and (atr > atrSMA * atrMultiplierNS)

isBull = close > open
isBear = close < open

// === NS表示（元のまま）===
plotshape(isNS and isBull, title="NS Bull", location=location.abovebar, color=color.yellow, style=shape.labelup,   text="NS", textcolor=color.black)
plotshape(isNS and isBear, title="NS Bear", location=location.belowbar, color=color.yellow, style=shape.labeldown, text="NS", textcolor=color.black)

// === SS表示（元のまま）===
// ※ののちゃん仕様が「Bull=上 / Bear=下」ならここは入れ替えてね（今は元コード踏襲）
plotshape(isSS and isBull, title="SS Bull", location=location.belowbar, color=color.red, style=shape.labeldown, text="SS", textcolor=color.white)
plotshape(isSS and isBear, title="SS Bear", location=location.abovebar, color=color.red, style=shape.labelup,   text="SS", textcolor=color.white)

// === RSIラベル（スパイクが出た足だけ）===
if isNS or isSS
    label.new(bar_index, high, "RSI=" + rsiStr, style=label.style_label_left, color=color.gray, textcolor=color.white, size=size.small)

// === アラート（メッセージ固定）===
alertcondition(isNS, title="NS Spike Alert", message="NS Spike! [RSI in chart label]")
alertcondition(isSS, title="SS Spike Alert", message="SS Spike! [RSI in chart label]")
````

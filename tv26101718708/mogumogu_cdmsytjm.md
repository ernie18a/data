# mogumogu

- url: https://www.tradingview.com/script/CdmsYtjM/
- type: indicator
- pine_id: PUB;f0f7e3b5beae469ebc63d8b14b9487b9
- version: 1.0

## Description

⚠ 注意（重要）
このインジのシグナルはあくまで判断の補助です。
これだけでエントリーを決めるのではなく、
上位足のトレンド（4時間足・日足）
サポート・レジスタンス
ラインや水平帯
相場の流れ（トレンド or レンジ）
などを総合的に見て判断することが重要です。
特に、重要なライン付近や上位足の流れと逆行している場面では、
シグナルが出ていても見送る判断が必要になります。

【このインジは下位足のトレンドの押し目（戻り）を狙うインジです】
RSIの過熱＋EMA5/13のクロスを使ってエントリー候補を出し、
さらに**EMA200でトレンド方向を絞る**ことで無駄なトレードを減らしたインジです。
---
### ■ 基本の考え方
* RSIで「行き過ぎた場所」を検知
* EMA5/13のクロスで「反転のタイミング」を確認
* EMA200で「大きな流れの方向」を判断

---
### ■ フィルターの役割
* EMA200より上 → **ロングのみ表示**
* EMA200より下 → **ショートのみ表示**
* それ以外 → **シグナルなし（触らない）**

---
### ■ 表示の意味
* **L / S**：エントリー候補
* **★**：利確目安
* **⚠**：流れ変化の警告
* **SL**：損切りライン

---
### ■ 特徴

* トレンド方向だけに絞るのでダマシが減る
* 無駄な逆張りをカットできる
* シンプルで裁量にも組み込みやすい

---
了解、名前を反映した英語版を置く👇

---

## Mogumogu 

Mogumogu combines RSI and EMA crossover signals,
with an EMA200 trend filter to reduce low-quality trades.

---

### ■ Concept

* RSI identifies **overbought / oversold conditions**
* EMA 5/13 crossover confirms **entry timing**
* EMA200 defines the **overall market direction**

---

### ■ Filter Logic

* Above EMA200 → **Long signals only**
* Below EMA200 → **Short signals only**
* Around EMA200 → **No signals (stay out)**

---

### ■ Signals

* **L / S**: Entry opportunity
* **★**: Take profit zone
* **⚠**: Warning (possible trend change)
* **SL**: Stop loss level

---

### ■ Features

* Filters out counter-trend trades
* Reduces unnecessary entries
* Works well as a discretionary trading support tool

---

## ⚠ Important Note

Mogumogu is a **support tool**, not a standalone system.

Always combine it with:

* Higher timeframe analysis (H4 / Daily)
* Support and resistance levels
* Key zones and structure
* Overall market condition (trend or range)

Even if a signal appears, it should be ignored if it goes against the bigger picture.

---

## Source Code

````pine
//@version=5
indicator("もぐもぐ", shorttitle="もぐもぐ", overlay=true, max_labels_count=500, max_lines_count=500)

// ==================== 入力設定 ====================
rsiLength=input.int(14, "RSI期間", minval=2, group="RSI設定")
obLevel=input.int(70, "買われすぎ水準", minval=50, maxval=95, group="RSI設定")
osLevel=input.int(30, "売られすぎ水準", minval=5, maxval=50, group="RSI設定")
emaFastLen=input.int(5, "EMA短期", minval=1, group="EMA設定")
emaSlowLen=input.int(13, "EMA長期", minval=1, group="EMA設定")
emaTrendLen=input.int(200, "EMA200", minval=1, group="EMA設定")
signalLookback=input.int(30, "シグナル判定の有効本数", minval=1, group="シグナル設定")
stopLookback=input.int(10, "損切り基準の本数", minval=1, group="損切り設定")
displayMemoryBars=input.int(50, "利確表示の方向保持バー数", minval=1, group="シグナル設定")
offsetAtrLen=input.int(14, "表示ずらしATR期間", minval=1, group="表示位置設定")
offsetAtrMult=input.float(0.35, "表示ずらしATR倍率", minval=0.05, step=0.05, group="表示位置設定")

showLabels=input.bool(true, "文字を表示", group="表示設定")
showEMA=input.bool(true, "EMAを表示", group="表示設定")
showSL=input.bool(true, "損切りラインを表示", group="表示設定")
showZoneBg=input.bool(false, "背景表示", group="表示設定")

longColor=input.color(color.aqua, "Lの色", group="文字デザイン")
shortColor=input.color(color.red, "Sの色", group="文字デザイン")
tpColor=input.color(color.lime, "★の色", group="文字デザイン")
warnColor=input.color(color.yellow, "⚠の色", group="文字デザイン")
slColor=input.color(color.red, "SLの色", group="文字デザイン")

longSizeStr=input.string("normal", "Lのサイズ", options=["tiny","small","normal","large","huge"], group="文字デザイン")
shortSizeStr=input.string("normal", "Sのサイズ", options=["tiny","small","normal","large","huge"], group="文字デザイン")
tpSizeStr=input.string("normal", "★のサイズ", options=["tiny","small","normal","large","huge"], group="文字デザイン")
warnSizeStr=input.string("normal", "⚠のサイズ", options=["tiny","small","normal","large","huge"], group="文字デザイン")
slSizeStr=input.string("normal", "SLのサイズ", options=["tiny","small","normal","large","huge"], group="文字デザイン")

// ==================== サイズ変換 ====================
f_getSize(_s)=>
    _s == "tiny" ? size.tiny : _s == "small" ? size.small : _s == "large" ? size.large : _s == "huge" ? size.huge : size.normal

longSize=f_getSize(longSizeStr)
shortSize=f_getSize(shortSizeStr)
tpSize=f_getSize(tpSizeStr)
warnSize=f_getSize(warnSizeStr)
slSize=f_getSize(slSizeStr)

// ==================== 基本計算 ====================
rsi=ta.rsi(close, rsiLength)
emaFast=ta.ema(close, emaFastLen)
emaSlow=ta.ema(close, emaSlowLen)
emaTrend=ta.ema(close, emaTrendLen)
atr=ta.atr(offsetAtrLen)
yOffset=atr * offsetAtrMult

gc=ta.crossover(emaFast, emaSlow)
dc=ta.crossunder(emaFast, emaSlow)

hitOB=rsi >= obLevel
hitOS=rsi <= osLevel

barsSinceOS=ta.barssince(hitOS)
barsSinceOB=ta.barssince(hitOB)

osActive=not na(barsSinceOS) and barsSinceOS <= signalLookback
obActive=not na(barsSinceOB) and barsSinceOB <= signalLookback

allowLong=close > emaTrend
allowShort=close < emaTrend

// ==================== 表示専用エントリー条件 ====================
showLongEntry=osActive and gc and allowLong
showShortEntry=obActive and dc and allowShort

// ==================== 内部ポジション管理 ====================
var int pos=0
var float stopPrice=na
var int lastDir=0
var int lastDirBar=na

longStopCandidate=ta.lowest(low, stopLookback)
shortStopCandidate=ta.highest(high, stopLookback)

execLongEntry=showLongEntry and pos <= 0
execShortEntry=showShortEntry and pos >= 0

if execLongEntry
    pos:=1
    stopPrice:=longStopCandidate
    lastDir:=1
    lastDirBar:=bar_index

if execShortEntry
    pos:=-1
    stopPrice:=shortStopCandidate
    lastDir:=-1
    lastDirBar:=bar_index

if not na(lastDirBar) and bar_index - lastDirBar > displayMemoryBars
    lastDir:=0
    lastDirBar:=na

// ==================== 決済条件 ====================
// ⚠は警告表示だけ。利確扱いにしない。
warnLong=pos == 1 and dc
warnShort=pos == -1 and gc

tpLong=pos == 1 and hitOB
tpShort=pos == -1 and hitOS

slLong=pos == 1 and not na(stopPrice) and low <= stopPrice
slShort=pos == -1 and not na(stopPrice) and high >= stopPrice

// ==================== 表示専用 利確条件 ====================
// 警告が出てもlastDirを維持して★を出せるようにする
showTpLong=tpLong or (lastDir == 1 and hitOB)
showTpShort=tpShort or (lastDir == -1 and hitOS)

showWarnLong=warnLong
showWarnShort=warnShort
showSlLong=slLong
showSlShort=slShort

// ==================== 内部決済処理 ====================
// 警告では決済しない。SLかTPだけで決済。
if slLong or tpLong
    pos:=0
    stopPrice:=na

if slShort or tpShort
    pos:=0
    stopPrice:=na

if slLong and lastDir == 1
    lastDir:=0
    lastDirBar:=na

if slShort and lastDir == -1
    lastDir:=0
    lastDirBar:=na

if tpLong and lastDir == 1
    lastDir:=0
    lastDirBar:=na

if tpShort and lastDir == -1
    lastDir:=0
    lastDirBar:=na

// ==================== 背景 ====================
bgcolor(showZoneBg and osActive ? color.new(color.blue, 93) : na)
bgcolor(showZoneBg and obActive ? color.new(color.red, 93) : na)

// ==================== 損切りライン ====================
plot(showSL and pos != 0 ? stopPrice : na, title="Stop Line", color=slColor, linewidth=2, style=plot.style_linebr)

// ==================== 表示位置 ====================
yLong1=low - yOffset * 1.0
yLong2=low - yOffset * 1.8
yLong3=low - yOffset * 2.6
yLong4=low - yOffset * 3.4

yShort1=high + yOffset * 1.0
yShort2=high + yOffset * 1.8
yShort3=high + yOffset * 2.6
yShort4=high + yOffset * 3.4

// ==================== ラベル表示 ====================
// 同じバーに複数出る前提で、少しずつ位置をずらす
if showLabels and showLongEntry
    label.new(bar_index, yLong1, "L", style=label.style_none, textcolor=longColor, size=longSize)

if showLabels and showShortEntry
    label.new(bar_index, yShort1, "S", style=label.style_none, textcolor=shortColor, size=shortSize)

if showLabels and showTpLong
    label.new(bar_index, yShort2, "★", style=label.style_none, textcolor=tpColor, size=tpSize)

if showLabels and showTpShort
    label.new(bar_index, yLong2, "★", style=label.style_none, textcolor=tpColor, size=tpSize)

if showLabels and showWarnLong
    label.new(bar_index, yShort3, "⚠", style=label.style_none, textcolor=warnColor, size=warnSize)

if showLabels and showWarnShort
    label.new(bar_index, yLong3, "⚠", style=label.style_none, textcolor=warnColor, size=warnSize)

if showLabels and showSlLong
    label.new(bar_index, yLong4, "SL", style=label.style_none, textcolor=slColor, size=slSize)

if showLabels and showSlShort
    label.new(bar_index, yShort4, "SL", style=label.style_none, textcolor=slColor, size=slSize)

// ==================== 補助表示 ====================
plot(showEMA ? emaFast : na, title="EMA 5", color=color.yellow, linewidth=2)
plot(showEMA ? emaSlow : na, title="EMA 13", color=color.white, linewidth=2)
plot(showEMA ? emaTrend : na, title="EMA 200", color=color.blue, linewidth=2)

// ==================== アラート ====================
alertcondition(showLongEntry, title="Long Entry", message="L: 売られすぎ到達後にEMA5/13がGC")
alertcondition(showShortEntry, title="Short Entry", message="S: 買われすぎ到達後にEMA5/13がDC")
alertcondition(showWarnLong, title="Long Warning", message="⚠ ロング中にEMA5/13がDC")
alertcondition(showWarnShort, title="Short Warning", message="⚠ ショート中にEMA5/13がGC")
alertcondition(showTpLong, title="Long Take Profit", message="★ ロング利確: 買われすぎ到達")
alertcondition(showTpShort, title="Short Take Profit", message="★ ショート利確: 売られすぎ到達")
alertcondition(showSlLong, title="Long Stop Loss", message="SL ロング損切り")
alertcondition(showSlShort, title="Short Stop Loss", message="SL ショート損切り")
alertcondition(showLongEntry or showShortEntry, title="Entry Any", message="Entry Any: LまたはS")
alertcondition(hitOS or hitOB, title="Zone Any", message="Zone Any: 売られすぎまたは買われすぎ")
alertcondition(showLongEntry or showShortEntry or showWarnLong or showWarnShort or showTpLong or showTpShort or showSlLong or showSlShort, title="All Signals", message="All Signals")
````

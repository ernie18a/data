# 007_croissant

- url: https://www.tradingview.com/script/Jxdt90zo/
- type: indicator
- pine_id: PUB;2f5b63931f334a7d8eacea1894ee820a
- version: 1.0

## Description

1時間足推奨。
26,104期間の基準線とローソク足の位置関係で、レンジを含めたトレンド判断。
26基準線に終値タッチでウリ、カイの矢印表示。
各機能はカスタマイズできます。
クロワッサンスキの人は是非どうぞ。

## Source Code

````pine
//@version=5
indicator("時代判定インジケーター", overlay=true, max_labels_count=500)

// ============================================================================
// === パラメータ ===
// ============================================================================
shortLen     = input.int(26,  "短期基準線 期間", minval=1, group="基準線")
longLen      = input.int(104, "長期基準線 期間", minval=1, group="基準線")

// 透明度: 0=完全不透明 / 100=完全透明
buyFillTransp  = input.int(85, "カイ時代 塗り透明度 (0=濃, 100=透明)", minval=0, maxval=100, group="塗りつぶし")
sellFillTransp = input.int(85, "ウリ時代 塗り透明度 (0=濃, 100=透明)", minval=0, maxval=100, group="塗りつぶし")

// マチ時代の判定パラメータ
machiBars    = input.int(3,    "マチ判定: 水平確認バー数", minval=1, group="マチ時代")
machiGapPct  = input.float(5.0,"マチ判定: 乖離許容 (% of price)", minval=0.0, step=0.1, group="マチ時代")

// シグナル制御
signalMode   = input.string("最初の1回のみ", "シグナル発生モード", options=["最初の1回のみ", "毎回"], group="シグナル")
buyAlertOn   = input.bool(true, "カイアラート 有効", group="アラート")
sellAlertOn  = input.bool(true, "ウリアラート 有効", group="アラート")

// ============================================================================
// === 基準線の計算 (一目均衡表方式) ===
// ============================================================================
shortBase = (ta.highest(high, shortLen) + ta.lowest(low, shortLen)) / 2
longBase  = (ta.highest(high, longLen)  + ta.lowest(low,  longLen))  / 2

// ============================================================================
// === 時代判定 ===
// ============================================================================
// 水平判定: 直近 machiBars バー間で値が変化していない
shortFlat = shortBase == shortBase[machiBars]
longFlat  = longBase  == longBase[machiBars]
// 乖離判定: 2線の差の絶対値が 価格 × machiGapPct% 以下
gapSmall  = math.abs(shortBase - longBase) <= close * machiGapPct / 100.0

// マチ時代:「開きがない」AND「両線ともに水平」(全条件 AND)
isMachi = gapSmall and shortFlat and longFlat
isKai   = not isMachi and shortBase > longBase
isUri   = not isMachi and shortBase < longBase

// ============================================================================
// === 基準線描画 ===
// ============================================================================
shortPlot = plot(shortBase, "短期基準線(26)", color=color.yellow, linewidth=2)
longPlot  = plot(longBase,  "長期基準線(104)", color=color.red,    linewidth=2)

// ============================================================================
// === 塗りつぶし ===
// ============================================================================
// 塗りつぶしは「時代判定」ではなく、2線の位置関係そのもので決定する。
// (マチ時代でも乖離が見えている期間は塗りを継続させるため)
fillColor = shortBase > longBase ? color.new(color.blue, buyFillTransp)
          : shortBase < longBase ? color.new(color.red,  sellFillTransp)
          : na
fill(shortPlot, longPlot, color=fillColor, title="時代塗りつぶし")

// ============================================================================
// === 右上タグ表示 ===
// ============================================================================
var table eraTable = table.new(position.top_right, 1, 1, border_width=1)
if barstate.islast
    eraText  = isKai ? "カイ時代" : isUri ? "ウリ時代" : "マチ時代"
    eraColor = isKai ? color.blue : isUri ? color.red  : color.gray
    table.cell(eraTable, 0, 0, eraText, text_color=color.white, bgcolor=eraColor, text_size=size.large)

// ============================================================================
// === タッチ判定 (終値ベース・確定足のみ) ===
// ============================================================================
// カイ: 前足クローズが26基準線より上 → 当足クローズが26基準線以下 (上からタッチ)
kaiTouch = barstate.isconfirmed and isKai and close[1] > shortBase[1] and close <= shortBase
// ウリ: 前足クローズが26基準線より下 → 当足クローズが26基準線以上 (下からタッチ)
uriTouch = barstate.isconfirmed and isUri and close[1] < shortBase[1] and close >= shortBase

// ============================================================================
// === 時代切替 & シグナルモード制御 ===
// ============================================================================
eraId = isKai ? 1 : isUri ? -1 : 0
var int  prevEraId      = 0
var bool kaiFiredInEra  = false
var bool uriFiredInEra  = false

eraChanged = barstate.isconfirmed and eraId != prevEraId
if eraChanged
    kaiFiredInEra := false
    uriFiredInEra := false
if barstate.isconfirmed
    prevEraId := eraId

firstOnly = signalMode == "最初の1回のみ"
kaiSignal = kaiTouch and (not firstOnly or not kaiFiredInEra)
uriSignal = uriTouch and (not firstOnly or not uriFiredInEra)

if kaiSignal
    kaiFiredInEra := true
if uriSignal
    uriFiredInEra := true

// ============================================================================
// === シグナル描画 (矢印 + ラベル) ===
// ============================================================================
plotshape(kaiSignal, title="カイシグナル", style=shape.triangleup,
          location=location.belowbar, color=color.blue, size=size.normal,
          text="カイ", textcolor=color.white)
plotshape(uriSignal, title="ウリシグナル", style=shape.triangledown,
          location=location.abovebar, color=color.red, size=size.normal,
          text="ウリ", textcolor=color.white)

// ============================================================================
// === アラート ===
// ============================================================================
// alert(): TradingView の通知設定でメール/ポップアップ/Webhook を選択可能
if kaiSignal and buyAlertOn
    alert("カイシグナル発生：価格が26基準線に上からタッチしました", alert.freq_once_per_bar_close)
if uriSignal and sellAlertOn
    alert("ウリシグナル発生：価格が26基準線に下からタッチしました", alert.freq_once_per_bar_close)

// alertcondition(): TV のアラート作成画面で個別に選択可能
alertcondition(kaiSignal and buyAlertOn,  title="カイアラート", message="カイシグナル発生：価格が26基準線に上からタッチ")
alertcondition(uriSignal and sellAlertOn, title="ウリアラート", message="ウリシグナル発生：価格が26基準線に下からタッチ")
````

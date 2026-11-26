# NORN WEAVE | THURISAZ

- url: https://www.tradingview.com/script/ab5k064U/
- type: strategy
- pine_id: PUB;1bf8829ec2fa45fa95497cd1806edbbe
- version: 2.0

## Description

# NORN WEAVE ᚦ THURISAZ

---

### Overview

NORN WEAVE ᚦ THURISAZ is the third version of the NORN WEAVE series, built on URUZ as its foundation.

The core logic is unchanged — EMA slope, Dow Theory swing structure, ADX trend confirmation. What changed is the entry filter. THURISAZ adds one question before every trade: *where are we standing on the daily chart?*

URUZ was built to survive. THURISAZ is built to choose. Bad entries don't just lose money — they consume time, margin, and mental bandwidth. The goal of this version is to stop entering trades that look right on the current timeframe but are wrong on the bigger picture.

The philosophy remains: survival first, profit second. THURISAZ adds a third principle — *don't enter where you shouldn't be standing.*

---

### What's New: Daily Fibonacci Filter

THURISAZ introduces a daily timeframe Fibonacci filter as a structural context layer.

When the current timeframe trend and the daily trend align, the strategy behaves exactly like URUZ — no additional friction.

When they diverge, THURISAZ evaluates *where* price sits within the daily swing range using Fibonacci retracement levels (0.382 and 0.618):

- **Mid zone (0.382–0.618)** — Price is in the middle of the daily range. This is the "landing zone": the most likely area for a pullback to stall and reverse, not complete. Entries are blocked.
- **Shallow zone (below 0.382)** — The pullback is still early. Entry is allowed, but TP1 is adjusted to the 0.382 level rather than the standard ATR-based target. Partial profit is taken before the natural resistance zone.
- **Deep zone (above 0.618)** — Price has retraced significantly. Potential reversal territory. Entry is allowed with standard targets.

The daily swing detection period is independently configurable from the current timeframe's Focus Level, giving finer control over what constitutes a "daily swing."

---

### Entry Conditions

**Long:** EMA rising AND Dow Theory trend up AND ADX above threshold AND Daily Fibo zone allows AND Footprint Delta bullish (if filter enabled)

**Short:** EMA falling AND Dow Theory trend down AND ADX above threshold AND Daily Fibo zone allows AND Footprint Delta bearish (if filter enabled)

---

### Exit Conditions

- TP1 — ATR × Factor × 1 → closes 30% (or Fibo 0.382 if shallow counter-trend entry)
- TP2 — ATR × Factor × 2 → closes another 30%
- TP3 — ATR × Factor × 3 → closes a further 30%
- Stop Loss — fixed % from entry → closes full position
- Break Even Stop — once floating profit reaches the BE trigger %, stop moves to entry price and closes on pullback
- Trend Reversal — when Dow Theory swing flips → closes full position

---

### Focus Level & Auto Calibration

Unchanged from URUZ. Focus Level is the primary knob — adjust it first when applying to a new symbol or timeframe.

Auto Calibration computes ADX threshold, ATR factor, and Stop Loss from the chart's own volatility data. When enabled, no manual tuning is required.

---

### Break Even Stop

Unchanged from URUZ. One parameter: how far price must move from entry before the stop activates. Stop is always placed at entry price.

---

### Footprint Delta Filter *(Premium plan required)*

Unchanged from URUZ. Uses BTC or ETH footprint delta as a directional confirmation filter. Blocks entries when order flow contradicts the trade direction.

---

### Parameters

- **Focus Level** (default 13) — Main knob. Controls swing detection and EMA scaling.
- **EMA Scale Ratio** (default 5) — EMA length = Focus Level × this value.
- **Daily Swing Length** (default 10) — Swing detection period for the daily timeframe. Independent from Focus Level.
- **Show Daily Fibo Zone** (default ON) — Displays the 0.382 and 0.618 levels on the chart for visual reference.
- **Auto Calibration** (default ON) — Computes ADX threshold, ATR factor, and SL automatically.
- **BE Trigger %** (default 5.5%) — How far price must move before the BE stop activates.
- **ATR Factor** — Manual mode only. Default 3.8.
- **Stop Loss %** — Manual mode only. Default -10.0%.
- **ADX Threshold** — Manual mode only. Default 20.5.
- **Footprint SMA Period** (default 21) — Smoothing period for delta signal.

---

### On Overfitting

One of the design principles of the NORN WEAVE series has been to minimize the number of configurable parameters. More parameters means more room to fit historical data — and less reason to trust that the results will hold going forward.

THURISAZ adds one new parameter: Daily Swing Length. That's it.

The Fibonacci levels themselves (0.382 and 0.618) are not parameters — they are fixed, widely recognized structural levels used by traders across markets and timeframes. They were not chosen by optimizing against backtest data.

The Daily Fibonacci Filter was validated across six symbols (SOL, DOGE, ETH, SUI, NEAR, PEPE). Five of the six showed improvement in profit factor and drawdown. The one exception — PEPE — deteriorated, which is the expected behavior: PEPE's explosive, non-structural price action doesn't respect daily swing context the way trend-following instruments do. A filter that improves everything uniformly would be suspicious. This result is not.

The filter works because the idea behind it is sound, not because it was tuned to work.

---

### Visual Guide

- **EMA line** — 3-layer glow. Teal when rising, red when falling.
- **Dow Theory zones** — gradient fill from current swing level to current price.
- **Daily Fibo lines** — gold lines at 0.382 and 0.618 of the daily swing. Shaded zone between them marks where entries are blocked.
- **TP lines** — semi-transparent. TP1 faintest, TP3 most visible.
- **BE Stop line** — gold, appears only when active.
- **Gray background** — ADX below threshold. No entries.
- **Orange background** — Footprint Delta Filter blocking entry, or Daily Fibo mid zone active.
- **Status table** — real-time display of all conditions. Japanese/English toggle included. Daily Fibo status shown as: Same Dir / Mid Zone (blocked) / Shallow (TP adjusted) / Deep (reversal watch).

---
---

### 概要

NORN WEAVE ᚦ THURISAZ は、URUZを土台とした NORN WEAVE シリーズ第3バージョンです。

コアロジックは変わっていません——EMAの傾き・ダウ理論のスイング構造・ADXトレンド確認。変わったのはエントリーフィルターです。THURISAZは、すべてのトレードの前に一つの問いを加えます。*日足でみたとき、今どこに立っているのか？*

URUZは「生き残る」ために設計されました。THURISAZは「選ぶ」ために設計されています。悪いエントリーは資金を失うだけでなく、時間・証拠金・集中力を消費します。このバージョンの目標は、現在足ではシグナルが正しく見えても、大きな地形では立ってはいけない場所へのエントリーを止めることです。

哲学は変わっていません。まず生き残る、利益はその次。THURISAZは三つ目の原則を加えます——*立つべきでない場所には立たない。*

---

### 追加機能：日足フィボフィルター

THURISAZは、相場の地形を把握するための「日足フィボナッチフィルター」を新たに導入しました。

現在足のトレンドと日足のトレンドが同じ方向の場合、ストラテジーはURUZとまったく同じ挙動をします——追加の制約はありません。

方向が逆の場合、THURISAZはフィボナッチリトレースメント水準（0.382・0.618）を使い、日足スイングのどの位置に価格があるかを評価します。

- **中間ゾーン（0.382〜0.618）** — 価格が日足レンジの真ん中にある状態。「踊り場」と呼ぶべき位置で、押し目・戻しが途中で止まって反転する可能性が最も高い。エントリーをブロックします。
- **浅いゾーン（0.382以下）** — 押し目・戻しがまだ浅い段階。エントリーは許可しますが、TP1を通常のATRベースから日足フィボ0.382水準に調整します。自然な抵抗ゾーンの手前で部分利確します。
- **深いゾーン（0.618以上）** — 大きく押し込まれた位置。反転の可能性がある水準として通常通りエントリーします。

日足のスイング検出期間は現在足のフォーカスレベルとは独立して設定できます。

---

### エントリー条件

**ロング：** EMA上向き AND ダウ理論上昇 AND ADXしきい値以上 AND 日足フィボゾーン許可 AND フットプリントデルタ買い優勢（フィルター有効時）

**ショート：** EMA下向き AND ダウ理論下降 AND ADXしきい値以上 AND 日足フィボゾーン許可 AND フットプリントデルタ売り優勢（フィルター有効時）

---

### イグジット条件

- TP1 — ATR×倍率×1 → 30%決済（逆張り・浅いゾーン時はフィボ0.382水準）
- TP2 — ATR×倍率×2 → さらに30%決済
- TP3 — ATR×倍率×3 → さらに30%決済
- ストップロス — エントリーから設定%に達したら全決済
- ブレークイーブンストップ — 含み益がBE発動しきい値%に達したらストップが建値に移動。価格が戻ったら全決済
- トレンド反転 — ダウ理論スイングが逆転した時点で全決済

---

### フォーカスレベルとオートキャリブレーション

URUZから変更なし。フォーカスレベルが主軸ノブです。新しい銘柄・時間足に適用するときはここを最初に調整してください。

オートキャリブレーションをONにすると、ADXしきい値・ATR倍率・SLがチャートのボラティリティデータから自動算出されます。

---

### ブレークイーブンストップ

URUZから変更なし。設定項目は一つ——「何%動いたら発動するか」だけ。ストップ位置は常に建値です。

---

### フットプリント・デルタフィルター *（Premiumプラン以上が必要）*

URUZから変更なし。BTCまたはETHのフットプリントデルタを方向性確認フィルターとして使用します。

---

### パラメーター

- **フォーカスレベル**（デフォルト13）— 主軸ノブ。スイング検出・EMAスケールを制御。
- **EMAスケール倍率**（デフォルト5）— EMA期間 = フォーカスレベル × この値。
- **日足スイング検出期間**（デフォルト10）— 日足フィボ計算に使うスイング検出期間。フォーカスレベルとは独立。
- **日足フィボゾーン表示**（デフォルトON）— 0.382・0.618ラインをチャートに表示。
- **オートキャリブレーション**（デフォルトON）— ADXしきい値・ATR倍率・SLを自動算出。
- **BE発動しきい値%**（デフォルト5.5%）— エントリーからこの%動いたらBEストップが発動。
- **ATR倍率**（手動）— オートキャリブレーションOFF時に有効。デフォルト3.8。
- **損切り%**（手動）— オートキャリブレーションOFF時に有効。デフォルト-10.0%。
- **ADXしきい値**（手動）— オートキャリブレーションOFF時に有効。デフォルト20.5。
- **フットプリントSMA期間**（デフォルト21）— デルタシグナルの平滑化期間。

---

### 過剰最適化について

NORN WEAVE シリーズの設計方針の一つは、パラメーター数をできる限り減らすことでした。パラメーターが増えるほど過去データへの過剰適合が起きやすくなり、将来の結果を信頼する根拠が薄れるからです。

THURISAZで追加したパラメーターは「日足スイング検出期間」の一つだけです。

フィボナッチ水準（0.382・0.618）自体はパラメーターではありません——バックテストデータを最適化して選んだ値ではなく、多くのトレーダーが長年にわたって参照してきた普遍的な構造水準です。

日足フィボフィルターは6銘柄（SOL・DOGE・ETH・SUI・NEAR・PEPE）で検証しました。そのうち5銘柄でPFとDDが改善しました。唯一悪化したのはPEPEですが、これは想定内の結果です——PEPEの急騰急落型の値動きは日足スイング構造を参照するロジックとそもそも相性が悪い。すべての銘柄で一様に改善するフィルターの方が、むしろ過剰最適化を疑うべきです。

このフィルターが機能するのは、チューニングの結果ではなく、背後にある考え方が正しいからだと考えています。

---

### チャートの見方

- **EMAライン** — 3層グロー効果。上向きはティール、下向きはレッド。
- **ダウ理論ゾーン** — 現在のスイングレベルから現在価格へのグラデーション。
- **日足フィボライン** — 日足スイングの0.382・0.618をゴールドラインで表示。その間のシェードが「踊り場ゾーン（エントリーブロック）」。
- **TPライン** — 半透明。TP1が最も薄く、TP3が最も濃い。
- **BEストップライン** — ゴールド。発動中のみ表示。
- **グレー背景** — ADXがしきい値以下。エントリーなし。
- **オレンジ背景** — フットプリントデルタフィルターがブロック中、または日足フィボ踊り場ゾーンが有効。
- **ステータステーブル** — 全条件・パラメーター値をリアルタイム表示。日英切り替え対応。日足フィボの状態は「同方向 / 踊り場（ブロック）/ 浅い（TP調整）/ 深い（反転狙い）」で表示。

## Source Code

````pine
//@version=6
strategy("NORN WEAVE | THURISAZ", overlay=true,
     initial_capital=16600,
     commission_type=strategy.commission.percent,
     commission_value=0.055,
     margin_long=0.001,
     margin_short=0.001,
     precision=4,
     default_qty_type=strategy.percent_of_equity,
     default_qty_value=3)
import TradingView/ta/7

// =====================
// 🌐 言語設定 / Language
// =====================
langJP = input.bool(true, "日本語表示 / Japanese", group="[ LANGUAGE ]",
     tooltip="ON = 日本語\nOFF = English")

// =====================================================================
// 📐 フォーカス設定 / FOCUS
// =====================================================================
swingLen = input.int(15, "📐 フォーカスレベル / Focus Level",
     minval=3, maxval=50, group="[ FOCUS ]",
     tooltip="主軸ノブ。スイング検出期間を設定します。\n他の通貨・時間足でズレを感じたらここを最初に調整。\nEMAはこの値×スケール倍率で自動追従します。\n\nMain knob — sets swing detection period.\nAdjust this first when applying to a new symbol/timeframe.\nEMA auto-tracks via Scale Ratio below.")

emaRatio = input.int(16, "EMAスケール倍率 / EMA Scale Ratio",
     minval=2, maxval=50, group="[ FOCUS ]",
     tooltip="EMA期間 = フォーカスレベル × この値。\nデフォルト 5 → 13×5=65（元の58に近い値）。\n大きいほど長期EMA（遅い追従）、小さいほど短期EMA（速い追従）。\n\nEMA length = Focus Level × this value.\nDefault 5 → 13×5=65 (close to original 58).\nHigher = slower EMA, Lower = faster EMA.")

// =====================================================================
// 🗓 日足フィボフィルター / Daily Fibo Filter
// =====================================================================
dailySwingLen = input.int(7, "📐 日足スイング検出期間 / Daily Swing Length",
     minval=3, maxval=30, group="[ DAILY FIBO FILTER ]",
     tooltip="日足のスイング高値・安値を検出する期間。現在足のフォーカスレベルとは独立して設定できます。\n\nSwing detection period for daily timeframe.\nIndependent from the current TF Focus Level.")

showFiboZone = input.bool(true, "日足フィボゾーン表示 / Show Daily Fibo Zone",
     group="[ DAILY FIBO FILTER ]",
     tooltip="日足フィボの0.382・0.618ラインをチャートに表示します。\n踊り場ゾーン（エントリーしないゾーン）の視覚確認用。")

// =====================================================================
// ✅ ファンダメンタル・フィルター / Fundamental Filter
// =====================================================================
fltEnabled = input.bool(true, "Enable Footprint Delta Filter / フットプリント・デルタフィルターを使う",
     group="[ FUNDAMENTAL FILTER ]",
     tooltip="EN: Filter entries using footprint delta (buy vol - sell vol) of BTC or ETH.\nPositive delta SMA → buyers in control → Long favored ✅\nNegative delta SMA → sellers in control → Short favored ✅\nRequires Premium+ plan.\n\nJP: BTCまたはETHのフットプリント・デルタ（買い出来高-売り出来高）でエントリーをフィルタリング。\nデルタSMAプラス → 買い優勢 → ロングに有利 ✅\nデルタSMAマイナス → 売り優勢 → ショートに有利 ✅\nPremium以上プラン必須。")

fltFpSymChoice = input.string("BTC / BTCUSD", "Footprint Symbol / 参照銘柄",
     group="[ FUNDAMENTAL FILTER ]",
     options=["BTC / BTCUSD", "ETH / ETHUSD"],
     tooltip="EN: Which symbol to use for footprint delta. BTC recommended for most altcoins including DOGE.\nJP: フットプリントを取得する銘柄。DOGE含むアルトコイン全般にはBTCが推奨。")

fltFpLookback = input.int(20, "Delta SMA Period / デルタSMA期間",
     group="[ FUNDAMENTAL FILTER ]", minval=1, maxval=50,
     tooltip="EN: SMA period applied to delta to smooth noise. Lower = more reactive, higher = more stable.\nJP: デルタを平滑化するSMA期間。小さいほど敏感、大きいほど安定。")

// =====================================================================
// ✅ ブレークイーブンストップ / Break Even Stop
// =====================================================================
beEnabled = input.bool(true, "Enable BE Stop (BEストップを有効にする)",
     group="[ BREAK EVEN STOP ]",
     tooltip="価格がエントリーから「BE発動しきい値%」以上動いたら BEストップを発動します。\nストップ位置は常に建値（エントリー価格）です。\n\nActivates a break-even stop once price moves the specified % from entry.\nStop is always placed at the entry price (break-even).")

beThresh = input.float(8.5, "BE Trigger % (BE発動しきい値%)",
     group="[ BREAK EVEN STOP ]", step=0.5, minval=0.5,
     tooltip="エントリーからこの%以上動いたら BEストップ（建値）が発動します。\nautoCalib の ON/OFF に関係なく、常にここで設定した値が使われます。\n\n推奨：SL絶対値の 50〜70%\n  例）SL=-10% → BE発動 5〜7%\n\nBE activates when price moves this % from entry.\nThis value is always used regardless of Auto Calibration setting.\n\nRecommended: 50–70% of |SL|\n  e.g. SL=-10% → BE trigger 5–7%")

// =====================================================================
// 🔧 マニュアル微調整 / Manual Tune
// =====================================================================
autoCalib = input.bool(true, "🔧 オートキャリブレーション / Auto Calibration",
     group="[ MANUAL TUNE ]",
     tooltip="ON：ADX閾値・ATR倍率・SLをチャートデータから自動算出。\n      新しい銘柄や時間足には ON 推奨。\nOFF：下の値を使用。\n\nON:  Auto-calculates ADX threshold, ATR factor, SL from chart.\n     Recommended ON for new symbols / timeframes.\nOFF: Uses values below.")

manualAtrFactor    = input.float(3.8,   "ATR Factor - TP Distance (ATR倍率・TP距離)",
     group="[ MANUAL TUNE ]", step=0.1,
     tooltip="autoCalib=OFF のときのみ有効。\nActive only when Auto Calibration is OFF.")
manualStopLoss     = input.float(-10.0, "Stop Loss % (損切り%)",
     group="[ MANUAL TUNE ]", step=0.5,
     tooltip="autoCalib=OFF のときのみ有効。\nActive only when Auto Calibration is OFF.")
manualAdxThreshold = input.float(20.5,  "ADX Threshold (ADXしきい値)",
     group="[ MANUAL TUNE ]", step=0.5,
     tooltip="autoCalib=OFF のときのみ有効。\nActive only when Auto Calibration is OFF.")

// =====================================================================
// ✅ 表示設定 / Display
// =====================================================================
showEma       = input.bool(true,  "EMA Line (EMAライン)",              group="[ DISPLAY ]")
showDowZone   = input.bool(true,  "Dow Zone / ダウゾーン",              group="[ DISPLAY ]")
showSwingLine = input.bool(true,  "Swing Line / スイングライン",         group="[ DISPLAY ]")
showTP        = input.bool(true,  "TP Lines / TPライン",                group="[ DISPLAY ]")
showBE        = input.bool(true,  "BE Stop Line / BEストップライン",     group="[ DISPLAY ]")
showHTF       = input.bool(true,  "Higher TF Swing / 上位足スイング",    group="[ DISPLAY ]")
showLabels    = input.bool(true,  "Trade Labels / トレードラベル",       group="[ DISPLAY ]")
showBG        = input.bool(true,  "Background / 背景色",                group="[ DISPLAY ]")
showTable     = input.bool(true,  "Status Table / ステータステーブル",   group="[ DISPLAY ]")
tablePos      = input.string("Top Right / 右上", "Table Position / テーブル位置",
     group="[ DISPLAY ]",
     options=["Top Right / 右上", "Top Left / 左上", "Bottom Right / 右下", "Bottom Left / 左下"])

// =====================================================================
// ⚙️ オートキャリブレーション計算
// =====================================================================
calcEmaLen = swingLen * emaRatio
[_diP, _diM, adxValue] = ta.dmi(14, 14)
_adxPctRaw       = ta.percentile_nearest_rank(adxValue, 300, 50)
autoAdxThreshold = na(_adxPctRaw) ? 20.5 : _adxPctRaw
atrPct      = ta.atr(14) / close * 100
atrPctAvg   = ta.sma(atrPct, 200)
volRatio    = (not na(atrPctAvg) and atrPctAvg > 0.0) ? atrPct / atrPctAvg : 1.0
volAdj        = math.min(math.max(1.0 - volRatio, -1.0), 1.0)
autoAtrFactor = 3.8 + volAdj * 0.8
atrPctSmooth = ta.sma(atrPct, 50)
_rawSl       = na(atrPctSmooth) ? -10.0 : -(atrPctSmooth * 3.5)
autoStopLoss = math.max(math.min(_rawSl, -5.0), -20.0)
emaLen       = calcEmaLen
adxThreshold = autoCalib ? autoAdxThreshold : manualAdxThreshold
atrFactor    = autoCalib ? autoAtrFactor    : manualAtrFactor
stopLoss     = autoCalib ? autoStopLoss     : manualStopLoss

// =====================================================================
// フットプリント・デルタ計算
// =====================================================================
fltFpSymbol     = fltFpSymChoice == "BTC / BTCUSD" ? "BITSTAMP:BTCUSD" : "BITSTAMP:ETHUSD"
footprint fpData    = request.security(fltFpSymbol, timeframe.period, request.footprint(100, 70))
float fltFpDelta    = not na(fpData) ? fpData.delta() : na
float fltFpDeltaSma = ta.sma(fltFpDelta, fltFpLookback)

fpBullish    = not na(fltFpDeltaSma) and fltFpDeltaSma > 0
fpBearish    = not na(fltFpDeltaSma) and fltFpDeltaSma < 0
fltPass      = not fltEnabled or na(fltFpDeltaSma) or fpBullish or fpBearish
fltPassLong  = not fltEnabled or na(fltFpDeltaSma) or fpBullish
fltPassShort = not fltEnabled or na(fltFpDeltaSma) or fpBearish

// =====================================================================
// EMA計算
// =====================================================================
ema    = ta.ema(close, emaLen)
emaUp   = ema > ema[1]
emaDown = ema < ema[1]

// =====================================================================
// ADX トレンド判定
// =====================================================================
isTrending = adxValue > adxThreshold

// =====================================================================
// スイング検出（現在足）
// =====================================================================
isSwingHigh = high[swingLen] == ta.highest(high, swingLen * 2 + 1)
isSwingLow  = low[swingLen]  == ta.lowest(low,  swingLen * 2 + 1)

var float lastSwingHigh = na
var float lastSwingLow  = na
lastSwingHigh := isSwingHigh ? high[swingLen] : lastSwingHigh
lastSwingLow  := isSwingLow  ? low[swingLen]  : lastSwingLow

// =====================================================================
// ダウ理論トレンド判定（現在足）
// =====================================================================
var int trend = 0
if not na(lastSwingHigh) and close > lastSwingHigh and trend != 1
    trend := 1
if not na(lastSwingLow)  and close < lastSwingLow  and trend != -1
    trend := -1

// =====================================================================
// 🗓 日足フィボフィルター計算
// =====================================================================

// 日足スイング高値・安値取得
dSwingHigh = request.security(syminfo.tickerid, "D",
     ta.pivothigh(high, dailySwingLen, dailySwingLen)[1],
     lookahead=barmerge.lookahead_off)
dSwingLow = request.security(syminfo.tickerid, "D",
     ta.pivotlow(low, dailySwingLen, dailySwingLen)[1],
     lookahead=barmerge.lookahead_off)

var float lastDSwingHigh = na
var float lastDSwingLow  = na
lastDSwingHigh := na(dSwingHigh) ? lastDSwingHigh : dSwingHigh
lastDSwingLow  := na(dSwingLow)  ? lastDSwingLow  : dSwingLow

// 日足トレンド判定（ダウ理論）
dClose = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_off)

var int dTrend = 0
if not na(lastDSwingHigh) and dClose > lastDSwingHigh and dTrend != 1
    dTrend := 1
if not na(lastDSwingLow)  and dClose < lastDSwingLow  and dTrend != -1
    dTrend := -1

// フィボ水準計算
dFiboRange = not na(lastDSwingHigh) and not na(lastDSwingLow) ? lastDSwingHigh - lastDSwingLow : na

// ロング逆張り用（日足下降中の押し目：安値基点）
dFibo382L = not na(dFiboRange) ? lastDSwingLow  + dFiboRange * 0.382 : na
dFibo618L = not na(dFiboRange) ? lastDSwingLow  + dFiboRange * 0.618 : na

// ショート逆張り用（日足上昇中の戻し：高値基点）
dFibo382S = not na(dFiboRange) ? lastDSwingHigh - dFiboRange * 0.382 : na
dFibo618S = not na(dFiboRange) ? lastDSwingHigh - dFiboRange * 0.618 : na

// 現在価格のゾーン判定
// ロング逆張り時（日足下降・現在足上昇）
inFiboMidL     = not na(dFibo382L) and close >= dFibo382L and close <= dFibo618L  // 踊り場→入らない
inFiboShallowL = not na(dFibo382L) and close < dFibo382L                           // 浅い→TP調整
// inFiboDeepL = not na(dFibo618L) and close > dFibo618L                           // 深い→通常エントリー

// ショート逆張り時（日足上昇・現在足下降）
inFiboMidS     = not na(dFibo382S) and close <= dFibo382S and close >= dFibo618S  // 踊り場→入らない
inFiboShallowS = not na(dFibo382S) and close > dFibo382S                           // 浅い→TP調整
// inFiboDeepS = not na(dFibo618S) and close < dFibo618S                           // 深い→通常エントリー

// 方向フラグ
dSameDir   = (dTrend == 1 and trend == 1) or (dTrend == -1 and trend == -1)
dAntiLong  = dTrend == -1 and trend == 1   // 日足下降・現在足上昇（ロング逆張り）
dAntiShort = dTrend ==  1 and trend == -1  // 日足上昇・現在足下降（ショート逆張り）

// エントリー可否（踊り場ゾーンのみブロック）
dFiboAllowLong  = dSameDir or dTrend == 0 or (dAntiLong  and not inFiboMidL)
dFiboAllowShort = dSameDir or dTrend == 0 or (dAntiShort and not inFiboMidS)

// 浅いゾーンフラグ（TP1をフィボ0.382に上書きするトリガー）
dAntiShallowLong  = dAntiLong  and inFiboShallowL
dAntiShallowShort = dAntiShort and inFiboShallowS

// =====================================================================
// エントリー条件
// =====================================================================
goLong  = emaUp   and trend == 1  and isTrending and fltPassLong  and dFiboAllowLong
goShort = emaDown and trend == -1 and isTrending and fltPassShort and dFiboAllowShort

// =====================================================================
// ATR / TP計算
// =====================================================================
atr = ta.atr(50) * atrFactor

var float tp1  = na
var float tp2  = na
var float tp3  = na
var float tp11 = na
var float tp22 = na
var float tp33 = na
var float entr = na

// =====================================================================
// ブレークイーブン管理
// =====================================================================
var bool  beActivated = false
var float bePrice     = na

// =====================================================================
// PnL計算
// =====================================================================
var float PnL = 0.
LastTriggeredPrice = strategy.opentrades.entry_price(strategy.opentrades - 1)
if strategy.position_size > 0.0 and LastTriggeredPrice != 0.0
    PnL := ((close - LastTriggeredPrice) / LastTriggeredPrice) * 100.0
else if strategy.position_size < 0.0 and LastTriggeredPrice != 0.0
    PnL := ((LastTriggeredPrice - close) / LastTriggeredPrice) * 100.0

var float TruePnL = na
var float Equity_AtStartTrade = na
TruePnL := na(Equity_AtStartTrade) ? na : ((strategy.equity / Equity_AtStartTrade) - 1.0) * 100.0

// BEストップ発動チェック
if beEnabled and strategy.position_size != 0.0 and not beActivated
    if strategy.position_size > 0.0 and PnL >= beThresh
        beActivated := true
        bePrice     := LastTriggeredPrice
    else if strategy.position_size < 0.0 and PnL >= beThresh
        beActivated := true
        bePrice     := LastTriggeredPrice

// =====================================================================
// 損切り（通常SL）
// =====================================================================
if PnL < stopLoss and strategy.position_size > 0.
    strategy.close("Long", "SL Long")
    beActivated := false
    bePrice     := na
    alert('{"Symbol":"' + syminfo.ticker + '","Side":"Buy","Price":' + str.tostring(close) + ',"Exit":true,"HalfExit":false, "Vertion":"7"}', alert.freq_once_per_bar)

if PnL < stopLoss and strategy.position_size < 0.
    strategy.close("Short", "SL Short")
    beActivated := false
    bePrice     := na
    alert('{"Symbol":"' + syminfo.ticker + '","Side":"Sell","Price":' + str.tostring(close) + ',"Exit":true,"HalfExit":false, "Vertion":"7"}', alert.freq_once_per_bar)

// =====================================================================
// BEストップ
// =====================================================================
if beEnabled and beActivated and not na(bePrice)
    if strategy.position_size > 0.0 and low <= bePrice
        strategy.close("Long", "BE Long")
        beActivated  := false
        bePrice      := na
        alert('{"Symbol":"' + syminfo.ticker + '","Side":"Buy","Price":' + str.tostring(close) + ',"Exit":true,"HalfExit":false, "Vertion":"7"}', alert.freq_once_per_bar)
    else if strategy.position_size < 0.0 and high >= bePrice
        strategy.close("Short", "BE Short")
        beActivated  := false
        bePrice      := na
        alert('{"Symbol":"' + syminfo.ticker + '","Side":"Sell","Price":' + str.tostring(close) + ',"Exit":true,"HalfExit":false, "Vertion":"7"}', alert.freq_once_per_bar)

// =====================================================================
// トレンド反転クローズ
// =====================================================================
if trend == 1 and strategy.position_size < 0
    strategy.close("Short", "trendChange→Long")
    beActivated := false
    bePrice     := na
    alert('{"Symbol":"' + syminfo.ticker + '","Side":"Sell","Price":' + str.tostring(close) + ',"Exit":true,"HalfExit":false, "Vertion":"7"}', alert.freq_once_per_bar)

if trend == -1 and strategy.position_size > 0
    strategy.close("Long", "trendChange→Short")
    beActivated := false
    bePrice     := na
    alert('{"Symbol":"' + syminfo.ticker + '","Side":"Buy","Price":' + str.tostring(close) + ',"Exit":true,"HalfExit":false, "Vertion":"7"}', alert.freq_once_per_bar)

// =====================================================================
// ロングエントリー
// =====================================================================
if strategy.position_size <= 0. and goLong
    if strategy.position_size < 0
        strategy.close("Short", comment="Exit Short→Long")
        alert('{"Symbol":"' + syminfo.ticker + '","Side":"Sell","Price":' + str.tostring(close) + ',"Exit":true,"HalfExit":false, "Vertion":"7"}', alert.freq_once_per_bar)
    if strategy.position_size == 0
        Equity_AtStartTrade := strategy.equity
        beActivated         := false
        bePrice             := na
        strategy.entry("Long", strategy.long)
        alert('{"Symbol":"' + syminfo.ticker + '","Side":"Buy","Price":' + str.tostring(close) + ',"Exit":false,"HalfExit":false, "Vertion":"7","Stop":'+str.tostring(0)+'}', alert.freq_once_per_bar_close)
        // TP1：逆張り・浅いゾーンならフィボ0.382、それ以外はATRベース
        tp1  := dAntiShallowLong and not na(dFibo382L) ? dFibo382L : close + atr
        tp2  := close + atr * 2
        tp3  := close + atr * 3
        tp11 := na
        tp22 := na
        tp33 := na
        entr := close

// =====================================================================
// ショートエントリー
// =====================================================================
if strategy.position_size >= 0. and goShort
    if strategy.position_size > 0
        strategy.close("Long", comment="Exit Long→Short")
        alert('{"Symbol":"' + syminfo.ticker + '","Side":"Buy","Price":' + str.tostring(close) + ',"Exit":true,"HalfExit":false, "Vertion":"7"}', alert.freq_once_per_bar)
    if strategy.position_size == 0
        Equity_AtStartTrade := strategy.equity
        beActivated         := false
        bePrice             := na
        strategy.entry("Short", strategy.short)
        alert('{"Symbol":"' + syminfo.ticker + '","Side":"Sell","Price":' + str.tostring(close) + ',"Exit":false,"HalfExit":false, "Vertion":"7","Stop":'+str.tostring(0)+'}', alert.freq_once_per_bar_close)
        // TP1：逆張り・浅いゾーンならフィボ0.382、それ以外はATRベース
        tp11 := dAntiShallowShort and not na(dFibo382S) ? dFibo382S : close - atr
        tp22 := close - atr * 2
        tp33 := close - atr * 3
        tp1  := na
        tp2  := na
        tp3  := na
        entr := close

// =====================================================================
// TP処理
// =====================================================================
if strategy.position_size > 0
    if high > tp1
        strategy.close('Long', 'Long TP1', qty_percent=30)
        alert('{"Symbol":"' + syminfo.ticker + '","Side":"Buy","Price":' + str.tostring(close) + ',"Exit":true,"halfExit":true, "vertion":"TP1"}', alert.freq_once_per_bar)
        tp1 := na
    if high > tp2
        strategy.close('Long', 'Long TP2', qty_percent=30)
        alert('{"Symbol":"' + syminfo.ticker + '","Side":"Buy","Price":' + str.tostring(close) + ',"Exit":true,"halfExit":true, "vertion":"TP2"}', alert.freq_once_per_bar)
        tp2 := na
    if high > tp3
        strategy.close('Long', 'Long TP3', qty_percent=30)
        alert('{"Symbol":"' + syminfo.ticker + '","Side":"Buy","Price":' + str.tostring(close) + ',"Exit":true,"halfExit":true, "vertion":"TP3"}', alert.freq_once_per_bar)
        tp3  := na
        entr := na

if strategy.position_size < 0
    if low < tp11
        strategy.close('Short', 'Short TP1', qty_percent=30)
        alert('{"Symbol":"' + syminfo.ticker + '","Side":"Sell","Price":' + str.tostring(close) + ',"Exit":true,"halfExit":true, "vertion":"TP1"}', alert.freq_once_per_bar)
        tp11 := na
    if low < tp22
        strategy.close('Short', 'Short TP2', qty_percent=30)
        alert('{"Symbol":"' + syminfo.ticker + '","Side":"Sell","Price":' + str.tostring(close) + ',"Exit":true,"halfExit":true, "vertion":"TP2"}', alert.freq_once_per_bar)
        tp22 := na
    if low < tp33
        strategy.close('Short', 'Short TP3', qty_percent=30)
        alert('{"Symbol":"' + syminfo.ticker + '","Side":"Sell","Price":' + str.tostring(close) + ',"Exit":true,"halfExit":true, "vertion":"TP3"}', alert.freq_once_per_bar)
        tp33 := na
        entr := na

// =====================================================================
// 🎨 NORN WEAVE — ビジュアル
// =====================================================================

C_BULL     = #e8eaf0
C_BEAR     = #c0152a
C_BE_COL   = #c9a84c
C_ENTRY    = #6b7280
C_HTF_BULL = #8ab4c2
C_HTF_BEAR = #9b3a4a
C_FLAT_BG  = #1a0a2e
C_FIBO     = #c9a84c

barPrice = close

// 1. ダウゾーン
sh_b  = trend == -1 ? lastSwingHigh : na
sh_q1 = trend == -1 ? lastSwingHigh - (lastSwingHigh - barPrice) * 0.22 : na
sh_q2 = trend == -1 ? lastSwingHigh - (lastSwingHigh - barPrice) * 0.50 : na
sh_q3 = trend == -1 ? lastSwingHigh - (lastSwingHigh - barPrice) * 0.78 : na
sh_e  = trend == -1 ? barPrice : na

p_shb  = plot(showDowZone ? sh_b  : na, display=display.none)
p_shq1 = plot(showDowZone ? sh_q1 : na, display=display.none)
p_shq2 = plot(showDowZone ? sh_q2 : na, display=display.none)
p_shq3 = plot(showDowZone ? sh_q3 : na, display=display.none)
p_she  = plot(showDowZone ? sh_e  : na, display=display.none)
fill(p_shb,  p_shq1, color.new(C_BEAR, 40))
fill(p_shq1, p_shq2, color.new(C_BEAR, 60))
fill(p_shq2, p_shq3, color.new(C_BEAR, 78))
fill(p_shq3, p_she,  color.new(C_BEAR, 90))

sl_b  = trend ==  1 ? lastSwingLow : na
sl_q1 = trend ==  1 ? lastSwingLow + (barPrice - lastSwingLow) * 0.22 : na
sl_q2 = trend ==  1 ? lastSwingLow + (barPrice - lastSwingLow) * 0.50 : na
sl_q3 = trend ==  1 ? lastSwingLow + (barPrice - lastSwingLow) * 0.78 : na
sl_e  = trend ==  1 ? barPrice : na

p_slb  = plot(showDowZone ? sl_b  : na, display=display.none)
p_slq1 = plot(showDowZone ? sl_q1 : na, display=display.none)
p_slq2 = plot(showDowZone ? sl_q2 : na, display=display.none)
p_slq3 = plot(showDowZone ? sl_q3 : na, display=display.none)
p_sle  = plot(showDowZone ? sl_e  : na, display=display.none)
fill(p_slb,  p_slq1, color.new(C_BULL, 40))
fill(p_slq1, p_slq2, color.new(C_BULL, 60))
fill(p_slq2, p_slq3, color.new(C_BULL, 78))
fill(p_slq3, p_sle,  color.new(C_BULL, 90))

// 2. スイングライン
plot(showSwingLine and trend == -1 ? lastSwingHigh : na, "Resist Outer", color=color.new(C_BEAR, 55), linewidth=3, style=plot.style_linebr)
plot(showSwingLine and trend == -1 ? lastSwingHigh : na, "Resist Core",  color=color.new(C_BEAR,  5), linewidth=1, style=plot.style_linebr)
plot(showSwingLine and trend ==  1 ? lastSwingLow  : na, "Support Outer",color=color.new(C_BULL, 55), linewidth=3, style=plot.style_linebr)
plot(showSwingLine and trend ==  1 ? lastSwingLow  : na, "Support Core", color=color.new(C_BULL,  5), linewidth=1, style=plot.style_linebr)

// 3. EMA
emaC_outer2 = emaUp ? color.new(C_BULL, 88) : color.new(C_BEAR, 88)
emaC_outer1 = emaUp ? color.new(C_BULL, 68) : color.new(C_BEAR, 68)
emaC_mid    = emaUp ? color.new(C_BULL, 40) : color.new(C_BEAR, 40)
emaC_core   = emaUp ? color.new(C_BULL,  5) : color.new(C_BEAR,  5)
plot(ema, "EMA Fog2", color=showEma ? emaC_outer2 : na, linewidth=14)
plot(ema, "EMA Fog1", color=showEma ? emaC_outer1 : na, linewidth=7)
plot(ema, "EMA Mid",  color=showEma ? emaC_mid    : na, linewidth=3)
plot(ema, "EMA Core", color=showEma ? emaC_core   : na, linewidth=1)

// 4. TPライン
plot(showTP ? (entr != entr[1] ? na : entr) : na, "Entry", color=color.new(C_ENTRY, 50), linewidth=1, style=plot.style_linebr)

tp1_plot  = showTP and strategy.position_size > 0 ? tp1  : na
tp2_plot  = showTP and strategy.position_size > 0 ? tp2  : na
tp3_plot  = showTP and strategy.position_size > 0 ? tp3  : na
tp11_plot = showTP and strategy.position_size < 0 ? tp11 : na
tp22_plot = showTP and strategy.position_size < 0 ? tp22 : na
tp33_plot = showTP and strategy.position_size < 0 ? tp33 : na

plot(tp1_plot,  "TP1 Glow",  color=color.new(C_BULL, 70), linewidth=3, style=plot.style_linebr)
plot(tp1_plot,  "TP1 Core",  color=color.new(C_BULL, 30), linewidth=1, style=plot.style_linebr)
plot(tp2_plot,  "TP2 Glow",  color=color.new(C_BULL, 55), linewidth=4, style=plot.style_linebr)
plot(tp2_plot,  "TP2 Core",  color=color.new(C_BULL, 10), linewidth=1, style=plot.style_linebr)
plot(tp3_plot,  "TP3 Glow",  color=color.new(C_BULL, 35), linewidth=6, style=plot.style_linebr)
plot(tp3_plot,  "TP3 Core",  color=color.new(C_BULL,  0), linewidth=2, style=plot.style_linebr)
plot(tp11_plot, "TP1S Glow", color=color.new(C_BEAR, 70), linewidth=3, style=plot.style_linebr)
plot(tp11_plot, "TP1S Core", color=color.new(C_BEAR, 30), linewidth=1, style=plot.style_linebr)
plot(tp22_plot, "TP2S Glow", color=color.new(C_BEAR, 55), linewidth=4, style=plot.style_linebr)
plot(tp22_plot, "TP2S Core", color=color.new(C_BEAR, 10), linewidth=1, style=plot.style_linebr)
plot(tp33_plot, "TP3S Glow", color=color.new(C_BEAR, 35), linewidth=6, style=plot.style_linebr)
plot(tp33_plot, "TP3S Core", color=color.new(C_BEAR,  0), linewidth=2, style=plot.style_linebr)

isLongEntry  = strategy.position_size > 0 and strategy.position_size[1] <= 0
isShortEntry = strategy.position_size < 0 and strategy.position_size[1] >= 0
if showTP and isLongEntry and not na(tp1)
    label.new(bar_index, tp1, "ᚠ TP1", color=color.new(#1a0a2e, 20), textcolor=color.new(C_BULL, 10), style=label.style_label_left, size=size.tiny)
    label.new(bar_index, tp2, "ᚢ TP2", color=color.new(#1a0a2e, 20), textcolor=color.new(C_BULL,  5), style=label.style_label_left, size=size.tiny)
    label.new(bar_index, tp3, "ᚦ TP3", color=color.new(#1a0a2e, 20), textcolor=color.new(C_BULL,  0), style=label.style_label_left, size=size.tiny)
if showTP and isShortEntry and not na(tp11)
    label.new(bar_index, tp11, "ᚠ TP1", color=color.new(#1a0a2e, 20), textcolor=color.new(C_BEAR, 10), style=label.style_label_left, size=size.tiny)
    label.new(bar_index, tp22, "ᚢ TP2", color=color.new(#1a0a2e, 20), textcolor=color.new(C_BEAR,  5), style=label.style_label_left, size=size.tiny)
    label.new(bar_index, tp33, "ᚦ TP3", color=color.new(#1a0a2e, 20), textcolor=color.new(C_BEAR,  0), style=label.style_label_left, size=size.tiny)

// 5. BEストップライン
bePricePlot = showBE and beActivated and strategy.position_size != 0 ? bePrice : na
plot(bePricePlot, "BE Fog",  color=color.new(C_BE_COL, 70), linewidth=6, style=plot.style_linebr)
plot(bePricePlot, "BE Mid",  color=color.new(C_BE_COL, 35), linewidth=2, style=plot.style_linebr)
plot(bePricePlot, "BE Core", color=color.new(C_BE_COL,  0), linewidth=1, style=plot.style_linebr)

beJustActivated = beActivated and not beActivated[1]
if showBE and beJustActivated and not na(bePrice)
    label.new(bar_index, bePrice, "ᚷ WEAVE",
         color=color.new(#1a0a2e, 10), textcolor=color.new(C_BE_COL, 5),
         style=label.style_label_right, size=size.small)

// 6. 上位足スイング（日足固定）
htfSwingHigh = request.security(syminfo.tickerid, "D", ta.pivothigh(high, swingLen, swingLen)[1], lookahead=barmerge.lookahead_off)
htfSwingLow  = request.security(syminfo.tickerid, "D", ta.pivotlow(low,  swingLen, swingLen)[1], lookahead=barmerge.lookahead_off)

var float lastHTFSwingHigh = na
var float lastHTFSwingLow  = na
lastHTFSwingHigh := na(htfSwingHigh) ? lastHTFSwingHigh : htfSwingHigh
lastHTFSwingLow  := na(htfSwingLow)  ? lastHTFSwingLow  : htfSwingLow

htfClose = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_off)

var int htfTrend = 0
if not na(lastHTFSwingHigh) and htfClose > lastHTFSwingHigh and htfTrend != 1
    htfTrend := 1
if not na(lastHTFSwingLow)  and htfClose < lastHTFSwingLow  and htfTrend != -1
    htfTrend := -1

plot(showHTF and htfTrend == -1 ? lastHTFSwingHigh : na, "HTF Res", color=color.new(C_HTF_BEAR, 45), linewidth=1, style=plot.style_linebr)
plot(showHTF and htfTrend ==  1 ? lastHTFSwingLow  : na, "HTF Sup", color=color.new(C_HTF_BULL, 45), linewidth=1, style=plot.style_linebr)

// 8. 背景色
bgcolor(showBG and not isTrending  ? color.new(C_FLAT_BG, 90) : na, title="横ばいゾーン / Flat Zone")
bgcolor(beActivated                ? color.new(C_BE_COL,  94) : na, title="BEストップ発動中 / BE Active")
bgcolor(fltEnabled and not fltPass ? color.new(#ff6b35,   93) : na, title="ファンダメンタルフィルターブロック中 / Flt Blocked")

// 9. トレードラベル
rangeR    = high - low
avgRangeR = ta.sma(rangeR, 20)
var float TruePnLToDisplay = PnL

if strategy.closedtrades > 0
    lastTradeIndex     = strategy.closedtrades - 1
    lastTradeEntryBar  = strategy.closedtrades.exit_bar_index(lastTradeIndex)
    lastTradeDirection = strategy.closedtrades.size(lastTradeIndex)

    if lastTradeEntryBar == bar_index
        uscitaFinale = strategy.position_size == 0. or
             lastTradeDirection > 0.0 and strategy.position_size < 0. or
             lastTradeDirection < 0.0 and strategy.position_size > 0.

        if uscitaFinale and showLabels
            isWin      = TruePnLToDisplay > 0
            labelTxtC  = isWin ? color.new(C_BULL, 5) : color.new(C_BEAR, 5)
            labelY     = isWin ? high + avgRangeR * 3.0 : low - avgRangeR * 3.0
            labelStyle = isWin ? label.style_label_down : label.style_label_up
            labelText  = (isWin ? "ᚢ +" : "ᚦ ") + str.tostring(math.round(TruePnLToDisplay, 1)) + "%"
            label.new(x=bar_index, y=labelY, text=labelText,
                 color=color.new(#1a0a2e, 5), textcolor=labelTxtC,
                 style=labelStyle, size=size.normal)
    else
        TruePnLToDisplay := TruePnL

// =====================================================================
// 10. ステータステーブル（11行に拡張）
// =====================================================================
tPos = tablePos == "Top Right / 右上"    ? position.top_right    :
       tablePos == "Top Left / 左上"     ? position.top_left     :
       tablePos == "Bottom Right / 右下" ? position.bottom_right :
                                           position.bottom_left

var table t = na
if showTable
    if na(t)
        t := table.new(tPos, 2, 11,
             bgcolor=color.new(#0d0520, 8), border_color=color.new(C_BE_COL, 60),
             border_width=1, frame_color=color.new(C_BE_COL, 40), frame_width=1)

    C_ON   = color.new(C_BULL,  5)
    C_OFF  = color.new(C_BEAR,  5)
    C_NEU  = color.new(#8892a4, 0)
    C_BG   = color.new(#0d0520, 20)
    C_HEAD = color.new(#1c0f3a, 10)

    // Row 0: ヘッダー
    table.cell(t, 0, 0, langJP ? "ᚾ 条件" : "ᚾ Condition",
         text_color=color.new(C_BE_COL, 10), text_size=size.small, bgcolor=C_HEAD, text_halign=text.align_center)
    table.cell(t, 1, 0, langJP ? "状態" : "Status",
         text_color=color.new(C_BE_COL, 10), text_size=size.small, bgcolor=C_HEAD, text_halign=text.align_center)

    // Row 1: EMA
    emaLenStr = str.tostring(emaLen)
    table.cell(t, 0, 1, "ᚢ EMA(" + emaLenStr + ")", text_color=C_NEU, text_size=size.small, bgcolor=C_BG)
    table.cell(t, 1, 1, emaUp ? (langJP ? "▲ 上昇" : "▲ Rising") : (langJP ? "▼ 下降" : "▼ Falling"),
         text_color=emaUp ? C_ON : C_OFF, text_size=size.small, bgcolor=C_BG, text_halign=text.align_center)

    // Row 2: ダウ理論
    table.cell(t, 0, 2, langJP ? "ᚦ ダウ理論" : "ᚦ Dow Theory", text_color=C_NEU, text_size=size.small, bgcolor=C_BG)
    table.cell(t, 1, 2,
         trend == 1 ? (langJP ? "▲ ブル" : "▲ Bull") : trend == -1 ? (langJP ? "▼ ベア" : "▼ Bear") : (langJP ? "─ 中立" : "─ Neutral"),
         text_color=trend == 1 ? C_ON : trend == -1 ? C_OFF : C_NEU,
         text_size=size.small, bgcolor=C_BG, text_halign=text.align_center)

    // Row 3: ADX
    adxVal   = str.tostring(math.round(adxValue,    1))
    adxThStr = str.tostring(math.round(adxThreshold, 1))
    table.cell(t, 0, 3,
         autoCalib ? "ᚠ ADX>" + adxThStr + "🔧" : "ᚠ ADX>" + adxThStr,
         text_color=C_NEU, text_size=size.small, bgcolor=C_BG)
    table.cell(t, 1, 3,
         isTrending
             ? "● " + adxVal + (langJP ? "  強" : "  Strong")
             : "○ " + adxVal + (langJP ? "  弱" : "  Weak"),
         text_color=isTrending ? C_ON : C_OFF, text_size=size.small, bgcolor=C_BG, text_halign=text.align_center)

    // Row 4: フットプリント・デルタ
    fltFpSymShort = fltFpSymChoice == "BTC / BTCUSD" ? "BTC" : "ETH"
    var string fltStatus = ""
    var color  fltColor  = color.gray
    if not fltEnabled
        fltStatus := langJP ? "─ 無効" : "─ Off"
        fltColor  := C_NEU
    else if na(fltFpDeltaSma)
        fltStatus := langJP ? "○ データ待ち" : "○ No Data"
        fltColor  := C_NEU
    else if fpBullish
        fltStatus := langJP ? "▲ 買い優勢 ✓" : "▲ Bull ✓"
        fltColor  := C_ON
    else if fpBearish
        fltStatus := langJP ? "▼ 売り優勢 ✓" : "▼ Bear ✓"
        fltColor  := C_OFF
    else
        fltStatus := langJP ? "─ 中立" : "─ Neutral"
        fltColor  := C_NEU

    fltBG = fltEnabled and (not fltPassLong and not fltPassShort) ? color.new(#ff6b35, 75) : C_BG
    table.cell(t, 0, 4, "ᚱ FP Δ " + fltFpSymShort, text_color=C_NEU, text_size=size.small, bgcolor=fltBG)
    table.cell(t, 1, 4, fltStatus, text_color=fltColor, text_size=size.small, bgcolor=fltBG, text_halign=text.align_center)

    // Row 5: 日足フィボゾーン ─ NEW ─
    var string dFiboStatus = ""
    var color  dFiboColor  = color.gray
    var color  dFiboBG     = C_BG
    if dTrend == 0
        dFiboStatus := langJP ? "─ 判定待ち" : "─ No Data"
        dFiboColor  := C_NEU
    else if dSameDir
        dFiboStatus := langJP ? "✓ 同方向" : "✓ Same Dir"
        dFiboColor  := C_ON
        dFiboBG     := C_BG
    else if dAntiLong and inFiboMidL
        dFiboStatus := langJP ? "✖ 踊り場(L)" : "✖ Mid Zone(L)"
        dFiboColor  := C_OFF
        dFiboBG     := color.new(#ff6b35, 75)
    else if dAntiShort and inFiboMidS
        dFiboStatus := langJP ? "✖ 踊り場(S)" : "✖ Mid Zone(S)"
        dFiboColor  := C_OFF
        dFiboBG     := color.new(#ff6b35, 75)
    else if dAntiShallowLong
        dFiboStatus := langJP ? "△ 浅い(L) TP調整" : "△ Shallow(L)"
        dFiboColor  := color.new(C_BE_COL, 0)
    else if dAntiShallowShort
        dFiboStatus := langJP ? "△ 浅い(S) TP調整" : "△ Shallow(S)"
        dFiboColor  := color.new(C_BE_COL, 0)
    else
        dFiboStatus := langJP ? "○ 深い 反転狙い" : "○ Deep"
        dFiboColor  := C_ON
    table.cell(t, 0, 5, langJP ? "ᚱ 日足フィボ" : "ᚱ D Fibo", text_color=C_NEU, text_size=size.small, bgcolor=dFiboBG)
    table.cell(t, 1, 5, dFiboStatus, text_color=dFiboColor, text_size=size.small, bgcolor=dFiboBG, text_halign=text.align_center)

    // Row 6: ポジション
    longOK  = emaUp   and trend == 1  and isTrending and fltPassLong  and dFiboAllowLong
    shortOK = emaDown and trend == -1 and isTrending and fltPassShort and dFiboAllowShort
    var string posStatus = ""
    var color  posColor  = color.gray
    var color  posBG     = color.gray
    if strategy.position_size > 0
        posStatus := langJP ? "▲ ロング中"   : "▲ Long"
        posColor  := C_ON
        posBG     := color.new(#e8eaf0, 82)
    else if strategy.position_size < 0
        posStatus := langJP ? "▼ ショート中" : "▼ Short"
        posColor  := C_OFF
        posBG     := color.new(#c0152a, 82)
    else if longOK
        posStatus := langJP ? "▲ ロング可"   : "▲ Long Ready"
        posColor  := C_ON
        posBG     := color.new(#e8eaf0, 90)
    else if shortOK
        posStatus := langJP ? "▼ ショート可" : "▼ Short Ready"
        posColor  := C_OFF
        posBG     := color.new(#c0152a, 90)
    else
        posStatus := langJP ? "─ 待機中" : "─ Waiting"
        posColor  := C_NEU
        posBG     := C_BG
    table.cell(t, 0, 6, langJP ? "ᚷ ポジション" : "ᚷ Position", text_color=C_NEU, text_size=size.small, bgcolor=posBG)
    table.cell(t, 1, 6, posStatus, text_color=posColor, text_size=size.small, bgcolor=posBG, text_halign=text.align_center)

    // Row 7: BEストップ
    var string beStatus      = ""
    var color  beStatusColor = color.gray
    if not beEnabled
        beStatus      := langJP ? "─ 無効"   : "─ Off"
        beStatusColor := C_NEU
    else if beActivated
        beStatus      := langJP ? "ᚷ 発動中" : "ᚷ Active"
        beStatusColor := color.new(C_BE_COL, 0)
    else
        beStatus      := langJP ? "○ 待機"   : "○ Standby"
        beStatusColor := C_NEU
    table.cell(t, 0, 7, langJP ? "ᚷ BEストップ" : "ᚷ BE Stop", text_color=C_NEU, text_size=size.small, bgcolor=C_BG)
    table.cell(t, 1, 7, beStatus, text_color=beStatusColor, text_size=size.small, bgcolor=C_BG, text_halign=text.align_center)

    // Row 8: フィルター詳細
    fltDetailStr = fltEnabled and not na(fltFpDeltaSma) ?
         "Δ " + str.tostring(math.round(fltFpDeltaSma, 0), format.volume) +
         (fpBullish ? " ▲" : fpBearish ? " ▼" : " ─") : "─"
    table.cell(t, 0, 8, langJP ? "  詳細" : "  Detail", text_color=C_NEU, text_size=size.tiny, bgcolor=C_BG)
    table.cell(t, 1, 8, fltDetailStr, text_color=C_NEU, text_size=size.tiny, bgcolor=C_BG, text_halign=text.align_center)

    // Row 9: オートキャリブレーション モード表示
    modeBG    = autoCalib ? color.new(#c9a84c, 82) : color.new(#2a2a3a, 50)
    modeColor = autoCalib ? color.new(C_BE_COL, 0) : C_NEU
    modeStr   = autoCalib
         ? (langJP ? "🔧 AUTO  FL:" + str.tostring(swingLen) + "×" + str.tostring(emaRatio) : "🔧 AUTO  FL:" + str.tostring(swingLen) + "×" + str.tostring(emaRatio))
         : (langJP ? "✎  MANUAL" : "✎  MANUAL")
    table.cell(t, 0, 9, langJP ? "⚙ モード" : "⚙ Mode", text_color=C_NEU, text_size=size.tiny, bgcolor=modeBG)
    table.cell(t, 1, 9, modeStr, text_color=modeColor, text_size=size.tiny, bgcolor=modeBG, text_halign=text.align_center)

    // Row 10: 現在の主要パラメータ値
    slStr    = str.tostring(math.round(stopLoss,  1))
    atrStr   = str.tostring(math.round(atrFactor, 2))
    beStr    = str.tostring(math.round(beThresh,  1))
    paramStr = "SL:" + slStr + "%  ATR×" + atrStr + "  BE:" + beStr + "%→建値"
    table.cell(t, 0, 10, langJP ? "  現在値" : "  Params", text_color=C_NEU, text_size=size.tiny, bgcolor=C_BG)
    table.cell(t, 1, 10, paramStr, text_color=C_NEU, text_size=size.tiny, bgcolor=C_BG, text_halign=text.align_center)
````

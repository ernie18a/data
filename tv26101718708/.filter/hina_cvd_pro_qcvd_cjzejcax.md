# HINA CVD Pro [Q.CVD]

- url: https://www.tradingview.com/script/cJzEJCaX/
- type: indicator
- pine_id: PUB;4a9965b9f8334b03a44cb81a7254611b
- version: 1.0

## Description

[b]Institutional CVD Pro [Q.CVD] 概要・利用マニュアル[/b]

概要 (Overview)
本インジケーターは、相場の背後にある「成行注文（攻め）」と「指値注文（守り）」の力関係を可視化する、機関投資家レベルのオーダーフロー分析ツールです。
一般的なオシレーターとは異なり、ローソク足の形状と出来高から「擬似CVD（累積デルタ）」を算出し、その統計的異常値（Zスコア）を検知。大口投資家が流動性を吸収した決定的な瞬間を、メインチャート上に直接オーバーレイ表示します。

参照ロジック (Reference Logic)
本ツールは以下の3つのクオンツ的アプローチによって構築されています。

True Range Proxy Delta: ティックデータに制限のある環境下でも、ローソク足のヒゲと実体の割合から、その足の「実質的な買い圧力・売り圧力（デルタ）」を高精度に推定します。

Effort vs Result (吸収の検知): 過去50期間の標準偏差（Zスコア2.0以上）を超える「特大の成行注文（Effort）」が発生したにも関わらず、価格が逆行して引けた（Result）場合、「大口の指値による吸収（Absorption）」と判定します。

Delta Exhaustion (枯渇の検知): トレンド発生後、超短期のデルタ移動平均線がゼロを割った瞬間を「成行注文の燃料切れ（Exhaustion）」と定義し、スマートな利確ポイントとして算出します。

サインの見方
チャートを汚さないよう、必要な瞬間のみ情報がポップアップする設計です。

ダークオレンジのローソク足: 大口の指値による「吸収」が発生した足です。相場の特異点を示します。

▲ Buy / ▼ Sell: 吸収が「確定」した直後に点灯するエントリーサインです。

点線 (防衛ライン): エントリーサイン点灯と同時に引かれるライン。大口が守った価格帯（安値/高値）を示します。

Exit [Buy] / Exit [Sell] (枯渇): エントリー後、相場を押し進めるエネルギー（デルタ）が尽きたことを示す利確サインです。

SL (Rupture): 防衛ラインが実体で破られたことを示す撤退（損切り）サインです。

使い方
待機: ダークオレンジの足と Buy / Sell サインの点灯を待ちます。

エントリー & リスク設定: サイン点灯でエントリーし、同時に表示される「点線（防衛ライン）」の少し外側に物理的なストップロス（損切り）を置きます。

エグジット: トレンドに乗り、Exit (枯渇) サインが出た足の確定で利確します。万が一逆行し、SL サインが出た場合は即座に撤退します。

実際の利用シーン3パターン
パターン1：トレンドの底打ち（パニック売りの吸収）
強烈な下落局面において、群衆のパニック売り（極端なマイナスデルタ）を大口が買い指値で全て受け止めた時、下ヒゲを伴うダークオレンジの足とともに Buy サインが点灯します。絶好の逆張りポイントです。

パターン2：ブレイクアウトの騙し（流動性の狩猟）
重要な高値を上にブレイクし、イナゴの飛び乗り買い（極端なプラスデルタ）が殺到した直後、価格が上ヒゲをつけて押し返された時に Sell サインが点灯します。大口が流動性を利用してショートを構築した「騙し」を狙い撃ちします。

パターン3：天井・底でのスマートな逃げ（Exhaustion）
Buy でエントリー後、順調に価格が上昇。まだチャート上は陽線が続いていても、内部の買いデルタが細ってきた瞬間に Exit [Buy] が点灯します。大衆が強気になっている裏で、反転下落する前に利益を確保して逃げ切ります。

気を付けるべきこと
本ツールのデルタは、取引所のフルティックデータではなく、TradingViewのローソク足と出来高に基づく「推定値」です。完璧なオーダーフローツールではなく、あくまで「統計的優位性を見つけるフィルター」として機能します。

「SL」を絶対に無視しないでください。 大口の指値の壁が食い破られた（Rupture）ということは、その方向にさらに強烈なトレンドが走る危険性があります。

向いている相場
出来高が豊富で流動性が高い市場: メジャー通貨ペア（EURUSD, USDJPYなど）、主要株価指数、ビットコイン、大型株など。大口の介入が統計として綺麗に表れます。

明確なレンジ相場や、上位足のサポレジ付近: 大口が防衛のための指値を置きやすいポイントで最大の威力を発揮します。

向かない相場
出来高が極端に少ない市場: マイナーアルトコインや小型草株。少額の成行注文で簡単にZスコアの異常値が出てしまうため、フェイクサインが増加します。

ボラティリティが死んでいる深夜・早朝の閑散相場: わずかなノイズにインジケーターが過剰反応する可能性があります（Zスコアの性質上の弱点）。

サインの期限について
本インジケーターの Buy / Sell サインは、「大口がその価格帯（防衛ライン）を守っている間」のみ有効です。
一度 Exit サインで利確された後、あるいは SL で撤退した後は、そのサインの効力は完全に消滅（消費）します。過去のサインの位置をいつまでもサポート/レジスタンスとして盲信せず、次の新たな「吸収」の発生を待ってください。

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// Q.CVD Pro v3 - Fixed Exhaustion Logic

//@version=5
indicator("Institutional CVD Pro [Q.CVD]", shorttitle="Q.CVD Pro", overlay=true, max_lines_count=100)

// ==========================================
// 1. Settings
// ==========================================
grp_calc    = "CVD Mechanics"
session_res = input.string("D", "Session Reset", group=grp_calc)
z_len       = input.int(50, "Z-Score Length", group=grp_calc)
z_thres     = input.float(2.0, "Anomaly Threshold (σ)", group=grp_calc)

// ==========================================
// 2. Colors
// ==========================================
c_red    = #971B2F
c_grn    = #004B23
c_gold   = #C5A059
c_absorb = #CC5500 // ダークオレンジ (吸収発生キャンドル)

// ==========================================
// 3. Core Engine (CVD & Z-Score)
// ==========================================
float tr = ta.tr == 0 ? 1 : ta.tr
float buy_eff  = volume * (close >= open ? (close - low) / tr : (high - open) / tr)
float sell_eff = volume * (close >= open ? (high - close) / tr : (close - low) / tr)
float delta = buy_eff - sell_eff

var float cvd = 0.0
if ta.change(time(session_res))
    cvd := delta
else
    cvd := nz(cvd[1]) + delta

float d_mean  = ta.sma(delta, z_len)
float d_std   = ta.stdev(delta, z_len)
float z_score = d_std == 0 ? 0 : (delta - d_mean) / d_std

// 吸収判定
float close_pos = high == low ? 0.5 : (close - low) / (high - low)
bool bull_abs = (z_score < -z_thres) and (close_pos > 0.70) 
bool bear_abs = (z_score > z_thres)  and (close_pos < 0.30) 

bool sig_buy  = bull_abs and barstate.isconfirmed
bool sig_sell = bear_abs and barstate.isconfirmed

// ==========================================
// 4. Entry Visuals 
// ==========================================
barcolor(sig_buy or sig_sell ? c_absorb : na, title="Absorption Candle")

plotshape(sig_buy ? low : na,  "Buy Signal",  style=shape.triangleup,   location=location.belowbar, color=color.new(c_grn, 0), text="Buy", textcolor=c_grn, size=size.tiny)
plotshape(sig_sell ? high : na, "Sell Signal", style=shape.triangledown, location=location.abovebar, color=color.new(c_red, 0), text="Sell", textcolor=c_red, size=size.tiny)

// ==========================================
// 5. Exit Logic (Fixed Exhaustion & Rupture)
// ==========================================
var float stop_lvl = na
var int active_side = 0 
var int entry_bar = 0 // エントリーしたバーのインデックスを記憶

if sig_buy
    active_side := 1
    stop_lvl := low 
    entry_bar := bar_index

if sig_sell
    active_side := -1
    stop_lvl := high 
    entry_bar := bar_index

// --- 撤退: 防衛ライン陥落 (Rupture) ---
bool rupture = false
if active_side == 1 and close < stop_lvl
    rupture := true
if active_side == -1 and close > stop_lvl
    rupture := true

if rupture
    label.new(bar_index, active_side == 1 ? low : high, "SL", color=color.new(color.gray, 50), textcolor=color.white, style=active_side == 1 ? label.style_label_up : label.style_label_down, size=size.small)
    active_side := 0
    stop_lvl := na

// --- 利確: デルタ枯渇 (Exhaustion) ---
// 修正点: エントリー後3本以上経過し、直近の純粋な買い/売りの勢い(3期間EMA)が逆転した時に決済
int bars_held = bar_index - entry_bar
float short_delta_ema = ta.ema(delta, 3)

bool cvd_exhausted = false
if active_side == 1 and bars_held > 2 and short_delta_ema < 0
    cvd_exhausted := true
if active_side == -1 and bars_held > 2 and short_delta_ema > 0
    cvd_exhausted := true

if active_side != 0 and cvd_exhausted and not rupture
    string exit_txt = active_side == 1 ? "Exit [Buy]\n(枯渇)" : "Exit [Sell]\n(枯渇)"
    color exit_col  = active_side == 1 ? color.new(c_grn, 10) : color.new(c_red, 10)
    label.new(bar_index, active_side == 1 ? high : low, exit_txt, color=exit_col, textcolor=color.white, style=active_side == 1 ? label.style_label_down : label.style_label_up, size=size.small)
    
    active_side := 0
    stop_lvl := na

// 防衛ライン(SL)の可視化
var line l_stop = na
line.delete(l_stop)
if not na(stop_lvl) and active_side != 0
    l_stop := line.new(bar_index - 1, stop_lvl, bar_index + 1, stop_lvl, color=color.new(c_absorb, 20), style=line.style_dotted, width=2)
````

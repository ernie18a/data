# Vegas Touch indicator

- url: https://www.tradingview.com/script/1ZbUQcbW/
- type: indicator
- pine_id: PUB;e2757410593c4cbda62b644a9e2317ee
- version: 1.0

## Description

本指標是基於經典的「維加斯通道 (Vegas Tunnel)」交易法深度開發而成。它專門設計用於捕捉價格在趨勢行情中，回踩 144/169 均線隧道後的高勝率反彈機會。我們在傳統邏輯的基礎上，加入了現代化的 K 棒型態過濾與動態警報系統，讓交易更直觀、更自動化。
1.雙重均線系統：自動繪製 144/169 (Tunnel) 與 576/676 (Base) 通道，清晰呈現市場的長短期結構與支撐壓力。
2.動態觸及判定：支援 ATR 或 百分比 模式，精準捕捉價格「接近」通道的瞬間，不再錯過任何關鍵回踩。
3..價格行為確認：內建 Pin Bar (收針) 與 Engulfing (吞沒) 過濾器，確保每一筆交易都有實際的價格支撐。
4.趨勢強力過濾：整合 EMA 12 與長短通道的相對位移判定，有效避開無趨勢的震盪行情與反轉死區。
5.智能風險管理：
支援 Swing (前高低點) 或 EMA 止損模式。
自動計算 1:2 RR (盈虧比) 的止盈價位並標註於警報中。
6.全方位警報通知：
內建動態 alert()：通知包含具體的 進場價、止損價、止盈價。
支援 alertcondition：方便在 TradingView UI 中快速建立靜態警報。
【如何使用】

綠色三角形 (VT Long)：看漲訊號，建議在收盤確認後進場。
紅色倒三角形 (VT Short)：看跌訊號。
建議時框：1H, 4H, Daily (Vegas 通道在較大時框表現最為穩定)。
🔵 英文描述 (English Description)
[Overview] The Vegas Touch indicator is a sophisticated trading tool based on the classic Vegas Tunnel methodology. It is specifically optimized to capture high-probability reversal opportunities when the price retraces to the 144/169 EMA Tunnel within a trending market.

[Key Features]

Dual Tunnel System: Automatically plots the 144/169 (Tunnel) and 576/676 (Base) channels to define the trend structure and institutional support/resistance.
Dynamic Touch Detection: Features adjustable ATR or Percentage thresholds to identify when the price enters the "Value Zone" near the tunnel.
Price Action Confirmation: Integrates Pin Bar and Engulfing pattern detection to ensure every signal is backed by localized market momentum.
Advanced Trend Filtering: Utilizes EMA 12 alignment and cross-tunnel positioning to filter out "fakeouts" and choppy sideways price action.
Built-in Risk Management:
Flexible SL modes: Choose between Swing High/Low or EMA-based stops.
Automatically targets a 1:2 Risk-Reward Ratio (RR).
Comprehensive Alert System:
Dynamic alert(): Pushes specific Entry, SL, and TP levels directly to your device.
alertcondition: Pre-configured for easy UI alert setup.
[Instructions]

Green Triangle (VT Long): Bullish setup confirmed near the tunnel.
Red Triangle (VT Short): Bearish setup confirmed near the tunnel.
Best Settings: Recommended for 1H, 4H, and Daily timeframes for maximum reliability.
[Disclaimer] Trading involves significant risk. This indicator is for educational and analytical purposes only. Past performance does not guarantee future results.

## Source Code

````pine
//@version=5
indicator("Vegas Touch — 1:2 RR (Indicator)",
     overlay=true, max_labels_count=500)

// ========================
// 基礎 EMA
// ========================
ema144 = ta.ema(close, 144)
ema169 = ta.ema(close, 169)
ema576 = ta.ema(close, 576)
ema676 = ta.ema(close, 676)
ema12  = ta.ema(close, 12)
ema200 = ta.ema(close, 200)

// Vegas 通道（短/長）
vt_tunnelUpper = math.max(ema144, ema169)
vt_tunnelLower = math.min(ema144, ema169)
vt_baseUpper   = math.max(ema576, ema676)
vt_baseLower   = math.min(ema576, ema676)

// ========================
// 進場邏輯參數（VT）
// ========================
group_vt = "Vegas Touch 進場 / 觸及閾值"
vt_distMode     = input.string("ATR", "觸及距離模式", options = ["ATR","Percent"], group = group_vt)
vt_atrLen       = input.int(14, "ATR 週期", minval = 1, group = group_vt)
vt_atrMult      = input.float(0.35, "ATR 倍數（距離閾值）", step = 0.05, group = group_vt)
vt_pctThresh    = input.float(0.20, "百分比閾值（%）", step = 0.05, group = group_vt)
vt_useCloseBar  = input.bool(true,  "僅收盤確認（避免重繪）", group = group_vt)
vt_cooldownBars = input.int(10, "冷卻根數（避免連發）", minval = 0, group = group_vt)
vt_emitAlert    = input.bool(true, "觸發時發送 alert()", group = group_vt)

// ========================
// VT 計算
// ========================
vt_atr = ta.atr(vt_atrLen)
vt_thr(ref) =>
    vt_distMode == "ATR" ? vt_atrMult * vt_atr : ref * (vt_pctThresh * 0.01)

vt_touch_lower(line) =>
    low <= line + vt_thr(line)
vt_touch_upper(line) =>
    high >= line - vt_thr(line)

vt_touchLower_tunnel = vt_touch_lower(vt_tunnelLower)
vt_touchUpper_tunnel = vt_touch_upper(vt_tunnelUpper)

// —— 鎖定（保持不變）
vt_longLock  = ema12 < ema676
vt_shortLock = ema12 > ema676

// —— 只使用「Tunnel」
vt_longUseTunnel   = not vt_longLock
vt_longTouchLower  = vt_longUseTunnel and vt_touchLower_tunnel
vt_shortUseTunnel  = not vt_shortLock
vt_shortTouchUpper = vt_shortUseTunnel and vt_touchUpper_tunnel

// 趨勢外側對齊（只檢查 Tunnel 版本）+ ema12 過濾
vt_longTrendOK_tunnel  = (ema144 > ema576) and (ema169 > ema676) and (close > vt_tunnelUpper)
vt_shortTrendOK_tunnel = (ema144 < ema576) and (ema169 < ema676) and (close < vt_tunnelLower)
vt_ema12AboveTunnel   = (ema12 > ema144) and (ema12 > ema169)
vt_ema12BelowTunnel   = (ema12 < ema144) and (ema12 < ema169)

vt_longTrendOK  = vt_longUseTunnel  and vt_longTrendOK_tunnel  and vt_ema12AboveTunnel
vt_shortTrendOK = vt_shortUseTunnel and vt_shortTrendOK_tunnel and vt_ema12BelowTunnel

// ========================
// K棒型態（可調）
// ========================
group_pat        = "K棒型態參數"
usePin           = input.bool(true,  "啟用 Pin（收針）", group=group_pat)
useEng           = input.bool(true,  "啟用 Engulf（吞沒）", group=group_pat)
pinWickRatio     = input.float(0.40, "收針比例（影線/全長）", step=0.05, minval=0.0, maxval=0.95, group=group_pat)
engBodyRatio     = input.float(0.60, "吞沒比例（本棒實體 ≥ 前一棒實體 × 倍數）", step=0.05, minval=0.1, maxval=3.0, group=group_pat)

vt_rng        = math.max(high - low, syminfo.mintick)
vt_body       = math.abs(close - open)
vt_upperWick  = high - math.max(open, close)
vt_lowerWick  = math.min(open, close) - low
vt_prevBody   = math.abs(close[1] - open[1])

// Pin（影線比例可調）
bullPin = (close > open) and (vt_lowerWick >= pinWickRatio * vt_rng)
bearPin = (close < open) and (vt_upperWick >= pinWickRatio * vt_rng)

// Engulf（實體倍率可調，且顏色相反）
bullEng = (close > open) and (close[1] < open[1]) and (vt_body >= engBodyRatio * vt_prevBody)
bearEng = (close < open) and (close[1] > open[1]) and (vt_body >= engBodyRatio * vt_prevBody)

// 依是否啟用彈性組合
vt_pinEng_long  = (usePin and bullPin) or (useEng and bullEng)
vt_pinEng_short = (usePin and bearPin) or (useEng and bearEng)

// 收盤確認 / 冷卻
vt_barOK = vt_useCloseBar ? barstate.isconfirmed : true
var vt_lastSigBar = -100000
vt_coolOK = (bar_index - vt_lastSigBar) > vt_cooldownBars

// 最終訊號
vt_longSetup_raw  = vt_barOK and not vt_longLock  and vt_longTrendOK  and vt_longTouchLower  and vt_pinEng_long
vt_shortSetup_raw = vt_barOK and not vt_shortLock and vt_shortTrendOK and vt_shortTouchUpper and vt_pinEng_short

vt_longSetup  = vt_longSetup_raw  and vt_coolOK
vt_shortSetup = vt_shortSetup_raw and vt_coolOK

if vt_longSetup or vt_shortSetup
    vt_lastSigBar := bar_index

// 視覺化
plot(vt_tunnelUpper, "Tunnel Upper(144/169)", color=color.new(color.teal, 0))
plot(vt_tunnelLower, "Tunnel Lower(144/169)", color=color.new(color.teal, 0))
plot(vt_baseUpper,   "Base Upper(576/676)",   color=color.new(color.purple, 70))
plot(vt_baseLower,   "Base Lower(576/676)",   color=color.new(color.purple, 70))
plotshape(vt_longSetup,  title="VT Long",  style=shape.triangleup,   location=location.belowbar, size=size.tiny, color=color.new(color.lime, 0),  text="VT Long")
plotshape(vt_shortSetup, title="VT Short", style=shape.triangledown, location=location.abovebar, size=size.tiny, color=color.new(color.red, 0),   text="VT Short")

// ========================
// 風控計算（供警報使用）
// ========================
group_risk  = "風控：SL/TP"
slMode      = input.string("Swing", "止損模式", options=["Swing","EMA"], group=group_risk)
slLookback  = input.int(15, "Swing SL 回看根數", minval=1, group=group_risk)
slEmaLen    = input.int(200, "EMA 止損長度", minval=5, group=group_risk)
slEma       = ta.ema(close, slEmaLen)
TP_R        = input.float(2.0, "TP 倍數 R", minval=0.5, step=0.5, group=group_risk)

getSL_long() =>
    slMode == "Swing" ? ta.lowest(low, slLookback) : slEma
getSL_short() =>
    slMode == "Swing" ? ta.highest(high, slLookback) : slEma

// 計算 SL/TP
var float longSL = na
var float longTP = na
var float shortSL = na
var float shortTP = na

if vt_longSetup
    longSL := getSL_long()
    longR  = close - longSL
    longTP := close + TP_R * longR

if vt_shortSetup
    shortSL := getSL_short()
    shortR  = shortSL - close
    shortTP := close - TP_R * shortR

// ========================
// 警報通知
// ========================
// 1. 動態警報 (alert())
if vt_emitAlert
    if vt_longSetup
        alert("VT LONG | Entry: " + str.tostring(close) + " | SL: " + str.tostring(longSL) + " | TP: " + str.tostring(longTP), alert.freq_once_per_bar_close)
    if vt_shortSetup
        alert("VT SHORT | Entry: " + str.tostring(close) + " | SL: " + str.tostring(shortSL) + " | TP: " + str.tostring(shortTP), alert.freq_once_per_bar_close)

// 2. 靜態警報條件 (alertcondition)
alertcondition(vt_longSetup,  "VT Long Setup",  "Vegas Touch LONG Signal Triggered!")
alertcondition(vt_shortSetup, "VT Short Setup", "Vegas Touch SHORT Signal Triggered!")
````

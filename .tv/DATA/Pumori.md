<!-- tradingview-pine-id: PUB;6d4006b89c2e4fbcb0551e6e00bfe691 -->
<!-- tradingviewscripts-format: 1 -->
# Pumori

Source: https://www.tradingview.com/script/yHpgAu7A-Carrier-Volatility-Pumori/

## Description

Carrier Volatility [Pumori]
This is the foundational Pulse component of the ET Massif Framework research suite.

Description
Pumori is a high-resolution volatility and impulse response tool built around an ultra-short fractional length (0.1 EMA). It is a high-frequency carrier framework that exposes the formation of volatility through controlled instability rather than smoothing. Unlike traditional indicators that smooth or lag volatility, Pumori captures high-frequency energy, allowing volatility to be observed in near real-time as it forms.
[image]https://www.tradingview.com/x/jt5IVNh7/ [/image]
Construct
At its core, Pumori uses:

[*]Dual 0.1-length EMA
A sub-unit length (N < 1) is intentionally used to produce an anti-smoothing response, where the recursive term overreacts to incoming data and amplifies micro-movements. The EMA is applied twice recursively, producing a controlled oscillatory response. This interaction forms the carrier layer, where continuous oscillation exposes high-frequency volatility directly.[image]https://www.tradingview.com/x/OOC7abkb/[/image]
[*]Flexible source input (RSI, RSI SMA, close, custom)
Three default source modes are available, allowing Pumori to operate across different domains. RSI is set as the default carrier as it represents normalized momentum in a bounded range, providing a stable domain for the transform. The chosen source defines how the carrier behaves and directly influences stability, noise profile, and interpretability. [image]https://www.tradingview.com/x/VlALnJsD/[/image]
[*]Volatility Envelope
The recursive overshoot–correction cycle forces continuous oscillation around the source, forming a dynamic envelope that expands and contracts with volatility. Pumori does not measure volatility, it reveals volatility formation.[image]https://www.tradingview.com/x/s7lfqGFx/    [/image]

Think of Pumori like an AM radio carrier wave. The point is not signal transmission — it is that the carrier must operate at a high enough frequency for changes to become visible immediately. Most traditional volatility measures operate over a fixed lookback window, which makes them inherently lagging. Pumori Instead, it allows volatility to express immediately. The 0.1 EMA acts as a high-frequency baseline upon which expansion and contraction are directly observed.[image]https://www.tradingview.com/x/8EtoJyCY/ [/image]
Modes

[*]Default 
RSI is the default baseline configuration. because it provides a bounded and naturally oscillatory structure (0–100), allowing the carrier to behave in a stable and interpretable manner. Unlike price, which can expand unpredictably, RSI compresses extremes and standardizes movement, making volatility expansion and contraction easier to observe. The result is a clean carrier waveform that offers the best balance between responsiveness and readability.[image]https://www.tradingview.com/x/FsWb1Zpj/[/image]
[*]Diagnostic
RSI (SMA) , the simple moving average of RSI is applied to the carrier transform. This reduces internal jitter while preserving underlying structure. It is used to assess movement quality, separating clean, controlled trends from noisy or chaotic trends.[image]https://www.tradingview.com/x/ZOPNsmFc/[/image]
[*]Price
Applying it on price produces a highly reactive output where volatility expansion and contraction are expressed in a zig-zag band around price. The oscillations reflect immediate changes in movement and make volatility clustering visible within trend.[image]https://www.tradingview.com/x/aWrH8V0J/ [/image]

How to Use

[*]Volatility Gauge
Band expansion indicates an active volatility state.
Band contraction indicates a suppressed environment
No volatility = no opportunity.[image]https://www.tradingview.com/x/RpodHSFC/   [/image]
[*]Market Progression
A low-volatility environment facilitates smooth, steady price progression. In contrast, high-volatility states produce a chaotic path characterized by erratic movement and uneven progression, signaling potential structural instability and reduced directional efficiency.[image]https://www.tradingview.com/x/M0iTqBvo/[/image]

Future Development 
Fractional EMA on price is further planned to be used as input component for adaptive filtering systems (e.g., Kalman filter integration). Specifically, the high-frequency oscillations of the volatility band provides a direct proxy for noise measurement, allowing dynamic adjustment of model responsiveness without introducing lag.

Default Settings
EMA Lengths: 0.1, 0.1
Default Mode: RSI (stable carrier behavior)
Diagnostic Mode: RSI SMA (reduced noise, structural clarity)
Price Mode: Close (Volatility clustering & envelop)
RSI Length: 14
RSI SMA Length: 14

日本語概要 (Japanese Summary)
Pumoriは、0.1という極短期間のEMA（指数平滑移動平均）を用いた高解像度なボラティリティ指標です。従来のATR（アベレージ・トゥルー・レンジ）のような遅行性の高い「平均型」ではなく、相場における瞬間的なボラティリティの拡張と収縮をリアルタイムに捉えることを目的としています。
主な特徴：

[*]高精度なバンド形成: 価格データまたはRSIをベースに、ジグザグ状のボラティリティバンドを形成します。
[*]ボラティリティの「発生」を直感的に把握: 従来の指標では見逃されがちな、微細な価格変化の初動（ボラティリティの発生）を直接観測可能です。
[*]市場の質を識別: 相場が「滑らかなトレンド」にあるのか、あるいは「ノイズの多い不安定な状態」にあるのか、その動きの質を瞬時に判別できます。

中文概要（Chinese Summary）
Pumori 是一個基於 0.1 極短期 EMA 的高解析度波動率工具，旨在即時捕捉市場波動的擴張與收縮。不同於傳統 ATR 等滯後性的「平均型」指標，Pumori 能在第一時間反應波動的動態變化。
核心特點：

[*]動態鋸齒型波動帶： 可靈活作用於價格、RSI 或平滑後的 RSI，形成緊隨走勢的動態帶狀區域。
[*]捕捉「波動生成」： 直接觀測波動的初動與爆發，而非事後進行數值平均
[*]高靈敏度動能偵測： 對市場動能變化極為敏感，能有效區分趨勢的平滑程度與市場雜訊（Noise）。
主要用途：
[*]市場環境判斷： 辨識當前是否具備交易條件（穩定趨勢 vs. 混亂無序）。
[*]波動品質分析： 評估市場走勢的品質，區分健康的波動與無效的雜訊。
[*]進階算法基礎： 作為未來卡爾曼濾波器（Kalman Filter）進行波動調節的核心基礎。
 Disclaimer:
This script is a research tool for market structure analysis and educational purposes only. It does not constitute financial advice. Trading involves risk.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © et20tradeview  
// Update 1.1

//@version=6
indicator("Pumori", overlay=false)

// User toggle
showOnPrice = input.bool(false, "Show on Main Chart?")
mode = input.string("Defaut (RSI)", "Input Mode", options=["Defaut (RSI)", "Diagnostic (RSI SMA)",  "Price", "Custom"])

// user input
source = input(close, title="Custom Mode")
factor = input.float(defval= 0.1 , minval=0.1, step=0.1)
factor2 = input.float(defval= 0.1 , minval=0.1, step=0.1)
rsiLengthInput = input.int(14, "RSI Length")
maLengthInput = input.int(14, "MA Length")

fillColor =#69359C

pine_ema(src, length) => 
    alpha = 2 / (length + 1)
    sum = src
    
    //The original code by Tradingview
    // sum = 0
    //sum := na(sum[1]) ? sma(src, length) : alpha * src + (1 - alpha) * nz(sum[1])
    
    sum := alpha * src + (1 - alpha) * nz(sum[1])



// Calculate RSI and MA of RSI 
rsi_input= ta.rsi(close, rsiLengthInput)
rsi_ma = ta.sma(rsi_input, maLengthInput)


//Select mode of input
float seriesP = switch mode
    "Defaut (RSI)"   => rsi_input
    "Diagnostic (RSI SMA)"   => rsi_ma
    "Price" => close
    => source



//Generate EMA
ln1 = pine_ema(seriesP, factor)
ln2 = pine_ema(ln1, factor2)

// 1. Plot in the SEPARATE PANE (hidden if showOnPrice is true)
p2 = plot(ln2, "EMA", color=color.purple, display = showOnPrice ? display.none : display.all)
p3 =  plot(ln2, "EMA offset" , offset=-1, color=color.purple,display = showOnPrice ? display.none : display.all)
pc = plot(seriesP,"source", color =color.new(color.rgb(255, 235, 59), 75), display = showOnPrice ? display.none : display.all )

// 2. Plot on the PRICE CHART (hidden if showOnPrice is false)
p4 = plot(ln2, "EMA", color=color.purple,force_overlay = true,  display = showOnPrice ? display.all : display.none)
p5 =  plot(ln2, "EMA offset" , offset=-1, color=color.purple, force_overlay = true, display = showOnPrice ? display.all : display.none)
ppc = plot(seriesP,"source", color =color.new(color.rgb(255, 235, 59), 75), force_overlay = true,display = showOnPrice ? display.all : display.none)


//fill(ln2, ln2, fillColor)
fill(p2, p3, color=color.new(#69359C, 70), title="Lag Shading", display = showOnPrice ? display.none : display.all)
fill(p4, p5, color=color.new(#69359C, 70), title="Lag Shading", display = showOnPrice ? display.all : display.none)
````

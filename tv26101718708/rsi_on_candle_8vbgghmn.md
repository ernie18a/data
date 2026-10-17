# RSI on Candle

- url: https://www.tradingview.com/script/8VbgGhMn/
- type: indicator
- pine_id: PUB;ceb7808d9a784f1ea8ebf1fea9040a06
- version: 1.0

## Description

[EN/JP]

Title: RSI on Candle — Dynamic RSI Bands with Divergence Detection

Description: RSI on Candle transforms the traditional RSI oscillator into dynamic price-level bands displayed directly on your chart. Instead of reading RSI values from a separate panel, you see three key RSI levels (30, 50, 70) projected onto price action as adaptive support/resistance zones.

Key Features:

Dynamic Price Projection: RSI levels are scaled into price-space using ATR volatility, creating bands that move naturally with the market
Trend Bias at a Glance: Price above RSI 50 = Bullish; Below = Bearish. The 50 line acts as a dynamic trend filter
Classic Extremes: RSI 30 (oversold/support) and RSI 70 (overbought/resistance) levels for mean-reversion and momentum entries
Automatic Divergence Detection: Visual alerts for Bullish (Price LL + RSI HL) and Bearish (Price HH + RSI LH) divergences with clear diamond markers
Smart Alerts: Built-in alerts for RSI 50 center line touches and divergence formations
Zero Clutter: Clean overlay design with transparent lines — no eye movement required between price and oscillator
How to Use:

Trend Following: Enter long when price holds above RSI 50; short when below
Mean Reversion: Look for bounces at RSI 30 (long) or rejections at RSI 70 (short)
Exit Signals: Divergence lines warn of potential trend exhaustion — consider taking profits when they appear
Settings: Adjustable RSI period, custom overbought/oversold levels, and divergence lookback sensitivity.

タイトル: RSI on Candle — ダイバージェンス検出付き動的RSIバンド

説明: RSI on Candle は、従来のRSIオシレーターを価格チャート上に直接投影するインジケーターです。別パネルで数値を確認する必要なく、RSI 30・50・70の3つの重要レベルが、価格に連動した動的なサポート/レジスタンスゾーンとして表示されます。

主な機能:

動的価格投影: ATRボラティリティを使用してRSI値を価格スケールに変換。市場の動きに自然に追随するバンドを形成
一目でわかるトレンド判断: RSI 50ライン上が強気、下が弱気。動的なトレンドフィルターとして機能
極値レベル: RSI 30（買われすぎ/サポート）とRSI 70（売られすぎ/レジスタンス）で、平均回帰・モメンタムエントリーを捕捉
自動ダイバージェンス検出: 価格とRSIの乖離を自動検出。強気ダイバ（価格安値更新+RSI上昇）と弱気ダイバ（価格高値更新+RSI下降）をダイヤマーカーで明確表示
スマートアラート: RSI 50センターラインタッチとダイバージェンス形成のアラートを標準搭載
ゼロ・クラッター: 透明ラインによるクリーンなオーバーレイ設計。価格とオシレーターを行き来する必要なし
使い方:

トレンドフォロー: RSI 50上での価格維持でロング、下でショート
平均回帰: RSI 30での反発（ロング候補）やRSI 70での拒否（ショート候補）を探す
利確シグナル: ダイバージェンスラインはトレンド疲労の警告。出現時は早期利確を検討
設定: RSI期間、買われすぎ/売られすぎレベル、ダイバージェンスのルックバック感度をカスタマイズ可能

## Source Code

````pine
//@version=6
indicator(
     title="RSI on Candle",
     shorttitle="RSI Candle",
     overlay=true,
     format=format.price,
     precision=2,
     max_lines_count=500,
     max_labels_count=500,
     max_bars_back=500
)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  USER INPUTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// --- RSI Parameters ---
len       = input.int(14,  "RSI Period",     group="RSI Settings",     minval=1)
rsiOS     = input.float(30.0, "RSI Oversold Level",  group="RSI Settings")
rsiCenter = input.float(50.0, "RSI Center Level",    group="RSI Settings")
rsiOB     = input.float(70.0, "RSI Overbought Level", group="RSI Settings")

// --- Divergence Detection ---
lbL          = input.int(5,  "Pivot Lookback Left",  group="Divergence", minval=1)
lbR          = input.int(5,  "Pivot Lookback Right", group="Divergence", minval=1)
maxLookback  = input.int(30, "Max Divergence Bars",  group="Divergence", minval=1)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  RSI CALCULATION & PRICE PROJECTION
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Calculate RSI using the standard Wilder's smoothing method
rsi = ta.rsi(close, len)

// Scale the RSI value into price-space using ATR as a volatility reference.
// Each RSI "point" is worth (ATR / 10) in price, so the three classic RSI
// levels appear as dynamic bands that move with price and volatility.
atr          = ta.atr(14)
pricePerRsi  = atr / 10

priceRsi30 = close + (rsiOS     - rsi) * pricePerRsi  // Oversold line
priceRsi50 = close + (rsiCenter - rsi) * pricePerRsi  // Center line
priceRsi70 = close + (rsiOB     - rsi) * pricePerRsi  // Overbought line

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  PLOT RSI LEVELS (Standard Colors)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(priceRsi30, "RSI 30 (Oversold)", color=color.new(color.gray, 50), linewidth=1)
plot(priceRsi50, "RSI 50 (Center)",   color=color.new(color.blue,  30), linewidth=2)
plot(priceRsi70, "RSI 70 (Overbought)", color=color.new(color.gray,   50), linewidth=1)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ALERTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// --- RSI50 Center Line Touch ---
touchRsi50 = low <= priceRsi50 and high >= priceRsi50

alertcondition(touchRsi50, title="🔄 RSI50 Center Line Touch", 
     message="RSI50 Center Line touched on {{ticker}} [{{timeframe}}]")

// --- Divergence Alerts ---
alertcondition(false, title="📗 Bullish Divergence", 
     message="Bullish Divergence detected on {{ticker}} [{{timeframe}}]")
alertcondition(false, title="📕 Bearish Divergence", 
     message="Bearish Divergence detected on {{ticker}} [{{timeframe}}]")

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  DIVERGENCE DETECTION ENGINE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Detect swing lows/highs for divergence pivots
swingLow  = ta.pivotlow(low, lbL, lbR)
swingHigh = ta.pivothigh(high, lbL, lbR)

// ─── Bullish Divergence (Price LL, RSI HL) ───
var float lastBullPrice = na
var float lastBullRsi   = na
var int   lastBullBar   = na

if not na(swingLow)
    currentPrice = low[lbR]
    currentRsi   = rsi[lbR]
    currentBar   = bar_index[lbR]
    
    if not na(lastBullPrice)
        priceLL = currentPrice < lastBullPrice
        rsiHL   = currentRsi > lastBullRsi
        barsDiff = currentBar - lastBullBar
        
        if priceLL and rsiHL and barsDiff <= maxLookback
            line.new(x1=lastBullBar, y1=lastBullPrice, x2=currentBar, y2=currentPrice, 
                 color=color.green, width=2, style=line.style_dashed)
            label.new(currentBar, currentPrice, "◆", 
                 color=color.new(color.green, 100), textcolor=color.green, 
                 style=label.style_label_up, size=size.normal, yloc=yloc.belowbar)
            alert("📗 Bullish Divergence on " + syminfo.ticker + " [" + timeframe.period + "]", alert.freq_once_per_bar_close)
    
    lastBullPrice := currentPrice
    lastBullRsi   := currentRsi
    lastBullBar   := currentBar

// ─── Bearish Divergence (Price HH, RSI LH) ───
var float lastBearPrice = na
var float lastBearRsi   = na
var int   lastBearBar   = na

if not na(swingHigh)
    currentPrice = high[lbR]
    currentRsi   = rsi[lbR]
    currentBar   = bar_index[lbR]
    
    if not na(lastBearPrice)
        priceHH = currentPrice > lastBearPrice
        rsiLH   = currentRsi < lastBearRsi
        barsDiff = currentBar - lastBearBar
        
        if priceHH and rsiLH and barsDiff <= maxLookback
            line.new(x1=lastBearBar, y1=lastBearPrice, x2=currentBar, y2=currentPrice, 
                 color=color.red, width=2, style=line.style_dashed)
            label.new(currentBar, currentPrice, "◆", 
                 color=color.new(color.red, 100), textcolor=color.red, 
                 style=label.style_label_down, size=size.normal, yloc=yloc.abovebar)
            alert("📕 Bearish Divergence on " + syminfo.ticker + " [" + timeframe.period + "]", alert.freq_once_per_bar_close)
    
    lastBearPrice := currentPrice
    lastBearRsi   := currentRsi
    lastBearBar   := currentBar

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  TABLE INFO (Top-Right Corner)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if barstate.islast
    var tbl = table.new(position.top_right, 2, 2, bgcolor=color.new(color.black, 80), 
         frame_color=color.gray, frame_width=1)
    
    table.cell(tbl, 0, 0, "RSI", text_color=color.gray, text_size=size.normal)
    table.cell(tbl, 1, 0, str.tostring(rsi, "#.#"), text_color=color.white, text_size=size.normal)
    
    table.cell(tbl, 0, 1, "Status", text_color=color.gray, text_size=size.normal)
    status = rsi > rsiOB ? "Overbought" : rsi < rsiOS ? "Oversold" : "Neutral"
    statusColor = rsi > rsiOB ? color.red : rsi < rsiOS ? color.green : color.gray
    table.cell(tbl, 1, 1, status, text_color=statusColor, text_size=size.normal)
````

# CDC Action Zone+TrueMarket Mean (BTC Focus) By Beckte

- url: https://www.tradingview.com/script/zKDzuRlm/
- type: indicator
- pine_id: PUB;442d9a5c6b4c444eae4b5a2e1129a863
- version: 1.0

## Description

## Overview
This indicator is a macro-focused trend following and cyclical value tracking tool, specifically designed for Bitcoin (BTC) long-term investors. It combines the momentum logic of the well-known **CDC Action Zone** with a mathematical simulation of the On-Chain **Realized Price** model. 

The main purpose of this script is to identify high-probability, macro-generational accumulation zones while filtering out early or false bottom signals during aggressive downtrends.

---

## Key Components

### 1. CDC Action Zone (Trend & Momentum)
Based on the classic EMA 12 and EMA 26 crossover logic, this component colors the candlesticks to reflect the market's current momentum:
- 🟢 **Bright Green:** Strong Bullish Momentum (Hold / Trend is up)
- 🔵 **Blue:** Early Bullish Sign / Potential Reversal (Watch closely or start accumulation)
- 🔴 **Bright Red:** Strong Bearish Momentum (Stay in cash / Wait)
- 🟠 **Orange:** Early Bearish Sign / Technical Rebound in Bear Market

### 2. Realized Price Proxy (The Cyclical Floor)
In on-chain analysis, the **Realized Price** represents the average cost basis of all aggregate Bitcoin supply moving on-network, without omitting lost or dormant coins. 
Since native on-chain data requires external API subscriptions on TradingView, this script utilizes a specialized long-term statistical proxy (**730-day SMA with custom logarithmic offsets**) to simulate this ultimate cyclical floor. Historically, major bear market bottoms (2015, 2018, 2022) have strictly formed near or slightly below this baseline.

---

## How it Works & Entry Strategy (The Anti-Doi Mechanism)
To avoid catching falling knives during a capitulation event, this script enforces a strict double-confirmation rule:

1. **Value Zone Check:** The current market price must correct down to within **10% of the Realized Price Proxy** (the light blue line). This ensures you are buying Bitcoin at an extreme discount relative to historical network value.
2. **Momentum Trigger:** Once inside the Value Zone, the script waits for the **CDC Action Zone to flip from Red/Orange to Blue or Green**. 

When both conditions are met, a **"REALIZED BUY"** label will plot beneath the candlestick, signaling a safe, low-risk entry spot with a highly compressed downside.

---

## Disclaimer & Credits
- **Credits:** The trend-following logic is inspired by the legendary "CDC Action Zone" concept popularized by Piriya Sambandaraksa. The valuation floor is based on the Realized Price on-chain metric conceptualized by the crypto-asset research community.
- **Disclaimer:** This indicator is designed for high-timeframe spot accumulation (recommended: 1D or 4H charts). It is not a financial advisory tool or a guarantee of future profits. Past performance does not indicate future results. Always practice proper risk management.

## Source Code

````pine
//@version=5
indicator("CDC Action Zone+TrueMarket Mean (BTC Focus) By Beckte", overlay=true)

// ==========================================
// 1. CDC ACTION ZONE CODE (EMA 12, 26)
// ==========================================
ema_fast_len = input.int(12, title="CDC Fast EMA Length")
ema_slow_len = input.int(26, title="CDC Slow EMA Length")

ema_fast = ta.ema(close, ema_fast_len)
ema_slow = ta.ema(close, ema_slow_len)

// กำหนดเงื่อนไขสีตามแบบฉบับ CDC Action Zone
is_bullish = ema_fast > ema_slow
is_bearish = ema_fast < ema_slow

// นิยามสีแท่งเทียน
var color bull_green  = color.rgb(0, 230, 118)
var color bull_blue   = color.rgb(41, 121, 255)
var color bear_red    = color.rgb(255, 23, 68)
var color bear_orange = color.rgb(255, 145, 0)

candle_color = is_bullish ? (close > ema_fast ? bull_green : bull_blue) : (close < ema_fast ? bear_red : bear_orange)
barcolor(candle_color)

// พล็อตเส้น EMA ของ CDC
plot(ema_fast, title="CDC Fast Line (12)", color=color.green, linewidth=1)
plot(ema_slow, title="CDC Slow Line (26)", color=color.red, linewidth=1)

// ==========================================
// 2. TRUE MARKET MEAN SIMULATOR (Macro On-Chain Proxy)
// ==========================================
// ใช้หลักการ VWAP ระยะยาวร่วมกับเส้นดัดแปลงทางสถิติ เพื่อเลียนแบบดุลยภาพต้นทุนสะสมของ BTC
tmm_length = input.int(365, title="True Market Mean Proxy Length (Days)")
tmm_base = ta.sma(close, tmm_length)
// ใส่ค่าเฉลี่ยชดเชยเพื่อเลียนแบบ Active Supply Cost Basis ของ Glassnode
true_market_mean = tmm_base * 0.96 

plot(true_market_mean, title="True Market Mean (Proxy)", color=color.rgb(255, 235, 59), linewidth=2, style=plot.style_line)

// ==========================================
// 3. ENTRY SIGNAL (ANTI-DOI)
// ==========================================
// สัญญาณซื้อ: ราคาอยู่ใกล้เส้น True Market Mean (หรือต่ำกว่า) และ CDC เปลี่ยนจากโซนแดง/ส้ม เป็นน้ำเงินหรือเขียว
in_value_zone = close <= (true_market_mean * 1.15) // อยู่ในขอบเขต 15% จากเส้น Mean
cdc_turn_buy  = (is_bullish and not is_bullish[1]) or (candle_color == bull_blue and candle_color[1] == bear_red)

buy_trigger = in_value_zone and cdc_turn_buy

plotshape(buy_trigger, title="Buy Signal", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.normal, text="BTC BUY")
````

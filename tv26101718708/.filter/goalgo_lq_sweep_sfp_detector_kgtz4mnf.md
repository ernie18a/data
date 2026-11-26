# GoAlgo - LQ Sweep & SFP Detector

- url: https://www.tradingview.com/script/kgTZ4mNf-GoAlgo-LQ-Sweep-SFP-Detector/
- type: indicator
- pine_id: PUB;19ee0667c2d04cac9aa3a3f1d6ed5f99
- version: 1.0

## Description

GoAlgo - LQ Sweep & SFP Detector
A professional liquidity detection tool based on Swing Failure Pattern (SFP) logic to identify key liquidity sweep points, which are often critical reversal levels in the market.

Key Features:
Liquidity Detection: Automatically identifies when price sweeps previous lows/highs (low < low[1] or high > high[1]) and closes back within the previous range.

Volume Spike Filter: Increases signal reliability by filtering with a 1.5x Volume Multiplier (based on a 20-period SMA), confirming significant market participation at the sweep point.

Visual Interface: Clearly plots "LQ" signals on the chart with green triangles for Buy Zones and red triangles for Sell Zones.

Alert System:
Optimized for professional trading with automated alerts via TradingView:

Low LQ Sweep: Triggers on bullish reversal conditions (Buy Zone).

High LQ Sweep: Triggers on bearish reversal conditions (Sell Zone).

Bar-Close Logic: Configured with alert.freq_once_per_bar_close to ensure clean, singular alerts at the end of every candle closure.

Target Audience:
Ideal for Smart Money Concept (SMC) traders, reversal traders, or those looking to identify high-probability liquidity zones to optimize their entry points.

## Source Code

````pine
//@version=6
indicator("GoAlgo - LQ Sweep & SFP Detector", overlay=true)

// --- Logic การตรวจจับ ---
bullish_sfp = low < low[1] and close > low[1]
bearish_sfp = high > high[1] and close < high[1]

// --- ปรับค่า Volume Spike เป็น 1.2 ---
vol_ma = ta.sma(volume, 20)
is_vol_spike = volume > (vol_ma * 1.5) 

// --- สร้างเงื่อนไขรวม ---
bullish_alert = bullish_sfp and is_vol_spike
bearish_alert = bearish_sfp and is_vol_spike

// --- การแสดงผลบนกราฟ ---
plotshape(bullish_alert, title="Bullish LQ Sweep", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.tiny, text="LQ")
plotshape(bearish_alert, title="Bearish LQ Sweep", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.tiny, text="LQ")

// --- ระบบ Alert แบบรวมศูนย์ ---

if bullish_alert
    alert("Low LQ Sweep ", alert.freq_once_per_bar_close)

if bearish_alert
    alert("High LQ Sweep ", alert.freq_once_per_bar_close)
````

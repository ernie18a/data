# Tin Nguyen RSI

- url: https://www.tradingview.com/script/0mJa9d3q-Tin-Nguyen-RSI/
- type: indicator
- pine_id: PUB;d710d5a3090a48d0a0fbe53f6aa246cf
- version: 1.0

## Description

This custom indicator is built on the Relative Strength Index (RSI) combined with two moving averages—WMA 9 and EMA 45—to track market momentum and trend direction. It is designed to provide high-clarity insights into price character shifts, specifically identifying extreme overbought/oversold conditions and potential reversal points.

⚙️ Core Components
RSI 14 (Purple Line): The primary momentum oscillator and backbone of the system.

WMA 9 (Green Line): A Weighted Moving Average that smooths the RSI, providing fast-acting signals for short-term shifts.

EMA 45 (Blue Line): An Exponential Moving Average acting as the medium-term "trend axis" for the RSI.

Visual Zones:

Blue shaded ribbons at 60-80 and 20-40 help track the migration of buying and selling pressure.

Background Highlights: Green or Orange backgrounds trigger automatically when RSI hits extreme levels (80 or 20).

🚦 Trading Rules & Discipline
The indicator integrates strict risk management protocols based on systematic trading logic:

Strict No-Trade Zone: When the RSI hits 20 or 80, the background changes color. Discipline: No new entries are permitted at these levels to avoid being trapped in high-volatility "climax" moves or trend exhaustion.

Trend Confirmation:

Bullish: RSI stays above EMA 45, and WMA 9 crosses above EMA 45.

Bearish: RSI stays below EMA 45, and WMA 9 crosses below EMA 45.

Built-in Alerts: Includes automated notifications for RSI crossing 70, dropping below 30, or hitting the 20/80 extremes to ensure timely decision-making.

💻 Application
Timeframes: Optimized for multi-timeframe analysis (Highly effective on M5, H1, and D1).

Markets: Best suited for Bitcoin, Gold, and major Forex pairs.

Note: This tool is for technical analysis support. Always combine with proper capital management and overall market context before executing trades.

## Source Code

````pine
//@version=5
indicator("Tin Nguyen", overlay=false)

// ==========================================
// --- STYLE BẢN GỐC CỦA BẠN (GIỮ NGUYÊN) ---
// ==========================================

// --- Thông số đầu vào ---
rsiLength  = input.int(14, title="RSI Length (Tím)")
wmaLength  = input.int(9,  title="WMA Length (Xanh lá)")
emaLength  = input.int(45, title="EMA Length (Xanh dương)")

// --- Tính toán ---
rsiValue = ta.rsi(close, rsiLength)
wmaValue = ta.wma(rsiValue, wmaLength)
emaValue = ta.ema(rsiValue, emaLength)

// --- Vẽ các đường chỉ báo ---
plot(emaValue, "EMA 45", color=#2196f3, linewidth=1) // Xanh dương
plot(wmaValue, "WMA 9", color=#2e7d32, linewidth=1)  // Xanh lá
plot(rsiValue, "RSI", color=#7b1fa2, linewidth=1)    // Tím

// --- Cấu trúc dải mờ nền ngang ---
h_80 = hline(80, "80", color=color.new(color.gray, 90), linestyle=hline.style_solid)
h_60 = hline(60, "60", color=color.new(color.gray, 90), linestyle=hline.style_solid)
h_40 = hline(40, "40", color=color.new(color.gray, 90), linestyle=hline.style_solid)
h_20 = hline(20, "20", color=color.new(color.gray, 90), linestyle=hline.style_solid)

fill(h_80, h_60, color=color.new(#4b3ad8, 85), title="Top Zone")
fill(h_40, h_20, color=color.new(#4b3ad8, 85), title="Bottom Zone")

hline(70, "Ngưỡng 70", color=color.new(color.white, 30), linestyle=hline.style_solid, linewidth=1)
hline(30, "Ngưỡng 30", color=color.new(color.white, 30), linestyle=hline.style_solid, linewidth=1)

// --- Đánh dấu vùng dọc ---
bgcolor(rsiValue >= 80 ? color.new(color.green, 50) : na)
bgcolor(rsiValue <= 20 ? color.new(color.orange, 50) : na)

// --- LOGIC ALERT GỘP (GIỮ NGUYÊN) ---
if rsiValue >= 80
    alert("QUÁN TÍNH TĂNG | RSI: " + str.tostring(math.round(rsiValue, 2)) + " (M5)", alert.freq_once_per_bar)

if rsiValue <= 20
    alert("QUÁN TÍNH GIẢM | RSI: " + str.tostring(math.round(rsiValue, 2)) + " (M5)", alert.freq_once_per_bar)

bool rsiCrossUp70   = ta.crossover(rsiValue, 70)
bool rsiCrossDown30 = ta.crossunder(rsiValue, 30)

if rsiCrossUp70
    alert("RSI Vượt 70 | RSI: " + str.tostring(math.round(rsiValue, 2)) + " (M5)", alert.freq_once_per_bar)

if rsiCrossDown30
    alert("RSI Thủng 30 | RSI: " + str.tostring(math.round(rsiValue, 2)) + " (M5)", alert.freq_once_per_bar)
````

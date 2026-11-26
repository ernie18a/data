# Roy Futuristic Moving Average AI Matrix Trend Lite

- url: https://www.tradingview.com/script/DiRiths7-Roy-Futuristic-Moving-Average-AI-Matrix-Trend-Lite/
- type: indicator
- pine_id: PUB;7bc20c08201f4e698657caf7ce33e3ff
- version: 1.0

## Description

ROY FUTURISTIC AI MATRIX TREND LITE is a multi-timeframe EMA trend scanner designed for traders who want a cleaner, faster, and mobile-friendly market trend analysis system.

This indicator combines multiple EMA trend confirmations across several timeframes into a futuristic matrix dashboard that allows traders to instantly identify bullish and bearish market alignment with a single glance.

The system analyzes whether price is trading above or below important EMA levels across multiple timeframes including:

• M1
• M5
• M15
• M30
• H1
• H4
• Daily
• Weekly

Each colored matrix cell represents the current market condition:

🟢 Green = Bullish
🔴 Red = Bearish

The indicator is specially optimized for TradingView mobile users with a compact futuristic heatmap layout that minimizes chart clutter while maximizing trend visibility.

FEATURES

• Multi-Timeframe EMA Matrix Scanner
• EMA 10 / 20 / 50 / 100 / 200 Analysis
• Instant Bullish & Bearish Detection
• Mobile-Friendly Dashboard
• Lightweight & Fast Performance
• Futuristic AI Heatmap Design
• Clean Trading Interface
• Higher Timeframe Trend Confirmation
• Scalping & Swing Trading Compatible

HOW TO USE

• More green cells = stronger bullish trend
• More red cells = stronger bearish trend
• Higher timeframe alignment gives stronger trend confirmation
• Use lower timeframe signals together with higher timeframe direction for better trade accuracy

This indicator is suitable for:

• Forex
• Gold (XAUUSD)
• Crypto
• Indices
• Stocks

Best used together with:
• Price Action
• Support & Resistance
• Market Structure
• Smart Money Concept (SMC)
• Volume Analysis

Designed for traders who prefer a clean, futuristic, and professional-style trading dashboard.

## Source Code

````pine
//@version=6
indicator("Roy Futuristic AI Matrix Trend Lite", overlay=true)

// ================= INPUT =================
showMatrix = input.bool(true, "Show Matrix")
showEMA50  = input.bool(true, "Show EMA 50")

// ================= EMA LINE =================
ema50 = ta.ema(close, 50)
plot(showEMA50 ? ema50 : na, "EMA 50", color=color.aqua, linewidth=2)

// ================= FUNCTION =================
fTrend(tf, len) =>
    request.security(syminfo.tickerid, tf, close > ta.ema(close, len) ? 1 : -1)

fColor(v) =>
    v == 1 ? color.new(color.lime, 0) : color.new(color.red, 0)

// ================= TABLE =================
var table t = table.new(position.bottom_right, 6, 10, border_width=1)

if barstate.islast and showMatrix
    table.cell(t, 0, 0, "TF",  bgcolor=color.black, text_color=color.aqua, text_size=size.tiny)
    table.cell(t, 1, 0, "10",  bgcolor=color.black, text_color=color.aqua, text_size=size.tiny)
    table.cell(t, 2, 0, "20",  bgcolor=color.black, text_color=color.aqua, text_size=size.tiny)
    table.cell(t, 3, 0, "50",  bgcolor=color.black, text_color=color.aqua, text_size=size.tiny)
    table.cell(t, 4, 0, "100", bgcolor=color.black, text_color=color.aqua, text_size=size.tiny)
    table.cell(t, 5, 0, "200", bgcolor=color.black, text_color=color.aqua, text_size=size.tiny)

    // M1
    m1_10=fTrend("1",10), m1_20=fTrend("1",20), m1_50=fTrend("1",50), m1_100=fTrend("1",100), m1_200=fTrend("1",200)
    table.cell(t,0,1,"M1",bgcolor=color.black,text_color=color.white,text_size=size.tiny)
    table.cell(t,1,1,"●",bgcolor=fColor(m1_10),text_size=size.tiny)
    table.cell(t,2,1,"●",bgcolor=fColor(m1_20),text_size=size.tiny)
    table.cell(t,3,1,"●",bgcolor=fColor(m1_50),text_size=size.tiny)
    table.cell(t,4,1,"●",bgcolor=fColor(m1_100),text_size=size.tiny)
    table.cell(t,5,1,"●",bgcolor=fColor(m1_200),text_size=size.tiny)

    // M5
    m5_10=fTrend("5",10), m5_20=fTrend("5",20), m5_50=fTrend("5",50), m5_100=fTrend("5",100), m5_200=fTrend("5",200)
    table.cell(t,0,2,"M5",bgcolor=color.black,text_color=color.white,text_size=size.tiny)
    table.cell(t,1,2,"●",bgcolor=fColor(m5_10),text_size=size.tiny)
    table.cell(t,2,2,"●",bgcolor=fColor(m5_20),text_size=size.tiny)
    table.cell(t,3,2,"●",bgcolor=fColor(m5_50),text_size=size.tiny)
    table.cell(t,4,2,"●",bgcolor=fColor(m5_100),text_size=size.tiny)
    table.cell(t,5,2,"●",bgcolor=fColor(m5_200),text_size=size.tiny)

    // M15
    m15_10=fTrend("15",10), m15_20=fTrend("15",20), m15_50=fTrend("15",50), m15_100=fTrend("15",100), m15_200=fTrend("15",200)
    table.cell(t,0,3,"M15",bgcolor=color.black,text_color=color.white,text_size=size.tiny)
    table.cell(t,1,3,"●",bgcolor=fColor(m15_10),text_size=size.tiny)
    table.cell(t,2,3,"●",bgcolor=fColor(m15_20),text_size=size.tiny)
    table.cell(t,3,3,"●",bgcolor=fColor(m15_50),text_size=size.tiny)
    table.cell(t,4,3,"●",bgcolor=fColor(m15_100),text_size=size.tiny)
    table.cell(t,5,3,"●",bgcolor=fColor(m15_200),text_size=size.tiny)

    // M30
    m30_10=fTrend("30",10), m30_20=fTrend("30",20), m30_50=fTrend("30",50), m30_100=fTrend("30",100), m30_200=fTrend("30",200)
    table.cell(t,0,4,"M30",bgcolor=color.black,text_color=color.white,text_size=size.tiny)
    table.cell(t,1,4,"●",bgcolor=fColor(m30_10),text_size=size.tiny)
    table.cell(t,2,4,"●",bgcolor=fColor(m30_20),text_size=size.tiny)
    table.cell(t,3,4,"●",bgcolor=fColor(m30_50),text_size=size.tiny)
    table.cell(t,4,4,"●",bgcolor=fColor(m30_100),text_size=size.tiny)
    table.cell(t,5,4,"●",bgcolor=fColor(m30_200),text_size=size.tiny)

    // H1
    h1_10=fTrend("60",10), h1_20=fTrend("60",20), h1_50=fTrend("60",50), h1_100=fTrend("60",100), h1_200=fTrend("60",200)
    table.cell(t,0,5,"H1",bgcolor=color.black,text_color=color.white,text_size=size.tiny)
    table.cell(t,1,5,"●",bgcolor=fColor(h1_10),text_size=size.tiny)
    table.cell(t,2,5,"●",bgcolor=fColor(h1_20),text_size=size.tiny)
    table.cell(t,3,5,"●",bgcolor=fColor(h1_50),text_size=size.tiny)
    table.cell(t,4,5,"●",bgcolor=fColor(h1_100),text_size=size.tiny)
    table.cell(t,5,5,"●",bgcolor=fColor(h1_200),text_size=size.tiny)

    // H4
    h4_10=fTrend("240",10), h4_20=fTrend("240",20), h4_50=fTrend("240",50), h4_100=fTrend("240",100), h4_200=fTrend("240",200)
    table.cell(t,0,6,"H4",bgcolor=color.black,text_color=color.white,text_size=size.tiny)
    table.cell(t,1,6,"●",bgcolor=fColor(h4_10),text_size=size.tiny)
    table.cell(t,2,6,"●",bgcolor=fColor(h4_20),text_size=size.tiny)
    table.cell(t,3,6,"●",bgcolor=fColor(h4_50),text_size=size.tiny)
    table.cell(t,4,6,"●",bgcolor=fColor(h4_100),text_size=size.tiny)
    table.cell(t,5,6,"●",bgcolor=fColor(h4_200),text_size=size.tiny)

    // D
    d_10=fTrend("D",10), d_20=fTrend("D",20), d_50=fTrend("D",50), d_100=fTrend("D",100), d_200=fTrend("D",200)
    table.cell(t,0,7,"D",bgcolor=color.black,text_color=color.white,text_size=size.tiny)
    table.cell(t,1,7,"●",bgcolor=fColor(d_10),text_size=size.tiny)
    table.cell(t,2,7,"●",bgcolor=fColor(d_20),text_size=size.tiny)
    table.cell(t,3,7,"●",bgcolor=fColor(d_50),text_size=size.tiny)
    table.cell(t,4,7,"●",bgcolor=fColor(d_100),text_size=size.tiny)
    table.cell(t,5,7,"●",bgcolor=fColor(d_200),text_size=size.tiny)

    // W
    w_10=fTrend("W",10), w_20=fTrend("W",20), w_50=fTrend("W",50), w_100=fTrend("W",100), w_200=fTrend("W",200)
    table.cell(t,0,8,"W",bgcolor=color.black,text_color=color.white,text_size=size.tiny)
    table.cell(t,1,8,"●",bgcolor=fColor(w_10),text_size=size.tiny)
    table.cell(t,2,8,"●",bgcolor=fColor(w_20),text_size=size.tiny)
    table.cell(t,3,8,"●",bgcolor=fColor(w_50),text_size=size.tiny)
    table.cell(t,4,8,"●",bgcolor=fColor(w_100),text_size=size.tiny)
    table.cell(t,5,8,"●",bgcolor=fColor(w_200),text_size=size.tiny)
````

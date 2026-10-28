# ontagion & Shock System (CSS) - Systemic Risk Tracker

- url: https://www.tradingview.com/script/FaqXFDHA-ontagion-Shock-System-CSS-Systemic-Risk-Tracker/
- type: indicator
- pine_id: PUB;93df1cad1a96489fb7cb6f27a394b45f
- version: 1.0

## Description

The Contagion & Shock System (CSS) is an advanced quantitative indicator designed to measure systemic risk and sector contagion in real-time. Instead of looking at a single asset in isolation, this system tracks how sudden price shocks ripple across a configurable basket of proxy assets, helping traders identify true macro risk-on or risk-off environments. 

1. Shock Detection
The system continuously monitors the base asset for sudden volatility spikes. It triggers an active "Shock" if a single bar exceeds a specific percentage threshold, or if a cumulative multi-bar move indicates sustained, aggressive buying or selling pressure.

2. Dynamic Correlation Engine (Wave Assignment)
The indicator runs a live Pearson Correlation (using log returns) between your base chart and 10 configurable proxy assets (e.g., SPY, QQQ, VIX, XLF). It automatically buckets these assets into three contagion waves:

Wave 1 (Immediate Impact): Correlation >= 0.70

Wave 2 (Lagging Impact): Correlation >= 0.40

Wave 3 (Distant/Isolated): Correlation < 0.40

3. Contagion Pressure Index (CPI)
Displayed as a central histogram, the CPI aggregates the correlation strength and directional movement of all 10 proxies. A positive score indicates risk-on contagion (assets are rising together), while a negative score indicates risk-off contagion (assets are falling together).

4. Systemic Risk Score (0-100)
Located in the dashboard, this gauge blends the magnitude of the CPI, the number of assets currently caught in Wave 1, and the recency of the last price shock. A score above 80 indicates severe market-wide stress.

Users can fully customize the shock thresholds, cumulative lookback windows, correlation lengths, and all 10 proxy tickers via the indicator settings to tailor the system to specific sectors or asset classes.

## Source Code

````pine
//@version=6
indicator("Contagion & Shock System", shorttitle="CSS", overlay=false, precision=2)

// ========================================================================= //
// 1. INPUTS & SETTINGS
// ========================================================================= //
grpShock = "Shock Detection"
shockThresh = input.float(2.0, title="Single-Bar Shock Threshold (%)", group=grpShock)
cumBars     = input.int(3, title="Multi-Bar Cumulative Window", group=grpShock)

grpCorr = "Correlation Engine & Proxies"
corrLen = input.int(20, title="Pearson Correlation Length", group=grpCorr)

// 10 Configurable Proxy Assets
sym1  = input.symbol("SPY",  group=grpCorr)
sym2  = input.symbol("QQQ",  group=grpCorr)
sym3  = input.symbol("IWM",  group=grpCorr)
sym4  = input.symbol("DIA",  group=grpCorr)
sym5  = input.symbol("AAPL", group=grpCorr)
sym6  = input.symbol("MSFT", group=grpCorr)
sym7  = input.symbol("XLF",  group=grpCorr)
sym8  = input.symbol("XLK",  group=grpCorr)
sym9  = input.symbol("XLE",  group=grpCorr)
sym10 = input.symbol("VIX",  group=grpCorr)

// ========================================================================= //
// 2. SHOCK DETECTION
// ========================================================================= //
pctChange = (close - close[1]) / close[1] * 100
cumChange = (close - close[cumBars]) / close[cumBars] * 100

isSingleBull = pctChange >= shockThresh
isSingleBear = pctChange <= -shockThresh
isCumBull    = cumChange >= (shockThresh * 1.5)
isCumBear    = cumChange <= -(shockThresh * 1.5)

isBullShock  = isSingleBull or isCumBull
isBearShock  = isSingleBear or isCumBear
isAnyShock   = isBullShock or isBearShock

barsSinceShock = ta.barssince(isAnyShock)
shockRecency   = barsSinceShock == 0 ? 1.0 : math.max(0, 1.0 - (barsSinceShock / 10))

// ========================================================================= //
// 3. CORRELATION ENGINE (Log Returns)
// ========================================================================= //
baseLogRet = math.log(close / close[1])

get_proxy_data(sym) =>
    pClose = request.security(sym, timeframe.period, close)
    pRet = math.log(pClose / pClose[1])
    corr = ta.correlation(baseLogRet, pRet, corrLen)
    [pRet, corr]

[r1, c1] = get_proxy_data(sym1)
[r2, c2] = get_proxy_data(sym2)
[r3, c3] = get_proxy_data(sym3)
[r4, c4] = get_proxy_data(sym4)
[r5, c5] = get_proxy_data(sym5)
[r6, c6] = get_proxy_data(sym6)
[r7, c7] = get_proxy_data(sym7)
[r8, c8] = get_proxy_data(sym8)
[r9, c9] = get_proxy_data(sym9)
[r10, c10] = get_proxy_data(sym10)

// ========================================================================= //
// 4. WAVE ASSIGNMENT & CPI (UPDATED FOR ARRAY LOOPING)
// ========================================================================= //
// Initialize variables for the current bar
wave1 = 0
wave2 = 0
wave3 = 0
rawCPI = 0.0

// Load results into arrays to avoid global variable mutation errors
corrArray = array.from(c1, c2, c3, c4, c5, c6, c7, c8, c9, c10)
retArray  = array.from(r1, r2, r3, r4, r5, r6, r7, r8, r9, r10)

// Loop through the 10 proxies
for i = 0 to 9
    corr = array.get(corrArray, i)
    pRet = array.get(retArray, i)
    
    if math.abs(corr) >= 0.70
        wave1 += 1
    else if math.abs(corr) >= 0.40
        wave2 += 1
    else
        wave3 += 1
        
    rawCPI += (math.abs(corr) * math.sign(pRet))

normCPI = rawCPI * 5

// ========================================================================= //
// 5. SYSTEMIC RISK SCORE (0-100 Gauge)
// ========================================================================= //
cpiFactor   = (math.abs(normCPI) / 50) * 33
waveFactor  = (wave1 / 10) * 33
shockFactor = shockRecency * 34

systemicRisk = cpiFactor + waveFactor + shockFactor

// ========================================================================= //
// 6. VISUALS & PLOTTING
// ========================================================================= //
cpiColor = normCPI > 0 ? color.new(color.lime, 0) : color.new(color.red, 0)
plot(normCPI, title="Contagion Pressure Index", style=plot.style_columns, color=cpiColor)

hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dotted)

plot(systemicRisk - 50, title="Systemic Risk (Visual Plot)", color=color.new(color.orange, 0), linewidth=2)

var table dash = table.new(position.bottom_right, 2, 4, border_width=1)
if barstate.islast
    table.cell(dash, 0, 0, "Systemic Risk Score", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 0, str.tostring(systemicRisk, "#.##"), text_color=systemicRisk > 75 ? color.red : color.white, bgcolor=color.black)
    
    table.cell(dash, 0, 1, "CPI (Risk On/Off)", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 1, str.tostring(normCPI, "#.##"), text_color=cpiColor, bgcolor=color.black)
    
    table.cell(dash, 0, 2, "Wave 1 Assets (>= 0.70)", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 2, str.tostring(wave1), text_color=color.yellow, bgcolor=color.black)
    
    table.cell(dash, 0, 3, "Active Shock", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 3, isBullShock ? "BULL" : isBearShock ? "BEAR" : "NONE", text_color=isAnyShock ? color.red : color.gray, bgcolor=color.black)

// ========================================================================= //
// 7. ALERTS (6 Conditions)
// ========================================================================= //
alertcondition(isBullShock, title="1. Bullish Shock Detected", message="A Bullish Shock (Single or Cumulative) exceeded the threshold.")
alertcondition(isBearShock, title="2. Bearish Shock Detected", message="A Bearish Shock (Single or Cumulative) exceeded the threshold.")
alertcondition(normCPI >= 40, title="3. High Risk-On Contagion", message="CPI exceeded +40. Risk-on spreading rapidly across proxies.")
alertcondition(normCPI <= -40, title="4. High Risk-Off Contagion", message="CPI dropped below -40. Risk-off contagion in motion.")

redSystemicTrigger = isAnyShock and (wave1 >= 5)
alertcondition(redSystemicTrigger, title="5. SYSTEMIC ALERT", message="CRITICAL: Shock detected while 5+ assets are in Wave 1 correlation.")
alertcondition(systemicRisk >= 80, title="6. Systemic Risk > 80", message="Systemic Risk Gauge has breached 80/100.")
````

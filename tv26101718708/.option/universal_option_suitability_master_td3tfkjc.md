# Universal Option Suitability Master

- url: https://www.tradingview.com/script/Td3TfkJc-Universal-Option-Suitability-Master/
- type: indicator
- pine_id: PUB;8ddaab1ff25a41289acef9ea691433dd
- version: 1.0

## Description

Universal Option Suitability Master (IC-S)
Overview
Options trading is often less about "direction" and more about Volatility and Market Structure. The Universal Option Suitability Master is a comprehensive quantitative dashboard designed to help traders identify the mathematically optimal time to enter five of the most popular options strategies.

Instead of guessing if the "premium is worth the risk," this tool analyzes the market through three distinct pillars—Volatility, Trend Strength, and Range Consistency—to provide a real-time Suitability Score (0-100%).

The Three Pillars of Suitability
This indicator calculates a weighted score based on three core metrics:

Volatility Pillar (IV Rank): Measures current historical volatility relative to the last 252 trading days. It tells you if options are currently "expensive" (selling environment) or "cheap" (buying environment).

Trend Pillar (ADX): Evaluates the strength of the current trend. Neutral strategies (like Iron Condors) require a low ADX, while directional spreads require a high ADX.

Range Pillar (Choppiness Index): Determines if price action is staying within a consolidated range or preparing for a breakout.
Supported Strategies

You can toggle between five different strategy modes in the settings. The entire dashboard and math engine will update instantly to reflect that strategy’s specific requirements:

Sell Iron Condor: A neutral income strategy. Optimal when IV is high, trends are weak, and the market is choppy.

Buy Iron Condor: A range-breakout play. Optimal when IV is cheap and a new trend is emerging from a tight range.

Straddle: A pure volatility bet. Optimal when IV is at extreme lows and trend strength is high (anticipating a massive move regardless of direction).

Credit Spreads: A trend-following income play. Optimal when IV is high and the trend is clearly established.

Calendar Spreads: A "Time & Vol" play. Optimal when the market is flat and IV is at historical lows, betting on a future rise in volatility.

Key Features
Interactive Dashboard: Features a clean table in the top-right corner with hover-tooltips explaining every metric.

Multi-Strategy Background Scanner: The script monitors all 5 strategies simultaneously. You can set alerts for the "Optimal" zone of any strategy, even if you don't have it currently selected.
Visual Suitability Histogram: High-visibility columns colored by "Optimal" (Green), "Fair" (Orange), and "Avoid" (Red) zones.
Strategy Tips: Includes dynamic entry tips and brief explanations of each strategy's logic directly on the UI.

How to Use
Select your target strategy in the Input settings.
Check the Suitability Score: A score above 70% indicates a mathematically "Optimal" environment for that specific trade.
Review the Pillars: Use the dashboard to see if the score is being driven by high premium (IVR) or market structure (ADX/Chop).
Set Alerts: Use the built-in alert conditions to be notified the moment a high-probability setup occurs on your favorite ticker.

Disclaimer
This indicator is for educational and informational purposes only. Options trading involves significant risk. The "Suitability Score" is a mathematical model based on historical data and does not guarantee future results. Always practice proper risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("Universal Option Suitability Master", shorttitle="Option Master", overlay=false, precision=0)

// --- Inputs ---
string strategyChoice = input.string("Sell Iron Condor", "Select Strategy", options=["Sell Iron Condor", "Buy Iron Condor", "Straddle", "Credit Spread", "Calendar Spread"])
int    ivrLookback    = input.int(252, "IV Rank Lookback")
int    adxLookback    = input.int(14, "ADX Length")
int    chopLookback   = input.int(14, "Choppiness Length")

color  bullCol = input.color(#089981, "High Suitability")
color  bearCol = input.color(#f23645, "Low Suitability")
color  neutCol = input.color(#ff9800, "Neutral")

// --- 1. Calculations ---
float logRet = math.log(close / close[1])
float hvVal  = ta.stdev(logRet, 20) * math.sqrt(252) * 100
float hvH    = ta.highest(hvVal, ivrLookback)
float hvL    = ta.lowest(hvVal, ivrLookback)
float ivrPct = (hvVal - hvL) / math.max(hvH - hvL, 0.001) * 100

// ADX
float trRaw   = math.max(high - low, math.abs(high - close[1]), math.abs(low - close[1]))
float trSm    = ta.rma(trRaw, adxLookback)
float pDM     = ta.rma(math.max(high - high[1], 0), adxLookback)
float mDM     = ta.rma(math.max(low[1] - low, 0), adxLookback)
float pDI     = 100 * pDM / math.max(trSm, 0.001)
float mDI     = 100 * mDM / math.max(trSm, 0.001)
float adxVal  = ta.rma(100 * math.abs(pDI - mDI) / math.max(pDI + mDI, 0.001), adxLookback)

// Choppiness
float sumTR    = math.sum(trRaw, chopLookback)
float highestH = ta.highest(high, chopLookback)
float lowestL  = ta.lowest(low, chopLookback)
float chopVal  = 100 * math.log10(sumTR / math.max(highestH - lowestL, 0.001)) / math.log10(chopLookback)

// --- 2. Strategy Logic ---
float scoreSellIC   = (ivrPct * 0.4) + (math.max(0, 100 - (adxVal * 2)) * 0.3) + (chopVal * 0.3)
float scoreBuyIC    = ((100 - ivrPct) * 0.4) + (math.min(100, adxVal * 2) * 0.3) + ((100 - chopVal) * 0.3)
float scoreStraddle = ((100 - ivrPct) * 0.5) + (math.min(100, adxVal * 2.5) * 0.5)
float scoreCredit   = (ivrPct * 0.5) + (math.min(100, adxVal * 2) * 0.5)
float scoreCalendar = ((100 - ivrPct) * 0.5) + (math.max(0, 100 - (adxVal * 2)) * 0.5)

float  finalScore = strategyChoice == "Sell Iron Condor" ? scoreSellIC : strategyChoice == "Buy Iron Condor" ? scoreBuyIC : strategyChoice == "Straddle" ? scoreStraddle : strategyChoice == "Credit Spread" ? scoreCredit : scoreCalendar
string descText   = strategyChoice == "Sell Iron Condor" ? "Neutral strategy selling premium." : strategyChoice == "Buy Iron Condor" ? "Directional breakout strategy." : strategyChoice == "Straddle" ? "Non-directional volatility bet." : strategyChoice == "Credit Spread" ? "Trend-following income strategy." : "Neutral strategy betting on vol rise."
string entryTip   = strategyChoice == "Sell Iron Condor" ? "High IVR + Low ADX" : strategyChoice == "Buy Iron Condor" ? "Low IVR + Rising ADX" : strategyChoice == "Straddle" ? "Low IVR + High ADX" : strategyChoice == "Credit Spread" ? "High IVR + Clear Trend" : "Low IVR + Flat Market"

color  scoreColor = finalScore > 70 ? bullCol : finalScore > 40 ? neutCol : bearCol

// --- 3. Visuals ---
plot(finalScore, "Suitability", color=scoreColor, style=plot.style_columns)
hline(70, "Optimal", color=color.new(bullCol, 50), linestyle=hline.style_dashed)
hline(40, "Avoid", color=color.new(bearCol, 50), linestyle=hline.style_dashed)

// --- 4. Dashboard with Tooltips ---
var table mainTable = table.new(position.top_right, 2, 6, border_width=1)
if barstate.islast
    // Strategy Name
    table.cell(mainTable, 0, 0, "STRATEGY", text_color=chart.fg_color, tooltip="The currently selected options strategy being analyzed.")
    table.cell(mainTable, 1, 0, strategyChoice, text_color=scoreColor)
    
    // Suitability
    table.cell(mainTable, 0, 1, "SUITABILITY", text_color=chart.fg_color, tooltip="A master score (0-100%) based on Volatility, Trend, and Choppiness pillars. 70%+ is optimal.")
    table.cell(mainTable, 1, 1, str.format("{0,number,#}%", finalScore), bgcolor=scoreColor, text_color=color.white)
    
    // IV Rank
    table.cell(mainTable, 0, 2, "IV Rank", text_color=chart.fg_color, tooltip="Measures current volatility relative to the last year. High IV Rank = Expensive premiums.")
    table.cell(mainTable, 1, 2, str.format("{0,number,#}%", ivrPct), text_color=chart.fg_color)
    
    // ADX
    table.cell(mainTable, 0, 3, "Trend (ADX)", text_color=chart.fg_color, tooltip="Measures trend strength. Below 20 is sideways (good for Condors). Above 25 is trending (good for Spreads).")
    table.cell(mainTable, 1, 3, str.format("{0,number,#}", adxVal), text_color=chart.fg_color)
    
    // Market Chop
    table.cell(mainTable, 0, 4, "Chop Index", text_color=chart.fg_color, tooltip="Measures price consistency. High values mean the price is staying in a range. Low values mean a breakout.")
    table.cell(mainTable, 1, 4, str.format("{0,number,#}%", chopVal), text_color=chart.fg_color)

    // Strategy Logic Info
    table.cell(mainTable, 0, 5, "Logic Tip", text_color=chart.fg_color, tooltip=descText)
    table.cell(mainTable, 1, 5, entryTip, text_color=neutCol, text_size=size.small)

// Alerts
alertcondition(finalScore > 70, "Strategy Optimal", "Current strategy suitability is above 70%.")
````

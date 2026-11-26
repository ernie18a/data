# Zero to Hero + Buy / Sell Labels + Dashboard

- url: https://www.tradingview.com/script/B62LSDu3-Zero-to-Hero-Buy-Sell-Labels-Dashboard/
- type: indicator
- pine_id: PUB;caab975c1cdd40e4bdf63b68a530d640
- version: 1.0

## Description

Zero to Hero is a comprehensive market-readiness meter that distills five powerful technical factors into a single, easy‑to‑read Hero Score (0‑100). It helps you avoid low‑probability chop and only trade when the odds are stacked in your favour. The indicator draws clear entry signals, dynamic stop‑loss and take‑profit levels, and a vibrant dashboard so you always know whether the market is in “hero” mode or still a “zero”.

[b]How It Works[/b]
The Hero Score is built from five independent components, each contributing up to 20 points:

Trend Alignment – Price above fast & slow EMAs, and EMAs stacked correctly.

Momentum – RSI in the healthy zone (50‑70 for longs).

Volume – Volume above its moving average, confirming participation.

Volatility – ATR% inside a “Goldilocks” range (not too quiet, not too wild).

Price Structure – Higher highs/higher lows (bullish) or lower highs/lower lows (bearish) based on pivot points.

The Bull Hero Score measures readiness for long trades; the Bear Hero Score does the same for shorts.
When a score crosses your chosen threshold (default 80 for longs, 20 for shorts), the indicator issues a non‑repainting signal.

What You’ll See on the Chart
Buy / Sell Labels – “🦸 HERO LONG” or “🦹 HERO SHORT” appear when the setup is confirmed.

Stop‑Loss & Take‑Profit Lines – Automatically placed at 1.5× ATR and 2.5× ATR from entry (customisable).

Risk‑Reward Shading – A translucent grey box between stop and target makes your trade plan instantly visible.

Hero Meter – A lower‑pane histogram shows the Hero Scores building up, with threshold lines for quick visual reference.

Info Dashboard – A colourful, easy‑to‑read table in the top‑right corner showing all five component scores, ATR%, volume ratio, and your current stop/target when a signal is active.

How to Use It
Wait until the dashboard says “🦸 LONG” or “🦹 SHORT”.

Check the dashboard – all five components should be showing green or positive values.

Enter the trade in the direction indicated.

Set your stop exactly where the red dashed line is drawn.

Take profit at the green dashed line.

Do nothing when the dashboard says “⚪ WAIT”. Patience is the edge.

Inputs & Customisation
All thresholds can be adjusted via the settings panel:

Hero Long / Short Threshold – Sensitivity of signals (default 80 / 20).

EMA lengths – Fast & Slow EMAs for trend detection.

RSI period – Used in momentum scoring.

Volume & Volatility filters – Minimum volume ratio, acceptable ATR% range.

Risk Management – ATR multiplier for stop‑loss and take‑profit.

Dashboard toggle – Show/hide the info panel.

Best For
Swing & position traders who want high‑confidence setups.

Intraday traders looking to filter out low‑volume chop.

Any market – stocks, forex, crypto, indices.

All timeframes (works best on 15min – daily).

Important Notes
Signals are non‑repainting (confirmed on bar close).

No indicator predicts the future – this tool highlights high‑probability conditions only.

Always use proper risk management.

Past performance does not guarantee future results.

Risk Disclaimer
This indicator is provided for educational purposes only. It does not constitute financial advice. Trading involves substantial risk of loss. Always do your own analysis and never trade with money you cannot afford to lose.

Take your trading from zero to hero – only when the market gives you the green light.

## Source Code

````pine
//@version=5
indicator("Zero to Hero", overlay=true, max_lines_count=50, max_labels_count=50, max_boxes_count=10)

// ======== USER INPUTS ========
heroLongThresh  = input.int(80, "Hero Long Threshold", minval=50, maxval=100, group="Hero Settings")
heroShortThresh = input.int(20, "Hero Short Threshold", minval=0, maxval=50, group="Hero Settings")

emaFastLen = input.int(20, "Fast EMA", group="Trend")
emaSlowLen = input.int(50, "Slow EMA", group="Trend")
rsiLen     = input.int(14, "RSI Period", group="Trend")

volAvgLen    = input.int(20,   "Volume MA Length", group="Volume & Volatility")
minVolRatio  = input.float(1.2, "Min Volume Ratio", minval=1.0, group="Volume & Volatility")
maxATRpc     = input.float(5.0, "Max ATR% (too volatile)", minval=1.0, group="Volume & Volatility")
minATRpc     = input.float(0.5, "Min ATR% (too quiet)",   minval=0.1, group="Volume & Volatility")

atrLen        = input.int(14,   "ATR Period", group="Risk Management")
riskATRMult   = input.float(1.5, "Stop Loss (ATR x)", minval=0.5, group="Risk Management")
rewardATRMult = input.float(2.5, "Take Profit (ATR x)", minval=1.0, group="Risk Management")

showDashboard = input.bool(true, "Show Dashboard", group="Dashboard")

// ======== COLOR HELPER FUNCTIONS (global scope) ========
bullColor(val) =>
    val >= 80 ? color.green : val >= 60 ? color.orange : val >= 40 ? color.yellow : color.gray

bearColor(val) =>
    val <= 20 ? color.red : val <= 40 ? color.orange : val <= 60 ? color.yellow : color.gray

// ======== CORE CALCULATIONS ========
emaF = ta.ema(close, emaFastLen)
emaS = ta.ema(close, emaSlowLen)
rsi  = ta.rsi(close, rsiLen)
atr  = ta.atr(atrLen)
atrPct = atr / close * 100
volAvg = ta.sma(volume, volAvgLen)
volRatio = volume / volAvg

// ==== COMPONENT SCORES ====
emaAlignScore = 0
if close > emaF and emaF > emaS
    emaAlignScore := 60
else if close > emaF or emaF > emaS
    emaAlignScore := 30

slope = ta.linreg(close, 20, 0) - ta.linreg(close, 20, 1)
slopeScore = slope > 0 ? 20 : slope < 0 ? -20 : 0

rsiScore = 0
if rsi > 50 and rsi < 70
    rsiScore := 20
else if rsi > 70
    rsiScore := 10
else if rsi < 50 and rsi > 30
    rsiScore := 10

volScore = volRatio >= minVolRatio ? 20 : 0
voltyScore = (atrPct >= minATRpc and atrPct <= maxATRpc) ? 20 : 0

structureScore = 0
ph = ta.pivothigh(high, 5, 5)
pl = ta.pivotlow(low, 5, 5)
var float lastHigh = na, var float lastLow = na
if not na(ph)
    lastHigh := ph
if not na(pl)
    lastLow := pl
if not na(lastHigh) and not na(lastLow)
    if close > lastHigh
        structureScore := 20
    else if close < lastLow
        structureScore := -20
    else if low > lastLow and lastLow > lastLow[10]
        structureScore := 15
    else if high < lastHigh and lastHigh < lastHigh[10]
        structureScore := -15

// ======== HERO SCORES ========
heroScore = emaAlignScore + math.max(slopeScore, 0) + rsiScore + volScore + voltyScore + math.max(structureScore, 0)
heroScore := math.max(0, math.min(heroScore, 100))

bearHeroScore = (100 - emaAlignScore) + math.max(-slopeScore, 0) + (20 - rsiScore) + volScore + voltyScore + math.max(-structureScore, 0)
bearHeroScore := math.max(0, math.min(bearHeroScore, 100))

// ======== TRADE SIGNALS (on bar close only) ========
var line stopLine = na, var line targetLine = na
var label entryLabel = na

if not na(stopLine)
    line.delete(stopLine)
    stopLine := na
if not na(targetLine)
    line.delete(targetLine)
    targetLine := na
if not na(entryLabel)
    label.delete(entryLabel)
    entryLabel := na

bool longSignal  = heroScore >= heroLongThresh and barstate.isconfirmed
bool shortSignal = bearHeroScore <= heroShortThresh and barstate.isconfirmed

if longSignal
    entryLabel := label.new(bar_index, low, "🦸 HERO LONG\nScore: " + str.tostring(heroScore, "#"), color=color.new(color.green, 90), textcolor=color.white, style=label.style_label_up, size=size.small)
    stopPrice   = close - (atr * riskATRMult)
    targetPrice = close + (atr * rewardATRMult)
    stopLine    := line.new(bar_index, stopPrice, bar_index + 10, stopPrice, color=color.red, width=2, style=line.style_dashed)
    targetLine  := line.new(bar_index, targetPrice, bar_index + 10, targetPrice, color=color.green, width=2, style=line.style_dashed)
    linefill.new(stopLine, targetLine, color.new(color.gray, 85))

if shortSignal
    entryLabel := label.new(bar_index, high, "🦹 HERO SHORT\nScore: " + str.tostring(bearHeroScore, "#"), color=color.new(color.red, 90), textcolor=color.white, style=label.style_label_down, size=size.small)
    stopPrice   = close + (atr * riskATRMult)
    targetPrice = close - (atr * rewardATRMult)
    stopLine    := line.new(bar_index, stopPrice, bar_index + 10, stopPrice, color=color.red, width=2, style=line.style_dashed)
    targetLine  := line.new(bar_index, targetPrice, bar_index + 10, targetPrice, color=color.green, width=2, style=line.style_dashed)
    linefill.new(stopLine, targetLine, color.new(color.gray, 85))

// ======== HERO METER (lower histogram) ========
heroScorePlot = plot(heroScore, "Hero Score", color=color.new(color.green, 50), style=plot.style_columns)
hline(heroLongThresh, "Long Threshold", color=color.green, linestyle=hline.style_dashed)
hline(heroShortThresh, "Short Threshold", color=color.red, linestyle=hline.style_dashed)
plot(bearHeroScore, "Bear Hero Score", color=color.new(color.red, 50), style=plot.style_columns)

// ======== 🌈 ENHANCED DASHBOARD TABLE ========
var table dash = table.new(position.top_right, 2, 12, bgcolor=color.new(color.black, 85), border_width=1, border_color=color.gray)
if showDashboard and barstate.islast
    table.clear(dash, 0, 0, 1, 11)

    // Header – large & bold
    table.cell(dash, 0, 0, "⚡ ZERO TO HERO", text_color=color.yellow, text_size=size.normal, bgcolor=color.new(color.black, 90))
    headerColor = longSignal ? color.green : shortSignal ? color.red : color.gray
    headerText  = longSignal ? "🦸 LONG"   : shortSignal ? "🦹 SHORT" : "⚪ WAIT"
    table.cell(dash, 1, 0, headerText, text_color=color.white, bgcolor=headerColor, text_size=size.normal)

    // Bull Hero
    table.cell(dash, 0, 1, "Bull Hero", text_color=color.white, bgcolor=color.new(color.black, 80), text_size=size.small)
    table.cell(dash, 1, 1, str.tostring(heroScore, "#"), text_color=bullColor(heroScore), bgcolor=color.new(color.black, 80), text_size=size.normal)

    // Bear Hero
    table.cell(dash, 0, 2, "Bear Hero", text_color=color.white, bgcolor=color.new(color.black, 70), text_size=size.small)
    table.cell(dash, 1, 2, str.tostring(bearHeroScore, "#"), text_color=bearColor(bearHeroScore), bgcolor=color.new(color.black, 70), text_size=size.normal)

    // Trend
    trendColor = emaAlignScore >= 60 ? color.green : emaAlignScore >= 30 ? color.orange : color.gray
    table.cell(dash, 0, 3, "📈 Trend", text_color=color.white, bgcolor=color.new(color.black, 80), text_size=size.small)
    table.cell(dash, 1, 3, str.tostring(emaAlignScore, "#"), text_color=trendColor, bgcolor=color.new(color.black, 80), text_size=size.small)

    // Momentum
    momColor = rsiScore >= 20 ? color.green : rsiScore >= 10 ? color.orange : color.gray
    table.cell(dash, 0, 4, "🚀 Momentum", text_color=color.white, bgcolor=color.new(color.black, 70), text_size=size.small)
    table.cell(dash, 1, 4, str.tostring(rsiScore, "#"), text_color=momColor, bgcolor=color.new(color.black, 70), text_size=size.small)

    // Volume
    volColor = volScore > 0 ? color.green : color.red
    table.cell(dash, 0, 5, "🔊 Volume", text_color=color.white, bgcolor=color.new(color.black, 80), text_size=size.small)
    table.cell(dash, 1, 5, volScore > 0 ? "✓ HIGH" : "✗ LOW", text_color=volColor, bgcolor=color.new(color.black, 80), text_size=size.small)

    // Volatility
    voltyColor = voltyScore > 0 ? color.green : color.red
    table.cell(dash, 0, 6, "🌊 Volatility", text_color=color.white, bgcolor=color.new(color.black, 70), text_size=size.small)
    table.cell(dash, 1, 6, voltyScore > 0 ? "✓ IDEAL" : "✗ EXTREME", text_color=voltyColor, bgcolor=color.new(color.black, 70), text_size=size.small)

    // Structure
    structColor = structureScore > 0 ? color.green : structureScore < 0 ? color.red : color.gray
    structText  = structureScore > 0 ? "↑ " + str.tostring(structureScore, "+#") : structureScore < 0 ? "↓ " + str.tostring(structureScore, "+#") : "→ 0"
    table.cell(dash, 0, 7, "🏗 Structure", text_color=color.white, bgcolor=color.new(color.black, 80), text_size=size.small)
    table.cell(dash, 1, 7, structText, text_color=structColor, bgcolor=color.new(color.black, 80), text_size=size.small)

    // ATR%
    atrColor = voltyScore > 0 ? color.green : color.orange
    table.cell(dash, 0, 8, "📏 ATR%", text_color=color.white, bgcolor=color.new(color.black, 70), text_size=size.small)
    table.cell(dash, 1, 8, str.tostring(atrPct, "#.##") + " %", text_color=atrColor, bgcolor=color.new(color.black, 70), text_size=size.small)

    // Volume Ratio
    volRatColor = volScore > 0 ? color.green : color.gray
    table.cell(dash, 0, 9, "📊 Vol Ratio", text_color=color.white, bgcolor=color.new(color.black, 80), text_size=size.small)
    table.cell(dash, 1, 9, str.tostring(volRatio, "#.##") + "x", text_color=volRatColor, bgcolor=color.new(color.black, 80), text_size=size.small)

    // Stop/Target (only if signal active)
    if longSignal and not na(stopLine)
        table.cell(dash, 0, 10, "🛑 Stop Loss", text_color=color.red, bgcolor=color.new(color.black, 70), text_size=size.small)
        table.cell(dash, 1, 10, str.tostring(close - (atr * riskATRMult), "#.##"), text_color=color.red, bgcolor=color.new(color.black, 70), text_size=size.normal)
        table.cell(dash, 0, 11, "🎯 Take Profit", text_color=color.green, bgcolor=color.new(color.black, 80), text_size=size.small)
        table.cell(dash, 1, 11, str.tostring(close + (atr * rewardATRMult), "#.##"), text_color=color.green, bgcolor=color.new(color.black, 80), text_size=size.normal)
    else if shortSignal and not na(stopLine)
        table.cell(dash, 0, 10, "🛑 Stop Loss", text_color=color.red, bgcolor=color.new(color.black, 70), text_size=size.small)
        table.cell(dash, 1, 10, str.tostring(close + (atr * riskATRMult), "#.##"), text_color=color.red, bgcolor=color.new(color.black, 70), text_size=size.normal)
        table.cell(dash, 0, 11, "🎯 Take Profit", text_color=color.green, bgcolor=color.new(color.black, 80), text_size=size.small)
        table.cell(dash, 1, 11, str.tostring(close - (atr * rewardATRMult), "#.##"), text_color=color.green, bgcolor=color.new(color.black, 80), text_size=size.normal)
````

# 10 EMA Breakout Scanner

- url: https://www.tradingview.com/script/l5WWZOnW-10-EMA-Breakout-Scanner/
- type: indicator
- pine_id: PUB;f514dd53505f4202b96178b81e432c20
- version: 1.0

## Description

10 EMA Breakout Scanner

Rules:

Price must be within 3% of the 10 EMA (hugging the moving average)
Stock must be consolidating — 5-day high-to-low range ≤ 8%
Price must be within 5% of the 52-week high or at all-time highs
RSI (14) must be above 50 (momentum confirmation)
BUY when the next candle closes above the consolidation range high and above the 10 EMA
Entry at the breakout candle's high
Stop loss at the breakout candle's low
Target at 1:3 risk-reward from entry
Avoid trading when:

Stock is extended more than 3% from 10 EMA
RSI is below 50 (weak momentum)
No tight consolidation (range > 8%)
Stock is far from 52-week highs (still in recovery mode)

## Source Code

````pine
//@version=5
indicator("10 EMA Consolidation Breakout", overlay=true, max_labels_count=50, max_lines_count=100)

// --- Inputs ---
emaLen        = input.int(10, "EMA Length")
consolDays    = input.int(5, "Consolidation Days", minval=3, maxval=10)
emaTouchPct   = input.float(3.0, "Max % Distance from EMA", step=0.5)
consolRange   = input.float(8.0, "Max Consolidation Range %", step=0.5)
rrRatio       = input.float(3.0, "Risk:Reward Ratio", step=0.5)
rsiLen        = input.int(14, "RSI Length")
rsiMin        = input.float(50.0, "Min RSI")
highLookback  = input.int(252, "52-Week Lookback (bars)")
nearHighPct   = input.float(5.0, "Max % Below 52W High", step=0.5)

// --- Core Calculations ---
ema10  = ta.ema(close, emaLen)
rsi    = ta.rsi(close, rsiLen)
availBars = math.min(highLookback, bar_index + 1)
high52 = ta.highest(high, availBars)

// --- Consolidation Detection ---
currentNearEma = math.abs(close - ema10) / ema10 * 100 <= emaTouchPct

consolHigh = ta.highest(high, consolDays)
consolLow  = ta.lowest(low, consolDays)
consolRangePct = (consolHigh - consolLow) / consolLow * 100
isTightRange = consolRangePct <= consolRange

isConsolidating = currentNearEma and isTightRange

// --- Near 52-Week / All-Time High ---
distFromHigh = (high52 - close) / high52 * 100
nearHigh = distFromHigh <= nearHighPct

// --- RSI Filter ---
rsiOk = rsi > rsiMin

// --- Setup Detection (day before breakout) ---
setup = isConsolidating and nearHigh and rsiOk

// --- Breakout Confirmation ---
prevSetup = setup[1]
prevConsolHigh = consolHigh[1]
breakoutConfirmed = prevSetup and close > prevConsolHigh and close > ema10

// --- Risk/Reward Levels ---
entryPrice = breakoutConfirmed ? high : na
stopLoss   = breakoutConfirmed ? low : na
riskAmt    = entryPrice - stopLoss
target     = entryPrice + (riskAmt * rrRatio)

// --- Plotting ---
plot(ema10, "10 EMA", color=color.yellow, linewidth=2)

plotshape(setup and not setup[1], "Setup", style=shape.diamond, location=location.belowbar, color=color.orange, size=size.small)

plotshape(breakoutConfirmed, "BUY", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.normal, text="BUY")

if breakoutConfirmed
    line.new(bar_index - 1, entryPrice, bar_index + 15, entryPrice, color=color.blue, style=line.style_solid, width=1)
    line.new(bar_index - 1, stopLoss, bar_index + 15, stopLoss, color=color.red, style=line.style_dashed, width=1)
    line.new(bar_index - 1, target, bar_index + 15, target, color=color.green, style=line.style_dashed, width=1)

    label.new(bar_index + 16, entryPrice, "Entry: " + str.tostring(entryPrice, format.mintick), style=label.style_label_left, color=color.blue, textcolor=color.white, size=size.small)
    label.new(bar_index + 16, stopLoss, "SL: " + str.tostring(stopLoss, format.mintick) + " (" + str.tostring(riskAmt, format.mintick) + ")", style=label.style_label_left, color=color.red, textcolor=color.white, size=size.small)
    label.new(bar_index + 16, target, "Target: " + str.tostring(target, format.mintick) + " (1:" + str.tostring(rrRatio) + ")", style=label.style_label_left, color=color.green, textcolor=color.white, size=size.small)

// --- Info Table ---
var table infoTbl = table.new(position.top_right, 2, 7, bgcolor=color.new(color.black, 80), border_width=1)

if barstate.islast
    table.cell(infoTbl, 0, 0, "Dist from EMA", text_color=color.gray, text_size=size.small)
    table.cell(infoTbl, 1, 0, str.tostring(math.abs(close - ema10) / ema10 * 100, "#.##") + "%", text_color=math.abs(close - ema10) / ema10 * 100 <= emaTouchPct ? color.lime : color.red, text_size=size.small)

    table.cell(infoTbl, 0, 1, "RSI (14)", text_color=color.gray, text_size=size.small)
    table.cell(infoTbl, 1, 1, str.tostring(rsi, "#.#"), text_color=rsi > rsiMin ? color.lime : color.red, text_size=size.small)

    table.cell(infoTbl, 0, 2, "52W High Dist", text_color=color.gray, text_size=size.small)
    table.cell(infoTbl, 1, 2, str.tostring(distFromHigh, "#.##") + "%", text_color=distFromHigh <= nearHighPct ? color.lime : color.red, text_size=size.small)

    table.cell(infoTbl, 0, 3, "Consol Range", text_color=color.gray, text_size=size.small)
    table.cell(infoTbl, 1, 3, str.tostring(consolRangePct, "#.##") + "%", text_color=isTightRange ? color.lime : color.red, text_size=size.small)

    table.cell(infoTbl, 0, 4, "Consolidating", text_color=color.gray, text_size=size.small)
    table.cell(infoTbl, 1, 4, isConsolidating ? "YES" : "NO", text_color=isConsolidating ? color.lime : color.red, text_size=size.small)

    table.cell(infoTbl, 0, 5, "Setup Ready", text_color=color.gray, text_size=size.small)
    table.cell(infoTbl, 1, 5, setup ? "YES" : "NO", text_color=setup ? color.lime : color.red, text_size=size.small)

    table.cell(infoTbl, 0, 6, "R:R", text_color=color.gray, text_size=size.small)
    table.cell(infoTbl, 1, 6, "1:" + str.tostring(rrRatio), text_color=color.yellow, text_size=size.small)

// --- Alerts ---
alertcondition(breakoutConfirmed, "Breakout Buy", "10 EMA Consolidation Breakout on {{ticker}} — Entry: {{close}}")
alertcondition(setup and not setup[1], "Setup Forming", "10 EMA Consolidation Setup forming on {{ticker}}")
````

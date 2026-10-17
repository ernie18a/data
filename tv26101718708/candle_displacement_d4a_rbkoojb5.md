# Candle Displacement [D4A]

- url: https://www.tradingview.com/script/rbKoojB5-Candle-Displacement-D4A/
- type: indicator
- pine_id: PUB;d5241cd106914739bb8a3af581060e20
- version: 1.0

## Description

[b]Quantifying Market Momentum[/b]

Spotting sudden, aggressive price action often called displacement doesn't have to be a guessing game. Finding who is in control - buyers or sellers - can be as easy as looking for candles with specific colors. The script objectively track these explosive price moves by comparing candle's range against multiple of ATR over a specific lookback period (ATR Length).
True displacement should create a gap or FVG (Fair Value Gap) which indicates strong price move in one direction and this script provides the logic to catch this specific scenario while filtering out noise. Additionally, the cript marks break-of-structure displacement candles to highlight the beginning of strong directional move or a reversal. There is also filter provided to find only candles with significant gap created (FVG threshold). This script works best on smaller timeframes, eg. 1m or 5m.

[b]SETTINGS[/b]
- Displacement - show displacement candles
- Min Body % - displacement candle should have at least this body size compared to whole candle range
- Require FVG - filters out the candles which don't create a gap. True displacement should create FVG
- Threshold - a valid FVG should be larger than this ATR multiplier
- Highlight candles which broke structure - color-codes the candles that broke recent market structure (high or low)
- Bars to define recent high/low (structure) - how many bars back should the script look to find recent high or low
- ATR length - ATR value over period of time to calculate average candle range
- Multiplier - used to find candles which are this times bigger than average ATR

-----------------
Disclaimer

The content provided in this script is for educational and informational purposes only. It does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any financial instruments. I will not accept liability for any loss or damage, including without limitation any loss of profit, which may arise directly or indirectly from the use of or reliance on such information.

All investments involve risk, and the past performance of a security, industry, sector, market, financial product, trading strategy, backtest, or individual's trading does not guarantee future results or returns. Investors are fully responsible for any investment decisions they make. Such decisions should be based solely on an evaluation of their financial circumstances, investment objectives, risk tolerance, and liquidity needs.

## Source Code

````pine
//@version=6
indicator("Candle Displacement", "DisplacementT", overlay=true)

var gDISPL = "Candle Displacement"
show_displacement = input.bool(true, 'Displacement', inline = 'displ0', group = gDISPL)
displ_c_up = input.color(color.new(#2E47C7, 50), '', inline = 'displ0', group = gDISPL)
displ_c_dn = input.color(color.new(color.yellow, 50), '', inline = 'displ0', group = gDISPL)
minBodyPct = input.float(60, "Min Body %", step=5, inline = 'displ0', group = gDISPL)
require_fvg   = input.bool(true, 'Require FVG    ', inline = 'displ1', group = gDISPL)
filterFVG     = input.float(0.3, 'Threshold', minval = 0, step = .1, inline = 'displ1', group = gDISPL, tooltip = 'Real displacement which shows intent should create FVG.\n\nValid FVGs must have a range greater than this ATR filter')
require_break = input.bool(true, 'Highlight candles which broke structure', inline = 'displ2', group = gDISPL)
displ_c_up_break = input.color(color.new(#1E3195, 0), '', inline = 'displ2', group = gDISPL)
displ_c_dn_break = input.color(color.new(color.yellow, 20), '', inline = 'displ2', group = gDISPL)
swingLookback = input.int(15,  "Bars to define recent high/low (structure)", minval=2, group = gDISPL)
atrLen        = input.int(300,  "ATR length", minval=1, inline = 'displ4', group = gDISPL)
atrMult       = input.float(1.5, "    Multiplier", step=0.1, inline = 'displ4', group = gDISPL)

atr = ta.atr(atrLen)

filter(a, b) =>
    a - b > atr * filterFVG

candle_range = high - low
body = math.abs(close - open)
fvgup = high[1] > high[2] and low > high[2] and filter(low, high[2])
fvgdn = low[1] < low[2] and high < low[2] and filter(low[2], high)

bodyPct  = candle_range > 0 ? body / candle_range * 100 : 0
big_body_bull = bodyPct >= minBodyPct and close > open
big_body_bear = bodyPct >= minBodyPct and close < open
bigRange = atr > 0 and candle_range >= atr * atrMult

// Break of recent structure (local high/low). Highest high and lowest low over last N bars, excluding current bar
priorHigh = ta.highest(high[1], swingLookback)
priorLow  = ta.lowest(low[1],  swingLookback)

brokeUp  = not na(priorHigh) and high > priorHigh 
brokeDown = not na(priorLow)  and low  < priorLow

displ_bull = require_fvg ? bigRange[1] and big_body_bull[1] and fvgup : bigRange and big_body_bull
displ_bull_break = require_fvg ? bigRange[1] and big_body_bull[1] and brokeUp[1] and fvgup : bigRange and big_body_bull and brokeUp

displ_bear = require_fvg ? bigRange[1] and big_body_bear[1] and fvgdn : bigRange and big_body_bear
displ_bear_break = require_fvg ? bigRange[1] and big_body_bear[1] and brokeDown[1] and fvgdn : bigRange and big_body_bear and brokeDown

barcolor(not show_displacement ? na : displ_bull ? displ_bull_break and require_break ? displ_c_up_break : displ_c_up : displ_bear ? displ_bear_break and require_break ? displ_c_dn_break : displ_c_dn : na,  offset = require_fvg ? -1 : na, title = 'Displacement Bars')
````

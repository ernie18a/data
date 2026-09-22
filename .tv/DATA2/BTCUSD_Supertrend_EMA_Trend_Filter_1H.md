<!-- tradingview-pine-id: PUB;caca248edd1a4bc7aa8857c730cb421f -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# BTCUSD Supertrend + EMA Trend Filter (1H)

Source: https://www.tradingview.com/script/NgSIfKQx-Bitcoin-SuperFlip-Supertrend-EMA-Trend-Following-Strategy/

## Description

SuperFlip combines two of the most widely tested trend-following tools on TradingView — the ATR-based Supertrend and a long-period EMA trend filter — into a single directional strategy built and tuned for BTCUSD on the 1-hour chart. The goal isn't novelty; it's a clean, well-understood core (Supertrend flips) layered with a simple confirmation filter (EMA200) and an optional secondary filter (ADX) to reduce whipsaw entries during choppy, low-conviction conditions.

This is a trend-following, not mean-reversion system. It will have a lower win rate than a typical scalping strategy, and that is by design — trend systems make their money from a smaller number of large winning trades that outweigh a higher frequency of small losses.

How it works

[*]Supertrend (ATR-based) tracks the prevailing trend direction and flips when price crosses its dynamic ATR band. This flip is the core trigger for both entries and exits.
[*]EMA200 trend filter only allows longs when price is above the 200-period EMA, and shorts when price is below it — filtering out counter-trend signals that go against the higher-timeframe bias.
[*]Optional ADX filter (off by default) adds a trend-strength gate, only allowing entries when ADX is above a user-set threshold (default 20). This is intended to reduce entries during flat, directionless conditions where Supertrend tends to whipsaw.
[*]Flip-based exits: positions close automatically when Supertrend flips in the opposite direction — this is the primary exit mechanism.
[*]Optional Stop Loss / Take Profit: percentage-based SL/TP can be layered on top of the flip exit as a secondary risk cap (off by default in the current preset — see warnings below).

Features

[*]Toggleable ADX trend-strength filter with adjustable length, smoothing, and threshold
[*]Optional percentage-based stop loss and take profit
[*]Adjustable Supertrend ATR length/factor and EMA filter length
[*]Visual glow-line Supertrend rendering with layered gradient fill toward price
[*]Bullish/bearish flip markers, separate from actual trade-entry markers, so you can see when Supertrend flips vs. when a trade was actually filtered/taken
[*]Multiple color presets (Classic, Aqua, Cosmic, Cyber, Neon, Custom)
[*]Optional bar and background tinting for at-a-glance trend state
[*]Commission (0.075%) and slippage (1 tick) modeled into backtest results by default

Recommendations

[*]Built and tested for BTCUSD, 1H timeframe — this is the intended use case; other assets/timeframes will require re-tuning.
[*]Position sizing defaults to 25% of equity per trade rather than 100% — this materially reduces drawdown and PnL volatility versus full-equity compounding, and is a more realistic starting point for evaluation.
[*]If enabling the ADX filter, start around threshold 15-20 and sweep from there — lower values retain more trades at the cost of some whipsaw protection, higher values do the opposite.
[*]Consider re-enabling a wider stop loss (8-10%+) rather than running with SL fully disabled, especially before using on a leveraged instrument.
[*]Always forward-test or paper-trade before committing real capital — historical performance on a fixed backtest window is not a guarantee of future results.

Warnings

[*]No stop loss is enabled by default in this configuration. Running without a stop loss on a leveraged or volatile asset like BTC carries real, uncapped downside risk per trade — enable and size a stop loss appropriate to your risk tolerance before live use.
[*]With low trade counts (roughly 50-100 in typical backtests), a small number of outlier trades can heavily influence headline profit factor and total return figures — inspect the individual trade list, not just summary stats, before trusting the numbers.
[*]High reported PnL% figures are sensitive to default_qty_value (percent-of-equity compounding) and can look far more impressive than the underlying edge actually is. Judge the strategy primarily by win rate, profit factor, and drawdown — not raw percentage return.
[*]Past performance on historical data does not predict future results. This script is provided for educational and research purposes and is not financial advice.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © blitz_locked

//@version=6
strategy("BTCUSD Supertrend + EMA Trend Filter (1H)", overlay=true,
     initial_capital=10000,
     default_qty_type=strategy.percent_of_equity, default_qty_value=25,
     commission_type=strategy.commission.percent, commission_value=0.075,
     slippage=1)

//              ╔════════════════════════════════╗              //
//              ║      USER-DEFINED SETTINGS     ║              //
//              ╚════════════════════════════════╝              //

g_strategy = '════════ Strategy Settings ════════'
g_adx      = '════════ ADX Filter ════════'
g_visual   = '════════ Visual Settings ════════'

atrPeriod   = input.int(10, title="Supertrend ATR Length", group=g_strategy)
factor      = input.float(1.8, title="Supertrend Factor", step=0.1, group=g_strategy)

emaLen      = input.int(200, title="EMA Trend Filter Length", group=g_strategy)

enableSL    = input.bool(false, title="Enable Stop Loss", group=g_strategy)
enableTP    = input.bool(false, title="Enable Take Profit", group=g_strategy)
slPct       = input.float(4.0, title="Stop Loss %", step=0.1, group=g_strategy) / 100
tpPct       = input.float(8.0, title="Take Profit %", step=0.1, group=g_strategy) / 100

enableADX   = input.bool(false, title="Enable ADX Filter", group=g_adx, tooltip="Only take signals when ADX is above the threshold, filtering out low-conviction/choppy conditions.")
adxLen      = input.int(14, title="ADX Length", minval=1, group=g_adx)
adxSmooth   = input.int(14, title="ADX Smoothing", minval=1, group=g_adx)
adxThresh   = input.float(20.0, title="ADX Threshold", step=1.0, group=g_adx)

show_fill     = input.bool(true, 'Show Gradient Fill', group=g_visual)
show_markers  = input.bool(true, 'Show Flip Markers', group=g_visual)
color_preset  = input.string('Custom', 'Color Preset', options=['Classic', 'Aqua', 'Cosmic', 'Cyber', 'Neon', 'Custom'], group=g_visual)
bullish_input = input.color(#00ffaa, 'Bullish Color', group=g_visual)
bearish_input = input.color(#ff0000, 'Bearish Color', group=g_visual)
show_candles  = input.bool(false, 'Enable Bar Coloring', group=g_visual)
bar_trans     = input.int(0, 'Bar Color Transparency', minval=0, maxval=100, group=g_visual)
show_bgcolor  = input.bool(false, 'Enable Background Coloring', group=g_visual)
bg_trans      = input.int(90, 'Background Color Transparency', minval=0, maxval=100, group=g_visual)

[bullish_color, bearish_color] = switch color_preset
    'Classic' => [#00ff00, #ff0000]
    'Aqua'    => [#00d4ff, #ff8c00]
    'Cosmic'  => [#49ffce, #9932cc]
    'Cyber'   => [#00cccc, #ff6600]
    'Neon'    => [#ffff00, #ff00ff]
    'Custom'  => [bullish_input, bearish_input]

//              ╔════════════════════════════════╗              //
//              ║        CORE CALCULATION        ║              //
//              ╚════════════════════════════════╝              //

[supertrend, direction] = ta.supertrend(factor, atrPeriod)
trendEMA = ta.ema(close, emaLen)

bullFlip = ta.change(direction) < 0   // flipped to uptrend
bearFlip = ta.change(direction) > 0   // flipped to downtrend

// ADX calculation (Wilder's DMI/ADX)
[diplus, diminus, adx] = ta.dmi(adxLen, adxSmooth)
adxOK = not enableADX or adx > adxThresh

longCondition  = bullFlip and close > trendEMA and adxOK
shortCondition = bearFlip and close < trendEMA and adxOK

trend_color = direction < 0 ? bullish_color : bearish_color

//              ╔════════════════════════════════╗              //
//              ║           EXECUTION            ║              //
//              ╚════════════════════════════════╝              //

if longCondition
    strategy.entry("Long", strategy.long)

if shortCondition
    strategy.entry("Short", strategy.short)

if bearFlip
    strategy.close("Long")
if bullFlip
    strategy.close("Short")

if strategy.position_size > 0
    entryPrice = strategy.position_avg_price
    if enableSL
        strategy.exit("Long SL/TP", "Long", stop = entryPrice * (1 - slPct),
             limit = enableTP ? entryPrice * (1 + tpPct) : na)

if strategy.position_size < 0
    entryPrice = strategy.position_avg_price
    if enableSL
        strategy.exit("Short SL/TP", "Short", stop = entryPrice * (1 + slPct),
             limit = enableTP ? entryPrice * (1 - tpPct) : na)

//              ╔════════════════════════════════╗              //
//              ║         VISUALIZATION          ║              //
//              ╚════════════════════════════════╝              //

// Glow + core Supertrend line
st_up = direction < 0 ? supertrend : na
st_dn = direction > 0 ? supertrend : na

plot(st_up, 'Glow Up',   color=color.new(bullish_color, 70), linewidth=6, style=plot.style_linebr)
plot(st_dn, 'Glow Down', color=color.new(bearish_color, 70), linewidth=6, style=plot.style_linebr)
p_st_up = plot(st_up, 'Bullish Supertrend', color=bullish_color, linewidth=2, style=plot.style_linebr)
p_st_dn = plot(st_dn, 'Bearish Supertrend', color=bearish_color, linewidth=2, style=plot.style_linebr)

// EMA trend filter line
plot(trendEMA, title="EMA Trend Filter", color=color.new(color.orange, 20), linewidth=1)

// Gradient fill between Supertrend line and price (layered, QuantAlgo-style)
p_price = plot(close, 'Price Anchor', color=na, display=display.none, editable=false)

step_up  = not na(st_up) ? (close - st_up) / 4.0 : na
grad1_up = not na(step_up) ? st_up + step_up * 1.0 : na
grad2_up = not na(step_up) ? st_up + step_up * 2.0 : na
grad3_up = not na(step_up) ? st_up + step_up * 3.0 : na

step_dn  = not na(st_dn) ? (close - st_dn) / 4.0 : na
grad1_dn = not na(step_dn) ? st_dn + step_dn * 1.0 : na
grad2_dn = not na(step_dn) ? st_dn + step_dn * 2.0 : na
grad3_dn = not na(step_dn) ? st_dn + step_dn * 3.0 : na

p_g1u = plot(show_fill ? grad1_up : na, display=display.none, editable=false)
p_g2u = plot(show_fill ? grad2_up : na, display=display.none, editable=false)
p_g3u = plot(show_fill ? grad3_up : na, display=display.none, editable=false)
p_g1d = plot(show_fill ? grad1_dn : na, display=display.none, editable=false)
p_g2d = plot(show_fill ? grad2_dn : na, display=display.none, editable=false)
p_g3d = plot(show_fill ? grad3_dn : na, display=display.none, editable=false)

fill(p_st_up, p_g1u, color=show_fill ? color.new(bullish_color, 65) : na, title='Up Gradient 1')
fill(p_g1u, p_g2u,   color=show_fill ? color.new(bullish_color, 78) : na, title='Up Gradient 2')
fill(p_g2u, p_g3u,   color=show_fill ? color.new(bullish_color, 88) : na, title='Up Gradient 3')
fill(p_g3u, p_price, color=show_fill ? color.new(bullish_color, 95) : na, title='Up Gradient 4')

fill(p_st_dn, p_g1d, color=show_fill ? color.new(bearish_color, 65) : na, title='Down Gradient 1')
fill(p_g1d, p_g2d,   color=show_fill ? color.new(bearish_color, 78) : na, title='Down Gradient 2')
fill(p_g2d, p_g3d,   color=show_fill ? color.new(bearish_color, 88) : na, title='Down Gradient 3')
fill(p_g3d, p_price, color=show_fill ? color.new(bearish_color, 95) : na, title='Down Gradient 4')

// Flip markers
plotshape(show_markers and bullFlip ? supertrend : na, title='Bullish Flip', style=shape.triangleup, location=location.belowbar, color=bullish_color, size=size.small)
plotshape(show_markers and bearFlip ? supertrend : na, title='Bearish Flip', style=shape.triangledown, location=location.abovebar, color=bearish_color, size=size.small)

// Entry markers
plotshape(longCondition, title='Long Entry', style=shape.circle, location=location.belowbar, color=color.new(bullish_color, 0), size=size.tiny)
plotshape(shortCondition, title='Short Entry', style=shape.circle, location=location.abovebar, color=color.new(bearish_color, 0), size=size.tiny)

// Optional bar/background tint
barcolor(show_candles ? color.new(trend_color, bar_trans) : na, title='Trend Bar Color')
bgcolor(show_bgcolor ? color.new(trend_color, bg_trans) : na, title='Trend Background Color')
````

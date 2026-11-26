# BTC IV Term Structure (60D - 30D)

- url: https://www.tradingview.com/script/DXWQJLmZ-BTC-IV-Term-Structure-60D-30D/
- type: indicator
- pine_id: PUB;d043e3843fe6400bb1da1daede64f899
- version: 1.0

## Description

This indicator measures the spread between Bitcoin's 60-day implied volatility and its 30-day implied volatility. When the spread is positive (contango), the market is pricing more uncertainty further out than near-term, which is the default, calm-market state. When the spread goes negative (backwardation), near-term fear has overtaken longer-term fear, which typically signals a stress event is actively unfolding, whether that's a sharp selloff, a macro catalyst, or a liquidation cascade working through the market.

The histogram color tells you the regime at a glance. Teal means contango, red means backwardation. The intensity matters too: a bright bar means the spread is outside the rolling mean plus or minus one standard deviation band, which flags a statistically extreme reading rather than just a directional one. Those extremes are where the indicator earns its keep. A deep red bar at an extreme low is the market pricing in panic, and historically those episodes tend to mean revert once the catalyst clears. A bright teal bar at an extreme high signals the opposite, complacency that can precede a volatility expansion.

The EMA line smooths the raw spread and is the cleanest signal to watch for regime transitions. A crossover from below zero to above zero (or vice versa) marks the point where the term structure has flipped regimes. Crossovers that happen at or near the band extremes carry more weight than crossovers near the mean. The percentile rank label on the last bar gives you immediate context: a reading in the 10th percentile means the spread is as compressed as it has been roughly 90% of the time over the past year, which is a meaningful signal on its own.

The most practical use is as a filter layered on top of an entry signal from another strategy. When backwardation is at an extreme and your directional indicator is signaling a long, the IV structure is corroborating the setup, the market is fearful and mean reversion conditions are favorable. When the spread is in extreme contango and everything looks calm, that is often the wrong time to be adding aggressive long exposure, because volatility tends to be cheapest right before it expands. Use this indicator to contextualize risk environment, not as a standalone entry trigger.

## Source Code

````pine
//@version=6
indicator('BTC IV Term Structure (60D - 30D)', shorttitle = 'BVIV Spread', overlay = false)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
smooth_len = input.int(5, 'Smoothing (EMA)', minval = 1, group = 'Display')
band_len = input.int(90, 'Rolling Window (bars)', minval = 10, group = 'Bands')
band_mult = input.float(1.0, 'Band StdDev Mult', minval = 0.1, step = 0.1, group = 'Bands')
show_bands = input.bool(true, 'Show Mean + Bands', group = 'Bands')
pct_len = input.int(252, 'Percentile Lookback', minval = 50, group = 'Percentile')
show_label = input.bool(true, 'Show Status Label', group = 'Percentile')

// ─── DATA ─────────────────────────────────────────────────────────────────────
bviv60 = request.security('VOLMEX:BVIV60D', timeframe.period, close, ignore_invalid_symbol = true)
bviv30 = request.security('VOLMEX:BVIV', timeframe.period, close, ignore_invalid_symbol = true)

spread = bviv60 - bviv30
spread_ema = ta.ema(spread, smooth_len)

// ─── STATISTICS ───────────────────────────────────────────────────────────────
s_mean = ta.sma(spread, band_len)
s_std = ta.stdev(spread, band_len)
upper = s_mean + band_mult * s_std
lower = s_mean - band_mult * s_std

pct_rank = ta.percentrank(spread, pct_len) / 100

// ─── REGIME FLAGS ─────────────────────────────────────────────────────────────
is_contango = spread >= 0
extreme_high = spread > upper
extreme_low = spread < lower

bar_col = is_contango ? extreme_high ? color.new(color.teal, 20) : color.new(color.teal, 55) : extreme_low ? color.new(color.red, 20) : color.new(color.red, 55)

// ─── BACKGROUND ───────────────────────────────────────────────────────────────
bgcolor(extreme_low ? color.new(color.red, 92) : na, title = 'Extreme Backwardation')
bgcolor(extreme_high ? color.new(color.teal, 92) : na, title = 'Extreme Contango')

// ─── PLOTS ────────────────────────────────────────────────────────────────────
hline(0, 'Zero', color = color.new(color.white, 50), linewidth = 1, linestyle = hline.style_dashed)

u_plot = plot(show_bands ? upper : na, 'Upper Band', color = color.new(color.gray, 70))
l_plot = plot(show_bands ? lower : na, 'Lower Band', color = color.new(color.gray, 70))
fill(u_plot, l_plot, color = color.new(color.gray, 88))

plot(show_bands ? s_mean : na, 'Mean', color = color.new(color.gray, 50), linewidth = 1)

plot(spread, 'IV Spread', color = bar_col, style = plot.style_histogram, linewidth = 3)
plot(spread_ema, 'Spread EMA', color = color.new(color.white, 0), linewidth = 2)

// ─── STATUS LABEL ─────────────────────────────────────────────────────────────
if show_label and barstate.islast
    regime = is_contango ? 'CONTANGO' : 'BACKWARDATION'
    pct_str = str.tostring(math.round(pct_rank * 100)) + 'th pct'
    spd_str = 'Spread: ' + str.tostring(math.round(spread, 2))
    lbl_col = is_contango ? color.teal : color.red

    label.new(x = bar_index, y = spread_ema, text = regime + '\n' + pct_str + '\n' + spd_str, color = lbl_col, style = label.style_label_left, textcolor = color.white, size = size.small)
````

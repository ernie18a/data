# [Thies] 0DTE SPY+ES Volume, VIX1D, Volume Delta

- url: https://www.tradingview.com/script/KikMRsOG-Thies-0DTE-SPY-ES-Volume-VIX1D-Volume-Delta/
- type: indicator
- pine_id: PUB;2e244cb2243541ec8176768e0a1c50aa
- version: 1.0

## Description

[b]0DTE Tape Read: Combining SPY + ES Volume, VIX1D, and Volume Delta for Same-Day Options Trading[/b]

[b]Why I Built This[/b]

If you trade 0DTE options on [symbol="SP:SPX"]SP:SPX[/symbol]  or [symbol="AMEX:SPY"]AMEX:SPY[/symbol] SPY, you already know raw SPY volume alone gives you an incomplete picture. The real flow lives across multiple instruments:

[list]
[*] SPY captures retail and ETF arbitrage  
[*] ES futures lead price discovery and show institutional hedging  
[*] VIX1D tells you the implied vol regime for the day you're actually trading  
[/list]

This indicator combines all three into a single pane so you can read the tape the way it actually trades, not the way a single-symbol volume bar suggests.

[b]What the Indicator Shows[/b]

[list]
[*] [b]SPY Volume (blue columns)[/b]  
Retail flow, ETF arb, and dealer hedging on the cash side.

[*] [b]ES Volume (orange columns)[/b]  
Institutional flow and the leading instrument for S&P price discovery. ES trades nearly 24 hours, so it shows you where the real money is positioned before the cash open and through the close.

[*] [b]Combined Volume Line (purple) with Moving Average[/b]  
Total flow across both instruments. The MA gives you a baseline to spot real surges versus noise.

[*] [b]Volume Delta Histogram (green/red)[/b]  
A signed-volume proxy using close vs open on each bar. Green means net buying pressure, red means net selling. Smoothed with an EMA to filter single-bar noise.

[*] [b]VIX1D Overlay (yellow)[/b]  
The 1-day VIX. This is the single most important context metric for 0DTE that most traders ignore. It tells you what implied vol is pricing for today specifically, not the 30-day VIX which is mostly irrelevant for same-day expiry.
[/list]

A dashboard in the top-right shows live values for each metric.

[b]Why This Beats Single-Symbol Volume[/b]

Three reasons SPY volume alone falls short for 0DTE:

[list]
[*] SPX dominates institutional 0DTE flow. Big players use SPX for cash settlement and 60/40 tax treatment. ES futures are the closest free proxy for that flow.  

[*] Overnight and pre-market context. ES tells you the setup before SPY even opens.  

[*] Dealer hedging happens in futures. When 0DTE gamma forces hedging, it shows up in ES first.  
[/list]

VIX1D rounds it out because 0DTE pricing is driven by 1-day implied vol, not the headline VIX number on financial TV.

[b]How to Trade With It[/b]

[b]Setup[/b]

[list]
[*] Timeframe: 1m or 5m on SPY or ES  
[*] Active hours: 9:30 to 10:30 and 14:00 to 16:00 ET  
[*] Skip the lunch chop window from roughly 11:30 to 13:30  
[/list]

[b]The Core Read[/b]

[list]
[*] [b]Bullish alignment:[/b] Green delta histogram rising + combined volume above MA + VIX1D stable or falling. Trade calls or call spreads.  

[*] [b]Bearish alignment:[/b] Red delta histogram falling + combined volume above MA + VIX1D rising. Trade puts or put spreads.  

[*] [b]Stand down:[/b] Delta near zero + volume below MA. Theta will eat you. No trade.  
[/list]

[b]High-Probability Windows[/b]

[b]Opening Drive (9:30 to 10:00)[/b]

A first-15-minute volume spike with delta in one direction signals a trend day. Enter on the first pullback to the combined volume MA. If VIX1D is above 18, widen your stop and cut your size.

[b]Reversal Window (10:00 to 10:30)[/b]

Watch for delta to flip against the opening move on rising volume. This is statistically the best risk/reward window of the day. Reversal setups here have a real edge if the histogram confirms.

[b]Fed/News Pivot (14:00)[/b]

On Fed days or scheduled releases, look for the volume surge plus clear delta direction and follow it. If VIX1D spikes and delta flips, fade the initial knee-jerk move.

[b]MOC Ramp (15:00 to 16:00)[/b]

0DTE gamma is at its peak. Sustained delta in one direction tends to accelerate into the close. Exit by 15:45 unless you're actively scalping into the bell.

[b]Strike Selection by VIX1D[/b]

[list]
[*] [b]VIX1D below 12:[/b] ATM or one strike OTM. Expect small moves, take quick profits.  

[*] [b]VIX1D 12 to 18:[/b] Two to three strikes OTM. Normal-range day.  

[*] [b]VIX1D above 20:[/b] Five-plus strikes OTM. Fat tails are likely, premiums are rich, sizing should drop.  
[/list]

[b]Risk Rules[/b]

[list]
[*] Risk 1 to 2% of account per trade. 0DTE goes to zero faster than you can react.  

[*] Stop out if delta flips against you or price breaks the combined volume MA.  

[*] Target 50 to 100% on premium. Don't get greedy on same-day expiry.  

[*] No new positions after 15:45.  

[*] Three losers in a row, you're done for the day. Walk away.  
[/list]

[b]Quick Decision Tree[/b]

[list]
[*] Is combined volume above its MA? If no, no trade.  

[*] Is delta strong and aligned with price? If yes, trade with trend.  

[*] Is delta flipping opposite to price on rising volume? If yes, reversal setup.  

[*] Is delta flat? No trade.  
[/list]

[b]What This Indicator Is Not[/b]

It's not a signal generator. It's a confirmation and context tool. The edge comes from using it to say no to 80% of setups you would have taken on raw volume alone.

Combine it with your own price action read, key levels, and gamma exposure data for full context.

[b]Known Limitations[/b]

[list]
[*] The delta calculation uses close vs open as a sign proxy. True signed volume requires tick data Pine Script can't access. The proxy is directionally useful but not exact.  

[*] ES1! is the continuous front-month contract. Roll dynamics can create small discontinuities on roll dates.  

[*] VIX1D only goes back to mid-2023, so backtests on older data won't include it.  
[/list]

[b]Inputs You Can Customize[/b]

[list]
[*] Symbols for SPY, ES, and VIX1D  
(defaults to AMEX:SPY, CME_MINI:ES1!, CBOE:VIX1D)

[*] Toggle each plot on/off  

[*] Moving average length for combined volume  

[*] Smoothing length for the volume delta histogram  
[/list]

[b]Final Thoughts[/b]

0DTE is a game of probabilities, timing, and discipline.

Most retail traders blow up because they trade size based on raw price action without understanding the flow underneath or the vol regime they're inside of.

This indicator forces you to look at all three at once:

[list]
[*] Where the money is  
[*] Which direction it's going  
[*] How much movement the market is pricing in  
[/list]

Use it as a filter, not a crystal ball.

The best trades will scream at you when every layer aligns. Everything else is noise.

If you found this useful, hit boost, drop a comment with how you're using it, and follow for more tools focused on real-world execution.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © kingthies

//@version=6 
indicator("[Thies] 0DTE SPY+ES Volume, VIX1D, Volume Delta", shorttitle = "0DTE", overlay=false)

// ============ INPUTS ============
spySymbol   = input.symbol("AMEX:SPY", "SPY Symbol")
esSymbol    = input.symbol("CME_MINI:ES1!", "ES Front Month")
vix1dSymbol = input.symbol("CBOE:VIX1D", "VIX1D Symbol")

showSPY      = input.bool(true,  "Show SPY Volume",      group="Volume")
showES       = input.bool(true,  "Show ES Volume",       group="Volume")
showCombined = input.bool(true,  "Show Combined Volume", group="Volume")
showDelta    = input.bool(true,  "Show Volume Delta",    group="Volume Delta")
showVIX1D    = input.bool(true,  "Show VIX1D Overlay",   group="VIX1D")

maLen        = input.int(20, "Combined Vol MA Length", minval=1, group="Volume")
deltaMaLen   = input.int(9,  "Delta Smoothing Length",  minval=1, group="Volume Delta")

// ============ DATA PULLS ============
spyVol = request.security(spySymbol, timeframe.period, volume, barmerge.gaps_off, barmerge.lookahead_off)
esVol  = request.security(esSymbol,  timeframe.period, volume, barmerge.gaps_off, barmerge.lookahead_off)

// Volume delta proxy: signed volume based on close vs open
[spyOpen, spyClose] = request.security(spySymbol, timeframe.period, [open, close], barmerge.gaps_off, barmerge.lookahead_off)
[esOpen,  esClose]  = request.security(esSymbol,  timeframe.period, [open, close], barmerge.gaps_off, barmerge.lookahead_off)

spyDelta = spyClose >= spyOpen ? spyVol : -spyVol
esDelta  = esClose  >= esOpen  ? esVol  : -esVol
combinedDelta = spyDelta + esDelta
smoothedDelta = ta.ema(combinedDelta, deltaMaLen)

// VIX1D
vix1d = request.security(vix1dSymbol, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)

// ============ COMBINED VOLUME ============
combinedVol = spyVol + esVol

// ============ COLORS ============
spyColor      = color.new(color.blue,   40)
esColor       = color.new(color.orange, 40)
combinedColor = color.new(color.purple, 20)
deltaUpColor  = color.new(color.lime,   20)
deltaDnColor  = color.new(color.red,    20)
vix1dColor    = color.new(color.yellow, 0)

// ============ PLOTS ============
plot(showSPY      ? spyVol      : na, title="SPY Volume",      color=spyColor,      style=plot.style_columns)
plot(showES       ? esVol       : na, title="ES Volume",       color=esColor,       style=plot.style_columns)
plot(showCombined ? combinedVol : na, title="Combined Volume", color=combinedColor, linewidth=2, style=plot.style_line)
plot(showCombined ? ta.sma(combinedVol, maLen) : na, title="Combined Vol MA", color=color.white, linewidth=1)

// Volume Delta as histogram
deltaColor = smoothedDelta >= 0 ? deltaUpColor : deltaDnColor
plot(showDelta ? smoothedDelta : na, title="Volume Delta (smoothed)", color=deltaColor, style=plot.style_histogram, linewidth=2)

hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dotted)

// VIX1D on separate scale
plot(showVIX1D ? vix1d : na, title="VIX1D", color=vix1dColor, linewidth=2, display=display.all)

// ============ DASHBOARD ============
var table dash = table.new(position.top_right, 2, 5, border_width=1)
if barstate.islast
    table.cell(dash, 0, 0, "Metric",   bgcolor=color.new(color.gray, 70), text_color=color.white)
    table.cell(dash, 1, 0, "Value",    bgcolor=color.new(color.gray, 70), text_color=color.white)
    table.cell(dash, 0, 1, "SPY Vol",  text_color=color.white)
    table.cell(dash, 1, 1, str.tostring(spyVol, format.volume), text_color=color.white)
    table.cell(dash, 0, 2, "ES Vol",   text_color=color.white)
    table.cell(dash, 1, 2, str.tostring(esVol, format.volume), text_color=color.white)
    table.cell(dash, 0, 3, "Δ (smooth)", text_color=color.white)
    table.cell(dash, 1, 3, str.tostring(smoothedDelta, format.volume), text_color=smoothedDelta >= 0 ? color.lime : color.red)
    table.cell(dash, 0, 4, "VIX1D",    text_color=color.white)
    table.cell(dash, 1, 4, str.tostring(vix1d, "#.##"), text_color=vix1d > 20 ? color.red : vix1d > 15 ? color.yellow : color.lime)
````

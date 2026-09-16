<!-- tradingview-pine-id: PUB;205017702bbf4f01ae23f42bd1ee53d2 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Crypto Breakout Compass

Source: https://www.tradingview.com/script/Hc39wy0X/

## Description

CRYPTO BREAKOUT COMPASS
A clear framework for reading crypto breakouts — from market context to confirmed signals.

Crypto Breakout Compass highlights price-channel breaks that also meet trend, volatility and candle-strength conditions. Its purpose is to make breakout selection visible and explainable. It is a chart-analysis indicator, not an automated trading strategy.

THE SIGNAL PATH
Price-channel break → Trend alignment → Volatility & candle checks → Confirmed close → B+ or B−

Each filter has a specific job: the channel identifies a break, the EMAs establish direction, ATR limits volatility and extension, and candle location checks whether the move held into the close. A shared cooldown limits repeated alerts.

1. READ THE CHART
• Teal channel: highest high of the previous 20 completed candles.
• Red channel: lowest low of the previous 20 completed candles.
• Orange line: EMA50. Blue line: EMA200.
• Teal / red background: confirmed bullish / bearish trend alignment.
• B+: confirmed bullish breakout. B−: confirmed bearish breakout.
• Status panel: last confirmed trend, ATR percentage and current gate status.

The current candle is excluded from the channel calculation. A colored background alone is not a breakout signal.

2. WHAT QUALIFIES AS A SIGNAL?
Bullish — B+
The close moves above the upper channel, while the preceding close was at or below its own upper channel. Price must close above EMA50, EMA50 must be above EMA200, and EMA200 must be higher than five bars earlier. The close must finish in the top 30% of the candle.

Bearish — B−
The close moves below the lower channel, while the preceding close was at or above its own lower channel. Price must close below EMA50, EMA50 must be below EMA200, and EMA200 must be lower than five bars earlier. The close must finish in the bottom 30% of the candle.

Shared checks
• ATR14 must be positive and no more than 12% of the closing price.
• The close must extend no more than 1 ATR beyond the broken channel.
• At least 10 bars must separate signals, across both directions.
• The candle must be closed and the warmup complete.

A rejected breakout is not automatically accepted later. A fresh channel crossing is required. Zero-range candles receive a neutral close location and cannot meet the default candle-strength threshold.

3. WORKED EXAMPLES
Hypothetical prices, using the default settings. These illustrate the rules, not actual trades or forecast returns.

Example A — bullish qualification
Upper channel = 100 | ATR = 4
Candle: high 103, low 98, close 102
EMA50 = 99 | EMA200 = 95 and rising

The close is 2 points above the channel: 2 ÷ 4 = 0.5 ATR. Its location within the candle is (102 − 98) ÷ (103 − 98) = 80%, inside the top 30%. ATR is approximately 3.92% of close, below the 12% cap. If the previous-close crossing condition, warmup and cooldown are also satisfied, B+ appears at candle close.

Example B — bearish qualification
Lower channel = 100 | ATR = 4
Candle: high 102, low 97, close 98
EMA50 = 105 | EMA200 = 110 and falling

The close is 0.5 ATR below the channel and sits 20% of the way up the candle, inside the bottom 30%. ATR is approximately 4.08% of close. If the remaining conditions are satisfied, B− appears at candle close.

Example C — an extended move is rejected
Upper channel = 100 | ATR = 4 | Close = 106
The extension is 6 ÷ 4 = 1.5 ATR, exceeding the default 1 ATR limit. No B+ is printed, even if the trend is bullish. This illustrates the extension filter; it does not imply the price cannot continue higher.

4. QUICK START & ALERTS
Start with regular 1D cryptocurrency candles and the default inputs. The default warmup requires at least 205 previous bars. Separate alert conditions are available for bullish and bearish breakouts; choose “Once Per Bar Close” when creating an alert.

The research covers daily candles only. Other intervals display “Unvalidated timeframe”. Changing inputs also moves beyond the tested defaults. Bearish markers describe price direction; they do not imply that short selling is available on a spot market.

5. CONFIRMATION & DATA BEHAVIOR
Markers and saved status update only on confirmed candle closes. Channel lines and EMAs can move while a candle is open. The script uses no future bars, pivot backdating or lookahead requests. Historical data corrections, feed changes, available history and input changes can still affect historical signals.

The indicator runs entirely on TradingView chart data and requires no API key. Prices and day boundaries can differ between exchanges and USD/USDT pairs.

6. WHAT THE RESEARCH DOES — AND DOES NOT — SHOW
Fixed default rules were examined on historical daily BTC, ETH, SOL, BNB and XRP USD series from January 2021 through September 10, 2026. No parameter search was performed for this study.

The event study measures directional price change from the next daily open after a signal to the close of the tenth following candle. A simple 0.30 percentage-point round-trip cost deduction was also examined. This is not a portfolio backtest: it does not model funding, leverage, actual fills, stops or compounding.

In the 2024–2025 validation window, 67 filtered events had a mean directional change of +1.114% and a median of −1.236%. The unfiltered channel baseline, with the same cooldown, averaged +1.240% across 159 events. The worst filtered adverse excursion within an observation window was −34.744%.

The later 2026 window contained only 15 filtered events, of which 14 were bearish. This small, directionally concentrated sample does not establish a general trading edge. The five coins are also a selected, correlated sample. The evidence is mixed, and positive average event returns should not be interpreted as verified strategy profitability.

SCOPE & ORIGINALITY
This implementation combines a prior-bar Donchian-style channel, standard EMAs and Wilder ATR with directional candle location, extension limits and a shared signal cooldown. The code was written independently for this tool. Its contribution is the explicit qualification process and closed-bar status display, not a claim to have invented the underlying indicators.

Crypto Breakout Compass does not place orders or prescribe position sizes, stop-losses or exits. Use it to inspect market structure and test hypotheses; a marker is not a guarantee of follow-through.

---

## Source Code

````pine
//@version=6
// Original research indicator, prepared for BotTradeLab. No external data or API keys.
indicator("Crypto Breakout Compass", "Crypto Compass", overlay = true)

int channelLen = input.int(20, "Breakout lookback", minval = 2, maxval = 500)
int fastLen = input.int(50, "Fast EMA", minval = 2, maxval = 500)
int slowLen = input.int(200, "Slow EMA", minval = 3, maxval = 1000)
int slopeLen = input.int(5, "Slow EMA slope lookback", minval = 1, maxval = 100)
int atrLen = input.int(14, "ATR length", minval = 2, maxval = 100)
float maxAtrPct = input.float(12.0, "Maximum ATR / close (%)", minval = 0.1, step = 0.5)
float maxExtension = input.float(1.0, "Maximum breakout extension (ATR)", minval = 0.1, step = 0.1)
float minLocation = input.float(0.70, "Minimum directional close location", minval = 0.5, maxval = 1.0, step = 0.05)
int cooldown = input.int(10, "Minimum bars between alerts (both directions)", minval = 1, maxval = 500)
bool showBg = input.bool(true, "Show confirmed trend background")

if barstate.isfirst and fastLen >= slowLen
    runtime.error("Fast EMA must be shorter than slow EMA.")

float upper = ta.highest(high, channelLen)[1]
float lower = ta.lowest(low, channelLen)[1]
float fast = ta.ema(close, fastLen)
float slow = ta.ema(close, slowLen)
float atr = ta.atr(atrLen)
float atrPct = close > 0 ? 100 * atr / close : na
float location = high > low ? (close - low) / (high - low) : 0.5
int warmup = math.max(math.max(slowLen + slopeLen, channelLen + 1), atrLen)
bool ready = bar_index >= warmup and not na(atr) and atr > 0 and close > 0
bool bull = ready and close > fast and fast > slow and slow > slow[slopeLen]
bool bear = ready and close < fast and fast < slow and slow < slow[slopeLen]
bool rawUp = close > upper and close[1] <= upper[1]
bool rawDown = close < lower and close[1] >= lower[1]
bool volOk = ready and atrPct <= maxAtrPct
bool upOk = rawUp and bull and volOk and (close - upper) / atr <= maxExtension and location >= minLocation
bool downOk = rawDown and bear and volOk and (lower - close) / atr <= maxExtension and location <= 1 - minLocation
var int lastSignal = na
bool cooled = na(lastSignal) or bar_index - lastSignal >= cooldown
bool longSignal = barstate.isconfirmed and cooled and upOk
bool shortSignal = barstate.isconfirmed and cooled and downOk
if longSignal or shortSignal
    lastSignal := bar_index

// Levels and EMAs may move on the open bar; markers and saved status commit only at close.
plot(upper, "Previous-bar upper channel", color.new(color.teal, 35), style = plot.style_stepline)
plot(lower, "Previous-bar lower channel", color.new(color.red, 35), style = plot.style_stepline)
plot(fast, "Fast EMA", color.orange)
plot(slow, "Slow EMA", color.blue, 2)
plotshape(longSignal, "Confirmed bullish breakout", shape.triangleup, location.belowbar, color.teal, size = size.small, text = "B+")
plotshape(shortSignal, "Confirmed bearish breakout", shape.triangledown, location.abovebar, color.red, size = size.small, text = "B-")
var int regime = 0
var string status = "Warming up"
var float closedAtrPct = na
if barstate.isconfirmed
    regime := bull ? 1 : bear ? -1 : 0
    closedAtrPct := atrPct
    status := not ready ? "Warming up" : not volOk ? "Volatility blocked" : not cooled ? "Cooldown" : longSignal ? "Bull breakout" : shortSignal ? "Bear breakout" : "Waiting for breakout"
bgcolor(showBg ? regime == 1 ? color.new(color.teal, 93) : regime == -1 ? color.new(color.red, 93) : na : na)
var table panel = table.new(position.top_right, 2, 4, border_width = 1)
if barstate.islast
    color panelBg = color.new(color.black, 15)
    table.cell(panel, 0, 0, "Crypto Compass", text_color = color.white, bgcolor = panelBg)
    table.cell(panel, 1, 0, "Closed-bar status", text_color = color.silver, bgcolor = panelBg)
    table.cell(panel, 0, 1, "Trend", text_color = color.white, bgcolor = panelBg)
    table.cell(panel, 1, 1, regime == 1 ? "Bull" : regime == -1 ? "Bear" : "Neutral", text_color = regime == 1 ? color.teal : regime == -1 ? color.red : color.silver, bgcolor = panelBg)
    table.cell(panel, 0, 2, "ATR / close", text_color = color.white, bgcolor = panelBg)
    table.cell(panel, 1, 2, str.tostring(closedAtrPct, "#.##") + "%", text_color = color.white, bgcolor = panelBg)
    table.cell(panel, 0, 3, timeframe.isdaily and timeframe.multiplier == 1 ? "1D research scope" : "Unvalidated timeframe", text_color = color.silver, bgcolor = panelBg)
    table.cell(panel, 1, 3, status, text_color = color.white, bgcolor = panelBg)

alertcondition(longSignal, "Bullish breakout confirmed", "{{ticker}} {{interval}}: Crypto Compass bullish breakout confirmed at {{close}}.")
alertcondition(shortSignal, "Bearish breakout confirmed", "{{ticker}} {{interval}}: Crypto Compass bearish breakout confirmed at {{close}}.")
````

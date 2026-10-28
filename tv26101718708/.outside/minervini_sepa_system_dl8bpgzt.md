# Minervini SEPA System

- url: https://www.tradingview.com/script/DL8BpgzT-Minervini-SEPA-System/
- type: indicator
- pine_id: PUB;b22c26503fd74c23851417fae4ee586d
- version: 1.0

## Description

Minervini SEPA Pine Script — Complete User Guide

WHAT THE SCRIPT DOES
This script overlays Mark Minervini's complete SEPA (Specific Entry Point Analysis) methodology directly onto any TradingView chart. The moment you load any ticker, it instantly scores that stock against all of Minervini's criteria and tells you exactly where you stand — no manual calculation needed.

THE 5 VISUAL ELEMENTS ON YOUR CHART
1. Three Moving Average Lines

Yellow line = 50-day SMA
Orange line = 150-day SMA
Red line = 200-day SMA

These are the backbone of the Trend Template. You want to see price above all three, with each line stacked in order — 50 above 150, 150 above 200, all pointing up. That stacking is a Stage 2 uptrend.
2. Background Color

Blue background = Stock passes all 8 Trend Template criteria. It is in a confirmed Stage 2 uptrend. This is your hunting ground.
Green background = Stage 2 confirmed AND a VCP is actively forming. This means the spring is coiling. You are getting close to a potential entry.
No color = Stock fails one or more criteria. Do not trade it. Move on.

3. Score Table (Bottom Right Corner)
A live dashboard that updates on every bar showing every metric — the 50/150/200 SMA values, RS Rating, percent from 52-week high and low, ATR contraction status, volume dry-up status, overall SEPA score out of 8, Stage 2 confirmation, and VCP status. Green = passing. Red = failing.
4. VCP Dot Marker (aqua circle labeled "VCP")
This appears below a candle when three conditions are simultaneously true — the stock is in Stage 2, the ATR (volatility) is contracting below 60% of its 50-bar average, and volume is drying up below 70% of its average. This is the coiling phase. The stock is building energy. You are not buying here yet — you are watching and waiting.
5. Breakout Triangle (lime green triangle labeled "BREAKOUT")
This is your signal. It fires when all of the following are true at the same time — the stock is in Stage 2, price closes above the most recent pivot high resistance level, the previous bar was below that pivot, and volume surges to at least 140% of its 50-bar average. This is Minervini's exact entry trigger.

THE SCORE LABEL (TOP RIGHT OF CHART)
When you load a ticker you will see a label appear on the most recent bar showing the full scorecard. Each of the 8 criteria shows either PASS or FAIL:

Price > 150 and 200 MA — Is the stock above both its intermediate and long-term trend lines?
150 MA > 200 MA — Is the intermediate trend above the long-term trend?
200 MA Trending Up — Has the 200-day MA been rising for at least 20 bars? This confirms the long-term trend is healthy.
50 MA > 150 and 200 MA — Is the short-term trend leading the intermediate and long-term trends?
Price > 50 MA — Is price above its short-term trend line right now?
25% Above 52W Low — Has the stock recovered enough from its lows to confirm it is in an uptrend, not a dead cat bounce?
Within 25% of 52W High — Is the stock near its highs, not extended or beaten down?
RS Rating 70+ — Is this stock outperforming at least 70% of all other stocks over the past 12 months?

A score of 8/8 means the stock is in a perfect Stage 2 uptrend. A score of 6 or 7 means it is close but not ready — watch it and check back.

THE RS RATING EXPLAINED
The script calculates relative strength by comparing this stock's 12-month price performance against SPY (the S&P 500 ETF). The formula is the same method Investor's Business Daily uses for their RS Rating. A reading of 80 means the stock has outperformed 80% of the entire market over the past year. Minervini wants 70 minimum, but the best setups typically show 80 to 95. The higher the better.

ATR CONTRACTION AND VOLUME DRY-UP
These two indicators together tell you that supply is disappearing from the stock.
ATR (Average True Range) measures the daily price range. When the current 14-day ATR drops below 60% of its 50-bar average, the stock's daily swings have gotten significantly smaller. That tight, quiet price action is exactly what a VCP looks like from the inside.
Volume dry-up fires when today's volume drops below 70% of its 50-bar average. Declining volume during a consolidation means fewer and fewer sellers are willing to sell at current prices. Supply is being absorbed. When volume eventually surges on the breakout, it means demand has overwhelmed that remaining supply.
Together — tight price action on shrinking volume — that is the VCP coiling. When both say YES in your table, start watching that stock very closely.

THE ALERTS
The script has three built-in alert conditions you can activate:

Stage 2 Confirmed — Fires the moment a stock enters a valid Stage 2 uptrend. Use this to build your watchlist automatically.
VCP Setup Forming — Fires when the VCP coiling pattern is actively detected. Move this stock to your active watch list.
SEPA Breakout Alert — This is the trade trigger. Volume-confirmed breakout above the pivot on a Stage 2 stock. This is the alert you act on.

To set alerts: click the alarm clock icon in TradingView, select "Minervini SEPA System" as the condition, choose which alert you want, and set it to fire on any ticker in your watchlist.

YOUR EXACT WORKFLOW
Step 1 — Screen. Go to TradingView's built-in Stock Screener. Filter for price above the 200 SMA and 52-week high proximity. This gives you a candidate list of 50 to 150 stocks.
Step 2 — Score. Load each candidate with this script applied. Immediately check the score table. Only stocks with 7/8 or 8/8 pass to the next step.
Step 3 — Watch for the VCP. On passing stocks, wait for the aqua VCP dot to appear. That means the consolidation is tightening and volume is drying up. Add these to a focused watchlist of 10 to 20 names.
Step 4 — Set the Alert. On your VCP watchlist stocks, set the SEPA Breakout Alert. You do not need to stare at the screen. Let the alert come to you.
Step 5 — Execute. When the breakout triangle fires, confirm the volume surge visually. Entry is within 1 to 2% of the pivot. Place your stop just below the lowest point of the final VCP contraction. Size your position so that if the stop is hit, you lose no more than 1% of your total account. Minimum target is 3x your risk.
Step 6 — Manage. Hold above the rising 10-day MA. Take 25 to 33% off at 20% gain. Let the rest run. If price breaks below the stop, sell immediately. No exceptions.

WHAT YOU ARE NOT LOOKING FOR

Stocks with a red or colorless background — skip instantly
VCP dots on stocks below the 200 MA — invalid setup
Breakout triangles on low volume — the volume surge must be present or it is a false breakout
Any stock scoring below 6/8 — the trend is not established enough
Stocks more than 25% below their 52-week high — too much overhead supply to overcome

## Source Code

````pine
//@version=5
indicator("Minervini SEPA System", overlay=true, max_bars_back=500)

grp1 = "Moving Averages"
ma50_len         = input.int(50,     "50-Day SMA",                  group=grp1)
ma150_len        = input.int(150,    "150-Day SMA",                  group=grp1)
ma200_len        = input.int(200,    "200-Day SMA",                  group=grp1)

grp2 = "Trend Template"
rs_min           = input.int(70,     "Min RS Rating",                group=grp2, minval=1, maxval=99)
pct_above_low    = input.float(25.0, "Min Pct Above 52-Week Low",    group=grp2)
pct_below_high   = input.float(25.0, "Max Pct Below 52-Week High",   group=grp2)
ma200_trend_bars = input.int(20,     "200 MA Trending Up bars",      group=grp2)

grp3 = "VCP Breakout"
vol_mult       = input.float(1.4, "Volume Surge Multiplier", group=grp3)
vol_len        = input.int(50,    "Volume Average Length",   group=grp3)
pivot_lookback = input.int(20,    "Pivot High Lookback",     group=grp3)

grp4 = "Display"
show_bg    = input.bool(true, "Highlight Stage 2 Background", group=grp4)
show_score = input.bool(true, "Show SEPA Score Label",        group=grp4)
show_ma    = input.bool(true, "Show Moving Averages",         group=grp4)

ma50  = ta.sma(close, ma50_len)
ma150 = ta.sma(close, ma150_len)
ma200 = ta.sma(close, ma200_len)

plot(show_ma ? ma50  : na, "50 SMA",  color=color.new(color.yellow, 0), linewidth=1)
plot(show_ma ? ma150 : na, "150 SMA", color=color.new(color.orange, 0), linewidth=1)
plot(show_ma ? ma200 : na, "200 SMA", color=color.new(color.red,    0), linewidth=2)

high52        = ta.highest(high, 252)
low52         = ta.lowest(low,   252)
pct_from_low  = (close - low52)  / low52  * 100
pct_from_high = (high52 - close) / high52 * 100

spy       = request.security("SPY", timeframe.period, close)
rs_raw    = (close / close[252]) / (spy / spy[252]) * 100
rs_rating = math.min(math.max(rs_raw - 50, 0), 99)

tt1 = close > ma150 and close > ma200
tt2 = ma150 > ma200
tt3 = ma200 > ma200[ma200_trend_bars]
tt4 = ma50 > ma150 and ma50 > ma200
tt5 = close > ma50
tt6 = pct_from_low >= pct_above_low
tt7 = pct_from_high <= pct_below_high
tt8 = rs_rating >= rs_min

trend_template_score = (tt1 ? 1 : 0) + (tt2 ? 1 : 0) + (tt3 ? 1 : 0) + (tt4 ? 1 : 0) + (tt5 ? 1 : 0) + (tt6 ? 1 : 0) + (tt7 ? 1 : 0) + (tt8 ? 1 : 0)

full_trend_template = trend_template_score == 8

atr14     = ta.atr(14)
atr50     = ta.sma(ta.atr(14), 50)
vcp_tight = atr14 < atr50 * 0.6

vol_avg   = ta.sma(volume, vol_len)
vol_dryup = volume < vol_avg * 0.7

pivot_high = ta.pivothigh(high, pivot_lookback, pivot_lookback)
var float last_pivot = na
if not na(pivot_high)
    last_pivot := pivot_high

vcp_setup = full_trend_template and vcp_tight and vol_dryup

vol_surge = volume > vol_avg * vol_mult
breakout  = not na(last_pivot) and close > last_pivot and close[1] <= last_pivot and vol_surge and full_trend_template

bg_color = full_trend_template ? (vcp_setup ? color.new(color.green, 88) : color.new(color.blue, 92)) : na
bgcolor(show_bg ? bg_color : na)

plotshape(breakout, title="SEPA Breakout", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.normal, text="BREAKOUT")
plotshape(vcp_setup and not breakout, title="VCP Setup", style=shape.circle, location=location.belowbar, color=color.aqua, size=size.small, text="VCP")

p(b) => b ? "PASS" : "FAIL"

if show_score and barstate.islast
    line1  = "SEPA SCORE\n"
    line2  = "--------------\n"
    line3  = p(tt1) + " | Price > 150 and 200 MA\n"
    line4  = p(tt2) + " | 150 MA > 200 MA\n"
    line5  = p(tt3) + " | 200 MA Trending Up\n"
    line6  = p(tt4) + " | 50 MA > 150 and 200 MA\n"
    line7  = p(tt5) + " | Price > 50 MA\n"
    line8  = p(tt6) + " | 25pct Above 52W Low\n"
    line9  = p(tt7) + " | Within 25pct of 52W High\n"
    line10 = p(tt8) + " | RS Rating 70+\n"
    line11 = "--------------\n"
    line12 = str.tostring(trend_template_score) + "/8 Criteria\n"
    line13 = full_trend_template ? "STAGE 2 CONFIRMED\n" : "NOT STAGE 2\n"
    line14 = vcp_setup ? "VCP FORMING\n" : "\n"
    line15 = "RS = " + str.tostring(math.round(rs_rating)) + "\n"
    line16 = "ATR Contract: " + (vcp_tight ? "YES" : "NO") + "\n"
    line17 = "Vol Dry-Up: " + (vol_dryup ? "YES" : "NO")
    score_txt = line1 + line2 + line3 + line4 + line5 + line6 + line7 + line8 + line9 + line10 + line11 + line12 + line13 + line14 + line15 + line16 + line17
    label.new(bar_index, high, score_txt, style=label.style_label_left, color=full_trend_template ? color.new(color.green, 10) : color.new(color.gray, 20), textcolor=color.white, size=size.normal)

alertcondition(breakout, title="SEPA Breakout Alert", message="SEPA BREAKOUT on {{ticker}} - Price: {{close}} - Volume confirmed - Stage 2 active")
alertcondition(vcp_setup, title="VCP Setup Forming", message="VCP SETUP on {{ticker}} - Volatility contracting, volume drying up.")
alertcondition(full_trend_template, title="Stage 2 Confirmed", message="STAGE 2 CONFIRMED on {{ticker}} - All 8 Trend Template criteria met.")

var table sepa_table = table.new(position.bottom_right, 2, 12, border_width=1, border_color=color.new(color.gray, 50), bgcolor=color.new(color.black, 20))

if barstate.islast
    table.cell(sepa_table, 0, 0,  "METRIC",           text_color=color.yellow, bgcolor=color.new(color.black, 0), text_size=size.small)
    table.cell(sepa_table, 1, 0,  "VALUE",             text_color=color.yellow, bgcolor=color.new(color.black, 0), text_size=size.small)
    table.cell(sepa_table, 0, 1,  "50 SMA",            text_color=color.white, text_size=size.small)
    table.cell(sepa_table, 1, 1,  str.tostring(math.round(ma50,  2)), text_color=close > ma50  ? color.lime : color.red, text_size=size.small)
    table.cell(sepa_table, 0, 2,  "150 SMA",           text_color=color.white, text_size=size.small)
    table.cell(sepa_table, 1, 2,  str.tostring(math.round(ma150, 2)), text_color=close > ma150 ? color.lime : color.red, text_size=size.small)
    table.cell(sepa_table, 0, 3,  "200 SMA",           text_color=color.white, text_size=size.small)
    table.cell(sepa_table, 1, 3,  str.tostring(math.round(ma200, 2)), text_color=close > ma200 ? color.lime : color.red, text_size=size.small)
    table.cell(sepa_table, 0, 4,  "RS Rating",         text_color=color.white, text_size=size.small)
    table.cell(sepa_table, 1, 4,  str.tostring(math.round(rs_rating)), text_color=rs_rating >= rs_min ? color.lime : color.red, text_size=size.small)
    table.cell(sepa_table, 0, 5,  "Pct From 52W Low",  text_color=color.white, text_size=size.small)
    table.cell(sepa_table, 1, 5,  str.tostring(math.round(pct_from_low,  1)) + "%", text_color=tt6 ? color.lime : color.red, text_size=size.small)
    table.cell(sepa_table, 0, 6,  "Pct From 52W High", text_color=color.white, text_size=size.small)
    table.cell(sepa_table, 1, 6,  str.tostring(math.round(pct_from_high, 1)) + "%", text_color=tt7 ? color.lime : color.red, text_size=size.small)
    table.cell(sepa_table, 0, 7,  "ATR Contract",      text_color=color.white, text_size=size.small)
    table.cell(sepa_table, 1, 7,  vcp_tight ? "YES" : "NO", text_color=vcp_tight ? color.lime : color.red, text_size=size.small)
    table.cell(sepa_table, 0, 8,  "Vol Dry-Up",        text_color=color.white, text_size=size.small)
    table.cell(sepa_table, 1, 8,  vol_dryup ? "YES" : "NO", text_color=vol_dryup ? color.lime : color.red, text_size=size.small)
    table.cell(sepa_table, 0, 9,  "SEPA Score",        text_color=color.white, text_size=size.small)
    table.cell(sepa_table, 1, 9,  str.tostring(trend_template_score) + " / 8", text_color=trend_template_score == 8 ? color.lime : color.orange, text_size=size.small)
    table.cell(sepa_table, 0, 10, "Stage 2",           text_color=color.white, text_size=size.small)
    table.cell(sepa_table, 1, 10, full_trend_template ? "YES" : "NO", text_color=full_trend_template ? color.lime : color.red, text_size=size.small)
    table.cell(sepa_table, 0, 11, "VCP Setup",         text_color=color.white, text_size=size.small)
    table.cell(sepa_table, 1, 11, vcp_setup ? "ACTIVE" : "---", text_color=vcp_setup ? color.aqua : color.gray, text_size=size.small)
````

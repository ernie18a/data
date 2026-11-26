# Shift Share - Full Diagnostics & R2

- url: https://www.tradingview.com/script/brEmU6Cg-Shift-Share-Full-Diagnostics-R2/
- type: indicator
- pine_id: PUB;338b9904e84b4237b47600bfdd298b68
- version: 1.0

## Description

📄 Shift Share: Full Diagnostics & R²

Indicator Purpose: 
To perform a "Multivariate Regression" on a stock's returns to see what is driving the price.

█ THE FOUR PERFORMANCE COMPONENTS

The indicator breaks down every price movement into four distinct buckets:
* Market (Beta): Returns driven by the broad market (e.g., SPY).
* Sector (Beta): Returns driven by your specific industry (e.g., XLF for Banks).
* Interaction: Returns caused by the market and sector moving in tandem (synergy).
* Unique (Idiosyncratic): Returns purely specific to the company (news, earnings, management).

█ CORE LOGIC & MATH

The script uses Log Returns and a Rolling Window (default 60 days) to calculate:
* Rolling Beta: It calculates how sensitive the stock is to the Market, Sector, and Interaction over time. This isn't a static number; it adapts as the stock's relationship with the market changes.
* T-Stats: This is a statistical "truth detector." It checks if the relationship is mathematically significant or just "noise."
* R-Squared ($R^2$): A measure of "Model Confidence." An $R^2$ of 0.80 means 80% of the stock's movement is explained by the Market and Sector, while 20% is random or unique.

█ HOW TO INTERPRET THE OUTCOME
1. The Cumulative Lines (The Visual Chart)
  * Total (White): The actual price performance of the stock.
  * Unique (Red): This is the most important line for stock pickers. If the red line is trending up, the company is outperforming its peers regardless of the economy. If it's trending down, the company is "bleeding" value despite what the market is doing.
  * Market/Sector (Blue/Orange): If these are the primary movers, the stock is a "Beta play"—it’s just a passenger on the macro boat.

2. The Diagnostics Table (The Data)
* Share %: Tells you what percentage of the total return was contributed by that specific source.
* [SIG] vs [n.s.]: * [SIG]: Statistically Significant. You can trust that this factor (e.g., the Sector) is actually driving the price.
  * [n.s.]: Not Significant. The relationship is weak; the price moves are likely random noise.
* Model Confidence ($R^2$): If this is low (e.g., < 30%), the "Unique" component is high, meaning the stock is "decoupled" from the market and doing its own thing.

█ LIMITATIONS
* Lookback Bias: Because it uses a rolling window (60 bars), it may take time to "notice" a sudden change in a stock's behavior.
* ETF Choice: The accuracy depends entirely on choosing the correct Sector ETF in the settings. If you use a Tech ETF (XLK) for a Bank stock, the data will be meaningless.

## Source Code

````pine
// © Stephen_F
//@version=5
indicator("Shift Share - Full Diagnostics & R2", overlay=false, max_lines_count=500)

// ---------- Inputs ----------
stock_id  = syminfo.tickerid
sector_id = input.symbol("XLF", "Sector ETF")
market_id = input.symbol("SPY", "Market Index")
win       = input.int(60, "Rolling Window (bars)", minval=20, maxval=252)

col_mkt   = input.color(#2196f3, "Market Color")
col_sec   = input.color(#ff9800, "Sector Color")
col_int   = input.color(#9c27b0, "Interaction Color")
col_idio  = input.color(#f44336, "Unique Color")
col_total = input.color(color.white, "Stock Total Color")
col_r2    = input.color(color.new(color.silver, 50), "R-Squared Line Color")

t_size    = input.string(size.normal, "Table Text Size", options=[size.tiny, size.small, size.normal, size.large, size.huge])
bg_color  = input.color(color.new(#1e222d, 0), "Table Background")

// ---------- Returns ----------
r_stock  = nz(math.log(request.security(stock_id,  timeframe.period, close) / request.security(stock_id,  timeframe.period, close[1])), 0.0)
r_sector = nz(math.log(request.security(sector_id, timeframe.period, close) / request.security(sector_id, timeframe.period, close[1])), 0.0)
r_market = nz(math.log(request.security(market_id, timeframe.period, close) / request.security(market_id, timeframe.period, close[1])), 0.0)
r_int    = r_market * r_sector

// ---------- Rolling Beta Math ----------
ma_s = ta.sma(r_stock, win)
ma_m = ta.sma(r_market, win)
ma_e = ta.sma(r_sector, win)
ma_i = ta.sma(r_int, win)

// Market Beta
cov_m = ta.sma(r_stock * r_market, win) - (ma_s * ma_m)
var_m = ta.sma(r_market * r_market, win) - (ma_m * ma_m)
b_mkt = var_m != 0 ? cov_m / var_m : 0.0

// Sector Beta
cov_e = ta.sma(r_stock * r_sector, win) - (ma_s * ma_e)
var_e = ta.sma(r_sector * r_sector, win) - (ma_e * ma_e)
b_sec = var_e != 0 ? cov_e / var_e : 0.0

// Interaction Beta
cov_i = ta.sma(r_stock * r_int, win) - (ma_s * ma_i)
var_i = ta.sma(r_int * r_int, win) - (ma_i * ma_i)
b_int = var_i != 0 ? cov_i / var_i : 0.0

// ---------- Components ----------
mkt_c  = b_mkt * r_market
sec_c  = b_sec * r_sector
int_c  = b_int * r_int
idio_c = r_stock - (mkt_c + sec_c + int_c)

// ---------- Cumulative Series ----------
cum_stock = ta.cum(r_stock)
cum_mkt   = ta.cum(mkt_c)
cum_sec   = ta.cum(sec_c)
cum_int   = ta.cum(int_c)
cum_idio  = ta.cum(idio_c)

// ---------- R-Squared ----------
ss_res = ta.sma(idio_c * idio_c, win) 
ss_tot = ta.variance(r_stock, win)
r2_val = ss_tot != 0 ? 1 - (ss_res / ss_tot) : 0.0

// ---------- Diagnostic T-Stats ----------
rss    = ta.sma(idio_c * idio_c, win) * win
sigma2 = (win > 4) ? rss / (win - 4) : na

// T-Stat Math (Flattened)
se_m = (not na(sigma2) and (ta.variance(r_market, win) * (win - 1)) > 0) ? math.sqrt(sigma2 / (ta.variance(r_market, win) * (win - 1))) : na
t_mkt = (nz(se_m) != 0) ? b_mkt / se_m : 0.0

se_e = (not na(sigma2) and (ta.variance(r_sector, win) * (win - 1)) > 0) ? math.sqrt(sigma2 / (ta.variance(r_sector, win) * (win - 1))) : na
t_sec = (nz(se_e) != 0) ? b_sec / se_e : 0.0

se_i = (not na(sigma2) and (ta.variance(r_int, win) * (win - 1)) > 0) ? math.sqrt(sigma2 / (ta.variance(r_int, win) * (win - 1))) : na
t_int = (nz(se_i) != 0) ? b_int / se_i : 0.0

sig_m = math.abs(t_mkt) >= 2.0 ? " [SIG]" : " [n.s.]"
sig_e = math.abs(t_sec) >= 2.0 ? " [SIG]" : " [n.s.]"
sig_i = math.abs(t_int) >= 2.0 ? " [SIG]" : " [n.s.]"

// ---------- Plots ----------
plot(cum_stock, "Total",       color=col_total, linewidth=2)
plot(cum_mkt,   "Market",      color=col_mkt)
plot(cum_sec,   "Sector",      color=col_sec)
plot(cum_int,   "Interaction", color=col_int)
plot(cum_idio,  "Unique",      color=col_idio)
plot(r2_val,    "Rolling R2",  color=col_r2, style=plot.style_area, transp=85)

// ---------- Table Logic ----------
// Expanded to 12 rows to prevent index errors
var table t = table.new(position.bottom_center, 5, 12, bgcolor=bg_color, border_width=2, border_color=color.gray)

if barstate.islast
    table.clear(t, 0, 0, 4, 11)
    norm = math.abs(cum_mkt) + math.abs(cum_sec) + math.abs(cum_int) + math.abs(cum_idio)
    h_bg = color.new(color.gray, 50)

    // Headers
    table.cell(t, 0, 0, "Source",      bgcolor=h_bg, text_color=color.white, text_size=t_size)
    table.cell(t, 1, 0, "Abs Return",  bgcolor=h_bg, text_color=color.white, text_size=t_size)
    table.cell(t, 2, 0, "Share %",     bgcolor=h_bg, text_color=color.white, text_size=t_size)
    table.cell(t, 3, 0, "Beta",        bgcolor=h_bg, text_color=color.white, text_size=t_size)
    table.cell(t, 4, 0, "Stock Total", bgcolor=h_bg, text_color=color.white, text_size=t_size)

    // Data Rows
    table.cell(t, 0, 1, "Market",     text_color=col_mkt, text_size=t_size)
    table.cell(t, 1, 1, str.tostring(math.exp(cum_mkt)-1, format.percent), text_color=color.white, text_size=t_size)
    table.cell(t, 2, 1, str.tostring(cum_mkt/norm, format.percent), text_color=color.white, text_size=t_size)
    table.cell(t, 3, 1, str.tostring(b_mkt, "#.##"), text_color=color.white, text_size=t_size)

    table.cell(t, 0, 2, "Sector",     text_color=col_sec, text_size=t_size)
    table.cell(t, 1, 2, str.tostring(math.exp(cum_sec)-1, format.percent), text_color=color.white, text_size=t_size)
    table.cell(t, 2, 2, str.tostring(cum_sec/norm, format.percent), text_color=color.white, text_size=t_size)
    table.cell(t, 3, 2, str.tostring(b_sec, "#.##"), text_color=color.white, text_size=t_size)

    table.cell(t, 0, 3, "Interact",   text_color=col_int, text_size=t_size)
    table.cell(t, 1, 3, str.tostring(math.exp(cum_int)-1, format.percent), text_color=color.white, text_size=t_size)
    table.cell(t, 2, 3, str.tostring(cum_int/norm, format.percent), text_color=color.white, text_size=t_size)
    table.cell(t, 3, 3, str.tostring(b_int, "#.##"), text_color=color.white, text_size=t_size)

    table.cell(t, 0, 4, "Unique",     text_color=col_idio, text_size=t_size)
    table.cell(t, 1, 4, str.tostring(math.exp(cum_idio)-1, format.percent), text_color=color.white, text_size=t_size)
    table.cell(t, 2, 4, str.tostring(cum_idio/norm, format.percent), text_color=color.white, text_size=t_size)
    table.cell(t, 3, 4, "---", text_color=color.white, text_size=t_size)

    table.cell(t, 4, 1, str.tostring(math.exp(cum_stock)-1, format.percent), text_color=col_total, text_size=t_size, bgcolor=color.new(color.gray, 80))
    table.merge_cells(t, 4, 1, 4, 4)

    // --- Expanded Diagnostics ---
    dR = 6
    table.cell(t, 0, dR, "T-Stat Diagnostics & Confidence", bgcolor=h_bg, text_color=color.silver, text_size=size.small)
    table.merge_cells(t, 0, dR, 4, dR)
    
    table.cell(t, 0, dR+1, "Mkt T: " + str.tostring(t_mkt, "#.##") + sig_m, text_color=col_mkt, text_size=t_size)
    table.merge_cells(t, 0, dR+1, 4, dR+1)
    
    table.cell(t, 0, dR+2, "Sec T: " + str.tostring(t_sec, "#.##") + sig_e, text_color=col_sec, text_size=t_size)
    table.merge_cells(t, 0, dR+2, 4, dR+2)

    table.cell(t, 0, dR+3, "Int T: " + str.tostring(t_int, "#.##") + sig_i, text_color=col_int, text_size=t_size)
    table.merge_cells(t, 0, dR+3, 4, dR+3)

    table.cell(t, 0, dR+4, "Model Confidence (R2): " + str.tostring(r2_val * 100, "#.##") + "%", bgcolor=color.new(color.gray, 80), text_color=color.white, text_size=t_size)
    table.merge_cells(t, 0, dR+4, 4, dR+4)
````

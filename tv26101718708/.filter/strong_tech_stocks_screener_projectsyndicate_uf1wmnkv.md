# Strong Tech Stocks Screener | ProjectSyndicate

- url: https://www.tradingview.com/script/UF1WmNKV-Strong-Tech-Stocks-Screener-ProjectSyndicate/
- type: indicator
- pine_id: PUB;561cd28f09954f8a9e65c8ede4cb9a04
- version: 1.0

## Description

[b]Strong Tech Stocks Screener turns dozens of charts into a single institutional-style dashboard, ranking a curated universe of 40 leading tech, AI, and semiconductor names by performance across six timeframes and scoring each one on professional-grade risk metrics — Beta, Sharpe, Sortino, Omega, Z-Score, and Kelly — so you can find the leaders and weigh their risk-adjusted quality at a glance, all on one clean, sortable panel. Every figure is computed live on the daily timeframe from real price history, not hard-coded, so the board reflects the market as it actually is right now.[/b]

📊 Curated 40-Name Tech Universe — the screener watches a hand-picked list of 40 high-momentum tech, AI, and semiconductor stocks in one place. Instead of flipping through forty charts, you see every name's performance and risk profile side by side and immediately spot who is leading and who is rolling over.

🗓️ Six-Timeframe Performance — each stock is tracked across Week, Month, Quarter, 6-Month, 12-Month, and Year-to-Date returns, so you can separate a one-week pop from a genuine long-run trend and see momentum building or fading across horizons in a single row.

🧮 Institutional Risk Metrics, Done Properly — beyond raw returns, every name is scored on Sharpe (excess return per unit of total volatility), Sortino (return per unit of downside risk only), Omega (probability-weighted gains versus losses above the risk-free threshold), Z-Score (how stretched the recent move is in standard deviations), and the Kelly fraction (a theoretical optimal-sizing read from return and variance). The stats are annualized from daily returns over a rolling window with a configurable risk-free rate, so the risk picture is consistent and comparable across the whole list.

🎯 Basket-Relative Beta — Beta is measured against an equal-weight basket of the 40 names in the screener, so it tells you how a stock moves relative to this specific tech/AI cohort rather than a broad index. Beta above 1 swings harder than the group; below 1 is steadier. You control the lookback length used for the beta and correlation calculation.

🌡️ Annualized Weekly Volatility — a dedicated Wk Vol column annualizes the standard deviation of recent weekly returns, giving you a fast read on how violent each name's price action is before you size into it.

🔀 Dynamic Sorting — sort the entire board by any of the six performance columns with a single setting. Rank by YTD to find the year's leaders, by Week to catch what is moving now, or by any horizon in between — the table re-ranks instantly.

🎨 Bloomberg-Amber Theme with Color-Coded Strength — a clean amber-on-black dashboard with a multi-level gradient that runs from bright amber on the strongest gains through to deep red on the steepest losses, so strength and weakness jump out the moment you look at the panel.

🧩 Fully Customizable Dashboard — place the table anywhere on the chart (Top / Middle / Bottom paired with Left / Center / Right), choose your text size (Tiny / Small / Normal / Large), set the sort column, the beta length, and the risk-free rate and periods — all from the settings menu, no code editing required.

🔒 Daily-Timeframe Lock — the screener is built for daily data and will prompt you to switch if you load it on a lower timeframe, so the returns, volatility, and ratios are always calculated on the basis they are designed for.

⚡ Lightweight and Efficient — the whole 40-name board is built from a tight, well-organized script that runs smoothly on TradingView, with a clean merged title heading and an alternating-row layout for easy reading.

🎯 Why this is different — most watchlists show you price and maybe a percentage move. This screener puts performance and a full institutional risk stack — Sharpe, Sortino, Omega, Z-Score, Kelly, Beta, and annualized volatility — for forty leading tech names on one sortable, color-coded panel, so you are ranking opportunities by risk-adjusted quality, not just chasing the biggest green number.

🚀 Where to use it — apply it to any daily chart to monitor the tech/AI/semiconductor leadership group as a whole. Use it for top-down scanning, rotation ideas, and risk screening before you drill into an individual name's chart for entry timing.

⚠️ Important — this is a research and decision-support dashboard, not a buy/sell system, and it makes no performance guarantees. All figures are historical and descriptive, computed from past price data, and say nothing certain about the future. Risk metrics like Sharpe, Sortino, Omega, Z-Score, and Kelly are simplified, assumption-based estimates and should inform your judgment, not replace it. Always pair the screener with your own analysis and risk management.

## Source Code

````pine
//@version=6
indicator("Strong TOP 40 Tech AI Stocks with Advanced Stats", overlay = true, max_bars_back = 504)

// Daily-timeframe guard
if timeframe.in_seconds() > timeframe.in_seconds('1D')
    runtime.error('Please switch to the Daily timeframe chart')

// ============================= INPUTS =============================
yPos        = input.string('Top',   'Table Position', options = ['Top', 'Middle', 'Bottom'], inline = 'p')
xPos        = input.string('Right',  '',              options = ['Right', 'Center', 'Left'],  inline = 'p')
txtSizeIn   = input.string('Normal', 'Text Size',     options = ['Tiny', 'Small', 'Normal', 'Large'])
sortBy      = input.string('YTD%',   'Sort By',       options = ['Week%', 'Mnt%', 'Quarter%', '6Mnt%', '12Mnt%', 'YTD%'])
betaLen     = input.int(60,   'Beta / Correlation Length', minval = 10)
riskFreeRate    = input.float(0.045, 'Risk-Free Rate (Annual)',  minval = 0, maxval = 1, step = 0.001)
riskFreePeriods = input.int(252,     'Risk-Free Periods (Annual)', minval = 1)

txtSize = txtSizeIn == 'Tiny' ? size.tiny : txtSizeIn == 'Small' ? size.small : txtSizeIn == 'Large' ? size.large : size.normal

// Map position strings to the table position constant
tablePos = yPos == 'Top' and xPos == 'Right' ? position.top_right : yPos == 'Top' and xPos == 'Center' ? position.top_center : yPos == 'Top' and xPos == 'Left' ? position.top_left : yPos == 'Middle' and xPos == 'Right' ? position.middle_right : yPos == 'Middle' and xPos == 'Center' ? position.middle_center : yPos == 'Middle' and xPos == 'Left' ? position.middle_left : yPos == 'Bottom' and xPos == 'Right' ? position.bottom_right : yPos == 'Bottom' and xPos == 'Center' ? position.bottom_center : position.bottom_left

// ====================== BLOOMBERG AMBER THEME =====================
C_BG     = #0A0A0A
C_TITLE  = #FFB000
C_HEADER = #FFA028
C_HDR_BG = #1C1206
C_FRAME  = #3A2A0E
C_ROW_A  = #0E0B05
C_ROW_B  = #17110A
C_NUM    = #8A7A52
C_TICKER = #FFC24D
C_NAME   = #C9A86A
C_STAT   = #E0B85E

getRowColor(int row) => row % 2 == 0 ? C_ROW_A : C_ROW_B

getPerfColor(float val) =>
    na(val)     ? #6E6048 :
     val >= 100 ? #FFD23F :
     val >= 50  ? #FFB000 :
     val >= 25  ? #FF9500 :
     val >= 10  ? #E8850E :
     val >= 0   ? #C29A3E :
     val >= -10 ? #C77A4A :
     val >= -25 ? #E0552E : #FF3B30

// Formatters
f_pct(float v) => na(v) ? '-' : str.tostring(v, '#.##') + '%'
f_num(float v) => na(v) ? '-' : str.tostring(v, '#.##')

var table data = table.new(tablePos, 16, 42, C_BG, C_FRAME, 1, C_FRAME, 1)

dailyRf = riskFreeRate / riskFreePeriods

// YTD bar offset: bars since the calendar year last changed (+1 to reach prior-year close)
rawY   = ta.barssince(ta.change(year) != 0)
ytdOff = na(rawY) ? 252 : math.max(1, rawY + 1)

// ===================== 40 SECURITY REQUESTS =======================
// One request.security per symbol (exactly 40 -> within the 40-call limit).
c_1 = request.security('SHAZ', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_2 = request.security('SNDK', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_3 = request.security('RXT', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_4 = request.security('AEHR', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_5 = request.security('ICHR', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_6 = request.security('AXTI', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_7 = request.security('MXL', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_8 = request.security('UCTT', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_9 = request.security('AAOI', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_10 = request.security('VSH', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_11 = request.security('WDC', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_12 = request.security('OPTX', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_13 = request.security('ATOM', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_14 = request.security('MU', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_15 = request.security('STX', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_16 = request.security('VPG', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_17 = request.security('MRVL', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_18 = request.security('QUIK', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_19 = request.security('INTC', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_20 = request.security('DOCN', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_21 = request.security('PENG', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_22 = request.security('NVTS', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_23 = request.security('BAND', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_24 = request.security('WOLF', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_25 = request.security('SVCO', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_26 = request.security('DELL', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_27 = request.security('AMBQ', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_28 = request.security('TTMI', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_29 = request.security('VICR', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_30 = request.security('COHU', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_31 = request.security('MRAM', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_32 = request.security('BRUN', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_33 = request.security('AIP', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_34 = request.security('VECO', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_35 = request.security('ACMR', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_36 = request.security('CHRN', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_37 = request.security('FORM', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_38 = request.security('KEEL', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_39 = request.security('KLIC', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
c_40 = request.security('VIAV', 'D', close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)

// ===================== PER-SYMBOL CALCULATIONS ====================
// --- SHAZ ---
r_1   = c_1[1] != 0 ? (c_1 - c_1[1]) / c_1[1] : na
md_1  = ta.sma(r_1, 252)
sd_1  = ta.stdev(r_1, 252)
dn_1  = math.sqrt(ta.sma(math.pow(math.min(r_1, 0.0), 2), 252))
og_1  = ta.sma(math.max(r_1 - dailyRf, 0.0), 252)
ol_1  = ta.sma(math.max(dailyRf - r_1, 0.0), 252)
wv_1  = ta.stdev(r_1, 5) * math.sqrt(252) * 100
wk_1  = c_1[5]      != 0 ? (c_1 - c_1[5])      / c_1[5]      * 100 : na
mo_1  = c_1[21]     != 0 ? (c_1 - c_1[21])     / c_1[21]     * 100 : na
qt_1  = c_1[63]     != 0 ? (c_1 - c_1[63])     / c_1[63]     * 100 : na
hf_1  = c_1[126]    != 0 ? (c_1 - c_1[126])    / c_1[126]    * 100 : na
yr_1  = c_1[252]    != 0 ? (c_1 - c_1[252])    / c_1[252]    * 100 : na
yt_1  = c_1[ytdOff] != 0 ? (c_1 - c_1[ytdOff]) / c_1[ytdOff] * 100 : na
// --- SNDK ---
r_2   = c_2[1] != 0 ? (c_2 - c_2[1]) / c_2[1] : na
md_2  = ta.sma(r_2, 252)
sd_2  = ta.stdev(r_2, 252)
dn_2  = math.sqrt(ta.sma(math.pow(math.min(r_2, 0.0), 2), 252))
og_2  = ta.sma(math.max(r_2 - dailyRf, 0.0), 252)
ol_2  = ta.sma(math.max(dailyRf - r_2, 0.0), 252)
wv_2  = ta.stdev(r_2, 5) * math.sqrt(252) * 100
wk_2  = c_2[5]      != 0 ? (c_2 - c_2[5])      / c_2[5]      * 100 : na
mo_2  = c_2[21]     != 0 ? (c_2 - c_2[21])     / c_2[21]     * 100 : na
qt_2  = c_2[63]     != 0 ? (c_2 - c_2[63])     / c_2[63]     * 100 : na
hf_2  = c_2[126]    != 0 ? (c_2 - c_2[126])    / c_2[126]    * 100 : na
yr_2  = c_2[252]    != 0 ? (c_2 - c_2[252])    / c_2[252]    * 100 : na
yt_2  = c_2[ytdOff] != 0 ? (c_2 - c_2[ytdOff]) / c_2[ytdOff] * 100 : na
// --- RXT ---
r_3   = c_3[1] != 0 ? (c_3 - c_3[1]) / c_3[1] : na
md_3  = ta.sma(r_3, 252)
sd_3  = ta.stdev(r_3, 252)
dn_3  = math.sqrt(ta.sma(math.pow(math.min(r_3, 0.0), 2), 252))
og_3  = ta.sma(math.max(r_3 - dailyRf, 0.0), 252)
ol_3  = ta.sma(math.max(dailyRf - r_3, 0.0), 252)
wv_3  = ta.stdev(r_3, 5) * math.sqrt(252) * 100
wk_3  = c_3[5]      != 0 ? (c_3 - c_3[5])      / c_3[5]      * 100 : na
mo_3  = c_3[21]     != 0 ? (c_3 - c_3[21])     / c_3[21]     * 100 : na
qt_3  = c_3[63]     != 0 ? (c_3 - c_3[63])     / c_3[63]     * 100 : na
hf_3  = c_3[126]    != 0 ? (c_3 - c_3[126])    / c_3[126]    * 100 : na
yr_3  = c_3[252]    != 0 ? (c_3 - c_3[252])    / c_3[252]    * 100 : na
yt_3  = c_3[ytdOff] != 0 ? (c_3 - c_3[ytdOff]) / c_3[ytdOff] * 100 : na
// --- AEHR ---
r_4   = c_4[1] != 0 ? (c_4 - c_4[1]) / c_4[1] : na
md_4  = ta.sma(r_4, 252)
sd_4  = ta.stdev(r_4, 252)
dn_4  = math.sqrt(ta.sma(math.pow(math.min(r_4, 0.0), 2), 252))
og_4  = ta.sma(math.max(r_4 - dailyRf, 0.0), 252)
ol_4  = ta.sma(math.max(dailyRf - r_4, 0.0), 252)
wv_4  = ta.stdev(r_4, 5) * math.sqrt(252) * 100
wk_4  = c_4[5]      != 0 ? (c_4 - c_4[5])      / c_4[5]      * 100 : na
mo_4  = c_4[21]     != 0 ? (c_4 - c_4[21])     / c_4[21]     * 100 : na
qt_4  = c_4[63]     != 0 ? (c_4 - c_4[63])     / c_4[63]     * 100 : na
hf_4  = c_4[126]    != 0 ? (c_4 - c_4[126])    / c_4[126]    * 100 : na
yr_4  = c_4[252]    != 0 ? (c_4 - c_4[252])    / c_4[252]    * 100 : na
yt_4  = c_4[ytdOff] != 0 ? (c_4 - c_4[ytdOff]) / c_4[ytdOff] * 100 : na
// --- ICHR ---
r_5   = c_5[1] != 0 ? (c_5 - c_5[1]) / c_5[1] : na
md_5  = ta.sma(r_5, 252)
sd_5  = ta.stdev(r_5, 252)
dn_5  = math.sqrt(ta.sma(math.pow(math.min(r_5, 0.0), 2), 252))
og_5  = ta.sma(math.max(r_5 - dailyRf, 0.0), 252)
ol_5  = ta.sma(math.max(dailyRf - r_5, 0.0), 252)
wv_5  = ta.stdev(r_5, 5) * math.sqrt(252) * 100
wk_5  = c_5[5]      != 0 ? (c_5 - c_5[5])      / c_5[5]      * 100 : na
mo_5  = c_5[21]     != 0 ? (c_5 - c_5[21])     / c_5[21]     * 100 : na
qt_5  = c_5[63]     != 0 ? (c_5 - c_5[63])     / c_5[63]     * 100 : na
hf_5  = c_5[126]    != 0 ? (c_5 - c_5[126])    / c_5[126]    * 100 : na
yr_5  = c_5[252]    != 0 ? (c_5 - c_5[252])    / c_5[252]    * 100 : na
yt_5  = c_5[ytdOff] != 0 ? (c_5 - c_5[ytdOff]) / c_5[ytdOff] * 100 : na
// --- AXTI ---
r_6   = c_6[1] != 0 ? (c_6 - c_6[1]) / c_6[1] : na
md_6  = ta.sma(r_6, 252)
sd_6  = ta.stdev(r_6, 252)
dn_6  = math.sqrt(ta.sma(math.pow(math.min(r_6, 0.0), 2), 252))
og_6  = ta.sma(math.max(r_6 - dailyRf, 0.0), 252)
ol_6  = ta.sma(math.max(dailyRf - r_6, 0.0), 252)
wv_6  = ta.stdev(r_6, 5) * math.sqrt(252) * 100
wk_6  = c_6[5]      != 0 ? (c_6 - c_6[5])      / c_6[5]      * 100 : na
mo_6  = c_6[21]     != 0 ? (c_6 - c_6[21])     / c_6[21]     * 100 : na
qt_6  = c_6[63]     != 0 ? (c_6 - c_6[63])     / c_6[63]     * 100 : na
hf_6  = c_6[126]    != 0 ? (c_6 - c_6[126])    / c_6[126]    * 100 : na
yr_6  = c_6[252]    != 0 ? (c_6 - c_6[252])    / c_6[252]    * 100 : na
yt_6  = c_6[ytdOff] != 0 ? (c_6 - c_6[ytdOff]) / c_6[ytdOff] * 100 : na
// --- MXL ---
r_7   = c_7[1] != 0 ? (c_7 - c_7[1]) / c_7[1] : na
md_7  = ta.sma(r_7, 252)
sd_7  = ta.stdev(r_7, 252)
dn_7  = math.sqrt(ta.sma(math.pow(math.min(r_7, 0.0), 2), 252))
og_7  = ta.sma(math.max(r_7 - dailyRf, 0.0), 252)
ol_7  = ta.sma(math.max(dailyRf - r_7, 0.0), 252)
wv_7  = ta.stdev(r_7, 5) * math.sqrt(252) * 100
wk_7  = c_7[5]      != 0 ? (c_7 - c_7[5])      / c_7[5]      * 100 : na
mo_7  = c_7[21]     != 0 ? (c_7 - c_7[21])     / c_7[21]     * 100 : na
qt_7  = c_7[63]     != 0 ? (c_7 - c_7[63])     / c_7[63]     * 100 : na
hf_7  = c_7[126]    != 0 ? (c_7 - c_7[126])    / c_7[126]    * 100 : na
yr_7  = c_7[252]    != 0 ? (c_7 - c_7[252])    / c_7[252]    * 100 : na
yt_7  = c_7[ytdOff] != 0 ? (c_7 - c_7[ytdOff]) / c_7[ytdOff] * 100 : na
// --- UCTT ---
r_8   = c_8[1] != 0 ? (c_8 - c_8[1]) / c_8[1] : na
md_8  = ta.sma(r_8, 252)
sd_8  = ta.stdev(r_8, 252)
dn_8  = math.sqrt(ta.sma(math.pow(math.min(r_8, 0.0), 2), 252))
og_8  = ta.sma(math.max(r_8 - dailyRf, 0.0), 252)
ol_8  = ta.sma(math.max(dailyRf - r_8, 0.0), 252)
wv_8  = ta.stdev(r_8, 5) * math.sqrt(252) * 100
wk_8  = c_8[5]      != 0 ? (c_8 - c_8[5])      / c_8[5]      * 100 : na
mo_8  = c_8[21]     != 0 ? (c_8 - c_8[21])     / c_8[21]     * 100 : na
qt_8  = c_8[63]     != 0 ? (c_8 - c_8[63])     / c_8[63]     * 100 : na
hf_8  = c_8[126]    != 0 ? (c_8 - c_8[126])    / c_8[126]    * 100 : na
yr_8  = c_8[252]    != 0 ? (c_8 - c_8[252])    / c_8[252]    * 100 : na
yt_8  = c_8[ytdOff] != 0 ? (c_8 - c_8[ytdOff]) / c_8[ytdOff] * 100 : na
// --- AAOI ---
r_9   = c_9[1] != 0 ? (c_9 - c_9[1]) / c_9[1] : na
md_9  = ta.sma(r_9, 252)
sd_9  = ta.stdev(r_9, 252)
dn_9  = math.sqrt(ta.sma(math.pow(math.min(r_9, 0.0), 2), 252))
og_9  = ta.sma(math.max(r_9 - dailyRf, 0.0), 252)
ol_9  = ta.sma(math.max(dailyRf - r_9, 0.0), 252)
wv_9  = ta.stdev(r_9, 5) * math.sqrt(252) * 100
wk_9  = c_9[5]      != 0 ? (c_9 - c_9[5])      / c_9[5]      * 100 : na
mo_9  = c_9[21]     != 0 ? (c_9 - c_9[21])     / c_9[21]     * 100 : na
qt_9  = c_9[63]     != 0 ? (c_9 - c_9[63])     / c_9[63]     * 100 : na
hf_9  = c_9[126]    != 0 ? (c_9 - c_9[126])    / c_9[126]    * 100 : na
yr_9  = c_9[252]    != 0 ? (c_9 - c_9[252])    / c_9[252]    * 100 : na
yt_9  = c_9[ytdOff] != 0 ? (c_9 - c_9[ytdOff]) / c_9[ytdOff] * 100 : na
// --- VSH ---
r_10   = c_10[1] != 0 ? (c_10 - c_10[1]) / c_10[1] : na
md_10  = ta.sma(r_10, 252)
sd_10  = ta.stdev(r_10, 252)
dn_10  = math.sqrt(ta.sma(math.pow(math.min(r_10, 0.0), 2), 252))
og_10  = ta.sma(math.max(r_10 - dailyRf, 0.0), 252)
ol_10  = ta.sma(math.max(dailyRf - r_10, 0.0), 252)
wv_10  = ta.stdev(r_10, 5) * math.sqrt(252) * 100
wk_10  = c_10[5]      != 0 ? (c_10 - c_10[5])      / c_10[5]      * 100 : na
mo_10  = c_10[21]     != 0 ? (c_10 - c_10[21])     / c_10[21]     * 100 : na
qt_10  = c_10[63]     != 0 ? (c_10 - c_10[63])     / c_10[63]     * 100 : na
hf_10  = c_10[126]    != 0 ? (c_10 - c_10[126])    / c_10[126]    * 100 : na
yr_10  = c_10[252]    != 0 ? (c_10 - c_10[252])    / c_10[252]    * 100 : na
yt_10  = c_10[ytdOff] != 0 ? (c_10 - c_10[ytdOff]) / c_10[ytdOff] * 100 : na
// --- WDC ---
r_11   = c_11[1] != 0 ? (c_11 - c_11[1]) / c_11[1] : na
md_11  = ta.sma(r_11, 252)
sd_11  = ta.stdev(r_11, 252)
dn_11  = math.sqrt(ta.sma(math.pow(math.min(r_11, 0.0), 2), 252))
og_11  = ta.sma(math.max(r_11 - dailyRf, 0.0), 252)
ol_11  = ta.sma(math.max(dailyRf - r_11, 0.0), 252)
wv_11  = ta.stdev(r_11, 5) * math.sqrt(252) * 100
wk_11  = c_11[5]      != 0 ? (c_11 - c_11[5])      / c_11[5]      * 100 : na
mo_11  = c_11[21]     != 0 ? (c_11 - c_11[21])     / c_11[21]     * 100 : na
qt_11  = c_11[63]     != 0 ? (c_11 - c_11[63])     / c_11[63]     * 100 : na
hf_11  = c_11[126]    != 0 ? (c_11 - c_11[126])    / c_11[126]    * 100 : na
yr_11  = c_11[252]    != 0 ? (c_11 - c_11[252])    / c_11[252]    * 100 : na
yt_11  = c_11[ytdOff] != 0 ? (c_11 - c_11[ytdOff]) / c_11[ytdOff] * 100 : na
// --- OPTX ---
r_12   = c_12[1] != 0 ? (c_12 - c_12[1]) / c_12[1] : na
md_12  = ta.sma(r_12, 252)
sd_12  = ta.stdev(r_12, 252)
dn_12  = math.sqrt(ta.sma(math.pow(math.min(r_12, 0.0), 2), 252))
og_12  = ta.sma(math.max(r_12 - dailyRf, 0.0), 252)
ol_12  = ta.sma(math.max(dailyRf - r_12, 0.0), 252)
wv_12  = ta.stdev(r_12, 5) * math.sqrt(252) * 100
wk_12  = c_12[5]      != 0 ? (c_12 - c_12[5])      / c_12[5]      * 100 : na
mo_12  = c_12[21]     != 0 ? (c_12 - c_12[21])     / c_12[21]     * 100 : na
qt_12  = c_12[63]     != 0 ? (c_12 - c_12[63])     / c_12[63]     * 100 : na
hf_12  = c_12[126]    != 0 ? (c_12 - c_12[126])    / c_12[126]    * 100 : na
yr_12  = c_12[252]    != 0 ? (c_12 - c_12[252])    / c_12[252]    * 100 : na
yt_12  = c_12[ytdOff] != 0 ? (c_12 - c_12[ytdOff]) / c_12[ytdOff] * 100 : na
// --- ATOM ---
r_13   = c_13[1] != 0 ? (c_13 - c_13[1]) / c_13[1] : na
md_13  = ta.sma(r_13, 252)
sd_13  = ta.stdev(r_13, 252)
dn_13  = math.sqrt(ta.sma(math.pow(math.min(r_13, 0.0), 2), 252))
og_13  = ta.sma(math.max(r_13 - dailyRf, 0.0), 252)
ol_13  = ta.sma(math.max(dailyRf - r_13, 0.0), 252)
wv_13  = ta.stdev(r_13, 5) * math.sqrt(252) * 100
wk_13  = c_13[5]      != 0 ? (c_13 - c_13[5])      / c_13[5]      * 100 : na
mo_13  = c_13[21]     != 0 ? (c_13 - c_13[21])     / c_13[21]     * 100 : na
qt_13  = c_13[63]     != 0 ? (c_13 - c_13[63])     / c_13[63]     * 100 : na
hf_13  = c_13[126]    != 0 ? (c_13 - c_13[126])    / c_13[126]    * 100 : na
yr_13  = c_13[252]    != 0 ? (c_13 - c_13[252])    / c_13[252]    * 100 : na
yt_13  = c_13[ytdOff] != 0 ? (c_13 - c_13[ytdOff]) / c_13[ytdOff] * 100 : na
// --- MU ---
r_14   = c_14[1] != 0 ? (c_14 - c_14[1]) / c_14[1] : na
md_14  = ta.sma(r_14, 252)
sd_14  = ta.stdev(r_14, 252)
dn_14  = math.sqrt(ta.sma(math.pow(math.min(r_14, 0.0), 2), 252))
og_14  = ta.sma(math.max(r_14 - dailyRf, 0.0), 252)
ol_14  = ta.sma(math.max(dailyRf - r_14, 0.0), 252)
wv_14  = ta.stdev(r_14, 5) * math.sqrt(252) * 100
wk_14  = c_14[5]      != 0 ? (c_14 - c_14[5])      / c_14[5]      * 100 : na
mo_14  = c_14[21]     != 0 ? (c_14 - c_14[21])     / c_14[21]     * 100 : na
qt_14  = c_14[63]     != 0 ? (c_14 - c_14[63])     / c_14[63]     * 100 : na
hf_14  = c_14[126]    != 0 ? (c_14 - c_14[126])    / c_14[126]    * 100 : na
yr_14  = c_14[252]    != 0 ? (c_14 - c_14[252])    / c_14[252]    * 100 : na
yt_14  = c_14[ytdOff] != 0 ? (c_14 - c_14[ytdOff]) / c_14[ytdOff] * 100 : na
// --- STX ---
r_15   = c_15[1] != 0 ? (c_15 - c_15[1]) / c_15[1] : na
md_15  = ta.sma(r_15, 252)
sd_15  = ta.stdev(r_15, 252)
dn_15  = math.sqrt(ta.sma(math.pow(math.min(r_15, 0.0), 2), 252))
og_15  = ta.sma(math.max(r_15 - dailyRf, 0.0), 252)
ol_15  = ta.sma(math.max(dailyRf - r_15, 0.0), 252)
wv_15  = ta.stdev(r_15, 5) * math.sqrt(252) * 100
wk_15  = c_15[5]      != 0 ? (c_15 - c_15[5])      / c_15[5]      * 100 : na
mo_15  = c_15[21]     != 0 ? (c_15 - c_15[21])     / c_15[21]     * 100 : na
qt_15  = c_15[63]     != 0 ? (c_15 - c_15[63])     / c_15[63]     * 100 : na
hf_15  = c_15[126]    != 0 ? (c_15 - c_15[126])    / c_15[126]    * 100 : na
yr_15  = c_15[252]    != 0 ? (c_15 - c_15[252])    / c_15[252]    * 100 : na
yt_15  = c_15[ytdOff] != 0 ? (c_15 - c_15[ytdOff]) / c_15[ytdOff] * 100 : na
// --- VPG ---
r_16   = c_16[1] != 0 ? (c_16 - c_16[1]) / c_16[1] : na
md_16  = ta.sma(r_16, 252)
sd_16  = ta.stdev(r_16, 252)
dn_16  = math.sqrt(ta.sma(math.pow(math.min(r_16, 0.0), 2), 252))
og_16  = ta.sma(math.max(r_16 - dailyRf, 0.0), 252)
ol_16  = ta.sma(math.max(dailyRf - r_16, 0.0), 252)
wv_16  = ta.stdev(r_16, 5) * math.sqrt(252) * 100
wk_16  = c_16[5]      != 0 ? (c_16 - c_16[5])      / c_16[5]      * 100 : na
mo_16  = c_16[21]     != 0 ? (c_16 - c_16[21])     / c_16[21]     * 100 : na
qt_16  = c_16[63]     != 0 ? (c_16 - c_16[63])     / c_16[63]     * 100 : na
hf_16  = c_16[126]    != 0 ? (c_16 - c_16[126])    / c_16[126]    * 100 : na
yr_16  = c_16[252]    != 0 ? (c_16 - c_16[252])    / c_16[252]    * 100 : na
yt_16  = c_16[ytdOff] != 0 ? (c_16 - c_16[ytdOff]) / c_16[ytdOff] * 100 : na
// --- MRVL ---
r_17   = c_17[1] != 0 ? (c_17 - c_17[1]) / c_17[1] : na
md_17  = ta.sma(r_17, 252)
sd_17  = ta.stdev(r_17, 252)
dn_17  = math.sqrt(ta.sma(math.pow(math.min(r_17, 0.0), 2), 252))
og_17  = ta.sma(math.max(r_17 - dailyRf, 0.0), 252)
ol_17  = ta.sma(math.max(dailyRf - r_17, 0.0), 252)
wv_17  = ta.stdev(r_17, 5) * math.sqrt(252) * 100
wk_17  = c_17[5]      != 0 ? (c_17 - c_17[5])      / c_17[5]      * 100 : na
mo_17  = c_17[21]     != 0 ? (c_17 - c_17[21])     / c_17[21]     * 100 : na
qt_17  = c_17[63]     != 0 ? (c_17 - c_17[63])     / c_17[63]     * 100 : na
hf_17  = c_17[126]    != 0 ? (c_17 - c_17[126])    / c_17[126]    * 100 : na
yr_17  = c_17[252]    != 0 ? (c_17 - c_17[252])    / c_17[252]    * 100 : na
yt_17  = c_17[ytdOff] != 0 ? (c_17 - c_17[ytdOff]) / c_17[ytdOff] * 100 : na
// --- QUIK ---
r_18   = c_18[1] != 0 ? (c_18 - c_18[1]) / c_18[1] : na
md_18  = ta.sma(r_18, 252)
sd_18  = ta.stdev(r_18, 252)
dn_18  = math.sqrt(ta.sma(math.pow(math.min(r_18, 0.0), 2), 252))
og_18  = ta.sma(math.max(r_18 - dailyRf, 0.0), 252)
ol_18  = ta.sma(math.max(dailyRf - r_18, 0.0), 252)
wv_18  = ta.stdev(r_18, 5) * math.sqrt(252) * 100
wk_18  = c_18[5]      != 0 ? (c_18 - c_18[5])      / c_18[5]      * 100 : na
mo_18  = c_18[21]     != 0 ? (c_18 - c_18[21])     / c_18[21]     * 100 : na
qt_18  = c_18[63]     != 0 ? (c_18 - c_18[63])     / c_18[63]     * 100 : na
hf_18  = c_18[126]    != 0 ? (c_18 - c_18[126])    / c_18[126]    * 100 : na
yr_18  = c_18[252]    != 0 ? (c_18 - c_18[252])    / c_18[252]    * 100 : na
yt_18  = c_18[ytdOff] != 0 ? (c_18 - c_18[ytdOff]) / c_18[ytdOff] * 100 : na
// --- INTC ---
r_19   = c_19[1] != 0 ? (c_19 - c_19[1]) / c_19[1] : na
md_19  = ta.sma(r_19, 252)
sd_19  = ta.stdev(r_19, 252)
dn_19  = math.sqrt(ta.sma(math.pow(math.min(r_19, 0.0), 2), 252))
og_19  = ta.sma(math.max(r_19 - dailyRf, 0.0), 252)
ol_19  = ta.sma(math.max(dailyRf - r_19, 0.0), 252)
wv_19  = ta.stdev(r_19, 5) * math.sqrt(252) * 100
wk_19  = c_19[5]      != 0 ? (c_19 - c_19[5])      / c_19[5]      * 100 : na
mo_19  = c_19[21]     != 0 ? (c_19 - c_19[21])     / c_19[21]     * 100 : na
qt_19  = c_19[63]     != 0 ? (c_19 - c_19[63])     / c_19[63]     * 100 : na
hf_19  = c_19[126]    != 0 ? (c_19 - c_19[126])    / c_19[126]    * 100 : na
yr_19  = c_19[252]    != 0 ? (c_19 - c_19[252])    / c_19[252]    * 100 : na
yt_19  = c_19[ytdOff] != 0 ? (c_19 - c_19[ytdOff]) / c_19[ytdOff] * 100 : na
// --- DOCN ---
r_20   = c_20[1] != 0 ? (c_20 - c_20[1]) / c_20[1] : na
md_20  = ta.sma(r_20, 252)
sd_20  = ta.stdev(r_20, 252)
dn_20  = math.sqrt(ta.sma(math.pow(math.min(r_20, 0.0), 2), 252))
og_20  = ta.sma(math.max(r_20 - dailyRf, 0.0), 252)
ol_20  = ta.sma(math.max(dailyRf - r_20, 0.0), 252)
wv_20  = ta.stdev(r_20, 5) * math.sqrt(252) * 100
wk_20  = c_20[5]      != 0 ? (c_20 - c_20[5])      / c_20[5]      * 100 : na
mo_20  = c_20[21]     != 0 ? (c_20 - c_20[21])     / c_20[21]     * 100 : na
qt_20  = c_20[63]     != 0 ? (c_20 - c_20[63])     / c_20[63]     * 100 : na
hf_20  = c_20[126]    != 0 ? (c_20 - c_20[126])    / c_20[126]    * 100 : na
yr_20  = c_20[252]    != 0 ? (c_20 - c_20[252])    / c_20[252]    * 100 : na
yt_20  = c_20[ytdOff] != 0 ? (c_20 - c_20[ytdOff]) / c_20[ytdOff] * 100 : na
// --- PENG ---
r_21   = c_21[1] != 0 ? (c_21 - c_21[1]) / c_21[1] : na
md_21  = ta.sma(r_21, 252)
sd_21  = ta.stdev(r_21, 252)
dn_21  = math.sqrt(ta.sma(math.pow(math.min(r_21, 0.0), 2), 252))
og_21  = ta.sma(math.max(r_21 - dailyRf, 0.0), 252)
ol_21  = ta.sma(math.max(dailyRf - r_21, 0.0), 252)
wv_21  = ta.stdev(r_21, 5) * math.sqrt(252) * 100
wk_21  = c_21[5]      != 0 ? (c_21 - c_21[5])      / c_21[5]      * 100 : na
mo_21  = c_21[21]     != 0 ? (c_21 - c_21[21])     / c_21[21]     * 100 : na
qt_21  = c_21[63]     != 0 ? (c_21 - c_21[63])     / c_21[63]     * 100 : na
hf_21  = c_21[126]    != 0 ? (c_21 - c_21[126])    / c_21[126]    * 100 : na
yr_21  = c_21[252]    != 0 ? (c_21 - c_21[252])    / c_21[252]    * 100 : na
yt_21  = c_21[ytdOff] != 0 ? (c_21 - c_21[ytdOff]) / c_21[ytdOff] * 100 : na
// --- NVTS ---
r_22   = c_22[1] != 0 ? (c_22 - c_22[1]) / c_22[1] : na
md_22  = ta.sma(r_22, 252)
sd_22  = ta.stdev(r_22, 252)
dn_22  = math.sqrt(ta.sma(math.pow(math.min(r_22, 0.0), 2), 252))
og_22  = ta.sma(math.max(r_22 - dailyRf, 0.0), 252)
ol_22  = ta.sma(math.max(dailyRf - r_22, 0.0), 252)
wv_22  = ta.stdev(r_22, 5) * math.sqrt(252) * 100
wk_22  = c_22[5]      != 0 ? (c_22 - c_22[5])      / c_22[5]      * 100 : na
mo_22  = c_22[21]     != 0 ? (c_22 - c_22[21])     / c_22[21]     * 100 : na
qt_22  = c_22[63]     != 0 ? (c_22 - c_22[63])     / c_22[63]     * 100 : na
hf_22  = c_22[126]    != 0 ? (c_22 - c_22[126])    / c_22[126]    * 100 : na
yr_22  = c_22[252]    != 0 ? (c_22 - c_22[252])    / c_22[252]    * 100 : na
yt_22  = c_22[ytdOff] != 0 ? (c_22 - c_22[ytdOff]) / c_22[ytdOff] * 100 : na
// --- BAND ---
r_23   = c_23[1] != 0 ? (c_23 - c_23[1]) / c_23[1] : na
md_23  = ta.sma(r_23, 252)
sd_23  = ta.stdev(r_23, 252)
dn_23  = math.sqrt(ta.sma(math.pow(math.min(r_23, 0.0), 2), 252))
og_23  = ta.sma(math.max(r_23 - dailyRf, 0.0), 252)
ol_23  = ta.sma(math.max(dailyRf - r_23, 0.0), 252)
wv_23  = ta.stdev(r_23, 5) * math.sqrt(252) * 100
wk_23  = c_23[5]      != 0 ? (c_23 - c_23[5])      / c_23[5]      * 100 : na
mo_23  = c_23[21]     != 0 ? (c_23 - c_23[21])     / c_23[21]     * 100 : na
qt_23  = c_23[63]     != 0 ? (c_23 - c_23[63])     / c_23[63]     * 100 : na
hf_23  = c_23[126]    != 0 ? (c_23 - c_23[126])    / c_23[126]    * 100 : na
yr_23  = c_23[252]    != 0 ? (c_23 - c_23[252])    / c_23[252]    * 100 : na
yt_23  = c_23[ytdOff] != 0 ? (c_23 - c_23[ytdOff]) / c_23[ytdOff] * 100 : na
// --- WOLF ---
r_24   = c_24[1] != 0 ? (c_24 - c_24[1]) / c_24[1] : na
md_24  = ta.sma(r_24, 252)
sd_24  = ta.stdev(r_24, 252)
dn_24  = math.sqrt(ta.sma(math.pow(math.min(r_24, 0.0), 2), 252))
og_24  = ta.sma(math.max(r_24 - dailyRf, 0.0), 252)
ol_24  = ta.sma(math.max(dailyRf - r_24, 0.0), 252)
wv_24  = ta.stdev(r_24, 5) * math.sqrt(252) * 100
wk_24  = c_24[5]      != 0 ? (c_24 - c_24[5])      / c_24[5]      * 100 : na
mo_24  = c_24[21]     != 0 ? (c_24 - c_24[21])     / c_24[21]     * 100 : na
qt_24  = c_24[63]     != 0 ? (c_24 - c_24[63])     / c_24[63]     * 100 : na
hf_24  = c_24[126]    != 0 ? (c_24 - c_24[126])    / c_24[126]    * 100 : na
yr_24  = c_24[252]    != 0 ? (c_24 - c_24[252])    / c_24[252]    * 100 : na
yt_24  = c_24[ytdOff] != 0 ? (c_24 - c_24[ytdOff]) / c_24[ytdOff] * 100 : na
// --- SVCO ---
r_25   = c_25[1] != 0 ? (c_25 - c_25[1]) / c_25[1] : na
md_25  = ta.sma(r_25, 252)
sd_25  = ta.stdev(r_25, 252)
dn_25  = math.sqrt(ta.sma(math.pow(math.min(r_25, 0.0), 2), 252))
og_25  = ta.sma(math.max(r_25 - dailyRf, 0.0), 252)
ol_25  = ta.sma(math.max(dailyRf - r_25, 0.0), 252)
wv_25  = ta.stdev(r_25, 5) * math.sqrt(252) * 100
wk_25  = c_25[5]      != 0 ? (c_25 - c_25[5])      / c_25[5]      * 100 : na
mo_25  = c_25[21]     != 0 ? (c_25 - c_25[21])     / c_25[21]     * 100 : na
qt_25  = c_25[63]     != 0 ? (c_25 - c_25[63])     / c_25[63]     * 100 : na
hf_25  = c_25[126]    != 0 ? (c_25 - c_25[126])    / c_25[126]    * 100 : na
yr_25  = c_25[252]    != 0 ? (c_25 - c_25[252])    / c_25[252]    * 100 : na
yt_25  = c_25[ytdOff] != 0 ? (c_25 - c_25[ytdOff]) / c_25[ytdOff] * 100 : na
// --- DELL ---
r_26   = c_26[1] != 0 ? (c_26 - c_26[1]) / c_26[1] : na
md_26  = ta.sma(r_26, 252)
sd_26  = ta.stdev(r_26, 252)
dn_26  = math.sqrt(ta.sma(math.pow(math.min(r_26, 0.0), 2), 252))
og_26  = ta.sma(math.max(r_26 - dailyRf, 0.0), 252)
ol_26  = ta.sma(math.max(dailyRf - r_26, 0.0), 252)
wv_26  = ta.stdev(r_26, 5) * math.sqrt(252) * 100
wk_26  = c_26[5]      != 0 ? (c_26 - c_26[5])      / c_26[5]      * 100 : na
mo_26  = c_26[21]     != 0 ? (c_26 - c_26[21])     / c_26[21]     * 100 : na
qt_26  = c_26[63]     != 0 ? (c_26 - c_26[63])     / c_26[63]     * 100 : na
hf_26  = c_26[126]    != 0 ? (c_26 - c_26[126])    / c_26[126]    * 100 : na
yr_26  = c_26[252]    != 0 ? (c_26 - c_26[252])    / c_26[252]    * 100 : na
yt_26  = c_26[ytdOff] != 0 ? (c_26 - c_26[ytdOff]) / c_26[ytdOff] * 100 : na
// --- AMBQ ---
r_27   = c_27[1] != 0 ? (c_27 - c_27[1]) / c_27[1] : na
md_27  = ta.sma(r_27, 252)
sd_27  = ta.stdev(r_27, 252)
dn_27  = math.sqrt(ta.sma(math.pow(math.min(r_27, 0.0), 2), 252))
og_27  = ta.sma(math.max(r_27 - dailyRf, 0.0), 252)
ol_27  = ta.sma(math.max(dailyRf - r_27, 0.0), 252)
wv_27  = ta.stdev(r_27, 5) * math.sqrt(252) * 100
wk_27  = c_27[5]      != 0 ? (c_27 - c_27[5])      / c_27[5]      * 100 : na
mo_27  = c_27[21]     != 0 ? (c_27 - c_27[21])     / c_27[21]     * 100 : na
qt_27  = c_27[63]     != 0 ? (c_27 - c_27[63])     / c_27[63]     * 100 : na
hf_27  = c_27[126]    != 0 ? (c_27 - c_27[126])    / c_27[126]    * 100 : na
yr_27  = c_27[252]    != 0 ? (c_27 - c_27[252])    / c_27[252]    * 100 : na
yt_27  = c_27[ytdOff] != 0 ? (c_27 - c_27[ytdOff]) / c_27[ytdOff] * 100 : na
// --- TTMI ---
r_28   = c_28[1] != 0 ? (c_28 - c_28[1]) / c_28[1] : na
md_28  = ta.sma(r_28, 252)
sd_28  = ta.stdev(r_28, 252)
dn_28  = math.sqrt(ta.sma(math.pow(math.min(r_28, 0.0), 2), 252))
og_28  = ta.sma(math.max(r_28 - dailyRf, 0.0), 252)
ol_28  = ta.sma(math.max(dailyRf - r_28, 0.0), 252)
wv_28  = ta.stdev(r_28, 5) * math.sqrt(252) * 100
wk_28  = c_28[5]      != 0 ? (c_28 - c_28[5])      / c_28[5]      * 100 : na
mo_28  = c_28[21]     != 0 ? (c_28 - c_28[21])     / c_28[21]     * 100 : na
qt_28  = c_28[63]     != 0 ? (c_28 - c_28[63])     / c_28[63]     * 100 : na
hf_28  = c_28[126]    != 0 ? (c_28 - c_28[126])    / c_28[126]    * 100 : na
yr_28  = c_28[252]    != 0 ? (c_28 - c_28[252])    / c_28[252]    * 100 : na
yt_28  = c_28[ytdOff] != 0 ? (c_28 - c_28[ytdOff]) / c_28[ytdOff] * 100 : na
// --- VICR ---
r_29   = c_29[1] != 0 ? (c_29 - c_29[1]) / c_29[1] : na
md_29  = ta.sma(r_29, 252)
sd_29  = ta.stdev(r_29, 252)
dn_29  = math.sqrt(ta.sma(math.pow(math.min(r_29, 0.0), 2), 252))
og_29  = ta.sma(math.max(r_29 - dailyRf, 0.0), 252)
ol_29  = ta.sma(math.max(dailyRf - r_29, 0.0), 252)
wv_29  = ta.stdev(r_29, 5) * math.sqrt(252) * 100
wk_29  = c_29[5]      != 0 ? (c_29 - c_29[5])      / c_29[5]      * 100 : na
mo_29  = c_29[21]     != 0 ? (c_29 - c_29[21])     / c_29[21]     * 100 : na
qt_29  = c_29[63]     != 0 ? (c_29 - c_29[63])     / c_29[63]     * 100 : na
hf_29  = c_29[126]    != 0 ? (c_29 - c_29[126])    / c_29[126]    * 100 : na
yr_29  = c_29[252]    != 0 ? (c_29 - c_29[252])    / c_29[252]    * 100 : na
yt_29  = c_29[ytdOff] != 0 ? (c_29 - c_29[ytdOff]) / c_29[ytdOff] * 100 : na
// --- COHU ---
r_30   = c_30[1] != 0 ? (c_30 - c_30[1]) / c_30[1] : na
md_30  = ta.sma(r_30, 252)
sd_30  = ta.stdev(r_30, 252)
dn_30  = math.sqrt(ta.sma(math.pow(math.min(r_30, 0.0), 2), 252))
og_30  = ta.sma(math.max(r_30 - dailyRf, 0.0), 252)
ol_30  = ta.sma(math.max(dailyRf - r_30, 0.0), 252)
wv_30  = ta.stdev(r_30, 5) * math.sqrt(252) * 100
wk_30  = c_30[5]      != 0 ? (c_30 - c_30[5])      / c_30[5]      * 100 : na
mo_30  = c_30[21]     != 0 ? (c_30 - c_30[21])     / c_30[21]     * 100 : na
qt_30  = c_30[63]     != 0 ? (c_30 - c_30[63])     / c_30[63]     * 100 : na
hf_30  = c_30[126]    != 0 ? (c_30 - c_30[126])    / c_30[126]    * 100 : na
yr_30  = c_30[252]    != 0 ? (c_30 - c_30[252])    / c_30[252]    * 100 : na
yt_30  = c_30[ytdOff] != 0 ? (c_30 - c_30[ytdOff]) / c_30[ytdOff] * 100 : na
// --- MRAM ---
r_31   = c_31[1] != 0 ? (c_31 - c_31[1]) / c_31[1] : na
md_31  = ta.sma(r_31, 252)
sd_31  = ta.stdev(r_31, 252)
dn_31  = math.sqrt(ta.sma(math.pow(math.min(r_31, 0.0), 2), 252))
og_31  = ta.sma(math.max(r_31 - dailyRf, 0.0), 252)
ol_31  = ta.sma(math.max(dailyRf - r_31, 0.0), 252)
wv_31  = ta.stdev(r_31, 5) * math.sqrt(252) * 100
wk_31  = c_31[5]      != 0 ? (c_31 - c_31[5])      / c_31[5]      * 100 : na
mo_31  = c_31[21]     != 0 ? (c_31 - c_31[21])     / c_31[21]     * 100 : na
qt_31  = c_31[63]     != 0 ? (c_31 - c_31[63])     / c_31[63]     * 100 : na
hf_31  = c_31[126]    != 0 ? (c_31 - c_31[126])    / c_31[126]    * 100 : na
yr_31  = c_31[252]    != 0 ? (c_31 - c_31[252])    / c_31[252]    * 100 : na
yt_31  = c_31[ytdOff] != 0 ? (c_31 - c_31[ytdOff]) / c_31[ytdOff] * 100 : na
// --- BRUN ---
r_32   = c_32[1] != 0 ? (c_32 - c_32[1]) / c_32[1] : na
md_32  = ta.sma(r_32, 252)
sd_32  = ta.stdev(r_32, 252)
dn_32  = math.sqrt(ta.sma(math.pow(math.min(r_32, 0.0), 2), 252))
og_32  = ta.sma(math.max(r_32 - dailyRf, 0.0), 252)
ol_32  = ta.sma(math.max(dailyRf - r_32, 0.0), 252)
wv_32  = ta.stdev(r_32, 5) * math.sqrt(252) * 100
wk_32  = c_32[5]      != 0 ? (c_32 - c_32[5])      / c_32[5]      * 100 : na
mo_32  = c_32[21]     != 0 ? (c_32 - c_32[21])     / c_32[21]     * 100 : na
qt_32  = c_32[63]     != 0 ? (c_32 - c_32[63])     / c_32[63]     * 100 : na
hf_32  = c_32[126]    != 0 ? (c_32 - c_32[126])    / c_32[126]    * 100 : na
yr_32  = c_32[252]    != 0 ? (c_32 - c_32[252])    / c_32[252]    * 100 : na
yt_32  = c_32[ytdOff] != 0 ? (c_32 - c_32[ytdOff]) / c_32[ytdOff] * 100 : na
// --- AIP ---
r_33   = c_33[1] != 0 ? (c_33 - c_33[1]) / c_33[1] : na
md_33  = ta.sma(r_33, 252)
sd_33  = ta.stdev(r_33, 252)
dn_33  = math.sqrt(ta.sma(math.pow(math.min(r_33, 0.0), 2), 252))
og_33  = ta.sma(math.max(r_33 - dailyRf, 0.0), 252)
ol_33  = ta.sma(math.max(dailyRf - r_33, 0.0), 252)
wv_33  = ta.stdev(r_33, 5) * math.sqrt(252) * 100
wk_33  = c_33[5]      != 0 ? (c_33 - c_33[5])      / c_33[5]      * 100 : na
mo_33  = c_33[21]     != 0 ? (c_33 - c_33[21])     / c_33[21]     * 100 : na
qt_33  = c_33[63]     != 0 ? (c_33 - c_33[63])     / c_33[63]     * 100 : na
hf_33  = c_33[126]    != 0 ? (c_33 - c_33[126])    / c_33[126]    * 100 : na
yr_33  = c_33[252]    != 0 ? (c_33 - c_33[252])    / c_33[252]    * 100 : na
yt_33  = c_33[ytdOff] != 0 ? (c_33 - c_33[ytdOff]) / c_33[ytdOff] * 100 : na
// --- VECO ---
r_34   = c_34[1] != 0 ? (c_34 - c_34[1]) / c_34[1] : na
md_34  = ta.sma(r_34, 252)
sd_34  = ta.stdev(r_34, 252)
dn_34  = math.sqrt(ta.sma(math.pow(math.min(r_34, 0.0), 2), 252))
og_34  = ta.sma(math.max(r_34 - dailyRf, 0.0), 252)
ol_34  = ta.sma(math.max(dailyRf - r_34, 0.0), 252)
wv_34  = ta.stdev(r_34, 5) * math.sqrt(252) * 100
wk_34  = c_34[5]      != 0 ? (c_34 - c_34[5])      / c_34[5]      * 100 : na
mo_34  = c_34[21]     != 0 ? (c_34 - c_34[21])     / c_34[21]     * 100 : na
qt_34  = c_34[63]     != 0 ? (c_34 - c_34[63])     / c_34[63]     * 100 : na
hf_34  = c_34[126]    != 0 ? (c_34 - c_34[126])    / c_34[126]    * 100 : na
yr_34  = c_34[252]    != 0 ? (c_34 - c_34[252])    / c_34[252]    * 100 : na
yt_34  = c_34[ytdOff] != 0 ? (c_34 - c_34[ytdOff]) / c_34[ytdOff] * 100 : na
// --- ACMR ---
r_35   = c_35[1] != 0 ? (c_35 - c_35[1]) / c_35[1] : na
md_35  = ta.sma(r_35, 252)
sd_35  = ta.stdev(r_35, 252)
dn_35  = math.sqrt(ta.sma(math.pow(math.min(r_35, 0.0), 2), 252))
og_35  = ta.sma(math.max(r_35 - dailyRf, 0.0), 252)
ol_35  = ta.sma(math.max(dailyRf - r_35, 0.0), 252)
wv_35  = ta.stdev(r_35, 5) * math.sqrt(252) * 100
wk_35  = c_35[5]      != 0 ? (c_35 - c_35[5])      / c_35[5]      * 100 : na
mo_35  = c_35[21]     != 0 ? (c_35 - c_35[21])     / c_35[21]     * 100 : na
qt_35  = c_35[63]     != 0 ? (c_35 - c_35[63])     / c_35[63]     * 100 : na
hf_35  = c_35[126]    != 0 ? (c_35 - c_35[126])    / c_35[126]    * 100 : na
yr_35  = c_35[252]    != 0 ? (c_35 - c_35[252])    / c_35[252]    * 100 : na
yt_35  = c_35[ytdOff] != 0 ? (c_35 - c_35[ytdOff]) / c_35[ytdOff] * 100 : na
// --- CHRN ---
r_36   = c_36[1] != 0 ? (c_36 - c_36[1]) / c_36[1] : na
md_36  = ta.sma(r_36, 252)
sd_36  = ta.stdev(r_36, 252)
dn_36  = math.sqrt(ta.sma(math.pow(math.min(r_36, 0.0), 2), 252))
og_36  = ta.sma(math.max(r_36 - dailyRf, 0.0), 252)
ol_36  = ta.sma(math.max(dailyRf - r_36, 0.0), 252)
wv_36  = ta.stdev(r_36, 5) * math.sqrt(252) * 100
wk_36  = c_36[5]      != 0 ? (c_36 - c_36[5])      / c_36[5]      * 100 : na
mo_36  = c_36[21]     != 0 ? (c_36 - c_36[21])     / c_36[21]     * 100 : na
qt_36  = c_36[63]     != 0 ? (c_36 - c_36[63])     / c_36[63]     * 100 : na
hf_36  = c_36[126]    != 0 ? (c_36 - c_36[126])    / c_36[126]    * 100 : na
yr_36  = c_36[252]    != 0 ? (c_36 - c_36[252])    / c_36[252]    * 100 : na
yt_36  = c_36[ytdOff] != 0 ? (c_36 - c_36[ytdOff]) / c_36[ytdOff] * 100 : na
// --- FORM ---
r_37   = c_37[1] != 0 ? (c_37 - c_37[1]) / c_37[1] : na
md_37  = ta.sma(r_37, 252)
sd_37  = ta.stdev(r_37, 252)
dn_37  = math.sqrt(ta.sma(math.pow(math.min(r_37, 0.0), 2), 252))
og_37  = ta.sma(math.max(r_37 - dailyRf, 0.0), 252)
ol_37  = ta.sma(math.max(dailyRf - r_37, 0.0), 252)
wv_37  = ta.stdev(r_37, 5) * math.sqrt(252) * 100
wk_37  = c_37[5]      != 0 ? (c_37 - c_37[5])      / c_37[5]      * 100 : na
mo_37  = c_37[21]     != 0 ? (c_37 - c_37[21])     / c_37[21]     * 100 : na
qt_37  = c_37[63]     != 0 ? (c_37 - c_37[63])     / c_37[63]     * 100 : na
hf_37  = c_37[126]    != 0 ? (c_37 - c_37[126])    / c_37[126]    * 100 : na
yr_37  = c_37[252]    != 0 ? (c_37 - c_37[252])    / c_37[252]    * 100 : na
yt_37  = c_37[ytdOff] != 0 ? (c_37 - c_37[ytdOff]) / c_37[ytdOff] * 100 : na
// --- KEEL ---
r_38   = c_38[1] != 0 ? (c_38 - c_38[1]) / c_38[1] : na
md_38  = ta.sma(r_38, 252)
sd_38  = ta.stdev(r_38, 252)
dn_38  = math.sqrt(ta.sma(math.pow(math.min(r_38, 0.0), 2), 252))
og_38  = ta.sma(math.max(r_38 - dailyRf, 0.0), 252)
ol_38  = ta.sma(math.max(dailyRf - r_38, 0.0), 252)
wv_38  = ta.stdev(r_38, 5) * math.sqrt(252) * 100
wk_38  = c_38[5]      != 0 ? (c_38 - c_38[5])      / c_38[5]      * 100 : na
mo_38  = c_38[21]     != 0 ? (c_38 - c_38[21])     / c_38[21]     * 100 : na
qt_38  = c_38[63]     != 0 ? (c_38 - c_38[63])     / c_38[63]     * 100 : na
hf_38  = c_38[126]    != 0 ? (c_38 - c_38[126])    / c_38[126]    * 100 : na
yr_38  = c_38[252]    != 0 ? (c_38 - c_38[252])    / c_38[252]    * 100 : na
yt_38  = c_38[ytdOff] != 0 ? (c_38 - c_38[ytdOff]) / c_38[ytdOff] * 100 : na
// --- KLIC ---
r_39   = c_39[1] != 0 ? (c_39 - c_39[1]) / c_39[1] : na
md_39  = ta.sma(r_39, 252)
sd_39  = ta.stdev(r_39, 252)
dn_39  = math.sqrt(ta.sma(math.pow(math.min(r_39, 0.0), 2), 252))
og_39  = ta.sma(math.max(r_39 - dailyRf, 0.0), 252)
ol_39  = ta.sma(math.max(dailyRf - r_39, 0.0), 252)
wv_39  = ta.stdev(r_39, 5) * math.sqrt(252) * 100
wk_39  = c_39[5]      != 0 ? (c_39 - c_39[5])      / c_39[5]      * 100 : na
mo_39  = c_39[21]     != 0 ? (c_39 - c_39[21])     / c_39[21]     * 100 : na
qt_39  = c_39[63]     != 0 ? (c_39 - c_39[63])     / c_39[63]     * 100 : na
hf_39  = c_39[126]    != 0 ? (c_39 - c_39[126])    / c_39[126]    * 100 : na
yr_39  = c_39[252]    != 0 ? (c_39 - c_39[252])    / c_39[252]    * 100 : na
yt_39  = c_39[ytdOff] != 0 ? (c_39 - c_39[ytdOff]) / c_39[ytdOff] * 100 : na
// --- VIAV ---
r_40   = c_40[1] != 0 ? (c_40 - c_40[1]) / c_40[1] : na
md_40  = ta.sma(r_40, 252)
sd_40  = ta.stdev(r_40, 252)
dn_40  = math.sqrt(ta.sma(math.pow(math.min(r_40, 0.0), 2), 252))
og_40  = ta.sma(math.max(r_40 - dailyRf, 0.0), 252)
ol_40  = ta.sma(math.max(dailyRf - r_40, 0.0), 252)
wv_40  = ta.stdev(r_40, 5) * math.sqrt(252) * 100
wk_40  = c_40[5]      != 0 ? (c_40 - c_40[5])      / c_40[5]      * 100 : na
mo_40  = c_40[21]     != 0 ? (c_40 - c_40[21])     / c_40[21]     * 100 : na
qt_40  = c_40[63]     != 0 ? (c_40 - c_40[63])     / c_40[63]     * 100 : na
hf_40  = c_40[126]    != 0 ? (c_40 - c_40[126])    / c_40[126]    * 100 : na
yr_40  = c_40[252]    != 0 ? (c_40 - c_40[252])    / c_40[252]    * 100 : na
yt_40  = c_40[ytdOff] != 0 ? (c_40 - c_40[ytdOff]) / c_40[ytdOff] * 100 : na

// Equal-weight basket return of the 40 screener constituents = beta benchmark
marketRet = (nz(r_1) + nz(r_2) + nz(r_3) + nz(r_4) + nz(r_5) + nz(r_6) + nz(r_7) + nz(r_8) + nz(r_9) + nz(r_10) + nz(r_11) + nz(r_12) + nz(r_13) + nz(r_14) + nz(r_15) + nz(r_16) + nz(r_17) + nz(r_18) + nz(r_19) + nz(r_20) + nz(r_21) + nz(r_22) + nz(r_23) + nz(r_24) + nz(r_25) + nz(r_26) + nz(r_27) + nz(r_28) + nz(r_29) + nz(r_30) + nz(r_31) + nz(r_32) + nz(r_33) + nz(r_34) + nz(r_35) + nz(r_36) + nz(r_37) + nz(r_38) + nz(r_39) + nz(r_40)) / 40.0
mStd = ta.stdev(marketRet, betaLen)

// ====================== DERIVED METRICS (series) ==================
annRet_1  = md_1 * 252
annVol_1  = sd_1 * math.sqrt(252)
annDD_1   = dn_1 * math.sqrt(252)
beta_1    = mStd > 1e-9 ? ta.correlation(r_1, marketRet, betaLen) * ta.stdev(r_1, betaLen) / mStd : na
sharpe_1  = annVol_1 > 1e-9 ? (annRet_1 - riskFreeRate) / annVol_1 : na
sortino_1 = annDD_1  > 1e-9 ? (annRet_1 - riskFreeRate) / annDD_1  : na
omega_1   = ol_1     > 1e-9 ? og_1 / ol_1 : na
zscore_1  = sd_1     > 1e-9 ? ((wk_1 / 100) - md_1 * 5) / (sd_1 * math.sqrt(5)) : na
kelly_1   = annVol_1 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_1 - riskFreeRate) / (annVol_1 * annVol_1))) : na
annRet_2  = md_2 * 252
annVol_2  = sd_2 * math.sqrt(252)
annDD_2   = dn_2 * math.sqrt(252)
beta_2    = mStd > 1e-9 ? ta.correlation(r_2, marketRet, betaLen) * ta.stdev(r_2, betaLen) / mStd : na
sharpe_2  = annVol_2 > 1e-9 ? (annRet_2 - riskFreeRate) / annVol_2 : na
sortino_2 = annDD_2  > 1e-9 ? (annRet_2 - riskFreeRate) / annDD_2  : na
omega_2   = ol_2     > 1e-9 ? og_2 / ol_2 : na
zscore_2  = sd_2     > 1e-9 ? ((wk_2 / 100) - md_2 * 5) / (sd_2 * math.sqrt(5)) : na
kelly_2   = annVol_2 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_2 - riskFreeRate) / (annVol_2 * annVol_2))) : na
annRet_3  = md_3 * 252
annVol_3  = sd_3 * math.sqrt(252)
annDD_3   = dn_3 * math.sqrt(252)
beta_3    = mStd > 1e-9 ? ta.correlation(r_3, marketRet, betaLen) * ta.stdev(r_3, betaLen) / mStd : na
sharpe_3  = annVol_3 > 1e-9 ? (annRet_3 - riskFreeRate) / annVol_3 : na
sortino_3 = annDD_3  > 1e-9 ? (annRet_3 - riskFreeRate) / annDD_3  : na
omega_3   = ol_3     > 1e-9 ? og_3 / ol_3 : na
zscore_3  = sd_3     > 1e-9 ? ((wk_3 / 100) - md_3 * 5) / (sd_3 * math.sqrt(5)) : na
kelly_3   = annVol_3 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_3 - riskFreeRate) / (annVol_3 * annVol_3))) : na
annRet_4  = md_4 * 252
annVol_4  = sd_4 * math.sqrt(252)
annDD_4   = dn_4 * math.sqrt(252)
beta_4    = mStd > 1e-9 ? ta.correlation(r_4, marketRet, betaLen) * ta.stdev(r_4, betaLen) / mStd : na
sharpe_4  = annVol_4 > 1e-9 ? (annRet_4 - riskFreeRate) / annVol_4 : na
sortino_4 = annDD_4  > 1e-9 ? (annRet_4 - riskFreeRate) / annDD_4  : na
omega_4   = ol_4     > 1e-9 ? og_4 / ol_4 : na
zscore_4  = sd_4     > 1e-9 ? ((wk_4 / 100) - md_4 * 5) / (sd_4 * math.sqrt(5)) : na
kelly_4   = annVol_4 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_4 - riskFreeRate) / (annVol_4 * annVol_4))) : na
annRet_5  = md_5 * 252
annVol_5  = sd_5 * math.sqrt(252)
annDD_5   = dn_5 * math.sqrt(252)
beta_5    = mStd > 1e-9 ? ta.correlation(r_5, marketRet, betaLen) * ta.stdev(r_5, betaLen) / mStd : na
sharpe_5  = annVol_5 > 1e-9 ? (annRet_5 - riskFreeRate) / annVol_5 : na
sortino_5 = annDD_5  > 1e-9 ? (annRet_5 - riskFreeRate) / annDD_5  : na
omega_5   = ol_5     > 1e-9 ? og_5 / ol_5 : na
zscore_5  = sd_5     > 1e-9 ? ((wk_5 / 100) - md_5 * 5) / (sd_5 * math.sqrt(5)) : na
kelly_5   = annVol_5 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_5 - riskFreeRate) / (annVol_5 * annVol_5))) : na
annRet_6  = md_6 * 252
annVol_6  = sd_6 * math.sqrt(252)
annDD_6   = dn_6 * math.sqrt(252)
beta_6    = mStd > 1e-9 ? ta.correlation(r_6, marketRet, betaLen) * ta.stdev(r_6, betaLen) / mStd : na
sharpe_6  = annVol_6 > 1e-9 ? (annRet_6 - riskFreeRate) / annVol_6 : na
sortino_6 = annDD_6  > 1e-9 ? (annRet_6 - riskFreeRate) / annDD_6  : na
omega_6   = ol_6     > 1e-9 ? og_6 / ol_6 : na
zscore_6  = sd_6     > 1e-9 ? ((wk_6 / 100) - md_6 * 5) / (sd_6 * math.sqrt(5)) : na
kelly_6   = annVol_6 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_6 - riskFreeRate) / (annVol_6 * annVol_6))) : na
annRet_7  = md_7 * 252
annVol_7  = sd_7 * math.sqrt(252)
annDD_7   = dn_7 * math.sqrt(252)
beta_7    = mStd > 1e-9 ? ta.correlation(r_7, marketRet, betaLen) * ta.stdev(r_7, betaLen) / mStd : na
sharpe_7  = annVol_7 > 1e-9 ? (annRet_7 - riskFreeRate) / annVol_7 : na
sortino_7 = annDD_7  > 1e-9 ? (annRet_7 - riskFreeRate) / annDD_7  : na
omega_7   = ol_7     > 1e-9 ? og_7 / ol_7 : na
zscore_7  = sd_7     > 1e-9 ? ((wk_7 / 100) - md_7 * 5) / (sd_7 * math.sqrt(5)) : na
kelly_7   = annVol_7 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_7 - riskFreeRate) / (annVol_7 * annVol_7))) : na
annRet_8  = md_8 * 252
annVol_8  = sd_8 * math.sqrt(252)
annDD_8   = dn_8 * math.sqrt(252)
beta_8    = mStd > 1e-9 ? ta.correlation(r_8, marketRet, betaLen) * ta.stdev(r_8, betaLen) / mStd : na
sharpe_8  = annVol_8 > 1e-9 ? (annRet_8 - riskFreeRate) / annVol_8 : na
sortino_8 = annDD_8  > 1e-9 ? (annRet_8 - riskFreeRate) / annDD_8  : na
omega_8   = ol_8     > 1e-9 ? og_8 / ol_8 : na
zscore_8  = sd_8     > 1e-9 ? ((wk_8 / 100) - md_8 * 5) / (sd_8 * math.sqrt(5)) : na
kelly_8   = annVol_8 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_8 - riskFreeRate) / (annVol_8 * annVol_8))) : na
annRet_9  = md_9 * 252
annVol_9  = sd_9 * math.sqrt(252)
annDD_9   = dn_9 * math.sqrt(252)
beta_9    = mStd > 1e-9 ? ta.correlation(r_9, marketRet, betaLen) * ta.stdev(r_9, betaLen) / mStd : na
sharpe_9  = annVol_9 > 1e-9 ? (annRet_9 - riskFreeRate) / annVol_9 : na
sortino_9 = annDD_9  > 1e-9 ? (annRet_9 - riskFreeRate) / annDD_9  : na
omega_9   = ol_9     > 1e-9 ? og_9 / ol_9 : na
zscore_9  = sd_9     > 1e-9 ? ((wk_9 / 100) - md_9 * 5) / (sd_9 * math.sqrt(5)) : na
kelly_9   = annVol_9 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_9 - riskFreeRate) / (annVol_9 * annVol_9))) : na
annRet_10  = md_10 * 252
annVol_10  = sd_10 * math.sqrt(252)
annDD_10   = dn_10 * math.sqrt(252)
beta_10    = mStd > 1e-9 ? ta.correlation(r_10, marketRet, betaLen) * ta.stdev(r_10, betaLen) / mStd : na
sharpe_10  = annVol_10 > 1e-9 ? (annRet_10 - riskFreeRate) / annVol_10 : na
sortino_10 = annDD_10  > 1e-9 ? (annRet_10 - riskFreeRate) / annDD_10  : na
omega_10   = ol_10     > 1e-9 ? og_10 / ol_10 : na
zscore_10  = sd_10     > 1e-9 ? ((wk_10 / 100) - md_10 * 5) / (sd_10 * math.sqrt(5)) : na
kelly_10   = annVol_10 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_10 - riskFreeRate) / (annVol_10 * annVol_10))) : na
annRet_11  = md_11 * 252
annVol_11  = sd_11 * math.sqrt(252)
annDD_11   = dn_11 * math.sqrt(252)
beta_11    = mStd > 1e-9 ? ta.correlation(r_11, marketRet, betaLen) * ta.stdev(r_11, betaLen) / mStd : na
sharpe_11  = annVol_11 > 1e-9 ? (annRet_11 - riskFreeRate) / annVol_11 : na
sortino_11 = annDD_11  > 1e-9 ? (annRet_11 - riskFreeRate) / annDD_11  : na
omega_11   = ol_11     > 1e-9 ? og_11 / ol_11 : na
zscore_11  = sd_11     > 1e-9 ? ((wk_11 / 100) - md_11 * 5) / (sd_11 * math.sqrt(5)) : na
kelly_11   = annVol_11 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_11 - riskFreeRate) / (annVol_11 * annVol_11))) : na
annRet_12  = md_12 * 252
annVol_12  = sd_12 * math.sqrt(252)
annDD_12   = dn_12 * math.sqrt(252)
beta_12    = mStd > 1e-9 ? ta.correlation(r_12, marketRet, betaLen) * ta.stdev(r_12, betaLen) / mStd : na
sharpe_12  = annVol_12 > 1e-9 ? (annRet_12 - riskFreeRate) / annVol_12 : na
sortino_12 = annDD_12  > 1e-9 ? (annRet_12 - riskFreeRate) / annDD_12  : na
omega_12   = ol_12     > 1e-9 ? og_12 / ol_12 : na
zscore_12  = sd_12     > 1e-9 ? ((wk_12 / 100) - md_12 * 5) / (sd_12 * math.sqrt(5)) : na
kelly_12   = annVol_12 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_12 - riskFreeRate) / (annVol_12 * annVol_12))) : na
annRet_13  = md_13 * 252
annVol_13  = sd_13 * math.sqrt(252)
annDD_13   = dn_13 * math.sqrt(252)
beta_13    = mStd > 1e-9 ? ta.correlation(r_13, marketRet, betaLen) * ta.stdev(r_13, betaLen) / mStd : na
sharpe_13  = annVol_13 > 1e-9 ? (annRet_13 - riskFreeRate) / annVol_13 : na
sortino_13 = annDD_13  > 1e-9 ? (annRet_13 - riskFreeRate) / annDD_13  : na
omega_13   = ol_13     > 1e-9 ? og_13 / ol_13 : na
zscore_13  = sd_13     > 1e-9 ? ((wk_13 / 100) - md_13 * 5) / (sd_13 * math.sqrt(5)) : na
kelly_13   = annVol_13 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_13 - riskFreeRate) / (annVol_13 * annVol_13))) : na
annRet_14  = md_14 * 252
annVol_14  = sd_14 * math.sqrt(252)
annDD_14   = dn_14 * math.sqrt(252)
beta_14    = mStd > 1e-9 ? ta.correlation(r_14, marketRet, betaLen) * ta.stdev(r_14, betaLen) / mStd : na
sharpe_14  = annVol_14 > 1e-9 ? (annRet_14 - riskFreeRate) / annVol_14 : na
sortino_14 = annDD_14  > 1e-9 ? (annRet_14 - riskFreeRate) / annDD_14  : na
omega_14   = ol_14     > 1e-9 ? og_14 / ol_14 : na
zscore_14  = sd_14     > 1e-9 ? ((wk_14 / 100) - md_14 * 5) / (sd_14 * math.sqrt(5)) : na
kelly_14   = annVol_14 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_14 - riskFreeRate) / (annVol_14 * annVol_14))) : na
annRet_15  = md_15 * 252
annVol_15  = sd_15 * math.sqrt(252)
annDD_15   = dn_15 * math.sqrt(252)
beta_15    = mStd > 1e-9 ? ta.correlation(r_15, marketRet, betaLen) * ta.stdev(r_15, betaLen) / mStd : na
sharpe_15  = annVol_15 > 1e-9 ? (annRet_15 - riskFreeRate) / annVol_15 : na
sortino_15 = annDD_15  > 1e-9 ? (annRet_15 - riskFreeRate) / annDD_15  : na
omega_15   = ol_15     > 1e-9 ? og_15 / ol_15 : na
zscore_15  = sd_15     > 1e-9 ? ((wk_15 / 100) - md_15 * 5) / (sd_15 * math.sqrt(5)) : na
kelly_15   = annVol_15 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_15 - riskFreeRate) / (annVol_15 * annVol_15))) : na
annRet_16  = md_16 * 252
annVol_16  = sd_16 * math.sqrt(252)
annDD_16   = dn_16 * math.sqrt(252)
beta_16    = mStd > 1e-9 ? ta.correlation(r_16, marketRet, betaLen) * ta.stdev(r_16, betaLen) / mStd : na
sharpe_16  = annVol_16 > 1e-9 ? (annRet_16 - riskFreeRate) / annVol_16 : na
sortino_16 = annDD_16  > 1e-9 ? (annRet_16 - riskFreeRate) / annDD_16  : na
omega_16   = ol_16     > 1e-9 ? og_16 / ol_16 : na
zscore_16  = sd_16     > 1e-9 ? ((wk_16 / 100) - md_16 * 5) / (sd_16 * math.sqrt(5)) : na
kelly_16   = annVol_16 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_16 - riskFreeRate) / (annVol_16 * annVol_16))) : na
annRet_17  = md_17 * 252
annVol_17  = sd_17 * math.sqrt(252)
annDD_17   = dn_17 * math.sqrt(252)
beta_17    = mStd > 1e-9 ? ta.correlation(r_17, marketRet, betaLen) * ta.stdev(r_17, betaLen) / mStd : na
sharpe_17  = annVol_17 > 1e-9 ? (annRet_17 - riskFreeRate) / annVol_17 : na
sortino_17 = annDD_17  > 1e-9 ? (annRet_17 - riskFreeRate) / annDD_17  : na
omega_17   = ol_17     > 1e-9 ? og_17 / ol_17 : na
zscore_17  = sd_17     > 1e-9 ? ((wk_17 / 100) - md_17 * 5) / (sd_17 * math.sqrt(5)) : na
kelly_17   = annVol_17 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_17 - riskFreeRate) / (annVol_17 * annVol_17))) : na
annRet_18  = md_18 * 252
annVol_18  = sd_18 * math.sqrt(252)
annDD_18   = dn_18 * math.sqrt(252)
beta_18    = mStd > 1e-9 ? ta.correlation(r_18, marketRet, betaLen) * ta.stdev(r_18, betaLen) / mStd : na
sharpe_18  = annVol_18 > 1e-9 ? (annRet_18 - riskFreeRate) / annVol_18 : na
sortino_18 = annDD_18  > 1e-9 ? (annRet_18 - riskFreeRate) / annDD_18  : na
omega_18   = ol_18     > 1e-9 ? og_18 / ol_18 : na
zscore_18  = sd_18     > 1e-9 ? ((wk_18 / 100) - md_18 * 5) / (sd_18 * math.sqrt(5)) : na
kelly_18   = annVol_18 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_18 - riskFreeRate) / (annVol_18 * annVol_18))) : na
annRet_19  = md_19 * 252
annVol_19  = sd_19 * math.sqrt(252)
annDD_19   = dn_19 * math.sqrt(252)
beta_19    = mStd > 1e-9 ? ta.correlation(r_19, marketRet, betaLen) * ta.stdev(r_19, betaLen) / mStd : na
sharpe_19  = annVol_19 > 1e-9 ? (annRet_19 - riskFreeRate) / annVol_19 : na
sortino_19 = annDD_19  > 1e-9 ? (annRet_19 - riskFreeRate) / annDD_19  : na
omega_19   = ol_19     > 1e-9 ? og_19 / ol_19 : na
zscore_19  = sd_19     > 1e-9 ? ((wk_19 / 100) - md_19 * 5) / (sd_19 * math.sqrt(5)) : na
kelly_19   = annVol_19 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_19 - riskFreeRate) / (annVol_19 * annVol_19))) : na
annRet_20  = md_20 * 252
annVol_20  = sd_20 * math.sqrt(252)
annDD_20   = dn_20 * math.sqrt(252)
beta_20    = mStd > 1e-9 ? ta.correlation(r_20, marketRet, betaLen) * ta.stdev(r_20, betaLen) / mStd : na
sharpe_20  = annVol_20 > 1e-9 ? (annRet_20 - riskFreeRate) / annVol_20 : na
sortino_20 = annDD_20  > 1e-9 ? (annRet_20 - riskFreeRate) / annDD_20  : na
omega_20   = ol_20     > 1e-9 ? og_20 / ol_20 : na
zscore_20  = sd_20     > 1e-9 ? ((wk_20 / 100) - md_20 * 5) / (sd_20 * math.sqrt(5)) : na
kelly_20   = annVol_20 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_20 - riskFreeRate) / (annVol_20 * annVol_20))) : na
annRet_21  = md_21 * 252
annVol_21  = sd_21 * math.sqrt(252)
annDD_21   = dn_21 * math.sqrt(252)
beta_21    = mStd > 1e-9 ? ta.correlation(r_21, marketRet, betaLen) * ta.stdev(r_21, betaLen) / mStd : na
sharpe_21  = annVol_21 > 1e-9 ? (annRet_21 - riskFreeRate) / annVol_21 : na
sortino_21 = annDD_21  > 1e-9 ? (annRet_21 - riskFreeRate) / annDD_21  : na
omega_21   = ol_21     > 1e-9 ? og_21 / ol_21 : na
zscore_21  = sd_21     > 1e-9 ? ((wk_21 / 100) - md_21 * 5) / (sd_21 * math.sqrt(5)) : na
kelly_21   = annVol_21 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_21 - riskFreeRate) / (annVol_21 * annVol_21))) : na
annRet_22  = md_22 * 252
annVol_22  = sd_22 * math.sqrt(252)
annDD_22   = dn_22 * math.sqrt(252)
beta_22    = mStd > 1e-9 ? ta.correlation(r_22, marketRet, betaLen) * ta.stdev(r_22, betaLen) / mStd : na
sharpe_22  = annVol_22 > 1e-9 ? (annRet_22 - riskFreeRate) / annVol_22 : na
sortino_22 = annDD_22  > 1e-9 ? (annRet_22 - riskFreeRate) / annDD_22  : na
omega_22   = ol_22     > 1e-9 ? og_22 / ol_22 : na
zscore_22  = sd_22     > 1e-9 ? ((wk_22 / 100) - md_22 * 5) / (sd_22 * math.sqrt(5)) : na
kelly_22   = annVol_22 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_22 - riskFreeRate) / (annVol_22 * annVol_22))) : na
annRet_23  = md_23 * 252
annVol_23  = sd_23 * math.sqrt(252)
annDD_23   = dn_23 * math.sqrt(252)
beta_23    = mStd > 1e-9 ? ta.correlation(r_23, marketRet, betaLen) * ta.stdev(r_23, betaLen) / mStd : na
sharpe_23  = annVol_23 > 1e-9 ? (annRet_23 - riskFreeRate) / annVol_23 : na
sortino_23 = annDD_23  > 1e-9 ? (annRet_23 - riskFreeRate) / annDD_23  : na
omega_23   = ol_23     > 1e-9 ? og_23 / ol_23 : na
zscore_23  = sd_23     > 1e-9 ? ((wk_23 / 100) - md_23 * 5) / (sd_23 * math.sqrt(5)) : na
kelly_23   = annVol_23 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_23 - riskFreeRate) / (annVol_23 * annVol_23))) : na
annRet_24  = md_24 * 252
annVol_24  = sd_24 * math.sqrt(252)
annDD_24   = dn_24 * math.sqrt(252)
beta_24    = mStd > 1e-9 ? ta.correlation(r_24, marketRet, betaLen) * ta.stdev(r_24, betaLen) / mStd : na
sharpe_24  = annVol_24 > 1e-9 ? (annRet_24 - riskFreeRate) / annVol_24 : na
sortino_24 = annDD_24  > 1e-9 ? (annRet_24 - riskFreeRate) / annDD_24  : na
omega_24   = ol_24     > 1e-9 ? og_24 / ol_24 : na
zscore_24  = sd_24     > 1e-9 ? ((wk_24 / 100) - md_24 * 5) / (sd_24 * math.sqrt(5)) : na
kelly_24   = annVol_24 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_24 - riskFreeRate) / (annVol_24 * annVol_24))) : na
annRet_25  = md_25 * 252
annVol_25  = sd_25 * math.sqrt(252)
annDD_25   = dn_25 * math.sqrt(252)
beta_25    = mStd > 1e-9 ? ta.correlation(r_25, marketRet, betaLen) * ta.stdev(r_25, betaLen) / mStd : na
sharpe_25  = annVol_25 > 1e-9 ? (annRet_25 - riskFreeRate) / annVol_25 : na
sortino_25 = annDD_25  > 1e-9 ? (annRet_25 - riskFreeRate) / annDD_25  : na
omega_25   = ol_25     > 1e-9 ? og_25 / ol_25 : na
zscore_25  = sd_25     > 1e-9 ? ((wk_25 / 100) - md_25 * 5) / (sd_25 * math.sqrt(5)) : na
kelly_25   = annVol_25 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_25 - riskFreeRate) / (annVol_25 * annVol_25))) : na
annRet_26  = md_26 * 252
annVol_26  = sd_26 * math.sqrt(252)
annDD_26   = dn_26 * math.sqrt(252)
beta_26    = mStd > 1e-9 ? ta.correlation(r_26, marketRet, betaLen) * ta.stdev(r_26, betaLen) / mStd : na
sharpe_26  = annVol_26 > 1e-9 ? (annRet_26 - riskFreeRate) / annVol_26 : na
sortino_26 = annDD_26  > 1e-9 ? (annRet_26 - riskFreeRate) / annDD_26  : na
omega_26   = ol_26     > 1e-9 ? og_26 / ol_26 : na
zscore_26  = sd_26     > 1e-9 ? ((wk_26 / 100) - md_26 * 5) / (sd_26 * math.sqrt(5)) : na
kelly_26   = annVol_26 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_26 - riskFreeRate) / (annVol_26 * annVol_26))) : na
annRet_27  = md_27 * 252
annVol_27  = sd_27 * math.sqrt(252)
annDD_27   = dn_27 * math.sqrt(252)
beta_27    = mStd > 1e-9 ? ta.correlation(r_27, marketRet, betaLen) * ta.stdev(r_27, betaLen) / mStd : na
sharpe_27  = annVol_27 > 1e-9 ? (annRet_27 - riskFreeRate) / annVol_27 : na
sortino_27 = annDD_27  > 1e-9 ? (annRet_27 - riskFreeRate) / annDD_27  : na
omega_27   = ol_27     > 1e-9 ? og_27 / ol_27 : na
zscore_27  = sd_27     > 1e-9 ? ((wk_27 / 100) - md_27 * 5) / (sd_27 * math.sqrt(5)) : na
kelly_27   = annVol_27 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_27 - riskFreeRate) / (annVol_27 * annVol_27))) : na
annRet_28  = md_28 * 252
annVol_28  = sd_28 * math.sqrt(252)
annDD_28   = dn_28 * math.sqrt(252)
beta_28    = mStd > 1e-9 ? ta.correlation(r_28, marketRet, betaLen) * ta.stdev(r_28, betaLen) / mStd : na
sharpe_28  = annVol_28 > 1e-9 ? (annRet_28 - riskFreeRate) / annVol_28 : na
sortino_28 = annDD_28  > 1e-9 ? (annRet_28 - riskFreeRate) / annDD_28  : na
omega_28   = ol_28     > 1e-9 ? og_28 / ol_28 : na
zscore_28  = sd_28     > 1e-9 ? ((wk_28 / 100) - md_28 * 5) / (sd_28 * math.sqrt(5)) : na
kelly_28   = annVol_28 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_28 - riskFreeRate) / (annVol_28 * annVol_28))) : na
annRet_29  = md_29 * 252
annVol_29  = sd_29 * math.sqrt(252)
annDD_29   = dn_29 * math.sqrt(252)
beta_29    = mStd > 1e-9 ? ta.correlation(r_29, marketRet, betaLen) * ta.stdev(r_29, betaLen) / mStd : na
sharpe_29  = annVol_29 > 1e-9 ? (annRet_29 - riskFreeRate) / annVol_29 : na
sortino_29 = annDD_29  > 1e-9 ? (annRet_29 - riskFreeRate) / annDD_29  : na
omega_29   = ol_29     > 1e-9 ? og_29 / ol_29 : na
zscore_29  = sd_29     > 1e-9 ? ((wk_29 / 100) - md_29 * 5) / (sd_29 * math.sqrt(5)) : na
kelly_29   = annVol_29 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_29 - riskFreeRate) / (annVol_29 * annVol_29))) : na
annRet_30  = md_30 * 252
annVol_30  = sd_30 * math.sqrt(252)
annDD_30   = dn_30 * math.sqrt(252)
beta_30    = mStd > 1e-9 ? ta.correlation(r_30, marketRet, betaLen) * ta.stdev(r_30, betaLen) / mStd : na
sharpe_30  = annVol_30 > 1e-9 ? (annRet_30 - riskFreeRate) / annVol_30 : na
sortino_30 = annDD_30  > 1e-9 ? (annRet_30 - riskFreeRate) / annDD_30  : na
omega_30   = ol_30     > 1e-9 ? og_30 / ol_30 : na
zscore_30  = sd_30     > 1e-9 ? ((wk_30 / 100) - md_30 * 5) / (sd_30 * math.sqrt(5)) : na
kelly_30   = annVol_30 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_30 - riskFreeRate) / (annVol_30 * annVol_30))) : na
annRet_31  = md_31 * 252
annVol_31  = sd_31 * math.sqrt(252)
annDD_31   = dn_31 * math.sqrt(252)
beta_31    = mStd > 1e-9 ? ta.correlation(r_31, marketRet, betaLen) * ta.stdev(r_31, betaLen) / mStd : na
sharpe_31  = annVol_31 > 1e-9 ? (annRet_31 - riskFreeRate) / annVol_31 : na
sortino_31 = annDD_31  > 1e-9 ? (annRet_31 - riskFreeRate) / annDD_31  : na
omega_31   = ol_31     > 1e-9 ? og_31 / ol_31 : na
zscore_31  = sd_31     > 1e-9 ? ((wk_31 / 100) - md_31 * 5) / (sd_31 * math.sqrt(5)) : na
kelly_31   = annVol_31 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_31 - riskFreeRate) / (annVol_31 * annVol_31))) : na
annRet_32  = md_32 * 252
annVol_32  = sd_32 * math.sqrt(252)
annDD_32   = dn_32 * math.sqrt(252)
beta_32    = mStd > 1e-9 ? ta.correlation(r_32, marketRet, betaLen) * ta.stdev(r_32, betaLen) / mStd : na
sharpe_32  = annVol_32 > 1e-9 ? (annRet_32 - riskFreeRate) / annVol_32 : na
sortino_32 = annDD_32  > 1e-9 ? (annRet_32 - riskFreeRate) / annDD_32  : na
omega_32   = ol_32     > 1e-9 ? og_32 / ol_32 : na
zscore_32  = sd_32     > 1e-9 ? ((wk_32 / 100) - md_32 * 5) / (sd_32 * math.sqrt(5)) : na
kelly_32   = annVol_32 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_32 - riskFreeRate) / (annVol_32 * annVol_32))) : na
annRet_33  = md_33 * 252
annVol_33  = sd_33 * math.sqrt(252)
annDD_33   = dn_33 * math.sqrt(252)
beta_33    = mStd > 1e-9 ? ta.correlation(r_33, marketRet, betaLen) * ta.stdev(r_33, betaLen) / mStd : na
sharpe_33  = annVol_33 > 1e-9 ? (annRet_33 - riskFreeRate) / annVol_33 : na
sortino_33 = annDD_33  > 1e-9 ? (annRet_33 - riskFreeRate) / annDD_33  : na
omega_33   = ol_33     > 1e-9 ? og_33 / ol_33 : na
zscore_33  = sd_33     > 1e-9 ? ((wk_33 / 100) - md_33 * 5) / (sd_33 * math.sqrt(5)) : na
kelly_33   = annVol_33 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_33 - riskFreeRate) / (annVol_33 * annVol_33))) : na
annRet_34  = md_34 * 252
annVol_34  = sd_34 * math.sqrt(252)
annDD_34   = dn_34 * math.sqrt(252)
beta_34    = mStd > 1e-9 ? ta.correlation(r_34, marketRet, betaLen) * ta.stdev(r_34, betaLen) / mStd : na
sharpe_34  = annVol_34 > 1e-9 ? (annRet_34 - riskFreeRate) / annVol_34 : na
sortino_34 = annDD_34  > 1e-9 ? (annRet_34 - riskFreeRate) / annDD_34  : na
omega_34   = ol_34     > 1e-9 ? og_34 / ol_34 : na
zscore_34  = sd_34     > 1e-9 ? ((wk_34 / 100) - md_34 * 5) / (sd_34 * math.sqrt(5)) : na
kelly_34   = annVol_34 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_34 - riskFreeRate) / (annVol_34 * annVol_34))) : na
annRet_35  = md_35 * 252
annVol_35  = sd_35 * math.sqrt(252)
annDD_35   = dn_35 * math.sqrt(252)
beta_35    = mStd > 1e-9 ? ta.correlation(r_35, marketRet, betaLen) * ta.stdev(r_35, betaLen) / mStd : na
sharpe_35  = annVol_35 > 1e-9 ? (annRet_35 - riskFreeRate) / annVol_35 : na
sortino_35 = annDD_35  > 1e-9 ? (annRet_35 - riskFreeRate) / annDD_35  : na
omega_35   = ol_35     > 1e-9 ? og_35 / ol_35 : na
zscore_35  = sd_35     > 1e-9 ? ((wk_35 / 100) - md_35 * 5) / (sd_35 * math.sqrt(5)) : na
kelly_35   = annVol_35 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_35 - riskFreeRate) / (annVol_35 * annVol_35))) : na
annRet_36  = md_36 * 252
annVol_36  = sd_36 * math.sqrt(252)
annDD_36   = dn_36 * math.sqrt(252)
beta_36    = mStd > 1e-9 ? ta.correlation(r_36, marketRet, betaLen) * ta.stdev(r_36, betaLen) / mStd : na
sharpe_36  = annVol_36 > 1e-9 ? (annRet_36 - riskFreeRate) / annVol_36 : na
sortino_36 = annDD_36  > 1e-9 ? (annRet_36 - riskFreeRate) / annDD_36  : na
omega_36   = ol_36     > 1e-9 ? og_36 / ol_36 : na
zscore_36  = sd_36     > 1e-9 ? ((wk_36 / 100) - md_36 * 5) / (sd_36 * math.sqrt(5)) : na
kelly_36   = annVol_36 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_36 - riskFreeRate) / (annVol_36 * annVol_36))) : na
annRet_37  = md_37 * 252
annVol_37  = sd_37 * math.sqrt(252)
annDD_37   = dn_37 * math.sqrt(252)
beta_37    = mStd > 1e-9 ? ta.correlation(r_37, marketRet, betaLen) * ta.stdev(r_37, betaLen) / mStd : na
sharpe_37  = annVol_37 > 1e-9 ? (annRet_37 - riskFreeRate) / annVol_37 : na
sortino_37 = annDD_37  > 1e-9 ? (annRet_37 - riskFreeRate) / annDD_37  : na
omega_37   = ol_37     > 1e-9 ? og_37 / ol_37 : na
zscore_37  = sd_37     > 1e-9 ? ((wk_37 / 100) - md_37 * 5) / (sd_37 * math.sqrt(5)) : na
kelly_37   = annVol_37 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_37 - riskFreeRate) / (annVol_37 * annVol_37))) : na
annRet_38  = md_38 * 252
annVol_38  = sd_38 * math.sqrt(252)
annDD_38   = dn_38 * math.sqrt(252)
beta_38    = mStd > 1e-9 ? ta.correlation(r_38, marketRet, betaLen) * ta.stdev(r_38, betaLen) / mStd : na
sharpe_38  = annVol_38 > 1e-9 ? (annRet_38 - riskFreeRate) / annVol_38 : na
sortino_38 = annDD_38  > 1e-9 ? (annRet_38 - riskFreeRate) / annDD_38  : na
omega_38   = ol_38     > 1e-9 ? og_38 / ol_38 : na
zscore_38  = sd_38     > 1e-9 ? ((wk_38 / 100) - md_38 * 5) / (sd_38 * math.sqrt(5)) : na
kelly_38   = annVol_38 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_38 - riskFreeRate) / (annVol_38 * annVol_38))) : na
annRet_39  = md_39 * 252
annVol_39  = sd_39 * math.sqrt(252)
annDD_39   = dn_39 * math.sqrt(252)
beta_39    = mStd > 1e-9 ? ta.correlation(r_39, marketRet, betaLen) * ta.stdev(r_39, betaLen) / mStd : na
sharpe_39  = annVol_39 > 1e-9 ? (annRet_39 - riskFreeRate) / annVol_39 : na
sortino_39 = annDD_39  > 1e-9 ? (annRet_39 - riskFreeRate) / annDD_39  : na
omega_39   = ol_39     > 1e-9 ? og_39 / ol_39 : na
zscore_39  = sd_39     > 1e-9 ? ((wk_39 / 100) - md_39 * 5) / (sd_39 * math.sqrt(5)) : na
kelly_39   = annVol_39 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_39 - riskFreeRate) / (annVol_39 * annVol_39))) : na
annRet_40  = md_40 * 252
annVol_40  = sd_40 * math.sqrt(252)
annDD_40   = dn_40 * math.sqrt(252)
beta_40    = mStd > 1e-9 ? ta.correlation(r_40, marketRet, betaLen) * ta.stdev(r_40, betaLen) / mStd : na
sharpe_40  = annVol_40 > 1e-9 ? (annRet_40 - riskFreeRate) / annVol_40 : na
sortino_40 = annDD_40  > 1e-9 ? (annRet_40 - riskFreeRate) / annDD_40  : na
omega_40   = ol_40     > 1e-9 ? og_40 / ol_40 : na
zscore_40  = sd_40     > 1e-9 ? ((wk_40 / 100) - md_40 * 5) / (sd_40 * math.sqrt(5)) : na
kelly_40   = annVol_40 > 1e-9 ? math.max(-1.0, math.min(10.0, (annRet_40 - riskFreeRate) / (annVol_40 * annVol_40))) : na

// ============================ RENDER ==============================
if barstate.islast
    // Title
    data.cell(0, 0, "Strong TOP 40 Tech AI Stocks with Advanced Stats", text_color = C_TITLE, text_size = size.large, text_halign = text.align_center)
    data.merge_cells(0, 0, 15, 0)

    // Header row
    data.cell(0, 1, 'No.', text_color = C_HEADER, bgcolor = C_HDR_BG, text_size = txtSize, text_halign = text.align_center)
    data.cell(1, 1, 'Ticker', text_color = C_HEADER, bgcolor = C_HDR_BG, text_size = txtSize, text_halign = text.align_left)
    data.cell(2, 1, 'Stock Name', text_color = C_HEADER, bgcolor = C_HDR_BG, text_size = txtSize, text_halign = text.align_left)
    data.cell(3, 1, 'Week%', text_color = C_HEADER, bgcolor = C_HDR_BG, text_size = txtSize, text_halign = text.align_right)
    data.cell(4, 1, 'Mnt%', text_color = C_HEADER, bgcolor = C_HDR_BG, text_size = txtSize, text_halign = text.align_right)
    data.cell(5, 1, 'Quarter%', text_color = C_HEADER, bgcolor = C_HDR_BG, text_size = txtSize, text_halign = text.align_right)
    data.cell(6, 1, '6Mnt%', text_color = C_HEADER, bgcolor = C_HDR_BG, text_size = txtSize, text_halign = text.align_right)
    data.cell(7, 1, '12Mnt%', text_color = C_HEADER, bgcolor = C_HDR_BG, text_size = txtSize, text_halign = text.align_right)
    data.cell(8, 1, 'YTD%', text_color = C_HEADER, bgcolor = C_HDR_BG, text_size = txtSize, text_halign = text.align_right)
    data.cell(9, 1, 'Wk Vol', text_color = C_HEADER, bgcolor = C_HDR_BG, text_size = txtSize, text_halign = text.align_right)
    data.cell(10, 1, 'Beta', text_color = C_HEADER, bgcolor = C_HDR_BG, text_size = txtSize, text_halign = text.align_right)
    data.cell(11, 1, 'Sharpe', text_color = C_HEADER, bgcolor = C_HDR_BG, text_size = txtSize, text_halign = text.align_right)
    data.cell(12, 1, 'Sortino', text_color = C_HEADER, bgcolor = C_HDR_BG, text_size = txtSize, text_halign = text.align_right)
    data.cell(13, 1, 'Omega', text_color = C_HEADER, bgcolor = C_HDR_BG, text_size = txtSize, text_halign = text.align_right)
    data.cell(14, 1, 'Z-Score', text_color = C_HEADER, bgcolor = C_HDR_BG, text_size = txtSize, text_halign = text.align_right)
    data.cell(15, 1, 'Kelly', text_color = C_HEADER, bgcolor = C_HDR_BG, text_size = txtSize, text_halign = text.align_right)

    // Build metric arrays (index 0..39 follow the constituent order above)
    weekArr = array.from(wk_1, wk_2, wk_3, wk_4, wk_5, wk_6, wk_7, wk_8, wk_9, wk_10, wk_11, wk_12, wk_13, wk_14, wk_15, wk_16, wk_17, wk_18, wk_19, wk_20, wk_21, wk_22, wk_23, wk_24, wk_25, wk_26, wk_27, wk_28, wk_29, wk_30, wk_31, wk_32, wk_33, wk_34, wk_35, wk_36, wk_37, wk_38, wk_39, wk_40)
    mntArr = array.from(mo_1, mo_2, mo_3, mo_4, mo_5, mo_6, mo_7, mo_8, mo_9, mo_10, mo_11, mo_12, mo_13, mo_14, mo_15, mo_16, mo_17, mo_18, mo_19, mo_20, mo_21, mo_22, mo_23, mo_24, mo_25, mo_26, mo_27, mo_28, mo_29, mo_30, mo_31, mo_32, mo_33, mo_34, mo_35, mo_36, mo_37, mo_38, mo_39, mo_40)
    qtrArr = array.from(qt_1, qt_2, qt_3, qt_4, qt_5, qt_6, qt_7, qt_8, qt_9, qt_10, qt_11, qt_12, qt_13, qt_14, qt_15, qt_16, qt_17, qt_18, qt_19, qt_20, qt_21, qt_22, qt_23, qt_24, qt_25, qt_26, qt_27, qt_28, qt_29, qt_30, qt_31, qt_32, qt_33, qt_34, qt_35, qt_36, qt_37, qt_38, qt_39, qt_40)
    halfArr = array.from(hf_1, hf_2, hf_3, hf_4, hf_5, hf_6, hf_7, hf_8, hf_9, hf_10, hf_11, hf_12, hf_13, hf_14, hf_15, hf_16, hf_17, hf_18, hf_19, hf_20, hf_21, hf_22, hf_23, hf_24, hf_25, hf_26, hf_27, hf_28, hf_29, hf_30, hf_31, hf_32, hf_33, hf_34, hf_35, hf_36, hf_37, hf_38, hf_39, hf_40)
    yearArr = array.from(yr_1, yr_2, yr_3, yr_4, yr_5, yr_6, yr_7, yr_8, yr_9, yr_10, yr_11, yr_12, yr_13, yr_14, yr_15, yr_16, yr_17, yr_18, yr_19, yr_20, yr_21, yr_22, yr_23, yr_24, yr_25, yr_26, yr_27, yr_28, yr_29, yr_30, yr_31, yr_32, yr_33, yr_34, yr_35, yr_36, yr_37, yr_38, yr_39, yr_40)
    ytdArr = array.from(yt_1, yt_2, yt_3, yt_4, yt_5, yt_6, yt_7, yt_8, yt_9, yt_10, yt_11, yt_12, yt_13, yt_14, yt_15, yt_16, yt_17, yt_18, yt_19, yt_20, yt_21, yt_22, yt_23, yt_24, yt_25, yt_26, yt_27, yt_28, yt_29, yt_30, yt_31, yt_32, yt_33, yt_34, yt_35, yt_36, yt_37, yt_38, yt_39, yt_40)
    volArr = array.from(wv_1, wv_2, wv_3, wv_4, wv_5, wv_6, wv_7, wv_8, wv_9, wv_10, wv_11, wv_12, wv_13, wv_14, wv_15, wv_16, wv_17, wv_18, wv_19, wv_20, wv_21, wv_22, wv_23, wv_24, wv_25, wv_26, wv_27, wv_28, wv_29, wv_30, wv_31, wv_32, wv_33, wv_34, wv_35, wv_36, wv_37, wv_38, wv_39, wv_40)
    betaArr = array.from(beta_1, beta_2, beta_3, beta_4, beta_5, beta_6, beta_7, beta_8, beta_9, beta_10, beta_11, beta_12, beta_13, beta_14, beta_15, beta_16, beta_17, beta_18, beta_19, beta_20, beta_21, beta_22, beta_23, beta_24, beta_25, beta_26, beta_27, beta_28, beta_29, beta_30, beta_31, beta_32, beta_33, beta_34, beta_35, beta_36, beta_37, beta_38, beta_39, beta_40)
    sharpeArr = array.from(sharpe_1, sharpe_2, sharpe_3, sharpe_4, sharpe_5, sharpe_6, sharpe_7, sharpe_8, sharpe_9, sharpe_10, sharpe_11, sharpe_12, sharpe_13, sharpe_14, sharpe_15, sharpe_16, sharpe_17, sharpe_18, sharpe_19, sharpe_20, sharpe_21, sharpe_22, sharpe_23, sharpe_24, sharpe_25, sharpe_26, sharpe_27, sharpe_28, sharpe_29, sharpe_30, sharpe_31, sharpe_32, sharpe_33, sharpe_34, sharpe_35, sharpe_36, sharpe_37, sharpe_38, sharpe_39, sharpe_40)
    sortinoArr = array.from(sortino_1, sortino_2, sortino_3, sortino_4, sortino_5, sortino_6, sortino_7, sortino_8, sortino_9, sortino_10, sortino_11, sortino_12, sortino_13, sortino_14, sortino_15, sortino_16, sortino_17, sortino_18, sortino_19, sortino_20, sortino_21, sortino_22, sortino_23, sortino_24, sortino_25, sortino_26, sortino_27, sortino_28, sortino_29, sortino_30, sortino_31, sortino_32, sortino_33, sortino_34, sortino_35, sortino_36, sortino_37, sortino_38, sortino_39, sortino_40)
    omegaArr = array.from(omega_1, omega_2, omega_3, omega_4, omega_5, omega_6, omega_7, omega_8, omega_9, omega_10, omega_11, omega_12, omega_13, omega_14, omega_15, omega_16, omega_17, omega_18, omega_19, omega_20, omega_21, omega_22, omega_23, omega_24, omega_25, omega_26, omega_27, omega_28, omega_29, omega_30, omega_31, omega_32, omega_33, omega_34, omega_35, omega_36, omega_37, omega_38, omega_39, omega_40)
    zArr = array.from(zscore_1, zscore_2, zscore_3, zscore_4, zscore_5, zscore_6, zscore_7, zscore_8, zscore_9, zscore_10, zscore_11, zscore_12, zscore_13, zscore_14, zscore_15, zscore_16, zscore_17, zscore_18, zscore_19, zscore_20, zscore_21, zscore_22, zscore_23, zscore_24, zscore_25, zscore_26, zscore_27, zscore_28, zscore_29, zscore_30, zscore_31, zscore_32, zscore_33, zscore_34, zscore_35, zscore_36, zscore_37, zscore_38, zscore_39, zscore_40)
    kellyArr = array.from(kelly_1, kelly_2, kelly_3, kelly_4, kelly_5, kelly_6, kelly_7, kelly_8, kelly_9, kelly_10, kelly_11, kelly_12, kelly_13, kelly_14, kelly_15, kelly_16, kelly_17, kelly_18, kelly_19, kelly_20, kelly_21, kelly_22, kelly_23, kelly_24, kelly_25, kelly_26, kelly_27, kelly_28, kelly_29, kelly_30, kelly_31, kelly_32, kelly_33, kelly_34, kelly_35, kelly_36, kelly_37, kelly_38, kelly_39, kelly_40)
    nameArr   = array.from('SharonAI', 'SanDisk', 'Rackspace Tech', 'Aehr Test', 'Ichor Holdings', 'AXT Inc', 'MaxLinear', 'Ultra Clean', 'Applied Opto', 'Vishay Inter', 'Western Digital', 'Syntec Optics', 'Atomera', 'Micron Tech', 'Seagate Tech', 'Vishay Precision', 'Marvell Tech', 'QuickLogic', 'Intel', 'DigitalOcean', 'Penguin Solut', 'Navitas Semi', 'Bandwidth', 'Wolfspeed', 'Silvaco Group', 'Dell Tech', 'Ambiq Micro', 'TTM Tech', 'Vicor', 'Cohu', 'Everspin', 'Boost Run', 'Arteris', 'Veeco Instr', 'ACM Research', 'ChronoScale', 'FormFactor', 'Keel Infra', 'Kulicke Soffa', 'Viavi Solut')
    tickerArr = array.from('SHAZ', 'SNDK', 'RXT', 'AEHR', 'ICHR', 'AXTI', 'MXL', 'UCTT', 'AAOI', 'VSH', 'WDC', 'OPTX', 'ATOM', 'MU', 'STX', 'VPG', 'MRVL', 'QUIK', 'INTC', 'DOCN', 'PENG', 'NVTS', 'BAND', 'WOLF', 'SVCO', 'DELL', 'AMBQ', 'TTMI', 'VICR', 'COHU', 'MRAM', 'BRUN', 'AIP', 'VECO', 'ACMR', 'CHRN', 'FORM', 'KEEL', 'KLIC', 'VIAV')

    // Choose sort key, replacing na with a sentinel so it sinks to the bottom
    baseArr = sortBy == 'Week%' ? weekArr : sortBy == 'Mnt%' ? mntArr : sortBy == 'Quarter%' ? qtrArr : sortBy == '6Mnt%' ? halfArr : sortBy == '12Mnt%' ? yearArr : ytdArr
    keyArr = array.new<float>()
    for i = 0 to 39
        v = baseArr.get(i)
        keyArr.push(na(v) ? -1e15 : v)
    sorted = array.sort_indices(keyArr, order.descending)

    for i = 0 to 39
        si    = sorted.get(i)
        rowBg = getRowColor(i)
        data.cell(0,  i + 2, str.tostring(i + 1),                 bgcolor = rowBg, text_color = C_NUM,    text_size = txtSize, text_halign = text.align_center)
        data.cell(1,  i + 2, array.get(tickerArr, si),            bgcolor = rowBg, text_color = C_TICKER, text_size = txtSize, text_halign = text.align_left)
        data.cell(2,  i + 2, array.get(nameArr, si),              bgcolor = rowBg, text_color = C_NAME,   text_size = txtSize, text_halign = text.align_left)
        data.cell(3,  i + 2, f_pct(array.get(weekArr, si)),       bgcolor = rowBg, text_color = getPerfColor(array.get(weekArr, si)),  text_size = txtSize, text_halign = text.align_right)
        data.cell(4,  i + 2, f_pct(array.get(mntArr, si)),        bgcolor = rowBg, text_color = getPerfColor(array.get(mntArr, si)),   text_size = txtSize, text_halign = text.align_right)
        data.cell(5,  i + 2, f_pct(array.get(qtrArr, si)),        bgcolor = rowBg, text_color = getPerfColor(array.get(qtrArr, si)),   text_size = txtSize, text_halign = text.align_right)
        data.cell(6,  i + 2, f_pct(array.get(halfArr, si)),       bgcolor = rowBg, text_color = getPerfColor(array.get(halfArr, si)),  text_size = txtSize, text_halign = text.align_right)
        data.cell(7,  i + 2, f_pct(array.get(yearArr, si)),       bgcolor = rowBg, text_color = getPerfColor(array.get(yearArr, si)),  text_size = txtSize, text_halign = text.align_right)
        data.cell(8,  i + 2, f_pct(array.get(ytdArr, si)),        bgcolor = rowBg, text_color = getPerfColor(array.get(ytdArr, si)),   text_size = txtSize, text_halign = text.align_right)
        data.cell(9,  i + 2, f_num(array.get(volArr, si)),        bgcolor = rowBg, text_color = C_STAT,  text_size = txtSize, text_halign = text.align_right)
        data.cell(10, i + 2, f_num(array.get(betaArr, si)),       bgcolor = rowBg, text_color = C_STAT,  text_size = txtSize, text_halign = text.align_right)
        data.cell(11, i + 2, f_num(array.get(sharpeArr, si)),     bgcolor = rowBg, text_color = C_STAT,  text_size = txtSize, text_halign = text.align_right)
        data.cell(12, i + 2, f_num(array.get(sortinoArr, si)),    bgcolor = rowBg, text_color = C_STAT,  text_size = txtSize, text_halign = text.align_right)
        data.cell(13, i + 2, f_num(array.get(omegaArr, si)),      bgcolor = rowBg, text_color = C_STAT,  text_size = txtSize, text_halign = text.align_right)
        data.cell(14, i + 2, f_num(array.get(zArr, si)),          bgcolor = rowBg, text_color = C_STAT,  text_size = txtSize, text_halign = text.align_right)
        data.cell(15, i + 2, f_num(array.get(kellyArr, si)),      bgcolor = rowBg, text_color = C_STAT,  text_size = txtSize, text_halign = text.align_right)
````

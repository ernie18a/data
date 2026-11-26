# Swing Data Pro - Intraday Trend and Relative Strength Dashboard

- url: https://www.tradingview.com/script/8t1ElMVB-Swing-Data-Pro-Intraday-Trend-and-Relative-Strength-Dashboard/
- type: indicator
- pine_id: PUB;09574f0aed124c339e5573a67c4b93d9
- version: 1.0

## Description

Swing Data Pro is a clean decision-support dashboard built for traders who want to combine intraday structure with higher-quality context before entering a trade.

This script is designed to help you quickly answer the most important questions:
- Is the stock acting bullish, bearish, or mixed right now?
- Is the move confirmed by volume and participation?
- Is the broader market helping or fighting the trade?
- Has the stock already used too much of its normal daily range?
- Is this ticker showing real relative strength, or is it just moving with noise?

Instead of relying on one signal, this tool organizes multiple layers of information into one compact panel so you can make faster and more structured decisions.

MAIN FEATURES

1) Setup Score
A quick snapshot score built from key quality inputs such as relative strength, volume, and range behavior.
This helps rank the overall quality of the setup at a glance.

2) ADR%, Day Range %, and ADR Used %
ADR% shows the stock’s average daily range.
Day Range % shows how much the stock has ranged today.
ADR Used % shows how much of the stock’s normal daily range has already been used.

Why this matters:
If a stock already used most of its typical daily range, the move may be getting extended and harder to chase.

3) ATR%, Day Move %, ATR Used %, and ATR ($)
ATR% helps compare daily movement across stocks with different prices.
Day Move % shows the move from today’s open to the current price.
ATR Used % helps show how much of the stock’s typical move has already been consumed.
ATR ($) helps estimate normal dollar movement for stops and targets.

4) Relative Volume (RVol)
This script uses intraday relative volume logic so participation is more relevant for active trading.
That makes RVol more useful for intraday entries instead of only relying on broad daily comparisons.

5) U/D Volume Ratio
The U/D reading is used as a pressure gauge to see whether buying or selling volume is more dominant.
This helps separate real trend participation from weak or unstable movement.

6) Relative Strength (RS)
The RS reading is designed to show whether the stock is outperforming the broader market.
In general, stronger RS names are often better candidates for long setups, while weak RS names are often lower quality for longs.

7) Trend Bias
Trend Bias simplifies price structure into:
- Bullish
- Bearish
- Mixed

This is based on how price is behaving relative to important structure such as today’s open and VWAP.
It is meant to answer one simple question:
“What is price doing right now?”

8) Trend Day
Trend Day is the confirmation layer.
This helps determine whether the current directional bias is being supported by participation conditions such as volume and U/D.
Possible outputs include:
- BULL TREND
- BEAR TREND
- BALANCED

This is useful because a stock can look bullish on price structure alone, but still not have enough participation to qualify as a stronger trend day.

9) Market Confirm
The Market Confirm row checks broader alignment using:
- SPY
- QQQ
- BTC
- Sector ETF

This helps you quickly judge whether the wider environment is supportive or conflicting.
A bullish individual stock setup is generally stronger when the broader market and sector are aligned.

10) VIX Label
The VIX row shows the actual VIX price and daily direction.
If VIX is rising, that often signals increasing market stress.
If VIX is falling, that often supports better risk appetite.
The row is color-coded for easier reading.

11) Key Levels
The script can display key reference levels such as:
- Today’s Open
- Yesterday’s High / Low
- Pre-Market High / Low
- VWAP
- This Week High / Low
- Last Week High / Low

These levels are useful for planning entries, exits, breakdowns, reclaims, and rejection areas.

12) Moving Averages
Optional EMA and SMA overlays are included for traders who want moving-average structure directly on the chart.

13) Candle Pattern Detection
The script includes optional bullish candle pattern highlights to help identify useful reversal or continuation candles.

HOW TO USE IT

A simple workflow:

Step 1:
Check Trend Bias.
This gives you the immediate structural read:
Bullish, Bearish, or Mixed.

Step 2:
Check Trend Day.
This tells you whether participation confirms the move or whether the stock is still more balanced.

Step 3:
Check Market Confirm.
Look at SPY, QQQ, BTC, and the sector ETF.
The best trades often happen when the stock and broader market are aligned.

Step 4:
Check RVol and U/D.
Strong trends usually look better when both participation and pressure support the move.

Step 5:
Check ADR Used % and ATR Used %.
These help you avoid chasing moves that may already be too extended.

Step 6:
Use the key levels.
Look for reclaims, breakouts, pullbacks, holds, or failures around important reference levels.

PRACTICAL INTERPRETATION

For long ideas:
- Trend Bias should preferably be Bullish
- Trend Day should ideally improve toward BULL TREND
- Market Confirm should lean positive
- RVol and U/D should support the move
- ADR Used % should not be overly stretched if you are entering late

For short ideas:
- Trend Bias should preferably be Bearish
- Trend Day should ideally improve toward BEAR TREND
- Market Confirm should lean negative
- Participation should support downside pressure
- Avoid forcing shorts if the broader market is strongly risk-on

WHO THIS IS FOR

This script is best suited for:
- Intraday traders
- Momentum traders
- Breakout traders
- Pullback traders
- Swing traders who want a stronger intraday timing panel

It is not meant to be a fully automated buy/sell system.
It is a structured decision-support tool designed to improve context, timing, and trade filtering.

NOTES

- No indicator should be used alone.
- Always combine signal quality with price action, levels, risk management, and your own trading plan.
- This script is for educational and decision-support purposes only and is not financial advice.

## Source Code

````pine
//@version=6
indicator(title='Swing Data Pro — ADR% / RVol / RS Rating & More', shorttitle='SwingPro', overlay=true, max_bars_back=253)
import TradingView/ta/12 as tvta

// ═══════════════════════════════════════════════════════════════
// 🔒 DAILY LOCK
// ═══════════════════════════════════════════════════════════════
lock_daily = input(true,
     title='🔒 Lock All Metrics to Daily TF',
     group='🔒 Daily Lock',
     tooltip='ON = keeps core swing metrics locked to DAILY data even on intraday charts.\n\nRecommended for swing trading.')

// ═══════════════════════════════════════════════════════════════
// 🕯️ CANDLE PATTERNS
// ═══════════════════════════════════════════════════════════════
// — Pattern toggles ──────────────────────────────────────────
show_engulfing      = input(true,  title='Show Bullish Engulfing',    group='🕯️ Candle Patterns')
show_doji           = input(true,  title='Show Dragonfly Doji',       group='🕯️ Candle Patterns')
show_morningstar    = input(true,  title='Show Morning Star',         group='🕯️ Candle Patterns')
show_piercing       = input(true,  title='Show Piercing Line',        group='🕯️ Candle Patterns')
show_hammer         = input(true,  title='Show Hammer',               group='🕯️ Candle Patterns')
show_harami         = input(true,  title='Show Bullish Harami',       group='🕯️ Candle Patterns')
show_three_soldiers = input(true,  title='Show Three White Soldiers', group='🕯️ Candle Patterns')

// — Pattern candle colors ────────────────────────────────────
engulf_col_conf      = input(color.rgb(27, 94, 32),   title='Engulfing Color',      group='🕯️ Candle Patterns')
doji_col_conf        = input(color.rgb(0, 96, 100),   title='Dragonfly Color',      group='🕯️ Candle Patterns')
morningstar_col_conf = input(color.rgb(74, 20, 140),  title='Morning Star Color',   group='🕯️ Candle Patterns')
piercing_col_conf    = input(color.rgb(230, 81, 0),   title='Piercing Color',       group='🕯️ Candle Patterns')
hammer_col_conf      = input(color.rgb(21, 101, 192), title='Hammer Color',         group='🕯️ Candle Patterns')
harami_col_conf      = input(color.rgb(0, 121, 107),  title='Bullish Harami Color', group='🕯️ Candle Patterns')
soldiers_col_conf    = input(color.rgb(130, 119, 23), title='3 Soldiers Color',     group='🕯️ Candle Patterns')
multi_col_conf       = input(color.rgb(245, 127, 23), title='Multiple Color',       group='🕯️ Candle Patterns')

// ═══════════════════════════════════════════════════════════════
// 🎨 TABLE STYLE
// ═══════════════════════════════════════════════════════════════
show_lock_row    = input(false, title='Show Daily Lock Row',  group='🎨 Table Style')

txt_col = input(color.rgb(0, 0, 0), title='Text Color', group='🎨 Table Style')

posTable = input.string('Top Right',
     title='Position',
     options=['Top Left', 'Top Right', 'Bottom Left', 'Bottom Right'],
     group='🎨 Table Style')

tbl_size = input.string('Tiny',
     title='Size',
     options=['Tiny', 'Small', 'Normal', 'Large'],
     group='🎨 Table Style')

bg_col = input(color.new(color.black, 100),
     title='Background',
     group='🎨 Table Style')

show_empty_row = input(false,
     title='Empty row at top (prevents icon overlap)',
     group='🎨 Table Style')

// ═══════════════════════════════════════════════════════════════
// 🎨 COLORS
// ═══════════════════════════════════════════════════════════════
col_positive  = input(color.rgb(76, 175, 80),  title='Strong / Positive',   group='🎨 Colors')
col_neutral   = input(color.rgb(255, 152, 0),  title='Neutral / Medium',    group='🎨 Colors')
col_negative  = input(color.rgb(244, 67, 54),  title='Weak / Negative',     group='🎨 Colors')
col_elite     = input(color.rgb(255, 215, 0),  title='Elite (Gold)',         group='🎨 Colors')
sector_chg_Up = input(color.rgb(76, 175, 80),  title='Sector Positive Chg', group='🎨 Colors')
sector_chg_Dn = input(color.rgb(244, 67, 54),  title='Sector Negative Chg', group='🎨 Colors')

// ═══════════════════════════════════════════════════════════════
// 📋 DISPLAY TOGGLES
// ═══════════════════════════════════════════════════════════════
show_setupScore   = input(true,  title='⭐ Setup Score',          group='📋 Display')
show_mktCap       = input(false, title='Market Cap',             group='📋 Display')
show_float        = input(false, title='Shares Float',           group='📋 Display')
show_floatpercent = input(false, title='Float %',                group='📋 Display')
show_adrp         = input(true,  title='ADR% (Avg Daily Range)', group='📋 Display', tooltip='Average daily high-to-low range over the lookback period. Higher ADR% means the stock normally moves more each day.')
show_dayRange     = input(true,  title='Day Range %',            group='📋 Display', tooltip='Shows the current intraday range from todays low to todays high. Compare this against ADR% to see how much range has already been used.')
show_adrUsed      = input(true,  title='ADR Used %',             group='📋 Display', tooltip='Shows how much of the normal daily range has already been used today. 100%+ means the move is becoming extended.')
show_atrPer       = input(true,  title='ATR%',                   group='📋 Display', tooltip='Average True Range as a percent of price. Helps compare normal movement across stocks with different prices.')
show_dayMove      = input(true,  title='Day Move %',             group='📋 Display', tooltip='Current move from todays open to the current price. Positive means price is above the open; negative means price is below it.')
show_atrUsed      = input(true,  title='ATR Used %',             group='📋 Display', tooltip='Shows how much of the typical ATR move has already been used today based on the current move from the open.')
show_atr          = input(true,  title='ATR ($)',                group='📋 Display', tooltip='Average True Range in dollars. Helps estimate normal dollar movement for stop placement and target sizing.')
show_ipo_date     = input(false, title='IPO Timer',              group='📋 Display')
show_lod_dist     = input(true,  title='LoD Distance',           group='📋 Display')
show_lod_price    = input(false, title='LoD Price',              group='📋 Display')
show_dist_high    = input(false, title='Off 52W High',           group='📋 Display')
show_dist_low     = input(false, title='Above 52W Low',          group='📋 Display')
show_ADVS         = input(false, title='Avg $ Volume',           group='📋 Display')
show_ADV          = input(true,  title='Avg Volume (Shares)',    group='📋 Display')
show_projectedVol = input(false, title='Projected Volume',       group='📋 Display')
show_relVol       = input(true,  title='Relative Volume',        group='📋 Display', tooltip='Current-chart-timeframe RVol. In At Time mode it compares current cumulative session volume to the historical average at the same time-of-day. In Simple TF mode it compares the current bar volume to the average bar volume on the current chart timeframe.')
show_volBuzz      = input(false, title='Vol. Buzz',              group='📋 Display')
show_UDratio      = input(true,  title='U/D Volume Ratio',       group='📋 Display', tooltip='Uses current chart timeframe volume. On a 5m chart it sums 5m bars; on a 15m chart it sums 15m bars. Above 1.0 favors buyers; below 1.0 favors sellers.')
show_rs_rating    = input(true,  title='RS Rating',              group='📋 Display', tooltip='Relative strength versus the S&P 500. Higher readings mean the stock is outperforming the market.')
show_trendBias    = input(true,  title='Trend Bias',             group='📋 Display', tooltip='Price structure only. Bullish = above todays open and above VWAP. Bearish = below todays open and below VWAP. Mixed = anything else.')
show_trendDay     = input(true,  title='Trend Day',              group='📋 Display', tooltip='Confirmation layer. BULL TREND = Bullish bias plus enough RVol and U/D. BEAR TREND = Bearish bias plus enough RVol and U/D. BALANCED = structure exists but confirmation is not strong enough yet.')
show_mktConfirm   = input(true,  title='Mkt Confirm',            group='📋 Display', tooltip='Checks SPY, QQQ, BTC, and the sector ETF. More plus signs = better alignment for long trades. More minus signs = worse alignment for longs.')
show_vixLabel     = input(true,  title='VIX',                    group='📋 Display', tooltip='Shows the current VIX price and todays percent change. VIX up = red, VIX down = green.')
show_liqCap       = input(false, title='Liquidity Cap (Shares)', group='📋 Display')
show_sector       = input(false, title='Sector',                 group='📋 Display')
show_ind          = input(false, title='Industry Group',         group='📋 Display')
show_selectSector = input(true,  title='Sector ETF + Change',    group='📋 Display')
show_sector_rs    = input(true,  title='Sector RS Rating',       group='📋 Display')

// ═══════════════════════════════════════════════════════════════
// ⚙️ PARAMETERS
// ═══════════════════════════════════════════════════════════════
adrp_len = input.int(20, title='ADR% Length (bars)',         group='⚙️ Parameters', minval=5,  maxval=60)
atr_len  = input.int(14, title='ATR Length (bars)',          group='⚙️ Parameters', minval=1,  maxval=50)
len      = input.int(50, title='Volume MA Length',           group='⚙️ Parameters', minval=10, maxval=200)
rvol_len = input.int(20, title='RVol Average Length (bars)', group='⚙️ Parameters', minval=1,  maxval=200)

rvol_mode = input.string('At Time',
     title='RVol Style',
     options=['At Time', 'Simple TF'],
     group='⚙️ Parameters',
     tooltip='At Time = compares current cumulative volume to the historical average at the same time offset in prior sessions on the current chart timeframe. Simple TF = compares the current bar volume to the average bar volume on the current chart timeframe.')

rvol_adjust_realtime = input.bool(true,
     title='RVol Realtime Adjust',
     group='⚙️ Parameters',
     tooltip='Only used in At Time mode. When ON, estimates the cumulative in-progress bar value in real time.')

// ═══════════════════════════════════════════════════════════════
// 📈 TREND SETTINGS
// ═══════════════════════════════════════════════════════════════
trend_ud_len = input.int(20,
     title='U/D Length (bars)',
     group='📈 Trend Settings',
     minval=2,
     maxval=200,
     tooltip='Used for the U/D ratio and Trend Day confirmation. This uses the current chart timeframe bars.')

trend_bull_rvol_min = input.float(100.0,
     title='Bull Trend RVol Min',
     group='📈 Trend Settings',
     minval=0,
     step=1,
     tooltip='Minimum Relative Volume needed before a Bullish bias can become a BULL TREND.')

trend_bull_ud_min = input.float(1.10,
     title='Bull Trend U/D Min',
     group='📈 Trend Settings',
     minval=0,
     step=0.05,
     tooltip='Minimum U/D ratio needed before a Bullish bias can become a BULL TREND.')

trend_bear_rvol_min = input.float(100.0,
     title='Bear Trend RVol Min',
     group='📈 Trend Settings',
     minval=0,
     step=1,
     tooltip='Minimum Relative Volume needed before a Bearish bias can become a BEAR TREND.')

trend_bear_ud_max = input.float(0.90,
     title='Bear Trend U/D Max',
     group='📈 Trend Settings',
     minval=0,
     step=0.05,
     tooltip='Maximum U/D ratio allowed before a Bearish bias can become a BEAR TREND.')

btc_confirm_symbol = input.symbol('BINANCE:BTCUSDT',
     title='BTC Confirm Symbol',
     group='📈 Trend Settings',
     tooltip='Symbol used for BTC market confirmation in the Mkt Confirm row.')

vix_symbol = input.symbol('CBOE:VIX',
     title='VIX Symbol',
     group='📈 Trend Settings',
     tooltip='Symbol used for the VIX row.')

// ═══════════════════════════════════════════════════════════════
// 📍 KEY PRICE LEVELS
// ═══════════════════════════════════════════════════════════════
show_levels      = input(true,  title='Show Key Levels Panel',  group='📍 Key Levels')
show_level_lines = input(true,  title='Show Lines on Chart',    group='📍 Key Levels')
level_line_width = input.int(1, title='Line Width', minval=1, maxval=3, group='📍 Key Levels')
level_line_style = input.string('Solid', title='Line Style',
     options=['Solid', 'Dashed', 'Dotted', 'Arrow Right', 'Arrow Left'],
     group='📍 Key Levels')
line_mode        = input.string('Most recent day',
     title='Line Reach',
     options=['Most recent day', 'Across the chart'],
     group='📍 Key Levels',
     tooltip='Most recent day = line starts from the beginning of today only.\n\nAcross the chart = line extends back the number of days you set below.')
line_lookback_days = input.int(3,
     title='Lookback Days (Across the chart mode)',
     minval=1, maxval=30,
     group='📍 Key Levels',
     tooltip='How many days back the level lines extend when in Across the chart mode.')

// — Label settings ───────────────────────────────────────────
show_level_labels  = input(true,  title='Show Right-Side Labels', group='📍 Key Levels')
level_label_size   = input.string('Small', title='Label Font Size',
     options=['Tiny','Small','Normal','Large','Huge'], group='📍 Key Levels')
level_label_font_col = input(color.new(#FFFFFF, 0), title='Label Font Color', group='📍 Key Levels',
     tooltip='Set to match each line color or use a single global font color for all labels.')
level_label_offset = input.int(3, title='Label Offset (bars right)',
     minval=0, maxval=20, group='📍 Key Levels')

// — Per level: toggle + color ────────────────────────────────
show_level_CDO  = input(true,  title='Show CDO  — Today Open',      group='📍 Key Levels')
col_CDO         = input(color.new(#26C6DA, 0),   title='CDO Color', group='📍 Key Levels')

show_level_PDH  = input(true,  title='Show PDH  — Yesterday High',  group='📍 Key Levels')
col_PDH         = input(color.new(#EF5350, 0),   title='PDH Color', group='📍 Key Levels')

show_level_PDL  = input(true,  title='Show PDL  — Yesterday Low',   group='📍 Key Levels')
col_PDL         = input(color.new(#66BB6A, 0),   title='PDL Color', group='📍 Key Levels')

show_level_PMH  = input(true,  title='Show PMH  — Pre Mkt High',    group='📍 Key Levels')
col_PMH         = input(color.new(#FFD700, 0),   title='PMH Color', group='📍 Key Levels')

show_level_PML  = input(true,  title='Show PML  — Pre Mkt Low',     group='📍 Key Levels')
col_PML         = input(color.new(#FF6D00, 0),   title='PML Color', group='📍 Key Levels')

show_level_VWAP = input(true,  title='Show VWAP — Session VWAP',    group='📍 Key Levels')
col_VWAP        = input(color.new(#CE93D8, 0),   title='VWAP Color',group='📍 Key Levels')

show_level_TWH  = input(true,  title='Show TWH  — This Week High',  group='📍 Key Levels')
col_TWH         = input(color.new(#80DEEA, 0),   title='TWH Color', group='📍 Key Levels')

show_level_TWL  = input(true,  title='Show TWL  — This Week Low',   group='📍 Key Levels')
col_TWL         = input(color.new(#80CBC4, 0),   title='TWL Color', group='📍 Key Levels')

show_level_LWH  = input(true,  title='Show LWH  — Last Week High',  group='📍 Key Levels')
col_LWH         = input(color.new(#81D4FA, 0),   title='LWH Color', group='📍 Key Levels')

show_level_LWL  = input(false, title='Show LWL  — Last Week Low',   group='📍 Key Levels')
col_LWL         = input(color.new(#A5D6A7, 0),   title='LWL Color', group='📍 Key Levels')

// ═══════════════════════════════════════════════════════════════
// 📈 MOVING AVERAGES
// ═══════════════════════════════════════════════════════════════
// — EMA 1 ───────────────────────────────────────────────────
ema1_show  = input(true,  title='Show EMA 1',      group='📈 Moving Averages')
ema1_len   = input.int(8, title='EMA 1 Length',    group='📈 Moving Averages', minval=1)
ema1_col   = input(color.new(#00E5FF, 0), title='EMA 1 Color', group='📈 Moving Averages')
ema1_width = input.int(2, title='EMA 1 Thickness', group='📈 Moving Averages', minval=1, maxval=4)

// — EMA 2 ───────────────────────────────────────────────────
ema2_show  = input(true,   title='Show EMA 2',      group='📈 Moving Averages')
ema2_len   = input.int(21, title='EMA 2 Length',    group='📈 Moving Averages', minval=1)
ema2_col   = input(color.new(#FF6D00, 0), title='EMA 2 Color', group='📈 Moving Averages')
ema2_width = input.int(2,  title='EMA 2 Thickness', group='📈 Moving Averages', minval=1, maxval=4)

// — EMA 3 ───────────────────────────────────────────────────
ema3_show  = input(false,  title='Show EMA 3',      group='📈 Moving Averages')
ema3_len   = input.int(50, title='EMA 3 Length',    group='📈 Moving Averages', minval=1)
ema3_col   = input(color.new(#FF1744, 0), title='EMA 3 Color', group='📈 Moving Averages')
ema3_width = input.int(2,  title='EMA 3 Thickness', group='📈 Moving Averages', minval=1, maxval=4)

// — SMA 1 ───────────────────────────────────────────────────
sma1_show  = input(false,  title='Show SMA 1',      group='📈 Moving Averages')
sma1_len   = input.int(20, title='SMA 1 Length',    group='📈 Moving Averages', minval=1)
sma1_col   = input(color.new(#69F0AE, 0), title='SMA 1 Color', group='📈 Moving Averages')
sma1_width = input.int(2,  title='SMA 1 Thickness', group='📈 Moving Averages', minval=1, maxval=4)

// — SMA 2 ───────────────────────────────────────────────────
sma2_show  = input(false,  title='Show SMA 2',      group='📈 Moving Averages')
sma2_len   = input.int(50, title='SMA 2 Length',    group='📈 Moving Averages', minval=1)
sma2_col   = input(color.new(#EA80FC, 0), title='SMA 2 Color', group='📈 Moving Averages')
sma2_width = input.int(2,  title='SMA 2 Thickness', group='📈 Moving Averages', minval=1, maxval=4)

// — SMA 3 ───────────────────────────────────────────────────
sma3_show  = input(false,   title='Show SMA 3',      group='📈 Moving Averages')
sma3_len   = input.int(200, title='SMA 3 Length',    group='📈 Moving Averages', minval=1)
sma3_col   = input(color.new(#FFEB3B, 0), title='SMA 3 Color', group='📈 Moving Averages')
sma3_width = input.int(2,   title='SMA 3 Thickness', group='📈 Moving Averages', minval=1, maxval=4)

// ═══════════════════════════════════════════════════════════════
// ⏱ DAILY DATA
// ═══════════════════════════════════════════════════════════════
s = syminfo.tickerid

closeDa = request.security(s, 'D', close)
openDa  = request.security(s, 'D', open)
highDa  = request.security(s, 'D', high)
lowDa   = request.security(s, 'D', low)
volDa   = request.security(s, 'D', volume)
maDa      = request.security(s, 'D', ta.sma(volume, len))
rvolAvgDa = request.security(s, 'D', ta.sma(volume[1], rvol_len))

arpDa  = 100 * (request.security(s, 'D', ta.sma(high / low, adrp_len)) - 1)
atrDa  = request.security(s, 'D', ta.atr(atr_len))
atrpDa = 100 * (atrDa / closeDa)

ema8Da  = request.security(s, 'D', ta.ema(close, 8))
ema21Da = request.security(s, 'D', ta.ema(close, 21))

// ═══════════════════════════════════════════════════════════════
// 📈 MA CALCULATIONS & PLOTS
// ═══════════════════════════════════════════════════════════════
ema1_val = ta.ema(close, ema1_len)
ema2_val = ta.ema(close, ema2_len)
ema3_val = ta.ema(close, ema3_len)
sma1_val = ta.sma(close, sma1_len)
sma2_val = ta.sma(close, sma2_len)
sma3_val = ta.sma(close, sma3_len)

plot(ema1_show ? ema1_val : na, title='EMA 1', color=ema1_col, linewidth=ema1_width)
plot(ema2_show ? ema2_val : na, title='EMA 2', color=ema2_col, linewidth=ema2_width)
plot(ema3_show ? ema3_val : na, title='EMA 3', color=ema3_col, linewidth=ema3_width)
plot(sma1_show ? sma1_val : na, title='SMA 1', color=sma1_col, linewidth=sma1_width)
plot(sma2_show ? sma2_val : na, title='SMA 2', color=sma2_col, linewidth=sma2_width)
plot(sma3_show ? sma3_val : na, title='SMA 3', color=sma3_col, linewidth=sma3_width)

// ═══════════════════════════════════════════════════════════════
// 📈 RVOL
// ═══════════════════════════════════════════════════════════════
time_left_da   = request.security(s, 'D', (time_close - timenow) / 1000.0)
time_passed_da = request.security(s, 'D', (timenow - time) / 1000.0)

vol_proj_da_raw = volDa
if time_left_da > 0 and time_passed_da > 0
    vol_proj_da_raw := volDa + (volDa / time_passed_da * time_left_da)

[currVolAtTime, avgVolAtTime, rvolRatioAtTime] = tvta.relativeVolume(rvol_len, 'D', true, rvol_adjust_realtime)
avgVolTf = ta.sma(volume[1], rvol_len)

useAtTimeRvol = timeframe.isintraday and rvol_mode == 'At Time'
relVol_tf   = useAtTimeRvol ? (na(rvolRatioAtTime) ? float(na) : math.round(rvolRatioAtTime * 100.0)) : avgVolTf != 0 ? math.round((volume / avgVolTf) * 100.0) : float(na)
volBuzz_tf  = useAtTimeRvol ? (na(rvolRatioAtTime) ? float(na) : 100.0 * (rvolRatioAtTime - 1.0))     : avgVolTf != 0 ? 100.0 * (volume / avgVolTf - 1.0)      : float(na)

relVol_da   = relVol_tf
volBuzz_da  = volBuzz_tf

// ═══════════════════════════════════════════════════════════════
// 🕯️ PATTERN DETECTION
// ═══════════════════════════════════════════════════════════════
p_close     = request.security(s, 'D', close,                lookahead=barmerge.lookahead_off)
p_open      = request.security(s, 'D', open,                 lookahead=barmerge.lookahead_off)
p_high      = request.security(s, 'D', high,                 lookahead=barmerge.lookahead_off)
p_low       = request.security(s, 'D', low,                  lookahead=barmerge.lookahead_off)
p_confirmed = request.security(s, 'D', barstate.isconfirmed, lookahead=barmerge.lookahead_off)

p_body      = math.abs(p_close - p_open)
p_lowerWick = math.min(p_open, p_close) - p_low
p_upperWick = p_high - math.max(p_open, p_close)
p_range     = p_high - p_low
p_isBullish = p_close > p_open

p_has_hist_1 = not na(p_open[1]) and not na(p_close[1]) and not na(p_low[1]) and not na(p_high[1])
p_has_hist_2 = p_has_hist_1 and not na(p_open[2]) and not na(p_close[2]) and not na(p_low[2]) and not na(p_high[2])

p_prev_body  = p_has_hist_1 ? math.abs(p_close[1] - p_open[1]) : float(na)
p_prev_range = p_has_hist_1 ? (p_high[1] - p_low[1])           : float(na)
p_engulfing  = show_engulfing and p_has_hist_1
     and p_isBullish
     and p_close[1] < p_open[1]
     and p_open  <= math.min(p_open[1], p_close[1])
     and p_close >= math.max(p_open[1], p_close[1])
     and p_body  >= p_prev_body * 1.10
     and p_prev_range > 0 and p_prev_body >= p_prev_range * 0.35
     and p_body >= p_range * 0.45

p_doji = show_doji
     and p_range > 0
     and p_body      <= p_range * 0.05
     and p_lowerWick >= p_range * 0.65
     and p_upperWick <= p_range * 0.05

p_ms_c1_body  = p_has_hist_2 ? math.abs(p_close[2] - p_open[2])   : float(na)
p_ms_c1_range = p_has_hist_2 ? (p_high[2] - p_low[2])             : float(na)
p_ms_c1_top   = p_has_hist_2 ? math.min(p_open[2], p_close[2])    : float(na)
p_ms_c1_mid   = p_has_hist_2 ? p_ms_c1_top + p_ms_c1_body * 0.55 : float(na)
p_morningstar = show_morningstar and p_has_hist_2
     and p_close[2] < p_open[2]
     and p_ms_c1_range > 0 and p_ms_c1_body >= p_ms_c1_range * 0.35
     and math.abs(p_close[1] - p_open[1]) <= p_ms_c1_body * 0.25
     and p_isBullish
     and p_close >= p_ms_c1_mid
     and p_body >= p_range * 0.45

p_pl_c1_body  = p_has_hist_1 ? math.abs(p_close[1] - p_open[1])  : float(na)
p_pl_c1_range = p_has_hist_1 ? (p_high[1] - p_low[1])             : float(na)
p_pl_c1_bot   = p_has_hist_1 ? math.min(p_open[1], p_close[1])    : float(na)
p_pl_c1_mid   = p_has_hist_1 ? p_pl_c1_bot + p_pl_c1_body * 0.50 : float(na)
p_piercing = show_piercing and p_has_hist_1
     and p_close[1] < p_open[1]
     and p_pl_c1_range > 0 and p_pl_c1_body >= p_pl_c1_range * 0.35
     and p_open < p_low[1]
     and p_isBullish
     and p_close >= p_pl_c1_mid
     and p_close < p_open[1]
     and p_body >= p_range * 0.45

p_hammer = show_hammer and p_has_hist_1
     and p_range > 0
     and p_body      <= p_range * 0.28
     and p_lowerWick >= p_body  * 2.0
     and p_upperWick <= p_range * 0.08
     and math.min(p_open, p_close) >= p_low + p_range * 0.55
     and p_close[1] < p_open[1]

p_har_prev_body  = p_has_hist_1 ? math.abs(p_close[1] - p_open[1]) : float(na)
p_har_prev_range = p_has_hist_1 ? (p_high[1] - p_low[1])            : float(na)
p_harami = show_harami and p_has_hist_1
     and p_close[1] < p_open[1]
     and p_har_prev_range > 0 and p_har_prev_body >= p_har_prev_range * 0.35
     and p_isBullish
     and p_open  > math.min(p_open[1], p_close[1])
     and p_close < math.max(p_open[1], p_close[1])
     and p_body  <= p_har_prev_body * 0.60

p_sol_r0  = p_high    - p_low
p_sol_r1  = p_high[1] - p_low[1]
p_sol_r2  = p_high[2] - p_low[2]
p_sol_ok0 = p_sol_r0 > 0 and math.abs(p_close    - p_open)    >= p_sol_r0 * 0.55 and (p_high    - p_close)    <= p_sol_r0 * 0.20
p_sol_ok1 = p_sol_r1 > 0 and math.abs(p_close[1] - p_open[1]) >= p_sol_r1 * 0.55 and (p_high[1] - p_close[1]) <= p_sol_r1 * 0.20
p_sol_ok2 = p_sol_r2 > 0 and math.abs(p_close[2] - p_open[2]) >= p_sol_r2 * 0.55 and (p_high[2] - p_close[2]) <= p_sol_r2 * 0.20

p_three_soldiers = show_three_soldiers and p_has_hist_2
     and p_close[2] > p_open[2]
     and p_close[1] > p_open[1]
     and p_isBullish
     and p_close[1] > p_close[2]
     and p_close    > p_close[1]
     and p_open[1]  > p_open[2] and p_open[1] < p_close[2]
     and p_open     > p_open[1] and p_open    < p_close[1]
     and p_sol_ok0 and p_sol_ok1 and p_sol_ok2

p_count = (p_engulfing ? 1 : 0) + (p_doji ? 1 : 0) + (p_morningstar ? 1 : 0) + (p_piercing ? 1 : 0) + (p_hammer ? 1 : 0) + (p_harami ? 1 : 0) + (p_three_soldiers ? 1 : 0)
p_any   = p_count > 0

f_conf_color(_count, _engulf, _doji, _ms, _pierce, _hammer, _harami, _soldiers) =>
    color _c = na
    if _count >= 2
        _c := multi_col_conf
    else if _engulf
        _c := engulf_col_conf
    else if _soldiers
        _c := soldiers_col_conf
    else if _ms
        _c := morningstar_col_conf
    else if _pierce
        _c := piercing_col_conf
    else if _harami
        _c := harami_col_conf
    else if _hammer
        _c := hammer_col_conf
    else if _doji
        _c := doji_col_conf
    _c

conf_col = f_conf_color(p_count, p_engulfing, p_doji, p_morningstar, p_piercing, p_hammer, p_harami, p_three_soldiers)

barcolor(p_any and p_confirmed ? conf_col : na, title='Pattern Candle Color')

// ═══════════════════════════════════════════════════════════════
// 📊 SECTOR
// ═══════════════════════════════════════════════════════════════
string sector = na(syminfo.sector) ? 'N/A' : syminfo.sector

get_sector_etf(sec) =>
    string _etf = 'SPY'
    if sec == 'Technology Services' or sec == 'Electronic Technology'
        _etf := 'XLK'
    else if sec == 'Finance'
        _etf := 'XLF'
    else if sec == 'Health Technology' or sec == 'Health Services'
        _etf := 'XLV'
    else if sec == 'Retail Trade' or sec == 'Consumer Non-Durables'
        _etf := 'XLP'
    else if sec == 'Energy Minerals'
        _etf := 'XLE'
    else if sec == 'Producer Manufacturing' or sec == 'Commercial Services' or sec == 'Industrial Services' or sec == 'Transportation' or sec == 'Distribution Services'
        _etf := 'XLI'
    else if sec == 'Consumer Services' or sec == 'Consumer Durables'
        _etf := 'XLY'
    else if sec == 'Utilities'
        _etf := 'XLU'
    else if sec == 'Non-Energy Minerals' or sec == 'Process Industries'
        _etf := 'XLB'
    else if sec == 'Communications'
        _etf := 'XLC'
    _etf

sector_etf  = get_sector_etf(sector)
closeSector = request.security(sector_etf, 'D', close)
openSector  = request.security(sector_etf, 'D', open)
sector_chg  = openSector != 0 ? (closeSector - openSector) / openSector * 100.0 : float(na)

spyOpenDa  = request.security('AMEX:SPY',   'D', open)
spyCloseDa = request.security('AMEX:SPY',   'D', close)
qqqOpenDa  = request.security('NASDAQ:QQQ', 'D', open)
qqqCloseDa = request.security('NASDAQ:QQQ', 'D', close)
btcOpenDa  = request.security(btc_confirm_symbol, 'D', open)
btcCloseDa = request.security(btc_confirm_symbol, 'D', close)
vixOpenDa   = request.security(vix_symbol, 'D', open)
vixPriceNow = request.security(vix_symbol, timeframe.period, close)

// ═══════════════════════════════════════════════════════════════
// 📊 RS RATING
// ═══════════════════════════════════════════════════════════════

upVolTf = close > close[1] ? volume : 0.0
dnVolTf = close < close[1] ? volume : 0.0
upSumTf = math.sum(upVolTf, trend_ud_len)
dnSumTf = math.sum(dnVolTf, trend_ud_len)
upDnVolRatio = dnSumTf > 0 ? upSumTf / dnSumTf : upSumTf > 0 ? 999.0 : na

f_get_rs_rating_simple(ticker) =>
    n63  = math.min(bar_index, 63)
    n126 = math.min(bar_index, 126)
    n189 = math.min(bar_index, 189)
    n252 = math.min(bar_index, 252)

    enough_hist = bar_index >= 63

    tickerClose = request.security(ticker, 'D', close)
    spxClose    = request.security('SP:SPX', 'D', close)

    rs_stock = enough_hist ? 0.4 * (tickerClose / tickerClose[n63]) + 0.2 * (tickerClose / tickerClose[n126]) + 0.2 * (tickerClose / tickerClose[n189]) + 0.2 * (tickerClose / tickerClose[n252]) : float(na)
    rs_ref   = enough_hist ? 0.4 * (spxClose / spxClose[n63]) + 0.2 * (spxClose / spxClose[n126]) + 0.2 * (spxClose / spxClose[n189]) + 0.2 * (spxClose / spxClose[n252]) : float(na)
    totalRsScore  = rs_ref != 0 ? rs_stock / rs_ref * 100.0 : float(na)
    totalRsRating = float(-1)

    curveRsPerf = request.seed('seed_fred6725_rs_rating', 'RSRATING', close)
    deltaRaw = ta.barssince(not na(curveRsPerf))
    delta = na(deltaRaw) ? 0 : deltaRaw

    var float[] dv = array.new_float(7, 0.0)
    for j = 0 to 6
        array.set(dv, j, 0.0)

    cnt = 0
    for i = delta to 34 + delta
        cv = nz(curveRsPerf[i])
        if not array.includes(dv, cv) and cnt < 7 and cv != 0
            array.set(dv, cnt, cv)
            cnt += 1

    first = array.get(dv, 0)
    scnd  = array.get(dv, 1)
    thrd  = array.get(dv, 2)
    frth  = array.get(dv, 3)
    ffth  = array.get(dv, 4)
    sxth  = array.get(dv, 5)
    svth  = array.get(dv, 6)

    if enough_hist and totalRsScore >= first
        totalRsRating := 99
    else if enough_hist and totalRsScore <= svth
        totalRsRating := 1
    else if enough_hist and totalRsScore < first and totalRsScore >= scnd
        s2 = totalRsScore + (totalRsScore - scnd) * 0.33
        if s2 > first - 1
            s2 := first - 1
        k1 = scnd / 90.0
        k2 = (first - 1) / 98.0
        k3 = (k1 - k2) / (first - 1 - scnd)
        totalRsRating := math.max(90, math.min(98, s2 / (k1 - k3 * (totalRsScore - scnd))))
    else if enough_hist and totalRsScore < scnd and totalRsScore >= thrd
        s2 = totalRsScore + (totalRsScore - thrd) * 2.1
        if s2 > scnd - 1
            s2 := scnd - 1
        k1 = thrd / 70.0
        k2 = (scnd - 1) / 89.0
        k3 = (k1 - k2) / (scnd - 1 - thrd)
        totalRsRating := math.max(70, math.min(89, s2 / (k1 - k3 * (totalRsScore - thrd))))
    else if enough_hist and totalRsScore < thrd and totalRsScore >= frth
        totalRsRating := math.max(50, math.min(69, totalRsScore / (thrd / 69.0)))
    else if enough_hist and totalRsScore < frth and totalRsScore >= ffth
        totalRsRating := math.max(30, math.min(49, totalRsScore / (frth / 49.0)))
    else if enough_hist and totalRsScore < ffth and totalRsScore >= sxth
        totalRsRating := math.max(10, math.min(29, totalRsScore / (ffth / 29.0)))
    else if enough_hist and totalRsScore < sxth and totalRsScore >= svth
        totalRsRating := math.max(2, math.min(9, totalRsScore / (sxth / 9.0)))

    totalRsRating

totalRsRating = f_get_rs_rating_simple(s)
sectorRs      = f_get_rs_rating_simple(sector_etf)

// ═══════════════════════════════════════════════════════════════
// 📐 OTHER METRICS
// ═══════════════════════════════════════════════════════════════
arp  = arpDa
atr  = atrDa
atrp = atrpDa

dayMovePct  = openDa != 0 ? 100.0 * (close - openDa) / openDa : float(na)
dayRangePct = lowDa  != 0 ? 100.0 * (highDa / lowDa - 1.0)    : float(na)
adrUsedPct  = arp  != 0 ? 100.0 * dayRangePct / arp           : float(na)
atrUsedPct  = atrp != 0 ? 100.0 * math.abs(dayMovePct) / atrp : float(na)

ipoSince = request.security(s, 'D', (bar_index + 1) / 252.0)

avgDaVolCalc = maDa
avgDaVol     = maDa
uV = ''
if avgDaVol >= 1000000000
    avgDaVol := avgDaVol / 1000000000
    uV := 'B'
else if avgDaVol >= 1000000
    avgDaVol := avgDaVol / 1000000
    uV := 'M'
else if avgDaVol >= 1000
    avgDaVol := avgDaVol / 1000
    uV := 'K'

advdolDa = closeDa * avgDaVolCalc
uVDoll = ''
if advdolDa >= 1000000000
    advdolDa := advdolDa / 1000000000
    uVDoll := 'B'
else if advdolDa >= 1000000
    advdolDa := advdolDa / 1000000
    uVDoll := 'M'
else if advdolDa >= 1000
    advdolDa := advdolDa / 1000
    uVDoll := 'K'

MCap = request.financial(s, 'MARKET_CAP_BASIC', 'D', ignore_invalid_symbol=true)
if na(MCap)
    MCap := syminfo.shares_outstanding_total * closeDa

MCapCalc = MCap
uM = ''
if MCap >= 1000000000
    MCap := MCap / 1000000000
    uM := 'B'
else if MCap >= 1000000
    MCap := MCap / 1000000
    uM := 'M'
else if MCap >= 1000
    MCap := MCap / 1000
    uM := 'K'

FSO         = syminfo.shares_outstanding_float
FFMCap      = nz(FSO * closeDa, 0.0)
floatPer    = MCapCalc != 0 ? nz(FFMCap / MCapCalc * 100.0, 0.0) : float(na)
sharesFloat = syminfo.shares_outstanding_float

uF = ''
if sharesFloat >= 1000000000
    sharesFloat := sharesFloat / 1000000000
    uF := 'B'
else if sharesFloat >= 1000000
    sharesFloat := sharesFloat / 1000000
    uF := 'M'
else if sharesFloat >= 1000
    sharesFloat := sharesFloat / 1000
    uF := 'K'

fiftyTwoWeekHigh = request.security(s, 'W', ta.highest(high, 52))
fiftyTwoWeekLow  = request.security(s, 'W', ta.lowest(low, 52))
distFromHigh = fiftyTwoWeekHigh != 0 ? 100.0 * (closeDa / fiftyTwoWeekHigh - 1.0) : float(na)
distFromLow  = fiftyTwoWeekLow  != 0 ? 100.0 * (closeDa / fiftyTwoWeekLow  - 1.0) : float(na)

liquidityCap       = maDa * 0.01
string industryGrp = na(syminfo.industry) ? 'N/A' : syminfo.industry

time_left_tf   = (time_close - timenow) / 1000.0
time_passed_tf = (timenow - time) / 1000.0
vol_proj_tf    = float(volume)
if time_left_tf > 0 and time_passed_tf > 0
    vol_proj_tf := volume + (volume / time_passed_tf * time_left_tf)

uP_tf = ''
if vol_proj_tf >= 1000000000
    vol_proj_tf := vol_proj_tf / 1000000000
    uP_tf := 'B'
else if vol_proj_tf >= 1000000
    vol_proj_tf := vol_proj_tf / 1000000
    uP_tf := 'M'
else if vol_proj_tf >= 1000
    vol_proj_tf := vol_proj_tf / 1000
    uP_tf := 'K'

lod_dist_da  = atrDa != 0 ? 100.0 * (closeDa - lowDa) / atrDa : float(na)
lod_price_da = lowDa
lod_dist_tf  = atrDa != 0 ? 100.0 * (close - low) / atrDa : float(na)
lod_price_tf = low

vol_proj_da = vol_proj_da_raw
uP_da = ''
if vol_proj_da >= 1000000000
    vol_proj_da := vol_proj_da / 1000000000
    uP_da := 'B'
else if vol_proj_da >= 1000000
    vol_proj_da := vol_proj_da / 1000000
    uP_da := 'M'
else if vol_proj_da >= 1000
    vol_proj_da := vol_proj_da / 1000
    uP_da := 'K'

relVol    = relVol_da
volBuzz   = volBuzz_da
lod_dist  = lock_daily ? lod_dist_da  : lod_dist_tf
lod_price = lock_daily ? lod_price_da : lod_price_tf
vol_proj  = lock_daily ? vol_proj_da  : vol_proj_tf
uP        = lock_daily ? uP_da        : uP_tf

vwapNow = ta.vwap(hlc3)
priceAboveOpen = close >= openDa
priceBelowOpen = close < openDa
priceAboveVwap = close >= vwapNow
priceBelowVwap = close < vwapNow

trendBiasBull = priceAboveOpen and priceAboveVwap
trendBiasBear = priceBelowOpen and priceBelowVwap
trendBiasText = trendBiasBull ? 'Bullish' : trendBiasBear ? 'Bearish' : 'Mixed'
trendBiasColor = trendBiasBull ? col_positive : trendBiasBear ? col_negative : col_neutral

bullTrend = trendBiasBull and nz(relVol, 0.0) >= trend_bull_rvol_min and nz(upDnVolRatio, 0.0) >= trend_bull_ud_min
bearTrend = trendBiasBear and nz(relVol, 0.0) >= trend_bear_rvol_min and nz(upDnVolRatio, 999.0) <= trend_bear_ud_max
trendDayText  = bullTrend ? 'BULL TREND' : bearTrend ? 'BEAR TREND' : 'BALANCED'
trendDayColor = bullTrend ? col_positive : bearTrend ? col_negative : col_neutral

spyPlus    = spyCloseDa >= spyOpenDa
qqqPlus    = qqqCloseDa >= qqqOpenDa
btcPlus    = btcCloseDa >= btcOpenDa
sectorPlus = na(sector_chg) ? false : sector_chg >= 0
mktConfirmText  = 'SPY' + (spyPlus ? '+' : '-') + ' QQQ' + (qqqPlus ? '+' : '-') + ' BTC' + (btcPlus ? '+' : '-') + ' SECTOR' + (sectorPlus ? '+' : '-')
mktConfirmScore = (spyPlus ? 1 : 0) + (qqqPlus ? 1 : 0) + (btcPlus ? 1 : 0) + (sectorPlus ? 1 : 0)
mktConfirmColor = mktConfirmScore >= 3 ? col_positive : mktConfirmScore == 2 ? col_neutral : col_negative

vixChgPct    = vixOpenDa != 0 ? 100.0 * (vixPriceNow - vixOpenDa) / vixOpenDa : float(na)
vixPriceText = na(vixPriceNow) ? 'N/A' : str.tostring(vixPriceNow, '0.00')
vixText      = vixPriceText + ' ' + (na(vixChgPct) ? 'N/A' : ((vixChgPct > 0 ? '+' : '') + str.tostring(vixChgPct, '0.00') + '%'))
vixTextColor = na(vixChgPct) ? txt_col : vixChgPct > 0 ? col_negative : vixChgPct < 0 ? col_positive : col_neutral

// ═══════════════════════════════════════════════════════════════
// ⭐ SETUP SCORE
// ═══════════════════════════════════════════════════════════════
rsComp     = totalRsRating > 0 ? math.min(totalRsRating, 99) / 99.0 * 40.0 : 0.0
rvolComp   = not na(relVol) ? math.min(nz(relVol), 300.0) / 300.0 * 30.0 : 0.0
adrComp    = not na(arp) ? math.min(math.max(nz(arp), 0.0), 10.0) / 10.0 * 30.0 : 0.0
setupScore = math.round(rsComp + rvolComp + adrComp)

setupLabel = '❌ Weak'
if setupScore >= 80
    setupLabel := '🔥 Elite'
else if setupScore >= 60
    setupLabel := '✅ Strong'
else if setupScore >= 40
    setupLabel := '⚠️ Mod'

// ═══════════════════════════════════════════════════════════════
// 🎨 HELPERS
// ═══════════════════════════════════════════════════════════════
f_rsColor(rs) =>
    color c = col_negative
    if rs >= 90
        c := col_elite
    else if rs >= 80
        c := col_positive
    else if rs >= 50
        c := col_neutral
    c

f_rvolColor(rv) =>
    color c = col_negative
    if rv >= 200
        c := col_positive
    else if rv >= 100
        c := col_neutral
    c

f_setupColor(sc) =>
    color c = col_negative
    if sc >= 80
        c := col_elite
    else if sc >= 60
        c := col_positive
    else if sc >= 40
        c := col_neutral
    c

f_udColor(ratio) =>
    color c = col_negative
    if ratio >= 1.5
        c := col_positive
    else if ratio >= 0.8
        c := col_neutral
    c

f_distHighColor(dist) =>
    color c = col_negative
    if dist >= -5
        c := col_positive
    else if dist >= -20
        c := col_neutral
    c

f_floatColor(fp) =>
    color c = col_negative
    if fp < 20
        c := col_positive
    else if fp < 50
        c := col_neutral
    c

f_adrColor(a) =>
    color c = col_negative
    if a >= 5
        c := col_positive
    else if a >= 2
        c := col_neutral
    c

f_extColor(pct) =>
    color c = col_positive
    if pct >= 120
        c := col_negative
    else if pct >= 80
        c := col_neutral
    c

fmtNA(val, fmt) =>
    na(val) ? 'N/A' : str.tostring(val, fmt)

// ═══════════════════════════════════════════════════════════════
// 📍 KEY LEVELS — CALCULATIONS
// ═══════════════════════════════════════════════════════════════
lvl_CDO = request.security(syminfo.tickerid, 'D', open,    lookahead=barmerge.lookahead_on)
lvl_PDH = request.security(syminfo.tickerid, 'D', high[1], lookahead=barmerge.lookahead_on)
lvl_PDL = request.security(syminfo.tickerid, 'D', low[1],  lookahead=barmerge.lookahead_on)
lvl_TWH = request.security(syminfo.tickerid, 'W', high,    lookahead=barmerge.lookahead_on)
lvl_TWL = request.security(syminfo.tickerid, 'W', low,     lookahead=barmerge.lookahead_on)
lvl_LWH = request.security(syminfo.tickerid, 'W', high[1], lookahead=barmerge.lookahead_on)
lvl_LWL = request.security(syminfo.tickerid, 'W', low[1],  lookahead=barmerge.lookahead_on)

// ── VWAP — resets each session ────────────────────────────────
var float vwap_vol = 0.0
var float vwap_pv  = 0.0
if ta.change(time('D')) != 0
    vwap_vol := 0.0
    vwap_pv  := 0.0
vwap_pv  += hlc3 * volume
vwap_vol += volume
lvl_VWAP = vwap_vol > 0 ? vwap_pv / vwap_vol : na

// ── Pre-market: 0400–0929, lock at session open ───────────────
in_premarket = not na(time(timeframe.period, "0400-0929:23456"))
is_new_day   = ta.change(time("D")) != 0

var float pm_high_run  = na
var float pm_low_run   = na
var float pm_high_lock = na
var float pm_low_lock  = na
var bool  pm_locked    = false

if is_new_day
    pm_high_run := na
    pm_low_run  := na
    pm_locked   := false

if in_premarket and not pm_locked
    pm_high_run := na(pm_high_run) ? high : math.max(pm_high_run, high)
    pm_low_run  := na(pm_low_run)  ? low  : math.min(pm_low_run,  low)

if session.ismarket and not pm_locked and not na(pm_high_run)
    pm_high_lock := pm_high_run
    pm_low_lock  := pm_low_run
    pm_locked    := true

lvl_PMH = pm_locked ? pm_high_lock : pm_high_run
lvl_PML = pm_locked ? pm_low_lock  : pm_low_run

// ── Label size helper ─────────────────────────────────────────
f_lvl_lbl_size(s) =>
    switch s
        'Tiny'   => size.tiny
        'Small'  => size.small
        'Normal' => size.normal
        'Large'  => size.large
        'Huge'   => size.huge
        => size.small

// ── Line style helper ─────────────────────────────────────────
f_lvl_ln_style(s) =>
    switch s
        'Dashed'      => line.style_dashed
        'Dotted'      => line.style_dotted
        'Arrow Right' => line.style_arrow_right
        'Arrow Left'  => line.style_arrow_left
        =>               line.style_solid

// ── Line + Label + Fill drawing ───────────────────────────────
var line ln_CDO  = na
var line ln_PDH  = na
var line ln_PDL  = na
var line ln_PMH  = na
var line ln_PML  = na
var line ln_VWAP = na
var line ln_TWH  = na
var line ln_TWL  = na
var line ln_LWH  = na
var line ln_LWL  = na

var label lbl_CDO  = na
var label lbl_PDH  = na
var label lbl_PDL  = na
var label lbl_PMH  = na
var label lbl_PML  = na
var label lbl_VWAP = na
var label lbl_TWH  = na
var label lbl_TWL  = na
var label lbl_LWH  = na
var label lbl_LWL  = na

if barstate.islast
    // delete old lines
    line.delete(ln_CDO)
    line.delete(ln_PDH)
    line.delete(ln_PDL)
    line.delete(ln_PMH)
    line.delete(ln_PML)
    line.delete(ln_VWAP)
    line.delete(ln_TWH)
    line.delete(ln_TWL)
    line.delete(ln_LWH)
    line.delete(ln_LWL)
    // delete old labels
    label.delete(lbl_CDO)
    label.delete(lbl_PDH)
    label.delete(lbl_PDL)
    label.delete(lbl_PMH)
    label.delete(lbl_PML)
    label.delete(lbl_VWAP)
    label.delete(lbl_TWH)
    label.delete(lbl_TWL)
    label.delete(lbl_LWH)
    label.delete(lbl_LWL)

    bpd      = timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly
                 ? 1 : math.max(1, math.round(390 * 60 / timeframe.in_seconds()))
    ln_start = line_mode == 'Most recent day'
                 ? bar_index - bpd
                 : bar_index - (line_lookback_days * bpd)
    lbl_x    = bar_index + level_label_offset
    lbl_sz   = f_lvl_lbl_size(level_label_size)
    ln_sty   = f_lvl_ln_style(level_line_style)

    if show_level_CDO and not na(lvl_CDO)
        if show_level_lines
            ln_CDO := line.new(ln_start, lvl_CDO, bar_index, lvl_CDO, color=col_CDO, width=level_line_width, style=ln_sty, extend=extend.right)
        if show_level_labels
            lbl_CDO := label.new(lbl_x, lvl_CDO, text='Today Open (' + str.tostring(lvl_CDO, format.mintick) + ')', color=color.new(color.black, 100), textcolor=level_label_font_col, style=label.style_none, size=lbl_sz)

    if show_level_PDH and not na(lvl_PDH)
        if show_level_lines
            ln_PDH := line.new(ln_start, lvl_PDH, bar_index, lvl_PDH, color=col_PDH, width=level_line_width, style=ln_sty, extend=extend.right)
        if show_level_labels
            lbl_PDH := label.new(lbl_x, lvl_PDH, text="Yesterday's High (" + str.tostring(lvl_PDH, format.mintick) + ')', color=color.new(color.black, 100), textcolor=level_label_font_col, style=label.style_none, size=lbl_sz)

    if show_level_PDL and not na(lvl_PDL)
        if show_level_lines
            ln_PDL := line.new(ln_start, lvl_PDL, bar_index, lvl_PDL, color=col_PDL, width=level_line_width, style=ln_sty, extend=extend.right)
        if show_level_labels
            lbl_PDL := label.new(lbl_x, lvl_PDL, text="Yesterday's Low (" + str.tostring(lvl_PDL, format.mintick) + ')', color=color.new(color.black, 100), textcolor=level_label_font_col, style=label.style_none, size=lbl_sz)

    if show_level_PMH and not na(lvl_PMH)
        if show_level_lines
            ln_PMH := line.new(ln_start, lvl_PMH, bar_index, lvl_PMH, color=col_PMH, width=level_line_width, style=ln_sty, extend=extend.right)
        if show_level_labels
            lbl_PMH := label.new(lbl_x, lvl_PMH, text='Pre Mkt High (' + str.tostring(lvl_PMH, format.mintick) + ')', color=color.new(color.black, 100), textcolor=level_label_font_col, style=label.style_none, size=lbl_sz)

    if show_level_PML and not na(lvl_PML)
        if show_level_lines
            ln_PML := line.new(ln_start, lvl_PML, bar_index, lvl_PML, color=col_PML, width=level_line_width, style=ln_sty, extend=extend.right)
        if show_level_labels
            lbl_PML := label.new(lbl_x, lvl_PML, text='Pre Mkt Low (' + str.tostring(lvl_PML, format.mintick) + ')', color=color.new(color.black, 100), textcolor=level_label_font_col, style=label.style_none, size=lbl_sz)

    if show_level_VWAP and not na(lvl_VWAP)
        if show_level_lines
            ln_VWAP := line.new(ln_start, lvl_VWAP, bar_index, lvl_VWAP, color=col_VWAP, width=level_line_width, style=ln_sty, extend=extend.right)
        if show_level_labels
            lbl_VWAP := label.new(lbl_x, lvl_VWAP, text='VWAP (' + str.tostring(lvl_VWAP, format.mintick) + ')', color=color.new(color.black, 100), textcolor=level_label_font_col, style=label.style_none, size=lbl_sz)

    if show_level_TWH and not na(lvl_TWH)
        if show_level_lines
            ln_TWH := line.new(ln_start, lvl_TWH, bar_index, lvl_TWH, color=col_TWH, width=level_line_width, style=ln_sty, extend=extend.right)
        if show_level_labels
            lbl_TWH := label.new(lbl_x, lvl_TWH, text='This Week High (' + str.tostring(lvl_TWH, format.mintick) + ')', color=color.new(color.black, 100), textcolor=level_label_font_col, style=label.style_none, size=lbl_sz)

    if show_level_TWL and not na(lvl_TWL)
        if show_level_lines
            ln_TWL := line.new(ln_start, lvl_TWL, bar_index, lvl_TWL, color=col_TWL, width=level_line_width, style=ln_sty, extend=extend.right)
        if show_level_labels
            lbl_TWL := label.new(lbl_x, lvl_TWL, text='This Week Low (' + str.tostring(lvl_TWL, format.mintick) + ')', color=color.new(color.black, 100), textcolor=level_label_font_col, style=label.style_none, size=lbl_sz)

    if show_level_LWH and not na(lvl_LWH)
        if show_level_lines
            ln_LWH := line.new(ln_start, lvl_LWH, bar_index, lvl_LWH, color=col_LWH, width=level_line_width, style=ln_sty, extend=extend.right)
        if show_level_labels
            lbl_LWH := label.new(lbl_x, lvl_LWH, text='Last Week High (' + str.tostring(lvl_LWH, format.mintick) + ')', color=color.new(color.black, 100), textcolor=level_label_font_col, style=label.style_none, size=lbl_sz)

    if show_level_LWL and not na(lvl_LWL)
        if show_level_lines
            ln_LWL := line.new(ln_start, lvl_LWL, bar_index, lvl_LWL, color=col_LWL, width=level_line_width, style=ln_sty, extend=extend.right)
        if show_level_labels
            lbl_LWL := label.new(lbl_x, lvl_LWL, text='Last Week Low (' + str.tostring(lvl_LWL, format.mintick) + ')', color=color.new(color.black, 100), textcolor=level_label_font_col, style=label.style_none, size=lbl_sz)

// ── Level Alerts ──────────────────────────────────────────────
alertcondition(ta.crossover(close,  lvl_CDO),  title='↑ Above CDO',  message='{{ticker}} crossed above Today Open')
alertcondition(ta.crossunder(close, lvl_CDO),  title='↓ Below CDO',  message='{{ticker}} crossed below Today Open')
alertcondition(ta.crossover(close,  lvl_PDH),  title='↑ Above PDH',  message='{{ticker}} crossed above Yesterday High')
alertcondition(ta.crossunder(close, lvl_PDH),  title='↓ Below PDH',  message='{{ticker}} crossed below Yesterday High')
alertcondition(ta.crossover(close,  lvl_PDL),  title='↑ Above PDL',  message='{{ticker}} crossed above Yesterday Low')
alertcondition(ta.crossunder(close, lvl_PDL),  title='↓ Below PDL',  message='{{ticker}} crossed below Yesterday Low')
alertcondition(ta.crossover(close,  lvl_PMH),  title='↑ Above PMH',  message='{{ticker}} crossed above Pre Market High')
alertcondition(ta.crossunder(close, lvl_PMH),  title='↓ Below PMH',  message='{{ticker}} crossed below Pre Market High')
alertcondition(ta.crossover(close,  lvl_PML),  title='↑ Above PML',  message='{{ticker}} crossed above Pre Market Low')
alertcondition(ta.crossunder(close, lvl_PML),  title='↓ Below PML',  message='{{ticker}} crossed below Pre Market Low')
alertcondition(ta.crossover(close,  lvl_VWAP), title='↑ Above VWAP', message='{{ticker}} crossed above VWAP')
alertcondition(ta.crossunder(close, lvl_VWAP), title='↓ Below VWAP', message='{{ticker}} crossed below VWAP')
alertcondition(ta.crossover(close,  lvl_TWH),  title='↑ Above TWH',  message='{{ticker}} crossed above This Week High')
alertcondition(ta.crossunder(close, lvl_TWH),  title='↓ Below TWH',  message='{{ticker}} crossed below This Week High')
alertcondition(ta.crossover(close,  lvl_TWL),  title='↑ Above TWL',  message='{{ticker}} crossed above This Week Low')
alertcondition(ta.crossunder(close, lvl_TWL),  title='↓ Below TWL',  message='{{ticker}} crossed below This Week Low')
alertcondition(ta.crossover(close,  lvl_LWH),  title='↑ Above LWH',  message='{{ticker}} crossed above Last Week High')
alertcondition(ta.crossunder(close, lvl_LWH),  title='↓ Below LWH',  message='{{ticker}} crossed below Last Week High')

// ═══════════════════════════════════════════════════════════════
// 🚨 ALERTS
// ═══════════════════════════════════════════════════════════════
alertcondition(p_engulfing      and p_confirmed, title='✓ Bullish Engulfing',    message='{{ticker}} Bullish Engulfing confirmed!')
alertcondition(p_doji           and p_confirmed, title='✓ Dragonfly Doji',       message='{{ticker}} Dragonfly Doji confirmed!')
alertcondition(p_morningstar    and p_confirmed, title='✓ Morning Star',         message='{{ticker}} Morning Star confirmed!')
alertcondition(p_piercing       and p_confirmed, title='✓ Piercing Line',        message='{{ticker}} Piercing Line confirmed!')
alertcondition(p_hammer         and p_confirmed, title='✓ Hammer',               message='{{ticker}} Hammer confirmed!')
alertcondition(p_harami         and p_confirmed, title='✓ Bullish Harami',       message='{{ticker}} Bullish Harami confirmed!')
alertcondition(p_three_soldiers and p_confirmed, title='✓ Three White Soldiers', message='{{ticker}} Three White Soldiers confirmed!')
alertcondition(p_count >= 2     and p_confirmed, title='✓ Multiple Patterns',    message='{{ticker}} Multiple patterns confirmed!')

// ═══════════════════════════════════════════════════════════════
// 📊 TABLE
// ═══════════════════════════════════════════════════════════════
tablePos = switch posTable
    'Top Left'     => position.top_left
    'Top Right'    => position.top_right
    'Bottom Left'  => position.bottom_left
    'Bottom Right' => position.bottom_right

size_tbl = switch tbl_size
    'Normal' => size.normal
    'Tiny'   => size.tiny
    'Small'  => size.small
    'Large'  => size.large

var table t = table.new(tablePos, 2, 50, bgcolor=bg_col)

if barstate.islast
    table.clear(t, 0, 0, 1, 49)

    row = 0

    if show_empty_row
        table.cell(t, 0, row, '', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, '', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_lock_row
        lockStr = lock_daily ? '🔒 Daily' : '🔓 Chart TF'
        lockCol = lock_daily ? color.rgb(76, 175, 80) : color.rgb(255, 152, 0)
        table.cell(t, 0, row, lockStr, text_color=lockCol, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, '',      text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.merge_cells(t, 0, row, 1, row)
        row += 1

    if show_setupScore
        scoreText = str.tostring(setupScore) + ' ' + setupLabel
        table.cell(t, 0, row, '⭐ Score', text_color=txt_col,      text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, scoreText,  text_color=f_setupColor(setupScore), text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_adrp
        table.cell(t, 0, row, 'ADR%', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(arp, '0.00') + '%', text_color=f_adrColor(nz(arp)), text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_dayRange
        table.cell(t, 0, row, 'Day Range', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(dayRangePct, '0.00') + '%', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_adrUsed
        table.cell(t, 0, row, 'ADR Used', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(adrUsedPct, '0.0') + '%', text_color=f_extColor(nz(adrUsedPct, 0.0)), text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_atrPer
        table.cell(t, 0, row, 'ATR%', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(atrp, '0.00') + '%', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_dayMove
        table.cell(t, 0, row, 'Day Move', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(dayMovePct, '0.00') + '%', text_color=dayMovePct >= 0 ? col_positive : col_negative, text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_atrUsed
        table.cell(t, 0, row, 'ATR Used', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(atrUsedPct, '0.0') + '%', text_color=f_extColor(nz(atrUsedPct, 0.0)), text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_atr
        table.cell(t, 0, row, 'ATR $', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(atr, '0.00'), text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_lod_dist
        table.cell(t, 0, row, 'LoD Dist', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(lod_dist, '0.00') + '%', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_ADV
        table.cell(t, 0, row, 'Avg Vol', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(avgDaVol, '0.00') + uV, text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_projectedVol
        table.cell(t, 0, row, 'Proj Vol', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(vol_proj, '0.00') + uP, text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_relVol
        table.cell(t, 0, row, 'RVol', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(relVol, '0') + '%', text_color=f_rvolColor(nz(relVol, 0.0)), text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_volBuzz
        table.cell(t, 0, row, 'Buzz', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(volBuzz, '0') + '%', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_UDratio
        table.cell(t, 0, row, 'U/D', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(upDnVolRatio, '0.00'), text_color=f_udColor(nz(upDnVolRatio, 1.0)), text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_rs_rating
        rsVal  = nz(totalRsRating, -1.0)
        rsIcon = rsVal >= 90 ? ' 🏆' : rsVal >= 80 ? ' ✅' : rsVal >= 50 ? ' ⚠️' : ' ❌'
        rsStr  = rsVal < 0 ? 'N/A' : str.tostring(rsVal, '0.0') + rsIcon
        table.cell(t, 0, row, 'RS',  text_color=txt_col,          text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, rsStr, text_color=f_rsColor(rsVal), text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_mktCap
        table.cell(t, 0, row, 'Mkt Cap', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(MCap, '0.00') + uM, text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_float
        table.cell(t, 0, row, 'Float', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(sharesFloat, '0.00') + uF, text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_floatpercent
        table.cell(t, 0, row, 'Float %', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(floatPer, '0.0') + '%', text_color=f_floatColor(nz(floatPer)), text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_ipo_date
        table.cell(t, 0, row, 'IPO', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(ipoSince, '0.00') + 'Y', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_lod_price
        table.cell(t, 0, row, 'LoD', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(lod_price, '0.00'), text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_dist_high
        table.cell(t, 0, row, '52W High', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(distFromHigh, '0.0') + '%', text_color=f_distHighColor(nz(distFromHigh, -100)), text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_dist_low
        table.cell(t, 0, row, '52W Low', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, '+' + fmtNA(distFromLow, '0.0') + '%', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_ADVS
        table.cell(t, 0, row, 'Avg$ Vol', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, '$' + fmtNA(advdolDa, '0.00') + uVDoll, text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_liqCap
        table.cell(t, 0, row, 'Liq Cap', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(liquidityCap, '0'), text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_sector
        table.cell(t, 0, row, sector, text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, '',     text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.merge_cells(t, 0, row, 1, row)
        row += 1

    if show_selectSector
        sectorData   = show_sector_rs ? sector_etf + ' (RS ' + str.tostring(sectorRs, '0') + ')' : sector_etf
        sectorChgStr = na(sector_chg) ? 'N/A' : (sector_chg > 0 ? '+' : '') + str.tostring(sector_chg, '0.00') + '%'
        table.cell(t, 0, row, sectorData,   text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, sectorChgStr, text_color=na(sector_chg) ? txt_col : (sector_chg > 0 ? sector_chg_Up : sector_chg_Dn), text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_trendBias
        table.cell(t, 0, row, 'Trend Bias', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, trendBiasText, text_color=trendBiasColor, text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_trendDay
        table.cell(t, 0, row, 'Trend Day', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, trendDayText, text_color=trendDayColor, text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_mktConfirm
        table.cell(t, 0, row, 'Mkt Confirm', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, mktConfirmText, text_color=mktConfirmColor, text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_vixLabel
        table.cell(t, 0, row, 'VIX', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, vixText, text_color=vixTextColor, text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_ind
        table.cell(t, 0, row, industryGrp, text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, '',          text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.merge_cells(t, 0, row, 1, row)
        row += 1
````

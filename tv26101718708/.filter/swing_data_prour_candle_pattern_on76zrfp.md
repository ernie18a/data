# Swing Data Pro[U&R + CANDLE PATTERN]

- url: https://www.tradingview.com/script/oN76ZrFP-Swing-Data-Pro-U-R-CANDLE-PATTERN/
- type: indicator
- pine_id: PUB;f1b343fb699b41579dce244f225444a1
- version: 1.0

## Description

Swing Data Pro — How to Use

Swing Data Pro is a swing-trading decision tool built to help filter out weak setups and reduce emotional entries.
It is designed to work best on daily-based swing setups, where the goal is to trade strong stocks with good trend structure, solid quality, and a valid trigger — not just a pretty candle.

This indicator does not treat candle patterns as standalone buy signals.
Instead, it uses a layered model:

Trend → Quality → Trigger → Pattern → Trade

That means a bullish candle pattern is treated as a bonus confirmation, not as a reason by itself to enter a swing trade.

Best Use Case

This indicator is built primarily for:

swing trading
daily chart decision-making
end-of-day / near-close scanning
finding higher-quality continuation or reclaim setups

It works best when used as a decision framework, not as a blind auto-entry signal.

Core Idea

A good swing trade usually needs 4 things:

Trend — the chart structure is healthy
Quality — the stock is strong enough to trade
Trigger — the actual setup happened
Pattern — price action confirmed the setup

The final TRADE row summarizes all of that into a simple read:

❌ Not Ready = do not force it
👀 Watch = good stock, but no valid entry yet
✅ Ready = valid swing setup
🔥 Ready+ = valid setup with confirmed bullish pattern bonus
How to Read the Table
TREND

This checks whether the chart is structurally strong enough for swing trading.

Depending on your settings, Trend can include:

close above 21 EMA
8 EMA above 21 EMA
21 EMA rising
optional: close above 50 SMA

How to use it:
If Trend fails, the chart is usually not worth forcing on the long side.

QUALITY

This checks whether the stock is worth your attention.

Quality may include:

minimum RS Rating
minimum Relative Volume
minimum average share volume
minimum average dollar volume
sector ETF confirmation

How to use it:
A weak stock can still print a bullish candle, but that does not make it a high-quality swing trade.

TRIGGER

This is the actual entry event.

Trigger can come from:

U&R (Undercut & Rally / Tap & Rally)
Pullback (clean bounce near 8 EMA or 21 EMA)

How to use it:
If Trend and Quality are good but Trigger says Waiting, the stock may be promising, but the actual entry is not there yet.

PATTERN

This shows bullish candle confirmation:

Bullish Engulfing
Dragonfly Doji
Morning Star
Piercing Line
Multiple bullish patterns

Important:
Pattern is a bonus, not permission.

A confirmed pattern can improve a valid setup, but it should not override weak Trend, weak Quality, or no Trigger.

TRADE

This is the final summary row.

It answers:

“After checking everything, is this actually tradable right now?”

Use it like this:

❌ Not Ready → skip
👀 Watch → add to watchlist, wait for trigger
✅ Ready → valid swing candidate
🔥 Ready+ → strongest version of the setup
Understanding U&R vs Trigger

U&R is not the same as Trigger.

U&R is a specific trigger type
Trigger is the broader entry layer

That means:

a U&R can create the trigger
a pullback can also create the trigger
if neither happens, Trigger stays inactive

So:

U&R = setup type
Trigger = entry permission layer

What “Waiting” Means on Trigger

If the Trigger row says Waiting, it means:

Trend is acceptable
Quality is acceptable
but the actual entry event has not happened yet

In plain English:

good stock, bad timing right now

That helps prevent one of the most common swing-trading mistakes:
buying a stock early just because it “looks strong.”

How to Use This for Entering Trades

The best way to use this indicator is to read it in order:

1. Start with TRADE

If Trade says Not Ready, move on.
If it says Watch, the setup may be developing, but it is not ready yet.
If it says Ready or Ready+, then inspect the chart more closely.

2. Check TRIGGER

Make sure the stock actually gave you a valid entry event:

U&R
Tap / reclaim
clean pullback bounce

If there is no valid trigger, do not force the trade.

3. Confirm TREND and QUALITY

A valid trigger on a weak stock or a bad chart is still a weak trade.

4. Use PATTERN as confirmation only

A good bullish candle helps — but only if the rest of the setup is already valid.

5. Check the chart location

Before entering, ask:

am I entering near support / EMA?
or am I chasing after a big move?

A lot of losing swing trades come from buying good setups too late.

How to Avoid Bad Trades

This indicator is built to reduce bad trades by forcing the setup through layers.

Avoid entering if:
Trend fails
Quality fails
Trigger has not happened
you are buying a big extended candle
volume is weak
sector is fighting the move
you are relying only on the candle pattern
Most common bad-trade mistake:

Pattern without context

A stock can print:

a bullish engulfing
a doji
a nice reversal candle

…but still fail if:

the trend is weak
quality is poor
the trigger is missing
price is extended
volume is weak

That is why this script treats patterns as confirmation, not permission.

Best Workflow for Swing Traders

This tool works best when used:

near the daily close
after the market closes
on daily charts
with Daily Lock ON

Why?
Because daily-based swing setups are more reliable once the candle is close to confirmed, especially for U&R and candle pattern confirmation.

Suggested Default Settings for Swing Trading

A strong starting profile:

Daily Lock = ON
Pattern Timeframe = D
Show Forming = OFF
Show Confirmed = ON
Trend filters ON
Min RS Rating = 85
Min RVol = 120%
Require Sector ETF Green = ON
Mobile Compact Mode = ON if using TradingView mobile

These settings help reduce noise and keep the tool focused on higher-quality daily swing setups.

Mobile-Friendly Tip

If you use TradingView on mobile, you can shrink and simplify the table by:

using Tiny table size
turning Mobile Compact Mode ON
hiding rows you do not need
hiding the Daily Lock row
hiding the spacer row

You can also individually hide:

Trend
Quality
Trigger
Pattern
Trade

This makes the indicator much easier to read on smaller screens.

Practical Entry Model
A-Grade Setup
Trend = Pass
Quality = Pass
Trigger = active
Trade = Ready or Ready+
price not too extended from support
volume is healthy
sector is aligned
Watchlist Setup
Trend = good
Quality = good
Trigger = Waiting
Trade = Watch
No-Trade Setup
Trade = Not Ready
no trigger
weak trend
weak quality
pattern-only setup
late / extended entry
Final Note

This indicator is meant to help you trade better timing and better structure, not more trades.

The goal is not to find every move.

The goal is to:

avoid weak setups
avoid premature entries
avoid chasing extended candles
and focus on stronger daily swing candidates with real confirmation

## Source Code

````pine
//@version=6
indicator(title='Swing Data Pro — ADR% / RVol / RS Rating & More', shorttitle='SwingPro', overlay=true, max_bars_back=253)

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
pattern_tf = input.string('D',
     title='Pattern Timeframe',
     group='🕯️ Candle Patterns',
     options=['1', '3', '5', '15', '30', '60', '240', 'D', 'W'],
     tooltip='Timeframe used to detect candle patterns.\n\nD = best default for swing trading.\n\nIcons only plot when the current chart timeframe matches this setting.')

show_forming = input(false,
     title='Show Forming ✕ (potential, not closed)',
     group='🕯️ Candle Patterns',
     tooltip='ON = shows unfinished patterns before candle close.\n\nOFF is usually better for swing trading.')

show_confirmed = input(true,
     title='Show Confirmed ✓ (closed candle)',
     group='🕯️ Candle Patterns',
     tooltip='ON = only confirmed patterns show.')

symbol_size = input.string('Small',
     title='Symbol Size',
     group='🕯️ Candle Patterns',
     options=['Tiny', 'Small', 'Normal', 'Large'])

show_engulfing   = input(true,  title='Show Bullish Engulfing',  group='🕯️ Candle Patterns')
show_doji        = input(true,  title='Show Dragonfly Doji',     group='🕯️ Candle Patterns')
show_morningstar = input(true,  title='Show Morning Star',       group='🕯️ Candle Patterns')
show_piercing    = input(true,  title='Show Piercing Line',      group='🕯️ Candle Patterns')

engulf_col_conf      = input(color.rgb(27, 94, 32),   title='Engulfing ✓ Color',    group='🕯️ Candle Patterns')
doji_col_conf        = input(color.rgb(0, 96, 100),   title='Dragonfly ✓ Color',    group='🕯️ Candle Patterns')
morningstar_col_conf = input(color.rgb(74, 20, 140),  title='Morning Star ✓ Color', group='🕯️ Candle Patterns')
piercing_col_conf    = input(color.rgb(230, 81, 0),   title='Piercing ✓ Color',     group='🕯️ Candle Patterns')
multi_col_conf       = input(color.rgb(245, 127, 23), title='Multiple ✓ Color',     group='🕯️ Candle Patterns')

engulf_col_form      = input(color.rgb(27, 94, 32),   title='Engulfing ✕ Color',    group='🕯️ Candle Patterns')
doji_col_form        = input(color.rgb(0, 96, 100),   title='Dragonfly ✕ Color',    group='🕯️ Candle Patterns')
morningstar_col_form = input(color.rgb(74, 20, 140),  title='Morning Star ✕ Color', group='🕯️ Candle Patterns')
piercing_col_form    = input(color.rgb(230, 81, 0),   title='Piercing ✕ Color',     group='🕯️ Candle Patterns')
multi_col_form       = input(color.rgb(245, 127, 23), title='Multiple ✕ Color',     group='🕯️ Candle Patterns')

require_ema_proximity = input(true,
     title='Require EMA Proximity',
     group='🕯️ Candle Patterns',
     tooltip='ON = pattern must happen near the 8 EMA or 21 EMA.')

ema8_prox_pct  = input.float(3.0, title='8 EMA Proximity %',  group='🕯️ Candle Patterns', minval=0.5, maxval=10.0)
ema21_prox_pct = input.float(3.0, title='21 EMA Proximity %', group='🕯️ Candle Patterns', minval=0.5, maxval=10.0)

require_pattern_rvol = input(true,
     title='Require RVol Above Min',
     group='🕯️ Candle Patterns',
     tooltip='ON = pattern only qualifies if Relative Volume is above the minimum.')

pattern_rvol_min = input.float(100.0, title='Min RVol % for Pattern', group='🕯️ Candle Patterns', minval=50.0, maxval=300.0)

engulf_min_body  = input.float(10.0, title='Engulfing Min Body % Larger',    group='🕯️ Candle Patterns', minval=0.0,  maxval=100.0)
doji_body_tol    = input.float(0.1,  title='Dragonfly Body Tolerance %',      group='🕯️ Candle Patterns', minval=0.01, maxval=1.0)
doji_wick_ratio  = input.float(3.0,  title='Dragonfly Min Wick/Body Ratio',   group='🕯️ Candle Patterns', minval=1.0,  maxval=10.0)
piercing_min_pct = input.float(60.0, title='Piercing Min Close % Into Body',  group='🕯️ Candle Patterns', minval=50.0, maxval=100.0)
ms_mid_body_pct  = input.float(30.0, title='Morning Star Max Mid Body %',     group='🕯️ Candle Patterns', minval=5.0,  maxval=80.0)
ms_close_pct     = input.float(50.0, title='Morning Star Min 3rd Close %',    group='🕯️ Candle Patterns', minval=30.0, maxval=90.0)

// ═══════════════════════════════════════════════════════════════
// 🎯 U&R SIGNAL SETTINGS
// ═══════════════════════════════════════════════════════════════
show_ur = input(false,
     title='Show U&R Detail Row',
     group='🎯 U&R Signal',
     tooltip='OFF by default for mobile.\n\nTRIGGER row already shows most of this info.')

ur_tap_pct  = input.float(0.5,   title='Tap Zone % (within EMA)', group='🎯 U&R Signal', minval=0.1, maxval=3.0)
ur_rvol_min = input.float(120.0, title='Min RVol % for U&R Confirm', group='🎯 U&R Signal', minval=50.0, maxval=300.0)

// ═══════════════════════════════════════════════════════════════
// 📊 LAYERED TRADE ENGINE
// ═══════════════════════════════════════════════════════════════
show_trade = input(true,
     title='Show Layered Trade Block',
     group='📊 Layered Trade Engine',
     tooltip='Main layered model:\nTREND\nQUALITY\nTRIGGER\nPATTERN\nTRADE')

trend_require_close_above_21 = input(true,  title='Trend: Close Above 21 EMA', group='📊 Layered Trade Engine')
trend_require_8_over_21      = input(true,  title='Trend: 8 EMA Above 21 EMA', group='📊 Layered Trade Engine')
trend_require_21_rising      = input(true,  title='Trend: 21 EMA Rising',      group='📊 Layered Trade Engine')
trend_require_close_above_50 = input(false, title='Trend: Close Above 50 SMA', group='📊 Layered Trade Engine')

trade_min_rs = input.float(85.0,
     title='Quality: Min RS Rating',
     group='📊 Layered Trade Engine',
     minval=1.0,
     maxval=99.0)

trade_min_rvol = input.float(120.0,
     title='Quality: Min RVol %',
     group='📊 Layered Trade Engine',
     minval=50.0,
     maxval=300.0)

liq_min_avg_vol = input.int(500000,
     title='Quality: Min Avg Volume (shares, 0 = OFF)',
     group='📊 Layered Trade Engine',
     minval=0,
     step=50000)

liq_min_avg_dollar_m = input.float(25.0,
     title='Quality: Min Avg $ Volume in Millions (0 = OFF)',
     group='📊 Layered Trade Engine',
     minval=0.0,
     step=1.0)

trade_req_sector = input(true,
     title='Quality: Require Sector ETF Green',
     group='📊 Layered Trade Engine')

allow_ur_trigger = input(true,
     title='Trigger: Allow U&R',
     group='📊 Layered Trade Engine')

allow_pullback_trigger = input(true,
     title='Trigger: Allow Pullback',
     group='📊 Layered Trade Engine')

pullback_zone_pct = input.float(1.0,
     title='Trigger: Pullback Zone % Above EMA',
     group='📊 Layered Trade Engine',
     minval=0.1,
     maxval=5.0)

pullback_close_pct = input.float(60.0,
     title='Trigger: Min Close % of Candle Range',
     group='📊 Layered Trade Engine',
     minval=40.0,
     maxval=100.0)

pullback_require_green = input(true,
     title='Trigger: Require Green Pullback Candle',
     group='📊 Layered Trade Engine')

// ═══════════════════════════════════════════════════════════════
// 🎨 TABLE STYLE / MOBILE
// ═══════════════════════════════════════════════════════════════
mobile_compact = input(true,
     title='📱 Mobile Compact Mode',
     group='🎨 Table Style',
     tooltip='ON = shorter text, tighter mobile-friendly view.')

show_lock_row = input(false,
     title='Show Daily Lock Row',
     group='🎨 Table Style',
     tooltip='OFF hides the Daily lock row to save space and move the table up.')

show_trend_row = input(true,  title='Show TREND Row',   group='🎨 Table Style')
show_quality_row = input(true, title='Show QUALITY Row', group='🎨 Table Style')
show_trigger_row = input(true, title='Show TRIGGER Row', group='🎨 Table Style')
show_pattern_row = input(true, title='Show PATTERN Row', group='🎨 Table Style')
show_trade_row = input(true,   title='Show TRADE Row',   group='🎨 Table Style')

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
col_positive  = input(color.rgb(76, 175, 80),   title='Strong / Positive', group='🎨 Colors')
col_neutral   = input(color.rgb(255, 152, 0),   title='Neutral / Medium',  group='🎨 Colors')
col_negative  = input(color.rgb(244, 67, 54),   title='Weak / Negative',   group='🎨 Colors')
col_elite     = input(color.rgb(255, 215, 0),   title='Elite (Gold)',      group='🎨 Colors')
sector_chg_Up = input(color.rgb(76, 175, 80),   title='Sector Positive Chg', group='🎨 Colors')
sector_chg_Dn = input(color.rgb(244, 67, 54),   title='Sector Negative Chg', group='🎨 Colors')

// ═══════════════════════════════════════════════════════════════
// 📋 DISPLAY TOGGLES
// ═══════════════════════════════════════════════════════════════
show_setupScore   = input(true,  title='⭐ Setup Score',         group='📋 Display')
show_mktCap       = input(false, title='Market Cap',             group='📋 Display')
show_float        = input(false, title='Shares Float',           group='📋 Display')
show_floatpercent = input(false, title='Float %',                group='📋 Display')
show_adrp         = input(true,  title='ADR% (Avg Daily Range)', group='📋 Display')
show_atrPer       = input(true,  title='ATR%',                   group='📋 Display')
show_atr          = input(true,  title='ATR ($)',                group='📋 Display')
show_ipo_date     = input(false, title='IPO Timer',              group='📋 Display')
show_lod_dist     = input(true,  title='LoD Distance',           group='📋 Display')
show_lod_price    = input(false, title='LoD Price',              group='📋 Display')
show_dist_high    = input(false, title='Off 52W High',           group='📋 Display')
show_dist_low     = input(false, title='Above 52W Low',          group='📋 Display')
show_ADVS         = input(false, title='Avg $ Volume',           group='📋 Display')
show_ADV          = input(true,  title='Avg Volume (Shares)',    group='📋 Display')
show_projectedVol = input(false, title='Projected Volume',       group='📋 Display')
show_relVol       = input(true,  title='Relative Volume',        group='📋 Display')
show_volBuzz      = input(false, title='Vol. Buzz',              group='📋 Display')
show_UDratio      = input(true,  title='U/D Volume Ratio',       group='📋 Display')
show_rs_rating    = input(true,  title='RS Rating',              group='📋 Display')
show_liqCap       = input(false, title='Liquidity Cap (Shares)', group='📋 Display')
show_sector       = input(false, title='Sector',                 group='📋 Display')
show_ind          = input(false, title='Industry Group',         group='📋 Display')
show_selectSector = input(true,  title='Sector ETF + Change',    group='📋 Display')
show_sector_rs    = input(true,  title='Sector RS Rating',       group='📋 Display')

// ═══════════════════════════════════════════════════════════════
// ⚙️ PARAMETERS
// ═══════════════════════════════════════════════════════════════
adrp_len = input.int(20, title='ADR% Length (bars)', group='⚙️ Parameters', minval=5, maxval=60)
atr_len  = input.int(14, title='ATR Length (bars)',  group='⚙️ Parameters', minval=1, maxval=50)
len      = input.int(50, title='Volume MA Length',   group='⚙️ Parameters', minval=10, maxval=200)

// ═══════════════════════════════════════════════════════════════
// ⏱ DAILY DATA
// ═══════════════════════════════════════════════════════════════
s = syminfo.tickerid

closeDa = request.security(s, 'D', close)
openDa  = request.security(s, 'D', open)
highDa  = request.security(s, 'D', high)
lowDa   = request.security(s, 'D', low)
volDa   = request.security(s, 'D', volume)
maDa    = request.security(s, 'D', ta.sma(volume, len))

arpDa  = 100 * (request.security(s, 'D', ta.sma(high / low, adrp_len)) - 1)
atrDa  = request.security(s, 'D', ta.atr(atr_len))
atrpDa = 100 * (atrDa / closeDa)

ema8Da  = request.security(s, 'D', ta.ema(close, 8))
ema21Da = request.security(s, 'D', ta.ema(close, 21))
sma50Da = request.security(s, 'D', ta.sma(close, 50))

// ═══════════════════════════════════════════════════════════════
// 🕯️ PATTERN DETECTION
// ═══════════════════════════════════════════════════════════════
p_close     = request.security(s, pattern_tf, close)
p_open      = request.security(s, pattern_tf, open)
p_high      = request.security(s, pattern_tf, high)
p_low       = request.security(s, pattern_tf, low)
p_volume    = request.security(s, pattern_tf, volume)
p_ma        = request.security(s, pattern_tf, ta.sma(volume, len))
p_ema8      = request.security(s, pattern_tf, ta.ema(close, 8))
p_ema21     = request.security(s, pattern_tf, ta.ema(close, 21))
p_confirmed = request.security(s, pattern_tf, barstate.isconfirmed)

p_near_ema8  = p_low <= p_ema8 * (1.0 + ema8_prox_pct / 100.0) and p_low >= p_ema8 * (1.0 - ema8_prox_pct / 100.0)
p_near_ema21 = p_low <= p_ema21 * (1.0 + ema21_prox_pct / 100.0) and p_low >= p_ema21 * (1.0 - ema21_prox_pct / 100.0)
p_near_ema   = p_near_ema8 or p_near_ema21

p_rvol   = p_ma != 0 ? p_volume / p_ma * 100.0 : float(na)
p_vol_ok = nz(p_rvol) >= pattern_rvol_min
p_gate   = (require_ema_proximity ? p_near_ema : true) and (require_pattern_rvol ? p_vol_ok : true)

p_body      = math.abs(p_close - p_open)
p_lowerWick = math.min(p_open, p_close) - p_low
p_upperWick = p_high - math.max(p_open, p_close)
p_range     = p_high - p_low
p_isBullish = p_close > p_open

p_has_hist_1 = not na(p_open[1]) and not na(p_close[1]) and not na(p_low[1]) and not na(p_high[1])
p_has_hist_2 = p_has_hist_1 and not na(p_open[2]) and not na(p_close[2]) and not na(p_low[2]) and not na(p_high[2])

p_prev_body     = p_has_hist_1 ? math.abs(p_close[1] - p_open[1]) : float(na)
p_engulf_strict = p_has_hist_1 and p_body >= p_prev_body * (1.0 + engulf_min_body / 100.0)
p_engulfing     = show_engulfing and p_has_hist_1 and p_isBullish and p_close[1] < p_open[1] and p_open <= p_close[1] and p_close >= p_open[1] and p_engulf_strict and p_gate

p_doji_body_ok  = p_range > 0 and p_body <= p_range * (doji_body_tol / 100.0)
p_doji_wick_ok  = p_lowerWick >= p_body * doji_wick_ratio
p_doji_upper_ok = p_upperWick <= p_body * 0.5
p_doji          = show_doji and p_doji_body_ok and p_doji_wick_ok and p_doji_upper_ok and p_gate

p_ms_c1_bear  = p_has_hist_2 and p_close[2] < p_open[2]
p_ms_c1_body  = p_has_hist_2 ? math.abs(p_close[2] - p_open[2]) : float(na)
p_ms_c2_body  = p_has_hist_2 ? math.abs(p_close[1] - p_open[1]) : float(na)
p_ms_c2_small = p_has_hist_2 and p_ms_c2_body <= p_ms_c1_body * (ms_mid_body_pct / 100.0)
p_ms_c3_bull  = p_close > p_open
p_ms_c1_mid   = p_has_hist_2 ? math.min(p_open[2], p_close[2]) + p_ms_c1_body * (ms_close_pct / 100.0) : float(na)
p_ms_c3_close = p_has_hist_2 and p_close >= p_ms_c1_mid
p_morningstar = show_morningstar and p_has_hist_2 and p_ms_c1_bear and p_ms_c2_small and p_ms_c3_bull and p_ms_c3_close and p_gate

p_pl_c1_bear      = p_has_hist_1 and p_close[1] < p_open[1]
p_pl_c1_body      = p_has_hist_1 ? math.abs(p_close[1] - p_open[1]) : float(na)
p_pl_c1_bot       = p_has_hist_1 ? math.min(p_open[1], p_close[1]) : float(na)
p_pl_c1_mid       = p_has_hist_1 ? p_pl_c1_bot + p_pl_c1_body * (piercing_min_pct / 100.0) : float(na)
p_pl_opens_below  = p_has_hist_1 and p_open < p_low[1]
p_pl_closes_above = p_has_hist_1 and p_close >= p_pl_c1_mid and p_close < p_open[1]
p_piercing        = show_piercing and p_has_hist_1 and p_pl_c1_bear and p_pl_opens_below and p_pl_closes_above and p_isBullish and p_gate

p_count = (p_engulfing ? 1 : 0) + (p_doji ? 1 : 0) + (p_morningstar ? 1 : 0) + (p_piercing ? 1 : 0)
p_any   = p_count > 0

f_conf_color(_count, _engulf, _doji, _ms, _pierce) =>
    color _c = na
    if _count >= 2
        _c := multi_col_conf
    else if _engulf
        _c := engulf_col_conf
    else if _ms
        _c := morningstar_col_conf
    else if _pierce
        _c := piercing_col_conf
    else if _doji
        _c := doji_col_conf
    _c

f_form_color(_count, _engulf, _doji, _ms, _pierce) =>
    color _c = na
    if _count >= 2
        _c := multi_col_form
    else if _engulf
        _c := engulf_col_form
    else if _ms
        _c := morningstar_col_form
    else if _pierce
        _c := piercing_col_form
    else if _doji
        _c := doji_col_form
    _c

conf_col = f_conf_color(p_count, p_engulfing, p_doji, p_morningstar, p_piercing)
form_col = f_form_color(p_count, p_engulfing, p_doji, p_morningstar, p_piercing)

f_pattern_chart_match(_tf) =>
    bool _ok = false
    if _tf == 'D'
        _ok := timeframe.isdaily
    else if _tf == 'W'
        _ok := timeframe.isweekly
    else
        _ok := timeframe.period == _tf
    _ok

pattern_chart_match = f_pattern_chart_match(pattern_tf)
plot_confirmed = show_confirmed and p_any and p_confirmed and pattern_chart_match
plot_forming   = show_forming and p_any and not p_confirmed and pattern_chart_match

plotshape(plot_confirmed and symbol_size == 'Tiny',   title='✓ Pattern Confirmed Tiny',   style=shape.labelup,   location=location.abovebar, color=conf_col, text='✓', textcolor=color.white, size=size.tiny)
plotshape(plot_confirmed and symbol_size == 'Small',  title='✓ Pattern Confirmed Small',  style=shape.labelup,   location=location.abovebar, color=conf_col, text='✓', textcolor=color.white, size=size.small)
plotshape(plot_confirmed and symbol_size == 'Normal', title='✓ Pattern Confirmed Normal', style=shape.labelup,   location=location.abovebar, color=conf_col, text='✓', textcolor=color.white, size=size.normal)
plotshape(plot_confirmed and symbol_size == 'Large',  title='✓ Pattern Confirmed Large',  style=shape.labelup,   location=location.abovebar, color=conf_col, text='✓', textcolor=color.white, size=size.large)

plotshape(plot_forming and symbol_size == 'Tiny',   title='✕ Pattern Forming Tiny',   style=shape.labeldown, location=location.belowbar, color=form_col, text='✕', textcolor=color.white, size=size.tiny)
plotshape(plot_forming and symbol_size == 'Small',  title='✕ Pattern Forming Small',  style=shape.labeldown, location=location.belowbar, color=form_col, text='✕', textcolor=color.white, size=size.small)
plotshape(plot_forming and symbol_size == 'Normal', title='✕ Pattern Forming Normal', style=shape.labeldown, location=location.belowbar, color=form_col, text='✕', textcolor=color.white, size=size.normal)
plotshape(plot_forming and symbol_size == 'Large',  title='✕ Pattern Forming Large',  style=shape.labeldown, location=location.belowbar, color=form_col, text='✕', textcolor=color.white, size=size.large)

// ═══════════════════════════════════════════════════════════════
// 🎯 U&R
// ═══════════════════════════════════════════════════════════════
relVol_da = maDa != 0 ? volDa / maDa * 100.0 : float(na)

prevDayHigh = highDa[1]
abovePDH    = closeDa > prevDayHigh

candleRange  = highDa - lowDa
closePct     = candleRange > 0 ? (closeDa - lowDa) / candleRange * 100.0 : float(na)
lowerWickPct = candleRange > 0 ? (math.min(openDa, closeDa) - lowDa) / candleRange * 100.0 : float(na)
hasWick      = nz(lowerWickPct) > 5.0

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
sectorGreen = nz(sector_chg) > 0

ema8_undercut  = lowDa <= ema8Da and closeDa > ema8Da
ema21_undercut = lowDa <= ema21Da and closeDa > ema21Da
ema8_tap       = lowDa > ema8Da and lowDa <= ema8Da * (1.0 + ur_tap_pct / 100.0) and closeDa > ema8Da
ema21_tap      = lowDa > ema21Da and lowDa <= ema21Da * (1.0 + ur_tap_pct / 100.0) and closeDa > ema21Da

any_undercut = ema8_undercut or ema21_undercut
any_tap      = (ema8_tap or ema21_tap) and not any_undercut
any_signal   = any_undercut or any_tap

ema_which = ''
ema_which_short = ''
if any_signal
    if (ema8_undercut and ema21_undercut) or (ema8_tap and ema21_tap and not any_undercut)
        ema_which := '[8+21]'
        ema_which_short := '[8+21]'
    else if ema8_undercut or ema8_tap
        ema_which := '[8 EMA]'
        ema_which_short := '[8]'
    else
        ema_which := '[21 EMA]'
        ema_which_short := '[21]'

type_label = any_undercut ? 'Undercut' : 'Tap'
type_label_short = any_undercut ? 'U&R' : 'Tap'
pdh_label  = abovePDH ? ' ↑PDH' : ' ↓PDH'
pdh_label_short = abovePDH ? ' ↑PDH' : ''

ur_pts = 0
if any_signal
    ur_pts := (nz(closePct) >= 50.0 ? 1 : 0) + (nz(relVol_da) >= ur_rvol_min ? 1 : 0) + (hasWick ? 1 : 0) + (sectorGreen ? 1 : 0)

ur_icon = ''
ur_col  = txt_col
if any_signal
    if ur_pts >= 4 and abovePDH
        ur_icon := '🔥 '
        ur_col  := col_elite
    else if ur_pts >= 3
        ur_icon := '🎯 '
        ur_col  := col_positive
    else
        ur_icon := '⚠️ '
        ur_col  := col_neutral

ur_displayStr = '—'
ur_displayCompact = '—'
if any_signal
    ur_displayStr := ur_icon + type_label + ' ' + ema_which + pdh_label
    ur_displayCompact := ur_icon + type_label_short + ' ' + ema_which_short + pdh_label_short

// ═══════════════════════════════════════════════════════════════
// 📊 RS / QUALITY SUPPORT
// ═══════════════════════════════════════════════════════════════
upVolDa      = closeDa > closeDa[1] ? volDa : 0.0
dnVolDa      = closeDa < closeDa[1] ? volDa : 0.0
sumUpDa      = math.sum(upVolDa, 50)
sumDnDa      = math.sum(dnVolDa, 50)
upDnVolRatio = sumDnDa != 0 ? nz(sumUpDa / sumDnDa, 1.0) : float(na)

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
// 📊 LAYERED ENGINE
// ═══════════════════════════════════════════════════════════════
chk_trend_close21 = not trend_require_close_above_21 or closeDa > ema21Da
chk_trend_stack   = not trend_require_8_over_21 or ema8Da > ema21Da
chk_trend_21rise  = not trend_require_21_rising or ema21Da > ema21Da[1]
chk_trend_close50 = not trend_require_close_above_50 or closeDa > sma50Da

trend_total_raw =
     (trend_require_close_above_21 ? 1 : 0) +
     (trend_require_8_over_21 ? 1 : 0) +
     (trend_require_21_rising ? 1 : 0) +
     (trend_require_close_above_50 ? 1 : 0)

trend_pass_raw =
     (trend_require_close_above_21 and chk_trend_close21 ? 1 : 0) +
     (trend_require_8_over_21 and chk_trend_stack ? 1 : 0) +
     (trend_require_21_rising and chk_trend_21rise ? 1 : 0) +
     (trend_require_close_above_50 and chk_trend_close50 ? 1 : 0)

trend_total = trend_total_raw == 0 ? 1 : trend_total_raw
trend_pass  = trend_total_raw == 0 ? 1 : trend_pass_raw
trend_ok    = chk_trend_close21 and chk_trend_stack and chk_trend_21rise and chk_trend_close50

trend_str = ''
trend_str_compact = ''
trend_col = col_negative
if trend_ok
    trend_str := '✅ Pass ' + str.tostring(trend_pass) + '/' + str.tostring(trend_total)
    trend_str_compact := '✅ ' + str.tostring(trend_pass) + '/' + str.tostring(trend_total)
    trend_col := col_positive
else if trend_pass >= trend_total - 1
    trend_str := '⚠️ Mixed ' + str.tostring(trend_pass) + '/' + str.tostring(trend_total)
    trend_str_compact := '⚠️ ' + str.tostring(trend_pass) + '/' + str.tostring(trend_total)
    trend_col := col_neutral
else
    trend_str := '❌ Fail ' + str.tostring(trend_pass) + '/' + str.tostring(trend_total)
    trend_str_compact := '❌ ' + str.tostring(trend_pass) + '/' + str.tostring(trend_total)
    trend_col := col_negative

avgDollarVolRaw = closeDa * maDa
use_liq_vol     = liq_min_avg_vol > 0
use_liq_advdol  = liq_min_avg_dollar_m > 0

chk_quality_rs     = nz(totalRsRating, 0.0) >= trade_min_rs
chk_quality_rvol   = nz(relVol_da, 0.0) >= trade_min_rvol
chk_quality_avgvol = not use_liq_vol or maDa >= liq_min_avg_vol
chk_quality_advdol = not use_liq_advdol or avgDollarVolRaw >= liq_min_avg_dollar_m * 1000000.0
chk_quality_sector = not trade_req_sector or sectorGreen

quality_total_raw = 2 + (use_liq_vol ? 1 : 0) + (use_liq_advdol ? 1 : 0) + (trade_req_sector ? 1 : 0)

quality_pass_raw =
     (chk_quality_rs ? 1 : 0) +
     (chk_quality_rvol ? 1 : 0) +
     (use_liq_vol and chk_quality_avgvol ? 1 : 0) +
     (use_liq_advdol and chk_quality_advdol ? 1 : 0) +
     (trade_req_sector and chk_quality_sector ? 1 : 0)

quality_total = quality_total_raw == 0 ? 1 : quality_total_raw
quality_pass  = quality_total_raw == 0 ? 1 : quality_pass_raw
quality_ok    = chk_quality_rs and chk_quality_rvol and chk_quality_avgvol and chk_quality_advdol and chk_quality_sector

quality_str = ''
quality_str_compact = ''
quality_col = col_negative
if quality_ok
    quality_str := '✅ Pass ' + str.tostring(quality_pass) + '/' + str.tostring(quality_total)
    quality_str_compact := '✅ ' + str.tostring(quality_pass) + '/' + str.tostring(quality_total)
    quality_col := col_positive
else if quality_pass >= quality_total - 1
    quality_str := '⚠️ Mixed ' + str.tostring(quality_pass) + '/' + str.tostring(quality_total)
    quality_str_compact := '⚠️ ' + str.tostring(quality_pass) + '/' + str.tostring(quality_total)
    quality_col := col_neutral
else
    quality_str := '❌ Fail ' + str.tostring(quality_pass) + '/' + str.tostring(quality_total)
    quality_str_compact := '❌ ' + str.tostring(quality_pass) + '/' + str.tostring(quality_total)
    quality_col := col_negative

pullback_8  = lowDa >= ema8Da and lowDa <= ema8Da * (1.0 + pullback_zone_pct / 100.0) and closeDa > ema8Da and nz(closePct) >= pullback_close_pct and (not pullback_require_green or closeDa >= openDa)
pullback_21 = lowDa >= ema21Da and lowDa <= ema21Da * (1.0 + pullback_zone_pct / 100.0) and closeDa > ema21Da and nz(closePct) >= pullback_close_pct and (not pullback_require_green or closeDa >= openDa)

trigger_ur_ok       = allow_ur_trigger and any_signal
trigger_pullback_ok = allow_pullback_trigger and not trigger_ur_ok and (pullback_8 or pullback_21)
trigger_ok          = trigger_ur_ok or trigger_pullback_ok

pullback_which = ''
pullback_which_short = ''
if pullback_8 and pullback_21
    pullback_which := '[8+21]'
    pullback_which_short := '[8+21]'
else if pullback_8
    pullback_which := '[8 EMA]'
    pullback_which_short := '[8]'
else if pullback_21
    pullback_which := '[21 EMA]'
    pullback_which_short := '[21]'

trigger_str = ''
trigger_str_compact = ''
trigger_col = col_negative
if trigger_ur_ok
    trigger_str := ur_displayStr
    trigger_str_compact := ur_displayCompact
    trigger_col := ur_col
else if trigger_pullback_ok
    trigger_str := '↗ Pullback ' + pullback_which
    trigger_str_compact := '↗ PB ' + pullback_which_short
    trigger_col := col_positive
else if trend_ok and quality_ok
    trigger_str := '… Waiting'
    trigger_str_compact := '… Wait'
    trigger_col := col_neutral
else
    trigger_str := '— None'
    trigger_str_compact := '—'
    trigger_col := col_negative

f_pattern_name(_count, _engulf, _doji, _ms, _pierce) =>
    string _name = 'None'
    if _count >= 2
        _name := 'Multiple (' + str.tostring(_count) + ')'
    else if _engulf
        _name := 'Engulfing'
    else if _ms
        _name := 'Morning Star'
    else if _pierce
        _name := 'Piercing'
    else if _doji
        _name := 'Dragonfly Doji'
    _name

f_pattern_name_short(_count, _engulf, _doji, _ms, _pierce) =>
    string _name = 'None'
    if _count >= 2
        _name := 'Multi(' + str.tostring(_count) + ')'
    else if _engulf
        _name := 'Engulf'
    else if _ms
        _name := 'MStar'
    else if _pierce
        _name := 'Pierce'
    else if _doji
        _name := 'Doji'
    _name

pattern_name       = f_pattern_name(p_count, p_engulfing, p_doji, p_morningstar, p_piercing)
pattern_name_short = f_pattern_name_short(p_count, p_engulfing, p_doji, p_morningstar, p_piercing)
pattern_bonus_ok = p_any and p_confirmed

pattern_str = ''
pattern_str_compact = ''
pattern_row_col = col_negative
if pattern_bonus_ok
    pattern_str := '✓ ' + pattern_name
    pattern_str_compact := '✓ ' + pattern_name_short
    pattern_row_col := conf_col
else if p_any and not p_confirmed
    pattern_str := '… Forming ' + pattern_name
    pattern_str_compact := '… ' + pattern_name_short
    pattern_row_col := col_neutral
else
    pattern_str := '— None'
    pattern_str_compact := '—'
    pattern_row_col := col_negative

base_ready       = trend_ok and quality_ok and trigger_ok
watch_ok         = trend_ok and quality_ok and not trigger_ok
trade_ready_plus = base_ready and pattern_bonus_ok
trade_ready      = base_ready and not pattern_bonus_ok
trade_not_ready  = not trend_ok or not quality_ok

trade_str = ''
trade_col = col_negative
if trade_not_ready
    trade_str := '❌ Not Ready'
    trade_col := col_negative
else if watch_ok
    trade_str := '👀 Watch'
    trade_col := col_neutral
else if trade_ready_plus
    trade_str := '🔥 Ready+'
    trade_col := col_elite
else if trade_ready
    trade_str := '✅ Ready'
    trade_col := col_positive
else
    trade_str := '❌ Not Ready'
    trade_col := col_negative

// ═══════════════════════════════════════════════════════════════
// 📐 OTHER METRICS
// ═══════════════════════════════════════════════════════════════
arp  = arpDa
atr  = atrDa
atrp = atrpDa

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

vol_tf = volume
ma_tf  = ta.sma(vol_tf, len)

relVol_tf    = ma_tf != 0 ? vol_tf / ma_tf * 100.0 : float(na)
volBuzz_tf   = ma_tf != 0 ? 100.0 * (vol_tf / ma_tf - 1.0) : float(na)
lod_dist_tf  = atrDa != 0 ? 100.0 * (close - low) / atrDa : float(na)
lod_price_tf = low

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

volBuzz_da   = maDa != 0 ? 100.0 * (volDa / maDa - 1.0) : float(na)
lod_dist_da  = atrDa != 0 ? 100.0 * (closeDa - lowDa) / atrDa : float(na)
lod_price_da = lowDa

time_left_da   = request.security(s, 'D', (time_close - timenow) / 1000.0)
time_passed_da = request.security(s, 'D', (timenow - time) / 1000.0)
vol_proj_da    = volDa
if time_left_da > 0 and time_passed_da > 0
    vol_proj_da := volDa + (volDa / time_passed_da * time_left_da)

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

relVol    = lock_daily ? relVol_da : relVol_tf
volBuzz   = lock_daily ? volBuzz_da : volBuzz_tf
lod_dist  = lock_daily ? lod_dist_da : lod_dist_tf
lod_price = lock_daily ? lod_price_da : lod_price_tf
vol_proj  = lock_daily ? vol_proj_da : vol_proj_tf
uP        = lock_daily ? uP_da : uP_tf

// ═══════════════════════════════════════════════════════════════
// ⭐ SETUP SCORE
// ═══════════════════════════════════════════════════════════════
rsComp     = totalRsRating > 0 ? math.min(totalRsRating, 99) / 99.0 * 40.0 : 0.0
rvolComp   = not na(relVol) ? math.min(nz(relVol), 300.0) / 300.0 * 30.0 : 0.0
adrComp    = not na(arp) ? math.min(math.max(nz(arp), 0.0), 10.0) / 10.0 * 30.0 : 0.0
setupScore = math.round(rsComp + rvolComp + adrComp)

setupLabel = '❌ Weak'
setupLabelCompact = 'W'
if setupScore >= 80
    setupLabel := '🔥 Elite'
    setupLabelCompact := 'E'
else if setupScore >= 60
    setupLabel := '✅ Strong'
    setupLabelCompact := 'S'
else if setupScore >= 40
    setupLabel := '⚠️ Mod'
    setupLabelCompact := 'M'

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

fmtNA(val, fmt) =>
    na(val) ? 'N/A' : str.tostring(val, fmt)

// ═══════════════════════════════════════════════════════════════
// 🚨 ALERTS
// ═══════════════════════════════════════════════════════════════
alertcondition(watch_ok,         title='👀 Layered Watch',  message='{{ticker}} layered swing setup is WATCH.')
alertcondition(base_ready,       title='✅ Layered Ready',  message='{{ticker}} layered swing setup is READY.')
alertcondition(trade_ready_plus, title='🔥 Layered Ready+', message='{{ticker}} layered swing setup is READY+ with confirmed pattern bonus.')

alertcondition(any_signal and ur_pts >= 4 and abovePDH, title='🔥 U&R Elite + ↑PDH', message='{{ticker}} Elite U&R above PDH!')
alertcondition(any_signal and ur_pts >= 3,              title='🎯 U&R Confirmed',   message='{{ticker}} Confirmed U&R!')
alertcondition(any_undercut,                            title='🎯 U&R Undercut',    message='{{ticker}} Undercut & Rally!')
alertcondition(any_tap,                                 title='👆 U&R Tap',         message='{{ticker}} Tap & Rally!')

alertcondition(p_engulfing and p_confirmed,   title='✓ Bullish Engulfing', message='{{ticker}} Bullish Engulfing confirmed!')
alertcondition(p_doji and p_confirmed,        title='✓ Dragonfly Doji',    message='{{ticker}} Dragonfly Doji confirmed!')
alertcondition(p_morningstar and p_confirmed, title='✓ Morning Star',      message='{{ticker}} Morning Star confirmed!')
alertcondition(p_piercing and p_confirmed,    title='✓ Piercing Line',     message='{{ticker}} Piercing Line confirmed!')
alertcondition(p_count >= 2 and p_confirmed,  title='✓ Multiple Patterns', message='{{ticker}} Multiple patterns confirmed!')
alertcondition(p_any and not p_confirmed,     title='✕ Pattern Forming',   message='{{ticker}} Pattern potentially forming — watch it!')

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
        table.cell(t, 1, row, '', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.merge_cells(t, 0, row, 1, row)
        row += 1

    if show_trade
        if show_trend_row
            table.cell(t, 0, row, mobile_compact ? 'TRND' : 'TREND', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
            table.cell(t, 1, row, mobile_compact ? trend_str_compact : trend_str, text_color=trend_col, text_size=size_tbl, bgcolor=bg_col)
            row += 1

        if show_quality_row
            table.cell(t, 0, row, mobile_compact ? 'QUAL' : 'QUALITY', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
            table.cell(t, 1, row, mobile_compact ? quality_str_compact : quality_str, text_color=quality_col, text_size=size_tbl, bgcolor=bg_col)
            row += 1

        if show_trigger_row
            table.cell(t, 0, row, mobile_compact ? 'TRIG' : 'TRIGGER', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
            table.cell(t, 1, row, mobile_compact ? trigger_str_compact : trigger_str, text_color=trigger_col, text_size=size_tbl, bgcolor=bg_col)
            row += 1

        if show_pattern_row
            table.cell(t, 0, row, mobile_compact ? 'PATT' : 'PATTERN', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
            table.cell(t, 1, row, mobile_compact ? pattern_str_compact : pattern_str, text_color=pattern_row_col, text_size=size_tbl, bgcolor=bg_col)
            row += 1

        if show_trade_row
            table.cell(t, 0, row, mobile_compact ? 'TRD' : 'TRADE', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
            table.cell(t, 1, row, trade_str, text_color=trade_col, text_size=size_tbl, bgcolor=bg_col)
            row += 1

    if show_ur
        table.cell(t, 0, row, 'U&R', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, mobile_compact ? ur_displayCompact : ur_displayStr, text_color=ur_col, text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_setupScore
        scoreText = mobile_compact ? str.tostring(setupScore) + ' ' + setupLabelCompact : str.tostring(setupScore) + ' ' + setupLabel
        table.cell(t, 0, row, mobile_compact ? '⭐' : '⭐ Score', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, scoreText, text_color=f_setupColor(setupScore), text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_adrp
        table.cell(t, 0, row, 'ADR%', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(arp, mobile_compact ? '0.0' : '0.00') + '%', text_color=f_adrColor(nz(arp)), text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_atrPer
        table.cell(t, 0, row, 'ATR%', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(atrp, mobile_compact ? '0.0' : '0.00') + '%', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_atr
        table.cell(t, 0, row, 'ATR $', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(atr, mobile_compact ? '0.0' : '0.00'), text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_lod_dist
        table.cell(t, 0, row, mobile_compact ? 'LoD%' : 'LoD Dist', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(lod_dist, mobile_compact ? '0.0' : '0.00') + '%', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_ADV
        table.cell(t, 0, row, 'Avg Vol', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(avgDaVol, mobile_compact ? '0.0' : '0.00') + uV, text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_projectedVol
        table.cell(t, 0, row, 'Proj Vol', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(vol_proj, mobile_compact ? '0.0' : '0.00') + uP, text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
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
        table.cell(t, 1, row, fmtNA(upDnVolRatio, mobile_compact ? '0.0' : '0.00'), text_color=f_udColor(nz(upDnVolRatio, 1.0)), text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_rs_rating
        rsVal  = nz(totalRsRating, -1.0)
        rsIcon = rsVal >= 90 ? ' 🏆' : rsVal >= 80 ? ' ✅' : rsVal >= 50 ? ' ⚠️' : ' ❌'
        rsStr  = rsVal < 0 ? 'N/A' : str.tostring(rsVal, mobile_compact ? '0' : '0.0') + rsIcon
        table.cell(t, 0, row, 'RS', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, rsStr, text_color=f_rsColor(rsVal), text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_mktCap
        table.cell(t, 0, row, 'Mkt Cap', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(MCap, mobile_compact ? '0.0' : '0.00') + uM, text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_float
        table.cell(t, 0, row, 'Float', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(sharesFloat, mobile_compact ? '0.0' : '0.00') + uF, text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_floatpercent
        table.cell(t, 0, row, 'Float %', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(floatPer, mobile_compact ? '0' : '0.0') + '%', text_color=f_floatColor(nz(floatPer)), text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_ipo_date
        table.cell(t, 0, row, 'IPO', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(ipoSince, mobile_compact ? '0.0' : '0.00') + 'Y', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_lod_price
        table.cell(t, 0, row, 'LoD', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(lod_price, mobile_compact ? '0.0' : '0.00'), text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_dist_high
        table.cell(t, 0, row, '52W High', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(distFromHigh, mobile_compact ? '0' : '0.0') + '%', text_color=f_distHighColor(nz(distFromHigh, -100)), text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_dist_low
        table.cell(t, 0, row, '52W Low', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, '+' + fmtNA(distFromLow, mobile_compact ? '0' : '0.0') + '%', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_ADVS
        table.cell(t, 0, row, 'Avg$ Vol', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, '$' + fmtNA(advdolDa, mobile_compact ? '0.0' : '0.00') + uVDoll, text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_liqCap
        table.cell(t, 0, row, 'Liq Cap', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, fmtNA(liquidityCap, '0'), text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_sector
        table.cell(t, 0, row, sector, text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, '', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.merge_cells(t, 0, row, 1, row)
        row += 1

    if show_selectSector
        sectorData = show_sector_rs ? sector_etf + ' (RS ' + str.tostring(sectorRs, '0') + ')' : sector_etf
        sectorChgStr = na(sector_chg) ? 'N/A' : (sector_chg > 0 ? '+' : '') + str.tostring(sector_chg, mobile_compact ? '0.0' : '0.00') + '%'
        table.cell(t, 0, row, sectorData, text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, sectorChgStr, text_color=na(sector_chg) ? txt_col : (sector_chg > 0 ? sector_chg_Up : sector_chg_Dn), text_size=size_tbl, bgcolor=bg_col)
        row += 1

    if show_ind
        table.cell(t, 0, row, industryGrp, text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.cell(t, 1, row, '', text_color=txt_col, text_size=size_tbl, bgcolor=bg_col)
        table.merge_cells(t, 0, row, 1, row)
        row += 1
````

# SwingPro Enhance [U&R- ALL in ONE]

- url: https://www.tradingview.com/script/tQBbn4LG-SwingPro-Enhance-U-R-ALL-in-ONE/
- type: indicator
- pine_id: PUB;f6b0377bc5dd42c892416d64d4b9273d
- version: 1.0

## Description

SwingPro 

Overview
SwingPro is a comprehensive swing trading dashboard built for active traders who want all critical setup information on a single chart. It evaluates every stock through a structured 4-layer system — Trend, Quality, Trigger, and Pattern — and delivers a clear trade readiness label so you can make faster, more consistent decisions without switching between indicators.
All core metrics are locked to Daily data by default, meaning the dashboard shows the same reliable swing-level information regardless of whether you're viewing a 5-minute, 15-minute, or daily chart.

The 4-Layer Trade Engine
The heart of SwingPro is a layered qualification system. Every layer must pass before the next one matters. Think of it as a checklist that runs automatically on every bar.

Layer 1 — TREND
Confirms the stock is in a healthy uptrend structure. All enabled conditions must pass simultaneously.
Conditions (each toggleable):

Close Above 21 EMA — price is trading above the intermediate trend line
8 EMA Above 21 EMA — short-term momentum is leading intermediate trend (stack alignment)
21 EMA Rising — the trend line itself is pointing up, not flattening or turning down
Close Above 50 SMA — optional longer-term filter for position traders

Display: ✅ Pass 3/3 → all conditions met. ⚠️ Mixed 2/3 → one condition failing. ❌ Fail → trend is broken.
A stock failing TREND is automatically disqualified regardless of what the other layers show.

Layer 2 — QUALITY
Filters for institutional-grade setups. Weak stocks with low liquidity, poor relative strength, or no volume behind them are filtered out here.
Conditions:

RS Rating ≥ 85 (default) — stock must be outperforming at least 85% of the market. Based on a 12-month relative strength calculation comparing the stock to SPY across multiple weighted time windows.
RVol ≥ 120% (default) — relative volume must show meaningful participation. Uses projected daily volume so early-session readings are accurate even at 10am.
Avg Daily Volume ≥ 500K shares — minimum liquidity gate
Avg Daily Dollar Volume ≥ $25M — ensures the stock is tradeable at meaningful size
Sector ETF Green — the stock's sector must be positive on the day, confirming the broader group is supporting the move

⚡ Tap Mode — Relaxed Quality:
When a U&R tap or undercut fires, Quality automatically switches to relaxed thresholds (RS ≥ 70, RVol ≥ 80%, sector waived). This is intentional — U&R setups are stock-specific liquidity events and the sector being slightly red can actually signal relative strength. The QUALITY row shows ⚡ Tap Mode when relaxed rules are active.

Layer 3 — TRIGGER
Identifies the specific price action event that signals institutional buyers have stepped in. Two trigger types are supported.
U&R (Undercut & Rally):
The most powerful trigger. Price breaks below a key EMA level — flushing stop losses and triggering emotional selling — then buyers absorb the supply and price reclaims back above the level. This represents a genuine shift in control from sellers to buyers.
Three levels are monitored:

Daily 8 EMA — short-term institutional support
Daily 21 EMA — intermediate trend support
Weekly 9 EMA — major institutional level, highest conviction when triggered

How U&R detection works:
The lookback setting scans recent daily (or weekly) bars for any bar where the low dipped below the EMA. If an undercut is found AND the current close is back above the EMA AND the candle is green (optional), the signal fires. This multi-bar approach correctly captures the full sequence: red breakdown candle → absorption → green reclaim candle.
U&R Score (⚠️ / 🎯 / 🔥):
Each U&R signal is scored across 5 quality factors:

Close in upper 50%+ of candle range (strong close, buyers in control)
RVol above threshold (volume confirms absorption)
Lower wick present (clear rejection of lows)
Sector ETF green (broad market tailwind)
Weekly 9 EMA undercut bonus (+1 point for higher timeframe confirmation)

⚠️ = 1–2 points → signal is weak, wait for follow-through before entering
🎯 = 3 points → solid setup, standard entry
🔥 = 4–5 points + above PDH → highest conviction, price has already broken above prior day's high
Pullback Trigger:
For setups where price hasn't undercut but is pulling back cleanly to the EMA. Fires when the candle low touches within X% of the 8 or 21 EMA, closes above it, closes in the upper portion of its range, and is a green candle. All three conditions are configurable.

Layer 4 — PATTERN (Informational)
Seven bullish candlestick patterns are detected on the last closed daily candle and displayed as additional confirmation. Pattern detection is separate from the trade decision — it's your extra conviction tool, not a gate.
Patterns detected:

Bullish Engulfing
Dragonfly Doji
Morning Star
Piercing Line
Hammer
Bullish Harami
Three White Soldiers

Each pattern uses a strict definition with real-body requirements, wick ratios, and context filters (prior candle must be bearish for reversal patterns). Patterns are restricted to regular market hours only — no pre-market or after-hours false signals.
Display options: Symbol (✓ label above the bar), Candle Color (recolors the bar with the pattern's color), or Both. The icon can be locked to fire once per day, once per week, or once per 4-hour block to prevent flooding on intraday charts.

TRADE Label
The final output. Determined entirely by the first three layers — pattern is informational only.

✅ Ready — TREND + QUALITY + TRIGGER all pass. This is your actionable signal.
👀 Watch — TREND + QUALITY pass but no trigger has fired yet. Stock is in position, wait for the entry.
❌ Not Ready — TREND or QUALITY fails. No trade regardless of what else is happening.


U&R Detail Row
An optional dedicated row showing the full U&R signal string. Off by default to save space since the TRIGGER row already shows everything. Turn on if you want the U&R breakdown always visible.

Setup Score (⭐)
A composite score from 0–100 built from three weighted components:

RS Rating (40 points max) — relative strength quality
RVol (30 points max) — volume conviction, capped at 300%
ADR% (30 points max) — average daily range, measures the stock's natural movement potential

Use this to compare multiple ✅ Ready stocks and prioritize the highest-scoring setup when you can only take one trade.

Additional Metrics
Every metric in the table is pulled from daily data and locked to swing-relevant timeframes.
MetricWhat it tells youADR%Average daily range % — how much the stock typically moves per day. Higher = more opportunity per tradeATR%Average true range as % of price — volatility normalized to price levelATR $Average true range in dollars — useful for stop sizingLoD DistHow far today's low is from the current price as % of ATR — tells you how extended you are from the day's worst levelAvg Vol50-day average daily volumeProj VolProjected end-of-day volume based on current pace — accurate intraday signal for volume convictionRVolRelative volume vs 20-day average of closed sessions. Uses projected volume so it reads correctly at any time of dayBuzzVolume buzz % — how much today's projected volume exceeds the averageU/DUp/Down volume ratio — ratio of volume on up-days vs down-days over recent historyRSRelative Strength rating 1–99 vs SPY. 99 = top 1% performerMkt CapMarket capitalizationFloatShares available for public tradingFloat %Float as % of total shares — low float stocks move more aggressivelyIPOYears since IPO — newer stocks have different institutional ownership dynamicsLoDToday's low price52W HighDistance from 52-week high as %52W Low% above 52-week lowAvg$ VolAverage daily dollar volume — best liquidity measure for position sizingSectorStock's sector classificationSector ETFSector ETF name and today's % changeIndustryIndustry group

RVol Mode
Two options for how RVol is calculated:
Current Day — Raw volume traded so far divided by the 20-day average. Conservative. Reads low early in the session. Best for end-of-day analysis or if you only take entries after 2pm.
Projected (recommended) — Projects the end-of-day volume based on current pace using time elapsed and time remaining. Gives you an accurate real-time reading at 10am rather than a misleadingly low raw number. A minimum elapsed time setting (default 30 minutes) prevents the opening bell spike from distorting the projection.

Settings Quick Reference
Lock All Metrics to Daily TF — Keep ON for swing trading. Ensures all metrics reflect daily data regardless of your chart timeframe.
U&R Lookback (bars) — Default 3. How many recent daily bars to scan for an undercut. Keep at 2–4 for clean setups. Higher values catch more but reduce precision.
Weekly 9 EMA Lookback (weeks) — Default 2. How many weekly bars to scan. Value of 1 = same-week undercut and reclaim only (rarest, highest quality).
Require Green Reclaim Candle — Keep ON. Ensures the reclaim candle shows buyers in control (close > open). Filters out weak red reclaims that look like U&Rs but aren't.
Pattern Display TF — Set to D when using intraday charts to prevent icon flooding. One icon appears at the start of each new trading day.
Mobile Compact Mode — Shortens all table labels to fit smaller screens without scrolling.

How to Use in a Real Trade
Step 1 — Scan for ✅ Ready
Use a watchlist or scanner and look for stocks showing ✅ Ready on the TRADE label. These have all three layers passing simultaneously.
Step 2 — Check the trigger type
🔥 U&R [9W EMA] ↑PDH is the highest conviction signal — weekly level defended, score 4+, already above prior day's high. 🎯 U&R [8 EMA] is solid. ⚠️ Pullback [21] is the weakest — proceed carefully.
Step 3 — Use pattern as confirmation
If the PATTERN row shows ✓ Engulfing or ✓ Hammer alongside a 🎯 or 🔥 trigger, that's multiple independent signals aligning. Size up.
Step 4 — Use Setup Score to prioritize
When multiple stocks show ✅ Ready on the same day, take the highest Setup Score first.
Step 5 — Stop placement
Place your stop below the low of the undercut candle (the day price dipped below the EMA). That low represents the level the market tested and rejected — if price returns below it, the setup has failed.

Alerts Available

Price crossed Daily 8/21 EMA
U&R Undercut (any daily EMA)
U&R Weekly 9 EMA (separate high-priority alert)
U&R Tap
Layered Setup Ready (✅)
All 7 individual pattern confirmations
Multiple patterns confirmed
Morning Star, Engulfing, Hammer, Harami, Piercing, Doji, 3 White Soldiers


SwingPro is a decision-support tool. All signals should be used in conjunction with your own analysis, risk management rules, and position sizing discipline. Past signal performance does not guarantee future results.

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
// Pattern detection is locked to Daily TF (last closed daily candle).
// The pattern_tf input has been removed — patterns always use 'D'.

show_confirmed = input(true,
     title='Show Confirmed ✓ (closed candle)',
     group='🕯️ Candle Patterns',
     tooltip='ON = only confirmed closed daily candles trigger a pattern icon.\n\nPatterns are always evaluated on the last closed daily candle regardless of chart timeframe.')

symbol_size = input.string('Small',
     title='Symbol Size',
     group='🕯️ Candle Patterns',
     options=['Tiny', 'Small', 'Normal', 'Large'])

pattern_display_mode = input.string('Symbol',
     title='Pattern Display Mode',
     options=['Symbol', 'Candle Color', 'Both'],
     group='🕯️ Candle Patterns',
     tooltip='Controls how a confirmed pattern is shown on the chart.\n\n📌 Symbol — ✓ label above the bar.\n\n📌 Candle Color — colors the candle body with the pattern color.\n\n📌 Both — symbol and candle color together.')




pattern_display_tf = input.string('D',
     title='Pattern Icon Display TF',
     options=['D', 'W', '240', 'All Bars'],
     group='🕯️ Candle Patterns',
     tooltip='Controls how often the pattern icon is stamped on the chart when viewing an intraday or lower timeframe.\n\nPattern DATA is always locked to the Daily closed candle — this setting only controls WHERE the icon appears.\n\n──────────────────────\n📌 D — Daily (recommended)\n──────────────────────\nOne icon per day. The confirmed ✓ icon appears on the first bar of the next trading day.\n\nBest for: swing traders viewing 15m / 30m / 1H charts. Avoids the icon-flood you get when the same daily pattern is stamped on every intraday bar.\n\n──────────────────────\n📌 W — Weekly\n──────────────────────\nOne icon per week. Appears on the first bar of the new trading week.\n\nBest for: position traders reviewing daily or 4H charts.\n\n──────────────────────\n📌 240 — 4 Hour\n──────────────────────\nOne icon per 4-hour block. Appears on the first bar of each new 4H period.\n\nBest for: viewing 15m or 30m charts where you want the icon to appear close to when the daily pattern was actually triggered.\n\n──────────────────────\n📌 All Bars\n──────────────────────\nIcon appears on every bar where the pattern condition is true (original behavior).\n\nOnly recommended when viewing the Daily chart directly — on intraday charts this floods every bar with icons as shown in the screenshot.')

// — Pattern toggles ——————————————————————————————————————————
show_engulfing      = input(true,  title='Show Bullish Engulfing',   group='🕯️ Candle Patterns')
show_doji           = input(true,  title='Show Dragonfly Doji',      group='🕯️ Candle Patterns')
show_morningstar    = input(true,  title='Show Morning Star',        group='🕯️ Candle Patterns')
show_piercing       = input(true,  title='Show Piercing Line',       group='🕯️ Candle Patterns')
show_hammer         = input(true,  title='Show Hammer',              group='🕯️ Candle Patterns')
show_harami         = input(true,  title='Show Bullish Harami',      group='🕯️ Candle Patterns')
show_three_soldiers = input(true,  title='Show Three White Soldiers',group='🕯️ Candle Patterns')

// — Confirmed colors ————————————————————————————————————————
engulf_col_conf         = input(color.rgb(27, 94, 32),   title='Engulfing ✓ Color',       group='🕯️ Candle Patterns')
doji_col_conf           = input(color.rgb(0, 96, 100),   title='Dragonfly ✓ Color',       group='🕯️ Candle Patterns')
morningstar_col_conf    = input(color.rgb(74, 20, 140),  title='Morning Star ✓ Color',    group='🕯️ Candle Patterns')
piercing_col_conf       = input(color.rgb(230, 81, 0),   title='Piercing ✓ Color',        group='🕯️ Candle Patterns')
hammer_col_conf         = input(color.rgb(21, 101, 192), title='Hammer ✓ Color',          group='🕯️ Candle Patterns')
harami_col_conf         = input(color.rgb(0, 121, 107),  title='Bullish Harami ✓ Color',  group='🕯️ Candle Patterns')
soldiers_col_conf       = input(color.rgb(130, 119, 23), title='3 Soldiers ✓ Color',      group='🕯️ Candle Patterns')
multi_col_conf          = input(color.rgb(245, 127, 23), title='Multiple ✓ Color',        group='🕯️ Candle Patterns')




// ═══════════════════════════════════════════════════════════════
// 🎯 U&R SIGNAL SETTINGS
// ═══════════════════════════════════════════════════════════════
show_ur = input(false,
     title='Show U&R Detail Row',
     group='🎯 U&R Signal',
     tooltip='Toggles the dedicated U&R row in the info table.\n\nOFF by default to save space — the TRIGGER row already shows the U&R signal, score, and EMA tag.\n\nTurn ON if you want the full U&R breakdown visible at all times.')

ur_lookback = input.int(3,
     title='Undercut Lookback (bars)',
     group='🎯 U&R Signal',
     minval=1,
     maxval=10,
     tooltip='How many recent daily bars to scan backward looking for an undercut — a bar where the LOW dipped BELOW the 8 or 21 EMA.\n\nThe undercut does not need to happen on the current bar. As long as it occurred within this window AND the current close is back above the EMA, the reclaim is confirmed.\n\n──────────────────────\n⚙️ SETTINGS GUIDE\n──────────────────────\n1 = strictest — undercut and reclaim must both happen on the same daily candle (original behavior).\n\n3 (default) = standard — matches the classic U&R sequence: red candle breaks below EMA (Day 1–2), buyers absorb and reclaim (Day 3). Catches the full setup without getting too loose.\n\n5–7 = relaxed — useful for choppy markets where the undercut and reclaim are spread across more days. Increases signal frequency but lowers precision.\n\n10 = maximum lookahead — essentially "was price ever below this EMA recently and is it above now?" Very loose, not recommended for strict setups.\n\nRecommended: 2–4.')

ur_confirm_green = input.bool(true,
     title='Require Green Reclaim Candle',
     group='🎯 U&R Signal',
     tooltip='When ON, the reclaim candle (the bar where close > EMA after the undercut) must also close ABOVE its own open — i.e. be a green/bullish candle.\n\nThis directly confirms the sequence described in the U&R concept:\n  → Red candle: aggressive selling / stop execution\n  → Green reclaim: demand absorbs supply, buyers reassert control\n  → Rally follows\n\nON (recommended) = filters out weak, indecisive reclaims where price closed above the EMA but the candle itself was still red. Adds meaningful quality control.\n\nOFF = any candle color qualifies as a reclaim. Catches more setups but includes lower-conviction ones where sellers may still have control.\n\nRecommended: ON.')

ur_tap_pct = input.float(0.5,
     title='Tap Zone % Above EMA',
     group='🎯 U&R Signal',
     minval=0.1,
     maxval=3.0,
     tooltip='Defines how close the candle low must come to the EMA (from above) to qualify as a TAP — a near-miss undercut where price tested the EMA without crossing below it.\n\nFormula: low must be between EMA and EMA × (1 + tap%) \n\nExample at 0.5%: if 8 EMA = $100.00, the low must be between $100.00 and $100.50.\n\n──────────────────────\n⚙️ SETTINGS GUIDE\n──────────────────────\n0.1–0.3% = very tight — only fires when price almost touched the EMA exactly. Fewer signals, very precise.\n\n0.5% (default) = standard — covers most EMA tap setups without too many false hits.\n\n1.0–2.0% = loose — fires even when price came within 1–2% of the EMA without touching. More signals, lower precision.\n\nNote: Tap signals score lower than full Undercuts in the U&R scoring system. A full undercut (low crossed below EMA) is considered a stronger reversal signal.')

ur_rvol_min = input.float(120.0,
     title='Min RVol % for U&R Score Bonus',
     group='🎯 U&R Signal',
     minval=50.0,
     maxval=300.0,
     tooltip='Relative Volume threshold used to award a quality point in the U&R scoring system.\n\nThe U&R score (shown as ⚠️ / 🎯 / 🔥) is built from 4 components:\n  1. Close in upper 50%+ of candle range\n  2. RVol ≥ this threshold (volume absorption)\n  3. Lower wick present (rejection of lows)\n  4. Sector ETF green (broad market support)\n\nThe more components that pass, the higher the score:\n  ⚠️ = 1–2 points (weak, proceed with caution)\n  🎯 = 3 points (solid setup)\n  🔥 = 4 points + above PDH (highest conviction)\n\nThis setting only affects the SCORE — it does not gate whether the U&R signal fires. The signal fires based on lookback + reclaim + green candle rules above.\n\nDefault 120% = requires at least 1.2× average daily volume, confirming genuine institutional absorption at the EMA.\n\nRecommended: 100–150%.')

// ── Weekly 9 EMA U&R ─────────────────────────────────────────
show_9w_ur = input.bool(true,
     title='Include Weekly 9 EMA in U&R Detection',
     group='🎯 U&R Signal',
     tooltip='When ON, the Weekly 9 EMA is added as a third U&R level alongside the Daily 8 and 21 EMAs.\n\nThe Weekly 9 EMA is one of the most widely watched institutional levels. When a stock undercuts it and reclaims, the move tends to be more powerful and sustained than a daily EMA reclaim — because it represents a full week of price memory being defended.\n\nThe undercut detection uses WEEKLY bars (not daily). A lookback of 2 = scanned the last 2 completed weeks for a weekly low below the 9W EMA.\n\nWhen detected, the TRIGGER row shows:\n  U&R [9W EMA] — undercut and reclaim of weekly level\n  Tap [9W EMA] — weekly low approached but didn\'t break\n\nPriority: 9W signals are shown above daily signals in the trigger row because they represent a higher timeframe — and therefore higher conviction — setup.\n\nBest used with: lookback 1–3 weekly bars, green candle confirm ON.')

ur_lookback_9w = input.int(2,
     title='Weekly 9 EMA Lookback (weeks)',
     group='🎯 U&R Signal',
     minval=1,
     maxval=8,
     tooltip='How many recent WEEKLY bars to scan for an undercut of the Weekly 9 EMA.\n\nThis counts in weeks — not days. A lookback of 2 means "did the weekly low dip below the 9W EMA in either of the last 2 weeks?"\n\n──────────────────────\n⚙️ SETTINGS GUIDE\n──────────────────────\n1 = Current or most recent week only. Tightest. Only fires when the undercut and reclaim are on the same or adjacent weekly candle.\n\n2 (default) = Standard — covers a 2-week sequence. Breakdown week → absorption → reclaim. Matches the natural weekly U&R rhythm.\n\n3–4 = Relaxed — allows for multi-week base building before the reclaim. More signals but the original undercut may be less relevant.\n\n5+ = Very loose. Not recommended for clean U&R setups.\n\nRecommended: 1–3.')


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

// — Relaxed Quality (auto-applies when U&R tap / undercut fires) ——
ur_relax_enable  = input(true,
     title='U&R Tap: Enable Relaxed Quality',
     group='📊 Layered Trade Engine',
     tooltip='ON = when price taps or undercuts the 8/21 EMA, looser RS and RVol thresholds apply automatically.\n\nSector green is also waived in relaxed mode.')

ur_relax_rs   = input.float(70.0,
     title='U&R Tap: Relaxed Min RS Rating',
     group='📊 Layered Trade Engine',
     minval=1.0,
     maxval=99.0)

ur_relax_rvol = input.float(80.0,
     title='U&R Tap: Relaxed Min RVol %',
     group='📊 Layered Trade Engine',
     minval=10.0,
     maxval=300.0)

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
adrp_len = input.int(20, title='ADR% Length (bars)', group='⚙️ Parameters', minval=5, maxval=60,
     tooltip='Number of daily bars used to calculate the Average Daily Range %.\n\nADR% = average of (High/Low) over this period, expressed as a percentage.\n\nDefault 20 = one trading month.\n\nHigher = smoother but slower. Lower = more reactive to recent volatility.')

atr_len = input.int(14, title='ATR Length (bars)', group='⚙️ Parameters', minval=1, maxval=50,
     tooltip='Number of bars for the Average True Range calculation.\n\nATR measures average daily price movement in dollars.\n\nDefault 14 = standard across most trading systems.\n\nUsed for ATR$ and ATR% display rows, and LoD Distance calculation.')

len = input.int(50, title='Volume MA Length', group='⚙️ Parameters', minval=10, maxval=200,
     tooltip='Number of daily bars used to calculate the average volume baseline.\n\nUsed for Avg Volume display and Avg $ Volume display rows.\n\nDefault 50 = approximately one trading quarter.\n\nNote: this is separate from the RVol average length below.')

rvol_len = input.int(20, title='RVol Average Length (bars)', group='⚙️ Parameters', minval=1, maxval=200,
     tooltip='Number of past CLOSED daily bars used to build the volume average that RVol is compared against.\n\nFormula: RVol average = SMA of volume[1] over this length.\n\nvolume[1] means today\'s live bar is excluded from the average — so the baseline is never inflated by today\'s activity (Ripster style).\n\nDefault 20 = one trading month of closed sessions.\n\nLower = baseline reacts faster to recent volume shifts.\nHigher = more stable baseline, less sensitive to short-term bursts.')

// ── RVol Mode ────────────────────────────────────────────────
rvol_mode = input.string('Projected',
     title='RVol Mode',
     options=['Current Day', 'Projected'],
     group='⚙️ Parameters',
     tooltip='Controls what volume figure is used to calculate Relative Volume (RVol).\n\n──────────────────────\n📌 CURRENT DAY\n──────────────────────\nRVol = today\'s actual traded volume so far ÷ average daily volume.\n\n• Conservative — reads low early in the session (e.g. 8% at 9:40am even on a strong day).\n• Accurate at market close — no estimation involved.\n• Best for: end-of-day reviews, backtesting, or if you only take entries after 2pm.\n• Downside: you will miss valid early-session entries because RVol reads low while the day is still building.\n\n──────────────────────\n📌 PROJECTED (recommended)\n──────────────────────\nRVol = projected end-of-day volume ÷ average daily volume.\n\nProjection formula:\n  Projected Vol = Current Vol + (Current Vol ÷ Time Elapsed × Time Remaining)\n\n• Reflects the current intraday PACE — if a stock is trading at 3× its usual early-morning rate, RVol will reflect that immediately.\n• Prevents missed entries caused by low raw volume early in the session.\n• Best for: intraday swing entries, U&R taps, EMA pullbacks.\n• Downside: can overestimate in the first 15–30 min due to opening-bell volume spikes — use the Min Minutes Elapsed guard below to control this.\n\nAfter market close: both modes produce identical results since time remaining = 0.')

rvol_min_elapsed = input.int(30,
     title='RVol Projection: Min Minutes Elapsed (0 = OFF)',
     group='⚙️ Parameters',
     minval=0,
     maxval=120,
     tooltip='Only applies when RVol Mode = Projected.\n\nSets a minimum number of minutes that must pass from the session open before the projection formula activates.\n\nBefore this threshold: RVol falls back to Current Day mode (raw volume), avoiding inflated readings from opening-bell volume spikes.\nAfter this threshold: projection activates and RVol reflects the intraday pace.\n\n──────────────────────\n⚙️ SETTINGS GUIDE\n──────────────────────\n0 = Project from the very first bar (9:30am). Maximum sensitivity. Highest risk of overestimation from gap-up or news-driven opens.\n\n30 (default) = Wait 30 minutes. Covers the standard opening range. Projection starts at 10:00am EST. Best balance for most swing setups.\n\n60 = Wait a full hour. Safer for traders who only take entries after the opening range resolves. Morning momentum plays may still show low RVol at 9:45am.\n\n120 = Very conservative. RVol only projects after 11:30am. Essentially current-day for morning sessions.\n\nRecommended: 30–60 for active swing traders.')

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
sma50Da = request.security(s, 'D', ta.sma(close, 50))

// ── Weekly 9 EMA (for U&R detection) ────────────────────────
ema9W  = request.security(s, 'W', ta.ema(close, 9))
lowW   = request.security(s, 'W', low)
closeW = request.security(s, 'W', close)
openW  = request.security(s, 'W', open)

// ═══════════════════════════════════════════════════════════════
// 📈 RVOL — computed early so all sections can reference it
// ═══════════════════════════════════════════════════════════════
time_left_da   = request.security(s, 'D', (time_close - timenow) / 1000.0)
time_passed_da = request.security(s, 'D', (timenow - time) / 1000.0)

// Projected volume — only activates after min elapsed minutes
min_elapsed_sec = rvol_min_elapsed * 60.0
elapsed_ok      = rvol_min_elapsed == 0 or (time_passed_da >= min_elapsed_sec)
vol_proj_da_raw = volDa
if time_left_da > 0 and time_passed_da > 0 and elapsed_ok
    vol_proj_da_raw := volDa + (volDa / time_passed_da * time_left_da)

// RVol source — Current Day = raw volume, Projected = end-of-day pace estimate
rvol_source = rvol_mode == 'Projected' ? vol_proj_da_raw : volDa

relVol_da  = rvolAvgDa != 0 ? math.round((rvol_source / rvolAvgDa) * 100.0) : float(na)
volBuzz_da = rvolAvgDa != 0 ? 100.0 * (rvol_source / rvolAvgDa - 1.0)      : float(na)

// ═══════════════════════════════════════════════════════════════
// 🕯️ PATTERN DETECTION
// ═══════════════════════════════════════════════════════════════
// 🔒 Pattern detection locked to Daily TF — always uses last CLOSED daily candle
p_close     = request.security(s, 'D', close,                lookahead=barmerge.lookahead_off)
p_open      = request.security(s, 'D', open,                 lookahead=barmerge.lookahead_off)
p_high      = request.security(s, 'D', high,                 lookahead=barmerge.lookahead_off)
p_low       = request.security(s, 'D', low,                  lookahead=barmerge.lookahead_off)
p_confirmed = request.security(s, 'D', barstate.isconfirmed, lookahead=barmerge.lookahead_off)


// ── Shared candle measurements ────────────────────────────────
p_body      = math.abs(p_close - p_open)
p_lowerWick = math.min(p_open, p_close) - p_low
p_upperWick = p_high - math.max(p_open, p_close)
p_range     = p_high - p_low
p_isBullish = p_close > p_open

p_has_hist_1 = not na(p_open[1]) and not na(p_close[1]) and not na(p_low[1]) and not na(p_high[1])
p_has_hist_2 = p_has_hist_1 and not na(p_open[2]) and not na(p_close[2]) and not na(p_low[2]) and not na(p_high[2])

// ── 1. Bullish Engulfing ──────────────────────────────────────
// Bullish body fully wraps prior bearish body AND is ≥ 10% larger.
// Prior candle must have a meaningful body (≥ 35% of its range).
p_prev_body    = p_has_hist_1 ? math.abs(p_close[1] - p_open[1]) : float(na)
p_prev_range   = p_has_hist_1 ? (p_high[1] - p_low[1])           : float(na)
p_engulfing = show_engulfing and p_has_hist_1
     and p_isBullish
     and p_close[1] < p_open[1]                                        // prior candle bearish
     and p_open  <= math.min(p_open[1], p_close[1])                    // open at or below prior body bottom
     and p_close >= math.max(p_open[1], p_close[1])                    // close at or above prior body top
     and p_body  >= p_prev_body * 1.10                                  // body ≥ 10% larger than prior
     and p_prev_range > 0 and p_prev_body >= p_prev_range * 0.35       // prior had a real body (not a doji)
     and p_body >= p_range * 0.45                                       // current body fills ≥ 45% of its range

// ── 2. Dragonfly Doji ─────────────────────────────────────────
// Small body (≤ 5% of range), long lower wick (≥ 65% of range), tiny upper wick (≤ 5%).
p_doji = show_doji
     and p_range > 0
     and p_body      <= p_range * 0.05   // body ≤ 5% of range
     and p_lowerWick >= p_range * 0.65   // lower wick ≥ 65% of range
     and p_upperWick <= p_range * 0.05   // upper wick ≤ 5% of range

// ── 3. Morning Star ───────────────────────────────────────────
// C1 bearish with real body (≥ 35% of range). C2 small body (≤ 25% of C1 body).
// C3 bullish closing above 55% of C1 body with real body.
p_ms_c1_body  = p_has_hist_2 ? math.abs(p_close[2] - p_open[2])   : float(na)
p_ms_c1_range = p_has_hist_2 ? (p_high[2] - p_low[2])             : float(na)
p_ms_c1_top   = p_has_hist_2 ? math.min(p_open[2], p_close[2])    : float(na)
p_ms_c1_mid   = p_has_hist_2 ? p_ms_c1_top + p_ms_c1_body * 0.55 : float(na)
p_morningstar = show_morningstar and p_has_hist_2
     and p_close[2] < p_open[2]                                        // C1 bearish
     and p_ms_c1_range > 0 and p_ms_c1_body >= p_ms_c1_range * 0.35  // C1 has real body
     and math.abs(p_close[1] - p_open[1]) <= p_ms_c1_body * 0.25     // C2 small body ≤ 25% of C1
     and p_isBullish                                                    // C3 bullish
     and p_close >= p_ms_c1_mid                                        // C3 closes above 55% of C1 body
     and p_body >= p_range * 0.45                                       // C3 has a real body

// ── 4. Piercing Line ──────────────────────────────────────────
// Prior bearish with real body. Opens below prior low (gap down).
// Closes bullish above 50% into prior body but below prior open.
p_pl_c1_body  = p_has_hist_1 ? math.abs(p_close[1] - p_open[1]) : float(na)
p_pl_c1_range = p_has_hist_1 ? (p_high[1] - p_low[1])            : float(na)
p_pl_c1_bot   = p_has_hist_1 ? math.min(p_open[1], p_close[1])   : float(na)
p_pl_c1_mid   = p_has_hist_1 ? p_pl_c1_bot + p_pl_c1_body * 0.50 : float(na)
p_piercing = show_piercing and p_has_hist_1
     and p_close[1] < p_open[1]                                        // prior bearish
     and p_pl_c1_range > 0 and p_pl_c1_body >= p_pl_c1_range * 0.35  // prior has real body
     and p_open < p_low[1]                                             // gaps below prior low
     and p_isBullish                                                    // current bullish
     and p_close >= p_pl_c1_mid                                        // closes above 50% of prior body
     and p_close < p_open[1]                                           // doesn't fully close above prior open
     and p_body >= p_range * 0.45                                       // real bullish body

// ── 5. Hammer ─────────────────────────────────────────────────
// Small body (≤ 28% of range) in the upper portion.
// Lower wick ≥ 2× body. Upper wick ≤ 8% of range.
// Prior candle must be bearish — confirms reversal context.
p_hammer = show_hammer and p_has_hist_1
     and p_range > 0
     and p_body      <= p_range * 0.28                                 // body ≤ 28% of range
     and p_lowerWick >= p_body  * 2.0                                  // lower wick ≥ 2× body
     and p_upperWick <= p_range * 0.08                                 // upper wick ≤ 8% of range
     and math.min(p_open, p_close) >= p_low + p_range * 0.55          // body sits in upper 45% of range
     and p_close[1] < p_open[1]                                        // prior candle bearish (context)

// ── 6. Bullish Harami ─────────────────────────────────────────
// Prior bearish candle with real body (≥ 35% of range).
// Current candle bullish, body completely inside prior body,
// and current body ≤ 60% of prior body.
p_har_prev_body  = p_has_hist_1 ? math.abs(p_close[1] - p_open[1]) : float(na)
p_har_prev_range = p_has_hist_1 ? (p_high[1] - p_low[1])            : float(na)
p_harami = show_harami and p_has_hist_1
     and p_close[1] < p_open[1]                                        // prior bearish
     and p_har_prev_range > 0 and p_har_prev_body >= p_har_prev_range * 0.35  // prior has real body
     and p_isBullish                                                    // current bullish
     and p_open  > math.min(p_open[1], p_close[1])                    // current open inside prior body
     and p_close < math.max(p_open[1], p_close[1])                    // current close inside prior body
     and p_body  <= p_har_prev_body * 0.60                             // current body ≤ 60% of prior

// ── 7. Three White Soldiers ───────────────────────────────────
// Three consecutive bullish candles each with body ≥ 55% of range,
// each opening inside prior body, each closing higher, upper wicks ≤ 20% of range.
p_sol_r0    = p_high    - p_low
p_sol_r1    = p_high[1] - p_low[1]
p_sol_r2    = p_high[2] - p_low[2]
p_sol_ok0   = p_sol_r0 > 0 and math.abs(p_close    - p_open)    >= p_sol_r0 * 0.55 and (p_high    - p_close)    <= p_sol_r0 * 0.20
p_sol_ok1   = p_sol_r1 > 0 and math.abs(p_close[1] - p_open[1]) >= p_sol_r1 * 0.55 and (p_high[1] - p_close[1]) <= p_sol_r1 * 0.20
p_sol_ok2   = p_sol_r2 > 0 and math.abs(p_close[2] - p_open[2]) >= p_sol_r2 * 0.55 and (p_high[2] - p_close[2]) <= p_sol_r2 * 0.20

p_three_soldiers = show_three_soldiers and p_has_hist_2
     and p_close[2] > p_open[2]
     and p_close[1] > p_open[1]
     and p_isBullish
     and p_close[1] > p_close[2]
     and p_close    > p_close[1]
     and p_open[1]  > p_open[2] and p_open[1] < p_close[2]
     and p_open     > p_open[1] and p_open    < p_close[1]
     and p_sol_ok0 and p_sol_ok1 and p_sol_ok2

// ── Pattern count & any-flag ──────────────────────────────────
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

// Gate: stamp icon only once per selected display TF period, only during regular market hours
// session.ismarket = true only during RTH (9:30am–4:00pm ET) — blocks pre/post market icons
pattern_new_period = pattern_display_tf == 'All Bars' ? true : ta.change(time(pattern_display_tf)) != 0
in_market_hours    = session.ismarket

plot_confirmed  = show_confirmed and p_any and p_confirmed and pattern_new_period and in_market_hours
show_symbol    = plot_confirmed and (pattern_display_mode == 'Symbol'       or pattern_display_mode == 'Both')
show_bar_color = p_any and p_confirmed and (pattern_display_mode == 'Candle Color' or pattern_display_mode == 'Both')

// Symbol — respects TF gate and market hours
plotshape(show_symbol and symbol_size == 'Tiny',   title='✓ Pattern Confirmed Tiny',   style=shape.labelup, location=location.abovebar, color=conf_col, text='✓', textcolor=color.white, size=size.tiny)
plotshape(show_symbol and symbol_size == 'Small',  title='✓ Pattern Confirmed Small',  style=shape.labelup, location=location.abovebar, color=conf_col, text='✓', textcolor=color.white, size=size.small)
plotshape(show_symbol and symbol_size == 'Normal', title='✓ Pattern Confirmed Normal', style=shape.labelup, location=location.abovebar, color=conf_col, text='✓', textcolor=color.white, size=size.normal)
plotshape(show_symbol and symbol_size == 'Large',  title='✓ Pattern Confirmed Large',  style=shape.labelup, location=location.abovebar, color=conf_col, text='✓', textcolor=color.white, size=size.large)

// Candle color — recolors the bar with the pattern's color
barcolor(show_bar_color ? conf_col : na, title='Pattern Candle Color')

// ═══════════════════════════════════════════════════════════════
// 🎯 U&R
// ═══════════════════════════════════════════════════════════════

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

// ── Daily EMA multi-bar lookback undercut detection ─────────
// Scan back ur_lookback daily bars — did the low cross below the EMA at any point?
ur_had_uc_8  = false
ur_had_uc_21 = false
for i = 0 to ur_lookback - 1
    if lowDa[i] < ema8Da[i]
        ur_had_uc_8  := true
    if lowDa[i] < ema21Da[i]
        ur_had_uc_21 := true

// Reclaim: close now above EMA — optional green candle confirms buyers stepped in
ur_green_ok    = not ur_confirm_green or closeDa > openDa
ema8_undercut  = ur_had_uc_8  and closeDa > ema8Da  and ur_green_ok
ema21_undercut = ur_had_uc_21 and closeDa > ema21Da and ur_green_ok

// Tap: low approached but never crossed below EMA — softer signal
ema8_tap  = not ur_had_uc_8  and lowDa > ema8Da  and lowDa <= ema8Da  * (1.0 + ur_tap_pct / 100.0) and closeDa > ema8Da
ema21_tap = not ur_had_uc_21 and lowDa > ema21Da and lowDa <= ema21Da * (1.0 + ur_tap_pct / 100.0) and closeDa > ema21Da

// ── Weekly 9 EMA multi-bar lookback undercut detection ───────
// Scan back ur_lookback_9w WEEKLY bars — higher timeframe, higher conviction
ur_had_uc_9w = false
for i = 0 to ur_lookback_9w - 1
    if lowW[i] < ema9W[i]
        ur_had_uc_9w := true

ur_9w_green_ok  = not ur_confirm_green or closeW > openW
ema9w_undercut  = show_9w_ur and ur_had_uc_9w and closeW > ema9W and ur_9w_green_ok
ema9w_tap       = show_9w_ur and not ur_had_uc_9w and lowW > ema9W and lowW <= ema9W * (1.0 + ur_tap_pct / 100.0) and closeW > ema9W

// ── Combine all signals ───────────────────────────────────────
// 9W signals take display priority — higher TF = higher conviction
any_undercut = ema8_undercut or ema21_undercut or ema9w_undercut
any_tap      = (ema8_tap or ema21_tap or ema9w_tap) and not any_undercut
any_signal   = any_undercut or any_tap

ema_which = ''
ema_which_short = ''
if any_signal
    if ema9w_undercut or ema9w_tap
        // 9W takes priority in display
        ema_which       := '[9W EMA]'
        ema_which_short := '[9W]'
        if ema8_undercut or ema21_undercut or ema8_tap or ema21_tap
            ema_which       := '[9W+D]'
            ema_which_short := '[9W+D]'
    else if (ema8_undercut and ema21_undercut) or (ema8_tap and ema21_tap)
        ema_which       := '[8+21]'
        ema_which_short := '[8+21]'
    else if ema8_undercut or ema8_tap
        ema_which       := '[8 EMA]'
        ema_which_short := '[8]'
    else
        ema_which       := '[21 EMA]'
        ema_which_short := '[21]'

type_label       = any_undercut ? 'Undercut' : 'Tap'
type_label_short = any_undercut ? 'U&R'      : 'Tap'
pdh_label        = abovePDH ? ' ↑PDH' : ' ↓PDH'
pdh_label_short  = abovePDH ? ' ↑PDH' : ''

ur_pts = 0
if any_signal
    // 9W undercut awards a bonus point — higher TF confirmation is worth more
    ur_pts := (nz(closePct) >= 50.0 ? 1 : 0) + (nz(relVol_da) >= ur_rvol_min ? 1 : 0) + (hasWick ? 1 : 0) + (sectorGreen ? 1 : 0) + (ema9w_undercut ? 1 : 0)

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
    ur_displayStr     := ur_icon + type_label + ' ' + ema_which + pdh_label
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

// Relaxed quality — active only when U&R tap/undercut fires and the toggle is on
chk_relax_rs     = nz(totalRsRating, 0.0) >= ur_relax_rs
chk_relax_rvol   = nz(relVol_da, 0.0)     >= ur_relax_rvol
quality_ok_relaxed = ur_relax_enable and any_signal and chk_relax_rs and chk_relax_rvol and chk_quality_avgvol and chk_quality_advdol
quality_ok_effective = quality_ok or quality_ok_relaxed
tap_relaxed_active   = quality_ok_effective and not quality_ok and quality_ok_relaxed

quality_str = ''
quality_str_compact = ''
quality_col = col_negative
if quality_ok
    quality_str := '✅ Pass ' + str.tostring(quality_pass) + '/' + str.tostring(quality_total)
    quality_str_compact := '✅ ' + str.tostring(quality_pass) + '/' + str.tostring(quality_total)
    quality_col := col_positive
else if tap_relaxed_active
    quality_str := '⚡ Tap Mode ' + str.tostring(quality_pass) + '/' + str.tostring(quality_total)
    quality_str_compact := '⚡ Tap ' + str.tostring(quality_pass) + '/' + str.tostring(quality_total)
    quality_col := col_neutral
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
else if trend_ok and quality_ok_effective
    trigger_str := '… Waiting'
    trigger_str_compact := '… Wait'
    trigger_col := col_neutral
else
    trigger_str := '— None'
    trigger_str_compact := '—'
    trigger_col := col_negative

f_pattern_name(_count, _engulf, _doji, _ms, _pierce, _hammer, _harami, _soldiers) =>
    string _name = 'None'
    if _count >= 2
        _name := 'Multiple (' + str.tostring(_count) + ')'
    else if _engulf
        _name := 'Engulfing'
    else if _soldiers
        _name := '3 White Soldiers'
    else if _ms
        _name := 'Morning Star'
    else if _pierce
        _name := 'Piercing'
    else if _harami
        _name := 'Bullish Harami'
    else if _hammer
        _name := 'Hammer'
    else if _doji
        _name := 'Dragonfly Doji'
    _name

f_pattern_name_short(_count, _engulf, _doji, _ms, _pierce, _hammer, _harami, _soldiers) =>
    string _name = 'None'
    if _count >= 2
        _name := 'Multi(' + str.tostring(_count) + ')'
    else if _engulf
        _name := 'Engulf'
    else if _soldiers
        _name := '3W Soldiers'
    else if _ms
        _name := 'MStar'
    else if _pierce
        _name := 'Pierce'
    else if _harami
        _name := 'Harami'
    else if _hammer
        _name := 'Hammer'
    else if _doji
        _name := 'Doji'
    _name

pattern_name       = f_pattern_name(p_count, p_engulfing, p_doji, p_morningstar, p_piercing, p_hammer, p_harami, p_three_soldiers)
pattern_name_short = f_pattern_name_short(p_count, p_engulfing, p_doji, p_morningstar, p_piercing, p_hammer, p_harami, p_three_soldiers)
pattern_bonus_ok = p_any and p_confirmed

pattern_str = ''
pattern_str_compact = ''
pattern_row_col = col_negative
if pattern_bonus_ok
    pattern_str := '✓ ' + pattern_name
    pattern_str_compact := '✓ ' + pattern_name_short
    pattern_row_col := conf_col
else
    pattern_str := '— None'
    pattern_str_compact := '—'
    pattern_row_col := col_negative

base_ready      = trend_ok and quality_ok_effective and trigger_ok
watch_ok        = trend_ok and quality_ok_effective and not trigger_ok
trade_not_ready = not trend_ok or not quality_ok_effective

trade_str = ''
trade_col = col_negative
if trade_not_ready
    trade_str := '❌ Not Ready'
    trade_col := col_negative
else if watch_ok
    trade_str := '👀 Watch'
    trade_col := col_neutral
else if base_ready
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

lod_dist_da  = atrDa != 0 ? 100.0 * (closeDa - lowDa) / atrDa : float(na)
lod_price_da = lowDa

// Scaled version for display only
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
alertcondition(base_ready, title='✅ Layered Ready', message='{{ticker}} layered swing setup is READY.')

alertcondition(any_signal and ur_pts >= 4 and abovePDH, title='🔥 U&R Elite + ↑PDH', message='{{ticker}} Elite U&R above PDH!')
alertcondition(any_signal and ur_pts >= 3,              title='🎯 U&R Confirmed',   message='{{ticker}} Confirmed U&R!')
alertcondition(any_undercut,                            title='🎯 U&R Undercut',        message='{{ticker}} Undercut & Rally!')
alertcondition(ema9w_undercut,                          title='🎯 U&R Weekly 9 EMA',     message='{{ticker}} Weekly 9 EMA Undercut & Rally — high conviction!')
alertcondition(any_tap,                                 title='👆 U&R Tap',              message='{{ticker}} Tap & Rally!')

alertcondition(p_engulfing      and p_confirmed, title='✓ Bullish Engulfing',     message='{{ticker}} Bullish Engulfing confirmed!')
alertcondition(p_doji           and p_confirmed, title='✓ Dragonfly Doji',         message='{{ticker}} Dragonfly Doji confirmed!')
alertcondition(p_morningstar    and p_confirmed, title='✓ Morning Star',            message='{{ticker}} Morning Star confirmed!')
alertcondition(p_piercing       and p_confirmed, title='✓ Piercing Line',           message='{{ticker}} Piercing Line confirmed!')
alertcondition(p_hammer         and p_confirmed, title='✓ Hammer',                  message='{{ticker}} Hammer confirmed!')
alertcondition(p_harami         and p_confirmed, title='✓ Bullish Harami',          message='{{ticker}} Bullish Harami confirmed!')
alertcondition(p_three_soldiers and p_confirmed, title='✓ Three White Soldiers',    message='{{ticker}} Three White Soldiers confirmed!')
alertcondition(p_count >= 2 and p_confirmed, title='✓ Multiple Patterns', message='{{ticker}} Multiple patterns confirmed!')

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

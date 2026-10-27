# Dskyz (DAFE) Aurora Divergence – Quant Master

- url: https://www.tradingview.com/script/E7Xk6XUm-Dskyz-DAFE-Aurora-Divergence-Quant-Master/
- type: strategy
- pine_id: PUB;a901e9cbef074e68b91ffc240c9fb634
- version: 1.0

## Description

[b]Dskyz (DAFE) Aurora Divergence – Quant Master[/b]

Introducing the [b]Dskyz (DAFE) Aurora Divergence – Quant Master[/b], a strategy that’s your secret weapon for mastering futures markets like MNQ, NQ, MES, and ES. Born from the legendary Aurora Divergence indicator, this fully automated system transforms raw divergence signals into a quant-grade trading machine, blending precision, risk management, and cyberpunk DAFE visuals that make your charts glow like a neon skyline. Crafted with care and driven by community passion, this strategy stands out in a sea of generic scripts, offering traders a unique edge to outsmart institutional traps and navigate volatile markets.

The Aurora Divergence indicator was a cult favorite for spotting price-OBV divergences with its aqua and fuchsia orbs, but traders craved a system to act on those signals with discipline and automation. This strategy delivers, layering advanced filters (z-score, ATR, multi-timeframe, session), dynamic risk controls (kill switches, adaptive stops/TPs), and a real-time dashboard to turn insights into profits. Whether you’re a newbie dipping into futures or a pro hunting reversals, this strat’s got your back with a beginner guide, alerts, and visuals that make trading feel like a sci-fi mission. Let’s dive into every detail and see why this original DAFE creation is a must-have.

[b]Why Traders Need This Strategy[/b]

Futures markets are a battlefield—fast-paced, volatile, and riddled with institutional games that can wipe out undisciplined traders. From the April 28, 2025 NQ 1k-point drop to sneaky ES slippage, the stakes are high. Meanwhile, platforms are flooded with unoriginal, low-effort scripts that promise the moon but deliver noise. The Aurora Divergence – Quant Master rises above, offering:

[b]Unmatched Originality:[/b] A bespoke system built from the ground up, with custom divergence logic, DAFE visuals, and quant filters that set it apart from copycat clutter.
[b]Automation with Precision:[/b] Executes trades on divergence signals, eliminating emotional slip-ups and ensuring consistency, even in chaotic sessions.
[b]Quant-Grade Filters:[/b] Z-score, ATR, multi-timeframe, and session checks filter out noise, targeting high-probability reversals.
[b]Robust Risk Management:[/b] Daily loss and rolling drawdown kill switches, plus ATR-based stops/TPs, protect your capital like a fortress.
[b]Stunning DAFE Visuals:[/b] Aqua/fuchsia orbs, aurora bands, and a glowing dashboard make signals intuitive and charts a work of art.
[b]Community-Driven:[/b] Evolved from trader feedback, this strat’s a labor of love, not a recycled knockoff.

Traders need this because it’s a complete, original system that blends accessibility, sophistication, and style. It’s your edge to trade smarter, not harder, in a market full of traps and imitators.

[b]1. Divergence Detection (Core Signal Logic)[/b]

The strategy’s core is its ability to detect bullish and bearish divergences between price and On-Balance Volume (OBV), pinpointing reversals with surgical accuracy.

[b]How It Works:[/b]

[b]Price Slope:[/b] Uses linear regression over a lookback (default: 9 bars) to measure price momentum (priceSlope).
[b]OBV Slope:[/b] OBV tracks volume flow (+volume if price rises, -volume if falls), with its slope calculated similarly (obvSlope).
[b]Bullish Divergence:[/b] Price slope negative (falling), OBV slope positive (rising), and price above 50-bar SMA (trend_ma).
[b]Bearish Divergence:[/b] Price slope positive (rising), OBV slope negative (falling), and price below 50-bar SMA.
[b]Smoothing:[/b] Requires two consecutive divergence bars (bullDiv2, bearDiv2) to confirm signals, reducing false positives.
[b]Strength:[/b] Divergence intensity (divStrength = |priceSlope * obvSlope| * sensitivity) is normalized (0–1, divStrengthNorm) for visuals.

[b]Why It’s Brilliant:[/b]

- Divergences catch hidden momentum shifts, often exploited by institutions, giving you an edge on reversals.
- The 50-bar SMA filter aligns signals with the broader trend, avoiding choppy markets.
- Adjustable lookback (min: 3) and sensitivity (default: 1.0) let you tune for different instruments or timeframes.

[b]2. Filters for Precision[/b]

Four advanced filters ensure signals are high-probability and market-aligned, cutting through the noise of volatile futures.

[b]Z-Score Filter:[/b]

[b]Logic:[/b] Calculates z-score ((close - SMA) / stdev) over a lookback (default: 50 bars). Blocks entries if |z-score| > threshold (default: 1.5) unless disabled (useZFilter = false).
[b]Impact:[/b] Avoids trades during extreme price moves (e.g., blow-off tops), keeping you in statistically safe zones.

[b]ATR Percentile Volatility Filter:[/b]

[b]Logic:[/b] Tracks 14-bar ATR in a 100-bar window (default). Requires current ATR > 80th percentile (percATR) to trade (tradeOk).
[b]Impact: [/b]Ensures sufficient volatility for meaningful moves, filtering out low-volume chop.

[b]Multi-Timeframe (HTF) Trend Filter:[/b]

[b]Logic:[/b] Uses a 50-bar SMA on a higher timeframe (default: 60min). Longs require price > HTF MA (bullTrendOK), shorts < HTF MA (bearTrendOK).
[b]Impact:[/b] Aligns trades with the bigger trend, reducing counter-trend losses.

[b]US Session Filter:[/b]

[b]Logic: [/b]Restricts trading to 9:30am–4:00pm ET (default: enabled, useSession = true) using America/New_York timezone.
[b]Impact: [/b]Focuses on high-liquidity hours, avoiding overnight spreads and erratic moves.

[b]Evolution:[/b]

- These filters create a robust signal pipeline, ensuring trades are timed for optimal conditions.
- Customizable inputs (e.g., zThreshold, atrPercentile) let traders adapt to their style without compromising quality.

[b]3. Risk Management[/b]

The strategy’s risk controls are a masterclass in balancing aggression and safety, protecting capital in volatile markets.

[b]Daily Loss Kill Switch:[/b]

[b]Logic:[/b] Tracks daily loss (dayStartEquity - strategy.equity). Halts trading if loss ≥ $300 (default) and enabled (killSwitch = true, killSwitchActive).
Impact: Caps daily downside, crucial during events like April 27, 2025 ES slippage.

[b]Rolling Drawdown Kill Switch:[/b]

[b]Logic:[/b] Monitors drawdown (rollingPeak - strategy.equity) over 100 bars (default). Stops trading if > $1000 (rollingKill).
[b]Impact:[/b] Prevents prolonged losing streaks, preserving capital for better setups.

[b]Dynamic Stop-Loss and Take-Profit:[/b]

[b]Logic:[/b] Stops = entry ± ATR * multiplier (default: 1.0x, stopDist). TPs = entry ± ATR * 1.5x (profitDist). Longs: stop below, TP above; shorts: vice versa.
[b]Impact:[/b] Adapts to volatility, keeping stops tight but realistic, with TPs targeting 1.5:1 reward/risk.

[b]Max Bars in Trade:[/b]

[b]Logic:[/b] Closes trades after 8 bars (default) if not already exited.
[b]Impact:[/b] Frees capital from stagnant trades, maintaining efficiency.

[b]Kill Switch Buffer Dashboard:[/b]

[b]Logic:[/b] Shows smallest buffer ($300 - daily loss or $1000 - rolling DD). Displays 0 (red) if kill switch active, else buffer (green).
[b]Impact:[/b] Real-time risk visibility, letting traders adjust dynamically.

[b]Why It’s Brilliant:[/b]

- Kill switches and ATR-based exits create a safety net, rare in generic scripts.
- Customizable risk inputs (maxDailyLoss, dynamicStopMult) suit different account sizes.
- Buffer metric empowers disciplined trading, a DAFE signature.

[b]4. Trade Entry and Exit Logic[/b]

The entry/exit rules are precise, filtered, and adaptive, ensuring trades are deliberate and profitable.

[b]Entry Conditions:[/b]
[b]Long Entry:[/b] bullDiv2, cooldown passed (canSignal), ATR filter passed (tradeOk), in US session (inSession), no kill switches (not killSwitchActive, not rollingKill), z-score OK (zOk), HTF trend bullish (bullTrendOK), no existing long (lastDirection != 1, position_size <= 0). Closes shorts first.
[b]Short Entry:[/b] Same, but for bearDiv2, bearTrendOK, no long (lastDirection != -1, position_size >= 0). Closes longs first.
[b]Adaptive Cooldown:[/b] Default 2 bars (cooldownBars). Doubles (up to 10) after a losing trade, resets after wins (dynamicCooldown).

[b]Exit Conditions:[/b]

[b]Stop-Loss/Take-Profit:[/b] Set per trade (ATR-based). Exits on stop/TP hits.
[b]Other Exits:[/b] Closes if maxBarsInTrade reached, ATR filter fails, or kill switch activates.
[b]Position Management:[/b] Ensures no conflicting positions, closing opposites before new entries.

[b]Built To Be Reliable and Consistent:[/b]

- Multi-filtered entries minimize false signals, a stark contrast to basic scripts.
- Adaptive cooldown prevents overtrading, especially after losses.
- Clean position handling ensures smooth execution, even in fast markets.

[b]5. DAFE Visuals[/b]

The visuals are a DAFE hallmark, blending function with clean flair to make signals intuitive and charts stunning.

[b]Aurora Bands:[/b]

[b]Display:[/b] Bands around price during divergences (bullish: below low, bearish: above high), sized by ATR * bandwidth (default: 0.5).
[b]Colors:[/b] Aqua (bullish), fuchsia (bearish), with transparency tied to divStrengthNorm.
[b]Purpose:[/b] Highlights divergence zones with a glowing, futuristic vibe.

[b]Divergence Orbs:[/b]

[b]Display:[/b] Large/small circles (aqua below for bullish, fuchsia above for bearish) when bullDiv2/bearDiv2 and canSignal. Labels show strength (0–1).
[b]Purpose:[/b] Pinpoints entries with eye-catching clarity.

[b]Gradient Background:[/b]

[b]Display:[/b] Green (bullish), red (bearish), or gray (neutral), 90–95% transparent.
[b]Purpose:[/b] Sets the market mood without clutter.

[b]Strategy Plots:[/b]

- Stop/TP Lines: Red (stops), green (TPs) for active trades.
- HTF MA: Yellow line for trend context.
- Z-Score: Blue step-line (if enabled).
- Kill Switch Warning: Red background flash when active.

[b]What Makes This Next-Level?:[/b]

- Visuals make complex signals (divergences, filters) instantly clear, even for beginners.
- DAFE’s unique aesthetic (orbs, bands) sets it apart from generic scripts, reinforcing originality.
- Functional plots (stops, TPs) enhance trade management.

[b]6. Metrics Dashboard[/b]

The top-right dashboard (2x8 table) is your command center, delivering real-time insights.

[b]Metrics:[/b]

[b]Daily Loss ($):[/b] Current loss vs. day’s start, red if > $300.
[b]Rolling DD ($):[/b] Drawdown vs. 100-bar peak, red if > $1000.
[b]ATR Threshold:[/b] Current percATR, green if ATR exceeds, red if not.
[b]Z-Score:[/b] Current value, green if within threshold, red if not.
[b]Signal:[/b] “Bullish Div” (aqua), “Bearish Div” (fuchsia), or “None” (gray).
[b]Action:[/b] “Consider Buying”/“Consider Selling” (signal color) or “Wait” (gray).
[b]Kill Switch Buffer ($):[/b] Smallest buffer to kill switch, green if > 0, red if 0.

Why This Is Important?:

- Consolidates critical data, making decisions effortless.
- Color-coded metrics guide beginners (e.g., green action = go).
- Buffer metric adds transparency, rare in off-the-shelf scripts.

[b]7. Beginner Guide[/b]

[b]Beginner Guide:[/b] Middle-right table (shown once on chart load), explains aqua orbs (bullish, buy) and fuchsia orbs (bearish, sell).

[b]Key Features:[/b]

[b]Futures-Optimized:[/b] Tailored for MNQ, NQ, MES, ES with point-value adjustments.
[b]Highly Customizable:[/b] Inputs for lookback, sensitivity, filters, and risk settings.
[b]Real-Time Insights: [/b]Dashboard and visuals update every bar.
[b]Backtest-Ready:[/b] Fixed qty and tick calc for accurate historical testing.
[b]User-Friendly:[/b] Guide, visuals, and dashboard make it accessible yet powerful.
[b]Original Design: [/b]DAFE’s unique logic and visuals stand out from generic scripts.

[b]How to Use[/b]

[b]Add to Chart:[/b] Load on a 5min MNQ/ES chart in TradingView.
[b]Configure Inputs:[/b] Adjust instrument, filters, or risk (defaults optimized for MNQ).
[b]Monitor Dashboard: [/b]Watch signals, actions, and risk metrics (top-right).
[b]Backtest:[/b] Run in strategy tester to evaluate performance.
[b]Live Trade:[/b] Connect to a broker (e.g., Tradovate) for automation. Watch for slippage (e.g., April 27, 2025 ES issues).
[b]Replay Test: [/b]Use bar replay (e.g., April 28, 2025 NQ drop) to test volatility handling.

[b]Disclaimer[/b]

Trading futures involves significant risk of loss and is not suitable for all investors. Past performance is not indicative of future results. Backtest results may not reflect live trading due to slippage, fees, or market conditions. Use this strategy at your own risk, and consult a financial advisor before trading. Dskyz (DAFE) Trading Systems is not responsible for any losses incurred.

Backtesting:
Frame: 2023-09-20 - 2025-04-29

Fee	Typical Range (per side, per contract)
CME Exchange	$1.14 – $1.20
Clearing	$0.10 – $0.30
NFA Regulatory	$0.02
Firm/Broker Commis.	$0.25 – $0.80 (retail prop)
TOTAL	$1.60 – $2.30 per side
Round Turn: (enter+exit) = $3.20 – $4.60 per contract


[b]Final Notes[/b]

[b]The Dskyz (DAFE) Aurora Divergence – Quant Master[/b] isn’t just a strategy—it’s a movement. Crafted with originality and driven by community passion, it rises above the flood of generic scripts to deliver a system that’s as powerful as it is beautiful. With its quant-grade logic, DAFE visuals, and robust risk controls, it empowers traders to tackle futures with confidence and style. Join the DAFE crew, light up your charts, and let’s outsmart the markets together!

(This publishing will most likely be taken down do to some miscellaneous rule about properly displaying charting symbols, or whatever. Once I've identified what part of the publishing they want to pick on, I'll adjust and repost.)

Use it with discipline. Use it with clarity. Trade smarter.

**I will continue to release incredible strategies and indicators until I turn this into a brand or until someone offers me a contract.

Created by Dskyz, powered by DAFE Trading Systems. Trade fast, trade bold.

## Source Code

````pine
//@version=6
strategy('Dskyz (DAFE) Aurora Divergence – Quant Master', overlay = true, default_qty_type = strategy.fixed, default_qty_value = 1, calc_on_every_tick = true, max_bars_back = 2000)

// === USER INPUTS ===
instrument = input.string('MNQ', 'Instrument', options = ['MNQ', 'NQ', 'MES', 'ES'], group = 'Futures Contract')
cooldownBars = input.int(2, 'Base Signal Cooldown (Bars)', minval = 1, group = 'Signal')
lookback = input.int(9, 'Divergence Lookback', minval = 3, group = 'Signal')
zLength = input.int(50, 'Z-Score Lookback', minval = 5, group = 'Z-Score Filter')
zThreshold = input.float(1.5, 'Max |Z-Score| to Enter', minval = 0.1, step = 0.1, group = 'Z-Score Filter')
useZFilter = input.bool(true, 'Enable Z-Score Filter', group = 'Z-Score Filter')
htf_tf = input.timeframe('60', 'HTF Trend TF', group = 'Multi-Timeframe Filter')
htf_len = input.int(50, 'HTF MA Length', group = 'Multi-Timeframe Filter')
atrLen = input.int(100, 'ATR Percentile Window', group = 'Volatility Filter')
atrPercentile = input.float(80, 'ATR Percentile Threshold', minval = 50, maxval = 99, group = 'Volatility Filter')
dynamicStopMult = input.float(1.0, 'Stop ATR Multiplier', group = 'Risk/Reward')
dynamicProfitMult = input.float(1.5, 'Profit ATR Multiplier', group = 'Risk/Reward')
maxBarsInTrade = input.int(8, 'Max Bars in Trade', minval = 1, group = 'Risk/Reward')
killSwitch = input.bool(true, 'Enable Max Daily Loss Kill Switch', group = 'Risk/Reward')
maxDailyLoss = input.float(300, 'Max Daily Loss ($)', minval = 10, group = 'Risk/Reward')
maxRollingDD = input.float(1000, 'Max Rolling Drawdown ($)', group = 'Risk/Reward')
rollingLen = input.int(100, 'Rolling Window (Bars)', group = 'Risk/Reward')
useSession = input.bool(true, 'Restrict to US Session Only', group = 'Session Filter')
bandWidth = input.float(0.5, 'Aurora Band Width (% of ATR)', step = 0.1, minval = 0.1, group = 'DAFE Visuals')
sensitivity = input.float(1.0, 'Divergence Sensitivity', step = 0.1, minval = 0.5, group = 'DAFE Visuals')
minStrength = input.float(0.3, 'Minimum Strength', step = 0.1, minval = 0.0, maxval = 1.0, group = 'DAFE Visuals')

// === CONTRACT POINT VALUES ===
pointValue = switch instrument
    'MNQ' => 2.0
    'NQ' => 20.0
    'MES' => 5.0
    'ES' => 50.0
    => 1.0

// Helper: Calculate Day of Year from date parts
f_dayofyear(_year, _month, _day) =>
    daysToMonth = array.from(0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334)
    doy = array.get(daysToMonth, _month - 1) + _day
    leap = _month > 2 and _year % 4 == 0 and (_year % 100 != 0 or _year % 400 == 0) ? 1 : 0
    doy + leap

currentYear = year(time('D'))
currentMonth = month(time('D'))
currentDay = dayofmonth(time('D'))
currentDayOfYear = f_dayofyear(currentYear, currentMonth, currentDay)

// === STRATEGY RISK/REWARD SETTINGS ===
atr = ta.atr(14)
stopDist = dynamicStopMult * atr
profitDist = dynamicProfitMult * atr

// === SESSION FILTER ===
sess = '0930-1600'
tz = 'America/New_York'
inSession = useSession ? na(time(timeframe.period, sess, tz)) == false : true

// === DAILY KILL SWITCH ===
var float dayStartEquity = na
var int prevDayOfYear = na
if currentDayOfYear != prevDayOfYear
    dayStartEquity := strategy.equity
    prevDayOfYear := currentDayOfYear
    prevDayOfYear
dailyLoss = dayStartEquity - strategy.equity
killSwitchActive = killSwitch and dailyLoss >= maxDailyLoss

// === ROLLING DRAWDOWN KILL SWITCH ===
rollingPeak = ta.highest(strategy.equity, rollingLen)
rollingDD = rollingPeak - strategy.equity
rollingKill = rollingDD > maxRollingDD

// === ATR PERCENTILE VOLATILITY FILTER ===
var array<float> atrArr = array.new<float>()
var float percATR = na
if bar_index > atrLen
    if array.size(atrArr) >= atrLen
        array.shift(atrArr)
    array.push(atrArr, atr)
    sorted = array.copy(atrArr)
    array.sort(sorted, order.ascending)
    percIndex = math.round(atrPercentile / 100 * (array.size(sorted) - 1))
    percATR := array.get(sorted, percIndex)
    percATR
tradeOk = bar_index > atrLen and atr > percATR

// === DIVERGENCE LOGIC ===
priceSlope = ta.linreg(close, lookback, 0) - ta.linreg(close, lookback, 1)
obv = ta.cum(close > close[1] ? volume : close < close[1] ? -volume : 0)
obvSlope = ta.linreg(obv, lookback, 0) - ta.linreg(obv, lookback, 1)
trend_ma = ta.sma(close, 50)
bullDiv = priceSlope < 0 and obvSlope > 0 and close > trend_ma
bearDiv = priceSlope > 0 and obvSlope < 0 and close < trend_ma
divStrength = math.abs(priceSlope * obvSlope) * sensitivity
divStrengthNorm = math.min(divStrength, 1.0)

// === SIGNAL SMOOTHING ===
bullDiv2 = bullDiv and bullDiv[1]
bearDiv2 = bearDiv and bearDiv[1]

// === Z-SCORE FILTER ===
zMean = ta.sma(close, zLength)
zStd = ta.stdev(close, zLength)
zScore = zStd != 0 ? (close - zMean) / zStd : 0
zOk = not useZFilter or math.abs(zScore) < zThreshold

// === MULTI-TIMEFRAME TREND FILTER ===
htf_ma = request.security(syminfo.tickerid, htf_tf, ta.sma(close, htf_len))
bullTrendOK = close > htf_ma
bearTrendOK = close < htf_ma

// === SIGNAL DEBOUNCE, ADAPTIVE COOLDOWN ===
var int lastSignalBar = na
var int lastDirection = 0 // 1=long, -1=short, 0=neutral
var int dynamicCooldown = cooldownBars
if strategy.closedtrades > 0
    lastTrade = strategy.closedtrades.profit(strategy.closedtrades - 1)
    if lastTrade < 0
        dynamicCooldown := math.min(dynamicCooldown * 2, 10)
        dynamicCooldown
    else
        dynamicCooldown := cooldownBars
        dynamicCooldown
canSignal = na(lastSignalBar) or bar_index - lastSignalBar >= dynamicCooldown

// === ENTRY LOGIC ===
if canSignal and tradeOk and inSession and not killSwitchActive and not rollingKill and zOk
    if bullDiv2 and lastDirection != 1 and strategy.position_size <= 0 and bullTrendOK
        if strategy.position_size < 0
            strategy.close('Short')
        strategy.entry('Long', strategy.long)
        lastDirection := 1
        lastSignalBar := bar_index
        lastSignalBar
    else if bearDiv2 and lastDirection != -1 and strategy.position_size >= 0 and bearTrendOK
        if strategy.position_size > 0
            strategy.close('Long')
        strategy.entry('Short', strategy.short)
        lastDirection := -1
        lastSignalBar := bar_index
        lastSignalBar

if strategy.position_size == 0
    lastDirection := 0
    lastDirection

// === TRADE MANAGEMENT ===
var float stopPrice = na
var float limitPrice = na
if strategy.position_size != 0 and strategy.opentrades > 0
    fillPx = strategy.opentrades.entry_price(0)
    barsInTrade = bar_index - strategy.opentrades.entry_bar_index(0)
    if strategy.position_size > 0
        stopPrice := fillPx - stopDist
        limitPrice := fillPx + profitDist
        strategy.exit('LongExit', from_entry = 'Long', stop = stopPrice, limit = limitPrice, alert_message = 'Long Stop/TP Exit')
        if barsInTrade >= maxBarsInTrade or not tradeOk or killSwitchActive or rollingKill
            strategy.close('Long')
    if strategy.position_size < 0
        stopPrice := fillPx + stopDist
        limitPrice := fillPx - profitDist
        strategy.exit('ShortExit', from_entry = 'Short', stop = stopPrice, limit = limitPrice, alert_message = 'Short Stop/TP Exit')
        if barsInTrade >= maxBarsInTrade or not tradeOk or killSwitchActive or rollingKill
            strategy.close('Short')
else
    stopPrice := na
    limitPrice := na
    limitPrice

// === AURORA BANDS ===
bandOffset = atr * bandWidth
bullTopPlot = plot(bullDiv2 ? low - bandOffset : na, color = color.new(color.white, 100), title = 'Bull Top')
bullBottomPlot = plot(bullDiv2 ? low - 2 * bandOffset : na, color = color.new(color.white, 100), title = 'Bull Bottom')
bearTopPlot = plot(bearDiv2 ? high + 2 * bandOffset : na, color = color.new(color.white, 100), title = 'Bear Top')
bearBottomPlot = plot(bearDiv2 ? high + bandOffset : na, color = color.new(color.white, 100), title = 'Bear Bottom')
bullColor = color.new(color.aqua, 60 - divStrengthNorm * 15)
bearColor = color.new(color.fuchsia, 60 - divStrengthNorm * 15)
fill(bullTopPlot, bullBottomPlot, color = bullColor, title = 'Bullish Aurora')
fill(bearTopPlot, bearBottomPlot, color = bearColor, title = 'Bearish Aurora')

// === DIVERGENCE ORBS WITH GLOW AND LABELS ===
plotshape(bullDiv2 and canSignal, style = shape.circle, location = location.belowbar, color = color.new(color.aqua, 40), size = size.large, offset = 0)
plotshape(bullDiv2 and canSignal, style = shape.circle, location = location.belowbar, color = color.new(color.aqua, 0), size = size.normal, offset = 0)
plotshape(bearDiv2 and canSignal, style = shape.circle, location = location.abovebar, color = color.new(color.fuchsia, 40), size = size.large, offset = 0)
plotshape(bearDiv2 and canSignal, style = shape.circle, location = location.abovebar, color = color.new(color.fuchsia, 0), size = size.normal, offset = 0)
y_pos_bull = bullDiv2 and canSignal ? low - atr * 0.5 : na
y_pos_bear = bearDiv2 and canSignal ? high + atr * 0.5 : na
label.new(bullDiv2 and canSignal ? bar_index : na, y_pos_bull, str.tostring(divStrengthNorm, '#.##'), color = color.new(color.white, 0), textcolor = color.white, style = label.style_none)
label.new(bearDiv2 and canSignal ? bar_index : na, y_pos_bear, str.tostring(divStrengthNorm, '#.##'), color = color.new(color.white, 0), textcolor = color.white, style = label.style_none)

// === GRADIENT BACKGROUND ===
bgColor = bullDiv2 ? color.new(color.green, 90) : bearDiv2 ? color.new(color.red, 90) : color.new(color.gray, 95)
bgcolor(bgColor, title = 'DAFE Aurora Gradient')

// === STRATEGY PLOTS ===
plot(series = strategy.position_size > 0 ? stopPrice : na, title = 'Long Stop', color = color.red, linewidth = 1, style = plot.style_linebr)
plot(series = strategy.position_size > 0 ? limitPrice : na, title = 'Long TP', color = color.green, linewidth = 1, style = plot.style_linebr)
plot(series = strategy.position_size < 0 ? stopPrice : na, title = 'Short Stop', color = color.red, linewidth = 1, style = plot.style_linebr)
plot(series = strategy.position_size < 0 ? limitPrice : na, title = 'Short TP', color = color.green, linewidth = 1, style = plot.style_linebr)
plot(series = htf_ma, title = 'HTF MA', color = color.yellow, linewidth = 1)
plot(series = useZFilter ? zScore : na, title = 'Z-Score', color = color.blue, linewidth = 1, style = plot.style_stepline)
bgcolor(killSwitchActive or rollingKill ? color.new(color.red, 90) : na, title = 'Kill Switch Warning')
hline(0, title = 'Zero Line', color = color.gray, linestyle = hline.style_dotted, linewidth = 1)

// === METRICS DASHBOARD ===
var table dashboard = table.new(position.top_right, 2, 8, bgcolor = color.new(color.black, 80), border_color = color.new(color.silver, 50), border_width = 1)
dailyBuffer = maxDailyLoss - dailyLoss
rollingBuffer = maxRollingDD - rollingDD
killSwitchBuffer = killSwitchActive or rollingKill ? 0.0 : math.min(dailyBuffer, rollingBuffer)
table.cell(dashboard, 0, 0, '⚡ Aurora Divergence – Quant Master', text_color = color.rgb(200, 200, 255), text_size = size.small)
table.cell(dashboard, 0, 1, 'Daily Loss ($):', text_color = color.white, text_size = size.small)
table.cell(dashboard, 1, 1, str.tostring(dailyLoss, '#.##'), text_color = dailyLoss > maxDailyLoss ? color.red : color.white, text_size = size.small)
table.cell(dashboard, 0, 2, 'Rolling DD ($):', text_color = color.white, text_size = size.small)
table.cell(dashboard, 1, 2, str.tostring(rollingDD, '#.##'), text_color = rollingDD > maxRollingDD ? color.red : color.white, text_size = size.small)
table.cell(dashboard, 0, 3, 'ATR Threshold:', text_color = color.white, text_size = size.small)
table.cell(dashboard, 1, 3, str.tostring(percATR, '#.##'), text_color = tradeOk ? color.green : color.red, text_size = size.small)
table.cell(dashboard, 0, 4, 'Z-Score:', text_color = color.white, text_size = size.small)
table.cell(dashboard, 1, 4, str.tostring(zScore, '#.##'), text_color = zOk ? color.green : color.red, text_size = size.small)
table.cell(dashboard, 0, 5, 'Signal:', text_color = color.white, text_size = size.small)
signalText = bullDiv2 ? 'Bullish Div' : bearDiv2 ? 'Bearish Div' : 'None'
signalColor = bullDiv2 ? color.aqua : bearDiv2 ? color.fuchsia : color.gray
table.cell(dashboard, 1, 5, signalText, text_color = signalColor, text_size = size.small)
table.cell(dashboard, 0, 6, 'Action:', text_color = color.white, text_size = size.small)
actionText = bullDiv2 and canSignal ? 'Consider Buying' : bearDiv2 and canSignal ? 'Consider Selling' : 'Wait'
table.cell(dashboard, 1, 6, actionText, text_color = signalColor, text_size = size.small)
table.cell(dashboard, 0, 7, 'Kill Switch Buffer ($):', text_color = color.white, text_size = size.small)
table.cell(dashboard, 1, 7, str.tostring(killSwitchBuffer, '#.##'), text_color = killSwitchBuffer > 0 ? color.green : color.red, text_size = size.small)

// === WATERMARK ===
var table watermark = table.new(position.bottom_right, 1, 1, bgcolor = color.new(color.black, 80), border_color = color.new(color.silver, 50), border_width = 1)
if barstate.islast
    table.cell(watermark, 0, 0, '⚡ Dskyz (DAFE) Trading Systems', text_color = color.rgb(159, 127, 255, 80), text_size = size.normal)

// === BEGINNER GUIDE ===
var bool guideShown = false
if not guideShown and barstate.isfirst
    guideShown := true
    var table guide = table.new(position.middle_right, 2, 3, bgcolor = color.new(color.black, 70), border_color = color.new(color.silver, 50), border_width = 1)
    table.cell(guide, 0, 0, 'Dskyz (DAFE) Aurora Divergence Guide', text_color = color.rgb(200, 200, 255), text_size = size.normal)
    table.cell(guide, 0, 1, 'Aqua Orbs (Below): Bullish Divergence - Consider Buying', text_color = color.aqua, text_size = size.small)
    table.cell(guide, 0, 2, 'Fuchsia Orbs (Above): Bearish Divergence - Consider Selling', text_color = color.fuchsia, text_size = size.small)

// === ALERTS ===
alertcondition(bullDiv2 and canSignal, title = 'DAFE Bullish Divergence', message = 'Aurora: Bullish Divergence Detected (Strength: {{divStrengthNorm}})')
alertcondition(bearDiv2 and canSignal, title = 'DAFE Bearish Divergence', message = 'Aurora: Bearish Divergence Detected (Strength: {{divStrengthNorm}})')

// === END OF STRATEGY ===
````

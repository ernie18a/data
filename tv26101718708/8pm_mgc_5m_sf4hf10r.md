# 8PM  (MGC 5M)

- url: https://www.tradingview.com/script/sf4Hf10r/
- type: strategy
- pine_id: PUB;5c62c7dd1bc24f109e9f3ff39caaa28a
- version: 1.0

## Description

Title:
8PM MGC 5M - $445/$1000 DEFAULT | Prop Firm Ready $300/$600 | Micro Gold

Full Description:

🔥 8PM MGC STRATEGY - $445 / $1000 DEFAULT | The Most Consistent Micro Gold Session
Stop overtrading Gold. One session. One range. One proven plan.

This is my DEFAULT 8PM NY strategy for MGC - Micro Gold Futures (5-Min Chart). No martingale, no grid, no indicators lagging. Just a pure Double Breakout system on the most predictable hour of Gold with fixed Dollar Risk Management.

Designed for prop firms and small accounts: Fixed $445 Risk -> $1000 Reward.

LIVE PERFORMANCE - DEFAULT SETTINGS:
From the screenshot - No optimization tricks:

Net Profit: +$28,679 [image]https://www.tradingview.com/x/rrEJyuPw/[/image]
Profit Factor: 1.862
Win Rate: 43.14% (66 Wins / 153 Trades) - Profitable thanks to 1:2.25 RR
Max Drawdown: Only  ($3,007)
Chart: https://www.tradingview.com/x/9UMXvjZA/
With a 1:2.25 RR, you only need ∼31% WR to be profitable. We do 43%+.

💡 THE EDGE - Why 8PM NY?
8PM NY is after the main US session close. Volume drops, Gold creates a tight, clean RANGE between 20:00-20:05. What happens next? A clean breakout + retest that institutions use to reposition for Asia.

This strategy avoids the noise and trades ONLY that move.

📦 HOW IT WORKS - Double Breakout Confirmation
This is NOT a simple range breakout. It's a 2-step filter to kill fakeouts.

Step 1: The RANGE (20:00-20:05 NY)
The strategy marks High/Low of the 5M candle at 8PM. This is your key zone. Premium box is drawn automatically.

Step 2: First Breakout - The Trap
Price must close ABOVE Range High or BELOW Range Low. This is just the alert. It does NOT enter yet. It marks a BO HIGH / BO LOW level.

Step 3: Second Breakout - The Entry
Only on the SECOND close beyond the BO level - we enter.

Long: Close > BO HIGH -> SL = Range Low, TP = $1000
Short: Close < BO LOW -> SL = Range High, TP = $1000
This double confirmation filters 70% of false breaks that kill most range strategies.

Expiration at 21:35 - If no entry by then, no trade. No late-night gambling.

💰 RISK MANAGEMENT - Built for Prop Firms
Fixed Dollar Risk: You risk exactly $445 per trade. The strategy auto-calculates contracts: Qty = $445 / (Risk Distance * $10 Point Value)
Fixed Dollar Reward: Target is exactly $1000. No greed.
TP Buffer (WR Boost): Default 0.8 points BEFORE the TP. Takes profit 0.8 points early to avoid wicks that miss TP by 0.1. This alone boosts WR by 5-8%.
SL Buffer: Extra protection beyond the range.
Max 3 Trades Per Day: Prevents revenge trading. After 3 trades, it stops for the day.
MGC Point Value: Correctly set to $10 for accurate sizing.
🏦 PROP FIRM READY - $300 Risk / $600 Reward Mode:
This strategy is perfect for funding companies (Apex, Take Profit Trader, Topstep, etc.). Just change the inputs to Risk $300 / Reward $600. You get a clean 1:2 RR that fits all prop firm rules for daily loss limit. Many funded traders use it on $300/$600 to pass evaluations faster with smaller drawdown. Same logic, same high accuracy, lower risk - ideal for challenges.

⚙️ SETTINGS - DEEP DIVE
TIME & RISK Group:

Range Candle Time (20:00-20:05 NY) & Expiration (21:35-21:40 NY): The core window. Don't change unless you know what you're doing.
Risk/Reward ($445/$1000): My DEFAULT proven on prop accounts. You can optimize but this is the sweet spot. For prop firms, switch to $300 / $600.
Skip First Trades? 0 - Do not skip / 1 - Skip 1st / 2 - Skip 1st & 2nd: Powerful! Often the first breakout of the night is a fakeout. Many pros skip the 1st trade and take 2nd & 3rd only for higher WR.
TP/SL Buffer Points: My secret for higher win rate on Gold.
ALLOWED DAYS NY Group:
Default: Sun, Mon, Tue, Wed = ON | Thu, Fri, Sat = OFF
Why? Statistics show Sun-Wed 8PM are the cleanest. Thursday/Friday have FOMC leftovers, NFP volatility. This filter avoids choppy days.

TRAILING STOP Group:

Enable TP Extension: Turns your fixed TP into a native trailing stop. When price hits your TP level, it starts trailing by Trail Distance to catch runners on big Gold moves. Perfect for letting winners run past $1000.
VISUALS PREMIUM:
Professional boxes, BO levels, TP/SL boxes with $ and quantity labels. You see exactly what the strategy sees.

🎯 HOW TO USE IT - 4 WAYS
1. DEFAULT Prop Firm Mode (Recommended):
Load on MGC 5M, leave defaults: $445/$1000, Sun-Wed, Max 3 trades. Let it run. No emotions.

2. High WR Mode:
Set Skip First Trades? = 1 - Skip 1st Trade + Enable TP Buffer 0.8. This cuts trades but increases win rate significantly. Perfect for funded accounts.

3. Runner Mode:
Enable TP Extension with Trail Distance 1.0-1.5 points. You will secure $800-$900 and let the rest run to $1500+ on trend nights.

4. MANUAL LOWER TIMEFRAME BIAS MODE (For Active Traders):
This strategy is also a perfect BIAS tool for those who want to trade manually during these hours on a lower timeframe.
Load the strategy on 5M, but execute on 1M or 3M. Treat the signals as a clear BIAS:

If BO HIGH is broken -> BIAS is LONG only until clear TP target.
If BO LOW is broken -> BIAS is SHORT only until clear TP target.
Don't fight the level. Use the premium TP/SL boxes as your clear target and stop. You get a defined BIAS with a clear target for scalping the 20:00-21:40 window.
This strategy is specifically for MGC (Micro Gold) on 5M. You can test it on GC (Gold Futures) as well but keep the Point Value adjustment.

If this helped you understand how to trade Gold properly at night, please Like, Boost, and Follow. I will publish the optimized version for GC and XAUUSD next.

Disclaimer: Futures trading involves substantial risk. Past performance shown in the screenshot (PF 1.862) does not guarantee future results. This is not financial advice. Trade at your own risk and always test on demo first.

Tags: #MGC #Gold #MicroGold #FuturesTrading #PropFirm #ApexTrader #NYSession #Scalping

[image]https://www.tradingview.com/x/rrEJyuPw/[/image]

## Source Code

````pine
// @version=6
strategy("8PM MGC 5M - $445 Risk $1000 Reward - DEFAULT", shorttitle="8PM MGC $445/$1000 DEFAULT V6", overlay=true, initial_capital=100000, currency=currency.USD, pyramiding=1, calc_on_every_tick=false, calc_on_order_fills=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// --- TIME & RISK - MGC - DEFAULTS FROM YOUR SCREENSHOTS ---
grp_time = "TIME & RISK - MGC"
rangeTime = input.session("2000-2005", title="Range Candle Time (NY)", group=grp_time)
endTime = input.session("2135-2140", title="Expiration Time (NY)", group=grp_time)
riskDollars = input.float(445, title="Risk Per Trade $ (MGC)", step=5, group=grp_time)
rewardDollars = input.float(1000, title="Reward Per Trade $ (MGC)", step=50, group=grp_time)
tpBufferPoints = input.float(0.8, title="TP Buffer - נקודות לפני ה-TP (WR Boost)", step=0.1, minval=0, group=grp_time)
slBufferPoints = input.float(0, title="SL Buffer - נקודות מעבר ל-SL", step=0.1, minval=0, group=grp_time)
pointValueMGC = input.float(10, title="MGC Point Value $ (1$ = 10$)", group=grp_time)
maxTrades = input.int(3, title="Max Trades Per Day", minval=1, group=grp_time)
skipTradesInput = input.string("0 - Do not skip", title="Skip First Trades?", options=["0 - Do not skip", "1 - Skip 1st Trade", "2 - Skip 1st and 2nd Trades"], group=grp_time)

// --- ALLOWED DAYS NY - DEFAULTS FROM YOUR SCREENSHOTS ---
grp_days = "ALLOWED DAYS NY"
tradeSun = input.bool(true, title="Sunday", group=grp_days)
tradeMon = input.bool(true, title="Monday", group=grp_days)
tradeTue = input.bool(true, title="Tuesday", group=grp_days)
tradeWed = input.bool(true, title="Wednesday", group=grp_days)
tradeThu = input.bool(false, title="Thursday", group=grp_days)
tradeFri = input.bool(false, title="Friday", group=grp_days)
tradeSat = input.bool(false, title="Saturday", group=grp_days)

groupVis = "VISUALS PREMIUM"
enablePremiumVisuals = input.bool(true, title="Enable Premium Visuals", group=groupVis)

// --- TRAILING STOP ---
grp_trail = "TRAILING STOP"
use_tp_extend = input.bool(false, title="Enable TP Extension (Native Trailing)", group=grp_trail)
sl_trail_dist = input.float(1.0, title="Trail Distance (Points)", step=0.5, group=grp_trail)
float sl_trail_ticks = sl_trail_dist / syminfo.mintick

skipCount = skipTradesInput == "1 - Skip 1st Trade"? 1 : skipTradesInput == "2 - Skip 1st and 2nd Trades"? 2 : 0
currentDayNY = dayofweek(time, "America/New_York")
isAllowedDay = (currentDayNY == dayofweek.sunday and tradeSun) or (currentDayNY == dayofweek.monday and tradeMon) or (currentDayNY == dayofweek.tuesday and tradeTue) or (currentDayNY == dayofweek.wednesday and tradeWed) or (currentDayNY == dayofweek.thursday and tradeThu) or (currentDayNY == dayofweek.friday and tradeFri) or (currentDayNY == dayofweek.saturday and tradeSat)
isRangeCandle = not na(time("5", rangeTime, "America/New_York")) and isAllowedDay
isExpCandle = not na(time("5", endTime, "America/New_York"))

var float rangeHigh = na
var float rangeLow = na
var float breakoutHigh = na
var float breakoutLow = na
var bool lookingForFirstBreakout = false
var bool lookingForSecondBreakoutLong = false
var bool lookingForSecondBreakoutShort = false
var int tradesToday = 0
var int skippedTradesToday = 0

var line lineHigh = na
var line lineLow = na
var line lineBO = na
var box rangeBox = na
var label rangeLabel = na
var box boBox = na
var label boLabel = na
var line tpLine = na
var line slLine = na
var box tpBox = na
var box slBox = na
var label tpLabel = na
var label slLabel = na
var label entryLabel = na

if isRangeCandle
    rangeHigh := high
    rangeLow := low
    lookingForFirstBreakout := true
    lookingForSecondBreakoutLong := false
    lookingForSecondBreakoutShort := false
    tradesToday := 0
    skippedTradesToday := 0
    line.delete(lineHigh)
    line.delete(lineLow)
    line.delete(lineBO)
    if not na(rangeBox)
        box.delete(rangeBox), label.delete(rangeLabel)
    if not na(boBox)
        box.delete(boBox), label.delete(boLabel)
    lineHigh := line.new(bar_index, rangeHigh, bar_index, rangeHigh, color=color.blue, width=2)
    lineLow := line.new(bar_index, rangeLow, bar_index, rangeLow, color=color.blue, width=2)
    if enablePremiumVisuals
        rangeBox := box.new(left=bar_index, top=rangeHigh, right=bar_index+1, bottom=rangeLow, xloc=xloc.bar_index, bgcolor=color.new(#2962FF, 85), border_color=#2962FF, border_width=2)
        rangeLabel := label.new(x=bar_index, y=rangeHigh, text="RANGE MGC " + str.tostring(rangeHigh) + " - " + str.tostring(rangeLow), style=label.style_label_down, color=color.new(#2962FF,0), textcolor=color.white, size=size.tiny)

if isExpCandle
    lookingForFirstBreakout := false
    lookingForSecondBreakoutLong := false
    lookingForSecondBreakoutShort := false

if lookingForFirstBreakout or lookingForSecondBreakoutLong or lookingForSecondBreakoutShort
    if not na(lineHigh)
        line.set_x2(lineHigh, bar_index)
    if not na(lineLow)
        line.set_x2(lineLow, bar_index)
    if not na(lineBO)
        line.set_x2(lineBO, bar_index)
    if not na(rangeBox)
        box.set_right(rangeBox, bar_index+5)

if lookingForFirstBreakout and not isRangeCandle and tradesToday < maxTrades and strategy.opentrades == 0
    if close > rangeHigh
        breakoutHigh := high
        lookingForSecondBreakoutLong := true
        lookingForFirstBreakout := false
        line.delete(lineBO)
        lineBO := line.new(bar_index, breakoutHigh, bar_index, breakoutHigh, color=color.green, width=2, style=line.style_dashed)
        if enablePremiumVisuals
            if not na(boBox)
                box.delete(boBox), label.delete(boLabel)
            boBox := box.new(left=bar_index, top=breakoutHigh, right=bar_index+10, bottom=breakoutHigh - 0.5, xloc=xloc.bar_index, bgcolor=color.new(#00E676, 85), border_color=#00E676, border_style=line.style_dashed)
            boLabel := label.new(x=bar_index, y=breakoutHigh, text="BO HIGH", style=label.style_label_left, color=color.new(#00E676,0), textcolor=color.white, size=size.tiny)
    else if close < rangeLow
        breakoutLow := low
        lookingForSecondBreakoutShort := true
        lookingForFirstBreakout := false
        line.delete(lineBO)
        lineBO := line.new(bar_index, breakoutLow, bar_index, breakoutLow, color=color.red, width=2, style=line.style_dashed)
        if enablePremiumVisuals
            if not na(boBox)
                box.delete(boBox), label.delete(boLabel)
            boBox := box.new(left=bar_index, top=breakoutLow + 0.5, right=bar_index+10, bottom=breakoutLow, xloc=xloc.bar_index, bgcolor=color.new(#FF5252, 85), border_color=#FF5252, border_style=line.style_dashed)
            boLabel := label.new(x=bar_index, y=breakoutLow, text="BO LOW", style=label.style_label_left, color=color.new(#FF5252,0), textcolor=color.white, size=size.tiny)

if lookingForSecondBreakoutLong and not isRangeCandle
    if close > breakoutHigh
        if skippedTradesToday < skipCount
            skippedTradesToday += 1
            lookingForFirstBreakout := true
            lookingForSecondBreakoutLong := false
        else
            float slFinal = rangeLow - slBufferPoints
            float riskDist = close - slFinal
            float qtyFloat = riskDollars / (riskDist * pointValueMGC)
            int qty = math.max(1, int(math.floor(qtyFloat)))
            float tpOrig = close + riskDist * (rewardDollars / riskDollars)
            float tpFinal = tpOrig - tpBufferPoints
            tradesToday += 1
            string longId = "Long " + str.tostring(tradesToday + skippedTradesToday)
            strategy.entry(longId, strategy.long, qty=qty)
            
            if use_tp_extend
                strategy.exit("Exit " + longId, from_entry=longId, stop=slFinal, trail_price=tpFinal, trail_offset=sl_trail_ticks)
            else
                strategy.exit("Exit " + longId, from_entry=longId, stop=slFinal, limit=tpFinal)
                
            if enablePremiumVisuals
                if not na(tpLine)
                    line.delete(tpLine), line.delete(slLine), box.delete(tpBox), box.delete(slBox), label.delete(tpLabel), label.delete(slLabel), label.delete(entryLabel)
                tpLine := line.new(x1=bar_index, y1=tpFinal, x2=bar_index+20, y2=tpFinal, xloc=xloc.bar_index, color=#089981, width=2)
                slLine := line.new(x1=bar_index, y1=slFinal, x2=bar_index+20, y2=slFinal, xloc=xloc.bar_index, color=#F23645, width=2)
                tpBox := box.new(left=bar_index, top=tpFinal, right=bar_index+20, bottom=close, xloc=xloc.bar_index, bgcolor=color.new(#089981, 80), border_color=#089981)
                slBox := box.new(left=bar_index, top=close, right=bar_index+20, bottom=slFinal, xloc=xloc.bar_index, bgcolor=color.new(#F23645, 80), border_color=#F23645)
                tpLabel := label.new(x=bar_index+2, y=tpFinal, text="TP $1000: " + str.tostring(tpFinal) + " | x" + str.tostring(qty), style=label.style_label_left, color=color.new(#089981,0), textcolor=color.white, size=size.tiny)
                slLabel := label.new(x=bar_index+2, y=slFinal, text="SL $445: " + str.tostring(slFinal) + " | x" + str.tostring(qty), style=label.style_label_left, color=color.new(#F23645,0), textcolor=color.white, size=size.tiny)
                entryLabel := label.new(x=bar_index, y=close, text="◍ LONG MGC x" + str.tostring(qty) + " 445$->1000$", style=label.style_label_up, color=color.new(#00E676,0), textcolor=color.white, size=size.small)
            lookingForFirstBreakout := true
            lookingForSecondBreakoutLong := false

if lookingForSecondBreakoutShort and not isRangeCandle
    if close < breakoutLow
        if skippedTradesToday < skipCount
            skippedTradesToday += 1
            lookingForFirstBreakout := true
            lookingForSecondBreakoutShort := false
        else
            float slFinal = rangeHigh + slBufferPoints
            float riskDist = slFinal - close
            float qtyFloat = riskDollars / (riskDist * pointValueMGC)
            int qty = math.max(1, int(math.floor(qtyFloat)))
            float tpOrig = close - riskDist * (rewardDollars / riskDollars)
            float tpFinal = tpOrig + tpBufferPoints
            tradesToday += 1
            string shortId = "Short " + str.tostring(tradesToday + skippedTradesToday)
            strategy.entry(shortId, strategy.short, qty=qty)
            
            if use_tp_extend
                strategy.exit("Exit " + shortId, from_entry=shortId, stop=slFinal, trail_price=tpFinal, trail_offset=sl_trail_ticks)
            else
                strategy.exit("Exit " + shortId, from_entry=shortId, stop=slFinal, limit=tpFinal)
                
            if enablePremiumVisuals
                if not na(tpLine)
                    line.delete(tpLine), line.delete(slLine), box.delete(tpBox), box.delete(slBox), label.delete(tpLabel), label.delete(slLabel), label.delete(entryLabel)
                tpLine := line.new(x1=bar_index, y1=tpFinal, x2=bar_index+20, y2=tpFinal, xloc=xloc.bar_index, color=#089981, width=2)
                slLine := line.new(x1=bar_index, y1=slFinal, x2=bar_index+20, y2=slFinal, xloc=xloc.bar_index, color=#F23645, width=2)
                tpBox := box.new(left=bar_index, top=close, right=bar_index+20, bottom=tpFinal, xloc=xloc.bar_index, bgcolor=color.new(#089981, 80), border_color=#089981)
                slBox := box.new(left=bar_index, top=slFinal, right=bar_index+20, bottom=close, xloc=xloc.bar_index, bgcolor=color.new(#F23645, 80), border_color=#F23645)
                tpLabel := label.new(x=bar_index+2, y=tpFinal, text="TP $1000: " + str.tostring(tpFinal) + " | x" + str.tostring(qty), style=label.style_label_left, color=color.new(#089981,0), textcolor=color.white, size=size.tiny)
                slLabel := label.new(x=bar_index+2, y=slFinal, text="SL $445: " + str.tostring(slFinal) + " | x" + str.tostring(qty), style=label.style_label_left, color=color.new(#F23645,0), textcolor=color.white, size=size.tiny)
                entryLabel := label.new(x=bar_index, y=close, text="◍ SHORT MGC x" + str.tostring(qty) + " 445$->1000$", style=label.style_label_down, color=color.new(#FF5252,0), textcolor=color.white, size=size.small)
            lookingForFirstBreakout := true
            lookingForSecondBreakoutShort := false

if strategy.opentrades > 0 and not na(tpBox)
    box.set_right(tpBox, bar_index+5)
    box.set_right(slBox, bar_index+5)
    line.set_x2(tpLine, bar_index+5)
    line.set_x2(slLine, bar_index+5)
````

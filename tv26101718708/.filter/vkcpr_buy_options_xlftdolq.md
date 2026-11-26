# VK_CPR Buy Options

- url: https://www.tradingview.com/script/XlFTdolq-VK-CPR-Buy-Options/
- type: indicator
- pine_id: PUB;0a157aa22e5b4a95bd8d3a46dc50cb9d
- version: 1.0

## Description

VK CPR Buy Options is a trend-following options entry indicator based on Central Pivot Range (CPR). It detects when price crosses above/below the CPR Top or Bottom and suggests the appropriate Call or Put strike. Includes Camarilla and Traditional R1/S1 strike methods, auto strike rounding, backtest stats table, PCR tracker, and day-filter controls. Designed for Indian index options trading (Nifty/Sensex).


📋 REGULATORY DISCLOSURE
//───────────────────
//- NOT SEBI REGISTERED - The creator is not registered with SEBI (Securities
// and Exchange Board of India) or any other financial regulatory authority.
//
//- NOT FINANCIAL ADVICE - This indicator is provided for EDUCATIONAL and
// INFORMATIONAL purposes only. It does not constitute financial advice,
// investment advice, trading advice, or any other sort of advice.
//
//- NO INVESTMENT ADVISOR RELATIONSHIP - Use of this indicator does not create
// an advisory or fiduciary relationship between you and the creator.
//
//⚠️ PERFORMANCE & ACCURACY
//─────────────────────
//- NO GUARANTEE OF RESULTS - Past performance does NOT guarantee future results.
// Profitable trades in backtesting or historical data do not ensure future
// profitability.
//
//- NO WARRANTY - This indicator is provided "AS IS" without warranty of any kind,
// either expressed or implied. The creator makes no guarantee regarding accuracy,
// reliability, or completeness of signals.
//
//- MARKET RISKS - All trading involves substantial risk. Markets can be volatile,
// unpredictable, and subject to sudden changes. No indicator can predict market
// movements with certainty.
//
//💰 FINANCIAL RISK WARNING
//─────────────────────
//- HIGH RISK OF LOSS - Trading in stocks, derivatives, forex, crypto, and other
// financial instruments involves substantial risk of loss and is not suitable
// for all investors.
//
//- CAPITAL AT RISK - You should only trade with capital you can afford to lose
// completely. Never invest money you cannot afford to lose.
//
//- LEVERAGE RISKS - If trading with leverage or margin, losses can exceed your
// initial investment. Use leverage cautiously.
//
//- EMOTIONAL & PSYCHOLOGICAL RISKS - Trading can be stressful. Ensure you have
// the emotional capacity to handle potential losses.
//
//👤 YOUR SOLE RESPONSIBILITY
//─────────────────────
//- PERSONAL ACCOUNTABILITY - You are SOLELY and ENTIRELY responsible for:
// ✗ All trading decisions you make
// ✗ All profits and losses resulting from your trades
// ✗ All tax obligations and regulatory compliance
// ✗ Understanding the risks involved before trading
//
//- DO YOUR OWN RESEARCH - Never trade based solely on indicator signals. Always:
// ✓ Conduct your own analysis and research
// ✓ Understand the assets you're trading
// ✓ Have a clear risk management strategy
// ✓ Use proper position sizing
// ✓ Set and follow stop losses
//
//- SEEK PROFESSIONAL ADVICE - Consult with a qualified, registered financial
// advisor before making investment decisions, especially if you're uncertain
// about the suitability of any investment.
//
//- BACKTESTING RECOMMENDED - Before using this indicator with real money:
// 1. Backtest on historical data
// 2. Paper trade to verify performance
// 3. Start with small position sizes
// 4. Gradually scale up only after consistent results
//
//- NO OPTIMAL SETTINGS - There is NO "perfect" setting that works for all
// markets, timeframes, or trading styles. What works in one market condition
// may fail in another.
//
//📊 INDICATOR LIMITATIONS
//──────────────────
//- TOOL, NOT SOLUTION - This indicator is a TOOL to assist your analysis. It
// should be used as part of a comprehensive trading strategy, not as a
// standalone system.
//
//- LAGGING INDICATORS - Most technical indicators, including this one, are based
// on historical price data and may lag current market conditions.
//
//- FALSE SIGNALS - All indicators generate false signals. No indicator is 100%
// accurate. Losses are inevitable in trading.
//
//- WORKS BEST IN TRENDS - This indicator is designed for trending markets. It
// may produce suboptimal results in sideways/ranging markets.
//
//🚫 WHAT THIS INDICATOR DOES NOT DO
//───────────────────────────
//✗ Does NOT guarantee profits
//✗ Does NOT eliminate risk
//✗ Does NOT replace proper education
//✗ Does NOT work 100% of the time
//✗ Does NOT predict the future
//✗ Does NOT replace risk management
//✗ Does NOT compensate for poor trading discipline
//
//✅ BEST PRACTICES FOR SAFE USAGE
//─────────────────────────
//1. EDUCATE YOURSELF - Learn about technical analysis, risk management, and
// trading psychology before trading with real money.
//
//2. START SMALL - Begin with paper trading or very small positions until you
// develop confidence and consistency.
//
//3. RISK MANAGEMENT - Never risk more than 1-2% of your capital on a single trade.
//
//4. USE STOP LOSSES - Always use stop losses. This indicator provides trailing
// stop levels - USE THEM!
//
//5. COMBINE METHODS - Use multiple forms of analysis (fundamental, technical,
// sentiment) along with this indicator.
//
//6. JOURNAL YOUR TRADES - Keep a detailed trading journal to learn from both
// wins and losses.
//
//7. MANAGE EMOTIONS - Follow your trading plan. Don't chase trades or revenge
// trade after losses.
//
//8. TEST BEFORE TRADING - Thoroughly backtest and forward test any settings
// before using real money.
//
//📞 QUESTIONS OR ISSUES?
//──────────────────
//This indicator is provided as-is for educational purposes. The creator provides
//no ongoing support, guarantees, or liability for its use.
//
//══════════════════════════════════════════════════
//BY USING THIS INDICATOR, YOU ACKNOWLEDGE THAT YOU HAVE READ, UNDERSTOOD,
//AND AGREE TO ALL TERMS OF THIS DISCLAIMER. YOU ACCEPT FULL RESPONSIBILITY
//FOR YOUR TRADING DECISIONS AND ANY RESULTING OUTCOMES.
//═════════════════════════════════════════════════════════
//
//⚖️ LEGAL NOTICE
//──────────────
//If trading is regulated in your jurisdiction, ensure you comply with all
//applicable laws and regulations. The creator assumes no responsibility for
//any legal consequences resulting from your use of this indicator.
//
//📅 Last Updated: 24 December 2025
//═══════════════════════
//
//💪 Trade Smart. Trade with Discipline. Stay on the Trend Side!

## Source Code

````pine
//@version=6
indicator("VK_CPR Buy Options", overlay=true, max_lines_count=500, max_labels_count=500)

// ============================================================================
// INPUTS
// ============================================================================
tradeSource = input.source(close, title='Price Source')
autoTF = input.string('Auto', title="Timeframe", options=['Auto','Manual'], group='Pivot')
manPivotTF = input.timeframe('D', title='Manual TF', group='Pivot',
     options=['60','90','120','D','2D','3D','4D','W','2W','3W','4W','M','2M','3M','6M'])

strikeMethod = input.string('Central Pivot', title="Strike Method",
     options=['Central Pivot', 'Traditional R1/S1', 'Camarilla R1/S1', 'Camarilla R2/S2'], group="Strike")

optionType = input.string('Auto (Both)', title='Option Type',
     options=['Auto (Both)', 'Calls Only', 'Puts Only'], group='Trade')

spreadMethod = input.string('Auto', title='Spread', options=['Auto', 'Manual'], group='Strike')
manSpreadValue = input.float(5.0, title="Manual Spread", group='Strike')

showPivots = input.bool(true, "Show Pivots", group='Visual')
showSignals = input.bool(true, "Show Signals", group='Visual')
showResults = input.bool(true, "Show Stats", group='Visual')

backtestStart = input.time(timestamp("1 Jan 2023"), "Start", group="Backtest")
backtestEnd = input.time(timestamp("1 Jan 2099"), "End", group="Backtest")

tradeOnMon = input.bool(true, 'Mon', group='Days', inline='d')
tradeOnTue = input.bool(true, 'Tue', group='Days', inline='d')
tradeOnWed = input.bool(true, 'Wed', group='Days', inline='d')
tradeOnThu = input.bool(true, 'Thu', group='Days', inline='d')
tradeOnFri = input.bool(true, 'Fri', group='Days', inline='d')

// ============================================================================
// SETUP
// ============================================================================
HTFo = timeframe.period == '1' ? '30' : timeframe.period == '3' ? '60' : timeframe.period == '5' ? '240' : 
     timeframe.period == '15' or timeframe.period == '30' or timeframe.period == '45' ? 'D' : 
     timeframe.period == '60' or timeframe.period == '120' or timeframe.period == '180' or timeframe.period == '240' ? 'W' : 
     timeframe.period == 'D' ? 'W' : timeframe.period == 'W' ? '4W' : 'D'

pivotTF = autoTF == 'Auto' ? HTFo : manPivotTF

tradeDay = (dayofweek == dayofweek.monday and tradeOnMon) or (dayofweek == dayofweek.tuesday and tradeOnTue) or
     (dayofweek == dayofweek.wednesday and tradeOnWed) or (dayofweek == dayofweek.thursday and tradeOnThu) or
     (dayofweek == dayofweek.friday and tradeOnFri)

inRange = time >= backtestStart and time <= backtestEnd

// ============================================================================
// GET PIVOT DATA
// ============================================================================
pivotShift = 1
htfH = request.security(syminfo.tickerid, pivotTF, high[pivotShift], lookahead=barmerge.lookahead_on)
htfL = request.security(syminfo.tickerid, pivotTF, low[pivotShift], lookahead=barmerge.lookahead_on)
htfC = request.security(syminfo.tickerid, pivotTF, close[pivotShift], lookahead=barmerge.lookahead_on)

// Calculate pivots
rng = htfH - htfL
cp = (htfH + htfL + htfC) / 3
tb = (htfH + htfL) / 2
tt = (cp - tb) + cp
bp = tb > tt ? tt : tb
tp = bp == tb ? tt : tb

tr1 = 2 * cp - htfL
ts1 = 2 * cp - htfH

cr1 = htfC + rng * 1.1 / 12
cs1 = htfC - rng * 1.1 / 12
cr2 = htfC + rng * 1.1 / 6
cs2 = htfC - rng * 1.1 / 6

// ============================================================================
// DRAW PIVOT LINES
// ============================================================================
var line topLine = na
var line cpLine = na
var line bottomLine = na
var line r1Line = na
var line s1Line = na
var int periodStartBar = na

is_newbar(res, sess) =>
    t = time(res, sess)
    na(t[1]) and not na(t) or t[1] < t

newPeriod = is_newbar(pivotTF, session.regular)

if newPeriod and showPivots and bar_index > 0
    if not na(topLine)
        line.delete(topLine)
    if not na(cpLine)
        line.delete(cpLine)
    if not na(bottomLine)
        line.delete(bottomLine)
    if not na(r1Line)
        line.delete(r1Line)
    if not na(s1Line)
        line.delete(s1Line)
    
    periodStartBar := bar_index
    topLine := line.new(periodStartBar, tp, bar_index, tp, color=color.blue, width=2)
    cpLine := line.new(periodStartBar, cp, bar_index, cp, color=color.orange, width=2)
    bottomLine := line.new(periodStartBar, bp, bar_index, bp, color=color.blue, width=2)
    
    if strikeMethod == 'Traditional R1/S1'
        r1Line := line.new(periodStartBar, tr1, bar_index, tr1, color=color.red, width=1, style=line.style_dotted)
        s1Line := line.new(periodStartBar, ts1, bar_index, ts1, color=color.green, width=1, style=line.style_dotted)

if not na(topLine) and not na(periodStartBar) and showPivots
    line.set_x2(topLine, bar_index)
    line.set_x2(cpLine, bar_index)
    line.set_x2(bottomLine, bar_index)
    
    if not na(r1Line) and strikeMethod == 'Traditional R1/S1'
        line.set_x2(r1Line, bar_index)
        line.set_x2(s1Line, bar_index)

// ============================================================================
// STRIKES
// ============================================================================
spreadValue = spreadMethod == "Auto" ? 
     close >= 1000 ? 50.0 : close >= 500 ? 10.0 : close >= 100 ? 5.0 :
     close >= 50 ? 2.5 : close >= 20 ? 1.0 : 0.5 : manSpreadValue

roundStrike(val, sprd, dir) =>
    dir == 'up' ? math.ceil(val/sprd) * sprd : math.floor(val/sprd) * sprd

callLevel = strikeMethod == 'Central Pivot' ? cp : strikeMethod == 'Traditional R1/S1' ? tr1 :
     strikeMethod == 'Camarilla R1/S1' ? cr1 : cr2

putLevel = strikeMethod == 'Central Pivot' ? cp : strikeMethod == 'Traditional R1/S1' ? ts1 :
     strikeMethod == 'Camarilla R1/S1' ? cs1 : cs2

callStrike = na(callLevel) ? na : roundStrike(callLevel, spreadValue, 'up')
putStrike = na(putLevel) ? na : roundStrike(putLevel, spreadValue, 'down')

// ============================================================================
// TREND FOLLOWING SIGNALS - ONE POSITION AT A TIME
// ============================================================================
var string currentTrade = na  // Track current position type
var float entryStrike = na
var int entryBar = na
var float entryPrice = na

// Detect crossovers
crossedAboveTop = ta.crossover(tradeSource, tp)
crossedBelowBottom = ta.crossunder(tradeSource, bp)

// Generate signals based on crosses - BUT ONLY IF NO SAME-TYPE POSITION EXISTS
string newSignal = na

if not na(tp) and not na(bp) and tradeDay and inRange
    if optionType == 'Auto (Both)'
        // Only enter CALL if we're NOT already in a CALL
        if crossedAboveTop and currentTrade != "BUY CALL"
            newSignal := "BUY CALL"
        // Only enter PUT if we're NOT already in a PUT
        else if crossedBelowBottom and currentTrade != "BUY PUT"
            newSignal := "BUY PUT"
    else if optionType == 'Calls Only'
        // Only enter CALL if we're NOT already in a CALL
        if crossedAboveTop and currentTrade != "BUY CALL"
            newSignal := "BUY CALL"
    else if optionType == 'Puts Only'
        // Only enter PUT if we're NOT already in a PUT
        if crossedBelowBottom and currentTrade != "BUY PUT"
            newSignal := "BUY PUT"

// Process new signal
if not na(newSignal)
    // Exit previous trade silently (no label, just track P&L)
    if not na(currentTrade) and not na(entryStrike)
        exitPrice = close
        exitResult = false
        
        if currentTrade == "BUY CALL"
            exitResult := exitPrice > entryStrike
        else if currentTrade == "BUY PUT"
            exitResult := exitPrice < entryStrike
        
        // NO EXIT LABEL - just track the result for stats
    
    // Enter new trade
    currentTrade := newSignal
    entryStrike := newSignal == "BUY CALL" ? callStrike : putStrike
    entryPrice := close
    entryBar := bar_index
    
    // Show ENTRY label ONLY
    if showSignals and not na(entryStrike)
        entryColor = newSignal == "BUY CALL" ? color.green : color.red
        entryStyle = newSignal == "BUY CALL" ? label.style_label_up : label.style_label_down
        entryY = newSignal == "BUY CALL" ? low : high
        
        label.new(bar_index, entryY, 
             newSignal + "\n" + str.tostring(entryStrike, '#.##'),
             color=color.new(entryColor, 30),
             textcolor=color.white,
             style=entryStyle,
             size=size.normal)

// ============================================================================
// P&L TRACKING
// ============================================================================
var int tot = 0, var int wins = 0, var int loss = 0
var int ct = 0, var int cw = 0, var int pt = 0, var int pw = 0

// Track trades when they exit
if not na(newSignal) and not na(currentTrade[1]) and not na(entryStrike[1])
    // Previous trade just exited
    exitResult = false
    
    if currentTrade[1] == "BUY CALL"
        exitResult := close > entryStrike[1]
        ct := ct + 1
        if exitResult
            cw := cw + 1
    else if currentTrade[1] == "BUY PUT"
        exitResult := close < entryStrike[1]
        pt := pt + 1
        if exitResult
            pw := pw + 1
    
    tot := tot + 1
    if exitResult
        wins := wins + 1
    else
        loss := loss + 1

// ============================================================================
// TABLES
// ============================================================================
var t1 = table.new(position.bottom_right, 3, 5, border_width=1)

if barstate.islast and showResults and tot > 0
    wr = (wins / tot) * 100
    cwr = ct > 0 ? (cw / ct) * 100 : 0
    pwr = pt > 0 ? (pw / pt) * 100 : 0
    
    table.cell(t1, 0, 0, "Type", text_color=color.white, bgcolor=color.gray)
    table.cell(t1, 1, 0, "Trades", text_color=color.white, bgcolor=color.gray)
    table.cell(t1, 2, 0, "Win %", text_color=color.white, bgcolor=color.gray)
    table.cell(t1, 0, 1, "All", text_color=color.white)
    table.cell(t1, 1, 1, str.tostring(tot), text_color=color.white)
    table.cell(t1, 2, 1, str.tostring(wr, '#.#') + "%", text_color=color.white)
    table.cell(t1, 0, 2, "Calls", text_color=color.white)
    table.cell(t1, 1, 2, str.tostring(ct), text_color=color.white)
    table.cell(t1, 2, 2, ct > 0 ? str.tostring(cwr, '#.#') + "%" : "-", text_color=color.white)
    table.cell(t1, 0, 3, "Puts", text_color=color.white)
    table.cell(t1, 1, 3, str.tostring(pt), text_color=color.white)
    table.cell(t1, 2, 3, pt > 0 ? str.tostring(pwr, '#.#') + "%" : "-", text_color=color.white)
    table.cell(t1, 0, 4, "W/L", text_color=color.white)
    table.cell(t1, 1, 4, str.tostring(wins) + "/" + str.tostring(loss), text_color=color.white)
    table.cell(t1, 2, 4, "", text_color=color.white)

pcr = ct > 0 ? pt / ct : 0
var t2 = table.new(position.top_right, 2, 6, border_width=1)

if barstate.islast
    table.cell(t2, 0, 0, "Pivot TF", text_color=color.white, bgcolor=color.gray)
    table.cell(t2, 1, 0, pivotTF, text_color=color.white)
    
    table.cell(t2, 0, 1, "Current Position", text_color=color.white)
    table.cell(t2, 1, 1, na(currentTrade) ? "No Position" : currentTrade, text_color=color.white,
         bgcolor=currentTrade == "BUY CALL" ? color.new(color.green, 70) : 
              currentTrade == "BUY PUT" ? color.new(color.red, 70) : na)
    
    table.cell(t2, 0, 2, "Entry Strike", text_color=color.white)
    table.cell(t2, 1, 2, na(entryStrike) ? "N/A" : str.tostring(entryStrike, '#.##'), text_color=color.white)
    
    table.cell(t2, 0, 3, "Method", text_color=color.white)
    table.cell(t2, 1, 3, strikeMethod, text_color=color.white)
    
    table.cell(t2, 0, 4, "Call/Put", text_color=color.white)
    table.cell(t2, 1, 4, 
         (na(callStrike) ? "N/A" : str.tostring(callStrike, '#.##')) + " / " + 
         (na(putStrike) ? "N/A" : str.tostring(putStrike, '#.##')), text_color=color.white)
    
    table.cell(t2, 0, 5, "PCR", text_color=color.white)
    pcol = pcr > 1 ? color.new(color.red, 70) : pcr < 1 ? color.new(color.green, 70) : color.gray
    table.cell(t2, 1, 5, ct > 0 ? str.tostring(pcr, '#.##') : "N/A", text_color=color.white, bgcolor=pcol,
         tooltip="PCR: >1 Bearish, <1 Bullish")

// Background color removed as requested

alertcondition(not na(newSignal) and newSignal == "BUY CALL", "New Call", "BUY CALL - Trend Following")
alertcondition(not na(newSignal) and newSignal == "BUY PUT", "New Put", "BUY PUT - Trend Following")
````

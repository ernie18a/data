# VK_MomentumEdge Pro

- url: https://www.tradingview.com/script/BHMK0EnS-VK-MomentumEdge-Pro/
- type: indicator
- pine_id: PUB;e93931b2de5b490fb8611852672c8a8d
- version: 1.0

## Description

//═══════════════════════════════════
//📊 MOMENTUM EDGE PRO - DESCRIPTION
//═══════════════════════════════════
//
//🎯 STAY WITH THE TREND, TRADE WITH CONFIDENCE
//
//This powerful indicator combines multiple proven strategies to keep you on
//the RIGHT SIDE of the market. No more guessing - let the trend be your friend!
//
////
//📈 WHAT'S INCLUDED:
//─────────────────────────────────────────
//✅ ATR MA & ATR (Blue and Red lines) - Your trend direction guide
//✅ ATR Trail (B1/S1) - Perfect for QUICK TRADES with trailing SL
//✅ SuperTrend (B2/S2) - Catch the BIG moves
//✅ ORB (Opening Range Breakout) - Day trading edge
//
//🎯 TRADING STRATEGIES - Four Powerful Methods
//════════════════════════════════
//📍 STRATEGY 1: SIGNAL-BASED TRADING (Recommended for Beginners)
//──────────────────────────────────────────────
//
//🟢 LONG TRADES (B1/B2 Signals)
// Entry: When B1 or B2 signal appears AFTER CANDLE CLOSE
// Stop Loss: Previous candle low OR recent swing low
// Target:
// • Conservative: 1:1 Risk-Reward
// • Moderate: 1:2 Risk-Reward
// • Aggressive: 1:3 to 1:4 Risk-Reward (after backtesting)
//
// 💡 Tip: B1 = Quick scalps | B2 = Swing trades
//
//🔴 SHORT TRADES (S1/S2 Signals)
// Entry: When S1 or S2 signal appears AFTER CANDLE CLOSE
// Stop Loss: Previous candle high OR recent swing high
// Target:
// • Conservative: 1:1 Risk-Reward
// • Moderate: 1:2 Risk-Reward
// • Aggressive: 1:3 to 1:4 Risk-Reward (after backtesting)
//
// 💡 Tip: S1 = Quick scalps | S2 = Swing trades
//
//────────────────────────────────────────────────────────
//
//📍 STRATEGY 2: ATR CROSSOVER SYSTEM (Trend Following)
//──────────────────────────────────────
//
//🟢 LONG SETUP
// Entry: When Blue ATR MA crosses ABOVE Red ATR line
// Stop Loss: Red ATR line (trailing stop)
// Exit: When Blue ATR MA crosses BELOW Red ATR line
//
// 💡 Best for: Capturing strong trends, ride the momentum
//
//🔴 SHORT SETUP
// Entry: When Blue ATR MA crosses BELOW Red ATR line
// Stop Loss: Red ATR line (trailing stop)
// Exit: When Blue ATR MA crosses ABOVE Red ATR line
//
// 💡 Best for: Riding downtrends with protected downside
//
//─────────────────────────────────────────────────────────
//
//📍 STRATEGY 3: OPENING RANGE BREAKOUT (Day Trading)
//──────────────────────────────────────
//
//🟢 LONG BREAKOUT
// Entry: Price breaks ABOVE white ORB high line (first 15 min range)
// Stop Loss: Below white ORB low line
// Target: 1:1 to 1:2 Risk-Reward
//
// 💡 Best Time: First 30-60 minutes after market open
//
//🔴 SHORT BREAKDOWN
// Entry: Price breaks BELOW white ORB low line (first 15 min range)
// Stop Loss: Above white ORB high line
// Target: 1:1 to 1:2 Risk-Reward
//
// 💡 Best Time: First 30-60 minutes after market open
//
//───────────────────────────────────────────────────────────
//
//📍 STRATEGY 4: MULTI-CONFIRMATION APPROACH (Advanced)
//────────────────────────────────────────
//
//🎯 HIGHEST PROBABILITY TRADES - Combine Multiple Signals:
//
//Example Long Setup:
// ✓ B1 / B2 signal appears on single candle
// ✓ Blue ATR MA is above Red ATR line (trend confirmation)
// ✓ Price breaks above ORB high (momentum confirmation)
// ✓ SuperTrend shows green (bullish confirmation)
//
// Entry: When 2-3 confirmations align
// Stop Loss: Most recent support level
// Target: 1:2 to 1:4 Risk-Reward
//
// 💡 Tip: More confirmations = Higher probability, but fewer trades
//
//──────────────────────────────────────────────────────────
//
//🔧 CUSTOMIZATION FOR YOUR TRADING STYLE
//═══════════════════════════════════════════════════════════
//
//Access Settings to Adjust:
//
//📊 For More Signals (More frequent, less reliable):
// • Decrease ATR Length (e.g., from 11 to 7-8)
// • Decrease SuperTrend Multiplier (e.g., from 2.2 to 1.8-2.0)
// • Decrease ATR Trail Multiplier (e.g., from 1.1 to 0.9-1.0)
//
//📊 For Fewer Signals (Less frequent, more reliable):
// • Increase ATR Length (e.g., from 11 to 14-17)
// • Increase SuperTrend Multiplier (e.g., from 2.2 to 2.5-3.0)
// • Increase ATR Trail Multiplier (e.g., from 1.1 to 1.3-1.5)
//
//📊 For Different Timeframes:
// • Lower Timeframes (1min-5min): Use tighter parameters
// • Higher Timeframes (1H-Daily): Use wider parameters
// • Backtest thoroughly before going live
//
//⚠️ IMPORTANT: Always backtest any parameter changes before using real money!
//
//⚠️ IMPORTANT DISCLAIMER & RISK WARNING
//══════════════════════════════
//
//📋 REGULATORY DISCLOSURE
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
//📅 Last Updated: 10 May 2026
//═══════════════════════
//
//💪 Trade Smart. Trade with Discipline. Stay on the Trend Side!
//══════════════════════════════════════════
//
//

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Combined Trading Suite

//@version=6
indicator('VK_MomentumEdge Pro', shorttitle='VK_MomentumEdgePro', overlay=true, max_labels_count=500)

//═══════════════════════════════════
//📊 MOMENTUM EDGE PRO - DESCRIPTION
//═══════════════════════════════════
//
//🎯 STAY WITH THE TREND, TRADE WITH CONFIDENCE
//
//This powerful indicator combines multiple proven strategies to keep you on 
//the RIGHT SIDE of the market. No more guessing - let the trend be your friend!
//
////
//📈 WHAT'S INCLUDED:
//─────────────────────────────────────────
//✅ ATR MA & ATR (Blue and Red lines) - Your trend direction guide
//✅ ATR Trail (B1/S1) - Perfect for QUICK TRADES with trailing SL
//✅ SuperTrend (B2/S2) - Catch the BIG moves
//✅ ORB (Opening Range Breakout) - Day trading edge
//
//🎯 TRADING STRATEGIES - Four Powerful Methods
//════════════════════════════════
//📍 STRATEGY 1: SIGNAL-BASED TRADING (Recommended for Beginners)
//──────────────────────────────────────────────
//
//🟢 LONG TRADES (B1/B2 Signals)
//   Entry: When B1 or B2 signal appears AFTER CANDLE CLOSE
//   Stop Loss: Previous candle low OR recent swing low
//   Target: 
//   • Conservative: 1:1 Risk-Reward
//   • Moderate: 1:2 Risk-Reward
//   • Aggressive: 1:3 to 1:4 Risk-Reward (after backtesting)
//   
//   💡 Tip: B1 = Quick scalps | B2 = Swing trades
//
//🔴 SHORT TRADES (S1/S2 Signals)
//   Entry: When S1 or S2 signal appears AFTER CANDLE CLOSE
//   Stop Loss: Previous candle high OR recent swing high
//   Target:
//   • Conservative: 1:1 Risk-Reward
//   • Moderate: 1:2 Risk-Reward
//   • Aggressive: 1:3 to 1:4 Risk-Reward (after backtesting)
//   
//   💡 Tip: S1 = Quick scalps | S2 = Swing trades
//
//────────────────────────────────────────────────────────
//
//📍 STRATEGY 2: ATR CROSSOVER SYSTEM (Trend Following)
//──────────────────────────────────────
//
//🟢 LONG SETUP
//   Entry: When Blue ATR MA crosses ABOVE Red ATR line
//   Stop Loss: Red ATR line (trailing stop)
//   Exit: When Blue ATR MA crosses BELOW Red ATR line
//   
//   💡 Best for: Capturing strong trends, ride the momentum
//
//🔴 SHORT SETUP
//   Entry: When Blue ATR MA crosses BELOW Red ATR line
//   Stop Loss: Red ATR line (trailing stop)
//   Exit: When Blue ATR MA crosses ABOVE Red ATR line
//   
//   💡 Best for: Riding downtrends with protected downside
//
//─────────────────────────────────────────────────────────
//
//📍 STRATEGY 3: OPENING RANGE BREAKOUT (Day Trading)
//──────────────────────────────────────
//
//🟢 LONG BREAKOUT
//   Entry: Price breaks ABOVE white ORB high line (first 15 min range)
//   Stop Loss: Below white ORB low line
//   Target: 1:1 to 1:2 Risk-Reward
//   
//   💡 Best Time: First 30-60 minutes after market open
//
//🔴 SHORT BREAKDOWN
//   Entry: Price breaks BELOW white ORB low line (first 15 min range)
//   Stop Loss: Above white ORB high line
//   Target: 1:1 to 1:2 Risk-Reward
//   
//   💡 Best Time: First 30-60 minutes after market open
//
//───────────────────────────────────────────────────────────
//
//📍 STRATEGY 4: MULTI-CONFIRMATION APPROACH (Advanced)
//────────────────────────────────────────
//
//🎯 HIGHEST PROBABILITY TRADES - Combine Multiple Signals:
//
//Example Long Setup:
//   ✓ B1 / B2 signal appears on single candle
//   ✓ Blue ATR MA is above Red ATR line (trend confirmation)
//   ✓ Price breaks above ORB high (momentum confirmation)
//   ✓ SuperTrend shows green (bullish confirmation)
//   
//   Entry: When 2-3 confirmations align
//   Stop Loss: Most recent support level
//   Target: 1:2 to 1:4 Risk-Reward
//   
//   💡 Tip: More confirmations = Higher probability, but fewer trades
//
//──────────────────────────────────────────────────────────
//
//🔧 CUSTOMIZATION FOR YOUR TRADING STYLE
//═══════════════════════════════════════════════════════════
//
//Access Settings to Adjust:
//
//📊 For More Signals (More frequent, less reliable):
//   • Decrease ATR Length (e.g., from 11 to 7-8)
//   • Decrease SuperTrend Multiplier (e.g., from 2.2 to 1.8-2.0)
//   • Decrease ATR Trail Multiplier (e.g., from 1.1 to 0.9-1.0)
//
//📊 For Fewer Signals (Less frequent, more reliable):
//   • Increase ATR Length (e.g., from 11 to 14-17)
//   • Increase SuperTrend Multiplier (e.g., from 2.2 to 2.5-3.0)
//   • Increase ATR Trail Multiplier (e.g., from 1.1 to 1.3-1.5)
//
//📊 For Different Timeframes:
//   • Lower Timeframes (1min-5min): Use tighter parameters
//   • Higher Timeframes (1H-Daily): Use wider parameters
//   • Backtest thoroughly before going live
//
//⚠️ IMPORTANT: Always backtest any parameter changes before using real money!
//
//⚠️ IMPORTANT DISCLAIMER & RISK WARNING
//══════════════════════════════
//
//📋 REGULATORY DISCLOSURE
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
//  trading psychology before trading with real money.
//
//2. START SMALL - Begin with paper trading or very small positions until you 
//  develop confidence and consistency.
//
//3. RISK MANAGEMENT - Never risk more than 1-2% of your capital on a single trade.
//
//4. USE STOP LOSSES - Always use stop losses. This indicator provides trailing 
//  stop levels - USE THEM!
//
//5. COMBINE METHODS - Use multiple forms of analysis (fundamental, technical, 
//  sentiment) along with this indicator.
//
//6. JOURNAL YOUR TRADES - Keep a detailed trading journal to learn from both 
//  wins and losses.
//
//7. MANAGE EMOTIONS - Follow your trading plan. Don't chase trades or revenge 
//  trade after losses.
//
//8. TEST BEFORE TRADING - Thoroughly backtest and forward test any settings 
//  before using real money.
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
//══════════════════════════════════════════
//
//


// ════════════════════════════════════════════════════════════════════════════
// VKPD ALPHA - ATR MA & ATR (CODE 1)
// ════════════════════════════════════════════════════════════════════════════

pm_group = '═══ 🎯 ATR EXPLORER ═══'
pm_enabled = input.bool(true, 'Enable ATR', group=pm_group)
pm_periods = input.int(11, 'ATR Length', group=pm_group)
pm_mult = input.float(3.0, 'ATR Multiplier', step=0.1, group=pm_group)
pm_mav = input.string('EMA', 'MA Type', options=['SMA', 'EMA', 'WMA'], group=pm_group)
pm_length = input.int(11, 'MA Length', minval=1, group=pm_group)
pm_changeATR = input.bool(true, 'Change ATR Calculation', group=pm_group)

pm_atr2 = ta.sma(ta.tr, pm_periods)
pm_atr = pm_changeATR ? ta.atr(pm_periods) : pm_atr2

pm_getMA(src, len) =>
    if pm_mav == 'SMA'
        ta.sma(src, len)
    else if pm_mav == 'EMA'
        ta.ema(src, len)
    else
        ta.wma(src, len)

pm_MAvg = pm_getMA(hl2, pm_length)

var float pm_longStop = na
var float pm_shortStop = na
var int pm_dir = 1

pm_longStop := pm_MAvg - pm_mult * pm_atr
pm_longStopPrev = nz(pm_longStop[1], pm_longStop)
pm_longStop := pm_MAvg > pm_longStopPrev ? math.max(pm_longStop, pm_longStopPrev) : pm_longStop

pm_shortStop := pm_MAvg + pm_mult * pm_atr
pm_shortStopPrev = nz(pm_shortStop[1], pm_shortStop)
pm_shortStop := pm_MAvg < pm_shortStopPrev ? math.min(pm_shortStop, pm_shortStopPrev) : pm_shortStop

pm_dir := nz(pm_dir[1], pm_dir)
pm_dir := pm_dir == -1 and pm_MAvg > pm_shortStopPrev ? 1 : pm_dir == 1 and pm_MAvg < pm_longStopPrev ? -1 : pm_dir

pm_ATR = pm_dir == 1 ? pm_longStop : pm_shortStop

plot(pm_enabled ? pm_MAvg : na, 'ATR MA', color.new(#0585E1, 0), 2)
plot(pm_enabled ? pm_ATR : na, 'ATR', color.new(#ff1100, 0), 2)

bgcolor(pm_enabled and pm_dir == 1 ? color.new(#00ff00, 97) : 
     pm_enabled and pm_dir == -1 ? color.new(#ff0000, 97) : na)

// ════════════════════════════════════════════════════════════════════════════
// PHOENIX - SUPERTREND (CODE 2)
// ════════════════════════════════════════════════════════════════════════════

st_group = '══ 🌟 SUPERTREND ══'
st_enabled = input.bool(true, 'Enable SuperTrend', group=st_group)
st_Periods = input.int(22, "ATR Period", group=st_group)
st_src = input(hl2, "Source", group=st_group)
st_Multiplier = input.float(2.2, "ATR Multiplier", step=0.1, group=st_group)
st_changeATR = input.bool(true, "Change ATR Calculation", group=st_group)
st_showsignals = input.bool(true, "Show Buy/Sell Signals", group=st_group)

st_atr2 = ta.sma(ta.tr, st_Periods)
st_atr = st_changeATR ? ta.atr(st_Periods) : st_atr2
st_up = st_src - st_Multiplier * st_atr
st_up1 = nz(st_up[1], st_up)
st_up := close[1] > st_up1 ? math.max(st_up, st_up1) : st_up
st_dn = st_src + st_Multiplier * st_atr
st_dn1 = nz(st_dn[1], st_dn)
st_dn := close[1] < st_dn1 ? math.min(st_dn, st_dn1) : st_dn

var int st_trend = 1
st_trend := nz(st_trend[1], st_trend)
st_trend := st_trend == -1 and close > st_dn1 ? 1 : st_trend == 1 and close < st_up1 ? -1 : st_trend

st_buySignal = st_trend == 1 and st_trend[1] == -1
st_sellSignal = st_trend == -1 and st_trend[1] == 1

plot(st_enabled and st_trend == 1 ? st_up : na, "Up", style=plot.style_linebr, linewidth=2, color=color.rgb(0, 255, 8))
plot(st_enabled and st_trend == -1 ? st_dn : na, "Down", style=plot.style_linebr, linewidth=2, color=color.rgb(255, 0, 0))

plotshape(st_enabled and st_buySignal and st_showsignals, "Buy", text="B2", location=location.belowbar, style=shape.labelup, size=size.small, color=color.new(#fffb00, 0), textcolor=color.black)
plotshape(st_enabled and st_sellSignal and st_showsignals, "Sell", text="S2", location=location.abovebar, style=shape.labeldown, size=size.small, color=color.new(#fffb00, 0), textcolor=color.black)

bgcolor(st_enabled ? (st_trend == 1 ? color.new(color.green, 95) : color.new(color.red, 95)) : na)

// ════════════════════════════════════════════════════════════════════════════
// PHOENIX - ATR TRAILING STOPS (CODE 2)
// ════════════════════════════════════════════════════════════════════════════

atr_group = '══ 🎯 ATR TRAIL ══'
atr_enabled = input.bool(true, 'Enable ATR Trail', group=atr_group)
atrLookback = input.int(22, 'ATR Lookback Period', group=atr_group)
atrMultiplier = input.float(1.1, 'ATR Multiplier', step=0.1, minval=0.5, maxval=4, group=atr_group)
atrTrailMode = input.string('Trailing', 'Trail Mode', options=['Running', 'Trailing'], group=atr_group)
atrFlipInput = input.string('Close', 'Flip Trail on:', options=['Close', 'Wick'], group=atr_group)
atr_showsignals = input.bool(true, "Show Buy/Sell Signals", group=atr_group)
atrBodyPercent = input.int(100, 'Percentage of Body', minval=0, maxval=200, step=10, group=atr_group)
atrWickPercent = input.int(100, 'Percentage of Wick', minval=0, maxval=200, step=10, group=atr_group)
atrSmoothingMode = input.string('RMA', 'ATR Smoothing', options=['RMA', 'SMA', 'EMA', 'WMA'], group=atr_group)

f_ma(_source, _length, _mode) =>
    _mode == 'RMA' ? ta.rma(_source, _length) : _mode == 'SMA' ? ta.sma(_source, _length) : _mode == 'EMA' ? ta.ema(_source, _length) : ta.wma(_source, _length)

float atrBodyTrueRange = math.max(math.abs(open - close), math.abs(open - close[1]), math.abs(close - close[1]))
float atrWickTrueRange = high - math.max(open, close) + math.min(open, close) - low
float atrPercentAdjustedTrueRange = atrBodyTrueRange * (atrBodyPercent / 100) + atrWickTrueRange * (atrWickPercent / 100)

float atrValue = f_ma(atrPercentAdjustedTrueRange, atrLookback, atrSmoothingMode)
float atrMultiplied = atrValue * atrMultiplier

float atrLow = low - atrMultiplied
float atrHigh = high + atrMultiplied

f_trail(_source, _trail, _direction) =>
    _direction == 'down' and _source >= _trail ? _trail : _direction == 'up' and _source <= _trail ? _trail : _source

var float trailAtrLong = na
var float trailAtrShort = na

if na(trailAtrLong)
    trailAtrLong := atrLow
if na(trailAtrShort)
    trailAtrShort := atrHigh

trailAtrLong := f_trail(atrLow, trailAtrLong, 'up')
trailAtrShort := f_trail(atrHigh, trailAtrShort, 'down')

f_flip(_flipInput, _longTrail, _shortTrail, _longReset, _shortReset) =>
    var bool _isLong = true
    var bool _isShort = true
    
    float _flipLongSource = _flipInput == 'Close' ? close : high
    float _flipShortSource = _flipInput == 'Close' ? close : low
    
    bool prevIsShort = _isShort
    bool prevIsLong = _isLong
    
    bool _flipLongNow = prevIsShort and _flipLongSource > _shortTrail
    bool _flipShortNow = prevIsLong and _flipShortSource < _longTrail
    
    if _flipShortNow and _flipLongNow
        _flipLongNow := close > _longTrail
        _flipShortNow := not _flipLongNow
    
    if _flipLongNow
        _isLong := true
        _isShort := false
    else if _flipShortNow
        _isLong := false
        _isShort := true
    
    float _longTrailOutput = _isLong and not prevIsLong ? _longReset : _longTrail
    float _shortTrailOutput = _isShort and not prevIsShort ? _shortReset : _shortTrail
    
    [_longTrailOutput, _shortTrailOutput, _isLong ? _longTrailOutput : na, _isShort ? _shortTrailOutput : na, _flipLongNow, _flipShortNow]

[trailAtrLong2, trailAtrShort2, trailAtrLongPlot, trailAtrShortPlot, atr_buySignal, atr_sellSignal] = f_flip(atrFlipInput, trailAtrLong, trailAtrShort, atrLow, atrHigh)

trailAtrLong := trailAtrLong2
trailAtrShort := trailAtrShort2

plot(atr_enabled and atrTrailMode == 'Running' ? atrLow : na, 'Running Low', color=color.new(#1900ff, 60), linewidth=1)
plot(atr_enabled and atrTrailMode == 'Running' ? atrHigh : na, 'Running High', color=color.new(#2600ff, 60), linewidth=1)

plot(atr_enabled and atrTrailMode == 'Trailing' ? trailAtrLongPlot : na, 'Long', color=color.new(#fc0000, 50), style=plot.style_linebr, linewidth=3)
plot(atr_enabled and atrTrailMode == 'Trailing' ? trailAtrLongPlot : na, 'Long2', color=color.rgb(255, 0, 0), style=plot.style_linebr, linewidth=1)

plot(atr_enabled and atrTrailMode == 'Trailing' ? trailAtrShortPlot : na, 'Short', color=color.new(#f30101, 0), style=plot.style_linebr, linewidth=3)
plot(atr_enabled and atrTrailMode == 'Trailing' ? trailAtrShortPlot : na, 'Short2', color=color.rgb(255, 0, 0), style=plot.style_linebr, linewidth=1)

plotshape(atr_enabled and atr_buySignal and atr_showsignals, 'ATR Buy', text='B1', location=location.belowbar, 
     color=color.new(#1900fc, 0), style=shape.labelup, textcolor=color.white, size=size.tiny)

plotshape(atr_enabled and atr_sellSignal and atr_showsignals, 'ATR Sell', text='S1', location=location.abovebar, 
     color=color.new(#1900fc, 0), style=shape.labeldown, textcolor=color.white, size=size.tiny)

// ════════════════════════════════════════════════════════════════════════════
// PHOENIX - ORB (CODE 2)
// ════════════════════════════════════════════════════════════════════════════

orb_group = '══ 📊 ORB ══'
orb_enabled = input.bool(true, 'Enable ORB', group=orb_group)
inputMax = input.int(15, "ORB Time (minutes)", group=orb_group)
sess = input.session("0915-0930", "Session Time", group=orb_group)

t = time(timeframe.period, sess + ":1234567")
hide = timeframe.isintraday and timeframe.multiplier <= inputMax
in_session = not na(t)
is_first = in_session and not in_session[1]

var float orb_high = na
var float orb_low = na

if is_first
    orb_high := high
    orb_low := low
else if not na(orb_high)
    orb_high := orb_high[1]
    orb_low := orb_low[1]

if high > orb_high and in_session and not na(orb_high)
    orb_high := high
if low < orb_low and in_session and not na(orb_low)
    orb_low := low

plot(orb_enabled and hide ? orb_high : na, "ORB High", style=plot.style_line, color=orb_high[1] != orb_high ? na : color.white, linewidth=1)
plot(orb_enabled and hide ? orb_low : na, "ORB Low", style=plot.style_line, color=orb_low[1] != orb_low ? na : color.white, linewidth=1)

// ════════════════════════════════════════════════════════════════════════════
// ALERTS
// ════════════════════════════════════════════════════════════════════════════

alertcondition(st_buySignal and st_enabled, 'SuperTrend Buy', 'SuperTrend Buy (B2)!')
alertcondition(st_sellSignal and st_enabled, 'SuperTrend Sell', 'SuperTrend Sell (S2)!')
alertcondition(atr_buySignal and atr_enabled, 'ATR Trail Buy', 'ATR Trail Buy (B1)!')
alertcondition(atr_sellSignal and atr_enabled, 'ATR Trail Sell', 'ATR Trail Sell (S1)!')
````

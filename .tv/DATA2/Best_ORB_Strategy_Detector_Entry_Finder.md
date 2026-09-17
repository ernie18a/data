<!-- tradingview-pine-id: PUB;3485dd05958b49af932894a70734b7ca -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Best ORB Strategy Detector + Entry Finder

Source: https://www.tradingview.com/script/z952ZVGe-Best-ORB-Strategy-Detector-Entry-Finder/

## Description

Best ORB Detector + Entry Finder

An Opening Range Breakout (ORB) indicator focused on one thing: find the opening range, catch the break, and manage the trade with clear entry, stop, and targets.

Most ORB tools only draw two lines and leave the rest to you. This one goes further — session selection, a single clean ORB stage, breakout/retest logic, optional filters, and full trade management on the chart.

The idea is simple: the first minutes of a session often define support and resistance for the day. When price breaks that range with conviction, moves can travel. When it breaks without conviction, they fail. This script helps you see both.
Built by the Xcelerate Trade team.

What makes it different

One ORB at a time
Instead of stacking four ranges on the chart, you pick one stage: ORB 5M, 15M, 30M, or 60M. Cleaner chart, clearer plan.

Session-aware
Choose Asia, London, or New York. The opening range is built from that session’s start — not a generic “market open” that may not match how you trade.

Entry the way you actually trade

Breakout — enter after the range breaks
Retest + Rejection — wait for price to come back to the ORB level, reject, then enter
Both — allow either path
This matches how many discretionary ORB traders work: the break is the alert, the retest is often the entry.

Trade management built in
When a setup triggers, you get entry, classic ORB stop (beyond the opposite side of the range, with optional buffer), and take-profit levels from 1R to 6R. Lines extend forward until stop or the last enabled target is hit.

Optional quality filters
Volume and FVG filters are available and off by default, so you start with raw price action and tighten only when you need fewer, cleaner signals.

Core features

1. ORB stages (pick one)

ORB 5M — fastest, more noise
ORB 15M — balanced, most common day-trading window
ORB 30M — slower, more confirmed
ORB 60M — slowest, strongest filter
During the window, the script tracks high and low. When the window completes, those levels become your ORB high and low.

2. Breakout detection
Labels appear when price closes outside the range (body close or wick, depending on your setting). Signals are confirmed on close — no repainting.

3. Retest and cycle tracking
After a breakout, if price returns to the ORB level, you can get a retest label. Useful if you missed the first move, or if you wait for retest entries by design.
Signal mode: First Only (cleaner) or Track Cycles (breakout → retest → re-break).

4. Failed / weak breaks
Settings like breakout buffer, min bars outside, and min distance for retest help filter tiny wiggles and half-hearted breaks.

5. TP / SL lines

Entry
Stop (classic ORB stop + buffer %)
TP1 (1R) through TP6 (6R)
Enable only the targets you use. When the last enabled TP or the stop is hit, lines freeze.

6. Info panel
Bottom-left dashboard with active ORB, range size, volatility, volume status (when the filter is on), ORB status, and the live setup (entry / stop / TPs / R:R). Panel size and theme are adjustable.

Volume filter

Many ORB fakeouts happen on thin volume. When Enable Volume Filter is on, a breakout needs volume confirmation.

Modes:

Increasing — breakout bar volume higher than the previous bar (Academy-style “volume in expansion”)
Above Average — volume at least X times the volume MA
Both — stricter: rising and above average
Use this on stocks and futures where volume is meaningful. On some CFDs, volume can be weak or synthetic — if signals disappear, turn the filter off or loosen the mode.

FVG filter (Fair Value Gap)

FVGs are short inefficiencies left by strong momentum candles. When Enable FVG Filter is on, breakouts are preferred when they interact with a nearby gap. You can also Show FVG Boxes without forcing the filter, just for context.

Why it helps: breaks through an FVG often carry more follow-through than breaks into empty air.
FVG Proximity controls how close the gap must be to count.

Start without FVG. Add it when you want fewer, higher-conviction setups.

How to use it

Simple start

Chart: 5m or 15m on a liquid symbol
Select Session (e.g. New York)
Select ORB (e.g. ORB 15M)
Leave filters off at first
Watch breakout / retest labels and the dashboard for entry, stop, and targets
Tighter setup

Entry Mode = Retest + Rejection
Volume Filter = Increasing or Both
FVG Filter on if you want institutional-style confirmation
Enable the TPs you actually take (many traders use TP1 + TP2, and leave TP3–TP6 for runners)
Suggested take-profit approach

Conservative: full exit at TP1
Balanced: partial at TP1, rest at TP2
Aggressive: trail toward TP3–TP6 on strong trend days
After TP1, many traders move stop to breakeven.

Tips

ORB works best on liquid instruments during the real session
The first hour matters most — that is when the range forms and the first breaks appear
Not every day is an ORB day; skip chop
Filters reduce noise but also reduce frequency — adjust to your style
Always use a stop; the R-multiple targets only make sense if risk is defined
Limitations

Intraday tool — not meant for daily/weekly charts
Needs a clear session definition
Can still false-break in ranges; filters help but do not remove risk
Volume quality depends on the symbol/feed
Indicator = decision aid, not a fully automated strategy
FAQ (short)

Why no signals? Check timeframe (intraday), session hours, breakout detection on, and whether filters are blocking you.

Best ORB stage? ORB 15M is a good default. 5M is faster/noisier; 30M/60M are slower/cleaner.

Should I enable all filters? No. Start clean, then add Volume first, then FVG if you still want fewer trades.

First Only vs Track Cycles? First Only = one main idea per direction. Track Cycles = more opportunities, busier chart.

Disclaimer
For education and research only. Not financial advice. Trading involves risk of loss. Paper trade first. Manage risk. Decisions are yours.

---

## Source Code

````pine
//@version=6
indicator("Best ORB Strategy Detector + Entry Finder", shorttitle = "Best ORB Detector Xcelerate", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=300)

// ====================================== DISCLAIMER & INFO =========================================
//
// DISCLAIMER: This indicator is for educational and informational purposes only.
// It does not constitute financial advice. Trading involves substantial risk of loss.
// Past performance does not guarantee future results. Always do your own research.
//
// DESCRIPTION:
// Dynamic Opening Range Breakout (ORB) indicator with multi-stage ranges (5/15/30/60 min).
// Identifies breakouts, retests (+ optional entry on retest/rejection), and failed breaks.
// Advanced filters: volume, trend, FVG, pullback (wired into signal logic).
// Includes position sizing, risk management, and higher timeframe bias analysis.
//
// FEATURES:
// • Multi-stage ORB levels (5, 15, 30, 60 minutes)
// • Breakout and retest detection with cycle counting
// • Volume, trend, and HTF bias filters
// • Position sizing with risk management
// • Target/stop-loss visualization
// • Real-time dashboard with trade parameters
//
// BEST PRACTICES: 
// • Recommended for liquid stocks with >1M daily volume
// • Best on 5-minute charts during regular trading hours
// • Paper trade first to understand the signals
// • Use with proper risk management (1-2% risk per trade)
// • Combine with overall market analysis
//
// LIMITATIONS:
// • May produce dangerous signals in choppy/ranging markets
// • Requires clean data feed for accurate ORB calculation
// • Not suitable for all market conditions
// • Performance varies by instrument and timeframe
//
// CREDITS:
// • Based on Opening Range Breakout concepts by Mark Fisher
// • Enhanced with modern technical analysis techniques
// • Original ORB concepts / base by OrenLuxy (Luxy Big Beautiful ORB)
// • Extended for Xcelerate Trade Academy: Asia/London/NY sessions, retest entry, wired filters
// • Version: v6 
//

// =========================================== TYPE DEFINITIONS ======================================

type ORBData
    string name          
    int    minutes       
    float  high         
    float  low          
    float  mid          
    float  orbRange     
    bool   isEnabled     
    bool   isBuilding    
    bool   isComplete    
    int    completionBar 
    bool   breakoutUp    
    bool   breakoutDown  
    int    breakoutBar   
    float  breakoutLevel 
    int    cyclesUp      
    int    cyclesDown    
    box    orbBox        
    line   highLine      
    line   lowLine       
    line   midLine       
    label  edgeLabel     
    color  orbColor      
    int    lineWidth     
    string lineStyle     

// ================================================ GROUPS ===========================================

grp_colors   = "🎨 ORB COLORS ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬"
grp_session  = "⏰ SESSION SETTINGS ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬"
grp_breakout = "⚡ BREAKOUT DETECTION ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬"
grp_volume   = "📊 VOLUME FILTER (Xcelerate) ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬"
grp_targets  = "🎯 TARGETS & RISK ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬"
grp_FVG      = "↩️ FVG FILTER ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬"
grp_lines    = "📍 TP/SL LINES ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬"
grp_dash     = "📊 DASHBOARD ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬"

// ============================================ CONSTANTS ============================================

LABEL_OFFSET_ATR_MULTIPLIER = 0.8  // 0.8× ATR distance from high/low
LABEL_OFFSET_BARS = 2              // Bars ahead for edge labels (keeps them visible)

MAX_BARS_FAILED_BREAK = 5  // Maximum bars to consider a retest as "failed break" instead of committed breakout
// Edge labels (ORB5/15/30/60 at high/low) removed from UI — off for cleaner chart
bool showEdgeLabels = false
string labelFormat = "Simple"  // fixed — removed from Inputs menu
string labelSize = "Small"  // fixed — All Label Size removed from Inputs menu

selectORB = input.string("ORB 5M", "Select ORB", options=["ORB 5M", "ORB 15M", "ORB 30M", "ORB 60M"], group=grp_colors, tooltip="Choose ONE Opening Range stage to trade (same idea as Select Session)\n\nORB 5M: First 5 minutes — fastest, more noise\nORB 15M: First 15 minutes — balanced\nORB 30M: First 30 minutes — slower, more confirmed\nORB 60M: First 60 minutes — slowest, strongest filter\n\nOnly the selected ORB is built and used for breakout / entry.")
orbHighColor = input.color(color.green, "ORB High Line", inline="orbLines", group=grp_colors, tooltip="Color of the top ORB boundary (High)")
orbLowColor = input.color(color.red, "ORB Low Line", inline="orbLines", group=grp_colors, tooltip="Color of the bottom ORB boundary (Low)")

sessionMode = input.string("New York", "Select Session", options=["Asia", "London", "New York"], group=grp_session, tooltip="Choose which session ORB to trade (America/New_York timezone)\n\nAsia - default 20:00-05:00 EST\nLondon - default 03:00-12:00 EST\nNew York - default 09:30-16:00 EST\n\nORB 5/15/30/60 stages count from the selected session start.")
S_ASIA = input.session("2000-0500", "Asia Session [20:00-05:00 EST]", group=grp_session, tooltip="Editable Asia window. ORB starts at BEGIN time.")
S_LONDON = input.session("0300-1200", "London Session [03:00-12:00 EST]", group=grp_session, tooltip="Editable London window. ORB starts at BEGIN time.")
S_NY = input.session("0930-1600", "New York Session [09:30-16:00 EST]", group=grp_session, tooltip="Editable New York window. ORB starts at BEGIN time.")

enableBreakout = input.bool(true, "Enable Breakout Detection", inline = "Show", group=grp_breakout)
showBreakLabels = input.bool(true, "Show Breakout Labels", group=grp_breakout, inline = "Show", tooltip="Detect and label breakouts above ORB High or below ORB Low\n\nON: Shows breakout labels when price exits ORB range\nOFF: Only displays ORB levels without signals\n\nBreakouts detected on CLOSE (no repaint)")
enableRetest = input.bool(true, "Show Retest Labels", group=grp_breakout, inline="retest", tooltip="Show labels when price returns to ORB after breakout\n\nRETEST = Price broke out, then came back to test ORB level\n\nUSEFUL FOR:\n• Re-entry opportunities\n• Confirming support/resistance\n• Failed breakout detection\n\nON: Shows retest labels\nOFF: Only shows initial breakout")

entryMode = input.string("Retest + Rejection", "Entry Mode", options=["Breakout", "Retest + Rejection", "Both"], group=grp_breakout, tooltip="When to create ENTRY / TP / SL\n\nBREAKOUT: Enter on next bar open after ORB breakout (classic)\n\nRETEST + REJECTION (Xcelerate Academy): Breakout is NOT the entry. Wait for retest of ORB level, then rejection close back in breakout direction, then entry next open.\n\nBOTH: Allow entry on breakout AND on retest+rejection")
breakoutConfirm = input.string("Body Close", "Breakout Confirm", options=["Body Close", "Wick"], group=grp_breakout, tooltip="How to confirm a breakout beyond ORB High/Low (on the ORB-stage candle)\n\nBODY CLOSE (recommended):\n• UP: candle CLOSE must finish ABOVE ORB High\n• DOWN: candle CLOSE must finish BELOW ORB Low\n• Stronger confirmation, fewer false breaks\n\nWICK:\n• UP: candle HIGH (wick) pierces ABOVE ORB High\n• DOWN: candle LOW (wick) pierces BELOW ORB Low\n• Earlier / more sensitive — close can still be back inside ORB")
signalMode = input.string("Track Cycles", "Signal Mode", options=["First Only", "Track Cycles"], group=grp_breakout, inline="mode", tooltip="How many breakout signals to show per day\n\nFIRST ONLY:\n• Shows only the FIRST breakout in each direction\n• One UP signal, one DOWN signal max per day\n• Clean chart, less noise\n• Good for: Swing traders, position traders\n\nTRACK CYCLES:\n• Tracks Breakout → Retest → Re-breakout cycles\n• Multiple signals as price oscillates\n• Detects momentum returns\n• Good for: Active traders, scalpers\n\nRECOMMENDED: Track Cycles")
maxCycles = input.int(6, "Max Cycles", minval=1, maxval=10, group=grp_breakout, inline="mode", tooltip="Maximum cycles to track when Signal Mode = Track Cycles\n\nCYCLE = Breakout → Retest → Re-breakout sequence\n\n1-2 cycles: Clean chart, fewer signals\n4-6 cycles: Balanced (recommended)\n8-10 cycles: Very active, may clutter chart\n\nIGNORED when Signal Mode = First Only")
breakoutBuffer = input.float(0.2, "Breakout Buffer (%)", minval=0, maxval=5, step=0.1, group=grp_breakout, inline="buffer", tooltip="Extra distance required beyond ORB level for breakout\n\nPREVENTS: False breakouts from tiny penetrations\n\nHOW IT WORKS:\n• UP: Price must close ABOVE (ORB High + buffer%)\n• DOWN: Price must close BELOW (ORB Low - buffer%)\n\nRECOMMENDATIONS:\n• 0.0% = Exact level (sensitive, more signals)\n• 0.1% = Tiny buffer (recommended)\n• 0.3% = Moderate filter\n• 0.5%+ = Conservative (fewer signals)\n\nHigher = fewer but stronger breakouts")
retestBuffer = input.float(0.0, "Retest Buffer (%)", minval=0, maxval=5, step=0.1, group=grp_breakout, inline="buffer", tooltip="Tolerance for retest detection\n\nALLOWS: Price to slightly penetrate ORB during retest\n\nHOW IT WORKS:\n• After UP breakout: Retest if price returns to ORB High ± buffer\n• After DOWN breakout: Retest if price returns to ORB Low ± buffer\n\nRECOMMENDATIONS:\n• 0.0% = Must touch exact level (strict)\n• 0.1-0.2% = Slight tolerance (recommended)\n• 0.3-0.5% = Generous tolerance\n\nHigher = more retests detected")
minRetestDistancePct = input.float(0.5, "Min Distance for Retest (%)", minval=0.5, maxval=10, step=0.5, group=grp_breakout, tooltip="How far price must travel away from ORB before retest is valid\n\nPREVENTS: Labeling tiny bounces as 'retests'\n\nEXAMPLE: ORB High = $10.00, Distance = 2%\n• Price breaks to $10.20 (2% away) ✓ Valid\n• Price returns to $10.00 → RETEST LABEL\n• If only went to $10.05 (0.5% away) ✗ Not valid\n\nRECOMMENDATIONS:\n• 0.5% = Very sensitive (many retests)\n• 2.0% = Balanced (filters noise) ⭐\n• 3.0%+ = Only strong moves\n\nHigher = fewer but more meaningful retests")
minBarsOutside = input.int(2, "Min Bars Outside ORB", minval=1, maxval=10, group=grp_breakout, tooltip="How many bars price must stay outside ORB for 'committed' breakout\n\nPREVENTS: Labeling quick failures as breakouts\n\nEXAMPLE: Min Bars = 2\n• Bar 1: Price breaks above ORB High\n• Bar 2: Still above ORB High ✓\n• Bar 3: Returns inside → Now can show retest\n\nIf returned on Bar 2 → Shows 'FAILED BREAK' instead\n\nRECOMMENDATIONS:\n• 1 bar = Aggressive (more signals, more failures)\n• 2 bars = Balanced (recommended) ⭐\n• 3-4 bars = Conservative (only strong moves)\n\nHigher = fewer but stronger breakouts")
minPullbackPct = input.float(0.3, "Min Pullback for Re-break (%)", minval=0.1, maxval=2, step=0.1, group=grp_breakout, tooltip="How far price must pull back before detecting new breakout\n\nPREVENTS: Too many signals from small wiggles\n\nEXAMPLE: Last breakout at $10.00\n• Price reaches $10.50\n• Must pull back to $10.35 (0.3% = $0.15) before new breakout counted\n\nRECOMMENDED:\n• 0.3% = Balanced (recommended) ⭐\n• 0.5% = Less sensitive\n• 1.0% = Very selective")

// Xcelerate Academy: breakout pe volum în creștere
enableVolumeFilter = input.bool(false, "Enable Volume Filter", group=grp_volume, tooltip="Xcelerate Trade strategy filter\n\nBreakout is valid only when volume confirms the move.\nWithout volume, many breaks are fakeouts.\n\nON: require volume confirmation\nOFF (default): accept all breakouts")
volumeMode = input.string("Increasing", "Volume Mode", options=["Increasing", "Above Average", "Both"], group=grp_volume, tooltip="How to confirm volume (Academy = Increasing)\n\nINCREASING:\n• Breakout candle volume > previous candle\n• Matches „volum în creștere” from Xcelerate strategy\n\nABOVE AVERAGE:\n• Volume ≥ Volume MA × multiplier\n\nBOTH:\n• Must be increasing AND above average (stricter)")
volumeMaLength = input.int(20, "Volume MA Length", minval=5, maxval=100, group=grp_volume, inline="volma", tooltip="Used when Volume Mode = Above Average or Both\n\n20 = balanced (recommended)")
volumeMultiplier = input.float(1.2, "Min × Avg", minval=1.0, maxval=3.0, step=0.1, group=grp_volume, inline="volma", tooltip="Minimum volume vs average\n\n1.2× = slightly above average (recommended)\n1.5× = stronger filter\n2.0× = very selective")

enableFVGFilter = input.bool(false, "Enable FVG Filter  | ", group=grp_FVG, inline="fvg1")
showFVG = input.bool(false, "Show FVG Boxes", group=grp_FVG, inline="fvg1", tooltip="Fair Value Gap Filter\n\nRequires breakout through FVG for confirmation\n\nFVG = Price gap from strong momentum\nON: Only signals with FVG\nOFF: All signals")
maxFVGtoKeep = input.int(5, "Max FVG", minval=1, maxval=20, inline="fvg2", group=grp_FVG)
fvgProximity = input.float(2.0, "FVG Proximity", minval=0.5, maxval=5.0, inline="fvg2", step=0.5, group=grp_FVG, tooltip="How close to FVG?\n\n1.0 = Must be IN the FVG\n2.0 = Within 2x FVG size (recommended)\n3.0 = Within 3x FVG size (very permissive)")
fvgTransparency = input.int(90, "Transparency", minval=0, maxval=100, step=5, inline="fvgcolor", group=grp_FVG)
fvgBullColor = input.color(color.green, "Bullish FVG", inline="fvgcolor", group=grp_FVG)
fvgBearColor = input.color(color.orange, "Bearish FVG", inline="fvgcolor", group=grp_FVG)

// ========================================= TARGETS & RISK MANAGEMENT ================================
enableTargets = input.bool(true, "Enable Take Profit & Stop Loss", group=grp_targets, tooltip="Calculate and display profit targets (TP) and stop-loss (SL)\n\nWHEN ENABLED:\n• Shows TP/SL lines on chart during breakout\n• Displays values in dashboard\n• Calculates Risk/Reward ratio\n\nWHEN DISABLED:\n• Only shows ORB levels\n• No trade management\n\nRECOMMENDED: ON for active trading")

showTP1 = input.bool(true, "TP1 (1R)", group=grp_targets, inline="show")
showTP1_5 = input.bool(false, "TP1.5 (1.5R)", group=grp_targets, inline="show")
showTP2 = input.bool(true, "TP2 (2R)", group=grp_targets, inline="show")
showTP3 = input.bool(false, "TP3 (3R)", group=grp_targets, inline="show")
showTP4 = input.bool(false, "TP4 (4R)", group=grp_targets, inline="show2")
showTP5 = input.bool(false, "TP5 (5R)", group=grp_targets, inline="show2")
showTP6 = input.bool(false, "TP6 (6R)", group=grp_targets, inline="show2", tooltip="Select which Take Profit levels to display\n\nR = RISK UNITS (1R = distance from entry to stop-loss)\n\nTP1–TP6: 1R … 6R (reward multiples of risk)\n\nRECOMMENDED:\n• Day Trading: TP1 + TP2\n• Runners: add TP3–TP6 as needed\n\nLines stop updating when last enabled TP is hit")

stopOrbFraction = input.float(20, "ORB Stop Buffer %", minval=0, maxval=50, step=5, group=grp_targets, tooltip="Classic ORB stop — beyond the opposite side of the range\n\nLONG:  SL = ORB Low  − (ORB Range × Buffer%)\nSHORT: SL = ORB High + (ORB Range × Buffer%)\n\n0% = stop exactly at ORB Low / High\n20% = small buffer beyond the range (recommended)\n\nATR / Swing / % Based stop methods removed — ORB classic only.")

showTPSLLines = input.bool(true, "Show TP/SL Lines on Chart", group=grp_lines, tooltip="Display Entry, TP, and SL as horizontal lines on chart\n\nWHEN BREAKOUT OCCURS:\n• Lines appear instantly\n• Extend forward as chart progresses\n• Update with each new bar\n\nLINES FREEZE (stop updating) when:\n• Last TP is hit ✓\n• Stop Loss is hit ✗\n\nCOLORS:\n• Entry: Cyan (LONG) / Orange (SHORT)\n• TP: Green when hit, cyan/orange before\n• SL: Red always\n\nON: Shows lines (recommended)\nOFF: Only dashboard display")
// Freeze at end of day removed from UI — lines stay until TP/SL hit
bool freezeOnEOD = false

// ============================================ DASHBOARD ============================================
showDashboard = input.bool(true, "Show Info Panel", group=grp_dash, inline="theme")
dashTheme = input.string("Dark", "| Theme", options=["Dark", "Light"], group=grp_dash, inline="theme", tooltip="Dashboard color scheme\n\nDARK (Recommended) — modern charcoal panel\nLIGHT — clean light panel for bright charts")
dashSize = input.string("Normal", "Panel Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=grp_dash, tooltip="Info panel text size\n\nTINY / SMALL — compact\nNORMAL — recommended\nLARGE / HUGE — easier to read on big monitors")
showStage = input.bool(true, "Show Stage", group=grp_dash, inline="rows1", tooltip="Display current ORB stage")
showRange = input.bool(true, "Show Range", group=grp_dash, inline="rows1", tooltip="Display ORB range size")
showStatus = input.bool(true, "Show Status", group=grp_dash, inline="rows1", tooltip="Display breakout / ORB status section")
showRisk = input.bool(true, "Show Risk/Reward", group=grp_dash, inline="rows2", tooltip="Display Risk/Reward ratio")
showVolatilityMeter = input.bool(true, "Show Volatility Meter", group=grp_dash, inline="rows3", tooltip="Display volatility level (ATR %)")

symbolCurrency = syminfo.currency

// Single-select ORB → only one stage active (like Select Session)
bool enableORB5Signals = selectORB == "ORB 5M"
bool enableORB15Signals = selectORB == "ORB 15M"
bool enableORB30Signals = selectORB == "ORB 30M"
bool enableORB60Signals = selectORB == "ORB 60M"
color orbFillColor = orbHighColor

// ORB range fill — fixed (Show Background / Transparency removed from Inputs)
bool showBG = true
int fillTransparency = 95

// Classic ORB stop only (ATR / Swing / % Based stop methods removed from UI)
string stopMode = "ORB %"
int atrLength = 14  // internal only — label spacing / volatility meter
float atrMultiplier = 1.5
float percentBasedStop = 1.0
int swingBars = 3

// Position sizing / risk amount / max position removed from UI (fixed defaults)
bool enablePosSizing = true
string riskMode = "$ Amount"
float fixedRisk = 150.0
float accountSize = 25000.0
float riskPct = 0.5
float maxPositionPct = 25.0
string accountCurrency = "USD"

// Fixed reference rates (no live FX feed)
float exchangeRate = 1.0

// Mid-Range Line removed from UI (always off)
bool showMidLine = false

// Pullback / Trend filters removed from UI (always off)
bool enablePullbackFilter = false
float pullbackPercent = 0.3
int pullbackTimeout = 10
float strongVolumeMultiplier = 2.0  // label display only
bool enableTrendFilter = false
string trendMode = "VWAP"
int customEmaLength = 50
int supertrendPeriod = 10
float supertrendMult = 3.0
bool showVol = true  // show volume row in dashboard when volume filter is on
bool showTrend = false
// Require Rejection Close removed from UI — always ON for Retest + Rejection / Both
bool requireRejectionClose = true

// Higher Timeframe / Check Daily Trend removed from UI
bool enableHTF = false
string htfTF = "D"
string htfMethod = "Price vs MA"
int htfEMA = 20
float htfMinStrength = 2.0

// GOD MODE removed from UI
bool godModeEnabled = false
bool godAdaptiveBuffer = false
bool godChopGuard = false
bool godShowScore = false

// Extended hours / futures overrides removed from UI (named Asia/London/NY sessions only)
bool enableExtendedHours = false
string extendedPreMarket = "0400-0930"
string extendedAfterHours = "1600-2000"
string futuresTradingHours = "RTH Only (9:30-16:00)"

// ============================================= ALERTS ==============================================
// All alerts enabled by default - no user controls (internal use only)
bool enableAlerts = true
bool alertBreakouts = true
bool alertRetests = true
bool alertFailedBreaks = true
bool alertStageComplete = true
bool alertTradeManagement = true

// ========================================= INPUT VALIDATION ========================================
if breakoutBuffer < 0 or breakoutBuffer > 5
    runtime.error("❌ Breakout Buffer must be between 0-5%. Current value: " + str.tostring(breakoutBuffer))
if minRetestDistancePct < 0.5
    runtime.error("❌ Min Retest Distance too low. Must be >= 0.5% to prevent false signals. Current: " + str.tostring(minRetestDistancePct))
if minBarsOutside < 1
    runtime.error("❌ Min Bars Outside must be >= 1. Current: " + str.tostring(minBarsOutside))
if maxCycles < 1 or maxCycles > 10
    runtime.error("❌ Max Cycles must be between 1-10. Current: " + str.tostring(maxCycles))
if enableVolumeFilter
    if volumeMode != "Increasing"
        if volumeMultiplier < 1.0
            runtime.error("❌ Min × Avg must be >= 1.0. Current: " + str.tostring(volumeMultiplier))
        if volumeMaLength < 1
            runtime.error("❌ Volume MA Length must be >= 1. Current: " + str.tostring(volumeMaLength))
if enableTargets
    if stopOrbFraction < 0 or stopOrbFraction > 100
        runtime.error("❌ ORB Stop Buffer % must be between 0-100%. Current: " + str.tostring(stopOrbFraction))
if enableTrendFilter
    if customEmaLength < 1 or customEmaLength > 500
        runtime.error("❌ Custom EMA Length must be between 1-500. Current: " + str.tostring(customEmaLength))
    
    if supertrendPeriod < 1 or supertrendPeriod > 50
        runtime.error("❌ SuperTrend Period must be between 1-50. Current: " + str.tostring(supertrendPeriod))
    
    if supertrendMult < 0.1 or supertrendMult > 10
        runtime.error("❌ SuperTrend Multiplier must be between 0.1-10. Current: " + str.tostring(supertrendMult))
// TP validation removed - allowing all TPs to be disabled while keeping ORB functionality

// ========================================= SESSION RESOLUTION =======================================
string tradingSession = "0930-1600:23456"
string sessionTimezone = syminfo.timezone
var int sessionStartHour = na
var int sessionStartMinute = na
var int sessionEndHour = na
var int sessionEndMinute = na
bool useElectronicFullDay = false

bool isNamedSession = true
string namedSess = sessionMode == "Asia" ? S_ASIA : sessionMode == "London" ? S_LONDON : S_NY
sessionTimezone := "America/New_York"
tradingSession := str.contains(namedSess, ":") ? namedSess : namedSess + ":23456"
useElectronicFullDay := false

if tradingSession != ""
    array<string> sessColonParts = str.split(tradingSession, ":")
    string sessionTimeOnly = array.size(sessColonParts) > 0 ? array.get(sessColonParts, 0) : tradingSession
    array<string> sessionParts = str.split(sessionTimeOnly, "-")
    if array.size(sessionParts) == 2
        string startTime = array.get(sessionParts, 0)
        string endTime = array.get(sessionParts, 1)
        if str.length(startTime) == 4
            sessionStartHour := int(str.tonumber(str.substring(startTime, 0, 2)))
            sessionStartMinute := int(str.tonumber(str.substring(startTime, 2, 4)))
        if str.length(endTime) == 4
            sessionEndHour := int(str.tonumber(str.substring(endTime, 0, 2)))
            sessionEndMinute := int(str.tonumber(str.substring(endTime, 2, 4)))

// ========================================= SESSION DETECTION =======================================
// Fix for crypto session handling - credit to Crucialblockchain (Reddit credit: u/Crucialblockchain)
// Issue: Crypto was always inSession=true, ignoring custom session times (e.g., London 08:00-16:30)
// Solution: Check if 24/7 mode first, otherwise respect session hours

// Detect if using native session (empty tradingSession string)
bool useNativeSession = tradingSession == ""

// 24/7 market detection: crypto with native session OR explicit 24/7 string
bool is24_7Market = syminfo.type == "crypto" and (useNativeSession or tradingSession == "0000-2359:1234567")

inSession = false
if useNativeSession
    // Use TradingView's native session detection (no session parameter)
    // This automatically handles timezone conversions!
    inSession := not na(time(timeframe.period))
else
    // Use custom session string (Extended Hours, timezone modes, Custom mode) with timezone support
    if syminfo.type == "stock" or syminfo.type == "fund" or syminfo.type == "index" or syminfo.type == "dr" or syminfo.type == "etf" or syminfo.type == "futures"
        inSession := not na(time(timeframe.period, tradingSession, sessionTimezone))
    else if syminfo.type == "crypto"
        if is24_7Market
            inSession := true  // 24/7 trading - always in session
        else
            inSession := not na(time(timeframe.period, tradingSession, sessionTimezone))  // Respect custom session hours
    else if syminfo.type == "forex"
        inSession := not na(time(timeframe.period, tradingSession, sessionTimezone))
    else
        inSession := not na(time(timeframe.period, tradingSession, sessionTimezone))

// ============================================== VARIABLES ==========================================
var label labH = na
var label labL = na
var color cachedLineColor = na
var float lastLabelH = na
var float lastLabelL = na
var string cachedStageName = na
var bool hadSessionToday = false
var bool hadBreakUp = false
var bool hadBreakDown = false
var int breakUpBar = na
var int breakDownBar = na
var bool shownBreakUpLabel = false
var bool shownBreakDownLabel = false
var bool everHadBreakUp = false
var bool everHadBreakDown = false
var float breakoutEntryPrice = na

var int cyclesUp = 0
var int cyclesDown = 0

var int retestCyclesUp = 0 
var int retestCyclesDown = 0

var int sessionBreakoutsUp = 0
var int sessionBreakoutsDown = 0
var int sessionRetestsUp = 0
var int sessionRetestsDown = 0 

 

var string alertMsgRetestUp = ""
var string alertMsgRetestDown = ""
var string alertMsgFailedUp = ""
var string alertMsgFailedDown = ""
var string alertMsgStageComplete = ""

bool alertBreakUpTriggered = false
bool alertBreakDownTriggered = false
bool alertRetestUpTriggered = false
bool alertRetestDownTriggered = false
bool alertFailedUpTriggered = false
bool alertFailedDownTriggered = false
bool alertStageCompleteTriggered = false

// Trade management alert triggers
bool alertEntryTriggered = false
bool alertSLTriggered = false
bool alertTP1Triggered = false
bool alertTP1_5Triggered = false
bool alertTP2Triggered = false
bool alertTP3Triggered = false
bool alertTP4Triggered = false
bool alertTP5Triggered = false
bool alertTP6Triggered = false

var int barsOutsideAfterBreakUp = 0
var int barsOutsideAfterBreakDown = 0

var label lastBreakUpLabel = na
var label lastBreakDownLabel = na
var int lastLabelStage = na

var int breakUpBarIndex = 0
var int breakDownBarIndex = 0

var bool pendingLongEntry = false
var bool pendingShortEntry = false
var int pendingLongBar = na
var int pendingShortBar = na

// Retest-entry state (Entry Mode)
var bool awaitRejectUp = false
var bool awaitRejectDown = false
var int awaitRejectUpBar = na
var int awaitRejectDownBar = na

// Pullback filter state (wired)
var bool pbPendingLong = false
var bool pbPendingShort = false
var float pbExtremeLong = na
var float pbExtremeShort = na
var int pbBarLong = na
var int pbBarShort = na
var bool pbPulledLong = false
var bool pbPulledShort = false

var array<label> breakoutLabels = array.new<label>()
MAX_LABELS_TO_KEEP = 10
var array<line> tpslLines = array.new<line>()
var array<box> orbBoxes = array.new<box>()
MAX_LINES_TO_KEEP = 20
MAX_BOXES_TO_KEEP = 10

var int lastDashUpdateBar = -1

var float cachedATR = na
var int cachedATRBar = -1
var float cachedVolumeMA = na
var int cachedVolumeMABar = -1

var float cachedEntry = na
var float cachedSL = na
var float cachedTP1 = na
var float cachedTP1_5 = na
var float cachedTP2 = na
var float cachedTP3 = na
var float cachedTP4 = na
var float cachedTP5 = na
var float cachedTP6 = na
var float cachedShares = na
var float cachedPosValue = na
var float cachedMaxLoss = na
var float cachedRiskAmount = na

var array<box> fvgBoxes = array.new<box>()
var array<float> fvgTops = array.new<float>()
var array<float> fvgBottoms = array.new<float>()
var array<bool> fvgIsBullish = array.new<bool>()
var array<bool> fvgIsActive = array.new<bool>()
var array<int> fvgStartBar = array.new<int>()

var bool hadRetestUp = false
var bool hadRetestDown = false
var int retestUpBar = na
var int retestDownBar = na
var bool wentFarEnoughUp = false
var bool wentFarEnoughDown = false
var int sessionStartBar = na
var float sessionStartTime = na

var float trendVWAP = na
var float trendEMA12 = na
var float trendEMACustom = na
var float trendSTUp = na
var float trendSTDown = na
var int trendSTDirection = 0
var float volumeMA = na

var bool htfBullish = false
var bool htfBearish = false
var string htfBiasText = ""

var float actH = na
var float actL = na
var float actM = na

var float tradeOrbHigh = na
var float tradeOrbLow = na

var bool haveRange = false
var bool haveDisplayRange = false

var int stage = 0
var float displayH = na
var float displayL = na

var line orbEntryLine = na
var label orbEntryLabel = na
var float orbEntryPrice = na
var int orbEntryBar = na
var color orbLineColor = na
var line orbSLLine = na
var label orbSLLabel = na
var float orbSLPrice = na
var line orbTP1Line = na
var label orbTP1Label = na
var float orbTP1Price = na
var line orbTP1_5Line = na
var label orbTP1_5Label = na
var float orbTP1_5Price = na
var line orbTP2Line = na
var label orbTP2Label = na
var float orbTP2Price = na
var line orbTP3Line = na
var label orbTP3Label = na
var float orbTP3Price = na
var line orbTP4Line = na
var label orbTP4Label = na
var float orbTP4Price = na
var line orbTP5Line = na
var label orbTP5Label = na
var float orbTP5Price = na
var line orbTP6Line = na
var label orbTP6Label = na
var float orbTP6Price = na
var bool orbLinesFrozen = false
var int orbTradeDirection = 0

var bool orbTP1Hit = false
var bool orbTP1_5Hit = false
var bool orbTP2Hit = false
var bool orbTP3Hit = false
var bool orbTP4Hit = false
var bool orbTP5Hit = false
var bool orbTP6Hit = false
var bool orbSLHit = false

var int session_wins = 0
var int session_losses = 0
var float session_total_rr = 0.0
var int session_trades = 0
var float session_best_r = 0.0
var float session_worst_r = 0.0
var bool trade_closed = false
var string last_trade_result = ""

var float current_trade_r = 0.0
var bool tp1_counted = false
var bool tp1_5_counted = false
var bool tp2_counted = false
var bool tp3_counted = false
var bool tp4_counted = false
var bool tp5_counted = false
var bool tp6_counted = false

var float maxShares = na
var float positionValue = na
var float maxLoss = na

var int prevOrbEntryBar = na

var table dashTable = na

var int prevCyclesUp = 0
var int prevCyclesDown = 0

// ========================================= ORB OBJECTS INITIALIZATION ==============================
var ORBData orb5Obj = ORBData.new(name = "ORB 5M",minutes = 5,high = na, low = na, mid = na, orbRange = na,isEnabled = false, isBuilding = false, isComplete = false,completionBar = 0,breakoutUp = false, breakoutDown = false,breakoutBar = 0, breakoutLevel = na,cyclesUp = 0, cyclesDown = 0,orbBox = na, highLine = na, lowLine = na, midLine = na, edgeLabel = na,orbColor = color.blue,lineWidth = 1,lineStyle = line.style_solid)
var ORBData orb15Obj = ORBData.new(name = "ORB 15M",minutes = 15,high = na, low = na, mid = na, orbRange = na,isEnabled = false, isBuilding = false, isComplete = false,completionBar = 0,breakoutUp = false, breakoutDown = false,breakoutBar = 0, breakoutLevel = na,cyclesUp = 0, cyclesDown = 0,orbBox = na, highLine = na, lowLine = na, midLine = na, edgeLabel = na,orbColor = color.green, lineWidth = 1,lineStyle = line.style_solid)
var ORBData orb30Obj = ORBData.new(name = "ORB 30M",minutes = 30,high = na, low = na, mid = na, orbRange = na,isEnabled = false,  isBuilding = false, isComplete = false,completionBar = 0,breakoutUp = false, breakoutDown = false,breakoutBar = 0, breakoutLevel = na,cyclesUp = 0, cyclesDown = 0,orbBox = na, highLine = na, lowLine = na, midLine = na, edgeLabel = na,orbColor = color.orange,  lineWidth = 1,lineStyle = line.style_solid)
var ORBData orb60Obj = ORBData.new(name = "ORB 60M",minutes = 60,high = na, low = na, mid = na, orbRange = na,isEnabled = false, isBuilding = false, isComplete = false,completionBar = 0,breakoutUp = false, breakoutDown = false,breakoutBar = 0, breakoutLevel = na,cyclesUp = 0, cyclesDown = 0,orbBox = na, highLine = na, lowLine = na, midLine = na, edgeLabel = na,orbColor = color.red, lineWidth = 1,lineStyle = line.style_solid)

var ORBData activeORB = na
var array<ORBData> allORBs = array.from(orb5Obj, orb15Obj, orb30Obj, orb60Obj)
var array<ORBData> cachedPrevORBs = array.new<ORBData>(4, na)
var array<ORBData> cachedNextORBs = array.new<ORBData>(4, na)
var bool orbNavigationCached = false

// Keep enable + line colors in sync with Select ORB / High-Low color inputs
orb5Obj.isEnabled := enableORB5Signals
orb15Obj.isEnabled := enableORB15Signals
orb30Obj.isEnabled := enableORB30Signals
orb60Obj.isEnabled := enableORB60Signals
orb5Obj.orbColor := orbHighColor
orb15Obj.orbColor := orbHighColor
orb30Obj.orbColor := orbHighColor
orb60Obj.orbColor := orbHighColor

// ============================================ ALERT FUNCTIONS ======================================
sendAlert(string message) =>
    if enableAlerts
        alert(message, alert.freq_once_per_bar_close)

// ========================================== VALIDATION FUNCTIONS ===================================
// Xcelerate volume confirm: Increasing (Academy), Above Average, or Both
hasVolumeConfirmation(volMA, mult, strongMult) =>
    bool rising = volume > nz(volume[1], volume)
    bool aboveAvg = not na(volMA) and volMA > 0 and volume >= volMA * mult
    bool strong = not na(volMA) and volMA > 0 and strongMult > 0 and volume >= volMA * strongMult
    if volumeMode == "Increasing"
        rising
    else if volumeMode == "Above Average"
        aboveAvg or strong
    else  // Both
        rising and (aboveAvg or strong)

// =========================================== TARGET & STOP FUNCTIONS ================================
calculateTargets(entry, sl, isBullish) =>
    float risk = math.abs(entry - sl)
    float orbWidth = actH - actL  // Current ORB width

    float riskAdjustment = entry < 1000 ? 1.0 : entry < 5000 ? 0.8 :  0.6
    
    float tp1_orb = isBullish ? entry + (orbWidth * 1.0) : entry - (orbWidth * 1.0)
    float tp1_5_orb = isBullish ? entry + (orbWidth * 1.5) : entry - (orbWidth * 1.5)
    float tp2_orb = isBullish ? entry + (orbWidth * 2.0) : entry - (orbWidth * 2.0)
    float tp3_orb = isBullish ? entry + (orbWidth * 3.0) : entry - (orbWidth * 3.0)
    float tp4_orb = isBullish ? entry + (orbWidth * 4.0) : entry - (orbWidth * 4.0)
    float tp5_orb = isBullish ? entry + (orbWidth * 5.0) : entry - (orbWidth * 5.0)
    float tp6_orb = isBullish ? entry + (orbWidth * 6.0) : entry - (orbWidth * 6.0)
    
    float tp1_risk = isBullish ? entry + (risk * 1.0 * riskAdjustment) : entry - (risk * 1.0 * riskAdjustment)
    float tp1_5_risk = isBullish ? entry + (risk * 1.5 * riskAdjustment) : entry - (risk * 1.5 * riskAdjustment)
    float tp2_risk = isBullish ? entry + (risk * 2.0 * riskAdjustment) : entry - (risk * 2.0 * riskAdjustment)
    float tp3_risk = isBullish ? entry + (risk * 3.0 * riskAdjustment) : entry - (risk * 3.0 * riskAdjustment)
    float tp4_risk = isBullish ? entry + (risk * 4.0 * riskAdjustment) : entry - (risk * 4.0 * riskAdjustment)
    float tp5_risk = isBullish ? entry + (risk * 5.0 * riskAdjustment) : entry - (risk * 5.0 * riskAdjustment)
    float tp6_risk = isBullish ? entry + (risk * 6.0 * riskAdjustment) : entry - (risk * 6.0 * riskAdjustment)
    
    float tp1 = isBullish ? math.min(tp1_orb, tp1_risk) : math.max(tp1_orb, tp1_risk)
    float tp1_5 = isBullish ? math.min(tp1_5_orb, tp1_5_risk) : math.max(tp1_5_orb, tp1_5_risk)
    float tp2 = isBullish ? math.min(tp2_orb, tp2_risk) : math.max(tp2_orb, tp2_risk)
    float tp3 = isBullish ? math.min(tp3_orb, tp3_risk) : math.max(tp3_orb, tp3_risk)
    float tp4 = isBullish ? math.min(tp4_orb, tp4_risk) : math.max(tp4_orb, tp4_risk)
    float tp5 = isBullish ? math.min(tp5_orb, tp5_risk) : math.max(tp5_orb, tp5_risk)
    float tp6 = isBullish ? math.min(tp6_orb, tp6_risk) : math.max(tp6_orb, tp6_risk)
    
    [tp1, tp1_5, tp2, tp3, tp4, tp5, tp6]

// Classic ORB stop: beyond opposite side of the range (+ optional buffer %)
calculateStopLoss(entry, orbHigh, orbLow, orbRange, atr, mode, isBullish) =>
    float orbFraction = stopOrbFraction / 100
    float rangeBuf = nz(orbRange, 0) * orbFraction
    float sl = isBullish ? orbLow - rangeBuf : orbHigh + rangeBuf
    sl

calculatePositionSize(entry, sl) =>
    float riskAmount = 0.0
    
    if riskMode == "% of Account"
        riskAmount := accountSize * (riskPct / 100)
    else
        riskAmount := fixedRisk
        
    if symbolCurrency != accountCurrency
        riskAmount := riskAmount * exchangeRate
    
    float riskPerShare = math.abs(entry - sl) 
    float sharesFromRisk = riskPerShare > 0 ? math.floor(riskAmount / riskPerShare) : 0
    float maxPositionValue = accountSize * (maxPositionPct / 100)

    if symbolCurrency != accountCurrency
        maxPositionValue := maxPositionValue * exchangeRate
    
    float maxSharesFromLimit = entry > 0 ? math.floor(maxPositionValue / entry) : 0
    float shares = math.min(sharesFromRisk, maxSharesFromLimit)
    float posValue = shares * entry
    shares := math.floor(shares)
    float maxLossCalc = shares * riskPerShare
    
    [shares, posValue, maxLossCalc, riskAmount]

calculateTPSplits(show1, show1_5, show2, show3) =>
    int activeCount = 0
    if show1
        activeCount += 1
    if show1_5
        activeCount += 1
    if show2
        activeCount += 1
    if show3
        activeCount += 1
    
    float split1 = 0.0
    float split1_5 = 0.0
    float split2 = 0.0
    float split3 = 0.0
    
    if activeCount == 1
        if show1
            split1 := 1.0
        else if show1_5
            split1_5 := 1.0
        else if show2
            split2 := 1.0
        else if show3
            split3 := 1.0
    else if activeCount == 2
        float half = 0.5
        if show1
            split1 := half
            if show1_5
                split1_5 := half
            else if show2
                split2 := half
            else if show3
                split3 := half
        else if show1_5
            split1_5 := half
            if show2
                split2 := half
            else if show3
                split3 := half
        else if show2
            split2 := half
            if show3
                split3 := half
        else if show3
            split3 := half
    else if activeCount >= 3
        float remaining = 0.5
        float remainder = remaining / (activeCount - 1)
        
        bool firstAssigned = false
        if show1
            split1 := firstAssigned ? remainder : 0.5
            firstAssigned := true
        if show1_5
            split1_5 := firstAssigned ? remainder : 0.5
            firstAssigned := true
        if show2
            split2 := firstAssigned ? remainder : 0.5
            firstAssigned := true
        if show3
            split3 := firstAssigned ? remainder : 0.5
            firstAssigned := true
    
    [split1, split1_5, split2, split3]

checkHTFBias() =>
    bool bullish = false
    bool bearish = false
    string biasText = ""
    float strength = 0.0
    
    if enableHTF
        [htfClose, htfOpen, htfMA] = request.security(syminfo.tickerid, htfTF, [close, open, ta.ema(close, htfEMA)], barmerge.gaps_off, barmerge.lookahead_off)
        
        if htfMethod == "Price vs MA"
            float distancePct = htfMA > 0 ? ((htfClose - htfMA) / htfMA) * 100 : 0
            strength := math.abs(distancePct)
            
            bool strongEnough = enableHTF ? strength >= htfMinStrength : false
            
            bullish := htfClose > htfMA and strongEnough
            bearish := htfClose < htfMA and strongEnough
            
        else if htfMethod == "Candle Direction"
            float bodySize = math.abs(htfClose - htfOpen)
            float candleRange = htfClose > 0 ? (bodySize / htfClose) * 100 : 0
            strength := candleRange
            
            bullish := htfClose > htfOpen
            bearish := htfClose < htfOpen
        
        if bullish
            biasText := strength > htfMinStrength * 2 ? "✅✅ Strong Aligned" : "✅ Aligned"
        else if bearish
            biasText := strength > htfMinStrength * 2 ? "⚠️ Strong Counter ⚠️" : "⚠️ Counter-Trend"
        else
            biasText := "➖ Neutral/Weak"
    
    [bullish, bearish, biasText, strength]

// ============================================== FUNCTIONS ==========================================
getBodyHigh() => math.max(open, close)
getBodyLow() => math.min(open, close)
bodyClosedAbove(level) => getBodyLow() > level
bodyClosedBelow(level) => getBodyHigh() < level

float currentTF_minutes = timeframe.in_seconds() / 60
needsConfirmation = currentTF_minutes <= 5

getBuffer(level, pct) =>
    level * (pct / 100)
priceRetestFromAbove(level, buffer) =>
    getBodyLow() < level + buffer
priceRetestFromBelow(level, buffer) =>
    getBodyHigh() > level - buffer
getLabelSize(sizeStr) =>
    sizeStr == "Tiny" ? size.tiny : sizeStr == "Small" ? size.small : sizeStr == "Normal" ? size.normal : sizeStr == "Large" ? size.large : size.huge
calcSuperTrend(atrPeriod, multiplier) =>
    atr = ta.atr(atrPeriod)
    hl2Val = hl2
    
    basicUpperBand = hl2Val + multiplier * atr
    basicLowerBand = hl2Val - multiplier * atr
    
    var float finalUpperBand = na
    var float finalLowerBand = na
    var int trendDir = 1
    
    finalUpperBand := na(finalUpperBand[1]) or basicUpperBand < finalUpperBand[1] or close[1] > finalUpperBand[1] ? basicUpperBand : finalUpperBand[1]
    finalLowerBand := na(finalLowerBand[1]) or basicLowerBand > finalLowerBand[1] or close[1] < finalLowerBand[1] ? basicLowerBand : finalLowerBand[1]
    
    trendDir := na(trendDir[1]) ? 1 : close > finalUpperBand[1] ? 1 : close < finalLowerBand[1] ? -1 : trendDir[1]
    
    [finalLowerBand, finalUpperBand, trendDir]

isTrendUp(mode, closePrice, vwapVal, ema12Val, emaCustomVal, stDir) =>
    switch mode
        "VWAP" => closePrice > vwapVal
        "EMA" => closePrice > ema12Val
        "Custom EMA" => closePrice > emaCustomVal
        "SuperTrend" => stDir == 1
        "VWAP+EMA" => closePrice > vwapVal and closePrice > ema12Val
        "VWAP+SuperTrend" => closePrice > vwapVal and stDir == 1
        => true

isTrendDown(mode, closePrice, vwapVal, ema12Val, emaCustomVal, stDir) =>
    switch mode
        "VWAP" => closePrice < vwapVal
        "EMA" => closePrice < ema12Val
        "Custom EMA" => closePrice < emaCustomVal
        "SuperTrend" => stDir == -1
        "VWAP+EMA" => closePrice < vwapVal and closePrice < ema12Val
        "VWAP+SuperTrend" => closePrice < vwapVal and stDir == -1
        => true

isTradingDay() =>
    bool isTrading = true
    
    if syminfo.type == "stock" or syminfo.type == "fund" or syminfo.type == "index" or syminfo.type == "dr" or syminfo.type == "etf" or syminfo.type == "futures"
        int currentDayOfWeek = dayofweek(timenow)
        // 1=Sunday, 2=Monday, ..., 7=Saturday
        // Trading days: Monday(2) to Friday(6)
        isTrading := currentDayOfWeek >= 2 and currentDayOfWeek <= 6
    else if syminfo.type == "crypto"
        isTrading := true  // 24/7
    else if syminfo.type == "forex"
        int currentDayOfWeek = dayofweek(timenow)
        // Forex: Sunday evening to Friday evening
        isTrading := currentDayOfWeek >= 1 and currentDayOfWeek <= 6
    else
        isTrading := true
    
    isTrading

isReplayMode() =>
    bool isReplay = false
    
    if barstate.islast
        int timeDiffMinutes = int((timenow - time_close) / 60000)

        int currentDayOfWeek = dayofweek(timenow)
        int barDayOfWeek = dayofweek(time_close)
    
        bool isWeekendNow = currentDayOfWeek == 7 or currentDayOfWeek == 1  // Saturday or Sunday
        bool barWasFriday = barDayOfWeek == 6  // Last bar was Friday

        if isWeekendNow and barWasFriday
            isReplay := false  // LIVE on weekend - don't show dashboard

        else if currentDayOfWeek == 2 and barDayOfWeek == 6
            isReplay := false  // LIVE on Monday pre-market

        else
            isReplay := timeDiffMinutes > 1440
    
    isReplay

isWithinSessionHours() =>
    bool withinHours = false

    // If using native session, use TradingView's inSession variable
    if useNativeSession
        withinHours := inSession
    else
        bool useReplayTime = isReplayMode()
        int timeToCheck = useReplayTime ? time : timenow

        int currentDayOfWeek = dayofweek(timeToCheck)
        bool isTradingDay = syminfo.type == "stock" ? (currentDayOfWeek >= 2 and currentDayOfWeek <= 6) : true

        if not isTradingDay and syminfo.type == "stock"
            withinHours := false
        else if not na(sessionStartHour) and not na(sessionEndHour)
            // Use session timezone (America/New_York for Asia/London/NY named sessions)
            int currentHour = hour(timeToCheck, sessionTimezone)
            int currentMinute = minute(timeToCheck, sessionTimezone)

            int currentMinutesFromMidnight = currentHour * 60 + currentMinute
            int sessionStartMinutes = sessionStartHour * 60 + nz(sessionStartMinute)
            int sessionEndMinutes = sessionEndHour * 60 + nz(sessionEndMinute)

            // Overnight windows (e.g. Asia 20:00-05:00): wrap past midnight
            if sessionStartMinutes <= sessionEndMinutes
                withinHours := currentMinutesFromMidnight >= sessionStartMinutes and currentMinutesFromMidnight <= sessionEndMinutes
            else
                withinHours := currentMinutesFromMidnight >= sessionStartMinutes or currentMinutesFromMidnight <= sessionEndMinutes

    withinHours

// ====================================== ORB HELPER FUNCTIONS =======================================
getPreviousEnabledORB(ORBData currentOrb) =>
    ORBData prevOrb = na
    for orb in allORBs
        if orb.isEnabled and orb.minutes < currentOrb.minutes
            if na(prevOrb) or orb.minutes > prevOrb.minutes
                prevOrb := orb
    prevOrb

getNextEnabledORB(ORBData currentOrb) =>
    ORBData nextOrb = na
    for orb in allORBs
        if orb.isEnabled and orb.minutes > currentOrb.minutes
            if na(nextOrb) or orb.minutes < nextOrb.minutes
                nextOrb := orb
    nextOrb

// ====================================== CLEANUP FUNCTIONS ==========================================
cleanupLine(lineObject) =>
    if not na(lineObject)
        array.push(tpslLines, lineObject)
        if array.size(tpslLines) > MAX_LINES_TO_KEEP
            oldLine = array.shift(tpslLines)
            if not na(oldLine)
                line.delete(oldLine)

cleanupLabel(labelObject) =>
    if not na(labelObject)
        array.push(breakoutLabels, labelObject)
        if array.size(breakoutLabels) > MAX_LABELS_TO_KEEP
            oldLabel = array.shift(breakoutLabels)
            if not na(oldLabel)
                label.delete(oldLabel)

// Clean up old boxes to prevent memory issues
cleanupBox(boxObject) =>
    if not na(boxObject)
        array.push(orbBoxes, boxObject)
        if array.size(orbBoxes) > MAX_BOXES_TO_KEEP
            oldBox = array.shift(orbBoxes)
            if not na(oldBox)
                box.delete(oldBox)

// ===================================== FVG DETECTION FUNCTIONS =====================================
detectBullishFVG() =>
    bool hasFVG = false
    float fvgTop = na
    float fvgBottom = na
    
    if bar_index >= 2
        if high[2] < low[0]
            hasFVG := true
            fvgTop := low[0]
            fvgBottom := high[2]
    
    [hasFVG, fvgTop, fvgBottom]

detectBearishFVG() =>
    bool hasFVG = false
    float fvgTop = na
    float fvgBottom = na
    
    if bar_index >= 2
        if low[2] > high[0]
            hasFVG := true
            fvgTop := low[2]
            fvgBottom := high[0]
    
    [hasFVG, fvgTop, fvgBottom]

hasValidFVGNearLevel(level, isBullish) =>
    bool foundFVG = false
    
    if array.size(fvgTops) > 0
        for i = 0 to array.size(fvgTops) - 1
            if array.get(fvgIsBullish, i) == isBullish
                fvgTop = array.get(fvgTops, i)
                fvgBottom = array.get(fvgBottoms, i)
                fvgSize = fvgTop - fvgBottom
                
                // Use user-defined proximity
                expandedTop = fvgTop + (fvgSize * fvgProximity)
                expandedBottom = fvgBottom - (fvgSize * fvgProximity)
                
                if level >= expandedBottom and level <= expandedTop
                    foundFVG := true
                    break
    
    foundFVG
 
cleanupOldFVG() =>
    while array.size(fvgBoxes) > maxFVGtoKeep
        oldBox = array.shift(fvgBoxes)
        array.shift(fvgTops)
        array.shift(fvgBottoms)
        array.shift(fvgIsBullish)
        array.shift(fvgIsActive)
        array.shift(fvgStartBar)
        if not na(oldBox)
            box.delete(oldBox)

// ================================ SESSION STATUS DETECTION FUNCTIONS ===============================
isWithinDisplayHours() =>
    bool withinDisplay = false
 
    bool useReplayTime = isReplayMode()
    int timeToCheck = useReplayTime ? time : timenow
    
    if syminfo.type == "stock" or syminfo.type == "fund" or syminfo.type == "index" or syminfo.type == "dr" or syminfo.type == "etf" or syminfo.type == "futures"
        int currentDayOfWeek = dayofweek(timeToCheck)
        bool isTradingDay = currentDayOfWeek >= 2 and currentDayOfWeek <= 6
        
        if not isTradingDay
            withinDisplay := false
        else
            int currentHour = hour(timeToCheck)
            int currentMinute = minute(timeToCheck)
            int currentMinutesFromMidnight = currentHour * 60 + currentMinute

            int displayStartMinutes = 4 * 60  // 240 minutes = 04:00
            int displayEndMinutes = 20 * 60   // 1200 minutes = 20:00
            
            withinDisplay := currentMinutesFromMidnight >= displayStartMinutes and currentMinutesFromMidnight < displayEndMinutes
    else if syminfo.type == "crypto"
        withinDisplay := true  // 24/7 display
    else if syminfo.type == "forex"
        withinDisplay := true  // Display when forex session active
    else
        withinDisplay := true  // Default: always display
    
    withinDisplay

isInRegularHours() =>
    bool inRegular = false
    
    bool useReplayTime = isReplayMode()
    int timeToCheck = useReplayTime ? time : timenow
    
    if syminfo.type == "stock" or syminfo.type == "fund" or syminfo.type == "index" or syminfo.type == "dr" or syminfo.type == "etf" or syminfo.type == "futures"
        int currentDayOfWeek = dayofweek(timeToCheck)
        bool isTradingDay = currentDayOfWeek >= 2 and currentDayOfWeek <= 6
        
        if not isTradingDay
            inRegular := false
        else
            int currentHour = hour(timeToCheck)
            int currentMinute = minute(timeToCheck)
            int currentMinutesFromMidnight = currentHour * 60 + currentMinute
            
            int regularStartMinutes = 9 * 60 + 30  // Default: 09:30
            int regularEndMinutes = 16 * 60        // Default: 16:00

            // Only use custom session hours when NOT in native session mode
            if not useNativeSession and not na(sessionStartHour) and not na(sessionEndHour)
                if enableExtendedHours
                    regularStartMinutes := 9 * 60 + 30
                    regularEndMinutes := 16 * 60
                else
                    regularStartMinutes := sessionStartHour * 60 + sessionStartMinute
                    regularEndMinutes := sessionEndHour * 60 + sessionEndMinute

            inRegular := currentMinutesFromMidnight >= regularStartMinutes and currentMinutesFromMidnight <= regularEndMinutes
    else if syminfo.type == "crypto"
        inRegular := true  // Crypto is always "regular" (24/7)
    else
        inRegular := true
    
    inRegular

// ========================================= NEW DAY/SESSION RESET ===================================
isNewSession = false
isNewDay = false

// Special reset logic for E-mini Electronic Full Day mode
// ORB resets daily at 9:30 AM ET, even though trading is 24/7
if useElectronicFullDay
    // Get current and previous bar times in sessionTimezone (America/New_York for E-minis)
    int currentHour = hour(time, sessionTimezone)
    int currentMinute = minute(time, sessionTimezone)
    int prevHour = hour(time[1], sessionTimezone)
    int prevMinute = minute(time[1], sessionTimezone)

    // Calculate minutes from midnight for easier comparison
    int currentMinutesFromMidnight = currentHour * 60 + currentMinute
    int prevMinutesFromMidnight = prevHour * 60 + prevMinute
    int resetTimeMinutes = 9 * 60 + 30  // 9:30 AM = 570 minutes

    // Check if we crossed the 9:30 AM threshold
    // Current bar is at or after 9:30, previous bar was before 9:30
    bool nowAfter930 = currentMinutesFromMidnight >= resetTimeMinutes
    bool prevBefore930 = prevMinutesFromMidnight < resetTimeMinutes

    isNewSession := nowAfter930 and prevBefore930
    isNewDay := false  // Don't use day change logic for Electronic Full Day
else if is24_7Market
    currentDay = dayofmonth(time)
    prevDay = dayofmonth(time[1])
    isNewDay := currentDay != prevDay
    isNewSession := false
else
    isNewSession := inSession and not inSession[1]
    isNewDay := ta.change(dayofweek) != 0

shouldReset = isNewSession or isNewDay

if shouldReset

    hadSessionToday := false

    orbNavigationCached := false
    if shouldReset
        hadSessionToday := false
        orbNavigationCached := false
        wentFarEnoughUp := false
        wentFarEnoughDown := false

    for i = 0 to array.size(allORBs) - 1
        orbObj = array.get(allORBs, i)
        if orbObj.minutes == 5
            orbObj.high := high
            orbObj.low := low
            orbObj.mid := hl2
            orbObj.orbRange := 0
        else
            orbObj.high := na
            orbObj.low := na
            orbObj.mid := na
            orbObj.orbRange := 0
        orbObj.isBuilding := true
        orbObj.isComplete := false
        orbObj.completionBar := 0
        orbObj.breakoutUp := false
        orbObj.breakoutDown := false
        orbObj.breakoutBar := 0
        orbObj.breakoutLevel := na
        orbObj.cyclesUp := 0
        orbObj.cyclesDown := 0

        if not na(orbObj.orbBox)
            box.delete(orbObj.orbBox)
        if not na(orbObj.highLine)
            line.delete(orbObj.highLine)
        if not na(orbObj.lowLine)
            line.delete(orbObj.lowLine)
        if not na(orbObj.midLine)
            line.delete(orbObj.midLine)
        if not na(orbObj.edgeLabel)
            label.delete(orbObj.edgeLabel)

        orbObj.orbBox := na
        orbObj.highLine := na
        orbObj.lowLine := na
        orbObj.midLine := na
        orbObj.edgeLabel := na

    activeORB := na
    actH := na
    actL := na
    actM := na

    tradeOrbHigh := na
    tradeOrbLow := na

    tradeOrbHigh := na
    tradeOrbLow := na
    haveRange := false
    haveDisplayRange := false
    stage := 0
    displayH := na
    displayL := na
    breakUpBarIndex := 0
    breakDownBarIndex := 0

    cyclesUp := 0
    cyclesDown := 0
    retestCyclesUp := 0
    retestCyclesDown := 0
    barsOutsideAfterBreakUp := 0
    barsOutsideAfterBreakDown := 0
    wentFarEnoughUp := false
    wentFarEnoughDown := false

    sessionBreakoutsUp := 0
    sessionBreakoutsDown := 0
    sessionRetestsUp := 0
    sessionRetestsDown := 0

    // daily counters reset removed

    session_wins := 0
    session_losses := 0
    session_total_rr := 0.0
    session_trades := 0
    session_best_r := 0.0
    session_worst_r := 0.0
    trade_closed := false
    last_trade_result := ""

    current_trade_r := 0.0
    tp1_counted := false
    tp1_5_counted := false
    tp2_counted := false
    tp3_counted := false
    tp4_counted := false
    tp5_counted := false
    tp6_counted := false

    prevOrbEntryBar := na

    sessionStartBar := na
    sessionStartTime := na
    
    cachedLineColor := na
    cachedStageName := na
    
    lastLabelH := na
    lastLabelL := na
    lastLabelStage := na
    
    if not na(labH)
        label.delete(labH)
        labH := na
    if not na(labL)
        label.delete(labL)
        labL := na

    hadBreakUp := false
    hadBreakDown := false
    breakUpBar := na
    breakDownBar := na
    shownBreakUpLabel := false
    shownBreakDownLabel := false        
    everHadBreakUp := false
    everHadBreakDown := false
    breakoutEntryPrice := na
    hadRetestUp := false
    hadRetestDown := false
    retestUpBar := na
    retestDownBar := na
    lastLabelStage := na

    pendingLongEntry := false
    pendingShortEntry := false
    pendingLongBar := na
    pendingShortBar := na
    awaitRejectUp := false
    awaitRejectDown := false
    awaitRejectUpBar := na
    awaitRejectDownBar := na
    pbPendingLong := false
    pbPendingShort := false
    pbExtremeLong := na
    pbExtremeShort := na
    pbBarLong := na
    pbBarShort := na
    pbPulledLong := false
    pbPulledShort := false

    if not na(orbEntryLine)
        line.delete(orbEntryLine)
        orbEntryLine := na
    if not na(orbEntryLabel)
        label.delete(orbEntryLabel)
        orbEntryLabel := na
    if not na(orbSLLine)
        line.delete(orbSLLine)
        orbSLLine := na
    if not na(orbSLLabel)
        label.delete(orbSLLabel)
        orbSLLabel := na
    if not na(orbTP1Line)
        line.delete(orbTP1Line)
        orbTP1Line := na
    if not na(orbTP1Label)
        label.delete(orbTP1Label)
        orbTP1Label := na
    if not na(orbTP1_5Line)
        line.delete(orbTP1_5Line)
        orbTP1_5Line := na
    if not na(orbTP1_5Label)
        label.delete(orbTP1_5Label)
        orbTP1_5Label := na
    if not na(orbTP2Line)
        line.delete(orbTP2Line)
        orbTP2Line := na
    if not na(orbTP2Label)
        label.delete(orbTP2Label)
        orbTP2Label := na
    if not na(orbTP3Line)
        line.delete(orbTP3Line)
        orbTP3Line := na
    if not na(orbTP3Label)
        label.delete(orbTP3Label)
        orbTP3Label := na
    if not na(orbTP4Line)
        line.delete(orbTP4Line)
        orbTP4Line := na
    if not na(orbTP4Label)
        label.delete(orbTP4Label)
        orbTP4Label := na
    if not na(orbTP5Line)
        line.delete(orbTP5Line)
        orbTP5Line := na
    if not na(orbTP5Label)
        label.delete(orbTP5Label)
        orbTP5Label := na
    if not na(orbTP6Line)
        line.delete(orbTP6Line)
        orbTP6Line := na
    if not na(orbTP6Label)
        label.delete(orbTP6Label)
        orbTP6Label := na
    
    orbEntryPrice := na
    orbEntryBar := na
    orbLineColor := na
    orbSLPrice := na
    orbTP1Price := na
    orbTP1_5Price := na
    orbTP2Price := na
    orbTP3Price := na
    orbTP4Price := na
    orbTP5Price := na
    orbTP6Price := na
    orbLinesFrozen := false
    orbTP1Hit := false
    orbTP1_5Hit := false
    orbTP2Hit := false
    orbTP3Hit := false
    orbTP4Hit := false
    orbTP5Hit := false
    orbTP6Hit := false
    orbSLHit := false
    orbTradeDirection := 0

    current_trade_r := 0.0
    tp1_counted := false
    tp1_5_counted := false
    tp2_counted := false
    tp3_counted := false
    tp4_counted := false
    tp5_counted := false
    tp6_counted := false

    maxShares := na
    positionValue := na
    maxLoss := na

    lastDashUpdateBar := bar_index - 100

// ========================================= TIME CALCULATION ========================================
var float sessionFirstBarTime = na

if inSession and na(sessionStartTime)
    sessionStartBar := bar_index
    sessionStartTime := time
    sessionFirstBarTime := time
    hadSessionToday := true// Track session start time and bar when new session is detected
if isNewSession
    sessionStartBar := bar_index
    sessionStartTime := time
    sessionFirstBarTime := time  // Reset first bar time for new session
    hadSessionToday := true  // Mark that session started today

float minsFromOpen = -1.0

if not na(sessionFirstBarTime) and inSession
    minsFromOpen := (time - sessionFirstBarTime) / 60000   
    if minsFromOpen > 480
        minsFromOpen := 480  
    if minsFromOpen < 0
        minsFromOpen := 0

// ===================================== GLOBAL CACHE (PERFORMANCE) ==================================
if barstate.isconfirmed or barstate.islast
    bool needATR = everHadBreakUp or everHadBreakDown or showDashboard or not na(activeORB)
    if needATR and bar_index != cachedATRBar
        cachedATR := ta.atr(atrLength)
        cachedATRBar := bar_index
    
    if bar_index != cachedVolumeMABar
        cachedVolumeMA := ta.sma(volume, volumeMaLength)
        cachedVolumeMABar := bar_index
 
// ======================================= ORB LEVEL BUILDING ========================================
currentTF_seconds = timeframe.in_seconds()
float chartMins = currentTF_seconds / 60.0
isHTF = currentTF_seconds >= 86400

// Completed ORB-stage OHLC (no lookahead) — breakout confirm on these TFs
[orbClose5, orbClose5Prev, orbHigh5, orbHigh5Prev, orbLow5, orbLow5Prev] = request.security(syminfo.tickerid, "5", [close[1], close[2], high[1], high[2], low[1], low[2]], barmerge.gaps_off, barmerge.lookahead_off)
[orbClose15, orbClose15Prev, orbHigh15, orbHigh15Prev, orbLow15, orbLow15Prev] = request.security(syminfo.tickerid, "15", [close[1], close[2], high[1], high[2], low[1], low[2]], barmerge.gaps_off, barmerge.lookahead_off)
[orbClose30, orbClose30Prev, orbHigh30, orbHigh30Prev, orbLow30, orbLow30Prev] = request.security(syminfo.tickerid, "30", [close[1], close[2], high[1], high[2], low[1], low[2]], barmerge.gaps_off, barmerge.lookahead_off)
[orbClose60, orbClose60Prev, orbHigh60, orbHigh60Prev, orbLow60, orbLow60Prev] = request.security(syminfo.tickerid, "60", [close[1], close[2], high[1], high[2], low[1], low[2]], barmerge.gaps_off, barmerge.lookahead_off)
bool orbTFClosed5 = timeframe.change("5")
bool orbTFClosed15 = timeframe.change("15")
bool orbTFClosed30 = timeframe.change("30")
bool orbTFClosed60 = timeframe.change("60")

// Signal OHLC for active ORB stage — never use a forming bar's live values.
getOrbSignalBar(int orbMins) =>
    float c = close
    float cPrev = close[1]
    float h = high
    float hPrev = high[1]
    float l = low
    float lPrev = low[1]
    bool justClosed = barstate.isconfirmed
    if chartMins < orbMins
        if orbMins == 5
            c := orbClose5
            cPrev := orbClose5Prev
            h := orbHigh5
            hPrev := orbHigh5Prev
            l := orbLow5
            lPrev := orbLow5Prev
            justClosed := orbTFClosed5 and barstate.isconfirmed
        else if orbMins == 15
            c := orbClose15
            cPrev := orbClose15Prev
            h := orbHigh15
            hPrev := orbHigh15Prev
            l := orbLow15
            lPrev := orbLow15Prev
            justClosed := orbTFClosed15 and barstate.isconfirmed
        else if orbMins == 30
            c := orbClose30
            cPrev := orbClose30Prev
            h := orbHigh30
            hPrev := orbHigh30Prev
            l := orbLow30
            lPrev := orbLow30Prev
            justClosed := orbTFClosed30 and barstate.isconfirmed
        else
            c := orbClose60
            cPrev := orbClose60Prev
            h := orbHigh60
            hPrev := orbHigh60Prev
            l := orbLow60
            lPrev := orbLow60Prev
            justClosed := orbTFClosed60 and barstate.isconfirmed
    [c, cPrev, h, hPrev, l, lPrev, justClosed]

// Back-compat helper used by rejection entry (body close)
getOrbSignalClose(int orbMins) =>
    [c, cPrev, h, hPrev, l, lPrev, justClosed] = getOrbSignalBar(orbMins)
    [c, cPrev, justClosed]

// ========================================== GOD MODE CONTEXT =======================================
// Daily levels from the previous COMPLETED day (offset [1] = no repaint) + daily ATR for OR-quality scoring
[godPrevDayHigh, godPrevDayLow, godPrevDayClose, godDailyATR] = request.security(syminfo.tickerid, "D", [high[1], low[1], close[1], ta.atr(14)[1]], barmerge.gaps_off, barmerge.lookahead_off)

var float godPmHigh = na
var float godPmLow = na
var float godSessionOpen = na
var int godFailedBreaks = 0
var float godLastScore = na
var string godLastScoreDir = ""

if shouldReset
    godSessionOpen := open
    godFailedBreaks := 0
    godLastScore := na
    godLastScoreDir := ""

if godModeEnabled and not isHTF
    if ta.change(time("D")) != 0
        godPmHigh := na
        godPmLow := na
    if not inSession
        godPmHigh := math.max(nz(godPmHigh, high), high)
        godPmLow := math.min(nz(godPmLow, low), low)

float godGapPct = godModeEnabled and not na(godSessionOpen) and not na(godPrevDayClose) and godPrevDayClose > 0 ? (godSessionOpen - godPrevDayClose) / godPrevDayClose * 100 : na
bool godChopDay = godModeEnabled and godChopGuard and godFailedBreaks >= 2

// ============================== NEW ARCHITECTURE: INDEPENDENT ORB BUILDING =========================
if not isHTF and minsFromOpen >= 0 and (barstate.isconfirmed or barstate.islast) and inSession
    for i = 0 to array.size(allORBs) - 1
        orbObj = array.get(allORBs, i)

        if orbObj.isEnabled and orbObj.isBuilding
            if minsFromOpen > orbObj.minutes
                orbObj.isBuilding := false
                orbObj.isComplete := true
                orbObj.completionBar := bar_index

                if na(activeORB) or orbObj.minutes > activeORB.minutes
                    activeORB := orbObj
                    actH := orbObj.high
                    actL := orbObj.low
                    actM := orbObj.mid
                    haveRange := true
                    haveDisplayRange := true
                    stage := orbObj.minutes
                    displayH := orbObj.high
                    displayL := orbObj.low
                    cachedStageName := orbObj.name
                    cachedLineColor := orbObj.orbColor

            else

                if na(orbObj.high)
                    prevOrb = getPreviousEnabledORB(orbObj)
                    if not na(prevOrb) and prevOrb.isComplete
                        orbObj.high := prevOrb.high
                        orbObj.low := prevOrb.low
                        orbObj.mid := prevOrb.mid
                        orbObj.orbRange := prevOrb.orbRange

                if minsFromOpen < orbObj.minutes
                    orbObj.high := math.max(nz(orbObj.high, high), high)
                    orbObj.low := math.min(nz(orbObj.low, low), low)
                    orbObj.mid := (orbObj.high + orbObj.low) / 2
                    orbObj.orbRange := orbObj.high - orbObj.low

                    if minsFromOpen >= orbObj.minutes - 1 and not orbObj.isComplete
                        orbObj.isBuilding := false
                        orbObj.isComplete := true
                        orbObj.completionBar := bar_index

                        activeORB := orbObj

                        actH := orbObj.high
                        actL := orbObj.low
                        actM := orbObj.mid
                        haveRange := true
                        haveDisplayRange := true

                        stage := orbObj.minutes
                        displayH := orbObj.high
                        displayL := orbObj.low
                        cachedStageName := orbObj.name
                        cachedLineColor := orbObj.orbColor

// ================================== CACHE ORB NAVIGATION (PERFORMANCE) =============================
if not orbNavigationCached and not isHTF
    for i = 0 to array.size(allORBs) - 1
        orbObj = array.get(allORBs, i)

        ORBData prevOrb = na
        for j = 0 to array.size(allORBs) - 1
            checkOrb = array.get(allORBs, j)
            if checkOrb.isEnabled and checkOrb.minutes < orbObj.minutes
                if na(prevOrb) or checkOrb.minutes > prevOrb.minutes
                    prevOrb := checkOrb
        array.set(cachedPrevORBs, i, prevOrb)
 
        ORBData nextOrb = na
        for j = 0 to array.size(allORBs) - 1
            checkOrb = array.get(allORBs, j)
            if checkOrb.isEnabled and checkOrb.minutes > orbObj.minutes
                if na(nextOrb) or checkOrb.minutes < nextOrb.minutes
                    nextOrb := checkOrb
        array.set(cachedNextORBs, i, nextOrb)
    
    orbNavigationCached := true

// ===================================== STAGE & COLOR MANAGEMENT ====================================
for i = 0 to array.size(allORBs) - 1
    orbObj = array.get(allORBs, i)
    if orbObj.isEnabled and orbObj.isComplete and orbObj.completionBar == bar_index
        rangeSize = orbObj.high - orbObj.low
        rangePct = (rangeSize / orbObj.low) * 100
        alertMsgStageComplete := "✅ " + orbObj.name + " COMPLETE - " + syminfo.ticker + " | Range: $" + str.tostring(orbObj.high, "#.##") + " - $" + str.tostring(orbObj.low, "#.##") + " (" + str.tostring(rangePct, "#.#") + "%)"
        sendAlert(alertMsgStageComplete)
        alertStageCompleteTriggered := true

// ======================================= TREND CALCULATION ========================================
if enableTrendFilter
    if str.contains(trendMode, "VWAP")
        trendVWAP := ta.vwap(close)
    
    if trendMode == "EMA" or trendMode == "VWAP+EMA"
        trendEMA12 := ta.ema(close, 12)
    
    if trendMode == "Custom EMA"
        trendEMACustom := ta.ema(close, customEmaLength)
    
    if str.contains(trendMode, "SuperTrend")
        if barstate.isnew or na(trendSTUp)
            [stLower, stUpper, stDir] = calcSuperTrend(supertrendPeriod, supertrendMult)
            trendSTUp := stLower
            trendSTDown := stUpper
            trendSTDirection := stDir

// ========================================== GOD MODE SCORING =======================================
f_nearLvl(lvl, ref, tol) => not na(lvl) and not na(ref) and math.abs(lvl - ref) <= tol
f_godGrade(s) => s >= 85 ? "A+" : s >= 70 ? "A" : s >= 55 ? "B" : s >= 40 ? "C" : "D"

float godLvlTol = nz(cachedATR) * 0.25
bool godHighConfluence = godModeEnabled and haveRange and (f_nearLvl(actH, godPrevDayHigh, godLvlTol) or f_nearLvl(actH, godPmHigh, godLvlTol))
bool godLowConfluence = godModeEnabled and haveRange and (f_nearLvl(actL, godPrevDayLow, godLvlTol) or f_nearLvl(actL, godPmLow, godLvlTol))

f_godScore(bool isUp) =>
    float score = 50.0
    float volRatio = nz(cachedVolumeMA) > 0 ? volume / cachedVolumeMA : 1.0
    score += volRatio >= strongVolumeMultiplier ? 20 : volRatio >= volumeMultiplier ? 12 : volRatio >= 1.0 ? 4 : -10
    score += isUp ? (htfBullish ? 15 : htfBearish ? -15 : 0) : (htfBearish ? 15 : htfBullish ? -15 : 0)
    float orVsAtr = not na(godDailyATR) and godDailyATR > 0 and not na(activeORB) ? activeORB.orbRange / godDailyATR : na
    score += na(orVsAtr) ? 0 : orVsAtr <= 0.25 ? 10 : orVsAtr <= 0.5 ? 5 : orVsAtr <= 0.75 ? 0 : -10
    float gapAligned = na(godGapPct) ? na : isUp ? godGapPct : -godGapPct
    score += na(gapAligned) ? 0 : gapAligned >= 0.5 ? 8 : gapAligned <= -0.5 ? -8 : 0
    score += (isUp ? godHighConfluence : godLowConfluence) ? 12 : 0
    int priorBreaks = (isUp ? sessionBreakoutsUp : sessionBreakoutsDown) - 1
    score -= math.min(math.max(priorBreaks, 0) * 5, 15)
    if godChopDay
        score := math.min(score, 40)
    math.max(0.0, math.min(100.0, score))

// site message (fixed — not in Settings; mid-script so it is not at file end)
showSitePromo = true
promoIntervalMin = 7
promoHighlightSec = 30
promoMsg = "For more indicators & strategies\nvisit trading.xcelerate.trade"
promoIntervalMs = promoIntervalMin * 60 * 1000
promoVisibleMs = promoHighlightSec * 1000
var table sitePromoTbl = na
varip int promoHiddenAnchorMs = -1
varip int promoVisibleAnchorMs = -1
if showSitePromo and barstate.islast
    if na(sitePromoTbl)
        sitePromoTbl := table.new(position.middle_center, 1, 1, border_width=0, frame_color=color.new(color.black, 100), bgcolor=color.new(color.black, 100))
    nowMs = na(timenow) ? time_close : timenow
    if promoHiddenAnchorMs < 0 and promoVisibleAnchorMs < 0
        promoHiddenAnchorMs := nowMs
    if promoVisibleAnchorMs >= 0
        if nowMs - promoVisibleAnchorMs >= promoVisibleMs
            promoHiddenAnchorMs := nowMs
            promoVisibleAnchorMs := -1
    else if promoHiddenAnchorMs >= 0 and nowMs - promoHiddenAnchorMs >= promoIntervalMs
        promoVisibleAnchorMs := nowMs
    showPromoNow = promoVisibleAnchorMs >= 0 and nowMs - promoVisibleAnchorMs < promoVisibleMs
    if showPromoNow
        table.cell(sitePromoTbl, 0, 0, promoMsg, text_color=color.white, text_size=size.large, bgcolor=color.new(color.black, 25), text_halign=text.align_center)
    else
        table.cell(sitePromoTbl, 0, 0, "", bgcolor=color.new(color.black, 100), text_color=color.new(color.white, 100), text_size=size.large)

// ====================================== BREAKOUT DETECTION =========================================
canDetectBreakout = not isHTF and enableBreakout and not na(activeORB) and barstate.isconfirmed
volumeMA := cachedVolumeMA

// ============================= PENDING ENTRY PROCESSING (AFTER SIGNAL BAR → NEXT BAR CLOSE) ================
// Only lock ENTRY / SL / TP after the entry candle is CLOSED (no labels on a forming bar).
bool pendingLongDue = pendingLongEntry and bar_index > pendingLongBar and barstate.isconfirmed
bool pendingShortDue = pendingShortEntry and bar_index > pendingShortBar and barstate.isconfirmed
bool entryIsLong = pendingLongDue and not pendingShortDue  // both due -> short wins (matches old sequential overwrite)

if pendingLongDue or pendingShortDue
    if enableTargets
        // Get active ORB levels
        float activeHigh = not na(activeORB) ? activeORB.high : na
        float activeLow = not na(activeORB) ? activeORB.low : na

        if not na(activeHigh) and not na(activeLow)
            // Delete old lines first
            if not na(orbEntryLine)
                line.delete(orbEntryLine)
                orbEntryLine := na
            if not na(orbEntryLabel)
                label.delete(orbEntryLabel)
                orbEntryLabel := na
            if not na(orbSLLine)
                line.delete(orbSLLine)
                orbSLLine := na
            if not na(orbSLLabel)
                label.delete(orbSLLabel)
                orbSLLabel := na
            if not na(orbTP1Line)
                line.delete(orbTP1Line)
                orbTP1Line := na
            if not na(orbTP1Label)
                label.delete(orbTP1Label)
                orbTP1Label := na
            if not na(orbTP1_5Line)
                line.delete(orbTP1_5Line)
                orbTP1_5Line := na
            if not na(orbTP1_5Label)
                label.delete(orbTP1_5Label)
                orbTP1_5Label := na
            if not na(orbTP2Line)
                line.delete(orbTP2Line)
                orbTP2Line := na
            if not na(orbTP2Label)
                label.delete(orbTP2Label)
                orbTP2Label := na
            if not na(orbTP3Line)
                line.delete(orbTP3Line)
                orbTP3Line := na
            if not na(orbTP3Label)
                label.delete(orbTP3Label)
                orbTP3Label := na
            if not na(orbTP4Line)
                line.delete(orbTP4Line)
                orbTP4Line := na
            if not na(orbTP4Label)
                label.delete(orbTP4Label)
                orbTP4Label := na
            if not na(orbTP5Line)
                line.delete(orbTP5Line)
                orbTP5Line := na
            if not na(orbTP5Label)
                label.delete(orbTP5Label)
                orbTP5Label := na
            if not na(orbTP6Line)
                line.delete(orbTP6Line)
                orbTP6Line := na
            if not na(orbTP6Label)
                label.delete(orbTP6Label)
                orbTP6Label := na

            float entry = open
            float atr = cachedATR
            float sl = calculateStopLoss(entry, activeHigh, activeLow, activeHigh - activeLow, atr, stopMode, entryIsLong)
            [tp1, tp1_5, tp2, tp3, tp4, tp5, tp6] = calculateTargets(entry, sl, entryIsLong)

            [shares, posValue, maxLossCalc, riskAmount] = calculatePositionSize(entry, sl)

            orbEntryPrice := entry
            breakoutEntryPrice := entry  // Sync with global entry price
            orbEntryBar := bar_index
            orbLineColor := entryIsLong ? color.new(color.aqua, 0) : color.new(color.orange, 0)
            orbSLPrice := sl
            orbTP1Price := tp1
            orbTP1_5Price := tp1_5
            orbTP2Price := tp2
            orbTP3Price := tp3
            orbTP4Price := tp4
            orbTP5Price := tp5
            orbTP6Price := tp6
            orbLinesFrozen := false
            orbTP1Hit := false
            orbTP1_5Hit := false
            orbTP2Hit := false
            orbTP3Hit := false
            orbTP4Hit := false
            orbTP5Hit := false
            orbTP6Hit := false
            orbSLHit := false
            orbTradeDirection := entryIsLong ? 1 : -1

            maxShares := shares
            positionValue := posValue
            maxLoss := maxLossCalc

            // Entry line - ALWAYS shown
            orbEntryLine := line.new(orbEntryBar, orbEntryPrice, bar_index, orbEntryPrice, xloc=xloc.bar_index, extend=extend.none, color=orbLineColor, width=1, style=line.style_solid)
            cleanupLine(orbEntryLine)
            string entryText = labelFormat == "Simple" ? "ENTRY" : str.format("ENTRY: ${0}", str.tostring(orbEntryPrice, "#.##"))
            orbEntryLabel := label.new(orbEntryBar, orbEntryPrice, entryText, xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.white, color=orbLineColor, size=getLabelSize(labelSize))

            // SL and TP lines - only if showTPSLLines is enabled
            if showTPSLLines
                orbSLLine := line.new(orbEntryBar, orbSLPrice, bar_index, orbSLPrice, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.red, 0), width=1, style=line.style_solid)
                cleanupLine(orbSLLine)
                string slText = labelFormat == "Simple" ? "SL" : str.format("SL: ${0}", str.tostring(orbSLPrice, "#.##"))
                orbSLLabel := label.new(orbEntryBar, orbSLPrice, slText, xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.white, color=color.new(color.red, 0), size=getLabelSize(labelSize))

                if showTP1
                    orbTP1Line := line.new(orbEntryBar, orbTP1Price, bar_index, orbTP1Price, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.green, 0), width=1, style=line.style_solid)
                    cleanupLine(orbTP1Line)
                    float tp1Pct = ((entryIsLong ? orbTP1Price - entry : entry - orbTP1Price) / entry) * 100
                    string tp1Text = labelFormat == "Simple" ? "TP1" : str.format("TP1: ${0} +{1}%", str.tostring(orbTP1Price, "#.##"), str.tostring(tp1Pct, "#.#"))
                    orbTP1Label := label.new(orbEntryBar, orbTP1Price, tp1Text, xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.white, color=color.new(color.green, 0), size=getLabelSize(labelSize))

                if showTP1_5
                    orbTP1_5Line := line.new(orbEntryBar, orbTP1_5Price, bar_index, orbTP1_5Price, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.green, 0), width=1, style=line.style_solid)
                    cleanupLine(orbTP1_5Line)
                    float tp1_5Pct = ((entryIsLong ? orbTP1_5Price - entry : entry - orbTP1_5Price) / entry) * 100
                    string tp1_5Text = labelFormat == "Simple" ? "TP1.5" : str.format("TP1.5: ${0} +{1}%", str.tostring(orbTP1_5Price, "#.##"), str.tostring(tp1_5Pct, "#.#"))
                    orbTP1_5Label := label.new(orbEntryBar, orbTP1_5Price, tp1_5Text, xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.white, color=color.new(color.green, 0), size=getLabelSize(labelSize))

                if showTP2
                    orbTP2Line := line.new(orbEntryBar, orbTP2Price, bar_index, orbTP2Price, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.green, 0), width=1, style=line.style_solid)
                    cleanupLine(orbTP2Line)
                    float tp2Pct = ((entryIsLong ? orbTP2Price - entry : entry - orbTP2Price) / entry) * 100
                    string tp2Text = labelFormat == "Simple" ? "TP2" : str.format("TP2: ${0} +{1}%", str.tostring(orbTP2Price, "#.##"), str.tostring(tp2Pct, "#.#"))
                    orbTP2Label := label.new(orbEntryBar, orbTP2Price, tp2Text, xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.white, color=color.new(color.green, 0), size=getLabelSize(labelSize))

                if showTP3
                    orbTP3Line := line.new(orbEntryBar, orbTP3Price, bar_index, orbTP3Price, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.green, 0), width=1, style=line.style_solid)
                    cleanupLine(orbTP3Line)
                    float tp3Pct = ((entryIsLong ? orbTP3Price - entry : entry - orbTP3Price) / entry) * 100
                    string tp3Text = labelFormat == "Simple" ? "TP3" : str.format("TP3: ${0} +{1}%", str.tostring(orbTP3Price, "#.##"), str.tostring(tp3Pct, "#.#"))
                    orbTP3Label := label.new(orbEntryBar, orbTP3Price, tp3Text, xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.white, color=color.new(color.green, 0), size=getLabelSize(labelSize))

                if showTP4
                    orbTP4Line := line.new(orbEntryBar, orbTP4Price, bar_index, orbTP4Price, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.green, 0), width=1, style=line.style_solid)
                    cleanupLine(orbTP4Line)
                    float tp4Pct = ((entryIsLong ? orbTP4Price - entry : entry - orbTP4Price) / entry) * 100
                    string tp4Text = labelFormat == "Simple" ? "TP4" : str.format("TP4: ${0} +{1}%", str.tostring(orbTP4Price, "#.##"), str.tostring(tp4Pct, "#.#"))
                    orbTP4Label := label.new(orbEntryBar, orbTP4Price, tp4Text, xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.white, color=color.new(color.green, 0), size=getLabelSize(labelSize))

                if showTP5
                    orbTP5Line := line.new(orbEntryBar, orbTP5Price, bar_index, orbTP5Price, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.green, 0), width=1, style=line.style_solid)
                    cleanupLine(orbTP5Line)
                    float tp5Pct = ((entryIsLong ? orbTP5Price - entry : entry - orbTP5Price) / entry) * 100
                    string tp5Text = labelFormat == "Simple" ? "TP5" : str.format("TP5: ${0} +{1}%", str.tostring(orbTP5Price, "#.##"), str.tostring(tp5Pct, "#.#"))
                    orbTP5Label := label.new(orbEntryBar, orbTP5Price, tp5Text, xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.white, color=color.new(color.green, 0), size=getLabelSize(labelSize))

                if showTP6
                    orbTP6Line := line.new(orbEntryBar, orbTP6Price, bar_index, orbTP6Price, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.green, 0), width=1, style=line.style_solid)
                    cleanupLine(orbTP6Line)
                    float tp6Pct = ((entryIsLong ? orbTP6Price - entry : entry - orbTP6Price) / entry) * 100
                    string tp6Text = labelFormat == "Simple" ? "TP6" : str.format("TP6: ${0} +{1}%", str.tostring(orbTP6Price, "#.##"), str.tostring(tp6Pct, "#.#"))
                    orbTP6Label := label.new(orbEntryBar, orbTP6Price, tp6Text, xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.white, color=color.new(color.green, 0), size=getLabelSize(labelSize))

    // Trigger entry alert
    alertEntryTriggered := true

    if pendingLongDue
        pendingLongEntry := false
        pendingLongBar := na
    if pendingShortDue
        pendingShortEntry := false
        pendingShortBar := na

[bullFVG, bullTop, bullBottom] = detectBullishFVG()
[bearFVG, bearTop, bearBottom] = detectBearishFVG()

if bullFVG and showFVG and not na(activeORB)
    fvgBox = box.new(left=bar_index-2, top=bullTop, right=bar_index, bottom=bullBottom,
                     border_color=color.new(fvgBullColor, 0),
                     bgcolor=color.new(fvgBullColor, fvgTransparency),
                     border_width=1,
                     extend=extend.none)  // Changed from extend.right to extend.none
    array.push(fvgBoxes, fvgBox)
    array.push(fvgTops, bullTop)
    array.push(fvgBottoms, bullBottom)
    array.push(fvgIsBullish, true)
    array.push(fvgIsActive, true)
    array.push(fvgStartBar, bar_index-2)
    cleanupOldFVG()

if bearFVG and showFVG and not na(activeORB)
    fvgBox = box.new(left=bar_index-2, top=bearTop, right=bar_index, bottom=bearBottom,
                     border_color=color.new(fvgBearColor, 0),
                     bgcolor=color.new(fvgBearColor, fvgTransparency),
                     border_width=1,
                     extend=extend.none)  // Changed from extend.right to extend.none 
    array.push(fvgBoxes, fvgBox)
    array.push(fvgTops, bearTop)
    array.push(fvgBottoms, bearBottom)
    array.push(fvgIsBullish, false)
    array.push(fvgIsActive, true)
    array.push(fvgStartBar, bar_index-2)
    cleanupOldFVG()

if showFVG and array.size(fvgBoxes) > 0 and (barstate.isnew or barstate.islast)
    for i = 0 to array.size(fvgBoxes) - 1
        if array.get(fvgIsActive, i)
            fvgTop = array.get(fvgTops, i)
            fvgBottom = array.get(fvgBottoms, i)
            isBull = array.get(fvgIsBullish, i)
            startBar = array.get(fvgStartBar, i)
            currentBox = array.get(fvgBoxes, i)
            boxColor = isBull ? fvgBullColor : fvgBearColor

            fvgFilled = false
            if isBull
                fvgFilled := close < fvgBottom
            else
                fvgFilled := close > fvgTop
            
            if not na(currentBox)
                if fvgFilled
                    box.set_right(currentBox, bar_index)
                    box.set_border_style(currentBox, line.style_dashed)
                    array.set(fvgIsActive, i, false)
                    
                    if bar_index - array.get(fvgStartBar, i) > 10
                        box.delete(currentBox)
                        array.set(fvgBoxes, i, na)
                else
                    box.set_right(currentBox, bar_index)

// Entry mode flags (global — used by breakout, pullback, retest, rejection)
bool entryOnBreakout = entryMode == "Breakout" or entryMode == "Both"
bool entryOnRetest = entryMode == "Retest + Rejection" or entryMode == "Both"

// ======================= NEW ARCHITECTURE: BREAKOUT DETECTION WITH activeORB =======================
// Breakout confirms on close of the ACTIVE ORB stage TF (5/15/30/60), not the chart TF.
// Example: chart 5m + active ORB30 → wait for a 30m candle to close beyond ORB High/Low.
if not na(activeORB) and activeORB.isComplete and inSession and enableBreakout and barstate.isconfirmed

    activeHigh = activeORB.high
    activeLow = activeORB.low
    activeMid = activeORB.mid

    [sigClose, sigClosePrev, sigHigh, sigHighPrev, sigLow, sigLowPrev, orbStageJustClosed] = getOrbSignalBar(activeORB.minutes)

    float effBreakoutBuffer = godModeEnabled and godAdaptiveBuffer and nz(cachedATR) > 0 and close > 0 ? math.max(breakoutBuffer, cachedATR * 0.10 / close * 100) : breakoutBuffer
    activeBufferUp = getBuffer(activeHigh, effBreakoutBuffer)
    activeBufferDown = getBuffer(activeLow, effBreakoutBuffer)
    float breakLevelUp = activeHigh + activeBufferUp
    float breakLevelDown = activeLow - activeBufferDown
 
    volumeOK = not enableVolumeFilter or hasVolumeConfirmation(volumeMA, volumeMultiplier, strongVolumeMultiplier)

    trendOK_Up = not enableTrendFilter or isTrendUp(trendMode, close, trendVWAP, trendEMA12, trendEMACustom, trendSTDirection)
    trendOK_Down = not enableTrendFilter or isTrendDown(trendMode, close, trendVWAP, trendEMA12, trendEMACustom, trendSTDirection)

    // FIX: FVG filter was declared but never applied to signals
    fvgOK_Up = not enableFVGFilter or hasValidFVGNearLevel(activeHigh, true)
    fvgOK_Down = not enableFVGFilter or hasValidFVGNearLevel(activeLow, false)

    bool useWickBreak = breakoutConfirm == "Wick"
    bool crossedAbove = false
    bool crossedBelow = false
    if orbStageJustClosed and not na(sigClose) and not na(sigClosePrev)
        if useWickBreak
            crossedAbove := not na(sigHigh) and not na(sigHighPrev) and sigHigh > breakLevelUp and sigHighPrev <= breakLevelUp
            crossedBelow := not na(sigLow) and not na(sigLowPrev) and sigLow < breakLevelDown and sigLowPrev >= breakLevelDown
        else
            // Body Close: candle must finish beyond ORB
            crossedAbove := sigClose > breakLevelUp and sigClosePrev <= breakLevelUp
            crossedBelow := sigClose < breakLevelDown and sigClosePrev >= breakLevelDown

    if crossedAbove and volumeOK and trendOK_Up and fvgOK_Up and not activeORB.breakoutUp
        activeORB.breakoutUp := true
        activeORB.breakoutBar := bar_index
        activeORB.breakoutLevel := activeHigh
        activeORB.cyclesUp := activeORB.cyclesUp + 1
        cyclesUp := cyclesUp + 1
        hadRetestUp := false
        wentFarEnoughUp := false

        sessionBreakoutsUp := sessionBreakoutsUp + 1
        if godModeEnabled
            godLastScore := f_godScore(true)
            godLastScoreDir := "UP"
        

        everHadBreakUp := true
        hadBreakUp := true
        breakUpBar := bar_index
        breakUpBarIndex := bar_index
        
        tradeOrbHigh := activeORB.high
        tradeOrbLow := activeORB.low
        
        if showBreakLabels
            string breakText = ""
            if labelFormat == "Simple"
                breakText := "🔼 BREAKOUT UP #" + str.tostring(sessionBreakoutsUp)
            else  // Detailed
                float volRatio = volumeMA > 0 ? volume / volumeMA : 0
                string volText = volRatio >= strongVolumeMultiplier ? str.tostring(volRatio, "#.#") + "x ⚡" : volRatio >= volumeMultiplier ? str.tostring(volRatio, "#.#") + "x" : str.tostring(volRatio, "#.#") + "x ⚠️"
                breakText := "🔼 BREAKOUT UP\n" + activeORB.name + " #" + str.tostring(sessionBreakoutsUp) + "\nVol: " + volText
            if godModeEnabled and godShowScore and not na(godLastScore)
                breakText += "\n⚡ " + str.tostring(godLastScore, "#") + " (" + f_godGrade(godLastScore) + ")" + (godHighConfluence ? " 🏆" : "")

            float labelOffset = cachedATR * LABEL_OFFSET_ATR_MULTIPLIER
            float labelY = high + labelOffset

            breakLabel = label.new(bar_index, labelY, breakText, color = color.new(color.green, 0), textalign = text.align_center, style = label.style_label_down, textcolor = color.white, size = getLabelSize(labelSize))
            cleanupLabel(breakLabel)

        if enableAlerts and alertBreakouts
            alertMsg = "🔼 BREAKOUT UP" + str.tostring(sessionBreakoutsUp) + " - " + syminfo.ticker + " @ " + str.tostring(close, "#.##") + " | " + activeORB.name + (godModeEnabled and not na(godLastScore) ? " | ⚡" + str.tostring(godLastScore, "#") + " " + f_godGrade(godLastScore) : "")
            sendAlert(alertMsg)
            alertBreakUpTriggered := true  // FIX: Set trigger for TradingView alerts

        // Entry on breakout / pullback / or wait for retest (must stay inside crossedAbove)
        awaitRejectUp := false
        if enablePullbackFilter and entryOnBreakout
            pbPendingLong := true
            pbExtremeLong := high
            pbBarLong := bar_index
            pbPulledLong := false
        else if entryOnBreakout
            pendingLongEntry := true
            pendingLongBar := bar_index

    // === BREAKOUT DOWN ===
    if crossedBelow and volumeOK and trendOK_Down and fvgOK_Down and not activeORB.breakoutDown
        activeORB.breakoutDown := true
        activeORB.breakoutBar := bar_index
        activeORB.breakoutLevel := activeLow
        activeORB.cyclesDown := activeORB.cyclesDown + 1
        cyclesDown := cyclesDown + 1
        hadRetestDown := false
        wentFarEnoughDown := false

        sessionBreakoutsDown := sessionBreakoutsDown + 1
        if godModeEnabled
            godLastScore := f_godScore(false)
            godLastScoreDir := "DOWN"
        

        everHadBreakDown := true
        hadBreakDown := true
        breakDownBar := bar_index
        breakDownBarIndex := bar_index

        tradeOrbHigh := activeORB.high
        tradeOrbLow := activeORB.low

        if showBreakLabels
            string breakText = ""
            if labelFormat == "Simple"
                breakText := "🔽 BREAKOUT DOWN #" + str.tostring(sessionBreakoutsDown)
            else  // Detailed
                float volRatio = volumeMA > 0 ? volume / volumeMA : 0
                string volText = volRatio >= strongVolumeMultiplier ? str.tostring(volRatio, "#.#") + "x ⚡" : volRatio >= volumeMultiplier ? str.tostring(volRatio, "#.#") + "x" : str.tostring(volRatio, "#.#") + "x ⚠️"
                breakText := "🔽 BREAKOUT DOWN\n" + activeORB.name + " | #" + str.tostring(sessionBreakoutsDown) + "\nVol: " + volText
            if godModeEnabled and godShowScore and not na(godLastScore)
                breakText += "\n⚡ " + str.tostring(godLastScore, "#") + " (" + f_godGrade(godLastScore) + ")" + (godLowConfluence ? " 🏆" : "")
            
            float labelOffset = cachedATR * LABEL_OFFSET_ATR_MULTIPLIER
            float labelY = low - labelOffset

            breakLabel = label.new(bar_index, labelY, breakText, color = color.new(color.red, 0), style = label.style_label_up, textalign = text.align_center, textcolor = color.white, size = getLabelSize(labelSize)) 
            cleanupLabel(breakLabel)

        if enableAlerts and alertBreakouts
            alertMsg = "🔽 BREAKOUT DOWN #" + str.tostring(sessionBreakoutsDown) + " - " + syminfo.ticker + " @ " + str.tostring(close, "#.##") + " | " + activeORB.name + (godModeEnabled and not na(godLastScore) ? " | ⚡" + str.tostring(godLastScore, "#") + " " + f_godGrade(godLastScore) : "")
            sendAlert(alertMsg)
            alertBreakDownTriggered := true  // FIX: Set trigger for TradingView alerts

        awaitRejectDown := false
        if enablePullbackFilter and entryOnBreakout
            pbPendingShort := true
            pbExtremeShort := low
            pbBarShort := bar_index
            pbPulledShort := false
        else if entryOnBreakout
            pendingShortEntry := true
            pendingShortBar := bar_index

// ====================================== PULLBACK FILTER ENGINE ======================================
if not isHTF and enablePullbackFilter and barstate.isconfirmed
    float pbDistLong = not na(pbExtremeLong) ? pbExtremeLong * (pullbackPercent / 100) : na
    float pbDistShort = not na(pbExtremeShort) ? pbExtremeShort * (pullbackPercent / 100) : na

    if pbPendingLong
        pbExtremeLong := math.max(nz(pbExtremeLong, high), high)
        if not pbPulledLong and not na(pbDistLong) and low <= pbExtremeLong - pbDistLong
            pbPulledLong := true
        bool pbTimeoutLong = bar_index - pbBarLong >= pullbackTimeout
        bool pbContinueLong = pbPulledLong and close >= pbExtremeLong
        if pbContinueLong or pbTimeoutLong
            pendingLongEntry := true
            pendingLongBar := bar_index
            pbPendingLong := false
            pbPulledLong := false

    if pbPendingShort
        pbExtremeShort := math.min(nz(pbExtremeShort, low), low)
        if not pbPulledShort and not na(pbDistShort) and high >= pbExtremeShort + pbDistShort
            pbPulledShort := true
        bool pbTimeoutShort = bar_index - pbBarShort >= pullbackTimeout
        bool pbContinueShort = pbPulledShort and close <= pbExtremeShort
        if pbContinueShort or pbTimeoutShort
            pendingShortEntry := true
            pendingShortBar := bar_index
            pbPendingShort := false
            pbPulledShort := false

// ====================================== BARS OUTSIDE TRACKING ======================================
if not isHTF and barstate.isconfirmed
    
    if hadBreakUp and bar_index > breakUpBarIndex
        if close > tradeOrbHigh
            barsOutsideAfterBreakUp += 1
            
            minRetestDistance = tradeOrbHigh * (minRetestDistancePct / 100)
            if close > tradeOrbHigh + minRetestDistance
                wentFarEnoughUp := true
        else
            barsOutsideAfterBreakUp := 0

    if hadBreakDown and bar_index > breakDownBarIndex
        if close < tradeOrbLow
            barsOutsideAfterBreakDown += 1
            
            minRetestDistance = tradeOrbLow * (minRetestDistancePct / 100)
            if close < tradeOrbLow - minRetestDistance
                wentFarEnoughDown := true
        else
            barsOutsideAfterBreakDown := 0

// ======================================= RETEST DETECTION ==========================================
if not isHTF and (enableRetest or entryOnRetest) and haveRange and barstate.isconfirmed
        
    retestBufferCalc = getBuffer(actH, retestBuffer)
        
    if hadBreakUp and not hadRetestUp
        wentFarEnough = wentFarEnoughUp
        
        isCommittedBreakout = barsOutsideAfterBreakUp >= minBarsOutside
        
        priceBackInside = close < tradeOrbHigh + retestBufferCalc and close > tradeOrbLow - retestBufferCalc
        
        barsSinceBreak = bar_index - breakUpBarIndex
        isFailedBreak = everHadBreakUp and barsSinceBreak > 0 and barsSinceBreak <= MAX_BARS_FAILED_BREAK and priceBackInside and not isCommittedBreakout
        if isFailedBreak
            if not na(lastBreakUpLabel)
                label.set_text(lastBreakUpLabel, "⚠️ FAILED BREAK")
                label.set_color(lastBreakUpLabel, color.new(color.orange, 0))

            if alertFailedBreaks
                orbStageName = not na(activeORB) ? activeORB.name : "None"
                alertMsgFailedUp := "⚠️ FAILED BREAK UP - " + syminfo.ticker + " @ $" + str.tostring(close, "#.##") + " | " + orbStageName + " - Price back inside range after " + str.tostring(barsSinceBreak) + " bars"
                sendAlert(alertMsgFailedUp)
                alertFailedUpTriggered := true
            
            

            if cyclesUp > 0
                cyclesUp -= 1
            
            godFailedBreaks += 1
            hadBreakUp := false
            barsOutsideAfterBreakUp := 0
            if not na(activeORB)
                activeORB.breakoutUp := false
        
        else if wentFarEnough and priceBackInside and isCommittedBreakout
            hadRetestUp := true
            retestUpBar := bar_index
            barsOutsideAfterBreakUp := 0
            
            if signalMode == "Track Cycles"
                hadBreakUp := false
                if not na(activeORB)
                    activeORB.breakoutUp := false

            showRetestLabel = enableRetest
            if signalMode == "Track Cycles"
                showRetestLabel := enableRetest and retestCyclesUp < maxCycles
            
            if showRetestLabel
                retestCyclesUp += 1
                sessionRetestsUp += 1
                
                retestText = str.format("🔁 RETEST UP #{0}", str.tostring(sessionRetestsUp))
                float labelOffset = cachedATR * LABEL_OFFSET_ATR_MULTIPLIER
                float labelY = high + labelOffset
                retestLabel = label.new(bar_index, labelY, retestText,
                          style=label.style_label_down,
                          color=color.new(color.orange, 20),
                          textcolor=color.white,
                          size=getLabelSize(labelSize))
                cleanupLabel(retestLabel)

                if alertRetests
                    orbStageName = not na(activeORB) ? activeORB.name : "None"
                    alertMsgRetestUp := "🔁 RETEST UP #" + str.tostring(retestCyclesUp) + " - " + syminfo.ticker + " @ $" + str.tostring(close, "#.##") + " | Back to " + orbStageName + " range"
                    sendAlert(alertMsgRetestUp)
                    alertRetestUpTriggered := true

            // Entry Mode: Retest (+ optional rejection)
            if entryOnRetest
                if requireRejectionClose
                    awaitRejectUp := true
                    awaitRejectUpBar := bar_index
                else
                    pendingLongEntry := true
                    pendingLongBar := bar_index
                    awaitRejectUp := false

                    
    if hadBreakDown and not hadRetestDown
        wentLowEnough = wentFarEnoughDown       
        isCommittedBreakout = barsOutsideAfterBreakDown >= minBarsOutside       
        priceBackInside = close > tradeOrbLow - retestBufferCalc and close < tradeOrbHigh + retestBufferCalc
        
        barsSinceBreak = bar_index - breakDownBarIndex
        isFailedBreak = everHadBreakDown and barsSinceBreak > 0 and barsSinceBreak <= MAX_BARS_FAILED_BREAK and priceBackInside and not isCommittedBreakout
        if isFailedBreak
            if not na(lastBreakDownLabel)
                label.set_text(lastBreakDownLabel, "⚠️ FAILED BREAK")
                label.set_color(lastBreakDownLabel, color.new(color.orange, 0))
            
            if alertFailedBreaks
                orbStageName = not na(activeORB) ? activeORB.name : "None"
                alertMsgFailedDown := "⚠️ FAILED BREAK DOWN - " + syminfo.ticker + " @ $" + str.tostring(close, "#.##") + " | " + orbStageName + " - Price back inside range after " + str.tostring(barsSinceBreak) + " bars"
                sendAlert(alertMsgFailedDown)
                alertFailedDownTriggered := true
            
            

            if cyclesDown > 0
                cyclesDown -= 1
            
            godFailedBreaks += 1
            hadBreakDown := false
            barsOutsideAfterBreakDown := 0
            if not na(activeORB)
                activeORB.breakoutDown := false
        
        else if wentLowEnough and priceBackInside and isCommittedBreakout
            hadRetestDown := true
            retestDownBar := bar_index
            barsOutsideAfterBreakDown := 0
            
            if signalMode == "Track Cycles"
                hadBreakDown := false
                if not na(activeORB)
                    activeORB.breakoutDown := false
            
            showRetestLabel = enableRetest
            if signalMode == "Track Cycles"
                showRetestLabel := enableRetest and retestCyclesDown < maxCycles
            
            if showRetestLabel
                retestCyclesDown += 1
                sessionRetestsDown += 1
                
                retestText = str.format("🔁 RETEST DOWN #{0}", str.tostring(sessionRetestsDown))
                
                float labelOffset = cachedATR * LABEL_OFFSET_ATR_MULTIPLIER
                float labelY = low - labelOffset
                retestLabel = label.new(bar_index, labelY, retestText,
                          style=label.style_label_up,
                          color=color.new(color.orange, 20),
                          textcolor=color.white,
                          size=getLabelSize(labelSize))
                cleanupLabel(retestLabel)

                if alertRetests
                    orbStageName = not na(activeORB) ? activeORB.name : "None"
                    alertMsgRetestDown := "🔁 RETEST DOWN #" + str.tostring(retestCyclesDown) + " - " + syminfo.ticker + " @ $" + str.tostring(close, "#.##") + " | Back to " + orbStageName + " range"
                    sendAlert(alertMsgRetestDown)
                    alertRetestDownTriggered := true

            if entryOnRetest
                if requireRejectionClose
                    awaitRejectDown := true
                    awaitRejectDownBar := bar_index
                else
                    pendingShortEntry := true
                    pendingShortBar := bar_index
                    awaitRejectDown := false


isBullish = everHadBreakUp
entry = orbEntryPrice
sl = orbSLPrice
tp1 = orbTP1Price
tp1_5 = orbTP1_5Price
tp2 = orbTP2Price
tp3 = orbTP3Price
tp4 = orbTP4Price
tp5 = orbTP5Price
tp6 = orbTP6Price
atr = cachedATR


// ====================================== RETEST REJECTION ENTRY ======================================
// Xcelerate Academy style: after retest, require ORB-stage TF close back beyond ORB boundary, then entry next bar
if not isHTF and barstate.isconfirmed and entryOnRetest and requireRejectionClose
    float rejBufUp = getBuffer(nz(tradeOrbHigh, actH), retestBuffer)
    float rejBufDn = getBuffer(nz(tradeOrbLow, actL), retestBuffer)
    int rejOrbMins = not na(activeORB) ? activeORB.minutes : stage > 0 ? stage : 5
    [rejClose, rejClosePrev, rejJustClosed] = getOrbSignalClose(rejOrbMins)

    if awaitRejectUp and not na(tradeOrbHigh)
        if bar_index - awaitRejectUpBar > math.max(pullbackTimeout, 15)
            awaitRejectUp := false
        else if rejJustClosed and not na(rejClose) and rejClose > tradeOrbHigh + rejBufUp
            pendingLongEntry := true
            pendingLongBar := bar_index
            awaitRejectUp := false
            if showBreakLabels
                float labelOffsetR = nz(cachedATR, 0) * LABEL_OFFSET_ATR_MULTIPLIER
                rejLabel = label.new(bar_index, high + labelOffsetR, "ENTRY RETEST UP", style=label.style_label_down, color=color.new(color.aqua, 0), textcolor=color.white, size=getLabelSize(labelSize))
                cleanupLabel(rejLabel)

    if awaitRejectDown and not na(tradeOrbLow)
        if bar_index - awaitRejectDownBar > math.max(pullbackTimeout, 15)
            awaitRejectDown := false
        else if rejJustClosed and not na(rejClose) and rejClose < tradeOrbLow - rejBufDn
            pendingShortEntry := true
            pendingShortBar := bar_index
            awaitRejectDown := false
            if showBreakLabels
                float labelOffsetR = nz(cachedATR, 0) * LABEL_OFFSET_ATR_MULTIPLIER
                rejLabel = label.new(bar_index, low - labelOffsetR, "ENTRY RETEST DOWN", style=label.style_label_up, color=color.new(color.orange, 0), textcolor=color.white, size=getLabelSize(labelSize))
                cleanupLabel(rejLabel)

// ========================================== EDGE LABELS ============================================
if not isHTF and showEdgeLabels and haveDisplayRange

    edgeStageChanged = stage != lastLabelStage
    priceChangedH = displayH != lastLabelH
    priceChangedL = displayL != lastLabelL
    labelsExist = not na(labH) and not na(labL)
    needsUpdate = edgeStageChanged or priceChangedH or priceChangedL or not labelsExist
    
    if needsUpdate
        labelColor = color.new(cachedLineColor, 0)
        
        if na(labH)
            labH := label.new(bar_index + LABEL_OFFSET_BARS, displayH, cachedStageName, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=labelColor, textcolor=color.white, size=getLabelSize(labelSize))
        else
            label.set_y(labH, displayH)
            if edgeStageChanged
                label.set_text(labH, cachedStageName)
                label.set_color(labH, labelColor)
        
        if na(labL)
            labL := label.new(bar_index + LABEL_OFFSET_BARS, displayL, cachedStageName, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=labelColor, textcolor=color.white, size=getLabelSize(labelSize))
        else
            label.set_y(labL, displayL)
            if edgeStageChanged
                label.set_text(labL, cachedStageName)
                label.set_color(labL, labelColor)
        
        lastLabelH := displayH
        lastLabelL := displayL
        lastLabelStage := stage
    
    if barstate.islast and not isHTF and haveDisplayRange
        if not na(labH)
            label.set_x(labH, bar_index + LABEL_OFFSET_BARS)
        if not na(labL)
            label.set_x(labL, bar_index + LABEL_OFFSET_BARS)

// ================================ TP/SL LINES UPDATE LOOP ==========================================
if not orbLinesFrozen and not na(orbEntryBar) and bar_index >= orbEntryBar
    if not na(orbEntryLine)
        line.set_x2(orbEntryLine, bar_index)
    if not na(orbEntryLabel)
        label.set_x(orbEntryLabel, bar_index)

    if not na(orbSLLine)
        line.set_x2(orbSLLine, bar_index)
    if not na(orbSLLabel)
        label.set_x(orbSLLabel, bar_index)

    if not na(orbTP1Line)
        line.set_x2(orbTP1Line, bar_index)
    if not na(orbTP1Label)
        label.set_x(orbTP1Label, bar_index)

    if not na(orbTP1_5Line)
        line.set_x2(orbTP1_5Line, bar_index)
    if not na(orbTP1_5Label)
        label.set_x(orbTP1_5Label, bar_index)

    if not na(orbTP2Line)
        line.set_x2(orbTP2Line, bar_index)
    if not na(orbTP2Label)
        label.set_x(orbTP2Label, bar_index)

    if not na(orbTP3Line)
        line.set_x2(orbTP3Line, bar_index)
    if not na(orbTP3Label)
        label.set_x(orbTP3Label, bar_index)

    if not na(orbTP4Line)
        line.set_x2(orbTP4Line, bar_index)
    if not na(orbTP4Label)
        label.set_x(orbTP4Label, bar_index)

    if not na(orbTP5Line)
        line.set_x2(orbTP5Line, bar_index)
    if not na(orbTP5Label)
        label.set_x(orbTP5Label, bar_index)

    if not na(orbTP6Line)
        line.set_x2(orbTP6Line, bar_index)
    if not na(orbTP6Label)
        label.set_x(orbTP6Label, bar_index)

if not orbLinesFrozen and not na(orbEntryPrice) and barstate.isconfirmed

    bool isLongTrade = orbTradeDirection == 1

    if not orbTP1Hit and not na(orbTP1Price) and showTP1 and bar_index >= orbEntryBar and (isLongTrade ? high >= orbTP1Price : low <= orbTP1Price)
        orbTP1Hit := true
        alertTP1Triggered := true  // Trigger TP1 alert
        if not na(orbTP1Label)
            string tp1Text = labelFormat == "Simple" ? "✅ TP1" : str.format("✅ TP1: ${0}", str.tostring(orbTP1Price, "#.##"))
            label.set_text(orbTP1Label, tp1Text)
            label.set_color(orbTP1Label, color.new(color.green, 0))
        if not na(orbTP1Line)
            line.set_color(orbTP1Line, color.new(color.green, 0))

    if not orbTP1_5Hit and not na(orbTP1_5Price) and showTP1_5 and bar_index >= orbEntryBar and (isLongTrade ? high >= orbTP1_5Price : low <= orbTP1_5Price)
        orbTP1_5Hit := true
        alertTP1_5Triggered := true  // Trigger TP1.5 alert
        if not na(orbTP1_5Label)
            string tp1_5Text = labelFormat == "Simple" ? "✅ TP1.5" : str.format("✅ TP1.5: ${0}", str.tostring(orbTP1_5Price, "#.##"))
            label.set_text(orbTP1_5Label, tp1_5Text)
            label.set_color(orbTP1_5Label, color.new(color.green, 0))
        if not na(orbTP1_5Line)
            line.set_color(orbTP1_5Line, color.new(color.green, 0))

    if not orbTP2Hit and not na(orbTP2Price) and showTP2 and bar_index >= orbEntryBar and (isLongTrade ? high >= orbTP2Price : low <= orbTP2Price)
        orbTP2Hit := true
        alertTP2Triggered := true  // Trigger TP2 alert
        if not na(orbTP2Label)
            string tp2Text = labelFormat == "Simple" ? "✅ TP2" : str.format("✅ TP2: ${0}", str.tostring(orbTP2Price, "#.##"))
            label.set_text(orbTP2Label, tp2Text)
            label.set_color(orbTP2Label, color.new(color.green, 0))
        if not na(orbTP2Line)
            line.set_color(orbTP2Line, color.new(color.green, 0))

    if not orbTP3Hit and not na(orbTP3Price) and showTP3 and bar_index >= orbEntryBar and (isLongTrade ? high >= orbTP3Price : low <= orbTP3Price)
        orbTP3Hit := true
        alertTP3Triggered := true  // Trigger TP3 alert
        if not na(orbTP3Label)
            string tp3Text = labelFormat == "Simple" ? "✅ TP3" : str.format("✅ TP3: ${0}", str.tostring(orbTP3Price, "#.##"))
            label.set_text(orbTP3Label, tp3Text)
            label.set_color(orbTP3Label, color.new(color.green, 0))
        if not na(orbTP3Line)
            line.set_color(orbTP3Line, color.new(color.green, 0))

    if not orbTP4Hit and not na(orbTP4Price) and showTP4 and bar_index >= orbEntryBar and (isLongTrade ? high >= orbTP4Price : low <= orbTP4Price)
        orbTP4Hit := true
        alertTP4Triggered := true
        if not na(orbTP4Label)
            string tp4Text = labelFormat == "Simple" ? "✅ TP4" : str.format("✅ TP4: ${0}", str.tostring(orbTP4Price, "#.##"))
            label.set_text(orbTP4Label, tp4Text)
            label.set_color(orbTP4Label, color.new(color.green, 0))
        if not na(orbTP4Line)
            line.set_color(orbTP4Line, color.new(color.green, 0))

    if not orbTP5Hit and not na(orbTP5Price) and showTP5 and bar_index >= orbEntryBar and (isLongTrade ? high >= orbTP5Price : low <= orbTP5Price)
        orbTP5Hit := true
        alertTP5Triggered := true
        if not na(orbTP5Label)
            string tp5Text = labelFormat == "Simple" ? "✅ TP5" : str.format("✅ TP5: ${0}", str.tostring(orbTP5Price, "#.##"))
            label.set_text(orbTP5Label, tp5Text)
            label.set_color(orbTP5Label, color.new(color.green, 0))
        if not na(orbTP5Line)
            line.set_color(orbTP5Line, color.new(color.green, 0))

    if not orbTP6Hit and not na(orbTP6Price) and showTP6 and bar_index >= orbEntryBar and (isLongTrade ? high >= orbTP6Price : low <= orbTP6Price)
        orbTP6Hit := true
        alertTP6Triggered := true
        if not na(orbTP6Label)
            string tp6Text = labelFormat == "Simple" ? "✅ TP6" : str.format("✅ TP6: ${0}", str.tostring(orbTP6Price, "#.##"))
            label.set_text(orbTP6Label, tp6Text)
            label.set_color(orbTP6Label, color.new(color.green, 0))
        if not na(orbTP6Line)
            line.set_color(orbTP6Line, color.new(color.green, 0))

    // Freeze when the highest enabled TP is hit
    lastTPHit = showTP6 ? orbTP6Hit : showTP5 ? orbTP5Hit : showTP4 ? orbTP4Hit : showTP3 ? orbTP3Hit : showTP2 ? orbTP2Hit : showTP1_5 ? orbTP1_5Hit : showTP1 ? orbTP1Hit : false

    if lastTPHit
        orbLinesFrozen := true

    if not orbSLHit and not na(orbSLPrice) and bar_index >= orbEntryBar and (isLongTrade ? low <= orbSLPrice : high >= orbSLPrice)
        orbSLHit := true
        alertSLTriggered := true  // Trigger SL alert
        orbLinesFrozen := true
        // Reset breakout flag to allow new breakouts after SL hit
        if not na(activeORB)
            if isLongTrade
                activeORB.breakoutUp := false
            else
                activeORB.breakoutDown := false
        if not na(orbSLLabel)
            string slText = labelFormat == "Simple" ? "❌ SL" : str.format("❌ SL: ${0}", str.tostring(orbSLPrice, "#.##"))
            label.set_text(orbSLLabel, slText)

    if freezeOnEOD and not inSession and inSession[1]
        orbLinesFrozen := true

// ===================== REAL-TIME TP TRACKING & TRADE CLOSE DETECTION ==============================
bool cyclesChanged = (cyclesUp != prevCyclesUp) or (cyclesDown != prevCyclesDown)
bool newBreakoutDetected = not na(orbEntryBar) and (na(prevOrbEntryBar) or orbEntryBar != prevOrbEntryBar or cyclesChanged)

if newBreakoutDetected
    trade_closed := false
    prevOrbEntryBar := orbEntryBar
    prevCyclesUp := cyclesUp
    prevCyclesDown := cyclesDown
    current_trade_r := 0.0
    tp1_counted := false
    tp1_5_counted := false
    tp2_counted := false
    tp3_counted := false
    tp4_counted := false
    tp5_counted := false
    tp6_counted := false

bool hasActiveBreakout = (everHadBreakUp or everHadBreakDown) and not na(orbEntryBar)

if hasActiveBreakout and not trade_closed

    // STEP 1: CALCULATE CURRENT TRADE R (Real-time)
    current_trade_r := 0.0
    
    if orbTP6Hit and showTP6
        current_trade_r := 6.0
    else if orbTP5Hit and showTP5
        current_trade_r := 5.0
    else if orbTP4Hit and showTP4
        current_trade_r := 4.0
    else if orbTP3Hit and showTP3
        current_trade_r := 3.0
    else if orbTP2Hit and showTP2
        current_trade_r := 2.0
    else if orbTP1_5Hit and showTP1_5
        current_trade_r := 1.5
    else if orbTP1Hit and showTP1
        current_trade_r := 1.0

    // STEP 2: CHECK TRADE CLOSE CONDITIONS (highest enabled TP wins)
    bool lastTPisTP6 = showTP6
    bool lastTPisTP5 = showTP5 and not showTP6
    bool lastTPisTP4 = showTP4 and not showTP5 and not showTP6
    bool lastTPisTP3 = showTP3 and not showTP4 and not showTP5 and not showTP6
    bool lastTPisTP2 = showTP2 and not showTP3 and not showTP4 and not showTP5 and not showTP6
    bool lastTPisTP1_5 = showTP1_5 and not showTP2 and not showTP3 and not showTP4 and not showTP5 and not showTP6
    bool lastTPisTP1 = showTP1 and not showTP1_5 and not showTP2 and not showTP3 and not showTP4 and not showTP5 and not showTP6
    
    bool shouldClose = false
    string resultText = ""
    bool isWin = false

    if orbSLHit
        shouldClose := true
        isWin := false
        current_trade_r := -1.0
        resultText := "SL  ·  −1R"

    else if (orbTP6Hit and lastTPisTP6) or (orbTP5Hit and lastTPisTP5) or (orbTP4Hit and lastTPisTP4) or (orbTP3Hit and lastTPisTP3) or (orbTP2Hit and lastTPisTP2) or (orbTP1_5Hit and lastTPisTP1_5) or (orbTP1Hit and lastTPisTP1)
        shouldClose := true
        isWin := true

        if orbTP6Hit and lastTPisTP6
            resultText := "TP6  ·  +6R"
        else if orbTP5Hit and lastTPisTP5
            resultText := "TP5  ·  +5R"
        else if orbTP4Hit and lastTPisTP4
            resultText := "TP4  ·  +4R"
        else if orbTP3Hit and lastTPisTP3
            resultText := "TP3  ·  +3R"
        else if orbTP2Hit and lastTPisTP2
            resultText := "TP2  ·  +2R"
        else if orbTP1_5Hit and lastTPisTP1_5
            resultText := "TP1.5  ·  +1.5R"
        else if orbTP1Hit and lastTPisTP1
            resultText := "TP1  ·  +1R"

    else if freezeOnEOD and not inSession and inSession[1]
        shouldClose := true

        if orbTradeDirection == 1  // LONG
            float riskDist = entry - sl
            float profitDist = close - entry
            current_trade_r := riskDist > 0 ? profitDist / riskDist : 0.0
        else if orbTradeDirection == -1  // SHORT
            float riskDist = sl - entry
            float profitDist = entry - close
            current_trade_r := riskDist > 0 ? profitDist / riskDist : 0.0

        isWin := current_trade_r > 0

        string eodIcon = current_trade_r > 0 ? "✅" : current_trade_r < 0 ? "❌" : "⚖️"
        resultText := str.format("{0} EOD Close: {1}R", eodIcon, str.tostring(current_trade_r, "#.#"))
    
    // STEP 3: CLOSE TRADE & UPDATE SESSION STATS
    if shouldClose and not trade_closed
        trade_closed := true
        session_trades += 1

        session_total_rr += current_trade_r

        if isWin
            session_wins += 1
            session_best_r := math.max(session_best_r, current_trade_r)
        else
            session_losses += 1
            session_worst_r := math.min(session_worst_r, current_trade_r)

        last_trade_result := resultText

// ====================== DYNAMIC ORB VISUALIZATION (BUILDING PHASE) ================================
float plotORB5High = na
float plotORB5Low = na
float plotORB5Mid = na
float plotORB15High = na
float plotORB15Low = na
float plotORB15Mid = na
float plotORB30High = na
float plotORB30Low = na
float plotORB30Mid = na
float plotORB60High = na
float plotORB60Low = na
float plotORB60Mid = na

ORBData lastEnabledORB = na
for orbObj in allORBs
    if orbObj.isEnabled
        if na(lastEnabledORB) or orbObj.minutes > lastEnabledORB.minutes
            lastEnabledORB := orbObj

if not isHTF and inSession

    float barEndTime = time + (currentTF_seconds * 1000)
    float minsFromOpenToEndOfBar = not na(sessionFirstBarTime) ? (barEndTime - sessionFirstBarTime) / 60000 : -1
 
    if orb5Obj.isEnabled and orb5Obj.minutes >= currentTF_minutes
        prevOrb = array.get(cachedPrevORBs, 0)
        nextOrb = array.get(cachedNextORBs, 0)
        
        bool prevOrbVisible = na(prevOrb) ? false : prevOrb.minutes >= currentTF_minutes
        float startMin = -1.0  // Special case for first ORB            
        float endMin = na(nextOrb) ? 9999.0 : orb5Obj.minutes -1
        bool inWindow = minsFromOpen > startMin and minsFromOpen <= endMin
        bool hasData = not na(orb5Obj.high) and not na(orb5Obj.low)
        
        if inWindow and hasData
            plotORB5High := orb5Obj.high
            plotORB5Low := orb5Obj.low
            plotORB5Mid := orb5Obj.mid
        else
            plotORB5High := na
            plotORB5Low := na
            plotORB5Mid := na
    else
        plotORB5High := na
        plotORB5Low := na
        plotORB5Mid := na

    if orb15Obj.isEnabled and orb15Obj.minutes >= currentTF_minutes
        prevOrb = getPreviousEnabledORB(orb15Obj)
        nextOrb = getNextEnabledORB(orb15Obj)

        bool prevOrbVisible = na(prevOrb) ? false : prevOrb.minutes >= currentTF_minutes
        float startMin = na(prevOrb) or not prevOrbVisible ? 0.0 : prevOrb.minutes - 1 
        float endMin = na(nextOrb) ? 9999.0 : orb15Obj.minutes
        bool startsBeforeEnd = minsFromOpen < endMin
        bool endsAfterStart = minsFromOpenToEndOfBar > startMin
        bool inWindow = startsBeforeEnd and endsAfterStart
        bool hasData = not na(orb15Obj.high) and not na(orb15Obj.low)
        
        if inWindow and hasData
            plotORB15High := orb15Obj.high
            plotORB15Low := orb15Obj.low
            plotORB15Mid := orb15Obj.mid
        else
            plotORB15High := na
            plotORB15Low := na
            plotORB15Mid := na
    else
        plotORB15High := na
        plotORB15Low := na
        plotORB15Mid := na

    if orb30Obj.isEnabled and orb30Obj.minutes >= currentTF_minutes
        prevOrb = getPreviousEnabledORB(orb30Obj)
        nextOrb = getNextEnabledORB(orb30Obj)

        bool prevOrbVisible = na(prevOrb) ? false : prevOrb.minutes >= currentTF_minutes
        float startMin = na(prevOrb) or not prevOrbVisible ? 0.0 : prevOrb.minutes - 1
        float endMin = na(nextOrb) ? 9999.0 : orb30Obj.minutes
        bool startsBeforeEnd = minsFromOpen < endMin
        bool endsAfterStart = minsFromOpenToEndOfBar > startMin
        bool inWindow = startsBeforeEnd and endsAfterStart
        bool hasData = not na(orb30Obj.high) and not na(orb30Obj.low)
        
        if inWindow and hasData
            plotORB30High := orb30Obj.high
            plotORB30Low := orb30Obj.low
            plotORB30Mid := orb30Obj.mid
        else
            plotORB30High := na
            plotORB30Low := na
            plotORB30Mid := na
    else
        plotORB30High := na
        plotORB30Low := na
        plotORB30Mid := na

    if orb60Obj.isEnabled and orb60Obj.minutes >= currentTF_minutes
        prevOrb = getPreviousEnabledORB(orb60Obj)
        nextOrb = getNextEnabledORB(orb60Obj)

        bool prevOrbVisible = na(prevOrb) ? false : prevOrb.minutes >= currentTF_minutes
        float startMin = na(prevOrb) or not prevOrbVisible ? 0.0 : prevOrb.minutes - 1
        float endMin = 9999.0 
        bool startsBeforeEnd = minsFromOpen < endMin
        bool endsAfterStart = minsFromOpenToEndOfBar > startMin
        bool inWindow = startsBeforeEnd and endsAfterStart
        bool hasData = not na(orb60Obj.high) and not na(orb60Obj.low)
        
        if inWindow and hasData
            plotORB60High := orb60Obj.high
            plotORB60Low := orb60Obj.low
            plotORB60Mid := orb60Obj.mid
        else
            plotORB60High := na
            plotORB60Low := na
            plotORB60Mid := na
    else
        plotORB60High := na
        plotORB60Low := na
        plotORB60Mid := na

// ORB plots — High/Low use separate colors from Inputs
p_orb5_high = plot(plotORB5High, title="ORB 5M High", color=color.new(orbHighColor, 0), linewidth=1, style=plot.style_linebr, display=display.all)
p_orb5_low = plot(plotORB5Low, title="ORB 5M Low", color=color.new(orbLowColor, 0), linewidth=1, style=plot.style_linebr, display=display.all)
fill(p_orb5_high, p_orb5_low, color=color.new(orbFillColor, showBG ? fillTransparency : 100), title="ORB 5M Fill")
plot(showMidLine ? plotORB5Mid : na, title="ORB 5M Mid", color=color.new(orbHighColor, 30), linewidth=1, style=plot.style_linebr, display=display.all)

p_orb15_high = plot(plotORB15High, title="ORB 15M High", color=color.new(orbHighColor, 0), linewidth=1, style=plot.style_linebr, display=display.all)
p_orb15_low = plot(plotORB15Low, title="ORB 15M Low", color=color.new(orbLowColor, 0), linewidth=1, style=plot.style_linebr, display=display.all)
fill(p_orb15_high, p_orb15_low, color=color.new(orbFillColor, showBG ? fillTransparency : 100), title="ORB 15M Fill")
plot(showMidLine ? plotORB15Mid : na, title="ORB 15M Mid", color=color.new(orbHighColor, 30), linewidth=1, style=plot.style_linebr, display=display.all)

p_orb30_high = plot(plotORB30High, title="ORB 30M High", color=color.new(orbHighColor, 0), linewidth=1, style=plot.style_linebr, display=display.all)
p_orb30_low = plot(plotORB30Low, title="ORB 30M Low", color=color.new(orbLowColor, 0), linewidth=1, style=plot.style_linebr, display=display.all)
fill(p_orb30_high, p_orb30_low, color=color.new(orbFillColor, showBG ? fillTransparency : 100), title="ORB 30M Fill")
plot(showMidLine ? plotORB30Mid : na, title="ORB 30M Mid", color=color.new(orbHighColor, 30), linewidth=1, style=plot.style_linebr, display=display.all)

p_orb60_high = plot(plotORB60High, title="ORB 60M High", color=color.new(orbHighColor, 0), linewidth=1, style=plot.style_linebr, display=display.all)
p_orb60_low = plot(plotORB60Low, title="ORB 60M Low", color=color.new(orbLowColor, 0), linewidth=1, style=plot.style_linebr, display=display.all)
fill(p_orb60_high, p_orb60_low, color=color.new(orbFillColor, showBG ? fillTransparency : 100), title="ORB 60M Fill")
plot(showMidLine ? plotORB60Mid : na, title="ORB 60M Mid", color=color.new(orbHighColor, 30), linewidth=1, style=plot.style_linebr, display=display.all)

// ============================================ DASHBOARD ============================================
var string cachedHTFBiasText = ""
var int lastHTFCheckBar = -1
var bool cachedHTFBullish = false
var bool cachedHTFBearish = false
var float cachedHTFStrength = 0.0
var bool shouldCheckHTF = false

var int lastDashStage = -1
var bool lastDashBreakUp = false
var bool lastDashBreakDown = false
var float lastDashOrbHigh = na
var float lastDashOrbLow = na
var bool lastDashTP1Hit = false
var bool lastDashTP1_5Hit = false
var bool lastDashTP2Hit = false
var bool lastDashTP3Hit = false
var bool lastDashTP4Hit = false
var bool lastDashTP5Hit = false
var bool lastDashTP6Hit = false
var bool lastDashSLHit = false

// Dashboard always renders when Show Info Panel is ON (fixed bottom-left).
// HTF/Daily Trend was removed from UI — do not gate the table on enableHTF.
if showDashboard
    bool dashStageChanged = stage != lastDashStage
    bool breakStateChanged = hadBreakUp != lastDashBreakUp or hadBreakDown != lastDashBreakDown
    bool orbLevelsChanged = not na(activeORB) and (activeORB.high != lastDashOrbHigh or activeORB.low != lastDashOrbLow)
    bool targetHitStateChanged = orbTP1Hit != lastDashTP1Hit or orbTP1_5Hit != lastDashTP1_5Hit or orbTP2Hit != lastDashTP2Hit or orbTP3Hit != lastDashTP3Hit or orbTP4Hit != lastDashTP4Hit or orbTP5Hit != lastDashTP5Hit or orbTP6Hit != lastDashTP6Hit or orbSLHit != lastDashSLHit
    bool forceUpdate = (bar_index - lastDashUpdateBar) >= 20
    bool dashDataChanged = barstate.islast and (dashStageChanged or breakStateChanged or orbLevelsChanged or targetHitStateChanged or forceUpdate)

    bool isDarkTheme = dashTheme == "Dark"
    // Modern professional palette (slate / charcoal — no neon aqua/red blocks)
    color bgColor = isDarkTheme ? #0B0F14 : #F5F6F8
    color txtColor = isDarkTheme ? #E6E8EB : #1C1F24
    color txtMuted = isDarkTheme ? #8B939E : #6B7280
    color headerColor = isDarkTheme ? #151C26 : #E8ECF1
    color accentBar = isDarkTheme ? #1E2A3A : #D9E2EC
    color rowBg = isDarkTheme ? #10161E : #FFFFFF
    color frameCol = isDarkTheme ? #2A3441 : #D1D5DB
    color accentLong = #3D8B6E
    color accentShort = #B85C5C
    tablePos = position.bottom_left
    txtSize = dashSize == "Tiny" ? size.tiny : dashSize == "Small" ? size.small : dashSize == "Large" ? size.large : dashSize == "Huge" ? size.huge : size.normal
    
    if showDashboard and na(dashTable)
        dashTable := table.new(tablePos, 2, 35, bgcolor=bgColor, border_width=0, frame_width=1, frame_color=frameCol, border_color=frameCol)
        table.clear(dashTable, 0, 0, 1, 34)
        table.set_position(dashTable, tablePos)
        lastDashUpdateBar := bar_index

    if showDashboard and not na(dashTable)
        lastDashUpdateBar := bar_index
        lastDashStage := stage
        lastDashBreakUp := hadBreakUp
        lastDashBreakDown := hadBreakDown
        if not na(activeORB)
            lastDashOrbHigh := activeORB.high
            lastDashOrbLow := activeORB.low
        lastDashTP1Hit := orbTP1Hit
        lastDashTP1_5Hit := orbTP1_5Hit
        lastDashTP2Hit := orbTP2Hit
        lastDashTP3Hit := orbTP3Hit
        lastDashTP4Hit := orbTP4Hit
        lastDashTP5Hit := orbTP5Hit
        lastDashTP6Hit := orbTP6Hit
        lastDashSLHit := orbSLHit
        
        table.clear(dashTable, 0, 0, 1, 34)
        table.set_position(dashTable, tablePos)

    int row = 0

    bool showFullDashboard = false
    string sessionIcon = ""
    string sessionStatusText = ""

    bool isMarketOpen = isTradingDay() and isWithinSessionHours()
    bool isDisplayWindow = isWithinDisplayHours()

    bool hasValidOrbData = not na(activeORB) or everHadBreakUp or everHadBreakDown or not na(orbEntryPrice)

    if isHTF
        sessionIcon := "!"
        sessionStatusText := "Use 5–60m chart"
        showFullDashboard := false
    else if isMarketOpen
        bool isRegularHours = isInRegularHours()
        sessionIcon := ""
        sessionStatusText := isRegularHours ? "Session open" : "Extended hours"
        showFullDashboard := true
    else if hadSessionToday and hasValidOrbData and isDisplayWindow and not isMarketOpen
        sessionIcon := ""

        bool useReplayTime = isReplayMode()
        int timeToCheck = useReplayTime ? time : timenow
        
        string sessionDate = not na(sessionStartTime) ? str.format_time(int(sessionStartTime), "MM/dd", syminfo.timezone) : "N/A"
        string currentDate = str.format_time(timeToCheck, "MM/dd", syminfo.timezone)

        if sessionDate == currentDate
            sessionStatusText := "After hours · " + sessionDate
        else
            sessionStatusText := "Prior session · " + sessionDate

        showFullDashboard := true
    else if not hadSessionToday and isDisplayWindow and isTradingDay() and enableExtendedHours
        sessionIcon := ""
        sessionStatusText := "Pre-market · waiting"
        showFullDashboard := false
    else
        sessionIcon := ""
        sessionStatusText := "Market closed"
        showFullDashboard := false

    // BUILD DASHBOARD
    if not showFullDashboard and not na(dashTable) and (dashDataChanged or forceUpdate)
        // Clear the full table range (table has 26 rows: 0..25)
        table.clear(dashTable, 0, 0, 1, 27)
        table.set_position(dashTable, tablePos)

        string statusTitle = sessionStatusText
        color statusBgColor = headerColor

        string statusTooltip = ""
        if isHTF
            statusTooltip := "ORB works only on timeframes 1-60 minutes.\n\nPlease switch to a lower timeframe to use ORB."
        else if not hadSessionToday and isDisplayWindow and isTradingDay() and enableExtendedHours
            statusTooltip := "Waiting for market open to build ORB.\n\nExtended hours trading is enabled.\nORB will start building at session start."
        else
            statusTooltip := "Market is closed.\n\nORB will activate during market hours."

        table.cell(dashTable, 0, 0, statusTitle, text_color=txtMuted, text_size=txtSize, text_halign=text.align_center, bgcolor=statusBgColor, tooltip=statusTooltip)
        table.cell(dashTable, 1, 0, "", bgcolor=statusBgColor)
        table.merge_cells(dashTable, 0, 0, 1, 0)
        
        lastDashUpdateBar := bar_index
        
    else if showFullDashboard and not na(dashTable)

        float entry = na
        float sl = na
        float tp1 = na
        float tp1_5 = na
        float tp2 = na
        float tp3 = na
        float tp4 = na
        float tp5 = na
        float tp6 = na
        float atr = na
        bool isBullish = false
        float shares = na
        float posValue = na
        float maxLossCalc = na
        float riskAmount = na
        float riskPctOfAcct = na
         
        // HEADER
        string headerTitle = "XCEL ORB"
        color headerBgColor = headerColor
        color headerTxt = txtColor
        string headerTooltip = "Xcelerate ORB · " + sessionStatusText + "\n\n"

        if isWithinDisplayHours() and isInRegularHours()
            headerTooltip += "Regular hours\n\n"
        else if isWithinDisplayHours() and not isInRegularHours()
            headerTooltip += "Extended hours\n\n"

        if everHadBreakUp
            headerTitle := "XCEL ORB  ·  LONG"
            headerBgColor := color.new(accentLong, 82)
            headerTooltip += "Breakout UP active\n"
        else if everHadBreakDown
            headerTitle := "XCEL ORB  ·  SHORT"
            headerBgColor := color.new(accentShort, 82)
            headerTooltip += "Breakout DOWN active\n"

        headerTooltip += "Opening Range Breakout status and trade setup."

        if not na(dashTable)
            table.cell(dashTable, 0, row, headerTitle, text_color=headerTxt, text_size=txtSize, text_halign=text.align_center, bgcolor=headerBgColor, tooltip=headerTooltip)
            table.cell(dashTable, 1, row, "", text_halign=text.align_center, bgcolor=headerBgColor)
            table.merge_cells(dashTable, 0, row, 1, row)
        row += 1

        if showStage and not na(activeORB)
            bool isMarketNow = isTradingDay() and isWithinSessionHours()
            bool showingPastData = hadSessionToday and not isMarketNow

            activeOrbText = showingPastData ? "Last  ·  " + activeORB.name : "Active  ·  " + activeORB.name
            
            // ENHANCED TOOLTIP: Time, Session, Market & ORB Details
            bool useReplayTime = isReplayMode()
            int timeToCheck = useReplayTime ? time : timenow
            string modeIndicator = useReplayTime ? " [REPLAY]" : " [LIVE]"

            string currentTime = str.format_time(timeToCheck, "HH:mm:ss", syminfo.timezone) + modeIndicator
            string currentDate = str.format_time(timeToCheck, "yyyy-MM-dd", syminfo.timezone)
            string barTime = str.format_time(time, "HH:mm:ss", syminfo.timezone)

            string chartTimezoneDisplay = "Unknown - Check: Right-click → Settings → Timezone"

            string timezoneHint = "\n\nℹ️ If time seems wrong:\n" + 
                                  "Your chart may be set to UTC, EST, or another timezone.\n" + 
                                  "To change: Right-click chart → Settings → Timezone\n\n" + 
                                  "Common settings:\n" + 
                                  "• Asia/Jerusalem (Israel time)\n" + 
                                  "• America/New_York (NYSE time)\n" + 
                                  "• UTC (Universal time - neutral)\n"

            string sessionDescription = ""
            if sessionMode == "New York"
                sessionDescription := "New York Session (EST / America/New_York)"
            else if sessionMode == "London"
                sessionDescription := "London Session (EST / America/New_York)"
            else if sessionMode == "Asia"
                sessionDescription := "Asia Session (EST / America/New_York)"
            else if sessionMode == "Auto-Detect"
                if syminfo.type == "stock" or syminfo.type == "fund" or syminfo.type == "index" or syminfo.type == "dr" or syminfo.type == "etf" or syminfo.type == "futures"
                    sessionDescription := "Exchange Hours (Auto-detected for " + syminfo.ticker + ")"
                else if syminfo.type == "crypto"
                    sessionDescription := "24/7 Trading"
                else
                    sessionDescription := "Auto-detected Session"
            else if sessionMode == "Custom"
                sessionDescription := "Custom Session (" + str.replace(tradingSession, ":23456", "") + ")"
            
            // === SESSION STATUS ===
            bool withinSessionHours = isWithinSessionHours()
            string sessionStatus = withinSessionHours ? "✅ OPEN" : "❌ CLOSED"

            string timeFromOpen = "N/A"
            
            if withinSessionHours and not na(sessionStartTime)
                int minutesElapsed = int((time - sessionStartTime) / 60000)
                int hours = int(minutesElapsed / 60)
                int mins = minutesElapsed % 60
                timeFromOpen := str.format("{0}h {1}m (OPEN)", hours, mins)
            else if not na(sessionStartTime)
                timeFromOpen := "Session Closed"
            
            // === ACTIVE ORB DETAILS ===
            string orbHighStr = str.tostring(activeORB.high, "#.####")
            string orbLowStr = str.tostring(activeORB.low, "#.####")
            string orbRangeStr = str.tostring(activeORB.orbRange, "#.####")
            string orbRangePct = str.tostring((activeORB.orbRange / activeORB.low) * 100, "#.##")
            
            // === BREAKOUT STATISTICS ===
            string breakoutStats = str.format("{0}↑ / {1}↓", activeORB.cyclesUp, activeORB.cyclesDown)
            int totalBreakouts = activeORB.cyclesUp + activeORB.cyclesDown
            
            // === MARKET DETECTION ===
            marketType = syminfo.type == "stock" ? "Stock" : syminfo.type == "crypto" ? "Crypto" : syminfo.type == "forex" ? "Forex" : syminfo.type
            resetTiming = is24_7Market ? "Midnight UTC (24/7 mode)" : "Session start: " + str.replace(tradingSession, ":23456", "") + " (" + sessionMode + ")"
            
            // === BUILD TOOLTIP ===
            if sessionMode == "New York"
                sessionDescription := "New York Session (EST / America/New_York)"
            else if sessionMode == "London"
                sessionDescription := "London Session (EST / America/New_York)"
            else if sessionMode == "Asia"
                sessionDescription := "Asia Session (EST / America/New_York)"
            else if sessionMode == "Auto-Detect"
                if syminfo.type == "stock" or syminfo.type == "fund" or syminfo.type == "index" or syminfo.type == "dr" or syminfo.type == "etf" or syminfo.type == "futures"
                    sessionDescription := "Exchange Hours (Auto-detected for " + syminfo.ticker + ")"
                else if syminfo.type == "crypto"
                    sessionDescription := "24/7 Trading"
                else
                    sessionDescription := "Auto-detected Session"
            else if sessionMode == "Custom"
                sessionDescription := "Custom Session (" + str.replace(tradingSession, ":23456", "") + ")"
            
            // === BUILD TOOLTIP ===
            bool is24_7 = syminfo.type == "crypto" or str.contains(tradingSession, "0000-2359")

            string sessionInfoSection = ""
            if not is24_7
                sessionInfoSection := "Time from session open: " + timeFromOpen + "\n\n" + "Session Definition: " + sessionDescription + "\n" + "Raw Session String: " + tradingSession + "\n\n"
            
            activeOrbTooltip = "Currently Active ORB\n\n" + 
                              "This is the ORB period being used for breakout detection.\n\n" + 
                              "• Breakouts are checked against THIS ORB only\n" + 
                              "• When a new ORB completes, it becomes active\n" + 
                              "• Priority: ORB 60M > ORB 30M > ORB 15M > ORB 5M\n\n" + 
                              
                              "─────────────────\n" + 
                              "⏰ CHART TIME DISPLAY\n" + 
                              "─────────────────\n" + 
                              "Date: " + currentDate + "\n" + 
                              "Current Bar: " + currentTime + "\n" + 
                              "Bar Open: " + barTime + "\n\n" + 
                              
                              "ℹ️ If time seems wrong:\n" + 
                              "Your chart may be set to UTC, EST, or another timezone.\n" + 
                              "To change: Right-click chart → Settings → Timezone\n\n" +

                              "─────────────────\n" + 
                              "📊 SESSION STATUS\n" + 
                              "─────────────────\n" + 
                              "Status: " + sessionStatus + "\n" + 
                              (is24_7 ? "" : "Time from session open: " + timeFromOpen + "\n\n" + 
                                             "Session Definition: " + sessionDescription + "\n" + 
                                             "Raw Session String: " + tradingSession + "\n\n")
            
            table.cell(dashTable, 0, row, activeOrbText, text_color=txtColor, text_size=txtSize, text_halign=text.align_center, bgcolor=accentBar, tooltip=activeOrbTooltip)
            table.cell(dashTable, 1, row, "", bgcolor=accentBar)
            table.merge_cells(dashTable, 0, row, 1, row)
            row += 1

        // Range info
        if showRange and not isHTF and not na(activeORB)
            orbRange = activeORB.high - activeORB.low
            rangePct = activeORB.low > 0 ? (orbRange / activeORB.low) * 100 : 0
            rangeTooltip = "ORB Range Size\n\nShows the width of the Opening Range in both dollars and percentage.\n\n• Large range (>1.5%) = High volatility\n• Medium range (0.5-1.5%) = Normal volatility\n• Small range (<0.5%) = Low volatility\n\nLarger ranges may require wider stops and smaller position sizes."
            
            table.cell(dashTable, 0, row, "Range", text_color=txtMuted, text_size=txtSize, text_halign=text.align_left, bgcolor=rowBg, tooltip=rangeTooltip)
            table.cell(dashTable, 1, row, str.format("${0}  ·  {1}%", str.tostring(orbRange, "#.##"), str.tostring(rangePct, "#.#")), text_color=txtColor, text_size=txtSize, text_halign=text.align_right, bgcolor=rowBg)
            row += 1
        
        // Volatility Meter
        if showVolatilityMeter and not isHTF
            float atrPct = cachedATR > 0 and close > 0 ? (cachedATR / close) * 100 : 0
            string volText = atrPct > 3.0 ? "Extreme" : atrPct > 2.0 ? "High" : atrPct > 1.0 ? "Medium" : "Low"
            color volCol = atrPct > 3.0 ? accentShort : atrPct > 2.0 ? color.new(#C4A35A, 0) : atrPct > 1.0 ? txtColor : txtMuted
            
            volTooltip = "Volatility (ATR % of price)\nCurrent: " + str.tostring(atrPct, "#.##") + "%\n\nExtreme >3% · High 2–3% · Medium 1–2% · Low <1%"
            
            table.cell(dashTable, 0, row, "Volatility", text_color=txtMuted, text_size=txtSize, text_halign=text.align_left, bgcolor=rowBg, tooltip=volTooltip)
            table.cell(dashTable, 1, row, volText + "  " + str.tostring(atrPct, "#.##") + "%", text_color=volCol, text_size=txtSize, text_halign=text.align_right, bgcolor=rowBg)
            row += 1


        // Volume (Xcelerate filter status)
        if showVol and enableVolumeFilter and not isHTF
            bool volRising = volume > nz(volume[1], volume)
            float volRatio = volumeMA > 0 ? volume / volumeMA : 0
            bool volOkNow = hasVolumeConfirmation(volumeMA, volumeMultiplier, strongVolumeMultiplier)
            string volStatus = volOkNow ? "OK" : "Weak"
            color volStatusCol = volOkNow ? accentLong : accentShort
            string volDetail = volumeMode == "Increasing" ? (volRising ? "Rising" : "Falling") : str.format("{0}× avg", str.tostring(volRatio, "#.#"))
            table.cell(dashTable, 0, row, "Volume", text_color=txtMuted, text_size=txtSize, text_halign=text.align_left, bgcolor=rowBg, tooltip="Xcelerate volume filter\nMode: " + volumeMode + "\n\nBreakout needs volume confirmation to reduce fakeouts.")
            table.cell(dashTable, 1, row, volDetail + "  ·  " + volStatus, text_color=volStatusCol, text_size=txtSize, text_halign=text.align_right, bgcolor=rowBg)
            row += 1
        
        // Trend
        if showTrend and not isHTF
            trendStatus = "➖ Neutral"
            if isTrendUp(trendMode, close, trendVWAP, trendEMA12, trendEMACustom, trendSTDirection)
                trendStatus := "✅ Bullish"
            else if isTrendDown(trendMode, close, trendVWAP, trendEMA12, trendEMACustom, trendSTDirection)
                trendStatus := "⚠️ Bearish"
            
            table.cell(dashTable, 0, row, "Trend:", text_color=txtColor, text_size=txtSize, text_halign=text.align_left)
            table.cell(dashTable, 1, row, trendStatus + (enableTrendFilter ? " (Filtered)" : ""), text_color=txtColor, text_size=txtSize, text_halign=text.align_right)
            row += 1
        
        // ORB Status Section - minimal spacer
        table.cell(dashTable, 0, row, "", text_color=txtColor, text_size=size.tiny)
        table.cell(dashTable, 1, row, "", text_color=txtColor, text_size=size.tiny)
        table.cell_set_height(dashTable, 0, row, 0.1)
        table.cell_set_height(dashTable, 1, row, 0.1)
        row += 1
    
        // ORB STATUS section - only show if enabled AND not on HTF
        if showStatus and not isHTF
            table.cell(dashTable, 0, row, "ORB STATUS", text_color=txtMuted, text_size=txtSize, text_halign=text.align_center, bgcolor=headerColor)
            table.cell(dashTable, 1, row, "", bgcolor=headerColor)
            table.merge_cells(dashTable, 0, row, 1, row)
            row += 1
            
            // Calculate end time of current bar for smart display (HTF compatibility)
            float barEndTime = time + (currentTF_seconds * 1000)
            float minsFromOpenToEndOfBar = not na(sessionFirstBarTime) ? (barEndTime - sessionFirstBarTime) / 60000 : -1
            
            // Show status of each ORB
            for i = 0 to array.size(allORBs) - 1
                orbObj = array.get(allORBs, i)
                if not na(orbObj) and orbObj.isEnabled
                    orbStatus = ""
                    orbIcon = ""
                    orbTooltip = ""
                    
                    // Smart display: Check if current bar COVERS the completion point
                    bool barCoversCompletion = minsFromOpen >= 0 and minsFromOpen < orbObj.minutes and minsFromOpenToEndOfBar >= orbObj.minutes
                    
                    if orbObj.isBuilding
                        if barCoversCompletion
                            // Display as complete even though internally still building
                            orbStatus := "Complete"
                            orbIcon := ""
                            orbTooltip := orbObj.name + " Status\n\nShowing COMPLETE because current bar covers the " + str.tostring(orbObj.minutes) + "-minute period.\n\nBar timeframe: " + timeframe.period + "\nBar covers: " + str.tostring(minsFromOpen, "#") + "-" + str.tostring(minsFromOpenToEndOfBar, "#") + " minutes from open\n\nInternal state: Still building (will finalize next bar)\nDisplay: Complete (user-friendly)"
                        else
                            orbStatus := "Building…"
                            orbIcon := ""
                            orbTooltip := orbObj.name + " Status\n\nCurrently building the " + str.tostring(orbObj.minutes) + "-minute range.\n\nTime elapsed: " + str.tostring(minsFromOpen, "#") + " minutes\nCompletion at: " + str.tostring(orbObj.minutes) + " minutes\n\nThe range is updating with each bar until completion."
                    else if orbObj.isComplete
                        cycleText = ""
                        if orbObj.cyclesUp > 0 or orbObj.cyclesDown > 0
                            cycleText := str.format("  ·  {0}↑ {1}↓", orbObj.cyclesUp, orbObj.cyclesDown)
                        
                        if not na(activeORB) and orbObj.name == activeORB.name
                            orbStatus := "Complete ★" + cycleText
                            orbIcon := ""
                            orbTooltip := orbObj.name + " Status\n\nCOMPLETE and ACTIVE\n\nThis is the current ORB being used for breakout detection.\n\nRange: $" + str.tostring(orbObj.low, "#.##") + " - $" + str.tostring(orbObj.high, "#.##") + "\nBreakouts: " + str.tostring(orbObj.cyclesUp) + " UP | " + str.tostring(orbObj.cyclesDown) + " DOWN"
                        else
                            orbStatus := "Complete" + cycleText
                            orbIcon := ""
                            orbTooltip := orbObj.name + " Status\n\nCOMPLETE (not active)\n\nThis ORB completed but a larger ORB is now active.\n\nRange: $" + str.tostring(orbObj.low, "#.##") + " - $" + str.tostring(orbObj.high, "#.##") + "\nBreakouts: " + str.tostring(orbObj.cyclesUp) + " UP | " + str.tostring(orbObj.cyclesDown) + " DOWN"
                    
                    table.cell(dashTable, 0, row, orbObj.name, text_color=txtMuted, text_size=txtSize, text_halign=text.align_left, bgcolor=rowBg, tooltip=orbTooltip)
                    table.cell(dashTable, 1, row, orbStatus, text_color=txtColor, text_size=txtSize, text_halign=text.align_right, bgcolor=rowBg)
                    row += 1

        /// Trade info section (only if ENTRY occurred AND targets enabled AND trade still active)
        if enableTargets and not na(orbEntryBar) and not trade_closed

            table.cell(dashTable, 0, row, "", text_color=txtColor, text_size=size.tiny)
            table.cell(dashTable, 1, row, "", text_color=txtColor, text_size=size.tiny)
            table.cell_set_height(dashTable, 0, row, 0.1)
            table.cell_set_height(dashTable, 1, row, 0.1)
            row += 1
            
            isBullish := everHadBreakUp
            entry := orbEntryPrice
            sl := orbSLPrice
            tp1 := orbTP1Price
            tp1_5 := orbTP1_5Price
            tp2 := orbTP2Price
            tp3 := orbTP3Price
            tp4 := orbTP4Price
            tp5 := orbTP5Price
            tp6 := orbTP6Price
            atr := cachedATR
            
            if enablePosSizing
                float displayShares = maxShares
                float displayPosValue = positionValue
                float displayRiskAmount = maxLoss
                
                if na(maxShares) or na(positionValue) or na(maxLoss)
                    // Show error state
                    table.cell(dashTable, 0, row, "⚠️ Position Error:", text_color=txtColor, text_size=txtSize, text_halign=text.align_left, tooltip="Position size calculation failed. Check Entry/SL values.")
                    table.cell(dashTable, 1, row, "Invalid Data", text_color=color.new(color.red, 0), text_size=txtSize, text_halign=text.align_right)
                    row += 1
                else

                    table.cell(dashTable, 0, row, "SETUP", text_color=txtMuted, text_size=txtSize, text_halign=text.align_center, bgcolor=headerColor)
                    table.cell(dashTable, 1, row, "", bgcolor=headerColor)
                    table.merge_cells(dashTable, 0, row, 1, row)
                    row += 1

                    string currencySymbol = accountCurrency == "EUR" ? "€" :
                                          accountCurrency == "GBP" ? "£" :
                                          accountCurrency == "JPY" ? "¥" :
                                          accountCurrency == "INR" ? "₹" :
                                          accountCurrency == "CAD" ? "C$" :
                                          accountCurrency == "AUD" ? "A$" :
                                          accountCurrency == "CHF" ? "Fr." :
                                          "$"
  
                    sharesTooltip = "Maximum Position Size in " + accountCurrency + "\n\nNumber of shares you can buy while staying within your risk limits.\n\nCALCULATED BY:\nRisk Amount ÷ Distance to Stop Loss\n\nEXAMPLE:\n• Risk: " + currencySymbol + "150\n• Entry: " + currencySymbol + "10.00\n• Stop: " + currencySymbol + "9.50 (50¢ distance)\n• Max Shares: 300 shares (" + currencySymbol + "150 ÷ " + currencySymbol + "0.50)\n• Position Value: " + currencySymbol + "3,000\n\nThis ensures consistent risk management across all trades.\n\n⚠️ FIXED at breakout - does not change with price!"
                    table.cell(dashTable, 0, row, "Size", text_color=txtMuted, text_size=txtSize, text_halign=text.align_left, bgcolor=rowBg, tooltip=sharesTooltip)
                    string sharesText = na(displayShares) ? "N/A" : str.tostring(displayShares, "#")
                    float displayPosValueInAcctCurr = na(displayPosValue) ? na : displayPosValue / (accountCurrency == "INR" ? exchangeRate : 1)
                    string posValueText = na(displayPosValueInAcctCurr) ? "N/A" : str.tostring(displayPosValueInAcctCurr, "#,###")
                    table.cell(dashTable, 1, row, sharesText + "  (" + currencySymbol + posValueText + ")", text_color=txtColor, text_size=txtSize, text_halign=text.align_right, bgcolor=rowBg)
                    row += 1
                    
                    // Risk amount
                    riskPctOfAcct := (displayRiskAmount / accountSize) * 100
                    riskTooltip = "Risk Amount in " + accountCurrency + "\n\nTotal amount you'll lose if stop loss is hit.\n\nSHOWS:\n• " + accountCurrency + " amount at risk\n• Percentage of total account\n\nRECOMMENDED RISK LEVELS:\n• 0.5-1% of account (conservative)\n• 1-2% of account (balanced)\n• 2-3% of account (aggressive)\n\nNEVER risk more than 3% on a single trade.\n\nThis is your MAXIMUM LOSS - stick to it!\n\n⚠️ FIXED at breakout - does not change!"
                    table.cell(dashTable, 0, row, "Risk", text_color=txtMuted, text_size=txtSize, text_halign=text.align_left, bgcolor=rowBg, tooltip=riskTooltip)
                    table.cell(dashTable, 1, row, str.format("{0}{1}  ({2}%)", currencySymbol, str.tostring(displayRiskAmount / (accountCurrency == "INR" ? exchangeRate : 1), "#"), str.tostring(riskPctOfAcct, "#.#")), text_color=accentShort, text_size=txtSize, text_halign=text.align_right, bgcolor=rowBg)
                    row += 1
                    
                    // Blank row after position size
                    table.cell(dashTable, 0, row, "", text_color=txtColor, text_size=size.tiny, height=0.5)
                    table.cell(dashTable, 1, row, "", text_color=txtColor, text_size=size.tiny, height=0.5)
                    row += 1

            // Entry - with validation
            bool validTrade = not na(entry) and not na(sl) and entry > 0 and sl > 0
            
            if validTrade
                entryTooltip = "Entry Price\n\nYour suggested entry point for the trade.\n\nFOR LONG: ORB High level (where breakout occurred)\nFOR SHORT: ORB Low level (where breakdown occurred)\n\nThis is where you would buy/sell to enter the position.\n\nNOTE: Market entry may differ slightly due to slippage."
                table.cell(dashTable, 0, row, "Entry", text_color=txtMuted, text_size=txtSize, text_halign=text.align_left, bgcolor=rowBg, tooltip=entryTooltip)
                table.cell(dashTable, 1, row, str.format("${0}", str.tostring(entry, "#.##")), text_color=txtColor, text_size=txtSize, text_halign=text.align_right, bgcolor=rowBg)
                row += 1
            else
                table.cell(dashTable, 0, row, "⚠️ Trade Data:", text_color=txtColor, text_size=txtSize, text_halign=text.align_left)
                table.cell(dashTable, 1, row, "Calculating...", text_color=color.new(color.orange, 0), text_size=txtSize, text_halign=text.align_right)
                row += 1
            
            // Stop Loss
            slDist = math.abs(entry - sl)
            slPct = (slDist / entry) * 100
            stopTooltip = "Stop Loss (classic ORB)\n\nLONG: beyond ORB Low\nSHORT: beyond ORB High\nBuffer: " + str.tostring(stopOrbFraction, "#") + "% of ORB range\n\nDISTANCE: Shows $ distance and % from entry\n\nAlways use a stop loss to protect capital."
            table.cell(dashTable, 0, row, "Stop", text_color=txtMuted, text_size=txtSize, text_halign=text.align_left, bgcolor=rowBg, tooltip=stopTooltip)
            table.cell(dashTable, 1, row, str.format("${0}  ({1}%)", str.tostring(sl, "#.##"), str.tostring(slPct, "#.#")), text_color=accentShort, text_size=txtSize, text_halign=text.align_right, bgcolor=rowBg)
            row += 1
            
            // Targets (only enabled ones)
            if showTP1
                tp1Dist = math.abs(tp1 - entry)
                tp1Pct = (tp1Dist / entry) * 100
                tp1Label = orbTP1Hit ? "TP1 ✓" : "TP1"
                tp1Tooltip = "Take Profit 1 (1R)\n\nFirst profit target at 1× Risk distance.\n\n1R = Risk/Reward ratio of 1:1\n\nIf you risk $100, TP1 gives you $100 profit.\n\nSTRATEGY:\n• Conservative: Exit full position at TP1\n• Balanced: Take 50% profit, hold rest for TP2\n• Aggressive: Hold through for higher targets\n\n✅ = Target hit"
                table.cell(dashTable, 0, row, tp1Label, text_color=txtColor, text_size=txtSize, text_halign=text.align_left, tooltip=tp1Tooltip)
                table.cell(dashTable, 1, row, str.format("${0} (+{1}%)", str.tostring(tp1, "#.##"), str.tostring(tp1Pct, "#.#")), text_color=txtColor, text_size=txtSize, text_halign=text.align_right)
                row += 1
            
            if showTP1_5
                tp1_5Dist = math.abs(tp1_5 - entry)
                tp1_5Pct = (tp1_5Dist / entry) * 100
                tp1_5Label = orbTP1_5Hit ? "TP1.5 ✓" : "TP1.5"
                tp1_5Tooltip = "Take Profit 1.5 (1.5R)\n\nIntermediate target at 1.5× Risk distance.\n\n1.5R = Risk/Reward ratio of 1:1.5\n\nIf you risk $100, TP1.5 gives you $150 profit.\n\nUSEFUL FOR:\n• Scaling out of positions gradually\n• Capturing middle-ground profits\n• Adjusting to market volatility\n\n✅ = Target hit"
                table.cell(dashTable, 0, row, tp1_5Label, text_color=txtColor, text_size=txtSize, text_halign=text.align_left, tooltip=tp1_5Tooltip)
                table.cell(dashTable, 1, row, str.format("${0} (+{1}%)", str.tostring(tp1_5, "#.##"), str.tostring(tp1_5Pct, "#.#")), text_color=txtColor, text_size=txtSize, text_halign=text.align_right)
                row += 1
            
            if showTP2
                tp2Dist = math.abs(tp2 - entry)
                tp2Pct = (tp2Dist / entry) * 100
                tp2Label = orbTP2Hit ? "TP2 ✓" : "TP2"
                tp2Tooltip = "Take Profit 2 (2R)\n\nMain profit target at 2× Risk distance.\n\n2R = Risk/Reward ratio of 1:2\n\nIf you risk $100, TP2 gives you $200 profit.\n\nThis is the STANDARD target for most ORB traders.\n\nSTRATEGY:\n• Exit remaining position at TP2\n• Move stop to breakeven after TP1 hit\n• Let runners go to TP3 if strong momentum\n\n✅ = Target hit"
                table.cell(dashTable, 0, row, tp2Label, text_color=txtColor, text_size=txtSize, text_halign=text.align_left, tooltip=tp2Tooltip)
                table.cell(dashTable, 1, row, str.format("${0} (+{1}%)", str.tostring(tp2, "#.##"), str.tostring(tp2Pct, "#.#")), text_color=txtColor, text_size=txtSize, text_halign=text.align_right)
                row += 1
            
            if showTP3
                tp3Dist = math.abs(tp3 - entry)
                tp3Pct = (tp3Dist / entry) * 100
                tp3Label = orbTP3Hit ? "TP3 ✓" : "TP3"
                tp3Tooltip = "Take Profit 3 (3R)\n\nExtended profit target at 3× Risk distance.\n\n3R = Risk/Reward ratio of 1:3\n\nIf you risk $100, TP3 gives you $300 profit.\n\nONLY FOR:\n• Strong trending days\n• High momentum breakouts\n• Extended runners\n\nMOST TRADES won't reach TP3.\n\nSTRATEGY: Trail stop or use for 'lottery tickets'\n\n✅ = Target hit"
                table.cell(dashTable, 0, row, tp3Label, text_color=txtColor, text_size=txtSize, text_halign=text.align_left, tooltip=tp3Tooltip)
                table.cell(dashTable, 1, row, str.format("${0} (+{1}%)", str.tostring(tp3, "#.##"), str.tostring(tp3Pct, "#.#")), text_color=txtColor, text_size=txtSize, text_halign=text.align_right)
                row += 1

            if showTP4
                tp4Dist = math.abs(tp4 - entry)
                tp4Pct = (tp4Dist / entry) * 100
                tp4Label = orbTP4Hit ? "TP4 ✓" : "TP4"
                tp4Tooltip = "Take Profit 4 (4R)\n\nExtended runner at 4× Risk.\n\n✅ = Target hit"
                table.cell(dashTable, 0, row, tp4Label, text_color=txtColor, text_size=txtSize, text_halign=text.align_left, tooltip=tp4Tooltip)
                table.cell(dashTable, 1, row, str.format("${0} (+{1}%)", str.tostring(tp4, "#.##"), str.tostring(tp4Pct, "#.#")), text_color=txtColor, text_size=txtSize, text_halign=text.align_right)
                row += 1

            if showTP5
                tp5Dist = math.abs(tp5 - entry)
                tp5Pct = (tp5Dist / entry) * 100
                tp5Label = orbTP5Hit ? "TP5 ✓" : "TP5"
                tp5Tooltip = "Take Profit 5 (5R)\n\nExtended runner at 5× Risk.\n\n✅ = Target hit"
                table.cell(dashTable, 0, row, tp5Label, text_color=txtColor, text_size=txtSize, text_halign=text.align_left, tooltip=tp5Tooltip)
                table.cell(dashTable, 1, row, str.format("${0} (+{1}%)", str.tostring(tp5, "#.##"), str.tostring(tp5Pct, "#.#")), text_color=txtColor, text_size=txtSize, text_halign=text.align_right)
                row += 1

            if showTP6
                tp6Dist = math.abs(tp6 - entry)
                tp6Pct = (tp6Dist / entry) * 100
                tp6Label = orbTP6Hit ? "TP6 ✓" : "TP6"
                tp6Tooltip = "Take Profit 6 (6R)\n\nMax runner at 6× Risk.\n\n✅ = Target hit"
                table.cell(dashTable, 0, row, tp6Label, text_color=txtColor, text_size=txtSize, text_halign=text.align_left, tooltip=tp6Tooltip)
                table.cell(dashTable, 1, row, str.format("${0} (+{1}%)", str.tostring(tp6, "#.##"), str.tostring(tp6Pct, "#.#")), text_color=txtColor, text_size=txtSize, text_halign=text.align_right)
                row += 1

            // Risk/Reward - Smart logic with caching
            if showRisk
                riskDist = math.abs(entry - sl)
                
                // Determine target: Hit TPs priority, then highest enabled
                float rrTarget = orbTP6Hit and showTP6 ? tp6 : orbTP5Hit and showTP5 ? tp5 : orbTP4Hit and showTP4 ? tp4 : orbTP3Hit and showTP3 ? tp3 : orbTP2Hit and showTP2 ? tp2 : orbTP1_5Hit and showTP1_5 ? tp1_5 : orbTP1Hit and showTP1 ? tp1 : showTP6 ? tp6 : showTP5 ? tp5 : showTP4 ? tp4 : showTP3 ? tp3 : showTP2 ? tp2 : showTP1_5 ? tp1_5 : showTP1 ? tp1 : tp2
                bool anyHit = orbTP6Hit or orbTP5Hit or orbTP4Hit or orbTP3Hit or orbTP2Hit or orbTP1_5Hit or orbTP1Hit
                
                rewardDist = math.abs(rrTarget - entry)
                rrRatio = riskDist > 0 ? rewardDist / riskDist : 0
                rrStatus = anyHit ? "hit" : rrRatio >= 2.0 ? "good" : rrRatio >= 1.5 ? "ok" : "low"
                
                table.cell(dashTable, 0, row, "R/R", text_color=txtMuted, text_size=txtSize, text_halign=text.align_left, bgcolor=rowBg)
                table.cell(dashTable, 1, row, str.format("1:{0}  ·  {1}", str.tostring(rrRatio, "#.#"), rrStatus), text_color=txtColor, text_size=txtSize, text_halign=text.align_right, bgcolor=rowBg)
                row += 1
        
        // Show last trade result when trade closed
        if enableTargets and (everHadBreakUp or everHadBreakDown) and trade_closed and last_trade_result != ""
            table.cell(dashTable, 0, row, "", text_color=txtColor, text_size=size.tiny)
            table.cell(dashTable, 1, row, "", text_color=txtColor, text_size=size.tiny)
            table.cell_set_height(dashTable, 0, row, 0.1)
            table.cell_set_height(dashTable, 1, row, 0.1)
            row += 1
            
            // Last trade result
            string lastTradeTooltip = "Last Trade Result\n\nShows the outcome of the most recent trade.\n\n✅ = Target hit (profit)\n❌ = Stop loss hit (loss)\n\nR = Risk/Reward ratio\n+2R means you made 2x your risk\n-1R means you lost your risk amount"
            if not na(dashTable)
                table.clear(dashTable, 0, row, 1, row)

            table.cell(dashTable, 0, row, "Last", text_color=txtMuted, text_size=txtSize, text_halign=text.align_left, bgcolor=rowBg, tooltip=lastTradeTooltip)
            color lastCol = str.contains(last_trade_result, "SL") or str.contains(last_trade_result, "−") ? accentShort : accentLong
            table.cell(dashTable, 1, row, last_trade_result, text_color=lastCol, text_size=txtSize, text_halign=text.align_right, bgcolor=rowBg)
            row += 1
    
    else if not na(dashTable)

        string headerTitle = "XCEL ORB"
        string headerTooltip = "Xcelerate ORB\n\n" + sessionStatusText + "\n\nMarket is currently closed.\nDisplay hours: 04:00–20:00"
        
        table.cell(dashTable, 0, row, headerTitle, text_color=txtColor, text_size=txtSize, text_halign=text.align_center, bgcolor=headerColor, tooltip=headerTooltip)
        table.cell(dashTable, 1, row, "", bgcolor=headerColor)
        table.merge_cells(dashTable, 0, row, 1, row)
        row += 1
        
        // NOT IN SESSION message
        string notInSessionMsg = sessionStatusText
        string notInSessionTooltip = "Outside active ORB window.\nTracking resumes at next session open."
        table.cell(dashTable, 0, row, notInSessionMsg, text_color=txtMuted, text_size=txtSize, text_halign=text.align_center, bgcolor=rowBg, tooltip=notInSessionTooltip)
        table.cell(dashTable, 1, row, "", bgcolor=rowBg)
        table.merge_cells(dashTable, 0, row, 1, row)
        row += 1
    
    // SESSION STATISTICS ROW (Always visible when there are trades)
    if session_trades > 0 and showFullDashboard and not na(dashTable)
        float winRate = (session_wins / session_trades) * 100

        string statsText = str.format("{0}W  ·  {1}L  ·  {2}R  ·  WR {3}%", 
                                      str.tostring(session_wins),
                                      str.tostring(session_losses),
                                      str.tostring(session_total_rr, "#.#"),
                                      str.tostring(winRate, "#"))
        
        // Build detailed tooltip
        string statsTooltip = "══════════════════════════════\n"
        statsTooltip += "📊 SESSION STATISTICS - Detailed View\n"
        statsTooltip += "══════════════════════════════\n\n"
        statsTooltip += "TRADES TODAY: " + str.tostring(session_trades) + "\n"
        statsTooltip += "├─ ✅ Wins: " + str.tostring(session_wins) + " (" + str.tostring(winRate, "#.#") + "%)\n"
        statsTooltip += "├─ ❌ Losses: " + str.tostring(session_losses) + " (" + str.tostring(100 - winRate, "#.#") + "%)\n"
        statsTooltip += "└─ ⚖️ Win Rate: " + str.tostring(winRate, "#.#") + "%\n\n"
        statsTooltip += "══════════════════════════════\n"
        statsTooltip += "R PERFORMANCE:\n"
        statsTooltip += "├─ 💰 Total R: " + str.tostring(session_total_rr, "#.##") + "R\n"
        
        if session_wins > 0
            float avgWin = session_total_rr > 0 ? (session_total_rr + session_losses) / session_wins : 0.0
            if avgWin > 0
                statsTooltip += "├─ 📈 Avg Win: " + str.tostring(avgWin, "#.##") + "R\n"
        
        if session_losses > 0
            float avgLoss = -1.0
            statsTooltip += "├─ 📉 Avg Loss: " + str.tostring(avgLoss, "#.##") + "R\n"
        
        statsTooltip += "├─ 🏆 Best Trade: " + str.tostring(session_best_r, "#.##") + "R\n"
        
        if session_worst_r < 0
            statsTooltip += "└─ 💀 Worst Trade: " + str.tostring(session_worst_r, "#.##") + "R\n"
        
        statsTooltip += "══════════════════════════════\n"
        statsTooltip += "💡 TIP: Target 2:1 R/R minimum\n"
        
        if session_total_rr > 0
            statsTooltip += "    Current session: PROFITABLE ⭐\n"
        else if session_total_rr == 0
            statsTooltip += "    Current session: BREAKEVEN ⚖️\n"
        else
            statsTooltip += "    Current session: NEGATIVE ⚠️\n"
        
        // Display the stats row (merged across both columns)
        color statsRowColor = session_total_rr > 0 ? color.new(accentLong, 88) : session_total_rr < 0 ? color.new(accentShort, 88) : headerColor
        
        table.cell(dashTable, 0, row, statsText, 
                   text_color=txtColor, 
                   text_size=txtSize, 
                   text_halign=text.align_center,
                   bgcolor=statsRowColor,
                   tooltip=statsTooltip)
        table.cell(dashTable, 1, row, "", bgcolor=statsRowColor)
        table.merge_cells(dashTable, 0, row, 1, row)
        row += 1

// ====================================== INDIVIDUAL ALERTS ==========================================
alertcondition(alertBreakUpTriggered and enableAlerts and alertBreakouts, 
               title="🔼 ORB Breakout UP", 
               message="{{ticker}} - Breakout ABOVE ORB High @ ${{close}}")

alertcondition(alertBreakDownTriggered and enableAlerts and alertBreakouts, 
               title="🔽 ORB Breakout DOWN", 
               message="{{ticker}} - Breakout BELOW ORB Low @ ${{close}}")

alertcondition(alertRetestUpTriggered and enableAlerts and alertRetests, 
               title="🔁 ORB Retest UP", 
               message="{{ticker}} - Retesting ORB after breakout UP @ ${{close}}")

alertcondition(alertRetestDownTriggered and enableAlerts and alertRetests, 
               title="🔁 ORB Retest DOWN", 
               message="{{ticker}} - Retesting ORB after breakout DOWN @ ${{close}}")

alertcondition(alertFailedUpTriggered and enableAlerts and alertFailedBreaks, 
               title="⚠️ ORB Failed Break UP", 
               message="{{ticker}} - Failed breakout UP, back inside ORB @ ${{close}}")

alertcondition(alertFailedDownTriggered and enableAlerts and alertFailedBreaks, 
               title="⚠️ ORB Failed Break DOWN", 
               message="{{ticker}} - Failed breakout DOWN, back inside ORB @ ${{close}}")

alertcondition(alertStageCompleteTriggered and enableAlerts and alertStageComplete,
               title="✅ ORB Stage Complete",
               message="{{ticker}} - ORB Stage completed")

// ================================ TRADE MANAGEMENT ALERTS =================================
alertcondition(alertEntryTriggered and enableAlerts and alertTradeManagement and enableTargets,
               title="🎯 ENTRY Triggered",
               message="{{ticker}} - ENTRY @ ${{close}} | Trade setup activated")

alertcondition(alertSLTriggered and enableAlerts and alertTradeManagement and enableTargets,
               title="❌ STOP LOSS Hit",
               message="{{ticker}} - STOP LOSS HIT @ ${{close}} | Trade closed with loss")

alertcondition(alertTP1Triggered and enableAlerts and alertTradeManagement and enableTargets and showTP1,
               title="✅ TP1 Hit (1R)",
               message="{{ticker}} - TP1 HIT @ ${{close}} | 1R profit target reached")

alertcondition(alertTP1_5Triggered and enableAlerts and alertTradeManagement and enableTargets and showTP1_5,
               title="✅ TP1.5 Hit (1.5R)",
               message="{{ticker}} - TP1.5 HIT @ ${{close}} | 1.5R profit target reached")

alertcondition(alertTP2Triggered and enableAlerts and alertTradeManagement and enableTargets and showTP2,
               title="✅ TP2 Hit (2R)",
               message="{{ticker}} - TP2 HIT @ ${{close}} | 2R profit target reached")

alertcondition(alertTP3Triggered and enableAlerts and alertTradeManagement and enableTargets and showTP3,
               title="✅ TP3 Hit (3R)",
               message="{{ticker}} - TP3 HIT @ ${{close}} | 3R profit target reached")

alertcondition(alertTP4Triggered and enableAlerts and alertTradeManagement and enableTargets and showTP4,
               title="✅ TP4 Hit (4R)",
               message="{{ticker}} - TP4 HIT @ ${{close}} | 4R profit target reached")

alertcondition(alertTP5Triggered and enableAlerts and alertTradeManagement and enableTargets and showTP5,
               title="✅ TP5 Hit (5R)",
               message="{{ticker}} - TP5 HIT @ ${{close}} | 5R profit target reached")

alertcondition(alertTP6Triggered and enableAlerts and alertTradeManagement and enableTargets and showTP6,
               title="✅ TP6 Hit (6R)",
               message="{{ticker}} - TP6 HIT @ ${{close}} | 6R profit target reached")

//END v6.7 — compile fix: all inputs first, then constants/session resolution
````

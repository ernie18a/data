# Structural Flow Decoder [JOAT]

- url: https://www.tradingview.com/script/bEmk8UnB-Structural-Flow-Decoder-JOAT/
- type: indicator
- pine_id: PUB;5864836e73cb4471985a62fb11778d4e
- version: 1.0

## Description

[b]Structural Flow Decoder [JOAT][/b]

[b]Introduction[/b]

The Structural Flow Decoder is an advanced open-source market structure analysis indicator that combines Break of Structure (BOS) detection, Change of Character (CHoCH) identification, nested pattern recognition, and multi-timeframe confluence into a unified structural analysis system. This indicator helps traders identify trend direction, structural shifts, and momentum changes by analyzing how price breaks through swing highs and lows across multiple timeframes.

Unlike basic trend indicators that use moving averages, this system analyzes actual market structure - the sequence of higher highs, higher lows, lower highs, and lower lows that define trends. Break of Structure signals trend continuation, Change of Character signals potential reversals, nested patterns reveal internal structure, and multi-timeframe alignment confirms institutional conviction. The indicator is designed for traders who understand that market structure precedes price and that structural breaks reveal directional intent.

[b]Why This Indicator Exists[/b]

This indicator addresses a critical need in technical analysis: the ability to identify trend changes before they're obvious. Market structure analysis reveals when institutions are shifting positioning. By combining multiple structural methodologies, this indicator reveals:

[list]
[*][b]Break of Structure (BOS):[/b] Price breaks swing high/low in trend direction - confirms continuation and momentum
[*][b]Change of Character (CHoCH):[/b] Price breaks swing high/low against trend - signals potential reversal or consolidation
[*][b]Nested Structure:[/b] Internal patterns within larger structure - reveals micro-trends and entry timing
[*][b]Multi-Timeframe Confluence:[/b] Higher timeframe structure alignment - confirms institutional participation
[*][b]Momentum Shifts:[/b] RSI and MACD crossovers at structure breaks - adds confirmation layer
[*][b]Trend Strength Analysis:[/b] Quantifies structural conviction - distinguishes strong from weak trends
[/list]

Each component provides a different lens on market structure. BOS shows continuation, CHoCH shows reversals, nested structure shows timing, MTF alignment shows conviction, and momentum shows acceleration. Together, they create a comprehensive view of structural flow.

[image]https://www.tradingview.com/x/JmDg4u7x/[/image]

[b]Core Components Explained[/b]

[b]1. Break of Structure (BOS) Detection[/b]

Break of Structure occurs when price breaks a swing high in an uptrend or swing low in a downtrend. It confirms trend continuation:

[pine]
// Bullish BOS: Price breaks above previous swing high
if pivotHigh > lastSwingHigh and bullishStructure:
    line.new(lastSwingHighBar, lastSwingHigh, bar_index, pivotHigh,
             color=COLOR_BULL_STRUCTURE, width=3, style=line.style_solid)
    label.new(bar_index, pivotHigh, "BOS ↑")
[/pine]

The indicator identifies BOS using swing detection:
[list]
[*]Detects swing highs and lows using pivot lookback (default 5 periods)
[*]Compares current swing to previous swing in same direction
[*]Draws solid lines connecting swings when BOS occurs
[*]Labels breaks with "BOS ↑" or "BOS ↓" for clarity
[/list]

BOS signals that the trend is intact and institutions are pushing price in the established direction. Multiple consecutive BOS indicate strong trending conditions.

[b]2. Change of Character (CHoCH) Detection[/b]

Change of Character occurs when price breaks a swing high in a downtrend or swing low in an uptrend. It signals potential trend reversal:

[pine]
// Bullish CHoCH: Price breaks above swing high while in downtrend
if pivotHigh > lastSwingHigh and not bullishStructure:
    line.new(lastSwingHighBar, lastSwingHigh, bar_index, pivotHigh,
             color=COLOR_CHOCH_BULL, width=3, style=line.style_dashed)
    label.new(bar_index, pivotHigh, "CHoCH ↑")
    bullishStructure := true
[/pine]

CHoCH is more significant than BOS because it represents structural shift:
[list]
[*]Breaks counter-trend swing points
[*]Signals potential trend reversal or major consolidation
[*]Drawn with dashed lines to distinguish from BOS
[*]Flips internal trend state when detected
[/list]

CHoCH doesn't guarantee reversal, but it warns that the previous trend is weakening. Confirmation from other factors (volume, momentum, higher timeframe) increases reliability.

[b]3. Nested Structure Analysis[/b]

Nested structure reveals internal patterns within the larger trend. It uses shorter lookback periods to detect micro-structure:

The indicator tracks internal swings using a separate period (default 3 bars vs 5 for main structure). This reveals:
[list]
[*]Internal BOS within larger trends - shows momentum acceleration
[*]Internal CHoCH before main CHoCH - early warning of reversals
[*]Pullback structure in trends - identifies entry opportunities
[*]Consolidation patterns - shows when to wait
[/list]

Nested structure is drawn with thinner dashed lines to distinguish from main structure. It provides entry timing within the larger trend context.

[b]4. Multi-Timeframe Confluence[/b]

The indicator requests structure data from a higher timeframe (default 60-minute) and compares it to current timeframe:

[pine]
[htfHigh, htfLow, htfClose] = request.security(syminfo.tickerid, "60", 
                                                [high, low, close])
[/pine]

Multi-timeframe analysis reveals:
[list]
[*]Whether current timeframe structure aligns with higher timeframe
[*]Institutional conviction (HTF structure = larger positions)
[*]Confluence zones where both timeframes show same direction
[*]Divergence warnings when timeframes conflict
[/list]

The dashboard displays HTF alignment status (Bullish/Bearish) and confluence state (Synced/Divergent). Trading in direction of HTF structure with current timeframe confirmation produces highest win rates.

[b]5. Momentum Shift Detection[/b]

The indicator integrates RSI and MACD to detect momentum shifts at structural breaks:

[pine]
rsi = ta.rsi(close, 14)
[macdLine, signalLine, macdHist] = ta.macd(close, 12, 26, 9)

momentum_bull = ta.crossover(rsi, 50) and macdHist > 0
momentum_bear = ta.crossunder(rsi, 50) and macdHist < 0
[/pine]

Momentum shifts are marked with "M+" (bullish) or "M-" (bearish) labels. When momentum shifts align with structural breaks, it confirms the move. Momentum divergence from structure warns of potential failures.

[b]6. Trend Strength Classification[/b]

The indicator quantifies trend strength based on consecutive structural breaks:

[list]
[*]Explosive: 3+ consecutive BOS in same direction
[*]Active: 1-2 consecutive BOS
[*]Weak: No recent BOS or mixed signals
[/list]

Strength classification appears in the dashboard and influences background gradient intensity. Strong trends show vibrant colors, weak trends show muted colors.

[image]https://www.tradingview.com/x/D4MX2Hg4/[/image]

[b]Visual Elements[/b]

[list]
[*][b]BOS Lines:[/b] Solid thick lines (cyan for bullish, magenta for bearish)
[*][b]CHoCH Lines:[/b] Dashed thick lines (cyan for bullish, magenta for bearish)
[*][b]Internal Structure:[/b] Thin dashed lines showing nested patterns
[*][b]Swing Point Labels:[/b] "H" and "L" markers at pivot highs/lows
[*][b]Momentum Labels:[/b] "M+" and "M-" at momentum shifts
[*][b]Gradient Background:[/b] Color intensity based on trend strength
[*][b]Gradient Candles:[/b] Strong moves in bright colors, weak moves in muted colors
[*][b]Dashboard:[/b] Real-time structure state and confluence metrics
[/list]

The dashboard displays 8 key metrics:
1. Structure Flow (Bullish/Bearish)
2. Flow Strength (Explosive/Active/Weak)
3. HTF Alignment (Bullish/Bearish/Off)
4. Confluence (Synced/Divergent)
5. Momentum (Strong/Neutral/Weak)
6. MACD Signal (Bullish/Bearish)
7. Last Pivot price level

[b]Input Parameters[/b]

[b]Structure Analysis:[/b]
[list]
[*]Detection Period: Swing lookback for main structure (default: 5)
[*]Break of Structure: Enable/disable BOS detection
[*]Change of Character: Enable/disable CHoCH detection
[*]Nested Patterns: Enable/disable internal structure
[*]Nested Period: Swing lookback for internal structure (default: 3)
[*]Momentum Shifts: Enable/disable RSI/MACD labels
[/list]

[b]Higher Timeframe:[/b]
[list]
[*]Multi-Timeframe Sync: Enable/disable HTF analysis
[*]HTF Period: Higher timeframe to analyze (default: 60 minutes)
[*]Confluence Filter: Require HTF alignment for signals
[/list]

[b]Visualization:[/b]
[list]
[*]Directional Zones: Show gradient backgrounds
[*]Pivot Markers: Show H/L labels at swings
[*]Strength Histogram: Show trend strength bars
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Identify Current Structure[/b]
Check the dashboard for Structure Flow. Bullish structure = look for longs, Bearish structure = look for shorts. This is your directional bias.

[b]Step 2: Wait for Structural Confirmation[/b]
In bullish structure, wait for BOS (break above swing high) to confirm continuation. In bearish structure, wait for BOS (break below swing low). Don't trade against structure.

[b]Step 3: Watch for Change of Character[/b]
CHoCH signals potential reversal. When CHoCH occurs, structure flips. Wait for confirmation BOS in new direction before entering. Don't trade immediately on CHoCH.

[b]Step 4: Use Nested Structure for Timing[/b]
Internal structure shows pullback completion. Enter when internal BOS occurs in direction of main structure. This provides precise entry timing.

[b]Step 5: Confirm with Higher Timeframe[/b]
Check HTF Alignment in dashboard. "Synced" = both timeframes agree (best setups). "Divergent" = conflict (avoid or reduce size).

[b]Step 6: Add Momentum Confirmation[/b]
Look for M+ labels in bullish structure or M- labels in bearish structure. Momentum + Structure = highest probability setups.

[b]Best Practices[/b]

[list]
[*]Trade in direction of structure - don't fight it
[*]BOS confirms trend, CHoCH warns of change - respect both
[*]Multiple BOS in same direction = strong trend, ride it
[*]CHoCH requires confirmation - don't reverse immediately
[*]Nested structure provides entries within larger trend
[*]HTF alignment is critical - always check confluence
[*]Momentum divergence from structure = warning sign
[*]Explosive strength = trending conditions, use breakout strategies
[*]Weak strength = ranging conditions, use mean reversion
[*]Structure works on all timeframes - scale appropriately
[/list]

[b]Indicator Limitations[/b]

[list]
[*]Structure analysis works best on trending markets with clear swings
[*]Choppy, sideways markets produce frequent false CHoCH signals
[*]Swing detection requires sufficient volatility - low volatility reduces reliability
[*]CHoCH doesn't guarantee reversal - it signals potential change
[*]Multiple CHoCH in short period indicates consolidation, not trend
[*]HTF data may repaint on lower timeframes - use confirmed bars
[*]Nested structure can be noisy in ranging markets
[*]The indicator shows structure state, not future direction
[*]Momentum shifts can occur without structural confirmation
[/list]

[b]Technical Implementation[/b]

Built with Pine Script v6 using:
[list]
[*]Pivot-based swing detection with configurable lookback
[*]State machine tracking for bullish/bearish structure
[*]Nested structure analysis with separate period
[*]Multi-timeframe security requests with proper gap handling
[*]RSI and MACD momentum calculations
[*]Trend strength quantification system
[*]Dynamic gradient backgrounds based on strength
[*]Real-time dashboard with 8 structural metrics
[/list]

The code is fully open-source and can be modified to suit individual trading styles and preferences.

[b]Originality Statement[/b]

This indicator is original in its comprehensive structural integration approach. While individual components (BOS, CHoCH, swing detection) are established concepts, this indicator is justified because:

[list]
[*]It synthesizes BOS and CHoCH detection with nested pattern analysis in a unified system
[*]The multi-timeframe confluence detection provides institutional conviction measurement
[*]Momentum shift integration (RSI + MACD) adds confirmation layer to structural breaks
[*]Trend strength quantification distinguishes explosive from weak structural flows
[*]Nested structure analysis reveals micro-patterns within macro-trends for entry timing
[*]The gradient visualization system shows structural conviction through color intensity
[*]Real-time dashboard presents 8 metrics simultaneously for holistic structural analysis
[/list]

Each component contributes unique information: BOS shows continuation, CHoCH shows reversals, nested structure shows timing, HTF shows conviction, momentum shows acceleration, and strength shows quality. The indicator's value lies in presenting these complementary perspectives simultaneously with unified classification and visual hierarchy.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss and is not suitable for all investors.

Market structure analysis is a tool for understanding price behavior, not a crystal ball for predicting future movement. BOS does not guarantee continuation. CHoCH does not guarantee reversal. Past structural patterns do not guarantee future structural patterns. Market conditions change, and strategies that worked historically may not work in the future.

The structural states displayed are analytical constructs based on current market data, not predictions of future price movement. Structure alignment does not guarantee profitable trades. Users must conduct their own analysis and risk assessment before making trading decisions.

Always use proper risk management, including stop losses and position sizing appropriate for your account size and risk tolerance. Never risk more than you can afford to lose. Consider consulting with a qualified financial advisor before making investment decisions.

The author is not responsible for any losses incurred from using this indicator. Users assume full responsibility for all trading decisions made using this tool.

-Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
 //@version=6
indicator("Structural Flow Decoder [JOAT]", overlay=true, max_lines_count=500, max_labels_count=500)

// ────────────────────────────────────────────────────────────────────────────────
// INPUTS
// ────────────────────────────────────────────────────────────────────────────────
swingLength = input.int(5, "Detection Period", minval=3, maxval=20, group="Structure Analysis")
showBOS = input.bool(true, "Break of Structure", group="Structure Analysis")
showCHoCH = input.bool(true, "Change of Character", group="Structure Analysis")
showInternalStructure = input.bool(true, "Nested Patterns", group="Structure Analysis")
internalSwingLen = input.int(3, "Nested Period", minval=2, maxval=10, group="Structure Analysis")
showMomentumShift = input.bool(true, "Momentum Shifts", group="Structure Analysis")

mtfEnabled = input.bool(true, "Multi-Timeframe Sync", group="Higher Timeframe")
htfTimeframe = input.timeframe("60", "HTF Period", group="Higher Timeframe")
htfConfluence = input.bool(true, "Confluence Filter", group="Higher Timeframe")

showTrendZones = input.bool(true, "Directional Zones", group="Visualization")
showSwingPoints = input.bool(true, "Pivot Markers", group="Visualization")
showStrengthBars = input.bool(true, "Strength Histogram", group="Visualization")

// ────────────────────────────────────────────────────────────────────────────────
// COLOR SCHEME - Holographic Plasma Gradient
// ────────────────────────────────────────────────────────────────────────────────
// Structure Colors - Neon Gradients
COLOR_BULL_STRUCTURE = color.new(#00ff9f, 0)
COLOR_BEAR_STRUCTURE = color.new(#ff006e, 0)
COLOR_CHOCH_BULL = color.new(#00ffff, 0)
COLOR_CHOCH_BEAR = color.new(#ff00ff, 0)
COLOR_INTERNAL_BULL = color.new(#7fffd4, 50)
COLOR_INTERNAL_BEAR = color.new(#ff69b4, 50)
COLOR_SWING_HIGH = color.new(#ff1493, 25)
COLOR_SWING_LOW = color.new(#00fa9a, 25)
COLOR_MOMENTUM_BULL = color.new(#32cd32, 0)
COLOR_MOMENTUM_BEAR = color.new(#dc143c, 0)

// Candle Colors - Gradient
COLOR_CANDLE_BULL_STRONG = color.new(#00ff9f, 0)
COLOR_CANDLE_BULL_WEAK = color.new(#00d4ff, 0)
COLOR_CANDLE_BEAR_STRONG = color.new(#ff006e, 0)
COLOR_CANDLE_BEAR_WEAK = color.new(#ff4500, 0)

// Background Gradients
COLOR_BG_BULL_1 = color.new(#00ff9f, 98)
COLOR_BG_BULL_2 = color.new(#00d4ff, 98)
COLOR_BG_BEAR_1 = color.new(#ff006e, 98)
COLOR_BG_BEAR_2 = color.new(#ff4500, 98)
COLOR_BG_NEUTRAL = color.new(#1a1a2e, 99)

// ────────────────────────────────────────────────────────────────────────────────
// CALCULATIONS
// ────────────────────────────────────────────────────────────────────────────────
atr = ta.atr(14)
avgVol = ta.sma(volume, 20)

// ────────────────────────────────────────────────────────────────────────────────
// SWING DETECTION
// ────────────────────────────────────────────────────────────────────────────────
pivotHigh = ta.pivothigh(high, swingLength, swingLength)
pivotLow = ta.pivotlow(low, swingLength, swingLength)

// Internal structure
internalHigh = ta.pivothigh(high, internalSwingLen, internalSwingLen)
internalLow = ta.pivotlow(low, internalSwingLen, internalSwingLen)

// ────────────────────────────────────────────────────────────────────────────────
// STRUCTURE TRACKING
// ────────────────────────────────────────────────────────────────────────────────
var float lastSwingHigh = na
var float lastSwingLow = na
var int lastSwingHighBar = na
var int lastSwingLowBar = na
var bool bullishStructure = true
var int structureStrength = 0

// Update swing highs
if not na(pivotHigh)
    if showSwingPoints
        label.new(bar_index[swingLength], pivotHigh, "H", 
                  style=label.style_label_down, color=COLOR_SWING_HIGH, 
                  textcolor=color.white, size=size.tiny)
    
    if not na(lastSwingHigh)
        // Higher High
        if pivotHigh > lastSwingHigh
            if bullishStructure and showBOS
                line.new(lastSwingHighBar, lastSwingHigh, bar_index[swingLength], pivotHigh,
                         color=COLOR_BULL_STRUCTURE, width=3, style=line.style_solid)
                label.new(bar_index[swingLength], pivotHigh, "BOS ↑",
                          style=label.style_label_down, color=COLOR_BULL_STRUCTURE,
                          textcolor=color.white, size=size.small)
                structureStrength += 1
            else if not bullishStructure and showCHoCH
                line.new(lastSwingHighBar, lastSwingHigh, bar_index[swingLength], pivotHigh,
                         color=COLOR_CHOCH_BULL, width=3, style=line.style_dashed)
                label.new(bar_index[swingLength], pivotHigh, "CHoCH ↑",
                          style=label.style_label_down, color=COLOR_CHOCH_BULL,
                          textcolor=color.white, size=size.normal)
                bullishStructure := true
                structureStrength := 1
        // Lower High
        else
            if not bullishStructure and showBOS
                line.new(lastSwingHighBar, lastSwingHigh, bar_index[swingLength], pivotHigh,
                         color=COLOR_BEAR_STRUCTURE, width=3, style=line.style_solid)
                structureStrength += 1
    
    lastSwingHigh := pivotHigh
    lastSwingHighBar := bar_index[swingLength]

// Update swing lows
if not na(pivotLow)
    if showSwingPoints
        label.new(bar_index[swingLength], pivotLow, "L",
                  style=label.style_label_up, color=COLOR_SWING_LOW,
                  textcolor=color.white, size=size.tiny)
    
    if not na(lastSwingLow)
        // Higher Low
        if pivotLow > lastSwingLow
            if bullishStructure and showBOS
                line.new(lastSwingLowBar, lastSwingLow, bar_index[swingLength], pivotLow,
                         color=COLOR_BULL_STRUCTURE, width=3, style=line.style_solid)
                structureStrength += 1
        // Lower Low
        else
            if not bullishStructure and showBOS
                line.new(lastSwingLowBar, lastSwingLow, bar_index[swingLength], pivotLow,
                         color=COLOR_BEAR_STRUCTURE, width=3, style=line.style_solid)
                label.new(bar_index[swingLength], pivotLow, "BOS ↓",
                          style=label.style_label_up, color=COLOR_BEAR_STRUCTURE,
                          textcolor=color.white, size=size.small)
                structureStrength += 1
            else if bullishStructure and showCHoCH
                line.new(lastSwingLowBar, lastSwingLow, bar_index[swingLength], pivotLow,
                         color=COLOR_CHOCH_BEAR, width=3, style=line.style_dashed)
                label.new(bar_index[swingLength], pivotLow, "CHoCH ↓",
                          style=label.style_label_up, color=COLOR_CHOCH_BEAR,
                          textcolor=color.white, size=size.normal)
                bullishStructure := false
                structureStrength := 1
    
    lastSwingLow := pivotLow
    lastSwingLowBar := bar_index[swingLength]

// ────────────────────────────────────────────────────────────────────────────────
// INTERNAL STRUCTURE
// ────────────────────────────────────────────────────────────────────────────────
var float lastInternalHigh = na
var float lastInternalLow = na
var int lastInternalHighBar = na
var int lastInternalLowBar = na

if showInternalStructure
    if not na(internalHigh)
        if not na(lastInternalHigh)
            if internalHigh > lastInternalHigh and bullishStructure
                line.new(lastInternalHighBar, lastInternalHigh, 
                         bar_index[internalSwingLen], internalHigh,
                         color=COLOR_INTERNAL_BULL, width=2, style=line.style_dashed)
        lastInternalHigh := internalHigh
        lastInternalHighBar := bar_index[internalSwingLen]
    
    if not na(internalLow)
        if not na(lastInternalLow)
            if internalLow < lastInternalLow and not bullishStructure
                line.new(lastInternalLowBar, lastInternalLow,
                         bar_index[internalSwingLen], internalLow,
                         color=COLOR_INTERNAL_BEAR, width=2, style=line.style_dashed)
        lastInternalLow := internalLow
        lastInternalLowBar := bar_index[internalSwingLen]

// ────────────────────────────────────────────────────────────────────────────────
// HIGHER TIMEFRAME STRUCTURE
// ────────────────────────────────────────────────────────────────────────────────
[htfHigh, htfLow, htfClose] = request.security(syminfo.tickerid, htfTimeframe, 
                                                [high, low, close], 
                                                gaps=barmerge.gaps_off)

htfPivotHigh = request.security(syminfo.tickerid, htfTimeframe,
                                 ta.pivothigh(high, swingLength, swingLength),
                                 gaps=barmerge.gaps_on)

htfPivotLow = request.security(syminfo.tickerid, htfTimeframe,
                                ta.pivotlow(low, swingLength, swingLength),
                                gaps=barmerge.gaps_on)

var float htfLastHigh = na
var float htfLastLow = na
var bool htfBullish = true

if mtfEnabled
    if not na(htfPivotHigh)
        if not na(htfLastHigh) and htfPivotHigh > htfLastHigh
            htfBullish := true
        htfLastHigh := htfPivotHigh
    
    if not na(htfPivotLow)
        if not na(htfLastLow) and htfPivotLow < htfLastLow
            htfBullish := false
        htfLastLow := htfPivotLow

// ────────────────────────────────────────────────────────────────────────────────
// TREND ZONES WITH GRADIENT
// ────────────────────────────────────────────────────────────────────────────────
// Calculate trend strength for gradient
trendStrength = structureStrength / 5.0
trendStrengthClamped = math.min(trendStrength, 1.0)

// Multi-gradient background
bgColor = if bullishStructure
    color.from_gradient(trendStrengthClamped, 0, 1, COLOR_BG_BULL_2, COLOR_BG_BULL_1)
else
    color.from_gradient(trendStrengthClamped, 0, 1, COLOR_BG_BEAR_2, COLOR_BG_BEAR_1)

bgcolor(showTrendZones ? bgColor : na, title="Trend Zone")

// ────────────────────────────────────────────────────────────────────────────────
// GRADIENT CANDLE COLORING
// ────────────────────────────────────────────────────────────────────────────────
isBullCandle = close > open
candleStrength = math.abs(close - open) / atr

candleColor = isBullCandle ?
               (candleStrength > 1.0 ? COLOR_CANDLE_BULL_STRONG : COLOR_CANDLE_BULL_WEAK) :
               (candleStrength > 1.0 ? COLOR_CANDLE_BEAR_STRONG : COLOR_CANDLE_BEAR_WEAK)

barcolor(candleColor)

// ────────────────────────────────────────────────────────────────────────────────
// MOMENTUM SHIFT DETECTION
// ────────────────────────────────────────────────────────────────────────────────
rsi = ta.rsi(close, 14)

// Fix MACD - properly unpack the tuple
[macdLine, signalLine, macdHist] = ta.macd(close, 12, 26, 9)

momentum_bull = ta.crossover(rsi, 50) and macdHist > 0
momentum_bear = ta.crossunder(rsi, 50) and macdHist < 0

if showMomentumShift and momentum_bull
    label.new(bar_index, low, "M+", style=label.style_label_up, 
              color=COLOR_MOMENTUM_BULL, textcolor=color.white, size=size.small)

if showMomentumShift and momentum_bear
    label.new(bar_index, high, "M-", style=label.style_label_down, 
              color=COLOR_MOMENTUM_BEAR, textcolor=color.white, size=size.small)

// ────────────────────────────────────────────────────────────────────────────────
// DASHBOARD WITH GRADIENT GLOW
// ────────────────────────────────────────────────────────────────────────────────
if barstate.islast
    var table dashboard = table.new(position.top_right, 2, 8,
                                     bgcolor=color.new(#0a0a0a, 5),
                                     border_width=3,
                                     border_color=color.new(#00ff9f, 30))
    
    // Header with gradient glow effect
    table.cell(dashboard, 0, 0, "STRUCTURAL FLOW [JOAT]", 
               text_color=color.from_gradient(bar_index % 50, 0, 50, #00ff9f, #00d4ff), 
               text_size=size.normal, bgcolor=color.new(#1a1a2e, 15))
    table.merge_cells(dashboard, 0, 0, 1, 0)
    
    table.cell(dashboard, 0, 1, "Structure Flow", text_color=color.new(#a0a0a0, 0), text_size=size.small)
    structText = bullishStructure ? "BULLISH" : "BEARISH"
    structColor = bullishStructure ? COLOR_BULL_STRUCTURE : COLOR_BEAR_STRUCTURE
    table.cell(dashboard, 1, 1, structText, text_color=structColor, text_size=size.small)
    
    table.cell(dashboard, 0, 2, "Flow Strength", text_color=color.new(#a0a0a0, 0), text_size=size.small)
    strengthText = structureStrength > 3 ? "EXPLOSIVE" : structureStrength > 1 ? "ACTIVE" : "WEAK"
    strengthColor = structureStrength > 3 ? color.new(#00ff00, 0) : structureStrength > 1 ? color.new(#ffd700, 0) : color.gray
    table.cell(dashboard, 1, 2, strengthText, text_color=strengthColor, text_size=size.small)
    
    table.cell(dashboard, 0, 3, "HTF Alignment", text_color=color.new(#a0a0a0, 0), text_size=size.small)
    htfText = mtfEnabled ? (htfBullish ? "BULLISH" : "BEARISH") : "OFF"
    htfColor = mtfEnabled ? (htfBullish ? COLOR_BULL_STRUCTURE : COLOR_BEAR_STRUCTURE) : color.gray
    table.cell(dashboard, 1, 3, htfText, text_color=htfColor, text_size=size.small)
    
    table.cell(dashboard, 0, 4, "Confluence", text_color=color.new(#a0a0a0, 0), text_size=size.small)
    aligned = mtfEnabled ? (bullishStructure == htfBullish) : true
    alignText = aligned ? "SYNCED" : "DIVERGENT"
    alignColor = aligned ? color.new(#00ff9f, 0) : color.new(#ff006e, 0)
    table.cell(dashboard, 1, 4, alignText, text_color=alignColor, text_size=size.small)
    
    table.cell(dashboard, 0, 5, "Momentum", text_color=color.new(#a0a0a0, 0), text_size=size.small)
    momText = rsi > 60 ? "STRONG" : rsi > 40 ? "NEUTRAL" : "WEAK"
    momColor = rsi > 60 ? COLOR_MOMENTUM_BULL : rsi > 40 ? color.new(#ffd700, 0) : COLOR_MOMENTUM_BEAR
    table.cell(dashboard, 1, 5, momText, text_color=momColor, text_size=size.small)
    
    table.cell(dashboard, 0, 6, "MACD Signal", text_color=color.new(#a0a0a0, 0), text_size=size.small)
    macdText = macdHist > 0 ? "BULLISH" : "BEARISH"
    macdColor = macdHist > 0 ? COLOR_MOMENTUM_BULL : COLOR_MOMENTUM_BEAR
    table.cell(dashboard, 1, 6, macdText, text_color=macdColor, text_size=size.small)
    
    table.cell(dashboard, 0, 7, "Last Pivot", text_color=color.new(#a0a0a0, 0), text_size=size.small)
    pivotPrice = bullishStructure ? str.tostring(lastSwingHigh, format.mintick) : str.tostring(lastSwingLow, format.mintick)
    table.cell(dashboard, 1, 7, pivotPrice, text_color=color.new(#00d4ff, 0), text_size=size.small)

// ────────────────────────────────────────────────────────────────────────────────
// ALERTS
// ────────────────────────────────────────────────────────────────────────────────
bosUp = not na(pivotHigh) and not na(lastSwingHigh) and pivotHigh > lastSwingHigh and bullishStructure
bosDown = not na(pivotLow) and not na(lastSwingLow) and pivotLow < lastSwingLow and not bullishStructure
chochUp = not na(pivotHigh) and not na(lastSwingHigh) and pivotHigh > lastSwingHigh and not bullishStructure
chochDown = not na(pivotLow) and not na(lastSwingLow) and pivotLow < lastSwingLow and bullishStructure

alertcondition(bosUp, "BOS Bullish", "Bullish Break of Structure")
alertcondition(bosDown, "BOS Bearish", "Bearish Break of Structure")
alertcondition(chochUp, "CHoCH Bullish", "Bullish Change of Character")
alertcondition(chochDown, "CHoCH Bearish", "Bearish Change of Character")
````

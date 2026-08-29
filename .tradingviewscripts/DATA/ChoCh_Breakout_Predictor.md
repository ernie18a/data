<!-- tradingview-pine-id: PUB;9c21a949a0aa4674a0128be6d069f1e8 -->
<!-- tradingviewscripts-format: 1 -->
# ChoCh Breakout Predictor

Source: https://www.tradingview.com/script/fkCEyF4U-ChoCh-Breakout-Predictor/

## Description

Ever wished you knew the exact price level where the market structure is about to flip, before it actually happens? The ChoCh Breakout Predictor is designed to give you that exact edge.

Instead of reacting to a Change of Character (ChoCh) after the candle closes, this indicator maps out the critical trigger price in advance. By highlighting the precise level where a structural shift will occur, it allows you to plan your market orders, set up liquidity traps, and position yourself ahead of the breakout.

☕ If this indicator gives you an edge and helps optimize your trading plan, consider supporting my work! You can buy me a coffee here: https://ko-fi.com/tradeguru/
(Feel free to reach out if you need custom Pine Script development tailored to your personal strategy!)

🧠 How It Works
The indicator tracks active swing structures and dynamically plots a clean "ChoCh Change" trigger line.

In a Bullish Trend: The yellow trigger line sits right below you at the critical swing low, marking the exact price where a breakdown will trigger a bearish shift.

In a Bearish Trend: The trigger line sits above you at the key swing high, marking the exact price required to ignite a bullish reversal.

Accompanied by an elegant, low-profile structure zone, your charts remain clean and free of heavy, cluttered noise.

⚠️ Essential Trading Rules & Best Practices
To get the most out of this predictive breakout tool and avoid unnecessary traps, follow these rules:

Trade High-Volatility Sessions: Use this indicator during high-volatility times of the day. Low-volatility markets lack the momentum needed for clean structural follow-through, leading to a higher rate of false signals depending on your timeframe.

Beware of Major News Events: Avoid relying on lower timeframes during high-impact economic news releases. Sudden price spikes and news wicks will easily invalidate structural levels.

Multi-Timeframe Alignment (For Scalpers): If you are scalping on the 1-minute chart, always check the 5m, 15m, and 1H timeframes first to see which ChoCh direction is currently active. This ensures you only take breakouts that align with the broader intraday trend. If these higher timeframes show mixed bullish and bearish signals, stay on the sidelines until they align.

---

## Source Code

````pine
// © jan80hansen

//@version=6
indicator("ChoCh Breakout Predictor", overlay = true, max_lines_count = 500, max_labels_count = 500)

// -----------------------------------------------------------------------------
// 1. INPUTS
// -----------------------------------------------------------------------------
gp_str = "Market Structure Settings"
msLen   = input.int(10, title="Market Structure Length", group=gp_str, tooltip="The lookback period for detecting pivot highs and lows.")

gp_targ = "Fibonacci Target Levels Settings"
show_targets = input.bool(true, title="Show Target Lines", group=gp_targ)
fib_mult     = input.float(0.618, title="Fibonacci Step Multiplier", group=gp_targ, tooltip="Multiplier applied to structural range for target spacing.")
targ_col     = input.color(color.rgb(0, 229, 255), title="Target Lines Color", group=gp_targ)

gp_disp = "Visual Design"
show_cloud = input.bool(true, title="Show Structure Zone (Cloud)", group=gp_disp)
bull_col   = input.color(color.new(color.green, 85), title="Bullish Zone Color", group=gp_disp)
bear_col   = input.color(color.new(color.red, 85), title="Bearish Zone Color", group=gp_disp)
trig_col   = input.color(color.yellow, title="ChoCh Trigger Line Color", group=gp_disp)

// -----------------------------------------------------------------------------
// 2. CALCULATIONS (STRUCTURE & CHOCH)
// -----------------------------------------------------------------------------
ph = ta.pivothigh(msLen, msLen)
pl = ta.pivotlow(msLen, msLen)

var float phVal = na 
var float plVal = na
var int phIndx = 0
var int plIndx = 0
var bool direction = false 

var float entryPrice = na
var float currentTarget = na
var line targetLine = na
var label targetLabel = na
var int trendStart = 0
var int target_count = 0

// Arrays to track target lines and price labels
var line[]  targetLines  = array.new_line()
var label[] targetLabels = array.new_label()

clearCurrentTrendObjects() =>
    if array.size(targetLines) > 0
        for i = 0 to array.size(targetLines) - 1
            line.delete(array.get(targetLines, i))
        array.clear(targetLines)
    if array.size(targetLabels) > 0
        for i = 0 to array.size(targetLabels) - 1
            label.delete(array.get(targetLabels, i))
        array.clear(targetLabels)

if not na(ph)
    phVal := high[msLen]
    phIndx := bar_index[msLen]

if not na(pl)
    plVal := low[msLen]
    plIndx := bar_index[msLen]

// -----------------------------------------------------------------------------
// 3. CHOCH DETECTORS & INFINITE TARGET GENERATION
// -----------------------------------------------------------------------------
bool bullish_choch = ta.crossover(close, phVal) and not direction
bool bearish_choch = ta.crossunder(close, plVal) and direction

var float struct_range = na

if bullish_choch
    direction := true 
    entryPrice := phVal
    struct_range := math.abs(phVal - plVal)
    currentTarget := entryPrice + (struct_range * fib_mult)
    trendStart := bar_index
    target_count := 1

    line.new(phIndx, phVal, bar_index, phVal, color=bull_col, width = 2)
    label.new(int(math.avg(phIndx, bar_index)), phVal, "ChoCh ↑", style = label.style_label_down, color = na, textcolor = bull_col)
    
    clearCurrentTrendObjects()
    line.delete(targetLine)
    label.delete(targetLabel)
    
    targetLine := line.new(bar_index, currentTarget, bar_index + 10, currentTarget, color=color.new(targ_col, 0), width=1)
    string price_txt = str.format("TP{0}: {1,number,#.##}", target_count, currentTarget)
    targetLabel := label.new(bar_index, currentTarget, price_txt, style=label.style_label_left, color=color.new(color.black, 40), textcolor=targ_col, size=size.small)

if bearish_choch
    direction := false 
    entryPrice := plVal
    struct_range := math.abs(phVal - plVal)
    currentTarget := entryPrice - (struct_range * fib_mult)
    trendStart := bar_index
    target_count := 1

    line.new(plIndx, plVal, bar_index, plVal, color=bear_col, width = 2)
    label.new(int(math.avg(plIndx, bar_index)), plVal, "ChoCh ↓", style = label.style_label_up, color = na, textcolor = bear_col)
    
    clearCurrentTrendObjects()
    line.delete(targetLine)
    label.delete(targetLabel)
    
    targetLine := line.new(bar_index, currentTarget, bar_index + 10, currentTarget, color=color.new(targ_col, 0), width=1)
    string price_txt = str.format("TP{0}: {1,number,#.##}", target_count, currentTarget)
    targetLabel := label.new(bar_index, currentTarget, price_txt, style=label.style_label_left, color=color.new(color.black, 40), textcolor=targ_col, size=size.small)

directionChange = direction != direction[1]

// -----------------------------------------------------------------------------
// 4. CONTINUOUS STEP-UP TARGET LOGIC
// -----------------------------------------------------------------------------
if show_targets and not na(currentTarget)
    if direction
        if high >= currentTarget
            line.set_x2(targetLine, bar_index)
            line.set_style(targetLine, line.style_dashed)
            line.set_x1(targetLine, trendStart)

            array.push(targetLines, targetLine)
            // Sletter teksten (merkelappen) når målet er nådd, slik at bare linjen blir igjen
            label.delete(targetLabel)

            target_count += 1
            currentTarget := currentTarget + (struct_range * fib_mult)
            
            targetLine := line.new(trendStart, currentTarget, bar_index + 10, currentTarget, color=color.new(targ_col, 40), width=1)
            string price_txt = str.format("TP{0}: {1,number,#.##}", target_count, currentTarget)
            targetLabel := label.new(bar_index, currentTarget, price_txt, style=label.style_label_left, color=color.new(color.black, 40), textcolor=targ_col, size=size.small)
        else
            line.set_x2(targetLine, bar_index + 10)
            label.set_x(targetLabel, bar_index + 10)
            label.set_y(targetLabel, currentTarget)
            label.set_text(targetLabel, str.format("TP{0}: {1,number,#.##}", target_count, currentTarget))
    else
        if low <= currentTarget
            line.set_x2(targetLine, bar_index)
            line.set_style(targetLine, line.style_dashed)
            line.set_x1(targetLine, trendStart)
            
            array.push(targetLines, targetLine)
            // Sletter teksten når målet er nådd
            label.delete(targetLabel)

            target_count += 1
            currentTarget := currentTarget - (struct_range * fib_mult)
            
            targetLine := line.new(trendStart, currentTarget, bar_index + 10, currentTarget, color=color.new(targ_col, 40), width=1)
            string price_txt = str.format("TP{0}: {1,number,#.##}", target_count, currentTarget)
            targetLabel := label.new(bar_index, currentTarget, price_txt, style=label.style_label_left, color=color.new(color.black, 40), textcolor=targ_col, size=size.small)
        else
            line.set_x2(targetLine, bar_index + 10)
            label.set_x(targetLabel, bar_index + 10)
            label.set_y(targetLabel, currentTarget)
            label.set_text(targetLabel, str.format("TP{0}: {1,number,#.##}", target_count, currentTarget))

// -----------------------------------------------------------------------------
// 5. PLOTTING STRUCTURE BASE & TRIGGER
// -----------------------------------------------------------------------------
base_line = direction ? plVal : phVal
trigger_price = direction ? plVal : phVal

p_base = plot(base_line, title="Structure Base", color=na, linewidth=1)
p_price = plot(close, title="Price Reference", color=na, linewidth=1)

zone_color = direction ? bull_col : bear_col
fill(p_base, p_price, title="Structure Zone", color=show_cloud ? zone_color : na)

plot(trigger_price, title="ChoCh Change Trigger", color=trig_col, linewidth=1, style=plot.style_linebr)

var label trig_label = na
if barstate.islast
    label.delete(trig_label)
    string label_text = direction ? "ChoCh Change (Bearish Trigger)" : "ChoCh Change (Bullish Trigger)"
    trig_label := label.new(bar_index, trigger_price, label_text, style=label.style_label_left, color=color.new(color.black, 30), textcolor=trig_col, size=size.small)
````

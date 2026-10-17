# ATK/DEF KDJ Rewind Context

- url: https://www.tradingview.com/script/guRQDAgi/
- type: indicator
- pine_id: PUB;85a4840b0ccd4985b00580fee0868b50
- version: 1.0

## Description

Rewind KDJ Context is a visual KDJ analysis indicator designed to provide a clearer understanding of momentum structure through the relationship between the K, D, and J lines.

Traditional KDJ analysis often focuses on fixed overbough and oversol levels. This indicator expands the interpretation by analyzing the interaction between KDJ components, including line arrangement, directional changes, momentum development, and structural transitions.

The script transforms KDJ movement into different context states, helping users observe how momentum conditions develop, slow down, weaken, and recover over time.

Instead of treating K, D, and J as isolated values, Rewind KDJ Context focuses on the relationship between the three components and presents their current condition through a structured visual approach.

KDJ Context Framework
▶️ Momentum Push

Identifies conditions where K, D, and J show coordinated upward momentum development.

This context represents a phase where KDJ structure is aligned with increasing momentum activity and stronger directional movement.

⏸️ Momentum Pause

Highlights situations where momentum remains active but begins to slow or entr a temporary balance condition.

This state focuses on changes in momentum speed and the relationship between K, D, and J during a slowing phase.

⏪ Reversal Context

Highlights changes in KDJ structure where J-line movement and the relationship between K and D indicate a possible transition in short-term momentum conditions.

This context focuses on structural changes rather than predicting future pric direction.

⬇️ Weakness Context

Displays conditions where KDJ structure shows reduced momentum strength and weaker directional movement.

This state helps visualize when previous momentum conditions begin losing strength.

🔄 Recovery Context

Highlights situations where KDJ structure begins improving after a weaker phase.

This context observes changes in J-line behavior and KDJ alignment during potential momentum recovery conditions.

⚪ Neutral Context

Represents situations where K, D, and J do not form a strong directional structure and momentum remains relatively balanced.

Main Features

• Customizable KDJ calculation parameters
• Dynamic K, D, and J value visualization
• KDJ line relationship and structure analysis
• Momentum context classification
• Historical context table display
• Recent bar comparison
• Visual markers for important KDJ transitions
• KDJ arrangement monitoring
• Adjustable display range and historical reference position

How It Works

Rewind KDJ Context uses the traditional KDJ calculation method based on RSV, followed by smoothing calculations for the K and D lines.

The J line is derived from the relationship between K and D:

• K line represents the smoothed RSV movement
• D line represents the smoothed K line movement
• J line represents an extended momentum relationship between K and D

The indicator evaluates several aspects of KDJ behavior, including:

• Relative position between K, D, and J
• Directional movement of each component
• Changes in momentum expansion and contraction
• KDJ structural transitions
• Recent historical context

These calculations are organized into visual context states to make KDJ behavior easier to interpret.

Intended Use

Rewind KDJ Context is designed as a technical analysis tool for observing momentum conditions and KDJ structure.

It can be used together with price action analysis, trend evaluation, support and resistance analysis, volatility analysis, and other technical methods to build a broader market view.

The indicator is intended to provide additional context about momentum behavior rather than replace complete market analysis.

Notes

Rewind KDJ Context is based on mathemat calculations derived from historical pric data.

The displayed context states represent current and historical KDJ conditions based on the selected settings and market data available on the chart.

Different assets, timeframes, and market environments may produce different interpretations of the same indicator behavior.

Disclaimer

Rewind KDJ Context is provided for informational and technical analysis purposes only.

This indicator does not provide finacl advice, personalized recommendations, autm trading decisions, or guaranteed results.

The displayed KDJ context states, momentum conditions, and visual markers are generated from mathematical calculations and should not be interpreted as predictions of future pric movements.

Users are responsible for conducting their own analysis, making their own decisions, and applying appropriate risk management methods.

Past market behavior and technical indicator performance do not guaran future outcomes.

## Source Code

````pine
//@version=6
indicator("Rewind KDJ Context", overlay=false, precision=2, max_labels_count=100)

// ========== 1. User Inputs ==========
kdj_length = input.int(9, title="KDJ Period", minval=1, tooltip="RSV calculation period")
k_smooth = input.int(3, title="K Smoothing", minval=1, tooltip="K value smoothing period")
d_smooth = input.int(3, title="D Smoothing", minval=1, tooltip="D value smoothing period")
maxBarsToShow = input.int(6, title="Bars to Show", minval=1, maxval=10, step=1)
startPosition = input.int(0, title="Start Offset", minval=0, maxval=10, step=1)

// ========== 2. Calculate KDJ ==========
RSV = (close - ta.lowest(low, kdj_length)) / (ta.highest(high, kdj_length) - ta.lowest(low, kdj_length)) * 100
K = ta.sma(RSV, k_smooth)
D = ta.sma(K, d_smooth)
J = 3 * K - 2 * D

// ========== 3. Three-line Structure ==========
get_structure(k, d, j) =>
    if k > d and d > j
        "K > D > J"
    else if k > j and j > d
        "K > J > D"
    else if j > k and k > d
        "J > K > D"
    else if j > d and d > k
        "J > D > K"
    else if d > j and j > k
        "D > J > K"
    else if d > k and k > j
        "D > K > J"
    else
        "Mixed"

// ========== 4. Rewind Context States ==========
get_rewind_context(k, d, j) =>
    context = ""
    icon = ""
    
    // Momentum Push：K crosses above D with J rising
    if k > k[1] and d > d[1] and j > j[1] and k > d and d > j
        context := "Momentum Push"
        icon := "▶️"
    // Momentum Push：K > D > J, all rising
    else if k > d and d > j and k > k[1] and d > d[1] and j > j[1]
        context := "Momentum Push"
        icon := "▶️"
    // Momentum Pause：K > J > D
    else if k > j and j > d
        context := "Momentum Pause"
        icon := "⏸️"
    // Reversal：J first crosses below K and D
    else if (j < j[1] and j < k and j < d) and not (j[1] < k[1] and j[1] < d[1])
        context := "Reversal"
        icon := "⏪"
    // Weakness：J continues below K/D with no bounce
    else if j < k and j < d and k < k[1] and j < j[1]
        context := "Weakness"
        icon := "⬇️"
    // Recovery：J bounces from lows, about to cross above K/D
    else if j > j[1] and j < d and j < k and d < d[1] and k < k[1]
        context := "Recovery"
        icon := "🔄"
    // Neutral
    else
        context := "Neutral"
        icon := "⚪"
    
    [context, icon]

// ========== 5. Event Detection ==========
play_start = ta.crossover(K, D) and J > J[1]
rewind_start = ta.crossunder(J, K) and ta.crossunder(J, D)
pause_warning = K > J and J > D and J > J[1]
recovery_signal = J > J[1] and J < D and J < K and D < D[1] and K < K[1]

// ========== 6. Plot KDJ Lines ==========
plot(K, color=color.new(color.blue, 0), linewidth=2, title="K (Push)")
plot(D, color=color.new(color.orange, 0), linewidth=2, title="D (Pause)")
plot(J, color=color.new(color.white, 0), linewidth=2, title="J (Reversal)")

hline(80, color=color.new(color.red, 30), linestyle=hline.style_dashed, linewidth=1, title="Overbought")
hline(50, color=color.new(color.gray, 30), linestyle=hline.style_dotted, linewidth=1, title="Midline")
hline(20, color=color.new(color.green, 30), linestyle=hline.style_dashed, linewidth=1, title="Oversold")

// ========== 7. Draw State Labels ==========
if barstate.islast
    [context, icon] = get_rewind_context(K, D, J)
    
    contextColor = color.gray
    if str.contains(context, "Push")
        contextColor := color.green
    else if str.contains(context, "Pause")
        contextColor := color.yellow
    else if str.contains(context, "Reversal")
        contextColor := color.red
    else if str.contains(context, "Weakness")
        contextColor := color.orange
    else if str.contains(context, "Recovery")
        contextColor := color.blue
    else
        contextColor := color.gray
    
    label.new(bar_index, 90, text=icon + " " + context, 
              style=label.style_label_down, 
              color=color.new(contextColor, 70),
              textcolor=color.white, size=size.large)
    
    if play_start
        label.new(bar_index, 20, text="▶️ PUSH START", 
                  style=label.style_label_up, color=color.new(color.green, 80), 
                  textcolor=color.white, size=size.small)
    
    if rewind_start
        label.new(bar_index, 80, text="⏪ REVERSAL", 
                  style=label.style_label_down, color=color.new(color.red, 80), 
                  textcolor=color.white, size=size.small)
    
    if pause_warning
        label.new(bar_index, 70, text="⏸️ PAUSE", 
                  style=label.style_label_down, color=color.new(color.yellow, 80), 
                  textcolor=color.white, size=size.small)
    
    if recovery_signal
        label.new(bar_index, 30, text="🔄 RECOVERY", 
                  style=label.style_label_up, color=color.new(color.blue, 80), 
                  textcolor=color.white, size=size.small)

// ========== 8. Collect Historical Data ==========
var float[] kHistory = array.new_float()
var float[] dHistory = array.new_float()
var float[] jHistory = array.new_float()
var string[] structHistory = array.new_string()
var string[] contextHistory = array.new_string()
var string[] eventHistory = array.new_string()

array.push(kHistory, K)
array.push(dHistory, D)
array.push(jHistory, J)

structStr = get_structure(K, D, J)
array.push(structHistory, structStr)

[context, icon] = get_rewind_context(K, D, J)
contextLabel = icon + " " + context
array.push(contextHistory, contextLabel)

eventStr = ""
if play_start
    eventStr := "▶️ Push"
else if rewind_start
    eventStr := "⏪ Reversal"
else if pause_warning
    eventStr := "⏸️ Pause"
else if recovery_signal
    eventStr := "🔄 Recovery"
else
    eventStr := "⚪ Neutral"
array.push(eventHistory, eventStr)

maxSize = maxBarsToShow + startPosition + 5
if array.size(kHistory) > maxSize
    array.remove(kHistory, 0)
if array.size(dHistory) > maxSize
    array.remove(dHistory, 0)
if array.size(jHistory) > maxSize
    array.remove(jHistory, 0)
if array.size(structHistory) > maxSize
    array.remove(structHistory, 0)
if array.size(contextHistory) > maxSize
    array.remove(contextHistory, 0)
if array.size(eventHistory) > maxSize
    array.remove(eventHistory, 0)

/// ========== 9. 渲染表格 ==========
if barstate.islast
    var table myTable = table.new(position.bottom_right, 7, maxBarsToShow + 1, 
                                   border_color=color.rgb(60,60,120, 60), 
                                   border_width=2,
                                   frame_color=color.rgb(40,40,90, 70),
                                   frame_width=2,
                                   bgcolor=color.rgb(10,10,30, 92))
    
    // 表头（全英文）
    headers = array.from("📌 Bar", "🔵 K", "🟠 D", "🟣 J", "📐 Structure", "🎬 Context", "⚡ Signal")
    for col = 0 to 6
        table.cell(myTable, col, 0, array.get(headers, col), 
                   text_color=color.rgb(220,230,255), 
                   bgcolor=color.rgb(30,50,110, 90),
                   text_size=size.small, 
                   text_halign=text.align_center)
    
    // 数据行
    totalSize = array.size(kHistory)
    for i = 0 to maxBarsToShow - 1
        idx = totalSize - 1 - i - startPosition
        row = i + 1
        
        if idx >= 0 and idx < totalSize
            k_val = array.get(kHistory, idx)
            d_val = array.get(dHistory, idx)
            j_val = array.get(jHistory, idx)
            struct_val = array.get(structHistory, idx)
            context_val = array.get(contextHistory, idx)
            evt = array.get(eventHistory, idx)
            
            isCurrent = (i == 0 and startPosition == 0)
            labelText = isCurrent ? "Current 🔴" : "-" + str.tostring(i + startPosition)
            
            // 行背景
            rowBg = color.rgb(15,15,30)
            if isCurrent
                rowBg := color.rgb(40,30,20)
            else if i % 2 == 1
                rowBg := color.rgb(20,22,40)
            
            // 状态颜色
            contextColor = color.rgb(180,180,200)
            if str.contains(context_val, "Push")
                contextColor := color.rgb(100,255,100)
            else if str.contains(context_val, "Pause")
                contextColor := color.rgb(255,255,100)
            else if str.contains(context_val, "Reversal")
                contextColor := color.rgb(255,100,100)
            else if str.contains(context_val, "Weakness")
                contextColor := color.rgb(255,150,50)
            else if str.contains(context_val, "Recovery")
                contextColor := color.rgb(100,200,255)
            
            // 信号颜色
            eventColor = color.rgb(100,100,120)
            if evt == "▶️ Push"
                eventColor := color.rgb(100,255,100)
            else if evt == "⏪ Reversal"
                eventColor := color.rgb(255,100,100)
            else if evt == "⏸️ Pause"
                eventColor := color.rgb(255,255,100)
            else if evt == "🔄 Recovery"
                eventColor := color.rgb(100,200,255)
            
            table.cell(myTable, 0, row, labelText, 
                       text_color=isCurrent ? color.rgb(255,215,100) : color.rgb(200,210,230), 
                       bgcolor=rowBg, text_size=size.small, text_halign=text.align_center)
            table.cell(myTable, 1, row, str.tostring(k_val, "#.##"), 
                       text_color=color.rgb(100,180,255), bgcolor=rowBg, text_size=size.small, text_halign=text.align_center)
            table.cell(myTable, 2, row, str.tostring(d_val, "#.##"), 
                       text_color=color.rgb(255,180,100), bgcolor=rowBg, text_size=size.small, text_halign=text.align_center)
            table.cell(myTable, 3, row, str.tostring(j_val, "#.##"), 
                       text_color=color.rgb(255,100,255), bgcolor=rowBg, text_size=size.small, text_halign=text.align_center)
            table.cell(myTable, 4, row, struct_val, 
                       text_color=color.rgb(150,230,255), bgcolor=rowBg, text_size=size.small, text_halign=text.align_center)
            table.cell(myTable, 5, row, context_val, 
                       text_color=contextColor, bgcolor=rowBg, text_size=size.small, text_halign=text.align_center)
            table.cell(myTable, 6, row, evt != "" ? evt : "·", 
                       text_color=eventColor, bgcolor=rowBg, text_size=size.small, text_halign=text.align_center)
````

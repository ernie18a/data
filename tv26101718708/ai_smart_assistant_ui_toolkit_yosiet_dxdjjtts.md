# AI Smart Assistant UI Toolkit [Yosiet]

- url: https://www.tradingview.com/script/DXdJJTts-AI-Smart-Assistant-UI-Toolkit-Yosiet/
- type: indicator
- pine_id: PUB;21b34c43cddd474faf1e8ac55249d7a1
- version: 1.0

## Description

[b][FRAMEWORK] AI Smart Assistant UI Toolkit[/b]
Most TradingView indicators provide data, but few provide a [i][b]User Experience[/b][/i]. This script is not just a market scanne, it is a fully modular UI Framework designed to help Pine Script developers build interactive, "talking" AI interfaces within their indicators.

The AI Smart Assistant Framework moves away from static labels and moves toward dynamic, state-driven communication.

[b]Key Framework Features[/b]
+ State-Driven Typewriter Engine: Includes a logic-gate system that detects changes in market conditions and triggers a "typing" animation, making the AI feel responsive and alive.

+ Dynamic Pulsing System: A custom-built alpha-transparency oscillator that creates a "breathing" effect on the UI based on real-time tick data.

+ Advanced Theme Engine: Comes pre-loaded with 6 professionally designed color palettes (Nord, Midnight, Cyberpunk, Glassmorphism) that can be swapped with a single line of code.

+ [b]Actionable Logic Lists: Demonstrates how to turn raw data into structured, easy-to-read "Recommended Action" checklists for the end-user.[/b]

++ [b]Stateless Rendering[/b]: The UI is decoupled from the logic, allowing you to plug in any data source (MACD, EMA, Liquidity Zones) into the Assistant’s brain.

[b]Included UI Themes[/b]

Nord: A professional, arctic-blue palette for serious analysts.
[image]https://www.tradingview.com/x/FyamBXtS/[/image]

Midnight: High-contrast, deep-space colors for dark mode enthusiasts.
[image]https://www.tradingview.com/x/HCgVDVea/[/image]

Cyberpunk: High-energy neon aesthetics for a modern "HUD" feel.
[image]https://www.tradingview.com/x/PONFoeNG/[/image]

Warzone: Red bloody for a dramatic feel.
[image]https://www.tradingview.com/x/7ZYvMf2S/[/image]

Minimalist Light: Clean and crisp for those who prefer white backgrounds.
[image]https://www.tradingview.com/x/lAwPFCzC/[/image]

[b]How to use this as a Toolkit[/b]
This script is open-source and intended to be used as a template. To integrate this into your own project:
[list]
[*]Define your Logic: Replace the RSI checks with your own entry/exit conditions.
[*]Set the State: Use the AIState type to trigger the typewriter reset when your conditions are met.
[*]Customize the UI: Modify the UITheme type to match your brand colors.
[/list]

[b]Requirements[/b]
Pine Script Version: v6
Performance: Lightweight. Optimized to render only on the last bar to save GPU resources.

[b][i]Why I built this[/i]
I believe the future of TradingView scripts isn't just better math, it's better communication. If an user understands the "Why" behind a signal through a clear, beautiful interface, they become better traders.

Feel free to use this framework in your own public or private scripts. A credit to the original framework is always appreciated![/b]

The data is not static, the UI should not be it

## Source Code

````pine
//@version=6
indicator("AI Smart Assistant UI Toolkit [Yosiet]", overlay=true)

// ==========================================
// 1. THE THEME TYPE & GENERATORS
// ==========================================
type UITheme
    color  header_bg
    color  body_bg
    color  text_col
    color  border_col
    int    title_size
    int    body_size
    int    font_style

// Legacy Themes
getCyberpunk() => UITheme.new(#00ff8822, #000000aa, #00ff88, #00ff88, 14, 10, 1)
getGlass()     => UITheme.new(color.new(color.white, 80), color.new(color.white, 90), color.black, color.gray, 12, 9, 2)
getWarzone()   => UITheme.new(#ff444422, #1a1a1aaa, #ff4444, #ff4444, 16, 11, 1)

// New "Good Taste" Professional Themes
getNord() => 
    // Inspired by the popular Nord theme: Cool, muted, easy on the eyes.
    UITheme.new(#3b4252ee, #2e3440ee, #eceff4, #88c0d0, 14, 11, 0)

getMidnight() => 
    // Deep blues and purples with high contrast text for dark charts.
    UITheme.new(#16213eee, #0f3460ee, #e94560, #e94560, 14, 11, 1)

getMinimalLight() => 
    // Clean, crisp grayscale for white/light chart backgrounds.
    UITheme.new(#e9ecefee, #f8f9faee, #212529, #ced4da, 14, 11, 0)


// ==========================================
// 2. STATE MACHINE
// ==========================================
type AIState
    int start_time
    int state_id 

var AIState ai_state = AIState.new(timenow, 0)

// ==========================================
// 3. ANIMATION & VISUAL HELPERS
// ==========================================
pulseColor(color base_col, int speed = 150) =>
    if barstate.isrealtime
        alpha = int(60 + 35 * math.sin(timenow / speed)) 
        color.new(base_col, alpha)
    else
        color.new(base_col, 50) 

typewriterText(string text_str, int start_time, int speed_ms = 25) => // Sped up to 25ms for longer text
    if barstate.isrealtime
        chars_to_show = math.max(0, math.floor((timenow - start_time) / speed_ms))
        safe_length = math.min(str.length(text_str), chars_to_show)
        str.substring(text_str, 0, safe_length)
    else
        text_str 

progressBar(float val, float min_val, float max_val, int length = 12) =>
    pct = (val - min_val) / (max_val - min_val)
    filled = math.round(pct * length)
    filled := math.max(0, math.min(length, filled)) 
    bar_str = "\n\n["
    for i = 1 to length
        bar_str += (i <= filled ? "█" : "░")
    bar_str + "] RSI: " + str.tostring(val, "#.##")

// ==========================================
// 4. THE STATELESS RENDERER
// ==========================================
renderUI(table table_id, UITheme theme, string icon, string title, string body, color status_col, float metric_val) =>
    if barstate.islast
        
        var title_format = theme.font_style == 1 ? text.format_bold : theme.font_style == 2 ? text.format_italic : text.format_none

        animated_avatar_bg = pulseColor(status_col, 150)
        animated_body_text = typewriterText(body, ai_state.start_time, 25)
        
        final_body = animated_body_text + progressBar(metric_val, 0, 100)

        // Avatar
        table.cell(table_id, 0, 0, icon, text_size=32, bgcolor=animated_avatar_bg)
        
        // Title
        table.cell(table_id, 1, 0, title, text_color=theme.text_col, text_size=theme.title_size, text_formatting=title_format, bgcolor=theme.header_bg, text_halign=text.align_left)
        
        // Body (Increased width to accommodate lists)
        table.cell(table_id, 1, 1, final_body, width=40, text_color=theme.text_col, text_size=theme.body_size, bgcolor=theme.body_bg, text_halign=text.align_left, text_valign=text.align_top)

// ==========================================
// 5. LOGIC ENGINE
// ==========================================
style_input = input.string("Nord", "UI Theme", options=["Cyberpunk", "Glass", "Warzone", "Nord", "Midnight", "Minimal Light"])
rsi_val     = ta.rsi(close, 14)

UITheme activeTheme = switch style_input
    "Cyberpunk"     => getCyberpunk()
    "Glass"         => getGlass()
    "Warzone"       => getWarzone()
    "Nord"          => getNord()
    "Midnight"      => getMidnight()
    "Minimal Light" => getMinimalLight()
    => getNord()

// Default State
string icon_str = "🛰️"
string t_str    = "ANALYZING MARKET"
string b_str    = "Market is currently stable.\n• Scanning for momentum shifts.\n• Monitoring baseline structures."
color  c_status = color.gray
int    current_condition = 0 

// Logic checks with expanded, actionable lists
if rsi_val > 70
    icon_str := "⚠️"
    t_str    := "OVERBOUGHT ALERT"
    b_str    := "RSI is extended. Momentum may stall.\nRecommended Actions:\n• Secure partial profits here.\n• Tighten trailing stop losses.\n• Do not enter new long positions.\n• Watch for bearish divergence."
    c_status := color.red
    current_condition := 1
else if rsi_val < 30
    icon_str := "🟢"
    t_str    := "OVERSOLD ALERT"
    b_str    := "RSI is depressed. Bounce probable.\nRecommended Actions:\n• Look for accumulation wicks.\n• Wait for bullish RSI divergence.\n• Prepare for mean reversion play.\n• Check higher timeframe trend."
    c_status := color.green
    current_condition := -1

if current_condition != ai_state.state_id
    ai_state.state_id := current_condition
    ai_state.start_time := timenow 

// ==========================================
// 6. RENDER
// ==========================================
var ui_table = table.new(position.bottom_right, 2, 2, border_width=2, border_color=activeTheme.border_col)
renderUI(ui_table, activeTheme, icon_str, t_str, b_str, c_status, rsi_val)
````

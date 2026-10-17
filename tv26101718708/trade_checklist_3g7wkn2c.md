# Trade checklist!

- url: https://www.tradingview.com/script/3G7wkn2C-Trade-checklist/
- type: indicator
- pine_id: PUB;43748b3baae144c8921a654773b54ebd
- version: 2.0

## Description

Here is a clean, professional, and compelling description tailored specifically for the TradingView community. It is designed to be pasted directly into your script’s publishing page to clearly explain what the indicator does, why traders need it, and how to use it.
📋 Trading Setup Checklist (Pre-Trade Gatekeeper)
📌 Overview

The Trading Setup Checklist is an interactive, on-screen heads-up display (HUD) designed to eliminate emotional trading, FOMO, and impulsive entries. Instead of relying on mental notes or external scratchpads, this indicator embeds a clean, high-contrast digital checklist directly onto your TradingView chart. It acts as your personal pre-flight gatekeeper before risking any market capital.

By forcing you to visually confirm your edge rule-by-rule, this tool bridges the gap between a written trading plan and disciplined execution.
🚀 Key Features

    10 Fully Customizable Rules: Type your exact strategy conditions (e.g., HTF Trend Alignment, Key S/R Levels, Risk-to-Reward Ratio, Macro News Check) directly into the script settings.

    Dynamic Visual Feedback: Uses a strict, high-contrast color system. Unchecked rules stay Maroon [ ] (Stop/Wait), while confirmed rules instantly flip to Green [x] (Go).

    Adjustable Display Length: Don't need all 10 rules? Use the "Visible Items Count" slider to scale the display down to match your exact setup.

    Zero Chart Clutter: Built using Pine Script’s native table engine. The dashboard stays anchored smoothly to the top-right corner of your screen and won't get buried or distorted when you zoom or scroll through candlesticks.

    Performance Optimized: The engine executes strictly on the live close (barstate.islast), ensuring zero chart lag, lightning-fast rendering, and maximum processing efficiency.

🛠️ How to Use It

    Define Your Edge: Open the indicator settings (gear icon) and type your specific trading rules into the text boxes.

    Set Your Layout: Adjust the visible item count and choose between Small, Normal, or Large text sizes to fit your display resolution.

    Scan the Setup: When a potential setup forms, open the settings menu.

    Check the Boxes: Tick the boxes for the conditions the market has successfully met.

    Execute with Discipline: If the dashboard on your screen isn't completely green, no trade is taken.

🧠 Trading Psychology Value

The hardest part of trading isn't finding a strategy; it's executing it consistently. This indicator addresses cognitive bias by transforming your passive trading plan into an active, visual checkpoint. It forces an objective pause before hitting "Buy" or "Sell," ensuring you only execute trades that completely align with your proven edge.

> Disclaimer: This indicator is a visual checklist utility designed solely to assist tracking user-defined rule compliance. It does not generate automatic trade signals, commercial bias, or financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("Pre-Trade Execution Dashboard", "Trade Checklist", overlay = true)

// --- Groups ---
string G1 = "Colors"
string G2 = "Rules 1-5 (Base)"
string G3 = "Rules 6-10 (Extended)"

// --- Color Inputs ---
color metColor    = input.color(#089981, "Met Color", group = G1)
color notMetColor = input.color(#800000, "Not Met Color", group = G1)
color textColor   = input.color(color.white, "Text Color", group = G1)

// --- Rules 1-5 ---
string rule1  = input.string("Rule 1: Trend Alignment", "Description", group = G2)
bool   check1 = input.bool(false, "Met?", inline = "1", group = G2)

string rule2  = input.string("Rule 2: RSI Overbought/Oversold", "Description", group = G2)
bool   check2 = input.bool(false, "Met?", inline = "2", group = G2)

string rule3  = input.string("Rule 3: Key S/R Level", "Description", group = G2)
bool   check3 = input.bool(false, "Met?", inline = "3", group = G2)

string rule4  = input.string("Rule 4: Volume Confirmation", "Description", group = G2)
bool   check4 = input.bool(false, "Met?", inline = "4", group = G2)

string rule5  = input.string("Rule 5: Risk/Reward > 1:2", "Description", group = G2)
bool   check5 = input.bool(false, "Met?", inline = "5", group = G2)

// --- Rules 6-10 (Toggleable) ---
bool   show6  = input.bool(true, "Enable Rule 6", group = G3)
string rule6  = input.string("Rule 6: News Check", "Description", group = G3)
bool   check6 = input.bool(false, "Met?", inline = "6", group = G3)

bool   show7  = input.bool(true, "Enable Rule 7", group = G3)
string rule7  = input.string("Rule 7: Stop Loss Defined", "Description", group = G3)
bool   check7 = input.bool(false, "Met?", inline = "7", group = G3)

bool   show8  = input.bool(true, "Enable Rule 8", group = G3)
string rule8  = input.string("Rule 8: Take Profit Defined", "Description", group = G3)
bool   check8 = input.bool(false, "Met?", inline = "8", group = G3)

bool   show9  = input.bool(true, "Enable Rule 9", group = G3)
string rule9  = input.string("Rule 9: Position Sizing", "Description", group = G3)
bool   check9 = input.bool(false, "Met?", inline = "9", group = G3)

bool   show10 = input.bool(true, "Enable Rule 10", group = G3)
string rule10 = input.string("Rule 10: Mental State Check", "Description", group = G3)
bool   check10 = input.bool(false, "Met?", inline = "10", group = G3)

// --- Logic ---
if barstate.islast
    // Arrays for easy iteration
    string[] ruleTexts  = array.from(rule1, rule2, rule3, rule4, rule5, rule6, rule7, rule8, rule9, rule10)
    bool[]   ruleStates = array.from(check1, check2, check3, check4, check5, check6, check7, check8, check9, check10)
    bool[]   ruleShows  = array.from(true, true, true, true, true, show6, show7, show8, show9, show10)

    // Calculate total visible rows
    int visibleRows = 0
    for show in ruleShows
        if show
            visibleRows += 1

    // Initialize Table
    var table dashboard = table.new(position.top_right, 2, 10, border_width = 1, border_color = color.new(chart.fg_color, 70))
    
    // Clear the table first (in case rules were removed)
    table.clear(dashboard, 0, 0, 1, 9)

    // Fill table
    int currentRow = 0
    for i = 0 to 9
        if array.get(ruleShows, i)
            string txt   = array.get(ruleTexts, i)
            bool met     = array.get(ruleStates, i)
            
            color bg    = met ? metColor : notMetColor
            string icon = met ? "[x]" : "[ ]"

            table.cell(dashboard, 0, currentRow, icon, bgcolor = bg, text_color = textColor, text_size = size.small)
            table.cell(dashboard, 1, currentRow, txt, bgcolor = bg, text_color = textColor, text_halign = text.align_left, text_size = size.small)
            
            currentRow += 1
````

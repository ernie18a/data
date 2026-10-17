# Hopiplaka Goldbach Swings

- url: https://www.tradingview.com/script/KeDeWdH7-Hopiplaka-Goldbach-Swings/
- type: indicator
- pine_id: PUB;302e0fc7c2dd42e59422108b7517230a
- version: 1.0

## Description

Core Functionality
Swing Detection: Uses Left and Right Buffer inputs to identify pivot highs and lows using ta.pivothigh() and ta.pivotlow().
Three Reference Points: For every potential swing, it calculates:
Minute: minute(time)
Hour + Minute: hour(time) + minute(time)
|Hour - Minute|: abs(hour(time) - minute(time))
Goldbach/CE Master List: Checks all three references against the master list: 0, 3, 7, 11, 14, 17, 23, 29, 35, 41, 44, 47, 50, 53, 56, 59, 65, 71, 77, 83, 89, 97, 100.
Tolerance: A user-defined tolerance (0 or 1) allows for near-matches.
Display Rules
Conditional Labels: By default, labels only appear if at least one reference point matches a Goldbach number. I've added a toggle to show all swings in gray if you wish to see non-matching pivots.
Color Coding:
Green: Swing High with a Goldbach match.
Red: Swing Low with a Goldbach match.
Gray: Swings with no match (only if "Show All" is enabled).
Inverse Rule (> 60): If a matched Goldbach number is greater than 60, the label displays its complement to 100 (e.g., 89 is displayed as 11). The original reference value (e.g., 89) is still shown for context.
Usage Notes
The script is an overlay, meaning it draws directly on the price chart.
It uses the chart's current timezone to calculate hours and minutes.
You can adjust the Left/Right Buffer to fine-tune the "strength" of the swings (larger buffers result in fewer, more significant pivots)

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © dbadu34

//@version=6
plot(close)
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Hopiplaka Goldbach Swings", overlay = true, max_labels_count = 500)

// --- Inputs ---
int leftLenInput   = input.int(10, "Left Buffer", minval = 1, tooltip = "Number of bars to the left required for pivot detection.")
int rightLenInput  = input.int(10, "Right Buffer", minval = 1, tooltip = "Number of bars to the right required for pivot detection.")
int toleranceInput = input.int(0, "Tolerance", minval = 0, maxval = 1, tooltip = "Match Goldbach numbers within this range (0 or 1).")
color bullColor    = input.color(#089981, "Swing High Color", group = "Style")
color bearColor    = input.color(#f23645, "Swing Low Color", group = "Style")
bool showAllSwings = input.bool(false, "Show All Swings (Gray if no GB Match)", tooltip = "If enabled, shows all swings. If disabled, only shows swings matching Goldbach numbers.")

// --- Constants ---
// Goldbach/CE Master List
int[] GOLDBACH_LIST = array.from(0, 3, 7, 11, 14, 17, 23, 29, 35, 41, 44, 47, 50, 53, 56, 59, 65, 71, 77, 83, 89, 97, 100)

// --- Functions ---
// Check if a value matches a Goldbach number within tolerance
// Returns the matched Goldbach number if found, otherwise -1
get_gb_match(float val, int tol) =>
    int match = -1
    for gb in GOLDBACH_LIST
        if math.abs(val - gb) <= tol
            match := gb
            break
    match

// Format the display value based on the inverse rule (> 60)
format_gb_display(int gbValue) =>
    gbValue > 60 ? 100 - gbValue : gbValue

// --- Core Logic ---
float ph = ta.pivothigh(high, leftLenInput, rightLenInput)
float pl = ta.pivotlow(low, leftLenInput, rightLenInput)

// Process Pivot
process_pivot(float price, bool isHigh) =>
    if not na(price)
        // Get time components from the bar where the pivot occurred (rightLenInput bars ago)
        int pivotTime = time[rightLenInput]
        int m = minute(pivotTime)
        int h = hour(pivotTime)
        
        int valM = m
        int valSum = h + m
        int valDiff = math.abs(h - m)
        
        int matchM    = get_gb_match(valM, toleranceInput)
        int matchSum  = get_gb_match(valSum, toleranceInput)
        int matchDiff = get_gb_match(valDiff, toleranceInput)
        
        bool hasMatch = matchM != -1 or matchSum != -1 or matchDiff != -1
        
        if hasMatch or showAllSwings
            string txt = "M: " + str.tostring(valM)
            if matchM != -1
                txt += " (GB: " + str.tostring(format_gb_display(matchM)) + ")"
            
            txt += "\nH+M: " + str.tostring(valSum)
            if matchSum != -1
                txt += " (GB: " + str.tostring(format_gb_display(matchSum)) + ")"
                
            txt += "\n|H-M|: " + str.tostring(valDiff)
            if matchDiff != -1
                txt += " (GB: " + str.tostring(format_gb_display(matchDiff)) + ")"
            
            color bgColor = hasMatch ? (isHigh ? bullColor : bearColor) : color.gray
            label.new(
                 bar_index[rightLenInput], 
                 price, 
                 txt, 
                 color = bgColor, 
                 textcolor = chart.fg_color, 
                 style = isHigh ? label.style_label_down : label.style_label_up,
                 size = size.small
             )

// Execute
process_pivot(ph, true)
process_pivot(pl, false)
````

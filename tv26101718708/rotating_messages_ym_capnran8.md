# Rotating Messages [YM]

- url: https://www.tradingview.com/script/CApnRAn8/
- type: indicator
- pine_id: PUB;9952608059c1449abc0a1bd3485aa4c8
- version: 1.0

## Description

Trading is 80% psychology and 20% strategy. How many times have you broken your trading plan or made a bad decision simply because you got carried away by the emotion of the moment?

I created the Rotating Messages [YM] indicator to act as your personal psychological assistant. This script displays your trading rules, reminders, or motivational quotes directly on your chart, rotating them automatically so you never lose focus while trading.

✨ Main Features:

    🔄 Smart Time Rotation: Unlike other indicators that stay frozen until the candle closes, this script uses the internal clock (when the market is open and the price moves) to rotate your messages every "X" seconds of your choosing. Ideal for higher timeframe charts where candles take a long time to close. (Note: In backtesting or weekends, it will automatically switch to bar counting).

    ⚠️ Dynamic Visual Alerts: Do you have a rule that you absolutely cannot break? Simply add the ! symbol at the beginning of your sentence in the settings (e.g., !Avoid trading on Friday afternoons). The indicator will hide the symbol and highlight that phrase with a striking yellow background to grab your attention immediately.

    🛠️ Perfect Positioning: Don't let the text block the price action. You can choose the screen corner and fine-tune the panel using the "Offsets" (Vertical and Horizontal) to place it exactly where it won't bother you.

    🎨 Total Customization: Change the text color, adjust the background opacity to see the candles through the panel, and choose between three text sizes.

    ⌨️ Simplicity of Use: Forget about complex coding. Type your rules in the text box and simply press "ENTER" to separate one phrase from the next.

📝 What's included by default?
The indicator comes pre-loaded with a list of golden risk management rules and trading psychology quotes ready to use, but you can delete everything and put your own personal trading plan.

💡 A disciplined trader is a profitable trader. Keep your mind focused, respect your Stop Loss, and let this indicator remind you of your flight plan every day.

If you find it useful to maintain discipline, don't forget to hit "Like" and add it to your favorites! Let me know in the comments which trading rule is the hardest for you to follow. 👇

## Source Code

````pine
//@version=5
// ==========================================
// Current Version: v2.00
// ==========================================
indicator("Rotating Messages [YM]", overlay=true)

// --- USER INPUTS ---
corner_opt = input.string(title="Screen position", defval="Top right", options=["Top right", "Bottom right", "Bottom center"])
vertical_offset = input.int(title="Vertical offset", defval=5, minval=0, maxval=20, tooltip="Adds empty rows above to lower the text.")
horizontal_offset = input.int(title="Horizontal offset", defval=0, minval=0, maxval=20, tooltip="Adds empty columns to the right to move the text to the left.")

// Messages separated only by "ENTER" (Add "!" at the start for a yellow background)
default_msgs = "Rule 1: Follow your plan\n" +
               "Rule 2: Accept losses as part of trading\n" +
               "Rule 3: Don't revenge trade after a loss\n" +
               "Rule 4: Let winners run and cut losers fast\n" +
               "Rule 5: Patience pays, wait for your ideal setup\n" +
               "Rule 6: Trading is a marathon, not a sprint\n" +
               "Rule 7: Keep your trading journal updated\n" +
               "Rule 8: Do not trade if you are not emotionally stable\n" +
               "Rule 9: If the 4H is not clear, do not trade.\n" +
               "Discipline over emotions\n" +
               "Focus on the process, not the money\n" +
               "Be humble before the market\n" +
               "Success requires time and practice\n" +
               "Don't seek to be right, seek to be profitable\n" +
               "Consistency always wins\n" +
               "Respect your Stop Loss without excuses\n" +
               "Visualize your success and trade calmly\n" +
               "!Reminder: Avoid Mondays and Friday afternoons"

messages_input = input.text_area(title="Messages (separated by ENTER)", defval=default_msgs)

use_time_switch = input.bool(true, "Prefer TIME-based switching (seconds).")
interval_seconds = input.int(10, title="Switch every X seconds (live)", minval=1)
switch_interval_bars = input.int(20, title="Switch every X bars (historical)", minval=1)

// Colors and size
text_color = input.color(color.black, title="Text color")
bg_color = input.color(color.new(#0f0f0f, 80), title="Normal background color")
txt_size = input.string(title="Text size", defval="Large", options=["Small", "Normal", "Large"])
show_border = input.bool(false, "Show border around cell")

// --- PROCESS MESSAGES ---
var string[] msgs = array.new_string()
if barstate.isfirst
    // Split the list DIRECTLY by line breaks (\n)
    parts = str.split(messages_input, "\n")
    for i = 0 to array.size(parts) - 1
        msg = str.trim(array.get(parts, i))
        if str.length(msg) > 0
            array.push(msgs, msg)

if array.size(msgs) == 0
    array.push(msgs, "No messages set")

// Position mapping for the table
pos = corner_opt == "Top right" ? position.top_right : corner_opt == "Bottom center" ? position.bottom_center : position.bottom_right
size_map = txt_size == "Small" ? size.small : txt_size == "Large" ? size.large : size.normal

// --- TABLE CREATION ---
var table cornerTable = na
if barstate.isfirst
    // Create the table considering the horizontal (extra columns) and vertical (extra rows) offsets
    cornerTable := table.new(pos, horizontal_offset + 1, vertical_offset + 1, border_width = show_border ? 1 : 0)

var int msg_idx = 0

// Absolute time-based rotation logic
if use_time_switch and barstate.isrealtime
    msg_idx := int(timenow / (interval_seconds * 1000)) % array.size(msgs)
else
    msg_idx := int(math.floor(bar_index / switch_interval_bars)) % array.size(msgs)

msg_raw = array.get(msgs, msg_idx)

// ALERT LOGIC: Detect if it starts with "!"
is_alert = str.startswith(msg_raw, "!")

// If it's an alert, remove the "!" from the start so it doesn't show on screen. Otherwise, leave it as is.
msg_to_show = is_alert ? str.substring(msg_raw, 1) : msg_raw

// Assign the 70% transparent yellow background if it's an alert, otherwise use the default background
current_bg = is_alert ? color.new(#ffeb3b, 70) : bg_color

// Drawing the table on the last bar
if barstate.islast and not na(cornerTable)
    
    // 1. Empty rows for vertical offset
    if vertical_offset > 0
        for i = 0 to vertical_offset - 1
            table.cell(cornerTable, 0, i, "", bgcolor=color.new(color.white, 100)) // 100 = completely transparent
    
    // 2. Main cell with the message and dynamic color
    table.cell(cornerTable, 0, vertical_offset, msg_to_show, text_color=text_color, bgcolor=current_bg, text_size=size_map)

    // 3. Empty columns for horizontal offset (pushes the text to the left)
    if horizontal_offset > 0
        for j = 1 to horizontal_offset
            // Use blank spaces ("   ") to give width to the invisible column
            table.cell(cornerTable, j, vertical_offset, "   ", text_color=color.new(color.white, 100), bgcolor=color.new(color.white, 100), text_size=size_map)
````

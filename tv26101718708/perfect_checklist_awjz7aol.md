# Perfect Checklist

- url: https://www.tradingview.com/script/awjz7aol-Perfect-Checklist/
- type: indicator
- pine_id: PUB;67c2a9ce8a1c454f93f5b64764ed13d2
- version: 1.0

## Description

🛠️ 1. Active Features built into the Script

• Isolated Status Line Display: Every background indicator configuration is hidden from your upper-left chart information strip, leaving only your custom text ticker (e.g., HD) completely clean and viewable. You can make copies of the script in the pine editor window and number them so that you can use a separate checklist on more than 1 ticker at a time.
• Smart 3-Column Chart Layout: Dynamically draws a clean visual grid displaying your checklist text lines, matching dropdown status symbols, and custom written notes.
• Auto-Collapsing Table Rows: Activating or deactivating criteria lines in your settings panel instantly re-sizes the on-chart table layout so no blank lines clutter your trading screen.
• Reordered Live Copy Logger: Automatically bundles your current workspace setups into a cleanly formatted, live text block arranged exactly like your chart: [Text Description] [Status Icon] [Notes]. More on that in section 3 below.

📐 2. Essential Chart Layout Settings

To ensure your status line shows your literal typed text letters instead of messy numeric positional formulas or indicator text spam, configure your chart properties exactly like this:
1. Open your TradingView Chart Settings (right-click the background grid and select Settings, or double click the chart).
2. Navigate to the Status Line panel tab.
3. Check the box next to "Arguments" (or Inputs in status line). This forces your literal text string ticker entry to load.
4. Uncheck the box next to "Values" (or Values in status line). This eliminates irrelevant trailing calculation metrics from clogging your bar.

📋 3. How to Copy Your Live Trade Checklist Data

Because you can't click or highlight text straight off an on-chart visual table, use your built-in custom logger shortcut:
1. Move your mouse cursor onto your checklist table display or the text ticker on your chart layout.
2. Right-click directly on the indicator and select Pine Logs... from the contextual action menu.
3. A clean data sub-panel terminal window will instantly  open.
4. Every single time you toggle an entry row checkbox, pick a new dropdown symbol, or edit a notes field on your chart, a fresh text block immediately updates inside that console which you can copy to a text box on your layout for adding to your chart directly, formatted just like the checklist indicator for a more permanent addition to your chart.

## Source Code

````pine
//@version=6
indicator("Perfect Checklist", overlay=true)

// ========================= Entry Inputs =========================
var string GP_ITEMS = "Checklist Items & Notes"

bool e1  = input.bool(true, inline="1", group=GP_ITEMS, display = display.none)
string entry1  = input.string("Daily & Wkly RSI Aligned", inline="1", group=GP_ITEMS, display = display.none)
string status1 = input.string("", options=["","✓","✕","✅","❌","⚪","🟠","🟡","🔴","True","False","Yes","No"], inline="1", group=GP_ITEMS, display = display.none)
string note1   = input.string("", title="Note", inline="1", group=GP_ITEMS, display = display.none)

bool e2  = input.bool(true, inline="2", group=GP_ITEMS, display = display.none)
string entry2  = input.string("Market Direction Alignment", inline="2", group=GP_ITEMS, display = display.none)
string status2 = input.string("", options=["","✓","✕","✅","❌","⚪","🟠","🟡","🔴","True","False","Yes","No"], inline="2", group=GP_ITEMS, display = display.none)
string note2   = input.string("", title="Note", inline="2", group=GP_ITEMS, display = display.none)

bool e3  = input.bool(true, inline="3", group=GP_ITEMS, display = display.none)
string entry3  = input.string("Sector Direction Alignment", inline="3", group=GP_ITEMS, display = display.none)
string status3 = input.string("", options=["","✓","✕","✅","❌","⚪","🟠","🟡","🔴","True","False","Yes","No"], inline="3", group=GP_ITEMS, display = display.none)
string note3   = input.string("", title="Note", inline="3", group=GP_ITEMS, display = display.none)

bool e4  = input.bool(true, inline="4", group=GP_ITEMS, display = display.none)
string entry4  = input.string("Recent History Alignment", inline="4", group=GP_ITEMS, display = display.none)
string status4 = input.string("", options=["","✓","✕","✅","❌","⚪","🟠","🟡","🔴","True","False","Yes","No"], inline="4", group=GP_ITEMS, display = display.none)
string note4   = input.string("", title="Note", inline="4", group=GP_ITEMS, display = display.none)

bool e5  = input.bool(true, inline="5", group=GP_ITEMS, display = display.none)
string entry5  = input.string("Backtest Results", inline="5", group=GP_ITEMS, display = display.none)
string status5 = input.string("", options=["","✓","✕","✅","❌","⚪","🟠","🟡","🔴","True","False","Yes","No"], inline="5", group=GP_ITEMS, display = display.none)
string note5   = input.string("", title="Note", inline="5", group=GP_ITEMS, display = display.none)

bool e6  = input.bool(true, inline="6", group=GP_ITEMS, display = display.none)
string entry6  = input.string("Price Pattern Confirmation", inline="6", group=GP_ITEMS, display = display.none)
string status6 = input.string("", options=["","✓","✕","✅","❌","⚪","🟠","🟡","🔴","True","False","Yes","No"], inline="6", group=GP_ITEMS, display = display.none)
string note6   = input.string("", title="Note", inline="6", group=GP_ITEMS, display = display.none)

bool e7  = input.bool(true, inline="7", group=GP_ITEMS, display = display.none)
string entry7  = input.string("Earnings 14+ Days Away", inline="7", group=GP_ITEMS, display = display.none)
string status7 = input.string("", options=["","✓","✕","✅","❌","⚪","🟠","🟡","🔴","True","False","Yes","No"], inline="7", group=GP_ITEMS, display = display.none)
string note7   = input.string("", title="Note", inline="7", group=GP_ITEMS, display = display.none)

bool e8  = input.bool(false, inline="8", group=GP_ITEMS, display = display.none)
string entry8  = input.string("", inline="8", group=GP_ITEMS, display = display.none)
string status8 = input.string("", options=["","✓","✕","✅","❌","⚪","🟠","🟡","🔴","True","False","Yes","No"], inline="8", group=GP_ITEMS, display = display.none)
string note8   = input.string("", title="Note", inline="8", group=GP_ITEMS, display = display.none)

bool e9  = input.bool(false, inline="9", group=GP_ITEMS, display = display.none)
string entry9  = input.string("", inline="9", group=GP_ITEMS, display = display.none)
string status9 = input.string("", options=["","✓","✕","✅","❌","⚪","🟠","🟡","🔴","True","False","Yes","No"], inline="9", group=GP_ITEMS, display = display.none)
string note9   = input.string("", title="Note", inline="9", group=GP_ITEMS, display = display.none)

bool e10 = input.bool(false, inline="10", group=GP_ITEMS, display = display.none)
string entry10 = input.string("", inline="10", group=GP_ITEMS, display = display.none)
string status10 = input.string("", options=["","✓","✕","✅","❌","⚪","🟠","🟡","🔴","True","False","Yes","No"], inline="10", group=GP_ITEMS, display = display.none)
string note10  = input.string("", title="Note", inline="10", group=GP_ITEMS, display = display.none)

bool e11 = input.bool(false, inline="11", group=GP_ITEMS, display = display.none)
string entry11 = input.string("", inline="11", group=GP_ITEMS, display = display.none)
string status11 = input.string("", options=["","✓","✕","✅","❌","⚪","🟠","🟡","🔴","True","False","Yes","No"], inline="11", group=GP_ITEMS, display = display.none)
string note11  = input.string("", title="Note", inline="11", group=GP_ITEMS, display = display.none)

bool e12 = input.bool(false, inline="12", group=GP_ITEMS, display = display.none)
string entry12 = input.string("", inline="12", group=GP_ITEMS, display = display.none)
string status12 = input.string("", options=["","✓","✕","✅","❌","⚪","🟠","🟡","🔴","True","False","Yes","No"], inline="12", group=GP_ITEMS, display = display.none)
string note12  = input.string("", title="Note", inline="12", group=GP_ITEMS, display = display.none)

bool e13 = input.bool(false, inline="13", group=GP_ITEMS, display = display.none)
string entry13 = input.string("", inline="13", group=GP_ITEMS, display = display.none)
string status13 = input.string("", options=["","✓","✕","✅","❌","⚪","🟠","🟡","🔴","True","False","Yes","No"], inline="13", group=GP_ITEMS, display = display.none)
string note13  = input.string("", title="Note", inline="13", group=GP_ITEMS, display = display.none)

bool e14 = input.bool(false, inline="14", group=GP_ITEMS, display = display.none)
string entry14 = input.string("", inline="14", group=GP_ITEMS, display = display.none)
string status14 = input.string("", options=["","✓","✕","✅","❌","⚪","🟠","🟡","🔴","True","False","Yes","No"], inline="14", group=GP_ITEMS, display = display.none)
string note14  = input.string("", title="Note", inline="14", group=GP_ITEMS, display = display.none)

bool e15 = input.bool(false, inline="15", group=GP_ITEMS, display = display.none)
string entry15 = input.string("", inline="15", group=GP_ITEMS, display = display.none)
string status15 = input.string("", options=["","✓","✕","✅","❌","⚪","🟠","🟡","🔴","True","False","Yes","No"], inline="15", group=GP_ITEMS, display = display.none)
string note15  = input.string("", title="Note", inline="15", group=GP_ITEMS, display = display.none)
// ========================= Collect Arrays =========================
string[] finalEntries  = array.from(entry1, entry2, entry3, entry4, entry5, entry6, entry7, entry8, entry9, entry10, entry11, entry12, entry13, entry14, entry15)
string[] finalStatuses = array.from(status1, status2, status3, status4, status5, status6, status7, status8, status9, status10, status11, status12, status13, status14, status15)
string[] finalNotes    = array.from(note1, note2, note3, note4, note5, note6, note7, note8, note9, note10, note11, note12, note13, note14, note15)
bool[]   finalEnables  = array.from(e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11, e12, e13, e14, e15)

// ========================= Layout Customization =========================
var string GP_LAYOUT = "General Layout"

string tableTitle = input.string("Perfect Checklist", "Table Title", group=GP_LAYOUT, display = display.none)
string inputTicker = input.string("", "Ticker", group=GP_LAYOUT)
color headerTextColor = input.color(color.white, "Header Text Color", group=GP_LAYOUT, display = display.none)

string notesTitle = input.string("Notes", "Notes Column Title", group=GP_LAYOUT, display = display.none)

string tablePosInput = input.string("Top Right", "Table Position", 
     options=["Top Left", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Right"], 
     group=GP_LAYOUT, display = display.none)

string sizeInput = input.string("Large", "Table Scaling Size", 
     options=["Large", "Small"], 
     group=GP_LAYOUT, display = display.none)

int maxEntries = input.int(15, "Max entries to display", minval=1, maxval=15, group=GP_LAYOUT, display = display.none)
bool hideDisabled = input.bool(true, "Hide disabled entries", group=GP_LAYOUT, display = display.none)

// ========================= Color Configuration =========================
var string GP2 = "Colors"
color titleBgColor   = input.color(color.new(color.gray, 40), "Title Background", group=GP2, display = display.none)
color entryTextColor = input.color(color.white, "Entry Text Color", group=GP2, display = display.none)
color entryBgColor   = input.color(color.new(color.black, 0), "Entry Background Color", group=GP2, display = display.none)

// Symbol statuses colors
color completedColor = input.color(color.new(color.teal, 60), "✅ Completed", group=GP2, display = display.none)
color failedColor    = input.color(color.new(color.maroon, 60), "❌ Failed", group=GP2, display = display.none)
color neutralColor   = input.color(color.new(color.silver, 60), "⚪ Neutral", group=GP2, display = display.none)
color orangeColor    = input.color(color.new(color.orange, 60), "🟠", group=GP2, display = display.none)
color redColor       = input.color(color.new(color.red, 60), "🔴", group=GP2, display = display.none)
color trueColor      = input.color(color.new(color.green, 60), "True/Yes", group=GP2, display = display.none)
color falseColor     = input.color(color.new(color.maroon, 60), "False/No", group=GP2, display = display.none)
color borderColor    = input.color(color.new(color.white, 80), "Border Color", group=GP2, display = display.none)

// ========================= Count visible rows =========================
int totalChecklistItems = array.size(finalEntries)
int rowCount = 0
for i = 0 to totalChecklistItems - 1
    if hideDisabled
        if array.get(finalEnables, i)
            rowCount += 1
    else
        rowCount += 1

// ========================= Table Placement Evaluation =========================
string resolvedPosition = tablePosInput == "Top Left"     ? position.top_left :
                          tablePosInput == "Top Right"    ? position.top_right :
                          tablePosInput == "Middle Left"  ? position.middle_left :
                          tablePosInput == "Middle Right" ? position.middle_right :
                          tablePosInput == "Bottom Left"  ? position.bottom_left : position.bottom_right

string resolvedTextSize = sizeInput == "Small" ? size.small : size.normal

// Clean 3-Column structural matrix restored
var table checklistTable = table.new(resolvedPosition, 3, rowCount + 1, border_width=1, border_color=borderColor, bgcolor=entryBgColor)

if barstate.islast
    string continuousHeader = tableTitle + (inputTicker != "" ? " (" + str.tostring(inputTicker) + ")" : "")
    
    table.cell(checklistTable, 0, 0, continuousHeader, bgcolor=titleBgColor, text_color=headerTextColor, text_size=resolvedTextSize, text_formatting=text.format_bold, text_halign=text.align_center)
    table.cell(checklistTable, 1, 0, "", bgcolor=titleBgColor, text_color=headerTextColor, text_size=resolvedTextSize)
    table.cell(checklistTable, 2, 0, notesTitle, bgcolor=titleBgColor, text_color=headerTextColor, text_size=resolvedTextSize, text_formatting=text.format_bold)

    // Build the copying data string buffer
    string exportString = "=== " + continuousHeader + " ===\n"

    int currentRow = 1
    for i = 0 to totalChecklistItems - 1
        if hideDisabled and not array.get(finalEnables, i)
            continue
            
        string labelText = array.get(finalEntries, i)
        table.cell(checklistTable, 0, currentRow, labelText, bgcolor=entryBgColor, text_color=entryTextColor, text_size=resolvedTextSize, text_halign=text.align_left)
        
        string s = array.get(finalStatuses, i)
        color c = s == "✓" or s == "✅" or s == "Yes" or s == "True" ? completedColor :
                  s == "✕" or s == "❌" or s == "No" or s == "False" ? failedColor :
                  s == "⚪" ? neutralColor :
                  s == "🟠" ? orangeColor :
                  s == "🔴" ? redColor : entryBgColor
        table.cell(checklistTable, 1, currentRow, s, bgcolor=c, text_color=entryTextColor, text_size=resolvedTextSize)
        
        string noteText = array.get(finalNotes, i)
        table.cell(checklistTable, 2, currentRow, noteText, bgcolor=entryBgColor, text_color=entryTextColor, text_size=resolvedTextSize, text_halign=text.align_left)
        
        // Output layout matching visual order: [Text Description] [Status Icon] [Notes]
        string cleanStatus = s != "" ? " [" + s + "]" : " [ ]"
        string cleanNote   = noteText != "" ? " | Note: " + noteText : ""
        exportString += labelText + cleanStatus + cleanNote + "\n"
        
        currentRow += 1
        
    // Push the output text directly into your Pine Logs tab panel
    log.info(exportString)

// Invisible compilation patch line
plot(na, title="Hidden Anchor")
````

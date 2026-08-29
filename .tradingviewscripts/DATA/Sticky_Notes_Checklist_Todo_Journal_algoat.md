<!-- tradingview-pine-id: PUB;eb70cf38f57f487bbad70a7f3ab50f47 -->
<!-- tradingviewscripts-format: 1 -->
# Sticky Notes, Checklist, To-do, Journal [algoat]

Source: https://www.tradingview.com/script/Tlz0MxsJ-Sticky-Notes-Checklist-To-do-Journal-algoat/

## Description

I forgot to bring my notes again...

Ever feel like your trading notes are all over the place, much like your portfolio after a market dip? Worry not! With this script, you'll have all your trading notes, tasks, and brilliant (or not so brilliant) ideas neatly organized right on your chart. It's like having a sticky note board, but way cooler and without the risk of paper cuts.

⭐ Features:

To-Do Lists
Keep track of tasks with satisfying checkmarks for those dopamine hits.

Journal Entries
Document your market insights, trade plans, or just random thoughts. "I forgot something" – we've all been there.

Due Dates
Never miss an important deadline again. Red alert for overdue tasks because procrastination is a trader's worst enemy.

Customization
Choose the size and position of your notes because one size doesn't fit all.

Perfect for the organized trader who loves a bit of fun or the chaotic one who needs a bit of structure. Embrace the power of notes and stay on top of your trading game!

══════════════════

🧠 General advice

Trading effectively requires a range of techniques, experience, and expertise. From technical analysis to market fundamentals, traders must navigate multiple factors, including market sentiment and economic conditions. However, traders often find themselves overwhelmed by market noise, making it challenging to filter out distractions and make informed decisions. By integrating multiple analytical approaches, traders can tailor their strategies to fit their unique trading styles and objectives.

Confirming Signals with other indicators
As with all technical indicators, it is important to confirm potential signals with other analytical tools, such as support and resistance levels, as well as indicators like RSI, MACD, and volume. This helps increase the probability of a successful trade.

Use proper risk management
When using this or any other indicator, it is crucial to have proper risk management in place. Consider implementing stop-loss levels and thoughtful position sizing.

Combining with other technical indicators
The indicator can be effectively used alongside other technical indicators to create a comprehensive trading strategy and provide additional confirmation.

Keep in mind
Thorough research and backtesting are essential before making any trading decisions. Furthermore, it's crucial to have a solid understanding of the indicator and its behavior. Additionally, incorporating fundamental analysis and considering market sentiment can be vital factors to take into account in your trading approach.

══════════════════

⭐ Conclusion

We hold the view that the true path to success is the synergy between the trader and the tool, contrary to the common belief that the tool itself is the sole determinant of profitability. The actual scenario is more nuanced than such an oversimplification. A word to the wise is enough: developed by traders, for traders — pioneering innovations for the modern era.

Risk Notice
Everything provided by algoat — from scripts, tools, and articles to educational materials — is intended solely for educational and informational purposes. Past performance does not assure future returns.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © algoat

//@version=5
indicator("Sticky Notes, Checklist, To-do, Journal [algoat]", "Sticky Notes [algoat]", true)


type Block
    bool   is_on      = na
    string title      = na
    bool   is_done    = na
    string comment    = na
    bool   is_date    = na
    int    date       = na


i_name   = input('Notes' , 'Name'    , display = display.none)
i_check1 = input('✅'   , 'Checkbox', display = display.none, inline = 'check')
i_check0 = input('⬜'   , ''        , display = display.none, inline = 'check')
i_size   = input.string(size.normal       , 'Size'    , display = display.none, options = [size.tiny, size.small, size.normal, size.large, size.huge])
i_pos    = input.string(position.top_right, 'Position', display = display.none, options = [position.top_left   , position.top_center   , position.top_right, 
                                                                                           position.middle_left, position.middle_center, position.middle_right, 
                                                                                           position.bottom_left, position.bottom_center, position.bottom_right])

colors = map.new<string,color>()
colors.put('title'  , input.color(#ffffffd7, 'Colors', '', 'clr'))
colors.put('content', input.color(#ffffff80, ''      , '', 'clr'))
colors.put('bg'     , input.color(#ffffff00, ''      , '', 'clr'))
colors.put('green'  , input.color(#4caf50  , ''      , '', 'clr'))
colors.put('due'    , input.color(#ff5252  , ''      , '', 'clr'))

g1 = 'Note 1', g2 = 'Note 2', g3 = 'Note 3', g4 = 'Note 4', g5 = 'Note 5', g6 = 'Note 6'
var notes = array.from(
 Block.new(
 input.bool(true, "", inline = '1-1', group = g1, display = display.none),
 input.string('1st Note', "", inline = '1-1', group = g1, display = display.none),
 input.bool(true, "Checkbox", inline = '1-1', group = g1, display = display.none),
 input.text_area("This is my first note,\nand it's already a masterpiece!\n\nMultiple lines? No problem.\n\nTask completed? Check!\n\nFeeling accomplished? Absolutely.", '', group = g1, display = display.none),
 input.bool(false, '', inline = '1-3', group = g1, display = display.none),
 input.time(timestamp("31 Dec 2024 00:00"), "Due", inline = '1-3', group = g1, display = display.none)
 ),

 Block.new(
 input.bool(true, "", inline = '1-1', group = g2, display = display.none),
 input.string('2nd Task', "", inline = '1-1', group = g2, display = display.none),
 input.bool(false, "Checkbox", inline = '1-1', group = g2, display = display.none),
 input.text_area("This is my second note\nand it's a serious task.\nGot a due date and everything.\n\nBut hey, plenty of time left...\nso maybe tomorrow?\n\nProcrastinators unite!", '', group = g2, display = display.none),
 input.bool(true, '', inline = '1-3', group = g2, display = display.none),
 input.time(timestamp("31 Dec 2028 00:00"), "Due", inline = '1-3', group = g2, display = display.none)
 ),

 Block.new(
 input.bool(true, "", inline = '1-1', group = g3, display = display.none),
 input.string('Forgot something', "", inline = '1-1', group = g3, display = display.none),
 input.bool(false, "Checkbox", inline = '1-1', group = g3, display = display.none),
 input.text_area("I forgot something... again.\nIt was definitely crucial. Or was it?\nGuess we'll never know!", '', group = g3, display = display.none),
 input.bool(true, '', inline = '1-3', group = g3, display = display.none),
 input.time(timestamp("31 Jan 2024 00:00"), "Due", inline = '1-3', group = g3, display = display.none)
 ),

 Block.new(
 input.bool(false, "", inline = '1-1', group = g4, display = display.none),
 input.string('4th Note', "", inline = '1-1', group = g4, display = display.none),
 input.bool(false, "Checkbox", inline = '1-1', group = g4, display = display.none),
 input.text_area('', '', group = g4, display = display.none),
 input.bool(false, '', inline = '1-3', group = g4, display = display.none),
 input.time(timestamp("31 Dec 2024 00:00"), "Due", inline = '1-3', group = g4, display = display.none)
 ),

 Block.new(
 input.bool(true, "", inline = '1-1', group = g5, display = display.none),
 input.string('5th Note', "", inline = '1-1', group = g5, display = display.none),
 input.bool(false, "Checkbox", inline = '1-1', group = g5, display = display.none),
 input.text_area('Skipped the 4th note because I can!\nLiving on the edge, one note at a time.', '', group = g5, display = display.none),
 input.bool(false, '', inline = '1-3', group = g5, display = display.none),
 input.time(timestamp("31 Dec 2024 00:00"), "Due", inline = '1-3', group = g5, display = display.none)
 ),

 Block.new(
 input.bool(true, "", inline = '1-1', group = g6, display = display.none),
 input.string("Let's meeek money!", "", inline = '1-1', group = g6, display = display.none),
 input.bool(true, "Checkbox", inline = '1-1', group = g6, display = display.none),
 input.text_area('Done already?\nWow, I must be a trading wizard.\n\nTime to reward myself...\nwith a coffee break!', '', group = g6, display = display.none),
 input.bool(false, '', inline = '1-3', group = g6, display = display.none),
 input.time(timestamp("31 Dec 2024 00:00"), "Due", inline = '1-3', group = g6, display = display.none)
 )
 )


size_title = switch i_size
    size.tiny   => size.small
    size.small  => size.normal
    size.normal => size.large
    size.large  => size.huge
    =>             i_size

clr_chart = color.new(chart.fg_color, 85)
var t = table.new(i_pos, 3, 25, colors.get('bg'), clr_chart, 1)

if barstate.islast
    row = 0

    t.cell(0, row, i_name, text_size = size_title, text_color = colors.get('title'))
    t.merge_cells(0,row,2,row)

    row += 1

    t.cell(0, row, '', height = 0.1, bgcolor = clr_chart, text_size = i_size)
    t.merge_cells(0,row,2,row)

    row += 1

    for note in notes

        if not note.is_on
            continue

        t.cell(0, row, note.is_done ? i_check1 : i_check0, text_color = colors.get(note.is_done ? 'green' : 'due'), text_size = i_size)
        t.cell(1, row, note.title, text_color = colors.get('title'), text_size = size_title, text_halign = text.align_left)
        t.merge_cells(1,row,2,row)

        row += 1

        if note.is_date

            is_due  = timenow >= note.date and not note.is_done
            clr     = colors.get(is_due ? 'due' : note.is_done ? 'green' : 'content')
            txt_due = is_due ? 'Overdue!' : note.is_done ? '' : str.format('{0} days left', math.floor((note.date - timenow) / 8.64e7))

            t.cell(1, row, str.format_time(note.date, 'yyyy-MM-dd'), text_color = clr, text_size = i_size, text_halign = text.align_left)
            t.cell(2, row, txt_due, text_color = clr, text_size = i_size, text_halign = text.align_center)

            row += 1

        t.cell(0, row, note.comment, text_color = colors.get('content'), text_size = i_size, text_halign = text.align_left)
        t.merge_cells(0,row,2,row)

        row += 1

        t.cell(0, row, '', height = 0.1, bgcolor = clr_chart, text_size = i_size)
        t.merge_cells(0,row,2,row)

        row += 1
````

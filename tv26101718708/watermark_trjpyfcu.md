# Watermark

- url: https://www.tradingview.com/script/trJpyFCU-Watermark/
- type: indicator
- pine_id: PUB;ca84a7a736924e43a57c7b7f8900f2cf
- version: 1.0

## Description

[b]Watermark[/b]
A simple, clean watermark indicator designed to keep your trading mindset front and center while you work. Displays two fully customizable lines of text directly on your chart background — perfect for affirmations, rules, or reminders that keep you disciplined during a session.

[b]Features:[/b]
Two editable text lines
Full color picker for text
Adjustable fade
Five text size options
Clean status line (no clutter)

[b]How to Use:[/b]
Add the indicator to your chart, then click the Settings gear ⚙️ to customize the text, color, size, and fade to match your chart theme.

[b]Default Text:[/b]
"Trade with no emotion"
"Not what you think it will do"

These two reminders were chosen intentionally — emotions are the #1 account killer, and the market will humble anyone who thinks they know what's coming next. 

Customize the text to whatever rules or mantras matter most to your own trading process.
Free to use. No signals, no repaints, no nonsense — just a quiet reminder of what good trading looks like.

## Source Code

````pine
//@version=6
indicator("Watermark", overlay=true, max_labels_count=0)

line1 = input.string("Trade with no emotion", title="Line 1", display=display.none)
line2 = input.string("Not what you think it will do", title="Line 2", display=display.none)
textColor = input.color(color.white, title="Text Color", display=display.none)
fade = input.int(84, title="Fade (0=solid, 100=invisible)", minval=0, maxval=100, display=display.none)
textSize = input.string("Huge", title="Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], display=display.none)

size = textSize == "Tiny" ? size.tiny : textSize == "Small" ? size.small : textSize == "Normal" ? size.normal : textSize == "Large" ? size.large : size.huge

var table t = table.new(position.middle_center, 1, 1)
table.cell(t, 0, 0, line1 + "\n" + line2,
     text_color=color.new(textColor, fade),
     text_size=size,
     bgcolor=color.new(color.black, 100))
````

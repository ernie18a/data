# stick to rules

- url: https://www.tradingview.com/script/3hCS4Joh-stick-to-rules/
- type: indicator
- pine_id: PUB;84b075a073b34f6bbc241fb608df010f
- version: 2.0

## Description

Screw Those Who Didn't Believe, put that on your chart and see it daily to stick to the rules

## Source Code

````pine
//@version=6
indicator("Trzymaj się zasad", overlay=true)

var table reminder = table.new(
     position.top_center,
     1,
     1,
     bgcolor=color.new(color.white, 100),
     frame_width=0,
     border_width=0
)

txt = "\nSTICK TO THE RULES\nDISCIPLINE = FREEDOM\nPROCES PONAD EMOCJE\nPATIENCE + EXECUTION\nREVENGE TRADE = BLOWN ACCOUNT\n𝐉𝐞𝐛𝐚𝐜 𝐓𝐲𝐜𝐡 𝐂𝐨 𝐍𝐢𝐞 𝐖𝐢𝐞𝐫𝐳𝐲𝐥𝐢 !!!"

if barstate.islast
    table.cell(
         reminder,
         0,
         0,
         txt,
         text_color=color.black,
         text_size=size.normal,
         text_halign=text.align_center,
         text_valign=text.align_center,
         bgcolor=color.new(color.white, 100)
    )
````

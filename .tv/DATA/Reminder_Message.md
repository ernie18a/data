<!-- tradingview-pine-id: PUB;0w9H8mzV1NYVH7rFZZn70LXvS67aUA2H -->
<!-- tradingviewscripts-format: 1 -->
# Reminder Message

Source: https://www.tradingview.com/script/KLNJvOaF-Reminder-Message-with-color-picker-ApopheniaPays/

## Description

This is a very simple script. It displays a message above the latest price. I coded it because I need a constant reminder to keep me from overtrading. 

You can customize several options:
- The message text
- How high above the latest price the message is displayed
- How often it is displayed. 1=display constantly, 2=only show it during every other period, 3=only show it every 3rd new period, etc. So, for example, if you are on the 15 minute chart, and set a frequency of 3, it will show it for the first 15 minutes out of every 45. 
- Color and lightness. This can be used as an example of how to add a color selection input to your own scripts.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ApopheniaPays 

//@version = 4

study ( "Reminder Message" , overlay = true ) 
theReminder =    input ( "If you don't see an obvious trade , \nthere probably isn't one." , "Reminder to display" )  
height      =    input ( 4 , "How far above price to display  ( in rows ) " ) 
frequency   =    input ( 1 , "Only display every x bars" ) 
colorChoice =    input ( "White" , "Color" , options = ["White" , "Red" , "Green" , "Yellow" , "Blue" , "Orange" , "Purple"] ) 
colorShade  =    input ( "Very Light" , "Color lightness" , options = ["Very Light" , "Light" , "Regular" , "Dark" , "Very Dark"] ) 
textSize    =    input ( "Normal" , "Text size" , options = ["Auto" , "Tiny" , "Small" , "Normal" , "Large" , "Huge"] )
pos    =    input ( "Above Bar" , "Vertical position" , options = ["Above Bar" , "At Price" , "Below Bar"] )
hbOffset    =    input ( 0 , "Move how many bars back from last bar?" , minval = 0 ) 

var theTextColor =    
     colorChoice == "White"?#999999:
     colorChoice == "Red"?#FF0000:
     colorChoice == "Green"?#00FF00:
     colorChoice == "Yellow"?#FFFF00:
     colorChoice == "Blue"?#0000FF:
     colorChoice == "Orange"?#FF9900:
     #FF33FF
if ( colorShade == "Very Light" )  
    theTextColor := 
         colorChoice == "White"?#FFFFFF: 
         colorChoice == "Red"?#FF9999:
         colorChoice == "Green"?#99FF99:
         colorChoice == "Yellow"?#FFFF99:
         colorChoice == "Blue"?#9999FF:
         colorChoice == "Orange"?#FFCC99:
         #FFAAFF
else
	if ( colorShade == "Light" ) 
	    theTextColor := 
	         colorChoice == "White"?#CCCCCC:
	         colorChoice == "Red"?#FF3333:
	         colorChoice == "Green"?#33FF33:
	         colorChoice == "Yellow"?#FFFF33:
	         colorChoice == "Blue"?#3333FF:
	         colorChoice == "Orange"?#FFCC33:
	         #FF66FF
	else
		if ( colorShade == "Dark" ) 
		    theTextColor := 
		         colorChoice == "White"?#666666:
		         colorChoice == "Red"?#CC0000:
		         colorChoice == "Green"?#00CC00:
		         colorChoice == "Yellow"?#CCCC00:
		         colorChoice == "Blue"?#0000CC:
		         colorChoice == "Orange"?#CC6600:
		         #CC18CC
		else
		    if ( colorShade == "Very Dark" ) 
			    theTextColor := 
			         colorChoice == "White"?#333333:
			         colorChoice == "Red"?#550000:
			         colorChoice == "Green"?#005500:
			         colorChoice == "Yellow"?#555500:
			         colorChoice == "Blue"?#000055:
			         colorChoice == "Orange"?#553300:
			         #551155

var theTextSize = 
     textSize == "Auto"?size.auto:
     textSize == "Tiny"?size.tiny:
     textSize == "Small"?size.small:
     textSize == "Normal"?size.normal:
     textSize == "Large"?size.large:
     size.huge

var thePosition = 
     pos == "Above Bar" ? yloc.abovebar:
     pos == "Below Bar" ? yloc.belowbar:
     yloc.price

var theCR = ""
theCR := ""
for counter = 1 to height 
    theCR := theCR+"\n"

x = label.new ( bar_index - hbOffset, high , text =  ( bar_index % frequency == 0 ) ? (theCR + theReminder + theCR ) : "" , yloc = thePosition , color = color.new ( color.black , 100 )  , textcolor = theTextColor , size=theTextSize ) 
label.delete ( x[1] )
````

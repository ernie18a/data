<!-- tradingview-pine-id: PUB;81f33fe72c1b4ae692bed7c06dc5f65a -->
<!-- tradingviewscripts-format: 1 -->
# PSv5 Color Magic and Chart Theme Simulator

Source: https://www.tradingview.com/script/f27Ejk2I-PSv5-Color-Magic-and-Chart-Theme-Simulator/

## Description

KEEP YOUR COINS FOLKS! I DON'T NEED THEM, DON'T WANT THEM. Many other talented authors on TV deserve them.

INTRODUCTION:
This is my "PSv5 Color Magic and Chart Theme Simulator" displayed using Pine Script version 5.0. The purpose of this PSv5 colorcator is to show vivid colors that are most suitable in my opinion for modifying or developing Pine scripts. Whether you are new to Pine or an experienced Pine poet, this should aid you in developing indicators with stunning color from the provided color list that is easily copied and pasted into any novel script you should possess. Whichever colors you choose, and how, is up to your imagination's capacity.

COMMENTARY:
I have a thesis. Pine essentially is a gigantor calculator with a lot of programmable bells and whistles to perform intense analytics. Zillions of numbers per day are blended up into another cornucopia of numbers to analyze. The thing is, ALL of those numbers are moot unless we can informatively portray them in various colorized forms with unique methods to point out significant numeric events. By graphically displaying them with specific modes of operation, only then do these numbers truly make any sense to us and become quantitatively beneficial.

I have to admit... I hate numbers. I never really liked them, even before I knew what an ema() was. Some days I almost can't stand them, and on occasion I feel they deserve to be flushed down the toilet at times. However, I'm a stickler for a proper gauge of measurements. Numbers are a mental burden, but they do have "purpose and meaning". That's where COLOR comes in! By applying color in specific ways in varying dynamic forms, we can generate smarter visual aids from these numerics. Numbers can be "transformed" into something colorful it wasn't before, into a tool, like a hammer. But we don't need a hammer, we need an impressive jack hammer for BIG problem solving that we could never achieve in the not to distant past.

As time goes on, we analytically measure more, and more, and more each year. It's necessary to our continual evolution. That's one significant difference between us and cave men, and the pertinent reason why we are quickly evolving as a species, while animals haven't. Humankind is gifted to enumerate very well AND blessed to see in color. We use it for innumerable things in the technological present for purpose and pleasure. Day in and day out, we take color for granted, because it's every where we can look. The fact is, color is the most important apparatus in humankind's existence EVER. We wouldn't have survived this far without it.

By utilizing color to it's grand potential, greater advancements can be attained while simultaneously being enjoyed visually. Once color is transformed from it's numeric origins into applicable tools, we can enjoy the style, elegance, and QUALITATIVE nature of the indication that can be forged. Quantities can't reveal all. Color on the other hand has a handy "quality" factor to it, often revealing things we can't ordinarily recognize. When high quality tools provide us with obtained goals, that's when we will realize how magical color truly is, always has been, and shall always be.

The future emerging economies and future financial vessels of people around the globe are going to be dependent on the secured construction of intelligent applications with a rock solid color foundation, not just math alone. I have no doubt about that. I can envision that with my eyes closed. To make an informed choice, it should be charted or graphed somehow prior to a final executive decision to trade. Going back to abysmal black and white with double decimal points placed next to cartoons within extinction doomed newspapers is not a viable option any more.

OBSERVATIONS AND UTILITY:
One thing you will notice is the code is very dense. Looks almost hideous right? Well, the variable naming is lengthy, but it's purpose is to be self explanatory, even for those who don't know how to program, YET. I'm simply not a notation enthusiast. My main intention was to provide clearly identifiable variables from their origin of assignment to their intended destination of use, clearly visible for anyone visiting. The empowerment of well versed words that are easier to understand, is a close rival to the prominent influence color has.

Secondly, I'm displaying hline() and label.new() as prime candidates to exemplify by demonstration how the "Power of Color" can be embraced with the "Power of Pine". Color in Pine has been extensively upgraded to serve novel purposes to accomplish next generation indicators that do and WILL come to exist. New functions included with PSv5 are color.rgb(), color.from_gradient(), color.r(), color.g(), color.b(), and color.t() to accompany color.new() in our mutual TV adventures. Keep in mind, the extreme agility of color also extends to line.new(), the "entirely new" linefill.new(), table.new(), bgcolor() and every other function that may utilize color.

There's a wide range of adjustability in Settings to make selections to see how they perform on different backgrounds, with their size and form. As you curiously toy with those, you're going to notice how some jump out like laser beams while others don't. Things that aren't visually appealing, still have very viable purposes, even if they don't stand out in the crowd. Often, that's preferable. The important thing is that when pertinent information relative to indication is crucial, you can program it with distinction from an assortment of a potential 1.67 million colors that can be created in Pine. "These" are my chosen favorite few, and I hope you adopt them.

PURPOSES:
For those of you who are new to Pine Script, this also may help you understand color hex/rgb and how it is utilized in Pine in a most effective manner. The most skilled of programmers can garner perks as well. There is countless examples of code diversity present here that are applicable in other scripts with adequate mutation. Any member has the freedom use any of this code in this script any way they see fit. It's specifically intended for all. There is absolutely no need for accreditation for any of this code reuse ever, in the present case. Don't worry about, I'm not.

The color_tostring() will be most valuable in troubleshooting color when using color.rgb() and becoming adept with it. I'm not going to be able to use color.rgb() without it. Chameleon indicators of the polychromatic variety are most likely going to be fine tuned with color_tostring() divulging it's results to label.new() or even table.new() maybe. One the best virtues of this script in chart, is when you hover over the generated labels, there's a hidden gift for those who truly wish to learn the intricate mechanics of diverse color in Pine. Settings has informative tooltips too.

AFTERTHOUGHTS:
Colors are most vibrant on the "Black Chart" which is the default, but it doesn't currently exist as a chart theme. With the extreme luminous intensity of LCDs in millicandela( mcd ), you may notice "Light" charts may saturate the colors making charts challenging to analyze. Because of this, I personally use "Dark Charts" and design my indicators specifically for these. I hope this provides inspiration for the future developers who are contemplating the creation of next generation indicators and how color may enhance their usefulness.

When available time provides itself, I will consider your inquiries, thoughts, and concepts presented below in the comments section, should you have any questions or comments regarding this indicator. When my indicators achieve more prevalent use by TV members , I may implement more ideas when they present themselves as worthy additions. Have a profitable future everyone!

---

## Source Code

````pine
//@version=5
indicator('PSv5 Color Magic and Chart Theme Simulator', 'PSv5 Color Magic', false, format.price, 0, max_labels_count=100)
// Double click the indicator background to maximize the indicator pane

var COLOR_HEX = 'HEX' // fOR color_tostring(ConvertTo=)
var COLOR_RGB = 'RGB'
color_tostring(color Color, string ConvertTo='HEX') => // Converts a Pine color variable into a string in the form of a hex value representation
    if ConvertTo == COLOR_HEX
        var aHexSymbols = array.from('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F')
        intR = color.r(Color),               hXooooooo = int(intR / 16)
        intG = color.g(Color),               hooXooooo = int(intG / 16)
        intB = color.b(Color),               hooooXooo = int(intB / 16)
        intT = color.t(Color) * -2.55 + 255, hooooooXo = int(intT / 16)
        '#' + array.get(aHexSymbols, hXooooooo) + array.get(aHexSymbols, int(intR - 16 * hXooooooo)) +
              array.get(aHexSymbols, hooXooooo) + array.get(aHexSymbols, int(intG - 16 * hooXooooo)) +
              array.get(aHexSymbols, hooooXooo) + array.get(aHexSymbols, int(intB - 16 * hooooXooo)) +
              array.get(aHexSymbols, hooooooXo) + array.get(aHexSymbols, int(intT - 16 * hooooooXo))
    else // 'RGB'
        'rgb(' + str.tostring(color.r(Color)) + ', ' +
                 str.tostring(color.g(Color)) + ', ' +
                 str.tostring(color.b(Color)) + ', ' +
                 str.tostring(color.t(Color)) + ')'

_label(bool DisplayLabel, float yPosition, string ColorName, color LabelColor, string TextColor, string TextSize, string PointerDirection, int LineTransparency) =>
    var TEXTCOLOR = TextColor=='White' ? #FFFFFF : #000000
    var  LINE_COLOR_AS_HEX_STRING = color_tostring(color.new(LabelColor, LineTransparency))
	var LABEL_COLOR_AS_HEX_STRING = color_tostring(LabelColor)
    var TOOLTIP = 'Line Colors:\n                  '  + LINE_COLOR_AS_HEX_STRING + '\n' +
                  '   color.new('    +    str.substring(LINE_COLOR_AS_HEX_STRING, 0, 7) + ', ' + str.tostring(LineTransparency) + ')\n' +
                  '    color.'       +   color_tostring(color.new(LabelColor, LineTransparency), COLOR_RGB) + '\n\n' +
                  'Label Colors:\n                  ' + LABEL_COLOR_AS_HEX_STRING + '\n' +
                  '   color.new('    +    str.substring(LABEL_COLOR_AS_HEX_STRING, 0, 7) + ', ' + str.tostring(color.t(LabelColor)) + ')\n' +
                  '    color.'       +   color_tostring(LabelColor, COLOR_RGB)
    if barstate.islast and DisplayLabel
        var _label = label.new(bar_index, yPosition, ColorName, color=LabelColor, textcolor=TEXTCOLOR, size=TextSize, style=PointerDirection, tooltip=TOOLTIP)
        label.set_x(_label, bar_index)

GROUP1 = '=============== hline() Tweaks ==============='
GROUP2 = '============= Label Manipulation ============='
nptSelectBackground  = input.string('Black Chart',  'Chart Theme Simulator',               options=['Black Chart','Dark Chart*','Light Chart*'], tooltip='This will aid with distinguishing between colors\nthat are beneficial or have pitfalls on different\nbackground colors. I strongly encourage the\nuse of dark/black charts for numerous reasons\nthat are indentifiable...\n\nCONSIDERATIONS:\n- Use of "light charts" can saturate ALL colors\nhaving plots/lines with thin widths. This reduces\nvisibility, depending on the members visual acuity.\n- Nearly all colors work flawlessly on darker charts')
nptLineStyle         = input.string(      'Solid',           ' Hline Style', group=GROUP1, options=['Solid','Dashed','Dotted'])
nptHlineWidth        = input.int   (            2,           ' HLine Width', group=GROUP1, options=[1,2,3,4,5,6,7,8,9,10],             tooltip='It is suggestible to use a 2px line width\nwhen developing indicators. 1px lines\nhave their uses in some cases, but can\nresult in diminished visibility')
nptHlineTransparency = input.int   (            0,     ' Line Transparency', group=GROUP1,  minval=0, maxval=100, step=5,              tooltip='You may manually type in any number between\n0 and 100. Indicators built for the overlay pane\nwill benefit from a transparency control where\nnumerous lines/plots can exist in abundance')
nptLabelTextColor    = input.string(      'White',      ' Label Text Color', group=GROUP2, options=['White','Black'],                  tooltip='Use of Pine labels with black text in many cases\ncauses reduced legibility due to dithering.\n#FFFFFFff has the highest utility in most cases')
nptLabelTextSize     = input.string(  size.normal,       ' Label Text Size', group=GROUP2, options=[size.normal,size.small,size.tiny], tooltip='size.tiny is challenging to read...')
nptLabelTransparency = input.int   (           60,    ' Label Transparency', group=GROUP2,  minval=0, maxval=100, step=5,              tooltip="You may manually type in any number between\n0 and 100. If you hover over any label, you can\nview it's color hex and rgbt values as such:\n    HEX:                 #XXXXXXxx\n             color.new(#XXXXXX, N)\n    RGBT: color.rgb(N, N, N, N)")
nptShowMoreColors    = input.string(       'None', 'Show Additional Colors',               options=['None', '-','All','Alternatives','Pine Built-Ins'], tooltip='Once the indicator pane is maximized,\nby selecting "All" provides you with the grand\nperspective of numeorous colors applicable\nin Pine with this presentation')
var SHOW_ALTERNATIVES   = nptShowMoreColors=='All' or nptShowMoreColors=='Alternatives'
var SHOW_PINE_BUILT_INS = nptShowMoreColors=='All' or nptShowMoreColors=='Pine Built-Ins'
var HLINE_STYLE = nptLineStyle=='Solid'  ? hline.style_solid  :
				  nptLineStyle=='Dotted' ? hline.style_dotted : hline.style_dashed
var BACKGROUND = nptSelectBackground=='Dark Chart*'  ? #191326ff :
                 nptSelectBackground=='Light Chart*' ? #FFFFFFff :
                                                       #000000ff // <- Black Chart Selection
bgcolor(BACKGROUND, editable=false)


//###################################################################################################
//########################## RECOMMENDED EASY COPY/PASTE COLOR LIST BELOW ###########################
//###################################################################################################

//===== Alternative colors to use
var brown      = #442211
var wood       = #774433
var tan        = #AA8855
var gold       = #C0C000
var olive      = #808000
var green      = #008000
var teal       = #008080
var navy       = #000088 // Not recommended for use on 'Dark Charts'
var maroon     = #800000
var coral      = #FF8080
var lavender   = #8080FF
var indigo     = #440088 // Not recommended for use on 'Dark Charts'

//===== My recommended colors, except where noted
var darkpurple = #660066, var dpurple = darkpurple // Alias for dark purple,  Not recommended for use on 'Dark Charts'
var purple     = #990099
var fuchsia    = #FF00FF
var violet     = #AA00FF
var hanpurple  = #5500FF
var blue       = #0000FF
var cichlid    = #0044FF
var azure      = #0080FF
var skyblue    = #00BBFF
var aqua       = #00FFFF // Not recommended for use on 'Light Charts' with 1px line thickness
var mint       = #00FF80
var lime       = #00FF00
var chartreuse = #80FF00
var yellow     = #FFFF00 // Not recommended for use on 'Light Charts'
var amber      = #FFC000
var orange     = #FF8000
var redorange  = #FF4400
var red        = #FF0000
var hotpink    = #FF0099
//  fuchsia    = #FF00FF // Defined above but used twice for consistent rainbow spectrum
var pink       = #FF99FF

//===== White to black gradient
var white      = #FFFFFF // Not recommended for use on 'Light Charts' WITHOUT COLORING TECHNIQUE BELOW
var silver     = #C0C0C0 // Not recommended for use on 'Light Charts' with 1px line thickness
var gray       = #808080
var darkgray   = #404040, var dgray = darkgray // Alias for dark gray
var nero       = #202020 // Not recommended for use on 'Dark Charts'
var eclipse    = #101010 // Not recommended for use on 'Dark Charts'
var black      = #000000 // Not recommended for use on 'Dark Charts' WITHOUT COLORING TECHNIQUE BELOW

//###################################################################################################
//########################## END OF RECOMMENDED EASY COPY/PASTE COLOR LIST ##########################
//###################################################################################################


//  My Recommended Colors Plotted ####################################################################################################
hline(SHOW_ALTERNATIVES ? 40 : na,    'Brown', color.new(   brown, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(SHOW_ALTERNATIVES ? 39 : na,     'Wood', color.new(    wood, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(SHOW_ALTERNATIVES ? 38 : na,      'Tan', color.new(     tan, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(SHOW_ALTERNATIVES ? 37 : na,     'Gold', color.new(    gold, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(SHOW_ALTERNATIVES ? 36 : na,    'Olive', color.new(   olive, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(SHOW_ALTERNATIVES ? 35 : na,    'Green', color.new(   green, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(SHOW_ALTERNATIVES ? 34 : na,     'Teal', color.new(    teal, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(SHOW_ALTERNATIVES ? 33 : na,     'Navy', color.new(    navy, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(SHOW_ALTERNATIVES ? 32 : na,   'Maroon', color.new(  maroon, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(SHOW_ALTERNATIVES ? 31 : na,    'Coral', color.new(   coral, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(SHOW_ALTERNATIVES ? 30 : na, 'Lavender', color.new(lavender, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(SHOW_ALTERNATIVES ? 29 : na,   'Indigo', color.new(  indigo, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)

plot( SHOW_ALTERNATIVES ? 28 : na,         '',               gray, trackprice=true, show_last=1, editable=false) // Separator

hline(27, 'Dark Purple', color.new(   dpurple, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(26,      'Purple', color.new(    purple, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(25,     'Fuchsia', color.new(   fuchsia, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(24,      'Violet', color.new(    violet, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(23,  'Han Purple', color.new( hanpurple, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(22,        'Blue', color.new(      blue, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(21,     'Cichlid', color.new(   cichlid, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(20,       'Azure', color.new(     azure, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(19,    'Sky Blue', color.new(   skyblue, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(18,        'Aqua', color.new(      aqua, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(17,        'Mint', color.new(      mint, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(16,        'Lime', color.new(      lime, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(15,  'Chartreuse', color.new(chartreuse, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(14,      'Yellow', color.new(    yellow, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(13,       'Amber', color.new(     amber, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(12,      'Orange', color.new(    orange, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(11,  'Red/Orange', color.new( redorange, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(10,         'Red', color.new(       red, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline( 9,    'Hot Pink', color.new(   hotpink, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline( 8,     'Fuchsia', color.new(   fuchsia, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline( 7,        'Pink', color.new(      pink, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)

//=================== Technique on below two lines for plotting white on white =====================//
hline( 6, 'White Highlighter', color.new( silver, nptHlineTransparency), HLINE_STYLE, nptHlineWidth+2) // Highlighter for white on white background
hline( 6,             'White', color.new(  white, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)

hline( 5,            'Silver', color.new( silver, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline( 4,              'Gray', color.new(   gray, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline( 3,         'Dark Gray', color.new(  dgray, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline( 2,              'Nero', color.new(   nero, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline( 1,           'Eclipse', color.new(eclipse, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)

//==================== Technique on below two lines for plotting black on black ====================//
hline( 0, 'Black Highlighter', color.new(  dgray, nptHlineTransparency), HLINE_STYLE, nptHlineWidth+2) // Highlighter for black on black background
hline( 0,             'Black', color.new(  black, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)

plot(SHOW_PINE_BUILT_INS ? -1  : na, '',    gray, trackprice=true, show_last=1, editable=false) // Separator

// Pine built-in colors #############################################################################################################
hline(SHOW_PINE_BUILT_INS ? -2  : na, '', color.new(color.aqua   , nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(SHOW_PINE_BUILT_INS ? -3  : na, '', color.new(color.black  , nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(SHOW_PINE_BUILT_INS ? -4  : na, '', color.new(color.blue   , nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(SHOW_PINE_BUILT_INS ? -5  : na, '', color.new(color.fuchsia, nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(SHOW_PINE_BUILT_INS ? -6  : na, '', color.new(color.gray   , nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(SHOW_PINE_BUILT_INS ? -7  : na, '', color.new(color.green  , nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(SHOW_PINE_BUILT_INS ? -8  : na, '', color.new(color.lime   , nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(SHOW_PINE_BUILT_INS ? -9  : na, '', color.new(color.maroon , nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(SHOW_PINE_BUILT_INS ? -10 : na, '', color.new(color.navy   , nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(SHOW_PINE_BUILT_INS ? -11 : na, '', color.new(color.olive  , nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(SHOW_PINE_BUILT_INS ? -12 : na, '', color.new(color.orange , nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(SHOW_PINE_BUILT_INS ? -13 : na, '', color.new(color.purple , nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(SHOW_PINE_BUILT_INS ? -14 : na, '', color.new(color.red    , nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(SHOW_PINE_BUILT_INS ? -15 : na, '', color.new(color.silver , nptHlineTransparency), HLINE_STYLE, nptHlineWidth) // Not recommended for use on 'Light Charts' with 1px line thickness
hline(SHOW_PINE_BUILT_INS ? -16 : na, '', color.new(color.teal   , nptHlineTransparency), HLINE_STYLE, nptHlineWidth)
hline(SHOW_PINE_BUILT_INS ? -17 : na, '', color.new(color.white  , nptHlineTransparency), HLINE_STYLE, nptHlineWidth) // PROBLEMATIC on 'Light Charts'
hline(SHOW_PINE_BUILT_INS ? -18 : na, '', color.new(color.yellow , nptHlineTransparency), HLINE_STYLE, nptHlineWidth)

// Labels ###########################################################################################################################
//===== For alternative colors
_label(SHOW_ALTERNATIVES, 40,    'Brown', color.new(    brown, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_right, nptHlineTransparency)
_label(SHOW_ALTERNATIVES, 39,     'Wood', color.new(     wood, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_left , nptHlineTransparency)
_label(SHOW_ALTERNATIVES, 38,      'Tan', color.new(      tan, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_right, nptHlineTransparency)
_label(SHOW_ALTERNATIVES, 37,     'Gold', color.new(     gold, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_left , nptHlineTransparency)
_label(SHOW_ALTERNATIVES, 36,    'Olive', color.new(    olive, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_right, nptHlineTransparency)
_label(SHOW_ALTERNATIVES, 35,    'Green', color.new(    green, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_left , nptHlineTransparency)
_label(SHOW_ALTERNATIVES, 34,     'Teal', color.new(     teal, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_right, nptHlineTransparency)
_label(SHOW_ALTERNATIVES, 33,     'Navy', color.new(     navy, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_left , nptHlineTransparency)
_label(SHOW_ALTERNATIVES, 32,   'Maroon', color.new(   maroon, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_right, nptHlineTransparency)
_label(SHOW_ALTERNATIVES, 31,    'Coral', color.new(    coral, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_left , nptHlineTransparency)
_label(SHOW_ALTERNATIVES, 30, 'Lavender', color.new( lavender, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_right, nptHlineTransparency)
_label(SHOW_ALTERNATIVES, 29,   'Indigo', color.new(   indigo, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_left , nptHlineTransparency)

//===== For my recommended colors
_label(true, 27,  'Dark Purple', color.new(   dpurple, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_right, nptHlineTransparency)
_label(true, 26,       'Purple', color.new(    purple, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_left , nptHlineTransparency)
_label(true, 25,      'Fuchsia', color.new(   fuchsia, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_right, nptHlineTransparency)
_label(true, 24,       'Violet', color.new(    violet, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_left , nptHlineTransparency)
_label(true, 23,   'Han Purple', color.new( hanpurple, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_right, nptHlineTransparency)
_label(true, 22,         'Blue', color.new(      blue, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_left , nptHlineTransparency)
_label(true, 21,      'Cichlid', color.new(   cichlid, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_right, nptHlineTransparency)
_label(true, 20,        'Azure', color.new(     azure, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_left , nptHlineTransparency)
_label(true, 19,     'Sky Blue', color.new(   skyblue, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_right, nptHlineTransparency)
_label(true, 18,     'Aqua ️⚠️', color.new(      aqua, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_left , nptHlineTransparency)
_label(true, 17,         'Mint', color.new(      mint, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_right, nptHlineTransparency)
_label(true, 16,         'Lime', color.new(      lime, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_left , nptHlineTransparency)
_label(true, 15,   'Chartreuse', color.new(chartreuse, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_right, nptHlineTransparency)
_label(true, 14,   'Yellow ️⚠️', color.new(    yellow, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_left , nptHlineTransparency)
_label(true, 13,        'Amber', color.new(     amber, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_right, nptHlineTransparency)
_label(true, 12,       'Orange', color.new(    orange, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_left , nptHlineTransparency)
_label(true, 11,   'Red/Orange', color.new( redorange, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_right, nptHlineTransparency)
_label(true, 10,          'Red', color.new(       red, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_left , nptHlineTransparency)
_label(true,  9,     'Hot Pink', color.new(   hotpink, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_right, nptHlineTransparency)
_label(true,  8,      'Fuchsia', color.new(   fuchsia, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_left , nptHlineTransparency)
_label(true,  7,         'Pink', color.new(      pink, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_right, nptHlineTransparency)
_label(true,  6,    'White ️⚠️', color.new(     white, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_left , nptHlineTransparency)
_label(true,  5,   '️⚠️ Silver️', color.new(    silver, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_right, nptHlineTransparency)
_label(true,  4,         'Gray', color.new(      gray, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_left , nptHlineTransparency)
_label(true,  3,    'Dark Gray', color.new(     dgray, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_right, nptHlineTransparency)
_label(true,  2,   '<- Nero'   , color.new(      nero, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_left , nptHlineTransparency)
_label(true,  1,   '<- Eclipse', color.new(   eclipse, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_right, nptHlineTransparency)
_label(true,  0, '<- Black ️⚠️', color.new(      black, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_left , nptHlineTransparency)

//===== For Pine built-in colors
_label(SHOW_PINE_BUILT_INS, -2 ,          'color.aqua', color.new(color.aqua   , nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_right, nptHlineTransparency)
_label(SHOW_PINE_BUILT_INS, -3 ,      '<- color.black', color.new(color.black  , nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_left , nptHlineTransparency)
_label(SHOW_PINE_BUILT_INS, -4 ,          'color.blue', color.new(color.blue   , nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_right, nptHlineTransparency)
_label(SHOW_PINE_BUILT_INS, -5 ,       'color.fuchsia', color.new(color.fuchsia, nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_left , nptHlineTransparency)
_label(SHOW_PINE_BUILT_INS, -6 ,          'color.gray', color.new(color.gray   , nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_right, nptHlineTransparency)
_label(SHOW_PINE_BUILT_INS, -7 ,         'color.green', color.new(color.green  , nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_left , nptHlineTransparency)
_label(SHOW_PINE_BUILT_INS, -8 ,          'color.lime', color.new(color.lime   , nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_right, nptHlineTransparency)
_label(SHOW_PINE_BUILT_INS, -9 ,        'color.maroon', color.new(color.maroon , nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_left , nptHlineTransparency)
_label(SHOW_PINE_BUILT_INS, -10,          'color.navy', color.new(color.navy   , nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_right, nptHlineTransparency)
_label(SHOW_PINE_BUILT_INS, -11,         'color.olive', color.new(color.olive  , nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_left , nptHlineTransparency)
_label(SHOW_PINE_BUILT_INS, -12,        'color.orange', color.new(color.orange , nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_right, nptHlineTransparency)
_label(SHOW_PINE_BUILT_INS, -13,        'color.purple', color.new(color.purple , nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_left , nptHlineTransparency)
_label(SHOW_PINE_BUILT_INS, -14,           'color.red', color.new(color.red    , nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_right, nptHlineTransparency)
_label(SHOW_PINE_BUILT_INS, -15, '<- color.silver ️⚠️️', color.new(color.silver , nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_left , nptHlineTransparency)
_label(SHOW_PINE_BUILT_INS, -16,          'color.teal', color.new(color.teal   , nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_right, nptHlineTransparency)
_label(SHOW_PINE_BUILT_INS, -17, '<- color.white ️⚠️⚠', color.new(color.white  , nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_left , nptHlineTransparency)
_label(SHOW_PINE_BUILT_INS, -18,        'color.yellow', color.new(color.yellow , nptLabelTransparency), nptLabelTextColor, nptLabelTextSize, label.style_label_right, nptHlineTransparency)
````

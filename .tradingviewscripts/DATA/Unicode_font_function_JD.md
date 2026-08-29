<!-- tradingview-pine-id: PUB;t7UcB9ICdnVSwqhiDNI4YrDdVJqppP3k -->
<!-- tradingviewscripts-format: 1 -->
# Unicode font function - JD

Source: https://www.tradingview.com/script/Bi1gJhKa-Unicode-font-function-JD/

## Description

Pinescript only allows the use of one type of font in texts and label, which causes some inconveniences:

- It's hard to make a label or text "look nice" and clear because it's not possible to use a different font for titles, etc.

- Because the default Pinescript font is not a monospaced font, (in Pinescript different characters have different widths)
  this makes it really difficult to align things in a label on different rows
  and causes everything to be "all over the place" and look messy

With the workaround in this script, you can "translate" the text string that you want to put in a label into a text with either upper case, bold and/or italic characters,
allowing for more control over the layout of the label text, by adding differently styled titles, control over spacing for columns, etc...

The characters provided in this script are an example of a monospaced font, but can easily be replaced by copy-pasting in other characters in the appropriate section
and the script will then use the new characters as replacements.

This script is to show the possibilities and principles of the functions.
The principles of this framework can be used to build your own go-to "text style conversion" functions, for styles that you use a lot, for example for titles.

A big shoutout to @DonovanWall, for the awesome character replacement idea that I built upon!!!
A shoutout also to the PineCoders community, who provide an infinite source of knowlegde and inspiration!!

Enjoy!

Gr, JD.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Duyck
//{
// DESCRIPTION
// 
// Pinescript only allows the use of one type of font in texts and label, which causes some inconveniences:

// - It's hard to make a label or text "look nice" and clear because it's not possible to use a different font for titles, etc.

// - Because the default Pinescript font is not a monospaced font, (in Pinescript different characters have different widths)
//   this makes it really difficult to align things in a label on different rows
//   and causes everything to be "all over the place" and look messy


// With the workaround in this script, you can "translate" the text string that you want to put in a label into a text with either upper case, bold and/or italic characters,
// allowing for more control over the layout of the label text, by adding differently styled titles, control over spacing for columns, etc...

// The characters provided in this script are an example of a monospaced font, but can easily be replaced by copy-pasting in other characters in the appropriate section
// and the script will then use the new characters as replacements.


// This script is to show the possibilities and principles of the functions.
// The principles of this framework can be used to build your own go-to "text style conversion" functions, for styles that you use a lot, for example for titles.


// A big shoutout to @DonovanWall, for the awesome character replacement idea that I built upon!!!
// A shoutout also to the PineCoders community, who provide an infinite source of knowlegde and inspiration!!


// Enjoy!

// Gr, JD.
//}
//@version=4
study("Unicode font function - JD")
//////////////////////////////////////////////////////////////////////////////////////////////////////
//// Inputs ////
//{
inp_str = input("input string here", title = "")
case    = input("lower case", title = "Char type", options = ["lower case", "UPPER CASE"], inline = "Type")
bold    = input(  false, title = "Bold",                                              inline = "Type")
italic  = input(  false, title = "Italic",                                            inline = "Type")
//}
//////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////
///// Monospace fonts ////
//{                                                                                                  //
// Font source : https://fonts.adobe.com/fonts/courier?mv=affiliate&mv2=red#recommendations-section //
//                                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////////////////////
///
//// STANDARD PINESCRIPT FONT ////
Pine_std_LC = "a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z"
Pine_std_UC = "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z"
Pine_std_DG = "0,1,2,3,4,5,6,7,8,9"
//
////  CUSTOM MONOSPACE FONT  ////
// (a different font can be copy-pasted here, from the listed website or another source)
//
// Sans-serif Std
std_LC      = "𝚊,𝚋,𝚌,𝚍,𝚎,𝚏,𝚐,𝚑,𝚒,𝚓,𝚔,𝚕,𝚖,𝚗,𝚘,𝚙,𝚚,𝚛,𝚜,𝚝,𝚞,𝚟,𝚠,𝚡,𝚢,𝚣"
std_UC      = "𝙰,𝙱,𝙲,𝙳,𝙴,𝙵,𝙶,𝙷,𝙸,𝙹,𝙺,𝙻,𝙼,𝙽,𝙾,𝙿,𝚀,𝚁,𝚂,𝚃,𝚄,𝚅,𝚆,𝚇,𝚈,𝚉"
std_DG      = "𝟶,𝟷,𝟸,𝟹,𝟺,𝟻,𝟼,𝟽,𝟾,𝟿"
//
// Sans-serif Std Italic
std_it_LC   = "𝘢,𝘣,𝘤,𝘥,𝘦,𝘧,𝘨,𝘩,𝘪,𝘫,𝘬,𝘭,𝘮,𝘯,𝘰,𝘱,𝘲,𝘳,𝘴,𝘵,𝘶,𝘷,𝘸,𝘹,𝘺,𝘻"
std_it_UC   = "𝘈,𝘉,𝘊,𝘋,𝘌,𝘍,𝘎,𝘏,𝘐,𝘑,𝘒,𝘓,𝘔,𝘕,𝘖,𝘗,𝘘,𝘙,𝘚,𝘛,𝘜,𝘝,𝘞,𝘟,𝘠,𝘡"
std_it_DG   = "𝟢,𝟣,𝟤,𝟥,𝟦,𝟧,𝟨,𝟩,𝟪,𝟫"
//
// Sans-serif Bold
bld_LC      = "𝗮,𝗯,𝗰,𝗱,𝗲,𝗳,𝗴,𝗵,𝗶,𝗷,𝗸,𝗹,𝗺,𝗻,𝗼,𝗽,𝗾,𝗿,𝘀,𝘁,𝘂,𝘃,𝘄,𝘅,𝘆,𝘇"
bld_UC      = "𝗔,𝗕,𝗖,𝗗,𝗘,𝗙,𝗚,𝗛,𝗜,𝗝,𝗞,𝗟,𝗠,𝗡,𝗢,𝗣,𝗤,𝗥,𝗦,𝗧,𝗨,𝗩,𝗪,𝗫,𝗬,𝗭"
bld_DG      = "𝟬,𝟭,𝟮,𝟯,𝟰,𝟱,𝟲,𝟳,𝟴,𝟵"
//
// Sans-serif Bold Italic
bld_it_LC   = "𝙖,𝙗,𝙘,𝙙,𝙚,𝙛,𝙜,𝙝,𝙞,𝙟,𝙠,𝙡,𝙢,𝙣,𝙤,𝙥,𝙦,𝙧,𝙨,𝙩,𝙪,𝙫,𝙬,𝙭,𝙮,𝙯"
bld_it_UC   = "𝘼,𝘽,𝘾,𝘿,𝙀,𝙁,𝙂,𝙃,𝙄,𝙅,𝙆,𝙇,𝙈,𝙉,𝙊,𝙋,𝙌,𝙍,𝙎,𝙏,𝙐,𝙑,𝙒,𝙓,𝙔,𝙕"
bld_it_DG   = "𝟬,𝟭,𝟮,𝟯,𝟰,𝟱,𝟲,𝟳,𝟴,𝟵"
//}
//////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////
//// Font arrays ////
//{
// Pine fonts
Pine_font_std_LC    = str.split(Pine_std_LC, ",")
Pine_font_std_UC    = str.split(Pine_std_UC, ",")
Pine_font_std_DG    = str.split(Pine_std_DG, ",")

// Custom fonts
// Standard
Cust_font_std_LC    = str.split(std_LC,    ",")
Cust_font_std_UC    = str.split(std_UC,    ",")
Cust_font_std_DG    = str.split(std_DG,    ",")
// Standard italic
Cust_font_std_it_LC = str.split(std_it_LC, ",")
Cust_font_std_it_UC = str.split(std_it_UC, ",")
Cust_font_std_it_DG = str.split(std_it_DG, ",")
// Bold
Cust_font_bld_LC    = str.split(bld_LC,    ",")
Cust_font_bld_UC    = str.split(bld_UC,    ",")
Cust_font_bld_DG    = str.split(bld_DG,    ",")
// Bold italic
Cust_font_bld_it_LC = str.split(bld_it_LC, ",")
Cust_font_bld_it_UC = str.split(bld_it_UC, ",")
Cust_font_bld_it_DG = str.split(bld_it_DG, ",")
//}
//////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////
//// UNICODE REPLACEMENT FUNCTIONS ////
//{
// Unicode Character Replace Function
uni_replace_CHAR(_str, _upper, _bold, _italic) =>
    _custom_font_LC =
     _bold ? _italic ? Cust_font_bld_it_LC : Cust_font_bld_LC :
             _italic ? Cust_font_std_it_LC : Cust_font_std_LC
    _custom_font_UC =
     _bold ? _italic ? Cust_font_bld_it_UC : Cust_font_bld_UC :
             _italic ? Cust_font_std_it_UC : Cust_font_std_UC
    _new_str  = _str
    for _i = 0 to array.size(Pine_font_std_LC) - 1
        _new_str := str.replace_all(_new_str, array.get(Pine_font_std_LC, _i),
                                              array.get(_upper ? _custom_font_UC : _custom_font_LC, _i))
                                              
        _new_str := str.replace_all(_new_str, array.get(Pine_font_std_UC, _i),
                                              array.get(_custom_font_UC, _i))
    _new_str

// Unicode Digit Replace Function
uni_replace_DG(_str, _bold, _italic) =>
    _custom_font =
     _bold ? _italic ? Cust_font_bld_it_DG : Cust_font_bld_DG :
             _italic ? Cust_font_std_it_DG : Cust_font_std_DG
    _new_str  = _str
    for _i = 0 to array.size(Pine_font_std_DG) - 1
        _new_str := str.replace_all(_new_str, array.get(Pine_font_std_DG, _i), array.get(_custom_font, _i))
    _new_str

// Unicode Global Replace Function
uni_replace(_str, _upper, _bold, _italic) =>
    _str2 = uni_replace_DG(   _str,         _bold, _italic)
    _str3 = uni_replace_CHAR(_str2, _upper, _bold, _italic)
    _str3
//}
//////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////
//// TEST SECTION ////
//{
test_string = inp_str
uni_test_string = uni_replace(test_string, (case == "lower case" ? false : true), bold, italic)
//}
//////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////
//// PLOTS ////
//{
if barstate.islast
    label.new(bar_index, close+5, text = test_string + "\n" + uni_test_string)
    //}
//////////////////////////////////////////////////////////////////////////////////////////////////////
````

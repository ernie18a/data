<!-- tradingview-pine-id: PUB;Ng41LADhSsOW2m9WC6MAk9Fg3jxWK5l7 -->
<!-- tradingviewscripts-format: 1 -->
# Unicode Font Function V2 - JD

Source: https://www.tradingview.com/script/hd0vZu6Y-Unicode-Font-Function-V2-JD/

## Description

This script is a continuation from Duyck's Unicode font function
A different approach made on this function to able change font type on a single string
Now you can call it as a function to change the font type on every string that you need,
either it is for a Label or regular Text

Shoutout to @Duyck for his amazing works on this function.
Thank you to PineScript Community as well

Let me know if you guys have any suggestion or idea.

Greets,
dddfault

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Duyck
//{
// DESCRIPTION
// 
// This script is a continuation from Duyck's Unicode font function
// A different approach made on this function to able change font type on a single string
// Now you can call it as a function to change the font type on every string that you need,
// either it is for a Label or regular Text
//
//
// Shoutout to @Duyck for his amazing works on this function.
//  
// Let me know if you guys have suggestion or idea.
//
//
// Greets,
// dddfault
//
//}

//@version=4
study("Unicode Font Function V2 - JD")

//////////////////////////////////////////////////////////////////////////////////////////////////////
//// Inputs ////
//{
inp_str = input("This function brought to you by", title = "Input 1", inline = "type1")
inp_str2 = input("Please input your custom text, then try to change the font type also.", title = "Input 2", inline = "type2")
fontType1 = input("Sans Bold Italic", title = "Font Type", options = ["Pine Default", "Sans", "Sans Italic", "Sans Bold", "Sans Bold Italic", "Sans-Serif", "Sans-Serif Italic", "Sans-Serif Bold", "Sans-Serif Bold Italic", "Fraktur", "Fraktur Bold", "Script", "Script Bold", "Double-Struck", "Monospace", "Regional Indicator", "Full Width", "Circled"], inline = "type1")
fontType2 = input("Regional Indicator", title = "Font Type", options = ["Pine Default", "Sans", "Sans Italic", "Sans Bold", "Sans Bold Italic", "Sans-Serif", "Sans-Serif Italic", "Sans-Serif Bold", "Sans-Serif Bold Italic", "Fraktur", "Fraktur Bold", "Script", "Script Bold", "Double-Struck", "Monospace", "Regional Indicator", "Full Width", "Circled"], inline = "type2")

//}
//////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////
//// FONTS ARRAY AND SELECTIONS ////
//{
//
//                                                                                                 
//// STANDARD PINESCRIPT FONT ////
Pine_std_LC = "a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z"
Pine_std_UC = "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z"
Pine_std_DG = "0,1,2,3,4,5,6,7,8,9"
// Pine fonts
Pine_font_std_LC    = str.split(Pine_std_LC, ",")
Pine_font_std_UC    = str.split(Pine_std_UC, ",")
Pine_font_std_DG    = str.split(Pine_std_DG, ",")
//////////////////////////////////////////////////////////////////////////////////////////////////////
///
////  CUSTOM MONOSPACE FONT  ////
// (a different font can be copy-pasted here, from the listed website or another source)

fontType(font_select) =>
	var string cust_select_LC = " "
	var string cust_select_UC = " "
	var string cust_select_DG = " "
	if font_select == "Sans"
		cust_select_LC := "𝖺,𝖻,𝖼,𝖽,𝖾,𝖿,𝗀,𝗁,𝗂,𝗃,𝗄,𝗅,𝗆,𝗇,𝗈,𝗉,𝗊,𝗋,𝗌,𝗍,𝗎,𝗏,𝗐,𝗑,𝗒,𝗓"
		cust_select_UC := "𝖠,𝖡,𝖢,𝖣,𝖤,𝖥,𝖦,𝖧,𝖨,𝖩,𝖪,𝖫,𝖬,𝖭,𝖮,𝖯,𝖰,𝖱,𝖲,𝖳,𝖴,𝖵,𝖶,𝖷,𝖸,𝖹"
		cust_select_DG := "𝟢,𝟣,𝟤,𝟥,𝟦,𝟧,𝟨,𝟩,𝟪,𝟫"
	else if font_select == "Sans Italic"
		cust_select_LC := "𝘢,𝘣,𝘤,𝘥,𝘦,𝘧,𝘨,𝘩,𝘪,𝘫,𝘬,𝘭,𝘮,𝘯,𝘰,𝘱,𝘲,𝘳,𝘴,𝘵,𝘶,𝘷,𝘸,𝘹,𝘺,𝘻"
		cust_select_UC := "𝘈,𝘉,𝘊,𝘋,𝘌,𝘍,𝘎,𝘏,𝘐,𝘑,𝘒,𝘓,𝘔,𝘕,𝘖,𝘗,𝘘,𝘙,𝘚,𝘛,𝘜,𝘝,𝘞,𝘟,𝘠,𝘡"
		cust_select_DG := "𝟢,𝟣,𝟤,𝟥,𝟦,𝟧,𝟨,𝟩,𝟪,𝟫"
	else if font_select == "Sans Bold"
		cust_select_LC := "𝗮,𝗯,𝗰,𝗱,𝗲,𝗳,𝗴,𝗵,𝗶,𝗷,𝗸,𝗹,𝗺,𝗻,𝗼,𝗽,𝗾,𝗿,𝘀,𝘁,𝘂,𝘃,𝘄,𝘅,𝘆,𝘇"
		cust_select_UC := "𝗔,𝗕,𝗖,𝗗,𝗘,𝗙,𝗚,𝗛,𝗜,𝗝,𝗞,𝗟,𝗠,𝗡,𝗢,𝗣,𝗤,𝗥,𝗦,𝗧,𝗨,𝗩,𝗪,𝗫,𝗬,𝗭"
		cust_select_DG := "𝟬,𝟭,𝟮,𝟯,𝟰,𝟱,𝟲,𝟳,𝟴,𝟵"
	else if font_select == "Sans Bold Italic"
		cust_select_LC := "𝙖,𝙗,𝙘,𝙙,𝙚,𝙛,𝙜,𝙝,𝙞,𝙟,𝙠,𝙡,𝙢,𝙣,𝙤,𝙥,𝙦,𝙧,𝙨,𝙩,𝙪,𝙫,𝙬,𝙭,𝙮,𝙯"
		cust_select_UC := "𝘼,𝘽,𝘾,𝘿,𝙀,𝙁,𝙂,𝙃,𝙄,𝙅,𝙆,𝙇,𝙈,𝙉,𝙊,𝙋,𝙌,𝙍,𝙎,𝙏,𝙐,𝙑,𝙒,𝙓,𝙔,𝙕"
		cust_select_DG := "𝟬,𝟭,𝟮,𝟯,𝟰,𝟱,𝟲,𝟳,𝟴,𝟵"
	else if font_select == "Sans-Serif"
		cust_select_LC := "𝚊,𝚋,𝚌,𝚍,𝚎,𝚏,𝚐,𝚑,𝚒,𝚓,𝚔,𝚕,𝚖,𝚗,𝚘,𝚙,𝚚,𝚛,𝚜,𝚝,𝚞,𝚟,𝚠,𝚡,𝚢,𝚣"
		cust_select_UC := "𝙰,𝙱,𝙲,𝙳,𝙴,𝙵,𝙶,𝙷,𝙸,𝙹,𝙺,𝙻,𝙼,𝙽,𝙾,𝙿,𝚀,𝚁,𝚂,𝚃,𝚄,𝚅,𝚆,𝚇,𝚈,𝚉"
		cust_select_DG := "𝟶,𝟷,𝟸,𝟹,𝟺,𝟻,𝟼,𝟽,𝟾,𝟿"
	else if font_select == "Sans-Serif Italic"
		cust_select_LC := "𝘢,𝘣,𝘤,𝘥,𝘦,𝘧,𝘨,𝘩,𝘪,𝘫,𝘬,𝘭,𝘮,𝘯,𝘰,𝘱,𝘲,𝘳,𝘴,𝘵,𝘶,𝘷,𝘸,𝘹,𝘺,𝘻"
		cust_select_UC := "𝘈,𝘉,𝘊,𝘋,𝘌,𝘍,𝘎,𝘏,𝘐,𝘑,𝘒,𝘓,𝘔,𝘕,𝘖,𝘗,𝘘,𝘙,𝘚,𝘛,𝘜,𝘝,𝘞,𝘟,𝘠,𝘡"
		cust_select_DG := "𝟶,𝟷,𝟸,𝟹,𝟺,𝟻,𝟼,𝟽,𝟾,𝟿"
	else if font_select == "Sans-Serif Bold"
		cust_select_LC := "𝐚,𝐛,𝐜,𝐝,𝐞,𝐟,𝐠,𝐡,𝐢,𝐣,𝐤,𝐥,𝐦,𝐧,𝐨,𝐩,𝐪,𝐫,𝐬,𝐭,𝐮,𝐯,𝐰,𝐱,𝐲,𝐳"
		cust_select_UC := "𝐀,𝐁,𝐂,𝐃,𝐄,𝐅,𝐆,𝐇,𝐈,𝐉,𝐊,𝐋,𝐌,𝐍,𝐎,𝐏,𝐐,𝐑,𝐒,𝐓,𝐔,𝐕,𝐖,𝐗,𝐘,𝐙"
		cust_select_DG := "𝟎,𝟏,𝟐,𝟑,𝟒,𝟓,𝟔,𝟕,𝟖,𝟗"
	else if font_select == "Sans-Serif Bold Italic"
		cust_select_LC := "𝒂,𝒃,𝒄,𝒅,𝒆,𝒇,𝒈,𝒉,𝒊,𝒋,𝒌,𝒍,𝒎,𝒏,𝒐,𝒑,𝒒,𝒓,𝒔,𝒕,𝒖,𝒗,𝒘,𝒙,𝒚,𝒛"
		cust_select_UC := "𝑨,𝑩,𝑪,𝑫,𝑬,𝑭,𝑮,𝑯,𝑰,𝑱,𝑲,𝑳,𝑴,𝑵,𝑶,𝑷,𝑸,𝑹,𝑺,𝑻,𝑼,𝑽,𝑾,𝑿,𝒀,𝒁"
		cust_select_DG := "𝟎,𝟏,𝟐,𝟑,𝟒,𝟓,𝟔,𝟕,𝟖,𝟗"
	else if font_select == "Fraktur"
		cust_select_LC := "𝔞,𝔟,𝔠,𝔡,𝔢,𝔣,𝔤,𝔥,𝔦,𝔧,𝔨,𝔩,𝔪,𝔫,𝔬,𝔭,𝔮,𝔯,𝔰,𝔱,𝔲,𝔳,𝔴,𝔵,𝔶,𝔷"
		cust_select_UC := "𝔄,𝔅,ℭ,𝔇,𝔈,𝔉,𝔊,ℌ,ℑ,𝔍,𝔎,𝔏,𝔐,𝔑,𝔒,𝔓,𝔔,ℜ,𝔖,𝔗,𝔘,𝔙,𝔚,𝔛,𝔜,ℨ"
		cust_select_DG := "𝟢,𝟣,𝟤,𝟥,𝟦,𝟧,𝟨,𝟩,𝟪,𝟫"
	else if font_select == "Fraktur Bold"
		cust_select_LC := "𝖆,𝖇,𝖈,𝖉,𝖊,𝖋,𝖌,𝖍,𝖎,𝖏,𝖐,𝖑,𝖒,𝖓,𝖔,𝖕,𝖖,𝖗,𝖘,𝖙,𝖚,𝖛,𝖜,𝖝,𝖞,𝖟"
		cust_select_UC := "𝕬,𝕭,𝕮,𝕯,𝕰,𝕱,𝕲,𝕳,𝕴,𝕵,𝕶,𝕷,𝕸,𝕹,𝕺,𝕻,𝕼,𝕽,𝕾,𝕿,𝖀,𝖁,𝖂,𝖃,𝖄,𝖅"
		cust_select_DG := "𝟎,𝟏,𝟐,𝟑,𝟒,𝟓,𝟔,𝟕,𝟖,𝟗"
	else if font_select == "Script"
		cust_select_LC := "𝒶,𝒷,𝒸,𝒹,ℯ,𝒻,ℊ,𝒽,𝒾,𝒿,𝓀,𝓁,𝓂,𝓃,ℴ,𝓅,𝓆,𝓇,𝓈,𝓉,𝓊,𝓋,𝓌,𝓍,𝓎,𝓏"
		cust_select_UC := "𝒜,ℬ,𝒞,𝒟,ℰ,ℱ,𝒢,ℋ,ℐ,𝒥,𝒦,ℒ,ℳ,𝒩,𝒪,𝒫,𝒬,ℛ,𝒮,𝒯,𝒰,𝒱,𝒲,𝒳,𝒴,𝒵"
		cust_select_DG := "𝟢,𝟣,𝟤,𝟥,𝟦,𝟧,𝟨,𝟩,𝟪,𝟫"
	else if font_select == "Script Bold"
		cust_select_LC := "𝓪,𝓫,𝓬,𝓭,𝓮,𝓯,𝓰,𝓱,𝓲,𝓳,𝓴,𝓵,𝓶,𝓷,𝓸,𝓹,𝓺,𝓻,𝓼,𝓽,𝓾,𝓿,𝔀,𝔁,𝔂,𝔃"
		cust_select_UC := "𝓐,𝓑,𝓒,𝓓,𝓔,𝓕,𝓖,𝓗,𝓘,𝓙,𝓚,𝓛,𝓜,𝓝,𝓞,𝓟,𝓠,𝓡,𝓢,𝓣,𝓤,𝓥,𝓦,𝓧,𝓨,𝓩"
		cust_select_DG := "𝟎,𝟏,𝟐,𝟑,𝟒,𝟓,𝟔,𝟕,𝟖,𝟗"
	else if font_select == "Double-Struck"
		cust_select_LC := "𝕒,𝕓,𝕔,𝕕,𝕖,𝕗,𝕘,𝕙,𝕚,𝕛,𝕜,𝕝,𝕞,𝕟,𝕠,𝕡,𝕢,𝕣,𝕤,𝕥,𝕦,𝕧,𝕨,𝕩,𝕪,𝕫"
		cust_select_UC := "𝔸,𝔹,ℂ,𝔻,𝔼,𝔽,𝔾,ℍ,𝕀,𝕁,𝕂,𝕃,𝕄,ℕ,𝕆,ℙ,ℚ,ℝ,𝕊,𝕋,𝕌,𝕍,𝕎,𝕏,𝕐,ℤ"
		cust_select_DG := "𝟘,𝟙,𝟚,𝟛,𝟜,𝟝,𝟞,𝟟,𝟠,𝟡"
	else if font_select == "Monospace"
		cust_select_LC := "𝚊,𝚋,𝚌,𝚍,𝚎,𝚏,𝚐,𝚑,𝚒,𝚓,𝚔,𝚕,𝚖,𝚗,𝚘,𝚙,𝚚,𝚛,𝚜,𝚝,𝚞,𝚟,𝚠,𝚡,𝚢,𝚣"
		cust_select_UC := "𝙰,𝙱,𝙲,𝙳,𝙴,𝙵,𝙶,𝙷,𝙸,𝙹,𝙺,𝙻,𝙼,𝙽,𝙾,𝙿,𝚀,𝚁,𝚂,𝚃,𝚄,𝚅,𝚆,𝚇,𝚈,𝚉"
		cust_select_DG := "𝟶,𝟷,𝟸,𝟹,𝟺,𝟻,𝟼,𝟽,𝟾,𝟿"
	else if font_select == "Regional Indicator"
		cust_select_LC := "🇦,🇧,🇨,🇩,🇪,🇫,🇬,🇭,🇮,🇯,🇰,🇱,🇲,🇳,🇴,🇵,🇶,🇷,🇸,🇹,🇺,🇻,🇼,🇽,🇾,🇿"
		cust_select_UC := "🇦,🇧,🇨,🇩,🇪,🇫,🇬,🇭,🇮,🇯,🇰,🇱,🇲,🇳,🇴,🇵,🇶,🇷,🇸,🇹,🇺,🇻,🇼,🇽,🇾,🇿"
		cust_select_DG := "𝟶,𝟷,𝟸,𝟹,𝟺,𝟻,𝟼,𝟽,𝟾,𝟿"
	else if font_select == "Full Width"
		cust_select_LC := "ａ,ｂ,ｃ,ｄ,ｅ,ｆ,ｇ,ｈ,ｉ,ｊ,ｋ,ｌ,ｍ,ｎ,ｏ,ｐ,ｑ,ｒ,ｓ,ｔ,ｕ,ｖ,ｗ,ｘ,ｙ,ｚ"
		cust_select_UC := "Ａ,Ｂ,Ｃ,Ｄ,Ｅ,Ｆ,Ｇ,Ｈ,Ｉ,Ｊ,Ｋ,Ｌ,Ｍ,Ｎ,Ｏ,Ｐ,Ｑ,Ｒ,Ｓ,Ｔ,Ｕ,Ｖ,Ｗ,Ｘ,Ｙ,Ｚ"
		cust_select_DG := "０,１,２,３,４,５,６,７,８,９"
	else if font_select == "Circled"
		cust_select_LC := "🅐,🅑,🅒,🅓,🅔,🅕,🅖,🅗,🅘,🅙,🅚,🅛,🅜,🅝,🅞,🅟,🅠,🅡,🅢,🅣,🅤,🅥,🅦,🅧,🅨,🅩"
		cust_select_UC := "🅐,🅑,🅒,🅓,🅔,🅕,🅖,🅗,🅘,🅙,🅚,🅛,🅜,🅝,🅞,🅟,🅠,🅡,🅢,🅣,🅤,🅥,🅦,🅧,🅨,🅩"
		cust_select_DG := "⓿,❶,❷,❸,❹,❺,❻,❼,❽,❾"
	else
		cust_select_LC := "𝚊,𝚋,𝚌,𝚍,𝚎,𝚏,𝚐,𝚑,𝚒,𝚓,𝚔,𝚕,𝚖,𝚗,𝚘,𝚙,𝚚,𝚛,𝚜,𝚝,𝚞,𝚟,𝚠,𝚡,𝚢,𝚣"
		cust_select_UC := "𝙰,𝙱,𝙲,𝙳,𝙴,𝙵,𝙶,𝙷,𝙸,𝙹,𝙺,𝙻,𝙼,𝙽,𝙾,𝙿,𝚀,𝚁,𝚂,𝚃,𝚄,𝚅,𝚆,𝚇,𝚈,𝚉"
		cust_select_DG := "𝟶,𝟷,𝟸,𝟹,𝟺,𝟻,𝟼,𝟽,𝟾,𝟿"
	[cust_select_LC, cust_select_UC, cust_select_DG]

//}
//////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////
//// UNICODE REPLACEMENT FUNCTIONS ////
//{
// Unicode Character Replace Function
uni_replace_CHAR(_str, _fontType) =>
	[cust_select_LC, cust_select_UC, cust_select_DG] = fontType(_fontType)
	Cust_font_select_LC = str.split(cust_select_LC, ",")
	Cust_font_select_UC = str.split(cust_select_UC, ",")
    _custom_font_LC = Cust_font_select_LC
    _custom_font_UC = Cust_font_select_UC
    _new_str  = _str
    for _i = 0 to array.size(Pine_font_std_LC) - 1
        _new_str := str.replace_all(_new_str, array.get(Pine_font_std_LC, _i),
                                              array.get(_custom_font_LC, _i))
                                              
        _new_str := str.replace_all(_new_str, array.get(Pine_font_std_UC, _i),
                                              array.get(_custom_font_UC, _i))
    _new_str

// Unicode Digit Replace Function
uni_replace_DG(_str, _fontType) =>
	[cust_select_LC, cust_select_UC, cust_select_DG] = fontType(_fontType)
	Cust_font_select_DG = str.split(cust_select_DG, ",")
    _custom_font = Cust_font_select_DG
    _new_str  = _str
    for _i = 0 to array.size(Pine_font_std_DG) - 1
        _new_str := str.replace_all(_new_str, array.get(Pine_font_std_DG, _i), array.get(_custom_font, _i))
    _new_str

// Unicode Global Replace Function
fontTypeSelector(_str, _fontType) =>
    _str2 = uni_replace_DG(   _str, _fontType)
    _str3 = uni_replace_CHAR(_str2, _fontType)
    _str3
//}
//////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////
//// TEST SECTION ////
//{
test_string      = inp_str
test_string2     = inp_str2
test_stringFunc  = "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
test_stringFunc2 = "Curabitur ac bibendum nibh, vel iaculis massa. Suspendisse fermentum nulla vel mi mollis, at ultrices."
//}
//////////////////////////////////////////////////////////////////////////////////////////////////////

txtLine0     = fontTypeSelector(inp_str, fontType1)

txtDuyck1    = "█▀▄ █░█ █▄█ █▀▀ █▄▀"
txtDuyck2    = "█▄▀ █▄█ ░█░ █▄▄ █░█"
txtSeparator = "──────────────────────"
txtddfault1  = "█▀▄ █▀▄ █▀▄ █▀▀ ▄▀█ █░█ █░░ ▀█▀"
txtddfault2  = "█▄▀ █▄▀ █▄▀ █▀░ █▀█ █▄█ █▄▄ ░█░"

txtLine1     = fontTypeSelector(inp_str2, fontType2)
txtLine2     = fontTypeSelector(test_stringFunc, "Regional Indicator")
txtLine3     = fontTypeSelector(test_stringFunc2, "Monospace")

nL           = "\n"
dashLogo     = txtLine0 + nL + nL +
			 txtDuyck1 + nL +
			 txtDuyck2 + nL +
			 txtSeparator + nL +
			 txtddfault1 + nL +
			 txtddfault2 + nL + nL + nL +
			 txtLine1 + nL + nL +
			 txtLine2 + nL +
			 txtLine3 + nL
			 
//////////////////////////////////////////////////////////////////////////////////////////////////////
//// PLOTS ////
//{
if barstate.islast
    label logo = label.new(bar_index, close+5, text = dashLogo, color=#111118, style=label.style_label_center, textcolor=color.white, textalign=text.align_center)
    label.set_size(logo, size.normal)
//}
//////////////////////////////////////////////////////////////////////////////////////////////////////
````

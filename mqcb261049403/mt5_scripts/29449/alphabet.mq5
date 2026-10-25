/**/
#include "Alphabet.mqh"
/****************************************************************/
void OnStart()
  {
   Alphabet abc;
   /*REPORT*/
   Print("RUSSIAN");
   ArrayPrint(abc.russian.capital.shortitems);
   ArrayPrint(abc.russian.capital.stringitems);
   ArrayPrint(abc.russian.lowercase.shortitems);
   ArrayPrint(abc.russian.lowercase.stringitems);
   Print("LATIN");
   ArrayPrint(abc.latin.capital.shortitems);
   ArrayPrint(abc.latin.capital.stringitems);
   ArrayPrint(abc.latin.lowercase.shortitems);
   ArrayPrint(abc.latin.lowercase.stringitems);
   Print("DIGITS");
   ArrayPrint(abc.digits.shortitems);
   ArrayPrint(abc.digits.stringitems);
   Print("PUNCTUATION");
   ArrayPrint(abc.punctuations.shortitems);
   ArrayPrint(abc.punctuations.stringitems);
   Print("NO SPACE BEFORE");
   ArrayPrint(abc.nospacebefores.shortitems);
   ArrayPrint(abc.nospacebefores.stringitems);
   Print("NO SPACE AFTER");
   ArrayPrint(abc.nospaceafters.shortitems);
   ArrayPrint(abc.nospaceafters.stringitems);
   Print("WRAP");
   ArrayPrint(abc.wrapmarkers.shortitems);
   ArrayPrint(abc.wrapmarkers.stringitems);
   Print("WHITESPACE");
   ArrayPrint(abc.whitespaces.shortitems);
   ArrayPrint(abc.whitespaces.stringitems);
   Print("BRACKETS");
   ArrayPrint(abc.brackets.shortitems);
   ArrayPrint(abc.brackets.stringitems);
   Print("CHECK");
   ENUM_ALPHABET_CAT category;
   /**/
   string stringchars[]= {"\\","(","7","$","abc"};
   int sizestringchars=ArraySize(stringchars);
   for(int i=0; i<sizestringchars; i++)
     {
      string stringchar=stringchars[i];
      category=abc.Check(stringchar);
      Print(stringchar," is ",EnumToString(category));
     }
   /**/
   for(int i=0; i<3; i++)
     {
      short shortchar=(i==0)?abc.space.shortitem:
                      (i==1)?abc.comma.shortitem:
                      abc.leftbrace.shortitem;
      category=abc.Check(shortchar);
      Print(shortchar," is a ",EnumToString(category));
     }
   /**/
   return;
  }
/**/

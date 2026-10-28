/**/
enum ENUM_ALPHABET_CAT
  {
   CHAR_LATIN_LOWERCASE,CHAR_LATIN_CAPITAL,
   CHAR_RUSSIAN_LOWERCASE,CHAR_RUSSIAN_CAPITAL,
   CHAR_DIGIT,CHAR_WHITESPACE,CHAR_PUNCTUATION,CHAR_BRACKET,
   CHAR_UNDEFINED
  };
/****************************************************************/
struct AlphabetItem
  {
   short             shortitem;
   string            stringitem;
  };
/****************************************************************/
struct AlphabetItems
  {
   short             shortitems[];
   string            stringitems[];
  };
/****************************************************************/
struct Letters
  {
   AlphabetItems     capital;
   AlphabetItems     lowercase;
  };
/****************************************************************/
struct Alphabet
  {
   /*FULL SETS*/
   Letters           latin;
   Letters           russian;
   /*ARRAYS*/
   AlphabetItems     punctuations;
   AlphabetItems     digits;
   AlphabetItems     whitespaces;
   AlphabetItems     brackets;
   AlphabetItems     nospaceafters;
   AlphabetItems     nospacebefores;
   AlphabetItems     wrapmarkers;
   /*FREQUENT INDIVIDUAL CHARACTERS*/
   AlphabetItem      colon;
   AlphabetItem      comma;
   AlphabetItem      leftbrace;
   AlphabetItem      rightbrace;
   AlphabetItem      space;
   AlphabetItem      linebreak;
   AlphabetItem      tabulator;
                     Alphabet();
   ENUM_ALPHABET_CAT Check(short character);
   ENUM_ALPHABET_CAT Check(string character);
protected:
   void              Latin();
   void              Russian();
   void              Digit();
   void              Punctuation();
   void              NoSpaceAfters();
   void              NoSpaceBefores();
   void              Wraps();
   void              WhiteSpaces();
   void              Brackets();
   void              FrequentItems();
   /**/
   template<typename T>bool Find(T character,T &array[]);
  };
/****************************************************************/
Alphabet::Alphabet(void)
  {
   Latin();
   Russian();
   Punctuation();
   Digit();
   NoSpaceAfters();
   NoSpaceBefores();
   Wraps();
   WhiteSpaces();
   Brackets();
   FrequentItems();
  }
/****************************************************************/
template<typename T>bool Alphabet::Find(T character,T &array[])
  {
   int sizearray=ArraySize(array);
   for(int i=0; i<sizearray; i++)
     {
      T arrayitem=array[i];
      bool ischaracterArrayitem=character==arrayitem;
      if(ischaracterArrayitem)
        {return true;}
     }
   return false;
  }
/****************************************************************/
ENUM_ALPHABET_CAT Alphabet::Check(short character)
  {
   bool islatinlower=0,islatincap=0,isrussianlower=0,isrussiancap=0,
        isdigit=0,ispunctuation=0,isbracket=0,iswhitespace=0;
   /**/
   islatinlower=Find(character,latin.lowercase.shortitems);
   if(!islatinlower)
     {islatincap=Find(character,latin.capital.shortitems);}
   if(!islatincap)
     {isrussianlower=Find(character,russian.lowercase.shortitems);}
   if(!isrussianlower)
     {isrussiancap=Find(character,russian.capital.shortitems);}
   if(!isrussiancap)
     {isdigit=Find(character,digits.shortitems);}
   if(!isdigit)
     {ispunctuation=Find(character,punctuations.shortitems);}
   if(!ispunctuation)
     {isbracket=Find(character,brackets.shortitems);}
   if(!isbracket)
     {iswhitespace=Find(character,whitespaces.shortitems);}
   /**/
   ENUM_ALPHABET_CAT category;
   category=(islatinlower)?CHAR_LATIN_LOWERCASE:
            (islatincap)?CHAR_LATIN_CAPITAL:
            (isrussianlower)?CHAR_RUSSIAN_LOWERCASE:
            (isrussiancap)?CHAR_RUSSIAN_CAPITAL:
            (isdigit)?CHAR_DIGIT:
            (ispunctuation)?CHAR_PUNCTUATION:
            (isbracket)?CHAR_BRACKET:
            (iswhitespace)?CHAR_WHITESPACE:CHAR_UNDEFINED;
   return category;
  }
/****************************************************************/
ENUM_ALPHABET_CAT Alphabet::Check(string character)
  {
   /*CHECK*/
   bool ok=StringLen(character)==1;
   if(!ok)
     {return WRONG_VALUE;}
   /**/
   bool islatinlower=0,islatincap=0,isrussianlower=0,isrussiancap=0,
        isdigit=0,ispunctuation=0,isbracket=0,iswhitespace=0;
   /**/
   islatinlower=Find(character,latin.lowercase.stringitems);
   if(!islatinlower)
     {islatincap=Find(character,latin.capital.stringitems);}
   if(!islatincap)
     {isrussianlower=Find(character,russian.lowercase.stringitems);}
   if(!isrussianlower)
     {isrussiancap=Find(character,russian.capital.stringitems);}
   if(!isrussiancap)
     {isdigit=Find(character,digits.stringitems);}
   if(!isdigit)
     {ispunctuation=Find(character,punctuations.stringitems);}
   if(!ispunctuation)
     {isbracket=Find(character,brackets.stringitems);}
   if(!isbracket)
     {iswhitespace=Find(character,whitespaces.stringitems);}
   /**/
   ENUM_ALPHABET_CAT category;
   category=(islatinlower)?CHAR_LATIN_LOWERCASE:
            (islatincap)?CHAR_LATIN_CAPITAL:
            (isrussianlower)?CHAR_RUSSIAN_LOWERCASE:
            (isrussiancap)?CHAR_RUSSIAN_CAPITAL:
            (isdigit)?CHAR_DIGIT:
            (ispunctuation)?CHAR_PUNCTUATION:
            (isbracket)?CHAR_BRACKET:
            (iswhitespace)?CHAR_WHITESPACE:CHAR_UNDEFINED;
   return category;
  }
/****************************************************************/
void Alphabet::Latin(void)
  {
   string srclatinlower="abcdefghijklmnopqrstuvwxyz";
   StringToShortArray(srclatinlower,latin.lowercase.shortitems);
   ArrayRemove(latin.lowercase.shortitems,ArraySize(latin.lowercase.shortitems)-1);
   /**/
   int sizelower=ArraySize(latin.lowercase.shortitems);
   ArrayResize(latin.lowercase.stringitems,sizelower);
   for(int i=0; i<sizelower; i++)
     {
      short shortitem=latin.lowercase.shortitems[i];
      latin.lowercase.stringitems[i]=ShortToString(shortitem);
     }
   /*CAPS*/
   string srclatincaps="ABCDEFGHIJKLMNOPQRSTUVWXYZ";
   StringToShortArray(srclatincaps,latin.capital.shortitems);
   ArrayRemove(latin.capital.shortitems,ArraySize(latin.capital.shortitems)-1);
   /**/
   int sizecaps=ArraySize(latin.capital.shortitems);
   ArrayResize(latin.capital.stringitems,sizecaps);
   for(int i=0; i<sizecaps; i++)
     {
      short shortitem=latin.capital.shortitems[i];
      latin.capital.stringitems[i]=ShortToString(shortitem);
     }
  }
/****************************************************************/
void Alphabet::Russian(void)
  {
   string srcrussianlower="абвгдеёжзиклмнопрстуфхцчшщъыьэюя";
   StringToShortArray(srcrussianlower,russian.lowercase.shortitems);
   ArrayRemove(russian.lowercase.shortitems,ArraySize(russian.lowercase.shortitems)-1);
   /**/
   int sizelower=ArraySize(russian.lowercase.shortitems);
   ArrayResize(russian.lowercase.stringitems,sizelower);
   for(int i=0; i<sizelower; i++)
     {
      short shortitem=russian.lowercase.shortitems[i];
      russian.lowercase.stringitems[i]=ShortToString(shortitem);
     }
   /*CAPS*/
   string srcrussiancaps="АБВГДЕЁЖЗИКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ";
   StringToShortArray(srcrussiancaps,russian.capital.shortitems);
   ArrayRemove(russian.capital.shortitems,ArraySize(russian.capital.shortitems)-1);
   /**/
   int sizecaps=ArraySize(russian.capital.shortitems);
   ArrayResize(russian.capital.stringitems,sizecaps);
   for(int i=0; i<sizecaps; i++)
     {
      short shortitem=russian.capital.shortitems[i];
      russian.capital.stringitems[i]=ShortToString(shortitem);
     }
  }
/****************************************************************/
void Alphabet::Digit(void)
  {
   string srcdigits="0123456789";
   StringToShortArray(srcdigits,digits.shortitems);
   ArrayRemove(digits.shortitems,ArraySize(digits.shortitems)-1);
   /**/
   int size=ArraySize(digits.shortitems);
   ArrayResize(digits.stringitems,size);
   for(int i=0; i<size; i++)
     {
      short shortitem=digits.shortitems[i];
      digits.stringitems[i]=ShortToString(shortitem);
     }
  }
/****************************************************************/
void Alphabet::Punctuation(void)
  {
   string srcpunctuation=".,;:!?+=*`~'\"\\/-—–";
   StringToShortArray(srcpunctuation,punctuations.shortitems);
   ArrayRemove(punctuations.shortitems,ArraySize(punctuations.shortitems)-1);
   /**/
   int size=ArraySize(punctuations.shortitems);
   ArrayResize(punctuations.stringitems,size);
   for(int i=0; i<size; i++)
     {
      short shortitem=punctuations.shortitems[i];
      punctuations.stringitems[i]=ShortToString(shortitem);
     }
  }
/****************************************************************/
void Alphabet::NoSpaceAfters(void)
  {
   string srcnospaceafters="([<{-—–";
   StringToShortArray(srcnospaceafters,nospaceafters.shortitems);
   ArrayRemove(nospaceafters.shortitems,ArraySize(nospaceafters.shortitems)-1);
   /**/
   int size=ArraySize(nospaceafters.shortitems);
   ArrayResize(nospaceafters.stringitems,size);
   for(int i=0; i<size; i++)
     {
      short shortitem=nospaceafters.shortitems[i];
      nospaceafters.stringitems[i]=ShortToString(shortitem);
     }
  }
/****************************************************************/
void Alphabet::NoSpaceBefores(void)
  {
   string srcnospacebefores=".,:;?!)]>}-—–";
   StringToShortArray(srcnospacebefores,nospacebefores.shortitems);
   ArrayRemove(nospacebefores.shortitems,ArraySize(nospacebefores.shortitems)-1);
   /**/
   int size=ArraySize(nospacebefores.shortitems);
   ArrayResize(nospacebefores.stringitems,size);
   for(int i=0; i<size; i++)
     {
      short shortitem=nospacebefores.shortitems[i];
      nospacebefores.stringitems[i]=ShortToString(shortitem);
     }
  }
/****************************************************************/
void Alphabet::Wraps(void)
  {
   string srcwraps=",]?!";
   StringToShortArray(srcwraps,wrapmarkers.shortitems);
   ArrayRemove(wrapmarkers.shortitems,ArraySize(wrapmarkers.shortitems)-1);
   /**/
   int size=ArraySize(wrapmarkers.shortitems);
   ArrayResize(wrapmarkers.stringitems,size);
   for(int i=0; i<size; i++)
     {
      short shortitem=wrapmarkers.shortitems[i];
      wrapmarkers.stringitems[i]=ShortToString(shortitem);
     }
  }
/****************************************************************/
void Alphabet::WhiteSpaces(void)
  {
   string src=" \t\r\n";
   StringToShortArray(src,whitespaces.shortitems);
   ArrayRemove(whitespaces.shortitems,ArraySize(whitespaces.shortitems)-1);
   /**/
   int size=ArraySize(whitespaces.shortitems);
   ArrayResize(whitespaces.stringitems,size);
   for(int i=0; i<size; i++)
     {
      short shortitem=whitespaces.shortitems[i];
      whitespaces.stringitems[i]=ShortToString(shortitem);
     }
  }
/****************************************************************/
void Alphabet::Brackets(void)
  {
   string src="()[]{}<>";
   StringToShortArray(src,brackets.shortitems);
   ArrayRemove(brackets.shortitems,ArraySize(brackets.shortitems)-1);
   /**/
   int size=ArraySize(brackets.shortitems);
   ArrayResize(brackets.stringitems,size);
   for(int i=0; i<size; i++)
     {
      short shortitem=brackets.shortitems[i];
      brackets.stringitems[i]=ShortToString(shortitem);
     }
  }
/****************************************************************/
void Alphabet::FrequentItems(void)
  {
   colon.shortitem=':';
   comma.shortitem=',';
   leftbrace.shortitem='[';
   rightbrace.shortitem=']';
   space.shortitem=' ';
   linebreak.shortitem='\n';
   tabulator.shortitem='\t';
   /**/
   colon.stringitem=":";
   comma.stringitem=",";
   leftbrace.stringitem="[";
   rightbrace.stringitem="]";
   space.stringitem=" ";
   linebreak.stringitem="\n";
   tabulator.stringitem="\t";
  }
/**/

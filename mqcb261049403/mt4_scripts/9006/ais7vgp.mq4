//< 1. Property 7 >===========================================================================================//<   1>
                                                                                                              //<   2>
#property       copyright                "Copyright (C) 2009, MetaQuotes Software Corp."                      //<   3>
#property       link                     "https://www.metaquotes.net"                                          //<   4>
                                                                                                              //<   5>
#define         A.System.Series          "AIS"                                                                //<   6>
#define         A.System.Modification    "70301"                                                              //<   7>
#define         A.System.ReleaseDate     "2009.06.26"                                                         //<   8>
#define         A.System.Program         "Vertical Grid Plotter"                                              //<   9>
#define         A.System.Programmer      "Airat Safin                          http://www.mql4.com/users/Ais" //<  10>
                                                                                                              //<  11>
//</1. Property 7 >===========================================================================================//<  12>
////////////////////////////////////////////////////////////////////////////////////////////////////////////////<  13>
//< 2. Constants 1 >==========================================================================================//<  14>
                                                                                                              //<  15>
#define         acs.VGPrefix             "AVGL_"                                                              //<  16>
                                                                                                              //<  17>
//</2. Constants 1 >==========================================================================================//<  18>
////////////////////////////////////////////////////////////////////////////////////////////////////////////////<  19>
//< 3. Presets 7 >============================================================================================//<  20>
                                                                                                              //<  21>
#property       show_inputs                                                                                   //<  22>
                                                                                                              //<  23>
extern datetime aet.VGLeft             = D'2009.01.01 00:00'                                                ; //<  24>
extern int      aei.VGStep             = 60                                                                 ; //<  25>
extern datetime aet.VGRight            = D'2009.01.01 00:00'                                                ; //<  26>
                                                                                                              //<  27>
extern color    aei.VGColor            = Yellow                                                             ; //<  28>
extern int      aei.VGStyle            = 2                                                                  ; //<  29>
extern int      aei.VGBackground       = 0                                                                  ; //<  30>
                                                                                                              //<  31>
//</3. Presets 7 >============================================================================================//<  32>
////////////////////////////////////////////////////////////////////////////////////////////////////////////////<  33>
//< 4. Main Program 8 >=======================================================================================//<  34>
                                                                                                              //<  35>
int    init                           ()                                                                      //<  36>
{                                                                                                             //<  37>
                                                                                                              //<  38>
for  ( int ali.Time  = aet.VGLeft      ; ali.Time     <= aet.VGRight    ; ali.Time += aei.VGStep * 60     )   //<  39>
     {                                                                                                        //<  40>
       string          als.VGLineName  = acs.VGPrefix  + TimeToStr      ( ali.Time                        ) ; //<  41>
       ObjectCreate  ( als.VGLineName  , OBJ_VLINE     , 0              , ali.Time  , 0                   ) ; //<  42>
       ObjectSet     ( als.VGLineName  , OBJPROP_COLOR                  , aei.VGColor                     ) ; //<  43>
       ObjectSet     ( als.VGLineName  , OBJPROP_STYLE                  , aei.VGStyle                     ) ; //<  44>
       ObjectSet     ( als.VGLineName  , OBJPROP_BACK                   , aei.VGBackground                ) ; //<  45>
     } // for                                                                                                 //<  46>
                                                                                                              //<  37>
}                                                                                                             //<  48>
//</4. Main Program 8 >=======================================================================================//<  49>
//< 1. Property 7 >===========================================================================================//<   1>
                                                                                                              //<   2>
#property       copyright                "Copyright (C) 2009, MetaQuotes Software Corp."                      //<   3>
#property       link                     "https://www.metaquotes.net"                                          //<   4>
                                                                                                              //<   5>
#define         A.System.Series          "AIS"                                                                //<   6>
#define         A.System.Modification    "70101"                                                              //<   7>
#define         A.System.ReleaseDate     "2009.06.26"                                                         //<   8>
#define         A.System.Program         "Horizontal Grid Plotter"                                            //<   9>
#define         A.System.Programmer      "Airat Safin                          http://www.mql4.com/users/Ais" //<  10>
                                                                                                              //<  11>
//</1. Property 7 >===========================================================================================//<  12>
////////////////////////////////////////////////////////////////////////////////////////////////////////////////<  13>
//< 2. Constants 1 >==========================================================================================//<  14>
                                                                                                              //<  15>
#define         acs.HGPrefix             "AHGL_"                                                              //<  16>
                                                                                                              //<  17>
//</2. Constants 1 >==========================================================================================//<  18>
////////////////////////////////////////////////////////////////////////////////////////////////////////////////<  19>
//< 3. Presets 7 >============================================================================================//<  20>
                                                                                                              //<  21>
#property       show_inputs                                                                                   //<  22>
                                                                                                              //<  23>
extern double   aed.HGMax              = 2.0000                                                             ; //<  24>
extern double   aed.HGStep             = 0.0100                                                             ; //<  25>
extern double   aed.HGMin              = 1.0000                                                             ; //<  26>
                                                                                                              //<  27>
extern color    aei.HGColor            = White                                                              ; //<  28>
extern int      aei.HGStyle            = 2                                                                  ; //<  29>
extern int      aei.HGBackground       = 0                                                                  ; //<  30>
                                                                                                              //<  31>
//</3. Presets 7 >============================================================================================//<  32>
////////////////////////////////////////////////////////////////////////////////////////////////////////////////<  33>
//< 4. Main Program 11 >======================================================================================//<  34>
                                                                                                              //<  35>
int    init                           ()                                                                      //<  36>
{                                                                                                             //<  37>
                                                                                                              //<  38>
int             ali.HGPriceMax         = MathRound     ( aed.HGMax      / Point                           ) ; //<  39>
int             ali.HGPriceStep        = MathRound     ( aed.HGStep     / Point                           ) ; //<  40>
int             ali.HGPriceMin         = MathRound     ( aed.HGMin      / Point                           ) ; //<  41>
                                                                                                              //<  42>
for  ( int ali.Price = ali.HGPriceMin  ; ali.Price    <= ali.HGPriceMax ; ali.Price      += ali.HGPriceStep ) //<  43>
     {                                                                                                        //<  44>
       double          ald.HGLinePrice = ali.Price     * Point                                              ; //<  45>
       string          als.HGLineName  = acs.HGPrefix  + DoubleToStr    ( ald.HGLinePrice , Digits        ) ; //<  46>
       ObjectCreate  ( als.HGLineName  , OBJ_HLINE     , 0 , 0          , ald.HGLinePrice                 ) ; //<  47>
       ObjectSet     ( als.HGLineName  , OBJPROP_COLOR                  , aei.HGColor                     ) ; //<  48>
       ObjectSet     ( als.HGLineName  , OBJPROP_STYLE                  , aei.HGStyle                     ) ; //<  49>
       ObjectSet     ( als.HGLineName  , OBJPROP_BACK                   , aei.HGBackground                ) ; //<  50>
     } // for                                                                                                 //<  51>
                                                                                                              //<  52>
}                                                                                                             //<  53>
//</4. Main Program 11 >======================================================================================//<  54>
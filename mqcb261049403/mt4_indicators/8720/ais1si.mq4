//< 1. Property    >===========================================================================================//<  1>
                                                                                                               //<  2>
#property  copyright                  "Copyright (C) 2009, MetaQuotes Software Corp."                          //<  3>
#property  link                       "https://www.metaquotes.net"                                              //<  4>
                                                                                                               //<  5>
#define    A.System.Series            "AIS"                                                                    //<  6>
#define    A.System.Modification      "10304"                                                                  //<  7>
#define    A.System.ReleaseDate       "21.02.2009"                                                             //<  8>
#define    A.System.Program           "Standard Indicator"                                                     //<  9>
#define    A.System.Programmer        "Airat Safin                              http://www.mql4.com/users/Ais" //< 10>
                                                                                                               //< 11>
//</1. Property    >===========================================================================================//< 12>
                                                                                                               //< 13>
//< 2. Program     >===========================================================================================//< 14>
                                                                                                               //< 15>
//< 2.1. Data      >-------------------------------------------------------------------------------------------//< 16>
                                                                                                               //< 17>
string     A.System.Stamp           = "A System"                                                             ; //< 18>
                                                                                                               //< 19>
#property  indicator_chart_window                                                                              //< 20>
                                                                                                               //< 21>
double     arv.Chart           [] = { EMPTY                                                                  , //< 22>
                                      EMPTY                                                                  , //< 23>
                                      EMPTY                                                                  , //< 24>
                                      EMPTY                                                                  , //< 25>
                                      EMPTY                                                                } ; //< 26>
                                                                                                               //< 27>
#define    ari.ZeroTime               0                                                                        //< 28>
#define    ari.Resolution.H           1                                                                        //< 29>
#define    ari.LastBar                2                                                                        //< 30>
#define    ari.PriceMax               3                                                                        //< 31>
#define    ari.PriceMin               4                                                                        //< 32>
                                                                                                               //< 33>
#property  indicator_buffers          4                                                                        //< 34>
                                                                                                               //< 35>
double     B0 [] , B1 [] , B2 []    , B3 []                                                                  ; //< 36>
                                                                                                               //< 37>
//</2.1. Data      >-------------------------------------------------------------------------------------------//< 38>
                                                                                                               //< 39>
//< 2.2. Functions >-------------------------------------------------------------------------------------------//< 40>
                                                                                                               //< 41>
int init   () { SetIndexBuffer  ( 3 , B3 ) ; SetIndexStyle  ( 3 , DRAW_LINE , STYLE_SOLID , 4 , Blue       ) ; //< 42>
                SetIndexBuffer  ( 2 , B2 ) ; SetIndexStyle  ( 2 , DRAW_LINE , STYLE_SOLID , 1 , Green      ) ; //< 43>
                SetIndexBuffer  ( 1 , B1 ) ; SetIndexStyle  ( 1 , DRAW_LINE , STYLE_SOLID , 1 , Yellow     ) ; //< 44>
                SetIndexBuffer  ( 0 , B0 ) ; SetIndexStyle  ( 0 , DRAW_LINE , STYLE_SOLID , 4 , Red        ) ; //< 45>
                                                                                                               //< 46>
                     arv.Chart  [ ari.ZeroTime              ]   = EMPTY                                      ; //< 47>
                     arv.Chart  [ ari.Resolution.H          ]   = EMPTY                                      ; //< 48>
                     arv.Chart  [ ari.LastBar               ]   = EMPTY                                      ; //< 49>
                     arv.Chart  [ ari.PriceMax              ]   = EMPTY                                      ; //< 50>
                     arv.Chart  [ ari.PriceMin              ]   = EMPTY                                      ; //< 51>
                                                                                                               //< 52>
                A.System.Stamp  = A.System.Stamp            + ": " +                                           //< 53>
                                  A.System.Series           +                                                  //< 54>
                                  A.System.Modification     + " "  +                                           //< 55>
                                  A.System.Program                                                           ; //< 56>
                                                                                                               //< 57>
                Alert           ( ""                                                                       ) ; //< 58>
                Alert           ( A.System.Stamp            ,   " Reload "       , UninitializeReason () ) ; } //< 59>
                                                                                                               //< 50>
int deinit () { Alert           ( A.System.Stamp            ,   " Stop "         , UninitializeReason () ) ; } //< 61>
                                                                                                               //< 62>
int start  () { if ( arv.Chart  [ ari.ZeroTime              ]  != Time [ 0 ]                                   //< 63>
                  || arv.Chart  [ ari.Resolution.H          ]  != WindowBarsPerChart                      ()   //< 64>
                  || arv.Chart  [ ari.LastBar               ]  != WindowFirstVisibleBar                   ()   //< 65>
                  || arv.Chart  [ ari.PriceMax              ]  != WindowPriceMax                          ()   //< 66>
                  || arv.Chart  [ ari.PriceMin              ]  != WindowPriceMin                          () ) //< 67>
                                                                                                               //< 68>
                {    arv.Chart  [ ari.ZeroTime              ]   = Time [ 0 ]                                 ; //< 69>
                     arv.Chart  [ ari.Resolution.H          ]   = WindowBarsPerChart                      () ; //< 70>
                     arv.Chart  [ ari.LastBar               ]   = WindowFirstVisibleBar                   () ; //< 71>
                     arv.Chart  [ ari.PriceMax              ]   = WindowPriceMax                          () ; //< 72>
                     arv.Chart  [ ari.PriceMin              ]   = WindowPriceMin                          () ; //< 73>
                                                                                                               //< 74>
                     double ald.AverageBid                                                                   ; //< 75>
                     double ald.Spread     =    Ask             - Bid                                        ; //< 76>
                     int    N              =    WindowFirstVisibleBar                                     () ; //< 77>
                     for (  int   i  = 0 ; i <= N    ; i ++ )                                                  //< 78>
                         {  ald.AverageBid =  ( Low  [ i ]      + High [ i ] ) / 2                           ; //< 79>
                                                                                                               //< 80>
                            B3  [ i ]      =    High [ i ]      + ald.Spread                                 ; //< 81>
                            B2  [ i ]      =    ald.AverageBid  + ald.Spread                                 ; //< 82>
                            B1  [ i ]      =    ald.AverageBid                                               ; //< 83>
                            B0  [ i ]      =    Low  [ i ]                                               ; } } //< 84>
                else                                                                                           //< 85>
                {           ald.Spread     =    Ask             - Bid                                        ; //< 86>
                            ald.AverageBid =  ( Low  [ 0 ]      + High [ 0 ] ) / 2                           ; //< 87>
                                                                                                               //< 88>
                            B3  [ 0 ]      =    High [ 0 ]      + ald.Spread                                 ; //< 89>
                            B2  [ 0 ]      =    ald.AverageBid  + ald.Spread                                 ; //< 90>
                            B1  [ 0 ]      =    ald.AverageBid                                               ; //< 91>
                            B0  [ 0 ]      =    Low  [ 0 ]                                               ; } } //< 92>
                                                                                                               //< 93>
//</2.2. Functions >-------------------------------------------------------------------------------------------//< 94>
                                                                                                               //< 95>
//</2. Program  >==============================================================================================//< 96>
//</2.2. Functions >-------------------------------------------------------------------------------------------//< 97>
                                                                                                               //< 98>
//</2. Program  >==============================================================================================//< 99>
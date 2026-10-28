//+------------------------------------------------------------------+
//|                                                   HPFGlobals.mqh |
//|                                  Copyright 2018, André S. Enger. |
//|                                          andre_enger@hotmail.com |
//|                                  Contribs                        |
//|                                         David Gadelha            |
//|                                               dgadelha@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//--- Header guard
#ifndef HPFGLOBALS_MQH
#define HPFGLOBALS_MQH

//--- Constants and macros
#define NUM_PATTERNS 88
#define NUM_4POINTPATTERNS 36
#define NON_EXISTENT_DATETIME D'19.07.1980 12:30:27'
const string _identifier="HPE";
const int _secsDoubleClick=1000;

//--- Include files
#include "HPFIndicator.mqh"
#include "HPFStatisticsObserver.mqh"
#include "HPFObserverList.mqh"
#include "HPFCommentObserver.mqh"
#include "HPFDrawingObserver.mqh"
#include "HPFFilterList.mqh"
#include "HPFPurityFilter.mqh"
#include "HPFTimeFilter.mqh"
//--- Number keys of patterns
enum PATTERN_INDEX
  {
   TRENDLIKE1_ABCD=0,
   TRENDLIKE2_ABCD,
   PERFECT_ABCD,
   IDEAL1_ABCD,
   IDEAL2_ABCD,
   RANGELIKE_ABCD,
   ALT127_TRENDLIKE1_ABCD,
   ALT127_TRENDLIKE2_ABCD,
   ALT127_PERFECT_ABCD,
   ALT127_IDEAL1_ABCD,
   ALT127_IDEAL2_ABCD,
   ALT127_RANGELIKE_ABCD,
   ALT161_TRENDLIKE1_ABCD,
   ALT161_TRENDLIKE2_ABCD,
   ALT161_PERFECT_ABCD,
   ALT161_IDEAL1_ABCD,
   ALT161_IDEAL2_ABCD,
   ALT161_RANGELIKE_ABCD,
   REC_TRENDLIKE1_ABCD,
   REC_TRENDLIKE2_ABCD,
   REC_PERFECT_ABCD,
   REC_IDEAL1_ABCD,
   REC_IDEAL2_ABCD,
   REC_RANGELIKE_ABCD,
   ALT127_REC_TRENDLIKE1_ABCD,
   ALT127_REC_TRENDLIKE2_ABCD,
   ALT127_REC_PERFECT_ABCD,
   ALT127_REC_IDEAL1_ABCD,
   ALT127_REC_IDEAL2_ABCD,
   ALT127_REC_RANGELIKE_ABCD,
   ALT161_REC_TRENDLIKE1_ABCD,
   ALT161_REC_TRENDLIKE2_ABCD,
   ALT161_REC_PERFECT_ABCD,
   ALT161_REC_IDEAL1_ABCD,
   ALT161_REC_IDEAL2_ABCD,
   ALT161_REC_RANGELIKE_ABCD,
   GARTLEY,
   PERFECT_GARTLEY,
   MAXGARTLEY,
   BAT,
   PERFECT_BAT,
   ALTBAT,
   MAXBAT,
   CRAB,
   PERFECT_CRAB,
   DEEPCRAB,
   BUTTERFLY,
   PERFECT_BUTTERFLY,
   MAXBUTTERFLY,
   BUTTERFLY113,
   FIVEO,
   THREEDRIVES,
   CYPHER,
   SHARK,
   NENSTAR,
   BLACKSWAN,
   WHITESWAN,
   ONE2ONE,
   NEWCYPHER,
   NAVARRO200,
   LEONARDO,
   KANE,
   GARFLY,
   GARTLEY113,
   ANTI_GARTLEY,
   ANTI_BAT,
   ANTI_ALTBAT,
   ANTI_FIVEO,
   ANTI_BUTTERFLY,
   ANTI_CRAB,
   ANTI_DEEPCRAB,
   ANTI_THREEDRIVES,
   ANTI_CYPHER,
   ANTI_SHARK,
   ANTI_NENSTAR,
   ANTI_BLACKSWAN,
   ANTI_WHITESWAN,
   ANTI_ONE2ONE,
   ANTI_NEWCYPHER,
   ANTI_NAVARRO200,
   ANTI_LEONARDO,
   ANTI_KANE,
   ANTI_GARFLY,
   ANTI_MAXBAT,
   ANTI_MAXGARTLEY,
   ANTI_MAXBUTTERFLY,
   ANTI_GARTLEY113,
   ANTI_BUTTERFLY113
  };

//--- User Inputs
input string zigzagSettings="-=ZigZag Settings=-"; //-=ZigZag Settings=-
input double i_zzAtrMultiplier=2;     //ATR ZZ atr multiplier
input int i_zzAtrPeriod=50;             //ATR ZZ atr period
input int i_zzMaxPeriod=10;           //ATR ZZ max period
input int i_zzMinPeriod=3;            //ATR ZZ min period
input bool i_zzRealtime=true;         //ATR ZZ realtime
input string indicatorSettings="-=Indicator Settings=-"; //-=Indicator Settings=-
input int i_barsAnalyzed=300;         //Max. bars per pattern
input int i_history=1000;             //Max. history bars to process
input int i_maxSamePoints=2;          //Max. shared points per pattern
input double i_slackRange=0.05;       //Max. slack for fib ratios (range)
input double i_slackSingular=0.1;        //Max. slack for fib ratios (unary)
input double i_tooEarly=0.382;        //Too early timezone
input double i_ideal=1.0;             //Ideal timezone
input double i_tooLate=1.618;         //Too late timezone
input bool i_puristPRZ=false;         //Filter patterns without fib ratios in PRZ
input bool i_timefilterEarly=false;     //Filter too early patterns
input bool i_timefilterLate=false;     //Filter too late patterns 
input string indicatorColors="-=Display Settings=-"; //-=Display Settings=-
input color i_clrBull=clrLightSkyBlue;               //Color for bullish patterns (5 points)
input color i_clrBear=clrLightPink;                  //Color for bearish patterns (5 points)
input color i_clrBull4P=clrDeepSkyBlue;              //Color for bullish patterns (4 points)
input color i_clrBear4P=clrDeepPink;                 //Color for bearish patterns (4 points)
input color i_clrBullProjection=clrSeaGreen;         //Color for proj. bullish patterns (5P)
input color i_clrBearProjection=clrDarkOrange;       //Color for proj. bearish patterns (5P)
input color i_clrBullProjection4P=clrYellowGreen;    //Color for proj. bullish patterns (4P)
input color i_clrBearProjection4P=clrYellow;         //Color for proj. bearish patterns (4P)
input color i_clrFocus=clrWhite;                     //Color for focused patterns
input bool i_fillPatterns=false;                    //Fill 5 point patterns found
input bool i_showDescriptions=true;                 //Show pattern descriptions
input bool i_emergingPatterns=true;                  //Show emerging patterns
input bool i_oldPatterns=true;                       //Show past patterns
input bool i_oneAheadProjection=false;               //Show "one-ahead" projections
input bool i_showSoftProjections=true;               //Draw projections bodies in soft color
input bool showPatternNames=true;                  //Show comment box
input int i_lineWidth=2;                               //Pattern line width
input int i_lineWidthProj=1;                          //Emerging patterns line width
input int i_lineWidthFoc=3;                       //Focused patterns line width
input int i_fontSize=08;                            //Font size
input ENUM_LINE_STYLE i_style5P=STYLE_SOLID;        //Style for 5 points patterns
input ENUM_LINE_STYLE i_style4P=STYLE_DASH;         //Style for 4 points patterns
input ENUM_LINE_STYLE i_styleProj=STYLE_DASHDOTDOT; //Style for projections
input ENUM_LINE_STYLE i_styleRatio=STYLE_DOT;       //Style for ratio lines
input ENUM_LINE_STYLE i_stylePRZ=STYLE_DASHDOT;     //Style for PRZ
input string indicatorPatternsQuick="-=Patterns Quick=-"; //-=Patterns Quick=-
input bool i_show_abcd=true;                //Display AB=CD patterns
input bool i_show_alt127_abcd=false;         //Display 1.27 AB=CD patterns
input bool i_show_alt161_abcd=false;         //Display 1.61 AB=CD patterns
input bool i_show_rec_abcd=false;            //Display Rec. AB=CD patterns
input bool i_show_alt127_rec_abcd=false;     //Display Rec. 1.27 AB=CD patterns
input bool i_show_alt161_rec_abcd=false;     //Display Rec. 1.61 AB=CD patterns
input bool i_show_patterns=true;            //Display normal 5-point patterns
input bool i_show_antipatterns=false;       //Display anti 5-point patterns
input string indicatorPatternsIndividual="-=Patterns Individual=-"; //-=Patterns Individual=-
input bool i_show_trendlike1_abcd=true;        //Display Trendlike AB=CD #1
input bool i_show_trendlike2_abcd=true;        //Display Trendlike AB=CD #2
input bool i_show_perfect_abcd=true;           //Display Perfect AB=CD
input bool i_show_ideal1_abcd=true;            //Display Ideal AB=CD #1
input bool i_show_ideal2_abcd=true;            //Display Ideal AB=CD #2
input bool i_show_rangelike_abcd=true;         //Display Rangelike AB=CD
input bool i_show_alt127_trendlike1_abcd=true; //Display Trendlike 1.27 AB=CD #1
input bool i_show_alt127_trendlike2_abcd=true; //Display Trendlike 1.27 AB=CD #2
input bool i_show_alt127_perfect_abcd=true;    //Display Perfect 1.27 AB=CD
input bool i_show_alt127_ideal1_abcd=true;     //Display Ideal 1.27 AB=CD #1
input bool i_show_alt127_ideal2_abcd=true;     //Display Ideal 1.27 AB=CD #2
input bool i_show_alt127_rangelike_abcd=true;  //Display Rangelike 1.27 AB=CD
input bool i_show_alt161_trendlike1_abcd=true; //Display Trendlike 1.61 AB=CD #1
input bool i_show_alt161_trendlike2_abcd=true; //Display Trendlike 1.61 AB=CD #2
input bool i_show_alt161_perfect_abcd=true;    //Display Perfect 1.61 AB=CD
input bool i_show_alt161_ideal1_abcd=true;     //Display Ideal 1.61 AB=CD #1
input bool i_show_alt161_ideal2_abcd=true;     //Display Ideal 1.61 AB=CD #2
input bool i_show_alt161_rangelike_abcd=true;  //Display Rangelike 1.61 AB=CD
input bool i_show_rec_trendlike1_abcd=true;    //Display Rec. Trendlike AB=CD #1
input bool i_show_rec_trendlike2_abcd=true;    //Display Rec. Trendlike AB=CD #2
input bool i_show_rec_perfect_abcd=true;       //Display Rec. Perfect AB=CD
input bool i_show_rec_ideal1_abcd=true;        //Display Rec. Ideal AB=CD #1
input bool i_show_rec_ideal2_abcd=true;        //Display Rec. Ideal AB=CD #2
input bool i_show_rec_rangelike_abcd=true;     //Display Rec. Rangelike AB=CD
input bool i_show_alt127_rec_trendlike1_abcd=true;    //Display Rec. Trendlike 1.27 AB=CD #1
input bool i_show_alt127_rec_trendlike2_abcd=true;    //Display Rec. Trendlike 1.27 AB=CD #2
input bool i_show_alt127_rec_perfect_abcd=true;       //Display Rec. Perfect 1.27 AB=CD
input bool i_show_alt127_rec_ideal1_abcd=true;        //Display Rec. Ideal 1.27 AB=CD #1
input bool i_show_alt127_rec_ideal2_abcd=true;        //Display Rec. Ideal 1.27 AB=CD #2
input bool i_show_alt127_rec_rangelike_abcd=true;     //Display Rec. Rangelike 1.27 AB=CD
input bool i_show_alt161_rec_trendlike1_abcd=true;    //Display Rec. Trendlike 1.61 AB=CD #1
input bool i_show_alt161_rec_trendlike2_abcd=true;    //Display Rec. Trendlike 1.61 AB=CD #2
input bool i_show_alt161_rec_perfect_abcd=true;       //Display Rec. Perfect 1.61 AB=CD
input bool i_show_alt161_rec_ideal1_abcd=true;        //Display Rec. Ideal 1.61 AB=CD #1
input bool i_show_alt161_rec_ideal2_abcd=true;        //Display Rec. Ideal 1.61 AB=CD #2
input bool i_show_alt161_rec_rangelike_abcd=true;     //Display Rec. Rangelike 1.61 AB=CD
input bool i_show_gartley=true;                //Display Gartley
input bool i_show_perfect_gartley=true;        //Display Perfect Gartley
input bool i_show_gartley113=true;             //Display Gartley 113
input bool i_show_maxgartley=true;             //Display Max. Gartley
input bool i_show_bat=true;                    //Display Bat
input bool i_show_perfect_bat=true;            //Display Perfect Bat
input bool i_show_altbat=true;                 //Display Alt. Bat
input bool i_show_maxbat=true;                 //Display Max. Bat
input bool i_show_crab=true;                   //Display Crab
input bool i_show_perfect_crab=true;           //Display Perfect Crab
input bool i_show_deepcrab=true;               //Display Deepcrab
input bool i_show_butterfly=true;              //Display Butterfly
input bool i_show_perfect_butterfly=true;      //Display Perfect Butterfly
input bool i_show_maxbutterfly=true;           //Display Max. Butterfly
input bool i_show_butterfly113=true;           //Display Butterfly 113
input bool i_show_fiveo=true;                  //Display 5-0
input bool i_show_threedrives=true;            //Display Three Drives
input bool i_show_cypher=true;                 //Display Cypher
input bool i_show_shark=true;                  //Display Shark
input bool i_show_nenstar=true;                //Display Nen Star
input bool i_show_blackswan=true;              //Display Black Swan
input bool i_show_whiteswan=true;              //Display White Swan
input bool i_show_one2one=false;                //Display One2One
input bool i_show_newCypher=true;              //Display New Cypher
input bool i_show_navarro200=false;             //Display Navarro 200
input bool i_show_leonardo=true;               //Display Leonardo
input bool i_show_kane=true;                   //Display Kane
input bool i_show_garfly=true;                 //Display Garfly
input bool i_show_antigartley=true;            //Display Anti Gartley
input bool i_show_antibat=true;                //Display Anti Bat
input bool i_show_antialtbat=true;             //Display Anti Alt. Bat
input bool i_show_antifiveo=true;              //Display Anti 5-0
input bool i_show_antibutterfly=true;          //Display Anti Butterfly
input bool i_show_anticrab=true;               //Display Anti Crab
input bool i_show_antideepcrab=true;           //Display Anti Deepcrab
input bool i_show_antithreedrives=true;        //Display Anti Three Drives
input bool i_show_anticypher=true;             //Display Anti Cypher
input bool i_show_antishark=true;              //Display Anti Shark
input bool i_show_antinenstar=true;            //Display Anti Nen Star
input bool i_show_antiblackswan=true;          //Display Anti Black Swan
input bool i_show_antiwhiteswan=true;          //Display Anti White Swan
input bool i_show_antione2one=true;            //Display Anti One2One
input bool i_show_antinewCypher=true;          //Display Anti New Cypher
input bool i_show_antinavarro200=true;         //Display Anti Navarro 200
input bool i_show_antileonardo=true;           //Display Anti Leonardo
input bool i_show_antikane=true;               //Display Anti Kane
input bool i_show_antigarfly=true;             //Display Anti Garfly
input bool i_show_antimaxbat=true;             //Display Anti Max. Bat
input bool i_show_antimaxgartley=true;         //Display Anti Max. Gartley
input bool i_show_antimaxbutterfly=true;       //Display Anti Max. Butterfly
input bool i_show_antigartley113=true;         //Display Anti Gartley 113
input bool i_show_antibutterfly113=true;       //Display Anti Butterfly 113

//--- Class objects
CHPFMatcher _matcher();
CHPFIndicator _indicator(NUM_PATTERNS,NUM_4POINTPATTERNS,i_barsAnalyzed*2);
CHPFStatisticsObserver _statistics(NUM_PATTERNS);
CHPFObserverList _observers(3);
CHPFTimeFilter _timeFilter(NUM_4POINTPATTERNS,i_tooEarly,i_tooLate);
CHPFFilterList _filters(2);

//--- Indicator buffer arrays and zigzag globals
double _peaks[],_troughs[];
bool _zzLastDirection;
bool _realtimeChange;
int _lastIndex;
int _lastIndex2;
int _contraIndex;
double _atr;

datetime _time[];

//--- Other globals
bool _lastDirection;
double _lastPeakValue;
double _lastTroughValue;
int _lastPeak;
int _lastTrough;
PATTERN_DESCRIPTOR _patterns[];
string _patternNames[];
int _timeOfInit;
uint _prevClick;
int _deltaDT=(Period()<60 ? PeriodSeconds()*180 : PeriodSeconds()*180);
color _faintBGColor;
long _clrbackground;
color _clrRatio;
//+------------------------------------------------------------------+
//| Shared method creates hexadecimal encoding of datetimes          |
//+------------------------------------------------------------------+
string UniqueIdentifier(datetime ADateTime,datetime BDateTime,datetime CDateTime,datetime DDateTime)
  {
   return " "+StringFormat("%x",ADateTime)+StringFormat("%x",BDateTime)+StringFormat("%x",CDateTime)+StringFormat("%x",DDateTime);
  }
//+------------------------------------------------------------------+
//| Shared method creates hexadecimal encoding of datetimes          |
//+------------------------------------------------------------------+
string UniqueIdentifier(datetime XDateTime,datetime ADateTime,datetime BDateTime,datetime CDateTime,datetime DDateTime)
  {
   return " "+StringFormat("%x",XDateTime)+StringFormat("%x",ADateTime)+StringFormat("%x",BDateTime)+StringFormat("%x",CDateTime)+StringFormat("%x",DDateTime);
  }
//+------------------------------------------------------------------+
//| Shared method checks for 4 point patterns                        |
//+------------------------------------------------------------------+
bool Is4PointPattern(int index) 
  {
   return index<NUM_4POINTPATTERNS;
  }
//--- End header guard
#endif
//+------------------------------------------------------------------+

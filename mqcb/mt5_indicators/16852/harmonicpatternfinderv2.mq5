//+------------------------------------------------------------------+
//|                                      HarmonicPatternFinderV2.mq5 |
//|                                  Copyright 2016, André S. Enger. |
//|                                          andre_enger@hotmail.com |
//|                                  Contribs                        |
//|                                         David Gadelha            |
//|                                               dgadelha@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Andre S. Enger."
#property link      "andre_enger@hotmail.com"
#property version   "2.0"
#property description "Indicator to display existent and emerging harmonic chart patterns."

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 1

#property indicator_label1  "Zig Zag"
#property indicator_type1   DRAW_ZIGZAG
#property indicator_color1  clrNONE
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- Describes patterns
struct PATTERN_DESCRIPTOR
  {
   double            ab2xa_min;
   double            ab2xa_max;
   double            bc2ab_min;
   double            bc2ab_max;
   double            cd2bc_min;
   double            cd2bc_max;
   double            ad2xa_min;
   double            ad2xa_max;
   double            cd2xc_min;
   double            cd2xc_max;
   double            xc2xa_min;
   double            xc2xa_max;
   double            cd2ab_min;
   double            cd2ab_max;
  };
//--- Identifies drawn patterns
struct PATTERN_INSTANCE
  {
   int               patternIndex;
   int               patternBufferIndex;
   bool              bullish;
   bool              overlapping;
   datetime          XDateTime;
   datetime          ADateTime;
   datetime          BDateTime;
   datetime          CDateTime;
   datetime          DDateTime;
   double            X;
   double            A;
   double            B;
   double            C;
   double            D;
   double            PRZ;
  };
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
   REC_TRENDLIKE1_ABCD,
   REC_TRENDLIKE2_ABCD,
   REC_PERFECT_ABCD,
   REC_IDEAL1_ABCD,
   REC_IDEAL2_ABCD,
   REC_RANGELIKE_ABCD,
   GARTLEY,
   BAT,
   ALTBAT,
   FIVEO,
   BUTTERFLY,
   CRAB,
   DEEPCRAB,
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
   MAXBAT,
   MAXGARTLEY,
   MAXBUTTERFLY,
   GARTLEY113,
   BUTTERFLY113,
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
   ANTI_BUTTERFLY113,
  };
//--- ZigZag selection
enum ZIGZAGTYPE
  {
   FASTZZ,//Fast ZZ
   ALEXSTAL,//Alexstal ZZ
   SWINGCHART //Swing ZZ
  };

//--- Constants and macros
#define SIZE_PATTERN_BUFFER 10
#define NUM_PATTERNS 66
#define NON_EXISTENT_DATETIME D'19.07.1980 12:30:27'

const string _identifier="HPF";

//--- User Inputs
input string indicatorSettings="-=Indicator Settings=-"; //-=Indicator Settings=-
input ZIGZAGTYPE zztype=ALEXSTAL;   //ZigZag type
input int zzperiod=12;              //AlexStal ZZ period
input int zzamplitude=10;           //AlexStal ZZ amplitude
input int zzminmotion=0;            //AlexStal ZZ minimum motion 
input int SwingSize=200;            //Fast ZZ sensitivity in points
input int BarsAnalyzed=200;         //Max. bars per pattern
input int History=1000;             //Max. history bars to process
input int MaxSamePoints=2;          //Max. shared points per pattern
input double SlackRange=0.01;       //Max. slack for fib ratios (range)
input double SlackUnary=0.1;        //Max. slack for fib ratios (unary)
input string indicatorColors="-=Display Settings=-"; //-=Display Settings=-
input color ClrBull=clrLightSkyBlue;               //Color for bullish patterns (5 points)
input color ClrBear=clrSalmon;                     //Color for bearish patterns (5 points)
input color ClrBull4P=clrBlue;                     //Color for bullish patterns (4 points)
input color ClrBear4P=clrRed;                      //Color for bearish patterns (4 points)
input color ClrBullProjection=clrSeaGreen;         //Color for projected bullish patterns
input color ClrBearProjection=clrDarkOrange;       //Color for projected bearish patterns
input color ClrRatio=clrGray;                      //Color for patterns ratios
input bool Fill_Patterns=false;                    //Fill 5 point patterns found
input bool Show_descriptions=true;                 //Show pattern descriptions
input bool Show_PRZ=true;                          //Show potential reversal zone (PRZ)
input bool EmergingPatterns=true;                  //Show emerging patterns
input bool OneAheadProjection=false;               //Show "one-ahead" projections
input bool showPatternNames=false;                 //Show comment box
input int l_width=2;                               //Pattern line width (5 points)
input int l_width4p=2;                             //Patterns line width (4 points)
input int l_width_proj=2;                          //Emerging patterns line width
input int Font_size=08;                            //Font size
input ENUM_LINE_STYLE Style_5P=STYLE_SOLID;        //Style for 5 points patterns
input ENUM_LINE_STYLE Style_4P=STYLE_DASH;         //Style for 4 points patterns
input ENUM_LINE_STYLE Style_Proj=STYLE_DASHDOTDOT; //Style for projections
input ENUM_LINE_STYLE Style_Ratio=STYLE_DOT;       //Style for ratio lines
input ENUM_LINE_STYLE Style_PRZ=STYLE_DASHDOT;     //Style for PRZ
input string indicatorPatternsQuick="-=Patterns Quick=-"; //-=Patterns Quick=-
input bool Show_abcd=true;          //Display AB=CD patterns
input bool Show_alt127_abcd=true;   //Display 1.27 AB=CD patterns
input bool Show_rec_abcd=true;      //Display Rec. AB=CD patterns
input bool Show_patterns=true;      //Display normal 5-point patterns
input bool Show_antipatterns=false; //Display anti 5-point patterns
input string indicatorPatternsIndividual="-=Patterns Individual=-"; //-=Patterns Individual=-
input bool Show_trendlike1_abcd=true;        //Display Trendlike AB=CD #1
input bool Show_trendlike2_abcd=true;        //Display Trendlike AB=CD #2
input bool Show_perfect_abcd=true;           //Display Perfect AB=CD
input bool Show_ideal1_abcd=true;            //Display Ideal AB=CD #1
input bool Show_ideal2_abcd=true;            //Display Ideal AB=CD #2
input bool Show_rangelike_abcd=true;         //Display Rangelike AB=CD
input bool Show_alt127_trendlike1_abcd=true; //Display Trendlike 1.27 AB=CD #1
input bool Show_alt127_trendlike2_abcd=true; //Display Trendlike 1.27 AB=CD #2
input bool Show_alt127_perfect_abcd=true;    //Display Perfect 1.27 AB=CD
input bool Show_alt127_ideal1_abcd=true;     //Display Ideal 1.27 AB=CD #1
input bool Show_alt127_ideal2_abcd=true;     //Display Ideal 1.27 AB=CD #2
input bool Show_alt127_rangelike_abcd=true;  //Display Rangelike 1.27 AB=CD
input bool Show_rec_trendlike1_abcd=true;    //Display Rec. Trendlike AB=CD #1
input bool Show_rec_trendlike2_abcd=true;    //Display Rec. Trendlike AB=CD #2
input bool Show_rec_perfect_abcd=true;       //Display Rec. Perfect AB=CD
input bool Show_rec_ideal1_abcd=true;        //Display Rec. Ideal AB=CD #1
input bool Show_rec_ideal2_abcd=true;        //Display Rec. Ideal AB=CD #2
input bool Show_rec_rangelike_abcd=true;     //Display Rec. Rangelike AB=CD
input bool Show_gartley=true;                //Display Gartley
input bool Show_bat=true;                    //Display Bat
input bool Show_altbat=true;                 //Display Alt. Bat
input bool Show_fiveo=true;                  //Display 5-0
input bool Show_butterfly=true;              //Display Butterfly
input bool Show_crab=true;                   //Display Crab
input bool Show_deepcrab=true;               //Display Deepcrab
input bool Show_threedrives=true;            //Display Three Drives
input bool Show_cypher=true;                 //Display Cypher
input bool Show_shark=true;                  //Display Shark
input bool Show_nenstar=true;                //Display Nen Star
input bool Show_blackswan=true;              //Display Black Swan
input bool Show_whiteswan=true;              //Display White Swan
input bool Show_one2one=true;                //Display One2One
input bool Show_newCypher=true;              //Display New Cypher
input bool Show_navarro200=true;             //Display Navarro 200
input bool Show_leonardo=true;               //Display Leonardo
input bool Show_kane=true;                   //Display Kane
input bool Show_garfly=true;                 //Display Garfly
input bool Show_maxbat=true;                 //Display Max. Bat
input bool Show_maxgartley=true;             //Display Max. Gartley
input bool Show_maxbutterfly=true;           //Display Max. Butterfly
input bool Show_gartley113=true;             //Display Gartley 113
input bool Show_butterfly113=true;           //Display Butterfly 113
input bool Show_antigartley=true;            //Display Anti Gartley
input bool Show_antibat=true;                //Display Anti Bat
input bool Show_antialtbat=true;             //Display Anti Alt. Bat
input bool Show_antifiveo=true;              //Display Anti 5-0
input bool Show_antibutterfly=true;          //Display Anti Butterfly
input bool Show_anticrab=true;               //Display Anti Crab
input bool Show_antideepcrab=true;           //Display Anti Deepcrab
input bool Show_antithreedrives=true;        //Display Anti Three Drives
input bool Show_anticypher=true;             //Display Anti Cypher
input bool Show_antishark=true;              //Display Anti Shark
input bool Show_antinenstar=true;            //Display Anti Nen Star
input bool Show_antiblackswan=true;          //Display Anti Black Swan
input bool Show_antiwhiteswan=true;          //Display Anti White Swan
input bool Show_antione2one=true;            //Display Anti One2One
input bool Show_antinewCypher=true;          //Display Anti New Cypher
input bool Show_antinavarro200=true;         //Display Anti Navarro 200
input bool Show_antileonardo=true;           //Display Anti Leonardo
input bool Show_antikane=true;               //Display Anti Kane
input bool Show_antigarfly=true;             //Display Anti Garfly
input bool Show_antimaxbat=true;             //Display Anti Max. Bat
input bool Show_antimaxgartley=true;         //Display Anti Max. Gartley
input bool Show_antimaxbutterfly=true;       //Display Anti Max. Butterfly
input bool Show_antigartley113=true;         //Display Anti Gartley 113
input bool Show_antibutterfly113=true;       //Display Anti Butterfly 113
//--- Indicator buffer arrays
double peaks[],troughs[];

//--- Globals
bool _lastDirection;
double _lastPeakValue;
double _lastTroughValue;
int _lastPeak;
int _lastTrough;
int _patternInstanceCounter;
int _maxPatternInstances;
int _projectionInstanceCounter;
int _maxProjectionInstances;
int _drawnProjectionInstanceCounter;
int _maxDrawnProjectionInstances;
int _zzHandle;
PATTERN_INSTANCE _patternInstances[];
PATTERN_INSTANCE _projectionInstances[];
PATTERN_INSTANCE _drawnProjectionInstances[];
PATTERN_DESCRIPTOR _patterns[];
string _patternNames[];
int _patternCounter[];
datetime _patternX[][SIZE_PATTERN_BUFFER];
datetime _patternA[][SIZE_PATTERN_BUFFER];
datetime _patternB[][SIZE_PATTERN_BUFFER];
datetime _patternC[][SIZE_PATTERN_BUFFER];
datetime _patternD[][SIZE_PATTERN_BUFFER];
string com1="",com2="",com3="",com4="",com5="",com6="",com7="",com8="",com9="";
int _timeOfInit;
//+------------------------------------------------------------------+
//| Indicator initialization function                                |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,peaks,INDICATOR_DATA);
   SetIndexBuffer(1,troughs,INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//--- memory
   switch(zztype)
     {
      case FASTZZ:
         _zzHandle=iCustom(NULL,0,"Downloads\\fastzz",SwingSize);
         break;
      case ALEXSTAL:
         _zzHandle=iCustom(NULL,0,"Downloads\\alexstal_zigzagprof",zzperiod,zzamplitude,zzminmotion,true);
         break;
      case SWINGCHART:
         default:
         _zzHandle=iCustom(NULL,0,"Downloads\\swingchart");
     }
   if(_zzHandle==INVALID_HANDLE)
     {
      printf("Error obtaining handle");
      return(INIT_FAILED);
     }
   MathSrand(GetTickCount());
   _timeOfInit=MathRand();
   for(int i=ObjectsTotal(0,0,-1)-1; i>=0; i--)
     {
      string name=ObjectName(0,i,0,-1);
      if(StringFind(name,"U "+_identifier)!=-1 || StringFind(name,"D "+_identifier)!=-1)
         ObjectDelete(0,name);
     }
   return PopulatePatterns();
  }
//+------------------------------------------------------------------+
//| Indicator deinitialization function                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   OnReinit();
   Comment("");
   ArrayFree(_patterns);
   ArrayFree(_patternInstances);
   ArrayFree(_projectionInstances);
   ArrayFree(_drawnProjectionInstances);
   ArrayFree(_patternNames);
   ArrayFree(_patternCounter);
   ArrayFree(_patternX);
   ArrayFree(_patternA);
   ArrayFree(_patternB);
   ArrayFree(_patternC);
   ArrayFree(_patternD);
  }
//+------------------------------------------------------------------+
//| Indicator reinitialization function                              |
//+------------------------------------------------------------------+
void OnReinit()
  {
//----
   _lastPeak=0;
   _lastTrough=0;
   _lastPeakValue=0;
   _lastTroughValue=0;
   _patternInstanceCounter=0;
   _drawnProjectionInstanceCounter=0;
   ArrayFill(_patternCounter,0,NUM_PATTERNS,0);
   for(int i=0; i<NUM_PATTERNS; i++)
     {
      for(int j=0; j<SIZE_PATTERN_BUFFER; j++)
        {
         _patternX[i][j]=0;
         _patternA[i][j]=0;
         _patternB[i][j]=0;
         _patternC[i][j]=0;
         _patternD[i][j]=0;
        }
     }
   for(int i=ObjectsTotal(0,0,-1)-1; i>=0; i--)
     {
      string name=ObjectName(0,i,0,-1);
      if(StringFind(name,"U "+_identifier+StringFormat("%x",_timeOfInit))!=-1 || StringFind(name,"D "+_identifier+StringFormat("%x",_timeOfInit))!=-1)
         ObjectDelete(0,name);
     }
  }
//+------------------------------------------------------------------+
//| Indicator iteration function                                     |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   int start=0;
   if(prev_calculated>rates_total || prev_calculated<=0)
      OnReinit();
   else
      start=prev_calculated-1;
   start=MathMax(1,start);
//--- copy data
   if(BarsCalculated(_zzHandle)<rates_total)
     {
      printf("ZigZag not calculated: "+IntegerToString(GetLastError()));
      return 0;
     }
   if(CopyBuffer(_zzHandle,0,0,rates_total,peaks)<=0)
     {
      printf("ZigZag peaks not copied: "+IntegerToString(GetLastError()));
      return 0;
     }
   if(CopyBuffer(_zzHandle,1,0,rates_total,troughs)<=0)
     {
      printf("ZigZag troughs not copied: "+IntegerToString(GetLastError()));
      return 0;
     }
//--- main loop
   for(int bar=start; bar<rates_total && !IsStopped(); bar++)
     {
      //--- Efficency checks
      if(bar<rates_total-History)
         continue;
      int lastPeak=FirstNonZeroFrom(bar,peaks);
      int lastTrough=FirstNonZeroFrom(bar,troughs);
      if(lastPeak==-1 || lastTrough==-1)
         continue;
      double lastPeakValue=peaks[lastPeak];
      double lastTroughValue=troughs[lastTrough];
      if(lastPeakValue==_lastPeakValue && lastTroughValue==_lastTroughValue)
         continue;
      //--- ZZ assessment
      bool endsInTrough=lastTrough>lastPeak;
      if(lastTrough==lastPeak)
        {
         int zzDirection=ZigZagDirection(lastPeak);
         if(zzDirection==0) continue;
         else if(zzDirection==-1) endsInTrough=true;
         else if(zzDirection==1) endsInTrough=false;
        }
      //--- Remove old projections
      UndisplayProjections();
      //--- Remove old patterns (on ZZ swing continuation) or store them (on new ZZ direction)
      if(_lastDirection==endsInTrough && !(_lastPeak<lastPeak && _lastTrough<lastTrough))
         UndisplayPatterns();
      else for(int i=0; i<_patternInstanceCounter; i++)
        {
         PATTERN_INSTANCE instance=_patternInstances[i];
         int k=instance.patternIndex;
         bool bullish=instance.bullish;
         datetime XDateTime=instance.XDateTime;
         datetime ADateTime=instance.ADateTime;
         datetime BDateTime=instance.BDateTime;
         datetime CDateTime=instance.CDateTime;
         datetime DDateTime=instance.DDateTime;
         StoreOverlaps(k,XDateTime,ADateTime,BDateTime,CDateTime,DDateTime);
        }
      if(Show_PRZ)
         UndisplayPRZs();
      _patternInstanceCounter=0;
      //--- Save most recent peaks/troughs and direction
      _lastPeak=lastPeak;
      _lastTrough=lastTrough;
      _lastPeakValue=lastPeakValue;
      _lastTroughValue=lastTroughValue;
      _lastDirection=endsInTrough;
      //--- Check each pattern for matches
      for(int patternIndex=0; patternIndex<NUM_PATTERNS && !IsStopped(); patternIndex++)
        {
         //--- Check if pattern should be displayed
         if(patternIndex==TRENDLIKE1_ABCD && (!Show_trendlike1_abcd || !Show_abcd)) continue;
         if(patternIndex==TRENDLIKE2_ABCD && (!Show_trendlike2_abcd || !Show_abcd)) continue;
         if(patternIndex==PERFECT_ABCD && (!Show_perfect_abcd || !Show_abcd)) continue;
         if(patternIndex==IDEAL1_ABCD && (!Show_ideal1_abcd || !Show_abcd)) continue;
         if(patternIndex==IDEAL2_ABCD && (!Show_ideal2_abcd || !Show_abcd)) continue;
         if(patternIndex==RANGELIKE_ABCD && (!Show_rangelike_abcd || !Show_abcd)) continue;
         if(patternIndex==ALT127_TRENDLIKE1_ABCD && (!Show_alt127_trendlike1_abcd || !Show_alt127_abcd)) continue;
         if(patternIndex==ALT127_TRENDLIKE2_ABCD && (!Show_alt127_trendlike2_abcd || !Show_alt127_abcd)) continue;
         if(patternIndex==ALT127_PERFECT_ABCD && (!Show_alt127_perfect_abcd || !Show_alt127_abcd)) continue;
         if(patternIndex==ALT127_IDEAL1_ABCD && (!Show_alt127_ideal1_abcd || !Show_alt127_abcd)) continue;
         if(patternIndex==ALT127_IDEAL2_ABCD && (!Show_alt127_ideal2_abcd || !Show_alt127_abcd)) continue;
         if(patternIndex==ALT127_RANGELIKE_ABCD && (!Show_alt127_rangelike_abcd || !Show_alt127_abcd)) continue;
         if(patternIndex==REC_TRENDLIKE1_ABCD && (!Show_rec_trendlike1_abcd || !Show_rec_abcd)) continue;
         if(patternIndex==REC_TRENDLIKE2_ABCD && (!Show_rec_trendlike2_abcd || !Show_rec_abcd)) continue;
         if(patternIndex==REC_PERFECT_ABCD && (!Show_rec_perfect_abcd || !Show_rec_abcd)) continue;
         if(patternIndex==REC_IDEAL1_ABCD && (!Show_rec_ideal1_abcd || !Show_rec_abcd)) continue;
         if(patternIndex==REC_IDEAL2_ABCD && (!Show_rec_ideal2_abcd || !Show_rec_abcd)) continue;
         if(patternIndex==REC_RANGELIKE_ABCD && (!Show_rec_rangelike_abcd || !Show_rec_abcd)) continue;
         if(patternIndex==GARTLEY && (!Show_gartley || !Show_patterns)) continue;
         if(patternIndex==BAT && (!Show_bat || !Show_patterns)) continue;
         if(patternIndex==ALTBAT && (!Show_altbat || !Show_patterns)) continue;
         if(patternIndex==FIVEO && (!Show_fiveo || !Show_patterns)) continue;
         if(patternIndex==BUTTERFLY && (!Show_butterfly || !Show_patterns)) continue;
         if(patternIndex==CRAB && (!Show_crab || !Show_patterns)) continue;
         if(patternIndex==DEEPCRAB && (!Show_deepcrab || !Show_patterns)) continue;
         if(patternIndex==THREEDRIVES && (!Show_threedrives || !Show_patterns)) continue;
         if(patternIndex==CYPHER && (!Show_cypher || !Show_patterns)) continue;
         if(patternIndex==SHARK && (!Show_shark || !Show_patterns)) continue;
         if(patternIndex==NENSTAR && (!Show_nenstar || !Show_patterns)) continue;
         if(patternIndex==BLACKSWAN && (!Show_blackswan || !Show_patterns)) continue;
         if(patternIndex==WHITESWAN && (!Show_whiteswan || !Show_patterns)) continue;
         if(patternIndex==ONE2ONE && (!Show_one2one || !Show_patterns)) continue;
         if(patternIndex==NEWCYPHER && (!Show_newCypher || !Show_patterns)) continue;
         if(patternIndex==NAVARRO200 && (!Show_navarro200 || !Show_patterns)) continue;
         if(patternIndex==LEONARDO && (!Show_leonardo || !Show_patterns)) continue;
         if(patternIndex==KANE && (!Show_kane || !Show_patterns)) continue;
         if(patternIndex==GARFLY && (!Show_garfly || !Show_patterns)) continue;
         if(patternIndex==MAXBAT && (!Show_maxbat || !Show_patterns)) continue;
         if(patternIndex==MAXGARTLEY && (!Show_maxgartley || !Show_patterns)) continue;
         if(patternIndex==MAXBUTTERFLY && (!Show_maxbutterfly || !Show_patterns)) continue;
         if(patternIndex==GARTLEY113 && (!Show_gartley113 || !Show_patterns)) continue;
         if(patternIndex==BUTTERFLY113 && (!Show_butterfly113 || !Show_patterns)) continue;
         if(patternIndex==ANTI_GARTLEY && (!Show_antigartley || !Show_antipatterns)) continue;
         if(patternIndex==ANTI_BAT && (!Show_antibat || !Show_antipatterns)) continue;
         if(patternIndex==ANTI_ALTBAT && (!Show_antialtbat || !Show_antipatterns)) continue;
         if(patternIndex==ANTI_FIVEO && (!Show_antifiveo || !Show_antipatterns)) continue;
         if(patternIndex==ANTI_BUTTERFLY && (!Show_antibutterfly || !Show_antipatterns)) continue;
         if(patternIndex==ANTI_CRAB && (!Show_anticrab || !Show_antipatterns)) continue;
         if(patternIndex==ANTI_DEEPCRAB && (!Show_antideepcrab || !Show_antipatterns)) continue;
         if(patternIndex==ANTI_THREEDRIVES && (!Show_antithreedrives || !Show_antipatterns)) continue;
         if(patternIndex==ANTI_CYPHER && (!Show_anticypher || !Show_antipatterns)) continue;
         if(patternIndex==ANTI_SHARK && (!Show_antishark || !Show_antipatterns)) continue;
         if(patternIndex==ANTI_NENSTAR && (!Show_antinenstar || !Show_antipatterns)) continue;
         if(patternIndex==ANTI_BLACKSWAN && (!Show_antiblackswan || !Show_antipatterns)) continue;
         if(patternIndex==ANTI_WHITESWAN && (!Show_antiwhiteswan || !Show_antipatterns)) continue;
         if(patternIndex==ANTI_ONE2ONE && (!Show_antione2one || !Show_antipatterns)) continue;
         if(patternIndex==ANTI_NEWCYPHER && (!Show_antinewCypher || !Show_antipatterns)) continue;
         if(patternIndex==ANTI_NAVARRO200 && (!Show_antinavarro200 || !Show_antipatterns)) continue;
         if(patternIndex==ANTI_LEONARDO && (!Show_antileonardo || !Show_antipatterns)) continue;
         if(patternIndex==ANTI_KANE && (!Show_antikane || !Show_antipatterns)) continue;
         if(patternIndex==ANTI_GARFLY && (!Show_antigarfly || !Show_antipatterns)) continue;
         if(patternIndex==ANTI_MAXBAT && (!Show_antimaxbat || !Show_antipatterns)) continue;
         if(patternIndex==ANTI_MAXGARTLEY && (!Show_antimaxgartley || !Show_antipatterns)) continue;
         if(patternIndex==ANTI_MAXBUTTERFLY && (!Show_antimaxbutterfly || !Show_antipatterns)) continue;
         if(patternIndex==ANTI_GARTLEY113 && (!Show_antigartley113 || !Show_antipatterns)) continue;
         if(patternIndex==ANTI_BUTTERFLY113 && (!Show_antibutterfly113 || !Show_antipatterns)) continue;
         PATTERN_DESCRIPTOR pattern=_patterns[patternIndex];
         //--- What constraints does the pattern have?
         bool ab2xaConstraint=pattern.ab2xa_max!=0 && pattern.ab2xa_min!=0;
         bool ad2xaConstraint=pattern.ad2xa_max!=0 && pattern.ad2xa_min!=0;
         bool bc2abConstraint=pattern.bc2ab_max!=0 && pattern.bc2ab_min!=0;
         bool cd2bcConstraint=pattern.cd2bc_max!=0 && pattern.cd2bc_min!=0;
         bool cd2xcConstraint=pattern.cd2xc_max!=0 && pattern.cd2xc_min!=0;
         bool xc2xaConstraint=pattern.xc2xa_max!=0 && pattern.xc2xa_min!=0;
         bool cd2abConstraint=pattern.cd2ab_max!=0 && pattern.cd2ab_min!=0;
         //--- Which constraints are unary vs range?
         double ab2xaSlack=pattern.ab2xa_max==pattern.ab2xa_min ? SlackUnary : SlackRange;
         double ad2xaSlack=pattern.ad2xa_max==pattern.ad2xa_min ? SlackUnary : SlackRange;
         double bc2abSlack=pattern.bc2ab_max==pattern.bc2ab_min ? SlackUnary : SlackRange;
         double cd2bcSlack=pattern.cd2bc_max==pattern.cd2bc_min ? SlackUnary : SlackRange;
         double cd2xcSlack=pattern.cd2xc_max==pattern.cd2xc_min ? SlackUnary : SlackRange;
         double xc2xaSlack=pattern.xc2xa_max==pattern.xc2xa_min ? SlackUnary : SlackRange;
         double cd2abSlack=pattern.cd2ab_max==pattern.cd2ab_min ? SlackUnary : SlackRange;
         //--- Start searching from current bar - 'BarsAnalyzed'
         _projectionInstanceCounter=0;
         bool xFirstRun=true;
         for(int XIndex=bar-BarsAnalyzed; XIndex<=bar && !IsStopped(); XIndex++)
           {
            if(XIndex<=0)
               continue;
            bool isPeak=IsProperValue(peaks[XIndex]);
            bool isTrough=IsProperValue(troughs[XIndex]);
            if(!isPeak && !isTrough)
               continue;
            bool startsInTrough=isTrough;
            bool xVerticalZZ=isPeak && isTrough;
            bool xZZDirection=!startsInTrough;
            if(xVerticalZZ)
              {
               if(xFirstRun)
                  startsInTrough=!startsInTrough;
               int zzDirection=ZigZagDirection(XIndex);
               if(zzDirection==0) continue;
               else if(zzDirection==-1) xZZDirection=false;
               else if(zzDirection==1) xZZDirection=true;
              }
            double X=startsInTrough ? troughs[XIndex]: peaks[XIndex];
            double extremeA=startsInTrough ? DBL_MIN : DBL_MAX;
            //--- Skip first AIndex if vertical zz at X and opposite extremum is before X 
            int aSkip=0;
            if(xVerticalZZ && ((xZZDirection && !startsInTrough) || (!xZZDirection && startsInTrough))) aSkip=1;
            for(int AIndex=XIndex+aSkip; AIndex<=bar && !IsStopped(); AIndex++)
              {
               //--- Ensure that X is the extremum on [X, A], i.e. there is no lower low (higher high)
               int extremeIndexXA=XIndex==AIndex ? AIndex : AIndex-1;
               if((startsInTrough && IsProperValue(troughs[extremeIndexXA]) && troughs[extremeIndexXA]<X)
                  || (!startsInTrough && IsProperValue(peaks[extremeIndexXA]) && peaks[extremeIndexXA]>X))
                  break;
               if((XIndex!=AIndex && IsProperValue(troughs[AIndex]) && IsProperValue(peaks[AIndex]))
                  && ((startsInTrough && ZigZagDirection(AIndex)==1 && troughs[AIndex]<X)
                  || (!startsInTrough && ZigZagDirection(AIndex)==-1 && peaks[AIndex]>X)))
                  break;
               //--- Only check increasing (decreasing) A's
               double A=startsInTrough ? peaks[AIndex]: troughs[AIndex];
               if(!IsProperValue(A) || (startsInTrough && A<extremeA) || (!startsInTrough && A>extremeA))
                  continue;
               extremeA=A;
               //--- For ratios
               double XA=MathAbs(A-X);
               if(XA==0)
                  continue;
               //--- Find B index
               double extremeB=startsInTrough ? DBL_MAX : DBL_MIN;
               //--- Skip first BIndex if vertical zz at X and both X and A is on it
               int bSkip=0;
               if(XIndex==AIndex) bSkip=1;
               for(int BIndex=AIndex+bSkip; BIndex<=bar && !IsStopped(); BIndex++)
                 {
                  //--- Ensure that A is the extremum on [A, B], i.e. there is no higher high (lower low)
                  int extremeIndexAB=AIndex==BIndex ? BIndex : BIndex-1;
                  if((!startsInTrough && IsProperValue(troughs[extremeIndexAB]) && troughs[extremeIndexAB]<A)
                     || (startsInTrough && IsProperValue(peaks[extremeIndexAB]) && peaks[extremeIndexAB]>A))
                     break;
                  if((AIndex!=BIndex && IsProperValue(troughs[BIndex]) && IsProperValue(peaks[BIndex]))
                     && ((!startsInTrough && ZigZagDirection(BIndex)==1  &&  troughs[BIndex]<A)
                     || (startsInTrough  &&  ZigZagDirection(BIndex)==-1  &&  peaks[BIndex]>A)))
                     break;
                  //--- Only check decreasing (increasing) B's
                  double B=startsInTrough ? troughs[BIndex]: peaks[BIndex];
                  if(!IsProperValue(B) || (startsInTrough && B>extremeB) || (!startsInTrough && B<extremeB))
                     continue;
                  extremeB=B;
                  //--- Second check for vertical ZZ at AB leg and B comes before A
                  if(AIndex==BIndex)
                    {
                     int zzDirection=ZigZagDirection(AIndex);
                     if(zzDirection==0) continue;
                     else if(zzDirection==-1 && !startsInTrough) continue;
                     else if(zzDirection==1 && startsInTrough) continue;
                    }
                  //--- Ratios
                  double AB=MathAbs(A-B);
                  if(AB==0)
                     continue;
                  double ab2xaRatio=AB/XA;
                  //--- Possible analytical continue: B does not extend far enough evidenced by 'ab2xaRatio' being too short
                  bool ab2xaContinue=ab2xaConstraint;
                  ab2xaContinue&=ab2xaRatio<pattern.ab2xa_min-ab2xaSlack;
                  if(ab2xaContinue)
                     continue;
                  //--- Possible analytical cutoff: B extends too far evidenced by 'ab2xaRatio' being too large
                  bool ab2xaCutoff=ab2xaConstraint;
                  ab2xaCutoff&=ab2xaRatio>pattern.ab2xa_max+ab2xaSlack;
                  if(ab2xaCutoff)
                     break;
                  //--- Find C
                  double extremeC=startsInTrough ? DBL_MIN : DBL_MAX;
                  //--- Skip first CIndex if vertical zz at B and both A and B is on it
                  int cSkip=0;
                  if(AIndex==BIndex) cSkip = 1;
                  for(int CIndex=BIndex+cSkip; CIndex<=bar && !IsStopped(); CIndex++)
                    {
                     //--- Ensure that B is the extremum on [B, C], i.e. there is no lower low (higher high)
                     int extremeIndexBC=BIndex==CIndex ? CIndex : CIndex-1;
                     if((startsInTrough && IsProperValue(troughs[extremeIndexBC]) && troughs[extremeIndexBC]<B)
                        || (!startsInTrough && IsProperValue(peaks[extremeIndexBC]) && peaks[extremeIndexBC]>B))
                        break;
                     if((BIndex!=CIndex && IsProperValue(troughs[CIndex]) && IsProperValue(peaks[CIndex]))
                        && ((startsInTrough && ZigZagDirection(CIndex)==1 && troughs[CIndex]<B)
                        || (!startsInTrough && ZigZagDirection(CIndex)==-1 && peaks[CIndex]>B)))
                        break;
                     //--- Only check increasing (decreasing) C's
                     double C=startsInTrough ? peaks[CIndex]: troughs[CIndex];
                     if(!IsProperValue(C))
                        continue;
                     if((startsInTrough && C<extremeC) || (!startsInTrough && C>extremeC))
                        continue;
                     extremeC=C;
                     //--- Second check for vertical ZZ at BC leg and C comes before B
                     if(BIndex==CIndex)
                       {
                        int zzDirection=ZigZagDirection(BIndex);
                        if(zzDirection==0) continue;
                        else if(zzDirection==-1 && startsInTrough) continue;
                        else if(zzDirection==1 && !startsInTrough) continue;
                       }
                     //--- Ratios
                     double BC=MathAbs(C-B);
                     double XC=MathAbs(X-C);
                     if(BC==0) continue;
                     if(XC==0) continue;
                     double bc2abRatio=BC/AB;
                     double xc2xaRatio=XC/XA;
                     //--- Analytical continue: C not far enough by short 'bc2abRatio' or 'xc2xaRatio'
                     bool bc2abContinue=bc2abConstraint;
                     bool xc2xaContinue=xc2xaConstraint;
                     bc2abContinue&=bc2abRatio<pattern.bc2ab_min-bc2abSlack;
                     xc2xaContinue&=xc2xaRatio<pattern.xc2xa_min-xc2xaSlack;
                     if(bc2abContinue || xc2xaContinue)
                        continue;
                     //--- Analytical cutoff: C too far by long 'bc2abRatio' or 'xc2xaRatio'
                     bool bc2abCutoff=bc2abConstraint;
                     bool xc2xaCutoff=xc2xaConstraint;
                     bc2abCutoff&=bc2abRatio>pattern.bc2ab_max+bc2abSlack;
                     xc2xaCutoff&=xc2xaRatio>pattern.xc2xa_max+xc2xaSlack;
                     if(bc2abCutoff || xc2xaCutoff)
                        break;
                     //--- Check if C is the extreme until end-of-search, only then it should be used to project
                     bool lastExtremeC=true;
                     for(int i=CIndex+1; i<=bar; i++)
                       {
                        if((startsInTrough && IsProperValue(peaks[i]) && peaks[i]>C)
                           || (!startsInTrough && IsProperValue(troughs[i]) && troughs[i]<C))
                          {
                           lastExtremeC=false;
                           break;
                          }
                       }
                     //--- Find D
                     double extremeD=startsInTrough ? DBL_MAX : DBL_MIN;
                     //--- Skip first DIndex if vertical zz at C and both B and C is on it
                     int dSkip=0;
                     if(BIndex==CIndex) dSkip = 1;
                     for(int DIndex=CIndex+dSkip; DIndex<=bar && !IsStopped(); DIndex++)
                       {
                        //--- Ensure that C is the extremum on [C, D], i.e. there is no higher high (lower low)
                        int extremeIndexCD=CIndex==DIndex ? DIndex : DIndex-1;
                        if((!startsInTrough && IsProperValue(troughs[extremeIndexCD]) && troughs[extremeIndexCD]<C)
                           || (startsInTrough && IsProperValue(peaks[extremeIndexCD]) && peaks[extremeIndexCD]>C))
                           break;
                        if((CIndex!=DIndex && IsProperValue(troughs[DIndex]) && IsProperValue(peaks[DIndex]))
                           && ((!startsInTrough && ZigZagDirection(DIndex)==1  &&  troughs[DIndex]<C)
                           || (startsInTrough  &&  ZigZagDirection(DIndex)==-1  &&  peaks[DIndex]>C)))
                           break;
                        //--- If CIndex is last, use imaginary D for projections
                        bool imaginaryD=((startsInTrough && CIndex==lastPeak && lastTrough<=lastPeak)
                                         || (!startsInTrough && CIndex==lastTrough && lastPeak<=lastTrough));
                        if(imaginaryD && lastPeak==lastTrough)
                           imaginaryD &=(startsInTrough && ZigZagDirection(lastPeak)==1)
                                        || (!startsInTrough && ZigZagDirection(lastPeak)==-1);
                        //--- Only check decreasing (increasing) D's
                        double D=startsInTrough ? troughs[DIndex]: peaks[DIndex];
                        if(!imaginaryD && (!IsProperValue(D) || (startsInTrough && D>extremeD) || (!startsInTrough && D<extremeD)))
                           continue;
                        extremeD=D;
                        //--- Second check for vertical ZZ at CD leg and D comes before C
                        if(!imaginaryD && CIndex==DIndex)
                          {
                           int zzDirection=ZigZagDirection(CIndex);
                           if(zzDirection==0) continue;
                           else if(zzDirection==-1 && !startsInTrough) continue;
                           else if(zzDirection==1 && startsInTrough) continue;
                          }
                        //--- Check if D is the extreme until end-of-search, only then it should be used to project
                        bool lastExtremeD=true;
                        if(!imaginaryD)
                          {
                           for(int i=DIndex+1; i<=bar; i++)
                             {
                              if((!startsInTrough && IsProperValue(peaks[i]) && peaks[i]>D)
                                 || (startsInTrough && IsProperValue(troughs[i]) && troughs[i]<D))
                                {
                                 lastExtremeD=false;
                                 break;
                                }
                             }
                          }
                        //--- Check if potential pattern is on active swing (rightmost on chart)
                        bool activeSwing=((endsInTrough && startsInTrough && DIndex==lastTrough) || (!endsInTrough && !startsInTrough && DIndex==lastPeak));
                        //--- Analytical solution to harmonic window
                        double nearD_cd2bc;
                        double nearD_ad2xa;
                        double nearD_cd2xc;
                        double nearD_cd2ab;
                        double farD_cd2bc;
                        double farD_ad2xa;
                        double farD_cd2xc;
                        double farD_cd2ab;
                        if(startsInTrough)
                          {
                           nearD_cd2bc=C-(pattern.cd2bc_min-cd2bcSlack)*BC;
                           nearD_ad2xa=A-(pattern.ad2xa_min-ad2xaSlack)*XA;
                           nearD_cd2xc=C-(pattern.cd2xc_min-cd2xcSlack)*XC;
                           nearD_cd2ab=C-(pattern.cd2ab_min-cd2abSlack)*AB;
                           farD_cd2bc=C-(pattern.cd2bc_max+cd2bcSlack)*BC;
                           farD_ad2xa=A-(pattern.ad2xa_max+ad2xaSlack)*XA;
                           farD_cd2xc=C-(pattern.cd2xc_max+cd2xcSlack)*XC;
                           farD_cd2ab=C-(pattern.cd2ab_max+cd2abSlack)*AB;
                          }
                        else
                          {
                           nearD_cd2bc=C+(pattern.cd2bc_min-cd2bcSlack)*BC;
                           nearD_ad2xa=A+(pattern.ad2xa_min-ad2xaSlack)*XA;
                           nearD_cd2xc=C+(pattern.cd2xc_min-cd2xcSlack)*XC;
                           nearD_cd2ab=C+(pattern.cd2ab_min-cd2abSlack)*AB;
                           farD_cd2bc=C+(pattern.cd2bc_max+cd2bcSlack)*BC;
                           farD_ad2xa=A+(pattern.ad2xa_max+ad2xaSlack)*XA;
                           farD_cd2xc=C+(pattern.cd2xc_max+cd2xcSlack)*XC;
                           farD_cd2ab=C+(pattern.cd2ab_max+cd2abSlack)*AB;
                          }
                        double nearD=startsInTrough ? DBL_MAX : DBL_MIN;
                        double farD=startsInTrough ? DBL_MIN : DBL_MAX;
                        if(cd2bcConstraint)
                          {
                           nearD=startsInTrough ? MathMin(nearD,nearD_cd2bc) : MathMax(nearD,nearD_cd2bc);
                           farD=startsInTrough ? MathMax(farD,farD_cd2bc) : MathMin(farD,farD_cd2bc);
                          }
                        if(ad2xaConstraint)
                          {
                           nearD=startsInTrough ? MathMin(nearD,nearD_ad2xa) : MathMax(nearD,nearD_ad2xa);
                           farD=startsInTrough ? MathMax(farD,farD_ad2xa) : MathMin(farD,farD_ad2xa);
                          }
                        if(cd2xcConstraint)
                          {
                           nearD=startsInTrough ? MathMin(nearD,nearD_cd2xc) : MathMax(nearD,nearD_cd2xc);
                           farD=startsInTrough ? MathMax(farD,farD_cd2xc) : MathMin(farD,farD_cd2xc);
                          }
                        if(cd2abConstraint)
                          {
                           nearD=startsInTrough ? MathMin(nearD,nearD_cd2ab) : MathMax(nearD,nearD_cd2ab);
                           farD=startsInTrough ? MathMax(farD,farD_cd2ab) : MathMin(farD,farD_cd2ab);
                          }
                        //--- Imaginary D only used when no further D's can exist
                        if(imaginaryD && !OneAheadProjection)
                           break;
                        //--- Continue/Pattern undershot
                        else if(imaginaryD || (startsInTrough && D>nearD) || (!startsInTrough && D<nearD))
                          {
                           //--- The XABC are such that no D can satisfy the pattern
                           if((startsInTrough && farD>nearD) || (!startsInTrough && farD<nearD))
                              break;
                           //--- In these two cases, a match or overshot pattern can occur later
                           if(!lastExtremeC || !lastExtremeD)
                              continue;
                           if(!EmergingPatterns)
                              break;
                           //--- 4-point
                           if(Is4PointPattern(patternIndex))
                              StoreProjection(patternIndex,startsInTrough,0,0,time[AIndex],A,time[BIndex],B,time[CIndex],C,time[bar],nearD,farD);
                           //--- 5-point
                           else
                              StoreProjection(patternIndex,startsInTrough,time[XIndex],X,time[AIndex],A,time[BIndex],B,time[CIndex],C,time[bar],nearD,farD);
                           break;
                          }
                        //--- Cutoff
                        else if((startsInTrough && D<farD) || (!startsInTrough && D>farD))
                           break;
                        //--- Match
                        else
                          {
                           //--- Invalidate if overlapping
                           if(Overlaps(patternIndex,time[XIndex],time[AIndex],time[BIndex],time[CIndex],time[DIndex]))
                              continue;
                           //--- 4-point
                           if(Is4PointPattern(patternIndex))
                             {
                              DisplayPattern(patternIndex,startsInTrough,time[AIndex],A,time[BIndex],B,time[CIndex],C,time[DIndex],D);
                              if(activeSwing)
                                {
                                 StorePattern(patternIndex,startsInTrough,0,time[AIndex],time[BIndex],time[CIndex],time[DIndex]);
                                 if(Show_PRZ)
                                    DisplayPRZ(patternIndex,startsInTrough,time[AIndex],A,time[BIndex],time[CIndex],C,time[DIndex],D,farD);
                                }
                              else
                                 StoreOverlaps(patternIndex,0,time[AIndex],time[BIndex],time[CIndex],time[DIndex]);
                             }
                           //--- 5-point
                           else
                             {
                              DisplayPattern(patternIndex,startsInTrough,time[XIndex],X,time[AIndex],A,time[BIndex],B,time[CIndex],C,time[DIndex],D);
                              if(activeSwing)
                                {
                                 StorePattern(patternIndex,startsInTrough,time[XIndex],time[AIndex],time[BIndex],time[CIndex],time[DIndex]);
                                 if(Show_PRZ)
                                    DisplayPRZ(patternIndex,startsInTrough,time[XIndex],X,time[AIndex],A,time[BIndex],time[CIndex],C,time[DIndex],D,farD);
                                }
                              else
                                 StoreOverlaps(patternIndex,time[XIndex],time[AIndex],time[BIndex],time[CIndex],time[DIndex]);
                             }
                          }
                       } //--- End DIndex-loop
                    } //--- End CIndex-loop
                 } //--- End BIndex-loop
              } //--- End AIndex-loop
            //--- Run same XIndex twice if ZigZag is vertical
            if(xVerticalZZ)
              {
               if(xFirstRun)
                 {
                  XIndex--;
                  xFirstRun=false;
                 }
               else
                  xFirstRun=true;
              }
           } //--- End XIndex-loop
         //--- Sort projections
         for(int i=1; i<_projectionInstanceCounter; i++)
           {
            _projectionInstances[i].overlapping=false;
            int j=i;
            while(j>0 && _projectionInstances[j-1].D>_projectionInstances[j].D)
              {
               PATTERN_INSTANCE tmp=_projectionInstances[j];
               _projectionInstances[j]=_projectionInstances[j-1];
               _projectionInstances[j-1]=tmp;
               j--;
              }
           }
         _projectionInstances[0].overlapping=false;
         //--- Display projections
         bool forward=true;
         int i=0;
         while(_projectionInstanceCounter!=0)
           {
            bool bullish=_projectionInstances[i].bullish;
            if((forward && !bullish) || (!forward && bullish))
              {
               datetime XDateTime=_projectionInstances[i].XDateTime;
               datetime ADateTime=_projectionInstances[i].ADateTime;
               datetime BDateTime=_projectionInstances[i].BDateTime;
               datetime CDateTime=_projectionInstances[i].CDateTime;
               datetime DDateTime=_projectionInstances[i].DDateTime;
               double X=_projectionInstances[i].X;
               double A=_projectionInstances[i].A;
               double B=_projectionInstances[i].B;
               double C=_projectionInstances[i].C;
               double D=_projectionInstances[i].D;
               double farD=_projectionInstances[i].PRZ;
               //--- Invalidate projection if overlapping other patterns
               if(Overlaps(patternIndex,XDateTime,ADateTime,BDateTime,CDateTime,NON_EXISTENT_DATETIME))
                  _projectionInstances[i].overlapping=true;
               //--- Invalidate projection if overlapping other projections
               int j=i;
               while(true)
                 {
                  //--- Loop condition
                  if(forward)
                    {
                     if(j==0) break;
                     else j--;
                    }
                  else
                    {
                     if(j==_projectionInstanceCounter-1) break;
                     else j++;
                    }
                  //--- Overlap check
                  if(!_projectionInstances[j].overlapping && _projectionInstances[j].bullish==bullish)
                    {
                     datetime XDateTimeActive=_projectionInstances[j].XDateTime;
                     datetime ADateTimeActive=_projectionInstances[j].ADateTime;
                     datetime BDateTimeActive=_projectionInstances[j].BDateTime;
                     datetime CDateTimeActive=_projectionInstances[j].CDateTime;
                     datetime DDateTimeActive=_projectionInstances[j].DDateTime;
                     int numMatches=0;
                     if(!Is4PointPattern(patternIndex) && XDateTime==XDateTimeActive) numMatches++;
                     if(ADateTime==ADateTimeActive) numMatches++;
                     if(BDateTime==BDateTimeActive) numMatches++;
                     if(CDateTime==CDateTimeActive) numMatches++;
                     //if(DDateTime==DDateTimeActive) numMatches++;
                     if(numMatches>MaxSamePoints)
                       {
                        _projectionInstances[i].overlapping=true;
                        break;
                       }
                    }
                 }
               //--- Display projection
               if(!_projectionInstances[i].overlapping)
                 {
                  if(Is4PointPattern(patternIndex))
                     DisplayProjection(patternIndex,bullish,ADateTime,A,BDateTime,B,CDateTime,C,DDateTime,D);
                  else
                     DisplayProjection(patternIndex,bullish,XDateTime,X,ADateTime,A,BDateTime,B,CDateTime,C,DDateTime,D);
                  _drawnProjectionInstances[_drawnProjectionInstanceCounter]=_projectionInstances[i];
                  _drawnProjectionInstanceCounter++;
                  if(_drawnProjectionInstanceCounter>=_maxDrawnProjectionInstances)
                    {
                     _maxDrawnProjectionInstances*=2;
                     if(ArrayResize(_drawnProjectionInstances,_maxDrawnProjectionInstances)<_maxDrawnProjectionInstances)
                        printf("Error allocating array");
                    }
                 }
              }
            //--- Loop condition
            if(forward)
              {
               if(i==_projectionInstanceCounter-1) forward=false;
               else i++;
              }
            else
              {
               if(i==0) break;
               else i--;
              }
           }
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Helper method determines 4 point patterns                        |
//+------------------------------------------------------------------+
bool Is4PointPattern(int patternIndex)
  {
   if(patternIndex == TRENDLIKE1_ABCD) return true;
   if(patternIndex == TRENDLIKE2_ABCD) return true;
   if(patternIndex == PERFECT_ABCD) return true;
   if(patternIndex == IDEAL1_ABCD) return true;
   if(patternIndex == IDEAL2_ABCD) return true;
   if(patternIndex == RANGELIKE_ABCD) return true;
   if(patternIndex == ALT127_TRENDLIKE1_ABCD) return true;
   if(patternIndex == ALT127_TRENDLIKE2_ABCD) return true;
   if(patternIndex == ALT127_PERFECT_ABCD) return true;
   if(patternIndex == ALT127_IDEAL1_ABCD) return true;
   if(patternIndex == ALT127_IDEAL2_ABCD) return true;
   if(patternIndex == ALT127_RANGELIKE_ABCD) return true;
   if(patternIndex == REC_TRENDLIKE1_ABCD) return true;
   if(patternIndex == REC_TRENDLIKE2_ABCD) return true;
   if(patternIndex == REC_PERFECT_ABCD) return true;
   if(patternIndex == REC_IDEAL1_ABCD) return true;
   if(patternIndex == REC_IDEAL2_ABCD) return true;
   if(patternIndex == REC_RANGELIKE_ABCD) return true;
   return false;
  }
//+------------------------------------------------------------------+
//| Helper method finds ZigZag direction in before index             |
//+------------------------------------------------------------------+
int ZigZagDirection(int index)
  {
   int lastPeakBefore=FirstNonZeroFrom(index-1,peaks);
   int lastTroughBefore=FirstNonZeroFrom(index-1,troughs);
   while(lastPeakBefore==lastTroughBefore)
     {
      lastPeakBefore=FirstNonZeroFrom(lastPeakBefore-1,peaks);
      lastTroughBefore=FirstNonZeroFrom(lastTroughBefore-1,troughs);
      if(lastPeakBefore==-1 || lastTroughBefore==-1) return 0;
     }
   if(lastPeakBefore==-1 || lastTroughBefore==-1) return 0;
   else if(lastPeakBefore<lastTroughBefore) return -1;
   else return 1;
  }
//+------------------------------------------------------------------+
//| Helper method finds first proper value from start                |
//+------------------------------------------------------------------+
int FirstNonZeroFrom(int start,double &array[])
  {
   for(int j=start; j>=0; j--)
      if(IsProperValue(array[j]))
         return j;
   return -1;
  }
//+------------------------------------------------------------------+
//| Helper method determines proper value                            |
//+------------------------------------------------------------------+
bool IsProperValue(double value)
  {
   return (value!=0 && value!=EMPTY_VALUE);
  }
//+------------------------------------------------------------------+
//| Comment                                                          |
//+------------------------------------------------------------------+
void ShowComment(string sComment)
  {
   if(sComment!="")
     {
      com9=com8; //--- discards last comment line
      com8=com7; //--- and shifts
      com7=com6;
      com6=com5;
      com5=com4;
      com4=com3;
      com3=com2;
      com2=com1;
      com1=sComment;
     }
   Comment("HarmonicPatternFinderV2 © 2016","\n","\n",com1,"\n",com2,"\n",com3,"\n",com4,"\n",com5,"\n",com6,"\n",com7,"\n",com8,"\n",com9,"\n");
  }
//+------------------------------------------------------------------+
//| Helper method checks if pattern overlaps                         |
//+------------------------------------------------------------------+
bool Overlaps(int k,datetime XDateTime,datetime ADateTime,datetime BDateTime,datetime CDateTime,datetime DDateTime)
  {
   bool overlaps=false;
//--- Check old patterns in fixed size ring buffer
   for(int i=0; i<SIZE_PATTERN_BUFFER; i++)
     {
      int numMatches=0;
      if(!Is4PointPattern(k) && XDateTime==_patternX[k][i]) numMatches++;
      if(ADateTime==_patternA[k][i]) numMatches++;
      if(BDateTime==_patternB[k][i]) numMatches++;
      if(CDateTime==_patternC[k][i]) numMatches++;
      if(DDateTime==_patternD[k][i]) numMatches++;
      if(numMatches>MaxSamePoints)
         return true;
     }
//--- Check active patterns in unlimited size array
   for(int i=0; i<_patternInstanceCounter; i++)
     {
      PATTERN_INSTANCE instance=_patternInstances[i];
      int patternIndexActive=_patternInstances[i].patternIndex;
      if(patternIndexActive!=k)
         continue;
      bool bullish=instance.bullish;
      datetime XDateTimeActive=instance.XDateTime;
      datetime ADateTimeActive=instance.ADateTime;
      datetime BDateTimeActive=instance.BDateTime;
      datetime CDateTimeActive=instance.CDateTime;
      datetime DDateTimeActive=instance.DDateTime;
      int numMatches=0;
      if(!Is4PointPattern(k) && XDateTime==XDateTimeActive) numMatches++;
      if(ADateTime==ADateTimeActive) numMatches++;
      if(BDateTime==BDateTimeActive) numMatches++;
      if(CDateTime==CDateTimeActive) numMatches++;
      if(DDateTime==DDateTimeActive) numMatches++;
      if(numMatches>MaxSamePoints)
         return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Helper method stores if pattern overlaps                         |
//+------------------------------------------------------------------+
void StoreOverlaps(int k,datetime XDateTime,datetime ADateTime,datetime BDateTime,datetime CDateTime,datetime DDateTime)
  {
   int index=_patternCounter[k];
   _patternCounter[k]=(index+1)%SIZE_PATTERN_BUFFER;
   _patternX[k][index]=XDateTime;
   _patternA[k][index]=ADateTime;
   _patternB[k][index]=BDateTime;
   _patternC[k][index]=CDateTime;
   _patternD[k][index]=DDateTime;
  }
//+------------------------------------------------------------------+
//| Helper method stores patterns                                    |
//+------------------------------------------------------------------+
void StorePattern(int k,bool bullish,datetime XDateTime,datetime ADateTime,datetime BDateTime,datetime CDateTime,datetime DDateTime)
  {
   _patternInstances[_patternInstanceCounter].patternIndex=k;
   _patternInstances[_patternInstanceCounter].bullish=bullish;
   _patternInstances[_patternInstanceCounter].XDateTime=XDateTime;
   _patternInstances[_patternInstanceCounter].ADateTime=ADateTime;
   _patternInstances[_patternInstanceCounter].BDateTime=BDateTime;
   _patternInstances[_patternInstanceCounter].CDateTime=CDateTime;
   _patternInstances[_patternInstanceCounter].DDateTime=DDateTime;
   _patternInstanceCounter++;
   if(_patternInstanceCounter>=_maxPatternInstances)
     {
      _maxPatternInstances*=2;
      if(ArrayResize(_patternInstances,_maxPatternInstances)<_maxPatternInstances)
         printf("Error allocating array");
     }
  }
//+------------------------------------------------------------------+
//| Helper method stores projections                                 |
//+------------------------------------------------------------------+
void StoreProjection(int k,bool bullish,
                     datetime XDateTime,double X,
                     datetime ADateTime,double A,
                     datetime BDateTime,double B,
                     datetime CDateTime,double C,
                     datetime DDateTime,double D,
                     double farD)
  {
   _projectionInstances[_projectionInstanceCounter].patternIndex=k;
   _projectionInstances[_projectionInstanceCounter].bullish=bullish;
   _projectionInstances[_projectionInstanceCounter].XDateTime=XDateTime;
   _projectionInstances[_projectionInstanceCounter].ADateTime=ADateTime;
   _projectionInstances[_projectionInstanceCounter].BDateTime=BDateTime;
   _projectionInstances[_projectionInstanceCounter].CDateTime=CDateTime;
   _projectionInstances[_projectionInstanceCounter].DDateTime=DDateTime;
   _projectionInstances[_projectionInstanceCounter].X=X;
   _projectionInstances[_projectionInstanceCounter].A=A;
   _projectionInstances[_projectionInstanceCounter].B=B;
   _projectionInstances[_projectionInstanceCounter].C=C;
   _projectionInstances[_projectionInstanceCounter].D=D;
   _projectionInstances[_projectionInstanceCounter].PRZ=farD;
   _projectionInstanceCounter++;
   if(_projectionInstanceCounter>=_maxProjectionInstances)
     {
      _maxProjectionInstances*=2;
      if(ArrayResize(_projectionInstances,_maxProjectionInstances)<_maxProjectionInstances)
         printf("Error allocating array");
     }
  }
//+------------------------------------------------------------------+
//| Helper method displays 4-point PRZ                               |
//+------------------------------------------------------------------+
void DisplayPRZ(int k,bool bullish,
                datetime ADateTime,double A,
                datetime BDateTime,
                datetime CDateTime,double C,
                datetime DDateTime,double D,
                double farD)
  {
   string unique=UniqueIdentifier(ADateTime,BDateTime,CDateTime,DDateTime);
   string prefix=(bullish ? "Bullish " : "Bearish ");
   string prefixName=(bullish ? "U "+_identifier : "D "+_identifier);
   string name=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PRZ"+unique;
   ObjectCreate(0,name,OBJ_TREND,0,DDateTime-1,farD,DDateTime,farD);
   ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,true);
   ObjectSetInteger(0,name,OBJPROP_COLOR,bullish ? ClrBull4P : ClrBear4P);
   ObjectSetInteger(0,name,OBJPROP_STYLE,Style_PRZ);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PRZ stop "+DoubleToString(farD));
  }
//+------------------------------------------------------------------+
//| Helper method displays 5-point PRZ                               |
//+------------------------------------------------------------------+
void DisplayPRZ(int k,bool bullish,
                datetime XDateTime,double X,
                datetime ADateTime,double A,
                datetime BDateTime,
                datetime CDateTime,double C,
                datetime DDateTime,double D,
                double farD)
  {
   string unique=UniqueIdentifier(XDateTime,ADateTime,BDateTime,CDateTime,DDateTime);
   string prefix=(bullish ? "Bullish " : "Bearish ");
   string prefixName=(bullish ? "U "+_identifier : "D "+_identifier);
   string name=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PRZ"+unique;
   ObjectCreate(0,name,OBJ_TREND,0,DDateTime-1,farD,DDateTime,farD);
   ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,true);
   ObjectSetInteger(0,name,OBJPROP_COLOR,bullish ? ClrBull: ClrBear);
   ObjectSetInteger(0,name,OBJPROP_STYLE,Style_PRZ);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PRZ stop "+DoubleToString(farD));
  }
//+------------------------------------------------------------------+
//| Helper method displays 4-point patterns                          |
//+------------------------------------------------------------------+
void DisplayPattern(int k,bool bullish,
                    datetime ADateTime,double A,
                    datetime BDateTime,double B,
                    datetime CDateTime,double C,
                    datetime DDateTime,double D)
  {
   string unique=UniqueIdentifier(ADateTime,BDateTime,CDateTime,DDateTime);
   string prefix=(bullish ? "Bullish " : "Bearish ");
   string prefixName=(bullish ? "U "+_identifier : "D "+_identifier);
   string name0=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" AB"+unique;
   string name1=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" BC"+unique;
   string name2=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" CD"+unique;
   string pointA=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PA"+unique;
   string pointB=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PB"+unique;
   string pointC=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PC"+unique;
   string pointD=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PD"+unique;
//--- Create lines on the chart
   ObjectCreate(0,name0,OBJ_TREND,0,ADateTime,A,BDateTime,B);
   ObjectCreate(0,name1,OBJ_TREND,0,BDateTime,B,CDateTime,C);
   ObjectCreate(0,name2,OBJ_ARROWED_LINE,0,CDateTime,C,DDateTime,D);
   ObjectSetInteger(0,name0,OBJPROP_COLOR, bullish ? ClrBull4P : ClrBear4P);
   ObjectSetInteger(0,name1,OBJPROP_COLOR, bullish ? ClrBull4P : ClrBear4P);
   ObjectSetInteger(0,name2,OBJPROP_COLOR, bullish ? ClrBull4P : ClrBear4P);
   ObjectSetInteger(0,name0,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name1,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name2,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name0,OBJPROP_WIDTH,l_width4p);
   ObjectSetInteger(0,name1,OBJPROP_WIDTH,l_width4p);
   ObjectSetInteger(0,name2,OBJPROP_WIDTH,l_width4p);
   ObjectSetInteger(0,name0,OBJPROP_STYLE,Style_4P);
   ObjectSetInteger(0,name1,OBJPROP_STYLE,Style_4P);
   ObjectSetInteger(0,name2,OBJPROP_STYLE,Style_4P);
   ObjectSetString(0,name0,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" AB");
   ObjectSetString(0,name1,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" BC");
   ObjectSetString(0,name2,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" CD");
   if(Show_descriptions)
     {
      int numOverlapping=0;
      for(int i=0; i<NUM_PATTERNS; i++)
        {
         for(int j=0; j<SIZE_PATTERN_BUFFER; j++)
           {
            if(ADateTime==_patternX[i][j]) numOverlapping++;
            if(Is4PointPattern(i) && ADateTime==_patternA[i][j]) numOverlapping++;
           }
        }
      for(int i=0; i<_patternInstanceCounter; i++)
        {
         PATTERN_INSTANCE instance=_patternInstances[i];
         int patternIndexActive=_patternInstances[i].patternIndex;
         datetime XDateTimeActive=instance.XDateTime;
         datetime ADateTimeActive=instance.ADateTime;
         if(ADateTime==XDateTimeActive) numOverlapping++;
         if(Is4PointPattern(patternIndexActive) && ADateTime==ADateTimeActive) numOverlapping++;
        }
      int x1=0;
      int y1=0;
      int x2=0;
      int y2=0;
      ChartTimePriceToXY(0,0,ADateTime,A,x1,y1);
      ChartTimePriceToXY(0,0,ADateTime,A+1,x2,y2);
      double pixelsPerPrice=MathAbs(y1-y2);
      double change=pixelsPerPrice!=0 ? numOverlapping*(Font_size)/pixelsPerPrice : 0;
      double price=(bullish ? A+change : A-change);
      ObjectCreate(0,pointA,OBJ_TEXT,0,ADateTime,price);
      ObjectCreate(0,pointB,OBJ_TEXT,0,BDateTime,B);
      ObjectCreate(0,pointC,OBJ_TEXT,0,CDateTime,C);
      ObjectCreate(0,pointD,OBJ_TEXT,0,DDateTime,D);
      ObjectSetString(0,pointA,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PA");
      ObjectSetString(0,pointB,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PB");
      ObjectSetString(0,pointC,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PC");
      ObjectSetString(0,pointD,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PD");
      ObjectSetString(0,pointA,OBJPROP_TEXT,"A "+prefix+_patternNames[k]);
      ObjectSetString(0,pointA,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,pointA,OBJPROP_FONTSIZE,08);
      ObjectSetInteger(0,pointA,OBJPROP_COLOR,bullish ? ClrBull4P : ClrBear4P);
      ObjectSetString(0,pointB,OBJPROP_TEXT,"B");
      ObjectSetString(0,pointB,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,pointB,OBJPROP_FONTSIZE,08);
      ObjectSetInteger(0,pointB,OBJPROP_COLOR,bullish ? ClrBull4P : ClrBear4P);
      ObjectSetString(0,pointC,OBJPROP_TEXT,"C");
      ObjectSetString(0,pointC,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,pointC,OBJPROP_FONTSIZE,08);
      ObjectSetInteger(0,pointC,OBJPROP_COLOR,bullish ? ClrBull4P : ClrBear4P);
      ObjectSetString(0,pointD,OBJPROP_TEXT,"D");
      ObjectSetString(0,pointD,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,pointD,OBJPROP_FONTSIZE,08);
      ObjectSetInteger(0,pointD,OBJPROP_COLOR,bullish ? ClrBull4P : ClrBear4P);
     }
   if(showPatternNames)
      ShowComment(prefix+_patternNames[k]+" @ "+TimeToString(DDateTime));
  }
//+------------------------------------------------------------------+
//| Helper method displays 5-point patterns                          |
//+------------------------------------------------------------------+
void DisplayPattern(int k,bool bullish,
                    datetime XDateTime,double X,
                    datetime ADateTime,double A,
                    datetime BDateTime,double B,
                    datetime CDateTime,double C,
                    datetime DDateTime,double D)
  {
   string unique=UniqueIdentifier(XDateTime,ADateTime,BDateTime,CDateTime,DDateTime);
   string prefix=(bullish ? "Bullish " : "Bearish ");
   string prefixName=(bullish ? "U "+_identifier : "D "+_identifier);
   string name0=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" XA"+unique;
   string name1=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" AB"+unique;
   string name2=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" BC"+unique;
   string name3=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" CD"+unique;
   string name4=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" XAB"+unique;
   string name5=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" XAD"+unique;
   string name6=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" ABC"+unique;
   string name7=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" BCD"+unique;
   string triangle_XB=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" XB"+unique;
   string triangle_BD=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" BD"+unique;
   string pointX=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PX"+unique;
   string pointA=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PA"+unique;
   string pointB=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PB"+unique;
   string pointC=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PC"+unique;
   string pointD=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PD"+unique;
   string xab=IntegerToString((int) MathRound(100*MathAbs(A-B)/MathAbs(X-A)));
   string xad=IntegerToString((int) MathRound(100*MathAbs(D-A)/MathAbs(X-A)));
   string abc=IntegerToString((int) MathRound(100*MathAbs(C-B)/MathAbs(B-A)));
   if(k==CYPHER || k==NENSTAR || k==NEWCYPHER)
      abc=IntegerToString((int) MathRound(100*MathAbs(X-C)/MathAbs(X-A)));
   string bcd=IntegerToString((int) MathRound(100*MathAbs(C-D)/MathAbs(B-C)));
   ObjectCreate(0,name0,OBJ_TREND,0,XDateTime,X,ADateTime,A);
   ObjectCreate(0,name1,OBJ_TREND,0,ADateTime,A,BDateTime,B);
   ObjectCreate(0,name2,OBJ_TREND,0,BDateTime,B,CDateTime,C);
   ObjectCreate(0,name3,(!Fill_Patterns || (k==THREEDRIVES) || (k==FIVEO)) ? OBJ_ARROWED_LINE : OBJ_TREND,0,CDateTime,C,DDateTime,D);  //Arrowed lines if not triangles
   ObjectCreate(0,name4,OBJ_TREND,0,XDateTime,X,BDateTime,B);
//--- Point labels
   if(Show_descriptions)
     {
      int numOverlapping=0;
      for(int i=0; i<NUM_PATTERNS; i++)
        {
         for(int j=0; j<SIZE_PATTERN_BUFFER; j++)
           {
            if(XDateTime==_patternX[i][j]) numOverlapping++;
            if(Is4PointPattern(i) && XDateTime==_patternA[i][j]) numOverlapping++;
           }
        }
      for(int i=0; i<_patternInstanceCounter; i++)
        {
         PATTERN_INSTANCE instance=_patternInstances[i];
         int patternIndexActive=_patternInstances[i].patternIndex;
         datetime XDateTimeActive=instance.XDateTime;
         datetime ADateTimeActive=instance.ADateTime;
         if(XDateTime==XDateTimeActive) numOverlapping++;
         if(Is4PointPattern(patternIndexActive) && XDateTime==ADateTimeActive) numOverlapping++;
        }
      int x1=0;
      int y1=0;
      int x2=0;
      int y2=0;
      ChartTimePriceToXY(0,0,XDateTime,X,x1,y1);
      ChartTimePriceToXY(0,0,XDateTime,X+1,x2,y2);
      double pixelsPerPrice=MathAbs(y1-y2);
      double change=pixelsPerPrice!=0 ? numOverlapping*(Font_size)/pixelsPerPrice : 0;
      double price=(bullish ? X-change : X+change);
      ObjectCreate(0,pointX,OBJ_TEXT,0,XDateTime,price);
      ObjectCreate(0,pointA,OBJ_TEXT,0,ADateTime,A);
      ObjectCreate(0,pointB,OBJ_TEXT,0,BDateTime,B);
      ObjectCreate(0,pointC,OBJ_TEXT,0,CDateTime,C);
      ObjectCreate(0,pointD,OBJ_TEXT,0,DDateTime,D);
      ObjectSetString(0,pointX,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PX");
      ObjectSetString(0,pointA,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PA");
      ObjectSetString(0,pointB,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PB");
      ObjectSetString(0,pointC,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PC");
      ObjectSetString(0,pointD,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PD");
      ObjectSetString(0,pointX,OBJPROP_TEXT,"X "+prefix+_patternNames[k]);
      ObjectSetString(0,pointX,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,pointX,OBJPROP_FONTSIZE,Font_size);
      ObjectSetInteger(0,pointX,OBJPROP_COLOR,bullish ? ClrBull : ClrBear);
      ObjectSetString(0,pointA,OBJPROP_TEXT,"A");
      ObjectSetString(0,pointA,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,pointA,OBJPROP_FONTSIZE,Font_size);
      ObjectSetInteger(0,pointA,OBJPROP_COLOR,bullish ? ClrBull : ClrBear);
      ObjectSetString(0,pointB,OBJPROP_TEXT,"B");
      ObjectSetString(0,pointB,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,pointB,OBJPROP_FONTSIZE,Font_size);
      ObjectSetInteger(0,pointB,OBJPROP_COLOR,bullish ? ClrBull : ClrBear);
      ObjectSetString(0,pointC,OBJPROP_TEXT,"C");
      ObjectSetString(0,pointC,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,pointC,OBJPROP_FONTSIZE,Font_size);
      ObjectSetInteger(0,pointC,OBJPROP_COLOR,bullish ? ClrBull : ClrBear);
      ObjectSetString(0,pointD,OBJPROP_TEXT,"D");
      ObjectSetString(0,pointD,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,pointD,OBJPROP_FONTSIZE,Font_size);
      ObjectSetInteger(0,pointD,OBJPROP_COLOR,bullish ? ClrBull : ClrBear);
     }
//--- No X-D for 5-0
   if(k!=FIVEO) ObjectCreate(0,name5,OBJ_TREND,0,XDateTime,X,DDateTime,D);
   ObjectCreate(0,name6,OBJ_TREND,0,ADateTime,A,CDateTime,C);
   ObjectCreate(0,name7,OBJ_TREND,0,BDateTime,B,DDateTime,D);
   ObjectSetInteger(0,name0,OBJPROP_COLOR, bullish ? ClrBull : ClrBear);
   ObjectSetInteger(0,name1,OBJPROP_COLOR, bullish ? ClrBull : ClrBear);
   ObjectSetInteger(0,name2,OBJPROP_COLOR, bullish ? ClrBull : ClrBear);
   ObjectSetInteger(0,name3,OBJPROP_COLOR, bullish ? ClrBull : ClrBear);
   ObjectSetInteger(0,name0,OBJPROP_STYLE,Style_5P);
   ObjectSetInteger(0,name1,OBJPROP_STYLE,Style_5P);
   ObjectSetInteger(0,name3,OBJPROP_STYLE,Style_5P);
   ObjectSetInteger(0,name4,OBJPROP_COLOR,ClrRatio);
   if(k!=FIVEO) ObjectSetInteger(0,name5,OBJPROP_COLOR,ClrRatio);
   ObjectSetInteger(0,name6,OBJPROP_COLOR,ClrRatio);
   ObjectSetInteger(0,name7,OBJPROP_COLOR,ClrRatio);
   ObjectSetInteger(0,name4,OBJPROP_STYLE,Style_Ratio);
   if(k!=FIVEO) ObjectSetInteger(0,name5,OBJPROP_STYLE,Style_Ratio);
   ObjectSetInteger(0,name6,OBJPROP_STYLE,Style_Ratio);
   ObjectSetInteger(0,name7,OBJPROP_STYLE,Style_Ratio);
   ObjectSetInteger(0,name0,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name1,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name2,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name3,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name4,OBJPROP_SELECTABLE,true);
   if(k!=FIVEO) ObjectSetInteger(0,name5,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name6,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name7,OBJPROP_SELECTABLE,true);
   ObjectSetString(0,name0,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" XA");
   ObjectSetString(0,name1,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" AB");
   ObjectSetString(0,name2,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" BC");
   ObjectSetString(0,name3,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" CD");
   ObjectSetString(0,name4,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" XAB="+xab);
   if(k!=FIVEO) ObjectSetString(0,name5,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" XAD="+xad);
   ObjectSetString(0,name6,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" ABC="+abc);
   ObjectSetString(0,name7,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" BCD="+bcd);
   ObjectSetInteger(0,name0,OBJPROP_WIDTH,l_width);
   ObjectSetInteger(0,name1,OBJPROP_WIDTH,l_width);
   ObjectSetInteger(0,name2,OBJPROP_WIDTH,l_width);
   ObjectSetInteger(0,name3,OBJPROP_WIDTH,l_width);
   if(Fill_Patterns && (k!=FIVEO && k!=THREEDRIVES))
     {
      ObjectCreate(0,triangle_XB,OBJ_TRIANGLE,0,XDateTime,X,ADateTime,A,BDateTime,B);
      ObjectCreate(0,triangle_BD,OBJ_TRIANGLE,0,BDateTime,B,CDateTime,C,DDateTime,D);
      ObjectSetInteger(0,triangle_XB,OBJPROP_COLOR,bullish ? ClrBull : ClrBear);
      ObjectSetInteger(0,triangle_XB,OBJPROP_STYLE,STYLE_SOLID);
      ObjectSetInteger(0,triangle_XB,OBJPROP_FILL,true);
      ObjectSetInteger(0,triangle_XB,OBJPROP_BACK,true);
      ObjectSetInteger(0,triangle_XB,OBJPROP_SELECTABLE,true);
      ObjectSetInteger(0,triangle_XB,OBJPROP_SELECTED,false);
      ObjectSetInteger(0,triangle_BD,OBJPROP_COLOR,bullish ? ClrBull : ClrBear);
      ObjectSetInteger(0,triangle_BD,OBJPROP_STYLE,STYLE_SOLID);
      ObjectSetInteger(0,triangle_BD,OBJPROP_FILL,true);
      ObjectSetInteger(0,triangle_BD,OBJPROP_BACK,true);
      ObjectSetInteger(0,triangle_BD,OBJPROP_SELECTABLE,true);
      ObjectSetInteger(0,triangle_BD,OBJPROP_SELECTED,false);
     }
   if(showPatternNames)
      ShowComment(prefix+_patternNames[k]+" @ "+TimeToString(DDateTime));

  }
//+------------------------------------------------------------------+
//| Helper method displays 4-point projections                       |
//+------------------------------------------------------------------+
void DisplayProjection(int k,bool bullish,
                       datetime ADateTime,double A,
                       datetime BDateTime,double B,
                       datetime CDateTime,double C,
                       datetime DDateTime,double D)
  {
   string unique=UniqueIdentifier(ADateTime,BDateTime,CDateTime,DDateTime);
   string prefix=(bullish ? "Projected Bullish " : "Projected Bearish ");
   string prefixName=(bullish ? "PU "+_identifier : "PD "+_identifier);
   string name0=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" AB"+unique;
   string name1=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" BC"+unique;
   string name2=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" CD"+unique;
   string pointA=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PA"+unique;
   string pointB=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PB"+unique;
   string pointC=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PC"+unique;
   string pointD=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PD"+unique;
   ObjectCreate(0,name0,OBJ_TREND,0,ADateTime,A,BDateTime,B);
   ObjectCreate(0,name1,OBJ_TREND,0,BDateTime,B,CDateTime,C);
   ObjectCreate(0,name2,OBJ_TREND,0,CDateTime,C,DDateTime,D);
   ObjectSetInteger(0,name0,OBJPROP_COLOR, bullish ? ClrBullProjection : ClrBearProjection);
   ObjectSetInteger(0,name1,OBJPROP_COLOR, bullish ? ClrBullProjection : ClrBearProjection);
   ObjectSetInteger(0,name2,OBJPROP_COLOR, bullish ? ClrBullProjection : ClrBearProjection);
   ObjectSetInteger(0,name0,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name1,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name2,OBJPROP_SELECTABLE,true);
   ObjectSetString(0,name0,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" AB");
   ObjectSetString(0,name1,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" BC");
   ObjectSetString(0,name2,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" CD");
   ObjectSetInteger(0,name0,OBJPROP_WIDTH,l_width_proj);
   ObjectSetInteger(0,name1,OBJPROP_WIDTH,l_width_proj);
   ObjectSetInteger(0,name2,OBJPROP_WIDTH,l_width_proj);
   ObjectSetInteger(0,name0,OBJPROP_STYLE,Style_Proj);
   ObjectSetInteger(0,name1,OBJPROP_STYLE,Style_Proj);
   ObjectSetInteger(0,name2,OBJPROP_STYLE,Style_Proj);
   if(Show_descriptions)
     {
      ObjectCreate(0,pointA,OBJ_TEXT,0,ADateTime,A);
      ObjectCreate(0,pointB,OBJ_TEXT,0,BDateTime,B);
      ObjectCreate(0,pointC,OBJ_TEXT,0,CDateTime,C);
      ObjectCreate(0,pointD,OBJ_TEXT,0,DDateTime,D);
      ObjectSetString(0,pointA,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PA");
      ObjectSetString(0,pointB,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PB");
      ObjectSetString(0,pointC,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PC");
      ObjectSetString(0,pointD,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PD");
      ObjectSetString(0,pointA,OBJPROP_TEXT,"A");
      ObjectSetString(0,pointA,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,pointA,OBJPROP_FONTSIZE,Font_size);
      ObjectSetInteger(0,pointA,OBJPROP_COLOR,bullish ? ClrBullProjection : ClrBearProjection);
      ObjectSetString(0,pointB,OBJPROP_TEXT,"B");
      ObjectSetString(0,pointB,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,pointB,OBJPROP_FONTSIZE,Font_size);
      ObjectSetInteger(0,pointB,OBJPROP_COLOR,bullish ? ClrBullProjection : ClrBearProjection);
      ObjectSetString(0,pointC,OBJPROP_TEXT,"C");
      ObjectSetString(0,pointC,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,pointC,OBJPROP_FONTSIZE,Font_size);
      ObjectSetInteger(0,pointC,OBJPROP_COLOR,bullish ? ClrBullProjection : ClrBearProjection);
      ObjectSetString(0,pointD,OBJPROP_TEXT," D "+prefix+_patternNames[k]);
      ObjectSetString(0,pointD,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,pointD,OBJPROP_FONTSIZE,Font_size);
      ObjectSetInteger(0,pointD,OBJPROP_COLOR,bullish ? ClrBullProjection : ClrBearProjection);
     }
  }
//+------------------------------------------------------------------+
//| Helper method displays 5-point projections                       |
//+------------------------------------------------------------------+
void DisplayProjection(int k,bool bullish,
                       datetime XDateTime,double X,
                       datetime ADateTime,double A,
                       datetime BDateTime,double B,
                       datetime CDateTime,double C,
                       datetime DDateTime,double D)
  {
   string unique=UniqueIdentifier(XDateTime,ADateTime,BDateTime,CDateTime,DDateTime);
   string prefix=(bullish ? "Projected Bullish " : "Projected Bearish ");
   string prefixName=(bullish ? "PU "+_identifier : "PD "+_identifier);
   string name0=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" XA"+unique;
   string name1=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" AB"+unique;
   string name2=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" BC"+unique;
   string name3=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" CD"+unique;
   string name4=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" XAB"+unique;
   string name5=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" XAD"+unique;
   string name6=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" ABC"+unique;
   string name7=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" BCD"+unique;
   string pointX=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PX"+unique;
   string pointA=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PA"+unique;
   string pointB=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PB"+unique;
   string pointC=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PC"+unique;
   string pointD=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PD"+unique;
   string xab=IntegerToString((int) MathRound(100*MathAbs(A-B)/MathAbs(X-A)));
   string xad=IntegerToString((int) MathRound(100*MathAbs(D-A)/MathAbs(X-A)));
   string abc=IntegerToString((int) MathRound(100*MathAbs(C-B)/MathAbs(B-A)));
//--- Cypher and Nen Start have the A-C top as XC/XA instead of CB/BA
   if(k==CYPHER || k==NENSTAR || k==NEWCYPHER)
      abc=IntegerToString((int) MathRound(100*MathAbs(X-C)/MathAbs(X-A)));
   string bcd=IntegerToString((int) MathRound(100*MathAbs(C-D)/MathAbs(B-C)));
   ObjectCreate(0,name0,OBJ_TREND,0,XDateTime,X,ADateTime,A);
   ObjectCreate(0,name1,OBJ_TREND,0,ADateTime,A,BDateTime,B);
   ObjectCreate(0,name2,OBJ_TREND,0,BDateTime,B,CDateTime,C);
   ObjectCreate(0,name3,OBJ_TREND,0,CDateTime,C,DDateTime,D);
   ObjectCreate(0,name4,OBJ_TREND,0,XDateTime,X,BDateTime,B);
   if(k!=FIVEO) ObjectCreate(0,name5,OBJ_TREND,0,XDateTime,X,DDateTime,D);
   ObjectCreate(0,name6,OBJ_TREND,0,ADateTime,A,CDateTime,C);
   ObjectCreate(0,name7,OBJ_TREND,0,BDateTime,B,DDateTime,D);
   ObjectSetInteger(0,name0,OBJPROP_COLOR, bullish ? ClrBullProjection : ClrBearProjection);
   ObjectSetInteger(0,name1,OBJPROP_COLOR, bullish ? ClrBullProjection : ClrBearProjection);
   ObjectSetInteger(0,name2,OBJPROP_COLOR, bullish ? ClrBullProjection : ClrBearProjection);
   ObjectSetInteger(0,name3,OBJPROP_COLOR, bullish ? ClrBullProjection : ClrBearProjection);
   ObjectSetInteger(0,name4,OBJPROP_COLOR,ClrRatio);
   if(k!=FIVEO) ObjectSetInteger(0,name5,OBJPROP_COLOR,ClrRatio);
   ObjectSetInteger(0,name6,OBJPROP_COLOR,ClrRatio);
   ObjectSetInteger(0,name7,OBJPROP_COLOR,ClrRatio);
   ObjectSetInteger(0,name0,OBJPROP_STYLE,Style_Proj);
   ObjectSetInteger(0,name1,OBJPROP_STYLE,Style_Proj);
   ObjectSetInteger(0,name2,OBJPROP_STYLE,Style_Proj);
   ObjectSetInteger(0,name3,OBJPROP_STYLE,Style_Proj);
   ObjectSetInteger(0,name4,OBJPROP_STYLE,Style_Ratio);
   ObjectSetInteger(0,name5,OBJPROP_STYLE,Style_Ratio);
   ObjectSetInteger(0,name6,OBJPROP_STYLE,Style_Ratio);
   ObjectSetInteger(0,name7,OBJPROP_STYLE,Style_Ratio);
   ObjectSetInteger(0,name0,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name1,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name2,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name3,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name4,OBJPROP_SELECTABLE,true);
   if(k!=FIVEO) ObjectSetInteger(0,name5,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name6,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name7,OBJPROP_SELECTABLE,true);
   ObjectSetString(0,name0,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" XA");
   ObjectSetString(0,name1,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" AB");
   ObjectSetString(0,name2,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" BC");
   ObjectSetString(0,name3,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" CD");
   ObjectSetString(0,name4,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" XAB="+xab);
   if(k!=FIVEO) ObjectSetString(0,name5,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" XAD="+xad);
   ObjectSetString(0,name6,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" ABC="+abc);
   ObjectSetString(0,name7,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" BCD="+bcd);
   if(Show_descriptions)
     {
      ObjectCreate(0,pointX,OBJ_TEXT,0,XDateTime,X);
      ObjectCreate(0,pointA,OBJ_TEXT,0,ADateTime,A);
      ObjectCreate(0,pointB,OBJ_TEXT,0,BDateTime,B);
      ObjectCreate(0,pointC,OBJ_TEXT,0,CDateTime,C);
      ObjectCreate(0,pointD,OBJ_TEXT,0,DDateTime,D);
      ObjectSetString(0,pointX,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PX");
      ObjectSetString(0,pointA,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PA");
      ObjectSetString(0,pointB,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PB");
      ObjectSetString(0,pointC,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PC");
      ObjectSetString(0,pointD,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PD");
      ObjectSetInteger(0,name0,OBJPROP_WIDTH,l_width_proj);
      ObjectSetInteger(0,name1,OBJPROP_WIDTH,l_width_proj);
      ObjectSetInteger(0,name2,OBJPROP_WIDTH,l_width_proj);
      ObjectSetInteger(0,name3,OBJPROP_WIDTH,l_width_proj);
      ObjectSetString(0,pointX,OBJPROP_TEXT,"X");
      ObjectSetString(0,pointX,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,pointX,OBJPROP_FONTSIZE,Font_size);
      ObjectSetInteger(0,pointX,OBJPROP_COLOR,bullish ? ClrBullProjection : ClrBearProjection);
      ObjectSetString(0,pointA,OBJPROP_TEXT,"A");
      ObjectSetString(0,pointA,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,pointA,OBJPROP_FONTSIZE,Font_size);
      ObjectSetInteger(0,pointA,OBJPROP_COLOR,bullish ? ClrBullProjection : ClrBearProjection);
      ObjectSetString(0,pointB,OBJPROP_TEXT,"B");
      ObjectSetString(0,pointB,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,pointB,OBJPROP_FONTSIZE,Font_size);
      ObjectSetInteger(0,pointB,OBJPROP_COLOR,bullish ? ClrBullProjection : ClrBearProjection);
      ObjectSetString(0,pointC,OBJPROP_TEXT,"C");
      ObjectSetString(0,pointC,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,pointC,OBJPROP_FONTSIZE,Font_size);
      ObjectSetInteger(0,pointC,OBJPROP_COLOR,bullish ? ClrBullProjection : ClrBearProjection);
      ObjectSetString(0,pointD,OBJPROP_TEXT," D "+prefix+_patternNames[k]);
      ObjectSetString(0,pointD,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,pointD,OBJPROP_FONTSIZE,Font_size);
      ObjectSetInteger(0,pointD,OBJPROP_COLOR,bullish ? ClrBullProjection : ClrBearProjection);
     }
  }
//+------------------------------------------------------------------+
//| Helper method undisplays projections                             |
//+------------------------------------------------------------------+
void UndisplayProjections()
  {
   for(int i=0; i<_drawnProjectionInstanceCounter; i++)
     {
      PATTERN_INSTANCE instance=_drawnProjectionInstances[i];
      int k=instance.patternIndex;
      bool bullish=instance.bullish;
      datetime XDateTime=instance.XDateTime;
      datetime ADateTime=instance.ADateTime;
      datetime BDateTime=instance.BDateTime;
      datetime CDateTime=instance.CDateTime;
      datetime DDateTime=instance.DDateTime;
      //--- Delete pattern from chart
      string unique=Is4PointPattern(k)?UniqueIdentifier(ADateTime,BDateTime,CDateTime,DDateTime) : UniqueIdentifier(XDateTime,ADateTime,BDateTime,CDateTime,DDateTime);
      string prefix=(bullish ? "PU "+_identifier : "PD "+_identifier);
      string name0=prefix+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" XA"+unique;
      string name1=prefix+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" AB"+unique;
      string name2=prefix+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" BC"+unique;
      string name3=prefix+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" CD"+unique;
      string name4=prefix+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" XAB"+unique;
      string name5=prefix+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" XAD"+unique;
      string name6=prefix+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" ABC"+unique;
      string name7=prefix+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" BCD"+unique;
      string pointX=prefix+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PX"+unique;
      string pointA=prefix+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PA"+unique;
      string pointB=prefix+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PB"+unique;
      string pointC=prefix+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PC"+unique;
      string pointD=prefix+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PD"+unique;
      ObjectDelete(0,name0);
      ObjectDelete(0,name1);
      ObjectDelete(0,name2);
      ObjectDelete(0,name3);
      ObjectDelete(0,name4);
      ObjectDelete(0,name5);
      ObjectDelete(0,name6);
      ObjectDelete(0,name7);
      ObjectDelete(0,pointX);
      ObjectDelete(0,pointA);
      ObjectDelete(0,pointB);
      ObjectDelete(0,pointC);
      ObjectDelete(0,pointD);
     }
   _drawnProjectionInstanceCounter=0;
  }
//+------------------------------------------------------------------+
//| Helper method undisplays recently drawn patterns                 |
//+------------------------------------------------------------------+
void UndisplayPatterns()
  {
   for(int i=0; i<_patternInstanceCounter; i++)
     {
      PATTERN_INSTANCE instance=_patternInstances[i];
      int k=instance.patternIndex;
      bool bullish=instance.bullish;
      datetime XDateTime=instance.XDateTime;
      datetime ADateTime=instance.ADateTime;
      datetime BDateTime=instance.BDateTime;
      datetime CDateTime=instance.CDateTime;
      datetime DDateTime=instance.DDateTime;
      //--- Delete pattern from chart
      string unique=Is4PointPattern(k)?UniqueIdentifier(ADateTime,BDateTime,CDateTime,DDateTime) : UniqueIdentifier(XDateTime,ADateTime,BDateTime,CDateTime,DDateTime);
      string prefix=(bullish ? "U "+_identifier : "D "+_identifier);
      string name0=prefix+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" XA"+unique;
      string name1=prefix+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" AB"+unique;
      string name2=prefix+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" BC"+unique;
      string name3=prefix+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" CD"+unique;
      string name4=prefix+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" XAB"+unique;
      string name5=prefix+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" XAD"+unique;
      string name6=prefix+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" ABC"+unique;
      string name7=prefix+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" BCD"+unique;
      string triangle_XB=prefix+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" XB"+unique;
      string triangle_BD=prefix+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" BD"+unique;
      string pointX=prefix+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PX"+unique;
      string pointA=prefix+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PA"+unique;
      string pointB=prefix+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PB"+unique;
      string pointC=prefix+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PC"+unique;
      string pointD=prefix+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PD"+unique;
      ObjectDelete(0,name0);
      ObjectDelete(0,name1);
      ObjectDelete(0,name2);
      ObjectDelete(0,name3);
      ObjectDelete(0,name4);
      ObjectDelete(0,name5);
      ObjectDelete(0,name6);
      ObjectDelete(0,name7);
      ObjectDelete(0,triangle_XB);
      ObjectDelete(0,triangle_BD);
      ObjectDelete(0,pointX);
      ObjectDelete(0,pointA);
      ObjectDelete(0,pointB);
      ObjectDelete(0,pointC);
      ObjectDelete(0,pointD);
     }
  }
//+------------------------------------------------------------------+
//| Helper method undisplays recently drawn PRZ                      |
//+------------------------------------------------------------------+
void UndisplayPRZs()
  {
   for(int i=0; i<_patternInstanceCounter; i++)
     {
      PATTERN_INSTANCE instance=_patternInstances[i];
      int k=instance.patternIndex;
      bool bullish=instance.bullish;
      datetime XDateTime=instance.XDateTime;
      datetime ADateTime=instance.ADateTime;
      datetime BDateTime=instance.BDateTime;
      datetime CDateTime=instance.CDateTime;
      datetime DDateTime=instance.DDateTime;
      //--- Delete pattern from chart
      string unique=Is4PointPattern(k)?UniqueIdentifier(ADateTime,BDateTime,CDateTime,DDateTime) : UniqueIdentifier(XDateTime,ADateTime,BDateTime,CDateTime,DDateTime);
      string prefix=(bullish ? "U "+_identifier : "D "+_identifier);
      string linePRZ=prefix+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PRZ"+unique;
      ObjectDelete(0,linePRZ);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Helper method populates pattern arrays                           |
//+------------------------------------------------------------------+
int PopulatePatterns()
  {
//--- Create pattern descriptor structs with relevant ratios
   PATTERN_DESCRIPTOR trendlike1_abcd=          {0,0,0.382,0.382,2.618,2.618,0,0,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR trendlike2_abcd=          {0,0,0.5,0.5,2.0,2.0,0,0,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR perfect_abcd=             {0,0,0.618,0.618,1.618,1.618,0,0,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR ideal1_abcd=              {0,0,0.707,0.707,1.41,1.41,0,0,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR ideal2_abcd=              {0,0,0.786,0.786,1.27,1.27,0,0,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR rangelike_abcd=           {0,0,0.886,0.886,1.13,1.13,0,0,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR alt127_trendlike1_abcd=   {0,0,0.382,0.382,2.618,3.618,0,0,0,0,0,0,1.272,1.272};
   PATTERN_DESCRIPTOR alt127_trendlike2_abcd=   {0,0,0.5,0.5,2.0,3.618,0,0,0,0,0,0,1.272,1.272};
   PATTERN_DESCRIPTOR alt127_perfect_abcd=      {0,0,0.618,0.618,1.618,3.618,0,0,0,0,0,0,1.272,1.272};
   PATTERN_DESCRIPTOR alt127_ideal1_abcd=       {0,0,0.707,0.707,1.41,3.618,0,0,0,0,0,0,1.272,1.272};
   PATTERN_DESCRIPTOR alt127_ideal2_abcd=       {0,0,0.786,0.786,1.27,3.618,0,0,0,0,0,0,1.272,1.272};
   PATTERN_DESCRIPTOR alt127_rangelike_abcd=    {0,0,0.886,0.886,1.13,3.618,0,0,0,0,0,0,1.272,1.272};
   PATTERN_DESCRIPTOR rec_trendlike1_abcd=      {0,0,2.618,2.618,0.382,0.382,0,0,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR rec_trendlike2_abcd=      {0,0,2.0,2.0,0.5,0.5,0,0,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR rec_perfect_abcd=         {0,0,1.618,1.618,0.618,0.618,0,0,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR rec_ideal1_abcd=          {0,0,1.41,1.41,0.707,0.707,0,0,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR rec_ideal2_abcd=          {0,0,1.27,1.27,0.786,0.786,0,0,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR rec_rangelike_abcd=       {0,0,1.13,1.13,0.886,0.886,0,0,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR gartley=      {0.618,0.618,0.382,0.886,1.272,1.618,0.786,0.786,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR bat=          {0.382,0.5,0.382,0.886,1.618,2.618,0.886,0.886,0,0,0,0,0,0 };
   PATTERN_DESCRIPTOR altbat=       {0.382,0.382,0.382,0.886,2.0,3.618,1.13,1.13,0,0,0,0,0,0 };
   PATTERN_DESCRIPTOR fiveo=        {1.13,1.618,1.618,2.24,0.5,0.5,0,0,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR butterfly=    {0.786,0.786,0.382,0.886,1.618,2.618,1.272,1.618,0,0,0,0,0,0 };
   PATTERN_DESCRIPTOR crab=         {0.382,0.618,0.382,0.886,2.24,3.618,1.618,1.618,0,0,0,0,0,0 };
   PATTERN_DESCRIPTOR deepcrab=     {0.886,0.886,0.382,0.886,2.0,3.618,1.618,1.618,0,0,0,0,0,0 };
   PATTERN_DESCRIPTOR threedrives=  {1.272,1.618,0.618,0.786,1.272,1.618,0,0,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR shark=        {0,0,1.13,1.618,1.618,2.24,0,0,0.886,1.13,0,0,0,0};
   PATTERN_DESCRIPTOR cypher=       {0.382,0.618,0,0,0,0,0,0,0.786,0.786,1.13,1.414,0,0};
   PATTERN_DESCRIPTOR nenstar=      {0.382,0.618,0,0,0,0,0,0,1.272,1.272,1.13,1.414,0,0};
   PATTERN_DESCRIPTOR blackswan=    {1.382,2.618,0.236,0.5,1.128,2,1.128,2.618,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR whiteswan=    {0.382,0.724,2,4.237,0.5,0.886,0.382,0.886,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR one2one=      {0.5,0.786,1.128,3.618,0.382,0.786,0.382,0.786,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR newcypher=    {0.382,0.618,0,0,0,0,0,0,0.786,0.786,1.414,2.14,0,0};
   PATTERN_DESCRIPTOR navarro200=   {0.382,0.786,0.886,1.128,0.886,3.618,0.886,1.128,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR leonardo=     {0.5,0.5,0.382,0.886,1.128,2.618,0.786,0.786,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR kane=         {0.685,0.685,0.382,0.886,0,0,1.460,1.460,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR garfly=       {0.618,0.618,0.382,0.886,1.618,2.24,1.272,1.272,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR maxbat=       {0.382,0.618,0.382,0.886,1.272,2.618,0.886,0.886,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR maxgartley=   {0.382,0.618,0.382,0.886,1.128,2.236,0.618,0.786,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR maxbutterfly= {0.618,0.886,0.382,0.886,1.272,2.618,1.272,1.618,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR gartley113=   {0.618,0.618,0.382,0.886,1.13,1.13,0.786,0.786,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR butterfly113= {0.786,1,0.618,1,1.128,1.618,1.128,1.128,0,0,0,0,0,0 };
   PATTERN_DESCRIPTOR anti_gartley=       {0.618,0.786,1.129,2.618,1.618,1.618,1.272,1.272,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR anti_bat=           {0.382,0.618,1.129,2.618,2.000,2.618,1.129,1.129,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR anti_altbat=        {0.276,0.500,1.129,2.618,2.618,2.618,0.885,0.885,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR anti_fiveo=         {2.000,2.000,0.446,0.618,0.618,0.885,0,0,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR anti_butterfly=     {0.382,0.618,1.129,2.618,1.272,1.272,0.618,0.786,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR anti_crab=          {0.276,0.446,1.129,2.618,1.618,2.618,0.618,0.618,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR anti_deepcrab=      {0.276,0.500,1.129,2.618,1.129,1.129,0.618,0.618,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR anti_threedrives=   {0.618,0.786,1.272,1.618,0.618,0.786,0,0,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR anti_shark=         {0.446,0.618,0.618,0.885,0,0,0,0,0.885,1.129,0,0,0,0};
   PATTERN_DESCRIPTOR anti_cypher=        {0,0,0,0,1.618,2.618,0,0,1.272,1.272,0.707,0.885,0,0};
   PATTERN_DESCRIPTOR anti_nenstar=       {0,0,0,0,1.618,2.618,0,0,0.786,0.786,0.707,0.885,0,0};
   PATTERN_DESCRIPTOR anti_blackswan=     {0.500,0.887,2.000,4.237,0.382,0.724,0.382,0.887,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR anti_whiteswan=     {1.129,2.000,0.236,0.500,1.381,2.618,1.129,2.618,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR anti_one2one=       {1.272,2.618,0.276,0.887,1.272,2.000,1.272,2.618,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR anti_newcypher=     {0,0,0,0,1.618,2.618,0,0,1.272,1.272,0.467,0.707,0,0};
   PATTERN_DESCRIPTOR anti_navarro200=    {0.276,1.129,0.887,1.129,1.272,2.618,0.887,1.129,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR anti_leonardo=      {0.382,0.887,1.129,2.618,2.000,2.000,1.272,1.272,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR anti_kane=          {0,0,1.129,2.618,1.460,1.460,0.685,0.685,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR anti_garfly=        {0.446,0.618,1.129,2.618,1.618,1.618,0.786,0.786,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR anti_maxbat=        {0.382,0.786,1.129,2.618,1.618,2.618,1.129,1.129,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR anti_maxgartley=    {0.447,0.887,1.129,2.618,1.618,2.618,1.272,1.618,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR anti_maxbutterfly=  {0.382,0.786,1.129,2.618,1.129,1.618,0.618,0.786,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR anti_gartley113=    {0.885,0.885,1.129,2.618,1.618,1.618,1.272,1.272,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR anti_butterfly113=  {0.618,0.887,1.000,1.618,1.000,1.272,0.887,0.887,0,0,0,0,0,0};

//--- Initialize arrays
   _maxProjectionInstances=4;
   _maxPatternInstances=NUM_PATTERNS*SIZE_PATTERN_BUFFER;
   _maxDrawnProjectionInstances=4;
   if(ArrayResize(_patterns,NUM_PATTERNS)<NUM_PATTERNS)
     {
      printf("Error allocating array: "+IntegerToString(GetLastError()));
      return INIT_FAILED;
     }
   if(ArrayResize(_patternNames,NUM_PATTERNS)<NUM_PATTERNS)
     {
      printf("Error allocating array: "+IntegerToString(GetLastError()));
      return INIT_FAILED;
     }
   if(ArrayResize(_patternX,NUM_PATTERNS)<NUM_PATTERNS)
     {
      printf("Error allocating array: "+IntegerToString(GetLastError()));
      return INIT_FAILED;
     }
   if(ArrayResize(_patternA,NUM_PATTERNS)<NUM_PATTERNS)
     {
      printf("Error allocating array: "+IntegerToString(GetLastError()));
      return INIT_FAILED;
     }
   if(ArrayResize(_patternB,NUM_PATTERNS)<NUM_PATTERNS)
     {
      printf("Error allocating array: "+IntegerToString(GetLastError()));
      return INIT_FAILED;
     }
   if(ArrayResize(_patternC,NUM_PATTERNS)<NUM_PATTERNS)
     {
      printf("Error allocating array: "+IntegerToString(GetLastError()));
      return INIT_FAILED;
     }
   if(ArrayResize(_patternD,NUM_PATTERNS)<NUM_PATTERNS)
     {
      printf("Error allocating array: "+IntegerToString(GetLastError()));
      return INIT_FAILED;
     }
   if(ArrayResize(_patternCounter,NUM_PATTERNS)<NUM_PATTERNS)
     {
      printf("Error allocating array: "+IntegerToString(GetLastError()));
      return INIT_FAILED;
     }
   if(ArrayResize(_patternInstances,_maxPatternInstances)<_maxPatternInstances)
     {
      printf("Error allocating array: "+IntegerToString(GetLastError()));
      return INIT_FAILED;
     }
   if(ArrayResize(_projectionInstances,_maxProjectionInstances)<_maxProjectionInstances)
     {
      printf("Error allocating array: "+IntegerToString(GetLastError()));
      return INIT_FAILED;
     }
   if(ArrayResize(_drawnProjectionInstances,_maxDrawnProjectionInstances)<_maxDrawnProjectionInstances)
     {
      printf("Error allocating array: "+IntegerToString(GetLastError()));
      return INIT_FAILED;
     }
   ArrayFill(_patternCounter,0,NUM_PATTERNS,0);
//--- Fill in the pattern arrays
   _patterns[TRENDLIKE1_ABCD]=trendlike1_abcd; _patternNames[TRENDLIKE1_ABCD]="Trendlike AB=CD #1";
   _patterns[TRENDLIKE2_ABCD]=trendlike2_abcd; _patternNames[TRENDLIKE2_ABCD]="Trendlike AB=CD #2";
   _patterns[PERFECT_ABCD]=perfect_abcd; _patternNames[PERFECT_ABCD]="Perfect AB=CD";
   _patterns[IDEAL1_ABCD]=ideal1_abcd; _patternNames[IDEAL1_ABCD]="Ideal AB=CD #1";
   _patterns[IDEAL2_ABCD]=ideal2_abcd; _patternNames[IDEAL2_ABCD]="Ideal AB=CD #2";
   _patterns[RANGELIKE_ABCD]=rangelike_abcd; _patternNames[RANGELIKE_ABCD]="Rangelike AB=CD";
   _patterns[ALT127_TRENDLIKE1_ABCD]=alt127_trendlike1_abcd; _patternNames[ALT127_TRENDLIKE1_ABCD]="Trendlike 1.27 AB=CD #1";
   _patterns[ALT127_TRENDLIKE2_ABCD]=alt127_trendlike2_abcd; _patternNames[ALT127_TRENDLIKE2_ABCD]="Trendlike 1.27 AB=CD #2";
   _patterns[ALT127_PERFECT_ABCD]=alt127_perfect_abcd; _patternNames[ALT127_PERFECT_ABCD]="Perfect 1.27 AB=CD";
   _patterns[ALT127_IDEAL1_ABCD]=alt127_ideal1_abcd; _patternNames[ALT127_IDEAL1_ABCD]="Ideal 1.27 AB=CD #1";
   _patterns[ALT127_IDEAL2_ABCD]=alt127_ideal2_abcd; _patternNames[ALT127_IDEAL2_ABCD]="Ideal 1.27 AB=CD #2";
   _patterns[ALT127_RANGELIKE_ABCD]=alt127_rangelike_abcd; _patternNames[ALT127_RANGELIKE_ABCD]="Rangelike 1.27 AB=CD";
   _patterns[REC_TRENDLIKE1_ABCD]=rec_trendlike1_abcd; _patternNames[REC_TRENDLIKE1_ABCD]="Rec. Trendlike AB=CD #1";
   _patterns[REC_TRENDLIKE2_ABCD]=rec_trendlike2_abcd; _patternNames[REC_TRENDLIKE2_ABCD]="Rec. Trendlike AB=CD #2";
   _patterns[REC_PERFECT_ABCD]=rec_perfect_abcd; _patternNames[REC_PERFECT_ABCD]="Rec. Perfect AB=CD";
   _patterns[REC_IDEAL1_ABCD]=rec_ideal1_abcd; _patternNames[REC_IDEAL1_ABCD]="Rec. Ideal AB=CD #1";
   _patterns[REC_IDEAL2_ABCD]=rec_ideal2_abcd; _patternNames[REC_IDEAL2_ABCD]="Rec. Ideal AB=CD #2";
   _patterns[REC_RANGELIKE_ABCD]=rec_rangelike_abcd; _patternNames[REC_RANGELIKE_ABCD]="Rec. Rangelike AB=CD";
   _patterns[GARTLEY]=gartley; _patternNames[GARTLEY]="Gartley";
   _patterns[BAT]=bat; _patternNames[BAT]="Bat";
   _patterns[ALTBAT]=altbat; _patternNames[ALTBAT]="Alt. Bat";
   _patterns[FIVEO]=fiveo; _patternNames[FIVEO]="5-0";
   _patterns[BUTTERFLY]=butterfly; _patternNames[BUTTERFLY]="Butterfly";
   _patterns[CRAB]=crab; _patternNames[CRAB]="Crab";
   _patterns[DEEPCRAB]=deepcrab; _patternNames[DEEPCRAB]="Deep Crab";
   _patterns[THREEDRIVES]=threedrives; _patternNames[THREEDRIVES]="Three Drives";
   _patterns[CYPHER]=cypher; _patternNames[CYPHER]="Cypher";
   _patterns[SHARK]=shark; _patternNames[SHARK]="Shark";
   _patterns[NENSTAR]=nenstar; _patternNames[NENSTAR]="Nen Star";
   _patterns[BLACKSWAN]=blackswan; _patternNames[BLACKSWAN]="Black Swan";
   _patterns[WHITESWAN]=whiteswan; _patternNames[WHITESWAN]="White Swan";
   _patterns[ONE2ONE]=one2one; _patternNames[ONE2ONE]="One2One";
   _patterns[NEWCYPHER]=newcypher; _patternNames[NEWCYPHER]="New Cypher";
   _patterns[NAVARRO200]=navarro200; _patternNames[NAVARRO200]="Navarro 200";
   _patterns[LEONARDO]=leonardo; _patternNames[LEONARDO]="Leonardo";
   _patterns[KANE]=kane; _patternNames[KANE]="Kane";
   _patterns[GARFLY]=garfly; _patternNames[GARFLY]="Garfly";
   _patterns[MAXBAT]=maxbat; _patternNames[MAXBAT]="Max. Bat";
   _patterns[MAXGARTLEY]=maxgartley; _patternNames[MAXGARTLEY]="Max. Gartley";
   _patterns[MAXBUTTERFLY]=maxbutterfly; _patternNames[MAXBUTTERFLY]="Max. Butterfly";
   _patterns[GARTLEY113]=gartley113; _patternNames[GARTLEY113]="Gartley 113";
   _patterns[BUTTERFLY113]=butterfly113; _patternNames[BUTTERFLY113]="Butterfly 113";
   _patterns[ANTI_GARTLEY]=anti_gartley; _patternNames[ANTI_GARTLEY]="Anti Gartley";
   _patterns[ANTI_BAT]=anti_bat; _patternNames[ANTI_BAT]="Anti Bat";
   _patterns[ANTI_ALTBAT]=anti_altbat; _patternNames[ANTI_ALTBAT]="Anti Alt. Bat";
   _patterns[ANTI_FIVEO]=anti_fiveo; _patternNames[ANTI_FIVEO]="Anti 5-0";
   _patterns[ANTI_BUTTERFLY]=anti_butterfly; _patternNames[ANTI_BUTTERFLY]="Anti Butterfly";
   _patterns[ANTI_CRAB]=anti_crab; _patternNames[ANTI_CRAB]="Anti Crab";
   _patterns[ANTI_DEEPCRAB]=anti_deepcrab; _patternNames[ANTI_DEEPCRAB]="Anti Deep Crab";
   _patterns[ANTI_THREEDRIVES]=anti_threedrives; _patternNames[ANTI_THREEDRIVES]="Anti Three Drives";
   _patterns[ANTI_CYPHER]=anti_cypher; _patternNames[ANTI_CYPHER]="Anti Cypher";
   _patterns[ANTI_SHARK]=anti_shark; _patternNames[ANTI_SHARK]="Anti Shark";
   _patterns[ANTI_NENSTAR]=anti_nenstar; _patternNames[ANTI_NENSTAR]="Anti Nen Star";
   _patterns[ANTI_BLACKSWAN]=anti_blackswan; _patternNames[ANTI_BLACKSWAN]="Anti Black Swan";
   _patterns[ANTI_WHITESWAN]=anti_whiteswan; _patternNames[ANTI_WHITESWAN]="Anti White Swan";
   _patterns[ANTI_ONE2ONE]=anti_one2one; _patternNames[ANTI_ONE2ONE]="Anti One2One";
   _patterns[ANTI_NEWCYPHER]=anti_newcypher; _patternNames[ANTI_NEWCYPHER]="Anti New Cypher";
   _patterns[ANTI_NAVARRO200]=anti_navarro200; _patternNames[ANTI_NAVARRO200]="Anti Navarro 200";
   _patterns[ANTI_LEONARDO]=anti_leonardo; _patternNames[ANTI_LEONARDO]="Anti Leonardo";
   _patterns[ANTI_KANE]=anti_kane; _patternNames[ANTI_KANE]="Anti Kane";
   _patterns[ANTI_GARFLY]=anti_garfly; _patternNames[ANTI_GARFLY]="Anti Garfly";
   _patterns[ANTI_MAXBAT]=anti_maxbat; _patternNames[ANTI_MAXBAT]="Anti Max. Bat";
   _patterns[ANTI_MAXGARTLEY]=anti_maxgartley; _patternNames[ANTI_MAXGARTLEY]="Anti Max. Gartley";
   _patterns[ANTI_MAXBUTTERFLY]=anti_maxbutterfly; _patternNames[ANTI_MAXBUTTERFLY]="Anti Max. Butterfly";
   _patterns[ANTI_GARTLEY113]=anti_gartley113; _patternNames[ANTI_GARTLEY113]="Anti Gartley 113";
   _patterns[ANTI_BUTTERFLY113]=anti_butterfly113; _patternNames[ANTI_BUTTERFLY113]="Anti Butterfly 113";
   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
//| Helper method creates hexadecimal encoding of datetimes          |
//+------------------------------------------------------------------+
string UniqueIdentifier(datetime ADateTime,datetime BDateTime,datetime CDateTime,datetime DDateTime)
  {
   return " "+StringFormat("%x",ADateTime)+StringFormat("%x",BDateTime)+StringFormat("%x",CDateTime)+StringFormat("%x",DDateTime);
  }
//+------------------------------------------------------------------+
//| Helper method creates hexadecimal encoding of datetimes          |
//+------------------------------------------------------------------+
string UniqueIdentifier(datetime XDateTime,datetime ADateTime,datetime BDateTime,datetime CDateTime,datetime DDateTime)
  {
   return " "+StringFormat("%x",XDateTime)+StringFormat("%x",ADateTime)+StringFormat("%x",BDateTime)+StringFormat("%x",CDateTime)+StringFormat("%x",DDateTime);
  }
//+------------------------------------------------------------------+

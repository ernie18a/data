//+------------------------------------------------------------------+
//|                                        HarmonicPatternFinder.mq5 |
//|                                  Copyright 2016, André S. Enger. |
//|                                          andre_enger@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Andre S. Enger."
#property link      "andre_enger@hotmail.com"
#property version   "1.00"
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
  };
//--- Identifies drawn patterns
struct PATTERN_INSTANCE
  {
   int               patternIndex;
   int               patternBufferIndex;
   bool              bullish;
   datetime          XDateTime;
   datetime          ADateTime;
   datetime          BDateTime;
   datetime          CDateTime;
   datetime          DDateTime;
  };

//--- Inputs
input int SwingSize=100;          //ZZ sensitivity in points
input double SlackRange=0.01;     //Max slack for fib ratios (range)
input double SlackUnary=0.1;        //Max slack for fib ratios (unary)
input int BarsAnalyzed=200;       //Max bars per pattern
input int History=1000;           //Max history bars to process
input int MaxSamePoints=0;        //Max shared points per pattern
input bool EmergingPatterns=false;//Enable emerging pattern projections
input int NumProjectionTries=100; //Number of projections
input double AtrIncrement=0.1;    //Increment per projection in ATRs
input int AtrPeriod=50;           //ATR-period used in projections
input color ClrBull=clrGreen;           //Color for bullish patterns
input color ClrBear=clrRed;              //Color for bearish patterns
input color ClrBullProjection=clrAquamarine;  //Color for projected bullish patterns
input color ClrBearProjection=clrHotPink;     //Color for projected bearish patterns
input bool Show_abcd=true;        //Display AB=CD
input bool Show_gartley=true;     //Display Gartley
input bool Show_bat=true;         //Display Bat
input bool Show_altbat=true;      //Display Alt. Bat
input bool Show_butterfly=true;   //Display Butterfly
input bool Show_crab=true;        //Display Crab
input bool Show_deepcrab=true;    //Display Deepcrab
input bool Show_threedrives=true; //Display Three Drives
input bool Show_cypher=true;      //Display Cypher
input bool Show_shark=true;       //Display Shark
input bool Show_fiveo=true;       //Display 5-0
input bool Show_nenstar=true;     //Display Nen Star
input bool Show_blackswan=true;   //Display Black Swan
input bool Show_whiteswan=true;   //Display White Swan

//--- Constant macro
#define SIZE_PATTERN_BUFFER 10

//--- Indicator buffer arrays
double peaks[],troughs[];

//--- Globals
bool lastDirection;
double _atr;
int _lastPeak;
int _lastTrough;
int maxPatternInstances;
int zzHandle;
int numPatterns;
int patternInstanceCounter;
int monotonicIndices[];
int monotonicIndicesCounter[];
int patternCounter[];
PATTERN_DESCRIPTOR patterns[];
PATTERN_INSTANCE patternInstances[];
string patternNames[];
datetime patternX[][SIZE_PATTERN_BUFFER];
datetime patternA[][SIZE_PATTERN_BUFFER];
datetime patternB[][SIZE_PATTERN_BUFFER];
datetime patternC[][SIZE_PATTERN_BUFFER];
datetime patternD[][SIZE_PATTERN_BUFFER];
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
   zzHandle=iCustom(NULL,0,"Downloads\\fastzz",SwingSize);
   if(zzHandle==INVALID_HANDLE)
      printf("Error obtaining handle");
   if(ArrayResize(monotonicIndices,BarsAnalyzed)<BarsAnalyzed)
      printf("Error allocating array");
   if(ArrayResize(monotonicIndicesCounter,BarsAnalyzed)<BarsAnalyzed)
      printf("Error allocating array");
   PopulatePatterns();
//--- set globals
   _atr=0.0;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Indicator deinitialization function                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   ArrayFree(monotonicIndices);
   ArrayFree(monotonicIndicesCounter);
   ArrayFree(patterns);
   ArrayFree(patternInstances);
   ArrayFree(patternNames);
   ArrayFree(patternCounter);
   ArrayFree(patternX);
   ArrayFree(patternA);
   ArrayFree(patternB);
   ArrayFree(patternC);
   ArrayFree(patternD);
   for(int i=ObjectsTotal(0,0,-1)-1; i>=0; i--)
     {
      string name=ObjectName(0,i,0,-1);
      if(StringFind(name,"Bullish")!=-1 || StringFind(name,"Bearish")!=-1)
         ObjectDelete(0,name);
     }
  }
//+------------------------------------------------------------------+
//| Indicator reinitialization function                              |
//+------------------------------------------------------------------+
void OnReinit()
  {
//----
   _atr=0;
   _lastPeak=0;
   _lastTrough=0;
   patternInstanceCounter=0;
   ArrayFill(patternCounter,0,numPatterns,0);
   for(int i=0; i<numPatterns; i++)
     {
      for(int j=0; j<SIZE_PATTERN_BUFFER; j++)
        {
         patternX[i][j]=0;
         patternA[i][j]=0;
         patternB[i][j]=0;
         patternC[i][j]=0;
         patternD[i][j]=0;
        }
     }
   for(int i=ObjectsTotal(0,0,-1)-1; i>=0; i--)
     {
      string name=ObjectName(0,i,0,-1);
      if(StringFind(name,"Bullish")!=-1 || StringFind(name,"Bearish")!=-1)
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
   int start;
   if(prev_calculated>rates_total || prev_calculated<=0)
     {
      OnReinit();
      start=0;
     }
   else
      start=prev_calculated-1;
   start=MathMax(1,start);
//--- copy data
   CopyBuffer(zzHandle,0,0,rates_total,peaks);
   CopyBuffer(zzHandle,1,0,rates_total,troughs);
   double atr=_atr;
//--- main loop
   for(int bar=start; bar<rates_total; bar++)
     {
      //--- Only use new and most recent bars
      if(bar<rates_total-History)
         continue;
      //--- Update ATR for calculating projections
      double tr=MathMax(high[bar],close[bar-1])-MathMin(low[bar],close[bar-1]);
      atr+=(tr-atr)*(2.0/(1.0+AtrPeriod));
      if(bar<rates_total-1)
         _atr=atr;
      //--- Scan for patterns ending in trough or peak?
      int lastPeak=FirstNonZeroFrom(bar,peaks);
      int lastTrough=FirstNonZeroFrom(bar,troughs);
      if(lastPeak==-1 || lastTrough==-1) continue;
      bool endsInTrough=lastTrough>lastPeak;
      bool verticalZZ=lastTrough==lastPeak;
      bool zzUp=!endsInTrough;
      //--- If last peak and trough are same, nothing has changed from perspective of indicator
      if(lastPeak==_lastPeak && lastTrough==_lastTrough) continue;
      _lastPeak=lastPeak;
      _lastTrough=lastTrough;
      //--- If the ZZ is vertical, it is pointing up if the first non-vertical bar is up and vice versa
      if(verticalZZ)
        {
         int lastPeakBefore=FirstNonZeroFrom(lastPeak-1,peaks);
         int lastTroughBefore=FirstNonZeroFrom(lastTrough - 1,troughs);
         while(lastPeakBefore==lastTroughBefore)
           {
            lastPeakBefore=FirstNonZeroFrom(lastPeakBefore-1,peaks);
            lastTroughBefore=FirstNonZeroFrom(lastTroughBefore-1,troughs);
            if(lastPeakBefore==-1 || lastTroughBefore==-1) break;
           }
         if(lastPeakBefore==-1 || lastTroughBefore==-1) continue;
         zzUp=lastPeakBefore>lastTroughBefore;
         endsInTrough=!zzUp;
        }
      //--- Remove old projections on new tick in same direction
      for(int patternIndex=0; patternIndex<numPatterns; patternIndex++)
        {
         if(verticalZZ)
           {
            UndisplayProjection(patternIndex,true);
            UndisplayProjection(patternIndex,false);
           }
         else
            UndisplayProjection(patternIndex,endsInTrough);
        }
      //--- Remove old patterns on new tick and same direction to avoid having overshot patterns remain
      if(!verticalZZ && lastDirection==endsInTrough)
         UndisplayPatterns();
      patternInstanceCounter=0;
      lastDirection=endsInTrough;
      //--- Flag to run the below loop twice in the case of vertical ZZ
      bool runTwice=verticalZZ;

      //--- Loop code to try different values of D if searching for emerging patterns
      int maxProjections=EmergingPatterns ? NumProjectionTries : 1;
      for(int projection=0; projection<maxProjections; projection++)
        {
         double increment=EmergingPatterns ?(maxProjections-projection-1)*(atr*AtrIncrement) : 0;
         //--- Set point D as most recent trough (peak) +- an increment for emerging pattern projection
         int DIndex=endsInTrough ? lastTrough : lastPeak;
         double D=endsInTrough ? troughs[DIndex]-increment : peaks[DIndex]+increment;
         //--- Reset arrays before finding subsequent extrema
         ArrayFill(monotonicIndices,0,BarsAnalyzed,-1);
         ArrayFill(monotonicIndicesCounter,0,BarsAnalyzed,-1);
         //--- First extremum, a potential point C, is the most recent peak (trough)
         int firstExtreme=endsInTrough ? lastPeak : lastTrough;
         //--- ...Unless the ZZ is vertical, where the most recent peak must be skipped for up ZZ
         if(verticalZZ)
           {
            if(endsInTrough && zzUp)
               firstExtreme=FirstNonZeroFrom(lastPeak-1,peaks);
            if(!endsInTrough && !zzUp)
               firstExtreme=FirstNonZeroFrom(lastTrough-1,troughs);
           }
         int numExtremums=0;
         monotonicIndices[numExtremums]=firstExtreme;
         //--- Successive peaks (troughs) must be earlier and monotonically increasing (decreasing)
         for(int i=firstExtreme-1; i>=MathMax(0,DIndex-BarsAnalyzed); i--)
           {
            double currentExtreme=endsInTrough ? peaks[i]: troughs[i];
            //--- Check if the ZZ identified the current point as an extremum
            if(!IsProperValue(currentExtreme)) continue;
            double previousExtreme=endsInTrough ? peaks[monotonicIndices[numExtremums]] : troughs[monotonicIndices[numExtremums]];
            //--- If so, check if it is higher (lower) in order to only consider increasing peaks (decreasing troughs)
            if((endsInTrough && currentExtreme>previousExtreme)
               || (!endsInTrough && currentExtreme<previousExtreme))
              {
               numExtremums++;
               monotonicIndices[numExtremums]=i;
              }
           }
         numExtremums++;
         //--- Storing the in-between lows (highs) allows for efficient retrieval on the patterns which have higher tops (lower bottoms)
         for(int i=0; i<numExtremums-1; i++)
           {
            int youngerExtreme=monotonicIndices[i];
            int olderExtreme=monotonicIndices[i+1];
            int counterExtreme=endsInTrough ? LowestFromTo(olderExtreme,youngerExtreme,troughs) : HighestFromTo(olderExtreme,youngerExtreme,peaks);
            //--- If none could be found (should not normally happen) use the lowest point
            if(counterExtreme==-1)
               counterExtreme= endsInTrough ? LowestFromTo(olderExtreme,youngerExtreme,low) : HighestFromTo(olderExtreme,youngerExtreme,high);
            if(counterExtreme==-1)
               continue;
            monotonicIndicesCounter[i]=counterExtreme;
           }
         //--- Check each pattern for matches
         for(int patternIndex=0; patternIndex<numPatterns; patternIndex++)
           {
            //--- Check if pattern should be displayed
            if(patternIndex==0 && !Show_abcd) continue;
            if(patternIndex==1 && !Show_gartley) continue;
            if(patternIndex==2 && !Show_bat) continue;
            if(patternIndex==3 && !Show_altbat) continue;
            if(patternIndex==4 && !Show_butterfly) continue;
            if(patternIndex==5 && !Show_crab) continue;
            if(patternIndex==6 && !Show_deepcrab) continue;
            if(patternIndex==7 && !Show_threedrives) continue;
            if(patternIndex==8 && !Show_cypher) continue;
            if(patternIndex==9 && !Show_shark) continue;
            if(patternIndex==10 && !Show_fiveo) continue;
            if(patternIndex==11 && !Show_nenstar) continue;
            if(patternIndex==12 && !Show_blackswan) continue;
            if(patternIndex==13 && !Show_whiteswan) continue;
            PATTERN_DESCRIPTOR pattern=patterns[patternIndex];
            //--- What constraints does the pattern have?
            bool ab2xaConstraint=pattern.ab2xa_max!=0 && pattern.ab2xa_min!=0;
            bool ad2xaConstraint=pattern.ad2xa_max!=0 && pattern.ad2xa_min!=0;
            bool bc2abConstraint=pattern.bc2ab_max!=0 && pattern.bc2ab_min!=0;
            bool cd2bcConstraint=pattern.cd2bc_max!=0 && pattern.cd2bc_min!=0;
            bool cd2xcConstraint=pattern.cd2xc_max!=0 && pattern.cd2xc_min!=0;
            bool xc2xaConstraint=pattern.xc2xa_max!=0 && pattern.xc2xa_min!=0;
            //--- Which constraints are unary vs range?
            double ab2xaSlack=pattern.ab2xa_max==pattern.ab2xa_min ? SlackUnary : SlackRange;
            double ad2xaSlack=pattern.ad2xa_max==pattern.ad2xa_min ? SlackUnary : SlackRange;
            double bc2abSlack=pattern.bc2ab_max==pattern.bc2ab_min ? SlackUnary : SlackRange;
            double cd2bcSlack=pattern.cd2bc_max==pattern.cd2bc_min ? SlackUnary : SlackRange;
            double cd2xcSlack=pattern.cd2xc_max==pattern.cd2xc_min ? SlackUnary : SlackRange;
            double xc2xaSlack=pattern.xc2xa_max==pattern.xc2xa_min ? SlackUnary : SlackRange;
            //--- How does the tops and bottoms relate?
            bool insideA=true;
            if(bc2abConstraint) insideA=pattern.bc2ab_min>1.0;
            if(xc2xaConstraint) insideA=pattern.xc2xa_min>1.0;
            bool insideB=true;
            if(cd2bcConstraint) insideB=pattern.cd2bc_min>1.0;
            //--- First loop checks for C-points, which are always monotonically increasing (decreasing)
            bool patternPossible=true;
            for(int k=0; k<numExtremums; k++)
              {
               int CIndex=monotonicIndices[k];
               double C=endsInTrough ? peaks[CIndex]: troughs[CIndex];
               double CD=MathAbs(C-D);
               //--- Ensure that D is the extremum on [C, D], i.e. there is no lower low (higher high)
               int counterExtremeIndex;
               if(k==0)
                  counterExtremeIndex=endsInTrough ? LowestFromTo(CIndex,DIndex,troughs) : HighestFromTo(CIndex,DIndex,peaks);
               else
                  counterExtremeIndex=monotonicIndicesCounter[k-1];
               double counterExtremeValue=endsInTrough ? troughs[counterExtremeIndex]: peaks[counterExtremeIndex];
               if((endsInTrough && counterExtremeValue<D) || (!endsInTrough && counterExtremeValue>D))
                 {
                  patternPossible=false;
                  break;
                 }
               //--- Loop which handles both the cases A > C (finding A in the monotonic indices from k)
               //--- and the case where A < C e.g. Shark and Cypher (finding A by leftwards search from CIndex)
               int previousBIndex=0;
               double previousB=endsInTrough ? DBL_MIN : DBL_MAX;
               double previousA=endsInTrough ? DBL_MIN : DBL_MAX;
               int k2=insideA ? CIndex : k;
               while(true)
                 {
                  //--- Dual loop condition
                  int AIndex;
                  if(insideA)
                    {
                     //--- Leftwards search using the raw troughs/peaks
                     k2--;
                     if(k2<MathMax(0,DIndex-BarsAnalyzed)) break;
                     AIndex=k2;
                    }
                  else
                    {
                     //--- Search using the monontonically increasing/decreasing troughs/peaks
                     k2++;
                     if(k2>=numExtremums) break;
                     AIndex=monotonicIndices[k2];
                    }
                  //--- Get A
                  double A=endsInTrough ? peaks[AIndex]: troughs[AIndex];
                  if(!IsProperValue(A)) continue;
                  //--- If inside A and there is a high between A-C higher than C the pattern must use that high-point as a C
                  if(insideA && ((endsInTrough && A>C) || (!endsInTrough && A<C)))
                     break;
                  int newBIndex;
                  //--- If not insideA, then B can be efficently retrieved in the counterindices, otherwise do linear search
                  if(!insideA)
                     newBIndex=monotonicIndicesCounter[k2-1];
                  else
                     newBIndex=endsInTrough ? LowestFromTo(AIndex,CIndex,troughs) : HighestFromTo(AIndex,CIndex,peaks);
                  if(newBIndex== -1)
                    {
                     patternPossible=false;
                     break;
                    }
                  double newB=endsInTrough ? troughs[newBIndex]: peaks[newBIndex];
                  bool newBLower=(endsInTrough && newB<previousB) || (!endsInTrough && newB>previousB);
                  if(!insideA)
                    {
                     //--- Each A attempt is higher than C, so a lower B means the previous A was a peak on [B, C]
                     if(newBLower)
                        break;
                     //--- Set previousB if not set (must be minimal/maximal)
                     if((endsInTrough && previousB==DBL_MIN) || (!endsInTrough && previousB==DBL_MAX))
                       {
                        previousBIndex=newBIndex;
                        previousB=newB;
                       }
                    }
                  else
                    {
                     //--- If lower B (or not set) save it as well as the A
                     if(newBLower || ((endsInTrough && previousB==DBL_MIN) || (!endsInTrough && previousB==DBL_MAX)))
                       {
                        previousBIndex=newBIndex;
                        previousB=newB;
                        previousA=A;
                       }
                     //--- A must be the peak on [A, B]
                     if((endsInTrough && A<previousA) || (!endsInTrough && A>previousA))
                        continue;
                     previousA=A;
                    }
                  int BIndex=previousBIndex;
                  double B=previousB;
                  double AB=MathAbs(A-B);
                  double BC=MathAbs(C-B);
                  double AD=MathAbs(A-D);
                  //--- To avoid divvision by zero
                  if(AB==0) continue;
                  if(BC==0) continue;
                  if(AD==0) continue;
                  double bc2abRatio=BC/AB;
                  double cd2bcRatio=CD/BC;
                  //--- If inside B and there is a low between A-C lower than D the pattern cannot be valid
                  if(insideB && ((endsInTrough && B<D) || (!endsInTrough && B>D)))
                    {
                     patternPossible=false;
                     break;
                    }
                  bool bc2abConstraintSatisfied=!bc2abConstraint;
                  bc2abConstraintSatisfied|=(pattern.bc2ab_min-bc2abSlack<=bc2abRatio && bc2abRatio<=pattern.bc2ab_max+bc2abSlack);
                  bool cd2bcConstraintSatisfied=!cd2bcConstraint;
                  cd2bcConstraintSatisfied|=(pattern.cd2bc_min-cd2bcSlack<=cd2bcRatio && cd2bcRatio<=pattern.cd2bc_max+cd2bcSlack);
                  //--- Check if the relevant fibonacci ratios are satisfied w.r.t. A, B, C, D
                  if(bc2abConstraintSatisfied && cd2bcConstraintSatisfied)
                    {
                     //--- AB=CD should be matched already
                     if(!ab2xaConstraint && !ad2xaConstraint && !cd2xcConstraint && !xc2xaConstraint)
                       {
                        if(projection==maxProjections-1)
                           DisplayPattern(patternIndex,endsInTrough,time[AIndex],A,time[BIndex],B,time[CIndex],C,time[DIndex],D);
                        else
                           DisplayProjection(patternIndex,endsInTrough,time[AIndex],A,time[BIndex],B,time[CIndex],C,time[bar],D);
                        patternPossible=false; //Dont draw multiple matches just changing the A
                        break;
                       }
                     //--- Search for X by going leftwards
                     double previousX=endsInTrough ? DBL_MAX : DBL_MIN;
                     for(int k3=AIndex-1; k3>=MathMax(0,DIndex-BarsAnalyzed); k3--)
                       {
                        //--- If a higher A is encountered - that invalidates the current A
                        double intermediateExtreme=endsInTrough ? peaks[k3]: troughs[k3];
                        if(IsProperValue(intermediateExtreme) && ((endsInTrough && intermediateExtreme>A) || (!endsInTrough && intermediateExtreme<A)))
                           break;
                        double X=endsInTrough ? troughs[k3]: peaks[k3];
                        if(!IsProperValue(X)) continue;
                        //--- Valid X must be lowest on XA leg
                        if((endsInTrough && X>previousX) || (!endsInTrough && X<previousX))
                           continue;
                        previousX=X;
                        double XA=MathAbs(A-X);
                        double XC=MathAbs(X-C);
                        if(XA==0) continue;
                        if(XC==0) continue;
                        double xabRatio=AB/XA;
                        double xadRatio=AD/XA;
                        double cd2xcRatio=CD/XC;
                        double xc2xaRatio=XC/XA;
                        bool ab2xaConstraintSatisfied=!ab2xaConstraint;
                        ab2xaConstraintSatisfied|=(pattern.ab2xa_min-ab2xaSlack<=xabRatio && xabRatio<=pattern.ab2xa_max+ab2xaSlack);
                        bool ad2xaConstraintSatisfied=!ad2xaConstraint;
                        ad2xaConstraintSatisfied|=(pattern.ad2xa_min-ad2xaSlack<=xadRatio && xadRatio<=pattern.ad2xa_max+ad2xaSlack);
                        bool cd2xcConstraintSatisfied=!cd2xcConstraint;
                        cd2xcConstraintSatisfied|=(pattern.cd2xc_min-cd2xcSlack<=cd2xcRatio && cd2xcRatio<=pattern.cd2xc_max+cd2xcSlack);
                        bool xc2xaConstraintSatisfied=!xc2xaConstraint;
                        xc2xaConstraintSatisfied|=(pattern.xc2xa_min-xc2xaSlack<=xc2xaRatio && xc2xaRatio<=pattern.xc2xa_max+xc2xaSlack);
                        if(ab2xaConstraintSatisfied && ad2xaConstraintSatisfied && cd2xcConstraintSatisfied && xc2xaConstraintSatisfied)
                          {
                           if(projection==maxProjections-1)
                              DisplayPattern(patternIndex,endsInTrough,time[k3],X,time[AIndex],A,time[BIndex],B,time[CIndex],C,time[DIndex],D);
                           else
                              DisplayProjection(patternIndex,endsInTrough,time[k3],X,time[AIndex],A,time[BIndex],B,time[CIndex],C,time[bar],D);
                           patternPossible=false;
                           break;
                          }
                       }
                    }
                 }
               if(!patternPossible)
                  break;
              }
           }
         if(runTwice && projection==maxProjections-1)
           {
            projection=-1;
            runTwice=false;
            endsInTrough=!endsInTrough;
           }
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

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
//| Helper method finds lowest proper value in range                 |
//+------------------------------------------------------------------+
int LowestFromTo(int start,int end,const double &array[])
  {
   double min=DBL_MAX;
   int index=-1;
   for(int i=start; i<=end; i++)
      if(IsProperValue(array[i]) && array[i]<=min)
        {
         min=array[i];
         index=i;
        }
   return index;
  }
//+------------------------------------------------------------------+
//| Helper method finds highest proper value in range                |
//+------------------------------------------------------------------+
int HighestFromTo(int start,int end,const double &array[])
  {
   double max=DBL_MIN;
   int index=-1;
   for(int i=start; i<=end; i++)
      if(IsProperValue(array[i]) && array[i]>=max)
        {
         max=array[i];
         index=i;
        }
   return index;
  }
//+------------------------------------------------------------------+
//| Helper method determines proper value                            |
//+------------------------------------------------------------------+
bool IsProperValue(double value)
  {
   return value!=0 && value!=EMPTY_VALUE;
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
   string unique=" "+TimeToString(ADateTime)+TimeToString(BDateTime)+TimeToString(CDateTime)+TimeToString(DDateTime);
   string prefix=(bullish ? "Bullish " : "Bearish ");
   string name0=prefix+patternNames[k]+" AB"+unique;
   string name1=prefix+patternNames[k]+" BC"+unique;
   string name2=prefix+patternNames[k]+" CD"+unique;
//--- Dont redraw same object
   if(ObjectFind(0,name0)>=0)
      return;
   bool overlaps=false;
   for(int i=0; i<SIZE_PATTERN_BUFFER; i++)
     {
      int numMatches=0;
      if(ADateTime==patternA[k][i]) numMatches++;
      if(BDateTime==patternB[k][i]) numMatches++;
      if(CDateTime==patternC[k][i]) numMatches++;
      if(DDateTime==patternD[k][i]) numMatches++;
      if(numMatches>MaxSamePoints)
        {
         overlaps=true;
         break;
        }
     }
//--- Dont draw if another instance of pattern already drawn, and this instance has many of the same points
   if(overlaps)
      return;
//--- If drawn, store the points such that they may be queried by another call
   int index=patternCounter[k];
   patternCounter[k]=(index+1)%SIZE_PATTERN_BUFFER;
   patternA[k][index]=ADateTime;
   patternB[k][index]=BDateTime;
   patternC[k][index]=CDateTime;
   patternD[k][index]=DDateTime;

//--- Create lines on the chart
   ObjectCreate(0,name0,OBJ_TREND,0,ADateTime,A,BDateTime,B);
   ObjectCreate(0,name1,OBJ_TREND,0,BDateTime,B,CDateTime,C);
   ObjectCreate(0,name2,OBJ_ARROWED_LINE,0,CDateTime,C,DDateTime,D);
   ObjectSetInteger(0,name0,OBJPROP_COLOR, bullish ? ClrBull : ClrBear);
   ObjectSetInteger(0,name1,OBJPROP_COLOR, bullish ? ClrBull : ClrBear);
   ObjectSetInteger(0,name2,OBJPROP_COLOR, bullish ? ClrBull : ClrBear);
   ObjectSetInteger(0,name0,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name1,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name2,OBJPROP_SELECTABLE,true);
   ObjectSetString(0,name0,OBJPROP_TOOLTIP,StringSubstr(name0,0,StringLen(name0)-StringLen(unique)));
   ObjectSetString(0,name1,OBJPROP_TOOLTIP,StringSubstr(name1,0,StringLen(name1)-StringLen(unique)));
   ObjectSetString(0,name2,OBJPROP_TOOLTIP,StringSubstr(name2,0,StringLen(name2)-StringLen(unique)));

//--- If there is a projection of the same pattern, undisplay it
   if(EmergingPatterns)
      UndisplayProjection(k,bullish);

   patternInstances[patternInstanceCounter].patternIndex=k;
   patternInstances[patternInstanceCounter].patternBufferIndex=index;
   patternInstances[patternInstanceCounter].bullish=bullish;
   patternInstances[patternInstanceCounter].ADateTime=ADateTime;
   patternInstances[patternInstanceCounter].BDateTime=BDateTime;
   patternInstances[patternInstanceCounter].CDateTime=CDateTime;
   patternInstances[patternInstanceCounter].DDateTime=DDateTime;
   patternInstanceCounter++;
   if(patternInstanceCounter>=maxPatternInstances)
     {
      maxPatternInstances*=2;
      if(ArrayResize(patternInstances,maxPatternInstances)<maxPatternInstances)
         printf("Error allocating array");
     }
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
   string unique=" "+TimeToString(XDateTime)+TimeToString(ADateTime)+TimeToString(BDateTime)+TimeToString(CDateTime)+TimeToString(DDateTime);
   string prefix=(bullish ? "Bullish " : "Bearish ");
   string name0=prefix+patternNames[k]+" XA"+unique;
   string name1=prefix+patternNames[k]+" AB"+unique;
   string name2=prefix+patternNames[k]+" BC"+unique;
   string name3=prefix+patternNames[k]+" CD"+unique;
   string name4=prefix+patternNames[k]+" XAB="+unique;
   string name5=prefix+patternNames[k]+" XAD="+unique;
   string name6=prefix+patternNames[k]+" ABC="+unique;
   string name7=prefix+patternNames[k]+" BCD="+unique;
   if(ObjectFind(0,name0)>=0)
      return;
   bool overlaps=false;
   for(int i=0; i<SIZE_PATTERN_BUFFER; i++)
     {
      int numMatches=0;
      if(XDateTime==patternX[k][i]) numMatches++;
      if(ADateTime==patternA[k][i]) numMatches++;
      if(BDateTime==patternB[k][i]) numMatches++;
      if(CDateTime==patternC[k][i]) numMatches++;
      if(DDateTime==patternD[k][i]) numMatches++;
      if(numMatches>MaxSamePoints)
        {
         overlaps=true;
         break;
        }
     }
   if(overlaps)
      return;
   int index=patternCounter[k];
   patternCounter[k]=(index+1)%SIZE_PATTERN_BUFFER;
   patternX[k][index]=XDateTime;
   patternA[k][index]=ADateTime;
   patternB[k][index]=BDateTime;
   patternC[k][index]=CDateTime;
   patternD[k][index]=DDateTime;

   string xab=IntegerToString((int) MathRound(100*MathAbs(A-B)/MathAbs(X-A)));
   string xad=IntegerToString((int) MathRound(100*MathAbs(D-A)/MathAbs(X-A)));
   string abc=IntegerToString((int) MathRound(100*MathAbs(C-B)/MathAbs(B-A)));
   if(k==8 || k==11)
      abc=IntegerToString((int) MathRound(100*MathAbs(X-C)/MathAbs(X-A)));
   string bcd=IntegerToString((int) MathRound(100*MathAbs(C-D)/MathAbs(B-C)));

   ObjectCreate(0,name0,OBJ_TREND,0,XDateTime,X,ADateTime,A);
   ObjectCreate(0,name1,OBJ_TREND,0,ADateTime,A,BDateTime,B);
   ObjectCreate(0,name2,OBJ_TREND,0,BDateTime,B,CDateTime,C);
   ObjectCreate(0,name3,OBJ_ARROWED_LINE,0,CDateTime,C,DDateTime,D);
   ObjectCreate(0,name4,OBJ_TREND,0,XDateTime,X,BDateTime,B);
//--- No X-D for 5-0 (k == 10)
   if(k!=10) ObjectCreate(0,name5,OBJ_TREND,0,XDateTime,X,DDateTime,D);
   ObjectCreate(0,name6,OBJ_TREND,0,ADateTime,A,CDateTime,C);
   ObjectCreate(0,name7,OBJ_TREND,0,BDateTime,B,DDateTime,D);
   ObjectSetInteger(0,name0,OBJPROP_COLOR, bullish ? ClrBull : ClrBear);
   ObjectSetInteger(0,name1,OBJPROP_COLOR, bullish ? ClrBull : ClrBear);
   ObjectSetInteger(0,name2,OBJPROP_COLOR, bullish ? ClrBull : ClrBear);
   ObjectSetInteger(0,name3,OBJPROP_COLOR, bullish ? ClrBull : ClrBear);
   ObjectSetInteger(0,name4,OBJPROP_COLOR, bullish ? ClrBull : ClrBear);
   if(k!=10) ObjectSetInteger(0,name5,OBJPROP_COLOR,bullish ? ClrBull : ClrBear);
   ObjectSetInteger(0,name6,OBJPROP_COLOR, bullish ? ClrBull : ClrBear);
   ObjectSetInteger(0,name7,OBJPROP_COLOR, bullish ? ClrBull : ClrBear);
   ObjectSetInteger(0,name4,OBJPROP_STYLE,STYLE_DOT);
   if(k!=10) ObjectSetInteger(0,name5,OBJPROP_STYLE,STYLE_DOT);
   ObjectSetInteger(0,name6,OBJPROP_STYLE,STYLE_DOT);
   ObjectSetInteger(0,name7,OBJPROP_STYLE,STYLE_DOT);
   ObjectSetInteger(0,name0,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name1,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name2,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name3,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name4,OBJPROP_SELECTABLE,true);
   if(k!=10) ObjectSetInteger(0,name5,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name6,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name7,OBJPROP_SELECTABLE,true);
   ObjectSetString(0,name0,OBJPROP_TOOLTIP,StringSubstr(name0,0,StringLen(name0)-StringLen(unique)));
   ObjectSetString(0,name1,OBJPROP_TOOLTIP,StringSubstr(name1,0,StringLen(name1)-StringLen(unique)));
   ObjectSetString(0,name2,OBJPROP_TOOLTIP,StringSubstr(name2,0,StringLen(name2)-StringLen(unique)));
   ObjectSetString(0,name3,OBJPROP_TOOLTIP,StringSubstr(name3,0,StringLen(name3)-StringLen(unique)));
   ObjectSetString(0,name4,OBJPROP_TOOLTIP,StringSubstr(name4,0,StringLen(name4)-StringLen(unique))+xab);
   if(k!=10) ObjectSetString(0,name5,OBJPROP_TOOLTIP,StringSubstr(name5,0,StringLen(name5)-StringLen(unique))+xad);
   ObjectSetString(0,name6,OBJPROP_TOOLTIP,StringSubstr(name6,0,StringLen(name6)-StringLen(unique))+abc);
   ObjectSetString(0,name7,OBJPROP_TOOLTIP,StringSubstr(name7,0,StringLen(name7)-StringLen(unique))+bcd);

   if(EmergingPatterns)
      UndisplayProjection(k,bullish);

   patternInstances[patternInstanceCounter].patternIndex=k;
   patternInstances[patternInstanceCounter].patternBufferIndex=index;
   patternInstances[patternInstanceCounter].bullish=bullish;
   patternInstances[patternInstanceCounter].XDateTime=XDateTime;
   patternInstances[patternInstanceCounter].ADateTime=ADateTime;
   patternInstances[patternInstanceCounter].BDateTime=BDateTime;
   patternInstances[patternInstanceCounter].CDateTime=CDateTime;
   patternInstances[patternInstanceCounter].DDateTime=DDateTime;
   patternInstanceCounter++;
   if(patternInstanceCounter>=maxPatternInstances)
     {
      maxPatternInstances*=2;
      if(ArrayResize(patternInstances,maxPatternInstances)<maxPatternInstances)
         printf("Error allocating array");
     }
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
   string prefix=(bullish ? "Projected Bullish " : "Projected Bearish ");
   string name0=prefix+patternNames[k]+" AB";
   string name1=prefix+patternNames[k]+" BC";
   string name2=prefix+patternNames[k]+" CD";

   bool overlaps=false;
   for(int i=0; i<SIZE_PATTERN_BUFFER; i++)
     {
      int numMatches=0;
      if(ADateTime==patternA[k][i]) numMatches++;
      if(BDateTime==patternB[k][i]) numMatches++;
      if(CDateTime==patternC[k][i]) numMatches++;
      if(DDateTime==patternD[k][i]) numMatches++;
      if(numMatches>MaxSamePoints)
        {
         overlaps=true;
         break;
        }
     }
//--- Dont draw if another instance of pattern already drawn, and this instance has many of the same points
   if(overlaps)
      return;

   ObjectCreate(0,name0,OBJ_TREND,0,ADateTime,A,BDateTime,B);
   ObjectCreate(0,name1,OBJ_TREND,0,BDateTime,B,CDateTime,C);
   ObjectCreate(0,name2,OBJ_ARROWED_LINE,0,CDateTime,C,DDateTime,D);
   ObjectSetInteger(0,name0,OBJPROP_COLOR, bullish ? ClrBullProjection : ClrBearProjection);
   ObjectSetInteger(0,name1,OBJPROP_COLOR, bullish ? ClrBullProjection : ClrBearProjection);
   ObjectSetInteger(0,name2,OBJPROP_COLOR, bullish ? ClrBullProjection : ClrBearProjection);
   ObjectSetInteger(0,name0,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name1,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name2,OBJPROP_SELECTABLE,true);
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
   string prefix=(bullish ? "Projected Bullish " : "Projected Bearish ");
   string name0=prefix+patternNames[k]+" XA";
   string name1=prefix+patternNames[k]+" AB";
   string name2=prefix+patternNames[k]+" BC";
   string name3=prefix+patternNames[k]+" CD";
   string name4=prefix+patternNames[k]+" XAB=";
   string name5=prefix+patternNames[k]+" XAD=";
   string name6=prefix+patternNames[k]+" ABC=";
   string name7=prefix+patternNames[k]+" BCD=";

   bool overlaps=false;
   for(int i=0; i<SIZE_PATTERN_BUFFER; i++)
     {
      int numMatches=0;
      if(XDateTime==patternX[k][i]) numMatches++;
      if(ADateTime==patternA[k][i]) numMatches++;
      if(BDateTime==patternB[k][i]) numMatches++;
      if(CDateTime==patternC[k][i]) numMatches++;
      if(DDateTime==patternD[k][i]) numMatches++;
      if(numMatches>MaxSamePoints)
        {
         overlaps=true;
         break;
        }
     }
   if(overlaps)
      return;

   string xab=IntegerToString((int) MathRound(100*MathAbs(A-B)/MathAbs(X-A)));
   string xad=IntegerToString((int) MathRound(100*MathAbs(D-A)/MathAbs(X-A)));
   string abc=IntegerToString((int) MathRound(100*MathAbs(C-B)/MathAbs(B-A)));
//--- Cypher and Nen Start have the A-C top as XC/XA instead of CB/BA
   if(k==8 || k==11)
      abc=IntegerToString((int) MathRound(100*MathAbs(X-C)/MathAbs(X-A)));
   string bcd=IntegerToString((int) MathRound(100*MathAbs(C-D)/MathAbs(B-C)));

   ObjectCreate(0,name0,OBJ_TREND,0,XDateTime,X,ADateTime,A);
   ObjectCreate(0,name1,OBJ_TREND,0,ADateTime,A,BDateTime,B);
   ObjectCreate(0,name2,OBJ_TREND,0,BDateTime,B,CDateTime,C);
   ObjectCreate(0,name3,OBJ_ARROWED_LINE,0,CDateTime,C,DDateTime,D);
   ObjectCreate(0,name4,OBJ_TREND,0,XDateTime,X,BDateTime,B);
   if(k!=10) ObjectCreate(0,name5,OBJ_TREND,0,XDateTime,X,DDateTime,D);
   ObjectCreate(0,name6,OBJ_TREND,0,ADateTime,A,CDateTime,C);
   ObjectCreate(0,name7,OBJ_TREND,0,BDateTime,B,DDateTime,D);
   ObjectSetInteger(0,name0,OBJPROP_COLOR, bullish ? ClrBullProjection : ClrBearProjection);
   ObjectSetInteger(0,name1,OBJPROP_COLOR, bullish ? ClrBullProjection : ClrBearProjection);
   ObjectSetInteger(0,name2,OBJPROP_COLOR, bullish ? ClrBullProjection : ClrBearProjection);
   ObjectSetInteger(0,name3,OBJPROP_COLOR, bullish ? ClrBullProjection : ClrBearProjection);
   ObjectSetInteger(0,name4,OBJPROP_COLOR, bullish ? ClrBullProjection : ClrBearProjection);
   if(k!=10) ObjectSetInteger(0,name5,OBJPROP_COLOR,bullish ? ClrBullProjection : ClrBearProjection);
   ObjectSetInteger(0,name6,OBJPROP_COLOR, bullish ? ClrBullProjection : ClrBearProjection);
   ObjectSetInteger(0,name7,OBJPROP_COLOR, bullish ? ClrBullProjection : ClrBearProjection);
   ObjectSetInteger(0,name4,OBJPROP_STYLE,STYLE_DOT);
   ObjectSetInteger(0,name5,OBJPROP_STYLE,STYLE_DOT);
   ObjectSetInteger(0,name6,OBJPROP_STYLE,STYLE_DOT);
   ObjectSetInteger(0,name7,OBJPROP_STYLE,STYLE_DOT);
   ObjectSetInteger(0,name0,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name1,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name2,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name3,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name4,OBJPROP_SELECTABLE,true);
   if(k!=10) ObjectSetInteger(0,name5,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name6,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name7,OBJPROP_SELECTABLE,true);
   ObjectSetString(0,name4,OBJPROP_TOOLTIP,name4+xab);
   if(k!=10) ObjectSetString(0,name5,OBJPROP_TOOLTIP,name5+xad);
   ObjectSetString(0,name6,OBJPROP_TOOLTIP,name6+abc);
   ObjectSetString(0,name7,OBJPROP_TOOLTIP,name7+bcd);

  }
//+------------------------------------------------------------------+
//| Helper method undisplays projections                             |
//+------------------------------------------------------------------+
void UndisplayProjection(int k,bool bullish)
  {
   string prefix=(bullish ? "Projected Bullish " : "Projected Bearish ");
   string name0=prefix+patternNames[k]+" XA";
   string name1=prefix+patternNames[k]+" AB";
   string name2=prefix+patternNames[k]+" BC";
   string name3=prefix+patternNames[k]+" CD";
   string name4=prefix+patternNames[k]+" XAB=";
   string name5=prefix+patternNames[k]+" XAD=";
   string name6=prefix+patternNames[k]+" ABC=";
   string name7=prefix+patternNames[k]+" BCD=";
   ObjectDelete(0,name0);
   ObjectDelete(0,name1);
   ObjectDelete(0,name2);
   ObjectDelete(0,name3);
   ObjectDelete(0,name4);
   ObjectDelete(0,name5);
   ObjectDelete(0,name6);
   ObjectDelete(0,name7);
  }
//+------------------------------------------------------------------+
//| Helper method undisplays recently drawn patterns                 |
//+------------------------------------------------------------------+
void UndisplayPatterns()
  {
   for(int i=0; i<patternInstanceCounter; i++)
     {
      PATTERN_INSTANCE instance=patternInstances[i];
      int k=instance.patternIndex;
      int index=instance.patternBufferIndex;
      bool bullish=instance.bullish;
      datetime XDateTime=instance.XDateTime;
      datetime ADateTime=instance.ADateTime;
      datetime BDateTime=instance.BDateTime;
      datetime CDateTime=instance.CDateTime;
      datetime DDateTime=instance.DDateTime;
      //--- Delete pattern from chart
      string unique=" "+(k==0 ? "" : TimeToString(XDateTime))+TimeToString(ADateTime)+TimeToString(BDateTime)+TimeToString(CDateTime)+TimeToString(DDateTime);
      string prefix=(bullish ? "Bullish " : "Bearish ");
      string name0=prefix+patternNames[k]+" XA"+unique;
      string name1=prefix+patternNames[k]+" AB"+unique;
      string name2=prefix+patternNames[k]+" BC"+unique;
      string name3=prefix+patternNames[k]+" CD"+unique;
      string name4=prefix+patternNames[k]+" XAB="+unique;
      string name5=prefix+patternNames[k]+" XAD="+unique;
      string name6=prefix+patternNames[k]+" ABC="+unique;
      string name7=prefix+patternNames[k]+" BCD="+unique;
      ObjectDelete(0,name0);
      ObjectDelete(0,name1);
      ObjectDelete(0,name2);
      ObjectDelete(0,name3);
      ObjectDelete(0,name4);
      ObjectDelete(0,name5);
      ObjectDelete(0,name6);
      ObjectDelete(0,name7);
      //--- Delete pattern from pattern buffer
      patternX[k][index]=0;
      patternA[k][index]=0;
      patternB[k][index]=0;
      patternC[k][index]=0;
      patternD[k][index]=0;
      int count=patternCounter[k];
      patternCounter[k]=count==0 ? SIZE_PATTERN_BUFFER-1 : count-1;
     }
   patternInstanceCounter=0;
  }
//+------------------------------------------------------------------+
//| Helper method populates pattern arrays                           |
//+------------------------------------------------------------------+
void PopulatePatterns()
  {

//--- Create pattern descriptor structs with relevant ratios
   PATTERN_DESCRIPTOR abcd={ 0,0,0.618,0.786,1.272,1.618,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR gartley={ 0.618,0.618,0.382,0.886,1.272,1.618,0.786,0.786,0,0,0,0 };
   PATTERN_DESCRIPTOR bat={ 0.382,0.5,0.382,0.886,1.618,2.618,0.886,0.886,0,0,0,0 };
   PATTERN_DESCRIPTOR altbat={ 0.382,0.382,0.382,0.886,2,3.618,1.13,1.13,0,0,0,0 };
   PATTERN_DESCRIPTOR butterfly={ 0.786,0.786,0.382,0.886,1.618,2.618,1.272,1.618,0,0,0,0 };
   PATTERN_DESCRIPTOR crab={ 0.382,0.618,0.382,0.886,2.24,3.618,1.618,1.618,0,0,0,0 };
   PATTERN_DESCRIPTOR deepcrab={ 0.886,0.886,0.382,0.886,2.618,3.618,1.618,1.618,0,0,0,0 };
   PATTERN_DESCRIPTOR threedrives={ 1.272,1.618,0.618,0.786,1.272,1.618,0,0,0,0,0,0 };
   PATTERN_DESCRIPTOR cypher={ 0.382,0.618,0,0,0,0,0,0,0.786,0.786,1.13,1.414 };
   PATTERN_DESCRIPTOR shark={ 0, 0, 1.13, 1.618, 1.618, 2.24, 0, 0, 0.886, 1.13, 0, 0 };
   PATTERN_DESCRIPTOR fiveo={ 1.13,1.618,1.618,2.24,0.5,0.5,0,0,0,0,0,0 };
   PATTERN_DESCRIPTOR nenstar={ 0.382,0.618,0,0,0,0,0,0,1.272,1.272,1.13,1.414 };
   PATTERN_DESCRIPTOR blackswan={ 1.382, 2.618, 0.236, 0.5, 1.128, 2, 1.128, 2.618, 0, 0, 0, 0 };
   PATTERN_DESCRIPTOR whiteswan={ 0.382, 0.724, 2, 4.237, 0.5, 0.886, 0.382, 0.886, 0, 0, 0, 0 };

//--- Initialize arrays
   numPatterns=14;
   maxPatternInstances=numPatterns*SIZE_PATTERN_BUFFER;
   if(ArrayResize(patterns,numPatterns)<numPatterns)
      printf("Error allocating array");
   if(ArrayResize(patternNames,numPatterns)<numPatterns)
      printf("Error allocating array");
   if(ArrayResize(patternX,numPatterns)<numPatterns)
      printf("Error allocating array");
   if(ArrayResize(patternA,numPatterns)<numPatterns)
      printf("Error allocating array");
   if(ArrayResize(patternB,numPatterns)<numPatterns)
      printf("Error allocating array");
   if(ArrayResize(patternC,numPatterns)<numPatterns)
      printf("Error allocating array");
   if(ArrayResize(patternD,numPatterns)<numPatterns)
      printf("Error allocating array");
   if(ArrayResize(patternCounter,numPatterns)<numPatterns)
      printf("Error allocating array");
   if(ArrayResize(patternInstances,maxPatternInstances)<maxPatternInstances)
      printf("Error allocating array");
   ArrayFill(patternCounter,0,numPatterns,0);
//--- Fill in the pattern arrays
   patterns[0]=abcd; patternNames[0]="AB=CD";
   patterns[1]=gartley; patternNames[1]="Gartley";
   patterns[2]=bat; patternNames[2]="Bat";
   patterns[3]=altbat; patternNames[3]="Alt. Bat";
   patterns[4]=butterfly; patternNames[4]="Butterfly";
   patterns[5]=crab; patternNames[5]="Crab";
   patterns[6]=deepcrab; patternNames[6]="Deep Crab";
   patterns[7]=threedrives; patternNames[7]="Three Drives";
   patterns[8]=cypher; patternNames[8]="Cypher";
   patterns[9]=shark; patternNames[9]="Shark";
   patterns[10]=fiveo; patternNames[10]="5-0";
   patterns[11]=nenstar; patternNames[11]="Nen Star";
   patterns[12]=blackswan; patternNames[12]="Black Swan";
   patterns[13]=whiteswan; patternNames[13]="White Swan";
  }
//+------------------------------------------------------------------+

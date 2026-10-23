//+------------------------------------------------------------------+
//|                                        HarmonicPatternFinder.mqh |
//|                                  Copyright 2018, André S. Enger. |
//|                                          andre_enger@hotmail.com |
//|                                  Contribs                        |
//|                                         David Gadelha            |
//|                                               dgadelha@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"

//--- Header guard
#ifndef HPFMATCHER_MQH
#define HPFMATCHER_MQH

//--- Heavily used snippet
#define IsProperValue(value) (value!=0 && value!=EMPTY_VALUE)

#include "HPFMatchProcessor.mqh"
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
   double            bc2xa_min;
   double            bc2xa_max;
   double            cd2ad_min;
   double            cd2ad_max;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHPFMatcher
  {
private:
   double            m_slackUnary;
   double            m_slackRange;
   CHPFMatchProcessor *m_matchProcessor;
public:
   void              SetSlackUnary(double slack)                           { m_slackUnary=slack; }
   void              SetSlackRange(double slack)                           { m_slackRange=slack; }
   void              SetMatchProcessor(CHPFMatchProcessor *matchProcessor) { m_matchProcessor=matchProcessor; }
   void              FindPattern(const PATTERN_DESCRIPTOR &pattern,
                                 int startBar,
                                 int endBar,
                                 int lastPeak,
                                 int lastTrough,
                                 const double &peaks[],
                                 const double &troughs[]);
  };
//+------------------------------------------------------------------+
void CHPFMatcher::FindPattern(const PATTERN_DESCRIPTOR &pattern,
                              int startBar,
                              int endBar,
                              int lastPeak,
                              int lastTrough,
                              const double &peaks[],
                              const double &troughs[])
  {
//--- What constraints does the pattern have?
   bool ab2xaConstraint=pattern.ab2xa_max!=0 && pattern.ab2xa_min!=0;
   bool ad2xaConstraint=pattern.ad2xa_max!=0 && pattern.ad2xa_min!=0;
   bool bc2abConstraint=pattern.bc2ab_max!=0 && pattern.bc2ab_min!=0;
   bool cd2bcConstraint=pattern.cd2bc_max!=0 && pattern.cd2bc_min!=0;
   bool cd2xcConstraint=pattern.cd2xc_max!=0 && pattern.cd2xc_min!=0;
   bool xc2xaConstraint=pattern.xc2xa_max!=0 && pattern.xc2xa_min!=0;
   bool cd2abConstraint=pattern.cd2ab_max!=0 && pattern.cd2ab_min!=0;
   bool bc2xaConstraint=pattern.bc2xa_max!=0 && pattern.bc2xa_min!=0;
//--- Which constraints are unary vs range?
   double ab2xaSlack=pattern.ab2xa_max==pattern.ab2xa_min ? m_slackUnary : m_slackRange;
   double ad2xaSlack=pattern.ad2xa_max==pattern.ad2xa_min ? m_slackUnary : m_slackRange;
   double bc2abSlack=pattern.bc2ab_max==pattern.bc2ab_min ? m_slackUnary : m_slackRange;
   double cd2bcSlack=pattern.cd2bc_max==pattern.cd2bc_min ? m_slackUnary : m_slackRange;
   double cd2xcSlack=pattern.cd2xc_max==pattern.cd2xc_min ? m_slackUnary : m_slackRange;
   double xc2xaSlack=pattern.xc2xa_max==pattern.xc2xa_min ? m_slackUnary : m_slackRange;
   double cd2abSlack=pattern.cd2ab_max==pattern.cd2ab_min ? m_slackUnary : m_slackRange;
   double bc2xaSlack=pattern.bc2xa_max==pattern.bc2xa_min ? m_slackUnary : m_slackRange;
//--- Start searching from current bar - 'BarsAnalyzed'
   bool xFirstRun=true;
   for(int XIndex=startBar; XIndex<=endBar && !IsStopped(); XIndex++)
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
         int zzDirection=ZigZagDirection(XIndex,peaks,troughs);
         if(zzDirection==0) continue;
         else if(zzDirection==-1) xZZDirection=false;
         else if(zzDirection==1) xZZDirection=true;
        }
      double X=startsInTrough ? troughs[XIndex]: peaks[XIndex];
      double extremeA=startsInTrough ? DBL_MIN : DBL_MAX;
      //--- Skip first AIndex if vertical zz at X and opposite extremum is before X 
      int aSkip=0;
      if(xVerticalZZ && ((xZZDirection && !startsInTrough) || (!xZZDirection && startsInTrough))) aSkip=1;
      for(int AIndex=XIndex+aSkip; AIndex<=endBar && !IsStopped(); AIndex++)
        {
         //--- Ensure that X is the extremum on [X, A], i.e. there is no lower low (higher high)
         if(XIndex!=AIndex)
           {
            //--- Check if extreme on preceding bar was lower
            bool notExtreme=startsInTrough && IsProperValue(troughs[AIndex-1]) && troughs[AIndex-1]<X;
            notExtreme|=!startsInTrough && IsProperValue(peaks[AIndex-1]) && peaks[AIndex-1]>X;
            //--- On vertical ZZ with A after contra extreme, check that too
            if(IsProperValue(troughs[AIndex]) && IsProperValue(peaks[AIndex]))
              {
               notExtreme|=startsInTrough && ZigZagDirection(AIndex,peaks,troughs)==1 && troughs[AIndex]<X;
               notExtreme|=!startsInTrough && ZigZagDirection(AIndex,peaks,troughs)==-1 && peaks[AIndex]>X;
              }
            //--- Then one is sure that on finding the A, no lower X has been seen yet
            if(notExtreme)
               break;
           }
         //--- Only check increasing (decreasing) valid A's
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
         for(int BIndex=AIndex+bSkip; BIndex<=endBar && !IsStopped(); BIndex++)
           {
            //--- Ensure that A is the extremum on [A, B], i.e. there is no higher high (lower low)
            int extremeIndexAB=AIndex==BIndex ? BIndex : BIndex-1;
            if((!startsInTrough && IsProperValue(troughs[extremeIndexAB]) && troughs[extremeIndexAB]<A)
               || (startsInTrough && IsProperValue(peaks[extremeIndexAB]) && peaks[extremeIndexAB]>A))
               break;
            if((AIndex!=BIndex && IsProperValue(troughs[BIndex]) && IsProperValue(peaks[BIndex]))
               && ((!startsInTrough && ZigZagDirection(BIndex,peaks,troughs)==1  &&  troughs[BIndex]<A)
               || (startsInTrough  &&  ZigZagDirection(BIndex,peaks,troughs)==-1  &&  peaks[BIndex]>A)))
               break;
            //--- Only check decreasing (increasing) B's
            double B=startsInTrough ? troughs[BIndex]: peaks[BIndex];
            if(!IsProperValue(B) || (startsInTrough && B>extremeB) || (!startsInTrough && B<extremeB))
               continue;
            extremeB=B;
            //--- Second check for vertical ZZ at AB leg and B comes before A
            if(AIndex==BIndex)
              {
               int zzDirection=ZigZagDirection(AIndex,peaks,troughs);
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
            for(int CIndex=BIndex+cSkip; CIndex<=endBar && !IsStopped(); CIndex++)
              {
               //--- Ensure that B is the extremum on [B, C], i.e. there is no lower low (higher high)
               int extremeIndexBC=BIndex==CIndex ? CIndex : CIndex-1;
               if((startsInTrough && IsProperValue(troughs[extremeIndexBC]) && troughs[extremeIndexBC]<B)
                  || (!startsInTrough && IsProperValue(peaks[extremeIndexBC]) && peaks[extremeIndexBC]>B))
                  break;
               if((BIndex!=CIndex && IsProperValue(troughs[CIndex]) && IsProperValue(peaks[CIndex]))
                  && ((startsInTrough && ZigZagDirection(CIndex,peaks,troughs)==1 && troughs[CIndex]<B)
                  || (!startsInTrough && ZigZagDirection(CIndex,peaks,troughs)==-1 && peaks[CIndex]>B)))
                  break;
               //--- Only check increasing (decreasing) C's
               double C=startsInTrough ? peaks[CIndex]: troughs[CIndex];
               if(!IsProperValue(C) || (startsInTrough && C<extremeC) || (!startsInTrough && C>extremeC))
                  continue;
               extremeC=C;
               //--- Second check for vertical ZZ at BC leg and C comes before B
               if(BIndex==CIndex)
                 {
                  int zzDirection=ZigZagDirection(BIndex,peaks,troughs);
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
               double bc2xaRatio=BC/XA;
               //--- Analytical continue: C not far enough by short 'bc2abRatio' or 'xc2xaRatio'
               bool bc2abContinue=bc2abConstraint;
               bool xc2xaContinue=xc2xaConstraint;
               bool bc2xaContinue=bc2xaConstraint;
               bc2abContinue&=bc2abRatio<pattern.bc2ab_min-bc2abSlack;
               xc2xaContinue&=xc2xaRatio<pattern.xc2xa_min-xc2xaSlack;
               bc2xaContinue&=bc2xaRatio<pattern.bc2xa_min-bc2xaSlack;
               if(bc2abContinue || xc2xaContinue || bc2xaContinue)
                  continue;
               //--- Analytical cutoff: C too far by long 'bc2abRatio' or 'xc2xaRatio'
               bool bc2abCutoff=bc2abConstraint;
               bool xc2xaCutoff=xc2xaConstraint;
               bool bc2xaCutoff=bc2xaConstraint;
               bc2abCutoff&=bc2abRatio>pattern.bc2ab_max+bc2abSlack;
               xc2xaCutoff&=xc2xaRatio>pattern.xc2xa_max+xc2xaSlack;
               bc2xaCutoff&=bc2xaRatio>pattern.bc2xa_max+bc2xaSlack;
               if(bc2abCutoff || xc2xaCutoff || bc2xaCutoff)
                  break;
               //--- Check if C is the extreme until end-of-search, only then it should be used to project
               bool lastExtremeC=true;
               for(int i=CIndex+1; i<=endBar; i++)
                 {
                  if((startsInTrough && IsProperValue(peaks[i]) && peaks[i]>C)
                     || (!startsInTrough && IsProperValue(troughs[i]) && troughs[i]<C))
                    {
                     lastExtremeC=false;
                     break;
                    }
                 }
               //--- Solution to harmonic window
               double nearD=0;
               double farD=0;
               HarmonicWindow(pattern,m_slackUnary,m_slackRange,startsInTrough,X,A,B,C,nearD,farD);
               //--- The XABC are such that no D can satisfy the pattern
               if((startsInTrough && farD>nearD) || (!startsInTrough && farD<nearD))
                  continue;
               //--- Find D
               double extremeD=startsInTrough ? DBL_MAX : DBL_MIN;
               //--- Skip first DIndex if vertical zz at C and both B and C is on it
               int dSkip=0;
               if(BIndex==CIndex) dSkip = 1;
               for(int DIndex=CIndex+dSkip; DIndex<=endBar && !IsStopped(); DIndex++)
                 {
                  //--- Ensure that C is the extremum on [C, D], i.e. there is no higher high (lower low)
                  int extremeIndexCD=CIndex==DIndex ? DIndex : DIndex-1;
                  if((!startsInTrough && IsProperValue(troughs[extremeIndexCD]) && troughs[extremeIndexCD]<C)
                     || (startsInTrough && IsProperValue(peaks[extremeIndexCD]) && peaks[extremeIndexCD]>C))
                     break;
                  if((CIndex!=DIndex && IsProperValue(troughs[DIndex]) && IsProperValue(peaks[DIndex]))
                     && ((!startsInTrough && ZigZagDirection(DIndex,peaks,troughs)==1  &&  troughs[DIndex]<C)
                     || (startsInTrough  &&  ZigZagDirection(DIndex,peaks,troughs)==-1  &&  peaks[DIndex]>C)))
                     break;
                  //--- If CIndex is last, use imaginary D for projections
                  bool imaginaryD=((startsInTrough && CIndex==lastPeak && lastTrough<=lastPeak)
                                   || (!startsInTrough && CIndex==lastTrough && lastPeak<=lastTrough));
                  if(imaginaryD && lastPeak==lastTrough)
                     imaginaryD &=(startsInTrough && ZigZagDirection(lastPeak,peaks,troughs)==1)
                                  || (!startsInTrough && ZigZagDirection(lastPeak,peaks,troughs)==-1);
                  //--- Only check decreasing (increasing) D's
                  double D=startsInTrough ? troughs[DIndex]: peaks[DIndex];
                  if(!imaginaryD && (!IsProperValue(D) || (startsInTrough && D>extremeD) || (!startsInTrough && D<extremeD)))
                     continue;
                  extremeD=D;
                  //--- Second check for vertical ZZ at CD leg and D comes before C
                  if(!imaginaryD && CIndex==DIndex)
                    {
                     int zzDirection=ZigZagDirection(CIndex,peaks,troughs);
                     if(zzDirection==0) continue;
                     else if(zzDirection==-1 && !startsInTrough) continue;
                     else if(zzDirection==1 && startsInTrough) continue;
                    }
                  //--- Check if D is the extreme until end-of-search, only then it should be used to project
                  bool lastExtremeD=true;
                  if(!imaginaryD)
                    {
                     for(int i=DIndex+1; i<=endBar; i++)
                       {
                        if((!startsInTrough && IsProperValue(peaks[i]) && peaks[i]>D)
                           || (startsInTrough && IsProperValue(troughs[i]) && troughs[i]<D))
                          {
                           lastExtremeD=false;
                           break;
                          }
                       }
                    }
                  //--- Pattern match structure
                  PATTERN_MATCH match;
                  match.bullish=startsInTrough;
                  match.XIndex=XIndex;
                  match.AIndex=AIndex;
                  match.BIndex=BIndex;
                  match.CIndex=CIndex;
                  match.DIndex=DIndex;
                  match.X=X;
                  match.A=A;
                  match.B=B;
                  match.C=C;
                  match.nearD=nearD;
                  match.farD=farD;
                  //--- Continue/Pattern undershot
                  if(imaginaryD || (startsInTrough && D>nearD) || (!startsInTrough && D<nearD))
                    {
                     //--- In these cases, a match or overshot pattern can occur later
                     if(!lastExtremeC || !lastExtremeD)
                        continue;
                     m_matchProcessor.PatternUndershot(match);
                     break;
                    }
                  //--- Cutoff
                  else if((startsInTrough && D<farD) || (!startsInTrough && D>farD))
                    {
                     m_matchProcessor.PatternOvershot(match);
                     break;
                    }
                  //--- Match
                  else
                     m_matchProcessor.PatternMatched(match);
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
  }
//+------------------------------------------------------------------+
//| Helper method finds ZigZag direction in before index             |
//+------------------------------------------------------------------+
int ZigZagDirection(int index,const double &peaks[],const double &troughs[])
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
int FirstNonZeroFrom(int start,const double &array[])
  {
   for(int j=start; j>=0; j--)
      if(IsProperValue(array[j]))
         return j;
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HarmonicWindow(const PATTERN_DESCRIPTOR &pattern,double slackUnary,double slackRange,
                    bool startsInTrough,double X,double A,double B,double C,double &nearD,double &farD)
  {
//--- What constraints does the pattern have?
   bool ad2xaConstraint=pattern.ad2xa_max!=0 && pattern.ad2xa_min!=0;
   bool cd2bcConstraint=pattern.cd2bc_max!=0 && pattern.cd2bc_min!=0;
   bool cd2xcConstraint=pattern.cd2xc_max!=0 && pattern.cd2xc_min!=0;
   bool cd2abConstraint=pattern.cd2ab_max!=0 && pattern.cd2ab_min!=0;
   bool cd2adConstraint=pattern.cd2ad_max!=0 && pattern.cd2ad_min!=0;
//--- Which constraints are unary vs range?
   double ad2xaSlack=pattern.ad2xa_max==pattern.ad2xa_min ? slackUnary : slackRange;
   double cd2bcSlack=pattern.cd2bc_max==pattern.cd2bc_min ? slackUnary : slackRange;
   double cd2xcSlack=pattern.cd2xc_max==pattern.cd2xc_min ? slackUnary : slackRange;
   double cd2abSlack=pattern.cd2ab_max==pattern.cd2ab_min ? slackUnary : slackRange;
   double cd2adSlack=pattern.cd2ad_max==pattern.cd2ad_min ? slackUnary : slackRange;
//--- Ratios
   double XA=MathAbs(A-X);
   double XC=MathAbs(X-C);
   double AB=MathAbs(A-B);
   double BC=MathAbs(C-B);
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
   nearD=startsInTrough ? DBL_MAX : DBL_MIN;
   farD=startsInTrough ? DBL_MIN : DBL_MAX;
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

//---cd2adConstraint is a bit tedious with 2 D's giving possible 0 division equation
   if(cd2adConstraint && (pattern.cd2ad_min-cd2adSlack)!=1.0 && (pattern.cd2ad_max+cd2adSlack)!=1)
     {
      double cd2ad_1 = MathAbs((C-(pattern.cd2ad_min-cd2adSlack)*A)/((pattern.cd2ad_min-cd2adSlack)-1.0));
      double cd2ad_2 = MathAbs((C-(pattern.cd2ad_max+cd2adSlack)*A)/((pattern.cd2ad_max+cd2adSlack)-1.0));
      nearD=startsInTrough ? MathMin(nearD,MathMax(cd2ad_1,cd2ad_2)) : MathMax(nearD,MathMin(cd2ad_1,cd2ad_2));
      farD=startsInTrough ? MathMax(farD,MathMin(cd2ad_1,cd2ad_2)) : MathMin(farD,MathMax(cd2ad_1,cd2ad_2));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


struct PRZLevels
  {
   double            cd2bc;
   double            ad2xa;
   double            cd2xc;
   double            cd2ab;
   double            cd2ad;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
PRZLevels HarmonicRatios(const PATTERN_DESCRIPTOR &pattern,
                         bool startsInTrough,double X,double A,double B,double C)
  {
//--- What constraints does the pattern have?
   bool ad2xaConstraint=pattern.ad2xa_max!=0 && pattern.ad2xa_min!=0;
   bool cd2bcConstraint=pattern.cd2bc_max!=0 && pattern.cd2bc_min!=0;
   bool cd2xcConstraint=pattern.cd2xc_max!=0 && pattern.cd2xc_min!=0;
   bool cd2abConstraint=pattern.cd2ab_max!=0 && pattern.cd2ab_min!=0;
   bool cd2adConstraint=pattern.cd2ad_max!=0 && pattern.cd2ad_min!=0;
//--- Which constraints are unary vs range?
   double ad2xaUnary=pattern.ad2xa_max==pattern.ad2xa_min;
   double cd2bcUnary=pattern.cd2bc_max==pattern.cd2bc_min;
   double cd2xcUnary=pattern.cd2xc_max==pattern.cd2xc_min;
   double cd2abUnary=pattern.cd2ab_max==pattern.cd2ab_min;
   double cd2adUnary=pattern.cd2ad_max==pattern.cd2ad_min;
//--- Ratios
   double XA=MathAbs(A-X);
   double XC=MathAbs(X-C);
   double AB=MathAbs(A-B);
   double BC=MathAbs(C-B);
//--- Analytical solution to harmonic window
   double cd2bc=0;
   double ad2xa=0;
   double cd2xc=0;
   double cd2ab=0;
   double cd2ad=0;
   if(startsInTrough)
     {
      if(cd2bcConstraint && cd2bcUnary)
        {
         cd2bc=C-pattern.cd2bc_min*BC;
        }
      if(ad2xaConstraint && ad2xaUnary)
        {
         ad2xa=A-pattern.ad2xa_min*XA;
        }
      if(cd2xcConstraint && cd2xcUnary)
        {
         cd2xc=C-pattern.cd2xc_min*XC;
        }
      if(cd2abConstraint && cd2abUnary)
        {
         cd2ab=C-pattern.cd2ab_min*AB;
        }
      if(cd2adConstraint && cd2adUnary && pattern.cd2ad_min!=1.0)
        {
         cd2ad=MathAbs((C-pattern.cd2ad_min*A)/(pattern.cd2ad_min-1.0));
        }
     }
   else
     {
      if(cd2bcConstraint && cd2bcUnary)
        {
         cd2bc=C+pattern.cd2bc_min*BC;
        }
      if(ad2xaConstraint && ad2xaUnary)
        {
         ad2xa=A+pattern.ad2xa_min*XA;
        }
      if(cd2xcConstraint && cd2xcUnary)
        {
         cd2xc=C+pattern.cd2xc_min*XC;
        }
      if(cd2abConstraint && cd2abUnary)
        {
         cd2ab=C+pattern.cd2ab_min*AB;
        }
      if(cd2adConstraint && cd2adUnary && pattern.cd2ad_min!=1.0)
        {
         cd2ad=MathAbs((C-pattern.cd2ad_min*A)/(pattern.cd2ad_min-1.0));
        }
     }
   PRZLevels levels;
   levels.cd2bc=cd2bc;
   levels.ad2xa=ad2xa;
   levels.cd2xc=cd2xc;
   levels.cd2ab=cd2ab;
   levels.cd2ad=cd2ad;
   return levels;
  }

double HARMONIC_NUMBERS[]={0.382,0.5,0.618,0.707,0.786,0.886,1,1.13,1.272,1.414,1.618,2,2.236,2.618,3.14,3.618};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
PRZLevels HarmonicRatios2(const PATTERN_DESCRIPTOR &pattern,
                          bool startsInTrough,double X,double A,double B,double C)
  {
//--- What constraints does the pattern have?
   bool ad2xaConstraint=pattern.ad2xa_max!=0 && pattern.ad2xa_min!=0;
   bool cd2bcConstraint=pattern.cd2bc_max!=0 && pattern.cd2bc_min!=0;
   bool cd2xcConstraint=pattern.cd2xc_max!=0 && pattern.cd2xc_min!=0;
   bool cd2abConstraint=pattern.cd2ab_max!=0 && pattern.cd2ab_min!=0;
   bool cd2adConstraint=pattern.cd2ad_max!=0 && pattern.cd2ad_min!=0;
//--- Which constraints are unary vs range?
   double ad2xaUnary=pattern.ad2xa_max==pattern.ad2xa_min;
   double cd2bcUnary=pattern.cd2bc_max==pattern.cd2bc_min;
   double cd2xcUnary=pattern.cd2xc_max==pattern.cd2xc_min;
   double cd2abUnary=pattern.cd2ab_max==pattern.cd2ab_min;
   double cd2adUnary=pattern.cd2ad_max==pattern.cd2ad_min;
//--- Ratios
   double XA=MathAbs(A-X);
   double XC=MathAbs(X-C);
   double AB=MathAbs(A-B);
   double BC=MathAbs(C-B);
//--- Analytical solution to harmonic window
   double cd2bc=0;
   double ad2xa=0;
   double cd2xc=0;
   double cd2ab=0;
   double cd2ad=0;
   if(startsInTrough)
     {
      if(cd2bcConstraint && cd2bcUnary)
        {
         cd2bc=C-pattern.cd2bc_min*BC;
        }
      if(ad2xaConstraint && ad2xaUnary)
        {
         ad2xa=A-pattern.ad2xa_min*XA;
        }
      if(cd2xcConstraint && cd2xcUnary)
        {
         cd2xc=C-pattern.cd2xc_min*XC;
        }
      if(cd2abConstraint && cd2abUnary)
        {
         cd2ab=C-pattern.cd2ab_min*AB;
        }
      if(cd2adConstraint && cd2adUnary && pattern.cd2ad_min!=1.0)
        {
         cd2ad=MathAbs((C-pattern.cd2ad_min*A)/(pattern.cd2ad_min-1.0));
        }
     }
   else
     {
      if(cd2bcConstraint && cd2bcUnary)
        {
         cd2bc=C+pattern.cd2bc_min*BC;
        }
      if(ad2xaConstraint && ad2xaUnary)
        {
         ad2xa=A+pattern.ad2xa_min*XA;
        }
      if(cd2xcConstraint && cd2xcUnary)
        {
         cd2xc=C+pattern.cd2xc_min*XC;
        }
      if(cd2abConstraint && cd2abUnary)
        {
         cd2ab=C+pattern.cd2ab_min*AB;
        }
      if(cd2adConstraint && cd2adUnary && pattern.cd2ad_min!=1.0)
        {
         cd2ad=MathAbs((C-pattern.cd2ad_min*A)/(pattern.cd2ad_min-1.0));
        }
     }
   PRZLevels levels;
   levels.cd2ab=cd2ab;
   levels.ad2xa=ad2xa;
   levels.cd2xc=cd2xc;
   levels.cd2bc=cd2ab;
   levels.cd2ad=cd2ad;
   return levels;
  }
//--- End header guard
#endif
//+------------------------------------------------------------------+

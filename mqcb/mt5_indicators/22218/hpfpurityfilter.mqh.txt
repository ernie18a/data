//+------------------------------------------------------------------+
//|                                    HPFRatioContainmentFilter.mqh |
//|                                  Copyright 2018, André S. Enger. |
//|                                          andre_enger@hotmail.com |
//|                                  Contribs                        |
//|                                         David Gadelha            |
//|                                               dgadelha@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"

//--- Header guard
#ifndef HPFPURITYFILTER_MQH
#define HPFPURITYFILTER_MQH

#include "HPFGlobals.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include "HPFFilter.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHPFPurityFilter : public CHPFFilter
  {
private:
   bool              m_activated;
public:
                     CHPFPurityFilter();
                    ~CHPFPurityFilter();
   //---
   void              SetActivated(bool activated) { m_activated=activated; }
   bool              IsValidUndershot(int patternIndex,PATTERN_MATCH &match) override;
   bool              IsValidMatched(int patternIndex,PATTERN_MATCH &match) override;
   bool              IsValidOvershot(int patternIndex,PATTERN_MATCH &match) override;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHPFPurityFilter::CHPFPurityFilter()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHPFPurityFilter::~CHPFPurityFilter()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHPFPurityFilter::IsValidUndershot(int patternIndex,PATTERN_MATCH &match)
  {
   if(m_activated)
     {
      PATTERN_DESCRIPTOR pattern=_patterns[patternIndex];
      return IsPuristPRZ(pattern,match.bullish,match.X,match.A,match.B,match.C,match.nearD,match.farD);
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHPFPurityFilter::IsValidMatched(int patternIndex,PATTERN_MATCH &match)
  {
   if(m_activated)
     {
      PATTERN_DESCRIPTOR pattern=_patterns[patternIndex];
      return IsPuristPRZ(pattern,match.bullish,match.X,match.A,match.B,match.C,match.nearD,match.farD);
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHPFPurityFilter::IsValidOvershot(int patternIndex,PATTERN_MATCH &match)
  {
   if(m_activated)
     {
      PATTERN_DESCRIPTOR pattern=_patterns[patternIndex];
      return IsPuristPRZ(pattern,match.bullish,match.X,match.A,match.B,match.C,match.nearD,match.farD);
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsPuristPRZ(const PATTERN_DESCRIPTOR &pattern,bool startsInTrough,
                 double X,double A,double B,double C,double nearD,double farD)
  {
//--- What constraints does the pattern have?
   bool ad2xaConstraint=pattern.ad2xa_max!=0 && pattern.ad2xa_min!=0;
   bool cd2bcConstraint=pattern.cd2bc_max!=0 && pattern.cd2bc_min!=0;
   bool cd2xcConstraint=pattern.cd2xc_max!=0 && pattern.cd2xc_min!=0;
   bool cd2abConstraint=pattern.cd2ab_max!=0 && pattern.cd2ab_min!=0;
   bool cd2adConstraint=pattern.cd2ad_max!=0 && pattern.cd2ad_min!=0;
//--- Ratios
   double XA=MathAbs(A-X);
   double XC=MathAbs(X-C);
   double AB=MathAbs(A-B);
   double BC=MathAbs(C-B);
   if(cd2bcConstraint)
     {
      bool contained;
      if(startsInTrough)
        {
         double nearRatio=C-pattern.cd2bc_min*BC;
         double farRatio=C-pattern.cd2bc_max*BC;
         contained=nearD>=farRatio && nearRatio>=farD;
        }
      else
        {
         double nearRatio=C+pattern.cd2bc_min*BC;
         double farRatio=C+pattern.cd2bc_max*BC;
         contained=nearD<=farRatio && nearRatio<=farD;
        }
      if(!contained)
         return false;
     }
   if(ad2xaConstraint)
     {
      bool contained;
      if(startsInTrough)
        {
         double nearRatio=A-pattern.ad2xa_min*XA;
         double farRatio=A-pattern.ad2xa_max*XA;
         contained=nearD>=farRatio && nearRatio>=farD;
        }
      else
        {
         double nearRatio=A+pattern.ad2xa_min*XA;
         double farRatio=A+pattern.ad2xa_max*XA;
         contained=nearD<=farRatio && nearRatio<=farD;
        }
      if(!contained)
         return false;
     }
   if(cd2xcConstraint)
     {
      bool contained;
      if(startsInTrough)
        {
         double nearRatio=C-pattern.cd2xc_min*XC;
         double farRatio=C-pattern.cd2xc_max*XC;
         contained=nearD>=farRatio && nearRatio>=farD;
        }
      else
        {
         double nearRatio=C+pattern.cd2xc_min*XC;
         double farRatio=C+pattern.cd2xc_max*XC;
         contained=nearD<=farRatio && nearRatio<=farD;
        }
      if(!contained)
         return false;
     }
   if(cd2abConstraint)
     {
      bool contained;
      if(startsInTrough)
        {
         double nearRatio=C-pattern.cd2ab_min*AB;
         double farRatio=C-pattern.cd2ab_max*AB;
         contained=nearD>=farRatio && nearRatio>=farD;
        }
      else
        {
         double nearRatio=C+pattern.cd2ab_min*AB;
         double farRatio=C+pattern.cd2ab_max*AB;
         contained=nearD<=farRatio && nearRatio<=farD;
        }
      if(!contained)
         return false;
     }
   if(cd2adConstraint && (pattern.cd2ad_min)!=1.0 && (pattern.cd2ad_max)!=1)
     {
      bool contained;
      double cd2ad_1 = MathAbs((C-pattern.cd2ad_min*A)/((pattern.cd2ad_min)-1.0));
      double cd2ad_2 = MathAbs((C-pattern.cd2ad_max*A)/((pattern.cd2ad_max)-1.0));
      if(startsInTrough)
        {
         double nearRatio=MathMax(cd2ad_1,cd2ad_2);
         double farRatio=MathMin(cd2ad_1,cd2ad_2);
         contained=nearD>=farRatio && nearRatio>=farD;
        }
      else
        {
         double nearRatio=MathMin(cd2ad_1,cd2ad_2);
         double farRatio=MathMax(cd2ad_1,cd2ad_2);
         contained=nearD<=farRatio && nearRatio<=farD;
        }
      if(!contained)
         return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//--- Header guard end
#endif
//+------------------------------------------------------------------+

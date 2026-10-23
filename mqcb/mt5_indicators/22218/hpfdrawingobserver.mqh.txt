//+------------------------------------------------------------------+
//|                                           HPFDrawingObserver.mqh |
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
#ifndef HPFDRAWINGOBSERVER_MQH
#define HPFDRAWINGOBSERVER_MQH

#include "HPFGlobals.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHPFDrawingObserver : public CHPFObserver
  {
private:
   int               m_bar;
public:
   void              Reset() {};
   void SetBar(int bar) { m_bar=bar; }
   void NotifyTransientMatch(int patternIndex,PATTERN_MATCH &match)
     {
      bool bullish=match.bullish;
      int XIndex=match.XIndex;
      int AIndex=match.AIndex;
      int BIndex=match.BIndex;
      int CIndex=match.CIndex;
      int DIndex=match.DIndex;
      double nearD=match.nearD;
      double farD=match.farD;
      double X=bullish ? _troughs[XIndex]: _peaks[XIndex];
      double A=bullish ? _peaks[AIndex]: _troughs[AIndex];
      double B=bullish ? _troughs[BIndex]: _peaks[BIndex];
      double C=bullish ? _peaks[CIndex]: _troughs[CIndex];
      double D=bullish ? _troughs[DIndex]: _peaks[DIndex];
      datetime XDateTime=_time[XIndex];
      datetime ADateTime=_time[AIndex];
      datetime BDateTime=_time[BIndex];
      datetime CDateTime=_time[CIndex];
      datetime DDateTime=_time[DIndex];
      if(_indicator.Is4PointPattern(patternIndex))
        {
         DisplayPattern(patternIndex,bullish,AIndex,ADateTime,A,BDateTime,B,CDateTime,C,DDateTime,D);
         DisplayPRZ(patternIndex,bullish,ADateTime,A,BDateTime,CDateTime,C,DDateTime,D,farD);
        }
      else
        {
         DisplayPattern(patternIndex,bullish,XIndex,XDateTime,X,ADateTime,A,BDateTime,B,CDateTime,C,DDateTime,D);
         DisplayPRZ(patternIndex,bullish,XDateTime,X,ADateTime,A,BDateTime,CDateTime,C,DDateTime,D,farD);
        }
     }
   void NotifyPersistentMatch(int patternIndex,PATTERN_MATCH &match)
     {
      if(!i_oldPatterns)
         return;
      bool bullish=match.bullish;
      int XIndex=match.XIndex;
      int AIndex=match.AIndex;
      int BIndex=match.BIndex;
      int CIndex=match.CIndex;
      int DIndex=match.DIndex;
      double nearD=match.nearD;
      double farD=match.farD;
      double X=bullish ? _troughs[XIndex]: _peaks[XIndex];
      double A=bullish ? _peaks[AIndex]: _troughs[AIndex];
      double B=bullish ? _troughs[BIndex]: _peaks[BIndex];
      double C=bullish ? _peaks[CIndex]: _troughs[CIndex];
      double D=bullish ? _troughs[DIndex]: _peaks[DIndex];
      datetime XDateTime=_time[XIndex];
      datetime ADateTime=_time[AIndex];
      datetime BDateTime=_time[BIndex];
      datetime CDateTime=_time[CIndex];
      datetime DDateTime=_time[DIndex];
      if(_indicator.Is4PointPattern(patternIndex))
        {
         DisplayPattern(patternIndex,bullish,AIndex,ADateTime,A,BDateTime,B,CDateTime,C,DDateTime,D);
        }
      else
        {
         DisplayPattern(patternIndex,bullish,XIndex,XDateTime,X,ADateTime,A,BDateTime,B,CDateTime,C,DDateTime,D);
        }
     }
   void NotifyStandardProjection(int patternIndex,PATTERN_MATCH &match)
     {
      if(i_emergingPatterns) //&& MathAbs(m_bar-match.DIndex)<BarsAnalyzed*2)
        {
         bool bullish=match.bullish;
         int XIndex=match.XIndex;
         int AIndex = match.AIndex;
         int BIndex = match.BIndex;
         int CIndex = match.CIndex;
         int DIndex = match.DIndex;
         double X=bullish ? _troughs[XIndex]: _peaks[XIndex];
         double A=bullish ? _peaks[AIndex]: _troughs[AIndex];
         double B=bullish ? _troughs[BIndex]: _peaks[BIndex];
         double C=bullish ? _peaks[CIndex]: _troughs[CIndex];
         datetime XDateTime=_time[XIndex];
         datetime ADateTime=_time[AIndex];
         datetime BDateTime=_time[BIndex];
         datetime CDateTime=_time[CIndex];
         datetime DDateTime=_time[DIndex];
         double nearD=match.nearD;
         if(_indicator.Is4PointPattern(patternIndex))
            DisplayProjection(patternIndex,bullish,ADateTime,A,BDateTime,B,CDateTime,C,DDateTime,nearD);
         else
            DisplayProjection(patternIndex,bullish,XDateTime,X,ADateTime,A,BDateTime,B,CDateTime,C,DDateTime,nearD);
        }
     }
   void NotifyOneAheadProjection(int patternIndex,PATTERN_MATCH &match)
     {
      if(i_oneAheadProjection)
        {
         NotifyStandardProjection(patternIndex,match);
        }
     }
   void NotifyOvershot(int patternIndex,PATTERN_MATCH &match) {}

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
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,true);
      ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,true);
      ObjectSetInteger(0,name,OBJPROP_COLOR,bullish ? i_clrBull4P : i_clrBear4P);
      ObjectSetInteger(0,name,OBJPROP_STYLE,i_stylePRZ);
      ObjectSetString(0,name,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PRZ stop "+DoubleToString(NormalizeDouble(farD,_Digits),_Digits));
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
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,true);
      ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,true);
      ObjectSetInteger(0,name,OBJPROP_COLOR,bullish ? i_clrBull: i_clrBear);
      ObjectSetInteger(0,name,OBJPROP_STYLE,i_stylePRZ);
      ObjectSetString(0,name,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PRZ stop "+DoubleToString(NormalizeDouble(farD,_Digits),_Digits));
     }
   //+------------------------------------------------------------------+
   //| Helper method displays 4-point patterns                          |
   //+------------------------------------------------------------------+
   void DisplayPattern(int k,bool bullish,
                       int AIndex,datetime ADateTime,double A,
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
      ObjectSetInteger(0,name0,OBJPROP_COLOR, bullish ? i_clrBull4P : i_clrBear4P);
      ObjectSetInteger(0,name1,OBJPROP_COLOR, bullish ? i_clrBull4P : i_clrBear4P);
      ObjectSetInteger(0,name2,OBJPROP_COLOR, bullish ? i_clrBull4P : i_clrBear4P);
      ObjectSetInteger(0,name0,OBJPROP_SELECTABLE,true);
      ObjectSetInteger(0,name1,OBJPROP_SELECTABLE,true);
      ObjectSetInteger(0,name2,OBJPROP_SELECTABLE,true);
      ObjectSetInteger(0,name0,OBJPROP_WIDTH,i_lineWidth);
      ObjectSetInteger(0,name1,OBJPROP_WIDTH,i_lineWidth);
      ObjectSetInteger(0,name2,OBJPROP_WIDTH,i_lineWidth);
      ObjectSetInteger(0,name0,OBJPROP_STYLE,i_style4P);
      ObjectSetInteger(0,name1,OBJPROP_STYLE,i_style4P);
      ObjectSetInteger(0,name2,OBJPROP_STYLE,i_style4P);
      ObjectSetString(0,name0,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" AB");
      ObjectSetString(0,name1,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" BC");
      ObjectSetString(0,name2,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" CD");
      if(i_showDescriptions)
        {
         int numOverlapping=0;
         for(int i=0; i<NUM_PATTERNS; i++)
           {
            CHPFRingbuffer *stored=_indicator.GetMatchedPersistent(i);
            int tail=stored.GetTail();
            int head=stored.GetHead();
            int capacity=stored.GetCapacity();
            for(int j=tail; j!=head; j=(j+1)%capacity)
              {
               if(!_indicator.Is4PointPattern(i) && AIndex==stored.GetMatch(j).XIndex) numOverlapping++;
               if(_indicator.Is4PointPattern(i) && AIndex==stored.GetMatch(j).AIndex) numOverlapping++;
              }
            stored=_indicator.GetMatchedTransient(i);
            tail=stored.GetTail();
            head=stored.GetHead();
            capacity=stored.GetCapacity();
            for(int j=tail; j!=head; j=(j+1)%capacity)
              {
               if(!_indicator.Is4PointPattern(i) && AIndex==stored.GetMatch(j).XIndex) numOverlapping++;
               if(_indicator.Is4PointPattern(i) && AIndex==stored.GetMatch(j).AIndex) numOverlapping++;
              }
           }
         int x1=0;
         int y1=0;
         int x2=0;
         int y2=0;
         ChartTimePriceToXY(0,0,ADateTime,A,x1,y1);
         ChartTimePriceToXY(0,0,ADateTime,A+1,x2,y2);
         double pixelsPerPrice=MathAbs(y1-y2);
         double change=pixelsPerPrice!=0 ? numOverlapping*(i_fontSize)/pixelsPerPrice : 0;
         double price=(bullish ? A+change : A-change);
         ObjectCreate(0,pointA,OBJ_TEXT,0,ADateTime,price);
         ObjectSetInteger(0,pointA,OBJPROP_SELECTABLE,true);
         ObjectSetString(0,pointA,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PA");
         ObjectSetString(0,pointA,OBJPROP_TEXT,"A "+prefix+_patternNames[k]);
         ObjectSetString(0,pointA,OBJPROP_FONT,"Arial");
         ObjectSetInteger(0,pointA,OBJPROP_FONTSIZE,i_fontSize);
         ObjectSetInteger(0,pointA,OBJPROP_COLOR,bullish ? i_clrBull4P : i_clrBear4P);
         ObjectCreate(0,pointB,OBJ_TEXT,0,BDateTime,B);
         ObjectCreate(0,pointC,OBJ_TEXT,0,CDateTime,C);
         ObjectCreate(0,pointD,OBJ_TEXT,0,DDateTime,D);
         ObjectSetInteger(0,pointB,OBJPROP_SELECTABLE,true);
         ObjectSetInteger(0,pointC,OBJPROP_SELECTABLE,true);
         ObjectSetInteger(0,pointD,OBJPROP_SELECTABLE,true);
         ObjectSetString(0,pointB,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PB");
         ObjectSetString(0,pointC,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PC");
         ObjectSetString(0,pointD,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PD");
         ObjectSetString(0,pointB,OBJPROP_TEXT,"B");
         ObjectSetString(0,pointB,OBJPROP_FONT,"Arial");
         ObjectSetInteger(0,pointB,OBJPROP_FONTSIZE,i_fontSize);
         ObjectSetInteger(0,pointB,OBJPROP_COLOR,bullish ? i_clrBull4P : i_clrBear4P);
         ObjectSetString(0,pointC,OBJPROP_TEXT,"C");
         ObjectSetString(0,pointC,OBJPROP_FONT,"Arial");
         ObjectSetInteger(0,pointC,OBJPROP_FONTSIZE,i_fontSize);
         ObjectSetInteger(0,pointC,OBJPROP_COLOR,bullish ? i_clrBull4P : i_clrBear4P);
         ObjectSetString(0,pointD,OBJPROP_TEXT,"D");
         ObjectSetString(0,pointD,OBJPROP_FONT,"Arial");
         ObjectSetInteger(0,pointD,OBJPROP_FONTSIZE,i_fontSize);
         ObjectSetInteger(0,pointD,OBJPROP_COLOR,bullish ? i_clrBull4P : i_clrBear4P);
        }
     }
   //+------------------------------------------------------------------+
   //| Helper method displays 5-point patterns                          |
   //+------------------------------------------------------------------+
   void DisplayPattern(int k,bool bullish,
                       int XIndex,datetime XDateTime,double X,
                       datetime ADateTime,double A,
                       datetime BDateTime,double B,
                       datetime CDateTime,double C,
                       datetime DDateTime,double D)
     {
      string unique=UniqueIdentifier(XDateTime,ADateTime,BDateTime,CDateTime,DDateTime);
      string prefix=(bullish ? "Bullish " : "Bearish ");
      string prefixName=(bullish ? "U " : "D ")+_identifier+StringFormat("%x",_timeOfInit)+IntegerToString(k);
      string name0=prefixName+" XA"+unique;
      string name1=prefixName+" AB"+unique;
      string name2=prefixName+" BC"+unique;
      string name3=prefixName+" CD"+unique;
      string name4=prefixName+" XAB"+unique;
      string name5=prefixName+" XAD"+unique;
      string name6=prefixName+" ABC"+unique;
      string name7=prefixName+" BCD"+unique;
      string triangle_XB=prefixName+" XB"+unique;
      string triangle_BD=prefixName+" BD"+unique;
      string pointX=prefixName+" PX"+unique;
      string pointA=prefixName+" PA"+unique;
      string pointB=prefixName+" PB"+unique;
      string pointC=prefixName+" PC"+unique;
      string pointD=prefixName+" PD"+unique;
      string xcd=IntegerToString((int) MathRound(100*MathAbs(D-C)/MathAbs(X-C)));
      string xab=IntegerToString((int) MathRound(100*MathAbs(A-B)/MathAbs(X-A)));
      string xad=IntegerToString((int) MathRound(100*MathAbs(D-A)/MathAbs(X-A)));
      string abc=IntegerToString((int) MathRound(100*MathAbs(C-B)/MathAbs(B-A)));
      if(k==CYPHER || k==NENSTAR || k==NEWCYPHER)
         abc=IntegerToString((int) MathRound(100*MathAbs(X-C)/MathAbs(X-A)));
      string bcd=IntegerToString((int) MathRound(100*MathAbs(C-D)/MathAbs(B-C)));
      ObjectCreate(0,name0,OBJ_TREND,0,XDateTime,X,ADateTime,A);
      ObjectCreate(0,name1,OBJ_TREND,0,ADateTime,A,BDateTime,B);
      ObjectCreate(0,name2,OBJ_TREND,0,BDateTime,B,CDateTime,C);
      ObjectCreate(0,name3,(!i_fillPatterns || (k==THREEDRIVES) || (k==FIVEO)) ? OBJ_ARROWED_LINE : OBJ_TREND,0,CDateTime,C,DDateTime,D);  //Arrowed lines if not triangles
      ObjectCreate(0,name4,OBJ_TREND,0,XDateTime,X,BDateTime,B);
      //--- Point labels
      if(i_showDescriptions)
        {
         int numOverlapping=0;
         for(int i=0; i<NUM_PATTERNS; i++)
           {
            CHPFRingbuffer *stored=_indicator.GetMatchedPersistent(i);
            int tail=stored.GetTail();
            int head=stored.GetHead();
            int capacity=stored.GetCapacity();
            for(int j=tail; j!=head; j=(j+1)%capacity)
              {
               if(!_indicator.Is4PointPattern(i) && XIndex==stored.GetMatch(j).XIndex) numOverlapping++;
               if(_indicator.Is4PointPattern(i) && XIndex==stored.GetMatch(j).AIndex) numOverlapping++;
              }
            stored=_indicator.GetMatchedTransient(i);
            tail=stored.GetTail();
            head=stored.GetHead();
            capacity=stored.GetCapacity();
            for(int j=tail; j!=head; j=(j+1)%capacity)
              {
               if(!_indicator.Is4PointPattern(i) && XIndex==stored.GetMatch(j).XIndex) numOverlapping++;
               if(_indicator.Is4PointPattern(i) && XIndex==stored.GetMatch(j).AIndex) numOverlapping++;
              }
           }
         int x1=0;
         int y1=0;
         int x2=0;
         int y2=0;
         ChartTimePriceToXY(0,0,XDateTime,X,x1,y1);
         ChartTimePriceToXY(0,0,XDateTime,X+1,x2,y2);
         double pixelsPerPrice=MathAbs(y1-y2);
         double change=pixelsPerPrice!=0 ? numOverlapping*(i_fontSize)/pixelsPerPrice : 0;
         double price=(bullish ? X-change : X+change);
         ObjectCreate(0,pointX,OBJ_TEXT,0,XDateTime,price);
         ObjectCreate(0,pointA,OBJ_TEXT,0,ADateTime,A);
         ObjectCreate(0,pointB,OBJ_TEXT,0,BDateTime,B);
         ObjectCreate(0,pointC,OBJ_TEXT,0,CDateTime,C);
         ObjectCreate(0,pointD,OBJ_TEXT,0,DDateTime,D);
         ObjectSetInteger(0,pointX,OBJPROP_SELECTABLE,true);
         ObjectSetInteger(0,pointA,OBJPROP_SELECTABLE,true);
         ObjectSetInteger(0,pointB,OBJPROP_SELECTABLE,true);
         ObjectSetInteger(0,pointC,OBJPROP_SELECTABLE,true);
         ObjectSetInteger(0,pointD,OBJPROP_SELECTABLE,true);
         ObjectSetString(0,pointX,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PX");
         ObjectSetString(0,pointA,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PA");
         ObjectSetString(0,pointB,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PB");
         ObjectSetString(0,pointC,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PC");
         ObjectSetString(0,pointD,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PD");
         ObjectSetString(0,pointX,OBJPROP_TEXT,"X "+prefix+_patternNames[k]);
         ObjectSetString(0,pointX,OBJPROP_FONT,"Arial");
         ObjectSetInteger(0,pointX,OBJPROP_FONTSIZE,i_fontSize);
         ObjectSetInteger(0,pointX,OBJPROP_COLOR,bullish ? i_clrBull : i_clrBear);
         ObjectSetString(0,pointA,OBJPROP_TEXT,"A");
         ObjectSetString(0,pointA,OBJPROP_FONT,"Arial");
         ObjectSetInteger(0,pointA,OBJPROP_FONTSIZE,i_fontSize);
         ObjectSetInteger(0,pointA,OBJPROP_COLOR,bullish ? i_clrBull : i_clrBear);
         ObjectSetString(0,pointB,OBJPROP_TEXT,"B");
         ObjectSetString(0,pointB,OBJPROP_FONT,"Arial");
         ObjectSetInteger(0,pointB,OBJPROP_FONTSIZE,i_fontSize);
         ObjectSetInteger(0,pointB,OBJPROP_COLOR,bullish ? i_clrBull : i_clrBear);
         ObjectSetString(0,pointC,OBJPROP_TEXT,"C");
         ObjectSetString(0,pointC,OBJPROP_FONT,"Arial");
         ObjectSetInteger(0,pointC,OBJPROP_FONTSIZE,i_fontSize);
         ObjectSetInteger(0,pointC,OBJPROP_COLOR,bullish ? i_clrBull : i_clrBear);
         ObjectSetString(0,pointD,OBJPROP_TEXT,"D");
         ObjectSetString(0,pointD,OBJPROP_FONT,"Arial");
         ObjectSetInteger(0,pointD,OBJPROP_FONTSIZE,i_fontSize);
         ObjectSetInteger(0,pointD,OBJPROP_COLOR,bullish ? i_clrBull : i_clrBear);
        }
      //--- No X-D for 5-0
      if(k!=FIVEO) ObjectCreate(0,name5,OBJ_TREND,0,XDateTime,X,DDateTime,D);
      ObjectCreate(0,name6,OBJ_TREND,0,ADateTime,A,CDateTime,C);
      ObjectCreate(0,name7,OBJ_TREND,0,BDateTime,B,DDateTime,D);
      ObjectSetInteger(0,name0,OBJPROP_COLOR, bullish ? i_clrBull : i_clrBear);
      ObjectSetInteger(0,name1,OBJPROP_COLOR, bullish ? i_clrBull : i_clrBear);
      ObjectSetInteger(0,name2,OBJPROP_COLOR, bullish ? i_clrBull : i_clrBear);
      ObjectSetInteger(0,name3,OBJPROP_COLOR, bullish ? i_clrBull : i_clrBear);
      ObjectSetInteger(0,name0,OBJPROP_STYLE,i_style5P);
      ObjectSetInteger(0,name1,OBJPROP_STYLE,i_style5P);
      ObjectSetInteger(0,name3,OBJPROP_STYLE,i_style5P);
      ObjectSetInteger(0,name4,OBJPROP_COLOR,_clrRatio);
      if(k!=FIVEO) ObjectSetInteger(0,name5,OBJPROP_COLOR,_clrRatio);
      ObjectSetInteger(0,name6,OBJPROP_COLOR,_clrRatio);
      ObjectSetInteger(0,name7,OBJPROP_COLOR,_clrRatio);
      ObjectSetInteger(0,name4,OBJPROP_STYLE,i_styleRatio);
      if(k!=FIVEO) ObjectSetInteger(0,name5,OBJPROP_STYLE,i_styleRatio);
      ObjectSetInteger(0,name6,OBJPROP_STYLE,i_styleRatio);
      ObjectSetInteger(0,name7,OBJPROP_STYLE,i_styleRatio);
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
      PATTERN_DESCRIPTOR pattern=_patterns[k];
      bool ad2xaConstraint=pattern.ad2xa_max!=0 && pattern.ad2xa_min!=0;
      bool cd2xcConstraint=pattern.cd2xc_max!=0 && pattern.cd2xc_min!=0;
      bool xcdMostRelevant=cd2xcConstraint&&!ad2xaConstraint;
      if(k!=FIVEO && xcdMostRelevant)
         ObjectSetString(0,name5,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" XCD="+xcd);
      else if(k!=FIVEO)
         ObjectSetString(0,name5,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" XAD="+xad);
      ObjectSetString(0,name6,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" ABC="+abc);
      ObjectSetString(0,name7,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" BCD="+bcd);
      ObjectSetInteger(0,name0,OBJPROP_WIDTH,i_lineWidth);
      ObjectSetInteger(0,name1,OBJPROP_WIDTH,i_lineWidth);
      ObjectSetInteger(0,name2,OBJPROP_WIDTH,i_lineWidth);
      ObjectSetInteger(0,name3,OBJPROP_WIDTH,i_lineWidth);
      if(i_fillPatterns && (k!=FIVEO && k!=THREEDRIVES))
        {
         ObjectCreate(0,triangle_XB,OBJ_TRIANGLE,0,XDateTime,X,ADateTime,A,BDateTime,B);
         ObjectCreate(0,triangle_BD,OBJ_TRIANGLE,0,BDateTime,B,CDateTime,C,DDateTime,D);
         ObjectSetInteger(0,triangle_XB,OBJPROP_COLOR,bullish ? i_clrBull : i_clrBear);
         ObjectSetInteger(0,triangle_XB,OBJPROP_STYLE,STYLE_SOLID);
         ObjectSetInteger(0,triangle_XB,OBJPROP_FILL,true);
         ObjectSetInteger(0,triangle_XB,OBJPROP_BACK,true);
         ObjectSetInteger(0,triangle_XB,OBJPROP_SELECTABLE,true);
         ObjectSetInteger(0,triangle_XB,OBJPROP_SELECTED,false);
         ObjectSetInteger(0,triangle_BD,OBJPROP_COLOR,bullish ? i_clrBull : i_clrBear);
         ObjectSetInteger(0,triangle_BD,OBJPROP_STYLE,STYLE_SOLID);
         ObjectSetInteger(0,triangle_BD,OBJPROP_FILL,true);
         ObjectSetInteger(0,triangle_BD,OBJPROP_BACK,true);
         ObjectSetInteger(0,triangle_BD,OBJPROP_SELECTABLE,true);
         ObjectSetInteger(0,triangle_BD,OBJPROP_SELECTED,false);
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
      string unique=UniqueIdentifier(ADateTime,BDateTime,CDateTime,DDateTime);
      string prefix=(bullish ? "Proj. Bullish " : "Proj. Bearish ");
      string prefixName=(bullish ? "PU "+_identifier : "PD "+_identifier);
      string name0=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" AB"+unique;
      string name1=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" BC"+unique;
      string name2=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" CD"+unique;
      string pointA=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PA"+unique;
      string pointB=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PB"+unique;
      string pointC=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PC"+unique;
      string pointD=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PD"+unique;
      string prz=prefixName+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PRS"+unique;
      color clr = bullish ? i_clrBullProjection4P : i_clrBearProjection4P;
      color clrleg=i_showSoftProjections ? _faintBGColor : clr;

      ObjectCreate(0,name0,OBJ_TREND,0,ADateTime,A,BDateTime,B);
      ObjectCreate(0,name1,OBJ_TREND,0,BDateTime,B,CDateTime,C);
      ObjectCreate(0,name2,OBJ_TREND,0,CDateTime,C,DDateTime,D);
      ObjectSetInteger(0,name0,OBJPROP_COLOR,clrleg);
      ObjectSetInteger(0,name1,OBJPROP_COLOR,clrleg);
      ObjectSetInteger(0,name2,OBJPROP_COLOR,clrleg);
      ObjectSetInteger(0,name0,OBJPROP_SELECTABLE,true);
      ObjectSetInteger(0,name1,OBJPROP_SELECTABLE,true);
      ObjectSetInteger(0,name2,OBJPROP_SELECTABLE,true);
      ObjectSetString(0,name0,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" AB");
      ObjectSetString(0,name1,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" BC");
      ObjectSetString(0,name2,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" CD");
      ObjectSetInteger(0,name0,OBJPROP_WIDTH,i_lineWidthProj);
      ObjectSetInteger(0,name1,OBJPROP_WIDTH,i_lineWidthProj);
      ObjectSetInteger(0,name2,OBJPROP_WIDTH,i_lineWidthProj);
      ObjectSetInteger(0,name0,OBJPROP_STYLE,i_styleProj);
      ObjectSetInteger(0,name1,OBJPROP_STYLE,i_styleProj);
      ObjectSetInteger(0,name2,OBJPROP_STYLE,i_styleProj);

      if(i_showSoftProjections)
        {
         ObjectSetInteger(0,name0,OBJPROP_BACK,true);
         ObjectSetInteger(0,name1,OBJPROP_BACK,true);
         ObjectSetInteger(0,name2,OBJPROP_BACK,true);
        }
      if(i_showDescriptions && !i_showSoftProjections)
        {
         ObjectCreate(0,pointA,OBJ_TEXT,0,ADateTime,A);
         ObjectCreate(0,pointB,OBJ_TEXT,0,BDateTime,B);
         ObjectCreate(0,pointC,OBJ_TEXT,0,CDateTime,C);
         ObjectCreate(0,pointD,OBJ_TEXT,0,DDateTime,D);
         ObjectSetInteger(0,pointA,OBJPROP_SELECTABLE,true);
         ObjectSetInteger(0,pointB,OBJPROP_SELECTABLE,true);
         ObjectSetInteger(0,pointC,OBJPROP_SELECTABLE,true);
         ObjectSetInteger(0,pointD,OBJPROP_SELECTABLE,true);
         ObjectSetString(0,pointA,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PA");
         ObjectSetString(0,pointB,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PB");
         ObjectSetString(0,pointC,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PC");
         ObjectSetString(0,pointD,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PD");
         ObjectSetString(0,pointA,OBJPROP_TEXT,"A");
         ObjectSetString(0,pointA,OBJPROP_FONT,"Arial");
         ObjectSetInteger(0,pointA,OBJPROP_FONTSIZE,i_fontSize);
         ObjectSetInteger(0,pointA,OBJPROP_COLOR,clrleg);
         ObjectSetString(0,pointB,OBJPROP_TEXT,"B");
         ObjectSetString(0,pointB,OBJPROP_FONT,"Arial");
         ObjectSetInteger(0,pointB,OBJPROP_FONTSIZE,i_fontSize);
         ObjectSetInteger(0,pointB,OBJPROP_COLOR,clrleg);
         ObjectSetString(0,pointC,OBJPROP_TEXT,"C");
         ObjectSetString(0,pointC,OBJPROP_FONT,"Arial");
         ObjectSetInteger(0,pointC,OBJPROP_FONTSIZE,i_fontSize);
         ObjectSetInteger(0,pointC,OBJPROP_COLOR,clrleg);
         ObjectSetString(0,pointD,OBJPROP_TEXT,(i_showSoftProjections ? "" :" D ")+prefix+_patternNames[k]);
         ObjectSetString(0,pointD,OBJPROP_FONT,"Arial");
         ObjectSetInteger(0,pointD,OBJPROP_FONTSIZE,i_fontSize);
         ObjectSetInteger(0,pointD,OBJPROP_COLOR,clr);
        }
      ObjectCreate(0,prz,OBJ_TREND,0,DDateTime-1,D,DDateTime+_deltaDT,D);
      ObjectSetInteger(0,prz,OBJPROP_SELECTABLE,true);
      ObjectSetInteger(0,prz,OBJPROP_RAY_RIGHT,false);
      //ObjectSetInteger(0,prz,OBJPROP_WIDTH,i_lineWidthProj);
      //ObjectSetInteger(0,prz,OBJPROP_STYLE,i_styleProj);
      ObjectSetInteger(0,prz,OBJPROP_STYLE,i_stylePRZ);
      ObjectSetInteger(0,prz,OBJPROP_COLOR,clr);
      ObjectSetString(0,prz,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PRZ start "+DoubleToString(D));
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
      string prefix=(bullish ? "Proj. Bullish " : "Proj. Bearish ");
      string prefixName=(bullish ? "PU " : "PD ")+_identifier+StringFormat("%x",_timeOfInit)+IntegerToString(k);
      string name0=prefixName+" XA"+unique;
      string name1=prefixName+" AB"+unique;
      string name2=prefixName+" BC"+unique;
      string name3=prefixName+" CD"+unique;
      string name4=prefixName+" XAB"+unique;
      string name5=prefixName+" XAD"+unique;
      string name6=prefixName+" ABC"+unique;
      string name7=prefixName+" BCD"+unique;
      string pointX=prefixName+" PX"+unique;
      string pointA=prefixName+" PA"+unique;
      string pointB=prefixName+" PB"+unique;
      string pointC=prefixName+" PC"+unique;
      string pointD=prefixName+" PD"+unique;
      string prz=prefixName+" PRS"+unique;
      string xcd=IntegerToString((int) MathRound(100*MathAbs(D-C)/MathAbs(X-C)));
      string xab=IntegerToString((int) MathRound(100*MathAbs(A-B)/MathAbs(X-A)));
      string xad=IntegerToString((int) MathRound(100*MathAbs(D-A)/MathAbs(X-A)));
      string abc=IntegerToString((int) MathRound(100*MathAbs(C-B)/MathAbs(B-A)));
      //--- Cypher and Nen Start have the A-C top as XC/XA instead of CB/BA
      if(k==CYPHER || k==NENSTAR || k==NEWCYPHER)
         abc=IntegerToString((int) MathRound(100*MathAbs(X-C)/MathAbs(X-A)));
      string bcd=IntegerToString((int) MathRound(100*MathAbs(C-D)/MathAbs(B-C)));
      color clr = bullish ? i_clrBullProjection : i_clrBearProjection;
      color clrleg=i_showSoftProjections ? _faintBGColor : clr;
      color clrratio=i_showSoftProjections ? _faintBGColor : _clrRatio;

      ObjectCreate(0,name0,OBJ_TREND,0,XDateTime,X,ADateTime,A);
      ObjectCreate(0,name1,OBJ_TREND,0,ADateTime,A,BDateTime,B);
      ObjectCreate(0,name2,OBJ_TREND,0,BDateTime,B,CDateTime,C);
      ObjectCreate(0,name3,OBJ_TREND,0,CDateTime,C,DDateTime,D);
      ObjectCreate(0,name4,OBJ_TREND,0,XDateTime,X,BDateTime,B);
      if(k!=FIVEO) ObjectCreate(0,name5,OBJ_TREND,0,XDateTime,X,DDateTime,D);
      ObjectCreate(0,name6,OBJ_TREND,0,ADateTime,A,CDateTime,C);
      ObjectCreate(0,name7,OBJ_TREND,0,BDateTime,B,DDateTime,D);
      ObjectSetInteger(0,name0,OBJPROP_COLOR,clrleg);
      ObjectSetInteger(0,name1,OBJPROP_COLOR,clrleg);
      ObjectSetInteger(0,name2,OBJPROP_COLOR,clrleg);
      ObjectSetInteger(0,name3,OBJPROP_COLOR,clrleg);
      ObjectSetInteger(0,name4,OBJPROP_COLOR,clrratio);
      if(k!=FIVEO) ObjectSetInteger(0,name5,OBJPROP_COLOR,clrratio);
      ObjectSetInteger(0,name6,OBJPROP_COLOR,clrratio);
      ObjectSetInteger(0,name7,OBJPROP_COLOR,clrratio);
      ObjectSetInteger(0,name0,OBJPROP_STYLE,i_styleProj);
      ObjectSetInteger(0,name1,OBJPROP_STYLE,i_styleProj);
      ObjectSetInteger(0,name2,OBJPROP_STYLE,i_styleProj);
      ObjectSetInteger(0,name3,OBJPROP_STYLE,i_styleProj);
      ObjectSetInteger(0,name4,OBJPROP_STYLE,i_styleRatio);
      ObjectSetInteger(0,name5,OBJPROP_STYLE,i_styleRatio);
      ObjectSetInteger(0,name6,OBJPROP_STYLE,i_styleRatio);
      ObjectSetInteger(0,name7,OBJPROP_STYLE,i_styleRatio);
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
      PATTERN_DESCRIPTOR pattern=_patterns[k];
      bool ad2xaConstraint=pattern.ad2xa_max!=0 && pattern.ad2xa_min!=0;
      bool cd2xcConstraint=pattern.cd2xc_max!=0 && pattern.cd2xc_min!=0;
      bool xcdMostRelevant=cd2xcConstraint&&!ad2xaConstraint;
      if(k!=FIVEO && xcdMostRelevant)
         ObjectSetString(0,name5,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" XCD="+xcd);
      else if(k!=FIVEO)
         ObjectSetString(0,name5,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" XAD="+xad);
      ObjectSetString(0,name6,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" ABC="+abc);
      ObjectSetString(0,name7,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" BCD="+bcd);

      if(i_showSoftProjections)
        {
         ObjectSetInteger(0,name0,OBJPROP_BACK,true);
         ObjectSetInteger(0,name1,OBJPROP_BACK,true);
         ObjectSetInteger(0,name2,OBJPROP_BACK,true);
         ObjectSetInteger(0,name3,OBJPROP_BACK,true);
         ObjectSetInteger(0,name4,OBJPROP_BACK,true);
         ObjectSetInteger(0,name5,OBJPROP_BACK,true);
         ObjectSetInteger(0,name6,OBJPROP_BACK,true);
         ObjectSetInteger(0,name7,OBJPROP_BACK,true);
        }

      if(i_showDescriptions && !i_showSoftProjections)
        {
         ObjectCreate(0,pointX,OBJ_TEXT,0,XDateTime,X);
         ObjectCreate(0,pointA,OBJ_TEXT,0,ADateTime,A);
         ObjectCreate(0,pointB,OBJ_TEXT,0,BDateTime,B);
         ObjectCreate(0,pointC,OBJ_TEXT,0,CDateTime,C);
         ObjectCreate(0,pointD,OBJ_TEXT,0,DDateTime,D);
         ObjectSetInteger(0,pointX,OBJPROP_SELECTABLE,true);
         ObjectSetInteger(0,pointA,OBJPROP_SELECTABLE,true);
         ObjectSetInteger(0,pointB,OBJPROP_SELECTABLE,true);
         ObjectSetInteger(0,pointC,OBJPROP_SELECTABLE,true);
         ObjectSetInteger(0,pointD,OBJPROP_SELECTABLE,true);
         ObjectSetString(0,pointX,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PX");
         ObjectSetString(0,pointA,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PA");
         ObjectSetString(0,pointB,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PB");
         ObjectSetString(0,pointC,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PC");
         ObjectSetString(0,pointD,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PD");
         ObjectSetInteger(0,name0,OBJPROP_WIDTH,i_lineWidthProj);
         ObjectSetInteger(0,name1,OBJPROP_WIDTH,i_lineWidthProj);
         ObjectSetInteger(0,name2,OBJPROP_WIDTH,i_lineWidthProj);
         ObjectSetInteger(0,name3,OBJPROP_WIDTH,i_lineWidthProj);
         ObjectSetString(0,pointX,OBJPROP_TEXT,"X");
         ObjectSetString(0,pointX,OBJPROP_FONT,"Arial");
         ObjectSetInteger(0,pointX,OBJPROP_FONTSIZE,i_fontSize);
         ObjectSetInteger(0,pointX,OBJPROP_COLOR,clrleg);
         ObjectSetString(0,pointA,OBJPROP_TEXT,"A");
         ObjectSetString(0,pointA,OBJPROP_FONT,"Arial");
         ObjectSetInteger(0,pointA,OBJPROP_FONTSIZE,i_fontSize);
         ObjectSetInteger(0,pointA,OBJPROP_COLOR,clrleg);
         ObjectSetString(0,pointB,OBJPROP_TEXT,"B");
         ObjectSetString(0,pointB,OBJPROP_FONT,"Arial");
         ObjectSetInteger(0,pointB,OBJPROP_FONTSIZE,i_fontSize);
         ObjectSetInteger(0,pointB,OBJPROP_COLOR,clrleg);
         ObjectSetString(0,pointC,OBJPROP_TEXT,"C");
         ObjectSetString(0,pointC,OBJPROP_FONT,"Arial");
         ObjectSetInteger(0,pointC,OBJPROP_FONTSIZE,i_fontSize);
         ObjectSetInteger(0,pointC,OBJPROP_COLOR,clrleg);
         ObjectSetString(0,pointD,OBJPROP_TEXT,(i_showSoftProjections ? "" :" D ")+prefix+_patternNames[k]);
         ObjectSetString(0,pointD,OBJPROP_FONT,"Arial");
         ObjectSetInteger(0,pointD,OBJPROP_FONTSIZE,i_fontSize);
         ObjectSetInteger(0,pointD,OBJPROP_COLOR,clr);
        }
      ObjectCreate(0,prz,OBJ_TREND,0,DDateTime-1,D,DDateTime+_deltaDT,D);
      ObjectSetInteger(0,prz,OBJPROP_SELECTABLE,true);
      ObjectSetInteger(0,prz,OBJPROP_RAY_RIGHT,false);
      //ObjectSetInteger(0,prz,OBJPROP_STYLE,i_styleProj);
      //ObjectSetInteger(0,prz,OBJPROP_WIDTH,i_lineWidthProj);
      ObjectSetInteger(0,prz,OBJPROP_STYLE,i_stylePRZ);
      ObjectSetInteger(0,prz,OBJPROP_COLOR,bullish ? i_clrBullProjection: i_clrBearProjection);
      ObjectSetString(0,prz,OBJPROP_TOOLTIP,prefix+_patternNames[k]+" PRZ start "+DoubleToString(D));
     }
  };
//--- End header guard
#endif
//+------------------------------------------------------------------+

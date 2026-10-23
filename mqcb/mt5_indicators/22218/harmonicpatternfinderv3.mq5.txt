//+------------------------------------------------------------------+
//|                                      HarmonicPatternFinderV3.mq5 |
//|                                  Copyright 2018, André S. Enger. |
//|                                          andre_enger@hotmail.com |
//|                                  Contribs                        |
//|                                         David Gadelha            |
//|                                               dgadelha@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Andre S. Enger."
#property link      "andre_enger@hotmail.com"
#property version   "3.2"
#property description "Indicator to display existent and emerging harmonic chart patterns."

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 1

#property indicator_label1  "Zig Zag"
#property indicator_type1   DRAW_ZIGZAG
#property indicator_color1  clrNONE
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- Globals are defined in own file due to being shared among several classes
#include "HPFGlobals.mqh"
CHPFDrawingObserver _drawer;
CHPFCommentObserver _commentator(NUM_PATTERNS,i_barsAnalyzed*2,showPatternNames);
CHPFPurityFilter _purityFilter;

//+------------------------------------------------------------------+
//| Indicator initialization function                                |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,_peaks,INDICATOR_DATA);
   SetIndexBuffer(1,_troughs,INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
   MathSrand(GetTickCount());
   _timeOfInit=MathRand();
   for(int i=ObjectsTotal(0,0,-1)-1; i>=0; i--)
     {
      string name=ObjectName(0,i,0,-1);
      if(StringFind(name,"U "+_identifier)!=-1 || StringFind(name,"D "+_identifier)!=-1)
         ObjectDelete(0,name);
     }
   int ret=PopulatePatterns();
   _purityFilter.SetActivated(i_puristPRZ);
   _timeFilter.SetActivated(i_timefilterEarly,i_timefilterLate);
   _commentator.SetStatistics(&_statistics);
   _observers.Set(0,&_statistics);
   _observers.Set(1,&_drawer);
   _observers.Set(2,&_commentator);
   _filters.Set(0,&_purityFilter);
   _filters.Set(1,&_timeFilter);
   _matcher.SetSlackRange(i_slackRange);
   _matcher.SetSlackUnary(i_slackSingular);
   _matcher.SetMatchProcessor(&_indicator);
   _indicator.SetMaxOverlap(i_maxSamePoints);
   _indicator.SetObserver(&_observers);
   _indicator.SetFilter(&_filters);
   ChartGetInteger(0,CHART_COLOR_BACKGROUND,0,_clrbackground);
   _faintBGColor=ColorIntensity(_clrbackground,40,true);
   _clrRatio=ColorIntensity(_clrbackground,80,true);
   return ret;
  }
//+------------------------------------------------------------------+
//| Indicator deinitialization function                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   OnReinit();
   Comment("");
   ArrayFree(_patterns);
   ArrayFree(_patternNames);
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
   ObjectsDeleteAll(0,"U "+_identifier+StringFormat("%x",_timeOfInit));
   ObjectsDeleteAll(0,"D "+_identifier+StringFormat("%x",_timeOfInit));
   ObjectsDeleteAll(0,"PU "+_identifier+StringFormat("%x",_timeOfInit));
   ObjectsDeleteAll(0,"PD "+_identifier+StringFormat("%x",_timeOfInit));
   _indicator.Reset();
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
//--- Call embedded zigzag
   ZZOnCalculate(rates_total,prev_calculated,time,open,high,low,close,tick_volume,volume,spread);
//---
   int start=0;
   if(prev_calculated>rates_total || prev_calculated<=0)
      OnReinit();
   else
      start=prev_calculated-1;
   start=MathMax(1,start);
//--- copy data
   ArrayCopy(_time,time,0,0);
   _drawer.SetBar(rates_total);
   _timeFilter.SetBar(rates_total);
   if(i_timefilterEarly || i_timefilterLate)
      _timeFilter.SetPrices(low,high);
//--- main loop
   for(int bar=start; bar<rates_total && !IsStopped(); bar++)
     {
      //--- Efficency checks
      if(bar<rates_total-i_history)
         continue;
      int lastPeak=FirstNonZeroFrom(bar,_peaks);
      int lastTrough=FirstNonZeroFrom(bar,_troughs);
      if(lastPeak==-1 || lastTrough==-1)
         continue;
      double lastPeakValue=_peaks[lastPeak];
      double lastTroughValue=_troughs[lastTrough];
      if(lastPeakValue==_lastPeakValue && lastTroughValue==_lastTroughValue)
         continue;
      //--- ZZ assessment
      bool endsInTrough=lastTrough>lastPeak;
      if(lastTrough==lastPeak)
        {
         int zzDirection=ZigZagDirection(lastPeak,_peaks,_troughs);
         if(zzDirection==0) continue;
         else if(zzDirection==-1) endsInTrough=true;
         else if(zzDirection==1) endsInTrough=false;
        }
      //--- Undisplay old projections, patterns (on current swing), and PRZs
      UndisplayProjections();
      UndisplayPatterns(time);
      //--- Persist transitent patterns on new ZZ direction
      if(!(_lastDirection==endsInTrough && !(_lastPeak<lastPeak && _lastTrough<lastTrough)))
        {
         _indicator.PersistTransient();
        }
      _indicator.ClearTransient();
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
         if(!ShouldDisplay(patternIndex))
            continue;
         PATTERN_DESCRIPTOR pattern=_patterns[patternIndex];
         _indicator.PreFind(patternIndex);
         _matcher.FindPattern(pattern,bar-i_barsAnalyzed,bar,lastPeak,lastTrough,_peaks,_troughs);
         _indicator.PostFind(patternIndex,lastPeak,lastTrough,endsInTrough);
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Embedded zigzag OnCalculate() method                             |
//+------------------------------------------------------------------+
int ZZOnCalculate(const int rates_total,
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
      start=1;
      _lastIndex=0;
      _lastIndex2=0;
      _contraIndex=0;
      _atr=0;
      _realtimeChange=false;
     }
   else
      start=MathMax(1,prev_calculated-1);
   double atr=_atr;
//--- main loop
   for(int bar=start; bar<rates_total-(i_zzRealtime?0:1); bar++)
     {
      bool realtimeBar=bar==rates_total-1;
      //--- Update ATR and other tasks
      if(!realtimeBar)
        {
         double tr=MathMax(high[bar],close[bar-1])-MathMin(low[bar],close[bar-1]);
         atr+=(tr-atr)*(2.0/(1.0+i_zzAtrPeriod));
         _atr=atr;
         if(_realtimeChange && i_zzRealtime)
           {
            if(_zzLastDirection)
               _peaks[_lastIndex]=high[_lastIndex];
            else
               _troughs[_lastIndex]=low[_lastIndex];
            _peaks[rates_total-1]=0;
            _troughs[rates_total-1]=0;
            _realtimeChange=false;
           }
         //---
         _troughs[bar]=0;
         _peaks[bar]=0;
        }
      //--- Conditions
      bool shouldntChange=bar-_lastIndex<i_zzMinPeriod;
      bool shallChange=bar-_lastIndex>i_zzMaxPeriod;
      bool mustChange,shouldChange,canChange;
      if(_zzLastDirection)
        {
         mustChange=low[bar]<low[_lastIndex2];
         shouldChange=_peaks[_lastIndex]-low[bar]>atr*i_zzAtrMultiplier;
         canChange=low[bar]<low[_contraIndex];
        }
      else
        {
         mustChange=high[bar]>high[_lastIndex2];
         shouldChange=high[bar]-_troughs[_lastIndex]>atr*i_zzAtrMultiplier;
         canChange=high[bar]>high[_contraIndex];
        }
      bool changeNow=mustChange || (canChange && shouldChange && !shouldntChange);
      //--- Algorithm realtime
      if(realtimeBar && i_zzRealtime)
        {
         if(_zzLastDirection)
           {
            if(!_realtimeChange && high[bar]>_peaks[_lastIndex])
              {
               _peaks[_lastIndex]=0;
               _peaks[bar]=high[bar];
               _realtimeChange=true;
              }
            else if(_realtimeChange && high[bar]>_peaks[bar])
              {
               _peaks[bar]=high[bar];
              }
           }
         else
           {
            if(!_realtimeChange && low[bar]<_troughs[_lastIndex])
              {
               _troughs[_lastIndex]=0;
               _troughs[bar]=low[bar];
               _realtimeChange=true;
              }
            else if(_realtimeChange && low[bar]<_troughs[bar])
              {
               _troughs[bar]=low[bar];
              }
           }
        }
      else
        {
         if(canChange)
            _contraIndex=bar;
         if(_zzLastDirection)
           {
            if(high[bar]>_peaks[_lastIndex])
              {
               _peaks[_lastIndex]=0;
               _peaks[bar]=high[bar];
               if(open[bar]>close[bar])
                 {
                  shouldntChange=0<i_zzMinPeriod;
                  shouldChange=_peaks[bar]-low[bar]>atr*i_zzAtrMultiplier;
                  changeNow=mustChange || (canChange && shouldChange && !shouldntChange);
                  if(changeNow)
                    {
                     _troughs[bar]=low[bar];
                     _zzLastDirection=false;
                     _lastIndex2=bar;
                    }
                 }
               else if(changeNow)
                 {
                  _peaks[_lastIndex]=high[_lastIndex];
                  _troughs[bar]=low[bar];
                  _lastIndex2=bar;
                 }
               _lastIndex=bar;
               _contraIndex=bar;
              }
            else if(changeNow)
              {
               _troughs[bar]=low[bar];
               _zzLastDirection=false;
               _lastIndex2=_lastIndex;
               _lastIndex=bar;
               _contraIndex=bar;
              }
            else if(shallChange)
              {
               int startSkip=_troughs[_lastIndex]==0?0:1;
               if(open[_lastIndex]<close[_lastIndex] && startSkip==0) startSkip++;
               bar=ArrayMinimum(low,_lastIndex+startSkip,bar-_lastIndex-startSkip+1);
               _troughs[bar]=low[bar];
               _zzLastDirection=false;
               _lastIndex2=_lastIndex;
               _lastIndex=bar;
               _contraIndex=bar;
              }
           }
         else
           {
            //--- bear trend
            if(low[bar]<_troughs[_lastIndex])
              {
               _troughs[_lastIndex]=0;
               _troughs[bar]=low[bar];
               if(open[bar]<close[bar])
                 {
                  shouldntChange=0<i_zzMinPeriod;
                  shouldChange=high[bar]-_troughs[bar]>atr*i_zzAtrMultiplier;
                  changeNow=mustChange || (canChange && shouldChange && !shouldntChange);
                  if(changeNow)
                    {
                     _peaks[bar]=high[bar];
                     _zzLastDirection=true;
                     _lastIndex2=bar;
                    }
                 }
               else if(changeNow)
                 {
                  _troughs[_lastIndex]=low[_lastIndex];
                  _peaks[bar]=high[bar];
                  _lastIndex2=bar;
                 }
               _lastIndex=bar;
               _contraIndex=bar;
              }
            else if(changeNow)
              {
               _peaks[bar]=high[bar];
               _zzLastDirection=true;
               _lastIndex2=_lastIndex;
               _lastIndex=bar;
               _contraIndex=bar;
              }
            else if(shallChange)
              {
               int startSkip=_peaks[_lastIndex]==0?0:1;
               if(open[_lastIndex]>close[_lastIndex] && startSkip==0) startSkip++;
               bar=ArrayMaximum(high,_lastIndex+startSkip,bar-_lastIndex-startSkip+1);
               _peaks[bar]=high[bar];
               _zzLastDirection=true;
               _lastIndex2=_lastIndex;
               _lastIndex=bar;
               _contraIndex=bar;
              }
           }
         //--- 
         _peaks[rates_total-1]=0;
         _troughs[rates_total-1]=0;
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Highlights clicked patterns in an interactive manner             |                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam
                  )
  {
//--- Is click event?
   if(id!=CHARTEVENT_OBJECT_CLICK)
      return;
//--- Is object with HPF?
   if(!StringFind(_identifier+StringFormat("%x",_timeOfInit),sparam,0))
      return;
//--- Is object double click selected?
   bool doubleClicked=GetTickCount()-_prevClick<1000;
   _prevClick=GetTickCount();
   if(!doubleClicked)
      return;
//--- Get pattern properties
   bool projection=StringFind(StringSubstr(sparam,0,1),"P",0)>=0;
   bool bullish=StringFind(StringSubstr(sparam,0,2),"U",0)>=0;
   string splitString[];
   StringSplit(sparam,' ',splitString);
   string indx=StringSubstr(splitString[1],StringLen(_identifier+StringFormat("%x",_timeOfInit)));
   int patternIndex=(int)StringToInteger(indx);
   if(ArraySize(splitString)<4)
      return;
   string unique=" "+splitString[3];
   bool is4PointPattern=_indicator.Is4PointPattern(patternIndex);
//--- Get object names
   string prefixName=(projection?"P":"")+(bullish ? "U " : "D ")+_identifier+StringFormat("%x",_timeOfInit)+IntegerToString(patternIndex);
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
   string triangle_XB=prefixName+" XB"+unique;
   string triangle_BD=prefixName+" BD"+unique;
   string prz=prefixName+" PRZ"+unique;
   bool transient=false;
   if(ObjectFind(0,prz)>=0)
      transient=true;
   else
      prz=prefixName+" PRS"+unique;
//--- Get price points
   double X=ObjectGetDouble(0,name0,OBJPROP_PRICE,0);
   double A=ObjectGetDouble(0,name1,OBJPROP_PRICE,0);
   double B=ObjectGetDouble(0,name2,OBJPROP_PRICE,0);
   double C=ObjectGetDouble(0,name2,OBJPROP_PRICE,1);
   datetime XDateTime=(datetime)ObjectGetInteger(0,name0,OBJPROP_TIME,0);
   datetime ADateTime=(datetime)ObjectGetInteger(0,name1,OBJPROP_TIME,0);
   datetime BDateTime=(datetime)ObjectGetInteger(0,name2,OBJPROP_TIME,0);
   datetime CDateTime=(datetime)ObjectGetInteger(0,name2,OBJPROP_TIME,1);
   datetime DDateTime=(datetime)ObjectGetInteger(0,name3,OBJPROP_TIME,1);
//--- Names for created objects
   string linePRZ=prefixName+" PRH"+unique;
   string timeZones=prefixName+" T"+unique;
   string lineXAD=prefixName+" lv1"+unique;
   string lineXCD=prefixName+" lv2"+unique;
   string lineBCD=prefixName+" lv3"+unique;
   string lineACD=prefixName+" lv4"+unique;
   string lineCD2AD=prefixName+" lv5"+unique;

   string prefix;
   if(projection)
      prefix=(bullish ? "Proj. Bullish " : "Proj. Bearish ");
   else
      prefix=(bullish ? "Bullish " : "Bearish ");
//--- 
   color clr=_clrRatio;
   color clrRatio=_clrRatio;
   color clrLeg=clr;
   int width=i_lineWidth;
   int widthPRZ=1;
   bool selected=ObjectGetInteger(0,sparam,OBJPROP_SELECTED);
//--- On
   if(selected)
     {
      clr=clrRatio=i_clrFocus;
      clrLeg=clr;
      width=i_lineWidthFoc;
      widthPRZ=2;
      string comment=bullish? "F. Bull. " : "F. Bear. ";
      comment+=_patternNames[patternIndex];
      comment+=" Prob. "+DoubleToString(_statistics.GetSuccessRate(patternIndex)*100,2);
      comment+=" ("+(string)_statistics.GetSuccesses(patternIndex)+" S/ "+(string)_statistics.GetFailures(patternIndex)+" F)";
      _commentator.ShowComment(comment);
      //--- Create early PRZ end line (Must know if already existent to create on other PATTERNS)
      if(!transient)
        {
         double nearD=0;
         double farD=0;
         HarmonicWindow(_patterns[patternIndex],i_slackSingular,i_slackRange,bullish,X,A,B,C,nearD,farD);
         ObjectCreate(0,linePRZ,OBJ_TREND,0,DDateTime-1,farD,DDateTime+_deltaDT,farD);
         ObjectSetInteger(0,linePRZ,OBJPROP_SELECTABLE,true);
         ObjectSetInteger(0,linePRZ,OBJPROP_COLOR,clr);
         ObjectSetInteger(0,linePRZ,OBJPROP_WIDTH,widthPRZ);
         ObjectSetString(0,linePRZ,OBJPROP_TOOLTIP,prefix+_patternNames[patternIndex]+" PRZ stop "+DoubleToString(NormalizeDouble(farD,_Digits),_Digits));
        }
      //--- Create harmonic PRZ levels
      PRZLevels levels=HarmonicRatios(_patterns[patternIndex],bullish,X,A,B,C);
      CreateLine(lineXAD,DDateTime,levels.ad2xa,clr,i_stylePRZ,1,prefix,patternIndex," AD2XA level (",_patterns[patternIndex].ad2xa_min);
      CreateLine(lineXCD,DDateTime,levels.cd2xc,clr,i_stylePRZ,1,prefix,patternIndex," CD2XC level (",_patterns[patternIndex].cd2xc_min);
      CreateLine(lineBCD,DDateTime,levels.cd2bc,clr,i_stylePRZ,1,prefix,patternIndex," CD2BC level (",_patterns[patternIndex].cd2bc_min);
      CreateLine(lineACD,DDateTime,levels.cd2ab,clr,i_stylePRZ,1,prefix,patternIndex," CD2AB level (",_patterns[patternIndex].cd2ab_min);
      CreateLine(lineCD2AD,DDateTime,levels.cd2ad,clr,i_stylePRZ,1,prefix,patternIndex," CD2AD level (",_patterns[patternIndex].cd2ad_min);
      //--- Create fibonacci time zones
      double minVisiblePrice=ChartGetDouble(0,CHART_PRICE_MIN);
      if(!is4PointPattern)
        {
         ObjectCreate(0,timeZones,OBJ_FIBOTIMES,0,XDateTime,0,BDateTime,minVisiblePrice);
        }
      else
        {
         int numBars=Bars(_Symbol,_Period);
         if(numBars<1)
            ObjectCreate(0,timeZones,OBJ_FIBOTIMES,0,CDateTime,A,CDateTime+(BDateTime-ADateTime),B);
         else
           {
            //--- Alternate approach:
            datetime time[];
            CopyTime(_Symbol,_Period,0,numBars,time);
            int ABar=-1,BBar=-1,CBar=-1;
            for(int i=0;i<numBars;i++)
              {
               if(time[i]==ADateTime)
                  ABar=i;
               if(time[i]==BDateTime)
                  BBar=i;
               if(time[i]==CDateTime)
                 {
                  CBar=i;
                  break;
                 }
              }
            int legBars=BBar-ABar;
            datetime secondAnchor;
            if(numBars-CBar>legBars && CBar+legBars>=0)
              {
               secondAnchor=time[CBar+legBars];
              }
            else
              {
               int futureBars=1+CBar+legBars-numBars;
               secondAnchor=time[numBars-1]+(futureBars*PeriodSeconds());
              }
            ObjectCreate(0,timeZones,OBJ_FIBOTIMES,0,CDateTime,0,secondAnchor,minVisiblePrice);
           }
         //---
        }
      //--- Setting fibonacci timezones
      ObjectSetInteger(0,timeZones,OBJPROP_COLOR,clrNONE);
      ObjectSetString(0,timeZones,OBJPROP_TOOLTIP,prefix+_patternNames[patternIndex]+" Timezones ");
      color fibColor=clrNONE;
      if(projection && bullish && is4PointPattern) fibColor=i_clrBullProjection4P;
      else if(projection && bullish && !is4PointPattern) fibColor=i_clrBullProjection;
      else if(projection && !bullish && is4PointPattern) fibColor=i_clrBearProjection4P;
      else if(projection && !bullish && !is4PointPattern) fibColor=i_clrBearProjection;
      else if(!projection && bullish && is4PointPattern) fibColor=i_clrBull4P;
      else if(!projection && bullish && !is4PointPattern) fibColor=i_clrBull;
      else if(!projection && !bullish && is4PointPattern) fibColor=i_clrBear4P;
      else if(!projection && !bullish && !is4PointPattern) fibColor=i_clrBear;
      double shift=is4PointPattern ? 0 : 1;
      ENUM_LINE_STYLE fibStyle=i_styleProj;
      int fibWidth=1;
      const long chart_ID=0;
      const string name=timeZones;
      //--- set the number of levels
      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELS,3);
      //--- set the display properties of the "too early" time-level
      ObjectSetDouble(chart_ID,name,OBJPROP_LEVELVALUE,0,i_tooEarly+shift);
      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELCOLOR,0,fibColor);
      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELSTYLE,0,fibStyle);
      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELWIDTH,0,fibWidth);
      ObjectSetString(chart_ID,name,OBJPROP_LEVELTEXT,0,DoubleToString(i_tooEarly+shift,3));
      //--- set the display properties of the "ideal" time-level
      ObjectSetDouble(chart_ID,name,OBJPROP_LEVELVALUE,1,i_ideal+shift);
      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELCOLOR,1,fibColor);
      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELSTYLE,1,fibStyle);
      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELWIDTH,1,fibWidth);
      ObjectSetString(chart_ID,name,OBJPROP_LEVELTEXT,1,DoubleToString(i_ideal+shift,3));
      //--- set the display properties of the "too late" time-level
      ObjectSetDouble(chart_ID,name,OBJPROP_LEVELVALUE,2,i_tooLate+shift);
      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELCOLOR,2,fibColor);
      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELSTYLE,2,fibStyle);
      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELWIDTH,2,fibWidth);
      ObjectSetString(chart_ID,name,OBJPROP_LEVELTEXT,2,DoubleToString(i_tooLate+shift,3));
     }
//off
   else
     {
      ObjectDelete(0,linePRZ);
      ObjectDelete(0,lineXAD);
      ObjectDelete(0,lineXCD);
      ObjectDelete(0,lineBCD);
      ObjectDelete(0,lineACD);
      ObjectDelete(0,lineCD2AD);
      ObjectDelete(0,timeZones);
      if(projection)
        {
         if(bullish)
           {
            if(is4PointPattern)
               clr=i_clrBullProjection4P;
            else
               clr=i_clrBullProjection;
           }
         else
           {
            if(is4PointPattern)
               clr=i_clrBearProjection4P;
            else
               clr=i_clrBearProjection;
           }
         width=i_lineWidthProj;
         clrLeg=i_showSoftProjections ? _faintBGColor : clr;
         clrRatio=i_showSoftProjections ? _faintBGColor : _clrRatio;
        }
      else
        {
         if(bullish && is4PointPattern)
            clr=i_clrBull4P;
         if(bullish && !is4PointPattern)
            clr=i_clrBull;
         if(!bullish && is4PointPattern)
            clr=i_clrBear4P;
         if(!bullish && !is4PointPattern)
            clr=i_clrBear;
         width=i_lineWidth;
         clrLeg=clr;
         clrRatio=_clrRatio;
        }
     }
   ObjectSetInteger(0,name0,OBJPROP_COLOR,clrLeg);
   ObjectSetInteger(0,name0,OBJPROP_WIDTH,width);
   ObjectSetInteger(0,name1,OBJPROP_COLOR,clrLeg);
   ObjectSetInteger(0,name1,OBJPROP_WIDTH,width);
   ObjectSetInteger(0,name2,OBJPROP_COLOR,clrLeg);
   ObjectSetInteger(0,name2,OBJPROP_WIDTH,width);
   ObjectSetInteger(0,name3,OBJPROP_COLOR,clrLeg);
   ObjectSetInteger(0,name3,OBJPROP_WIDTH,width);
   ObjectSetInteger(0,name4,OBJPROP_COLOR,clrRatio);
   ObjectSetInteger(0,name5,OBJPROP_COLOR,clrRatio);
   ObjectSetInteger(0,name6,OBJPROP_COLOR,clrRatio);
   ObjectSetInteger(0,name7,OBJPROP_COLOR,clrRatio);
   ObjectSetInteger(0,pointX,OBJPROP_COLOR,clrLeg);
   ObjectSetInteger(0,pointA,OBJPROP_COLOR,clrLeg);
   ObjectSetInteger(0,pointB,OBJPROP_COLOR,clrLeg);
   ObjectSetInteger(0,pointC,OBJPROP_COLOR,clrLeg);
   ObjectSetInteger(0,pointD,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,triangle_XB,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,triangle_BD,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,prz,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,prz,OBJPROP_WIDTH,widthPRZ);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Helper/Refactoring/Condensation of repetitive drawing code       |
//+------------------------------------------------------------------+
void CreateLine(string line,
                datetime DDateTime,
                double level,
                color clr,
                ENUM_LINE_STYLE style,
                int width,
                string prefix,
                int patternIndex,
                string levelName,
                double levelDef)
  {
   ObjectCreate(0,line,OBJ_TREND,0,DDateTime-1,level,DDateTime+_deltaDT,level);
   ObjectSetInteger(0,line,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,line,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,line,OBJPROP_STYLE,style);
   ObjectSetInteger(0,line,OBJPROP_WIDTH,width);
   ObjectSetString(0,line,OBJPROP_TOOLTIP,prefix+_patternNames[patternIndex]+levelName+
                   DoubleToString(NormalizeDouble(levelDef,_Digits),3)+") "+
                   DoubleToString(NormalizeDouble(level,_Digits),_Digits));
  }
//+------------------------------------------------------------------+
//| Helper method determines "soft" color based on background scheme |
//+------------------------------------------------------------------+
color ColorIntensity(long lcolor,int ishift=30,bool dim=false)
  {
//decomposing color
   int blue=(int) MathFloor(lcolor/65536);
   int green=(int) MathFloor((lcolor-(blue*65536))/256);
   int red=(int) lcolor -(blue*65536) -(green*256);

   if(dim)
     {
      blue =((blue<127)  ? blue+ishift+(blue*ishift/100)  : blue-ishift-(blue*ishift/100));
      green=((green<127) ?  green+ishift+(green*ishift/100)  : green-ishift-(green*ishift/100));
      red  =((red<127)   ?  red+ishift+(red*ishift/100)  : red-ishift-(red*ishift/100));
     }
   else
     {
      //glowing
      red=red+(red*ishift/100);
      green=green+(green*ishift/100);
      blue=blue+(blue*ishift/100);
     }
   red=(red>255) ? 255 : red;
   red=(red<0) ? 0 : red;
   green=(green>255) ? 255 : green;
   green=(green<0) ? 0 : green;
   blue=(blue>255) ? 255 : blue;
   blue=(blue<0) ? 0 : blue;

   string sred=IntegerToString(red);
   string sgreen=IntegerToString(green);
   string sblue=IntegerToString(blue);
   return ( StringToColor (sred+","+sgreen+","+sblue));
  }

//+------------------------------------------------------------------+
//| Helper method undisplays projections                             |
//+------------------------------------------------------------------+
void UndisplayProjections()
  {
   ObjectsDeleteAll(0,"PU "+_identifier);
   ObjectsDeleteAll(0,"PD "+_identifier);
  }
//+------------------------------------------------------------------+
//| Helper method undisplays recently drawn patterns                 |
//+------------------------------------------------------------------+
void UndisplayPatterns(const datetime &time[])
  {
   for(int k=0; k<NUM_PATTERNS; k++)
     {
      CHPFRingbuffer *stored=_indicator.GetMatchedTransient(k);
      int tail=stored.GetTail();
      int head=stored.GetHead();
      int capacity=stored.GetCapacity();
      for(int j=tail; j!=head; j=(j+1)%capacity)
        {
         PATTERN_MATCH match=stored.GetMatch(j);
         bool bullish=match.bullish;
         datetime XDateTime=time[match.XIndex];
         datetime ADateTime=time[match.AIndex];
         datetime BDateTime=time[match.BIndex];
         datetime CDateTime=time[match.CIndex];
         datetime DDateTime=time[match.DIndex];
         //--- Delete pattern from chart
         string unique=_indicator.Is4PointPattern(k)?UniqueIdentifier(ADateTime,BDateTime,CDateTime,DDateTime): UniqueIdentifier(XDateTime,ADateTime,BDateTime,CDateTime,DDateTime);
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
   for(int k=0; k<NUM_PATTERNS; k++)
     {
      CHPFRingbuffer *stored=_indicator.GetMatchedTransient(k);
      int tail=stored.GetTail();
      int head=stored.GetHead();
      int capacity=stored.GetCapacity();
      for(int j=tail; j!=head; j=(j+1)%capacity)
        {
         PATTERN_MATCH match=stored.GetMatch(j);
         bool bullish=match.bullish;
         datetime XDateTime=time[match.XIndex];
         datetime ADateTime=time[match.AIndex];
         datetime BDateTime=time[match.BIndex];
         datetime CDateTime=time[match.CIndex];
         datetime DDateTime=time[match.DIndex];
         //--- Delete pattern from chart
         string unique=_indicator.Is4PointPattern(k)?UniqueIdentifier(ADateTime,BDateTime,CDateTime,DDateTime) : UniqueIdentifier(XDateTime,ADateTime,BDateTime,CDateTime,DDateTime);
         string prefix=(bullish ? "U "+_identifier : "D "+_identifier);
         string linePRZ=prefix+StringFormat("%x",_timeOfInit)+IntegerToString(k)+" PRZ"+unique;
         ObjectDelete(0,linePRZ);
        }
     }
  }
//+------------------------------------------------------------------+
//| Helper method populates pattern arrays                           |
//+------------------------------------------------------------------+
int PopulatePatterns()
  {
//--- Create pattern descriptor structs with relevant ratios
   PATTERN_DESCRIPTOR trendlike1_abcd=          {0,0,0.382,0.382,2.618,2.618,0,0,0,0,0,0,1,1};
   PATTERN_DESCRIPTOR trendlike2_abcd=          {0,0,0.5,0.5,2.0,2.0,0,0,0,0,0,0,1,1};
   PATTERN_DESCRIPTOR perfect_abcd=             {0,0,0.618,0.618,1.618,1.618,0,0,0,0,0,0,1,1};
   PATTERN_DESCRIPTOR ideal1_abcd=              {0,0,0.707,0.707,1.41,1.41,0,0,0,0,0,0,1,1};
   PATTERN_DESCRIPTOR ideal2_abcd=              {0,0,0.786,0.786,1.27,1.27,0,0,0,0,0,0,1,1};
   PATTERN_DESCRIPTOR rangelike_abcd=           {0,0,0.886,0.886,1.13,1.13,0,0,0,0,0,0,1,1};
   PATTERN_DESCRIPTOR alt127_trendlike1_abcd=   {0,0,0.382,0.382,2.618,3.618,0,0,0,0,0,0,1.272,1.272};
   PATTERN_DESCRIPTOR alt127_trendlike2_abcd=   {0,0,0.5,0.5,2.0,3.618,0,0,0,0,0,0,1.272,1.272};
   PATTERN_DESCRIPTOR alt127_perfect_abcd=      {0,0,0.618,0.618,1.618,3.618,0,0,0,0,0,0,1.272,1.272};
   PATTERN_DESCRIPTOR alt127_ideal1_abcd=       {0,0,0.707,0.707,1.41,3.618,0,0,0,0,0,0,1.272,1.272};
   PATTERN_DESCRIPTOR alt127_ideal2_abcd=       {0,0,0.786,0.786,1.27,3.618,0,0,0,0,0,0,1.272,1.272};
   PATTERN_DESCRIPTOR alt127_rangelike_abcd=    {0,0,0.886,0.886,1.13,3.618,0,0,0,0,0,0,1.272,1.272};
   PATTERN_DESCRIPTOR alt161_trendlike1_abcd=   {0,0,0.382,0.382,2.618,3.618,0,0,0,0,0,0,1.618,1.618};
   PATTERN_DESCRIPTOR alt161_trendlike2_abcd=   {0,0,0.5,0.5,2.0,3.618,0,0,0,0,0,0,1.618,1.618};
   PATTERN_DESCRIPTOR alt161_perfect_abcd=      {0,0,0.618,0.618,1.618,3.618,0,0,0,0,0,0,1.618,1.618};
   PATTERN_DESCRIPTOR alt161_ideal1_abcd=       {0,0,0.707,0.707,1.41,3.618,0,0,0,0,0,0,1.618,1.618};
   PATTERN_DESCRIPTOR alt161_ideal2_abcd=       {0,0,0.786,0.786,1.27,3.618,0,0,0,0,0,0,1.618,1.618};
   PATTERN_DESCRIPTOR alt161_rangelike_abcd=    {0,0,0.886,0.886,1.13,3.618,0,0,0,0,0,0,1.618,1.618};
   PATTERN_DESCRIPTOR rec_trendlike1_abcd=      {0,0,2.618,2.618,0.382,0.382,0,0,0,0,0,0,1,1};
   PATTERN_DESCRIPTOR rec_trendlike2_abcd=      {0,0,2.0,2.0,0.5,0.5,0,0,0,0,0,0,1,1};
   PATTERN_DESCRIPTOR rec_perfect_abcd=         {0,0,1.618,1.618,0.618,0.618,0,0,0,0,0,0,1,1};
   PATTERN_DESCRIPTOR rec_ideal1_abcd=          {0,0,1.41,1.41,0.707,0.707,0,0,0,0,0,0,1,1};
   PATTERN_DESCRIPTOR rec_ideal2_abcd=          {0,0,1.27,1.27,0.786,0.786,0,0,0,0,0,0,1,1};
   PATTERN_DESCRIPTOR rec_rangelike_abcd=       {0,0,1.13,1.13,0.886,0.886,0,0,0,0,0,0,1,1};
   PATTERN_DESCRIPTOR alt127_rec_trendlike1_abcd=      {0,0,2.618,2.618,0.382,3.618,0,0,0,0,0,0,1.272,1.272};
   PATTERN_DESCRIPTOR alt127_rec_trendlike2_abcd=      {0,0,2.0,2.0,0.5,3.618,0,0,0,0,0,0,1.272,1.272};
   PATTERN_DESCRIPTOR alt127_rec_perfect_abcd=         {0,0,1.618,1.618,0.618,3.618,0,0,0,0,0,0,1.272,1.272};
   PATTERN_DESCRIPTOR alt127_rec_ideal1_abcd=          {0,0,1.41,1.41,0.707,3.618,0,0,0,0,0,0,1.272,1.272};
   PATTERN_DESCRIPTOR alt127_rec_ideal2_abcd=          {0,0,1.27,1.27,0.786,3.618,0,0,0,0,0,0,1.272,1.272};
   PATTERN_DESCRIPTOR alt127_rec_rangelike_abcd=       {0,0,1.13,1.13,0.886,3.618,0,0,0,0,0,0,1.272,1.272};
   PATTERN_DESCRIPTOR alt161_rec_trendlike1_abcd=      {0,0,2.618,2.618,0.382,3.618,0,0,0,0,0,0,1.618,1.618};
   PATTERN_DESCRIPTOR alt161_rec_trendlike2_abcd=      {0,0,2.0,2.0,0.5,3.618,0,0,0,0,0,0,1.618,1.618};
   PATTERN_DESCRIPTOR alt161_rec_perfect_abcd=         {0,0,1.618,1.618,0.618,3.618,0,0,0,0,0,0,1.618,1.618};
   PATTERN_DESCRIPTOR alt161_rec_ideal1_abcd=          {0,0,1.41,1.41,0.707,3.618,0,0,0,0,0,0,1.618,1.618};
   PATTERN_DESCRIPTOR alt161_rec_ideal2_abcd=          {0,0,1.27,1.27,0.786,3.618,0,0,0,0,0,0,1.618,1.618};
   PATTERN_DESCRIPTOR alt161_rec_rangelike_abcd=       {0,0,1.13,1.13,0.886,3.618,0,0,0,0,0,0,1.618,1.618};
   PATTERN_DESCRIPTOR perfect_gartley={0.618,0.618,0.618,0.618,1.618,1.618,0.786,0.786,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR perfect_bat={0.5,0.5,0.5,0.618,2,2,0.886,0.886,0,0,0,0,0,0 };
   PATTERN_DESCRIPTOR gartley={0.618,0.618,0.382,0.886,1.272,1.618,0.786,0.786,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR gartley113=   {0.618,0.618,0.886,0.886,1.13,1.13,0.786,0.786,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR maxgartley=   {0.382,0.618,0.382,0.886,1.128,2.236,0.618,0.786,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR bat={0.382,0.5,0.382,0.886,1.618,2.618,0.886,0.886,0,0,0,0,0,0 };
   PATTERN_DESCRIPTOR altbat=       {0.382,0.382,0.382,0.886,2.0,3.618,1.13,1.13,0,0,0,0,0,0 };
   PATTERN_DESCRIPTOR maxbat=       {0.382,0.618,0.382,0.886,1.272,2.618,0.886,0.886,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR crab={0.382,0.618,0.382,0.886,2.24,3.618,1.618,1.618,0,0,0,0,0,0 };//2.618
   PATTERN_DESCRIPTOR perfect_crab={0.618,0.618,0.5,0.618,3.14,3.14,1.618,1.618,0,0,0,0,1.618,1.618 };
   PATTERN_DESCRIPTOR deepcrab={0.886,0.886,0.382,0.886,2.0,3.618,1.618,1.618,0,0,0,0,0,0 };//2.24
   PATTERN_DESCRIPTOR butterfly={0.786,0.786,0.382,0.886,1.618,2.618,1.272,1.272,0,0,0,0,0,0 };//1.272 vs 1.618
   PATTERN_DESCRIPTOR perfect_butterfly={0.786,0.786,0.5,0.886,1.618,1.618,1.272,1.272,0,0,0,0,1.272,1.272 };
   PATTERN_DESCRIPTOR maxbutterfly={0.618,0.886,0.382,0.886,1.272,2.618,1.272,1.618,0,0,0,0,0,0};
   PATTERN_DESCRIPTOR butterfly113={0.786,1,0.618,1,1.128,1.618,1.128,1.128,0,0,0,0,0,0 };
   PATTERN_DESCRIPTOR fiveo=        {1.13,1.618,1.618,2.24,0.5,0.5,0,0,0,0,0,0,0,0};
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
   PATTERN_DESCRIPTOR anti_gartley=Invert(gartley);
   PATTERN_DESCRIPTOR anti_bat=Invert(bat);
   PATTERN_DESCRIPTOR anti_altbat=Invert(altbat);
   PATTERN_DESCRIPTOR anti_fiveo=Invert(fiveo);
   PATTERN_DESCRIPTOR anti_butterfly=Invert(butterfly);
   PATTERN_DESCRIPTOR anti_crab=Invert(crab);
   PATTERN_DESCRIPTOR anti_deepcrab=Invert(deepcrab);
   PATTERN_DESCRIPTOR anti_threedrives=Invert(threedrives);
   PATTERN_DESCRIPTOR anti_shark=Invert(shark);
   PATTERN_DESCRIPTOR anti_cypher=Invert(cypher);
   PATTERN_DESCRIPTOR anti_nenstar=Invert(nenstar);
   PATTERN_DESCRIPTOR anti_blackswan=     Invert(blackswan);
   PATTERN_DESCRIPTOR anti_whiteswan=     Invert(whiteswan);
   PATTERN_DESCRIPTOR anti_one2one=Invert(one2one);
   PATTERN_DESCRIPTOR anti_newcypher=Invert(newcypher);
   PATTERN_DESCRIPTOR anti_navarro200=Invert(navarro200);
   PATTERN_DESCRIPTOR anti_leonardo=Invert(leonardo);
   PATTERN_DESCRIPTOR anti_kane=Invert(kane);
   PATTERN_DESCRIPTOR anti_garfly=        Invert(garfly);
   PATTERN_DESCRIPTOR anti_maxbat=        Invert(maxbat);
   PATTERN_DESCRIPTOR anti_maxgartley=Invert(maxgartley);
   PATTERN_DESCRIPTOR anti_maxbutterfly=Invert(maxbutterfly);
   PATTERN_DESCRIPTOR anti_gartley113=Invert(gartley113);
   PATTERN_DESCRIPTOR anti_butterfly113=Invert(butterfly113);

//--- Initialize arrays
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
//--- Fill in the pattern arrays
   fillPatternArrays(TRENDLIKE1_ABCD,trendlike1_abcd,"Trendlike AB=CD #1");
   fillPatternArrays(TRENDLIKE2_ABCD,trendlike2_abcd,"Trendlike AB=CD #2");
   fillPatternArrays(PERFECT_ABCD,perfect_abcd,"Perfect AB=CD");
   fillPatternArrays(IDEAL1_ABCD,ideal1_abcd,"Ideal AB=CD #1");
   fillPatternArrays(IDEAL2_ABCD,ideal2_abcd,"Ideal AB=CD #2");
   fillPatternArrays(RANGELIKE_ABCD,rangelike_abcd,"Rangelike AB=CD");
   fillPatternArrays(ALT127_TRENDLIKE1_ABCD,alt127_trendlike1_abcd,"Trendlike 1.27 AB=CD #1");
   fillPatternArrays(ALT127_TRENDLIKE2_ABCD,alt127_trendlike2_abcd,"Trendlike 1.27 AB=CD #2");
   fillPatternArrays(ALT127_PERFECT_ABCD,alt127_perfect_abcd,"Perfect 1.27 AB=CD");
   fillPatternArrays(ALT127_IDEAL1_ABCD,alt127_ideal1_abcd,"Ideal 1.27 AB=CD #1");
   fillPatternArrays(ALT127_IDEAL2_ABCD,alt127_ideal2_abcd,"Ideal 1.27 AB=CD #2");
   fillPatternArrays(ALT127_RANGELIKE_ABCD,alt127_rangelike_abcd,"Rangelike 1.27 AB=CD");
   fillPatternArrays(ALT161_TRENDLIKE1_ABCD,alt161_trendlike1_abcd,"Trendlike 1.61 AB=CD #1");
   fillPatternArrays(ALT161_TRENDLIKE2_ABCD,alt161_trendlike2_abcd,"Trendlike 1.61 AB=CD #2");
   fillPatternArrays(ALT161_PERFECT_ABCD,alt161_perfect_abcd,"Perfect 1.61 AB=CD");
   fillPatternArrays(ALT161_IDEAL1_ABCD,alt161_ideal1_abcd,"Ideal 1.61 AB=CD #1");
   fillPatternArrays(ALT161_IDEAL2_ABCD,alt161_ideal2_abcd,"Ideal 1.61 AB=CD #2");
   fillPatternArrays(ALT161_RANGELIKE_ABCD,alt161_rangelike_abcd,"Rangelike 1.61 AB=CD");
   fillPatternArrays(REC_TRENDLIKE1_ABCD,rec_trendlike1_abcd,"Rec. Trendlike AB=CD #1");
   fillPatternArrays(REC_TRENDLIKE2_ABCD,rec_trendlike2_abcd,"Rec. Trendlike AB=CD #2");
   fillPatternArrays(REC_PERFECT_ABCD,rec_perfect_abcd,"Rec. Perfect AB=CD");
   fillPatternArrays(REC_IDEAL1_ABCD,rec_ideal1_abcd,"Rec. Ideal AB=CD #1");
   fillPatternArrays(REC_IDEAL2_ABCD,rec_ideal2_abcd,"Rec. Ideal AB=CD #2");
   fillPatternArrays(REC_RANGELIKE_ABCD,rec_rangelike_abcd,"Rec. Rangelike AB=CD");
   fillPatternArrays(ALT127_REC_TRENDLIKE1_ABCD,alt127_rec_trendlike1_abcd,"Rec. Trendlike 1.27 AB=CD #1");
   fillPatternArrays(ALT127_REC_TRENDLIKE2_ABCD,alt127_rec_trendlike2_abcd,"Rec. Trendlike 1.27 AB=CD #2");
   fillPatternArrays(ALT127_REC_PERFECT_ABCD,alt127_rec_perfect_abcd,"Rec. Perfect 1.27 AB=CD");
   fillPatternArrays(ALT127_REC_IDEAL1_ABCD,alt127_rec_ideal1_abcd,"Rec. Ideal 1.27 AB=CD #1");
   fillPatternArrays(ALT127_REC_IDEAL2_ABCD,alt127_rec_ideal2_abcd,"Rec. Ideal 1.27 AB=CD #2");
   fillPatternArrays(ALT127_REC_RANGELIKE_ABCD,alt127_rec_rangelike_abcd,"Rec. Rangelike 1.27 AB=CD");
   fillPatternArrays(ALT161_REC_TRENDLIKE1_ABCD,alt161_rec_trendlike1_abcd,"Rec. Trendlike 1.61 AB=CD #1");
   fillPatternArrays(ALT161_REC_TRENDLIKE2_ABCD,alt161_rec_trendlike2_abcd,"Rec. Trendlike 1.61 AB=CD #2");
   fillPatternArrays(ALT161_REC_PERFECT_ABCD,alt161_rec_perfect_abcd,"Rec. Perfect 1.61 AB=CD");
   fillPatternArrays(ALT161_REC_IDEAL1_ABCD,alt161_rec_ideal1_abcd,"Rec. Ideal 1.61 AB=CD #1");
   fillPatternArrays(ALT161_REC_IDEAL2_ABCD,alt161_rec_ideal2_abcd,"Rec. Ideal 1.61 AB=CD #2");
   fillPatternArrays(ALT161_REC_RANGELIKE_ABCD,alt161_rec_rangelike_abcd,"Rec. Rangelike 1.61 AB=CD");
   fillPatternArrays(GARTLEY,gartley,"Gartley");
   fillPatternArrays(PERFECT_GARTLEY,perfect_gartley,"Perfect Gartley");
   fillPatternArrays(GARTLEY113,gartley113,"Gartley 113");
   fillPatternArrays(MAXGARTLEY,maxgartley,"Max. Gartley");
   fillPatternArrays(BAT,bat,"Bat");
   fillPatternArrays(PERFECT_BAT,perfect_bat,"Perfect Bat");
   fillPatternArrays(ALTBAT,altbat,"Alt. Bat");
   fillPatternArrays(MAXBAT,maxbat,"Max. Bat");
   fillPatternArrays(CRAB,crab,"Crab");
   fillPatternArrays(PERFECT_CRAB,perfect_crab,"Perfect Crab");
   fillPatternArrays(DEEPCRAB,deepcrab,"Deep Crab");
   fillPatternArrays(BUTTERFLY,butterfly,"Butterfly");
   fillPatternArrays(PERFECT_BUTTERFLY,perfect_butterfly,"Perfect Butterfly");
   fillPatternArrays(MAXBUTTERFLY,maxbutterfly,"Max. Butterfly");
   fillPatternArrays(BUTTERFLY113,butterfly113,"Butterfly 113");
   fillPatternArrays(FIVEO,fiveo,"5-0");
   fillPatternArrays(THREEDRIVES,threedrives,"Three Drives");
   fillPatternArrays(CYPHER,cypher,"Cypher");
   fillPatternArrays(SHARK,shark,"Shark");
   fillPatternArrays(NENSTAR,nenstar,"Nen Star");
   fillPatternArrays(BLACKSWAN,blackswan,"Black Swan");
   fillPatternArrays(WHITESWAN,whiteswan,"White Swan");
   fillPatternArrays(ONE2ONE,one2one,"One2One");
   fillPatternArrays(NEWCYPHER,newcypher,"New Cypher");
   fillPatternArrays(NAVARRO200,navarro200,"Navarro 200");
   fillPatternArrays(LEONARDO,leonardo,"Leonardo");
   fillPatternArrays(KANE,kane,"Kane");
   fillPatternArrays(GARFLY,garfly,"Garfly");
   fillPatternArrays(ANTI_GARTLEY,anti_gartley,"Anti Gartley");
   fillPatternArrays(ANTI_BAT,anti_bat,"Anti Bat");
   fillPatternArrays(ANTI_ALTBAT,anti_altbat,"Anti Alt. Bat");
   fillPatternArrays(ANTI_FIVEO,anti_fiveo,"Anti 5-0");
   fillPatternArrays(ANTI_BUTTERFLY,anti_butterfly,"Anti Butterfly");
   fillPatternArrays(ANTI_CRAB,anti_crab,"Anti Crab");
   fillPatternArrays(ANTI_DEEPCRAB,anti_deepcrab,"Anti Deep Crab");
   fillPatternArrays(ANTI_THREEDRIVES,anti_threedrives,"Anti Three Drives");
   fillPatternArrays(ANTI_CYPHER,anti_cypher,"Anti Cypher");
   fillPatternArrays(ANTI_SHARK,anti_shark,"Anti Shark");
   fillPatternArrays(ANTI_NENSTAR,anti_nenstar,"Anti Nen Star");
   fillPatternArrays(ANTI_BLACKSWAN,anti_blackswan,"Anti Black Swan");
   fillPatternArrays(ANTI_WHITESWAN,anti_whiteswan,"Anti White Swan");
   fillPatternArrays(ANTI_ONE2ONE,anti_one2one,"Anti One2One");
   fillPatternArrays(ANTI_NEWCYPHER,anti_newcypher,"Anti New Cypher");
   fillPatternArrays(ANTI_NAVARRO200,anti_navarro200,"Anti Navarro 200");
   fillPatternArrays(ANTI_LEONARDO,anti_leonardo,"Anti Leonardo");
   fillPatternArrays(ANTI_KANE,anti_kane,"Anti Kane");
   fillPatternArrays(ANTI_GARFLY,anti_garfly,"Anti Garfly");
   fillPatternArrays(ANTI_MAXBAT,anti_maxbat,"Anti Max. Bat");
   fillPatternArrays(ANTI_MAXGARTLEY,anti_maxgartley,"Anti Max. Gartley");
   fillPatternArrays(ANTI_MAXBUTTERFLY,anti_maxbutterfly,"Anti Max. Butterfly");
   fillPatternArrays(ANTI_GARTLEY113,anti_gartley113,"Anti Gartley 113");
   fillPatternArrays(ANTI_BUTTERFLY113,anti_butterfly113,"Anti Butterfly 113");
   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
//| Helper method does the actual filling of array entries           |
//+------------------------------------------------------------------+
void fillPatternArrays(int index,PATTERN_DESCRIPTOR &descriptor,string name)
  {
   _patterns[index]=descriptor;
   _patternNames[index]=name;
  }
//+------------------------------------------------------------------+
//| Helper method checks if pattern should be displayed              |
//+------------------------------------------------------------------+
bool ShouldDisplay(int patternIndex)
  {
   if(patternIndex==TRENDLIKE1_ABCD && (!i_show_trendlike1_abcd || !i_show_abcd)) return false;
   if(patternIndex==TRENDLIKE2_ABCD && (!i_show_trendlike2_abcd || !i_show_abcd)) return false;
   if(patternIndex==PERFECT_ABCD && (!i_show_perfect_abcd || !i_show_abcd)) return false;
   if(patternIndex==IDEAL1_ABCD && (!i_show_ideal1_abcd || !i_show_abcd)) return false;
   if(patternIndex==IDEAL2_ABCD && (!i_show_ideal2_abcd || !i_show_abcd)) return false;
   if(patternIndex==RANGELIKE_ABCD && (!i_show_rangelike_abcd || !i_show_abcd)) return false;
   if(patternIndex==ALT127_TRENDLIKE1_ABCD && (!i_show_alt127_trendlike1_abcd || !i_show_alt127_abcd)) return false;
   if(patternIndex==ALT127_TRENDLIKE2_ABCD && (!i_show_alt127_trendlike2_abcd || !i_show_alt127_abcd)) return false;
   if(patternIndex==ALT127_PERFECT_ABCD && (!i_show_alt127_perfect_abcd || !i_show_alt127_abcd)) return false;
   if(patternIndex==ALT127_IDEAL1_ABCD && (!i_show_alt127_ideal1_abcd || !i_show_alt127_abcd)) return false;
   if(patternIndex==ALT127_IDEAL2_ABCD && (!i_show_alt127_ideal2_abcd || !i_show_alt127_abcd)) return false;
   if(patternIndex==ALT127_RANGELIKE_ABCD && (!i_show_alt127_rangelike_abcd || !i_show_alt127_abcd)) return false;
   if(patternIndex==ALT161_TRENDLIKE1_ABCD && (!i_show_alt161_trendlike1_abcd || !i_show_alt161_abcd)) return false;
   if(patternIndex==ALT161_TRENDLIKE2_ABCD && (!i_show_alt161_trendlike2_abcd || !i_show_alt161_abcd)) return false;
   if(patternIndex==ALT161_PERFECT_ABCD && (!i_show_alt161_perfect_abcd || !i_show_alt161_abcd)) return false;
   if(patternIndex==ALT161_IDEAL1_ABCD && (!i_show_alt161_ideal1_abcd || !i_show_alt161_abcd)) return false;
   if(patternIndex==ALT161_IDEAL2_ABCD && (!i_show_alt161_ideal2_abcd || !i_show_alt161_abcd)) return false;
   if(patternIndex==ALT161_RANGELIKE_ABCD && (!i_show_alt161_rangelike_abcd || !i_show_alt161_abcd)) return false;
   if(patternIndex==REC_TRENDLIKE1_ABCD && (!i_show_rec_trendlike1_abcd || !i_show_rec_abcd)) return false;
   if(patternIndex==REC_TRENDLIKE2_ABCD && (!i_show_rec_trendlike2_abcd || !i_show_rec_abcd)) return false;
   if(patternIndex==REC_PERFECT_ABCD && (!i_show_rec_perfect_abcd || !i_show_rec_abcd)) return false;
   if(patternIndex==REC_IDEAL1_ABCD && (!i_show_rec_ideal1_abcd || !i_show_rec_abcd)) return false;
   if(patternIndex==REC_IDEAL2_ABCD && (!i_show_rec_ideal2_abcd || !i_show_rec_abcd)) return false;
   if(patternIndex==REC_RANGELIKE_ABCD && (!i_show_rec_rangelike_abcd || !i_show_rec_abcd)) return false;
   if(patternIndex==ALT127_REC_TRENDLIKE1_ABCD && (!i_show_alt127_rec_trendlike1_abcd || !i_show_alt127_rec_abcd)) return false;
   if(patternIndex==ALT127_REC_TRENDLIKE2_ABCD && (!i_show_alt127_rec_trendlike2_abcd || !i_show_alt127_rec_abcd)) return false;
   if(patternIndex==ALT127_REC_PERFECT_ABCD && (!i_show_alt127_rec_perfect_abcd || !i_show_alt127_rec_abcd)) return false;
   if(patternIndex==ALT127_REC_IDEAL1_ABCD && (!i_show_alt127_rec_ideal1_abcd || !i_show_alt127_rec_abcd)) return false;
   if(patternIndex==ALT127_REC_IDEAL2_ABCD && (!i_show_alt127_rec_ideal2_abcd || !i_show_alt127_rec_abcd)) return false;
   if(patternIndex==ALT127_REC_RANGELIKE_ABCD && (!i_show_alt127_rec_rangelike_abcd || !i_show_alt127_rec_abcd)) return false;
   if(patternIndex==ALT161_REC_TRENDLIKE1_ABCD && (!i_show_alt161_rec_trendlike1_abcd || !i_show_alt161_rec_abcd)) return false;
   if(patternIndex==ALT161_REC_TRENDLIKE2_ABCD && (!i_show_alt161_rec_trendlike2_abcd || !i_show_alt161_rec_abcd)) return false;
   if(patternIndex==ALT161_REC_PERFECT_ABCD && (!i_show_alt161_rec_perfect_abcd || !i_show_alt161_rec_abcd)) return false;
   if(patternIndex==ALT161_REC_IDEAL1_ABCD && (!i_show_alt161_rec_ideal1_abcd || !i_show_alt161_rec_abcd)) return false;
   if(patternIndex==ALT161_REC_IDEAL2_ABCD && (!i_show_alt161_rec_ideal2_abcd || !i_show_alt161_rec_abcd)) return false;
   if(patternIndex==ALT161_REC_RANGELIKE_ABCD && (!i_show_alt161_rec_rangelike_abcd || !i_show_alt161_rec_abcd)) return false;
   if(patternIndex==GARTLEY && (!i_show_gartley || !i_show_patterns)) return false;
   if(patternIndex==PERFECT_GARTLEY && (!i_show_perfect_gartley || !i_show_patterns)) return false;
   if(patternIndex==GARTLEY113 && (!i_show_gartley113 || !i_show_patterns)) return false;
   if(patternIndex==MAXGARTLEY && (!i_show_maxgartley || !i_show_patterns)) return false;
   if(patternIndex==BAT && (!i_show_bat || !i_show_patterns)) return false;
   if(patternIndex==ALTBAT && (!i_show_altbat || !i_show_patterns)) return false;
   if(patternIndex==PERFECT_BAT && (!i_show_perfect_bat || !i_show_patterns)) return false;
   if(patternIndex==MAXBAT && (!i_show_maxbat || !i_show_patterns)) return false;
   if(patternIndex==CRAB && (!i_show_crab || !i_show_patterns)) return false;
   if(patternIndex==PERFECT_CRAB && (!i_show_perfect_crab || !i_show_patterns)) return false;
   if(patternIndex==DEEPCRAB && (!i_show_deepcrab || !i_show_patterns)) return false;
   if(patternIndex==BUTTERFLY && (!i_show_butterfly || !i_show_patterns)) return false;
   if(patternIndex==PERFECT_BUTTERFLY && (!i_show_perfect_butterfly || !i_show_patterns)) return false;
   if(patternIndex==MAXBUTTERFLY && (!i_show_maxbutterfly || !i_show_patterns)) return false;
   if(patternIndex==BUTTERFLY113 && (!i_show_butterfly113 || !i_show_patterns)) return false;
   if(patternIndex==FIVEO && (!i_show_fiveo || !i_show_patterns)) return false;
   if(patternIndex==THREEDRIVES && (!i_show_threedrives || !i_show_patterns)) return false;
   if(patternIndex==CYPHER && (!i_show_cypher || !i_show_patterns)) return false;
   if(patternIndex==SHARK && (!i_show_shark || !i_show_patterns)) return false;
   if(patternIndex==NENSTAR && (!i_show_nenstar || !i_show_patterns)) return false;
   if(patternIndex==BLACKSWAN && (!i_show_blackswan || !i_show_patterns)) return false;
   if(patternIndex==WHITESWAN && (!i_show_whiteswan || !i_show_patterns)) return false;
   if(patternIndex==ONE2ONE && (!i_show_one2one || !i_show_patterns)) return false;
   if(patternIndex==NEWCYPHER && (!i_show_newCypher || !i_show_patterns)) return false;
   if(patternIndex==NAVARRO200 && (!i_show_navarro200 || !i_show_patterns)) return false;
   if(patternIndex==LEONARDO && (!i_show_leonardo || !i_show_patterns)) return false;
   if(patternIndex==KANE && (!i_show_kane || !i_show_patterns)) return false;
   if(patternIndex==GARFLY && (!i_show_garfly || !i_show_patterns)) return false;
   if(patternIndex==ANTI_GARTLEY && (!i_show_antigartley || !i_show_antipatterns)) return false;
   if(patternIndex==ANTI_BAT && (!i_show_antibat || !i_show_antipatterns)) return false;
   if(patternIndex==ANTI_ALTBAT && (!i_show_antialtbat || !i_show_antipatterns)) return false;
   if(patternIndex==ANTI_FIVEO && (!i_show_antifiveo || !i_show_antipatterns)) return false;
   if(patternIndex==ANTI_BUTTERFLY && (!i_show_antibutterfly || !i_show_antipatterns)) return false;
   if(patternIndex==ANTI_CRAB && (!i_show_anticrab || !i_show_antipatterns)) return false;
   if(patternIndex==ANTI_DEEPCRAB && (!i_show_antideepcrab || !i_show_antipatterns)) return false;
   if(patternIndex==ANTI_THREEDRIVES && (!i_show_antithreedrives || !i_show_antipatterns)) return false;
   if(patternIndex==ANTI_CYPHER && (!i_show_anticypher || !i_show_antipatterns)) return false;
   if(patternIndex==ANTI_SHARK && (!i_show_antishark || !i_show_antipatterns)) return false;
   if(patternIndex==ANTI_NENSTAR && (!i_show_antinenstar || !i_show_antipatterns)) return false;
   if(patternIndex==ANTI_BLACKSWAN && (!i_show_antiblackswan || !i_show_antipatterns)) return false;
   if(patternIndex==ANTI_WHITESWAN && (!i_show_antiwhiteswan || !i_show_antipatterns)) return false;
   if(patternIndex==ANTI_ONE2ONE && (!i_show_antione2one || !i_show_antipatterns)) return false;
   if(patternIndex==ANTI_NEWCYPHER && (!i_show_antinewCypher || !i_show_antipatterns)) return false;
   if(patternIndex==ANTI_NAVARRO200 && (!i_show_antinavarro200 || !i_show_antipatterns)) return false;
   if(patternIndex==ANTI_LEONARDO && (!i_show_antileonardo || !i_show_antipatterns)) return false;
   if(patternIndex==ANTI_KANE && (!i_show_antikane || !i_show_antipatterns)) return false;
   if(patternIndex==ANTI_GARFLY && (!i_show_antigarfly || !i_show_antipatterns)) return false;
   if(patternIndex==ANTI_MAXBAT && (!i_show_antimaxbat || !i_show_antipatterns)) return false;
   if(patternIndex==ANTI_MAXGARTLEY && (!i_show_antimaxgartley || !i_show_antipatterns)) return false;
   if(patternIndex==ANTI_MAXBUTTERFLY && (!i_show_antimaxbutterfly || !i_show_antipatterns)) return false;
   if(patternIndex==ANTI_GARTLEY113 && (!i_show_antigartley113 || !i_show_antipatterns)) return false;
   if(patternIndex==ANTI_BUTTERFLY113 && (!i_show_antibutterfly113 || !i_show_antipatterns)) return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Helper method inverts pattern descriptors (anti-pattern)         |
//+------------------------------------------------------------------+
PATTERN_DESCRIPTOR Invert(PATTERN_DESCRIPTOR &original)
  {
   PATTERN_DESCRIPTOR ret={0,0,0,0,0,0,0,0,0,0,0,0,0,0};
   if(original.ab2xa_max!=0) ret.cd2bc_min=1.0/original.ab2xa_max;
   if(original.ab2xa_min!=0) ret.cd2bc_max=1.0/original.ab2xa_min;
   if(original.bc2ab_max!=0) ret.bc2ab_min=1.0/original.bc2ab_max;
   if(original.bc2ab_min!=0) ret.bc2ab_max=1.0/original.bc2ab_min;
   if(original.cd2bc_max!=0) ret.ab2xa_min=1.0/original.cd2bc_max;
   if(original.cd2bc_min!=0) ret.ab2xa_max=1.0/original.cd2bc_min;
   if(original.ad2xa_max!=0) ret.cd2xc_min=1.0/original.ad2xa_max;
   if(original.ad2xa_min!=0) ret.cd2xc_max=1.0/original.ad2xa_min;
   if(original.cd2xc_max!=0) ret.ad2xa_min=1.0/original.cd2xc_max;
   if(original.cd2xc_min!=0) ret.ad2xa_max=1.0/original.cd2xc_min;
   if(original.xc2xa_max!=0) ret.cd2ad_min=1.0/original.xc2xa_max;
   if(original.xc2xa_min!=0) ret.cd2ad_max=1.0/original.xc2xa_min;
   if(original.cd2ab_max!=0) ret.bc2xa_min=1.0/original.cd2ab_max;
   if(original.cd2ab_min!=0) ret.bc2xa_max=1.0/original.cd2ab_min;
   return ret;
  }
//+------------------------------------------------------------------+

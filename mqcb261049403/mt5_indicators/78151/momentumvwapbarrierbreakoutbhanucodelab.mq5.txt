//+------------------------------------------------------------------+
//|               MomentumVwapBarrierBreakoutBhanuCodeLab.mq5        |
//|                       Copyright BhanuCodeLab                     |
//+------------------------------------------------------------------+
#property copyright "BhanuCodeLab"
#property version   "1.00"
#property description "Detects breaks through tested price barriers and supports optional VWAP, SMA, or SMMA direction filters"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3

#property indicator_label1  "Bullish Barrier Break"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrBlue
#property indicator_width1  1

#property indicator_label2  "Bearish Barrier Break"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_width2  1

#property indicator_label3  "Selected Filter"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDodgerBlue
#property indicator_width3  2

enum ENUM_MBB_FILTER_MODE
  {
   MBB_FILTER_NONE = 0, // None
   MBB_FILTER_VWAP,     // VWAP
   MBB_FILTER_SMA,      // SMA
   MBB_FILTER_SMMA      // SMMA
  };

enum ENUM_MBB_BOUNDARY_STYLE
  {
   MBB_BOUNDARY_SOLID = 0,
   MBB_BOUNDARY_DASHED,
   MBB_BOUNDARY_DOTTED
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input int                     SwingStrength        = 5;       // Swing confirmation bars (minimum 2)
input int                     BarrierMemoryBars    = 200;     // Barrier memory (30-300 bars)
input double                  ZoneTolerancePercent = 3.0;     // Zone tolerance % (1-10)
input int                     RequiredTouches      = 2;       // Required barrier touches
input color                   BullishSignalColor   = clrBlue; // Bullish barrier color
input color                   BearishSignalColor   = clrRed;  // Bearish barrier color
input ENUM_MBB_BOUNDARY_STYLE BoundaryAppearance   = MBB_BOUNDARY_SOLID; // Boundary style
input bool                    DisplaySignalPanel    = true;    // Display signal panel
input int                     HistoryBarsToScan     = 3000;    // Maximum bars rebuilt for signals

input ENUM_MBB_FILTER_MODE FilterMode = MBB_FILTER_VWAP; // Confirmation filter
input int FilterPeriod = 20; // SMA / SMMA period

double FilterBuffer[];
double BullishMarkerBuffer[];
double BearishMarkerBuffer[];

const string DRAWING_TAG       = "MVBB_V3_ZONE_";
const string SIGNAL_PANEL_ID   = "MVBB_V3_SIGNAL_PANEL";
const int    DRAWING_LINE_CAP  = 400;

datetime LastRebuiltBarTime=0;
int      LastKnownBarCount=0;

struct BarrierBreakSignal
  {
   bool              bullish;
   datetime          triggerTime;
   datetime          originTime;
   double            primaryBoundary;
   double            secondaryBoundary;
   double            symbolPrice;
  };


//+------------------------------------------------------------------+
int OnInit()
  {
   if(SwingStrength < 2 || BarrierMemoryBars < 30 ||
      BarrierMemoryBars > 300 || ZoneTolerancePercent < 1.0 ||
      ZoneTolerancePercent > 10.0 || RequiredTouches < 1 ||
      HistoryBarsToScan < 500 || FilterPeriod < 1)
     {
      Print("Momentum Barrier Breakout: invalid input value(s).");
      return(INIT_PARAMETERS_INCORRECT);
     }

   SetIndexBuffer(0,BullishMarkerBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,BearishMarkerBuffer,INDICATOR_DATA);
   ArraySetAsSeries(BullishMarkerBuffer,true);
   ArraySetAsSeries(BearishMarkerBuffer,true);

   SetIndexBuffer(2,FilterBuffer,INDICATOR_DATA);
   ArraySetAsSeries(FilterBuffer,true);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,FilterPeriod-1);

   PlotIndexSetInteger(0,PLOT_ARROW,241); // Up triangle
   PlotIndexSetInteger(1,PLOT_ARROW,242); // Down triangle
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,BullishSignalColor);
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,BearishSignalColor);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);

   IndicatorSetString(INDICATOR_SHORTNAME,"Momentum Barrier Breakout MT5 V3");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,DRAWING_TAG);
   ObjectDelete(0,SIGNAL_PANEL_ID);
  }

//+------------------------------------------------------------------+
ENUM_LINE_STYLE ResolveBoundaryStyle()
  {
   if(BoundaryAppearance == MBB_BOUNDARY_DASHED)
      return(STYLE_DASH);
   if(BoundaryAppearance == MBB_BOUNDARY_DOTTED)
      return(STYLE_DOT);
   return(STYLE_SOLID);
  }

//+------------------------------------------------------------------+
void RegisterNewestLevel(double &levels[],int &barPositions[],const double price,const int barPosition)
  {
   int size=ArraySize(levels);
   ArrayResize(levels,size+1);
   ArrayResize(barPositions,size+1);
   for(int i=size;i>0;i--)
     {
      levels[i]=levels[i-1];
      barPositions[i]=barPositions[i-1];
     }
   levels[0]=price;
   barPositions[0]=barPosition;
  }

//+------------------------------------------------------------------+
void DiscardAgedLevels(double &levels[],int &barPositions[],const int activeBar)
  {
   int size=ArraySize(levels);
   while(size>1 && activeBar-barPositions[size-1]>BarrierMemoryBars)
     {
      size--;
      ArrayResize(levels,size);
      ArrayResize(barPositions,size);
     }
  }

//+------------------------------------------------------------------+
bool HasConfirmedSwingPeak(const double &high[],const int barCount,const int chronologicalBar)
  {
   int center=chronologicalBar-SwingStrength;
   if(center-SwingStrength<0 || center+SwingStrength>=barCount)
      return(false);
   double candidate=high[barCount-1-center];
   for(int p=center-SwingStrength;p<center;p++)
      if(high[barCount-1-p]>candidate)
         return(false);
   for(int p=center+1;p<=center+SwingStrength;p++)
      if(high[barCount-1-p]>=candidate)
         return(false);
   return(true);
  }

//+------------------------------------------------------------------+
bool HasConfirmedSwingTrough(const double &low[],const int barCount,const int chronologicalBar)
  {
   int center=chronologicalBar-SwingStrength;
   if(center-SwingStrength<0 || center+SwingStrength>=barCount)
      return(false);
   double candidate=low[barCount-1-center];

   for(int p=center-SwingStrength;p<center;p++)
      if(low[barCount-1-p]<candidate)
         return(false);
   for(int p=center+1;p<=center+SwingStrength;p++)
      if(low[barCount-1-p]<=candidate)
         return(false);
   return(true);
  }

//+------------------------------------------------------------------+
double ReadWindowCeiling(const double &high[],const int barCount,
                         const int finalBar,const int windowSize)
  {
   double result=-DBL_MAX;
   int first=MathMax(0,finalBar-windowSize+1);
   for(int p=first;p<=finalBar;p++)
      result=MathMax(result,high[barCount-1-p]);
   return(result);
  }

//+------------------------------------------------------------------+
double ReadWindowFloor(const double &low[],const int barCount,
                       const int finalBar,const int windowSize)
  {
   double result=DBL_MAX;
   int first=MathMax(0,finalBar-windowSize+1);
   for(int p=first;p<=finalBar;p++)
      result=MathMin(result,low[barCount-1-p]);
   return(result);
  }

//+------------------------------------------------------------------+
void StoreBarrierSignal(BarrierBreakSignal &signals[],const bool bullish,
                        const datetime triggerTime,const datetime originTime,
                        const double primaryBoundary,const double secondaryBoundary,
                        const double symbolPrice)
  {
   int size=ArraySize(signals);
   ArrayResize(signals,size+1);
   signals[size].bullish=bullish;
   signals[size].triggerTime=triggerTime;
   signals[size].originTime=originTime;
   signals[size].primaryBoundary=primaryBoundary;
   signals[size].secondaryBoundary=secondaryBoundary;
   signals[size].symbolPrice=symbolPrice;
  }

//+------------------------------------------------------------------+
void PaintDirectionSymbol(const string objectName,const BarrierBreakSignal &signal,
                          const color symbolColor)
  {
   if(!ObjectCreate(0,objectName,OBJ_ARROW,0,signal.triggerTime,signal.symbolPrice))
      return;

   ObjectSetInteger(0,objectName,OBJPROP_ARROWCODE,signal.bullish ? 241 : 242);
   ObjectSetInteger(0,objectName,OBJPROP_COLOR,symbolColor);
   ObjectSetInteger(0,objectName,OBJPROP_WIDTH,2);
   ObjectSetInteger(0,objectName,OBJPROP_ANCHOR,
                    signal.bullish ? ANCHOR_TOP : ANCHOR_BOTTOM);
   ObjectSetInteger(0,objectName,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,objectName,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,objectName,OBJPROP_BACK,false);
  }

//+------------------------------------------------------------------+
void PaintBoundary(const string objectName,const datetime firstTime,const double firstPrice,
                   const datetime secondTime,const double secondPrice,const color boundaryColor)
  {
   if(!ObjectCreate(0,objectName,OBJ_TREND,0,firstTime,firstPrice,secondTime,secondPrice))
      return;
   ObjectSetInteger(0,objectName,OBJPROP_COLOR,boundaryColor);
   ObjectSetInteger(0,objectName,OBJPROP_STYLE,ResolveBoundaryStyle());
   ObjectSetInteger(0,objectName,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,objectName,OBJPROP_RAY_LEFT,false);
   ObjectSetInteger(0,objectName,OBJPROP_RAY_RIGHT,false);
   ObjectSetInteger(0,objectName,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,objectName,OBJPROP_HIDDEN,true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color BlendChartColor(const color foreground,const color background,const double opacity)
  {
   int fr=((int)foreground)&255;
   int fg=(((int)foreground)>>8)&255;
   int fb=(((int)foreground)>>16)&255;
   int br=((int)background)&255;
   int bg=(((int)background)>>8)&255;
   int bb=(((int)background)>>16)&255;
   int rr=(int)MathRound(fr*opacity+br*(1.0-opacity));
   int rg=(int)MathRound(fg*opacity+bg*(1.0-opacity));
   int rb=(int)MathRound(fb*opacity+bb*(1.0-opacity));
   return((color)(rr | (rg<<8) | (rb<<16)));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color MixColors(const color first,const color second,const double amount)
  {
   int ar=((int)first)&255, ag=(((int)first)>>8)&255, ab=(((int)first)>>16)&255;
   int br=((int)second)&255, bg=(((int)second)>>8)&255, bb=(((int)second)>>16)&255;
   int rr=(int)MathRound(ar*(1.0-amount)+br*amount);
   int rg=(int)MathRound(ag*(1.0-amount)+bg*amount);
   int rb=(int)MathRound(ab*(1.0-amount)+bb*amount);
   return((color)(rr | (rg<<8) | (rb<<16)));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PaintGradientZone(const string baseName,const BarrierBreakSignal &signal,
                       const color signalColor)
  {
   const int strips=12;
   const double top=MathMax(signal.primaryBoundary,signal.secondaryBoundary);
   const double bottom=MathMin(signal.primaryBoundary,signal.secondaryBoundary);
   const color background=(color)ChartGetInteger(0,CHART_COLOR_BACKGROUND);
   for(int part=0;part<strips;part++)
     {
      double firstPrice=bottom+(top-bottom)*(double)part/strips;
      double secondPrice=bottom+(top-bottom)*(double)(part+1)/strips;
      double gradient=(double)part/(strips-1);
      if(!signal.bullish)
         gradient=1.0-gradient;
      color graded=MixColors(signalColor,clrWhite,0.30*gradient);
      color visibleColor=BlendChartColor(graded,background,0.40);
      string name=baseName+"FILL_"+IntegerToString(part);
      if(ObjectCreate(0,name,OBJ_RECTANGLE,0,
                      signal.originTime,firstPrice,signal.triggerTime,secondPrice))
        {
         ObjectSetInteger(0,name,OBJPROP_COLOR,visibleColor);
         ObjectSetInteger(0,name,OBJPROP_FILL,true);
         ObjectSetInteger(0,name,OBJPROP_BACK,true);
         ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
         ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FilterApproves(const bool bullish,const int seriesIndex,const double &close[],
                    const double &filter[])
  {
   if(FilterMode==MBB_FILTER_NONE)
      return(true);
   if(seriesIndex<=0 || filter[seriesIndex]==EMPTY_VALUE ||
      !MathIsValidNumber(filter[seriesIndex]))
      return(false);
   return(bullish ? close[seriesIndex]>filter[seriesIndex]
          : close[seriesIndex]<filter[seriesIndex]);
  }

//+------------------------------------------------------------------+
void RefreshBarrierDrawings(BarrierBreakSignal &signals[])
  {
   ObjectsDeleteAll(0,DRAWING_TAG);
   int count=ArraySize(signals);
   int first=MathMax(0,count-DRAWING_LINE_CAP/17);
   int drawingIndex=0;
   for(int i=first;i<count;i++,drawingIndex++)
     {
      string base=DRAWING_TAG+IntegerToString(drawingIndex)+"_";
      color signalColor=signals[i].bullish ? BullishSignalColor : BearishSignalColor;
      PaintBoundary(base+"PRIMARY",signals[i].triggerTime,signals[i].primaryBoundary,
                    signals[i].originTime,signals[i].primaryBoundary,signalColor);
      PaintBoundary(base+"SECONDARY",signals[i].triggerTime,signals[i].secondaryBoundary,
                    signals[i].originTime,signals[i].secondaryBoundary,signalColor);
      PaintBoundary(base+"ORIGIN",signals[i].originTime,signals[i].secondaryBoundary,
                    signals[i].originTime,signals[i].primaryBoundary,signalColor);
      PaintBoundary(base+"TRIGGER",signals[i].triggerTime,signals[i].secondaryBoundary,
                    signals[i].triggerTime,signals[i].primaryBoundary,signalColor);
      PaintGradientZone(base,signals[i],signalColor);
      PaintDirectionSymbol(base+"SYMBOL",signals[i],signalColor);
     }
  }

//+------------------------------------------------------------------+
void RefreshSignalPanel(const string message,const color messageColor)
  {
   if(!DisplaySignalPanel)
     {
      ObjectDelete(0,SIGNAL_PANEL_ID);
      return;
     }

   if(ObjectFind(0,SIGNAL_PANEL_ID)<0)
      ObjectCreate(0,SIGNAL_PANEL_ID,OBJ_EDIT,0,0,0);

   ObjectSetInteger(0,SIGNAL_PANEL_ID,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,SIGNAL_PANEL_ID,OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,SIGNAL_PANEL_ID,OBJPROP_YDISTANCE,20);
   ObjectSetInteger(0,SIGNAL_PANEL_ID,OBJPROP_XSIZE,155);
   ObjectSetInteger(0,SIGNAL_PANEL_ID,OBJPROP_YSIZE,24);
   ObjectSetInteger(0,SIGNAL_PANEL_ID,OBJPROP_ALIGN,ALIGN_CENTER);
   ObjectSetInteger(0,SIGNAL_PANEL_ID,OBJPROP_FONTSIZE,9);
   ObjectSetInteger(0,SIGNAL_PANEL_ID,OBJPROP_COLOR,messageColor);
   ObjectSetInteger(0,SIGNAL_PANEL_ID,OBJPROP_BGCOLOR,clrBlack);
   ObjectSetInteger(0,SIGNAL_PANEL_ID,OBJPROP_BORDER_COLOR,clrDimGray);
   ObjectSetInteger(0,SIGNAL_PANEL_ID,OBJPROP_READONLY,true);
   ObjectSetInteger(0,SIGNAL_PANEL_ID,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,SIGNAL_PANEL_ID,OBJPROP_HIDDEN,true);
   ObjectSetString(0,SIGNAL_PANEL_ID,OBJPROP_FONT,"Arial");
   ObjectSetString(0,SIGNAL_PANEL_ID,OBJPROP_TEXT,message);
  }

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &time[],const double &open[],const double &high[],
                const double &low[],const double &close[],const long &tick_volume[],
                const long &volume[],const int &spread[])
  {

   ArraySetAsSeries(time,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(tick_volume,true);

   int requiredHistory=SwingStrength*2+1;
   if(rates_total<requiredHistory)
      return(0);

   const bool requiresRebuild=
      (prev_calculated<=0 || prev_calculated>rates_total ||
       LastRebuiltBarTime!=time[0] || LastKnownBarCount!=rates_total);


   if(!requiresRebuild)
     {
      if(FilterMode==MBB_FILTER_SMA && rates_total>=FilterPeriod)
        {
         double total=0.0;
         for(int offset=0;offset<FilterPeriod;offset++)
            total+=close[offset];
         FilterBuffer[0]=total/(double)FilterPeriod;
        }
      else
         if(FilterMode==MBB_FILTER_SMMA && rates_total>=FilterPeriod &&
            FilterBuffer[1]!=EMPTY_VALUE)
            FilterBuffer[0]=(FilterBuffer[1]*(FilterPeriod-1)+close[0])/(double)FilterPeriod;
         else
            if(FilterMode==MBB_FILTER_VWAP)
              {
               MqlDateTime liveDay;
               TimeToStruct(time[0],liveDay);
               double priceVolume=0.0,activity=0.0;
               for(int k=0;k<rates_total;k++)
                 {
                  MqlDateTime stamp;
                  TimeToStruct(time[k],stamp);
                  if(stamp.year!=liveDay.year || stamp.day_of_year!=liveDay.day_of_year)
                     break;
                  double volumeValue=(double)tick_volume[k];
                  priceVolume+=((high[k]+low[k]+close[k])/3.0)*volumeValue;
                  activity+=volumeValue;
                 }
               FilterBuffer[0]=(activity>0.0 ? priceVolume/activity : EMPTY_VALUE);
              }
            else
               if(FilterMode==MBB_FILTER_NONE)
                  FilterBuffer[0]=EMPTY_VALUE;
      return(rates_total);
     }

   ArrayInitialize(FilterBuffer,EMPTY_VALUE);
   ArrayInitialize(BullishMarkerBuffer,EMPTY_VALUE);
   ArrayInitialize(BearishMarkerBuffer,EMPTY_VALUE);

   double resistanceLevels[],supportLevels[];
   int resistanceBars[],supportBars[];
   BarrierBreakSignal signals[];
   string panelMessage="";
   color panelColor=clrSilver;
   double toleranceFactor=ZoneTolerancePercent/100.0;

   int requestedBars=MathMax(HistoryBarsToScan,500);
   int barsToProcess=MathMin(rates_total,requestedBars);
   int firstChronologicalBar=rates_total-barsToProcess;
   double vwapPriceVolume=0.0,vwapActivity=0.0;
   int vwapYear=-1,vwapDay=-1;
   double smmaValue=0.0,smmaSeed=0.0;
   int smmaSeedCount=0;


   for(int chronologicalBar=firstChronologicalBar;
       chronologicalBar<rates_total;chronologicalBar++)
     {
      int seriesIndex=rates_total-1-chronologicalBar;

      if(FilterMode==MBB_FILTER_SMA && seriesIndex+FilterPeriod<=rates_total)
        {
         double total=0.0;
         for(int offset=0;offset<FilterPeriod;offset++)
            total+=close[seriesIndex+offset];
         FilterBuffer[seriesIndex]=total/(double)FilterPeriod;
        }
      else
         if(FilterMode==MBB_FILTER_SMMA)
           {
            if(smmaSeedCount<FilterPeriod)
              {
               smmaSeed+=close[seriesIndex];
               smmaSeedCount++;
               if(smmaSeedCount==FilterPeriod)
                 {
                  smmaValue=smmaSeed/(double)FilterPeriod;
                  FilterBuffer[seriesIndex]=smmaValue;
                 }
              }
            else
              {
               smmaValue=(smmaValue*(FilterPeriod-1)+close[seriesIndex])/(double)FilterPeriod;
               FilterBuffer[seriesIndex]=smmaValue;
              }
           }
         else
            if(FilterMode==MBB_FILTER_VWAP)
              {
               MqlDateTime stamp;
               TimeToStruct(time[seriesIndex],stamp);
               if(stamp.year!=vwapYear || stamp.day_of_year!=vwapDay)
                 {
                  vwapPriceVolume=0.0;
                  vwapActivity=0.0;
                  vwapYear=stamp.year;
                  vwapDay=stamp.day_of_year;
                 }
               double volumeValue=(double)tick_volume[seriesIndex];
               vwapPriceVolume+=((high[seriesIndex]+low[seriesIndex]+close[seriesIndex])/3.0)*volumeValue;
               vwapActivity+=volumeValue;
               if(vwapActivity>0.0)
                  FilterBuffer[seriesIndex]=vwapPriceVolume/vwapActivity;
              }


      if(HasConfirmedSwingPeak(high,rates_total,chronologicalBar))
        {
         int swingBar=chronologicalBar-SwingStrength;
         RegisterNewestLevel(resistanceLevels,resistanceBars,
                             high[rates_total-1-swingBar],swingBar);
         DiscardAgedLevels(resistanceLevels,resistanceBars,chronologicalBar);
        }

      if(HasConfirmedSwingTrough(low,rates_total,chronologicalBar))
        {
         int swingBar=chronologicalBar-SwingStrength;
         RegisterNewestLevel(supportLevels,supportBars,
                             low[rates_total-1-swingBar],swingBar);
         DiscardAgedLevels(supportLevels,supportBars,chronologicalBar);
        }

      int volatilityWindow=MathMax(MathMin(chronologicalBar,300),1);
      double visibleCeiling=ReadWindowCeiling(high,rates_total,chronologicalBar,volatilityWindow);
      double visibleFloor=ReadWindowFloor(low,rates_total,chronologicalBar,volatilityWindow);
      double zoneThickness=(visibleCeiling-visibleFloor)*toleranceFactor;

      if(seriesIndex>0 && chronologicalBar>=SwingStrength &&
         ArraySize(resistanceLevels)>=RequiredTouches &&
         FilterApproves(true,seriesIndex,close,FilterBuffer))
        {
         double priorCeiling=ReadWindowCeiling(high,rates_total,
                                               chronologicalBar-1,SwingStrength);
         if(close[seriesIndex]>open[seriesIndex] && close[seriesIndex]>priorCeiling)
           {
            double upperBarrier=resistanceLevels[0];
            int scannedLevel=0;
            for(int levelIndex=0;levelIndex<ArraySize(resistanceLevels);levelIndex++)
              {
               if(resistanceLevels[levelIndex]>=close[seriesIndex])
                  break;
               scannedLevel=levelIndex;
               upperBarrier=MathMax(upperBarrier,resistanceLevels[levelIndex]);
              }

            int qualifyingTouches=0;
            int barrierOrigin=chronologicalBar;
            if(scannedLevel>=RequiredTouches && open[seriesIndex]<=upperBarrier)
              {
               for(int levelIndex=0;levelIndex<=scannedLevel;levelIndex++)
                 {
                  if(resistanceLevels[levelIndex]<=upperBarrier &&
                     resistanceLevels[levelIndex]>=upperBarrier-zoneThickness)
                    {
                     qualifyingTouches++;
                     barrierOrigin=resistanceBars[levelIndex];
                    }
                 }
              }

            if(qualifyingTouches>=RequiredTouches && priorCeiling<upperBarrier &&
               FilterApproves(true,seriesIndex,close,FilterBuffer))
              {
               BullishMarkerBuffer[seriesIndex]=low[seriesIndex]-MathMax(zoneThickness*0.15,3.0*_Point);
               StoreBarrierSignal(signals,true,time[seriesIndex],
                                  time[rates_total-1-barrierOrigin],
                                  upperBarrier,upperBarrier-zoneThickness,
                                  low[seriesIndex]-MathMax(zoneThickness*0.15,6.0*_Point));
               panelMessage="BULLISH BREAK";
               panelColor=BullishSignalColor;
              }
           }
        }

      if(seriesIndex>0 && chronologicalBar>=SwingStrength &&
         ArraySize(supportLevels)>=RequiredTouches &&
         FilterApproves(false,seriesIndex,close,FilterBuffer))
        {
         double priorFloor=ReadWindowFloor(low,rates_total,
                                           chronologicalBar-1,SwingStrength);
         if(close[seriesIndex]<open[seriesIndex] && close[seriesIndex]<priorFloor)
           {
            double lowerBarrier=supportLevels[0];
            int scannedLevel=0;
            for(int levelIndex=0;levelIndex<ArraySize(supportLevels);levelIndex++)
              {
               if(supportLevels[levelIndex]<=close[seriesIndex])
                  break;
               scannedLevel=levelIndex;
               lowerBarrier=MathMin(lowerBarrier,supportLevels[levelIndex]);
              }

            int qualifyingTouches=0;
            int barrierOrigin=chronologicalBar;
            if(scannedLevel>=RequiredTouches && open[seriesIndex]>=lowerBarrier)
              {
               for(int levelIndex=0;levelIndex<=scannedLevel;levelIndex++)
                 {
                  if(supportLevels[levelIndex]>=lowerBarrier &&
                     supportLevels[levelIndex]<=lowerBarrier+zoneThickness)
                    {
                     qualifyingTouches++;
                     barrierOrigin=supportBars[levelIndex];
                    }
                 }
              }

            if(qualifyingTouches>=RequiredTouches && priorFloor>lowerBarrier &&
               FilterApproves(false,seriesIndex,close,FilterBuffer))
              {
               BearishMarkerBuffer[seriesIndex]=high[seriesIndex]+MathMax(zoneThickness*0.15,3.0*_Point);
               StoreBarrierSignal(signals,false,time[seriesIndex],
                                  time[rates_total-1-barrierOrigin],
                                  lowerBarrier,lowerBarrier+zoneThickness,
                                  high[seriesIndex]+MathMax(zoneThickness*0.15,6.0*_Point));
               panelMessage="BEARISH BREAK";
               panelColor=BearishSignalColor;
              }
           }
        }
     }

   RefreshBarrierDrawings(signals);
   RefreshSignalPanel(panelMessage,panelColor);
   LastRebuiltBarTime=time[0];
   LastKnownBarCount=rates_total;
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+

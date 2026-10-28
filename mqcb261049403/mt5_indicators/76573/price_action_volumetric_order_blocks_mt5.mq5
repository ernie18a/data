//+------------------------------------------------------------------+
//| Price Action Volumetric Order Blocks - MT5 Community Edition     |
//|                                                                  |
//| Original Pine Script concept and implementation: UAlgo           |
//| https://www.tradingview.com/script/MRrXtZOh-Price-Action-        |
//| Volumetric-Order-Blocks-UAlgo/                                   |
//|                                                                  |
//| MQL5 port, interface and corrections: German Emilio Camon, 2026  |
//| Changes include the MT5 object engine, compact data panel,       |
//| editable dark-chart palette, confirmed BOS/pivot markers,        |
//| volume fallback handling and deterministic object cleanup.       |
//|                                                                  |
//| This Source Code Form is subject to the terms of the Mozilla     |
//| Public License, v. 2.0. If a copy of the MPL was not distributed |
//| with this file, You can obtain one at                            |
//| https://mozilla.org/MPL/2.0/                                     |
//+------------------------------------------------------------------+
#property copyright "UAlgo; MQL5 port and modifications (c) 2026 German Emilio Camon"
#property link "https://www.tradingview.com/script/MRrXtZOh-Price-Action-Volumetric-Order-Blocks-UAlgo/"
#property version "1.12"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2
#property indicator_type1 DRAW_ARROW
#property indicator_type2 DRAW_ARROW
#property indicator_color1 clrTurquoise
#property indicator_color2 clrTomato
#property indicator_width1 1
#property indicator_width2 1
#property indicator_label1 "Bullish order block"
#property indicator_label2 "Bearish order block"
#property description "Open-source MT5 port with confirmed market-structure breaks and estimated volumetric order blocks."
#property description "Uses real volume when available and tick volume as fallback."
#property description "The B/S split is an estimate, not true order-flow delta."

input group "=== Structure calculation ==="
input int      SwingLength        = 8;
input int      ShowLastXOb        = 4;      // Per direction; 0 = all
input bool     ViolationByClose   = false;  // false = wick
input bool     HideOverlap        = true;
input int      MaxBarsBack        = 2000;   // 0 = all
input bool     ConfirmOnClosedBar = true;

input group "=== Display ==="
input bool     ShowStructure      = true;
input bool     ShowSwingMarks     = true;
input bool     ShowVolumeInfo     = true;
input bool     ShowZoneLabels     = false;   // Text directly over each zone
input bool     ShowDataPanel      = true;    // Compact screen panel
input bool     ReservePanelSpace  = true;    // Shift candles so the panel does not cover them
input double   PanelSpacePercent  = 0.0;     // 0 = automatic; manual range 10-50%
input int      SwingArrowUp       = 218;     // Bullish BOS triangle
input int      SwingArrowDown     = 217;     // Bearish BOS triangle
input int      PivotMarkerCode    = 159;     // Confirmed pivot symbol
input int      SwingOffsetPoints  = 20;
input int      SignalRangePeriod  = 14;      // Average range used for marker spacing
input double   SignalRangeOffset  = 0.45;    // Marker spacing as a range fraction
input double   BosTriangleScale   = 1.80;    // BOS triangle size (0.5-4.0)
input int      StructureLineWidth = 2;
input int      SeparatorLineWidth = 1;
input int      ObOpacity          = 70;
input int      VolumePanelBars    = 14;
input bool     DrawOnTop          = false;
input group "=== Editable colors ==="
input color    NeutralBorderColor = clrSlateGray; // Zone separators
input color    StructureTextColor = clrSilver;    // BOS, MSB and structure
input color    BuyVolumeColor     = clrLime;      // Estimated buy volume
input color    SellVolumeColor    = clrCrimson;   // Estimated sell volume
input color    PivotHighColor     = clrOrangeRed; // Confirmed swing high
input color    PivotLowColor      = clrDeepSkyBlue;// Confirmed swing low
input color    BosBullColor       = clrLime;      // Bullish BOS triangle
input color    BosBearColor       = clrRed;       // Bearish BOS triangle
input bool     ShowSignalLabels   = false;        // Optional pivot/BOS text

input group "=== Data panel ==="
input ENUM_BASE_CORNER DataPanelCorner = CORNER_RIGHT_UPPER;
input int      DataPanelX         = 14;
input int      DataPanelY         = 34;
input bool     AutoPanelWidth     = true;    // Ajustar al contenido
input int      DataPanelWidth     = 390;     // Maximum/manual width
input int      DataPanelRowHeight = 19;
input color    DataPanelBgColor   = C'28,42,55';  // Panel background
input color    DataPanelHeaderColor=C'55,78,96'; // Header background
input color    DataPanelBorderColor=clrSilver;    // Panel border
input color    DataPanelTitleColor= clrWhite;     // Panel title

struct SwingPoint
  {
   double            price;
   datetime          time;
   bool              crossed;
  };

struct OrderBlock
  {
   double            top,bottom,bullVolume,bearVolume,totalVolume;
   datetime          start,created;
   int               direction,id;
   bool              leftZone;
  };

SwingPoint gTop,gBottom;
OrderBlock gBullObs[],gBearObs[];
double gBosUp[],gBosDown[];
int gObjId=0,gStructId=0,gSwingId=0,gDirection=0;
datetime gLastBar=0;
bool gInitialized=false;
string gPrefix="";
color UpObColor=clrTurquoise;
color DownObColor=clrTomato;
int gPanelRenderWidth=390;
bool gOriginalChartShift=false;
bool gPanelShiftApplied=false;
double gOriginalChartShiftSize=10.0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Obj(const string suffix,const int id)
  { return gPrefix+suffix+"_"+IntegerToString(id); }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Configure(const string name,const int z)
  {
   if(ObjectFind(0,name)<0)
      return;
   ObjectSetInteger(0,name,OBJPROP_BACK,!DrawOnTop);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,z);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClearObjects()
  {
   if(gPrefix=="")
      return;
   for(int i=ObjectsTotal(0,0,-1)-1;i>=0;i--)
     {
      string name=ObjectName(0,i,0,-1);
      if(StringFind(name,gPrefix)==0)
         ObjectDelete(0,name);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteOb(const OrderBlock &ob)
  {
   ObjectDelete(0,Obj("ZONE",ob.id));
   ObjectDelete(0,Obj("BULL",ob.id));
   ObjectDelete(0,Obj("BEAR",ob.id));
   ObjectDelete(0,Obj("MID",ob.id));
   ObjectDelete(0,Obj("PANEL",ob.id));
   ObjectDelete(0,Obj("LABEL",ob.id));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RemoveAt(OrderBlock &items[],const int index)
  {
   int n=ArraySize(items);
   if(index<0 || index>=n)
      return;
   for(int i=index;i<n-1;i++)
      items[i]=items[i+1];
   ArrayResize(items,n-1);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EffectiveVolume(const int i,const long &ticks[],const long &real[])
  { return real[i]>0 ? (double)real[i] : (double)ticks[i]; }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CompactVolume(const double v)
  {
   if(v>=1000000.0)
      return DoubleToString(v/1000000.0,1)+"M";
   if(v>=1000.0)
      return DoubleToString(v/1000.0,1)+"K";
   return DoubleToString(v,0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NewBar(const datetime value)
  {
   if(value==gLastBar)
      return false;
   gLastBar=value;
   return true;
  }

// Chart objects expect BGR colors. ColorToARGB() returns ARGB for graphical
// resources and swaps the red/blue channels when used with OBJPROP_COLOR.
// Blend with the chart background in BGR to preserve a translucent look.
color BlendWithChartBackground(const color foreground,const uchar opacity)
  {
   color background=(color)ChartGetInteger(0,CHART_COLOR_BACKGROUND);
   long fg=(long)foreground;
   long bg=(long)background;
   int fr=(int)(fg&0xFF),       fgreen=(int)((fg>>8)&0xFF),  fb=(int)((fg>>16)&0xFF);
   int br=(int)(bg&0xFF),       bgreen=(int)((bg>>8)&0xFF),  bb=(int)((bg>>16)&0xFF);
   double a=(double)opacity/255.0;
   int r=(int)MathRound(fr*a+br*(1.0-a));
   int g=(int)MathRound(fgreen*a+bgreen*(1.0-a));
   int b=(int)MathRound(fb*a+bb*(1.0-a));
   return (color)(r|(g<<8)|(b<<16));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(SwingLength<2 || StructureLineWidth<1 || StructureLineWidth>5 ||
      SeparatorLineWidth<1 || SeparatorLineWidth>5 || VolumePanelBars<1 ||
      ObOpacity<0 || ObOpacity>255 ||
      SignalRangePeriod<1 || SignalRangeOffset<0.0 ||
      (PanelSpacePercent!=0.0 && (PanelSpacePercent<10.0 || PanelSpacePercent>50.0)))
      return INIT_PARAMETERS_INCORRECT;

   SetIndexBuffer(0,gBosUp,INDICATOR_DATA);
   SetIndexBuffer(1,gBosDown,INDICATOR_DATA);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetInteger(0,PLOT_ARROW,SwingArrowUp);
   PlotIndexSetInteger(1,PLOT_ARROW,SwingArrowDown);
   UpObColor=(color)PlotIndexGetInteger(0,PLOT_LINE_COLOR,0);
   DownObColor=(color)PlotIndexGetInteger(1,PLOT_LINE_COLOR,0);
   ArraySetAsSeries(gBosUp,true);
   ArraySetAsSeries(gBosDown,true);
   gOriginalChartShift=(bool)ChartGetInteger(0,CHART_SHIFT);
   gOriginalChartShiftSize=ChartGetDouble(0,CHART_SHIFT_SIZE);
   gPrefix="PAVOB_"+IntegerToString((long)ChartID())+"_"+
           IntegerToString((long)GetTickCount())+"_";
   IndicatorSetString(INDICATOR_SHORTNAME,"PA Volumetric OB Community v1.12");
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ClearObjects();
   if(gPanelShiftApplied)
     {
      ChartSetInteger(0,CHART_SHIFT,gOriginalChartShift);
      ChartSetDouble(0,CHART_SHIFT_SIZE,gOriginalChartShiftSize);
     }
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SignalPriceOffset(const int i,const double &high[],const double &low[],const int total)
  {
   int last=MathMin(total-1,i+MathMax(1,SignalRangePeriod)-1);
   double sum=0.0;
   int count=0;
   for(int k=i;k<=last;k++)
     {
      sum+=MathMax(0.0,high[k]-low[k]);
      count++;
     }
   double average=count>0?sum/(double)count:0.0;
   return MathMax(MathMax(0,SwingOffsetPoints)*_Point,average*SignalRangeOffset);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawSwing(const datetime pivotTime,const double pivotPrice,
               const datetime confirmationTime,const double confirmationPrice,
               const double offset,const bool highSwing)
  {
   if(!ShowSwingMarks)
      return;
   int id=++gSwingId;
   string name=Obj("PIVOT_CONF",id),label=Obj("PIVOT_LABEL",id);
   double markerPrice=highSwing?confirmationPrice+offset:confirmationPrice-offset;
   color markerColor=highSwing?PivotHighColor:PivotLowColor;
   if(!ObjectCreate(0,name,OBJ_ARROW,0,confirmationTime,markerPrice))
      return;
   ObjectSetInteger(0,name,OBJPROP_ARROWCODE,PivotMarkerCode);
   ObjectSetInteger(0,name,OBJPROP_COLOR,markerColor);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,highSwing?ANCHOR_BOTTOM:ANCHOR_TOP);
   Configure(name,5);
   if(ShowSignalLabels && ObjectCreate(0,label,OBJ_TEXT,0,confirmationTime,markerPrice))
     {
      ObjectSetString(0,label,OBJPROP_TEXT,highSwing?"CONFIRMED SWING HIGH":"CONFIRMED SWING LOW");
      ObjectSetInteger(0,label,OBJPROP_COLOR,markerColor);
      ObjectSetInteger(0,label,OBJPROP_FONTSIZE,7);
      ObjectSetString(0,label,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,label,OBJPROP_ANCHOR,highSwing?ANCHOR_LEFT_LOWER:ANCHOR_LEFT_UPPER);
      Configure(label,6);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawBosCaption(const datetime t,const double price,const double markerOffset,const bool bull)
  {
   int id=++gStructId;
   string marker=Obj("BOS_TRIANGLE",id),label=Obj("BOS_SIGNAL",id);
   color c=bull?BosBullColor:BosBearColor;
   double scale=MathMax(0.50,MathMin(4.00,BosTriangleScale));
   int halfSeconds=(int)MathMax(2.0,PeriodSeconds(_Period)*0.35*scale);
   double height=MathMax(MathMax(0,SwingOffsetPoints)*_Point,
                         markerOffset*0.65*scale);
   double basePrice=bull?price-height:price+height;
   if(ObjectCreate(0,marker,OBJ_TRIANGLE,0,
                   t,price,t-(datetime)halfSeconds,basePrice,t+(datetime)halfSeconds,basePrice))
     {
      ObjectSetInteger(0,marker,OBJPROP_COLOR,c);
      ObjectSetInteger(0,marker,OBJPROP_FILL,true);
      ObjectSetInteger(0,marker,OBJPROP_WIDTH,1);
      ObjectSetString(0,marker,OBJPROP_TOOLTIP,bull?"Bullish BOS break":"Bearish BOS break");
      Configure(marker,6);
      ObjectSetInteger(0,marker,OBJPROP_BACK,false);
     }
   if(!ShowSignalLabels || !ObjectCreate(0,label,OBJ_TEXT,0,t,price))
      return;
   ObjectSetString(0,label,OBJPROP_TEXT,bull?"BULLISH BOS BREAK":"BEARISH BOS BREAK");
   ObjectSetInteger(0,label,OBJPROP_COLOR,c);
   ObjectSetInteger(0,label,OBJPROP_FONTSIZE,7);
   ObjectSetString(0,label,OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,label,OBJPROP_ANCHOR,bull?ANCHOR_LEFT_UPPER:ANCHOR_LEFT_LOWER);
   Configure(label,7);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawStructure(const datetime t1,const datetime t2,const double price,
                   const bool bull,const bool msb)
  {
   if(!ShowStructure)
      return;
   int id=++gStructId;
   string line=Obj("STRUCT",id),label=Obj("STRUCT_LABEL",id);
   color c=bull?UpObColor:DownObColor;
   if(ObjectCreate(0,line,OBJ_TREND,0,t1,price,t2,price))
     {
      ObjectSetInteger(0,line,OBJPROP_COLOR,BlendWithChartBackground(c,(uchar)210));
      ObjectSetInteger(0,line,OBJPROP_WIDTH,StructureLineWidth);
      ObjectSetInteger(0,line,OBJPROP_RAY_RIGHT,false);
      Configure(line,3);
     }
   datetime middle=t1+(datetime)((t2-t1)/2);
   if(ObjectCreate(0,label,OBJ_TEXT,0,middle,price))
     {
      ObjectSetString(0,label,OBJPROP_TEXT,msb?"MSB":"BOS");
      ObjectSetInteger(0,label,OBJPROP_COLOR,StructureTextColor);
      ObjectSetInteger(0,label,OBJPROP_FONTSIZE,8);
      ObjectSetString(0,label,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,label,OBJPROP_ANCHOR,ANCHOR_CENTER);
      Configure(label,4);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Overlaps(const OrderBlock &candidate,const OrderBlock &items[])
  {
   for(int i=0;i<ArraySize(items);i++)
      if(candidate.bottom<=items[i].top && candidate.top>=items[i].bottom)
         return true;
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Strengths(const int blockIndex,const int breakIndex,const double &open[],
               const double &close[],const long &ticks[],const long &real[],
               double &bull,double &bear)
  {
   bull=0.0;
   bear=0.0;
   for(int i=blockIndex;i>=breakIndex;i--)
     {
      double v=EffectiveVolume(i,ticks,real);
      if(close[i]>open[i])
         bull+=v;
      else
         if(close[i]<open[i])
            bear+=v;
         else
           {
            bull+=v*0.5;
            bear+=v*0.5;
           }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawOb(const OrderBlock &ob,const datetime now)
  {
   datetime right=now;
   int sec=MathMax(1,PeriodSeconds(_Period));
   if(right<=ob.start)
      right=ob.start+(datetime)sec;
   double middle=(ob.top+ob.bottom)*0.5;
   double total=ob.totalVolume>0.0?ob.totalVolume:1.0;
   double br=ob.bullVolume/total,sr=ob.bearVolume/total;
   datetime wanted=right-(datetime)(sec*VolumePanelBars);
   datetime panelLeft=wanted>ob.start?wanted:ob.start;
   double panelSeconds=(double)(right-panelLeft);
   datetime bullRight=panelLeft+(datetime)(panelSeconds*br);
   datetime bearRight=panelLeft+(datetime)(panelSeconds*sr);
   string zone=Obj("ZONE",ob.id),bull=Obj("BULL",ob.id),bear=Obj("BEAR",ob.id);
   string mid=Obj("MID",ob.id),panel=Obj("PANEL",ob.id),label=Obj("LABEL",ob.id);
   uchar alpha=(uchar)ObOpacity;
   color base=ob.direction>0?UpObColor:DownObColor;

   if(ObjectFind(0,zone)<0)
     {
      ObjectCreate(0,zone,OBJ_RECTANGLE,0,ob.start,ob.top,right,ob.bottom);
      ObjectSetInteger(0,zone,OBJPROP_FILL,true);
      Configure(zone,1);
      ObjectCreate(0,bull,OBJ_RECTANGLE,0,panelLeft,ob.top,bullRight,middle);
      ObjectSetInteger(0,bull,OBJPROP_FILL,true);
      Configure(bull,2);
      ObjectCreate(0,bear,OBJ_RECTANGLE,0,panelLeft,middle,bearRight,ob.bottom);
      ObjectSetInteger(0,bear,OBJPROP_FILL,true);
      Configure(bear,2);
      ObjectCreate(0,mid,OBJ_TREND,0,ob.start,middle,right,middle);
      ObjectSetInteger(0,mid,OBJPROP_STYLE,STYLE_DOT);
      ObjectSetInteger(0,mid,OBJPROP_WIDTH,SeparatorLineWidth);
      ObjectSetInteger(0,mid,OBJPROP_RAY_RIGHT,false);
      Configure(mid,3);
      ObjectCreate(0,panel,OBJ_TREND,0,panelLeft,ob.top,panelLeft,ob.bottom);
      ObjectSetInteger(0,panel,OBJPROP_STYLE,STYLE_DASH);
      ObjectSetInteger(0,panel,OBJPROP_WIDTH,SeparatorLineWidth);
      ObjectSetInteger(0,panel,OBJPROP_RAY_RIGHT,false);
      Configure(panel,3);
     }
   else
     {
      ObjectMove(0,zone,0,ob.start,ob.top);
      ObjectMove(0,zone,1,right,ob.bottom);
      ObjectMove(0,bull,0,panelLeft,ob.top);
      ObjectMove(0,bull,1,bullRight,middle);
      ObjectMove(0,bear,0,panelLeft,middle);
      ObjectMove(0,bear,1,bearRight,ob.bottom);
      ObjectMove(0,mid,0,ob.start,middle);
      ObjectMove(0,mid,1,right,middle);
      ObjectMove(0,panel,0,panelLeft,ob.top);
      ObjectMove(0,panel,1,panelLeft,ob.bottom);
     }

// Reaplicar siempre los colores evita que objetos ya existentes conserven
// una paleta antigua después de cambiar las propiedades del indicador.
   ObjectSetInteger(0,zone,OBJPROP_COLOR,BlendWithChartBackground(base,alpha));
   ObjectSetInteger(0,bull,OBJPROP_COLOR,BuyVolumeColor);   // upper half
   ObjectSetInteger(0,bear,OBJPROP_COLOR,SellVolumeColor);  // lower half
   ObjectSetInteger(0,mid,OBJPROP_COLOR,BlendWithChartBackground(NeutralBorderColor,(uchar)150));
   ObjectSetInteger(0,panel,OBJPROP_COLOR,BlendWithChartBackground(NeutralBorderColor,(uchar)180));

   if(ShowVolumeInfo && ShowZoneLabels)
     {
      string text=(ob.direction>0?"Bullish OB":"Bearish OB")+"  B "+
                  IntegerToString((int)MathRound(br*100.0))+"% / S "+
                  IntegerToString((int)MathRound(sr*100.0))+"%  V "+CompactVolume(ob.totalVolume);
      double p=ob.direction>0?ob.top:ob.bottom;
      if(ObjectFind(0,label)<0)
        {
         ObjectCreate(0,label,OBJ_TEXT,0,panelLeft,p);
         ObjectSetInteger(0,label,OBJPROP_COLOR,StructureTextColor);
         ObjectSetInteger(0,label,OBJPROP_FONTSIZE,8);
         ObjectSetString(0,label,OBJPROP_FONT,"Arial");
         ObjectSetInteger(0,label,OBJPROP_ANCHOR,ob.direction>0?ANCHOR_LEFT_LOWER:ANCHOR_LEFT_UPPER);
         Configure(label,4);
        }
      ObjectSetString(0,label,OBJPROP_TEXT,text);
      ObjectMove(0,label,0,panelLeft,p);
     }
   else
      ObjectDelete(0,label);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_ANCHOR_POINT PanelAnchor()
  {
   if(DataPanelCorner==CORNER_RIGHT_UPPER)
      return ANCHOR_RIGHT_UPPER;
   if(DataPanelCorner==CORNER_LEFT_LOWER)
      return ANCHOR_LEFT_LOWER;
   if(DataPanelCorner==CORNER_RIGHT_LOWER)
      return ANCHOR_RIGHT_LOWER;
   return ANCHOR_LEFT_UPPER;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteDataPanel()
  {
   ObjectDelete(0,Obj("DATA_BG",0));
   ObjectDelete(0,Obj("DATA_HEADER",0));
   ObjectDelete(0,Obj("DATA_TITLE",0));
   for(int i=0;i<40;i++)
      ObjectDelete(0,Obj("DATA_ROW",i));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetPanelLabel(const string name,const string text,const int x,const int y,
                   const color textColor,const int fontSize,const bool isTitle=false)
  {
   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_EDIT,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_CORNER,DataPanelCorner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,MathMax(250,gPanelRenderWidth)-24);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,isTitle?22:MathMax(16,DataPanelRowHeight));
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,isTitle?DataPanelHeaderColor:DataPanelBgColor);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,isTitle?DataPanelHeaderColor:DataPanelBgColor);
   ObjectSetInteger(0,name,OBJPROP_READONLY,true);
   ObjectSetInteger(0,name,OBJPROP_ALIGN,ALIGN_LEFT);
   ObjectSetInteger(0,name,OBJPROP_COLOR,textColor);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontSize);
   ObjectSetString(0,name,OBJPROP_FONT,"Consolas");
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   Configure(name,12);
// Screen-space labels must remain above candles even when zones are behind them.
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string PanelRowText(const OrderBlock &ob)
  {
   double total=ob.totalVolume>0.0?ob.totalVolume:1.0;
   int bp=(int)MathRound(ob.bullVolume/total*100.0);
   int sp=(int)MathRound(ob.bearVolume/total*100.0);
   return (ob.direction>0?"BUY  ":"SELL ")+
          DoubleToString(ob.bottom,_Digits)+" - "+DoubleToString(ob.top,_Digits)+
          " | B"+IntegerToString(bp)+" S"+IntegerToString(sp)+
          " | V "+CompactVolume(ob.totalVolume);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ApplyPanelChartSpace()
  {
   bool right=(DataPanelCorner==CORNER_RIGHT_UPPER || DataPanelCorner==CORNER_RIGHT_LOWER);
   if(!ReservePanelSpace || !ShowDataPanel || !right)
      return;
   long chartWidth=ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   if(chartWidth<=0)
      return;
   double required=((double)MathMax(280,gPanelRenderWidth)+2.0*MathMax(0,DataPanelX))*100.0/
                   (double)chartWidth;
   double shiftPercent=(PanelSpacePercent==0.0)?required+2.0:
                       MathMax(PanelSpacePercent,required+2.0);
   shiftPercent=MathMax(10.0,MathMin(50.0,shiftPercent));
   ChartSetInteger(0,CHART_SHIFT,true);
   ChartSetDouble(0,CHART_SHIFT_SIZE,shiftPercent);
   if(!gPanelShiftApplied)
      ChartNavigate(0,CHART_END,0);
   gPanelShiftApplied=true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateDataPanel()
  {
   if(!ShowDataPanel)
     {
      DeleteDataPanel();
      return;
     }

   int rows=ArraySize(gBullObs)+ArraySize(gBearObs);
   int rowHeight=MathMax(15,DataPanelRowHeight);
   string panelTitle="ACTIVE VOLUMETRIC ORDER BLOCKS  ["+IntegerToString(rows)+"]";
   int maxChars=StringLen(panelTitle);
   for(int i=0;i<ArraySize(gBullObs);i++)
      maxChars=MathMax(maxChars,StringLen(PanelRowText(gBullObs[i])));
   for(int i=0;i<ArraySize(gBearObs);i++)
      maxChars=MathMax(maxChars,StringLen(PanelRowText(gBearObs[i])));
   int manualWidth=MathMax(280,DataPanelWidth);
   int width=AutoPanelWidth?MathMin(manualWidth,MathMax(290,maxChars*6+30)):manualWidth;
   gPanelRenderWidth=width;
   ApplyPanelChartSpace();
   int height=42+rows*rowHeight;
   bool right=(DataPanelCorner==CORNER_RIGHT_UPPER || DataPanelCorner==CORNER_RIGHT_LOWER);
   bool lower=(DataPanelCorner==CORNER_LEFT_LOWER || DataPanelCorner==CORNER_RIGHT_LOWER);
   int panelX=MathMax(0,DataPanelX)+(right?width:0);
   int panelY=MathMax(0,DataPanelY)+(lower?height:0);
   string bg=Obj("DATA_BG",0);
   if(ObjectFind(0,bg)<0)
      ObjectCreate(0,bg,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,bg,OBJPROP_CORNER,DataPanelCorner);
   ObjectSetInteger(0,bg,OBJPROP_XDISTANCE,panelX);
   ObjectSetInteger(0,bg,OBJPROP_YDISTANCE,panelY);
   ObjectSetInteger(0,bg,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,bg,OBJPROP_YSIZE,height);
   ObjectSetInteger(0,bg,OBJPROP_BGCOLOR,DataPanelBgColor);
   ObjectSetInteger(0,bg,OBJPROP_BORDER_COLOR,DataPanelBorderColor);
   ObjectSetInteger(0,bg,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   Configure(bg,10);
// The data card is a HUD element, not a price-zone object.
   ObjectSetInteger(0,bg,OBJPROP_BACK,false);

// A distinct header makes the card visible even on a black chart theme.
   string header=Obj("DATA_HEADER",0);
   if(ObjectFind(0,header)<0)
      ObjectCreate(0,header,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,header,OBJPROP_CORNER,DataPanelCorner);
   ObjectSetInteger(0,header,OBJPROP_XDISTANCE,panelX+(right?-1:1));
   ObjectSetInteger(0,header,OBJPROP_YDISTANCE,panelY+(lower?-1:1));
   ObjectSetInteger(0,header,OBJPROP_XSIZE,width-2);
   ObjectSetInteger(0,header,OBJPROP_YSIZE,26);
   ObjectSetInteger(0,header,OBJPROP_BGCOLOR,DataPanelHeaderColor);
   ObjectSetInteger(0,header,OBJPROP_BORDER_COLOR,DataPanelHeaderColor);
   ObjectSetInteger(0,header,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   Configure(header,11);
   ObjectSetInteger(0,header,OBJPROP_BACK,false);

   int textX=MathMax(0,DataPanelX)+(right?width-12:12);
   int titleY=lower?MathMax(0,DataPanelY)+height-9:MathMax(0,DataPanelY)+9;
   SetPanelLabel(Obj("DATA_TITLE",0),
                 panelTitle,
                 textX,titleY,DataPanelTitleColor,9,true);

   for(int i=0;i<40;i++)
      ObjectDelete(0,Obj("DATA_ROW",i));
   int row=0;
   for(int i=ArraySize(gBullObs)-1;i>=0;i--)
     {
      int y=lower?MathMax(0,DataPanelY)+height-31-row*rowHeight
            :MathMax(0,DataPanelY)+31+row*rowHeight;
      SetPanelLabel(Obj("DATA_ROW",row),PanelRowText(gBullObs[i]),textX,y,UpObColor,8);
      row++;
     }
   for(int i=ArraySize(gBearObs)-1;i>=0;i--)
     {
      int y=lower?MathMax(0,DataPanelY)+height-31-row*rowHeight
            :MathMax(0,DataPanelY)+31+row*rowHeight;
      SetPanelLabel(Obj("DATA_ROW",row),PanelRowText(gBearObs[i]),textX,y,DownObColor,8);
      row++;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trim(OrderBlock &items[])
  {
   while(ShowLastXOb>0 && ArraySize(items)>ShowLastXOb)
     { DeleteOb(items[0]); RemoveAt(items,0); }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AddOb(const OrderBlock &ob)
  {
   if(ob.direction>0)
     {
      if(HideOverlap && Overlaps(ob,gBullObs))
         return;
      int n=ArraySize(gBullObs);
      ArrayResize(gBullObs,n+1);
      gBullObs[n]=ob;
      Trim(gBullObs);
     }
   else
     {
      if(HideOverlap && Overlaps(ob,gBearObs))
         return;
      int n=ArraySize(gBearObs);
      ArrayResize(gBearObs,n+1);
      gBearObs[n]=ob;
      Trim(gBearObs);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateOb(const int breakIndex,const int direction,const datetime &time[],
              const double &open[],const double &high[],const double &low[],
              const double &close[],const long &ticks[],const long &real[],const int total)
  {
   int selected=-1;
   double top=0.0,bottom=direction>0?DBL_MAX:0.0;
   for(int d=1;d<=SwingLength;d++)
     {
      int i=breakIndex+d;
      if(i>=total)
         break;
      if(direction>0 && close[i]<open[i] && low[i]<bottom)
        { selected=i; bottom=low[i]; top=high[i]; }
      if(direction<0 && close[i]>open[i] && high[i]>top)
        { selected=i; top=high[i]; bottom=low[i]; }
     }
   if(selected<0)
      return;
   double bv,sv;
   Strengths(selected,breakIndex,open,close,ticks,real,bv,sv);
   OrderBlock ob;
   ob.top=top;
   ob.bottom=bottom;
   ob.start=time[selected];
   ob.bullVolume=bv;
   ob.bearVolume=sv;
   ob.totalVolume=bv+sv;
   ob.direction=direction;
   ob.id=++gObjId;
   ob.created=time[breakIndex];
   ob.leftZone=(direction>0?close[breakIndex]>top:close[breakIndex]<bottom);
   AddOb(ob);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PivotHigh(const int i,const double &high[],const int total)
  {
   if(i<SwingLength || i+SwingLength>=total)
      return false;
   for(int d=1;d<=SwingLength;d++)
      if(high[i-d]>=high[i] || high[i+d]>high[i])
         return false;
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PivotLow(const int i,const double &low[],const int total)
  {
   if(i<SwingLength || i+SwingLength>=total)
      return false;
   for(int d=1;d<=SwingLength;d++)
      if(low[i-d]<=low[i] || low[i+d]<low[i])
         return false;
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RegisterPivot(const int i,const datetime &time[],const double &high[],
                   const double &low[],const int total)
  {
   int confirmationIndex=i-SwingLength;
   if(confirmationIndex<0 || confirmationIndex>=total)
      return;
   double offset=SignalPriceOffset(confirmationIndex,high,low,total);
   if(PivotHigh(i,high,total))
     {
      gTop.time=time[i];
      gTop.price=high[i];
      gTop.crossed=false;
      DrawSwing(time[i],high[i],time[confirmationIndex],high[confirmationIndex],offset,true);
     }
   if(PivotLow(i,low,total))
     {
      gBottom.time=time[i];
      gBottom.price=low[i];
      gBottom.crossed=false;
      DrawSwing(time[i],low[i],time[confirmationIndex],low[confirmationIndex],offset,false);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Invalidate(const int i,const double &high[],const double &low[],const double &close[])
  {
   for(int k=ArraySize(gBullObs)-1;k>=0;k--)
      if(ViolationByClose?close[i]<gBullObs[k].bottom:low[i]<gBullObs[k].bottom)
        { DeleteOb(gBullObs[k]); RemoveAt(gBullObs,k); }
   for(int k=ArraySize(gBearObs)-1;k>=0;k--)
      if(ViolationByClose?close[i]>gBearObs[k].top:high[i]>gBearObs[k].top)
        { DeleteOb(gBearObs[k]); RemoveAt(gBearObs,k); }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Evaluate(const int i,const datetime &time[],const double &open[],const double &high[],
              const double &low[],const double &close[],const long &ticks[],
              const long &real[],const int total)
  {
   gBosUp[i]=EMPTY_VALUE;
   gBosDown[i]=EMPTY_VALUE;
   double markerOffset=SignalPriceOffset(i,high,low,total);
   if(!gBottom.crossed && gBottom.price>0.0 && close[i]<gBottom.price)
     {
      bool msb=gDirection!=0 && gDirection!=-1;
      gBottom.crossed=true;
      gDirection=-1;
      DrawStructure(gBottom.time,time[i],gBottom.price,false,msb);
      DrawBosCaption(time[i],high[i]+markerOffset,markerOffset,false);
      CreateOb(i,-1,time,open,high,low,close,ticks,real,total);
     }
   if(!gTop.crossed && gTop.price>0.0 && close[i]>gTop.price)
     {
      bool msb=gDirection!=0 && gDirection!=1;
      gTop.crossed=true;
      gDirection=1;
      DrawStructure(gTop.time,time[i],gTop.price,true,msb);
      DrawBosCaption(time[i],low[i]-markerOffset,markerOffset,true);
      CreateOb(i,1,time,open,high,low,close,ticks,real,total);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ProcessBar(const int i,const datetime &time[],const double &open[],const double &high[],
                const double &low[],const double &close[],const long &ticks[],
                const long &real[],const int total)
  {
   RegisterPivot(i+SwingLength,time,high,low,total); // confirmed only now: no look-ahead
   Evaluate(i,time,open,high,low,close,ticks,real,total);
   Invalidate(i,high,low,close);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateObjects(const datetime now)
  {
   for(int i=0;i<ArraySize(gBullObs);i++)
      DrawOb(gBullObs[i],now);
   for(int i=0;i<ArraySize(gBearObs);i++)
      DrawOb(gBearObs[i],now);
   UpdateDataPanel();
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],const double &high[],const double &low[],
                const double &close[],const long &tick_volume[],const long &volume[],
                const int &spread[])
  {
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(tick_volume,true);
   ArraySetAsSeries(volume,true);
   ArraySetAsSeries(spread,true);
   if(rates_total<SwingLength*2+10)
      return 0;

   bool newBar=NewBar(time[0]);
   if(!gInitialized || prev_calculated==0)
     {
      ClearObjects();
      ArrayResize(gBullObs,0);
      ArrayResize(gBearObs,0);
      gTop.price=0.0;
      gTop.time=0;
      gTop.crossed=false;
      gBottom.price=0.0;
      gBottom.time=0;
      gBottom.crossed=false;
      gDirection=0;
      gObjId=0;
      gStructId=0;
      gSwingId=0;
      ArrayInitialize(gBosUp,EMPTY_VALUE);
      ArrayInitialize(gBosDown,EMPTY_VALUE);
      int maxStart=rates_total-1-SwingLength*2;
      int oldest=MaxBarsBack>0?MathMin(maxStart,MaxBarsBack+SwingLength):maxStart;
      int newest=ConfirmOnClosedBar?1:0;
      for(int i=oldest;i>=newest;i--)
         ProcessBar(i,time,open,high,low,close,tick_volume,volume,rates_total);
      UpdateObjects(time[0]);
      gInitialized=true;
     }
   else
     {
      gBosUp[0]=EMPTY_VALUE;
      gBosDown[0]=EMPTY_VALUE;
      if(ConfirmOnClosedBar)
        {
         if(newBar)
            ProcessBar(1,time,open,high,low,close,tick_volume,volume,rates_total);
        }
      else
        {
         if(newBar)
           {
            RegisterPivot(SwingLength+1,time,high,low,rates_total);
            Invalidate(1,high,low,close);
           }
         Evaluate(0,time,open,high,low,close,tick_volume,volume,rates_total);
         Invalidate(0,high,low,close);
        }
      if(newBar || !ConfirmOnClosedBar)
         UpdateObjects(time[0]);
     }
   return rates_total;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                    SAXAnalog.mq5 |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/23484 |
//+------------------------------------------------------------------+
#property copyright "MMQ — Muhammad Minhas Qamar"
#property link      "https://www.mql5.com/en/articles/23484"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_plots 0

#include <SAX\SAXAnalogs.mqh>

//--- shape / search
input int             InpWinLen    = 48;                 // window length (bars)
input int             InpHorizon   = 12;                 // forecast horizon (bars)
input int             InpWordLen   = 8;                  // SAX word length
input int             InpAlphabet  = 4;                  // SAX alphabet size
input int             InpMaxAnalogs= 50;                 // max analogs kept
input int             InpMinAnalogs= 10;                 // min analogs for a verdict
input double          InpEdgeATR   = 0.25;               // |median| ATR for an edge
input ENUM_SAX_METRIC InpMetric    = SAX_METRIC_MINDIST; // search metric
input int             InpATRPeriod = 14;                 // ATR period (scale)
input int             InpMaxHistory= 6000;               // bars of history to scan

//--- appearance
//--- panel theme (background + body-text colors)
enum ENUM_PANEL_THEME
  {
   THEME_DARK,   // dark box, light text  (for dark charts)
   THEME_LIGHT   // light box, dark text  (for light charts)
  };

input color            InpUpColor   = clrDodgerBlue;      // bullish cone / panel
input color            InpDownColor = clrTomato;          // bearish cone / panel
input color            InpFlatColor = clrGray;            // no-edge / too-few
input color            InpBandColor = clrSlateGray;       // p25..p75 band lines
input int              InpCorner    = CORNER_LEFT_UPPER;  // panel corner
input ENUM_PANEL_THEME InpTheme     = THEME_DARK;         // panel theme

//--- globals
int      g_hATR=INVALID_HANDLE;
string   g_pfx="SAXAN_";          // object-name prefix (all ours, easy cleanup)
datetime g_lastBar=0;
CSAXAnalogFinder g_finder;

//+------------------------------------------------------------------+
//| Indicator init: configure the finder and create the ATR handle.  |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!g_finder.Configure(InpWinLen,InpHorizon,InpWordLen,InpAlphabet,InpMetric))
     {
      Print("SAXAnalog: bad configuration (check window/word/alphabet)");
      return(INIT_PARAMETERS_INCORRECT);
     }
   g_finder.SetMaxAnalogs(InpMaxAnalogs);
   g_finder.SetMinAnalogs(InpMinAnalogs);
   g_finder.SetEdgeThreshold(InpEdgeATR);

   g_hATR=iATR(_Symbol,_Period,InpATRPeriod);
   if(g_hATR==INVALID_HANDLE)
     {
      Print("SAXAnalog: failed to create ATR handle");
      return(INIT_FAILED);
     }

   IndicatorSetString(INDICATOR_SHORTNAME,"SAX Analog Forecaster");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Indicator shutdown: drop our objects and release the ATR handle. |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,g_pfx);
   if(g_hATR!=INVALID_HANDLE)
      IndicatorRelease(g_hATR);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Recompute only when a new bar has formed.                        |
//+------------------------------------------------------------------+
bool NewBar()
  {
   datetime t=iTime(_Symbol,_Period,0);
   if(t==g_lastBar)
      return false;
   g_lastBar=t;
   return true;
  }

//+------------------------------------------------------------------+
//| Load closes + aligned ATR into chronological buffers (oldest at  |
//| index 0). 'shift 1' so only CLOSED bars are used. Returns the    |
//| number of usable bars, or 0 on failure.                          |
//+------------------------------------------------------------------+
int LoadHistory(double &close[],double &atr[])
  {
   int want=InpMaxHistory;
   int got=CopyClose(_Symbol,_Period,1,want,close);
   if(got<InpWinLen+InpHorizon+InpATRPeriod+5)
      return 0;
   ArraySetAsSeries(close,false);

   double atrBuf[];
   if(CopyBuffer(g_hATR,0,1,got,atrBuf)<got)
      return 0;
   ArraySetAsSeries(atrBuf,false);

   ArrayResize(atr,got);
   for(int i=0;i<got;i++)
      atr[i]=atrBuf[i];
   return got;
  }

//+------------------------------------------------------------------+
//| Create-or-update a trend segment object between two chart points.|
//+------------------------------------------------------------------+
void SetTrend(string name,datetime t1,double p1,datetime t2,double p2,
              color clr,int width,int style)
  {
   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_TREND,0,t1,p1,t2,p2);
   ObjectSetInteger(0,name,OBJPROP_TIME,0,t1);
   ObjectSetDouble(0,name,OBJPROP_PRICE,0,p1);
   ObjectSetInteger(0,name,OBJPROP_TIME,1,t2);
   ObjectSetDouble(0,name,OBJPROP_PRICE,1,p2);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(0,name,OBJPROP_STYLE,style);
   ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,false);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }

//+------------------------------------------------------------------+
//| Create-or-update a text label anchored to a chart corner.        |
//+------------------------------------------------------------------+
void SetLabel(string name,int x,int y,string text,color clr,int fontsize)
  {
   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_CORNER,InpCorner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
   ObjectSetString(0,name,OBJPROP_FONT,"Consolas");
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }

//+------------------------------------------------------------------+
//| Erase the fan-cone objects (they are rebuilt each new bar).      |
//+------------------------------------------------------------------+
void ClearCone()
  {
   for(int k=0;k<InpHorizon+2;k++)
     {
      ObjectDelete(0,g_pfx+"med_"+(string)k);
      ObjectDelete(0,g_pfx+"p25_"+(string)k);
      ObjectDelete(0,g_pfx+"p75_"+(string)k);
     }
  }

//+------------------------------------------------------------------+
//| Draw the fan cone.                                               |
//|  The per-step distribution is in ATR units; multiply by the      |
//|  CURRENT ATR to turn it into a price offset from the last close, |
//|  so the cone sits on the real price axis. Future bar times don't |
//|  exist yet, so their timestamps are extrapolated from the last   |
//|  bar time + k * PeriodSeconds().                                 |
//+------------------------------------------------------------------+
void DrawCone(datetime lastTime,double lastClose,double curATR,color clr)
  {
   int    ps=PeriodSeconds(_Period);
   double medPrev=lastClose,p25Prev=lastClose,p75Prev=lastClose;
   datetime tPrev=lastTime;

   for(int k=1;k<=InpHorizon;k++)
     {
      SStepStat st;
      if(!g_finder.StepStats(k,st))
         break;
      datetime tk=lastTime+(datetime)(k*ps);
      double med=lastClose+st.median_atr*curATR;
      double p25=lastClose+st.p25_atr   *curATR;
      double p75=lastClose+st.p75_atr   *curATR;

      SetTrend(g_pfx+"med_"+(string)k,tPrev,medPrev,tk,med,clr,2,STYLE_SOLID);
      SetTrend(g_pfx+"p75_"+(string)k,tPrev,p75Prev,tk,p75,InpBandColor,1,STYLE_DOT);
      SetTrend(g_pfx+"p25_"+(string)k,tPrev,p25Prev,tk,p25,InpBandColor,1,STYLE_DOT);

      tPrev=tk;
      medPrev=med;
      p25Prev=p25;
      p75Prev=p75;
     }
  }

//+------------------------------------------------------------------+
//| Draw the corner verdict panel (background box + text rows).      |
//|  The box is sized from the actual rendered text so nothing clips |
//|  at any font/content, and its colors follow InpTheme so it reads |
//|  on both dark and light charts. Header and verdict rows take the |
//|  verdict color; body rows take the theme's text color.           |
//+------------------------------------------------------------------+
void DrawPanel(SForwardStats &s,string word,string verdict,color clr)
  {
   const int pad=8;                // inner margin, px
   const int x=12,y=20,rowH=16;    // origin and row pitch
   const int fBody=9,fHead=10;     // font sizes

//--- theme colors
   color bgCol  =(InpTheme==THEME_LIGHT)?C'245,245,248':C'20,20,25';
   color bodyCol=(InpTheme==THEME_LIGHT)?C'40,40,45'   :clrSilver;

//--- assemble the seven rows (text + font size). Rows 0 and 6 are the
//--- accent rows; the middle five are body rows.
   string txt[7];
   int    fnt[7];
   txt[0]="SAX ANALOG FORECAST";
   fnt[0]=fHead;
   txt[1]=StringFormat("word    : %s",word);
   fnt[1]=fBody;
   txt[2]=StringFormat("analogs : %d   (avg dist %.2f)",
                       s.count,s.avg_distance);
   fnt[2]=fBody;
   txt[3]=StringFormat("fwd %2d  : median %+.2f ATR  (%+.2f%%)",
                       InpHorizon,s.median_atr,s.median_pct);
   fnt[3]=fBody;
   txt[4]=StringFormat("band    : %+.2f .. %+.2f ATR",
                       s.p25_atr,s.p75_atr);
   fnt[4]=fBody;
   txt[5]=StringFormat("up rate : %.0f%%   spread %.2f ATR",
                       100.0*s.up_rate,s.dispersion);
   fnt[5]=fBody;
   txt[6]=StringFormat("VERDICT : %s",verdict);
   fnt[6]=fHead;

//--- measure the widest row to size the box (same font as the labels)
   int maxW=0;
   for(int i=0;i<7;i++)
     {
      TextSetFont("Consolas",-fnt[i]*10);   // negative = points*10 (dpi-aware)
      uint tw=0,th=0;
      TextGetSize(txt[i],tw,th);
      if((int)tw>maxW)
         maxW=(int)tw;
     }
   int boxW=maxW+2*pad;
   int boxH=rowH*7+2*pad;

//--- background box
   string bg=g_pfx+"bg";
   if(ObjectFind(0,bg)<0)
      ObjectCreate(0,bg,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,bg,OBJPROP_CORNER,InpCorner);
   ObjectSetInteger(0,bg,OBJPROP_XDISTANCE,x-pad);
   ObjectSetInteger(0,bg,OBJPROP_YDISTANCE,y-pad);
   ObjectSetInteger(0,bg,OBJPROP_XSIZE,boxW);
   ObjectSetInteger(0,bg,OBJPROP_YSIZE,boxH);
   ObjectSetInteger(0,bg,OBJPROP_BGCOLOR,bgCol);
   ObjectSetInteger(0,bg,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,bg,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,bg,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,bg,OBJPROP_HIDDEN,true);

//--- text rows: accent color on header/verdict, theme text on the rest
   for(int i=0;i<7;i++)
     {
      color rc=(i==0 || i==6)?clr:bodyCol;
      SetLabel(g_pfx+"t"+(string)i,x,y+rowH*i,txt[i],rc,fnt[i]);
     }

//--- drop any orphaned row from an earlier (taller) layout
   ObjectDelete(0,g_pfx+"t7");
  }

//+------------------------------------------------------------------+
//| Map a verdict to its display color.                              |
//+------------------------------------------------------------------+
color VerdictColor(ENUM_ANALOG_VERDICT v)
  {
   switch(v)
     {
      case ANALOG_BULLISH:
         return InpUpColor;
      case ANALOG_BEARISH:
         return InpDownColor;
      default:
         return InpFlatColor;   // no-edge / too-few / no-data
     }
  }

//+------------------------------------------------------------------+
//| Main: run the search on each new bar and redraw cone + panel.    |
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
   if(!NewBar() && prev_calculated>0)
      return(rates_total);

   double c[],atr[];
   int n=LoadHistory(c,atr);
   if(n<=0)
      return(rates_total);

//--- query ends at the newest loaded (closed) bar
   int qEnd=n-1;
   bool ok=g_finder.Find(c,atr,n,qEnd);

   SForwardStats s=g_finder.Stats();
   color clr=VerdictColor(s.verdict);

//--- last CLOSED bar anchors the cone (index 1 on the live chart)
   datetime lastTime=iTime(_Symbol,_Period,1);
   double   lastClose=iClose(_Symbol,_Period,1);
   double   curATR=(atr[n-1]>0.0)?atr[n-1]:0.0;

   ClearCone();
//--- draw the cone only when there is a high-conviction edge
   if(ok && curATR>0.0 &&
      (s.verdict==ANALOG_BULLISH || s.verdict==ANALOG_BEARISH))
      DrawCone(lastTime,lastClose,curATR,clr);

   string word=ok?g_finder.QueryWord():"-";
   DrawPanel(s,word,g_finder.VerdictText(),clr);

   ChartRedraw();
   return(rates_total);
  }
//+------------------------------------------------------------------+

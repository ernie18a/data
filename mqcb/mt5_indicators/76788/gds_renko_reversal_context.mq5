//+------------------------------------------------------------------+
//|                                   GDS_Renko_Reversal_Context.mq5 |
//|                                  Golden Delta - CodeBase Edition |
//|                                       https://goldendeltaea.com/ |
//+------------------------------------------------------------------+
#property copyright "Golden Delta"
#property link      "https://goldendeltaea.com/"
#property version   "1.01"
#property description "Shows the current fixed-size Renko run and the price level required"
#property description "to confirm a classic two-brick reversal. The indicator builds its own"
#property description "Renko sequence from tick history and uses no external libraries."
#property indicator_chart_window
#property indicator_plots   0

//--- User settings
input group "Renko"
input double InpBrickSize = 1.00;        // Brick size in price units
input int    InpHistoryTicks = 100000;   // Ticks used to initialize Renko history

input group "Display"
input bool   InpShowReversalLine = true; // Show confirmed reversal level
input int    InpX = 12;                  // Panel X offset
input int    InpY = 18;                  // Panel Y offset
input color  InpUpColor = clrDeepSkyBlue;
input color  InpDownColor = clrTomato;
input color  InpReversalColor = clrOrange;

//+------------------------------------------------------------------+
//| Minimal classic Renko implementation.                            |
//| Continuation: 1 brick. Reversal: 2 bricks from last close.       |
//+------------------------------------------------------------------+
struct SRenkoBrick
  {
   double close;
   int    direction; // +1 up, -1 down
  };

class CRenkoBuilder
  {
private:
   double m_size;
   bool   m_has_anchor;
   double m_anchor;
   double m_last_close;
   int    m_last_dir;

   void AddBrick(SRenkoBrick &out[],const double close_price,const int direction)
     {
      const int n=ArraySize(out);
      ArrayResize(out,n+1);
      out[n].close=close_price;
      out[n].direction=direction;
     }

public:
   CRenkoBuilder(void)
     {
      m_size=0.0;
      Reset();
     }

   void Init(const double brick_size)
     {
      m_size=brick_size;
      Reset();
     }

   void Reset(void)
     {
      m_has_anchor=false;
      m_anchor=0.0;
      m_last_close=0.0;
      m_last_dir=0;
     }

   int PushPrice(const double price,SRenkoBrick &out[])
     {
      ArrayResize(out,0);
      if(m_size<=0.0 || price<=0.0)
         return 0;

      if(!m_has_anchor)
        {
         m_anchor=price;
         m_has_anchor=true;
         return 0;
        }

      int added=0;

      // First confirmed direction starts one brick from the anchor.
      if(m_last_dir==0)
        {
         while(price>=m_anchor+m_size)
           {
            m_anchor+=m_size;
            m_last_close=m_anchor;
            m_last_dir=+1;
            AddBrick(out,m_last_close,+1);
            added++;
           }
         while(price<=m_anchor-m_size)
           {
            m_anchor-=m_size;
            m_last_close=m_anchor;
            m_last_dir=-1;
            AddBrick(out,m_last_close,-1);
            added++;
           }
         return added;
        }

      bool changed=true;
      while(changed)
        {
         changed=false;

         if(m_last_dir>0)
           {
            // Up continuation needs one full brick.
            if(price>=m_last_close+m_size)
              {
               m_last_close+=m_size;
               AddBrick(out,m_last_close,+1);
               added++;
               changed=true;
              }
            // Classic reversal needs two bricks from the previous close.
            else if(price<=m_last_close-2.0*m_size)
              {
               m_last_close-=2.0*m_size;
               m_last_dir=-1;
               AddBrick(out,m_last_close,-1);
               added++;
               changed=true;
              }
           }
         else
           {
            // Down continuation needs one full brick.
            if(price<=m_last_close-m_size)
              {
               m_last_close-=m_size;
               AddBrick(out,m_last_close,-1);
               added++;
               changed=true;
              }
            // Classic reversal needs two bricks from the previous close.
            else if(price>=m_last_close+2.0*m_size)
              {
               m_last_close+=2.0*m_size;
               m_last_dir=+1;
               AddBrick(out,m_last_close,+1);
               added++;
               changed=true;
              }
           }
        }

      return added;
     }
  };

CRenkoBuilder g_builder;
SRenkoBrick   g_bricks[];
double        g_brick_size=0.0;
ulong         g_last_tick_msc=0;
double        g_last_price=0.0;
string        g_prefix="";

//+------------------------------------------------------------------+
string ObjName(const string suffix)
  {
   return g_prefix+suffix;
  }

//+------------------------------------------------------------------+
void DeleteObjects(void)
  {
   for(int i=0;i<7;i++)
      ObjectDelete(0,ObjName("row"+IntegerToString(i)));
   ObjectDelete(0,ObjName("reversal"));
  }

//+------------------------------------------------------------------+
void SetPanelRow(const int row,const string text,const color clr)
  {
   const string name=ObjName("row"+IntegerToString(row));
   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
      ObjectSetString(0,name,OBJPROP_FONT,"Consolas");
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
     }

   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,InpX);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,InpY+row*17);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
  }

//+------------------------------------------------------------------+
void AppendBricks(SRenkoBrick &added[])
  {
   const int n=ArraySize(added);
   if(n<=0)
      return;

   const int old=ArraySize(g_bricks);
   ArrayResize(g_bricks,old+n);
   for(int i=0;i<n;i++)
      g_bricks[old+i]=added[i];

   // We only need recent bricks to count the current run.
   const int keep=2000;
   const int total=ArraySize(g_bricks);
   if(total>keep)
     {
      const int cut=total-keep;
      for(int i=0;i<keep;i++)
         g_bricks[i]=g_bricks[i+cut];
      ArrayResize(g_bricks,keep);
     }
  }

//+------------------------------------------------------------------+
void ProcessPrice(const double price)
  {
   SRenkoBrick added[];
   if(g_builder.PushPrice(price,added)>0)
      AppendBricks(added);
  }

//+------------------------------------------------------------------+
void LoadTickHistory(void)
  {
   if(InpHistoryTicks<=0)
      return;

   MqlTick ticks[];
   ResetLastError();
   const int count=CopyTicks(_Symbol,ticks,COPY_TICKS_ALL,0,(uint)InpHistoryTicks);
   if(count<=0)
     {
      Print("GDS Renko Reversal Context: tick history is not available yet. Error ",GetLastError());
      return;
     }

   for(int i=0;i<count;i++)
     {
      const double price=(ticks[i].bid>0.0 ? ticks[i].bid : ticks[i].last);
      if(price>0.0)
         ProcessPrice(price);
     }

   g_last_tick_msc=ticks[count-1].time_msc;
   g_last_price=(ticks[count-1].bid>0.0 ? ticks[count-1].bid : ticks[count-1].last);
  }

//+------------------------------------------------------------------+
int CurrentRun(void)
  {
   const int total=ArraySize(g_bricks);
   if(total<=0)
      return 0;

   const int dir=g_bricks[total-1].direction;
   int run=0;
   for(int i=total-1;i>=0;i--)
     {
      if(g_bricks[i].direction!=dir)
         break;
      run++;
     }
   return run;
  }

//+------------------------------------------------------------------+
bool GetContext(int &direction,double &last_close,double &reversal_level)
  {
   const int total=ArraySize(g_bricks);
   if(total<=0 || g_brick_size<=0.0)
      return false;

   direction=g_bricks[total-1].direction;
   last_close=g_bricks[total-1].close;

   if(direction>0)
      reversal_level=last_close-2.0*g_brick_size;
   else if(direction<0)
      reversal_level=last_close+2.0*g_brick_size;
   else
      return false;

   return true;
  }

//+------------------------------------------------------------------+
void UpdatePanel(void)
  {
   int direction=0;
   double last_close=0.0;
   double reversal=0.0;

   SetPanelRow(0,"RENKO CONTEXT",clrSilver);

   if(!GetContext(direction,last_close,reversal))
     {
      SetPanelRow(1,"Waiting for first brick...",clrSilver);
      for(int i=2;i<7;i++)
         SetPanelRow(i,"",clrSilver);
      ObjectDelete(0,ObjName("reversal"));
      return;
     }

   MqlTick tick;
   double live_price=last_close;
   if(SymbolInfoTick(_Symbol,tick))
      live_price=(tick.bid>0.0 ? tick.bid : tick.last);

   const int run=CurrentRun();
   const double distance_bricks=MathAbs(live_price-reversal)/g_brick_size;
   const string dir_text=(direction>0 ? "UP" : "DOWN");
   const color dir_color=(direction>0 ? InpUpColor : InpDownColor);

   SetPanelRow(1,"Run:              "+dir_text+" x"+IntegerToString(run),dir_color);
   SetPanelRow(2,"Brick:            "+DoubleToString(g_brick_size,_Digits),clrSilver);
   SetPanelRow(3,"Renko close:      "+DoubleToString(last_close,_Digits),clrSilver);
   SetPanelRow(4,"Price:            "+DoubleToString(live_price,_Digits),clrSilver);
   SetPanelRow(5,"2-brick reversal: "+DoubleToString(reversal,_Digits),InpReversalColor);
   SetPanelRow(6,"Distance:         "+DoubleToString(distance_bricks,2)+" bricks",clrSilver);

   const string line=ObjName("reversal");
   if(!InpShowReversalLine)
     {
      ObjectDelete(0,line);
      return;
     }

   if(ObjectFind(0,line)<0)
     {
      ObjectCreate(0,line,OBJ_HLINE,0,0,reversal);
      ObjectSetInteger(0,line,OBJPROP_COLOR,InpReversalColor);
      ObjectSetInteger(0,line,OBJPROP_STYLE,STYLE_DASH);
      ObjectSetInteger(0,line,OBJPROP_WIDTH,1);
      ObjectSetInteger(0,line,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,line,OBJPROP_HIDDEN,true);
     }
   ObjectSetDouble(0,line,OBJPROP_PRICE,reversal);
   ObjectSetString(0,line,OBJPROP_TOOLTIP,
                   "Classic Renko 2-brick reversal closes here: "+DoubleToString(reversal,_Digits));
  }

//+------------------------------------------------------------------+
void ProcessLatestTick(void)
  {
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick))
      return;

   const double price=(tick.bid>0.0 ? tick.bid : tick.last);
   if(price<=0.0)
      return;

   // Different prices may occasionally share the same millisecond stamp.
   if(tick.time_msc==g_last_tick_msc && price==g_last_price)
      return;

   ProcessPrice(price);
   g_last_tick_msc=tick.time_msc;
   g_last_price=price;
  }

//+------------------------------------------------------------------+
int OnInit(void)
  {
   if(InpBrickSize<=0.0)
     {
      Print("GDS Renko Reversal Context: InpBrickSize must be greater than zero.");
      return INIT_PARAMETERS_INCORRECT;
     }

   g_prefix="GDS_RRC_"+IntegerToString((int)ChartID())+"_";
   g_brick_size=InpBrickSize;
   ArrayResize(g_bricks,0);
   g_builder.Init(g_brick_size);

   IndicatorSetString(INDICATOR_SHORTNAME,
                      "GDS Renko Reversal Context ("+DoubleToString(InpBrickSize,_Digits)+")");

   DeleteObjects();
   LoadTickHistory();
   ProcessLatestTick();
   UpdatePanel();

   EventSetTimer(1);
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   DeleteObjects();
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
void OnTimer(void)
  {
   ProcessLatestTick();
   UpdatePanel();
   ChartRedraw(0);
  }

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
   ProcessLatestTick();
   UpdatePanel();
   return rates_total;
  }
//+------------------------------------------------------------------+

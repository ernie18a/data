//+------------------------------------------------------------------+
//|                                       GDS_Renko_Bricks_v1.05.mq5 |
//|                                  Golden Delta - CodeBase Edition |
//|                                       https://goldendeltaea.com/ |
//+------------------------------------------------------------------+
#property copyright "Golden Delta"
#property link      "https://goldendeltaea.com/"
#property version   "1.05"
#property description "Draws classic fixed-size Renko bricks directly in an MT5 chart."
#property description "Bricks have equal visual width and update in real time from ticks."
#property description "No external libraries, DLLs or custom symbols are required."
#property indicator_chart_window
#property indicator_plots 0

//--- The only user setting.
input double InpBrickSize = 1.00; // Brick size in price units

//--- Internal settings intentionally kept fixed for a simple CodeBase tool.
#define GDS_HISTORY_TICKS      200000
#define GDS_MAX_BRICKS            300
#define GDS_BRICK_WIDTH_PX          9
#define GDS_RIGHT_MARGIN_PX        64
#define GDS_LEFT_MARGIN_PX          8

const color GDS_UP_COLOR     = clrDeepSkyBlue;
const color GDS_DOWN_COLOR   = clrTomato;
const color GDS_BORDER_COLOR = clrBlack;

//+------------------------------------------------------------------+
//| One completed Renko brick.                                      |
//+------------------------------------------------------------------+
struct SRenkoBrick
  {
   double open;
   double close;
   int    direction; // +1 up, -1 down
   long   serial;
  };

//+------------------------------------------------------------------+
//| Minimal classic fixed-size Renko builder.                        |
//| Continuation: 1 brick. Reversal: 2 bricks from last close.       |
//+------------------------------------------------------------------+
class CRenkoBuilder
  {
private:
   double m_size;
   bool   m_has_anchor;
   double m_anchor;
   double m_last_close;
   int    m_last_dir;

   void AddBrick(SRenkoBrick &out[],
                 const double open_price,
                 const double close_price,
                 const int direction)
     {
      const int n=ArraySize(out);
      ArrayResize(out,n+1);
      out[n].open=NormalizeDouble(open_price,_Digits);
      out[n].close=NormalizeDouble(close_price,_Digits);
      out[n].direction=direction;
      out[n].serial=0;
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
            const double brick_open=m_anchor;
            m_anchor+=m_size;
            m_last_close=m_anchor;
            m_last_dir=+1;
            AddBrick(out,brick_open,m_last_close,+1);
            added++;
           }

         while(price<=m_anchor-m_size)
           {
            const double brick_open=m_anchor;
            m_anchor-=m_size;
            m_last_close=m_anchor;
            m_last_dir=-1;
            AddBrick(out,brick_open,m_last_close,-1);
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
            // Up continuation: one full brick above the last close.
            if(price>=m_last_close+m_size)
              {
               const double brick_open=m_last_close;
               const double brick_close=m_last_close+m_size;
               AddBrick(out,brick_open,brick_close,+1);
               m_last_close=brick_close;
               added++;
               changed=true;
              }
            // Down reversal: two bricks from the last close.
            else if(price<=m_last_close-2.0*m_size)
              {
               const double brick_open=m_last_close-m_size;
               const double brick_close=m_last_close-2.0*m_size;
               AddBrick(out,brick_open,brick_close,-1);
               m_last_close=brick_close;
               m_last_dir=-1;
               added++;
               changed=true;
              }
           }
         else
           {
            // Down continuation: one full brick below the last close.
            if(price<=m_last_close-m_size)
              {
               const double brick_open=m_last_close;
               const double brick_close=m_last_close-m_size;
               AddBrick(out,brick_open,brick_close,-1);
               m_last_close=brick_close;
               added++;
               changed=true;
              }
            // Up reversal: two bricks from the last close.
            else if(price>=m_last_close+2.0*m_size)
              {
               const double brick_open=m_last_close+m_size;
               const double brick_close=m_last_close+2.0*m_size;
               AddBrick(out,brick_open,brick_close,+1);
               m_last_close=brick_close;
               m_last_dir=+1;
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
string        g_prefix="";
long          g_next_serial=1;
ulong         g_last_tick_msc=0;
double        g_last_price=0.0;
bool          g_history_ready=false;
int           g_history_attempts=0;
int           g_last_chart_width=0;
int           g_last_chart_height=0;

//--- Original chart appearance. Restored when the indicator is removed.
bool   g_chart_style_saved=false;
long   g_saved_chart_up=0;
long   g_saved_chart_down=0;
long   g_saved_candle_bull=0;
long   g_saved_candle_bear=0;
long   g_saved_chart_line=0;
long   g_saved_chart_foreground=0;
long   g_saved_show_grid=0;
long   g_saved_show_date_scale=0;
long   g_saved_show_price_scale=0;
long   g_saved_scale_fix=0;
double g_saved_fixed_min=0.0;
double g_saved_fixed_max=0.0;

//+------------------------------------------------------------------+
bool SaveChartStyle(void)
  {
   bool ok=true;
   if(!ChartGetInteger(0,CHART_COLOR_CHART_UP,0,g_saved_chart_up)) ok=false;
   if(!ChartGetInteger(0,CHART_COLOR_CHART_DOWN,0,g_saved_chart_down)) ok=false;
   if(!ChartGetInteger(0,CHART_COLOR_CANDLE_BULL,0,g_saved_candle_bull)) ok=false;
   if(!ChartGetInteger(0,CHART_COLOR_CANDLE_BEAR,0,g_saved_candle_bear)) ok=false;
   if(!ChartGetInteger(0,CHART_COLOR_CHART_LINE,0,g_saved_chart_line)) ok=false;
   if(!ChartGetInteger(0,CHART_FOREGROUND,0,g_saved_chart_foreground)) ok=false;
   if(!ChartGetInteger(0,CHART_SHOW_GRID,0,g_saved_show_grid)) ok=false;
   if(!ChartGetInteger(0,CHART_SHOW_DATE_SCALE,0,g_saved_show_date_scale)) ok=false;
   if(!ChartGetInteger(0,CHART_SHOW_PRICE_SCALE,0,g_saved_show_price_scale)) ok=false;
   if(!ChartGetInteger(0,CHART_SCALEFIX,0,g_saved_scale_fix)) ok=false;
   if(!ChartGetDouble(0,CHART_FIXED_MIN,0,g_saved_fixed_min)) ok=false;
   if(!ChartGetDouble(0,CHART_FIXED_MAX,0,g_saved_fixed_max)) ok=false;
   g_chart_style_saved=ok;
   return ok;
  }

//+------------------------------------------------------------------+
void PrepareRenkoChart(void)
  {
   long bg=0;
   if(!ChartGetInteger(0,CHART_COLOR_BACKGROUND,0,bg))
      bg=(long)clrBlack;

   // Hide the host chart price drawing. The chart remains only a container.
   ChartSetInteger(0,CHART_COLOR_CHART_UP,bg);
   ChartSetInteger(0,CHART_COLOR_CHART_DOWN,bg);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,bg);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,bg);
   ChartSetInteger(0,CHART_COLOR_CHART_LINE,bg);
   ChartSetInteger(0,CHART_FOREGROUND,false);
   ChartSetInteger(0,CHART_SHOW_GRID,false);

   // Classic Renko has no meaningful time axis. Keep only the price scale.
   ChartSetInteger(0,CHART_SHOW_DATE_SCALE,false);
   ChartSetInteger(0,CHART_SHOW_PRICE_SCALE,true);
  }

//+------------------------------------------------------------------+
void RestoreChartStyle(void)
  {
   if(!g_chart_style_saved)
      return;

   ChartSetInteger(0,CHART_COLOR_CHART_UP,g_saved_chart_up);
   ChartSetInteger(0,CHART_COLOR_CHART_DOWN,g_saved_chart_down);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,g_saved_candle_bull);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,g_saved_candle_bear);
   ChartSetInteger(0,CHART_COLOR_CHART_LINE,g_saved_chart_line);
   ChartSetInteger(0,CHART_FOREGROUND,g_saved_chart_foreground);
   ChartSetInteger(0,CHART_SHOW_GRID,g_saved_show_grid);
   ChartSetInteger(0,CHART_SHOW_DATE_SCALE,g_saved_show_date_scale);
   ChartSetInteger(0,CHART_SHOW_PRICE_SCALE,g_saved_show_price_scale);
   ChartSetDouble(0,CHART_FIXED_MIN,g_saved_fixed_min);
   ChartSetDouble(0,CHART_FIXED_MAX,g_saved_fixed_max);
   ChartSetInteger(0,CHART_SCALEFIX,g_saved_scale_fix);
  }

//+------------------------------------------------------------------+
string BrickName(const long serial)
  {
   return g_prefix+"brick_"+IntegerToString((int)serial);
  }

//+------------------------------------------------------------------+
void DeleteAllObjects(void)
  {
   ObjectsDeleteAll(0,g_prefix,-1,-1);
  }

//+------------------------------------------------------------------+
void DrawHeader(const int visible_count)
  {
   const string name=g_prefix+"header";

   if(ObjectFind(0,name)<0)
     {
      if(!ObjectCreate(0,name,OBJ_LABEL,0,0,0))
         return;
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,GDS_RIGHT_MARGIN_PX+8);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,24);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,9);
      ObjectSetString(0,name,OBJPROP_FONT,"Consolas");
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
     }

   long fg=0;
   if(!ChartGetInteger(0,CHART_COLOR_FOREGROUND,0,fg))
      fg=(long)clrSilver;

   ObjectSetInteger(0,name,OBJPROP_COLOR,(color)fg);

   string text="RENKO BRICKS  |  Brick: "+DoubleToString(InpBrickSize,_Digits);
   if(!g_history_ready)
      text="RENKO BRICKS  |  Loading tick history...";

   ObjectSetString(0,name,OBJPROP_TEXT,text);
  }

//+------------------------------------------------------------------+
//| Map a chart price to Y pixels using the chart's current scale.   |
//+------------------------------------------------------------------+
bool PriceToY(const double price,int &y)
  {
   const int width=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);
   const int height=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0);
   if(width<=0 || height<=0)
      return false;

   int subwindow=0;
   datetime ref_time=0;
   double ref_price=0.0;

   // Obtain any time coordinate that is guaranteed to be inside the visible chart.
   if(!ChartXYToTimePrice(0,width/2,height/2,subwindow,ref_time,ref_price))
      return false;

   int x_dummy=0;
   return ChartTimePriceToXY(0,0,ref_time,price,x_dummy,y);
  }

//+------------------------------------------------------------------+
//| Classic visual layout. X is screen space, not chart time.        |
//+------------------------------------------------------------------+
void DrawAllBricks(void)
  {
   DeleteAllObjects();

   const int total=ArraySize(g_bricks);
   const int chart_width=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);
   const int chart_height=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0);
   g_last_chart_width=chart_width;
   g_last_chart_height=chart_height;

   if(total<=0 || chart_width<=GDS_RIGHT_MARGIN_PX+GDS_LEFT_MARGIN_PX+GDS_BRICK_WIDTH_PX)
     {
      DrawHeader(0);
      ChartRedraw(0);
      return;
     }

   const int drawable_width=chart_width-GDS_RIGHT_MARGIN_PX-GDS_LEFT_MARGIN_PX;
   int visible_count=drawable_width/GDS_BRICK_WIDTH_PX;
   if(visible_count<1)
      visible_count=1;
   if(visible_count>total)
      visible_count=total;

   const int first=total-visible_count;

   // Fit the price scale to the bricks currently visible on screen.
   double min_price=DBL_MAX;
   double max_price=-DBL_MAX;
   for(int i=first;i<total;i++)
     {
      min_price=MathMin(min_price,MathMin(g_bricks[i].open,g_bricks[i].close));
      max_price=MathMax(max_price,MathMax(g_bricks[i].open,g_bricks[i].close));
     }

   if(min_price==DBL_MAX || max_price==-DBL_MAX)
     {
      DrawHeader(0);
      ChartRedraw(0);
      return;
     }

   const double padding=2.0*InpBrickSize;
   double fixed_min=min_price-padding;
   double fixed_max=max_price+padding;
   if(fixed_max<=fixed_min)
      fixed_max=fixed_min+4.0*InpBrickSize;

   ChartSetInteger(0,CHART_SCALEFIX,true);
   ChartSetDouble(0,CHART_FIXED_MIN,fixed_min);
   ChartSetDouble(0,CHART_FIXED_MAX,fixed_max);
   ChartRedraw(0);

   // Keep the last brick at the right edge of the drawable area.
   const int right_edge=chart_width-GDS_RIGHT_MARGIN_PX;
   const int start_x=right_edge-visible_count*GDS_BRICK_WIDTH_PX;

   for(int i=first;i<total;i++)
     {
      const SRenkoBrick brick=g_bricks[i];
      const double top=MathMax(brick.open,brick.close);
      const double bottom=MathMin(brick.open,brick.close);

      int y_top=0;
      int y_bottom=0;
      if(!PriceToY(top,y_top) || !PriceToY(bottom,y_bottom))
         continue;

      int y=MathMin(y_top,y_bottom);
      int h=MathAbs(y_bottom-y_top);
      if(h<2)
         h=2;

      const int slot=i-first;
      const int x=start_x+slot*GDS_BRICK_WIDTH_PX;
      const string name=BrickName(brick.serial);
      const color fill=(brick.direction>0 ? GDS_UP_COLOR : GDS_DOWN_COLOR);

      if(!ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0))
         continue;

      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(0,name,OBJPROP_XSIZE,GDS_BRICK_WIDTH_PX);
      ObjectSetInteger(0,name,OBJPROP_YSIZE,h);
      ObjectSetInteger(0,name,OBJPROP_BGCOLOR,fill);
      ObjectSetInteger(0,name,OBJPROP_COLOR,GDS_BORDER_COLOR);
      ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
      ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
      ObjectSetInteger(0,name,OBJPROP_BACK,false);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetString(0,name,OBJPROP_TOOLTIP,
                      (brick.direction>0 ? "UP" : "DOWN")+" Renko brick: "+
                      DoubleToString(brick.open,_Digits)+" -> "+
                      DoubleToString(brick.close,_Digits));
     }

   DrawHeader(visible_count);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
void TrimToMaximum(void)
  {
   const int total=ArraySize(g_bricks);
   if(total<=GDS_MAX_BRICKS)
      return;

   const int remove_count=total-GDS_MAX_BRICKS;
   for(int i=0;i<GDS_MAX_BRICKS;i++)
      g_bricks[i]=g_bricks[i+remove_count];

   ArrayResize(g_bricks,GDS_MAX_BRICKS);
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
     {
      added[i].serial=g_next_serial++;
      g_bricks[old+i]=added[i];
     }

   TrimToMaximum();
  }

//+------------------------------------------------------------------+
bool ProcessPrice(const double price)
  {
   SRenkoBrick added[];
   if(g_builder.PushPrice(price,added)<=0)
      return false;

   AppendBricks(added);
   return true;
  }

//+------------------------------------------------------------------+
bool LoadTickHistory(void)
  {
   g_history_attempts++;

   MqlTick ticks[];
   ResetLastError();
   const int count=CopyTicks(_Symbol,ticks,COPY_TICKS_ALL,0,GDS_HISTORY_TICKS);
   if(count<=0)
     {
      g_history_ready=false;
      DrawHeader(0);
      ChartRedraw(0);
      if(g_history_attempts==1 || (g_history_attempts%10)==0)
         Print("GDS Renko Bricks: waiting for tick history. Error ",GetLastError());
      return false;
     }

   DeleteAllObjects();
   ArrayResize(g_bricks,0);
   g_builder.Init(InpBrickSize);
   g_next_serial=1;
   g_last_tick_msc=0;
   g_last_price=0.0;

   for(int i=0;i<count;i++)
     {
      const double price=(ticks[i].bid>0.0 ? ticks[i].bid : ticks[i].last);
      if(price>0.0)
         ProcessPrice(price);
     }

   g_last_tick_msc=ticks[count-1].time_msc;
   g_last_price=(ticks[count-1].bid>0.0 ? ticks[count-1].bid : ticks[count-1].last);
   g_history_ready=true;
   TrimToMaximum();
   DrawAllBricks();
   return true;
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

   // OnCalculate and OnTimer can observe the same tick.
   if(tick.time_msc==g_last_tick_msc && price==g_last_price)
      return;

   const bool new_brick=ProcessPrice(price);
   g_last_tick_msc=tick.time_msc;
   g_last_price=price;

   if(new_brick)
      DrawAllBricks();
  }

//+------------------------------------------------------------------+
void CheckChartSize(void)
  {
   const int width=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);
   const int height=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0);
   if(width<=0 || height<=0)
      return;

   if(width!=g_last_chart_width || height!=g_last_chart_height)
      DrawAllBricks();
  }

//+------------------------------------------------------------------+
int OnInit(void)
  {
   if(InpBrickSize<=0.0)
     {
      Print("GDS Renko Bricks: Brick Size must be greater than zero.");
      return INIT_PARAMETERS_INCORRECT;
     }

   g_prefix="GDS_RB_"+IntegerToString((int)ChartID())+"_";

   if(SaveChartStyle())
      PrepareRenkoChart();
   else
      Print("GDS Renko Bricks: could not save all chart properties.");

   g_next_serial=1;
   g_last_tick_msc=0;
   g_last_price=0.0;
   g_history_ready=false;
   g_history_attempts=0;
   g_last_chart_width=0;
   g_last_chart_height=0;
   ArrayResize(g_bricks,0);
   g_builder.Init(InpBrickSize);

   IndicatorSetString(INDICATOR_SHORTNAME,
                      "GDS Renko Bricks ("+DoubleToString(InpBrickSize,_Digits)+")");

   DeleteAllObjects();
   DrawHeader(0);
   LoadTickHistory();
   ProcessLatestTick();

   EventSetTimer(1);
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   DeleteAllObjects();
   RestoreChartStyle();
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
void OnTimer(void)
  {
   if(!g_history_ready)
     {
      LoadTickHistory();
      if(!g_history_ready)
         return;
     }

   ProcessLatestTick();
   CheckChartSize();
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
   if(g_history_ready)
      ProcessLatestTick();
   return rates_total;
  }
//+------------------------------------------------------------------+

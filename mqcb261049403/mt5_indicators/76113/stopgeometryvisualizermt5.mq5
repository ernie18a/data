//+------------------------------------------------------------------+
//|                                    StopGeometryVisualizerMT5.mq5 |
//| Read-only chart references for broker Stops and Freeze Levels.   |
//+------------------------------------------------------------------+
#property copyright "Usamah"
#property link      "https://www.mql5.com/en/users/usamah41"
#property version   "1.00"
#property description "Read-only Stops Level and Freeze Level chart visualizer for MT5."
#property indicator_chart_window
#property indicator_plots   0
#property indicator_buffers 0

input int   InpRefreshSeconds        = 2;          // Timer refresh interval
input bool  InpShowStopReferences    = true;       // Show Stops Level reference lines
input bool  InpShowFreezeReferences  = true;       // Show Freeze Level reference lines
input bool  InpPrintChanges          = true;       // Print specification changes to Journal
input color InpUpperStopColor        = clrLimeGreen;
input color InpLowerStopColor        = clrTomato;
input color InpFreezeColor           = clrDarkOrange;

string PREFIX="SGV_";
long   last_stops=-1;
long   last_freeze=-1;
double last_tick_size=-1.0;
double last_volume_step=-1.0;

//+------------------------------------------------------------------+
double NormalizePrice(const string symbol,const double price)
  {
   const double tick_size=SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);
   if(tick_size<=0.0)
      return price;
   return MathRound(price/tick_size)*tick_size;
  }

//+------------------------------------------------------------------+
void DeleteLine(const string suffix)
  {
   ObjectDelete(0,PREFIX+suffix);
  }

//+------------------------------------------------------------------+
void SetLine(const string suffix,const double price,const color line_color,
             const ENUM_LINE_STYLE style,const int width)
  {
   const string name=PREFIX+suffix;
   if(ObjectFind(0,name)<0)
     {
      if(!ObjectCreate(0,name,OBJ_HLINE,0,0,price))
        {
         PrintFormat("Stop Geometry Visualizer: ObjectCreate failed for %s, error=%d",name,GetLastError());
         return;
        }
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_BACK,false);
     }
   ObjectSetDouble(0,name,OBJPROP_PRICE,price);
   ObjectSetInteger(0,name,OBJPROP_COLOR,line_color);
   ObjectSetInteger(0,name,OBJPROP_STYLE,style);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
  }

//+------------------------------------------------------------------+
void DeleteVisuals()
  {
   DeleteLine("STOP_UPPER");
   DeleteLine("STOP_LOWER");
   DeleteLine("FREEZE_UPPER");
   DeleteLine("FREEZE_LOWER");
  }

//+------------------------------------------------------------------+
void LogSpecificationChange(const string symbol,const long stops_level,
                            const long freeze_level,const double tick_size,
                            const double volume_step)
  {
   if(!InpPrintChanges)
      return;
   if(stops_level==last_stops && freeze_level==last_freeze &&
      MathAbs(tick_size-last_tick_size)<1.0e-12 &&
      MathAbs(volume_step-last_volume_step)<1.0e-12)
      return;

   PrintFormat("SGV specification: %s stops=%d freeze=%d tick_size=%.10f volume_step=%.8f",
               symbol,(int)stops_level,(int)freeze_level,tick_size,volume_step);
  }

//+------------------------------------------------------------------+
void UpdateVisuals()
  {
   const string symbol=_Symbol;
   MqlTick tick={};
   if(!SymbolInfoTick(symbol,tick) || tick.bid<=0.0 || tick.ask<=0.0)
     {
      Comment("STOP GEOMETRY VISUALIZER MT5 | READ ONLY\nWaiting for a valid broker tick...");
      return;
     }

   const int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   const double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
   const double tick_size=SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);
   const double volume_min=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
   const double volume_max=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
   const double volume_step=SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);
   const long stops_level=SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL);
   const long freeze_level=SymbolInfoInteger(symbol,SYMBOL_TRADE_FREEZE_LEVEL);
   const long filling_mode=SymbolInfoInteger(symbol,SYMBOL_FILLING_MODE);
   const double stops_distance=stops_level*point;
   const double freeze_distance=freeze_level*point;

   LogSpecificationChange(symbol,stops_level,freeze_level,tick_size,volume_step);
   last_stops=stops_level;
   last_freeze=freeze_level;
   last_tick_size=tick_size;
   last_volume_step=volume_step;

   const double stop_upper=NormalizePrice(symbol,tick.ask+stops_distance);
   const double stop_lower=NormalizePrice(symbol,tick.bid-stops_distance);
   const double freeze_upper=NormalizePrice(symbol,tick.ask+freeze_distance);
   const double freeze_lower=NormalizePrice(symbol,tick.bid-freeze_distance);

   if(InpShowStopReferences && stops_level>0)
     {
      SetLine("STOP_UPPER",stop_upper,InpUpperStopColor,STYLE_SOLID,2);
      SetLine("STOP_LOWER",stop_lower,InpLowerStopColor,STYLE_SOLID,2);
     }
   else
     {
      DeleteLine("STOP_UPPER");
      DeleteLine("STOP_LOWER");
     }

   if(InpShowFreezeReferences && freeze_level>0)
     {
      SetLine("FREEZE_UPPER",freeze_upper,InpFreezeColor,STYLE_DASH,1);
      SetLine("FREEZE_LOWER",freeze_lower,InpFreezeColor,STYLE_DASH,1);
     }
   else
     {
      DeleteLine("FREEZE_UPPER");
      DeleteLine("FREEZE_LOWER");
     }

   const double spread_points=(point>0.0 ? (tick.ask-tick.bid)/point : 0.0);
   string text="STOP GEOMETRY VISUALIZER MT5 | READ ONLY\n";
   text+=StringFormat("%s | Bid %.*f | Ask %.*f | Spread %.1f points\n",
                      symbol,digits,tick.bid,digits,tick.ask,spread_points);
   text+=StringFormat("Stops Level: %d points (%.*f) | Freeze Level: %d points (%.*f)\n",
                      (int)stops_level,digits,stops_distance,
                      (int)freeze_level,digits,freeze_distance);
   if(stops_level>0)
     {
      text+=StringFormat("Upper stop reference: %.*f | BUY STOP / SELL SL side\n",digits,stop_upper);
      text+=StringFormat("Lower stop reference: %.*f | SELL STOP / BUY SL side\n",digits,stop_lower);
     }
   else
      text+="Stops Level is zero in the current broker specification.\n";
   if(freeze_level>0)
      text+=StringFormat("Freeze references: %.*f / %.*f\n",digits,freeze_upper,digits,freeze_lower);
   else
      text+="Freeze Level is zero in the current broker specification.\n";
   text+=StringFormat("Tick size: %.*f | Volume min/step/max: %.4f / %.4f / %.4f | Filling flags: %d\n",
                      digits,tick_size,volume_min,volume_step,volume_max,(int)filling_mode);
   text+="References are diagnostics, not order approval. Recheck direction-specific rules with OrderCheck.";
   Comment(text);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpRefreshSeconds<1)
     {
      Print("Stop Geometry Visualizer: refresh interval must be at least one second.");
      return INIT_PARAMETERS_INCORRECT;
     }
   IndicatorSetString(INDICATOR_SHORTNAME,"Stop Geometry Visualizer MT5");
   EventSetTimer(InpRefreshSeconds);
   UpdateVisuals();
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   DeleteVisuals();
   Comment("");
  }

//+------------------------------------------------------------------+
void OnTimer()
  {
   UpdateVisuals();
  }

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &time[],const double &open[],
                const double &high[],const double &low[],
                const double &close[],const long &tick_volume[],
                const long &volume[],const int &spread[])
  {
   UpdateVisuals();
   return rates_total;
  }
//+------------------------------------------------------------------+

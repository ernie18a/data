//+------------------------------------------------------------------+
//|                                                candle-colors.mq5 |
//|                                        Copyright 2026, sef - jkt |
//|                              https://www.mql5.com/en/users/seffx |
//+------------------------------------------------------------------+
#define VERSION "260.125"
#property version   VERSION
#property strict
#property copyright "(C) 2026, seffx"
#property link      "https://www.mql5.com/en/users/seffx"
#property description "candle-colors\nversion " VERSION "-1\n\nDISCLAIMER:\n"
"This tool is provided \"AS IS\", use it on your own risks.\n"
"No warranty, no liability.\n"
"Binary trading is an extremely high-risk financial activity.\n"
"Please be aware of your local legal requirements."

#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0
//--- input parameters
sinput uint    expire = 0; // Expire in secs, 5, 60 .. 3600; 0: default
sinput ulong   amount = 0; // Amount to trade, 0: default
sinput bool    inverted=false;   // Inverted trade
sinput bool    call_enabled=true; // CALL enable
sinput bool    put_enabled=true; // PUT enable
sinput string  mt5_trade_name = "ZCRYIDX_5"; // MT5 global variable


int last_bars;
string _mt5_trade_name;
string _mt5_trade_name_expire;
string _mt5_trade_name_amount;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   last_bars = 0;
   _mt5_trade_name = mt5_trade_name;
   StringTrimLeft(_mt5_trade_name);
   StringTrimRight(_mt5_trade_name);
   if(_mt5_trade_name != "")
     {
      _mt5_trade_name_expire = _mt5_trade_name + "_EXPIRE";
      _mt5_trade_name_amount = _mt5_trade_name + "_AMOUNT";
      GlobalVariableTemp(_mt5_trade_name);
      GlobalVariableTemp(_mt5_trade_name_expire);
      GlobalVariableTemp(_mt5_trade_name_amount);
     }
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int candle_color(uint bar, const double &open[], const double &close[])
  {
   double diff = close[bar] - open[bar];
   if(MathAbs(diff) <= DBL_EPSILON)
      return 0; // "DOJI"
   if(diff > 0)
      return 1; // "BULL"
   return -1; // "BEAR"
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int32_t rates_total,
                const int32_t prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int32_t &spread[])
  {
   if(rates_total < 12)
      return rates_total;
   if(last_bars == rates_total)
      return rates_total;
   last_bars = rates_total;
   ArraySetAsSeries(time, true);
   const uint secs = (uint)(time[0] % 60);
   int t = 25 - (int)secs;
   if(t < 0)
      t += 60;
   if(secs <= 25)
      Comment(StringFormat("CANDLE COLORS: %s (%d)", TimeToString(time[0], TIME_SECONDS), t));
   if(secs != 25)
      return rates_total;
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(close, true);
   string order = "SKIP";
   int bulls = 0;
   int bears = 0;
   int dojis = 0;
   double mt5_order = 0;
   for(int i=0;i<12;i++)
     {
      const int candle = candle_color(i, open, close);
      if(candle > 0)
         bulls++;
      else
         if(candle < 0)
            bears++;
         else
            dojis++;
     }
   if((bears + bulls) > 0)
     {
      if(inverted)
        {
         int delta = bears - bulls;
         if(call_enabled && (delta >= 1))
           {
            mt5_order = +1;
            order = "CALL";
           }
         else
           {
            delta = bulls - bears;
            if(put_enabled && (delta >= 1))
              {
               mt5_order = -1;
               order = "PUT";
              }
           }
        }
      else
        {
         int delta = bears - bulls;
         if(put_enabled && (delta >= 1))
           {
            mt5_order = -1;
            order = "PUT";
           }
         else
           {
            delta = bulls - bears;
            if(call_enabled && (delta >= 1))
              {
               mt5_order = +1;
               order = "CALL";
              }
           }
        }
     }
   if(mt5_order != 0)
     {
      GlobalVariableSet(_mt5_trade_name_amount, amount);
      GlobalVariableSet(_mt5_trade_name_expire, expire);
      GlobalVariableSet(_mt5_trade_name, mt5_order);
     }

   string msg = StringFormat(
                   "CANDLE COLORS: %s (bears:%d, bulls:%d, dojis:%d) %s",
                   TimeToString(time[0], TIME_SECONDS),
                   bears, bulls, dojis,
                   order
                );

   Comment(msg);
   Print(msg);
   return(rates_total);
  }
//+------------------------------------------------------------------+

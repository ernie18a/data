//+------------------------------------------------------------------+
//|                                              BrokerInfoPanel.mq5 |
//|                         Practical MT5 Broker Information Monitor |
//+------------------------------------------------------------------+
#property copyright "Shahrukh"
#property version   "1.00"
#property description "Displays live spread, tick size/value, volume limits, stop level and freeze level."
#property indicator_chart_window
#property indicator_plots 0

input bool   InpShowSpreadPoints = true;
input bool   InpShowSpreadPrice  = true;
input bool   InpShowTickInfo     = true;
input bool   InpShowVolumeInfo   = true;
input bool   InpShowTradeLevels  = true;
input int    InpRefreshSeconds   = 1;

string BuildPanelText()
{
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick))
      return "Broker Info Panel\nWaiting for tick data...";

   const int    digits       = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   const double point        = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   const double tickSize     = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   const double tickValue    = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   const double volMin       = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   const double volMax       = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   const double volStep      = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   const int    stopsLevel   = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   const int    freezeLevel  = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL);

   const double spreadPrice  = tick.ask - tick.bid;
   const double spreadPoints = (point > 0.0 ? spreadPrice / point : 0.0);

   string text = "Broker Info Panel\n";
   text += "Symbol: " + _Symbol + "\n";
   text += "Bid: " + DoubleToString(tick.bid, digits) +
           "   Ask: " + DoubleToString(tick.ask, digits) + "\n";

   if(InpShowSpreadPoints)
      text += "Spread: " + DoubleToString(spreadPoints, 1) + " points\n";

   if(InpShowSpreadPrice)
      text += "Spread Price: " + DoubleToString(spreadPrice, digits) + "\n";

   if(InpShowTickInfo)
   {
      text += "Tick Size: " + DoubleToString(tickSize, digits) + "\n";
      text += "Tick Value: " + DoubleToString(tickValue, 2) + "\n";
   }

   if(InpShowVolumeInfo)
   {
      text += "Volume Min: " + DoubleToString(volMin, 2) + "\n";
      text += "Volume Max: " + DoubleToString(volMax, 2) + "\n";
      text += "Volume Step: " + DoubleToString(volStep, 2) + "\n";
   }

   if(InpShowTradeLevels)
   {
      text += "Stops Level: " + IntegerToString(stopsLevel) + " points\n";
      text += "Freeze Level: " + IntegerToString(freezeLevel) + " points\n";
   }

   return text;
}

int OnInit()
{
   int refresh = InpRefreshSeconds;
   if(refresh < 1)
      refresh = 1;

   EventSetTimer(refresh);
   Comment(BuildPanelText());

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   Comment("");
}

void OnTimer()
{
   Comment(BuildPanelText());
}

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
   Comment(BuildPanelText());
   return rates_total;
}
//+------------------------------------------------------------------+

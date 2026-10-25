//+------------------------------------------------------------------+
//|                                             Exposure_Monitor.mq5 |
//|                                         Copyright 2026, Amanda V |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Amanda V"
#property link      "https://forge.mql5.io"
#property version   "4.05"
#property indicator_chart_window
#property indicator_plots 0

//--- Inputs
input group "=== Risk Settings ==="
input double InpWarningThreshold = 3.0;     // Warning Threshold (Net Lots)

input group "=== Dashboard Visuals ==="
input ENUM_BASE_CORNER InpCorner = CORNER_LEFT_UPPER; // Dashboard Corner
input int    InpXOffset          = 20;      // X Offset
input int    InpYOffset          = 30;      // Y Offset
input color  InpColorText        = clrWhite; // Text Color
input color  InpColorWarn        = clrRed;   // Warning Color

//--- Arrays for currency tracking
string currencies[] = {"USD", "EUR", "GBP", "JPY", "CHF", "AUD", "CAD", "NZD"};
double net_exposure[8];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetTimer(1); 
   Print("Institutional Currency Exposure Monitor Initialized.");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   Comment("");
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ArrayInitialize(net_exposure, 0.0);
   
   // Scan all open positions
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
        {
         string sym = PositionGetString(POSITION_SYMBOL);
         double vol = PositionGetDouble(POSITION_VOLUME);
         long type  = PositionGetInteger(POSITION_TYPE);
         
         // Basic extraction of Base and Quote currencies (Assuming 6 char symbols like EURUSD)
         if(StringLen(sym) >= 6)
           {
            string base_curr  = StringSubstr(sym, 0, 3);
            string quote_curr = StringSubstr(sym, 3, 3);
            
            double dir_base  = (type == POSITION_TYPE_BUY) ? vol : -vol;
            double dir_quote = (type == POSITION_TYPE_BUY) ? -vol : vol;
            
            // Add to totals
            for(int c = 0; c < 8; c++)
              {
               if(base_curr == currencies[c]) net_exposure[c] += dir_base;
               if(quote_curr == currencies[c]) net_exposure[c] += dir_quote;
              }
           }
        }
     }
     
   // Build Dashboard String
   string dash = "=== INSTITUTIONAL EXPOSURE MONITOR ===\n\n";
   bool has_exposure = false;
   
   for(int c = 0; c < 8; c++)
     {
      if(MathAbs(net_exposure[c]) > 0.001) // Filter out floating point noise
        {
         has_exposure = true;
         string direction = (net_exposure[c] > 0) ? "LONG  " : "SHORT ";
         string warning = (MathAbs(net_exposure[c]) >= InpWarningThreshold) ? " [!] HIGH RISK" : "";
         
         dash += StringFormat("%s: %s | Net Lots: %+.2f%s\n", 
                              currencies[c], direction, net_exposure[c], warning);
        }
     }
     
   if(!has_exposure) dash += "No active currency exposure detected.\n";
   
   dash += "\nThreshold: " + DoubleToString(InpWarningThreshold, 2) + " Lots";
   
   Comment(dash);
  }
//+------------------------------------------------------------------+
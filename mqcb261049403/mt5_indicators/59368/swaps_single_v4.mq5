//+------------------------------------------------------------------+
//|                                                 Swaps_Single.mq5 |
//|                             Copyright 2024,Ryan Lawrence Johnson |
//|                         https://www.mql5.com/en/users/rjo/seller |
//+------------------------------------------------------------------+
#property copyright "© 2024, Ryan Lawrence Johnson"
#property link      "https://www.mql5.com/en/users/rjo/seller"
#property version   "4.00"

#property indicator_chart_window
#property indicator_plots 0

#include <Trade\SymbolInfo.mqh>
CSymbolInfo symbol; // symbol informations object

#include <Arrays\ArrayString.mqh>
CArrayString astring; // string informations object

input string UseSymbol = "GBPJPY"; // 0 means current chart symbol
input int XdistanceL = 70;
input int YdistanceL = 160;
input int XdistanceS = 70;
input int YdistanceS = 200;
input bool ExpertsTab = false;

string Sym;
string SwapL;
string SwapS;
string PswapL;
string PswapS;

double swap_long;
double swap_short;
double norm_swap_long;
double norm_swap_short;

datetime curr_time;

ulong last_time;

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(0, "SwapL");
   ObjectDelete(0, "SwapS");
  }
  
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(UseSymbol == "0")
    {
     Sym = _Symbol;
    }
   else
    {
     Sym = UseSymbol;
    }
   
   // ##### POINTER (.) CAN ONLY BE USED ONCE IN ANY PROJECT #####
   
   //symbol.Name(Sym); // get the object for the chart symbol
   
   //if(symbol.SwapMode() == SYMBOL_SWAP_MODE_POINTS)
    //{     
     //swap_long = swap_value_currency(symbol.SwapLong(), symbol.TickValueProfit(), symbol.TickValueLoss());
     //swap_short = swap_value_currency(symbol.SwapShort(), symbol.TickValueProfit(), symbol.TickValueLoss());
    //}
   
   norm_swap_long = NormalizeDouble(swap_long, 2);
   norm_swap_short = NormalizeDouble(swap_short, 2);
   
   curr_time = TimeCurrent();
   MqlDateTime s_curr_time;
   TimeToStruct(curr_time, s_curr_time);
   
   if(s_curr_time.day_of_week == 3) // Wednesday
    {
     norm_swap_long = NormalizeDouble(swap_long * 3, 2);
     norm_swap_short = NormalizeDouble(swap_short * 3, 2);
    }   
     
   SwapL = "SwapL";
   SwapS = "SwapS";    
	  
	ObjectCreate(0, SwapL, OBJ_LABEL, 0, 0, 0);
	ObjectSetInteger(0, SwapL, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
	ObjectSetInteger(0, SwapL, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);		
	ObjectSetInteger(0, SwapL, OBJPROP_XDISTANCE, XdistanceL);
	ObjectSetInteger(0, SwapL, OBJPROP_YDISTANCE, YdistanceL);
	ObjectSetString(0, SwapL, OBJPROP_FONT, "Arial");
	ObjectSetInteger(0, SwapL, OBJPROP_FONTSIZE, 12);
	ObjectSetInteger(0, SwapL, OBJPROP_COLOR, clrDodgerBlue);
	ObjectSetString(0, SwapL, OBJPROP_TEXT, "Swap Long: " + DoubleToString(norm_swap_long, 2));
	
	ObjectCreate(0, SwapS, OBJ_LABEL, 0, 0, 0);
	ObjectSetInteger(0, SwapS, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
	ObjectSetInteger(0, SwapS, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);		    
	ObjectSetInteger(0, SwapS, OBJPROP_XDISTANCE, XdistanceS);
	ObjectSetInteger(0, SwapS, OBJPROP_YDISTANCE, YdistanceS); 
	ObjectSetString(0, SwapS, OBJPROP_FONT, "Arial");
	ObjectSetInteger(0, SwapS, OBJPROP_FONTSIZE, 12);
	ObjectSetInteger(0, SwapS, OBJPROP_COLOR, clrOrangeRed);
	ObjectSetString(0, SwapS, OBJPROP_TEXT, "Swap Short: " + DoubleToString(norm_swap_short, 2));		
	
  	last_time = (ulong)iTime(Sym, PERIOD_M1, 0);	  	  	     	  
     
//---
   return(INIT_SUCCEEDED);
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
//---
	if(last_time != (ulong)iTime(Sym, PERIOD_M1, 1))
	 {
     symbol.Name(Sym); // get the object for the chart symbol
   
     if(symbol.SwapMode() == SYMBOL_SWAP_MODE_POINTS)
      {     
       swap_long = swap_value_currency(symbol.SwapLong(), symbol.TickValueProfit(), symbol.TickValueLoss());
       swap_short = swap_value_currency(symbol.SwapShort(), symbol.TickValueProfit(), symbol.TickValueLoss());
      }
      
     norm_swap_long = NormalizeDouble(swap_long, 2);
     norm_swap_short = NormalizeDouble(swap_short, 2);
     
     curr_time = TimeCurrent();
     MqlDateTime s_curr_time;
     TimeToStruct(curr_time, s_curr_time);
   
     if(s_curr_time.day_of_week == 3) // Wednesday
      {
       norm_swap_long = NormalizeDouble(swap_long * 3, 2);
       norm_swap_short = NormalizeDouble(swap_short * 3, 2);
      } 

	  ObjectSetString(0, SwapL, OBJPROP_TEXT, "Swap Long: " + DoubleToString(norm_swap_long, 2));   
	        
     if(ExpertsTab == true)
      {
       Print("swap long updated");
      }
     
	  ObjectSetString(0, SwapS, OBJPROP_TEXT, "Swap Short: " + DoubleToString(norm_swap_short, 2));
	    
	  if(ExpertsTab == true)
	   {
	    Print("swap short updated");
	   }         	    	      
     
     last_time = (ulong)iTime(Sym, PERIOD_M1, 1);         
   }  
    
//--- return value of prev_calculated for next call
   return(rates_total);
  }     

//+------------------------------------------------------------------+
//| Custom convert swap to account currency function                 |
//+------------------------------------------------------------------+
double swap_value_currency(double value_point, double tickprofit, double tickloss)
  {
   if(value_point == 0.0)
     {
      return(0.0);
     }
   if(value_point < 0.0)
     {
      return(value_point * tickloss);
     }
   return(value_point * tickprofit);
  }
//+------------------------------------------------------------------+

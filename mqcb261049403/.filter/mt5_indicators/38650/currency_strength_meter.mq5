//+------------------------------------------------------------------+
//|                                      Currency Strength Meter.mq5 |
//|                                        Copyright 2021, aligroup™ |
//|                                         https://www.aligroup.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, aligroup™"
#property link "https://www.aligroup.com"
#property version "1.00"
#property strict

#property indicator_chart_window
#property indicator_plots 0

#include <Arrays\ArrayString.mqh>
CArrayString SymbolGroups, Symbols;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input int RefreshRate = 100;                               //Refresh Rate (Milliseconds)
input bool SHOW_CURRENCIES = true;
input bool SHOW_CHART_PAIR = true;
input bool SHOW_COMMENT = false;
input ENUM_TIMEFRAMES timeframe = PERIOD_D1;//Strength Timeframe
input string CurrencyPairs = "AUDCAD,AUDCHF,AUDJPY,AUDNZD,AUDUSD,CADCHF,CADJPY,CHFJPY,EURAUD,EURCAD,EURCHF,EURGBP,EURJPY,EURNZD,EURUSD,GBPAUD,GBPCAD,GBPCHF,GBPJPY,GBPNZD,GBPUSD,NZDCAD,NZDCHF,NZDJPY,NZDUSD,USDCAD,USDCHF,USDJPY"; // 28 pairs
input string FontName = "Calibri";
input int FontSize = 12;
input int HorizPos = 5;
input int VertPos = 200;
input int VertSpacing = 20;
input color Color1 = clrMediumVioletRed;
input double Level1 = 7.0;
input color Color2 = clrDarkGreen;
input double Level2 = 5.0;
input color Color3 = clrBlue;
input double Level3 = 2.9;
input color Color4 = clrRed;
input double Level4 = 0.0;
input bool ShowNoOfPairs = false;
input bool SortDescending = true;

bool busy;
int ccy_count[8];
ENUM_BASE_CORNER myCorner = CORNER_RIGHT_UPPER;
double BaseVal, QuoteVal, PairVal, ccy_strength[8];
string BaseCur, QuoteCur, tMessage,  obj_name_prefix = "_CurrencyStrength_" + string(timeframe);

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SymbolGroups.Add("AUD");
   SymbolGroups.Add("CAD");
   SymbolGroups.Add("CHF");
   SymbolGroups.Add("EUR");
   SymbolGroups.Add("GBP");
   SymbolGroups.Add("JPY");
   SymbolGroups.Add("NZD");
   SymbolGroups.Add("USD");

   if(CurrencyPairs == "")
     {
      Symbols.Clear();
      Symbols.Add(Symbol());
     }
   else
     {
      Symbols.Clear();
      string ArraySplitResult[];
      int tradesResult = StringSplit(CurrencyPairs, StringGetCharacter(",", 0), ArraySplitResult);

      for(int i = 0; i < tradesResult; i++)
        {
         string symbol = ArraySplitResult[i];

         if(StringLen(symbol) == 6 && Symbols.SearchFirst(symbol) == -1)
           {
            if(AddSymbolToMarketWatch(symbol))
              {
               Symbols.Add(symbol);
              }
           }
        }
     }

   IndicatorSetString(INDICATOR_SHORTNAME, "Currecy Strength Meter");

// extract base and quote from symbol
   BaseCur = StringSubstr(Symbol(), 0, 3);
   QuoteCur = StringSubstr(Symbol(), 3, 3);

   Refresh_CS_Data();

//--- create timer
   EventSetMillisecondTimer(RefreshRate);

//---
   return (INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
   EventKillTimer();
   ObjectsDeleteAll(0, obj_name_prefix);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[])
  {

//--- return value of prev_calculated for next call
   return (rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(!busy)
     {
      busy = true;
      bool isTicking = false;
      static datetime LastTime = 0;
      datetime CurrentTime = TimeCurrent();
      LastTime = (isTicking = (CurrentTime > LastTime)) ? CurrentTime : LastTime;

      if(isTicking)
        {
         Refresh_CS_Data();
        }
      busy = false;
     }
  }

//+------------------------------------------------------------------+
void Refresh_CS_Data()
  {
   ArrayInitialize(ccy_strength, 0.0);
   ArrayInitialize(ccy_count, 0);

   for(int i = 0; i < Symbols.Total(); i++)
     {
      double ind_strength = 0;
      string symbol = Symbols[i];
      double day_high = iHigh(symbol, timeframe, 0), day_low = iLow(symbol, timeframe, 0);
      double bid_ratio = 100.0 * DivZero((SymbolInfoDouble(symbol, SYMBOL_BID) - day_low), (day_high - day_low));

      if(bid_ratio > 3.0)
         ind_strength = 1;
      if(bid_ratio > 10.0)
         ind_strength = 2;
      if(bid_ratio > 25.0)
         ind_strength = 3;
      if(bid_ratio > 40.0)
         ind_strength = 4;
      if(bid_ratio > 50.0)
         ind_strength = 5;
      if(bid_ratio > 60.0)
         ind_strength = 6;
      if(bid_ratio > 75.0)
         ind_strength = 7;
      if(bid_ratio > 90.0)
         ind_strength = 8;
      if(bid_ratio > 97.0)
         ind_strength = 9;

      for(int j = 0; j < SymbolGroups.Total(); j++)
        {
         if(SymbolGroups[j] == StringSubstr(symbol, 0, 3))  // Check if symbol is base currency
           {
            ccy_strength[j] += ind_strength;
            ccy_count[j] += 1;
            break;
           }
        }
      for(int j = 0; j < SymbolGroups.Total(); j++)
        {
         if(SymbolGroups[j] == StringSubstr(symbol, 3, 3))  // Check if symbol is quote currency
           {
            ccy_strength[j] += SymbolGroups.Total() + 1 - ind_strength;
            ccy_count[j] += 1;
            break;
           }
        }
     }

// This routine loads the strength values and currency symbols into an array, and sorts the array......
   int length = 0;
   double average_strength = 0;
   string array_to_sort[8], display_txt;

   for(int j = 0; j < SymbolGroups.Total(); j++)
     {
      array_to_sort[j] = "";
      average_strength = DivZero(ccy_strength[j], ccy_count[j]); // calculate the strength value = total strength / number of pairs that were summed

      if(SymbolGroups[j] == BaseCur)
        {
         BaseVal = average_strength;
         int basej = j;
        }
      if(SymbolGroups[j] == QuoteCur)
        {
         QuoteVal = average_strength;
         int quotej = j;
        }

      display_txt = DoubleToString(average_strength, 1) + SymbolGroups[j]; // build a string (display_txt) with the formatted number value, followed by the currency name
      length = StringLen(DoubleToString(average_strength, 1));       // length of the formatted number value

      if(ShowNoOfPairs)
        {
         display_txt = display_txt + DoubleToString(ccy_count[j], 0); // append the currency count to the string
        }
      array_to_sort[j] = display_txt; // load the string into an array to be sorted
     }

   int xp = HorizPos, yp = VertPos;
   ShellsortStringArray(array_to_sort, SortDescending); //   string, it has priority, but everything in the string gets sorted

   for(int j = 0; j < SymbolGroups.Total(); j++)
     {
      color FontColor = clrWhite;
      average_strength = StringToDouble(StringSubstr(array_to_sort[j], 0, length));                     // extract the value from the string
      display_txt = StringSubstr(array_to_sort[j], length, 3) + "    " + DoubleToString(average_strength, 1); // build a new string to be output, from the sorted array, with the currency sybol first

      if(ShowNoOfPairs)
        {
         display_txt = display_txt + " (" + StringSubstr(array_to_sort[j], length + 3) + ")"; // extract and append the currency count to the string
        }
      if(SHOW_CURRENCIES)
        {
         if(average_strength >= Level4)
            FontColor = Color4;
         if(average_strength > Level3)
            FontColor = Color3;
         if(average_strength > Level2)
            FontColor = Color2;
         if(average_strength > Level1)
            FontColor = Color1;

         display_txt = StringRightPad(display_txt, 16, " ");
         CreateTextLabel(obj_name_prefix, string(j), display_txt, xp, yp, FontColor, FontSize, myCorner);

         yp += VertSpacing;
        }
     }

   color FontColor = clrWhite;
   PairVal = BaseVal - QuoteVal;

   switch(PairVal > 0.0 ? 1 : PairVal < 0.0 ? -1 : 0)
     {
      case 1:
         FontColor = clrGreen;
         tMessage = "BUY   ";
         break;
      case -1:
         FontColor = clrRed;
         tMessage = "SELL  ";
         break;
      default:
         FontColor = clrDimGray;
         tMessage = "WAIT  ";
         break;
     }

   if(SHOW_CHART_PAIR)
     {
      display_txt = GetTimeFrame(timeframe) + ": " + Symbol() + " " + DoubleToString(PairVal, 1) + " " + tMessage;
      CreateTextLabel(obj_name_prefix, "active_chart", display_txt, xp, yp, FontColor, FontSize, myCorner);
      yp += VertSpacing;
     }
   if(SHOW_COMMENT)
     {
      Comment(BaseCur + " " + DoubleToString(BaseVal, Digits()), "\n", QuoteCur + " " + DoubleToString(QuoteVal, Digits()), "\n", Symbol() + " " + DoubleToString(PairVal, Digits()) + " " + tMessage, "\n", "");
     }
  }

//===========================================================================
//                            FUNCTIONS LIBRARY
//===========================================================================

//+------------------------------------------------------------------+
string StringRightPad(string str, int n = 1, string str2 = " ")
  {
// Appends occurrences of the string STR2 to the string STR to make a string N characters long
// Usage:    string x=StringRightPad("ABCDEFG",9," ")  returns x = "ABCDEFG  "
   return (str + StringRepeat(str2, n - StringLen(str)));
  }

//+------------------------------------------------------------------+
string StringRepeat(string str, int n = 1)
  {
// Repeats the string STR N times
// Usage:    string x=StringRepeat("-",10)  returns x = "----------"
   string outstr = "";
   for(int i = 0; i < n; i++)
     {
      outstr = outstr + str;
     }
   return (outstr);
  }

//+------------------------------------------------------------------+
double DivZero(double n, double d)
  {
// Divides N by D, and returns 0 if the denominator (D) = 0
// Usage:   double x = DivZero(y,z)  sets x = y/z
// Use DivZero(y,z) instead of y/z to eliminate division by zero errors
   return (d == 0) ? 0 : (1.0 * n / d);
  }

//+------------------------------------------------------------------+
void ShellsortStringArray(string &array[], bool desc = false)
  {
//+------------------------------------------------------------------+
// Performs a shell sort (rapid resorting) of string array 'a'
//  default is ascending order, unless 'desc' is set to true
   string mid;
   int n = ArraySize(array), j, i, m;

   for(m = n / 2; m > 0; m /= 2)
     {
      for(j = m; j < n; j++)
        {
         for(i = j - m; i >= 0; i -= m)
           {
            if(desc)
              {
               if(array[i + m] <= array[i])
                  break;
               else
                 {
                  mid = array[i];
                  array[i] = array[i + m];
                  array[i + m] = mid;
                 }
              }
            else
              {
               if(array[i + m] >= array[i])
                  break;
               else
                 {
                  mid = array[i];
                  array[i] = array[i + m];
                  array[i + m] = mid;
                 }
              }
           }
        }
     }
// return(0);
  }

//+------------------------------------------------------------------+
//| Create a text label                                              |
//+------------------------------------------------------------------+
void CreateTextLabel(string obj_prefix, string obj_label, string obj_text, int x_dist, int y_dist, int text_color, int font_size, ENUM_BASE_CORNER obj_corner)
  {
   obj_label = obj_prefix + obj_label;

   if(ObjectFind(0, obj_label) >= 0)
     {
      ObjectSetString(0, obj_label, OBJPROP_TEXT, obj_text);
      ObjectSetInteger(0, obj_label, OBJPROP_COLOR, text_color);
     }
   else
     {
      if(ObjectCreate(0, obj_label, OBJ_LABEL, 0, 0, 0))
        {
         switch(obj_corner)
           {
            case CORNER_LEFT_UPPER:
              {
               ObjectSetInteger(0, obj_label, OBJPROP_ALIGN, ALIGN_LEFT);
               ObjectSetInteger(0, obj_label, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
              };
            break;
            case CORNER_RIGHT_UPPER:
              {
               ObjectSetInteger(0, obj_label, OBJPROP_ALIGN, ALIGN_RIGHT);
               ObjectSetInteger(0, obj_label, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
              };
            break;
            case CORNER_LEFT_LOWER:
              {
               ObjectSetInteger(0, obj_label, OBJPROP_ALIGN, ALIGN_LEFT);
               ObjectSetInteger(0, obj_label, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
              };
            break;
            case CORNER_RIGHT_LOWER:
              {
               ObjectSetInteger(0, obj_label, OBJPROP_ALIGN, ALIGN_RIGHT);
               ObjectSetInteger(0, obj_label, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
              };
            break;
           }

         ObjectSetInteger(0, obj_label, OBJPROP_CORNER, obj_corner);

         ObjectSetString(0, obj_label, OBJPROP_TEXT, obj_text);
         ObjectSetInteger(0, obj_label, OBJPROP_COLOR, text_color);
         ObjectSetInteger(0, obj_label, OBJPROP_FONTSIZE, font_size);

         ObjectSetInteger(0, obj_label, OBJPROP_XDISTANCE, x_dist);
         ObjectSetInteger(0, obj_label, OBJPROP_YDISTANCE, y_dist);
        }
      else
        {
         Print(__FUNCTION__, ": failed to create text label! Error code: ", GetLastError());
        }
     }
  }

//+------------------------------------------------------------------+
//| Adding the specified symbol to the Market Watch window           |
//+------------------------------------------------------------------+
bool AddSymbolToMarketWatch(string symbol)
  {
//--- Iterate over the entire list of symbols
   for(int i = 0; i < SymbolsTotal(false); i++)
     {
      //--- Symbol name on the server
      string name = SymbolName(i, false);
      //--- If this symbol is available,
      if(name == symbol)
        {
         //--- add it to the Market Watch window and
         return SymbolSelect(name, true);
        }
     }

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetTimeFrame(ENUM_TIMEFRAMES tf)
  {
   tf = (tf == PERIOD_CURRENT) ? (ENUM_TIMEFRAMES)Period() : tf;
   string period_xxx = EnumToString(tf); // PERIOD_XXX
   return StringSubstr(period_xxx, 7);          // XXX
  }//+------------------------------------------------------------------+

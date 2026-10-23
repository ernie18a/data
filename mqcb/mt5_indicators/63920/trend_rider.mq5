
#property copyright "Mohammed Kaddour"
#property link "https://www.mql5.com/en/users/mohkadd/news"
#property version "1.0"
#property strict

#property indicator_chart_window
#property indicator_buffers 12
#property indicator_plots 2


//--- plot TrendLine
#property indicator_label1 "regular SuperTrend"
#property indicator_type1 DRAW_COLOR_LINE
#property indicator_color1 clrGreen, clrRed
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2

#property indicator_label2 "RSI adjusted SuperTrend"
#property indicator_type2 DRAW_COLOR_LINE
#property indicator_color2 clrGreen, clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 2





#define RESET 0
#define Buy 1.0
#define Sell -1.0

enum MYENUM
{
    v1 = 100,  // 100
    v2 = 50    // 50
};


input double AtrMultiplier = 1.0;                        // factor
input int AtrLength = 20;                                // length ATR
input int RsiPeriod = 14;                                // Length RSI
input MYENUM toggle = v1 ;                               //  Divide RSI value by
input bool SuperTrendenable = false ;                    // show Regular ST



ENUM_APPLIED_PRICE AtrAppliedPrice = PRICE_CLOSE;
ENUM_APPLIED_PRICE RsiAppliedPrice = PRICE_CLOSE; 
string prog_name = "RSI adjusted SuperTrend";
int iATR_Handle, iRSI_Handle;
double Up[], Dn[],Up1[], Dn1[], Di[], Di1[], SuperTrend[], SuperTrendprv[], SuperTrend1[], SuperTrendprv1[], STColors[],STColorsprv[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
//---Relative Strengh Index Candles



  //---SuperTrend
   SetIndexBuffer(0, SuperTrend, INDICATOR_DATA);
   SetIndexBuffer(1, STColors, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, SuperTrendprv, INDICATOR_DATA);
   SetIndexBuffer(3, STColorsprv, INDICATOR_COLOR_INDEX);
//---Calculations
   SetIndexBuffer(4, Up, INDICATOR_CALCULATIONS);
   SetIndexBuffer(5, Dn, INDICATOR_CALCULATIONS);
   SetIndexBuffer(6, Up1, INDICATOR_CALCULATIONS);
   SetIndexBuffer(7, Dn1, INDICATOR_CALCULATIONS);   
   SetIndexBuffer(8, Di, INDICATOR_CALCULATIONS);
   SetIndexBuffer(9, Di1, INDICATOR_CALCULATIONS);
   SetIndexBuffer(10, SuperTrend1, INDICATOR_CALCULATIONS);
   SetIndexBuffer(11, SuperTrendprv1, INDICATOR_CALCULATIONS);
   if((iRSI_Handle = iRSI(Symbol(), PERIOD_CURRENT, RsiPeriod, RsiAppliedPrice)) == INVALID_HANDLE)
     {
      Print("Failed to initialize ", Symbol(), " RSI indicator handle");
      return (INIT_FAILED);
     }
   if((iATR_Handle = iATR(Symbol(), PERIOD_CURRENT, AtrLength)) == INVALID_HANDLE)
     {
      Print("Failed to initialize ", Symbol(), " ATR indicator handle");
      return (INIT_FAILED);
     }

   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   IndicatorSetString(INDICATOR_SHORTNAME, prog_name + " (" + string(AtrLength) + "," + string(AtrMultiplier) + ") " + GetTimeFrame(PERIOD_CURRENT));

//---
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[])
  {
   double atr[], rsi[], macd[];

//--- get fast indicator buffer values

   if(BarsCalculated(iRSI_Handle) < rates_total || CopyBuffer(iRSI_Handle, 0, 0, rates_total, rsi) < rates_total)
     {
      Print("Unable to get all ", Symbol(), " RSI indicator values, Error Code: ", GetLastError());
      return RESET;
     }
   if((BarsCalculated(iATR_Handle) < rates_total) || (CopyBuffer(iATR_Handle, 0, 0, rates_total, atr) < rates_total))
     {
      Print("Unable to get all ", Symbol(), " ATR indicator values, Error Code: ", GetLastError());
      return RESET;
     }

   for(int i = MathMax(prev_calculated - 1, 1); i < rates_total; i++)
     {
      double aRsi   = MathAbs(rsi[i]  -   50  ) / (toggle == 100 ? 100 : 50);
      double mprice = (high[i] + low[i]) / 2;
      
      Up[i] = mprice + AtrMultiplier * atr[i];
      Dn[i] = mprice - AtrMultiplier * atr[i];
      Up1[i] = mprice + AtrMultiplier * atr[i];
      Dn1[i] = mprice - AtrMultiplier * atr[i];

      
      Dn[i] = Dn[i]>Dn[i-1] || close[i-1] < Dn[i-1] ? Dn[i] : Dn[i-1];
      Up[i] = Up[i]<Up[i-1] || close[i-1] > Up[i-1] ? Up[i] : Up[i-1];
      
      Up1[i] += Up1[i]*aRsi;
      Dn1[i] -= Dn1[i]*aRsi;

      Dn1[i] = Dn1[i]>Dn1[i-1] || close[i-1] < Dn1[i-1] ? Dn1[i] : Dn1[i-1];
      Up1[i] = Up1[i]<Up1[i-1] || close[i-1] > Up1[i-1] ? Up1[i] : Up1[i-1];
      
      
      
       
      if(!MathIsValidNumber(atr[i-1])){
      
       Di[i] = 1 ;
       Di1[i] = 1 ;
      
      }else{
      
        if(SuperTrend1[i-1] == Up[i-1]){
        Di[i] = close[i] > Up[i] ? -1 : 1 ; 
        }else{
        Di[i] = close[i] < Dn[i] ? 1 : -1 ;
        }
        
      
      
      
        if(SuperTrendprv1[i-1] == Up1[i-1]){
        Di1[i] = close[i] > Up1[i] ? -1 : 1 ; 
        }else{
        Di1[i] = close[i] < Dn1[i] ? 1 : -1 ;
        }
      
      }
      if(Di1[i] < 0)
        {
         STColorsprv[i] = 0;
         SuperTrendprv[i] = Dn1[i] ;
         SuperTrendprv1[i] = Dn1[i] ;
        }
      if(Di1[i] > 0)
        {
         STColorsprv[i] = 1;
         SuperTrendprv[i] = Up1[i] ;
         SuperTrendprv1[i] = Up1[i] ;
        }

 
 
      if(Di[i] < 0  && SuperTrendenable )
        {
         STColors[i] = 0;
         SuperTrend[i] = Dn[i] ;
         SuperTrend1[i] = Dn[i] ;
        }
      if(Di[i] > 0 && SuperTrendenable)
        {
         STColors[i] = 1;
         SuperTrend[i] = Up[i] ;
         SuperTrend1[i] = Up[i] ;
        }
      
     }

     
//--- return value of prev_calculated for next call
   return (rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getPrice(ENUM_APPLIED_PRICE price, const double &open[], const double &close[], const double &high[], const double &low[], int i)
  {
   switch(price)
     {
      case PRICE_CLOSE:
         return (close[i]);
      case PRICE_OPEN:
         return (open[i]);
      case PRICE_HIGH:
         return (high[i]);
      case PRICE_LOW:
         return (low[i]);
      case PRICE_MEDIAN:
         return ((high[i] + low[i]) / 2.0);
      case PRICE_TYPICAL:
         return ((high[i] + low[i] + close[i]) / 3.0);
      case PRICE_WEIGHTED:
         return ((high[i] + low[i] + close[i] + close[i]) / 4.0);
      default:
         return (close[i]);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetTimeFrame(ENUM_TIMEFRAMES timeframe)
  {
   timeframe = (timeframe == PERIOD_CURRENT) ? (ENUM_TIMEFRAMES)Period() : timeframe;
   string period_xxx = EnumToString(timeframe); // PERIOD_XXX
   return StringSubstr(period_xxx, 7);          // XXX
  }
//+------------------------------------------------------------------+

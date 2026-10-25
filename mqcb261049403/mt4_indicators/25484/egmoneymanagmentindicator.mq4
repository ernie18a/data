//+------------------------------------------------------------------+
//|                                EG-Money-Management-Indicator.mq4 |
//|                                    Copyright 2019-2021. ErangaG  |
//|                         @author ErangaG. http://www.simply.trade |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright "Copyright 2019-2021, ErangaG"
#property link      "http://www.simply.trade"
#property version   "21.10"
#property strict


#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1  clrNONE
#property indicator_color2  clrNONE
#property indicator_color3  clrNONE

enum ECapitalCalculation {
   FREEMARGIN = 2,
   BALANCE = 4,
   EQUITY = 8,
};

enum ERiskCalculation { 
   ATR_POINTS = 3, 
   FIXED_POINTS = 9, 
};

input ECapitalCalculation  riskmg_AvailableCapital = BALANCE;  // Capital calculation mechanism
input double               riskmg_FractionOfCapital = 0.01;    // Risk fraction of the capital ,ex: 0.01 = 1%
input ERiskCalculation     riskmg_RiskMode = ATR_POINTS;       // Stop-Loss points calculation mechanism

input int       common_ATRLength = 14;                         // ATR length for ATR based Stop-Loss
input double    common_ATRMultiplier = 1.5;                    // ATR value multiplier
input int       common_FixedStoplossPoints = 1000;             // Fixed size Stop-Loss point count

input color     common_ColorParameters = clrOrange;            // Colour for Parameters
input color     common_ColorLotsize = clrDeepSkyBlue;          // Colour for calculaed Lots
input string    common_CurrencyPairAppendix = "";              // Currency Pair Appendix

int       Display_Corner = 2;

double   buffer_atrPoints[];
double   buffer_stoplossPoints[];
double   buffer_lotsize[];


class CToolkit {   
      
   protected:
   
       virtual void  _Name() = NULL;   // A pure virtual function to make this class abstract       
   
   public:
   
      static double NormalizeLots(string argSymbol, double argLots) {
         double uvolumeStep = SymbolInfoDouble(argSymbol, SYMBOL_VOLUME_STEP);
         double ulots = MathRound(argLots / uvolumeStep) * uvolumeStep; //-- normallize to a multiple of lotstep accepted by the broker
         return ulots;
      }      
      
      static double ToPointDecimal(string argSymbol, uint pointsCount) 
      {
         int udigits = (int)SymbolInfoInteger(argSymbol,SYMBOL_DIGITS);
         double upointDecimal = SymbolInfoDouble(argSymbol, SYMBOL_POINT); 
         return NormalizeDouble(upointDecimal * pointsCount, udigits);

      }
      
      static int ToPointsCount(string argSymbol, double decimalValue) 
      {
         double upointDecimal = SymbolInfoDouble(argSymbol, SYMBOL_POINT);
         return (int)((1/upointDecimal) * decimalValue);
      }
      
      static int ToTicksCount(string argSymbol, uint pointsCount) 
      {
        // https://forum.mql4.com/43064#515262 for non-currency DE30:
        // SymbolInfoDouble(chart.symbol, SYMBOL_TRADE_TICK_SIZE) returns 0.5
        // SymbolInfoInteger(chart.symbol,SYMBOL_DIGITS) returns 1
        // SymbolInfoInteger(chart.symbol,SYMBOL_POINT) returns 0.1
        // Prices to open must be a multiple of ticksize    
         double uticksize = SymbolInfoDouble(argSymbol, SYMBOL_TRADE_TICK_SIZE);
         int utickscount = (int)((pointsCount / uticksize) * uticksize); //-- fix prices by ticksize
         return utickscount;
      }  
      
      static int GetATRPointCount(string argSymbol, uint argTimeframe, int argATRLength, int argIndicatorShift, double argATRMultiplier) {
         double atr;
         int atrPoints, slPoints;
            
         atr = iATR(argSymbol, argTimeframe, argATRLength, argIndicatorShift);
         atrPoints = (int)(atr * MathPow(10,MarketInfo(argSymbol, MODE_DIGITS)));
         slPoints = (int)MathCeil(argATRMultiplier*atrPoints);   
         return slPoints;
      }      
         
      static double _CurrencyMultiplicator(string currencyPairAppendix="")
      {
         double _multiplicator = 1.0;
      
         if(AccountCurrency() == "USD")
            return (_multiplicator);
         if(AccountCurrency() == "EUR")
            _multiplicator = 1.0 / SymbolInfoDouble("EURUSD" + currencyPairAppendix, SYMBOL_BID);
         if(AccountCurrency() == "GBP")
            _multiplicator = 1.0 / SymbolInfoDouble("GBPUSD" + currencyPairAppendix, SYMBOL_BID);
         if(AccountCurrency() == "AUD")
            _multiplicator = 1.0 / SymbolInfoDouble("AUDUSD" + currencyPairAppendix, SYMBOL_BID);
         if(AccountCurrency() == "NZD")
            _multiplicator = 1.0 / SymbolInfoDouble("NZDUSD" + currencyPairAppendix, SYMBOL_BID);
         if(AccountCurrency() == "CHF")
            _multiplicator = SymbolInfoDouble("USDCHF" + currencyPairAppendix, SYMBOL_BID);
         if(AccountCurrency() == "JPY")
            _multiplicator = SymbolInfoDouble("USDJPY" + currencyPairAppendix, SYMBOL_BID);
         if(AccountCurrency() == "CAD")
            _multiplicator = SymbolInfoDouble("USDCAD" + currencyPairAppendix, SYMBOL_BID);
         if(_multiplicator == 0)
            _multiplicator = 1.0; // If account currency is neither of EUR, GBP, AUD, NZD, CHF, JPY or CAD we assumes that it is USD
         return (_multiplicator);
      }
      
      
      static double CalculateLotSize(string argSymbol, double argMoneyCapital, double argRiskDecimal, int argStoplossPoints, int argExtraPriceGapPoints, double argAllowedMaxLotSize, string argCurrencyPairAppendix)
      {
         // Calculate LotSize based on Equity, Risk in decimal and StopLoss in points
         double _moneyRisk, _lotsByRequiredMargin, _lotsByRisk, _lotSize;
         int _lotdigit = 2, _totalSLPoints, _totalTickCount;
      
         
         double _marginForOneLot = MarketInfo(argSymbol, MODE_MARGINREQUIRED); // Calculate margin required for 1 lot   
         double _lotStep = SymbolInfoDouble(argSymbol, SYMBOL_VOLUME_STEP); // Step in lot size changing
         double _oneTickValue = SymbolInfoDouble(argSymbol, SYMBOL_TRADE_TICK_VALUE); // Tick value of the asset
               
         if(_lotStep ==  1) _lotdigit = 0;
         if(_lotStep == 0.1) _lotdigit = 1;
         if(_lotStep == 0.01) _lotdigit = 2;
      
         _moneyRisk = argRiskDecimal * argMoneyCapital;
         _totalSLPoints = argStoplossPoints + argExtraPriceGapPoints; 
         _totalTickCount = ToTicksCount(argSymbol, _totalSLPoints); 
      
         // Calculate Lot size according to Equity. 
         _lotsByRequiredMargin = argMoneyCapital * 0.98 / _marginForOneLot;
         _lotsByRequiredMargin = MathMin(_lotsByRequiredMargin, MathMin(argAllowedMaxLotSize, SymbolInfoDouble(argSymbol, SYMBOL_VOLUME_MAX)));
         _lotsByRequiredMargin = NormalizeLots(argSymbol, _lotsByRequiredMargin);   
                                 
         // Calculate the Lot size according to Risk.
         _lotsByRisk = _moneyRisk / (_totalTickCount * _oneTickValue);
         _lotsByRisk = _lotsByRisk * _CurrencyMultiplicator(argCurrencyPairAppendix);
         _lotsByRisk = NormalizeLots(argSymbol, _lotsByRisk);
         
         _lotSize = MathMax(MathMin(_lotsByRisk, _lotsByRequiredMargin), SymbolInfoDouble(argSymbol, SYMBOL_VOLUME_MIN));
         //_lotSize = MathMax(MathMin(_lotsByRisk, SymbolInfoDouble(argSymbol, SYMBOL_VOLUME_MAX)), SymbolInfoDouble(argSymbol, SYMBOL_VOLUME_MIN));   
         _lotSize = NormalizeDouble(_lotSize, _lotdigit);
      
         return (_lotSize);
      } 
      
      static void DisplayText(string objname,string objtext,int clr,int x,int y,int corner)
      {
         if(ObjectFind(objname)==-1)
           {
            ObjectCreate(objname,OBJ_LABEL,0,0,0);
            ObjectSet(objname,OBJPROP_CORNER,corner);
            ObjectSet(objname,OBJPROP_XDISTANCE,x);
            ObjectSet(objname,OBJPROP_YDISTANCE,y);
           }
         ObjectSetText(objname,objtext,13,"Arial",clr);
      }         
   
};

int init()
{

   string name = "EG";
   SetIndexBuffer(0,buffer_atrPoints);
   SetIndexLabel(0,StringConcatenate(name,"_ATR_Points"));
   SetIndexStyle(0,DRAW_NONE);
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexBuffer(1,buffer_stoplossPoints);
   SetIndexLabel(1,StringConcatenate(name,"_Stoploss_Points"));
   SetIndexStyle(1,DRAW_NONE);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexBuffer(2,buffer_lotsize);
   SetIndexLabel(2,StringConcatenate(name,"_Lots"));
   SetIndexStyle(2,DRAW_NONE);
   SetIndexEmptyValue(2,EMPTY_VALUE);

   IndicatorShortName(WindowExpertName());

   return(0);
}


int deinit()
{

   ObjectDelete(ChartID(), "@MM-ATR");
   ObjectDelete(ChartID(), "@MM-LotText");
   ObjectDelete(ChartID(), "@MM-LotSize");
   return(0);
}


int start()
{
   static int xLastCountedBars;                                          
   int xBars = iBars(NULL, 0);
   if (xLastCountedBars != xBars) { xLastCountedBars = xBars; } else { return (0); }   

   int indicator_counted = IndicatorCounted();
   if(indicator_counted <0 ) return(-1);
   if(indicator_counted >0 ) indicator_counted--;
   int limit = MathMin(xBars-indicator_counted, xBars-1);

   double availableMoney, lotsize;
   int atrPoints, slPoints, extraPoints;

   for(int i=limit; i>=0; i--) {   
   
         // Get available money
         switch (riskmg_AvailableCapital) {            
            case FREEMARGIN:
               availableMoney = AccountInfoDouble(ACCOUNT_MARGIN_FREE); break;        
            case BALANCE:
               availableMoney = AccountInfoDouble(ACCOUNT_BALANCE); break;   
            case EQUITY:
               availableMoney = AccountInfoDouble(ACCOUNT_EQUITY); break;
            default:
               availableMoney = AccountInfoDouble(ACCOUNT_MARGIN_FREE); break;                  
         }      
         
         atrPoints = CToolkit::GetATRPointCount(NULL, 0, common_ATRLength, i+1, common_ATRMultiplier);
         
         // calculate raw lotsize
         if(riskmg_RiskMode == FIXED_POINTS) {
            slPoints = common_FixedStoplossPoints;
         }else {   
            slPoints = atrPoints > 0 ? atrPoints : common_FixedStoplossPoints;
         } 
         
         extraPoints = (int)SymbolInfoInteger(NULL, SYMBOL_SPREAD);
         lotsize = CToolkit::CalculateLotSize(NULL, availableMoney, riskmg_FractionOfCapital, slPoints, extraPoints, SymbolInfoDouble(NULL, SYMBOL_VOLUME_MAX), common_CurrencyPairAppendix);

         buffer_atrPoints[i]=StrToDouble(DoubleToStr(atrPoints,0));
         buffer_stoplossPoints[i]=StrToDouble(DoubleToStr(slPoints,0));
         buffer_lotsize[i]=StrToDouble(DoubleToStr(lotsize,2));;
   }

   if(riskmg_RiskMode == ATR_POINTS) {
      CToolkit::DisplayText("@MM-ATR",StringConcatenate("ATR (", common_ATRLength,") : ",buffer_atrPoints[0]," points"), common_ColorParameters,30,50,Display_Corner);
   }

   CToolkit::DisplayText("@MM-LotText",StringConcatenate("Risk : ",DoubleToStr((riskmg_FractionOfCapital*100),2),"% , Stop-Loss : ",buffer_stoplossPoints[0]," points"),common_ColorParameters,30,25,Display_Corner);
   CToolkit::DisplayText("@MM-LotSize",StringConcatenate("Lots : ",buffer_lotsize[0]),common_ColorLotsize,30,0,Display_Corner);

   return(0);
}





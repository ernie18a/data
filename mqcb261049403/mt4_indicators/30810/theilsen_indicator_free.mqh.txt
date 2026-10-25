//+------------------------------------------------------------------+
//|                                    Keltner_Channel_Indicator.mqh |
//|                        Copyright 2019, NetrillioN Software Corp. |
//|                                       https://www.netrillion.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, NetrillioN Software Corp."
#property link      "https://www.netrillion.com"
#property strict
#property strict
#include <BreakPoint.mqh>

//+------------------------------------------------------------------+
// iTSlope                                                             
//+------------------------------------------------------------------+
/*
 This returns the current theilsen value of market condition,sentiment and slope.
 Theil–Sen estimator of a set of two-dimensional points (xi,yi) is the median m of the slopes (yj - yi)/(xj - xi).
 Dataset selection:
 "close" - regression on close prices.
 "open" - regression on open prices.
 "high" - regression on high prices.
 "low" - regression on low prices.
 "sma_close" - regression on close price sma values.
 "ema_close" - regression on close price ema values.
*/
bool iTSlope(string tSymbol, ENUM_TIMEFRAMES tChartTimeframe, int tRegressionPeriod, string tDataset_Selection, string& tResult_MarketPhase, string& tResult_Tendency, double& tResult_Slope, string tTrendline_NickName, bool tDisplayText, int tShift)
{
 bool res=false;
 double theilsen=-99999,blank=0;
 int mkphase=0, tendency=0;
    if(tShift < 0)
    {
     Print("Only up to shift "+IntegerToString(1)+" has been calculated by theilsen. Shift "+IntegerToString(tShift)+" was requested.");
     return(res);
    }
    else
    {
     blank = iCustom(tSymbol, tChartTimeframe, "theilsen_gradient", tSymbol, tChartTimeframe, tRegressionPeriod, tDataset_Selection, tResult_MarketPhase,tResult_Tendency, tResult_Slope, tTrendline_NickName,tDisplayText,tShift, 0, tShift); // Shift 1 when tShift=1   
     mkphase = (int)GlobalVariableGet("tGlobalMarketPhase");
     tendency = (int)GlobalVariableGet("tGlobalTendency");
     theilsen = GlobalVariableGet("tGlobalSlope");
     tResult_Slope = theilsen;
         
       if(mkphase == 2)tResult_MarketPhase = "ranging";
       else if(mkphase == 1)tResult_MarketPhase = "trending"; 
                         
       if(tendency == 1)tResult_Tendency = "bullish";
       else if(tendency == 3)tResult_Tendency = "neutral";
       else if(tendency == 2)tResult_Tendency = "bearish"; 
           
    }  
     
    if(tResult_MarketPhase == "" || tResult_Tendency == "" || theilsen == -99999)
    { 
        if(tDataset_Selection == "close" || tDataset_Selection == "open" || tDataset_Selection == "high" || tDataset_Selection == "low" || tDataset_Selection == "sma_close" || tDataset_Selection == "ema_close"){}
        else
        {
         Print("Error: Invalid tDataset_Selection "+tDataset_Selection+" value. This value must be either 'close','open','high','low','sma_close','ema_close'.");
        }
        if(tChartTimeframe > 3 || tChartTimeframe < 0)Print("Error: Invalid tChartTimeframe "+IntegerToString(tChartTimeframe)+" value. This value must be less than or equal to 43200.");
        if(tShift < 0)Print("Error: Invalid tShift "+IntegerToString(tShift)+" value. This value must be bigger than 0.");
        else
        { 
            if(IsTesting() != true)Print("Error: Check if tSymbol '"+tSymbol+"' is listed in the Market Watch window. Or maybe something else is wrong.");
        } 
    }
    else res = true;
 return res;
}
//+------------------------------------------------------------------+
// End of iTSlope                                                             
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|    OverallSlope                                     
//+------------------------------------------------------------------+
// This function calculates the overall direction for several regression lines.
/*
 Dataset selection:
 "close" - regression on close prices.
 "open" - regression on open prices.
 "high" - regression on high prices.
 "low" - regression on low prices.
 "sma_close" - regression on close price sma values.
 "ema_close" - regression on close price ema values.
*/
bool OverallSlope(string acurrent_symbol, ENUM_TIMEFRAMES charttimeframe, string Periods, string DataSet, int& rhighestperiod, int& rlowestperiod, string& rmarketphase,  string& rtendency, double& rslope, bool display, int Shift)
{
 bool res=false;
 string periods_arr[]; string lastmarketphase=""; string lasttendency=""; 
 string linename,tempmarketphase,temptendency;
 int aperiod=-1,c=-1,sz=0,lowest_period=0,highest_period=0;
 string sep=",";// A separator as a character 
 ushort u_sep=0;// The code of the separator character 
 double totalslope=0,avg=-99999,slope=0,max_ranging_value=0.0006,max_neutral_val=0.0001, highest_period_slope=0, lowest_period_slope=0, lastval=0;

 u_sep=StringGetCharacter(sep,0);//--- Get the separator code     
 sz = StringSplit(Periods,u_sep,periods_arr);
 c = sz;         
    while(c>0 && slope>-1)
    {
     c--;
     aperiod = StrToInteger(periods_arr[c]);
     linename = StringConcatenate(periods_arr[c],"period_trend");
     iTSlope(acurrent_symbol,charttimeframe,aperiod,"ema_close",tempmarketphase,temptendency,slope,linename,display,Shift);
     //lastval = iMA(acurrent_symbol,charttimeframe,aperiod,0,MODE_SMA,PRICE_CLOSE,Shift);
     lastval = NormalizeDouble(lastval,Digits);
        if(highest_period_slope == 0)//sort by highest
        {
         highest_period_slope = lastval;
         highest_period = aperiod;
        } 
        else if(highest_period_slope<lastval)
        {
         highest_period_slope = lastval;
         highest_period = aperiod;
        }
        if(lowest_period_slope == 0)//sort by lowest
        {
         lowest_period_slope = lastval;
         lowest_period = aperiod;
        }
        else if(lowest_period_slope>lastval)
        {
         lowest_period_slope = lastval;        
         lowest_period = aperiod;
        }
                
        if(lastmarketphase == "" && tempmarketphase != "")lastmarketphase = tempmarketphase;
        else if(lastmarketphase == tempmarketphase && tempmarketphase != "")lastmarketphase = tempmarketphase;
        else lastmarketphase = "unknown";
         
        if(lasttendency == "" && temptendency != "")lasttendency = temptendency;
        else if(lasttendency == temptendency && temptendency != "")lasttendency = temptendency;
        else lasttendency = "unknown";  
        
        if(slope>-99999)totalslope = totalslope + slope;
        else totalslope = slope;            
    } 
    if(sz>0 && totalslope>-99999)avg=totalslope/sz;
    if(avg<0.00001 && avg>-0.00001 && lasttendency != "neutral")lasttendency="trendless";
 rmarketphase = lastmarketphase;
 rtendency = lasttendency;   
 rslope = avg; 
 rhighestperiod = highest_period;
 rlowestperiod = lowest_period;
                    
 return  res;  
}
//+------------------------------------------------------------------+
//|    End of OverallSlope                                     
//+------------------------------------------------------------------+



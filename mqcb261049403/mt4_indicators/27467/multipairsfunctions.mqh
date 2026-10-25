//+------------------------------------------------------------------+
//|                                          multipairsfunctions.mqh |
//|                        Copyright 2019, NetrillioN Software Corp. |
//|                                       https://www.netrillion.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, NetrillioN Software Corp."
#property link      "https://www.netrillion.com"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+

string indicator_counted_bars[][5];
int limit=2;//maximum bars indicator should calculate at any one time.Also set max bars in MT4 chart to 205
int multipairsfilepos=0;
//+------------------------------------------------------------------+
//| IndicatorCounted2                                                |
//+------------------------------------------------------------------+
/*
 this will get the number of bars the indicator has counted. 
*/
int IndicatorCounted2(string theSymbol, ENUM_TIMEFRAMES theChartTimeframe, string theIndicatorName)
  {
   bool fnd=false;
   ENUM_TIMEFRAMES charttimeframe=-1,CurrentChart=0;
   int sz=0,i=0,countedbars=0;
   string symbol,CurrentSymbol,iname;
   
   //search for indicator name and symbol
   sz=ArrayRange(indicator_counted_bars,0);
   i=sz;
   CurrentChart = theChartTimeframe; 
      if(theChartTimeframe == 0)CurrentChart = (ENUM_TIMEFRAMES)Period(); 
   CurrentSymbol = theSymbol;  
      if(theSymbol == "" || theSymbol == NULL)CurrentSymbol = Symbol();    
      while(i>0 && fnd==false)
      {
       i--; 
       symbol = indicator_counted_bars[i][0];//symbol   
       iname = indicator_counted_bars[i][1];//indicator's name   
       charttimeframe = (ENUM_TIMEFRAMES)StrToInteger(indicator_counted_bars[i][3]);//chart time frame
          if(symbol == CurrentSymbol && iname == theIndicatorName && CurrentChart==charttimeframe)
          {
           fnd = true;
           countedbars = (int)StringToInteger(indicator_counted_bars[i][2]);
          }        
      }
   return(countedbars);   
  }
//+------------------------------------------------------------------+
//| End of IndicatorCounted2                                         |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| updateIndicatorCounted2                                          |
//+------------------------------------------------------------------+
/*
 this will update the number of bars the indicator has counted. 
*/
void updateIndicatorCounted2(string theSymbol, ENUM_TIMEFRAMES theChartTimeframe, datetime Latestbaropentime, string theIndicatorName, int Counted, int SymbolPos=-1)
  {
   bool fnd=false;
   ENUM_TIMEFRAMES charttimeframe=-1,CurrentChart=0;
   int sz=0,i=0,countedbars=0;
   string symbol,CurrentSymbol,iname;
      if(SymbolPos>=0)
      {
       fnd = true;
       indicator_counted_bars[SymbolPos][2] = IntegerToString(Counted);
       indicator_counted_bars[SymbolPos][4] = TimeToString(Latestbaropentime);        
      }  
  
   //search for indicator name and symbol
   sz=ArrayRange(indicator_counted_bars,0);
   i=sz;
   CurrentChart = theChartTimeframe;   
      if(theChartTimeframe == 0)CurrentChart = (ENUM_TIMEFRAMES)Period();
   CurrentSymbol = theSymbol;  
      if(theSymbol == "" || theSymbol == NULL)CurrentSymbol = Symbol();        
      while(i>0 && fnd==false)
      {
       i--; 
       symbol = indicator_counted_bars[i][0];//symbol   
       iname = indicator_counted_bars[i][1];//indicator's name
       charttimeframe = (ENUM_TIMEFRAMES)StrToInteger(indicator_counted_bars[i][3]);//chart time frame   
          if(symbol == CurrentSymbol && iname == theIndicatorName && CurrentChart==charttimeframe)
          {
           fnd = true;
           indicator_counted_bars[i][2] = IntegerToString(Counted);
           indicator_counted_bars[i][4] = TimeToString(Latestbaropentime);
          }        
      }
      if(fnd == false)
      {
       ArrayResize(indicator_counted_bars,(sz+1));//expand array size
       indicator_counted_bars[sz][0] = CurrentSymbol;
       indicator_counted_bars[sz][1] = theIndicatorName;
       indicator_counted_bars[sz][2] = IntegerToString(Counted);
       indicator_counted_bars[sz][3] = IntegerToString(CurrentChart);
       indicator_counted_bars[sz][4] = TimeToString(Latestbaropentime);
      }  
  }
//+------------------------------------------------------------------+
//| End of updateIndicatorCounted2                                         |
//+------------------------------------------------------------------+





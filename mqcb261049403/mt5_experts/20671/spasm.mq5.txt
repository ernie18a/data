//+------------------------------------------------------------------+
//|                               Spasm(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
#property version   "1.003"
//---
#define MODE_HIGH 2
#define MODE_LOW 1
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//--- input parameters
input double   InpLots        = 0.1;         // Lots
input double   InpCoefficient = 5.0;         // Multiplier relative to current volatility  
input int      InpPeriod      = 24;          // Period for the calculation of volatility in bars
input bool     InpExp         = false;       // Volatility smoothing Mode: 0-simple sliding 1-linear-weighted
input bool     OpenClose      = false;       // Volatility calculation Mode: 1-open/close, 0-High/Low
input double   SL_pp          = 0.5;         // Stop loss as a percentage of volatility (0 to 1)
input ulong    m_magic        = 592772159;   // magic number
//---
ulong          m_slippage=10;                // slippage
//---
double high_highest=0,low_lowest=0;
bool trend=false;
datetime time_lowest=0,time_highest=0;
double koef[];
ushort plech=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();

   string err_text="";
   if(!CheckVolumeValue(InpLots,err_text))
     {
      Print(__FUNCTION__,", ERROR: ",err_text);
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   m_trade.SetExpertMagicNumber(m_magic);
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(m_symbol.Name());
//---
   m_trade.SetDeviationInPoints(m_slippage);
//---
   int index_highest=iHighest(m_symbol.Name(),Period(),InpPeriod*3,0);
   int index_lowest=iLowest(m_symbol.Name(),Period(),InpPeriod*3,0);
   if(index_highest<index_lowest)
      trend=false;
   else
      trend=true;

   high_highest= iHigh(index_highest);
   time_highest= iTime(index_highest);
   low_lowest  = iLow(index_lowest);
   time_lowest = iTime(index_lowest);
//**************
   double res=0.0;
   if(!calc_vol(res))
      return(INIT_FAILED);
   plech=(ushort)(res*InpCoefficient);
//**************
   ArrayResize(koef,InpPeriod);
   double val=2.0/InpPeriod;
   double inc=2.0;
   for(int j=0;j<InpPeriod;j++)
     {
      koef[j]=inc;
      inc-=val;
     }
//*********************  
/*stoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL)+1;
   spread=MarketInfo(Symbol(), MODE_SPREAD);
   freeze=MarketInfo(Symbol(), MODE_FREEZELEVEL)+1;*/

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---  
   static datetime PrevBars=0;
   datetime time_0=iTime(0);
   if(time_0!=PrevBars)
     {
      double res=0.0;
      if(!calc_vol(res))
         return;
      plech=(ushort)(res*InpCoefficient);
      PrevBars=time_0;
     }
//---
   if(!RefreshRates())
      return;
//---
   if(m_symbol.Bid()>high_highest+plech*m_symbol.Point())
      high_highest=m_symbol.Bid();
   if(m_symbol.Bid()<low_lowest-plech*m_symbol.Point())
      low_lowest=m_symbol.Bid();
//---
   if(!trend && m_symbol.Bid()>low_lowest+plech*m_symbol.Point())
     {
      trend=true;
      high_highest=m_symbol.Bid();
      CloseAllPositions();
      double ush_sl=(SL_pp<=0)?0.0:plech*SL_pp;
      if(ush_sl<m_symbol.StopsLevel() && ush_sl<m_symbol.Spread())
         ush_sl=m_symbol.Spread()*3;
      double sl=m_symbol.Ask()-ush_sl*m_symbol.Point();
      OpenBuy(sl,0.0);
     }
   if(trend && m_symbol.Bid()<high_highest-plech*m_symbol.Point())
     {
      trend=false;
      low_lowest=m_symbol.Bid();
      CloseAllPositions();
      //---
      double ush_sl=(SL_pp<=0)?0.0:plech*SL_pp;
      if(ush_sl<m_symbol.StopsLevel() && ush_sl<m_symbol.Spread())
         ush_sl=m_symbol.Spread()*3;
      double sl=m_symbol.Bid()+ush_sl*m_symbol.Point();
      OpenSell(sl,0.0);
     }
//---

  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//---

  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates(void)
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
     {
      Print("RefreshRates error");
      return(false);
     }
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Check the correctness of the position volume                     |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &error_description)
  {
//--- minimal allowed volume for trade operations
   double min_volume=m_symbol.LotsMin();
   if(volume<min_volume)
     {
      error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }
//--- maximal allowed volume of trade operations
   double max_volume=m_symbol.LotsMax();
   if(volume>max_volume)
     {
      error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }
//--- get minimal step of volume changing
   double volume_step=m_symbol.LotsStep();
   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      error_description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                                     volume_step,ratio*volume_step);
      return(false);
     }
   error_description="Correct volume value";
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int iHighest(string symbol,
             ENUM_TIMEFRAMES timeframe,
             int type,
             int count=WHOLE_ARRAY,
             int start=0)
  {
   if(symbol==NULL)
      symbol=m_symbol.Name();
   if(timeframe==0)
      timeframe=Period();
   if(start<0)
      return(-1);
   if(count<=0)
      count=Bars(symbol,timeframe);
   if(type==MODE_HIGH)
     {
      double High[];
      ArraySetAsSeries(High,true);
      CopyHigh(symbol,timeframe,start,count,High);
      return(ArrayMaximum(High)+start);
     }
//---
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int iLowest(string symbol,
            ENUM_TIMEFRAMES timeframe,
            int type,
            int count=WHOLE_ARRAY,
            int start=0)
  {
   if(symbol==NULL)
      symbol=m_symbol.Name();
   if(timeframe==0)
      timeframe=Period();
   if(start<0)
      return(-1);
   if(count<=0)
      count=Bars(symbol,timeframe);
   if(type==MODE_LOW)
     {
      double Low[];
      ArraySetAsSeries(Low,true);
      CopyLow(symbol,timeframe,start,count,Low);
      return(ArrayMinimum(Low)+start);
     }
//---
   return(0);
  }
//+------------------------------------------------------------------+ 
//| Get the High for specified bar index                             | 
//+------------------------------------------------------------------+ 
double iHigh(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=m_symbol.Name();
   if(timeframe==0)
      timeframe=Period();
   double High[1];
   double high=0;
   int copied=CopyHigh(symbol,timeframe,index,1,High);
   if(copied>0)
      high=High[0];
   return(high);
  }
//+------------------------------------------------------------------+ 
//| Get Low for specified bar index                                  | 
//+------------------------------------------------------------------+ 
double iLow(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=m_symbol.Name();
   if(timeframe==0)
      timeframe=Period();
   double Low[1];
   double low=0;
   int copied=CopyLow(symbol,timeframe,index,1,Low);
   if(copied>0)
      low=Low[0];
   return(low);
  }
//+------------------------------------------------------------------+ 
//| Get Time for specified bar index                                 | 
//+------------------------------------------------------------------+ 
datetime iTime(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=m_symbol.Name();
   if(timeframe==0)
      timeframe=Period();
   datetime Time[1];
   datetime time=0; // datetime "0" -> D'1970.01.01 00:00:00'
   int copied=CopyTime(symbol,timeframe,index,1,Time);
   if(copied>0)
      time=Time[0];
   return(time);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool calc_vol(double &res)
  {
   res=0;
   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   int copied=CopyRates(m_symbol.Name(),Period(),0,InpPeriod,rates);
   if(copied!=InpPeriod)
      return(false);
   for(int i=0;i<InpPeriod;i++)
     {
      if(!OpenClose)
        {
         if(!InpExp)
            res+=(rates[i].high-rates[i].low)/m_symbol.Point();
         else res+=((rates[i].high-rates[i].low)/m_symbol.Point())*koef[i];
        }
      else
        {
         if(!InpExp)
            res+=MathAbs(rates[i].open-rates[i].close)/m_symbol.Point();
         else res+=(MathAbs(rates[i].open-rates[i].close)/m_symbol.Point())*koef[i];
        }
     }
   res/=InpPeriod;
   if(res<=0.0)
      res=1.0;
   return(res);
  }
//+------------------------------------------------------------------+
//| Close all positions                                              |
//+------------------------------------------------------------------+
void CloseAllPositions()
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),InpLots,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(check_volume_lot!=0.0)
     {
      if(check_volume_lot>=InpLots)
        {
         if(m_trade.Buy(InpLots,m_symbol.Name(),m_symbol.Ask(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print(__FUNCTION__,", #1 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
            else
              {
               Print(__FUNCTION__,", #2 Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
           }
         else
           {
            Print(__FUNCTION__,", #3 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResult(m_trade,m_symbol);
           }
        }
      else
        {
         Print(__FUNCTION__,", ERROR: method CheckVolume (",DoubleToString(check_volume_lot,2),") ",
               "< Lots (",DoubleToString(InpLots,2),")");
         return;
        }
     }
   else
     {
      Print(__FUNCTION__,", ERROR: method CheckVolume returned the value of \"0.0\"");
      return;
     }
//---
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
void OpenSell(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),InpLots,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
     {
      if(check_volume_lot>=InpLots)
        {
         if(m_trade.Sell(InpLots,m_symbol.Name(),m_symbol.Bid(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print(__FUNCTION__,", #1 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
            else
              {
               Print(__FUNCTION__,", #2 Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
           }
         else
           {
            Print(__FUNCTION__,", #3 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResult(m_trade,m_symbol);
           }
        }
      else
        {
         Print(__FUNCTION__,", ERROR: method CheckVolume (",DoubleToString(check_volume_lot,2),") ",
               "< Lots (",DoubleToString(InpLots,2),")");
         return;
        }
     }
   else
     {
      Print(__FUNCTION__,", ERROR: method CheckVolume returned the value of \"0.0\"");
      return;
     }
//---
  }
//+------------------------------------------------------------------+
//| Print CTrade result                                              |
//+------------------------------------------------------------------+
void PrintResult(CTrade &trade,CSymbolInfo &symbol)
  {
   Print("Code of request result: "+IntegerToString(trade.ResultRetcode()));
   Print("code of request result: "+trade.ResultRetcodeDescription());
   Print("deal ticket: "+IntegerToString(trade.ResultDeal()));
   Print("order ticket: "+IntegerToString(trade.ResultOrder()));
   Print("volume of deal or order: "+DoubleToString(trade.ResultVolume(),2));
   Print("price, confirmed by broker: "+DoubleToString(trade.ResultPrice(),symbol.Digits()));
   Print("current bid price: "+DoubleToString(trade.ResultBid(),symbol.Digits()));
   Print("current ask price: "+DoubleToString(trade.ResultAsk(),symbol.Digits()));
   Print("broker comment: "+trade.ResultComment());
   int d=0;
  }
//+------------------------------------------------------------------+

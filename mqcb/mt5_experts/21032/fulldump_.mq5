//+------------------------------------------------------------------+
//|                            FullDump(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
#property copyright "FORTRADER.RU"
#property link      "http://FORTRADER.RU"
#property version   "1.000"
//---
#define MODE_LOW 1
#define MODE_HIGH 2
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//--- input parameters
input double   InpLots           = 0.1;      // Lots
input int      BB_bands_period   = 20;       // Bands: period for average line calculation 
input int      RSI_ma_period     = 14;       // RSI: averaging period 
input ushort   IndentHL          = 10;       // Indent from High and Low
input uchar    Depth             = 6;        // Depth of search (in bars)
ulong          m_magic           = 1956924;  // magic number
//---
ulong          m_slippage=10;                // slippage

double         ExtIndentHL=0.0;

int            handle_iBands;                // variable for storing the handle of the iBands indicator 
int            handle_iRSI;                  // variable for storing the handle of the iRSI indicator

double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
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
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   ExtIndentHL=IndentHL *m_adjusted_point;
//--- create handle of the indicator iBands
   handle_iBands=iBands(m_symbol.Name(),Period(),BB_bands_period,0,2.0,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iBands==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iBands indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iRSI
   handle_iRSI=iRSI(m_symbol.Name(),Period(),RSI_ma_period,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iRSI==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iRSI indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
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
//--- we work only at the time of the birth of new bar
   static datetime PrevBars=0;
   datetime time_0=Time(0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;
   if(!RefreshRates())
     {
      PrevBars=0;
      return;
     }
/*
Поиск сигнала на покупку в промежутке от бара #0 до #Depth of search:
1. RSI должен быть ниже 30. 
2. Цена должна достичь самой нижней полосы Боллинджера. 
3. Ждем, пока свеча переместится выше средней полосы Болинджера. 
4. СтопЛосс размещается ниже последнего локального минимума.
   Тейк профит размещается выше верхней полосы Болинджера.
5. При достижении верхней линии необходимо перевести стоп в точку безубыточности. 

Поиск сигнала на продажу в промежутке от бара #0 до #Depth of search:
1. RSI должен быть больше 70. 
2. Цена должна достичь верхней полосы Боллинджера. 
3. Ждем, пока свеча переместится ниже средней полосы Болинджера. 
4. СтопЛосс размещается выше последнего локального максимума. 
   Тейк профит размещается ниже нижней полосы Болинджера.
5. При достижении нижней линии перемещаем стоп в точку безубыточности. 
*/
   double array_rsi[];
   ArraySetAsSeries(array_rsi,true);
   if(!iRSIGetArray(0,Depth,array_rsi))
      return;
//--- step  1
//--- BUY:  1. RSI должен быть ниже 30. 
//--- SELL: 1. RSI должен быть больше 70. 
   bool buy_step_1   = false;
   bool sell_step_1  = false;

   for(int i=0;i<Depth;i++)
     {
      if(array_rsi[i]<30.0 && !buy_step_1)
         buy_step_1=true;

      if(array_rsi[i]>70.0 && !sell_step_1)
         sell_step_1=true;
     }
//--- step  2
//--- BUY:  2. Цена должна достичь самой нижней полосы Боллинджера. 
//--- SELL: 2. Цена должна достичь верхней полосы Боллинджера. 
   bool buy_step_2   = false;
   bool sell_step_2  = false;

   double array_bands_upper[];
   ArraySetAsSeries(array_bands_upper,true);
   if(!iBandsGetArray(UPPER_BAND,0,Depth,array_bands_upper))
      return;

   double array_bands_lower[];
   ArraySetAsSeries(array_bands_lower,true);
   if(!iBandsGetArray(LOWER_BAND,0,Depth,array_bands_lower))
      return;

   for(int i=0;i<Depth;i++)
     {
      if(m_symbol.Ask()<=array_bands_lower[i] && !buy_step_2)
         buy_step_2=true;
      if(m_symbol.Bid()>=array_bands_upper[i] && !sell_step_2)
         sell_step_2=true;
     }
//--- step  3
//--- BUY:  3. Ждем, пока свеча переместится выше средней полосы Болинджера. 
//--- SELL: 3. Ждем, пока свеча переместится ниже средней полосы Болинджера. 
   bool buy_step_3   = false;
   bool sell_step_3  = false;

   double array_bands_base[];
   if(!iBandsGetArray(BASE_LINE,0,1,array_bands_base))
      return;

   if(m_symbol.Ask()>=array_bands_base[0])
      buy_step_3=true;
   if(m_symbol.Bid()<=array_bands_base[0])
      sell_step_3=true;
//--- step  4
//--- 4. СтопЛосс размещается ниже последнего локального минимума.
//---    Тейк профит размещается выше верхней полосы Болинджера.
//--- SELL: 4. СтопЛосс размещается выше последнего локального максимума.
//---    Тейк профит размещается ниже нижней полосы Болинджера.
   if(buy_step_1 && buy_step_2 && buy_step_3)
     {
      double lowest=Lowest(m_symbol.Name(),Period(),MODE_LOW,Depth,0);
      if(lowest!=-1)
        {
         double sl=lowest-ExtIndentHL;
         double tp=array_bands_upper[0]+ExtIndentHL;
         OpenBuy(sl,tp);
        }
     }
   if(sell_step_1 && sell_step_2 && sell_step_3)
     {
      double highest=Highest(m_symbol.Name(),Period(),MODE_HIGH,Depth,0);
      if(highest!=-1)
        {
         double sl=highest+ExtIndentHL;
         double tp=array_bands_lower[0]-ExtIndentHL;
         OpenSell(sl,tp);
        }
     }
//--- step 5
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
               if(m_position.PriceCurrent()>=array_bands_upper[0] && 
                  !CompareDoubles(m_position.StopLoss(),m_position.PriceOpen(),m_symbol.Digits()))
                  if(!m_trade.PositionModify(m_position.Ticket(),
                     m_position.PriceOpen(),
                     m_position.TakeProfit()))
                     Print("Modify ",m_position.Ticket(),
                           " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());

            if(m_position.PositionType()==POSITION_TYPE_SELL)
               if(m_position.PriceCurrent()<=array_bands_lower[0] && 
                  !CompareDoubles(m_position.StopLoss(),m_position.PriceOpen(),m_symbol.Digits()))
                  if(!m_trade.PositionModify(m_position.Ticket(),
                     m_position.PriceOpen(),
                     m_position.TakeProfit()))
                     Print("Modify ",m_position.Ticket(),
                           " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
           }
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
      if(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")
         error_description=StringFormat("Объем меньше минимально допустимого SYMBOL_VOLUME_MIN=%.2f",min_volume);
      else
         error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }
//--- maximal allowed volume of trade operations
   double max_volume=m_symbol.LotsMax();
   if(volume>max_volume)
     {
      if(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")
         error_description=StringFormat("Объем больше максимально допустимого SYMBOL_VOLUME_MAX=%.2f",max_volume);
      else
         error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }
//--- get minimal step of volume changing
   double volume_step=m_symbol.LotsStep();
   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      if(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")
         error_description=StringFormat("Объем не кратен минимальному шагу SYMBOL_VOLUME_STEP=%.2f, ближайший правильный объем %.2f",
                                        volume_step,ratio*volume_step);
      else
         error_description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                                        volume_step,ratio*volume_step);
      return(false);
     }
   error_description="Correct volume value";
   return(true);
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
//| Get Time for specified bar index                                 | 
//+------------------------------------------------------------------+ 
datetime Time(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
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
//| Get value of buffers for the iBands in the array                 |
//|  the buffer numbers are the following:                           |
//|   0 - BASE_LINE, 1 - UPPER_BAND, 2 - LOWER_BAND                  |
//+------------------------------------------------------------------+
double iBandsGetArray(const int buffer,const int start_pos,const int count,double &arr_buffer[])
  {
//---
   bool result=true;
   if(!ArrayIsDynamic(arr_buffer))
     {
      Print("This a no dynamic array!");
      return(false);
     }
   ArrayFree(arr_buffer);
   int       buffer_num=0;          // indicator buffer number 
//--- reset error code 
   ResetLastError();
//--- fill a part of the iBands array with values from the indicator buffer
   int copied=CopyBuffer(handle_iBands,buffer,start_pos,count,arr_buffer);
   if(copied<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iBands indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false);
     }
   return(result);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iRSI in the array                   |
//+------------------------------------------------------------------+
bool iRSIGetArray(const int start_pos,const int count,double &arr_buffer[])
  {
//---
   bool result=true;
   if(!ArrayIsDynamic(arr_buffer))
     {
      Print("This a no dynamic array!");
      return(false);
     }
   ArrayFree(arr_buffer);
   int       buffer_num=0;          // indicator buffer number 
//--- reset error code 
   ResetLastError();
//--- fill a part of the iRSIBuffer array with values from the indicator buffer
   int copied=CopyBuffer(handle_iRSI,buffer_num,start_pos,count,arr_buffer);
   if(copied<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iRSI indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false);
     }
//---
   return(result);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Highest(string symbol,
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
      if(CopyHigh(symbol,timeframe,start,count,High)!=count)
         return(-1);
      return(High[ArrayMaximum(High)]);
     }
//---
   return(-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Lowest(string symbol,
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
      if(CopyLow(symbol,timeframe,start,count,Low)!=count)
         return(-1);
      return(Low[ArrayMinimum(Low)]);
     }
//---
   return(-1);
  }
//+------------------------------------------------------------------+
//| Compare doubles                                                  |
//+------------------------------------------------------------------+
bool CompareDoubles(double number1,double number2,int digits)
  {
   digits--;
   if(digits<0)
      digits=0;
   if(NormalizeDouble(number1-number2,digits)==0)
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+

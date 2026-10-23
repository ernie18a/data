//+------------------------------------------------------------------+
//|                 IStochastic_Trading(barabashkakvn's edition).mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//--- input parameters
input double   InpLots           = 0.1;      // Lots 
input ushort   InpTakeProfit     = 50;       // Take Profit
input ushort   InpStopLoss       = 50;       // Stop Loss (in pips)
input ushort   InpTrailingStop   = 10;       // Trailing Stop (in pips) (if "0" the parameter is off)
ushort         InpTrailingStep   = 5;        // Trailing Step (in pips)
input double   InpMaxPositions   = 3;        // Max Positions (if "0" the parameter is off)
input ushort   InpGap            = 7;        // Gap
input int      InpKperiod        = 5;        // K-period (number of bars for calculations) 
input int      InpDperiod        = 3;        // D-period (period of first smoothing)
input int      Inpslowing        = 3;        // final smoothing 
input double   zoneBUY           = 30;
input double   zoneSELL          = 70;
//---
ulong          m_magic=798503024;            // magic number
ulong          m_slippage=30;                // slippage
double         ExtTakeProfit=0;
double         ExtStopLoss=0;
double         ExtTrailingStop=0;
double         ExtTrailingStep=0;
double         ExtGap=0;
int            handle_iStochastic;           // variable for storing the handle of the iStochastic indicator 
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   RefreshRates();
   m_symbol.Refresh();

   string err_text="";
   if(!CheckVolumeValue(InpLots,err_text))
     {
      Print(err_text);
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   m_trade.SetExpertMagicNumber(m_magic);
//---
   if(IsFillingTypeAllowed(Symbol(),SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(Symbol(),SYMBOL_FILLING_IOC))
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      m_trade.SetTypeFilling(ORDER_FILLING_RETURN);
//---
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   ExtTakeProfit  = InpTakeProfit   * m_adjusted_point;
   ExtStopLoss    = InpStopLoss     * m_adjusted_point;
   ExtTrailingStop= InpTrailingStop * m_adjusted_point;
   ExtTrailingStep= InpTrailingStep * m_adjusted_point;
   ExtGap         = InpGap          * m_adjusted_point;
//--- create handle of the indicator iStochastic
   handle_iStochastic=iStochastic(m_symbol.Name(),Period(),InpKperiod,InpDperiod,Inpslowing,MODE_SMA,STO_LOWHIGH);
//--- if the handle is not created 
   if(handle_iStochastic==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iStochastic indicator for the symbol %s/%s, error code %d",
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
//---
   int total=0;
   ENUM_POSITION_TYPE last_position_type=-1;
   datetime last_position_time=0;
   double last_position_price_open=0.0;
   double last_position_volume=0.0;
//---
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            total++;
            if(total==1)
              {
               last_position_type=m_position.PositionType();
               last_position_time=m_position.Time();
               last_position_price_open=m_position.PriceOpen();
               last_position_volume=m_position.Volume();
              }
            if(InpTrailingStop==0.0)
               continue;
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(m_position.StopLoss()<m_symbol.Bid()-(ExtTrailingStop+ExtTrailingStep))
                 {
                  if(!m_trade.PositionModify(m_position.Ticket(),
                     m_symbol.NormalizePrice(m_symbol.Bid()-ExtTrailingStop),
                     m_position.TakeProfit()))
                     Print("Modify ",m_position.Ticket(),
                           " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                 }
              }
            else
              {
               if((m_position.StopLoss()>(m_symbol.Ask()+(ExtTrailingStop+ExtTrailingStep))) || 
                  (m_position.StopLoss()==0))
                 {
                  if(!m_trade.PositionModify(m_position.Ticket(),
                     m_symbol.NormalizePrice(m_symbol.Ask()+ExtTrailingStop),
                     m_position.TakeProfit()))
                     Print("Modify ",m_position.Ticket(),
                           " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                 }
              }
           }
//--- Open position
   if(total==0)
     {
      double iStochastic_main_1  = iStochasticGet(MAIN_LINE,1);
      double iStochastic_signal_1= iStochasticGet(SIGNAL_LINE,1);
      if(iStochastic_main_1>iStochastic_signal_1 && iStochastic_signal_1<zoneBUY)
        {
         if(!RefreshRates())
            return;
         double sl=m_symbol.Bid()-ExtStopLoss;
         double tp=m_symbol.Bid()+ExtTakeProfit;
         OpenBuy(sl,tp,InpLots);
         return;
        }
      if(iStochastic_main_1<iStochastic_signal_1 && iStochastic_signal_1>zoneSELL)
        {
         if(!RefreshRates())
            return;
         double sl=m_symbol.Ask()+ExtStopLoss;
         double tp=m_symbol.Ask()-ExtTakeProfit;
         OpenSell(sl,tp,InpLots);
         return;
        }
     }
   else if(total>0 && total<InpMaxPositions)
     {
      if(!RefreshRates())
         return;
      if(last_position_type==POSITION_TYPE_BUY)
        {
         double price=m_symbol.Ask();
         if((last_position_price_open-ExtGap)>price)
           {
            // lot * 2
            double sl=m_symbol.Bid()-ExtStopLoss;
            double tp=m_symbol.Bid()+ExtTakeProfit;
            OpenBuy(sl,tp,last_position_volume*2);
            return;
           }
        }
      else if(last_position_type==POSITION_TYPE_SELL)
        {
         double price=m_symbol.Bid();
         if((last_position_price_open+ExtGap)<price)
           {
            // lot * 2
            double sl=m_symbol.Ask()+ExtStopLoss;
            double tp=m_symbol.Ask()-ExtTakeProfit;
            OpenSell(sl,tp,last_position_volume*2);
            return;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates()
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
      return(false);
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Check the correctness of the order volume                        |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &error_description)
  {
//--- minimal allowed volume for trade operations
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<min_volume)
     {
      error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }

//--- maximal allowed volume of trade operations
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
     {
      error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }

//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);

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
//| Checks if the specified filling mode is allowed                  | 
//+------------------------------------------------------------------+ 
bool IsFillingTypeAllowed(string symbol,int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=(int)SymbolInfoInteger(symbol,SYMBOL_FILLING_MODE);
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iStochastic                         |
//|  the buffer numbers are the following:                           |
//|   0 - MAIN_LINE, 1 - SIGNAL_LINE                                 |
//+------------------------------------------------------------------+
double iStochasticGet(const int buffer,const int index)
  {
   double Stochastic[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iStochasticBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iStochastic,buffer,index,1,Stochastic)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iStochastic indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Stochastic[0]);
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double sl,double tp,double volume)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   volume=LotCheck(volume);
   if(volume==0.0)
      return;

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),volume,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=volume)
        {
         if(m_trade.Buy(volume,NULL,m_symbol.Ask(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            else
              {
               Print("Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
           }
         else
           {
            Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
           }
        }
//---
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
void OpenSell(double sl,double tp,double volume)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   volume=LotCheck(volume);
   if(volume==0.0)
      return;

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),volume,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=volume)
        {
         if(m_trade.Sell(volume,NULL,m_symbol.Bid(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            else
              {
               Print("Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
           }
         else
           {
            Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
           }
        }
//---
  }
//+------------------------------------------------------------------+
//| Lot Check                                                        |
//+------------------------------------------------------------------+
double LotCheck(double lots)
  {
//--- calculate maximum volume
   double volume=NormalizeDouble(lots,2);
   double stepvol=m_symbol.LotsStep();
   if(stepvol>0.0)
      volume=stepvol*MathFloor(volume/stepvol);
//---
   double minvol=m_symbol.LotsMin();
   if(volume<minvol)
      volume=0.0;
//---
   double maxvol=m_symbol.LotsMax();
   if(volume>maxvol)
      volume=maxvol;
   return(volume);
  }
//+------------------------------------------------------------------+

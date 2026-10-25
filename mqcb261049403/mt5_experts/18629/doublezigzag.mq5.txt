//+------------------------------------------------------------------+
//|                        DoubleZigZag(barabashkakvn's edition).mq5 |
//|                                                         Maksimus |
//+------------------------------------------------------------------+
#property copyright "Maksimus"
#property link      ""
#property version   "1.007"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//--- input parameters
input double   InpLots=0.1;      // Lots
input double   k                 = 2.1;
input double   k2                = 2.1;
//---
datetime LastOpenTime=0;
double Ppoint=1888.0;
double Spoint=1888.0;
double Bpoint=888.0;
//---
ulong          m_magic=15489;                // magic number
ulong          m_slippage=30;                // slippage
int            handle_iCustom;               // variable for storing the handle of the Custom indicator 
int            handle_iCustomX8;             // variable for storing the handle of the Custom indicator 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(InpLots<=0.0)
     {
      Print("The \"volume transaction\" can't be smaller or equal to zero");
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   RefreshRates();
   m_symbol.Refresh();
//---
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
//--- create handle of the indicator iCustom
   handle_iCustom=iCustom(Symbol(),Period(),"Examples\\ZigZag",13,5,3);
//--- if the handle is not created 
   if(handle_iCustom==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iCustom indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iCustom
   handle_iCustomX8=iCustom(Symbol(),Period(),"Examples\\ZigZag",13*8,5*8,3*8);
//--- if the handle is not created 
   if(handle_iCustomX8==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iCustomX8 indicator for the symbol %s/%s, error code %d",
                  Symbol(),
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
   datetime time_0=iTime(m_symbol.Name(),Period(),0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;
//---
   double a=0.0;
   int tik=0;

   int i;
   double a0=0.0,b0=0.0;
   double au=0.0,bu=0.0;
   double ad=0.0,bd=0.0;
   int z=0,p=0,up=0,dw=0;
   double vu[3]={0.0,0.0,0.0};
   double vd[3]={0.0,0.0,0.0};

   datetime time_h1_0=iTime(m_symbol.Name(),PERIOD_H1,0);
   MqlDateTime str1;
   TimeToStruct(time_h1_0,str1);

   int bars_calculated_custom=BarsCalculated(handle_iCustom);
   int bars_calculated_customX8=BarsCalculated(handle_iCustomX8);
   int limit=(bars_calculated_custom<bars_calculated_customX8)?bars_calculated_custom:bars_calculated_customX8;
   limit=(limit<8888)?limit:8888;
   for(i=1;i<8888;i++)
     {
      a0=iCustomGet(handle_iCustom,0,i);
      b0=iCustomGet(handle_iCustomX8,0,i);

      au=iCustomGet(handle_iCustom,1,i);
      bu=iCustomGet(handle_iCustomX8,1,i);

      ad=iCustomGet(handle_iCustom,2,i);
      bd=iCustomGet(handle_iCustomX8,2,i);

      if(a0==b0 && au==bu && a0!=0 && a0==au)
        {
         vu[z]=a0;
         p=1;
         z++;
        }
      if(a0==b0 && ad==bd && a0!=0 && a0==ad)
        {
         vd[z]=a0;
         p=-1;
         z++;
        }
      if(z>2)
         break;

      if(a0!=0 && p==1 && (a0==au || a0==ad))
         up++;
      if(a0!=0 && p==-1 && (a0==au || a0==ad))
         dw++;
     }
   if(z<2)
     {
      Print("Мало вершин");
      return;
     }

   if(up>dw*k && vu[0]>vd[1] && vu[2]>vd[1] && vd[1]>0 && (vu[2]-vd[1])*k2<vu[0]-vd[1])
     {
      ClosePositions(POSITION_TYPE_SELL);
      if(CalculatePositions()==0)
         if(RefreshRates())
            OpenBuy(0.0,0.0);
     }

   if(up*k<dw && vd[0]<vu[1] && vd[2]<vu[1] && vu[1]>0 && (vu[1]-vd[2])*k2<vu[1]-vd[0])
     {
      ClosePositions(POSITION_TYPE_BUY);
      if(CalculatePositions()==0)
         if(RefreshRates())
            OpenSell(0.0,0.0);
     }
//---
  }
////+------------------------------------------------------------------+
////|                                                                  |
////+------------------------------------------------------------------+
//void ordercl(int p)
//  {
//   int i;
//
//   int total=OrdersTotal();
//
//   for(i=0; i<total; i++)
//     {
//      if(OrderSelect(i,SELECT_BY_POS)==true)
//        {
//         // if((TimeCurrent()-OrderOpenTime())<24*60*60) return(1);
//
//         if((OrderType()==OP_SELL) && (p==-1))
//           {
//
//            OrderClose(OrderTicket(),OrderLots(),Ask,5,Blue);
//           }
//
//         if((OrderType()==OP_BUY) && (p==1))
//           {
//
//            OrderClose(OrderTicket(),OrderLots(),Bid,5,Blue);
//           }
//
//         if((OrderType()==OP_SELLLIMIT) && (p==-1))
//           {
//            OrderDelete(OrderTicket());
//           }
//
//         if((OrderType()==OP_BUYLIMIT) && (p==1))
//           {
//            OrderDelete(OrderTicket());
//           }
//
//         if((OrderType()==OP_SELLSTOP) && (p==-1))
//           {
//            OrderDelete(OrderTicket());
//           }
//
//         if((OrderType()==OP_BUYSTOP) && (p==1))
//           {
//            OrderDelete(OrderTicket());
//           }
//
//        }
//
//     }
//   if((p==1) && (ch(1)==1))
//      ordercl(1);
//   if((p==-1) && (ch(-1)==1))
//      ordercl(-1);
//
//  }
//+------------------------------------------------------------------+
//| Close Positions                                                  |
//+------------------------------------------------------------------+
void ClosePositions(ENUM_POSITION_TYPE pos_type)
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            if(m_position.PositionType()==pos_type) // gets the position type
               m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
////+------------------------------------------------------------------+
////|                                                                  |
////+------------------------------------------------------------------+
//double ch(int p)
//  {
//
//   int i;
//   int total=OrdersTotal();
//
//   for(i=0; i<total; i++)
//     {
//      if(OrderSelect(i,SELECT_BY_POS)==true)
//        {
//         // if((TimeCurrent()-OrderOpenTime())<24*60*60) return(1);
//
//         if((OrderType()==OP_SELL) && (p==-1))
//           {
//
//            return (1);
//           }
//
//         if((OrderType()==OP_BUY) && (p==1))
//           {
//
//            return (1);
//           }
//         if((OrderType()==OP_SELLLIMIT) && (p==-1))
//           {
//
//            return (1);
//           }
//
//         if((OrderType()==OP_BUYLIMIT) && (p==1))
//           {
//
//            return (1);
//           }
//
//        }
//
//     }
//   return(0);
//  }
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
//| Get value of buffers for the iCustom                             |
//|  the buffer numbers are the following:                           |
//+------------------------------------------------------------------+
double iCustomGet(int handle,const int buffer,const int index)
  {
   double Custom[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iCustom array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle,buffer,index,1,Custom)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iCustom indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Custom[0]);
  }
//+------------------------------------------------------------------+
//| Calculate positions                                              |
//+------------------------------------------------------------------+
int CalculatePositions()
  {
   int total=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            total++;
//---
   return(total);
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
      if(check_volume_lot>=InpLots)
        {
         if(m_trade.Buy(InpLots,NULL,m_symbol.Ask(),sl,tp))
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
void OpenSell(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),InpLots,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=InpLots)
        {
         if(m_trade.Sell(InpLots,NULL,m_symbol.Bid(),sl,tp))
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

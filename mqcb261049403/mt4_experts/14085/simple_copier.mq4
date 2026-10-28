//+------------------------------------------------------------------+
//|                                                    Simple Copier |
//|                                Copyright 2015, Vladimir V. Tkach |
//+------------------------------------------------------------------+
#property version "1.2"
#property copyright "Copyright © 2015, Vladimir V. Tkach"
#property description "Trades copying utility with multiplyer."
#property strict
//+------------------------------------------------------------------+
//| Enumerator of working mode                                       |
//+------------------------------------------------------------------+
enum copier_mode
  {
   master,
   slave,
  };

input copier_mode mode=0;  // Working mode
input int slip=10;         // Slippage (in pips)
input double mult=1.0;     // Multiplyer (for slave)

int
opened_list[500],
ticket,
type,
filehandle;

string
symbol;

double
lot,
price,
sl,
tp;
//+------------------------------------------------------------------+
//|Initialisation function                                           |
//+------------------------------------------------------------------+          
void init()
  {
   ObjectsDeleteAll();
   EventSetTimer(1);
   return;
  }
//+------------------------------------------------------------------+
//|Deinitialisation function                                         |
//+------------------------------------------------------------------+
void deinit()
  {
   ObjectsDeleteAll();
   EventKillTimer();
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(!ObjectFind("mode") || ObjectDescription("mode")!=EnumToString(mode))
     {
      ObjectDelete("mode");
      ObjectCreate("mode",OBJ_LABEL,0,0,0);
      ObjectSet("mode",OBJPROP_XDISTANCE,10);
      ObjectSet("mode",OBJPROP_YDISTANCE,10);
      ObjectSet("mode",OBJPROP_COLOR,Red);
      ObjectSetText("mode",EnumToString(mode));
      ObjectSet("mode",OBJPROP_FONTSIZE,10);
     }

//--- Master working mode
   if(EnumToString(mode)=="master")
     {
      //--- Saving information about opened deals
      if(OrdersTotal()==0)
        {
         filehandle=FileOpen("C4F.csv",FILE_WRITE|FILE_CSV|FILE_COMMON);
         FileWrite(filehandle,"");
         FileClose(filehandle);
        }
      else
        {
         filehandle=FileOpen("C4F.csv",FILE_WRITE|FILE_CSV|FILE_COMMON);

         if(filehandle!=INVALID_HANDLE)
           {
            for(int i=0; i<OrdersTotal(); i++)
              {
               if(!OrderSelect(i,SELECT_BY_POS)) break;
               symbol=OrderSymbol();

               if(StringSubstr(OrderComment(),0,3)!="C4F") FileWrite(filehandle,OrderTicket(),symbol,OrderType(),OrderOpenPrice(),OrderLots(),OrderStopLoss(),OrderTakeProfit());
               FileFlush(filehandle);
              }
            FileClose(filehandle);
           }
        }
     }

//--- Slave working mode
   if(EnumToString(mode)=="slave")
     {
      //--- Checking for the new deals and stop loss/take profit changes
      filehandle=FileOpen("C4F.csv",FILE_READ|FILE_CSV|FILE_COMMON);

      if(filehandle!=INVALID_HANDLE)
        {
         int o=0;
         opened_list[o]=0;

         while(!FileIsEnding(filehandle))
           {
            ticket=StrToInteger(FileReadString(filehandle));
            symbol=FileReadString(filehandle);
            type=StrToInteger(FileReadString(filehandle));
            price=StrToDouble(FileReadString(filehandle));
            lot=StrToDouble(FileReadString(filehandle))*mult;
            sl=StrToDouble(FileReadString(filehandle));
            tp=StrToDouble(FileReadString(filehandle));

            string
            OrdComm="C4F"+IntegerToString(ticket);

            for(int i=0; i<OrdersTotal(); i++)
              {
               if(!OrderSelect(i,SELECT_BY_POS)) continue;

               if(OrderComment()!=OrdComm) continue;

               opened_list[o]=ticket;
               opened_list[o+1]=0;
               o++;

               if(OrderType()>1 && OrderOpenPrice()!=price)
                 {
                  if(!OrderModify(OrderTicket(),price,0,0,0))
                     Print("Error: ",GetLastError()," during modification of the order.");
                 }

               if(tp!=OrderTakeProfit() || sl!=OrderStopLoss())
                 {
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),sl,tp,0))
                     Print("Error: ",GetLastError()," during modification of the order.");
                 }
               break;
              }

            //--- If deal was not opened yet on slave-account, open it.
            if(InList(ticket)==-1 && ticket!=0)
              {
               FileClose(filehandle);
               if(type<2) OpenMarketOrder(ticket,symbol,type,price,lot);
               if(type>1) OpenPendingOrder(ticket,symbol,type,price,lot);
               return;
              }
           }
         FileClose(filehandle);
        }
      else return;

      //--- If deal was closed on master-account, close it on slave-accont
      for(int i=0; i<OrdersTotal(); i++)
        {
         if(!OrderSelect(i,SELECT_BY_POS)) continue;

         if(StringSubstr(OrderComment(),0,3)!="C4F") continue;

         if(InList(StrToInteger(StringSubstr(OrderComment(),StringLen("C4F"),0)))==-1)
           {
            if(OrderType()==0)
              {
               if(!OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),slip))
                  Print("Error: ",GetLastError()," during closing the order.");
              }
            else if(OrderType()==1)
              {
               if(!OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),slip))
                  Print("Error: ",GetLastError()," during closing the order.");
              }
            else if(OrderType()>1)
              {
               if(!OrderDelete(OrderTicket()))
                  Print("Error: ",GetLastError()," during deleting the pending order.");
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|Checking list                                                     |
//+------------------------------------------------------------------+
int InList(int ticket_)
  {
   int h=0;

   while(opened_list[h]!=0)
     {
      if(opened_list[h]==ticket_) return(1);
      h++;
     }
   return(-1);
  }
//+------------------------------------------------------------------+
//|Open market execution orders                                      |
//+------------------------------------------------------------------+
void OpenMarketOrder(int ticket_,string symbol_,int type_,double price_,double lot_)
  {
   double market_price=MarketInfo(symbol_,MODE_BID);
   if(type_==0) market_price=MarketInfo(symbol_,MODE_ASK);

   double delta;

   delta=MathAbs(market_price-price_)/MarketInfo(symbol_,MODE_POINT);
   if(delta>slip) return;

   if(!OrderSend(symbol_,type_,LotNormalize(lot_),market_price,slip,0,0,"C4F"+IntegerToString(ticket_))) Print("Error: ",GetLastError()," during opening the market order.");
   return;
  }
//+------------------------------------------------------------------+
//|Open pending orders                                               |
//+------------------------------------------------------------------+
void OpenPendingOrder(int ticket_,string symbol_,int type_,double price_,double lot_)
  {
   if(!OrderSend(symbol_,type_,LotNormalize(lot_),price_,slip,0,0,"C4F"+IntegerToString(ticket_))) Print("Error: ",GetLastError()," during setting the pending order.");
   return;
  }
//+------------------------------------------------------------------+
//|Normalize lot size                                                |
//+------------------------------------------------------------------+
double LotNormalize(double lot_)
  {
   double minlot=MarketInfo(symbol,MODE_MINLOT);

   if(minlot==0.001)      return(NormalizeDouble(lot_,3));
   else if(minlot==0.01)  return(NormalizeDouble(lot_,2));
   else if(minlot==0.1)   return(NormalizeDouble(lot_,1));

   return(NormalizeDouble(lot_,0));
  }
//+------------------------------------------------------------------+

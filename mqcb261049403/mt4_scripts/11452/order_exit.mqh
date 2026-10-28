//+------------------------------------------------------------------+
//|                                                   order_exit.mq4 |
//|                                                   Enrico Lambino |
//|                                          enricolambino@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum position {BUY,SELL,BUYLIMIT,SELLLIMIT,BUYSTOP,SELLSTOP,ALL_MARKET,ALL_PENDING,ALL};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
char exitOrder(int i,int select=SELECT_BY_POS,bool exact=false,int magic=-1,string symbol=NULL,position type=ALL,double loss=-1,double profit=-1,string comment=NULL)
  {
   char res=-1;
   bool symbol_match=true,comment_match=true,magic_match=true,type_match=true;
   bool profit_match=true,loss_match=true;
   if(!OrderSelect(i,select)) return(res);
   if(type<=5)
     {
      if(type!=OrderType()) type_match=false;
     }
   else
     {
      if(type==ALL_MARKET)
        {
         if(OrderType()>1) type_match=false;
        }
      else if(type==ALL_PENDING)
        {
         if(OrderType()<=1) type_match=false;
        }
     }
   if(exact)
     {
      if(!type_match)
        {
         Print(OrderTicket()," type_match not satisfied, type: ",type," order type: ",OrderType());
         return(res);
        }
     }
   if(symbol!=NULL && symbol!="" && symbol!=OrderSymbol())
     {
      if(exact)
        {
         Print(OrderTicket()," symbol not satisfied, symbol: ",symbol," order symbol: ",OrderSymbol());
         return(res);
        }
      else symbol_match=false;
     }
   if(comment!=NULL && comment!="" && comment!=OrderComment())
     {
      if(exact)
        {
         Print(OrderTicket()," comment not satisfied, comment: ",comment," order comment: ",OrderComment());
         return(res);
        }
      else comment_match=false;
     }
   if((magic>=0) && magic!=OrderMagicNumber())
     {
      if(exact)
        {
         Print(OrderTicket()," magic not satisfied, magic: ",magic," order magic: ",OrderMagicNumber());
         return(res);
        }
      else magic_match=false;
     }

   if(loss>=0 && profit>=0)
     {
      if(profit>OrderProfit() && -loss<OrderProfit())
        {
         if(exact)
           {
            Print(OrderTicket()," profit/loss not satisfied, order profit: ",DoubleToStr(OrderProfit(),2)," profit threshold: ",profit," loss threshold: ",loss);
            return(res);
           }
         else
           {
            profit_match=false;
            loss_match=false;
           }
        }
     }
   else if(loss>=0 && profit<0)
     {
      if(OrderProfit()>-loss)
        {
         if(exact)
           {
            Print(OrderTicket()," loss not satisfied, order profit: ",DoubleToStr(OrderProfit(),2)," loss threshold: ",loss);
            return(res);
           }
         else loss_match=false;
        }

     }
   else if(loss<0 && profit>=0)
     {
      if(profit>OrderProfit())
        {
         if(exact)
           {
            Print(OrderTicket()," profit not satisfied, order profit: ",DoubleToStr(OrderProfit(),2)," profit threshold: ",profit);
            return(res);
           }
         else profit_match=false;
        }

     }

   if(!exact)
      if(!(symbol_match || comment_match || magic_match || type_match || loss_match || profit_match))
         return(res);
   Print("closing #",OrderTicket()," symbol_match: ",symbol_match," comment_match: ",comment_match," magic_match: ",magic_match," type_match: ",type_match," loss_match: ",loss_match," profit_match: ",profit_match);

   if(OrderType()<=1)
      res=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),1000);
   else if(OrderType()>1)
      res=OrderDelete(OrderTicket());

   if(res) Sleep(500);
   return(res);
  }
//+------------------------------------------------------------------+

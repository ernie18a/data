//+------------------------------------------------------------------+
//|                                                   pile_face.mq4  |
//|                                     Copyright 2017, Charly Oudy. |
//+------------------------------------------------------------------+
#property copyright   "2018, Charly Oudy."
#property description "Coin Flipping EA"

#define MAGICNUM  20131111

// Define our Parameters
input double Risque        = 2;    // % of your capital invested on each position
input int TakeProfit       = 20;   // The take profit pips distance
input int StopLoss         = 10;   // The stop loss pips distance
//+------------------------------------------------------------------+
//| expert initialization functions                                  |
//+------------------------------------------------------------------+
int init()
  {
   MathSrand(GetTickCount());  //Initialise the random number system
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| To know how many positions are opened by this robot on this pair |
//+------------------------------------------------------------------+
int Nb_Positions()
  {
   int total=OrdersTotal(); // We get the numbers of positions now
   int count= 0;
   int pos;

   if(total==0)
     {
      return total;
     }

// scan each opened positions to check if it is opened by this EA
   for(pos=0;pos<total;pos++) 
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=MAGICNUM) continue;
      count++;
     }

// return the number of opened positions.
   return count;
  }
//+------------------------------------------------------------------+
//+ Coin Flipping Robot                                              |
//+------------------------------------------------------------------+
int start()
  {
   int positionsOuvertes=Nb_Positions();       // Is there a position already opened ?                                     

   if(positionsOuvertes<1)
     {
      // Variables we will need
      int ticket,typeOrdre;

      // Define the order type	
      int numeroAleatoire=MathRand();         // generate 1 random number

      if(numeroAleatoire%2==0)
        {              // if this random number is even
         typeOrdre=1;                          // then it will be a BUY
        }
      else
        {                                     // or odd
         typeOrdre= 2;                          // then it will be a SELL
        }

      // Calculate Stop Loss and Take profit
      if(StopLoss>0)
        {
         double ShortSL = Bid+(StopLoss*Point);
         double LongSL  = Ask-(StopLoss*Point);
        }
      if(TakeProfit>0)
        {
         double ShortTP = Bid-(TakeProfit*Point);
         double LongTP  = Ask+(TakeProfit*Point);
        }

      // Calculate the position size according to the % of risk                   
      double taille=((AccountBalance()/100*Risque)/StopLoss)*Bid;
      taille=NormalizeDouble(taille,2);

      // BUY OR SELL
      if(typeOrdre==1)
        {         // BUY
         ticket=OrderSend(Symbol(),OP_BUY,taille,Ask,5,LongSL,LongTP,"Coin Flipping : Pair",MAGICNUM,0,Blue);
        }
      else
        {                        // SELL
         ticket=OrderSend(Symbol(),OP_SELL,taille,Bid,5,ShortSL,ShortTP,"Coin Flipping : Impair",MAGICNUM,0,Blue);
        }

      // Check the result
      if(ticket>0)
        {
         if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
           {
            Print("BUY Order Opened: ",OrderOpenPrice()," SL:",LongSL," TP: ",LongTP);
           }
         else
           {
            Print("Error Opening BUY  Order: ",GetLastError());
            return(0);
           }
        }
     }

   return(0);
  }
//+------------------------------------------------------------------+

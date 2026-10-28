//+------------------------------------------------------------------+
//|               Triangular Arbitrage EA Aggiornato                 |
//|                        Versione 1.02                             |
//+------------------------------------------------------------------+
#property strict
#property copyright "Copyright 2023"
#property version   "1.02"

// Inclusione della libreria per il trading
#include <Trade\Trade.mqh>
CTrade trade;

// Input parameters
input double   LotSize       = 0.01;     // Lotto utilizzato per ogni trade (ora 0.01)
input double   ProfitTarget  = 10.0;     // Profitto target (in valuta conto) per chiudere l'arbitraggio
input double   Threshold     = 0.0001;   // Soglia della differenza relativa (0.0001 equivale a 0.01%)
input int      MagicNumber   = 1001;     // Magic Number per identificare gli ordini dell'EA

// Definizione dei simboli (coppie di valute)
string symbol1 = "EURUSD"; // Coppia 1
string symbol2 = "USDJPY"; // Coppia 2
string symbol3 = "EURJPY"; // Coppia triangolata

//+------------------------------------------------------------------+
//| Funzione: GetValidLotSize                                        |
//| Recupera il lotto valido per il simbolo, adattandolo ai limiti     |
//| richiesti dal broker: lotto minimo, massimo e passo dei lotti.     |
//+------------------------------------------------------------------+
double GetValidLotSize(string symbol, double desiredLotSize)
{
   double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);  // Lotto minimo
   double maxLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);  // Lotto massimo
   double stepLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);  // Passo del lotto

   if(desiredLotSize < minLot)
      desiredLotSize = minLot;
   else if(desiredLotSize > maxLot)
      desiredLotSize = maxLot;

   // Arrotonda il lotto al passo corretto
   desiredLotSize = MathFloor(desiredLotSize / stepLot) * stepLot;
   return desiredLotSize;
}

//+------------------------------------------------------------------+
//| Funzione: GetPrice                                               |
//| Recupera il prezzo corrente (Ask) di un determinato simbolo        |
//+------------------------------------------------------------------+
double GetPrice(string symbol)
{
   double price = SymbolInfoDouble(symbol, SYMBOL_ASK);
   if(price == 0)
      Print("Errore nella lettura del prezzo per ", symbol, " - errore ", GetLastError());
   return price;
}

//+------------------------------------------------------------------+
//| Funzione: CheckArbitrageOpportunity                              |
//| Verifica l'opportunità di arbitraggio triangolare:               |
//|   - Calcola il prezzo implicito: (EURUSD * USDJPY)                |
//|   - Confronta il prezzo implicito con il prezzo diretto EURJPY     |
//|   - Restituisce:                                                 |
//|         1  se il prezzo implicito è superiore (opportunità di     |
//|            acquistare EURJPY e vendere EURUSD e USDJPY)            |
//|        -1  se il prezzo implicito è inferiore                     |
//|         0  se non viene rilevata alcuna opportunità               |
//+------------------------------------------------------------------+
int CheckArbitrageOpportunity(double &diff, double &impliedPrice, double &directPrice)
{
   double price1 = GetPrice(symbol1); // Prezzo EURUSD
   double price2 = GetPrice(symbol2); // Prezzo USDJPY
   directPrice   = GetPrice(symbol3);// Prezzo diretto EURJPY

   impliedPrice = price1 * price2;
   diff = (impliedPrice - directPrice) / directPrice;

   Print("EURUSD: ", price1, " | USDJPY: ", price2, " | EURJPY: ", directPrice,
         " | Prezzo implicito: ", impliedPrice, " | Diff: ", diff);

   if(diff > Threshold)
      return 1;
   else if(diff < -Threshold)
      return -1;
   return 0;
}

//+------------------------------------------------------------------+
//| Funzione: OpenArbitragePositions                                 |
//| Apre le posizioni di arbitraggio in base al segnale ricevuto:      |
//|   Se dir = 1:                                                    |
//|       -> Compra EURJPY, Vende EURUSD e Vende USDJPY               |
//|   Se dir = -1:                                                   |
//|       -> Vende EURJPY, Compra EURUSD e Compra USDJPY              |
//+------------------------------------------------------------------+
void OpenArbitragePositions(int dir)
{
   bool op;
   double validLot1 = GetValidLotSize(symbol1, LotSize);
   double validLot2 = GetValidLotSize(symbol2, LotSize);
   double validLot3 = GetValidLotSize(symbol3, LotSize);

   if(dir == 1)
   {
      op = trade.Buy(validLot3, symbol3, 0, 0, 0, "TA Buy EURJPY");
      if(!op)
         Print("Errore BUY su ", symbol3, " - ", GetLastError());
         
      op = trade.Sell(validLot1, symbol1, 0, 0, 0, "TA Sell EURUSD");
      if(!op)
         Print("Errore SELL su ", symbol1, " - ", GetLastError());
         
      op = trade.Sell(validLot2, symbol2, 0, 0, 0, "TA Sell USDJPY");
      if(!op)
         Print("Errore SELL su ", symbol2, " - ", GetLastError());
   }
   else if(dir == -1)
   {
      op = trade.Sell(validLot3, symbol3, 0, 0, 0, "TA Sell EURJPY");
      if(!op)
         Print("Errore SELL su ", symbol3, " - ", GetLastError());
         
      op = trade.Buy(validLot1, symbol1, 0, 0, 0, "TA Buy EURUSD");
      if(!op)
         Print("Errore BUY su ", symbol1, " - ", GetLastError());
         
      op = trade.Buy(validLot2, symbol2, 0, 0, 0, "TA Buy USDJPY");
      if(!op)
         Print("Errore BUY su ", symbol2, " - ", GetLastError());
   }
}

//+------------------------------------------------------------------+
//| Funzione: AreArbitragePositionsOpen                              |
//| Controlla se ci sono posizioni aperte dall'EA, basandosi sul       |
//| Magic Number, e restituisce true se presenti                       |
//+------------------------------------------------------------------+
bool AreArbitragePositionsOpen()
{
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber)
            return true;
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//| Funzione: CloseArbitragePositions                                |
//| Chiude le posizioni di arbitraggio se il profitto totale supera     |
//| il ProfitTarget                                                   |
//+------------------------------------------------------------------+
void CloseArbitragePositions()
{
   double totalProfit = 0;
   
   // Calcola il profitto cumulativo delle posizioni col Magic Number
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber)
            totalProfit += PositionGetDouble(POSITION_PROFIT);
      }
   }
   
   if(totalProfit >= ProfitTarget)
   {
      Print("Profit target raggiunto: ", totalProfit, ". Procedo alla chiusura delle posizioni.");
      
      // Chiude le posizioni iterando all'indietro per sicurezza
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
         {
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber)
            {
               string sym = PositionGetString(POSITION_SYMBOL);
               if(!trade.PositionClose(sym))
                  Print("Errore nella chiusura della posizione su ", sym, " - ", GetLastError());
               else
                  Print("Posizione su ", sym, " chiusa con successo.");
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Funzione: OnTick                                                 |
//| Viene eseguita ad ogni aggiornamento di mercato; controlla le    |
//| opportunità di arbitraggio, apre le posizioni se necessario e      |
//| monitora il profitto per eventuali chiusure                       |
//+------------------------------------------------------------------+
void OnTick()
{
   // Verifica che il saldo dell'account sia almeno 1000 USD
   double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   if(accountBalance < 1000.0)
   {
      Print("Saldo minimo richiesto di 1000 USD non raggiunto. Saldo attuale: ", accountBalance);
      return;
   }
   
   int arbitrageDir;
   double diff = 0, impliedPrice = 0, directPrice = 0;
   
   arbitrageDir = CheckArbitrageOpportunity(diff, impliedPrice, directPrice);
   
   // Se viene identificata un'opportunità e non ci sono posizioni aperte
   if(arbitrageDir != 0 && !AreArbitragePositionsOpen())
   {
      Print("Arbitraggio rilevato: diff = ", diff, ". Apro le posizioni in direzione: ", arbitrageDir);
      OpenArbitragePositions(arbitrageDir);
   }
   
   // Se esistono posizioni aperte, controlla il profitto e chiude se il target è raggiunto
   if(AreArbitragePositionsOpen())
      CloseArbitragePositions();
}

//+------------------------------------------------------------------+
//| Funzione: OnInit                                                 |
//| Inizializza l'EA, impostando il Magic Number e stampando un      |
//| messaggio di conferma                                              |
//+------------------------------------------------------------------+
int OnInit()
{
   trade.SetExpertMagicNumber(MagicNumber);
   Print("Triangular Arbitrage EA inizializzato correttamente.");
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Funzione: OnDeinit                                               |
//| Viene eseguita quando l'EA viene disattivato; stampa un messaggio   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("Triangular Arbitrage EA de-inizializzato.");
}

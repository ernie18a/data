//+------------------------------------------------------------------+
//|                                    LeadLagRelationshipTester.mq5 |
//|                               Хасанов Ильнур Фаритович (aharata) |
//|                            https://www.mql5.com/ru/users/aharata |
//+------------------------------------------------------------------+
#property copyright "Хасанов Ильнур Фаритович (aharata)"
#property link "https://www.mql5.com/ru/users/aharata"
#property version "1.00"
#property description "Скрипт для проверки индикатора LeadLagRelationship"

sinput uint inpTimerPeriod = 100; // период основного таймера в мс
sinput string inpFilename = "buffer.csv"; // название файла для отправки котировок (\Terminal\Common\Files)
sinput string inpGlobalVariableAsk = "ask"; // название глобальной переменной для аск
sinput string inpGlobalVariableBid = "bid"; // название глобальной переменной для бид
sinput int inpUseMode = 0; // режим канала; 0 - файл, 2 - глобальные перменные терминала
sinput int inpSetLag = 12000; // заданное отставание в мс

uint msCounter, memMsCounter = 0;
MqlTick tick, ticks[];
int sizeTicks = 0;
int fileHandle;

void OnStart()
{
   if(!EventSetMillisecondTimer(inpTimerPeriod)) // количество миллисекунд 
   {
      Print("Ошибка установки таймера, код ошибки:" + IntegerToString(GetLastError()));
      ResetLastError();
   }

   sizeTicks = (int)MathRound(inpSetLag / inpTimerPeriod);
   ArrayResize(ticks, sizeTicks, sizeTicks);

   while(!IsStopped())
   {
      msCounter = GetTickCount();
      if(msCounter - memMsCounter >= inpTimerPeriod) 
      {
         SymbolInfoTick(Symbol(), tick);
         
         ticks[0] = tick;
         for(int i = sizeTicks - 1; i > 0; i--)
         {
            ticks[i] = ticks[i - 1];
         }
         tick = ticks[sizeTicks - 1];
         
         if(inpUseMode == 0)
         {
            fileHandle = FileOpen(inpFilename, FILE_WRITE|FILE_CSV|FILE_COMMON|FILE_SHARE_READ|FILE_SHARE_WRITE);
            if(fileHandle != INVALID_HANDLE)
            {
               FileWrite(fileHandle, tick.ask, tick.bid);
               FileFlush(fileHandle);
               FileClose(fileHandle);
            }
            Sleep(1);            
         }
         
         if(inpUseMode == 2)
         {
            GlobalVariableSet(inpGlobalVariableAsk, tick.ask);
            GlobalVariableSet(inpGlobalVariableBid, tick.bid);
         }
         
         memMsCounter = msCounter;
      }
   }

   EventKillTimer(); 
   if(inpUseMode == 0)
   {
      if(fileHandle != INVALID_HANDLE)
      {
         FileClose(fileHandle);
      }
   }
}
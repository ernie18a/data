//+---------------------------------------------------------------------+
//|                                       MultiThreadedObjectWorker.mq5 |
//|                                       Copyright (c) 2020, Marketeer |
//|                             https://www.mql5.com/en/users/marketeer |
//|            Asynchronous Multithreaded Calculations in Chart Objects |
//| based on . . . . . . . . . .  https://www.mql5.com/ru/articles/5337 |
//+---------------------------------------------------------------------+
#property copyright   "Copyright (c) 2020, Marketeer"
#property link        "https://www.mql5.com/en/users/marketeer"
#property description "Multithreaded calculations in chart objects created ad hoc\n"

#include <MultiThreadedObjectWorker.mqh>
#include <CustomMultiThreadedExample.mqh>

class MyCalcWorkerServer: public CalcWorkerServer
{
  public:
    MyCalcWorkerServer(const long id): CalcWorkerServer(id)
    {
    }

    virtual int execute(const string method,
      const string url, const string header, // url and header are available but not used in the example
      const int timeout, const uchar &body[],
      uchar &result[], string &result_headers) override // result_headers are available but not used here
    {
      if(method == CallDispatcher::method)
      {
        CallDispatcher::_ThreadParameters parameters;
        CharArrayToStruct(parameters, body);

        double sum = 0.0;
        for(int i = 0; i < parameters.iterations; i++)
        {
          if(i % 2 == 0) sum += MathSqrt(i);
          else sum -= MathSqrt(i);
        }

        CallDispatcher::_ThreadResult results;
        results.sum = sum;
        
        StructToCharArray(results, result);

        return 0;
      }
      return -1;
    }
};

MyCalcWorkerServer wws(ChartID());

void OnInit()
{
  Print(ChartID(), ": ", __FUNCTION__);
  const int build = __MQL5BUILD__;
  if(build > 2190)
  {
    EventSetTimer(1);
  }
  else
  {
    wws.startCalculation(MultiThreadedScriptPath);
  }
}

void OnDeinit(const int reason)
{
  Print(ChartID(), ": ", __FUNCTION__);
}

void OnTimer()
{
  EventKillTimer();
  Print(ChartID(), ": ", __FUNCTION__);
  wws.startCalculation(MultiThreadedScriptPath);
}

//+---------------------------------------------------------------------+
//|                                          MultiThreadedIndicator.mq5 |
//|                                       Copyright (c) 2020, Marketeer |
//|                             https://www.mql5.com/en/users/marketeer |
//|          Asynchronous Parallel Calculations on Helper Chart Objects |
//| based on                      https://www.mql5.com/ru/articles/5337 |
//+---------------------------------------------------------------------+
#property copyright   "Copyright (c) 2020, Marketeer"
#property link        "https://www.mql5.com/en/users/marketeer"
#property description "Async demo pseudo-indicator w/o buffers"

#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0


sinput int _Cores = 1;
sinput int _Tasks = 1;


#include <MultiThreadedObjectWorker.mqh>
#include <CustomMultiThreadedExample.mqh>

bool clicked;

class MyCalcWorkerClient : public CalcWorkerClient
{
    static int cursor;
    static int tasknum;
    static int doneCount;
    static uint asyncStart;

  public:
    MyCalcWorkerClient(const long id): CalcWorkerClient(id)
    {
    }
    
    virtual void onResult(const long code, const uchar &headers[], const uchar &text[]) override
    {
      Print("Method ", getMethod(), " ", getURL(), "\nReceived ", ArraySize(headers), " bytes in header, ", ArraySize(text), " bytes in result");
      CallDispatcher::_ThreadResult result;
      CharArrayToStruct(result, text);
      Print(result.sum);
      
      if(++doneCount == tasknum)
      {
        Print("> > > Async ", _Cores, " workers finished ", tasknum, " tasks in ", GetTickCount() - asyncStart, "ms");
        clicked = false;
      }
    }

    virtual void onError(const long code) override
    {
      Print(getWorkerChartID(), ": error code ", code);
    }
    
    static void reset(const int threads, const int tasks);

    static bool iterate();
};

static int MyCalcWorkerClient::cursor = 0;
static int MyCalcWorkerClient::tasknum = 0;
static int MyCalcWorkerClient::doneCount = 0;
static uint MyCalcWorkerClient::asyncStart = 0;

ClientCalcWorkersPool<MyCalcWorkerClient> pool(ChartID());

static void MyCalcWorkerClient::reset(const int threads, const int tasks)
{
  cursor = 0;
  tasknum = tasks;
  asyncStart = 0;
  pool.allocate(threads);
  pool.advance();
}

static bool MyCalcWorkerClient::iterate()
{
  static int errors = 0;
  
  if(cursor == 0)
  {
    doneCount = 0;
    asyncStart = GetTickCount();
  }

  if(cursor < tasknum)
  {
    uchar Body[];
    
    CallDispatcher::_ThreadParameters parameters = {100000000};
    StructToCharArray(parameters, Body);
    
    MyCalcWorkerClient *promise = pool.CalculateAsync(CallDispatcher::method, CallDispatcher::url, CallDispatcher::header, CallDispatcher::timeout, Body);
    if(pool.isWait(promise)) return true; // continue

    errors += (promise == NULL);
    
    cursor++;
    pool.advance();
    return true; // continue iteration
  }

  if(errors > 0)
  {
    Print(errors, " tasks failed");
    tasknum -= errors;
  }
  
  return false; // break interation
}


void OnInit()
{
  clicked = false;
  Comment("Click the chart to start calculations of ", _Tasks, " tasks in ", _Cores, " threads");
}

void OnDeinit(const int reason)
{
  Comment("");
}

int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[])
{
  return 0; // dummy handler
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) 
{
  if(id == CHARTEVENT_CLICK) // initiate test by simple user action
  {
    if(!clicked)
    {
      clicked = true;
      MyCalcWorkerClient::reset(_Cores, _Tasks);
    }
  }
  else
  {
    // this handler manages all important messaging behind the scene
    pool.onChartEvent(id, lparam, dparam, sparam);
  }
}

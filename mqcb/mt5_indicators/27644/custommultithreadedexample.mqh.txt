//+---------------------------------------------------------------------+
//|                                      CustomMultiThreadedExample.mqh |
//|                                       Copyright (c) 2020, Marketeer |
//|                             https://www.mql5.com/en/users/marketeer |
//|          Asynchronous Parallel Calculations on Helper Chart Objects |
//| based on                      https://www.mql5.com/ru/articles/5337 |
//+---------------------------------------------------------------------+

class CallDispatcher
{
  public:
    // standard parameters for calls
    const static string method;
    const static string url;
    const static string header;
    const static int timeout;

    // custom binary parameters
    struct _ThreadParameters
    {
      int iterations;
    };

    // custom result
    struct _ThreadResult
    {
      double sum;
    };
};

const static string CallDispatcher::method = "sqrtloop";
const static string CallDispatcher::url = "";
const static string CallDispatcher::header = "";
const static int CallDispatcher::timeout = 0;

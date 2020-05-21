

#import "KCAssert.h"

NSString *const KCErrorDomain = @"KCErrorDomain";
NSString *const KCJSStackTraceKey = @"KCJSStackTraceKey";
NSString *const KCFatalExceptionName = @"KCFatalException";

static NSString *const KCAssertFunctionStack = @"KCAssertFunctionStack";

KCAssertFunction KCCurrentAssertFunction = nil;
KCFatalHandler KCCurrentFatalHandler = nil;

NSException *_KCNotImplementedException(SEL, Class);
NSException *_KCNotImplementedException(SEL cmd, Class cls)
{
  NSString *msg = [NSString stringWithFormat:@"%s is not implemented "
                   "for the class %@", sel_getName(cmd), cls];
  return [NSException exceptionWithName:@"KCNotDesignatedInitializerException"
                                 reason:msg userInfo:nil];
}

void KCSetAssertFunction(KCAssertFunction assertFunction)
{
  KCCurrentAssertFunction = assertFunction;
}

KCAssertFunction KCGetAssertFunction(void)
{
  return KCCurrentAssertFunction;
}

void KCAddAssertFunction(KCAssertFunction assertFunction)
{
  KCAssertFunction existing = KCCurrentAssertFunction;
  if (existing) {
    KCCurrentAssertFunction = ^(NSString *condition,
                                 NSString *fileName,
                                 NSNumber *lineNumber,
                                 NSString *function,
                                 NSString *message) {

      existing(condition, fileName, lineNumber, function, message);
      assertFunction(condition, fileName, lineNumber, function, message);
    };
  } else {
    KCCurrentAssertFunction = assertFunction;
  }
}

/**
 * returns the topmost stacked assert function for the current thread, which
 * may not be the same as the current value of KCCurrentAssertFunction.
 */
static KCAssertFunction KCGetLocalAssertFunction()
{
  NSMutableDictionary *threadDictionary = [NSThread currentThread].threadDictionary;
  NSArray<KCAssertFunction> *functionStack = threadDictionary[KCAssertFunctionStack];
  KCAssertFunction assertFunction = functionStack.lastObject;
  if (assertFunction) {
    return assertFunction;
  }
  return KCCurrentAssertFunction;
}

void KCPerformBlockWithAssertFunction(void (^block)(void), KCAssertFunction assertFunction)
{
  NSMutableDictionary *threadDictionary = [NSThread currentThread].threadDictionary;
  NSMutableArray<KCAssertFunction> *functionStack = threadDictionary[KCAssertFunctionStack];
  if (!functionStack) {
    functionStack = [NSMutableArray new];
    threadDictionary[KCAssertFunctionStack] = functionStack;
  }
  [functionStack addObject:assertFunction];
  block();
  [functionStack removeLastObject];
}

NSString *KCCurrentThreadName(void)
{
  NSThread *thread = [NSThread currentThread];
  NSString *threadName = thread.isMainThread ? @"main" : thread.name;
  if (threadName.length == 0) {
    const char *label = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
    if (label && strlen(label) > 0) {
      threadName = @(label);
    } else {
      threadName = [NSString stringWithFormat:@"%p", thread];
    }
  }
  return threadName;
}

void _KCAssertFormat(
  const char *condition,
  const char *fileName,
  int lineNumber,
  const char *function,
  NSString *format, ...)
{
  KCAssertFunction assertFunction = KCGetLocalAssertFunction();
  if (assertFunction) {
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);

    assertFunction(@(condition), @(fileName), @(lineNumber), @(function), message);
  }
}

void KCFatal(NSError *error)
{
    KCLog(@"%@", [error localizedDescription]);

  KCFatalHandler fatalHandler = KCGetFatalHandler();
  if (fatalHandler) {
    fatalHandler(error);
  } else {
#if DEBUG
    @try {
#endif
      NSString *name = [NSString stringWithFormat:@"%@: %@", KCFatalExceptionName, [error localizedDescription]];
      NSString *message = KCFormatError([error localizedDescription], error.userInfo[KCJSStackTraceKey], 75);
      [NSException raise:name format:@"%@", message];
#if DEBUG
    } @catch (NSException *e) {}
#endif
  }
}

void KCSetFatalHandler(KCFatalHandler fatalhandler)
{
  KCCurrentFatalHandler = fatalhandler;
}

KCFatalHandler KCGetFatalHandler(void)
{
  return KCCurrentFatalHandler;
}

NSString *KCFormatError(NSString *message, NSArray<NSDictionary<NSString *, id> *> *stackTrace, NSUInteger maxMessageLength)
{
  if (maxMessageLength > 0 && message.length > maxMessageLength) {
    message = [[message substringToIndex:maxMessageLength] stringByAppendingString:@"..."];
  }

  NSMutableString *prettyStack = [NSMutableString string];
  if (stackTrace) {
    [prettyStack appendString:@", stack:\n"];
    for (NSDictionary<NSString *, id> *frame in stackTrace) {
      [prettyStack appendFormat:@"%@@%@:%@\n", frame[@"methodName"], frame[@"lineNumber"], frame[@"column"]];
    }
  }

  return [NSString stringWithFormat:@"%@%@", message, prettyStack];
}

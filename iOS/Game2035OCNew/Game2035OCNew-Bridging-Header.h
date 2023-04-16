//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#ifdef DEBUG
# define DLog(fmt, ...) NSLog((@"MC ----- [文件:%s] [函数:%s] [行:%d] ----- MC" fmt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
# define DLog(...);
#endif


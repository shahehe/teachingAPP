#import <Foundation/Foundation.h>

@interface PGTimer : NSObject

@property(nonatomic,retain) NSDate *start;
@property(nonatomic,retain) NSDate *end;

- (void) startTimer;
- (void) stopTimer;
- (double) timeElapsedInSeconds;
- (double) timeElapsedInMilliseconds;
- (double) timeElapsedInMinutes;

@end
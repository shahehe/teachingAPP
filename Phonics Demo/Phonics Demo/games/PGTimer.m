#import "PGTimer.h"

@implementation PGTimer

- (id) init {
    self = [super init];
    if (self != nil) {
        _start = nil;
        _end = nil;
    }
    return self;
}

- (void) dealloc
{
    [_start release];
    [_end release];
    
    [super dealloc];
}

- (void) startTimer {
    self.start = [NSDate date];
}

- (void) stopTimer {
    self.end = [NSDate date];
}

- (double) timeElapsedInSeconds {
    return [self.end timeIntervalSinceDate:self.start];
}

- (double) timeElapsedInMilliseconds {
    return [self timeElapsedInSeconds] * 1000.0f;
}

- (double) timeElapsedInMinutes {
    return [self timeElapsedInSeconds] / 60.0f;
}

@end
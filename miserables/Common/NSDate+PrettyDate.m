//
//  NSDate+PrettyDate.m
//  miserables
//
//  Created by Xhacker on 2013-03-13.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "NSDate+PrettyDate.h"

@implementation NSDate (PrettyDate)

- (NSString *)prettyDate
{
    NSString *prettyTimestamp;
    
    float delta = [self timeIntervalSinceNow] * -1;
    
    if (delta < 120) {
        prettyTimestamp = @"just now";
    }
    else if (delta < 3600) {
        prettyTimestamp = [NSString stringWithFormat:@"%d min ago", (int) floor(delta / 60.0) ];
    }
    else if (delta < 86400) {
        prettyTimestamp = [NSString stringWithFormat:@"%d hrs ago", (int) floor(delta / 3600.0) ];
    }
    else if (delta < 86400 * 30) {
        prettyTimestamp = [NSString stringWithFormat:@"%d days ago", (int) floor(delta / 86400.0) ];
    }
    else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        prettyTimestamp = [formatter stringFromDate:self];
    }
    
    return prettyTimestamp;
}

@end

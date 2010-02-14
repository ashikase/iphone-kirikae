/**
 * Name: Kirikae
 * Type: iPhone OS SpringBoard extension (MobileSubstrate-based)
 * Description: a task manager/switcher for iPhoneOS
 * Author: Lance Fetters (aka. ashikase)
 * Last-modified: 2010-02-13 11:49:02
 */

/**
 * Copyright (C) 2009  Lance Fetters (aka. ashikase)
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. The name of the author may not be used to endorse or promote
 *    products derived from this software without specific prior
 *    written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS
 * OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */


#import "KirikaeActivator.h"

#import "SpringBoardHooks.h"


@implementation KirikaeActivator
 
+ (void)load
{
    static KirikaeActivator *activator = nil;
    if (activator == nil) {
        activator = [[KirikaeActivator alloc] init];
	    [[LAActivator sharedInstance] registerListener:activator forName:@APP_ID];
    }
}
 
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
    SpringBoard *springBoard = (SpringBoard *)[UIApplication sharedApplication];

    if ([event.name isEqualToString:LAEventNameMenuPressDouble]) {
        if ([springBoard kirikae] != nil) {
            // Kirikae is invoked; dismiss and perform normal behaviour
            [springBoard dismissKirikae];
            return;
        }
    }

    [springBoard invokeKirikae];
 
    // Prevent the default OS implementation
	event.handled = YES;
}
 
- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event
{
    SpringBoard *springBoard = (SpringBoard *)[UIApplication sharedApplication];
    [springBoard dismissKirikae];
}
 
@end

/* vim: set syntax=objcpp sw=4 ts=4 sts=4 expandtab textwidth=80 ff=unix: */

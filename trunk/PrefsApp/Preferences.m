/**
 * Name: Kirikae
 * Type: iPhone OS SpringBoard extension (MobileSubstrate-based)
 * Description: a task manager/switcher for iPhoneOS
 * Author: Lance Fetters (aka. ashikase)
 * Last-modified: 2009-09-09 10:01:37
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


#import "Preferences.h"

#import <Foundation/Foundation.h>


@implementation Preferences

@synthesize firstRun;
@synthesize animationsEnabled;
@synthesize favorites;

#pragma mark - Methods

+ (Preferences *)sharedInstance
{
    static Preferences *instance = nil;
    if (instance == nil)
        instance = [[Preferences alloc] init];
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Setup default values
        [self registerDefaults];

        // Load preference values into memory
        [self readFromDisk];

        // Retain a copy of the initial values of the preferences
        initialValues = [[self dictionaryRepresentation] retain];

        // The on-disk values at startup are the same as initialValues
        onDiskValues = [initialValues retain];
    }
    return self;
}

- (void)dealloc
{
    [onDiskValues release];
    [initialValues release];

    [super dealloc];
}

#pragma mark - Other

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:4];

    [dict setObject:[NSNumber numberWithBool:firstRun] forKey:@"firstRun"];
    [dict setObject:[NSNumber numberWithBool:animationsEnabled] forKey:@"animationsEnabled"];
    [dict setObject:[favorites copy] forKey:@"favorites"];

    return dict;
}

#pragma mark - Status

- (BOOL)isModified
{
    return ![[self dictionaryRepresentation] isEqual:onDiskValues];
}

- (BOOL)needsRespring
{
    return ![[self dictionaryRepresentation] isEqual:initialValues];
}

#pragma mark - Read/Write methods

- (void)registerDefaults
{
    // NOTE: This method sets default values for options that are not already
    //       set in the application's on-disk preferences list.

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:4];

    [dict setObject:[NSNumber numberWithBool:YES] forKey:@"firstRun"];
    [dict setObject:[NSNumber numberWithBool:YES] forKey:@"animationsEnabled"];
    [dict setObject:[NSArray array] forKey:@"favorites"];

    [defaults registerDefaults:dict];
}

- (void)readFromDisk
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    firstRun = [defaults boolForKey:@"firstRun"];
    animationsEnabled = [defaults boolForKey:@"animationsEnabled"];
    favorites = [[defaults arrayForKey:@"favorites"] retain];
}

- (void)writeToDisk
{
    NSDictionary *dict = [self dictionaryRepresentation];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setPersistentDomain:dict forName:[[NSBundle mainBundle] bundleIdentifier]];
    [defaults synchronize];

    // Update the list of on-disk values
    [onDiskValues release];
    onDiskValues = [dict retain];
}

@end

/* vim: set syntax=objc sw=4 ts=4 sts=4 expandtab textwidth=80 ff=unix: */

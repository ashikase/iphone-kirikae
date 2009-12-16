/**
 * Name: Kirikae
 * Type: iPhone OS SpringBoard extension (MobileSubstrate-based)
 * Description: a task manager/switcher for iPhoneOS
 * Author: Lance Fetters (aka. ashikase)
 * Last-modified: 2009-12-16 18:58:36
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


#import <Foundation/NSObject.h>


@class NSArray;
@class NSDictionary;
@class NSString;

@interface Preferences : NSObject
{
    NSDictionary *initialValues;
    NSDictionary *onDiskValues;

    BOOL firstRun;
    BOOL animationsEnabled;
    BOOL useLargeRows;
    BOOL showActive;
    BOOL showFavorites;
    BOOL showSpotlight;
    unsigned int initialView;
    unsigned int invocationMethod;
    NSArray *favorites;
}

@property(nonatomic) BOOL firstRun;
@property(nonatomic) BOOL animationsEnabled;
@property(nonatomic) BOOL useLargeRows;
@property(nonatomic) BOOL showActive;
@property(nonatomic) BOOL showFavorites;
@property(nonatomic) BOOL showSpotlight;
@property(nonatomic) unsigned int initialView;
@property(nonatomic) unsigned int invocationMethod;
@property(nonatomic, retain) NSArray *favorites;

+ (Preferences *)sharedInstance;

- (NSDictionary *)dictionaryRepresentation;

- (BOOL)isModified;
- (BOOL)needsRespring;

- (void)registerDefaults;
- (void)readFromDisk;
- (void)writeToDisk;

@end

/* vim: set syntax=objc sw=4 ts=4 sts=4 expandtab textwidth=80 ff=unix: */

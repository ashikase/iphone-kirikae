/**
 * Name: Kirikae
 * Type: iPhone OS SpringBoard extension (MobileSubstrate-based)
 * Description: a task manager/switcher for iPhoneOS
 * Author: Lance Fetters (aka. ashikase)
 * Last-modified: 2009-09-21 18:05:26
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


#import "FavoritesController.h"

#import <objc/runtime.h>

#import <CoreGraphics/CGGeometry.h>
#import <QuartzCore/CALayer.h>

#import <CoreFoundation/CFPreferences.h>

#import <Foundation/Foundation.h>

#import "ApplicationCell.h"
#import "HtmlDocController.h"
#import "Preferences.h"
#import "RootController.h"

// SpringBoardServices
extern NSString * SBSCopyLocalizedApplicationNameForDisplayIdentifier(NSString *identifier);
extern NSString * SBSCopyIconImagePathForDisplayIdentifier(NSString *identifier);

#define HELP_FILE "favorites.html"


@interface UIProgressHUD : UIView

- (id)initWithWindow:(id)fp8;
- (void)setText:(id)fp8;
- (void)show:(BOOL)fp8;
- (void)hide;

@end

//________________________________________________________________________________
//________________________________________________________________________________

static NSInteger compareDisplayNames(NSString *a, NSString *b, void *context)
{
    NSInteger ret;

    NSString *name_a = SBSCopyLocalizedApplicationNameForDisplayIdentifier(a);
    NSString *name_b = SBSCopyLocalizedApplicationNameForDisplayIdentifier(b);
    ret = [name_a caseInsensitiveCompare:name_b];
    [name_a release];
    [name_b release];

    return ret;
}

//________________________________________________________________________________
//________________________________________________________________________________

@implementation FavoritesController

static NSArray *applicationDisplayIdentifiers()
{
    // First, get a list of all possible application paths
    NSMutableArray *paths = [NSMutableArray array];

    // ... scan /Applications (System/Jailbreak applications)
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSString *path in [fileManager directoryContentsAtPath:@"/Applications"]) {
        if ([path hasSuffix:@".app"] && ![path hasPrefix:@"."])
           [paths addObject:[NSString stringWithFormat:@"/Applications/%@", path]];
    }

    // ... scan /var/mobile/Applications (AppStore applications)
    for (NSString *path in [fileManager directoryContentsAtPath:@"/var/mobile/Applications"]) {
        for (NSString *subpath in [fileManager directoryContentsAtPath:
                [NSString stringWithFormat:@"/var/mobile/Applications/%@", path]]) {
            if ([subpath hasSuffix:@".app"])
                [paths addObject:[NSString stringWithFormat:@"/var/mobile/Applications/%@/%@", path, subpath]];
        }
    }

    // Then, go through paths and record valid application identifiers
    NSMutableArray *identifiers = [NSMutableArray array];

    for (NSString *path in paths) {
        NSBundle *bundle = [NSBundle bundleWithPath:path];
        if (bundle) {
            NSString *identifier = [bundle bundleIdentifier];

            // Filter out non-applications and apps that should remain hidden
            // FIXME: The proper fix is to only show non-hidden apps and apps
            //        that are in Categories; unfortunately, the design of
            //        Categories does not make it easy to determine what apps
            //        a given folder contains.
            if (identifier &&
                ![identifier hasPrefix:@"jp.ashikase.springjumps."] &&
                ![identifier hasPrefix:@"com.bigboss.categories."] &&
                ![identifier hasPrefix:@"com.apple.mobileslideshow"] &&
                ![identifier hasPrefix:@"com.apple.mobileipod"] &&
                ![identifier isEqualToString:@"com.iptm.bigboss.sbsettings"] &&
                ![identifier isEqualToString:@"com.apple.webapp"])
            [identifiers addObject:identifier];
        }
    }

    // Finally, add identifiers for apps known to have multiple roles
    [identifiers addObject:[NSString stringWithString:@"com.apple.mobileslideshow-Camera"]];
    [identifiers addObject:[NSString stringWithString:@"com.apple.mobileslideshow-Photos"]];
    if ([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]) {
        // iPhone
        [identifiers addObject:[NSString stringWithString:@"com.apple.mobileipod-MediaPlayer"]];
    } else {
        // iPod Touch
        [identifiers addObject:[NSString stringWithString:@"com.apple.mobileipod-AudioPlayer"]];
        [identifiers addObject:[NSString stringWithString:@"com.apple.mobileipod-VideoPlayer"]];
    }

    return identifiers;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Favorites";

        // Get a copy of the list of favorites
        favorites = [[NSMutableArray alloc]
            initWithArray:[[Preferences sharedInstance] favorites]];
    }
    return self;
}

- (void)loadView
{
    // Retain a reference to the root controller for accessing cached info
    // FIXME: Consider passing the display id array in as an init parameter
    rootController = [[self.navigationController.viewControllers objectAtIndex:0] retain];

    [super loadView];
}

- (void)dealloc
{
    [busyIndicator release];
    [favorites release];
    [rootController release];

    [super dealloc];
}

- (void)enumerateApplications
{
    NSArray *array = applicationDisplayIdentifiers();
    NSArray *sortedArray = [array sortedArrayUsingFunction:compareDisplayNames context:NULL];
    [rootController setDisplayIdentifiers:sortedArray];
    [self.tableView reloadData];

    // Remove the progress indicator
    [busyIndicator hide];
    [busyIndicator release];
    busyIndicator = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([rootController displayIdentifiers] != nil)
        // Application list already loaded
        return;

    // Show a progress indicator
    busyIndicator = [[UIProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
    [busyIndicator setText:@"Loading applications..."];
    [busyIndicator show:YES];

    // Enumerate applications
    // NOTE: Must call via performSelector, or busy indicator does not show in time
    [self performSelector:@selector(enumerateApplications) withObject:nil afterDelay:0.1f];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (isModified) {
        // Sort list of favorites by display name and save to preferences file
        NSArray *sortedArray = [favorites sortedArrayUsingFunction:compareDisplayNames context:NULL];
        [[Preferences sharedInstance] setFavorites:sortedArray];
    }
}

#pragma mark - UITableViewDataSource

- (int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(int)section
{
    return nil;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(int)section
{
    return [[rootController displayIdentifiers] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"FavoritesCell";

    // Try to retrieve from the table view a now-unused cell with the given identifier
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        // Cell does not exist, create a new one
        cell = [[[ApplicationCell alloc] initWithFrame:CGRectZero reuseIdentifier:reuseIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }

    NSString *identifier = [[rootController displayIdentifiers] objectAtIndex:indexPath.row];

    NSString *displayName = SBSCopyLocalizedApplicationNameForDisplayIdentifier(identifier);
    [cell setText:displayName];
    [displayName release];

    UIImage *icon = nil;
    NSString *iconPath = SBSCopyIconImagePathForDisplayIdentifier(identifier);
    if (iconPath != nil) {
        icon = [UIImage imageWithContentsOfFile:iconPath];
        [iconPath release];
    }
    [cell setImage:icon];

    cell.accessoryType = [favorites containsObject:identifier] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    return cell;
}

#pragma mark - UITableViewCellDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [[rootController displayIdentifiers] objectAtIndex:indexPath.row];

    // Update the list of favorites and toggle the cell's checkmark
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        [favorites addObject:identifier];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        [favorites removeObject:identifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    isModified = YES;

    // Reset the table by deselecting the current selection
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation bar delegates

- (void)helpButtonTapped
{
    // Create and show help page
    [[self navigationController] pushViewController:[[[HtmlDocController alloc]
        initWithContentsOfFile:@HELP_FILE title:@"Explanation"] autorelease] animated:YES];
}

@end

/* vim: set syntax=objc sw=4 ts=4 sts=4 expandtab textwidth=80 ff=unix: */
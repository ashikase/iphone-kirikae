/**
 * Name: Kirikae
 * Type: iPhone OS SpringBoard extension (MobileSubstrate-based)
 * Description: a task manager/switcher for iPhoneOS
 * Author: Lance Fetters (aka. ashikase)
 * Last-modified: 2009-12-16 00:46:43
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


#import "TaskListController.h"

#import <QuartzCore/CALayer.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationIcon.h>
#import <SpringBoard/SBIconModel.h>

#import "SpringBoardHooks.h"
#import "TaskListCell.h"


@interface TaskListController (Private)
- (NSString *)displayIdentifierAtIndexPath:(NSIndexPath *)indexPath;
@end

@implementation TaskListController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Setup tab bar button
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:@"Active" image:[UIImage imageNamed:@"Kirikae_Active.png"] tag:0];
        [self setTabBarItem:item];
        [item release];

        // Cache the images used for the terminate button
        NSBundle *bundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"/Applications/Kirikae.app"]];
        termImage = [[UIImage alloc] initWithContentsOfFile:
            [bundle pathForResource:@"terminate_btn" ofType:@"png"]];
        termPressedImage = [[UIImage alloc] initWithContentsOfFile:
            [bundle pathForResource:@"terminate_btn_pressed" ofType:@"png"]];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    [self.tableView setRowHeight:60.0f];
}

- (void)dealloc
{
    // NOTE: Should already be released and nullified, but just in case
    [currentApp release];
    [otherApps release];

    [termImage release];
    [termPressedImage release];

    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Get current application
    currentApp = [[[(SpringBoard *)UIApp topApplication] displayIdentifier] copy];

    // Get list of other active applications
    otherApps = [[NSMutableArray alloc] init];
    for (SBApplication *app in [(SpringBoard *)UIApp _accessibilityRunningApplications])
        [otherApps addObject:app.displayIdentifier];

    // Do not show current application in list of other applications
    [otherApps removeObject:currentApp];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[(SpringBoard *)UIApp kirikae] setDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[(SpringBoard *)UIApp kirikae] setDelegate:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [currentApp release];
    currentApp = nil;

    [otherApps release];
    otherApps = nil;
}

#pragma mark - Private methods

- (NSString *)displayIdentifierAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *displayId = nil;

    switch (indexPath.section) {
        case 0:
            displayId = @"com.apple.springboard";
            break;
        case 1:
            displayId = currentApp;
            break;
        case 2:
            displayId = [otherApps objectAtIndex:indexPath.row];
            break;
        default:
            break;
    }

    return displayId;
}

#pragma mark - UITableViewDataSource

- (int)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(int)section
{
    static NSString *titles[] =  {@"Home Screen", @"Current Application", @"Other Applications"};
    return (section == 1 && currentApp == nil) ? nil : titles[section];
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(int)section
{
    int rows = 0;

    if (section == 2)
        rows = [otherApps count];
    else if (section == 0 || currentApp != nil)
        rows = 1;

    return rows;
}

- (float)tableView:(UITableView *)tableView_ heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SBIconBadge *badge = nil;

    NSString *displayId = (indexPath.section == 1) ? currentApp : [otherApps objectAtIndex:indexPath.row];
    if (displayId) {
        SBApplicationIcon *icon = [[objc_getClass("SBIconModel") sharedInstance] iconForDisplayIdentifier:displayId];
        badge = MSHookIvar<SBIconBadge *>(icon, "_badge");
    }

    return (badge ? 68.0f : 60.0f);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"TaskMenuCell";

    // Try to retrieve from the table view a now-unused cell with the given identifier
    TaskListCell *cell = (TaskListCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        // Cell does not exist, create a new one
        cell = [[[TaskListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }

    // Get the display identifier of the application for this cell
    NSString *identifier = [self displayIdentifierAtIndexPath:indexPath];

    // Get the application icon object
    SBApplicationIcon *icon = [[objc_getClass("SBIconModel") sharedInstance] iconForDisplayIdentifier:identifier];

    // Set the cell's text to the name of the application
    [cell setText:[icon displayName]];

    // Set the cell's image to the application's icon image
    UIImage *image = nil;
    if (indexPath.section == 0) {
        // Is SpringBoard
        image = [UIImage imageNamed:@"applelogo.png"];
    } else {
        // Is an application (either current or other)
        image = [icon icon];

        SBIconBadge *badge = MSHookIvar<SBIconBadge *>(icon, "_badge");
        if (badge) {
            UIGraphicsBeginImageContext([badge frame].size);
            [[badge layer] renderInContext:UIGraphicsGetCurrentContext()];
            [cell setBadge:UIGraphicsGetImageFromCurrentImageContext()];
            UIGraphicsEndImageContext();
        }
    }
    [cell setImage:image];

    // Create close button to use as accessory for cell
    // NOTE: The button is aligned so that it will appear in the same spot
    //       as the activity indicator it is replaced with when tapped.
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 40.0f, 60.0f);
    [button setImage:termImage forState:UIControlStateNormal];
    [button setImage:termPressedImage forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = button;

    return cell;
}

- (void)tableView:(UITableView *)tableView
  commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
    }
}

#pragma mark - UITableViewCellDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SpringBoard *springBoard = (SpringBoard *)[objc_getClass("SpringBoard") sharedApplication];

    if (indexPath.section == 1)
        [springBoard dismissKirikae];
    else
        // Switch to selected application
        [springBoard switchToAppWithDisplayIdentifier:(indexPath.section == 0) ?
            @"com.apple.springboard" :
            [otherApps objectAtIndex:indexPath.row]];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

#pragma mark - Actions

- (void)buttonPressed:(UIButton *)button
{
    // Get the cell for the pressed button
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)[button superview]];

    // Create an activity indicator to display while waiting for app to quit
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    cell.accessoryView = spinner;
    [spinner release];

    // Quit the selected application
    NSString *identifier = [self displayIdentifierAtIndexPath:indexPath];
    [(SpringBoard *)UIApp quitAppWithDisplayIdentifier:identifier];
}

#pragma mark - Kirikae delegate methods

- (void)kirikae:(Kirikae *)kirikae applicationDidActivate:(NSString *)displayId
{
    // Mark beginning of animations
    [self.tableView beginUpdates];

    if ([displayId isEqualToString:[[(SpringBoard *)UIApp topApplication] displayIdentifier]]) {
        // New current application
        if (currentApp != nil) {
            // Application replaced currently active application
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                withRowAnimation:UITableViewRowAnimationFade];

            // Move previous application to other applications section
            [otherApps insertObject:currentApp atIndex:0];
            indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                withRowAnimation:UITableViewRowAnimationFade];

            // Release the old identifier
            [currentApp release];
        } else {
            // No previous currently active application (was SpringBoard)
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:1];
            [self.tableView reloadSections:indexSet
                withRowAnimation:UITableViewRowAnimationFade];
        }

        // Save the new identifier
        currentApp = [displayId copy];
    } else {
        // Other active application
        int row = [otherApps indexOfObject:displayId];
        if (row != NSNotFound) {
            // Already exists in other applications list; will move to top of list
            [otherApps removeObjectAtIndex:row];

            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:2];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                withRowAnimation:UITableViewRowAnimationFade];
        }

        // Insert at top of list
        [otherApps insertObject:displayId atIndex:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
            withRowAnimation:UITableViewRowAnimationFade];
    }

    // Commit animations
    [self.tableView endUpdates];
}

- (void)kirikae:(Kirikae *)kirikae applicationDidTerminate:(NSString *)displayId
{
    int row = NSNotFound;
    if ([displayId isEqualToString:currentApp]) {
        // Currently active application terminated
        [currentApp release];
        currentApp = nil;

        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:1];
        [self.tableView reloadSections:indexSet
            withRowAnimation:UITableViewRowAnimationFade];
    } else if ((row = [otherApps indexOfObject:displayId]) != NSNotFound) {
        // Other application terminated
        [otherApps removeObjectAtIndex:row];

        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:2];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
            withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end

/* vim: set syntax=objcpp sw=4 ts=4 sts=4 expandtab textwidth=80 ff=unix: */

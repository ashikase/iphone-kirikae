/**
 * Name: Kirikae
 * Type: iPhone OS SpringBoard extension (MobileSubstrate-based)
 * Description: a task manager/switcher for iPhoneOS
 * Author: Lance Fetters (aka. ashikase)
 * Last-modified: 2009-09-20 23:45:29
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


#import "RootController.h"

#include <stdlib.h>

#import <CoreGraphics/CGGeometry.h>

#import <Foundation/Foundation.h>

#import <UIKit/UIViewController-UINavigationControllerItem.h>

#import "Constants.h"
#import "HtmlDocController.h"
#import "FavoritesController.h"
#import "Preferences.h"


@implementation RootController

@synthesize displayIdentifiers;


- (id)initWithStyle:(int)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self setTitle:@"Kirikae"];
        [[self navigationItem] setBackButtonTitle:@"Back"];
    }
    return self;
}

- (void)dealloc
{
    [displayIdentifiers release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Reset the table by deselecting the current selection
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - UITableViewDataSource

- (int)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(int)section
{
    static NSString *headers[] = {nil, @"Documentation", nil, nil};
    return headers[section];
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(int)section
{
    static int rows[] = {2, 4, 2};
    return rows[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdDonate = @"DonateCell";
    static NSString *reuseIdName = @"NameCell";
    static NSString *reuseIdSafari = @"SafariCell";
    static NSString *reuseIdSimple = @"SimpleCell";
    static NSString *reuseIdToggle = @"ToggleCell";

    UITableViewCell *cell = nil;

    if (indexPath.section == 0 && indexPath.row == 0) {
        // Try to retrieve from the table view a now-unused cell with the given identifier
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdToggle];
        if (cell == nil) {
            // Cell does not exist, create a new one
            cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:reuseIdToggle] autorelease];
            [cell setSelectionStyle:0];

            UISwitch *toggle = [[UISwitch alloc] init];
            [cell setText:@"Animate switching"];
            [toggle setOn:[[Preferences sharedInstance] animationsEnabled]];
            [toggle addTarget:self action:@selector(switchToggled:) forControlEvents:4096]; // ValueChanged
            [cell setAccessoryView:toggle];
            [toggle release];
        }
    } else if (indexPath.section == 1 && indexPath.row == 3) {
        // Try to retrieve from the table view a now-unused cell with the given identifier
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdSafari];
        if (cell == nil) {
            // Cell does not exist, create a new one
            cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:reuseIdSafari] autorelease];
            [cell setSelectionStyle:2]; // Gray

            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            [label setText:@"(via Safari)"];
            [label setTextColor:[UIColor colorWithRed:0.2f green:0.31f blue:0.52f alpha:1.0f]];
            [label setFont:[UIFont systemFontOfSize:16.0f]];
            CGSize size = [label.text sizeWithFont:label.font];
            [label setFrame:CGRectMake(0, 0, size.width, size.height)];

            [cell setAccessoryView:label];
            [label release];
        }

        [cell setText:@"Project Homepage"];
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            // Credits cell
            // Try to retrieve from the table view a now-unused cell with the given identifier
            cell = [tableView dequeueReusableCellWithIdentifier:reuseIdName];
            if (cell == nil) {
                // Cell does not exist, create a new one
                cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:reuseIdName] autorelease];
                [cell setSelectionStyle:0]; // None

                // Make cell background transparent
                UIView *bgView = [[UIView alloc] initWithFrame:CGRectZero];
                [bgView setBackgroundColor:[UIColor clearColor]];
                [cell setBackgroundView:bgView];
                [bgView release];

                // Must create own label to allow transparency
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
                [label setText:@"by Lance Fetters (ashikase)"];
                [label setTextColor:[UIColor colorWithRed:0.3f green:0.34f blue:0.42f alpha:1.0f]];
                [label setShadowColor:[UIColor whiteColor]];
                [label setShadowOffset:CGSizeMake(1, 1)];
                [label setBackgroundColor:[UIColor clearColor]];
                [label setFont:[UIFont systemFontOfSize:16.0f]];
                CGSize size = [label.text sizeWithFont:label.font];
                [label setFrame:CGRectMake((300.0f - size.width) / 2.0f, 0, size.width, size.height)];

                [[cell contentView] addSubview:label];
                [label release];
            }
        } else {
            // Donation button cell
            // Try to retrieve from the table view a now-unused cell with the given identifier
            cell = [tableView dequeueReusableCellWithIdentifier:reuseIdDonate];
            if (cell == nil) {
                // Cell does not exist, create a new one
                cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:reuseIdDonate] autorelease];
                [cell setSelectionStyle:0]; // None

                // Make cell background transparent
                UIView *bgView = [[UIView alloc] initWithFrame:CGRectZero];
                [bgView setBackgroundColor:[UIColor clearColor]];
                [cell setBackgroundView:bgView];
                [bgView release];

                // Add image
                UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"donate.png"]];
                CGSize size = [imageView frame].size;
                [imageView setFrame:CGRectMake((300.0f - size.width) / 2.0f, 0, size.width, size.height)];
                [[cell contentView] addSubview:imageView];
                [imageView release];
            }
        }
    } else {
        static NSString *cellTitles[][3] = {
            {nil, @"Favorites", nil},
            {@"How to Use", @"Release Notes", @"Known Issues"}
        };

        // Try to retrieve from the table view a now-unused cell with the given identifier
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdSimple];
        if (cell == nil) {
            // Cell does not exist, create a new one
            cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:reuseIdSimple] autorelease];
            [cell setSelectionStyle:2]; // Gray
            [cell setAccessoryType:1]; // Simple arrow
        }
        [cell setText:cellTitles[indexPath.section][indexPath.row]];
    }

    return cell;
}

#pragma mark - UITableViewCellDelegate

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == 2 && indexPath.row == 0) ? 22.0f : 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *vc = nil;

    if (indexPath.section == 0) {
        vc = [[[FavoritesController alloc] initWithStyle:1] autorelease];
    } else if (indexPath.section == 1) {
        // Documentation
        static NSString *fileNames[] = { @"usage.mdwn", @"release_notes.mdwn", @"known_issues.mdwn" };
        static NSString *titles[] = { @"How to Use", @"Release Notes", @"Known Issues" };

        if (indexPath.row == 3)
            // Project Homepage
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@DEVSITE_URL]];
        else
            vc = [[[HtmlDocController alloc]
                initWithContentsOfFile:fileNames[indexPath.row] title:titles[indexPath.row]]
                autorelease];
            [(HtmlDocController *)vc setTemplateFileName:@"template.html"];
    } else {
        // Donation
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=gaizin%40gmail%2ecom&lc=US&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHostedGuest"]];
    }

    if (vc)
        [[self navigationController] pushViewController:vc animated:YES];
}

#pragma mark - Switch delegate

- (void)switchToggled:(UISwitch *)control
{
    [[Preferences sharedInstance] setAnimationsEnabled:[control isOn]];
}

@end

/* vim: set syntax=objc sw=4 ts=4 sts=4 expandtab textwidth=80 ff=unix: */
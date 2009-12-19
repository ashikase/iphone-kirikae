/**
 * Name: Kirikae
 * Type: iPhone OS SpringBoard extension (MobileSubstrate-based)
 * Description: a task manager/switcher for iPhoneOS
 * Author: Lance Fetters (aka. ashikase)
 * Last-modified: 2009-12-19 16:36:48
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


#import "GeneralController.h"

#import <CoreGraphics/CGGeometry.h>

#import <Foundation/Foundation.h>

#import "Constants.h"
#import "Preferences.h"


@implementation GeneralController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"General";
    }
    return self;
}

#pragma mark - UITableViewDataSource

- (int)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(int)section
{
    return (section == 0) ? @"Enabled Tabs" : @"Always start with...";
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(int)section
{
    return (section == 0) ? 4 : 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdToggle = @"ToggleCell";
    static NSString *reuseIdSimple = @"SimpleCell";

    static NSString *cellTitles[] = {@"Active Tab", @"Favorites Tab",
        @"Spotlight Tab", @"SpringBoard Tab", @"Last-used Tab"};

	UITableViewCell *cell = nil; 
    if (indexPath.section == 0) {
        // Try to retrieve from the table view a now-unused cell with the given identifier
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdToggle];
        if (cell == nil) {
            // Cell does not exist, create a new one
            cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:reuseIdToggle] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0, 0, 54.0f, 27.0f);
            button.font = [UIFont boldSystemFontOfSize:17.0f];
            [button setBackgroundImage:[[UIImage imageNamed:@"toggle_off.png"]
                stretchableImageWithLeftCapWidth:5.0f topCapHeight:0] forState:UIControlStateNormal];
            [button setBackgroundImage:[[UIImage imageNamed:@"toggle_on.png"]
                stretchableImageWithLeftCapWidth:5.0f topCapHeight:0] forState:UIControlStateSelected];
            [button setTitle:@"OFF" forState:UIControlStateNormal];
            [button setTitle:@"ON" forState:UIControlStateSelected];
            [button setTitleColor:[UIColor colorWithWhite:0.5f alpha:1.0f] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [button addTarget:self action:@selector(buttonToggled:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = button;
        }
        cell.text = cellTitles[indexPath.row];

        UIButton *button = (UIButton *)cell.accessoryView;
		Preferences *prefs = [Preferences sharedInstance];
        switch (indexPath.row) {
            case 0:
                button.selected = prefs.showActive;
                break;
            case 1:
                button.selected = prefs.showFavorites;
                break;
            case 2:
                button.selected = prefs.showSpotlight;
                break;
            case 3:
                button.selected = prefs.showSpringBoard;
                break;
            default:
                break;
        }
    } else {
        // Try to retrieve from the table view a now-unused cell with the given identifier
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdSimple];
        if (cell == nil) {
            // Cell does not exist, create a new one
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdSimple] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        cell.textLabel.text = cellTitles[indexPath.row];
        cell.accessoryType = ([[Preferences sharedInstance] initialView] == indexPath.row) ?
            UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }

    return cell;
}

#pragma mark - UITableViewCellDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        // Store the selected option
        [[Preferences sharedInstance] setInitialView:indexPath.row];
        [tableView reloadData];
    }
}

#pragma mark - Actions

- (void)buttonToggled:(UIButton *)button
{
    // Update selected state of button
    button.selected = !button.selected;

	Preferences *prefs = [Preferences sharedInstance];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)[button superview]];
    switch (indexPath.row) {
		case 0:
			prefs.showActive = button.selected;
			break;
		case 1:
			prefs.showFavorites = button.selected;
			break;
		case 2:
			prefs.showSpotlight = button.selected;
			break;
		case 3:
			prefs.showSpringBoard = button.selected;
			break;
		default:
			break;
	}
}

@end

/* vim: set syntax=objc sw=4 ts=4 sts=4 expandtab textwidth=80 ff=unix: */

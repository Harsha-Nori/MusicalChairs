//
//  AddPackageViewController.m
//  Musical Chairs
//
//  Created by Harsha Nori on 9/26/15.
//  Copyright © 2015 Harsha Nori. All rights reserved.
//

#import "AddPackageTableViewController.h"
#import "AppDelegate.h"

@interface AddPackageTableViewController (){
    
}

@end

@implementation AddPackageTableViewController

- (IBAction)cancel:(id)sender
{
    [self.delegate addPackageTableViewControllerDidCancel:self];
}
- (IBAction)done:(id)sender
{
    NSDictionary *package = [[NSDictionary alloc] initWithObjectsAndKeys:
                             [[self sourceTextField] text], @"source",
                             [[self destinationTextField] text], @"destination",
                             @"85EB652B-53E1-4A40-AA1D-7BA954C59B3F", @"owner",
                             nil];
    [self.delegate addPackageTableViewController:self didAddPackage:package];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self.sourceTextField becomeFirstResponder];
    }
    else if (indexPath.section == 1) {
        [self.destinationTextField becomeFirstResponder];
    }
}

@end
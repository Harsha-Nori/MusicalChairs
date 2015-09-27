//
//  AddPackageViewController.h
//  Musical Chairs
//
//  Created by Harsha Nori on 9/26/15.
//  Copyright © 2015 Harsha Nori. All rights reserved.
//

#ifndef AddPackageViewTableController_h
#define AddPackageViewTableController_h

#import <UIKit/UIKit.h>

@class AddPackageTableViewController;

@protocol AddPackageTableViewControllerDelegate <NSObject>
- (void)addPackageTableViewControllerDidCancel:(AddPackageTableViewController *)controller;
- (void)addPackageTableViewController:(AddPackageTableViewController *)controller didAddPackage: (NSDictionary *)package;
@end

@interface AddPackageTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UITextField *sourceTextField;
@property (weak, nonatomic) IBOutlet UITextField *destinationTextField;

@property (nonatomic, weak) id <AddPackageTableViewControllerDelegate> delegate;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end


#endif /* AddPackageViewController_h */

//
//  SecondViewController.m
//  Musical Chairs
//
//  Created by Harsha Nori on 9/26/15.
//  Copyright © 2015 Harsha Nori. All rights reserved.
//

#import "PackageTableViewController.h"
#import "AppDelegate.h"
#import "ChooseCourierTableViewController.h"

@interface PackageTableViewController (){
    
    NSArray *tableObjects;
    MSClient *client;
    MSTable *packagesTable;
    
}

@end

@implementation PackageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    client = [(AppDelegate *) [[UIApplication sharedApplication] delegate] client];
    packagesTable = [client tableWithName:@"Packages"];
    [self pullFromAzure];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self pullFromAzure];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableObjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PackageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSDictionary *package = [tableObjects objectAtIndex:[indexPath row]];
    
    [[cell textLabel] setFont:[UIFont systemFontOfSize:22.0]];
    [[cell textLabel] setText:[NSString stringWithFormat:@"%@ to %@", [package objectForKey:@"source"], [package objectForKey:@"destination"]]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"ChooseCourier" sender:indexPath];
}

#pragma mark - Add Package Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddPackage"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        AddPackageTableViewController *addPackageTableViewController = [navigationController viewControllers][0];
        addPackageTableViewController.delegate = self;
    } else if ([segue.identifier isEqualToString:@"ChooseCourier"]) {
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        ChooseCourierTableViewController *destViewController = segue.destinationViewController;
        destViewController.package = [tableObjects objectAtIndex:indexPath.row];
    }
}

#pragma mark - PlayerDetailsViewControllerDelegate

- (void)addPackageTableViewControllerDidCancel:(AddPackageTableViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addPackageTableViewController:(AddPackageTableViewController *)controller didAddPackage:(NSDictionary *)package
{
    [self pushToAzure:package];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Azure Methods

- (void)pullFromAzure{
    MSQuery *query = [packagesTable queryWithPredicate:[NSPredicate predicateWithFormat:@"owner == '85EB652B-53E1-4A40-AA1D-7BA954C59B3F'"]];
    [query readWithCompletion:^(MSQueryResult *result, NSError *error) {
        if(error) {
            NSLog(@"ERROR %@", error);
        } else {
            tableObjects = result.items;
            [[self tableView] reloadData];
        }
    }];
}

- (void)pushToAzure:(NSDictionary *)package{
    [packagesTable insert:package completion:^(NSDictionary *item, NSError *error) {
        if(error) {
            NSLog(@"ERROR %@", error);
        } else {
            [self pullFromAzure];
        }
    }];
}

@end

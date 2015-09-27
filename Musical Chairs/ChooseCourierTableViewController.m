//
//  ChooseCourierTableViewController.m
//  Musical Chairs
//
//  Created by Harsha Nori on 9/26/15.
//  Copyright © 2015 Harsha Nori. All rights reserved.
//

#import "ChooseCourierTableViewController.h"
#import "AppDelegate.h"

@interface ChooseCourierTableViewController (){
    NSArray *flightsLocal;
    NSMutableArray *usersLocal;
    MSClient *client;
    MSTable *flightsTable;
    MSTable *usersTable;
    MSTable *packageRequestsTable;
}

@end

@implementation ChooseCourierTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:[NSString stringWithFormat:@"%@ to %@", [_package objectForKey:@"source"], [_package objectForKey:@"destination"]]];
    client = [(AppDelegate *) [[UIApplication sharedApplication] delegate] client];
    flightsTable = [client tableWithName:@"Flights"];
    usersTable = [client tableWithName:@"Users"];
    packageRequestsTable = [client tableWithName:@"PackageRequests"];
    usersLocal = [[NSMutableArray alloc] init];
    [self pullFromAzure];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self pullFromAzure];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [usersLocal count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CourierCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSDictionary *user = [usersLocal objectAtIndex:[indexPath row]];
    NSDictionary *flight;
    for(NSDictionary *f in flightsLocal){
        if([[f valueForKey:@"id"] isEqualToString:[user valueForKey:@"flight"]]){
            flight = f;
        }
    }
    
    [[cell textLabel] setFont:[UIFont systemFontOfSize:22.0]];
    [[cell detailTextLabel] setFont:[UIFont systemFontOfSize:22.0]];
    [[cell textLabel] setText:[NSString stringWithFormat:@"%@", [user objectForKey:@"username"]]];
    NSDate *departureTime = [flight objectForKey:@"departureTime"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM d    h:mm a"];
    [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@", [dateFormat stringFromDate:departureTime]]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *user = [usersLocal objectAtIndex:[indexPath row]];
    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    [request setObject:[_package objectForKey:@"id"] forKey:@"package"];
    [request setObject:[user objectForKey:@"id"] forKey:@"receiver"];
    [self pushToAzure:request];
}

#pragma mark - Azure Methods

- (void)pullFromAzure{
    [self pullFlights];
}

- (void)pullFlights{
    MSQuery *query = [flightsTable queryWithPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(source == '%@') AND (destination == '%@')",
                                                                                        [_package objectForKey:@"source"],
                                                                                        [_package objectForKey:@"destination"]]]];
    [query readWithCompletion:^(MSQueryResult *result, NSError *error) {
        if(error) {
            NSLog(@"ERROR %@", error);
        } else {
            flightsLocal = result.items;
            [self pullUsers];
        }
    }];
}

- (void)pullUsers{
    usersLocal = [[NSMutableArray alloc] init];
    for(NSDictionary *flight in flightsLocal){
        MSQuery *query = [usersTable queryWithPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"flight == '%@'",
                                                                                          [flight objectForKey:@"id"]]]];
        [query readWithCompletion:^(MSQueryResult *result, NSError *error) {
            if(error) {
                NSLog(@"ERROR %@", error);
            } else {
                [usersLocal addObjectsFromArray:result.items];
                [[self tableView] reloadData];
            }
        }];
    }
}

- (void)pushToAzure:(NSDictionary *)request{
    [packageRequestsTable insert:request completion:^(NSDictionary *item, NSError *error) {
        if(error) {
            NSLog(@"ERROR %@", error);
        } else {
            NSLog(@"SUCCESS");
        }
    }];
}

@end

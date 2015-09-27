//
//  ChooseSeatTableViewController.m
//  Musical Chairs
//
//  Created by Harsha Nori on 9/27/15.
//  Copyright © 2015 Harsha Nori. All rights reserved.
//

#import "ChooseSeatTableViewController.h"
#import "AppDelegate.h"

@interface ChooseSeatTableViewController (){
    NSMutableArray *usersLocal;
    NSMutableArray *seatsLocal;
    MSClient *client;
    MSTable *flightsTable;
    MSTable *usersTable;
    MSTable *seatsTable;
    MSTable *seatRequestsTable;
    NSDictionary *user;
    NSDictionary *seat;
}

@end

@implementation ChooseSeatTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    client = [(AppDelegate *) [[UIApplication sharedApplication] delegate] client];
    flightsTable = [client tableWithName:@"Flights"];
    usersTable = [client tableWithName:@"Users"];
    seatsTable = [client tableWithName:@"Seats"];
    seatRequestsTable = [client tableWithName:@"SeatRequests"];
    usersLocal = [[NSMutableArray alloc] init];
    [self pullFromAzure];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //[self pullFromAzure];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [usersLocal count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SeatCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSDictionary *u = [usersLocal objectAtIndex:[indexPath row]];
    NSDictionary *s;
    for(NSDictionary *sTemp in seatsLocal){
        if([[sTemp valueForKey:@"id"] isEqualToString:[u valueForKey:@"seat"]]){
            s = sTemp;
        }
    }
    
    [[cell textLabel] setText:[NSString stringWithFormat:@"%@ %@    %@", [s objectForKey:@"seatRow"], [s objectForKey:@"seatColumn"], [u objectForKey:@"username"]]];
    [[cell detailTextLabel] setText:@""];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *u = [usersLocal objectAtIndex:[indexPath row]];
    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    [request setObject:[user objectForKey:@"id"] forKey:@"sender"];
    [request setObject:[u objectForKey:@"id"] forKey:@"receiver"];
    [self pushToAzure:request];
}

#pragma mark - Azure Methods

- (void)pullFromAzure{
    [self pullUser];
}

- (void)pullUser{
    MSQuery *query = [usersTable queryWithPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"id == '%@'", _userID]]];
    [query readWithCompletion:^(MSQueryResult *result, NSError *error) {
        if(error) {
            NSLog(@"ERROR %@", error);
        } else {
            user = result.items[0];
            [self pullUsers];
            [self pullCurrentSeat];
        }
    }];
}

- (void)pullUsers{
    usersLocal = [[NSMutableArray alloc] init];
    MSQuery *query = [usersTable queryWithPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"flight == '%@'",[user objectForKey:@"flight"]]]];
    [query readWithCompletion:^(MSQueryResult *result, NSError *error) {
        if(error) {
            NSLog(@"ERROR %@", error);
        } else {
            for(NSDictionary *u in result.items){
                if([[u objectForKey:@"id"] isEqualToString:[user objectForKey:@"id"]] == NO){
                    [usersLocal addObject:u];
                }
            }
            [self pullSeats];
        }
    }];
}

- (void)pullSeats{
    seatsLocal = [[NSMutableArray alloc] init];
    for(NSDictionary *u in usersLocal){
        MSQuery *query = [seatsTable queryWithPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"id == '%@'",[u objectForKey:@"seat"]]]];
        [query readWithCompletion:^(MSQueryResult *result, NSError *error) {
            if(error) {
                NSLog(@"ERROR %@", error);
            } else {
                if([[result items] count] > 0){
                    [seatsLocal addObject:result.items[0]];
                }
                [[self tableView] reloadData];
            }
        }];
    }
}

- (void)pullCurrentSeat{
    MSQuery *query = [seatsTable queryWithPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"id == '%@'",[user objectForKey:@"seat"]]]];
    [query readWithCompletion:^(MSQueryResult *result, NSError *error) {
        if(error) {
            NSLog(@"ERROR %@", error);
        } else {
            if([[result items] count] > 0){
                seat = result.items[0];
            }
            [self setTitle:[NSString stringWithFormat:@"%@ %@", [seat objectForKey:@"seatRow"], [seat objectForKey:@"seatColumn"]]];
        }
    }];
}

- (void)pushToAzure:(NSDictionary *)request{
    [seatRequestsTable insert:request completion:^(NSDictionary *item, NSError *error) {
        if(error) {
            NSLog(@"ERROR %@", error);
        } else {
            NSLog(@"SUCCESS");
        }
    }];
}

@end

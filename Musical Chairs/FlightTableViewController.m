//
//  FirstViewController.m
//  Musical Chairs
//
//  Created by Harsha Nori on 9/26/15.
//  Copyright © 2015 Harsha Nori. All rights reserved.
//

#import "FlightTableViewController.h"
#import "AppDelegate.h"
#import "ChooseSeatTableViewController.h"

@interface FlightTableViewController (){
    NSMutableArray *usersLocal;
    NSArray *flightsLocal;
    MSClient *client;
    MSTable *flightsTable;
    MSTable *usersTable;
    MSTable *seatsTable;
    MSTable *packagesTable;
    NSString *userID;
    NSDictionary *user;
    NSDictionary *flight;
    NSDictionary *seat;
    NSDictionary *package;
    NSDictionary *packageOwner;
}

@end

@implementation FlightTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"hit1");
    client = [(AppDelegate *) [[UIApplication sharedApplication] delegate] client];
    usersTable = [client tableWithName:@"Users"];
    flightsTable = [client tableWithName:@"Flights"];
    seatsTable = [client tableWithName:@"Seats"];
    packagesTable = [client tableWithName:@"Packages"];
    userID = @"4F979FC8-CC63-45E3-8E9F-2F7509833036";
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self pullFromAzure];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([indexPath section] == 1 && [indexPath row] == 0){
        [self performSegueWithIdentifier:@"ChooseSeat" sender:indexPath];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ChooseSeat"]) {
        ChooseSeatTableViewController *destViewController = segue.destinationViewController;
        NSLog(@"USER: %@", user);
        [destViewController setUserID:userID];
    }
}

#pragma mark - Azure Methods

- (void)pullFromAzure{
    [self pullUser];
}

- (void)pullUser{
    MSQuery *query = [usersTable queryWithPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"id == '%@'", userID]]];
    [query readWithCompletion:^(MSQueryResult *result, NSError *error) {
        if(error) {
            NSLog(@"ERROR %@", error);
        } else {
            user = result.items[0];
            NSLog(@"%@", user);
            [self pullFlight];
            [self pullSeat];
            [self pullPackage];
        }
    }];
}

- (void)pullFlight{
    MSQuery *query = [flightsTable queryWithPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"id == '%@'", [user objectForKey:@"flight"]]]];
    [query readWithCompletion:^(MSQueryResult *result, NSError *error) {
        if(error) {
            NSLog(@"ERROR %@", error);
        } else {
            flight = result.items[0];
            NSLog(@"%@", flight);
            [[[[self tableView] headerViewForSection:0] textLabel] setText:[flight objectForKey:@"flightNumber"]];
            [[self sourceTextField] setText:[flight objectForKey:@"source"]];
            [[self destinationTextField] setText:[flight objectForKey:@"destination"]];
            NSDate *departureTime = [flight objectForKey:@"departureTime"];
            NSDate *arrivalTime = [flight objectForKey:@"arrivalTime"];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"MMM d    h:mm a"];
            [[self departureTimeTextField] setText:[NSString stringWithFormat:@"Departs: %@",[dateFormat stringFromDate:departureTime]]];
            [[self arrivalTimeTextField] setText:[NSString stringWithFormat:@"Arrives: %@",[dateFormat stringFromDate:arrivalTime]]];
        }
    }];
}

- (void)pullSeat{
    MSQuery *query = [seatsTable queryWithPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"id == '%@'", [user objectForKey:@"seat"]]]];
    [query readWithCompletion:^(MSQueryResult *result, NSError *error) {
        if(error) {
            NSLog(@"ERROR %@", error);
        } else {
            for(NSDictionary *s in result.items){
                seat = s;
                NSLog(@"%@", seat);
            }
            if (seat != nil) {
                [[self seatTextField] setText:[NSString stringWithFormat:@"%@ %@", [seat objectForKey:@"seatRow"], [seat objectForKey:@"seatColumn"]]];
            }
        }
    }];
}

- (void)pullPackage{
    MSQuery *query = [packagesTable queryWithPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"id == '%@'", [user objectForKey:@"courierPackage"]]]];
    [query readWithCompletion:^(MSQueryResult *result, NSError *error) {
        if(error) {
            NSLog(@"ERROR %@", error);
        } else {
            for(NSDictionary *p in result.items){
                package = p;
                NSLog(@"%@", package);
                [self pullPackageOwner];
            }
        }
    }];
}
     
- (void)pullPackageOwner{
    MSQuery *query = [usersTable queryWithPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"id == '%@'", [package objectForKey:@"owner"]]]];
    [query readWithCompletion:^(MSQueryResult *result, NSError *error) {
        if(error) {
            NSLog(@"ERROR %@", error);
            } else {
            for(NSDictionary *o in result.items){
                packageOwner = o;
                NSLog(@"%@", packageOwner);
            }
            if (packageOwner != nil) {
                [[self courierPackageTextField] setText:[packageOwner objectForKey:@"username"]];
            }
        }
    }];
}


     
@end

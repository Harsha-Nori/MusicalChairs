//
//  AppDelegate.m
//  Musical Chairs
//
//  Created by Harsha Nori on 9/26/15.
//  Copyright © 2015 Harsha Nori. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (){
    MSClient *client;
    MSTable *flightsTable;
    MSTable *usersTable;
    MSTable *packagesTable;
    MSTable *seatsTable;
    NSDictionary *package;
    NSDictionary *owner;
    NSDictionary *sender;
    NSDictionary *receiver;
    NSDictionary *senderOldSeat;
    NSDictionary *receiverOldSeat;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.client = [MSClient clientWithApplicationURLString:@"https://musicalchairs.azure-mobile.net/"
                                            applicationKey:@"iqBWSxPonPxehlmhoFqNJoazvbNDWP78"];
    
    client = [(AppDelegate *) [[UIApplication sharedApplication] delegate] client];
    flightsTable = [client tableWithName:@"Flights"];
    usersTable = [client tableWithName:@"Users"];
    packagesTable = [client tableWithName:@"Packages"];
    seatsTable = [client tableWithName:@"Seats"];
    
    UIMutableUserNotificationAction *acceptPackageAction = [[UIMutableUserNotificationAction alloc] init];
    acceptPackageAction.identifier = @"ACCEPT_PACKAGE_IDENTIFIER";
    acceptPackageAction.title = @"Accept";
    acceptPackageAction.activationMode = UIUserNotificationActivationModeBackground;
    acceptPackageAction.destructive = NO;
    acceptPackageAction.authenticationRequired = NO;
    
    UIMutableUserNotificationAction *declinePackageAction = [[UIMutableUserNotificationAction alloc] init];
    declinePackageAction.identifier = @"DECLINE_PACKAGE_IDENTIFIER";
    declinePackageAction.title = @"Decline";
    declinePackageAction.activationMode = UIUserNotificationActivationModeBackground;
    declinePackageAction.destructive = YES;
    declinePackageAction.authenticationRequired = NO;
    
    UIMutableUserNotificationCategory *packageCategory = [[UIMutableUserNotificationCategory alloc] init];
    packageCategory.identifier = @"PACKAGE_CATEGORY";
    [packageCategory setActions:@[acceptPackageAction, declinePackageAction] forContext:UIUserNotificationActionContextDefault];
    [packageCategory setActions:@[acceptPackageAction, declinePackageAction] forContext:UIUserNotificationActionContextMinimal];
    
    UIMutableUserNotificationAction *acceptSeatAction = [[UIMutableUserNotificationAction alloc] init];
    acceptSeatAction.identifier = @"ACCEPT_SEAT_IDENTIFIER";
    acceptSeatAction.title = @"Accept";
    acceptSeatAction.activationMode = UIUserNotificationActivationModeBackground;
    acceptSeatAction.destructive = NO;
    acceptSeatAction.authenticationRequired = NO;
    
    UIMutableUserNotificationAction *declineSeatAction = [[UIMutableUserNotificationAction alloc] init];
    declineSeatAction.identifier = @"DECLINE_SEAT_IDENTIFIER";
    declineSeatAction.title = @"Decline";
    declineSeatAction.activationMode = UIUserNotificationActivationModeBackground;
    declineSeatAction.destructive = YES;
    declineSeatAction.authenticationRequired = NO;
    
    UIMutableUserNotificationCategory *seatCategory = [[UIMutableUserNotificationCategory alloc] init];
    seatCategory.identifier = @"SEAT_CATEGORY";
    [seatCategory setActions:@[acceptSeatAction, declineSeatAction] forContext:UIUserNotificationActionContextDefault];
    [seatCategory setActions:@[acceptSeatAction, declineSeatAction] forContext:UIUserNotificationActionContextMinimal];
    
    NSSet *categories = [NSSet setWithObjects:packageCategory, seatCategory, nil];
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeSound |
                                            UIUserNotificationTypeAlert | UIUserNotificationTypeBadge categories:categories];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    return YES;
}

- (void)application:(UIApplication *) application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)notification completionHandler: (void (^)())completionHandler {
    NSLog(@"hit");
    if ([identifier isEqualToString: @"ACCEPT_PACKAGE_IDENTIFIER"]) {
        [self handleAcceptPackageActionWithNotification:notification];
    }
    else if ([identifier isEqualToString: @"DECLINE_PACKAGE_IDENTIFIER"]) {
        [self handleDeclinePackageActionWithNotification:notification];
    }
    else if ([identifier isEqualToString: @"ACCEPT_SEAT_IDENTIFIER"]) {
        [self handleAcceptSeatActionWithNotification:notification];
    }
    else if ([identifier isEqualToString: @"DECLINE_SEAT_IDENTIFIER"]) {
        [self handleDeclineSeatActionWithNotification:notification];
    }
    completionHandler();
}

- (void) handleAcceptPackageActionWithNotification:(NSDictionary *)notification {
    NSLog(@"ACCEPT PACKAGE: %@", notification);
    NSDictionary *apsPayload = notification[@"aps"];
    NSString *packageID = apsPayload[@"package"];
    NSString *receiverID = apsPayload[@"receiver"];
    NSLog(@"apsPayload: %@", apsPayload);
    NSLog(@"receiver: %@", receiverID);
    NSLog(@"package: %@", packageID);
    [usersTable update:@{@"id":receiverID, @"courierPackage":packageID} completion:^(NSDictionary *item, NSError *error){
        if(error) {
            NSLog(@"ERROR %@", error);
        } else {
            NSLog(@"good job");
        }
    }];
}

- (void) handleDeclinePackageActionWithNotification:(NSDictionary *)notification {
    NSLog(@"DECLINE PACKAGE: %@", notification);
}

- (void) handleAcceptSeatActionWithNotification:(NSDictionary *)notification {
    NSLog(@"SEAT PACKAGE: %@", notification);
    NSDictionary *apsPayload = notification[@"aps"];
    NSString *senderID = apsPayload[@"sender"];
    NSString *receiverID = apsPayload[@"receiver"];
    NSLog(@"apsPayload: %@", apsPayload);
    NSLog(@"receiver: %@", receiverID);
    NSLog(@"sender: %@", senderID);
    [self pullSender:senderID ReceiverID:receiverID];
}

- (void) handleDeclineSeatActionWithNotification:(NSDictionary *)notification {
    NSLog(@"SEAT PACKAGE: %@", notification);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *) deviceToken {
    SBNotificationHub* hub = [[SBNotificationHub alloc] initWithConnectionString:@"Endpoint=sb://musicalchairshub-ns.servicebus.windows.net/;SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey=GsJmeS0i7lMkxl3InTx3GKCGBmCFrQNN67sZWHCUpTg="
                                                             notificationHubPath:@"musicalchairshub3"];
    
    [hub registerNativeWithDeviceToken:deviceToken tags:nil completion:^(NSError* error) {
        if (error != nil) {
            NSLog(@"Error registering for notifications: %@", error);
        }
    }];
}


// Use userInfo in the payload to display a UIAlertView.
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)notification{
    NSLog(@"NOTIFICATION: %@", notification);
    NSDictionary *apsPayload = notification[@"aps"];
    NSString *receiverID = apsPayload[@"receiver"];
    NSString *cat = apsPayload[@"category"];
    if([cat isEqualToString:@"PACKAGE_CATEGORY"]){
        NSString *packageID = apsPayload[@"package"];
        if([receiverID isEqualToString:@"4F979FC8-CC63-45E3-8E9F-2F7509833036"] == NO){
            NSLog(@"This is not the request you were looking for");
            return;
        }
        [self pullPackages:packageID notification:notification];
    }
    else{
        //NSString *senderID = apsPayload[@"sender"];
        if([receiverID isEqualToString:@"4F979FC8-CC63-45E3-8E9F-2F7509833036"] == NO){
            NSLog(@"This is not the request you were looking for");
            return;
        }
        NSString *message = [NSString stringWithFormat:@"Switch Seats?"];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Seat Request" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *seatAcceptAction = [UIAlertAction actionWithTitle:@"Accept" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self handleAcceptSeatActionWithNotification:notification];
        }];
        UIAlertAction *seatDeclineAction = [UIAlertAction actionWithTitle:@"Decline" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self handleDeclineSeatActionWithNotification:notification];
        }];
        [alert addAction:seatAcceptAction];
        [alert addAction:seatDeclineAction];
        [[[self window] rootViewController] presentViewController:alert animated:YES completion:nil];
    }
}

- (void)pullPackages:(NSString*)packageID notification:(NSDictionary *)notification{
    MSQuery *query = [packagesTable queryWithPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"id == '%@'", packageID]]];
    [query readWithCompletion:^(MSQueryResult *result, NSError *error) {
        if(error) {
            NSLog(@"ERROR %@", error);
        } else {
            package = result.items[0];
            [self pullUsers:notification];
        }
    }];
}

- (void)pullUsers:(NSDictionary *)notification{
    MSQuery *query2 = [usersTable queryWithPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"id == '%@'", package[@"owner"]]]];
    [query2 readWithCompletion:^(MSQueryResult *result, NSError *error) {
        if(error) {
            NSLog(@"ERROR %@", error);
        } else {
            owner = result.items[0];
            NSString *message = [NSString stringWithFormat:@"%@ wants you to deliver a package", owner[@"username"]];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Package Request" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *packageAcceptAction = [UIAlertAction actionWithTitle:@"Accept" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self handleAcceptPackageActionWithNotification:notification];
            }];
            UIAlertAction *packageDeclineAction = [UIAlertAction actionWithTitle:@"Decline" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [self handleDeclinePackageActionWithNotification:notification];
            }];
            [alert addAction:packageAcceptAction];
            [alert addAction:packageDeclineAction];
            [[[self window] rootViewController] presentViewController:alert animated:YES completion:nil];
        }
    }];
}

- (void)pullSender:(NSString *)senderID ReceiverID:(NSString *)receiverID{
    MSQuery *query = [usersTable queryWithPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"id == '%@'", senderID]]];
    [query readWithCompletion:^(MSQueryResult *result, NSError *error) {
        if(error) {
            NSLog(@"ERROR %@", error);
        } else {
            sender = result.items[0];
            [self pullSenderSeat:[sender objectForKey:@"seat"] ReceiverID:receiverID];
        }
    }];
}

- (void)pullSenderSeat:(NSString *)senderSeatID ReceiverID:(NSString *)receiverID{
    MSQuery *query = [seatsTable queryWithPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"id == '%@'", senderSeatID]]];
    [query readWithCompletion:^(MSQueryResult *result, NSError *error) {
        if(error) {
            NSLog(@"ERROR %@", error);
        } else {
            senderOldSeat = result.items[0];
            [self pullReceiver:receiverID];
        }
    }];
}

- (void)pullReceiver:(NSString *)receiverID{
    MSQuery *query = [usersTable queryWithPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"id == '%@'", receiverID]]];
    [query readWithCompletion:^(MSQueryResult *result, NSError *error) {
        if(error) {
            NSLog(@"ERROR %@", error);
        } else {
            receiver = result.items[0];
            [self pullReceiverSeat:[receiver objectForKey:@"seat"]];
        }
    }];
}

- (void)pullReceiverSeat:(NSString *)receiverSeatID{
    MSQuery *query = [seatsTable queryWithPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"id == '%@'", receiverSeatID]]];
    [query readWithCompletion:^(MSQueryResult *result, NSError *error) {
        if(error) {
            NSLog(@"ERROR %@", error);
        } else {
            receiverOldSeat = result.items[0];
            [self swapSeats];
        }
    }];
}

- (void)swapSeats{
    [usersTable update:@{@"id":sender[@"id"], @"seat":receiverOldSeat[@"id"]} completion:^(NSDictionary *item, NSError *error){
        if(error) {
            NSLog(@"ERROR %@", error);
        } else {
            NSLog(@"good job1");
        }
    }];
    [usersTable update:@{@"id":receiver[@"id"], @"seat":senderOldSeat[@"id"]} completion:^(NSDictionary *item, NSError *error){
        if(error) {
            NSLog(@"ERROR %@", error);
        } else {
            NSLog(@"good job2");
        }
    }];
}

@end

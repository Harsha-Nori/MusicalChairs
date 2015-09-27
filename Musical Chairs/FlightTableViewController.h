//
//  FirstViewController.h
//  Musical Chairs
//
//  Created by Harsha Nori on 9/26/15.
//  Copyright © 2015 Harsha Nori. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlightTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UILabel *sourceTextField;
@property (weak, nonatomic) IBOutlet UILabel *destinationTextField;
@property (weak, nonatomic) IBOutlet UILabel *departureTimeTextField;
@property (weak, nonatomic) IBOutlet UILabel *arrivalTimeTextField;
@property (weak, nonatomic) IBOutlet UILabel *seatTextField;
@property (weak, nonatomic) IBOutlet UILabel *courierPackageTextField;

@end
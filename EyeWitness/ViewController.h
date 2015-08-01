//
//  ViewController.h
//  EyeWitness
//
//  Created by Oliver Atwal on 27/07/2015.
//  Copyright (c) 2015 Oliver Atwal. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;
@import MapKit;

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, NSURLConnectionDelegate> {
    IBOutlet UITableView *cardTableView;
    
    NSMutableArray *titles;
    NSMutableArray *times;
    NSMutableArray *descriptions;
    NSMutableArray *locations;
    NSMutableArray *cellBackgroundColours;
    NSMutableArray *longitude;
    NSMutableArray *latitude;
    NSMutableArray *phoneNumbers;
    NSMutableArray *policeForces;
    
    int lastUpdate;
    
    CLLocationManager *locationManager;
    NSMutableArray *userLocations;
    
    int locationIndex;
    int selectedIndex;
    int timeClock;
}

@property (nonatomic, strong) NSURLConnection *connection;

@end


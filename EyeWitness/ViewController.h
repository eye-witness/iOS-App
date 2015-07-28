//
//  ViewController.h
//  EyeWitness
//
//  Created by Oliver Atwal on 27/07/2015.
//  Copyright (c) 2015 Oliver Atwal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *cardTableView;
    NSMutableArray *titles;
    NSMutableArray *descriptions;
    NSMutableArray *locations;
    NSMutableArray *cellBackgroundColours;
    NSMutableArray *longitude;
    NSMutableArray *latitude;
    NSMutableArray *phoneNumbers;
    NSMutableArray *policeForces;
    int selectedIndex;
}


@end


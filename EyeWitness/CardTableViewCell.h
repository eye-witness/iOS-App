//
//  CardTableViewCell.h
//  eyeWitness
//
//  Created by Oliver Atwal on 27/07/2015.
//  Copyright (c) 2015 Oliver Atwal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIView *MapViewCircle;
@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UILabel *description;
@property (strong, nonatomic) IBOutlet UILabel *location;

@property (strong, nonatomic) IBOutlet UIButton *share;
@end

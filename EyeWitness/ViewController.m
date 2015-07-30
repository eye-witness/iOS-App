//
//  ViewController.m
//  eyeWitness
//
//  Created by Oliver Atwal on 27/07/2015.
//  Copyright (c) 2015 Oliver Atwal. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CardTableViewCell.h"
#import "SCLAlertView.h"
@import GoogleMaps;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    selectedIndex = -1;
    
    cardTableView.dataSource = self;
    cardTableView.delegate = self;
    [cardTableView setBackgroundColor:[UIColor colorWithRed:((float)229 / 255.0f) green:((float)229 / 255.0f) blue:((float)229 / 255.0f) alpha:1.0f]];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:((float)229 / 255.0f) green:((float)229 / 255.0f) blue:((float)229 / 255.0f) alpha:1.0f]];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"locations"];
    userLocations = [[NSMutableArray alloc] init];
    userLocations = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    titles = [[NSMutableArray alloc] init];
    descriptions = [[NSMutableArray alloc] init];
    locations = [[NSMutableArray alloc] init];
    cellBackgroundColours = [[NSMutableArray alloc] init];
    longitude = [[NSMutableArray alloc] init];
    latitude = [[NSMutableArray alloc] init];
    policeForces = [[NSMutableArray alloc] init];
    phoneNumbers = [[NSMutableArray alloc] init];
    times = [[NSMutableArray alloc] init];
    
    [self dataForAPICall];
    
    UIView *myBox  = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 60)];
    myBox.backgroundColor = [UIColor colorWithRed:((float)66 / 255.0f) green:((float)133 / 255.0f) blue:((float)244 / 255.0f) alpha:1.0f];
    [self.view addSubview:myBox];
    
    UIImageView *EyeWitnessLogo256 = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width / 2) - 160, 10, 320, 40)];
    EyeWitnessLogo256.image = [UIImage imageNamed:@"title.png"];
    [myBox addSubview:EyeWitnessLogo256];
    
    UIView *myBox2  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    myBox2.backgroundColor = [UIColor colorWithRed:((float)51 / 255.0f) green:((float)103 / 255.0f) blue:((float)214 / 255.0f) alpha:1.0f];
    [self.view addSubview:myBox2];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    /*      CODE RESETS SAVED DATA
     
    userLocations = [[NSMutableArray alloc] init];
    NSUserDefaults *defualts = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:userLocations];
    [defualts setObject:data forKey:@"locations"];*/
    
    NSLog(@"Location Points: %lu", (unsigned long)userLocations.count);
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.delegate = self;
    [locationManager requestAlwaysAuthorization];
    
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dataForAPICall {
    int newAlerts = 0;
    
    for (int i = 0; i < 1; i++) {     //replace 1 with userLocations.count
        CLLocation *location = userLocations[i];
        int TWOXLongitude = round(location.coordinate.longitude * 2);
        int TWOXLatitude = round(location.coordinate.latitude * 2);
        NSLog(@"long: %d lat: %d", TWOXLongitude, TWOXLatitude);
        
        NSArray *APIData = [self APICallWithLongitude:TWOXLongitude andLatitude:TWOXLatitude];
        
        for (int i = 0; i < APIData.count; i++) {
            //check if the data is relevant and wich relevance stage before adding
            NSLog(@"%d: %@", i, APIData[i][@"description"][@"crimeType"]);
            [titles addObject:APIData[i][@"description"][@"crimeType"]];
            [descriptions addObject:APIData[i][@"description"][@"text"]];
            [locations addObject:APIData[i][@"description"][@"location"]];
            [cellBackgroundColours addObject:@"1"];
            [longitude addObject:APIData[i][@"location"][@"long"]];
            [latitude addObject:APIData[i][@"location"][@"lat"]];
            [policeForces addObject:APIData[i][@"contact"][@"policeForce"]];
            [phoneNumbers addObject:APIData[i][@"contact"][@"phoneNumber"]];
            [times addObject:APIData[i][@"time"]];
            
            newAlerts++;
        }
    }
    
    if (newAlerts > 0) {
        if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
            [cardTableView reloadData];
        } else {
            UILocalNotification *notify = [[UILocalNotification alloc] init];
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *dateComps = [calendar components: (NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate: [NSDate date]];
            
            NSDate *date;
            if ([dateComps second] > 30) {
                date = [calendar dateBySettingHour:[dateComps hour] minute:([dateComps minute] + 1) second:[dateComps second] ofDate:[NSDate date] options:0];
            } else {
                date = [calendar dateBySettingHour:[dateComps hour] minute:[dateComps minute] second:([dateComps second] + 20) ofDate:[NSDate date] options:0];
            }
            
            notify.fireDate = date;
            notify.alertBody = [NSString stringWithFormat:@"%d new crimes", newAlerts];
            notify.alertAction = @"Test";
            notify.category = @"e";
            
            [UIApplication sharedApplication].applicationIconBadgeNumber = newAlerts;
            [[UIApplication sharedApplication] scheduleLocalNotification:notify];
        }
    }
}

- (NSArray *)APICallWithLongitude:(int)longitudeForAPI andLatitude:(int)latitudeForAPI {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://gist.githubusercontent.com/michaelcullum/674c70d7f3b9d0c76af8/raw/5816df9f46d13187aacc2e2b88b8d9edb621b3a9/file.json"]];
    [request setHTTPMethod:@"GET"];
    NSURLResponse *requestResponse;
    NSData *requestHandler = [NSURLConnection sendSynchronousRequest:request returningResponse:&requestResponse error:nil];
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: requestHandler options: NSJSONReadingMutableContainers error:nil];
    
    NSArray *values = json[@"cases"];
    
    return values;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"ss"];
    long timeSince = [[dateFormatter stringFromDate:newLocation.timestamp] integerValue] - [[dateFormatter stringFromDate:oldLocation.timestamp] integerValue];
    
    if ([[dateFormatter stringFromDate:oldLocation.timestamp] integerValue] < [[dateFormatter stringFromDate:newLocation.timestamp] integerValue]) {
        timeSince = [[dateFormatter stringFromDate:newLocation.timestamp] integerValue] - [[dateFormatter stringFromDate:oldLocation.timestamp] integerValue];
    } else {
        timeSince = [[dateFormatter stringFromDate:oldLocation.timestamp] integerValue] - [[dateFormatter stringFromDate:newLocation.timestamp] integerValue];
    }
    
    locationIndex += timeSince;
    
    if (locationIndex > 20) {
        locationIndex = 0;
        
        [userLocations addObject:newLocation];
        
        NSUserDefaults *defualts = [NSUserDefaults standardUserDefaults];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:userLocations];
        [defualts setObject:data forKey:@"locations"];
        NSLog(@"Saving");
        
        [self dataForAPICall];
        
        NSLog(@"Quantity Of Locations: %lu", (unsigned long)userLocations.count);
    }
}

#pragma mark - tableview datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (titles.count == 0) {
        return 2;
    } else {
        return ([titles count] * 2) + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row % 2) {
        static NSString *cellIndentifier = @"CardTableViewCell";
        
        if (titles.count == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            [cell addSubview:[self drawLabel:@"No relevant appeals for information at this time" numberOfLines:2 textSize:32.0 position:CGRectMake(0, 0, self.view.bounds.size.width - 16, 100) align:NSTextAlignmentCenter backgroundColor:[UIColor whiteColor]]];
            
            cell.layer.masksToBounds = YES;
            cell.layer.cornerRadius = 11;
            
            cell.clipsToBounds = YES;
            
            return cell;
        }
        
        CardTableViewCell *cell = (CardTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CardTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if ([[cellBackgroundColours objectAtIndex:(indexPath.row / 2)] integerValue] == 1) {
            [cell setBackgroundColor:[UIColor colorWithRed:((float)33 / 255.0f) green:((float)150 / 255.0f) blue:((float)243 / 255.0f) alpha:1.0f]];
        } else {
            [cell setBackgroundColor:[UIColor colorWithRed:((float)150 / 255.0f) green:((float)150 / 255.0f) blue:((float)150 / 255.0f) alpha:1.0f]];
        }
        
        if (selectedIndex == indexPath.row) {
            UIView *MapViewRectangle  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (self.view.bounds.size.width - 10), 300)];
            [cell addSubview:MapViewRectangle];
            
            [MapViewRectangle addSubview:[self googleMapWithLongitude:[[longitude objectAtIndex:((indexPath.row - 1) / 2)] integerValue] andLatitude:[[latitude objectAtIndex:((indexPath.row - 1) / 2)] integerValue] andFrame:MapViewRectangle.bounds andZoom:18 andUserInteraction:YES]];
            
            cell.title.hidden = YES;
            cell.description.hidden = YES;
            cell.location.hidden = YES;
            
            NSString *descriptionString = [NSString stringWithFormat:@" %@", [descriptions objectAtIndex:((indexPath.row - 1) / 2)]];
            NSString *locationString = [locations objectAtIndex:((indexPath.row - 1) / 2)];
            NSString *titleString = [NSString stringWithFormat:@" %@", [titles objectAtIndex:((indexPath.row - 1) / 2)]];
            
            NSTimeInterval seconds = [[times objectAtIndex:((indexPath.row - 1) / 2)] doubleValue];
            NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
            [dateFormatter setDateFormat:@"HH:mm EE dd-MMM"];
            NSString *convertedTime = [dateFormatter stringFromDate:epochNSDate];
            
            [cell addSubview:[self drawLabel:titleString numberOfLines:1 textSize:32.0 position:CGRectMake(0, 300, self.view.bounds.size.width - 16, 44) align:NSTextAlignmentLeft backgroundColor:[UIColor whiteColor]]];
            
            [cell addSubview:[self drawLabel:descriptionString numberOfLines:3 textSize:26.0 position:CGRectMake(0, 344, self.view.bounds.size.width - 16, 100) align:NSTextAlignmentLeft backgroundColor:[UIColor whiteColor]]];
            
            [cell addSubview:[self drawLabel:locationString numberOfLines:1 textSize:14.0 position:CGRectMake(0, 290, self.view.bounds.size.width - 25, 44) align:NSTextAlignmentRight backgroundColor:[UIColor clearColor]]];
            
            [cell addSubview:[self drawLabel:convertedTime numberOfLines:1 textSize:14.0 position:CGRectMake(0, 320, self.view.bounds.size.width - 25, 44) align:NSTextAlignmentRight backgroundColor:[UIColor clearColor]]];
            
            [cell.report addTarget:self action:@selector(reportWithPosition) forControlEvents:UIControlEventTouchUpInside];
            [cell.reportLabel addTarget:self action:@selector(reportWithPosition) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.close addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
            [cell.closeLabel addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
            
            cell.close.hidden = NO;
            cell.report.hidden = NO;
            cell.closeLabel.hidden = NO;
            cell.reportLabel.hidden = NO;
            
        } else {
            UIImageView *testImage =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
            testImage.image = [UIImage imageNamed:@"testImage.png"];
            [cell.MapViewCircle addSubview:testImage];
            
            cell.MapViewCircle.clipsToBounds = YES;
            [self setRoundedView:cell.MapViewCircle toDiameter:150.0];
            
            cell.close.hidden = YES;
            cell.closeLabel.hidden = YES;
            cell.report.hidden = YES;
            cell.reportLabel.hidden = YES;
        }
        
        NSString *descriptionString = [NSString stringWithFormat:@" %@", [descriptions objectAtIndex:((indexPath.row - 1) / 2)]];
        NSString *titleString = [NSString stringWithFormat:@" %@", [titles objectAtIndex:((indexPath.row - 1) / 2)]];
        NSString *locationString = [locations objectAtIndex:((indexPath.row - 1) / 2)];
        
        NSTimeInterval seconds = [[times objectAtIndex:((indexPath.row - 1) / 2)] doubleValue];
        NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [dateFormatter setDateFormat:@"HH:mm EE dd-MMM"];
        NSString *convertedTime = [dateFormatter stringFromDate:epochNSDate];
        
        cell.title.text = titleString;
        cell.description.text = descriptionString;
        cell.location.text = locationString;
        cell.time.text = convertedTime;
        
        cell.layer.masksToBounds = YES;
        cell.layer.cornerRadius = 11;
        
        cell.clipsToBounds = YES;
        
        return cell;
    } else {
        static NSString *cellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell setBackgroundColor:[UIColor colorWithRed:((float)229 / 255.0f) green:((float)229 / 255.0f) blue:((float)229 / 255.0f) alpha:1.0f]];
        
        return cell;
    }
}

- (UILabel *)drawLabel:(NSString *)text numberOfLines:(int)lines textSize:(int)textSize position:(CGRect)position align:(NSTextAlignment)alignment backgroundColor:(UIColor *)backgroundColor {
    UILabel *NewLabel = [[UILabel alloc] initWithFrame:position];
    
    NewLabel.text = text;
    NewLabel.textColor = [UIColor blackColor];
    NewLabel.adjustsFontSizeToFitWidth = NO;
    NewLabel.backgroundColor = backgroundColor;
    NewLabel.textAlignment = alignment;
    NewLabel.font = [UIFont fontWithName:@"Roboto-Light" size:textSize];
    NewLabel.hidden = NO;
    NewLabel.numberOfLines = lines;
    
    return NewLabel;
}

- (GMSMapView *)googleMapWithLongitude:(long)longi andLatitude:(long)lat andFrame:(CGRect)frame andZoom:(int)zoom andUserInteraction:(BOOL)interaction {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat longitude:longi zoom:zoom];
    GMSMapView *mapView = [GMSMapView mapWithFrame:frame camera:camera];
    mapView.userInteractionEnabled = interaction;
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = camera.target;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = mapView;
    
    return mapView;
}

- (void)reportWithPosition {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    int pos = ((selectedIndex - 1) / 2);
    
    NSString *phone = [NSString stringWithFormat:@"Phone %@", [phoneNumbers objectAtIndex:pos]];
    [alert addButton:phone actionBlock:^(void) {
        NSLog(@"Phone button tapped");
        NSString *tel = [NSString stringWithFormat:@"Tel:%@", [phoneNumbers objectAtIndex:pos]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:tel]];
    }];
    
    [alert addButton:@"Email" actionBlock:^(void) {
        NSLog(@"Email button tapped");
    }];
    
    alert.shouldDismissOnTapOutside = YES;
    alert.showAnimationType = SlideInFromBottom;
    alert.hideAnimationType = SlideOutToBottom;
    
    
    NSString *reportTitle = [NSString stringWithFormat:@"Report To %@", [policeForces objectAtIndex:pos]];
    [alert showCustom:self image:[UIImage imageNamed:@"256 EyeWitness Logo.png"] color:[UIColor colorWithRed:((float)66 / 255.0f) green:((float)133 / 255.0f) blue:((float)244 / 255.0f) alpha:1.0f] title:reportTitle subTitle:@"do not hesitate to report any suspicous behavour" closeButtonTitle:@"Cancel" duration:0.0f];
}

- (void)dismiss {
    int pos = ((selectedIndex - 1) / 2);
    [titles removeObjectAtIndex:pos];
    [descriptions removeObjectAtIndex:pos];
    [locations removeObjectAtIndex:pos];
    [cellBackgroundColours removeObjectAtIndex:pos];
    [longitude removeObjectAtIndex:pos];
    [latitude removeObjectAtIndex:pos];
    [policeForces removeObjectAtIndex:pos];
    [phoneNumbers removeObjectAtIndex:pos];
    
    selectedIndex = -1;
    
    [cardTableView reloadData];
    
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionFade];
    [animation setSubtype:kCATransitionFade];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFillMode:kCAFillModeBoth];
    [animation setDuration:.3];
    [self.view.layer addAnimation:animation forKey:@"UITableViewReloadDataAnimationKey"];
}

-(void)setRoundedView:(UIView *)roundedView toDiameter:(float)newSize {
    CGPoint saveCenter = roundedView.center;
    CGRect newFrame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y, newSize, newSize);
    roundedView.frame = newFrame;
    roundedView.layer.cornerRadius = newSize / 2.0;
    roundedView.center = saveCenter;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2) {
        if (selectedIndex == indexPath.row) {
            NSLog(@"%f", (self.view.bounds.size.height - 80));
            return (self.view.bounds.size.height - 93);
        } else if (titles.count == 0) {
            return 100;
        } else {
            return 195;
        }
    } else {
        return 8;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2 && titles.count != 0) {
        if (selectedIndex == indexPath.row){
            selectedIndex = -1;
            [UIView setAnimationDuration:0.2];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
            [UIView setAnimationDuration:0];
            return;
        }
        
        if (selectedIndex != -1) {
            NSIndexPath *prevPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
            selectedIndex = (int)indexPath.row;
            [UIView setAnimationDuration:0.2];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:prevPath, nil] withRowAnimation:UITableViewRowAnimationFade];
            [UIView setAnimationDuration:0];
            
            selectedIndex = -1;
            [UIView setAnimationDuration:0.2];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
            [UIView setAnimationDuration:0];
            
            //[tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            
            return;
        }
        
        selectedIndex = (int)indexPath.row;
        [UIView setAnimationDuration:0.2];
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
        [UIView setAnimationDuration:0];
    }
}

@end

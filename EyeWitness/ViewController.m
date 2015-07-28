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
    
    [self APICall];
    
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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"locations"];
    userLocations = [[NSMutableArray alloc] init];
    userLocations = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
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

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    locationIndex++;
    
    if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
        NSLog(@"App is foreground. New location is %f", newLocation.speed);
        [userLocations addObject:newLocation];
    } else {
        NSLog(@"App is backgrounded. New location is %f", newLocation.speed);
        [userLocations addObject:newLocation];
    }
    
    if (locationIndex > 10) {
        NSUserDefaults *defualts = [NSUserDefaults standardUserDefaults];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:userLocations];
        [defualts setObject:data forKey:@"locations"];
        NSLog(@"Saving");
        locationIndex = 0;
        
        NSLog(@"Location Points: %lu", (unsigned long)userLocations.count);
    }
}

- (void)APICall {
    //API Call
    
    //Parse API Data
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://gist.githubusercontent.com/michaelcullum/674c70d7f3b9d0c76af8/raw/5816df9f46d13187aacc2e2b88b8d9edb621b3a9/file.json"]];
    [request setHTTPMethod:@"GET"];
    NSURLResponse *requestResponse;
    NSData *requestHandler = [NSURLConnection sendSynchronousRequest:request returningResponse:&requestResponse error:nil];
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: requestHandler options: NSJSONReadingMutableContainers error:nil];
    
    NSArray *values = json[@"cases"];
    
    NSLog(@"%@", values[0][@"caseID"]);
    
    titles = [[NSMutableArray alloc] initWithCapacity:(values.count - 1)];
    descriptions = [[NSMutableArray alloc] initWithCapacity:(values.count - 1)];
    locations = [[NSMutableArray alloc] initWithCapacity:(values.count - 1)];
    cellBackgroundColours = [[NSMutableArray alloc] initWithCapacity:(values.count - 1)];
    longitude = [[NSMutableArray alloc] initWithCapacity:(values.count - 1)];
    latitude = [[NSMutableArray alloc] initWithCapacity:(values.count - 1)];
    policeForces = [[NSMutableArray alloc] initWithCapacity:(values.count - 1)];
    phoneNumbers = [[NSMutableArray alloc] initWithCapacity:(values.count - 1)];
    
    for (int i = 0; i < (values.count); i++) {
        NSLog(@"%d: %@", i, values[i][@"description"][@"crimeType"]);
        [titles insertObject:values[i][@"description"][@"crimeType"] atIndex:i];
        [descriptions insertObject:values[i][@"description"][@"text"] atIndex:i];
        [locations insertObject:values[i][@"description"][@"location"] atIndex:i];
        [cellBackgroundColours insertObject:@"1" atIndex:i];
        [longitude insertObject:values[i][@"location"][@"long"] atIndex:i];
        [latitude insertObject:values[i][@"location"][@"lat"] atIndex:i];
        [policeForces insertObject:values[i][@"contact"][@"policeForce"] atIndex:i];
        [phoneNumbers insertObject:values[i][@"contact"][@"phoneNumber"] atIndex:i];
    }
    
    NSLog(@"eh");
    
    [cardTableView reloadData];
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
            
            [cell addSubview:[self drawLabel:@"no current crimes require review" numberOfLines:1 textSize:32.0 position:CGRectMake(0, 0, self.view.bounds.size.width - 16, 100) align:NSTextAlignmentCenter backgroundColor:[UIColor whiteColor]]];
            
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
            
            [cell addSubview:[self drawLabel:[titles objectAtIndex:((indexPath.row - 1) / 2)] numberOfLines:1 textSize:32.0 position:CGRectMake(0, 300, self.view.bounds.size.width - 16, 44) align:NSTextAlignmentLeft backgroundColor:[UIColor whiteColor]]];
            
            [cell addSubview:[self drawLabel:[locations objectAtIndex:((indexPath.row - 1) / 2)] numberOfLines:1 textSize:20.0 position:CGRectMake(0, 300, self.view.bounds.size.width - 16, 44) align:NSTextAlignmentRight backgroundColor:[UIColor clearColor]]];
            
            [cell addSubview:[self drawLabel:[descriptions objectAtIndex:((indexPath.row - 1) / 2)] numberOfLines:3 textSize:26.0 position:CGRectMake(0, 344, self.view.bounds.size.width - 16, 100) align:NSTextAlignmentLeft backgroundColor:[UIColor whiteColor]]];
            
            [cell.report addTarget:self action:@selector(reportWithPosition) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.close addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
            
            cell.close.hidden = NO;
            cell.report.hidden = NO;
            
        } else {
            UIImageView *testImage =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
            testImage.image = [UIImage imageNamed:@"testImage.png"];
            [cell.MapViewCircle addSubview:testImage];
            
            cell.MapViewCircle.clipsToBounds = YES;
            [self setRoundedView:cell.MapViewCircle toDiameter:150.0];
            
            cell.close.hidden = YES;
            cell.report.hidden = YES;
        }
        
        cell.title.text = [titles objectAtIndex:((indexPath.row - 1) / 2)];
        cell.description.text = [descriptions objectAtIndex:((indexPath.row - 1) / 2)];
        cell.location.text = [locations objectAtIndex:((indexPath.row - 1) / 2)];
        
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
            return 200;
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

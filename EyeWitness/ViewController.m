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
    
    [self retrieveData];
    
    UIView *myBox  = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 60)];
    myBox.backgroundColor = [UIColor colorWithRed:((float)66 / 255.0f) green:((float)133 / 255.0f) blue:((float)244 / 255.0f) alpha:1.0f];
    [self.view addSubview:myBox];
    
    UIView *myBox2  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    myBox2.backgroundColor = [UIColor colorWithRed:((float)51 / 255.0f) green:((float)103 / 255.0f) blue:((float)214 / 255.0f) alpha:1.0f];
    [self.view addSubview:myBox2];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)retrieveData {
    //Load Data From phone storage and call the APICall fnction with this data
    
    [self APICall];
}

- (void)APICall {
    //API Call
    
    //Parse API Data
    
    titles = @[@"Murder", @"Theft", @"Collision", @"Stabbing"];
    descriptions = @[@"man killed by train", @"corner shop robbed", @"fatal car crash", @"violent stabbing"];
    locations = @[@"Cemetry Junction", @"Microsoft Campus", @"TVP", @"Reading Station"];
    cellBackgroundColours = @[@1, @0, @1, @1];
    
    [cardTableView reloadData];
}

#pragma mark - tableview datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ([titles count] * 2) - 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row % 2) {
        static NSString *cellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        [cell setBackgroundColor:[UIColor colorWithRed:((float)229 / 255.0f) green:((float)229 / 255.0f) blue:((float)229 / 255.0f) alpha:1.0f]];
        
        return cell;
    } else {
        static NSString *cellIndentifier = @"CardTableViewCell";
        
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
            UIView *MapViewRectangle  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (self.view.bounds.size.width - 10), 200)];
            [cell addSubview:MapViewRectangle];
            
            GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
                                                                    longitude:151.2086
                                                                         zoom:18];
            GMSMapView *mapView = [GMSMapView mapWithFrame:MapViewRectangle.bounds camera:camera];
            mapView.userInteractionEnabled = YES;
            
            
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.position = camera.target;
            marker.appearAnimation = kGMSMarkerAnimationPop;
            marker.map = mapView;
            
            [MapViewRectangle addSubview:mapView];
            
            //cell.title.frame = CGRectMake(0, 300, cell.bounds.size.width, 40);
            //cell.location.frame = CGRectMake(0, 264, cell.bounds.size.width, 24);
            //cell.description.frame = CGRectMake(0, 400, cell.bounds.size.width, 136);
            
            cell.title.hidden = YES;
            cell.description.hidden = YES;
            cell.location.hidden = YES;
            
            UILabel *headingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, cell.bounds.size.width, 44)];
            
            [cell addSubview:headingLabel];
            
            headingLabel.text = [titles objectAtIndex:(indexPath.row / 2)];
            headingLabel.textColor = [UIColor blackColor];
            headingLabel.adjustsFontSizeToFitWidth = NO;
            headingLabel.backgroundColor = [UIColor whiteColor];
            headingLabel.textAlignment = NSTextAlignmentCenter;
            headingLabel.font = [UIFont fontWithName:@"Roboto-Light" size:32.0];
            headingLabel.hidden = NO;
            headingLabel.numberOfLines = 1;
            
            cell.share.hidden = NO;
            
        } else {
            /*GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
                                                                    longitude:151.2086
                                                                         zoom:15];
            GMSMapView *mapView = [GMSMapView mapWithFrame:cell.MapViewCircle.bounds camera:camera];
            mapView.userInteractionEnabled = NO;
            
            
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.position = camera.target;
            marker.appearAnimation = kGMSMarkerAnimationPop;
            marker.map = mapView;
            
            [cell.MapViewCircle addSubview:mapView];*/
            
            UIImageView *testImage =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0,20,20)];
            testImage.image = [UIImage imageNamed:@"testImage.png"];
            [cell addSubview:testImage];
            
            cell.MapViewCircle.clipsToBounds = YES;
            [self setRoundedView:cell.MapViewCircle toDiameter:150.0];
            
            cell.share.hidden = YES;
        }
        
        cell.title.text = [titles objectAtIndex:(indexPath.row / 2)];
        cell.description.text = [descriptions objectAtIndex:(indexPath.row / 2)];
        cell.location.text = [locations objectAtIndex:(indexPath.row / 2)];
        
        cell.layer.masksToBounds = YES;
        cell.layer.cornerRadius = 15;
        
        cell.clipsToBounds = YES;
        
        return cell;
        
    }
}

- (void)report {
    
}

- (void)share {
    
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
        return 5;
    } else {
        if (selectedIndex == indexPath.row) {
            NSLog(@"%f", (self.view.bounds.size.height - 80));
            return (self.view.bounds.size.height - 90);
        } else {
            return 240;
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2) {
        
    } else {
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
            return;
        }
        
        selectedIndex = (int)indexPath.row;
        [UIView setAnimationDuration:0.2];
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
        [UIView setAnimationDuration:0];
    }
}

@end

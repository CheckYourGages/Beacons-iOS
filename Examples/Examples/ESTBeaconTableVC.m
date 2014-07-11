//
//  ESTBeaconTableVC.m
//  DistanceDemo
//
//  Created by Grzegorz Krukiewicz-Gacek on 17.03.2014.
//  Copyright (c) 2014 Estimote. All rights reserved.
//

#import "ESTBeaconTableVC.h"
#import "ESTBeaconManager.h"
#import "ESTViewController.h"
#import "AFNetworking.h"

@interface ESTBeaconTableVC () <ESTBeaconManagerDelegate>

@property (nonatomic, copy)     void (^completion)(ESTBeacon *);
@property (nonatomic, assign)   ESTScanType scanType;

@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) ESTBeaconRegion *region;
@property (nonatomic, strong) NSArray *beaconsArray;
@property (nonatomic, strong) NSArray *responseObject;
@property (nonatomic, strong) NSString *matcher;
@property (nonatomic, strong) NSString *image;




@end

@interface ESTTableViewCell : UITableViewCell

@end
@implementation ESTTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
    }
    return self;
}
@end

@implementation ESTBeaconTableVC

- (id)initWithScanType:(ESTScanType)scanType completion:(void (^)(ESTBeacon *))completion
{
    self = [super init];
    if (self)
    {
        self.scanType = scanType;
        self.completion = [completion copy];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*
     * Fill the table with beacon data.
     */
    
    //NSMutableArray *persons = [[NSMutableArray alloc] init];
    
    //NSDictionary *json = NSDictionary
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"http://dance-beacons.integrationrequired.com:3000/beacons.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        self.responseObject = responseObject;
        
        //NSLog(@"JSON: %@", responseObject[0][@"name"]);
        
      
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    self.title = @"Select beacon";
    
    [self.tableView registerClass:[ESTTableViewCell class] forCellReuseIdentifier:@"CellIdentifier"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    
    /* 
     * Creates sample region object (you can additionaly pass major / minor values).
     *
     * We specify it using only the ESTIMOTE_PROXIMITY_UUID because we want to discover all
     * hardware beacons with Estimote's proximty UUID.
     */
    self.region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                      identifier:@"EstimoteSampleRegion"];
    
    NSLog(@"View Did Appear: %@", self.responseObject[0][@"name"]);

    
    /*
     * Starts looking for Estimote beacons.
     * All callbacks will be delivered to beaconManager delegate.
     */
    if (self.scanType == ESTScanTypeBeacon)
    {
        [self.beaconManager startRangingBeaconsInRegion:self.region];
    }
    else
    {
        [self.beaconManager startEstimoteBeaconsDiscoveryForRegion:self.region];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    /*
     *Stops ranging after exiting the view.
     */
    [self.beaconManager stopRangingBeaconsInRegion:self.region];
    [self.beaconManager stopEstimoteBeaconDiscovery];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ESTBeaconManager delegate

- (void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
{
    self.beaconsArray = beacons;
    
    [self.tableView reloadData];
}

- (void)beaconManager:(ESTBeaconManager *)manager didDiscoverBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
{
    self.beaconsArray = beacons;
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.beaconsArray count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ESTTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    
   

    
    
    
    ESTBeacon *beacon = [self.beaconsArray objectAtIndex:indexPath.row];
    
    if (self.scanType == ESTScanTypeBeacon)
    {
      //if([persons[@"major"].String isEqualToString:NSString stringWithFormat:@"%@", beacon.major]){
        
        //cell.textLabel.text = [NSString stringWithFormat:@"%@", persons[@"name"];
      //}
      //else {
        //NSLog(@"TableView: %@", self.responseObject[0][@"name"]);
        
   
        
        for(NSDictionary *item in self.responseObject) {
            
            //NSLog(@"Item: %@", item);
            //NSLog(@"%@",[item objectForKey:@"id"]);
            //NSLog(@"%@",[item objectForKey:@"name"]);
            
            //if ( [item objectForKey:@"major"] == [NSString stringWithFormat:@"%@", beacon.major] ) {
            
                if ([[item objectForKey:@"major"] isEqualToString:[NSString stringWithFormat:@"%@", beacon.major]] ) {
                 NSLog(@"%@",[item objectForKey:@"major"]);
                 NSLog(@"%@", [NSString stringWithFormat:@"%@", beacon.major]);
                 
                self.matcher = [item objectForKey:@"name"];
                
                for(NSDictionary *url in [item objectForKey:@"image"]) {
                    
                    self.image = [url objectForKey:@"url"];
                }
            
                
        }
        
        
        
                    cell.textLabel.text = [NSString stringWithFormat:@"Name: %@", self.matcher];
                    
        
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"Distance: %.2f", [beacon.distance floatValue]];
            
                    //cell.textLabel.text = [NSString stringWithFormat:@"MacAddress: %@", beacon.macAddress];
                    //cell.detailTextLabel.text = [NSString stringWithFormat:@"RSSI: %d", beacon.rssi];
        
           NSString *host = @"http://dance-beacons.integrationrequired.com:3000/";
           host = [host stringByAppendingString:self.image];
        
        
        // NSString MyURL = [host ]self.image
        
            cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:host]]];
        //self.matcher = @"";
        
        }
            //}
    }
    
  self.matcher = @"";
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 80;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ESTBeacon *selectedBeacon = [self.beaconsArray objectAtIndex:indexPath.row];
    
    self.completion(selectedBeacon);
}

@end

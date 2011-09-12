//
//  GasolinerasController.m
//  litrosdealitro
//
//  Created by Erick Camacho Chavarría on 09/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GasolinerasController.h"

#import "JSON.h"
#import "Constants.h"
#import "GasolineraController.h"
#import <QuartzCore/QuartzCore.h>

@interface  GasolinerasController ()

- (void)loadGasolineras;
- (void)loadGasolinerasStub;
- (void)updateGasolineras:(NSString *)jsonGasolineras;

@end

@implementation GasolinerasController

@synthesize estado;
@synthesize request;
@synthesize municipio;
@synthesize gasolineras;

- (id)initWithMunicipio:(NSInteger)theMunicipio andEstado:(NSInteger)theEstado
{
  self = [super initWithStyle:UITableViewStyleGrouped];
  if (self) {
    self.title = @"Gasolineras";
    self.municipio = theMunicipio;
    self.estado    = theEstado;
  }
  return self;
}

- (void)dealloc
{
    [gasolineras release];
    [super dealloc];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  
}

- (void)viewDidAppear:(BOOL)animated
{
  [self loadGasolineras];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark private methods

- (void)loadGasolineras
{
  NSString *urlRequest = [NSString stringWithFormat:MUNICIPIO_STATIONS_SERVICE_URL, 
                          [NSNumber numberWithInteger:self.estado],
                          [NSNumber numberWithInteger:self.municipio]];
  NSLog(@"urlRequest %@", urlRequest);
  request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlRequest]];
  [request setDelegate:self];
  [request startAsynchronous]; 
}

- (void)loadGasolinerasStub
{

  NSString *filePath = [[NSBundle mainBundle] pathForResource:@"stations" ofType:@"json"];
  
  [self updateGasolineras:[NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:nil]];

}

- (void)updateGasolineras:(NSString *)jsonGasolineras
{
  self.gasolineras = [jsonGasolineras JSONValue];
  [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    return [self.gasolineras count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
    
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {

    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
  }
    
  NSDictionary *gasolinera = [self.gasolineras objectAtIndex:indexPath.row];
  cell.textLabel.text =  [NSString stringWithFormat:@"Estación %@", [gasolinera objectForKey:@"id"]];
  cell.detailTextLabel.text = [gasolinera objectForKey:@"direccion"];
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
  NSNumber *semaforo = [gasolinera objectForKey:@"semaforo"];
  switch ([semaforo intValue]) {
    case 1:
      cell.imageView.image = [UIImage imageNamed:@"green_light.png"];

      break;
    case 2:
      cell.imageView.image = [UIImage imageNamed:@"orange_light.png"];

      break;
    case 3:
      cell.imageView.image = [UIImage imageNamed:@"red_light.png"];
      break;  
    default:
      cell.imageView.image = [UIImage imageNamed:@"no_light.png"];     
      break;
  }
  cell.imageView.layer.masksToBounds = YES;
  cell.imageView.layer.cornerRadius  = 5.0;
  
  return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSDictionary *station = [self.gasolineras objectAtIndex:indexPath.row];
     
    
  GasolineraController *detailViewController = [[GasolineraController alloc] initWithGasStation:@"E00333"];
  
  [self.navigationController pushViewController:detailViewController animated:YES];
  [detailViewController release];
     
}

#pragma mark - ASIHTTPRequest Delegate Methods

- (void)requestFinished:(ASIHTTPRequest *)theRequest
{
  
  [self updateGasolineras:[theRequest responseString]];
  
}

- (void)requestFailed:(ASIHTTPRequest *)theRequest
{
  NSError *error = [theRequest error];
  NSLog(@"Error %@", error);
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                  message:@"Error conectándose al servidor" 
                                                 delegate:nil 
                                        cancelButtonTitle:@"OK" 
                                        otherButtonTitles:nil];
  [alert show];
  [alert release];
}


@end

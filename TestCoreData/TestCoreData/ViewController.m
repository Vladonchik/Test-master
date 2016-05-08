//
//  ViewController.m
//  Test
//
//  Created by Vlad Vyshnevskyy on 06/05/2016.
//  Copyright © 2016 VV-SD. All rights reserved.
//

#import "ViewController.h"
#import "TableViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *firstIcon;

@property (strong, nonatomic) NSDictionary* credentialsDictionary;
@property (strong, nonatomic) UITapGestureRecognizer *tapOutsideTextField;

@property (assign, nonatomic) BOOL userAuthenticated;

@end

@implementation ViewController

- (void)viewDidLoad
{
	_userAuthenticated = NO;
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self setUpView];
}

- (void)viewWillAppear:(BOOL)animated
{
	[self.navigationController setNavigationBarHidden:YES animated:animated];
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self.navigationController setNavigationBarHidden:NO animated:animated];
	[super viewWillDisappear:animated];
}


-(void) setUpView
{
	[self.firstIcon setImage:[UIImage imageNamed:@"basket"]];
	[self.view addGestureRecognizer:self.tapOutsideTextField];
}

-(void)dismissKeyboard
{
	[usernameTextField resignFirstResponder];
	[passwordTextField resignFirstResponder];
}

-(UITapGestureRecognizer*) tapOutsideTextField
{
	if (!_tapOutsideTextField)
	{
		_tapOutsideTextField = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
	}
	return _tapOutsideTextField;
}

- (IBAction)loginAction:(id)sender
{
	if ([[self.credentialsDictionary objectForKey:usernameTextField.text] isEqualToString:passwordTextField.text])
	{
//		UITableViewController* tableViewController = [[TableViewController alloc] init];
//		[self presentViewController:tableViewController animated:YES completion:nil];
		self.userAuthenticated = YES;
		NSLog(@"logged in");
	}
	else
	{
		self.userAuthenticated = NO;
		[self presentAlertViewOnWrongLoginCredentials];
		NSLog(@"not logged in");
	}
}

-(void) presentAlertViewOnWrongLoginCredentials
{
	UIAlertController * alert=   [UIAlertController
								  alertControllerWithTitle:@"Cannot Log In"
								  message:@"Username: iostallium@gmail.com and Password: ios123"
								  preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction* ok = [UIAlertAction
						 actionWithTitle:@"Try Again"
						 style:UIAlertActionStyleDefault
						 handler:^(UIAlertAction * action)
						 {
							 //Handel your yes please button action here
							 
							 
						 }];
	
	
	[alert addAction:ok];
	[self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
	if (self.userAuthenticated)
	{
		return YES;
	}
	return NO;
}

-(NSDictionary*) credentialsDictionary
{
	if (!_credentialsDictionary)
 	{
		_credentialsDictionary = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@"ios123", nil]
															  forKeys:[NSArray arrayWithObjects:@"iostallium@gmail.com", nil]];
		
	}
	return _credentialsDictionary;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end

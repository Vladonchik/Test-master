//
//  CustomTableViewCell.h
//  TestCoreData
//
//  Created by Vlad Vyshnevskyy on 07/05/2016.
//  Copyright © 2016 VV-SD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *duplicateRow;
@property (weak, nonatomic) IBOutlet UIButton *deleteRow;

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UILabel *footerLabel;

@property (weak, nonatomic) IBOutlet UIImageView *myImage;

@property (strong, nonatomic) NSIndexPath* indexPath;

@end

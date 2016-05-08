//
//  Cell+CoreDataProperties.h
//  TestCoreData
//
//  Created by Vlad Vyshnevskyy on 07/05/2016.
//  Copyright © 2016 VV-SD. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Cell.h"

NS_ASSUME_NONNULL_BEGIN

@interface Cell (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *image;
@property (nullable, nonatomic, retain) NSString *header;
@property (nullable, nonatomic, retain) NSString *footer;

@end

NS_ASSUME_NONNULL_END

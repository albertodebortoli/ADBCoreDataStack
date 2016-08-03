//
//  Skiathos.m
//  ADBCoreDataStack
//
//  Created by Alberto DeBortoli on 28/07/2016.
//  Copyright © 2016 Alberto De Bortoli. All rights reserved.
//

#import "Skiathos.h"
#import "ADBCoreDataStack.h"
#import "ADBDALService.h"

@implementation Skiathos

+ (instancetype)setupSqliteStackWithDataModelFileName:(NSString *)dataModelFileName
{
    ADBCoreDataStack *cds = [[ADBCoreDataStack alloc] initWithStoreType:ADBStoreTypeSQLite dataModelFileName:dataModelFileName];
    return [[self alloc] initWithCoreDataStack:cds];
}

+ (instancetype)setupInMemoryStackWithDataModelFileName:(NSString *)dataModelFileName
{
    ADBCoreDataStack *cds = [[ADBCoreDataStack alloc] initWithStoreType:ADBStoreTypeInMemory dataModelFileName:dataModelFileName];
    return [[self alloc] initWithCoreDataStack:cds];
}

@end

//
//  ViewController.h
//  DZ 22 - Obj_Skut_Touch
//
//  Created by mac on 11.11.17.
//  Copyright © 2017 Dima Zgera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView * cellsLayer;

@property (weak, nonatomic) IBOutlet UIView *checkersLayer;

@property (weak, nonatomic) IBOutlet UIView *mainView;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *cells;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *blackCells;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *checkers;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *whiteCheckers;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *blackCheckers;


@end


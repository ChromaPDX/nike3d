//
//  DevMenu.m
//  nike3dField
//
//  Created by Chroma Developer on 3/25/14.
//
//

#include "ofApp.h"
#import "DevMenu.h"
#import "ofxNodeKitten.h"
#import "MiniGameScene.h"
#import "GameScene.h"

@implementation DevMenu 

-(instancetype)initWithSize:(CGSize)size {

    self = [super initWithSize:size];
    
    if (self){
    
    NKScrollNode *table = [[NKScrollNode alloc] initWithColor:nil size:size];
    [self addChild:table];
    
    NKScrollNode *leif = [[NKScrollNode alloc] initWithParent:table autoSizePct:.33];
    [table addChild:leif];
    leif.normalColor = [UIColor colorWithRed:1. green:.5 blue:.5 alpha:1.0];
    leif.name = @"LEIF";
    leif.delegate = self;
        
    NKLabelNode* llabel = [[NKLabelNode alloc] initWithSize:leif.size FontNamed:@"Helvetica"];
    llabel.text = @"LEIF - FIELD";
    [leif addChild:llabel];
    [llabel setZPosition:2];
        
    NKScrollNode *robby = [[NKScrollNode alloc] initWithParent:table autoSizePct:.33];
    [table addChild:robby];
    robby.normalColor = [UIColor colorWithRed:.5 green:1. blue:.5 alpha:1.0];
    robby.name = @"ROBBY";
    robby.delegate = self;
        
    NKLabelNode* rlabel = [[NKLabelNode alloc] initWithSize:leif.size FontNamed:@"Helvetica"];
    rlabel.text = @"ROBBY - MINIGAMES";
    [robby addChild:rlabel];
    [rlabel setZPosition:2];
        
    NKScrollNode *eric = [[NKScrollNode alloc] initWithParent:table autoSizePct:.33];
    [table addChild:eric];
    eric.normalColor = [UIColor colorWithRed:.5 green:.5 blue:1. alpha:1.0];
    eric.name = @"ERIC";
    eric.delegate = self;
        
    NKLabelNode* elabel = [[NKLabelNode alloc] initWithSize:leif.size FontNamed:@"Helvetica"];
    elabel.text = @"ERIC - MAIN MENU";
    [elabel setZPosition:2];
    [eric addChild:elabel];
    
    }
    
    return self;
}

-(void)cellWasSelected:(NKScrollNode *)cell {
    NSLog(@"%@ was selected", cell.name);
    
    if ([cell.name isEqualToString:@"ROBBY"]) {
        MiniGameScene* newScene = [[MiniGameScene alloc]initWithSize:self.size];
        ((ofApp*)ofGetAppPtr())->scene = newScene;
        
    }
    else if ([cell.name isEqualToString:@"LEIF"]) {
        GameScene* newScene = [[GameScene alloc]initWithSize:self.size];
        ((ofApp*)ofGetAppPtr())->scene = newScene;
        
    }
}

-(void)cellWasDeSelected:(NKScrollNode *)cell {
    NSLog(@"%@ was deselected", cell.name);
}

@end
//
//  Menu.h
//  nike3dField
//
//  Created by Chroma Developer on 3/25/14.
//
//

#import "NKSceneNode.h"
#import "NKScrollNode.h"

@class MenuNode;

@interface MenuScene : NKSceneNode <NKTableCellDelegate>

@property (nonatomic, strong) MenuNode* MenuNode;

@end

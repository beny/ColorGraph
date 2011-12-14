//
//  OBEvolution.h
//  ColorGraph
//
//  Created by Ondra Beneš on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
	NSUInteger nodeA;
	NSUInteger nodeB;
} tEdge;

typedef struct {
	BOOL *neighbourgs;
}tNode;

typedef struct {
	tNode *nodes;
	tEdge *edges;
} tGraph;

typedef NSUInteger tColor;
typedef tColor *tChromosome;


@interface OBEvolution : NSObject {	
}

@property (nonatomic, retain) NSProgressIndicator *progressIndicator;
@property (assign) NSInteger populationSize;
@property (assign) NSInteger generations;
@property (assign) NSInteger bestIndividuals;

@property (assign) NSTextField *bestFitness;
- (void)runEvolution;
@end

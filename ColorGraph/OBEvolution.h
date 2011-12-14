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

@class Twister;

@interface OBEvolution : NSObject 

@property (nonatomic, retain) NSProgressIndicator *progressIndicator;
@property (assign) NSInteger populationSize;
@property (assign) NSInteger generations;
@property (assign) NSInteger bestIndividuals;
@property (assign) NSTextField *bestFitness;
@property (nonatomic, retain) Twister *generator;

- (void)runEvolution;

// genetic operators
- (void)crossover1ParentA:(tChromosome *)parentA parentB:(tChromosome *)parentB child:(tChromosome *)child;
- (void)crossover2ParentA:(tChromosome *)parentA parentB:(tChromosome *)parentB child:(tChromosome *)child;
- (NSUInteger)fitness:(tChromosome *)chromosome;

@end

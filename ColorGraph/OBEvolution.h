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

@class Twister, OBAppDelegate;

@interface OBEvolution : NSObject 

@property (nonatomic, retain) NSProgressIndicator *progressIndicator;
@property (assign) NSInteger populationSize;
@property (assign) NSInteger generations;
@property (assign) NSInteger bestIndividualsCount;

@property (assign) NSTextField *bestFitness;
@property (assign) NSTextField *progressLabel;
@property (nonatomic, retain) Twister *generator;
@property (nonatomic, retain) OBAppDelegate *delegate;

- (void)readFile;
- (void)runEvolution;
- (void)testEvolution;

// genetic operators
- (void)crossover1ParentA:(tChromosome *)parentA parentB:(tChromosome *)parentB child:(tChromosome *)child;
- (void)crossover2ParentA:(tChromosome *)parentA parentB:(tChromosome *)parentB child:(tChromosome *)child;
- (void)mutateSwitch:(tChromosome *)chromosome withProbability:(float)probability;
- (void)mutateGene:(tChromosome *)chromosome withProbability:(float)probability;

// chromosome help methods
- (NSUInteger)numberOfColorsInChromosome:(tChromosome *)chromosome;
- (NSInteger)fitness:(tChromosome *)chromosome;
- (void)printChromosome:(tChromosome *)chromosome;
- (NSString *)chromosomeString:(tChromosome *)chromosome;

@end

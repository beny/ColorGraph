//
//  OBEvolution.m
//  ColorGraph
//
//  Created by Ondra Beneš on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OBEvolution.h"

#import "OBAppDelegate.h"
#import "Twister.h"

//#define FILE @"DSJC5.5.col"
#define FILE @"DSJC125.5.col"

@implementation OBEvolution {
@private
	__block tGraph graph;
	__block unsigned edgesCount, nodesCount;
	
}

@synthesize progressIndicator;
@synthesize populationSize, generations, bestIndividualsCount;
@synthesize bestFitness, generator, progressLabel;
@synthesize delegate;

- (id)init {
	if (self = [super init]) {
		self.generator = [[Twister alloc] init];
	}
	
	return self;
}

- (void)readFile {
	NSError *error = nil;
	NSString *stringData = [NSString stringWithContentsOfFile:FILE encoding:NSASCIIStringEncoding error:&error];
	
	// get graph from file
	[stringData enumerateLinesUsingBlock:^(NSString *line, BOOL *stop){
		
		NSArray *parts = [line componentsSeparatedByString:@" "];
		
		unsigned lastAdded = 0;
		// for check expoted graph correction
		NSString *firstPart = [parts objectAtIndex:0];
		if ([firstPart isEqualToString:@"p"]) {
			nodesCount = [[parts objectAtIndex:2] intValue];
			edgesCount = [[parts objectAtIndex:3] intValue];
			
			// alloc graph
			graph.edges = (tEdge *)malloc(sizeof(tEdge) * edgesCount);
			graph.nodes = (tNode *)malloc(sizeof(tNode) * nodesCount);
			
			// alloc each node with max size and init
			for (unsigned i = 0 ; i<nodesCount; i++) {
				graph.nodes[i].neighbourgs = (BOOL *)malloc(sizeof(BOOL) * nodesCount);
				
				for (unsigned k = 0; k<nodesCount; k++) {
					graph.nodes[i].neighbourgs[k] = NO;
				}
			}
		}
		
		// add edge to array
		if ([firstPart isEqualToString:@"e"]) {
			NSUInteger nodeA = [[parts objectAtIndex:1] intValue]-1;
			NSUInteger nodeB = [[parts objectAtIndex:2] intValue]-1;
			
			// add edge
			graph.edges[lastAdded].nodeA = nodeA;
			graph.edges[lastAdded].nodeB = nodeB;
			
			// add neighbourgs to nodes
			graph.nodes[nodeA].neighbourgs[nodeB] = YES;
			graph.nodes[nodeB].neighbourgs[nodeA] = YES;
			
			lastAdded++;				
		}
	}];
}

- (void)runEvolution {
	
	[self.progressIndicator startAnimation:self];
	self.progressIndicator.doubleValue = 0.0;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		[self readFile];
		
#ifdef DEBUG
//		NSUInteger count;
//		for (unsigned i = 0; i < nodesCount; i++) {
//			
//			count = 0;
//			for (unsigned k = 0; k < nodesCount; k++) {
//				if (graph.nodes[i].neighbourgs[k]) {
//					count++;
//				}
//			}
//			
//			NSLog(@"Node %d has degree %ld", i, count);
//		}
//		
//		// alloc
//		tChromosome *chr1 = (tChromosome*)malloc(sizeof(tColor) * nodesCount);
//		tChromosome *chr2 = (tChromosome*)malloc(sizeof(tColor) * nodesCount);
//		tChromosome *chrC = (tChromosome *)malloc(sizeof(tColor) * nodesCount);
//		tChromosome *chrCC = (tChromosome *)malloc(sizeof(tChromosome) * nodesCount);
//		
//		// generate
//		for (unsigned i = 0; i<nodesCount; i++) {
//			chr1[i] = (tChromosome)[generator randomIntValueBetweenStart:0 andStop:nodesCount-1];
//			chr2[i] = (tChromosome)[generator randomIntValueBetweenStart:0 andStop:nodesCount-1];
//		}
//		
//		// print test chromosome
//		[self printChromosome:chr1];
//		[self printChromosome:chr2];
//		
//		// crossover
//		[self crossover1ParentA:chr1 parentB:chr2 child:chrC];
//		[self crossover2ParentA:chr1 parentB:chr2 child:chrCC];
//				
//		// mutate
//		
//		// fitness
//		[self fitness:chr1];
//		[self fitness:chr2];
//		[self fitness:chrC];
//		[self fitness:chrCC];
//		
//		free(chr1);
//		free(chr2);
//		free(chrC);
//		free(chrCC);
#endif
		
		NSLog(@"Evolution begins");
		
		// generate init population
		tChromosome **population = (tChromosome **)malloc(sizeof(tChromosome*) * self.populationSize);
		tChromosome **newPopulation = (tChromosome **)malloc(sizeof(tChromosome *) * self.populationSize);
		
		for (unsigned i = 0; i<populationSize; i++) {
			tChromosome *chr = (tChromosome*)malloc(sizeof(tColor) * nodesCount);
			for (unsigned i = 0; i<nodesCount; i++) {
				chr[i] = (tChromosome)[generator randomIntValueBetweenStart:0 andStop:nodesCount-1];
			}
			
			population[i] = chr;
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			// set progress state
			self.progressIndicator.maxValue = self.generations;
		});
		
		for (unsigned g = 0; g<self.generations; g++) {
			
			NSLog(@"New generation started");
			
			dispatch_async(dispatch_get_main_queue(), ^{
				// set progress state
				[self.progressIndicator incrementBy:1];
				[self.progressLabel setStringValue:[NSString stringWithFormat:@"%d%%", (int)ceilf(100 * ((float)g/(float)self.generations))]];
			});
			
			NSLog(@"Population before sort");
			
//			for (unsigned i = 0; i<populationSize; i++) {
//				NSLog(@"Chromosome %@ and fitness %ld", [self chromosomeString:population[i]], [self fitness:population[i]]);
//			}
			
			// sort individual based on fitness (bubble sort)
			for (unsigned i = 0; i<populationSize; i++) {
				
				for (unsigned k = 0; k<populationSize; k++) {
					if ([self fitness:population[i]] > [self fitness:population[k]]) {
						tChromosome *tmp;
						tmp = population[i];
						
						population[i] = population[k];
						population[k] = tmp;
					}
				}
			}
			
//			for (unsigned i = 0; i<populationSize; i++) {
//				NSLog(@"Chromosome %@ and fitness %ld", [self chromosomeString:population[i]], [self fitness:population[i]]);
//			}
			
			tChromosome *bestOne;
			bestOne = population[0];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				// set progress state
				[self.bestFitness setStringValue:[NSString stringWithFormat:@"%ld", [self numberOfColorsInChromosome:bestOne]]];
			});
			
			NSLog(@"Creating new generation");
			
			// create a new population with crossover
			for (unsigned i = 0; i<populationSize; i++) {
				unsigned rand1 = [generator randomIntValueBetweenStart:0 andStop:(int)self.bestIndividualsCount-1];
				unsigned rand2 = [generator randomIntValueBetweenStart:0 andStop:(int)self.bestIndividualsCount-1];
				
				tChromosome *chr = (tChromosome*)malloc(sizeof(tColor) * nodesCount);
				[self crossover1ParentA:population[rand1] parentB:population[rand2] child:chr];
				
				newPopulation[i] = chr;
				
				// try to mutate
				[self mutate:chr withProbability:0.1];
			}
			
			NSLog(@"Saving new generatiron");
			for (unsigned i = 0; i<populationSize; i++) {
				population[i] = newPopulation[i];
			}
			
//			free(newPopulation);
			
		}
		free(newPopulation);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.progressIndicator stopAnimation:self];
			[self.delegate showResultForFitness:[self numberOfColorsInChromosome:population[0]]];
		});
		
	});
}

#pragma mark - Genetic Operators
- (void)crossover1ParentA:(tChromosome *)parentA parentB:(tChromosome *)parentB child:(tChromosome *)child {
	
	
	NSMutableString *repC = [NSMutableString stringWithCapacity:nodesCount];
	unsigned crossoverPoint = [generator randomIntValueBetweenStart:1 andStop:nodesCount-2];
	for (unsigned i = 0; i < nodesCount; i++) {
		child[i] = (i < crossoverPoint)?parentA[i]:parentB[i];
		[repC appendString:[NSString stringWithFormat:@"%ld ", child[i]]];
	}
	
//	NSLog(@"== Crossover 1 ==");
//	NSLog(@"\tCrossover point = %d", crossoverPoint);
//	NSLog(@"\tChild = %@", repC);
}

- (void)crossover2ParentA:(tChromosome *)parentA parentB:(tChromosome *)parentB child:(tChromosome *)child {
	NSMutableString *repCC = [NSMutableString stringWithCapacity:nodesCount];
	unsigned crossoverPoint1 = [generator randomIntValueBetweenStart:1 andStop:nodesCount-3];
	unsigned crossoverPoint2;
	while (crossoverPoint1 >= (crossoverPoint2 = [generator randomIntValueBetweenStart:1 andStop:nodesCount-2]));
	for (unsigned i = 0; i < nodesCount; i++) {
		
		child[i] = (i < crossoverPoint1 || i > crossoverPoint2)?parentA[i]:parentB[i];
		[repCC appendString:[NSString stringWithFormat:@"%ld ", child[i]]];
	}
	
//	NSLog(@"== Crossover 2 ==");
//	NSLog(@"\tCrossover points = %d %d", crossoverPoint1, crossoverPoint2);
//	NSLog(@"\tchrCC = %@", repCC);
}

- (void)mutate:(tChromosome *)chromosome withProbability:(float)probability {
	
	float rand = [generator randomDoubleValueBetweenStart:0 andStop:1];

	if (rand < probability) {
		NSUInteger randPositionA = [generator randomIntValueBetweenStart:0 andStop:nodesCount-1];
		NSUInteger randPositionB = [generator randomIntValueBetweenStart:0 andStop:nodesCount-1];
		
		// switch two genes
		tColor *temp;
		temp = chromosome[randPositionA];
		chromosome[randPositionA] = chromosome[randPositionB];
		chromosome[randPositionB] = temp;
	}
}

#pragma mark - Chromosome Help Methods
- (NSInteger)fitness:(tChromosome *)chromosome {

	tColor color;
	int fitness = 0;
	for (unsigned i = 0; i<nodesCount; i++) {
		
		// chr1
		color = (tColor)chromosome[i];
		for (unsigned k = 0; k<nodesCount; k++) {
			
			// same color on existing edge
			if (graph.nodes[i].neighbourgs[k] == YES && chromosome[k] == chromosome[i]) {
//				NSLog(@"edge with same color exists from %d to %d", i, k);
				fitness--;
			}
		}
	}

	
	fitness -= [self numberOfColorsInChromosome:chromosome];
	
//	NSLog(@"== Fitness ==");
//	NSLog(@"\tChromosome has %ld colors", uniqColorCount);
//	NSLog(@"\tChromosome fitness = %d", fitness);
	
	return fitness;
}

- (NSUInteger)numberOfColorsInChromosome:(tChromosome *)chromosome {
	// uniq color
	NSUInteger uniqColorCount = 0;
	BOOL *uniqColors = (BOOL *)malloc(sizeof(BOOL) * nodesCount);
	for (unsigned k = 0; k<nodesCount; k++) uniqColors[k] = NO;
	for (unsigned k = 0; k<nodesCount; k++)	uniqColors[(int)chromosome[k]] = YES;
	for (unsigned k = 0; k<nodesCount; k++) { 
		if(uniqColors[k]) uniqColorCount++;
		//			NSLog(@"uniqColors[%d] = %d", k, uniqColors[k]);
	}
	free(uniqColors);
	return uniqColorCount;
}

- (void)printChromosome:(tChromosome *)chromosome {
	NSLog(@"Chromosome = %@",[self chromosomeString:chromosome]);
}

- (NSString *)chromosomeString:(tChromosome *)chromosome {
	NSMutableString *rep1 = [NSMutableString stringWithCapacity:nodesCount];
	for (unsigned i = 0; i<nodesCount; i++) {
		[rep1 appendString:[NSString stringWithFormat:@"%ld ", chromosome[i]]];
	}
	return rep1;
}

#pragma mark - Memory Management
- (void)dealloc {
	
	[delegate release];
	[generator release];
	[progressIndicator release];
	[super dealloc];
}

@end

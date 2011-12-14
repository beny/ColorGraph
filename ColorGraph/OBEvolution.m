//
//  OBEvolution.m
//  ColorGraph
//
//  Created by Ondra Beneš on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OBEvolution.h"

#import "Twister.h"

#define FILE @"DSJC5.5.col"

@implementation OBEvolution

@synthesize progressIndicator;
@synthesize populationSize, generations, bestIndividuals;
@synthesize bestFitness;

- (void)runEvolution {
	
	[self.progressIndicator startAnimation:self];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, nil), ^{
		
		NSError *error = nil;
		NSString *stringData = [NSString stringWithContentsOfFile:FILE encoding:NSASCIIStringEncoding error:&error];
		
		// get graph from file
		__block int edgesCount, nodesCount;
		__block tGraph graph;
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
		
#ifdef DEBUG
		NSUInteger count;
		for (unsigned i = 0; i < nodesCount; i++) {
			
			count = 0;
			for (unsigned k = 0; k < nodesCount; k++) {
				if (graph.nodes[i].neighbourgs[k]) {
					count++;
				}
			}
			
			NSLog(@"Node %d has degree %ld", i, count);
		}
		
		Twister *generator = [[[Twister alloc] init] autorelease];
		
		tChromosome *chr1 = (tChromosome*)malloc(sizeof(tColor) * nodesCount);
		tChromosome *chr2 = (tChromosome*)malloc(sizeof(tColor) * nodesCount);
		
		NSMutableString *rep1 = [NSMutableString stringWithCapacity:nodesCount];
		NSMutableString *rep2 = [NSMutableString stringWithCapacity:nodesCount];
		for (unsigned i = 0; i<nodesCount; i++) {
			chr1[i] = (tChromosome)[generator randomIntValueBetweenStart:0 andStop:nodesCount-1];
			[rep1 appendString:[NSString stringWithFormat:@"%ld ", chr1[i]]];
			chr2[i] = (tChromosome)[generator randomIntValueBetweenStart:0 andStop:nodesCount-1];
			[rep2 appendString:[NSString stringWithFormat:@"%ld ", chr2[i]]];
		}
		
		NSLog(@"chr1 = %@", rep1);
		NSLog(@"chr2 = %@", rep2);
		
		// crossover 1
		NSMutableString *repC = [NSMutableString stringWithCapacity:nodesCount];
		unsigned crossoverPoint = [generator randomIntValueBetweenStart:1 andStop:nodesCount-2];
		tChromosome *chrC = (tChromosome *)malloc(sizeof(tColor) * nodesCount);
		for (unsigned i = 0; i < nodesCount; i++) {
			chrC[i] = (i < crossoverPoint)?chr1[i]:chr2[i];
			[repC appendString:[NSString stringWithFormat:@"%ld ", chrC[i]]];
		}
		
		NSLog(@"Crossover point = %d", crossoverPoint);
		NSLog(@"chrC = %@", repC);
		
		// crossover 2
		NSMutableString *repCC = [NSMutableString stringWithCapacity:nodesCount];
		unsigned crossoverPoint1 = [generator randomIntValueBetweenStart:1 andStop:nodesCount-3];
		unsigned crossoverPoint2;
		while (crossoverPoint1 >= (crossoverPoint2 = [generator randomIntValueBetweenStart:1 andStop:nodesCount-2]));
		tChromosome *chrCC = (tChromosome *)malloc(sizeof(tChromosome) * nodesCount);
		for (unsigned i = 0; i < nodesCount; i++) {
			
			chrCC[i] = (i < crossoverPoint1 || i > crossoverPoint2)?chr1[i]:chr2[i];
			[repCC appendString:[NSString stringWithFormat:@"%ld ", chrCC[i]]];
		}
		
		NSLog(@"Crossover points = %d %d", crossoverPoint1, crossoverPoint2);
		NSLog(@"chrCC = %@", repCC);
		
		// fitness
		tColor color;
		int fitness = 0;
		for (unsigned i = 0; i<nodesCount; i++) {
			
			// chr1
			color = (tColor)chr1[i];
			for (unsigned k = 0; k<nodesCount; k++) {
				
				// same color on existing edge
				if (graph.nodes[i].neighbourgs[k] == YES && chr1[k] == chr1[i]) {
					NSLog(@"edge with same color exists from %d to %d", i, k);
					fitness--;
				}
			}
			
			
		}
		// uniq color
		NSUInteger uniqColorCount = 0;
		BOOL *uniqColors = (BOOL *)malloc(sizeof(BOOL) * nodesCount);
		for (unsigned k = 0; k<nodesCount; k++) uniqColors[k] = NO;
		for (unsigned k = 0; k<nodesCount; k++)	uniqColors[(int)chr1[k]] = YES;
		for (unsigned k = 0; k<nodesCount; k++) { 
			if(uniqColors[k]) uniqColorCount++;
//			NSLog(@"uniqColors[%d] = %d", k, uniqColors[k]);
		}
		free(uniqColors);
		
		fitness -= uniqColorCount;
		
		NSLog(@"chr1 has %ld colors", uniqColorCount);
		NSLog(@"chr1 fitness = %d", fitness);
		
		free(chr1);
		free(chr2);
		free(chrC);
		free(chrCC);
#endif
		
//		// create first population
//		NSMutableArray *population= [[NSMutableArray alloc] init];
//		for (unsigned i = 0; i < self.populationSize; i++) {
//			Chromosome *chrom = [[Chromosome alloc] initRandomForGraph:graph];
//			[population addObject:chrom];
//			[chrom release];
//		}
//		
//		// compare two chromosome based on fitness
//		NSComparator chromosomeComparator = ^NSComparisonResult(Chromosome *chr1, Chromosome *chr2) {
//			
//			if (chr1.fitness > chr2.fitness)
//				return NSOrderedAscending;
//			else if (chr1.fitness < chr2.fitness)
//				return NSOrderedDescending;
//			else
//				return NSOrderedSame;
//		};
//		
//		Twister *tw = [[[Twister alloc]init] autorelease];
//		
//		dispatch_async(dispatch_get_main_queue(), ^{
//			// set progress state
//			self.progressIndicator.maxValue = self.generations;
//		});
//		
//		// iterate through generations
//		for (unsigned i = 0; i < self.generations; i++) {
//			
//			dispatch_async(dispatch_get_main_queue(), ^{
//				// set progress state
//				[self.progressIndicator incrementBy:1];
//			});
//			
//			// sort population
//			[population sortUsingComparator:chromosomeComparator];
//			
//			Chromosome *bestIndividual = [population objectAtIndex:0];
//			dispatch_async(dispatch_get_main_queue(), ^{
//				// set progress state
//				[self.bestFitness setStringValue:[NSString stringWithFormat:@"%ld", bestIndividual.fitness]];
//			});
////			NSLog(@"%d: Best individual fitness %ld",i , bestIndividual.fitness);
//			
//			// take 10 best individual for chreating new population
//			NSRange bestIndidividualRange = NSMakeRange(0, self.bestIndividuals);
//			NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:bestIndidividualRange];
//			
//			NSArray *bestIndivids = [[NSArray alloc] init]; 
//			bestIndivids = [population objectsAtIndexes:indexSet];
//			
//			[population removeAllObjects];
//			for (unsigned k = 0; k < self.populationSize; k++) {
//				
//				// crossover two random individual
//				unsigned rand1 = [tw randomIntValueBetweenStart:0 andStop:(unsigned)bestIndivids.count-1];
//				unsigned rand2 = [tw randomIntValueBetweenStart:0 andStop:(unsigned)bestIndivids.count-1];
//				Chromosome *chrom1 = [bestIndivids objectAtIndex:rand1];
//				Chromosome *chrom2 = [bestIndivids objectAtIndex:rand2]; 
//				
//				// save new individual to the new population
//				Chromosome *newChrom = [chrom1 crossover1withChromosome:chrom2];
//				
//				// mutate
//				[newChrom mutateWithProbability:0.1];
//				[population addObject:newChrom];
//			}
//		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.progressIndicator stopAnimation:self];
		});
		
		free(graph.nodes);
		free(graph.edges);
	});
}

- (void)dealloc {
	
	[progressIndicator release];
	[super dealloc];
}

@end

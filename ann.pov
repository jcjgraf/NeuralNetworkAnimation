#include "colors.inc"
#include "finish.inc"
#include "textures.inc"
#include "rand.inc"
//#include "koSy.inc"

// Basic Scene
camera {
	location <2, 5, -3>
	look_at <2, 0, 0>
}

light_source {
	<-200, 400, -200>
	color White
}

plane {
	<0, 1, 0>, 0
	texture {
		pigment {checker Gray80 Gray95}
		finish {Phong_Shiny}
	}
}

// Helper
#macro HelperLine (pos, col)
cylinder {
	pos, pos + <15,0,0>, 0.005 
         pigment{color col}
}
#end

HelperLine(<-5, 0, -1>, Yellow)
HelperLine(<-5, 0, -0.5>, Green)
HelperLine(<-5, 0, 0>, Red)
HelperLine(<-5, 0, 0.5>, Green)
HelperLine(<-5, 0, 1>, Yellow)

// ANN
#declare Size = 3;
#declare Shape = array[Size] {2, 5, 2};

/*#declare Weights1 = array[Shape[1]][Shape[0]] {
	{-5.74501215, 12.78399623},
	{-14.86579363, 7.06784888},
	{5.94776516, -13.18882104}
};

#declare Weights2 = array[Shape[2]][Shape[1]] {
	{5.21130487, -10.74472035, -6.11404724}
};*/

#declare Weights1 = array[Shape[1]][Shape[0]];
#declare Weights2 = array[Shape[2]][Shape[1]];

// Init W1
#declare i = 0;
#while (i < Shape[0])

	#declare j = 0;
	#while (j < Shape[1])
	
		#declare Weights1[j][i] = 15 * RRand(-0.9, 0.9, RdmB);
		
		#declare j = j + 1;
	#end	

	#declare i = i + 1;
#end

// Init W2
#declare i = 0;
#while (i < Shape[1])

	#declare j = 0;
	#while (j < Shape[2])
	
		#declare Weights2[j][i] = 15 * RRand(-0.9, 0.9, RdmB);
		
		#declare j = j + 1;
	#end	

	#declare i = i + 1;
#end

#declare zNeuronDist = 1;  // Distance between two neurons on the Z-axis
#declare xNeuronDist = 2;  // Distance between two neurons on the X-axis

#declare LayerCenter = array[Size];
#declare i = 0;
#while (i < Size)
	
	#declare LayerCenter[i] = <i * xNeuronDist, 0.2, 0>;
	
	#declare i = i + 1;
#end

// Classes
#macro Neuron (position, layer)
sphere {
	position, 0.2
	texture {
		#if (layer = 0)
			pigment {color CornflowerBlue}
			
		#elseif (layer = 1)
			pigment {color DarkOliveGreen}
			
		#elseif (layer = 2)
			pigment {color DarkSlateGrey}
			
		#end
	}	
}
#end

#macro Weight (startPt, endPt, weight)
cylinder {
	startPt, endPt, 0.05 * weight / 15
	texture {
		pigment {color rgb<(weight + 1) / 2, 0, 1 - (weight + 1) / 2>}
		finish {}
	}	
}
#end

#macro Put(position, value)
sphere {
	position, 0.15
	texture {
		#if (value >= 0.5)
			pigment {color White}
		#else
			pigment {color Black}
		#end	
	}	
}
#end

// Draw Neurons
#declare i = 0;
#while (i < Size)

	#declare j = 0;
	#while (j < Shape[i])
		
		Neuron(LayerCenter [i] + <0, 0, (Shape[i] / 2 - j) * zNeuronDist - zNeuronDist / 2>, i)
		
		#declare j = j + 1;
	#end
	
	#declare i = i + 1;
#end

// Draw Weights
#declare i = 0;
#while (i < Size - 1)
	
	#declare i0 = 0;
	#while (i0 < Shape[i])
		
		#declare i1 = 0;
		#while (i1 < Shape[i + 1])
	
			#declare p1 = LayerCenter [i] + <0, 0, (Shape[i] / 2 - i0) * zNeuronDist - zNeuronDist / 2>;
			#declare p2 = LayerCenter [i + 1] + <0, 0, (Shape[i + 1] / 2 - i1) * zNeuronDist - zNeuronDist / 2>;
			
			#if (i = 0)
				Weight(p1, p2, Weights1[i1][i0])
				
			#else
				Weight(p1, p2, Weights2[i1][i0])
			
			#end
			
			#declare i1 = i1 + 1;
		#end
	
		#declare i0 = i0 + 1;
	#end

	#declare i = i + 1;
#end
/*
// Evaluate
#declare NetInput = array[2][1] {{1}, {0}};
#declare LayerInput = NetInput;

#declare HL = array[Shape[1]][Shape[0]];

#declare i = 0;
#while (i < Size -1)

	#declare LayerOutput = array[Shape[i + 1]][1];

	#declare l1 = 0;
	#while (l1 < Shape[i + 1])
	
		#declare rowSum = 0;
	
		#declare l0 = 0;
		#while (l0 < Shape[i ])
			
			#if (i = 0)
				#declare rowSum = rowSum + Weights1[l1][l0] * LayerInput[l0][0];
				
			#else
				#declare rowSum = rowSum + Weights2[l1][l0] * LayerInput[l0][0];
			
			#end
			
			#declare l0 = l0 + 1;
		#end
		
		// Apply sigmoid function
		#declare rowSum = 1 / (1 + exp(-rowSum));
		
		#declare LayerOutput[l1][0] = rowSum;
		
		#declare l1 = l1 + 1;
	#end
	
	#if (i = 0)
		#declare HL = LayerOutput;
		
	#end
	
	#declare LayerInput = LayerOutput;
	
	#declare i = i + 1;
#end

#warning concat("Out: ", str(LayerOutput[0][0], 5, 5))

// Animation

// Input
#if (clock <= 1)

	#declare i = 0;
	#while (i < Shape[0])

		#declare relPos = <clock, 0, 0>;
		#declare value = NetInput[i][0];

		Put(LayerCenter [0] + <0, 0, (Shape[0] / 2 - i) * zNeuronDist - zNeuronDist / 2> + <-1, 0, 0> + relPos, value)
	
		#declare i = i + 1;
	#end
	
// Layer 1
#elseif (clock <= 3)
	
	#declare i0 = 0;
	#while (i0 < Shape[0])
		
		#declare i1 = 0;
		#while (i1 < Shape[1])
		
			#declare value =  Weights1[i1][i0] * NetInput[i0][0];
	
			#declare p1 = LayerCenter [0] + <0, 0, (Shape[0] / 2 - i0) * zNeuronDist - zNeuronDist / 2>;
			#declare p2 = LayerCenter [1] + <0, 0, (Shape[1] / 2 - i1) * zNeuronDist - zNeuronDist / 2>;

			Put(p1 * (1 - (clock - 1) / 2) + p2 * (clock - 1) / 2, value)
			
			#declare i1 = i1 + 1;
		#end
	
		#declare i0 = i0 + 1;
	#end

// Layer 2
#elseif (clock <= 5)

	#declare i0 = 0;
	#while (i0 < Shape[1])
		
		#declare i1 = 0;
		#while (i1 < Shape[2])
		
			#declare value =  Weights2[i1][i0] * HL[i0][0];
	
			#declare p1 = LayerCenter [1] + <0, 0, (Shape[1] / 2 - i0) * zNeuronDist - zNeuronDist / 2>;
			#declare p2 = LayerCenter [2] + <0, 0, (Shape[2] / 2 - i1) * zNeuronDist - zNeuronDist / 2>;

			Put(p1 * (1 - (clock - 3) / 2)  + p2 * (clock - 3) / 2, value)
			
			#declare i1 = i1 + 1;
		#end
	
		#declare i0 = i0 + 1;
	#end

// Output
#elseif (clock <= 6)

	#declare i = 0;
	#while (i < Shape[2])

		#declare relPos = <clock - 4 * zNeuronDist, 0, 0>;
		#declare value = LayerOutput[0][0];
		
		#warning str(value, 2, 2)

		Put(LayerCenter [2] + <0, 0, (Shape[2] / 2 - i) * zNeuronDist - zNeuronDist / 2> + <-1, 0, 0> + relPos, value)
	
		#declare i = i + 1;
	#end

#end


*/













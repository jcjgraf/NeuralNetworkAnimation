#include "colors.inc"
#include "finish.inc"
#include "textures.inc"
//#include "koSy.inc"

// Basic Scene
camera {
	location <2, 5, 0>
	look_at <2, 0, 0>
}

light_source {
	<-200, 400, -200>
	color White
}

plane {
	<0, 1, 0>, 0
	texture {DMFWood4}
}

// Helper
#macro HelperLine (pos, col)
cylinder {
	pos, pos + <10,0,0>, 0.005 
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
#declare Shape = array[Size] {2, 3, 1};

#declare Weights1 = array[Shape[0]][Shape[1]] {
	{1, 2, 1},
	{1, 1, 1}	
};
#declare Weights2 = array[Shape[1]][Shape[2]] {
	{1},
	{1},
	{1}
};

// Init W1
// #declare i = 0;
// #while (i < Shape[0])

// 	#declare j = 0;
// 	#while (j < Shape[1])
	
// 		#declare Weights1[i][j] = 0;
		
// 		#declare j = j + 1;
// 	#end	

// 	#declare i = i + 1;
// #end

// Init W2
// #declare i = 0;
// #while (i < Shape[1])

// 	#declare j = 0;
// 	#while (j < Shape[2])
	
// 		#declare Weights2[i][j] = 0;
		
// 		#declare j = j + 1;
// 	#end	

// 	#declare i = i + 1;
// #end

#declare zNeuronDist = 1;  // Distance between two neurons on the Z-axis
#declare xNeuronDist = 2;  // Distance between two neurons on the X-axis

#declare LayerCenter = array[Size];
#declare i = 0;
#while (i < Size)
	
	#declare LayerCenter[i] = <i * xNeuronDist, 0, 0>;
	
	#declare i = i + 1;
#end

// Neuran Class
#macro Neuron (position)
sphere {
	position, 0.1
	texture {Chrome_Metal}	
}
#end

#macro Weight (startPt, endPt, weight)
cylinder {
	startPt, endPt, weight
	texture {
		pigment {color Red}
		finish {}
		}	
}
#end

// Draw Neurons
#declare i = 0;
#while (i < Size)

	#declare j = 0;
	#while (j < Shape[i])
		
		Neuron(LayerCenter [i] + <0, 0, (-Shape[i] / 2 + j) * zNeuronDist + zNeuronDist / 2>)
		
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
	
			#declare p1 = LayerCenter [i] + <0, 0, (-Shape[i] / 2 + i0) * zNeuronDist + zNeuronDist / 2>;
			#declare p2 = LayerCenter [i + 1] + <0, 0, (-Shape[i + 1] / 2 + i1) * zNeuronDist + zNeuronDist / 2>;
			
			#if (i = 0)
				#declare weight = Weights1[i0][i1];
				
			#else
				#declare weight = Weights2[i0][i1];
			
			#end
			
			
			
			Weight(p1, p2, weight * 0.01)
			
			
		
	
			#declare i1 = i1 + 1;
		#end
	
		#declare i0 = i0 + 1;
	#end

	#declare i = i + 1;
#end













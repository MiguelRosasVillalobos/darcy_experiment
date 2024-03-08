lc = 0.03;
//+
Point(1) = {0, 0, 0,lc};
//+
Point(2) = {1.5, 0, 0,lc};
//+
Point(3) = {1.5, .1, 0,lc};
//+
Point(4) = {0, .1, 0,lc};
//+
Line(1) = {1, 2};
//+
Line(2) = {2, 3};
//+
Line(3) = {3, 4};
//+
Line(4) = {4, 1};
//+
Curve Loop(8) = {4, 1, 2, 3};
//+
Plane Surface(2) = {8};
//+
Transfinite Surface {1};
Recombine Surface {1};

Extrude {0, 0, 0.01} {
  Surface{2}; Layers{5}; Recombine; 
}
Transfinite Volume {1};
//+
Physical Surface("inlet", 25) = {17};
//+
Physical Surface("outlet", 27) = {25};
//+
Physical Volume("interior", 28) = {1};
//+
Physical Surface("sides", 29) = {30,2};
//+
Physical Surface("Wall", 30) = {21,29};
//+
Field[1] = Box;

Field[1].VIn = 0.005;

Field[1].XMin = 0.75-0.1;

Field[1].XMax = 0.75+0.1;

Field[1].YMin = 0;

Field[1].YMax = 0.1;

Field[1].ZMin = 0;

Field[1].ZMax = 0.01;

Background Field = 1;

Mesh 3;
//+

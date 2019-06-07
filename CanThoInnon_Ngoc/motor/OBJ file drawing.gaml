/**
* Name: OBJ File to Geometry
* Author:  Arnaud Grignard
* Description: Model which shows how to use a OBJ File to draw a complex geometry. The geometry is simply used, in this case, to draw the agents.
* Tags:  load_file, 3d, skill, obj
*/
model obj_drawing

global {
	geometry c<- box(15, 10, 5);
	geometry a1<-cylinder(2, 10) rotated_by (90::{0,1,0}) translated_by({-4,-5,0});
	geometry a2<-cylinder(2, 10) rotated_by (90::{0,1,0}) translated_by({-4,5,0});
	geometry cc<-geometry([a1,c]);
	init {
		create car number: 1;
	}

}

species car skills: [moving] {

	reflex sss {
		do wander amplitude:90.0;
	}

	aspect obj { 
		draw cc color:#red;
//		draw box(15, 10, 5) color: #red rotate: heading;
//		draw box(10, 10, 10) color: #red rotate: heading;
//		draw a1 color: #red at:location rotate: heading;
//		draw a2 color: #red at:location rotate: heading;
//		draw cylinder(2, 10) color: #red at: {location.x, location.y, location.z-1} rotate: 90+heading;//::{0, 1, 0};
//		draw cylinder(2, 2) color: #red at: {location.x - 4+heading, location.y + 5+heading, location.z} rotate: heading;//::{heading, heading, 1};
	}

}

experiment Display type: gui {
	output {
		display ComplexObject type: opengl {
			species car aspect: obj;
		}

	}

}

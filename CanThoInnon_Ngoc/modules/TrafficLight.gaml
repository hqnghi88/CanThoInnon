model TrafficLight
import "Moveable.gaml"
import "GlobalVariable.gaml"
species traffic_light parent: moveable {
	geometry shape <- square(1);
	int nbred;
	int nbgreen;
	rgb color_fire;
	int counter <- 0;

	reflex change {
		if (color_fire = #red and counter > nbred) {
			counter <- 0;
			color_fire <- #green;
		}

		if (color_fire = #green and counter > nbgreen) {
			counter <- 0;
			color_fire <- #red;
		}

		counter <- counter + 1;
	}

	aspect default {
		draw box(1, 1, 12) color: #black;
		draw sphere(5) at: {location.x, location.y, 12} color: color_fire;
		if (#zoom > 6) {
			draw color_fire = #red ?""+(nbred-counter+1):""+(nbgreen-counter+1) anchor: #center font: font("Arial", 24, #bold)  color: color_fire at: {location.x, location.y, 25} perspective: false;
		}
	}

}


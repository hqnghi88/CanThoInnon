model Vehicle

import "Moveable.gaml"
import "TrafficLight.gaml"
import "GlobalVariable.gaml"
import "../modules/Water.gaml"
import "../modules/DEMCell.gaml"
species vehicle skills: [moving] parent: moveable {
	rgb color;
	string type;
	int nb_people;
	bool go_work<-true;
	string carburant <- "essence";
	float wsize <- 7.0 + rnd(1);
	float hsize <- 2.0 + rnd(2);
	float depth <- 2.0 + rnd(2);
	bool insane <- flip(0.00001) ? true : false;
	float speed <- (insane ? 20 + rnd(20) : 10 + rnd(10.0)) °m / °h;
	float csp <- speed;
	float perception_distance <- wsize * 4;
	geometry shape <- box(wsize, hsize, depth);
	geometry TL_area;
	point target <- nil;
	rgb csd <- #green;
	bool waiting_traffic_light <- false;
	int time_on_road<-0;
	float get_pollution {
	//		write  csp * coeff_vehicle[type];
		return csp * coeff_vehicle[type] * 100;
	}

	reflex move when: target != nil {
		TL_area <- (cone(heading - 15, heading + 15) intersection world.shape) intersection (circle(perception_distance));
		list<traffic_light> redlight <- (((traffic_light) at_distance perception_distance) where (each.color_fire = #red)) overlapping TL_area;
		list<vehicle> v <- (vehicle at_distance (perception_distance)) where (!(each.TL_area overlaps TL_area) and (each overlaps TL_area));
		if (length(redlight) > 0) {
			waiting_traffic_light <- true;
			return;
		}

		if (!waiting_traffic_light and length(v where (each.waiting_traffic_light)) > 0) {
			waiting_traffic_light <- true;
			return;
		}

		waiting_traffic_light <- false;
		if (length(v) > 0) {
			csd <- #darkred;
			if (csp = speed) {
				csp <- (v min_of each.csp);
			}

		} else {
			csd <- #green;
			csp <- speed;
		}

		if ((first(water).wlevel > -13.30) and length(DEMcell overlapping self) > 0) {
			if ((first(DEMcell overlapping self).subsidence < 30)) {
				csd <- #black;
				csp <-(rnd(5) °m / °h);
			} else {
				csd <- #green;
				csp <- speed;
			}

		}

		time_on_road<-time_on_road+1;
		do goto target: target on: road_graph recompute_path: recompute_path speed: csp move_weights: road_weights;
		if (target != nil and location distance_to target <= speed) {
		//		if (target = location){
			target <- nil;
			time_on_road<-0;
		}

	}

	reflex choose_target when: target = nil {
//		target <- any_location_in(road_geom);
		if(go_work){			
			go_work<-false;
			target <- any_location_in(road_geom);
		}else{
			go_work<-true;
			target <- any_location_in(any(building where(each.osm_name index_of "osm_agent" != 0)));
			
		}
	}

	aspect d3d {
		draw obj_file("../motor/Bike.obj") size: 5 rotate: -90::{1, 0, 0};
	}

	aspect default {
		draw box(wsize - 2, hsize, depth + 2) color: csd rotate: heading;
		draw shape color: csd rotate: heading;
		if (draw_perception and TL_area != nil) {
			draw TL_area color: csd empty: true depth: 0.5;
		}

	}

}

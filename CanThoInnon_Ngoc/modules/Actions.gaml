/***
* Name: Actions
* Author: hqngh
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model Actions
import "../modules/GlobalVariable.gaml"
import "../modules/Building.gaml"
import "../modules/Moveable.gaml"
global{
	
	user_command "Create a vehicle" {
		if (!edit_mode) {
			return;
		}

		create vehicle number: 1 {
			type <- TYPE_MOTORBIKE;
			location <- mouse_target;
		} }

	user_command "Create a traffic light" {
		if (!edit_mode) {
			return;
		}

		create traffic_light number: 1 with: (location: mouse_target) {
			color_fire <- flip(0.5) ? #red : #green;
			nbred <- 30 + rnd(70);
			nbgreen <- 15 + rnd(40);
		} }

	user_command "Create a building" {
		if (!edit_mode) {
			return;
		}

		map answers <- user_input("Amount", ["Amount"::1]);
		int num <- int(answers["Amount"]);
		create building number: num {
			osm_name <- "osm_agent" + self;
			shape <- any(building);
			location <- any_location_in(circle(num * 2) at_location mouse_target);
			depth <- (10 + (rnd(20)) / 150 * shape.perimeter);
			texture <- textures[rnd(9)];
		}

	}

	list<agent> get_all_instances (species<agent> spec) {
		return spec.population + spec.subspecies accumulate (get_all_instances(each));
	}

	action click {
		mouse_target <- #user_location;
		if (!edit_mode) {
			return;
		}

		if (empty(moved_agents)) {
			list<moveable> selected_agents <- list<moveable>(get_all_instances(moveable) overlapping (zone at_location #user_location));
			moved_agents <- selected_agents;
			ask selected_agents {
				difference <- #user_location - location;
				color <- #olive;
			}

		} else if (can_drop) {
			ask moved_agents {
				color <- #burlywood;
			}

			moved_agents <- list<moveable>([]);
		}

	}

	action move {
		if (!edit_mode) {
			return;
		}

		can_drop <- true;
//		mouse_target <- #user_location;
		ask moved_agents {
			location <- #user_location - difference;
		}

	} 
}


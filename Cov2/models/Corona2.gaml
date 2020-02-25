/***
* Name: Corona
* Author: hqngh
* Description: 
* Tags: Tag1, Tag2, TagN
***/
model Corona

global {
//	float seed <- 0.5362681362380473; //
	float seed <- 0.2955510396397566;
	file road_shapefile <- file("../includes/roads.shp");
	file building_shapefile <- file("../includes/buildings.shp");
	geometry shape <- envelope(building_shapefile);
	int max_exposed_period <- 30;
	list<string>
	schoolname <- ["Tieu hoc Mac Dinh Chi", "Trường THPT Châu Văn Liêm", "THPT BC Phạm Ngọc Hiển", "Trường THCS Đoàn Thị Điểm", "Ngô Quyền", "Mầm non Tây Đô", "Trung Tâm Giáo Dục Thường Xuyên"];
	graph road_network;
	bool off_school;

	init {
		create road from: road_shapefile;
		road_network <- as_edge_graph(road);
		create building from: building_shapefile {
			if (name in schoolname) {
				is_school <- true;
			}

		}

		create people number: 1000 {
			my_school <- any(building where (each.is_school));
			my_building <- any(building where (!each.is_school));
			location <- any_location_in(my_building);
			my_bound <- my_building.shape;
			//			masked <- flip(0.8) ? true : false;
		}

		ask 800 among people {
			masked <- true;
		}

		ask 1 among (people) {
			exposed <- true;
		}

	}

}

species road {

	aspect default {
		draw shape color: #black;
	}

}

species virus_container {
	bool infected <- false;
	bool exposed <- false;
}

species building parent: virus_container {
	bool is_school <- false;

	aspect default {
		draw shape color: is_school ? #blue : #gray empty: is_school ? true : false;
	}

}

//species obstacle parent: virus_container {
//}
species people parent: virus_container skills: [moving] {
	float spd <- 1.0;
	int size <- 1;
	building my_building <- nil;
	building my_school <- nil;
	people my_friend <- nil;
	geometry my_bound;
	point my_target <- nil;
	bool moving <- false;
	bool visiting <- false;
	bool making_conversation <- false;
	bool masked <- false;
	bool at_school <- false;
	int exposed_period <- 14;
	int infected_period <- 14;
	int cnt <- 0;
	geometry shape <- circle(size);

	reflex epidemic {
		if (exposed) {
			cnt <- cnt + 1;
			if (cnt >= exposed_period * 20) {
				cnt <- 0;
				exposed <- false;
				infected <- true;
			}

		}

		if (infected) {
			cnt <- cnt + 1;
			if (cnt >= infected_period * 20) {
				cnt <- 0;
				exposed <- false;
				infected <- false;
			}

		}

	}

	reflex spreading_virus when: exposed or infected {
		ask ((people at_distance (size * 2)) where (!each.exposed and !each.infected)) {
			exposed <- masked ? (flip(0.001) ? true : false) : (flip(0.5) ? true : false);
			exposed_period <- rnd(max_exposed_period);
			infected_period <- 1 + rnd(10);
		}

	}

	reflex living when: !moving {
		do wander speed: spd bounds: my_bound;
		if (off_school) {
			if (flip(0.001)) {
				if (flip(0.01)) {
					moving <- true;
					my_friend <- any((people - self) where (!each.moving and (my_building overlaps each)));
				} else {
					if (!infected) {
						visiting <- true;
						my_target <- any_location_in(any(building where (!each.is_school)));
					}

				}

			}

		} else {
			if (flip(0.01)) {
				moving <- true;
				my_friend <- any((people - self) where (!each.moving and (my_bound overlaps each)));
				if (my_friend = nil) {
					moving <- false;
				}

			} else {
				if (at_school) {
					if (flip(0.0005)) {
						visiting <- true;
						my_target <- any_location_in(my_building);
					}

				} else {
					if (flip(0.05)) {
						visiting <- true;
						my_target <- any_location_in(my_school);
					}

				}

			}

		}

	}

	reflex visit when: visiting {
		do goto target: my_target on: road_network speed: 10.0;
		if (location = my_target) {
			visiting <- false;
			if (!off_school) {
				at_school <- !at_school;
				my_bound <- my_building.shape;
				if (at_school) {
					my_bound <- my_school.shape;
				}

			}

		}

	}

	reflex moving when: moving {
		do goto target: my_friend.location speed: 10.0;
		if (location distance_to my_friend < (size * 2)) {
			moving <- false;
			making_conversation <- false;
		}

	}

	aspect default {
		draw shape color: exposed ? #pink : (infected ? #red : #green);
	}

}

experiment sim {
	parameter "OFF SCHOOL" var: off_school <- true category: "Education planning";
	output {
		layout horizontal([0::6740, 1::3260]) tabs: true editors: false;
		display "d1" synchronized: false {
			species road refresh: false;
			species building;
			species people;
		}

		display "chart" {
			chart "sir" background: #white axes: #black {
				data "susceptible" value: length(people where (!each.exposed and !each.infected)) color: #green marker: false style: line;
				data "infected" value: length(people where (each.exposed or each.infected)) color: #red marker: false style: line;
			}

		}

	}

}
/**
* Name: Luneray's flu 4
* Author: Patrick Taillandier
* Description: Use of a graph to constraint the movements of people
* Tags: graph, moving
*/
model model4

global {
	int nb_people <- 1000;
	int nb_infected_init <- 5;
	float step <- 5 #mn;
	file roads_shapefile <- file("../includes/nkRoadsSimple.shp");
	file buildings_shapefile <- file("../includes/nkBuildingSimple.shp");
	geometry shape <- envelope(roads_shapefile);
	graph road_network;
	int nb_people_infected <- nb_infected_init update: people count (each.is_infected);
	int nb_people_recovered <- 0 update: people count (each.is_recovered);
	int nb_people_not_infected <- nb_people - nb_infected_init update: nb_people - nb_people_infected - nb_people_recovered;
	float infected_rate update: nb_people_infected / nb_people;

	init {
		create road from: roads_shapefile;
		road_network <- as_edge_graph(road);
		create building from: buildings_shapefile;
		create people number: nb_people {
			my_building <- one_of(building);
			location <- any_location_in(my_building);
		}

		ask nb_infected_init among people {
			is_infected <- true;
		}

	}

	reflex end_simulation when: infected_rate = 1.0 {
		do pause;
	}

}

species people skills: [moving] {
	float speed <- (0.2 + rnd(10) / 20) #km / #h;
	bool is_exposed <- false;
	bool is_infected <- false;
	bool is_recovered <- false;
//	bool is_dead <- false;
	point target;
	building my_building;
	int infected_period <- 0;

	reflex stay when: target = nil {
		if flip(0.05) {
			my_building <- one_of(building);
			target <- any_location_in(my_building);
		} else {
			do wander bounds: my_building.shape speed: ((rnd(3)) / 100) #km / #h;
		}

	}

	reflex move when: target != nil {
		do goto target: target on: road_network;
		if (location = target) {
			target <- nil;
		}

	}

	reflex spread when: is_exposed or is_infected {
//		ask people at_distance 10 #m {

		ask (people at_distance 10 #m) overlapping self {
			if flip(0.5) {
				is_exposed <- true;
			}

		}

	}

	reflex sick when: is_exposed {
		infected_period <- infected_period + 1;
		if (infected_period > 864) {
			is_exposed <- false;
			is_infected <- true;
			is_recovered <- false;
		}

	}

	reflex recover when: is_infected {
		infected_period <- infected_period + 1;
		if (infected_period > 4000) {
			if (flip(0.9)) {
				is_exposed <- false;
				is_infected <- false;
				is_recovered <- true;
//				is_dead <- false;
				infected_period <- 0;
			}

		}

	}

	aspect circle {
		draw circle(1) color: is_infected ? #red : (is_recovered ? #blue : #green);
	}

}

species road {

	aspect geom {
		draw shape color: #black;
	}

}

species building {

	aspect geom {
		draw shape empty: true color: #gray;
	}

}

experiment main type: gui {
	parameter "Nb people infected at init" var: nb_infected_init min: 1 max: 2147;
	output {
	 layout horizontal([0::5000,1::5000]) tabs:true editors: false;
	//		monitor "Infected people rate" value: infected_rate;
		display map {
			species road aspect: geom;
			species building aspect: geom;
			species people aspect: circle;
		}

		display chart_display refresh: every(10 #cycles) {
			chart "Disease spreading" type: series {
				data "susceptible" value: nb_people_not_infected color: #green marker:false;
				data "infected" value: nb_people_infected color: #red marker:false;
				data "recovered" value: nb_people_recovered color: #blue marker:false;
			}

		}

	}

}

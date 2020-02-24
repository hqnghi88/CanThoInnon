/***
* Name: Corona
* Author: hqngh
* Description: 
* Tags: Tag1, Tag2, TagN
***/
model Corona

global {
	float seed<-0.5362681362380473;
	
	int max_exposed_period <- 30;
	init {
	//		create obstacle number:10;
		create people number: 100 {
//			masked <- flip(0.8) ? true : false;
		}

		ask 1 among (people) {
			exposed <- true;
		}

	}

}

species virus_container {
	bool infected <- false;
	bool exposed <- false;
}

species obstacle parent: virus_container {
}

species people parent: virus_container skills: [moving] {
	float spd <- 0.1;
	people my_friend <- nil;
	point my_target <- nil;
	bool moving <- false;
	bool making_conversation <- false;
	bool masked <- false;
	int exposed_period <- 14;
	int infected_period <- 14;
	int cnt <- 0;

	reflex epidemic {
		if (exposed) {
			cnt <- cnt + 1;
			if (cnt >= exposed_period*20) {
				cnt <- 0;
				exposed <- false;
				infected <- true;
			}

		}

		if (infected) {
			cnt <- cnt + 1;
			if (cnt >= infected_period*20) {
				cnt <- 0;
				exposed <- false;
				infected <- false;
			}

		}

	}


	reflex spreading_virus when: exposed or infected {
		ask ((people at_distance 2) where (!each.exposed and !each.infected)) {
			exposed <- masked ? (flip(0.001) ? true : false) : (flip(0.5) ? true : false);
			exposed_period<-rnd(max_exposed_period);
			infected_period<-1+rnd(10);
		}

	}

	reflex living when: !moving {
		do wander speed: spd;
		if (flip(0.001)) {
			moving <- true;
			if (flip(0.5)) {
				making_conversation <- true;
				my_friend <- any((people - self) where (!each.moving));
			} else {
				my_target <- any_location_in(world.shape);
			}

		}

	}
	reflex moving when: moving {
		if (making_conversation) {
			do goto target: my_friend.location speed: 1.0;
			if (location distance_to my_friend < 2) {
				moving <- false;
				making_conversation <- false;
			}

		} else {
			do goto target: my_target speed: 1.0;
			if (location distance_to my_target < 2) {
				moving <- false;
			}

		}

	}

	aspect default {
		draw circle(1) color:exposed?#pink:(infected ? #red : #green);
	}

}

experiment sim {
	output {
		layout horizontal([0::5000, 1::5000]) tabs: true editors: false;
		display "d1" synchronized: false {
			species obstacle;
			species people;
		}

		display "Statistic" {
			chart "Number of people stuck in traffic jams" type: series {
				data "infected " value: length(people where (!each.exposed and !each.infected)) color: #green marker: false style: line;
				data "infected " value: length(people where (each.exposed or each.infected)) color: #red marker: false style: line;
			}

		}

	}

}